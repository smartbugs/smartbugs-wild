pragma solidity ^0.4.4;

contract Broodt {
    // hallo dit is een cryptovaluta munt token genaamt: BROODT
    // als je BROODT wil stuur dan helemaal niks naar het contract adress en je krijgt 1 BROODT gratis
    // als je meer wilt dan moet je eth sturen of gewoon heel kut zijn en heel vaak niks sturen.
    // 0.0001 eth = 1 BROODT
    // alle ETH gaat naar mij en niet arno hahaha
    // fb arno: https://www.facebook.com/Arnosplaatjevoorjou
    // fijne dag gewenst grt.
    
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

contract StandardToken is Broodt {

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

contract ArnosMotiverendeTokensVoorOverdagEnSomsInDeNacht is StandardToken { // CHANGE THIS. Update the contract name.

    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                 // Token Name
    uint8 public decimals;                // How many decimals to show. To be standard complicant keep it 18
    string public symbol;                // An identifier: eg SBX, XPR etc..
    string public version = 'H1.0'; 
    uint256 public unitsOneEthCanBuy;     // How many units of your coin can be bought by 1 ETH?
    address public fundsWallet;           // Where should the raised ETH go?
    uint256 public creatorReward;
    address public contractWallet;
    

    // This is a constructor function 
    // which means the following function name has to match the contract name declared above
    function ArnosMotiverendeTokensVoorOverdagEnSomsInDeNacht() {
        creatorReward = 420;                                    // deze zijn voor mij
        totalSupply = 420000;
        balances[msg.sender] = creatorReward;                   
        balances[address(this)] = totalSupply - creatorReward;  // store all the tokens in the contract
        name = "ArnosMotiverendeTokensVoorOverdagEnSomsInDeNacht";// AAAAAA NEEEE GEEF BROODT
        decimals = 0;                                           // wie wil nou 0.1 broodt zech nou eerlijk haha
        symbol = "BROODT";                                      // had een bloedgroep B emoji geprobeert maar dat vond etherscan niet chill
        unitsOneEthCanBuy = 10000;                              // send 1 eth and get 10000 broodt send 0.0001 eth and get 1 broodt
        fundsWallet = msg.sender;                               // The owner of the contract gets ETH (dat ben ik en niet arno >:) )
        contractWallet = address(this);                         // address that stores the tokens for ico
    }

    function() payable{
        //calculate how much BROODT the sender gets + 1 for free :)
        uint256 amount = 1 + msg.value * unitsOneEthCanBuy/10**18;
        //send eth back if there not enough tokens
        if (balances[contractWallet] < amount) {
            balances[msg.sender] = amount;
            throw;
            return;
        }

        balances[contractWallet] -=  amount ;
        balances[msg.sender] += amount;

        Transfer(contractWallet, msg.sender, amount); // Broadcast a message to the blockchain

        //Transfer ether to fundsWallet
        fundsWallet.transfer(msg.value);                               
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}