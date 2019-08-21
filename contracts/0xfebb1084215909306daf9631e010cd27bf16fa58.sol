pragma solidity ^0.4.24;

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




contract MyEthLab {
    using SafeMath for uint256;

    uint256 constant public PERCENT_PER_DAY = 5;                        // 0.05%
    uint256 constant public ONE_HUNDRED_PERCENTS = 10000;               // 100%
    uint256 constant public MARKETING_FEE = 700;                        // 7%
    uint256 constant public TEAM_FEE = 300;                             // 3%
    uint256 constant public REFERRAL_PERCENTS = 300;                    // 3%
    uint256 constant public MAX_RATE = 330;                             // 3.3%
    uint256 constant public MAX_DAILY_LIMIT = 150 ether;                // 150 ETH
    uint256 constant public MAX_DEPOSIT = 25 ether;                     // 25 ETH
    uint256 constant public MIN_DEPOSIT = 50 finney;                    // 0.05 ETH
    uint256 constant public MAX_USER_DEPOSITS_COUNT = 50;

    struct Deposit {
        uint256 time;
        uint256 amount;
        uint256 rate;
    }

    struct User {
        address referrer;
        uint256 firstTime;
        uint256 lastPayment;
        uint256 totalAmount;
        uint256 lastInvestment;
        uint256 depositAdditionalRate;
        Deposit[] deposits;
    }

    address public marketing = 0x270ff8c154d4d738B78bEd52a6885b493A2EDdA3;
    address public team = 0x69B18e895F2D9438d2128DB8151EB6e9bB02136d;

    uint256 public totalDeposits;
    uint256 public dailyTime;
    uint256 public dailyLimit;
    bool public running = true;
    mapping(address => User) public users;

    event InvestorAdded(address indexed investor);
    event ReferrerAdded(address indexed investor, address indexed referrer);
    event DepositAdded(address indexed investor, uint256 indexed depositsCount, uint256 amount);
    event UserDividendPayed(address indexed investor, uint256 dividend);
    event ReferrerPayed(address indexed investor, address indexed referrer, uint256 amount, uint256 refAmount);
    event FeePayed(address indexed investor, uint256 amount);
    event TotalDepositsChanged(uint256 totalDeposits);
    event BalanceChanged(uint256 balance);
    event DepositDividendPayed(address indexed investor, uint256 indexed index, uint256 deposit, uint256 rate, uint256 dividend);
    
    constructor() public {
        dailyTime = now.add(1 days);
    }
    
    function() public payable {
        require(running, "MyEthLab is not running");
        User storage user = users[msg.sender];

        if (now > dailyTime) {
            dailyTime = now.add(1 days);
            dailyLimit = 0;
        }

        // Dividends
        uint256[] memory dividends = dividendsForUser(msg.sender);
        uint256 dividendsSum = _dividendsSum(dividends);
        if (dividendsSum > 0) {

            // One payment per hour and first payment will be after 24 hours
            if ((now.sub(user.lastPayment)) > 1 hours && (now.sub(user.firstTime)) > 1 days) {
                if (dividendsSum >= address(this).balance) {
                	dividendsSum = address(this).balance;
                	running = false;
            	}
                msg.sender.transfer(dividendsSum);
                user.lastPayment = now;
                emit UserDividendPayed(msg.sender, dividendsSum);
                for (uint i = 0; i < dividends.length; i++) {
                    emit DepositDividendPayed(
                        msg.sender,
                        i,
                        user.deposits[i].amount,
                        user.deposits[i].rate,
                        dividends[i]
                    );
                }
            }
        }

        // Deposit
        if (msg.value > 0) {
            require(msg.value >= MIN_DEPOSIT, "You dont have enough ethers");

            uint256 userTotalDeposit = user.totalAmount.add(msg.value);
            require(userTotalDeposit <= MAX_DEPOSIT, "You have enough invesments");

            if (user.firstTime != 0 && (now.sub(user.lastInvestment)) > 1 days) {
                user.depositAdditionalRate = user.depositAdditionalRate.add(5);
            }

            if (user.firstTime == 0) {
                user.firstTime = now;
                user.lastPayment = now;
                emit InvestorAdded(msg.sender);
            }

            user.lastInvestment = now;
            user.totalAmount = userTotalDeposit;

            uint currentRate = getRate(userTotalDeposit).add(user.depositAdditionalRate).add(balanceAdditionalRate());
            if (currentRate > MAX_RATE) {
                currentRate = MAX_RATE;
            }

            // Create deposit
            user.deposits.push(Deposit({
                time: now,
                amount: msg.value,
                rate: currentRate
            }));

            require(user.deposits.length <= MAX_USER_DEPOSITS_COUNT, "Too many deposits per user");
            emit DepositAdded(msg.sender, user.deposits.length, msg.value);

            // Check daily limit and Add daily amount of etheres
            dailyLimit = dailyLimit.add(msg.value);
            require(dailyLimit < MAX_DAILY_LIMIT, "Please wait one more day too invest");

            // Add to total deposits
            totalDeposits = totalDeposits.add(msg.value);
            emit TotalDepositsChanged(totalDeposits);

            // Add referral if possible
            if (user.referrer == address(0) && msg.data.length == 20) {
                address referrer = _bytesToAddress(msg.data);
                if (referrer != address(0) && referrer != msg.sender && now >= users[referrer].firstTime) {
                    user.referrer = referrer;
                    emit ReferrerAdded(msg.sender, referrer);
                }
            }

            // Referrers fees
            if (users[msg.sender].referrer != address(0)) {
                address referrerAddress = users[msg.sender].referrer;
                uint256 refAmount = msg.value.mul(REFERRAL_PERCENTS).div(ONE_HUNDRED_PERCENTS);
                referrerAddress.send(refAmount); // solium-disable-line security/no-send
                emit ReferrerPayed(msg.sender, referrerAddress, msg.value, refAmount);
            }

            // Marketing and team fees
            uint256 marketingFee = msg.value.mul(MARKETING_FEE).div(ONE_HUNDRED_PERCENTS);
            uint256 teamFee = msg.value.mul(TEAM_FEE).div(ONE_HUNDRED_PERCENTS);
            marketing.send(marketingFee); // solium-disable-line security/no-send
            team.send(teamFee); // solium-disable-line security/no-send
            emit FeePayed(msg.sender, marketingFee.add(teamFee));            
        }

        emit BalanceChanged(address(this).balance);
    }

    function depositsCountForUser(address wallet) public view returns(uint256) {
        return users[wallet].deposits.length;
    }

    function depositForUser(address wallet, uint256 index) public view returns(uint256 time, uint256 amount, uint256 rate) {
        time = users[wallet].deposits[index].time;
        amount = users[wallet].deposits[index].amount;
        rate = users[wallet].deposits[index].rate;
    }

    function dividendsSumForUser(address wallet) public view returns(uint256 dividendsSum) {
        return _dividendsSum(dividendsForUser(wallet));
    }

    function dividendsForUser(address wallet) public view returns(uint256[] dividends) {
        User storage user = users[wallet];
        dividends = new uint256[](user.deposits.length);

        for (uint i = 0; i < user.deposits.length; i++) {
            uint256 duration = now.sub(user.lastPayment);
            dividends[i] = dividendsForAmountAndTime(user.deposits[i].rate, user.deposits[i].amount, duration);
        }
    }

    function dividendsForAmountAndTime(uint256 rate, uint256 amount, uint256 duration) public pure returns(uint256) {
        return amount
            .mul(rate).div(ONE_HUNDRED_PERCENTS)
            .mul(duration).div(1 days);
    }

    function _bytesToAddress(bytes data) private pure returns(address addr) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            addr := mload(add(data, 20)) 
        }
    }

    function _dividendsSum(uint256[] dividends) private pure returns(uint256 dividendsSum) {
        for (uint i = 0; i < dividends.length; i++) {
            dividendsSum = dividendsSum.add(dividends[i]);
        }
    }
    
    function getRate(uint256 userTotalDeposit) private pure returns(uint256) {
        if (userTotalDeposit < 5 ether) {
            return 180;
        } else if (userTotalDeposit < 10 ether) {
            return 200;
        } else {
            return 220;
        }
    }
    
    function balanceAdditionalRate() public view returns(uint256) {
        if (address(this).balance < 600 ether) {
            return 0;
        } else if (address(this).balance < 1200 ether) {
            return 10;
        } else if (address(this).balance < 1800 ether) {
            return 20;
        } else if (address(this).balance < 2400 ether) {
            return 30;
        } else if (address(this).balance < 3000 ether) {
            return 40;
        } else {
            return 50;
        }
    }
}