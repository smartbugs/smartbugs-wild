pragma solidity ^0.4.18;

contract MigrationAgent {
    function migrateFrom(address _from, uint256 _value);
}

contract ERC20Interface {
     function totalSupply() constant returns (uint256 totalSupply);
     function balanceOf(address _owner) constant returns (uint256 balance);
     function transfer(address _to, uint256 _value) returns (bool success);
     function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
     function approve(address _spender, uint256 _value) returns (bool success);
     function allowance(address _owner, address _spender) constant returns (uint256 remaining);
     event Transfer(address indexed _from, address indexed _to, uint256 _value);
     event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/// ETH (EEE)
contract ETHToken is ERC20Interface {
    string public constant name = "ETHToken";
    string public constant symbol = "EEE";
    uint8 public constant decimals = 18;  // 18 decimal places, the same as ETH.
    uint256 public constant tokenCreationCap = 3000000* 10**18;
    uint256 public constant tokenCreationMin = 1* 10**18;
    mapping(address => mapping (address => uint256)) allowed;
    uint public fundingStart;
    uint public fundingEnd;
    bool public funding = true;
    address public master;
    uint256 totalTokens;
    uint256 soldAfterPowerHour;
    mapping (address => uint256) balances;
    mapping (address => uint) lastTransferred;
    mapping (address => uint256) balancesEther;
    address public migrationAgent;
    uint256 public totalMigrated;
    event Migrate(address indexed _from, address indexed _to, uint256 _value);
    event Refund(address indexed _from, uint256 _value);
    uint totalParticipants;

    function ETHToken() {
        master = msg.sender;
        fundingStart = 1511654250;
        fundingEnd = 1511663901;
    }
    
    function getAmountofTotalParticipants() constant returns (uint){
        return totalParticipants;
    }
    
    function getAmountSoldAfterPowerDay() constant external returns(uint256){
        return soldAfterPowerHour;
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        if(funding) throw;

        var senderBalance = balances[msg.sender];
        if (senderBalance >= _value && _value > 0) {
            senderBalance -= _value;
            balances[msg.sender] = senderBalance;
            
            balances[_to] += _value;
            
            lastTransferred[msg.sender]=block.timestamp;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }
    function totalSupply() constant returns (uint256 totalSupply) {
        return totalTokens;
    }
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
    function EtherBalanceOf(address _owner) constant returns (uint256) {
        return balancesEther[_owner];
    }
    function TimeLeft() external constant returns (uint256) {
        if(fundingEnd>block.timestamp)
            return fundingEnd-block.timestamp;
        else
            return 0;
    }
    function TimeLeftBeforeCrowdsale() external constant returns (uint256) {
        if(fundingStart>block.timestamp)
            return fundingStart-block.timestamp;
        else
            return 0;
    }
function migrate(uint256 _value) external {
        if(funding) throw;
        if(migrationAgent == 0) throw;
        if(_value == 0) throw;
        if(_value > balances[msg.sender]) throw;
        balances[msg.sender] -= _value;
        totalTokens -= _value;
        totalMigrated += _value;
        MigrationAgent(migrationAgent).migrateFrom(msg.sender, _value);
        Migrate(msg.sender, migrationAgent, _value);
    }

    function setMigrationAgent(address _agent) external {
        if(funding) throw;
        
        if(migrationAgent != 0) throw;
        
        if(msg.sender != master) throw;
        
        migrationAgent = 0x52918621C4bFcdb65Bb683ba5bDC03e398451Afd;
    }
    
    function getExchangeRate() constant returns(uint){
            return 30000; // 30000 
    }
    
    function ICOopen() constant returns(bool){
        if(!funding) return false;
        else if(block.timestamp < fundingStart) return false;
        else if(block.timestamp > fundingEnd) return false;
        else if(tokenCreationCap <= totalTokens) return false;
        else return true;
    }

    function() payable external {
        if(!funding) throw;
        if(block.timestamp < fundingStart) throw;
        if(block.timestamp > fundingEnd) throw;
        if(msg.value == 0) throw;
        if((msg.value  * getExchangeRate()) > (tokenCreationCap - totalTokens)) throw;
        var numTokens = msg.value * getExchangeRate();
        totalTokens += numTokens;
        
        if(getExchangeRate()!=30000){
            soldAfterPowerHour += numTokens;
        }
        balances[msg.sender] += numTokens;
        balancesEther[msg.sender] += msg.value;
        totalParticipants+=1;
        Transfer(0, msg.sender, numTokens);
    }

    function finalize() external {
        if(!funding) throw;
        funding = false;
        uint256 percentOfTotal = 25;
        uint256 additionalTokens = totalTokens * percentOfTotal / (37 + percentOfTotal);
        totalTokens += additionalTokens;
        balances[master] += additionalTokens;
        Transfer(0, master, additionalTokens);
        if (!master.send(this.balance)) throw;
    }

    function refund() external {
        if(!funding) throw;
        if(block.timestamp <= fundingEnd) throw;
        if(totalTokens >= tokenCreationMin) throw;

        var ethuValue = balances[msg.sender];
        var ethValue = balancesEther[msg.sender];
        if (ethuValue == 0) throw;
        balances[msg.sender] = 0;
        balancesEther[msg.sender] = 0;
        totalTokens -= ethuValue;

        Refund(msg.sender, ethValue);
        if (!msg.sender.send(ethValue)) throw;
    }
  
     function transferFrom(address _from,address _to,uint256 _amount) returns (bool success) {
         if(funding) throw;
         if (balances[_from] >= _amount
             && allowed[_from][msg.sender] >= _amount
             && _amount > 0
             && balances[_to] + _amount > balances[_to]) {
             balances[_from] -= _amount;
             allowed[_from][msg.sender] -= _amount;
             balances[_to] += _amount;
             Transfer(_from, _to, _amount);
             return true;
         } else {
             return false;
         }
     }
  
     function approve(address _spender, uint256 _amount) returns (bool success) {
         if(funding) throw;
         allowed[msg.sender][_spender] = _amount;
         Approval(msg.sender, _spender, _amount);
         return true;
     }
  
     function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
         return allowed[_owner][_spender];
     }
}