pragma solidity 0.5.4;


/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
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
       
        require(b > 0);
        uint256 c = a / b;
       
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
* @title interface of ERC 20 token
* 
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
     * @notice Warning!!!! only be used when owner address is compromised
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
contract TokenVesting is Ownable{
    
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    struct VestedToken{
        uint256 cliff;
        uint256 start;
        uint256 duration;
        uint256 releasedToken;
        uint256 totalToken;
        bool revoked;
    }
    
    mapping (address => VestedToken) public vestedUser; 
    
    // default Vesting parameter values
    uint256 private _cliff = 2592000; // 30 days period
    uint256 private _duration = 93312000; // for 3 years
    bool private _revoked = false;
    
    IERC20 public LCXToken;
    
    event TokenReleased(address indexed account, uint256 amount);
    event VestingRevoked(address indexed account);
    
    /**
     * @dev Its a modifier in which we authenticate the caller is owner or LCXToken Smart Contract
     */ 
    modifier onlyLCXTokenAndOwner() {
        require(msg.sender==owner() || msg.sender == address(LCXToken));
        _;
    }
    
    /**
     * @dev First we have to set token address before doing any thing 
     * @param token LCX Smart contract Address
     */
     
    function setTokenAddress(IERC20 token) public onlyOwner returns(bool){
        LCXToken = token;
        return true;
    }
    
    /**
     * @dev this will set the beneficiary with default vesting 
     * parameters ie, every month for 3 years
     * @param account address of the beneficiary for vesting
     * @param amount  totalToken to be vested
     */
     
     function setDefaultVesting(address account, uint256 amount) public onlyLCXTokenAndOwner returns(bool){
         _setDefaultVesting(account, amount);
         return true;
     }
     
     /**
      *@dev Internal function to set default vesting parameters
      */
      
     function _setDefaultVesting(address account, uint256 amount)  internal {
         require(account!=address(0));
         VestedToken storage vested = vestedUser[account];
         vested.cliff = _cliff;
         vested.start = block.timestamp;
         vested.duration = _duration;
         vested.totalToken = amount;
         vested.releasedToken = 0;
         vested.revoked = _revoked;
     }
     
     
     /**
     * @dev this will set the beneficiary with vesting 
     * parameters provided
     * @param account address of the beneficiary for vesting
     * @param amount  totalToken to be vested
     * @param cliff In seconds of one period in vesting
     * @param duration In seconds of total vesting 
     * @param startAt UNIX timestamp in seconds from where vesting will start
     */
     
     function setVesting(address account, uint256 amount, uint256 cliff, uint256 duration, uint256 startAt ) public onlyLCXTokenAndOwner  returns(bool){
         _setVesting(account, amount, cliff, duration, startAt);
         return true;
     }
     
     /**
      * @dev Internal function to set default vesting parameters
      * @param account address of the beneficiary for vesting
      * @param amount  totalToken to be vested
      * @param cliff In seconds of one period in vestin
      * @param duration In seconds of total vesting duration
      * @param startAt UNIX timestamp in seconds from where vesting will start
      *
      */
     
     function _setVesting(address account, uint256 amount, uint256 cliff, uint256 duration, uint256 startAt) internal {
         
         require(account!=address(0));
         require(cliff<=duration);
         VestedToken storage vested = vestedUser[account];
         vested.cliff = cliff;
         vested.start = startAt;
         vested.duration = duration;
         vested.totalToken = amount;
         vested.releasedToken = 0;
         vested.revoked = false;
     }

    /**
     * @notice Transfers vested tokens to beneficiary.
     * anyone can release their token 
     */
     
    function releaseMyToken() public returns(bool) {
        releaseToken(msg.sender);
        return true;
    }
    
     /**
     * @notice Transfers vested tokens to the given account.
     * @param account address of the vested user
     */
    function releaseToken(address account) public {
       require(account != address(0));
       VestedToken storage vested = vestedUser[account];
       uint256 unreleasedToken = _releasableAmount(account);  // total releasable token currently
       require(unreleasedToken>0);
       vested.releasedToken = vested.releasedToken.add(unreleasedToken);
       LCXToken.safeTransfer(account,unreleasedToken);
       emit TokenReleased(account, unreleasedToken);
    }
    
    /**
     * @dev Calculates the amount that has already vested but hasn't been released yet.
     * @param account address of user
     */
    function _releasableAmount(address account) internal view returns (uint256) {
        return _vestedAmount(account).sub(vestedUser[account].releasedToken);
    }

  
    /**
     * @dev Calculates the amount that has already vested.
     * @param account address of the user
     */
    function _vestedAmount(address account) internal view returns (uint256) {
        VestedToken storage vested = vestedUser[account];
        uint256 totalToken = vested.totalToken;
        if(block.timestamp <  vested.start.add(vested.cliff)){
            return 0;
        }else if(block.timestamp >= vested.start.add(vested.duration) || vested.revoked){
            return totalToken;
        }else{
            uint256 numberOfPeriods = (block.timestamp.sub(vested.start)).div(vested.cliff);
            return totalToken.mul(numberOfPeriods.mul(vested.cliff)).div(vested.duration);
        }
    }
    
    /**
     * @notice Allows the owner to revoke the vesting. Tokens already vested
     * remain in the contract, the rest are returned to the owner.
     * @param account address in which the vesting is revoked
     */
    function revoke(address account) public onlyOwner {
        VestedToken storage vested = vestedUser[account];
        require(!vested.revoked);
        uint256 balance = vested.totalToken;
        uint256 unreleased = _releasableAmount(account);
        uint256 refund = balance.sub(unreleased);
        vested.revoked = true;
        vested.totalToken = unreleased;
        LCXToken.safeTransfer(owner(), refund);
        emit VestingRevoked(account);
    }
    
    
    
    
}