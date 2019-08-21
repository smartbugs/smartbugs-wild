pragma solidity ^0.4.22;


contract LastManStanding {

    uint lastBlock;
    address owner;
    modifier onlyowner {
        require (msg.sender == owner);
        _;
    }

    function LastManStanding() public {
        owner = msg.sender;
    }

    function () public payable {
        mineIsBigger();
    }

    function mineIsBigger() public payable {
        if (msg.value > this.balance) {
            owner = msg.sender;
            lastBlock = now;
        }
    }

    function withdraw() public onlyowner {
        // if there are no contestants within 5 hours
        // the winner is allowed to take the money
        require(now > lastBlock + 5 hours);
        msg.sender.transfer(this.balance);
    }
   
}