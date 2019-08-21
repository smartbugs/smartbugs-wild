pragma solidity ^0.4.11;

 /* Receiver must implement this function to receive tokens
 *  otherwise token transaction will fail
 */
 
 contract ContractReceiver {
    function tokenFallback(address _from, uint256 _value, bytes _data){
      _from = _from;
      _value = _value;
      _data = _data;
      // Incoming transaction code here
    }
}
 
 /* New ERC23 contract interface */

contract ERC23 {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function allowance(address owner, address spender) constant returns (uint256);

  function name() constant returns (string _name);
  function symbol() constant returns (string _symbol);
  function decimals() constant returns (uint8 _decimals);
  function totalSupply() constant returns (uint256 _supply);

  function transfer(address to, uint256 value) returns (bool ok);
  function transfer(address to, uint256 value, bytes data) returns (bool ok);
  function transferFrom(address from, address to, uint256 value) returns (bool ok);
  function approve(address spender, uint256 value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value, bytes data);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


 /**
 * ERC23 token by Dexaran
 *
 * https://github.com/Dexaran/ERC23-tokens
 */
 
contract ERC23Token is ERC23 {

  mapping(address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;

  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;

  // Function to access name of token .
  function name() constant returns (string _name) {
      return name;
  }
  // Function to access symbol of token .
  function symbol() constant returns (string _symbol) {
      return symbol;
  }
  // Function to access decimals of token .
  function decimals() constant returns (uint8 _decimals) {
      return decimals;
  }
  // Function to access total supply of tokens .
  function totalSupply() constant returns (uint256 _totalSupply) {
      return totalSupply;
  }

  //function that is called when a user or another contract wants to transfer funds
  function transfer(address _to, uint256 _value, bytes _data) returns (bool success) {
  
    //filtering if the target is a contract with bytecode inside it
    if(isContract(_to)) {
        transferToContract(_to, _value, _data);
    }
    else {
        transferToAddress(_to, _value, _data);
    }
    return true;
  }
  
  function transfer(address _to, uint256 _value) returns (bool success) {
      
    //standard function transfer similar to ERC20 transfer with no _data
    //added due to backwards compatibility reasons
    bytes memory empty;
    if(isContract(_to)) {
        transferToContract(_to, _value, empty);
    }
    else {
        transferToAddress(_to, _value, empty);
    }
    return true;
  }

  //function that is called when transaction target is an address
  function transferToAddress(address _to, uint256 _value, bytes _data) private returns (bool success) {
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    Transfer(msg.sender, _to, _value);
    Transfer(msg.sender, _to, _value, _data);
    return true;
  }
  
  //function that is called when transaction target is a contract
  function transferToContract(address _to, uint256 _value, bytes _data) private returns (bool success) {
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    ContractReceiver reciever = ContractReceiver(_to);
    reciever.tokenFallback(msg.sender, _value, _data);
    Transfer(msg.sender, _to, _value);
    Transfer(msg.sender, _to, _value, _data);
    return true;
  }
  
  //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
  function isContract(address _addr) private returns (bool is_contract) {
      _addr = _addr;
      uint256 length;
      assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
        }
        if(length>0) {
            return true;
        }
        else {
            return false;
        }
    }

  function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
    var _allowance = allowed[_from][msg.sender];
    
    if(_value > _allowance) {
        throw;
    }

    balances[_to] += _value;
    balances[_from] -= _value;
    allowed[_from][msg.sender] -= _value;
    Transfer(_from, _to, _value);
    return true;
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
}


// ERC223 token with the ability for the owner to block any account
contract DASToken is ERC23Token {
    mapping (address => bool) blockedAccounts;
    address public secretaryGeneral;


    // Constructor
    function DASToken(
            string _name,
            string _symbol,
            uint8 _decimals,
            uint256 _totalSupply,
            address _initialTokensHolder) {
        secretaryGeneral = msg.sender;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balances[_initialTokensHolder] = _totalSupply;
    }


    modifier onlySecretaryGeneral {
        if (msg.sender != secretaryGeneral) throw;
        _;
    }


    // block account
    function blockAccount(address _account) onlySecretaryGeneral {
        blockedAccounts[_account] = true;
    }

    // unblock account
    function unblockAccount(address _account) onlySecretaryGeneral {
        blockedAccounts[_account] = false;
    }

    // check is account blocked
    function isAccountBlocked(address _account) returns (bool){
        return blockedAccounts[_account];
    }

    // override transfer methods to throw on blocked accounts
    function transfer(address _to, uint256 _value, bytes _data) returns (bool success) {
        if (blockedAccounts[msg.sender]) {
            throw;
        }
        return ERC23Token.transfer(_to, _value, _data);
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        if (blockedAccounts[msg.sender]) {
            throw;
        }
        bytes memory empty;
        return ERC23Token.transfer(_to, _value, empty);
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (blockedAccounts[_from]) {
            throw;
        }
        return ERC23Token.transferFrom(_from, _to, _value);
    }
}