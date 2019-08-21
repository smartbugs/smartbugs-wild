/**
 * Overflow aware uint math functions.
 *
 * Inspired by https://github.com/MakerDAO/maker-otc/blob/master/contracts/simple_market.sol
 */
contract SafeMath {
  //internals
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function assert(bool assertion) internal {
    if (!assertion) throw;
  }
}

/**
 * ERC 20 token
 *
 * https://github.com/ethereum/EIPs/issues/20
 */
contract Token {

    /// @return total amount of tokens
    function totalSupply() constant returns (uint256 supply) {}

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance) {}

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success) {}

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success) {}

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

/**
 * ERC 20 token
 *
 * https://github.com/ethereum/EIPs/issues/20
 */
contract StandardToken is Token {

    /**
     * Reviewed:
     * - Interger overflow = OK, checked
     */
    function transfer(address _to, uint256 _value) returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        //if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping(address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

    uint256 public totalSupply;
}

contract NapoleonXToken is StandardToken, SafeMath {
    // Constant token specific fields
    string public constant name = "NapoleonX Token";
    string public constant symbol = "NPX";
    // no decimals allowed
    uint8 public decimals = 2;
    uint public INITIAL_SUPPLY = 95000000;
    
    /* this napoleonXAdministrator address is where token.napoleonx.eth resolves to */
    address napoleonXAdministrator;
    
    /* ICO end time in seconds 14 mars 2018 */
    uint public endTime;
    
    event TokenAllocated(address investor, uint tokenAmount);
    // MODIFIERS
    modifier only_napoleonXAdministrator {
        require(msg.sender == napoleonXAdministrator);
        _;
    }

    modifier is_not_earlier_than(uint x) {
        require(now >= x);
        _;
    }
    modifier is_earlier_than(uint x) {
        require(now < x);
        _;
    }
    function isEqualLength(address[] x, uint[] y) internal returns (bool) { return x.length == y.length; }
    modifier onlySameLengthArray(address[] x, uint[] y) {
        require(isEqualLength(x,y));
        _;
    }
	
    function NapoleonXToken(uint setEndTime) {
        napoleonXAdministrator = msg.sender;
        endTime = setEndTime;
    }
	
    // we here repopulate the greenlist using the historic commitments from www.napoleonx.ai website
    function populateWhitelisted(address[] whitelisted, uint[] tokenAmount) only_napoleonXAdministrator onlySameLengthArray(whitelisted, tokenAmount) is_earlier_than(endTime) {
        for (uint i = 0; i < whitelisted.length; i++) {
			uint previousAmount = balances[whitelisted[i]];
			balances[whitelisted[i]] = tokenAmount[i];
			totalSupply = totalSupply-previousAmount+tokenAmount[i];
            TokenAllocated(whitelisted[i], tokenAmount[i]);
        }
    }
    
    function changeFounder(address newAdministrator) only_napoleonXAdministrator {
        napoleonXAdministrator = newAdministrator;
    }
 
    function getICOStage() public constant returns(string) {
         if (now < endTime){
            return "Presale ended, standard ICO running";
         }
         if (now >= endTime){
            return "ICO finished";
         }
    }
}