pragma solidity ^0.4.10;


contract Nigger
{


	address 	owner;


    string 		public standard = 'Token 0.1';
	string 		public name = "Nigger"; 
	string 		public symbol = "NGR";
	uint8 		public decimals = 18; 
	uint256 	public totalSupply = 40695277 * 1e18;
	

	mapping (address => uint256) balances;	
	mapping (address => mapping (address => uint256)) allowed;


	modifier ownerOnly() 
	{
		require(msg.sender == owner);
		_;
	}		


	function changeName(string _name) public ownerOnly returns(bool success) 
	{

		name = _name;
		NameChange(name);

		return true;
	}


	function changeSymbol(string _symbol) public ownerOnly returns(bool success) 
	{

		symbol = _symbol;
		SymbolChange(symbol);

		return true;
	}


    function balanceOf(address _owner) public constant returns(uint256 tokens) 
	{

		require(_owner != 0x0);
		return balances[_owner];
	}


	function balanceOfReadable(address _owner) public constant returns(uint256 tokens) 
	{

		require(_owner != 0x0);
		return balances[_owner] / 1e18;
	}
	

    function transfer(address _to, uint256 _value) public returns(bool success)
	{ 

		require(_to != 0x0 && _value > 0 && balances[msg.sender] >= _value && _to != msg.sender);


		balances[msg.sender] -= _value;
		balances[_to] += _value;
		Transfer(msg.sender, _to, _value);

		return true;
	}


   function burn(uint256 _value) public returns(bool success)
	{

		require(balances[msg.sender] >= _value && _value > 0);


		balances[msg.sender] -= _value;
		totalSupply -= _value;
		Burn(msg.sender, _value);

		return true;
	}


	function canTransferFrom(address _owner, address _spender) public constant returns(uint256 tokens) 
	{

		require(_owner != 0x0 && _spender != 0x0);
		

		if (_owner == _spender)
		{
			return balances[_owner];
		}
		else 
		{
			return allowed[_owner][_spender];
		}
	}

	
	function transferFrom(address _from, address _to, uint256 _value) public returns(bool success) 
	{

        require(_value > 0 && _from != 0x0 && _to != 0x0 && _to != _from &&
        		allowed[_from][msg.sender] >= _value && 
        		balances[_from] >= _value);
                

        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        balances[_to] += _value;	
        Transfer(_from, _to, _value);

        return true;
    }

    
    function approve(address _spender, uint256 _value) public returns(bool success)  
    {

        require(_spender != 0x0 && _spender != msg.sender);


        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        return true;
    }


    function Nigger() public
	{
		owner = msg.sender;
		balances[owner] = totalSupply;
		TokenDeployed(totalSupply);
	}


	// ====================================================================================
	//
    // List of all events

    event NameChange(string _name);
    event SymbolChange(string _symbol);
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
	event Burn(address indexed _from, uint256 _value);
	event TokenDeployed(uint256 _totalSupply);

}