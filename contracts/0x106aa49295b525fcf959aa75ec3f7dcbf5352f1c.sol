pragma solidity ^0.4.18;

contract Token {
    /* This is a slight change to the ERC20 base standard.
    function totalSupply() constant returns (uint256 supply);
    is replaced with:
    uint256 public totalSupply;
    This automatically creates a getter function for the totalSupply.
    This is moved to the base contract since public getter functions are not
    currently recognised as an implementation of the matching abstract
    function by the compiler.
    */
    /// total amount of tokens
    uint256 public totalSupply;

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) public view returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is Token {

    uint256 constant MAX_UINT256 = 2**256 - 1;
    bool transferEnabled = false;

    function transfer(address _to, uint256 _value) public returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(balances[msg.sender] >= _value);
        require(transferEnabled);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        require(transferEnabled);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) view public returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) view public returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract RockToken is StandardToken {

    using SafeMath for uint;

    // UM
    uint256 public million = 1000000;
    uint8 public constant decimals = 18;
    string public constant symbol = "RKT";
    string public constant name = "Rock Token";
    bool public canConvertTokens;

    // Inited in constructor
    address public contractOwner; // Can stop the allocation of delayed tokens and can allocate delayed tokens.
    address public futureOwner;
    address public masterContractAddress; // The ICO contract to issue tokens.

    // Constructor
    // Sets the contractOwner for the onlyOwner modifier
    // Sets the public values in the ERC20 standard token
    // Opens the delayed allocation window.
    // can pre-allocate balances for an array of _accounts
    function RockToken(address _masterContractAddress, address[] _accounts, uint[] _balances) public {
        contractOwner = msg.sender;
        masterContractAddress = _masterContractAddress;

        totalSupply = 0;
        canConvertTokens = true;

        uint length = _accounts.length;
        require(length == _balances.length);
        for (uint i = 0; i < length; i++) {
            balances[_accounts[i]] = _balances[i];
            // Fire Transfer event for ERC-20 compliance. Adjust totalSupply.
            Transfer(address(0), _accounts[i], _balances[i]);
            totalSupply = totalSupply.add(_balances[i]);
        }
    }

    // Can only be called by the master contract during the TokenSale to issue tokens.
    function convertTokens(uint256 _amount, address _tokenReceiver) onlyMasterContract public {
        require(canConvertTokens);
        balances[_tokenReceiver] = balances[_tokenReceiver].add(_amount);
    }

    // Fire Transfer event for ERC-20 compliance. Adjust totalSupply. Can only be called by the Master Contract.
    function reportConvertTokens(uint256 _amount, address _address) onlyMasterContract public {
        require(canConvertTokens);
        Transfer(address(0), _address, _amount);
        totalSupply = totalSupply.add(_amount);
    }

    function stopConvertTokens() onlyOwner public {
        canConvertTokens = false;
    }

    // Called by the token owner to block or unblock transfers
    function enableTransfers() onlyOwner public {
        transferEnabled = true;
    }

    modifier onlyOwner() {
        require(msg.sender == contractOwner);
        _;
    }

    modifier onlyMasterContract() {
        require(msg.sender == masterContractAddress);
        _;
    }

    // Makes sure that the ownership is only changed by the owner
    function transferOwnership(address _newOwner) public onlyOwner {
    // Makes sure that the contract will have an owner
        require(_newOwner != address(0));
        futureOwner = _newOwner;
    }

    function claimOwnership() public {
        require(msg.sender == futureOwner);
        contractOwner = msg.sender;
        futureOwner = address(0);
    }

}