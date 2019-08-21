/**
 * Social Remit Contract Airdrop
 * Developer: Nechesov Andrey 
 * Skype: Nechesov
 * Telegram: @nechesoff
 * Facebook: http://fb.com/nechesov
*/

pragma solidity ^0.5.10;        
   
contract Airdrop {     	

	address public c = 0x7a0e91c4204355e0A6bBf746dc0B7E32dFEFDecf; 
	address payable public owner;	
	
	mapping (uint => address) public a;	
	

	constructor() public{
        owner = msg.sender;                
    }

	function() payable external{    

	}

	function transfer(uint _sreur_tokens, address[] memory _addresses) onlyOwner public returns (bool) {      
		
		require (_sreur_tokens > 0);		
    	uint amount = _sreur_tokens*100000000;

		for (uint i = 0; i < _addresses.length; i++) {
			//c.call(bytes4(sha3("transfer(address,uint256)")),_addresses[i], amount);				
			(bool success,) = address(c).call(abi.encodeWithSignature("transfer(address,uint256)", _addresses[i], amount));                  
          	require(success);
		}  
	  
	  return true;
	} 
	
	function withdraw() onlyOwner public returns (bool result) {
	  owner.transfer(address(this).balance);
	  return true;
	}
	
    modifier onlyOwner() {
        require (msg.sender == owner);
        _;
    }       

}