pragma solidity ^0.4.13;

contract ReentrancyGuard {

  /**
   * @dev We use a single lock for the whole contract.
   */
  bool private rentrancy_lock = false;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * @notice If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one nonReentrant function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and a `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    require(!rentrancy_lock);
    rentrancy_lock = true;
    _;
    rentrancy_lock = false;
  }

}

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
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract RefundVault is Ownable {
  using SafeMath for uint256;

  enum State { Active, Refunding, Closed }

  mapping (address => uint256) public deposited;
  address public wallet;
  State public state;

  event Closed();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);

  function RefundVault(address _wallet) public {
    require(_wallet != address(0));
    wallet = _wallet;
    state = State.Active;
  }

  function deposit(address investor) onlyOwner public payable {
    require(state == State.Active);
    deposited[investor] = deposited[investor].add(msg.value);
  }

  function close() onlyOwner public {
    require(state == State.Active);
    state = State.Closed;
    Closed();
    wallet.transfer(this.balance);
  }

  function enableRefunds() onlyOwner public {
    require(state == State.Active);
    state = State.Refunding;
    RefundsEnabled();
  }

  function refund(address investor) public {
    require(state == State.Refunding);
    uint256 depositedValue = deposited[investor];
    deposited[investor] = 0;
    investor.transfer(depositedValue);
    Refunded(investor, depositedValue);
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

contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

contract RenCrowdsale is Ownable, ReentrancyGuard {
    using SafeMath for uint256;

    // We have a window in the first 5hrs that permits to allocate all whitelist 
    // participants with an equal distribution => fiveHourCap = cap / whitelist participants.
    uint256 public fiveHourCap;
    uint256 public cap;
    uint256 public goal;
    uint256 public rate;


    address public wallet;
    RefundVault public vault;
    RepublicToken public token;

    uint256 public startTime;
    uint256 public endTime;
    uint256 public fiveHours;
    bool public isFinalized = false;
    uint256 public weiRaised;

    mapping(address => bool) public whitelist;
    mapping(address => uint256) public contribution;
    
    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    event TokenRelease(address indexed beneficiary, uint256 amount);
    event TokenRefund(address indexed refundee, uint256 amount);
    event Finalized();

    function RenCrowdsale(
        address _token, 
        address _wallet,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rate,
        uint256 _cap,
        uint256 _fiveHourCap,
        uint256 _goal
    ) {
        require(_startTime >= getBlockTimestamp());
        require(_endTime >= _startTime);
        require(_rate > 0);
        require(_goal > 0);
        require(_cap > 0);
        require(_wallet != 0x0);

        vault = new RefundVault(_wallet);
        token = RepublicToken(_token);
        startTime = _startTime;
        wallet = _wallet;
        endTime = _endTime;
        fiveHours = startTime + 5 * 1 hours;
        fiveHourCap = _fiveHourCap;
        rate = _rate;
        goal = _goal;
        cap = _cap;
    }

    // fallback function can be used to buy tokens
    function () external payable {
        buyTokens(msg.sender);
    }

    //low level function to buy tokens
    function buyTokens(address beneficiary) internal {
        require(beneficiary != 0x0);
        require(whitelist[beneficiary]);
        require(validPurchase());
        //derive amount in wei to buy 
        uint256 weiAmount = msg.value;

        // check if contribution is in the first 5 hours
        if (getBlockTimestamp() <= fiveHours) {
             require((contribution[beneficiary].add(weiAmount)) <= fiveHourCap);
        }
        // check if there is enough funds 
        uint256 remainingToFund = cap.sub(weiRaised);
        if (weiAmount > remainingToFund) {
            weiAmount = remainingToFund;
        }
        uint256 weiToReturn = msg.value.sub(weiAmount);
        //Forward funds to the vault 
        forwardFunds(weiAmount);
        //refund if the contribution exceed the cap
        if (weiToReturn > 0) {
            msg.sender.transfer(weiToReturn);
            TokenRefund(beneficiary, weiToReturn);
        }
        //derive how many tokens
        uint256 tokens = getTokens(weiAmount);
        //update the state of weiRaised
        weiRaised = weiRaised.add(weiAmount);
        contribution[beneficiary] = contribution[beneficiary].add(weiAmount);
     
        //Trigger the event of TokenPurchase
        TokenPurchase(
            msg.sender,
            beneficiary,
            weiAmount,
            tokens
        );
        token.transferTokens(beneficiary, tokens);
        
    }

    function getTokens(uint256 amount) internal constant returns (uint256) {
        return amount.mul(rate);
    }

    // contributors can claim refund if the goal is not reached
    function claimRefund() nonReentrant external {
        require(isFinalized);
        require(!goalReached());
        vault.refund(msg.sender);
    }

    //in case of endTime before the reach of the cap, the owner can claim the unsold tokens
    function claimUnsold() onlyOwner {
        require(endTime <= getBlockTimestamp());
        uint256 unsold = token.balanceOf(this);

        if (unsold > 0) {
            require(token.transferTokens(msg.sender, unsold));
        }
    }

    // add/remove to whitelist array of addresses based on boolean status
    function updateWhitelist(address[] addresses, bool status) public onlyOwner {
        for (uint256 i = 0; i < addresses.length; i++) {
            address contributorAddress = addresses[i];
            whitelist[contributorAddress] = status;
        }
    }

    //Only owner can manually finalize the sale
    function finalize() onlyOwner {
        require(!isFinalized);
        require(hasEnded());

        if (goalReached()) {
            //Close the vault
            vault.close();
            //Unpause the token 
            token.unpause();
            //give ownership back to deployer
            token.transferOwnership(owner);
        } else {
            //else enable refunds
            vault.enableRefunds();
        }
        //update the sate of isFinalized
        isFinalized = true;
        //trigger and emit the event of finalization
        Finalized();
    } 

    // send ether to the fund collection wallet, the vault in this case
    function forwardFunds(uint256 weiAmount) internal {
        vault.deposit.value(weiAmount)(msg.sender);
    }

    // @return true if crowdsale event has ended or cap reached
    function hasEnded() public constant returns (bool) {
        bool passedEndTime = getBlockTimestamp() > endTime;
        return passedEndTime || capReached();
    }

    function capReached() public constant returns (bool) {
        return weiRaised >= cap;
    }

    function goalReached() public constant returns (bool) {
        return weiRaised >= goal;
    }

    function isWhitelisted(address contributor) public constant returns (bool) {
        return whitelist[contributor];
    }

    // @return true if the transaction can buy tokens
    function validPurchase() internal constant returns (bool) {
        bool withinPeriod = getBlockTimestamp() >= startTime && getBlockTimestamp() <= endTime;
        bool nonZeroPurchase = msg.value != 0;
        bool capNotReached = weiRaised < cap;
        return withinPeriod && nonZeroPurchase && capNotReached;
    }

    function getBlockTimestamp() internal constant returns (uint256) {
        return block.timestamp;
    }
}

contract RepublicToken is PausableToken, BurnableToken {

    string public constant name = "Republic Token";
    string public constant symbol = "REN";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 1000000000 * 10**uint256(decimals);
    
    /**
     * @notice The RepublicToken Constructor.
     */
    function RepublicToken() {
        totalSupply = INITIAL_SUPPLY;   
        balances[msg.sender] = INITIAL_SUPPLY;
    }

    function transferTokens(address beneficiary, uint256 amount) onlyOwner returns (bool) {
        require(amount > 0);

        balances[owner] = balances[owner].sub(amount);
        balances[beneficiary] = balances[beneficiary].add(amount);
        Transfer(owner, beneficiary, amount);

        return true;
    }
}