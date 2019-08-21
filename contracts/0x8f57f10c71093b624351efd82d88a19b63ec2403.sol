pragma solidity ^0.5.4;

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
}

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);
}

/**
 * @title MultiBeneficiariesTokenTimelock
 * @dev MultiBeneficiariesTokenTimelock is a token holder contract that will allow a
 * beneficiaries to extract the tokens after a given release time
 */
contract MultiBeneficiariesTokenTimelock {
    using SafeERC20 for IERC20;

    // ERC20 basic token contract being held
    IERC20 public token;

    // beneficiary of tokens after they are released
    address[] public beneficiaries;
    
    // token amounts of beneficiaries to be released
    uint256[] public tokenValues;

    // timestamp when token release is enabled
    uint256 public releaseTime;
    
    //Whether tokens have been distributed
    bool public distributed;

    constructor(
        IERC20 _token,
        address[] memory _beneficiaries,
        uint256[] memory _tokenValues,
        uint256 _releaseTime
    )
    public
    {
        require(_releaseTime > block.timestamp);
        releaseTime = _releaseTime;
        require(_beneficiaries.length == _tokenValues.length);
        beneficiaries = _beneficiaries;
        tokenValues = _tokenValues;
        token = _token;
        distributed = false;
    }

    /**
     * @notice Transfers tokens held by timelock to beneficiaries.
     */
    function release() public {
        require(block.timestamp >= releaseTime);
        require(!distributed);

        for (uint256 i = 0; i < beneficiaries.length; i++) {
            address beneficiary = beneficiaries[i];
            uint256 amount = tokenValues[i];
            require(amount > 0);
            token.safeTransfer(beneficiary, amount);
        }
        
        distributed = true;
    }
    
    /**
     * Returns the time remaining until release
     */
    function getTimeLeft() public view returns (uint256 timeLeft){
        if (releaseTime > block.timestamp) {
            return releaseTime - block.timestamp;
        }
        return 0;
    }
    
    /**
     * Reject ETH 
     */
    function() external payable {
        revert();
    }
}