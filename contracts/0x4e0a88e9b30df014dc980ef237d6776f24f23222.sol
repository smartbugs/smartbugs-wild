pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

contract CoblicAccessControl {
	/**
	 *		- The Admin: The admin can reassign other roles and change the addresses of Coblic's smart contracts.
	 *			It is also the only role that can unpause the smart contract, and is initially set to the address
	 *			that created the smart contract in the CoblicToken constructor.
	 *
	 *		- The System: The System can call burn function
	 *
	 */

	// The addresses of the accounts (or contracts) that can execute actions within each roles.
	address public adminAddress;
	address public systemAddress;
	address public ceoAddress;

	/// @dev Access modifier for Admin-only functionality
	modifier onlyAdmin() {
		require(msg.sender == adminAddress);
		_;
	}

	// @dev Access modifier for CEO-only functionality
	modifier onlyCEO() {
		require(msg.sender == ceoAddress || msg.sender == adminAddress);
		_;
	}

	/// @dev Access modifier for System-only functionality
	modifier onlySystem() {
		require(msg.sender == systemAddress || msg.sender == adminAddress);
		_;
	}

	/// @dev Assigns a new address to act as the Admin. Only available to the current Admin.
	/// @param _newAdminAddress The address of the new Admin
	function setAdmin(address _newAdminAddress) public onlyAdmin {
		require(_newAdminAddress != address(0));

		adminAddress = _newAdminAddress;
	}

	/// @dev Assigns a new address to act as the System. Only available to the current Admin.
	/// @param _newSystemAddress The address of the new System
	function setSystem(address _newSystemAddress) public onlySystem {
		require(_newSystemAddress != address(0));

		systemAddress = _newSystemAddress;
	}

	/// @dev Assigns a new address to act as the CEO. Only available to the current CEO.
	/// @param _newCEOAddress The address of the new CEO
	function setCEO(address _newCEOAddress) public onlyCEO {
		require(_newCEOAddress != address(0));

		ceoAddress = _newCEOAddress;
	}
}

/**
 * @title ERC1132 interface
 * @dev see https://github.com/ethereum/EIPs/issues/1132
 */

contract ERC1132 {
	/**
	 * @dev Reasons why a user's tokens have been locked
	 */
	mapping(address => bytes32[]) public lockReason;

	/**
	 * @dev locked token structure
	 */
	struct lockToken {
		uint256 amount;
		uint256 validity;
		bool claimed;
	}

	/**
	 * @dev Holds number & validity of tokens locked for a given reason for
	 *      a specified address
	 */
	mapping(address => mapping(bytes32 => lockToken)) public locked;

	/**
	 * @dev Records data of all the tokens Locked
	 */
	event Locked(
			address indexed _of,
			bytes32 indexed _reason,
			uint256 _amount,
			uint256 _validity
			);

	/**
	 * @dev Records data of all the tokens unlocked
	 */
	event Unlocked(
			address indexed _of,
			bytes32 indexed _reason,
			uint256 _amount
			);

	/**
	 * @dev Locks a specified amount of tokens against an address,
	 *      for a specified reason and time
	 * @param _reason The reason to lock tokens
	 * @param _amount Number of tokens to be locked
	 * @param _time Lock time in seconds
	 * @param _of address to be locked
	 */
	function lock(bytes32 _reason, uint256 _amount, uint256 _time, address _of)
		public returns (bool);

	/**
	 * @dev Returns tokens locked for a specified address for a
	 *      specified reason
	 *
	 * @param _of The address whose tokens are locked
	 * @param _reason The reason to query the lock tokens for
	 */
	function tokensLocked(address _of, bytes32 _reason)
		public view returns (uint256 amount);

	/**
	 * @dev Returns tokens locked for a specified address for a
	 *      specified reason at a specific time
	 *
	 * @param _of The address whose tokens are locked
	 * @param _reason The reason to query the lock tokens for
	 * @param _time The timestamp to query the lock tokens for
	 */
	function tokensLockedAtTime(address _of, bytes32 _reason, uint256 _time)
		public view returns (uint256 amount);

	/**
	 * @dev Returns total tokens held by an address (locked + transferable)
	 * @param _of The address to query the total balance of
	 */
	function totalBalanceOf(address _of)
		public view returns (uint256 amount);

	/**
	 * @dev Extends lock for a specified reason and time
	 * @param _reason The reason to lock tokens
	 * @param _time Lock extension time in seconds
	 */
	function extendLock(bytes32 _reason, uint256 _time)
		public returns (bool);

	/**
	 * @dev Increase number of tokens locked for a specified reason
	 * @param _reason The reason to lock tokens
	 * @param _amount Number of tokens to be increased
	 */
	function increaseLockAmount(bytes32 _reason, uint256 _amount)
		public returns (bool);

	/**
	 * @dev Returns unlockable tokens for a specified address for a specified reason
	 * @param _of The address to query the the unlockable token count of
	 * @param _reason The reason to query the unlockable tokens for
	 */
	function tokensUnlockable(address _of, bytes32 _reason)
		public view returns (uint256 amount);

	/**
	 * @dev Unlocks the unlockable tokens of a specified address
	 * @param _of Address of user, claiming back unlockable tokens
	 */
	function unlock(address _of)
		public returns (uint256 unlockableTokens);

	/**
	 * @dev Gets the unlockable tokens of a specified address
	 * @param _of The address to query the the unlockable token count of
	 */
	function getUnlockableTokens(address _of)
		public view returns (uint256 unlockableTokens);

}

contract CoblicToken is StandardToken, CoblicAccessControl, ERC1132 {
	// Define constants
	string public constant name = "Coblic Token";
	string public constant symbol = "CT";
	uint256 public constant decimals = 18;
	uint256 public constant INITIAL_SUPPLY = 20000000000 * (10 ** decimals);

	event Mint(address minter, uint256 value);
	event Burn(address burner, uint256 value);

	/**
	 * @dev Error messages for require statements
	 */
	string internal constant INVALID_TOKEN_VALUES = 'Invalid token values';
	string internal constant NOT_ENOUGH_TOKENS = 'Not enough tokens';
	string internal constant ALREADY_LOCKED = 'Tokens already locked';
	string internal constant NOT_LOCKED = 'No tokens locked';
	string internal constant AMOUNT_ZERO = 'Amount can not be 0';

	constructor(address _adminAddress, address _systemAddress, address _ceoAddress) public {
		adminAddress = _adminAddress;
		systemAddress = _systemAddress;
		ceoAddress = _ceoAddress;
		totalSupply_ = INITIAL_SUPPLY;
		balances[adminAddress] = INITIAL_SUPPLY;
	}

	/**
	 * admin or system can call burn function to burn tokens in 0x0 address
	 */

	/**
	 * @dev Mint a specified amount of tokens to the Admin address. Only available to the Admin.
	 * @param _to address to mint
	 * @param _amount an amount value to be minted
	 */
	function mint(address _to, uint256 _amount) public onlyAdmin {
		require(_amount > 0, INVALID_TOKEN_VALUES);
		balances[_to] = balances[_to].add(_amount);
		totalSupply_ = totalSupply_.add(_amount);
		emit Mint(_to, _amount);
	}

	/**
	 * @dev Burn a specified amount of tokens in msg.sender. Only available to the Admin and System.
	 * @param _of address to burn
	 * @param _amount an amount value to be burned
	 */
	function burn(address _of, uint256 _amount) public onlySystem {
		require(_amount > 0, INVALID_TOKEN_VALUES);
		require(_amount <= balances[_of], NOT_ENOUGH_TOKENS);
		balances[_of] = balances[_of].sub(_amount);
		totalSupply_ = totalSupply_.sub(_amount);
		emit Burn(_of, _amount);
	}

	/**
	 * @dev Locks a specified amount of tokens against an address,
	 *      for a specified reason and time
	 * @param _reason The reason to lock tokens
	 * @param _amount Number of tokens to be locked
	 * @param _time Lock time in seconds
	 * @param _of address to be locked
	 */
	function lock(bytes32 _reason, uint256 _amount, uint256 _time, address _of) public onlyAdmin returns (bool) {
		uint256 validUntil = now.add(_time); //solhint-disable-line

		// If tokens are already locked, then functions extendLock or
		// increaseLockAmount should be used to make any changes
		require(_amount <= balances[_of], NOT_ENOUGH_TOKENS);
		require(tokensLocked(_of, _reason) == 0, ALREADY_LOCKED);
		require(_amount != 0, AMOUNT_ZERO);

		if (locked[_of][_reason].amount == 0)
			lockReason[_of].push(_reason);

		balances[address(this)] = balances[address(this)].add(_amount);
		balances[_of] = balances[_of].sub(_amount);

		locked[_of][_reason] = lockToken(_amount, validUntil, false);

		emit Transfer(_of, address(this), _amount);
		emit Locked(_of, _reason, _amount, validUntil);
		return true;
	}

	/**
	 * @dev Transfers and Locks a specified amount of tokens,
	 *      for a specified reason and time
	 * @param _to adress to which tokens are to be transfered
	 * @param _reason The reason to lock tokens
	 * @param _amount Number of tokens to be transfered and locked
	 * @param _time Lock time in seconds
	 */
	function transferWithLock(address _to, bytes32 _reason, uint256 _amount, uint256 _time) public returns (bool) {
		uint256 validUntil = now.add(_time); //solhint-disable-line

		require(tokensLocked(_to, _reason) == 0, ALREADY_LOCKED);
		require(_amount != 0, AMOUNT_ZERO);

		if (locked[_to][_reason].amount == 0)
			lockReason[_to].push(_reason);

		transfer(address(this), _amount);

		locked[_to][_reason] = lockToken(_amount, validUntil, false);

		emit Locked(_to, _reason, _amount, validUntil);
		return true;
	}

	/**
	 * @dev Returns tokens locked for a specified address for a
	 *      specified reason
	 *
	 * @param _of The address whose tokens are locked
	 * @param _reason The reason to query the lock tokens for
	 */
	function tokensLocked(address _of, bytes32 _reason) public view returns (uint256 amount) {
		if (!locked[_of][_reason].claimed)
			amount = locked[_of][_reason].amount;
	}

	/**
	 * @dev Returns tokens locked for a specified address for a
	 *      specified reason at a specific time
	 *
	 * @param _of The address whose tokens are locked
	 * @param _reason The reason to query the lock tokens for
	 * @param _time The timestamp to query the lock tokens for
	 */
	function tokensLockedAtTime(address _of, bytes32 _reason, uint256 _time) public view returns (uint256 amount) {
		if (locked[_of][_reason].validity > _time)
			amount = locked[_of][_reason].amount;
	}

	/**
	 * @dev Returns total tokens held by an address (locked + transferable)
	 * @param _of The address to query the total balance of
	 */
	function totalBalanceOf(address _of) public view returns (uint256 amount) {
		amount = balanceOf(_of);

		for (uint256 i = 0; i < lockReason[_of].length; i++) {
			amount = amount.add(tokensLocked(_of, lockReason[_of][i]));
		}
	}

	/**
	 * @dev Extends lock for a specified reason and time
	 * @param _reason The reason to lock tokens
	 * @param _time Lock extension time in seconds
	 */
	function extendLock(bytes32 _reason, uint256 _time) public returns (bool) {
		require(tokensLocked(msg.sender, _reason) > 0, NOT_LOCKED);

		locked[msg.sender][_reason].validity = locked[msg.sender][_reason].validity.add(_time);

		emit Locked(msg.sender, _reason, locked[msg.sender][_reason].amount, locked[msg.sender][_reason].validity);
		return true;
	}

	/**
	 * @dev Increase number of tokens locked for a specified reason
	 * @param _reason The reason to lock tokens
	 * @param _amount Number of tokens to be increased
	 */
	function increaseLockAmount(bytes32 _reason, uint256 _amount) public returns (bool) {
		require(tokensLocked(msg.sender, _reason) > 0, NOT_LOCKED);
		transfer(address(this), _amount);

		locked[msg.sender][_reason].amount = locked[msg.sender][_reason].amount.add(_amount);

		emit Locked(msg.sender, _reason, locked[msg.sender][_reason].amount, locked[msg.sender][_reason].validity);
		return true;
	}

	/**
	 * @dev Returns unlockable tokens for a specified address for a specified reason
	 * @param _of The address to query the the unlockable token count of
	 * @param _reason The reason to query the unlockable tokens for
	 */
	function tokensUnlockable(address _of, bytes32 _reason) public view returns (uint256 amount) {
		if (locked[_of][_reason].validity <= now && !locked[_of][_reason].claimed) //solhint-disable-line
			amount = locked[_of][_reason].amount;
	}

	/**
	 * @dev Unlocks the unlockable tokens of a specified address
	 * @param _of Address of user, claiming back unlockable tokens
	 */
	function unlock(address _of) public returns (uint256 unlockableTokens) {
		uint256 lockedTokens;

		for (uint256 i = 0; i < lockReason[_of].length; i++) {
			lockedTokens = tokensUnlockable(_of, lockReason[_of][i]);
			if (lockedTokens > 0) {
				unlockableTokens = unlockableTokens.add(lockedTokens);
				locked[_of][lockReason[_of][i]].claimed = true;
				emit Unlocked(_of, lockReason[_of][i], lockedTokens);
			}
		}  

		if (unlockableTokens > 0)
			this.transfer(_of, unlockableTokens);
	}

	/**
	 * @dev Gets the unlockable tokens of a specified address
	 * @param _of The address to query the the unlockable token count of
	 */
	function getUnlockableTokens(address _of) public view returns (uint256 unlockableTokens) {
		for (uint256 i = 0; i < lockReason[_of].length; i++) {
			unlockableTokens = unlockableTokens.add(tokensUnlockable(_of, lockReason[_of][i]));
		}  
	}
}