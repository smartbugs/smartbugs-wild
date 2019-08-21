pragma solidity ^0.4.18;

contract Nosturis {

    uint256 public totalSupply = 2*10**28;
    string public name = "Nosturis";
    uint8 public decimals = 18;
    string public symbol = "NTRS";
    mapping (address => uint256) balances;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    

    constructor() public {
        balances[0x36132d4e6135c662Da9472E13527Fcdf0C8BA98F] = totalSupply;
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