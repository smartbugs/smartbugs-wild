/************************************************************************************
This is the source code for the XGT token written in Solidity language.				*
This token is based on ERC20 specification 											*	
								*
Version 1.0																			*
									
Date: 13-Apr-2018																	*
************************************************************************************/


pragma solidity ^0.4.21;
contract Token {
    /// @return total amount of tokens
    function totalSupply() constant public returns (uint256 supply) {}
    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant public returns (uint256 balance) {}
    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success) {}
    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {}
    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success) {}
    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {}
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
contract StandardToken is Token {
    address public owner; //added for customization
	/************************************************************************************
	This function transfers the value specified in _value to the specified address _to.	
	************************************************************************************/
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (balances[msg.sender] >= _value && _value > 0 
			&& balances[_to] + _value > balances[_to]) {  // This condition is to avoid integer overflow - for customization
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            //Transfer(msg.sender, _to, _value);
            emit Transfer(msg.sender, _to, _value); //Above transfer call is deprecated for customization
            return true;
        } else { return false; }
    }
	/************************************************************************************
	This function transfers the value specified in _value from the address _from to 
	the specified address _to.	
	************************************************************************************/
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0 
			&& balances[_to] + _value > balances[_to]) {  // This condition is to avoid integer overflow - for customization
            balances[_to] += _value;  
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            //Transfer(_from, _to, _value);
            emit  Transfer(_from, _to, _value); //Above transfer call is deprecated for customization
            return true;
        } else { return false; }
    }
    //function balanceOf(address _owner) constant returns (uint256 balance) {
	function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }
    
    
    function totalSupply() constant public returns (uint256 supply) {
        return _totalSupply;
    }
    
    function approve(address _spender, uint256 _value) onlyOwner public returns (bool success) { //onlyOwner restrcts the token owner to make transactions -- for customization
        allowed[msg.sender][_spender] = _value;
        //Approval(msg.sender, _spender, _value);
        emit Approval(msg.sender, _spender, _value); // Above Approval function is deprecated. for customization
        return true;
    }
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
    
    /************************************************************************************
	This function will be called from Approve.
	************************************************************************************/
	modifier onlyOwner
	{
		require(msg.sender == owner);
		_;
	}
	
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    //uint256 public totalSupply;
	uint256  _totalSupply;
}
contract XGTToken is StandardToken { // XGTToken is the name of the contract to be deployed on the blockchain
    /* Public variables of the token */
    //string public name;                   // Token Name
	string public constant name="XGT";                   // Token Name
    //uint8 public decimals;                // How many decimals to show. To be standard complicant keep it 18
	uint8 public constant decimals=18;                // How many decimals to show. To be standard complicant keep it 18
    string public constant symbol="XGT";                 // An identifier: eg SBX, XPR etc..
    string public version = 'J1.0'; 
    uint256 public unitsOneEthCanBuy;     // How many units of your coin can be bought by 1 ETH?
    uint256 public totalEthInWei;         // WEI is the smallest unit of ETH (the equivalent of cent in USD or satoshi in BTC). We'll store the total ETH raised via our ICO here.  
    address public fundsWallet;           // Where should the raised ETH go?

    function XGTToken() public  {
        balances[msg.sender] 	= 150000000000000000000000000;        
        _totalSupply          	= 150000000000000000000000000;               
                                               
        unitsOneEthCanBuy = 180;                             
        fundsWallet = msg.sender;   
		owner = msg.sender; 
    }
    function() public payable{
        totalEthInWei = totalEthInWei + msg.value;
        uint256 amount = msg.value * unitsOneEthCanBuy;
        if (balances[fundsWallet] < amount) {
            return;
        }
        balances[fundsWallet] = balances[fundsWallet] - amount;
        balances[msg.sender] = balances[msg.sender] + amount;
        //Transfer(fundsWallet, msg.sender, amount); // Broadcast a message to the blockchain
        emit Transfer(fundsWallet, msg.sender, amount); // Broadcast a message to the blockchain
        //Transfer ether to fundsWallet
        fundsWallet.transfer(msg.value);                               
    }
    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        //Approval(msg.sender, _spender, _value);
        emit Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
	
}