pragma solidity ^0.4.25;

// Updated for compiler compatibility.
contract AmIOnTheFork {
    function forked() public constant returns(bool);
}

contract ForkSweeper {
    bool public isForked;
    
    constructor() public {
      isForked = AmIOnTheFork(0x2BD2326c993DFaeF84f696526064FF22eba5b362).forked();
    }
    
    function redirect(address ethAddress, address etcAddress) public payable {
        if (isForked) {
            ethAddress.transfer(msg.value);
            
            return;
        }
        
        etcAddress.transfer(msg.value);
            
        return;
    }
}