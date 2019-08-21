pragma solidity ^0.4.25;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract IPCoin is ERC20 {
    
    using SafeMath for uint256; 
    address owner = msg.sender; 

    mapping (address => uint256) balances; 
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => uint256) times;//投放次数T
    mapping (address => mapping (uint256 => uint256)) dorpnum;//对应T序号的投放数目
    mapping (address => mapping (uint256 => uint256)) dorptime;//对应T序号的投放时间戳
    mapping (address => mapping (uint256 => uint256)) freeday;//对应T序号的冻结时间
    mapping (address => mapping (uint256 => bool)) unlock;//对应T序号的解锁
    
    mapping (address => bool) public frozenAccount;
    mapping (address => bool) public airlist;

    string public constant name = "IPCoin";
    string public constant symbol = "IPC";
    uint public constant decimals = 8;
    uint256 _Rate = 10 ** decimals; 
    uint256 public totalSupply = 2000000000 * _Rate;

//    uint256 public totalDistributed = 0;
//    uint256 public totalRemaining = totalSupply.sub(totalDistributed);
    uint256 public _value;
    uint256 public _per = 1;
    uint256 public _freeday = 90;
    bool public distributionClosed = true;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event FrozenFunds(address target, bool frozen);
    event Distr(address indexed to, uint256 amount);
    event DistrClosed(bool Closed);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyPayloadSize(uint size) {
        assert(msg.data.length >= size + 4);
        _;
    }

     function IPCoin () public {
        owner = msg.sender;
        balances[owner] = totalSupply;
        _value = 200 * _Rate;
    }
     function nowInSeconds() constant public returns (uint256){
        return now;
    }
    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner != address(0) && newOwner != owner) {
             owner = newOwner; 
        }
    }

    function closeDistribution(bool Closed) onlyOwner public returns (bool) {
        distributionClosed = Closed;
        emit DistrClosed(Closed);
        return true;
    }

   function Set_distr(uint256 per,uint256 freeday,uint256 value) onlyOwner public returns (bool) {
   require(per <= 100 && per >= 1);
   require(value <= 2000000000 && value >= 0);
        _freeday = freeday;
        _per  = per;
        _value = value * _Rate;
        return true;
    }

    function distr(address _to, uint256 _amount, bool _unlock) private returns (bool) {
         if (_amount > balances[owner]) {
            _amount = balances[owner];
        }
//        totalDistributed = totalDistributed.add(_amount);
        balances[owner] = balances[owner].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        times[_to] += 1;
        dorptime[_to][times[_to]] = now;
        freeday[_to][times[_to]] = _freeday * 1 days;
        dorpnum[_to][times[_to]] = _amount;
        unlock[_to][times[_to]] = _unlock;
        if (balances[owner] == 0) {
            distributionClosed = true;
        }        
        emit Distr(_to, _amount);
//        Transfer(owner, _to, _amount);
        return true;
        

    }
 

    function distribute(address[] addresses, uint256[] amounts, bool _unlock) onlyOwner public {

        require(addresses.length <= 255);
        require(addresses.length == amounts.length);
        
        for (uint8 i = 0; i < addresses.length; i++) {
            require(amounts[i] * _Rate <= balances[owner]);
            distr(addresses[i], amounts[i] * _Rate, _unlock);
        }
    }

    function () external payable {
            getTokens();
     }

    function getTokens() payable public {
        if(!distributionClosed){
        address investor = msg.sender;
        uint256 toGive = _value; 
        if (toGive > balances[owner]) {
            toGive = balances[owner];
        }
        
        if(!airlist[investor]){
//        totalDistributed = totalDistributed.add(toGive);
        balances[owner] = balances[owner].sub(toGive);
        balances[investor] = balances[investor].add(toGive);
        times[investor] += 1;
        dorptime[investor][times[investor]] = now;
        freeday[investor][times[investor]] = _freeday * 1 days;
        dorpnum[investor][times[investor]] = toGive;
        unlock[investor][times[investor]] = false;
        airlist[investor] = true;
        if (_value > balances[owner]) {
            distributionClosed = true;
        }        
        emit Distr(investor, toGive);
//        Transfer(address(0), investor, toGive);
        }
        }
    }
    function unlocked(address _owner) onlyOwner public returns (bool) {
    for (uint8 i = 1; i < times[_owner] + 1; i++){
        unlock[_owner][i] = true;
              }
	    return true;
    }
    //
    function freeze(address[] addresses,bool locked) onlyOwner public {
        
        require(addresses.length <= 255);
        
        for (uint i = 0; i < addresses.length; i++) {
            freezeAccount(addresses[i], locked);
        }
    }
    
    function freezeAccount(address target, bool B) private {
        frozenAccount[target] = B;
        emit FrozenFunds(target, B);
    }

    function balanceOf(address _owner) constant public returns (uint256) {
      if(!distributionClosed && !airlist[_owner] && _owner!=owner){
       return balances[_owner] + _value;
       }
	    return balances[_owner];
    }
//查询地址锁定币数
    function lockOf(address _owner) constant public returns (uint256) {
    uint locknum = 0;
    for (uint8 i = 1; i < times[_owner] + 1; i++){
        if(unlock[_owner][i]){
               locknum += 0;
              }
        else{
               
            if(now < dorptime[_owner][i] + freeday[_owner][i] + 1* 1 days){
            locknum += dorpnum[_owner][i];
            }
            else{
                if(now < dorptime[_owner][i] + freeday[_owner][i] + 100/_per* 1 days){
                locknum += ((now - dorptime[_owner][i] - freeday[_owner][i] )/(1 * 1 days)*dorpnum[_owner][i]*_per/100);
                }
                else{
                 locknum += 0;
                }
            }
        }
    }
	    return locknum;
    }

    function transfer(address _to, uint256 _amount) onlyPayloadSize(2 * 32) public returns (bool success) {

        require(_to != address(0));
        require(_amount <= (balances[msg.sender].sub(lockOf(msg.sender))));
        require(!frozenAccount[msg.sender]);                     
        require(!frozenAccount[_to]);                      
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }
  
    function transferFrom(address _from, address _to, uint256 _amount) onlyPayloadSize(3 * 32) public returns (bool success) {

        require(_to != address(0));
        require(_amount <= balances[_from]);
        require(_amount <= (allowed[_from][msg.sender].sub(lockOf(msg.sender))));

        
        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        if (_value != 0 && allowed[msg.sender][_spender] != 0) { return false; }
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant public returns (uint256) {
        return allowed[_owner][_spender];
    }

    function withdraw() onlyOwner public {
        uint256 etherBalance = this.balance;
        address owner = msg.sender;
        owner.transfer(etherBalance);
    }
}