pragma solidity ^0.4.0;
contract Nobody {
    function die() public {
        selfdestruct(msg.sender);
    }
}