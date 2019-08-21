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

contract Claimable is Ownable {
  address public pendingOwner;

  /**
   * @dev Modifier throws if called by any account other than the pendingOwner.
   */
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner);
    _;
  }

  /**
   * @dev Allows the current owner to set the pendingOwner address.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() onlyPendingOwner public {
    OwnershipTransferred(owner, pendingOwner);
    owner = pendingOwner;
    pendingOwner = 0x0;
  }
}

contract HasNoContracts is Ownable {

  /**
   * @dev Reclaim ownership of Ownable contracts
   * @param contractAddr The address of the Ownable to be reclaimed.
   */
  function reclaimContract(address contractAddr) external onlyOwner {
    Ownable contractInst = Ownable(contractAddr);
    contractInst.transferOwnership(owner);
  }
}

contract HasNoEther is Ownable {

  /**
  * @dev Constructor that rejects incoming Ether
  * @dev The `payable` flag is added so we can access `msg.value` without compiler warning. If we
  * leave out payable, then Solidity will allow inheriting contracts to implement a payable
  * constructor. By doing it this way we prevent a payable constructor from working. Alternatively
  * we could use assembly to access msg.value.
  */
  function HasNoEther() payable {
    require(msg.value == 0);
  }

  /**
   * @dev Disallows direct send by settings a default function without the `payable` flag.
   */
  function() external {
  }

  /**
   * @dev Transfer all Ether held by the contract to the owner.
   */
  function reclaimEther() external onlyOwner {
    assert(owner.send(this.balance));
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

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

  /**
   * @dev Reclaim all ERC20Basic compatible tokens
   * @param token ERC20Basic The address of the token contract
   */
  function reclaimToken(ERC20Basic token) external onlyOwner {
    uint256 balance = token.balanceOf(this);
    token.safeTransfer(owner, balance);
  }

}

contract HasNoTokens is CanReclaimToken {

 /**
  * @dev Reject all ERC23 compatible tokens
  * @param from_ address The address that is transferring the tokens
  * @param value_ uint256 the amount of the specified token
  * @param data_ Bytes The data passed from the caller.
  */
  function tokenFallback(address from_, uint256 value_, bytes data_) external {
    revert();
  }

}

contract NoOwner is HasNoEther, HasNoTokens, HasNoContracts {
}

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

contract Campaign is Claimable, HasNoTokens, ReentrancyGuard {
    using SafeMath for uint256;

    string constant public version = "1.0.0";

    string public id;

    string public name;

    string public website;

    bytes32 public whitePaperHash;

    uint256 public fundingThreshold;

    uint256 public fundingGoal;

    uint256 public tokenPrice;

    enum TimeMode {
        Block,
        Timestamp
    }

    TimeMode public timeMode;

    uint256 public startTime;

    uint256 public finishTime;

    enum BonusMode {
        Flat,
        Block,
        Timestamp,
        AmountRaised,
        ContributionAmount
    }

    BonusMode public bonusMode;

    uint256[] public bonusLevels;

    uint256[] public bonusRates; // coefficients in ether

    address public beneficiary;

    uint256 public amountRaised;

    uint256 public minContribution;

    uint256 public earlySuccessTimestamp;

    uint256 public earlySuccessBlock;

    mapping (address => uint256) public contributions;

    Token public token;

    enum Stage {
        Init,
        Ready,
        InProgress,
        Failure,
        Success
    }

    function stage()
    public
    constant
    returns (Stage)
    {
        if (token == address(0)) {
            return Stage.Init;
        }

        var _time = timeMode == TimeMode.Timestamp ? block.timestamp : block.number;

        if (_time < startTime) {
            return Stage.Ready;
        }

        if (finishTime <= _time) {
            if (amountRaised < fundingThreshold) {
                return Stage.Failure;
            }
            return Stage.Success;
        }

        if (fundingGoal <= amountRaised) {
            return Stage.Success;
        }

        return Stage.InProgress;
    }

    modifier atStage(Stage _stage) {
        require(stage() == _stage);
        _;
    }

    event Contribution(address sender, uint256 amount);

    event Refund(address recipient, uint256 amount);

    event Payout(address recipient, uint256 amount);

    event EarlySuccess();

    function Campaign(
        string _id,
        address _beneficiary,
        string _name,
        string _website,
        bytes32 _whitePaperHash
    )
    public
    {
        id = _id;
        beneficiary = _beneficiary;
        name = _name;
        website = _website;
        whitePaperHash = _whitePaperHash;
    }

    function setParams(
        // Params are combined to the array to avoid the “Stack too deep” error
        uint256[] _fundingThreshold_fundingGoal_tokenPrice_startTime_finishTime,
        uint8[] _timeMode_bonusMode,
        uint256[] _bonusLevels,
        uint256[] _bonusRates
    )
    public
    onlyOwner
    atStage(Stage.Init)
    {
        assert(fundingGoal == 0);

        fundingThreshold = _fundingThreshold_fundingGoal_tokenPrice_startTime_finishTime[0];
        fundingGoal = _fundingThreshold_fundingGoal_tokenPrice_startTime_finishTime[1];
        tokenPrice = _fundingThreshold_fundingGoal_tokenPrice_startTime_finishTime[2];
        timeMode = TimeMode(_timeMode_bonusMode[0]);
        startTime = _fundingThreshold_fundingGoal_tokenPrice_startTime_finishTime[3];
        finishTime = _fundingThreshold_fundingGoal_tokenPrice_startTime_finishTime[4];
        bonusMode = BonusMode(_timeMode_bonusMode[1]);
        bonusLevels = _bonusLevels;
        bonusRates = _bonusRates;

        require(fundingThreshold > 0);
        require(fundingThreshold <= fundingGoal);
        require(startTime < finishTime);
        require((timeMode == TimeMode.Block ? block.number : block.timestamp) < startTime);
        require(bonusLevels.length == bonusRates.length);
    }

    function createToken(
        string _tokenName,
        string _tokenSymbol,
        uint8 _tokenDecimals,
        address[] _distributionRecipients,
        uint256[] _distributionAmounts,
        uint256[] _releaseTimes
    )
    public
    onlyOwner
    atStage(Stage.Init)
    {
        assert(fundingGoal > 0);

        token = new Token(
            _tokenName,
            _tokenSymbol,
            _tokenDecimals,
            _distributionRecipients,
            _distributionAmounts,
            _releaseTimes,
            uint8(timeMode)
        );

        minContribution = tokenPrice.div(10 ** uint256(token.decimals()));
        if (minContribution < 1 wei) {
            minContribution = 1 wei;
        }
    }

    function()
    public
    payable
    atStage(Stage.InProgress)
    {
        require(minContribution <= msg.value);

        contributions[msg.sender] = contributions[msg.sender].add(msg.value);

        // Calculate bonus
        uint256 _level;
        uint256 _tokensAmount;
        uint i;
        if (bonusMode == BonusMode.AmountRaised) {
            _level = amountRaised;
            uint256 _value = msg.value;
            uint256 _weightedRateSum = 0;
            uint256 _stepAmount;
            for (i = 0; i < bonusLevels.length; i++) {
                if (_level <= bonusLevels[i]) {
                    _stepAmount = bonusLevels[i].sub(_level);
                    if (_value <= _stepAmount) {
                        _level = _level.add(_value);
                        _weightedRateSum = _weightedRateSum.add(_value.mul(bonusRates[i]));
                        _value = 0;
                        break;
                    } else {
                        _level = _level.add(_stepAmount);
                        _weightedRateSum = _weightedRateSum.add(_stepAmount.mul(bonusRates[i]));
                        _value = _value.sub(_stepAmount);
                    }
                }
            }
            _weightedRateSum = _weightedRateSum.add(_value.mul(1 ether));

            _tokensAmount = _weightedRateSum.div(1 ether).mul(10 ** uint256(token.decimals())).div(tokenPrice);
        } else {
            _tokensAmount = msg.value.mul(10 ** uint256(token.decimals())).div(tokenPrice);

            if (bonusMode == BonusMode.Block) {
                _level = block.number;
            }
            if (bonusMode == BonusMode.Timestamp) {
                _level = block.timestamp;
            }
            if (bonusMode == BonusMode.ContributionAmount) {
                _level = msg.value;
            }

            for (i = 0; i < bonusLevels.length; i++) {
                if (_level <= bonusLevels[i]) {
                    _tokensAmount = _tokensAmount.mul(bonusRates[i]).div(1 ether);
                    break;
                }
            }
        }

        amountRaised = amountRaised.add(msg.value);

        // We don’t want more than the funding goal
        require(amountRaised <= fundingGoal);

        require(token.mint(msg.sender, _tokensAmount));

        Contribution(msg.sender, msg.value);

        if (fundingGoal <= amountRaised) {
            earlySuccessTimestamp = block.timestamp;
            earlySuccessBlock = block.number;
            token.finishMinting();
            EarlySuccess();
        }
    }

    function withdrawPayout()
    public
    atStage(Stage.Success)
    {
        require(msg.sender == beneficiary);

        if (!token.mintingFinished()) {
            token.finishMinting();
        }

        var _amount = this.balance;
        require(beneficiary.call.value(_amount)());
        Payout(beneficiary, _amount);
    }

    // Anyone can make tokens available when the campaign is successful
    function releaseTokens()
    public
    atStage(Stage.Success)
    {
        require(!token.mintingFinished());
        token.finishMinting();
    }

    function withdrawRefund()
    public
    atStage(Stage.Failure)
    nonReentrant
    {
        var _amount = contributions[msg.sender];

        require(_amount > 0);

        contributions[msg.sender] = 0;

        msg.sender.transfer(_amount);
        Refund(msg.sender, _amount);
    }
}

contract Token is MintableToken, NoOwner {
    string constant public version = "1.0.0";

    string public name;

    string public symbol;

    uint8 public decimals;

    enum TimeMode {
        Block,
        Timestamp
    }

    TimeMode public timeMode;

    mapping (address => uint256) public releaseTimes;

    function Token(
        string _name,
        string _symbol,
        uint8 _decimals,
        address[] _recipients,
        uint256[] _amounts,
        uint256[] _releaseTimes,
        uint8 _timeMode
    )
    public
    {
        require(_recipients.length == _amounts.length);
        require(_recipients.length == _releaseTimes.length);

        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        timeMode = TimeMode(_timeMode);

        // Mint pre-distributed tokens
        for (uint256 i = 0; i < _recipients.length; i++) {
            mint(_recipients[i], _amounts[i]);
            if (_releaseTimes[i] > 0) {
                releaseTimes[_recipients[i]] = _releaseTimes[i];
            }
        }
    }

    function transfer(address _to, uint256 _value)
    public
    returns (bool)
    {
        // Transfer is forbidden until minting is finished
        require(mintingFinished);

        // Transfer of time-locked funds is forbidden
        require(!timeLocked(msg.sender));

        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value)
    public
    returns (bool)
    {
        // Transfer is forbidden until minting is finished
        require(mintingFinished);

        // Transfer of time-locked funds is forbidden
        require(!timeLocked(_from));

        return super.transferFrom(_from, _to, _value);
    }

    // Checks if funds of a given address are time-locked
    function timeLocked(address _spender)
    public
    constant
    returns (bool)
    {
        if (releaseTimes[_spender] == 0) {
            return false;
        }

        // If time-lock is expired, delete it
        var _time = timeMode == TimeMode.Timestamp ? block.timestamp : block.number;
        if (releaseTimes[_spender] <= _time) {
            delete releaseTimes[_spender];
            return false;
        }

        return true;
    }
}