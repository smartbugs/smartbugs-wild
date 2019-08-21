pragma solidity 0.5.8;

/**
 * Trickle is a decentralized program allowing people to create
 * secure fixed hourly rate agreements leveraging the power of blockchain technology.
 * Trickle works with any ERC20-compatible tokens on top of Ethereum, including stablecoins.
 *
 * Brought to you by DreamTeam <https://token.dreamteam.gg>.
 * Learn more about Trickle <https://github.com/dreamteam-gg/trickle-dapp>.
 * Access this DApp at <https://trickle.gg> or <http://zitros.github.io/trickle-dapp>.
 */
contract Trickle {

    using SafeMath for uint256;

    event AgreementCreated(
        uint256 indexed agreementId,
        address token,
        address indexed recipient,
        address indexed sender,
        uint256 start,
        uint256 duration,
        uint256 totalAmount,
        uint256 createdAt
    );
    event AgreementCanceled(
        uint256 indexed agreementId,
        address token,
        address indexed recipient,
        address indexed sender,
        uint256 start,
        uint256 duration,
        uint256 amountReleased,
        uint256 amountCanceled,
        uint256 canceledAt
    );
    event Withdraw(
        uint256 indexed agreementId,
        address token,
        address indexed recipient,
        address indexed sender,
        uint256 amountReleased,
        uint256 releasedAt
    );

    uint256 private lastAgreementId;

    struct Agreement {
        uint256 meta; // Metadata packs 3 values to save on storage:
                      // + uint48 start;    // Timestamp with agreement start. Up to year 999999+.
                      // + uint48 duration; // Agreement duration. Up to year 999999+.
                      // + uint160 token;   // Token address converted to uint.
        uint256 totalAmount;
        uint256 releasedAmount;
        address recipient;
        address sender;
    }

    mapping (uint256 => Agreement) private agreements;

    modifier agreementPartiesOnly(uint256 agreementId) {
        require (
            msg.sender == agreements[agreementId].sender ||
            msg.sender == agreements[agreementId].recipient,
            "Allowed only for agreement's sender or recipient"
        );
        _;
    }

    modifier validAgreement(uint256 agreementId) {
        require(agreements[agreementId].releasedAmount < agreements[agreementId].totalAmount, "Agreement is completed or does not exists");
        _;
    }

    function createAgreement(IERC20 token, address recipient, uint256 totalAmount, uint48 duration, uint48 start) external {
        require(duration > 0, "Duration must be greater than zero");
        require(totalAmount > 0, "Total Amount must be greater than zero");
        require(start > 0, "Start must be greater than zero");
        require(token != IERC20(0x0), "Token must be a valid Ethereum address");
        require(recipient != address(0x0), "Recipient must be a valid Ethereum address");

        uint256 agreementId = ++lastAgreementId;

        agreements[agreementId] = Agreement({
            meta: encodeMeta(start, duration, uint256(address(token))),
            recipient: recipient,
            totalAmount: totalAmount,
            sender: msg.sender,
            releasedAmount: 0
        });

        token.transferFrom(agreements[agreementId].sender, address(this), agreements[agreementId].totalAmount);

        emit AgreementCreated(
            agreementId,
            address(token),
            recipient,
            msg.sender,
            start,
            duration,
            totalAmount,
            block.timestamp
        );
    }

    function getAgreement(uint256 agreementId) external view returns (
        address token,
        address recipient,
        address sender,
        uint256 start,
        uint256 duration,
        uint256 totalAmount,
        uint256 releasedAmount
    ) {
        (start, duration, token) = decodeMeta(agreements[agreementId].meta);
        sender = agreements[agreementId].sender;
        totalAmount = agreements[agreementId].totalAmount;
        releasedAmount = agreements[agreementId].releasedAmount;
        recipient = agreements[agreementId].recipient;
    }

    function withdrawTokens(uint256 agreementId) public validAgreement(agreementId) {
        uint256 unreleased = withdrawableAmount(agreementId);
        require(unreleased > 0, "Nothing to withdraw");

        agreements[agreementId].releasedAmount = agreements[agreementId].releasedAmount.add(unreleased);
        (, , address token) = decodeMeta(agreements[agreementId].meta);
        IERC20(token).transfer(agreements[agreementId].recipient, unreleased);

        emit Withdraw(
            agreementId,
            token,
            agreements[agreementId].recipient,
            agreements[agreementId].sender,
            unreleased,
            block.timestamp
        );
    }

    function cancelAgreement(uint256 agreementId) external validAgreement(agreementId) agreementPartiesOnly(agreementId) {
        if (withdrawableAmount(agreementId) > 0) {
            withdrawTokens(agreementId);
        }

        uint256 releasedAmount = agreements[agreementId].releasedAmount;
        uint256 canceledAmount = agreements[agreementId].totalAmount.sub(releasedAmount);

        (uint256 start, uint256 duration, address token) = decodeMeta(agreements[agreementId].meta);

        agreements[agreementId].releasedAmount = agreements[agreementId].totalAmount;
        if (canceledAmount > 0) {
            IERC20(token).transfer(agreements[agreementId].sender, canceledAmount);
        }

        emit AgreementCanceled(
            agreementId,
            token,
            agreements[agreementId].recipient,
            agreements[agreementId].sender,
            start,
            duration,
            releasedAmount,
            canceledAmount,
            block.timestamp
        );
    }

    function withdrawableAmount(uint256 agreementId) public view returns (uint256) {
        return proportionalAmount(agreementId).sub(agreements[agreementId].releasedAmount);
    }

    function proportionalAmount(uint256 agreementId) private view returns (uint256) {
        (uint256 start, uint256 duration, ) = decodeMeta(agreements[agreementId].meta);
        if (block.timestamp >= start.add(duration)) {
            return agreements[agreementId].totalAmount;
        } else if (block.timestamp <= start) {
            return 0;
        } else {
            return agreements[agreementId].totalAmount.mul(
                block.timestamp.sub(start)
            ).div(duration);
        }
    }

    function encodeMeta(uint256 start, uint256 duration, uint256 token) private pure returns(uint256 result) {
        require(
            start < 2 ** 48 &&
            duration < 2 ** 48 &&
            token < 2 ** 160,
            "Start, Duration or Token Address provided have invalid values"
        );

        result = start;
        result |= duration << (48);
        result |= token << (48 + 48);

        return result;
    }

    function decodeMeta(uint256 meta) private pure returns(uint256 start, uint256 duration, address token) {
        start = uint48(meta);
        duration = uint48(meta >> (48));
        token = address(meta >> (48 + 48));
    }

}

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
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
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }

}

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