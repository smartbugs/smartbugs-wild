pragma solidity ^0.4.21;

contract Proxy{
  address public owner;
  address public target;
  event ProxyTargetSet(address target);
  event ProxyOwnerChanged(address _owner);

  constructor () public{
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function setTarget(address _target) public onlyOwner {
    target = _target;
    emit ProxyTargetSet(_target);
  }

  function setOwner(address _owner) public onlyOwner {
    owner = _owner;
    emit ProxyOwnerChanged(_owner);
  }

  function () payable public {
    address _impl = target;
    require(_impl != address(0));

    assembly {
      let ptr := mload(0x40)
      calldatacopy(ptr, 0, calldatasize)
      let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
      let size := returndatasize
      returndatacopy(ptr, 0, size)

      switch result
      case 0 { revert(ptr, size) }
      default { return(ptr, size) }
    }
  }
}