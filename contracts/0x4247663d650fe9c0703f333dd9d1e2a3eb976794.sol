pragma solidity ^0.4.25;
contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require (msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}


contract PowerBall is owned {
 using Strings for string;
    struct Ticket {
        address player;
        uint id;
        uint drawDate;
		uint price;
		string balls;
        uint16[] whiteBalls;
        uint16 redBall;
    }
    
    struct Player {
        address id;
		uint ticketCount;
        uint[] arrayIdTickets;
		string ticketId;
    }
    
	struct Draws {
        uint drawId;
		uint ticketCount;
		uint revenue;
        uint[] arrayIdTickets;
		string ticketId;
		uint8 Special; //match 4 balls + power ball
        uint8 First; //match 3 balls + power ball
		uint8 Second; //match 2 balls + power ball
		uint8 Third; //match 1 balls + power ball
        string Result;
    }
	
	struct TicketInfo{
		uint priceTicket;
		uint8 specialPrize;
		uint8 firstPrize;
		uint8 secondPrize;
		uint8 thirdPrize;
	}
	
	struct PrizeInfo{
		uint specialPrize;
		uint firstPrize;
		uint secondPrize;
		uint thirdPrize;
	}
	
    bool acceptTicket = false;
    TicketInfo public ticketInfo;
    uint idTicket = 0;
    uint16 numBall = 5;
	uint16 maxRedBall = 26;
	uint16 maxNumBall = 70;
	PrizeInfo public prizes;
    mapping (uint => Ticket) public tickets;
	mapping (address => Player) public players;
	mapping (uint => Draws) public draws;
	
    
	modifier isAcceptTicket(uint16[] balls) {
		require(balls.length >= numBall );
		require(balls.length % numBall == 0);
		_;
	}
    
    
    event logBuyTicketSumary(
        address user,
        uint[] ticketId,
		uint drawDate
    );
    
	constructor() public{
		ticketInfo.priceTicket  = 10000; 		// 10 GM
		ticketInfo.specialPrize = 30; 			//30 percent
		ticketInfo.firstPrize = 2; 				//2 percent
		ticketInfo.secondPrize = 5; 			//5 percent
		ticketInfo.thirdPrize = 8; 				//8 percent
	}
	
	function setTicketInfo(uint price, uint8 specialPrize, uint8 firstPrize, uint8 secondPrize, uint8 thirdPrize)
	public
	onlyOwner
	{
		ticketInfo.priceTicket  = price; 		
		ticketInfo.specialPrize = specialPrize; 
		ticketInfo.firstPrize = firstPrize; 	
		ticketInfo.secondPrize = secondPrize; 	
		ticketInfo.thirdPrize = thirdPrize; 	
	}
	
	function DrawResult(uint16[] result, uint drawDate, uint8 special, uint8 first,uint8 second, uint8 third)
	public
	onlyOwner
	{
		
		require(draws[drawDate].revenue != 0);
		require(result.length == numBall);
		bytes memory emptyResult = bytes(draws[drawDate].Result);
		if(emptyResult.length == 0){
			uint spe = 0;
			uint fst = 0;
			uint snd = 0;
			uint thr = 0;
			if(special == 0)
				spe = prizes.specialPrize + (draws[drawDate].revenue *  ticketInfo.specialPrize);
			if(first == 0)
				fst = prizes.firstPrize + (draws[drawDate].revenue *  ticketInfo.firstPrize);
			if(second == 0)
				snd = prizes.secondPrize + (draws[drawDate].revenue *  ticketInfo.secondPrize);
			if(third == 0)
				thr = prizes.thirdPrize + (draws[drawDate].revenue *  ticketInfo.thirdPrize);
			Prizes(spe,fst,snd,thr);
		}
		string memory rs = "";
		for(uint8 i=0; i<result.length; i++){
			rs = rs.append(uint2str(result[i]));
		}
		draws[drawDate].Result = rs;
		draws[drawDate].Special = special;
		draws[drawDate].First = first;
		draws[drawDate].Second = second;
		draws[drawDate].Third = third;
	}
	
	
	
    function giveTicket(address user, uint16[] balls, uint drawDate) 
	    public 
		onlyOwner
	    isAcceptTicket(balls)
	{
	   
		address id = user;
		uint[] memory totalId = new uint[](balls.length / numBall);
		for(uint16 i =0; i<balls.length; i += numBall){
			idTicket++;
			uint16[] memory wb = new uint16[](numBall -1);
			string memory _balls = "";
			for(uint16 j = 0; j< numBall -1; j++){
				uint16 ball = i  + j;
				wb[j] = balls[ball];
				_balls = _balls.append(uint2str(balls[ball]));
			}
			 bool bMatch = true;
			if(wb.length == numBall-1){
				bMatch = checkBalls(wb);
			}
			require (!bMatch);		
			uint16 rb = balls[i + numBall -1];
			require(checkRedBall(rb));
			// create ticket
			Ticket memory ticket = Ticket({
				player: id,
				id: idTicket,
				drawDate: drawDate,
				price: ticketInfo.priceTicket,
				balls:_balls,
				whiteBalls:wb,
				redBall:rb
			});
			players[id].arrayIdTickets.push(idTicket);
			players[id].id = id;
			players[id].ticketCount = players[id].arrayIdTickets.length;
			players[id].ticketId = players[id].ticketId.append(uint2str(uint(idTicket)));
			
			draws[drawDate].arrayIdTickets.push(idTicket);
			draws[drawDate].drawId = drawDate;
			draws[drawDate].ticketCount = draws[drawDate].arrayIdTickets.length;
			draws[drawDate].ticketId = draws[drawDate].ticketId.append(uint2str(uint(idTicket)));
			draws[drawDate].revenue += ticket.price;
			
			tickets[idTicket] = ticket;
			totalId[i/numBall] = idTicket;
		}
		emit logBuyTicketSumary(id,totalId,drawDate);
	}
	
    function buyTicket(uint16[] balls, uint drawDate) 
	    public 
	    isAcceptTicket(balls)
	{
	   
		address id = msg.sender;
		uint[] memory totalId = new uint[](balls.length / numBall);
		for(uint16 i =0; i<balls.length; i += numBall){
			idTicket++;
			uint16[] memory wb = new uint16[](numBall -1);
			string memory _balls = "";
			for(uint16 j = 0; j< numBall -1; j++){
				uint16 ball = i  + j;
				wb[j] = balls[ball];
				_balls = _balls.append(uint2str(balls[ball]));
			}
			 bool bMatch = true;
			if(wb.length == numBall-1){
				bMatch = checkBalls(wb);
			}
			require (!bMatch);		
			uint16 rb = balls[i + numBall -1];
			require(checkRedBall(rb));
			// create ticket
			Ticket memory ticket = Ticket({
				player: id,
				id: idTicket,
				drawDate: drawDate,
				price: ticketInfo.priceTicket,
				balls:_balls,
				whiteBalls:wb,
				redBall:rb
			});
			players[id].arrayIdTickets.push(idTicket);
			players[id].id = id;
			players[id].ticketCount = players[id].arrayIdTickets.length;
			players[id].ticketId = players[id].ticketId.append(uint2str(uint(idTicket)));
			
			draws[drawDate].arrayIdTickets.push(idTicket);
			draws[drawDate].drawId = drawDate;
			draws[drawDate].ticketCount = draws[drawDate].arrayIdTickets.length;
			draws[drawDate].ticketId = draws[drawDate].ticketId.append(uint2str(uint(idTicket)));
			draws[drawDate].revenue += ticket.price;
			
			tickets[idTicket] = ticket;
			totalId[i/numBall] = idTicket;
		}
		emit logBuyTicketSumary(id,totalId,drawDate);
	}
	
	function getTicket(uint id) internal view returns(uint drawDate,string ballNum){
		uint16[] storage  balls = tickets[id].whiteBalls;
		for(uint8 i=0; i < balls.length; i++){
			ballNum = ballNum.concat(uint2str(balls[i]));
			ballNum = ballNum.concat("-");
		}
		uint16 redb = tickets[id].redBall;
		ballNum = ballNum.concat(uint2str(redb));
		drawDate = tickets[id].drawDate;
	}
	
	function viewTicket(uint id) internal view returns(uint drawDate, string ballNum){
		uint16[] storage  balls = tickets[id].whiteBalls;
		for(uint8 i=0; i < balls.length; i++){
			ballNum = ballNum.append(uint2str(balls[i]));
		}
		uint16 redb = tickets[id].redBall;
		ballNum = ballNum.append(uint2str(redb));
		drawDate = tickets[id].drawDate;
	}
	function checkRedBall(uint16 ball) private view returns (bool){
		return(ball <= maxRedBall);
	}
	
	function checkBalls(uint16[] ar) private view returns (bool){
        bool bMatch = false;
        uint8 i = uint8(numBall-1);
        uint8 j = uint8(numBall-1);
        
        while (i > 0) {
            i--;
            j = uint8(numBall-1);
            uint16 num1 = ar[i];
			require(num1 <= maxNumBall);
            while (j > 0) {
                j--;
                uint16 num2 = ar[j];
				require(num2 <= maxNumBall);
                if(num1 == num2 && i != j){
                    bMatch = true;
                    break;
                }
            }
            if(bMatch){
                break;
            }
        }
        
       return bMatch;
    }
	function checkRevenue(uint drawDate)
	public 
	onlyOwner
	{
		require(draws[drawDate].revenue > 0);
		uint[] memory ids = draws[drawDate].arrayIdTickets;
		draws[drawDate].revenue = 0;
		for(uint16 i = 0; i< ids.length; i++){
			draws[drawDate].revenue += tickets[ids[i]].price;
		}
	}
	
	function Prizes(uint spe, uint fst, uint snd, uint thr)
	public 
	onlyOwner
	{
		prizes.specialPrize = spe;
		prizes.firstPrize = fst;
		prizes.secondPrize = snd;
		prizes.thirdPrize = thr;
	}
	
	function uint2str(uint i) internal pure returns (string){
		if (i == 0) return "0";
		uint j = i;
		uint length;
		while (j != 0){
			length++;
			j /= 10;
		}
		bytes memory bstr = new bytes(length);
		uint k = length - 1;
		while (i != 0){
			bstr[k--] = byte(48 + i % 10);
			i /= 10;
		}
		return string(bstr);
	}
	
	
}

library Strings {
	function append(string _base, string _value)  internal pure returns (string) {
		return string(abi.encodePacked(_base,"[",_value,"]"," "));
	}

    function concat(string _base, string _value) internal pure returns (string) {
        bytes memory _baseBytes = bytes(_base);
        bytes memory _valueBytes = bytes(_value);

        string memory _tmpValue = new string(_baseBytes.length + _valueBytes.length);
        bytes memory _newValue = bytes(_tmpValue);

        uint i;
        uint j;

        for(i=0; i<_baseBytes.length; i++) {
            _newValue[j++] = _baseBytes[i];
        }

        for(i=0; i<_valueBytes.length; i++) {
            _newValue[j++] = _valueBytes[i];
        }

        return string(_newValue);
    }

}