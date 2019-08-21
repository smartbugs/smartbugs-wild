contract bbb{
    /* Define variable owner of the type address*/
    address owner;
	event EmailSent(address Sender, uint256 PricePaid, string EmailAddress, string Message);
	
    function bbb() { 
        owner = msg.sender; 
    }
    function Kill() { 
		if(msg.sender==owner){
			suicide(owner); 
		}		
    }
	function Withdraw(uint256 AmountToWithdraw){
		owner.send(AmountToWithdraw);
	}
    function SendEmail(string EmailAddress, string Message) { 
        EmailSent(msg.sender, msg.value, EmailAddress, Message);
    }    
}