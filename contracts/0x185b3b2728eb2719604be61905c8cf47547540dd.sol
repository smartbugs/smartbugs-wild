pragma solidity ^0.4.25;
    contract TMBToken  {
        string public constant name = "TimeBankToken";
        string public constant symbol = "TMB";
        uint public constant decimals = 18;
        uint256 _totalSupply = 1e9 * (10 ** uint256(decimals)); 
        uint public baseStartTime;
        mapping (address => bool) public freezed;
        mapping(address => uint256) balances;       
        mapping(address => uint256) distBalances;   
        mapping(address => mapping (address => uint256)) allowed;
        address public founder;
        mapping (address => bool) owners;
        event AddOwner(address indexed newOwner);
        event DeleteOwner(address indexed toDeleteOwner);
        event Transfer(address indexed _from, address indexed _to, uint256 _value);
        event Approval(address indexed _owner, address indexed _spender, uint256 _value);
        event Burn(address indexed fromAddr, uint256 value);
     
    function TMBToken() {
            founder = msg.sender;
            owners[founder] = true;
            balances[msg.sender] = _totalSupply;
            emit Transfer(0x0, msg.sender, _totalSupply);
        }

    modifier onlyFounder() {
        require(founder == msg.sender);
        _;
        }

        modifier onlyOwner() {
        require(owners[msg.sender]);
        _;
        }
    function addOwner(address owner) public onlyFounder returns (bool) {
             require(owner != address(0));
             owners[owner] = true;
             emit AddOwner(owner);
            return true;
        }

    function deleteOwner(address owner) public onlyFounder returns (bool) {
        
            require(owner != address(0));
            owners[owner] = false;
        
             emit DeleteOwner(owner);
        
             return true;
        }
    function chkOwner(address owner) public view returns (bool) {
             return owners[owner];
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
        
    function setStartTime(uint _startTime) public onlyFounder returns (bool){
            baseStartTime = _startTime;
        }
    function setDistBalances(address _owner) public onlyOwner returns (bool){
        require(_owner != address(0));
        require(!owners[_owner]);
        
        distBalances[_owner]=balances[_owner];
        
        return true;
    }
    
     function setPartialRelease(address _owner,uint256 _value) public onlyFounder returns (bool){
        require(_owner != address(0));
        require(!owners[_owner]);
        require(distBalances[_owner]>_value * 10 ** decimals);
        distBalances[_owner] -= _value * 10 ** decimals;
        return true;
    }
    
    function setAllRelease(address _owner) public onlyFounder returns (bool){
        require(_owner != address(0));
        require(!owners[_owner]);
        distBalances[_owner]=0;
        return true;
    }
    
    function getDistBalances(address _owner)public view returns (uint256){
        require(_owner != address(0));
        return  distBalances[_owner];
    }
    
    function transfer(address _to, uint256 _value) returns (bool success) {
        
        if (freezed[msg.sender]) revert();
        if (freezed[_to]) revert();
        
        if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
            if(distBalances[msg.sender] > 0){
            if (now < baseStartTime ) revert();
            uint _freeAmount = freeAmount(msg.sender);
            if (_freeAmount < _value) {
                return false;
            } 
            }
 
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }
        
    function addTokenTotal(uint256 _addAmount) public onlyFounder returns (bool){
    require(_addAmount > 0);                             
        
    _totalSupply += _addAmount * 10 ** decimals;           
    balances[msg.sender] += _addAmount * 10 ** decimals;  
    return true;
    }  
    function unFreezenAccount(address _freezen) public onlyFounder returns (bool){
        freezed[_freezen] = false;
        return true;
    }
    
    function burn(uint256 _value) public onlyFounder returns (bool){
        require(balances[msg.sender] >= _value);      
        balances[msg.sender] -= _value * 10 ** decimals;
        _totalSupply -= _value * 10 ** decimals;
        Burn(msg.sender, _value * 10 ** decimals);
        return true;
    }
    
   
    function burnFrom(address _from, uint256 _value) public onlyFounder returns (bool) {
        require(balances[_from] >= _value);            
        require(_value <= allowed[_from][msg.sender]);  
        balances[_from] -= _value * 10 ** decimals;
        allowed[_from][msg.sender] -= _value * 10 ** decimals;
        _totalSupply -= _value * 10 ** decimals;
        Burn(_from, _value * 10 ** decimals);
        return true;
    }

  function freezenAccount(address _freezen) public onlyOwner returns (bool) {
        require(!owners[_freezen]);         
    
        freezed[_freezen] = true;
        return true;
    }

    function freeAmount(address user) returns (uint256 amount) {
           
        if (owners[user]) {
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
        
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        require(_to != address(0));
        if (freezed[_from]) revert();
        if (freezed[_to]) revert();
            
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
             if(distBalances[msg.sender] > 0){
        uint _freeAmount = freeAmount(_from);
            if (_freeAmount < _value) {
                return false;
            } 
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