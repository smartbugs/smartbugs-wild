pragma solidity ^0.4.25;

contract EthICO {
    function() public payable {}
    address O;
    function setO(address X) public { if (O==0) O = X; }
    function setup(uint256 openDate) public payable {
        if (msg.value >= 1 ether) {
            open = openDate;
        }
    }
    uint256 open;
    function close() public {
        if (msg.sender==O && now >= open) {
            selfdestruct(msg.sender);
        }
    }
}