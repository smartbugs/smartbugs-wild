pragma solidity ^0.4.24;

contract Lottery {

    uint public lotteryStart;
    uint public ticketPrice;
    uint public ticketsAvailable;

    mapping(uint => address) public owner;

    modifier lotteryComplete {require(block.timestamp >= (lotteryStart + 7 days), "lottery has not completed"); _;}

    constructor() public {
        lotteryStart = 0;
    }

    function newLottery() public {
        if (lotteryStart != 0) {
            require(block.timestamp >= (lotteryStart + 7 days), "lottery has not completed");
        }

        for (uint ticket = 0; ticket < ticketsAvailable; ticket++) {
            owner[ticket] = address(0);
        }

        ticketsAvailable = 100;
        ticketPrice = 10 finney;
        lotteryStart = block.timestamp;
    }

    function purchaseTicket(uint ticket) public payable {
        require(owner[ticket] == address(0), "the ticket has been purchased");                    // the ticket hasn't been purchased
        require(msg.value == ticketPrice, "sent an invalid ticket price");                      // value sent is the ticket price

        owner[ticket] = msg.sender;
    }

    function completeLottery() public lotteryComplete {
        address winner = owner[block.number % ticketsAvailable];

        if (winner != address(0)) {
            address(this).transfer(address(this).balance);
        }
    }

    function getTicketOwner(uint ticket) public view returns(address) {
        return owner[ticket];
    }
}