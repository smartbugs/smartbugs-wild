pragma solidity ^0.4.18;

/// @title Ownable contract
library SafeMath {

  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a / b;
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

/// @title Ownable contract
contract Ownable {
  
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /// @dev Change ownership
  /// @param newOwner Address of the new owner
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/// @title Pausable contract
contract Pausable is Ownable {

  /// Used to pause transfers
  bool public transferPaused;
  address public crowdsale;
  
  function Pausable() public {
    transferPaused = false;
    crowdsale = msg.sender; // or address(0)
  }

  /// Crowdsale is the only one allowed to do transfers if transfer is paused
  modifier onlyCrowdsaleIfPaused() {
    if (transferPaused) {
      require(msg.sender == crowdsale);
    }
    _;
  }

  /// @dev Change crowdsale address reference
  /// @param newCrowdsale Address of the new crowdsale
  function changeCrowdsale(address newCrowdsale) onlyOwner public {
    require(newCrowdsale != address(0));
    CrowdsaleChanged(crowdsale, newCrowdsale);
    crowdsale = newCrowdsale;
  }

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

  event Pause();
  event Unpause();
  event CrowdsaleChanged(address indexed previousCrowdsale, address indexed newCrowdsale);

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
contract ExtendedToken is ERC20, Pausable {
  using SafeMath for uint;

  /// Mapping for balances
  mapping (address => uint) public balances;
  /// Mapping for allowance
  mapping (address => mapping (address => uint)) internal allowed;

  /// @dev Any unsold tokens from ICO will be sent to owner address and burned
  /// @param _amount Amount of tokens to be burned from owner address
  /// @return True if successfully burned
  function burn(uint _amount) public onlyOwner returns (bool) {
	  require(balances[msg.sender] >= _amount);     
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    totalSupply = totalSupply.sub(_amount);
    Burn(msg.sender, _amount);
    return true;
  }

  /// @dev Used by transfer function
  function _transfer(address _from, address _to, uint _value) internal onlyCrowdsaleIfPaused {
    require(_to != address(0));
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
    require(_value <= allowed[_from][msg.sender]);
    _transfer(_from, _to, _value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
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
  event Burn(address _from, uint _amount);
  event ClaimedTokens(address indexed _token, address indexed _owner, uint _amount);

}

/// @title Cultural Coin Token contract
contract CulturalCoinToken is ExtendedToken {
  string public constant name = "Cultural Coin Token";
  string public constant symbol = "CC";
  uint8 public constant decimals = 18;
  string public constant version = "v1";

  function CulturalCoinToken() public { 
    totalSupply = 1500 * 10**24;    // 1500m tokens
    balances[owner] = totalSupply;  // Tokens will be initially set to the owner account. From there 900m will be sent to Crowdsale
  }

}