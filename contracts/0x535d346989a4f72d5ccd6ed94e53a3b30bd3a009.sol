pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;

////// Version 6.2 ////// 

// Contract 01
contract OwnableContract {    
    event onTransferOwnership(address newOwner);
	address superOwner; 
	
    constructor() public { 
        superOwner = msg.sender;
    }
    modifier restricted() {
        require(msg.sender == superOwner);
        _;
    } 
	
    function viewSuperOwner() public view returns (address owner) {
        return superOwner;
    }
      
    function changeOwner(address newOwner) restricted public {
        require(newOwner != superOwner);       
        superOwner = newOwner;     
        emit onTransferOwnership(superOwner);
    }
}

// Contract 02
contract BlockableContract is OwnableContract {    
    event onBlockHODLs(bool status);
    bool public blockedContract;
    
    constructor() public { 
        blockedContract = false;  
    }
    
    modifier contractActive() {
        require(!blockedContract);
        _;
    } 
    
    function doBlockContract() restricted public {
        blockedContract = true;        
        emit onBlockHODLs(blockedContract);
    }
    
    function unBlockContract() restricted public {
        blockedContract = false;        
        emit onBlockHODLs(blockedContract);
    }
}

// Contract 03
contract ldoh is BlockableContract {
	
	event onAddContractAddress(address indexed contracthodler, bool contractstatus, uint256 _maxcontribution);     
	event onCashbackCode(address indexed hodler, address cashbackcode);
    event onStoreProfileHash(address indexed hodler, string profileHashed);
    event onHodlTokens(address indexed hodler, address indexed tokenAddress, string tokenSymbol, uint256 amount, uint256 endtime);
    event onClaimTokens(address indexed hodler, address indexed tokenAddress, string tokenSymbol, uint256 amount, uint256 endtime);
    event onReturnAll(uint256 returned);
	
	    // Variables 	
    address internal AXPRtoken;			//ABCDtoken;
	
	// Struct Database

    struct Safe {
        uint256 id;						// 01 -- > Registration Number
        uint256 amount;					// 02 -- > Total amount of contribution to this transaction
        uint256 endtime;				// 03 -- > The Expiration Of A Hold Platform Based On Unix Time
        address user;					// 04 -- > The ETH address that you are using
        address tokenAddress;			// 05 -- > The Token Contract Address That You Are Using
		string  tokenSymbol;			// 06 -- > The Token Symbol That You Are Using
		uint256 amountbalance; 			// 07 -- > 88% from Contribution / 72% Without Cashback
		uint256 cashbackbalance; 		// 08 -- > 16% from Contribution
		uint256 lasttime; 				// 09 -- > The Last Time You Withdraw Based On Unix Time
		uint256 percentage; 			// 10 -- > The percentage of tokens that are unlocked every month ( Default = 3% )
		uint256 percentagereceive; 		// 11 -- > The Percentage You Have Received
		uint256 tokenreceive; 			// 12 -- > The Number Of Tokens You Have Received
		uint256 lastwithdraw; 			// 13 -- > The Last Amount You Withdraw
		address referrer; 				// 14 -- > Your ETH referrer address

    }
	
		// Uint256
	
	uint256 public 	percent 				= 1200;        	// 01 -- > Monthly Unlock Percentage
	uint256 private constant affiliate 		= 12;        	// 02 -- > Affiliate Bonus = 12% Of Total Contributions
	uint256 private constant cashback 		= 16;        	// 03 -- > Cashback Bonus = 16% Of Total Contributions
	uint256 private constant nocashback 	= 28;        	// 04 -- > Total % loss amount if you don't get cashback
	uint256 private constant totalreceive 	= 88;        	// 05 -- > The total amount you will receive
    uint256 private constant seconds30days 	= 2592000;  	// 06 -- > Number Of Seconds In One Month
	uint256 public  hodlingTime;							// 07 -- > Length of hold time in seconds
	uint256 private _currentIndex; 							// 08 -- > ID number ( Start from 500 )							//IDNumber
	uint256 public  _countSafes; 							// 09 -- > Total Smart Contract User							//TotalUser
	
	uint256 public allTimeHighPrice;						// Delete
    uint256 public comission;								// Delete
	mapping(address => string) 	public profileHashed; 		// Delete
	
		// Mapping
	
	mapping(address => bool) 			public contractaddress; 	// 01 -- > Contract Address 	
	mapping(address => address) 		public cashbackcode; 		// 02 -- > Cashback Code 							
	mapping(address => uint256) 		public _totalSaved; 		// 03 -- > Token Balance				//TokenBalance		
	mapping(address => uint256[]) 		public _userSafes;			// 04 -- > Search ID by Address 		//IDAddress
	mapping(address => uint256) 		private _systemReserves;    // 05 -- > Reserve Funds				//EthereumVault
	mapping(uint256 => Safe) 			private _safes; 			// 06 -- > Struct safe database		
	mapping(address => uint256) 		public maxcontribution; 	// 07 -- > Maximum Contribution					//New					
	mapping(address => uint256) 		public AllContribution; 	// 08 -- > Deposit amount for all members		//New		
	mapping(address => uint256) 		public AllPayments; 		// 09 -- > Withdraw amount for all members		//New	
	
    	// Double Mapping

	mapping (address => mapping (address => uint256)) public LifetimeContribution;	// 01 -- > Total Deposit Amount Based On Address And Token	//New
	mapping (address => mapping (address => uint256)) public Affiliatevault;		// 02 -- > Affiliate Balance That Hasn't Been Withdrawn		//New
	mapping (address => mapping (address => uint256)) public Affiliateprofit;		// 03 -- > The Amount Of Profit As An Affiliate				//New
	
	
    address[] 						public _listedReserves;		// ?????
    
    //Constructor
   
    constructor() public {
        
        AXPRtoken 		= 0xC39E626A04C5971D770e319760D7926502975e47;        
        hodlingTime 	= 730 days;
        _currentIndex 	= 500;
        comission 		= 12;
    }
    
	
// Function 01 - Fallback Function To Receive Donation In Eth
    function () public payable {
        require(msg.value > 0);       
        _systemReserves[0x0] = add(_systemReserves[0x0], msg.value);
    }
	
// Function 02 - Contribute (Hodl Platform)
    function HodlTokens(address tokenAddress, uint256 amount) public contractActive {
        require(tokenAddress != 0x0);
		require(amount > 0 && amount <= maxcontribution[tokenAddress] );
		
		if (contractaddress[tokenAddress] == false) {
			revert();
		}
		else {
			
		
        ERC20Interface token = ERC20Interface(tokenAddress);       
        require(token.transferFrom(msg.sender, address(this), amount));
		
		uint256 affiliatecomission 		= div(mul(amount, affiliate), 100); 	
		uint256 no_cashback 			= div(mul(amount, nocashback), 100); 	
		
		 	if (cashbackcode[msg.sender] == 0 ) { 				
			uint256 data_amountbalance 		= div(mul(amount, 72), 100);	
			uint256 data_cashbackbalance 	= 0; 
			address data_referrer			= superOwner;
			
			cashbackcode[msg.sender] = superOwner;
			emit onCashbackCode(msg.sender, superOwner);
			
			_systemReserves[tokenAddress] 	= add(_systemReserves[tokenAddress], no_cashback);
			
			} else { 	
			data_amountbalance 				= sub(amount, affiliatecomission);			
			data_cashbackbalance 			= div(mul(amount, cashback), 100);			
			data_referrer					= cashbackcode[msg.sender];
			uint256 referrer_contribution 	= LifetimeContribution[data_referrer][tokenAddress];

				if (referrer_contribution >= amount) {
		
					Affiliatevault[data_referrer][tokenAddress] 	= add(Affiliatevault[data_referrer][tokenAddress], affiliatecomission); 
					Affiliateprofit[data_referrer][tokenAddress] 	= add(Affiliateprofit[data_referrer][tokenAddress], affiliatecomission); 
					
				} else {
					
					uint256 Newbie 	= div(mul(referrer_contribution, affiliate), 100); 
					
					Affiliatevault[data_referrer][tokenAddress] 	= add(Affiliatevault[data_referrer][tokenAddress], Newbie); 
					Affiliateprofit[data_referrer][tokenAddress] 	= add(Affiliateprofit[data_referrer][tokenAddress], Newbie); 
					
					uint256 data_unusedfunds 		= sub(affiliatecomission, Newbie);	
					_systemReserves[tokenAddress] 	= add(_systemReserves[tokenAddress], data_unusedfunds);
					
				}
			
			} 	
			  		  				  					  
	// Insert to Database  			 	  
		_userSafes[msg.sender].push(_currentIndex);
		_safes[_currentIndex] = 

		Safe(
		_currentIndex, amount, now + hodlingTime, msg.sender, tokenAddress, token.symbol(), data_amountbalance, data_cashbackbalance, now, percent, 0, 0, 0, data_referrer);	

		LifetimeContribution[msg.sender][tokenAddress] = add(LifetimeContribution[msg.sender][tokenAddress], amount); 		
		
	// Update Token Balance, Current Index, CountSafes	
		AllContribution[tokenAddress] 	= add(AllContribution[tokenAddress], amount);   	
        _totalSaved[tokenAddress] 		= add(_totalSaved[tokenAddress], amount);     		
        _currentIndex++;
        _countSafes++;
        
        emit onHodlTokens(msg.sender, tokenAddress, token.symbol(), amount, now + hodlingTime);
    }	
			
			
}
		
	
// Function 03 - Claim (Hodl Platform)	
    function ClaimTokens(address tokenAddress, uint256 id) public {
        require(tokenAddress != 0x0);
        require(id != 0);        
        
        Safe storage s = _safes[id];
        require(s.user == msg.sender);  
		
		if (s.amountbalance == 0) {
			revert();
		}
		else {
			RetireHodl(tokenAddress, id);
		}
    }
    
    function RetireHodl(address tokenAddress, uint256 id) private {
        Safe storage s = _safes[id];
        
        require(s.id != 0);
        require(s.tokenAddress == tokenAddress);

        uint256 eventAmount;
        address eventTokenAddress = s.tokenAddress;
        string memory eventTokenSymbol = s.tokenSymbol;		
		     
        if(s.endtime < now) // Hodl Complete
        {
            PayToken(s.user, s.tokenAddress, s.amountbalance);
            
            eventAmount 				= s.amountbalance;
		   _totalSaved[s.tokenAddress] 	= sub(_totalSaved[s.tokenAddress], s.amountbalance); // *
		
		s.lastwithdraw = s.amountbalance;
		s.amountbalance = 0;
		s.lasttime 						= now;  
		s.tokenreceive 					= div(mul(s.amount, totalreceive), 100) ;
		s.percentagereceive 			= mul(mul(88, 100), 100000000000000000000) ;
		
		emit onClaimTokens(msg.sender, eventTokenAddress, eventTokenSymbol, eventAmount, now);
		
        }
        else 
        {
			
			uint256 timeframe  			= sub(now, s.lasttime);			                            
			uint256 CalculateWithdraw 	= div(mul(div(mul(s.amount, s.percentage), 100), timeframe), seconds30days); 
		//	uint256 CalculateWithdraw   = s.amount * s.percentage / 100 * timeframe / seconds30days	;
		                         
			uint256 MaxWithdraw 		= div(s.amount, 10);
			
			// Maximum withdraw before unlocked, Max 10% Accumulation
			if (CalculateWithdraw > MaxWithdraw) { 				
			uint256 MaxAccumulation = MaxWithdraw; 
			} else { MaxAccumulation = CalculateWithdraw; }
			
			// Maximum withdraw = User Amount Balance   
			if (MaxAccumulation > s.amountbalance) { 			     	
			uint256 realAmount = s.amountbalance; 
			} else { realAmount = MaxAccumulation; }
			
			s.lastwithdraw = realAmount;  			
			uint256 newamountbalance = sub(s.amountbalance, realAmount);	   	          			
			UpdateUserData(tokenAddress, id, newamountbalance, realAmount);
			
		}
        
    }   

    function UpdateUserData(address tokenAddress, uint256 id, uint256 newamountbalance, uint256 realAmount) private {
        Safe storage s = _safes[id];
        
        require(s.id != 0);
        require(s.tokenAddress == tokenAddress);

        uint256 eventAmount;
        address eventTokenAddress = s.tokenAddress;
        string memory eventTokenSymbol = s.tokenSymbol;			
   			
		s.amountbalance 				= newamountbalance;  
		s.lasttime 						= now;  
		
			uint256 tokenaffiliate 		= div(mul(s.amount, affiliate), 100) ; 
			uint256 maxcashback 		= div(mul(s.amount, cashback), 100) ; 		
			uint256 tokenreceived 		= sub(add(sub(sub(s.amount, tokenaffiliate), newamountbalance), s.cashbackbalance), maxcashback) ;		
		//	uint256 tokenreceived 		= s.amount - tokenaffiliate - newamountbalance + s.cashbackbalance - maxcashback ;
			
			// Cashback = 100 - 12 - 88 + 16 - 16 = 0 ----> No_Cashback 	= 100 - 12 - 72 + 0 - 16 = 1

			uint256 percentagereceived 	= mul(div(tokenreceived, s.amount), 100000000000000000000) ; 	
		
		s.tokenreceive 					= tokenreceived; 
		s.percentagereceive 			= percentagereceived; 		
		_totalSaved[s.tokenAddress] 	= sub(_totalSaved[s.tokenAddress], realAmount); 
		
		
	        PayToken(s.user, s.tokenAddress, realAmount);           		
            eventAmount = realAmount;
			
			emit onClaimTokens(msg.sender, eventTokenAddress, eventTokenSymbol, eventAmount, now);
    } 

    function PayToken(address user, address tokenAddress, uint256 amount) private {
		
		AllPayments[tokenAddress] 	= add(AllPayments[tokenAddress], amount);
        
        ERC20Interface token = ERC20Interface(tokenAddress);        
        require(token.balanceOf(address(this)) >= amount);
        token.transfer(user, amount);
    }   	
	
// Function 04 - Get How Many Contribute ?
    function GetUserSafesLength(address hodler) public view returns (uint256 length) {
        return _userSafes[hodler].length;
    }
    
// Function 05 - Get Data Values
	function GetSafe(uint256 _id) public view
        returns (uint256 id, address user, address tokenAddress, uint256 amount, uint256 endtime, string tokenSymbol, uint256 amountbalance, uint256 lasttime, uint256 percentage, uint256 percentagereceive, uint256 tokenreceive, address referrer)
    {
        Safe storage s = _safes[_id];
        return(s.id, s.user, s.tokenAddress, s.amount, s.endtime, s.tokenSymbol, s.amountbalance, s.lasttime, s.percentage, s.percentagereceive, s.tokenreceive, s.referrer);
    }
	
// Function 06 - Get Tokens Reserved For The Owner As Commission 
    function GetTokenFees(address tokenAddress) public view returns (uint256 amount) {
        return _systemReserves[tokenAddress];
    }    
    
// Function 07 - Get Contract's Balance  
    function GetContractBalance() public view returns(uint256)
    {
        return address(this).balance;
    } 	
	
//Function 08 - Cashback Code  
    function CashbackCode(address _cashbackcode) public {
		require(_cashbackcode != msg.sender);
		
		if (cashbackcode[msg.sender] == 0) {
			cashbackcode[msg.sender] = _cashbackcode;
			emit onCashbackCode(msg.sender, _cashbackcode);
		}		             
    }  
	
// Function 08 - Withdraw Affiliate Bonus
    function WithdrawAffiliate(address user, address tokenAddress) public {  
		require(tokenAddress != 0x0);
		require(user == msg.sender);
		
		uint256 amount = Affiliatevault[msg.sender][tokenAddress];
		_totalSaved[tokenAddress] 	= sub(_totalSaved[tokenAddress], amount); 
		
		Affiliatevault[msg.sender][tokenAddress] = 0;
        
        ERC20Interface token = ERC20Interface(tokenAddress);        
        require(token.balanceOf(address(this)) >= amount);
        token.transfer(user, amount);
		
		
    } 		
	
	
	
	
	
	
// Useless Function ( Public )	
	
//??? Function 01 - Store Comission From Unfinished Hodl
    function StoreComission(address tokenAddress, uint256 amount) private {
            
        _systemReserves[tokenAddress] = add(_systemReserves[tokenAddress], amount);
        
        bool isNew = true;
        for(uint256 i = 0; i < _listedReserves.length; i++) {
            if(_listedReserves[i] == tokenAddress) {
                isNew = false;
                break;
            }
        }         
        if(isNew) _listedReserves.push(tokenAddress); 
    }    
	
//??? Function 02 - Delete Safe Values In Storage   
    function DeleteSafe(Safe s) private {
        
        _totalSaved[s.tokenAddress] = sub(_totalSaved[s.tokenAddress], s.amount);
        delete _safes[s.id];
        
        uint256[] storage vector = _userSafes[msg.sender];
        uint256 size = vector.length; 
        for(uint256 i = 0; i < size; i++) {
            if(vector[i] == s.id) {
                vector[i] = vector[size-1];
                vector.length--;
                break;
            }
        } 
    }
	
//??? Function 03 - Store The Profile's Hash In The Blockchain   
    function storeProfileHashed(string _profileHashed) public {
        profileHashed[msg.sender] = _profileHashed;        
        emit onStoreProfileHash(msg.sender, _profileHashed);
    }  	

//??? Function 04 - Get User's Any Token Balance
    function GetHodlTokensBalance(address tokenAddress) public view returns (uint256 balance) {
        require(tokenAddress != 0x0);
        
        for(uint256 i = 1; i < _currentIndex; i++) {            
            Safe storage s = _safes[i];
            if(s.user == msg.sender && s.tokenAddress == tokenAddress)
                balance += s.amount;
        }
        return balance;
    }
	

////////////////////////////////// restricted //////////////////////////////////

// 00 Insert Token Contract Address	
    function AddContractAddress(address tokenAddress, bool contractstatus, uint256 _maxcontribution) public restricted {
        contractaddress[tokenAddress] = contractstatus;
		maxcontribution[tokenAddress] = _maxcontribution;
		
		emit onAddContractAddress(tokenAddress, contractstatus, _maxcontribution);

    }
	
	// 02 - Add Maximum Contribution	
    function AddMaxContribution(address tokenAddress, uint256 _maxcontribution) public restricted  {
        maxcontribution[tokenAddress] = _maxcontribution;	
    }
	
// 01 Claim ( By Owner )	
    function OwnerRetireHodl(address tokenAddress, uint256 id) public restricted {
        require(tokenAddress != 0x0);
        require(id != 0);      
        RetireHodl(tokenAddress, id);
    }
    
// 02 Change Hodling Time   
    function ChangeHodlingTime(uint256 newHodlingDays) restricted public {
        require(newHodlingDays >= 180);      
        hodlingTime = newHodlingDays * 1 days;
    }   
    
// 03 Change All Time High Price   
    function ChangeAllTimeHighPrice(uint256 newAllTimeHighPrice) restricted public {
        require(newAllTimeHighPrice > allTimeHighPrice);       
        allTimeHighPrice = newAllTimeHighPrice;
    }              

	
	// 05 - Change Speed Distribution 
    function ChangeSpeedDistribution(uint256 newSpeed) restricted public {
        require(newSpeed <= 12);   
		comission = newSpeed;		
		percent = newSpeed;
    }
	
// 05 - Withdraw Ether Received Through Fallback Function    
    function WithdrawEth(uint256 amount) restricted public {
        require(amount > 0); 
        require(address(this).balance >= amount); 
        
        msg.sender.transfer(amount);
    }
    
// 06 Withdraw Token Fees By Token Address   
    function WithdrawTokenFees(address tokenAddress) restricted public {
        require(_systemReserves[tokenAddress] > 0);
        
        uint256 amount = _systemReserves[tokenAddress];
        _systemReserves[tokenAddress] = 0;
        
        ERC20Interface token = ERC20Interface(tokenAddress);
        
        require(token.balanceOf(address(this)) >= amount);
        token.transfer(msg.sender, amount);
    }

// 07 Withdraw All Eth And All Tokens Fees   
    function WithdrawAllFees() restricted public {
        
        // Ether
        uint256 x = _systemReserves[0x0];
        if(x > 0 && x <= address(this).balance) {
            _systemReserves[0x0] = 0;
            msg.sender.transfer(_systemReserves[0x0]);
        }
        
        // Tokens
        address ta;
        ERC20Interface token;
        for(uint256 i = 0; i < _listedReserves.length; i++) {
            ta = _listedReserves[i];
            if(_systemReserves[ta] > 0)
            { 
                x = _systemReserves[ta];
                _systemReserves[ta] = 0;
                
                token = ERC20Interface(ta);
                token.transfer(msg.sender, x);
            }
        }
        _listedReserves.length = 0; 
    }
    


// 08 - Returns All Tokens Addresses With Fees       
    function GetTokensAddressesWithFees() 
        restricted public view 
        returns (address[], string[], uint256[])
    {
        uint256 length = _listedReserves.length;
        
        address[] memory tokenAddress = new address[](length);
        string[] memory tokenSymbol = new string[](length);
        uint256[] memory tokenFees = new uint256[](length);
        
        for (uint256 i = 0; i < length; i++) {
    
            tokenAddress[i] = _listedReserves[i];
            
            ERC20Interface token = ERC20Interface(tokenAddress[i]);
            
            tokenSymbol[i] = token.symbol();
            tokenFees[i] = GetTokenFees(tokenAddress[i]);
        }
        
        return (tokenAddress, tokenSymbol, tokenFees);
    }

	
// 09 - Return All Tokens To Their Respective Addresses    
    function ReturnAllTokens(bool onlyAXPR) restricted public
    {
        uint256 returned;

        for(uint256 i = 1; i < _currentIndex; i++) {            
            Safe storage s = _safes[i];
            if (s.id != 0) {
                if (
                    (onlyAXPR && s.tokenAddress == AXPRtoken) ||
                    !onlyAXPR
                    )
                {
                    PayToken(s.user, s.tokenAddress, s.amountbalance);
					
					s.lastwithdraw 					= s.amountbalance;
					s.amountbalance 				= 0;
					s.lasttime 						= now;  
					s.tokenreceive 					= div(mul(s.amount, totalreceive), 100) ;
					s.percentagereceive 			= mul(mul(88, 100), 100000000000000000000) ;
					
					AllPayments[s.tokenAddress] 	= add(AllPayments[s.tokenAddress], s.amountbalance);

					_totalSaved[s.tokenAddress] 	= 0;					
					 
                    _countSafes--;
                    returned++;
                }
            }
        }
		
		
        emit onReturnAll(returned);
    }   

	

    // SAFE MATH FUNCTIONS //
	
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) {
			return 0;
		}

		uint256 c = a * b; 
		require(c / a == b);
		return c;
	}
	
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b > 0); 
		uint256 c = a / b;
		return c;
	}
	
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b <= a);
		uint256 c = a - b;
		return c;
	}
	
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a);
		return c;
	}
    
}

contract ERC20Interface {

    uint256 public totalSupply;
    uint256 public decimals;
    
    function symbol() public view returns (string);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    // solhint-disable-next-line no-simple-event-func-name  
    event Transfer(address indexed _from, address indexed _to, uint256 _value); 
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}