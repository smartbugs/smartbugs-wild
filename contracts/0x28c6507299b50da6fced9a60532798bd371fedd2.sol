pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;

////// Version 4.1 ////// 

// Contract 01
contract OwnableContract {    
    event onTransferOwnership(address newOwner);
	address superOwner; 
	
    constructor() public { 
        superOwner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == superOwner);
        _;
    } 
	
    function viewSuperOwner() public view returns (address owner) {
        return superOwner;
    }
      
    function changeOwner(address newOwner) onlyOwner public {
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
    
    function doBlockContract() onlyOwner public {
        blockedContract = true;        
        emit onBlockHODLs(blockedContract);
    }
    
    function unBlockContract() onlyOwner public {
        blockedContract = false;        
        emit onBlockHODLs(blockedContract);
    }
}

// Contract 03
contract ldoh is BlockableContract {
    
	event onCashbackCode(address indexed hodler, address cashbackcode);
    event onStoreProfileHash(address indexed hodler, string profileHashed);
    event onHodlTokens(address indexed hodler, address indexed tokenAddress, string tokenSymbol, uint256 amount, uint256 endtime);
    event onClaimTokens(address indexed hodler, address indexed tokenAddress, string tokenSymbol, uint256 amount, uint256 endtime);
    event onReturnAll(uint256 returned);
	
    // Variables // * = New ** = Undeveloped	
    address internal AXPRtoken;
    mapping(address => string) public profileHashed; 		// User Prime 
	mapping(address => address) public cashbackcode; 		// Cashback Code 
	mapping(address => bool) public contractaddress; 		// Contract Address
	
	// Default Setting
	uint256 public 	percent 				= 1200;        	// * Percent Permonth ( Only Test = 1200% )
	uint256 private constant affiliate 		= 12;        	// * 12% from deposit
	uint256 private constant cashback 		= 16;        	// * 16% from deposit
	uint256 private constant totalreceive 	= 88;        	// * 88% from deposit	
    uint256 private constant seconds30days 	= 2592000;  	// *

    struct Safe {
        uint256 id;
        uint256 amount;
        uint256 endtime;
        address user;
        address tokenAddress;
		string  tokenSymbol;	
		uint256 amountbalance; 			// * --- > 88% from deposit
		uint256 cashbackbalance; 		// * --- > 16% from deposit
		uint256 lasttime; 				// * --- > Last Withdraw
		uint256 percentage; 			// * --- > return tokens every month
		uint256 percentagereceive; 		// * --- > 0 %
		uint256 tokenreceive; 			// * --- > 0 Token
		uint256 affiliatebalance; 		// **
		address referrer; 				// **

    }
    
	mapping(address => uint256[]) 	public 	_userSafes;			// ?????
    mapping(address => uint256) 	public 	_totalSaved; 		// Token Balance
	mapping(uint256 => Safe) 		private _safes; 			// Struct safe database
    uint256 						private _currentIndex; 		// Sequential number ( Start from 500 )
	uint256 						public _countSafes; 		// Total Smart Contract User
	uint256 						public hodlingTime;			
    uint256 						public allTimeHighPrice;
    uint256 						public comission;
	
    mapping(address => uint256) 	private _systemReserves;    // Token Balance ( Reserve )
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
        require(amount > 0);
		
		if (contractaddress[tokenAddress] = false) {
			revert();
		}
		else {
			
		
        ERC20Interface token = ERC20Interface(tokenAddress);       
        require(token.transferFrom(msg.sender, address(this), amount));
		
		uint256 affiliatecomission 		= mul(amount, affiliate) / 100; 	// *
		uint256 nocashback 				= mul(amount, 28) / 100; 	// *
		
		 	if (cashbackcode[msg.sender] == 0 ) { 				
			uint256 data_amountbalance 		= mul(amount, 72) / 100;
			uint256 data_cashbackbalance 	= 0; 
			address data_referrer			= superOwner;
			
			cashbackcode[msg.sender] = superOwner;
			emit onCashbackCode(msg.sender, superOwner);
			
			_systemReserves[tokenAddress] 	= add(_systemReserves[tokenAddress], nocashback);
			
			} else { 	
			data_amountbalance 		= sub(amount, affiliatecomission);	
			data_cashbackbalance 	= mul(amount, cashback) / 100;
			data_referrer			= cashbackcode[msg.sender];

			_systemReserves[tokenAddress] 	= add(_systemReserves[tokenAddress], affiliatecomission); } //--->>> Dont forget to change code
			  		  				  					  
	// Insert to Database  			 	  
		_userSafes[msg.sender].push(_currentIndex);
		_safes[_currentIndex] = 

		Safe(
		_currentIndex, amount, now + hodlingTime, msg.sender, tokenAddress, token.symbol(), data_amountbalance, data_cashbackbalance, now, percent, 0, 0, 0, data_referrer);				
		
	// Update Token Balance, Current Index, CountSafes		
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
			
	    s.amountbalance = 0;
		emit onClaimTokens(msg.sender, eventTokenAddress, eventTokenSymbol, eventAmount, now);
		
        }
        else 
        {
			
			uint256 timeframe  			= sub(now, s.lasttime);
			uint256 CalculateWithdraw 	= s.amount * s.percentage / 100 * timeframe / seconds30days ;		// SAFE MATH FUNCTIONS ???	
			uint256 MaxWithdraw 		= mul(s.amount, 10);
			
			// Maximum withdraw before unlocked, Max 10% Accumulation
			if (CalculateWithdraw > MaxWithdraw) { 				
			uint256 MaxAccumulation = MaxWithdraw; 
			} else { MaxAccumulation = CalculateWithdraw; }
			
			// Maximum withdraw = User Amount Balance   
			if (MaxAccumulation > s.amountbalance) { 			     	
			uint256 realAmount = s.amountbalance; 
			} else { realAmount = MaxAccumulation; }
			   				
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
		
			uint256 tokenaffiliate 		= mul(s.amount, affiliate) / 100 ; 
			uint256 tokenreceived 		= s.amount - tokenaffiliate - newamountbalance;	  		// * SAFE MATH FUNCTIONS ???		
			uint256 percentagereceived 	= tokenreceived / s.amount * 100000000000000000000;	  	// * SAFE MATH FUNCTIONS ???	
		
		s.tokenreceive 					= tokenreceived; 
		s.percentagereceive 			= percentagereceived; 		
		_totalSaved[s.tokenAddress] 	= sub(_totalSaved[s.tokenAddress], realAmount); 
		
		
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
		
		if (cashbackcode[msg.sender] == 0) {
			cashbackcode[msg.sender] = _cashbackcode;
			emit onCashbackCode(msg.sender, _cashbackcode);
		}		             
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
	
	
		    function ContractAddress(address _contractaddress, bool status) public {
		
		contractaddress[_contractaddress] = status;
		
			             
    }
	
	
////////////////////////////////// onlyOwner //////////////////////////////////

// 00 Insert Token Contract Address	
    function AddContractAddress(address tokenAddress, bool contractstatus) public onlyOwner {
        contractaddress[tokenAddress] = contractstatus;
    }
	
// 01 Claim ( By Owner )	
    function OwnerRetireHodl(address tokenAddress, uint256 id) public onlyOwner {
        require(tokenAddress != 0x0);
        require(id != 0);      
        RetireHodl(tokenAddress, id);
    }
    
// 02 Change Hodling Time   
    function ChangeHodlingTime(uint256 newHodlingDays) onlyOwner public {
        require(newHodlingDays >= 60);      
        hodlingTime = newHodlingDays * 1 days;
    }   
    
// 03 Change All Time High Price   
    function ChangeAllTimeHighPrice(uint256 newAllTimeHighPrice) onlyOwner public {
        require(newAllTimeHighPrice > allTimeHighPrice);       
        allTimeHighPrice = newAllTimeHighPrice;
    }              

// 04 Change Comission Value   
    function ChangeComission(uint256 newComission) onlyOwner public {
        require(newComission <= 30);       
        comission = newComission;
    }
	
// 05 - Withdraw Ether Received Through Fallback Function    
    function WithdrawEth(uint256 amount) onlyOwner public {
        require(amount > 0); 
        require(address(this).balance >= amount); 
        
        msg.sender.transfer(amount);
    }
    
// 06 Withdraw Token Fees By Token Address   
    function WithdrawTokenFees(address tokenAddress) onlyOwner public {
        require(_systemReserves[tokenAddress] > 0);
        
        uint256 amount = _systemReserves[tokenAddress];
        _systemReserves[tokenAddress] = 0;
        
        ERC20Interface token = ERC20Interface(tokenAddress);
        
        require(token.balanceOf(address(this)) >= amount);
        token.transfer(msg.sender, amount);
    }

// 07 Withdraw All Eth And All Tokens Fees   
    function WithdrawAllFees() onlyOwner public {
        
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
        onlyOwner public view 
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
    function ReturnAllTokens(bool onlyAXPR) onlyOwner public
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
                    
                    _countSafes--;
                    returned++;
                }
            }
        }

        emit onReturnAll(returned);
    }   



//////////////////////////////////////////////// 	
	

    /**
    * SAFE MATH FUNCTIONS
    * 
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
    
    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }
    
    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    
    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
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