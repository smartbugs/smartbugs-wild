pragma solidity ^ 0.4.16;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns(uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns(uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns(uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns(uint256) {
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
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner public {
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

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns(uint256);
  function transfer(address to, uint256 value) public returns(bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns(uint256);
  function transferFrom(address from, address to, uint256 value) public returns(bool);
  function approve(address spender, uint256 value) public returns(bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Lockupable is Pausable {
  function _unlockIfPosible(address who) internal;
  function unlockAll() onlyOwner public returns(bool);
  function lockupOf(address who) public constant returns(uint256[5]);
  function distribute(address _to, uint256 _value, uint256 _amount1, uint256 _amount2, uint256 _amount3, uint256 _amount4) onlyOwner public returns(bool);
}

/**
 * @title ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20Token is ERC20 {
  using SafeMath for uint256;

    mapping(address => uint256) balances;
  mapping(address => mapping(address => uint256)) internal allowed;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns(bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _holder The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _holder) public constant returns(uint256 balance) {
    return balances[_holder];
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns(bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns(uint256 remaining) {
    return allowed[_owner][_spender];
  }
}

/**
 * @title Lockupable token
 *
 * @dev ERC20Token modified with lockupable.
 **/

contract LockupableToken is ERC20Token, Lockupable {

  uint64[] RELEASE = new uint64[](4);
  mapping(address => uint256[4]) lockups;
  mapping(uint => address) private holders;
  uint _lockupHolders;
  bool unlocked;


  function transfer(address _to, uint256 _value) public whenNotPaused returns(bool) {
    _unlockIfPosible(_to);
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns(bool) {
    _unlockIfPosible(_from);
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns(bool) {
    return super.approve(_spender, _value);
  }
  function balanceOf(address _holder) public constant returns(uint256 balance) {
    uint256[5] memory amount = lockupOf(_holder);
    return amount[0];
  }
  /**
    * @dev Gets the lockup of the specified address.
    * @param who address The address to query the the balance of.
    * @return An lockupOf representing the amount owned by the passed address.
   */
  function lockupOf(address who) public constant  returns(uint256[5]){
    uint256[5] memory amount;
    amount[0] = balances[who];
    for (uint i = 0; i < RELEASE.length; i++) {
      amount[i + 1] = lockups[who][i];
      if (now >= RELEASE[i]) {
        amount[0] = amount[0].add(lockups[who][i]);
        amount[i + 1] = 0;
      }
    }

    return amount;
  }
  /**
    * @dev update balance lockUpAmount
    * @param who address The address updated the balances of.
    */
  function _unlockIfPosible(address who) internal{
    if (now <= RELEASE[3] || !unlocked) {
      uint256[5] memory amount = lockupOf(who);
      balances[who] = amount[0];
      for (uint i = 0; i < 4; i++) {
        lockups[who][i] = amount[i + 1];
      }
    }
  }
  /**
     * @dev unlock all after August 31 , 2019 GMT+9.
     * 
     */
  function unlockAll() onlyOwner public returns(bool){
    if (now > RELEASE[3]) {
      for (uint i = 0; i < _lockupHolders; i++) {
        balances[holders[i]] = balances[holders[i]].add(lockups[holders[i]][0]);
        balances[holders[i]] = balances[holders[i]].add(lockups[holders[i]][1]);
        balances[holders[i]] = balances[holders[i]].add(lockups[holders[i]][2]);
        balances[holders[i]] = balances[holders[i]].add(lockups[holders[i]][3]);
        lockups[holders[i]][0] = 0;
        lockups[holders[i]][1] = 0;
        lockups[holders[i]][2] = 0;
        lockups[holders[i]][3] = 0;
      }
      unlocked = true;
    }

    return true;
  }
  /**
    * @dev Distribute tokens from owner address to another , distribute for ICO and bounty campaign
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of  Amount1-type-tokens to be transferred
    * ...
    * @param _amount4 uint256 the amount of Amount1-type-tokens to be transferred
    */
  function distribute(address _to, uint256 _value, uint256 _amount1, uint256 _amount2, uint256 _amount3, uint256 _amount4) onlyOwner public returns(bool) {
    require(_to != address(0));
    _unlockIfPosible(msg.sender);
    uint256 __total = 0;
    __total = __total.add(_amount1);
    __total = __total.add(_amount2);
    __total = __total.add(_amount3);
    __total = __total.add(_amount4);
    __total = __total.add(_value);
    balances[msg.sender] = balances[msg.sender].sub(__total);
    balances[_to] = balances[_to].add(_value);
    lockups[_to][0] = lockups[_to][0].add(_amount1);
    lockups[_to][1] = lockups[_to][1].add(_amount2);
    lockups[_to][2] = lockups[_to][2].add(_amount3);
    lockups[_to][3] = lockups[_to][3].add(_amount4);

    holders[_lockupHolders] = _to;
    _lockupHolders++;

    Transfer(msg.sender, _to, __total);
    return true;
  }


}

/**
 * @title BBXC Token
 *
 * @dev Implementation of BBXC Token based on the ERC20Token token.
 */
contract BBXCToken is LockupableToken {

  function () {
    //if ether is sent to this address, send it back.
    revert();
  }

  /**
  * Public variables of the token
  */
  string public constant name = 'Bluebelt Exchange Coin';
  string public constant symbol = 'BBXC';
  uint8 public constant decimals = 18;


  /**
   * @dev Constructor 
   */
  function BBXCToken() {
    _lockupHolders = 0;
    RELEASE[0] = 1553958000; // March 30, 2019, GMT+9
    RELEASE[1] = 1556550000; // April 29, 2019, GMT+9.
    RELEASE[2] = 1559228400; //	May 30, 2019, GMT+9.
    RELEASE[3] = 1567263600; // August 31 , 2019 GMT+9.
  
    totalSupply = 200000000 * (uint256(10) ** decimals);
    unlocked = false;
    balances[msg.sender] = totalSupply;
    Transfer(address(0x0), msg.sender, totalSupply);
  }
}