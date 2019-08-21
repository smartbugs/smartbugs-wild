pragma solidity ^0.4.15;
 
/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}
 
/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}
 
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
 
  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
 
  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }
 
  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
  
}
 
/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
    
  using SafeMath for uint256;
 
  mapping(address => uint256) balances;
  
  Crowdsale crowdsale;
  
    modifier crowdsaleIsOverOrThisIsContract(){
      require(crowdsale.isCrowdsaleOver() || msg.sender == crowdsale.getContractAddress());
      _;
  }
 
  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) crowdsaleIsOverOrThisIsContract returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }
 
  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }
 
}
 
/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {
 
  mapping (address => mapping (address => uint256)) allowed;
  
  
  
  function StandardToken(Crowdsale x){
      crowdsale =x;
  }
  

 
  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];
 
    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);
 
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }
 
  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {
 
    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));
 
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }
 
  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
 
}
 
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    
  address public owner;
 
  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }
 
  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
 
  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    owner = newOwner;
  }
 
}
 
/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
 
contract MintableToken is StandardToken, Ownable {
    
     function MintableToken(Crowdsale x) StandardToken(x){
        
    }
    
  event Mint(address indexed to, uint256 amount);
  
  event MintFinished();
 
  bool public mintingFinished = false;
 
  modifier canMint() {
    require(!mintingFinished);
    _;
  }
 
  /**
   * @dev Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    allowed[_to][_to] =  allowed[_to][_to].add(_amount);
    Mint(_to, _amount);
    return true;
  }
 
  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
  
}
 
contract DjohniKrasavchickToken is MintableToken {
    
    string public constant name = "DjohniKrasavchickToken";
    
    string public constant symbol = "DJKR";
    
    uint32 public constant decimals = 2;
    
    function DjohniKrasavchickToken(Crowdsale x) MintableToken(x){
        
    } 
    
}
 
 
contract Crowdsale is Ownable {
    
    using SafeMath for uint;
    
    address public myWalletForETH;
    
    uint public bountyPercent;
    
    uint public djonniPercent;
    
    uint public developerPercent;
    
    uint public bountyTokens;
    
    uint public djonniTokens;
    
    uint public developerTokens;
    
    address[] public bountyAdresses;
 
    DjohniKrasavchickToken public token = new DjohniKrasavchickToken(this);
 
    uint public start;
    
    uint public period;
 
    uint public hardcap;
 
    uint public rate;
    
    uint public softcap;
    
    bool private isHardCapWasReached = false;
    
    bool private isCrowdsaleStoped = false;
    
    mapping(address => uint) public balances;
 
    function Crowdsale() {
      myWalletForETH = 0xe4D5b0aECfeFf1A39235f49254a0f37AaA7F6cC0;
      bountyPercent = 10;
      djonniPercent = 50;
      developerPercent = 20;
      rate = 100000000;
      start = 1536858000;
      period = 14;
      hardcap = 200000000000000000;
      softcap = 50000000000000000;
    }
     
    function getContractAddress() public returns(address){
        return this;
    }
    
    function isCrowdsaleOver() public returns(bool){
        if( isCrowsdaleTimeFinished() || isHardCapReached() || isCrowdsaleStoped){
            return true;
        }
        return false;
    }
    
    function isCrowsdaleTimeFinished() internal returns(bool){
        if(now > start + period * 1 hours){
            return true;
        }
        return false;
    }
    
    function isHardCapReached() internal returns (bool){
        if(hardcap==this.balance){
            isHardCapWasReached = true;
        }
        return isHardCapWasReached;
    }
    
    function stopCrowdSaleOnlyForOwner() onlyOwner{
        if(!isCrowdsaleStoped){
         stopCrowdSale();
        }
    }
    
    function stopCrowdSale() internal{
        if(token.mintingFinished() == false){
              finishMinting();
        }
        isCrowdsaleStoped = true;
    }
 
    modifier saleIsOn() {
      require(now > start && now < start + period * 1 hours);
      _;
    }
    
    modifier crowdsaleIsOver() {
      require(isCrowdsaleOver());
      _;
    }

    modifier isUnderHardCap() {
      require(this.balance <= hardcap && !isHardCapWasReached );
      _;
    }
    
    modifier onlyOwnerOrSaleIsOver(){
        require(owner==msg.sender || isCrowdsaleOver() );
        _;
    }
 
    function refund() {
      require(this.balance < softcap && now > start + period * 1 hours);
      uint value = balances[msg.sender]; 
      balances[msg.sender] = 0; 
      msg.sender.transfer(value); 
    }
 
    function finishMinting() public onlyOwnerOrSaleIsOver  {
      if(this.balance > softcap) {
        myWalletForETH.transfer(this.balance);
        uint issuedTokenSupply = token.totalSupply();
        uint additionalTokens = bountyPercent+developerPercent+djonniPercent;
        uint tokens = issuedTokenSupply.mul(additionalTokens).div(100 - additionalTokens);
        token.mint(this, tokens);
        token.finishMinting();
        issuedTokenSupply = token.totalSupply();
        bountyTokens = issuedTokenSupply.div(100).mul(bountyPercent);
        developerTokens = issuedTokenSupply.div(100).mul(developerPercent);
        djonniTokens = issuedTokenSupply.div(100).mul(djonniPercent);
        token.transfer(myWalletForETH, developerTokens);
      }
    }
    
    function showThisBallance() public returns (uint){
        return this.balance;
    }

 
   function createTokens() isUnderHardCap saleIsOn payable {
      uint tokens = rate.mul(msg.value).div(1 ether);
      token.mint(this, tokens);
      token.transfer(msg.sender, tokens);
      balances[msg.sender] = balances[msg.sender].add(msg.value);
    }
    

 
    function() external payable {
     if(isCrowsdaleTimeFinished() && !isCrowdsaleStoped){
       stopCrowdSale();    
     }
     createTokens();
     if(isCrowdsaleOver() && !isCrowdsaleStoped){
      stopCrowdSale();
     }
    }
    
    function addBountyAdresses(address[] array) onlyOwner{
               for (uint i = 0; i < array.length; i++){
                  bountyAdresses.push(array[i]);
               }
    }
    
    function distributeBountyTokens() onlyOwner crowdsaleIsOver{
               uint amountofTokens = bountyTokens/bountyAdresses.length;
               for (uint i = 0; i < bountyAdresses.length; i++){
                  token.transfer(bountyAdresses[i], amountofTokens);
               }
               bountyTokens = 0;
    }
    
        function distributeDjonniTokens(address addr) onlyOwner crowdsaleIsOver{
                  token.transfer(addr, djonniTokens);
                  djonniTokens = 0;
              
    }
    
    
    
}