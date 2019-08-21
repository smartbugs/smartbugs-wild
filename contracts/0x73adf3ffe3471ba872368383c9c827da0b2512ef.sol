pragma solidity 0.4.24;


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
 * @title Contracts that should be able to recover tokens
 * @author SylTi
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.
 * This will prevent any accidental loss of tokens.
 */
contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

  /**
   * @dev Reclaim all ERC20Basic compatible tokens
   * @param token ERC20Basic The address of the token contract
   */
  function reclaimToken(ERC20Basic token) external onlyOwner {
    uint256 balance = token.balanceOf(this);
    token.safeTransfer(owner, balance);
  }

}


/**
 * @title Contracts that should not own Tokens
 * @author Remco Bloemen <remco@2π.com>
 * @dev This blocks incoming ERC223 tokens to prevent accidental loss of tokens.
 * Should tokens (any ERC20Basic compatible) end up in the contract, it allows the
 * owner to reclaim the tokens.
 */
contract HasNoTokens is CanReclaimToken {

 /**
  * @dev Reject all ERC223 compatible tokens
  * @param from_ address The address that is transferring the tokens
  * @param value_ uint256 the amount of the specified token
  * @param data_ Bytes The data passed from the caller.
  */
  function tokenFallback(address from_, uint256 value_, bytes data_) external {
    from_;
    value_;
    data_;
    revert();
  }

}


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


/**
 * @title Contracts that should not own Contracts
 * @author Remco Bloemen <remco@2π.com>
 * @dev Should contracts (anything Ownable) end up being owned by this contract, it allows the owner
 * of this contract to reclaim ownership of the contracts.
 */
contract HasNoContracts is Ownable {

  /**
   * @dev Reclaim ownership of Ownable contracts
   * @param contractAddr The address of the Ownable to be reclaimed.
   */
  function reclaimContract(address contractAddr) external onlyOwner {
    Ownable contractInst = Ownable(contractAddr);
    contractInst.transferOwnership(owner);
  }
}


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


/// @title PoolParty contract responsible for deploying independent Pool.sol contracts.
contract PoolParty is HasNoTokens, HasNoContracts {
    using SafeMath for uint256;

    event PoolCreated(uint256 poolId, address creator);

    uint256 public nextPoolId;

    /// @dev Holds the pool id and the corresponding pool contract address
    mapping(uint256 =>address) public pools;

    /// @notice Reclaim Ether that is accidentally sent to this contract.
    /// @dev If a user forces ether into this contract, via selfdestruct etc..
    /// Requires:
    ///     - msg.sender is the owner
    function reclaimEther() external onlyOwner {
        owner.transfer(address(this).balance);
    }

    /// @notice Creates a new pool with custom configurations.
    /// @dev Creates a new pool via the imported Pool.sol contracts.
    /// Refer to Pool.sol contracts for specific details.
    /// @param _admins List of admins for the new pool.
    /// @param _configsUint Array of all uint256 custom configurations.
    /// Refer to the Config.sol files for a description of each one.
    /// @param _configsBool Array of all boolean custom configurations.
    /// Refer to the Config.sol files for a description of each one.
    /// @return The poolId for the created pool. Throws an exception on failure.
    function createPool(
        address[] _admins,
        uint256[] _configsUint,
        bool[] _configsBool
    )
        public
        returns (address _pool)
    {
        address poolOwner = msg.sender;

        _pool = new Pool(
            poolOwner,
            _admins,
            _configsUint,
            _configsBool,
            nextPoolId
        );

        pools[nextPoolId] = _pool;
        nextPoolId = nextPoolId.add(1);

        emit PoolCreated(nextPoolId, poolOwner);
    }
}


/// @title Admin functionality for Pool.sol contracts.
contract Admin {
    using SafeMath for uint256;
    using SafeMath for uint8;

    address public owner;
    address[] public admins;

    /// @dev Verifies the msg.sender is a member of the admins list.
    modifier isAdmin() {
        bool found = false;

        for (uint256 i = 0; i < admins.length; ++i) {
            if (admins[i] == msg.sender) {
                found = true;
                break;
            }
        }

        // msg.sender is not an admin!
        require(found);
        _;
    }

    /// @dev Ensures creator of the pool is in the admin list and that there are no duplicates or 0x0 addresses.
    modifier isValidAdminsList(address[] _listOfAdmins) {
        bool containsSender = false;

        for (uint256 i = 0; i < _listOfAdmins.length; ++i) {
            // Admin list contains 0x0 address!
            require(_listOfAdmins[i] != address(0));

            if (_listOfAdmins[i] == owner) {
                containsSender = true;
            }

            for (uint256 j = i + 1; j < _listOfAdmins.length; ++j) {
                // Admin list contains a duplicate address!
                require(_listOfAdmins[i] != _listOfAdmins[j]);
            }
        }

        // Admin list does not contain the creators address!
        require(containsSender);
        _;
    }

    /// @dev If the list of admins is verified, the global variable admins is set to equal the _listOfAdmins.
    /// throws an exception if _listOfAdmins is < 1.
    /// @param _listOfAdmins the list of admin addresses for the new pool.
    function createAdminsForPool(
        address[] _listOfAdmins
    )
        internal
        isValidAdminsList(_listOfAdmins)
    {
        admins = _listOfAdmins;
    }
}


// @title State configurations for Pool.sol contracts.
contract State is Admin {
    enum PoolState{
        // @dev Pool is accepting ETH. Users can refund themselves in this state.
        OPEN,

        // @dev Pool is closed and the funds are locked. No user refunds allowed.
        CLOSED,

        // @dev ETH is transferred out and the funds are locked. No refunds can be processed.
        // State cannot be re-opened.
        AWAITING_TOKENS,

        // @dev Available tokens are claimable by users.
        COMPLETED,

        // @dev Eth can be refunded to all wallets. State is final.
        CANCELLED
    }

    event PoolIsOpen ();
    event PoolIsClosed ();
    event PoolIsAwaitingTokens ();
    event PoolIsCompleted ();
    event PoolIsCancelled ();

    PoolState public state;

    /// @dev Verifies the pool is in the OPEN state.
    modifier isOpen() {
        // Pool is not set to open!
        require(state == PoolState.OPEN);
        _;
    }

    /// @dev Verifies the pool is in the CLOSED state.
    modifier isClosed() {
        // Pool is not closed!
        require(state == PoolState.CLOSED);
        _;
    }

    /// @dev Verifies the pool is in the OPEN or CLOSED state.
    modifier isOpenOrClosed() {
        // Pool is not cancelable!
        require(state == PoolState.OPEN || state == PoolState.CLOSED);
        _;
    }

    /// @dev Verifies the pool is CANCELLED.
    modifier isCancelled() {
        // Pool is not cancelled!
        require(state == PoolState.CANCELLED);
        _;
    }

    /// @dev Verifies the user is able to call a refund.
    modifier isUserRefundable() {
        // Pool is not user refundable!
        require(state == PoolState.OPEN || state == PoolState.CANCELLED);
        _;
    }

    /// @dev Verifies an admin is able to call a refund.
    modifier isAdminRefundable() {
        // Pool is not admin refundable!
        require(state == PoolState.OPEN || state == PoolState.CLOSED || state == PoolState.CANCELLED);  // solium-disable-line max-len
        _;
    }

    /// @dev Verifies the pool is in the COMPLETED or AWAITING_TOKENS state.
    modifier isAwaitingOrCompleted() {
        // Pool is not awaiting or completed!
        require(state == PoolState.COMPLETED || state == PoolState.AWAITING_TOKENS);
        _;
    }

    /// @dev Verifies the pool is in the COMPLETED state.
    modifier isCompleted() {
        // Pool is not completed!
        require(state == PoolState.COMPLETED);
        _;
    }

    /// @notice Allows the admin to set the state of the pool to OPEN.
    /// @dev Requires that the sender is an admin, and the pool is currently CLOSED.
    function setPoolToOpen() public isAdmin isClosed {
        state = PoolState.OPEN;
        emit PoolIsOpen();
    }

    /// @notice Allows the admin to set the state of the pool to CLOSED.
    /// @dev Requires that the sender is an admin, and the contract is currently OPEN.
    function setPoolToClosed() public isAdmin isOpen {
        state = PoolState.CLOSED;
        emit PoolIsClosed();
    }

    /// @notice Cancels the project and sets the state of the pool to CANCELLED.
    /// @dev Requires that the sender is an admin, and the contract is currently OPEN or CLOSED.
    function setPoolToCancelled() public isAdmin isOpenOrClosed {
        state = PoolState.CANCELLED;
        emit PoolIsCancelled();
    }

    /// @dev Sets the pool to AWAITING_TOKENS.
    function setPoolToAwaitingTokens() internal {
        state = PoolState.AWAITING_TOKENS;
        emit PoolIsAwaitingTokens();
    }

    /// @dev Sets the pool to COMPLETED.
    function setPoolToCompleted() internal {
        state = PoolState.COMPLETED;
        emit PoolIsCompleted();
    }
}


/// @title Uint256 and boolean configurations for Pool.sol contracts.
contract Config is State {
    enum OptionUint256{
        MAX_ALLOCATION,
        MIN_CONTRIBUTION,
        MAX_CONTRIBUTION,

        // Number of decimal places for the ADMIN_FEE_PERCENTAGE - capped at FEE_PERCENTAGE_DECIMAL_CAP.
        ADMIN_FEE_PERCENT_DECIMALS,

        // The percentage of admin fee relative to the amount of ADMIN_FEE_PERCENT_DECIMALS.
        ADMIN_FEE_PERCENTAGE
    }

    enum OptionBool{
        // True when the pool requires a whitelist.
        HAS_WHITELIST,

        // Uses ADMIN_FEE_PAYOUT_METHOD - true = tokens, false = ether.
        ADMIN_FEE_PAYOUT_TOKENS
    }

    uint8 public constant  OPTION_UINT256_SIZE = 5;
    uint8 public constant  OPTION_BOOL_SIZE = 2;
    uint8 public constant  FEE_PERCENTAGE_DECIMAL_CAP = 5;

    uint256 public maxAllocation;
    uint256 public minContribution;
    uint256 public maxContribution;
    uint256 public adminFeePercentageDecimals;
    uint256 public adminFeePercentage;
    uint256 public feePercentageDivisor;

    bool public hasWhitelist;
    bool public adminFeePayoutIsToken;

    /// @notice Sets the min and the max contribution configurations.
    /// @dev This will not retroactively effect previous contributions.
    /// This will only be applied to contributions moving forward.
    /// Requires:
    ///     - The msg.sender is an admin
    ///     - Max contribution is <= the max allocation
    ///     - Minimum contribution is <= max contribution
    ///     - The pool state is currently set to OPEN or CLOSED
    /// @param _min The new minimum contribution for this pool.
    /// @param _max The new maximum contribution for this pool.
    function setMinMaxContribution(
        uint256 _min,
        uint256 _max
    )
        public
        isAdmin
        isOpenOrClosed
    {
        // Max contribution is greater than max allocation!
        require(_max <= maxAllocation);
        // Minimum contribution is greater than max contribution!
        require(_min <= _max);

        minContribution = _min;
        maxContribution = _max;
    }

    /// @dev Validates and sets the configurations for the new pool.
    /// Throws an exception when:
    ///     - The config arrays are not the correct size
    ///     - The maxContribution > maxAllocation
    ///     - The minContribution > maxContribution
    ///     - The adminFeePercentageDecimals > FEE_PERCENTAGE_DECIMAL_CAP
    ///     - The adminFeePercentage >= 100
    /// @param _configsUint contains all of the uint256 configurations.
    /// The indexes are as follows:
    ///     - MAX_ALLOCATION
    ///     - MIN_CONTRIBUTION
    ///     - MAX_CONTRIBUTION
    ///     - ADMIN_FEE_PERCENT_DECIMALS
    ///     - ADMIN_FEE_PERCENTAGE
    /// @param _configsBool contains all of the  boolean configurations.
    /// The indexes are as follows:
    ///     - HAS_WHITELIST
    ///     - ADMIN_FEE_PAYOUT
    function createConfigsForPool(
        uint256[] _configsUint,
        bool[] _configsBool
    )
        internal
    {
        // Wrong number of uint256 configurations!
        require(_configsUint.length == OPTION_UINT256_SIZE);
        // Wrong number of boolean configurations!
        require(_configsBool.length == OPTION_BOOL_SIZE);

        // Sets the uint256 configurations.
        maxAllocation = _configsUint[uint(OptionUint256.MAX_ALLOCATION)];
        minContribution = _configsUint[uint(OptionUint256.MIN_CONTRIBUTION)];
        maxContribution = _configsUint[uint(OptionUint256.MAX_CONTRIBUTION)];
        adminFeePercentageDecimals = _configsUint[uint(OptionUint256.ADMIN_FEE_PERCENT_DECIMALS)];
        adminFeePercentage = _configsUint[uint(OptionUint256.ADMIN_FEE_PERCENTAGE)];

        // Sets the boolean values.
        hasWhitelist = _configsBool[uint(OptionBool.HAS_WHITELIST)];
        adminFeePayoutIsToken = _configsBool[uint(OptionBool.ADMIN_FEE_PAYOUT_TOKENS)];

        // @dev Test the validity of _configsUint.
        // Number of decimals used for admin fee greater than cap!
        require(adminFeePercentageDecimals <= FEE_PERCENTAGE_DECIMAL_CAP);
        // Max contribution is greater than max allocation!
        require(maxContribution <= maxAllocation);
        // Minimum contribution is greater than max contribution!
        require(minContribution <= maxContribution);

        // Verify the admin fee is less than 100%.
        feePercentageDivisor = (10 ** adminFeePercentageDecimals).mul(100);
        // Admin fee percentage is >= %100!
        require(adminFeePercentage < feePercentageDivisor);
    }
}


/// @title Whitelist configurations for Pool.sol contracts.
contract Whitelist is Config {
    mapping(address => bool) public whitelist;

    /// @dev Checks to see if the pool whitelist is enabled.
    modifier isWhitelistEnabled() {
        // Pool is not whitelisted!
        require(hasWhitelist);
        _;
    }

    /// @dev If the pool is whitelisted, verifies the user is whitelisted.
    modifier canDeposit(address _user) {
        if (hasWhitelist) {
            // User is not whitelisted!
            require(whitelist[_user] != false);
        }
        _;
    }

    /// @notice Adds a list of addresses to this pools whitelist.
    /// @dev Forwards a call to the internal method.
    /// Requires:
    ///     - Msg.sender is an admin
    /// @param _users The list of addresses to add to the whitelist.
    function addAddressesToWhitelist(address[] _users) public isAdmin {
        addAddressesToWhitelistInternal(_users);
    }

    /// @dev The internal version of adding addresses to the whitelist.
    /// This is called directly when initializing the pool from the poolParty.
    /// Requires:
    ///     - The white list configuration enabled
    /// @param _users The list of addresses to add to the whitelist.
    function addAddressesToWhitelistInternal(
        address[] _users
    )
        internal
        isWhitelistEnabled
    {
        // Cannot add an empty list to whitelist!
        require(_users.length > 0);

        for (uint256 i = 0; i < _users.length; ++i) {
            whitelist[_users[i]] = true;
        }
    }
}


/// @title Pool contract functionality and configurations.
contract Pool is Whitelist {
    /// @dev Address points to a boolean indicating if the address has participated in the pool.
    /// Even if they have been refunded and balance is zero
    /// This mapping internally helps us prevent duplicates from being pushed into swimmersList
    /// instead of iterating and popping from the list each time a users balance reaches 0.
    mapping(address => bool) public invested;

    /// @dev Address points to the current amount of wei the address has contributed to the pool.
    /// Even after the wei has been transferred out.
    /// Because the claim tokens function uses swimmers balances to calculate their claimable tokens.
    mapping(address => uint256) public swimmers;
    mapping(address => uint256) public swimmerReimbursements;
    mapping(address => mapping(address => uint256)) public swimmersTokensPaid;
    mapping(address => uint256) public totalTokensDistributed;
    mapping(address => bool) public adminFeePaid;

    address[] public swimmersList;
    address[] public tokenAddress;

    address public poolPartyAddress;
    uint256 public adminWeiFee;
    uint256 public poolId;
    uint256 public weiRaised;
    uint256 public reimbursementTotal;

    event AdminFeePayout(uint256 value);
    event Deposit(address recipient, uint256 value);
    event EtherTransferredOut(uint256 value);
    event ProjectReimbursed(uint256 value);
    event Refund(address recipient, uint256 value);
    event ReimbursementClaimed(address recipient, uint256 value);
    event TokenAdded(address tokenAddress);
    event TokenRemoved(address tokenAddress);
    event TokenClaimed(address recipient, uint256 value, address tokenAddress);

    /// @dev Verifies the msg.sender is the owner.
    modifier isOwner() {
        // This is not the owner!
        require(msg.sender == owner);
        _;
    }

    /// @dev Makes sure that the amount being transferred + the total amount previously sent
    /// is compliant with the configurations for the existing pool.
    modifier depositIsConfigCompliant() {
        // Value sent must be greater than 0!
        require(msg.value > 0);
        uint256 totalRaised = weiRaised.add(msg.value);
        uint256 amount = swimmers[msg.sender].add(msg.value);

        // Contribution will cause pool to be greater than max allocation!
        require(totalRaised <= maxAllocation);
        // Contribution is greater than max contribution!
        require(amount <= maxContribution);
        // Contribution is less than minimum contribution!
        require(amount >= minContribution);
        _;
    }

    /// @dev Verifies the user currently has funds in the pool.
    modifier userHasFundedPool(address _user) {
        // User does not have funds in the pool!
        require(swimmers[_user] > 0);
        _;
    }

    /// @dev Verifies the index parameters are valid/not out of bounds.
    modifier isValidIndex(uint256 _startIndex, uint256 _numberOfAddresses) {
        uint256 endIndex = _startIndex.add(_numberOfAddresses.sub(1));

        // The starting index is out of the array bounds!
        require(_startIndex < swimmersList.length);
        // The end index is out of the array bounds!
        require(endIndex < swimmersList.length);
        _;
    }

    /// @notice Creates a new pool with the parameters as custom configurations.
    /// @dev Creates a new pool where:
    ///     - The creator of the pool will be the owner
    ///     - _admins become administrators for the pool contract and are automatically
    ///      added to whitelist, if it is enabled in the _configsBool
    ///     - Pool is initialised with the state set to OPEN
    /// @param _poolOwner The owner of the new pool.
    /// @param _admins The list of admin addresses for the new pools. This list must include
    /// the creator of the pool.
    /// @param _configsUint Contains all of the uint256 configurations for the new pool.
    ///     - MAX_ALLOCATION
    ///     - MIN_CONTRIBUTION
    ///     - MAX_CONTRIBUTION
    ///     - ADMIN_FEE_PERCENT_DECIMALS
    ///     - ADMIN_FEE_PERCENTAGE
    /// @param _configsBool Contains all of the boolean configurations for the new pool.
    ///     - HAS_WHITELIST
    ///     - ADMIN_FEE_PAYOUT
    /// @param _poolId The corresponding poolId.
    constructor(
        address _poolOwner,
        address[] _admins,
        uint256[] _configsUint,
        bool[] _configsBool,
        uint256  _poolId
    )
        public
    {
        owner = _poolOwner;
        state = PoolState.OPEN;
        poolPartyAddress = msg.sender;
        poolId = _poolId;

        createAdminsForPool(_admins);
        createConfigsForPool(_configsUint, _configsBool);

        if (hasWhitelist) {
            addAddressesToWhitelistInternal(admins);
        }

        emit PoolIsOpen();
    }

    /// @notice The user sends Ether to the pool.
    /// @dev Calls the deposit function on behalf of the msg.sender.
    function() public payable {
        deposit(msg.sender);
    }

    /// @notice Returns the array of admin addresses.
    /// @dev This is used specifically for the Web3 DAPP portion of PoolParty,
    /// as the EVM will not allow contracts to return dynamically sized arrays.
    /// @return Returns and instance of the admins array.
    function getAdminAddressArray(
    )
        public
        view
        returns (address[] _arrayToReturn)
    {
        _arrayToReturn = admins;
    }

    /// @notice Returns the array of token addresses.
    /// @dev This is used specifically for the Web3 DAPP portion of PoolParty,
    /// as the EVM will not allow contracts to return dynamically sized arrays.
    /// @return Returns and instance of the tokenAddress array.
    function getTokenAddressArray(
    )
        public
        view
        returns (address[] _arrayToReturn)
    {
        _arrayToReturn = tokenAddress;
    }

    /// @notice Returns the amount of tokens currently in this contract.
    /// @dev This is used specifically for the Web3 DAPP portion of PoolParty.
    /// @return Returns the length of the tokenAddress arrau.
    function getAmountOfTokens(
    )
        public
        view
        returns (uint256 _lengthOfTokens)
    {
        _lengthOfTokens = tokenAddress.length;
    }

    /// @notice Returns the array of swimmers addresses.
    /// @dev This is used specifically for the DAPP portion of PoolParty,
    /// as the EVM will not allow contracts to return dynamically sized arrays.
    /// @return Returns and instance of the swimmersList array.
    function getSwimmersListArray(
    )
        public
        view
        returns (address[] _arrayToReturn)
    {
        _arrayToReturn = swimmersList;
    }

    /// @notice Returns the amount of swimmers currently in this contract.
    /// @dev This is used specifically for the Web3 DAPP portion of PoolParty.
    /// @return Returns the length of the swimmersList array.
    function getAmountOfSwimmers(
    )
        public
        view
        returns (uint256 _lengthOfSwimmers)
    {
        _lengthOfSwimmers = swimmersList.length;
    }

    /// @notice Deposit Ether where the contribution is credited to the address specified in the parameter.
    /// @dev Allows a user to deposit on the behalf of someone else. Emits a Deposit event on success.
    /// Requires:
    ///     - The pool state is set to OPEN
    ///     - The amount is > 0
    ///     - The amount complies with the configurations of the pool
    ///     - If the whitelist configuration is enabled, verify the _user can deposit
    /// @param _user The address that will be credited with the deposit.
    function deposit(
        address _user
    )
        public
        payable
        isOpen
        depositIsConfigCompliant
        canDeposit(_user)
    {
        if (!invested[_user]) {
            swimmersList.push(_user);
            invested[_user] = true;
        }

        weiRaised = weiRaised.add(msg.value);
        swimmers[_user] = swimmers[_user].add(msg.value);

        emit Deposit(msg.sender, msg.value);
    }

    /// @notice Process a refund.
    /// @dev Allows refunds in the contract. Calls the internal refund function.
    /// Requires:
    ///     - The state of the pool is either OPEN or CANCELLED
    ///     - The user currently has funds in the pool
    function refund() public isUserRefundable userHasFundedPool(msg.sender) {
        processRefundInternal(msg.sender);
    }

    /// @notice This triggers a refund event for a subset of users.
    /// @dev Uses the internal refund function.
    /// Requires:
    ///     - The pool state is currently set to CANCELLED
    ///     - The indexes are within the bounds of the swimmersList
    /// @param _startIndex The starting index for the subset.
    /// @param _numberOfAddresses The number of addresses to include past the starting index.
    function refundManyAddresses(
        uint256 _startIndex,
        uint256 _numberOfAddresses
    )
        public
        isCancelled
        isValidIndex(_startIndex, _numberOfAddresses)
    {
        uint256 endIndex = _startIndex.add(_numberOfAddresses.sub(1));

        for (uint256 i = _startIndex; i <= endIndex; ++i) {
            address user = swimmersList[i];

            if (swimmers[user] > 0) {
                processRefundInternal(user);
            }
        }
    }

    /// @notice claims available tokens.
    /// @dev Allows the user to claim their available tokens.
    /// Requires:
    ///     - The msg.sender has funded the pool
    function claim() public {
        claimAddress(msg.sender);
    }

    /// @notice Process a claim function for a specified address.
    /// @dev Allows the user to claim tokens on behalf of someone else.
    /// Requires:
    ///     - The _address has funded the pool
    ///     - The pool is in the completed state
    /// @param _address The address for which tokens should be redeemed.
    function claimAddress(
        address _address
    )
        public
        isCompleted
        userHasFundedPool(_address)
    {
        for (uint256 i = 0; i < tokenAddress.length; ++i) {
            ERC20Basic token = ERC20Basic(tokenAddress[i]);
            uint256 poolTokenBalance = token.balanceOf(this);

            payoutTokensInternal(_address, poolTokenBalance, token);
        }
    }

    /// @notice Distribute available tokens to a subset of users.
    /// @dev Allows anyone to call claim on a specified series of addresses.
    /// Requires:
    ///     - The indexes are within the bounds of the swimmersList
    /// @param _startIndex The starting index for the subset.
    /// @param _numberOfAddresses The number of addresses to include past the starting index.
    function claimManyAddresses(
        uint256 _startIndex,
        uint256 _numberOfAddresses
    )
        public
        isValidIndex(_startIndex, _numberOfAddresses)
    {
        uint256 endIndex = _startIndex.add(_numberOfAddresses.sub(1));

        claimAddressesInternal(_startIndex, endIndex);
    }

    /// @notice Process a reimbursement claim.
    /// @dev Allows the msg.sender to claim a reimbursement
    /// Requires:
    ///     - The msg.sender has a reimbursement to withdraw
    ///     - The pool state is currently set to AwaitingOrCompleted
    function reimbursement() public {
        claimReimbursement(msg.sender);
    }

    /// @notice Process a reimbursement claim for a specified address.
    /// @dev Calls the internal method responsible for processing a reimbursement.
    /// Requires:
    ///     - The specified user has a reimbursement to withdraw
    ///     - The pool state is currently set to AwaitingOrCompleted
    /// @param _user The user having the reimbursement processed.
    function claimReimbursement(
        address _user
    )
        public
        isAwaitingOrCompleted
        userHasFundedPool(_user)
    {
        processReimbursementInternal(_user);
    }

    /// @notice Process a reimbursement claim for subset of addresses.
    /// @dev Allows anyone to call claimReimbursement on a specified series of address indexes.
    /// Requires:
    ///     - The pool state is currently set to AwaitingOrCompleted
    ///     - The indexes are within the bounds of the swimmersList
    /// @param _startIndex The starting index for the subset.
    /// @param _numberOfAddresses The number of addresses to include past the starting index.
    function claimManyReimbursements(
        uint256 _startIndex,
        uint256 _numberOfAddresses
    )
        public
        isAwaitingOrCompleted
        isValidIndex(_startIndex, _numberOfAddresses)
    {
        uint256 endIndex = _startIndex.add(_numberOfAddresses.sub(1));

        for (uint256 i = _startIndex; i <= endIndex; ++i) {
            address user = swimmersList[i];

            if (swimmers[user] > 0) {
                processReimbursementInternal(user);
            }
        }
    }

    /// @notice Set a new token address where users can redeem ERC20 tokens.
    /// @dev Adds a new ERC20 address to the tokenAddress array.
    /// Sets the pool state to COMPLETED if it is not already.
    /// Crucial that only valid ERC20 addresses be added with this function.
    /// In the event a bad one is entered, it can be removed with the removeToken() method.
    /// Requires:
    ///     - The msg.sender is an admin
    ///     - The pool state is set to either AWAITING_TOKENS or COMPLETED
    ///     - The token address has not previously been added
    /// @param _tokenAddress The ERC20 address users can redeem from.
    function addToken(
        address _tokenAddress
    )
        public
        isAdmin
        isAwaitingOrCompleted
    {
        if (state != PoolState.COMPLETED) {
            setPoolToCompleted();
        }

        for (uint256 i = 0; i < tokenAddress.length; ++i) {
            // The address has already been added!
            require(tokenAddress[i] != _tokenAddress);
        }

        // @dev This verifies the address we are trying to add contains an ERC20 address.
        // This does not completely protect from having a bad address added, but it will reduce the likelihood.
        // Any address that does not contain a balanceOf() method cannot be added.
        ERC20Basic token = ERC20Basic(_tokenAddress);

        // The address being added is not an ERC20!
        require(token.balanceOf(this) >= 0);

        tokenAddress.push(_tokenAddress);

        emit TokenAdded(_tokenAddress);
    }

    /// @notice Remove a token address from the list of token addresses.
    /// @dev Removes a token address. This prevents users from calling claim on it. Does not preserve order.
    /// If it reduces the tokenAddress length to zero, then the state is set back to awaiting tokens.
    /// Requires:
    ///     - The msg.sender is an admin
    ///     - The pool state is set to COMPLETED
    ///     - The token address is located in the list.
    /// @param _tokenAddress The address to remove.
    function removeToken(address _tokenAddress) public isAdmin isCompleted {
        for (uint256 i = 0; i < tokenAddress.length; ++i) {
            if (tokenAddress[i] == _tokenAddress) {
                tokenAddress[i] = tokenAddress[tokenAddress.length - 1];
                delete tokenAddress[tokenAddress.length - 1];
                tokenAddress.length--;
                break;
            }
        }

        if (tokenAddress.length == 0) {
            setPoolToAwaitingTokens();
        }

        emit TokenRemoved(_tokenAddress);
    }

    /// @notice Removes a user from the whitelist and processes a refund.
    /// @dev Removes a user from the whitelist and their ability to contribute to the pool.
    /// Requires:
    ///     - The msg.sender is an admin
    ///     - The pool state is currently set to OPEN or CLOSED or CANCELLED
    ///     - The pool has enabled whitelist functionality
    /// @param _address The address for which the refund is processed and removed from whitelist.
    function removeAddressFromWhitelistAndRefund(
        address _address
    )
        public
        isWhitelistEnabled
        canDeposit(_address)
    {
        whitelist[_address] = false;
        refundAddress(_address);
    }

    /// @notice Refund a given address for all the Ether they have contributed.
    /// @dev Processes a refund for a given address by calling the internal refund function.
    /// Requires:
    ///     - The msg.sender is an admin
    ///     - The pool state is currently set to OPEN or CLOSED or CANCELLED
    /// @param _address The address for which the refund is processed.
    function refundAddress(
        address _address
    )
        public
        isAdmin
        isAdminRefundable
        userHasFundedPool(_address)
    {
        processRefundInternal(_address);
    }

    /// @notice Provides a refund for the entire list of swimmers
    /// to distribute at a pro-rata rate via the reimbursement functions.
    /// @dev Refund users after the pool state is set to AWAITING_TOKENS or COMPLETED.
    /// Requires:
    ///     - The msg.sender is an admin
    ///     - The state is either Awaiting or Completed
    function projectReimbursement(
    )
        public
        payable
        isAdmin
        isAwaitingOrCompleted
    {
        reimbursementTotal = reimbursementTotal.add(msg.value);

        emit ProjectReimbursed(msg.value);
    }

    /// @notice Sets the maximum allocation for the contract.
    /// @dev Set the uint256 configuration for maxAllocation to the _newMax parameter.
    /// If the amount of weiRaised so far is already past the limit,
    //  no further deposits can be made until the weiRaised is reduced
    /// Possibly by refunding some users.
    /// Requires:
    ///     - The msg.sender is an admin
    ///     - The pool state is currently set to OPEN or CLOSED
    ///     - The _newMax must be >= max contribution
    /// @param _newMax The new maximum allocation for this pool contract.
    function setMaxAllocation(uint256 _newMax) public isAdmin isOpenOrClosed {
        // Max Allocation cannot be below Max contribution!
        require(_newMax >= maxContribution);

        maxAllocation = _newMax;
    }

    /// @notice Transfers the Ether out of the contract to the given address parameter.
    /// @dev If admin fee is > 0, then call payOutAdminFee to distribute the admin fee.
    /// Sets the pool state to AWAITING_TOKENS.
    /// Requires:
    ///     - The pool state must be currently set to CLOSED
    ///     - msg.sender is the owner
    /// @param _contractAddress The address to send all Ether in the pool.
    function transferWei(address _contractAddress) public isOwner isClosed {
        uint256 weiForTransfer = weiTransferCalculator();

        if (adminFeePercentage > 0) {
            weiForTransfer = payOutAdminFee(weiForTransfer);
        }

        // No Ether to transfer!
        require(weiForTransfer > 0);
        _contractAddress.transfer(weiForTransfer);

        setPoolToAwaitingTokens();

        emit EtherTransferredOut(weiForTransfer);
    }

    /// @dev Calculates the amount of wei to be transferred out of the contract.
    /// Adds the difference to the refund total for participants to withdraw pro-rata from.
    /// @return The difference between amount raised and the max allocation.
    function weiTransferCalculator() internal returns (uint256 _amountOfWei) {
        if (weiRaised > maxAllocation) {
            _amountOfWei = maxAllocation;
            reimbursementTotal = reimbursementTotal.add(weiRaised.sub(maxAllocation));
        } else {
            _amountOfWei = weiRaised;
        }
    }

    /// @dev Payout the owner of this contract, based on the adminFeePayoutIsToken boolean.
    ///  - adminFeePayoutIsToken == true -> The payout is in tokens.
    /// Each member will have their portion deducted from their contribution before claiming tokens.
    ///  - adminFeePayoutIsToken == false -> The adminFee is deducted from the total amount of wei
    /// that would otherwise be transferred out of the contract.
    /// @return The amount of wei that will be transferred out of this function.
    function payOutAdminFee(
        uint256 _weiTotal
    )
        internal
        returns (uint256 _weiForTransfer)
    {
        adminWeiFee = _weiTotal.mul(adminFeePercentage).div(feePercentageDivisor);

        if (adminFeePayoutIsToken) {
            // @dev In the event the owner has wei currently contributed to the pool,
            // their fee is collected before they get credited on line 420.
            if (swimmers[owner] > 0) {
                collectAdminFee(owner);
            } else {
                // @dev In the event the owner has never contributed to the pool,
                // they have their address added so they can be iterated over in the claim all method.
                if (!invested[owner]) {
                    swimmersList.push(owner);
                    invested[owner] = true;
                }

                adminFeePaid[owner] = true;
            }

            // @dev The admin gets credited for his fee upfront.
            // Then the first time a swimmer claims their tokens, they will have their portion
            // of the fee deducted from their contribution, via the collectAdminFee() method.
            swimmers[owner] = swimmers[owner].add(adminWeiFee);
            _weiForTransfer = _weiTotal;
        } else {
            _weiForTransfer = _weiTotal.sub(adminWeiFee);

            if (adminWeiFee > 0) {
                owner.transfer(adminWeiFee);

                emit AdminFeePayout(adminWeiFee);
            }
        }
    }

    /// @dev The internal claim function for distributing available tokens.
    /// Goes through each of the token addresses set by the addToken function,
    /// and calculates a pro-rata rate for each pool participant to be distributed.
    /// In the event that a bad token address is present, and the transfer function fails,
    /// this method cannot be processed until
    /// the bad address has been removed via the removeToken() method.
    /// Requires:
    ///     - The pool state must be set to COMPLETED
    ///     - The tokenAddress array must contain ERC20 compliant addresses.
    /// @param _startIndex The index we start iterating from.
    /// @param _endIndex The last index we process.
    function claimAddressesInternal(
        uint256 _startIndex,
        uint256 _endIndex
    )
        internal
        isCompleted
    {
        for (uint256 i = 0; i < tokenAddress.length; ++i) {
            ERC20Basic token = ERC20Basic(tokenAddress[i]);
            uint256 tokenBalance = token.balanceOf(this);

            for (uint256 j = _startIndex; j <= _endIndex && tokenBalance > 0; ++j) {
                address user = swimmersList[j];

                if (swimmers[user] > 0) {
                    payoutTokensInternal(user, tokenBalance, token);
                }

                tokenBalance = token.balanceOf(this);
            }
        }
    }

    /// @dev Calculates the amount of tokens to be paid out for a given user.
    /// Emits a TokenClaimed event upon success.
    /// @param _user The user claiming tokens.
    /// @param _poolBalance The current balance the pool has for the given token.
    /// @param _token The token currently being calculated for.
    function payoutTokensInternal(
        address _user,
        uint256 _poolBalance,
        ERC20Basic _token
    )
        internal
    {
        // @dev The first time a user tries to claim tokens,
        // they will have the admin fee subtracted from their contribution.
        // This is the pro-rata portion added to swimmers[owner], in the payoutAdminFee() function.
        if (!adminFeePaid[_user] && adminFeePayoutIsToken && adminFeePercentage > 0) {
            collectAdminFee(_user);
        }

        // The total amount of tokens the contract has received.
        uint256 totalTokensReceived = _poolBalance.add(totalTokensDistributed[_token]);

        uint256 tokensOwedTotal = swimmers[_user].mul(totalTokensReceived).div(weiRaised);
        uint256 tokensPaid = swimmersTokensPaid[_user][_token];
        uint256 tokensToBePaid = tokensOwedTotal.sub(tokensPaid);

        if (tokensToBePaid > 0) {
            swimmersTokensPaid[_user][_token] = tokensOwedTotal;
            totalTokensDistributed[_token] = totalTokensDistributed[_token].add(tokensToBePaid);

            // Token transfer failed!
            require(_token.transfer(_user, tokensToBePaid));

            emit TokenClaimed(_user, tokensToBePaid, _token);
        }
    }

    /// @dev Processes a reimbursement claim for a given address.
    /// Emits a ReimbursementClaimed event for each successful iteration.
    /// @param _user The address being processed.
    function processReimbursementInternal(address _user) internal {
        // @dev The first time a user tries to claim tokens or a Reimbursement,
        // they will have the admin fee subtracted from their contribution.
        // This is the pro-rata portion added to swimmers[owner], in the payoutAdminFee() function.
        if (!adminFeePaid[_user] && adminFeePayoutIsToken && adminFeePercentage > 0) {
            collectAdminFee(_user);
        }

        // @dev Using integer division, there is the potential to truncate the result.
        // The effect is negligible because it is calculated in wei.
        // There will be dust, but the cost of gas for transferring it out, costs more than it is worth.
        uint256 amountContributed = swimmers[_user];
        uint256 totalReimbursement = reimbursementTotal.mul(amountContributed).div(weiRaised);
        uint256 alreadyReimbursed = swimmerReimbursements[_user];

        uint256 reimbursementAvailable = totalReimbursement.sub(alreadyReimbursed);

        if (reimbursementAvailable > 0) {
            swimmerReimbursements[_user] = swimmerReimbursements[_user].add(reimbursementAvailable);
            _user.transfer(reimbursementAvailable);

            emit ReimbursementClaimed(_user, reimbursementAvailable);
        }
    }

    /// @dev Subtracts the admin fee from the user's contribution.
    /// This should only happen once per user.
    /// Requires:
    ///     - This is the first time a user has tried to claim tokens or a reimbursement.
    /// @param _user The user who is paying the admin fee.
    function collectAdminFee(address _user) internal {
        uint256 individualFee = swimmers[_user].mul(adminFeePercentage).div(feePercentageDivisor);

        // @dev adding 1 to the fee is for rounding errors.
        // This will result in some left over dust, but it will cost more to transfer, than gained.
        individualFee = individualFee.add(1);
        swimmers[_user] = swimmers[_user].sub(individualFee);

        // Indicates the user has paid their fee.
        adminFeePaid[_user] = true;
    }

    /// @dev Processes a refund for a given address.
    /// Emits a Refund event for each successful iteration.
    /// @param _user The address for which the refund is processed.
    function processRefundInternal(address _user) internal {
        uint256 amount = swimmers[_user];

        swimmers[_user] = 0;
        weiRaised = weiRaised.sub(amount);
        _user.transfer(amount);

        emit Refund(_user, amount);
    }
}