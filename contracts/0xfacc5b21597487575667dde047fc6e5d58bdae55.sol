pragma solidity ^0.4.15;

contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract Pausable is Ownable {
  bool public stopped;

  modifier stopInEmergency {
    require(!stopped);
    _;
  }
  
  modifier onlyInEmergency {
    require(stopped);
    _;
  }

  // called by the owner on emergency, triggers stopped state
  function emergencyStop() external onlyOwner {
    stopped = true;
  }

  // called by the owner on end of emergency, returns to normal state
  function release() external onlyOwner onlyInEmergency {
    stopped = false;
  }

}

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

contract PullPayment {
  using SafeMath for uint256;

  mapping(address => uint256) public payments;
  uint256 public totalPayments;

  /**
  * @dev Called by the payer to store the sent amount as credit to be pulled.
  * @param dest The destination address of the funds.
  * @param amount The amount to transfer.
  */
  function asyncSend(address dest, uint256 amount) internal {
    payments[dest] = payments[dest].add(amount);
    totalPayments = totalPayments.add(amount);
  }

  /**
  * @dev withdraw accumulated balance, called by payee.
  */
  function withdrawPayments() {
    address payee = msg.sender;
    uint256 payment = payments[payee];

    require(payment != 0);
    require(this.balance >= payment);

    totalPayments = totalPayments.sub(payment);
    payments[payee] = 0;

    assert(payee.send(payment));
  }
}

contract Crowdsale is Pausable, PullPayment {

    using SafeMath for uint;

  	struct Backer {
		uint weiReceived; // Amount of Ether given
		uint256 coinSent;
	}


	/*
	* Constants
	*/
	/* Minimum number of DARFtoken to sell */
	uint public constant MIN_CAP = 100000 ether; // 100,000 DARFtokens

	/* Maximum number of DARFtoken to sell */
	uint public constant MAX_CAP = 8000000 ether; // 8,000,000 DARFtokens

	/* Minimum amount to BUY */
	uint public constant MIN_BUY_ETHER = 100 finney;

    /*
    If backer buy over 1 000 000 DARF (2000 Ether) he/she can clame to become an investor after signing additional agreement with KYC procedure and get 1% of project profit per every 1 000 000 DARF
    */
    struct Potential_Investor {
		uint weiReceived; // Amount of Ether given
		uint256 coinSent;
        uint  profitshare; // Amount of Ether given
    }
    uint public constant MIN_INVEST_BUY = 2000 ether;

    /* But only 49%  of profit can be distributed this way for bakers who will be first
    */

    uint  public  MAX_INVEST_SHARE = 4900; //  4900 from 10000 is 49%, becouse Soliditi stil don't support fixed

/* Crowdsale period */
	uint private constant CROWDSALE_PERIOD = 62 days;

	/* Number of DARFtokens per Ether */
	uint public constant COIN_PER_ETHER = 500; // 500 DARF per ether

	uint public constant BIGSELL = COIN_PER_ETHER * 100 ether; // when 1 buy is over 50000 DARF (or 100 ether), in means additional bonus 30%


	/*
	* Variables
	*/
	/* DARFtoken contract reference */
	DARFtoken public coin;

    /* Multisig contract that will receive the Ether */
	address public multisigEther;

	/* Number of Ether received */
	uint public etherReceived;

	/* Number of DARFtokens sent to Ether contributors */
	uint public coinSentToEther;

	/* Number of DARFtokens sent to potential investors */
	uint public invcoinSentToEther;


	/* Crowdsale start time */
	uint public startTime;

	/* Crowdsale end time */
	uint public endTime;

 	/* Is crowdsale still on going */
	bool public crowdsaleClosed;

	/* Backers Ether indexed by their Ethereum address */
	mapping(address => Backer) public backers;

    mapping(address => Potential_Investor) public Potential_Investors; // list of potential investors


	/*
	* Modifiers
	*/
	modifier minCapNotReached() {
		require(!((now < endTime) || coinSentToEther >= MIN_CAP ));
		_;
	}

	modifier respectTimeFrame() {
		require(!((now < startTime) || (now > endTime )));
		_;
	}

	/*
	 * Event
	*/
	event LogReceivedETH(address addr, uint value);
	event LogCoinsEmited(address indexed from, uint amount);
	event LogInvestshare(address indexed from, uint share);

	/*
	 * Constructor
	*/
	function Crowdsale(address _DARFtokenAddress, address _to) {
		coin = DARFtoken(_DARFtokenAddress);
		multisigEther = _to;
	}

	/*
	 * The fallback function corresponds to a donation in ETH
	 */
	function() stopInEmergency respectTimeFrame payable {
		receiveETH(msg.sender);
	}

	/*
	 * To call to start the crowdsale
	 */
	function start() onlyOwner {
		require (startTime == 0);

		startTime = now ;
		endTime =  now + CROWDSALE_PERIOD;
	}

	/*
	 *	Receives a donation in Ether
	*/
	function receiveETH(address beneficiary) internal {
		require(!(msg.value < MIN_BUY_ETHER)); // Don't accept funding under a predefined threshold
        if (multisigEther ==  beneficiary) return ; // Don't pay tokens if team refund ethers
    uint coinToSend = bonus(msg.value.mul(COIN_PER_ETHER));// Compute the number of DARFtoken to send
		require(!(coinToSend.add(coinSentToEther) > MAX_CAP));

        Backer backer = backers[beneficiary];
		coin.transfer(beneficiary, coinToSend); // Transfer DARFtokens right now

		backer.coinSent = backer.coinSent.add(coinToSend);
		backer.weiReceived = backer.weiReceived.add(msg.value); // Update the total wei collected during the crowdfunding for this backer
        multisigEther.send(msg.value);

        if (backer.weiReceived > MIN_INVEST_BUY) {

            // calculate profit share
            uint share = msg.value.mul(10000).div(MIN_INVEST_BUY); // 100 = 1% from 10000
			// compare to all profit share will LT 49%
			LogInvestshare(msg.sender,share);
			if (MAX_INVEST_SHARE > share) {

				Potential_Investor potential_investor = Potential_Investors[beneficiary];
				potential_investor.coinSent = backer.coinSent;
				potential_investor.weiReceived = backer.weiReceived; // Update the total wei collected during the crowdfunding for this potential investor
                // add share to potential_investor
				if (potential_investor.profitshare == 0 ) {
					uint startshare = potential_investor.weiReceived.mul(10000).div(MIN_INVEST_BUY);
					MAX_INVEST_SHARE = MAX_INVEST_SHARE.sub(startshare);
					potential_investor.profitshare = potential_investor.profitshare.add(startshare);
				} else {
					MAX_INVEST_SHARE = MAX_INVEST_SHARE.sub(share);
					potential_investor.profitshare = potential_investor.profitshare.add(share);
					LogInvestshare(msg.sender,potential_investor.profitshare);

				}
            }

        }

		etherReceived = etherReceived.add(msg.value); // Update the total wei collected during the crowdfunding
		coinSentToEther = coinSentToEther.add(coinToSend);

		// Send events
		LogCoinsEmited(msg.sender ,coinToSend);
		LogReceivedETH(beneficiary, etherReceived);
	}


	/*
	 *Compute the DARFtoken bonus according to the BUYment period
	 */
	function bonus(uint256 amount) internal constant returns (uint256) {
		/*
			25%in the first 15 days
			20% 16 days 18 days
			15% 19 days 21 days
			10% 22 days 24 days
			5% from 25 days to 27 days
			0% from 28 days to 42 days

			*/

		if (amount >=  BIGSELL ) {
				amount = amount.add(amount.div(10).mul(3));
		}// bonus 30% to buying  over 50000 DARF
		if (now < startTime.add(16 days)) return amount.add(amount.div(4));   // bonus 25%
		if (now < startTime.add(18 days)) return amount.add(amount.div(5));   // bonus 20%
		if (now < startTime.add(22 days)) return amount.add(amount.div(20).mul(3));   // bonus 15%
		if (now < startTime.add(25 days)) return amount.add(amount.div(10));   // bonus 10%
		if (now < startTime.add(28 days)) return amount.add(amount.div(20));   // bonus 5


		return amount;
	}

/*
 * Finalize the crowdsale, should be called after the refund period
*/
	function finalize() onlyOwner public {

		if (now < endTime) { // Cannot finalise before CROWDSALE_PERIOD or before selling all coins
			require (coinSentToEther == MAX_CAP);
		}

		require(!(coinSentToEther < MIN_CAP && now < endTime + 15 days)); // If MIN_CAP is not reached donors have 15days to get refund before we can finalise

		require(multisigEther.send(this.balance)); // Move the remaining Ether to the multisig address

		uint remains = coin.balanceOf(this);
		// No burn all of my precisiossss!
		// if (remains > 0) { // Burn the rest of DARFtokens
		//	require(coin.burn(remains)) ;
		//}
		crowdsaleClosed = true;
	}

	/*
	* Failsafe drain
	*/
	function drain() onlyOwner {
		require(owner.send(this.balance)) ;
	}

	/**
	 * Allow to change the team multisig address in the case of emergency.
	 */
	function setMultisig(address addr) onlyOwner public {
		require(addr != address(0)) ;
		multisigEther = addr;
	}

	/**
	 * Manually back DARFtoken owner address.
	 */
	function backDARFtokenOwner() onlyOwner public {
		coin.transferOwnership(owner);
	}

	/**
	 * Transfer remains to owner in case if impossible to do min BUY
	 */
	function getRemainCoins() onlyOwner public {
		var remains = MAX_CAP - coinSentToEther;
		uint minCoinsToSell = bonus(MIN_BUY_ETHER.mul(COIN_PER_ETHER) / (1 ether));

		require(!(remains > minCoinsToSell));

		Backer backer = backers[owner];
		coin.transfer(owner, remains); // Transfer DARFtokens right now

		backer.coinSent = backer.coinSent.add(remains);


        coinSentToEther = coinSentToEther.add(remains);

		// Send events
		LogCoinsEmited(this ,remains);
		LogReceivedETH(owner, etherReceived);
	}


	/*
  	 * When MIN_CAP is not reach:
  	 * 1) backer call the "approve" function of the DARFtoken token contract with the amount of all DARFtokens they got in order to be refund
  	 * 2) backer call the "refund" function of the Crowdsale contract with the same amount of DARFtokens
   	 * 3) backer call the "withdrawPayments" function of the Crowdsale contract to get a refund in ETH
   	 */
	function refund(uint _value) minCapNotReached public {

		require (_value == backers[msg.sender].coinSent) ; // compare value from backer balance

		coin.transferFrom(msg.sender, address(this), _value); // get the token back to the crowdsale contract
		// No burn all of my precisiossss!
		//require (coin.burn(_value)); // token sent for refund are burnt

		uint ETHToSend = backers[msg.sender].weiReceived;
		backers[msg.sender].weiReceived=0;

		if (ETHToSend > 0) {
			asyncSend(msg.sender, ETHToSend); // pull payment to get refund in ETH
		}
	}

}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
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
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

contract DARFtoken is StandardToken, Ownable {
  string public constant name = "DARFtoken";
  string public constant symbol = "DAR";
  uint public constant decimals = 18;


  // Constructor
  function DARFtoken() {
      totalSupply = 84000000 ether; // to make right number  84 000 000
      balances[msg.sender] = totalSupply; // Send all tokens to owner
  }

  /**
   *  Burn away the specified amount of DARFtoken tokens
   */
  function burn(uint _value) onlyOwner returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    totalSupply = totalSupply.sub(_value);
    Transfer(msg.sender, 0x0, _value);
    return true;
  }

}