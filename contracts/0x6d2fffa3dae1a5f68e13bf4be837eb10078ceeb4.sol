pragma solidity 0.4.25;
pragma experimental ABIEncoderV2;

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

contract ErrorReporter {
    function revertTx(string reason) public pure {
        revert(reason);
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

/*

  Copyright 2018 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

contract LibEIP712 {

    // EIP191 header for EIP712 prefix
    string constant internal EIP191_HEADER = "\x19\x01";

    // EIP712 Domain Name value
    string constant internal EIP712_DOMAIN_NAME = "0x Protocol";

    // EIP712 Domain Version value
    string constant internal EIP712_DOMAIN_VERSION = "2";

    // Hash of the EIP712 Domain Separator Schema
    bytes32 constant internal EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH = keccak256(abi.encodePacked(
        "EIP712Domain(",
        "string name,",
        "string version,",
        "address verifyingContract",
        ")"
    ));

    // Hash of the EIP712 Domain Separator data
    // solhint-disable-next-line var-name-mixedcase
    bytes32 public EIP712_DOMAIN_HASH;

    constructor ()
        public
    {
        EIP712_DOMAIN_HASH = keccak256(abi.encodePacked(
            EIP712_DOMAIN_SEPARATOR_SCHEMA_HASH,
            keccak256(bytes(EIP712_DOMAIN_NAME)),
            keccak256(bytes(EIP712_DOMAIN_VERSION)),
            bytes32(address(this))
        ));
    }

    /// @dev Calculates EIP712 encoding for a hash struct in this EIP712 Domain.
    /// @param hashStruct The EIP712 hash struct.
    /// @return EIP712 hash applied to this EIP712 Domain.
    function hashEIP712Message(bytes32 hashStruct)
        internal
        view
        returns (bytes32 result)
    {
        bytes32 eip712DomainHash = EIP712_DOMAIN_HASH;

        // Assembly for more efficient computing:
        // keccak256(abi.encodePacked(
        //     EIP191_HEADER,
        //     EIP712_DOMAIN_HASH,
        //     hashStruct
        // ));

        assembly {
            // Load free memory pointer
            let memPtr := mload(64)

            mstore(memPtr, 0x1901000000000000000000000000000000000000000000000000000000000000)  // EIP191 header
            mstore(add(memPtr, 2), eip712DomainHash)                                            // EIP712 domain hash
            mstore(add(memPtr, 34), hashStruct)                                                 // Hash of struct

            // Compute hash
            result := keccak256(memPtr, 66)
        }
        return result;
    }
}

/*

  Copyright 2018 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

contract LibOrder is
    LibEIP712
{
    // Hash for the EIP712 Order Schema
    bytes32 constant internal EIP712_ORDER_SCHEMA_HASH = keccak256(abi.encodePacked(
        "Order(",
        "address makerAddress,",
        "address takerAddress,",
        "address feeRecipientAddress,",
        "address senderAddress,",
        "uint256 makerAssetAmount,",
        "uint256 takerAssetAmount,",
        "uint256 makerFee,",
        "uint256 takerFee,",
        "uint256 expirationTimeSeconds,",
        "uint256 salt,",
        "bytes makerAssetData,",
        "bytes takerAssetData",
        ")"
    ));

    // A valid order remains fillable until it is expired, fully filled, or cancelled.
    // An order's state is unaffected by external factors, like account balances.
    enum OrderStatus {
        INVALID,                     // Default value
        INVALID_MAKER_ASSET_AMOUNT,  // Order does not have a valid maker asset amount
        INVALID_TAKER_ASSET_AMOUNT,  // Order does not have a valid taker asset amount
        FILLABLE,                    // Order is fillable
        EXPIRED,                     // Order has already expired
        FULLY_FILLED,                // Order is fully filled
        CANCELLED                    // Order has been cancelled
    }

    // solhint-disable max-line-length
    struct Order {
        address makerAddress;           // Address that created the order.
        address takerAddress;           // Address that is allowed to fill the order. If set to 0, any address is allowed to fill the order.
        address feeRecipientAddress;    // Address that will recieve fees when order is filled.
        address senderAddress;          // Address that is allowed to call Exchange contract methods that affect this order. If set to 0, any address is allowed to call these methods.
        uint256 makerAssetAmount;       // Amount of makerAsset being offered by maker. Must be greater than 0.
        uint256 takerAssetAmount;       // Amount of takerAsset being bid on by maker. Must be greater than 0.
        uint256 makerFee;               // Amount of ZRX paid to feeRecipient by maker when order is filled. If set to 0, no transfer of ZRX from maker to feeRecipient will be attempted.
        uint256 takerFee;               // Amount of ZRX paid to feeRecipient by taker when order is filled. If set to 0, no transfer of ZRX from taker to feeRecipient will be attempted.
        uint256 expirationTimeSeconds;  // Timestamp in seconds at which order expires.
        uint256 salt;                   // Arbitrary number to facilitate uniqueness of the order's hash.
        bytes makerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring makerAsset. The last byte references the id of this proxy.
        bytes takerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring takerAsset. The last byte references the id of this proxy.
    }
    // solhint-enable max-line-length

    struct OrderInfo {
        uint8 orderStatus;                    // Status that describes order's validity and fillability.
        bytes32 orderHash;                    // EIP712 hash of the order (see LibOrder.getOrderHash).
        uint256 orderTakerAssetFilledAmount;  // Amount of order that has already been filled.
    }

    /// @dev Calculates Keccak-256 hash of the order.
    /// @param order The order structure.
    /// @return Keccak-256 EIP712 hash of the order.
    function getOrderHash(Order memory order)
        internal
        view
        returns (bytes32 orderHash)
    {
        orderHash = hashEIP712Message(hashOrder(order));
        return orderHash;
    }

    /// @dev Calculates EIP712 hash of the order.
    /// @param order The order structure.
    /// @return EIP712 hash of the order.
    function hashOrder(Order memory order)
        internal
        pure
        returns (bytes32 result)
    {
        bytes32 schemaHash = EIP712_ORDER_SCHEMA_HASH;
        bytes32 makerAssetDataHash = keccak256(order.makerAssetData);
        bytes32 takerAssetDataHash = keccak256(order.takerAssetData);

        // Assembly for more efficiently computing:
        // keccak256(abi.encodePacked(
        //     EIP712_ORDER_SCHEMA_HASH,
        //     bytes32(order.makerAddress),
        //     bytes32(order.takerAddress),
        //     bytes32(order.feeRecipientAddress),
        //     bytes32(order.senderAddress),
        //     order.makerAssetAmount,
        //     order.takerAssetAmount,
        //     order.makerFee,
        //     order.takerFee,
        //     order.expirationTimeSeconds,
        //     order.salt,
        //     keccak256(order.makerAssetData),
        //     keccak256(order.takerAssetData)
        // ));

        assembly {
            // Calculate memory addresses that will be swapped out before hashing
            let pos1 := sub(order, 32)
            let pos2 := add(order, 320)
            let pos3 := add(order, 352)

            // Backup
            let temp1 := mload(pos1)
            let temp2 := mload(pos2)
            let temp3 := mload(pos3)

            // Hash in place
            mstore(pos1, schemaHash)
            mstore(pos2, makerAssetDataHash)
            mstore(pos3, takerAssetDataHash)
            result := keccak256(pos1, 416)

            // Restore
            mstore(pos1, temp1)
            mstore(pos2, temp2)
            mstore(pos3, temp3)
        }
        return result;
    }
}

/*

  Copyright 2018 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

contract LibFillResults
{
    struct FillResults {
        uint256 makerAssetFilledAmount;  // Total amount of makerAsset(s) filled.
        uint256 takerAssetFilledAmount;  // Total amount of takerAsset(s) filled.
        uint256 makerFeePaid;            // Total amount of ZRX paid by maker(s) to feeRecipient(s).
        uint256 takerFeePaid;            // Total amount of ZRX paid by taker to feeRecipients(s).
    }

    struct MatchedFillResults {
        FillResults left;                    // Amounts filled and fees paid of left order.
        FillResults right;                   // Amounts filled and fees paid of right order.
        uint256 leftMakerAssetSpreadAmount;  // Spread between price of left and right order, denominated in the left order's makerAsset, paid to taker.
    }

    /// @dev Adds properties of both FillResults instances.
    ///      Modifies the first FillResults instance specified.
    /// @param totalFillResults Fill results instance that will be added onto.
    /// @param singleFillResults Fill results instance that will be added to totalFillResults.
    function addFillResults(FillResults memory totalFillResults, FillResults memory singleFillResults)
        internal
        pure
    {
        totalFillResults.makerAssetFilledAmount = SafeMath.add(totalFillResults.makerAssetFilledAmount, singleFillResults.makerAssetFilledAmount);
        totalFillResults.takerAssetFilledAmount = SafeMath.add(totalFillResults.takerAssetFilledAmount, singleFillResults.takerAssetFilledAmount);
        totalFillResults.makerFeePaid = SafeMath.add(totalFillResults.makerFeePaid, singleFillResults.makerFeePaid);
        totalFillResults.takerFeePaid = SafeMath.add(totalFillResults.takerFeePaid, singleFillResults.takerFeePaid);
    }
}

contract IExchangeCore {

    bytes public ZRX_ASSET_DATA;

    /// @dev Fills the input order.
    /// @param order Order struct containing order specifications.
    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.
    /// @param signature Proof that order has been created by maker.
    /// @return Amounts filled and fees paid by maker and taker.
    function fillOrder(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        returns (LibFillResults.FillResults memory fillResults);

    function fillOrderNoThrow(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        returns (LibFillResults.FillResults memory fillResults);

    /// @dev Gets information about an order: status, hash, and amount filled.
    /// @param order Order to gather information on.
    /// @return OrderInfo Information about the order and its state.
    ///                   See LibOrder.OrderInfo for a complete description.
    function getOrderInfo(LibOrder.Order memory order)
        public
        view
        returns (LibOrder.OrderInfo memory orderInfo);

    /// @dev Gets an asset proxy.
    /// @param assetProxyId Id of the asset proxy.
    /// @return The asset proxy registered to assetProxyId. Returns 0x0 if no proxy is registered.
    function getAssetProxy(bytes4 assetProxyId)
        external
        view
        returns (address);

    function isValidSignature(
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    )
        public
        view
        returns (bool isValid);
}

interface WETH {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}

/// @title ZeroExExchangeHandler
/// @notice Handles the all ZeroExExchange trades for the primary contract
contract ZeroExExchangeHandler is ExchangeHandler, AllowanceSetter  {

    /*
    *   State Variables
    */

    IExchangeCore public exchange;
    /// @dev note that this is dependent on the deployment of 0xV2. This is the ERC20 asset proxy + the mainnet address of the ZRX token
    bytes constant ZRX_ASSET_DATA = "\xf4\x72\x61\xb0\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\xe4\x1d\x24\x89\x57\x1d\x32\x21\x89\x24\x6d\xaf\xa5\xeb\xde\x1f\x46\x99\xf4\x98";
    address ERC20_ASSET_PROXY;
    WETH weth;

    /*
    *   Types
    */

    /// @notice Constructor
    /// @param _exchange Address of the IExchangeCore exchange
    /// @param totlePrimary the address of the totlePrimary contract
    constructor(
        address _exchange,
        address totlePrimary,
        address _weth,
        address errorReporter
        /* ,address logger */
    )
        ExchangeHandler(totlePrimary, errorReporter/*, logger*/)
        public
    {
        require(_exchange != address(0x0));
        exchange = IExchangeCore(_exchange);
        ERC20_ASSET_PROXY = exchange.getAssetProxy(toBytes4(ZRX_ASSET_DATA, 0));
        weth = WETH(_weth);
    }

    struct OrderData {
        address makerAddress;           // Address that created the order.
        address takerAddress;           // Address that is allowed to fill the order. If set to 0, any address is allowed to fill the order.
        address feeRecipientAddress;    // Address that will recieve fees when order is filled.
        address senderAddress;          // Address that is allowed to call Exchange contract methods that affect this order. If set to 0, any address is allowed to call these methods.
        uint256 makerAssetAmount;       // Amount of makerAsset being offered by maker. Must be greater than 0.
        uint256 takerAssetAmount;       // Amount of takerAsset being bid on by maker. Must be greater than 0.
        uint256 makerFee;               // Amount of ZRX paid to feeRecipient by maker when order is filled. If set to 0, no transfer of ZRX from maker to feeRecipient will be attempted.
        uint256 takerFee;               // Amount of ZRX paid to feeRecipient by taker when order is filled. If set to 0, no transfer of ZRX from taker to feeRecipient will be attempted.
        uint256 expirationTimeSeconds;  // Timestamp in seconds at which order expires.
        uint256 salt;                   // Arbitrary number to facilitate uniqueness of the order's hash.
        bytes makerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring makerAsset. The last byte references the id of this proxy.
        bytes takerAssetData;           // Encoded data that can be decoded by a specified proxy contract when transferring takerAsset. The last byte references the id of this proxy.
        bytes signature;
    }

    /*
    *   Public functions
    */

    /*
    *   Internal functions
    */

    /// @notice Gets the amount that Totle needs to give for this order
    /// @param data LibOrder.Order struct containing order values
    /// @return amountToGive amount taker needs to give in order to fill the order
    function getAmountToGive_(
        OrderData data
    )
      public
      view
      onlyTotle
      returns (uint256 amountToGive)
    {
        LibOrder.OrderInfo memory orderInfo = exchange.getOrderInfo(
            getZeroExOrder(data)
        );
        uint makerAssetAvailable = getAssetDataAvailable(data.makerAssetData, data.makerAddress);
        uint feeAssetAvailable = getAssetDataAvailable(ZRX_ASSET_DATA, data.makerAddress);

        uint maxFromMakerFee = data.makerFee == 0 ? Utils.max_uint() : getPartialAmount(feeAssetAvailable, data.makerFee, data.takerAssetAmount);
        amountToGive = Math.min(Math.min(
            getPartialAmount(makerAssetAvailable, data.makerAssetAmount, data.takerAssetAmount),
            maxFromMakerFee),
            SafeMath.sub(data.takerAssetAmount, orderInfo.orderTakerAssetFilledAmount)
        );
        /* logger.log("Getting amountToGive from ZeroEx arg2: amountToGive", amountToGive); */
    }

    function getAssetDataAvailable(bytes assetData, address account) internal view returns (uint){
        address tokenAddress = toAddress(assetData, 16);
        ERC20 token = ERC20(tokenAddress);
        return Math.min(token.balanceOf(account), token.allowance(account, ERC20_ASSET_PROXY));
    }

    function getZeroExOrder(OrderData data) internal pure returns (LibOrder.Order) {
        return LibOrder.Order({
            makerAddress: data.makerAddress,
            takerAddress: data.takerAddress,
            feeRecipientAddress: data.feeRecipientAddress,
            senderAddress: data.senderAddress,
            makerAssetAmount: data.makerAssetAmount,
            takerAssetAmount: data.takerAssetAmount,
            makerFee: data.makerFee,
            takerFee: data.takerFee,
            expirationTimeSeconds: data.expirationTimeSeconds,
            salt: data.salt,
            makerAssetData: data.makerAssetData,
            takerAssetData: data.takerAssetData
        });
    }

    /// @notice Perform exchange-specific checks on the given order
    /// @dev This should be called to check for payload errors
    /// @param data LibOrder.Order struct containing order values
    /// @return checksPassed value representing pass or fail
    function staticExchangeChecks_(
        OrderData data
    )
        public
        view
        onlyTotle
        returns (bool checksPassed)
    {

        // Make sure that:
        //  The order is not expired
        //  Both the maker and taker assets are ERC20 tokens
        //  The taker does not have to pay a fee (we don't support fees yet)
        //  We are permitted to take this order
        //  We are permitted to send this order
        // TODO: Should we check signatures here?
        return (block.timestamp <= data.expirationTimeSeconds &&
                toBytes4(data.takerAssetData, 0) == bytes4(0xf47261b0) &&
                toBytes4(data.makerAssetData, 0) == bytes4(0xf47261b0) &&
                data.takerFee == 0 &&
                (data.takerAddress == address(0x0) || data.takerAddress == address(this)) &&
                (data.senderAddress == address(0x0) || data.senderAddress == address(this))
        );
    }

    /// @notice Perform a buy order at the exchange
    /// @param data LibOrder.Order struct containing order values
    /// @return amountSpentOnOrder the amount that would be spent on the order
    /// @return amountReceivedFromOrder the amount that was received from this order
    function performBuyOrder_(
        OrderData data
    )
        public
        payable
        onlyTotle
        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)
    {
        uint256 amountToGiveForOrder = toUint(msg.data, msg.data.length - 32);

        approveAddress(ERC20_ASSET_PROXY, toAddress(data.takerAssetData, 16));

        weth.deposit.value(amountToGiveForOrder)();

        LibFillResults.FillResults memory results = exchange.fillOrder(
            getZeroExOrder(data),
            amountToGiveForOrder,
            data.signature
        );
        require(ERC20SafeTransfer.safeTransfer(toAddress(data.makerAssetData, 16), msg.sender, results.makerAssetFilledAmount));

        amountSpentOnOrder = results.takerAssetFilledAmount;
        amountReceivedFromOrder = results.makerAssetFilledAmount;
        /* logger.log("Performed buy order on ZeroEx arg2: amountSpentOnOrder, arg3: amountReceivedFromOrder", amountSpentOnOrder, amountReceivedFromOrder); */
    }

    /// @notice Perform a sell order at the exchange
    /// @param data LibOrder.Order struct containing order values
    /// @return amountSpentOnOrder the amount that would be spent on the order
    /// @return amountReceivedFromOrder the amount that was received from this order
    function performSellOrder_(
        OrderData data
    )
        public
        onlyTotle
        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)
    {
        uint256 amountToGiveForOrder = toUint(msg.data, msg.data.length - 32);
        approveAddress(ERC20_ASSET_PROXY, toAddress(data.takerAssetData, 16));

        LibFillResults.FillResults memory results = exchange.fillOrder(
            getZeroExOrder(data),
            amountToGiveForOrder,
            data.signature
        );

        weth.withdraw(results.makerAssetFilledAmount);
        msg.sender.transfer(results.makerAssetFilledAmount);

        amountSpentOnOrder = results.takerAssetFilledAmount;
        amountReceivedFromOrder = results.makerAssetFilledAmount;
        /* logger.log("Performed sell order on ZeroEx arg2: amountSpentOnOrder, arg3: amountReceivedFromOrder", amountSpentOnOrder, amountReceivedFromOrder); */
    }

    /// @notice Calculate the result of ((numerator * target) / denominator)
    /// @param numerator the numerator in the equation
    /// @param denominator the denominator in the equation
    /// @param target the target for the equations
    /// @return partialAmount the resultant value
    function getPartialAmount(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
        internal
        pure
        returns (uint256)
    {
        return SafeMath.div(SafeMath.mul(numerator, target), denominator);
    }

    // @notice Extract an address from a string of bytes
    // @param _bytes a string of at least 20 bytes
    // @param _start the offset of the address within the byte stream
    // @return tempAddress the address encoded in the bytestring beginning at _start
    function toAddress(bytes _bytes, uint _start) internal  pure returns (address) {
        require(_bytes.length >= (_start + 20));
        address tempAddress;

        assembly {
            tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000)
        }

        return tempAddress;
    }

    function toBytes4(bytes _bytes, uint _start) internal pure returns (bytes4) {
        require(_bytes.length >= (_start + 4));
        bytes4 tempBytes4;

        assembly {
            tempBytes4 := mload(add(add(_bytes, 0x20), _start))
        }
        return tempBytes4;
    }

    // @notice Extract a uint256 from a string of bytes
    // @param _bytes a string of at least 32 bytes
    // @param _start the offset of the uint256 within the byte stream
    // @return tempUint the uint encoded in the bytestring beginning at _start
    function toUint(bytes _bytes, uint _start) internal  pure returns (uint256) {
        require(_bytes.length >= (_start + 32));
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }

        return tempUint;
    }

    function getSelector(bytes4 genericSelector) public pure returns (bytes4) {
        if (genericSelector == getAmountToGiveSelector) {
            return bytes4(keccak256("getAmountToGive_((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes,bytes))"));
        } else if (genericSelector == staticExchangeChecksSelector) {
            return bytes4(keccak256("staticExchangeChecks_((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes,bytes))"));
        } else if (genericSelector == performBuyOrderSelector) {
            return bytes4(keccak256("performBuyOrder_((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes,bytes))"));
        } else if (genericSelector == performSellOrderSelector) {
            return bytes4(keccak256("performSellOrder_((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes,bytes))"));
        } else {
            return bytes4(0x0);
        }
    }

    /*
    *   Payable fallback function
    */

    /// @notice payable fallback to allow the exchange to return ether directly to this contract
    /// @dev note that only the exchange should be able to send ether to this contract
    function() public payable {
        require(msg.sender == address(weth));
    }
}