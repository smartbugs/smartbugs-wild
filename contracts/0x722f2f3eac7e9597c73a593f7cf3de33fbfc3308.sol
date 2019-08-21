pragma solidity 0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
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

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

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
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract BurnableToken is BasicToken {

  event Burn(address indexed burner, uint256 value);

  /**
   * @dev Burns a specific amount of tokens.
   * @param _value The amount of token to be burned.
   */
  function burn(uint256 _value) public {
    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {
    require(_value <= balances[_who]);
    // no need to require value <= totalSupply, since that would imply the
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
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

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
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
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
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
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
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
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
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

/* solium-disable security/no-block-members */

pragma solidity ^0.4.24;






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
   * @param _start the time (as Unix time) at which point vesting starts
   * @param _duration duration in seconds of the period in which the tokens will vest
   * @param _revocable whether the vesting is revocable or not
   */
  constructor(
    address _beneficiary,
    uint256 _start,
    uint256 _cliff,
    uint256 _duration,
    bool _revocable
  )
    public
  {
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
   * @param _token ERC20 token which is being vested
   */
  function release(ERC20Basic _token) public {
    uint256 unreleased = releasableAmount(_token);

    require(unreleased > 0);

    released[_token] = released[_token].add(unreleased);

    _token.safeTransfer(beneficiary, unreleased);

    emit Released(unreleased);
  }

  /**
   * @notice Allows the owner to revoke the vesting. Tokens already vested
   * remain in the contract, the rest are returned to the owner.
   * @param _token ERC20 token which is being vested
   */
  function revoke(ERC20Basic _token) public onlyOwner {
    require(revocable);
    require(!revoked[_token]);

    uint256 balance = _token.balanceOf(address(this));

    uint256 unreleased = releasableAmount(_token);
    uint256 refund = balance.sub(unreleased);

    revoked[_token] = true;

    _token.safeTransfer(owner, refund);

    emit Revoked();
  }

  /**
   * @dev Calculates the amount that has already vested but hasn't been released yet.
   * @param _token ERC20 token which is being vested
   */
  function releasableAmount(ERC20Basic _token) public view returns (uint256) {
    return vestedAmount(_token).sub(released[_token]);
  }

  /**
   * @dev Calculates the amount that has already vested.
   * @param _token ERC20 token which is being vested
   */
  function vestedAmount(ERC20Basic _token) public view returns (uint256) {
    uint256 currentBalance = _token.balanceOf(address(this));
    uint256 totalBalance = currentBalance.add(released[_token]);

    if (block.timestamp < cliff) {
      return 0;
    } else if (block.timestamp >= start.add(duration) || revoked[_token]) {
      return totalBalance;
    } else {
      return totalBalance.mul(block.timestamp.sub(start)).div(duration);
    }
  }
}

/** @title Periodic Token Vesting
  * @dev A token holder contract that can release its token balance periodically like a
  * typical vesting scheme. Optionally revocable by the owner.
  */
contract PeriodicTokenVesting is TokenVesting {
    using SafeMath for uint256;

    uint256 public releasePeriod;
    uint256 public releaseCount;

    mapping (address => uint256) public revokedAmount;

    constructor(
        address _beneficiary,
        uint256 _startInUnixEpochTime,
        uint256 _releasePeriodInSeconds,
        uint256 _releaseCount
    )
        public
        TokenVesting(_beneficiary, _startInUnixEpochTime, 0, _releasePeriodInSeconds.mul(_releaseCount), true)
    {
        require(_releasePeriodInSeconds.mul(_releaseCount) > 0, "Vesting Duration cannot be 0");
        require(_startInUnixEpochTime.add(_releasePeriodInSeconds.mul(_releaseCount)) > block.timestamp, "Worthless vesting");
        releasePeriod = _releasePeriodInSeconds;
        releaseCount = _releaseCount;
    }

    function initialTokenAmountInVesting(ERC20Basic _token) public view returns (uint256) {
        return _token.balanceOf(address(this)).add(released[_token]).add(revokedAmount[_token]);
    }

    function tokenAmountLockedInVesting(ERC20Basic _token) public view returns (uint256) {
        return _token.balanceOf(address(this)).sub(releasableAmount(_token));
    }

    function nextVestingTime(ERC20Basic _token) public view returns (uint256) {
        if (block.timestamp >= start.add(duration) || revoked[_token]) {
            return 0;
        } else {
            return start.add(((block.timestamp.sub(start)).div(releasePeriod).add(1)).mul(releasePeriod));
        }
    }

    function vestingCompletionTime(ERC20Basic _token) public view returns (uint256) {
        if (block.timestamp >= start.add(duration) || revoked[_token]) {
            return 0;
        } else {
            return start.add(duration);
        }
    }

    function remainingVestingCount(ERC20Basic _token) public view returns (uint256) {
        if (block.timestamp >= start.add(duration) || revoked[_token]) {
            return 0;
        } else {
            return releaseCount.sub((block.timestamp.sub(start)).div(releasePeriod));
        }
    }

    /**
     * @notice Allows the owner to revoke the vesting. Tokens already vested
     * remain in the contract, the rest are returned to the owner.
     * @param _token ERC20 token which is being vested
     */
    function revoke(ERC20Basic _token) public onlyOwner {
      require(revocable);
      require(!revoked[_token]);

      uint256 balance = _token.balanceOf(address(this));

      uint256 unreleased = releasableAmount(_token);
      uint256 refund = balance.sub(unreleased);

      revoked[_token] = true;
      revokedAmount[_token] = refund;

      _token.safeTransfer(owner, refund);

      emit Revoked();
    }

    /**
     * @dev Calculates the amount that has already vested.
     * @param _token ERC20 token which is being vested
     */
    function vestedAmount(ERC20Basic _token) public view returns (uint256) {
        uint256 currentBalance = _token.balanceOf(address(this));
        uint256 totalBalance = currentBalance.add(released[_token]);

        if (block.timestamp < cliff) {
            return 0;
        } else if (block.timestamp >= start.add(duration) || revoked[_token]) {
            return totalBalance;
        } else {
            return totalBalance.mul((block.timestamp.sub(start)).div(releasePeriod)).div(releaseCount);
        }
    }
}

/** @title Cnus Token
  * An ERC20-compliant token.
  */
contract CnusToken is StandardToken, Ownable, BurnableToken {
    using SafeMath for uint256;

    // global token transfer lock
    bool public globalTokenTransferLock = false;
    bool public mintingFinished = false;
    bool public lockingDisabled = false;

    string public name = "CoinUs";
    string public symbol = "CNUS";
    uint256 public decimals = 18;

    address public mintContractOwner;

    address[] public vestedAddresses;

    // mapping that provides address based lock.
    mapping( address => bool ) public lockedStatusAddress;
    mapping( address => PeriodicTokenVesting ) private tokenVestingContracts;

    event LockingDisabled();
    event GlobalLocked();
    event GlobalUnlocked();
    event Locked(address indexed lockedAddress);
    event Unlocked(address indexed unlockedaddress);
    event Mint(address indexed to, uint256 amount);
    event MintFinished();
    event MintOwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event VestingCreated(address indexed beneficiary, uint256 startTime, uint256 period, uint256 releaseCount);
    event InitialVestingDeposited(address indexed beneficiary, uint256 amount);
    event AllVestedTokenReleased();
    event VestedTokenReleased(address indexed beneficiary);
    event RevokedTokenVesting(address indexed beneficiary);

    // Check for global lock status to be unlocked
    modifier checkGlobalTokenTransferLock {
        if (!lockingDisabled) {
            require(!globalTokenTransferLock, "Global lock is active");
        }
        _;
    }

    // Check for address lock to be unlocked
    modifier checkAddressLock {
        require(!lockedStatusAddress[msg.sender], "Address is locked");
        _;
    }

    modifier canMint() {
        require(!mintingFinished, "Minting is finished");
        _;
    }

    modifier hasMintPermission() {
        require(msg.sender == mintContractOwner, "Minting is not authorized from this account");
        _;
    }

    constructor() public {
        uint256 initialSupply = 2000000000;
        initialSupply = initialSupply.mul(10**18);
        totalSupply_ = initialSupply;
        balances[msg.sender] = initialSupply;
        mintContractOwner = msg.sender;
    }

    function disableLockingForever() public
    onlyOwner
    {
        lockingDisabled = true;
        emit LockingDisabled();
    }

    function setGlobalTokenTransferLock(bool locked) public
    onlyOwner
    {
        require(!lockingDisabled);
        require(globalTokenTransferLock != locked);
        globalTokenTransferLock = locked;
        if (globalTokenTransferLock) {
            emit GlobalLocked();
        } else {
            emit GlobalUnlocked();
        }
    }

    /**
      * @dev Allows token issuer to lock token transfer for an address.
      * @param target Target address to lock token transfer.
      */
    function lockAddress(
        address target
    )
        public
        onlyOwner
    {
        require(!lockingDisabled);
        require(owner != target);
        require(!lockedStatusAddress[target]);
        for(uint256 i = 0; i < vestedAddresses.length; i++) {
            require(tokenVestingContracts[vestedAddresses[i]] != target);
        }
        lockedStatusAddress[target] = true;
        emit Locked(target);
    }

    /**
      * @dev Allows token issuer to unlock token transfer for an address.
      * @param target Target address to unlock token transfer.
      */
    function unlockAddress(
        address target
    )
        public
        onlyOwner
    {
        require(!lockingDisabled);
        require(lockedStatusAddress[target]);
        lockedStatusAddress[target] = false;
        emit Unlocked(target);
    }

    /**
     * @dev Creates a vesting contract that vests its balance of Cnus token to the
     * _beneficiary, gradually in periodic interval until all of the balance will have
     * vested by period * release count time.
     * @param _beneficiary address of the beneficiary to whom vested tokens are transferred
     * @param _startInUnixEpochTime the time (as Unix time) at which point vesting starts
     * @param _releasePeriodInSeconds period in seconds in which tokens will vest to beneficiary
     * @param _releaseCount count of period required to have all of the balance vested
     */
    function createNewVesting(
        address _beneficiary,
        uint256 _startInUnixEpochTime,
        uint256 _releasePeriodInSeconds,
        uint256 _releaseCount
    )
        public
        onlyOwner
    {
        require(tokenVestingContracts[_beneficiary] == address(0));
        tokenVestingContracts[_beneficiary] = new PeriodicTokenVesting(
            _beneficiary, _startInUnixEpochTime, _releasePeriodInSeconds, _releaseCount);
        vestedAddresses.push(_beneficiary);
        emit VestingCreated(_beneficiary, _startInUnixEpochTime, _releasePeriodInSeconds, _releaseCount);
    }

    /**
      * @dev Transfers token vesting amount from token issuer to vesting contract created for the
      * beneficiary. Token Issuer must first approve token spending from owner's account.
      * @param _beneficiary beneficiary for whom vesting has been created with createNewVesting function.
      * @param _vestAmount vesting amount for the beneficiary
      */
    function transferInitialVestAmountFromOwner(
        address _beneficiary,
        uint256 _vestAmount
    )
        public
        onlyOwner
        returns (bool)
    {
        require(tokenVestingContracts[_beneficiary] != address(0));
        ERC20 cnusToken = ERC20(address(this));
        require(cnusToken.allowance(owner, address(this)) >= _vestAmount);
        require(cnusToken.transferFrom(owner, tokenVestingContracts[_beneficiary], _vestAmount));
        emit InitialVestingDeposited(_beneficiary, cnusToken.balanceOf(tokenVestingContracts[_beneficiary]));
        return true;
    }

    function checkVestedAddressCount()
        public
        view
        returns (uint256)
    {
        return vestedAddresses.length;
    }

    function checkCurrentTotolVestedAmount()
        public
        view
        returns (uint256)
    {
        uint256 vestedAmountSum = 0;
        for (uint256 i = 0; i < vestedAddresses.length; i++) {
            vestedAmountSum = vestedAmountSum.add(
                tokenVestingContracts[vestedAddresses[i]].vestedAmount(ERC20(address(this))));
        }
        return vestedAmountSum;
    }

    function checkCurrentTotalReleasableAmount()
        public
        view
        returns (uint256)
    {
        uint256 releasableAmountSum = 0;
        for (uint256 i = 0; i < vestedAddresses.length; i++) {
            releasableAmountSum = releasableAmountSum.add(
                tokenVestingContracts[vestedAddresses[i]].releasableAmount(ERC20(address(this))));
        }
        return releasableAmountSum;
    }

    function checkCurrentTotalAmountLockedInVesting()
        public
        view
        returns (uint256)
    {
        uint256 lockedAmountSum = 0;
        for (uint256 i = 0; i < vestedAddresses.length; i++) {
            lockedAmountSum = lockedAmountSum.add(
               tokenVestingContracts[vestedAddresses[i]].tokenAmountLockedInVesting(ERC20(address(this))));
        }
        return lockedAmountSum;
    }

    function checkInitialTotalTokenAmountInVesting()
        public
        view
        returns (uint256)
    {
        uint256 initialTokenVesting = 0;
        for (uint256 i = 0; i < vestedAddresses.length; i++) {
            initialTokenVesting = initialTokenVesting.add(
                tokenVestingContracts[vestedAddresses[i]].initialTokenAmountInVesting(ERC20(address(this))));
        }
        return initialTokenVesting;
    }

    function checkNextVestingTimeForBeneficiary(
        address _beneficiary
    )
        public
        view
        returns (uint256)
    {
        require(tokenVestingContracts[_beneficiary] != address(0));
        return tokenVestingContracts[_beneficiary].nextVestingTime(ERC20(address(this)));
    }

    function checkVestingCompletionTimeForBeneficiary(
        address _beneficiary
    )
        public
        view
        returns (uint256)
    {
        require(tokenVestingContracts[_beneficiary] != address(0));
        return tokenVestingContracts[_beneficiary].vestingCompletionTime(ERC20(address(this)));
    }

    function checkRemainingVestingCountForBeneficiary(
        address _beneficiary
    )
        public
        view
        returns (uint256)
    {
        require(tokenVestingContracts[_beneficiary] != address(0));
        return tokenVestingContracts[_beneficiary].remainingVestingCount(ERC20(address(this)));
    }

    function checkReleasableAmountForBeneficiary(
        address _beneficiary
    )
        public
        view
        returns (uint256)
    {
        require(tokenVestingContracts[_beneficiary] != address(0));
        return tokenVestingContracts[_beneficiary].releasableAmount(ERC20(address(this)));
    }

    function checkVestedAmountForBeneficiary(
        address _beneficiary
    )
        public
        view
        returns (uint256)
    {
        require(tokenVestingContracts[_beneficiary] != address(0));
        return tokenVestingContracts[_beneficiary].vestedAmount(ERC20(address(this)));
    }

    function checkTokenAmountLockedInVestingForBeneficiary(
        address _beneficiary
    )
        public
        view
        returns (uint256)
    {
        require(tokenVestingContracts[_beneficiary] != address(0));
        return tokenVestingContracts[_beneficiary].tokenAmountLockedInVesting(ERC20(address(this)));
    }

    /**
     * @notice Transfers vested tokens to all beneficiaries.
     */
    function releaseAllVestedToken()
        public
        checkGlobalTokenTransferLock
        returns (bool)
    {
        emit AllVestedTokenReleased();
        PeriodicTokenVesting tokenVesting;
        for(uint256 i = 0; i < vestedAddresses.length; i++) {
            tokenVesting = tokenVestingContracts[vestedAddresses[i]];
            if(tokenVesting.releasableAmount(ERC20(address(this))) > 0) {
                tokenVesting.release(ERC20(address(this)));
                emit VestedTokenReleased(vestedAddresses[i]);
            }
        }
        return true;
    }

    /**
     * @notice Transfers vested tokens to beneficiary.
     * @param _beneficiary Beneficiary to whom cnus token is being vested
     */
    function releaseVestedToken(
        address _beneficiary
    )
        public
        checkGlobalTokenTransferLock
        returns (bool)
    {
        require(tokenVestingContracts[_beneficiary] != address(0));
        tokenVestingContracts[_beneficiary].release(ERC20(address(this)));
        emit VestedTokenReleased(_beneficiary);
        return true;
    }

    /**
     * @notice Allows the owner to revoke the vesting. Tokens already vested
     * remain in the contract, the rest are returned to the owner.
     * @param _beneficiary Beneficiary to whom cnus token is being vested
     */
    function revokeTokenVesting(
        address _beneficiary
    )
        public
        onlyOwner
        checkGlobalTokenTransferLock
        returns (bool)
    {
        require(tokenVestingContracts[_beneficiary] != address(0));
        tokenVestingContracts[_beneficiary].revoke(ERC20(address(this)));
        _transferMisplacedToken(owner, address(this), ERC20(address(this)).balanceOf(address(this)));
        emit RevokedTokenVesting(_beneficiary);
        return true;
    }

    /** @dev Transfer `_value` token to `_to` from `msg.sender`, on the condition
      * that global token lock and individual address lock in the `msg.sender`
      * accountare both released.
      * @param _to The address of the recipient.
      * @param _value The amount of token to be transferred.
      * @return Whether the transfer was successful or not.
      */
    function transfer(
        address _to,
        uint256 _value
    )
        public
        checkGlobalTokenTransferLock
        checkAddressLock
        returns (bool)
    {
        return super.transfer(_to, _value);
    }

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
        checkGlobalTokenTransferLock
        returns (bool)
    {
        require(!lockedStatusAddress[_from], "Address is locked.");
        return super.transferFrom(_from, _to, _value);
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * @param _spender address The address which will spend the funds.
     * @param _value uint256 The amount of tokens to be spent.
     */
    function approve(
        address _spender,
        uint256 _value
    )
        public
        checkGlobalTokenTransferLock
        checkAddressLock
        returns (bool)
    {
        return super.approve(_spender, _value);
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
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
        checkGlobalTokenTransferLock
        checkAddressLock
        returns (bool success)
    {
        return super.increaseApproval(_spender, _addedValue);
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
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
        checkGlobalTokenTransferLock
        checkAddressLock
        returns (bool success)
    {
        return super.decreaseApproval(_spender, _subtractedValue);
    }

    /**
     * @dev Function to transfer mint ownership.
     * @param _newOwner The address that will have the mint ownership.
     */
    function transferMintOwnership(
        address _newOwner
    )
        public
        onlyOwner
    {
        _transferMintOwnership(_newOwner);
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(
        address _to,
        uint256 _amount
    )
        public
        hasMintPermission
        canMint
        returns (bool)
    {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    /**
     * @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting()
        public
        onlyOwner
        canMint
        returns (bool)
    {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }

    function checkMisplacedTokenBalance(
        address _tokenAddress
    )
        public
        view
        returns (uint256)
    {
        ERC20 unknownToken = ERC20(_tokenAddress);
        return unknownToken.balanceOf(address(this));
    }

    // Allow transfer of accidentally sent ERC20 tokens
    function refundMisplacedToken(
        address _recipient,
        address _tokenAddress,
        uint256 _value
    )
        public
        onlyOwner
    {
        _transferMisplacedToken(_recipient, _tokenAddress, _value);
    }

    function _transferMintOwnership(
        address _newOwner
    )
        internal
    {
        require(_newOwner != address(0));
        emit MintOwnershipTransferred(mintContractOwner, _newOwner);
        mintContractOwner = _newOwner;
    }

    function _transferMisplacedToken(
        address _recipient,
        address _tokenAddress,
        uint256 _value
    )
        internal
    {
        require(_recipient != address(0));
        ERC20 unknownToken = ERC20(_tokenAddress);
        require(unknownToken.balanceOf(address(this)) >= _value, "Insufficient token balance.");
        require(unknownToken.transfer(_recipient, _value));
    }
}