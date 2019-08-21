pragma solidity ^0.4.25;

contract Hodls {
    function() public payable {}
    function setOwner() { if (Owner==0) Owner = msg.sender; }
    address Owner;
    function setup(uint256 futureDate) public payable {
        if (msg.value >= 1 ether) {
            openDate = futureDate;
        }
    }
    uint256 openDate;
    function close() {
        if (msg.sender==Owner && now >= openDate) {
            selfdestruct(msg.sender);
        }
    }
 }