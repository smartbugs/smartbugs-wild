pragma solidity ^0.4.4;

contract Token {
    
    function totalSupply() constant returns (uint256 supply) {}

    function balanceOf(address _owner) constant returns (uint256 balance) {}

    function transfer(address _to, uint256 _value) returns (bool success) {}

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    function approve(address _spender, uint256 _value) returns (bool success) {}

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}

contract RefugeCoin is StandardToken {

    /* Public variables of the token */

    string public name;                   
    uint8 public decimals;                
    string public symbol;                 
    string public version = 'H1.0'; 
    address private fundsWallet;
    uint256 private unitsOneEthCanBuyInPreICO;     
    uint256 private unitsOneEthCanBuyInFirstICO;     
    uint256 private unitsOneEthCanBuyInSecondICO;    
    uint256 public totalEthInWeiForPreIco;  
    uint256 public totalEthInWeiForFirstIco;  
    uint256 public totalEthInWeiForSecondIco;
    uint private PreIcoDeadline;
    uint private FirstICODeadline;
    uint private SecondICODeadline;
    uint256 public totalFirstICOSupply;
    uint256 public totalSecondICOSupply;
    uint256 public totalPreICOSupply;
    function RefugeCoin() {
        
        decimals = 18;
        balances[msg.sender] = 200000000 * 1e18;
        totalSupply = 200000000 * 1e18;
        name = "RefugeCoin";
        symbol = "RFG";
        fundsWallet = msg.sender;
        
        PreIcoDeadline = 1522540799;                              // Until 31/3
        FirstICODeadline = 1527811199;                            // Until 31/5
        SecondICODeadline = 1535759999;                           // Until 31/8
        
        unitsOneEthCanBuyInPreICO = 2000;
        unitsOneEthCanBuyInFirstICO = 1250;
        unitsOneEthCanBuyInSecondICO = 1111;
        
        totalPreICOSupply = 6000000 * 1e18;
        totalFirstICOSupply = 7000000 * 1e18;
        totalSecondICOSupply = 7000000 * 1e18;
    }

    function() payable{
        uint256 currentValue;
        uint256 amount;
        
        if(PreIcoDeadline > now){
            
            currentValue = unitsOneEthCanBuyInPreICO;
            amount = msg.value * currentValue;
            if (totalPreICOSupply < amount){
                return;
            }
            totalPreICOSupply = totalPreICOSupply - amount;
            totalEthInWeiForPreIco = totalEthInWeiForPreIco + msg.value;
            
        }else if(FirstICODeadline > now){
            
            currentValue = unitsOneEthCanBuyInFirstICO;
            amount = msg.value * currentValue;
            if (totalFirstICOSupply < amount){
                return;
            }
            totalFirstICOSupply = totalFirstICOSupply - amount;
            totalEthInWeiForFirstIco = totalEthInWeiForFirstIco + msg.value;
            
        }else if(SecondICODeadline > now){
            
            currentValue = unitsOneEthCanBuyInSecondICO;
            amount = msg.value * currentValue;
            if (totalSecondICOSupply < amount){
                return;
            }
            totalSecondICOSupply = totalSecondICOSupply - amount;
            totalEthInWeiForSecondIco = totalEthInWeiForSecondIco + msg.value;
        }else{
            return;
        }
        
        
        
        if (balances[fundsWallet] < amount) {
            return;
        }
        
        balances[fundsWallet] = balances[fundsWallet] - amount;
        balances[msg.sender] = balances[msg.sender] + amount;
    
        Transfer(fundsWallet, msg.sender, amount);
    
        fundsWallet.transfer(msg.value);
        
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}