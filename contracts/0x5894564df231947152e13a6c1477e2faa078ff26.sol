pragma solidity ^0.4.15;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

  address public owner;

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() internal {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
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
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() external onlyOwner whenNotPaused {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() external onlyOwner whenPaused {
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
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
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
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
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
  function approve(address _spender, uint256 _value) public returns (bool) {
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
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }
}


/**
 * @title Pausable token
 *
 * @dev StandardToken modified with pausable transfers.
 **/

contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }
}


/**
 * Alvalor token
 *
 * The Alvalor Token is a simple ERC20 token with an initial supply equivalent to the maximum value
 * of an unsigned 64-bit integer, credited to the creator which represents the Alvalor foundation.
 *
 * It is pausible so that transfers can be frozen when we create the snapshot of balances, which
 * will be used to transfer balances to the Alvalor genesis block.
 **/

contract AlvalorToken is PausableToken {

  using SafeMath for uint256;

  // the details of the token for wallets
  string public constant name = "Alvalor";
  string public constant symbol = "TVAL";
  uint8 public constant decimals = 12;

  // when frozen, the supply of the token cannot change anymore
  bool public frozen = false;

  // defines the maximum total supply and the maximum number of tokens
  // claimable through the airdrop mechanism
  uint256 public constant maxSupply = 18446744073709551615;
  uint256 public constant dropSupply = 3689348814741910323;

  // keeps track of the total supply already claimed through the airdrop
  uint256 public claimedSupply = 0;

  // keeps track of how much each address can claim in the airdrop
  mapping(address => uint256) private claims;

  // events emmitted by the contract
  event Freeze();
  event Drop(address indexed receiver, uint256 value);
  event Mint(address indexed receiver, uint256 value);
  event Claim(address indexed receiver, uint256 value);
  event Burn(address indexed receiver, uint256 value);

  // the not frozen modifier guards functions modifying the supply of the token
  // from being called after the token supply has been frozen
  modifier whenNotFrozen() {
    require(!frozen);
    _;
  }

  modifier whenFrozen() {
    require(frozen);
    _;
  }

  // AlvalorToken will make sure the owner can claim any unclaimed drop at any
  // point.
  function AlvalorToken() public {
    claims[owner] = dropSupply;
  }

  // freeze will irrevocably stop all modifications to the supply of the token,
  // effectively freezing the supply of the token (transfers are still possible)
  function freeze() external onlyOwner whenNotFrozen {
    frozen = true;
    Freeze();
  }

  // mint can be called by the owner to create tokens for a certain receiver
  // it will no longer work once the token supply has been frozen
  function mint(address _receiver, uint256 _value) onlyOwner whenNotFrozen public returns (bool) {
    require(_value > 0);
    require(_value <= maxSupply.sub(totalSupply).sub(dropSupply));
    totalSupply = totalSupply.add(_value);
    balances[_receiver] = balances[_receiver].add(_value);
    Mint(_receiver, _value);
    return true;
  }

  function claimable(address _receiver) constant public returns (uint256) {
    if (claimedSupply >= dropSupply) {
      return 0;
    }
    return claims[_receiver];
  }

  // drop will create a new allowance for claimable tokens of the airdrop
  // it will no longer work once the token supply has been frozen
  function drop(address _receiver, uint256 _value) onlyOwner whenNotFrozen public returns (bool) {
    require(claimedSupply < dropSupply);
    require(_receiver != owner);
    claims[_receiver] = _value;
    Drop(_receiver, _value);
    return true;
  }

  // claim will allow any sender to retrieve the airdrop tokens assigned to him
  // it will only work until the maximum number of airdrop tokens are redeemed
  function claim() whenNotPaused whenFrozen public returns (bool) {
    require(claimedSupply < dropSupply);
    uint value = Math.min256(claims[msg.sender], dropSupply.sub(claimedSupply));
    claims[msg.sender] = claims[msg.sender].sub(value);
    claimedSupply = claimedSupply.add(value);
    totalSupply = totalSupply.add(value);
    balances[msg.sender] = balances[msg.sender].add(value);
    Claim(msg.sender, value);
    return true;
  }
}