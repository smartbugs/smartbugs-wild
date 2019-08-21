pragma solidity 0.4.18;

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: zeppelin-solidity/contracts/lifecycle/Pausable.sol

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

// File: zeppelin-solidity/contracts/math/SafeMath.sol

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

// File: zeppelin-solidity/contracts/token/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: zeppelin-solidity/contracts/token/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

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
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

// File: zeppelin-solidity/contracts/token/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: zeppelin-solidity/contracts/token/StandardToken.sol

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
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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

// File: zeppelin-solidity/contracts/token/PausableToken.sol

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

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

// File: contracts/BrickblockToken.sol

contract BrickblockToken is PausableToken {

  string public constant name = "BrickblockToken";
  string public constant symbol = "BBK";
  uint256 public constant initialSupply = 500 * (10 ** 6) * (10 ** uint256(decimals));
  uint256 public companyTokens;
  uint256 public bonusTokens;
  uint8 public constant contributorsShare = 51;
  uint8 public constant companyShare = 35;
  uint8 public constant bonusShare = 14;
  uint8 public constant decimals = 18;
  address public bonusDistributionAddress;
  address public fountainContractAddress;
  bool public tokenSaleActive;
  bool public dead = false;

  event TokenSaleFinished
  (
    uint256 totalSupply,
    uint256 distributedTokens,
    uint256 bonusTokens,
    uint256 companyTokens
  );
  event Burn(address indexed burner, uint256 value);

  // This modifier is used in `distributeTokens()` and ensures that no more than 51% of the total supply can be distributed
  modifier supplyAvailable(uint256 _value) {
    uint256 _distributedTokens = initialSupply.sub(balances[this].add(bonusTokens));
    uint256 _maxDistributedAmount = initialSupply.mul(contributorsShare).div(100);
    require(_distributedTokens.add(_value) <= _maxDistributedAmount);
    _;
  }

  function BrickblockToken(address _bonusDistributionAddress)
    public
  {
    require(_bonusDistributionAddress != address(0));
    bonusTokens = initialSupply.mul(bonusShare).div(100);
    companyTokens = initialSupply.mul(companyShare).div(100);
    bonusDistributionAddress = _bonusDistributionAddress;
    totalSupply = initialSupply;
    balances[this] = initialSupply;
    Transfer(address(0), this, initialSupply);
    // distribute bonusTokens to bonusDistributionAddress
    balances[this] = balances[this].sub(bonusTokens);
    balances[bonusDistributionAddress] = balances[bonusDistributionAddress].add(bonusTokens);
    Transfer(this, bonusDistributionAddress, bonusTokens);
    // we need to start with trading paused to make sure that there can be no transfers while the token sale is still ongoing
    // we will unpause the contract manually after finalizing the token sale by calling `unpause()` which is a function inherited from PausableToken
    paused = true;
    tokenSaleActive = true;
  }

  // For worst case scenarios, e.g. when a vulnerability in this contract would be discovered and we would have to deploy a new contract
  // This is only for visibility purposes to publicly indicate that we consider this contract "dead" and don't intend to re-activate it ever again
  function toggleDead()
    external
    onlyOwner
    returns (bool)
  {
    dead = !dead;
  }

  // Helper function used in changeFountainContractAddress to ensure an address parameter is a contract and not an external address
  function isContract(address addr)
    private
    view
    returns (bool)
  {
    uint _size;
    assembly { _size := extcodesize(addr) }
    return _size > 0;
  }

  // Fountain contract address could change over time, so we need the ability to update its address
  function changeFountainContractAddress(address _newAddress)
    external
    onlyOwner
    returns (bool)
  {
    require(isContract(_newAddress));
    require(_newAddress != address(this));
    require(_newAddress != owner);
    fountainContractAddress = _newAddress;
    return true;
  }

  // Custom transfer function that enables us to distribute tokens while contract is paused. Cannot be used after end of token sale
  function distributeTokens(address _contributor, uint256 _value)
    external
    onlyOwner
    supplyAvailable(_value)
    returns (bool)
  {
    require(tokenSaleActive == true);
    require(_contributor != address(0));
    require(_contributor != owner);
    balances[this] = balances[this].sub(_value);
    balances[_contributor] = balances[_contributor].add(_value);
    Transfer(this, _contributor, _value);
    return true;
  }

  // Distribute tokens reserved for partners and staff to a wallet owned by Brickblock
  function distributeBonusTokens(address _recipient, uint256 _value)
    external
    onlyOwner
    returns (bool)
  {
    require(_recipient != address(0));
    require(_recipient != owner);
    balances[bonusDistributionAddress] = balances[bonusDistributionAddress].sub(_value);
    balances[_recipient] = balances[_recipient].add(_value);
    Transfer(bonusDistributionAddress, _recipient, _value);
    return true;
  }

  // Calculate the shares for company, bonus & contibutors based on the intial totalSupply of 500.000.000 tokens - not what is left over after burning
  function finalizeTokenSale()
    external
    onlyOwner
    returns (bool)
  {
    // ensure that sale is active. is set to false at the end. can only be performed once.
    require(tokenSaleActive == true);
    // ensure that fountainContractAddress has been set
    require(fountainContractAddress != address(0));
    // calculate new total supply. need to do this in two steps in order to have accurate totalSupply due to integer division
    uint256 _distributedTokens = initialSupply.sub(balances[this].add(bonusTokens));
    uint256 _newTotalSupply = _distributedTokens.add(bonusTokens.add(companyTokens));
    // unpurchased amount of tokens which will be burned
    uint256 _burnAmount = totalSupply.sub(_newTotalSupply);
    // leave remaining balance for company to be claimed at later date
    balances[this] = balances[this].sub(_burnAmount);
    Burn(this, _burnAmount);
    // allow our fountain contract to transfer the company tokens to itself
    allowed[this][fountainContractAddress] = companyTokens;
    Approval(this, fountainContractAddress, companyTokens);
    // set new totalSupply
    totalSupply = _newTotalSupply;
    // prevent this function from ever running again after finalizing the token sale
    tokenSaleActive = false;
    // dispatch event showing sale is finished
    TokenSaleFinished(
      totalSupply,
      _distributedTokens,
      bonusTokens,
      companyTokens
    );
    // everything went well return true
    return true;
  }

  // fallback function - do not allow any eth transfers to this contract
  function()
    external
  {
    revert();
  }

}