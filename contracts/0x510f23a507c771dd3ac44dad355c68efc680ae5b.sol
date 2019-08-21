// INTERFACE FOR TOKEN
contract ERC20Interface {
    function totalSupply() public constant returns (uint256 totalSupply) {}
    function balanceOf(address _owner) public constant returns (uint256 balance) {}
    function transfer(address _to, uint256 _amount) public returns (bool success) {}
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {}
    function approve(address _spender, uint256 _amount) public returns (bool success) {}
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {}
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

///////////////////////////////////
//                               //
//        FORTUNITY PRESALE      //
//                               //
///////////////////////////////////

contract FortunityPresale is ERC20Interface {
    string public constant symbol = "FTPS";
    string public constant name = "FORTUNITY PRESALE";
    uint8 public constant decimals = 18;
    uint256 _totalSupply = 1000000000000000000000000;
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    
    address public owner;
    
    //CONSTRUCTOR
    function FortunityPresale() public {
        owner               = msg.sender;
        balances[owner]     = _totalSupply;
    }
    
    //WHEN ETH IS RECEIVED DIRECTLY
    function() payable {
        owner.transfer(this.balance);
    }
    

    // Get total supply
    function totalSupply() public constant returns (uint256 totalSupply) {
        totalSupply = _totalSupply;
    }
  
    // What is the balance of a particular account?
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }
  
    // Transfer the balance from owner's account to another account
    function transfer(address _to, uint256 _amount) public returns (bool success) {
        if (balances[msg.sender] >= _amount 
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
  
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) {
        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount
            && _amount > 0
            && balances[_to] + _amount > balances[_to]) {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
    
    function approve(address _spender, uint256 _amount) public returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
    
 
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}