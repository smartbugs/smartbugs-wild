contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender == owner)
      _;
  }

  function transferOwner(address newOwner) onlyOwner {
    if (newOwner != address(0)) owner = newOwner;
  }

}

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

contract SafeMath {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
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

  function assert(bool assertion) internal {
    if (!assertion) throw;
  }
}

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

/*
  Wings ERC20 Token.
  Added allocation for users who participiated in Wings Campaign.

  Important!
  We have to run pre-mine allocation first.
  And only then rest of users.
  Or it's not going to work due to whenAllocation logic.
*/
contract Token is StandardToken, Ownable {
  // Account allocation event
  event ALLOCATION(address indexed account, uint amount);

  /*
    Premine events
  */
  event PREMINER_ADDED(address indexed owner, address account, uint amount);
  event PREMINE_ALLOCATION_ADDED(address indexed account, uint time);
  event PREMINE_RELEASE(address indexed account, uint timestamp, uint amount);
  event PREMINER_CHANGED(address indexed oldPreminer, address newPreminer, address newRecipient);

  /*
    Premine structure
  */
  struct Preminer {
    address account;
    uint monthlyPayment;
    uint latestAllocation;
    bool disabled;

    uint allocationsCount;
    mapping(uint => uint) allocations;
  }

  /*
    List of preminers
  */
  mapping(address => Preminer) preminers;

  /*
    Token Name & Token Symbol & Decimals
  */
  string public name = "WINGS";
  string public symbol = "WINGS";
  uint public decimals = 18;

  /*
    Total supply
  */
  uint public totalSupply = 10**26;//100000000000000000000000000;

  /*
    Premine allocation interval
  */
  uint public DAYS_28 = 2419200;
  uint public DAYS_31 = 2678400;

  /*
    Maximum premine allocations count
  */
  uint public MAX_ALLOCATIONS_COUNT = 26;

  /*
    How many accounts allocated?
  */
  uint public accountsToAllocate;

  /*
    Multisignature
  */
  address public multisignature;

  /*
    Only multisignature
  */
  modifier onlyMultisignature() {
    if (msg.sender != multisignature) {
      throw;
    }

    _;
  }

  /*
    When preminer is not disabled
  */
  modifier whenPreminerIsntDisabled(address _account) {
    if (preminers[_account].disabled == true) {
      throw;
    }

    _;
  }

  /*
    Modifier for checking is allocation completed.
    Maybe we should add here pre-mine accounts too.
  */
  modifier whenAllocation(bool value) {
    if ((accountsToAllocate > 0) == value) {
      _;
    } else {
      throw;
    }
  }

  /*
    Check if user already allocated
  */
  modifier whenAccountHasntAllocated(address user) {
    if (balances[user] == 0) {
      _;
    } else {
      throw;
    }
  }

  /*
    Check if preminer already added
  */
  modifier whenPremineHasntAllocated(address preminer) {
    if (preminers[preminer].account == address(0)) {
      _;
    } else {
      throw;
    }
  }

  function Token(uint _accountsToAllocate, address _multisignature) {
    /*
      Maybe we should calculate it in allocation and pre-mine.
      I mean total supply
    */
    owner = msg.sender;
    accountsToAllocate = _accountsToAllocate;
    multisignature = _multisignature;
  }

  /*
    Allocate tokens for users.
    Only owner and only while allocation active.

    Should check if user allocated already (no double allocations)
  */
  function allocate(address user, uint balance) onlyOwner() whenAllocation(true) whenAccountHasntAllocated(user) {
    balances[user] = balance;

    accountsToAllocate--;
    ALLOCATION(user, balance);
  }

  /*
    Standard Token functional
  */
  function transfer(address _to, uint _value) whenAllocation(false) returns (bool success) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint _value) whenAllocation(false) returns (bool success) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint _value) whenAllocation(false) returns (bool success) {
    return super.approve(_spender, _value);
  }

  /*
    Premine functionality
  */

  /*
    Add pre-mine account
  */
  function addPreminer(address preminer, address recipient, uint initialBalance, uint monthlyPayment) onlyOwner() whenAllocation(true) whenPremineHasntAllocated(preminer) {
    var premine = Preminer(
        recipient,
        monthlyPayment,
        0,
        false,
        0
      );


    balances[recipient] = safeAdd(balances[recipient], initialBalance);
    preminers[preminer] = premine;
    accountsToAllocate--;
    PREMINER_ADDED(preminer, premine.account, initialBalance);
  }

  /*
    Disable pre-miner
  */
  function disablePreminer(address _preminer, address _newPreminer, address _newRecipient) onlyMultisignature() whenPreminerIsntDisabled(_preminer) {
    var oldPreminer = preminers[_preminer];

    if (oldPreminer.account == address(0) || preminers[_newPreminer].account != address(0)) {
      throw;
    }

    preminers[_newPreminer] = oldPreminer;
    preminers[_newPreminer].account = _newRecipient;
    oldPreminer.disabled = true;

    if(preminers[_newPreminer].disabled == true) {
      throw;
    }

    for (uint i = 0; i < preminers[_newPreminer].allocationsCount; i++) {
      preminers[_newPreminer].allocations[i] = oldPreminer.allocations[i];
    }

    PREMINER_CHANGED(_preminer, _newPreminer, _newRecipient);
  }

  /*
    Add pre-mine allocation
  */
  function addPremineAllocation(address _preminer, uint _time) onlyOwner() whenAllocation(true) whenPreminerIsntDisabled(_preminer) {
    var preminer = preminers[_preminer];

    if (preminer.account == address(0) ||  _time == 0 || preminer.allocationsCount == MAX_ALLOCATIONS_COUNT) {
      throw;
    }

    if (preminer.allocationsCount > 0) {
      var previousAllocation = preminer.allocations[preminer.allocationsCount-1];

      if (previousAllocation > _time) {
        throw;
      }

      if (previousAllocation + DAYS_28 > _time) {
        throw;
      }

      if (previousAllocation + DAYS_31 < _time) {
        throw;
      }
    }

    preminer.allocations[preminer.allocationsCount++] = _time;
    PREMINE_ALLOCATION_ADDED(_preminer, _time);
  }

  /*
    Get preminer
  */
  function getPreminer(address _preminer) constant returns (address, bool, uint, uint, uint) {
    var preminer = preminers[_preminer];

    return (preminer.account, preminer.disabled, preminer.monthlyPayment, preminer.latestAllocation, preminer.allocationsCount);
  }

  /*
    Get preminer allocation time by index
  */
  function getPreminerAllocation(address _preminer, uint _index) constant returns (uint) {
    return preminers[_preminer].allocations[_index];
  }

  /*
    Release premine when preminer asking
    Gas usage: 0x5786 or 22406 GAS.
    Maximum is 26 months of pre-mine in case of Wings. So should be enough to execute it.
  */
  function releasePremine() whenAllocation(false) whenPreminerIsntDisabled(msg.sender) {
    var preminer = preminers[msg.sender];

    if (preminer.account == address(0)) {
      throw;
    }

    for (uint i = preminer.latestAllocation; i < preminer.allocationsCount; i++) {
      if (preminer.allocations[i] < block.timestamp) {
        if (preminer.allocations[i] == 0) {
          continue;
        }

        balances[preminer.account] = safeAdd(balances[preminer.account], preminer.monthlyPayment);
        preminer.latestAllocation = i;

        PREMINE_RELEASE(preminer.account, preminer.allocations[i], preminer.monthlyPayment);
        preminer.allocations[i] = 0;
      } else {
        break;
      }
    }
  }
}