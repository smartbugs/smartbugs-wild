pragma solidity ^0.4.18;

/** ----------------------------------------------------------------------------------------------
 * ENGINE_Token by ENGINE Limited.
 * An ERC20 standard
 *
 * author: ENGINE Team
 */

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error.
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
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract EEEToken is ERC20, Ownable {

  using SafeMath for uint256;

  
  // the controller of minting and destroying tokens
  address public engDevAddress = 0x6d3E0B5abFc141cAa674a3c11e1580e6fff2a0B9;
  // the controller of approving of minting and withdraw tokens
  address public engCommunityAddress = 0x4885B422656D4B316C9C7Abc0c0Ab31A2677d9f0;

  struct TokensWithLock {
    uint256 value;
    uint256 blockNumber;
  }
  // Balances for each account
  mapping(address => uint256) balances;

  mapping(address => TokensWithLock) lockTokens;
  
  mapping (address => mapping (address => uint256)) public allowance;
  
  // Owner of account approves the transfer of an amount to another account
  mapping(address => mapping (address => uint256)) allowed;
  // Token Cap
  uint256 public totalSupplyCap = 1e28;
  // Token Info
  string public name = "EEE_Token";
  string public symbol = "EEE";
  uint8 public decimals = 18;

  // True if transfers are allowed
  bool public transferable = false;
  // True if the transferable can be change
  bool public canSetTransferable = true;


  modifier only(address _address) {
    require(msg.sender == _address);
    _;
  }

  modifier nonZeroAddress(address _address) {
    require(_address != address(0));
    _;
  }

  modifier canTransfer() {
    require(transferable == true);
    _;
  }

  /**
   * @dev Fix for the ERC20 short address attack.
   */
  modifier onlyPayloadSize(uint size) {
    if(msg.data.length < size + 4) {
       revert();
    }
    _;
  }



  event Burn(address indexed from, uint256 value);
  event SetTransferable(address indexed _address, bool _transferable);
  event SetENGDevAddress(address indexed _old, address indexed _new);
  event SetENGCommunityAddress(address indexed _old, address indexed _new);
  event DisableSetTransferable(address indexed _address, bool _canSetTransferable);

 /**
   * @dev transfer token for a specified address
   * @param _to The address to transfer to.
   * @param _value The amount to be transferred.
   */
  function transfer(address _to, uint256 _value) canTransfer public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    require(_value >= 0);
    require(balances[_to] + _value > balances[_to]);

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
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) canTransfer public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value > 0);

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
  function approve(address _spender, uint256 _value) canTransfer public returns (bool) {
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));
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
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval(address _spender, uint256 _addedValue) canTransfer public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint256 _subtractedValue) canTransfer public returns (bool) {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Enables token holders to transfer their tokens freely if true
   * @param _transferable True if transfers are allowed
   */
  function setTransferable(bool _transferable) only(engDevAddress) public {
    require(canSetTransferable == true);
    transferable = _transferable;
    SetTransferable(msg.sender, _transferable);
  }

  /**
   * @dev disable the canSetTransferable
   */
  function disableSetTransferable() only(engDevAddress) public {
    transferable = true;
    canSetTransferable = false;
    DisableSetTransferable(msg.sender, false);
  }

  /**
   * @dev Set the engAddress
   * @param _engDevAddress The new engAddress
   */
  function setENGDevAddress(address _engDevAddress) only(engDevAddress) nonZeroAddress(_engDevAddress) public {
    engDevAddress = _engDevAddress;
    SetENGDevAddress(msg.sender, _engDevAddress);
  }
  /**
   * @dev Set the engCommunityAddress
   * @param _engCommunityAddress The new engCommunityAddress
   */
  function setENGCommunityAddress(address _engCommunityAddress) only(engCommunityAddress) nonZeroAddress(_engCommunityAddress) public {
    engCommunityAddress = _engCommunityAddress;
    SetENGCommunityAddress(msg.sender, _engCommunityAddress);
  }

  /**
   * @dev Get the quantity of locked tokens
   * @param _owner The address of locked tokens
   * @return the quantity and the lock time of locked tokens
   */
   function getLockTokens(address _owner) nonZeroAddress(_owner) view public returns (uint256 value, uint256 blockNumber) {
     return (lockTokens[_owner].value, lockTokens[_owner].blockNumber);
   }

  /**
   * @dev Transfer tokens to multiple addresses
   * @param _addresses The addresses that will receieve tokens
   * @param _amounts The quantity of tokens that will be transferred
   * @return True if the tokens are transferred correctly
   */
  function transferForMultiAddresses(address[] _addresses, uint256[] _amounts) canTransfer public returns (bool) {
    for (uint256 i = 0; i < _addresses.length; i++) {
      require(_addresses[i] != address(0));
      require(_amounts[i] <= balances[msg.sender]);
      require(_amounts[i] > 0);

      // SafeMath.sub will throw if there is not enough balance.
      balances[msg.sender] = balances[msg.sender].sub(_amounts[i]);
      balances[_addresses[i]] = balances[_addresses[i]].add(_amounts[i]);
      Transfer(msg.sender, _addresses[i], _amounts[i]);
    }
    return true;
  }

  /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);   // Check if the sender has enough
        balances[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }

    /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balances[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        Burn(_from, _value);
        return true;
    }
}