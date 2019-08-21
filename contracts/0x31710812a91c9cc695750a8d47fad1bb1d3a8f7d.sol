pragma solidity ^0.4.7;

contract FreeMoney {
    function take() public payable {
        if (msg.value > 15 finney) {
            selfdestruct(msg.sender);
        }
    }
    function () public payable {}
}