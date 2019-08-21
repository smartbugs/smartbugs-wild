pragma solidity ^0.4.4;


/**
 * @title AbstractBlobStore
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 * @dev Contracts must be able to interact with blobs regardless of which BlobStore contract they are stored in, so it is necessary for there to be an abstract contract that defines an interface for BlobStore contracts.
 */
contract AbstractBlobStore {

    /**
     * @dev Creates a new blob. It is guaranteed that different users will never receive the same blobId, even before consensus has been reached. This prevents blobId sniping. Consider createWithNonce() if not calling from another contract.
     * @param flags Packed blob settings.
     * @param contents Contents of the blob to be stored.
     * @return blobId Id of the blob.
     */
    function create(bytes4 flags, bytes contents) external returns (bytes20 blobId);

    /**
     * @dev Creates a new blob using provided nonce. It is guaranteed that different users will never receive the same blobId, even before consensus has been reached. This prevents blobId sniping. This method is cheaper than create(), especially if multiple blobs from the same account end up in the same block. However, it is not suitable for calling from other contracts because it will throw if a unique nonce is not provided.
     * @param flagsNonce First 4 bytes: Packed blob settings. The parameter as a whole must never have been passed to this function from the same account, or it will throw.
     * @param contents Contents of the blob to be stored.
     * @return blobId Id of the blob.
     */
    function createWithNonce(bytes32 flagsNonce, bytes contents) external returns (bytes20 blobId);

    /**
     * @dev Create a new blob revision.
     * @param blobId Id of the blob.
     * @param contents Contents of the new revision.
     * @return revisionId The new revisionId.
     */
    function createNewRevision(bytes20 blobId, bytes contents) external returns (uint revisionId);

    /**
     * @dev Update a blob's latest revision.
     * @param blobId Id of the blob.
     * @param contents Contents that should replace the latest revision.
     */
    function updateLatestRevision(bytes20 blobId, bytes contents) external;

    /**
     * @dev Retract a blob's latest revision. Revision 0 cannot be retracted.
     * @param blobId Id of the blob.
     */
    function retractLatestRevision(bytes20 blobId) external;

    /**
     * @dev Delete all a blob's revisions and replace it with a new blob.
     * @param blobId Id of the blob.
     * @param contents Contents that should be stored.
     */
    function restart(bytes20 blobId, bytes contents) external;

    /**
     * @dev Retract a blob.
     * @param blobId Id of the blob. This blobId can never be used again.
     */
    function retract(bytes20 blobId) external;

    /**
     * @dev Enable transfer of the blob to the current user.
     * @param blobId Id of the blob.
     */
    function transferEnable(bytes20 blobId) external;

    /**
     * @dev Disable transfer of the blob to the current user.
     * @param blobId Id of the blob.
     */
    function transferDisable(bytes20 blobId) external;

    /**
     * @dev Transfer a blob to a new user.
     * @param blobId Id of the blob.
     * @param recipient Address of the user to transfer to blob to.
     */
    function transfer(bytes20 blobId, address recipient) external;

    /**
     * @dev Disown a blob.
     * @param blobId Id of the blob.
     */
    function disown(bytes20 blobId) external;

    /**
     * @dev Set a blob as not updatable.
     * @param blobId Id of the blob.
     */
    function setNotUpdatable(bytes20 blobId) external;

    /**
     * @dev Set a blob to enforce revisions.
     * @param blobId Id of the blob.
     */
    function setEnforceRevisions(bytes20 blobId) external;

    /**
     * @dev Set a blob to not be retractable.
     * @param blobId Id of the blob.
     */
    function setNotRetractable(bytes20 blobId) external;

    /**
     * @dev Set a blob to not be transferable.
     * @param blobId Id of the blob.
     */
    function setNotTransferable(bytes20 blobId) external;

    /**
     * @dev Get the id for this BlobStore contract.
     * @return Id of the contract.
     */
    function getContractId() external constant returns (bytes12);

    /**
     * @dev Check if a blob exists.
     * @param blobId Id of the blob.
     * @return exists True if the blob exists.
     */
    function getExists(bytes20 blobId) external constant returns (bool exists);

    /**
     * @dev Get info about a blob.
     * @param blobId Id of the blob.
     * @return flags Packed blob settings.
     * @return owner Owner of the blob.
     * @return revisionCount How many revisions the blob has.
     * @return blockNumbers The block numbers of the revisions.
     */
    function getInfo(bytes20 blobId) external constant returns (bytes4 flags, address owner, uint revisionCount, uint[] blockNumbers);

    /**
     * @dev Get all a blob's flags.
     * @param blobId Id of the blob.
     * @return flags Packed blob settings.
     */
    function getFlags(bytes20 blobId) external constant returns (bytes4 flags);

    /**
     * @dev Determine if a blob is updatable.
     * @param blobId Id of the blob.
     * @return updatable True if the blob is updatable.
     */
    function getUpdatable(bytes20 blobId) external constant returns (bool updatable);

    /**
     * @dev Determine if a blob enforces revisions.
     * @param blobId Id of the blob.
     * @return enforceRevisions True if the blob enforces revisions.
     */
    function getEnforceRevisions(bytes20 blobId) external constant returns (bool enforceRevisions);

    /**
     * @dev Determine if a blob is retractable.
     * @param blobId Id of the blob.
     * @return retractable True if the blob is blob retractable.
     */
    function getRetractable(bytes20 blobId) external constant returns (bool retractable);

    /**
     * @dev Determine if a blob is transferable.
     * @param blobId Id of the blob.
     * @return transferable True if the blob is transferable.
     */
    function getTransferable(bytes20 blobId) external constant returns (bool transferable);

    /**
     * @dev Get the owner of a blob.
     * @param blobId Id of the blob.
     * @return owner Owner of the blob.
     */
    function getOwner(bytes20 blobId) external constant returns (address owner);

    /**
     * @dev Get the number of revisions a blob has.
     * @param blobId Id of the blob.
     * @return revisionCount How many revisions the blob has.
     */
    function getRevisionCount(bytes20 blobId) external constant returns (uint revisionCount);

    /**
     * @dev Get the block numbers for all of a blob's revisions.
     * @param blobId Id of the blob.
     * @return blockNumbers Revision block numbers.
     */
    function getAllRevisionBlockNumbers(bytes20 blobId) external constant returns (uint[] blockNumbers);

}


/**
 * @title BlobStoreFlags
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStoreFlags {

    bytes4 constant UPDATABLE = 0x01;           // True if the blob is updatable. After creation can only be disabled.
    bytes4 constant ENFORCE_REVISIONS = 0x02;   // True if the blob is enforcing revisions. After creation can only be enabled.
    bytes4 constant RETRACTABLE = 0x04;         // True if the blob can be retracted. After creation can only be disabled.
    bytes4 constant TRANSFERABLE = 0x08;        // True if the blob be transfered to another user or disowned. After creation can only be disabled.
    bytes4 constant ANONYMOUS = 0x10;           // True if the blob should not have an owner.

}


/**
 * @title BlobStoreRegistry
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStoreRegistry {

    /**
     * @dev Mapping of contract id to contract addresses.
     */
    mapping (bytes12 => address) contractAddresses;

    /**
     * @dev An AbstractBlobStore contract has been registered.
     * @param contractId Id of the contract.
     * @param contractAddress Address of the contract.
     */
    event Register(bytes12 indexed contractId, address indexed contractAddress);

    /**
     * @dev Throw if contract is registered.
     * @param contractId Id of the contract.
     */
    modifier isNotRegistered(bytes12 contractId) {
        if (contractAddresses[contractId] != 0) {
            throw;
        }
        _;
    }

    /**
     * @dev Throw if contract is not registered.
     * @param contractId Id of the contract.
     */
    modifier isRegistered(bytes12 contractId) {
        if (contractAddresses[contractId] == 0) {
            throw;
        }
        _;
    }

    /**
     * @dev Register the calling BlobStore contract.
     * @param contractId Id of the BlobStore contract.
     */
    function register(bytes12 contractId) external isNotRegistered(contractId) {
        // Record the calling contract address.
        contractAddresses[contractId] = msg.sender;
        // Log the registration.
        Register(contractId, msg.sender);
    }

    /**
     * @dev Get an AbstractBlobStore contract.
     * @param contractId Id of the contract.
     * @return blobStore The AbstractBlobStore contract.
     */
    function getBlobStore(bytes12 contractId) external constant isRegistered(contractId) returns (AbstractBlobStore blobStore) {
        blobStore = AbstractBlobStore(contractAddresses[contractId]);
    }

}


/**
 * @title BlobStore
 * @author Jonathan Brown <jbrown@bluedroplet.com>
 */
contract BlobStore is AbstractBlobStore, BlobStoreFlags {

    /**
     * @dev Single slot structure of blob info.
     */
    struct BlobInfo {
        bytes4 flags;               // Packed blob settings.
        uint32 revisionCount;       // Number of revisions including revision 0.
        uint32 blockNumber;         // Block number which contains revision 0.
        address owner;              // Who owns this blob.
    }

    /**
     * @dev Mapping of blobId to blob info.
     */
    mapping (bytes20 => BlobInfo) blobInfo;

    /**
     * @dev Mapping of blobId to mapping of packed slots of eight 32-bit block numbers.
     */
    mapping (bytes20 => mapping (uint => bytes32)) packedBlockNumbers;

    /**
     * @dev Mapping of blobId to mapping of transfer recipient addresses to enabled.
     */
    mapping (bytes20 => mapping (address => bool)) enabledTransfers;

    /**
     * @dev Id of this instance of BlobStore. Unique across all blockchains.
     */
    bytes12 contractId;

    /**
     * @dev A blob revision has been published.
     * @param blobId Id of the blob.
     * @param revisionId Id of the revision (the highest at time of logging).
     * @param contents Contents of the blob.
     */
    event Store(bytes20 indexed blobId, uint indexed revisionId, bytes contents);

    /**
     * @dev A revision has been retracted.
     * @param blobId Id of the blob.
     * @param revisionId Id of the revision.
     */
    event RetractRevision(bytes20 indexed blobId, uint revisionId);

    /**
     * @dev An entire blob has been retracted. This cannot be undone.
     * @param blobId Id of the blob.
     */
    event Retract(bytes20 indexed blobId);

    /**
     * @dev A blob has been transfered to a new address.
     * @param blobId Id of the blob.
     * @param recipient The address that now owns the blob.
     */
    event Transfer(bytes20 indexed blobId, address recipient);

    /**
     * @dev A blob has been disowned. This cannot be undone.
     * @param blobId Id of the blob.
     */
    event Disown(bytes20 indexed blobId);

    /**
     * @dev A blob has been set as not updatable. This cannot be undone.
     * @param blobId Id of the blob.
     */
    event SetNotUpdatable(bytes20 indexed blobId);

    /**
     * @dev A blob has been set as enforcing revisions. This cannot be undone.
     * @param blobId Id of the blob.
     */
    event SetEnforceRevisions(bytes20 indexed blobId);

    /**
     * @dev A blob has been set as not retractable. This cannot be undone.
     * @param blobId Id of the blob.
     */
    event SetNotRetractable(bytes20 indexed blobId);

    /**
     * @dev A blob has been set as not transferable. This cannot be undone.
     * @param blobId Id of the blob.
     */
    event SetNotTransferable(bytes20 indexed blobId);

    /**
     * @dev Throw if the blob has not been used before or it has been retracted.
     * @param blobId Id of the blob.
     */
    modifier exists(bytes20 blobId) {
        BlobInfo info = blobInfo[blobId];
        if (info.blockNumber == 0 || info.blockNumber == uint32(-1)) {
            throw;
        }
        _;
    }

    /**
     * @dev Throw if the owner of the blob is not the message sender.
     * @param blobId Id of the blob.
     */
    modifier isOwner(bytes20 blobId) {
        if (blobInfo[blobId].owner != msg.sender) {
            throw;
        }
        _;
    }

    /**
     * @dev Throw if the blob is not updatable.
     * @param blobId Id of the blob.
     */
    modifier isUpdatable(bytes20 blobId) {
        if (blobInfo[blobId].flags & UPDATABLE == 0) {
            throw;
        }
        _;
    }

    /**
     * @dev Throw if the blob is not enforcing revisions.
     * @param blobId Id of the blob.
     */
    modifier isNotEnforceRevisions(bytes20 blobId) {
        if (blobInfo[blobId].flags & ENFORCE_REVISIONS != 0) {
            throw;
        }
        _;
    }

    /**
     * @dev Throw if the blob is not retractable.
     * @param blobId Id of the blob.
     */
    modifier isRetractable(bytes20 blobId) {
        if (blobInfo[blobId].flags & RETRACTABLE == 0) {
            throw;
        }
        _;
    }

    /**
     * @dev Throw if the blob is not transferable.
     * @param blobId Id of the blob.
     */
    modifier isTransferable(bytes20 blobId) {
        if (blobInfo[blobId].flags & TRANSFERABLE == 0) {
            throw;
        }
        _;
    }

    /**
     * @dev Throw if the blob is not transferable to a specific user.
     * @param blobId Id of the blob.
     * @param recipient Address of the user.
     */
    modifier isTransferEnabled(bytes20 blobId, address recipient) {
        if (!enabledTransfers[blobId][recipient]) {
            throw;
        }
        _;
    }

    /**
     * @dev Throw if the blob only has one revision.
     * @param blobId Id of the blob.
     */
    modifier hasAdditionalRevisions(bytes20 blobId) {
        if (blobInfo[blobId].revisionCount == 1) {
            throw;
        }
        _;
    }

    /**
     * @dev Throw if a specific blob revision does not exist.
     * @param blobId Id of the blob.
     * @param revisionId Id of the revision.
     */
    modifier revisionExists(bytes20 blobId, uint revisionId) {
        if (revisionId >= blobInfo[blobId].revisionCount) {
            throw;
        }
        _;
    }

    /**
     * @dev Constructor.
     * @param registry Address of BlobStoreRegistry contract to register with.
     */
    function BlobStore(BlobStoreRegistry registry) {
        // Create id for this contract.
        contractId = bytes12(keccak256(this, block.blockhash(block.number - 1)));
        // Register this contract.
        registry.register(contractId);
    }

    /**
     * @dev Creates a new blob. It is guaranteed that different users will never receive the same blobId, even before consensus has been reached. This prevents blobId sniping. Consider createWithNonce() if not calling from another contract.
     * @param flags Packed blob settings.
     * @param contents Contents of the blob to be stored.
     * @return blobId Id of the blob.
     */
    function create(bytes4 flags, bytes contents) external returns (bytes20 blobId) {
        // Generate the blobId.
        blobId = bytes20(keccak256(msg.sender, block.blockhash(block.number - 1)));
        // Make sure this blobId has not been used before (could be in the same block).
        while (blobInfo[blobId].blockNumber != 0) {
            blobId = bytes20(keccak256(blobId));
        }
        // Store blob info in state.
        blobInfo[blobId] = BlobInfo({
            flags: flags,
            revisionCount: 1,
            blockNumber: uint32(block.number),
            owner: (flags & ANONYMOUS != 0) ? 0 : msg.sender,
        });
        // Store the first revision in a log in the current block.
        Store(blobId, 0, contents);
    }

    /**
     * @dev Creates a new blob using provided nonce. It is guaranteed that different users will never receive the same blobId, even before consensus has been reached. This prevents blobId sniping. This method is cheaper than create(), especially if multiple blobs from the same account end up in the same block. However, it is not suitable for calling from other contracts because it will throw if a unique nonce is not provided.
     * @param flagsNonce First 4 bytes: Packed blob settings. The parameter as a whole must never have been passed to this function from the same account, or it will throw.
     * @param contents Contents of the blob to be stored.
     * @return blobId Id of the blob.
     */
    function createWithNonce(bytes32 flagsNonce, bytes contents) external returns (bytes20 blobId) {
        // Generate the blobId.
        blobId = bytes20(keccak256(msg.sender, flagsNonce));
        // Make sure this blobId has not been used before.
        if (blobInfo[blobId].blockNumber != 0) {
            throw;
        }
        // Store blob info in state.
        blobInfo[blobId] = BlobInfo({
            flags: bytes4(flagsNonce),
            revisionCount: 1,
            blockNumber: uint32(block.number),
            owner: (bytes4(flagsNonce) & ANONYMOUS != 0) ? 0 : msg.sender,
        });
        // Store the first revision in a log in the current block.
        Store(blobId, 0, contents);
    }

    /**
     * @dev Store a blob revision block number in a packed slot.
     * @param blobId Id of the blob.
     * @param offset The offset of the block number should be retreived.
     */
    function _setPackedBlockNumber(bytes20 blobId, uint offset) internal {
        // Get the slot.
        bytes32 slot = packedBlockNumbers[blobId][offset / 8];
        // Wipe the previous block number.
        slot &= ~bytes32(uint32(-1) * 2**((offset % 8) * 32));
        // Insert the current block number.
        slot |= bytes32(uint32(block.number) * 2**((offset % 8) * 32));
        // Store the slot.
        packedBlockNumbers[blobId][offset / 8] = slot;
    }

    /**
     * @dev Create a new blob revision.
     * @param blobId Id of the blob.
     * @param contents Contents of the new revision.
     * @return revisionId The new revisionId.
     */
    function createNewRevision(bytes20 blobId, bytes contents) external isOwner(blobId) isUpdatable(blobId) returns (uint revisionId) {
        // Increment the number of revisions.
        revisionId = blobInfo[blobId].revisionCount++;
        // Store the block number.
        _setPackedBlockNumber(blobId, revisionId - 1);
        // Store the revision in a log in the current block.
        Store(blobId, revisionId, contents);
    }

    /**
     * @dev Update a blob's latest revision.
     * @param blobId Id of the blob.
     * @param contents Contents that should replace the latest revision.
     */
    function updateLatestRevision(bytes20 blobId, bytes contents) external isOwner(blobId) isUpdatable(blobId) isNotEnforceRevisions(blobId) {
        BlobInfo info = blobInfo[blobId];
        uint revisionId = info.revisionCount - 1;
        // Update the block number.
        if (revisionId == 0) {
            info.blockNumber = uint32(block.number);
        }
        else {
            _setPackedBlockNumber(blobId, revisionId - 1);
        }
        // Store the revision in a log in the current block.
        Store(blobId, revisionId, contents);
    }

    /**
     * @dev Retract a blob's latest revision. Revision 0 cannot be retracted.
     * @param blobId Id of the blob.
     */
    function retractLatestRevision(bytes20 blobId) external isOwner(blobId) isUpdatable(blobId) isNotEnforceRevisions(blobId) hasAdditionalRevisions(blobId) {
        uint revisionId = --blobInfo[blobId].revisionCount;
        // Delete the slot if it is no longer required.
        if (revisionId % 8 == 1) {
            delete packedBlockNumbers[blobId][revisionId / 8];
        }
        // Log the revision retraction.
        RetractRevision(blobId, revisionId);
    }

    /**
     * @dev Delete all of a blob's packed revision block numbers.
     * @param blobId Id of the blob.
     */
    function _deleteAllPackedRevisionBlockNumbers(bytes20 blobId) internal {
        // Determine how many slots should be deleted.
        // Block number of the first revision is stored in the blob info, so the first slot only needs to be deleted if there are at least 2 revisions.
        uint slotCount = (blobInfo[blobId].revisionCount + 6) / 8;
        // Delete the slots.
        for (uint i = 0; i < slotCount; i++) {
            delete packedBlockNumbers[blobId][i];
        }
    }

    /**
     * @dev Delete all a blob's revisions and replace it with a new blob.
     * @param blobId Id of the blob.
     * @param contents Contents that should be stored.
     */
    function restart(bytes20 blobId, bytes contents) external isOwner(blobId) isUpdatable(blobId) isNotEnforceRevisions(blobId) {
        // Delete the packed revision block numbers.
        _deleteAllPackedRevisionBlockNumbers(blobId);
        // Update the blob state info.
        BlobInfo info = blobInfo[blobId];
        info.revisionCount = 1;
        info.blockNumber = uint32(block.number);
        // Store the blob in a log in the current block.
        Store(blobId, 0, contents);
    }

    /**
     * @dev Retract a blob.
     * @param blobId Id of the blob. This blobId can never be used again.
     */
    function retract(bytes20 blobId) external isOwner(blobId) isRetractable(blobId) {
        // Delete the packed revision block numbers.
        _deleteAllPackedRevisionBlockNumbers(blobId);
        // Mark this blob as retracted.
        blobInfo[blobId] = BlobInfo({
            flags: 0,
            revisionCount: 0,
            blockNumber: uint32(-1),
            owner: 0,
        });
        // Log the blob retraction.
        Retract(blobId);
    }

    /**
     * @dev Enable transfer of the blob to the current user.
     * @param blobId Id of the blob.
     */
    function transferEnable(bytes20 blobId) external isTransferable(blobId) {
        // Record in state that the current user will accept this blob.
        enabledTransfers[blobId][msg.sender] = true;
    }

    /**
     * @dev Disable transfer of the blob to the current user.
     * @param blobId Id of the blob.
     */
    function transferDisable(bytes20 blobId) external isTransferEnabled(blobId, msg.sender) {
        // Record in state that the current user will not accept this blob.
        enabledTransfers[blobId][msg.sender] = false;
    }

    /**
     * @dev Transfer a blob to a new user.
     * @param blobId Id of the blob.
     * @param recipient Address of the user to transfer to blob to.
     */
    function transfer(bytes20 blobId, address recipient) external isOwner(blobId) isTransferable(blobId) isTransferEnabled(blobId, recipient) {
        // Update ownership of the blob.
        blobInfo[blobId].owner = recipient;
        // Disable this transfer in future and free up the slot.
        enabledTransfers[blobId][recipient] = false;
        // Log the transfer.
        Transfer(blobId, recipient);
    }

    /**
     * @dev Disown a blob.
     * @param blobId Id of the blob.
     */
    function disown(bytes20 blobId) external isOwner(blobId) isTransferable(blobId) {
        // Remove the owner from the blob's state.
        delete blobInfo[blobId].owner;
        // Log that the blob has been disowned.
        Disown(blobId);
    }

    /**
     * @dev Set a blob as not updatable.
     * @param blobId Id of the blob.
     */
    function setNotUpdatable(bytes20 blobId) external isOwner(blobId) {
        // Record in state that the blob is not updatable.
        blobInfo[blobId].flags &= ~UPDATABLE;
        // Log that the blob is not updatable.
        SetNotUpdatable(blobId);
    }

    /**
     * @dev Set a blob to enforce revisions.
     * @param blobId Id of the blob.
     */
    function setEnforceRevisions(bytes20 blobId) external isOwner(blobId) {
        // Record in state that all changes to this blob must be new revisions.
        blobInfo[blobId].flags |= ENFORCE_REVISIONS;
        // Log that the blob now forces new revisions.
        SetEnforceRevisions(blobId);
    }

    /**
     * @dev Set a blob to not be retractable.
     * @param blobId Id of the blob.
     */
    function setNotRetractable(bytes20 blobId) external isOwner(blobId) {
        // Record in state that the blob is not retractable.
        blobInfo[blobId].flags &= ~RETRACTABLE;
        // Log that the blob is not retractable.
        SetNotRetractable(blobId);
    }

    /**
     * @dev Set a blob to not be transferable.
     * @param blobId Id of the blob.
     */
    function setNotTransferable(bytes20 blobId) external isOwner(blobId) {
        // Record in state that the blob is not transferable.
        blobInfo[blobId].flags &= ~TRANSFERABLE;
        // Log that the blob is not transferable.
        SetNotTransferable(blobId);
    }

    /**
     * @dev Get the id for this BlobStore contract.
     * @return Id of the contract.
     */
    function getContractId() external constant returns (bytes12) {
        return contractId;
    }

    /**
     * @dev Check if a blob exists.
     * @param blobId Id of the blob.
     * @return exists True if the blob exists.
     */
    function getExists(bytes20 blobId) external constant returns (bool exists) {
        BlobInfo info = blobInfo[blobId];
        exists = info.blockNumber != 0 && info.blockNumber != uint32(-1);
    }

    /**
     * @dev Get the block number for a specific blob revision.
     * @param blobId Id of the blob.
     * @param revisionId Id of the revision.
     * @return blockNumber Block number of the specified revision.
     */
    function _getRevisionBlockNumber(bytes20 blobId, uint revisionId) internal returns (uint blockNumber) {
        if (revisionId == 0) {
            blockNumber = blobInfo[blobId].blockNumber;
        }
        else {
            bytes32 slot = packedBlockNumbers[blobId][(revisionId - 1) / 8];
            blockNumber = uint32(uint256(slot) / 2**(((revisionId - 1) % 8) * 32));
        }
    }

    /**
     * @dev Get the block numbers for all of a blob's revisions.
     * @param blobId Id of the blob.
     * @return blockNumbers Revision block numbers.
     */
    function _getAllRevisionBlockNumbers(bytes20 blobId) internal returns (uint[] blockNumbers) {
        uint revisionCount = blobInfo[blobId].revisionCount;
        blockNumbers = new uint[](revisionCount);
        for (uint revisionId = 0; revisionId < revisionCount; revisionId++) {
            blockNumbers[revisionId] = _getRevisionBlockNumber(blobId, revisionId);
        }
    }

    /**
     * @dev Get info about a blob.
     * @param blobId Id of the blob.
     * @return flags Packed blob settings.
     * @return owner Owner of the blob.
     * @return revisionCount How many revisions the blob has.
     * @return blockNumbers The block numbers of the revisions.
     */
    function getInfo(bytes20 blobId) external constant exists(blobId) returns (bytes4 flags, address owner, uint revisionCount, uint[] blockNumbers) {
        BlobInfo info = blobInfo[blobId];
        flags = info.flags;
        owner = info.owner;
        revisionCount = info.revisionCount;
        blockNumbers = _getAllRevisionBlockNumbers(blobId);
    }

    /**
     * @dev Get all a blob's flags.
     * @param blobId Id of the blob.
     * @return flags Packed blob settings.
     */
    function getFlags(bytes20 blobId) external constant exists(blobId) returns (bytes4 flags) {
        flags = blobInfo[blobId].flags;
    }

    /**
     * @dev Determine if a blob is updatable.
     * @param blobId Id of the blob.
     * @return updatable True if the blob is updatable.
     */
    function getUpdatable(bytes20 blobId) external constant exists(blobId) returns (bool updatable) {
        updatable = blobInfo[blobId].flags & UPDATABLE != 0;
    }

    /**
     * @dev Determine if a blob enforces revisions.
     * @param blobId Id of the blob.
     * @return enforceRevisions True if the blob enforces revisions.
     */
    function getEnforceRevisions(bytes20 blobId) external constant exists(blobId) returns (bool enforceRevisions) {
        enforceRevisions = blobInfo[blobId].flags & ENFORCE_REVISIONS != 0;
    }

    /**
     * @dev Determine if a blob is retractable.
     * @param blobId Id of the blob.
     * @return retractable True if the blob is blob retractable.
     */
    function getRetractable(bytes20 blobId) external constant exists(blobId) returns (bool retractable) {
        retractable = blobInfo[blobId].flags & RETRACTABLE != 0;
    }

    /**
     * @dev Determine if a blob is transferable.
     * @param blobId Id of the blob.
     * @return transferable True if the blob is transferable.
     */
    function getTransferable(bytes20 blobId) external constant exists(blobId) returns (bool transferable) {
        transferable = blobInfo[blobId].flags & TRANSFERABLE != 0;
    }

    /**
     * @dev Get the owner of a blob.
     * @param blobId Id of the blob.
     * @return owner Owner of the blob.
     */
    function getOwner(bytes20 blobId) external constant exists(blobId) returns (address owner) {
        owner = blobInfo[blobId].owner;
    }

    /**
     * @dev Get the number of revisions a blob has.
     * @param blobId Id of the blob.
     * @return revisionCount How many revisions the blob has.
     */
    function getRevisionCount(bytes20 blobId) external constant exists(blobId) returns (uint revisionCount) {
        revisionCount = blobInfo[blobId].revisionCount;
    }

    /**
     * @dev Get the block number for a specific blob revision.
     * @param blobId Id of the blob.
     * @param revisionId Id of the revision.
     * @return blockNumber Block number of the specified revision.
     */
    function getRevisionBlockNumber(bytes20 blobId, uint revisionId) external constant revisionExists(blobId, revisionId) returns (uint blockNumber) {
        blockNumber = _getRevisionBlockNumber(blobId, revisionId);
    }

    /**
     * @dev Get the block numbers for all of a blob's revisions.
     * @param blobId Id of the blob.
     * @return blockNumbers Revision block numbers.
     */
    function getAllRevisionBlockNumbers(bytes20 blobId) external constant exists(blobId) returns (uint[] blockNumbers) {
        blockNumbers = _getAllRevisionBlockNumbers(blobId);
    }

}