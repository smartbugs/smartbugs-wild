pragma solidity ^0.5.0;

interface SwapInterface {
    // Public variables
    function brokerFees(address _broker) external view returns (uint256);
    function redeemedAt(bytes32 _swapID) external view returns(uint256);

    /// @notice Initiates the atomic swap.
    ///
    /// @param _swapID The unique atomic swap id.
    /// @param _spender The address of the withdrawing trader.
    /// @param _secretLock The hash of the secret (Hash Lock).
    /// @param _timelock The unix timestamp when the swap expires.
    /// @param _value The value of the atomic swap.
    function initiate(
        bytes32 _swapID,
        address payable _spender,
        bytes32 _secretLock,
        uint256 _timelock,
        uint256 _value
    ) external payable;

    /// @notice Initiates the atomic swap with broker fees.
    ///
    /// @param _swapID The unique atomic swap id.
    /// @param _spender The address of the withdrawing trader.
    /// @param _broker The address of the broker.
    /// @param _brokerFee The fee to be paid to the broker on success.
    /// @param _secretLock The hash of the secret (Hash Lock).
    /// @param _timelock The unix timestamp when the swap expires.
    /// @param _value The value of the atomic swap.
    function initiateWithFees(
        bytes32 _swapID,
        address payable _spender,
        address payable _broker,
        uint256 _brokerFee,
        bytes32 _secretLock,
        uint256 _timelock,
        uint256 _value
    ) external payable;

    /// @notice Redeems an atomic swap.
    ///
    /// @param _swapID The unique atomic swap id.
    /// @param _receiver The receiver's address.
    /// @param _secretKey The secret of the atomic swap.
    function redeem(bytes32 _swapID, address payable _receiver, bytes32 _secretKey) external;

    /// @notice Redeems an atomic swap to the spender. Can be called by anyone.
    ///
    /// @param _swapID The unique atomic swap id.
    /// @param _secretKey The secret of the atomic swap.
    function redeemToSpender(bytes32 _swapID, bytes32 _secretKey) external;

    /// @notice Refunds an atomic swap.
    ///
    /// @param _swapID The unique atomic swap id.
    function refund(bytes32 _swapID) external;

    /// @notice Allows broker fee withdrawals.
    ///
    /// @param _amount The withdrawal amount.
    function withdrawBrokerFees(uint256 _amount) external;

    /// @notice Audits an atomic swap.
    ///
    /// @param _swapID The unique atomic swap id.
    function audit(
        bytes32 _swapID
    ) external view returns (
        uint256 timelock,
        uint256 value,
        address to, uint256 brokerFee,
        address broker,
        address from,
        bytes32 secretLock
    );

    /// @notice Audits the secret of an atomic swap.
    ///
    /// @param _swapID The unique atomic swap id.
    function auditSecret(bytes32 _swapID) external view  returns (bytes32 secretKey);

    /// @notice Checks whether a swap is refundable or not.
    ///
    /// @param _swapID The unique atomic swap id.
    function refundable(bytes32 _swapID) external view returns (bool);

    /// @notice Checks whether a swap is initiatable or not.
    ///
    /// @param _swapID The unique atomic swap id.
    function initiatable(bytes32 _swapID) external view returns (bool);

    /// @notice Checks whether a swap is redeemable or not.
    ///
    /// @param _swapID The unique atomic swap id.
    function redeemable(bytes32 _swapID) external view returns (bool);

    /// @notice Generates a deterministic swap id using initiate swap details.
    ///
    /// @param _secretLock The hash of the secret.
    /// @param _timelock The expiry timestamp.
    function swapID(bytes32 _secretLock, uint256 _timelock) external pure returns (bytes32);
}

contract BaseSwap is SwapInterface {
    string public VERSION; // Passed in as a constructor parameter.

    struct Swap {
        uint256 timelock;
        uint256 value;
        uint256 brokerFee;
        bytes32 secretLock;
        bytes32 secretKey;
        address payable funder;
        address payable spender;
        address payable broker;
    }

    enum States {
        INVALID,
        OPEN,
        CLOSED,
        EXPIRED
    }

    // Events
    event LogOpen(bytes32 _swapID, address _spender, bytes32 _secretLock);
    event LogExpire(bytes32 _swapID);
    event LogClose(bytes32 _swapID, bytes32 _secretKey);

    // Storage
    mapping (bytes32 => Swap) internal swaps;
    mapping (bytes32 => States) private _swapStates;
    mapping (address => uint256) private _brokerFees;
    mapping (bytes32 => uint256) private _redeemedAt;

    /// @notice Throws if the swap is not invalid (i.e. has already been opened)
    modifier onlyInvalidSwaps(bytes32 _swapID) {
        require(_swapStates[_swapID] == States.INVALID, "swap opened previously");
        _;
    }

    /// @notice Throws if the swap is not open.
    modifier onlyOpenSwaps(bytes32 _swapID) {
        require(_swapStates[_swapID] == States.OPEN, "swap not open");
        _;
    }

    /// @notice Throws if the swap is not closed.
    modifier onlyClosedSwaps(bytes32 _swapID) {
        require(_swapStates[_swapID] == States.CLOSED, "swap not redeemed");
        _;
    }

    /// @notice Throws if the swap is not expirable.
    modifier onlyExpirableSwaps(bytes32 _swapID) {
        /* solium-disable-next-line security/no-block-members */
        require(now >= swaps[_swapID].timelock, "swap not expirable");
        _;
    }

    /// @notice Throws if the secret key is not valid.
    modifier onlyWithSecretKey(bytes32 _swapID, bytes32 _secretKey) {
        require(swaps[_swapID].secretLock == sha256(abi.encodePacked(_secretKey)), "invalid secret");
        _;
    }

    /// @notice Throws if the caller is not the authorized spender.
    modifier onlySpender(bytes32 _swapID, address _spender) {
        require(swaps[_swapID].spender == _spender, "unauthorized spender");
        _;
    }

    /// @notice The contract constructor.
    ///
    /// @param _VERSION A string defining the contract version.
    constructor(string memory _VERSION) public {
        VERSION = _VERSION;
    }

    /// @notice Initiates the atomic swap.
    ///
    /// @param _swapID The unique atomic swap id.
    /// @param _spender The address of the withdrawing trader.
    /// @param _secretLock The hash of the secret (Hash Lock).
    /// @param _timelock The unix timestamp when the swap expires.
    /// @param _value The value of the atomic swap.
    function initiate(
        bytes32 _swapID,
        address payable _spender,
        bytes32 _secretLock,
        uint256 _timelock,
        uint256 _value
    ) public onlyInvalidSwaps(_swapID) payable {
        // Store the details of the swap.
        Swap memory swap = Swap({
            timelock: _timelock,
            brokerFee: 0,
            value: _value,
            funder: msg.sender,
            spender: _spender,
            broker: address(0x0),
            secretLock: _secretLock,
            secretKey: 0x0
        });
        swaps[_swapID] = swap;
        _swapStates[_swapID] = States.OPEN;

        // Logs open event
        emit LogOpen(_swapID, _spender, _secretLock);
    }

    /// @notice Initiates the atomic swap with fees.
    ///
    /// @param _swapID The unique atomic swap id.
    /// @param _spender The address of the withdrawing trader.
    /// @param _broker The address of the broker.
    /// @param _brokerFee The fee to be paid to the broker on success.
    /// @param _secretLock The hash of the secret (Hash Lock).
    /// @param _timelock The unix timestamp when the swap expires.
    /// @param _value The value of the atomic swap.
    function initiateWithFees(
        bytes32 _swapID,
        address payable _spender,
        address payable _broker,
        uint256 _brokerFee,
        bytes32 _secretLock,
        uint256 _timelock,
        uint256 _value
    ) public onlyInvalidSwaps(_swapID) payable {
        require(_value >= _brokerFee, "fee must be less than value");

        // Store the details of the swap.
        Swap memory swap = Swap({
            timelock: _timelock,
            brokerFee: _brokerFee,
            value: _value - _brokerFee,
            funder: msg.sender,
            spender: _spender,
            broker: _broker,
            secretLock: _secretLock,
            secretKey: 0x0
        });
        swaps[_swapID] = swap;
        _swapStates[_swapID] = States.OPEN;

        // Logs open event
        emit LogOpen(_swapID, _spender, _secretLock);
    }

    /// @notice Redeems an atomic swap.
    ///
    /// @param _swapID The unique atomic swap id.
    /// @param _receiver The receiver's address.
    /// @param _secretKey The secret of the atomic swap.
    function redeem(bytes32 _swapID, address payable _receiver, bytes32 _secretKey) public onlyOpenSwaps(_swapID) onlyWithSecretKey(_swapID, _secretKey) onlySpender(_swapID, msg.sender) {
        require(_receiver != address(0x0), "invalid receiver");

        // Close the swap.
        swaps[_swapID].secretKey = _secretKey;
        _swapStates[_swapID] = States.CLOSED;
        /* solium-disable-next-line security/no-block-members */
        _redeemedAt[_swapID] = now;

        // Update the broker fees to the broker.
        _brokerFees[swaps[_swapID].broker] += swaps[_swapID].brokerFee;

        // Logs close event
        emit LogClose(_swapID, _secretKey);
    }

    /// @notice Redeems an atomic swap to the spender. Can be called by anyone.
    ///
    /// @param _swapID The unique atomic swap id.
    /// @param _secretKey The secret of the atomic swap.
    function redeemToSpender(bytes32 _swapID, bytes32 _secretKey) public onlyOpenSwaps(_swapID) onlyWithSecretKey(_swapID, _secretKey) {
        // Close the swap.
        swaps[_swapID].secretKey = _secretKey;
        _swapStates[_swapID] = States.CLOSED;
        /* solium-disable-next-line security/no-block-members */
        _redeemedAt[_swapID] = now;

        // Update the broker fees to the broker.
        _brokerFees[swaps[_swapID].broker] += swaps[_swapID].brokerFee;

        // Logs close event
        emit LogClose(_swapID, _secretKey);
    }

    /// @notice Refunds an atomic swap.
    ///
    /// @param _swapID The unique atomic swap id.
    function refund(bytes32 _swapID) public onlyOpenSwaps(_swapID) onlyExpirableSwaps(_swapID) {
        // Expire the swap.
        _swapStates[_swapID] = States.EXPIRED;

        // Logs expire event
        emit LogExpire(_swapID);
    }

    /// @notice Allows broker fee withdrawals.
    ///
    /// @param _amount The withdrawal amount.
    function withdrawBrokerFees(uint256 _amount) public {
        require(_amount <= _brokerFees[msg.sender], "insufficient withdrawable fees");
        _brokerFees[msg.sender] -= _amount;
    }

    /// @notice Audits an atomic swap.
    ///
    /// @param _swapID The unique atomic swap id.
    function audit(bytes32 _swapID) external view returns (uint256 timelock, uint256 value, address to, uint256 brokerFee, address broker, address from, bytes32 secretLock) {
        Swap memory swap = swaps[_swapID];
        return (
            swap.timelock,
            swap.value,
            swap.spender,
            swap.brokerFee,
            swap.broker,
            swap.funder,
            swap.secretLock
        );
    }

    /// @notice Audits the secret of an atomic swap.
    ///
    /// @param _swapID The unique atomic swap id.
    function auditSecret(bytes32 _swapID) external view onlyClosedSwaps(_swapID) returns (bytes32 secretKey) {
        return swaps[_swapID].secretKey;
    }

    /// @notice Checks whether a swap is refundable or not.
    ///
    /// @param _swapID The unique atomic swap id.
    function refundable(bytes32 _swapID) external view returns (bool) {
        /* solium-disable-next-line security/no-block-members */
        return (now >= swaps[_swapID].timelock && _swapStates[_swapID] == States.OPEN);
    }

    /// @notice Checks whether a swap is initiatable or not.
    ///
    /// @param _swapID The unique atomic swap id.
    function initiatable(bytes32 _swapID) external view returns (bool) {
        return (_swapStates[_swapID] == States.INVALID);
    }

    /// @notice Checks whether a swap is redeemable or not.
    ///
    /// @param _swapID The unique atomic swap id.
    function redeemable(bytes32 _swapID) external view returns (bool) {
        return (_swapStates[_swapID] == States.OPEN);
    }

    function redeemedAt(bytes32 _swapID) external view returns (uint256) {
        return _redeemedAt[_swapID];
    }

    function brokerFees(address _broker) external view returns (uint256) {
        return _brokerFees[_broker];
    }

    /// @notice Generates a deterministic swap id using initiate swap details.
    ///
    /// @param _secretLock The hash of the secret.
    /// @param _timelock The expiry timestamp.
    function swapID(bytes32 _secretLock, uint256 _timelock) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(_secretLock, _timelock));
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
 * @title Math
 * @dev Assorted math operations
 */
library Math {
    /**
    * @dev Returns the largest of two numbers.
    */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
    * @dev Returns the smallest of two numbers.
    */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
    * @dev Calculates the average of two numbers. Since these are integers,
    * averages of an even and odd number cannot be represented, and will be
    * rounded down.
    */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

/// @notice Implements safeTransfer, safeTransferFrom and
/// safeApprove for CompatibleERC20.
///
/// See https://github.com/ethereum/solidity/issues/4116
///
/// This library allows interacting with ERC20 tokens that implement any of
/// these interfaces:
///
/// (1) transfer returns true on success, false on failure
/// (2) transfer returns true on success, reverts on failure
/// (3) transfer returns nothing on success, reverts on failure
///
/// Additionally, safeTransferFromWithFees will return the final token
/// value received after accounting for token fees.
library CompatibleERC20Functions {
    using SafeMath for uint256;

    /// @notice Calls transfer on the token and reverts if the call fails.
    function safeTransfer(CompatibleERC20 self, address to, uint256 amount) internal {
        self.transfer(to, amount);
        require(previousReturnValue(), "transfer failed");
    }

    /// @notice Calls transferFrom on the token and reverts if the call fails.
    function safeTransferFrom(CompatibleERC20 self, address from, address to, uint256 amount) internal {
        self.transferFrom(from, to, amount);
        require(previousReturnValue(), "transferFrom failed");
    }

    /// @notice Calls approve on the token and reverts if the call fails.
    function safeApprove(CompatibleERC20 self, address spender, uint256 amount) internal {
        self.approve(spender, amount);
        require(previousReturnValue(), "approve failed");
    }

    /// @notice Calls transferFrom on the token, reverts if the call fails and
    /// returns the value transferred after fees.
    function safeTransferFromWithFees(CompatibleERC20 self, address from, address to, uint256 amount) internal returns (uint256) {
        uint256 balancesBefore = self.balanceOf(to);
        self.transferFrom(from, to, amount);
        require(previousReturnValue(), "transferFrom failed");
        uint256 balancesAfter = self.balanceOf(to);
        return Math.min(amount, balancesAfter.sub(balancesBefore));
    }

    /// @notice Checks the return value of the previous function. Returns true
    /// if the previous function returned 32 non-zero bytes or returned zero
    /// bytes.
    function previousReturnValue() private pure returns (bool)
    {
        uint256 returnData = 0;

        assembly { /* solium-disable-line security/no-inline-assembly */
            // Switch on the number of bytes returned by the previous call
            switch returndatasize

            // 0 bytes: ERC20 of type (3), did not throw
            case 0 {
                returnData := 1
            }

            // 32 bytes: ERC20 of types (1) or (2)
            case 32 {
                // Copy the return data into scratch space
                returndatacopy(0, 0, 32)

                // Load  the return data into returnData
                returnData := mload(0)
            }

            // Other return size: return false
            default { }
        }

        return returnData != 0;
    }
}

/// @notice ERC20 interface which doesn't specify the return type for transfer,
/// transferFrom and approve.
interface CompatibleERC20 {
    // Modified to not return boolean
    function transfer(address to, uint256 value) external;
    function transferFrom(address from, address to, uint256 value) external;
    function approve(address spender, uint256 value) external;

    // Not modifier
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/// @notice ERC20Swap implements the ERC20Swap interface.
contract ERC20Swap is SwapInterface, BaseSwap {
    using CompatibleERC20Functions for CompatibleERC20;

    address public TOKEN_ADDRESS; // Address of the ERC20 contract. Passed in as a constructor parameter

    /// @notice The contract constructor.
    ///
    /// @param _VERSION A string defining the contract version.
    constructor(string memory _VERSION, address _TOKEN_ADDRESS) BaseSwap(_VERSION) public {
        TOKEN_ADDRESS = _TOKEN_ADDRESS;
    }

    /// @notice Initiates the atomic swap.
    ///
    /// @param _swapID The unique atomic swap id.
    /// @param _spender The address of the withdrawing trader.
    /// @param _secretLock The hash of the secret (Hash Lock).
    /// @param _timelock The unix timestamp when the swap expires.
    /// @param _value The value of the atomic swap.
    function initiate(
        bytes32 _swapID,
        address payable _spender,
        bytes32 _secretLock,
        uint256 _timelock,
        uint256 _value
    ) public payable {
        // To abide by the interface, the function is payable but throws if
        // msg.value is non-zero
        require(msg.value == 0, "eth value must be zero");
        require(_spender != address(0x0), "spender must not be zero");

        // Transfer the token to the contract
        // TODO: Initiator will first need to call
        // ERC20(TOKEN_ADDRESS).approve(address(this), _value)
        // before this contract can make transfers on the initiator's behalf.
        CompatibleERC20(TOKEN_ADDRESS).safeTransferFrom(msg.sender, address(this), _value);

        BaseSwap.initiate(
            _swapID,
            _spender,
            _secretLock,
            _timelock,
            _value
        );
    }

    /// @notice Initiates the atomic swap with broker fees.
    ///
    /// @param _swapID The unique atomic swap id.
    /// @param _spender The address of the withdrawing trader.
    /// @param _broker The address of the broker.
    /// @param _brokerFee The fee to be paid to the broker on success.
    /// @param _secretLock The hash of the secret (Hash Lock).
    /// @param _timelock The unix timestamp when the swap expires.
    /// @param _value The value of the atomic swap.
    function initiateWithFees(
        bytes32 _swapID,
        address payable _spender,
        address payable _broker,
        uint256 _brokerFee,
        bytes32 _secretLock,
        uint256 _timelock,
        uint256 _value
    ) public payable {
        // To abide by the interface, the function is payable but throws if
        // msg.value is non-zero
        require(msg.value == 0, "eth value must be zero");
        require(_spender != address(0x0), "spender must not be zero");

        // Transfer the token to the contract
        // TODO: Initiator will first need to call
        // ERC20(TOKEN_ADDRESS).approve(address(this), _value)
        // before this contract can make transfers on the initiator's behalf.
        CompatibleERC20(TOKEN_ADDRESS).safeTransferFrom(msg.sender, address(this), _value);

        BaseSwap.initiateWithFees(
            _swapID,
            _spender,
            _broker,
            _brokerFee,
            _secretLock,
            _timelock,
            _value
        );
    }

    /// @notice Redeems an atomic swap.
    ///
    /// @param _swapID The unique atomic swap id.
    /// @param _secretKey The secret of the atomic swap.
    function redeem(bytes32 _swapID, address payable _receiver, bytes32 _secretKey) public {
        BaseSwap.redeem(
            _swapID,
            _receiver,
            _secretKey
        );

        // Transfer the ERC20 funds from this contract to the withdrawing trader.
        CompatibleERC20(TOKEN_ADDRESS).safeTransfer(_receiver, swaps[_swapID].value);
    }

    /// @notice Redeems an atomic swap to the spender. Can be called by anyone.
    ///
    /// @param _swapID The unique atomic swap id.
    /// @param _secretKey The secret of the atomic swap.
    function redeemToSpender(bytes32 _swapID, bytes32 _secretKey) public {
        BaseSwap.redeemToSpender(
            _swapID,
            _secretKey
        );

        // Transfer the ERC20 funds from this contract to the withdrawing trader.
        CompatibleERC20(TOKEN_ADDRESS).safeTransfer(swaps[_swapID].spender, swaps[_swapID].value);
    }

    /// @notice Refunds an atomic swap.
    ///
    /// @param _swapID The unique atomic swap id.
    function refund(bytes32 _swapID) public {
        BaseSwap.refund(_swapID);

        // Transfer the ERC20 value from this contract back to the funding trader.
        CompatibleERC20(TOKEN_ADDRESS).safeTransfer(swaps[_swapID].funder, swaps[_swapID].value + swaps[_swapID].brokerFee);
    }

    /// @notice Allows broker fee withdrawals.
    ///
    /// @param _amount The withdrawal amount.
    function withdrawBrokerFees(uint256 _amount) public {
        BaseSwap.withdrawBrokerFees(_amount);

        CompatibleERC20(TOKEN_ADDRESS).safeTransfer(msg.sender, _amount);
    }
}