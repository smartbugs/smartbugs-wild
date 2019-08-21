pragma solidity ^0.4.24;
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

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
    using SafeMath for uint256;
     
    struct Ticket {
        address player;
        uint32 drawDate;
		uint64 price;
        uint8 ball1;
        uint8 ball2;
        uint8 ball3;
        uint8 ball4;
        uint8 redBall;
    }
    struct Draws{
        uint32 count;
        uint32[500000] tickets;
    }
    
	struct CurrentPrizes{
		address special;
		address first;
		address second;
		address third;
	}
	struct Prize{
	    address[] winners;
	    uint amout;
	}
	struct LotteryResults{
		Prize special;
		Prize first;
		Prize second;
		Prize third;
		uint8[5] result;
		bool hadDraws;
		bool hadAward;
	}
	
	struct TicketInfo{
		uint64 priceTicket;
		uint8 specialPrize;
		uint8 firstPrize;
		uint8 secondPrize;
		uint8 thirdPrize;
		uint8 commission;
		uint8 sales;
	}
    TicketInfo public ticketInfo;
	CurrentPrizes public prizes;
	address SystemSale;
    mapping(address => uint256) private balances;
    mapping (uint => Ticket) private tickets;
    mapping (uint32 => Draws)  _draws;
	mapping (uint32 => LotteryResults)  _results;
	
    
	uint32 idTicket;
    
    event logBuyTicketSumary(
        address user,
        uint32[] ticketId,
		uint drawDate
    );
    
    event logGetPrize(
        string prize,
		uint drawDate,
		uint amout,
		address[] winners,
		uint8[5] result
		
    );
    
    event logAward(
        string prize,
        uint drawDate,
		uint amout,
		address[] winners,
		uint8[5] result
    );
    
    event logWithdraw(
        address account,
		uint amout
    );
    
	constructor() public{
		ticketInfo.priceTicket  = 10000; 		//10 GM
		ticketInfo.specialPrize = 30; 			//30 percent
		ticketInfo.firstPrize = 2; 				//2 percent
		ticketInfo.secondPrize = 5; 			//5 percent
		ticketInfo.thirdPrize = 8; 				//8 percent
		ticketInfo.commission = 10; 			//10 percent
		ticketInfo.sales = 45; 				    //45 percent
		
		
		prizes.special = 0x374cC1ed754A448276380872786659ab532CD7fC; //account 3
		prizes.first = 0xF73823D62f8006E8cBF39Ba630479EFDA59419C9; //account 4
		prizes.second = 0x0b744af1F0E55AFBeAb8212B00bBf2586F0EBB8F; //account 5
		prizes.third = 0x6dD465891AcB3570F122f5E7E52eeAA406992Dcf; //account 6
		
	
		SystemSale = 0xbD6E06b04c2582c4373741ef6EDf39AB37Eb964C; //account 8
		
		
	}
	
	
	function setTicketInfo(
	    uint64 _priceTicket,
		uint8 _specialPrize,
		uint8 _firstPrize,
		uint8 _secondPrize,
		uint8 _thirdPrize,
		uint8 _commission,
		uint8 _sales
	    ) 
	public
	onlyOwner
	{
	    ticketInfo.priceTicket  = _priceTicket;    
	    ticketInfo.specialPrize = _specialPrize;
		ticketInfo.firstPrize = _firstPrize;
		ticketInfo.secondPrize = _secondPrize;
		ticketInfo.thirdPrize = _thirdPrize;
		ticketInfo.commission = _commission;
		ticketInfo.sales = _sales;
	}
	
	function cumulativeAward(uint _special, uint _first, uint _second, uint _third)
	public
	onlyOwner
	{
	    setBalance(prizes.special,_special);
	    setBalance(prizes.first,_first);
	    setBalance(prizes.second,_second);
	    setBalance(prizes.third,_third);
	}
	
	/**
    * @dev giveTickets buy ticket and give it to another player
    * @param _user The address of the player that will receive the ticket.
    * @param _drawDate The draw date of tickets.
    * @param _balls The ball numbers of the tickets.
    */
	function giveTickets(address _user,uint32 _drawDate, uint8[] _balls) 
	onlyOwner
	public
	{
	    require(!_results[_drawDate].hadDraws);
	    uint32[] memory _idTickets = new uint32[](_balls.length/5);
	    uint32 id = idTicket;
		
	    for(uint8 i = 0; i< _balls.length; i+=5){
	        require(checkRedBall(_balls[i+4]));
	        require(checkBall(_balls[i]));
	        require(checkBall(_balls[i+1]));
	        require(checkBall(_balls[i+2]));
	        require(checkBall(_balls[i+3]));
	        id++;
    	    tickets[id].player = _user;
    	    tickets[id].drawDate = _drawDate;
    	    tickets[id].price = ticketInfo.priceTicket;
    	    tickets[id].redBall = _balls[i+4];
    	    tickets[id].ball1 = _balls[i];
    	    tickets[id].ball2 = _balls[i + 1];
    	    tickets[id].ball3 = _balls[i +2];
    	    tickets[id].ball4 = _balls[i + 3];
		    _draws[_drawDate].tickets[_draws[_drawDate].count] = id;
    	    _draws[_drawDate].count ++;
    	    _idTickets[i/5] = id;
	    }
	    idTicket = id;
	    emit logBuyTicketSumary(_user,_idTickets,_drawDate);
	}
	
	/**
    * @dev addTickets allow admin add ticket to player for buy ticket fail
    * @param _user The address of the player that will receive the ticket.
    * @param _drawDate The draw date of tickets.
    * @param _balls The ball numbers of the tickets.
    * @param _price The price of the tickets.
    */
	function addTickets(address _user,uint32 _drawDate, uint64 _price, uint8[] _balls) 
	onlyOwner
	public
	{
	    require(!_results[_drawDate].hadDraws);
	    uint32[] memory _idTickets = new uint32[](_balls.length/5);
	    uint32 id = idTicket;
		
	    for(uint8 i = 0; i< _balls.length; i+=5){
	        require(checkRedBall(_balls[i+4]));
	        require(checkBall(_balls[i]));
	        require(checkBall(_balls[i+1]));
	        require(checkBall(_balls[i+2]));
	        require(checkBall(_balls[i+3]));
	        id++;
    	    tickets[id].player = _user;
    	    tickets[id].drawDate = _drawDate;
    	    tickets[id].price = _price;
    	    tickets[id].redBall = _balls[i+4];
    	    tickets[id].ball1 = _balls[i];
    	    tickets[id].ball2 = _balls[i + 1];
    	    tickets[id].ball3 = _balls[i +2];
    	    tickets[id].ball4 = _balls[i + 3];
		    _draws[_drawDate].tickets[_draws[_drawDate].count] = id;
    	    _draws[_drawDate].count ++;
    	    _idTickets[i/5] = id;
	    }
	    idTicket = id;
	    emit logBuyTicketSumary(_user,_idTickets,_drawDate);
	}
	
	function checkBall(uint8 ball) private pure returns (bool){
	    return ball > 0 && ball <= 70; 
	}
   
    function checkRedBall(uint8 ball) private pure returns (bool){
	    return ball > 0 && ball <= 26; 
	}
	
	
    /**
    * @dev doDraws buy ticket and give it to another player
    * @param _drawDate The draw date of tickets.
    * @param _result The result of draw.
    */
	function doDraws(uint32 _drawDate, uint8[5] _result)
	public
	onlyOwner
	returns (bool success) 
	{
		require (_draws[_drawDate].count > 0);
		require(!_results[_drawDate].hadDraws);
		_results[_drawDate].hadDraws =true;
		for(uint32 i=0; i<_draws[_drawDate].count;i++){
			uint8 _prize = checkTicket(_draws[_drawDate].tickets[i],_result);
			if(_prize==5){ //special
			    _results[_drawDate].special.winners.push(address(0));
				_results[_drawDate].special.winners[_results[_drawDate].special.winners.length-1] = tickets[_draws[_drawDate].tickets[i]].player;
			}else if(_prize == 4){ //First
			    _results[_drawDate].first.winners.push(address(0));
				_results[_drawDate].first.winners[_results[_drawDate].first.winners.length-1] = tickets[_draws[_drawDate].tickets[i]].player;
			}else if(_prize == 3){ //Second
			    _results[_drawDate].second.winners.push(address(0));
				_results[_drawDate].second.winners[_results[_drawDate].second.winners.length-1] = tickets[_draws[_drawDate].tickets[i]].player;
			}else if(_prize == 2){ //Third
			    _results[_drawDate].third.winners.push(address(0));
				_results[_drawDate].third.winners[_results[_drawDate].third.winners.length-1] = tickets[_draws[_drawDate].tickets[i]].player;
			}
		}
		_results[_drawDate].result =_result;
		setAmoutPrize(_drawDate,_result);
		
		
		return true;
	}
	
	function setDrawsResult(uint32 _drawDate, uint8[5] _result,address[] _special, address[] _first, address[] _second, address[] _third)
	public
	onlyOwner
	returns (bool success) 
	{
	    
		require (_draws[_drawDate].count > 0);
		require(!_results[_drawDate].hadDraws);
		_results[_drawDate].hadDraws =true;
		
		_results[_drawDate].special.winners = _special;

		_results[_drawDate].first.winners = _first;

		_results[_drawDate].second.winners = _second;

		_results[_drawDate].third.winners = _third;

		_results[_drawDate].result =_result;
		
		setAmoutPrize(_drawDate,_result);
		return true;
	}
	
	
	function doAward(uint32 _drawDate)
	public
	onlyOwner
	{
	    require(_results[_drawDate].hadDraws);
	    require(!_results[_drawDate].hadAward);
	    //uint revenue = getRevenue(_drawDate);
	    uint _prize=0;
	    if(_results[_drawDate].special.winners.length>0){
    	    _prize = _results[_drawDate].special.amout / _results[_drawDate].special.winners.length;
    	    for(uint i=0;i<	_results[_drawDate].special.winners.length; i++){
    	        transfer(_results[_drawDate].special.winners[i], _prize);
    	    }
    	    emit logAward(
                "Special prize",
                _drawDate,
        		_prize,
        		_results[_drawDate].special.winners,
        		_results[_drawDate].result
            );
	    }
	    
	    if( _results[_drawDate].first.winners.length > 0){
    	    _prize = _results[_drawDate].first.amout / _results[_drawDate].first.winners.length;
    	    for(i=0;i<	_results[_drawDate].first.winners.length; i++){
    	        transfer(_results[_drawDate].first.winners[i], _prize);
    	    }
    	    emit logAward(
                "First prize",
                _drawDate,
        		_prize,
        		_results[_drawDate].first.winners,
        		_results[_drawDate].result
            );
	    }
	    if( _results[_drawDate].second.winners.length > 0){
    	    _prize = _results[_drawDate].second.amout / _results[_drawDate].second.winners.length;
    	    for(i=0;i<	_results[_drawDate].second.winners.length; i++){
    	        transfer(_results[_drawDate].second.winners[i], _prize);
    	    }
    	    emit logAward(
                "Second prize",
                _drawDate,
        		_prize,
        		_results[_drawDate].second.winners,
        		_results[_drawDate].result
            );
	    }
	    
	    if( _results[_drawDate].third.winners.length > 0){
    	    _prize = _results[_drawDate].third.amout / _results[_drawDate].third.winners.length;
    	    for(i=0;i<	_results[_drawDate].third.winners.length; i++){
    	        transfer(_results[_drawDate].third.winners[i], _prize);
    	    }
    	    emit logAward(
                "Third prize",
                _drawDate,
        		_prize,
        		_results[_drawDate].third.winners,
        		_results[_drawDate].result
            );
	    }
	    _results[_drawDate].hadAward = true;
	}
	

	function getRevenue(uint32 _drawDate) private view returns(uint _revenue){
	    for(uint i=0; i< _draws[_drawDate].count; i++){
			_revenue += tickets[_draws[_drawDate].tickets[i]].price;
		}
	}
	
	
	function resetDraws(uint32 _drawDate)
	onlyOwner
	public
	{
	    require(_results[_drawDate].hadDraws);
	    require(!_results[_drawDate].hadAward);
		delete  _results[_drawDate];
	}
	
	function setAmoutPrize(uint32 _drawDate,uint8[5] _result)
	private
	{
	    //send coin to prize wallets
		uint revenue = getRevenue(_drawDate);
		uint _prizeAmout;
		//send value to system sale
		transfer(SystemSale,(revenue * ticketInfo.sales / 100));
		//if had special prize
		_prizeAmout = (revenue * ticketInfo.specialPrize / 100);
		if(	_results[_drawDate].special.winners.length == 0){
		    transfer(prizes.special,_prizeAmout);
		}else{
		    _results[_drawDate].special.amout = _prizeAmout + balanceOf(prizes.special);
		    clear(prizes.special);
		    emit logGetPrize(
		            "Special",
		            _drawDate,
		            _results[_drawDate].special.amout,
		            _results[_drawDate].special.winners,
		            _result
		            
		    );
		}
		
		//if had First prize
		_prizeAmout = (revenue * ticketInfo.firstPrize / 100);
		if(	_results[_drawDate].first.winners.length == 0){
		    transfer(prizes.first,_prizeAmout);
		}else{
		    _results[_drawDate].first.amout = _prizeAmout + balanceOf(prizes.first);
		    clear(prizes.first);
		    emit logGetPrize(
		            "First prize",
		            _drawDate,
		            _results[_drawDate].first.amout,
		            _results[_drawDate].first.winners,
		            _result
		            
		    );
		}
		
		//if had seconds prize
		_prizeAmout = (revenue * ticketInfo.secondPrize / 100);
		if(	_results[_drawDate].second.winners.length == 0){
		    transfer(prizes.second,_prizeAmout);
		}else{
		    _results[_drawDate].second.amout = _prizeAmout + balanceOf(prizes.second);
		    clear(prizes.second);
		    emit logGetPrize(
		            "Second prize",
		            _drawDate,
		            _results[_drawDate].second.amout,
		            _results[_drawDate].second.winners,
		            _result
		            
		    );
		}
		
		//if had third prize
		_prizeAmout = (revenue * ticketInfo.thirdPrize / 100);
		if(	_results[_drawDate].third.winners.length == 0){
		   transfer(prizes.third,_prizeAmout);
		}else{
		    _results[_drawDate].third.amout = _prizeAmout + balanceOf(prizes.third);
		    clear(prizes.third);
		    emit logGetPrize(
		            "Third prize",
		            _drawDate,
		            _results[_drawDate].third.amout,
		            _results[_drawDate].third.winners,
		            _result
		            
		    );
		}
	}
	
	function checkTicket(uint32 _ticketId, uint8[5] _result)
	private
	view
	returns(uint8 _prize)
	{
		//check red ball
		if(_result[4] != tickets[_ticketId].redBall){
			_prize = 0;
			return _prize;
		}
		_prize = 1;
		//check white ball 1
		for(uint8 i=0;i<4; i++){
			if(_result[i] == tickets[_ticketId].ball1){
				_prize ++;
				break;
			}
		}
		//check white ball 2
		for(i=0;i<4; i++){
			if(_result[i] == tickets[_ticketId].ball2){
				_prize ++;
				break;
			}
		}
		//check white ball 3
		for(i=0;i<4; i++){
			if(_result[i] == tickets[_ticketId].ball3){
				_prize ++;
				break;
			}
		}
		//check white ball 4
		for(i=0;i<4; i++){
			if(_result[i] == tickets[_ticketId].ball4){
				_prize ++;
				break;
			}
		}
		return _prize;
	}
	
	
	
	function viewResult(uint32 _drawDate)
	public
	view
	returns(uint _revenue, string _special, string _first, string _second,string _third, string _result, bool _wasDrawn, bool _wasAwarded)
	{
		LotteryResults memory dr = _results[_drawDate];
		uint8 i;
		
		_revenue = getRevenue(_drawDate);
		
		_special = _special.add(uint2str(dr.special.amout)).add(" / ").add(uint2str(dr.special.winners.length));
		_first = _first.add(uint2str(dr.first.amout)).add(" / ").add(uint2str(dr.first.winners.length));
		_second = _second.add(uint2str(dr.second.amout)).add(" / ").add(uint2str(dr.second.winners.length));
		_third = _third.add(uint2str(dr.third.amout)).add(" / ").add(uint2str(dr.third.winners.length));
		
		for(i=0; i< dr.result.length; i++){
			_result = _result.append(uint2str(dr.result[i]));
		}
		_wasDrawn = dr.hadDraws;
		_wasAwarded = dr.hadAward;
	}
	

	function ViewCumulativeAward()
	public
	view
	returns(uint _special, uint _first, uint _second, uint _third)
	{
	    _special = balanceOf(prizes.special);
	    _first = balanceOf(prizes.first);
	    _second = balanceOf(prizes.second);
	    _third = balanceOf(prizes.third);
	}
	
	
    
	
	function viewTicketsInRound(uint32 _drawDate)
	public
	view
	returns (uint32 _count, string _tickets, uint _revenue) 
	{
	    _count = _draws[_drawDate].count;
	    for(uint i=0; i< _count;i++){
	        _tickets = _tickets.append(uint2str(_draws[_drawDate].tickets[i]));
			_revenue+=  tickets[_draws[_drawDate].tickets[i]].price;
	    }
	    return (_count,_tickets,_revenue);
	}
	
	function ticketsOfPlayer(address _player, uint32 _drawDate)
	public
	view
	returns (uint32 _count, string _tickets) 
	{
	    for(uint i=0; i<  _draws[_drawDate].count;i++){
	        if(tickets[_draws[_drawDate].tickets[i]].player == _player){
	            _count++;
	            _tickets = _tickets.append(uint2str(_draws[_drawDate].tickets[i]));
	        }
	    }
	    return (_count,_tickets);
	}
	
	function ticket(uint _ticketID)
	public
	view
	returns(address _player, uint32 _drawDate, uint64 _price, string _balls)
	{
	    _player = tickets[_ticketID].player;
	    _drawDate = tickets[_ticketID].drawDate;
	    _price = tickets[_ticketID].price;
	    _balls = _balls.append(uint2str(tickets[_ticketID].ball1))
	                .append(uint2str(tickets[_ticketID].ball2))
            	    .append(uint2str(tickets[_ticketID].ball3))
	                .append(uint2str(tickets[_ticketID].ball4));
	    _balls = _balls.append(uint2str(tickets[_ticketID].redBall));
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
	
	
	 /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer( address _to, uint256 _value) private returns (bool) {
        require(_to != address(0));
		balances[_to] = balances[_to].add(_value);
        return true;
    }
    
     /**
    * @dev setBalance token for a specified address
    * @param _to The address to set balances to.
    * @param _value The amount to be set balances.
    */
    function setBalance( address _to, uint256 _value) private returns (bool) {
        require(_to != address(0));
		balances[_to] = _value;
        return true;
    }
    
    /**
    * @dev withdraw token for a specified address
    * @param _from The address to withdraw from.
    * @param _value The amount to be withdraw.
    */
    function withdraw( address _from, uint256 _value) 
    public 
    onlyOwner
    returns (bool) {
        require(_from != address(0));
		balances[_from] = balances[_from].sub(_value);
		emit logWithdraw(_from, _value);
        return true;
    }
    
    /**
    * @dev clear reset token for a specified address to zero
    * @param _from The address to withdraw from.
    */
    function clear( address _from) 
    private 
    onlyOwner returns (bool) {
        require(_from != address(0));
		balances[_from] = 0;
    
        return true;
    }
   
    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of. 
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }
}
library Strings {
	function append(string _base, string _value)  internal pure returns (string) {
		return string(abi.encodePacked(_base,"[",_value,"]"," "));
	}
	
	function add(string _base, string _value)  internal pure returns (string) {
		return string(abi.encodePacked(_base,_value," "));
	}
}