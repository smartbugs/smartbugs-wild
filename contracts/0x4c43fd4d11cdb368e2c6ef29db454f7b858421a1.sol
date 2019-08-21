pragma solidity 0.4.18;

contract Ownable {
	address public owner;
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	function Ownable() {
		owner = msg.sender;
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	function transferOwnership(address newOwner) onlyOwner public {
		require(newOwner != address(0));
		OwnershipTransferred(owner, newOwner);
		owner = newOwner;
	}
}

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

contract ERC20 {
	uint256 public totalSupply;
	function balanceOf(address who) public constant returns (uint256);
	function transfer(address to, uint256 value) public returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);

	function allowance(address owner, address spender) public constant returns (uint256);
	function transferFrom(address from, address to, uint256 value) public returns (bool);
	function approve(address spender, uint256 value) public returns (bool);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20 {
	using SafeMath for uint256;

	mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

	function transfer(address _to, uint256 _value) public returns (bool) {
		require(_to != address(0));

		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		Transfer(msg.sender, _to, _value);
		return true;
	}

	function balanceOf(address _owner) public constant returns (uint256 balance) {
		return balances[_owner];
	}

	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
		require(_to != address(0));

		uint256 _allowance = allowed[_from][msg.sender];

		balances[_from] = balances[_from].sub(_value);
		balances[_to] = balances[_to].add(_value);
		allowed[_from][msg.sender] = _allowance.sub(_value);
		Transfer(_from, _to, _value);
		return true;
	}

	function approve(address _spender, uint256 _value) public returns (bool) {
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
		return true;
	}

	function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
		return allowed[_owner][_spender];
	}
}

contract T8EXToken is StandardToken {
	string public constant name = "T8EX Token";
    string public constant symbol = "T8EX";
    uint8  public constant decimals = 18;

	address public minter; 
	uint    public tokenSaleEndTime; 

	// token lockup for cornerstone investors
	mapping(address=>uint) public lockedBalanceCor; 
	mapping(uint=>address) lockedBalanceCor_index;
	uint lockedBalanceCor_count;

	// token lockup for private investors
	mapping(address=>uint) public lockedBalancePri; 
	mapping(uint=>address) lockedBalancePri_index;
	uint lockedBalancePri_count;

	modifier onlyMinter {
		require (msg.sender == minter);
		_;
	}

	modifier whenMintable {
		require (now <= tokenSaleEndTime);
		_;
	}

    modifier validDestination(address to) {
        require(to != address(this));
        _;
    }

	function T8EXToken(address _minter, uint _tokenSaleEndTime) public {
		minter = _minter;
		tokenSaleEndTime = _tokenSaleEndTime;
    }

	function transfer(address _to, uint _value)
        public
        validDestination(_to)
        returns (bool) 
    {
        return super.transfer(_to, _value);
    }

	function transferFrom(address _from, address _to, uint _value)
        public
        validDestination(_to)
        returns (bool) 
    {
        return super.transferFrom(_from, _to, _value);
    }

	function createToken(address _recipient, uint _value)
		whenMintable
		onlyMinter
		returns (bool)
	{
		balances[_recipient] += _value;
		totalSupply += _value;
		return true;
	}

	// Create an lockedBalance which cannot be traded until admin make it liquid.
	// Can only be called by crowdfund contract before the end time.
	function createLockedTokenCor(address _recipient, uint _value)
		whenMintable
		onlyMinter
		returns (bool) 
	{
		lockedBalanceCor_index[lockedBalanceCor_count] = _recipient;
		lockedBalanceCor[_recipient] += _value;
		lockedBalanceCor_count++;

		totalSupply += _value;
		return true;
	}

	// Make sender's locked balance liquid when called after lockout period.
	function makeLiquidCor()
		onlyMinter
	{
		for (uint i=0; i<lockedBalanceCor_count; i++) {
			address investor = lockedBalanceCor_index[i];
			balances[investor] += lockedBalanceCor[investor];
			lockedBalanceCor[investor] = 0;
		}
	}

	// Create an lockedBalance which cannot be traded until admin make it liquid.
	// Can only be called by crowdfund contract before the end time.
	function createLockedTokenPri(address _recipient, uint _value)
		whenMintable
		onlyMinter
		returns (bool) 
	{
		lockedBalancePri_index[lockedBalancePri_count] = _recipient;
		lockedBalancePri[_recipient] += _value;
		lockedBalancePri_count++;

		totalSupply += _value;
		return true;
	}

	// Make sender's locked balance liquid when called after lockout period.
	function makeLiquidPri()
		onlyMinter
	{
		for (uint i=0; i<lockedBalancePri_count; i++) {
			address investor = lockedBalancePri_index[i];
			balances[investor] += lockedBalancePri[investor];
			lockedBalancePri[investor] = 0;
		}
	}
}

contract T8EXTokenSale is Ownable {
    using SafeMath for uint256;

	// token allocation
	uint public constant TOTAL_T8EXTOKEN_SUPPLY  = 540000000;
	uint public constant ALLOC_TEAM             = 135000000e18;
	uint public constant ALLOC_RESERVED         =  54000000e18;
	uint public constant ALLOC_COMMUNITY        = 118800000e18;
	uint public constant ALLOC_ADVISOR          =  16200000e18;
	uint public constant ALLOC_SALE_CORNERSTONE =  32500000e18; 
	uint public constant ALLOC_SALE_PRIVATE     = 120000000e18; 
	uint public constant ALLOC_SALE_GENERAL     =  63500000e18; 

	// crowdsale stage
	uint public constant STAGE1_TIME_END = 4 days;
	uint public constant STAGE2_TIME_END = 8 days;
	uint public constant STAGE3_TIME_END = 13 days;

	// Token sale rate from ETH to T8EX
	uint public constant RATE_CORNERSTONE  = 6500;
	uint public constant RATE_PRIVATE      = 6000;
	uint public constant RATE_CROWDSALE_S1 = 4500;
	uint public constant RATE_CROWDSALE_S2 = 4200;
	uint public constant RATE_CROWDSALE_S3 = 4000;

	// For token transfer
	address public constant WALLET_T8EX_RESERVED  = 0x63cB2fB590d5eD47fBEFbBbF0CDda1c56D506f0A;
	address public constant WALLET_T8EX_COMMUNITY = 0x1a0E0147acF86e7bFa773e90D9465D51C1c0a594;
	address public constant WALLET_T8EX_TEAM      = 0x5e7658d850B1A050937ee088EB503243A345ffe6;
	address public constant WALLET_T8EX_ADMIN     = 0x4Db76c3F8d0169ABa7aD5795dA1253231a09a22C;

	// For ether transfer
	address private constant WALLET_ETH_T8EX  = 0xEE1B6C44DBb3b0d5e46C34542dC7718325ac4095;
	address private constant WALLET_ETH_ADMIN = 0x782872fb9459FC0dbdf8c0EDb5fE3D5f214a6660;

    T8EXToken public t8exToken; 

	uint256 public presaleStartTime;
    uint256 public publicStartTime;
    uint256 public publicEndTime;
	bool public halted;

	// stat
	uint256 public totalT8EXSold_CORNERSTONE;
	uint256 public totalT8EXSold_PRIVATE;
	uint256 public totalT8EXSold_GENERAL;
    uint256 public weiRaised;
	mapping(address=>uint256) public weiContributions;

	// whitelisting
	mapping(address=>bool) public whitelisted_Private;
	mapping(address=>bool) public whitelisted_Cornerstone;
	event WhitelistedPrivateStatusChanged(address target, bool isWhitelisted);
	event WhitelistedCornerstoneStatusChanged(address target, bool isWhitelisted);

    event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);

    function T8EXTokenSale(uint256 _presaleStartTime, uint256 _publicStartTime, uint256 _publicEndTime) {
        presaleStartTime = _presaleStartTime;
        publicStartTime = _publicStartTime;
		publicEndTime = _publicEndTime;

        t8exToken = new T8EXToken(address(this), publicEndTime);
		t8exToken.createToken(WALLET_T8EX_RESERVED, ALLOC_RESERVED);
		t8exToken.createToken(WALLET_T8EX_COMMUNITY, ALLOC_COMMUNITY);
		t8exToken.createToken(WALLET_T8EX_TEAM, ALLOC_TEAM);
		t8exToken.createToken(WALLET_T8EX_ADMIN, ALLOC_ADVISOR);
    }


    function changeWhitelistPrivateStatus(address _target, bool _isWhitelisted)
        public
        onlyOwner
    {
        whitelisted_Private[_target] = _isWhitelisted;
        WhitelistedPrivateStatusChanged(_target, _isWhitelisted);
    }

    function changeWhitelistPrivateStatuses(address[] _targets, bool _isWhitelisted)
        public
        onlyOwner
    {
        for (uint i = 0; i < _targets.length; i++) {
            changeWhitelistPrivateStatus(_targets[i], _isWhitelisted);
        }
    }

	function changeWhitelistCornerstoneStatus(address _target, bool _isWhitelisted)
        public
        onlyOwner
    {
        whitelisted_Cornerstone[_target] = _isWhitelisted;
        WhitelistedCornerstoneStatusChanged(_target, _isWhitelisted);
    }

    function changeWhitelistCornerstoneStatuses(address[] _targets, bool _isWhitelisted)
        public
        onlyOwner
    {
        for (uint i = 0; i < _targets.length; i++) {
            changeWhitelistCornerstoneStatus(_targets[i], _isWhitelisted);
        }
    }

    function validPurchase() 
        internal 
        returns(bool) 
    {
		bool nonZeroPurchase = msg.value != 0;
		bool withinSalePeriod = now >= presaleStartTime && now <= publicEndTime;
        bool withinPublicPeriod = now >= publicStartTime && now <= publicEndTime;

		bool whitelisted = whitelisted_Cornerstone[msg.sender] || whitelisted_Private[msg.sender];
		bool whitelistedCanBuy = whitelisted && withinSalePeriod;
        
        return nonZeroPurchase && (whitelistedCanBuy || withinPublicPeriod);
    }

	function getPriceRate()
		constant
		returns (uint)
	{
		if (now <= publicStartTime + STAGE1_TIME_END) {return RATE_CROWDSALE_S1;}
		if (now <= publicStartTime + STAGE2_TIME_END) {return RATE_CROWDSALE_S2;}
		if (now <= publicStartTime + STAGE3_TIME_END) {return RATE_CROWDSALE_S3;}
		return 0;
	}

    function () 
       payable 
    {
        buyTokens();
    }

    function buyTokens() 
       payable 
    {
		require(!halted);
        require(validPurchase());

        uint256 weiAmount = msg.value;
		uint256 purchaseTokens; 
		
		if (whitelisted_Cornerstone[msg.sender]) {
			purchaseTokens = weiAmount.mul(RATE_CORNERSTONE); 
			require(ALLOC_SALE_CORNERSTONE - totalT8EXSold_CORNERSTONE >= purchaseTokens); // buy only if enough supply
			require(t8exToken.createLockedTokenCor(msg.sender, purchaseTokens));
			totalT8EXSold_CORNERSTONE = totalT8EXSold_CORNERSTONE.add(purchaseTokens); 
		} else if (whitelisted_Private[msg.sender]) {
			purchaseTokens = weiAmount.mul(RATE_PRIVATE); 
			require(ALLOC_SALE_PRIVATE - totalT8EXSold_PRIVATE >= purchaseTokens); // buy only if enough supply
			require(t8exToken.createLockedTokenPri(msg.sender, purchaseTokens));
			totalT8EXSold_PRIVATE = totalT8EXSold_PRIVATE.add(purchaseTokens); 
		} else {
        	purchaseTokens = weiAmount.mul(getPriceRate()); 
			require(ALLOC_SALE_GENERAL - totalT8EXSold_GENERAL >= purchaseTokens); // buy only if enough supply
			require(t8exToken.createToken(msg.sender, purchaseTokens));
			totalT8EXSold_GENERAL = totalT8EXSold_GENERAL.add(purchaseTokens); 
		}

		weiRaised = weiRaised.add(weiAmount);
		weiContributions[msg.sender] = weiContributions[msg.sender].add(weiAmount);

		TokenPurchase(msg.sender, weiAmount, purchaseTokens);
		forwardFunds();
    }

    function forwardFunds() 
       internal 
    {
        WALLET_ETH_T8EX.transfer((msg.value).mul(98).div(100));
		WALLET_ETH_ADMIN.transfer((msg.value).mul(2).div(100));
    }

    function hasEnded() 
        public 
        constant 
        returns(bool) 
    {
        return now > publicEndTime;
    }

	function releaseTokenCornerstone()
		public
		onlyOwner
	{
		require(hasEnded());
		t8exToken.makeLiquidCor();
	}

	function releaseTokenPrivate()
		public
		onlyOwner
	{
		require(hasEnded());
		t8exToken.makeLiquidPri();
	}

	function toggleHalt(bool _halted)
		public
		onlyOwner
	{
		halted = _halted;
	}
}