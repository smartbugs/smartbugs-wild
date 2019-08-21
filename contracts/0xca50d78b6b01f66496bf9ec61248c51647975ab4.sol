pragma solidity ^0.4.11;
contract Pot {

	address public owner;
    address[] public potMembers;
    
	uint public potSize = 0;
	uint public winnerIndex;
	address public winnerAddress;
	uint public minBetSize = .01 ether;
	uint public potTime = 1800;
	uint public endTime = now + potTime;
	uint public totalBet = 0;

	bool public locked = false;
	
	event potSizeChanged(
        uint _potSize
    );
	
	event winnerAnnounced(
	    address winner,
	    uint amount
	);
	
	event timeLeft(uint left);
	
	event debug(string msg);
	
	function Pot() {
		owner = msg.sender;
	}

	// function Kill() public {
	// 	if(msg.sender == owner) {
	// 	    selfdestruct(owner);
	// 	}
	// }
	
	
	function bytesToString (bytes32 data) returns (string) {
        bytes memory bytesString = new bytes(32);
        for (uint j=0; j<32; j++) {
            byte char = byte(bytes32(uint(data) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[j] = char;
            }
        }
        return string(bytesString);
    }
	
	//1 ether = 1 spot
	function joinPot() public payable {
	    
	    assert(now < endTime);
        //for each ether sent, reserve a spot
	    for(uint i = msg.value; i >= minBetSize; i-= minBetSize) {
	        potMembers.push(msg.sender);
	        totalBet+= minBetSize;
	        potSize += 1;
	    }
	    
	    potSizeChanged(potSize);
	    timeLeft(endTime - now);
	    
	}

	function getPlayers() constant public returns(address[]) {
		return potMembers;
	}
	
	function getEndTime() constant public returns (uint) {
	    return endTime;
	}
	
    function rewardWinner() public payable {
        
        //assert time
        debug("assert now > end time");
        assert(now > endTime);
        if(!locked) {
            locked = true;
            debug("locked");
            if(potSize > 0) {
            	//if only one member entered the pot, then they automatically win
            	if(potMembers.length == 1) 
            		random_number = 0;
            	else
                	uint random_number = uint(block.blockhash(block.number-1))%potMembers.length - 1;
                winnerIndex = random_number;
                winnerAddress = potMembers[random_number];
                uint amountWon = potSize * minBetSize * 98 / 100;
                
                
                winnerAnnounced(winnerAddress, amountWon);
                potMembers[random_number].transfer(amountWon); //2% fee
                owner.transfer(potSize * minBetSize * 2 / 100);
            }
            else {
                winnerAnnounced(0x0000000000000000000000000000000000000000, 0);
            }
            
            potSize = 0;
            endTime = now + potTime;
            timeLeft(endTime - now);
            delete potMembers;
            locked = false;
        }
        
    }

}