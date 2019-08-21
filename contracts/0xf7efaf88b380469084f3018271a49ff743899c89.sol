pragma solidity ^0.4.25;

/**
 * @title SGDS ERC20 token
 *
 * @dev SGDS are stable coin from SEITEE Pte Ltd use only to compare
 *  1 - 1 with SGD Dollar
 *  it for use only internal in NATEE Service and other service from Seitee in future;
 *  This stable coin are unlimit but can user a lot of crypto to buy it with exchange late FROM Seitee Only
 *  SGDS are control by SEITEE Pte,Ltd. Please understand before purchase it
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


contract StandarERC20 is ERC20{
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


contract SGDS is StandarERC20, Ownable {
  using SafeMath256 for uint256;
  string public name = "SEITEE SGD";
  string public symbol = "SGDS"; 
  uint256 public decimals = 2;
  uint256 public totalUsed;
  uint256 public totalPurchange;
  uint256 public transFee = 100; // default transection fee = 1.00 SGDS
  uint256 public version = 10000;
  
  
  struct PurchaseData{
    string fromCoin;   // Name OF Coin or Token BTC,LITE,ETH,ETC or other
    uint256 value;     // Value from that coin  18 dacimon
    uint256 exchangeRate; // 1: xxxxx   18 decimon
    string tranHash;  // Tran hash from that token 
  }

  event PurchaseSGDS(address indexed addr,uint256 value,uint256 refID);
  event UsedSGDS(address indexed addr,uint256 value);
  event SetControlToken(address indexed addr, bool outControl);
  event FeeTransfer(address indexed addr,uint256 _value);
  event TransferWallet(address indexed from,address indexed to,address indexed execute_);

  mapping(address => bool) userControl;   // if true mean can't not control this address
  mapping(uint256 => uint256) purchaseID;

  PurchaseData[]  purDatas;

  constructor() public {
    totalSupply_ = 0;
    totalUsed = 0;
    totalPurchange = 0;
  }

// It can only purchase direct from SETITEE ONLY
  function purchaseSGDS(address addr, uint256 value,uint256 refID,string fromCoin,uint256 coinValue,uint256 rate,string txHash)  external onlyOwners{
    balance[addr] += value;
    totalSupply_ += value;
    totalPurchange += value;
    
    uint256 id = purDatas.push(PurchaseData(fromCoin,coinValue,rate,txHash));
    purchaseID[refID] = id;

    emit PurchaseSGDS(addr,value,refID);
    emit Transfer(address(this),addr,value);
  }

  function getPurchaseData(uint256 refID) view public returns(string fromCoin,uint256 value,uint256 exchangeRate,string txHash) {
    require(purchaseID[refID] > 0);
    uint256  pId = purchaseID[refID] - 1;
    PurchaseData memory pData = purDatas[pId];

    fromCoin = pData.fromCoin;
    value = pData.value;
    exchangeRate = pData.exchangeRate;
    txHash = pData.tranHash;

  }

// This will cal only in website then it will no gas fee for user that buy and use in my system.
// SETITEE will pay for that
  function useSGDS(address useAddr,uint256 value) onlyOwners external returns(bool)  {
    require(userControl[useAddr] == false); // if true user want to  make it by your self
    require(balance[useAddr] >= value);

    balance[useAddr] -= value;
    totalSupply_ -= value;
    totalUsed += value;

    emit UsedSGDS(useAddr,value);
    emit Transfer(useAddr,address(0),value);

    return true;
  }

// This for use seitee transfer . Seitee will pay for gas
  function intTransfer(address _from, address _to, uint256 _value) external onlyOwners returns(bool){
    require(userControl[_from] == false);  // Company can do if they still allow compay to do it
    require(balance[_from] >= _value);
    require(_to != address(0));
        
    balance[_from] -= _value; 
    balance[_to] += _value;
    
    emit Transfer(_from,_to,_value);
    return true;
  }

  // For transfer all SGDS Token to new Wallet Address. Want to pay 1 SGDS for fee.
  
  function transferWallet(address _from,address _to) external onlyOwners{
        require(userControl[_from] == false);
        require(balance[_from] > transFee);  //Fee 1 SGDS
        uint256  value = balance[_from];

        balance[_from] = balance[_from].sub(value);
        balance[_to] = balance[_to].add(value - transFee); // sub with FEE

        emit TransferWallet(_from,_to,msg.sender);
        emit Transfer(_from,_to,value - transFee);
        emit FeeTransfer(_to,transFee);
  }

// Address Owner can set permision by him self. Set to true will stop company control his/her wallet
  function setUserControl(bool _control) public {
    userControl[msg.sender] = _control;
    emit SetControlToken(msg.sender,_control);
  }

  function getUserControl(address _addr) external view returns(bool){
    return userControl[_addr];
  }
  
  function setTransFee(uint256 _fee) onlyOwners public{
    transFee = _fee;
  }
}