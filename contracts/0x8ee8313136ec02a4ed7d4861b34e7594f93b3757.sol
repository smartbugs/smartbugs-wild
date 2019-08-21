pragma solidity >=0.4.14 <0.6.0;

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
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

/**
 * @title WhitelistAdminRole
 * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.
 */
contract WhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    constructor () internal {
        _addWhitelistAdmin(msg.sender);
    }

    modifier onlyWhitelistAdmin() {
        require(isWhitelistAdmin(msg.sender));
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {
        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {
        _removeWhitelistAdmin(msg.sender);
    }

    function _addWhitelistAdmin(address account) internal {
        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
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
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(address(this), spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}


/// @author QuarkChain Eng Team
/// @title A simplified term deposit contract for ERC20 tokens
contract TermDepositSimplified is WhitelistAdminRole {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event DoDeposit(address indexed depositor, uint256 amount);
    event Withdraw(address indexed depositor, uint256 amount);
    event Drain(address indexed admin);
    event Pause(address indexed admin, bool isPaused);
    event Goodbye(address indexed admin, uint256 amount);

    uint256 public constant MIN_DEPOSIT = 100 * 1e18;  // => 100 QKC.
    // Pre-defined terms.
    bytes4 public constant TERM_2MO = "2mo";
    bytes4 public constant TERM_4MO = "4mo";
    bytes4 public constant TERM_6MO = "6mo";

    struct TermDepositInfo {
        uint256 duration;
        uint256 totalReceived;
        mapping (address => Deposit[]) deposits;
    }

    struct Deposit {
        uint256 amount;
        uint256 depositAt;
        uint256 withdrawAt;
    }

    mapping (bytes4 => TermDepositInfo) private _termDeposits;
    IERC20 private _token;
    bool   private _isPaused = false;

    bytes4[] public allTerms = [TERM_2MO, TERM_4MO, TERM_6MO];

    /// Constructor for the term deposit contract.
    /// @param token ERC20 token addresses for term deposit
    constructor(IERC20 token) public {
        uint256 monthInSec = 2635200;
        _token = token;

        _termDeposits[TERM_2MO] = TermDepositInfo({
            duration: 2 * monthInSec,
            totalReceived: 0
        });

        _termDeposits[TERM_4MO] = TermDepositInfo({
            duration: 4 * monthInSec,
            totalReceived: 0
        });

        _termDeposits[TERM_6MO] = TermDepositInfo({
            duration: 6 * monthInSec,
            totalReceived: 0
        });
    }

    /// Getter for token address.
    /// @return the token address
    function token() public view returns (IERC20) {
        return _token;
    }

    /// Return a term deposit's key properties.
    /// @param term the byte representation of terms
    /// @return a list of deposit overview info
    function getTermDepositInfo(bytes4 term) public view returns (uint256[2] memory) {
        TermDepositInfo memory info = _termDeposits[term];
        require(info.duration > 0, "should be a valid term");
        return [
            info.duration,
            info.totalReceived
        ];
    }

    /// Deposit users tokens into this contract.
    /// @param term the byte representation of terms
    /// @param amount token amount in wei
    function deposit(bytes4 term, uint256 amount) public {
        require(!_isPaused, "deposit not allowed when contract is paused");
        require(amount >= MIN_DEPOSIT, "should have amount >= minimum");
        TermDepositInfo storage info = _termDeposits[term];
        require(info.duration > 0, "should be a valid term");

        Deposit[] storage deposits = info.deposits[msg.sender];
        deposits.push(Deposit({
            amount: amount,
            depositAt: now,
            withdrawAt: 0
        }));
        info.totalReceived = info.totalReceived.add(amount);
        emit DoDeposit(msg.sender, amount);

        _token.safeTransferFrom(msg.sender, address(this), amount);
    }

    /// Calculate amount of tokens a user has deposited.
    /// @param depositor the address of the depositor
    /// @param terms the list of byte representation of terms
    /// @param withdrawable boolean flag for whether to require withdrawable
    /// @return amount of tokens available for withdrawal
    function getDepositAmount(
        address depositor,
        bytes4[] memory terms,
        bool withdrawable
    ) public view returns (uint256[] memory)
    {
        uint256[] memory ret = new uint256[](terms.length);
        for (uint256 i = 0; i < terms.length; i++) {
            TermDepositInfo storage info = _termDeposits[terms[i]];
            require(info.duration > 0, "should be a valid term");
            Deposit[] memory deposits = info.deposits[depositor];

            uint256 total = 0;
            for (uint256 j = 0; j < deposits.length; j++) {
                uint256 lockUntil = deposits[j].depositAt.add(info.duration);
                if (deposits[j].withdrawAt == 0) {
                    if (!withdrawable || now >= lockUntil) {
                        total = total.add(deposits[j].amount);
                    }
                }
            }
            ret[i] = total;
        }
        return ret;
    }

    /// Get detailed deposit information of a user.
    /// @param depositor the address of the depositor
    /// @param terms the list of byte representation of terms
    /// @return 1 array for terms, 3 arrays of deposit amounts, deposit / withdrawal timestamps
    function getDepositDetails(
        address depositor,
        bytes4[] memory terms
    ) public view returns (bytes4[] memory, uint256[] memory, uint256[] memory, uint256[] memory)
    {
        Deposit[][] memory depositListByTerms = new Deposit[][](terms.length);

        // Collect count first because dynamic array in memory is not allowed.
        uint256 totalDepositCount = 0;
        for (uint256 i = 0; i < terms.length; i++) {
            bytes4 term = terms[i];
            TermDepositInfo storage info = _termDeposits[term];
            require(info.duration > 0, "should be a valid term");
            Deposit[] memory deposits = info.deposits[depositor];
            depositListByTerms[i] = deposits;
            totalDepositCount = totalDepositCount.add(deposits.length);
        }

        bytes4[] memory depositTerms = new bytes4[](totalDepositCount);
        uint256[] memory amounts = new uint256[](totalDepositCount);
        uint256[] memory depositTs = new uint256[](totalDepositCount);
        uint256[] memory withdrawTs = new uint256[](totalDepositCount);
        uint256 retIndex = 0;
        for (uint256 i = 0; i < depositListByTerms.length; i++) {
            Deposit[] memory deposits = depositListByTerms[i];
            for (uint256 j = 0; j < deposits.length; j++) {
                depositTerms[retIndex] = terms[i];
                Deposit memory d = deposits[j];
                amounts[retIndex] = d.amount;
                depositTs[retIndex] = d.depositAt;
                withdrawTs[retIndex] = d.withdrawAt;
                retIndex += 1;
            }
        }
        assert(retIndex == totalDepositCount);
        return (depositTerms, amounts, depositTs, withdrawTs);
    }

    /// Withdraw a user's tokens plus interest to his/her own address.
    /// @param terms the list of byte representation of terms
    /// @return whether have withdrawn some tokens successfully
    function withdraw(bytes4[] memory terms) public returns (bool) {
        require(!_isPaused, "withdraw not allowed when contract is paused");

        uint256 total = 0;
        for (uint256 i = 0; i < terms.length; i++) {
            bytes4 term = terms[i];
            TermDepositInfo storage info = _termDeposits[term];
            require(info.duration > 0, "should be a valid term");
            Deposit[] storage deposits = info.deposits[msg.sender];

            uint256 termTotal = 0;
            for (uint256 j = 0; j < deposits.length; j++) {
                uint256 lockUntil = deposits[j].depositAt.add(info.duration);
                if (deposits[j].withdrawAt == 0 && now >= lockUntil) {
                    termTotal = termTotal.add(deposits[j].amount);
                    deposits[j].withdrawAt = now;
                }
            }

            info.totalReceived = info.totalReceived.sub(termTotal);
            total = total.add(termTotal);
        }

        if (total == 0) {
            return false;
        }
        emit Withdraw(msg.sender, total);
        _token.safeTransfer(msg.sender, total);
        return true;
    }

    /// Return necessary amount of tokens to cover interests and referral bonuses.
    /// @param terms the list of byte representation of terms
    /// @return total deposit
    function calculateTotalPayout(bytes4[] memory terms) public view returns (uint256) {
        // [deposit, interest, bonus].
        uint256 ret;
        for (uint256 i = 0; i < terms.length; i++) {
            TermDepositInfo memory info = _termDeposits[terms[i]];
            require(info.duration > 0, "should be a valid term");
            ret = ret.add(info.totalReceived);
        }
        return ret;
    }

    /// Leave enough tokens for payout, and drain the surplus.
    /// @dev only admins can call this function
    function drainSurplusTokens() external onlyWhitelistAdmin {
        emit Drain(msg.sender);

        uint256 neededAmount = calculateTotalPayout(allTerms);
        uint256 currentAmount = _token.balanceOf(address(this));
        if (currentAmount > neededAmount) {
            uint256 surplus = currentAmount.sub(neededAmount);
            _token.safeTransfer(msg.sender, surplus);
        }
    }

    /// Pause deposit and withdraw
    /// @dev only admins can call this function
    function pause(bool isPaused) external onlyWhitelistAdmin {
        _isPaused = isPaused;

        emit Pause(msg.sender, _isPaused);
    }

    /// Drain remaining tokens and destroys the contract to save some space for the network.
    /// @dev only admins can call this function
    function goodbye() external onlyWhitelistAdmin {
        // Make sure is after deposit deadline, and no received tokens.
        for (uint256 i = 0; i < allTerms.length; i++) {
            bytes4 term = allTerms[i];
            TermDepositInfo memory info = _termDeposits[term];
            require(info.totalReceived < 1000 * 1e18, "should have small enough deposits");
        }
        // Transfer remaining tokens.
        uint256 tokenAmount = _token.balanceOf(address(this));
        emit Goodbye(msg.sender, tokenAmount);
        if (tokenAmount > 0) {
            _token.safeTransfer(msg.sender, tokenAmount);
        }
        // Say goodbye.
        selfdestruct(msg.sender);
    }
}