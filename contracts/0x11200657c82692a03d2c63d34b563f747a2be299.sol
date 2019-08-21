pragma solidity >=0.4.22 <0.7.0;

library BalancesLib {
    function move(mapping(address => uint) storage balances, address _from, address _to, uint _amount) internal {
        require(balances[_from] >= _amount);
        require(balances[_to] + _amount >= balances[_to]);
        balances[_from] -= _amount;
        balances[_to] += _amount;
    }
}

contract Token {
    function balanceOf(address _owner) view public returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) view public returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    }

contract StandardERC20Token is Token {
    uint totalSupplyValue;
    address public owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
     modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function totalSupply() public view returns (uint _totalSupply) {
        _totalSupply=totalSupplyValue;
    }
    
    function transfer(address _to, uint _value) public returns (bool success) {
        require(!frozenAccount[msg.sender]);
        require(_to != address(0));
        balances.move(msg.sender, _to, _value);
        emit Transfer(msg.sender, _to, _value);
	    return true;
    }
    

    function transferFrom(address _from, address _to, uint _amount) public returns (bool success) {
        require(!frozenAccount[_from]);                         
        require(!frozenAccount[_to]);                           
        require(_to != address(0));
        require(allowed[_from][msg.sender] >= _amount);
        allowed[_from][msg.sender] -= _amount;
        balances.move(_from, _to, _amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint _tokens) public returns (bool success) {
        require(allowed[msg.sender][_spender] == 0, "");
        allowed[msg.sender][_spender] = _tokens;
        emit Approval(msg.sender, _spender, _tokens);
        return true;
    }

    function allowance(address _owner, address _spender) view public returns (uint remaining) {
      return allowed[_owner][_spender];
    }
   
    function freezeAccount(address _target, bool _freeze) public onlyOwner{
        frozenAccount[_target] = _freeze;
        emit FrozenFunds(_target, _freeze);
    }
    
    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return Token(tokenAddress).transfer(owner, tokens);
    }

    mapping (address => bool) public frozenAccount;
    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
    event FrozenFunds(address target, bool frozen);
    using BalancesLib for *;
}

contract AppUcoin is StandardERC20Token {

function () external payable{
        //if ether is sent to this address, send it back.
        revert();
}
    string public name;                 
    uint8 public decimals;               
    string public symbol;                
    string public version = '1.0'; 
    
    constructor () public{
        balances[msg.sender] = 1769520000000000;              
        totalSupplyValue = 1769520000000000;                       
        name = "AppUcoin";                                   
        decimals = 8;                                               
        symbol = "AU";      
   }
}