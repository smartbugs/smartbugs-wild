pragma solidity ^0.4.11;

contract EthereumPot {

	address public owner;
	address[] public addresses;
	
	address public winnerAddress;
    uint[] public slots;
    uint minBetSize = 0.01 ether;
    uint public potSize = 0;
    
	
	uint public amountWon;
	uint public potTime = 300;
	uint public endTime = now + potTime;
	uint public totalBet = 0;

	bool public locked = false;

    
    event debug(string msg);
    event potSizeChanged(
        uint _potSize
    );
	event winnerAnnounced(
	    address winner,
	    uint amount
	);
	
	event timeLeft(uint left);
	function EthereumPot() public {
	    owner = msg.sender;
	}
	
	// function kill() public {
	//     if(msg.sender == owner)
	//         selfdestruct(owner);
	// }
	
	
	
	
	function findWinner(uint random) constant returns (address winner) {
	    
	    for(uint i = 0; i < slots.length; i++) {
	        
	       if(random <= slots[i]) {
	           return addresses[i];
	       }
	        
	    }    
	    
	}
	
	
	function joinPot() public payable {
	    
	    assert(now < endTime);
	    assert(!locked);
	    
	    uint tickets = 0;
	    
	    for(uint i = msg.value; i >= minBetSize; i-= minBetSize) {
	        tickets++;
	    }
	    if(tickets > 0) {
	        addresses.push(msg.sender);
	        slots.push(potSize += tickets);
	        totalBet+= potSize;
	        potSizeChanged(potSize);
	        timeLeft(endTime - now);
	    }
	}
	
	
	function getPlayers() constant public returns(address[]) {
		return addresses;
	}
	
	function getSlots() constant public returns(uint[]) {
		return slots;
	}

	function getEndTime() constant public returns (uint) {
	    return endTime;
	}
	
	function openPot() internal {
        potSize = 0;
        endTime = now + potTime;
        timeLeft(endTime - now);
        delete slots;
        delete addresses;
        
        locked = false;
	}
	
    function rewardWinner() public payable {
        
        //assert time
        
        assert(now > endTime);
        if(!locked) {
            locked = true;
            
            if(potSize > 0) {
            	//if only 1 person bet, wait until they've been challenged
            	if(addresses.length == 1) {
            	    random_number = 0;
            	    endTime = now + potTime;
            	    timeLeft(endTime - now);
            	    locked = false;
            	}
            		
            	else {
            	    
            	    uint random_number = uint(block.blockhash(block.number-1))%slots.length;
                    winnerAddress = findWinner(random_number);
                    amountWon = potSize * minBetSize * 98 / 100;
                    
                    winnerAnnounced(winnerAddress, amountWon);
                    winnerAddress.transfer(amountWon); //2% fee
                    owner.transfer(potSize * minBetSize * 2 / 100);
                    openPot();

            	}
                
            }
            else {
                winnerAnnounced(0x0000000000000000000000000000000000000000, 0);
                openPot();
            }
            
            
        }
        
    }
	
	
	
	
	
        

}