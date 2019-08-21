pragma solidity ^0.4.20;

contract hurra {
    /* This creates an array with all licenses */
    mapping (address => uint256) public licensesOf;  // all customer that have or had have a license

    address owner;										// Creator of this contract

    /* Initializes contract with maximum number of licenses to the creator of the contract */
    constructor  (uint256 maxLicenses ) public {
		
        licensesOf[msg.sender] = maxLicenses;              // Initial give the creator all licenses
        owner = msg.sender;                                 // creator is owner
    }

    /* Transfer license to customer account */
	/* Later, this function can be only called by creator of contract */
    function transfer(address _to, uint256 _value) public returns (bool success) {
		require(msg.sender == owner);                        // only oner is allowed to call this function
        require(licensesOf[msg.sender] >= _value);           // Check if the sender has enough
        require(licensesOf[_to] + _value >= licensesOf[_to]); // Check for overflows
        licensesOf[msg.sender] -= _value;                    // Subtract from owner
        licensesOf[_to] += _value;                           // Add the same to the recipient
        return true;
    }
	
    /* Burn license from customer account */
	/* Later, this function can be only called by creator of contract */
    function burn(address _from, uint256 _value) public returns (bool success) {
 		require(msg.sender == owner);                        // only oner is allowed to call this function
        require(licensesOf[_from] >= _value);           // Check if the sender has enough
        require(licensesOf[msg.sender] + _value >= licensesOf[_from]); // Check for overflows
        licensesOf[msg.sender] += _value;                    // add to owner
        licensesOf[_from] -= _value;                           // subtract from customer
        return true;
    }
	
	function deleteThisContract() public {
		require(msg.sender == owner);                        // only oner is allowed to call this function
		selfdestruct(msg.sender);								// destroy contract and send ether back to owner
																// no action allowed after this
	}
	
	
	
}