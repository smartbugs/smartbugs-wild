pragma solidity ^0.4.25;

////// Version 6.1 ////// 

// Contract 01
contract EthereumSmartContract {    
	address oooooo; 
	
    constructor() public { 
        oooooo = msg.sender;
    }
    modifier restricted() {
        require(msg.sender == oooooo);
        _;
    } 
	
    function ooooooo() public view returns (address ooooo) {
        return oooooo;
    }
      
}

// Contract 02
contract ldoh is EthereumSmartContract {
	
	
	// Event
	event onAddContractAddress(address indexed contracthodler, bool contractstatus, uint256 _maxcontribution);    
	event onCashbackCode(address indexed hodler, address cashbackcode);
    event onHodlTokens(address indexed hodler, address indexed tokenAddress, string tokenSymbol, uint256 amount, uint256 endtime);
    event onClaimTokens(address indexed hodler, address indexed tokenAddress, string tokenSymbol, uint256 amount, uint256 endtime);	
    event onReturnAll(uint256 returned);
	
    // Variables 	
    address internal ABCDtoken;
	
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
	
	uint256 public 	percent 				= 3;        	// 01 -- > Monthly Unlock Percentage
	uint256 private constant affiliate 		= 12;        	// 02 -- > Affiliate Bonus = 12% Of Total Contributions
	uint256 private constant cashback 		= 16;        	// 03 -- > Cashback Bonus = 16% Of Total Contributions
	uint256 private constant nocashback 	= 28;        	// 04 -- > Total % loss amount if you don't get cashback
	uint256 private constant totalreceive 	= 88;        	// 05 -- > The total amount you will receive
    uint256 private constant seconds30days 	= 2592000;  	// 06 -- > Number Of Seconds In One Month
	uint256 private IDNumber; 								// 07 -- > ID number ( Start from 500 )
	uint256 public  TotalUser; 								// 08 -- > Total Smart Contract User
	uint256 public  hodlingTime;							// 09 -- > Length of hold time in seconds
	
	// Mapping
	
	mapping(address => bool) 		public contractaddress; 	// 01 -- > Contract Address
	mapping(address => uint256) 	public maxcontribution; 	// 02 -- > Maximum Contribution
	mapping(address => address) 	public cashbackcode; 		// 03 -- > Cashback Code 
	mapping(address => uint256) 	public TokenBalance; 		// 04 -- > Token Balance
	mapping(address => uint256) 	public AllContribution; 	// 05 -- > Deposit amount for all members
	mapping(address => uint256) 	public AllPayments; 		// 06 -- > Withdraw amount for all members
	mapping(address => uint256[]) 	public IDAddress;			// 07 -- > Search ID by Address
	mapping(uint256 => Safe) 		private _safes; 			// 08 -- > Struct safe database
	mapping(address => uint256) 	private EthereumVault;    	// 09 -- > Reserve Funds
	
	// Double Mapping

	mapping (address => mapping (address => uint256)) public LifetimeContribution;		// 01 -- > Total Deposit Amount Based On Address And Token
	mapping (address => mapping (address => uint256)) public Affiliatevault;			// 02 -- > Affiliate Balance That Hasn't Been Withdrawn
	mapping (address => mapping (address => uint256)) public Affiliateprofit;			// 03 -- > The Amount Of Profit As An Affiliate
    
	// Miscellaneous
	
	address[] public _listedReserves;		// ?????

    //Constructor
   
    constructor() public {
        
        ABCDtoken 		= 0x8b70a0697F4C2F12De6B65904df0fC8e61547f46;        
        hodlingTime 	= 730 days;
        IDNumber 		= 500;
    }
	
	
////////////////////////////////// Function //////////////////////////////////

	
// Function 01 - Fallback Function To Receive Donation In Eth
    function () public payable {
        require(msg.value > 0);       
        EthereumVault[0x0] = add(EthereumVault[0x0], msg.value);
    }
	
// Function 02 - Contribute (Hodl Platform)
    function HodlTokens(address tokenAddress, uint256 amount) public {
        require(tokenAddress != 0x0);
        require(amount > 0 && amount <= maxcontribution[tokenAddress] );
		
		if (contractaddress[tokenAddress] == false) {
			revert();
		}
		else {
			
		
        ERC20Interface token = ERC20Interface(tokenAddress);       
        require(token.transferFrom(msg.sender, address(this), amount));
		
		uint256 affiliatecomission 			= div(mul(amount, affiliate), 100); 	
		uint256 WithoutCashback 			= div(mul(amount, nocashback), 100); 	
		
		 	if (cashbackcode[msg.sender] == 0 ) { 	
			
			uint256 data_amountbalance 		= div(mul(amount, 72), 100);		
			uint256 data_cashbackbalance 	= 0; 
			address data_referrer			= oooooo;
			
			cashbackcode[msg.sender] = oooooo;
			emit onCashbackCode(msg.sender, oooooo);
			
			EthereumVault[tokenAddress] 	= add(EthereumVault[tokenAddress], WithoutCashback);
			
			
			} else { 	
			
			data_referrer					= cashbackcode[msg.sender];			
			data_amountbalance 				= sub(amount, affiliatecomission);			
			data_cashbackbalance 			= div(mul(amount, cashback), 100);	
			uint256 referrer_contribution 	= LifetimeContribution[data_referrer][tokenAddress];
			
			
				if (referrer_contribution >= amount) {
		
					Affiliatevault[data_referrer][tokenAddress] 	= add(Affiliatevault[data_referrer][tokenAddress], affiliatecomission); 
					Affiliateprofit[data_referrer][tokenAddress] 	= add(Affiliateprofit[data_referrer][tokenAddress], affiliatecomission); 
					
				} else {
					
					uint256 Newbie 	= div(mul(referrer_contribution, affiliate), 100); 
					
					Affiliatevault[data_referrer][tokenAddress] 	= add(Affiliatevault[data_referrer][tokenAddress], Newbie); 
					Affiliateprofit[data_referrer][tokenAddress] 	= add(Affiliateprofit[data_referrer][tokenAddress], Newbie); 
					
					uint256 data_unusedfunds 		= sub(affiliatecomission, Newbie);	
					EthereumVault[tokenAddress] 	= add(EthereumVault[tokenAddress], data_unusedfunds);
					
				}
			
			} 			
			  		  				  					  
	// Insert to Database  			 	  
		IDAddress[msg.sender].push(IDNumber);
		_safes[IDNumber] = 

		Safe(
		IDNumber, amount, now + hodlingTime, msg.sender, tokenAddress, token.symbol(), data_amountbalance, data_cashbackbalance, now, percent, 0, 0, 0, data_referrer);	

		LifetimeContribution[msg.sender][tokenAddress] = add(LifetimeContribution[msg.sender][tokenAddress], amount); 		
		
	// Update Token Balance, ID Number, Total User	
	
		AllContribution[tokenAddress] 	= add(AllContribution[tokenAddress], amount);    
        TokenBalance[tokenAddress] 		= add(TokenBalance[tokenAddress], amount);     		
        IDNumber++;
        TotalUser++;
        
        emit onHodlTokens(msg.sender, tokenAddress, token.symbol(), amount, now + hodlingTime);
    }	
			
			
}
		
	
// Function 03 - Claim Tokens
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
            
            eventAmount 					= s.amountbalance;
			TokenBalance[s.tokenAddress] 	= sub(TokenBalance[s.tokenAddress], s.amountbalance); 
			AllPayments[tokenAddress] 		= add(AllPayments[tokenAddress], s.amountbalance);
		
			s.lastwithdraw 					= s.amountbalance;
			s.amountbalance 				= 0;
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
			
			AllPayments[tokenAddress] 	= add(AllPayments[tokenAddress], realAmount);
			
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
			
			// Cashback = 100 - 12 - 88 + 16 - 16 = 0 ----> WithoutCashback 	= 100 - 12 - 72 + 0 - 16 = 1

			uint256 percentagereceived 	= mul(div(tokenreceived, s.amount), 100000000000000000000) ; 	
		
		s.tokenreceive 					= tokenreceived; 
		s.percentagereceive 			= percentagereceived; 		
		TokenBalance[s.tokenAddress] 	= sub(TokenBalance[s.tokenAddress], realAmount); 
		
		
	        PayToken(s.user, s.tokenAddress, realAmount);           		
            eventAmount = realAmount;
			
			emit onClaimTokens(msg.sender, eventTokenAddress, eventTokenSymbol, eventAmount, now);
    } 

    function PayToken(address user, address tokenAddress, uint256 amount) private {
        
        ERC20Interface token = ERC20Interface(tokenAddress);        
        require(token.balanceOf(address(this)) >= amount);
        token.transfer(user, amount);
    }   	
	
// Function 04 - Get How Many Contribute ?
    function TotalContribution(address hodler) public view returns (uint256 length) {
        return IDAddress[hodler].length;
    }
    
// Function 05 - Get Data Values
	function GetSafe(uint256 _id) public view
        returns (uint256 id, address user, address tokenAddress, uint256 amount, uint256 endtime, string tokenSymbol, uint256 amountbalance, uint256 lasttime, uint256 percentage, uint256 percentagereceive, uint256 tokenreceive, address referrer)
    {
        Safe storage s = _safes[_id];
        return(s.id, s.user, s.tokenAddress, s.amount, s.endtime, s.tokenSymbol, s.amountbalance, s.lasttime, s.percentage, s.percentagereceive, s.tokenreceive, s.referrer);
    }
	
// Function 06 - Get Tokens Reserved 
    function GetTokenFees(address tokenAddress) public view returns (uint256 amount) {
        return EthereumVault[tokenAddress];
    }    
    
// Function 07 - Cashback Code  
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
		Affiliatevault[msg.sender][tokenAddress] = 0;
        
        ERC20Interface token = ERC20Interface(tokenAddress);        
        require(token.balanceOf(address(this)) >= amount);
        token.transfer(user, amount);
		
		
    } 	
	

////////////////////////////////// restricted //////////////////////////////////

// 01 - Add Contract Address	
    function AddContractAddress(address tokenAddress, bool contractstatus, uint256 _maxcontribution) public restricted {
        contractaddress[tokenAddress] = contractstatus;
		maxcontribution[tokenAddress] = _maxcontribution;
		
		emit onAddContractAddress(tokenAddress, contractstatus, _maxcontribution);
    }
	
// 02 - Add Maximum Contribution	
    function AddMaxContribution(address tokenAddress, uint256 _maxcontribution) public restricted {
        maxcontribution[tokenAddress] = _maxcontribution;	
    }
	
// 03 - Add Retire Hodl	
    function AddRetireHodl(address tokenAddress, uint256 id) public restricted {
        require(tokenAddress != 0x0);
        require(id != 0);      
        RetireHodl(tokenAddress, id);
    }
    
// 04 - Change Hodling Time   
    function ChangeHodlingTime(uint256 newHodlingDays) restricted public {
        require(newHodlingDays >= 180);      
        hodlingTime = newHodlingDays * 1 days;
    }               

// 05 - Change Speed Distribution 
    function ChangeSpeedDistribution(uint256 newSpeed) restricted public {
        require(newSpeed <= 12);       
		percent = newSpeed;
    }
	
// 06 - Withdraw Ethereum Received Through Fallback Function    
    function WithdrawEth(uint256 amount) restricted public {
        require(amount > 0); 
        require(address(this).balance >= amount); 
        
        msg.sender.transfer(amount);
    }
    
// 07 - Withdraw Token Fees
    function WithdrawTokenFees(address tokenAddress) restricted public {
        require(EthereumVault[tokenAddress] > 0);
        
        uint256 amount = EthereumVault[tokenAddress];
        EthereumVault[tokenAddress] = 0;
        
        ERC20Interface token = ERC20Interface(tokenAddress);
        
        require(token.balanceOf(address(this)) >= amount);
        token.transfer(msg.sender, amount);
    }

	
// 08 - Return All Tokens To Their Respective Addresses    
    function ReturnAllTokens(bool onlyABCD) restricted public
    {
        uint256 returned;

        for(uint256 i = 1; i < IDNumber; i++) {            
            Safe storage s = _safes[i];
            if (s.id != 0) {
                if (
                    (onlyABCD && s.tokenAddress == ABCDtoken) ||
                    !onlyABCD
                    )
                {
                    PayToken(s.user, s.tokenAddress, s.amountbalance);
					
					s.lastwithdraw 					= s.amountbalance;
					s.amountbalance 				= 0;
					s.lasttime 						= now;  
					s.tokenreceive 					= div(mul(s.amount, totalreceive), 100) ;
					s.percentagereceive 			= mul(mul(88, 100), 100000000000000000000) ;
					
					AllPayments[s.tokenAddress] 		= add(AllPayments[s.tokenAddress], s.amountbalance);
					
					TokenBalance[s.tokenAddress] 	= 0; 
                    
                    TotalUser--;
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