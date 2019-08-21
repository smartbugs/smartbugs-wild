pragma solidity ^0.4.24;

/*
 * Contract that is working with ERC223 tokens
 */
contract ContractReceiver {
  function tokenFallback(address _from, uint256 _value, bytes _data) public;
}

/* New ERC223 contract interface */
contract ERC223 {
  uint public totalSupply;
  function balanceOf(address who) public view returns (uint);

  function name() public view returns (string _name);
  function symbol() public view returns (string _symbol);
  function decimals() public view returns (uint8 _decimals);
  function totalSupply() public view returns (uint256 _supply);

  function transfer(address to, uint value) public returns (bool ok);
  function transfer(address to, uint value, bytes data) public returns (bool ok);
  function transfer(address to, uint value, bytes data, string custom_fallback) public returns (bool ok);

  // solhint-disable-next-line
  event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}

 /**
 * ERC223 token by Dexaran
 *
 * https://github.com/Dexaran/ERC223-token-standard
 */

 /* https://github.com/LykkeCity/EthereumApiDotNetCore/blob/master/src/ContractBuilder/contracts/token/SafeMath.sol */
contract SafeMathERC223 {
  uint256 constant public MAX_UINT256 =
  0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

  function safeAdd(uint256 x, uint256 y) internal pure returns (uint256 z) {
    if (x > MAX_UINT256 - y) revert();
    return x + y;
  }

  function safeSub(uint256 x, uint256 y) internal pure returns (uint256 z) {
    if (x < y) revert();
    return x - y;
  }

  function safeMul(uint256 x, uint256 y) internal pure returns (uint256 z) {
    if (y == 0) return 0;
    if (x > MAX_UINT256 / y) revert();
    return x * y;
  }
}


contract ERC223Token is ERC223, SafeMathERC223 {
  mapping(address => uint) public balances;

  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;

  // Constractor
  constructor(string _name, string _symbol, uint8 _decimals, uint256 _totalSupply) public {
        symbol = _symbol;
        name = _name;
        decimals = _decimals;
        totalSupply = _totalSupply;
        balances[msg.sender] = _totalSupply;
  }

  // Function to access name of token .
  function name() public view returns (string _name) {
    return name;
  }

  // Function to access symbol of token .
  function symbol() public view returns (string _symbol) {
    return symbol;
  }

  // Function to access decimals of token .
  function decimals() public view returns (uint8 _decimals) {
    return decimals;
  }

  // Function to access total supply of tokens .
  function totalSupply() public view returns (uint256 _totalSupply) {
    return totalSupply;
  }

  // Function that is called when a user or another contract wants to transfer funds .
  function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success) {
    if (isContract(_to)) {
      return transferToContractCustom(msg.sender, _to, _value, _data, _custom_fallback);
    } else {
      return transferToAddress(msg.sender, _to, _value, _data);
    }
  }

  // Function that is called when a user or another contract wants to transfer funds .
  function transfer(address _to, uint _value, bytes _data) public returns (bool success) {
    if (isContract(_to)) {
      return transferToContract(msg.sender, _to, _value, _data);
    } else {
      return transferToAddress(msg.sender, _to, _value, _data);
    }
  }

  // Standard function transfer similar to ERC20 transfer with no _data .
  // Added due to backwards compatibility reasons .
  function transfer(address _to, uint _value) public returns (bool success) {
    //standard function transfer similar to ERC20 transfer with no _data
    //added due to backwards compatibility reasons
    bytes memory empty;
    if (isContract(_to)) {
      return transferToContract(msg.sender, _to, _value, empty);
    } else {
      return transferToAddress(msg.sender, _to, _value, empty);
    }
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }

  //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
  function isContract(address _addr) internal view returns (bool is_contract) {
    uint length;
    assembly { // solhint-disable-line
          //retrieve the size of the code on target address, this needs assembly
          length := extcodesize(_addr)
    }
    return (length > 0);
  }

  //function that is called when transaction target is an address
  function transferToAddress(address _from, address _to, uint _value, bytes _data) internal returns (bool success) {
    if (balanceOf(_from) < _value) revert();
    balances[_from] = safeSub(balanceOf(_from), _value);
    balances[_to] = safeAdd(balanceOf(_to), _value);
    emit Transfer(_from, _to, _value, _data);
    return true;
  }

  //function that is called when transaction target is a contract
  function transferToContract(address _from, address _to, uint _value, bytes _data) internal returns (bool success) {
    if (balanceOf(_from) < _value) revert();
    balances[_from] = safeSub(balanceOf(_from), _value);
    balances[_to] = safeAdd(balanceOf(_to), _value);
    ContractReceiver receiver = ContractReceiver(_to);
    receiver.tokenFallback(_from, _value, _data);
    emit Transfer(_from, _to, _value, _data);
    return true;
  }

  //function that is called when transaction target is a contract
  function transferToContractCustom(address _from, address _to, uint _value, bytes _data, string _custom_fallback) internal returns (bool success) {
    if (balanceOf(_from) < _value) revert();
    balances[_from] = safeSub(balanceOf(_from), _value);
    balances[_to] = safeAdd(balanceOf(_to), _value);
    // solhint-disable-next-line
    assert(_to.call.value(0)(abi.encodeWithSignature(_custom_fallback, _from, _value, _data)));
    emit Transfer(_from, _to, _value, _data);
    return true;
  }
}