//File: node_modules/zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol
pragma solidity ^0.4.18;


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

//File: node_modules/zeppelin-solidity/contracts/math/SafeMath.sol
pragma solidity ^0.4.18;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

//File: node_modules/zeppelin-solidity/contracts/token/ERC20/BasicToken.sol
pragma solidity ^0.4.18;






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

//File: node_modules/zeppelin-solidity/contracts/token/ERC20/ERC20.sol
pragma solidity ^0.4.18;




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

//File: node_modules/zeppelin-solidity/contracts/token/ERC20/StandardToken.sol
pragma solidity ^0.4.18;





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
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
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

//File: node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol
pragma solidity ^0.4.18;


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

//File: node_modules/zeppelin-solidity/contracts/token/ERC20/MintableToken.sol
pragma solidity ^0.4.18;





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
    totalSupply_ = totalSupply_.add(_amount);
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

//File: node_modules/zeppelin-solidity/contracts/crowdsale/Crowdsale.sol
pragma solidity ^0.4.18;





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
    uint256 tokens = getTokenAmount(weiAmount);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
  }

  // Override this method to have a way to add business logic to your crowdsale when buying
  function getTokenAmount(uint256 weiAmount) internal view returns(uint256) {
    return weiAmount.mul(rate);
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

}

//File: node_modules/zeppelin-solidity/contracts/lifecycle/Pausable.sol
pragma solidity ^0.4.18;





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

//File: node_modules/zeppelin-solidity/contracts/token/ERC20/SafeERC20.sol
pragma solidity ^0.4.18;





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

//File: node_modules/zeppelin-solidity/contracts/token/ERC20/TokenVesting.sol
pragma solidity ^0.4.18;







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

//File: node_modules/zeppelin-solidity/contracts/token/ERC20/PausableToken.sol
pragma solidity ^0.4.18;





/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
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

//File: src/contracts/ico/DividendToken.sol
/**
 * @title Dividend contract
 *
 * @version 1.0
 * @author Validity Labs AG <info@validitylabs.org>
 */
pragma solidity ^0.4.18;





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
    function DividendToken() public {
        isTreasurer[owner] = true;
    }

    /**
     * @dev Request payout dividend (claim) (requested by tokenHolder -> pull)
     * dividends that have not been claimed within 330 days expire and cannot be claimed anymore by the token holder.
     */
    function claimDividend() public returns (bool) {
        // unclaimed dividend fractions should expire after 330 days and the owner can reclaim that fraction
        require(dividendEndTime > 0 && dividendEndTime.sub(claimTimeout) > now);

        updateDividend(msg.sender);

        uint256 payment = unclaimedDividend[msg.sender];
        unclaimedDividend[msg.sender] = 0;

        msg.sender.transfer(payment);

        // Trigger payout event
        Payout(msg.sender, payment);

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
            lastUpdate[_hodler] = now;
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
        ChangedTreasurer(_treasurer, _active);
    }

    /**
     * @dev Request unclaimed ETH, payback to beneficiary (owner) wallet
     * dividend payment is possible every 330 days at the earliest - can be later, this allows for some flexibility,
     * e.g. board meeting had to happen a bit earlier this year than previous year.
     */
    function requestUnclaimed() public onlyOwner {
        // Send remaining ETH to beneficiary (back to owner) if dividend round is over
        require(now >= dividendEndTime.sub(claimTimeout));

        msg.sender.transfer(this.balance);

        Reclaimed(this.balance, dividendEndTime, now);
    }

    /**
     * @dev ETH Payin for Treasurer
     * Only owner or treasurer can do a payin for all token holder.
     * Owner / treasurer can also increase dividend by calling fallback function multiple times.
     */
    function() public payable {
        require(isTreasurer[msg.sender]);
        require(dividendEndTime < now);

        // pay back unclaimed dividend that might not have been claimed by owner yet
        if (this.balance > msg.value) {
            uint256 payout = this.balance.sub(msg.value);
            owner.transfer(payout);
            Reclaimed(payout, dividendEndTime, now);
        }

        currentDividend = this.balance;

        // No active dividend cycle found, initialize new round
        dividendEndTime = now.add(dividendCycleTime);

        // Trigger payin event
        Payin(msg.sender, msg.value, dividendEndTime);

        lastDividendIncreaseDate = now;
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

//File: src/contracts/ico/IcoToken.sol
/**
 * @title ICO token
 * @version 1.0
 * @author Validity Labs AG <info@validitylabs.org>
 */
pragma solidity ^0.4.18;





contract IcoToken is MintableToken, PausableToken, DividendToken {
    string public constant name = "Tend Token";
    string public constant symbol = "TND";
    uint8 public constant decimals = 18;

    /**
     * @dev Constructor of IcoToken that instantiate a new DividendToken
     */
    function IcoToken() public DividendToken() {
        // token should not be transferrable until after all tokens have been issued
        paused = true;
    }
}

//File: src/contracts/ico/IcoCrowdsale.sol
/**
 * @title IcoCrowdsale
 * Simple time and capped based crowdsale.
 *
 * @version 1.0
 * @author Validity Labs AG <info@validitylabs.org>
 */
pragma solidity ^0.4.18;







contract IcoCrowdsale is Crowdsale, Ownable {
    /*** CONSTANTS ***/
    // Different levels of caps per allotment
    uint256 public constant MAX_TOKEN_CAP = 13e6 * 1e18;        // 13 million * 1e18

    // // Bottom three should add to above
    uint256 public constant ICO_ENABLERS_CAP = 15e5 * 1e18;     // 1.5 million * 1e18
    uint256 public constant DEVELOPMENT_TEAM_CAP = 2e6 * 1e18;  // 2 million * 1e18
    uint256 public constant ICO_TOKEN_CAP = 9.5e6 * 1e18;        // 9.5 million  * 1e18

    uint256 public constant CHF_CENT_PER_TOKEN = 1000;          // standard CHF per token rate - in cents - 10 CHF => 1000 CHF cents
    uint256 public constant MIN_CONTRIBUTION_CHF = 250;

    uint256 public constant VESTING_CLIFF = 1 years;
    uint256 public constant VESTING_DURATION = 3 years;

    // Amount of discounted tokens per discount stage (2 stages total; each being the same amount)
    uint256 public constant DISCOUNT_TOKEN_AMOUNT_T1 = 3e6 * 1e18; // 3 million * 1e18
    uint256 public constant DISCOUNT_TOKEN_AMOUNT_T2 = DISCOUNT_TOKEN_AMOUNT_T1 * 2;

    // Track tokens depending which stage that the ICO is in
    uint256 public tokensToMint;            // tokens to be minted after confirmation
    uint256 public tokensMinted;            // already minted tokens (maximally = cap)
    uint256 public icoEnablersTokensMinted;
    uint256 public developmentTeamTokensMinted;

    uint256 public minContributionInWei;
    uint256 public tokenPerWei;
    uint256 public totalTokensPurchased;
    bool public capReached;
    bool public tier1Reached;
    bool public tier2Reached;

    address public underwriter;

    // allow managers to blacklist and confirm contributions by manager accounts
    // (managers can be set and altered by owner, multiple manager accounts are possible
    mapping(address => bool) public isManager;

    // true if addess is not allowed to invest
    mapping(address => bool) public isBlacklisted;

    uint256 public confirmationPeriod;
    bool public confirmationPeriodOver;     // can be set by owner to finish confirmation in under 30 days

    // for convenience we store vesting wallets
    address[] public vestingWallets;

    uint256 public investmentIdLastAttemptedToSettle;

    struct Payment {
        address investor;
        address beneficiary;
        uint256 weiAmount;
        uint256 tokenAmount;
        bool confirmed;
        bool attemptedSettlement;
        bool completedSettlement;
    }

    Payment[] public investments;

    /*** EVENTS ***/
    event ChangedInvestorBlacklisting(address investor, bool blacklisted);
    event ChangedManager(address manager, bool active);
    event ChangedInvestmentConfirmation(uint256 investmentId, address investor, bool confirmed);

    /*** MODIFIERS ***/
    modifier onlyUnderwriter() {
        require(msg.sender == underwriter);
        _;
    }

    modifier onlyManager() {
        require(isManager[msg.sender]);
        _;
    }

    modifier onlyNoneZero(address _to, uint256 _amount) {
        require(_to != address(0));
        require(_amount > 0);
        _;
    }

    modifier onlyConfirmPayment() {
        require(now > endTime && now <= endTime.add(confirmationPeriod));
        require(!confirmationPeriodOver);
        _;
    }

    modifier onlyConfirmationOver() {
        require(confirmationPeriodOver || now > endTime.add(confirmationPeriod));
        _;
    }

    /**
     * @dev Deploy capped ico crowdsale contract
     * @param _startTime uint256 Start time of the crowdsale
     * @param _endTime uint256 End time of the crowdsale
     * @param _rateChfPerEth uint256 CHF per ETH rate
     * @param _wallet address Wallet address of the crowdsale
     * @param _confirmationPeriodDays uint256 Confirmation period in days
     * @param _underwriter address of the underwriter
     */
    function IcoCrowdsale(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _rateChfPerEth,
        address _wallet,
        uint256 _confirmationPeriodDays,
        address _underwriter
    )
        public
        Crowdsale(_startTime, _endTime, _rateChfPerEth, _wallet)
    {
        require(MAX_TOKEN_CAP == ICO_ENABLERS_CAP.add(ICO_TOKEN_CAP).add(DEVELOPMENT_TEAM_CAP));
        require(_underwriter != address(0));

        setManager(msg.sender, true);

        tokenPerWei = (_rateChfPerEth.mul(1e2)).div(CHF_CENT_PER_TOKEN);
        minContributionInWei = (MIN_CONTRIBUTION_CHF.mul(1e18)).div(_rateChfPerEth);

        confirmationPeriod = _confirmationPeriodDays * 1 days;
        underwriter = _underwriter;
    }

    /**
     * @dev Set / alter manager / blacklister account. This can be done from owner only
     * @param _manager address address of the manager to create/alter
     * @param _active bool flag that shows if the manager account is active
     */
    function setManager(address _manager, bool _active) public onlyOwner {
        isManager[_manager] = _active;
        ChangedManager(_manager, _active);
    }

    /**
     * @dev blacklist investor from participating in the crowdsale
     * @param _investor address address of the investor to disallowed participation
     */
    function blackListInvestor(address _investor, bool _active) public onlyManager {
        isBlacklisted[_investor] = _active;
        ChangedInvestorBlacklisting(_investor, _active);
    }

    /**
     * @dev override (not extend! because we only issues tokens after final KYC confirm phase)
     *      core functionality by blacklist check and registration of payment
     * @param _beneficiary address address of the beneficiary to receive tokens after they have been confirmed
     */
    function buyTokens(address _beneficiary) public payable {
        require(_beneficiary != address(0));
        require(validPurchase());
        require(!isBlacklisted[msg.sender]);

        uint256 weiAmount = msg.value;
        uint256 tokenAmount;
        uint256 purchasedTokens = weiAmount.mul(tokenPerWei);
        uint256 tempTotalTokensPurchased = totalTokensPurchased.add(purchasedTokens);
        uint256 overflowTokens;
        uint256 overflowTokens2;
        // 20% discount bonus amount
        uint256 tier1BonusTokens;
        // 10% discount bonus amount
        uint256 tier2BonusTokens;

        // tier 1 20% discount - 1st 3 million tokens purchased
        if (!tier1Reached) {

            // tx tokens overflowed into next tier 2 - 10% discount - mark tier1Reached! else all tokens are tier 1 discounted
            if (tempTotalTokensPurchased > DISCOUNT_TOKEN_AMOUNT_T1) {
                tier1Reached = true;
                overflowTokens = tempTotalTokensPurchased.sub(DISCOUNT_TOKEN_AMOUNT_T1);
                tier1BonusTokens = purchasedTokens.sub(overflowTokens);
            // tx tokens did not overflow into next tier 2 (10% discount)
            } else {
                tier1BonusTokens = purchasedTokens;
            }
            //apply discount
            tier1BonusTokens = tier1BonusTokens.mul(10).div(8);
            tokenAmount = tokenAmount.add(tier1BonusTokens);
        }

        // tier 2 10% discount - 2nd 3 million tokens purchased
        if (tier1Reached && !tier2Reached) {

            // tx tokens overflowed into next tier 3 - 0% - marked tier2Reached! else all tokens are tier 2 discounted
            if (tempTotalTokensPurchased > DISCOUNT_TOKEN_AMOUNT_T2) {
                tier2Reached = true;
                overflowTokens2 = tempTotalTokensPurchased.sub(DISCOUNT_TOKEN_AMOUNT_T2);
                tier2BonusTokens = purchasedTokens.sub(overflowTokens2);
            // tx tokens did not overflow into next tier 3 (tier 3 == no discount)
            } else {
                // tokens overflowed from tier1 else this tx started in tier2
                if (overflowTokens > 0) {
                    tier2BonusTokens = overflowTokens;
                } else {
                    tier2BonusTokens = purchasedTokens;
                }
            }
            // apply discount for tier 2 tokens
            tier2BonusTokens = tier2BonusTokens.mul(10).div(9);
            tokenAmount = tokenAmount.add(tier2BonusTokens).add(overflowTokens2);
        }

        // this triggers when both tier 1 and tier 2 discounted tokens have be filled - but ONLY afterwards, not if the flags got set during the same tx
        // aka this is tier 3
        if (tier2Reached && tier1Reached && tier2BonusTokens == 0) {
            tokenAmount = purchasedTokens;
        }

        /*** Record & update state variables  ***/
        // Tracks purchased tokens for 2 tiers of discounts
        totalTokensPurchased = totalTokensPurchased.add(purchasedTokens);
        // Tracks total tokens pending to be minted - this includes presale tokens
        tokensToMint = tokensToMint.add(tokenAmount);

        weiRaised = weiRaised.add(weiAmount);

        TokenPurchase(msg.sender, _beneficiary, weiAmount, tokenAmount);

        // register payment so that later on it can be confirmed (and tokens issued and Ether paid out)
        Payment memory newPayment = Payment(msg.sender, _beneficiary, weiAmount, tokenAmount, false, false, false);
        investments.push(newPayment);
    }

    /**
     * @dev confirms payment
     * @param _investmentId uint256 uint256 of the investment id to confirm
     */
    function confirmPayment(uint256 _investmentId) public onlyManager onlyConfirmPayment {
        investments[_investmentId].confirmed = true;
        ChangedInvestmentConfirmation(_investmentId, investments[_investmentId].investor, true);
    }

    /**
     * @dev confirms payments via a batch method
     * @param _investmentIds uint256[] array of uint256 of the investment ids to confirm
     */
    function batchConfirmPayments(uint256[] _investmentIds) public onlyManager onlyConfirmPayment {
        uint256 investmentId;

        for (uint256 c; c < _investmentIds.length; c = c.add(1)) {
            investmentId = _investmentIds[c]; // gas optimization
            confirmPayment(investmentId);
        }
    }

    /**
     * @dev unconfirms payment made via investment id
     * @param _investmentId uint256 uint256 of the investment to unconfirm
     */
    function unConfirmPayment(uint256 _investmentId) public onlyManager onlyConfirmPayment {
        investments[_investmentId].confirmed = false;
        ChangedInvestmentConfirmation(_investmentId, investments[_investmentId].investor, false);
    }

   /**
    * @dev allows contract owner to mint tokens for presale or non-ETH contributions in batches
     * @param _toList address[] array of the beneficiaries to receive tokens
     * @param _tokenList uint256[] array of the token amounts to mint for the corresponding users
    */
    function batchMintTokenDirect(address[] _toList, uint256[] _tokenList) public onlyOwner {
        require(_toList.length == _tokenList.length);

        for (uint256 i; i < _toList.length; i = i.add(1)) {
            mintTokenDirect(_toList[i], _tokenList[i]);
        }
    }

    /**
     * @dev allows contract owner to mint tokens for presale or non-ETH contributions
     * @param _to address of the beneficiary to receive tokens
     * @param _tokens uint256 of the token amount to mint
     */
    function mintTokenDirect(address _to, uint256 _tokens) public onlyOwner {
        require(tokensToMint.add(_tokens) <= ICO_TOKEN_CAP);

        tokensToMint = tokensToMint.add(_tokens);

        // register payment so that later on it can be confirmed (and tokens issued and Ether paid out)
        Payment memory newPayment = Payment(address(0), _to, 0, _tokens, false, false, false);
        investments.push(newPayment);
        TokenPurchase(msg.sender, _to, 0, _tokens);
    }

    /**
     * @dev allows contract owner to mint tokens for ICO enablers respecting the ICO_ENABLERS_CAP (no vesting)
     * @param _to address for beneficiary
     * @param _tokens uint256 token amount to mint
     */
    function mintIcoEnablersTokens(address _to, uint256 _tokens) public onlyOwner onlyNoneZero(_to, _tokens) {
        require(icoEnablersTokensMinted.add(_tokens) <= ICO_ENABLERS_CAP);

        token.mint(_to, _tokens);
        icoEnablersTokensMinted = icoEnablersTokensMinted.add(_tokens);
    }

    /**
     * @dev allows contract owner to mint team tokens per DEVELOPMENT_TEAM_CAP and transfer to the development team's wallet (yes vesting)
     * @param _to address for beneficiary
     * @param _tokens uint256 token amount to mint
     */
    function mintDevelopmentTeamTokens(address _to, uint256 _tokens) public onlyOwner onlyNoneZero(_to, _tokens) {
        require(developmentTeamTokensMinted.add(_tokens) <= DEVELOPMENT_TEAM_CAP);

        developmentTeamTokensMinted = developmentTeamTokensMinted.add(_tokens);
        TokenVesting newVault = new TokenVesting(_to, now, VESTING_CLIFF, VESTING_DURATION, false);
        vestingWallets.push(address(newVault)); // for convenience we keep them in storage so that they are easily accessible via MEW or etherscan
        token.mint(address(newVault), _tokens);
    }

    /**
     * @dev returns number of elements in the vestinWallets array
     */
    function getVestingWalletLength() public view returns (uint256) {
        return vestingWallets.length;
    }

    /**
     * @dev set final the confirmation period
     */
    function finalizeConfirmationPeriod() public onlyOwner onlyConfirmPayment {
        confirmationPeriodOver = true;
    }

    /**
     * @dev settlement of investment made via investment id
     * @param _investmentId uint256 uint256 being the investment id
     */
    function settleInvestment(uint256 _investmentId) public onlyConfirmationOver {
        Payment storage p = investments[_investmentId];

        // investment should not be settled already (prevent double token issueing or repayment)
        require(!p.completedSettlement);

        // investments have to be processed in right order
        // unless we're at first investment, the previous has needs to have undergone an attempted settlement

        require(_investmentId == 0 || investments[_investmentId.sub(1)].attemptedSettlement);

        p.attemptedSettlement = true;

        // just so that we can see which one we attempted last time and can continue with next
        investmentIdLastAttemptedToSettle = _investmentId;

        if (p.confirmed && !capReached) {
            // if confirmed -> issue tokens, send ETH to wallet and complete settlement

            // calculate number of tokens to be issued to investor
            uint256 tokens = p.tokenAmount;

            // check to see if this purchase sets it over the crowdsale token cap
            // if so, refund
            if (tokensMinted.add(tokens) > ICO_TOKEN_CAP) {
                capReached = true;
                if (p.weiAmount > 0) {
                    p.investor.send(p.weiAmount); // does not throw (otherwise we'd block all further settlements)
                }
            } else {
                tokensToMint = tokensToMint.sub(tokens);
                tokensMinted = tokensMinted.add(tokens);

                // mint tokens for beneficiary
                token.mint(p.beneficiary, tokens);
                if (p.weiAmount > 0) {
                    // send Ether to project wallet (throws if wallet throws)
                    wallet.transfer(p.weiAmount);
                }
            }

            p.completedSettlement = true;
        } else {
            // if not confirmed -> reimburse ETH or if fiat (presale) investor: do nothing
            // only complete settlement if investor got their money back
            // (does not throw (as .transfer would)
            // otherwise we would block settlement process of all following investments)
            if (p.investor != address(0) && p.weiAmount > 0) {
                if (p.investor.send(p.weiAmount)) {
                    p.completedSettlement = true;
                }
            }
        }
    }

    /**
     * @dev allows the batch settlement of investments made
     * @param _investmentIds uint256[] array of uint256 of investment ids
     */
    function batchSettleInvestments(uint256[] _investmentIds) public {
        for (uint256 c; c < _investmentIds.length; c = c.add(1)) {
            settleInvestment(_investmentIds[c]);
        }
    }

    /**
     * @dev allows contract owner to finalize the ICO, unpause tokens, set treasurer, finish minting, and transfer ownship of the token contract
     */
    function finalize() public onlyUnderwriter onlyConfirmationOver {
        Pausable(token).unpause();

        // this crowdsale also should not be treasurer of the token anymore
        IcoToken(token).setTreasurer(this, false);

        // do not allow new owner to mint further tokens
        MintableToken(token).finishMinting();

        // until now the owner of the token is this crowdsale contract
        // in order for a human owner to make use of the tokens onlyOwner functions
        // we need to transfer the ownership
        // in the end the owner of this crowdsale will also be the owner of the token
        Ownable(token).transferOwnership(owner);
    }

    /**
     * @dev Create new instance of ico token contract
     */
    function createTokenContract() internal returns (MintableToken) {
        return new IcoToken();
    }

    /**
     * @dev extend base functionality with min investment amount
     */
    function validPurchase() internal view returns (bool) {
        // minimal investment: 250 CHF (represented in wei)
        require (msg.value >= minContributionInWei);
        return super.validPurchase();
    }
}