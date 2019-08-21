pragma solidity ^0.4.18;
contract LifetimeLottery {
    
    uint internal constant MIN_SEND_VAL = 500000000000000000; //minimum amount (in wei) for getting registered on list
	uint internal constant JACKPOT_INC = 100000000000000000; //amount (in wei) which is added to the jackpot
	uint internal constant JACKPOT_CHANCE = 5; //the chance to hit the jackpot in percent
	
	uint internal nonce;
	uint internal random; //number which picks the winner from lotteryList
	uint internal jackpot; //current jackpot
	uint internal jackpotNumber; //number, which is used to decide if the jackpot hits
    
	address[] internal lotteryList; //all registered addresses
    address internal lastWinner;
	address internal lastJackpotWinner;
	address internal deployer;
    
    mapping(address => bool) addressMapping; //for checking quickly, if already registered
	event LotteryLog(address adrs, string message);
	
    function LifetimeLottery() public {
        deployer = msg.sender;
        nonce = (uint(msg.sender) + block.timestamp) % 100;
    }
     
    function () public payable {
		LotteryLog(msg.sender, "Received new funds...");
        if(msg.value >= MIN_SEND_VAL) {
            if(addressMapping[msg.sender] == false) { //--> cheaper access through map instead of a loop
                addressMapping[msg.sender] = true;
                lotteryList.push(msg.sender);
                nonce++;
                random = uint(keccak256(block.timestamp + block.number + uint(msg.sender) + nonce)) % lotteryList.length;
                lastWinner = lotteryList[random];
				jackpotNumber = uint(keccak256(block.timestamp + block.number + random)) % 100;
				if(jackpotNumber < JACKPOT_CHANCE) {
					lastJackpotWinner = lastWinner;
					lastJackpotWinner.transfer(msg.value + jackpot);
					jackpot = 0;
					LotteryLog(lastJackpotWinner, "Jackpot is hit!");
				} else {
					jackpot += JACKPOT_INC;
					lastWinner.transfer(msg.value - JACKPOT_INC);
					LotteryLog(lastWinner, "We have a Winner!");
				}
            } else {
                msg.sender.transfer(msg.value);
				LotteryLog(msg.sender, "Failed: already joined! Sending back received ether...");
            }
        } else {
            msg.sender.transfer(msg.value);
			LotteryLog(msg.sender, "Failed: not enough Ether sent! Sending back received ether...");
        }
    }
	
	function amountOfRegisters() public constant returns(uint) {
		return lotteryList.length;
	}
	
	function currentJackpotInWei() public constant returns(uint) {
		return jackpot;
	}
    
    function ourLastWinner() public constant returns(address) {
        return lastWinner;
    }
	
	function ourLastJackpotWinner() public constant returns(address) {
		return lastJackpotWinner;
	}
	
	modifier isDeployer {
		require(msg.sender == deployer);
		_;
	}
	
	function withdraw() public isDeployer { //backdoor in case of errors
        deployer.transfer(this.balance - jackpot); //jackpot is untouchable
    }
	
	function die() public isDeployer {
		selfdestruct(deployer); //killing contract
	}
}