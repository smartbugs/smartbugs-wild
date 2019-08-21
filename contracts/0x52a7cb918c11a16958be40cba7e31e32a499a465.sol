pragma solidity ^0.4.16;


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
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */

  modifier onlyOwner(){
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
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

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
      */
  function transfer(address _to, uint256 _value) public returns (bool){
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
  function balanceOf(address _owner) public constant returns (uint256 balance) {
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
  mapping (address => mapping (address => uint256)) internal allowed;

  /**
  * @dev Transfer tokens from one address to another
  * @param _from address The address which you want to send tokens from
  * @param _to address The address which you want to transfer to
  * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
  * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
  * @param _spender The address which will spend the funds.
  * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {

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
    * @return A uint256 specifing the amount of tokens still avaible for the spender.
   */

  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {

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
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Transfer(0X0, _to, _amount);
    return true;
  }

  /**
  * @dev Function to stop minting new tokens.
  * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

contract FidentiaXToken is MintableToken {
  // Coin Properties
  string public name = "fidentiaX";
  string public symbol = "fdX";
  uint256 public decimals = 18;

  // Special propeties
  bool public tradingStarted = false;

  /**
  * @dev modifier that throws if trading has not started yet
   */
  modifier hasStartedTrading() {
    require(tradingStarted);
    _;
  }

  /**
  * @dev Allows the owner to enable the trading. This can not be undone
  */
  function startTrading() public onlyOwner {
    tradingStarted = true;
  }

  /**
  * @dev Allows anyone to transfer the Change tokens once trading has started
  * @param _to the recipient address of the tokens.
  * @param _value number of tokens to be transfered.
   */
  function transfer(address _to, uint _value) hasStartedTrading public returns (bool) {
    return super.transfer(_to, _value);
  }

  /**
  * @dev Allows anyone to transfer the Change tokens once trading has started
  * @param _from address The address which you want to send tokens from
  * @param _to address The address which you want to transfer to
  * @param _value uint the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint _value) hasStartedTrading public returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function emergencyERC20Drain( ERC20 oddToken, uint amount ) public {
    oddToken.transfer(owner, amount);
  }
}

contract Sender {
    
    address firstContractor = 0x155020972767efc46DDA0Ec63A95627550F8C64F;
    address secondContractor = 0xDcDa40786C0E63B7932B7F844846eDce994a0851;
    
    function SendThreeWays( address multisig, uint256 value ) internal {
        uint256 cshare = value / 400;
        uint256 mainshare = value - 2 * cshare;
        firstContractor.transfer(cshare);
        secondContractor.transfer(cshare);
        multisig.transfer(mainshare);
    }
    
}

contract FidentiaXTokenSale is Ownable,Sender {

  using SafeMath for uint256;

  // The token being sold
  FidentiaXToken public token;

  uint256 public decimals;  

  uint256 public oneCoin;

  // start and end block where investments are allowed (both inclusive)
  uint256 public startTimestamp;
  uint256 public endTimestamp;

  // timestamps for tiers
  uint256 public tier1Timestamp;
  uint256 public tier2Timestamp;

  // address where funds are collected

  address public multiSig;

  function setWallet(address _newWallet) public onlyOwner {
    multiSig = _newWallet;
  }

  // These will be set by setTier()

  uint256 public rate; // how many token units a buyer gets per wei

  uint256 public minContribution = 0.0001 ether;  // minimum contributio to participate in tokensale

  uint256 public maxContribution = 200000 ether;  // default limit to tokens that the users can buy

  // ***************************
  // amount of raised money in wei

  uint256 public weiRaised;

  // amount of raised tokens 

  uint256 public tokenRaised;

  // maximum amount of tokens being created

  uint256 public maxTokens;

  // maximum amount of tokens for sale

  uint256 public tokensForSale;  // 24 Million Tokens for SALE

  // number of participants in presale

  uint256 public numberOfPurchasers = 0;

  //  for whitelist
  address public cs;
  //  for whitelist AND placement
  address public fx;

  // switch on/off the authorisation , default: true - on

  bool    public freeForAll = false;

  mapping (address => bool) public authorised; // just to annoy the heck out of americans

  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  event SaleClosed();

  function FidentiaXTokenSale() public {
    startTimestamp = 1509930000; //  Monday November 06, 2017 09:00:00 (am) in time zone Asia/Singapore (SGT)
    //1508684400;
    endTimestamp = 1512489599;   //  December 05, 2017 23:59:59 (pm) in time zone Asia/Singapore (SGT) ( GMT +08:00 )
    tier1Timestamp = 1510102799; //   November 08, 2017 08:59:59 (am) in time zone Asia/Singapore (SGT)
    tier2Timestamp = 1510361999; //   November 11, 2017 08:59:59 (am) in time zone Asia/Singapore (SGT)
    multiSig = 0x90420B8aef42F856a0AFB4FFBfaA57405FB190f3;
    token = new FidentiaXToken();
    decimals = token.decimals();
    oneCoin = 10 ** decimals;
    maxTokens = 130 * (10**6) * oneCoin;
    tokensForSale = 130 * (10**6) * oneCoin;
  }

  /**
  * @dev Calculates the amount of bonus coins the buyer gets
   */
  function getRateAt(uint256 at) internal constant returns (uint256) {
    if (at < (tier1Timestamp))
      return 575;
    if (at < (tier2Timestamp))
      return 550;
    return 500;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    if (now > endTimestamp)
      return true;
    if (tokenRaised >= tokensForSale)
      return true; // if we reach the tokensForSale
    return false;
 }
  /**
  * @dev throws if person sending is not contract owner or cs role
   */
  modifier onlyCSorFx() {
    require((msg.sender == fx) || (msg.sender==cs));
    _;
  }

  modifier onlyFx() {
    require(msg.sender == fx);
    _;
  }

  /**
  * @dev throws if person sending is not authorised or sends nothing
  */
  modifier onlyAuthorised() {
    require (authorised[msg.sender] || freeForAll);
    require (now >= startTimestamp);
    require (!(hasEnded()));
    require (multiSig != 0x0);
    require (msg.value > 1 finney);
    require(tokensForSale > tokenRaised); // check we are not over the number of tokensForSale
    _;
  }

  /**
  * @dev authorise an account to participate
  */
  function authoriseAccount(address whom) onlyCSorFx public {
    authorised[whom] = true;
  }

  /**
  * @dev authorise a lot of accounts in one go
  */
  function authoriseManyAccounts(address[] many) onlyCSorFx public {
    for (uint256 i = 0; i < many.length; i++) {
      authorised[many[i]] = true;
    }
  }

  /**
  * @dev ban an account from participation (default)
  */
  function blockAccount(address whom) onlyCSorFx public {
    authorised[whom] = false;
  }

  /**
  * @dev set a new CS representative
  */
  function setCS(address newCS) onlyOwner public {
    cs = newCS;
  }

  /**
  * @dev set a new Fx representative
  */
  function setFx(address newFx) onlyOwner public {
    fx = newFx;
  }

  function placeTokens(address beneficiary, uint256 _tokens) onlyFx public {
    //check minimum and maximum amount
    require(_tokens != 0);
    require(!hasEnded());
    uint256 amount = 0;
    if (token.balanceOf(beneficiary) == 0) {
      numberOfPurchasers++;
    }
    tokenRaised = tokenRaised.add(_tokens); // so we can go slightly over
    token.mint(beneficiary, _tokens);
    TokenPurchase(beneficiary, beneficiary, amount, _tokens);
  }

  // low level token purchase function
  function buyTokens(address beneficiary, uint256 amount) onlyAuthorised internal {
    //check minimum and maximum amount
    require(amount >= minContribution);
    require(amount <= maxContribution);

    // Calculate token amount to be purchased
    uint256 actualRate = getRateAt(now);
    uint256 tokens = amount.mul(actualRate);

    // update state
    weiRaised = weiRaised.add(amount);
    if (token.balanceOf(beneficiary) == 0) {
      numberOfPurchasers++;
    }
    tokenRaised = tokenRaised.add(tokens); // so we can go slightly over
    token.mint(beneficiary, tokens);
    TokenPurchase(beneficiary, beneficiary, amount, tokens);
    SendThreeWays(multiSig,this.balance); // better in case any other ether ends up here
  }

  // transfer ownership of the token to the owner of the presale contract
  function finishSale() public onlyOwner {
    require(hasEnded());
    // assign the rest of the 100M tokens to the reserve
    uint unassigned;
    if(maxTokens > tokenRaised) {
      unassigned  = maxTokens.sub(tokenRaised);
      token.mint(multiSig,unassigned);
    }
    token.finishMinting();
    token.transferOwnership(owner);
    SaleClosed();
  }

  // fallback function can be used to buy tokens
  function () public payable {
    buyTokens(msg.sender, msg.value);
  }

  function emergencyERC20Drain( ERC20 oddToken, uint amount ) public {
    oddToken.transfer(owner, amount);
  }
}