pragma solidity ^0.4.8;

contract SOA {
    /* Public variables of the token */
    string public name = 'SOA Test Token';
    string public symbol = 'SOA';
    uint8 public decimals = 2;
    uint256 public totalSupply = 10000; // 100 

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function SOA() {
        balanceOf[msg.sender] = totalSupply;
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        assert(_to != 0x0);
        assert(balanceOf[msg.sender] >= _value);
        assert(balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balanceOf[_owner];
    }
}