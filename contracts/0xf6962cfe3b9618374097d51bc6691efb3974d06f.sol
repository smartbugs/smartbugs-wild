/**
*
* Inspired by FirstBlood Token - firstblood.io
*
*/

pragma solidity ^0.4.16;

/**
* @title SafeMath
* @dev Math operations with safety checks that throw on error
**/
library SafeMath {
	function mul(uint256 a, uint256 b) internal returns (uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
  	}

  	function div(uint256 a, uint256 b) internal returns (uint256) {
		uint256 c = a / b;
		return c;
  	}

	function sub(uint256 a, uint256 b) internal returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	function add(uint256 a, uint256 b) internal returns (uint256) {
		 uint256 c = a + b;
		 assert(c >= a);
		 return c;
	}
}

/**
* @title Ownable
* @dev The Ownable contract has an owner address, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
**/
contract Ownable {
	address public owner;

	/**
	* @dev The Ownable constructor sets the original 'owner' of the contract to the sender
	* account.
	**/
	function Ownable() {
		owner = msg.sender;
	}

	/**
	* @dev Throws if called by any account other than the owner.
	**/
	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	/**
	* @dev Allows the current owner to transfer control of the contract to a newOwner.
	* @param newOwner The address to transfer ownership to.
	**/
	function transferOwnership(address newOwner) onlyOwner {
		if (newOwner != address(0)) {
			owner = newOwner;
		}
	}
}

/**
* @title Pausable
* @dev Base contract which allows children to implement an emergency stop mechanism.
**/
contract Pausable is Ownable {
	event Pause();
	event Unpause();
	event PauseRefund();
	event UnpauseRefund();

	bool public paused = true;
	bool public refundPaused = true;
	// Deadline set to December 29th, 2017 at 11:59pm PST
	uint256 public durationInMinutes = 60*24*29+60*3+10;
	uint256 public dayAfterInMinutes = 60*24*30+60*3+10;
	uint256 public deadline = now + durationInMinutes * 1 minutes;
	uint256 public dayAfterDeadline = now + dayAfterInMinutes * 1 minutes;

	/**
	* @dev modifier to allow actions only when the contract IS NOT paused
	**/
	modifier whenNotPaused() {
		require(!paused);
		_;
	}

	/**
	* @dev modifier to allow actions only when the refund IS NOT paused
	**/
	modifier whenRefundNotPaused() {
		require(!refundPaused);
		_;
	}

	/**
	* @dev modifier to allow actions only when the contract IS paused
	**/
	modifier whenPaused {
		require(paused);
		_;
	}

	/**
	* @dev modifier to allow actions only when the refund IS paused
	**/
	modifier whenRefundPaused {
		require(refundPaused);
		_;
	}

	/**
	* @dev modifier to allow actions only when the crowdsale has ended
	**/
	modifier whenCrowdsaleEnded {
		require(deadline < now);
		_;
	}

	/**
	* @dev modifier to allow actions only when the crowdsale has not ended
	**/
	modifier whenCrowdsaleNotEnded {
		require(deadline >= now);
		_;
	}

	/**
	* @dev called by the owner to pause, triggers stopped state
	**/
	function pause() onlyOwner whenNotPaused returns (bool) {
		paused = true;
		Pause();
		return true;
	}

	/**
	* @dev called by the owner to pause, triggers stopped state
	**/
	function pauseRefund() onlyOwner whenRefundNotPaused returns (bool) {
		refundPaused = true;
		PauseRefund();
		return true;
	}

	/**
	* @dev called by the owner to unpause, returns to normal state
	**/
	function unpause() onlyOwner whenPaused returns (bool) {
		paused = false;
		Unpause();
		return true;
	}

	/**
	* @dev called by the owner to unpause, returns to normal state
	**/
	function unpauseRefund() onlyOwner whenRefundPaused returns (bool) {
		refundPaused = false;
		UnpauseRefund();
		return true;
	}
}

/**
* @title ERC20Basic
* @dev Simpler version of ERC20 interface
* @dev see https://github.com/ethereum/EIPs/issues/179
**/
contract ERC20Basic {
	uint256 public totalSupply;
	function balanceOf(address who) constant returns (uint256);
	function transfer(address to, uint256 value) returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
* @title Basic token
* @dev Basic version of StandardToken, with no allowances.
**/
contract BasicToken is ERC20Basic {
	using SafeMath for uint256;

	mapping(address => uint256) balances;

	/**
	* @dev transfer token for a specified address
	* @param _to The address to transfer to.
	* @param _value The amount to be transferred.
	**/
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
	**/
	function balanceOf(address _owner) constant returns (uint256 balance) {
		return balances[_owner];
	}
}

/**
* @title ERC20 interface
* @dev see https://github.com/ethereum/EIPs/issues/20
**/
contract ERC20 is ERC20Basic {
	function allowance(address owner, address spender) constant returns (uint256);
	function transferFrom(address from, address to, uint256 value) returns (bool);
	function approve(address spender, uint256 value) returns (bool);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
* @title Standard ERC20 token
*
* @dev Implementation of the basic standard token.
* @dev https://github.com/ethereum/EIPs/issues/20
* @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
**/
contract StandardToken is ERC20, BasicToken {

	mapping (address => mapping (address => uint256)) allowed;

	/**
	* @dev Transfer tokens from one address to another
	* @param _from address The address which you want to send tokens from
	* @param _to address The address which you want to transfer to
	* @param _value uint256 the amout of tokens to be transfered
	**/
	function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
		var _allowance = allowed[_from][msg.sender];

		require (_value <= _allowance);

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
	**/
	function approve(address _spender, uint256 _value) returns (bool) {
		
		/**
		* To change the approve amount you first have to reduce the addresses'
		* allowance to zero by calling 'approve(_spender, 0)' if it is not
		* already 0 to mitigate the race condition described here: 
		https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
		**/
		require((_value == 0) || (allowed[msg.sender][_spender] == 0));

		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
		return true;
	}

	/**
	* @dev Function to check the amount of tokens that an owner allowed to a spender.
	* @param _owner address The address which owns the funds.
	* @param _spender address The address which will spend the funds.
	* @return A uint256 specifing the amount of tokens still available for the spender.
	**/
	function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
		return allowed[_owner][_spender];
	}

}

/**
* @title hodlToken
* @dev All tokens are pre-assigned to the creator.
* Tokens can be transferred using 'transfer' and other
* 'StandardToken' functions.
**/
contract hodlToken is Pausable, StandardToken {

	using SafeMath for uint256;

	address public escrow = this;

	//20% Finder allocation 
	uint256 public purchasableTokens = 112000 * 10**18;
	uint256 public founderAllocation = 28000 * 10**18;

	string public name = "TeamHODL Token";
	string public symbol = "THODL";
	uint256 public decimals = 18;
	uint256 public INITIAL_SUPPLY = 140000 * 10**18;

	uint256 public RATE = 200;
	uint256 public REFUND_RATE = 200;

	/**
	* @dev Contructor that gives msg.sender all of existing tokens.
	**/
	function hodlToken() {
		totalSupply = INITIAL_SUPPLY;
		balances[msg.sender] = INITIAL_SUPPLY;
	}

	/**
	* @dev Allows the current owner to transfer control of the contract to a newOwner.
	* @param newOwner The address to transfer ownership to.
	**/
	function transferOwnership(address newOwner) onlyOwner {
		address oldOwner = owner;
		super.transferOwnership(newOwner);
		balances[newOwner] = balances[oldOwner];
		balances[oldOwner] = 0;
	}

	/**
	* @dev Allows the current owner to transfer escrowship of the contract to a escrow account.
	* @param newEscrow The address to transfer the escrow account to.
	**/
	function transferEscrowship(address newEscrow) onlyOwner {
		if (newEscrow != address(0)) {
			escrow = newEscrow;
		}
	}

	/**
	* @dev Allows the current owner to set the new total supply, to be used iff not all tokens sold during crowdsale.
	**/
	function setTotalSupply() onlyOwner whenCrowdsaleEnded {
		if (purchasableTokens > 0) {
			totalSupply = totalSupply.sub(purchasableTokens);
		}
	}

	/**
	* @dev Allows the current owner to withdraw ether funds after ICO ended.
	**/
	function cashOut() onlyOwner whenCrowdsaleEnded {
		
		/**
		* Transfer money from escrow wallet up to 1 day after ICO end.
		**/
		if (dayAfterDeadline >= now) {
			owner.transfer(escrow.balance);
		}
	}
  
	/**
	* @dev Allows owner to change the exchange rate of tokens (default 0.005 Ether)
	**/
	function setRate(uint256 rate) {

		/**
		* If break-even point has been reached (3500 Eth = 3.5*10**21 Wei),
		* rate updates to 20% of total revenue (100% of dedicated wallet after forwarding contract)
		**/
		if (escrow.balance >= 7*10**20) {

			/**
			* Rounds up to address division error
			**/
			RATE = (((totalSupply.mul(10000)).div(escrow.balance)).add(9999)).div(10000);
		}
	}
  
	/**
	* @dev Allows owner to change the refund exchange rate of tokens (default 0.005 Ether)
	* @param rate The number of tokens to release
	**/
	function setRefundRate(uint256 rate) {

		/**
		* If break-even point has been reached (3500 Eth = 3.5*10**21 Wei),
		* refund rate updates to 20% of total revenue (100% of dedicated wallet after forwarding contract)
		**/
		if (escrow.balance >= 7*10**20) {

			/**
			* Rounds up to address division error
			**/
			REFUND_RATE = (((totalSupply.mul(10000)).div(escrow.balance)).add(9999)).div(10000);
		}
	}

	/**
	* @dev fallback function
	**/
	function () payable {
		if(now <= deadline){
			buyTokens(msg.sender);
		}
	}

	/**
	* @dev function that sells available tokens
	**/
	function buyTokens(address addr) payable whenNotPaused whenCrowdsaleNotEnded {
		
		/**
		* Calculate tokens to sell and check that they are purchasable
		**/
		uint256 weiAmount = msg.value;
		uint256 tokens = weiAmount.mul(RATE);
		require(purchasableTokens >= tokens);

		/**
		* Send tokens to buyer
		**/
		purchasableTokens = purchasableTokens.sub(tokens);
		balances[owner] = balances[owner].sub(tokens);
		balances[addr] = balances[addr].add(tokens);

		Transfer(owner, addr, tokens);
	}
  
	function fund() payable {}

	function defund() onlyOwner {}

	function refund(uint256 _amount) payable whenNotPaused whenCrowdsaleEnded {

		/**
		* Calculate amount of THODL to refund
		**/
		uint256 refundTHODL = _amount.mul(10**18);
		require(balances[msg.sender] >= refundTHODL);

		/**
		* Calculate refund in wei
		**/
		uint256 weiAmount = refundTHODL.div(REFUND_RATE);
		require(this.balance >= weiAmount);

		balances[msg.sender] = balances[msg.sender].sub(refundTHODL);
		
		/**
		* The tokens are burned
		**/
		totalSupply = totalSupply.sub(refundTHODL);

		msg.sender.transfer(weiAmount);
	}
}