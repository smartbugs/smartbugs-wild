pragma solidity ^0.4.11;


/**
 * Math operations with safety checks
 */
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


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}


contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


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


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
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

    uint256 _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
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
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
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


/**
 * @title Kitchan Network Token
 * Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20 with the addition 
 * of ownership, a lock and issuing.
 */
contract KitchanNetworkToken is Ownable, StandardToken {

    using SafeMath for uint256;
    
	// metadata
    string public constant name = "Kitchan Network";
    string public constant symbol = "KCN";
    uint256 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 600 * (10**6) * 10**decimals; // Total 600m KCN
	uint256 public totalSale;

    // crowdsale parameters
    bool public isFinalized;              // switched to true in operational state

    // Sale period.
    uint256 public startDate;
    
    // 2017.10.10 02:00 UTC 
    uint256 public constant startIco = 1507600800;
    
    uint256 public constant tokenRatePre = 15000; // 15000 KCN tokens per 1 ETH when Pre-ICO
    uint256 public constant tokenRate1 = 13000; // 13000 KCN tokens per 1 ETH when week 1
    uint256 public constant tokenRate2 = 12000; // 12000 KCN tokens per 1 ETH when week 2
    uint256 public constant tokenRate3 = 11000; // 11000 KCN tokens per 1 ETH when week 3
    uint256 public constant tokenRate4 = 10000; // 10000 KCN tokens per 1 ETH when week 4

    uint256 public constant tokenForTeam    = 100 * (10**6) * 10**decimals;
    uint256 public constant tokenForAdvisor = 60 * (10**6) * 10**decimals;
    uint256 public constant tokenForBounty  = 20 * (10**6) * 10**decimals;
    uint256 public constant tokenForSale    = 420 * (10**6) * 10**decimals;

	// Address received Token
    address public constant ethFundAddress = 0xc73a39834a14D91eCB701aEf41F5C71A0E95fB10;      // deposit address for ETH 
	address public constant teamAddress = 0x689ab85eBFF451f661665114Abb6EF7109175F9D;
	address public constant advisorAddress = 0xe7F74ee4e03C14144936BF738c12865C489aF8A7;
	address public constant bountyAddress = 0x65E5F11D845ecb2b7104Ad163B0B957Ed14D6EEF;
  

    // constructor
    function KitchanNetworkToken() {
      	isFinalized = false;                   //controls pre through crowdsale state      	
      	totalSale = 0;
      	startDate = getCurrent();
      	balances[teamAddress] = tokenForTeam;   
      	balances[advisorAddress] = tokenForAdvisor;
      	balances[bountyAddress] = tokenForBounty;
    }

    function getCurrent() internal returns (uint256) {
        return now;
    }
    

    function getRateTime(uint256 at) internal returns (uint256) {
        if (at < (startIco)) {
            return tokenRatePre;
        } else if (at < (startIco + 7 days)) {
            return tokenRate1;
        } else if (at < (startIco + 14 days)) {
            return tokenRate2;
        } else if (at < (startIco + 21 days)) {
            return tokenRate3;
        }
        return tokenRate4;
    }
    
    // Fallback function can be used to buy tokens
    function () payable {
        buyTokens(msg.sender, msg.value);
    }
    	
    // @dev Accepts ether and creates new KCN tokens.
    function buyTokens(address sender, uint256 value) internal {
        require(!isFinalized);
        require(value > 0 ether);

        // Calculate token  to be purchased
        uint256 tokenRateNow = getRateTime(getCurrent());
      	uint256 tokens = value * tokenRateNow; // check that we're not over totals
      	uint256 checkedSupply = totalSale + tokens;
      	
       	// return money if something goes wrong
      	require(tokenForSale >= checkedSupply);  // odd fractions won't be found     	

        // Transfer
        balances[sender] += tokens;

        // Update total sale.
        totalSale = checkedSupply;

        // Forward the fund to fund collection wallet.
        ethFundAddress.transfer(value);
    }

    /// @dev Ends the funding period
    function finalize() onlyOwner {
        require(!isFinalized);
    	require(msg.sender == ethFundAddress);
    	require(tokenForSale > totalSale);
    	
        balances[ethFundAddress] += (tokenForSale - totalSale);
           	      	
      	// move to operational
      	isFinalized = true;

    }
    
}