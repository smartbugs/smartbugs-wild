pragma solidity 0.4.18;
//signature - 9927A75EF7C89D3C028C8BA7A1B48CDD515ACED7A2BC564A099D452D3B3FFE89
contract NewYearToken{
	string public symbol = "NYT";
	string public name = "New Year Token";
	uint8 public constant decimals = 8;
	uint256 _totalSupply = 0;
	address contract_owner;
	uint256 current_remaining = 0;
	uint256 _contractStart = 1514782800; // 01/01/2018 12:00AM EST
	uint256 _maxTotalSupply = 10000000000000000; //one hundred million
	uint256 _miningReward = 10000000000; //100 NYT rewarded on successful mine halved every 5 years 
	uint256 _maxMiningReward = 1000000000000000; //10,000,000 NYT - To be halved every 5 years
	uint256 _year = 1514782800; // 01/01/2018 12:00AM EST
	uint256 _year_count = 2018; //contract starts in 2018 first leap year is 2020
	uint256 _currentMined = 0; //mined for the year


	event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;

    //initialize contract - set owner and give owner 20,000 tokens
    function NewYearToken(){	
    	contract_owner = msg.sender;
    	balances[msg.sender] += 20000;
    }

	function totalSupply() constant returns (uint256) {        
		return _totalSupply;
	}

	function balanceOf(address _owner) constant returns (uint256 balance) {
		return balances[_owner];
	}


	function transfer(address _to, uint256 _amount) returns (bool success) {
		if (balances[msg.sender] >= _amount 
			&& _amount > 0
			&& balances[_to] + _amount > balances[_to]) {
			balances[msg.sender] -= _amount;
			balances[_to] += _amount;
			Transfer(msg.sender, _to, _amount);
			return true;
		} else {
            return false;
		}
	}

	function transferFrom(
		address _from,
		address _to,
		uint256 _amount
	) returns (bool success) {
		if (balances[_from] >= _amount
			&& allowed[_from][msg.sender] >= _amount
			&& _amount > 0
			&& balances[_to] + _amount > balances[_to]) {
			balances[_from] -= _amount;
			allowed[_from][msg.sender] -= _amount;
			balances[_to] += _amount;
			Transfer(_from, _to, _amount);
			return true;
		} else {
			return false;
		}
	}

	function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
		return allowed[_owner][_spender];
	}

	function approve(address _spender, uint256 _amount) returns (bool success) {
		allowed[msg.sender][_spender] = _amount;
		Approval(msg.sender, _spender, _amount);
		return true;
	}
	//is_leap_year sets year to 12AM on new years day of the current year and sets the mining rewards
	function is_leap_year() private{
		if(now >= _year + 31557600){	
			_year = _year + 31557600;	//changes to new year, 1 day early on leap year, in seconds
			_year_count = _year_count + 1; //changes to new year in years
			_currentMined = 0;	//rests for current years supply
			_miningReward = _miningReward/2; //halved yearly starting at 100
			if(((_year_count-2018)%5 == 0) && (_year_count != 2018)){
				_maxMiningReward = _maxMiningReward/2; //halved every 5th year
				

			}
			if((_year_count%4 == 1) && ((_year_count-1)%100 != 0)){
				_year = _year + 86400;	//adds a day following a leap year
				

			}
			else if((_year_count-1)%400 == 0){
				_year = _year + 86400; //leap year day added on last day of leap year

			}
 
		}	

	}


	function date_check() private returns(bool check_newyears){

		is_leap_year(); //set the year variables and rewards
		//check if date is new years day
	    if((_year <= now) && (now <= (_year + 604800))){
			return true;	//it is the first week of the new year
		}
		else{
			return false; //it is not the first week of the new year
		}
	}
	
	function mine() returns(bool success){
		if(date_check() != true)
			revert();
		else if((_currentMined < _maxMiningReward) && (_maxMiningReward - _currentMined >= _miningReward)){
			if((_totalSupply+_miningReward) <= _maxTotalSupply){
				//send reward if there are tokens available and it is new years day
				balances[msg.sender] += _miningReward;	
				_currentMined += _miningReward;
				_totalSupply += _miningReward;
				Transfer(this, msg.sender, _miningReward); 
				return true;
			}
		else if(now > (_year + 604800)){
			current_remaining = _maxMiningReward - _currentMined; 
			if((current_remaining >= 0) && (_currentMined != 0)){
				_currentMined += current_remaining;
				Transfer(this, contract_owner, current_remaining);	//sends unmined coins for the year to _owner
			}
		}
		return false;
		}
		
	}

	function MaxTotalSupply() constant returns(uint256)
	{
		return _maxTotalSupply;
	}
	
	function MiningReward() constant returns(uint256)
	{
		return _miningReward;
	}
	
	function MaxMiningReward() constant returns(uint256)
	{
		return _maxMiningReward;
	}
	function CurrentMined() constant returns(uint256)
	{
		return _currentMined; //amount mined so far this year
	}



}