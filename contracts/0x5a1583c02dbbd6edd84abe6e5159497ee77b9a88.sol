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
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

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
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

/**
 * @title Capped token
 * @dev Mintable token with a token cap.
 */

contract CappedToken is MintableToken {

  uint256 public cap;

  function CappedToken(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    require(totalSupply.add(_amount) <= cap);

    return super.mint(_to, _amount);
  }

}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {
    assert(token.transfer(to, value));
  }

  function safeTransferFrom(ERC20 token, address from, address to, uint256 value) internal {
    assert(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    assert(token.approve(spender, value));
  }
}

/**
 * @title TokenVesting
 * @dev A token holder contract that can release its token balance gradually like a
 * typical vesting scheme, with a cliff and vesting period. Optionally revocable by the
 * owner.
 */
contract TokenVesting is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for ERC20Basic;

  event Released(uint256 amount);
  event Revoked();

  // beneficiary of tokens after they are released
  address public beneficiary;

  uint256 public cliff;
  uint256 public start;
  uint256 public duration;

  bool public revocable;

  mapping (address => uint256) public released;
  mapping (address => bool) public revoked;

  /**
   * @dev Creates a vesting contract that vests its balance of any ERC20 token to the
   * _beneficiary, gradually in a linear fashion until _start + _duration. By then all
   * of the balance will have vested.
   * @param _beneficiary address of the beneficiary to whom vested tokens are transferred
   * @param _cliff duration in seconds of the cliff in which tokens will begin to vest
   * @param _duration duration in seconds of the period in which the tokens will vest
   * @param _revocable whether the vesting is revocable or not
   */
  function TokenVesting(address _beneficiary, uint256 _start, uint256 _cliff, uint256 _duration, bool _revocable) public {
    require(_beneficiary != address(0));
    require(_cliff <= _duration);

    beneficiary = _beneficiary;
    revocable = _revocable;
    duration = _duration;
    cliff = _start.add(_cliff);
    start = _start;
  }

  /**
   * @notice Transfers vested tokens to beneficiary.
   * @param token ERC20 token which is being vested
   */
  function release(ERC20Basic token) public {
    uint256 unreleased = releasableAmount(token);

    require(unreleased > 0);

    released[token] = released[token].add(unreleased);

    token.safeTransfer(beneficiary, unreleased);

    Released(unreleased);
  }

  /**
   * @notice Allows the owner to revoke the vesting. Tokens already vested
   * remain in the contract, the rest are returned to the owner.
   * @param token ERC20 token which is being vested
   */
  function revoke(ERC20Basic token) public onlyOwner {
    require(revocable);
    require(!revoked[token]);

    uint256 balance = token.balanceOf(this);

    uint256 unreleased = releasableAmount(token);
    uint256 refund = balance.sub(unreleased);

    revoked[token] = true;

    token.safeTransfer(owner, refund);

    Revoked();
  }

  /**
   * @dev Calculates the amount that has already vested but hasn't been released yet.
   * @param token ERC20 token which is being vested
   */
  function releasableAmount(ERC20Basic token) public view returns (uint256) {
    return vestedAmount(token).sub(released[token]);
  }

  /**
   * @dev Calculates the amount that has already vested.
   * @param token ERC20 token which is being vested
   */
  function vestedAmount(ERC20Basic token) public view returns (uint256) {
    uint256 currentBalance = token.balanceOf(this);
    uint256 totalBalance = currentBalance.add(released[token]);

    if (now < cliff) {
      return 0;
    } else if (now >= start.add(duration) || revoked[token]) {
      return totalBalance;
    } else {
      return totalBalance.mul(now.sub(start)).div(duration);
    }
  }
}

contract MonthlyTokenVesting is TokenVesting {

    uint256 public previousTokenVesting = 0;

    function MonthlyTokenVesting(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        bool _revocable
    ) public
    TokenVesting(_beneficiary, _start, _cliff, _duration, _revocable)
    { }


    function release(ERC20Basic token) public onlyOwner {
        require(now >= previousTokenVesting + 30 days);
        super.release(token);
        previousTokenVesting = now;
    }
}

contract CREDToken is CappedToken {
    using SafeMath for uint256;

    /**
     * Constant fields
     */

    string public constant name = "Verify Token";
    uint8 public constant decimals = 18;
    string public constant symbol = "CRED";

    /**
     * Immutable state variables
     */

    // Time when team and reserved tokens are unlocked
    uint256 public reserveUnlockTime;

    address public teamWallet;
    address public reserveWallet;
    address public advisorsWallet;

    /**
     * State variables
     */

    uint256 teamLocked;
    uint256 reserveLocked;
    uint256 advisorsLocked;

    // Are the tokens non-transferrable?
    bool public locked = true;

    // When tokens can be unfreezed.
    uint256 public unfreezeTime = 0;

    bool public unlockedReserveAndTeamFunds = false;

    MonthlyTokenVesting public advisorsVesting = MonthlyTokenVesting(address(0));

    /**
     * Events
     */

    event MintLocked(address indexed to, uint256 amount);

    event Unlocked(address indexed to, uint256 amount);

    /**
     * Modifiers
     */

    // Tokens must not be locked.
    modifier whenLiquid {
        require(!locked);
        _;
    }

    modifier afterReserveUnlockTime {
        require(now >= reserveUnlockTime);
        _;
    }

    modifier unlockReserveAndTeamOnce {
        require(!unlockedReserveAndTeamFunds);
        _;
    }

    /**
     * Constructor
     */
    function CREDToken(
        uint256 _cap,
        uint256 _yearLockEndTime,
        address _teamWallet,
        address _reserveWallet,
        address _advisorsWallet
    )
    CappedToken(_cap)
    public
    {
        require(_yearLockEndTime != 0);
        require(_teamWallet != address(0));
        require(_reserveWallet != address(0));
        require(_advisorsWallet != address(0));

        reserveUnlockTime = _yearLockEndTime;
        teamWallet = _teamWallet;
        reserveWallet = _reserveWallet;
        advisorsWallet = _advisorsWallet;
    }

    // Mint a certain number of tokens that are locked up.
    // _value has to be bounded not to overflow.
    function mintAdvisorsTokens(uint256 _value) public onlyOwner canMint {
        require(advisorsLocked == 0);
        require(_value.add(totalSupply) <= cap);
        advisorsLocked = _value;
        MintLocked(advisorsWallet, _value);
    }

    function mintTeamTokens(uint256 _value) public onlyOwner canMint {
        require(teamLocked == 0);
        require(_value.add(totalSupply) <= cap);
        teamLocked = _value;
        MintLocked(teamWallet, _value);
    }

    function mintReserveTokens(uint256 _value) public onlyOwner canMint {
        require(reserveLocked == 0);
        require(_value.add(totalSupply) <= cap);
        reserveLocked = _value;
        MintLocked(reserveWallet, _value);
    }


    /// Finalise any minting operations. Resets the owner and causes normal tokens
    /// to be frozen. Also begins the countdown for locked-up tokens.
    function finalise() public onlyOwner {
        require(reserveLocked > 0);
        require(teamLocked > 0);
        require(advisorsLocked > 0);

        advisorsVesting = new MonthlyTokenVesting(advisorsWallet, now, 92 days, 2 years, false);
        mint(advisorsVesting, advisorsLocked);
        finishMinting();

        owner = 0;
        unfreezeTime = now + 1 weeks;
    }


    // Causes tokens to be liquid 1 week after the tokensale is completed
    function unfreeze() public {
        require(unfreezeTime > 0);
        require(now >= unfreezeTime);
        locked = false;
    }


    /// Unlock any now freeable tokens that are locked up for team and reserve accounts .
    function unlockTeamAndReserveTokens() public whenLiquid afterReserveUnlockTime unlockReserveAndTeamOnce {
        require(totalSupply.add(teamLocked).add(reserveLocked) <= cap);

        totalSupply = totalSupply.add(teamLocked).add(reserveLocked);
        balances[teamWallet] = balances[teamWallet].add(teamLocked);
        balances[reserveWallet] = balances[reserveWallet].add(reserveLocked);
        teamLocked = 0;
        reserveLocked = 0;
        unlockedReserveAndTeamFunds = true;

        Transfer(address(0), teamWallet, teamLocked);
        Transfer(address(0), reserveWallet, reserveLocked);
        Unlocked(teamWallet, teamLocked);
        Unlocked(reserveWallet, reserveLocked);
    }

    function unlockAdvisorTokens() public whenLiquid {
        advisorsVesting.release(this);
    }


    /**
     * Methods overriding some OpenZeppelin functions to prevent calling them when token is not liquid.
     */

    function transfer(address _to, uint256 _value) public whenLiquid returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenLiquid returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public whenLiquid returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint256 _addedValue) public whenLiquid returns (bool) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public whenLiquid returns (bool) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }

}

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
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


  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) public {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != address(0));

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
  function () external payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
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
  function validPurchase() internal view returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }


}
/**
 * @title CappedCrowdsale
 * @dev Extension of Crowdsale with a max amount of funds raised
 */
contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public cap;

  function CappedCrowdsale(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  function validPurchase() internal view returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap;
  }

  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }

}

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

contract Tokensale is CappedCrowdsale, Pausable{
    using SafeMath for uint256;

    uint256 constant public MAX_SUPPLY = 50000000 ether;
    uint256 constant public SALE_TOKENS_SUPPLY = 11125000 ether;
    uint256 constant public INVESTMENT_FUND_TOKENS_SUPPLY = 10500000 ether;
    uint256 constant public MISCELLANEOUS_TOKENS_SUPPLY = 2875000 ether;
    uint256 constant public TEAM_TOKENS_SUPPLY = 10000000 ether;
    uint256 constant public RESERVE_TOKENS_SUPPLY = 10000000 ether;
    uint256 constant public ADVISORS_TOKENS_SUPPLY = 5500000 ether;


    uint256 public totalSold;
    uint256 public soldDuringTokensale;

    uint256 public presaleStartTime;

    mapping(address => uint256) public presaleLimit;


    modifier beforeSale() {
        require(now < startTime);
        _;
    }

    modifier duringSale() {
        require(now >= startTime && !hasEnded() && !paused);
        _;
    }

    function Tokensale(
        uint256 _presaleStartTime,
        uint256 _startTime,
        uint256 _hardCap,
        address _investmentFundWallet,
        address _miscellaneousWallet,
        address _treasury,
        address _teamWallet,
        address _reserveWallet,
        address _advisorsWallet
    )
    CappedCrowdsale(_hardCap)
    Crowdsale(_startTime, _startTime + 30 days, SALE_TOKENS_SUPPLY.div(_hardCap), _treasury)
    public
    {
        require(_startTime > _presaleStartTime);
        require(now < _presaleStartTime);

        token = new CREDToken(
            MAX_SUPPLY,
            _startTime + 1 years,
            _teamWallet,
            _reserveWallet,
            _advisorsWallet
        );
        presaleStartTime = _presaleStartTime;
        mintInvestmentFundAndMiscellaneous(_investmentFundWallet, _miscellaneousWallet);
        castedToken().mintTeamTokens(TEAM_TOKENS_SUPPLY);
        castedToken().mintReserveTokens(RESERVE_TOKENS_SUPPLY);
        castedToken().mintAdvisorsTokens(ADVISORS_TOKENS_SUPPLY);

    }

    function setHardCap(uint256 _cap) public onlyOwner {
        require(now < presaleStartTime);
        require(_cap > 0);
        cap = _cap;
        rate = SALE_TOKENS_SUPPLY.div(_cap);
    }

    // Function for setting presale buy limits for list of accounts
    function addPresaleWallets(address[] _wallets, uint256[] _weiLimit) external onlyOwner {
        require(now < startTime);
        require(_wallets.length == _weiLimit.length);
        for (uint256 i = 0; i < _wallets.length; i++) {
            presaleLimit[_wallets[i]] = _weiLimit[i];
        }
    }

    // Override to track sold tokens
    function buyTokens(address beneficiary) public payable {
        super.buyTokens(beneficiary);
        // If bought in presale, decrease limit
        if (now < startTime) {
            presaleLimit[msg.sender] = presaleLimit[msg.sender].sub(msg.value);
        }
        totalSold = totalSold.add(msg.value.mul(rate));
    }

    function finalise() public {
        require(hasEnded());
        castedToken().finalise();
    }

    function mintInvestmentFundAndMiscellaneous(
        address _investmentFundWallet,
        address _miscellaneousWallet
    ) internal {
        require(_investmentFundWallet != address(0));
        require(_miscellaneousWallet != address(0));

        token.mint(_investmentFundWallet, INVESTMENT_FUND_TOKENS_SUPPLY);
        token.mint(_miscellaneousWallet, MISCELLANEOUS_TOKENS_SUPPLY);
    }

    function castedToken() internal view returns (CREDToken) {
        return CREDToken(token);
    }

    // Overrides Crowdsale#createTokenContract not to create new token
    // CRED Token is created in the constructor
    function createTokenContract() internal returns (MintableToken) {
        return MintableToken(address(0));
    }

    function validSalePurchase() internal view returns (bool) {
        return super.validPurchase();
    }

    function validPreSalePurchase() internal view returns (bool) {
        if (msg.value > presaleLimit[msg.sender]) { return false; }
        if (weiRaised.add(msg.value) > cap) { return false; }
        if (now < presaleStartTime) { return false; }
        if (now >= startTime) { return false; }
        return true;
    }

    // Overrides CappedCrowdsale#validPurchase to check if not paused
    function validPurchase() internal view returns (bool) {
        require(!paused);
        return validSalePurchase() || validPreSalePurchase();
    }

}