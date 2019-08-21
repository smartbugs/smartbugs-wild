pragma solidity ^0.4.4;


contract MockTestNetworkToken {

    // Token metadata
    string public constant name = "Test Network Token";
    string public constant symbol = "TNT";
    uint8 public constant decimals = 18;  // 18 decimal places, the same as ETH.

    // The current total token supply
    uint256 totalTokens;

    // Balances are stored here
    mapping (address => uint256) balances;

    // Always false, corresponds to ongoing crowdfunding
    bool transferable;


    // ERC20 interface - Transfer event used to track token transfers
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // ERC20 interface - minimal functional subset

    function transfer(address _to, uint256 _value) returns (bool) {
        if (transferable && balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
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

}

contract TestNetworkToken is MockTestNetworkToken {

    // Only this address is allowed to kill this contract
    address owner;

    uint256 public constant tokenCreationRate = 1000;

    event Refund(address indexed _from, uint256 _value);

    function TestNetworkToken() {
        owner = msg.sender;
    }

    // Public, external API exposed to all users interested in taking part in the crowdfunding

    function create() payable external {
        // Do not allow creating 0 tokens.
        if (msg.value == 0) throw;

        var numTokens = msg.value * tokenCreationRate;

        totalTokens += numTokens;

        // Assign new tokens to the sender
        balances[msg.sender] += numTokens;

        // Log token creation event
        Transfer(0x0, msg.sender, numTokens);
    }

    function refund() external {
        var tokenValue = balances[msg.sender];
        if (tokenValue == 0) throw;
        balances[msg.sender] = 0;
        totalTokens -= tokenValue;

        var ethValue = tokenValue / tokenCreationRate;
        Refund(msg.sender, ethValue);
        Transfer(msg.sender, 0x0, tokenValue);

        if (!msg.sender.send(ethValue)) throw;
    }

    // This is a test contract, so kill can be used once it is not needed
    
    function kill() {
        if (msg.sender != owner) throw;
        if (totalTokens > 0) throw;

        selfdestruct(msg.sender);
    }
}