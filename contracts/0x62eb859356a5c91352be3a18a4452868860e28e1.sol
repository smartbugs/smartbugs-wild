pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }
  
  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
 
    return c;
  }
  
  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }
  
  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }
}

library FrozenChecker {
  using SafeMath for uint256;
  
  /**
   * Rule for each address
   */
  struct Rule {
    uint256 timeT;
    uint8 initPercent;
    uint256[] periods;
    uint8[] percents;
  }
  
  function check(Rule storage self, uint256 totalFrozenValue) internal view returns(uint256) {
    if (totalFrozenValue == uint256(0)) {
      return 0;
    }
    if (self.timeT == uint256(0) || self.timeT > now) {
      return totalFrozenValue.sub(totalFrozenValue.mul(self.initPercent).div(100));
    }
    for (uint256 i = 0; i < self.periods.length.sub(1); i = i.add(1)) {
      if (now >= self.timeT.add(self.periods[i]) && now < self.timeT.add(self.periods[i.add(1)])) {
        return totalFrozenValue.sub(totalFrozenValue.mul(self.percents[i]).div(100));
      }
    }
    if (now >= self.timeT.add(self.periods[self.periods.length.sub(1)])) {
      return totalFrozenValue.sub(totalFrozenValue.mul(self.percents[self.periods.length.sub(1)]).div(100));
    }
  }
}

library FrozenValidator {
    
  using SafeMath for uint256;
  using FrozenChecker for FrozenChecker.Rule;

  struct Validator {
    mapping(address => IndexValue) data;
    KeyFlag[] keys;
    uint256 size;
  }

  struct IndexValue {
    uint256 keyIndex; 
    FrozenChecker.Rule rule;
    mapping (address => uint256) frozenBalances;
  }

  struct KeyFlag { 
    address key; 
    bool deleted; 
  }

  function addRule(Validator storage self, address key, uint8 initPercent, uint256[] periods, uint8[] percents) internal returns (bool replaced) {
    require(key != address(0));
    require(periods.length == percents.length);
    require(periods.length > 0);
    require(periods[0] == uint256(0));
    require(initPercent <= percents[0]);
    for (uint256 i = 1; i < periods.length; i = i.add(1)) {
      require(periods[i.sub(1)] < periods[i]);
      require(percents[i.sub(1)] <= percents[i]);
    }
    require(percents[percents.length.sub(1)] == 100);
    FrozenChecker.Rule memory rule = FrozenChecker.Rule(0, initPercent, periods, percents);
    uint256 keyIndex = self.data[key].keyIndex;
    self.data[key].rule = rule;
    if (keyIndex > 0) {
      return false;
    } else {
      keyIndex = self.keys.length++;
      self.data[key].keyIndex = keyIndex.add(1);
      self.keys[keyIndex].key = key;
      self.size++;
      return true;
    }
  }

  function removeRule(Validator storage self, address key) internal returns (bool success) {
    uint256 keyIndex = self.data[key].keyIndex;
    if (keyIndex == 0) {
      return false;
    }
    delete self.data[key];
    self.keys[keyIndex.sub(1)].deleted = true;
    self.size--;
    return true;
  }

  function containRule(Validator storage self, address key) internal view returns (bool) {
    return self.data[key].keyIndex > 0;
  }

  function addTimeT(Validator storage self, address addr, uint256 timeT) internal returns (bool) {
    require(timeT > now);
    self.data[addr].rule.timeT = timeT;
    return true;
  }

  function addFrozenBalance(Validator storage self, address from, address to, uint256 value) internal returns (uint256) {
    self.data[from].frozenBalances[to] = self.data[from].frozenBalances[to].add(value);
    return self.data[from].frozenBalances[to];
  }

  function validate(Validator storage self, address addr) internal returns (uint256) {
    uint256 frozenTotal = 0;
    for (uint256 i = iterateStart(self); iterateValid(self, i); i = iterateNext(self, i)) {
      address ruleaddr = iterateGet(self, i);
      FrozenChecker.Rule storage rule = self.data[ruleaddr].rule;
      frozenTotal = frozenTotal.add(rule.check(self.data[ruleaddr].frozenBalances[addr]));
    }
    return frozenTotal;
  }

  function iterateStart(Validator storage self) internal view returns (uint256 keyIndex) {
    return iterateNext(self, uint256(-1));
  }

  function iterateValid(Validator storage self, uint256 keyIndex) internal view returns (bool) {
    return keyIndex < self.keys.length;
  }

  function iterateNext(Validator storage self, uint256 keyIndex) internal view returns (uint256) {
    keyIndex++;
    while (keyIndex < self.keys.length && self.keys[keyIndex].deleted) {
      keyIndex++;
    }
    return keyIndex;
  }

  function iterateGet(Validator storage self, uint256 keyIndex) internal view returns (address) {
    return self.keys[keyIndex].key;
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
  constructor() public {
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
  event PausePublic(bool newState);
  event PauseOwnerAdmin(bool newState);

  bool public pausedPublic = true;
  bool public pausedOwnerAdmin = false;

  address public admin;

  /**
   * @dev Modifier to make a function callable based on pause states.
   */
  modifier whenNotPaused() {
    if(pausedPublic) {
      if(!pausedOwnerAdmin) {
        require(msg.sender == admin || msg.sender == owner);
      } else {
        revert();
      }
    }
    _;
  }

  /**
   * @dev called by the owner to set new pause flags
   * pausedPublic can't be false while pausedOwnerAdmin is true
   */
  function pause(bool newPausedPublic, bool newPausedOwnerAdmin) onlyOwner public {
    require(!(newPausedPublic == false && newPausedOwnerAdmin == true));

    pausedPublic = newPausedPublic;
    pausedOwnerAdmin = newPausedOwnerAdmin;

    PausePublic(newPausedPublic);
    PauseOwnerAdmin(newPausedOwnerAdmin);
  }
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract SEROToken is Pausable {
  using SafeMath for uint256;
  using FrozenValidator for FrozenValidator.Validator;
  
  string public name;
  string public symbol;
  uint8 public decimals = 9;
  uint256 public totalSupply;
  
  // Create array of all balances
  mapping (address => uint256) internal balances;
  mapping (address => mapping (address => uint256)) internal allowed;
  
  // Create array of freeze account
  mapping (address => bool) frozenAccount;       // Indefinite frozen account
  mapping (address => uint256) frozenTimestamp;  // Timelimit frozen account
  
  // Freeze account using rule
  FrozenValidator.Validator validator;
  
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event AdminTransferred(address indexed previousAdmin, address indexed newAdmin);
  
  constructor(string tokenName, string tokenSymbol, uint256 totalTokenSupply ) public {
     
    name = tokenName;
    symbol = tokenSymbol;
    totalSupply = totalTokenSupply * 10 ** uint256(decimals);
    admin = msg.sender;
    balances[msg.sender] = totalSupply;
    emit Transfer(0x0, msg.sender, totalSupply);
  }
  
  
  // Change admin
  function changeAdmin(address newAdmin) public onlyOwner returns (bool)  {
    // require(msg.sender == admin);
    require(newAdmin != address(0));
    // uint256 balAdmin = balances[admin];
    // balances[newAdmin] = balances[newAdmin].add(balAdmin);
    // balances[admin] = 0;
    admin = newAdmin;
    emit AdminTransferred(admin, newAdmin);
    return true;
  }
  
  // Get account frozen timestamp
  function getFrozenTimestamp(address _target) public view returns (uint256) {
    return frozenTimestamp[_target];
  }
  
  // Check if the account is freezed indefinitely 
  function getFrozenAccount(address _target) public view returns (bool) {
    return frozenAccount[_target];
  }
  
  // Indefinite freeze account or unfreeze account(set _freeze to true)
  function freeze(address _target, bool _freeze) public returns (bool) {
    require(msg.sender == admin);
    require(_target != admin);
    frozenAccount[_target] = _freeze;
    return true;
  }
  
  // Timelimit freeze account or unfreeze account(set _timestamp to 0x0)
  function freezeWithTimestamp(address _target, uint256 _timestamp) public returns (bool) {
    require(msg.sender == admin);
    require(_target != admin);
    frozenTimestamp[_target] = _timestamp;
    return true;
  }
  
  // Batch indefinite freeze account or unfreeze account
  function multiFreeze(address[] _targets, bool[] _freezes) public returns (bool) {
    require(msg.sender == admin);
    require(_targets.length == _freezes.length);
    uint256 len = _targets.length;
    require(len > 0);
    for (uint256 i = 0; i < len; i = i.add(1)) {
      address _target = _targets[i];
      require(_target != admin);
      bool _freeze = _freezes[i];
      frozenAccount[_target] = _freeze;
    }
    return true;
  }
  
  // Batch timelimit freeze account or unfreeze account
  function multiFreezeWithTimestamp(address[] _targets, uint256[] _timestamps) public returns (bool) {
    require(msg.sender == admin);
    require(_targets.length == _timestamps.length);
    uint256 len = _targets.length;
    require(len > 0);
    for (uint256 i = 0; i < len; i = i.add(1)) {
      address _target = _targets[i];
      require(_target != admin);
      uint256 _timestamp = _timestamps[i];
      frozenTimestamp[_target] = _timestamp;
    }
    return true;
  }
  
  /* Freeze or unfreeze account using rules */
  
  function addRule(address addr, uint8 initPercent, uint256[] periods, uint8[] percents) public returns (bool) {
    require(msg.sender == admin);
    return validator.addRule(addr, initPercent, periods, percents);
  }

  function addTimeT(address addr, uint256 timeT) public returns (bool) {
    require(msg.sender == admin);
    return validator.addTimeT(addr, timeT);
  }
  
  function removeRule(address addr) public returns (bool) {
    require(msg.sender == admin);
    return validator.removeRule(addr);
  }
  
  function validate(address addr) public view returns (uint256) {
    require(msg.sender == admin);
    return validator.validate(addr);
  }

    
  function queryRule(address addr) public view returns (uint256,uint8,uint256[],uint8[]) {
    require(msg.sender == admin);
    return (validator.data[addr].rule.timeT,validator.data[addr].rule.initPercent,validator.data[addr].rule.periods,validator.data[addr].rule.percents);
  }
  
  /* ERC20 interface */
  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    _transfer(_to, _value);
    return true;
  }
  
  function _transfer(address _to, uint256 _value) internal whenNotPaused {
    require(_to != 0x0);
    require(!frozenAccount[msg.sender]);
    require(now > frozenTimestamp[msg.sender]);
    require(balances[msg.sender].sub(_value) >= validator.validate(msg.sender));

    if (validator.containRule(msg.sender) && msg.sender != _to) {
        validator.addFrozenBalance(msg.sender, _to, _value);
    }
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);

    emit Transfer(msg.sender, _to, _value);
  }
 
  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    require(_to != 0x0);
    require(!frozenAccount[_from]);
    require(now > frozenTimestamp[_from]);
    require(_value <= balances[_from].sub(validator.validate(_from)));
    require(_value <= allowed[_from][msg.sender]);

    if (validator.containRule(_from) && _from != _to) {
      validator.addFrozenBalance(_from, _to, _value);
    }

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

    emit Transfer(_from, _to, _value);
    return true;
  }
  
  function multiTransfer(address[] _tos, uint256[] _values) public whenNotPaused returns (bool) {
    require(!frozenAccount[msg.sender]);
    require(now > frozenTimestamp[msg.sender]);
    require(_tos.length == _values.length);
    uint256 len = _tos.length;
    require(len > 0);
    uint256 amount = 0;
    for (uint256 i = 0; i < len; i = i.add(1)) {
      amount = amount.add(_values[i]);
    }
    require(amount <= balances[msg.sender].sub(validator.validate(msg.sender)));
    for (uint256 j = 0; j < len; j = j.add(1)) {
      address _to = _tos[j];
      require(_to != 0x0);
      if (validator.containRule(msg.sender) && msg.sender != _to) {
        validator.addFrozenBalance(msg.sender, _to, _values[j]);
      }
      balances[_to] = balances[_to].add(_values[j]);
      balances[msg.sender] = balances[msg.sender].sub(_values[j]);
      emit Transfer(msg.sender, _to, _values[j]);
    }
    return true;
  }
  
  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    allowed[msg.sender][_spender] = _value;

    emit Approval(msg.sender, _spender, _value);
    return true;
  }
  
  function approveAndCall(address _spender, uint256 _value, bytes _extraData) public whenNotPaused returns (bool success) {

    require(_spender != 0x0);
    require(!frozenAccount[msg.sender]);
    require(now > frozenTimestamp[msg.sender]);
    require(_value <= balances[msg.sender].sub(validator.validate(msg.sender)));

    if (validator.containRule(msg.sender) && msg.sender != _spender) {
      validator.addFrozenBalance(msg.sender, _spender, _value);
    }

    tokenRecipient spender = tokenRecipient(_spender);
    if (approve(_spender, _value)) {
      spender.receiveApproval(msg.sender, _value, this, _extraData);
      return true;
    }
  }
  
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }
  
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner]; //.sub(validator.validate(_owner));
  }
  
  function kill() public {
    require(msg.sender == admin);
    selfdestruct(admin);
  }
}