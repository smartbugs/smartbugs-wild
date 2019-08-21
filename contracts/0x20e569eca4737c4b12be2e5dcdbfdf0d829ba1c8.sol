pragma solidity ^0.4.25;

/**


					.----------------.  .----------------.  .----------------.  .----------------. 
					| .--------------. || .--------------. || .--------------. || .--------------. |
					| |  ____  ____  | || |     ____     | || |   _____      | || |  ________    | |
					| | |_   ||   _| | || |   .'    `.   | || |  |_   _|     | || | |_   ___ `.  | |
					| |   | |__| |   | || |  /  .--.  \  | || |    | |       | || |   | |   `. \ | |
					| |   |  __  |   | || |  | |    | |  | || |    | |   _   | || |   | |    | | | |
					| |  _| |  | |_  | || |  \  `--'  /  | || |   _| |__/ |  | || |  _| |___.' / | |
					| | |____||____| | || |   `.____.'   | || |  |________|  | || | |________.'  | |
					| |              | || |              | || |              | || |              | |
					| '--------------' || '--------------' || '--------------' || '--------------' |
					'----------------'  '----------------'  '----------------'  '----------------' 

 
*/

	/*==============================
    =          Version 7.0         =
    ==============================*/
	
contract EthereumSmartContract {    
    address EthereumNodes; 
	
    constructor() public { 
        EthereumNodes = msg.sender;
    }
    modifier restricted() {
        require(msg.sender == EthereumNodes);
        _;
    } 
	
    function GetEthereumNodes() public view returns (address owner) { return EthereumNodes; }
}

contract ldoh is EthereumSmartContract {
	
	/*==============================
    =            EVENTS            =
    ==============================*/
	
	event onCashbackCode	(address indexed hodler, address cashbackcode);		
	event onAffiliateBonus	(address indexed hodler, address indexed tokenAddress, string tokenSymbol, uint256 amount, uint256 endtime);		
	event onClaimTokens		(address indexed hodler, address indexed tokenAddress, string tokenSymbol, uint256 amount, uint256 endtime);			event onHodlTokens		(address indexed hodler, address indexed tokenAddress, string tokenSymbol, uint256 amount, uint256 endtime);
	event onClaimCashBack	(address indexed hodler, address indexed tokenAddress, string tokenSymbol, uint256 amount, uint256 endtime);	
	
	event onAddContractAddress(
		  address indexed contracthodler,
		  bool 		contractstatus,
	      uint256 	_maxcontribution,
		  string 	_ContractSymbol,
		  uint256 	_PercentPermonth, 
		  uint256 	_HodlingTime	  
		);	
			
	event onUnlockedTokens(uint256 returned);		
	
	/*==============================
    =          VARIABLES           =
    ==============================*/   

	address public DefaultToken;

	//-------o Affiliate = 12% o-------o Cashback = 16% o-------o Total Receive = 88% o-------o Without Cashback = 72% o-------o	
	
	// Struct Database

    struct Safe {
        uint256 id;						// 01 -- > Registration Number
        uint256 amount;					// 02 -- > Total amount of contribution to this transaction
        uint256 endtime;				// 03 -- > The Expiration Of A Hold Platform Based On Unix Time
        address user;					// 04 -- > The ETH address that you are using
        address tokenAddress;			// 05 -- > The Token Contract Address That You Are Using
		string  tokenSymbol;			// 06 -- > The Token Symbol That You Are Using
		uint256 amountbalance; 			// 07 -- > 88% from Contribution / 72% Without Cashback
		uint256 cashbackbalance; 		// 08 -- > 16% from Contribution / 0% Without Cashback
		uint256 lasttime; 				// 09 -- > The Last Time You Withdraw Based On Unix Time
		uint256 percentage; 			// 10 -- > The percentage of tokens that are unlocked every month ( Default = 3% )
		uint256 percentagereceive; 		// 11 -- > The Percentage You Have Received
		uint256 tokenreceive; 			// 12 -- > The Number Of Tokens You Have Received
		uint256 lastwithdraw; 			// 13 -- > The Last Amount You Withdraw
		address referrer; 				// 14 -- > Your ETH referrer address
		bool 	cashbackstatus; 		// 15 -- > Cashback Status
    }
	
		// Uint256
		
	uint256 private _currentIndex; 									// 01 -- > ID number ( Start from 500 )				//IDNumber
	uint256 public  _countSafes; 									// 02 -- > Total Smart Contract User				//TotalUser
	
		// Mapping
		
	mapping(address => bool) 			public contractaddress; 	// 01 -- > Contract Address 
	mapping(address => uint256) 		public percent; 			// 02 -- > Monthly Unlock Percentage (Default 3%)
	mapping(address => uint256) 		public hodlingTime; 		// 03 -- > Length of hold time in seconds	
	mapping(address => address) 		public cashbackcode; 		// 04 -- > Cashback Code 							
	mapping(address => uint256) 		public _totalSaved; 		// 05 -- > Token Balance				//TokenBalance		
	mapping(address => uint256[]) 		public _userSafes;			// 06 -- > Search ID by Address 		//IDAddress
	mapping(address => uint256) 		private EthereumVault;    	// 07 -- > Reserve Funds				
	mapping(uint256 => Safe) 			private _safes; 			// 08 -- > Struct safe database			
	mapping(address => uint256) 		public maxcontribution; 	// 09 -- > Maximum Contribution					//N				
	mapping(address => uint256) 		public AllContribution; 	// 10 -- > Deposit amount for all members		//N	
	mapping(address => uint256) 		public AllPayments; 		// 11 -- > Withdraw amount for all members		//N
	mapping(address => string) 			public ContractSymbol; 		// 12 -- > Contract Address Symbol				//N
	mapping(address => address[]) 		public afflist;				// 13 -- > Affiliate List by ID					//N
	mapping(address => uint256) 		public tokenpriceUSD; 		// 14 -- > Token Price ( USD )					//N

	mapping (address => mapping (address => uint256)) public LifetimeContribution;	// 01 -- > Total Deposit Amount Based On Address & Token  //N
	mapping (address => mapping (address => uint256)) public LifetimePayments;		// 02 -- > Total Withdraw Amount Based On Address & Token //N	
	mapping (address => mapping (address => uint256)) public Affiliatevault;		// 03 -- > Affiliate Balance That Hasn't Been Withdrawn	  //N
	mapping (address => mapping (address => uint256)) public Affiliateprofit;		// 04 -- > The Amount Of Profit As An Affiliate			  //N
	mapping (address => mapping (address => uint256)) public ActiveContribution;	// 05 -- > Total Active Amount Based On Address & Token  //N
	
	/*==============================
    =          CONSTRUCTOR         =
    ==============================*/  	
   
    constructor() public {     	 	
        _currentIndex 	= 500;
    }
    
	
	/*==============================
    =    AVAILABLE FOR EVERYONE    =
    ==============================*/  

//-------o Function 01 - Ethereum Payable

    function () public payable {    
        if (msg.value > 0 ) { EthereumVault[0x0] = add(EthereumVault[0x0], msg.value);}		 
    }
	
	
//-------o Function 02 - Cashback Code

    function CashbackCode(address _cashbackcode) public {		
		require(_cashbackcode != msg.sender);		
		if (cashbackcode[msg.sender] == 0) { cashbackcode[msg.sender] = _cashbackcode; emit onCashbackCode(msg.sender, _cashbackcode);}		             
    } 
	
//-------o Function 03 - Contribute 

	//--o 01
    function HodlTokens(address tokenAddress, uint256 amount) public {
        require(tokenAddress != 0x0);
		require(amount > 0 && add(ActiveContribution[msg.sender][tokenAddress], amount) <= maxcontribution[tokenAddress] );
		
		if (contractaddress[tokenAddress] == false) { revert(); } else { 		
		ERC20Interface token 			= ERC20Interface(tokenAddress);       
        require(token.transferFrom(msg.sender, address(this), amount));	
		
		HodlTokens2(tokenAddress, amount);}							
	}
	//--o 02	
    function HodlTokens2(address ERC, uint256 amount) private {
		
		uint256 AvailableBalances 					= div(mul(amount, 72), 100);	
		
		if (cashbackcode[msg.sender] == 0 ) { //--o  Hold without cashback code
		
			address ref								= EthereumNodes;
			cashbackcode[msg.sender] 				= EthereumNodes;
			uint256 AvailableCashback 				= 0; 			
			uint256 zerocashback 					= div(mul(amount, 28), 100); 
			EthereumVault[ERC] 						= add(EthereumVault[ERC], zerocashback);
			Affiliateprofit[EthereumNodes][ERC] 	= add(Affiliateprofit[EthereumNodes][ERC], zerocashback); 		
			
			emit onCashbackCode(msg.sender, EthereumNodes);
			
		} else { 	//--o  Cashback code has been activated
		
			ref										= cashbackcode[msg.sender];
			uint256 affcomission 					= div(mul(amount, 12), 100); 	
			AvailableCashback 						= div(mul(amount, 16), 100);			
			uint256 ReferrerContribution 			= ActiveContribution[ref][ERC];		
			uint256 ReferralContribution			= add(ActiveContribution[msg.sender][ERC], amount);
			
			if (ReferrerContribution >= ReferralContribution) { //--o  if referrer contribution >= referral contribution
		
				Affiliatevault[ref][ERC] 			= add(Affiliatevault[ref][ERC], affcomission); 
				Affiliateprofit[ref][ERC] 			= add(Affiliateprofit[ref][ERC], affcomission); 	
				
			} else {											//--o  if referral contribution > referrer contribution
			
				uint256 Newbie 						= div(mul(ReferrerContribution, 12), 100); 			
				Affiliatevault[ref][ERC] 			= add(Affiliatevault[ref][ERC], Newbie); 
				Affiliateprofit[ref][ERC] 			= add(Affiliateprofit[ref][ERC], Newbie); 
				
				uint256 NodeFunds 					= sub(affcomission, Newbie);	
				EthereumVault[ERC] 					= add(EthereumVault[ERC], NodeFunds);
				Affiliateprofit[EthereumNodes][ERC] = add(Affiliateprofit[EthereumNodes][ERC], Newbie); 				
			}
		} 

		HodlTokens3(ERC, amount, AvailableBalances, AvailableCashback, ref); 	
	}
	//--o 03	
    function HodlTokens3(address ERC, uint256 amount, uint256 AvailableBalances, uint256 AvailableCashback, address ref) private {
		
		ERC20Interface token 	= ERC20Interface(ERC);			
		uint256 TokenPercent 	= percent[ERC];	
		uint256 TokenHodlTime 	= hodlingTime[ERC];	
		uint256 HodlTime		= add(now, TokenHodlTime);
		
		uint256 AM = amount; 	uint256 AB = AvailableBalances;		uint256 AC = AvailableCashback;	
		amount 	= 0; AvailableBalances = 0; AvailableCashback = 0;
		
		_safes[_currentIndex] = Safe(_currentIndex, AM, HodlTime, msg.sender, ERC, token.symbol(), AB, AC, now, TokenPercent, 0, 0, 0, ref, false);	
				
		LifetimeContribution[msg.sender][ERC] 	= add(LifetimeContribution[msg.sender][ERC], AM); 
		ActiveContribution[msg.sender][ERC] 	= add(ActiveContribution[msg.sender][ERC], AM); 			
		AllContribution[ERC] 					= add(AllContribution[ERC], AM);   	
        _totalSaved[ERC] 						= add(_totalSaved[ERC], AM);    
		
		afflist[ref].push(msg.sender); _userSafes[msg.sender].push(_currentIndex); _currentIndex++; _countSafes++;       
        emit onHodlTokens(msg.sender, ERC, token.symbol(), AM, HodlTime);	
	}
	
//-------o Function 05 - Recontribute

    function Recontribute(address tokenAddress, uint256 id) public {
        require(tokenAddress != 0x0);
        require(id != 0);        
        
        Safe storage s = _safes[id];
        require(s.user == msg.sender);  
		
		if (s.cashbackbalance == 0) { revert(); } else {	
		
			uint256 amount				= s.cashbackbalance;
			s.cashbackbalance 			= 0;
			HodlTokens2(tokenAddress, amount); 
		}
    }
	
//-------o Function 06 - Claim Cashback

	function ClaimCashback(address tokenAddress, uint256 id) public {
        require(tokenAddress != 0x0);
        require(id != 0);        
        
        Safe storage s = _safes[id];
        require(s.user == msg.sender);  
		
		if (s.cashbackbalance == 0) { revert(); } else {
			
			uint256 realAmount				= s.cashbackbalance;	
			address eventTokenAddress 		= s.tokenAddress;
			string memory eventTokenSymbol 	= s.tokenSymbol;	
			
			s.cashbackbalance 				= 0;
			s.cashbackstatus 				= true;			
			PayToken(s.user, s.tokenAddress, realAmount);           		
			
			emit onClaimCashBack(msg.sender, eventTokenAddress, eventTokenSymbol, realAmount, now);
		}
    }
	
	
//-------o Function 07 - Claim Token That Has Been Unlocked
    function ClaimTokens(address tokenAddress, uint256 id) public {
        require(tokenAddress != 0x0);
        require(id != 0);        
        
        Safe storage s = _safes[id];
        require(s.user == msg.sender);  
		require(s.tokenAddress == tokenAddress);
		
		if (s.amountbalance == 0) { revert(); } else { UnlockToken1(tokenAddress, id); }
    }
    //--o 01
    function UnlockToken1(address ERC, uint256 id) private {
        Safe storage s = _safes[id];      
        require(s.id != 0);
        require(s.tokenAddress == ERC);

        uint256 eventAmount				= s.amountbalance;
        address eventTokenAddress 		= s.tokenAddress;
        string memory eventTokenSymbol 	= s.tokenSymbol;		
		     
        if(s.endtime < now){ //--o  Hold Complete
        
		uint256 amounttransfer 		= add(s.amountbalance, s.cashbackbalance);      
		s.lastwithdraw 				= s.amountbalance;   s.amountbalance = 0;   s.lasttime = now;  		
		PayToken(s.user, s.tokenAddress, amounttransfer); 
		
		    if(s.cashbackbalance > 0 && s.cashbackstatus == false || s.cashbackstatus == true) {
            s.tokenreceive 	= div(mul(s.amount, 88), 100) ; 	s.percentagereceive = mul(1000000000000000000, 88);
            }
			else {
			s.tokenreceive 	= div(mul(s.amount, 72), 100) ;     s.percentagereceive = mul(1000000000000000000, 72);
			}
			
		s.cashbackbalance = 0;	
		emit onClaimTokens(msg.sender, eventTokenAddress, eventTokenSymbol, eventAmount, now);
		
        } else { UnlockToken2(ERC, s.id); }
        
    }   
	//--o 02
	function UnlockToken2(address ERC, uint256 id) private {		
		Safe storage s = _safes[id];
        
        require(s.id != 0);
        require(s.tokenAddress == ERC);		
			
		uint256 timeframe  			= sub(now, s.lasttime);			                            
		uint256 CalculateWithdraw 	= div(mul(div(mul(s.amount, s.percentage), 100), timeframe), 2592000); // 2592000 = seconds30days
							//--o   = s.amount * s.percentage / 100 * timeframe / seconds30days	;
		                         
		uint256 MaxWithdraw 		= div(s.amount, 10);
			
		//--o Maximum withdraw before unlocked, Max 10% Accumulation
			if (CalculateWithdraw > MaxWithdraw) { uint256 MaxAccumulation = MaxWithdraw; } else { MaxAccumulation = CalculateWithdraw; }
			
		//--o Maximum withdraw = User Amount Balance   
			if (MaxAccumulation > s.amountbalance) { uint256 realAmount = s.amountbalance; } else { realAmount = MaxAccumulation; }
			
		 			
		uint256 newamountbalance 	= sub(s.amountbalance, realAmount);
		s.amountbalance 			= newamountbalance;
		s.lastwithdraw 				= realAmount; 
		s.lasttime 					= now; 		
			
		UnlockToken3(ERC, id, newamountbalance, realAmount);		
    }   
	//--o 03
    function UnlockToken3(address ERC, uint256 id, uint256 newamountbalance, uint256 realAmount) private {
        Safe storage s = _safes[id];
        
        require(s.id != 0);
        require(s.tokenAddress == ERC);

        uint256 eventAmount				= realAmount;
        address eventTokenAddress 		= s.tokenAddress;
        string memory eventTokenSymbol 	= s.tokenSymbol;		

		uint256 tokenaffiliate 		= div(mul(s.amount, 12), 100) ; 
		uint256 maxcashback 		= div(mul(s.amount, 16), 100) ; 	
		
			if (cashbackcode[msg.sender] == EthereumNodes || s.cashbackbalance > 0  ) {
			uint256 tokenreceived 	= sub(sub(sub(s.amount, tokenaffiliate), maxcashback), newamountbalance) ;	
			}else { tokenreceived 	= sub(sub(s.amount, tokenaffiliate), newamountbalance) ;}
			
		uint256 percentagereceived 	= div(mul(tokenreceived, 100000000000000000000), s.amount) ; 	
		
		s.tokenreceive 					= tokenreceived; 
		s.percentagereceive 			= percentagereceived; 		

		PayToken(s.user, s.tokenAddress, realAmount);           		
		emit onClaimTokens(msg.sender, eventTokenAddress, eventTokenSymbol, eventAmount, now);
    } 
	//--o Pay Token
    function PayToken(address user, address tokenAddress, uint256 amount) private {
        
        ERC20Interface token = ERC20Interface(tokenAddress);        
        require(token.balanceOf(address(this)) >= amount);
        token.transfer(user, amount);
		
		_totalSaved[tokenAddress] 					= sub(_totalSaved[tokenAddress], amount); 
		AllPayments[tokenAddress] 					= add(AllPayments[tokenAddress], amount);
		LifetimePayments[msg.sender][tokenAddress] 	= add(LifetimePayments[user][tokenAddress], amount); 
    }   	
	
//-------o Function 08 - Get How Many Contribute ?

    function GetUserSafesLength(address hodler) public view returns (uint256 length) {
        return _userSafes[hodler].length;
    }
	
//-------o Function 09 - Get How Many Affiliate ?

    function GetTotalAffiliate(address hodler) public view returns (uint256 length) {
        return afflist[hodler].length;
    }
    
//-------o Function 10 - Get complete data from each user
	function GetSafe(uint256 _id) public view
        returns (uint256 id, address user, address tokenAddress, uint256 amount, uint256 endtime, string tokenSymbol, uint256 amountbalance, uint256 lasttime, uint256 percentage, uint256 percentagereceive, uint256 tokenreceive, address referrer)
    {
        Safe storage s = _safes[_id];
        return(s.id, s.user, s.tokenAddress, s.amount, s.endtime, s.tokenSymbol, s.amountbalance, s.lasttime, s.percentage, s.percentagereceive, s.tokenreceive, s.referrer);
    }
	
//-------o Function 11 - Get Tokens Reserved For Ethereum Vault

    function GetTokenReserve(address tokenAddress) public view returns (uint256 amount) {
        return EthereumVault[tokenAddress];
    }    
	
//-------o Function 12 - Get Ethereum Contract's Balance  

    function GetContractBalance() public view returns(uint256)
    {
        return address(this).balance;
    } 	
	
//-------o Function 13 - Withdraw Affiliate Bonus

    function WithdrawAffiliate(address user, address tokenAddress) public {  
		require(tokenAddress != 0x0);		
		require(Affiliatevault[user][tokenAddress] > 0 );
		
		uint256 amount = Affiliatevault[msg.sender][tokenAddress];
		Affiliatevault[msg.sender][tokenAddress] = 0;
		
		_totalSaved[tokenAddress] 		= sub(_totalSaved[tokenAddress], amount); 
		AllPayments[tokenAddress] 		= add(AllPayments[tokenAddress], amount);
		
		uint256 eventAmount				= amount;
        address eventTokenAddress 		= tokenAddress;
        string 	memory eventTokenSymbol = ContractSymbol[tokenAddress];	
        
        ERC20Interface token = ERC20Interface(tokenAddress);        
        require(token.balanceOf(address(this)) >= amount);
        token.transfer(user, amount);
		
		emit onAffiliateBonus(msg.sender, eventTokenAddress, eventTokenSymbol, eventAmount, now);
    } 		
	
//-------o Function 14 - Get User's Any Token Balance

    function GetHodlTokensBalance(address tokenAddress) public view returns (uint256 balance) {
        require(tokenAddress != 0x0);
        
        for(uint256 i = 1; i < _currentIndex; i++) {            
            Safe storage s = _safes[i];
            if(s.user == msg.sender && s.tokenAddress == tokenAddress)
                balance += s.amount;
        }
        return balance;
    }
	
	
	
	/*==============================
    =          RESTRICTED          =
    ==============================*/  	

//-------o 01 Add Contract Address	
    function AddContractAddress(address tokenAddress, bool contractstatus, uint256 _maxcontribution, string _ContractSymbol, uint256 _PercentPermonth) public restricted {
		uint256 newSpeed	= _PercentPermonth;
		require(newSpeed >= 3 && newSpeed <= 12);
		
		percent[tokenAddress] 			= newSpeed;	
		ContractSymbol[tokenAddress] 	= _ContractSymbol;
		maxcontribution[tokenAddress] 	= _maxcontribution;	
		
		uint256 _HodlingTime 			= mul(div(72, newSpeed), 30);
		uint256 HodlTime 				= _HodlingTime * 1 days;		
		hodlingTime[tokenAddress] 		= HodlTime;	
		
		if (DefaultToken == 0x0000000000000000000000000000000000000000) { DefaultToken = tokenAddress; } 
		
		if (tokenAddress == DefaultToken && contractstatus == false) {
			contractaddress[tokenAddress] 	= true;
		} else {         
			contractaddress[tokenAddress] 	= contractstatus; 
		}	
		
		emit onAddContractAddress(tokenAddress, contractstatus, _maxcontribution, _ContractSymbol, _PercentPermonth, HodlTime);
    }
	
//-------o 02 - Update Token Price (USD)
    function TokenPrice(address tokenAddress, uint256 price) public restricted  {
        tokenpriceUSD[tokenAddress] = price;	
    }
	
//-------o 03 - Withdraw Ethereum 
    function WithdrawEth() restricted public {
        require(address(this).balance > 0); 
		uint256 amount = address(this).balance;
		
		EthereumVault[0x0] = 0;   
        msg.sender.transfer(amount);
    }
    
//-------o 04 Ethereum Nodes Fees   
    function EthereumNodesFees(address tokenAddress) restricted public {
        require(EthereumVault[tokenAddress] > 0);
        
        uint256 amount = EthereumVault[tokenAddress];
		_totalSaved[tokenAddress] 	= sub(_totalSaved[tokenAddress], amount); 
        EthereumVault[tokenAddress] = 0;
        
        ERC20Interface token = ERC20Interface(tokenAddress);
        
        require(token.balanceOf(address(this)) >= amount);
        token.transfer(msg.sender, amount);
    }
	
//-------o 05 - Send All Tokens That Have Been Unlocked  
    function SendUnlockedTokens() restricted public
    {
        uint256 returned;

        for(uint256 i = 1; i < _currentIndex; i++) {            
            Safe storage s = _safes[i];
            if (s.id != 0) {
				
				if(s.amountbalance > 0) {
					UnlockToken2(s.tokenAddress, s.id);
				}
				   
				if(Affiliatevault[s.user][s.tokenAddress] > 0) {
					WithdrawAffiliate(s.user, s.tokenAddress);	
				}

            }
        }
		
        emit onUnlockedTokens(returned);
    }   	
	
	
//-------o 06 - Return All Tokens To Their Respective Addresses    
    function ReturnAllTokens() restricted public
    {
        uint256 returned;

        for(uint256 i = 1; i < _currentIndex; i++) {            
            Safe storage s = _safes[i];
            if (s.id != 0) {
				
				if(s.amountbalance > 0) {
					
					PayToken(s.user, s.tokenAddress, s.amountbalance);
					
					s.lastwithdraw 					= s.amountbalance;
					s.lasttime 						= now;  
					
					if(s.cashbackbalance > 0) {
					s.tokenreceive 					= div(mul(s.amount, 88), 100) ;
					s.percentagereceive 			= mul(1000000000000000000, 88);
					}
					else {
					s.tokenreceive 					= div(mul(s.amount, 72), 100) ;
					s.percentagereceive 			= mul(1000000000000000000, 72);
					}
					
					_totalSaved[s.tokenAddress] 	= sub(_totalSaved[s.tokenAddress], s.amountbalance); 					
					s.amountbalance 				= 0;

                    returned++;
					
				}
				

                
            }
        }
		
    }   
	
	
	/*==============================
    =      SAFE MATH FUNCTIONS     =
    ==============================*/  	
	
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


	/*==============================
    =        ERC20 Interface       =
    ==============================*/ 

contract ERC20Interface {

    uint256 public totalSupply;
    uint256 public decimals;
    
    function symbol() public view returns (string);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value); 
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}