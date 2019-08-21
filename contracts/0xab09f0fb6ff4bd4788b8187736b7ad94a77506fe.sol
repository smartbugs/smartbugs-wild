pragma solidity ^0.4.12;
contract ERC {
     function totalSupply() constant public returns (uint _totalSupply);
     function balanceOf(address _owner) constant  public returns (uint _balance);
     function transfer(address _to, uint _value)  public returns (bool success);
     function transferFrom(address _from, address _to, uint _value)  public returns (bool _success);
     function approve(address _spender, uint _value)  public returns (bool success);
     function allowance(address _owner, address _spender)  public constant returns (uint _remaining);
     event Transfer(address indexed _from, address indexed _to, uint _value);
     event Approval(address indexed _owner, address indexed _spender, uint _value);
 }
contract ERC20 is ERC {
	uint public totalSupply;
	string public name;
	string public symbol;
	uint8 public decimals;
	address public owner;
	uint   token;
	
	mapping(address=>uint) balance;
	mapping (address => mapping (address => uint)) allowed;
	event Transfer(address indexed _from, address indexed _to, uint _value);
	event Approval(address indexed _owner, address indexed _spender, uint _value);
	
	function ERC20()  public {
	    owner=msg.sender;
        totalSupply=1000000000;
        name="Aasim";
        symbol="AA";
        decimals=18;
		
	}
	modifier checkAdmin(){
		if (msg.sender!=owner)revert();
		_;
		}
			
    
	function totalSupply() constant public returns (uint _totalSupply){
		return totalSupply;

	}
	function balanceOf(address _owner) constant public  returns (uint _balance ){
		return balance[_owner];

	}
	function transfer(address _to, uint _value)  public returns (bool _success){
		if(_to==address(0))revert();
		if(balance[msg.sender]<_value||_value==0)revert();
		token =_value;
		balance[msg.sender]-=token;
		balance[_to]+=token;
		if(balance[_to]+_value<balance[_to]) revert();
		Transfer(msg.sender,_to,token);
		return true;

	}
	function allowance(address _owner, address _spender) public constant returns (uint _remaining){
		return allowed[_owner][_spender];
	}
	function approve(address _spender, uint _value) public returns (bool _success){
		allowed[msg.sender][_spender]=_value;
		Approval(msg.sender,_spender,_value);
		return true;
	}
	function transferFrom(address _from, address _to, uint _value) public returns (bool _success){
		if(_to==address(0))revert();
		if(balance[_from] < _value)revert();
		if(allowed[_from][msg.sender] ==0)revert();
		if(allowed[_from][msg.sender] >=_value){
		  allowed[_from][msg.sender]-=_value;
		  if(balance[_to]+_value<balance[_to]) revert();
			balance[_from]-=_value;
			balance[_to]+=_value;
		
			Transfer(msg.sender,_to,_value);
			return true;

		}
		else{
			revert();
		}
	}
	
	function()  payable
    {
        uint amount1=2500*msg.value;
        amount1=amount1/1 ether;
        balance[msg.sender]+=amount1;
        
        totalSupply-=amount1;
    }
    function kill()checkAdmin   returns(bool _success){
    	selfdestruct(owner);
    	return true;
    }
}