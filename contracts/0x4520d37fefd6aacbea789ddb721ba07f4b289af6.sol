pragma solidity ^0.4.16;
contract SafeMath {
    function safeMul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        safeassert(a == 0 || c / a == b);
        return c;
    }
    
    function safeSub(uint a, uint b) internal returns (uint) {
        safeassert(b <= a);
        return a - b;
    }
    
    function safeAdd(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        safeassert(c>=a && c>=b);
        return c;
    }
    
    function safeassert(bool assertion) internal {
        require(assertion);
    }
}
contract COIN is SafeMath {
    string public symbol;
    string public name;
    uint256 public decimals;
    uint preicoEnd = 1517356799; // Pre ICO Expiry 30 Jan 2018 23:59:59
    
    uint256 rate;
    uint256 public tokenSold;
    uint256 _totalSupply;
    address public owner;
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;
    
    /**
    * @dev Fix for the ERC20 short address attack.
    */
    modifier onlyPayloadSize(uint size) {
        require(msg.data.length >= size + 4) ;
        _;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
      
    function transferOwnership(address __newOwner) public onlyOwner {
        require(__newOwner != 0x0);
        owner = __newOwner;
    }
    
    function totalSupply() constant returns (uint256) {
        return _totalSupply;
    }
 
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
    
    function COIN(
        string _name,
        uint256 _supply,
        uint256 _rate,
        string _symbol,
        uint256 _decimals
    ) {
        tokenSold = safeMul(2000000, (10 ** _decimals));
        _totalSupply = safeMul(_supply, safeMul(1000000, (10 ** _decimals)));
        name = _name;
        symbol = _symbol;
        rate = _rate;
        decimals = _decimals;
        owner = msg.sender;
        balances[msg.sender] = tokenSold;
        Transfer(address(this), msg.sender, tokenSold);
    }
    
    function () payable {
        require(preicoEnd > now);
        uint256 token_amount = safeMul(msg.value, rate);
        require(safeAdd(tokenSold, token_amount) <= _totalSupply);
        
        tokenSold = safeAdd(tokenSold, token_amount);
        balances[msg.sender] = safeAdd(balances[msg.sender], token_amount);
        owner.transfer(msg.value);
        Transfer(address(this), msg.sender, token_amount);
    }
 
    function transfer(address _to, uint256 _amount) onlyPayloadSize(2 * 32) public returns (bool success) {
        if (balances[msg.sender] >= _amount
            && _amount > 0
            && safeAdd(balances[_to], _amount) > balances[_to]) {
            balances[msg.sender] = safeSub(balances[msg.sender], _amount);
            balances[_to] = safeAdd(balances[_to], _amount);
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }
    
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) onlyPayloadSize(2 * 32) public returns (bool success) {
        if (balances[_from] >= _amount
        && allowed[_from][msg.sender] >= _amount
        && _amount > 0
        && safeAdd(balances[_to], _amount) > balances[_to]) {
            balances[_from] = safeSub(balances[_from], _amount);
            allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _amount);
            balances[_to] = safeAdd(balances[_to], _amount);
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
 
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}