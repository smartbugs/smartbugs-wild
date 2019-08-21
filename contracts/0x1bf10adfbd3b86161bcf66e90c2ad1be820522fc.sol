pragma solidity 0.4.18;

// implement safemath as a library
library SafeMath {

  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    require(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}

// Used for function invoke restriction
contract Administration {

    address     public owner; // temporary address
    
    mapping (address => bool) public moderators;

    event AddMod(address indexed _invoker, address indexed _newMod, bool indexed _modAdded);
    event RemoveMod(address indexed _invoker, address indexed _removeMod, bool indexed _modRemoved);

    function Administration() {
        owner = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == owner || moderators[msg.sender] == true);
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _; // function code inserted here
    }

    function transferOwnership(address _newOwner) onlyOwner returns (bool success) {
        owner = _newOwner;
        return true;
        
    }

    function addModerator(address _newMod) onlyOwner returns (bool added) {
        require(_newMod != address(0x0));
        moderators[_newMod] = true;
        AddMod(msg.sender, _newMod, true);
        return true;
    }
    
    function removeModerator(address _removeMod) onlyOwner returns (bool removed) {
        require(_removeMod != address(0x0));
        moderators[_removeMod] = false;
        RemoveMod(msg.sender, _removeMod, true);
        return true;
    }

}

contract TokenDraft is Administration {
    using SafeMath for uint256;

    uint256 public totalSupply;
    uint8   public decimals;
    string  public symbol;
    string  public name;

    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    
    event Transfer(address indexed _sender, address indexed _recipient, uint256 indexed _amount);
    event Approval(address indexed _owner, address indexed _spender, uint256 indexed _allowance);
    event BurnTokens(address indexed _burner, uint256 indexed _amountBurned, bool indexed _burned);

    function TokenDraft() {
        // 500 million in wei
        totalSupply = 500000000000000000000000000;
        decimals = 18;
        name = "TokenDraft";
        symbol = "FAN";
        balances[owner] = totalSupply;
    }

    function tokenBurn(uint256 _amountBurn)
        onlyAdmin
        returns (bool burned)
    {
        require(_amountBurn > 0);
        require(balances[msg.sender] >= _amountBurn);
        require(totalSupply.sub(_amountBurn) >= 0);
        balances[msg.sender] = balances[msg.sender].sub(_amountBurn);
        totalSupply = totalSupply.sub(_amountBurn);
        BurnTokens(msg.sender, _amountBurn, true);
        Transfer(msg.sender, 0, _amountBurn);
        return true;
    }

    function transferCheck(address _sender, address _recipient, uint256 _amount)
        private
        constant
        returns (bool valid)
    {
        require(_amount > 0);
        require(_recipient != address(0x0));
        require(balances[_sender] >= _amount);
        require(balances[_sender].sub(_amount) >= 0);
        require(balances[_recipient].add(_amount) > balances[_recipient]);
        return true;
    }

    function transfer(address _recipient, uint256 _amount)
        public
        returns (bool transferred)
    {
        require(transferCheck(msg.sender, _recipient, _amount));
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_recipient] = balances[_recipient].add(_amount);
        Transfer(msg.sender, _recipient, _amount);
        return true;
    }

    function transferFrom(address _owner, address _recipient, uint256 _amount)
        public
        returns (bool transferredFrom)
    {
        require(allowed[_owner][msg.sender] >= _amount);
        require(transferCheck(_owner, _recipient, _amount));
        require(allowed[_owner][msg.sender].sub(_amount) >= 0);
        allowed[_owner][msg.sender] = allowed[_owner][msg.sender].sub(_amount);
        balances[_owner] = balances[_owner].sub(_amount);
        balances[_recipient] = balances[_recipient].add(_amount);
        Transfer(_owner, _recipient, _amount);
        return true;
    }

    function approve(address _spender, uint256 _allowance)
        public
        returns (bool approved)
    {
        require(_allowance > 0);
        allowed[msg.sender][_spender] = _allowance;
        Approval(msg.sender, _spender, _allowance);
        return true;
    }

    //GETTERS//

    function balanceOf(address _tokenHolder)
        public
        constant
        returns (uint256 _balance)
    {
        return balances[_tokenHolder];
    }

    function allowance(address _owner, address _spender)
        public
        constant
        returns (uint256 _allowance)
    {
        return allowed[_owner][_spender];
    }

    function totalSupply()
        public
        constant
        returns (uint256 _totalSupply)
    {
        return totalSupply;
    }
}