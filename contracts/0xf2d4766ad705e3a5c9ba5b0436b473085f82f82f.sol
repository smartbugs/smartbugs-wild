pragma solidity ^0.4.24;

contract Ownable {

    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {                                                
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));                                    // to ensure the owner's address isn't an uninitialised address, "0x0"
        owner = newOwner;
    }
}

contract WarmWallet is Ownable {
    
    address defaultSweeper;

    mapping (address => address) sweepers;
    mapping (address => bool) financeFolks;
    mapping (address => bool) destinations;
    mapping (address => bytes32) dstLabels;
    mapping (address => uint256) dstIndex;
    address[] public destKeys;

    constructor() public {
        owner = msg.sender;
    }

    function sweeperOf(address asset) public view returns (address) {
    	if (sweepers[asset] == 0x0) {
    		return defaultSweeper;
    	}
    	return sweepers[asset];
    }

    function setDefaultSweeper(address sweeper) public onlyOwner {
    	defaultSweeper = sweeper;
    }

    function setSweeper(address asset, address sweeper) public onlyOwner {
    	sweepers[asset] = sweeper;
    }

    function authorizeAddress(address actor) public onlyOwner {
    	financeFolks[actor] = true;
    }

    function revokeAuthorization(address actor) public onlyOwner {
    	financeFolks[actor] = false;
    }

    function isAuthorized(address actor) public view returns (bool) {
    	return financeFolks[actor];
    }

    function addDestination(address dest, bytes32 label) public onlyOwner {
    	require(destinations[dest] == false);
    	destinations[dest] = true;
    	dstIndex[dest] = destKeys.length;
    	destKeys.push(dest);
    	dstLabels[dest] = label;
    }

    function removeDestination(address dest) public onlyOwner {
    	require(destinations[dest] == true);
    	destinations[dest] = false;
    	delete dstLabels[dest];
    	uint256 keyindex = dstIndex[dest];
    	delete destKeys[keyindex];
    	delete dstIndex[dest];
    }

    function isDestination(address dest) public view returns (bool) {
    	return destinations[dest];
    }

    function destinationLabel(address dest) public view returns (string) {
    	bytes memory bytesArray = new bytes(32);
    	for (uint256 i; i < 32; i++) {
        	bytesArray[i] = dstLabels[dest][i];
        }
    	return string(bytesArray);
    }

    function () public payable { 
        if (msg.value == 0 && financeFolks[msg.sender] == true) {
            address destination = addressAtIndex(msg.data, 2);
            require(destinations[destination] == true);

            address asset = addressAtIndex(msg.data, 1);
            address _impl = sweeperOf(asset);
            require(_impl != 0x0);
            bytes memory data = msg.data;

    		assembly {
    			let result := delegatecall(gas, _impl, add(data, 0x20), mload(data), 0, 0)
    			let size := returndatasize
    			let ptr := mload(0x40)
    			returndatacopy(ptr, 0, size)
    			switch result
    			case 0 { revert(ptr, size) }
    			default { return(ptr, size) }
    		}
        }
    }

    function addressAtIndex(bytes _bytes, uint256 index) internal pure returns (address asset) {
        assembly {
            // mul(32, index) - Each param is 32 bytes, so we use n*32
            // add(4, ^) - 4 function sig bytes
            // add(_bytes, ^) - set the pointer to that position in memory
            // mload(^) - load an addresses worth of value (20 bytes) from memory into asset
            asset := mload(add(_bytes, add(4, mul(32, index))))
        }
    }

}