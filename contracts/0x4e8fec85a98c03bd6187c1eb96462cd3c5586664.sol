pragma solidity ^0.4.24;

/// @author David Li <davidli012345@gmail.com>
/// @dev basic authentication contract
/// @notice tracks list of all users
contract Authentication {
  struct User {
    bytes32 name;
    uint256 created_at;
  }
  
  event UserCreated(address indexed _address, bytes32 _name, uint256 _created_at);
  event UserUpdated(address indexed _address, bytes32 _name);
  event UserDeleted(address indexed _address);
  
  // make info public???
  mapping (address => User) private users;
  
  // public array that contains list of all users that have registered 
  address[] public allUsers;
  modifier onlyExistingUser {
    // Check if user exists or terminate

    require(!(users[msg.sender].name == 0x0));
    _;
  }

  modifier onlyValidName(bytes32 name) {
    // Only valid names allowed

    require(!(name == 0x0));
    _;
  }
  
  /// @return username
  function login() 
  public
  view 
  onlyExistingUser
  returns (bytes32) {
    return (users[msg.sender].name);
  }
  
  /// @param name the username to be created. 
  /// @dev checks if user exists
  /// If yes return user name 
  /// If no, check if name was sent 
  /// If yes, create and return user 
  /// @return username of created user
  function signup(bytes32 name)
  public
  payable
  onlyValidName(name)
  returns (bytes32) {

    if (users[msg.sender].name == 0x0)
    {
        users[msg.sender].name = name;
	    users[msg.sender].created_at = now;
        
        allUsers.push(msg.sender);
        emit UserCreated(msg.sender,name,now);
        return (users[msg.sender].name);
    }

    return (users[msg.sender].name);
  }
  
  /// @param name updating username
  /// @dev updating user name 
  /// @return updated username 
  function update(bytes32 name)
  public
  payable
  onlyValidName(name)
  onlyExistingUser
  returns (bytes32) {
    // Update user name.

    if (users[msg.sender].name != 0x0)
    {
        users[msg.sender].name = name;
        
        emit UserUpdated(msg.sender,name);
 
        return (users[msg.sender].name);
    }
  }
  
  /// @dev destroy existing username 
  function destroy () 
  public 
  onlyExistingUser {
    delete users[msg.sender];
    emit UserDeleted(msg.sender);
  }
}