pragma solidity 0.4.25;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 */
library SafeMath {
  /**
   * @dev Multiplies two unsigned integers, reverts on overflow.
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
   * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
   */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // Solidity only automatically asserts when dividing by 0
    require(b > 0);
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
   * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
   */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
   * @dev Adds two unsigned integers, reverts on overflow.
   */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
   * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
   * reverts when dividing by zero.
   */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

library UnitConverter {
  using SafeMath for uint256;

  function stringToBytes24(string memory source)
  internal
  pure
  returns (bytes24 result)
  {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
      return 0x0;
    }

    assembly {
      result := mload(add(source, 24))
    }
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

library ArrayUtil {

  function tooLargestValues(uint[] array) internal pure returns (uint max, uint subMax) {
    require(array.length >= 2, "Invalid array length");
    max = array[0];
    for (uint i = 1; i < array.length; i++) {
      if (array[i] > max) {
        subMax = max;
        max = array[i];
      } else if (array[i] > subMax) {
        subMax = array[i];
      }
    }
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

contract Citizen is Auth {
  using ArrayUtil for uint256[];
  using StringUtil for string;
  using UnitConverter for string;
  using SafeMath for uint;

  enum Rank {
    UnRanked,
    Star1,
    Star2,
    Star3,
    Star4,
    Star5,
    Star6,
    Star7,
    Star8,
    Star9,
    Star10
  }

  enum DepositType {
    Ether,
    Token,
    Dollar
  }

  uint[11] public rankCheckPoints = [
    0,
    1000000,
    3000000,
    10000000,
    40000000,
    100000000,
    300000000,
    1000000000,
    2000000000,
    5000000000,
    10000000000
  ];

  uint[11] public rankBonuses = [
    0,
    0,
    0,
    0,
    1000000, // $1k
    2000000,
    6000000,
    20000000,
    50000000,
    150000000,
    500000000 // $500k
  ];

  struct Investor {
    uint id;
    string userName;
    address inviter;
    address[] directlyInvitee;
    address[] directlyInviteeHaveJoinedPackage;
    uint f1Deposited;
    uint networkDeposited;
    uint networkDepositedViaETH;
    uint networkDepositedViaToken;
    uint networkDepositedViaDollar;
    uint subscribers;
    Rank rank;
  }

  address private reserveFundContract;
  IWallet private walletContract;

  mapping (address => Investor) private investors;
  mapping (bytes24 => address) private userNameAddresses;
  address[] private userAddresses;

  modifier onlyWalletContract() {
    require(msg.sender == address(walletContract), "onlyWalletContract");
    _;
  }

  modifier onlyReserveFundContract() {
    require(msg.sender == address(reserveFundContract), "onlyReserveFundContract");
    _;
  }

  event RankAchieved(address investor, uint currentRank, uint newRank);

  constructor(address _mainAdmin) Auth(_mainAdmin, msg.sender) public {
    setupAdminAccount();
  }

  // ONLY-CONTRACT-ADMIN FUNCTIONS

  function setWalletContract(address _walletContract) onlyContractAdmin public {
    walletContract = IWallet(_walletContract);
  }

  function setDABankContract(address _reserveFundContract) onlyContractAdmin public {
    reserveFundContract = _reserveFundContract;
  }

  // ONLY-DABANK-CONTRACT FUNCTIONS

  function register(address _user, string memory _userName, address _inviter)
  onlyReserveFundContract
  public
  returns
  (uint)
  {
    require(_userName.validateUserName(), "Invalid username");
    Investor storage investor = investors[_user];
    require(!isCitizen(_user), "Already an citizen");
    bytes24 _userNameAsKey = _userName.stringToBytes24();
    require(userNameAddresses[_userNameAsKey] == address(0x0), "Username already exist");
    userNameAddresses[_userNameAsKey] = _user;

    investor.id = userAddresses.length;
    investor.userName = _userName;
    investor.inviter = _inviter;
    investor.rank = Rank.UnRanked;
    increaseInvitersSubscribers(_inviter);
    increaseInviterF1(_inviter, _user);
    userAddresses.push(_user);
    return investor.id;
  }

  function showInvestorInfo(address _investorAddress)
  onlyReserveFundContract
  public
  view
  returns (uint, string memory, address, address[], uint, uint, uint, Citizen.Rank)
  {
    Investor storage investor = investors[_investorAddress];
    return (
      investor.id,
      investor.userName,
      investor.inviter,
      investor.directlyInvitee,
      investor.f1Deposited,
      investor.networkDeposited,
      investor.subscribers,
      investor.rank
    );
  }

  // ONLY-WALLET-CONTRACT FUNCTIONS

  function addF1DepositedToInviter(address _invitee, uint _amount)
  onlyWalletContract
  public
  {
    address inviter = investors[_invitee].inviter;
    investors[inviter].f1Deposited = investors[inviter].f1Deposited.add(_amount);
    assert(investors[inviter].f1Deposited > 0);
  }

  // _source: 0-eth 1-token 2-usdt
  function addNetworkDepositedToInviter(address _inviter, uint _amount, uint _source, uint _sourceAmount)
  onlyWalletContract
  public
  {
    require(_inviter != address(0x0), "Invalid inviter address");
    require(_amount >= 0, "Invalid deposit amount");
    require(_source >= 0 && _source <= 2, "Invalid deposit source");
    require(_sourceAmount >= 0, "Invalid source amount");
    investors[_inviter].networkDeposited = investors[_inviter].networkDeposited.add(_amount);
    if (_source == 0) {
      investors[_inviter].networkDepositedViaETH = investors[_inviter].networkDepositedViaETH.add(_sourceAmount);
    } else if (_source == 1) {
      investors[_inviter].networkDepositedViaToken = investors[_inviter].networkDepositedViaToken.add(_sourceAmount);
    } else {
      investors[_inviter].networkDepositedViaDollar = investors[_inviter].networkDepositedViaDollar.add(_sourceAmount);
    }
  }

  function increaseInviterF1HaveJoinedPackage(address _invitee)
  public
  onlyWalletContract
  {
    address _inviter = getInviter(_invitee);
    investors[_inviter].directlyInviteeHaveJoinedPackage.push(_invitee);
  }

  // PUBLIC FUNCTIONS

  function updateRanking() public {
    Investor storage investor = investors[msg.sender];
    Rank currentRank = investor.rank;
    require(investor.directlyInviteeHaveJoinedPackage.length > 2, "Invalid condition to make ranking");
    require(currentRank < Rank.Star10, "Congratulations! You have reached max rank");
    uint investorRevenueToCheckRank = getInvestorRankingRevenue(msg.sender);
    Rank newRank;
    for(uint8 k = uint8(currentRank) + 1; k <= uint8(Rank.Star10); k++) {
      if(investorRevenueToCheckRank >= rankCheckPoints[k]) {
        newRank = getRankFromIndex(k);
      }
    }
    if (newRank > currentRank) {
      walletContract.bonusNewRank(msg.sender, uint(currentRank), uint(newRank));
      investor.rank = newRank;
      emit RankAchieved(msg.sender, uint(currentRank), uint(newRank));
    }
  }

  function getInvestorRankingRevenue(address _investor) public view returns (uint) {
    Investor storage investor = investors[_investor];
    if (investor.directlyInviteeHaveJoinedPackage.length <= 2) {
      return 0;
    }
    uint[] memory f1NetworkDeposited = new uint[](investor.directlyInviteeHaveJoinedPackage.length);
    uint sumF1NetworkDeposited = 0;
    for (uint j = 0; j < investor.directlyInviteeHaveJoinedPackage.length; j++) {
      f1NetworkDeposited[j] = investors[investor.directlyInviteeHaveJoinedPackage[j]].networkDeposited;
      sumF1NetworkDeposited = sumF1NetworkDeposited.add(f1NetworkDeposited[j]);
    }
    uint max;
    uint subMax;
    (max, subMax) = f1NetworkDeposited.tooLargestValues();
    return sumF1NetworkDeposited.sub(max).sub(subMax);
  }

  function checkInvestorsInTheSameReferralTree(address _inviter, address _invitee)
  public
  view
  returns (bool)
  {
    require(_inviter != _invitee, "They are the same");
    bool inTheSameTreeDownLine = checkInTheSameReferralTree(_inviter, _invitee);
    bool inTheSameTreeUpLine = checkInTheSameReferralTree(_invitee, _inviter);
    return inTheSameTreeDownLine || inTheSameTreeUpLine;
  }

  function getInviter(address _investor) public view returns (address) {
    return investors[_investor].inviter;
  }

  function getDirectlyInvitee(address _investor) public view returns (address[]) {
    return investors[_investor].directlyInvitee;
  }

  function getDirectlyInviteeHaveJoinedPackage(address _investor) public view returns (address[]) {
    return investors[_investor].directlyInviteeHaveJoinedPackage;
  }

  function getDepositInfo(address _investor) public view returns (uint, uint, uint, uint, uint) {
    return (
      investors[_investor].f1Deposited,
      investors[_investor].networkDeposited,
      investors[_investor].networkDepositedViaETH,
      investors[_investor].networkDepositedViaToken,
      investors[_investor].networkDepositedViaDollar
    );
  }

  function getF1Deposited(address _investor) public view returns (uint) {
    return investors[_investor].f1Deposited;
  }

  function getNetworkDeposited(address _investor) public view returns (uint) {
    return investors[_investor].networkDeposited;
  }

  function getId(address _investor) public view returns (uint) {
    return investors[_investor].id;
  }

  function getUserName(address _investor) public view returns (string) {
    return investors[_investor].userName;
  }

  function getRank(address _investor) public view returns (Rank) {
    return investors[_investor].rank;
  }

  function getUserAddresses(uint _index) public view returns (address) {
    require(_index >= 0 && _index < userAddresses.length, "Index must be >= 0 or < getInvestorCount()");
    return userAddresses[_index];
  }

  function getSubscribers(address _investor) public view returns (uint) {
    return investors[_investor].subscribers;
  }

  function isCitizen(address _user) view public returns (bool) {
    Investor storage investor = investors[_user];
    return bytes(investor.userName).length > 0;
  }

  function getInvestorCount() public view returns (uint) {
    return userAddresses.length;
  }

  function getRankBonus(uint _index) public view returns (uint) {
    return rankBonuses[_index];
  }

  // PRIVATE FUNCTIONS

  function setupAdminAccount() private {
    string memory _mainAdminUserName = "ADMIN";
    bytes24 _mainAdminUserNameAsKey = _mainAdminUserName.stringToBytes24();
    userNameAddresses[_mainAdminUserNameAsKey] = mainAdmin;
    Investor storage mainAdminInvestor = investors[mainAdmin];
    mainAdminInvestor.id = userAddresses.length;
    mainAdminInvestor.userName = _mainAdminUserName;
    mainAdminInvestor.inviter = 0x0;
    mainAdminInvestor.rank = Rank.UnRanked;
    userAddresses.push(mainAdmin);
  }

  function increaseInviterF1(address _inviter, address _invitee) private {
    investors[_inviter].directlyInvitee.push(_invitee);
  }

  function checkInTheSameReferralTree(address _from, address _to) private view returns (bool) {
    do {
      Investor storage investor = investors[_from];
      if (investor.inviter == _to) {
        return true;
      }
      _from = investor.inviter;
    } while (investor.inviter != 0x0);
    return false;
  }

  function increaseInvitersSubscribers(address _inviter) private {
    do {
      investors[_inviter].subscribers += 1;
      _inviter = investors[_inviter].inviter;
    } while (_inviter != address(0x0));
  }

  function getRankFromIndex(uint8 _index) private pure returns (Rank rank) {
    require(_index >= 0 && _index <= 10, "Invalid index");
    if (_index == 1) {
      return Rank.Star1;
    } else if (_index == 2) {
      return Rank.Star2;
    } else if (_index == 3) {
      return Rank.Star3;
    } else if (_index == 4) {
      return Rank.Star4;
    } else if (_index == 5) {
      return Rank.Star5;
    } else if (_index == 6) {
      return Rank.Star6;
    } else if (_index == 7) {
      return Rank.Star7;
    } else if (_index == 8) {
      return Rank.Star8;
    } else if (_index == 9) {
      return Rank.Star9;
    } else if (_index == 10) {
      return Rank.Star10;
    } else {
      return Rank.UnRanked;
    }
  }
}