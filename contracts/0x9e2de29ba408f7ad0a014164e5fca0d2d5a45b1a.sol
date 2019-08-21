// File: zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

pragma solidity ^0.4.21;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: zeppelin-solidity/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.4.21;



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: zeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.4.21;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: zeppelin-solidity/contracts/crowdsale/Crowdsale.sol

pragma solidity ^0.4.21;




/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overriden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropiate to concatenate
 * behavior.
 */
contract Crowdsale {
  using SafeMath for uint256;

  // The token being sold
  ERC20 public token;

  // Address where funds are collected
  address public wallet;

  // How many token units a buyer gets per wei
  uint256 public rate;

  // Amount of wei raised
  uint256 public weiRaised;

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  /**
   * @param _rate Number of token units a buyer gets per wei
   * @param _wallet Address where collected funds will be forwarded to
   * @param _token Address of the token being sold
   */
  function Crowdsale(uint256 _rate, address _wallet, ERC20 _token) public {
    require(_rate > 0);
    require(_wallet != address(0));
    require(_token != address(0));

    rate = _rate;
    wallet = _wallet;
    token = _token;
  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  function () external payable {
    buyTokens(msg.sender);
  }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param _beneficiary Address performing the token purchase
   */
  function buyTokens(address _beneficiary) public payable {

    uint256 weiAmount = msg.value;
    _preValidatePurchase(_beneficiary, weiAmount);

    // calculate token amount to be created
    uint256 tokens = _getTokenAmount(weiAmount);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    _processPurchase(_beneficiary, tokens);
    emit TokenPurchase(
      msg.sender,
      _beneficiary,
      weiAmount,
      tokens
    );

    _updatePurchasingState(_beneficiary, weiAmount);

    _forwardFunds();
    _postValidatePurchase(_beneficiary, weiAmount);
  }

  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

  /**
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
  }

  /**
   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _postValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
    // optional override
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param _beneficiary Address performing the token purchase
   * @param _tokenAmount Number of tokens to be emitted
   */
  function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
    token.transfer(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _beneficiary Address receiving the tokens
   * @param _tokenAmount Number of tokens to be purchased
   */
  function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
    _deliverTokens(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
   * @param _beneficiary Address receiving the tokens
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal {
    // optional override
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
    return _weiAmount.mul(rate);
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}

// File: zeppelin-solidity/contracts/token/ERC20/BasicToken.sol

pragma solidity ^0.4.21;




/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

// File: zeppelin-solidity/contracts/token/ERC20/StandardToken.sol

pragma solidity ^0.4.21;




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
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
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
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.4.21;


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
  function Ownable() public {
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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: zeppelin-solidity/contracts/token/ERC20/MintableToken.sol

pragma solidity ^0.4.21;




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
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

// File: zeppelin-solidity/contracts/crowdsale/emission/MintedCrowdsale.sol

pragma solidity ^0.4.21;




/**
 * @title MintedCrowdsale
 * @dev Extension of Crowdsale contract whose tokens are minted in each purchase.
 * Token ownership should be transferred to MintedCrowdsale for minting. 
 */
contract MintedCrowdsale is Crowdsale {

  /**
   * @dev Overrides delivery by minting tokens upon purchase.
   * @param _beneficiary Token purchaser
   * @param _tokenAmount Number of tokens to be minted
   */
  function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {
    require(MintableToken(token).mint(_beneficiary, _tokenAmount));
  }
}

// File: zeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol

pragma solidity ^0.4.21;




/**
 * @title TimedCrowdsale
 * @dev Crowdsale accepting contributions only within a time frame.
 */
contract TimedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public openingTime;
  uint256 public closingTime;

  /**
   * @dev Reverts if not in crowdsale time range.
   */
  modifier onlyWhileOpen {
    // solium-disable-next-line security/no-block-members
    require(block.timestamp >= openingTime && block.timestamp <= closingTime);
    _;
  }

  /**
   * @dev Constructor, takes crowdsale opening and closing times.
   * @param _openingTime Crowdsale opening time
   * @param _closingTime Crowdsale closing time
   */
  function TimedCrowdsale(uint256 _openingTime, uint256 _closingTime) public {
    // solium-disable-next-line security/no-block-members
    require(_openingTime >= block.timestamp);
    require(_closingTime >= _openingTime);

    openingTime = _openingTime;
    closingTime = _closingTime;
  }

  /**
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.
   * @return Whether crowdsale period has elapsed
   */
  function hasClosed() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return block.timestamp > closingTime;
  }

  /**
   * @dev Extend parent behavior requiring to be within contributing period
   * @param _beneficiary Token purchaser
   * @param _weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal onlyWhileOpen {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

}

// File: zeppelin-solidity/contracts/crowdsale/distribution/FinalizableCrowdsale.sol

pragma solidity ^0.4.21;





/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCrowdsale is TimedCrowdsale, Ownable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() onlyOwner public {
    require(!isFinalized);
    require(hasClosed());

    finalization();
    emit Finalized();

    isFinalized = true;
  }

  /**
   * @dev Can be overridden to add finalization logic. The overriding function
   * should call super.finalization() to ensure the chain of finalization is
   * executed entirely.
   */
  function finalization() internal {
  }

}

// File: contracts/Crowdsale/BasicCrowdsale.sol

pragma solidity ^0.4.24;




contract BasicCrowdsale is MintedCrowdsale, FinalizableCrowdsale {
    
    uint256 public cap = 100000000 * (10 ** 18); // Total number of MYO tokens that would be created
    uint256 public capForSale = 71000000 * (10 ** 18); // Total MYO tokens that could be sold during the ICO
    uint256 public bountyTokensCap = 5000000 * (10 ** 18); // Total number of MYO tokens that would be given as a reward
    uint256 public reservedForTeamTokens = 29000000 * (10 ** 18); // Tokens reserved for rewardpool, advisors and team that will be minted after Crowdsale
    uint256 public totalMintedBountyTokens; // Total number of MYO tokens given as a reward

    uint256 public privateSaleEndDate;
    mapping (address => bool) public minters;

    uint256 constant MIN_CONTRIBUTION_AMOUNT = 10 finney;
    uint256 constant MAX_CONTRIBUTION_AMOUNT = 250 ether;

    uint256 public constant PRIVATE_SALE_CAP = 26000000 * (10 ** 18);
    uint256 public constant PRIVATE_SALE_DURATION = 24 days; // to be calculated according to deployment day; the end date should be 15 May

    uint256 public constant MAIN_SALE_DURATION = 60 days;
    uint256 public mainSaleDurationExtentionLimitInDays = 120; //max days the duration of the ICO can be extended

    event LogFiatTokenMinted(address sender, address beficiary, uint256 amount);
    event LogFiatTokenMintedToMany(address sender, address[] beneficiaries, uint256[] amount);
    event LogBountyTokenMinted(address minter, address beneficiary, uint256 amount);
    event LogBountyTokenMintedToMany(address sender, address[] beneficiaries, uint256[] amount);
    event LogPrivateSaleExtended(uint256 extentionInDays);
    event LogMainSaleExtended(uint256 extentionInDays);
    event LogRateChanged(uint256 rate);
    event LogMinterAdded(address minterAdded);
    event LogMinterRemoved(address minterRemoved);

    constructor(uint256 _rate, address _wallet, address _token, uint256 _openingTime, uint256 _closingTime)
    Crowdsale(_rate, _wallet, ERC20(_token))
    TimedCrowdsale(_openingTime, _closingTime) public {
        privateSaleEndDate = _openingTime.add(PRIVATE_SALE_DURATION);
    }

    // only addresses who are allowed to mint
    modifier onlyMinter (){
        require(minters[msg.sender]);
        _;
    }

    function buyTokens(address beneficiary) public payable {
        require(msg.value >= MIN_CONTRIBUTION_AMOUNT);
        require(msg.value <= MAX_CONTRIBUTION_AMOUNT);
        uint amount = _getTokenAmount(msg.value);
        if(now <= privateSaleEndDate) {
            require(MintableToken(token).totalSupply().add(amount) < PRIVATE_SALE_CAP);
        }
        
        require(MintableToken(token).totalSupply().add(amount) <= capForSale);
        super.buyTokens(beneficiary);
    }

    function addMinter(address _minter) public onlyOwner {
        require(_minter != address(0));
        minters[_minter] = true;
        emit LogMinterAdded(_minter);
    }

    function removeMinter(address _minter) public onlyOwner {
        minters[_minter] = false;
        emit LogMinterRemoved(_minter);
    }

    function createFiatToken(address beneficiary, uint256 amount) public onlyMinter() returns(bool){
        require(!hasClosed());
        mintFiatToken(beneficiary, amount);
        emit LogFiatTokenMinted(msg.sender, beneficiary, amount);
        return true;
    }

    function createFiatTokenToMany(address[] beneficiaries, uint256[] amount) public onlyMinter() returns(bool){
        multiBeneficiariesValidation(beneficiaries, amount);
        for(uint i = 0; i < beneficiaries.length; i++){
            mintFiatToken(beneficiaries[i], amount[i]);
        } 
        emit LogFiatTokenMintedToMany(msg.sender, beneficiaries, amount);
        return true;
    }

    function mintFiatToken(address beneficiary, uint256 amount) internal {
        require(MintableToken(token).totalSupply().add(amount) <= capForSale);
        MintableToken(token).mint(beneficiary, amount);
    }

    function createBountyToken(address beneficiary, uint256 amount) public onlyMinter() returns (bool) {
        require(!hasClosed());
        mintBountyToken(beneficiary, amount);
        emit LogBountyTokenMinted(msg.sender, beneficiary, amount);
        return true;
    }

    function createBountyTokenToMany(address[] beneficiaries, uint256[] amount) public onlyMinter() returns (bool) {
        multiBeneficiariesValidation(beneficiaries, amount);
        for(uint i = 0; i < beneficiaries.length; i++){
            mintBountyToken(beneficiaries[i], amount[i]);
        }
        
        emit LogBountyTokenMintedToMany(msg.sender, beneficiaries, amount);
        return true;
    }

    function mintBountyToken(address beneficiary, uint256 amount) internal {
        require(MintableToken(token).totalSupply().add(amount) <= capForSale);
        require(totalMintedBountyTokens.add(amount) <= bountyTokensCap);
        MintableToken(token).mint(beneficiary, amount);
        totalMintedBountyTokens = totalMintedBountyTokens.add(amount);
    }

    function multiBeneficiariesValidation(address[] beneficiaries, uint256[] amount) internal view {
        require(!hasClosed());
        require(beneficiaries.length > 0);
        require(beneficiaries.length == amount.length);
    }

    /**
        @param extentionInDays is a simple number of the days, e.c. 3 => 3 days
     */
    function extendPrivateSaleDuration(uint256 extentionInDays) public onlyOwner returns (bool) {
        require(now <= privateSaleEndDate);
        extentionInDays = extentionInDays.mul(1 days); // convert the days in seconds
        privateSaleEndDate = privateSaleEndDate.add(extentionInDays);
        closingTime = closingTime.add(extentionInDays);
        emit LogPrivateSaleExtended(extentionInDays);
        return true;
    }

    /**
        @param extentionInDays is a simple number of the days, e.c. 3 => 3 days
     */
    function extendMainSaleDuration(uint256 extentionInDays) public onlyOwner returns (bool) {
        require(now > privateSaleEndDate);
        require(!hasClosed());
        require(mainSaleDurationExtentionLimitInDays.sub(extentionInDays) >= 0);

        uint256 extention = extentionInDays.mul(1 days); // convert the days in seconds
        mainSaleDurationExtentionLimitInDays = mainSaleDurationExtentionLimitInDays.sub(extentionInDays); // substract days from the limit
        closingTime = closingTime.add(extention);

        emit LogMainSaleExtended(extentionInDays);
        return true;
    }

    function changeRate(uint _newRate) public onlyOwner returns (bool) {
        require(!hasClosed());
        require(_newRate != 0);
        rate = _newRate;
        emit LogRateChanged(_newRate);
        return true;
    }

    // after finalization will be minted manually reservedForTeamTokens amount
    function finalization() internal {
        MintableToken(token).transferOwnership(owner);
        super.finalization();
    }
}

// File: contracts/Crowdsale/MultipleWhitelistedCrowdsale.sol

pragma solidity ^0.4.24;



/**
 * @title MultipleWhitelistedCrowdsale
 * @dev Crowdsale in which only whitelisted users can contribute.
 */
contract MultipleWhitelistedCrowdsale is Crowdsale, Ownable {

  mapping(address => bool) public whitelist;
  // keeps all addresses who can manage the whitelist
  mapping(address => bool) public whitelistManagers;

  constructor() public {
      whitelistManagers[owner] = true;
  }

  /**
   * @dev Reverts if beneficiary is not whitelisted. Can be used when extending this contract.
   */
  modifier isWhitelisted(address _beneficiary) {
    require(whitelist[_beneficiary]);
    _;
  }

  /**
   * @dev Reverts if msg.sender is not whitelist manager
   */
  modifier onlyWhitelistManager(){
      require(whitelistManagers[msg.sender]);
      _;
  }

  /**
   * @dev Adds single address who can manage the whitelist.
   * @param _manager Address to be added to the whitelistManagers
   */
  function addWhitelistManager(address _manager) public onlyOwner {
      require(_manager != address(0));
      whitelistManagers[_manager] = true;
  }

  /**
  * @param _manager Address to remove from whitelistManagers
   */

  function removeWhitelistManager(address _manager) public onlyOwner {
      whitelistManagers[_manager] = false;
  }

  /**
   * @dev Adds single address to whitelist.
   * @param _beneficiary Address to be added to the whitelist
   */
  function addToWhitelist(address _beneficiary) external onlyWhitelistManager() {
    whitelist[_beneficiary] = true;
  }

  /**
   * @dev Adds list of addresses to whitelist. Not overloaded due to limitations with truffle testing.
   * @param _beneficiaries Addresses to be added to the whitelist
   */
  function addManyToWhitelist(address[] _beneficiaries) external onlyWhitelistManager() {
    for (uint256 i = 0; i < _beneficiaries.length; i++) {
      whitelist[_beneficiaries[i]] = true;
    }
  }

  /**
   * @dev Removes single address from whitelist.
   * @param _beneficiary Address to be removed to the whitelist
   */
  function removeFromWhitelist(address _beneficiary) external onlyWhitelistManager() {
    whitelist[_beneficiary] = false;
  }

  /**
   * @dev Extend parent behavior requiring beneficiary to be in whitelist.
   * @param _beneficiary Token beneficiary
   * @param _weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal isWhitelisted(_beneficiary) {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

}

// File: contracts/Crowdsale/WhitelistedBasicCrowdsale.sol

pragma solidity ^0.4.24;




contract WhitelistedBasicCrowdsale is BasicCrowdsale, MultipleWhitelistedCrowdsale {


    constructor(uint256 _rate, address _wallet, address _token, uint256 _openingTime, uint256 _closingTime)
    BasicCrowdsale(_rate, _wallet, ERC20(_token), _openingTime, _closingTime)
    MultipleWhitelistedCrowdsale()
    public {
    }
}