pragma solidity ^0.4.18;

interface IERC20 {
	function totalSupply() constant returns (uint totalSupply);
	function balanceOf(address _owner) constant returns (uint balance);
	function transfer(address _to, uint _value) returns (bool success);
	function transferFrom(address _from, address _to, uint _value) returns (bool success);
	function approve(address _spender, uint _value) returns (bool success);
	function allowance(address _owner, address _spender) constant returns (uint remaining);
	event Transfer(address indexed _from, address indexed _to, uint _value);
	event Approval(address indexed _owner, address indexed _spender, uint _value);
}

/**
* @title SafeMath
* @dev Math operations with safety checks that throw on error
*/
library SafeMath {
	function mul(uint256 a, uint256 b) internal constant returns (uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal constant returns (uint256) {
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
		return c;
	}

	function sub(uint256 a, uint256 b) internal constant returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	function add(uint256 a, uint256 b) internal constant returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
}



contract ScudoCash is IERC20{
	using SafeMath for uint256;

	uint256 private _totalSupply = 0;

	bool public purchasingAllowed = true;
	bool private bonusAllowed = true;	

	string public constant symbol = "SCH";
	string public constant name = "ScudoCash";
	uint256 public constant decimals = 18;

	uint256 private CREATOR_TOKEN = 3100000000 * 10**decimals;
	uint256 private CREATOR_TOKEN_END = 465000000 * 10**decimals;
	uint256 private constant RATE = 100000;
	uint constant LENGHT_BONUS = 5 * 1 days;
	uint constant PERC_BONUS = 100;
	uint constant LENGHT_BONUS2 = 7 * 1 days;
	uint constant PERC_BONUS2 = 30;
	uint constant LENGHT_BONUS3 = 7 * 1 days;
	uint constant PERC_BONUS3 = 30;
	uint constant LENGHT_BONUS4 = 7 * 1 days;
	uint constant PERC_BONUS4 = 20;
	uint constant LENGHT_BONUS5 = 7 * 1 days;
	uint constant PERC_BONUS5 = 20;
	uint constant LENGHT_BONUS6 = 7 * 1 days;
	uint constant PERC_BONUS6 = 15;
	uint constant LENGHT_BONUS7 = 7 * 1 days;
	uint constant PERC_BONUS7 = 10;
	uint constant LENGHT_BONUS8 = 7 * 1 days;
	uint constant PERC_BONUS8 = 10;
	uint constant LENGHT_BONUS9 = 7 * 1 days;
	uint constant PERC_BONUS9 = 5;
	uint constant LENGHT_BONUS10 = 7 * 1 days;
	uint constant PERC_BONUS10 = 5;

		
	address private owner;

	mapping(address => uint256) balances;
	mapping(address => mapping(address => uint256)) allowed;

	uint private start;
	uint private end;
	uint private end2;
	uint private end3;
	uint private end4;
	uint private end5;
	uint private end6;
	uint private end7;
	uint private end8;
	uint private end9;
	uint private end10;
	
	struct Buyer{
	    address to;
	    uint256 value;
	}
	
	Buyer[] buyers;
	
	modifier onlyOwner {
	    require(msg.sender == owner);
	    _;
	}
	
	function() payable{
		require(purchasingAllowed);		
		createTokens();
	}
   
	function ScudoCash(){
		owner = msg.sender;
		balances[msg.sender] = CREATOR_TOKEN;
		start = now;
		end = now.add(LENGHT_BONUS);
		end2 = end.add(LENGHT_BONUS2);
		end3 = end2.add(LENGHT_BONUS3);
		end4 = end3.add(LENGHT_BONUS4);
		end5 = end4.add(LENGHT_BONUS5);
		end6 = end5.add(LENGHT_BONUS6);
		end7 = end6.add(LENGHT_BONUS7);
		end8 = end7.add(LENGHT_BONUS8);
		end9 = end8.add(LENGHT_BONUS9);
		end10 = end9.add(LENGHT_BONUS10);
	}
   
	function createTokens() payable{
	    bool bSend = true;
		require(msg.value >= 0);
		uint256 tokens = msg.value.mul(10 ** decimals);
		tokens = tokens.mul(RATE);
		tokens = tokens.div(10 ** 18);
		if (bonusAllowed)
		{
			if (now >= start && now < end)
			{
			tokens += tokens.mul(PERC_BONUS).div(100);
			bSend = false;
			}
			if (now >= end && now < end2)
			{
			tokens += tokens.mul(PERC_BONUS2).div(100);
			bSend = false;
			}
			if (now >= end2 && now < end3)
			{
			tokens += tokens.mul(PERC_BONUS3).div(100);
			bSend = false;
			}
			if (now >= end3 && now < end4)
			{
			tokens += tokens.mul(PERC_BONUS4).div(100);
			bSend = false;
			}
			if (now >= end4 && now < end5)
			{
			tokens += tokens.mul(PERC_BONUS5).div(100);
			bSend = false;
			}
			if (now >= end5 && now < end6)
			{
			tokens += tokens.mul(PERC_BONUS6).div(100);
			bSend = false;
			}
			if (now >= end6 && now < end7)
			{
			tokens += tokens.mul(PERC_BONUS7).div(100);
			bSend = false;
			}
			if (now >= end7 && now < end8)
			{
			tokens += tokens.mul(PERC_BONUS8).div(100);
			bSend = false;
			}
			if (now >= end8 && now < end9)
			{
			tokens += tokens.mul(PERC_BONUS9).div(100);
			bSend = false;
			}
			if (now >= end9 && now < end10)
			{
			tokens += tokens.mul(PERC_BONUS10).div(100);
			bSend = false;
			}
		}
		uint256 sum2 = balances[owner].sub(tokens);		
		require(sum2 >= CREATOR_TOKEN_END);
		uint256 sum = _totalSupply.add(tokens);		
		_totalSupply = sum;
		owner.transfer(msg.value);
		if (!bSend){
    		buyers.push(Buyer(msg.sender, tokens));
	    	Transfer(msg.sender, owner, msg.value);
		} else {
	        balances[msg.sender] = balances[msg.sender].add(tokens);
		    balances[owner] = balances[owner].sub(tokens);		    
            Transfer(msg.sender, owner, msg.value);
		}
	}
   
	function totalSupply() constant returns (uint totalSupply){
		return _totalSupply;
	}
   
	function balanceOf(address _owner) constant returns (uint balance){
		return balances[_owner];
	}

	function enablePurchasing() onlyOwner {
		purchasingAllowed = true;
	}
	
	function disablePurchasing() onlyOwner {
		purchasingAllowed = false;
	}   
	
	function enableBonus() onlyOwner {
		bonusAllowed = true;
	}
	
	function disableBonus() onlyOwner {
		bonusAllowed = false;
	}   

	function transfer(address _to, uint256 _value) returns (bool success){
		require(balances[msg.sender] >= _value	&& _value > 0);
		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		Transfer(msg.sender, _to, _value);
		return true;
	}
   
	function transferFrom(address _from, address _to, uint256 _value) returns (bool success){
		require(allowed[_from][msg.sender] >= _value && balances[msg.sender] >= _value	&& _value > 0);
		balances[_from] = balances[_from].sub(_value);
		balances[_to] = balances[_to].add(_value);
		allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
		Transfer(_from, _to, _value);
		return true;
	}
   
	function approve(address _spender, uint256 _value) returns (bool success){
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
		return true;
	}
   
	function allowance(address _owner, address _spender) constant returns (uint remaining){
		return allowed[_owner][_spender];
	}
	
	function burnAll() onlyOwner public {		
		address burner = msg.sender;
		uint256 total = balances[burner];
		if (total > CREATOR_TOKEN_END) {
			total = total.sub(CREATOR_TOKEN_END);
			balances[burner] = balances[burner].sub(total);
			if (_totalSupply >= total){
				_totalSupply = _totalSupply.sub(total);
			}
			Burn(burner, total);
		}
	}
	
	function burn(uint256 _value) onlyOwner public {
        require(_value > 0);
        require(_value <= balances[msg.sender]);
		_value = _value.mul(10 ** decimals);
        address burner = msg.sender;
		uint t = balances[burner].sub(_value);
		require(t >= CREATOR_TOKEN_END);
        balances[burner] = balances[burner].sub(_value);
        if (_totalSupply >= _value){
			_totalSupply = _totalSupply.sub(_value);
		}
        Burn(burner, _value);
	}
		
    function mintToken(uint256 _value) onlyOwner public {
        require(_value > 0);
		_value = _value.mul(10 ** decimals);
        balances[owner] = balances[owner].add(_value);
        _totalSupply = _totalSupply.add(_value);
        Transfer(0, this, _value);
    }
	
	function TransferTokens() onlyOwner public {
	    for (uint i = 0; i<buyers.length; i++){
    		balances[buyers[i].to] = balances[buyers[i].to].add(buyers[i].value);
    		balances[owner] = balances[owner].sub(buyers[i].value);
	        Transfer(owner, buyers[i].to, buyers[i].value);
	    }
	    delete buyers;
	}
	
	event Transfer(address indexed _from, address indexed _to, uint _value);
	event Approval(address indexed _owner, address indexed _spender, uint _value);
	event Burn(address indexed burner, uint256 value);	   
}