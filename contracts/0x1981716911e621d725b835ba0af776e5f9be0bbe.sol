pragma solidity ^0.4.19;
 
 
 
 
 
contract Lottery7 {
    
    address owner;
    address profit = 0xB7BB510B0746bdeE208dB6fB781bF5Be39d15A15;
    uint public tickets;
    uint public round;
    string public status;
    uint public lastWiningTicketNumber;
    address public lastWinner;
    address ticket1;
    address ticket2;
    address ticket3;
    address ticket4;
    address ticket5;
    uint constant price = 0.1 ether; 
    uint seed;
    bool entry = false;
     
    function Lottery7() public { 
        owner = msg.sender;
        tickets = 5;
        round = 1;
        status = "Running";
        entry = false;
        seed = 777;
    }
     
     
    function changeStatus(string w) public {
        if (msg.sender == owner) {
            status = w;
        }
        else {
            revert();
        }
    }
    
    function changeSeed(uint32 n) public {
        if (msg.sender == owner) {
            seed = uint(n);
            seed = uint(block.blockhash(block.number-seed))%2000 + 1; 
        }
        else {
            revert();
        }
    }
     
    function () public payable { 
        buyTickets();
    }
     
    function buyTickets() public payable {
        if (entry == true) { 
            revert();
        }
        entry = true;
        
        if (msg.value != (price)) {
            entry = false;
            if (keccak256(status) == keccak256("Shutdown")) { 
                selfdestruct(owner);
            }
            revert(); 
        }
        else {
            if (tickets == 5) {
                tickets -= 1;
                ticket1 = msg.sender;
            }
            else if(tickets == 4) {
                tickets -= 1;
                ticket2 = msg.sender;
                profit.transfer(price * 1/2); 
            }
            else if(tickets == 3) {
                tickets -= 1;
                ticket3 = msg.sender;
            }
            else if(tickets == 2) {
                tickets -= 1;
                ticket4 = msg.sender;
            }
            else if(tickets == 1) {
                ticket5 = msg.sender;
                
                tickets = 5; 
                round += 1; 
                seed = uint(block.blockhash(block.number-seed))%2000 + 1; 
                uint random_number = uint(block.blockhash(block.number-seed))%5 + 1; 
                lastWiningTicketNumber = random_number; 
    
                uint pay = (price * 9/2); 
                
                if (random_number == 1) {
                    ticket1.transfer(pay);
                    lastWinner = ticket1; 
                }
                else if(random_number == 2) {
                    ticket2.transfer(pay);
                    lastWinner = ticket2; 
                }
                else if(random_number == 3) {
                    ticket3.transfer(pay);
                    lastWinner = ticket3; 
                }
                else if(random_number == 4) {
                    ticket4.transfer(pay);
                    lastWinner = ticket4; 
                }
                else if(random_number == 5) {
                    ticket5.transfer(pay);
                    lastWinner = ticket5; 
                }
            }
        }

        entry = false;
    }
     
     
}