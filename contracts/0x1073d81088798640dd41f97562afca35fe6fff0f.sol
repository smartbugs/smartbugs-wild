pragma solidity ^0.4.25;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control 
 * functions, this simplifies the implementation of "user permissions". 
 */
contract Ownable {
  address public owner;

  constructor() public {
    owner = msg.sender;
  }
 
  modifier onlyOwner() {
    require (msg.sender == owner);
    _;
  }
 
  function transferOwnership(address newOwner) onlyOwner external {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}
 
contract ERC20 {
  function transfer(address to, uint value) public;
}

contract Airdropper is Ownable {

    function multisend(address _tokenAddr, address[] dests, uint256[] values)
        external
        onlyOwner
    {
        for (uint i = 0; i < dests.length; i++) {
           ERC20(_tokenAddr).transfer(dests[i], values[i]);
        }
    }
}