pragma solidity ^0.4.11;


/*
  Author: Victor Mezrin  victor@mezrin.com
*/


/* Interface of the ERC223 token */
contract ERC223TokenInterface {
    function name() constant returns (string _name);
    function symbol() constant returns (string _symbol);
    function decimals() constant returns (uint8 _decimals);
    function totalSupply() constant returns (uint256 _supply);

    function balanceOf(address _owner) constant returns (uint256 _balance);

    function approve(address _spender, uint256 _value) returns (bool _success);
    function allowance(address _owner, address spender) constant returns (uint256 _remaining);

    function transfer(address _to, uint256 _value) returns (bool _success);
    function transfer(address _to, uint256 _value, bytes _metadata) returns (bool _success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool _success);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value, bytes metadata);
}


/* Interface of the contract that is going to receive ERC223 tokens */
contract ERC223ContractInterface {
    function erc223Fallback(address _from, uint256 _value, bytes _data){
        // to avoid warnings during compilation
        _from = _from;
        _value = _value;
        _data = _data;
        // Incoming transaction code here
        throw;
    }
}


/* https://github.com/LykkeCity/EthereumApiDotNetCore/blob/master/src/ContractBuilder/contracts/token/SafeMath.sol */
contract SafeMath {
    uint256 constant public MAX_UINT256 =
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    function safeAdd(uint256 x, uint256 y) constant internal returns (uint256 z) {
        if (x > MAX_UINT256 - y) throw;
        return x + y;
    }

    function safeSub(uint256 x, uint256 y) constant internal returns (uint256 z) {
        if (x < y) throw;
        return x - y;
    }

    function safeMul(uint256 x, uint256 y) constant internal returns (uint256 z) {
        if (y == 0) return 0;
        if (x > MAX_UINT256 / y) throw;
        return x * y;
    }
}


contract ERC223Token is ERC223TokenInterface, SafeMath {

    /*
      Storage of the contract
    */

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowances;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;


    /*
      Getters
    */

    function name() constant returns (string _name) {
        return name;
    }

    function symbol() constant returns (string _symbol) {
        return symbol;
    }

    function decimals() constant returns (uint8 _decimals) {
        return decimals;
    }

    function totalSupply() constant returns (uint256 _supply) {
        return totalSupply;
    }

    function balanceOf(address _owner) constant returns (uint256 _balance) {
        return balances[_owner];
    }


    /*
      Allow to spend
    */

    function approve(address _spender, uint256 _value) returns (bool _success) {
        allowances[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 _remaining) {
        return allowances[_owner][_spender];
    }


    /*
      Transfer
    */

    function transfer(address _to, uint256 _value) returns (bool _success) {
        bytes memory emptyMetadata;
        __transfer(msg.sender, _to, _value, emptyMetadata);
        return true;
    }

    function transfer(address _to, uint256 _value, bytes _metadata) returns (bool _success)
    {
        __transfer(msg.sender, _to, _value, _metadata);
        Transfer(msg.sender, _to, _value, _metadata);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool _success) {
        if (allowances[_from][msg.sender] < _value) throw;

        allowances[_from][msg.sender] = safeSub(allowances[_from][msg.sender], _value);
        bytes memory emptyMetadata;
        __transfer(_from, _to, _value, emptyMetadata);
        return true;
    }

    function __transfer(address _from, address _to, uint256 _value, bytes _metadata) internal
    {
        if (_from == _to) throw;
        if (_value == 0) throw;
        if (balanceOf(_from) < _value) throw;

        balances[_from] = safeSub(balanceOf(_from), _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);

        if (isContract(_to)) {
            ERC223ContractInterface receiverContract = ERC223ContractInterface(_to);
            receiverContract.erc223Fallback(_from, _value, _metadata);
        }

        Transfer(_from, _to, _value);
    }


    /*
      Helpers
    */

    // Assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    function isContract(address _addr) internal returns (bool _isContract) {
        _addr = _addr; // to avoid warnings during compilation

        uint256 length;
        assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
        }
        return (length > 0);
    }
}



contract ABCToken is ERC223Token {
    // Constructor
    function ABCToken(
            string _name,
            string _symbol,
            uint8 _decimals,
            uint256 _totalSupply,
            address _initialTokensHolder) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balances[_initialTokensHolder] = _totalSupply;
    }
}