pragma solidity >=0.4.0 <0.6.0;

contract Token {

    function totalSupply() public  view returns (uint256 supply) {}

    function balanceOf(address _owner) public view returns (uint256 balance) {}

    function transfer(address _to, uint256 _value) public returns (bool success) {}

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {}

    function approve(address _spender, uint256 _value)public returns (bool success) {}

    function allowance(address _owner, address _spender)public  returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

contract StandardToken is Token {
  uint256 public _totalSupply;  
  string public name;  
  string public symbol;  
  uint32 public decimals;  
  address public owner;
  uint256 public oneTokenPrice;
  uint256 public  no_of_tokens;
  
  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;
  
   constructor() public {  
        symbol = "MAS";  
        name = "MAS";  
        decimals = 18;  
        _totalSupply = 2000000000* 10**uint(decimals);  
        owner = msg.sender;  
        balances[msg.sender] = _totalSupply; 
        oneTokenPrice = 0.01 ether;
    }
    
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
 

   function transfer(address _to, uint256 _value) public returns (bool success) {

        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            emit Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) public view  returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public  returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    function tokenForEther() public payable returns(uint256)
    {
        address payable _owner = address(uint160((owner))) ;
        no_of_tokens = msg.value/oneTokenPrice;
        _owner.transfer(msg.value);
        transferFrom(_owner,msg.sender,no_of_tokens);
        return no_of_tokens;
    }

}