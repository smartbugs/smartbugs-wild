pragma solidity >=0.4.22 <0.6.0;

interface tokenRecipient
{
	function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external;
}


interface IERC20 
{
	function totalSupply() external view returns (uint256);
	function balanceOf(address who) external view returns (uint256);
	function allowance(address owner, address spender) external view returns (uint256);
	function transfer(address to, uint256 value) external returns (bool);
	function approve(address spender, uint256 value) external returns (bool);
	function transferFrom(address from, address to, uint256 value) external returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC223Rtc 
{
	event Transfer(address indexed from, address indexed to, uint256 value,bytes _data);
	event tFallback(address indexed _contract,address indexed _from, uint256 _value,bytes _data);
	event tRetrive(address indexed _contract,address indexed _to, uint256 _value);
	
	
	mapping (address => bool) internal _tokenFull;	
	//	contract => user => balance
	mapping (address => mapping (address => uint256)) internal _tokenInContract;
	
	/// @notice entry to receve tokens
	function tokenFallback(address _from, uint _value, bytes memory _data) public
	{
        	_tokenFull[msg.sender]=true;
		_tokenInContract[msg.sender][_from]=_value;
		emit tFallback(msg.sender,_from, _value, _data);
	}

	function balanceOfToken(address _contract,address _owner) public view returns(uint256)
	{
		IERC20 cont=IERC20(_contract);
		uint256 tBal = cont.balanceOf(address(this));
		if(_tokenFull[_contract]==true)		//full info
		{
			uint256 uBal=_tokenInContract[_contract][_owner];	// user balans on contract
			require(tBal >= uBal);
			return(uBal);
		}
		
		return(tBal);
	}

	
	function tokeneRetrive(address _contract, address _to, uint _value) public
	{
		IERC20 cont=IERC20(_contract);
		
		uint256 tBal = cont.balanceOf(address(this));
		require(tBal >= _value);
		
		if(_tokenFull[_contract]==true)		//full info
		{
			uint256 uBal=_tokenInContract[_contract][msg.sender];	// user balans on contract
			require(uBal >= _value);
			_tokenInContract[_contract][msg.sender]-=_value;
		}
		
		cont.transfer(_to, _value);
		emit tRetrive(_contract, _to, _value);
	}
	
	//test contract is or not
	function isContract(address _addr) internal view returns (bool)
	{
        	uint length;
        	assembly
        	{
			//retrieve the size of the code on target address, this needs assembly
			length := extcodesize(_addr)
		}
		return (length>0);
	}
	
	function transfer(address _to, uint _value, bytes memory _data) public returns(bool) 
	{
		if(isContract(_to))
        	{
			ERC223Rtc receiver = ERC223Rtc(_to);
			receiver.tokenFallback(msg.sender, _value, _data);
		}
        	_transfer(msg.sender, _to, _value);
        	emit Transfer(msg.sender, _to, _value, _data);
		return true;        
	}
	
	function _transfer(address _from, address _to, uint _value) internal 
	{
		// virtual must be defined later
		bytes memory empty;
		emit Transfer(_from, _to, _value,empty);
	}
}

contract FairSocialSystem is IERC20,ERC223Rtc
{
	// Public variables of the token
	string	internal _name;
	string	internal _symbol;
	uint8	internal _decimals;
	uint256	internal _totalS;

	
	// Private variables of the token
	address	payable internal _mainOwner;
	uint	internal _maxPeriodVolume;		//max volume for period
	uint	internal _minPeriodVolume;		//min volume for period
	uint	internal _currentPeriodVolume;
	uint	internal _startPrice;
	uint	internal _currentPrice;
	uint	internal _bonusPrice;


	uint16	internal _perUp;		//percent / 2^20
	uint16	internal _perDown;		//99 & 98 
	uint8	internal _bonus;		//for test price up
	bool	internal _way;			// buy or sell 


	// This creates an array with all balances and allowance
	mapping (address => uint256) internal _balance;
	mapping (address => mapping (address => uint256)) internal _allowed;

	// This generates a public event on the blockchain that will notify clients
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
	event Sell(address indexed owner, uint256 value);
	event Buy (address indexed owner, uint256 value);


	constructor() public 
	{
		_name="Fair Social System";	// Set the name for display purposes
		_symbol="FSS";			// Set the symbol for display purposes
		_decimals=2;                 	//start total = 128*1024*1024
		_totalS=13421772800;		// Update total supply with the decimal amount
		_currentPrice=0.00000001 ether;	


		_startPrice=_currentPrice;
		_bonusPrice=_currentPrice<<1;	//*2
		_maxPeriodVolume=132864000;	//for period
		_minPeriodVolume=131532800;
		_currentPeriodVolume=0;


		_mainOwner=0x394b570584F2D37D441E669e74563CD164142930;
		_balance[_mainOwner]=(_totalS*5)/100;	// Give the creator 5% 
		_perUp=10380;			//percent / 2^20
		_perDown=10276;		//99 & 98 


		emit Transfer(address(this), _mainOwner, _balance[_mainOwner]);
	}

	function _calcPercent(uint mn1,uint mn2) internal pure returns (uint)	//calc % by 2^20
	{
		uint res=mn1*mn2;
		return res>>20;
	}

	function _initPeriod(bool way) internal
	{                   //main logic
		if(way)		//true == sell
		{
			_totalS=_totalS-_maxPeriodVolume;
			_maxPeriodVolume=_minPeriodVolume;
			_minPeriodVolume=_minPeriodVolume-_calcPercent(_minPeriodVolume,_perUp);

			_currentPeriodVolume=_minPeriodVolume;
			_currentPrice=_currentPrice-_calcPercent(_currentPrice,_perUp);
		}
		else
		{
			_minPeriodVolume=_maxPeriodVolume;
			_maxPeriodVolume=_maxPeriodVolume+_calcPercent(_maxPeriodVolume,_perDown);
			_totalS=_totalS+_maxPeriodVolume;
			_currentPeriodVolume=0;
			_currentPrice=_currentPrice+_calcPercent(_currentPrice,_perDown);
		}
		if(_currentPrice>_bonusPrice)		//bonus
		{
			_bonusPrice=_bonusPrice<<1;	//next stage
			uint addBal=_totalS/100;
			_balance[_mainOwner]=_balance[_mainOwner]+addBal;
			_totalS=_totalS+addBal;
			emit Transfer(address(this), _mainOwner, addBal);
		}
	}


	function getPrice() public view returns (uint,uint,uint) 
	{
		return (_currentPrice,_startPrice,_bonusPrice);
	}

	function getVolume() public view returns (uint,uint,uint) 
	{
		return (_currentPeriodVolume,_minPeriodVolume,_maxPeriodVolume);
	}

	function restartPrice() public
	{
		require(address(msg.sender)==_mainOwner);
		if(_currentPrice<_startPrice)
		{
			require(_balance[_mainOwner]>100);
			_currentPrice=address(this).balance/_balance[_mainOwner];
			_startPrice=_currentPrice;
			_bonusPrice=_startPrice<<1;
		}
	}


	//for all income
	function () external payable 
	{        
		buy();
	}

	// entry to buy tokens
	function buy() public payable
	{
		// reject contract buyer to avoid breaking interval limit
		require(!isContract(msg.sender));
		
		uint ethAm=msg.value;
		uint amount=ethAm/_currentPrice;
		uint tAmount=0;	
		uint cAmount=_maxPeriodVolume-_currentPeriodVolume;	//for sell now 

		while (amount>=cAmount)
		{
			tAmount=tAmount+cAmount;
			ethAm=ethAm-cAmount*_currentPrice;
			_initPeriod(false);	//set new params from buy
			amount=ethAm/_currentPrice;
			cAmount=_maxPeriodVolume;
		}
		if(amount>0)	
		{
			_currentPeriodVolume=_currentPeriodVolume+amount;
			tAmount=tAmount+amount;
		}
		_balance[msg.sender]+=tAmount;
		emit Buy(msg.sender, tAmount);		
		emit Transfer(address(this), msg.sender, tAmount);
	}


	// entry to sell tokens
	function sell(uint _amount) public
	{
		require(_balance[msg.sender] >= _amount);

		uint ethAm=0;		//total 
		uint tAmount=_amount;	//for encounting
//		address payble internal userAddr;

		while (tAmount>=_currentPeriodVolume)
		{
			ethAm=ethAm+_currentPeriodVolume*_currentPrice;
			tAmount=tAmount-_currentPeriodVolume;
			_initPeriod(true);	//set new params from sell
		}
		if(tAmount>0)       //may be 0 
		{
			_currentPeriodVolume=_currentPeriodVolume-tAmount;
			ethAm=ethAm+tAmount*_currentPrice;
		}
		
//		userAddr=msg.sender;
//		userAddr.transfer(ethAm);
		_balance[msg.sender] -= _amount;
		msg.sender.transfer(ethAm);
		emit Sell(msg.sender, _amount);
		emit Transfer(msg.sender,address(this),_amount);
	}



	
	/**
	* Internal transfer, only can be called by this contract
	*/
	function _transfer(address _from, address _to, uint _value) internal 
	{
		// Prevent transfer to 0x0 address
		require(_to != address(0x0));
		
		
		// Check if the sender has enough
		require(_balance[_from] >= _value);
		// Check for overflows
		require(_balance[_to] + _value > _balance[_to]);
		// Save this for an assertion in the future
		uint256 previousBalances = _balance[_from] + _balance[_to];
		// Subtract from the sender
		_balance[_from] -= _value;
		// Add the same to the recipient
		_balance[_to] += _value;
		// Asserts are used to use static analysis to find bugs in your code. They should never fail
		require(_balance[_from] + _balance[_to] == previousBalances);
	
		emit Transfer(_from, _to, _value);
	}

	
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) 
	{
		require(_allowed[_from][msg.sender] >= _value);
        
		_allowed[_from][msg.sender] -= _value;
		_transfer(_from, _to, _value);
		emit Approval(_from, msg.sender, _allowed[_from][msg.sender]);
		return true;
	}
	
	
	function transfer(address _to, uint256 _value) public returns(bool) 
	{
		if (_to==address(this))		//sell token 
		{
			sell(_value);
			return true;
		}

		bytes memory empty;
		if(isContract(_to))
		{
			ERC223Rtc receiver = ERC223Rtc(_to);
			receiver.tokenFallback(msg.sender, _value, empty);
		}
		
		_transfer(msg.sender, _to, _value);
		return true;
	}
	
	
	function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool)
	{
		tokenRecipient spender = tokenRecipient(_spender);
		if (approve(_spender, _value))
		{
			spender.receiveApproval(msg.sender, _value, address(this), _extraData);
			return true;
		}
	}


	function approve(address _spender, uint256 _value) public returns(bool)
	{
		require(_spender != address(0));
		_allowed[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

	//check the amount of tokens that an owner allowed to a spender
	function allowance(address owner, address spender) public view returns (uint256)
	{
		return _allowed[owner][spender];
	}

	//balance of the specified address with interest
	function balanceOf(address _addr) public view returns(uint256)
	{
		return _balance[_addr];
	}

    	// Function to access total supply of tokens .
	function totalSupply() public view returns(uint256) 
	{
		return _totalS;
	}


	// the name of the token.
	function name() public view returns (string memory)
	{
		return _name;
	}

	//the symbol of the token
	function symbol() public view returns (string memory) 
	{
		return _symbol;
	}

	//number of decimals of the token
	function decimals() public view returns (uint8) 
	{
		return _decimals;
	}
}