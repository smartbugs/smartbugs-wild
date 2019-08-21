pragma solidity ^0.4;


contract ERC20 {
   uint public totalSupply;
   function balanceOf(address _account) public constant returns (uint balance);
   function transfer(address _to, uint _value) public returns (bool success);
   function transferFrom(address _from, address _to, uint _value) public returns (bool success);
   function approve(address _spender, uint _value) public returns (bool success);
   function allowance(address _owner, address _spender) public constant returns (uint remaining);
   event Transfer(address indexed _from, address indexed _to, uint _value);
   event Approval(address indexed _owner, address indexed _spender, uint _value);
}


contract Token is ERC20 {
    // Balances for trading
    mapping(address => uint256) public balances;


    mapping(address => uint256) public investBalances;

    mapping(address => mapping (address => uint)) allowed;

    // Total amount of supplied tokens
    uint256 public totalSupply;

    // Information about token
    string public constant name = "3D METAMORPHOSIS";
    string public constant symbol = "MMS";
    address public owner;
    address public owner2;
    uint8 public decimals = 6;

    // If function has this modifier, only owner can execute this function
    modifier onlyOwner() {
        require(msg.sender == owner || msg.sender == owner2);
        _;
    }




    function Token() public {
        owner = msg.sender;
        totalSupply = 1000000000000;
        balances[owner] = totalSupply;
    }

    // Change main owner address and transer tokens to new owner
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != owner);
        balances[newOwner] = balances[owner];
        balances[owner] = 0;
        owner = newOwner;
    }

    // Chech trade balance of account
    function balanceOf(address _account) public constant returns (uint256 balance) {
    return balances[_account];
    }

 // Transfer tokens from your account to other account
    function transfer(address _to, uint _value) public  returns (bool success) {
        require(_to != 0x0);                               // Prevent transfer to 0x0 address.
        require(balances[msg.sender] >= _value);           // Check if the sender has enough
        balances[msg.sender] -= _value;                    // Subtract from the sender
        balances[_to] += _value;                           // Add the same to the recipient
        Transfer(msg.sender, _to, _value);
    return true;
    }

   // Transfer tokens from account (_from) to another account (_to)
    function transferFrom(address _from, address _to, uint256 _amount) public  returns(bool) {
        require(_amount <= allowed[_from][msg.sender]);
        if (balances[_from] >= _amount && _amount > 0) {
            balances[_from] -= _amount;
            balances[_to] += _amount;
            allowed[_from][msg.sender] -= _amount;
            Transfer(_from, _to, _amount);
            return true;
        }
        else {
            return false;
            }
    }

    function approve(address _spender, uint _value) public  returns (bool success){
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
    return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
    return allowed[_owner][_spender];
    }

    function add_tokens(address _to, uint256 _amount) public onlyOwner {
        balances[owner] -= _amount;
        investBalances[_to] += _amount;
    }

    // Transfer tokens from investBalance to Balncec for trading
    function transferToken_toBalance(address _user, uint256 _amount) public onlyOwner {
        investBalances[_user] -= _amount;
        balances[_user] += _amount;
    } 

    // Transfer toknes from Balncec to investBalance
    function transferToken_toInvestBalance(address _user, uint256 _amount) public onlyOwner {
        balances[_user] -= _amount;
        investBalances[_user] += _amount;
    }  


    function addOwner2(address _owner2) public onlyOwner {
        owner2 = _owner2;
    }
}