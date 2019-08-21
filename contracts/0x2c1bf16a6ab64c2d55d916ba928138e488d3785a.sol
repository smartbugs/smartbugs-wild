pragma solidity ^0.4.19;

contract Token {

    function totalSupply() public constant returns (uint256 supply) {}

    function balanceOf(address _owner) public constant returns (uint256 balance) {}

    function transfer(address _to, uint256 _value) public returns (bool success) {}


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {}


    function approve(address _spender, uint256 _value) public returns (bool success) {}


    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    
}

contract Owned{
    address public owner;
    function Owned(){
        owner = msg.sender;
    }
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public;}

contract StandardToken is Token {

    //Internal transfer, only can be called by this contract
    function _transfer(address _from, address _to,uint256 _value) internal {
        //prevent transfer to 0x0 address.
        require(_to != 0x0);
        //check if sender has enough tokens
        require(balances[_from] >= _value);
        //check for overflows
        require(balances[_to] + _value > balances[_to]);

        uint256 previousBalances = balances[_from]+balances[_to];
        //subtract value from sender
        balances[_from] -= _value;
        //add value to receiver
        balances[_to] += _value;
        Transfer(_from,_to,_value);
        //Assert are used for analysing statically if bugs resides
        assert(balances[_from] + balances[_to] == previousBalances);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        
        _transfer(msg.sender,_to,_value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        
        require(_value <= allowed[_from][msg.sender]);
        allowed[_from][msg.sender] -= _value;
        _transfer(_from,_to,_value);
        return true;
    }

    //Return balance of the owner
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    //Approve the spender ammount
    //set allowance for other address
    // allows _spender to spend no more than _value tokens on your behalf
    function approve(address _spender, uint256 _value) public returns (bool success) {
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

/**************************************/
/*INTRODUCING ADVANCE FUNCTIONALITIES*/
/*************************************/

contract XRTStandards is Owned,StandardToken
{

    //generate a public event on the blockchain

    function _transfer(address _from, address _to,uint256 _value) internal {
        //prevent transfer to 0x0 address.
        require(_to != 0x0);
        //check if sender has enough tokens
        require(balances[_from] >= _value);
        //check for overflows
        require(balances[_to] + _value > balances[_to]);
        //subtract value from sender
        balances[_from] -= _value;
        //add value to receiver
        balances[_to] += _value;
        Transfer(_from,_to,_value);
    }

}

contract XRTToken is XRTStandards {

    uint256 public initialSupply;
    string public name;                   // Token Name
    uint8 public decimals;                // How many decimals to show. To be standard complicant keep it 18
    string public symbol;                 // An identifier: eg SBX, XPR etc..
    string public version; 
    uint256 public unitsOneEthCanBuy;     // How many units of your coin can be bought by 1 ETH?
    uint256 public totalEthInWei;         // WEI is the smallest unit of ETH (the equivalent of cent in USD or satoshi in BTC). We'll store the total ETH raised via our ICO here.  
    address public fundsWallet;           // Where should the raised ETH go?

    // This is a constructor function 
    // which means the following function name has to match the contract name declared above
    function XRTToken(uint256 _initialSupply, string t_name, string t_symbol,string t_version, uint8 decimalsUnits,uint256 OneEthValue) public {
        initialSupply = _initialSupply;
        decimals = decimalsUnits;                                               // Amount of decimals for display purposes (CHANGE THIS)
        totalSupply = initialSupply*10**uint256(decimals);                        // Update total supply (1000 for example) (CHANGE THIS)
        balances[msg.sender] = totalSupply;               // Give the creator all initial tokens. This is set to 1000 for example. If you want your initial tokens to be X and your decimal is 5, set this value to X * 100000. (CHANGE THIS)
        name = t_name;                                   // Set the name for display purposes (CHANGE THIS)
        symbol = t_symbol;                                             // Set the symbol for display purposes (CHANGE THIS)
        unitsOneEthCanBuy = OneEthValue*10**uint256(decimals);                                    
        fundsWallet = msg.sender;
        version = t_version;                                  
    }

    function() payable{
        if (msg.value == 0) { return; }

        totalEthInWei = totalEthInWei + msg.value;
        uint256 amount = msg.value * unitsOneEthCanBuy;
        if (balances[fundsWallet] < amount) {
            return;
        }

        balances[fundsWallet] = balances[fundsWallet] - amount;
        balances[msg.sender] = balances[msg.sender] + amount;

        Transfer(fundsWallet, msg.sender, amount); // Broadcast a message to the blockchain

        //Transfer ether to fundsWallet
        fundsWallet.transfer(msg.value);                               
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        if(approve(_spender,_value)){
            require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
            return true;
        }    
    }
}