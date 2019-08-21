pragma solidity ^0.4.19;

//Submit your eth to show how big your Eth penis is. The 
//biggest Eth dick for 2 days wins the balance and can claim
//prize restarting the contest. The creator gets 3% and the
//winner gets the rest.
contract EthDickMeasuringContest {
    address public largestPenisOwner;
    address public owner;
    uint public largestPenis;
    uint public withdrawDate;

    function EthDickMeasuringContest() public{
        owner = msg.sender;
        largestPenisOwner = 0;
        largestPenis = 0;
    }

    function () public payable{
        require(largestPenis < msg.value);
        largestPenis = msg.value;
        withdrawDate = now + 2 days;
        largestPenisOwner = msg.sender;
    }

    function withdraw() public{
        require(now >= withdrawDate);
        require(msg.sender == largestPenisOwner);

        //Reset game
        largestPenisOwner = 0;
        largestPenis = 0;

        //Judging penises isn't a fun job
        //taking my 3% from the total prize.
        owner.transfer(this.balance*3/100);
        
        //Congratulation on your giant penis.
        //Swing that big dig around
        msg.sender.transfer(this.balance);
    }
}