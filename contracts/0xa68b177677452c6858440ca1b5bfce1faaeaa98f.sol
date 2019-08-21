library SafeMath {
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b > 0); // Solidity automatically throws when dividing by 0
		uint256 c = a / b;
		assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

contract Ownable {
	address public owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}
	
	function transferOwnership(address newOwner) public onlyOwner {
		require(newOwner != address(0));
		OwnershipTransferred(owner, newOwner);
		owner = newOwner;
	}
}

contract ERC20 {
	uint public totalSupply;
	function balanceOf(address _owner) public constant returns (uint balance);
	function transfer(address _to,uint _value) public returns (bool success);
	function transferFrom(address _from,address _to,uint _value) public returns (bool success);
	function approve(address _spender,uint _value) public returns (bool success);
	function allownce(address _owner,address _spender) public constant returns (uint remaining);
	event Transfer(address indexed _from,address indexed _to,uint _value);
	event Approval(address indexed _owner,address indexed _spender,uint _value);
}

contract Option is ERC20,Ownable {
	using SafeMath for uint8;
	using SafeMath for uint256;
	
	event Burn(address indexed _from,uint256 _value);
	event Increase(address indexed _to, uint256 _value);
	event SetItemOption(address _to, uint256 _amount, uint256 _releaseTime);
	
	struct ItemAccount {
		address fromAccount;
		address toAccount;
	}
	struct ItemOption {
		uint256 releaseAmount;
		uint256 releaseTime;
	}
	struct listOption {
	    uint256 offset;
	    address fromAccount;
		address toAccount;
		uint256 releaseAmount;
		uint256 releaseTime;
	}

	string public name;
	string public symbol;
	uint8 public decimals;
	uint256 public initial_supply;
	mapping (address => uint256) public balances;
	mapping (address => mapping (address => uint256)) allowed;
	uint256 private offset;
	mapping (address => uint256[]) fromOption;
	mapping (address => uint256[]) toOption;
	mapping (uint256 => ItemAccount) itemAccount;
	mapping (uint256 => ItemOption[]) mapOption;
	
	function Option (
		string Name,
		string Symbol,
		uint8 Decimals,
		uint256 initialSupply,
		address initOwner
	) public {
		require(initOwner != address(0));
		owner = initOwner;
		name = Name;
		symbol = Symbol;
		decimals = Decimals;
		initial_supply = initialSupply * (10 ** uint256(decimals));
		totalSupply = initial_supply;
		balances[initOwner] = totalSupply;
		offset = 0;
	}
	
	function itemBalance(address _to) public view returns (uint256 amount) {
		require(_to != address(0));
		amount = 0;
		uint256 nowtime = now;
		for(uint256 i = 0; i < toOption[_to].length; i++) {
		    for(uint256 j = 0; j < mapOption[toOption[_to][i]].length; j++) {
		        if(mapOption[toOption[_to][i]][j].releaseAmount > 0 && nowtime >= mapOption[toOption[_to][i]][j].releaseTime) {
		            amount = amount.add(mapOption[toOption[_to][i]][j].releaseAmount);
		        }
		    }
		}
		return amount;
	}
	
	function balanceOf(address _owner) public view returns (uint256 balance) {
		return balances[_owner].add(itemBalance(_owner));
	}
	
	function itemTransfer(address _to) public returns (bool success) {
		require(_to != address(0));
		uint256 nowtime = now;
		for(uint256 i = 0; i < toOption[_to].length; i++) {
		    for(uint256 j = 0; j < mapOption[toOption[_to][i]].length; j++) {
		        if(mapOption[toOption[_to][i]][j].releaseAmount > 0 && nowtime >= mapOption[toOption[_to][i]][j].releaseTime) {
    		        balances[_to] = balances[_to].add(mapOption[toOption[_to][i]][j].releaseAmount);
    		        mapOption[toOption[_to][i]][j].releaseAmount = 0;
    		    }
		    }
		}
		return true;
	}
	
	function transfer(address _to,uint _value) public returns (bool success) {
		itemTransfer(_to);
		if(balances[msg.sender] >= _value && _value > 0 && balances[_to] + _value > balances[_to]){
			balances[msg.sender] = balances[msg.sender].sub(_value);
			balances[_to] = balances[_to].add(_value);
			Transfer(msg.sender,_to,_value);
			return true;
		} else {
			return false;
		}
	}

	function transferFrom(address _from,address _to,uint _value) public returns (bool success) {
		itemTransfer(_from);
		if(balances[_from] >= _value && _value > 0 && balances[_to] + _value > balances[_to]) {
			if(_from != msg.sender) {
				require(allowed[_from][msg.sender] > _value);
				allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
			}
			balances[_from] = balances[_from].sub(_value);
			balances[_to] = balances[_to].add(_value);
			Transfer(_from,_to,_value);
			return true;
		} else {
			return false;
		}
	}

	function approve(address _spender, uint _value) public returns (bool success) {
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender,_spender,_value);
		return true;
	}
	
	function allownce(address _owner,address _spender) public constant returns (uint remaining) {
		return allowed[_owner][_spender];
	}
	
	function burn(uint256 _value) public returns (bool success) {
		require(balances[msg.sender] >= _value);
		balances[msg.sender] = balances[msg.sender].sub(_value);
		totalSupply = totalSupply.sub(_value);
		Burn(msg.sender,_value);
		return true;
	}

	function increase(uint256 _value) public onlyOwner returns (bool success) {
		if(balances[msg.sender] + _value > balances[msg.sender]) {
			totalSupply = totalSupply.add(_value);
			balances[msg.sender] = balances[msg.sender].add(_value);
			Increase(msg.sender, _value);
			return true;
		}
	}
	
	function setItemOptions(address _to, uint256 _amount, uint256 _startTime, uint8 _count) public returns (bool success) {
	    require(_to != address(0));
		require(_amount > 0);
		require(_count > 0);
		
		uint256 total = _amount.mul(_count);
		require(total > 0 && balances[msg.sender].sub(total) >= 0 && balances[_to].add(total) > balances[_to]);
		
		fromOption[msg.sender].push(offset);
		toOption[_to].push(offset);
		itemAccount[offset] = ItemAccount(msg.sender, _to);
		
		balances[msg.sender] = balances[msg.sender].sub(total);
		
		uint256 releaseTime = _startTime;
		for(uint8 i = 0; i < _count; i++) {
		    releaseTime = releaseTime.add(1 years);
		    mapOption[offset].push(ItemOption(_amount, releaseTime));
		}
		offset++;
		
		return true;
	}
	
	function fromListOptions() public view returns (uint256[] offset_s) {
	    uint256 nowtime = now;
	    uint8 k = 0;
	    for(uint256 i = 0; i < fromOption[msg.sender].length; i++) {
	        for(uint256 j = 0; j < mapOption[fromOption[msg.sender][i]].length; j++) {
	            if(mapOption[fromOption[msg.sender][i]][j].releaseAmount > 0 && mapOption[fromOption[msg.sender][i]][j].releaseTime > nowtime) {
                    offset_s[k] = fromOption[msg.sender][i];
                    k++;
	                break;
	            }
	        }
	    }
	}
	
	function toListOptions() public view returns (uint256[] offset_s) {
	    uint256 nowtime = now;
	    uint8 k = 0;
	    for(uint256 i = 0; i < toOption[msg.sender].length; i++) {
	        for(uint256 j = 0; j < mapOption[toOption[msg.sender][i]].length; j++) {
	            if(mapOption[toOption[msg.sender][i]][j].releaseAmount > 0 && mapOption[toOption[msg.sender][i]][j].releaseTime > nowtime) {
	                offset_s[k] = toOption[msg.sender][i];
	                k++;
	                break;
	            }
	        }
	    }
	}
	
	function getOption(uint256 _offset) public view returns (address fromAccount, address toAccount, uint8 count, uint256 totalAmount) {
	    require(_offset >= 0);
	    require(itemAccount[_offset].fromAccount == msg.sender || itemAccount[_offset].toAccount == msg.sender);
	    
	    fromAccount = itemAccount[_offset].fromAccount;
	    toAccount = itemAccount[_offset].toAccount;
	    count = 0;
	    totalAmount = 0;
	    uint256 nowtime = now;
	    for(uint256 i = 0; i < mapOption[_offset].length; i++) {
	        if(mapOption[_offset][i].releaseAmount > 0 && mapOption[_offset][i].releaseTime > nowtime && totalAmount.add(mapOption[_offset][i].releaseAmount) > totalAmount) {
	            count++;
	            totalAmount = totalAmount.add(mapOption[_offset][i].releaseAmount);
	        }
	    }
	}
	
	function getOptionOnce(uint256 _offset, uint8 _id) public view returns (address fromAccount, address toAccount, uint256 releaseAmount, uint256 releaseTime) {
	    require(_offset >= 0);
	    require(_id >= 0);
	    require(itemAccount[_offset].fromAccount == msg.sender || itemAccount[_offset].toAccount == msg.sender);
	    require(mapOption[_offset][_id].releaseAmount > 0);
	    
	    fromAccount = itemAccount[_offset].fromAccount;
	    toAccount = itemAccount[_offset].toAccount;
	    releaseAmount = mapOption[_offset][_id].releaseAmount;
	    releaseTime = mapOption[_offset][_id].releaseTime;
	}
	
	function burnOptions(address _to, uint256 _offset) public returns (bool success) {
	    require(_to != address(0));
	    require(_offset >= 0);
	    uint256 nowtime = now;
	    for(uint256 i = 0; i < toOption[_to].length; i++) {
	        if(toOption[_to][i] == _offset && itemAccount[toOption[_to][i]].fromAccount == msg.sender) {
	            for(uint256 j = 0; j < mapOption[_offset].length; j++) {
	                if(mapOption[_offset][j].releaseAmount > 0 && mapOption[_offset][j].releaseTime > nowtime && balances[msg.sender].add(mapOption[_offset][j].releaseAmount) > balances[msg.sender]) {
	                    balances[msg.sender] = balances[msg.sender].add(mapOption[_offset][j].releaseAmount);
	                    mapOption[_offset][j].releaseAmount = 0;
	                }
	            }
	            return true;
	        }
	    }
	    
	    return false;
	}
}