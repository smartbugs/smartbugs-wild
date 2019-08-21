pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;
// File: @0x/contracts-libs/contracts/libs/LibEIP712.sol

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

// File: @0x/contracts-libs/contracts/libs/LibOrder.sol

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

// File: @0x/contracts-utils/contracts/utils/SafeMath/SafeMath.sol

contract SafeMath {

    function safeMul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(
            c / a == b,
            "UINT256_OVERFLOW"
        );
        return c;
    }

    function safeDiv(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 c = a / b;
        return c;
    }

    function safeSub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        require(
            b <= a,
            "UINT256_UNDERFLOW"
        );
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 c = a + b;
        require(
            c >= a,
            "UINT256_OVERFLOW"
        );
        return c;
    }

    function max64(uint64 a, uint64 b)
        internal
        pure
        returns (uint256)
    {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b)
        internal
        pure
        returns (uint256)
    {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return a < b ? a : b;
    }
}

// File: @0x/contracts-libs/contracts/libs/LibFillResults.sol

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




contract LibFillResults is
    SafeMath
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
        totalFillResults.makerAssetFilledAmount = safeAdd(totalFillResults.makerAssetFilledAmount, singleFillResults.makerAssetFilledAmount);
        totalFillResults.takerAssetFilledAmount = safeAdd(totalFillResults.takerAssetFilledAmount, singleFillResults.takerAssetFilledAmount);
        totalFillResults.makerFeePaid = safeAdd(totalFillResults.makerFeePaid, singleFillResults.makerFeePaid);
        totalFillResults.takerFeePaid = safeAdd(totalFillResults.takerFeePaid, singleFillResults.takerFeePaid);
    }
}

// File: @0x/contracts-interfaces/contracts/protocol/Exchange/IExchangeCore.sol

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





contract IExchangeCore {

    /// @dev Cancels all orders created by makerAddress with a salt less than or equal to the targetOrderEpoch
    ///      and senderAddress equal to msg.sender (or null address if msg.sender == makerAddress).
    /// @param targetOrderEpoch Orders created with a salt less or equal to this value will be cancelled.
    function cancelOrdersUpTo(uint256 targetOrderEpoch)
        external;

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

    /// @dev After calling, the order can not be filled anymore.
    /// @param order Order struct containing order specifications.
    function cancelOrder(LibOrder.Order memory order)
        public;

    /// @dev Gets information about an order: status, hash, and amount filled.
    /// @param order Order to gather information on.
    /// @return OrderInfo Information about the order and its state.
    ///                   See LibOrder.OrderInfo for a complete description.
    function getOrderInfo(LibOrder.Order memory order)
        public
        view
        returns (LibOrder.OrderInfo memory orderInfo);
}

// File: @0x/contracts-interfaces/contracts/protocol/Exchange/IMatchOrders.sol

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





contract IMatchOrders {

    /// @dev Match two complementary orders that have a profitable spread.
    ///      Each order is filled at their respective price point. However, the calculations are
    ///      carried out as though the orders are both being filled at the right order's price point.
    ///      The profit made by the left order goes to the taker (who matched the two orders).
    /// @param leftOrder First order to match.
    /// @param rightOrder Second order to match.
    /// @param leftSignature Proof that order was created by the left maker.
    /// @param rightSignature Proof that order was created by the right maker.
    /// @return matchedFillResults Amounts filled and fees paid by maker and taker of matched orders.
    function matchOrders(
        LibOrder.Order memory leftOrder,
        LibOrder.Order memory rightOrder,
        bytes memory leftSignature,
        bytes memory rightSignature
    )
        public
        returns (LibFillResults.MatchedFillResults memory matchedFillResults);
}

// File: @0x/contracts-interfaces/contracts/protocol/Exchange/ISignatureValidator.sol

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



contract ISignatureValidator {

    /// @dev Approves a hash on-chain using any valid signature type.
    ///      After presigning a hash, the preSign signature type will become valid for that hash and signer.
    /// @param signerAddress Address that should have signed the given hash.
    /// @param signature Proof that the hash has been signed by signer.
    function preSign(
        bytes32 hash,
        address signerAddress,
        bytes signature
    )
        external;
    
    /// @dev Approves/unnapproves a Validator contract to verify signatures on signer's behalf.
    /// @param validatorAddress Address of Validator contract.
    /// @param approval Approval or disapproval of  Validator contract.
    function setSignatureValidatorApproval(
        address validatorAddress,
        bool approval
    )
        external;

    /// @dev Verifies that a signature is valid.
    /// @param hash Message hash that is signed.
    /// @param signerAddress Address of signer.
    /// @param signature Proof of signing.
    /// @return Validity of order signature.
    function isValidSignature(
        bytes32 hash,
        address signerAddress,
        bytes memory signature
    )
        public
        view
        returns (bool isValid);
}

// File: @0x/contracts-interfaces/contracts/protocol/Exchange/ITransactions.sol

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


contract ITransactions {

    /// @dev Executes an exchange method call in the context of signer.
    /// @param salt Arbitrary number to ensure uniqueness of transaction hash.
    /// @param signerAddress Address of transaction signer.
    /// @param data AbiV2 encoded calldata.
    /// @param signature Proof of signer transaction by signer.
    function executeTransaction(
        uint256 salt,
        address signerAddress,
        bytes data,
        bytes signature
    )
        external;
}

// File: @0x/contracts-interfaces/contracts/protocol/Exchange/IAssetProxyDispatcher.sol

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



contract IAssetProxyDispatcher {

    /// @dev Registers an asset proxy to its asset proxy id.
    ///      Once an asset proxy is registered, it cannot be unregistered.
    /// @param assetProxy Address of new asset proxy to register.
    function registerAssetProxy(address assetProxy)
        external;

    /// @dev Gets an asset proxy.
    /// @param assetProxyId Id of the asset proxy.
    /// @return The asset proxy registered to assetProxyId. Returns 0x0 if no proxy is registered.
    function getAssetProxy(bytes4 assetProxyId)
        external
        view
        returns (address);
}

// File: @0x/contracts-interfaces/contracts/protocol/Exchange/IWrapperFunctions.sol

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





contract IWrapperFunctions {

    /// @dev Fills the input order. Reverts if exact takerAssetFillAmount not filled.
    /// @param order LibOrder.Order struct containing order specifications.
    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.
    /// @param signature Proof that order has been created by maker.
    function fillOrKillOrder(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        returns (LibFillResults.FillResults memory fillResults);

    /// @dev Fills an order with specified parameters and ECDSA signature.
    ///      Returns false if the transaction would otherwise revert.
    /// @param order LibOrder.Order struct containing order specifications.
    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.
    /// @param signature Proof that order has been created by maker.
    /// @return Amounts filled and fees paid by maker and taker.
    function fillOrderNoThrow(
        LibOrder.Order memory order,
        uint256 takerAssetFillAmount,
        bytes memory signature
    )
        public
        returns (LibFillResults.FillResults memory fillResults);

    /// @dev Synchronously executes multiple calls of fillOrder.
    /// @param orders Array of order specifications.
    /// @param takerAssetFillAmounts Array of desired amounts of takerAsset to sell in orders.
    /// @param signatures Proofs that orders have been created by makers.
    /// @return Amounts filled and fees paid by makers and taker.
    function batchFillOrders(
        LibOrder.Order[] memory orders,
        uint256[] memory takerAssetFillAmounts,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);

    /// @dev Synchronously executes multiple calls of fillOrKill.
    /// @param orders Array of order specifications.
    /// @param takerAssetFillAmounts Array of desired amounts of takerAsset to sell in orders.
    /// @param signatures Proofs that orders have been created by makers.
    /// @return Amounts filled and fees paid by makers and taker.
    function batchFillOrKillOrders(
        LibOrder.Order[] memory orders,
        uint256[] memory takerAssetFillAmounts,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);

    /// @dev Fills an order with specified parameters and ECDSA signature.
    ///      Returns false if the transaction would otherwise revert.
    /// @param orders Array of order specifications.
    /// @param takerAssetFillAmounts Array of desired amounts of takerAsset to sell in orders.
    /// @param signatures Proofs that orders have been created by makers.
    /// @return Amounts filled and fees paid by makers and taker.
    function batchFillOrdersNoThrow(
        LibOrder.Order[] memory orders,
        uint256[] memory takerAssetFillAmounts,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);

    /// @dev Synchronously executes multiple calls of fillOrder until total amount of takerAsset is sold by taker.
    /// @param orders Array of order specifications.
    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.
    /// @param signatures Proofs that orders have been created by makers.
    /// @return Amounts filled and fees paid by makers and taker.
    function marketSellOrders(
        LibOrder.Order[] memory orders,
        uint256 takerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);

    /// @dev Synchronously executes multiple calls of fillOrder until total amount of takerAsset is sold by taker.
    ///      Returns false if the transaction would otherwise revert.
    /// @param orders Array of order specifications.
    /// @param takerAssetFillAmount Desired amount of takerAsset to sell.
    /// @param signatures Proofs that orders have been signed by makers.
    /// @return Amounts filled and fees paid by makers and taker.
    function marketSellOrdersNoThrow(
        LibOrder.Order[] memory orders,
        uint256 takerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);

    /// @dev Synchronously executes multiple calls of fillOrder until total amount of makerAsset is bought by taker.
    /// @param orders Array of order specifications.
    /// @param makerAssetFillAmount Desired amount of makerAsset to buy.
    /// @param signatures Proofs that orders have been signed by makers.
    /// @return Amounts filled and fees paid by makers and taker.
    function marketBuyOrders(
        LibOrder.Order[] memory orders,
        uint256 makerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);

    /// @dev Synchronously executes multiple fill orders in a single transaction until total amount is bought by taker.
    ///      Returns false if the transaction would otherwise revert.
    /// @param orders Array of order specifications.
    /// @param makerAssetFillAmount Desired amount of makerAsset to buy.
    /// @param signatures Proofs that orders have been signed by makers.
    /// @return Amounts filled and fees paid by makers and taker.
    function marketBuyOrdersNoThrow(
        LibOrder.Order[] memory orders,
        uint256 makerAssetFillAmount,
        bytes[] memory signatures
    )
        public
        returns (LibFillResults.FillResults memory totalFillResults);

    /// @dev Synchronously cancels multiple orders in a single transaction.
    /// @param orders Array of order specifications.
    function batchCancelOrders(LibOrder.Order[] memory orders)
        public;

    /// @dev Fetches information for all passed in orders
    /// @param orders Array of order specifications.
    /// @return Array of OrderInfo instances that correspond to each order.
    function getOrdersInfo(LibOrder.Order[] memory orders)
        public
        view
        returns (LibOrder.OrderInfo[] memory);
}

// File: @0x/contracts-interfaces/contracts/protocol/Exchange/IExchange.sol

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









// solhint-disable no-empty-blocks
contract IExchange is
    IExchangeCore,
    IMatchOrders,
    ISignatureValidator,
    ITransactions,
    IAssetProxyDispatcher,
    IWrapperFunctions
{}

// File: contracts/RequirementFilter/libs/LibConstants.sol

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




contract LibConstants {

    bytes4 constant internal ERC20_DATA_ID = bytes4(keccak256("ERC20Token(address)"));
    bytes4 constant internal ERC721_DATA_ID = bytes4(keccak256("ERC721Token(address,uint256)"));
    bytes4 constant internal BALANCE_THRESHOLD_DATA_ID = bytes4(keccak256("BalanceThreshold(address,uint256)"));
    bytes4 constant internal OWNERSHIP_DATA_ID = bytes4(keccak256("Ownership(address,uint256)"));
    bytes4 constant internal FILLED_TIMES_DATA_ID = bytes4(keccak256("FilledTimes(uint256)"));
    uint256 constant internal MAX_UINT = 2**256 - 1;
 
    // solhint-disable var-name-mixedcase
    IExchange internal EXCHANGE;
    // solhint-enable var-name-mixedcase

    constructor (address exchange)
        public
    {
        EXCHANGE = IExchange(exchange);
    }
}

// File: contracts/RequirementFilter/mixins/MExchangeCalldata.sol

/*

  Copyright 2018 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/




contract MExchangeCalldata {

    /// @dev Emulates the `calldataload` opcode on the embedded Exchange calldata,
    ///      which is accessed through `signedExchangeTransaction`.
    /// @param offset  Offset into the Exchange calldata.
    /// @return value  Corresponding 32 byte value stored at `offset`.
    function exchangeCalldataload(uint256 offset)
        internal pure
        returns (bytes32 value);

    /// @dev Extracts the takerAssetData from an order stored in the Exchange calldata
    ///      (which is embedded in `signedExchangeTransaction`).
    /// @return takerAssetData The extracted takerAssetData.
    function loadTakerAssetDataFromOrder()
        internal pure
        returns (uint256 takerAssetAmount, bytes memory takerAssetData);

    /// @dev Extracts the signature from an order stored in the Exchange calldata
    ///      (which is embedded in `signedExchangeTransaction`).
    /// @return signature The extracted signature.
    function loadSignatureFromExchangeCalldata()
        internal pure
        returns (bytes memory signature);
}

// File: contracts/RequirementFilter/MixinExchangeCalldata.sol

/*

  Copyright 2018 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/





contract MixinExchangeCalldata
    is MExchangeCalldata
{

    /// @dev Emulates the `calldataload` opcode on the embedded Exchange calldata,
    ///      which is accessed through `signedExchangeTransaction`.
    /// @param offset  Offset into the Exchange calldata.
    /// @return value  Corresponding 32 byte value stored at `offset`.
    function exchangeCalldataload(uint256 offset)
        internal pure
        returns (bytes32 value)
    {
        assembly {
            // Pointer to exchange transaction
            // 0x04 for calldata selector
            // 0x40 to access `signedExchangeTransaction`, which is the third parameter
            let exchangeTxPtr := calldataload(0x44)

            // Offset into Exchange calldata
            // We compute this by adding 0x24 to the `exchangeTxPtr` computed above.
            // 0x04 for calldata selector
            // 0x20 for length field of `signedExchangeTransaction`
            let exchangeCalldataOffset := add(exchangeTxPtr, add(0x24, offset))
            value := calldataload(exchangeCalldataOffset)
        }
        return value;
    }

    /// @dev Extracts the takerAssetData from an order stored in the Exchange calldata
    ///      (which is embedded in `signedExchangeTransaction`).
    /// @return takerAssetData The extracted takerAssetData.
    function loadTakerAssetDataFromOrder()
        internal pure
        returns (uint256 takerAssetAmount, bytes memory takerAssetData)
    {
        assembly {
            takerAssetData := mload(0x40)
            // Offset to exchange calldata
            // 0x04 for calldata selector
            // 0x40 to access `signedExchangeTransaction`, which is the third parameter
            let exchangeCalldataOffset := add(0x28, calldataload(0x44))
            // Offset to order
            let orderOffset := add(exchangeCalldataOffset, calldataload(exchangeCalldataOffset))
            // Offset to takerAssetData
            takerAssetAmount := calldataload(add(orderOffset, 160))
            let takerAssetDataOffset := add(orderOffset, calldataload(add(orderOffset, 352)))
            let takerAssetDataLength := calldataload(takerAssetDataOffset)
            // Locate new memory including padding
            mstore(0x40, add(takerAssetData, and(add(add(takerAssetDataLength, 0x20), 0x1f), not(0x1f))))
            mstore(takerAssetData, takerAssetDataLength)
            // Copy takerAssetData
            calldatacopy(add(takerAssetData, 32), add(takerAssetDataOffset, 32), takerAssetDataLength)
        }

        return (takerAssetAmount, takerAssetData);
    }

    /// @dev Extracts the signature from an order stored in the Exchange calldata
    ///      (which is embedded in `signedExchangeTransaction`).
    /// @return signature The extracted signature.
    function loadSignatureFromExchangeCalldata()
        internal pure
        returns (bytes memory signature)
    {
        assembly {
            signature := mload(0x40)
            // Offset to exchange calldata
            // 0x04 for calldata selector
            // 0x40 to access `signedExchangeTransaction`, which is the third parameter
            let exchangeCalldataOffset := add(0x28, calldataload(0x44))
            // Offset to signature
            // 0x40 to access `signature`, which is the third parameter of `fillOrder`
            let signatureOffset := add(exchangeCalldataOffset, calldataload(add(exchangeCalldataOffset, 0x40)))
            let signatureLength := calldataload(signatureOffset)
            // Locate new memory including padding
            mstore(0x40, add(signature, and(add(add(signatureLength, 0x20), 0x1f), not(0x1f))))
            mstore(signature, signatureLength)
            // Copy takerAssetData
            calldatacopy(add(signature, 32), add(signatureOffset, 32), signatureLength)
        }

        return signature;
    }
}

// File: contracts/RequirementFilter/MixinFakeERC20Token.sol

contract MixinFakeERC20Token is
    LibConstants
{
    /// @dev Fake `transferFrom` for scenorios like puzzle huting, airdrop, etc...
    /// @param from The address of the sender
    /// @param to The address of the recipient
    /// @param amount The amount of token to be transferred
    /// @return True if transfer was successful
    function transferFrom(address from, address to, uint256 amount)
        external returns (bool)
    {
        require(
            amount == 1,
            "INVALID_TAKER_ASSET_FILL_AMOUNT"
        );
        return true;
    }

    /// @dev Fake `allowance` for scenorios like puzzle huting, airdrop, etc...
    /// @param owner The address of the account owning tokens
    /// @param spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address owner, address spender)
        external pure returns (uint256)
    {
        return MAX_UINT;
    }
}

// File: contracts/RequirementFilter/interfaces/IRequiredAsset.sol

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



contract IRequiredAsset {

    /// @dev Check balanceOf owner
    /// @param owner The address from which the balance will be retrieved
    /// @return Balance of owner
    function balanceOf(address owner)
        external
        view
        returns (uint256);

    /// @dev Check ownerOf tokenId
    /// @param tokenId The token id from which the ownership will be checked
    /// @return Owner address of tokenId
    function ownerOf(uint256 tokenId)
        external
        view
        returns (address);
}

// File: contracts/RequirementFilter/interfaces/IRequirementFilterCore.sol

contract IRequirementFilterCore {

    /// @dev Executes an Exchange transaction iff the maker and taker meet 
    ///      all requirements specified in `takerAssetData`
    ///      Supported Exchange functions:
    ///         - fillOrder
    ///      Trying to call any other exchange function will throw.
    /// @param salt Arbitrary number to ensure uniqueness of transaction hash.
    /// @param signerAddress Address of transaction signer.
    /// @param signedExchangeTransaction AbiV2 encoded calldata.
    /// @param signature Proof of signer transaction by signer.
    function executeTransaction(
        uint256 salt,
        address signerAddress,
        bytes signedExchangeTransaction,
        bytes signature
    ) 
        external
        returns (bool success);

    /// @dev Chech whether input signerAddress has achieved all
    ///      requirements specified in `takerAssetData`. Return
    ///      array of boolean of requirements' achievement.
    /// @param takerAssetData TakerAssetData extracted from signedExchangeTransaction.
    /// @param signerAddress Address of transaction signer.
    function getRequirementsAchieved(
        bytes memory takerAssetData,
        address signerAddress
    )
        public view
        returns (bool[] memory requirementsAchieved);
}

// File: contracts/RequirementFilter/mixins/MRequirementFilterCore.sol

contract MRequirementFilterCore is
    IRequirementFilterCore
{
    mapping(bytes32 => mapping(address => uint256)) internal filledTimes;

    /// @dev Validates signerAddress's filling times is in limitation. Succeeds or throws.
    /// @param takerAssetData TakerAssetData extracted from signedExchangeTransaction.
    /// @param embeddedSignature Signature extracted from signedExchangeTransaction.
    /// @param signerAddress Signer of signedExchangeTransaction.
    function assertValidFilledTimes(bytes memory takerAssetData, bytes memory embeddedSignature, address signerAddress)
        internal
        returns (bool);

    /// @dev Validates all requirements' achievement. Succeeds or throws.
    /// @param takerAssetData TakerAssetData extracted from signedExchangeTransaction.
    /// @param signerAddress Signer of signedExchangeTransaction.
    function assertRequirementsAchieved(bytes memory takerAssetData, address signerAddress)
        internal view
        returns (bool);
}

// File: @0x/contracts-libs/contracts/libs/LibExchangeSelectors.sol

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



contract LibExchangeSelectors {

    // solhint-disable max-line-length
    // allowedValidators
    bytes4 constant public ALLOWED_VALIDATORS_SELECTOR = 0x7b8e3514;
    bytes4 constant public ALLOWED_VALIDATORS_SELECTOR_GENERATOR = bytes4(keccak256("allowedValidators(address,address)"));

    // assetProxies
    bytes4 constant public ASSET_PROXIES_SELECTOR = 0x3fd3c997;
    bytes4 constant public ASSET_PROXIES_SELECTOR_GENERATOR = bytes4(keccak256("assetProxies(bytes4)"));

    // batchCancelOrders
    bytes4 constant public BATCH_CANCEL_ORDERS_SELECTOR = 0x4ac14782;
    bytes4 constant public BATCH_CANCEL_ORDERS_SELECTOR_GENERATOR = bytes4(keccak256("batchCancelOrders((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes)[])"));

    // batchFillOrKillOrders
    bytes4 constant public BATCH_FILL_OR_KILL_ORDERS_SELECTOR = 0x4d0ae546;
    bytes4 constant public BATCH_FILL_OR_KILL_ORDERS_SELECTOR_GENERATOR = bytes4(keccak256("batchFillOrKillOrders((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes)[],uint256[],bytes[])"));

    // batchFillOrders
    bytes4 constant public BATCH_FILL_ORDERS_SELECTOR = 0x297bb70b;
    bytes4 constant public BATCH_FILL_ORDERS_SELECTOR_GENERATOR = bytes4(keccak256("batchFillOrders((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes)[],uint256[],bytes[])"));

    // batchFillOrdersNoThrow
    bytes4 constant public BATCH_FILL_ORDERS_NO_THROW_SELECTOR = 0x50dde190;
    bytes4 constant public BATCH_FILL_ORDERS_NO_THROW_SELECTOR_GENERATOR = bytes4(keccak256("batchFillOrdersNoThrow((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes)[],uint256[],bytes[])"));

    // cancelOrder
    bytes4 constant public CANCEL_ORDER_SELECTOR = 0xd46b02c3;
    bytes4 constant public CANCEL_ORDER_SELECTOR_GENERATOR = bytes4(keccak256("cancelOrder((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes))"));

    // cancelOrdersUpTo
    bytes4 constant public CANCEL_ORDERS_UP_TO_SELECTOR = 0x4f9559b1;
    bytes4 constant public CANCEL_ORDERS_UP_TO_SELECTOR_GENERATOR = bytes4(keccak256("cancelOrdersUpTo(uint256)"));

    // cancelled
    bytes4 constant public CANCELLED_SELECTOR = 0x2ac12622;
    bytes4 constant public CANCELLED_SELECTOR_GENERATOR = bytes4(keccak256("cancelled(bytes32)"));

    // currentContextAddress
    bytes4 constant public CURRENT_CONTEXT_ADDRESS_SELECTOR = 0xeea086ba;
    bytes4 constant public CURRENT_CONTEXT_ADDRESS_SELECTOR_GENERATOR = bytes4(keccak256("currentContextAddress()"));

    // executeTransaction
    bytes4 constant public EXECUTE_TRANSACTION_SELECTOR = 0xbfc8bfce;
    bytes4 constant public EXECUTE_TRANSACTION_SELECTOR_GENERATOR = bytes4(keccak256("executeTransaction(uint256,address,bytes,bytes)"));

    // fillOrKillOrder
    bytes4 constant public FILL_OR_KILL_ORDER_SELECTOR = 0x64a3bc15;
    bytes4 constant public FILL_OR_KILL_ORDER_SELECTOR_GENERATOR = bytes4(keccak256("fillOrKillOrder((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes),uint256,bytes)"));

    // fillOrder
    bytes4 constant public FILL_ORDER_SELECTOR = 0xb4be83d5;
    bytes4 constant public FILL_ORDER_SELECTOR_GENERATOR = bytes4(keccak256("fillOrder((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes),uint256,bytes)"));

    // fillOrderNoThrow
    bytes4 constant public FILL_ORDER_NO_THROW_SELECTOR = 0x3e228bae;
    bytes4 constant public FILL_ORDER_NO_THROW_SELECTOR_GENERATOR = bytes4(keccak256("fillOrderNoThrow((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes),uint256,bytes)"));

    // filled
    bytes4 constant public FILLED_SELECTOR = 0x288cdc91;
    bytes4 constant public FILLED_SELECTOR_GENERATOR = bytes4(keccak256("filled(bytes32)"));

    // getAssetProxy
    bytes4 constant public GET_ASSET_PROXY_SELECTOR = 0x60704108;
    bytes4 constant public GET_ASSET_PROXY_SELECTOR_GENERATOR = bytes4(keccak256("getAssetProxy(bytes4)"));

    // getOrderInfo
    bytes4 constant public GET_ORDER_INFO_SELECTOR = 0xc75e0a81;
    bytes4 constant public GET_ORDER_INFO_SELECTOR_GENERATOR = bytes4(keccak256("getOrderInfo((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes))"));

    // getOrdersInfo
    bytes4 constant public GET_ORDERS_INFO_SELECTOR = 0x7e9d74dc;
    bytes4 constant public GET_ORDERS_INFO_SELECTOR_GENERATOR = bytes4(keccak256("getOrdersInfo((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes)[])"));

    // isValidSignature
    bytes4 constant public IS_VALID_SIGNATURE_SELECTOR = 0x93634702;
    bytes4 constant public IS_VALID_SIGNATURE_SELECTOR_GENERATOR = bytes4(keccak256("isValidSignature(bytes32,address,bytes)"));

    // marketBuyOrders
    bytes4 constant public MARKET_BUY_ORDERS_SELECTOR = 0xe5fa431b;
    bytes4 constant public MARKET_BUY_ORDERS_SELECTOR_GENERATOR = bytes4(keccak256("marketBuyOrders((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes)[],uint256,bytes[])"));

    // marketBuyOrdersNoThrow
    bytes4 constant public MARKET_BUY_ORDERS_NO_THROW_SELECTOR = 0xa3e20380;
    bytes4 constant public MARKET_BUY_ORDERS_NO_THROW_SELECTOR_GENERATOR = bytes4(keccak256("marketBuyOrdersNoThrow((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes)[],uint256,bytes[])"));

    // marketSellOrders
    bytes4 constant public MARKET_SELL_ORDERS_SELECTOR = 0x7e1d9808;
    bytes4 constant public MARKET_SELL_ORDERS_SELECTOR_GENERATOR = bytes4(keccak256("marketSellOrders((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes)[],uint256,bytes[])"));

    // marketSellOrdersNoThrow
    bytes4 constant public MARKET_SELL_ORDERS_NO_THROW_SELECTOR = 0xdd1c7d18;
    bytes4 constant public MARKET_SELL_ORDERS_NO_THROW_SELECTOR_GENERATOR = bytes4(keccak256("marketSellOrdersNoThrow((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes)[],uint256,bytes[])"));

    // matchOrders
    bytes4 constant public MATCH_ORDERS_SELECTOR = 0x3c28d861;
    bytes4 constant public MATCH_ORDERS_SELECTOR_GENERATOR = bytes4(keccak256("matchOrders((address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes),(address,address,address,address,uint256,uint256,uint256,uint256,uint256,uint256,bytes,bytes),bytes,bytes)"));

    // orderEpoch
    bytes4 constant public ORDER_EPOCH_SELECTOR = 0xd9bfa73e;
    bytes4 constant public ORDER_EPOCH_SELECTOR_GENERATOR = bytes4(keccak256("orderEpoch(address,address)"));

    // owner
    bytes4 constant public OWNER_SELECTOR = 0x8da5cb5b;
    bytes4 constant public OWNER_SELECTOR_GENERATOR = bytes4(keccak256("owner()"));

    // preSign
    bytes4 constant public PRE_SIGN_SELECTOR = 0x3683ef8e;
    bytes4 constant public PRE_SIGN_SELECTOR_GENERATOR = bytes4(keccak256("preSign(bytes32,address,bytes)"));

    // preSigned
    bytes4 constant public PRE_SIGNED_SELECTOR = 0x82c174d0;
    bytes4 constant public PRE_SIGNED_SELECTOR_GENERATOR = bytes4(keccak256("preSigned(bytes32,address)"));

    // registerAssetProxy
    bytes4 constant public REGISTER_ASSET_PROXY_SELECTOR = 0xc585bb93;
    bytes4 constant public REGISTER_ASSET_PROXY_SELECTOR_GENERATOR = bytes4(keccak256("registerAssetProxy(address)"));

    // setSignatureValidatorApproval
    bytes4 constant public SET_SIGNATURE_VALIDATOR_APPROVAL_SELECTOR = 0x77fcce68;
    bytes4 constant public SET_SIGNATURE_VALIDATOR_APPROVAL_SELECTOR_GENERATOR = bytes4(keccak256("setSignatureValidatorApproval(address,bool)"));

    // transactions
    bytes4 constant public TRANSACTIONS_SELECTOR = 0x642f2eaf;
    bytes4 constant public TRANSACTIONS_SELECTOR_GENERATOR = bytes4(keccak256("transactions(bytes32)"));

    // transferOwnership
    bytes4 constant public TRANSFER_OWNERSHIP_SELECTOR = 0xf2fde38b;
    bytes4 constant public TRANSFER_OWNERSHIP_SELECTOR_GENERATOR = bytes4(keccak256("transferOwnership(address)"));
}

// File: @0x/contracts-utils/contracts/utils/LibBytes/LibBytes.sol

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

    /// @dev Gets the memory address for a byte array.
    /// @param input Byte array to lookup.
    /// @return memoryAddress Memory address of byte array. This
    ///         points to the header of the byte array which contains
    ///         the length.
    function rawAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := input
        }
        return memoryAddress;
    }
    
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
        require(
            from <= to,
            "FROM_LESS_THAN_TO_REQUIRED"
        );
        require(
            to < b.length,
            "TO_LESS_THAN_LENGTH_REQUIRED"
        );
        
        // Create a new bytes structure and copy contents
        result = new bytes(to - from);
        memCopy(
            result.contentAddress(),
            b.contentAddress() + from,
            result.length
        );
        return result;
    }
    
    /// @dev Returns a slice from a byte array without preserving the input.
    /// @param b The byte array to take a slice from. Will be destroyed in the process.
    /// @param from The starting index for the slice (inclusive).
    /// @param to The final index for the slice (exclusive).
    /// @return result The slice containing bytes at indices [from, to)
    /// @dev When `from == 0`, the original array will match the slice. In other cases its state will be corrupted.
    function sliceDestructive(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        require(
            from <= to,
            "FROM_LESS_THAN_TO_REQUIRED"
        );
        require(
            to < b.length,
            "TO_LESS_THAN_LENGTH_REQUIRED"
        );
        
        // Create a new bytes structure around [from, to) in-place.
        assembly {
            result := add(b, from)
            mstore(result, sub(to, from))
        }
        return result;
    }

    /// @dev Pops the last byte off of a byte array by modifying its length.
    /// @param b Byte array that will be modified.
    /// @return The byte that was popped off.
    function popLastByte(bytes memory b)
        internal
        pure
        returns (bytes1 result)
    {
        require(
            b.length > 0,
            "GREATER_THAN_ZERO_LENGTH_REQUIRED"
        );

        // Store last byte.
        result = b[b.length - 1];

        assembly {
            // Decrement length of byte array.
            let newLen := sub(mload(b), 1)
            mstore(b, newLen)
        }
        return result;
    }

    /// @dev Pops the last 20 bytes off of a byte array by modifying its length.
    /// @param b Byte array that will be modified.
    /// @return The 20 byte address that was popped off.
    function popLast20Bytes(bytes memory b)
        internal
        pure
        returns (address result)
    {
        require(
            b.length >= 20,
            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"
        );

        // Store last 20 bytes.
        result = readAddress(b, b.length - 20);

        assembly {
            // Subtract 20 from byte array length.
            let newLen := sub(mload(b), 20)
            mstore(b, newLen)
        }
        return result;
    }

    /// @dev Tests equality of two byte arrays.
    /// @param lhs First byte array to compare.
    /// @param rhs Second byte array to compare.
    /// @return True if arrays are the same. False otherwise.
    function equals(
        bytes memory lhs,
        bytes memory rhs
    )
        internal
        pure
        returns (bool equal)
    {
        // Keccak gas cost is 30 + numWords * 6. This is a cheap way to compare.
        // We early exit on unequal lengths, but keccak would also correctly
        // handle this.
        return lhs.length == rhs.length && keccak256(lhs) == keccak256(rhs);
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

    /// @dev Writes an address into a specific position in a byte array.
    /// @param b Byte array to insert address into.
    /// @param index Index in byte array of address.
    /// @param input Address to put into byte array.
    function writeAddress(
        bytes memory b,
        uint256 index,
        address input
    )
        internal
        pure
    {
        require(
            b.length >= index + 20,  // 20 is length of address
            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"
        );

        // Add offset to index:
        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)
        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)
        index += 20;

        // Store address into array memory
        assembly {
            // The address occupies 20 bytes and mstore stores 32 bytes.
            // First fetch the 32-byte word where we'll be storing the address, then
            // apply a mask so we have only the bytes in the word that the address will not occupy.
            // Then combine these bytes with the address and store the 32 bytes back to memory with mstore.

            // 1. Add index to address of bytes array
            // 2. Load 32-byte word from memory
            // 3. Apply 12-byte mask to obtain extra bytes occupying word of memory where we'll store the address
            let neighbors := and(
                mload(add(b, index)),
                0xffffffffffffffffffffffff0000000000000000000000000000000000000000
            )
            
            // Make sure input address is clean.
            // (Solidity does not guarantee this)
            input := and(input, 0xffffffffffffffffffffffffffffffffffffffff)

            // Store the neighbors and address into memory
            mstore(add(b, index), xor(input, neighbors))
        }
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

    /// @dev Writes a bytes32 into a specific position in a byte array.
    /// @param b Byte array to insert <input> into.
    /// @param index Index in byte array of <input>.
    /// @param input bytes32 to put into byte array.
    function writeBytes32(
        bytes memory b,
        uint256 index,
        bytes32 input
    )
        internal
        pure
    {
        require(
            b.length >= index + 32,
            "GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED"
        );

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            mstore(add(b, index), input)
        }
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

    /// @dev Writes a uint256 into a specific position in a byte array.
    /// @param b Byte array to insert <input> into.
    /// @param index Index in byte array of <input>.
    /// @param input uint256 to put into byte array.
    function writeUint256(
        bytes memory b,
        uint256 index,
        uint256 input
    )
        internal
        pure
    {
        writeBytes32(b, index, bytes32(input));
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

    /// @dev Reads nested bytes from a specific position.
    /// @dev NOTE: the returned value overlaps with the input value.
    ///            Both should be treated as immutable.
    /// @param b Byte array containing nested bytes.
    /// @param index Index of nested bytes.
    /// @return result Nested bytes.
    function readBytesWithLength(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes memory result)
    {
        // Read length of nested bytes
        uint256 nestedBytesLength = readUint256(b, index);
        index += 32;

        // Assert length of <b> is valid, given
        // length of nested bytes
        require(
            b.length >= index + nestedBytesLength,
            "GREATER_OR_EQUAL_TO_NESTED_BYTES_LENGTH_REQUIRED"
        );
        
        // Return a pointer to the byte array as it exists inside `b`
        assembly {
            result := add(b, index)
        }
        return result;
    }

    /// @dev Inserts bytes at a specific position in a byte array.
    /// @param b Byte array to insert <input> into.
    /// @param index Index in byte array of <input>.
    /// @param input bytes to insert.
    function writeBytesWithLength(
        bytes memory b,
        uint256 index,
        bytes memory input
    )
        internal
        pure
    {
        // Assert length of <b> is valid, given
        // length of input
        require(
            b.length >= index + 32 + input.length,  // 32 bytes to store length
            "GREATER_OR_EQUAL_TO_NESTED_BYTES_LENGTH_REQUIRED"
        );

        // Copy <input> into <b>
        memCopy(
            b.contentAddress() + index,
            input.rawAddress(), // includes length of <input>
            input.length + 32   // +32 bytes to store <input> length
        );
    }

    /// @dev Performs a deep copy of a byte array onto another byte array of greater than or equal length.
    /// @param dest Byte array that will be overwritten with source bytes.
    /// @param source Byte array to copy onto dest bytes.
    function deepCopyBytes(
        bytes memory dest,
        bytes memory source
    )
        internal
        pure
    {
        uint256 sourceLen = source.length;
        // Dest length must be >= source length, or some bytes would not be copied.
        require(
            dest.length >= sourceLen,
            "GREATER_OR_EQUAL_TO_SOURCE_BYTES_LENGTH_REQUIRED"
        );
        memCopy(
            dest.contentAddress(),
            source.contentAddress(),
            sourceLen
        );
    }
}

// File: contracts/RequirementFilter/MixinRequirementFilterCore.sol

contract MixinRequirementFilterCore is
    LibConstants,
    LibExchangeSelectors,
    MExchangeCalldata,
    MRequirementFilterCore
{
    using LibBytes for bytes;

    /// @dev Executes an Exchange transaction iff the maker and taker meet 
    ///      all requirements specified in `takerAssetData`
    ///      Supported Exchange functions:
    ///         - fillOrder
    ///      Trying to call any other exchange function will throw.
    /// @param salt Arbitrary number to ensure uniqueness of transaction hash.
    /// @param signerAddress Address of transaction signer.
    /// @param signedExchangeTransaction AbiV2 encoded calldata.
    /// @param signature Proof of signer transaction by signer.
    function executeTransaction(
        uint256 salt,
        address signerAddress,
        bytes signedExchangeTransaction,
        bytes signature
    ) 
        external
        returns (bool success)
    {
        bytes4 exchangeCalldataSelector = bytes4(exchangeCalldataload(0));

        require(
            exchangeCalldataSelector == LibExchangeSelectors.FILL_ORDER_SELECTOR,
            "INVALID_EXCHANGE_SELECTOR"
        );

        (uint256 takerAssetAmount, bytes memory takerAssetData) = loadTakerAssetDataFromOrder();
        bytes memory embeddedSignature = loadSignatureFromExchangeCalldata();

        // Assert valid filled times if takerAssetAmoun is larger than 1
        if (takerAssetAmount > 1) {
            assertValidFilledTimes(takerAssetData, embeddedSignature, signerAddress);
        }
        // Assert all requirements achieved
        assertRequirementsAchieved(takerAssetData, signerAddress);

        // All assertion passed. Execute exchange function.
        EXCHANGE.executeTransaction(
            salt,
            signerAddress,
            signedExchangeTransaction,
            signature
        );

        return true;
    }

    /// @dev Chech whether input signerAddress has achieved all
    ///      requirements specified in `takerAssetData`. Return
    ///      array of boolean of requirements' achievement.
    /// @param takerAssetData TakerAssetData extracted from signedExchangeTransaction.
    /// @param signerAddress Address of transaction signer.
    function getRequirementsAchieved(bytes memory takerAssetData, address signerAddress)
        public view
        returns (bool[] memory requirementsAchieved)
    {
        uint256 index;
        bytes4 proxyId = takerAssetData.readBytes4(0);

        if (proxyId == ERC20_DATA_ID) {
            index = 36;
        } else if (proxyId == ERC721_DATA_ID) {
            index = 68;
        } else {
            revert("UNSUPPORTED_ASSET_PROXY");
        }

        uint256 requirementsNumber = 0;
        uint256 takerAssetDataLength = takerAssetData.length;
        requirementsAchieved = new bool[]((takerAssetDataLength - index) / 68);

        while (index < takerAssetDataLength) {
            bytes4 dataId = takerAssetData.readBytes4(index);
            address tokenAddress = takerAssetData.readAddress(index + 16);
            IRequiredAsset requiredToken = IRequiredAsset(tokenAddress);

            if (dataId == BALANCE_THRESHOLD_DATA_ID) {
                uint256 balanceThreshold = takerAssetData.readUint256(index + 36);
                requirementsAchieved[requirementsNumber] = requiredToken.balanceOf(signerAddress) >= balanceThreshold;
                requirementsNumber += 1;
                index += 68;
            } else if (dataId == OWNERSHIP_DATA_ID) {
                uint256 tokenId = takerAssetData.readUint256(index + 36);
                requirementsAchieved[requirementsNumber] = requiredToken.ownerOf(tokenId) == signerAddress;
                requirementsNumber += 1;
                index += 68;
            } else if (dataId == FILLED_TIMES_DATA_ID) {
                index += 36;
            } else {
                revert("UNSUPPORTED_METHOD");
            }
        }

        return requirementsAchieved;
    }

    /// @dev Validates signerAddress's filling times is in limitation. Succeeds or throws.
    /// @param takerAssetData TakerAssetData extracted from signedExchangeTransaction.
    /// @param embeddedSignature Signature extracted from signedExchangeTransaction.
    /// @param signerAddress Signer of signedExchangeTransaction.
    function assertValidFilledTimes(bytes memory takerAssetData, bytes memory embeddedSignature, address signerAddress)
        internal
        returns (bool)
    {
        uint256 takerAssetDataLength = takerAssetData.length;
        bytes32 signatureHash = keccak256(embeddedSignature);
        uint256 filledTimesLimit = 1;

        if (takerAssetData.readBytes4(takerAssetDataLength - 36) == FILLED_TIMES_DATA_ID) {
            filledTimesLimit = takerAssetData.readUint256(takerAssetDataLength - 32);
        }

        require(
            filledTimes[signatureHash][signerAddress] < filledTimesLimit,
            "FILLED_TIMES_EXCEEDED"
        );

        filledTimes[signatureHash][signerAddress] += 1;

        return true;
    }

    /// @dev Validates all requirements' achievement. Succeeds or throws.
    /// @param takerAssetData TakerAssetData extracted from signedExchangeTransaction.
    /// @param signerAddress Signer of signedExchangeTransaction.
    function assertRequirementsAchieved(bytes memory takerAssetData, address signerAddress)
        internal view
        returns (bool)
    {
        bool[] memory requirementsAchieved = getRequirementsAchieved(takerAssetData, signerAddress);
        uint256 requirementsAchievedLength = requirementsAchieved.length;

        for (uint256 i = 0; i < requirementsAchievedLength; i += 1) {
            require(
                requirementsAchieved[i],
                "AT_LEAST_ONE_REQUIREMENT_NOT_ACHIEVED"
            );
        }

        return true;
    }
}

// File: contracts/RequirementFilter/RequirementFilter.sol

contract RequirementFilter is
    LibConstants,
    MixinExchangeCalldata,
    MixinFakeERC20Token,
    MixinRequirementFilterCore
{
    constructor (address exchange)
        public
        LibConstants(exchange)
    {}
}