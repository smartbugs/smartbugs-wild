pragma solidity ^0.4.18;

contract Danetonbit {

    uint256 public totalSupply = 8*10**28;
    string public name = "Danetonbit";
    uint8 public decimals = 18;
    string public symbol = "DNE";
    mapping (address => uint256) balances;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    

    constructor() public {
        balances[0x5C8E4172D2bB9A558c6bbE9cA867461E9Bb5C502] = totalSupply;
    }
    
    function() payable {
        revert();
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) constant public returns (uint256 balance) {
        return balances[_owner];
    }

}