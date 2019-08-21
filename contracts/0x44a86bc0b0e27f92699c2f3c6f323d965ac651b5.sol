/**
 * Tokensale.sol
 * Mt Pelerin Share (MPS) token sale : public phase.

 * More info about MPS : https://github.com/MtPelerin/MtPelerin-share-MPS

 * The unflattened code is available through this github tag:
 * https://github.com/MtPelerin/MtPelerin-protocol/tree/etherscan-verify-batch-2

 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved

 * @notice All matters regarding the intellectual property of this code 
 * @notice or software are subject to Swiss Law without reference to its 
 * @notice conflicts of law rules.

 * @notice License for each contract is available in the respective file
 * @notice or in the LICENSE.md file.
 * @notice https://github.com/MtPelerin/

 * @notice Code by OpenZeppelin is copyrighted and licensed on their repository:
 * @notice https://github.com/OpenZeppelin/openzeppelin-solidity
 */


pragma solidity ^0.4.24;

// File: contracts/interface/IUserRegistry.sol

/**
 * @title IUserRegistry
 * @dev IUserRegistry interface
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 **/
contract IUserRegistry {

  function registerManyUsers(address[] _addresses, uint256 _validUntilTime)
    public;

  function attachManyAddresses(uint256[] _userIds, address[] _addresses)
    public;

  function detachManyAddresses(address[] _addresses)
    public;

  function userCount() public view returns (uint256);
  function userId(address _address) public view returns (uint256);
  function addressConfirmed(address _address) public view returns (bool);
  function validUntilTime(uint256 _userId) public view returns (uint256);
  function suspended(uint256 _userId) public view returns (bool);
  function extended(uint256 _userId, uint256 _key)
    public view returns (uint256);

  function isAddressValid(address _address) public view returns (bool);
  function isValid(uint256 _userId) public view returns (bool);

  function registerUser(address _address, uint256 _validUntilTime) public;
  function attachAddress(uint256 _userId, address _address) public;
  function confirmSelf() public;
  function detachAddress(address _address) public;
  function detachSelf() public;
  function detachSelfAddress(address _address) public;
  function suspendUser(uint256 _userId) public;
  function unsuspendUser(uint256 _userId) public;
  function suspendManyUsers(uint256[] _userIds) public;
  function unsuspendManyUsers(uint256[] _userIds) public;
  function updateUser(uint256 _userId, uint256 _validUntil, bool _suspended)
    public;

  function updateManyUsers(
    uint256[] _userIds,
    uint256 _validUntil,
    bool _suspended) public;

  function updateUserExtended(uint256 _userId, uint256 _key, uint256 _value)
    public;

  function updateManyUsersExtended(
    uint256[] _userIds,
    uint256 _key,
    uint256 _value) public;
}

// File: contracts/interface/IRatesProvider.sol

/**
 * @title IRatesProvider
 * @dev IRatesProvider interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 */
contract IRatesProvider {
  function rateWEIPerCHFCent() public view returns (uint256);
  function convertWEIToCHFCent(uint256 _amountWEI)
    public view returns (uint256);

  function convertCHFCentToWEI(uint256 _amountCHFCent)
    public view returns (uint256);
}

// File: contracts/zeppelin/token/ERC20/ERC20Basic.sol

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

// File: contracts/zeppelin/token/ERC20/ERC20.sol

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

// File: contracts/interface/ITokensale.sol

/**
 * @title ITokensale
 * @dev ITokensale interface
 *
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 */
contract ITokensale {

  function () external payable;

  uint256 constant MINIMAL_AUTO_WITHDRAW = 0.5 ether;
  uint256 constant MINIMAL_BALANCE = 0.5 ether;
  uint256 constant MINIMAL_INVESTMENT = 50; // tokens
  uint256 constant BASE_PRICE_CHF_CENT = 500;
  uint256 constant KYC_LEVEL_KEY = 1;

  function minimalAutoWithdraw() public view returns (uint256);
  function minimalBalance() public view returns (uint256);
  function basePriceCHFCent() public view returns (uint256);

  /* General sale details */
  function token() public view returns (ERC20);
  function vaultETH() public view returns (address);
  function vaultERC20() public view returns (address);
  function userRegistry() public view returns (IUserRegistry);
  function ratesProvider() public view returns (IRatesProvider);
  function sharePurchaseAgreementHash() public view returns (bytes32);

  /* Sale status */
  function startAt() public view returns (uint256);
  function endAt() public view returns (uint256);
  function raisedETH() public view returns (uint256);
  function raisedCHF() public view returns (uint256);
  function totalRaisedCHF() public view returns (uint256);
  function totalUnspentETH() public view returns (uint256);
  function totalRefundedETH() public view returns (uint256);
  function availableSupply() public view returns (uint256);

  /* Investor specific attributes */
  function investorUnspentETH(uint256 _investorId)
    public view returns (uint256);

  function investorInvestedCHF(uint256 _investorId)
    public view returns (uint256);

  function investorAcceptedSPA(uint256 _investorId)
    public view returns (bool);

  function investorAllocations(uint256 _investorId)
    public view returns (uint256);

  function investorTokens(uint256 _investorId) public view returns (uint256);
  function investorCount() public view returns (uint256);

  function investorLimit(uint256 _investorId) public view returns (uint256);

  /* Share Purchase Agreement */
  function defineSPA(bytes32 _sharePurchaseAgreementHash)
    public returns (bool);

  function acceptSPA(bytes32 _sharePurchaseAgreementHash)
    public payable returns (bool);

  /* Investment */
  function investETH() public payable;
  function addOffChainInvestment(address _investor, uint256 _amountCHF)
    public;

  /* Schedule */
  function updateSchedule(uint256 _startAt, uint256 _endAt) public;

  /* Allocations admin */
  function allocateTokens(address _investor, uint256 _amount)
    public returns (bool);

  function allocateManyTokens(address[] _investors, uint256[] _amounts)
    public returns (bool);

  /* ETH administration */
  function fundETH() public payable;
  function refundManyUnspentETH(address[] _receivers) public;
  function refundUnspentETH(address _receiver) public;
  function withdrawETHFunds() public;

  event SalePurchaseAgreementHash(bytes32 sharePurchaseAgreement);
  event Allocation(
    uint256 investorId,
    uint256 tokens
  );
  event Investment(
    uint256 investorId,
    uint256 spentCHF
  );
  event ChangeETHCHF(
    address investor,
    uint256 amount,
    uint256 converted,
    uint256 rate
  );
  event FundETH(uint256 amount);
  event WithdrawETH(address receiver, uint256 amount);
}

// File: contracts/zeppelin/math/SafeMath.sol

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

// File: contracts/zeppelin/ownership/Ownable.sol

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

// File: contracts/zeppelin/lifecycle/Pausable.sol

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

// File: contracts/Authority.sol

/**
 * @title Authority
 * @dev The Authority contract has an authority address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 * Authority means to represent a legal entity that is entitled to specific rights
 *
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 *
 * Error messages
 * AU01: Message sender must be an authority
 */
contract Authority is Ownable {

  address authority;

  /**
   * @dev Throws if called by any account other than the authority.
   */
  modifier onlyAuthority {
    require(msg.sender == authority, "AU01");
    _;
  }

  /**
   * @dev Returns the address associated to the authority
   */
  function authorityAddress() public view returns (address) {
    return authority;
  }

  /** Define an address as authority, with an arbitrary name included in the event
   * @dev returns the authority of the
   * @param _name the authority name
   * @param _address the authority address.
   */
  function defineAuthority(string _name, address _address) public onlyOwner {
    emit AuthorityDefined(_name, _address);
    authority = _address;
  }

  event AuthorityDefined(
    string name,
    address _address
  );
}

// File: contracts/tokensale/Tokensale.sol

/**
 * @title Tokensale
 * @dev Tokensale contract
 *
 * @author Cyril Lapinte - <cyril.lapinte@mtpelerin.com>
 *
 * @notice Copyright © 2016 - 2018 Mt Pelerin Group SA - All Rights Reserved
 * @notice Please refer to the top of this file for the license.
 *
 * Error messages
 * TOS01: It must be before the sale is opened
 * TOS02: Sale must be open
 * TOS03: It must be before the sale is closed
 * TOS04: It must be after the sale is closed
 * TOS05: No data must be sent while sending ETH
 * TOS06: Share Purchase Agreement Hashes must match
 * TOS07: User/Investor must exist
 * TOS08: SPA must be accepted before any ETH investment
 * TOS09: Cannot update schedule once started
 * TOS10: Investor must exist
 * TOS11: Cannot allocate more tokens than available supply
 * TOS12: Length of InvestorIds and amounts arguments must match
 * TOS13: Investor must exist
 * TOS14: Must refund ETH unspent
 * TOS15: Must withdraw ETH to vaultETH
 * TOS16: Cannot invest onchain and offchain at the same time
 * TOS17: A ETHCHF rate must exist to invest
 * TOS18: User must be valid
 * TOS19: Cannot invest if no tokens are available
 * TOS20: Investment is below the minimal investment
 * TOS21: Cannot unspend more CHF than BASE_TOKEN_PRICE_CHF
 * TOS22: Token transfer must be successful
 */
contract Tokensale is ITokensale, Authority, Pausable {
  using SafeMath for uint256;

  uint32[5] contributionLimits = [
    5000,
    500000,
    1500000,
    10000000,
    25000000
  ];

  /* General sale details */
  ERC20 public token;
  address public vaultETH;
  address public vaultERC20;
  IUserRegistry public userRegistry;
  IRatesProvider public ratesProvider;

  uint256 public minimalBalance = MINIMAL_BALANCE;
  bytes32 public sharePurchaseAgreementHash;

  uint256 public startAt = 4102441200;
  uint256 public endAt = 4102441200;
  uint256 public raisedETH;
  uint256 public raisedCHF;
  uint256 public totalRaisedCHF;
  uint256 public totalUnspentETH;
  uint256 public totalRefundedETH;
  uint256 public allocatedTokens;

  struct Investor {
    uint256 unspentETH;
    uint256 investedCHF;
    bool acceptedSPA;
    uint256 allocations;
    uint256 tokens;
  }
  mapping(uint256 => Investor) investors;
  mapping(uint256 => uint256) investorLimits;
  uint256 public investorCount;

  /**
   * @dev Throws unless before sale opening
   */
  modifier beforeSaleIsOpened {
    require(currentTime() < startAt, "TOS01");
    _;
  }

  /**
   * @dev Throws if sale is not open
   */
  modifier saleIsOpened {
    require(currentTime() >= startAt && currentTime() <= endAt, "TOS02");
    _;
  }

  /**
   * @dev Throws once the sale is closed
   */
  modifier beforeSaleIsClosed {
    require(currentTime() <= endAt, "TOS03");
    _;
  }

  /**
   * @dev constructor
   */
  constructor(
    ERC20 _token,
    IUserRegistry _userRegistry,
    IRatesProvider _ratesProvider,
    address _vaultERC20,
    address _vaultETH
  ) public
  {
    token = _token;
    userRegistry = _userRegistry;
    ratesProvider = _ratesProvider;
    vaultERC20 = _vaultERC20;
    vaultETH = _vaultETH;
  }

  /**
   * @dev fallback function
   */
  function () external payable {
    require(msg.data.length == 0, "TOS05");
    investETH();
  }

  /**
   * @dev returns the token sold
   */
  function token() public view returns (ERC20) {
    return token;
  }

  /**
   * @dev returns the vault use to
   */
  function vaultETH() public view returns (address) {
    return vaultETH;
  }

  /**
   * @dev returns the vault to receive ETH
   */
  function vaultERC20() public view returns (address) {
    return vaultERC20;
  }

  function userRegistry() public view returns (IUserRegistry) {
    return userRegistry;
  }

  function ratesProvider() public view returns (IRatesProvider) {
    return ratesProvider;
  }

  function sharePurchaseAgreementHash() public view returns (bytes32) {
    return sharePurchaseAgreementHash;
  }

  /* Sale status */
  function startAt() public view returns (uint256) {
    return startAt;
  }

  function endAt() public view returns (uint256) {
    return endAt;
  }

  function raisedETH() public view returns (uint256) {
    return raisedETH;
  }

  function raisedCHF() public view returns (uint256) {
    return raisedCHF;
  }

  function totalRaisedCHF() public view returns (uint256) {
    return totalRaisedCHF;
  }

  function totalUnspentETH() public view returns (uint256) {
    return totalUnspentETH;
  }

  function totalRefundedETH() public view returns (uint256) {
    return totalRefundedETH;
  }

  function availableSupply() public view returns (uint256) {
    uint256 vaultSupply = token.balanceOf(vaultERC20);
    uint256 allowance = token.allowance(vaultERC20, address(this));
    return (vaultSupply < allowance) ? vaultSupply : allowance;
  }
 
  /* Investor specific attributes */
  function investorUnspentETH(uint256 _investorId)
    public view returns (uint256)
  {
    return investors[_investorId].unspentETH;
  }

  function investorInvestedCHF(uint256 _investorId)
    public view returns (uint256)
  {
    return investors[_investorId].investedCHF;
  }

  function investorAcceptedSPA(uint256 _investorId)
    public view returns (bool)
  {
    return investors[_investorId].acceptedSPA;
  }

  function investorAllocations(uint256 _investorId)
    public view returns (uint256)
  {
    return investors[_investorId].allocations;
  }

  function investorTokens(uint256 _investorId) public view returns (uint256) {
    return investors[_investorId].tokens;
  }

  function investorCount() public view returns (uint256) {
    return investorCount;
  }

  function investorLimit(uint256 _investorId) public view returns (uint256) {
    return investorLimits[_investorId];
  }

  /**
   * @dev get minimak auto withdraw threshold
   */
  function minimalAutoWithdraw() public view returns (uint256) {
    return MINIMAL_AUTO_WITHDRAW;
  }

  /**
   * @dev get minimal balance to maintain in contract
   */
  function minimalBalance() public view returns (uint256) {
    return minimalBalance;
  }

  /**
   * @dev get base price in CHF cents
   */
  function basePriceCHFCent() public view returns (uint256) {
    return BASE_PRICE_CHF_CENT;
  }

  /**
   * @dev contribution limit based on kyc level
   */
  function contributionLimit(uint256 _investorId)
    public view returns (uint256)
  {
    uint256 kycLevel = userRegistry.extended(_investorId, KYC_LEVEL_KEY);
    uint256 limit = 0;
    if (kycLevel < 5) {
      limit = contributionLimits[kycLevel];
    } else {
      limit = (investorLimits[_investorId] > 0
        ) ? investorLimits[_investorId] : contributionLimits[4];
    }
    return limit.sub(investors[_investorId].investedCHF);
  }

  /**
   * @dev update minimal balance to be kept in contract
   */
  function updateMinimalBalance(uint256 _minimalBalance)
    public returns (uint256)
  {
    minimalBalance = _minimalBalance;
  }

  /**
   * @dev define investor limit
   */
  function updateInvestorLimits(uint256[] _investorIds, uint256 _limit)
    public returns (uint256)
  {
    for (uint256 i = 0; i < _investorIds.length; i++) {
      investorLimits[_investorIds[i]] = _limit;
    }
  }

  /* Share Purchase Agreement */
  /**
   * @dev define SPA
   */
  function defineSPA(bytes32 _sharePurchaseAgreementHash)
    public onlyOwner returns (bool)
  {
    sharePurchaseAgreementHash = _sharePurchaseAgreementHash;
    emit SalePurchaseAgreementHash(_sharePurchaseAgreementHash);
  }

  /**
   * @dev Accept SPA and invest if msg.value > 0
   */
  function acceptSPA(bytes32 _sharePurchaseAgreementHash)
    public beforeSaleIsClosed payable returns (bool)
  {
    require(
      _sharePurchaseAgreementHash == sharePurchaseAgreementHash, "TOS06");
    uint256 investorId = userRegistry.userId(msg.sender);
    require(investorId > 0, "TOS07");
    investors[investorId].acceptedSPA = true;
    investorCount++;

    if (msg.value > 0) {
      investETH();
    }
  }

  /* Investment */
  function investETH() public
    saleIsOpened whenNotPaused payable
  {
    //Accepting SharePurchaseAgreement is temporarily offchain
    //uint256 investorId = userRegistry.userId(msg.sender);
    //require(investors[investorId].acceptedSPA, "TOS08");
    investInternal(msg.sender, msg.value, 0);
    withdrawETHFundsInternal();
  }

  /**
   * @dev add off chain investment
   */
  function addOffChainInvestment(address _investor, uint256 _amountCHF)
    public onlyAuthority
  {
    investInternal(_investor, 0, _amountCHF);
  }

  /* Schedule */ 
  /**
   * @dev update schedule
   */
  function updateSchedule(uint256 _startAt, uint256 _endAt)
    public onlyAuthority beforeSaleIsOpened
  {
    require(_startAt < _endAt, "TOS09");
    startAt = _startAt;
    endAt = _endAt;
  }

  /* Allocations admin */
  /**
   * @dev allocate
   */
  function allocateTokens(address _investor, uint256 _amount)
    public onlyAuthority beforeSaleIsClosed returns (bool)
  {
    uint256 investorId = userRegistry.userId(_investor);
    require(investorId > 0, "TOS10");
    Investor storage investor = investors[investorId];
    
    allocatedTokens = allocatedTokens.sub(investor.allocations).add(_amount);
    require(allocatedTokens <= availableSupply(), "TOS11");

    investor.allocations = _amount;
    emit Allocation(investorId, _amount);
  }

  /**
   * @dev allocate many
   */
  function allocateManyTokens(address[] _investors, uint256[] _amounts)
    public onlyAuthority beforeSaleIsClosed returns (bool)
  {
    require(_investors.length == _amounts.length, "TOS12");
    for (uint256 i = 0; i < _investors.length; i++) {
      allocateTokens(_investors[i], _amounts[i]);
    }
  }

  /* ETH administration */
  /**
   * @dev fund ETH
   */
  function fundETH() public payable onlyAuthority {
    emit FundETH(msg.value);
  }

  /**
   * @dev refund unspent ETH many
   */
  function refundManyUnspentETH(address[] _receivers) public onlyAuthority {
    for (uint256 i = 0; i < _receivers.length; i++) {
      refundUnspentETH(_receivers[i]);
    }
  }

  /**
   * @dev refund unspent ETH
   */
  function refundUnspentETH(address _receiver) public onlyAuthority {
    uint256 investorId = userRegistry.userId(_receiver);
    require(investorId != 0, "TOS13");
    Investor storage investor = investors[investorId];

    if (investor.unspentETH > 0) {
      // solium-disable-next-line security/no-send
      require(_receiver.send(investor.unspentETH), "TOS14");
      totalRefundedETH = totalRefundedETH.add(investor.unspentETH);
      emit WithdrawETH(_receiver, investor.unspentETH);
      totalUnspentETH = totalUnspentETH.sub(investor.unspentETH);
      investor.unspentETH = 0;
    }
  }

  /**
   * @dev withdraw ETH funds
   */
  function withdrawETHFunds() public onlyAuthority {
    withdrawETHFundsInternal();
  }

  /**
   * @dev withdraw all ETH funds
   */
  function withdrawAllETHFunds() public onlyAuthority {
    uint256 balance = address(this).balance;
    // solium-disable-next-line security/no-send
    require(vaultETH.send(balance), "TOS15");
    emit WithdrawETH(vaultETH, balance);
  }

  /**
   * @dev allowed token investment
   */
  function allowedTokenInvestment(
    uint256 _investorId, uint256 _contributionCHF)
    public view returns (uint256)
  {
    uint256 tokens = 0;
    uint256 allowedContributionCHF = contributionLimit(_investorId);
    if (_contributionCHF < allowedContributionCHF) {
      allowedContributionCHF = _contributionCHF;
    }
    tokens = allowedContributionCHF.div(BASE_PRICE_CHF_CENT);
    uint256 availableTokens = availableSupply().sub(
      allocatedTokens).add(investors[_investorId].allocations);
    if (tokens > availableTokens) {
      tokens = availableTokens;
    }
    if (tokens < MINIMAL_INVESTMENT) {
      tokens = 0;
    }
    return tokens;
  }

  /**
   * @dev withdraw ETH funds internal
   */
  function withdrawETHFundsInternal() internal {
    uint256 balance = address(this).balance;

    if (balance > totalUnspentETH && balance > minimalBalance) {
      uint256 amount = balance.sub(minimalBalance);
      // solium-disable-next-line security/no-send
      require(vaultETH.send(amount), "TOS15");
      emit WithdrawETH(vaultETH, amount);
    }
  }

  /**
   * @dev invest internal
   */
  function investInternal(
    address _investor, uint256 _amountETH, uint256 _amountCHF)
    private
  {
    // investment with _amountETH is decentralized
    // investment with _amountCHF is centralized
    // They are mutually exclusive
    bool isInvesting = (
        _amountETH != 0 && _amountCHF == 0
      ) || (
      _amountETH == 0 && _amountCHF != 0
      );
    require(isInvesting, "TOS16");
    require(ratesProvider.rateWEIPerCHFCent() != 0, "TOS17");
    uint256 investorId = userRegistry.userId(_investor);
    require(userRegistry.isValid(investorId), "TOS18");

    Investor storage investor = investors[investorId];

    uint256 contributionCHF = ratesProvider.convertWEIToCHFCent(
      investor.unspentETH);

    if (_amountETH > 0) {
      contributionCHF = contributionCHF.add(
        ratesProvider.convertWEIToCHFCent(_amountETH));
    }
    if (_amountCHF > 0) {
      contributionCHF = contributionCHF.add(_amountCHF);
    }

    uint256 tokens = allowedTokenInvestment(investorId, contributionCHF);
    require(tokens != 0, "TOS19");

    /** Calculating unspentETH value **/
    uint256 investedCHF = tokens.mul(BASE_PRICE_CHF_CENT);
    uint256 unspentContributionCHF = contributionCHF.sub(investedCHF);

    uint256 unspentETH = 0;
    if (unspentContributionCHF != 0) {
      if (_amountCHF > 0) {
        // Prevent CHF investment LARGER than available supply
        // from creating a too large and dangerous unspentETH value
        require(unspentContributionCHF < BASE_PRICE_CHF_CENT, "TOS21");
      }
      unspentETH = ratesProvider.convertCHFCentToWEI(
        unspentContributionCHF);
    }

    /** Spent ETH **/
    uint256 spentETH = 0;
    if (investor.unspentETH == unspentETH) {
      spentETH = _amountETH;
    } else {
      uint256 unspentETHDiff = (unspentETH > investor.unspentETH)
        ? unspentETH.sub(investor.unspentETH)
        : investor.unspentETH.sub(unspentETH);

      if (_amountCHF > 0) {
        if (unspentETH < investor.unspentETH) {
          spentETH = unspentETHDiff;
        }
        // if unspentETH > investor.unspentETH
        // then CHF has been converted into ETH
        // and no ETH were spent
      }
      if (_amountETH > 0) {
        spentETH = (unspentETH > investor.unspentETH)
          ? _amountETH.sub(unspentETHDiff)
          : _amountETH.add(unspentETHDiff);
      }
    }

    totalUnspentETH = totalUnspentETH.sub(
      investor.unspentETH).add(unspentETH);
    investor.unspentETH = unspentETH;
    investor.investedCHF = investor.investedCHF.add(investedCHF);
    investor.tokens = investor.tokens.add(tokens);
    raisedCHF = raisedCHF.add(_amountCHF);
    raisedETH = raisedETH.add(spentETH);
    totalRaisedCHF = totalRaisedCHF.add(investedCHF);

    allocatedTokens = allocatedTokens.sub(investor.allocations);
    investor.allocations = (investor.allocations > tokens)
      ? investor.allocations.sub(tokens) : 0;
    allocatedTokens = allocatedTokens.add(investor.allocations);
    require(
      token.transferFrom(vaultERC20, _investor, tokens),
      "TOS22");

    if (spentETH > 0) {
      emit ChangeETHCHF(
        _investor,
        spentETH,
        ratesProvider.convertWEIToCHFCent(spentETH),
        ratesProvider.rateWEIPerCHFCent());
    }
    emit Investment(investorId, investedCHF);
  }

  /* Util */
  /**
   * @dev current time
   */
  function currentTime() private view returns (uint256) {
    // solium-disable-next-line security/no-block-members
    return now;
  }
}