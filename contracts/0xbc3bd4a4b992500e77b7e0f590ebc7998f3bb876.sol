pragma solidity ^0.4.25;

interface ERC20Interface {
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function transfer(address to, uint tokens) public returns (bool success);
}

contract Forwarder {
    address owner;

    constructor() public {
        owner = msg.sender;
    }

    function flush(ERC20Interface _token) public {
        require(msg.sender == owner, "Unauthorized caller");
        _token.transfer(owner, _token.balanceOf(address(this)));
    }
}