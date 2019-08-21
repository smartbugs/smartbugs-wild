pragma solidity ^0.4.18;




contract DocumentRegistry {




	mapping(string => uint256) registry;




	function register(string hash) public {
		
		//REQUIRE THAT THE HASH HAS NOT BEEN REGISTERED BEFORE
		require(registry[hash] == 0);
		
		//REGISTER NEW HASH WITH CURRENT BLOCK'S TIMESTAMP
		registry[hash] = block.timestamp;
	}




	function check(string hash) public constant returns (uint256) {
		return registry[hash];
	}
}