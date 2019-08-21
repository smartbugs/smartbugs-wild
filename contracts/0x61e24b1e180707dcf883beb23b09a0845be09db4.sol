pragma solidity ^0.4.2;

contract Titaneum {
    /* Public variables of the token */
    string public standard = 'Token 0.1';
    string public name = "Titaneum";
    string public symbol = "TTNM";
    uint8 public decimals = 0;
    uint256 public totalSupply = 99000000;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function Titaneum() {
    
        balanceOf[msg.sender] = 99000000;              // Give the creator all initial tokens
        totalSupply = 99000000;                        // Update total supply
        name = "Titaneum";                                   // Set the name for display purposes
        symbol = "TTNM";                               // Set the symbol for display purposes
        decimals = 0;                            // Amount of decimals for display purposes
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }
}