pragma solidity ^0.4.10;

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

contract StandardToken is Token {
    function transfer(address _to, uint256 _value) returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
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

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract HumanStandardToken is StandardToken {

    function () {
        throw;
    }

    string public name;
    uint8 public decimals;
    string public symbol;
    string public version = 'H0.1';

    function HumanStandardToken(
        uint256 _initialAmount,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol
        ) {
        balances[msg.sender] = _initialAmount;
        totalSupply = _initialAmount;
        name = _tokenName;
        decimals = _decimalUnits;
        symbol = _tokenSymbol;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}

contract Owned {
  address owner;

  bool frozen = false;

  function Owned() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  modifier publicMethod() {
    require(!frozen);
    _;
  }

  function drain() onlyOwner {
    owner.transfer(this.balance);
  }

  function freeze() onlyOwner {
    frozen = true;
  }

  function unfreeze() onlyOwner {
    frozen = false;
  }

  function destroy() onlyOwner {
    selfdestruct(owner);
  }
}

contract Pixel is Owned, HumanStandardToken {
  uint32 public size = 1000;
  uint32 public size2 = size*size;

  mapping (uint32 => uint24) public pixels;
  mapping (uint32 => address) public owners;

  event Set(address indexed _from, uint32[] _xys, uint24[] _rgbs);
  event Unset(address indexed _from, uint32[] _xys);

  // Constructor.
  function Pixel() HumanStandardToken(size2, "Pixel", 0, "PXL") {
  }

  // Public interface.
  function set(uint32[] _xys, uint24[] _rgbs) publicMethod() {
    address _from = msg.sender;

    require(_xys.length == _rgbs.length);
    require(balances[_from] >= _xys.length);

    uint32 _xy; uint24 _rgb;
    for (uint i = 0; i < _xys.length; i++) {
      _xy = _xys[i];
      _rgb = _rgbs[i];

      require(_xy < size2);
      require(owners[_xy] == 0);

      owners[_xy] = _from;
      pixels[_xy] = _rgb;
    }

    balances[_from] -= _xys.length;

    Set(_from, _xys, _rgbs);
  }

  function unset(uint32[] _xys) publicMethod() {
    address _from = msg.sender;

    uint32 _xy;
    for (uint i = 0; i < _xys.length; i++) {
      _xy = _xys[i];

      require(owners[_xy] == _from);

      balances[_from] += 1;
      owners[_xy] = 0;
      pixels[_xy] = 0;
    }

    Unset(_from, _xys);
  }

  // Constants.
  function row(uint32 _y) constant returns (uint24[1000], address[1000]) {
    uint32 _start = _y * size;

    uint24[1000] memory rgbs;
    address[1000] memory addrs;

    for (uint32 i = 0; i < 1000; i++) {
      rgbs[i] = pixels[_start + i];
      addrs[i] = owners[_start + i];
    }

    return (rgbs, addrs);
  }
}