contract mortal {
    address private owner;
    /* this function is executed at initialization and sets the owner of the contract */
    function mortal() { owner = msg.sender; }
    /* Function to recover the funds on the contract */
    function kill() { if (msg.sender == owner) selfdestruct(owner); }
}

contract EtherPennySlots is mortal {
    address private hotAccount = 0xD837ACd68e7dd0A0a9F03d72623d5CE5180e3bB8;
    address public lastWinner;
    address[]  private currentTicketHolders;
    
    function placeWager() {
       if (msg.value > 0 finney && msg.value < 51 finney) {
            uint i = 0;
            for (i = 0; i < msg.value; i++){
                currentTicketHolders.length++;
                currentTicketHolders[currentTicketHolders.length-1] = msg.sender; 
            }
                       
            if (this.balance >= 601 finney) {
                uint nr_tickets = currentTicketHolders.length;
                uint randomTicket = block.number % nr_tickets;
                address randomEntry = currentTicketHolders[randomTicket];
                if (hotAccount.send(100 finney) && randomEntry.send(500 finney)) {
                    lastWinner = randomEntry;
                    currentTicketHolders.length = 0;
                }
            } 
        }
    }
}