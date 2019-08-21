pragma solidity ^0.4.15;

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
 * @title ERC20Basic
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);

  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20Basic {

  using SafeMath for uint256;

  mapping (address => mapping (address => uint256)) internal allowed;
  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
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


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is StandardToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value > 0);
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }
}


/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is BurnableToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
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


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }

}

contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

}

/*
 * @title GESToken
 */
contract GESToken is MintableToken, PausableToken {
  string public constant name = "Galaxy eSolutions";
  string public constant symbol = "GES";
  uint8 public constant decimals = 18;
}

/**
 * @title Crowdsale
 * @dev Modified contract for managing a token crowdsale.
 */

contract GESTokenCrowdSale is Ownable {
  using SafeMath for uint256;

  /* true for finalised crowdsale */
  bool public isFinalised;

  /* The token object */
  MintableToken public token;

  /* Start and end timestamps where investments are allowed (both inclusive) */
  uint256 public mainSaleStartTime;
  uint256 public mainSaleEndTime;

  /* Address where funds are transferref after collection */
  address public wallet;

  /* Address where company funds will be collected */
  address public tokenWallet;

  /* How many token units a buyer gets per ether */
  uint256 public rate = 10000;

  /* Amount of raised money in wei */
  /* PreSale + Whitelist =  1273.779099 ETH*/
  uint256 public weiRaised = 1273779099000000000000 ;

  /* 20,000 - 1,273.779099 = 18,726 is what will be raised*/

  /* Minimum amount of Wei allowed per transaction = 0.1 Ethers */
  uint256 public saleMinimumWei = 100000000000000000; 
  
  /* Hard Cap amount of Wei allowed 20,000 ETH */
  uint256 public hardCap = 20000000000000000000000; 
  
  /* Hard Cap amount oftokens to be sold 300000000 */
  /* Amount raise in preSale removing the extra company 11% as we are allocating here */
  /* 300000000 - 12235717 - 33000000 - 6178952 = 248585331 */
  /* Tokens to be sold in the ICO 248585330 */
  uint256 public tokensToSell = 248585331 * 10 ** 18; 

  /* Always default to 20 can go upto 50 base don amount being sent */
   struct AmountBonus {
    uint256 amount;
    uint percent;
  }
  AmountBonus[] public amountBonuses;
  /**
   * event for token purchase logging
   * event for finalizing the crowdsale
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  event FinalisedCrowdsale(uint256 totalSupply);

  function GESTokenCrowdSale(uint256 _mainSaleStartTime, uint256 _mainSaleEndTime, address _wallet, address _tokenWallet) public {

    /* Can't start main sale in the past */
    require(_mainSaleStartTime >= now);
    /* Can't close main sale earlier than start time */
    require(_mainSaleEndTime >= _mainSaleStartTime);

    /* Confirming wallet addresses as valid */
    require(_wallet != 0x0);
    require(_tokenWallet != 0x0);

    /* Create GES token */
    token = createTokenContract();
    
    amountBonuses.push(AmountBonus(    50000000000000000000, 20));
    amountBonuses.push(AmountBonus(   100000000000000000000, 25));
    amountBonuses.push(AmountBonus(   250000000000000000000, 30));
    amountBonuses.push(AmountBonus(   500000000000000000000, 35));
    amountBonuses.push(AmountBonus(  1000000000000000000000, 40));
    amountBonuses.push(AmountBonus(  2500000000000000000000, 45));
    amountBonuses.push(AmountBonus(200000000000000000000000, 50));


    mainSaleStartTime = _mainSaleStartTime;
    mainSaleEndTime = _mainSaleEndTime;

    wallet = _wallet ;
    tokenWallet = _tokenWallet;

    isFinalised = false;

    /* Mint tokens for previous backers [Removed the previous 11% the company raised in presale]*/
    /* 101964.308375680000000000 * 120 = 12235717 -> rounding to highest integer */
    /* Fixed tokens for the whitelist money raised = 6178952 */
    /* Fixed tokens for the management and bounty = 33000000 */
    /* Total to allot: 6178952 + 12235717 + 33000000 = 51414669 */
    token.mint(tokenWallet, 51414669 * 10 ** 18);
  }

  /* Creates the token to be sold */
  function createTokenContract() internal returns (MintableToken) {
    return new GESToken();
  }

  /* Fallback function can be used to buy tokens */
  function () public payable {
    buyTokens(msg.sender);
  }

  /* Low level token purchase function */
  function buyTokens(address beneficiary) public payable {
    require(!isFinalised);
    require(beneficiary != 0x0);
    require(msg.value != 0);
    require(now >= mainSaleStartTime && now <= mainSaleEndTime);
    uint256 newRaise = weiRaised.add(msg.value);
    require(msg.value >= saleMinimumWei && newRaise <= hardCap);

    /* Add bonus to tokens depends on the value */
    uint256 bonusedTokens = applyBonus(msg.value);
    
    /* Check if we have available tokens to sell */
    require(bonusedTokens < tokensToSell);

    /* Update state on the blockchain */
    weiRaised = newRaise;
    tokensToSell = tokensToSell.sub(bonusedTokens);
    token.mint(beneficiary, bonusedTokens);
    TokenPurchase(msg.sender, beneficiary, msg.value, bonusedTokens);
  }

  /* Finish Crowdsale,
   */
  function finaliseCrowdsale() external onlyOwner returns (bool) {
    require(!isFinalised);
    token.finishMinting();
    forwardFunds();
    FinalisedCrowdsale(token.totalSupply());
    isFinalised = true;
    return true;
  }

  /* Pause the token contract */
  function pauseToken() external onlyOwner {
    require(!isFinalised);
    GESToken(token).pause();
  }

  /* Unpause the token contract */
  function unpauseToken() external onlyOwner {
    GESToken(token).unpause();
  }

  /* Transfer token's contract ownership to a new owner */
  function transferTokenOwnership(address newOwner) external onlyOwner {
    GESToken(token).transferOwnership(newOwner);
  }

  /* @return true if main sale event has ended */
  function mainSaleHasEnded() external constant returns (bool) {
    return now > mainSaleEndTime;
  }

  /* Send ether to the fund collection wallet */
  function forwardFunds() internal {
    wallet.transfer(this.balance);
  }

  /* Set new dates for main-sale (emergency case) */
  function setMainSaleDates(uint256 _mainSaleStartTime, uint256 _mainSaleEndTime) public onlyOwner returns (bool) {
    require(!isFinalised);
    require(_mainSaleStartTime < _mainSaleEndTime);
    mainSaleStartTime = _mainSaleStartTime;
    mainSaleEndTime = _mainSaleEndTime;
    return true;
  }

  /* Function to calculate bonus tokens based on the amount sent by the contributor */
  function applyBonus(uint256 weiAmount) internal constant returns (uint256 bonusedTokens) {
    /* Bonus tokens to be added */
    uint256 tokensToAdd = 0;

    /* Calculting the amont of tokens to be allocated based on rate and the money transferred */
    uint256 tokens = weiAmount.mul(rate);
    
    for(uint8 i = 0; i < amountBonuses.length; i++){
        if(weiAmount < amountBonuses[i].amount){
           tokensToAdd = tokens.mul(amountBonuses[i].percent).div(100);
            return tokens.add(tokensToAdd);
        }
    }
    /* Default callback at 20%, just as a precaution */
    return tokens.mul(120).div(100);
  }

  /*  
  * Function to extract funds as required before finalizing
  */
  function fetchFunds() onlyOwner public {
    wallet.transfer(this.balance);
  }

}