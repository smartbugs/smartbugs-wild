pragma solidity ^0.4.8;
contract Token{

    uint256 public totalSupply;    //Token amount, by default, generates a getter function interface for the public variable with the name of totalSupply().

    function balanceOf(address _owner) constant returns (uint256 balance);    // Gets the number of tokens owned by the account _owner


    function transfer(address _to, uint256 _value) returns (bool success);    //Token that transfers amount to _value from message sender account

    function transferFrom(address _from, address _to, uint256 _value) returns   // token transferred from account _from to account _to is used in conjunction with the approve method
    (bool success);

    function allowance(address _owner, address _spender) constant returns // get the number of tokens that the account _spender can transfer from the account _owner
    (uint256 remaining);
    
    function approve(address _spender, uint256 _value) returns (bool success); // message sending account setting account _spender can transfer the number of token as _value from the sending account

    event Approval(address indexed _owner, address indexed _spender, uint256 
    _value);
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

}

contract StandardToken is Token {
    function transfer(address _to, uint256 _value) returns (bool success) {
        //The default totalSupply does not exceed the maximum (2^256 - 1).
        //require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;//Subtract the token number _value from the message sender account
        balances[_to] += _value;//Add token number _value to receive account
        Transfer(msg.sender, _to, _value);//Trigger the exchange transaction event
        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) returns 
    (bool success) {
        //require(balances[_from] >= _value && allowed[_from][msg.sender] >= 
        // _value && balances[_to] + _value > balances[_to]);
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        balances[_to] += _value;//Receive account increases token number _value
        balances[_from] -= _value; //The expenditure account _from minus the number of tokens _value
        allowed[_from][msg.sender] -= _value;//The number of messages sent from the account _from can be reduced by _value
        Transfer(_from, _to, _value);//Trigger the exchange transaction event
        return true;
    }

    function approve(address _spender, uint256 _value) returns (bool success)   
    {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
}

contract TIAToken is StandardToken { 

    /* Public variables of the token */
    string public name;                   //eg Simon Bucks
    uint8 public decimals;               //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.
    string public symbol;              
    string public version = 'H0.1';  

    function TIAToken(uint256 _initialAmount, string _tokenName, uint8 _decimalUnits, string _tokenSymbol) {
        balances[msg.sender] = _initialAmount; 
        totalSupply = _initialAmount;       
        name = _tokenName;                   
        decimals = _decimalUnits;          
        symbol = _tokenSymbol;            
    }

    /* Approves and then calls the receiving contract */
    
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }

}