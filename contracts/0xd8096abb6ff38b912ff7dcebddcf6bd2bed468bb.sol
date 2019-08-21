pragma solidity ^0.4.17;

/** @title Decentralized Identification Number (DIN) registry. */
contract DINRegistry {

    struct Record {
        address owner;
        address resolver;  // Address of the resolver contract, which can be used to find product information. 
        uint256 updated;   // Last updated time (Unix timestamp).
    }

    // DIN => Record
    mapping (uint256 => Record) records;

    // The first DIN registered.
    uint256 public genesis;

    // The current DIN.
    uint256 public index;

    modifier only_owner(uint256 DIN) {
        require(records[DIN].owner == msg.sender);
        _;
    }

    // Log transfers of ownership.
    event NewOwner(uint256 indexed DIN, address indexed owner);

    // Log when new resolvers are set.
    event NewResolver(uint256 indexed DIN, address indexed resolver);

    // Log new registrations.
    event NewRegistration(uint256 indexed DIN, address indexed owner);

    /** @dev Constructor.
      * @param _genesis The first DIN registered.
      */
    function DINRegistry(uint256 _genesis) public {
        genesis = _genesis;
        index = _genesis;

        // Register the genesis DIN to the account that deploys this contract.
        records[_genesis].owner = msg.sender;
        records[_genesis].updated = block.timestamp;
        NewRegistration(_genesis, msg.sender);
    }

    /**
     * @dev Get the owner of a specific DIN.
     */
    function owner(uint256 _DIN) public view returns (address) {
        return records[_DIN].owner;
    }

    /**
     * @dev Transfer ownership of a DIN.
     * @param _DIN The DIN to transfer.
     * @param _owner Address of the new owner.
     */
    function setOwner(uint256 _DIN, address _owner) public only_owner(_DIN) {
        records[_DIN].owner = _owner;
        records[_DIN].updated = block.timestamp;
        NewOwner(_DIN, _owner);
    }

    /**
     * @dev Get the address of the resolver contract for a specific DIN.
     */
    function resolver(uint256 _DIN) public view returns (address) {
        return records[_DIN].resolver;
    }

    /**
     * @dev Set the resolver of a DIN.
     * @param _DIN The DIN to update.
     * @param _resolver Address of the resolver.
     */
    function setResolver(uint256 _DIN, address _resolver) public only_owner(_DIN) {
        records[_DIN].resolver = _resolver;
        records[_DIN].updated = block.timestamp;
        NewResolver(_DIN, _resolver);
    }

    /**
     * @dev Get the last time a DIN was updated with a new owner or resolver.
     * @param _DIN The DIN to query.
     * @return _timestamp Last updated time (Unix timestamp).
     */
    function updated(uint256 _DIN) public view returns (uint256 _timestamp) {
        return records[_DIN].updated;
    }

    /**
     * @dev Self-register a new DIN.
     * @return _DIN The DIN that is registered.
     */
    function selfRegisterDIN() public returns (uint256 _DIN) {
        return registerDIN(msg.sender);
    }

    /**
     * @dev Self-register a new DIN and set the resolver.
     * @param _resolver Address of the resolver.
     * @return _DIN The DIN that is registered.
     */
    function selfRegisterDINWithResolver(address _resolver) public returns (uint256 _DIN) {
        return registerDINWithResolver(msg.sender, _resolver);
    }

    /**
     * @dev Register a new DIN for a specific address.
     * @param _owner Account that will own the DIN.
     * @return _DIN The DIN that is registered.
     */
    function registerDIN(address _owner) public returns (uint256 _DIN) {
        index++;
        records[index].owner = _owner;
        records[index].updated = block.timestamp;
        NewRegistration(index, _owner);
        return index;
    }

    /**
     * @dev Register a new DIN and set the resolver.
     * @param _owner Account that will own the DIN.
     * @param _resolver Address of the resolver.
     * @return _DIN The DIN that is registered.
     */
    function registerDINWithResolver(address _owner, address _resolver) public returns (uint256 _DIN) {
        index++;
        records[index].owner = _owner;
        records[index].resolver = _resolver;
        records[index].updated = block.timestamp;
        NewRegistration(index, _owner);
        NewResolver(index, _resolver);
        return index;
    }

}