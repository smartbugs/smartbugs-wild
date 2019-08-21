pragma solidity 0.4.19;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract DataCentre is Ownable {
    struct Container {
        mapping(bytes32 => uint256) values;
        mapping(bytes32 => address) addresses;
        mapping(bytes32 => bool) switches;
        mapping(address => uint256) balances;
        mapping(address => mapping (address => uint)) constraints;
    }

    mapping(bytes32 => Container) containers;

    // Owner Functions
    function setValue(bytes32 _container, bytes32 _key, uint256 _value) onlyOwner {
        containers[_container].values[_key] = _value;
    }

    function setAddress(bytes32 _container, bytes32 _key, address _value) onlyOwner {
        containers[_container].addresses[_key] = _value;
    }

    function setBool(bytes32 _container, bytes32 _key, bool _value) onlyOwner {
        containers[_container].switches[_key] = _value;
    }

    function setBalanace(bytes32 _container, address _key, uint256 _value) onlyOwner {
        containers[_container].balances[_key] = _value;
    }


    function setConstraint(bytes32 _container, address _source, address _key, uint256 _value) onlyOwner {
        containers[_container].constraints[_source][_key] = _value;
    }

    // Constant Functions
    function getValue(bytes32 _container, bytes32 _key) constant returns(uint256) {
        return containers[_container].values[_key];
    }

    function getAddress(bytes32 _container, bytes32 _key) constant returns(address) {
        return containers[_container].addresses[_key];
    }

    function getBool(bytes32 _container, bytes32 _key) constant returns(bool) {
        return containers[_container].switches[_key];
    }

    function getBalanace(bytes32 _container, address _key) constant returns(uint256) {
        return containers[_container].balances[_key];
    }

    function getConstraint(bytes32 _container, address _source, address _key) constant returns(uint256) {
        return containers[_container].constraints[_source][_key];
    }
}