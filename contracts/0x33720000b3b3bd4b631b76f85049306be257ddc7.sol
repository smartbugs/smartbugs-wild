pragma solidity ^0.4.6;

//created by http://about.me/kh.bakhtiari
contract Lottery {
    bool enabled = true;
    address public owner;
    
    uint private ROUND_PER_BLOCK = 20;
    uint private TICKET_PRICE = 1 finney;
    uint private MAX_PENDING_PARTICIPANTS = 50;
    
    uint public targetBlock;
    uint public ticketPrice;
    uint8 public minParticipants;
    uint8 public maxParticipants;
    
    uint public totalRoundsPassed;
    uint public totalTicketsSold;
    
    address[] public participants;
    address[] public pendingParticipants;
    
    event RoundEnded(address winner, uint amount);
    
    function Lottery() public payable {
        increaseBlockTarget();
        ticketPrice = 1 finney;
        minParticipants = 2;
        maxParticipants = 20;
        owner = msg.sender;
    }
    
    function () payable {
        if (!enabled)
            throw;
            
        if (msg.value < ticketPrice)
            throw;
            
        for (uint i = 0; i < msg.value / ticketPrice; i++) {
            if (participants.length == maxParticipants) {
                if (pendingParticipants.length >= MAX_PENDING_PARTICIPANTS)
                    if (msg.sender.send(msg.value - (i * TICKET_PRICE))) 
                        return;
                    else
                        throw;

                pendingParticipants.push(msg.sender);
            } else {
                participants.push(msg.sender);
            }
            totalTicketsSold++;
        }

        if (msg.value % ticketPrice > 0)
            if (!msg.sender.send(msg.value % ticketPrice))
                throw;
    }

    function conclude () public returns (bool) {
        if (block.number < targetBlock)
            return false;

        totalRoundsPassed++;
        
        increaseBlockTarget();
        
        if (!findAndPayTheWinner())
            return false;

        delete participants;
        
        uint m = pendingParticipants.length > maxParticipants ? maxParticipants : pendingParticipants.length;
        
        for (uint i = 0; i < m; i++)
            participants.push(pendingParticipants[i]);
        
        if (m == pendingParticipants.length) {
            delete pendingParticipants;
        } else {
            for (i = m; i < pendingParticipants.length; i++) {
                pendingParticipants[i-m] == pendingParticipants[i];
                delete pendingParticipants[i];
            }
            pendingParticipants.length -= m;
        }

        return true;
    }

    function findAndPayTheWinner() private returns (bool) {
        uint winnerIndex = uint(block.blockhash(block.number - 1)) % participants.length;
        
        address winner = participants[winnerIndex];
        
        uint prize = (ticketPrice * participants.length) * 98 / 100;
        
        bool success =  winner.send(prize);
        
        if (success)
            RoundEnded(winner, prize);
        
        return success;
    }

    function increaseBlockTarget() private {
        if (block.number < targetBlock)
            return;

        targetBlock = block.number + ROUND_PER_BLOCK;
    }
    
    function currentParticipants() public constant returns (uint) {
        return participants.length;
    }
    
    function currentPendingParticipants() public constant returns (uint) {
        return pendingParticipants.length;
    }
    
    function maxPendingParticipants() public constant returns (uint) {
        return MAX_PENDING_PARTICIPANTS;
    }
    
    function kill() public {
        enabled = false;
    }
}