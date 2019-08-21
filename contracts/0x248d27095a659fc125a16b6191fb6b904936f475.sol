pragma solidity ^0.4.24;

contract Crowdsale {
  using SafeMath for uint256;
  using SafeERC20 for ERC20;

  // The token being sold
  ERC20 public token;

  // Address where funds are collected
  address public wallet;

  // How many token units a buyer gets per wei.
  // The rate is the conversion between wei and the smallest and indivisible token unit.
  // So, if you are using a rate of 1 with a DetailedERC20 token with 3 decimals called TOK
  // 1 wei will give you 1 unit, or 0.001 TOK.
  uint256 public rate;

  // Amount of wei raised
  uint256 public weiRaised;

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );

  /**
   * @param _rate Number of token units a buyer gets per wei
   * @param _wallet Address where collected funds will be forwarded to
   * @param _token Address of the token being sold
   */
  constructor(uint256 _rate, address _wallet, ERC20 _token) public {
    require(_rate > 0);
    require(_wallet != address(0));
    require(_token != address(0));

    rate = _rate;
    wallet = _wallet;
    token = _token;
  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  function () external payable {
    buyTokens(msg.sender);
  }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param _beneficiary Address performing the token purchase
   */
  function buyTokens(address _beneficiary) public payable {

    uint256 weiAmount = msg.value;
    _preValidatePurchase(_beneficiary, weiAmount);

    // calculate token amount to be created
    uint256 tokens = _getTokenAmount(weiAmount);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    _processPurchase(_beneficiary, tokens);
    emit TokenPurchase(
      msg.sender,
      _beneficiary,
      weiAmount,
      tokens
    );

    _updatePurchasingState(_beneficiary, weiAmount);

    _forwardFunds();
    _postValidatePurchase(_beneficiary, weiAmount);
  }

  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

  /**
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use `super` in contracts that inherit from Crowdsale to extend their validations.
   * Example from CappedCrowdsale.sol's _preValidatePurchase method: 
   *   super._preValidatePurchase(_beneficiary, _weiAmount);
   *   require(weiRaised.add(_weiAmount) <= cap);
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    require(_beneficiary != address(0));
    require(_weiAmount != 0);
  }

  /**
   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
   * @param _beneficiary Address performing the token purchase
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _postValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param _beneficiary Address performing the token purchase
   * @param _tokenAmount Number of tokens to be emitted
   */
  function _deliverTokens(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    token.safeTransfer(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param _beneficiary Address receiving the tokens
   * @param _tokenAmount Number of tokens to be purchased
   */
  function _processPurchase(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    _deliverTokens(_beneficiary, _tokenAmount);
  }

  /**
   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
   * @param _beneficiary Address receiving the tokens
   * @param _weiAmount Value in wei involved in the purchase
   */
  function _updatePurchasingState(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param _weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 _weiAmount)
    internal view returns (uint256)
  {
    return _weiAmount.mul(rate);
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    wallet.transfer(msg.value);
  }
}

contract TimedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public openingTime;
  uint256 public closingTime;

  /**
   * @dev Reverts if not in crowdsale time range.
   */
  modifier onlyWhileOpen {
    // solium-disable-next-line security/no-block-members
    require(block.timestamp >= openingTime && block.timestamp <= closingTime);
    _;
  }

  /**
   * @dev Constructor, takes crowdsale opening and closing times.
   * @param _openingTime Crowdsale opening time
   * @param _closingTime Crowdsale closing time
   */
  constructor(uint256 _openingTime, uint256 _closingTime) public {
    // solium-disable-next-line security/no-block-members
    require(_openingTime >= block.timestamp);
    require(_closingTime >= _openingTime);

    openingTime = _openingTime;
    closingTime = _closingTime;
  }

  /**
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.
   * @return Whether crowdsale period has elapsed
   */
  function hasClosed() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return block.timestamp > closingTime;
  }

  /**
   * @dev Extend parent behavior requiring to be within contributing period
   * @param _beneficiary Token purchaser
   * @param _weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(
    address _beneficiary,
    uint256 _weiAmount
  )
    internal
    onlyWhileOpen
  {
    super._preValidatePurchase(_beneficiary, _weiAmount);
  }

}

contract PostDeliveryCrowdsale is TimedCrowdsale {
  using SafeMath for uint256;

  mapping(address => uint256) public balances;

  /**
   * @dev Withdraw tokens only after crowdsale ends.
   */
  function withdrawTokens() public {
    require(hasClosed());
    uint256 amount = balances[msg.sender];
    require(amount > 0);
    balances[msg.sender] = 0;
    _deliverTokens(msg.sender, amount);
  }

  /**
   * @dev Overrides parent by storing balances instead of issuing tokens right away.
   * @param _beneficiary Token purchaser
   * @param _tokenAmount Amount of tokens purchased
   */
  function _processPurchase(
    address _beneficiary,
    uint256 _tokenAmount
  )
    internal
  {
    balances[_beneficiary] = balances[_beneficiary].add(_tokenAmount);
  }

}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

library SafeERC20 {
  function safeTransfer(
    ERC20Basic _token,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transfer(_to, _value));
  }

  function safeTransferFrom(
    ERC20 _token,
    address _from,
    address _to,
    uint256 _value
  )
    internal
  {
    require(_token.transferFrom(_from, _to, _value));
  }

  function safeApprove(
    ERC20 _token,
    address _spender,
    uint256 _value
  )
    internal
  {
    require(_token.approve(_spender, _value));
  }
}

contract Oraclized is Ownable {

    address public oracle;

    constructor(address _oracle) public {
        oracle = _oracle;
    }

    /**
     * @dev Change oracle address
     * @param _oracle Oracle address
     */
    function setOracle(address _oracle) public onlyOwner {
        oracle = _oracle;
    }

    /**
     * @dev Modifier to allow access only by oracle
     */
    modifier onlyOracle() {
        require(msg.sender == oracle);
        _;
    }

    /**
     * @dev Modifier to allow access only by oracle or owner
     */
    modifier onlyOwnerOrOracle() {
        require((msg.sender == oracle) || (msg.sender == owner));
        _;
    }
}

contract KYCCrowdsale is Oraclized, PostDeliveryCrowdsale {
    using SafeMath for uint256;

    /**
     * @dev etherPriceInUsd Ether price in cents
     * @dev usdRaised Total USD raised while ICO in cents
     * @dev weiInvested Stores amount of wei invested by each user
     * @dev usdInvested Stores amount of USD invested by each user in cents
     */
    uint256 public etherPriceInUsd;
    uint256 public usdRaised;
    mapping (address => uint256) public weiInvested;
    mapping (address => uint256) public usdInvested;

    /**
     * @dev KYCPassed Registry of users who passed KYC
     * @dev KYCRequired Registry of users who has to passed KYC
     */
    mapping (address => bool) public KYCPassed;
    mapping (address => bool) public KYCRequired;

    /**
     * @dev KYCRequiredAmountInUsd Amount in cents invested starting from which user must pass KYC
     */
    uint256 public KYCRequiredAmountInUsd;

    event EtherPriceUpdated(uint256 _cents);

    /**
     * @param _kycAmountInUsd Amount in cents invested starting from which user must pass KYC
     */
    constructor(uint256 _kycAmountInUsd, uint256 _etherPrice) public {
        require(_etherPrice > 0);

        KYCRequiredAmountInUsd = _kycAmountInUsd;
        etherPriceInUsd = _etherPrice;
    }

    /**
     * @dev Update amount required to pass KYC
     * @param _cents Amount in cents invested starting from which user must pass KYC
     */
    function setKYCRequiredAmount(uint256 _cents) external onlyOwnerOrOracle {
        require(_cents > 0);

        KYCRequiredAmountInUsd = _cents;
    }

    /**
     * @dev Set ether conversion rate
     * @param _cents Price of 1 ETH in cents
     */
    function setEtherPrice(uint256 _cents) public onlyOwnerOrOracle {
        require(_cents > 0);

        etherPriceInUsd = _cents;

        emit EtherPriceUpdated(_cents);
    }

    /**
     * @dev Check if KYC is required for address
     * @param _address Address to check
     */
    function isKYCRequired(address _address) external view returns(bool) {
        return KYCRequired[_address];
    }

    /**
     * @dev Check if KYC is passed by address
     * @param _address Address to check
     */
    function isKYCPassed(address _address) external view returns(bool) {
        return KYCPassed[_address];
    }

    /**
     * @dev Check if KYC is not required or passed
     * @param _address Address to check
     */
    function isKYCSatisfied(address _address) public view returns(bool) {
        return !KYCRequired[_address] || KYCPassed[_address];
    }

    /**
     * @dev Returns wei invested by specific amount
     * @param _account Account you would like to get wei for
     */
    function weiInvestedOf(address _account) external view returns (uint256) {
        return weiInvested[_account];
    }

    /**
     * @dev Returns cents invested by specific amount
     * @param _account Account you would like to get cents for
     */
    function usdInvestedOf(address _account) external view returns (uint256) {
        return usdInvested[_account];
    }

    /**
     * @dev Update KYC status for set of addresses
     * @param _addresses Addresses to update
     * @param _completed Is KYC passed or not
     */
    function updateKYCStatus(address[] _addresses, bool _completed) public onlyOwnerOrOracle {
        for (uint16 index = 0; index < _addresses.length; index++) {
            KYCPassed[_addresses[index]] = _completed;
        }
    }

    /**
     * @dev Override update purchasing state
     *      - update sum of funds invested
     *      - if total amount invested higher than KYC amount set KYC required to true
     */
    function _updatePurchasingState(address _beneficiary, uint256 _weiAmount) internal {
        super._updatePurchasingState(_beneficiary, _weiAmount);

        uint256 usdAmount = _weiToUsd(_weiAmount);
        usdRaised = usdRaised.add(usdAmount);
        usdInvested[_beneficiary] = usdInvested[_beneficiary].add(usdAmount);
        weiInvested[_beneficiary] = weiInvested[_beneficiary].add(_weiAmount);

        if (usdInvested[_beneficiary] >= KYCRequiredAmountInUsd) {
            KYCRequired[_beneficiary] = true;
        }
    }

    /**
     * @dev Override token withdraw
     *      - do not allow token withdraw in case KYC required but not passed
     */
    function withdrawTokens() public {
        require(isKYCSatisfied(msg.sender));

        super.withdrawTokens();
    }

    /**
     * @dev Converts wei to cents
     * @param _wei Wei amount
     */
    function _weiToUsd(uint256 _wei) internal view returns (uint256) {
        return _wei.mul(etherPriceInUsd).div(1e18);
    }

    /**
     * @dev Converts cents to wei
     * @param _cents Cents amount
     */
    function _usdToWei(uint256 _cents) internal view returns (uint256) {
        return _cents.mul(1e18).div(etherPriceInUsd);
    }
}

contract KYCRefundableCrowdsale is KYCCrowdsale {
    using SafeMath for uint256;

    /**
     * @dev percentage multiplier to present percentage as decimals. 5 decimal by default
     * @dev weiOnFinalize ether balance which was on finalize & will be returned to users in case of failed crowdsale
     */
    uint256 private percentage = 100 * 1000;
    uint256 private weiOnFinalize;

    /**
     * @dev goalReached specifies if crowdsale goal is reached
     * @dev isFinalized is crowdsale finished
     * @dev tokensWithdrawn total amount of tokens already withdrawn
     */
    bool public goalReached = false;
    bool public isFinalized = false;
    uint256 public tokensWithdrawn;

    event Refund(address indexed _account, uint256 _amountInvested, uint256 _amountRefunded);
    event Finalized();
    event OwnerWithdraw(uint256 _amount);

    /**
     * @dev Set is goal reached or not
     * @param _success Is goal reached or not
     */
    function setGoalReached(bool _success) external onlyOwner {
        require(!isFinalized);
        goalReached = _success;
    }

    /**
     * @dev Investors can claim refunds here if crowdsale is unsuccessful
     */
    function claimRefund() public {
        require(isFinalized);
        require(!goalReached);

        uint256 refundPercentage = _refundPercentage();
        uint256 amountInvested = weiInvested[msg.sender];
        uint256 amountRefunded = amountInvested.mul(refundPercentage).div(percentage);
        weiInvested[msg.sender] = 0;
        usdInvested[msg.sender] = 0;
        msg.sender.transfer(amountRefunded);

        emit Refund(msg.sender, amountInvested, amountRefunded);
    }

    /**
     * @dev Must be called after crowdsale ends, to do some extra finalization works.
     */
    function finalize() public onlyOwner {
        require(!isFinalized);

        // NOTE: We do this because we would like to allow withdrawals earlier than closing time in case of crowdsale success
        closingTime = block.timestamp;
        weiOnFinalize = address(this).balance;
        isFinalized = true;

        emit Finalized();
    }

    /**
     * @dev Override. Withdraw tokens only after crowdsale ends.
     * Make sure crowdsale is successful & finalized
     */
    function withdrawTokens() public {
        require(isFinalized);
        require(goalReached);

        tokensWithdrawn = tokensWithdrawn.add(balances[msg.sender]);

        super.withdrawTokens();
    }

    /**
     * @dev Is called by owner to send funds to ICO wallet.
     * params _amount Amount to be sent.
     */
    function ownerWithdraw(uint256 _amount) external onlyOwner {
        require(_amount > 0);

        wallet.transfer(_amount);

        emit OwnerWithdraw(_amount);
    }

    /**
     * @dev Override. Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        // NOTE: Do nothing here. Keep funds in contract by default
    }

    /**
     * @dev Calculates refund percentage in case some funds will be used by dev team on crowdsale needs
     */
    function _refundPercentage() internal view returns (uint256) {
        return weiOnFinalize.mul(percentage).div(weiRaised);
    }
}

contract AerumCrowdsale is KYCRefundableCrowdsale {
    using SafeMath for uint256;

    /**
     * @dev minInvestmentInUsd Minimal investment allowed in cents
     */
    uint256 public minInvestmentInUsd;

    /**
     * @dev tokensSold Amount of tokens sold by this time
     */
    uint256 public tokensSold;

    /**
     * @dev pledgeTotal Total pledge collected from all investors
     * @dev pledgeClosingTime Time when pledge is closed & it's not possible to pledge more or use pledge more
     * @dev pledges Mapping of all pledges done by investors
     */
    uint256 public pledgeTotal;
    uint256 public pledgeClosingTime;
    mapping (address => uint256) public pledges;

    /**
     * @dev whitelistedRate Rate which is used while whitelisted sale (XRM to ETH)
     * @dev publicRate Rate which is used white public crowdsale (XRM to ETH)
     */
    uint256 public whitelistedRate;
    uint256 public publicRate;


    event AirDrop(address indexed _account, uint256 _amount);
    event MinInvestmentUpdated(uint256 _cents);
    event RateUpdated(uint256 _whitelistedRate, uint256 _publicRate);
    event Withdraw(address indexed _account, uint256 _amount);

    /**
     * @param _token ERC20 compatible token on which crowdsale is done
     * @param _wallet Address where all ETH funded will be sent after ICO finishes
     * @param _whitelistedRate Rate which is used while whitelisted sale
     * @param _publicRate Rate which is used white public crowdsale
     * @param _openingTime Crowdsale open time
     * @param _closingTime Crowdsale close time
     * @param _pledgeClosingTime Time when pledge is closed & no more active
\\
     * @param _kycAmountInUsd Amount on which KYC will be required in cents
     * @param _etherPriceInUsd ETH price in cents
     */
    constructor(
        ERC20 _token, address _wallet,
        uint256 _whitelistedRate, uint256 _publicRate,
        uint256 _openingTime, uint256 _closingTime,
        uint256 _pledgeClosingTime,
        uint256 _kycAmountInUsd, uint256 _etherPriceInUsd)
    Oraclized(msg.sender)
    Crowdsale(_whitelistedRate, _wallet, _token)
    TimedCrowdsale(_openingTime, _closingTime)
    KYCCrowdsale(_kycAmountInUsd, _etherPriceInUsd)
    KYCRefundableCrowdsale()
    public {
        require(_openingTime < _pledgeClosingTime && _pledgeClosingTime < _closingTime);
        pledgeClosingTime = _pledgeClosingTime;

        whitelistedRate = _whitelistedRate;
        publicRate = _publicRate;

        minInvestmentInUsd = 25 * 100;
    }

    /**
     * @dev Update minimal allowed investment
     */
    function setMinInvestment(uint256 _cents) external onlyOwnerOrOracle {
        minInvestmentInUsd = _cents;

        emit MinInvestmentUpdated(_cents);
    }

    /**
     * @dev Update closing time
     * @param _closingTime Closing time
     */
    function setClosingTime(uint256 _closingTime) external onlyOwner {
        require(_closingTime >= openingTime);

        closingTime = _closingTime;
    }

    /**
     * @dev Update pledge closing time
     * @param _pledgeClosingTime Pledge closing time
     */
    function setPledgeClosingTime(uint256 _pledgeClosingTime) external onlyOwner {
        require(_pledgeClosingTime >= openingTime && _pledgeClosingTime <= closingTime);

        pledgeClosingTime = _pledgeClosingTime;
    }

    /**
     * @dev Update rates
     * @param _whitelistedRate Rate which is used while whitelisted sale (XRM to ETH)
     * @param _publicRate Rate which is used white public crowdsale (XRM to ETH)
     */
    function setRate(uint256 _whitelistedRate, uint256 _publicRate) public onlyOwnerOrOracle {
        require(_whitelistedRate > 0);
        require(_publicRate > 0);

        whitelistedRate = _whitelistedRate;
        publicRate = _publicRate;

        emit RateUpdated(_whitelistedRate, _publicRate);
    }

    /**
     * @dev Update rates & ether price. Done to not make 2 requests from oracle.
     * @param _whitelistedRate Rate which is used while whitelisted sale
     * @param _publicRate Rate which is used white public crowdsale
     * @param _cents Price of 1 ETH in cents
     */
    function setRateAndEtherPrice(uint256 _whitelistedRate, uint256 _publicRate, uint256 _cents) external onlyOwnerOrOracle {
        setRate(_whitelistedRate, _publicRate);
        setEtherPrice(_cents);
    }

    /**
     * @dev Send remaining tokens back
     * @param _to Address to send
     * @param _amount Amount to send
     */
    function sendTokens(address _to, uint256 _amount) external onlyOwner {
        if (!isFinalized || goalReached) {
            // NOTE: if crowdsale not finished or successful we should keep at least tokens sold
            _ensureTokensAvailable(_amount);
        }

        token.transfer(_to, _amount);
    }

    /**
     * @dev Get balance fo tokens bought
     * @param _address Address of investor
     */
    function balanceOf(address _address) external view returns (uint256) {
        return balances[_address];
    }

    /**
     * @dev Check if all tokens were sold
     */
    function capReached() public view returns (bool) {
        return tokensSold >= token.balanceOf(this);
    }

    /**
     * @dev Returns percentage of tokens sold
     */
    function completionPercentage() external view returns (uint256) {
        uint256 balance = token.balanceOf(this);
        if (balance == 0) {
            return 0;
        }

        return tokensSold.mul(100).div(balance);
    }

    /**
     * @dev Returns remaining tokens based on stage
     */
    function tokensRemaining() external view returns(uint256) {
        return token.balanceOf(this).sub(_tokensLocked());
    }

    /**
     * @dev Override. Withdraw tokens only after crowdsale ends.
     * Adding withdraw event
     */
    function withdrawTokens() public {
        uint256 amount = balances[msg.sender];
        super.withdrawTokens();

        emit Withdraw(msg.sender, amount);
    }

    /**
     * @dev Override crowdsale pre validate. Check:
     *      - is amount invested larger than minimal
     *      - there is enough tokens on balance of contract to proceed
     *      - check if pledges amount are not more than total coins (in case of pledge period)
     */
    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal {
        super._preValidatePurchase(_beneficiary, _weiAmount);

        require(_totalInvestmentInUsd(_beneficiary, _weiAmount) >= minInvestmentInUsd);
        _ensureTokensAvailableExcludingPledge(_beneficiary, _getTokenAmount(_weiAmount));
    }

    /**
     * @dev Returns total investment of beneficiary including current one in cents
     * @param _beneficiary Address to check
     * @param _weiAmount Current amount being invested in wei
     */
    function _totalInvestmentInUsd(address _beneficiary, uint256 _weiAmount) internal view returns(uint256) {
        return usdInvested[_beneficiary].add(_weiToUsd(_weiAmount));
    }

    /**
     * @dev Override process purchase
     *      - additionally sum tokens sold
     */
    function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
        super._processPurchase(_beneficiary, _tokenAmount);

        tokensSold = tokensSold.add(_tokenAmount);

        if (pledgeOpen()) {
            // NOTE: In case of buying tokens inside pledge it doesn't matter how we decrease pledge as we change it anyway
            _decreasePledge(_beneficiary, _tokenAmount);
        }
    }

    /**
     * @dev Decrease pledge of account by specific token amount
     * @param _beneficiary Account to increase pledge
     * @param _tokenAmount Amount of tokens to decrease pledge
     */
    function _decreasePledge(address _beneficiary, uint256 _tokenAmount) internal {
        if (pledgeOf(_beneficiary) <= _tokenAmount) {
            pledgeTotal = pledgeTotal.sub(pledgeOf(_beneficiary));
            pledges[_beneficiary] = 0;
        } else {
            pledgeTotal = pledgeTotal.sub(_tokenAmount);
            pledges[_beneficiary] = pledges[_beneficiary].sub(_tokenAmount);
        }
    }

    /**
     * @dev Override to use whitelisted or public crowdsale rates
     */
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {
        uint256 currentRate = getCurrentRate();
        return _weiAmount.mul(currentRate);
    }

    /**
     * @dev Returns current XRM to ETH rate based on stage
     */
    function getCurrentRate() public view returns (uint256) {
        if (pledgeOpen()) {
            return whitelistedRate;
        }
        return publicRate;
    }

    /**
     * @dev Check if pledge period is still open
     */
    function pledgeOpen() public view returns (bool) {
        return (openingTime <= block.timestamp) && (block.timestamp <= pledgeClosingTime);
    }

    /**
     * @dev Returns amount of pledge for account
     */
    function pledgeOf(address _address) public view returns (uint256) {
        return pledges[_address];
    }

    /**
     * @dev Check if all tokens were pledged
     */
    function pledgeCapReached() public view returns (bool) {
        return pledgeTotal.add(tokensSold) >= token.balanceOf(this);
    }

    /**
     * @dev Returns percentage of tokens pledged
     */
    function pledgeCompletionPercentage() external view returns (uint256) {
        uint256 balance = token.balanceOf(this);
        if (balance == 0) {
            return 0;
        }

        return pledgeTotal.add(tokensSold).mul(100).div(balance);
    }

    /**
     * @dev Pledges
     * @param _addresses list of addresses
     * @param _tokens List of tokens to drop
     */
    function pledge(address[] _addresses, uint256[] _tokens) external onlyOwnerOrOracle {
        require(_addresses.length == _tokens.length);
        _ensureTokensListAvailable(_tokens);

        for (uint16 index = 0; index < _addresses.length; index++) {
            pledgeTotal = pledgeTotal.sub(pledges[_addresses[index]]).add(_tokens[index]);
            pledges[_addresses[index]] = _tokens[index];
        }
    }

    /**
     * @dev Air drops tokens to users
     * @param _addresses list of addresses
     * @param _tokens List of tokens to drop
     */
    function airDropTokens(address[] _addresses, uint256[] _tokens) external onlyOwnerOrOracle {
        require(_addresses.length == _tokens.length);
        _ensureTokensListAvailable(_tokens);

        for (uint16 index = 0; index < _addresses.length; index++) {
            tokensSold = tokensSold.add(_tokens[index]);
            balances[_addresses[index]] = balances[_addresses[index]].add(_tokens[index]);

            emit AirDrop(_addresses[index], _tokens[index]);
        }
    }

    /**
     * @dev Ensure token list total is available
     * @param _tokens list of tokens amount
     */
    function _ensureTokensListAvailable(uint256[] _tokens) internal {
        uint256 total;
        for (uint16 index = 0; index < _tokens.length; index++) {
            total = total.add(_tokens[index]);
        }

        _ensureTokensAvailable(total);
    }

    /**
     * @dev Ensure amount of tokens you would like to buy or pledge is available
     * @param _tokens Amount of tokens to buy or pledge
     */
    function _ensureTokensAvailable(uint256 _tokens) internal view {
        require(_tokens.add(_tokensLocked()) <= token.balanceOf(this));
    }

    /**
     * @dev Ensure amount of tokens you would like to buy or pledge is available excluding pledged for account
     * @param _account Account which is checked for pledge
     * @param _tokens Amount of tokens to buy or pledge
     */
    function _ensureTokensAvailableExcludingPledge(address _account, uint256 _tokens) internal view {
        require(_tokens.add(_tokensLockedExcludingPledge(_account)) <= token.balanceOf(this));
    }

    /**
     * @dev Returns locked or sold tokens based on stage
     */
    function _tokensLocked() internal view returns(uint256) {
        uint256 locked = tokensSold.sub(tokensWithdrawn);

        if (pledgeOpen()) {
            locked = locked.add(pledgeTotal);
        }

        return locked;
    }

    /**
     * @dev Returns locked or sold tokens based on stage excluding pledged for account
     * @param _account Account which is checked for pledge
     */
    function _tokensLockedExcludingPledge(address _account) internal view returns(uint256) {
        uint256 locked = _tokensLocked();

        if (pledgeOpen()) {
            locked = locked.sub(pledgeOf(_account));
        }

        return locked;
    }
}