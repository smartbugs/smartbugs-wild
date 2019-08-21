pragma solidity ^0.4.25;

contract CoinFlip {
    address owner;
    uint payPercentage = 90;
	
	// Maximum amount to bet in WEIs
	uint public MaxAmountToBet = 200000000000000000; // = 0.2 Ether
	
    mapping (address => uint) private userBalances;
	
	struct Game {
		address addr;
		uint blocknumber;
		uint blocktimestamp;
        uint bet;
		uint prize;
        bool winner;
    }
	
	Game[] lastPlayedGames;
	
	Game newGame;
    
    event Status(
		string _msg, 
		address user, 
		uint amount,
		bool winner
	);
    
    constructor() public payable {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        if (owner != msg.sender) {
            revert();
        } else {
            _;
        }
    }
    
    function Play() public payable {
		
		if (msg.value > MaxAmountToBet) {
			revert();
		} else {
			if ((block.timestamp % 2) == 0) {
				
				if (address(this).balance < (msg.value * ((100 + payPercentage) / 100))) {
					// No tenemos suficientes fondos para pagar el premio, así que transferimos todo lo que tenemos
                    userBalances[msg.sender] = address(this).balance;
                    uint amountToWithdraw = userBalances[msg.sender];
                    userBalances[msg.sender] = 0;
					msg.sender.transfer(amountToWithdraw);
					emit Status('Congratulations, you win! Sorry, we didn\'t have enought money, we will deposit everything we have!', msg.sender, msg.value, true);
					
					newGame = Game({
						addr: msg.sender,
						blocknumber: block.number,
						blocktimestamp: block.timestamp,
						bet: msg.value,
						prize: address(this).balance,
						winner: true
					});
					lastPlayedGames.push(newGame);
					
				} else {
					uint _prize = msg.value * (100 + payPercentage) / 100;
					emit Status('Congratulations, you win!', msg.sender, _prize, true);
                    userBalances[msg.sender] = _prize;
                    uint amountToWithdraw2 = userBalances[msg.sender];
                    userBalances[msg.sender] = 0;
					msg.sender.transfer(amountToWithdraw2);
					
					newGame = Game({
						addr: msg.sender,
						blocknumber: block.number,
						blocktimestamp: block.timestamp,
						bet: msg.value,
						prize: _prize,
						winner: true
					});
					lastPlayedGames.push(newGame);
					
				}
			} else {
				emit Status('Sorry, you loose!', msg.sender, msg.value, false);
				
				newGame = Game({
					addr: msg.sender,
					blocknumber: block.number,
					blocktimestamp: block.timestamp,
					bet: msg.value,
					prize: 0,
					winner: false
				});
				lastPlayedGames.push(newGame);
				
			}
		}
    }
	
	function getGameCount() public constant returns(uint) {
		return lastPlayedGames.length;
	}

	function getGameEntry(uint index) public constant returns(address addr, uint blocknumber, uint blocktimestamp, uint bet, uint prize, bool winner) {
		return (lastPlayedGames[index].addr, lastPlayedGames[index].blocknumber, lastPlayedGames[index].blocktimestamp, lastPlayedGames[index].bet, lastPlayedGames[index].prize, lastPlayedGames[index].winner);
	}
	
	
	function depositFunds() payable public onlyOwner {}
    
	function withdrawFunds(uint amount) onlyOwner public {
	    require(amount <= address(this).balance);
        if (owner.send(amount)) {
            emit Status('User withdraw some money!', msg.sender, amount, true);
        }
    }
	
	function setMaxAmountToBet(uint amount) onlyOwner public returns (uint) {
		MaxAmountToBet = amount;
        return MaxAmountToBet;
    }
	
	function getMaxAmountToBet() constant public returns (uint) {
        return MaxAmountToBet;
    }
	
    
    function Kill() onlyOwner public{
        emit Status('Contract was killed, contract balance will be send to the owner!', msg.sender, address(this).balance, true);
        selfdestruct(owner);
    }
}