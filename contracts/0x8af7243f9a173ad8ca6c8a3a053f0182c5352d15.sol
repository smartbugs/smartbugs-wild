pragma solidity ^0.4.8;
contract Soarcoin {

    mapping (address => uint256) balances;               // each address in this contract may have tokens. 
    address internal owner = 0x4Bce8E9850254A86a1988E2dA79e41Bc6793640d;                // the owner is the creator of the smart contract
    string public name = "Soarcoin";                     // name of this contract and investment fund
    string public symbol = "SOAR";                       // token symbol
    uint8 public decimals = 6;                           // decimals (for humans)
    uint256 public totalSupply = 5000000000000000;  
           
    modifier onlyOwner()
    {
        if (msg.sender != owner) throw;
        _;
    }

    function Soarcoin() { balances[owner] = totalSupply; }    

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // query balance
    function balanceOf(address _owner) constant returns (uint256 balance)
    {
        return balances[_owner];
    }

    // transfer tokens from one address to another
    function transfer(address _to, uint256 _value) returns (bool success)
    {
        if(_value <= 0) throw;                                      // Check send token value > 0;
        if (balances[msg.sender] < _value) throw;                   // Check if the sender has enough
        if (balances[_to] + _value < balances[_to]) throw;          // Check for overflows                          
        balances[msg.sender] -= _value;                             // Subtract from the sender
        balances[_to] += _value;                                    // Add the same to the recipient, if it's the contact itself then it signals a sell order of those tokens                       
        Transfer(msg.sender, _to, _value);                          // Notify anyone listening that this transfer took place
        return true;      
    }

    function mint(address _to, uint256 _value) onlyOwner
    {
    	balances[_to] += _value;
    	totalSupply += _value;
    }
}