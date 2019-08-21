/**
 *Submitted for verification at Etherscan.io on 2019-06-06
*/

/**
 * Source Code first verified at https://etherscan.io on Wednesday, April 24, 2019
 (UTC) */

pragma solidity ^0.4.25;

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

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

/**
 * @title math operations that returns specific size reults (32, 64 and 256
 *        bits)
 */
library SafeMath {

    /**
     * @dev Multiplies two numbers and returns a uint64
     * @param a A number
     * @param b A number
     * @return a * b as a uint64
     */
    function mul64(uint256 a, uint256 b) internal pure returns (uint64) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        require(c < 2**64);
        return uint64(c);
    }

    /**
     * @dev Divides two numbers and returns a uint64
     * @param a A number
     * @param b A number
     * @return a / b as a uint64
     */
    function div64(uint256 a, uint256 b) internal pure returns (uint64) {
        uint256 c = a / b;
        require(c < 2**64);
        /* solcov ignore next */
        return uint64(c);
    }

    /**
     * @dev Substracts two numbers and returns a uint64
     * @param a A number
     * @param b A number
     * @return a - b as a uint64
     */
    function sub64(uint256 a, uint256 b) internal pure returns (uint64) {
        require(b <= a);
        uint256 c = a - b;
        require(c < 2**64);
        /* solcov ignore next */
        return uint64(c);
    }

    /**
     * @dev Adds two numbers and returns a uint64
     * @param a A number
     * @param b A number
     * @return a + b as a uint64
     */
    function add64(uint256 a, uint256 b) internal pure returns (uint64) {
        uint256 c = a + b;
        require(c >= a && c < 2**64);
        /* solcov ignore next */
        return uint64(c);
    }

    /**
     * @dev Multiplies two numbers and returns a uint32
     * @param a A number
     * @param b A number
     * @return a * b as a uint32
     */
    function mul32(uint256 a, uint256 b) internal pure returns (uint32) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        require(c < 2**32);
        /* solcov ignore next */
        return uint32(c);
    }

    /**
     * @dev Divides two numbers and returns a uint32
     * @param a A number
     * @param b A number
     * @return a / b as a uint32
     */
    function div32(uint256 a, uint256 b) internal pure returns (uint32) {
        uint256 c = a / b;
        require(c < 2**32);
        /* solcov ignore next */
        return uint32(c);
    }

    /**
     * @dev Substracts two numbers and returns a uint32
     * @param a A number
     * @param b A number
     * @return a - b as a uint32
     */
    function sub32(uint256 a, uint256 b) internal pure returns (uint32) {
        require(b <= a);
        uint256 c = a - b;
        require(c < 2**32);
        /* solcov ignore next */
        return uint32(c);
    }

    /**
     * @dev Adds two numbers and returns a uint32
     * @param a A number
     * @param b A number
     * @return a + b as a uint32
     */
    function add32(uint256 a, uint256 b) internal pure returns (uint32) {
        uint256 c = a + b;
        require(c >= a && c < 2**32);
        return uint32(c);
    }

    /**
     * @dev Multiplies two numbers and returns a uint256
     * @param a A number
     * @param b A number
     * @return a * b as a uint256
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        /* solcov ignore next */
        return c;
    }

    /**
     * @dev Divides two numbers and returns a uint256
     * @param a A number
     * @param b A number
     * @return a / b as a uint256
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        /* solcov ignore next */
        return c;
    }

    /**
     * @dev Substracts two numbers and returns a uint256
     * @param a A number
     * @param b A number
     * @return a - b as a uint256
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers and returns a uint256
     * @param a A number
     * @param b A number
     * @return a + b as a uint256
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}



/**
 * @title Merkle Tree's proof helper contract
 */
library Merkle {

    /**
     * @dev calculates the hash of two child nodes on the merkle tree.
     * @param a Hash of the left child node.
     * @param b Hash of the right child node.
     * @return sha3 hash of the resulting node.
     */
    function combinedHash(bytes32 a, bytes32 b) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(a, b));
    }

    /**
     * @dev calculates a root hash associated with a Merkle proof
     * @param proof array of proof hashes
     * @param key index of the leaf element list.
     *        this key indicates the specific position of the leaf
     *        in the merkle tree. It will be used to know if the
     *        node that will be hashed along with the proof node
     *        is placed on the right or the left of the current
     *        tree level. That is achieved by doing the modulo of
     *        the current key/position. A new level of nodes will
     *        be evaluated after that, and the new left or right
     *        position is obtained by doing the same operation, 
     *        after dividing the key/position by two.
     * @param leaf the leaf element to verify on the set.
     * @return the hash of the Merkle proof. Should match the Merkle root
     *         if the proof is valid
     */
    function getProofRootHash(bytes32[] memory proof, uint256 key, bytes32 leaf) public pure returns(bytes32) {
        bytes32 hash = keccak256(abi.encodePacked(leaf));
        uint256 k = key;
        for(uint i = 0; i<proof.length; i++) {
            uint256 bit = k % 2;
            k = k / 2;

            if (bit == 0)
                hash = combinedHash(hash, proof[i]);
            else
                hash = combinedHash(proof[i], hash);
        }
        return hash;
    }
}

/**
 * @title Data Structures for BatPay: Accounts, Payments & Challenge
 */
contract Data {
    struct Account {
        address owner;
        uint64  balance;
        uint32  lastCollectedPaymentId;
    }

    struct BulkRegistration {
        bytes32 rootHash;
        uint32  recordCount;
        uint32  smallestRecordId;
    }

    struct Payment {
        uint32  fromAccountId;
        uint64  amount;
        uint64  fee;
        uint32  smallestAccountId;
        uint32  greatestAccountId;
        uint32  totalNumberOfPayees;
        uint64  lockTimeoutBlockNumber;
        bytes32 paymentDataHash;
        bytes32 lockingKeyHash;
        bytes32 metadata;
    }

    struct CollectSlot {
        uint32  minPayIndex;
        uint32  maxPayIndex;
        uint64  amount;
        uint64  delegateAmount;
        uint32  to;
        uint64  block;
        uint32  delegate;
        uint32  challenger;
        uint32  index;
        uint64  challengeAmount;
        uint8   status;
        address addr;
        bytes32 data;
    }

    struct Config {
        uint32 maxBulk;
        uint32 maxTransfer;
        uint32 challengeBlocks;
        uint32 challengeStepBlocks;
        uint64 collectStake;
        uint64 challengeStake;
        uint32 unlockBlocks;
        uint32 massExitIdBlocks;
        uint32 massExitIdStepBlocks;
        uint32 massExitBalanceBlocks;
        uint32 massExitBalanceStepBlocks;
        uint64 massExitStake;
        uint64 massExitChallengeStake;
        uint64 maxCollectAmount;
    }

    Config public params;
    address public owner;

    uint public constant MAX_ACCOUNT_ID = 2**32-1;    // Maximum account id (32-bits)
    uint public constant NEW_ACCOUNT_FLAG = 2**256-1; // Request registration of new account
    uint public constant INSTANT_SLOT = 32768;

}


/**
  * @title Accounts, methods to manage accounts and balances
  */

contract Accounts is Data {
    event BulkRegister(uint bulkSize, uint smallestAccountId, uint bulkId );
    event AccountRegistered(uint accountId, address accountAddress);

    IERC20 public token;
    Account[] public accounts;
    BulkRegistration[] public bulkRegistrations;

    /**
      * @dev determines whether accountId is valid
      * @param accountId an account id
      * @return boolean
      */
    function isValidId(uint accountId) public view returns (bool) {
        return (accountId < accounts.length);
    }

    /**
      * @dev determines whether accountId is the owner of the account
      * @param accountId an account id
      * @return boolean
      */
    function isAccountOwner(uint accountId) public view returns (bool) {
        return isValidId(accountId) && msg.sender == accounts[accountId].owner;
    }

    /**
      * @dev modifier to restrict that accountId is valid
      * @param accountId an account id
      */
    modifier validId(uint accountId) {
        require(isValidId(accountId), "accountId is not valid");
        _;
    }

    /**
      * @dev modifier to restrict that accountId is owner
      * @param accountId an account ID
      */
    modifier onlyAccountOwner(uint accountId) {
        require(isAccountOwner(accountId), "Only account owner can invoke this method");
        _;
    }

    /**
      * @dev Reserve accounts but delay assigning addresses.
      *      Accounts will be claimed later using MerkleTree's rootHash.
      * @param bulkSize Number of accounts to reserve.
      * @param rootHash Hash of the root node of the Merkle Tree referencing the list of addresses.
      */
    function bulkRegister(uint256 bulkSize, bytes32 rootHash) public {
        require(bulkSize > 0, "Bulk size can't be zero");
        require(bulkSize < params.maxBulk, "Cannot register this number of ids simultaneously");
        require(SafeMath.add(accounts.length, bulkSize) <= MAX_ACCOUNT_ID, "Cannot register: ran out of ids");
        require(rootHash > 0, "Root hash can't be zero");

        emit BulkRegister(bulkSize, accounts.length, bulkRegistrations.length);
        bulkRegistrations.push(BulkRegistration(rootHash, uint32(bulkSize), uint32(accounts.length)));
        accounts.length = SafeMath.add(accounts.length, bulkSize);
    }

    /** @dev Complete registration for a reserved account by showing the
      *     bulkRegistration-id and Merkle proof associated with this address
      * @param addr Address claiming this account
      * @param proof Merkle proof for address and id
      * @param accountId Id of the account to be registered.
      * @param bulkId BulkRegistration id for the transaction reserving this account
      */
    function claimBulkRegistrationId(address addr, bytes32[] memory proof, uint accountId, uint bulkId) public {
        require(bulkId < bulkRegistrations.length, "the bulkId referenced is invalid");
        uint smallestAccountId = bulkRegistrations[bulkId].smallestRecordId;
        uint n = bulkRegistrations[bulkId].recordCount;
        bytes32 rootHash = bulkRegistrations[bulkId].rootHash;
        bytes32 hash = Merkle.getProofRootHash(proof, SafeMath.sub(accountId, smallestAccountId), bytes32(addr));

        require(accountId >= smallestAccountId && accountId < smallestAccountId + n,
            "the accountId specified is not part of that bulk registration slot");
        require(hash == rootHash, "invalid Merkle proof");
        emit AccountRegistered(accountId, addr);

        accounts[accountId].owner = addr;
    }

    /**
      * @dev Register a new account
      * @return the id of the new account
      */
    function register() public returns (uint32 ret) {
        require(accounts.length < MAX_ACCOUNT_ID, "no more accounts left");
        ret = (uint32)(accounts.length);
        accounts.push(Account(msg.sender, 0, 0));
        emit AccountRegistered(ret, msg.sender);
        return ret;
    }

    /**
     * @dev withdraw tokens from the BatchPayment contract into the original address.
     * @param amount Amount of tokens to withdraw.
     * @param accountId Id of the user requesting the withdraw.
     */
    function withdraw(uint64 amount, uint256 accountId)
        external
        onlyAccountOwner(accountId)
    {
        uint64 balance = accounts[accountId].balance;

        require(balance >= amount, "insufficient funds");
        require(amount > 0, "amount should be nonzero");

        balanceSub(accountId, amount);

        require(token.transfer(msg.sender, amount), "transfer failed");
    }

    /**
     * @dev Deposit tokens into the BatchPayment contract to enable scalable payments
     * @param amount Amount of tokens to deposit on `accountId`. User should have
     *        enough balance and issue an `approve()` method prior to calling this.
     * @param accountId The id of the user account. In case `NEW_ACCOUNT_FLAG` is used,
     *        a new account will be registered and the requested amount will be
     *        deposited in a single operation.
     */
    function deposit(uint64 amount, uint256 accountId) external {
        require(accountId < accounts.length || accountId == NEW_ACCOUNT_FLAG, "invalid accountId");
        require(amount > 0, "amount should be positive");

        if (accountId == NEW_ACCOUNT_FLAG) {
            // new account
            uint newId = register();
            accounts[newId].balance = amount;
        } else {
            // existing account
            balanceAdd(accountId, amount);
        }

        require(token.transferFrom(msg.sender, address(this), amount), "transfer failed");
    }

    /**
     * @dev Increase the specified account balance by `amount` tokens.
     * @param accountId An account id
     * @param amount number of tokens
     */
    function balanceAdd(uint accountId, uint64 amount)
    internal
    validId(accountId)
    {
        accounts[accountId].balance = SafeMath.add64(accounts[accountId].balance, amount);
    }

    /**
     *  @dev Substract `amount` tokens from the specified account's balance
     *  @param accountId An account id
     *  @param amount number of tokens
     */
    function balanceSub(uint accountId, uint64 amount)
    internal
    validId(accountId)
    {
        uint64 balance = accounts[accountId].balance;
        require(balance >= amount, "not enough funds");
        accounts[accountId].balance = SafeMath.sub64(balance, amount);
    }

    /**
     *  @dev returns the balance associated with the account in tokens
     *  @param accountId account requested.
     */
    function balanceOf(uint accountId)
        external
        view
        validId(accountId)
        returns (uint64)
    {
        return accounts[accountId].balance;
    }

    /**
      * @dev gets number of accounts registered and reserved.
      * @return returns the size of the accounts array.
      */
    function getAccountsLength() external view returns (uint) {
        return accounts.length;
    }

    /**
      * @dev gets the number of bulk registrations performed
      * @return the size of the bulkRegistrations array.
      */
    function getBulkLength() external view returns (uint) {
        return bulkRegistrations.length;
    }
}


/**
 * @title Challenge helper library
 */
library Challenge {

    uint8 public constant PAY_DATA_HEADER_MARKER = 0xff; // marker in payData header

    /**
     * @dev Reverts if challenge period has expired or Collect Slot status is
     *      not a valid one.
     */
    modifier onlyValidCollectSlot(Data.CollectSlot storage collectSlot, uint8 validStatus) {
        require(!challengeHasExpired(collectSlot), "Challenge has expired");
        require(isSlotStatusValid(collectSlot, validStatus), "Wrong Collect Slot status");
        _;
    }

    /**
     * @return true if the current block number is greater or equal than the
     *         allowed block for this challenge.
     */
    function challengeHasExpired(Data.CollectSlot storage collectSlot) public view returns (bool) {
        return collectSlot.block <= block.number;
    }

    /**
     * @return true if the Slot status is valid.
     */
    function isSlotStatusValid(Data.CollectSlot storage collectSlot, uint8 validStatus) public view returns (bool) {
        return collectSlot.status == validStatus;
    }

    /** @dev calculates new block numbers based on the current block and a
     *      delta constant specified by the protocol policy.
     * @param delta number of blocks into the future to calculate.
     * @return future block number.
     */
    function getFutureBlock(uint delta) public view returns(uint64) {
        return SafeMath.add64(block.number, delta);
    }

    /**
     * @dev Inspects the compact payment list provided and calculates the sum
     *      of the amounts referenced
     * @param data binary array, with 12 bytes per item. 8-bytes amount,
     *        4-bytes payment index.
     * @return the sum of the amounts referenced on the array.
     */
    function getDataSum(bytes memory data) public pure returns (uint sum) {
        require(data.length > 0, "no data provided");
        require(data.length % 12 == 0, "wrong data format, data length should be multiple of 12");

        uint n = SafeMath.div(data.length, 12);
        uint modulus = 2**64;

        sum = 0;

        // Get the sum of the stated amounts in data
        // Each entry in data is [8-bytes amount][4-bytes payIndex]

        for (uint i = 0; i < n; i++) {
            // solium-disable-next-line security/no-inline-assembly
            assembly {
                let amount := mod(mload(add(data, add(8, mul(i, 12)))), modulus)
                let result := add(sum, amount)
                switch or(gt(result, modulus), eq(result, modulus))
                case 1 { revert (0, 0) }
                default { sum := result }
            }
        }
    }

    /**
     * @dev Helper function that obtains the amount/payIndex pair located at
     *      position `index`.
     * @param data binary array, with 12 bytes per item. 8-bytes amount,
     *        4-bytes payment index.
     * @param index Array item requested.
     * @return amount and payIndex requested.
     */
    function getDataAtIndex(bytes memory data, uint index) public pure returns (uint64 amount, uint32 payIndex) {
        require(data.length > 0, "no data provided");
        require(data.length % 12 == 0, "wrong data format, data length should be multiple of 12");

        uint mod1 = 2**64;
        uint mod2 = 2**32;
        uint i = SafeMath.mul(index, 12);

        require(i <= SafeMath.sub(data.length, 12), "index * 12 must be less or equal than (data.length - 12)");

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            amount := mod( mload(add(data, add(8, i))), mod1 )

            payIndex := mod( mload(add(data, add(12, i))), mod2 )
        }
    }

    /**
     * @dev obtains the number of bytes per id in `payData`
     * @param payData efficient binary representation of a list of accountIds
     * @return bytes per id in `payData`
     */
    function getBytesPerId(bytes payData) internal pure returns (uint) {
        // payData includes a 2 byte header and a list of ids
        // [0xff][bytesPerId]

        uint len = payData.length;
        require(len >= 2, "payData length should be >= 2");
        require(uint8(payData[0]) == PAY_DATA_HEADER_MARKER, "payData header missing");
        uint bytesPerId = uint(payData[1]);
        require(bytesPerId > 0 && bytesPerId < 32, "second byte of payData should be positive and less than 32");

        // remaining bytes should be a multiple of bytesPerId
        require((len - 2) % bytesPerId == 0,
        "payData length is invalid, all payees must have same amount of bytes (payData[1])");

        return bytesPerId;
    }

    /**
     * @dev Process payData, inspecting the list of ids, accumulating the amount for
     *    each entry of `id`.
     *   `payData` includes 2 header bytes, followed by n bytesPerId-bytes entries.
     *   `payData` format: [byte 0xff][byte bytesPerId][delta 0][delta 1]..[delta n-1]
     * @param payData List of payees of a specific Payment, with the above format.
     * @param id ID to look for in `payData`
     * @param amount amount per occurrence of `id` in `payData`
     * @return the amount sum for all occurrences of `id` in `payData`
     */
    function getPayDataSum(bytes memory payData, uint id, uint amount) public pure returns (uint sum) {
        uint bytesPerId = getBytesPerId(payData);
        uint modulus = 1 << SafeMath.mul(bytesPerId, 8);
        uint currentId = 0;

        sum = 0;

        for (uint i = 2; i < payData.length; i += bytesPerId) {
            // Get next id delta from paydata
            // currentId += payData[2+i*bytesPerId]

            // solium-disable-next-line security/no-inline-assembly
            assembly {
                currentId := add(
                    currentId,
                    mod(
                        mload(add(payData, add(i, bytesPerId))),
                        modulus))

                switch eq(currentId, id)
                case 1 { sum := add(sum, amount) }
            }
        }
    }

    /**
     * @dev calculates the number of accounts included in payData
     * @param payData efficient binary representation of a list of accountIds
     * @return number of accounts present
     */
    function getPayDataCount(bytes payData) public pure returns (uint) {
        uint bytesPerId = getBytesPerId(payData);

        // calculate number of records
        return SafeMath.div(payData.length - 2, bytesPerId);
    }

    /**
     * @dev function. Phase I of the challenging game
     * @param collectSlot Collect slot
     * @param config Various parameters
     * @param accounts a reference to the main accounts array
     * @param challenger id of the challenger user
     */
    function challenge_1(
        Data.CollectSlot storage collectSlot,
        Data.Config storage config,
        Data.Account[] storage accounts,
        uint32 challenger
    )
        public
        onlyValidCollectSlot(collectSlot, 1)
    {
        require(accounts[challenger].balance >= config.challengeStake, "not enough balance");

        collectSlot.status = 2;
        collectSlot.challenger = challenger;
        collectSlot.block = getFutureBlock(config.challengeStepBlocks);

        accounts[challenger].balance -= config.challengeStake;
    }

    /**
     * @dev Internal function. Phase II of the challenging game
     * @param collectSlot Collect slot
     * @param config Various parameters
     * @param data Binary array listing the payments in which the user was referenced.
     */
    function challenge_2(
        Data.CollectSlot storage collectSlot,
        Data.Config storage config,
        bytes memory data
    )
        public
        onlyValidCollectSlot(collectSlot, 2)
    {
        require(getDataSum(data) == collectSlot.amount, "data doesn't represent collected amount");

        collectSlot.data = keccak256(data);
        collectSlot.status = 3;
        collectSlot.block = getFutureBlock(config.challengeStepBlocks);
    }

    /**
     * @dev Internal function. Phase III of the challenging game
     * @param collectSlot Collect slot
     * @param config Various parameters
     * @param data Binary array listing the payments in which the user was referenced.
     * @param disputedPaymentIndex index selecting the disputed payment
     */
    function challenge_3(
        Data.CollectSlot storage collectSlot,
        Data.Config storage config,
        bytes memory data,
        uint32 disputedPaymentIndex
    )
        public
        onlyValidCollectSlot(collectSlot, 3)
    {
        require(collectSlot.data == keccak256(data),
        "data mismatch, collected data hash doesn't match provided data hash");
        (collectSlot.challengeAmount, collectSlot.index) = getDataAtIndex(data, disputedPaymentIndex);
        collectSlot.status = 4;
        collectSlot.block = getFutureBlock(config.challengeStepBlocks);
    }

    /**
     * @dev Internal function. Phase IV of the challenging game
     * @param collectSlot Collect slot
     * @param payments a reference to the BatPay payments array
     * @param payData binary data describing the list of account receiving
     *        tokens on the selected transfer
     */
    function challenge_4(
        Data.CollectSlot storage collectSlot,
        Data.Payment[] storage payments,
        bytes memory payData
    )
        public
        onlyValidCollectSlot(collectSlot, 4)
    {
        require(collectSlot.index >= collectSlot.minPayIndex && collectSlot.index < collectSlot.maxPayIndex,
            "payment referenced is out of range");
        Data.Payment memory p = payments[collectSlot.index];
        require(keccak256(payData) == p.paymentDataHash,
        "payData mismatch, payment's data hash doesn't match provided payData hash");
        require(p.lockingKeyHash == 0, "payment is locked");

        uint collected = getPayDataSum(payData, collectSlot.to, p.amount);

        // Check if id is included in bulkRegistration within payment
        if (collectSlot.to >= p.smallestAccountId && collectSlot.to < p.greatestAccountId) {
            collected = SafeMath.add(collected, p.amount);
        }

        require(collected == collectSlot.challengeAmount,
        "amount mismatch, provided payData sum doesn't match collected challenge amount");

        collectSlot.status = 5;
    }

    /**
     * @dev the challenge was completed successfully, or the delegate failed to respond on time.
     *      The challenger will collect the stake.
     * @param collectSlot Collect slot
     * @param config Various parameters
     * @param accounts a reference to the main accounts array
     */
    function challenge_success(
        Data.CollectSlot storage collectSlot,
        Data.Config storage config,
        Data.Account[] storage accounts
    )
        public
    {
        require((collectSlot.status == 2 || collectSlot.status == 4),
            "Wrong Collect Slot status");
        require(challengeHasExpired(collectSlot),
            "Challenge not yet finished");

        accounts[collectSlot.challenger].balance = SafeMath.add64(
            accounts[collectSlot.challenger].balance,
            SafeMath.add64(config.collectStake, config.challengeStake));

        collectSlot.status = 0;
    }

    /**
     * @dev Internal function. The delegate proved the challenger wrong, or
     *      the challenger failed to respond on time. The delegae collects the stake.
     * @param collectSlot Collect slot
     * @param config Various parameters
     * @param accounts a reference to the main accounts array
     */
    function challenge_failed(
        Data.CollectSlot storage collectSlot,
        Data.Config storage config,
        Data.Account[] storage accounts
    )
        public
    {
        require(collectSlot.status == 5 || (collectSlot.status == 3 && block.number >= collectSlot.block),
            "challenge not completed");

        // Challenge failed
        // delegate wins Stake
        accounts[collectSlot.delegate].balance = SafeMath.add64(
            accounts[collectSlot.delegate].balance,
            config.challengeStake);

        // reset slot to status=1, waiting for challenges
        collectSlot.challenger = 0;
        collectSlot.status = 1;
        collectSlot.block = getFutureBlock(config.challengeBlocks);
    }

    /**
     * @dev Helps verify a ECDSA signature, while recovering the signing address.
     * @param hash Hash of the signed message
     * @param sig binary representation of the r, s & v parameters.
     * @return address of the signer if data provided is valid, zero otherwise.
     */
    function recoverHelper(bytes32 hash, bytes sig) public pure returns (address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, hash));

        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (sig.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return address(0);
        }

        return ecrecover(prefixedHash, v, r, s);
    }
}


/**
 * @title Payments and Challenge game - Performs the operations associated with
 *        transfer and the different steps of the collect challenge game.
 */
contract Payments is Accounts {
    event PaymentRegistered(
        uint32 indexed payIndex,
        uint indexed from,
        uint totalNumberOfPayees,
        uint amount
    );

    event PaymentUnlocked(uint32 indexed payIndex, bytes key);
    event PaymentRefunded(uint32 beneficiaryAccountId, uint64 amountRefunded);

    /**
     * Event for collection logging. Off-chain monitoring services may listen
     * to this event to trigger challenges.
     */
    event Collect(
        uint indexed delegate,
        uint indexed slot,
        uint indexed to,
        uint32 fromPayindex,
        uint32 toPayIndex,
        uint amount
    );

    event Challenge1(uint indexed delegate, uint indexed slot, uint challenger);
    event Challenge2(uint indexed delegate, uint indexed slot);
    event Challenge3(uint indexed delegate, uint indexed slot, uint index);
    event Challenge4(uint indexed delegate, uint indexed slot);
    event ChallengeSuccess(uint indexed delegate, uint indexed slot);
    event ChallengeFailed(uint indexed delegate, uint indexed slot);

    Payment[] public payments;
    mapping (uint32 => mapping (uint32 => CollectSlot)) public collects;

    /**
     * @dev Register token payment to multiple recipients
     * @param fromId Account id for the originator of the transaction
     * @param amount Amount of tokens to pay each destination.
     * @param fee Fee in tokens to be payed to the party providing the unlocking service
     * @param payData Efficient representation of the destination account list
     * @param newCount Number of new destination accounts that will be reserved during the registerPayment transaction
     * @param rootHash Hash of the root hash of the Merkle tree listing the addresses reserved.
     * @param lockingKeyHash hash resulting of calculating the keccak256 of
     *        of the key locking this payment to help in atomic data swaps.
     *        This hash will later be used by the `unlock` function to unlock the payment we are registering.
     *         The `lockingKeyHash` must be equal to the keccak256 of the packed
     *         encoding of the unlockerAccountId and the key used by the unlocker to encrypt the traded data:
     *             `keccak256(abi.encodePacked(unlockerAccountId, key))`
     *         DO NOT use previously used locking keys, since an attacker could realize that by comparing key hashes
     * @param metadata Application specific data to be stored associated with the payment
     */
    function registerPayment(
        uint32 fromId,
        uint64 amount,
        uint64 fee,
        bytes payData,
        uint newCount,
        bytes32 rootHash,
        bytes32 lockingKeyHash,
        bytes32 metadata
    )
        external
    {
        require(payments.length < 2**32, "Cannot add more payments");
        require(isAccountOwner(fromId), "Invalid fromId");
        require(amount > 0, "Invalid amount");
        require(newCount == 0 || rootHash > 0, "Invalid root hash"); // although bulkRegister checks this, we anticipate
        require(fee == 0 || lockingKeyHash > 0, "Invalid lock hash");

        Payment memory p;

        // Prepare a Payment struct
        p.totalNumberOfPayees = SafeMath.add32(Challenge.getPayDataCount(payData), newCount);
        require(p.totalNumberOfPayees > 0, "Invalid number of payees, should at least be 1 payee");
        require(p.totalNumberOfPayees < params.maxTransfer,
        "Too many payees, it should be less than config maxTransfer");

        p.fromAccountId = fromId;
        p.amount = amount;
        p.fee = fee;
        p.lockingKeyHash = lockingKeyHash;
        p.metadata = metadata;
        p.smallestAccountId = uint32(accounts.length);
        p.greatestAccountId = SafeMath.add32(p.smallestAccountId, newCount);
        p.lockTimeoutBlockNumber = SafeMath.add64(block.number, params.unlockBlocks);
        p.paymentDataHash = keccak256(abi.encodePacked(payData));

        // calculate total cost of payment
        uint64 totalCost = SafeMath.mul64(amount, p.totalNumberOfPayees);
        totalCost = SafeMath.add64(totalCost, fee);

        // Check that fromId has enough balance and substract totalCost
        balanceSub(fromId, totalCost);

        // If this operation includes new accounts, do a bulkRegister
        if (newCount > 0) {
            bulkRegister(newCount, rootHash);
        }

        // Save the new Payment
        payments.push(p);

        emit PaymentRegistered(SafeMath.sub32(payments.length, 1), p.fromAccountId, p.totalNumberOfPayees, p.amount);
    }

    /**
     * @dev provide the required key, releasing the payment and enabling the buyer decryption the digital content.
     * @param payIndex payment Index associated with the registerPayment operation.
     * @param unlockerAccountId id of the party providing the unlocking service. Fees wil be payed to this id.
     * @param key Cryptographic key used to encrypt traded data.
     */
    function unlock(uint32 payIndex, uint32 unlockerAccountId, bytes memory key) public returns(bool) {
        require(payIndex < payments.length, "invalid payIndex, payments is not that long yet");
        require(isValidId(unlockerAccountId), "Invalid unlockerAccountId");
        require(block.number < payments[payIndex].lockTimeoutBlockNumber, "Hash lock expired");
        bytes32 h = keccak256(abi.encodePacked(unlockerAccountId, key));
        require(h == payments[payIndex].lockingKeyHash, "Invalid key");

        payments[payIndex].lockingKeyHash = bytes32(0);
        balanceAdd(unlockerAccountId, payments[payIndex].fee);

        emit PaymentUnlocked(payIndex, key);
        return true;
    }

    /**
     * @dev Enables the buyer to recover funds associated with a `registerPayment()`
     *      operation for which decryption keys were not provided.
     * @param payIndex Index of the payment transaction associated with this request.
     * @return true if the operation succeded.
     */
    function refundLockedPayment(uint32 payIndex) external returns (bool) {
        require(payIndex < payments.length, "invalid payIndex, payments is not that long yet");
        require(payments[payIndex].lockingKeyHash != 0, "payment is already unlocked");
        require(block.number >= payments[payIndex].lockTimeoutBlockNumber, "Hash lock has not expired yet");
        Payment memory payment = payments[payIndex];
        require(payment.totalNumberOfPayees > 0, "payment already refunded");

        uint64 total = SafeMath.add64(
            SafeMath.mul64(payment.totalNumberOfPayees, payment.amount),
            payment.fee
        );

        payment.totalNumberOfPayees = 0;
        payment.fee = 0;
        payment.amount = 0;
        payments[payIndex] = payment;

        // Complete refund
        balanceAdd(payment.fromAccountId, total);
        emit PaymentRefunded(payment.fromAccountId, total);

        return true;
    }

    /**
     * @dev let users claim pending balance associated with prior transactions
            Users ask a delegate to complete the transaction on their behalf,
            the delegate calculates the apropiate amount (declaredAmount) and
            waits for a possible challenger.
            If this is an instant collect, tokens are transfered immediatly.
     * @param delegate id of the delegate account performing the operation on the name of the user.
     * @param slotId Individual slot used for the challenge game.
     * @param toAccountId Destination of the collect operation.
     * @param maxPayIndex payIndex of the first payment index not covered by this application.
     * @param declaredAmount amount of tokens owed to this user account
     * @param fee fee in tokens to be paid for the end user help.
     * @param destination Address to withdraw the full account balance.
     * @param signature An R,S,V ECDS signature provided by a user.
     */
    function collect(
        uint32 delegate,
        uint32 slotId,
        uint32 toAccountId,
        uint32 maxPayIndex,
        uint64 declaredAmount,
        uint64 fee,
        address destination,
        bytes memory signature
    )
    public
    {
        // Check delegate and toAccountId are valid
        require(isAccountOwner(delegate), "invalid delegate");
        require(isValidId(toAccountId), "toAccountId must be a valid account id");

        // make sure the game slot is empty (release it if necessary)
        freeSlot(delegate, slotId);

        Account memory tacc = accounts[toAccountId];
        require(tacc.owner != 0, "account registration has to be completed");

        if (delegate != toAccountId) {
            // If "toAccountId" != delegate, check who signed this transaction
            bytes32 hash =
            keccak256(
            abi.encodePacked(
                address(this), delegate, toAccountId, tacc.lastCollectedPaymentId,
                maxPayIndex, declaredAmount, fee, destination
            ));
            require(Challenge.recoverHelper(hash, signature) == tacc.owner, "Bad user signature");
        }

        // Check maxPayIndex is valid
        require(maxPayIndex > 0 && maxPayIndex <= payments.length,
        "invalid maxPayIndex, payments is not that long yet");
        require(maxPayIndex > tacc.lastCollectedPaymentId, "account already collected payments up to maxPayIndex");
        require(payments[maxPayIndex - 1].lockTimeoutBlockNumber < block.number,
            "cannot collect payments that can be unlocked");

        // Check if declaredAmount and fee are valid
        require(declaredAmount <= params.maxCollectAmount, "declaredAmount is too big");
        require(fee <= declaredAmount, "fee is too big, should be smaller than declaredAmount");

        // Prepare the challenge slot
        CollectSlot storage sl = collects[delegate][slotId];
        sl.delegate = delegate;
        sl.minPayIndex = tacc.lastCollectedPaymentId;
        sl.maxPayIndex = maxPayIndex;
        sl.amount = declaredAmount;
        sl.to = toAccountId;
        sl.block = Challenge.getFutureBlock(params.challengeBlocks);
        sl.status = 1;

        // Calculate how many tokens needs the delegate, and setup delegateAmount and addr
        uint64 needed = params.collectStake;

        // check if this is an instant collect
        if (slotId >= INSTANT_SLOT) {
            uint64 declaredAmountLessFee = SafeMath.sub64(declaredAmount, fee);
            sl.delegateAmount = declaredAmount;
            needed = SafeMath.add64(needed, declaredAmountLessFee);
            sl.addr = address(0);

            // Instant-collect, toAccount gets the declaredAmount now
            balanceAdd(toAccountId, declaredAmountLessFee);
        } else
        {   // not instant-collect
            sl.delegateAmount = fee;
            sl.addr = destination;
        }

        // Check delegate has enough funds
        require(accounts[delegate].balance >= needed, "not enough funds");

        // Update the lastCollectPaymentId for the toAccount
        accounts[toAccountId].lastCollectedPaymentId = uint32(maxPayIndex);

        // Now the delegate Pays
        balanceSub(delegate, needed);

        // Proceed if the user is withdrawing its balance
        if (destination != address(0) && slotId >= INSTANT_SLOT) {
            uint64 toWithdraw = accounts[toAccountId].balance;
            accounts[toAccountId].balance = 0;
            require(token.transfer(destination, toWithdraw), "transfer failed");
        }

        emit Collect(delegate, slotId, toAccountId, tacc.lastCollectedPaymentId, maxPayIndex, declaredAmount);
    }

    /**
     * @dev gets the number of payments issued
     * @return returns the size of the payments array.
     */
    function getPaymentsLength() external view returns (uint) {
        return payments.length;
    }

    /**
     * @dev initiate a challenge game
     * @param delegate id of the delegate that performed the collect operation
     *        in the name of the end-user.
     * @param slot slot used for the challenge game. Every user has a sperate
     *        set of slots
     * @param challenger id of the user account challenging the delegate.
     */
    function challenge_1(
        uint32 delegate,
        uint32 slot,
        uint32 challenger
    )
        public
        validId(delegate)
        onlyAccountOwner(challenger)
    {
        Challenge.challenge_1(collects[delegate][slot], params, accounts, challenger);
        emit Challenge1(delegate, slot, challenger);
    }

    /**
     * @dev The delegate provides the list of payments that mentions the enduser
     * @param delegate id of the delegate performing the collect operation
     * @param slot slot used for the operation
     * @param data binary list of payment indexes associated with this collect operation.
     */
    function challenge_2(
        uint32 delegate,
        uint32 slot,
        bytes memory data
    )
        public
        onlyAccountOwner(delegate)
    {
        Challenge.challenge_2(collects[delegate][slot], params, data);
        emit Challenge2(delegate, slot);
    }

    /**
     * @dev the Challenger chooses a single index into the delegate provided data list
     * @param delegate id of the delegate performing the collect operation
     * @param slot slot used for the operation
     * @param data binary list of payment indexes associated with this collect operation.
     * @param index index into the data array for the payment id selected by the challenger
     */
    function challenge_3(
        uint32 delegate,
        uint32 slot,
        bytes memory data,
        uint32 index
    )
        public
        validId(delegate)
    {
        require(isAccountOwner(collects[delegate][slot].challenger), "only challenger can call challenge_2");

        Challenge.challenge_3(collects[delegate][slot], params, data, index);
        emit Challenge3(delegate, slot, index);
    }

    /**
     * @dev the delegate provides proof that the destination account was
     *      included on that payment, winning the game
     * @param delegate id of the delegate performing the collect operation
     * @param slot slot used for the operation
     */
    function challenge_4(
        uint32 delegate,
        uint32 slot,
        bytes memory payData
    )
        public
        onlyAccountOwner(delegate)
    {
        Challenge.challenge_4(
            collects[delegate][slot],
            payments,
            payData
            );
        emit Challenge4(delegate, slot);
    }

    /**
     * @dev the challenge was completed successfully. The delegate stake is slashed.
     * @param delegate id of the delegate performing the collect operation
     * @param slot slot used for the operation
     */
    function challenge_success(
        uint32 delegate,
        uint32 slot
    )
        public
        validId(delegate)
    {
        Challenge.challenge_success(collects[delegate][slot], params, accounts);
        emit ChallengeSuccess(delegate, slot);
    }

    /**
     * @dev The delegate won the challenge game. He gets the challenge stake.
     * @param delegate id of the delegate performing the collect operation
     * @param slot slot used for the operation
     */
    function challenge_failed(
        uint32 delegate,
        uint32 slot
    )
        public
        onlyAccountOwner(delegate)
    {
        Challenge.challenge_failed(collects[delegate][slot], params, accounts);
        emit ChallengeFailed(delegate, slot);
    }

    /**
     * @dev Releases a slot used by the collect channel game, only when the game is finished.
     *      This does three things:
     *        1. Empty the slot
     *        2. Pay the delegate
     *        3. Pay the destinationAccount
     *      Also, if a token.transfer was requested, transfer the outstanding balance to the specified address.
     * @param delegate id of the account requesting the release operation
     * @param slot id of the slot requested for the duration of the challenge game
     */
    function freeSlot(uint32 delegate, uint32 slot) public {
        CollectSlot memory s = collects[delegate][slot];

        // If this is slot is empty, nothing else to do here.
        if (s.status == 0) return;

        // Make sure this slot is ready to be freed.
        // It should be in the waiting state(1) and with challenge time ran-out
        require(s.status == 1, "slot not available");
        require(block.number >= s.block, "slot not available");

        // 1. Put the slot in the empty state
        collects[delegate][slot].status = 0;

        // 2. Pay the delegate
        // This includes the stake as well as fees and other tokens reserved during collect()
        // [delegateAmount + stake] => delegate
        balanceAdd(delegate, SafeMath.add64(s.delegateAmount, params.collectStake));

        // 3. Pay the destination account
        // [amount - delegateAmount] => to
        uint64 balance = SafeMath.sub64(s.amount, s.delegateAmount);

        // was a transfer requested?
        if (s.addr != address(0))
        {
            // empty the account balance
            balance = SafeMath.add64(balance, accounts[s.to].balance);
            accounts[s.to].balance = 0;
            if (balance != 0)
                require(token.transfer(s.addr, balance), "transfer failed");
        } else
        {
            balanceAdd(s.to, balance);
        }
    }
}


/**
 * @title BatchPayment processing
 * @notice This contract allows to scale ERC-20 token transfer for fees or
 *         micropayments on the few-buyers / many-sellers setting.
 */
contract BatPay is Payments {

    /**
     * @dev Contract constructor, sets ERC20 token this contract will use for payments
     * @param token_ ERC20 contract address
     * @param maxBulk Maximum number of users to register in a single bulkRegister
     * @param maxTransfer Maximum number of destinations on a single payment
     * @param challengeBlocks number of blocks to wait for a challenge
     * @param challengeStepBlocks number of blocks to wait for a single step on
     *        the challenge game
     * @param collectStake stake in tokens for a collect operation
     * @param challengeStake stake in tokens for the challenger of a collect operation
     * @param unlockBlocks number of blocks to wait after registering payment
     *        for an unlock operation
     * @param maxCollectAmount Maximum amount of tokens to be collected in a
     *        single transaction
     */
    constructor(
        IERC20 token_,
        uint32 maxBulk,
        uint32 maxTransfer,
        uint32 challengeBlocks,
        uint32 challengeStepBlocks,
        uint64 collectStake,
        uint64 challengeStake,
        uint32 unlockBlocks,
        uint64 maxCollectAmount
    )
        public
    {
        require(token_ != address(0), "Token address can't be zero");
        require(maxBulk > 0, "Parameter maxBulk can't be zero");
        require(maxTransfer > 0, "Parameter maxTransfer can't be zero");
        require(challengeBlocks > 0, "Parameter challengeBlocks can't be zero");
        require(challengeStepBlocks > 0, "Parameter challengeStepBlocks can't be zero");
        require(collectStake > 0, "Parameter collectStake can't be zero");
        require(challengeStake > 0, "Parameter challengeStake can't be zero");
        require(unlockBlocks > 0, "Parameter unlockBlocks can't be zero");
        require(maxCollectAmount > 0, "Parameter maxCollectAmount can't be zero");

        owner = msg.sender;
        token = IERC20(token_);
        params.maxBulk = maxBulk;
        params.maxTransfer = maxTransfer;
        params.challengeBlocks = challengeBlocks;
        params.challengeStepBlocks = challengeStepBlocks;
        params.collectStake = collectStake;
        params.challengeStake = challengeStake;
        params.unlockBlocks = unlockBlocks;
        params.maxCollectAmount = maxCollectAmount;
    }
}