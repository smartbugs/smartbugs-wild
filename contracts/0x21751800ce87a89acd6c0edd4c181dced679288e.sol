pragma solidity ^0.4.25;

contract EasySmartolutionProcessor {
    address constant public smartolution = 0x2628E13a3CBDC52Ed96b4B8D6b1041D3EF3A409e;
    
    constructor () public {
    }
    
    function () external payable {
        require(msg.value == 0, "This contract doest not accept ether");
    }

    function processPayment(address _participant) external {
        EasySmartolutionInterface(smartolution).processPayment(_participant);
    }
}

contract EasySmartolutionInterface {
    function processPayment(address _address) public;
}