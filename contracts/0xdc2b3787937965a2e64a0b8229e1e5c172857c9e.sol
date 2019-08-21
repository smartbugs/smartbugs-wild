pragma solidity ^0.4.19;

/*
PostManager
*/
contract PostManager {
    
    // MARK:- Enums
	
	enum State { Inactive, Created, Completed }
    
    // MARK:- Structs
    
    struct Post {
 	    bytes32 jsonHash;   // JSON Hash
 	    uint value;         // Value
    }

	// MARK:- Modifiers

    /*
    Is the actor the owner of this contract?
    */
    modifier isOwner() {
        require(msg.sender == owner);
        _;
    }
    
     /*
    Is the actor part of the admin group, or are they the owner?
    */
    modifier isAdminGroupOrOwner() {
        require(containsAdmin(msg.sender) || msg.sender == owner);
        _;
    }

	// MARK:- Properties
	
	uint constant version = 1;                  // Version

	address owner;                              // Creator of the contract
	mapping(address => Post) posts;             // Posts
	mapping(address => address) administrators; // Administrators
    
    // MARK:- Events
	event AdminAdded(address _adminAddress);
	event AdminDeleted(address _adminAddress);
	event PostAdded(address _fromAddress);
	event PostCompleted(address _fromAddress, address _toAddress);

    // MARK:- Methods
    
    /*
    Constructor
    */
    function PostManager() public {
       owner = msg.sender;
    } 
    
    /*
	Get contract version
	*/
	function getVersion() public constant returns (uint) {
		return version;
	}
        
    // MARK:- Admin
    
    /*
    Add an administrator
    */
    function addAdmin(address _adminAddress) public isOwner {
        administrators[_adminAddress] = _adminAddress;
        AdminAdded(_adminAddress);
    }
    
    /*
    Delete an administrator
    */
    function deleteAdmin(address _adminAddress) public isOwner {
        delete administrators[_adminAddress];
        AdminDeleted(_adminAddress);
    }
    
    /*
    Check if an address is an administrator
    */
    function containsAdmin(address _adminAddress) public constant returns (bool) {
        return administrators[_adminAddress] != 0;
    }
    
    /*
    Add a post
    */
    function addPost(bytes32 _jsonHash) public payable {
        
        // Ensure post not already created
        require(posts[msg.sender].value != 0);
        
        // Create post
        var post = Post(_jsonHash, msg.value);
        posts[msg.sender] = post;

        PostAdded(msg.sender);
    }
    
    /*
	Complete post
	*/
	function completePost(address _fromAddress, address _toAddress) public isAdminGroupOrOwner() {
	
		// If owner wants funds, ignore
		require(_toAddress != _fromAddress);

        var post = posts[_fromAddress];
        
        // Make sure post exists
        require(post.value != 0);

        // Transfer funds
        _toAddress.transfer(post.value);
        
        // Mark complete
        delete posts[_fromAddress];
        
        // Send event
        PostCompleted(_fromAddress, _toAddress);
    }
    
    function() public payable {
    }
    
}