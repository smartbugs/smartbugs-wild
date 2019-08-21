pragma solidity ^0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
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
  function isOwner() public view returns(bool) {
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

contract BCEOInterface {
  function owner() public view returns (address);
  function balanceOf(address who) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  
}


contract TransferContract is Ownable {
  address private addressBCEO; 
  address private addressABT; 
  
  BCEOInterface private bCEOInstance;

  function initTransferContract(address _addressBCEO) public onlyOwner returns (bool) {
    require(_addressBCEO != address(0));
    addressBCEO = _addressBCEO;
    bCEOInstance = BCEOInterface(addressBCEO);
    return true;
  }

  function batchTransfer (address sender, address[] _receivers,  uint256[] _amounts) public onlyOwner {
    uint256 cnt = _receivers.length;
    require(cnt > 0);
    require(cnt == _amounts.length);
    for ( uint i = 0 ; i < cnt ; i++ ) {
      uint256 numBitCEO = _amounts[i];
      address receiver = _receivers[i];
      bCEOInstance.transferFrom(sender, receiver, numBitCEO * (10 ** uint256(18)));
    }
  }

}