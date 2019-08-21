pragma solidity >=0.4.22 <0.6.0;
contract Token{
    uint256 public totalSupply;
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from,address _to,uint256 _value)public returns(bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns  (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256  _value);
    event Burn(address indexed from, uint256 value);
}

contract FSCToken is Token{
    string public chinaName;
    string public name;
    string public symbol;
    uint8 public decimals;
    address public owner;
    mapping(address=>uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    
    constructor(uint256 _initialAmount, string memory _tokenName,string memory _chinaName,uint8 _decimalUnits, string memory _tokenSymbol) public{
        totalSupply = _initialAmount * 10 ** uint256(_decimalUnits);
        balances[msg.sender] = totalSupply;
        name=_tokenName;
        decimals=_decimalUnits;
        symbol=_tokenSymbol;
        chinaName=_chinaName;
        owner=msg.sender;
    }
    
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != address(0x0));
        require(balances[_from] >= _value);
        require(balances[_to] + _value >= balances[_to]);
        uint previousBalances = balances[_from] + balances[_to];
        balances[_from] -= _value;
        balances[_to] += _value;
        emit Transfer(_from, _to, _value);
        assert(balances[_from] + balances[_to] == previousBalances);
    }    
    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowed[_from][msg.sender]);     
        allowed[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
    
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success)   
    { 
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }  
    
    function burn(uint256 _value) public returns (bool success) {
        require(msg.sender==owner);
        require(balances[msg.sender] >= _value);  
        balances[msg.sender] -= _value;            
        totalSupply -= _value;                      
        emit Burn(msg.sender, _value);
        return true;
    }    
    
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(msg.sender==owner);
        require(balances[_from] >= _value);                
        require(_value <= allowed[_from][msg.sender]);    
        balances[_from] -= _value;                        
        allowed[_from][msg.sender] -= _value;             
        totalSupply -= _value;                              
        emit Burn(_from, _value);
        return true;
    }
    
}