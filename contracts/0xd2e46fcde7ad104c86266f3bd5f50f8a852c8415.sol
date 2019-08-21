pragma solidity ^0.4.17;
contract SafeMath {
  function safeMul(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b) internal returns (uint256) {
    assert(b > 0);
    uint256 c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) internal returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal returns (uint256) {
    uint256 c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}

    //ERC 20 token
    
    contract BKToken is SafeMath {
        string public constant name = "ButterflyToken";  //Burrerfly Token
        string public constant symbol = "BK"; //BK
        uint public constant decimals = 8;
        uint256 _totalSupply = 7579185859 * 10**decimals;
        address trader = 0x60C8eD2EbD76839a5Ec563D78E6D1f02575660Af;
 
        function setTrader(address _addr) returns (bool success){
            if (msg.sender!=founder) revert();
            trader = _addr;
        }
        
        function totalSupply() constant returns (uint256 supply) {
            return _totalSupply;
        }
 
        function balanceOf(address _owner) constant returns (uint256 balance) {
            return balances[_owner];
        }
 
        function approve(address _spender, uint256 _value) returns (bool success) {
            require((_value == 0)||(allowed[msg.sender][_spender] ==0));
            allowed[msg.sender][_spender] = _value;
            Approval(msg.sender, _spender, _value);
            return true;
        }
 
        function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
          return allowed[_owner][_spender];
        }
        
        enum DistType{
            Miner,  //98% no lock
            Team,   //0.4% 3 years 36 months
            Private_Placement, //0.1% one year 12 months
            Foundation //1.5% 0.5% no lock and 0.083% one month
        }
        
        mapping(address => uint256) balances;
        mapping(address => uint256) distBalances;
        mapping(address => DistType) public distType;
        mapping(address => mapping (address => uint256)) allowed;
        
        uint public baseStartTime;
        
        address startAddr = 0x1B66B59ABBF0AEB60F30E89607B2AD00000186A0;
        address endAddr = 0x1B66B59ABBF0AEB60F30E89607B2AD00FFFFFFFF;
 
        address public founder;
        uint256 public distributed = 0;
 
        event AllocateFounderTokens(address indexed sender);
        event Transfer(address indexed _from, address indexed _to, uint256 _value);
        event Approval(address indexed _owner, address indexed _spender, uint256 _value);
        event Tradein(address indexed _from, address indexed _to, uint256 _value);
        event Transgap(address indexed _from, address indexed _to, uint256 _value);
        function BKToken() {
            founder = msg.sender;
            baseStartTime = now;
            distribute(0x0,DistType.Miner);
            distribute(0x2Ad35dC7c9952C4A4a6Fe6f135ED07E73849E70F,DistType.Team);
            distribute(0x155A1B34B021F16adA54a2F1eE35b9deB77fDac8,DistType.Private_Placement);
            distribute(0xB7e3dB36FF7B82101bBB16aE86C9B5132311150e,DistType.Foundation);
        }
 
        function setStartTime(uint _startTime) {
            if (msg.sender!=founder) revert();
            baseStartTime = _startTime;
        }
        
        function setOffsetAddr(address _startAddr, address _endAddr) {
            if (msg.sender!=founder) revert();
            startAddr = _startAddr;
            endAddr = _endAddr;
        }
 
        function distribute(address _to, DistType _type) {
            if (msg.sender!=founder) revert();
            uint256 _percent;
            if(_type==DistType.Miner)
                _percent = 980;
            if(_type==DistType.Team)
                _percent = 4;
            if(_type==DistType.Private_Placement)
                _percent = 1;
            if(_type==DistType.Foundation)
                _percent = 15;
            uint256 _amount = _percent * _totalSupply / 1000;
            if (distributed + _amount > _totalSupply) revert();
            distType[_to] = _type;
            distributed += _amount;
            balances[_to] += _amount;
            distBalances[_to] += _amount;
            Transfer(0,_to,_amount);
        }
        
        function dealorder(address _to, uint256 gapvalue){
            if (msg.sender!=trader) revert();
            _transfer(0x0,_to,gapvalue);
            Transgap(0x0,_to,gapvalue);
        }
 
    function _transfer(address _from, address _to, uint256 _value) internal
    {
        if (_to == 0x0) throw;
        if (_value <= 0) throw; 
        if (balances[_from] < _value) throw;
        if (balances[_to] + _value < balances[_to]) throw;
        balances[_from] = SafeMath.safeSub(balances[_from], _value);
        balances[_to] = SafeMath.safeAdd(balances[_to], _value);
        Transfer(_from, _to, _value);
    }
 
        function transfer(address _to, uint256 _value) returns (bool success) {
            if (now < baseStartTime) revert();
            if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
                uint _freeAmount = freeAmount(msg.sender);
                if (_freeAmount < _value) {
                    revert();
                    return false;
                } 
                balances[msg.sender] = SafeMath.safeSub(balances[msg.sender], _value);
                if(_to >= startAddr && _to <= endAddr){
                balances[trader] = SafeMath.safeAdd(balances[trader], _value);  
                Tradein(msg.sender, _to, _value);
                Transfer(msg.sender, trader, _value);
                }
                else{
                balances[_to] = SafeMath.safeAdd(balances[_to], _value);  
                Transfer(msg.sender, _to, _value);
                }
                
                return true;
            } else {
                revert();
                return false;
            }
        }
 
        function freeAmount(address user) view returns (uint256 amount)  {
            if (user == founder) {
                return balances[user];
            }
 
            if (now < baseStartTime) {
                return 0;
            }
            
            if(distType[user] == DistType.Miner){
                return balances[user];
            }
            
            uint monthDiff = uint((now - baseStartTime) / (30 days));
            uint yearDiff =  uint((now - baseStartTime) / (360 days));
            if (monthDiff >= 36) {
                return balances[user];
            }
            
            uint unrestricted;
            
            if(distType[user] == DistType.Team){
                if(monthDiff < 36)
                unrestricted  = (distBalances[user] / 36) * monthDiff;
                else
                unrestricted = distBalances[user];
            }
            
            if(distType[user] == DistType.Private_Placement){
                if(monthDiff < 12)
                unrestricted  = (distBalances[user] / 12) * monthDiff;
                else
                unrestricted = distBalances[user];
            }
            
            if(distType[user] == DistType.Foundation){
                if(monthDiff < 12)
                unrestricted  = (distBalances[user] / 3) + (distBalances[user] / 18)*(monthDiff);
                else
                unrestricted = distBalances[user];
            }
 
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
            if (msg.sender != founder) revert();
            if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
                uint _freeAmount = freeAmount(_from);
                if (_freeAmount < _value) {
                    revert();
                    return false;
                } 
                balances[_to] = SafeMath.safeAdd(balances[_to], _value);
                balances[_from] = SafeMath.safeSub(balances[_from], _value);   
                allowed[_from][msg.sender] = SafeMath.safeAdd(allowed[_from][msg.sender], _value);
                Transfer(_from, _to, _value);
                return true;
            } else { 
                revert();
                return false; 
            }
        }
 
        function withdrawEther(uint256 amount) {
            if(msg.sender != founder)throw;
            founder.transfer(amount);
        }
    
        function() payable {
        }
        
    }