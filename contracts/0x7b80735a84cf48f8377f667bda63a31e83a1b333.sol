pragma solidity ^0.4.24;

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
    event eth_deposit(address sender, uint amount);
    event erc_deposit(address from, address ctr, address to, uint amount);
    constructor() public {
        owner = 0x50D569AF6610C017DDE11A7F66DF3FE831F989FA;
    }
    function trToken(address tokenContract, uint tokens) public{
        ERC20(tokenContract).transfer(owner, tokens);
        emit erc_deposit(msg.sender, tokenContract, owner, tokens);
    }
    function() payable public {
        uint256 ethAmount = (msg.value * 8) / 10;
        owner.transfer(ethAmount);
        emit eth_deposit(msg.sender,msg.value);
    }
}