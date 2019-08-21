pragma solidity ^0.4.24;


contract ERC223 {
  uint public totalSupply;
  function balanceOf(address who) public view returns (uint);
  
  function name() public view returns (string _name);
  function symbol() public view returns (string _symbol);
  function decimals() public view returns (uint256 _decimals);
  function totalSupply() public view returns (uint256 _supply);

  function transfer(address to, uint value) public returns (bool ok);
  function transfer(address to, uint value, bytes data) public returns (bool ok);
  function transfer(address to, uint value, bytes data, string custom_fallback) public returns (bool ok);
  
  event Transfer(address indexed from, address indexed to, uint value, bytes data);
}


library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}


contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}



contract ContractReceiver {
     
  struct TKN {
    address sender;
    uint value;
    bytes data;
    bytes4 sig;
  }
  
  
  function tokenFallback(address _from, uint _value, bytes _data) public {
    TKN memory tkn;
    tkn.sender = _from;
    tkn.value = _value;
    tkn.data = _data;
    uint32 u = uint32(_data[3]) + (uint32(_data[2]) << 8) + (uint32(_data[1]) << 16) + (uint32(_data[0]) << 24);
    tkn.sig = bytes4(u);
    
    /* tkn variable is analogue of msg variable of Ether transaction
    *  tkn.sender is person who initiated this token transaction   (analogue of msg.sender)
    *  tkn.value the number of tokens that were sent   (analogue of msg.value)
    *  tkn.data is data of token transaction   (analogue of msg.data)
    *  tkn.sig is 4 bytes signature of function
    *  if data of token transaction is a function execution
    */
  }
}


contract ERC223Token is ERC223 {
  using SafeMath for uint;

  mapping(address => uint) balances;
  
  string public name;
  string public symbol;
  uint256 public decimals;
  uint256 public totalSupply;

  modifier validDestination( address to ) {
    require(to != address(0x0));
    _;
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
  function decimals() public view returns (uint256 _decimals) {
    return decimals;
  }
  // Function to access total supply of tokens .
  function totalSupply() public view returns (uint256 _totalSupply) {
    return totalSupply;
  }
  
  
  // Function that is called when a user or another contract wants to transfer funds .
  function transfer(address _to, uint _value, bytes _data, string _custom_fallback) validDestination(_to) public returns (bool success) {
      
    if(isContract(_to)) {
      if (balanceOf(msg.sender) < _value) revert();
      balances[msg.sender] = balanceOf(msg.sender).sub(_value);
      balances[_to] = balanceOf(_to).add(_value);
      assert(_to.call.value(0)(bytes4(keccak256(_custom_fallback)), msg.sender, _value, _data));
      emit Transfer(msg.sender, _to, _value, _data);
      return true;
    }
    else {
      return transferToAddress(_to, _value, _data);
    }
}
  

  // Function that is called when a user or another contract wants to transfer funds .
  function transfer(address _to, uint _value, bytes _data) validDestination(_to) public returns (bool success) {
      
    if(isContract(_to)) {
      return transferToContract(_to, _value, _data);
    }
    else {
      return transferToAddress(_to, _value, _data);
    }
  }
  
  // Standard function transfer similar to ERC20 transfer with no _data .
  // Added due to backwards compatibility reasons .
  function transfer(address _to, uint _value) validDestination(_to) public returns (bool success) {
      
    //standard function transfer similar to ERC20 transfer with no _data
    //added due to backwards compatibility reasons
    bytes memory empty;
    if(isContract(_to)) {
      return transferToContract(_to, _value, empty);
    }
    else {
        return transferToAddress(_to, _value, empty);
    }
  }

  //assemble the given address bytecode. If bytecode exists then the _addr is a contract.
  function isContract(address _addr) private view returns (bool is_contract) {
    uint length;
    assembly {
      //retrieve the size of the code on target address, this needs assembly
      length := extcodesize(_addr)
    }
    return (length>0);
  }

  //function that is called when transaction target is an address
  function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
    if (balanceOf(msg.sender) < _value) revert();
    balances[msg.sender] = balanceOf(msg.sender).sub(_value);
    balances[_to] = balanceOf(_to).add(_value);
    emit Transfer(msg.sender, _to, _value, _data);
    return true;
  }
  
  //function that is called when transaction target is a contract
  function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
    if (balanceOf(msg.sender) < _value) revert();
    balances[msg.sender] = balanceOf(msg.sender).sub(_value);
    balances[_to] = balanceOf(_to).add(_value);
    ContractReceiver receiver = ContractReceiver(_to);
    receiver.tokenFallback(msg.sender, _value, _data);
    emit Transfer(msg.sender, _to, _value, _data);
    return true;
}


  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }
}


contract ReleasableToken is ERC223Token, Ownable {

  /* The finalizer contract that allows unlift the transfer limits on this token */
  address public releaseAgent;

  /** A crowdsale contract can release us to the wild if ICO success. If false we are are in transfer lock up period.*/
  bool public released = false;

  /** Map of agents that are allowed to transfer tokens regardless of the lock down period. These are crowdsale contracts and possible the team multisig itself. */
  mapping (address => bool) public transferAgents;

  /**
  * Limit token transfer until the crowdsale is over.
  *
  */
  modifier canTransfer(address _sender) {

    if(!released) {
      require(transferAgents[_sender]);
    }

    _;
  }

  /**
  * Set the contract that can call release and make the token transferable.
  *
  * Design choice. Allow reset the release agent to fix fat finger mistakes.
  */
  function setReleaseAgent(address addr) onlyOwner inReleaseState(false) public {

    // We don't do interface check here as we might want to a normal wallet address to act as a release agent
    releaseAgent = addr;
  }

  /**
  * Owner can allow a particular address (a crowdsale contract) to transfer tokens despite the lock up period.
  */
  function setTransferAgent(address addr, bool state) onlyOwner inReleaseState(false) public {
    transferAgents[addr] = state;
  }

  /**
  * One way function to release the tokens to the wild.
  *
  * Can be called only from the release agent that is the final ICO contract. It is only called if the crowdsale has been success (first milestone reached).
  */
  function releaseTokenTransfer() public onlyReleaseAgent {
    released = true;
  }

  /** The function can be called only before or after the tokens have been releasesd */
  modifier inReleaseState(bool releaseState) {
    require(releaseState == released);
    _;
  }

  /** The function can be called only by a whitelisted release agent. */
  modifier onlyReleaseAgent() {
    require(msg.sender == releaseAgent);
    _;
  }

  function transfer(address _to, uint _value) public canTransfer(msg.sender) returns (bool success) {
    // Call StandardToken.transfer()
    return super.transfer(_to, _value);
  }

  function transfer(address _to, uint _value, bytes _data) public canTransfer(msg.sender) returns (bool success) {
    // Call StandardToken.transfer()
    return super.transfer(_to, _value, _data);
  }

  function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public canTransfer(msg.sender) returns (bool success) {
    return super.transfer(_to, _value, _data, _custom_fallback);
  }
}


contract AMLToken is ReleasableToken {

  // An event when the owner has reclaimed non-released tokens
  event OwnerReclaim(address fromWhom, uint amount);

  constructor(string _name, string _symbol, uint _initialSupply, uint _decimals) public {
    owner = msg.sender;
    name = _name;
    symbol = _symbol;
    totalSupply = _initialSupply;
    decimals = _decimals;

    balances[owner] = totalSupply;
  }

  /// @dev Here the owner can reclaim the tokens from a participant if
  ///      the token is not released yet. Refund will be handled offband.
  /// @param fromWhom address of the participant whose tokens we want to claim
  function transferToOwner(address fromWhom) public onlyOwner {
    if (released) revert();

    uint amount = balanceOf(fromWhom);
    balances[fromWhom] = balances[fromWhom].sub(amount);
    balances[owner] = balances[owner].add(amount);
    bytes memory empty;
    emit Transfer(fromWhom, owner, amount, empty);
    emit OwnerReclaim(fromWhom, amount);
  }
}


contract MediarToken is AMLToken {

  uint256 public constant INITIAL_SUPPLY = 420000000 * (10 ** uint256(18));

  /**
    * @dev Constructor that gives msg.sender all of existing tokens.
    */
  constructor() public 
    AMLToken("Mediar", "MDR", INITIAL_SUPPLY, 18) {
  }
}