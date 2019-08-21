pragma solidity ^0.4.16;

contract Owned {

    
    address public owner;
    address public ico;

    function Owned() {
        owner = msg.sender;
        ico = msg.sender;
    }

    modifier onlyOwner() {
        
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyICO() {
        
        require(msg.sender == ico);
        _;
    }

    function transferOwnership(address _newOwner) onlyOwner {
        owner = _newOwner;
    }
    function transferIcoship(address _newIco) onlyOwner {
        ico = _newIco;
    }
}


contract Token {
    
    uint256 public totalSupply;

    function balanceOf(address _owner) constant returns (uint256 balance);

    function transfer(address _to, uint256 _value) returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    function approve(address _spender, uint256 _value) returns (bool success);

    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract StandardToken is Token,Owned {

    bool public locked;

    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;
    
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
    mapping (address => bool) public frozenAccount;
    event FrozenFunds(address target, bool frozen);
    
    function freezeAccount(address target, bool freeze) onlyOwner {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    function transfer(address _to, uint256 _value) returns (bool success) {

        require(!locked);
        require(!frozenAccount[msg.sender]);
        
        require(balances[msg.sender] >= _value);
        
        require(balances[_to] + _value >= balances[_to]);
       
        balances[msg.sender] -= _value;
        balances[_to] += _value;


        Transfer(msg.sender, _to, _value);
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {

        require(!locked);
        
        require(balances[_from] >= _value);
             
        require(balances[_to] + _value >= balances[_to]);    
       
        require(_value <= allowed[_from][msg.sender]);    

        balances[_to] += _value;
        balances[_from] -= _value;

        allowed[_from][msg.sender] -= _value;

        Transfer(_from, _to, _value);
        return true;
    }


    function approve(address _spender, uint256 _value) returns (bool success) {
  
        require(!locked);

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);
        return true;
    }


    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
}



contract FccToken is Owned, StandardToken {

    string public standard = "Token 0.2";

    string public name = "First Capital Coin";        
    
    string public symbol = "FCC";

    uint8 public decimals = 8;
   
    function FccToken() {  
        balances[msg.sender] = 500000000* 10**8;
        totalSupply = 500000000* 10**8;
        locked = false;
    }
   
    function unlock() onlyOwner returns (bool success)  {
        locked = false;
        return true;
    }
    
    function lock() onlyOwner returns (bool success)  {
        locked = true;
        return true;
    }
    
    

    function issue(address _recipient, uint256 _value) onlyICO returns (bool success) {

        require(_value >= 0);

        balances[_recipient] += _value;
        totalSupply += _value;

        Transfer(0, owner, _value);
        Transfer(owner, _recipient, _value);

        return true;
    }
   
    function () {
        throw;
    }
}