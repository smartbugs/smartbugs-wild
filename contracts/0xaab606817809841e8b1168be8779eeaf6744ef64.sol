/**
 * @title TEND token
 * @version 2.0
 * @author Validity Labs AG <info@validitylabs.org>
 *
 * The TTA tokens are issued as participation certificates and represent
 * uncertificated securities within the meaning of article 973c Swiss CO. The
 * issuance of the TTA tokens has been governed by a prospectus issued by
 * Tend Technologies AG.
 *
 * TTA tokens are only recognized and transferable in undivided units.
 *
 * The holder of a TTA token must prove his possessorship to be recognized by
 * the issuer as being entitled to the rights arising out of the respective
 * participation certificate; he/she waives any rights if he/she is not in a
 * position to prove him/her being the holder of the respective token.
 *
 * Similarly, only the person who proves him/her being the holder of the TTA
 * Token is entitled to transfer title and ownership on the token to another
 * person. Both the transferor and the transferee agree and accept hereby
 * explicitly that the tokens are transferred digitally, i.e. in a form-free
 * manner. However, if any regulators, courts or similar would require written
 * confirmation of a transfer of the transferable uncertificated securities
 * from one investor to another investor, such investors will provide written
 * evidence of such transfer.
 */
pragma solidity ^0.4.24;

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
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
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

/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/openzeppelin-solidity/issues/120
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

  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
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
    hasMintPermission
    canMint
    public
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
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
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
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    emit Unpause();
  }
}

/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is StandardToken, Pausable {

  function transfer(
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transfer(_to, _value);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(
    address _spender,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {
    return super.approve(_spender, _value);
  }

  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

contract DividendToken is StandardToken, Ownable {
    using SafeMath for uint256;

    // time before dividendEndTime during which dividend cannot be claimed by token holders
    // instead the unclaimed dividend can be claimed by treasury in that time span
    uint256 public claimTimeout = 20 days;

    uint256 public dividendCycleTime = 350 days;

    uint256 public currentDividend;

    mapping(address => uint256) unclaimedDividend;

    // tracks when the dividend balance has been updated last time
    mapping(address => uint256) public lastUpdate;

    uint256 public lastDividendIncreaseDate;

    // allow payment of dividend only by special treasury account (treasury can be set and altered by owner,
    // multiple treasurer accounts are possible
    mapping(address => bool) public isTreasurer;

    uint256 public dividendEndTime = 0;

    event Payin(address _owner, uint256 _value, uint256 _endTime);

    event Payout(address _tokenHolder, uint256 _value);

    event Reclaimed(uint256 remainingBalance, uint256 _endTime, uint256 _now);

    event ChangedTreasurer(address treasurer, bool active);

    /**
     * @dev Deploy the DividendToken contract and set the owner of the contract
     */
    constructor() public {
        isTreasurer[owner] = true;
    }

    /**
     * @dev Request payout dividend (claim) (requested by tokenHolder -> pull)
     * dividends that have not been claimed within 330 days expire and cannot be claimed anymore by the token holder.
     */
    function claimDividend() public returns (bool) {
        // unclaimed dividend fractions should expire after 330 days and the owner can reclaim that fraction
        require(dividendEndTime > 0);
        require(dividendEndTime.sub(claimTimeout) > block.timestamp);

        updateDividend(msg.sender);

        uint256 payment = unclaimedDividend[msg.sender];
        unclaimedDividend[msg.sender] = 0;

        msg.sender.transfer(payment);

        // Trigger payout event
        emit Payout(msg.sender, payment);

        return true;
    }

    /**
     * @dev Transfer dividend (fraction) to new token holder
     * @param _from address The address of the old token holder
     * @param _to address The address of the new token holder
     * @param _value uint256 Number of tokens to transfer
     */
    function transferDividend(address _from, address _to, uint256 _value) internal {
        updateDividend(_from);
        updateDividend(_to);

        uint256 transAmount = unclaimedDividend[_from].mul(_value).div(balanceOf(_from));

        unclaimedDividend[_from] = unclaimedDividend[_from].sub(transAmount);
        unclaimedDividend[_to] = unclaimedDividend[_to].add(transAmount);
    }

    /**
     * @dev Update the dividend of hodler
     * @param _hodler address The Address of the hodler
     */
    function updateDividend(address _hodler) internal {
        // last update in previous period -> reset claimable dividend
        if (lastUpdate[_hodler] < lastDividendIncreaseDate) {
            unclaimedDividend[_hodler] = calcDividend(_hodler, totalSupply_);
            lastUpdate[_hodler] = block.timestamp;
        }
    }

    /**
     * @dev Get claimable dividend for the hodler
     * @param _hodler address The Address of the hodler
     */
    function getClaimableDividend(address _hodler) public constant returns (uint256 claimableDividend) {
        if (lastUpdate[_hodler] < lastDividendIncreaseDate) {
            return calcDividend(_hodler, totalSupply_);
        } else {
            return (unclaimedDividend[_hodler]);
        }
    }

    /**
     * @dev Overrides transfer method from BasicToken
     * transfer token for a specified address
     * @param _to address The address to transfer to.
     * @param _value uint256 The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        transferDividend(msg.sender, _to, _value);

        // Return from inherited transfer method
        return super.transfer(_to, _value);
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        // Prevent dividend to be claimed twice
        transferDividend(_from, _to, _value);

        // Return from inherited transferFrom method
        return super.transferFrom(_from, _to, _value);
    }

    /**
     * @dev Set / alter treasurer "account". This can be done from owner only
     * @param _treasurer address Address of the treasurer to create/alter
     * @param _active bool Flag that shows if the treasurer account is active
     */
    function setTreasurer(address _treasurer, bool _active) public onlyOwner {
        isTreasurer[_treasurer] = _active;
        emit ChangedTreasurer(_treasurer, _active);
    }

    /**
     * @dev Request unclaimed ETH, payback to beneficiary (owner) wallet
     * dividend payment is possible every 330 days at the earliest - can be later, this allows for some flexibility,
     * e.g. board meeting had to happen a bit earlier this year than previous year.
     */
    function requestUnclaimed() public onlyOwner {
        // Send remaining ETH to beneficiary (back to owner) if dividend round is over
        require(block.timestamp >= dividendEndTime.sub(claimTimeout));

        msg.sender.transfer(address(this).balance);

        emit Reclaimed(address(this).balance, dividendEndTime, block.timestamp);
    }

    /**
     * @dev ETH Payin for Treasurer
     * Only owner or treasurer can do a payin for all token holder.
     * Owner / treasurer can also increase dividend by calling fallback function multiple times.
     */
    function() public payable {
        require(isTreasurer[msg.sender]);
        require(dividendEndTime < block.timestamp);

        // pay back unclaimed dividend that might not have been claimed by owner yet
        if (address(this).balance > msg.value) {
            uint256 payout = address(this).balance.sub(msg.value);
            owner.transfer(payout);
            emit Reclaimed(payout, dividendEndTime, block.timestamp);
        }

        currentDividend = address(this).balance;

        // No active dividend cycle found, initialize new round
        dividendEndTime = block.timestamp.add(dividendCycleTime);

        // Trigger payin event
        emit Payin(msg.sender, msg.value, dividendEndTime);

        lastDividendIncreaseDate = block.timestamp;
    }

    /**
     * @dev calculate the dividend
     * @param _hodler address
     * @param _totalSupply uint256
     */
    function calcDividend(address _hodler, uint256 _totalSupply) public view returns(uint256) {
        return (currentDividend.mul(balanceOf(_hodler))).div(_totalSupply);
    }
}

contract TendToken is MintableToken, PausableToken, DividendToken {
    using SafeMath for uint256;

    string public constant name = "Tend Token";
    string public constant symbol = "TTA";
    uint8 public constant decimals = 18;

    // Minimum transferable chunk
    uint256 public granularity = 1e18;

    /**
     * @dev Constructor of TendToken that instantiate a new DividendToken
     */
    constructor() public DividendToken() {
        // token should not be transferrable until after all tokens have been issued
        paused = true;
    }

    /**
     * @dev Internal function that ensures `_amount` is multiple of the granularity
     * @param _amount The quantity that wants to be checked
     */
    function requireMultiple(uint256 _amount) internal view {
        require(_amount.div(granularity).mul(granularity) == _amount);
    }

    /**
     * @dev Transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        requireMultiple(_value);

        return super.transfer(_to, _value);
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        requireMultiple(_value);

        return super.transferFrom(_from, _to, _value);
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) public returns (bool) {
        requireMultiple(_amount);

        // Return from inherited mint method
        return super.mint(_to, _amount);
    }

    /**
     * @dev Function to batch mint tokens
     * @param _to An array of addresses that will receive the minted tokens.
     * @param _amount An array with the amounts of tokens each address will get minted.
     * @return A boolean that indicates whether the operation was successful.
     */
    function batchMint(
        address[] _to,
        uint256[] _amount
    )
        hasMintPermission
        canMint
        public
        returns (bool)
    {
        require(_to.length == _amount.length);

        for (uint i = 0; i < _to.length; i++) {
            requireMultiple(_amount[i]);

            require(mint(_to[i], _amount[i]));
        }
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
   * @param token ERC20 token which is being vested
   */
  function release(ERC20Basic token) public {
    uint256 unreleased = releasableAmount(token);

    require(unreleased > 0);

    released[token] = released[token].add(unreleased);

    token.safeTransfer(beneficiary, unreleased);

    emit Released(unreleased);
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

    emit Revoked();
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

    if (block.timestamp < cliff) {
      return 0;
    } else if (block.timestamp >= start.add(duration) || revoked[token]) {
      return totalBalance;
    } else {
      return totalBalance.mul(block.timestamp.sub(start)).div(duration);
    }
  }
}

contract RoundedTokenVesting is TokenVesting {
    using SafeMath for uint256;

    // Minimum transferable chunk
    uint256 public granularity;

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
        bool _revocable,
        uint256 _granularity
    )
        public
        TokenVesting(_beneficiary, _start, _cliff, _duration, _revocable)
    {
        granularity = _granularity;
    }
    
    /**
     * @dev Calculates the amount that has already vested.
     * @param token ERC20 token which is being vested
     */
    function vestedAmount(ERC20Basic token) public view returns (uint256) {
        uint256 currentBalance = token.balanceOf(this);
        uint256 totalBalance = currentBalance.add(released[token]);

        if (block.timestamp < cliff) {
            return 0;
        } else if (block.timestamp >= start.add(duration) || revoked[token]) {
            return totalBalance;
        } else {
            uint256 notRounded = totalBalance.mul(block.timestamp.sub(start)).div(duration);

            // Round down to the nearest token chunk by using integer division: (x / 1e18) * 1e18
            uint256 rounded = notRounded.div(granularity).mul(granularity);

            return rounded;
        }
    }
}

contract TendTokenVested is TendToken {
    using SafeMath for uint256;

    /*** CONSTANTS ***/
    uint256 public constant DEVELOPMENT_TEAM_CAP = 2e6 * 1e18;  // 2 million * 1e18

    uint256 public constant VESTING_CLIFF = 0 days;
    uint256 public constant VESTING_DURATION = 3 * 365 days;

    uint256 public developmentTeamTokensMinted;

    // for convenience we store vesting wallets
    address[] public vestingWallets;

    modifier onlyNoneZero(address _to, uint256 _amount) {
        require(_to != address(0));
        require(_amount > 0);
        _;
    }

    /**
     * @dev allows contract owner to mint team tokens per DEVELOPMENT_TEAM_CAP and transfer to the development team's wallet (yes vesting)
     * @param _to address for beneficiary
     * @param _tokens uint256 token amount to mint
     */
    function mintDevelopmentTeamTokens(address _to, uint256 _tokens) public onlyOwner onlyNoneZero(_to, _tokens) returns (bool) {
        requireMultiple(_tokens);
        require(developmentTeamTokensMinted.add(_tokens) <= DEVELOPMENT_TEAM_CAP);

        developmentTeamTokensMinted = developmentTeamTokensMinted.add(_tokens);
        RoundedTokenVesting newVault = new RoundedTokenVesting(_to, block.timestamp, VESTING_CLIFF, VESTING_DURATION, false, granularity);
        vestingWallets.push(address(newVault)); // for convenience we keep them in storage so that they are easily accessible via MEW or etherscan
        return mint(address(newVault), _tokens);
    }

    /**
     * @dev returns number of elements in the vestinWallets array
     */
    function getVestingWalletLength() public view returns (uint256) {
        return vestingWallets.length;
    }
}