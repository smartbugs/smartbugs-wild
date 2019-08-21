pragma solidity ^0.4.6;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Owned {

    // The address of the account that is the current owner
    address public owner;

    // The publiser is the inital owner
    function Owned() {
        owner = msg.sender;
    }

    /**
     * Restricted access to the current owner
     */
    modifier onlyOwner() {
        if (msg.sender != owner) throw;
        _;
    }

    /**
     * Transfer ownership to `_newOwner`
     *
     * @param _newOwner The address of the account that will become the new owner
     */
    function transferOwnership(address _newOwner) onlyOwner {
        owner = _newOwner;
    }
}

// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20
contract Token {
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/**
 * @title CryptoCopy token
 *
 * Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20 with the addition
 * of ownership, a lock and issuing.
 *
 */
contract CryptoCopyToken is Owned, Token {

    using SafeMath for uint256;

    // Ethereum token standaard
    string public standard = "Token 0.2";

    // Full name
    string public name = "CryptoCopy token";

    // Symbol
    string public symbol = "CCOPY";

    // No decimal points
    uint8 public decimals = 8;
    
    // No decimal points
    uint256 public maxTotalSupply = 1000000 * 10 ** 8; // 1 million

    // Token starts if the locked state restricting transfers
    bool public locked;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    /**
     * Get balance of `_owner`
     *
     * @param _owner The address from which the balance will be retrieved
     * @return The balance
     */
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    /**
     * Send `_value` token to `_to` from `msg.sender`
     *
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transfer(address _to, uint256 _value) returns (bool success) {

        // Unable to transfer while still locked
        if (locked) {
            throw;
        }

        // Check if the sender has enough tokens
        if (balances[msg.sender] < _value) {
            throw;
        }

        // Check for overflows
        if (balances[_to] + _value < balances[_to])  {
            throw;
        }

        // Transfer tokens
        balances[msg.sender] -= _value;
        balances[_to] += _value;

        // Notify listners
        Transfer(msg.sender, _to, _value);

        return true;
    }

    /**
     * Send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {

         // Unable to transfer while still locked
        if (locked) {
            throw;
        }

        // Check if the sender has enough
        if (balances[_from] < _value) {
            throw;
        }

        // Check for overflows
        if (balances[_to] + _value < balances[_to]) {
            throw;
        }

        // Check allowance
        if (_value > allowed[_from][msg.sender]) {
            throw;
        }

        // Transfer tokens
        balances[_to] += _value;
        balances[_from] -= _value;

        // Update allowance
        allowed[_from][msg.sender] -= _value;

        // Notify listners
        Transfer(_from, _to, _value);
        
        return true;
    }

    /**
     * `msg.sender` approves `_spender` to spend `_value` tokens
     *
     * @param _spender The address of the account able to transfer the tokens
     * @param _value The amount of tokens to be approved for transfer
     * @return Whether the approval was successful or not
     */
    function approve(address _spender, uint256 _value) returns (bool success) {

        // Unable to approve while still locked
        if (locked) {
            throw;
        }

        // Update allowance
        allowed[msg.sender][_spender] = _value;

        // Notify listners
        Approval(msg.sender, _spender, _value);
        return true;
    }


    /**
     * Get the amount of remaining tokens that `_spender` is allowed to spend from `_owner`
     *
     * @param _owner The address of the account owning tokens
     * @param _spender The address of the account able to transfer the tokens
     * @return Amount of remaining tokens allowed to spent
     */
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    /**
     * Starts with a total supply of zero and the creator starts with
     * zero tokens (just like everyone else)
     */
    function CryptoCopyToken() {
        balances[msg.sender] = 0;
        totalSupply = 0;
        locked = false;
    }

    /**
     * Unlocks the token irreversibly so that the transfering of value is enabled
     *
     * @return Whether the unlocking was successful or not
     */
    function unlock() onlyOwner returns (bool success)  {
        locked = false;
        return true;
    }

    /**
     * Locks the token irreversibly so that the transfering of value is not enabled
     *
     * @return Whether the locking was successful or not
     */
    function lock() onlyOwner returns (bool success)  {
        locked = true;
        return true;
    }
    
    /**
     * Restricted access to the current owner
     */
    modifier onlyOwner() {
        if (msg.sender != owner) throw;
        _;
    }
    
    /**
     * Set max total supply
     *
     * @param _maxTotalSupply maximum total amount of tokens
     */
    function setMaxTotalSupply(uint256 _maxTotalSupply) {
        maxTotalSupply = _maxTotalSupply;
    }

    /**
     * Issues `_value` new tokens to `_recipient`
     *
     * @param _recipient The address to which the tokens will be issued
     * @param _value The amount of new tokens to issue
     * @return Whether the approval was successful or not
     */
    function issue(address _recipient, uint256 _value) onlyOwner returns (bool success) {

        if (totalSupply + _value > maxTotalSupply) {
            return;
        }
        
        // Create tokens
        balances[_recipient] += _value;
        totalSupply += _value;

        return true;
    }

    event Burn(address indexed burner, uint indexed value);

    /**
     * Prevents accidental sending of ether
     */
    function () {
        throw;
    }
}