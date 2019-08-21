pragma solidity ^0.4.0;
contract Test {

    function send(address to) public{
        if (to.call("0xabcdef")) {
            return;
        } else {
            revert();
        }
    }
}