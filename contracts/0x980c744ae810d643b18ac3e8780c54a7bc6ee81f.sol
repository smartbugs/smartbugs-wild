pragma solidity >=0.4.22 <0.6.0;

// * Gods Unchained Ticket Sale
//
// * Version 1.0
//
// * A dedicated contract selling tickets for the Gods Unchained tournament.
//
// * https://gu.cards

contract ERC20Interface {
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
}

contract TournamentTicket is ERC20Interface {}

contract TournamentTicketSale {

    //////// V A R I A B L E S
    //
    // The ticket owner
    //
    address payable constant public ticketOwner = 0x317D875cA3B9f8d14f960486C0d1D1913be74e90;
    //
    // The ticket contract
    //
    TournamentTicket constant public ticketContract = TournamentTicket(0x22365168c8705E95B2D08876C23a8c13E3ad72E2);
    //
    // In case the sale is paused.
    //
    bool public paused;
    //
    // Price per ticket.
    //
    uint public pricePerTicket;
    //
    // Standard contract ownership.
    //
    address payable public owner;

    //////// M O D I F I E R S
    //
    // Invokable only by contract owner.
    //
    modifier onlyContractOwner {
        require(msg.sender == owner, "Function called by non-owner.");
        _;
    }
    //
    // Invokable only if exchange is not paused.
    //
    modifier onlyUnpaused {
        require(paused == false, "Exchange is paused.");
        _;
    }

    //////// C O N S T R U C T O R
    //
    constructor() public {
        owner = msg.sender;
    }

    //////// F U N C T I O N S
    //
    // Buy a single ticket.
    //
    function buyOne() onlyUnpaused payable external {
        require(msg.value == pricePerTicket, "The amout sent is not corresponding with the ticket price!");
        
        require(
            ticketContract.transferFrom(ticketOwner, msg.sender, 1),
            "Ticket transfer failed!"
        );
    }
    //
    // Sets current ticket price.
    //
    function setTicketPrice(uint price) external onlyContractOwner {
        pricePerTicket = price;
    }
    //
    // Set paused
    //
    function setPaused(bool value) external onlyContractOwner {
        paused = value;
    }
    //
    // Funds withdrawal to cover operational costs
    //
    function withdrawFunds(uint withdrawAmount) external onlyContractOwner {
        ticketOwner.transfer(withdrawAmount);
    }
    //
    // Contract may be destroyed only when there are no ongoing bets,
    // either settled or refunded. All funds are transferred to contract owner.
    //
    function kill() external onlyContractOwner {
        selfdestruct(owner);
    }
}