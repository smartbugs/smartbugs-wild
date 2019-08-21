pragma solidity ^0.4.15;

/**
* GoldGate Token Contract
* Copyright © 2017 by GoldGate https://goldgate.io
*/

/**
 * @title ERC20Basic
 * Simpler version of ERC20 interface
 * https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * transfer token for a specified address
  */
  function transfer(address _to, uint256 _value) returns (bool) {
    require(_to != address(0));

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * Gets the balance of the specified address.
  */
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title Ownable
 * The Ownable contract has an owner address, and provides basic authorization control
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }

  /**
   * Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * Allows the current owner to transfer control of the contract to a newOwner.
   */
  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title Pausable
 * Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused {
    paused = true;
    Pause();
  }

  /**
   * called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused {
    paused = false;
    Unpause();
  }
}

/**
 * @title Ownable
 */
contract GGOwnable is Ownable {

  address public newOwner;

  /**
   * Allows the current owner to transfer control of the contract to an otherOwner.
   */
  function transferOwnership(address otherOwner) onlyOwner {
    require(otherOwner != address(0));      
    newOwner = otherOwner;
  }

  /**
   * Finish ownership transfer.
   */
  function approveOwnership() {
    require(msg.sender == newOwner);
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
    newOwner = address(0);
  }
}


/**
 * @title Moderated
 * Moderator can make transfers from and to any account (including frozen).
 */
contract GGModerated is GGOwnable {

  address public moderator;
  address public newModerator;

  /**
   * Throws if called by any account other than the moderator.
   */
  modifier onlyModerator() {
    require(msg.sender == moderator);
    _;
  }

  /**
   * Throws if called by any account other than the owner or moderator.
   */
  modifier onlyOwnerOrModerator() {
    require((msg.sender == moderator) || (msg.sender == owner));
    _;
  }

  /**
   * Moderator same as owner
   */
  function GGModerated(){
    moderator = msg.sender;
  }

  /**
   * Allows the current moderator to transfer control of the contract to an otherModerator.
   */
  function transferModeratorship(address otherModerator) onlyModerator {
    newModerator = otherModerator;
  }

  /**
   * Complete moderatorship transfer.
   */
  function approveModeratorship() {
    require(msg.sender == newModerator);
    moderator = newModerator;
    newModerator = address(0);
  }

  /**
   * Removes moderator from the contract.
   */
  function removeModeratorship() onlyOwner {
      moderator = address(0);
  }

  function hasModerator() constant returns(bool) {
      return (moderator != address(0));
  }
}

/**
 * @title Pausable
 */
contract GGPausable is Pausable, GGModerated {
  /**
   * called by the owner or moderator to pause, triggers stopped state
   */
  function pause() onlyOwnerOrModerator whenNotPaused {
    paused = true;
    Pause();
  }

  /**
   * called by the owner or moderator to unpause, returns to normal state
   */
  function unpause() onlyOwnerOrModerator whenPaused {
    paused = false;
    Unpause();
  }
}

/**
 * @title Standard ERC20 token
 * Implementation of the basic standard token.
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;

  /**
   * transfer tokens from one address to another
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    require(_to != address(0));

    var _allowance = allowed[_from][msg.sender];

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   */
  function approve(address _spender, uint256 _value) returns (bool) {
    // to change the approve amount you first have to reduce the addresses`
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * function to check the amount of tokens that an owner allowed to a spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
  
  function increaseApproval (address _spender, uint _addedValue) 
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) 
    returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

/**
 * @title SafeMath
 * Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * Pausable token with moderator role and freeze address implementation
 **/
contract ModToken is StandardToken, GGPausable {

  mapping(address => bool) frozen;

  /**
   * check if given address is frozen. Freeze works only if moderator role is active
   */
  function isFrozen(address _addr) constant returns (bool){
      return frozen[_addr] && hasModerator();
  }

  /**
   * Freezes address (no transfer can be made from or to this address).
   */
  function freeze(address _addr) onlyModerator {
      frozen[_addr] = true;
  }

  /**
   * Unfreezes frozen address.
   */
  function unfreeze(address _addr) onlyModerator {
      frozen[_addr] = false;
  }

  /**
   * Declines transfers from/to frozen addresses.
   */
  function transfer(address _to, uint256 _value) whenNotPaused returns (bool) {
    require(!isFrozen(msg.sender));
    require(!isFrozen(_to));
    return super.transfer(_to, _value);
  }

  /**
   * Declines transfers from/to/by frozen addresses.
   */
  function transferFrom(address _from, address _to, uint256 _value) whenNotPaused returns (bool) {
    require(!isFrozen(msg.sender));
    require(!isFrozen(_from));
    require(!isFrozen(_to));
    return super.transferFrom(_from, _to, _value);
  }

  /**
   * Allows moderator to transfer tokens from one address to another.
   */
  function moderatorTransferFrom(address _from, address _to, uint256 _value) onlyModerator returns (bool) {
    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }
}

contract GoldGate is ModToken {
  string public constant version = "1.0.0";
  string public constant name = "GoldGate";
  string public constant symbol = "BGG";
  uint256 public constant decimals = 8;

  function GoldGate(uint256 _initialSupply) {   
    totalSupply = _initialSupply;
    balances[msg.sender] = _initialSupply;
  }
}