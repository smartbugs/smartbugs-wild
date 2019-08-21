pragma solidity ^0.4.24;

// File: node_modules\zeppelin-solidity\contracts\math\SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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

// File: node_modules\zeppelin-solidity\contracts\token\ERC20\ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: node_modules\zeppelin-solidity\contracts\token\ERC20\ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: node_modules\zeppelin-solidity\contracts\token\ERC20\SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    require(token.approve(spender, value));
  }
}

// File: node_modules\zeppelin-solidity\contracts\crowdsale\Crowdsale.sol

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
  using SafeERC20 for ERC20;

  // The token being sold
  ERC20 public token;

  // Address where funds are collected
  address public wallet;

  // How many token units a buyer gets per wei.
  // The rate is the conversion between wei and the smallest and indivisible token unit.
  // So, if you are using a rate of 1 with a DetailedERC20 token with 3 decimals called TOK
  // 1 wei will give you 1 unit, or 0.001 TOK.
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
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );

  /**
   * @param _rate Number of token units a buyer gets per wei
   * @param _wallet Address where collected funds will be forwarded to
   * @param _token Address of the token being sold
   */
  constructor(uint256 _rate, address _wallet, ERC20 _token) public {
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
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
  }

  /**
   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _postValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param _beneficiary Address performing the token purchase
   * @param _tokenAmount Number of tokens to be emitted
   */
  function _deliverTokens(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    token.safeTransfer(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _beneficiary Address receiving the tokens
   * @param _tokenAmount Number of tokens to be purchased
   */
  function _processPurchase(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    _deliverTokens(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
   * @param _beneficiary Address receiving the tokens
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _updatePurchasingState(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 _weiAmount)
    internal view returns (uint256)
  {
    return _weiAmount.mul(rate);
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}

// File: node_modules\zeppelin-solidity\contracts\ownership\Ownable.sol

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

// File: node_modules\zeppelin-solidity\contracts\crowdsale\validation\TimedCrowdsale.sol

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
  constructor(uint256 _openingTime, uint256 _closingTime) public {
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
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
    onlyWhileOpen
  {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

}

// File: node_modules\zeppelin-solidity\contracts\crowdsale\distribution\FinalizableCrowdsale.sol

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

// File: node_modules\zeppelin-solidity\contracts\token\ERC20\BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

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

// File: node_modules\zeppelin-solidity\contracts\token\ERC20\StandardToken.sol

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
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: node_modules\zeppelin-solidity\contracts\token\ERC20\MintableToken.sol

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
    hasMintPermission
    canMint
    public
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
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}

// File: node_modules\zeppelin-solidity\contracts\crowdsale\emission\MintedCrowdsale.sol

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
  function _deliverTokens(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    require(MintableToken(token).mint(_beneficiary, _tokenAmount));
  }
}

// File: node_modules\zeppelin-solidity\contracts\token\ERC20\CappedToken.sol

/**
 * @title Capped token
 * @dev Mintable token with a token cap.
 */
contract CappedToken is MintableToken {

  uint256 public cap;

  constructor(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
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
    returns (bool)
  {
    require(totalSupply_.add(_amount) <= cap);

    return super.mint(_to, _amount);
  }

}

// File: node_modules\zeppelin-solidity\contracts\math\Math.sol

/**
 * @title Math
 * @dev Assorted math operations
 */
library Math {
  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}

// File: node_modules\zeppelin-solidity\contracts\payment\Escrow.sol

/**
 * @title Escrow
 * @dev Base escrow contract, holds funds destinated to a payee until they
 * withdraw them. The contract that uses the escrow as its payment method
 * should be its owner, and provide public methods redirecting to the escrow's
 * deposit and withdraw.
 */
contract Escrow is Ownable {
  using SafeMath for uint256;

  event Deposited(address indexed payee, uint256 weiAmount);
  event Withdrawn(address indexed payee, uint256 weiAmount);

  mapping(address => uint256) private deposits;

  function depositsOf(address _payee) public view returns (uint256) {
    return deposits[_payee];
  }

  /**
  * @dev Stores the sent amount as credit to be withdrawn.
  * @param _payee The destination address of the funds.
  */
  function deposit(address _payee) public onlyOwner payable {
    uint256 amount = msg.value;
    deposits[_payee] = deposits[_payee].add(amount);

    emit Deposited(_payee, amount);
  }

  /**
  * @dev Withdraw accumulated balance for a payee.
  * @param _payee The address whose funds will be withdrawn and transferred to.
  */
  function withdraw(address _payee) public onlyOwner {
    uint256 payment = deposits[_payee];
    assert(address(this).balance >= payment);

    deposits[_payee] = 0;

    _payee.transfer(payment);

    emit Withdrawn(_payee, payment);
  }
}

// File: node_modules\zeppelin-solidity\contracts\payment\ConditionalEscrow.sol

/**
 * @title ConditionalEscrow
 * @dev Base abstract escrow to only allow withdrawal if a condition is met.
 */
contract ConditionalEscrow is Escrow {
  /**
  * @dev Returns whether an address is allowed to withdraw their funds. To be
  * implemented by derived contracts.
  * @param _payee The destination address of the funds.
  */
  function withdrawalAllowed(address _payee) public view returns (bool);

  function withdraw(address _payee) public {
    require(withdrawalAllowed(_payee));
    super.withdraw(_payee);
  }
}

// File: node_modules\zeppelin-solidity\contracts\payment\RefundEscrow.sol

/**
 * @title RefundEscrow
 * @dev Escrow that holds funds for a beneficiary, deposited from multiple parties.
 * The contract owner may close the deposit period, and allow for either withdrawal
 * by the beneficiary, or refunds to the depositors.
 */
contract RefundEscrow is Ownable, ConditionalEscrow {
  enum State { Active, Refunding, Closed }

  event Closed();
  event RefundsEnabled();

  State public state;
  address public beneficiary;

  /**
   * @dev Constructor.
   * @param _beneficiary The beneficiary of the deposits.
   */
  constructor(address _beneficiary) public {
    require(_beneficiary != address(0));
    beneficiary = _beneficiary;
    state = State.Active;
  }

  /**
   * @dev Stores funds that may later be refunded.
   * @param _refundee The address funds will be sent to if a refund occurs.
   */
  function deposit(address _refundee) public payable {
    require(state == State.Active);
    super.deposit(_refundee);
  }

  /**
   * @dev Allows for the beneficiary to withdraw their funds, rejecting
   * further deposits.
   */
  function close() public onlyOwner {
    require(state == State.Active);
    state = State.Closed;
    emit Closed();
  }

  /**
   * @dev Allows for refunds to take place, rejecting further deposits.
   */
  function enableRefunds() public onlyOwner {
    require(state == State.Active);
    state = State.Refunding;
    emit RefundsEnabled();
  }

  /**
   * @dev Withdraws the beneficiary's funds.
   */
  function beneficiaryWithdraw() public {
    require(state == State.Closed);
    beneficiary.transfer(address(this).balance);
  }

  /**
   * @dev Returns whether refundees can withdraw their deposits (be refunded).
   */
  function withdrawalAllowed(address _payee) public view returns (bool) {
    return state == State.Refunding;
  }
}

// File: contracts\ClinicAllRefundEscrow.sol

/**
 * @title ClinicAllRefundEscrow
 * @dev Escrow that holds funds for a beneficiary, deposited from multiple parties.
 * The contract owner may close the deposit period, and allow for either withdrawal
 * by the beneficiary, or refunds to the depositors.
 */
contract ClinicAllRefundEscrow is RefundEscrow {
  using Math for uint256;

  struct RefundeeRecord {
    bool isRefunded;
    uint256 index;
  }

  mapping(address => RefundeeRecord) public refundees;
  address[] public refundeesList;

  event Deposited(address indexed payee, uint256 weiAmount);
  event Withdrawn(address indexed payee, uint256 weiAmount);

  mapping(address => uint256) public deposits;
  mapping(address => uint256) public beneficiaryDeposits;

  // Amount of wei deposited by beneficiary
  uint256 public beneficiaryDepositedAmount;

  // Amount of wei deposited by investors to CrowdSale
  uint256 public investorsDepositedToCrowdSaleAmount;

  /**
   * @dev Constructor.
   * @param _beneficiary The beneficiary of the deposits.
   */
  constructor(address _beneficiary)
  RefundEscrow(_beneficiary)
  public {
  }

  function depositsOf(address _payee) public view returns (uint256) {
    return deposits[_payee];
  }

  function beneficiaryDepositsOf(address _payee) public view returns (uint256) {
    return beneficiaryDeposits[_payee];
  }

  /**
   * Internal. Is being user by parent classes, just for keeping the interface.
   * @dev Stores funds that may later be refunded.
   * @param _refundee The address funds will be sent to if a refund occurs.
   */
  function deposit(address _refundee) public payable {
    uint256 amount = msg.value;
    beneficiaryDeposits[_refundee] = beneficiaryDeposits[_refundee].add(amount);
    beneficiaryDepositedAmount = beneficiaryDepositedAmount.add(amount);
  }

  /**
 * @dev Stores funds that may later be refunded.
 * @param _refundee The address funds will be sent to if a refund occurs.
 * @param _value The amount of funds will be sent to if a refund occurs.
 */
  function depositFunds(address _refundee, uint256 _value) public onlyOwner {
    require(state == State.Active, "Funds deposition is possible only in the Active state.");

    uint256 amount = _value;
    deposits[_refundee] = deposits[_refundee].add(amount);
    investorsDepositedToCrowdSaleAmount = investorsDepositedToCrowdSaleAmount.add(amount);

    emit Deposited(_refundee, amount);

    RefundeeRecord storage _data = refundees[_refundee];
    _data.isRefunded = false;

    if (_data.index == uint256(0)) {
      refundeesList.push(_refundee);
      _data.index = refundeesList.length.sub(1);
    }
  }

  /**
  * @dev Allows for the beneficiary to withdraw their funds, rejecting
  * further deposits.
  */
  function close() public onlyOwner {
    super.close();
  }

  function withdraw(address _payee) public onlyOwner {
    require(state == State.Refunding, "Funds withdrawal is possible only in the Refunding state.");
    require(depositsOf(_payee) > 0, "An investor should have non-negative deposit for withdrawal.");

    RefundeeRecord storage _data = refundees[_payee];
    require(_data.isRefunded == false, "An investor should not be refunded.");

    uint256 payment = deposits[_payee];
    assert(address(this).balance >= payment);

    deposits[_payee] = 0;

    investorsDepositedToCrowdSaleAmount = investorsDepositedToCrowdSaleAmount.sub(payment);

    _payee.transfer(payment);

    emit Withdrawn(_payee, payment);

    _data.isRefunded = true;

    removeRefundeeByIndex(_data.index);
  }

  /**
  @dev Owner can do manual refund here if investore has "BAD" money
  @param _payee address of investor that needs to refund with next manual ETH sending
  */
  function manualRefund(address _payee) public onlyOwner {
    uint256 payment = deposits[_payee];
    RefundeeRecord storage _data = refundees[_payee];

    investorsDepositedToCrowdSaleAmount = investorsDepositedToCrowdSaleAmount.sub(payment);
    deposits[_payee] = 0;
    _data.isRefunded = true;

    removeRefundeeByIndex(_data.index);
  }

  /**
  * @dev Remove refundee referenced index from the internal list
  * @param _indexToDelete An index in an array for deletion
  */
  function removeRefundeeByIndex(uint256 _indexToDelete) private {
    if ((refundeesList.length > 0) && (_indexToDelete < refundeesList.length)) {
      uint256 _lastIndex = refundeesList.length.sub(1);
      refundeesList[_indexToDelete] = refundeesList[_lastIndex];
      refundeesList.length--;
    }
  }
  /**
  * @dev Get refundee list length
  */
  function refundeesListLength() public onlyOwner view returns (uint256) {
    return refundeesList.length;
  }

  /**
  * @dev Auto refund
  * @param _txFee The cost of executing refund code
  */
  function withdrawChunk(uint256 _txFee, uint256 _chunkLength) public onlyOwner returns (uint256, address[]) {
    require(state == State.Refunding, "Funds withdrawal is possible only in the Refunding state.");

    uint256 _refundeesCount = refundeesList.length;
    require(_chunkLength >= _refundeesCount);
    require(_txFee > 0, "Transaction fee should be above zero.");
    require(_refundeesCount > 0, "List of investors should not be empty.");
    uint256 _weiRefunded = 0;
    require(address(this).balance > (_chunkLength.mul(_txFee)), "Account's ballance should allow to pay all tx fees.");
    address[] memory _refundeesListCopy = new address[](_chunkLength);

    uint256 i;
    for (i = 0; i < _chunkLength; i++) {
      address _refundee = refundeesList[i];
      RefundeeRecord storage _data = refundees[_refundee];
      if (_data.isRefunded == false) {
        if (depositsOf(_refundee) > _txFee) {
          uint256 _deposit = depositsOf(_refundee);
          if (_deposit > _txFee) {
            _weiRefunded = _weiRefunded.add(_deposit);
            uint256 _paymentWithoutTxFee = _deposit.sub(_txFee);
            _refundee.transfer(_paymentWithoutTxFee);
            emit Withdrawn(_refundee, _paymentWithoutTxFee);
            _data.isRefunded = true;
            _refundeesListCopy[i] = _refundee;
          }
        }
      }
    }

    for (i = 0; i < _chunkLength; i++) {
      if (address(0) != _refundeesListCopy[i]) {
        RefundeeRecord storage _dataCleanup = refundees[_refundeesListCopy[i]];
        require(_dataCleanup.isRefunded == true, "Investors in this list should be refunded.");
        removeRefundeeByIndex(_dataCleanup.index);
      }
    }

    return (_weiRefunded, _refundeesListCopy);
  }

  /**
  * @dev Auto refund
  * @param _txFee The cost of executing refund code
  */
  function withdrawEverything(uint256 _txFee) public onlyOwner returns (uint256, address[]) {
    require(state == State.Refunding, "Funds withdrawal is possible only in the Refunding state.");
    return withdrawChunk(_txFee, refundeesList.length);
  }

  /**
  * @dev Withdraws all beneficiary's funds.
  */
  function beneficiaryWithdraw() public {
    //This methods is intentionally is overriden here to prevent uncontrollable funds transferring to a beneficiary. Only owner should be able to do this
    //require(state == State.Closed);
    //beneficiary.transfer(address(this).balance);
  }

  /**
  * @dev Withdraws the part of beneficiary's funds.
  */
  function beneficiaryWithdrawChunk(uint256 _value) public onlyOwner {
    require(_value <= address(this).balance, "Withdraw part can not be more than current balance");
    beneficiaryDepositedAmount = beneficiaryDepositedAmount.sub(_value);
    beneficiary.transfer(_value);
  }

  /**
  * @dev Withdraws all beneficiary's funds.
  */
  function beneficiaryWithdrawAll() public onlyOwner {
    uint256 _value = address(this).balance;
    beneficiaryDepositedAmount = beneficiaryDepositedAmount.sub(_value);
    beneficiary.transfer(_value);
  }

}

// File: node_modules\zeppelin-solidity\contracts\lifecycle\TokenDestructible.sol

/**
 * @title TokenDestructible:
 * @author Remco Bloemen <remco@2о─.com>
 * @dev Base contract that can be destroyed by owner. All funds in contract including
 * listed tokens will be sent to the owner.
 */
contract TokenDestructible is Ownable {

  constructor() public payable { }

  /**
   * @notice Terminate contract and refund to owner
   * @param tokens List of addresses of ERC20 or ERC20Basic token contracts to
   refund.
   * @notice The called token contracts could try to re-enter this contract. Only
   supply token contracts you trust.
   */
  function destroy(address[] tokens) onlyOwner public {

    // Transfer tokens to owner
    for (uint256 i = 0; i < tokens.length; i++) {
      ERC20Basic token = ERC20Basic(tokens[i]);
      uint256 balance = token.balanceOf(this);
      token.transfer(owner, balance);
    }

    // Transfer Eth to owner and terminate contract
    selfdestruct(owner);
  }
}

// File: node_modules\zeppelin-solidity\contracts\token\ERC20\BurnableToken.sol

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

// File: node_modules\zeppelin-solidity\contracts\token\ERC20\DetailedERC20.sol

/**
 * @title DetailedERC20 token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  constructor(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}

// File: node_modules\zeppelin-solidity\contracts\lifecycle\Pausable.sol

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
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

// File: node_modules\zeppelin-solidity\contracts\token\ERC20\PausableToken.sol

/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is StandardToken, Pausable {

  function transfer(
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(_to, _value);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(
    address _spender,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(_spender, _value);
  }

  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

// File: contracts\TransferableToken.sol

/**
 * @title TransferableToken
 * @dev Base contract which allows to implement transfer for token.
 */
contract TransferableToken is Ownable {
  event TransferOn();
  event TransferOff();

  bool public transferable = false;

  /**
   * @dev Modifier to make a function callable only when the contract is not transferable.
   */
  modifier whenNotTransferable() {
    require(!transferable);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is transferable.
   */
  modifier whenTransferable() {
    require(transferable);
    _;
  }

  /**
   * @dev called by the owner to enable transfers
   */
  function transferOn() onlyOwner whenNotTransferable public {
    transferable = true;
    emit TransferOn();
  }

  /**
   * @dev called by the owner to disable transfers
   */
  function transferOff() onlyOwner whenTransferable public {
    transferable = false;
    emit TransferOff();
  }

}

// File: contracts\ClinicAllToken.sol

//PausableToken, TokenDestructible
contract ClinicAllToken is MintableToken, DetailedERC20, CappedToken, BurnableToken, TransferableToken {
  constructor
  (
    string _name,
    string _symbol,
    uint8 _decimals,
    uint256 _cap
  )
  DetailedERC20(_name, _symbol, _decimals)
  CappedToken(_cap)
  public
  {

  }

  /*/
  *  Refund event when ICO didn't pass soft cap and we refund ETH to investors + burn ERC-20 tokens from investors balances
  /*/
  function burnAfterRefund(address _who) public onlyOwner {
    uint256 _value = balances[_who];
    _burn(_who, _value);
  }

  /*/
  *  Allow transfers only if token is transferable
  /*/
  function transfer(
    address _to,
    uint256 _value
  )
  public
  whenTransferable
  returns (bool)
  {
    return super.transfer(_to, _value);
  }

  /*/
  *  Allow transfers only if token is transferable
  /*/
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
  public
  whenTransferable
  returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }

  function transferToPrivateInvestor(
    address _from,
    address _to,
    uint256 _value
  )
  public
  onlyOwner
  returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function burnPrivateSale(address privateSaleWallet, uint256 _value) public onlyOwner {
    _burn(privateSaleWallet, _value);
  }

}

// File: node_modules\zeppelin-solidity\contracts\ownership\rbac\Roles.sol

/**
 * @title Roles
 * @author Francisco Giordano (@frangio)
 * @dev Library for managing addresses assigned to a Role.
 * See RBAC.sol for example usage.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an address access to this role
   */
  function add(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = true;
  }

  /**
   * @dev remove an address' access to this role
   */
  function remove(Role storage role, address addr)
    internal
  {
    role.bearer[addr] = false;
  }

  /**
   * @dev check if an address has this role
   * // reverts
   */
  function check(Role storage role, address addr)
    view
    internal
  {
    require(has(role, addr));
  }

  /**
   * @dev check if an address has this role
   * @return bool
   */
  function has(Role storage role, address addr)
    view
    internal
    returns (bool)
  {
    return role.bearer[addr];
  }
}

// File: node_modules\zeppelin-solidity\contracts\ownership\rbac\RBAC.sol

/**
 * @title RBAC (Role-Based Access Control)
 * @author Matt Condon (@Shrugs)
 * @dev Stores and provides setters and getters for roles and addresses.
 * Supports unlimited numbers of roles and addresses.
 * See //contracts/mocks/RBACMock.sol for an example of usage.
 * This RBAC method uses strings to key roles. It may be beneficial
 * for you to write your own implementation of this interface using Enums or similar.
 * It's also recommended that you define constants in the contract, like ROLE_ADMIN below,
 * to avoid typos.
 */
contract RBAC {
  using Roles for Roles.Role;

  mapping (string => Roles.Role) private roles;

  event RoleAdded(address indexed operator, string role);
  event RoleRemoved(address indexed operator, string role);

  /**
   * @dev reverts if addr does not have role
   * @param _operator address
   * @param _role the name of the role
   * // reverts
   */
  function checkRole(address _operator, string _role)
    view
    public
  {
    roles[_role].check(_operator);
  }

  /**
   * @dev determine if addr has role
   * @param _operator address
   * @param _role the name of the role
   * @return bool
   */
  function hasRole(address _operator, string _role)
    view
    public
    returns (bool)
  {
    return roles[_role].has(_operator);
  }

  /**
   * @dev add a role to an address
   * @param _operator address
   * @param _role the name of the role
   */
  function addRole(address _operator, string _role)
    internal
  {
    roles[_role].add(_operator);
    emit RoleAdded(_operator, _role);
  }

  /**
   * @dev remove a role from an address
   * @param _operator address
   * @param _role the name of the role
   */
  function removeRole(address _operator, string _role)
    internal
  {
    roles[_role].remove(_operator);
    emit RoleRemoved(_operator, _role);
  }

  /**
   * @dev modifier to scope access to a single role (uses msg.sender as addr)
   * @param _role the name of the role
   * // reverts
   */
  modifier onlyRole(string _role)
  {
    checkRole(msg.sender, _role);
    _;
  }

  /**
   * @dev modifier to scope access to a set of roles (uses msg.sender as addr)
   * @param _roles the names of the roles to scope access to
   * // reverts
   *
   * @TODO - when solidity supports dynamic arrays as arguments to modifiers, provide this
   *  see: https://github.com/ethereum/solidity/issues/2467
   */
  // modifier onlyRoles(string[] _roles) {
  //     bool hasAnyRole = false;
  //     for (uint8 i = 0; i < _roles.length; i++) {
  //         if (hasRole(msg.sender, _roles[i])) {
  //             hasAnyRole = true;
  //             break;
  //         }
  //     }

  //     require(hasAnyRole);

  //     _;
  // }
}

// File: contracts\Managed.sol

/**
 * @title Managed
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * This simplifies the implementation of "user permissions".
 */
contract Managed is Ownable, RBAC {
  string public constant ROLE_MANAGER = "manager";

  /**
  * @dev Throws if operator is not whitelisted.
  */
  modifier onlyManager() {
    checkRole(msg.sender, ROLE_MANAGER);
    _;
  }

  /**
  * @dev set an address as a manager
  * @param _operator address
  * @return true if the address was added to the whitelist, false if the address was already in the whitelist
  */
  function setManager(address _operator) public onlyOwner {
    addRole(_operator, ROLE_MANAGER);
  }

  /**
  * @dev delete an address as a manager
  * @param _operator address
  * @return true if the address was deleted from the whitelist, false if the address wasn't already in the whitelist
  */
  function removeManager(address _operator) public onlyOwner {
    removeRole(_operator, ROLE_MANAGER);
  }
}

// File: contracts\Limited.sol

/**
 * @title LimitedCrowdsale
 * @dev Crowdsale in which only limited number of tokens can be bought.
 */
contract Limited is Managed {
  using SafeMath for uint256;
  mapping(address => uint256) public limitsList;

  /**
  * @dev Reverts if beneficiary has no limit. Can be used when extending this contract.
  */
  modifier isLimited(address _payee) {
    require(limitsList[_payee] > 0, "An investor is limited if it has a limit.");
    _;
  }


  /**
  * @dev Reverts if beneficiary want to buy more tokens than limit allows. Can be used when extending this contract.
  */
  modifier doesNotExceedLimit(address _payee, uint256 _tokenAmount, uint256 _tokenBalance, uint256 kycLimitThreshold) {
    uint256 _newBalance = _tokenBalance.add(_tokenAmount);
    uint256 _payeeLimit = getLimit(_payee);
    if (_newBalance >= kycLimitThreshold/* && _payeeLimit >= kycLimitThreshold*/) {
        //It does not make sense to validate limit if its lower than the threshold; otherwhise, a payee will hit the lower limit in attempt of buying more than kycThreshold
        require(_newBalance <= _payeeLimit, "An investor should not exceed its limit on buying.");
    }
    _;
  }

  /**
  * @dev Returns limits for _payee.
  * @param _payee Address to get token limits
  */
  function getLimit(address _payee)
  public view returns (uint256)
  {
    return limitsList[_payee];
  }

  /**
  * @dev Adds limits to addresses.
  * @param _payees Addresses to set limit
  * @param _limits Limit values to set to addresses
  */
  function addAddressesLimits(address[] _payees, uint256[] _limits) public
  onlyManager
  {
    require(_payees.length == _limits.length, "Array sizes should be equal.");
    for (uint256 i = 0; i < _payees.length; i++) {
      addLimit(_payees[i], _limits[i]);
    }
  }


  /**
  * @dev Adds limit to address.
  * @param _payee Address to set limit
  * @param _limit Limit value to set to address
  */
  function addLimit(address _payee, uint256 _limit) public
  onlyManager
  {
    limitsList[_payee] = _limit;
  }


  /**
  * @dev Removes single address-limit record.
  * @param _payee Address to be removed
  */
  function removeLimit(address _payee) external
  onlyManager
  {
    limitsList[_payee] = 0;
  }

}

// File: node_modules\zeppelin-solidity\contracts\access\Whitelist.sol

/**
 * @title Whitelist
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * This simplifies the implementation of "user permissions".
 */
contract Whitelist is Ownable, RBAC {
  string public constant ROLE_WHITELISTED = "whitelist";

  /**
   * @dev Throws if operator is not whitelisted.
   * @param _operator address
   */
  modifier onlyIfWhitelisted(address _operator) {
    checkRole(_operator, ROLE_WHITELISTED);
    _;
  }

  /**
   * @dev add an address to the whitelist
   * @param _operator address
   * @return true if the address was added to the whitelist, false if the address was already in the whitelist
   */
  function addAddressToWhitelist(address _operator)
    onlyOwner
    public
  {
    addRole(_operator, ROLE_WHITELISTED);
  }

  /**
   * @dev getter to determine if address is in whitelist
   */
  function whitelist(address _operator)
    public
    view
    returns (bool)
  {
    return hasRole(_operator, ROLE_WHITELISTED);
  }

  /**
   * @dev add addresses to the whitelist
   * @param _operators addresses
   * @return true if at least one address was added to the whitelist,
   * false if all addresses were already in the whitelist
   */
  function addAddressesToWhitelist(address[] _operators)
    onlyOwner
    public
  {
    for (uint256 i = 0; i < _operators.length; i++) {
      addAddressToWhitelist(_operators[i]);
    }
  }

  /**
   * @dev remove an address from the whitelist
   * @param _operator address
   * @return true if the address was removed from the whitelist,
   * false if the address wasn't in the whitelist in the first place
   */
  function removeAddressFromWhitelist(address _operator)
    onlyOwner
    public
  {
    removeRole(_operator, ROLE_WHITELISTED);
  }

  /**
   * @dev remove addresses from the whitelist
   * @param _operators addresses
   * @return true if at least one address was removed from the whitelist,
   * false if all addresses weren't in the whitelist in the first place
   */
  function removeAddressesFromWhitelist(address[] _operators)
    onlyOwner
    public
  {
    for (uint256 i = 0; i < _operators.length; i++) {
      removeAddressFromWhitelist(_operators[i]);
    }
  }

}

// File: contracts\ManagedWhitelist.sol

/**
 * @title ManagedWhitelist
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * This simplifies the implementation of "user permissions".
 */
contract ManagedWhitelist is Managed, Whitelist {
  /**
  * @dev add an address to the whitelist
  * @param _operator address
  * @return true if the address was added to the whitelist, false if the address was already in the whitelist
  */
  function addAddressToWhitelist(address _operator) public onlyManager {
    addRole(_operator, ROLE_WHITELISTED);
  }

  /**
  * @dev add addresses to the whitelist
  * @param _operators addresses
  * @return true if at least one address was added to the whitelist,
  * false if all addresses were already in the whitelist
  */
  function addAddressesToWhitelist(address[] _operators) public onlyManager {
    for (uint256 i = 0; i < _operators.length; i++) {
      addAddressToWhitelist(_operators[i]);
    }
  }

  /**
  * @dev remove an address from the whitelist
  * @param _operator address
  * @return true if the address was removed from the whitelist,
  * false if the address wasn't in the whitelist in the first place
  */
  function removeAddressFromWhitelist(address _operator) public onlyManager {
    removeRole(_operator, ROLE_WHITELISTED);
  }

  /**
  * @dev remove addresses from the whitelist
  * @param _operators addresses
  * @return true if at least one address was removed from the whitelist,
  * false if all addresses weren't in the whitelist in the first place
  */
  function removeAddressesFromWhitelist(address[] _operators) public onlyManager {
    for (uint256 i = 0; i < _operators.length; i++) {
      removeAddressFromWhitelist(_operators[i]);
    }
  }
}

// File: contracts\MigratedTimedFinalizableCrowdsale.sol

/**
 * @title MigratedTimedCrowdsale
 * @dev Crowdsale accepting contributions only within a time frame.
 */
contract MigratedTimedFinalizableCrowdsale is Crowdsale, Ownable {
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
  constructor(uint256 _openingTime, uint256 _closingTime) public {
    // solium-disable-next-line security/no-block-members
    //require(_closingTime >= block.timestamp);
    //require(_closingTime >= _openingTime);

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
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
    onlyWhileOpen
  {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }
}

// File: contracts\PrivatelyManaged.sol

/**
 * @title Managed
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * This simplifies the implementation of "user permissions".
 */
contract PrivatelyManaged is Ownable, RBAC {
  string public constant ROLE_PRIVATEMANAGER = "private_manager";

  /**
  * @dev Throws if operator is not whitelisted.
  */
  modifier onlyPrivateManager() {
    checkRole(msg.sender, ROLE_PRIVATEMANAGER);
    _;
  }

  /**
  * @dev set an address as a private sale manager
  * @param _operator address
  * @return true if the address was added to the whitelist, false if the address was already in the whitelist
  */
  function setPrivateManager(address _operator) public onlyOwner {
    addRole(_operator, ROLE_PRIVATEMANAGER);
  }

  /**
  * @dev delete an address as a private sale manager
  * @param _operator address
  * @return true if the address was deleted from the whitelist, false if the address wasn't already in the whitelist
  */
  function removePrivateManager(address _operator) public onlyOwner {
    removeRole(_operator, ROLE_PRIVATEMANAGER);
  }
}

// File: contracts\ClinicAllCrowdsale.sol

//import "./../node_modules/zeppelin-solidity/contracts/crowdsale/validation/TimedCrowdsale.sol";














/// @title ClinicAll crowdsale contract
/// @dev  ClinicAll crowdsale contract
//contract ClinicAllCrowdsale is Crowdsale, TimedCrowdsale, FinalizableCrowdsale, MintedCrowdsale, ManagedWhitelist, Limited {
contract ClinicAllCrowdsale is Crowdsale, MigratedTimedFinalizableCrowdsale, MintedCrowdsale, ManagedWhitelist, Limited {
  constructor
  (
    uint256 _tokenLimitSupply,
    uint256 _rate,
    address _wallet,
    address _privateSaleManagerWallet,
    ERC20 _token,
    uint256 _openingTime,
    uint256 _closingTime,
    uint256 _discountTokenAmount,
    uint256 _discountTokenPercent,
    uint256 _preSaleClosingTime,
    uint256 _softCapLimit,
    ClinicAllRefundEscrow _vault,
    uint256 _buyLimitSupplyMin,
    uint256 _buyLimitSupplyMax,
    uint256 _kycLimitThreshold
  )
  Crowdsale(_rate, _wallet, _token)
  //TimedCrowdsale(_openingTime, _closingTime)
  MigratedTimedFinalizableCrowdsale(_openingTime, _closingTime)
  public
  {
    privateSaleManagerWallet = _privateSaleManagerWallet;
    tokenSupplyLimit = _tokenLimitSupply;
    discountTokenAmount = _discountTokenAmount;
    discountTokenPercent = _discountTokenPercent;
    preSaleClosingTime = _preSaleClosingTime;
    softCapLimit = _softCapLimit;
    vault = _vault;
    buyLimitSupplyMin = _buyLimitSupplyMin;
    buyLimitSupplyMax = _buyLimitSupplyMax;
    kycLimitThreshold = _kycLimitThreshold;
  }

  using SafeMath for uint256;

  // refund vault used to hold funds while crowdsale is running
  ClinicAllRefundEscrow public vault;

  /*/
  *  Properties, constants
  /*/
  //address public walletPrivateSaler;
  // Limit of tokens for supply during ICO public sale
  uint256 public tokenSupplyLimit;
  // Limit of tokens with discount on current contract
  uint256 public discountTokenAmount;
  // Percent value for discount tokens
  uint256 public discountTokenPercent;
  // Time when we finish pre sale
  uint256 public preSaleClosingTime;
  // Minimum amount of funds to be raised in weis
  uint256 public softCapLimit;
  // Min buy limit for each investor
  uint256 public buyLimitSupplyMin;
  // Max buy limit for each investor
  uint256 public buyLimitSupplyMax;
  // KYC Limit threshold for small and big investors
  uint256 public kycLimitThreshold;
  // Address where private sale funds are collected
  address public privateSaleManagerWallet;
  // Private sale tokens supply limit
  uint256 public privateSaleSupplyLimit;

  // Modifiers
  /**
  * @dev Throws if operator is not whitelisted.
  */
  modifier onlyPrivateSaleManager() {
    require(privateSaleManagerWallet == msg.sender, "Operation is allowed only for the private sale manager.");
    _;
  }


  // Public functions

  /*/
  *  @dev Owner can transfer ownership of the token to a new owner
  *  @param _newTokenOwner  New token owner address
  */
  function transferTokenOwnership(address _newTokenOwner) public
  onlyOwner
  {
      MintableToken(token).transferOwnership(_newTokenOwner);
  }

  /*/
  *  @dev Owner can transfer ownership of the vault to a new owner
  *  @param _newTokenOwner  New token owner address
  */
  function transferVaultOwnership(address _newVaultOwner) public
  onlyOwner
  {
      ClinicAllRefundEscrow(vault).transferOwnership(_newVaultOwner);
  }

  /*/
  *  @dev Owner can extend ICO closing time
  *  @param _closingTime New ICO closing time
  */
  function extendICO(uint256 _closingTime) public
  onlyOwner
  {
      closingTime = _closingTime;
  }

  /*/
  *  @dev Owner can extend ICO closing time
  *  @param _closingTime New ICO closing time
  */
  function extendPreSale(uint256 _preSaleClosingTime) public
  onlyOwner
  {
      preSaleClosingTime = _preSaleClosingTime;
  }

  /*/
  *  @dev Should be used only once during the migration of ICO contracts
  *  @param _beneficiary Wallet address of migrated beneficiary
  *  @param _weiAmount Sum of invested ETH funds in wei
  *  @param _tokenAmount Sum of bought tokens for this ETH funds
  */
  function migrateBeneficiary(address _beneficiary, uint256 _weiAmount, uint256 _tokenAmount) public
  onlyOwner
  {
    weiRaised = weiRaised.add(_weiAmount);
    //That is crucial that _forwardFunds() will not be called here
    _processPurchase(_beneficiary, _tokenAmount);
    emit TokenPurchase(
      msg.sender,
      _beneficiary,
      _weiAmount,
      _tokenAmount
    );
  }

  /*/
  *  @dev CrowdSale manager is able to change rate value during ICO
  *  @param _rate wei to CHT tokens exchange rate
  */
  function updateRate(uint256 _rate) public
  onlyManager
  {
    require(_rate != 0, "Exchange rate should not be 0.");
    rate = _rate;
  }

  /*/
  *  @dev CrowdSale manager is able to change min and max buy limit for investors during ICO
  *  @param _min Minimal amount of tokens that could be bought
  *  @param _max Maximum amount of tokens that could be bought
  */
  function updateBuyLimitRange(uint256 _min, uint256 _max) public
  onlyOwner
  {
    require(_min != 0, "Minimal buy limit should not be 0.");
    require(_max != 0, "Maximal buy limit should not be 0.");
    require(_max > _min, "Maximal buy limit should be greater than minimal buy limit.");
    buyLimitSupplyMin = _min;
    buyLimitSupplyMax = _max;
  }

  /*/
  *  @dev CrowdSale manager is able to change Kyc Limit Eliminator for investors during ICO
  *  @param _value amount of tokens that should be as eliminator
  */
  function updateKycLimitThreshold(uint256 _value) public
  onlyOwner
  {
    require(_value != 0, "Kyc threshold should not be 0.");
    kycLimitThreshold = _value;
  }

  /**
  * @dev Investors can claim refunds here if crowdsale is unsuccessful
  */
  function claimRefund() public {
    require(isFinalized, "Claim refunds is only possible if the ICO is finalized.");
    require(!goalReached(), "Claim refunds is only possible if the soft cap goal has not been reached.");
    uint256 deposit = vault.depositsOf(msg.sender);
    vault.withdraw(msg.sender);
    weiRaised = weiRaised.sub(deposit);
    ClinicAllToken(token).burnAfterRefund(msg.sender);
  }

  /**
  @dev Owner can claim full refund if a crowdsale is unsuccessful
  @param _txFee Transaction fee that will be deducted from an invested sum
  */
  function claimRefundChunk(uint256 _txFee, uint256 _chunkLength) public onlyOwner {
    require(isFinalized, "Claim refunds is only possible if the ICO is finalized.");
    require(!goalReached(), "Claim refunds is only possible if the soft cap goal has not been reached.");
    uint256 _weiRefunded;
    address[] memory _refundeesList;
    (_weiRefunded, _refundeesList) = vault.withdrawChunk(_txFee, _chunkLength);
    weiRaised = weiRaised.sub(_weiRefunded);
    for (uint256 i = 0; i < _refundeesList.length; i++) {
      ClinicAllToken(token).burnAfterRefund(_refundeesList[i]);
    }
  }

  /**
  * @dev Get refundee list length
  */
  function refundeesListLength() public onlyOwner view returns (uint256) {
    return vault.refundeesListLength();
  }

  /**
  * @dev Checks whether the period in which the crowdsale is open has already elapsed.
  * @return Whether crowdsale period has elapsed
  */
  function hasClosed() public view returns (bool) {
    return ((block.timestamp > closingTime) || tokenSupplyLimit <= token.totalSupply());
  }

  /**
  * @dev Checks whether funding goal was reached.
  * @return Whether funding goal was reached
  */
  function goalReached() public view returns (bool) {
    return token.totalSupply() >= softCapLimit;
  }

  /**
  * @dev Checks rest of tokens supply.
  */
  function supplyRest() public view returns (uint256) {
    return (tokenSupplyLimit.sub(token.totalSupply()));
  }

  //Private functions

  function _processPurchase(
    address _beneficiary,
    uint256 _tokenAmount
  )
  internal
  doesNotExceedLimit(_beneficiary, _tokenAmount, token.balanceOf(_beneficiary), kycLimitThreshold)
  {
    super._processPurchase(_beneficiary, _tokenAmount);
  }

  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
  internal
  onlyIfWhitelisted(_beneficiary)
  isLimited(_beneficiary)
  {
    super._preValidatePurchase(_beneficiary, _weiAmount);
    uint256 tokens = _getTokenAmount(_weiAmount);
    require(tokens.add(token.totalSupply()) <= tokenSupplyLimit, "Total amount fo sold tokens should not exceed the total supply limit.");
    require(tokens >= buyLimitSupplyMin, "An investor can buy an amount of tokens only above the minimal limit.");
    require(tokens.add(token.balanceOf(_beneficiary)) <= buyLimitSupplyMax, "An investor cannot buy tokens above the maximal limit.");
  }

  /**
   * @dev Te way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount with discount or not
   */
  function _getTokenAmount(uint256 _weiAmount)
  internal view returns (uint256)
  {
    if (isDiscount()) {
      return _getTokensWithDiscount(_weiAmount);
    }
    return _weiAmount.mul(rate);
  }

  /**
   * @dev Public method where ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   */
  function getTokenAmount(uint256 _weiAmount)
  public view returns (uint256)
  {
    return _getTokenAmount(_weiAmount);
  }

  /**
   * @dev iternal method returns total tokens amount including discount
   */
  function _getTokensWithDiscount(uint256 _weiAmount)
  internal view returns (uint256)
  {
    uint256 tokens = 0;
    uint256 restOfDiscountTokens = discountTokenAmount.sub(token.totalSupply());
    uint256 discountTokensMax = _getDiscountTokenAmount(_weiAmount);
    if (restOfDiscountTokens < discountTokensMax) {
      uint256 discountTokens = restOfDiscountTokens;
      //get rest of WEI
      uint256 _rate = _getDiscountRate();
      uint256 _discointWeiAmount = discountTokens.div(_rate);
      uint256 _restOfWeiAmount = _weiAmount.sub(_discointWeiAmount);
      uint256 normalTokens = _restOfWeiAmount.mul(rate);
      tokens = discountTokens.add(normalTokens);
    } else {
      tokens = discountTokensMax;
    }

    return tokens;
  }

  /**
   * @dev iternal method returns discount tokens amount
   * @param _weiAmount An amount of ETH that should be converted to an amount of CHT tokens
   */
  function _getDiscountTokenAmount(uint256 _weiAmount)
  internal view returns (uint256)
  {
    require(_weiAmount != 0, "It should be possible to buy tokens only by providing non zero ETH.");
    uint256 _rate = _getDiscountRate();
    return _weiAmount.mul(_rate);
  }

  /**
   * @dev Returns the discount rate value
   */
  function _getDiscountRate()
  internal view returns (uint256)
  {
    require(isDiscount(), "Getting discount rate should be possible only below the discount tokens limit.");
    return rate.add(rate.mul(discountTokenPercent).div(100));
  }

  /**
   * @dev Returns the exchange rate value
   */
  function getRate()
  public view returns (uint256)
  {
    if (isDiscount()) {
      return _getDiscountRate();
    }

    return rate;
  }

  /**
   * @dev Returns the status if the ICO's private sale has closed or not
   */
  function isDiscount()
  public view returns (bool)
  {
    return (preSaleClosingTime >= block.timestamp);
  }

  /**
   * @dev Internal method where owner transfers part of tokens to reserve
   */
  function transferTokensToReserve(address _beneficiary) private
  {
    require(tokenSupplyLimit < CappedToken(token).cap(), "Token's supply limit should be less that token' cap limit.");
    // calculate token amount to be created
    uint256 _tokenCap = CappedToken(token).cap();
    uint256 tokens = _tokenCap.sub(tokenSupplyLimit);

    _deliverTokens(_beneficiary, tokens);
  }

  /**
  * @dev Enable transfers of tokens between wallets
  */
  function transferOn() public onlyOwner
  {
    ClinicAllToken(token).transferOn();
  }

  /**
  * @dev Disable transfers of tokens between wallets
  */
  function transferOff() public onlyOwner
  {
    ClinicAllToken(token).transferOff();
  }

  /**
   * @dev Internal method where owner transfers part of tokens to reserve and finish minting
   */
  function finalization() internal {
    if (goalReached()) {
      transferTokensToReserve(wallet);
      vault.close();
    } else {
      vault.enableRefunds();
    }
    MintableToken(token).finishMinting();
    super.finalization();
  }

  /**
  * @dev Overrides Crowdsale fund forwarding, sending funds to vault.
  */
  function _forwardFunds() internal {
    super._forwardFunds();
    vault.depositFunds(msg.sender, msg.value);
  }

  /**
  * @dev Public method where private sale manager can transfer tokens to private investors
  */
  function transferToPrivateInvestor(
    address _beneficiary,
    uint256 _value
  )
  public
  onlyPrivateSaleManager
  onlyIfWhitelisted(_beneficiary)
  returns (bool)
  {
    ClinicAllToken(token).transferToPrivateInvestor(msg.sender, _beneficiary, _value);
  }

  /**
  * @dev Allocates funds for the private sale manager, but not beyound the tokenSupplyLimit
  * @param privateSaleSupplyAmount value of CHT tokens to add for private sale
  */
  function allocatePrivateSaleFunds(uint256 privateSaleSupplyAmount) public onlyOwner
  {
    require(privateSaleSupplyLimit.add(privateSaleSupplyAmount) < tokenSupplyLimit, "Token's private sale supply limit should be less that token supply limit.");
    privateSaleSupplyLimit = privateSaleSupplyLimit.add(privateSaleSupplyAmount);
    _deliverTokens(privateSaleManagerWallet, privateSaleSupplyAmount);
  }

  /**
  * @dev Public method where private sale manager can transfer the rest of tokens form private sale wallet available to crowdsale
  */
  function redeemPrivateSaleFunds()
  public
  onlyPrivateSaleManager
  {
    uint256 _balance = ClinicAllToken(token).balanceOf(msg.sender);
    privateSaleSupplyLimit = privateSaleSupplyLimit.sub(_balance);
    ClinicAllToken(token).burnPrivateSale(msg.sender, _balance);
  }

  /**
  @dev Owner can withdraw part of funds during of ICO
  @param _value Transaction amoun that will be deducted from an vault sum
  */
  function beneficiaryWithdrawChunk(uint256 _value)
  public
  onlyOwner
  {
    vault.beneficiaryWithdrawChunk(_value);
  }

  /**
  @dev Owner can withdraw all funds during or after of ICO
  */
  function beneficiaryWithdrawAll()
  public
  onlyOwner
  {
    vault.beneficiaryWithdrawAll();
  }

  /**
  @dev Owner can do manual refund here if investore has "BAD" money
  @param _payee address of investor that needs to refund with next manual ETH sending
  */
  function manualRefund(address _payee) public onlyOwner {
    uint256 deposit = vault.depositsOf(_payee);
    vault.manualRefund(_payee);
    weiRaised = weiRaised.sub(deposit);
    ClinicAllToken(token).burnAfterRefund(_payee);
  }

}