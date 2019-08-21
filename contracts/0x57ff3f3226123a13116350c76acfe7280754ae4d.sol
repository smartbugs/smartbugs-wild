pragma solidity ^0.5.1;

/**
 * Followine - Coil. More info www.followine.io
**/

contract CoilChecker {

	mapping (uint256 => bool) coils;
	address owner;

	constructor() public {
        owner = msg.sender;
    }

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

    function addCoil(uint256 _id) public onlyOwner {
        coils[_id] = true;
    }

	function changeOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }

	function removeCoil(uint256 _id) public onlyOwner {
        coils[_id] = false;
    }

	function getCoil(uint256 _id) public view returns (bool coilStatus) {
        return coils[_id];
    }

}