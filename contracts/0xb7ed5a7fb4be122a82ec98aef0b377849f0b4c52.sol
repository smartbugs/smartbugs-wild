pragma solidity ^0.4.24;

contract hbys{

    mapping(uint=>address) public addr;
    uint public counter;
    uint public bingo;
    address owner;
    
    event Lucknumber(address holder,uint startfrom,uint quantity);
    modifier onlyowner{require(msg.sender == owner);_;}
    
    
    constructor() public{owner = msg.sender;}
    
    
    function() payable public{
        require(msg.value>0 && msg.value<=5*10**18);
        getticket();
    }
    
    
    function getticket() internal{
            //require(msg.sender==tx.origin);
            uint fee;
            fee+=msg.value/10;
	        owner.transfer(fee);
	        fee=0;
	        
	        
	        address _holder=msg.sender;
	        uint _startfrom=counter;
	        
	        uint ticketnum;
            ticketnum=msg.value/(0.1*10**18);
            uint _quantity=ticketnum;
	        counter+=ticketnum;
	        
	        uint8 i=0;
            for (i=0;i<ticketnum;i++){
                	   addr[_startfrom+i]=msg.sender;
                
            }
            emit Lucknumber(_holder,_startfrom,_quantity);
    }
    
    
    
    
/*
work out the target-number:bingo,and sent 2% of cash pool to the lucky guy.

Join the two decimal of Dow Jones index's open price,close price,high price and low price in sequence.
eg. if the open price is 25012.33,the close price is 25103.12,the high price is 25902.26,
and the low price is 25001.49, then dji will be 33122649.
*/
    function share(uint dji) public  onlyowner{
       require(dji>=0 && dji<=99999999);

       bingo=uint(keccak256(abi.encodePacked(dji)))%counter;

       addr[bingo].transfer(address(this).balance/50);
    }
       
}