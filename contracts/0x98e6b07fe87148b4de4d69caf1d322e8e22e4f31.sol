pragma solidity ^0.4.15;

contract Token {
    function transfer(address _to, uint _value) returns (bool success);
}

contract Safe {
    uint256 public lock = 1541422740;
    address public owner;

    function Safe() {
        owner = msg.sender;
    }
    
    function transfer(address to) returns (bool) {
        require(msg.sender == owner);
        require(to != address(0));
        owner = to;
        return true;
    }

    function withdrawal(Token token, address to, uint value) returns (bool) {
        require(msg.sender == owner);
        require(block.timestamp >= lock);
        require(to != address(0));
        return token.transfer(to, value);
    }
}