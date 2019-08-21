// CHAINPAY -- BRINGING CRYPTO TO A [N]eighbor[H]ood NEAR YOU 


pragma solidity ^0.4.18;


contract ERC223Receiver {

	function tokenFallback(address _from, uint _value, bytes _data) public;
}


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


contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  function Ownable() public {
    owner = msg.sender;
  }

 
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


contract Claimable is Ownable {
  address public pendingOwner;

  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

 
  function transferOwnership(address newOwner) onlyOwner public {
    pendingOwner = newOwner;
  }

  function claimOwnership() onlyPendingOwner public {
    OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}


contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

 
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}


contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


contract ERC223Token is StandardToken, Claimable {
	using SafeMath for uint256;

	bool public erc223Activated;

	mapping (address => bool) public whiteListContracts;

	
	mapping (address => mapping (address => bool) ) public userWhiteListContracts;

	function setERC223Activated(bool _activate) public onlyOwner {
		erc223Activated = _activate;
	}
	function setWhiteListContract(address _addr, bool f) public onlyOwner {
		whiteListContracts[_addr] = f;
	}
	function setUserWhiteListContract(address _addr, bool f) public {
		userWhiteListContracts[msg.sender][_addr] = f;
	}

	function checkAndInvokeReceiver(address _to, uint256 _value, bytes _data) internal {
		uint codeLength;

		assembly {
			
			codeLength := extcodesize(_to)
		}

		if (codeLength>0) {
			ERC223Receiver receiver = ERC223Receiver(_to);
			receiver.tokenFallback(msg.sender, _value, _data);
		}
	}

	function transfer(address _to, uint256 _value) public returns (bool) {
		bool ok = super.transfer(_to, _value);
		if (erc223Activated
			&& whiteListContracts[_to] ==false
			&& userWhiteListContracts[msg.sender][_to] ==false) {
			bytes memory empty;
			checkAndInvokeReceiver(_to, _value, empty);
		}
		return ok;
	}

	function transfer(address _to, uint256 _value, bytes _data) public returns (bool) {
		bool ok = super.transfer(_to, _value);
		if (erc223Activated
			&& whiteListContracts[_to] ==false
			&& userWhiteListContracts[msg.sender][_to] ==false) {
			checkAndInvokeReceiver(_to, _value, _data);
		}
		return ok;
	}

	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
		bool ok = super.transferFrom(_from, _to, _value);
		if (erc223Activated
			&& whiteListContracts[_to] ==false
			&& userWhiteListContracts[_from][_to] ==false
			&& userWhiteListContracts[msg.sender][_to] ==false) {
			bytes memory empty;
			checkAndInvokeReceiver(_to, _value, empty);
		}
		return ok;
	}

	function transferFrom(address _from, address _to, uint256 _value, bytes _data) public returns (bool) {
		bool ok = super.transferFrom(_from, _to, _value);
		if (erc223Activated
			&& whiteListContracts[_to] ==false
			&& userWhiteListContracts[_from][_to] ==false
			&& userWhiteListContracts[msg.sender][_to] ==false) {
			checkAndInvokeReceiver(_to, _value, _data);
		}
		return ok;
	}

}

contract BurnableToken is ERC223Token {
	using SafeMath for uint256;


	event Burn(address indexed burner, uint256 value);


	function burnTokenBurn(uint256 _value) public onlyOwner {
		require(_value <= balances[msg.sender]);

		address burner = msg.sender;
		balances[burner] = balances[burner].sub(_value);
		totalSupply_ = totalSupply_.sub(_value);
		Burn(burner, _value);
	}
}

contract HoldersToken is BurnableToken {
	using SafeMath for uint256;


	mapping (address => bool) public isHolder;
	address [] public holders;

	function addHolder(address _addr) internal returns (bool) {
		if (isHolder[_addr] != true) {
			holders[holders.length++] = _addr;
			isHolder[_addr] = true;
			return true;
		}
		return false;
	}

	function transfer(address _to, uint256 _value) public returns (bool) {
		require(_to != address(this)); // Prevent sending coin to contract... ya dig?
		bool ok = super.transfer(_to, _value);
		addHolder(_to);
		return ok;
	}

	function transfer(address _to, uint256 _value, bytes _data) public returns (bool) {
		require(_to != address(this)); 
		bool ok = super.transfer(_to, _value, _data);
		addHolder(_to);
		return ok;
	}

	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
		require(_to != address(this)); 
		bool ok = super.transferFrom(_from, _to, _value);
		addHolder(_to);
		return ok;
	}

	function transferFrom(address _from, address _to, uint256 _value, bytes _data) public returns (bool) {
		require(_to != address(this)); // Prevent transfer to contract itself
		bool ok = super.transferFrom(_from, _to, _value, _data);
		addHolder(_to);
		return ok;
	}

}


contract MigrationAgent {
	function migrateFrom(address from, uint256 value) public returns (bool);
}

contract MigratoryToken is HoldersToken {
	using SafeMath for uint256;

	address public migrationAgent;

	uint256 public migrationCountComplete;

	
	function setMigrationAgent(address agent) public onlyOwner {
		migrationAgent = agent;
	}

	function migrate() public returns (bool) {
		require(migrationAgent != 0x0);
		uint256 value = balances[msg.sender];
		balances[msg.sender] = balances[msg.sender].sub(value);
		totalSupply_ = totalSupply_.sub(value);
		MigrationAgent(migrationAgent).migrateFrom(msg.sender, value);
	
		Migrate(msg.sender, value);
		return true;
	}

	function migrateHolders(uint256 count) public onlyOwner returns (bool) {
		require(count > 0);
		require(migrationAgent != 0x0);
		
		count = migrationCountComplete.add(count);
		if (count > holders.length) {
			count = holders.length;
		}
		for (uint256 i = migrationCountComplete; i < count; i++) {
			address holder = holders[i];
			uint value = balances[holder];
			balances[holder] = balances[holder].sub(value);
			totalSupply_ = totalSupply_.sub(value);
			MigrationAgent(migrationAgent).migrateFrom(holder, value);
			
			Migrate(holder, value);
		}
		migrationCountComplete = count;
		return true;
	}

	event Migrate(address indexed owner, uint256 value);
}

// File: contracts/ChainPay.sol

contract ChainPay is MigratoryToken {
	using SafeMath for uint256;

	// TOKEN NAME :: CHAINPAY :: LINKING DIGITAL PAYMENTS + EVERYDAY LIFE
	string public name;
	// TOKEN SYMBOL :: CIP :: CR_P IN PEACE NIP 
	string public symbol;
	//! Token decimals, 18
	uint8 public decimals;

	/*!	Contructor
	 */
	function ChainPay() public {
		name = "ChainPay";
		symbol = "CIP";
		decimals = 18;
		totalSupply_ = 6060660000000000000000000; //six million, sixty thousand, six hundred sixty 
		// SIX-O
		balances[owner] = totalSupply_;
		holders[holders.length++] = owner;
		isHolder[owner] = true;
	}

	address public migrationGate;

	
	function setMigrationGate(address _addr) public onlyOwner {
		migrationGate = _addr;
	}


	modifier onlyMigrationGate() {
		require(msg.sender == migrationGate);
		_;
	}


	function transferMulti(address [] _tos, uint256 [] _values) public onlyMigrationGate returns (string) {
		require(_tos.length == _values.length);
		bytes memory return_values = new bytes(_tos.length);

		for (uint256 i = 0; i < _tos.length; i++) {
			address _to = _tos[i];
			uint256 _value = _values[i];
			return_values[i] = byte(48); //'0'

			if (_to != address(0) &&
				_value <= balances[msg.sender]) {

				bool ok = transfer(_to, _value);
				if (ok) {
					return_values[i] = byte(49); //'1'
				}
			}
		}
		return string(return_values);
	}

// DONT ACCEPT INCOMMING CRYPTO TO CONTRACT 

	function() public payable {
		revert();
	}
}

//cryptocurrency allows you to control your wealth usingtechnology, never in history was that possible.
//we are forever prolific 
// (the marathon continues)
//six million, sixty thousand, six hundred sixty #LLNH