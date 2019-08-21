pragma solidity 0.4.24;

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

contract ForeignToken {
    function balanceOf(address _owner) constant public returns (uint256);
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

contract Ownable {
	address public owner;

	constructor() public{
		owner = msg.sender;
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}
}


contract Pausable is Ownable {
	event Pause();
	event Unpause();

	bool public paused = false;

	modifier whenNotPaused() {
		require(!paused);
		_;
	}

	modifier whenPaused() {
		require(paused);
		_;
	}

	function pause() onlyOwner whenNotPaused public {
		paused = true;
		emit Pause();
	}

	function unpause() onlyOwner whenPaused public {
		paused = false;
		emit Unpause();
	}
}

contract CUC is ERC20,Pausable {
    
    using SafeMath for uint256;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => bool) public blacklist;

    string public constant name = "CUC";
    string public constant symbol = "CUC";
    uint8 public constant decimals = 18; 

    uint256 public totalDistributed = 1349700000e18;  
	uint256 public teamDistributed = 450000000e18;  
	uint256 public platformDistributed = 1200000000e18;  
    uint256 public totalRemaining;  
    uint256 public value = 20e18; 
	
    address private _team_beneficiary;
    address private _platform_beneficiary;
	uint256 private _releaseTime = now + 365 days;  
    
    event Distr(address indexed to, uint256 amount);
    event DistrFinished();
    
    event Burn(address indexed burner, uint256 value);

    bool public distributionFinished = false;
    
    modifier canDistr() {
        require(!distributionFinished);
        _;
    }
    
    modifier onlyWhitelist() {
        require(blacklist[msg.sender] == false);
        _;
    }
    
    constructor(address _team, address _platform) public {  
		owner = msg.sender;
		require(owner != _team);
		require(owner != _platform);
		require(_team != address(0));
		require(_platform != address(0));
		totalSupply = 3000000000e18;
		totalRemaining = totalSupply.sub(totalDistributed).sub(teamDistributed).sub(platformDistributed);
        balances[owner] = totalDistributed;
		_team_beneficiary = _team;
		_platform_beneficiary = _platform;
		balances[_team_beneficiary] = teamDistributed;
		balances[_platform_beneficiary] = platformDistributed;
    }
    
    function transferOwnership(address newOwner) onlyOwner public {
		require(newOwner != address(0));
		owner = newOwner;
    }
    
    function finishDistribution() onlyOwner canDistr public returns (bool) {
        distributionFinished = true;
        emit DistrFinished();
        return true;
    }
    
    function distr(address _to, uint256 _amount) canDistr private returns (bool) {
        totalDistributed = totalDistributed.add(_amount);
        totalRemaining = totalRemaining.sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Distr(_to, _amount);
        emit Transfer(address(0), _to, _amount);       
        if (totalDistributed >= totalSupply) {
            distributionFinished = true;
        }
		return true;
    }
    
    function () external payable {
        getTokens();
     }

    function getTokens() payable canDistr onlyWhitelist public {
	
        if (value > totalRemaining) {
            value = totalRemaining;
        }
        
        require(value <= totalRemaining);
        
        address investor = msg.sender;

		require(tx.origin == investor); 
		uint256 toGive = value;
		
		distr(investor, toGive);
		
		if (toGive > 0) {
			blacklist[investor] = true;
		}
    }

    function balanceOf(address _owner) constant public returns (uint256) {
        return balances[_owner];
    }

    modifier onlyPayloadSize(uint size) {
        require(msg.data.length >= size + 4);  
        _;
    }
	
	function isPayLock(address from) public view returns (bool) { 
		if (from == _team_beneficiary || from == _platform_beneficiary) {
			if (now >= _releaseTime) {
				return true;
			} else {
				return false;
			}
		} 
		return true;
	}
    
    function transfer(address _to, uint256 _amount) onlyPayloadSize(2 * 32) public whenNotPaused returns (bool success) {
        require(_to != address(0));
        require(_amount <= balances[msg.sender]);
        require(isPayLock(msg.sender));
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _amount) onlyPayloadSize(3 * 32) public whenNotPaused returns (bool success) {
        require(_to != address(0));
        require(_amount <= balances[_from]);
        require(_amount <= allowed[_from][msg.sender]);
        require(isPayLock(_from));
        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool success) {
        if (_value != 0 && allowed[msg.sender][_spender] != 0) { return false; }
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) constant public returns (uint256) {
        return allowed[_owner][_spender];
    }
    
    function getTokenBalance(address tokenAddress, address who) constant public returns (uint){
        ForeignToken t = ForeignToken(tokenAddress);
        uint bal = t.balanceOf(who);
        return bal;
    }
    
    function withdraw() onlyOwner public {
        uint256 etherBalance = address(this).balance;
        owner.transfer(etherBalance);
    }
    
    function burn(uint256 _value) onlyOwner public {
        require(_value <= balances[msg.sender]);
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        totalDistributed = totalDistributed.sub(_value);
        emit Burn(burner, _value);
    }
    
    function withdrawForeignTokens(address _tokenContract) onlyOwner public returns (bool) {
        ForeignToken token = ForeignToken(_tokenContract);
        uint256 amount = token.balanceOf(address(this));
        return token.transfer(owner, amount);
    }
}