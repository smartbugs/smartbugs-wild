pragma solidity ^0.4.16;

contract TestCoin {
    string public name;
    string public symbol;
    uint8 public decimals;

    event Transfer(address indexed from, address indexed to, uint256 value);

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function TestCoin() {
        balanceOf[msg.sender] = 4000000;  	            // Give the creator all initial tokens
        name = "TestCoin";                                  // Set the name for display purposes
        symbol = "TEST";  	                            // Set the symbol for display purposes
        decimals = 2;                   		    // Amount of decimals for display purposes
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        require(balanceOf[msg.sender] >= _value);           // Check if the sender has enough
        require(balanceOf[_to] + _value >= balanceOf[_to]); // Check for overflows
        balanceOf[msg.sender] -= _value;                    // Subtract from the sender
        balanceOf[_to] += _value;                           // Add the same to the recipient

        /* Notify anyone listening that this transfer took place */
        Transfer(msg.sender, _to, _value);
    }
}