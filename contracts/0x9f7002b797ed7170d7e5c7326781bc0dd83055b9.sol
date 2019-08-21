pragma solidity ^0.5.8;


library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
}


interface IERC20 {
  function balanceOf(address owner) external view returns (uint256 balance);
  function transfer(address to, uint256 value) external returns (bool success);
  function transferFrom(address from, address to, uint256 value) external returns (bool success);
  function approve(address spender, uint256 value) external returns (bool success);
  function allowance(address owner, address spender) external view returns (uint256 remaining);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/// @dev This is taken from https://github.com/OpenZeppelin/openzeppelin-solidity project.
/// https://github.com/OpenZeppelin/openzeppelin-solidity/blob/67bca857eedf99bf44a4b6a0fc5b5ed553135316/contracts/token/ERC20/ERC20.sol
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  string public constant name = "CAPZ";
  string public constant symbol = "CAPZ";
  uint8 public constant decimals = 18;

  /// @dev Total number of tokens in existence.
  uint256 public totalSupply;

  mapping(address => uint256) internal balances;
  mapping(address => mapping(address => uint256)) internal allowed;

  /// @dev Gets the balance of the specified address.
  /// @param owner The address to query the balance of.
  /// @return A uint256 representing the amount owned by the passed address.
  function balanceOf(address owner) external view returns (uint256) {
    return balances[owner];
  }

  /// @dev Transfer token to a specified address.
  /// @param to The address to transfer to.
  /// @param value The amount to be transferred.
  function transfer(address to, uint256 value) external returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  /// @dev Transfer tokens from one address to another.
  /// Note that while this function emits an Approval event, this is not required as per the specification,
  /// and other compliant implementations may not emit the event.
  /// @param from The address which you want to send tokens from
  /// @param to The address which you want to transfer to
  /// @param value The amount of tokens to be transferred
  function transferFrom(address from, address to, uint256 value) external returns (bool) {
    _transfer(from, to, value);
    _approve(from, msg.sender, allowed[from][msg.sender].sub(value));
    return true;
  }

  /// @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
  /// Beware that changing an allowance with this method brings the risk that someone may use both the old
  /// and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
  /// race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
  /// https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
  /// @param spender The address which will spend the funds.
  /// @param value The amount of tokens to be spent.
  function approve(address spender, uint256 value) external returns (bool) {
    _approve(msg.sender, spender, value);
    return true;
  }

  /// @dev Function to check the amount of tokens that an owner allowed to a spender.
  /// @param owner The address which owns the funds.
  /// @param spender The address which will spend the funds.
  /// @return A uint256 specifying the amount of tokens still available for the spender.
  function allowance(address owner, address spender) external view returns (uint256) {
    return allowed[owner][spender];
  }

  /// @dev Internal function that transfer token for a specified addresses.
  /// @param from The address to transfer from.
  /// @param to The address to transfer to.
  /// @param value The amount to be transferred.
  function _transfer(address from, address to, uint256 value) internal {
    require(address(this) != to);
    require(address(0) != to);

    balances[from] = balances[from].sub(value);
    balances[to] = balances[to].add(value);

    emit Transfer(from, to, value);
  }

  /// @dev Approve an address to spend another addresses' tokens.
  /// @param owner The address that owns the tokens.
  /// @param spender The address that will spend the tokens.
  /// @param value The number of tokens that can be spent.
  function _approve(address owner, address spender, uint256 value) internal {
    require(address(0) != owner);
    require(address(0) != spender);

    allowed[owner][spender] = value;

    emit Approval(owner, spender, value);
  }

  /// @dev Internal function that mints an amount of the token and assigns it to
  /// an account. This encapsulates the modification of balances such that the
  /// proper events are emitted.
  /// @param account The account that will receive the created tokens.
  /// @param value The amount that will be created.
  function _mint(address account, uint256 value) internal {
    require(address(0) != account);

    totalSupply = totalSupply.add(value);
    balances[account] = balances[account].add(value);

    emit Transfer(address(0), account, value);
  }
}


/// @notice The CAPZ contract has a finite date span and a financial
/// goal set in wei. While this contract is in force, users may buy
/// tokens. After certain conditions are met, token holders may either
/// refund the paid amount or claim the tokens in the form of points
/// with us. The availability of each operation depends on the result
/// of this contract. During the period that the contract is in force
/// (w.r.t. the dates and goals) the funds are locked and can only be
/// unlocked when status is GoalReached or GoalNotReached.
contract CAPZ is ERC20 {
  using SafeMath for uint256;

  /// @dev This is us. We use it internally to allow/deny usage of
  /// admininstrative functions.
  address internal owner;

  /// @notice The current wei amount that this contract has
  /// received. It also represents the number of tokens that have been
  /// granted.
  uint256 public balanceInWei;

  /// @notice The soft limit that we check against for success at the
  /// end of this contract. These limits may change over the course of
  /// this crowdsale contract as we want to adjust these values to
  /// match a certain amount in fiat currency.
  uint256 public goalLimitMinInWei;

  /// @title Same as goalLimitMinInWei but defines the hard limit. In
  /// the event this amount is received we do not wait for the end
  /// date to collect received funds and close the contract.
  uint256 public goalLimitMaxInWei;

  /// @notice The date (unix timestamp) which this contract terminates.
  uint256 public endOn;

  /// @notice The date (unix timestamp) which this contract starts.
  uint256 public startOn;

  /// @dev Internal struct that tracks the refunds made so far.
  mapping(address => uint256) internal refunds;

  /// @title The current status of this contract.
  enum ICOStatus {
    /// @notice The contract is not yet in force.
    NotOpen,
    /// @notice The contract is in force, accepting payments and
    /// granting tokens.
    Open,
    /// @notice The contract has terminated with success and the owner
    /// of this contract may withdraw the amount in wei. The contract
    /// may terminate prior the endOn date on the event that the
    /// goalLimitMaxInWei has been reached.
    GoalReached,
    /// @notice The contract has terminated and the goal not been
    /// reached. Token holders may refund the invested value.
    GoalNotReached
  }

  constructor (uint256 _startOn, uint256 _endOn, uint256 _goalLimitMinInWei, uint256 _goalLimitMaxInWei) public {
    require(_startOn < _endOn);
    require(_goalLimitMinInWei < _goalLimitMaxInWei);

    owner = msg.sender;
    endOn = _endOn;
    startOn = _startOn;
    goalLimitMaxInWei = _goalLimitMaxInWei;
    goalLimitMinInWei = _goalLimitMinInWei;
  }

  function () external payable {
    require(0 == msg.data.length);

    buyTokens();
  }

  /// @notice The function that allow users to buy tokens. This
  /// function shall grant the amount received in wei to tokens. As
  /// this is an standard ERC20 contract you may trade these tokens at
  /// any time if desirable. At the end of the contract, you may
  /// either claim these tokens or refund the amount paid. Refer to
  /// these two functions for more information about the rules.
  /// @dev Receives wei and _mint the received amount to the
  /// msg.sender. Emits a Transfer event, using address(0) as the
  /// source address. It also increases the totalSupply and balanceInWei.
  function buyTokens() public whenOpen payable {
    uint256 receivedAmount = msg.value;
    address beneficiary = msg.sender;
    uint256 newBalance = balanceInWei.add(receivedAmount);
    uint256 newRefundBalance = refunds[beneficiary].add(receivedAmount);

    _mint(beneficiary, receivedAmount);
    refunds[beneficiary] = newRefundBalance;
    balanceInWei = newBalance;
  }

  /// @notice In the event the contract has terminated [status is
  /// GoalNotReached] and the goal has not been reached users may
  /// refund the amount paid [disregarding gas expenses].
  function escrowRefund() external whenGoalNotReached {
    uint256 amount = refunds[msg.sender];

    require(address(0) != msg.sender);
    require(0 < amount);

    refunds[msg.sender] = 0;
    msg.sender.transfer(amount);
  }

  /// @notice This is an administrative function and can only be
  /// called by the contract's owner when the status is
  /// GoalReached. If these conditions are met the balance is
  /// transferred to the contract's owner.
  function escrowWithdraw() external onlyOwner whenGoalReached {
    uint256 amount = address(this).balance;

    require(address(0) != msg.sender);
    require(0 < amount);

    msg.sender.transfer(amount);
  }

  /// @notice This function is used in the event the contract's status
  /// is GoalReached. It allows the user to exchange tokens in
  /// points. The conversion rate is variable and is not defined in
  /// this contract.
  /// @param amount The tokens you want to convert in points.
  /// @dev Emits the Claim event.
  function escrowClaim(uint256 amount) external whenGoalReached {
    _transfer(msg.sender, owner, amount);
    emit Claim(msg.sender, amount);
  }

  /// @notice Administrative function that allows the contract's owner
  /// to change the goals. As the goals are set in fiat currency, this
  /// mechanism might be used to adjust the goal so that the goal
  /// won't suffer from severe ETH fluctuations. Notice this function
  /// can't be used when the status is GoalNotReached or GoalReached.
  /// @dev Emits the GoalChange event.
  function alterGoal(uint256 _goalLimitMinInWei, uint256 _goalLimitMaxInWei) external onlyOwner {
    ICOStatus status = status(block.timestamp);

    require(ICOStatus.GoalReached != status);
    require(ICOStatus.GoalNotReached != status);
    require(_goalLimitMinInWei < _goalLimitMaxInWei);

    goalLimitMinInWei = _goalLimitMinInWei;
    goalLimitMaxInWei = _goalLimitMaxInWei;

    emit GoalChange(_goalLimitMinInWei, _goalLimitMaxInWei);
  }

  /// @notice Administrative function.
  function transferOwnership(address newOwner) external onlyOwner {
    require(address(0) != newOwner);
    require(address(this) != newOwner);

    owner = newOwner;
  }

  /// @notice Returns the current status of the contract. All functions
  /// depend on this to enforce invariants, like allowing/denying
  /// refund or withdraw. Please refer to ICOStatus enum documentation
  /// for more information about each status in detail.
  function status() external view returns (ICOStatus) {
    return status(block.timestamp);
  }

  /// @dev internal function that receives a timestamp instead of
  /// reading from block.timestamp.
  function status(uint256 timestamp) internal view returns (ICOStatus) {
    if (timestamp < startOn) {
      return ICOStatus.NotOpen;
    } else if (timestamp < endOn && balanceInWei < goalLimitMaxInWei) {
      return ICOStatus.Open;
    } else if (balanceInWei >= goalLimitMinInWei) {
      return ICOStatus.GoalReached;
    } else {
      return ICOStatus.GoalNotReached;
    }
  }

  /// @notice Event emitted when the contract's owner has adjusted the
  /// goal. Refer to alterGoal function for more information.
  event GoalChange(uint256 goalLimitMinInWei, uint256 goalLimitMaxInWei);

  /// @notice Event emitted when the user has exchanged tokens per
  /// points.
  event Claim(address beneficiary, uint256 value);

  modifier onlyOwner() {
    require(owner == msg.sender);
    _;
  }

  modifier whenOpen() {
    require(ICOStatus.Open == status(block.timestamp));
    _;
  }

  modifier whenGoalReached() {
    require(ICOStatus.GoalReached == status(block.timestamp));
    _;
  }

  modifier whenGoalNotReached() {
    require(ICOStatus.GoalNotReached == status(block.timestamp));
    _;
  }
}