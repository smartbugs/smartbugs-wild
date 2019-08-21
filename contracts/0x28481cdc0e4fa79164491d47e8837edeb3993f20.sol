pragma solidity ^0.4.13;

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

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


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
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

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
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
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

contract BurnableToken is StandardToken {

    event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value > 0);
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
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

contract TssToken is MintableToken, BurnableToken {
    string public constant name = "TssToken";
    string public constant symbol = "TSS";
    uint256 public constant decimals = 18;

    function TssToken(address initialAccount, uint256 initialBalance) public {
        balances[initialAccount] = initialBalance;
        totalSupply = initialBalance;
  }
}

contract Crowdsale {
  using SafeMath for uint256;

  // The token being sold
  MintableToken public token;

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
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  event Debug(bytes32 text, uint256);

  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != 0x0);

    token = createTokenContract();
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
  }


  // fallback function can be used to buy tokens
  function () payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }


}

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
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

contract TssCrowdsale is Crowdsale, Pausable {
    enum LifecycleStage {
    DEPLOYMENT,
    MINTING,
    PRESALE,
    CROWDSALE_PHASE_1,
    CROWDSALE_PHASE_2,
    CROWDSALE_PHASE_3,
    POSTSALE
    }

    uint256 public CROWDSALE_PHASE_1_START;

    uint256 public CROWDSALE_PHASE_2_START;

    uint256 public CROWDSALE_PHASE_3_START;

    uint256 public POSTSALE_START;

    address public FOUNDER_WALLET;

    address public BOUNTY_WALLET;

    address public FUTURE_WALLET;

    address public CROWDSALE_WALLET;

    address public PRESALE_WALLET;

    address PROCEEDS_WALLET;


    LifecycleStage public currentStage;

    function assertValidParameters() internal {
        require(CROWDSALE_PHASE_1_START > 0);
        require(CROWDSALE_PHASE_2_START > 0);
        require(CROWDSALE_PHASE_3_START > 0);
        require(POSTSALE_START > 0);

        require(address(FOUNDER_WALLET) != 0);
        require(address(BOUNTY_WALLET) != 0);
        require(address(FUTURE_WALLET) != 0);
    }

    /**
     * Used for forcing ensureStage modifier
     */
    function setCurrentStage() onlyOwner ensureStage returns (bool) {
        return true;
    }

    modifier ensureStage() {
        if (token.mintingFinished()) {
            if (now < CROWDSALE_PHASE_1_START) {currentStage = LifecycleStage.PRESALE;}
            else if (now < CROWDSALE_PHASE_2_START) {currentStage = LifecycleStage.CROWDSALE_PHASE_1;}
            else if (now < CROWDSALE_PHASE_3_START) {currentStage = LifecycleStage.CROWDSALE_PHASE_2;}
            else if (now < POSTSALE_START) {currentStage = LifecycleStage.CROWDSALE_PHASE_3;}
            else {currentStage = LifecycleStage.POSTSALE;}
        }
        _;
    }

    function getCurrentRate() constant returns (uint _rate) {

        if (currentStage == LifecycleStage.CROWDSALE_PHASE_1) {_rate = 1150;}
        else if (currentStage == LifecycleStage.CROWDSALE_PHASE_2) {_rate = 1100;}
        else if (currentStage == LifecycleStage.CROWDSALE_PHASE_3) {_rate = 1050;}
        else {_rate == 0;}

        return _rate;
    }

    function TssCrowdsale(
    uint256 _rate,
    address _wallet,

    uint256 _phase_1_start,
    uint256 _phase_2_start,
    uint256 _phase_3_start,
    uint256 _postsale_start,

    address _founder_wallet,
    address _bounty_wallet,
    address _future_wallet,
    address _presale_wallet)

    public
    Crowdsale(_phase_1_start, _postsale_start, _rate, _wallet)
    {
        // Initialise date milestones
        CROWDSALE_PHASE_1_START = _phase_1_start;
        CROWDSALE_PHASE_2_START = _phase_2_start;
        CROWDSALE_PHASE_3_START = _phase_3_start;
        POSTSALE_START = _postsale_start;

        // Initialise Wallet Addresses

        FOUNDER_WALLET = _founder_wallet;
        BOUNTY_WALLET = _bounty_wallet;
        FUTURE_WALLET = _future_wallet;
        PRESALE_WALLET = _presale_wallet;

        CROWDSALE_WALLET = address(this);

        assertValidParameters();

        // Mint Tokens
        currentStage = LifecycleStage.MINTING;
        mintTokens();
        token.finishMinting();

        currentStage = LifecycleStage.PRESALE;
    }

    function mintTokens() internal {

        /**  Token Initial Distribution
         *   100 000 000 to founder wallet
         *   25 000 000 to bounty wallet
         *   275 000 000 to future wallet
         *   97 000 000 to crowdsale wallet
         *   3 000 000 to presale wallet
         */

        TssToken _token = TssToken(token);
        token.mint(FOUNDER_WALLET, 100000000 * 10 ** _token.decimals());
        token.mint(BOUNTY_WALLET, 25000000 * 10 ** _token.decimals());
        token.mint(FUTURE_WALLET, 275000000 * 10 ** _token.decimals());
        token.mint(CROWDSALE_WALLET, 97000000 * 10 ** _token.decimals());
        token.mint(PRESALE_WALLET, 3000000 * 10 ** _token.decimals());
    }

    /**
     * Overrides Crowdsale.buyTokens()
     */
    function buyTokens(address beneficiary) public
    payable
    whenNotPaused()
    ensureStage()
    {
        require(beneficiary != 0x0);
        require(validPurchase());

        uint256 weiAmount = msg.value;

        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(getCurrentRate());

        // update state
        weiRaised = weiRaised.add(weiAmount);

        token.transfer(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardFunds();
    }

    /**
      * Overrides Crowdsale.validPurchase()
     */
    function validPurchase() internal constant returns (bool) {
        bool withinPeriod = currentStage >= LifecycleStage.CROWDSALE_PHASE_1 && currentStage <= LifecycleStage.CROWDSALE_PHASE_3;
        bool minimumPurchase = msg.value > 0.01 ether;
        return withinPeriod && minimumPurchase;
    }

    /**
    * Overrides Crowdsale.createTokenContract()
    */
    function createTokenContract() internal returns (MintableToken) {
        return new TssToken(0x0, 0);
    }

    event CoinsRetrieved(address indexed recipient, uint amount);    

    function retrieveRemainingCoinsPostSale() 
        public
        onlyOwner 
        ensureStage() 
    {
        require(currentStage == LifecycleStage.POSTSALE);

        uint coinBalance = token.balanceOf(CROWDSALE_WALLET);
        token.transfer(FUTURE_WALLET, coinBalance);
        CoinsRetrieved(FUTURE_WALLET, coinBalance);
    }

    /** 
        There shouldn't be any funds trapped in this contract 
        but as a failsafe if there are any funds whatsoever, this function exists
     */
    function retrieveFunds() 
        public
        onlyOwner
    {
        owner.transfer(this.balance);
    }

}