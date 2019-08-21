pragma solidity ^0.4.25;
    contract TMBToken  {
        string public constant name = "TimeBankToken";
        string public constant symbol = "TMB";
        uint public constant decimals = 18;
        uint256 _totalSupply = 1e9 * (10 ** uint256(decimals)); 
        uint public baseStartTime;
        uint256 public distributed = 0;
        mapping (address => bool) public freezed;
        mapping(address => uint256) balances;       
        mapping(address => uint256) distBalances;   
        mapping(address => mapping (address => uint256)) allowed;
        address public founder;
        event AllocateFounderTokens(address indexed sender);
        event Transfer(address indexed _from, address indexed _to, uint256 _value);
        event Approval(address indexed _owner, address indexed _spender, uint256 _value);
        event Burn(address indexed fromAddr, uint256 value);
     
        function TMBToken() {
            founder = msg.sender;
        }
         function totalSupply() constant returns (uint256 supply) {
            return _totalSupply;
        }
 
        function balanceOf(address _owner) constant returns (uint256 balance) {
            return balances[_owner];
        }
 
        function approve(address _spender, uint256 _value) returns (bool success) {
            allowed[msg.sender][_spender] = _value;
            Approval(msg.sender, _spender, _value);
            return true;
        }
 
        function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
          return allowed[_owner][_spender];
        }
        function setStartTime(uint _startTime) {
            if (msg.sender!=founder) revert();
            baseStartTime = _startTime;
        }
 
       
        function distribute(uint256 _amount, address _to) {
            if (msg.sender!=founder) revert();
            if (distributed + _amount > _totalSupply) revert();
            if (freezed[_to]) revert();
            distributed += _amount;
            balances[_to] += _amount;
            distBalances[_to] += _amount;
        }
 
      
        function transfer(address _to, uint256 _value) returns (bool success) {
            if (now < baseStartTime) revert();
            if (freezed[msg.sender]) revert();
            if (freezed[_to]) revert();
            
            
            
            if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
                uint _freeAmount = freeAmount(msg.sender);
                if (_freeAmount < _value) {
                    return false;
                } 
 
                balances[msg.sender] -= _value;
                balances[_to] += _value;
                Transfer(msg.sender, _to, _value);
                return true;
            } else {
                return false;
            }
        }
        
        function addTokenTotal(uint256 _addAmount) public returns (bool success){
    require(msg.sender == founder);                        
    require(_addAmount > 0);                             
        
    _totalSupply += _addAmount * 10 ** decimals;           
    balances[msg.sender] += _addAmount * 10 ** decimals;  
    return true;
}  
    function unFreezenAccount(address _freezen) public returns (bool success) {
        require(msg.sender == founder);       
        
        freezed[_freezen] = false;
        return true;
    }
    
    function burn(uint256 _value) public returns (bool success) {
        require(msg.sender == founder);                  
        require(balances[msg.sender] >= _value);      
        balances[msg.sender] -= _value;
        _totalSupply -= _value;
        Burn(msg.sender, _value);
        return true;
    }
    
   
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(msg.sender == founder);                  
        require(balances[_from] >= _value);            
        require(_value <= allowed[_from][msg.sender]);  
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        _totalSupply -= _value;
        Burn(_from, _value);
        return true;
    }

   

  function freezenAccount(address _freezen) public returns (bool success) {
        require(msg.sender == founder);      
        require(_freezen != founder);         
    
        freezed[_freezen] = true;
        return true;
    }

        function freeAmount(address user) returns (uint256 amount) {
           
            if (user == founder) {
                return balances[user];
            }

            if (now < baseStartTime) {
                return 0;
            }
 
         
            uint monthDiff = (now - baseStartTime) / (30 days);
 
           
            if (monthDiff > 5) {
                return balances[user];
            }
 
           
            uint unrestricted = distBalances[user] / 10 + distBalances[user] * 20 / 100 * monthDiff;
            if (unrestricted > distBalances[user]) {
                unrestricted = distBalances[user];
            }
 
           
            if (unrestricted + balances[user] < distBalances[user]) {
                amount = 0;
            } else {
                amount = unrestricted + (balances[user] - distBalances[user]);
            }
 
            return amount;
        }
 
       
        function changeFounder(address newFounder) {
            if (msg.sender!=founder) revert();
            founder = newFounder;
        }
 
        
        function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
            require(_to != address(0));
            if (freezed[_from]) revert();
            if (freezed[_to]) revert();
            
            if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
                uint _freeAmount = freeAmount(_from);
                if (_freeAmount < _value) {
                    return false;
                } 
 
                balances[_to] += _value;
                balances[_from] -= _value;
                allowed[_from][msg.sender] -= _value;
                Transfer(_from, _to, _value);
                return true;
            } else { return false; }
        }
        function kill() public {
        require(msg.sender == founder);
        selfdestruct(founder);
        }

        function() payable {
            if (!founder.call.value(msg.value)()) revert(); 
        }
    }