pragma solidity ^0.4.17;


// ----------------------------------------------------------------------------
// 'KWHToken' contract
//
// Symbol      : KWHT
// Name        : KWHToken
// Total supply: 900,000.000000000000000000
// Decimals    : 18
//
// The MIT Licence.
// ----------------------------------------------------------------------------


// Overflow math functions.

contract SafeMath {

    function safeAdd(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function safeSub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function safeMul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function safeDiv(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }

    function assert(bool assertion) internal {
        require(assertion);
    }

}


// Contract Owned

contract Owned {

    address public owner;

    function Owned() {

        owner = msg.sender;

    }

    modifier onlyOwner {

        require(msg.sender == owner);
        _;

    }

    function transferOwnership(address newOwner) onlyOwner {

        require(newOwner != 0x0);
        
        owner = newOwner;

    }

}


// Contract Token

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


// StandardToken

contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {

        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {

            balances[msg.sender] -= _value;
            
            balances[_to] += _value;
            
            Transfer(msg.sender, _to, _value);
            
            return true;

        } else {
            
            return false;
            
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {

        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {

            balances[_from] -= _value;
            
            balances[_to] += _value;
            
            allowed[_from][msg.sender] -= _value;
            
            Transfer(_from, _to, _value);
            
            return true;

        } else {
            
            return false;
            
        }
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

}



// 'KWHToken' contract

contract KWHToken is SafeMath, Owned, StandardToken {

    string public symbol = "KWHT";
    
    string public name = "KWHToken";

    address public KWHTokenAddress = this;
    
    uint8 public decimals = 18;
    
    uint256 public totalSupply;
    
    uint256 public buyPriceEth = 5 finney;
    
    uint256 public sellPriceEth = 5 finney;
    
    uint256 public gasForKWH = 3 finney;
    
    uint256 public KWHForGas = 10;
    
    uint256 public gasReserve = 1 ether;
    
    uint256 public minBalanceForAccounts = 20 finney;
    
    bool public directTradeAllowed = false;


    function KWHToken() {
        
        totalSupply = 900000 * 10**uint(decimals);
        
        balances[msg.sender] = totalSupply;
        
    }

    function setEtherPrices(uint256 newBuyPriceEth, uint256 newSellPriceEth) onlyOwner {
        
        buyPriceEth = newBuyPriceEth;
        
        sellPriceEth = newSellPriceEth;
        
    }
    
    function setGasForKWH(uint newGasAmountInWei) onlyOwner {
        
        gasForKWH = newGasAmountInWei;
        
    }
    
    function setKWHForGas(uint newDCNAmount) onlyOwner {
        
        KWHForGas = newDCNAmount;
        
    }
    
    function setGasReserve(uint newGasReserveInWei) onlyOwner {
        
        gasReserve = newGasReserveInWei;
    
    }
    
    function setMinBalance(uint minimumBalanceInWei) onlyOwner {
        
        minBalanceForAccounts = minimumBalanceInWei;
        
    }


// Halts or unhalts direct trades without the sell and buy functions below
    function haltDirectTrade() onlyOwner {
        
        directTradeAllowed = false;
        
    }
    
    function unhaltDirectTrade() onlyOwner {
        
        directTradeAllowed = true;
        
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        
        require(_value > KWHForGas);
        
        if (msg.sender != owner && _to == KWHTokenAddress && directTradeAllowed) {
            
            sellKWHAgainstEther(_value);
            
            return true;
            
        }

        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            
            balances[msg.sender] = safeSub(balances[msg.sender], _value);

            if (msg.sender.balance >= minBalanceForAccounts && _to.balance >= minBalanceForAccounts) {
                
                balances[_to] = safeAdd(balances[_to], _value);
                
                Transfer(msg.sender, _to, _value);
                
                return true;
                
            } else {
                
                balances[this] = safeAdd(balances[this], KWHForGas);
                
                balances[_to] = safeAdd(balances[_to], safeSub(_value, KWHForGas));
                
                Transfer(msg.sender, _to, safeSub(_value, KWHForGas));

                if(msg.sender.balance < minBalanceForAccounts) {
                    
                    require(msg.sender.send(gasForKWH));
                    
                }
                
                if(_to.balance < minBalanceForAccounts) {
                    
                    require(_to.send(gasForKWH));
                
                }
            }
        } else { 
            throw; 
        }
    }

// User buys KWHs and pays in Ether
    function buyKWHAgainstEther() payable returns (uint amount) {
        
        require(!(buyPriceEth == 0 || msg.value < buyPriceEth));
        
        amount = msg.value / buyPriceEth;
        
        require(!(balances[this] < amount));
        
        balances[msg.sender] = safeAdd(balances[msg.sender], amount);
        
        balances[this] = safeSub(balances[this], amount);
        
        Transfer(this, msg.sender, amount);
        
        return amount;
    }


// User sells KWHs and gets Ether
    function sellKWHAgainstEther(uint256 amount) returns (uint revenue) {
        
        require(!(sellPriceEth == 0 || amount < KWHForGas));
        
        require(!(balances[msg.sender] < amount));
        
        revenue = safeMul(amount, sellPriceEth);
        
        require(!(safeSub(this.balance, revenue) < gasReserve));
        
        if (!msg.sender.send(revenue)) {
            
            throw;
            
        } else {
            
            balances[this] = safeAdd(balances[this], amount);
            
            balances[msg.sender] = safeSub(balances[msg.sender], amount);
            
            Transfer(this, msg.sender, revenue);
            
            return revenue;
        }
    }


// Refunding owner
    function refundToOwner (uint256 amountOfEth, uint256 kwh) onlyOwner {
        
        uint256 eth = safeMul(amountOfEth, 1 ether);
        
        if (!msg.sender.send(eth)) {
            
            throw;
            
        } else {
            
            Transfer(this, msg.sender, kwh);
            
        }
        
        require(!(balances[this] < kwh));
        
        balances[msg.sender] = safeAdd(balances[msg.sender], kwh);
        
        balances[this] = safeSub(balances[this], kwh);
        
        Transfer(this, msg.sender, kwh);
    }


    function() payable {
        
        if (msg.sender != owner) {
            
            require(directTradeAllowed);
            
            buyKWHAgainstEther();
            
        }
    }
}