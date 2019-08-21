pragma solidity 0.4.24;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
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
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
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

// File: contracts/ContractRegistry.sol

contract ContractRegistry is Ownable {

  uint8 public constant version = 1;
  mapping (bytes32 => address) private contractAddresses;

  event UpdateContract(string name, address indexed contractAddress);

  /**
    @notice Ensures that a given address is a contract by making sure it has code.
   */
  function isContract(address _address)
    private
    view
    returns (bool)
  {
    uint256 _size;
    assembly { _size := extcodesize(_address) }
    return _size > 0;
  }

  function updateContractAddress(string _name, address _address)
    public
    onlyOwner
    returns (address)
  {
    require(isContract(_address));
    require(_address != contractAddresses[keccak256(_name)]);

    contractAddresses[keccak256(_name)] = _address;
    emit UpdateContract(_name, _address);

    return _address;
  }

  function getContractAddress(string _name)
    public
    view
    returns (address)
  {
    require(contractAddresses[keccak256(_name)] != address(0));
    return contractAddresses[keccak256(_name)];
  }

  function getContractAddress32(bytes32 _name32)
    public
    view
    returns (address)
  {
    require(contractAddresses[_name32] != address(0));
    return contractAddresses[_name32];
  }
}