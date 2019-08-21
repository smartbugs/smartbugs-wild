pragma solidity 0.5.4;

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

contract pDNADistributedRegistryInterface {
  function getProperty(string memory _eGrid) public view returns (address property);
  function owner() public view returns (address);
}

contract CuratorsInterface {
  function checkRole(address _operator, string memory _permission) public view;
}

contract pDNA {
  address public constant CURATORS_ADDRESS = 0x75375B37845792256F274875b345F35597d1C053;  // 0x0f5Ea0A652E851678Ebf77B69484bFcD31F9459B;
  CuratorsInterface public curators = CuratorsInterface(CURATORS_ADDRESS);

  address public constant PDNA_DISTRIBUTED_REGISTRY_ADDRESS = 0xf8D03aE98997B7d58A69Db3B98a77AE6819Ff39b;  // 0xEC8bE1A5630364292E56D01129E8ee8A9578d7D8;
  pDNADistributedRegistryInterface public registry = pDNADistributedRegistryInterface(PDNA_DISTRIBUTED_REGISTRY_ADDRESS);

  string public name;
  string public symbol;

  mapping(string => bytes32) private files;

  event FilePut(address indexed curator, bytes32 indexed hash, string name);
  event FileRemoved(address indexed curator, bytes32 indexed hash, string name);

  modifier isValid() {
    require(registry.getProperty(name) == address(this), "invalid pDNA");
    _;
  }

  constructor(string memory _eGrid, string memory _grundstuck) public {
    name = _eGrid;
    symbol = _grundstuck;
  }

  function elea() public view returns (address) {
    return registry.owner();
  }

  function getFile(string memory _name) public view returns (bytes32) {
    return files[_name];
  }

  function removeFile(string memory _name) public isValid {
    curators.checkRole(msg.sender, "authorized");

    bytes32 hash = files[_name];
    require(hash != bytes32(0));

    files[_name] = bytes32(0);

    emit FileRemoved(msg.sender, hash, _name);
  }

  function putFile(bytes32 _hash, string memory _name) public isValid {
    curators.checkRole(msg.sender, "authorized");

    files[_name] = _hash;

    emit FilePut(msg.sender, _hash, _name);
  }
}