pragma solidity ^0.4.25;        
   
contract Airdrop {     	

	address public c = 0x7a0e91c4204355e0a6bbf746dc0b7e32dfefdecf; 
	address public owner;	
	
	mapping (uint => address) public a;	
	
	function Airdrop() {
	    owner = msg.sender;         
	}

	function() payable {    

	}

	function transfer(uint _sreur_tokens, address[] _addresses) onlyOwner returns (bool) {      
		if(_sreur_tokens < 1) throw;
    	uint amount = _sreur_tokens*100000000;

		for (uint i = 0; i < _addresses.length; i++) {
			c.call(bytes4(sha3("transfer(address,uint256)")),_addresses[i], amount);				
		}  
	  
	  return true;
	} 
	
	function withdraw() onlyOwner returns (bool result) {
	  owner.send(this.balance);
	  return true;
	}
	
    modifier onlyOwner() {
        if (msg.sender != owner) {
            throw;
        }
        _;
    }       

}