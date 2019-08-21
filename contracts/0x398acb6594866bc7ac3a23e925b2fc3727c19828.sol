pragma solidity ^0.4.18;

// File: zeppelin-solidity/contracts/math/SafeMath.sol

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

// File: contracts/Discounts.sol

library Discounts {
  using SafeMath for uint256;

  /**************************************************************************
   * TYPES
   *************************************************************************/

  /*
   * Top-level struct for grouping of tiers with a base purchase rate
   */
  struct Collection {
    Tier[] tiers;

    // number of tokens per wei
    uint256 baseRate;
  }

  /*
   * Struct for a given tier - discount and availability
   */
  struct Tier {
    // discount the set purchase price, expressed in basis points (‱)
    // range (0‱ .. 10,000‱) corresponds to (0.00% .. 100.00%)
    uint256 discount;

    // number of remaining available tokens in tier
    uint256 available;
  }

  // upper-bound of basis point scale
  uint256 public constant MAX_DISCOUNT = 10000;


  /**************************************************************************
   * CREATE
   *************************************************************************/

  /*
   * @dev Add a new tier at the end of the list
   * @param _discount - Discount in basis points
   * @param _available - Available supply at tier
   */
  function addTier(
    Collection storage self,
    uint256 _discount,
    uint256 _available
  )
    internal
  {
    self.tiers.push(Tier({
      discount: _discount,
      available: _available
    }));
  }


  /**************************************************************************
   * PURCHASE
   *************************************************************************/

  /*
   * @dev Subtracts supply from tiers starting at a minimum, using up funds
   * @param _amount - Maximum number of tokens to purchase
   * @param _funds - Allowance in Wei
   * @param _minimumTier - Minimum tier to start purchasing from
   * @return Total tokens purchased and remaining funds in wei
   */
  function purchaseTokens(
    Collection storage self,
    uint256 _amount,
    uint256 _funds,
    uint256 _minimumTier
  )
    internal
    returns (
      uint256 purchased,
      uint256 remaining
    )
  {
    uint256 issue = 0; // tracks total tokens to issue
    remaining = _funds;

    uint256 available;  // var for available tokens at tier
    uint256 spend; // amount spent at tier
    uint256 affordable;  // var for # funds can pay for at tier
    uint256 purchase; // var for # to purchase at tier

    // for each tier starting at minimum
    // draw from the sent funds and count tokens to issue
    for (var i = _minimumTier; i < self.tiers.length && issue < _amount; i++) {
      // get the available tokens left at each tier
      available = self.tiers[i].available;

      // compute the maximum tokens that the funds can pay for
      affordable = _computeTokensPurchasedAtTier(self, i, remaining);

      // either purchase what the funds can afford, or the whole supply
      // at the tier
      if (affordable < available) {
        purchase = affordable;
      } else {
        purchase = available;
      }

      // limit the amount purchased up to specified amount
      // use safemath here in case of unknown overflow risk
      if (purchase.add(issue) > _amount) {
        purchase = _amount.sub(issue);
      }

      spend = _computeCostForTokensAtTier(self, i, purchase);

      // decrease available supply at tier
      self.tiers[i].available -= purchase;

      // increase tokens to issue
      issue += purchase;

      // decrement funds to proceed
      remaining -= spend;
    }

    return (issue, remaining);
  }


  /**************************************************************************
   * PRICE MATH
   *************************************************************************/

  // @return total number of tokens for an amount of wei, discount-adjusted
  function _computeTokensPurchasedAtTier(
    Collection storage self,
    uint256 _tier,
    uint256 _wei
  )
    private
    view
    returns (uint256)
  {
    var paidBasis = MAX_DISCOUNT.sub(self.tiers[_tier].discount);

    return _wei.mul(self.baseRate).mul(MAX_DISCOUNT) / paidBasis;
  }

  // @return cost in wei for that many tokens
  function _computeCostForTokensAtTier(
    Collection storage self,
    uint256 _tier,
    uint256 _tokens
  )
    private
    view
    returns (uint256)
  {
    var paidBasis = MAX_DISCOUNT.sub(self.tiers[_tier].discount);

    var numerator = _tokens.mul(paidBasis);
    var denominator = MAX_DISCOUNT.mul(self.baseRate);

    var floor = _tokens.mul(paidBasis).div(
      MAX_DISCOUNT.mul(self.baseRate)
    );

    // must round up cost to next wei (cause token computation rounds down)
    if (numerator % denominator != 0) {
      floor = floor + 1;
    }

    return floor;
  }
}

// File: contracts/Limits.sol

library Limits {
  using SafeMath for uint256;

  struct PurchaseRecord {
    uint256 blockNumber;
    uint256 amount;
  }

  struct Window {
    uint256 amount;  // # of tokens
    uint256 duration;  // # of blocks

    mapping (address => PurchaseRecord) purchases;
  }

  /*
   * Record a purchase towards a purchaser's cap limit
   * @dev resets the purchaser's cap if the window duration has been met
   * @param _participant - purchaser
   * @param _amount - token amount of new purchase
   */
  function recordPurchase(
    Window storage self,
    address _participant,
    uint256 _amount
  )
    internal
  {
    var blocksLeft = getBlocksUntilReset(self, _participant);
    var record = self.purchases[_participant];

    if (blocksLeft == 0) {
      record.amount = _amount;
      record.blockNumber = block.number;
    } else {
      record.amount = record.amount.add(_amount);
    }
  }

  /*
   * Retrieve the current limit for a given participant, based on previous
   * purchase history
   * @param _participant - Purchaser
   * @return amount of tokens left for participant with cap
   */
  function getLimit(Window storage self, address _participant)
    public
    view
    returns (uint256 _amount)
  {
    var blocksLeft = getBlocksUntilReset(self, _participant);

    if (blocksLeft == 0) {
      return self.amount;
    } else {
      return self.amount.sub(self.purchases[_participant].amount);
    }
  }

  function getBlocksUntilReset(Window storage self, address _participant)
    public
    view
    returns (uint256 _blocks)
  {
    var expires = self.purchases[_participant].blockNumber + self.duration;
    if (block.number > expires) {
      return 0;
    } else {
      return expires - block.number;
    }
  }
}

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: zeppelin-solidity/contracts/ownership/Claimable.sol

/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
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
    pendingOwner = address(0);
  }
}

// File: contracts/SeeToken.sol

/**
 * @title SEE Token
 * Not a full ERC20 token - prohibits transferring. Serves as a record of
 * account, to redeem for real tokens after launch.
 */
contract SeeToken is Claimable {
  using SafeMath for uint256;

  string public constant name = "See Presale Token";
  string public constant symbol = "SEE";
  uint8 public constant decimals = 18;

  uint256 public totalSupply;
  mapping (address => uint256) balances;

  event Issue(address to, uint256 amount);

  /**
   * @dev Issue new tokens
   * @param _to The address that will receive the minted tokens
   * @param _amount the amount of new tokens to issue
   */
  function issue(address _to, uint256 _amount) onlyOwner public {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);

    Issue(_to, _amount);
  }

  /**
   * @dev Get the balance for a particular token holder
   * @param _holder The token holder's address
   * @return The holder's balance
   */
  function balanceOf(address _holder) public view returns (uint256 balance) {
    balance = balances[_holder];
  }
}

// File: zeppelin-solidity/contracts/lifecycle/Pausable.sol

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

// File: contracts/Presale.sol

contract Presale is Claimable, Pausable {
  using Discounts for Discounts.Collection;
  using Limits for Limits.Window;

  struct Participant {
    bool authorized;

    uint256 minimumTier;
  }


  /**************************************************************************
   * STORAGE / EVENTS
   *************************************************************************/

  SeeToken token;
  Discounts.Collection discounts;
  Limits.Window cap;

  mapping (address => Participant) participants;


  event Tier(uint256 discount, uint256 available);


  /**************************************************************************
   * CONSTRUCTOR / LIFECYCLE
   *************************************************************************/

  function Presale(address _token)
    public
  {
    token = SeeToken(_token);

    paused = true;
  }

  /*
   * @dev (Done as part of migration) Claims ownership of token contract
   */
  function claimToken() public {
    token.claimOwnership();
  }

  /*
   * Allow purchase
   * @dev while paused
   */
  function unpause()
    onlyOwner
    whenPaused
    whenRateSet
    whenCapped
    whenOwnsToken
    public
  {
    super.unpause();
  }


  /**************************************************************************
   * ADMIN INTERFACE
   *************************************************************************/

  /*
   * Set the base purchase rate for the token
   * @param _purchaseRate - number of tokens granted per wei
   */
  function setRate(uint256 _purchaseRate)
    onlyOwner
    whenPaused
    public
  {
    discounts.baseRate = _purchaseRate;
  }

  /*
   * Specify purchasing limits for a single account: the limit of tokens
   * that a participant may purchase in a set amount of time (blocks)
   * @param _amount - Number of tokens
   * @param _duration - Number of blocks
   */
  function limitPurchasing(uint256 _amount, uint256 _duration)
    onlyOwner
    whenPaused
    public
  {
    cap.amount = _amount;
    cap.duration = _duration;
  }

  /*
   * Add a tier with a given discount and available supply
   * @param _discount - Discount in basis points
   * @param _available - Available supply at tier
   */
  function addTier(uint256 _discount, uint256 _available)
    onlyOwner
    whenPaused
    public
  {
    discounts.addTier(_discount, _available);

    Tier(_discount, _available);
  }

  /*
   * Authorize a group of participants for a tier
   * @param _minimumTier - minimum tier for list of participants
   * @param _participants - array of authorized addresses
   */
  function authorizeForTier(uint256 _minimumTier, address[] _authorized)
    onlyOwner
    public
  {
    for (uint256 i = 0; i < _authorized.length; i++) {
      participants[_authorized[i]] = Participant({
        authorized: true,
        minimumTier: _minimumTier
      });
    }
  }

  /*
   * Withdraw balance from presale
   */
  function withdraw()
    onlyOwner
    public
  {
    owner.transfer(this.balance);
  }


  /**************************************************************************
   * PURCHASE INTERFACE
   *************************************************************************/

  /*
   * Fallback (default) function.
   * @dev Forwards to `purchaseTokens()`
   */
  function ()
    public
    payable
  {
    purchaseTokens();
  }

  /*
   * Public purchase interface for authorized Dragon Holders
   * @dev Purchases tokens starting in authorized minimum tier
   */
  function purchaseTokens()
    onlyAuthorized
    whenNotPaused
    public
    payable
  {
    var limit = cap.getLimit(msg.sender);

    var (purchased, refund) = discounts.purchaseTokens(
      limit,
      msg.value,
      participants[msg.sender].minimumTier
    );

    cap.recordPurchase(msg.sender, purchased);

    // issue new tokens
    token.issue(msg.sender, purchased);

    // if there are funds left, send refund
    if (refund > 0) {
      msg.sender.transfer(refund);
    }
  }


  /**************************************************************************
   * PRICING / AVAILABILITY - VIEW INTERFACE
   *************************************************************************/

  /*
   * Get terms for purchasing limit window
   * @return number of tokens and duration in blocks
   */
  function getPurchaseLimit()
    public
    view
    returns (uint256 _amount, uint256 _duration)
  {
    _amount = cap.amount;
    _duration = cap.duration;
  }

  /*
   * Get tiers currently set up, with discounts and available supplies
   * @return array of tuples (discount, available)
   */
  function getTiers()
    public
    view
    returns (uint256[2][])
  {
    var records = discounts.tiers;
    uint256[2][] memory tiers = new uint256[2][](records.length);

    for (uint256 i = 0; i < records.length; i++) {
      tiers[i][0] = records[i].discount;
      tiers[i][1] = records[i].available;
    }

    return tiers;
  }

  /*
   * Get available supply for each tier for a given participant
   * @dev starts at minimum tier for participant (requiring auth)
   * @return available supply by tier index, zeroes for non-auth
   */
  function getAvailability(address _participant)
    public
    view
    returns (uint256[])
  {
    var participant = participants[_participant];
    uint256 minimumTier = participant.minimumTier;

    // minor HACK - if the participant isn't authorized, just set the
    // minimum tier above the bounds
    if (!participant.authorized) {
      minimumTier = discounts.tiers.length;
    }

    uint256[] memory tiers = new uint256[](discounts.tiers.length);

    for (uint256 i = minimumTier; i < tiers.length; i++) {
      tiers[i] = discounts.tiers[i].available;
    }

    return tiers;
  }


  /**************************************************************************
   * MODIFIERS
   *************************************************************************/

  /*
   * @dev require participant is whitelist-authorized
   */
  modifier onlyAuthorized() {
    require(participants[msg.sender].authorized);
    _;
  }

  /*
   * @dev baseRate will default to 0
   */
  modifier whenRateSet() {
    require(discounts.baseRate != 0);
    _;
  }

  /*
   * @dev to prevent accidentally capping at 0
   */
  modifier whenCapped() {
    require(cap.amount != 0);
    _;
  }

  /*
   * @dev asserts zeppelin Claimable workflow is finalized
   */
  modifier whenOwnsToken() {
    require(token.owner() == address(this));
    _;
  }
}