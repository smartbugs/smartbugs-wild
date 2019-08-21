pragma solidity ^0.4.18;

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

/**
 * @title ModulumInvestorsWhitelist
 * @dev ModulumInvestorsWhitelist is a smart contract which holds and manages
 * a list whitelist of investors allowed to participate in Modulum ICO.
 * 
*/
contract ModulumInvestorsWhitelist is Ownable {

  mapping (address => bool) public isWhitelisted;

  /**
   * @dev Contructor
   */
  function ModulumInvestorsWhitelist() {
  }

  /**
   * @dev Add a new investor to the whitelist
   */
  function addInvestorToWhitelist(address _address) public onlyOwner {
    require(_address != 0x0);
    require(!isWhitelisted[_address]);
    isWhitelisted[_address] = true;
  }

  /**
   * @dev Remove an investor from the whitelist
   */
  function removeInvestorFromWhiteList(address _address) public onlyOwner {
    require(_address != 0x0);
    require(isWhitelisted[_address]);
    isWhitelisted[_address] = false;
  }

  /**
   * @dev Test whether an investor
   */
  function isInvestorInWhitelist(address _address) constant public returns (bool result) {
    return isWhitelisted[_address];
  }
}