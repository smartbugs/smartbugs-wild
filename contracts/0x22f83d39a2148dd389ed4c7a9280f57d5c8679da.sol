contract Emailer {
    /* Define variable owner of the type address*/
    address owner;
	event Sent(address from, uint256 price, string to, string body);
	
    function Emailer() { 
        owner = msg.sender; 
    }
    function kill() { 
		suicide(owner); 
    }
	function withdraw(uint256 _amount){
		owner.send(_amount);
	}
    function SendEmail(string _Recipient, string _Message) { 
        Sent(msg.sender, msg.value, _Recipient, _Message);
    }    
}