pragma solidity 0.4.4; // optimization enabled

contract SendBack {
    function() payable {
        if (!msg.sender.send(msg.value))
            throw;
    }
}