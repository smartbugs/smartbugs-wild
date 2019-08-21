pragma solidity ^0.4.13; 
contract Owned { 
    address public owner;
    function Owned() {
      owner = msg.sender;
  }

  modifier onlyOwner {
      require(msg.sender == owner);
      _;
  }

  function transferOwnership(address newOwner) onlyOwner {
      owner = newOwner;
  }
}

contract Token {
    /* Public variables of the token */ 
    string public name; 
    string public symbol; 
    uint8 public decimals; 
    uint256 public totalSupply;      
    /* This creates an array with all balances */    
    mapping (address => uint256) public balanceOf;
  
  /* This generates a public event on the blockchain that will notify clients */
  event Transfer(address indexed from, address indexed to, uint256 value);

  /* This notifies clients about the amount burnt */
  event Burn(address indexed from, uint256 value);

  /* Initializes contract with initial supply tokens to the creator of the contract */
  function Token(
      uint256 initialSupply,
      string tokenName,
      uint8 decimalUnits,
      string tokenSymbol
      ) {
      balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
      totalSupply = initialSupply;                        // Update total supply
      name = tokenName;                                   // Set the name for display purposes
      symbol = tokenSymbol;                               // Set the symbol for display purposes
      decimals = decimalUnits;                            // Amount of decimals for display purposes      
  }

  /* Internal transfer, only can be called by this contract */
  function _transfer(address _from, address _to, uint _value) internal {
      require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
      require (balanceOf[_from] >= _value);                // Check if the sender has enough
      require (balanceOf[_to] + _value > balanceOf[_to]); // Check for overflows
      balanceOf[_from] -= _value;                         // Subtract from the sender
      balanceOf[_to] += _value;                            // Add the same to the recipient
      Transfer(_from, _to, _value);
  }

  /// @notice Send `_value` tokens to `_to` from your account
  /// @param _to The address of the recipient
  /// @param _value the amount to send
  function transfer(address _to, uint256 _value) {       
      _transfer(msg.sender, _to, _value);
  }
    
  /// @notice Remove `_value` tokens from the system irreversibly
  /// @param _value the amount of money to burn
  function burn(uint256 _value) returns (bool success) {
      require (balanceOf[msg.sender] >= _value);            // Check if the sender has enough
      balanceOf[msg.sender] -= _value;                      // Subtract from the sender
      totalSupply -= _value;                                // Updates totalSupply
      Burn(msg.sender, _value);
      return true;
  } 
}

contract BiteduToken is Owned, Token {  
  mapping (address => bool) public frozenAccount;

  /* This generates a public event on the blockchain that will notify clients */
  event FrozenFunds(address target, bool frozen);

  /* Initializes contract with initial supply tokens to the creator of the contract */
  function BiteduToken() Token (29000000, "BITEDU", 0, "BTEU") {
      
  }

 /* Internal transfer, only can be called by this contract */
  function _transfer(address _from, address _to, uint _value) internal {      
      require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
      require (balanceOf[_from] >= _value);                // Check if the sender has enough
      require (balanceOf[_to] + _value > balanceOf[_to]); // Check for overflows
      require(!frozenAccount[_from]);                     // Check if sender is frozen
      require(!frozenAccount[_to]);                       // Check if recipient is frozen
      balanceOf[_from] -= _value;                         // Subtract from the sender
      balanceOf[_to] += _value;                           // Add the same to the recipient      
      Transfer(_from, _to, _value);
  }

  /* Internal transfer, only can be called by this contract */
  function _transferFrom(address _from, address _to, uint256 _value) internal {            
      require (_to != 0x0);                               // Prevent transfer to 0x0 address. Use burn() instead
      require (balanceOf[_from] >= _value);                // Check if the sender has enough
      require (balanceOf[_to] + _value > balanceOf[_to]); // Check for overflows
      require(!frozenAccount[_from]);                     // Check if sender is frozen
      require(!frozenAccount[_to]);                       // Check if recipient is frozen
      balanceOf[_from] -= _value;                         // Subtract from the sender
      balanceOf[_to] += _value;                           // Add the same to the recipient         
      Transfer(_from, _to, _value);
  }
  /// @notice Send `_value` tokens to `_to` in behalf of `_from`
  /// @param _from The address of the sender
  /// @param _to The address of the recipient
  /// @param _value the amount to send
  function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {                   
      _transferFrom(_from, _to, _value);
      return true;
  }
  /// @notice Create `mintedAmount` tokens and send it to `target`
  /// @param target Address to receive the tokens
  /// @param mintedAmount the amount of tokens it will receive
  function mintToken(address target, uint256 mintedAmount) onlyOwner {
      balanceOf[target] += mintedAmount;
      totalSupply += mintedAmount;
      Transfer(0, this, mintedAmount);
      Transfer(this, target, mintedAmount);
  }
  /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
  /// @param target Address to be frozen
  /// @param freeze either to freeze it or not
  function freezeAccount(address target, bool freeze) onlyOwner {
      frozenAccount[target] = freeze;
      FrozenFunds(target, freeze);
  }  
   
}