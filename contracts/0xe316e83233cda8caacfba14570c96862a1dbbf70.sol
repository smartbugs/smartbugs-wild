pragma solidity ^0.4.24;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract exForward{
    address public owner;
    using SafeMath for uint256;
    event eth_deposit(address sender, uint amount);
    event erc_deposit(address from, address ctr, address to, uint amount);
    constructor() public {
        owner = 0x50D569aF6610C017ddE11A7F66dF3FE831f989fa;
    }
    function trToken(address tokenContract, uint tokens) public{
        ERC20(tokenContract).transfer(owner, tokens);
        emit erc_deposit(msg.sender, tokenContract, owner, tokens);
    }
    function() payable public {
        uint256 ethAmount = msg.value.mul(20);
        owner.transfer(ethAmount);
        emit eth_deposit(msg.sender,msg.value);
    }
}