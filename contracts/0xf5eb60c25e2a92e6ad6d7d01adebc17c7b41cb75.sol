pragma solidity 0.5.3;

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
        require((value == 0) || (token.allowance(msg.sender, spender) == 0));
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

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
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
    function isOwner() public view returns (bool) {
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

/**
 * @title TokenDistributor
 * @dev This contract is a token holder contract that will 
 * allow beneficiaries to release the tokens in ten six-months period intervals.
 */
contract TokenDistributor is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event TokensReleased(address account, uint256 amount);

    // ERC20 basic token contract being held
    IERC20 private _token;

    // timestamp when token release is enabled
    uint256 private _releaseTime;

    uint256 private _totalReleased;
    mapping(address => uint256) private _released;

    // beneficiary of tokens that are released
    address private _beneficiary1;
    address private _beneficiary2;
    address private _beneficiary3;
    address private _beneficiary4;

    uint256 public releasePerStep = uint256(1000000) * 10 ** 18;

    /**
     * @dev Constructor
     */
    constructor (IERC20 token, uint256 releaseTime, address beneficiary1, address beneficiary2, address beneficiary3, address beneficiary4) public {
        _token = token;
        _releaseTime = releaseTime;
        _beneficiary1 = beneficiary1;
        _beneficiary2 = beneficiary2;
        _beneficiary3 = beneficiary3;
        _beneficiary4 = beneficiary4;
    }

    /**
     * @return the token being held.
     */
    function token() public view returns (IERC20) {
        return _token;
    }

    /**
     * @return the total amount already released.
     */
    function totalReleased() public view returns (uint256) {
        return _totalReleased;
    }

    /**
     * @return the amount already released to an account.
     */
    function released(address account) public view returns (uint256) {
        return _released[account];
    }

    /**
     * @return the beneficiary1 of the tokens.
     */
    function beneficiary1() public view returns (address) {
        return _beneficiary1;
    }

    /**
     * @return the beneficiary2 of the tokens.
     */
    function beneficiary2() public view returns (address) {
        return _beneficiary2;
    }

    /**
     * @return the beneficiary3 of the tokens.
     */
    function beneficiary3() public view returns (address) {
        return _beneficiary3;
    }

    /**
     * @return the beneficiary4 of the tokens.
     */
    function beneficiary4() public view returns (address) {
        return _beneficiary4;
    }

    /**
     * @return the time when the tokens are released.
     */
    function releaseTime() public view returns (uint256) {
        return _releaseTime;
    }

    /**
     * @dev Release one of the beneficiary's tokens.
     * @param account Whose tokens will be sent to.
     * @param amount Value in wei to send to the account.
     */
    function releaseToAccount(address account, uint256 amount) internal {
        require(amount != 0, 'The amount must be greater than zero.');

        _released[account] = _released[account].add(amount);
        _totalReleased = _totalReleased.add(amount);

        _token.safeTransfer(account, amount);
        emit TokensReleased(account, amount);
    }

    /**
     * @notice Transfers 1000000 tokens in each interval(six-months timelocks) to beneficiaries.
     */
    function release() onlyOwner public {
        require(block.timestamp >= releaseTime(), 'Team�s tokens can be released every six months.');

        uint256 _value1 = releasePerStep.mul(10).div(100);      //10%
        uint256 _value2 = releasePerStep.mul(68).div(100);      //68%
        uint256 _value3 = releasePerStep.mul(12).div(100);      //12%
        uint256 _value4 = releasePerStep.mul(10).div(100);      //10%

        _releaseTime = _releaseTime.add(180 days);

        releaseToAccount(_beneficiary1, _value1);
        releaseToAccount(_beneficiary2, _value2);
        releaseToAccount(_beneficiary3, _value3);
        releaseToAccount(_beneficiary4, _value4);
    }
}