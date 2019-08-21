pragma solidity 0.4.21;

// Declaring the API of external functions.
contract IJNBToken {
    function acceptOwnership() public;
    function transfer(address _to, uint _value) public returns(bool);
}


contract Ownable {
    address public owner; 
    address public newOwner; 

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner); 

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner); // Requiring that the function caller must be owner.
        _;
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(address(0) != _newOwner); 
        newOwner = _newOwner; // Setting the newOwner.
    }
    
    function acceptOwnership() public {
        require(msg.sender == newOwner); // Requiring that the caller must be newOwner.
        emit OwnershipTransferred(owner, msg.sender); // Triggering the OwnershipTransferred event.
        owner = msg.sender;
        newOwner = address(0); // Resetting the newOwner as zero.
    }
}


contract JNBOwner is Ownable{

    address public constant addr = 0x21D5A14e625d767Ce6b7A167491C2d18e0785fDa; // The address of JNB Token.
     
	function JNBOwner(address _owner) public { 
		owner = _owner; // The constructor sets owner as '_owner'.
	}

    function acceptJNBOwner() public{
        IJNBToken(addr).acceptOwnership(); // Calling external function to compelete 'transferOwnership' operation.
    }
    
    function withdrawJNB(uint256 _amount) onlyOwner public{
        require(IJNBToken(addr).transfer(owner,_amount)); // Requiring the return value of callling external function 
    }

}