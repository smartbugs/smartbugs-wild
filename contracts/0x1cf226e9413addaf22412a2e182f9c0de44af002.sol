/**
 * Copyright 2017–2018, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */
 
pragma solidity 0.5.3;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

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

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

  /// @dev Constant for unlocked guard state - non-zero to prevent extra gas costs.
  /// See: https://github.com/OpenZeppelin/openzeppelin-solidity/issues/1056
  uint256 private constant REENTRANCY_GUARD_FREE = 1;

  /// @dev Constant for locked guard state
  uint256 private constant REENTRANCY_GUARD_LOCKED = 2;

  /**
   * @dev We use a single lock for the whole contract.
   */
  uint256 private reentrancyLock = REENTRANCY_GUARD_FREE;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one `nonReentrant` function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and an `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    require(reentrancyLock == REENTRANCY_GUARD_FREE);
    reentrancyLock = REENTRANCY_GUARD_LOCKED;
    _;
    reentrancyLock = REENTRANCY_GUARD_FREE;
  }

}

contract GasTracker {

    uint256 internal gasUsed;

    modifier tracksGas() {
        // tx call 21k gas
        gasUsed = gasleft() + 21000;

        _; // modified function body inserted here

        gasUsed = 0; // zero out the storage so we don't persist anything
    }
}

contract BZxObjects {

    struct ListIndex {
        uint256 index;
        bool isSet;
    }

    struct LoanOrder {
        address loanTokenAddress;
        address interestTokenAddress;
        address collateralTokenAddress;
        address oracleAddress;
        uint256 loanTokenAmount;
        uint256 interestAmount;
        uint256 initialMarginAmount;
        uint256 maintenanceMarginAmount;
        uint256 maxDurationUnixTimestampSec;
        bytes32 loanOrderHash;
    }

    struct LoanOrderAux {
        address makerAddress;
        address takerAddress;
        address feeRecipientAddress;
        address tradeTokenToFillAddress;
        uint256 lenderRelayFee;
        uint256 traderRelayFee;
        uint256 makerRole;
        uint256 expirationUnixTimestampSec;
        bool withdrawOnOpen;
        string description;
    }

    struct LoanPosition {
        address trader;
        address collateralTokenAddressFilled;
        address positionTokenAddressFilled;
        uint256 loanTokenAmountFilled;
        uint256 loanTokenAmountUsed;
        uint256 collateralTokenAmountFilled;
        uint256 positionTokenAmountFilled;
        uint256 loanStartUnixTimestampSec;
        uint256 loanEndUnixTimestampSec;
        bool active;
        uint256 positionId;
    }

    struct PositionRef {
        bytes32 loanOrderHash;
        uint256 positionId;
    }

    struct LenderInterest {
        uint256 interestOwedPerDay;
        uint256 interestPaid;
        uint256 interestPaidDate;
    }

    struct TraderInterest {
        uint256 interestOwedPerDay;
        uint256 interestPaid;
        uint256 interestDepositTotal;
        uint256 interestUpdatedDate;
    }
}

contract BZxEvents {

    event LogLoanAdded (
        bytes32 indexed loanOrderHash,
        address adderAddress,
        address indexed makerAddress,
        address indexed feeRecipientAddress,
        uint256 lenderRelayFee,
        uint256 traderRelayFee,
        uint256 maxDuration,
        uint256 makerRole
    );

    event LogLoanTaken (
        address indexed lender,
        address indexed trader,
        address loanTokenAddress,
        address collateralTokenAddress,
        uint256 loanTokenAmount,
        uint256 collateralTokenAmount,
        uint256 loanEndUnixTimestampSec,
        bool firstFill,
        bytes32 indexed loanOrderHash,
        uint256 positionId
    );

    event LogLoanCancelled(
        address indexed makerAddress,
        uint256 cancelLoanTokenAmount,
        uint256 remainingLoanTokenAmount,
        bytes32 indexed loanOrderHash
    );

    event LogLoanClosed(
        address indexed lender,
        address indexed trader,
        address loanCloser,
        bool isLiquidation,
        bytes32 indexed loanOrderHash,
        uint256 positionId
    );

    event LogPositionTraded(
        bytes32 indexed loanOrderHash,
        address indexed trader,
        address sourceTokenAddress,
        address destTokenAddress,
        uint256 sourceTokenAmount,
        uint256 destTokenAmount,
        uint256 positionId
    );

    event LogWithdrawPosition(
        bytes32 indexed loanOrderHash,
        address indexed trader,
        uint256 positionAmount,
        uint256 remainingPosition,
        uint256 positionId
    );

    event LogPayInterestForOracle(
        address indexed lender,
        address indexed oracleAddress,
        address indexed interestTokenAddress,
        uint256 amountPaid,
        uint256 totalAccrued
    );

    event LogPayInterestForOrder(
        bytes32 indexed loanOrderHash,
        address indexed lender,
        address indexed interestTokenAddress,
        uint256 amountPaid,
        uint256 totalAccrued,
        uint256 loanCount
    );

    event LogChangeTraderOwnership(
        bytes32 indexed loanOrderHash,
        address indexed oldOwner,
        address indexed newOwner
    );

    event LogChangeLenderOwnership(
        bytes32 indexed loanOrderHash,
        address indexed oldOwner,
        address indexed newOwner
    );

    event LogUpdateLoanAsLender(
        bytes32 indexed loanOrderHash,
        address indexed lender,
        uint256 loanTokenAmountAdded,
        uint256 loanTokenAmountFillable,
        uint256 expirationUnixTimestampSec
    );
}

contract BZxStorage is BZxObjects, BZxEvents, ReentrancyGuard, Ownable, GasTracker {
    uint256 internal constant MAX_UINT = 2**256 - 1;

    address public bZRxTokenContract;
    address public bZxEtherContract;
    address public wethContract;
    address payable public vaultContract;
    address public oracleRegistryContract;
    address public bZxTo0xContract;
    address public bZxTo0xV2Contract;
    bool public DEBUG_MODE = false;

    // Loan Orders
    mapping (bytes32 => LoanOrder) public orders; // mapping of loanOrderHash to on chain loanOrders
    mapping (bytes32 => LoanOrderAux) public orderAux; // mapping of loanOrderHash to on chain loanOrder auxiliary parameters
    mapping (bytes32 => uint256) public orderFilledAmounts; // mapping of loanOrderHash to loanTokenAmount filled
    mapping (bytes32 => uint256) public orderCancelledAmounts; // mapping of loanOrderHash to loanTokenAmount cancelled
    mapping (bytes32 => address) public orderLender; // mapping of loanOrderHash to lender (only one lender per order)

    // Loan Positions
    mapping (uint256 => LoanPosition) public loanPositions; // mapping of position ids to loanPositions
    mapping (bytes32 => mapping (address => uint256)) public loanPositionsIds; // mapping of loanOrderHash to mapping of trader address to position id

    // Lists
    mapping (address => bytes32[]) public orderList; // mapping of lenders and trader addresses to array of loanOrderHashes
    mapping (bytes32 => mapping (address => ListIndex)) public orderListIndex; // mapping of loanOrderHash to mapping of lenders and trader addresses to ListIndex objects

    mapping (bytes32 => uint256[]) public orderPositionList; // mapping of loanOrderHash to array of order position ids

    PositionRef[] public positionList; // array of loans that need to be checked for liquidation or expiration
    mapping (uint256 => ListIndex) public positionListIndex; // mapping of position ids to ListIndex objects

    // Interest
    mapping (address => mapping (address => uint256)) public tokenInterestOwed; // mapping of lender address to mapping of interest token address to amount of interest owed for all loans (assuming they go to full term)
    mapping (address => mapping (address => mapping (address => LenderInterest))) public lenderOracleInterest; // mapping of lender address to mapping of oracle to mapping of interest token to LenderInterest objects
    mapping (bytes32 => LenderInterest) public lenderOrderInterest; // mapping of loanOrderHash to LenderInterest objects
    mapping (uint256 => TraderInterest) public traderLoanInterest; // mapping of position ids to TraderInterest objects

    // Other Storage
    mapping (address => address) public oracleAddresses; // mapping of oracles to their current logic contract
    mapping (bytes32 => mapping (address => bool)) public preSigned; // mapping of hash => signer => signed
    mapping (address => mapping (address => bool)) public allowedValidators; // mapping of signer => validator => approved

    // General Purpose
    mapping (bytes => uint256) internal dbUint256;
    mapping (bytes => uint256[]) internal dbUint256Array;
    mapping (bytes => address) internal dbAddress;
    mapping (bytes => address[]) internal dbAddressArray;
    mapping (bytes => bool) internal dbBool;
    mapping (bytes => bool[]) internal dbBoolArray;
    mapping (bytes => bytes32) internal dbBytes32;
    mapping (bytes => bytes32[]) internal dbBytes32Array;
    mapping (bytes => bytes) internal dbBytes;
    mapping (bytes => bytes[]) internal dbBytesArray;
}

contract BZxProxiable {
    mapping (bytes4 => address) public targets;

    mapping (bytes4 => bool) public targetIsPaused;

    function initialize(address _target) public;
}

contract BZxProxy is BZxStorage, BZxProxiable {
    
    constructor(
        address _settings) 
        public
    {
        (bool result,) = _settings.delegatecall.gas(gasleft())(abi.encodeWithSignature("initialize(address)", _settings));
        require(result, "BZxProxy::constructor: failed");
    }
    
    function() 
        external
        payable 
    {
        require(!targetIsPaused[msg.sig], "BZxProxy::Function temporarily paused");

        address target = targets[msg.sig];
        require(target != address(0), "BZxProxy::Target not found");

        bytes memory data = msg.data;
        assembly {
            let result := delegatecall(gas, target, add(data, 0x20), mload(data), 0, 0)
            let size := returndatasize
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }

    function initialize(
        address)
        public
    {
        revert();
    }
}