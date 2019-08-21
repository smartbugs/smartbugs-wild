pragma solidity ^0.4.24;
// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : dave@akomba.com
// released under Apache 2.0 licence
// input  D:\Repositories\GitHub\Cronos\src\CRS.Presale.Contract\contracts\Presale.sol
// flattened :  Friday, 28-Dec-18 10:47:36 UTC
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

contract ReentrancyGuard {

  /// @dev counter to allow mutex lock with only one SSTORE operation
  uint256 private _guardCounter;

  constructor() internal {
    // The counter starts at one to prevent changing it from zero to a non-zero
    // value, which is a more expensive operation.
    _guardCounter = 1;
  }

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * Calling a `nonReentrant` function from another `nonReentrant`
   * function is not supported. It is possible to prevent this from happening
   * by making the `nonReentrant` function external, and make it call a
   * `private` function that does the actual work.
   */
  modifier nonReentrant() {
    _guardCounter += 1;
    uint256 localCounter = _guardCounter;
    _;
    require(localCounter == _guardCounter);
  }

}

contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

contract Presale is Ownable, ReentrancyGuard {
  using SafeMath for uint256;

  struct ReferralData {
    uint256 referrals; // number of referrals
    uint256 bonusSum;  // sum of all bonuses - this is just for showing the total amount - for payouts the referralBonuses mapping will be used
    address[] children; // child referrals
  }

  uint256 public currentPrice = 0;

  bool public isActive = false;

  uint256 public currentDiscountSum = 0;                       // current sum of all discounts (have to stay in the contract for payout)
  uint256 public overallDiscountSum = 0;                       // sum of all discounts given since beginning

  bool public referralsEnabled = true;                      // are referrals enabled in general

  mapping(address => uint) private referralBonuses;

  uint256 public referralBonusMaxDepth = 3;                                  // used to ensure the max depth
  mapping(uint256 => uint) public currentReferralCommissionPercentages;      // commission levels
  uint256 public currentReferralBuyerDiscountPercentage = 5;                 // discount percentage if a buyer uses a valid affiliate link

  mapping(address => address) private parentReferrals;    // parent relationship
  mapping(address => ReferralData) private referralData;  // referral data for this address
  mapping(address => uint) private nodesBought;           // number of bought nodes

  mapping(address => bool) private manuallyAddedReferrals; // we need a chance to add referrals manually since this is needed for promotion

  event MasternodeSold(address buyer, uint256 price, string coinsTargetAddress, bool referral);
  event MasternodePriceChanged(uint256 price);
  event ReferralAdded(address buyer, address parent);

  constructor() public {
    currentReferralCommissionPercentages[0] = 10;
    currentReferralCommissionPercentages[1] = 5;
    currentReferralCommissionPercentages[2] = 3;
  }

  function () external payable {
      // nothing to do
  }

  function buyMasternode(string memory coinsTargetAddress) public nonReentrant payable {
    _buyMasternode(coinsTargetAddress, false, owner());
  }

  function buyMasternodeReferral(string memory coinsTargetAddress, address referral) public nonReentrant payable {
    _buyMasternode(coinsTargetAddress, referralsEnabled, referral);
  }

  function _buyMasternode(string memory coinsTargetAddress, bool useReferral, address referral) internal {
    require(isActive, "Buying is currently deactivated.");
    require(currentPrice > 0, "There was no MN price set so far.");

    uint256 nodePrice = currentPrice;

    // nodes can be bought cheaper if the user uses a valid referral address
    if (useReferral && isValidReferralAddress(referral)) {
      nodePrice = getDiscountedNodePrice();
    }

    require(msg.value >= nodePrice, "Sent amount of ETH was too low.");

    // check target address
    uint256 length = bytes(coinsTargetAddress).length;
    require(length >= 30 && length <= 42 , "Coins target address invalid");

    if (useReferral && isValidReferralAddress(referral)) {

      require(msg.sender != referral, "You can't be your own referral.");

      // set parent/child relations (only if there is no connection/parent yet available)
      // --> this also means that a referral structure can't be changed
      address parent = parentReferrals[msg.sender];
      if (referralData[parent].referrals == 0) {
        referralData[referral].referrals = referralData[referral].referrals.add(1);
        referralData[referral].children.push(msg.sender);
        parentReferrals[msg.sender] = referral;
      }

      // iterate over commissionLevels and calculate commissions
      uint256 discountSumForThisPayment = 0;
      address currentReferral = referral;

      for (uint256 level=0; level < referralBonusMaxDepth; level++) {
        // only apply discount if referral address is valid (or as long we can step up the hierarchy)
        if(isValidReferralAddress(currentReferral)) {

          require(msg.sender != currentReferral, "Invalid referral structure (you can't be in your own tree)");

          // do not take node price here since it could be already dicounted
          uint256 referralBonus = currentPrice.div(100).mul(currentReferralCommissionPercentages[level]);

          // set payout bonus
          referralBonuses[currentReferral] = referralBonuses[currentReferral].add(referralBonus);

          // set stats/counters
          referralData[currentReferral].bonusSum = referralData[currentReferral].bonusSum.add(referralBonus);
          discountSumForThisPayment = discountSumForThisPayment.add(referralBonus);

          // step up one hierarchy level
          currentReferral = parentReferrals[currentReferral];
        } else {
          // we can't find any parent - stop hierarchy calculation
          break;
        }
      }

      require(discountSumForThisPayment < nodePrice, "Wrong calculation of bonuses/discounts - would be higher than the price itself");

      currentDiscountSum = currentDiscountSum.add(discountSumForThisPayment);
      overallDiscountSum = overallDiscountSum.add(discountSumForThisPayment);
    }

    // set the node bought counter
    nodesBought[msg.sender] = nodesBought[msg.sender].add(1);

    emit MasternodeSold(msg.sender, currentPrice, coinsTargetAddress, useReferral);
  }

  function setActiveState(bool active) public onlyOwner {
    isActive = active;
  }

  function setPrice(uint256 price) public onlyOwner {
    require(price > 0, "Price has to be greater than zero.");

    currentPrice = price;

    emit MasternodePriceChanged(price);
  }

  function setReferralsEnabledState(bool _referralsEnabled) public onlyOwner {
    referralsEnabled = _referralsEnabled;
  }

  function setReferralCommissionPercentageLevel(uint256 level, uint256 percentage) public onlyOwner {
    require(percentage >= 0 && percentage <= 20, "Percentage has to be between 0 and 20.");
    require(level >= 0 && level < referralBonusMaxDepth, "Invalid depth level");

    currentReferralCommissionPercentages[level] = percentage;
  }

  function setReferralBonusMaxDepth(uint256 depth) public onlyOwner {
    require(depth >= 0 && depth <= 10, "Referral bonus depth too high.");

    referralBonusMaxDepth = depth;
  }

  function setReferralBuyerDiscountPercentage(uint256 percentage) public onlyOwner {
    require(percentage >= 0 && percentage <= 20, "Percentage has to be between 0 and 20.");

    currentReferralBuyerDiscountPercentage = percentage;
  }

  function addReferralAddress(address addr) public onlyOwner {
    manuallyAddedReferrals[addr] = true;
  }

  function removeReferralAddress(address addr) public onlyOwner {
    manuallyAddedReferrals[addr] = false;
  }

  function withdraw(uint256 amount) public onlyOwner {
    owner().transfer(amount);
  }

  function withdrawReferralBonus() public nonReentrant returns (bool) {
    uint256 amount = referralBonuses[msg.sender];

    if (amount > 0) {
        referralBonuses[msg.sender] = 0;
        currentDiscountSum = currentDiscountSum.sub(amount);

        if (!msg.sender.send(amount)) {
            referralBonuses[msg.sender] = amount;
            currentDiscountSum = currentDiscountSum.add(amount);

            return false;
        }
    }

    return true;
  }

  function checkReferralBonusHeight(address addr) public view returns (uint) {
      return referralBonuses[addr];
  }

  function getNrOfReferrals(address addr) public view returns (uint) {
      return referralData[addr].referrals;
  }

  function getReferralBonusSum(address addr) public view returns (uint) {
      return referralData[addr].bonusSum;
  }

  function getReferralChildren(address addr) public view returns (address[] memory) {
      return referralData[addr].children;
  }

  function getReferralChild(address addr, uint256 idx) public view returns (address) {
      return referralData[addr].children[idx];
  }

  function isValidReferralAddress(address addr) public view returns (bool) {
      return nodesBought[addr] > 0 || manuallyAddedReferrals[addr] == true;
  }

  function getNodesBoughtCountForAddress(address addr) public view returns (uint256) {
      return nodesBought[addr];
  }

  function getDiscountedNodePrice() public view returns (uint256) {
      return currentPrice.sub(currentPrice.div(100).mul(currentReferralBuyerDiscountPercentage));
  }
}