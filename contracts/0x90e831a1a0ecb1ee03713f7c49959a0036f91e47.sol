pragma solidity ^0.4.24;


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


contract XNR is StandardToken {
  
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
    address bountyMgrAddress = address(0x03De5f75915DC5382C5dF82538F8D5e124A7ebB8);
    
    initialBalance = 18666666667 * 1e8;
    uint256 bountyMgrBalance = 933333333 * 1e8;
    totalSupply = initialBalance;

    balances[msg.sender] = safeSub(initialBalance, bountyMgrBalance);
    balances[bountyMgrAddress] = bountyMgrBalance;

    Transfer(address(0x0), address(msg.sender), balances[msg.sender]);
    Transfer(address(0x0), address(bountyMgrAddress), balances[bountyMgrAddress]);

    name = "Neuroneum";
    symbol = "XNR";
    decimals = 8;
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

  // Standard ERC20 transfer commands, with additional requireThawed modifier
  function transfer(address _to, uint _value) requireThawed returns (bool success) {
    return super.transfer(_to, _value);
  }
  function transferFrom(address _from, address _to, uint _value) requireThawed returns (bool success) {
    return super.transferFrom(_from, _to, _value);
  }

}