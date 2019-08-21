pragma solidity ^0.4.24;

// File: zeppelin/token/ERC20.sol

/*
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);

  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

// File: contracts/interface/ERC223.sol

/*
  ERC223 additions to ERC20

  Interface wise is ERC20 + data paramenter to transfer and transferFrom.
 */


contract ERC223 is ERC20 {
  function transfer(address to, uint value, bytes data) returns (bool ok);
  function transferFrom(address from, address to, uint value, bytes data) returns (bool ok);
}

// File: contracts/interface/ERC223Receiver.sol

/*
Base class contracts willing to accept ERC223 token transfers must conform to.

Sender: msg.sender to the token contract, the address originating the token transfer.
          - For user originated transfers sender will be equal to tx.origin
          - For contract originated transfers, tx.origin will be the user that made the tx that produced the transfer.
Origin: the origin address from whose balance the tokens are sent
          - For transfer(), origin = msg.sender
          - For transferFrom() origin = _from to token contract
Value is the amount of tokens sent
Data is arbitrary data sent with the token transfer. Simulates ether tx.data

From, origin and value shouldn't be trusted unless the token contract is trusted.
If sender == tx.origin, it is safe to trust it regardless of the token.
*/

contract ERC223Receiver {
  function tokenFallback(address _sender, address _origin, uint _value, bytes _data) returns (bool ok);
}

// File: zeppelin/SafeMath.sol

/**
 * Math operations with safety checks
 */
contract SafeMath {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
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

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}

// File: zeppelin/token/StandardToken.sol

/**
 * Standard ERC20 token
 *
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, SafeMath {

  mapping(address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;

  function transfer(address _to, uint _value) returns (bool success) {
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) returns (bool success) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because safeSub(_allowance, _value) will already throw if this condition is not met
    // if (_value > _allowance) throw;

    balances[_to] = safeAdd(balances[_to], _value);
    balances[_from] = safeSub(balances[_from], _value);
    allowed[_from][msg.sender] = safeSub(_allowance, _value);
    Transfer(_from, _to, _value);
    return true;
  }

  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

}

// File: contracts/implementation/Standard223Token.sol

/* ERC223 additions to ERC20 */




contract Standard223Token is ERC223, StandardToken {
  //function that is called when a user or another contract wants to transfer funds
  function transfer(address _to, uint _value, bytes _data) returns (bool success) {
    //filtering if the target is a contract with bytecode inside it
    if (!super.transfer(_to, _value)) throw; // do a normal token transfer
    if (isContract(_to)) return contractFallback(msg.sender, _to, _value, _data);
    return true;
  }

  function transferFrom(address _from, address _to, uint _value, bytes _data) returns (bool success) {
    if (!super.transferFrom(_from, _to, _value)) throw; // do a normal token transfer
    if (isContract(_to)) return contractFallback(_from, _to, _value, _data);
    return true;
  }

  function transfer(address _to, uint _value) returns (bool success) {
    return transfer(_to, _value, new bytes(0));
  }

  function transferFrom(address _from, address _to, uint _value) returns (bool success) {
    return transferFrom(_from, _to, _value, new bytes(0));
  }

  //function that is called when transaction target is a contract
  function contractFallback(address _origin, address _to, uint _value, bytes _data) private returns (bool success) {
    ERC223Receiver reciever = ERC223Receiver(_to);
    return reciever.tokenFallback(msg.sender, _origin, _value, _data);
  }

  //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
  function isContract(address _addr) private returns (bool is_contract) {
    // retrieve the size of the code on target address, this needs assembly
    uint length;
    assembly { length := extcodesize(_addr) }
    return length > 0;
  }
}

// File: contracts/XNR.sol

contract XNR is Standard223Token {
  
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  // Requires that before a function executes either:
  // The global isThawed value is set true
  // The sender is in a whitelisted thawedAddress
  // It has been a year since contract deployment
  modifier requireThawed() {
    require(isThawed == true || thawedAddresses[msg.sender] == true || now > thawTime);
    _;
  }

  // Applies to thaw functions. Only the designated manager is allowed when this modifier is present
  modifier onlyManager() {
    require(msg.sender == owner || msg.sender == manager);
    _;
  }

  address owner;
  address manager;
  uint initialBalance;
  string public name;
  string public symbol;
  uint public decimals;
  mapping (uint=>string) public metadata;
  mapping (uint=>string) public publicMetadata;
  bool isThawed = false;
  mapping (address=>bool) public thawedAddresses;
  uint256 thawTime;

  constructor() public {
    address bountyMgrAddress = address(0x03de5f75915dc5382c5df82538f8d5e124a7ebb8);
    initialBalance = 18666666667;
    uint256 bountyMgrBalance = 933333333;
    balances[msg.sender] = safeSub(initialBalance, bountyMgrBalance);
    balances[bountyMgrAddress] = bountyMgrBalance;
    totalSupply = initialBalance;
    name = "Neuroneum";
    symbol = "XNR";
    decimals = 18;
    owner = msg.sender;
    thawedAddresses[msg.sender] = true;
    thawedAddresses[bountyMgrAddress] = true;
    thawTime = now + 1 years;
  }

  // **
  // ** Manager functions **
  // **
  // Thaw a specific address, allowing it to send tokens
  function thawAddress(address _address) onlyManager {
    thawedAddresses[_address] = true;
  }
  // Thaw all addresses. This is irreversible
  function thawAllAddresses() onlyManager {
    isThawed = true;
  }
  // Freeze all addresses except for those whitelisted in thawedAddresses. This is irreversible
  // This only applies if the thawTime has not yet past.
  function freezeAllAddresses() onlyManager {
    isThawed = false;
  }

  // **
  // ** Owner functions **
  // **
  // Set a new owner
  function setOwner(address _newOwner) onlyOwner {
    owner = _newOwner;
  }

  // Set a manager, who can unfreeze wallets as needed
  function setManager(address _address) onlyOwner {
    manager = _address;
  }

  // Change the ticker symbol of the token
  function changeSymbol(string newSymbol) onlyOwner {
    symbol = newSymbol;
  }

  // Change the long-form name of the token
  function changeName(string newName) onlyOwner {
    name = newName;
  }

  // Set any admin level metadata needed for XNR mainnet purposes
  function setMetadata(uint key, string value) onlyOwner {
    metadata[key] = value;
  }

  // **
  // ** Public functions **
  // **
  // Set any public metadata needed for XNR mainnet purposes
  function setPublicMetadata(uint key, string value) {
    publicMetadata[key] = value;
  }

  // Standard ERC20 transfer commands, with additional requireThawed modifier
  function transfer(address _to, uint _value, bytes _data) requireThawed returns (bool success) {
    return super.transfer(_to, _value, _data);
  }
  function transferFrom(address _from, address _to, uint _value, bytes _data) requireThawed returns (bool success) {
    return super.transferFrom(_from, _to, _value, _data);
  }
  function transfer(address _to, uint _value) requireThawed returns (bool success) {
    return super.transfer(_to, _value);
  }
  function transferFrom(address _from, address _to, uint _value) requireThawed returns (bool success) {
    return super.transferFrom(_from, _to, _value);
  }

}