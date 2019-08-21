pragma solidity ^0.4.11;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
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

/*
file:   ReentryProtection.sol
ver:    0.3.0
updated:6-April-2016
author: Darryl Morris
email:  o0ragman0o AT gmail.com

Mutex based reentry protection protect.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.
<http://www.gnu.org/licenses/>.
*/

contract ReentryProtected
{
  // The reentry protection state mutex.
  bool __reMutex;

  // This modifier can be used on functions with external calls to
  // prevent reentry attacks.
  // Constraints:
  //   Protected functions must have only one point of exit.
  //   Protected functions cannot use the `return` keyword
  //   Protected functions return values must be through return parameters.
  modifier preventReentry() {
    require(!__reMutex);
    __reMutex = true;
    _;
    delete __reMutex;
    return;
  }

  // This modifier can be applied to public access state mutation functions
  // to protect against reentry if a `preventReentry` function has already
  // set the mutex. This prevents the contract from being reenter under a
  // different memory context which can break state variable integrity.
  modifier noReentry() {
    require(!__reMutex);
    _;
  }
}

/*
file:   ERC20.sol
ver:    0.4.4-o0ragman0o
updated:26-July-2017
author: Darryl Morris
email:  o0ragman0o AT gmail.com

An ERC20 compliant token with reentry protection and safe math.

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  
See MIT Licence for further details.
<https://opensource.org/licenses/MIT>.

Release Notes
-------------
0.4.4-o0ragman0o
* removed state from interface
* added abstract functions of public state to interface.
* included state into contract implimentation
*/


// ERC20 Standard Token Interface with safe maths and reentry protection
contract ERC20Interface
{
  /* Structs */

  /* State Valiables */

  /* Events */
  // Triggered when tokens are transferred.
  event Transfer(
    address indexed _from,
    address indexed _to,
    uint256 _value);

  // Triggered whenever approve(address _spender, uint256 _value) is called.
  event Approval(
    address indexed _owner,
    address indexed _spender,
    uint256 _value);

  /* Modifiers */

  /* Function Abstracts */

  /// @return The total supply of tokens
  function totalSupply() public constant returns (uint256);

  /// @param _addr The address of a token holder
  /// @return The amount of tokens held by `_addr`
  function balanceOf(address _addr) public constant returns (uint256);

  /// @param _owner The address of a token holder
  /// @param _spender the address of a third-party
  /// @return The amount of tokens the `_spender` is allowed to transfer
  function allowance(address _owner, address _spender) public constant
  returns (uint256);

  /// @notice Send `_amount` of tokens from `msg.sender` to `_to`
  /// @param _to The address of the recipient
  /// @param _amount The amount of tokens to transfer
  function transfer(address _to, uint256 _amount) public returns (bool);

  /// @notice Send `_amount` of tokens from `_from` to `_to` on the condition
  /// it is approved by `_from`
  /// @param _from The address of the sender
  /// @param _to The address of the recipient
  /// @param _amount The amount of tokens to transfer
  function transferFrom(address _from, address _to, uint256 _amount)
  public returns (bool);

  /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
  /// its behalf
  /// @param _spender The address of the approved spender
  /// @param _amount The amount of tokens to transfer
  function approve(address _spender, uint256 _amount) public returns (bool);
}

contract ERC20Token is ReentryProtected, ERC20Interface
{

  using SafeMath for uint256;

  /* State */
  // The Total supply of tokens
  uint256 totSupply;

  
  // Token ownership mapping
  mapping (address => uint256) balance;

  // Allowances mapping
  mapping (address => mapping (address => uint256)) allowed;

  /* Funtions Public */

  function ERC20Token()
  {
    // Supply limited to 2^128 rather than 2^256 to prevent potential 
    // multiplication overflow
    
    totSupply = 0;
    balance[msg.sender] = totSupply;
  }

  // Using an explicit getter allows for function overloading    
  function totalSupply()
  public
  constant
  returns (uint256)
  {
    return totSupply;
  }


  // Using an explicit getter allows for function overloading    
  function balanceOf(address _addr)
  public
  constant
  returns (uint256)
  {
    return balance[_addr];
  }

  // Using an explicit getter allows for function overloading    
  function allowance(address _owner, address _spender)
  public
  constant
  returns (uint256 remaining_)
  {
    return allowed[_owner][_spender];
  }


  // Send _value amount of tokens to address _to
  // Reentry protection prevents attacks upon the state
  function transfer(address _to, uint256 _value)
  public
  noReentry
  returns (bool)
  {
    return xfer(msg.sender, _to, _value);
  }

  // Send _value amount of tokens from address _from to address _to
  // Reentry protection prevents attacks upon the state
  function transferFrom(address _from, address _to, uint256 _value)
  public
  noReentry
  returns (bool)
  {
    require(_value <= allowed[_from][msg.sender]);
    allowed[_from][msg.sender] -= _value;
    return xfer(_from, _to, _value);
  }

  // Process a transfer internally.
  function xfer(address _from, address _to, uint256 _value)
  internal
  returns (bool)
  {
    require(_value > 0 && _value <= balance[_from]);
    balance[_from] -= _value;
    balance[_to] += _value;
    Transfer(_from, _to, _value);
    return true;
  }

  // Approves a third-party spender
  // Reentry protection prevents attacks upon the state
  function approve(address _spender, uint256 _value)
  public
  noReentry
  returns (bool)
  {
    require(balance[msg.sender] != 0);
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
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
   function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    owner = newOwner;
  }

}


/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

 contract MintableToken is ERC20Token, Ownable {
  using SafeMath for uint256;
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
   function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
    totSupply = totSupply.add(_amount);
    balance[_to] = balance[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
    return true;
  }

    /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
   function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}
/**
 * @title SimpleToken
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator. 
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `StandardToken` functions.
 */
 contract TriaToken_v2 is MintableToken {

  string public constant name = "TriaToken";
  string public constant symbol = "TRIA";
  uint256 public constant decimals = 10;
}