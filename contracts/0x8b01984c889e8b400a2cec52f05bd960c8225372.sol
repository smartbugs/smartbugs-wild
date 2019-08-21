// Automatically forwards any funds received back to the sender
pragma solidity ^0.4.0;
contract NoopTransfer {
    address owner;
    
    function NoopTransfer() public {
        owner = msg.sender;
    }

    function () public payable {
        msg.sender.transfer(this.balance);
    }
    
    function kill() public {
        require(msg.sender == owner);
        selfdestruct(owner);
    }
}