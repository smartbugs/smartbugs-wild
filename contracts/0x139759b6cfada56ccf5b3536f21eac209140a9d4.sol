pragma solidity ^0.4.2;
contract Token {
    address public issuer;
    mapping (address => uint) public balances;

    function Token() {
        issuer = msg.sender;
        balances[issuer] = 1000000;
    }

    function transfer(address _to, uint _amount) {
        if (balances[msg.sender] < _amount) {
            throw;
        }

        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
    }
}