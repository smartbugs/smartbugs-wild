pragma solidity ^0.4.24;

// File: c:/ich/contracts/SafeMath.sol

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
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
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

// File: c:/ich/contracts/Ownable.sol

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
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: c:/ich/contracts/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

// File: c:/ich/contracts/ERC20Basic.sol

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

// File: c:/ich/contracts/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  function setCrowdsale(address tokenWallet, uint256 amount) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: C:/ich/contracts/depCrowd.sol

contract crowdsaleContract is Pausable {
  using SafeMath for uint256;

  struct Period {
    uint256 startTimestamp;
    uint256 endTimestamp;
    uint256 rate;
  }

  Period[] private periods;

  ERC20 public token;
  address public wallet;
  address public tokenWallet;
  uint256 public weiRaised;

  /**
   * @dev A purchase was made.
   * @param _purchaser Who paid for the tokens.
   * @param _value Total purchase price in weis.
   * @param _amount Amount of tokens purchased.
   */
  event TokensPurchased(address indexed _purchaser, uint256 _value, uint256 _amount);

  /**
   * @dev Constructor, takes initial parameters.
   * @param _wallet Address where collected funds will be forwarded to.
   * @param _token Address of the token being sold.
   * @param _tokenWallet Address holding the tokens, which has approved allowance to this contract.
   */
  function crowdsaleContract (address _wallet, address _token, address _tokenWallet, uint maxToken, address realOwner) public {
    require(_wallet != address(0));
    require(_token != address(0));
    require(_tokenWallet != address(0));
    transferOwnership(realOwner);
    wallet = _wallet;
    token = ERC20(_token);
    tokenWallet = _tokenWallet;
    require(token.setCrowdsale(_tokenWallet, maxToken));
  }

  /**
   * @dev Send weis, get tokens.
   */
  function () external payable {
    // Preconditions.
    require(msg.sender != address(0));
    require(isOpen());
    uint256 tokenAmount = getTokenAmount(msg.value);
    if(tokenAmount > remainingTokens()){
      revert();
    }
    weiRaised = weiRaised.add(msg.value);

    token.transferFrom(tokenWallet, msg.sender, tokenAmount);
    emit TokensPurchased(msg.sender, msg.value, tokenAmount);

    wallet.transfer(msg.value);
  }

  /**
   * @dev Add a sale period with its default rate.
   * @param _startTimestamp Beginning of this sale period.
   * @param _endTimestamp End of this sale period.
   * @param _rate Rate at which tokens are sold during this sale period.
   */
  function addPeriod(uint256 _startTimestamp, uint256 _endTimestamp, uint256 _rate) onlyOwner public {
    require(_startTimestamp != 0);
    require(_endTimestamp > _startTimestamp);
    require(_rate != 0);
    Period memory period = Period(_startTimestamp, _endTimestamp, _rate);
    periods.push(period);
  }

  /**
   * @dev Emergency function to clear all sale periods (for example in case the sale is delayed).
   */
  function clearPeriods() onlyOwner public {
    delete periods;
  }

  /**
   * @dev True while the sale is open (i.e. accepting contributions). False otherwise.
   */
  function isOpen() view public returns (bool) {
    return ((!paused) && (_getCurrentPeriod().rate != 0));
  }

  /**
   * @dev Current rate for the specified purchaser.
   * @return Custom rate for the purchaser, or current standard rate if no custom rate was whitelisted.
   */
  function getCurrentRate() public view returns (uint256 rate) {
    Period memory currentPeriod = _getCurrentPeriod();
    require(currentPeriod.rate != 0);
    rate = currentPeriod.rate;
  }

  /**
   * @dev Number of tokens that a specified address would get by sending right now
   * the specified amount.
   * @param _weiAmount Value in wei to be converted into tokens.
   * @return Number of tokens that can be purchased with the specified _weiAmount.
   */
  function getTokenAmount(uint256 _weiAmount) public view returns (uint256) {
    return _weiAmount.mul(getCurrentRate());
  }

  /**
   * @dev Checks the amount of tokens left in the allowance.
   * @return Amount of tokens remaining for sale.
   */
  function remainingTokens() public view returns (uint256) {
    return token.allowance(tokenWallet, this);
  }

  /*
   * Internal functions
   */

  /**
   * @dev Returns the current period, or null.
   */
  function _getCurrentPeriod() view internal returns (Period memory _period) {
    _period = Period(0, 0, 0);
    uint256 len = periods.length;
    for (uint256 i = 0; i < len; i++) {
      if ((periods[i].startTimestamp <= block.timestamp) && (periods[i].endTimestamp >= block.timestamp)) {
        _period = periods[i];
        break;
      }
    }
  }

}

// File: ..\contracts\cDep.sol

contract cDeployer is Ownable {
	
	address private main;

	function cMain(address nM) public onlyOwner {
		main = nM;
	}

	function deployCrowdsale(address _eWallet, address _token, address _tWallet, uint _maxToken, address reqBy) public returns (address) {
		require(msg.sender == main);
		crowdsaleContract newContract = new crowdsaleContract(_eWallet, _token, _tWallet, _maxToken, reqBy);
		return newContract;
	}

}