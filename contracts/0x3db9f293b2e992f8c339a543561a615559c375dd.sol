pragma solidity ^0.4.19;

// See biteuthusiast.github.io

// Press the button to become the winner (costs 0.0001)
// Then you can take 10% of the balance whent the countdown reach 0

// Dev fee is 0.0005 per winner

// Enjoy, don't forget to check this account
// I will refill it

contract Countdown {
    uint public deadline = now;
    uint private constant waittime = 12 hours;
    
    address private owner = msg.sender;
    address public winner;
    
    function () public payable {
        
    }
    
    function click() public payable {
        require(msg.value >= 0.0001 ether);
        deadline = now + waittime;
        winner = msg.sender;
    }
    
    function withdraw() public {
        require(now > deadline);
        require(msg.sender == winner);
        
        deadline = now + waittime;

        // Winner take 10% of the funds
        // And the game continues !
        if(this.balance < 0.0005 ether)
            msg.sender.transfer(this.balance);
        else
            msg.sender.transfer(this.balance /  10);

        // The only fee I will take
        if(this.balance > 0.0005 ether)
            owner.transfer(0.0005 ether);
    }
}