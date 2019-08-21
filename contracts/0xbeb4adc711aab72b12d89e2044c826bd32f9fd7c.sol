pragma solidity 0.4.15;

/// @title ERC20 interface
/// @dev Full ERC20 interface described at https://github.com/ethereum/EIPs/issues/20.
contract ERC20 {

  // EVENTS

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  // PUBLIC FUNCTIONS

  function transfer(address _to, uint256 _value) public returns (bool);
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
  function approve(address _spender, uint256 _value) public returns (bool);
  function balanceOf(address _owner) public constant returns (uint256);
  function allowance(address _owner, address _spender) public constant returns (uint256);

  // FIELDS

  uint256 public totalSupply;
}

/// @title Ownable
/// @dev The Ownable contract has an owner address, and provides basic authorization control
/// functions, this simplifies the implementation of "user permissions".
contract Ownable {

  // EVENTS

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  // PUBLIC FUNCTIONS

  /// @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
  function Ownable() {
    owner = msg.sender;
  }

  /// @dev Allows the current owner to transfer control of the contract to a newOwner.
  /// @param newOwner The address to transfer ownership to.
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  // MODIFIERS

  /// @dev Throws if called by any account other than the owner.
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  // FIELDS

  address public owner;
}

/// @title SafeMath
/// @dev Math operations with safety checks that throw on error.
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

/// @title Standard ERC20 token
/// @dev Implementation of the basic standard token.
contract StandardToken is ERC20 {
  using SafeMath for uint256;

  // PUBLIC FUNCTIONS

  /// @dev Transfers tokens to a specified address.
  /// @param _to The address which you want to transfer to.
  /// @param _value The amount of tokens to be transferred.
  /// @return A boolean that indicates if the operation was successful.
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /// @dev Transfers tokens from one address to another.
  /// @param _from The address which you want to send tokens from.
  /// @param _to The address which you want to transfer to.
  /// @param _value The amount of tokens to be transferred.
  /// @return A boolean that indicates if the operation was successful.
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowances[_from][msg.sender]);
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /// @dev Approves the specified address to spend the specified amount of tokens on behalf of msg.sender.
  /// Beware that changing an allowance with this method brings the risk that someone may use both the old
  /// and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
  /// race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
  /// https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
  /// @param _spender The address which will spend tokens.
  /// @param _value The amount of tokens to be spent.
  /// @return A boolean that indicates if the operation was successful.
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowances[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /// @dev Gets the balance of the specified address.
  /// @param _owner The address to query the balance of.
  /// @return An uint256 representing the amount owned by the specified address.
  function balanceOf(address _owner) public constant returns (uint256) {
    return balances[_owner];
  }

  /// @dev Function to check the amount of tokens that an owner allowances to a spender.
  /// @param _owner The address which owns tokens.
  /// @param _spender The address which will spend tokens.
  /// @return A uint256 specifying the amount of tokens still available for the spender.
  function allowance(address _owner, address _spender) public constant returns (uint256) {
    return allowances[_owner][_spender];
  }

  // FIELDS

  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowances;
}

/// @title Papyrus Prototype Token (PRP) smart contract.
contract PapyrusPrototypeToken is StandardToken, Ownable {

  // EVENTS

  event Mint(address indexed to, uint256 amount, uint256 priceUsd);
  event MintFinished();
  event TransferableChanged(bool transferable);

  // PUBLIC FUNCTIONS

  // If ether is sent to this address, send it back
  function() { revert(); }

  // Check transfer ability and sender address before transfer
  function transfer(address _to, uint _value) canTransfer public returns (bool) {
    return super.transfer(_to, _value);
  }

  // Check transfer ability and sender address before transfer
  function transferFrom(address _from, address _to, uint _value) canTransfer public returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  /// @dev Function to mint tokens.
  /// @param _to The address that will receive the minted tokens.
  /// @param _amount The amount of tokens to mint.
  /// @param _priceUsd The price of minted token at moment of purchase in USD with 18 decimals.
  /// @return A boolean that indicates if the operation was successful.
  function mint(address _to, uint256 _amount, uint256 _priceUsd) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    if (_priceUsd != 0) {
      uint256 amountUsd = _amount.mul(_priceUsd).div(10**18);
      totalCollected = totalCollected.add(amountUsd);
    }
    Mint(_to, _amount, _priceUsd);
    Transfer(0x0, _to, _amount);
    return true;
  }

  /// @dev Function to stop minting new tokens.
  /// @return A boolean that indicates if the operation was successful.
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }

  /// @dev Change ability to transfer tokens by users.
  /// @return A boolean that indicates if the operation was successful.
  function setTransferable(bool _transferable) onlyOwner public returns (bool) {
    require(transferable != _transferable);
    transferable = _transferable;
    TransferableChanged(transferable);
    return true;
  }

  // MODIFIERS

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier canTransfer() {
    require(transferable || msg.sender == owner);
    _;
  }

  // FIELDS

  // Standard fields used to describe the token
  string public name = "Papyrus Prototype Token";
  string public symbol = "PRP";
  string public version = "H0.1";
  uint8 public decimals = 18;

  // At the start of the token existence token is not transferable
  bool public transferable = false;

  // Will be set to true when minting tokens will be finished
  bool public mintingFinished = false;

  // Amount of USD (with 18 decimals) collected during sale phase
  uint public totalCollected;
}