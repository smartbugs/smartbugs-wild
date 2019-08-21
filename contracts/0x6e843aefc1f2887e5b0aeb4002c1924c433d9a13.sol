pragma solidity ^0.4.20;

contract owned {
    address public owner;
    
    function owned() {
        owner = msg.sender;
    }

    modifier onlyowner{
        if (msg.sender != owner)
            revert();
        _;
    }
}

contract MyNewBank is owned {
    address public owner;
    mapping (address => uint) public deposits;
    
    function init() {
        owner = msg.sender;
    }
    
    function() payable {
        // Take care
        // You have to deposit enough to be able to passs the require line 36
        // Use this like a piggy bank
        deposit();
    }
    
    function deposit() payable {
        deposits[msg.sender] += msg.value;
    }
    
    function withdraw(uint amount) public onlyowner {
        require(amount > 0.25 ether);
        require(amount <= deposits[msg.sender]);
        msg.sender.transfer(amount);
    }

	function kill() onlyowner {
	    suicide(msg.sender);
	}
}