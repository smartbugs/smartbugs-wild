pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */

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

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

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

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
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
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
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

 //The Persian Daric was a gold coin which, along
 //with a similar silver coin, the siglos, represented
 //the bimetallic monetary standard of the 
 //Achaemenid Persian Empire.in that era Daric
 //was the best phenomena in purpose to making
 //possible exchange in whole world.This is a 
 //contract to celebrate our ancestors and to 
 //remind us of the tradition. The tradition one 
 //that made our lives today. We are going to the 
 //future, while this is our past that drives us 
 //forward. Author, Farhad Ghanaatgar 
 //Constructor
contract DaRiCpAy is StandardToken {
	using SafeMath for uint256;

    // EVENTS
    event CreatedIRC(address indexed _creator, uint256 _amountOfIRC);

	
	// TOKEN DATA
	string public constant name = "DaRiC";
	string public constant symbol = "IRC";
	uint256 public constant decimals = 18;
	string public version = "1.0";

	// IRC TOKEN PURCHASE LIMITS
	uint256 public maxPresaleSupply; 	// MAX TOTAL DURING PRESALE (0.8% of MAXTOTALSUPPLY)

	// PURCHASE DATES
	uint256 public constant preSaleStartTime = 1516406400; 	//Saturday, 20-Jan-18 00:00:00 UTC in RFC 2822
	uint256 public constant preSaleEndTime = 1518220800 ; 	// Saturday, 10-Feb-18 00:00:00 UTC in RFC 2822
	uint256 public saleStartTime = 1518267600 ; // Saturday, 10-Feb-18 13:00:00 UTC in RFC 2822
	uint256 public saleEndTime = 1522429200; //Friday, 30-Mar-18 17:00:00 UTC in RFC 2822


	// PURCHASE BONUSES
	uint256 public lowEtherBonusLimit = 5 * 1 ether;				// 5+ Ether
	uint256 public lowEtherBonusValue = 110;						// 10% Discount
	uint256 public midEtherBonusLimit = 24 * 1 ether; 		    	// 24+ Ether
	uint256 public midEtherBonusValue = 115;						// 15% Discount
	uint256 public highEtherBonusLimit = 50 * 1 ether; 				// 50+ Ether
	uint256 public highEtherBonusValue = 120; 						// 20% Discount
	uint256 public highTimeBonusLimit = 0; 							// 1-12 Days
	uint256 public highTimeBonusValue = 115; 						// 20% Discount
	uint256 public midTimeBonusLimit = 1036800; 					// 12-24 Days
	uint256 public midTimeBonusValue = 110; 						// 15% Discount
	uint256 public lowTimeBonusLimit = 3124800;						// 24+ Days
	uint256 public lowTimeBonusValue = 105;							// 5% Discount

	// PRICING INFO
	uint256 public constant IRC_PER_ETH_PRE_SALE = 10000;  			// 10000 IRC = 1 ETH
	uint256 public constant IRC_PER_ETH_SALE = 8000;  				// 8000 IRC = 1 ETH
	
	// ADDRESSES
	address public constant ownerAddress = 0x88ce817Efd0dD935Eed8e9d553167d08870AA6e7; 	// The owners address

	// STATE INFO	
	bool public allowInvestment = true;								// Flag to change if transfering is allowed
	uint256 public totalWEIInvested = 0; 							// Total WEI invested
	uint256 public totalIRCAllocated = 0;							// Total IRC allocated
	mapping (address => uint256) public WEIContributed; 			// Total WEI Per Account


	// INITIALIZATIONS FUNCTION
	function DaRiCpAy() {
		require(msg.sender == ownerAddress);

		totalSupply = 20*1000000*1000000000000000000; 				// MAX TOTAL IRC 20 million
		uint256 totalIRCReserved = totalSupply.mul(20).div(100);	// 20% reserved for IRC
		maxPresaleSupply = totalSupply*8/1000 + totalIRCReserved; 	// MAX TOTAL DURING PRESALE (0.8% of MAXTOTALSUPPLY)

		balances[msg.sender] = totalIRCReserved;
		totalIRCAllocated = totalIRCReserved;				
	}


	// FALL BACK FUNCTION TO ALLOW ETHER DONATIONS
	function() payable {

		require(allowInvestment);

		// Smallest investment is 0.00001 ether
		uint256 amountOfWei = msg.value;
		require(amountOfWei >= 10000000000000);

		uint256 amountOfIRC = 0;
		uint256 absLowTimeBonusLimit = 0;
		uint256 absMidTimeBonusLimit = 0;
		uint256 absHighTimeBonusLimit = 0;
		uint256 totalIRCAvailable = 0;

		// Investment periods
		if (now > preSaleStartTime && now < preSaleEndTime) {
			// Pre-sale ICO
			amountOfIRC = amountOfWei.mul(IRC_PER_ETH_PRE_SALE);
			absLowTimeBonusLimit = preSaleStartTime + lowTimeBonusLimit;
			absMidTimeBonusLimit = preSaleStartTime + midTimeBonusLimit;
			absHighTimeBonusLimit = preSaleStartTime + highTimeBonusLimit;
			totalIRCAvailable = maxPresaleSupply - totalIRCAllocated;
		} else if (now > saleStartTime && now < saleEndTime) {
			// ICO
			amountOfIRC = amountOfWei.mul(IRC_PER_ETH_SALE);
			absLowTimeBonusLimit = saleStartTime + lowTimeBonusLimit;
			absMidTimeBonusLimit = saleStartTime + midTimeBonusLimit;
			absHighTimeBonusLimit = saleStartTime + highTimeBonusLimit;
			totalIRCAvailable = totalSupply - totalIRCAllocated;
		} else {
			// Invalid investment period
			revert();
		}

		// Check that IRC calculated greater than zero
		assert(amountOfIRC > 0);

		// Apply Bonuses
		if (amountOfWei >= highEtherBonusLimit) {
			amountOfIRC = amountOfIRC.mul(highEtherBonusValue).div(100);
		} else if (amountOfWei >= midEtherBonusLimit) {
			amountOfIRC = amountOfIRC.mul(midEtherBonusValue).div(100);
		} else if (amountOfWei >= lowEtherBonusLimit) {
			amountOfIRC = amountOfIRC.mul(lowEtherBonusValue).div(100);
		}
		if (now >= absLowTimeBonusLimit) {
			amountOfIRC = amountOfIRC.mul(lowTimeBonusValue).div(100);
		} else if (now >= absMidTimeBonusLimit) {
			amountOfIRC = amountOfIRC.mul(midTimeBonusValue).div(100);
		} else if (now >= absHighTimeBonusLimit) {
			amountOfIRC = amountOfIRC.mul(highTimeBonusValue).div(100);
		}

		// Max sure it doesn't exceed remaining supply
		assert(amountOfIRC <= totalIRCAvailable);

		// Update total IRC balance
		totalIRCAllocated = totalIRCAllocated + amountOfIRC;

		// Update user IRC balance
		uint256 balanceSafe = balances[msg.sender].add(amountOfIRC);
		balances[msg.sender] = balanceSafe;

		// Update total WEI Invested
		totalWEIInvested = totalWEIInvested.add(amountOfWei);

		// Update total WEI Invested by account
		uint256 contributedSafe = WEIContributed[msg.sender].add(amountOfWei);
		WEIContributed[msg.sender] = contributedSafe;

		// CHECK VALUES
		assert(totalIRCAllocated <= totalSupply);
		assert(totalIRCAllocated > 0);
		assert(balanceSafe > 0);
		assert(totalWEIInvested > 0);
		assert(contributedSafe > 0);

		// CREATE EVENT FOR SENDER
		CreatedIRC(msg.sender, amountOfIRC);
	}
	
	
	// CHANGE PARAMETERS METHODS
	function transferEther(address addressToSendTo, uint256 value) {
		require(msg.sender == ownerAddress);
		addressToSendTo;
		addressToSendTo.transfer(value) ;
	}	
	function changeAllowInvestment(bool _allowInvestment) {
		require(msg.sender == ownerAddress);
		allowInvestment = _allowInvestment;
	}
	function changeSaleTimes(uint256 _saleStartTime, uint256 _saleEndTime) {
		require(msg.sender == ownerAddress);
		saleStartTime = _saleStartTime;
		saleEndTime	= _saleEndTime;
	}
	function changeEtherBonuses(uint256 _lowEtherBonusLimit, uint256 _lowEtherBonusValue, uint256 _midEtherBonusLimit, uint256 _midEtherBonusValue, uint256 _highEtherBonusLimit, uint256 _highEtherBonusValue) {
		require(msg.sender == ownerAddress);
		lowEtherBonusLimit = _lowEtherBonusLimit;
		lowEtherBonusValue = _lowEtherBonusValue;
		midEtherBonusLimit = _midEtherBonusLimit;
		midEtherBonusValue = _midEtherBonusValue;
		highEtherBonusLimit = _highEtherBonusLimit;
		highEtherBonusValue = _highEtherBonusValue;
	}
	function changeTimeBonuses(uint256 _highTimeBonusLimit, uint256 _highTimeBonusValue, uint256 _midTimeBonusLimit, uint256 _midTimeBonusValue, uint256 _lowTimeBonusLimit, uint256 _lowTimeBonusValue) {
		require(msg.sender == ownerAddress);
		highTimeBonusLimit = _highTimeBonusLimit;
		highTimeBonusValue = _highTimeBonusValue;
		midTimeBonusLimit = _midTimeBonusLimit;
		midTimeBonusValue = _midTimeBonusValue;
		lowTimeBonusLimit = _lowTimeBonusLimit;
		lowTimeBonusValue = _lowTimeBonusValue;
	}

}