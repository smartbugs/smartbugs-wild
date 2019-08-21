pragma solidity ^0.4.17;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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
contract EthereumTrustFund {
    
    using SafeMath for uint256;
    
    string public constant name   	= "Ethereum Trust Fund";
    string public constant symbol 	= "ETRUST";
    uint8  public constant decimals = 18;
    uint256 public rate = 10;
    // todo
    uint256 public constant _totalSupply = 1000000000000;
    uint256 public 		_totalSupplyLeft = 1000000000000;
    uint256 tokens                       = 0;
    // vars
    mapping(address => uint256) balances; 
    mapping(address => mapping(address => uint256)) allowedToSpend;
    address public contract_owner;
    uint256 currentBlock = 0;
    uint256 lastblock    = 0;
    // init function
    function EthereumTrustFund() public{
    	currentBlock = block.number;
    	lastblock    = block.number;
    }
    // ## ERC20 standards ##
    
    // Get the total token supply
    function totalSupply() constant public returns (uint256 thetotalSupply){
    	return _totalSupply;
    }
    // Get the account balance of another account with address _queryaddress
    function balanceOf(address _queryaddress) constant public returns (uint256 balance){
    	return balances[_queryaddress];
    }
 	
    // Send _value amount of tokens to address _to
    function transfer(address _to, uint256 _value) public returns (bool success){
    	require(
    		balances[msg.sender] >= _value
    		&& _value > 0);
    	balances[msg.sender] = balances[msg.sender].sub(_value);
    	balances[_to]      	 = balances[_to].add(_value);
    	Transfer(msg.sender, _to,_value);
    	return true;
    }
    // Send _value amount of tokens from address _from to address _to
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
    	require(
    		allowedToSpend[_from][msg.sender] >= _value
    		&& balances[_from] >= _value
    		&& _value > 0);
    	balances[_from] = balances[_from].sub(_value);
    	balances[_to]   = balances[_to].add(_value);
    	allowedToSpend[_from][msg.sender] = allowedToSpend[_from][msg.sender].sub(_value);
    	Transfer(_from, _to, _value);
    	return true;
    }
    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    // this function is required for some DEX functionality
    function approve(address _spender, uint256 _value) public returns (bool success){
    	allowedToSpend[msg.sender][_spender] = _value;
    	Approval(msg.sender, _spender, _value);
    	return true;
    }
    // Returns the amount which _spender is still allowed to withdraw from _owner
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining){
    	return allowedToSpend[_owner][_spender];
    }
    // Triggered when tokens are transferred.
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    // Triggered whenever approve(address _spender, uint256 _value) is called.
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    // ## ERC20 standards end ##
    // ## Custom functions ###
    function() public payable {
    	require(msg.value > 0);
    	tokens 		 = msg.value.mul(rate);
    	currentBlock = block.number;
    	if(rate > 1 && currentBlock.sub(lastblock) > 3000){
    		rate = rate.sub(1);
    		RateChange(rate);
    		lastblock 		 = currentBlock;
    	} 
    	balances[msg.sender] = balances[msg.sender].add(tokens);
    	_totalSupplyLeft 	 = _totalSupplyLeft.sub(tokens);
    	contract_owner.transfer(msg.value);
    	MoneyTransfered(contract_owner,msg.value);
    	
    }
    function shutThatShitDown() public {
    	require(msg.sender == contract_owner);
    	selfdestruct(contract_owner);
    }
    
    // 
    event RateChange(uint256 _rate);
    // 
    event MoneyTransfered(address indexed _owner, uint256 _msgvalue);
    
}