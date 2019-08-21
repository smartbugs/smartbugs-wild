pragma solidity ^0.4.8;

contract TimeLockSend {
    address sender;
    address recipient;
    uint256 created;
    uint256 deadline;
    
    function TimeLockSend(address _sender, address _recipient, uint256 _deadline) payable {
        if (msg.value <= 0) {
            throw;
        }
        sender = _sender;
        recipient = _recipient;
        created = now;
        deadline = _deadline;
    }
    
    function withdraw() {
        if (msg.sender == recipient) {
            selfdestruct(recipient);
        } else if (msg.sender == sender && now > deadline) {
            selfdestruct(sender);
        } else {
            throw;
        }
    }
    
    function () {
        throw;
    }
}

contract SafeSender {
    address owner;
    
    event TimeLockSendCreated(
        address indexed sender, 
        address indexed recipient, 
        uint256 deadline,
        address safeSendAddress
    );
    
    function SafeSender() {
        owner = msg.sender;
    }
    
    function safeSend(address recipient, uint256 timeLimit) payable returns (address) {
        if (msg.value <= 0 || (now + timeLimit) <= now) {
            throw;
        }
        uint256 deadline = now + timeLimit;
        TimeLockSend newSend = (new TimeLockSend).value(msg.value)(msg.sender, recipient, deadline);
        if (address(newSend) == address(0)) {
            throw;
        }
        TimeLockSendCreated(
            msg.sender,
            recipient,
            deadline,
            address(newSend)
        );
        return address(newSend);
    }
    
    function withdraw() {
        if (msg.sender != owner) {
            throw;
        }
        if (this.balance > 0 && !owner.send(this.balance)) {
            throw;
        }
    }
    
    function () payable {
        // why yes, thank you.
    }
}