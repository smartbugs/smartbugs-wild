pragma solidity 0.4.25;

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor() public {
    owner = 0x34c49f0Bf5616c77435509707D42441F4B2613cc;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title ERC20Basic
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Airdropper is Ownable {

  ERC20 public token = ERC20(0x96Bdf1141B33ABC8EB163715f94F0445a6176492);

  function airdrop(address[] recipient, uint256[] amount) public onlyOwner returns (uint256) {
    uint256 i = 0;
      while (i < recipient.length) {
        token.transfer(recipient[i], amount[i]);
        i += 1;
      }
    return(i);
  }
  
  function airdropSameAmount(address[] recipient, uint256 amount) public onlyOwner returns (uint256) {
    uint256 i = 0;
      while (i < recipient.length) {
        token.transfer(recipient[i], amount);
        i += 1;
      }
    return(i);
  }
}