pragma solidity ^0.4.4;

contract Token {

    /// @return total amount of tokens
    function totalSupply() constant returns (uint256 supply) {}

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance) {}

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success) {}

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success) {}

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
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

contract KillYourselfCoin is StandardToken {

    /* Public variables of the token */

    string public name;                 // Token Name
    uint8 public decimals;              // How many decimals to show.
    string public symbol;               // Identifier
    string public version = "v1.0";     // Version number
    uint256 public unitsOneEthCanBuy;   // Number of coins per ETH
    uint256 public totalEthInWei;       // Keep track of ETH contributed
    uint256 public tokensIssued;        // Keep track of tokens issued
    address public owner;               // Address of contract creator
    uint256 public availableSupply;     // Tokens available for sale
    uint256 public reservedTokens;      // Tokens reserved not for sale
    bool public purchasingAllowed = false;

    // This is a constructor function
    // which means the following function name has to match the contract name declared above
    function KillYourselfCoin() {
        owner = msg.sender;                               // Set the contract owner
        decimals = 18;                                    // Amount of decimals for display. 18 is ETH recommended
        totalSupply = 1500000000000000000000000;          // Total token supply
        availableSupply = 1393800000000000000000000;      // Tokens available for sale
        reservedTokens = totalSupply - availableSupply;   // Calculate reserved tokens
        balances[owner] = totalSupply;                    // Give the creator all initial tokens

        name = "Kill Yourself Coin";                      // Set the token name
        symbol = "KYS";                                   // Set the token symbol
        unitsOneEthCanBuy = 6969;                         // Token price
    }

    function enablePurchasing() {
        if (msg.sender != owner) { revert(); }
        purchasingAllowed = true;
    }

    function disablePurchasing() {
        if (msg.sender != owner) { revert(); }
        purchasingAllowed = false;
    }

    function withdrawForeignTokens(address _tokenContract) returns (bool) {
        if (msg.sender != owner) { revert(); }

        Token token = Token(_tokenContract);

        uint256 amount = token.balanceOf(address(this));
        return token.transfer(owner, amount);
    }

    function() payable{
        // Revert transaction if purchasing has been disabled
        if (!purchasingAllowed) { revert(); }
        // Revert transaction if it doesn't include any ETH
        if (msg.value == 0) { revert(); }

        uint256 amount = msg.value * unitsOneEthCanBuy;
        if (balances[owner] - reservedTokens < amount) {
            revert();
        }

        totalEthInWei = totalEthInWei + msg.value;
        tokensIssued = tokensIssued + amount;

        balances[owner] = balances[owner] - amount;
        balances[msg.sender] = balances[msg.sender] + amount;

        // Broadcast a message to the blockchain
        Transfer(owner, msg.sender, amount);

        //Transfer ETH to owner
        owner.transfer(msg.value);
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert(); }
        return true;
    }
}