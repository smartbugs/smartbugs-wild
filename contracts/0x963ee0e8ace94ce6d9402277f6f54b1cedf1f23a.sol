pragma solidity ^0.5.7;
pragma experimental ABIEncoderV2;

// File: contracts/lib/ERC20SafeTransfer.sol

/*

  Copyright 2017 Loopring Project Ltd (Loopring Foundation).

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

/// @title ERC20 safe transfer
/// @dev see https://github.com/sec-bit/badERC20Fix
/// @author Brecht Devos - <brecht@loopring.org>
library ERC20SafeTransfer {

    function safeTransfer(
        address token,
        address to,
        uint256 value)
    internal
    returns (bool success)
    {
        // A transfer is successful when 'call' is successful and depending on the token:
        // - No value is returned: we assume a revert when the transfer failed (i.e. 'call' returns false)
        // - A single boolean is returned: this boolean needs to be true (non-zero)

        // bytes4(keccak256("transfer(address,uint256)")) = 0xa9059cbb
        bytes memory callData = abi.encodeWithSelector(
            bytes4(0xa9059cbb),
            to,
            value
        );
        (success, ) = token.call(callData);
        return checkReturnValue(success);
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value)
    internal
    returns (bool success)
    {
        // A transferFrom is successful when 'call' is successful and depending on the token:
        // - No value is returned: we assume a revert when the transfer failed (i.e. 'call' returns false)
        // - A single boolean is returned: this boolean needs to be true (non-zero)

        // bytes4(keccak256("transferFrom(address,address,uint256)")) = 0x23b872dd
        bytes memory callData = abi.encodeWithSelector(
            bytes4(0x23b872dd),
            from,
            to,
            value
        );
        (success, ) = token.call(callData);
        return checkReturnValue(success);
    }

    function checkReturnValue(
        bool success
    )
    internal
    pure
    returns (bool)
    {
        // A transfer/transferFrom is successful when 'call' is successful and depending on the token:
        // - No value is returned: we assume a revert when the transfer failed (i.e. 'call' returns false)
        // - A single boolean is returned: this boolean needs to be true (non-zero)
        if (success) {
            assembly {
                switch returndatasize()
                // Non-standard ERC20: nothing is returned so if 'call' was successful we assume the transfer succeeded
                case 0 {
                    success := 1
                }
                // Standard ERC20: a single boolean value is returned which needs to be true
                case 32 {
                    returndatacopy(0, 0, 32)
                    success := mload(0)
                }
                // None of the above: not successful
                default {
                    success := 0
                }
            }
        }
        return success;
    }

}

// File: contracts/lib/LibBytes.sol

// Modified from 0x LibBytes
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
library LibBytes {

    using LibBytes for bytes;

    /// @dev Gets the memory address for the contents of a byte array.
    /// @param input Byte array to lookup.
    /// @return memoryAddress Memory address of the contents of the byte array.
    function contentAddress(bytes memory input)
    internal
    pure
    returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := add(input, 32)
        }
        return memoryAddress;
    }

    /// @dev Copies `length` bytes from memory location `source` to `dest`.
    /// @param dest memory address to copy bytes to.
    /// @param source memory address to copy bytes from.
    /// @param length number of bytes to copy.
    function memCopy(
        uint256 dest,
        uint256 source,
        uint256 length
    )
    internal
    pure
    {
        if (length < 32) {
            // Handle a partial word by reading destination and masking
            // off the bits we are interested in.
            // This correctly handles overlap, zero lengths and source == dest
            assembly {
                let mask := sub(exp(256, sub(32, length)), 1)
                let s := and(mload(source), not(mask))
                let d := and(mload(dest), mask)
                mstore(dest, or(s, d))
            }
        } else {
            // Skip the O(length) loop when source == dest.
            if (source == dest) {
                return;
            }

            // For large copies we copy whole words at a time. The final
            // word is aligned to the end of the range (instead of after the
            // previous) to handle partial words. So a copy will look like this:
            //
            //  ####
            //      ####
            //          ####
            //            ####
            //
            // We handle overlap in the source and destination range by
            // changing the copying direction. This prevents us from
            // overwriting parts of source that we still need to copy.
            //
            // This correctly handles source == dest
            //
            if (source > dest) {
                assembly {
                // We subtract 32 from `sEnd` and `dEnd` because it
                // is easier to compare with in the loop, and these
                // are also the addresses we need for copying the
                // last bytes.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                // Remember the last 32 bytes of source
                // This needs to be done here and not after the loop
                // because we may have overwritten the last bytes in
                // source already due to overlap.
                    let last := mload(sEnd)

                // Copy whole words front to back
                // Note: the first check is always true,
                // this could have been a do-while loop.
                // solhint-disable-next-line no-empty-blocks
                    for {} lt(source, sEnd) {} {
                        mstore(dest, mload(source))
                        source := add(source, 32)
                        dest := add(dest, 32)
                    }

                // Write the last 32 bytes
                    mstore(dEnd, last)
                }
            } else {
                assembly {
                // We subtract 32 from `sEnd` and `dEnd` because those
                // are the starting points when copying a word at the end.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                // Remember the first 32 bytes of source
                // This needs to be done here and not after the loop
                // because we may have overwritten the first bytes in
                // source already due to overlap.
                    let first := mload(source)

                // Copy whole words back to front
                // We use a signed comparisson here to allow dEnd to become
                // negative (happens when source and dest < 32). Valid
                // addresses in local memory will never be larger than
                // 2**255, so they can be safely re-interpreted as signed.
                // Note: the first check is always true,
                // this could have been a do-while loop.
                // solhint-disable-next-line no-empty-blocks
                    for {} slt(dest, dEnd) {} {
                        mstore(dEnd, mload(sEnd))
                        sEnd := sub(sEnd, 32)
                        dEnd := sub(dEnd, 32)
                    }

                // Write the first 32 bytes
                    mstore(dest, first)
                }
            }
        }
    }

    /// @dev Returns a slices from a byte array.
    /// @param b The byte array to take a slice from.
    /// @param from The starting index for the slice (inclusive).
    /// @param to The final index for the slice (exclusive).
    /// @return result The slice containing bytes at indices [from, to)
    function slice(
        bytes memory b,
        uint256 from,
        uint256 to
    )
    internal
    pure
    returns (bytes memory result)
    {
        if (from > to || to > b.length) {
            return "";
        }

        // Create a new bytes structure and copy contents
        result = new bytes(to - from);
        memCopy(
            result.contentAddress(),
            b.contentAddress() + from,
            result.length
        );
        return result;
    }

    /// @dev Reads an address from a position in a byte array.
    /// @param b Byte array containing an address.
    /// @param index Index in byte array of address.
    /// @return address from byte array.
    function readAddress(
        bytes memory b,
        uint256 index
    )
    internal
    pure
    returns (address result)
    {
        require(
            b.length >= index + 20,  // 20 is length of address
            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"
        );

        // Add offset to index:
        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)
        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)
        index += 20;

        // Read address from array memory
        assembly {
        // 1. Add index to address of bytes array
        // 2. Load 32-byte word from memory
        // 3. Apply 20-byte mask to obtain address
            result := and(mload(add(b, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }

    /// @dev Reads a bytes32 value from a position in a byte array.
    /// @param b Byte array containing a bytes32 value.
    /// @param index Index in byte array of bytes32 value.
    /// @return bytes32 value from byte array.
    function readBytes32(
        bytes memory b,
        uint256 index
    )
    internal
    pure
    returns (bytes32 result)
    {
        require(
            b.length >= index + 32,
            "GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED"
        );

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            result := mload(add(b, index))
        }
        return result;
    }

    /// @dev Reads a uint256 value from a position in a byte array.
    /// @param b Byte array containing a uint256 value.
    /// @param index Index in byte array of uint256 value.
    /// @return uint256 value from byte array.
    function readUint256(
        bytes memory b,
        uint256 index
    )
    internal
    pure
    returns (uint256 result)
    {
        result = uint256(readBytes32(b, index));
        return result;
    }

    /// @dev Reads an unpadded bytes4 value from a position in a byte array.
    /// @param b Byte array containing a bytes4 value.
    /// @param index Index in byte array of bytes4 value.
    /// @return bytes4 value from byte array.
    function readBytes4(
        bytes memory b,
        uint256 index
    )
    internal
    pure
    returns (bytes4 result)
    {
        require(
            b.length >= index + 4,
            "GREATER_OR_EQUAL_TO_4_LENGTH_REQUIRED"
        );

        // Arrays are prefixed by a 32 byte length field
        index += 32;

        // Read the bytes4 from array memory
        assembly {
            result := mload(add(b, index))
        // Solidity does not require us to clean the trailing bytes.
        // We do it anyway
            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)
        }
        return result;
    }
}

// File: contracts/lib/LibMath.sol

contract LibMath {
    // Copied from openzeppelin Math
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

    // Modified from openzeppelin SafeMath
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

    // Copied from 0x LibMath
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
    /// @dev Calculates partial value given a numerator and denominator rounded down.
    ///      Reverts if rounding error is >= 0.1%
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to calculate partial of.
    /// @return Partial value of target rounded down.
    function safeGetPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
    internal
    pure
    returns (uint256 partialAmount)
    {
        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        require(
            !isRoundingErrorFloor(
            numerator,
            denominator,
            target
        ),
            "ROUNDING_ERROR"
        );

        partialAmount = div(
            mul(numerator, target),
            denominator
        );
        return partialAmount;
    }

    /// @dev Calculates partial value given a numerator and denominator rounded down.
    ///      Reverts if rounding error is >= 0.1%
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to calculate partial of.
    /// @return Partial value of target rounded up.
    function safeGetPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
    internal
    pure
    returns (uint256 partialAmount)
    {
        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        require(
            !isRoundingErrorCeil(
            numerator,
            denominator,
            target
        ),
            "ROUNDING_ERROR"
        );

        partialAmount = div(
            add(
                mul(numerator, target),
                sub(denominator, 1)
            ),
            denominator
        );
        return partialAmount;
    }

    /// @dev Calculates partial value given a numerator and denominator rounded down.
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to calculate partial of.
    /// @return Partial value of target rounded down.
    function getPartialAmountFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
    internal
    pure
    returns (uint256 partialAmount)
    {
        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        partialAmount = div(
            mul(numerator, target),
            denominator
        );
        return partialAmount;
    }

    /// @dev Calculates partial value given a numerator and denominator rounded down.
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to calculate partial of.
    /// @return Partial value of target rounded up.
    function getPartialAmountCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
    internal
    pure
    returns (uint256 partialAmount)
    {
        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        partialAmount = div(
            add(
                mul(numerator, target),
                sub(denominator, 1)
            ),
            denominator
        );
        return partialAmount;
    }

    /// @dev Checks if rounding error >= 0.1% when rounding down.
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to multiply with numerator/denominator.
    /// @return Rounding error is present.
    function isRoundingErrorFloor(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
    internal
    pure
    returns (bool isError)
    {
        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        // The absolute rounding error is the difference between the rounded
        // value and the ideal value. The relative rounding error is the
        // absolute rounding error divided by the absolute value of the
        // ideal value. This is undefined when the ideal value is zero.
        //
        // The ideal value is `numerator * target / denominator`.
        // Let's call `numerator * target % denominator` the remainder.
        // The absolute error is `remainder / denominator`.
        //
        // When the ideal value is zero, we require the absolute error to
        // be zero. Fortunately, this is always the case. The ideal value is
        // zero iff `numerator == 0` and/or `target == 0`. In this case the
        // remainder and absolute error are also zero.
        if (target == 0 || numerator == 0) {
            return false;
        }

        // Otherwise, we want the relative rounding error to be strictly
        // less than 0.1%.
        // The relative error is `remainder / (numerator * target)`.
        // We want the relative error less than 1 / 1000:
        //        remainder / (numerator * denominator)  <  1 / 1000
        // or equivalently:
        //        1000 * remainder  <  numerator * target
        // so we have a rounding error iff:
        //        1000 * remainder  >=  numerator * target
        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        isError = mul(1000, remainder) >= mul(numerator, target);
        return isError;
    }

    /// @dev Checks if rounding error >= 0.1% when rounding up.
    /// @param numerator Numerator.
    /// @param denominator Denominator.
    /// @param target Value to multiply with numerator/denominator.
    /// @return Rounding error is present.
    function isRoundingErrorCeil(
        uint256 numerator,
        uint256 denominator,
        uint256 target
    )
    internal
    pure
    returns (bool isError)
    {
        require(
            denominator > 0,
            "DIVISION_BY_ZERO"
        );

        // See the comments in `isRoundingError`.
        if (target == 0 || numerator == 0) {
            // When either is zero, the ideal value and rounded value are zero
            // and there is no rounding error. (Although the relative error
            // is undefined.)
            return false;
        }
        // Compute remainder as before
        uint256 remainder = mulmod(
            target,
            numerator,
            denominator
        );
        remainder = sub(denominator, remainder) % denominator;
        isError = mul(1000, remainder) >= mul(numerator, target);
        return isError;
    }
}

// File: contracts/lib/Ownable.sol

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
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
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

// File: contracts/router/IExchangeHandler.sol

/// Interface of exchange handler.
interface IExchangeHandler {

    /// Gets maximum available amount can be spent on order (fee not included).
    /// @param data General order data.
    /// @return availableToFill Amount can be spent on order.
    /// @return feePercentage Fee percentage of order.
    function getAvailableToFill(
        bytes calldata data
    )
    external
    view
    returns (uint256 availableToFill, uint256 feePercentage);

    /// Fills an order on the target exchange.
    /// NOTE: The required funds must be transferred to this contract in the same transaction of calling this function.
    /// @param data General order data.
    /// @param takerAmountToFill Taker token amount to spend on order (fee not included).
    /// @return makerAmountReceived Amount received from trade.
    function fillOrder(
        bytes calldata data,
        uint256 takerAmountToFill
    )
    external
    payable
    returns (uint256 makerAmountReceived);
}

// File: contracts/router/RouterCommon.sol

contract RouterCommon {
    struct GeneralOrder {
        address handler;
        address makerToken;
        address takerToken;
        uint256 makerAmount;
        uint256 takerAmount;
        bytes data;
    }

    struct FillResults {
        uint256 makerAmountReceived;
        uint256 takerAmountSpentOnOrder;
        uint256 takerAmountSpentOnFee;
    }
}

// File: contracts/router/ZeroExV2Handler.sol

/// Abstract contract of core 0x v2 contract.
contract ZeroExV2Exchange {
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

    struct OrderInfo {
        uint8 orderStatus;                    // Status that describes order's validity and fillability.
        bytes32 orderHash;                    // EIP712 hash of the order (see LibOrder.getOrderHash).
        uint256 orderTakerAssetFilledAmount;  // Amount of order that has already been filled.
    }

    struct FillResults {
        uint256 makerAssetFilledAmount;  // Total amount of makerAsset(s) filled.
        uint256 takerAssetFilledAmount;  // Total amount of takerAsset(s) filled.
        uint256 makerFeePaid;            // Total amount of ZRX paid by maker(s) to feeRecipient(s).
        uint256 takerFeePaid;            // Total amount of ZRX paid by taker to feeRecipients(s).
    }

    function getAssetProxy(bytes4 assetProxyId)
    external
    view
    returns (address);

    function isValidSignature(
        bytes32 hash,
        address signerAddress,
        bytes calldata signature
    )
    external
    view
    returns (bool isValid);

    function fillOrder(
        Order calldata order,
        uint256 takerAssetFillAmount,
        bytes calldata signature
    )
    external
    returns (FillResults memory fillResults);

    function getOrderInfo(Order calldata order)
    external
    view
    returns (OrderInfo memory orderInfo);
}

/// Interface of ERC20 approve function.
interface IERC20 {
    function approve(address spender, uint256 value) external returns (bool);
}

// Simple WETH interface to wrap ETH.
interface IWETH {
    function deposit() external payable;
}

/// 0x v2 implementation of exchange handler. ERC721 orders are not currently supported.
contract ZeroExV2Handler is IExchangeHandler, LibMath, Ownable {

    using LibBytes for bytes;

    ZeroExV2Exchange constant public EXCHANGE = ZeroExV2Exchange(0x4F833a24e1f95D70F028921e27040Ca56E09AB0b);
    address constant public WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public ROUTER;
    address payable public FEE_ACCOUNT;
    uint256 public PROCESSING_FEE_PERCENTAGE;

    constructor(
        address router,
        address payable feeAccount,
        uint256 processingFeePercentage
    ) public {
        ROUTER = router;
        FEE_ACCOUNT = feeAccount;
        PROCESSING_FEE_PERCENTAGE = processingFeePercentage;
    }

    /// Fallback function to receive ETH.
    function() external payable {}

    /// Sets fee account. Only contract owner can call this function.
    /// @param feeAccount Fee account address.
    function setFeeAccount(
        address payable feeAccount
    )
    external
    onlyOwner
    {
        FEE_ACCOUNT = feeAccount;
    }

    /// Gets maximum available amount can be spent on order (fee not included).
    /// @param data General order data.
    /// @return availableToFill Amount can be spent on order.
    /// @return feePercentage Fee percentage of order.
    function getAvailableToFill(
        bytes calldata data
    )
    external
    view
    returns (uint256 availableToFill, uint256 feePercentage)
    {
        (ZeroExV2Exchange.Order memory order, bytes memory signature) = getOrder(data);
        ZeroExV2Exchange.OrderInfo memory orderInfo = EXCHANGE.getOrderInfo(order);
        if ((order.takerAddress == address(0) || order.takerAddress == address(this)) &&
            (order.senderAddress == address(0) || order.senderAddress == address(this)) &&
            order.takerFee == 0 &&
            orderInfo.orderStatus == 3 &&
            EXCHANGE.isValidSignature(orderInfo.orderHash, order.makerAddress, signature)
        ) {
            availableToFill = sub(order.takerAssetAmount, orderInfo.orderTakerAssetFilledAmount);
        }
        feePercentage = PROCESSING_FEE_PERCENTAGE;
    }

    /// Fills an order on the target exchange.
    /// NOTE: The required funds must be transferred to this contract in the same transaction of calling this function.
    /// @param data General order data.
    /// @param takerAmountToFill Taker token amount to spend on order (fee not included).
    /// @return makerAmountReceived Amount received from trade.
    function fillOrder(
        bytes calldata data,
        uint256 takerAmountToFill
    )
    external
    payable
    returns (uint256 makerAmountReceived)
    {
        require(msg.sender == ROUTER, "SENDER_NOT_ROUTER");
        (ZeroExV2Exchange.Order memory order, bytes memory signature) = getOrder(data);
        address makerToken = order.makerAssetData.readAddress(16);
        address takerToken = order.takerAssetData.readAddress(16);
        uint256 processingFee = mul(takerAmountToFill, PROCESSING_FEE_PERCENTAGE) / (1 ether);
        if (takerToken == WETH) {
            IWETH(WETH).deposit.value(takerAmountToFill)();
            if (processingFee > 0) {
                require(FEE_ACCOUNT.send(processingFee), "FAILED_SEND_ETH_TO_FEE_ACCOUNT");
            }
        } else if (processingFee > 0) {
            require(ERC20SafeTransfer.safeTransfer(takerToken, FEE_ACCOUNT, processingFee), "FAILED_SEND_ERC20_TO_FEE_ACCOUNT");
        }
        require(IERC20(takerToken).approve(EXCHANGE.getAssetProxy(order.takerAssetData.readBytes4(0)), takerAmountToFill));
        ZeroExV2Exchange.FillResults memory results = EXCHANGE.fillOrder(
            order,
            takerAmountToFill,
            signature
        );
        makerAmountReceived = results.makerAssetFilledAmount;
        if (makerAmountReceived > 0) {
            require(ERC20SafeTransfer.safeTransfer(makerToken, msg.sender, makerAmountReceived), "FAILED_SEND_ERC20_TO_ROUTER");
        }
    }

    /// Assembles order object in 0x format.
    /// @param data General order data.
    /// @return order Order object in 0x format.
    /// @return signature Signature object in 0x format.
    function getOrder(
        bytes memory data
    )
    internal
    pure
    returns (ZeroExV2Exchange.Order memory order, bytes memory signature)
    {
        uint256 makerAssetDataOffset = data.readUint256(320);
        uint256 takerAssetDataOffset = data.readUint256(352);
        uint256 signatureOffset = data.readUint256(384);
        order.makerAddress = data.readAddress(12);
        order.takerAddress = data.readAddress(44);
        order.feeRecipientAddress = data.readAddress(76);
        order.senderAddress = data.readAddress(108);
        order.makerAssetAmount = data.readUint256(128);
        order.takerAssetAmount = data.readUint256(160);
        order.makerFee = data.readUint256(192);
        order.takerFee = data.readUint256(224);
        order.expirationTimeSeconds = data.readUint256(256);
        order.salt = data.readUint256(288);
        order.makerAssetData = data.slice(makerAssetDataOffset + 32, makerAssetDataOffset + 32 + data.readUint256(makerAssetDataOffset));
        order.takerAssetData = data.slice(takerAssetDataOffset + 32, takerAssetDataOffset + 32 + data.readUint256(takerAssetDataOffset));
        signature = data.slice(signatureOffset + 32, signatureOffset + 32 + data.readUint256(signatureOffset));
    }

}