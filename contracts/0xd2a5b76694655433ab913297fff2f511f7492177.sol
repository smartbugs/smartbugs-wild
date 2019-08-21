pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
  * @dev Transfer token for a specified addresses
  * @param from The address to transfer from.
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param value The amount that will be created.
   */
  function _mint(address account, uint256 value) internal {
    require(account != 0);
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burn(address account, uint256 value) internal {
    require(account != 0);
    require(value <= _balances[account]);

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burnFrom(address account, uint256 value) internal {
    require(value <= _allowed[account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
    _burn(account, value);
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol

/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is IERC20 {
  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(string name, string symbol, uint8 decimals) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

  /**
   * @return the name of the token.
   */
  function name() public view returns(string) {
    return _name;
  }

  /**
   * @return the symbol of the token.
   */
  function symbol() public view returns(string) {
    return _symbol;
  }

  /**
   * @return the number of decimals of the token.
   */
  function decimals() public view returns(uint8) {
    return _decimals;
  }
}

// File: openzeppelin-solidity/contracts/access/Roles.sol

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an account access to this role
   */
  function add(Role storage role, address account) internal {
    require(account != address(0));
    require(!has(role, account));

    role.bearer[account] = true;
  }

  /**
   * @dev remove an account's access to this role
   */
  function remove(Role storage role, address account) internal {
    require(account != address(0));
    require(has(role, account));

    role.bearer[account] = false;
  }

  /**
   * @dev check if an account has this role
   * @return bool
   */
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}

// File: openzeppelin-solidity/contracts/access/roles/MinterRole.sol

contract MinterRole {
  using Roles for Roles.Role;

  event MinterAdded(address indexed account);
  event MinterRemoved(address indexed account);

  Roles.Role private minters;

  constructor() internal {
    _addMinter(msg.sender);
  }

  modifier onlyMinter() {
    require(isMinter(msg.sender));
    _;
  }

  function isMinter(address account) public view returns (bool) {
    return minters.has(account);
  }

  function addMinter(address account) public onlyMinter {
    _addMinter(account);
  }

  function renounceMinter() public {
    _removeMinter(msg.sender);
  }

  function _addMinter(address account) internal {
    minters.add(account);
    emit MinterAdded(account);
  }

  function _removeMinter(address account) internal {
    minters.remove(account);
    emit MinterRemoved(account);
  }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol

/**
 * @title ERC20Mintable
 * @dev ERC20 minting logic
 */
contract ERC20Mintable is ERC20, MinterRole {
  /**
   * @dev Function to mint tokens
   * @param to The address that will receive the minted tokens.
   * @param value The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address to,
    uint256 value
  )
    public
    onlyMinter
    returns (bool)
  {
    _mint(to, value);
    return true;
  }
}

// File: contracts/KDO.sol

contract KDO is Ownable, ERC20Detailed, ERC20Mintable {
  struct Ticket {
    // Type of the ticket
    string tType;

    // Creation date and expiration date
    uint createdAt;
    uint expireAt;

    address contractor;

    // The ticket has published a review
    bool hasReviewed;
  }

  // A contractor is someone that will be credited by tickets (clients)
  struct Contractor {
    // Its reviews
    mapping (uint => uint) reviews;

    // Total of tickets
    uint256 nbCredittedTickets;

    // Total of debitted tokens
    uint256 debittedBalance;
  }

  // Commission regarding the review average, the index is about the rating value
  // the value is the commission in %
  uint8[5] public commissions;

  mapping (address => Ticket) public tickets;

  // A contractor is a person who can consume ticketTypes and be credited for
  mapping (address => Contractor) public contractors;

  event CreditEvt(address ticket, address contractor, string tType, uint256 date);
  event DebitEvt(address contractor, uint256 amount, uint256 commission, uint256 date);
  event ReviewEvt(address reviewer, address contractor, uint rate, uint256 date);
  event CommissionsChangeEvt(uint8[5] commissions, uint256 date);

  mapping (uint256 => string) public ticketTypes;

  // Minimum base value for tickets 150000 Gwei
  uint256 constant public MIN_TICKET_BASE_VALUE = 150000000000000;

  // Min and Max commission in %
  uint256 constant public MIN_COMMISSION = 8;
  uint256 constant public MAX_COMMISSION = 30;

  // Value to transfer to tickets when allocated
  uint256 public ticketBaseValue;

  // .0% of 10e18 (1 = 0.1%, 10 = 1%)
  uint256 public ticketCostBase;

  address private _businessOwner;

  constructor(uint8[5] _commissions, address __businessOwner)
    ERC20Detailed("KDO Coin", "KDO", 0)
    public
  {
    ticketBaseValue = MIN_TICKET_BASE_VALUE;
    ticketCostBase = 3;

    updateCommissions(_commissions);

    _businessOwner = __businessOwner;
  }

  // Only listed tickets
  modifier onlyExistingTicketAmount(uint256 _amount) {
    require(bytes(ticketTypes[_amount]).length > 0, '{error: UNKNOWN_TICKET}');
    _;
  }

  // Update the ticket base cost for following market value in case of crash or
  // pump
  // @param _value new ticket base cost
  function updateTicketCostBase(uint256 _value) public
    onlyOwner()
  {
    require(_value > 0 && _value <= 500, '{error: BAD_VALUE, message: "Should be > 0 and <= 500"}');
    ticketCostBase = _value;
  }

  // Update the ticket base value
  // a ticket value is the amount of ether allowed to the ticket in order to
  // be used
  // @param _value is the base value change, in wei
  function updateTicketBaseValue(uint256 _value) public
    onlyOwner()
  {
    // Cant put a value below the minimal value
    require(_value >= MIN_TICKET_BASE_VALUE, '{error: BAD_VALUE, message: "Value too low"}');
    ticketBaseValue = _value;
  }

  // Update the commissions
  // @param _c are the new commissions
  function updateCommissions(uint8[5] _c) public
    onlyOwner()
  {
    for (uint i = 0; i <= 4; i++) {
        require(_c[i] <= MAX_COMMISSION && _c[i] >= MIN_COMMISSION, '{error: BAD_VALUE, message: "A commission it too low or too high"}');
    }
    commissions = _c;
    emit CommissionsChangeEvt(_c, now);
  }

  // Add a new ticket type
  // Can update an old ticket type, for instance :
  // ticketTypes[99] = "bronze"
  // addTicketType(99, "wood")
  // ticketTypes[99] = "wood"
  // ticket 99 has been updated from "bronze" to "wood"
  // @param _amount is the ticket amount to update
  // @param _key is the key to attribute to the amount
  function addTicketType(uint256 _amount, string _key) public
    onlyOwner()
  {
    ticketTypes[_amount] = _key;
  }

  // Create a ticket using KDO tokens
  // @param _to ticket to create
  // @param _KDOAmount amount to allocate to the ticket
  function allocateNewTicketWithKDO(address _to, uint256 _KDOAmount)
    public
    payable
    onlyExistingTicketAmount(_KDOAmount)
    returns (bool success)
  {
      require(msg.value >= ticketBaseValue, '{error: BAD_VALUE, message: "Value too low"}');

      _to.transfer(ticketBaseValue);

      super.transfer(_to, _KDOAmount);

      _createTicket(_to, _KDOAmount);

      return true;
  }

  // Allocates a ticket to an address and create tokens (accordingly to the value of the allocated ticket)
  // @param _to ticket to create
  // @param _amount amount to allocate to the ticket
  function allocateNewTicket(address _to, uint256 _amount)
    public
    payable
    onlyExistingTicketAmount(_amount)
    returns (bool success)
  {
    uint256 costInWei = costOfTicket(_amount);
    require(msg.value == costInWei, '{error: BAD_VALUE, message: "Value should be equal to the cost of the ticket"}');

    // Give minimal WEI value to a ticket
    _to.transfer(ticketBaseValue);

    // Price of the ticket transfered to the business owner address
    _businessOwner.transfer(costInWei - ticketBaseValue);

    super.mint(_to, _amount);

    _createTicket(_to, _amount);

    return true;
  }

  // Checks if an address can handle the ticket type
  // @param _ticketAddr tocket to check
  function isTicketValid(address _ticketAddr)
    public
    view
    returns (bool valid)
  {
    if (tickets[_ticketAddr].contractor == 0x0 && now < tickets[_ticketAddr].expireAt) {
      return true;
    }
    return false;
  }

  // A ticket credit the contractor balance
  // It triggers Consume event for logs
  // @param _contractor contractor to credit
  // @param _amount amount that will be creditted
  function creditContractor(address _contractor, uint256 amount)
    public
    onlyExistingTicketAmount(amount)
    returns (bool success)
  {
    require(isTicketValid(msg.sender), '{error: INVALID_TICKET}');

    super.transfer(_contractor, amount);

    contractors[_contractor].nbCredittedTickets += 1;

    tickets[msg.sender].contractor = _contractor;

    emit CreditEvt(msg.sender, _contractor, tickets[msg.sender].tType, now);

    return true;
  }

  // Publish a review and rate the ticket's contractor (only consumed tickets can
  // perform this action)
  // @param _reviewRate rating of the review
  function publishReview(uint _reviewRate) public {
    // Only ticket that hasn't published any review and that has been consumed
    require(!tickets[msg.sender].hasReviewed && tickets[msg.sender].contractor != 0x0, '{error: INVALID_TICKET}');

    // Only between 0 and 5
    require(_reviewRate >= 0 && _reviewRate <= 5, '{error: INVALID_RATE, message: "A rate should be between 0 and 5 included"}');

    // Add the review to the contractor of the ticket
    contractors[tickets[msg.sender].contractor].reviews[_reviewRate] += 1;

    tickets[msg.sender].hasReviewed = true;

    emit ReviewEvt(msg.sender, tickets[msg.sender].contractor, _reviewRate, now);
  }

  // Calculate the average rating of a contractor
  // @param _address contractor address
  function reviewAverageOfContractor(address _address) public view returns (uint avg) {
    // Percentage threshold
    uint decreaseThreshold = 60;

    // Apply a penalty of -1 for reviews = 0
    int totReviews = int(contractors[_address].reviews[0]) * -1;

    uint nbReviews = contractors[_address].reviews[0];

    for (uint i = 1; i <= 5; i++) {
      totReviews += int(contractors[_address].reviews[i] * i);
      nbReviews += contractors[_address].reviews[i];
    }

    if (nbReviews == 0) {
      return 250;
    }

    // Too much penalties leads to 0, then force it to be 0, the average
    // can't be negative
    if (totReviews < 0) {
      totReviews = 0;
    }

    uint percReviewsTickets = (nbReviews * 100 / contractors[_address].nbCredittedTickets);

    avg = (uint(totReviews) * 100) / nbReviews;

    if (percReviewsTickets >= decreaseThreshold) {
      return avg;
    }

    // A rate < 60% on the number of reviews will decrease the rating average of
    // the difference between the threshold and the % of reviews
    // for instance a percent reviews of 50% will decrease the rating average
    // of 10% (60% - 50%)
    // This is to avoid abuse of the system, without this mecanism a contractor
    // could stay with a average of 500 (the max) regardless of the number
    // of ticket he used.
    uint decreasePercent = decreaseThreshold - percReviewsTickets;

    return avg - (avg / decreasePercent);
  }

  // Returns the commission for the contractor
  // @param _address contractor address
  function commissionForContractor(address _address) public view returns (uint8 c) {
    return commissionForReviewAverageOf(reviewAverageOfContractor(_address));
  }

  // Returns the info of a ticket
  // @param _address ticket address
  function infoOfTicket(address _address) public view returns (uint256 balance, string tType, bool isValid, uint createdAt, uint expireAt, address contractor, bool hasReviewed) {
    return (super.balanceOf(_address), tickets[_address].tType, isTicketValid(_address), tickets[_address].createdAt, tickets[_address].expireAt, tickets[_address].contractor, tickets[_address].hasReviewed);
  }

  // Returns the contractor info
  // @param _address contractor address
  function infoOfContractor(address _address) public view returns(uint256 balance, uint256 debittedBalance, uint256 nbReviews, uint256 nbCredittedTickets, uint256 avg) {
    for (uint i = 0; i <= 5; i++) {
      nbReviews += contractors[_address].reviews[i];
    }

    return (super.balanceOf(_address), contractors[_address].debittedBalance, nbReviews, contractors[_address].nbCredittedTickets, reviewAverageOfContractor(_address));
  }

  // Transfers contractors tokens to the owner
  // It triggers Debit event
  // @param _amount amount to debit
  function debit(uint256 _amount) public {
    super.transfer(super.owner(), _amount);

    emit DebitEvt(msg.sender, _amount, commissionForContractor(msg.sender), now);
  }

  // Returns the cost of a ticket regarding its amount
  // Returned value is represented in Wei
  // @param _amount amount of the ticket
  function costOfTicket(uint256 _amount) public view returns(uint256 cost) {
    return (_amount * (ticketCostBase * 1000000000000000)) + ticketBaseValue;
  }

  // Calculate the commission regarding the rating (review average)
  // Example with a commissions = [30, 30, 30, 25, 20]
  // [0,3[ = 30% (DefaultCommission)
  // [3,4[ = 25%
  // [4,5[ = 20%
  // A rating average of 3.8 = 25% of commission
  // @param _avg commission average
  function commissionForReviewAverageOf(uint _avg) public view returns (uint8 c) {
    if (_avg >= 500) {
      return commissions[4];
    }

    for (uint i = 0; i < 5; i++) {
      if (_avg <= i * 100 || _avg < (i + 1) * 100) {
        return commissions[i];
      }
    }

    // Default commission when there is something wrong
    return commissions[0];
  }

  function _createTicket(address _address, uint256 _amount) private {
    tickets[_address] = Ticket({
      tType: ticketTypes[_amount],
      createdAt: now,
      expireAt: now + 2 * 365 days,
      contractor: 0x0,
      hasReviewed: false
    });
  }
}