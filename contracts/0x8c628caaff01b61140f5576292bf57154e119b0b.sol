pragma solidity ^0.4.18;


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


contract RiemannianNonorientableManifolds is EtherealFoundationOwned {
    string public constant CONTRACT_NAME = "RiemannianNonorientableManifolds";
    string public constant CONTRACT_VERSION = "B";
	string public constant QUOTE = "'Everything is theoretically impossible, until it is done.' -Robert A. Heinlein";
    
    string public constant name = "Riemannian Nonorientable Manifolds";
    string public constant symbol = "RNM";
	
    uint256 public constant decimals = 18;  // 18 is the most common number of decimal places
	
    bool private tradeable;
    uint256 private currentSupply;
    mapping(address => uint256) private balances;
    mapping(address => mapping(address=> uint256)) private allowed;
    mapping(address => bool) private lockedAccounts;  
	
	/*
		Incomming Ether
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
	/*
		End Incomming Ether
	*/
	
	
	
    function RiemannianNonorientableManifolds(
		uint256 initialTotalSupply, 
		address[] addresses, 
		uint256[] initialBalances, 
		bool initialBalancesLocked
		) public
    {
        require(addresses.length == initialBalances.length);
        
        currentSupply = initialTotalSupply * (10**decimals);
        uint256 totalCreated;
        for(uint8 i =0; i < addresses.length; i++)
        {
            if(initialBalancesLocked){
                lockedAccounts[addresses[i]] = true;
            }
            balances[addresses[i]] = initialBalances[i]* (10**decimals);
            totalCreated += initialBalances[i]* (10**decimals);
        }
        
        
        if(currentSupply < totalCreated)
        {
            selfdestruct(msg.sender);
        }
        else
        {
            balances[this] = currentSupply - totalCreated;
        }
    }
    
	
    event SoldToken(address indexed _buyer, uint256 _value, bytes32 note);
    function BuyToken(address _buyer, uint256 _value, bytes32 note) public onlyOwner
    {
		require(balances[this] >= _value && balances[_buyer] + _value > balances[_buyer]);
		
        SoldToken( _buyer,  _value,  note);
        balances[this] -= _value;
        balances[_buyer] += _value;
        Transfer(this, _buyer, _value);
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