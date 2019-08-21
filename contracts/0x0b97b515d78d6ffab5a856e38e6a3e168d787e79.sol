pragma solidity ^0.4.24;

// File: node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
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

// File: node_modules/openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
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

// File: node_modules/openzeppelin-solidity/contracts/math/Safemath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
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

// File: node_modules/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: lib/CanReclaimToken.sol

/**
 * @title Contracts that should be able to recover tokens
 * @author SylTi
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.
 * This will prevent any accidental loss of tokens.
 */
contract CanReclaimToken is Ownable {

  /**
   * @dev Reclaim all ERC20 compatible tokens
   * @param token ERC20 The address of the token contract
   */
  function reclaimToken(IERC20 token) external onlyOwner {
    if (address(token) == address(0)) {
      owner().transfer(address(this).balance);
      return;
    }
    uint256 balance = token.balanceOf(this);
    token.transfer(owner(), balance);
  }

}

// File: openzeppelin-solidity/contracts/access/Roles.sol

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   * @dev give an account access to this role
   */
  function add(Role storage role, address account) internal {
    require(account != address(0));
    require(!has(role, account));

    role.bearer[account] = true;
  }

  /**
   * @dev remove an account's access to this role
   */
  function remove(Role storage role, address account) internal {
    require(account != address(0));
    require(has(role, account));

    role.bearer[account] = false;
  }

  /**
   * @dev check if an account has this role
   * @return bool
   */
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}

// File: lib/ServiceRole.sol

contract ServiceRole {
  using Roles for Roles.Role;

  event ServiceAdded(address indexed account);
  event ServiceRemoved(address indexed account);

  Roles.Role private services;

  constructor() internal {
    _addService(msg.sender);
  }

  modifier onlyService() {
    require(isService(msg.sender));
    _;
  }

  function isService(address account) public view returns (bool) {
    return services.has(account);
  }

  function renounceService() public {
    _removeService(msg.sender);
  }

  function _addService(address account) internal {
    services.add(account);
    emit ServiceAdded(account);
  }

  function _removeService(address account) internal {
    services.remove(account);
    emit ServiceRemoved(account);
  }
}

// File: contracts/SaleFix.sol

interface HEROES {
  function mint(address to, uint256 genes, uint256 level)  external returns (uint);
}

//Crypto Hero Rocket coin
interface CHR {
  function mint(address _to, uint256 _amount) external returns (bool);
}

contract SaleFix is Ownable, ServiceRole, ReentrancyGuard, CanReclaimToken {
  using SafeMath for uint256;

  event ItemUpdate(uint256 indexed itemId, uint256 genes, uint256 level, uint256 price, uint256 count);
  event Sold(address indexed to, uint256 indexed tokenId, uint256 indexed itemId, uint256 genes, uint256 level, uint256 price);
  event CoinReward(uint256 code, uint256 coins);
  event EthReward(uint256 code, uint256 eth);
  event CoinRewardGet(uint256 code, uint256 coins);
  event EthRewardGet(uint256 code, uint256 eth);
  event Income(address source, uint256 amount);

  HEROES public heroes;
  CHR public coin;

  //MARKET
  struct Item {
    bool exists;
    uint256 index;
    uint256 genes;
    uint256 level;
    uint256 price;
    uint256 count;
  }

  // item id => Item
  mapping(uint256 => Item) items;
  // market index => item id
  mapping(uint256 => uint) public market;
  uint256 public marketSize;

  uint256 public lastItemId;


  //REFERRALS
  struct Affiliate {
    uint256 affCode;
    uint256 coinsToMint;
    uint256 ethToSend;
    uint256 coinsMinted;
    uint256 ethSent;
    bool active;
  }

  struct AffiliateReward {
    uint256 coins;
    //1% - 100, 10% - 1000 50% - 5000
    uint256 percent;
  }

  //personal reward struct
  struct StaffReward {
    //1% - 100, 10% - 1000 50% - 5000
    uint256 coins;
    uint256 percent;
    uint256 index;
    bool exists;
  }

  //personal reward mapping
  //staff affCode => StaffReward
  mapping (uint256 => StaffReward) public staffReward;
  //staff index => staff affCode
  mapping (uint256 => uint) public staffList;
  uint256 public staffCount;

  //refCode => Affiliate
  mapping(uint256 => Affiliate) public affiliates;
  mapping(uint256 => bool) public vipAffiliates;
  AffiliateReward[] public affLevelReward;
  AffiliateReward[] public vipAffLevelReward;

  //total reserved eth amount for affiliates
  uint256 public totalReserved;

  constructor(HEROES _heroes, CHR _coin) public {
    require(address(_heroes) != address(0));
    require(address(_coin) != address(0));
    heroes = _heroes;
    coin = _coin;

    affLevelReward.push(AffiliateReward({coins : 2, percent : 0})); // level 0 - player self, 2CHR
    affLevelReward.push(AffiliateReward({coins : 1, percent : 1000})); // level 1, 1CHR, 10%
    affLevelReward.push(AffiliateReward({coins : 0, percent : 500})); // level 2, 0CHR, 5%
  
    vipAffLevelReward.push(AffiliateReward({coins : 2, percent : 0})); // level 0 - player self, 2CHR
    vipAffLevelReward.push(AffiliateReward({coins : 1, percent : 2000})); // level 1, 1CHR, 20%
    vipAffLevelReward.push(AffiliateReward({coins : 0, percent : 1000})); // level 2, 0CHR, 10%
  }

  /// @notice The fallback function payable
  function() external payable {
    require(msg.value > 0);
    _flushBalance();
  }

  function _flushBalance() private {
    uint256 balance = address(this).balance.sub(totalReserved);
    if (balance > 0) {
      address(heroes).transfer(balance);
      emit Income(address(this), balance);
    }
  }

  function addService(address account) public onlyOwner {
    _addService(account);
  }

  function removeService(address account) public onlyOwner {
    _removeService(account);
  }

//  function setCoin(CHR _coin) external onlyOwner {
//    require(address(_coin) != address(0));
//    coin = _coin;
//  }


  function setAffiliateLevel(uint256 _level, uint256 _rewardCoins, uint256 _rewardPercent) external onlyOwner {
    require(_level < affLevelReward.length);
    AffiliateReward storage rew = affLevelReward[_level];
    rew.coins = _rewardCoins;
    rew.percent = _rewardPercent;
  }


  function incAffiliateLevel(uint256 _rewardCoins, uint256 _rewardPercent) external onlyOwner {
    affLevelReward.push(AffiliateReward({coins : _rewardCoins, percent : _rewardPercent}));
  }

  function decAffiliateLevel() external onlyOwner {
    delete affLevelReward[affLevelReward.length--];
  }

  function affLevelsCount() external view returns (uint) {
    return affLevelReward.length;
  }

  function setVipAffiliateLevel(uint256 _level, uint256 _rewardCoins, uint256 _rewardPercent) external onlyOwner {
    require(_level < vipAffLevelReward.length);
    AffiliateReward storage rew = vipAffLevelReward[_level];
    rew.coins = _rewardCoins;
    rew.percent = _rewardPercent;
  }

  function incVipAffiliateLevel(uint256 _rewardCoins, uint256 _rewardPercent) external onlyOwner {
    vipAffLevelReward.push(AffiliateReward({coins : _rewardCoins, percent : _rewardPercent}));
  }

  function decVipAffiliateLevel() external onlyOwner {
    delete vipAffLevelReward[vipAffLevelReward.length--];
  }

  function vipAffLevelsCount() external view returns (uint) {
    return vipAffLevelReward.length;
  }

  function addVipAffiliates(address[] _affiliates) external onlyOwner {
    require(_affiliates.length > 0);
    for(uint256 i = 0; i < _affiliates.length; i++) {
      vipAffiliates[_getAffCode(uint(_affiliates[i]))] = true;
    }
  }

  function delVipAffiliates(address[] _affiliates) external onlyOwner {
    require(_affiliates.length > 0);
    for(uint256 i = 0; i < _affiliates.length; i++) {
      delete vipAffiliates[_getAffCode(uint(_affiliates[i]))];
    }
  }

  function addStaff(address _staff, uint256 _percent) external onlyOwner {
    require(_staff != address(0) && _percent > 0);
    uint256 affCode = _getAffCode(uint(_staff));
    StaffReward storage sr = staffReward[affCode];
    if (!sr.exists) {
      sr.exists = true;
      sr.index = staffCount;
      staffList[staffCount++] = affCode;
    }
    sr.percent = _percent;
  }

  function delStaff(address _staff) external onlyOwner {
    require(_staff != address(0));
    uint256 affCode = _getAffCode(uint(_staff));
    StaffReward storage sr = staffReward[affCode];
    require(sr.exists);

    staffReward[staffList[--staffCount]].index = staffReward[affCode].index;
    staffList[staffReward[affCode].index] = staffList[staffCount];
    delete staffList[staffCount];
    delete staffReward[affCode];
  }

  //// MARKETPLACE

  function addItem(uint256 genes, uint256 level, uint256 price, uint256 count) external onlyService {
    items[++lastItemId] = Item({
      exists : true,
      index : marketSize,
      genes : genes,
      level : level,
      price : price,
      count : count
      });
    market[marketSize++] = lastItemId;
    emit ItemUpdate(lastItemId, genes, level,  price, count);
  }

  function delItem(uint256 itemId) external onlyService {
    require(items[itemId].exists);
    items[market[--marketSize]].index = items[itemId].index;
    market[items[itemId].index] = market[marketSize];
    delete market[marketSize];
    delete items[itemId];
    emit ItemUpdate(itemId, 0, 0, 0, 0);
  }

  function setPrice(uint256 itemId, uint256 price) external onlyService {
    Item memory i = items[itemId];
    require(i.exists);
    require(i.price != price);
    i.price = price;
    emit ItemUpdate(itemId, i.genes, i.level, i.price, i.count);
  }

  function setCount(uint256 itemId, uint256 count) external onlyService {
    Item storage i = items[itemId];
    require(i.exists);
    require(i.count != count);
    i.count = count;
    emit ItemUpdate(itemId, i.genes, i.level, i.price, i.count);
  }

  function getItem(uint256 itemId) external view returns (uint256 genes, uint256 level, uint256 price, uint256 count) {
    Item memory i = items[itemId];
    require(i.exists);
    return (i.genes, i.level, i.price, i.count);
  }


  //// AFFILIATE

  function myAffiliateCode() public view returns (uint) {
    return _getAffCode(uint(msg.sender));
  }

  function _getAffCode(uint256 _a) internal pure returns (uint) {
    return (_a ^ (_a >> 80)) & 0xFFFFFFFFFFFFFFFFFFFF;
  }

  function buyItem(uint256 itemId, uint256 _affCode) public payable returns (uint256 tokenId) {
    Item memory i = items[itemId];
    require(i.exists);
    require(i.count > 0);
    require(msg.value == i.price);

    //minting character
    i.count--;
    tokenId = heroes.mint(msg.sender, i.genes, i.level);

    emit ItemUpdate(itemId, i.genes, i.level, i.price, i.count);
    emit Sold(msg.sender, tokenId, itemId, i.genes, i.level, i.price);

    // fetch player code
    uint256 _pCode = _getAffCode(uint(msg.sender));
    Affiliate storage p = affiliates[_pCode];

    //check if it was 1st buy
    if (!p.active) {
      p.active = true;
    }

    // manage affiliate residuals

    // if affiliate code was given and player not tried to use their own, lolz
    // and its not the same as previously stored
    if (_affCode != 0 && _affCode != _pCode && _affCode != p.affCode) {
        // update last affiliate
        p.affCode = _affCode;
    }

    //referral reward
    _distributeAffiliateReward(i.price, _pCode, 0);

    //staff reward
    _distributeStaffReward(i.price, _pCode);

    _flushBalance();
  }

  function _distributeAffiliateReward(uint256 _sum, uint256 _affCode, uint256 _level) internal {
    Affiliate storage aff = affiliates[_affCode];
    AffiliateReward storage ar = vipAffiliates[_affCode] ? vipAffLevelReward[_level] : affLevelReward[_level];
    if (ar.coins > 0) {
      aff.coinsToMint = aff.coinsToMint.add(ar.coins);
      emit CoinReward(_affCode, ar.coins);
    }
    if (ar.percent > 0) {
      uint256 pcnt = _getPercent(_sum, ar.percent);
      aff.ethToSend = aff.ethToSend.add(pcnt);
      totalReserved = totalReserved.add(pcnt);
      emit EthReward(_affCode, pcnt);
    }
    if (++_level < affLevelReward.length && aff.affCode != 0) {
      _distributeAffiliateReward(_sum, aff.affCode, _level);
    }
  }

  //be aware of big number of staff - huge gas!
  function _distributeStaffReward(uint256 _sum, uint256 _affCode) internal {
    for (uint256 i = 0; i < staffCount; i++) {
      if (_affCode != staffList[i]) {
        Affiliate storage aff = affiliates[staffList[i]];
        StaffReward memory sr = staffReward[staffList[i]];
        if (sr.coins > 0) {
          aff.coinsToMint = aff.coinsToMint.add(sr.coins);
          emit CoinReward(_affCode, sr.coins);
        }
        if (sr.percent > 0) {
          uint256 pcnt = _getPercent(_sum, sr.percent);
          aff.ethToSend = aff.ethToSend.add(pcnt);
          totalReserved = totalReserved.add(pcnt);
          emit EthReward(_affCode, pcnt);
        }
      }
    }
  }

  //player can take all rewards after 1st buy of item when he became active
  function getReward() external nonReentrant {
    // fetch player code
    uint256 _pCode = _getAffCode(uint(msg.sender));
    Affiliate storage p = affiliates[_pCode];
    require(p.active);

    //minting coins
    if (p.coinsToMint > 0) {
      require(coin.mint(msg.sender, p.coinsToMint));
      p.coinsMinted = p.coinsMinted.add(p.coinsToMint);
      emit CoinRewardGet(_pCode, p.coinsToMint);
      p.coinsToMint = 0;
    }
    //sending eth
    if (p.ethToSend > 0) {
      msg.sender.transfer(p.ethToSend);
      p.ethSent = p.ethSent.add(p.ethToSend);
      totalReserved = totalReserved.sub(p.ethToSend);
      emit EthRewardGet(_pCode, p.ethToSend);
      p.ethToSend = 0;
    }
  }

  //// SERVICE
  //1% - 100, 10% - 1000 50% - 5000
  function _getPercent(uint256 _v, uint256 _p) internal pure returns (uint)    {
    return _v.mul(_p).div(10000);
  }
}