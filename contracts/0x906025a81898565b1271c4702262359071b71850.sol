// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: contracts/BombCoin.sol

/**
 *Submitted for verification at Etherscan.io on 2019-02-11
*/

pragma solidity 0.4.25;

library SafeMathCustom {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
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

    function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
        uint256 c = add(a,m);
        uint256 d = sub(c,1);
        return mul(div(d,m),m);
    }
}

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns(string memory) {
        return _name;
    }

    function symbol() public view returns(string memory) {
        return _symbol;
    }

    function decimals() public view returns(uint8) {
        return _decimals;
    }
}

contract BOMBv3 is ERC20Detailed {

    using SafeMathCustom for uint256;
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;

    string constant tokenName = "BOMB";
    string constant tokenSymbol = "BOMB";
    uint8  constant tokenDecimals = 0;
    uint256 _totalSupply = 1000000;
    uint256 public basePercent = 100;

    constructor() public payable ERC20Detailed(tokenName, tokenSymbol, tokenDecimals) {
        _mint(msg.sender, _totalSupply);
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    function findOnePercent(uint256 value) public view returns (uint256)  {
        uint256 roundValue = value.ceil(basePercent);
        uint256 onePercent = roundValue.mul(basePercent).div(10000);
        return onePercent;
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(value <= _balances[msg.sender]);
        require(to != address(0));

        uint256 tokensToBurn = findOnePercent(value);
        uint256 tokensToTransfer = value.sub(tokensToBurn);

        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(tokensToTransfer);

        _totalSupply = _totalSupply.sub(tokensToBurn);

        emit Transfer(msg.sender, to, tokensToTransfer);
        emit Transfer(msg.sender, address(0), tokensToBurn);
        return true;
    }

    function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {
        for (uint256 i = 0; i < receivers.length; i++) {
          transfer(receivers[i], amounts[i]);
        }
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(value <= _balances[from]);
        require(value <= _allowed[from][msg.sender]);
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);

        uint256 tokensToBurn = findOnePercent(value);
        uint256 tokensToTransfer = value.sub(tokensToBurn);

        _balances[to] = _balances[to].add(tokensToTransfer);
        _totalSupply = _totalSupply.sub(tokensToBurn);

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

        emit Transfer(from, to, tokensToTransfer);
        emit Transfer(from, address(0), tokensToBurn);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));
        _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function _mint(address account, uint256 amount) internal {
        require(amount != 0);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(amount != 0);
        require(amount <= _balances[account]);
        _totalSupply = _totalSupply.sub(amount);
        _balances[account] = _balances[account].sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function burnFrom(address account, uint256 amount) external {
        require(amount <= _allowed[account][msg.sender]);
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(amount);
        _burn(account, amount);
    }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.4.24;


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

// File: openzeppelin-solidity/contracts/ownership/Claimable.sol

pragma solidity ^0.4.24;



/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
contract Claimable is Ownable {
  address public pendingOwner;

  /**
   * @dev Modifier throws if called by any account other than the pendingOwner.
   */
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

  /**
   * @dev Allows the current owner to set the pendingOwner address.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() public onlyPendingOwner {
    emit OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}

// File: contracts/Broker.sol

pragma solidity 0.4.25;



/// @title The Broker + Vault contract for Switcheo Exchange
/// @author Switcheo Network
/// @notice This contract faciliates Ethereum and ERC-20 trades
/// between users. Users can trade with each other by making
/// and taking offers without giving up custody of their tokens.
/// Users should first deposit tokens, then communicate off-chain
/// with the exchange coordinator, in order to place orders
/// (make / take offers). This allows trades to be confirmed
/// immediately by the coordinator, and settled on-chain through
/// this contract at a later time.
contract Broker is Claimable {
    using SafeMath for uint256;

    struct Offer {
        address maker;
        address offerAsset;
        address wantAsset;
        uint64 nonce;
        uint256 offerAmount;
        uint256 wantAmount;
        uint256 availableAmount; // the remaining offer amount
    }

    struct AnnouncedWithdrawal {
        uint256 amount;
        uint256 canWithdrawAt;
    }

    // Exchange states
    enum State { Active, Inactive }
    State public state;

    // The maximum announce delay in seconds
    // (7 days * 24 hours * 60 mins * 60 seconds)
    uint32 constant maxAnnounceDelay = 604800;
    // Ether token "address" is set as the constant 0x00
    address constant etherAddr = address(0);

    // deposits
    uint8 constant ReasonDeposit = 0x01;
    // making an offer
    uint8 constant ReasonMakerGive = 0x02;
    uint8 constant ReasonMakerFeeGive = 0x10;
    uint8 constant ReasonMakerFeeReceive = 0x11;
    // filling an offer
    uint8 constant ReasonFillerGive = 0x03;
    uint8 constant ReasonFillerFeeGive = 0x04;
    uint8 constant ReasonFillerReceive = 0x05;
    uint8 constant ReasonMakerReceive = 0x06;
    uint8 constant ReasonFillerFeeReceive = 0x07;
    // cancelling an offer
    uint8 constant ReasonCancel = 0x08;
    uint8 constant ReasonCancelFeeGive = 0x12;
    uint8 constant ReasonCancelFeeReceive = 0x13;
    // withdrawals
    uint8 constant ReasonWithdraw = 0x09;
    uint8 constant ReasonWithdrawFeeGive = 0x14;
    uint8 constant ReasonWithdrawFeeReceive = 0x15;

    // The coordinator sends trades (balance transitions) to the exchange
    address public coordinator;
    // The operator receives fees
    address public operator;
    // The time required to wait after a cancellation is announced
    // to let the operator detect it in non-byzantine conditions
    uint32 public cancelAnnounceDelay;
    // The time required to wait after a withdrawal is announced
    // to let the operator detect it in non-byzantine conditions
    uint32 public withdrawAnnounceDelay;

    // User balances by: userAddress => assetHash => balance
    mapping(address => mapping(address => uint256)) public balances;
    // Offers by the creation transaction hash: transactionHash => offer
    mapping(bytes32 => Offer) public offers;
    // A record of which hashes have been used before
    mapping(bytes32 => bool) public usedHashes;
    // Set of whitelisted spender addresses allowed by the owner
    mapping(address => bool) public whitelistedSpenders;
    // Spenders which have been approved by individual user as: userAddress => spenderAddress => true
    mapping(address => mapping(address => bool)) public approvedSpenders;
    // Announced withdrawals by: userAddress => assetHash => data
    mapping(address => mapping(address => AnnouncedWithdrawal)) public announcedWithdrawals;
    // Announced cancellations by: offerHash => data
    mapping(bytes32 => uint256) public announcedCancellations;

    // Emitted when new offers made
    event Make(address indexed maker, bytes32 indexed offerHash);
    // Emitted when offers are filled
    event Fill(address indexed filler, bytes32 indexed offerHash, uint256 amountFilled, uint256 amountTaken, address indexed maker);
    // Emitted when offers are cancelled
    event Cancel(address indexed maker, bytes32 indexed offerHash);
    // Emitted on any balance state transition (+ve)
    event BalanceIncrease(address indexed user, address indexed token, uint256 amount, uint8 indexed reason);
    // Emitted on any balance state transition (-ve)
    event BalanceDecrease(address indexed user, address indexed token, uint256 amount, uint8 indexed reason);
    // Emitted when a withdrawal is annnounced
    event WithdrawAnnounce(address indexed user, address indexed token, uint256 amount, uint256 canWithdrawAt);
    // Emitted when a cancellation is annnounced
    event CancelAnnounce(address indexed user, bytes32 indexed offerHash, uint256 canCancelAt);
    // Emitted when a user approved a spender
    event SpenderApprove(address indexed user, address indexed spender);
    // Emitted when a user rescinds approval for a spender
    event SpenderRescind(address indexed user, address indexed spender);

    /// @notice Initializes the Broker contract
    /// @dev The coordinator and operator is initialized
    /// to be the address of the sender. The Broker is immediately
    /// put into an active state, with maximum exit delays set.
    constructor()
        public
    {
        coordinator = msg.sender;
        operator = msg.sender;
        cancelAnnounceDelay = maxAnnounceDelay;
        withdrawAnnounceDelay = maxAnnounceDelay;
        state = State.Active;
    }

    modifier onlyCoordinator() {
        require(
            msg.sender == coordinator,
            "Invalid sender"
        );
        _;
    }

    modifier onlyActiveState() {
        require(
            state == State.Active,
            "Invalid state"
        );
        _;
    }

    modifier onlyInactiveState() {
        require(
            state == State.Inactive,
            "Invalid state"
        );
        _;
    }

    modifier notMoreThanMaxDelay(uint32 _delay) {
        require(
            _delay <= maxAnnounceDelay,
            "Invalid delay"
        );
        _;
    }

    modifier unusedReasonCode(uint8 _reasonCode) {
        require(
            _reasonCode > ReasonWithdrawFeeReceive,
            "Invalid reason code"
        );
        _;
    }

    /// @notice Sets the Broker contract state
    /// @dev There are only two states - Active & Inactive.
    ///
    /// The Active state is the normal operating state for the contract -
    /// deposits, trading and withdrawals can be carried out.
    ///
    /// In the Inactive state, the coordinator can invoke additional
    /// emergency methods such as emergencyCancel and emergencyWithdraw,
    /// without the cooperation of users. However, deposits and trading
    /// methods cannot be invoked at that time. This state is meant
    /// primarily to terminate and upgrade the contract, or to be used
    /// in the event that the contract is considered no longer viable
    /// to continue operation, and held tokens should be immediately
    /// withdrawn to their respective owners.
    /// @param _state The state to transition the contract into
    function setState(State _state) external onlyOwner { state = _state; }

    /// @notice Sets the coordinator address.
    /// @dev All standard operations (except `depositEther`)
    /// must be invoked by the coordinator.
    /// @param _coordinator The address to set as the coordinator
    function setCoordinator(address _coordinator) external onlyOwner {
        _validateAddress(_coordinator);
        coordinator = _coordinator;
    }

    /// @notice Sets the operator address.
    /// @dev All fees are paid to the operator.
    /// @param _operator The address to set as the operator
    function setOperator(address _operator) external onlyOwner {
        _validateAddress(operator);
        operator = _operator;
    }

    /// @notice Sets the delay between when a cancel
    /// intention must be announced, and when the cancellation
    /// can actually be executed on-chain
    /// @dev This delay exists so that the coordinator has time to
    /// respond when a user is attempting to bypass it and cancel
    /// offers directly on-chain.
    /// Note that this is an direct on-chain cancellation
    /// is an atypical operation - see `slowCancel`
    /// for more details.
    /// @param _delay The delay in seconds
    function setCancelAnnounceDelay(uint32 _delay)
        external
        onlyOwner
        notMoreThanMaxDelay(_delay)
    {
        cancelAnnounceDelay = _delay;
    }

    /// @notice Sets the delay (in seconds) between when a withdrawal
    /// intention must be announced, and when the withdrawal
    /// can actually be executed on-chain.
    /// @dev This delay exists so that the coordinator has time to
    /// respond when a user is attempting to bypass it and cancel
    /// offers directly on-chain. See `announceWithdraw` and
    /// `slowWithdraw` for more details.
    /// @param _delay The delay in seconds
    function setWithdrawAnnounceDelay(uint32 _delay)
        external
        onlyOwner
        notMoreThanMaxDelay(_delay)
    {
        withdrawAnnounceDelay = _delay;
    }

    /// @notice Adds an address to the set of allowed spenders.
    /// @dev Spenders are meant to be additional EVM contracts that
    /// will allow adding or upgrading of trading functionality, without
    /// having to cancel all offers and withdraw all tokens for all users.
    /// This whitelist ensures that all approved spenders are contracts
    /// that have been verified by the owner. Note that each user also
    /// has to invoke `approveSpender` to actually allow the `_spender`
    /// to spend his/her balance, so that they can examine / verify
    /// the new spender contract first.
    /// @param _spender The address to add as a whitelisted spender
    function addSpender(address _spender)
        external
        onlyOwner
    {
        _validateAddress(_spender);
        whitelistedSpenders[_spender] = true;
    }

    /// @notice Removes an address from the set of allowed spenders.
    /// @dev Note that removing a spender from the whitelist will not
    /// prevent already approved spenders from spending a user's balance.
    /// This is to ensure that the spender contracts can be certain that once
    /// an approval is done, the owner cannot rescient spending priviledges,
    /// and cause tokens to be withheld or locked in the spender contract.
    /// Users must instead manually rescind approvals using `rescindApproval`
    /// after the `_spender` has been removed from the whitelist.
    /// @param _spender The address to remove as a whitelisted spender
    function removeSpender(address _spender)
        external
        onlyOwner
    {
        _validateAddress(_spender);
        delete whitelistedSpenders[_spender];
    }

    /// @notice Deposits Ethereum tokens under the `msg.sender`'s balance
    /// @dev Allows sending ETH to the contract, and increasing
    /// the user's contract balance by the amount sent in.
    /// This operation is only usable in an Active state to prevent
    /// a terminated contract from receiving tokens.
    function depositEther()
        external
        payable
        onlyActiveState
    {
        require(
            msg.value > 0,
            'Invalid value'
        );
        balances[msg.sender][etherAddr] = balances[msg.sender][etherAddr].add(msg.value);
        emit BalanceIncrease(msg.sender, etherAddr, msg.value, ReasonDeposit);
    }

    /// @notice Deposits ERC20 tokens under the `_user`'s balance
    /// @dev Allows sending ERC20 tokens to the contract, and increasing
    /// the user's contract balance by the amount sent in. This operation
    /// can only be used after an ERC20 `approve` operation for a
    /// sufficient amount has been carried out.
    ///
    /// Note that this operation does not require user signatures as
    /// a valid ERC20 `approve` call is considered as intent to deposit
    /// the tokens. This is as there is no other ERC20 methods that this
    /// contract can call.
    ///
    /// This operation can only be called by the coordinator,
    /// and should be autoamtically done so whenever an `approve` event
    /// from a ERC20 token (that the coordinator deems valid)
    /// approving this contract to spend tokens on behalf of a user is seen.
    ///
    /// This operation is only usable in an Active state to prevent
    /// a terminated contract from receiving tokens.
    /// @param _user The address of the user that is depositing tokens
    /// @param _token The address of the ERC20 token to deposit
    /// @param _amount The (approved) amount to deposit
    function depositERC20(
        address _user,
        address _token,
        uint256 _amount
    )
        external
        onlyCoordinator
        onlyActiveState
    {
        require(
            _amount > 0,
            'Invalid value'
        );
        balances[_user][_token] = balances[_user][_token].add(_amount);

        _validateIsContract(_token);
        require(
            _token.call(
                bytes4(keccak256("transferFrom(address,address,uint256)")),
                _user,
                address(this),
                _amount
            ),
            "transferFrom call failed"
        );
        require(
            _getSanitizedReturnValue(),
            "transferFrom failed."
        );

        emit BalanceIncrease(_user, _token, _amount, ReasonDeposit);
    }

    /// @notice Withdraws `_amount` worth of `_token`s to the `_withdrawer`
    /// @dev This is the standard withdraw operation. Tokens can only be
    /// withdrawn directly to the token balance owner's address.
    /// Fees can be paid to cover network costs, as the operation must
    /// be invoked by the coordinator. The hash of all parameters, prefixed
    /// with the operation name "withdraw" must be signed by the withdrawer
    /// to validate the withdrawal request. A nonce that is issued by the
    /// coordinator is used to prevent replay attacks.
    /// See `slowWithdraw` for withdrawing without requiring the coordinator's
    /// involvement.
    /// @param _withdrawer The address of the user that is withdrawing tokens
    /// @param _token The address of the token to withdraw
    /// @param _amount The number of tokens to withdraw
    /// @param _feeAsset The address of the token to use for fee payment
    /// @param _feeAmount The amount of tokens to pay as fees to the operator
    /// @param _nonce The nonce to prevent replay attacks
    /// @param _v The `v` component of the `_withdrawer`'s signature
    /// @param _r The `r` component of the `_withdrawer`'s signature
    /// @param _s The `s` component of the `_withdrawer`'s signature
    function withdraw(
        address _withdrawer,
        address _token,
        uint256 _amount,
        address _feeAsset,
        uint256 _feeAmount,
        uint64 _nonce,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        external
        onlyCoordinator
    {
        bytes32 msgHash = keccak256(abi.encodePacked(
            "withdraw",
            _withdrawer,
            _token,
            _amount,
            _feeAsset,
            _feeAmount,
            _nonce
        ));

        require(
            _recoverAddress(msgHash, _v, _r, _s) == _withdrawer,
            "Invalid signature"
        );

        _validateAndAddHash(msgHash);

        _withdraw(_withdrawer, _token, _amount, _feeAsset, _feeAmount);
    }

    /// @notice Announces intent to withdraw tokens using `slowWithdraw`
    /// @dev Allows a user to invoke `slowWithdraw` after a minimum of
    /// `withdrawAnnounceDelay` seconds has passed.
    /// This announcement and delay is necessary so that the operator has time
    /// to respond if a user attempts to invoke a `slowWithdraw` even though
    /// the exchange is operating normally. In that case, the coordinator would respond
    /// by not allowing the announced amount of tokens to be used in future trades
    /// the moment a `WithdrawAnnounce` is seen.
    /// @param _token The address of the token to withdraw after the required exit delay
    /// @param _amount The number of tokens to withdraw after the required exit delay
    function announceWithdraw(
        address _token,
        uint256 _amount
    )
        external
    {
        require(
            _amount <= balances[msg.sender][_token],
            "Amount too high"
        );

        AnnouncedWithdrawal storage announcement = announcedWithdrawals[msg.sender][_token];
        uint256 canWithdrawAt = now + withdrawAnnounceDelay;

        announcement.canWithdrawAt = canWithdrawAt;
        announcement.amount = _amount;

        emit WithdrawAnnounce(msg.sender, _token, _amount, canWithdrawAt);
    }

    /// @notice Withdraw tokens without requiring the coordinator
    /// @dev This operation is meant to be used if the operator becomes "byzantine",
    /// so that users can still exit tokens locked in this contract.
    /// The `announceWithdraw` operation has to be invoked first, and a minimum time of
    /// `withdrawAnnounceDelay` seconds have to pass, before this operation can be carried out.
    /// Note that this direct on-chain withdrawal is an atypical operation, and
    /// the normal `withdraw` operation should be used in non-byzantine states.
    /// @param _withdrawer The address of the user that is withdrawing tokens
    /// @param _token The address of the token to withdraw
    /// @param _amount The number of tokens to withdraw
    function slowWithdraw(
        address _withdrawer,
        address _token,
        uint256 _amount
    )
        external
    {
        AnnouncedWithdrawal memory announcement = announcedWithdrawals[_withdrawer][_token];

        require(
            announcement.canWithdrawAt != 0 && announcement.canWithdrawAt <= now,
            "Insufficient delay"
        );

        require(
            announcement.amount == _amount,
            "Invalid amount"
        );

        delete announcedWithdrawals[_withdrawer][_token];

        _withdraw(_withdrawer, _token, _amount, etherAddr, 0);
    }

    /// @notice Withdraws tokens to the owner without requiring the owner's signature
    /// @dev Can only be invoked in an Inactive state by the coordinator.
    /// This operation is meant to be used in emergencies only.
    /// @param _withdrawer The address of the user that should have tokens withdrawn
    /// @param _token The address of the token to withdraw
    /// @param _amount The number of tokens to withdraw
    function emergencyWithdraw(
        address _withdrawer,
        address _token,
        uint256 _amount
    )
        external
        onlyCoordinator
        onlyInactiveState
    {
        _withdraw(_withdrawer, _token, _amount, etherAddr, 0);
    }

    /// @notice Makes an offer which can be filled by other users.
    /// @dev Makes an offer for `_offerAmount` of `offerAsset` tokens
    /// for `wantAmount` of `wantAsset` tokens, that can be filled later
    /// by one or more counterparties using `fillOffer` or `fillOffers`.
    /// The offer can be later cancelled using `cancel` or `slowCancel` as long
    /// as it has not completely been filled.
    /// A fee of `_feeAmount` of `_feeAsset` tokens can be paid to the operator
    /// to cover orderbook maintenance and network costs.
    /// The hash of all parameters, prefixed with the operation name "makeOffer"
    /// must be signed by the `_maker` to validate the offer request.
    /// A nonce that is issued by the coordinator is used to prevent replay attacks.
    /// This operation can only be invoked by the coordinator in an Active state.
    /// @param _maker The address of the user that is making the offer
    /// @param _offerAsset The address of the token being offered
    /// @param _wantAsset The address of the token asked in return
    /// @param _offerAmount The number of tokens being offered
    /// @param _wantAmount The number of tokens asked for in return
    /// @param _feeAsset The address of the token to use for fee payment
    /// @param _feeAmount The amount of tokens to pay as fees to the operator
    /// @param _nonce The nonce to prevent replay attacks
    /// @param _v The `v` component of the `_maker`'s signature
    /// @param _r The `r` component of the `_maker`'s signature
    /// @param _s The `s` component of the `_maker`'s signature
    function makeOffer(
        address _maker,
        address _offerAsset,
        address _wantAsset,
        uint256 _offerAmount,
        uint256 _wantAmount,
        address _feeAsset,
        uint256 _feeAmount,
        uint64 _nonce,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        external
        onlyCoordinator
        onlyActiveState
    {
        require(
            _offerAmount > 0 && _wantAmount > 0,
            "Invalid amounts"
        );

        require(
            _offerAsset != _wantAsset,
            "Invalid assets"
        );

        bytes32 offerHash = keccak256(abi.encodePacked(
            "makeOffer",
            _maker,
            _offerAsset,
            _wantAsset,
            _offerAmount,
            _wantAmount,
            _feeAsset,
            _feeAmount,
            _nonce
        ));

        require(
            _recoverAddress(offerHash, _v, _r, _s) == _maker,
            "Invalid signature"
        );

        _validateAndAddHash(offerHash);

        // Reduce maker's balance
        _decreaseBalanceAndPayFees(
            _maker,
            _offerAsset,
            _offerAmount,
            _feeAsset,
            _feeAmount,
            ReasonMakerGive,
            ReasonMakerFeeGive,
            ReasonMakerFeeReceive
        );

        // Store the offer
        Offer storage offer = offers[offerHash];
        offer.maker = _maker;
        offer.offerAsset = _offerAsset;
        offer.wantAsset = _wantAsset;
        offer.offerAmount = _offerAmount;
        offer.wantAmount = _wantAmount;
        offer.availableAmount = _offerAmount;
        offer.nonce = _nonce;

        emit Make(_maker, offerHash);
    }

    /// @notice Fills a offer that has been previously made using `makeOffer`.
    /// @dev Fill an offer with `_offerHash` by giving `_amountToTake` of
    /// the offers' `wantAsset` tokens.
    /// A fee of `_feeAmount` of `_feeAsset` tokens can be paid to the operator
    /// to cover orderbook maintenance and network costs.
    /// The hash of all parameters, prefixed with the operation name "fillOffer"
    /// must be signed by the `_filler` to validate the fill request.
    /// A nonce that is issued by the coordinator is used to prevent replay attacks.
    /// This operation can only be invoked by the coordinator in an Active state.
    /// @param _filler The address of the user that is filling the offer
    /// @param _offerHash The hash of the offer to fill
    /// @param _amountToTake The number of tokens to take from the offer
    /// @param _feeAsset The address of the token to use for fee payment
    /// @param _feeAmount The amount of tokens to pay as fees to the operator
    /// @param _nonce The nonce to prevent replay attacks
    /// @param _v The `v` component of the `_filler`'s signature
    /// @param _r The `r` component of the `_filler`'s signature
    /// @param _s The `s` component of the `_filler`'s signature
    function fillOffer(
        address _filler,
        bytes32 _offerHash,
        uint256 _amountToTake,
        address _feeAsset,
        uint256 _feeAmount,
        uint64 _nonce,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        external
        onlyCoordinator
        onlyActiveState
    {
        bytes32 msgHash = keccak256(
            abi.encodePacked(
                "fillOffer",
                _filler,
                _offerHash,
                _amountToTake,
                _feeAsset,
                _feeAmount,
                _nonce
            )
        );

        require(
            _recoverAddress(msgHash, _v, _r, _s) == _filler,
            "Invalid signature"
        );

        _validateAndAddHash(msgHash);

        _fill(_filler, _offerHash, _amountToTake, _feeAsset, _feeAmount);
    }

    /// @notice Fills multiple offers that have been previously made using `makeOffer`.
    /// @dev Fills multiple offers with hashes in `_offerHashes` for amounts in
    /// `_amountsToTake`. This method allows conserving of the base gas cost.
    /// A fee of `_feeAmount` of `_feeAsset`  tokens can be paid to the operator
    /// to cover orderbook maintenance and network costs.
    /// The hash of all parameters, prefixed with the operation name "fillOffers"
    /// must be signed by the maker to validate the fill request.
    /// A nonce that is issued by the coordinator is used to prevent replay attacks.
    /// This operation can only be invoked by the coordinator in an Active state.
    /// @param _filler The address of the user that is filling the offer
    /// @param _offerHashes The hashes of the offers to fill
    /// @param _amountsToTake The number of tokens to take for each offer
    /// (each index corresponds to the entry with the same index in _offerHashes)
    /// @param _feeAsset The address of the token to use for fee payment
    /// @param _feeAmount The amount of tokens to pay as fees to the operator
    /// @param _nonce The nonce to prevent replay attacks
    /// @param _v The `v` component of the `_filler`'s signature
    /// @param _r The `r` component of the `_filler`'s signature
    /// @param _s The `s` component of the `_filler`'s signature
    function fillOffers(
        address _filler,
        bytes32[] _offerHashes,
        uint256[] _amountsToTake,
        address _feeAsset,
        uint256 _feeAmount,
        uint64 _nonce,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        external
        onlyCoordinator
        onlyActiveState
    {
        require(
            _offerHashes.length > 0,
            'Invalid input'
        );
        require(
            _offerHashes.length == _amountsToTake.length,
            'Invalid inputs'
        );

        bytes32 msgHash = keccak256(
            abi.encodePacked(
                "fillOffers",
                _filler,
                _offerHashes,
                _amountsToTake,
                _feeAsset,
                _feeAmount,
                _nonce
            )
        );

        require(
            _recoverAddress(msgHash, _v, _r, _s) == _filler,
            "Invalid signature"
        );

        _validateAndAddHash(msgHash);

        for (uint32 i = 0; i < _offerHashes.length; i++) {
            _fill(_filler, _offerHashes[i], _amountsToTake[i], etherAddr, 0);
        }

        _paySeparateFees(
            _filler,
            _feeAsset,
            _feeAmount,
            ReasonFillerFeeGive,
            ReasonFillerFeeReceive
        );
    }

    /// @notice Cancels an offer that was preivously made using `makeOffer`.
    /// @dev Cancels the offer with `_offerHash`. An `_expectedAvailableAmount`
    /// is provided to allow the coordinator to ensure that the offer is not accidentally
    /// cancelled ahead of time (where there is a pending fill that has not been settled).
    /// The hash of the _offerHash, _feeAsset, `_feeAmount` prefixed with the
    /// operation name "cancel" must be signed by the offer maker to validate
    /// the cancellation request. Only the coordinator can invoke this operation.
    /// See `slowCancel` for cancellation without requiring the coordinator's
    /// involvement.
    /// @param _offerHash The hash of the offer to cancel
    /// @param _expectedAvailableAmount The number of tokens that should be present when cancelling
    /// @param _feeAsset The address of the token to use for fee payment
    /// @param _feeAmount The amount of tokens to pay as fees to the operator
    /// @param _v The `v` component of the offer maker's signature
    /// @param _r The `r` component of the offer maker's signature
    /// @param _s The `s` component of the offer maker's signature
    function cancel(
        bytes32 _offerHash,
        uint256 _expectedAvailableAmount,
        address _feeAsset,
        uint256 _feeAmount,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        external
        onlyCoordinator
    {
        require(
            _recoverAddress(keccak256(abi.encodePacked(
                "cancel",
                _offerHash,
                _feeAsset,
                _feeAmount
            )), _v, _r, _s) == offers[_offerHash].maker,
            "Invalid signature"
        );

        _cancel(_offerHash, _expectedAvailableAmount, _feeAsset, _feeAmount);
    }

    /// @notice Announces intent to cancel tokens using `slowCancel`
    /// @dev Allows a user to invoke `slowCancel` after a minimum of
    /// `cancelAnnounceDelay` seconds has passed.
    /// This announcement and delay is necessary so that the operator has time
    /// to respond if a user attempts to invoke a `slowCancel` even though
    /// the exchange is operating normally.
    /// In that case, the coordinator would simply stop matching the offer to
    /// viable counterparties the moment the `CancelAnnounce` is seen.
    /// @param _offerHash The hash of the offer that will be cancelled
    function announceCancel(bytes32 _offerHash)
        external
    {
        Offer memory offer = offers[_offerHash];

        require(
            offer.maker == msg.sender,
            "Invalid sender"
        );

        require(
            offer.availableAmount > 0,
            "Offer already cancelled"
        );

        uint256 canCancelAt = now + cancelAnnounceDelay;
        announcedCancellations[_offerHash] = canCancelAt;

        emit CancelAnnounce(offer.maker, _offerHash, canCancelAt);
    }

    /// @notice Cancel an offer without requiring the coordinator
    /// @dev This operation is meant to be used if the operator becomes "byzantine",
    /// so that users can still cancel offers in this contract, and withdraw tokens
    /// using `slowWithdraw`.
    /// The `announceCancel` operation has to be invoked first, and a minimum time of
    /// `cancelAnnounceDelay` seconds have to pass, before this operation can be carried out.
    /// Note that this direct on-chain cancellation is an atypical operation, and
    /// the normal `cancel` operation should be used in non-byzantine states.
    /// @param _offerHash The hash of the offer to cancel
    function slowCancel(bytes32 _offerHash)
        external
    {
        require(
            announcedCancellations[_offerHash] != 0 && announcedCancellations[_offerHash] <= now,
            "Insufficient delay"
        );

        delete announcedCancellations[_offerHash];

        Offer memory offer = offers[_offerHash];
        _cancel(_offerHash, offer.availableAmount, etherAddr, 0);
    }

    /// @notice Cancels an offer immediately once cancellation intent
    /// has been announced.
    /// @dev Can only be invoked by the coordinator. This allows
    /// the coordinator to quickly remove offers that it has already
    /// acknowledged, and move its offer book into a consistent state.
    function fastCancel(bytes32 _offerHash, uint256 _expectedAvailableAmount)
        external
        onlyCoordinator
    {
        require(
            announcedCancellations[_offerHash] != 0,
            "Missing annoncement"
        );

        delete announcedCancellations[_offerHash];

        _cancel(_offerHash, _expectedAvailableAmount, etherAddr, 0);
    }

    /// @notice Cancels an offer without requiring the owner's signature,
    /// so that the tokens can be withdrawn using `emergencyWithdraw`.
    /// @dev Can only be invoked in an Inactive state by the coordinator.
    /// This operation is meant to be used in emergencies only.
    function emergencyCancel(bytes32 _offerHash, uint256 _expectedAvailableAmount)
        external
        onlyCoordinator
        onlyInactiveState
    {
        _cancel(_offerHash, _expectedAvailableAmount, etherAddr, 0);
    }

    /// @notice Approve an address for spending any amount of
    /// any token from the `msg.sender`'s balances
    /// @dev Analogous to ERC-20 `approve`, with the following differences:
    ///     - `_spender` must be whitelisted by owner
    ///     - approval can be rescinded at a later time by the user
    ///       iff it has been removed from the whitelist
    ///     - spending amount is unlimited
    /// @param _spender The address to approve spending
    function approveSpender(address _spender)
        external
    {
        require(
            whitelistedSpenders[_spender],
            "Spender is not whitelisted"
        );

        approvedSpenders[msg.sender][_spender] = true;
        emit SpenderApprove(msg.sender, _spender);
    }

    /// @notice Rescinds a previous approval for spending the `msg.sender`'s contract balance.
    /// @dev Rescinds approval for a spender, after it has been removed from
    /// the `whitelistedSpenders` set. This allows an approval to be removed
    /// if both the owner and user agrees that the previously approved spender
    /// contract should no longer be used.
    /// @param _spender The address to rescind spending approval
    function rescindApproval(address _spender)
        external
    {
        require(
            approvedSpenders[msg.sender][_spender],
            "Spender has not been approved"
        );

        require(
            whitelistedSpenders[_spender] != true,
            "Spender must be removed from the whitelist"
        );

        delete approvedSpenders[msg.sender][_spender];
        emit SpenderRescind(msg.sender, _spender);
    }

    /// @notice Transfers tokens from one address to another
    /// @dev Analogous to ERC-20 `transferFrom`, with the following differences:
    ///     - the address of the token to transfer must be specified
    ///     - any amount of token can be transferred, as long as it is less or equal
    ///       to `_from`'s balance
    ///     - reason codes can be attached and they must not use reasons specified in
    ///       this contract
    /// @param _from The address to transfer tokens from
    /// @param _to The address to transfer tokens to
    /// @param _amount The number of tokens to transfer
    /// @param _token The address of the token to transfer
    /// @param _decreaseReason A reason code to emit in the `BalanceDecrease` event
    /// @param _increaseReason A reason code to emit in the `BalanceIncrease` event
    function spendFrom(
        address _from,
        address _to,
        uint256 _amount,
        address _token,
        uint8 _decreaseReason,
        uint8 _increaseReason
    )
        external
        unusedReasonCode(_decreaseReason)
        unusedReasonCode(_increaseReason)
    {
        require(
            approvedSpenders[_from][msg.sender],
            "Spender has not been approved"
        );

        _validateAddress(_to);

        balances[_from][_token] = balances[_from][_token].sub(_amount);
        emit BalanceDecrease(_from, _token, _amount, _decreaseReason);

        balances[_to][_token] = balances[_to][_token].add(_amount);
        emit BalanceIncrease(_to, _token, _amount, _increaseReason);
    }

    /// @dev Overrides ability to renounce ownership as this contract is
    /// meant to always have an owner.
    function renounceOwnership() public { require(false, "Cannot have no owner"); }

    /// @dev The actual withdraw logic that is used internally by multiple operations.
    function _withdraw(
        address _withdrawer,
        address _token,
        uint256 _amount,
        address _feeAsset,
        uint256 _feeAmount
    )
        private
    {
        // SafeMath.sub checks that balance is sufficient already
        _decreaseBalanceAndPayFees(
            _withdrawer,
            _token,
            _amount,
            _feeAsset,
            _feeAmount,
            ReasonWithdraw,
            ReasonWithdrawFeeGive,
            ReasonWithdrawFeeReceive
        );

        if (_token == etherAddr) // ether
        {
            _withdrawer.transfer(_amount);
        }
        else
        {
            _validateIsContract(_token);
            require(
                _token.call(
                    bytes4(keccak256("transfer(address,uint256)")), _withdrawer, _amount
                ),
                "transfer call failed"
            );
            require(
                _getSanitizedReturnValue(),
                "transfer failed"
            );
        }
    }

    /// @dev The actual fill logic that is used internally by multiple operations.
    function _fill(
        address _filler,
        bytes32 _offerHash,
        uint256 _amountToTake,
        address _feeAsset,
        uint256 _feeAmount
    )
        private
    {
        require(
            _amountToTake > 0,
            "Invalid input"
        );

        Offer storage offer = offers[_offerHash];
        require(
            offer.maker != _filler,
            "Invalid filler"
        );

        require(
            offer.availableAmount != 0,
            "Offer already filled"
        );

        uint256 amountToFill = (_amountToTake.mul(offer.wantAmount)).div(offer.offerAmount);

        // transfer amountToFill in fillAsset from filler to maker
        balances[_filler][offer.wantAsset] = balances[_filler][offer.wantAsset].sub(amountToFill);
        emit BalanceDecrease(_filler, offer.wantAsset, amountToFill, ReasonFillerGive);

        balances[offer.maker][offer.wantAsset] = balances[offer.maker][offer.wantAsset].add(amountToFill);
        emit BalanceIncrease(offer.maker, offer.wantAsset, amountToFill, ReasonMakerReceive);

        // deduct amountToTake in takeAsset from offer
        offer.availableAmount = offer.availableAmount.sub(_amountToTake);
        _increaseBalanceAndPayFees(
            _filler,
            offer.offerAsset,
            _amountToTake,
            _feeAsset,
            _feeAmount,
            ReasonFillerReceive,
            ReasonFillerFeeGive,
            ReasonFillerFeeReceive
        );
        emit Fill(_filler, _offerHash, amountToFill, _amountToTake, offer.maker);

        if (offer.availableAmount == 0)
        {
            delete offers[_offerHash];
        }
    }

    /// @dev The actual cancellation logic that is used internally by multiple operations.
    function _cancel(
        bytes32 _offerHash,
        uint256 _expectedAvailableAmount,
        address _feeAsset,
        uint256 _feeAmount
    )
        private
    {
        Offer memory offer = offers[_offerHash];

        require(
            offer.availableAmount > 0,
            "Offer already cancelled"
        );

        require(
            offer.availableAmount == _expectedAvailableAmount,
            "Invalid input"
        );

        delete offers[_offerHash];

        _increaseBalanceAndPayFees(
            offer.maker,
            offer.offerAsset,
            offer.availableAmount,
            _feeAsset,
            _feeAmount,
            ReasonCancel,
            ReasonCancelFeeGive,
            ReasonCancelFeeReceive
        );

        emit Cancel(offer.maker, _offerHash);
    }

    /// @dev Performs an `ecrecover` operation for signed message hashes
    /// in accordance to EIP-191.
    function _recoverAddress(bytes32 _hash, uint8 _v, bytes32 _r, bytes32 _s)
        private
        pure
        returns (address)
    {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, _hash));
        return ecrecover(prefixedHash, _v, _r, _s);
    }

    /// @dev Decreases a user's balance while adding a cut from the decrement
    /// to be paid as fees to the operator. Reason codes should be provided
    /// to be emitted with events for tracking.
    function _decreaseBalanceAndPayFees(
        address _user,
        address _token,
        uint256 _amount,
        address _feeAsset,
        uint256 _feeAmount,
        uint8 _reason,
        uint8 _feeGiveReason,
        uint8 _feeReceiveReason
    )
        private
    {
        uint256 totalAmount = _amount;

        if (_feeAsset == _token) {
            totalAmount = _amount.add(_feeAmount);
        }

        balances[_user][_token] = balances[_user][_token].sub(totalAmount);
        emit BalanceDecrease(_user, _token, totalAmount, _reason);

        _payFees(_user, _token, _feeAsset, _feeAmount, _feeGiveReason, _feeReceiveReason);
    }

    /// @dev Increases a user's balance while deducting a cut from the increment
    /// to be paid as fees to the operator. Reason codes should be provided
    /// to be emitted with events for tracking.
    function _increaseBalanceAndPayFees(
        address _user,
        address _token,
        uint256 _amount,
        address _feeAsset,
        uint256 _feeAmount,
        uint8 _reason,
        uint8 _feeGiveReason,
        uint8 _feeReceiveReason
    )
        private
    {
        uint256 totalAmount = _amount;

        if (_feeAsset == _token) {
            totalAmount = _amount.sub(_feeAmount);
        }

        balances[_user][_token] = balances[_user][_token].add(totalAmount);
        emit BalanceIncrease(_user, _token, totalAmount, _reason);

        _payFees(_user, _token, _feeAsset, _feeAmount, _feeGiveReason, _feeReceiveReason);
    }

    /// @dev Pays fees to the operator, attaching the specified reason codes
    /// to the emitted event, only deducting from the `_user` balance if the
    /// `_token` does not match `_feeAsset`.
    /// IMPORTANT: In the event that the `_token` matches `_feeAsset`,
    /// there should a reduction in balance increment carried out separately,
    /// to ensure balance consistency.
    function _payFees(
        address _user,
        address _token,
        address _feeAsset,
        uint256 _feeAmount,
        uint8 _feeGiveReason,
        uint8 _feeReceiveReason
    )
        private
    {
        if (_feeAmount == 0) {
            return;
        }

        // if the feeAsset does not match the token then the feeAmount needs to be separately deducted
        if (_feeAsset != _token) {
            balances[_user][_feeAsset] = balances[_user][_feeAsset].sub(_feeAmount);
            emit BalanceDecrease(_user, _feeAsset, _feeAmount, _feeGiveReason);
        }

        balances[operator][_feeAsset] = balances[operator][_feeAsset].add(_feeAmount);
        emit BalanceIncrease(operator, _feeAsset, _feeAmount, _feeReceiveReason);
    }

    /// @dev Pays fees to the operator, attaching the specified reason codes to the emitted event.
    function _paySeparateFees(
        address _user,
        address _feeAsset,
        uint256 _feeAmount,
        uint8 _feeGiveReason,
        uint8 _feeReceiveReason
    )
        private
    {
        if (_feeAmount == 0) {
            return;
        }

        balances[_user][_feeAsset] = balances[_user][_feeAsset].sub(_feeAmount);
        emit BalanceDecrease(_user, _feeAsset, _feeAmount, _feeGiveReason);

        balances[operator][_feeAsset] = balances[operator][_feeAsset].add(_feeAmount);
        emit BalanceIncrease(operator, _feeAsset, _feeAmount, _feeReceiveReason);
    }

    /// @dev Ensures that the address is a valid user address.
    function _validateAddress(address _address)
        private
        pure
    {
        require(
            _address != address(0),
            'Invalid address'
        );
    }

    /// @dev Ensures a hash hasn't been already used, which would mean
    /// a repeated set of arguments and nonce was used. This prevents
    /// replay attacks.
    function _validateAndAddHash(bytes32 _hash)
        private
    {
        require(
            usedHashes[_hash] != true,
            "hash already used"
        );

        usedHashes[_hash] = true;
    }

    /// @dev Ensure that the address is a deployed contract
    function _validateIsContract(address addr) private view {
        assembly {
            if iszero(extcodesize(addr)) { revert(0, 0) }
        }
    }

    /// @dev Fix for ERC-20 tokens that do not have proper return type
    /// See: https://github.com/ethereum/solidity/issues/4116
    /// https://medium.com/loopring-protocol/an-incompatibility-in-smart-contract-threatening-dapp-ecosystem-72b8ca5db4da
    /// https://github.com/sec-bit/badERC20Fix/blob/master/badERC20Fix.sol
    function _getSanitizedReturnValue()
        private
        pure
        returns (bool)
    {
        uint256 result = 0;
        assembly {
            switch returndatasize
            case 0 {    // this is an non-standard ERC-20 token
                result := 1 // assume success on no revert
            }
            case 32 {   // this is a standard ERC-20 token
                returndatacopy(0, 0, 32)
                result := mload(0)
            }
            default {   // this is not an ERC-20 token
                revert(0, 0) // revert for safety
            }
        }
        return result != 0;
    }
}

// File: contracts/BombBurner.sol

pragma solidity 0.4.25;




/// @title The BombBurner contract to burn 1% of tokens on approve+transfer
/// @author Switcheo Network
contract BombBurner {
    using SafeMath for uint256;

    // The Switcheo Broker contract
    BOMBv3 public bomb;
    Broker public broker;

    uint8 constant ReasonDepositBurnGive = 0x40;
    uint8 constant ReasonDepositBurnReceive = 0x41;

    // A record of deposits that will have 1% burnt
    mapping(address => uint256) public preparedBurnAmounts;
    mapping(address => bytes32) public preparedBurnHashes;

    event PrepareBurn(address indexed depositer, uint256 depositAmount, bytes32 indexed approvalTransactionHash, uint256 burnAmount);
    event ExecuteBurn(address indexed depositer, uint256 burnAmount, bytes32 indexed approvalTransactionHash);

    /// @notice Initializes the BombBurner contract
    constructor(address brokerAddress, address bombAddress)
        public
    {
        broker = Broker(brokerAddress);
        bomb = BOMBv3(bombAddress);
    }

    modifier onlyCoordinator() {
        require(
            msg.sender == address(broker.coordinator()),
            "Invalid sender"
        );
        _;
    }

    function prepareBurn(
        address _depositer,
        uint256 _depositAmount,
        bytes32 _approvalTransactionHash
    )
        external
        onlyCoordinator
    {
        require(
            _depositAmount > 0,
            "Invalid deposit amount"
        );

        require(
            bomb.allowance(_depositer, address(broker)) == _depositAmount,
            "Invalid approval amount"
        );

        preparedBurnAmounts[_depositer] = bomb.findOnePercent(_depositAmount);
        preparedBurnHashes[_depositer] = _approvalTransactionHash;

        emit PrepareBurn(_depositer, _depositAmount, _approvalTransactionHash, preparedBurnAmounts[_depositer]);
    }

    function executeBurn(
        address _depositer,
        uint256 _burnAmount,
        bytes32 _approvalTransactionHash
    )
        external
        onlyCoordinator
    {
        require(
            _burnAmount == preparedBurnAmounts[_depositer],
            "Invalid burn amount"
        );

        require(
            _approvalTransactionHash == preparedBurnHashes[_depositer],
            "Invalid approval transaction hash"
        );

        require(
            bomb.allowance(_depositer, address(broker)) == 0,
            "Invalid approved amount"
        );

        delete preparedBurnAmounts[_depositer];
        delete preparedBurnHashes[_depositer];

        broker.spendFrom(
            _depositer,
            address(this),
            _burnAmount,
            address(bomb),
            ReasonDepositBurnGive,
            ReasonDepositBurnReceive
        );

        emit ExecuteBurn(_depositer, _burnAmount, _approvalTransactionHash);
    }
}