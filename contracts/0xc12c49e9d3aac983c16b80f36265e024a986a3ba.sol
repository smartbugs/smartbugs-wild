pragma solidity ^0.5.1;

contract Token {

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Transfer_data( address indexed _to, uint256 _value,string data);
    event data_Marketplace(string data);

    function transfer(address _to, uint256 _value) public returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            emit Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

   function transfer_data( address _to,uint256 _value,string memory data) public returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[fundsWallet] += _value;
            emit Transfer_data(_to, _value, data);
            return true;
        } else { return false; }
    }
    
     function marketplace( string memory data) public returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[msg.sender] >= 1 && 1 > 0) {
            balances[msg.sender] -= 1;
            balances[fundsWallet] += 1;
            emit data_Marketplace(data);
            return true;
        } else { return false; }
    }
    
     


    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
    
    function mybalance() public view returns (uint256 balance) {
        return balances[fundsWallet];
    }


    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;



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
    string public version = 'H1.0'; 
    uint256 public totalEthInWei;         // WEI is the smallest unit of ETH (the equivalent of cent in USD or satoshi in BTC). We'll store the total ETH raised via our ICO here.  
    address payable fundsWallet;           // Where should the raised ETH go?

    // This is a constructor function 
    // which means the following function name has to match the contract name declared above
    constructor () public {
        balances[msg.sender] = 1000000000000000000000;               // Give the creator all initial tokens. This is set to 1000 for example. If you want your initial tokens to be X and your decimal is 5, set this value to X * 100000. (CHANGE THIS)
        totalSupply = 1000000000000000000000;                        // Update total supply (1000 for example) (CHANGE THIS)
        name = "Kaus-0.0.1";                                   // Set the name for display purposes (CHANGE THIS)
        decimals = 0;                                               // Amount of decimals for display purposes (CHANGE THIS)
        symbol = "KAUS";                                             // Set the symbol for display purposes (CHANGE THIS)
        fundsWallet = msg.sender;                                    // The owner of the contract gets ETH
    }

   
    
}