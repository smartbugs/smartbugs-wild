/*
Implements a rate oracle (for EUR/ETH)
Operated by Capacity Blockchain Solutions GmbH.
No warranties.
*/
// File: openzeppelin-solidity\contracts\token\ERC20\IERC20.sol

pragma solidity ^0.5.2;

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
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

// File: openzeppelin-solidity\contracts\math\SafeMath.sol

pragma solidity ^0.5.2;

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

// File: contracts\OracleRequest.sol

/*
Interface for requests to the rate oracle (for EUR/ETH)
Copy this to projects that need to access the oracle.
See rate-oracle project for implementation.
*/
pragma solidity ^0.5.0;


contract OracleRequest {

    uint256 public EUR_WEI; //number of wei per EUR

    uint256 public lastUpdate; //timestamp of when the last update occurred

    function ETH_EUR() public view returns (uint256); //number of EUR per ETH (rounded down!)

    function ETH_EURCENT() public view returns (uint256); //number of EUR cent per ETH (rounded down!)

}

// File: contracts\Oracle.sol

/*
Implements a rate oracle (for EUR/ETH)
*/
pragma solidity ^0.5.0;




contract Oracle is OracleRequest {
    using SafeMath for uint256;

    address public rateControl;

    address public tokenAssignmentControl;

    constructor(address _rateControl, address _tokenAssignmentControl)
    public
    {
        lastUpdate = 0;
        rateControl = _rateControl;
        tokenAssignmentControl = _tokenAssignmentControl;
    }

    modifier onlyRateControl()
    {
        require(msg.sender == rateControl, "rateControl key required for this function.");
        _;
    }

    modifier onlyTokenAssignmentControl() {
        require(msg.sender == tokenAssignmentControl, "tokenAssignmentControl key required for this function.");
        _;
    }

    function setRate(uint256 _new_EUR_WEI)
    public
    onlyRateControl
    {
        lastUpdate = now;
        require(_new_EUR_WEI > 0, "Please assign a valid rate.");
        EUR_WEI = _new_EUR_WEI;
    }

    function ETH_EUR()
    public view
    returns (uint256)
    {
        return uint256(1 ether).div(EUR_WEI);
    }

    function ETH_EURCENT()
    public view
    returns (uint256)
    {
        return uint256(100 ether).div(EUR_WEI);
    }

    /*** Make sure currency doesn't get stranded in this contract ***/

    // If this contract gets a balance in some ERC20 contract after it's finished, then we can rescue it.
    function rescueToken(IERC20 _foreignToken, address _to)
    public
    onlyTokenAssignmentControl
    {
        _foreignToken.transfer(_to, _foreignToken.balanceOf(address(this)));
    }

    // Make sure this contract cannot receive ETH.
    function() external
    payable
    {
        revert("The contract cannot receive ETH payments.");
    }
}