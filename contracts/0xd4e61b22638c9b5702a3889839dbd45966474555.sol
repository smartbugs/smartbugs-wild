pragma solidity ^0.4.18;


contract rik {

    uint256 constant MAX_UINT256 = 2**256 - 1;
    uint256 constant MAX = 150000000000000000000000000;

    uint256 public cost = 2000000000000;
    
    uint256 _totalSupply = 500000000000000000000000;
    
        event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
 
    string public name = "Rik FIESTA!";
    uint8 public decimals = 18;
    string public symbol = "RIK";
    
 
  address public wallet = 0xe5f0c234DEb1C9C9f4f8d9Fd8ec7A0Cc5cED1cfa;
  
   function () external payable {
   
        require(msg.sender != address(0));
    
        uint256 amnt = (msg.value / cost) * 1000000000000000000;
    
        mint(msg.sender, amnt);
       
        if (2000000000000 * 2 **(_totalSupply / 1000000000000000000000000) > cost)
        {
            cost = 2000000000000 * 2 **(_totalSupply / 1000000000000000000000000);
        }
       
        // maybe event
    
        wallet.transfer(msg.value);
    }
    
    function rik() public {
        balances[msg.sender] = 500000000000000000000000;
    }
    
    
    function totalSupply() public constant returns (uint)
    {
        return _totalSupply;
    }
    
    function mint(address _to, uint256 _value) private returns (bool success) 
    {
        require((_totalSupply + _value) <= MAX);
        balances[_to] += _value;
       
        _totalSupply += _value;
        
        return true;
    }
   

    function transfer(address _to, uint256 _value) public returns (bool success) {

        require(balances[msg.sender] >= _value);
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
       
        uint256 allowance = allowed[_from][msg.sender];
        require(balances[_from] >= _value && allowance >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        if (allowance < MAX_UINT256) {
            allowed[_from][msg.sender] -= _value;
        }
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) view public returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) view public returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    

}