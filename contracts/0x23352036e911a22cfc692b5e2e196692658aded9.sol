pragma solidity 0.4.19;

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    require(newOwner != owner);

    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract Whitelisted is Ownable {

	// variables
	mapping (address => bool) public whitelist;

	// events
	event WhitelistChanged(address indexed account, bool state);

	// modifiers

	// checkes if the address is whitelisted
	modifier isWhitelisted(address _addr) {
		require(whitelist[_addr] == true);

		_;
	}

	// methods
	function setWhitelist(address _addr, bool _state) onlyOwner external {
		require(_addr != address(0));
		require(whitelist[_addr] != _state);

		whitelist[_addr] = _state;

		WhitelistChanged(_addr, _state);
	}

}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
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
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value > 0);

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
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract BurnableToken is BasicToken {
	// events
	event Burn(address indexed burner, uint256 amount);

	// reduce sender balance and Token total supply
	function burn(uint256 _value) public {
		balances[msg.sender] = balances[msg.sender].sub(_value);
		totalSupply = totalSupply.sub(_value);

		Burn(msg.sender, _value);
	}
}

contract FriendzToken is BurnableToken, Ownable {

	// public variables
	mapping(address => uint256) public release_dates;
	mapping(address => uint256) public purchase_dates;
	mapping(address => uint256) public blocked_amounts;
	mapping (address => mapping (address => uint256)) public allowed;
	bool public free_transfer = false;
	uint256 public RELEASE_DATE = 1522540800; // 1th april 2018 00:00 UTC

	// private variables
	address private co_owner;
	address private presale_holder = 0x1ea128767610c944Ff9a60E4A1Cbd0C88773c17c;
	address private ico_holder = 0xc1c643701803eca8DDfA2017547E8441516BE047;
	address private reserved_holder = 0x26226CfaB092C89eF3D79653D692Cc1425a0B907;
	address private wallet_holder = 0xBF0B56276e90fc4f0f1e2Ec66fa418E30E717215;

	// ERC20 variables
	string public name;
	string public symbol;
	uint256 public decimals;

	// constants

	// events
	event Approval(address indexed owner, address indexed spender, uint256 value);
	event UpdatedBlockingState(address indexed to, uint256 purchase, uint256 end_date, uint256 value);
	event CoOwnerSet(address indexed owner);
	event ReleaseDateChanged(address indexed from, uint256 date);

	function FriendzToken(string _name, string _symbol, uint256 _decimals, uint256 _supply) public {
		// safety checks
		require(_decimals > 0);
		require(_supply > 0);

		// assign variables
		name = _name;
		symbol = _symbol;
		decimals = _decimals;
		totalSupply = _supply;

		// assign the total supply to the owner
		balances[owner] = _supply;
	}

	// modifiers

	// checks if the address can transfer tokens
	modifier canTransfer(address _sender, uint256 _value) {
		require(_sender != address(0));

		require(
			(free_transfer) ||
			canTransferBefore(_sender) ||
			canTransferIfLocked(_sender, _value)
	 	);

	 	_;
	}

	// check if we're in a free-transfter state
	modifier isFreeTransfer() {
		require(free_transfer);

		_;
	}

	// check if we're in non free-transfter state
	modifier isBlockingTransfer() {
		require(!free_transfer);

		_;
	}

	// functions

	function canTransferBefore(address _sender) public view returns(bool) {
		return (
			_sender == owner ||
			_sender == presale_holder ||
			_sender == ico_holder ||
			_sender == reserved_holder ||
			_sender == wallet_holder
		);
	}

	function canTransferIfLocked(address _sender, uint256 _value) public view returns(bool) {
		uint256 after_math = balances[_sender].sub(_value);
		return (
			now >= RELEASE_DATE &&
		    after_math >= getMinimumAmount(_sender)
        );
	}

	// set co-owner, can be set to 0
	function setCoOwner(address _addr) onlyOwner public {
		require(_addr != co_owner);

		co_owner = _addr;

		CoOwnerSet(_addr);
	}

	// set release date
	function setReleaseDate(uint256 _date) onlyOwner public {
		require(_date > 0);
		require(_date != RELEASE_DATE);

		RELEASE_DATE = _date;

		ReleaseDateChanged(msg.sender, _date);
	}

	// calculate the amount of tokens an address can use
	function getMinimumAmount(address _addr) constant public returns (uint256) {
		// if the address ha no limitations just return 0
		if(blocked_amounts[_addr] == 0x0)
			return 0x0;

		// if the purchase date is in the future block all the tokens
		if(purchase_dates[_addr] > now){
			return blocked_amounts[_addr];
		}

		uint256 alpha = uint256(now).sub(purchase_dates[_addr]); // absolute purchase date
		uint256 beta = release_dates[_addr].sub(purchase_dates[_addr]); // absolute token release date
		uint256 tokens = blocked_amounts[_addr].sub(alpha.mul(blocked_amounts[_addr]).div(beta)); // T - (α * T) / β

		return tokens;
	}

	// set blocking state to an address
	function setBlockingState(address _addr, uint256 _end, uint256 _value) isBlockingTransfer public {
		// only the onwer and the co-owner can call this function
		require(
			msg.sender == owner ||
			msg.sender == co_owner
		);
		require(_addr != address(0));

		uint256 final_value = _value;

		if(release_dates[_addr] != 0x0){
			// if it's not the first time this function is beign called for this address
			// update its information instead of setting them (add value to previous value)
			final_value = blocked_amounts[_addr].add(_value);
		}

		release_dates[_addr] = _end;
		purchase_dates[_addr] = RELEASE_DATE;
		blocked_amounts[_addr] = final_value;

		UpdatedBlockingState(_addr, _end, RELEASE_DATE, final_value);
	}

	// all addresses can transfer tokens now
	function freeToken() public onlyOwner {
		free_transfer = true;
	}

	// override function using canTransfer on the sender address
	function transfer(address _to, uint _value) canTransfer(msg.sender, _value) public returns (bool success) {
		return super.transfer(_to, _value);
	}

	// transfer tokens from one address to another
	function transferFrom(address _from, address _to, uint _value) canTransfer(_from, _value) public returns (bool success) {
		require(_from != address(0));
		require(_to != address(0));

	    // SafeMath.sub will throw if there is not enough balance.
	    balances[_from] = balances[_from].sub(_value);
	    balances[_to] = balances[_to].add(_value);
		allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value); // this will throw if we don't have enough allowance

	    // this event comes from BasicToken.sol
	    Transfer(_from, _to, _value);

	    return true;
	}

	// erc20 functions
  	function approve(address _spender, uint256 _value) public returns (bool) {
	 	require(_value == 0 || allowed[msg.sender][_spender] == 0);

	 	allowed[msg.sender][_spender] = _value;
	 	Approval(msg.sender, _spender, _value);

	 	return true;
  	}

	function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    	return allowed[_owner][_spender];
  	}

	/**
	* approve should be called when allowed[_spender] == 0. To increment
	* allowed value is better to use this function to avoid 2 calls (and wait until
	* the first transaction is mined)
	* From MonolithDAO Token.sol
	*/
	function increaseApproval (address _spender, uint256 _addedValue) public returns (bool success) {
		allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
		Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}

	function decreaseApproval (address _spender, uint256 _subtractedValue) public returns (bool success) {
		uint256 oldValue = allowed[msg.sender][_spender];
		if (_subtractedValue >= oldValue) {
			allowed[msg.sender][_spender] = 0;
		} else {
			allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
		}
		Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
		return true;
	}

}