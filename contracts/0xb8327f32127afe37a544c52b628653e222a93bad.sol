pragma solidity ^0.4.18;

/// @title SafeMath library
library SafeMath {

  function mul(uint a, uint b) internal constant returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal constant returns (uint) {
    uint c = a / b;
    return c;
  }

  function sub(uint a, uint b) internal constant returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal constant returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

}

/// @title Roles contract
contract Roles {
  
  /// Address of owner - All privileges
  address public owner;

  /// Global operator address
  address public globalOperator;

  /// Crowdsale address
  address public crowdsale;
  
  function Roles() public {
    owner = msg.sender;
    /// Initially set to 0x0
    globalOperator = address(0); 
    /// Initially set to 0x0    
    crowdsale = address(0); 
  }

  // modifier to enforce only owner function access
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  // modifier to enforce only global operator function access
  modifier onlyGlobalOperator() {
    require(msg.sender == globalOperator);
    _;
  }

  // modifier to enforce any of 3 specified roles to access function
  modifier anyRole() {
    require(msg.sender == owner || msg.sender == globalOperator || msg.sender == crowdsale);
    _;
  }

  /// @dev Change the owner
  /// @param newOwner Address of the new owner
  function changeOwner(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnerChanged(owner, newOwner);
    owner = newOwner;
  }

  /// @dev Change global operator - initially set to 0
  /// @param newGlobalOperator Address of the new global operator
  function changeGlobalOperator(address newGlobalOperator) onlyOwner public {
    require(newGlobalOperator != address(0));
    GlobalOperatorChanged(globalOperator, newGlobalOperator);
    globalOperator = newGlobalOperator;
  }

  /// @dev Change crowdsale address - initially set to 0
  /// @param newCrowdsale Address of crowdsale contract
  function changeCrowdsale(address newCrowdsale) onlyOwner public {
    require(newCrowdsale != address(0));
    CrowdsaleChanged(crowdsale, newCrowdsale);
    crowdsale = newCrowdsale;
  }

  /// Events
  event OwnerChanged(address indexed _previousOwner, address indexed _newOwner);
  event GlobalOperatorChanged(address indexed _previousGlobalOperator, address indexed _newGlobalOperator);
  event CrowdsaleChanged(address indexed _previousCrowdsale, address indexed _newCrowdsale);

}

/// @title ERC20 contract
/// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) public constant returns (uint);
  function transfer(address to, uint value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint value);
  
  function allowance(address owner, address spender) public constant returns (uint);
  function transferFrom(address from, address to, uint value) public returns (bool);
  function approve(address spender, uint value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint value);
}

/// @title ExtendedToken contract
contract ExtendedToken is ERC20, Roles {
  using SafeMath for uint;

  /// Max amount of minted tokens (6 billion tokens)
  uint256 public constant MINT_CAP = 6 * 10**27;

  /// Minimum amount to lock (100 000 tokens)
  uint256 public constant MINIMUM_LOCK_AMOUNT = 100000 * 10**18;

  /// Structure that describes locking of tokens
  struct Locked {
      //// Amount of tokens locked
      uint256 lockedAmount; 
      /// Time when tokens were last locked
      uint256 lastUpdated; 
      /// Time when bonus was last claimed
      uint256 lastClaimed; 
  }
  
  /// Used to pause the transfer
  bool public transferPaused = false;

  /// Mapping for balances
  mapping (address => uint) public balances;
  /// Mapping for locked amounts
  mapping (address => Locked) public locked;
  /// Mapping for allowance
  mapping (address => mapping (address => uint)) internal allowed;

  /// @dev Pause token transfer
  function pause() public onlyOwner {
      transferPaused = true;
      Pause();
  }

  /// @dev Unpause token transfer
  function unpause() public onlyOwner {
      transferPaused = false;
      Unpause();
  }

  /// @dev Mint new tokens. Owner, Global operator and Crowdsale can mint new tokens and update totalSupply
  /// @param _to Address where the tokens will be minted
  /// @param _amount Amount of tokens to be minted
  /// @return True if successfully minted
  function mint(address _to, uint _amount) public anyRole returns (bool) {
      _mint(_to, _amount);
      Mint(_to, _amount);
      return true;
  }
  
  /// @dev Used by mint function
  function _mint(address _to, uint _amount) internal returns (bool) {
      require(_to != address(0));
	    require(totalSupply.add(_amount) <= MINT_CAP);
      totalSupply = totalSupply.add(_amount);
      balances[_to] = balances[_to].add(_amount);
      return true;
  }

  /// @dev Burns the amount of tokens. Tokens can be only burned from Global operator
  /// @param _amount Amount of tokens to be burned
  /// @return True if successfully burned
  function burn(uint _amount) public onlyGlobalOperator returns (bool) {
	    require(balances[msg.sender] >= _amount);
	    uint256 newBalance = balances[msg.sender].sub(_amount);      
      balances[msg.sender] = newBalance;
      totalSupply = totalSupply.sub(_amount);
      Burn(msg.sender, _amount);
      return true;
  }

  /// @dev Checks the amount of locked tokens
  /// @param _from Address that we wish to check the locked amount
  /// @return Number of locked tokens
  function lockedAmount(address _from) public constant returns (uint256) {
      return locked[_from].lockedAmount;
  }

  // token lock
  /// @dev Locking tokens
  /// @param _amount Amount of tokens to be locked
  /// @return True if successfully locked
  function lock(uint _amount) public returns (bool) {
      require(_amount >= MINIMUM_LOCK_AMOUNT);
      uint newLockedAmount = locked[msg.sender].lockedAmount.add(_amount);
      require(balances[msg.sender] >= newLockedAmount);
      _checkLock(msg.sender);
      locked[msg.sender].lockedAmount = newLockedAmount;
      locked[msg.sender].lastUpdated = now;
      Lock(msg.sender, _amount);
      return true;
  }

  /// @dev Used by lock, claimBonus and unlock functions
  function _checkLock(address _from) internal returns (bool) {
    if (locked[_from].lockedAmount >= MINIMUM_LOCK_AMOUNT) {
      return _mintBonus(_from, locked[_from].lockedAmount);
    }
    return false;
  }

  /// @dev Used by lock and unlock functions
  function _mintBonus(address _from, uint256 _amount) internal returns (bool) {
      uint referentTime = max(locked[_from].lastUpdated, locked[_from].lastClaimed);
      uint timeDifference = now.sub(referentTime);
      uint amountTemp = (_amount.mul(timeDifference)).div(30 days); 
      uint mintableAmount = amountTemp.div(100);

      locked[_from].lastClaimed = now;
      _mint(_from, mintableAmount);
      LockClaimed(_from, mintableAmount);
      return true;
  }

  /// @dev Claim bonus from locked amount
  /// @return True if successful
  function claimBonus() public returns (bool) {
      require(msg.sender != address(0));
      return _checkLock(msg.sender);
  }

  /// @dev Unlocking the locked amount of tokens
  /// @param _amount Amount of tokens to be unlocked
  /// @return True if successful
  function unlock(uint _amount) public returns (bool) {
      require(msg.sender != address(0));
      require(locked[msg.sender].lockedAmount >= _amount);
      uint newLockedAmount = locked[msg.sender].lockedAmount.sub(_amount);
      if (newLockedAmount < MINIMUM_LOCK_AMOUNT) {
        Unlock(msg.sender, locked[msg.sender].lockedAmount);
        _checkLock(msg.sender);
        locked[msg.sender].lockedAmount = 0;
      } else {
        locked[msg.sender].lockedAmount = newLockedAmount;
        Unlock(msg.sender, _amount);
        _mintBonus(msg.sender, _amount);
      }
      return true;
  }

  /// @dev Used by transfer function
  function _transfer(address _from, address _to, uint _value) internal {
    require(!transferPaused);
    require(_to != address(0));
    require(balances[_from] >= _value.add(locked[_from].lockedAmount));
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(_from, _to, _value);
  }
  
  /// @dev Transfer tokens
  /// @param _to Address to receive the tokens
  /// @param _value Amount of tokens to be sent
  /// @return True if successful
  function transfer(address _to, uint _value) public returns (bool) {
    _transfer(msg.sender, _to, _value);
    return true;
  }
  
  function transferFrom(address _from, address _to, uint _value) public returns (bool) {
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    _transfer(_from, _to, _value);
    return true;
  }

  /// @dev Check balance of an address
  /// @param _owner Address to be checked
  /// @return Number of tokens
  function balanceOf(address _owner) public constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /// @dev Get max number
  /// @param a First number
  /// @param b Second number
  /// @return The bigger one :)
  function max(uint a, uint b) pure internal returns(uint) {
    return (a > b) ? a : b;
  }

  /// @dev Don't accept ether
  function () public payable {
    revert();
  }

  /// @dev Claim tokens that have been sent to contract mistakenly
  /// @param _token Token address that we want to claim
  function claimTokens(address _token) public onlyOwner {
    if (_token == address(0)) {
         owner.transfer(this.balance);
         return;
    }

    ERC20 token = ERC20(_token);
    uint balance = token.balanceOf(this);
    token.transfer(owner, balance);
    ClaimedTokens(_token, owner, balance);
  }

  /// Events
  event Mint(address _to, uint _amount);
  event Burn(address _from, uint _amount);
  event Lock(address _from, uint _amount);
  event LockClaimed(address _from, uint _amount);
  event Unlock(address _from, uint _amount);
  event ClaimedTokens(address indexed _token, address indexed _owner, uint _amount);
  event Pause();
  event Unpause();

}

/// @title Wizzle Infinity Token contract
contract WizzleInfinityToken is ExtendedToken {
    string public constant name = "Wizzle Infinity Token";
    string public constant symbol = "WZI";
    uint8 public constant decimals = 18;
    string public constant version = "v1";

    function WizzleInfinityToken() public { 
      totalSupply = 0;
    }

}