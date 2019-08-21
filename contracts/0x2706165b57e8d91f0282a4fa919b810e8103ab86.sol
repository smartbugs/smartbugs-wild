pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

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

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(
    ERC20Basic _token,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transfer(_to, _value));
  }

  function safeTransferFrom(
    ERC20 _token,
    address _from,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transferFrom(_from, _to, _value));
  }

  function safeApprove(
    ERC20 _token,
    address _spender,
    uint256 _value
  )
    internal
  {
    require(_token.approve(_spender, _value));
  }
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
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
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
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

  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _amount
  )
    public
    hasMintPermission
    canMint
    returns (bool)
  {
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
  function finishMinting() public onlyOwner canMint returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}


/**
 * @title MintAndBurnToken
 *
 * @dev StandardToken that is mintable and burnable
 */
contract MintAndBurnToken is MintableToken {

  // -----------------------------------
  // BURN FUNCTIONS
  // https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/token/ERC20/BurnableToken.sol
  // -----------------------------------

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who], "must have balance greater than burn value");
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}


/**
 * @title BabyloniaToken
 */
contract BabyloniaToken is MintAndBurnToken {

  // DetailedERC20 variables
  string public name = "Babylonia Token";
  string public symbol = "BBY";
  uint8 public decimals = 18;
}

/**
 * @title EthPriceOracleI
 * @dev Interface for interacting with MakerDAO's on-chain price oracle
 */
contract EthPriceOracleI {
    function compute() public view returns (bytes32, bool);
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
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}

/**
 * @title Babylon
 *
 * @dev This contract manages the exchange of Helbiz tokens for Babylonia tokens, with a locking period
 * in place before tokens can be claimed
 */
contract Babylon is Pausable {
  using SafeMath for uint256;
  using SafeERC20 for BabyloniaToken;

  event TokenExchangeCreated(address indexed recipient, uint amount, uint releasedAt);
  event TokenExchangeReleased(address indexed recipient);

  BabyloniaToken private babyloniaToken;
  StandardToken private helbizToken;
  EthPriceOracleI private ethPriceOracle;

  uint public INITIAL_CIRCULATION_BBY = 80000000; // the amount of BBY tokens available for the token swap
  uint public MIN_EXCHANGE_BBY = SafeMath.mul(1000, 10**18); // minimum amount of BBY tokens for an exchange

  uint public exchangeRate;          // HBZ tokens we receive per BBY
  uint8 public usdCentsExchangeRate; // USD cents we receive per BBY
  uint32 public exchangeLockTime;    // time (seconds) after an exchange before the sender can claim their BBY tokens
  uint public babyloniaTokensLocked; // the amount of BBY tokens locked for exchange
  bool public ethExchangeEnabled;    // whether we are accepting ETH for BBY

  struct TokenExchange {
    address recipient; // the address to receive BBY in exchange for HBZ
    uint amountHBZ;    // amount in HBZ
    uint amountBBY;    // amount in BBY
    uint amountWei;    // amount in Wei
    uint createdAt;    // datetime created
    uint releasedAt;   // datetime when BBY can be redeemed
  }

  mapping(address => uint) private activeTokenExchanges;
  TokenExchange[] private tokenExchanges;

  modifier activeTokenExchange() {
    require(activeTokenExchanges[msg.sender] != 0, "must be an active token exchange");
    _;
  }

  modifier noActiveTokenExchange() {
    require(activeTokenExchanges[msg.sender] == 0, "must not have an active token exchange");
    _;
  }

  modifier whenEthEnabled() {
    require(ethExchangeEnabled);
    _;
  }

  /**
   * Contract constructor
   * Instantiates instance of HelbizCoin (HBZ) and BabyloniaToken (BBY) contracts
   * Sets the cap for the total circulation
   * Mints 50% of the cap for this contract
   * @param _helbizCoinAddress Address of deployed HelbizCoin contract
   * @param _babyloniaTokenAddress Address of deployed BabyloniaToken contract
   * @param _ethPriceOracleAddress Address of deployed EthPriceOracle contract
   * @param _exchangeRate x HBZ => 1 BBY rate
   * @param _exchangeLockTime Number of seconds the exchanged BBY tokens are locked up for
   */
  constructor(
    address _helbizCoinAddress,
    address _babyloniaTokenAddress,
    address _ethPriceOracleAddress,
    uint8 _exchangeRate,
    uint8 _usdCentsExchangeRate,
    uint32 _exchangeLockTime
  ) public {
    helbizToken = StandardToken(_helbizCoinAddress);
    babyloniaToken = BabyloniaToken(_babyloniaTokenAddress);
    ethPriceOracle = EthPriceOracleI(_ethPriceOracleAddress);
    exchangeRate = _exchangeRate;
    usdCentsExchangeRate = _usdCentsExchangeRate;
    exchangeLockTime = _exchangeLockTime;
    paused = true;

    // take care of zero-index for storage array
    tokenExchanges.push(TokenExchange({
      recipient: address(0),
      amountHBZ: 0,
      amountBBY: 0,
      amountWei: 0,
      createdAt: 0,
      releasedAt: 0
    }));
  }

  /**
   * Do not accept ETH
   */
  function() public payable {
    require(msg.value == 0, "not accepting ETH");
  }

  /**
   * Transfers all of this contract's owned HBZ to the given address
   * @param _to The address to transfer this contract's HBZ to
   */
  function withdrawHBZ(address _to) external onlyOwner {
    require(_to != address(0), "invalid _to address");
    require(helbizToken.transfer(_to, helbizToken.balanceOf(address(this))));
  }

  /**
   * Transfers all of this contract's ETH to the given address
   * @param _to The address to transfer all this contract's ETH to
   */
  function withdrawETH(address _to) external onlyOwner {
    require(_to != address(0), "invalid _to address");
    _to.transfer(address(this).balance);
  }

  /**
   * Transfers all of this contract's BBY MINUS locked tokens to the given address
   * @param _to The address to transfer BBY to
   * @param _amountBBY The amount of BBY to transfer
   */
  function withdrawBBY(address _to, uint _amountBBY) external onlyOwner {
    require(_to != address(0), "invalid _to address");
    require(_amountBBY > 0, "_amountBBY must be greater than 0");
    require(babyloniaToken.transfer(_to, _amountBBY));
  }

  /**
   * Burns the remainder of BBY owned by this contract MINUS locked tokens
   */
  function burnRemainderBBY() public onlyOwner {
    uint amountBBY = SafeMath.sub(babyloniaToken.balanceOf(address(this)), babyloniaTokensLocked);
    babyloniaToken.burn(amountBBY);
  }

  /**
   * Sets a new exchange rate
   * @param _newRate 1 BBY => _newRate
   */
  function setExchangeRate(uint8 _newRate) external onlyOwner {
    require(_newRate > 0, "new rate must not be 0");
    exchangeRate = _newRate;
  }

  /**
   * Sets the exchange rate in USD cents (for ETH payments)
   * @param _newRate 1 BBY => _newRate
   */
  function setUSDCentsExchangeRate(uint8 _newRate) external onlyOwner {
    require(_newRate > 0, "new rate must not be 0");
    usdCentsExchangeRate = _newRate;
  }

  /**
   * Sets a new exchange lock time
   * @param _newLockTime Number of seconds the exchanged BBY tokens are locked up for
   */
  function setExchangeLockTime(uint32 _newLockTime) external onlyOwner {
    require(_newLockTime > 0, "new lock time must not be 0");
    exchangeLockTime = _newLockTime;
  }

  /**
   * Sets whether we are accepting ETH for the exchange
   * @param _enabled Is ETH enabled
   */
  function setEthExchangeEnabled(bool _enabled) external onlyOwner {
    ethExchangeEnabled = _enabled;
  }

  /**
   * Return the address of the BabyloniaToken contract
   */
  function getTokenAddress() public view returns(address) {
    return address(babyloniaToken);
  }

  /**
   * Transfers HBZ from the sender equal to _amountHBZ to this contract and creates a record for TokenExchange
   * NOTE: the address must have already approved the transfer with hbzToken.approve()
   * @param _amountHBZ Amount of HBZ tokens
   */
  function exchangeTokens(uint _amountHBZ) public whenNotPaused noActiveTokenExchange {
    // sanity check
    require(_amountHBZ >= MIN_EXCHANGE_BBY, "_amountHBZ must be greater than or equal to MIN_EXCHANGE_BBY");

    // the contract must have enough tokens - considering the locked ones
    uint amountBBY = SafeMath.div(_amountHBZ, exchangeRate);
    uint contractBalanceBBY = babyloniaToken.balanceOf(address(this));
    require(SafeMath.sub(contractBalanceBBY, babyloniaTokensLocked) >= amountBBY, "contract has insufficient BBY");

    // transfer the HBZ tokens to this contract
    require(helbizToken.transferFrom(msg.sender, address(this), _amountHBZ));

    _createExchangeRecord(_amountHBZ, amountBBY, 0);
  }

  /**
   * Accepts ETH in exchange for BBY tokens and creates a record for TokenExchange
   * NOTE: this function can only be called when the contract is paused, preventing sales in ETH during the token swap
   * @param _amountBBY Amount of BBY tokens
   */
  function exchangeEth(uint _amountBBY) public whenNotPaused whenEthEnabled noActiveTokenExchange payable {
    // sanity check
    require(_amountBBY > 0, "_amountBBY must be greater than 0");

    bytes32 val;
    (val,) = ethPriceOracle.compute();
    // divide to get the number of cents in 1 ETH
    uint256 usdCentsPerETH = SafeMath.div(uint256(val), 10**16);

    // calculate the price of BBY in Wei
    uint256 priceInWeiPerBBY = SafeMath.div(10**18, SafeMath.div(usdCentsPerETH, usdCentsExchangeRate));

    // total cost in Wei for _amountBBY
    uint256 totalPriceInWei = SafeMath.mul(priceInWeiPerBBY, _amountBBY);

    // ensure the user sent enough funds and that we have enough BBY
    require(msg.value >= totalPriceInWei, "Insufficient ETH value");
    require(SafeMath.sub(babyloniaToken.balanceOf(address(this)), babyloniaTokensLocked) >= _amountBBY, "contract has insufficient BBY");

    // refund any overpayment
    if (msg.value > totalPriceInWei) msg.sender.transfer(msg.value - totalPriceInWei);

    _createExchangeRecord(0, _amountBBY, totalPriceInWei);
  }

  /**
   * Transfers BBY tokens to the sender
   */
  function claimTokens() public whenNotPaused activeTokenExchange {
    TokenExchange storage tokenExchange = tokenExchanges[activeTokenExchanges[msg.sender]];
    uint amountBBY = tokenExchange.amountBBY;

    // assert that we're past the lock period
    /* solium-disable-next-line security/no-block-members */
    require(block.timestamp >= tokenExchange.releasedAt, "not past locking period");

    // decrease the counter
    babyloniaTokensLocked = SafeMath.sub(babyloniaTokensLocked, tokenExchange.amountBBY);

    // delete from storage and lookup
    delete tokenExchanges[activeTokenExchanges[msg.sender]];
    delete activeTokenExchanges[msg.sender];

    // transfer BBY tokens to the sender
    babyloniaToken.safeTransfer(msg.sender, amountBBY);

    emit TokenExchangeReleased(msg.sender);
  }

  /**
   * Return the id of the owned active token exchange
   */
  function getActiveTokenExchangeId() public view activeTokenExchange returns(uint) {
    return activeTokenExchanges[msg.sender];
  }

  /**
   * Returns a token exchange with the given id
   * @param _id the id of the record to retrieve (optional)
   */
  function getActiveTokenExchangeById(uint _id)
    public
    view
    returns(
      address recipient,
      uint amountHBZ,
      uint amountBBY,
      uint amountWei,
      uint createdAt,
      uint releasedAt
    )
  {
    // sanity check
    require(tokenExchanges[_id].recipient != address(0));

    TokenExchange storage tokenExchange = tokenExchanges[_id];

    recipient = tokenExchange.recipient;
    amountHBZ = tokenExchange.amountHBZ;
    amountBBY = tokenExchange.amountBBY;
    amountWei = tokenExchange.amountWei;
    createdAt = tokenExchange.createdAt;
    releasedAt = tokenExchange.releasedAt;
  }

  /**
   * Returns the number of token exchanges in the storage array
   * NOTE: the length will be inaccurate as we are deleting array elements, leaving gaps
   */
  function getTokenExchangesCount() public view onlyOwner returns(uint) {
    return tokenExchanges.length;
  }

  /**
   * Creates a record for the token exchange
   * @param _amountHBZ The amount of HBZ tokens
   * @param _amountBBY The amount of BBY tokens
   * @param _amountWei The amount of Wei (optional - in place of _amountHBZ)
   */
  function _createExchangeRecord(uint _amountHBZ, uint _amountBBY, uint _amountWei) internal {
    /* solium-disable-next-line security/no-block-members */
    uint releasedAt = SafeMath.add(block.timestamp, exchangeLockTime);
    TokenExchange memory tokenExchange = TokenExchange({
      recipient: msg.sender,
      amountHBZ: _amountHBZ,
      amountBBY: _amountBBY,
      amountWei: _amountWei,
      createdAt: block.timestamp, // solium-disable-line security/no-block-members, whitespace
      releasedAt: releasedAt
    });
    // add to storage and lookup
    activeTokenExchanges[msg.sender] = tokenExchanges.push(tokenExchange) - 1;

    // increase the counter
    babyloniaTokensLocked = SafeMath.add(babyloniaTokensLocked, _amountBBY);

    emit TokenExchangeCreated(msg.sender, _amountHBZ, releasedAt);
  }
}