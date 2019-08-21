pragma solidity 0.4.25;

contract Auth {

  address internal mainAdmin;
  address internal contractAdmin;

  event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);

  constructor(
    address _mainAdmin,
    address _contractAdmin
  )
  internal
  {
    mainAdmin = _mainAdmin;
    contractAdmin = _contractAdmin;
  }

  modifier onlyAdmin() {
    require(isMainAdmin() || isContractAdmin(), "onlyAdmin");
    _;
  }

  modifier onlyMainAdmin() {
    require(isMainAdmin(), "onlyMainAdmin");
    _;
  }

  modifier onlyContractAdmin() {
    require(isContractAdmin(), "onlyContractAdmin");
    _;
  }

  function transferOwnership(address _newOwner) onlyContractAdmin internal {
    require(_newOwner != address(0x0));
    contractAdmin = _newOwner;
    emit OwnershipTransferred(msg.sender, _newOwner);
  }

  function isMainAdmin() public view returns (bool) {
    return msg.sender == mainAdmin;
  }

  function isContractAdmin() public view returns (bool) {
    return msg.sender == contractAdmin;
  }
}

library Math {
  function abs(int number) internal pure returns (uint) {
    if (number < 0) {
      return uint(number * -1);
    }
    return uint(number);
  }
}

library StringUtil {
  struct slice {
    uint _length;
    uint _pointer;
  }

  function validateUserName(string memory _username)
  internal
  pure
  returns (bool)
  {
    uint8 len = uint8(bytes(_username).length);
    if ((len < 4) || (len > 18)) return false;

    // only contain A-Z 0-9
    for (uint8 i = 0; i < len; i++) {
      if (
        (uint8(bytes(_username)[i]) < 48) ||
        (uint8(bytes(_username)[i]) > 57 && uint8(bytes(_username)[i]) < 65) ||
        (uint8(bytes(_username)[i]) > 90)
      ) return false;
    }
    // First char != '0'
    return uint8(bytes(_username)[0]) != 48;
  }
}

interface IWallet {

  function bonusForAdminWhenUserBuyPackageViaDollar(uint _amount, address _admin) external;

  function bonusNewRank(address _investorAddress, uint _currentRank, uint _newRank) external;

  function mineToken(address _from, uint _amount) external;

  function deposit(address _to, uint _deposited, uint8 _source, uint _sourceAmount) external;

  function getInvestorLastDeposited(address _investor) external view returns (uint);

  function getUserWallet(address _investor) external view returns (uint, uint[], uint, uint, uint, uint, uint);

  function getProfitBalance(address _investor) external view returns (uint);

  function increaseETHWithdrew(uint _amount) external;

  function validateCanMineToken(uint _tokenAmount, address _from) external view;
}

interface ICitizen {

  function addF1DepositedToInviter(address _invitee, uint _amount) external;

  function addNetworkDepositedToInviter(address _inviter, uint _amount, uint _source, uint _sourceAmount) external;

  function checkInvestorsInTheSameReferralTree(address _inviter, address _invitee) external view returns (bool);

  function getF1Deposited(address _investor) external view returns (uint);

  function getId(address _investor) external view returns (uint);

  function getInvestorCount() external view returns (uint);

  function getInviter(address _investor) external view returns (address);

  function getDirectlyInvitee(address _investor) external view returns (address[]);

  function getDirectlyInviteeHaveJoinedPackage(address _investor) external view returns (address[]);

  function getNetworkDeposited(address _investor) external view returns (uint);

  function getRank(address _investor) external view returns (uint);

  function getRankBonus(uint _index) external view returns (uint);

  function getUserAddresses(uint _index) external view returns (address);

  function getSubscribers(address _investor) external view returns (uint);

  function increaseInviterF1HaveJoinedPackage(address _invitee) external;

  function isCitizen(address _user) view external returns (bool);

  function register(address _user, string _userName, address _inviter) external returns (uint);

  function showInvestorInfo(address _investorAddress) external view returns (uint, string memory, address, address[], uint, uint, uint, uint);
}

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
 */
contract IERC20 {
    function transfer(address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function balanceOf(address who) public view returns (uint256);

    function allowance(address owner, address spender) public view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ReserveFund is Auth {
  using StringUtil for *;
  using Math for int;

  enum Lock {
    UNLOCKED,
    PROFIT,
    MINING_TOKEN,
    BOTH
  }

  mapping(address => Lock) public lockedAccounts;
  uint private miningDifficulty = 200000; // $200
  uint private transferDifficulty = 1000; // $1
  uint private aiTokenG3; // 1 ETH = aiTokenG3 DAB
  uint public aiTokenG2; // in mili-dollar (1/1000 dollar)
  uint public minJoinPackage = 200000; // $200
  uint public maxJoinPackage = 5000000; // $5k
  uint public currentETHPrice;
  bool public enableJoinPackageViaEther = true;

  ICitizen private citizen;
  IWallet private wallet;
  IERC20 public dabToken;

  event AccountsLocked(address[] addresses, uint8 lockingType);
  event AITokenG2Set(uint rate);
  event AITokenG3Set(uint rate);
  event ETHPriceSet(uint ethPrice);
  event EnableJoinPackageViaEtherSwitched(bool enabled);
  event EtherPriceUpdated(uint currentETHPrice);
  event MinJoinPackageSet(uint minJoinPackage);
  event MaxJoinPackageSet(uint maxJoinPackage);
  event MiningDifficultySet(uint rate);
  event TransferDifficultySet(uint value);
  event PackageJoinedViaEther(address buyer, address receiver, uint amount);
  event PackageJoinedViaToken(address buyer, address receiver, uint amount);
  event PackageJoinedViaDollar(address buyer, address receiver, uint amount);
  event Registered(uint id, string userName, address userAddress, address inviter);
  event TokenMined(address buyer, uint amount, uint walletAmount);
  event TokenSwapped(address seller, uint amount, uint ethAmount);

  constructor (
    address _citizen,
    address _wallet,
    address _mainAdmin,
    uint _currentETHPrice
  )
  Auth(_mainAdmin, msg.sender)
  public
  {
    citizen = ICitizen(_citizen);
    wallet = IWallet(_wallet);
    currentETHPrice = _currentETHPrice;
  }

  // ADMINS FUNCTIONS

  function setDABankingToken(address _dabToken) onlyAdmin public {
    dabToken = IERC20(_dabToken);
  }

  function updateETHPrice(uint _currentETHPrice) onlyAdmin public {
    require(_currentETHPrice > 0, "Must be > 0");
    require(_currentETHPrice != currentETHPrice, "Must be new value");
    currentETHPrice = _currentETHPrice;
    emit ETHPriceSet(currentETHPrice);
  }

  function updateContractAdmin(address _newAddress) onlyAdmin public {
    transferOwnership(_newAddress);
  }

  function setMinJoinPackage(uint _minJoinPackage) onlyAdmin public {
    require(_minJoinPackage > 0, "Must be > 0");
    require(_minJoinPackage < maxJoinPackage, "Must be < maxJoinPackage");
    require(_minJoinPackage != minJoinPackage, "Must be new value");
    minJoinPackage = _minJoinPackage;
    emit MinJoinPackageSet(minJoinPackage);
  }

  function setMaxJoinPackage(uint _maxJoinPackage) onlyAdmin public {
    require(_maxJoinPackage > minJoinPackage, "Must be > minJoinPackage");
    require(_maxJoinPackage != maxJoinPackage, "Must be new value");
    maxJoinPackage = _maxJoinPackage;
    emit MaxJoinPackageSet(maxJoinPackage);
  }

  function setEnableJoinPackageViaEther(bool _enableJoinPackageViaEther) onlyAdmin public {
    require(_enableJoinPackageViaEther != enableJoinPackageViaEther, "Must be new value");
    enableJoinPackageViaEther = _enableJoinPackageViaEther;
    emit EnableJoinPackageViaEtherSwitched(enableJoinPackageViaEther);
  }

  function aiSetTokenG2(uint _rate) onlyAdmin public {
    require(_rate > 0, "aiTokenG2 must be > 0");
    require(_rate != aiTokenG2, "aiTokenG2 must be new value");
    aiTokenG2 = _rate;
    emit AITokenG2Set(aiTokenG2);
  }

  function aiSetTokenG3(uint _rate) onlyAdmin public {
    require(_rate > 0, "aiTokenG3 must be > 0");
    require(_rate != aiTokenG3, "aiTokenG3 must be new value");
    aiTokenG3 = _rate;
    emit AITokenG3Set(aiTokenG3);
  }

  function setMiningDifficulty(uint _miningDifficulty) onlyAdmin public {
    require(_miningDifficulty > 0, "miningDifficulty must be > 0");
    require(_miningDifficulty != miningDifficulty, "miningDifficulty must be new value");
    miningDifficulty = _miningDifficulty;
    emit MiningDifficultySet(miningDifficulty);
  }

  function setTransferDifficulty(uint _transferDifficulty) onlyAdmin public {
    require(_transferDifficulty > 0, "MinimumBuy must be > 0");
    require(_transferDifficulty != transferDifficulty, "transferDifficulty must be new value");
    transferDifficulty = _transferDifficulty;
    emit TransferDifficultySet(transferDifficulty);
  }

  function lockAccounts(address[] _addresses, uint8 _type) onlyAdmin public {
    require(_addresses.length > 0, "Address cannot be empty");
    require(_addresses.length <= 256, "Maximum users per action is 256");
    require(_type >= 0 && _type <= 3, "Type is invalid");
    for (uint8 i = 0; i < _addresses.length; i++) {
      require(_addresses[i] != msg.sender, "You cannot lock yourself");
      lockedAccounts[_addresses[i]] = Lock(_type);
    }
    emit AccountsLocked(_addresses, _type);
  }

  // PUBLIC FUNCTIONS

  function () public payable {}

  function getAITokenG3() view public returns (uint) {
    return aiTokenG3;
  }

  function getMiningDifficulty() view public returns (uint) {
    return miningDifficulty;
  }

  function getTransferDifficulty() view public returns (uint) {
    return transferDifficulty;
  }

  function getLockedStatus(address _investor) view public returns (uint8) {
    return uint8(lockedAccounts[_investor]);
  }

  function register(string memory _userName, address _inviter) public {
    require(citizen.isCitizen(_inviter), "Inviter did not registered.");
    require(_inviter != msg.sender, "Cannot referral yourself");
    uint id = citizen.register(msg.sender, _userName, _inviter);
    emit Registered(id, _userName, msg.sender, _inviter);
  }

  function showMe() public view returns (uint, string memory, address, address[], uint, uint, uint, uint) {
    return citizen.showInvestorInfo(msg.sender);
  }

  function joinPackageViaEther(uint _rate, address _to) payable public {
    require(enableJoinPackageViaEther, "Can not buy via Ether now");
    validateJoinPackage(msg.sender, _to);
    require(_rate > 0, "Rate must be > 0");
    validateAmount(_to, (msg.value * _rate) / (10 ** 18));
    bool rateHigherUnder3Percents = (int(currentETHPrice - _rate).abs() * 100 / _rate) <= uint(3);
    bool rateLowerUnder5Percents = (int(_rate - currentETHPrice).abs() * 100 / currentETHPrice) <= uint(5);
    bool validRate = rateHigherUnder3Percents && rateLowerUnder5Percents;
    require(validRate, "Invalid rate, please check again!");
    doJoinViaEther(msg.sender, _to, msg.value, _rate);
  }

  function joinPackageViaDollar(uint _amount, address _to) public {
    validateJoinPackage(msg.sender, _to);
    validateAmount(_to, _amount);
    validateProfitBalance(msg.sender, _amount);
    wallet.deposit(_to, _amount, 2, _amount);
    wallet.bonusForAdminWhenUserBuyPackageViaDollar(_amount / 10, mainAdmin);
    emit PackageJoinedViaDollar(msg.sender, _to, _amount);
  }

  function joinPackageViaToken(uint _amount, address _to) public {
    validateJoinPackage(msg.sender, _to);
    validateAmount(_to, _amount);
    uint tokenAmount = (_amount / aiTokenG2) * (10 ** 18);
    require(dabToken.allowance(msg.sender, address(this)) >= tokenAmount, "You must call approve() first");
    uint userOldBalance = dabToken.balanceOf(msg.sender);
    require(userOldBalance >= tokenAmount, "You have not enough tokens");
    require(dabToken.transferFrom(msg.sender, address(this), tokenAmount), "Transfer token failed");
    require(dabToken.transfer(mainAdmin, tokenAmount / 10), "Transfer token to admin failed");
    wallet.deposit(_to, _amount, 1, tokenAmount);
    emit PackageJoinedViaToken(msg.sender, _to, _amount);
  }

  function miningToken(uint _tokenAmount) public {
    require(aiTokenG2 > 0, "Invalid aiTokenG2, please contact admin");
    require(citizen.isCitizen(msg.sender), "Please register first");
    validateLockingMiningToken(msg.sender);
    require(_tokenAmount > miningDifficulty, "Amount must be > miningDifficulty");
    uint fiatAmount = (_tokenAmount * aiTokenG2) / (10 ** 18);
    validateProfitBalance(msg.sender, fiatAmount);
    wallet.validateCanMineToken(fiatAmount, msg.sender);

    wallet.mineToken(msg.sender, fiatAmount);
    uint userOldBalance = dabToken.balanceOf(msg.sender);
    require(dabToken.transfer(msg.sender, _tokenAmount), "Transfer token to user failed");
    require(dabToken.balanceOf(msg.sender) == userOldBalance + _tokenAmount, "User token changed invalid");
    emit TokenMined(msg.sender, _tokenAmount, fiatAmount);
  }

  function swapToken(uint _amount) public {
    require(_amount > 0, "Invalid amount to swap");
    require(dabToken.balanceOf(msg.sender) >= _amount, "You have not enough balance");
    uint etherAmount = getEtherAmountFromToken(_amount);
    require(address(this).balance >= etherAmount, "The contract have not enough balance");
    require(dabToken.allowance(msg.sender, address(this)) >= _amount, "You must call approve() first");
    require(dabToken.transferFrom(msg.sender, address(this), _amount), "Transfer token failed");
    msg.sender.transfer(etherAmount);
    wallet.increaseETHWithdrew(etherAmount);
    emit TokenSwapped(msg.sender, _amount, etherAmount);
  }

  function getCurrentEthPrice() public view returns (uint) {
    return currentETHPrice;
  }

  // PRIVATE FUNCTIONS

  function getEtherAmountFromToken(uint _amount) private view returns (uint) {
    require(aiTokenG3 > 0, "Invalid aiTokenG3, please contact admin");
    return _amount / aiTokenG3;
  }

  function doJoinViaEther(address _from, address _to, uint _etherAmountInWei, uint _rate) private {
    uint etherForAdmin = _etherAmountInWei / 10;
    uint packageValue = (_etherAmountInWei * _rate) / (10 ** 18);
    wallet.deposit(_to, packageValue, 0, _etherAmountInWei);
    mainAdmin.transfer(etherForAdmin);
    emit PackageJoinedViaEther(_from, _to, packageValue);
  }

  function validateAmount(address _user, uint _packageValue) private view {
    require(_packageValue > 0, "Amount must be > 0");
    require(_packageValue <= maxJoinPackage, "Can not join with amount that greater max join package");
    uint lastBuy = wallet.getInvestorLastDeposited(_user);
    if (lastBuy == 0) {
      require(_packageValue >= minJoinPackage, "Minimum for first join is $200");
    } else {
      require(_packageValue >= lastBuy, "Can not join with amount that lower than your last join");
    }
  }

  function validateJoinPackage(address _from, address _to) private view {
    require(citizen.isCitizen(_from), "Please register first");
    require(citizen.isCitizen(_to), "You can only buy for an exists member");
    if (_from != _to) {
      require(citizen.checkInvestorsInTheSameReferralTree(_from, _to), "This user isn't in your referral tree");
    }
    require(currentETHPrice > 0, "Invalid currentETHPrice, please contact admin!");
  }

  function validateLockingMiningToken(address _from) private view {
    bool canBuy = lockedAccounts[_from] != Lock.MINING_TOKEN && lockedAccounts[_from] != Lock.BOTH;
    require(canBuy, "Your account get locked from mining token");
  }

  function validateProfitBalance(address _user, uint _amount) private view {
    uint profitBalance = wallet.getProfitBalance(_user);
    require(profitBalance >= _amount, "You have not enough balance");
  }
}