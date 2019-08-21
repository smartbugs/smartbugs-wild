pragma solidity 0.4.25;
pragma experimental ABIEncoderV2;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  function approve(address _spender, uint256 _value)
    public returns (bool);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function decimals() public view returns (uint256);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

library ERC20SafeTransfer {
    function safeTransfer(address _tokenAddress, address _to, uint256 _value) internal returns (bool success) {

        require(_tokenAddress.call(bytes4(keccak256("transfer(address,uint256)")), _to, _value));

        return fetchReturnData();
    }

    function safeTransferFrom(address _tokenAddress, address _from, address _to, uint256 _value) internal returns (bool success) {

        require(_tokenAddress.call(bytes4(keccak256("transferFrom(address,address,uint256)")), _from, _to, _value));

        return fetchReturnData();
    }

    function safeApprove(address _tokenAddress, address _spender, uint256 _value) internal returns (bool success) {

        require(_tokenAddress.call(bytes4(keccak256("approve(address,uint256)")), _spender, _value));

        return fetchReturnData();
    }

    function fetchReturnData() internal returns (bool success){
        assembly {
            switch returndatasize()
            case 0 {
                success := 1
            }
            case 32 {
                returndatacopy(0, 0, 32)
                success := mload(0)
            }
            default {
                revert(0, 0)
            }
        }
    }

}

/// @title A contract which is used to check and set allowances of tokens
/// @dev In order to use this contract is must be inherited in the contract which is using
/// its functionality
contract AllowanceSetter {
    uint256 constant MAX_UINT = 2**256 - 1;

    /// @notice A function which allows the caller to approve the max amount of any given token
    /// @dev In order to function correctly, token allowances should not be set anywhere else in
    /// the inheriting contract
    /// @param addressToApprove the address which we want to approve to transfer the token
    /// @param token the token address which we want to call approve on
    function approveAddress(address addressToApprove, address token) internal {
        if(ERC20(token).allowance(address(this), addressToApprove) == 0) {
            require(ERC20SafeTransfer.safeApprove(token, addressToApprove, MAX_UINT));
        }
    }

}

contract ErrorReporter {
    function revertTx(string reason) public pure {
        revert(reason);
    }
}

/**
 * @title Math
 * @dev Assorted math operations
 */

library Math {
  function max(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }

  function average(uint256 a, uint256 b) internal pure returns (uint256) {
    // (a + b) / 2 can overflow, so we distribute
    return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
  }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

/*
    Modified Util contract as used by Kyber Network
*/

library Utils {

    uint256 constant internal PRECISION = (10**18);
    uint256 constant internal MAX_QTY   = (10**28); // 10B tokens
    uint256 constant internal MAX_RATE  = (PRECISION * 10**6); // up to 1M tokens per ETH
    uint256 constant internal MAX_DECIMALS = 18;
    uint256 constant internal ETH_DECIMALS = 18;
    uint256 constant internal MAX_UINT = 2**256-1;

    // Currently constants can't be accessed from other contracts, so providing functions to do that here
    function precision() internal pure returns (uint256) { return PRECISION; }
    function max_qty() internal pure returns (uint256) { return MAX_QTY; }
    function max_rate() internal pure returns (uint256) { return MAX_RATE; }
    function max_decimals() internal pure returns (uint256) { return MAX_DECIMALS; }
    function eth_decimals() internal pure returns (uint256) { return ETH_DECIMALS; }
    function max_uint() internal pure returns (uint256) { return MAX_UINT; }

    /// @notice Retrieve the number of decimals used for a given ERC20 token
    /// @dev As decimals are an optional feature in ERC20, this contract uses `call` to
    /// ensure that an exception doesn't cause transaction failure
    /// @param token the token for which we should retrieve the decimals
    /// @return decimals the number of decimals in the given token
    function getDecimals(address token)
        internal
        view
        returns (uint256 decimals)
    {
        bytes4 functionSig = bytes4(keccak256("decimals()"));

        /// @dev Using assembly due to issues with current solidity `address.call()`
        /// implementation: https://github.com/ethereum/solidity/issues/2884
        assembly {
            // Pointer to next free memory slot
            let ptr := mload(0x40)
            // Store functionSig variable at ptr
            mstore(ptr,functionSig)
            let functionSigLength := 0x04
            let wordLength := 0x20

            let success := call(
                                5000, // Amount of gas
                                token, // Address to call
                                0, // ether to send
                                ptr, // ptr to input data
                                functionSigLength, // size of data
                                ptr, // where to store output data (overwrite input)
                                wordLength // size of output data (32 bytes)
                               )

            switch success
            case 0 {
                decimals := 0 // If the token doesn't implement `decimals()`, return 0 as default
            }
            case 1 {
                decimals := mload(ptr) // Set decimals to return data from call
            }
            mstore(0x40,add(ptr,0x04)) // Reset the free memory pointer to the next known free location
        }
    }

    /// @dev Checks that a given address has its token allowance and balance set above the given amount
    /// @param tokenOwner the address which should have custody of the token
    /// @param tokenAddress the address of the token to check
    /// @param tokenAmount the amount of the token which should be set
    /// @param addressToAllow the address which should be allowed to transfer the token
    /// @return bool true if the allowance and balance is set, false if not
    function tokenAllowanceAndBalanceSet(
        address tokenOwner,
        address tokenAddress,
        uint256 tokenAmount,
        address addressToAllow
    )
        internal
        view
        returns (bool)
    {
        return (
            ERC20(tokenAddress).allowance(tokenOwner, addressToAllow) >= tokenAmount &&
            ERC20(tokenAddress).balanceOf(tokenOwner) >= tokenAmount
        );
    }

    function calcDstQty(uint srcQty, uint srcDecimals, uint dstDecimals, uint rate) internal pure returns (uint) {
        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
            return (srcQty * rate * (10**(dstDecimals - srcDecimals))) / PRECISION;
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
            return (srcQty * rate) / (PRECISION * (10**(srcDecimals - dstDecimals)));
        }
    }

    function calcSrcQty(uint dstQty, uint srcDecimals, uint dstDecimals, uint rate) internal pure returns (uint) {

        //source quantity is rounded up. to avoid dest quantity being too low.
        uint numerator;
        uint denominator;
        if (srcDecimals >= dstDecimals) {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
            numerator = (PRECISION * dstQty * (10**(srcDecimals - dstDecimals)));
            denominator = rate;
        } else {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
            numerator = (PRECISION * dstQty);
            denominator = (rate * (10**(dstDecimals - srcDecimals)));
        }
        return (numerator + denominator - 1) / denominator; //avoid rounding down errors
    }

    function calcDestAmount(ERC20 src, ERC20 dest, uint srcAmount, uint rate) internal view returns (uint) {
        return calcDstQty(srcAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcSrcAmount(ERC20 src, ERC20 dest, uint destAmount, uint rate) internal view returns (uint) {
        return calcSrcQty(destAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcRateFromQty(uint srcAmount, uint destAmount, uint srcDecimals, uint dstDecimals)
        internal pure returns (uint)
    {
        require(srcAmount <= MAX_QTY);
        require(destAmount <= MAX_QTY);

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
            return (destAmount * PRECISION / ((10 ** (dstDecimals - srcDecimals)) * srcAmount));
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
            return (destAmount * PRECISION * (10 ** (srcDecimals - dstDecimals)) / srcAmount);
        }
    }

    /// @notice Bringing this in from the Math library as we've run out of space in TotlePrimary (see EIP-170)
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}

interface WETH {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
    function balanceOf(address account) external returns (uint256);
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  event OwnershipRenounced(address indexed previousOwner);
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
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
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

/// @title A contract which can be used to ensure only the TotlePrimary contract can call
/// some functions
/// @dev Defines a modifier which should be used when only the totle contract should
/// able able to call a function
contract TotleControl is Ownable {
    mapping(address => bool) public authorizedPrimaries;

    /// @dev A modifier which only allows code execution if msg.sender equals totlePrimary address
    modifier onlyTotle() {
        require(authorizedPrimaries[msg.sender]);
        _;
    }

    /// @notice Contract constructor
    /// @dev As this contract inherits ownable, msg.sender will become the contract owner
    /// @param _totlePrimary the address of the contract to be set as totlePrimary
    constructor(address _totlePrimary) public {
        authorizedPrimaries[_totlePrimary] = true;
    }

    /// @notice A function which allows only the owner to change the address of totlePrimary
    /// @dev onlyOwner modifier only allows the contract owner to run the code
    /// @param _totlePrimary the address of the contract to be set as totlePrimary
    function addTotle(
        address _totlePrimary
    ) external onlyOwner {
        authorizedPrimaries[_totlePrimary] = true;
    }

    function removeTotle(
        address _totlePrimary
    ) external onlyOwner {
        authorizedPrimaries[_totlePrimary] = false;
    }
}

/// @title A contract which allows its owner to withdraw any ether which is contained inside
contract Withdrawable is Ownable {

    /// @notice Withdraw ether contained in this contract and send it back to owner
    /// @dev onlyOwner modifier only allows the contract owner to run the code
    /// @param _token The address of the token that the user wants to withdraw
    /// @param _amount The amount of tokens that the caller wants to withdraw
    /// @return bool value indicating whether the transfer was successful
    function withdrawToken(address _token, uint256 _amount) external onlyOwner returns (bool) {
        return ERC20SafeTransfer.safeTransfer(_token, owner, _amount);
    }

    /// @notice Withdraw ether contained in this contract and send it back to owner
    /// @dev onlyOwner modifier only allows the contract owner to run the code
    /// @param _amount The amount of ether that the caller wants to withdraw
    function withdrawETH(uint256 _amount) external onlyOwner {
        owner.transfer(_amount);
    }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Paused();
  event Unpaused();

  bool private _paused = false;

  /**
   * @return true if the contract is paused, false otherwise.
   */
  function paused() public view returns (bool) {
    return _paused;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!_paused, "Contract is paused.");
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(_paused, "Contract not paused.");
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    _paused = true;
    emit Paused();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    _paused = false;
    emit Unpaused();
  }
}

contract SelectorProvider {
    bytes4 constant getAmountToGiveSelector = bytes4(keccak256("getAmountToGive(bytes)"));
    bytes4 constant staticExchangeChecksSelector = bytes4(keccak256("staticExchangeChecks(bytes)"));
    bytes4 constant performBuyOrderSelector = bytes4(keccak256("performBuyOrder(bytes,uint256)"));
    bytes4 constant performSellOrderSelector = bytes4(keccak256("performSellOrder(bytes,uint256)"));

    function getSelector(bytes4 genericSelector) public pure returns (bytes4);
}

/// @title Interface for all exchange handler contracts
contract ExchangeHandler is SelectorProvider, TotleControl, Withdrawable, Pausable {

    /*
    *   State Variables
    */

    ErrorReporter public errorReporter;
    /* Logger public logger; */
    /*
    *   Modifiers
    */

    /// @notice Constructor
    /// @dev Calls the constructor of the inherited TotleControl
    /// @param totlePrimary the address of the totlePrimary contract
    constructor(
        address totlePrimary,
        address _errorReporter
        /* ,address _logger */
    )
        TotleControl(totlePrimary)
        public
    {
        require(_errorReporter != address(0x0));
        /* require(_logger != address(0x0)); */
        errorReporter = ErrorReporter(_errorReporter);
        /* logger = Logger(_logger); */
    }

    /// @notice Gets the amount that Totle needs to give for this order
    /// @param genericPayload the data for this order in a generic format
    /// @return amountToGive amount taker needs to give in order to fill the order
    function getAmountToGive(
        bytes genericPayload
    )
        public
        view
        returns (uint256 amountToGive)
    {
        bool success;
        bytes4 functionSelector = getSelector(this.getAmountToGive.selector);

        assembly {
            let functionSelectorLength := 0x04
            let functionSelectorOffset := 0x1C
            let scratchSpace := 0x0
            let wordLength := 0x20
            let bytesLength := mload(genericPayload)
            let totalLength := add(functionSelectorLength, bytesLength)
            let startOfNewData := add(genericPayload, functionSelectorOffset)

            mstore(add(scratchSpace, functionSelectorOffset), functionSelector)
            let functionSelectorCorrect := mload(scratchSpace)
            mstore(genericPayload, functionSelectorCorrect)

            success := delegatecall(
                            gas,
                            address, // This address of the current contract
                            startOfNewData, // Start data at the beginning of the functionSelector
                            totalLength, // Total length of all data, including functionSelector
                            scratchSpace, // Use the first word of memory (scratch space) to store our return variable.
                            wordLength // Length of return variable is one word
                           )
            amountToGive := mload(scratchSpace)
            if eq(success, 0) { revert(0, 0) }
        }
    }

    /// @notice Perform exchange-specific checks on the given order
    /// @dev this should be called to check for payload errors
    /// @param genericPayload the data for this order in a generic format
    /// @return checksPassed value representing pass or fail
    function staticExchangeChecks(
        bytes genericPayload
    )
        public
        view
        returns (bool checksPassed)
    {
        bool success;
        bytes4 functionSelector = getSelector(this.staticExchangeChecks.selector);
        assembly {
            let functionSelectorLength := 0x04
            let functionSelectorOffset := 0x1C
            let scratchSpace := 0x0
            let wordLength := 0x20
            let bytesLength := mload(genericPayload)
            let totalLength := add(functionSelectorLength, bytesLength)
            let startOfNewData := add(genericPayload, functionSelectorOffset)

            mstore(add(scratchSpace, functionSelectorOffset), functionSelector)
            let functionSelectorCorrect := mload(scratchSpace)
            mstore(genericPayload, functionSelectorCorrect)

            success := delegatecall(
                            gas,
                            address, // This address of the current contract
                            startOfNewData, // Start data at the beginning of the functionSelector
                            totalLength, // Total length of all data, including functionSelector
                            scratchSpace, // Use the first word of memory (scratch space) to store our return variable.
                            wordLength // Length of return variable is one word
                           )
            checksPassed := mload(scratchSpace)
            if eq(success, 0) { revert(0, 0) }
        }
    }

    /// @notice Perform a buy order at the exchange
    /// @param genericPayload the data for this order in a generic format
    /// @param  amountToGiveForOrder amount that should be spent on this order
    /// @return amountSpentOnOrder the amount that would be spent on the order
    /// @return amountReceivedFromOrder the amount that was received from this order
    function performBuyOrder(
        bytes genericPayload,
        uint256 amountToGiveForOrder
    )
        public
        payable
        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)
    {
        bool success;
        bytes4 functionSelector = getSelector(this.performBuyOrder.selector);
        assembly {
            let callDataOffset := 0x44
            let functionSelectorOffset := 0x1C
            let functionSelectorLength := 0x04
            let scratchSpace := 0x0
            let wordLength := 0x20
            let startOfFreeMemory := mload(0x40)

            calldatacopy(startOfFreeMemory, callDataOffset, calldatasize)

            let bytesLength := mload(startOfFreeMemory)
            let totalLength := add(add(functionSelectorLength, bytesLength), wordLength)

            mstore(add(scratchSpace, functionSelectorOffset), functionSelector)

            let functionSelectorCorrect := mload(scratchSpace)

            mstore(startOfFreeMemory, functionSelectorCorrect)

            mstore(add(startOfFreeMemory, add(wordLength, bytesLength)), amountToGiveForOrder)

            let startOfNewData := add(startOfFreeMemory,functionSelectorOffset)

            success := delegatecall(
                            gas,
                            address, // This address of the current contract
                            startOfNewData, // Start data at the beginning of the functionSelector
                            totalLength, // Total length of all data, including functionSelector
                            scratchSpace, // Use the first word of memory (scratch space) to store our return variable.
                            mul(wordLength, 0x02) // Length of return variables is two words
                          )
            amountSpentOnOrder := mload(scratchSpace)
            amountReceivedFromOrder := mload(add(scratchSpace, wordLength))
            if eq(success, 0) { revert(0, 0) }
        }
    }

    /// @notice Perform a sell order at the exchange
    /// @param genericPayload the data for this order in a generic format
    /// @param  amountToGiveForOrder amount that should be spent on this order
    /// @return amountSpentOnOrder the amount that would be spent on the order
    /// @return amountReceivedFromOrder the amount that was received from this order
    function performSellOrder(
        bytes genericPayload,
        uint256 amountToGiveForOrder
    )
        public
        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)
    {
        bool success;
        bytes4 functionSelector = getSelector(this.performSellOrder.selector);
        assembly {
            let callDataOffset := 0x44
            let functionSelectorOffset := 0x1C
            let functionSelectorLength := 0x04
            let scratchSpace := 0x0
            let wordLength := 0x20
            let startOfFreeMemory := mload(0x40)

            calldatacopy(startOfFreeMemory, callDataOffset, calldatasize)

            let bytesLength := mload(startOfFreeMemory)
            let totalLength := add(add(functionSelectorLength, bytesLength), wordLength)

            mstore(add(scratchSpace, functionSelectorOffset), functionSelector)

            let functionSelectorCorrect := mload(scratchSpace)

            mstore(startOfFreeMemory, functionSelectorCorrect)

            mstore(add(startOfFreeMemory, add(wordLength, bytesLength)), amountToGiveForOrder)

            let startOfNewData := add(startOfFreeMemory,functionSelectorOffset)

            success := delegatecall(
                            gas,
                            address, // This address of the current contract
                            startOfNewData, // Start data at the beginning of the functionSelector
                            totalLength, // Total length of all data, including functionSelector
                            scratchSpace, // Use the first word of memory (scratch space) to store our return variable.
                            mul(wordLength, 0x02) // Length of return variables is two words
                          )
            amountSpentOnOrder := mload(scratchSpace)
            amountReceivedFromOrder := mload(add(scratchSpace, wordLength))
            if eq(success, 0) { revert(0, 0) }
        }
    }
}

/// @title AirSwap
/// @notice Exchange contract interface
interface AirSwap {
    /// @dev Mapping of order hash to bool (true = already filled).
    function fills(bytes32 hash) external view returns (bool);

    /// @notice Fills an order by transferring tokens between (maker or escrow) and taker
    function fill(
        address makerAddress,
        uint makerAmount,
        address makerToken,
        address takerAddress,
        uint takerAmount,
        address takerToken,
        uint256 expiration,
        uint256 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external payable;
}

/// @title AirSwapHandler
/// @notice Handles the all AirSwap trades for the primary contract
contract AirSwapHandler is ExchangeHandler, AllowanceSetter {

    /*
    *   State Variables
    */

    AirSwap public exchange;
    WETH public weth;

    /*
    *   Types
    */

    struct OrderData {
        address makerAddress;
        address makerToken;
        address takerAddress;
        address takerToken;
        uint256 makerAmount;
        uint256 takerAmount;
        uint256 expiration;
        uint256 nonce;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    /// @notice Constructor
    /// @dev Calls the constructor of the inherited ExchangeHandler
    /// @param _exchange Address of the AirSwap exchange
    /// @param _weth Address of the weth contract we are using
    /// @param totlePrimary the address of the totlePrimary contract
    /// @param errorReporter the address of the error reporter contract
    constructor(
        address _exchange,
        address _weth,
        address totlePrimary,
        address errorReporter
        /* ,address logger */
    )
        ExchangeHandler(totlePrimary, errorReporter/*, logger*/)
        public
    {
        require(_exchange != address(0x0));
        require(_weth != address(0x0));
        exchange = AirSwap(_exchange);
        weth = WETH(_weth);
    }

    /*
    *   Public functions
    */

    /// @notice Gets the amount that Totle needs to give for this order
    /// @dev Uses the `onlyTotle` modifier with public visibility as this function
    /// should only be called from functions which are inherited from the ExchangeHandler
    /// base contract.
    /// Uses `whenNotPaused` modifier to revert transactions when contract is "paused".
    /// @param data OrderData struct containing order values
    /// @return amountToGive amount taker needs to give in order to fill the order
    function getAmountToGive(
        OrderData data
    )
        public
        view
        whenNotPaused
        onlyTotle
        returns (uint256 amountToGive)
    {
        return data.takerAmount;
    }

    /// @notice Perform exchange-specific checks on the given order
    /// @dev This function should be called to check for payload errors.
    /// Uses the `onlyTotle` modifier with public visibility as this function
    /// should only be called from functions which are inherited from the ExchangeHandler
    /// base contract.
    /// Uses `whenNotPaused` modifier to revert transactions when contract is "paused".
    /// @param data OrderData struct containing order values
    /// @return checksPassed value representing pass or fail
    function staticExchangeChecks(
        OrderData data
    )
        public
        view
        whenNotPaused
        onlyTotle
        returns (bool checksPassed)
    {
        bytes32 orderHash;
        bytes32 prefixedHash;

        (orderHash, prefixedHash) = getOrderHash(data);

        return (
            data.takerAddress != data.makerAddress &&
            data.expiration >= block.timestamp &&
            ecrecover(prefixedHash, data.v, data.r, data.s) == data.makerAddress &&
            !exchange.fills(orderHash) &&
            data.takerAddress == address(this) &&
            Utils.tokenAllowanceAndBalanceSet(data.makerAddress, data.makerToken, data.makerAmount, address(exchange))
        );
    }

    /// @notice Perform a buy order at the exchange
    /// @dev Uses the `onlyTotle` modifier with public visibility as this function
    /// should only be called from functions which are inherited from the ExchangeHandler
    /// base contract.
    /// Uses `whenNotPaused` modifier to revert transactions when contract is "paused".
    /// @param data OrderData struct containing order values
    /// @param amountToGiveForOrder amount that should be spent on this order
    /// @return amountSpentOnOrder the amount that would be spent on the order
    /// @return amountReceivedFromOrder the amount that was received from this order
    function performBuyOrder(
        OrderData data,
        uint256 amountToGiveForOrder
    )
        public
        payable
        whenNotPaused
        onlyTotle
        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)
    {
        /* logger.log("Performing AirSwap buy arg2: amountToGiveForOrder", amountToGiveForOrder); */
        if (data.takerAmount != amountToGiveForOrder || msg.value != data.takerAmount) {
            /* logger.log(
                "Taker amount is not equal to the amountToGiveForOrder or ether sent is not equal to the taker amount arg2: takerAmount, arg3: amountToGiveForOrder, arg4: msg.value",
                data.takerAmount,
                amountToGiveForOrder,
                msg.value
            ); */
            msg.sender.transfer(msg.value);
            return (0,0);
        }

        fillAndValidate(data);

        /* logger.log("Filled and validated"); */

        if (!ERC20SafeTransfer.safeTransfer(data.makerToken, msg.sender, data.makerAmount)) {
            errorReporter.revertTx("AirSwap: Unable to transfer bought tokens to primary");
        }

        return (data.takerAmount, data.makerAmount);
    }

    /// @notice Perform a sell order at the exchange
    /// @dev Uses the `onlyTotle` modifier with public visibility as this function
    /// should only be called from functions which are inherited from the ExchangeHandler
    /// base contract
    /// Uses `whenNotPaused` modifier to revert transactions when contract is "paused".
    /// @param data OrderData struct containing order values
    /// @param amountToGiveForOrder amount that should be spent on this order
    /// @return amountSpentOnOrder the amount that would be spent on the order
    /// @return amountReceivedFromOrder the amount that was received from this order
    function performSellOrder(
        OrderData data,
        uint256 amountToGiveForOrder
    )
        public
        whenNotPaused
        onlyTotle
        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)
    {
        /* logger.log("Performing AirSwap sell arg2: amountToGiveForOrder", amountToGiveForOrder); */
        /// @dev Primary will have transfered the tokens to us, revert if amount incorrect
        if (data.takerAmount != amountToGiveForOrder) {
            errorReporter.revertTx("AirSwap: takerAmount != amountToGiveForOrder");
        }

        if (data.makerToken != address(weth)) {
            /* logger.log("Maker token is not WETH", amountToGiveForOrder); */
            return (0,0);
        }

        approveAddress(address(exchange), data.takerToken);

        /* logger.log("Address approved arg6: exchange, arg7: takerToken", 0,0,0,0, exchange, data.takerToken); */

        fillAndValidate(data);

        /* logger.log("Filled and validated"); */

        weth.withdraw(data.makerAmount);

        /* logger.log("WETH withdrawal arg2: makerAmount", data.makerAmount); */

        msg.sender.transfer(data.makerAmount);

        /* logger.log("Transfered WETH to Primary"); */

        return (data.takerAmount, data.makerAmount);
    }

    /*
    *   Internal functions
    */

    /// @notice Get both hash(data) and hash(prefix,hash(data))
    /// @param data OrderData struct containing order values
    /// @return orderHash the result of hashing the concatenated order data
    /// @return prefixedHash the result of orderHash prefixed by a message
    function getOrderHash(
        OrderData data
    )
        internal
        pure
        returns (bytes32 orderHash, bytes32 prefixedHash)
    {
        orderHash = keccak256(
            data.makerAddress,
            data.makerAmount,
            data.makerToken,
            data.takerAddress,
            data.takerAmount,
            data.takerToken,
            data.expiration,
            data.nonce
        );

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        prefixedHash = keccak256(prefix, orderHash);
    }

    /// @notice Calls the fill function at airSwap, then validates the order was filled
    /// @dev If the order was not valid, this function will revert the transaction
    /// @param data OrderData struct containing order values
    function fillAndValidate(OrderData data) internal {

        exchange.fill.value(msg.value)(
            data.makerAddress,
            data.makerAmount,
            data.makerToken,
            data.takerAddress,
            data.takerAmount,
            data.takerToken,
            data.expiration,
            data.nonce,
            data.v,
            data.r,
            data.s
        );

        bytes32 orderHash;
        (orderHash, ) = getOrderHash(data);

        if (!exchange.fills(orderHash)) {
            errorReporter.revertTx("AirSwap: Order failed validation after execution");
        }
    }

    function getSelector(bytes4 genericSelector) public pure returns (bytes4) {
        if (genericSelector == getAmountToGiveSelector) {
            return bytes4(keccak256("getAmountToGive((address,address,address,address,uint256,uint256,uint256,uint256,uint8,bytes32,bytes32))"));
        } else if (genericSelector == staticExchangeChecksSelector) {
            return bytes4(keccak256("staticExchangeChecks((address,address,address,address,uint256,uint256,uint256,uint256,uint8,bytes32,bytes32))"));
        } else if (genericSelector == performBuyOrderSelector) {
            return bytes4(keccak256("performBuyOrder((address,address,address,address,uint256,uint256,uint256,uint256,uint8,bytes32,bytes32),uint256)"));
        } else if (genericSelector == performSellOrderSelector) {
            return bytes4(keccak256("performSellOrder((address,address,address,address,uint256,uint256,uint256,uint256,uint8,bytes32,bytes32),uint256)"));
        } else {
            return bytes4(0x0);
        }
    }

    /*
    *   Payable fallback function
    */

    /// @notice payable fallback to allow handler or exchange contracts to return ether
    /// @dev only accounts containing code (ie. contracts) can send ether to this contract
    function() public payable whenNotPaused {
        // Check in here that the sender is a contract! (to stop accidents)
        uint256 size;
        address sender = msg.sender;
        assembly {
            size := extcodesize(sender)
        }
        if (size == 0) {
            errorReporter.revertTx("EOA cannot send ether to primary fallback");
        }
    }

}