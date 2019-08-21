pragma solidity 0.4.15;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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

/**
 * @title PausableOnce
 * @dev The PausableOnce contract provides an option for the "pauseMaster"
 * to pause once the transactions for two weeks.
 *
 */

contract PausableOnce is Ownable {

    /** Address that can start the pause */
    address public pauseMaster;

    uint constant internal PAUSE_DURATION = 14 days;
    uint64 public pauseEnd = 0;

    event Paused();

    /**
     * @dev Set the pauseMaster (callable by the owner only).
     * @param _pauseMaster The address of the pauseMaster
     */
    function setPauseMaster(address _pauseMaster) onlyOwner external returns (bool success) {
        require(_pauseMaster != address(0));
        pauseMaster = _pauseMaster;
        return true;
    }

    /**
     * @dev Start the pause (by the pauseMaster, ONCE only).
     */
    function pause() onlyPauseMaster external returns (bool success) {
        require(pauseEnd == 0);
        pauseEnd = uint64(now + PAUSE_DURATION);
        Paused();
        return true;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(now > pauseEnd);
        _;
    }

    /**
     * @dev Throws if called by any account other than the pauseMaster.
     */
    modifier onlyPauseMaster() {
        require(msg.sender == pauseMaster);
        _;
    }

}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
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

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
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

/**
* @title Upgrade agent interface
*/
contract InterfaceUpgradeAgent {

    uint32 public revision;
    uint256 public originalSupply;

    /**
     * @dev Reissue the tokens onto the new contract revision.
     * @param holder Holder (owner) of the tokens
     * @param tokenQty How many tokens to be issued
     */
    function upgradeFrom(address holder, uint256 tokenQty) public;
}

/**
 * @title UpgradableToken
 * @dev The UpgradableToken contract provides an option of upgrading the tokens to a new revision.
 * The "upgradeMaster" may propose the upgrade. Token holders can opt-in amount of tokens to upgrade.
 */

contract UpgradableToken is StandardToken, Ownable {

    using SafeMath for uint256;

    uint32 public REVISION;

    /** Address that can set the upgrade agent thus enabling the upgrade. */
    address public upgradeMaster = address(0);

    /** Address of the contract that issues the new revision tokens. */
    address public upgradeAgent = address(0);

    /** How many tokens are upgraded. */
    uint256 public totalUpgraded;

    event Upgrade(address indexed _from, uint256 _value);
    event UpgradeEnabled(address agent);

    /**
     * @dev Set the upgrade master.
     * parameter _upgradeMaster Upgrade master
     */
    function setUpgradeMaster(address _upgradeMaster) onlyOwner external {
        require(_upgradeMaster != address(0));
        upgradeMaster = _upgradeMaster;
    }

    /**
     * @dev Set the upgrade agent (once only) thus enabling the upgrade.
     * @param _upgradeAgent Upgrade agent contract address
     * @param _revision Unique ID that agent contract must return on ".revision()"
     */
    function setUpgradeAgent(address _upgradeAgent, uint32 _revision)
        onlyUpgradeMaster whenUpgradeDisabled external
    {
        require((_upgradeAgent != address(0)) && (_revision != 0));

        InterfaceUpgradeAgent agent = InterfaceUpgradeAgent(_upgradeAgent);

        require(agent.revision() == _revision);
        require(agent.originalSupply() == totalSupply);

        upgradeAgent = _upgradeAgent;
        UpgradeEnabled(_upgradeAgent);
    }

    /**
     * @dev Upgrade tokens to the new revision.
     * @param value How many tokens to be upgraded
     */
    function upgrade(uint256 value) whenUpgradeEnabled external {
        require(value > 0);

        uint256 balance = balances[msg.sender];
        require(balance > 0);

        // Take tokens out from the old contract
        balances[msg.sender] = balance.sub(value);
        totalSupply = totalSupply.sub(value);
        totalUpgraded = totalUpgraded.add(value);
        // Issue the new revision tokens
        InterfaceUpgradeAgent agent = InterfaceUpgradeAgent(upgradeAgent);
        agent.upgradeFrom(msg.sender, value);

        Upgrade(msg.sender, value);
    }

    /**
    * @dev Modifier to make a function callable only when the upgrade is enabled.
    */
    modifier whenUpgradeEnabled() {
        require(upgradeAgent != address(0));
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the upgrade is impossible.
    */
    modifier whenUpgradeDisabled() {
        require(upgradeAgent == address(0));
        _;
    }

    /**
    * @dev Throws if called by any account other than the upgradeMaster.
    */
    modifier onlyUpgradeMaster() {
        require(msg.sender == upgradeMaster);
        _;
    }

}

/**
 * @title Withdrawable
 * @dev The Withdrawable contract provides a mechanism of withdrawal(s).
 * "Withdrawals" are permissions for specified addresses to pull (withdraw) payments from the contract balance.
 */

contract Withdrawable {

    mapping (address => uint) pendingWithdrawals;

    /*
     * @dev Logged upon a granted allowance to the specified drawer on withdrawal.
     * @param drawer The address of the drawer.
     * @param weiAmount The value in Wei which may be withdrawn.
     */
    event Withdrawal(address indexed drawer, uint256 weiAmount);

    /*
     * @dev Logged upon a withdrawn value.
     * @param drawer The address of the drawer.
     * @param weiAmount The value in Wei which has been withdrawn.
     */
    event Withdrawn(address indexed drawer, uint256 weiAmount);

    /*
     * @dev Allow the specified drawer to withdraw the specified value from the contract balance.
     * @param drawer The address of the drawer.
     * @param weiAmount The value in Wei allowed to withdraw.
     * @return success
     */
    function setWithdrawal(address drawer, uint256 weiAmount) internal returns (bool success) {
        if ((drawer != address(0)) && (weiAmount > 0)) {
            uint256 oldBalance = pendingWithdrawals[drawer];
            uint256 newBalance = oldBalance + weiAmount;
            if (newBalance > oldBalance) {
                pendingWithdrawals[drawer] = newBalance;
                Withdrawal(drawer, weiAmount);
                return true;
            }
        }
        return false;
    }

    /*
     * @dev Withdraw the allowed value from the contract balance.
     * @return success
     */
    function withdraw() public returns (bool success) {
        uint256 weiAmount = pendingWithdrawals[msg.sender];
        require(weiAmount > 0);

        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(weiAmount);
        Withdrawn(msg.sender, weiAmount);
        return true;
    }

}

/**
 * @title Cointed Token
 * @dev Cointed Token (CTD) and Token Sale (ICO).
 */

contract CtdToken is UpgradableToken, PausableOnce, Withdrawable {

    using SafeMath for uint256;

    string public constant name = "Cointed Token";
    string public constant symbol = "CTD";
    /** Number of "Atom" in 1 CTD (1 CTD = 1x10^decimals Atom) */
    uint8  public constant decimals = 18;

    /** Holder of bounty tokens */
    address public bounty;

    /** Limit (in Atom) issued, inclusive owner's and bounty shares */
    uint256 constant internal TOTAL_LIMIT   = 650000000 * (10 ** uint256(decimals));
    /** Limit (in Atom) for Pre-ICO Phases A, incl. owner's and bounty shares */
    uint256 constant internal PRE_ICO_LIMIT = 130000000 * (10 ** uint256(decimals));

    /**
    * ICO Phases.
    *
    * - PreStart: tokens are not yet sold/issued
    * - PreIcoA:  new tokens sold/issued at the premium price
    * - PreIcoB:  new tokens sold/issued at the discounted price
    * - MainIco   new tokens sold/issued at the regular price
    * - AfterIco: new tokens can not be not be sold/issued any longer
    */
    enum Phases {PreStart, PreIcoA, PreIcoB, MainIco, AfterIco}

    uint64 constant internal PRE_ICO_DURATION = 745 hours;
    uint64 constant internal ICO_DURATION = 2423 hours + 59 minutes;
    uint64 constant internal RETURN_WEI_PAUSE = 30 days;

    // Main ICO rate in CTD(s) per 1 ETH:
    uint256 constant internal TO_SENDER_RATE   = 1000;
    uint256 constant internal TO_OWNER_RATE    =  263;
    uint256 constant internal TO_BOUNTY_RATE   =   52;
    uint256 constant internal TOTAL_RATE   =   TO_SENDER_RATE + TO_OWNER_RATE + TO_BOUNTY_RATE;
    // Pre-ICO Phase A rate
    uint256 constant internal TO_SENDER_RATE_A = 1150;
    uint256 constant internal TO_OWNER_RATE_A  =  304;
    uint256 constant internal TO_BOUNTY_RATE_A =   61;
    uint256 constant internal TOTAL_RATE_A   =   TO_SENDER_RATE_A + TO_OWNER_RATE_A + TO_BOUNTY_RATE_A;
    // Pre-ICO Phase B rate
    uint256 constant internal TO_SENDER_RATE_B = 1100;
    uint256 constant internal TO_OWNER_RATE_B  =  292;
    uint256 constant internal TO_BOUNTY_RATE_B =   58;
    uint256 constant internal TOTAL_RATE_B   =   TO_SENDER_RATE_B + TO_OWNER_RATE_B + TO_BOUNTY_RATE_B;

    // Award in Wei(s) to a successful initiator of a Phase shift
    uint256 constant internal PRE_OPENING_AWARD = 100 * (10 ** uint256(15));
    uint256 constant internal ICO_OPENING_AWARD = 200 * (10 ** uint256(15));
    uint256 constant internal ICO_CLOSING_AWARD = 500 * (10 ** uint256(15));

    struct Rates {
        uint256 toSender;
        uint256 toOwner;
        uint256 toBounty;
        uint256 total;
    }

    event NewTokens(uint256 amount);
    event NewFunds(address funder, uint256 value);
    event NewPhase(Phases phase);

    // current Phase
    Phases public phase = Phases.PreStart;

    // Timestamps limiting duration of Phases, in seconds since Unix epoch.
    uint64 public preIcoOpeningTime;  // when Pre-ICO Phase A starts
    uint64 public icoOpeningTime;     // when Main ICO starts (if not sold out before)
    uint64 public closingTime;        // by when the ICO campaign finishes in any way
    uint64 public returnAllowedTime;  // when owner may withdraw Eth from contract, if any

    uint256 public totalProceeds;

    /*
     * @dev constructor
     * @param _preIcoOpeningTime Timestamp when the Pre-ICO (Phase A) shall start.
     * msg.value MUST be at least the sum of awards.
     */
    function CtdToken(uint64 _preIcoOpeningTime) payable {
        require(_preIcoOpeningTime > now);

        preIcoOpeningTime = _preIcoOpeningTime;
        icoOpeningTime = preIcoOpeningTime + PRE_ICO_DURATION;
        closingTime = icoOpeningTime + ICO_DURATION;
    }

    /*
     * @dev Fallback function delegates the request to create().
     */
    function () payable external {
        create();
    }

    /**
     * @dev Set the address of the holder of bounty tokens.
     * @param _bounty The address of the bounty token holder.
     * @return success/failure
     */
    function setBounty(address _bounty) onlyOwner external returns (bool success) {
        require(_bounty != address(0));
        bounty = _bounty;
        return true;
    }

    /**
     * @dev Mint tokens and add them to the balance of the message.sender.
     * Additional tokens are minted and added to the owner and the bounty balances.
     * @return success/failure
     */
    function create() payable whenNotClosed whenNotPaused public returns (bool success) {
        require(msg.value > 0);
        require(now >= preIcoOpeningTime);

        Phases oldPhase = phase;
        uint256 weiToParticipate = msg.value;
        uint256 overpaidWei;

        adjustPhaseBasedOnTime();

        if (phase != Phases.AfterIco) {

            Rates memory rates = getRates();
            uint256 newTokens = weiToParticipate.mul(rates.total);
            uint256 requestedSupply = totalSupply.add(newTokens);

            uint256 oversoldTokens = computeOversoldAndAdjustPhase(requestedSupply);
            overpaidWei = (oversoldTokens > 0) ? oversoldTokens.div(rates.total) : 0;

            if (overpaidWei > 0) {
                weiToParticipate = msg.value.sub(overpaidWei);
                newTokens = weiToParticipate.mul(rates.total);
                requestedSupply = totalSupply.add(newTokens);
            }

            // "emission" of new tokens
            totalSupply = requestedSupply;
            balances[msg.sender] = balances[msg.sender].add(weiToParticipate.mul(rates.toSender));
            balances[owner] = balances[owner].add(weiToParticipate.mul(rates.toOwner));
            balances[bounty] = balances[bounty].add(weiToParticipate.mul(rates.toBounty));

            // ETH transfers
            totalProceeds = totalProceeds.add(weiToParticipate);
            owner.transfer(weiToParticipate);
            if (overpaidWei > 0) {
                setWithdrawal(msg.sender, overpaidWei);
            }

            // Logging
            NewTokens(newTokens);
            NewFunds(msg.sender, weiToParticipate);

        } else {
            setWithdrawal(msg.sender, msg.value);
        }

        if (phase != oldPhase) {
            logShiftAndBookAward();
        }

        return true;
    }

    /**
     * @dev Send the value (ethers) that the contract holds to the owner address.
     */
    function returnWei() onlyOwner whenClosed afterWithdrawPause external {
        owner.transfer(this.balance);
    }

    function adjustPhaseBasedOnTime() internal {

        if (now >= closingTime) {
            if (phase != Phases.AfterIco) {
                phase = Phases.AfterIco;
            }
        } else if (now >= icoOpeningTime) {
            if (phase != Phases.MainIco) {
                phase = Phases.MainIco;
            }
        } else if (phase == Phases.PreStart) {
            setDefaultParamsIfNeeded();
            phase = Phases.PreIcoA;
        }
    }

    function setDefaultParamsIfNeeded() internal {
        if (bounty == address(0)) {
            bounty = owner;
        }
        if (upgradeMaster == address(0)) {
            upgradeMaster = owner;
        }
        if (pauseMaster == address(0)) {
            pauseMaster = owner;
        }
    }

    function computeOversoldAndAdjustPhase(uint256 newTotalSupply) internal returns (uint256 oversoldTokens) {

        if ((phase == Phases.PreIcoA) &&
            (newTotalSupply >= PRE_ICO_LIMIT)) {
            phase = Phases.PreIcoB;
            oversoldTokens = newTotalSupply.sub(PRE_ICO_LIMIT);

        } else if (newTotalSupply >= TOTAL_LIMIT) {
            phase = Phases.AfterIco;
            oversoldTokens = newTotalSupply.sub(TOTAL_LIMIT);

        } else {
            oversoldTokens = 0;
        }

        return oversoldTokens;
    }

    function getRates() internal returns (Rates rates) {

        if (phase == Phases.PreIcoA) {
            rates.toSender = TO_SENDER_RATE_A;
            rates.toOwner = TO_OWNER_RATE_A;
            rates.toBounty = TO_BOUNTY_RATE_A;
            rates.total = TOTAL_RATE_A;
        } else if (phase == Phases.PreIcoB) {
            rates.toSender = TO_SENDER_RATE_B;
            rates.toOwner = TO_OWNER_RATE_B;
            rates.toBounty = TO_BOUNTY_RATE_B;
            rates.total = TOTAL_RATE_B;
        } else {
            rates.toSender = TO_SENDER_RATE;
            rates.toOwner = TO_OWNER_RATE;
            rates.toBounty = TO_BOUNTY_RATE;
            rates.total = TOTAL_RATE;
        }
        return rates;
    }

    function logShiftAndBookAward() internal {
        uint256 shiftAward;

        if ((phase == Phases.PreIcoA) || (phase == Phases.PreIcoB)) {
            shiftAward = PRE_OPENING_AWARD;

        } else if (phase == Phases.MainIco) {
            shiftAward = ICO_OPENING_AWARD;

        } else {
            shiftAward = ICO_CLOSING_AWARD;
            returnAllowedTime = uint64(now + RETURN_WEI_PAUSE);
        }

        setWithdrawal(msg.sender, shiftAward);
        NewPhase(phase);
    }

    /**
     * @dev Transfer tokens to the specified address.
     * @param _to The address to transfer to.
     * @param _value The amount of tokens to be transferred.
     * @return success/failure
     */
    function transfer(address _to, uint256 _value)
        whenNotPaused limitForOwner public returns (bool success)
    {
        return super.transfer(_to, _value);
    }

    /**
     * @dev Transfer tokens from one address to another.
     * @param _from address The address which you want to send tokens from.
     * @param _to address The address which you want to transfer to.
     * @param _value the amount of tokens to be transferred.
     * @return success/failure
     */
    function transferFrom(address _from, address _to, uint256 _value)
        whenNotPaused limitForOwner public returns (bool success)
    {
        return super.transferFrom(_from, _to, _value);
    }

    /**
     * @dev Approve the specified address to spend the specified amount of tokens on behalf of the msg.sender.
     * Use "increaseApproval" or "decreaseApproval" function to change the approval, if needed.
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     * @return success/failure
     */
    function approve(address _spender, uint256 _value)
        whenNotPaused limitForOwner public returns (bool success)
    {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        return super.approve(_spender, _value);
    }

    /**
     * @dev Increase the approval for the passed address to spend tokens on behalf of the msg.sender.
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the approval with.
     * @return success/failure
     */
    function increaseApproval(address _spender, uint _addedValue)
        whenNotPaused limitForOwner public returns (bool success)
    {
        return super.increaseApproval(_spender, _addedValue);
    }

    /**
     * @dev Decrease the approval for the passed address to spend tokens on behalf of the msg.sender.
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the approval with.
     * @return success/failure
     */
    function decreaseApproval(address _spender, uint _subtractedValue)
        whenNotPaused limitForOwner public returns (bool success)
    {
        return super.decreaseApproval(_spender, _subtractedValue);
    }

    /*
     * @dev Withdraw the allowed value (ethers) from the contract balance.
     * @return success/failure
     */
    function withdraw() whenNotPaused public returns (bool success) {
        return super.withdraw();
    }

    /**
     * @dev Throws if called when ICO is active.
     */
    modifier whenClosed() {
        require(phase == Phases.AfterIco);
        _;
    }

    /**
     * @dev Throws if called when ICO is completed.
     */
    modifier whenNotClosed() {
        require(phase != Phases.AfterIco);
        _;
    }

    /**
     * @dev Throws if called by the owner before ICO is completed.
     */
    modifier limitForOwner() {
        require((msg.sender != owner) || (phase == Phases.AfterIco));
        _;
    }

    /**
     * @dev Throws if called before returnAllowedTime.
     */
    modifier afterWithdrawPause() {
        require(now > returnAllowedTime);
        _;
    }

}