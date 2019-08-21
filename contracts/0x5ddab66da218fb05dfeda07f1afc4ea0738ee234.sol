pragma solidity ^0.4.9;

// ----------------------------------------------------------------------------------------------
// The new RARE token contract
//
// https://github.com/bokkypoobah/RAREPeperiumToken
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2017 for Michael C. The MIT Licence.
// ----------------------------------------------------------------------------------------------

contract Owned {
    address public owner;
    address public newOwner;
    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    function transferOwnership(address _newOwner) onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() {
        if (msg.sender == newOwner) {
            OwnershipTransferred(owner, newOwner);
            owner = newOwner;
        }
    }
}


contract ERC20Token is Owned {
    string public symbol;
    string public name;
    uint8 public decimals;
    uint256 public totalSupply;

    // ------------------------------------------------------------------------
    // Balances for each account
    // ------------------------------------------------------------------------
    mapping (address => uint256) balances;

    // ------------------------------------------------------------------------
    // Owner of account approves the transfer of an amount to another account
    // ------------------------------------------------------------------------
    mapping (address => mapping (address => uint256)) allowed;

    // ------------------------------------------------------------------------
    // Events
    // ------------------------------------------------------------------------
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    function ERC20Token(string _symbol, string _name, uint8 _decimals, uint256 _totalSupply) {
        symbol = _symbol;
        name = _name;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balances[msg.sender] = _totalSupply;
    }

    // ------------------------------------------------------------------------
    // Get the account balance of another account with address _owner
    // ------------------------------------------------------------------------
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from owner's account to another account
    // ------------------------------------------------------------------------
    function transfer(address _to, uint256 _amount) returns (bool success) {
        if (balances[msg.sender] >= _amount             // User has balance
            && _amount > 0                              // Non-zero transfer
            && balances[_to] + _amount > balances[_to]  // Overflow check
        ) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    // ------------------------------------------------------------------------
    // Allow _spender to withdraw from your account, multiple times, up to the
    // _value amount. If this function is called again it overwrites the
    // current allowance with _value.
    // ------------------------------------------------------------------------
    function approve(address _spender, uint256 _amount) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    // ------------------------------------------------------------------------
    // Spender of tokens transfer an amount of tokens from the token owner's
    // balance to another account. The owner of the tokens must already
    // have approve(...)-d this transfer
    // ------------------------------------------------------------------------
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) returns (bool success) {
        if (balances[_from] >= _amount                  // From a/c has balance
            && allowed[_from][msg.sender] >= _amount    // Transfer approved
            && _amount > 0                              // Non-zero transfer
            && balances[_to] + _amount > balances[_to]  // Overflow check
        ) {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    // ------------------------------------------------------------------------
    // Don't accept ethers
    // ------------------------------------------------------------------------
    function () {
        throw;
    }
}


contract RareToken is ERC20Token {
    // ------------------------------------------------------------------------
    // 100,000,000 tokens that will be populated by the fill, 8 decimal places
    // ------------------------------------------------------------------------
    function RareToken() ERC20Token ("RARE", "RARE", 8, 0) {
    }

    function burnTokens(uint256 value) onlyOwner {
        if (balances[owner] < value) throw;
        balances[owner] -= value;
        totalSupply -= value;
        Transfer(owner, 0, value);
    }

    // ------------------------------------------------------------------------
    // Fill - to populate tokens from the old token contract
    // ------------------------------------------------------------------------
    // From https://github.com/BitySA/whetcwithdraw/tree/master/daobalance
    bool public sealed;
    // The compiler will warn that this constant does not match the address checksum
    uint256 constant D160 = 0x010000000000000000000000000000000000000000;
    // The 160 LSB is the address of the balance
    // The 96 MSB is the balance of that address.
    function fill(uint256[] data) onlyOwner {
        if (sealed) throw;
        for (uint256 i = 0; i < data.length; i++) {
            address account = address(data[i] & (D160-1));
            uint256 amount = data[i] / D160;
            // Prevent duplicates
            if (balances[account] == 0) {
                balances[account] = amount;
                totalSupply += amount;
                Transfer(0x0, account, amount);
            }
        }
    }

    // ------------------------------------------------------------------------
    // After sealing, no more filling is possible
    // ------------------------------------------------------------------------
    function seal() onlyOwner {
        if (sealed) throw;
        sealed = true;
    }
}