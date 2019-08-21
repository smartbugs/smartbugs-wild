pragma solidity ^0.4.25;

contract EthDeltaHold {
    function() public payable {}
    address Owner;
    function setOwner(address X) public { if (Owner==0) Owner = X; }
    function setup(uint256 openDate) public payable {
        if (msg.value >= 1 ether) {
            open = openDate;
        }
    }
    uint256 open;
    function close() public {
        if (msg.sender==Owner && now>=open) {
            selfdestruct(msg.sender);
        }
    }
}