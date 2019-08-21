pragma solidity ^0.4.16;

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ForeignToken {
    function balanceOf(address _owner) public constant returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
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

contract EtherBall is ERC20 {
    
    using SafeMath for uint256;
    
    address owner = msg.sender;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    
    uint256 public totalSupply = 1000000e9;

    function name() public constant returns (string) { return "Etherball"; }
    function symbol() public constant returns (string) { return "EBYTE"; }
    function decimals() public constant returns (uint8) { return 9; }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event DistrFinished();

    bool public distributionFinished = false;

    modifier canDistr() {
        require(!distributionFinished);
        _;
    }

    function EtherBall() public {
        owner = msg.sender;
        balances[msg.sender] = totalSupply;
    }

    modifier onlyOwner { 
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }

    function getTokenBalance(address tokenAddress, address who) constant public returns (uint){
        ForeignToken t = ForeignToken(tokenAddress);
        uint bal = t.balanceOf(who);
        return bal;
    }
    
    function getEthBalance(address _addr) constant public returns(uint) {
        return _addr.balance;
    }

    function distributeEbyte(address[] addresses, address _tokenAddress, uint256 _value, uint256 _ebytebal, uint256 _ethbal) onlyOwner canDistr public {

        for (uint i = 0; i < addresses.length; i++) {
	     if (getEthBalance(addresses[i]) < _ethbal) {
 	         continue;
             }
	     if (getTokenBalance(_tokenAddress, addresses[i]) < _ebytebal) {
 	         continue;
             }
             balances[owner] = balances[owner].sub(_value);
             balances[addresses[i]] = balances[addresses[i]].add(_value);
             Transfer(owner, addresses[i], _value);
        }
    }

    function distributeEbyteForETH(address[] addresses, uint256 _value, uint256 _div, uint256 _ethbal) onlyOwner canDistr public {

        for (uint i = 0; i < addresses.length; i++) {
	     if (getEthBalance(addresses[i]) < _ethbal) {
 	         continue;
             }
             uint256 ethMulti = getEthBalance(addresses[i]).div(1000000000);
             uint256 toDistr = (_value.mul(ethMulti)).div(_div);
             balances[owner] = balances[owner].sub(toDistr);
             balances[addresses[i]] = balances[addresses[i]].add(toDistr);
             Transfer(owner, addresses[i], toDistr);
        }
    }
    
    function distributeEbyteForEBYTE(address[] addresses, address _tokenAddress, uint256 _ebytebal, uint256 _perc) onlyOwner canDistr public {

        for (uint i = 0; i < addresses.length; i++) {
	     if (getTokenBalance(_tokenAddress, addresses[i]) < _ebytebal) {
 	         continue;
             }
             uint256 toGive = (getTokenBalance(_tokenAddress, addresses[i]).div(100)).mul(_perc);
             balances[owner] = balances[owner].sub(toGive);
             balances[addresses[i]] = balances[addresses[i]].add(toGive);
             Transfer(owner, addresses[i], toGive);
        }
    }
    
    function distribution(address[] addresses, address _tokenAddress, uint256 _value, uint256 _ethbal, uint256 _ebytebal, uint256 _div, uint256 _perc) onlyOwner canDistr public {

        for (uint i = 0; i < addresses.length; i++) {
	      distributeEbyteForEBYTE(addresses, _tokenAddress, _ebytebal, _perc);
	      distributeEbyteForETH(addresses, _value, _div, _ethbal);
	      break;
        }
    }
    
    function balanceOf(address _owner) constant public returns (uint256) {
	 return balances[_owner];
    }

    // mitigates the ERC20 short address attack
    modifier onlyPayloadSize(uint size) {
        assert(msg.data.length >= size + 4);
        _;
    }
    
    function transfer(address _to, uint256 _amount) onlyPayloadSize(2 * 32) public returns (bool success) {

        require(_to != address(0));
        require(_amount <= balances[msg.sender]);
        
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(msg.sender, _to, _amount);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _amount) onlyPayloadSize(3 * 32) public returns (bool success) {

        require(_to != address(0));
        require(_amount <= balances[_from]);
        require(_amount <= allowed[_from][msg.sender]);
        
        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(_from, _to, _amount);
        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success) {
        // mitigates the ERC20 spend/approval race condition
        if (_value != 0 && allowed[msg.sender][_spender] != 0) { return false; }
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) constant public returns (uint256) {
        return allowed[_owner][_spender];
    }

    function finishDistribution() onlyOwner public returns (bool) {
    distributionFinished = true;
    DistrFinished();
    return true;
    }

    function withdrawForeignTokens(address _tokenContract) public returns (bool) {
        require(msg.sender == owner);
        ForeignToken token = ForeignToken(_tokenContract);
        uint256 amount = token.balanceOf(address(this));
        return token.transfer(owner, amount);
    }

}