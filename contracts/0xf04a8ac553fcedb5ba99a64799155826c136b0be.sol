/*
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  uint public totalSupply; // Number of tokens in circulation
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);

  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);

  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}


/**
 * Math operations with safety checks
 * Reference: https://github.com/OpenZeppelin/zeppelin-solidity/commit/353285e5d96477b4abb86f7cde9187e84ed251ac
 */
contract SafeMath {
  function safeMul(uint a, uint b) internal constant returns (uint) {
    uint c = a * b;

    assert(a == 0 || c / a == b);

    return c;
  }

  function safeDiv(uint a, uint b) internal constant returns (uint) {    
    uint c = a / b;

    return c;
  }

  function safeSub(uint a, uint b) internal constant returns (uint) {
    require(b <= a);

    return a - b;
  }

  function safeAdd(uint a, uint b) internal constant returns (uint) {
    uint c = a + b;

    assert(c>=a && c>=b);

    return c;
  }
}


/*
 * Standard ERC20 token
 *
 * https://github.com/ethereum/EIPs/issues/20
 */
contract Token is ERC20, SafeMath {

  mapping(address => uint) balances;
  mapping (address => mapping (address => uint)) allowed;

  function transfer(address _to, uint _value) returns (bool success) {

    return doTransfer(msg.sender, _to, _value);
  }

  function transferFrom(address _from, address _to, uint _value) returns (bool success) {
    var _allowance = allowed[_from][msg.sender];

    allowed[_from][msg.sender] = safeSub(_allowance, _value);

    return doTransfer(_from, _to, _value);
  }

  /// @notice You must set the allowance to zero before changing to a non-zero value
  function approve(address _spender, uint _value) public returns (bool success) {
    require(allowed[msg.sender][_spender] == 0 || _value == 0);

    allowed[msg.sender][_spender] = _value;

    Approval(msg.sender, _spender, _value);

    return true;
  }

  function doTransfer(address _from, address _to, uint _value) private returns (bool success) {
    balances[_from] = safeSub(balances[_from], _value);
    balances[_to] = safeAdd(balances[_to], _value);

    Transfer(_from, _to, _value);

    return true;
  }

  function balanceOf(address _owner) public constant returns (uint balance) {
    return balances[_owner];
  }

  function allowance(address _owner, address _spender) public constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }
}

contract MintInterface {
  function mint(address recipient, uint amount) returns (bool success);
}


/*
 * Manages the ownership of a contract
 */
contract Owned {
    address public owner; // owner of the contract. By default, the creator of the contract

    modifier onlyOwner() {
      require(msg.sender == owner);

        _;
    }

    function Owned() {
        owner = msg.sender;
    }

    // Changes the owner of the contract to "newOwner"
    // Only executed by "owner"
    // If you want to completely remove the ownership of a contract, just change it to "0x0"
    function changeOwner(address newOwner) public onlyOwner {
      owner = newOwner;
    }
}

/*
 * Manage the minters of a token
 */
contract Minted is MintInterface, Owned {
  uint public numMinters; // Number of minters of the token.
  bool public open; // If is possible to add new minters or not. True by default.
  mapping (address => bool) public minters; // if an address is a minter of the token or not

  // Log of the minters added
  event NewMinter(address who);

  modifier onlyMinters() {
    require(minters[msg.sender]);

    _;
  }

  modifier onlyIfOpen() {
    require(open);

    _;
  }

  function Minted() {
    open = true;
  }

  // Adds a new minter to the token
  // _minter: address of the new minter
  // Only executed by "Owner" (see "Owned" contract)
  // Only executed if the function "endMinting" has not been executed
  function addMinter(address _minter) public onlyOwner onlyIfOpen {
    if(!minters[_minter]) {
      minters[_minter] = true;
      numMinters++;

      NewMinter(_minter);
    }
  }

  // Removes a minter of the token
  // _minter: address of the minter to be removed
  // Only executed by "Owner" (see "Owned" contract)
  function removeMinter(address _minter) public onlyOwner {
    if(minters[_minter]) {
      minters[_minter] = false;
      numMinters--;
    }
  }

  // Blocks the possibility to add new minters
  // This function is irreversible
  // Only executed by "Owner" (see "Owned" contract)
  function endMinting() public onlyOwner {
    open = false;
  }
}

/*
 * Allows an address to set a block from when a token won't be tradeable
 */
contract Pausable is Owned {
  // block from when the token won't be tradeable
  // Default to 0 = no restriction
  uint public endBlock;

  modifier validUntil() {
    require(block.number <= endBlock || endBlock == 0);

    _;
  }

  // Set a block from when a token won't be tradeable
  // There is no limit in the number of executions to avoid irreversible mistakes.
  // Only executed by "Owner" (see "Owned" contract)
  function setEndBlock(uint block) public onlyOwner {
    endBlock = block;
  }
}


/*
 * Token contract
 */
contract ProjectToken is Token, Minted, Pausable {
  string public name; // name of the token
  string public symbol; // acronim of the token
  uint public decimals; // number of decimals of the token

  uint public transferableBlock; // block from which the token can de transfered

  modifier lockUpPeriod() {
    require(block.number >= transferableBlock);

    _;
  }

  function ProjectToken(
    string _name,
    string _symbol,
    uint _decimals,
    uint _transferableBlock
  ) {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    transferableBlock = _transferableBlock;
  }

  // Creates "amount" tokens and send them to "recipient" address
  // Only executed by authorized minters (see "Minted" contract)
  function mint(address recipient, uint amount)
    public
    onlyMinters
    returns (bool success)
  {
    totalSupply = safeAdd(totalSupply, amount);
    balances[recipient] = safeAdd(balances[recipient], amount);

    Transfer(0x0, recipient, amount);

    return true;
  }

  // Aproves "_spender" to spend "_value" tokens and executes its "receiveApproval" function
  function approveAndCall(address _spender, uint256 _value)
    public
    returns (bool success)
  {
    if(super.approve(_spender, _value)){
      if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address)"))), msg.sender, _value, this))
        revert();

      return true;
    }
  }

  // Transfers "value" tokens to "to" address
  // Only executed adter "transferableBlock"
  // Only executed before "endBlock" (see "Expiration" contract)
  // Only executed if there are enough funds and don't overflow
  function transfer(address to, uint value)
    public
    lockUpPeriod
    validUntil
    returns (bool success)
  {
    if(super.transfer(to, value))
      return true;

    return false;
  }

  // Transfers "value" tokens to "to" address from "from"
  // Only executed adter "transferableBlock"
  // Only executed before "endBlock" (see "Expiration" contract)
  // Only executed if there are enough funds available and approved, and don't overflow
  function transferFrom(address from, address to, uint value)
    public
    lockUpPeriod
    validUntil
    returns (bool success)
  {
    if(super.transferFrom(from, to, value))
      return true;

    return false;
  }

  function refundTokens(address _token, address _refund, uint _value) onlyOwner {

    Token(_token).transfer(_refund, _value);
  }

}