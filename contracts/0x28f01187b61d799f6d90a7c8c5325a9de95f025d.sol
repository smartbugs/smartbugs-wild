pragma solidity ^0.4.11;
/*
Token Contract with batch assignments

ERC-20 Token Standar Compliant

Contract developer: Fares A. Akel C.
f.antonio.akel@gmail.com
MIT PGP KEY ID: 078E41CB
*/

 contract token {

 	function transfer(address _to, uint256 _value) returns (bool); 
 
 }


/**
 * This contract is administered
 */

contract admined {
    address public admin; //Admin address is public
    /**
    * @dev This constructor set the initial admin of the contract
    */
    function admined() internal {
        admin = msg.sender; //Set initial admin to contract creator
        Admined(admin);
    }

    modifier onlyAdmin() { //A modifier to define admin-only functions
        require(msg.sender == admin);
        _;
    }

    /**
    * @dev Transfer the adminship of the contract
    * @param _newAdmin The address of the new admin.
    */
    function transferAdminship(address _newAdmin) onlyAdmin public { //Admin can be transfered
        require(_newAdmin != address(0));
        admin = _newAdmin;
        TransferAdminship(admin);
    }

    //All admin actions have a log for public review
    event TransferAdminship(address newAdmin);
    event Admined(address administrador);
}

contract Sender is admined {
    
    token public DEEM;
    
	function Sender (token _addressOfToken) public {
		DEEM = _addressOfToken; 
	}

    function batch(address[] _data, uint256 _amount) onlyAdmin public { //It takes an array of addresses and an amount
        for (uint i=0; i<_data.length; i++) { //It moves over the array
            require(DEEM.transfer(_data[i], _amount));
        }
    }

    function() public {
        revert();
    }
}