pragma solidity ^0.4.2;

contract owned {
    address public owner;

    function owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract MyToken is owned {
    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;

    /* Public variables of the token */
    string public standard = 'Token 0.1';
    string public name = 'TrekMiles';
    string public symbol = 'TMC';
    uint8 public decimals = 0;
    uint256 public totalSupply;

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function MyToken() {
        uint256 initialSupply = 10;
        balanceOf[msg.sender] = initialSupply;
        totalSupply = initialSupply;
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);        // Notify anyone listening that this transfer took place
    }

    /* Mint coins */
    function mintToken(address target, uint256 mintedAmount) onlyOwner {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        Transfer(0, owner, mintedAmount);
        Transfer(owner, target, mintedAmount);
    }

    function () {
        //if ether is sent to this address, send it back.
        throw;
    }
}