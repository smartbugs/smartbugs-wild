pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ConoToken  {

    using SafeMath for uint256;
    
    uint256 public _totalSupply;
    
    uint256 public constant AMOUNT = 1000000000;    // initial amount of token
    
    string public constant symbol = "CONO";
    string public constant name = "Cono Coins";
    uint8 public constant decimals = 18; 
    string public version = '1.0';  

    
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    
    address _contractCreator;
    
    function ConoToken(address owner) public {
        _contractCreator = owner;
        _totalSupply = AMOUNT * 1000000000000000000;
        balances[_contractCreator] = _totalSupply;
    }
     

    /// @return total amount of tokens
    function totalSupply() constant public returns (uint256) {
        return _totalSupply;
    }

    /// @param who The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address who) constant public returns (uint256){
        return balances[who];
    }

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success) {
        
        require(_to != 0x00);
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        require(balances[msg.sender] >= _value && _value > 0 );
        require(balances[_to] + _value >= balances[_to]); // Check for overflows

        if (balances[msg.sender] >= _value && _value > 0) {
            //balances[msg.sender] -= _value;
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);  // Log the Transaction
            return true;
        } else { return false; }
    }
        

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
         //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        require(
            allowed[_from][msg.sender] >= _value && balances[_from] >= _value && _value > 0
        );
        require(balances[_to] + _value >= balances[_to]); // Check for overflows
        
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;

            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value); // Log the Transaction
        return true;
    }

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
 
}