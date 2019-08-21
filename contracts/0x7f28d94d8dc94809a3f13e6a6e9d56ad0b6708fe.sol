pragma solidity ^0.4.25;

/**
 * @title NATEE WARRANT 01 ERC20 token
 *
 * @dev NATEE WARRANT 01 use for airdrop bonus and other for NATEE Token
 * User can transfer to NATEE Token by pay at FIX RATE 
 * if user hold NATEE WARRANT until expride FEE to change will reduce to 0 
 */

library SafeMath256 {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if(a==0 || b==0)
        return 0;  
    uint256 c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b>0);
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
   require( b<= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }
  
}


// Only Owner modifier it support a lot owner but finally should have 1 owner
contract Ownable {

  mapping (address=>bool) owners;
  address owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  event AddOwner(address newOwner);
  event RemoveOwner(address owner);
  /**
   * @dev Ownable constructor ตั้งค่าบัญชีของ sender ให้เป็น `owner` ดั้งเดิมของ contract 
   *
   */
   constructor() public {
    owner = msg.sender;
    owners[msg.sender] = true;
  }

  function isContract(address _addr) internal view returns(bool){
     uint256 length;
     assembly{
      length := extcodesize(_addr)
     }
     if(length > 0){
       return true;
    }
    else {
      return false;
    }

  }

 // For Single Owner
  modifier onlyOwner(){
    require(msg.sender == owner);
    _;
  }


  function transferOwnership(address newOwner) public onlyOwner{
    require(isContract(newOwner) == false);
    emit OwnershipTransferred(owner,newOwner);
    owner = newOwner;

  }

  //For multiple Owner
  modifier onlyOwners(){
    require(owners[msg.sender] == true);
    _;
  }

  function addOwner(address newOwner) public onlyOwners{
    require(owners[newOwner] == false);
    require(newOwner != msg.sender);

    owners[newOwner] = true;
    emit AddOwner(newOwner);
  }

  function removeOwner(address _owner) public onlyOwners{
    require(_owner != msg.sender);  // can't remove your self
    owners[_owner] = false;
    emit RemoveOwner(_owner);
  }

  function isOwner(address _owner) public view returns(bool){
    return owners[_owner];
  }
}

contract ERC20 {
	     event Transfer(address indexed from, address indexed to, uint256 tokens);
       event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);

   	   function totalSupply() public view returns (uint256);
       function balanceOf(address tokenOwner) public view returns (uint256 balance);
       function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);

       function transfer(address to, uint256 tokens) public returns (bool success);
       
       function approve(address spender, uint256 tokens) public returns (bool success);
       function transferFrom(address from, address to, uint256 tokens) public returns (bool success);
  

}


contract StandardERC20 is ERC20{
  using SafeMath256 for uint256;  
     
     mapping (address => uint256) balance;
     mapping (address => mapping (address=>uint256)) allowed;


     uint256  totalSupply_;  
     
      event Transfer(address indexed from,address indexed to,uint256 value);
      event Approval(address indexed owner,address indexed spender,uint256 value);


    function totalSupply() public view returns (uint256){
      return totalSupply_;
    }

     function balanceOf(address _walletAddress) public view returns (uint256){
        return balance[_walletAddress];
     }


     function allowance(address _owner, address _spender) public view returns (uint256){
          return allowed[_owner][_spender];
        }

     function transfer(address _to, uint256 _value) public returns (bool){
        require(_value <= balance[msg.sender]);
        require(_to != address(0));

        balance[msg.sender] = balance[msg.sender].sub(_value);
        balance[_to] = balance[_to].add(_value);
        emit Transfer(msg.sender,_to,_value);
        
        return true;

     }

     function approve(address _spender, uint256 _value)
            public returns (bool){
            allowed[msg.sender][_spender] = _value;

            emit Approval(msg.sender, _spender, _value);
            return true;
            }

      function transferFrom(address _from, address _to, uint256 _value)
            public returns (bool){
               require(_value <= balance[_from]);
               require(_value <= allowed[_from][msg.sender]); 
               require(_to != address(0));

              balance[_from] = balance[_from].sub(_value);
              balance[_to] = balance[_to].add(_value);
              allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
              emit Transfer(_from, _to, _value);
              return true;
      }


     
}


contract SGDSInterface{
  function balanceOf(address tokenOwner) public view returns (uint256 balance);
  function intTransfer(address _from, address _to, uint256 _value) external;
  function transferWallet(address _from,address _to) external;
  function getCanControl(address _addr) external view returns(bool); // if true mean user can control by him. false mean Company can control
  function useSGDS(address useAddr,uint256 value) external returns(bool);
}

contract NATEE_WARRANT is StandardERC20, Ownable {
  using SafeMath256 for uint256;
  string public name = "NATEE WARRANT";
  string public symbol = "NATEE-W1"; // Real Name NATEE
  uint256 public decimals = 18;
  uint256 public INITIAL_SUPPLY = 20000000 ether;
  uint256 public totalUndist;  // How many warrant that not distributed
  uint256 public totalRedeem;
  address public NATEE_CONTRACT = address(0);
  uint256 public transFee = 100;
  uint32  public expireDate;

  SGDSInterface public sgds;

  event RedeemWarrant(address indexed addr,uint256 _value);
  event SetControlToken(address indexed addr, bool outControl);
  event FeeTransfer(address indexed addr,uint256 _value);
  event TransferWallet(address indexed from,address indexed to,address indexed execute_);

  mapping(address => bool) userControl;   

  constructor() public {
    totalSupply_ = INITIAL_SUPPLY;
    totalUndist = INITIAL_SUPPLY;
    expireDate = uint32(now + 1825 days);  // Start 5 Year Expire First

    sgds = SGDSInterface(0xf7EfaF88B380469084f3018271A49fF743899C89);
  }


  function setExpireDate(uint32 newDate) external onlyOwners{
    if(newDate < expireDate && newDate > uint32(now))
    {
        expireDate = newDate;
    }
  }
  function sendWarrant(address _to,uint256 _value) external onlyOwners {
    require(_value <= totalUndist);
    balance[_to] += _value;
    totalUndist -= _value;

    emit Transfer(address(this),_to,_value);
  }

// This for use seitee transfer . Seitee will pay for gas
  function intTransfer(address _from, address _to, uint256 _value) external onlyOwners{
    require(userControl[_from] == false);  // Company can do if they still allow compay to do it
    require(balance[_from] >= _value);
    //require(_to != address(0)); // internal Call then can remove this
        
    balance[_from] -= _value; 
    balance[_to] += _value;
    
    emit Transfer(_from,_to,_value);
        
  }

  // THIS IS SOS FUNCTION 
  // For transfer all Warrant Token to new Wallet Address. Want to pay 1 SGDS for fee.
  
  function transferWallet(address _from,address _to) external onlyOwners{
    require(userControl[_from] == false); 
    require(sgds.getCanControl(_from) == false);
    require(sgds.balanceOf(_from) >= transFee);

    uint256  value = balance[_from];

    balance[_from] = balance[_from].sub(value);
    balance[_to] = balance[_to].add(value); // sub with FEE

    sgds.useSGDS(_from,transFee);

    emit TransferWallet(_from,_to,msg.sender);
    emit Transfer(_from,_to,value);
  }

// This function will call direct from Natee Contract To deduct Warrant
  function redeemWarrant(address _from, uint256 _value) external {
    require(msg.sender == NATEE_CONTRACT);
    require(balance[_from] >= _value);

    balance[_from] = balance[_from].sub(_value);
    totalSupply_ -= _value;
    totalRedeem += _value;

    emit Transfer(_from,address(0),_value);
    emit RedeemWarrant(_from,_value);
  }

// Address Owner can set permision by him self. Set to true will stop company control his/her wallet
  function setUserControl(bool _control) public {
    userControl[msg.sender] = _control;
    emit SetControlToken(msg.sender,_control);
  }

  function getUserControl(address _addr) external view returns(bool){
    return userControl[_addr];
  }

// This function can set 1 time to make sure no one can cheat 
  function setNateeContract(address addr) onlyOwners external{
    require(NATEE_CONTRACT == address(0));
    NATEE_CONTRACT = addr; 
  }

  function setTransFee(uint256 _fee) onlyOwners public{
    transFee = _fee;
  }

}