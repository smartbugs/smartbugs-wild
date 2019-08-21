pragma solidity ^0.4.13;

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

contract EthicHubArbitrage is EthicHubBase, Ownable {

    event ArbiterAssigned (
        address indexed _arbiter,                    // Address of the arbiter
        address indexed _lendingContract            // Address of the lending contract
    );

    event ArbiterRevoked (
        address indexed _arbiter,                    // Address of the arbiter
        address indexed _lendingContract            // Address of the lending contract
    );

    constructor(address _storageAddress) EthicHubBase(_storageAddress) public {
        // Version
        version = 1;
    }

    function assignArbiterForLendingContract(address _arbiter, address _lendingContract) public onlyOwner {
        require(_arbiter != address(0));
        require(_lendingContract != address(0));
        require(_lendingContract == ethicHubStorage.getAddress(keccak256("contract.address", _lendingContract)));
        ethicHubStorage.setAddress(keccak256("arbiter", _lendingContract), _arbiter);
        emit ArbiterAssigned(_arbiter, _lendingContract);
    }

    function revokeArbiterForLendingContract(address _arbiter, address _lendingContract) public onlyOwner {
        require(_arbiter != address(0));
        require(_lendingContract != address(0));
        require(_lendingContract == ethicHubStorage.getAddress(keccak256("contract.address", _lendingContract)));
        require(arbiterForLendingContract(_lendingContract) == _arbiter);
        ethicHubStorage.deleteAddress(keccak256("arbiter", _lendingContract));
        emit ArbiterRevoked(_arbiter, _lendingContract);
    }

    function arbiterForLendingContract(address _lendingContract) public view returns(address) {
        return ethicHubStorage.getAddress(keccak256("arbiter", _lendingContract));
    }

}