pragma solidity >=0.4.22 <0.6.0;

// * Gods Unchained Ticket Sale
//
// * Version 1.0
//
// * A dedicated contract selling tickets for the Gods Unchained tournament.
//
// * https://gu.cards

contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract TournamentTicket is ERC20Interface {}

contract TournamentTicketSale {

    //////// V A R I A B L E S
    //
    // Current address of the ticket contract (tickets).
    //
    address public ticketContract;
    //
    // Address that owns the tickets.
    //
    address payable public ticketOwner;
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
    address payable private nextOwner;

    //////// M O D I F I E R S
    //
    // Invokable only by contract owner.
    //
    modifier onlyContractOwner {
        require(msg.sender == owner, "Function called by non-owner.");
        _;
    }
    //
    // Invokable only by owner of the tickets.
    //
    modifier onlyTicketOwner {
        require(msg.sender == ticketOwner, "Function called by non-ticket-owner.");
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
        TournamentTicket ticket = getTicketContract();

        require(ticket.balanceOf(msg.sender) == 0, "You already have a ticket, and you only need one to participate!");
        require(pricePerTicket > 0, "The price per ticket needs to be more than 0!");
        require(msg.value == pricePerTicket, "The amout sent is not corresponding with the ticket price!");
        
        require(
            ticket.transferFrom(getTicketOwnerAddress(), msg.sender, 1000000000000000000),
            "Ticket transfer failed!"
        );
        
        getTicketOwnerAddress().transfer(msg.value);
    }
    //
    // Sets current ticket price.
    //
    function setTicketPrice(uint price) external onlyTicketOwner {
        pricePerTicket = price;
    }
    //
    // Sets current ticket token contract address.
    //
    function setTicketContract(address value) external onlyContractOwner {
        ticketContract = value;
    }
    //
    // Get current ticket token contract instance.
    //
    function getTicketContract() internal view returns(TournamentTicket) {
        return(TournamentTicket(ticketContract));
    }
    //
    // Sets current ticket token contract address.
    //
    function setTicketOwnerAddress(address payable value) external onlyContractOwner {
        ticketOwner = value;
    }
    //
    // Get current ticket token contract instance.
    //
    function getTicketOwnerAddress() internal view returns(address payable) {
        return(ticketOwner);
    }
    //
    // Set paused
    //
    function setPaused(bool value) external onlyContractOwner {
        paused = value;
    }
    //
    // Standard contract ownership transfer.
    //
    function approveNextOwner(address payable _nextOwner) external onlyContractOwner {
        require(_nextOwner != owner, "Cannot approve current owner.");
        nextOwner = _nextOwner;
    }
    //
    // Accept the next getGodsTokenContract owner.
    //
    function acceptNextOwner() external {
        require(msg.sender == nextOwner, "The new owner has to accept the previously set new owner.");
        owner = nextOwner;
    }
    //
    // Fallback function deliberately left empty. It's primary use case
    // is to top up the exchange.
    //
    function () external payable {}
    
}