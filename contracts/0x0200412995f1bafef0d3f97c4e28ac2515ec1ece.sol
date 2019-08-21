pragma solidity ^0.4.18;

// File: contracts/ERC223Receiver.sol

/**
 * @title Contract that will work with ERC223 tokens.
 */

contract ERC223Receiver {
	/**
	 * @dev Standard ERC223 function that will handle incoming token transfers.
	 *
	 * @param _from  Token sender address.
	 * @param _value Amount of tokens.
	 * @param _data  Transaction metadata.
	 */
	function tokenFallback(address _from, uint _value, bytes _data) public;
}

// File: zeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: zeppelin-solidity/contracts/ownership/Claimable.sol

/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
contract Claimable is Ownable {
  address public pendingOwner;

  /**
   * @dev Modifier throws if called by any account other than the pendingOwner.
   */
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

  /**
   * @dev Allows the current owner to set the pendingOwner address.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() onlyPendingOwner public {
    OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = address(0);
  }
}

// File: zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: zeppelin-solidity/contracts/token/ERC20/BasicToken.sol

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

// File: zeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: zeppelin-solidity/contracts/token/ERC20/StandardToken.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
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

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
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

// File: contracts/ERC223Token.sol

/*!	ERC223 token implementation
 */
contract ERC223Token is StandardToken, Claimable {
	using SafeMath for uint256;

	bool public erc223Activated;

	/*!	Whitelisting addresses of smart contracts which have

	 */
	mapping (address => bool) public whiteListContracts;

	/*!	Per user: whitelisting addresses of smart contracts which have

	 */
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
			// Retrieve the size of the code
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

// File: contracts/BurnableToken.sol

/*!	Functionality to keep burn for owner.
	Copy from Burnable token but only for owner
 */
contract BurnableToken is ERC223Token {
	using SafeMath for uint256;

	/*! Copy from Burnable token but only for owner */

	event Burn(address indexed burner, uint256 value);

	/**
	 * @dev Burns a specific amount of tokens.
	 * @param _value The amount of token to be burned.
	 */
	function burnTokenBurn(uint256 _value) public onlyOwner {
		require(_value <= balances[msg.sender]);
		// no need to require value <= totalSupply, since that would imply the
		// sender's balance is greater than the totalSupply, which *should* be an assertion failure

		address burner = msg.sender;
		balances[burner] = balances[burner].sub(_value);
		totalSupply_ = totalSupply_.sub(_value);
		Burn(burner, _value);
	}
}

// File: contracts/HoldersToken.sol

/*!	Functionality to keep up-to-dated list of all holders.
 */
contract HoldersToken is BurnableToken {
	using SafeMath for uint256;

	/*!	Keep the list of addresses of holders up-to-dated

		other contracts can communicate with or to do operations
		with all holders of tokens
	 */
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
		require(_to != address(this)); // Prevent transfer to contract itself
		bool ok = super.transfer(_to, _value);
		addHolder(_to);
		return ok;
	}

	function transfer(address _to, uint256 _value, bytes _data) public returns (bool) {
		require(_to != address(this)); // Prevent transfer to contract itself
		bool ok = super.transfer(_to, _value, _data);
		addHolder(_to);
		return ok;
	}

	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
		require(_to != address(this)); // Prevent transfer to contract itself
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

// File: contracts/MigrationAgent.sol

/*!	Definition of destination interface
	for contract that can be used for migration
 */
contract MigrationAgent {
	function migrateFrom(address from, uint256 value) public returns (bool);
}

// File: contracts/MigratoryToken.sol

/*!	Functionality to support migrations to new upgraded contract
	for tokens. Only has effect if migrations are enabled and
	address of new contract is known.
 */
contract MigratoryToken is HoldersToken {
	using SafeMath for uint256;

	//! Address of new contract for possible upgrades
	address public migrationAgent;
	//! Counter to iterate (by portions) through all addresses for migration
	uint256 public migrationCountComplete;

	/*!	Setup the address for new contract (to migrate coins to)
		Can be called only by owner (onlyOwner)
	 */
	function setMigrationAgent(address agent) public onlyOwner {
		migrationAgent = agent;
	}

	/*!	Migrate tokens to the new token contract
		The method can be only called when migration agent is set.

		Can be called by user(holder) that would like to transfer
		coins to new contract immediately.
	 */
	function migrate() public returns (bool) {
		require(migrationAgent != 0x0);
		uint256 value = balances[msg.sender];
		balances[msg.sender] = balances[msg.sender].sub(value);
		totalSupply_ = totalSupply_.sub(value);
		MigrationAgent(migrationAgent).migrateFrom(msg.sender, value);
		// Notify anyone listening that this migration took place
		Migrate(msg.sender, value);
		return true;
	}

	/*!	Migrate holders of tokens to the new contract
		The method can be only called when migration agent is set.

		Can be called only by owner (onlyOwner)
	 */
	function migrateHolders(uint256 count) public onlyOwner returns (bool) {
		require(count > 0);
		require(migrationAgent != 0x0);
		// Calculate bounds for processing
		count = migrationCountComplete.add(count);
		if (count > holders.length) {
			count = holders.length;
		}
		// Process migration
		for (uint256 i = migrationCountComplete; i < count; i++) {
			address holder = holders[i];
			uint value = balances[holder];
			balances[holder] = balances[holder].sub(value);
			totalSupply_ = totalSupply_.sub(value);
			MigrationAgent(migrationAgent).migrateFrom(holder, value);
			// Notify anyone listening that this migration took place
			Migrate(holder, value);
		}
		migrationCountComplete = count;
		return true;
	}

	event Migrate(address indexed owner, uint256 value);
}

// File: contracts/FollowCoin.sol

contract FollowCoin is MigratoryToken {
	using SafeMath for uint256;

	//! Token name FollowCoin
	string public name;
	//! Token symbol FLLW
	string public symbol;
	//! Token decimals, 18
	uint8 public decimals;

	/*!	Contructor
	 */
	function FollowCoin() public {
		name = "FollowCoin";
		symbol = "FLLW";
		decimals = 18;
		totalSupply_ = 515547535173959076174820000;
		balances[owner] = totalSupply_;
		holders[holders.length++] = owner;
		isHolder[owner] = true;
	}

	//! Address of migration gate to do transferMulti on migration
	address public migrationGate;

	/*!	Setup the address for new contract (to migrate coins to)
		Can be called only by owner (onlyOwner)
	 */
	function setMigrationGate(address _addr) public onlyOwner {
		migrationGate = _addr;
	}

	/*!	Throws if called by any account other than the migrationGate.
	 */
	modifier onlyMigrationGate() {
		require(msg.sender == migrationGate);
		_;
	}

	/*!	Transfer tokens to multipe destination addresses
		Returns list with appropriate (by index) successful statuses.
		(string with 0 or 1 chars)
	 */
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

	/*!	Do not accept incoming ether
	 */
	function() public payable {
		revert();
	}
}