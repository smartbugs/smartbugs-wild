pragma solidity 0.4.24;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}


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

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
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
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
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
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint _addedValue
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
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

/**
* @title Emco token
* @dev Emco token implementation
*/
contract EmcoToken is StandardToken, Ownable {

	string public constant name = "EmcoToken";
	string public constant symbol = "EMCO";
	uint8 public constant decimals = 18;

	uint public constant INITIAL_SUPPLY = 1500000 * (10 ** uint(decimals));
	uint public constant MAX_SUPPLY = 36000000 * (10 ** uint(decimals));

	mapping (address => uint) public miningBalances;
	mapping (address => uint) public lastMiningBalanceUpdateTime;

	address systemAddress;

	uint public constant DAY_MINING_DEPOSIT_LIMIT = 360000 * (10 ** uint(decimals));
	uint public constant TOTAL_MINING_DEPOSIT_LIMIT = 3600000 * (10 ** uint(decimals));
	uint currentDay;
	uint currentDayDeposited;
	uint public miningTotalDeposited;

	mapping(address => bytes32) public userReferralCodes;
	mapping(bytes32 => address) public referralCodeOwners;
	mapping(address => address) public referrals;

	event Mine(address indexed beneficiary, uint value);

	event MiningBalanceUpdated(address indexed owner, uint amount, bool isDeposit);

	constructor() public {
		balances[msg.sender] = INITIAL_SUPPLY;
		systemAddress = msg.sender;
		totalSupply_ = INITIAL_SUPPLY;
		emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
	}

	function setReferralCode(bytes32 _code) public returns (bytes32) {
		require(_code != "", "Ref code should not be empty");
		require(referralCodeOwners[_code] == address(0), "This referral code is already used");
		require(userReferralCodes[msg.sender] == "", "Referal code is already set");
		userReferralCodes[msg.sender] = _code;
		referralCodeOwners[_code] = msg.sender;
		return userReferralCodes[msg.sender];
	}

	function setReferral(bytes32 _code) public {
		require(referralCodeOwners[_code] != address(0), "Invalid referral code");
		require(referrals[msg.sender] == address(0), "You already have a referrer");
		address referrer = referralCodeOwners[_code];
		require(referrer != msg.sender, "Can not invite yourself");
		referrals[msg.sender] = referrer;
	}

	/**
	* @dev Gets the balance of specified address (amount of tokens on main balance 
	* plus amount of tokens on mining balance).
	* @param _owner The address to query the balance of.
	* @return An uint256 representing the amount owned by the passed address.
	*/
	function balanceOf(address _owner) public view returns (uint balance) {
		return balances[_owner].add(miningBalances[_owner]);
	}

	/**
	* @dev Gets the mining balance if caller.
	* @param _owner The address to query the balance of.
	* @return An uint256 representing the amount of tokens of caller's mining balance
	*/
	function miningBalanceOf(address _owner) public view returns (uint balance) {
		return miningBalances[_owner];
	}

	/**
	* @dev Moves specified amount of tokens from main balance to mining balance 
	* @param _amount An uint256 representing the amount of tokens to transfer to main balance
	*/
	function depositToMiningBalance(uint _amount) public {
		require(balances[msg.sender] >= _amount, "not enough tokens");
		require(getCurrentDayDeposited().add(_amount) <= DAY_MINING_DEPOSIT_LIMIT,
			"Day mining deposit exceeded");
		require(miningTotalDeposited.add(_amount) <= TOTAL_MINING_DEPOSIT_LIMIT,
			"Total mining deposit exceeded");

		balances[msg.sender] = balances[msg.sender].sub(_amount);
		miningBalances[msg.sender] = miningBalances[msg.sender].add(_amount);
		miningTotalDeposited = miningTotalDeposited.add(_amount);
		updateCurrentDayDeposited(_amount);
		lastMiningBalanceUpdateTime[msg.sender] = now;
		emit MiningBalanceUpdated(msg.sender, _amount, true);
	}

	/**
	* @dev Moves specified amount of tokens from mining balance to main balance
	* @param _amount An uint256 representing the amount of tokens to transfer to mining balance
	*/
	function withdrawFromMiningBalance(uint _amount) public {
		require(miningBalances[msg.sender] >= _amount, "not enough tokens on mining balance");

		miningBalances[msg.sender] = miningBalances[msg.sender].sub(_amount);
		balances[msg.sender] = balances[msg.sender].add(_amount);

		//updating mining limits
		miningTotalDeposited.sub(_amount);
		lastMiningBalanceUpdateTime[msg.sender] = now;
		emit MiningBalanceUpdated(msg.sender, _amount, false);
	}

	/**
	* @dev Mine tokens. For every 24h for each user�s token on mining balance, 
	* 1% is burnt on mining balance and Reward % is minted to the main balance. 15% fee of difference 
	* between minted coins and burnt coins goes to system address.
	*/ 
	function mine() public {
		require(totalSupply_ < MAX_SUPPLY, "mining is over");
		uint reward = getReward(totalSupply_);
		uint daysForReward = getDaysForReward();

		uint mintedAmount = miningBalances[msg.sender].mul(reward.sub(1000000000))
										.mul(daysForReward).div(100000000000);
		require(mintedAmount != 0, "mining will not produce any reward");

		uint amountToBurn = miningBalances[msg.sender].mul(daysForReward).div(100);

		//check exceeding max number of tokens
		if(totalSupply_.add(mintedAmount) > MAX_SUPPLY) {
			uint availableToMint = MAX_SUPPLY.sub(totalSupply_);
			amountToBurn = availableToMint.div(mintedAmount).mul(amountToBurn);
			mintedAmount = availableToMint;
		}

		totalSupply_ = totalSupply_.add(mintedAmount);

		miningBalances[msg.sender] = miningBalances[msg.sender].sub(amountToBurn);
		balances[msg.sender] = balances[msg.sender].add(amountToBurn);

		uint userReward;
		uint referrerReward = 0;
		address referrer = referrals[msg.sender];
		
		if(referrer == address(0)) {
			userReward = mintedAmount.mul(85).div(100);
		} else {
			userReward = mintedAmount.mul(86).div(100);
			referrerReward = mintedAmount.div(100);
			balances[referrer] = balances[referrer].add(referrerReward);
			emit Mine(referrer, referrerReward);
			emit Transfer(address(0), referrer, referrerReward);
		}
		balances[msg.sender] = balances[msg.sender].add(userReward);

		emit Mine(msg.sender, userReward);
		emit Transfer(address(0), msg.sender, userReward);

		//update limits
		miningTotalDeposited = miningTotalDeposited.sub(amountToBurn);
		emit MiningBalanceUpdated(msg.sender, amountToBurn, false);

		//set system fee
		uint systemFee = mintedAmount.sub(userReward).sub(referrerReward);
		balances[systemAddress] = balances[systemAddress].add(systemFee);

		emit Mine(systemAddress, systemFee);
		emit Transfer(address(0), systemAddress, systemFee);

		lastMiningBalanceUpdateTime[msg.sender] = now;
	}

	/**
	* @dev Set system address
	* @param _systemAddress An address to set
	*/
	function setSystemAddress(address _systemAddress) public onlyOwner {
		systemAddress = _systemAddress;
	}

	/**
	* @dev Get sum of deposits to mining accounts for current day
	*/
	function getCurrentDayDeposited() public view returns (uint) {
		if(now / 1 days == currentDay) {
			return currentDayDeposited;
		} else {
			return 0;
		}
	}

	/**
	* @dev Get number of days for reward on mining. Maximum 100 days.
	* @return An uint256 representing number of days user will get reward for.
	*/
	function getDaysForReward() public view returns (uint rewardDaysNum){
		if(lastMiningBalanceUpdateTime[msg.sender] == 0) {
			return 0;
		} else {
			uint value = (now - lastMiningBalanceUpdateTime[msg.sender]) / (1 days);
			if(value > 100) {
				return 100;
			} else {
				return value;
			}
		}
	}

	/**
	* @dev Calculate current mining reward based on total supply of tokens
	* @return An uint256 representing reward in percents multiplied by 1000000000
	*/
	function getReward(uint _totalSupply) public pure returns (uint rewardPercent){
		uint rewardFactor = 1000000 * (10 ** uint256(decimals));
		uint decreaseFactor = 41666666;

		if(_totalSupply < 23 * rewardFactor) {
			return 2000000000 - (decreaseFactor.mul(_totalSupply.div(rewardFactor)));
		}

		if(_totalSupply < MAX_SUPPLY) {
			return 1041666666;
		} else {
			return 1000000000;
		} 
	}

	function updateCurrentDayDeposited(uint _addedTokens) private {
		if(now / 1 days == currentDay) {
			currentDayDeposited = currentDayDeposited.add(_addedTokens);
		} else {
			currentDay = now / 1 days;
			currentDayDeposited = _addedTokens;
		}
	}

}