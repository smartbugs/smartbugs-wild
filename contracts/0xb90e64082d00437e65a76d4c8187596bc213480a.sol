/**
 *  StickerRegistry
 *
 *  This is a simple contract to implement a demo of a collectible blockchain
 *  item.
 *
 *  As part of the Firefly Crowdsale, backers and participants of various events
 *  will receive limited edition Firefly stickers. Each sticker is procedurally
 *  generated and unique. The ownership of the sticker is tracked by an instance
 *  of this contract.
 *
 *  Since many people will likely not care about the actual sticker, ownership
 *  and all that jazz, this has been designed to be very gas effecient from the
 *  project owner's point of view.
 *
 *  When a new series is minted, the entire series manifest is made public, along with
 *  a list of faux owners. Each faux owner is an address, for which there exists a
 *  secret, which can be used to generate a private key and claim the sticker by
 *  signing a message (the destination address) and calling this contract.
 *
 *  All the faux owners along with their sticker serial number are used to create a
 *  merkle tree, of which only the merkle root is registered with the set.
 *
 *  Nomenclature
 *   - Serial Number:  1-indexed (human ordinal) index into the list of items/redeem codes
 *   - item index:     0-indexed (mchine ordinal) representation of the Serial Number
 */

/**
 *  Why use ENS?
 *   - Enforces series name uniqueness
 *   - Offloads series ownership and name collision disputes
 *   - Hierarchical (e.g. weatherlight.mtg.wotc.eth)
 *   - Strong authenticity and identity
 *   - Prevents spam
 *   - A well-adopted standard that will be maintained and extended
 */

// See: https://github.com/firefly/stickers


pragma solidity ^0.4.16;

// This is only used to enable token withdrawl incase this contract is
// somehow given some (e.g. airdopped)
contract Token {
    function approve(address, uint256) returns (bool);
}

// We use ENS to manage series ownership
contract AbstractENS {
    function owner(bytes32) constant returns(address);
    function resolver(bytes32) constant returns(address);
}

contract Resolver {
    function addr(bytes32);
}

contract ReverseRegistrar {
    function claim(address) returns (bytes32);
}



contract StickerRegistry {

    // namehash('addr.reverse')
    bytes32 constant RR_NODE = 0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;

    event seriesCreated(bytes32 indexed nodehash);

    event itemTransferred(
        bytes32 indexed nodehash,
        uint256 itemIndex,
        address indexed oldOwner,
        address indexed newOwner
    );


    struct Series {
        // The name of the series (the namehash of this should resovle to the nodehash)
        string name;

        // The merkle root of all stikers in the series
        bytes32 rootHash;

        // The initial number of cards issued
        uint256 initialCount;

        // How many have been claimed
        uint256 issuedCount;

        // The total number in existance after taking provable burning into account
        uint256 currentCount;

        // Maps a serial number to an owner
        mapping (uint256 => address) owners;
    }

    AbstractENS _ens;

    address _owner;

    mapping (bytes32 => Series) _series;


    function StickerRegistry(address ens) {
        _owner = msg.sender;
        _ens = AbstractENS(ens);

        // Give the owner access to the reverse entry
        ReverseRegistrar(_ens.owner(RR_NODE)).claim(_owner);
    }

    function setOwner(address newOwner) {
        require(msg.sender == _owner);
        _owner = newOwner;

        // Give the owner access to the reverse entry
        ReverseRegistrar(_ens.owner(RR_NODE)).claim(_owner);
    }

    // Bailout - Just in case this contract ever receives funds
    function withdraw(address target, uint256 amount) {
        require(msg.sender == _owner);
        assert(target.send(amount));
    }

    // Bailout - Just in case this contract ever received tokens
    function approveToken(address token, uint256 amount) {
        require(msg.sender == _owner);
        assert(Token(token).approve(_owner, amount));
    }


    // Create a new series
    function createSeries(bytes32 nodehash, string seriesName, bytes32 rootHash, uint256 initialCount) returns (bool success) {

        // Only the ENS owner of the nodehash may create this series
        if (msg.sender != _ens.owner(nodehash)) { return false; }

        if (rootHash == 0x00) { return false; }

        Series storage series = _series[nodehash];

        // Already exists!
        if (series.rootHash != 0x00) { return false; }

        series.name = seriesName;
        series.rootHash = rootHash;
        series.initialCount = initialCount;
        series.currentCount = initialCount;

        seriesCreated(nodehash);
    }

    // Allow the owner to transfer un-claimed items (they already have the
    // redeem codes, so there is no additional trust required)
    function bestow(bytes32 nodehash, uint256 itemIndex, address owner) returns (bool success) {

        // Only the ENS owner of nodehash may bestow
        if (_ens.owner(nodehash) != msg.sender) { return false; }

        Series storage series = _series[nodehash];

        if (itemIndex >= series.initialCount) { return false; }

        // Already claimed
        if (series.owners[itemIndex] != 0) { return false; }

        // Burning...
        if (owner == 0xdead) { series.currentCount--; }

        series.issuedCount++;

        series.owners[itemIndex] = owner;

        itemTransferred(nodehash, itemIndex, 0x0, owner);
    }

    // Allow a user to claim an item using their redeem code
    function claim(bytes32 nodehash, uint256 itemIndex, address owner, uint8 sigV, bytes32 sigR, bytes32 sigS,  bytes32[] merkleProof) returns (bool success) {
        Series storage series = _series[nodehash];

        if (itemIndex >= series.initialCount) { return false; }

        // Already claimed
        if (series.owners[itemIndex] != 0) { return false; }

        uint256 path = itemIndex;

        // Compute the redeem code address from the provided proof
        address fauxOwner = ecrecover(bytes32(owner), sigV, sigR, sigS);

        // Verify the merkle proof
        bytes32 node = keccak256(nodehash, itemIndex, bytes32(fauxOwner));
        for (uint16 i = 0; i < merkleProof.length; i++) {
            if ((path & 0x01) == 1) {
                node = keccak256(merkleProof[i], node);
            } else {
                node = keccak256(node, merkleProof[i]);
            }
            path /= 2;
        }

        // Failed merkle proof
        if (node != series.rootHash) { return false; }

        // Assign the caller as the owner
        series.owners[itemIndex] = owner;

        // One more has been issued
        series.issuedCount++;

        itemTransferred(nodehash, itemIndex, 0x0, owner);

        return true;
    }

    // Allow item owners to transfer to another account
    function transfer(bytes32 nodehash, uint256 itemIndex, address newOwner) returns (bool success) {

        // Do not allow transfering to 0 (would allow claiming again)
        if (newOwner == 0) { return false; }

        Series storage series = _series[nodehash];

        address currentOwner = series.owners[itemIndex];

        // Only the owner can transfer a item
        if (currentOwner != msg.sender) {
            return false;
        }

        // Burining! Anyone may choose to destroy a sticker to provably lower
        // its total supply
        if (newOwner == 0xdead) { series.currentCount--; }

        itemTransferred(nodehash, itemIndex, currentOwner, newOwner);

        // Assign the new owner
        series.owners[itemIndex] = newOwner;

        return true;
    }


    // Get the contract owner
    function owner() constant returns (address) {
        return _owner;
    }

    // Get details about a given series
    function seriesInfo(bytes32 nodehash) constant returns (string name, bytes32 rootHash, uint256 initialCount, uint256 issuedCount, uint256 currentCount) {
        Series storage series = _series[nodehash];
        return (series.name, series.rootHash, series.initialCount, series.issuedCount, series.currentCount);
    }

    // Get the owner of an item
    function itemOwner(bytes32 nodehash, uint256 itemIndex) constant returns (address) {
        return _series[nodehash].owners[itemIndex];
    }
}