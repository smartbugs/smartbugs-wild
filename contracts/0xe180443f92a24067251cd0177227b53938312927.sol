pragma solidity ^0.4.24;

/**
 * @title ERC223 interface
 * @dev see https://github.com/ethereum/EIPs/issues/223
 */
interface ERC223I {

  function balanceOf(address _owner) external view returns (uint balance);
  
  function name() external view returns (string _name);
  function symbol() external view returns (string _symbol);
  function decimals() external view returns (uint8 _decimals);
  function totalSupply() external view returns (uint256 supply);

  function transfer(address to, uint value) external returns (bool ok);
  function transfer(address to, uint value, bytes data) external returns (bool ok);
  function transfer(address to, uint value, bytes data, string custom_fallback) external returns (bool ok);

  function releaseTokenTransfer() external;
  
  event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);  
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
contract SafeMath {

    /**
    * @dev Subtracts two numbers, reverts on overflow.
    */
    function safeSub(uint256 x, uint256 y) internal pure returns (uint256) {
        assert(y <= x);
        uint256 z = x - y;
        return z;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function safeAdd(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x + y;
        assert(z >= x);
        return z;
    }
	
	/**
    * @dev Integer division of two numbers, reverts on division by zero.
    */
    function safeDiv(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x / y;
        return z;
    }
    
    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */	
    function safeMul(uint256 x, uint256 y) internal pure returns (uint256) {    
        if (x == 0) {
            return 0;
        }
    
        uint256 z = x * y;
        assert(z / x == y);
        return z;
    }

    /**
    * @dev Returns the integer percentage of the number.
    */
    function safePerc(uint256 x, uint256 y) internal pure returns (uint256) {
        if (x == 0) {
            return 0;
        }
        
        uint256 z = x * y;
        assert(z / x == y);    
        z = z / 10000; // percent to hundredths
        return z;
    }

    /**
    * @dev Returns the minimum value of two numbers.
    */	
    function min(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x <= y ? x : y;
        return z;
    }

    /**
    * @dev Returns the maximum value of two numbers.
    */
    function max(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x >= y ? x : y;
        return z;
    }
}
/**
 * @title Ownable contract - base contract with an owner
 */
contract Ownable {
  
  address public owner;
  address public newOwner;

  event OwnershipTransferred(address indexed _from, address indexed _to);
  
  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    assert(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    assert(_newOwner != address(0));      
    newOwner = _newOwner;
  }

  /**
   * @dev Accept transferOwnership.
   */
  function acceptOwnership() public {
    if (msg.sender == newOwner) {
      emit OwnershipTransferred(owner, newOwner);
      owner = newOwner;
    }
  }
}








/**
 * @title Agent contract - base contract with an agent
 */
contract Agent is Ownable {

  address public defAgent;

  mapping(address => bool) public Agents;  

  event UpdatedAgent(address _agent, bool _status);

  constructor() public {
    defAgent = msg.sender;
    Agents[msg.sender] = true;
  }
  
  modifier onlyAgent() {
    assert(Agents[msg.sender]);
    _;
  }
  
  function updateAgent(address _agent, bool _status) public onlyOwner {
    assert(_agent != address(0));
    Agents[_agent] = _status;

    emit UpdatedAgent(_agent, _status);
  }  
}



/**
 * @title Standard ERC223 token
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/223
 */
contract ERC223 is ERC223I, Agent, SafeMath {

  mapping(address => uint) balances;
  
  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;

  address public crowdsale = address(0);
  bool public released = false;

  /**
   * @dev Limit token transfer until the crowdsale is over.
   */
  modifier canTransfer() {
    assert(released || msg.sender == crowdsale);
    _;
  }

  modifier onlyCrowdsaleContract() {
    assert(msg.sender == crowdsale);
    _;
  }  
  
  function name() public view returns (string _name) {
    return name;
  }

  function symbol() public view returns (string _symbol) {
    return symbol;
  }

  function decimals() public view returns (uint8 _decimals) {
    return decimals;
  }

  function totalSupply() public view returns (uint256 _totalSupply) {
    return totalSupply;
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }  

  // if bytecode exists then the _addr is a contract.
  function isContract(address _addr) private view returns (bool is_contract) {
    uint length;
    assembly {
      //retrieve the size of the code on target address, this needs assembly
      length := extcodesize(_addr)
    }
    return (length>0);
  }
  
  // function that is called when a user or another contract wants to transfer funds .
  function transfer(address _to, uint _value, bytes _data) external canTransfer() returns (bool success) {      
    if(isContract(_to)) {
      return transferToContract(_to, _value, _data);
    } else {
      return transferToAddress(_to, _value, _data);
    }
  }
  
  // standard function transfer similar to ERC20 transfer with no _data.
  // added due to backwards compatibility reasons.
  function transfer(address _to, uint _value) external canTransfer() returns (bool success) {      
    bytes memory empty;
    if(isContract(_to)) {
      return transferToContract(_to, _value, empty);
    } else {
      return transferToAddress(_to, _value, empty);
    }
  }

  // function that is called when transaction target is an address
  function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
    if (balanceOf(msg.sender) < _value) revert();
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    emit Transfer(msg.sender, _to, _value, _data);
    return true;
  }
  
  // function that is called when transaction target is a contract
  function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
    if (balanceOf(msg.sender) < _value) revert();
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    assert(_to.call.value(0)(abi.encodeWithSignature("tokenFallback(address,uint256,bytes)", msg.sender, _value, _data)));
    emit Transfer(msg.sender, _to, _value, _data);
    return true;
  }

  // function that is called when a user or another contract wants to transfer funds .
  function transfer(address _to, uint _value, bytes _data, string _custom_fallback) external canTransfer() returns (bool success) {      
    if(isContract(_to)) {
      if (balanceOf(msg.sender) < _value) revert();
      balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
      balances[_to] = safeAdd(balanceOf(_to), _value);      
      assert(_to.call.value(0)(abi.encodeWithSignature(_custom_fallback), msg.sender, _value, _data));    
      emit Transfer(msg.sender, _to, _value, _data);
      return true;
    } else {
      return transferToAddress(_to, _value, _data);
    }
  }

  function setCrowdsaleContract(address _contract) external onlyOwner {
    crowdsale = _contract;
  }

  /**
   * @dev One way function to release the tokens to the wild. Can be called only from the crowdsale contract.
   */
  function releaseTokenTransfer() external onlyCrowdsaleContract {
    released = true;
  }
}

/**
 * @title SABIGlobal Token based on ERC223 token
 */
contract SABIToken is ERC223 {
	
  uint public initialSupply = 1400 * 10**6; // 1.4 billion

  /** Name and symbol were updated. */
  event UpdatedTokenInformation(string _name, string _symbol);

  constructor(string _name, string _symbol, address _crowdsale, address _team, address _bounty, address _adviser, address _developer) public {
    name = _name;
    symbol = _symbol;
    decimals = 8;
    crowdsale = _crowdsale;

    bytes memory empty;    
    totalSupply = initialSupply*uint(10)**decimals;
    // creating initial tokens
    balances[_crowdsale] = totalSupply;    
    emit Transfer(0x0, _crowdsale, balances[_crowdsale], empty);
    
    // send 15% - to team account
    uint value = safePerc(totalSupply, 1500);
    balances[_crowdsale] = safeSub(balances[_crowdsale], value);
    balances[_team] = value;
    emit Transfer(_crowdsale, _team, balances[_team], empty);  

    // send 5% - to bounty account
    value = safePerc(totalSupply, 500);
    balances[_crowdsale] = safeSub(balances[_crowdsale], value);
    balances[_bounty] = value;
    emit Transfer(_crowdsale, _bounty, balances[_bounty], empty);

    // send 1.5% - to adviser account
    value = safePerc(totalSupply, 150);
    balances[_crowdsale] = safeSub(balances[_crowdsale], value);
    balances[_adviser] = value;
    emit Transfer(_crowdsale, _adviser, balances[_adviser], empty);

    // send 1% - to developer account
    value = safePerc(totalSupply, 100);
    balances[_crowdsale] = safeSub(balances[_crowdsale], value);
    balances[_developer] = value;
    emit Transfer(_crowdsale, _developer, balances[_developer], empty);
  } 

  /**
  * Owner may issue new tokens
  */
  function mint(address _receiver, uint _amount) public onlyOwner {
    balances[_receiver] = safeAdd(balances[_receiver], _amount);
    totalSupply = safeAdd(totalSupply, _amount);
    bytes memory empty;    
    emit Transfer(0x0, _receiver, _amount, empty);    
  }

  /**
  * Owner can update token information here.
  */
  function updateTokenInformation(string _name, string _symbol) public onlyOwner {
    name = _name;
    symbol = _symbol;
    emit UpdatedTokenInformation(_name, _symbol);
  }
}