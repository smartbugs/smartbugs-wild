contract EtherealFoundationOwned {
	address private Owner;
    
	function IsOwner(address addr) view public returns(bool)
	{
	    return Owner == addr;
	}
	
	function TransferOwner(address newOwner) public onlyOwner
	{
	    Owner = newOwner;
	}
	
	function EtherealFoundationOwned() public
	{
	    Owner = msg.sender;
	}
	
	function Terminate() public onlyOwner
	{
	    selfdestruct(Owner);
	}
	
	modifier onlyOwner(){
        require(msg.sender == Owner);
        _;
    }
}

contract ERC20Basic {
  function transfer(address to, uint256 value) public returns (bool);
}

contract Bassdrops is EtherealFoundationOwned {
    string public constant CONTRACT_NAME = "Bassdrops";
    string public constant CONTRACT_VERSION = "A";
	string public constant QUOTE = "It’s a permanent, perfect SIMULTANEOUS dichotomy of total insignificance and total significance merged as one into every single flashing second.";
    
    string public constant name = "Bassdrops, a Currency of Omnitempo Maximalism";
    string public constant symbol = "BASS";
	
    uint256 public constant decimals = 11;  
	
    bool private tradeable;
    uint256 private currentSupply;
    mapping(address => uint256) private balances;
    mapping(address => mapping(address=> uint256)) private allowed;
    mapping(address => bool) private lockedAccounts;  
	

	/*
		Incomming Ether and ERC20
	*/	
    event RecievedEth(address indexed _from, uint256 _value, uint256 timeStamp);
	//this is the fallback
	function () payable public {
		RecievedEth(msg.sender, msg.value, now);		
	}
	
	event TransferedEth(address indexed _to, uint256 _value);
	function FoundationTransfer(address _to, uint256 amtEth, uint256 amtToken) public onlyOwner
	{
		require(this.balance >= amtEth && balances[this] >= amtToken );
		
		if(amtEth >0)
		{
			_to.transfer(amtEth);
			TransferedEth(_to, amtEth);
		}
		
		if(amtToken > 0)
		{
			require(balances[_to] + amtToken > balances[_to]);
			balances[this] -= amtToken;
			balances[_to] += amtToken;
			Transfer(this, _to, amtToken);
		}
	}		
	
	event TransferedERC20(address indexed _to, address indexed tokenContract, uint256 amtToken);
	function TransferERC20Token(address _to, address tokenContract, uint256 amtToken) internal onlyOwner{
			ERC20Basic token = ERC20Basic(tokenContract);
			require(token.transfer( _to, amtToken));
			TransferedERC20(_to, tokenContract, amtToken);
	}
	
	
	/*
		End Incomming Ether
	*/
	
	
	
    function Bassdrops(
		uint256 initialTotalSupply,
		uint256 initialTokensPerEth
		) public
    {
        currentSupply = initialTotalSupply * (10**decimals);
        balances[this] =  initialTotalSupply * (10**decimals);
        _tokenPerEth = initialTokensPerEth;
        tradeable = true;
        
    }
    
    uint256 private _tokenPerEth;
    function TokensPerWei() view public returns(uint256){
        return _tokenPerEth;
    }
    function SetTokensPerWei(uint256 tpe) public onlyOwner{
        _tokenPerEth = tpe;
    }
	
    event SoldToken(address indexed _buyer, uint256 _value, bytes32 note);
    function BuyToken(bytes32 note) public payable
    {
		require(msg.value > 0);
		
		//calculate value
		uint256 tokensToBuy = ((_tokenPerEth * (10**decimals)) * msg.value) / (10**18);
		
		require(balances[this] + tokensToBuy > balances[this]);
		SoldToken(msg.sender, tokensToBuy, note);
		Transfer(this,msg.sender,tokensToBuy);
		currentSupply += tokensToBuy;
		balances[msg.sender] += tokensToBuy;
        
    }
    
    function LockAccount(address toLock) public onlyOwner
    {
        lockedAccounts[toLock] = true;
    }
    function UnlockAccount(address toUnlock) public onlyOwner
    {
        delete lockedAccounts[toUnlock];
    }
    
    function SetTradeable(bool t) public onlyOwner
    {
        tradeable = t;
    }
    function IsTradeable() public view returns(bool)
    {
        return tradeable;
    }
    
    
    function totalSupply() constant public returns (uint256)
    {
        return currentSupply;
    }
    function balanceOf(address _owner) constant public returns (uint256 balance)
    {
        return balances[_owner];
    }
    function transfer(address _to, uint256 _value) public notLocked returns (bool success) {
        require(tradeable);
         if (balances[msg.sender] >= _value && _value > 0 && balances[_to] + _value > balances[_to]) {
             Transfer( msg.sender, _to,  _value);
             balances[msg.sender] -= _value;
             balances[_to] += _value;
             return true;
         } else {
             return false;
         }
     }
    function transferFrom(address _from, address _to, uint _value)public notLocked returns (bool success) {
        require(!lockedAccounts[_from] && !lockedAccounts[_to]);
		require(tradeable);
        if (balances[_from] >= _value
            && allowed[_from][msg.sender] >= _value
            && _value > 0
            && balances[_to] + _value > balances[_to]) {
                
            Transfer( _from, _to,  _value);
                
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            balances[_to] += _value;
            return true;
        } else {
            return false;
        }
    }
    
    function approve(address _spender, uint _value) public returns (bool success) {
        Approval(msg.sender,  _spender, _value);
        allowed[msg.sender][_spender] = _value;
        return true;
    }
    function allowance(address _owner, address _spender) constant public returns (uint remaining){
        return allowed[_owner][_spender];
    }
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
   
   modifier notLocked(){
       require (!lockedAccounts[msg.sender]);
       _;
   }
}