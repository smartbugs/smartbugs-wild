pragma solidity ^0.4.11;

contract SafeMath {
    function safeMul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
    
    function safeSub(uint a, uint b) internal returns (uint) {
        assert(b <= a);
        return a - b;
    }
    
    function safeAdd(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }
    
    function assert(bool assertion) internal {
        if (!assertion) throw;
    }
}

contract ExploreCoin is SafeMath {
    string public symbol;
    string public name;
    uint public decimals;
    
    uint256 _rate;
    uint256 public tokenSold;
    uint oneMillion = 1000000;
    
    uint256 _totalSupply;
    address owner;
    bool preIco = true;
    
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

    function transferOwnership(address newOwner) onlyOwner {
        require(newOwner != 0x0);
        owner = newOwner;
    }

    function currentOwner() onlyOwner returns (address){
        return owner;
    }

    function endpreIco(bool status) onlyOwner {
        if(status){
            preIco = false;
        }
    }
 
    function tokenAvailable() constant returns (uint256 tokenAvailable) {        
        return safeSub(_totalSupply, tokenSold);
    }
 
    function totalSupply() constant returns (uint256 totalSupply) {        
        return _totalSupply;
    }
 
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
    
    function ExploreCoin(
        string tokenName,
        string tokenSymbol,
        uint decimalUnits,
        uint256 totalSupply,
        uint256 rate
    ) {
        _totalSupply = safeMul(totalSupply, safeMul(oneMillion, (10 ** decimalUnits) ));
        _rate = rate;
        name = tokenName;
        symbol = tokenSymbol;
        decimals = decimalUnits;
        owner = msg.sender;
        tokenSold = 0;
    }
    
    function () payable {
        if (!preIco) throw;
        uint256 token_amount = safeMul(msg.value, _rate);
        if(safeAdd(tokenSold, token_amount) > _totalSupply) throw;
        
        tokenSold = safeAdd(tokenSold, token_amount);
        balances[msg.sender] = safeAdd(balances[msg.sender], token_amount);
        owner.transfer(msg.value);
        Transfer(msg.sender, msg.sender, token_amount);
    }
 
    function transfer(address _to, uint256 _amount) onlyPayloadSize(2 * 32) returns (bool success) {
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
    ) onlyPayloadSize(2 * 32) returns (bool success) {
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
 
    function approve(address _spender, uint256 _amount) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }
 
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}