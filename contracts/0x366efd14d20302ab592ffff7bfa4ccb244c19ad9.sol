pragma solidity ^0.4.20;

contract LCoin {
    mapping (address => uint256) public balanceOf;
	mapping (address => mapping (address => uint256)) allowed;

	uint256 public totalSupply;
	string public name;
	string public symbol;
	uint8 public decimals;
	
    constructor(uint _totalSupply,string tokenName,string tokenSymbol,uint8 decimalUnits) public{
		balanceOf[msg.sender] = _totalSupply; 
		totalSupply = _totalSupply;
		name = tokenName;		
		symbol = tokenSymbol;		
		decimals = decimalUnits;	
	}
	function transfer(address _to, uint256 _value) public returns (bool success){
		require(balanceOf[msg.sender]>=_value);			
		require(balanceOf[_to] + _value >= balanceOf[_to]);	
		balanceOf[msg.sender] -= _value;
		balanceOf[_to] += _value;
		return true;
	}
	
	
	function transferFrom(address _from,address _to,uint _value) public 
	returns (bool success){
		require(balanceOf[_from]>= _value);
		require(allowed[_from][msg.sender]>=_value);
		require(_value>0);
		balanceOf[_to] += _value;
        balanceOf[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
	}
	
	
	function approve(address _spender,uint _value) public returns (bool success){
		allowed[msg.sender][_spender] = _value;
	        emit Approval(msg.sender, _spender, _value);
		return true;
	}
	
	event Transfer(address indexed _from,address indexed _to,uint _value);
	
	event Approval(address indexed _owner, address indexed _spender, uint _value);
}