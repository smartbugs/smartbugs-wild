pragma solidity 0.4.6;

contract Owned {
    address public contractOwner;
    address public pendingContractOwner;

    function Owned() {
        contractOwner = msg.sender;
    }

    modifier onlyContractOwner() {
        if (contractOwner == msg.sender) {
            _;
        }
    }

    function changeContractOwnership(address _to) onlyContractOwner() returns(bool) {
        pendingContractOwner = _to;
        return true;
    }

    function claimContractOwnership() returns(bool) {
        if (pendingContractOwner != msg.sender) {
            return false;
        }
        contractOwner = pendingContractOwner;
        delete pendingContractOwner;
        return true;
    }
}

contract PropyPrototype is Owned {
    struct IdentityProvider {
        string metadata;
    }

    struct Owner {
        uint identityVerificationId;
        address identityVerificationProvider;
        bool status; // unverified/verified
        string metadata;
    }

    struct Title {
        string legalAddress;
        bytes32 ownerId;
        bytes32 lastDeedId;
        bool status; // executed/pending
        string metadata;
    }

    struct Deed {
        bytes32 titleId;
        bytes32 buyerId;
        bytes32 sellerId;
        uint status; // in progress/notarized/cancelled
        string metadata;
    }

    mapping(address => IdentityProvider) identityProviders;
    mapping(bytes32 => Owner) owners;
    mapping(bytes32 => Title) titles;
    bytes32[] public titleIds;
    mapping(bytes32 => Deed) deeds;
    bytes32[] public deedIds;

    function putIdentityProvider(address _address, string _metadata) onlyContractOwner() returns(bool success) {
        identityProviders[_address].metadata = _metadata;
        return true;
    }

    function getIdentityProvider(address _address) constant returns(string metadata) {
        return identityProviders[_address].metadata;
    }

    function putOwner(bytes32 _id, uint _identityVerificationId, address _identityVerificationProvider, bool _status, string _metadata) onlyContractOwner() returns(bool success) {
        owners[_id] = Owner(_identityVerificationId, _identityVerificationProvider, _status, _metadata);
        return true;
    }

    function getOwner(bytes32 _id) constant returns(uint identityVerificationId, string identityProvider, string status, string metadata) {
        var owner = owners[_id];
        return (
            owner.identityVerificationId,
            getIdentityProvider(owner.identityVerificationProvider),
            owner.status ? "Verified" : "Unverified",
            owner.metadata
        );
    }

    function putTitle(bytes32 _id, string _legalAddress, bytes32 _ownerId, bytes32 _lastDeedId, bool _status, string _metadata) onlyContractOwner() returns(bool success) {
        if (bytes(_legalAddress).length == 0) {
            return false;
        }
        if (owners[_ownerId].identityVerificationProvider == 0x0) {
            return false;
        }
        if (bytes(titles[_id].legalAddress).length == 0) {
            titleIds.push(_id);
        }
        titles[_id] = Title(_legalAddress, _ownerId, _lastDeedId, _status, _metadata);
        return true;
    }

    function getTitle(bytes32 _id) constant returns(string legalAddress, bytes32 ownerId, string owner, bytes32 lastDeedId, string lastDeed, string status, string metadata) {
        var title = titles[_id];
        return (
            title.legalAddress,
            title.ownerId,
            owners[title.ownerId].metadata,
            title.lastDeedId,
            deeds[title.lastDeedId].metadata,
            title.status ? "Executed" : "Pending",
            title.metadata
        );
    }

    function getDeedId(bytes32 _titleId, uint _index) constant returns(bytes32) {
        return sha3(_titleId, _index);
    }

    function putDeed(bytes32 _titleId, uint _index, bytes32 _buyerId, bytes32 _sellerId, uint _status, string _metadata) onlyContractOwner() returns(bool success) {
        if (bytes(titles[_titleId].legalAddress).length == 0) {
            return false;
        }
        if (owners[_buyerId].identityVerificationProvider == 0x0) {
            return false;
        }
        if (owners[_sellerId].identityVerificationProvider == 0x0) {
            return false;
        }
        if (_status > 2) {
            return false;
        }
        bytes32 id = getDeedId(_titleId, _index);
        if (uint(deeds[id].titleId) == 0) {
            deedIds.push(id);
        }
        deeds[id] = Deed(_titleId, _buyerId, _sellerId, _status, _metadata);
        return true;
    }

    function getDeed(bytes32 _id) constant returns(bytes32 titleId, string title, bytes32 buyerId, string buyer, bytes32 sellerId, string seller, string status, string metadata) {
        var deed = deeds[_id];
        return (
            deed.titleId,
            titles[deed.titleId].metadata,
            deed.buyerId,
            owners[deed.buyerId].metadata,
            deed.sellerId,
            owners[deed.sellerId].metadata,
            deed.status == 0 ? "In Progress" :
                deed.status == 1 ? "Notarized" : "Cancelled",
            deed.metadata
        );
    }

    // Should not be used in non constant functions!
    function getTitleDeeds(bytes32 _titleId) constant returns(bytes32[]) {
        uint deedsCount = 0;
        while(uint(deeds[getDeedId(_titleId, deedsCount)].titleId) != 0) {
            deedsCount++;
        }
        bytes32[] memory result = new bytes32[](deedsCount);
        for (uint i = 0; i < deedsCount; i++) {
            result[i] = getDeedId(_titleId, i);
        }
        return result;
    }
}