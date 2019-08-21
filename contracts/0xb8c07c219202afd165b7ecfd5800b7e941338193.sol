//Copyright Global Invest Place Ltd.
pragma solidity ^0.4.13;

library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a / b;
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


interface GlobalToken {
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Owned {
    address public owner;
    
    event OwnershipTransferred(address indexed _from, address indexed _to);

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner) ;
        _;
    }
	
	modifier onlyPayloadSize(uint numwords) {
        assert(msg.data.length == numwords * 32 + 4);
		_;
	}

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
        OwnershipTransferred(owner, newOwner);
    }
  
  function contractVersion() constant returns(uint256) {
        /*  contractVersion identifies as 100YYYYMMDDHHMM */
        return 100201712010000;
    }
}

// GlobalToken Interface
contract GlobalCryptoFund is Owned, GlobalToken {
    
    using SafeMath for uint256;
    
    /* Public variables of the token */
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;
	
	address public minter;
    
    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    
	modifier onlyMinter {
		require(msg.sender == minter);
		_;
	}
	
	function setMinter(address _addressMinter) onlyOwner {
		minter = _addressMinter;
	}
    
    /* Initializes contract with initial supply tokens to the creator of the contract */
    function GlobalCryptoFund() {
		name = "GlobalCryptoFund";                    								// Set the name for display purposes
        symbol = "GCF";                												// Set the symbol for display purposes
        decimals = 18;                          									// Amount of decimals for display purposes
        totalSupply = 0;                									// Update total supply
        balanceOf[msg.sender] = totalSupply;       									// Give the creator all initial tokens
    }
    
    function balanceOf(address _owner) constant returns (uint256 balance){
        return balanceOf[_owner];
    }
    
    /* Internal transfer, only can be called by this contract */
    function _transfer(address _from, address _to, uint256 _value) internal {
        require (_to != 0x0);                               						// Prevent transfer to 0x0 address. Use burn() instead
        require (balanceOf[_from] >= _value);                						// Check if the sender has enough
        require (balanceOf[_to].add(_value) >= balanceOf[_to]); 						// Check for overflows
        require(_to != address(this));
        balanceOf[_from] = balanceOf[_from].sub(_value);                         	// Subtract from the sender
        balanceOf[_to] = balanceOf[_to].add(_value);                           		// Add the same to the recipient
        Transfer(_from, _to, _value);
    }
    
    function transfer(address _to, uint256 _value) onlyPayloadSize(2) returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }
    
	event Mint(address indexed from, uint256 value);
    function mintToken(address target, uint256 mintedAmount) onlyMinter {
        balanceOf[target] = balanceOf[target].add(mintedAmount);
        totalSupply = totalSupply.add(mintedAmount);
        Transfer(0, this, mintedAmount);
        Transfer(this, target, mintedAmount);
        Mint(target, mintedAmount);
    }
    
	event Burn(address indexed from, uint256 value);
    function burn(uint256 _value) onlyMinter returns (bool success) {
        require (balanceOf[msg.sender] >= _value);            					// Check if the sender has enough
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);              // Subtract from the sender
        totalSupply = totalSupply.sub(_value);                                	// Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }  
	
	function kill() onlyOwner {
        selfdestruct(owner);
    }
    
    function contractVersion() constant returns(uint256) {
        /*  contractVersion identifies as 200YYYYMMDDHHMM */
        return 200201712010000;
    }
}

contract ExchangeManager is Owned {
	
	using SafeMath for uint256;
	 
    GlobalCryptoFund public gcf;
    ActualInfo[] public periods;
	address[] public accounts;
    
    struct ActualInfo {
        uint256 ethAtThePeriod;
        uint256 tokensAtThePeriod;
        
        uint256 price;
        
        uint256 ethForReederem;
    }
    
    uint256 ethTax;
    uint256 tokenTax;
	uint256 public currentPeriodPrice;
	uint256 public marketCap;
	
    modifier onlyReg {
        require(isReg[msg.sender]);
        _;
    }
  
    mapping (address => mapping (uint256 => uint256)) public buyTokens;
    mapping (address => mapping (uint256 => uint256)) public sellTokens;
	mapping (address => address) public myUserWallet;
    mapping (address => bool) public isReg;
	

    function ExchangeManager() {
        gcf = GlobalCryptoFund(0x26F45379d3f581e09719f1dC79c184302572AF00);
        require(gcf.contractVersion() == 200201712010000);
		
		uint256 newPeriod = periods.length++;
		ActualInfo storage info = periods[newPeriod];
		info.ethAtThePeriod = 0;
		info.tokensAtThePeriod = 0;
		info.price = 10000000000000000;
		info.ethForReederem = 0;
    }
	
	event TaxTillNow(uint256 _ethTx, uint256 _tokenTx);
	function taxTillNow() onlyOwner returns (uint256 _ethTax, uint256 _tokenTax) {
		TaxTillNow(ethTax, tokenTax);
		return (ethTax, tokenTax);
	}
	
	event RegisterEvent(address indexed _person, address indexed _userWallet);
    function Register() returns (address _userWallet) {
        _userWallet = address(new UserWallet(this, gcf));
        accounts.push(_userWallet);
        UserWallet(_userWallet).transferOwnership(msg.sender);
       
        isReg[_userWallet] = true;
        myUserWallet[msg.sender] = _userWallet;
        
		RegisterEvent(msg.sender, _userWallet);
        return _userWallet;
    }
	
    function getActualPeriod() returns (uint256) {
        return periods.length;
    }
	
	event ClosePeriodEvent(uint256 period, uint256 price, uint256 _marketCap, uint256 _ethForReederem);
    function closePeriod(uint256 _price, uint256 _marketCap, uint256 _ethForReederem) onlyOwner {
		uint256 period = getActualPeriod();
		ActualInfo storage info = periods[period.sub(1)];
		uint256 tokensAtThisPeriod = info.tokensAtThePeriod;
        //set Prices at this period
        info.price = _price;
		//calculate how much eth must have at the contract for reederem
		if(_ethForReederem != 0) {
			info.ethForReederem = _ethForReederem;
		} else {
			info.ethForReederem = ((info.tokensAtThePeriod).mul(_price)).div(1 ether);
		}
		currentPeriodPrice = _price;
		
		marketCap = _marketCap;
		
		ClosePeriodEvent(period, info.price, marketCap, info.ethForReederem);
		
		end();
    }

	function end() internal {
		uint256 period = periods.length ++;
		ActualInfo storage info = periods[period];
		info.ethAtThePeriod = 0;
		info.tokensAtThePeriod = 0;
		info.price = 0;
		info. ethForReederem = 0;
	}
	
    function getPrices() public returns (uint256 _Price) {
        return currentPeriodPrice;
    }
	
	event DepositEvent(address indexed _from, uint256 _amount);
    function() payable {
        DepositEvent(msg.sender, msg.value);
    }

	event BuyEvent(address indexed _from, uint256 period, uint256 _amountEthers, uint256 _ethAtThePeriod);
    function buy(uint256 _amount) onlyReg returns (bool) {
        require(_amount > 0.01 ether);
		
        uint256 thisPeriod = getActualPeriod();
        thisPeriod = thisPeriod.sub(1);
		
		uint256 tax = calculateTax(_amount);
		ethTax = ethTax.add(tax);
		uint256 _ethValue = _amount.sub(tax);
		
        buyTokens[msg.sender][thisPeriod] = buyTokens[msg.sender][thisPeriod].add(_ethValue);
		
		ActualInfo storage info = periods[thisPeriod];
		info.ethAtThePeriod = info.ethAtThePeriod.add(_ethValue);
		
		BuyEvent(msg.sender, thisPeriod, _amount, info.ethAtThePeriod);
		
		return true;
    }
	
	event ReederemEvent(address indexed _from, uint256 period, uint256 _amountTokens, uint256 _tokensAtThePeriod);
    function Reederem(uint256 _amount) onlyReg returns (bool) {
		require(_amount > 0);
		
        uint256 thisPeriod = getActualPeriod();
		thisPeriod = thisPeriod.sub(1);
		
		uint256 tax = calculateTax(_amount);
		tokenTax = tokenTax.add(tax);
		uint256 _tokensValue = _amount.sub(tax);
		
        sellTokens[msg.sender][thisPeriod] = sellTokens[msg.sender][thisPeriod].add(_tokensValue);
		
		ActualInfo storage info = periods[thisPeriod];
        info.tokensAtThePeriod = info.tokensAtThePeriod.add(_tokensValue);
		
        ReederemEvent(msg.sender, thisPeriod, _amount, info.tokensAtThePeriod);
		
        return true;
    }
	
	event Tax(uint256 _taxPayment);
	function calculateTax(uint256 _amount) internal returns (uint256 _tax) {
		_tax = (_amount.mul(5)).div(100);
		Tax(_tax);
		return _tax;
	}
	
	event ClaimTokensEvent(address indexed _from, uint256 period, uint256 _tokensValue, uint256 _tokensPrice, uint256 _ethersAmount);
    function claimTokens(uint256 _period) onlyReg returns (bool) {
        require(periods.length > _period);
		
        uint256 _ethValue = buyTokens[msg.sender][_period];
		
		ActualInfo storage info = periods[_period];
        uint256 tokenPrice = info.price;
        uint256 amount = (_ethValue.mul(1 ether)).div(tokenPrice);
        gcf.mintToken(this, amount);
		
		buyTokens[msg.sender][_period] = 0;
				
        ClaimTokensEvent(msg.sender, _period, _ethValue, tokenPrice, amount);
		
		return GlobalToken(gcf).transfer(msg.sender, amount);
    }
	
	event ClaimEthersEvent(address indexed _from, uint256 period, uint256 _ethValue, uint256 _tokensPrice, uint256 _tokensAmount);
    function claimEthers(uint256 _period) onlyReg returns (bool) {
        require(periods.length > _period);
		
        uint256 _tokensValue = sellTokens[msg.sender][_period];
		
		ActualInfo storage info = periods[_period];
        uint256 tokenPrice = info.price;
        uint256 amount = (_tokensValue.mul(tokenPrice)).div(1 ether);
        gcf.burn(_tokensValue);
        msg.sender.transfer(amount);
				
        sellTokens[msg.sender][_period] = 0;
		
		ClaimEthersEvent(msg.sender, _period, _tokensValue, tokenPrice, amount);
        
        return true;
    }
	
	event claimTaxex (uint256 _eth, uint256 _tokens);
    function claimTax() onlyOwner {
		if(ethTax != 0) {
			transferEther(owner, ethTax);
			claimTaxex(ethTax, 0);
			ethTax = 0;
		}
		
		if(tokenTax != 0) {
			transferTokens(owner, tokenTax);
			claimTaxex(0, tokenTax);
			tokenTax = 0;
		}
    }
	
    function transferTokens(address _to, uint256 _amount) onlyOwner returns (bool) {
        return GlobalToken(gcf).transfer(_to, _amount);
    }
	
    function transferEther(address _to, uint256 _amount) onlyOwner returns (bool) {
		require(_amount <= (this.balance).sub(ethTax));
        _to.transfer(_amount);
        return true;
    }
    
    function contractVersion() constant returns(uint256) {
        /*  contractVersion identifies as 300YYYYMMDDHHMM */
        return 300201712010000;
    }
    
    function numAccounts() returns (uint256 _numAccounts) {
        return accounts.length;
    }
	
    function kill() onlyOwner {
        uint256 amount = GlobalToken(gcf).balanceOf(this);
        transferTokens(owner, amount);
        selfdestruct(owner);
    }
}

library ConvertStringToUint {
	
	function stringToUint(string _amount) internal constant returns (uint result) {
        bytes memory b = bytes(_amount);
        uint i;
        uint counterBeforeDot;
        uint counterAfterDot;
        result = 0;
        uint totNum = b.length;
        totNum--;
        bool hasDot = false;
        
        for (i = 0; i < b.length; i++) {
            uint c = uint(b[i]);
            
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
                counterBeforeDot ++;
                totNum--;
            }
            
			if(c == 46){
			    hasDot = true;
				break;
			}
        }
        
        if(hasDot) {
            for (uint j = counterBeforeDot + 1; j < 18; j++) {
                uint m = uint(b[j]);
                
                if (m >= 48 && m <= 57) {
                    result = result * 10 + (m - 48);
                    counterAfterDot ++;
                    totNum--;
                }
                
                if(totNum == 0){
                    break;
                }
            }
        }
         if(counterAfterDot < 18){
             uint addNum = 18 - counterAfterDot;
             uint multuply = 10 ** addNum;
             return result = result * multuply;
         }
         
         return result;
	}
}

contract UserWallet is Owned {
	using ConvertStringToUint for string;
	using SafeMath for uint256;
	
    ExchangeManager fund;
    GlobalCryptoFund public gcf;
    
    uint256[] public investedPeriods;
    uint256[] public reederemPeriods;
    
	mapping (uint256 => bool) isInvested;
	mapping (uint256 => bool) isReederem;
	
    function UserWallet(address _fund, address _token) {
        fund = ExchangeManager(_fund);
		require(fund.contractVersion() == 300201712010000);
		
        gcf = GlobalCryptoFund(_token);
        require(gcf.contractVersion() == 200201712010000);
    }
	
    function getPrices() onlyOwner returns (uint256 _Price) {
		return fund.getPrices();
	}
	
	function getActualPeriod() onlyOwner returns (uint256) {
		uint256 period = fund.getActualPeriod();
		return period.sub(1);
	}
	
	event TokensSold(uint256 recivedEthers);
    function() payable {
        if(msg.sender == address(fund)) {
            TokensSold(msg.value);
        } else {
            deposit(msg.value);
        }
    }
	
    function deposit(uint256 _WeiAmount) payable returns (bool) {
        fund.transfer(_WeiAmount);
        fund.buy(_WeiAmount);
		uint256 period = fund.getActualPeriod();
		bool _isInvested = isInvest(period);
		if(!_isInvested) {
			investedPeriods.push(period.sub(1));
			isInvested[period] = true;
		}
        return true;
    }
    
    function Reederem(string _amount) onlyOwner returns (bool) {
		uint256 amount = _amount.stringToUint();
        gcf.transfer(fund, amount);
        uint256 period = fund.getActualPeriod();
		bool _isReederemed = isReederemed(period);
		if(!_isReederemed) {
			reederemPeriods.push(period.sub(1));
			isReederem[period] = true;
		}
        return fund.Reederem(amount);
    }
    
    function transferTokens() onlyOwner returns (bool) {
		uint256 amount = GlobalToken(gcf).balanceOf(this);
        return GlobalToken(gcf).transfer(owner, amount);
    }
    
    event userWalletTransferEther(address indexed _from, address indexed _to, uint256 _ethersValue);
    function transferEther() onlyOwner returns (bool) {
		uint256 amount = this.balance;
        owner.transfer(amount);
        userWalletTransferEther(this,owner,amount);
        return true;
    }
    
    function claimTokens() onlyOwner {
        uint256 period;
        for(uint256 i = 0; i < investedPeriods.length; i++) {
            period = investedPeriods[i];
            fund.claimTokens(period);
        }
        investedPeriods.length = 0;
    }

    function claimEthers() onlyOwner {
        uint256 period;
        for(uint256 i = 0; i < reederemPeriods.length; i++) {
            period = reederemPeriods[i];
            fund.claimEthers(period);
        }
        reederemPeriods.length = 0;
    }
  
    function contractVersion() constant returns(uint256) {
        /*  contractVersion identifies as 400YYYYMMDDHHMM */
        return 400201712010000;
    }
    
    function kill() onlyOwner {
		transferTokens();
		transferEther();
        selfdestruct(owner);
    }
	
	function isInvest(uint256 _per) internal returns (bool) {
		return isInvested[_per];
	}
	
	function isReederemed(uint256 _per) internal returns (bool) {
		return isReederem[_per];
	}
}