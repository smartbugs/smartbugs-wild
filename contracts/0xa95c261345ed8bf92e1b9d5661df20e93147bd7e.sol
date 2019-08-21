pragma solidity ^0.4.24;

contract MusicTOKEN {

    uint256 public totalSupply = 99*10**28;
    string public name = "MusicTOKEN";
    uint8 public decimals = 18;
    string public symbol = "BESO";
    mapping (address => uint256) balances;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    

    constructor() public {
        balances[0xc79c47634a1D12E68017135f217dbC67200fb9A9] = totalSupply;
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