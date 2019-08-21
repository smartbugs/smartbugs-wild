pragma solidity ^0.4.16;


library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
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

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract frozen is owned {

    mapping (address => bool) public frozenAccount;
    event FrozenFunds(address target, bool frozen);
    
    modifier isFrozen(address _target) {
        require(!frozenAccount[_target]);
        _;
    }

    function freezeAccount(address _target, bool _freeze) public onlyOwner {
        frozenAccount[_target] = _freeze;
        emit FrozenFunds(_target, _freeze);
    }
}


contract DDP is frozen{
    
    using SafeMath for uint256;
    uint256 private constant LOCK_PERCENT= 100; 
    uint256 private constant UN_FREEZE_CYCLE = 30 days;
    uint256 private constant EVERY_RELEASE_COUNT = 10;
    uint256 private constant INT100 = 100;
    
    
    string public name;
    string public symbol;
    uint8 public decimals = 8;  
    uint256 public totalSupply;
   
    
    uint256 private startLockTime;
    
    mapping (address => uint256) public balanceOf;
    mapping(address => uint256) freezeBalance;
    mapping(address => uint256) public preTotalTokens;

    event Transfer(address indexed from, address indexed to, uint256 value);

    function DDP() public {
        totalSupply = 2100000000 * 10 ** uint256(decimals);  
        balanceOf[msg.sender] = totalSupply;                
        name = "Distributed Diversion Paradise";                                   
        symbol = "DDP";                               
    }

    function transfer(address _to, uint256 _value) public returns (bool){
        _transfer(msg.sender, _to, _value);
        return true;
    }
    
    function _transfer(address _from, address _to, uint _value) internal isFrozen(_from) isFrozen(_to){
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to]+ _value > balanceOf[_to]);
        if(freezeBalance[_from] > 0){
            require(now > startLockTime);
            uint256 percent = (now - startLockTime) / UN_FREEZE_CYCLE * EVERY_RELEASE_COUNT;
            if(percent <= LOCK_PERCENT){
                freezeBalance[_from] = preTotalTokens[_from] * (LOCK_PERCENT - percent) / INT100;
                require (_value <= balanceOf[_from] - freezeBalance[_from]); 
            }else{
                freezeBalance[_from] = 0;
            }
        } 
        balanceOf[_from] = balanceOf[_from] - _value;
        balanceOf[_to] = balanceOf[_to] + _value;
        emit Transfer(_from, _to, _value);
    }

    function lock(address _to, uint256 _value) public onlyOwner isFrozen(_to){
        _value = _value.mul(10 ** uint256(decimals));
		require(balanceOf[owner] >= _value);
		require (balanceOf[_to].add(_value)> balanceOf[_to]); 
		require (_to != 0x0);
        balanceOf[owner] = balanceOf[owner].sub(_value);
        balanceOf[ _to] =balanceOf[_to].add(_value);
        preTotalTokens[_to] = preTotalTokens[_to].add(_value);
        freezeBalance[_to] = preTotalTokens[_to].mul(LOCK_PERCENT).div(INT100);
	    emit Transfer(owner, _to, _value);
    }
    
    function transfers(address[] _dests, uint256[] _values) onlyOwner public {
        uint256 i = 0;
        while (i < _dests.length) {
            transfer(_dests[i], _values[i]);
            i += 1;
        }
    }
   
    function locks(address[] _dests, uint256[] _values) onlyOwner public {
        uint256 i = 0;
        while (i < _dests.length) {
            lock(_dests[i], _values[i]);
            i += 1;
        }
    }
    
    function setStartLockTime(uint256 _time) external onlyOwner{
        startLockTime = _time;
    }
    
    function releaseCount() public view returns(uint256) {
        if(startLockTime == 0 || startLockTime > now){
            return 0;
        }
        uint256 percent = now.sub(startLockTime).div(UN_FREEZE_CYCLE).add(1);
        if(percent < INT100.div(EVERY_RELEASE_COUNT)){
            return percent;
        }else{
            return INT100.div(EVERY_RELEASE_COUNT);
        }
        
    }

}