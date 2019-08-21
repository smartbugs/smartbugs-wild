pragma solidity ^0.4.13;

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

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
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

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

contract STEAK is StandardToken {

    uint256 public initialSupply;
    // the original supply, just for posterity, since totalSupply
    //  will decrement on burn

    string public constant name   = "$TEAK";
    string public constant symbol = "$TEAK";
    // ^ whether or not to include the `$` here will probably be contested
    //   but it's more important to me that the joke is obvious, even if it's overdone
    //   by displaying as `$$TEAK`
    uint8 public constant decimals = 18;
    //  (^ can we please get around to standardizing on 18 decimals?)

    address public tokenSaleContract;

    modifier validDestination(address to)
    {
        require(to != address(this));
        _;
    }

    function STEAK(uint tokenTotalAmount)
    public
    {
        initialSupply = tokenTotalAmount * (10 ** uint256(decimals));
        totalSupply = initialSupply;

        // Mint all tokens to crowdsale.
        balances[msg.sender] = totalSupply;
        Transfer(address(0x0), msg.sender, totalSupply);

        tokenSaleContract = msg.sender;
    }

    /**
     * @dev override transfer token for a specified address to add validDestination
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint _value)
        public
        validDestination(_to)
        returns (bool)
    {
        return super.transfer(_to, _value);
    }

    /**
     * @dev override transferFrom token for a specified address to add validDestination
     * @param _from The address to transfer from.
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transferFrom(address _from, address _to, uint _value)
        public
        validDestination(_to)
        returns (bool)
    {
        return super.transferFrom(_from, _to, _value);
    }

    event Burn(address indexed _burner, uint _value);

    /**
     * @dev burn tokens
     * @param _value The amount to be burned.
     * @return always true (necessary in case of override)
     */
    function burn(uint _value)
        public
        returns (bool)
    {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(msg.sender, _value);
        Transfer(msg.sender, address(0x0), _value);
        return true;
    }

    /**
     * @dev burn tokens on the behalf of someone
     * @param _from The address of the owner of the token.
     * @param _value The amount to be burned.
     * @return always true (necessary in case of override)
     */
    function burnFrom(address _from, uint256 _value)
        public
        returns(bool)
    {
        assert(transferFrom(_from, msg.sender, _value));
        return burn(_value);
    }
}

contract StandardCrowdsale {
    using SafeMath for uint256;

    // The token being sold
    StandardToken public token; // Request Modification : change to not mintable

    // start and end timestamps where investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    // address where funds are collected
    address public wallet;

    // how many token units a buyer gets per wei
    uint256 public rate;

    // amount of raised money in wei
    uint256 public weiRaised;

    /**
     * event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);

    function StandardCrowdsale(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate,
        address _wallet)
        public
    {
        // require(_startTime >= now); // Steak Network Modification
        require(_endTime >= _startTime);
        require(_rate > 0);
        require(_wallet != 0x0);

        startTime = _startTime;
        endTime = _endTime;
        rate = _rate;
        wallet = _wallet;

        token = createTokenContract(); // Request Modification : change to StandardToken + position
    }

    // creates the token to be sold.
    // Request Modification : change to StandardToken
    // override this method to have crowdsale of a specific mintable token.
    function createTokenContract()
        internal
        returns(StandardToken)
    {
        return new StandardToken();
    }

    // fallback function can be used to buy tokens
    function ()
        public
        payable
    {
        buyTokens();
    }

    // low level token purchase function
    // Request Modification : change to not mint but transfer from this contract
    function buyTokens()
        public
        payable
    {
        require(validPurchase());

        uint256 weiAmount = msg.value;

        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate);

        // update state
        weiRaised = weiRaised.add(weiAmount);

        require(token.transfer(msg.sender, tokens)); // Request Modification : changed here - tranfer instead of mintable
        TokenPurchase(msg.sender, weiAmount, tokens);

        forwardFunds();
    }

    // send ether to the fund collection wallet
    // override to create custom fund forwarding mechanisms
    function forwardFunds()
        internal
    {
        wallet.transfer(msg.value);
    }

    // @return true if the transaction can buy tokens
    function validPurchase()
        internal
        returns(bool)
    {
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = msg.value != 0;
        return withinPeriod && nonZeroPurchase;
    }

    // @return true if crowdsale event has ended
    function hasEnded()
        public
        constant
        returns(bool)
    {
        return now > endTime;
    }

    modifier onlyBeforeSale() {
        require(now < startTime);
        _;
    }
}

contract CappedCrowdsale is StandardCrowdsale {
  using SafeMath for uint256;

  uint256 public cap;

  function CappedCrowdsale(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  // Request Modification : delete constant because needed in son contract
  function validPurchase() internal returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap;
  }

  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }

}

contract InfiniteCappedCrowdsale is StandardCrowdsale, CappedCrowdsale {
    using SafeMath for uint256;

    /**
        @param _cap the maximum number of tokens
        @param _rate tokens per wei received
        @param _wallet the wallet that receives the funds
     */
    function InfiniteCappedCrowdsale(uint256 _cap, uint256 _rate, address _wallet)
        CappedCrowdsale(_cap)
        StandardCrowdsale(0, uint256(int256(-1)), _rate, _wallet)
        public
    {

    }
}

contract ICS is InfiniteCappedCrowdsale {

    uint256 public constant TOTAL_SUPPLY = 975220000000;
    uint256 public constant ARBITRARY_VALUATION_IN_ETH = 33;
    // ^ arbitrary valuation of ~$10k
    uint256 public constant ETH_TO_WEI = (10 ** 18);
    uint256 public constant TOKEN_RATE = (TOTAL_SUPPLY / ARBITRARY_VALUATION_IN_ETH);
    // 29552121212 $TEAK per wei


    function ICS(address _wallet)
        InfiniteCappedCrowdsale(ARBITRARY_VALUATION_IN_ETH * ETH_TO_WEI, TOKEN_RATE, _wallet)
        public
    {

    }

    function createTokenContract() internal returns (StandardToken) {
        return new STEAK(TOTAL_SUPPLY);
    }
}