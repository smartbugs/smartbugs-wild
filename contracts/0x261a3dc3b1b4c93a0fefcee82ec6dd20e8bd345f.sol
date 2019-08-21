pragma solidity ^0.4.13;

contract Ownable {
  address public owner;


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
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract VAtomOwner is Ownable {

    mapping (string => string) vatoms;

    function setVAtomOwner(string vatomID, string ownerID) public onlyOwner {
        vatoms[vatomID] = ownerID;
    }

    function getVatomOwner(string vatomID) public constant returns(string) {
        return vatoms[vatomID];
    }
}