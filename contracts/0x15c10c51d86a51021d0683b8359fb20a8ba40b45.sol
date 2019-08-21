pragma solidity ^0.5.1;

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

interface ERC20SwapContract {
    /// @notice Initiates the atomic swap.
    ///
    /// @param _swapID The unique atomic swap id.
    /// @param _spender The address of the withdrawing trader.
    /// @param _secretLock The hash of the secret (Hash Lock).
    /// @param _timelock The unix timestamp when the swap expires.
    /// @param _value The value of the atomic swap.
    function initiate(
        bytes32 _swapID,
        address _spender,
        bytes32 _secretLock,
        uint256 _timelock,
        uint256 _value
    ) external;

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
        address _spender,
        address _broker,
        uint256 _brokerFee,
        bytes32 _secretLock,
        uint256 _timelock,
        uint256 _value
    ) external;

    /// @notice Redeems an atomic swap.
    ///
    /// @param _swapID The unique atomic swap id.
    /// @param _receiver The receiver's address.
    /// @param _secretKey The secret of the atomic swap.
    function redeem(bytes32 _swapID, address _receiver, bytes32 _secretKey) external;

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
    function audit(bytes32 _swapID) external view returns (uint256 timelock, uint256 value, address to, uint256 brokerFee, address broker, address from, bytes32 secretLock);

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

/// @notice WBTCSwapContract implements the ERC20SwapContract interface.
contract WBTCSwapContract is ERC20SwapContract {
    string public VERSION; // Passed in as a constructor parameter.
    address public TOKEN_ADDRESS; // Address of the ERC20 contract. Passed in as a constructor parameter

    struct Swap {
        uint256 timelock;
        uint256 value;
        uint256 brokerFee;
        bytes32 secretLock;
        bytes32 secretKey;
        address funder;
        address spender;
        address broker;
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
    mapping (bytes32 => Swap) private swaps;
    mapping (bytes32 => States) private swapStates;
    mapping (address => uint256) public brokerFees;
    mapping (bytes32 => uint256) public redeemedAt;

    /// @notice Throws if the swap is not invalid (i.e. has already been opened)
    modifier onlyInvalidSwaps(bytes32 _swapID) {
        require(swapStates[_swapID] == States.INVALID, "swap opened previously");
        _;
    }

    /// @notice Throws if the swap is not open.
    modifier onlyOpenSwaps(bytes32 _swapID) {
        require(swapStates[_swapID] == States.OPEN, "swap not open");
        _;
    }

    /// @notice Throws if the swap is not closed.
    modifier onlyClosedSwaps(bytes32 _swapID) {
        require(swapStates[_swapID] == States.CLOSED, "swap not redeemed");
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
    constructor(string memory _VERSION, address _TOKEN_ADDRESS) public {
        VERSION = _VERSION;
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
        address _spender,
        bytes32 _secretLock,
        uint256 _timelock,
        uint256 _value
    ) external onlyInvalidSwaps(_swapID) {
        // Transfer the token to the contract
        // TODO: Initiator will first need to call
        // ERC20(TOKEN_ADDRESS).approve(address(this), _value)
        // before this contract can make transfers on the initiator's behalf.
        CompatibleERC20(TOKEN_ADDRESS).transferFrom(msg.sender, address(this), _value);

        // Store the details of the swap.
        Swap memory swap = Swap({
            timelock: _timelock,
            value: _value,
            funder: msg.sender,
            spender: _spender,
            broker: address(0x0),
            brokerFee: 0,
            secretLock: _secretLock,
            secretKey: 0x0
        });
        swaps[_swapID] = swap;
        swapStates[_swapID] = States.OPEN;

        // Logs open event
        emit LogOpen(_swapID, _spender, _secretLock);
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
        address _spender,
        address _broker,
        uint256 _brokerFee,
        bytes32 _secretLock,
        uint256 _timelock,
        uint256 _value
    ) external onlyInvalidSwaps(_swapID) {
        // Transfer the token to the contract
        // TODO: Initiator will first need to call
        // ERC20(TOKEN_ADDRESS).approve(address(this), _value)
        // before this contract can make transfers on the initiator's behalf.
        CompatibleERC20(TOKEN_ADDRESS).transferFrom(msg.sender, address(this), _value);

        // Store the details of the swap.
        Swap memory swap = Swap({
            timelock: _timelock,
            value: _value - _brokerFee,
            funder: msg.sender,
            spender: _spender,
            broker: _broker,
            brokerFee: _brokerFee,
            secretLock: _secretLock,
            secretKey: 0x0
        });
        swaps[_swapID] = swap;
        swapStates[_swapID] = States.OPEN;

        // Logs open event
        emit LogOpen(_swapID, _spender, _secretLock);
    }

    /// @notice Refunds an atomic swap.
    ///
    /// @param _swapID The unique atomic swap id.
    function refund(bytes32 _swapID) external onlyOpenSwaps(_swapID) onlyExpirableSwaps(_swapID) {
        // Expire the swap.
        swapStates[_swapID] = States.EXPIRED;

        // Transfer the ERC20 value from this contract back to the funding trader.
        CompatibleERC20(TOKEN_ADDRESS).transfer(swaps[_swapID].funder, swaps[_swapID].value + swaps[_swapID].brokerFee);

        // Logs expire event
        emit LogExpire(_swapID);
    }

    /// @notice Allows broker fee withdrawals.
    ///
    /// @param _amount The withdrawal amount.
    function withdrawBrokerFees(uint256 _amount) external {
        require(_amount <= brokerFees[msg.sender]);
        brokerFees[msg.sender] -= _amount;
        CompatibleERC20(TOKEN_ADDRESS).transfer(msg.sender, _amount);
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

    /// @notice Redeems an atomic swap.
    ///
    /// @param _swapID The unique atomic swap id.
    /// @param _secretKey The secret of the atomic swap.
    function redeem(bytes32 _swapID, address _receiver, bytes32 _secretKey) external onlyOpenSwaps(_swapID) onlyWithSecretKey(_swapID, _secretKey) onlySpender(_swapID, msg.sender) {
        // Close the swap.
        swaps[_swapID].secretKey = _secretKey;
        swapStates[_swapID] = States.CLOSED;
        /* solium-disable-next-line security/no-block-members */
        redeemedAt[_swapID] = now;

        // Transfer the ERC20 funds from this contract to the broker.
        brokerFees[swaps[_swapID].broker] += swaps[_swapID].brokerFee;

        // Transfer the ERC20 funds from this contract to the withdrawing trader.
        CompatibleERC20(TOKEN_ADDRESS).transfer(_receiver, swaps[_swapID].value);

        // Logs close event
        emit LogClose(_swapID, _secretKey);
    }
    
    /// @notice Checks whether a swap is refundable or not.
    ///
    /// @param _swapID The unique atomic swap id.
    function refundable(bytes32 _swapID) external view returns (bool) {
        /* solium-disable-next-line security/no-block-members */
        return (now >= swaps[_swapID].timelock && swapStates[_swapID] == States.OPEN);
    }

    /// @notice Checks whether a swap is initiatable or not.
    ///
    /// @param _swapID The unique atomic swap id.
    function initiatable(bytes32 _swapID) external view returns (bool) {
        return (swapStates[_swapID] == States.INVALID);
    }

    /// @notice Checks whether a swap is redeemable or not.
    ///
    /// @param _swapID The unique atomic swap id.
    function redeemable(bytes32 _swapID) external view returns (bool) {
        return (swapStates[_swapID] == States.OPEN);
    }

    /// @notice Generates a deterministic swap id using initiate swap details.
    ///
    /// @param _secretLock The hash of the secret.
    /// @param _timelock The expiry timestamp.
    function swapID(bytes32 _secretLock, uint256 _timelock) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_secretLock, _timelock));
    }
}