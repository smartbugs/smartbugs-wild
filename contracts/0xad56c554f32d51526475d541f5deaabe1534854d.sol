pragma solidity ^0.4.15;





contract ContractReceiver {   
    function tokenFallback(address _from, uint _value, bytes _data){
    }
}

 /* New ERC23 contract interface */

contract ERC223 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  
  function name() constant returns (string _name);
  function symbol() constant returns (string _symbol);
  function decimals() constant returns (uint8 _decimals);
  function totalSupply() constant returns (uint256 _supply);

  function transfer(address to, uint value) returns (bool ok);
  function transfer(address to, uint value, bytes data) returns (bool ok);
  function transfer(address to, uint value, bytes data, string custom_fallback) returns (bool ok);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}

// The GXVC token ERC223

contract GXVCToken {

    // Token public variables
    string public name;
    string public symbol;
    uint8 public decimals; 
    string public version = 'v0.2';
    uint256 public totalSupply;
    bool locked;

    address rootAddress;
    address Owner;
    uint multiplier = 10000000000; // For 10 decimals
    address swapperAddress; // Can bypass a lock

    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;
    mapping(address => bool) freezed; 


  	event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // Modifiers

    modifier onlyOwner() {
        if ( msg.sender != rootAddress && msg.sender != Owner ) revert();
        _;
    }

    modifier onlyRoot() {
        if ( msg.sender != rootAddress ) revert();
        _;
    }

    modifier isUnlocked() {
    	if ( locked && msg.sender != rootAddress && msg.sender != Owner ) revert();
		_;    	
    }

    modifier isUnfreezed(address _to) {
    	if ( freezed[msg.sender] || freezed[_to] ) revert();
    	_;
    }


    // Safe math
    function safeAdd(uint x, uint y) internal returns (uint z) {
        require((z = x + y) >= x);
    }
    function safeSub(uint x, uint y) internal returns (uint z) {
        require((z = x - y) <= x);
    }


    // GXC Token constructor
    function GXVCToken() {        
        locked = true;
        totalSupply = 160000000 * multiplier; // 160,000,000 tokens * 10 decimals
        name = 'Genevieve VC'; 
        symbol = 'GXVC'; 
        decimals = 10; 
        rootAddress = msg.sender;        
        Owner = msg.sender;       
        balances[rootAddress] = totalSupply; 
        allowed[rootAddress][swapperAddress] = totalSupply;
    }


	// ERC223 Access functions

	function name() constant returns (string _name) {
	      return name;
	  }
	function symbol() constant returns (string _symbol) {
	      return symbol;
	  }
	function decimals() constant returns (uint8 _decimals) {
	      return decimals;
	  }
	function totalSupply() constant returns (uint256 _totalSupply) {
	      return totalSupply;
	  }


    // Only root function

    function changeRoot(address _newrootAddress) onlyRoot returns(bool){
    		allowed[rootAddress][swapperAddress] = 0; // Removes allowance to old rootAddress
            rootAddress = _newrootAddress;
            allowed[_newrootAddress][swapperAddress] = totalSupply; // Gives allowance to new rootAddress
            return true;
    }


    // Only owner functions

    function changeOwner(address _newOwner) onlyOwner returns(bool){
            Owner = _newOwner;
            return true;
    }

    function changeSwapperAdd(address _newSwapper) onlyOwner returns(bool){
    		allowed[rootAddress][swapperAddress] = 0; // Removes allowance to old rootAddress
            swapperAddress = _newSwapper;
            allowed[rootAddress][_newSwapper] = totalSupply; // Gives allowance to new rootAddress
            return true;
    }
       
    function unlock() onlyOwner returns(bool) {
        locked = false;
        return true;
    }

    function lock() onlyOwner returns(bool) {
        locked = true;
        return true;
    }

    function freeze(address _address) onlyOwner returns(bool) {
        freezed[_address] = true;
        return true;
    }

    function unfreeze(address _address) onlyOwner returns(bool) {
        freezed[_address] = false;
        return true;
    }

    function burn(uint256 _value) onlyOwner returns(bool) {
    	bytes memory empty;
        if ( balances[msg.sender] < _value ) revert();
        balances[msg.sender] = safeSub( balances[msg.sender] , _value );
        totalSupply = safeSub( totalSupply,  _value );
        Transfer(msg.sender, 0x0, _value , empty);
        return true;
    }


    // Public getters
    function isFreezed(address _address) constant returns(bool) {
        return freezed[_address];
    }

    function isLocked() constant returns(bool) {
        return locked;
    }

  // Public functions (from https://github.com/Dexaran/ERC223-token-standard/tree/Recommended)

  // Function that is called when a user or another contract wants to transfer funds to an address that has a non-standard fallback function
  function transfer(address _to, uint _value, bytes _data, string _custom_fallback) isUnlocked isUnfreezed(_to) returns (bool success) {
      
    if(isContract(_to)) {
        if (balances[msg.sender] < _value) return false;
        balances[msg.sender] = safeSub( balances[msg.sender] , _value );
        balances[_to] = safeAdd( balances[_to] , _value );
        ContractReceiver receiver = ContractReceiver(_to);
        receiver.call.value(0)(bytes4(sha3(_custom_fallback)), msg.sender, _value, _data);
        Transfer(msg.sender, _to, _value, _data);
        return true;
    }
    else {
        return transferToAddress(_to, _value, _data);
    }
}

  // Function that is called when a user or another contract wants to transfer funds to an address with tokenFallback function
  function transfer(address _to, uint _value, bytes _data) isUnlocked isUnfreezed(_to) returns (bool success) {
      
    if(isContract(_to)) {
        return transferToContract(_to, _value, _data);
    }
    else {
        return transferToAddress(_to, _value, _data);
    }
}


  // Standard function transfer similar to ERC20 transfer with no _data.
  // Added due to backwards compatibility reasons.
  function transfer(address _to, uint _value) isUnlocked isUnfreezed(_to) returns (bool success) {

    bytes memory empty;
    if(isContract(_to)) {
        return transferToContract(_to, _value, empty);
    }
    else {
        return transferToAddress(_to, _value, empty);
    }
}

//assemble the given address bytecode. If bytecode exists then the _addr is a contract.
  function isContract(address _addr) private returns (bool is_contract) {
      uint length;
      assembly {
            //retrieve the size of the code on target address, this needs assembly
            length := extcodesize(_addr)
      }
      return (length>0);
    }

  //function that is called when transaction target is an address
  function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
    if (balances[msg.sender] < _value) return false;
    balances[msg.sender] = safeSub(balances[msg.sender], _value);
    balances[_to] = safeAdd(balances[_to], _value);
    Transfer(msg.sender, _to, _value, _data);
    return true;
  }
  
  //function that is called when transaction target is a contract
  function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
    if (balances[msg.sender] < _value) return false;
    balances[msg.sender] = safeSub(balances[msg.sender] , _value);
    balances[_to] = safeAdd(balances[_to] , _value);
    ContractReceiver receiver = ContractReceiver(_to);
    receiver.tokenFallback(msg.sender, _value, _data);
    Transfer(msg.sender, _to, _value, _data);
    return true;
}


    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {

        if ( locked && msg.sender != swapperAddress ) return false; 
        if ( freezed[_from] || freezed[_to] ) return false; // Check if destination address is freezed
        if ( balances[_from] < _value ) return false; // Check if the sender has enough
		if ( _value > allowed[_from][msg.sender] ) return false; // Check allowance

        balances[_from] = safeSub(balances[_from] , _value); // Subtract from the sender
        balances[_to] = safeAdd(balances[_to] , _value); // Add the same to the recipient

        allowed[_from][msg.sender] = safeSub( allowed[_from][msg.sender] , _value );

        bytes memory empty;

        if ( isContract(_to) ) {
	        ContractReceiver receiver = ContractReceiver(_to);
	    	receiver.tokenFallback(_from, _value, empty);
		}

        Transfer(_from, _to, _value , empty);
        return true;
    }


    function balanceOf(address _owner) constant returns(uint256 balance) {
        return balances[_owner];
    }


    function approve(address _spender, uint _value) returns(bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }


    function allowance(address _owner, address _spender) constant returns(uint256) {
        return allowed[_owner][_spender];
    }
}
/**
 * @title Math
 * @dev Assorted math operations
 */

library Math {
  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
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
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

contract Dec {
    function decimals() public view returns (uint8);
}

contract ERC20 {
    function transfer(address,uint256);
}

contract KeeToken {
    // Stub

    function icoBalanceOf(address from, address ico) external view returns (uint) ;


}

contract KeeHole {
    using SafeMath for uint256;
    
    KeeToken  token;

    uint256   pos;
    uint256[] slots;
    uint256[] bonuses;

    uint256 threshold;
    uint256 maxTokensInTier;
    uint256 rate;
    uint256 tokenDiv;

    function KeeHole() public {
        token = KeeToken(0x72D32ac1c5E66BfC5b08806271f8eEF915545164);
        slots.push(100);
        slots.push(200);
        slots.push(500);
        slots.push(1200);
        bonuses.push(5);
        bonuses.push(3);
        bonuses.push(2);
        bonuses.push(1);
        threshold = 5;
        rate = 10000;
        tokenDiv = 100000000; // 10^18 / 10^10
        maxTokensInTier = 25000 * (10 ** 10);
    }

    mapping (address => bool) hasParticipated;

    // getBonusAmount - calculates any bonus due.
    // only one bonus per account
    function getBonusAmount(uint256 amount) public returns (uint256 bonus) {
        if (hasParticipated[msg.sender])
            return 0;
        if ( token.icoBalanceOf(msg.sender,this) < threshold )
            return 0;
        if (pos>=slots.length)
            return 0;
        bonus = (amount.mul(bonuses[pos])).div(100);
        slots[pos]--;
        if (slots[pos] == 0) 
            pos++;
        bonus = Math.min256(maxTokensInTier,bonus);
        hasParticipated[msg.sender] = true;
        return;
    }

    // this function is not const because it writes hasParticipated
    function getTokenAmount(uint256 ethDeposit) public returns (uint256 numTokens) {
        numTokens = (ethDeposit.mul(rate)).div(tokenDiv);
        numTokens = numTokens.add(getBonusAmount(numTokens));
    }


}

contract GenevieveCrowdsale is Ownable, Pausable, KeeHole {
  using SafeMath for uint256;

  // The token being sold
  GXVCToken public token;
  KeeHole public keeCrytoken;

  // owner of GXVC tokens
  address public tokenSpender;

  // start and end times
  uint256 public startTimestamp;
  uint256 public endTimestamp;

  // address where funds are collected
  address public hardwareWallet;

  mapping (address => uint256) public deposits;
  uint256 public numberOfPurchasers;

  // how many token units a buyer gets per wei comes from keeUser
  
 // uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;
  uint256 public weiToRaise;
  uint256 public tokensSold;

  uint256 public minContribution = 1 finney;


  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  event MainSaleClosed();

  uint256 public weiRaisedInPresale  = 0 ether;
  uint256 public tokensSoldInPresale = 0 * 10 ** 18;

// REGISTRY FUNCTIONS 

  mapping (address => bool) public registered;
  address public registrar;
  function setReg(address _newReg) external onlyOwner {
    registrar = _newReg;
  }

  function register(address participant) external {
    require(msg.sender == registrar);
    registered[participant] = true;
  }

// END OF REGISTRY FUNCTIONS

  function setCoin(GXVCToken _coin) external onlyOwner {
    token = _coin;
  }

  function setWallet(address _wallet) external onlyOwner {
    hardwareWallet = _wallet;
  }

  function GenevieveCrowdsale() public {
    token = GXVCToken(0x22F0AF8D78851b72EE799e05F54A77001586B18A);
    startTimestamp = 1516453200;
    endTimestamp = 1519563600;
    hardwareWallet = 0x6Bc63d12D5AAEBe4dc86785053d7E4f09077b89E;
    tokensSoldInPresale = 0; // 187500
    weiToRaise = 10000 * (10 ** 18);
    tokenSpender = 0x6835706E8e58544deb6c4EC59d9815fF6C20417f; // Bal = 104605839.665805634 GXVC

    minContribution = 1 finney;
    require(startTimestamp >= now);
    require(endTimestamp >= startTimestamp);
  }

  // check if valid purchase
  modifier validPurchase {
    // REGISTRY REQUIREMENT
    require(registered[msg.sender]);
    // END OF REGISTRY REQUIREMENT
    require(now >= startTimestamp);
    require(now < endTimestamp);
    require(msg.value >= minContribution);
    require(weiRaised.add(msg.value) <= weiToRaise);
    _;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    if (now > endTimestamp) 
        return true;
    if (weiRaised >= weiToRaise.sub(minContribution))
      return true;
    return false;
  }

  // low level token purchase function
  function buyTokens(address beneficiary, uint256 weiAmount) 
    internal 
    validPurchase 
    whenNotPaused
  {

    require(beneficiary != 0x0);

    if (deposits[beneficiary] == 0) {
        numberOfPurchasers++;
    }
    deposits[beneficiary] = weiAmount.add(deposits[beneficiary]);
    
    // calculate token amount to be created
    uint256 tokens = getTokenAmount(weiAmount);

    // update state
    weiRaised = weiRaised.add(weiAmount);
    tokensSold = tokensSold.add(tokens);

    require(token.transferFrom(tokenSpender, beneficiary, tokens));
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    hardwareWallet.transfer(this.balance);
  }

  // fallback function can be used to buy tokens
  function () public payable {
    buyTokens(msg.sender,msg.value);
  }

    function emergencyERC20Drain( ERC20 theToken, uint amount ) {
        theToken.transfer(owner, amount);
    }


}