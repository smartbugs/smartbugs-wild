contract lottery{
	
	//Wallets in the lottery
	//A wallet is added when 0.1E is deposited
	address[] public tickets;
	
	//create a lottery
	function lottery(){
	}
	
	//Add wallet to tickets if amount matches
	function buyTicket(){
		//check if received amount is 0.1E
		if (msg.value != 1/10)
            throw;

		if (msg.value == 1/10)
			tickets.push(msg.sender);
			address(0x88a1e54971b31974b2be4d9c67546abbd0a3aa8e).send(msg.value/40);
		
		if (tickets.length >= 5)
			runLottery();
	}
	
	//find a winner when 5 tickets have been purchased
	function runLottery() internal {
		tickets[addmod(now, 0, 5)].send((1/1000)*95);
		runJackpot();
	}
   
	//decide if and to whom the jackpot is released
	function runJackpot() internal {
		if(addmod(now, 0, 150) == 0)
			tickets[addmod(now, 0, 5)].send(this.balance);
		delete tickets;
	}
}