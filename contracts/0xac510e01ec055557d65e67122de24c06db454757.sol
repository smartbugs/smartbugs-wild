pragma solidity ^0.4.19;

contract owned{
	address public owner;

function owned() public {
	owner = msg.sender;
}

modifier onlyOwner{
	require(msg.sender == owner);
_;
}

function transferOwnership(address newOwner) onlyOwner public {
	owner = newOwner;
}
}

//declare basic Events for Token Base
contract Token{
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
event Approval(address indexed _owner, address indexed _spender, uint256 _value);
event Burn(address indexed _from, uint256 _amount);
}

contract StandardToken is Token{

	function transfer(address _to, uint256 _value) public returns(bool success) {
	if (balances[msg.sender] >= _value && _value > 0) {
		balances[msg.sender] -= _value;
		balances[_to] += _value;
		Transfer(msg.sender, _to, _value);
		return true;
	}
	else {
		return false;
	}
}

function transferFrom(address _from, address _to, uint256 _value) public returns(bool success) {
	if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
		balances[_to] += _value;
		balances[_from] -= _value;
		allowed[_from][msg.sender] -= _value;
		Transfer(_from, _to, _value);
		return true;
	}
	else {
		return false;
	}
}

function balanceOf(address _owner) constant public returns(uint256 amount) {
	return balances[_owner];
}

function approve(address _spender, uint256 _value) public returns(bool success) {
	allowed[msg.sender][_spender] = _value;
	Approval(msg.sender, _spender, _value);
	return true;
}

function burn(uint256 _amount) public returns(bool success) {
	require(balances[msg.sender] >= _amount);
	balances[msg.sender] -= _amount;
	totalSupply -= _amount;
	Burn(msg.sender, _amount);
	return true;
}

function burnFrom(address from, uint256 _amount) public returns(bool success)
{
	require(balances[from] >= _amount);
	require(_amount <= allowed[from][msg.sender]);
	balances[from] -= _amount;
	allowed[from][msg.sender] -= _amount;
	totalSupply -= _amount;
	Burn(from, _amount);
	return true;
}

function allowance(address _owner, address _spender) constant public returns(uint256 remaining) {
	return allowed[_owner][_spender];
}

mapping(address => uint256) balances;
mapping(address => mapping(address => uint256)) allowed;
uint256 public totalSupply;
uint256 public availableSupply;
uint256 public releasedSupply;
}


/////////////////////////////////////////////
//Advanced Token functions - advanced layer//
/////////////////////////////////////////////
contract AuraToken is StandardToken, owned{
	function() public payable{
	if (msg.sender != owner)
	giveTokens(msg.sender,msg.value);
}


string public name;
uint8 public decimals;
string public symbol;
uint256 public buyPrice;  //in wei


						  //make sure this constructor name matches contract name above
function AuraToken() public{
	decimals = 18;                            // Amount of decimals for display purposes
	totalSupply = 50000000 * 10 ** uint256(decimals);  // Update total supply 
	releasedSupply = 0;
	availableSupply = 0;
	name = "AuraToken";                                   // Set the name for display purposes
	symbol = "AURA";                               // Set the symbol for display purposes
	buyPrice = 1 * 10 ** 18;			//set unreal price for the beginning to prevent attacks (in wei)
}

function giveTokens(address _payer, uint256 _payment) internal returns(bool success) {
	require(_payment > 0);
	uint256 tokens = (_payment / buyPrice) * (10 ** uint256(decimals));
	if (availableSupply < tokens)tokens = availableSupply;
	require(availableSupply >= tokens);
	require((balances[_payer] + tokens) > balances[_payer]); //overflow test
	balances[_payer] += tokens;
	availableSupply -= tokens;
	return true;
}

function giveReward(address _to, uint256 _amount) public onlyOwner returns(bool success) {
	require(_amount > 0);
	require(_to != 0x0); // burn instead
	require(availableSupply >= _amount);
	require((balances[_to] + _amount) > balances[_to]);
	balances[_to] += _amount;
	availableSupply -= _amount;
	return true;
}

function setPrice(uint256 _newPrice) public onlyOwner returns(bool success) {
	buyPrice = _newPrice;
	return true;
}

function release(uint256 _amount) public onlyOwner returns(bool success) {
	require((releasedSupply + _amount) <= totalSupply);
	releasedSupply += _amount;
	availableSupply += _amount;
	return true;
}

function withdraw(uint256 _amount) public onlyOwner returns(bool success) {
	msg.sender.transfer(_amount);
	return true;
}
}

//EOF