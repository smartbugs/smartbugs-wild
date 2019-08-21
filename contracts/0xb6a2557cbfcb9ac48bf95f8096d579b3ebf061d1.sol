pragma solidity 0.4.24;

/// @title SafeMath
/// @dev Math operations with safety checks that throw on error
library SafeMath {

    /// @dev Multiply two numbers, throw on overflow.
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /// @dev Substract two numbers, throw on overflow (i.e. if subtrahend is greater than minuend).
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /// @dev Add two numbers, throw on overflow.
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/// @title Ownable
/// @dev Provide a modifier that permits only a single user to call the function
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /// @dev Set the original `owner` of the contract to the sender account.
    constructor() public {
        owner = msg.sender;
    }

    /// @dev Require that the modified function is only called by `owner`
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /// @dev Allow `owner` to transfer control of the contract to `newOwner`.
    /// @param newOwner The address to transfer ownership to.
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

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

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <remco@2π.com>
 * @dev This tries to block incoming ether to prevent accidental loss of Ether. Should Ether end up
 * in the contract, it will allow the owner to reclaim this ether.
 * @notice Ether can still be sent to this contract by:
 * calling functions labeled `payable`
 * `selfdestruct(contract_address)`
 * mining directly to the contract address
 */
contract HasNoEther is Ownable {

    /**
    * @dev Constructor that rejects incoming Ether
    * @dev The `payable` flag is added so we can access `msg.value` without compiler warning. If we
    * leave out payable, then Solidity will allow inheriting contracts to implement a payable
    * constructor. By doing it this way we prevent a payable constructor from working. Alternatively
    * we could use assembly to access msg.value.
    */
    constructor() public payable {
        require(msg.value == 0);
    }

    /**
    * @dev Disallows direct send by settings a default function without the `payable` flag.
    */
    function() external {}

    /**
    * @dev Transfer all Ether held by the contract to the owner.
    */
    function reclaimEther() external onlyOwner {
        owner.transfer(address(this).balance);
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
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    ERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

  function safeApprove(ERC20 token, address spender, uint256 value) internal {
    require(token.approve(spender, value));
  }
}

/**
 * @title Contracts that should be able to recover tokens
 * @author SylTi
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.
 * This will prevent any accidental loss of tokens.
 */
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

/**
 * @title Contracts that should not own Tokens
 * @author Remco Bloemen <remco@2π.com>
 * @dev This blocks incoming ERC223 tokens to prevent accidental loss of tokens.
 * Should tokens (any ERC20Basic compatible) end up in the contract, it allows the
 * owner to reclaim the tokens.
 */
contract HasNoTokens is CanReclaimToken {

 /**
  * @dev Reject all ERC223 compatible tokens
  * @param from_ address The address that is transferring the tokens
  * @param value_ uint256 the amount of the specified token
  * @param data_ Bytes The data passed from the caller.
  */
  function tokenFallback(address from_, uint256 value_, bytes data_) external {
    from_;
    value_;
    data_;
    revert();
  }

}

/**
 * @title Contracts that should not own Contracts
 * @author Remco Bloemen <remco@2π.com>
 * @dev Should contracts (anything Ownable) end up being owned by this contract, it allows the owner
 * of this contract to reclaim ownership of the contracts.
 */
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

/**
 * @title Base contract for contracts that should not own things.
 * @author Remco Bloemen <remco@2π.com>
 * @dev Solves a class of errors where a contract accidentally becomes owner of Ether, Tokens or
 * Owned contracts. See respective base contracts for details.
 */
contract NoOwner is HasNoEther, HasNoTokens, HasNoContracts {
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
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

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
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
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

/// @title Lockable token with exceptions
/// @dev StandardToken modified with pausable transfers.
contract LockableToken is Ownable, StandardToken {

    /// Flag for locking normal trading
    bool public locked = true;

    /// Addresses exempted from token trade lock
    mapping(address => bool) public lockExceptions;

    constructor() public {
        // It should always be possible to call reclaimToken
        lockExceptions[this] = true;
    }

    /// @notice Admin function to lock trading
    function lock() public onlyOwner {
        locked = true;
    }

    /// @notice Admin function to unlock trading
    function unlock() public onlyOwner {
        locked = false;
    }

    /// @notice Set whether `sender` may trade when token is locked
    /// @param sender The address to change the lock exception for
    /// @param _canTrade Whether `sender` may trade
    function setTradeException(address sender, bool _canTrade) public onlyOwner {
        lockExceptions[sender] = _canTrade;
    }

    /// @notice Check if the token is currently tradable for `sender`
    /// @param sender The address attempting to make a transfer
    /// @return True if `sender` is allowed to make transfers, false otherwise
    function canTrade(address sender) public view returns(bool) {
        return !locked || lockExceptions[sender];
    }

    /// @dev Modifier to make a function callable only when the contract is not paused.
    modifier whenNotLocked() {
        require(canTrade(msg.sender));
        _;
    }

    function transfer(address _to, uint256 _value)
                public whenNotLocked returns (bool) {

        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value)
                public whenNotLocked returns (bool) {

        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value)
                public whenNotLocked returns (bool) {

        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue)
                public whenNotLocked returns (bool success) {

        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue)
                public whenNotLocked returns (bool success) {
                        
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}

/// @title Pledgecamp Token (PLG)
/// @author Sam Pullman
/// @notice ERC20 compatible token for the Pledgecamp platform
contract PLGToken is Ownable, NoOwner, LockableToken {
    using SafeMath for uint256;
    
    /// @notice Emitted when tokens are burned
    /// @param burner Account that burned its tokens
    /// @param value Number of tokens burned
    event Burn(address indexed burner, uint256 value);

    string public name = "PLGToken";
    string public symbol = "PLG";
    uint8 public decimals = 18;

    /// Flag for only allowing a single token initialization
    bool public initialized = false;

    /// @notice Set initial PLG allocations, which can only happen once
    /// @param addresses Addresses of beneficiaries
    /// @param allocations Amounts to allocate each beneficiary
    function initialize(address[] addresses, uint256[] allocations) public onlyOwner {
        require(!initialized);
        require(addresses.length == allocations.length);
        initialized = true;

        for(uint i = 0; i<allocations.length; i += 1) {
            require(addresses[i] != address(0));
            require(allocations[i] > 0);
            balances[addresses[i]] = allocations[i];
            totalSupply_ = totalSupply_.add(allocations[i]);
        }
    }

    /// @dev Burns a specific amount of tokens owned by the sender
    /// @param value The number of tokens to be burned
    function burn(uint256 value) public {
        require(value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(value);
        totalSupply_ = totalSupply_.sub(value);
        emit Burn(msg.sender, value);
        emit Transfer(msg.sender, address(0), value);
    }

}

/// @title Whitelist
/// @dev Handle whitelisting, maximum purchase limits, and bonus calculation for PLGCrowdsale
contract Whitelist is Ownable {
    using SafeMath for uint256;

    /// A participant in the crowdsale
    struct Participant {
        /// Percent of bonus tokens awarded to this participant
        uint256 bonusPercent;
        /// Maximum amount the participant can contribute in wei
        uint256 maxPurchaseAmount;
        /// Wei contributed to the crowdsale so far
        uint256 weiContributed;
    }

    /// Crowdsale address, used to authorize purchase records
    address public crowdsaleAddress;

    /// Bonus/Vesting for specific accounts
    /// If Participant.maxPurchaseAmount is zero, the address is not whitelisted
    mapping(address => Participant) private participants;

    /// @notice Set the crowdsale address. Only one crowdsale at a time may use this whitelist
    /// @param crowdsale The address of the crowdsale
    function setCrowdsale(address crowdsale) public onlyOwner {
        require(crowdsale != address(0));
        crowdsaleAddress = crowdsale;
    }

    /// @notice Get the bonus token percentage for `user`
    /// @param user The address of a crowdsale participant
    /// @return The percentage of bonus tokens `user` qualifies for
    function getBonusPercent(address user) public view returns(uint256) {
        return participants[user].bonusPercent;
    }

    /// @notice Check if an address is whitelisted
    /// @param user Potential participant
    /// @return Whether `user` may participate in the crowdsale
    function isValidPurchase(address user, uint256 weiAmount) public view returns(bool) {
        require(user != address(0));
        Participant storage participant = participants[user];
        if(participant.maxPurchaseAmount == 0) {
            return false;
        }
        return participant.weiContributed.add(weiAmount) <= participant.maxPurchaseAmount;
    }

    /// @notice Whitelist a crowdsale participant
    /// @notice Do not override weiContributed if the user has previously been whitelisted
    /// @param user The participant to add
    /// @param bonusPercent The user's bonus percentage
    /// @param maxPurchaseAmount The maximum the participant is allowed to contribute in wei
    ///     If zero, the user is de-whitelisted
    function addParticipant(address user, uint256 bonusPercent, uint256 maxPurchaseAmount) external onlyOwner {
        require(user != address(0));
        participants[user].bonusPercent = bonusPercent;
        participants[user].maxPurchaseAmount = maxPurchaseAmount;
    }

    /// @notice Whitelist multiple crowdsale participants at once with the same bonus/purchase amount
    /// @param users The participants to add
    /// @param bonusPercent The bonus percentage shared among users
    /// @param maxPurchaseAmount The maximum each participant is allowed to contribute in wei
    function addParticipants(address[] users, uint256 bonusPercent, uint256 maxPurchaseAmount) external onlyOwner {
        
        for(uint i=0; i<users.length; i+=1) {
            require(users[i] != address(0));
            participants[users[i]].bonusPercent = bonusPercent;
            participants[users[i]].maxPurchaseAmount = maxPurchaseAmount;
        }
    }

    /// @notice De-whitelist a crowdsale participant
    /// @param user The participant to revoke
    function revokeParticipant(address user) external onlyOwner {
        require(user != address(0));
        participants[user].maxPurchaseAmount = 0;
    }

    /// @notice De-whitelist multiple crowdsale participants at once
    /// @param users The participants to revoke
    function revokeParticipants(address[] users) external onlyOwner {
        
        for(uint i=0; i<users.length; i+=1) {
            require(users[i] != address(0));
            participants[users[i]].maxPurchaseAmount = 0;
        }
    }

    function recordPurchase(address beneficiary, uint256 weiAmount) public {

        require(msg.sender == crowdsaleAddress);

        Participant storage participant = participants[beneficiary];
        participant.weiContributed = participant.weiContributed.add(weiAmount);
    }
    
}

/// @title Pledgecamp Crowdsale
/// @author Sam Pullman
/// @notice Capped crowdsale with bonuses for the Pledgecamp platform
contract PLGCrowdsale is Ownable {
    using SafeMath for uint256;

    /// @notice Indicates successful token purchase
    /// @param buyer Fund provider for the token purchase. Must either be `owner` or equal to `beneficiary`
    /// @param beneficiary Account that ultimately receives purchased tokens
    /// @param value Amount in wei of investment
    /// @param tokenAmount Number of tokens purchased (not including bonus)
    /// @param bonusAmount Number of bonus tokens received
    event TokenPurchase(address indexed buyer, address indexed beneficiary,
                        uint256 value, uint256 tokenAmount, uint256 bonusAmount);

    /// @notice Emitted when the ETH to PLG exchange rate has been updated
    /// @param oldRate The previous exchange rate
    /// @param newRate The new exchange rate
    event ExchangeRateUpdated(uint256 oldRate, uint256 newRate);

    /// @notice Emitted when the crowdsale ends
    event Closed();

    /// True if the sale is active
    bool public saleActive;

    /// ERC20 token the crowdsale is based on
    PLGToken plgToken;

    /// Timestamp for when the crowdsale may start
    uint256 public startTime;

    /// Timestamp set when crowdsale purchasing stops
    uint256 public endTime;

    /// Token to ether conversion rate
    uint256 public tokensPerEther;

    /// Amount raised so far in wei
    uint256 public amountRaised;

    /// The minimum purchase amount in wei
    uint256 public minimumPurchase;

    /// The address from which bonus tokens are distributed
    address public bonusPool;

    /// The strategy for assigning bonus tokens from bonusPool and assigning vesting contracts
    Whitelist whitelist;

    /// @notice Constructor for the Pledgecamp crowdsale contract
    /// @param _plgToken ERC20 token contract used in the crowdsale
    /// @param _startTime Timestamp for when the crowdsale may start
    /// @param _rate Token to ether conversion rate
    /// @param _minimumPurchase The minimum purchase amount in wei
    constructor(address _plgToken, uint256 _startTime, uint256 _rate, uint256 _minimumPurchase) public {

        require(_startTime >= now);
        require(_rate > 0);
        require(_plgToken != address(0));

        startTime = _startTime;
        tokensPerEther = _rate;
        minimumPurchase = _minimumPurchase;
        plgToken = PLGToken(_plgToken);
    }

    /// @notice Set the address of the bonus pool, which provides tokens
    /// @notice during bonus periods if it contains sufficient PLG
    /// @param _bonusPool Address of PLG holder
    function setBonusPool(address _bonusPool) public onlyOwner {
        bonusPool = _bonusPool;
    }

    /// @notice Set the contract that whitelists and calculates how many bonus tokens to award each purchase.
    /// @param _whitelist The address of the whitelist, which must be a `Whitelist`
    function setWhitelist(address _whitelist) public onlyOwner {
        require(_whitelist != address(0));
        whitelist = Whitelist(_whitelist);
    }

    /// @notice Starts the crowdsale under appropriate conditions
    function start() public onlyOwner {
        require(!saleActive);
        require(now > startTime);
        require(endTime == 0);
        require(plgToken.initialized());
        require(plgToken.lockExceptions(address(this)));
        require(bonusPool != address(0));
        require(whitelist != address(0));
        
        saleActive = true;
    }

    /// @notice End the crowdsale if the sale is active
    /// @notice Transfer remaining tokens to reserve pool
    function end() public onlyOwner {
        require(saleActive);
        require(bonusPool != address(0));
        saleActive = false;
        endTime = now;

        withdrawTokens();

        owner.transfer(address(this).balance);
    }

    /// @notice Withdraw crowdsale ETH to owner wallet
    function withdrawEth() public onlyOwner {
        owner.transfer(address(this).balance);
    }

    /// @notice Send remaining crowdsale tokens to `bonusPool` after sale is over
    function withdrawTokens() public onlyOwner {
        require(!saleActive);
        uint256 remainingTokens = plgToken.balanceOf(this);
        plgToken.transfer(bonusPool, remainingTokens);
    }

    /// Default function tries to make a token purchase
    function () external payable {
        buyTokensInternal(msg.sender);
    }

    /// @notice Public crowdsale purchase method
    function buyTokens() external payable {
        buyTokensInternal(msg.sender);
    }

    /// @notice Owner only method for purchasing on behalf of another person
    /// @param beneficiary Address to receive the tokens
    function buyTokensFor(address beneficiary) external payable onlyOwner {
        require(beneficiary != address(0));
        buyTokensInternal(beneficiary);
    }

    /// @notice Main crowdsale purchase method, which validates the purchase and assigns bonuses
    /// @param beneficiary Address to receive the tokens
    function buyTokensInternal(address beneficiary) private {
        require(whitelist != address(0));
        require(bonusPool != address(0));
        require(validPurchase(msg.value));
        uint256 weiAmount = msg.value;

        // This is the whitelist/max purchase check
        require(whitelist.isValidPurchase(beneficiary, weiAmount));

        // Calculate the amount of PLG that's been purchased
        uint256 tokens = weiAmount.mul(tokensPerEther);

        // update state
        amountRaised = amountRaised.add(weiAmount);
        // Record the purchase in the whitelist contract
        whitelist.recordPurchase(beneficiary, weiAmount);

        plgToken.transfer(beneficiary, tokens);

        uint256 bonusPercent = whitelist.getBonusPercent(beneficiary);
        uint256 bonusTokens = tokens.mul(bonusPercent) / 100;

        if(bonusTokens > 0) {
            plgToken.transferFrom(bonusPool, beneficiary, bonusTokens);
        }

        emit TokenPurchase(msg.sender, beneficiary, weiAmount, tokens, bonusTokens);
    }

    /// @notice Set a new ETH to PLG exchange rate
    /// @param _tokensPerEther Exchange rate
    function setExchangeRate(uint256 _tokensPerEther) external onlyOwner {

        emit ExchangeRateUpdated(tokensPerEther, _tokensPerEther);
        tokensPerEther = _tokensPerEther;
    }

    /// @notice Check various conditions to determine whether a purchase is currently valid
    /// @param amount The amount of tokens to be purchased
    function validPurchase(uint256 amount) public view returns (bool) {
        bool nonZeroPurchase = amount != 0;
        bool isMinPurchase = (amount >= minimumPurchase);
        return saleActive && nonZeroPurchase && isMinPurchase;
    }

    /// @notice Check if this is valid PLGCrowdsale contract
    function validCrowdsale() public view returns (bool) {
        return true;
    }
}