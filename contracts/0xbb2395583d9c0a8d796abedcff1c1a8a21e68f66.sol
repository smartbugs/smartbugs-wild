pragma solidity ^0.4.20;

// JohnVerToken Made By PinkCherry - insanityskan@gmail.com
// JohnVerToken Request Question - koreacoinsolution@gmail.com

library SafeMath
{
  	function mul(uint256 a, uint256 b) internal pure returns (uint256)
    {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);

		return c;
  	}

  	function div(uint256 a, uint256 b) internal pure returns (uint256)
	{
		uint256 c = a / b;

		return c;
  	}

  	function sub(uint256 a, uint256 b) internal pure returns (uint256)
	{
		assert(b <= a);

		return a - b;
  	}

  	function add(uint256 a, uint256 b) internal pure returns (uint256)
	{
		uint256 c = a + b;
		assert(c >= a);

		return c;
  	}
}


contract OwnerHelper
{
  	address public owner;

  	event OwnerTransferPropose(address indexed _from, address indexed _to);

  	modifier onlyOwner
	{
		require(msg.sender == owner);
		_;
  	}

  	function OwnerHelper() public
	{
		owner = msg.sender;
  	}

  	function transferOwnership(address _to) onlyOwner public
	{
        require(_to != owner);
		require(_to != address(0x0));
		owner = _to;
		OwnerTransferPropose(owner, _to);
  	}

}


contract ERC20Interface
{
  	event Transfer(address indexed _from, address indexed _to, uint _value);
  	event Approval(address indexed _owner, address indexed _spender, uint _value);

  	function totalSupply() public constant returns (uint);
  	function balanceOf(address _owner) public constant returns (uint balance);
  	function transfer(address _to, uint _value) public returns (bool success);
  	function transferFrom(address _from, address _to, uint _value) public returns (bool success);
  	function approve(address _spender, uint _value) public returns (bool success);
  	function allowance(address _owner, address _spender) public constant returns (uint remaining);
}


contract ERC20Token is ERC20Interface, OwnerHelper
{
  	using SafeMath for uint;

  	uint public tokensIssuedTotal = 0;
  	address public constant burnAddress = 0;

  	mapping(address => uint) balances;
  	mapping(address => mapping (address => uint)) allowed;

  	function totalSupply() public constant returns (uint)
	{
		return tokensIssuedTotal;
  	}

  	function balanceOf(address _owner) public constant returns (uint balance)
	{
		return balances[_owner];
  	}

	function transfer(address _to, uint _amount) public returns (bool success)
	{
		require( balances[msg.sender] >= _amount );

	    balances[msg.sender] = balances[msg.sender].sub(_amount);
		balances[_to]        = balances[_to].add(_amount);

		Transfer(msg.sender, _to, _amount);
    
		return true;
  	}

  	function approve(address _spender, uint _amount) public returns (bool success)
	{
		require ( balances[msg.sender] >= _amount );

		allowed[msg.sender][_spender] = _amount;
    		
		Approval(msg.sender, _spender, _amount);

		return true;
	}

  	function transferFrom(address _from, address _to, uint _amount) public returns (bool success)
	{
		require( balances[_from] >= _amount );
		require( allowed[_from][msg.sender] >= _amount );
		balances[_from]            = balances[_from].sub(_amount);
		allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
		balances[_to]              = balances[_to].add(_amount);

		Transfer(_from, _to, _amount);
		return true;
  	}

  	function allowance(address _owner, address _spender) public constant returns (uint remaining)
	{
		return allowed[_owner][_spender];
  	}
}

contract JohnVerToken is ERC20Token
{
	uint constant E18 = 10**18;

  	string public constant name 	= "JohnVerToken";
  	string public constant symbol 	= "JVT";
  	uint public constant decimals 	= 18;

	address public wallet;
	address public adminWallet;

	uint public constant totalTokenCap   = 7600000000 * E18;
	uint public constant icoTokenCap     = 4006662000 * E18;
	uint public constant mktTokenCap     = 3593338000 * E18;

	uint public tokenPerEth = 3000000 * E18;

	uint public constant privateSaleBonus	 = 50;
	uint public constant preSaleFirstBonus	 = 20;
	uint public constant preSaleSecondBonus  = 15;
	uint public constant mainSaleBonus  = 0;
	
  	uint public constant privateSaleEtherCap = 100 ether;
  	uint public constant preSaleFirstEtherCap = 200 ether;
  	uint public constant preSaleSecondEtherCap = 200 ether;
  	uint public constant mainSaleEtherCap = 7 ether;
  	
  	uint public constant dayToMinusToken = 3000 * E18;
	uint public constant dayToDate = 86400;

  	uint public constant privateSaleStartDate = 1519344000; // 2018-02-23 00:00 UTC
  	uint public constant privateSaleEndDate   = 1519862400; // 2018-03-01 00:00 UTC

  	uint public constant preSaleFirstStartDate = 1520208000; // 2018-03-05 00:00 UTC
  	uint public constant preSaleFirstEndDate   = 1520726400; // 2018-03-11 00:00 UTC

  	uint public constant preSaleSecondStartDate = 1521158400; // 2018-03-16 00:00 UTC
  	uint public constant preSaleSecondEndDate   = 1521676800; // 2018-03-22 00:00 UTC

  	uint public constant mainSaleStartDate = 1522022400; // 2018-03-26 00:00 UTC
  	uint public constant mainSaleEndDate   = 1531353600; // 2018-07-11 00:00 UTC

	uint public constant privateSaleMinEth  = 3 ether / 10; // 0.3 Ether
	uint public constant preSaleMinEth      = 2 ether / 10; // 0.2 Ether
	uint public constant mainSaleMinEth     = 1 ether / 10; // 0.1 Ether

  	uint public icoEtherReceivedTotal = 0;
  	uint public icoEtherReceivedPrivateSale = 0;
  	uint public icoEtherReceivedPreFirstSale = 0;
  	uint public icoEtherReceivedPreSecondSale = 0;
  	uint public icoEtherReceivedMainSale = 0;
	uint public icoEtherReceivedMainSaleDay = 0;
	
	uint public tokenIssuedToday = 0;
	
    uint public tokenIssuedTotal        = 0;
  	uint public tokenIssuedPrivateIco   = 0;
  	uint public tokenIssuedPreFirstIco  = 0;
  	uint public tokenIssuedPreSecondIco = 0;
  	uint public tokenIssuedMainSaleIco  = 0;
  	uint public tokenIssuedMkt          = 0;
	uint public tokenIssuedAirDrop      = 0;
	uint public tokenIssuedLockUp       = 0;

  	mapping(address => uint) public icoEtherContributed;
  	mapping(address => uint) public icoTokenReceived;
  	mapping(address => bool) public refundClaimed;
  	
 	event WalletChange(address _newWallet);
  	event AdminWalletChange(address _newAdminWallet);
  	event TokenMinted(address indexed _owner, uint _tokens, uint _balance);
  	event TokenAirDroped(address indexed _owner, uint _tokens, uint _balance);
  	event TokenIssued(address indexed _owner, uint _tokens, uint _balance, uint _etherContributed);
  	event Refund(address indexed _owner, uint _amount, uint _tokens);
  	event LockRemove(address indexed _participant);
	event WithDraw(address indexed _to, uint _amount);
	event OwnerReclaim(address indexed _from, address indexed _owner, uint _amount);

  	function JohnVerToken() public
	{
		require( icoTokenCap + mktTokenCap == totalTokenCap );
		wallet = owner;
		adminWallet = owner;
  	}

  	function () payable public
	{
    	buyToken();
  	}
  	
  	function atNow() public constant returns (uint)
	{
		return now;
  	}

  	function buyToken() private
	{
		uint nowTime = atNow();

		uint saleTime = 0; // 1 : privateSale, 2 : preSaleFirst, 3 : preSaleSecond, 4 : mainSale

		uint minEth = 0;
		uint maxEth = 0;

		uint tokens = 0;
		uint tokenBonus = 0;
		uint tokenMinusPerEther = 0;
		uint etherCap = 0;

		uint mainSaleDay = 0;
		
		if (nowTime > privateSaleStartDate && nowTime < privateSaleEndDate)
		{
			saleTime = 1;
			minEth = privateSaleMinEth;
			tokenBonus = privateSaleBonus;
			etherCap = privateSaleEtherCap;
			maxEth = privateSaleEtherCap;
		}

		if (nowTime > preSaleFirstStartDate && nowTime < preSaleFirstEndDate)
		{
			saleTime = 2;
			minEth = preSaleMinEth;
			tokenBonus = preSaleFirstBonus;
			etherCap = preSaleFirstEtherCap;
			maxEth = preSaleFirstEtherCap;
		}

		if (nowTime > preSaleSecondStartDate && nowTime < preSaleSecondEndDate)
		{
			saleTime = 3;
			minEth = preSaleMinEth;
			tokenBonus = preSaleSecondBonus;
			etherCap = preSaleSecondEtherCap;
			maxEth = preSaleSecondEtherCap;
		}

		if (nowTime > mainSaleStartDate && nowTime < mainSaleEndDate)
		{
			saleTime = 4;
			minEth = mainSaleMinEth;
			uint dateStartTime = 0;
			uint dateEndTime = 0;
			
		    for (uint i = 1; i <= 108; i++)
		    {
		        dateStartTime = 0;
		        dateStartTime = dateStartTime.add(i.sub(1));
		        dateStartTime = dateStartTime.mul(dayToDate);
		        dateStartTime = dateStartTime.add(mainSaleStartDate);
		        
		        dateEndTime = 0;
		        dateEndTime = dateEndTime.add(i.sub(1));
		        dateEndTime = dateEndTime.mul(dayToDate);
		        dateEndTime = dateEndTime.add(mainSaleEndDate);
		        
  			    if (nowTime > dateStartTime && nowTime < dateEndTime) 
			    {
			    	mainSaleDay = i;
			    }
		    }
		    
		    require( mainSaleDay != 0 );
		    
		    etherCap = mainSaleEtherCap;
		    maxEth = mainSaleEtherCap;
		    tokenMinusPerEther = tokenMinusPerEther.add(dayToMinusToken);
		    tokenMinusPerEther = tokenMinusPerEther.mul(mainSaleDay.sub(1));
		}
		
		require( saleTime >= 1 && saleTime <= 4 );
		require( msg.value >= minEth );
		require( icoEtherContributed[msg.sender].add(msg.value) <= maxEth );

		tokens = tokenPerEth.mul(msg.value) / 1 ether;
		tokenMinusPerEther = tokenMinusPerEther.mul(msg.value) / 1 ether;
      	tokens = tokens.mul(100 + tokenBonus) / 100;
      	tokens = tokens.sub(tokenMinusPerEther);

		if(saleTime == 1)
		{
		    require( icoEtherReceivedPrivateSale.add(msg.value) <= etherCap );
    
		    icoEtherReceivedPrivateSale = icoEtherReceivedPrivateSale.add(msg.value);
		    tokenIssuedPrivateIco = tokenIssuedPrivateIco.add(tokens);
		}
		else if(saleTime == 2)
		{
		    require( icoEtherReceivedPreFirstSale.add(msg.value) <= etherCap );
    
		    icoEtherReceivedPreFirstSale = icoEtherReceivedPreFirstSale.add(msg.value);
		    tokenIssuedPreFirstIco = tokenIssuedPreFirstIco.add(tokens);
		}
		else if(saleTime == 3)
		{
		    require( icoEtherReceivedPreSecondSale.add(msg.value) <= etherCap );
    
		    icoEtherReceivedPreSecondSale = icoEtherReceivedPreSecondSale.add(msg.value);
		    tokenIssuedPreSecondIco = tokenIssuedPreSecondIco.add(tokens);
		}
		else if(saleTime == 4)
		{
		    require( msg.value <= etherCap );
		    
		    if(tokenIssuedToday < mainSaleDay)
		    {
		        tokenIssuedToday = mainSaleDay;
		        icoEtherReceivedMainSaleDay = 0;
		    }
		    
		    require( icoEtherReceivedMainSaleDay.add(msg.value) <= etherCap );
    
		    icoEtherReceivedMainSale = icoEtherReceivedMainSale.add(msg.value);
		    icoEtherReceivedMainSaleDay = icoEtherReceivedMainSaleDay.add(msg.value);
		    tokenIssuedMainSaleIco = tokenIssuedMainSaleIco.add(tokens);
		}
		
		balances[msg.sender]         = balances[msg.sender].add(tokens);
	    icoTokenReceived[msg.sender] = icoTokenReceived[msg.sender].add(tokens);
		tokensIssuedTotal            = tokensIssuedTotal.add(tokens);
		icoEtherContributed[msg.sender] = icoEtherContributed[msg.sender].add(msg.value);
    
		Transfer(0x0, msg.sender, tokens);
		TokenIssued(msg.sender, tokens, balances[msg.sender], msg.value);

		wallet.transfer(this.balance);
  	}

 	function isTransferable() public constant returns (bool transferable)
	{
		if ( atNow() < preSaleSecondEndDate )
		{
			return false;
		}

		return true;
  	}

  	function changeWallet(address _wallet) onlyOwner public
	{
    		require( _wallet != address(0x0) );
    		wallet = _wallet;
    		WalletChange(wallet);
  	}

  	function changeAdminWallet(address _wallet) onlyOwner public
	{
    		require( _wallet != address(0x0) );
    		adminWallet = _wallet;
    		AdminWalletChange(adminWallet);
  	}

  	function mintMarketing(address _participant) onlyOwner public
	{
		uint tokens = mktTokenCap.sub(tokenIssuedAirDrop);
		
		balances[_participant] = balances[_participant].add(tokens);
		
		tokenIssuedMkt   = tokenIssuedMkt.add(tokens);
		tokenIssuedTotal = tokenIssuedTotal.add(tokens);
		
		Transfer(0x0, _participant, tokens);
		TokenMinted(_participant, tokens, balances[_participant]);
  	}

  	function mintLockUpTokens(address _participant) onlyOwner public
	{
		require ( atNow() >= mainSaleEndDate );
		
		uint tokens = totalTokenCap.sub(tokenIssuedTotal);
		
		balances[_participant] = balances[_participant].add(tokens);
		
		tokenIssuedLockUp = tokenIssuedLockUp.add(tokens);
		tokenIssuedTotal = tokenIssuedTotal.add(tokens);
		
		Transfer(0x0, _participant, tokens);
		TokenMinted(_participant, tokens, balances[_participant]);
  	}

  	function airDropOne(address _address, uint _amount) onlyOwner public
  	{
  	    uint tokens = _amount * E18;
		       
		balances[_address] = balances[_address].add(tokens);
		
		tokenIssuedAirDrop = tokenIssuedAirDrop.add(tokens);
        tokenIssuedTotal = tokenIssuedTotal.add(tokens);
		
        Transfer(0x0, _address, tokens);
        TokenAirDroped(_address, tokens, balances[_address]);
  	}

  	function airDropMultiple(address[] _addresses, uint[] _amounts) onlyOwner public
  	{
		require( _addresses.length == _amounts.length );
		
  	    uint tokens = 0;
  	    
		for (uint i = 0; i < _addresses.length; i++)
		{
		        tokens = _amounts[i] * E18;
				
		        balances[_addresses[i]] = balances[_addresses[i]].add(tokens);
		
				tokenIssuedAirDrop = tokenIssuedAirDrop.add(tokens);
		        tokenIssuedTotal = tokenIssuedTotal.add(tokens);
		
		        Transfer(0x0, _addresses[i], tokens);
		        TokenAirDroped(_addresses[i], tokens, balances[_addresses[i]]);
		}
  	}

  	function airDropMultipleSame(address[] _addresses, uint _amount) onlyOwner public
  	{
  	    uint tokens = _amount * E18;
  	    
		for (uint i = 0; i < _addresses.length; i++)
		{
		        balances[_addresses[i]] = balances[_addresses[i]].add(tokens);
		
				tokenIssuedAirDrop = tokenIssuedAirDrop.add(tokens);
		        tokenIssuedTotal = tokenIssuedTotal.add(tokens);
		
		        Transfer(0x0, _addresses[i], tokens);
		        TokenAirDroped(_addresses[i], tokens, balances[_addresses[i]]);
		}
  	}
  	
  	function ownerWithdraw() external onlyOwner
	{
		uint amount = this.balance;
		wallet.transfer(amount);
		WithDraw(msg.sender, amount);
  	}
  	
  	function transferAnyERC20Token(address tokenAddress, uint amount) onlyOwner public returns (bool success)
	{
  		return ERC20Interface(tokenAddress).transfer(owner, amount);
  	}
  	
  	function transfer(address _to, uint _amount) public returns (bool success)
	{
		require( isTransferable() );
		
		return super.transfer(_to, _amount);
  	}
  	
  	function transferFrom(address _from, address _to, uint _amount) public returns (bool success)
	{
		require( isTransferable() );
		
		return super.transferFrom(_from, _to, _amount);
  	}

  	function transferMultiple(address[] _addresses, uint[] _amounts) external
  	{
		require( isTransferable() );
		require( _addresses.length == _amounts.length );
		
		for (uint i = 0; i < _addresses.length; i++)
		{
			super.transfer(_addresses[i], _amounts[i]);
		}
  	}

  	function reclaimFunds() external
	{
		uint tokens;
		uint amount;

		require( atNow() > preSaleSecondEndDate );
		require( !refundClaimed[msg.sender] );
		require( icoEtherContributed[msg.sender] > 0 );

		tokens = icoTokenReceived[msg.sender];
		amount = icoEtherContributed[msg.sender];

		balances[msg.sender] = balances[msg.sender].sub(tokens);
		tokensIssuedTotal    = tokensIssuedTotal.sub(tokens);

		refundClaimed[msg.sender] = true;

		msg.sender.transfer(amount);

		Transfer(msg.sender, 0x0, tokens);
		Refund(msg.sender, amount, tokens);
  	}
  	
    function transferToOwner(address _from) onlyOwner public
    {
        uint amount = balanceOf(_from);
        
        balances[_from] = balances[_from].sub(amount);
        balances[owner] = balances[owner].add(amount);
        
        Transfer(_from, owner, amount);
        OwnerReclaim(_from, owner, amount);
    }
}