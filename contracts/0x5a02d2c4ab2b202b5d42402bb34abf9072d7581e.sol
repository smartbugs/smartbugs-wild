pragma solidity ^0.4.19;
contract ChessMoney {
 
    //CONSTANT
    uint256 private maxTickets;
    uint256 public ticketPrice; 
     
    //LOTTO REGISTER
    uint256 public lottoIndex;
    uint256 lastTicketTime;
    
    //LOTTO VARIABLES
	uint8 _direction;
    uint256 numtickets;
    uint256 totalBounty;
    
    address worldOwner;   
     
    event NewTicket(address indexed fromAddress, bool success);
    event LottoComplete(address indexed fromAddress, uint indexed lottoIndex, uint256 reward);
    
    /// Create a new Lotto
    function ChessMoney() public 
    {
        worldOwner = msg.sender; 
        
        ticketPrice = 0.00064 * 10**18;
        maxTickets = 320;
        
		_direction = 0;
        lottoIndex = 1;
        lastTicketTime = 0;
        
        numtickets = 0;
        totalBounty = 0;
    }

    
    function getBalance() public view returns (uint256 balance)
    {
        balance = 0;
        
        if(worldOwner == msg.sender) balance = this.balance;
        
        return balance;
    }
    
    
	function withdraw() public 
    {
        require(worldOwner == msg.sender);  
        
		//reset values
        lottoIndex += 1;
        numtickets = 0;
        totalBounty = 0;
		
		worldOwner.transfer(this.balance); 
    }
    
    
    function getLastTicketTime() public view returns (uint256 time)
    {
        time = lastTicketTime; 
        return time;
    }
    
	
    function AddTicket() public payable 
    {
        require(msg.value == ticketPrice); 
        require(numtickets < maxTickets);
        
		//update bif
		lastTicketTime = now;
        numtickets += 1;
        totalBounty += ticketPrice;
        bool success = numtickets == maxTickets;
		
        NewTicket(msg.sender, success);
        
		//check if winner
        if(success) 
        {
            PayWinner(msg.sender);
        } 
    }
    
    
    function PayWinner( address winner ) private 
    { 
        require(numtickets == maxTickets);
        
		//calc reward
        uint ownerTax = totalBounty / 10;
        uint winnerPrice = totalBounty - ownerTax;
        
        LottoComplete(msg.sender, lottoIndex, winnerPrice);
         
		//reset values
        lottoIndex += 1;
        numtickets = 0;
        totalBounty = 0;
		
		//change max tickets to give unpredictability
		if(_direction == 0 && maxTickets < 10) maxTickets += 1;
		if(_direction == 1 && maxTickets > 20) maxTickets -= 1;
		if(_direction == 0 && maxTickets < 30) maxTickets += 1;
		if(_direction == 1 && maxTickets > 40) maxTickets -= 1;
		if(_direction == 0 && maxTickets < 50) maxTickets += 1;
		if(_direction == 1 && maxTickets > 60) maxTickets -= 1;
		if(_direction == 0 && maxTickets < 70) maxTickets += 1;
		if(_direction == 1 && maxTickets > 80) maxTickets -= 1;
		if(_direction == 0 && maxTickets < 90) maxTickets += 1;
		if(_direction == 1 && maxTickets > 100) maxTickets -= 1;
		if(_direction == 0 && maxTickets < 110) maxTickets += 1;
		if(_direction == 1 && maxTickets > 120) maxTickets -= 1;
		if(_direction == 0 && maxTickets < 130) maxTickets += 1;
		if(_direction == 1 && maxTickets > 140) maxTickets -= 1;
		if(_direction == 0 && maxTickets < 150) maxTickets += 1;
		if(_direction == 1 && maxTickets > 160) maxTickets -= 1;
		if(_direction == 0 && maxTickets < 170) maxTickets += 1;
		if(_direction == 1 && maxTickets > 180) maxTickets -= 1;
		if(_direction == 0 && maxTickets < 190) maxTickets += 1;
		if(_direction == 1 && maxTickets > 200) maxTickets -= 1;
		if(_direction == 0 && maxTickets < 210) maxTickets += 1;
		if(_direction == 1 && maxTickets > 220) maxTickets -= 1;
		if(_direction == 0 && maxTickets < 230) maxTickets += 1;
		if(_direction == 1 && maxTickets > 240) maxTickets -= 1;
		if(_direction == 0 && maxTickets < 250) maxTickets += 1;
		if(_direction == 1 && maxTickets > 260) maxTickets -= 1;
		if(_direction == 0 && maxTickets < 270) maxTickets += 1;
		if(_direction == 1 && maxTickets > 280) maxTickets -= 1;
		if(_direction == 0 && maxTickets < 290) maxTickets += 1;
		if(_direction == 1 && maxTickets > 300) maxTickets -= 1;
		if(_direction == 0 && maxTickets < 310) maxTickets += 1;
		if(_direction == 1 && maxTickets > 320) maxTickets -= 1;
		if(_direction == 0 && maxTickets == 10) _direction = 1;
		if(_direction == 1 && maxTickets == 20) _direction = 0;
		if(_direction == 0 && maxTickets == 30) _direction = 1;
		if(_direction == 1 && maxTickets == 40) _direction = 0;
		if(_direction == 0 && maxTickets == 50) _direction = 1;
		if(_direction == 1 && maxTickets == 60) _direction = 0;
		if(_direction == 0 && maxTickets == 70) _direction = 1;
		if(_direction == 1 && maxTickets == 80) _direction = 0;
 		if(_direction == 0 && maxTickets == 90) _direction = 1;
		if(_direction == 1 && maxTickets == 100) _direction = 0;
		if(_direction == 0 && maxTickets == 110) _direction = 1;
		if(_direction == 1 && maxTickets == 120) _direction = 0;
		if(_direction == 0 && maxTickets == 130) _direction = 1;
		if(_direction == 1 && maxTickets == 140) _direction = 0;
		if(_direction == 0 && maxTickets == 150) _direction = 1;
		if(_direction == 1 && maxTickets == 160) _direction = 0;
		if(_direction == 0 && maxTickets == 170) _direction = 1;
		if(_direction == 1 && maxTickets == 180) _direction = 0;
		if(_direction == 0 && maxTickets == 190) _direction = 1;
		if(_direction == 1 && maxTickets == 200) _direction = 0;
		if(_direction == 0 && maxTickets == 210) _direction = 1;
		if(_direction == 1 && maxTickets == 220) _direction = 0;
		if(_direction == 0 && maxTickets == 230) _direction = 1;
		if(_direction == 1 && maxTickets == 240) _direction = 0;
 		if(_direction == 0 && maxTickets == 250) _direction = 1;
		if(_direction == 1 && maxTickets == 260) _direction = 0;
		if(_direction == 0 && maxTickets == 270) _direction = 1;
		if(_direction == 1 && maxTickets == 280) _direction = 0;
		if(_direction == 0 && maxTickets == 290) _direction = 1;
		if(_direction == 1 && maxTickets == 300) _direction = 0;
		if(_direction == 0 && maxTickets == 310) _direction = 1;
		if(_direction == 1 && maxTickets == 320) _direction = 0;
	      

        
		//give real money
        worldOwner.transfer(ownerTax);
        winner.transfer(winnerPrice); 
    }
}