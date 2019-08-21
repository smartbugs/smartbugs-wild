pragma solidity ^0.4.4;


contract TestToken {

    string public constant name = "Test Network Token";
    string public constant symbol = "TNT";
    uint8 public constant decimals = 18;  // 18 decimal places, the same as ETH.

    uint256 public constant tokenCreationRate = 1000;

    // The current total token supply.
    uint256 totalTokens;
    
    address owner;
    uint256 public startMark;
    uint256 public endMark;

    mapping (address => uint256) balances;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Refund(address indexed _from, uint256 _value);
        
    function TestToken(address _owner, uint256 _startMark, uint256 _endMark) {
        owner = _owner;
        startMark = _startMark;
        endMark = _endMark;
    }

    // Transfer tokens from sender's account to provided account address.
    function transfer(address _to, uint256 _value) returns (bool) {
        var senderBalance = balances[msg.sender];
        if (senderBalance >= _value && _value > 0) {
            senderBalance -= _value;
            balances[msg.sender] = senderBalance;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }

        return false;
    }

    // Transfer tokens from sender's account to provided account address.
    function privilegedTransfer(address _from, address _to, uint256 _value) returns (bool) {
        if (msg.sender != owner) throw;
    
        var srcBalance = balances[_from];
        
        if (srcBalance >= _value && _value > 0) {
            srcBalance -= _value;
            balances[_from] = srcBalance;
            balances[_to] += _value;
            Transfer(_from, _to, _value);
            
            return true;
        }

        return false;
        
    }

    function totalSupply() external constant returns (uint256) {
        return totalTokens;
    }

    function balanceOf(address _owner) external constant returns (uint256) {
        return balances[_owner];
    }

    function fund() payable external {
        // Do not allow creating 0 tokens.
        if (msg.value == 0) throw;

        var numTokens = msg.value * tokenCreationRate;

        totalTokens += numTokens;

        // Assign new tokens to the sender
        balances[msg.sender] += numTokens;

        // Log token creation event
        Transfer(0x0, msg.sender, numTokens);
    }

    // Test redfunding
    function refund() external {
        var tokenValue = balances[msg.sender];
        if (tokenValue == 0) throw;
        balances[msg.sender] = 0;
        totalTokens -= tokenValue;

        var ethValue = tokenValue / tokenCreationRate;
        Refund(msg.sender, ethValue);

        if (!msg.sender.send(ethValue)) throw;
    }
    
    function kill() {
        if(msg.sender != owner) throw;
        
        selfdestruct(msg.sender);
    }
}