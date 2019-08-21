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

contract CARLO is ERC20,Pausable {
    
    using SafeMath for uint256;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    mapping (address => bool) public blacklist;

    string public constant name = "CARLO";
    string public constant symbol = "CARLO";
    uint8 public constant decimals = 18; 

	uint256 public foundationDistributed = 100000000e18;
	uint256 public marketDistributed = 360000000e18;
	uint256 public devDistributed = 240000000e18;
	uint256 public labDistributed = 300000000e18;
	
	uint256 public devLockFirstDistributed = 300000000e18;
	uint256 public devLockSecondDistributed = 300000000e18;
	uint256 public devLockThirdDistributed = 400000000e18; 

    uint256 public totalRemaining; 
	
	address private devLockFirstBeneficiary = 0x9E01714A3700168E82b898618C6181Eb6abF7cff;
	address private devLockSecondBeneficiary = 0x20986b25C551f7944cEbF500F6C950229865FAae;
	address private devLockThirdBeneficiary = 0x3cD928a432c9666be26fE82480A8a77dA33b2B42;
	address private foundationBeneficiary = 0xCCF02CC2fF5e896fF3D7D6aDC59bAbe514EBb64C;
	address private marketBeneficiary = 0xC9b66dC5A27d94F9ab804dF98437945700b93555;
	address private devBeneficiary = 0xf89fdcca528e1E82da8dee643b38e693AebB6F45;
	address private labBeneficiary = 0x239d10c737E26cB85746426313aCF167b564eDB8;

	uint256 private _releaseTimeFirst = now + 365 days; 
	uint256 private _releaseTimeSecond = now + 365 days + 365 days; 
	uint256 private _releaseTimeThird = now + 365 days + 365 days + 365 days; 	
	
	bool public devLockFirstReleased = true;
	bool public devLockSecondReleased = true;
	bool public devLockThirdReleased = true;
    
    event Burn(address indexed burner, uint256 value);
	event OwnershipTransferred(address indexed perviousOwner, address indexed newOwner);
    
    constructor() public {  
		owner = msg.sender;
		totalSupply = 2000000000e18;
		totalRemaining = totalSupply.sub(foundationDistributed).sub(marketDistributed).sub(labDistributed).sub(devDistributed);
        balances[owner] = totalRemaining;
		balances[foundationBeneficiary] = foundationDistributed;
		balances[marketBeneficiary] = marketDistributed;
		balances[labBeneficiary] = labDistributed;
		balances[devBeneficiary] = devDistributed;
    }
    
    function transferOwnership(address newOwner) onlyOwner public {
		require(newOwner != address(0));
		emit OwnershipTransferred(owner, newOwner);
		balances[owner] = balances[owner].sub(totalRemaining);
		balances[newOwner] = balances[newOwner].add(totalRemaining);
		emit Transfer(owner, newOwner, totalRemaining);
		owner = newOwner;		
    }

    function balanceOf(address _owner) constant public returns (uint256) {
        return balances[_owner];
    }

    modifier onlyPayloadSize(uint size) {
        require(msg.data.length >= size + 4);  
        _;
    }
	
	function isPayLockFirst() public view returns (bool) { 
		if (now >= _releaseTimeFirst) {
			return true;
		} else {
			return false;
		}
	}
	function isPayLockSecond() public view returns (bool) { 
		if (now >= _releaseTimeSecond) {
			return true;
		} else {
			return false;
		}
	}
	function isPayLockThird() public view returns (bool) { 		
		if (now >= _releaseTimeThird) {
			return true;
		} else {
			return false;
		}
	}
	function releaseFirst()internal {
		balances[owner] = balances[owner].sub(devLockFirstDistributed);
		balances[devLockFirstBeneficiary] = balances[devLockFirstBeneficiary].add(devLockFirstDistributed);
		emit Transfer(owner, devLockFirstBeneficiary, devLockFirstDistributed);
		totalRemaining = totalRemaining.sub(devLockFirstDistributed);
		devLockFirstReleased = false;
	}
	function releaseSecond() internal {
		balances[owner] = balances[owner].sub(devLockSecondDistributed);
		balances[devLockSecondBeneficiary] = balances[devLockSecondBeneficiary].add(devLockSecondDistributed);
		emit Transfer(owner, devLockSecondBeneficiary, devLockSecondDistributed);
		totalRemaining = totalRemaining.sub(devLockSecondDistributed);
		devLockSecondReleased = false;
	}
	function releaseThird() internal {
		balances[owner] = balances[owner].sub(devLockThirdDistributed);
		balances[devLockThirdBeneficiary] = balances[devLockThirdBeneficiary].add(devLockThirdDistributed);
		emit Transfer(owner, devLockThirdBeneficiary, devLockThirdDistributed);
		totalRemaining = totalRemaining.sub(devLockThirdDistributed);
		devLockThirdReleased = false;
	}
	
	function release(address from) internal {
		if (from == devLockFirstBeneficiary) {
			if (isPayLockFirst()) {
				if (devLockFirstReleased) {
					releaseFirst();
				}
			}
		}
		if (from == devLockSecondBeneficiary) {
			if (isPayLockSecond()) {
				if (devLockSecondReleased) {
					releaseSecond();
				}
			}
		}
		if (from == devLockThirdBeneficiary) {
			if (isPayLockThird()) {
				if (devLockThirdReleased) {
					releaseThird();
				}
			}
		}
		
	}
    
    function transfer(address _to, uint256 _amount) onlyPayloadSize(2 * 32) public whenNotPaused returns (bool success) {
        require(blacklist[msg.sender] == false);
		require(blacklist[_to] == false);
		require(_to != address(0));
		if (msg.sender == owner) {
			require(balances[msg.sender] >= (totalRemaining.add(_amount)));
		}
		release(msg.sender);
        require(_amount <= balances[msg.sender]);		
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);		
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _amount) onlyPayloadSize(3 * 32) public whenNotPaused returns (bool success) {
        require(blacklist[msg.sender] == false);
		require(blacklist[_to] == false);
		require(blacklist[_from] == false);
		require(_to != address(0));
		if (_from == owner) {
			require(balances[_from] >= (totalRemaining.add(_amount)));
		}
		release(_from);
        require(_amount <= balances[_from]);
        require(_amount <= allowed[_from][msg.sender]);		
        balances[_from] = balances[_from].sub(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(_from, _to, _amount);
        return true;
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool success) {
		require(_value == 0 || allowed[msg.sender][_spender] == 0);
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
	
	function addOrRemoveBlackList(address _addr, bool action) onlyOwner public returns (bool success) {
		require(_addr != address(0));
		blacklist[_addr] = action;
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
		require(balances[msg.sender] >= totalRemaining.add(_value));
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(burner, _value);
    }
    
    function withdrawForeignTokens(address _tokenContract) onlyOwner public returns (bool) {
        ForeignToken token = ForeignToken(_tokenContract);
        uint256 amount = token.balanceOf(address(this));
        return token.transfer(owner, amount);
    }
}