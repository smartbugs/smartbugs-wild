pragma solidity ^0.4.11;


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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
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

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
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
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


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
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue)
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue)
    returns (bool success) {
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

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

/**
 * @title SetherToken
 * @dev Sether ERC20 Token that can be minted.
 * It is meant to be used in sether crowdsale contract.
 */
contract SetherToken is MintableToken {

    string public constant name = "Sether";
    string public constant symbol = "SETH";
    uint8 public constant decimals = 18;

    function getTotalSupply() public returns (uint256) {
        return totalSupply;
    }
}

/**
 * @title SetherBaseCrowdsale
 * @dev SetherBaseCrowdsale is a base contract for managing a sether token crowdsale.
 */
contract SetherBaseCrowdsale {
    using SafeMath for uint256;

    // The token being sold
    SetherToken public token;

    // start and end timestamps where investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    // address where funds are collected
    address public wallet;

    // how many finney per token
    uint256 public rate;

    // amount of raised money in wei
    uint256 public weiRaised;

    /**
    * event for token purchase logging
    * @param purchaser who paid for the tokens
    * @param beneficiary who got the tokens
    * @param value weis paid for purchase
    * @param amount amount of tokens purchased
    */
    event SethTokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    function SetherBaseCrowdsale(uint256 _rate, address _wallet) {
        require(_rate > 0);
        require(_wallet != address(0));

        token = createTokenContract();
        rate = _rate;
        wallet = _wallet;
    }

    // fallback function can be used to buy tokens
    function () payable {
        buyTokens(msg.sender);
    }

    // low level token purchase function
    function buyTokens(address beneficiary) public payable {
        require(beneficiary != address(0));
        require(validPurchase());

        uint256 weiAmount = msg.value;

        // calculate token amount to be created
        uint256 tokens = computeTokens(weiAmount);

        require(isWithinTokenAllocLimit(tokens));

        // update state
        weiRaised = weiRaised.add(weiAmount);

        token.mint(beneficiary, tokens);

        SethTokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardFunds();
    }

    // @return true if crowdsale event has ended
    function hasEnded() public constant returns (bool) {
        return now > endTime;
    }

    // @return true if crowdsale event has started
    function hasStarted() public constant returns (bool) {
        return now < startTime;
    }

    // send ether to the fund collection wallet
    function forwardFunds() internal {
        wallet.transfer(msg.value);
    }

    // @return true if the transaction can buy tokens
    function validPurchase() internal constant returns (bool) {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = msg.value != 0;
        return withinPeriod && nonZeroPurchase;
    }
    
    //Override this method with token distribution strategy
    function computeTokens(uint256 weiAmount) internal returns (uint256) {
        //To be overriden
    }

    //Override this method with token limitation strategy
    function isWithinTokenAllocLimit(uint256 _tokens) internal returns (bool) {
        //To be overriden
    }
    
    // creates the token to be sold.
    function createTokenContract() internal returns (SetherToken) {
        return new SetherToken();
    }
}

/**
 * @title SetherMultiStepCrowdsale
 * @dev Multi-step payment policy contract that extends SetherBaseCrowdsale
 */
contract SetherMultiStepCrowdsale is SetherBaseCrowdsale {
    uint256 public constant PRESALE_LIMIT = 25 * (10 ** 6) * (10 ** 18);
    uint256 public constant CROWDSALE_LIMIT = 55 * (10 ** 6) * (10 ** 18);
    
    uint256 public constant PRESALE_BONUS_LIMIT = 1 * (10 ** 17);

    // Presale period (includes holidays)
    uint public constant PRESALE_PERIOD = 53 days;
    // Crowdsale first week period (constants for proper testing)
    uint public constant CROWD_WEEK1_PERIOD = 7 days;
    // Crowdsale second week period
    uint public constant CROWD_WEEK2_PERIOD = 7 days;
    //Crowdsale third week period
    uint public constant CROWD_WEEK3_PERIOD = 7 days;
    //Crowdsale last week period
    uint public constant CROWD_WEEK4_PERIOD = 7 days;

    uint public constant PRESALE_BONUS = 40;
    uint public constant CROWD_WEEK1_BONUS = 25;
    uint public constant CROWD_WEEK2_BONUS = 20;
    uint public constant CROWD_WEEK3_BONUS = 10;

    uint256 public limitDatePresale;
    uint256 public limitDateCrowdWeek1;
    uint256 public limitDateCrowdWeek2;
    uint256 public limitDateCrowdWeek3;

    function SetherMultiStepCrowdsale() {

    }

    function isWithinPresaleTimeLimit() internal returns (bool) {
        return now <= limitDatePresale;
    }

    function isWithinCrowdWeek1TimeLimit() internal returns (bool) {
        return now <= limitDateCrowdWeek1;
    }

    function isWithinCrowdWeek2TimeLimit() internal returns (bool) {
        return now <= limitDateCrowdWeek2;
    }

    function isWithinCrowdWeek3TimeLimit() internal returns (bool) {
        return now <= limitDateCrowdWeek3;
    }

    function isWithinCrodwsaleTimeLimit() internal returns (bool) {
        return now <= endTime && now > limitDatePresale;
    }

    function isWithinPresaleLimit(uint256 _tokens) internal returns (bool) {
        return token.getTotalSupply().add(_tokens) <= PRESALE_LIMIT;
    }

    function isWithinCrowdsaleLimit(uint256 _tokens) internal returns (bool) {
        return token.getTotalSupply().add(_tokens) <= CROWDSALE_LIMIT;
    }

    function validPurchase() internal constant returns (bool) {
        return super.validPurchase() &&
                 !(isWithinPresaleTimeLimit() && msg.value < PRESALE_BONUS_LIMIT);
    }

    function isWithinTokenAllocLimit(uint256 _tokens) internal returns (bool) {
        return (isWithinPresaleTimeLimit() && isWithinPresaleLimit(_tokens)) ||
                        (isWithinCrodwsaleTimeLimit() && isWithinCrowdsaleLimit(_tokens));
    }

    function computeTokens(uint256 weiAmount) internal returns (uint256) {
        uint256 appliedBonus = 0;
        if (isWithinPresaleTimeLimit()) {
            appliedBonus = PRESALE_BONUS;
        } else if (isWithinCrowdWeek1TimeLimit()) {
            appliedBonus = CROWD_WEEK1_BONUS;
        } else if (isWithinCrowdWeek2TimeLimit()) {
            appliedBonus = CROWD_WEEK2_BONUS;
        } else if (isWithinCrowdWeek3TimeLimit()) {
            appliedBonus = CROWD_WEEK3_BONUS;
        }

        return weiAmount.mul(10).mul(100 + appliedBonus).div(rate);
    }
}

/**
 * @title SetherCappedCrowdsale
 * @dev Extension of SetherBaseCrowdsale with a max amount of funds raised
 */
contract SetherCappedCrowdsale is SetherMultiStepCrowdsale {
    using SafeMath for uint256;

    uint256 public constant HARD_CAP = 55 * (10 ** 6) * (10 ** 18);

    function SetherCappedCrowdsale() {
        
    }

    // overriding SetherBaseCrowdsale#validPurchase to add extra cap logic
    // @return true if investors can buy at the moment
    function validPurchase() internal constant returns (bool) {
        bool withinCap = weiRaised.add(msg.value) <= HARD_CAP;

        return super.validPurchase() && withinCap;
    }

    // overriding Crowdsale#hasEnded to add cap logic
    // @return true if crowdsale event has ended
    function hasEnded() public constant returns (bool) {
        bool capReached = weiRaised >= HARD_CAP;
        return super.hasEnded() || capReached;
    }
}

/**
 * @title SetherStartableCrowdsale
 * @dev Extension of SetherBaseCrowdsale where an owner can start the crowdsale
 */
contract SetherStartableCrowdsale is SetherBaseCrowdsale, Ownable {
  using SafeMath for uint256;

  bool public isStarted = false;

  event SetherStarted();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function start() onlyOwner public {
    require(!isStarted);
    require(!hasStarted());

    starting();
    SetherStarted();

    isStarted = true;
  }

  /**
   * @dev Can be overridden to add start logic. The overriding function
   * should call super.starting() to ensure the chain of starting is
   * executed entirely.
   */
  function starting() internal {
    //To be overriden
  }
}

/**
 * @title SetherFinalizableCrowdsale
 * @dev Extension of SetherBaseCrowdsale where an owner can do extra work
 * after finishing.
 */
contract SetherFinalizableCrowdsale is SetherBaseCrowdsale, Ownable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event SetherFinalized();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() onlyOwner public {
    require(!isFinalized);
    require(hasEnded());

    finalization();
    SetherFinalized();

    isFinalized = true;
  }

  /**
   * @dev Can be overridden to add finalization logic. The overriding function
   * should call super.finalization() to ensure the chain of finalization is
   * executed entirely.
   */
  function finalization() internal {
    //To be overriden
  }
}

/**
 * @title SetherCrowdsale
 * @dev This is Sether's crowdsale contract.
 */
contract SetherCrowdsale is SetherCappedCrowdsale, SetherStartableCrowdsale, SetherFinalizableCrowdsale {

    function SetherCrowdsale(uint256 rate, address _wallet) 
        SetherCappedCrowdsale()
        SetherFinalizableCrowdsale()
        SetherStartableCrowdsale()
        SetherMultiStepCrowdsale()
        SetherBaseCrowdsale(rate, _wallet) 
    {
   
    }

    function starting() internal {
        super.starting();
        startTime = now;
        limitDatePresale = startTime + PRESALE_PERIOD;
        limitDateCrowdWeek1 = limitDatePresale + CROWD_WEEK1_PERIOD; 
        limitDateCrowdWeek2 = limitDateCrowdWeek1 + CROWD_WEEK2_PERIOD; 
        limitDateCrowdWeek3 = limitDateCrowdWeek2 + CROWD_WEEK3_PERIOD;         
        endTime = limitDateCrowdWeek3 + CROWD_WEEK4_PERIOD;
    }

    function finalization() internal {
        super.finalization();
        uint256 ownerShareTokens = token.getTotalSupply().mul(9).div(11);

        token.mint(wallet, ownerShareTokens);
    }
}