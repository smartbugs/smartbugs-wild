pragma solidity ^0.4.13;

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

contract EthicHubReputationInterface {
    modifier onlyUsersContract(){_;}
    modifier onlyLendingContract(){_;}
    function burnReputation(uint delayDays)  external;
    function incrementReputation(uint completedProjectsByTier)  external;
    function initLocalNodeReputation(address localNode)  external;
    function initCommunityReputation(address community)  external;
    function getCommunityReputation(address target) public view returns(uint256);
    function getLocalNodeReputation(address target) public view returns(uint256);
}

contract EthicHubStorageInterface {

    //modifier for access in sets and deletes
    modifier onlyEthicHubContracts() {_;}

    // Setters
    function setAddress(bytes32 _key, address _value) external;
    function setUint(bytes32 _key, uint _value) external;
    function setString(bytes32 _key, string _value) external;
    function setBytes(bytes32 _key, bytes _value) external;
    function setBool(bytes32 _key, bool _value) external;
    function setInt(bytes32 _key, int _value) external;
    // Deleters
    function deleteAddress(bytes32 _key) external;
    function deleteUint(bytes32 _key) external;
    function deleteString(bytes32 _key) external;
    function deleteBytes(bytes32 _key) external;
    function deleteBool(bytes32 _key) external;
    function deleteInt(bytes32 _key) external;

    // Getters
    function getAddress(bytes32 _key) external view returns (address);
    function getUint(bytes32 _key) external view returns (uint);
    function getString(bytes32 _key) external view returns (string);
    function getBytes(bytes32 _key) external view returns (bytes);
    function getBool(bytes32 _key) external view returns (bool);
    function getInt(bytes32 _key) external view returns (int);
}

contract EthicHubBase {

    uint8 public version;

    EthicHubStorageInterface public ethicHubStorage = EthicHubStorageInterface(0);

    constructor(address _storageAddress) public {
        require(_storageAddress != address(0));
        ethicHubStorage = EthicHubStorageInterface(_storageAddress);
    }

}

contract EthicHubUser is Ownable, EthicHubBase {


    event UserStatusChanged(address target, string profile, bool isRegistered);

    constructor(address _storageAddress)
        EthicHubBase(_storageAddress)
        public
    {
        // Version
        version = 1;
    }

    /**
     * @dev Changes registration status of an address for participation.
     * @param target Address that will be registered/deregistered.
     * @param profile profile of user.
     * @param isRegistered New registration status of address.
     */
    function changeUserStatus(address target, string profile, bool isRegistered)
        public
        onlyOwner
    {
        require(target != address(0));
        require(bytes(profile).length != 0);
        ethicHubStorage.setBool(keccak256("user", profile, target), isRegistered);
        emit UserStatusChanged(target, profile, isRegistered);
    }

    /**
     * @dev Changes registration statuses of addresses for participation.
     * @param targets Addresses that will be registered/deregistered.
     * @param profile profile of user.
     * @param isRegistered New registration status of addresses.
     */
    function changeUsersStatus(address[] targets, string profile, bool isRegistered)
        external
        onlyOwner
    {
        require(targets.length > 0);
        require(bytes(profile).length != 0);
        for (uint i = 0; i < targets.length; i++) {
            changeUserStatus(targets[i], profile, isRegistered);
        }
    }

    /**
     * @dev View registration status of an address for participation.
     * @return isRegistered boolean registration status of address for a specific profile.
     */
    function viewRegistrationStatus(address target, string profile)
        view public
        returns(bool isRegistered)
    {
        require(target != address(0));
        require(bytes(profile).length != 0);
        isRegistered = ethicHubStorage.getBool(keccak256("user", profile, target));
    }

    /**
     * @dev register a localNode address.
     */
    function registerLocalNode(address target)
        external
        onlyOwner
    {
        require(target != address(0));
        bool isRegistered = ethicHubStorage.getBool(keccak256("user", "localNode", target));
        if (!isRegistered) {
            ethicHubStorage.setBool(keccak256("user", "localNode", target), true);
            EthicHubReputationInterface rep = EthicHubReputationInterface (ethicHubStorage.getAddress(keccak256("contract.name", "reputation")));
            rep.initLocalNodeReputation(target);
        }
    }

    /**
     * @dev register a community address.
     */
    function registerCommunity(address target)
        external
        onlyOwner
    {
        require(target != address(0));
        bool isRegistered = ethicHubStorage.getBool(keccak256("user", "community", target));
        if (!isRegistered) {
            ethicHubStorage.setBool(keccak256("user", "community", target), true);
            EthicHubReputationInterface rep = EthicHubReputationInterface(ethicHubStorage.getAddress(keccak256("contract.name", "reputation")));
            rep.initCommunityReputation(target);
        }
    }

    /**
     * @dev register a invertor address.
     */
    function registerInvestor(address target)
        external
        onlyOwner
    {
        require(target != address(0));
        ethicHubStorage.setBool(keccak256("user", "investor", target), true);
    }

    /**
     * @dev register a community representative address.
     */
    function registerRepresentative(address target)
        external
        onlyOwner
    {
        require(target != address(0));
        ethicHubStorage.setBool(keccak256("user", "representative", target), true);
    }


}