pragma solidity ^0.5.0;


library SafeMath{
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

contract Ownable
{
  	address public Owner_master;
  	address public Owner_creator;
  	address public Owner_manager;

  	event ChangeOwner_master(address indexed _from, address indexed _to);
  	event ChangeOwner_creator(address indexed _from, address indexed _to);
  	event ChangeOwner_manager(address indexed _from, address indexed _to);

  	modifier onlyOwner_master{ 
          require(msg.sender == Owner_master);	_; 	}
  	modifier onlyOwner_creator{ 
          require(msg.sender == Owner_creator); _; }
  	modifier onlyOwner_manager{ 
          require(msg.sender == Owner_manager); _; }
  	constructor() public { 
          Owner_master = msg.sender; }
  	
    
    
    
    
    
    function transferOwnership_master(address _to) onlyOwner_master public{
        	require(_to != Owner_master);
        	require(_to != Owner_creator);
        	require(_to != Owner_manager);
        	require(_to != address(0x0));

		address from = Owner_master;
  	    	Owner_master = _to;
  	    
  	    	emit ChangeOwner_master(from, _to);}

  	function transferOwner_creator(address _to) onlyOwner_master public{
	        require(_to != Owner_master);
        	require(_to != Owner_creator);
        	require(_to != Owner_manager);
	        require(_to != address(0x0));

		address from = Owner_creator;        
	    	Owner_creator = _to;
        
    		emit ChangeOwner_creator(from, _to);}

  	function transferOwner_manager(address _to) onlyOwner_master public{
	        require(_to != Owner_master);
	        require(_to != Owner_creator);
        	require(_to != Owner_manager);
	        require(_to != address(0x0));
        	
		address from = Owner_manager;
    		Owner_manager = _to;
        
	    	emit ChangeOwner_manager(from, _to);}
}

contract Helper
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

contract LINIX is Helper, Ownable
{
    using SafeMath for uint;
    
    string public name;
    string public symbol;
    uint public decimals;
    
    uint constant private zeroAfterDecimal = 10**18;
    uint constant private monInSec = 2592000;
    
    uint constant public maxSupply             = 2473750000 * zeroAfterDecimal;
    
    uint constant public maxSupply_Public      =   100000000 * zeroAfterDecimal;
    uint constant public maxSupply_Private     =   889500000 * zeroAfterDecimal;
    uint constant public maxSupply_Advisor     =   123687500 * zeroAfterDecimal;
    uint constant public maxSupply_Reserve     =   296850000 * zeroAfterDecimal;
    uint constant public maxSupply_Marketing   =   197900000 * zeroAfterDecimal;
    uint constant public maxSupply_Ecosystem   =   371062500 * zeroAfterDecimal;
    uint constant public maxSupply_RND         =   247375000 * zeroAfterDecimal;
    uint constant public maxSupply_Team        =   247375000 * zeroAfterDecimal;
  
    uint constant public vestingAmountPerRound_RND          = 9895000 * zeroAfterDecimal;
    uint constant public vestingReleaseTime_RND             = 1 * monInSec;
    uint constant public vestingReleaseRound_RND            = 25;

    uint constant public vestingAmountPerRound_Advisor      = 30921875 * zeroAfterDecimal;
    uint constant public vestingReleaseTime_Advisor         = 3 * monInSec;
    uint constant public vestingReleaseRound_Advisor        = 4;

    uint constant public vestingAmountPerRound_Team        = 247375000 * zeroAfterDecimal;
    uint constant public vestingReleaseTime_Team           = 24 * monInSec;
    uint constant public vestingReleaseRound_Team          = 1;
    
    uint public issueToken_Total;
    
    uint public issueToken_Private;
    uint public issueToken_Public;
    uint public issueToken_Ecosystem;
    uint public issueToken_Marketing;
    uint public issueToken_RND;
    uint public issueToken_Team;
    uint public issueToken_Reserve;
    uint public issueToken_Advisor;
    
    uint public burnTokenAmount;
    
    mapping (address => uint) public balances;
    mapping (address => mapping ( address => uint )) public approvals;

    mapping (uint => uint) public vestingRelease_RND;
    mapping (uint => uint) public vestingRelease_Advisor;
    mapping (uint => uint) public vestingRelease_Team;
    
    bool public tokenLock = true;
    bool public saleTime = true;
    uint public endSaleTime = 0;
    
    event Burn(address indexed _from, uint _value);
    
    event Issue_private(address indexed _to, uint _tokens);
    event Issue_public(address indexed _to, uint _tokens);
    event Issue_ecosystem(address indexed _to, uint _tokens);
    event Issue_marketing(address indexed _to, uint _tokens);
    event Issue_RND(address indexed _to, uint _tokens);
    event Issue_team(address indexed _to, uint _tokens);
    event Issue_reserve(address indexed _to, uint _tokens);
    event Issue_advisor(address indexed _to, uint _tokens);
    
    event TokenUnLock(address indexed _to, uint _tokens);

    
    constructor() public
    {
        name        = "LINIX";
        decimals    = 18;
        symbol      = "LNX";
        
        issueToken_Total      = 0;
        
        issueToken_Public     = 0;
        issueToken_Private    = 0;
        issueToken_Ecosystem  = 0;
        issueToken_Marketing  = 0;
        issueToken_RND        = 0;
        issueToken_Team       = 0;
        issueToken_Reserve    = 0;
        issueToken_Advisor    = 0;
        
        require(maxSupply == maxSupply_Public + maxSupply_Private + maxSupply_Ecosystem + maxSupply_Marketing + maxSupply_RND + maxSupply_Team + maxSupply_Reserve + maxSupply_Advisor);
        require(maxSupply_RND == vestingAmountPerRound_RND * vestingReleaseRound_RND);
        require(maxSupply_Team == vestingAmountPerRound_Team * vestingReleaseRound_Team);
        require(maxSupply_Advisor == vestingAmountPerRound_Advisor * vestingReleaseRound_Advisor);
    }
    
    // ERC - 20 Interface -----

    function totalSupply() view public returns (uint) {
        return issueToken_Total;}
    
    function balanceOf(address _who) view public returns (uint) {
        uint balance = balances[_who];
        
        return balance;}
    
    function transfer(address _to, uint _value) public returns (bool) {
        require(isTransferable() == true);
        require(balances[msg.sender] >= _value);
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        
        emit Transfer(msg.sender, _to, _value);
        
        return true;}
    
    function approve(address _spender, uint _value) public returns (bool){
        require(isTransferable() == true);
        require(balances[msg.sender] >= _value);
        
        approvals[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value);
        
        return true; }
    
    function allowance(address _owner, address _spender) view public returns (uint) {
        return approvals[_owner][_spender];}

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        require(isTransferable() == true);
        require(balances[_from] >= _value);
        require(approvals[_from][msg.sender] >= _value);
        
        approvals[_from][msg.sender] = approvals[_from][msg.sender].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to]  = balances[_to].add(_value);
        
        emit Transfer(_from, _to, _value);
        
        return true;}
    
    // -----
    
    // Issue Function -----
    function issue_noVesting_Private(address _to, uint _value) onlyOwner_creator public
    {
        uint tokens = _value * zeroAfterDecimal;
        require(maxSupply_Private >= issueToken_Private.add(tokens));
        
        balances[_to] = balances[_to].add(tokens);
        
        issueToken_Total = issueToken_Total.add(tokens);
        issueToken_Private = issueToken_Private.add(tokens);
        
        emit Issue_private(_to, tokens);
    }

    function issue_noVesting_Public(address _to, uint _value) onlyOwner_creator public
    {
        uint tokens = _value * zeroAfterDecimal;
        require(maxSupply_Public >= issueToken_Public.add(tokens));
        
        balances[_to] = balances[_to].add(tokens);
        
        issueToken_Total = issueToken_Total.add(tokens);
        issueToken_Public = issueToken_Public.add(tokens);
        
        emit Issue_public(_to, tokens);
    }    
    
    function issue_noVesting_Marketing(address _to, uint _value) onlyOwner_creator public
    {
        uint tokens = _value * zeroAfterDecimal;
        require(maxSupply_Marketing >= issueToken_Marketing.add(tokens));
        
        balances[_to] = balances[_to].add(tokens);
        
        issueToken_Total = issueToken_Total.add(tokens);
        issueToken_Marketing = issueToken_Marketing.add(tokens);
        
        emit Issue_marketing(_to, tokens);
    }

    function issue_noVesting_Ecosystem(address _to, uint _value) onlyOwner_creator public
    {
        uint tokens = _value * zeroAfterDecimal;
        require(maxSupply_Ecosystem >= issueToken_Ecosystem.add(tokens));
        
        balances[_to] = balances[_to].add(tokens);
        
        issueToken_Total = issueToken_Total.add(tokens);
        issueToken_Ecosystem = issueToken_Ecosystem.add(tokens);
        
        emit Issue_ecosystem(_to, tokens);
    }
    
    function issue_noVesting_Reserve(address _to, uint _value) onlyOwner_creator public
    {
        uint tokens = _value * zeroAfterDecimal;
        require(maxSupply_Reserve >= issueToken_Reserve.add(tokens));
        
        balances[_to] = balances[_to].add(tokens);
        
        issueToken_Total = issueToken_Total.add(tokens);
        issueToken_Reserve = issueToken_Reserve.add(tokens);
        
        emit Issue_reserve(_to, tokens);
    }
    // Vesting Issue Function -----
    
    function issue_Vesting_RND(address _to, uint _time) onlyOwner_creator public
    {
        require(saleTime == false);
        require(vestingReleaseRound_RND >= _time);
        
        uint time = now;
        require( ( ( endSaleTime + (_time * vestingReleaseTime_RND) ) < time ) && ( vestingRelease_RND[_time] > 0 ) );
        
        uint tokens = vestingRelease_RND[_time];

        require(maxSupply_RND >= issueToken_RND.add(tokens));
        
        balances[_to] = balances[_to].add(tokens);
        vestingRelease_RND[_time] = 0;
        
        issueToken_Total = issueToken_Total.add(tokens);
        issueToken_RND = issueToken_RND.add(tokens);
        
        emit Issue_RND(_to, tokens);
    }
    
    function issue_Vesting_Advisor(address _to, uint _time) onlyOwner_creator public
    {
        require(saleTime == false);
        require(vestingReleaseRound_Advisor >= _time);
        
        uint time = now;
        require( ( ( endSaleTime + (_time * vestingReleaseTime_Advisor) ) < time ) && ( vestingRelease_Advisor[_time] > 0 ) );
        
        uint tokens = vestingRelease_Advisor[_time];
        
        require(maxSupply_Advisor >= issueToken_Advisor.add(tokens));
        
        balances[_to] = balances[_to].add(tokens);
        vestingRelease_Advisor[_time] = 0;
        
        issueToken_Total = issueToken_Total.add(tokens);
        issueToken_Advisor = issueToken_Advisor.add(tokens);
        
        emit Issue_advisor(_to, tokens);
    }

    function issue_Vesting_Team(address _to, uint _time) onlyOwner_creator public
    {
        require(saleTime == false);
        require(vestingReleaseRound_Team >= _time);
        
        uint time = now;
        require( ( ( endSaleTime + (_time * vestingReleaseTime_Team) ) < time ) && ( vestingRelease_Team[_time] > 0 ) );
        
        uint tokens = vestingRelease_Team[_time];
        
        require(maxSupply_Team >= issueToken_Team.add(tokens));
        
        balances[_to] = balances[_to].add(tokens);
        vestingRelease_Team[_time] = 0;
        
        issueToken_Total = issueToken_Total.add(tokens);
        issueToken_Team = issueToken_Team.add(tokens);
        
        emit Issue_team(_to, tokens);
    }


    
    // -----
    
    // Lock Function -----
    
    function isTransferable() private view returns (bool)
    {
        if(tokenLock == false)
        {
            return true;
        }
        else if(msg.sender == Owner_manager)
        {
            return true;
        }
        
        return false;
    }
    
    function setTokenUnlock() onlyOwner_manager public
    {
        require(tokenLock == true);
        require(saleTime == false);
        
        tokenLock = false;
    }
    
    function setTokenLock() onlyOwner_manager public
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
    
    function endSale() onlyOwner_manager public
    {
        require(saleTime == true);
        
        saleTime = false;
        
        uint time = now;
        
        endSaleTime = time;
        
        for(uint i = 1; i <= vestingReleaseRound_RND; i++)
        {
            vestingRelease_RND[i] = vestingRelease_RND[i].add(vestingAmountPerRound_RND);
        }
        
        for(uint i = 1; i <= vestingReleaseRound_Advisor; i++)
        {
            vestingRelease_Advisor[i] = vestingRelease_Advisor[i].add(vestingAmountPerRound_Advisor);
        }

            for(uint i = 1; i <= vestingReleaseRound_Team; i++)
        {
            vestingRelease_Team[i] = vestingRelease_Team[i].add(vestingAmountPerRound_Team);
        }
    }
    
    function withdrawTokens(address _contract, uint _decimals, uint _value) onlyOwner_manager public
    {

        if(_contract == address(0x0))
        {
            uint eth = _value.mul(10 ** _decimals);
            msg.sender.transfer(eth);
        }
        else
        {
            uint tokens = _value.mul(10 ** _decimals);
            Helper(_contract).transfer(msg.sender, tokens);
            
            emit Transfer(address(0x0), msg.sender, tokens);
        }
    }
    
    function burnToken(uint _value) onlyOwner_manager public
    {
        uint tokens = _value * zeroAfterDecimal;
        
        require(balances[msg.sender] >= tokens);
        
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        
        burnTokenAmount = burnTokenAmount.add(tokens);
        issueToken_Total = issueToken_Total.sub(tokens);
        
        emit Burn(msg.sender, tokens);
    }
    
    function close() onlyOwner_master public
    {
        selfdestruct(msg.sender);
    }
    
    // -----
}