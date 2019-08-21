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

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: contracts/livepeerInterface/IController.sol

pragma solidity ^0.5.7;

contract IController  {
    event SetContractInfo(bytes32 id, address contractAddress, bytes20 gitCommitHash);

    function setContractInfo(bytes32 _id, address _contractAddress, bytes20 _gitCommitHash) external;
    function updateController(bytes32 _id, address _controller) external;
    function getContract(bytes32 _id) public view returns (address);
}

// File: contracts/livepeerInterface/IBondingManager.sol

pragma solidity ^0.5.1;

contract IBondingManager {

    function unbondingPeriod() public view returns (uint64);

}

// File: contracts/livepeerInterface/IRoundsManager.sol

pragma solidity ^0.5.1;

contract IRoundsManager {

    function roundLength() public view returns (uint256);

}

// File: contracts/LptOrderBook.sol

pragma solidity ^0.5.7;






contract LptOrderBook {

    using SafeMath for uint256;

    address private constant ZERO_ADDRESS = address(0);

    string internal constant ERROR_SELL_ORDER_COMMITTED_TO = "LPT_ORDER_SELL_ORDER_COMMITTED_TO";
    string internal constant ERROR_SELL_ORDER_NOT_COMMITTED_TO = "LPT_ORDER_SELL_ORDER_NOT_COMMITTED_TO";
    string internal constant ERROR_INITIALISED_ORDER = "LPT_ORDER_INITIALISED_ORDER";
    string internal constant ERROR_UNINITIALISED_ORDER = "LPT_ORDER_UNINITIALISED_ORDER";
    string internal constant ERROR_COMMITMENT_WITHIN_UNBONDING_PERIOD = "LPT_ORDER_COMMITMENT_WITHIN_UNBONDING_PERIOD";
    string internal constant ERROR_NOT_BUYER = "LPT_ORDER_NOT_BUYER";
    string internal constant ERROR_STILL_WITHIN_LOCK_PERIOD = "LPT_ORDER_STILL_WITHIN_LOCK_PERIOD";

    struct LptSellOrder {
        uint256 lptSellValue;
        uint256 daiPaymentValue;
        uint256 daiCollateralValue;
        uint256 deliveredByBlock;
        address buyerAddress;
    }

    IController livepeerController;
    IERC20 daiToken;
    mapping(address => LptSellOrder) public lptSellOrders; // One sell order per address for simplicity

    constructor(address _livepeerController, address _daiToken) public {
        livepeerController = IController(_livepeerController);
        daiToken = IERC20(_daiToken);
    }

    /*
    * @notice Create an LPT sell order, requires approval for this contract to spend _daiCollateralValue amount of DAI.
    * @param _lptSellValue Value of LPT to sell
    * @param _daiPaymentValue Value required in exchange for LPT
    * @param _daiCollateralValue Value of collateral
    * @param _deliveredByBlock Order filled or cancelled by this block or the collateral can be claimed
    */
    function createLptSellOrder(uint256 _lptSellValue, uint256 _daiPaymentValue, uint256 _daiCollateralValue, uint256 _deliveredByBlock) public {
        LptSellOrder storage lptSellOrder = lptSellOrders[msg.sender];

        require(lptSellOrder.daiCollateralValue == 0, ERROR_INITIALISED_ORDER);

        daiToken.transferFrom(msg.sender, address(this), _daiCollateralValue);

        lptSellOrders[msg.sender] = LptSellOrder(_lptSellValue, _daiPaymentValue, _daiCollateralValue, _deliveredByBlock, ZERO_ADDRESS);
    }

    /*
    * @notice Cancel an LPT sell order, must be executed by the sell order creator.
    */
    function cancelLptSellOrder() public {
        LptSellOrder storage lptSellOrder = lptSellOrders[msg.sender];

        require(lptSellOrder.buyerAddress == ZERO_ADDRESS, ERROR_SELL_ORDER_COMMITTED_TO);

        daiToken.transfer(msg.sender, lptSellOrder.daiCollateralValue);
        delete lptSellOrders[msg.sender];
    }

    /*
    * @notice Commit to buy LPT, requires approval for this contract to spend the payment amount in DAI.
    * @param _sellOrderCreator Address of sell order creator
    */
    function commitToBuyLpt(address _sellOrderCreator) public {
        LptSellOrder storage lptSellOrder = lptSellOrders[_sellOrderCreator];

        require(lptSellOrder.lptSellValue > 0, ERROR_UNINITIALISED_ORDER);
        require(lptSellOrder.buyerAddress == ZERO_ADDRESS, ERROR_SELL_ORDER_COMMITTED_TO);
        require(lptSellOrder.deliveredByBlock.sub(_getUnbondingPeriodLength()) > block.number, ERROR_COMMITMENT_WITHIN_UNBONDING_PERIOD);

        daiToken.transferFrom(msg.sender, address(this), lptSellOrder.daiPaymentValue);

        lptSellOrder.buyerAddress = msg.sender;
    }

    /*
    * @notice Claim collateral and payment after a sell order has been committed to but it hasn't been delivered by
    *         the block number specified.
    * @param _sellOrderCreator Address of sell order creator
    */
    function claimCollateralAndPayment(address _sellOrderCreator) public {
        LptSellOrder storage lptSellOrder = lptSellOrders[_sellOrderCreator];

        require(lptSellOrder.buyerAddress == msg.sender, ERROR_NOT_BUYER);
        require(lptSellOrder.deliveredByBlock < block.number, ERROR_STILL_WITHIN_LOCK_PERIOD);

        uint256 totalValue = lptSellOrder.daiPaymentValue.add(lptSellOrder.daiCollateralValue);
        daiToken.transfer(msg.sender, totalValue);
    }

    /*
    * @notice Fulfill sell order, requires approval for this contract spend the orders LPT value from the seller.
    *         Returns the collateral and payment to the LPT seller.
    */
    function fulfillSellOrder() public {
        LptSellOrder storage lptSellOrder = lptSellOrders[msg.sender];

        require(lptSellOrder.buyerAddress != ZERO_ADDRESS, ERROR_SELL_ORDER_NOT_COMMITTED_TO);

        IERC20 livepeerToken = IERC20(_getLivepeerContractAddress("LivepeerToken"));livepeerToken.transferFrom(msg.sender, lptSellOrder.buyerAddress, lptSellOrder.lptSellValue);

        uint256 totalValue = lptSellOrder.daiPaymentValue.add(lptSellOrder.daiCollateralValue);
        daiToken.transfer(msg.sender, totalValue);

        delete lptSellOrders[msg.sender];
    }

    function _getLivepeerContractAddress(string memory _livepeerContract) internal view returns (address) {
        bytes32 contractId = keccak256(abi.encodePacked(_livepeerContract));
        return livepeerController.getContract(contractId);
    }

    function _getUnbondingPeriodLength() internal view returns (uint256) {
        IBondingManager bondingManager = IBondingManager(_getLivepeerContractAddress("BondingManager"));
        uint64 unbondingPeriodRounds = bondingManager.unbondingPeriod();

        IRoundsManager roundsManager = IRoundsManager(_getLivepeerContractAddress("RoundsManager"));
        uint256 roundLength = roundsManager.roundLength();

        return roundLength.mul(unbondingPeriodRounds);
    }
}