pragma solidity ^0.4.24;

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

contract AI42TOKEN is StandardToken { // contract name.

    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   // Token Name
    uint8 public decimals;                // How many decimals to show. To be standard complicant keep it 18
    string public symbol;                 // An identifier: eg SBX, XPR etc..
    string public version = 'V1.2'; 
    uint256 public unitsOneEthCanBuy;     // AI42 units 1 ETH can buy
    uint256 public totalEthInWei;         // WEI is the smallest unit of ETH (the equivalent of cent in USD or satoshi in BTC). We'll store the total ETH raised here.  
    address public fundsWallet;           // Where should the raised ETH go?
    uint256 public AI42IndexValue;        // AI-42 INDEX Value (f.e. 150034 for 1,500.34)
    uint256 public ETHUSDrate;            // Exchange rate EHT to USD

    // This is a constructor function 
    // which means the following function name has to match the contract name declared above
    constructor () public AI42TOKEN() {
        balances[msg.sender] = 100000 * 1e18;                   // Gives the creator all initial tokens.
        totalSupply = 100000 * 1e18;                            // Total supply 
        name = "AI-42 INDEX Token";                             // Sets the name for display purposes 
        decimals = 18;                                          // Amount of decimals for display purposes 
        symbol = "AI42";                                        // Sets the symbol for display purposes 
        unitsOneEthCanBuy = 0.07326 * 1e18;                     // AI42 units 1 ETH can buy
        fundsWallet = msg.sender;                               // The owner of the contract gets ETH
        AI42IndexValue = 150032;                                // Initial value of AI42 INDEX; here INDEX = 1500.32
        ETHUSDrate = 10992;                                     // Initial ETH : USD conversion rate; here 1 ETH = 109.92 USD
    }

    function() public payable{
        totalEthInWei = totalEthInWei + msg.value;
        uint256 amount = msg.value * unitsOneEthCanBuy / 1e18;
        require(balances[fundsWallet] >= amount);

        balances[fundsWallet] = balances[fundsWallet] - amount ;
        balances[msg.sender] = balances[msg.sender] + amount ;

        emit Transfer(fundsWallet, msg.sender, amount); // Broadcast a message to the blockchain

        //Transfer ether to fundsWallet
        fundsWallet.transfer(msg.value);                               
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success)  {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
    
    /**
     * @return set the AI42 INDEX value
     */
    function setAI42IndexValue(uint256 x) public returns (bool) {
        require(msg.sender == fundsWallet);                     // Only owner can update the AI42 INDEX value
        AI42IndexValue = x;
        return true;
    }
    /**
     * @return set the ETHUSDrate value
     */
    function setETHUSDrate(uint256 x) public returns (bool) {
        require(msg.sender == fundsWallet);                     // Only owner can update the AI42 INDEX value
        ETHUSDrate = x;
        return true;
    }
    /**
     * @return set the unitsOneEthCanBuy value
     */
    function setunitsOneEthCanBuy(uint256 x) public returns (bool) {
        require(msg.sender == fundsWallet);                     // Only owner can update the AI42 INDEX value
        unitsOneEthCanBuy = x;
        return true;
    }
    /**
     * @return retreive the current AI42 INDEX value
     */
    function getAI42IndexValue() public view returns (uint256) {
        return AI42IndexValue;
    }
    /**
     * @return retreive the current ETHUSDrate value
     */
    function getETHUSDrate() public view returns (uint256) {
        return ETHUSDrate;
    }
    /**
     * @return retreive the current unitsOneEthCanBuy value
     */
    function getunitsOneEthCanBuy() public view returns (uint256) {
        return unitsOneEthCanBuy;
    }
}