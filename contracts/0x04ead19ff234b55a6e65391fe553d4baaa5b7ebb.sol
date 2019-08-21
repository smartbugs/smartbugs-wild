pragma solidity ^0.5.8;

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
  	address public master;
  	address public owner1;
  	address public owner2;
  	
  	address public targetAddress;
  	uint public targetOwner;
    mapping (address => bool) public targetTransferOwnership;

  	event ChangeOwnerSuggest(address indexed _from, address indexed _to, uint indexed _num);

  	modifier onlyOwner
	{
		require(msg.sender == owner1 ||msg.sender == owner2);
		_;
  	}
  	
  	modifier onlyMaster
  	{
  	    require(msg.sender == master);
  	    _;
  	}
  	
  	constructor() public
	{
		master = msg.sender;
  	}
  	
  	function changeOwnership1(address _to) onlyMaster public
  	{
  	    require(_to != address(0x0));

  	    owner1 = _to;
  	}
  	
  	function changeOwnership2(address _to) onlyMaster public
  	{
  	    require(_to != address(0x0));
  	    
  	    owner2 = _to;
  	}
}

contract ERC20Interface
{
    event Transfer( address indexed _from, address indexed _to, uint _value);
    event Approval( address indexed _owner, address indexed _spender, uint _value);
    
    function totalSupply() view public returns (uint _supply);
    function balanceOf( address _who ) public view returns (uint _value);
    function transfer( address _to, uint _value) public returns (bool _success);
    function approve( address _spender, uint _value ) public returns (bool _success);
    function allowance( address _owner, address _spender ) public view returns (uint _allowance);
    function transferFrom( address _from, address _to, uint _value) public returns (bool _success);
}

contract ITAMToken is ERC20Interface, OwnerHelper
{
    using SafeMath for uint;
    
    string public name;
    uint public decimals;
    string public symbol;
    
    uint constant private E18 = 1000000000000000000;
    uint constant private month = 2592000;
    
    // Total                                        2,500,000,000
    uint constant public maxTotalSupply =           2500000000 * E18;
    
    // Advisor & Early Supporters                   125,000,000 (5%)
    // - Vesting 3 month 2 times
    uint constant public maxAdvSptSupply =          125000000 * E18;
    
    // Team & Founder                               250,000,000 (10%)
    // - Vesting 6 month 3 times
    uint constant public maxTeamSupply =            250000000 * E18;
    
    // Marketing                                    375,000,000 (15%)
    // - Vesting 6 month 1 time
    uint constant public maxMktSupply =             375000000 * E18;
    
    // ITAM Ecosystem                               750,000,000 (30%)
    // - Vesting 3 month 1 time
    uint constant public maxEcoSupply =             750000000 * E18;
    
    // Sale Supply                                  1,000,000,000 (40%)
    uint constant public maxSaleSupply =            1000000000 * E18;
    
    // * Sale Details
    // Friends and Family                           130,000,000 (5.2%)
    // - Lock Monthly 20% 20% 20% 20% 20% 
    uint constant public maxFnFSaleSupply =         130000000 * E18;
    
    // Private Sale                                 345,000,000 (13.8%)
    // - Lock Monthly 20% 20% 20% 20% 10% 10%
    uint constant public maxPrivateSaleSupply =     345000000 * E18;
    
    // Public Sale                                  525,000,000 (19%)
    uint constant public maxPublicSaleSupply =      525000000 * E18;
    // *
    
    uint constant public advSptVestingSupplyPerTime = 25000000 * E18;
    uint constant public advSptVestingDate = 2 * month;
    uint constant public advSptVestingTime = 5;
    
    uint constant public teamVestingSupplyPerTime   = 12500000 * E18;
    uint constant public teamVestingDelayDate = 6 * month;
    uint constant public teamVestingDate = 1 * month;
    uint constant public teamVestingTime = 20;
    
    uint constant public mktVestingSupplyFirst      = 125000000 * E18;
    uint constant public mktVestingSupplyPerTime    =  25000000 * E18;
    uint constant public mktVestingDate = 1 * month;
    uint constant public mktVestingTime = 11;
    
    uint constant public ecoVestingSupplyFirst      = 250000000 * E18;
    uint constant public ecoVestingSupplyPerTime    =  50000000 * E18;
    uint constant public ecoVestingDate = 1 * month;
    uint constant public ecoVestingTime = 11;
    
    uint constant public fnfSaleLockDate = 1 * month;
    uint constant public fnfSaleLockTime = 5;
    
    uint constant public privateSaleLockDate = 1 * month;
    uint constant public privateSaleLockTime = 6;
    
    uint public totalTokenSupply;
    
    uint public tokenIssuedAdvSpt;
    uint public tokenIssuedTeam;
    uint public tokenIssuedMkt;
    uint public tokenIssuedEco;
    
    uint public tokenIssuedSale;
    uint public fnfIssuedSale;
    uint public privateIssuedSale;
    uint public publicIssuedSale;
    
    uint public burnTokenSupply;
    
    mapping (address => uint) public balances;
    mapping (address => mapping ( address => uint )) public approvals;
    mapping (address => bool) public blackLists;
    
    mapping (uint => uint) public advSptVestingTimer;
    mapping (uint => uint) public advSptVestingBalances;
    
    mapping (uint => uint) public teamVestingTimer;
    mapping (uint => uint) public teamVestingBalances;
    
    mapping (uint => uint) public mktVestingTimer;
    mapping (uint => uint) public mktVestingBalances;
    
    mapping (uint => uint) public ecoVestingTimer;
    mapping (uint => uint) public ecoVestingBalances;
    
    mapping (uint => uint) public fnfLockTimer;
    mapping (address => mapping ( uint => uint )) public fnfLockWallet;
    
    mapping (uint => uint) public privateLockTimer;
    mapping (address => mapping ( uint => uint )) public privateLockWallet;
    
    bool public tokenLock = true;
    bool public saleTime = true;
    uint public endSaleTime = 0;
    
    event AdvSptIssue(address indexed _to, uint _tokens);
    event TeamIssue(address indexed _to, uint _tokens);
    event MktIssue(address indexed _to, uint _tokens);
    event EcoIssue(address indexed _to, uint _tokens);
    event SaleIssue(address indexed _to, uint _tokens);
    
    event Burn(address indexed _from, uint _value);
    
    event TokenUnlock(address indexed _to, uint _tokens);
    event EndSale(uint _date);
    
    constructor() public
    {
        name        = "ITAM";
        decimals    = 18;
        symbol      = "ITAM";
        
        totalTokenSupply    = 0;
        
        tokenIssuedAdvSpt   = 0;
        tokenIssuedTeam     = 0;
        tokenIssuedMkt      = 0;
        tokenIssuedEco      = 0;
        tokenIssuedSale     = 0;
        
        fnfIssuedSale       = 0;
        privateIssuedSale   = 0;
        publicIssuedSale    = 0;

        burnTokenSupply     = 0;
        
        require(maxAdvSptSupply == advSptVestingSupplyPerTime * advSptVestingTime, "Invalid AdvSpt Supply");
        require(maxTeamSupply == teamVestingSupplyPerTime * teamVestingTime, "Invalid Team Supply");
        require(maxMktSupply == mktVestingSupplyFirst + ( mktVestingSupplyPerTime * ( mktVestingTime - 1 ) ) , "Invalid Mkt Supply");
        require(maxEcoSupply == ecoVestingSupplyFirst + ( ecoVestingSupplyPerTime * ( ecoVestingTime - 1 ) ) , "Invalid Eco Supply");
        
        uint fnfPercent = 0;
        for(uint i = 0; i < fnfSaleLockTime; i++)
        {
            fnfPercent = fnfPercent.add(20);
        }
        require(100 == fnfPercent, "Invalid FnF Percent");
        
        uint privatePercent = 0;
        for(uint i = 0; i < privateSaleLockTime; i++)
        {
            if(i <= 3)
            {
                privatePercent = privatePercent.add(20);
            }
            else
            {
                privatePercent = privatePercent.add(10);
            }
        }
        require(100 == privatePercent, "Invalid Private Percent");
        
        require(maxTotalSupply == maxAdvSptSupply + maxTeamSupply + maxMktSupply + maxEcoSupply + maxSaleSupply, "Invalid Total Supply");
        require(maxSaleSupply == maxFnFSaleSupply + maxPrivateSaleSupply + maxPublicSaleSupply, "Invalid Sale Supply");
    }
    
    // ERC - 20 Interface -----

    function totalSupply() view public returns (uint) 
    {
        return totalTokenSupply;
    }
    
    function balanceOf(address _who) view public returns (uint) 
    {
        return balances[_who];
    }
    
    function balanceOfAll(address _who) view public returns (uint)
    {
        uint balance = balances[_who];
        uint fnfBalances = (fnfLockWallet[_who][0] + fnfLockWallet[_who][1] + fnfLockWallet[_who][2] + fnfLockWallet[_who][3] + fnfLockWallet[_who][4]);
        uint privateBalances = (privateLockWallet[_who][0] + privateLockWallet[_who][1] + privateLockWallet[_who][2] + privateLockWallet[_who][3] + privateLockWallet[_who][4] + privateLockWallet[_who][5]);
        balance = balance.add(fnfBalances);
        balance = balance.add(privateBalances);
        
        return balance;
    }
    
    function transfer(address _to, uint _value) public returns (bool) 
    {
        require(isTransferable(msg.sender) == true);
        require(isTransferable(_to) == true);
        require(balances[msg.sender] >= _value);
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        
        emit Transfer(msg.sender, _to, _value);
        
        return true;
    }
    
    function approve(address _spender, uint _value) public returns (bool)
    {
        require(isTransferable(msg.sender) == true);
        require(balances[msg.sender] >= _value);
        
        approvals[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value);
        
        return true; 
    }
    
    function allowance(address _owner, address _spender) view public returns (uint) 
    {
        return approvals[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) 
    {
        require(isTransferable(_from) == true);
        require(isTransferable(_to) == true);
        require(balances[_from] >= _value);
        require(approvals[_from][msg.sender] >= _value);
        
        approvals[_from][msg.sender] = approvals[_from][msg.sender].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to]  = balances[_to].add(_value);
        
        emit Transfer(_from, _to, _value);
        
        return true;
    }
    
    // -----
    
    // Vesting Function -----
    
    // _time : 0 ~ 4
    function advSptIssue(address _to, uint _time) onlyOwner public
    {
        require(saleTime == false);
        require( _time < advSptVestingTime);
        
        uint nowTime = now;
        require( nowTime > advSptVestingTimer[_time] );
        
        uint tokens = advSptVestingSupplyPerTime;

        require(tokens <= advSptVestingBalances[_time]);
        require(tokens > 0);
        require(maxAdvSptSupply >= tokenIssuedAdvSpt.add(tokens));
        
        balances[_to] = balances[_to].add(tokens);
        advSptVestingBalances[_time] = 0;
        
        totalTokenSupply = totalTokenSupply.add(tokens);
        tokenIssuedAdvSpt = tokenIssuedAdvSpt.add(tokens);
        
        emit AdvSptIssue(_to, tokens);
    }
    
    // _time : 0 ~ 19
    function teamIssue(address _to, uint _time) onlyOwner public
    {
        require(saleTime == false);
        require( _time < teamVestingTime);
        
        uint nowTime = now;
        require( nowTime > teamVestingTimer[_time] );
        
        uint tokens = teamVestingSupplyPerTime;

        require(tokens <= teamVestingBalances[_time]);
        require(tokens > 0);
        require(maxTeamSupply >= tokenIssuedTeam.add(tokens));
        
        balances[_to] = balances[_to].add(tokens);
        teamVestingBalances[_time] = 0;
        
        totalTokenSupply = totalTokenSupply.add(tokens);
        tokenIssuedTeam = tokenIssuedTeam.add(tokens);
        
        emit TeamIssue(_to, tokens);
    }
    
    // _time : 0 ~ 10
    function mktIssue(address _to, uint _time, uint _value) onlyOwner public
    {
        require(saleTime == false);
        require( _time < mktVestingTime);
        
        uint nowTime = now;
        require( nowTime > mktVestingTimer[_time] );
        
        uint tokens = _value * E18;

        require(tokens <= mktVestingBalances[_time]);
        require(tokens > 0);
        require(maxMktSupply >= tokenIssuedMkt.add(tokens));
        
        balances[_to] = balances[_to].add(tokens);
        mktVestingBalances[_time] = mktVestingBalances[_time].sub(tokens);
        
        totalTokenSupply = totalTokenSupply.add(tokens);
        tokenIssuedMkt = tokenIssuedMkt.add(tokens);
        
        emit MktIssue(_to, tokens);
    }
    
    // _time : 0 ~ 10
    function ecoIssue(address _to, uint _time, uint _value) onlyOwner public
    {
        require(saleTime == false);
        require( _time < ecoVestingTime);
        
        uint nowTime = now;
        require( nowTime > ecoVestingTimer[_time] );
        
        uint tokens = _value * E18;

        require(tokens <= ecoVestingBalances[_time]);
        require(tokens > 0);
        require(maxEcoSupply >= tokenIssuedEco.add(tokens));
        
        balances[_to] = balances[_to].add(tokens);
        ecoVestingBalances[_time] = ecoVestingBalances[_time].sub(tokens);
        
        totalTokenSupply = totalTokenSupply.add(tokens);
        tokenIssuedEco = tokenIssuedEco.add(tokens);
        
        emit EcoIssue(_to, tokens);
    }
    
    // Sale Function -----
    
    function fnfSaleIssue(address _to, uint _value) onlyOwner public
    {
        uint tokens = _value * E18;
        require(maxSaleSupply >= tokenIssuedSale.add(tokens));
        require(maxFnFSaleSupply >= fnfIssuedSale.add(tokens));
        require(tokens > 0);
        
        for(uint i = 0; i < fnfSaleLockTime; i++)
        {
            uint lockTokens = tokens.mul(20) / 100;
            fnfLockWallet[_to][i] = lockTokens;
        }
        
        balances[_to] = balances[_to].add(fnfLockWallet[_to][0]);
        fnfLockWallet[_to][0] = 0;
        
        totalTokenSupply = totalTokenSupply.add(tokens);
        tokenIssuedSale = tokenIssuedSale.add(tokens);
        fnfIssuedSale = fnfIssuedSale.add(tokens);
        
        emit SaleIssue(_to, tokens);
    }
    
    // _time : 1 ~ 4
    function fnfSaleUnlock(address _to, uint _time) onlyOwner public
    {
        require(saleTime == false);
        require( _time < fnfSaleLockTime);
        
        uint nowTime = now;
        require( nowTime > fnfLockTimer[_time] );
        
        uint tokens = fnfLockWallet[_to][_time];
        require(tokens > 0);
        
        balances[_to] = balances[_to].add(tokens);
        fnfLockWallet[_to][_time] = 0;
        
        emit TokenUnlock(_to, tokens);
    }
    
    function privateSaleIssue(address _to, uint _value) onlyOwner public
    {
        uint tokens = _value * E18;
        require(maxSaleSupply >= tokenIssuedSale.add(tokens));
        require(maxPrivateSaleSupply >= privateIssuedSale.add(tokens));
        require(tokens > 0);
        
        for(uint i = 0; i < privateSaleLockTime; i++)
        {
            uint lockPer = 20;
            if(i >= 4)
            {
                lockPer = 10;
            }
            uint lockTokens = tokens.mul(lockPer) / 100;
            privateLockWallet[_to][i] = lockTokens;
        }
        
        balances[_to] = balances[_to].add(privateLockWallet[_to][0]);
        privateLockWallet[_to][0] = 0;
        
        totalTokenSupply = totalTokenSupply.add(tokens);
        tokenIssuedSale = tokenIssuedSale.add(tokens);
        privateIssuedSale = privateIssuedSale.add(tokens);
        
        emit SaleIssue(_to, tokens);
    }
    
    // _time : 1 ~ 5
    function privateSaleUnlock(address _to, uint _time) onlyOwner public
    {
        require(saleTime == false);
        require( _time < privateSaleLockTime);
        
        uint nowTime = now;
        require( nowTime > privateLockTimer[_time] );
        
        uint tokens = privateLockWallet[_to][_time];
        require(tokens > 0);
        
        balances[_to] = balances[_to].add(tokens);
        privateLockWallet[_to][_time] = 0;
        
        emit TokenUnlock(_to, tokens);
    }
    
    function publicSaleIssue(address _to, uint _value) onlyOwner public
    {
        uint tokens = _value * E18;
        require(maxSaleSupply >= tokenIssuedSale.add(tokens));
        
        balances[_to] = balances[_to].add(tokens);
        
        totalTokenSupply = totalTokenSupply.add(tokens);
        tokenIssuedSale = tokenIssuedSale.add(tokens);
        publicIssuedSale = publicIssuedSale.add(tokens);
        
        emit SaleIssue(_to, tokens);
    }
    
    // -----
    
    // Lock Function -----
    
    function isTransferable(address _who) private view returns (bool)
    {
        if(blackLists[_who] == true)
        {
            return false;
        }
        if(tokenLock == false)
        {
            return true;
        }
        else if(msg.sender == owner1 || msg.sender == owner2)
        {
            return true;
        }
        
        return false;
    }
    
    function setTokenUnlock() onlyOwner public
    {
        require(tokenLock == true);
        require(saleTime == false);
        
        tokenLock = false;
    }
    
    function setTokenLock() onlyOwner public
    {
        require(tokenLock == false);
        
        tokenLock = true;
    }
    
    // -----
    
    // ETC / Burn Function -----
    
    function () payable external
    {
        revert();
    }
    
    function endSale() onlyOwner public
    {
        require(saleTime == true);
        require(maxSaleSupply == tokenIssuedSale);
        
        saleTime = false;
        
        uint nowTime = now;
        
        endSaleTime = nowTime;
        
        for(uint i = 0; i < advSptVestingTime; i++)
        {
            uint lockTime = endSaleTime + (advSptVestingDate * i);
            advSptVestingTimer[i] = lockTime;
            advSptVestingBalances[i] = advSptVestingBalances[i].add(advSptVestingSupplyPerTime);
        }
        
        for(uint i = 0; i < teamVestingTime; i++)
        {
            uint lockTime = endSaleTime + teamVestingDelayDate + (teamVestingDate * i);
            teamVestingTimer[i] = lockTime;
            teamVestingBalances[i] = teamVestingBalances[i].add(teamVestingSupplyPerTime);
        }
        
        for(uint i = 0; i < mktVestingTime; i++)
        {
            uint lockTime = endSaleTime + (mktVestingDate * i);
            mktVestingTimer[i] = lockTime;
            if(i == 0)
            {
                mktVestingBalances[i] = mktVestingBalances[i].add(mktVestingSupplyFirst);
            }
            else
            {
                mktVestingBalances[i] = mktVestingBalances[i].add(mktVestingSupplyPerTime);
            }
        }
        
        for(uint i = 0; i < ecoVestingTime; i++)
        {
            uint lockTime = endSaleTime + (ecoVestingDate * i);
            ecoVestingTimer[i] = lockTime;
            if(i == 0)
            {
                ecoVestingBalances[i] = ecoVestingBalances[i].add(ecoVestingSupplyFirst);
            }
            else
            {
                ecoVestingBalances[i] = ecoVestingBalances[i].add(ecoVestingSupplyPerTime);
            }
        }
        
        for(uint i = 0; i < fnfSaleLockTime; i++)
        {
            uint lockTime = endSaleTime + (fnfSaleLockDate * i);
            fnfLockTimer[i] = lockTime;
        }
        
        for(uint i = 0; i < privateSaleLockTime; i++)
        {
            uint lockTime = endSaleTime + (privateSaleLockDate * i);
            privateLockTimer[i] = lockTime;
        }
        
        emit EndSale(endSaleTime);
    }
    
    function withdrawTokens(address _contract, uint _decimals, uint _value) onlyOwner public
    {

        if(_contract == address(0x0))
        {
            uint eth = _value.mul(10 ** _decimals);
            msg.sender.transfer(eth);
        }
        else
        {
            uint tokens = _value.mul(10 ** _decimals);
            ERC20Interface(_contract).transfer(msg.sender, tokens);
            
            emit Transfer(address(0x0), msg.sender, tokens);
        }
    }
    
    function burnToken(uint _value) onlyOwner public
    {
        uint tokens = _value * E18;
        
        require(balances[msg.sender] >= tokens);
        
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        
        burnTokenSupply = burnTokenSupply.add(tokens);
        totalTokenSupply = totalTokenSupply.sub(tokens);
        
        emit Burn(msg.sender, tokens);
    }
    
    function close() onlyOwner public
    {
        selfdestruct(msg.sender);
    }
    
    // -----
    
    // BlackList function
    
    function addBlackList(address _to) onlyOwner public
    {
        require(blackLists[_to] == false);
        
        blackLists[_to] = true;
    }
    
    function delBlackList(address _to) onlyOwner public
    {
        require(blackLists[_to] == true);
        
        blackLists[_to] = false;
    }
    
    // -----
}