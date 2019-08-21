pragma solidity ^0.4.24;

/*
 * OASIS is an international community of financially independent people,
 * united by the principles of trust and mutual assistance.
 * 
 * This community was implemented based on the Ethereum smart contract.
 * The technology is completely transparent and has no analogues in the world.
 * Ethereum blockchain stores all the information concerning the distribution 
 * of community finances.
 * 
 * Smart contract stores the funds of community members, managing payments
 * according to the algorithm. This function allows the community to develop
 * on the principles of trust and mutual assistance.
 * 
 * The community has activated smart contract’s “REFUSE FROM OWNERSHIP” function,
 * thus, no one can change this smart contract, including the community creators.
 * 
 * The community distributes funds in accordance with the following scheme:
 *   80% for community members;
 *   15% for advertising budget;
 *   4% for technical support;
 *   1% to contribute to SENS Research Foundation.
 * 
 * The profit is 3% for 24 hours (interest is accrued continuously).
 * The deposit is included in the payments, 50 days after the deposit is over and eliminated.
 * Minimum deposit is 0.01 ETH.
 * Each deposit is a new deposit contributed to the community.
 * No more than 50 deposits from one ETH wallet are allowed.
 * 
 * Referral system:
 *   Line 1 - 3%
 *   Line 2 - 2%
 *   Line 3 - 1%
 * If you indicate your referral, you get 50% refback from Line 1.
 * 
 * How to make a deposit:
 *   Send cryptocurrency from ETH wallet (at least 0.01 ETH) to the address
 *   of the smart contract - 0x4390a19282c661c9eb8ffb47faca7ad4b47d21fc
 * 
 * Recommended limits are 200000 ETH, check the current ETH rate at
 * the following link: https://ethgasstation.info/
 * 
 * How to get paid:
 *   Request your profit by sending 0 ETH to the address of the smart contract.
 * 
 * It is not allowed to make transfers from cryptocurrency exchanges.
 * Only personal ETH wallet with private keys is allowed.
 * 
 * The source code of this smart contract was created by CryptoManiacs.
 */

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

// File: contracts/Oasis.sol

contract Oasis {
    using SafeMath for uint256;

    uint256 constant public ONE_HUNDRED_PERCENTS = 10000;               // 100%
    uint256 constant public DAILY_INTEREST = 300;                       // 3%
    uint256 constant public MARKETING_FEE = 1500;                       // 15%
    uint256 constant public TEAM_FEE = 400;                             // 4%
    uint256 constant public CHARITY_FEE = 100;                          // 1%
    uint256 constant public MAX_DEPOSIT_TIME = 50 days;                 // 150%
    uint256 constant public REFERRER_ACTIVATION_PERIOD = 0;
    uint256 constant public MAX_USER_DEPOSITS_COUNT = 50;
    uint256 constant public REFBACK_PERCENT = 150;                      // 1.5%
    uint256[] /*constant*/ public referralPercents = [150, 200, 100];   // 1.5%, 2%, 1%

    struct Deposit {
        uint256 time;
        uint256 amount;
    }

    struct User {
        address referrer;
        uint256 refStartTime;
        uint256 lastPayment;
        Deposit[] deposits;
    }

    address public marketing = 0xDB6827de6b9Fc722Dc4EFa7e35f3b78c54932494;
    address public team = 0x31CdA77ab136c8b971511473c3D04BBF7EAe8C0f;
    address public charity = 0x36c92a9Da5256EaA5Ccc355415271b7d2682f32E;
    uint256 public totalDeposits;
    bool public running = true;
    mapping(address => User) public users;

    event InvestorAdded(address indexed investor);
    event ReferrerAdded(address indexed investor, address indexed referrer);
    event DepositAdded(address indexed investor, uint256 indexed depositsCount, uint256 amount);
    event UserDividendPayed(address indexed investor, uint256 dividend);
    event DepositDividendPayed(address indexed investor, uint256 indexed index, uint256 deposit, uint256 totalPayed, uint256 dividend);
    event ReferrerPayed(address indexed investor, address indexed referrer, uint256 amount, uint256 refAmount, uint256 indexed level);
    event FeePayed(address indexed investor, uint256 amount);
    event TotalDepositsChanged(uint256 totalDeposits);
    event BalanceChanged(uint256 balance);

    Oasis public prevContract = Oasis(0x0A5155AD298CcfD1610A00eD75457eb2d8B0C701);
    mapping(address => bool) public wasImported;

    function migrateDeposits() public {
        require(totalDeposits == 0, "Should be called on start");
        totalDeposits = prevContract.totalDeposits();
    }

    function migrate(address[] investors) public {
        for (uint i = 0; i < investors.length; i++) {
            if (wasImported[investors[i]]) {
                continue;
            }

            wasImported[investors[i]] = true;
            User storage user = users[investors[i]];
            (user.referrer, user.refStartTime, user.lastPayment) = prevContract.users(investors[i]);
            
            uint depositsCount = prevContract.depositsCountForUser(investors[i]);
            for (uint j = 0; j < depositsCount; j++) {
                (uint256 time, uint256 amount) = prevContract.depositForUser(investors[i], j);
                user.deposits.push(Deposit({
                    time: time,
                    amount: amount
                }));
            }

            if (user.lastPayment == 0 && depositsCount > 0) {
                user.lastPayment = user.deposits[0].time;
            }
        }
    }
    
    function() public payable {
        require(running, "Oasis is not running");
        User storage user = users[msg.sender];

        // Dividends
        uint256[] memory dividends = dividendsForUser(msg.sender);
        uint256 dividendsSum = _dividendsSum(dividends);
        if (dividendsSum > 0) {
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
                    dividendsForAmountAndTime(user.deposits[i].amount, now.sub(user.deposits[i].time)),
                    dividends[i]
                );
            }

            // Cleanup deposits array a bit
            for (i = 0; i < user.deposits.length; i++) {
                if (now >= user.deposits[i].time.add(MAX_DEPOSIT_TIME)) {
                    user.deposits[i] = user.deposits[user.deposits.length - 1];
                    user.deposits.length -= 1;
                    i -= 1;
                }
            }
        }

        // Deposit
        if (msg.value > 0) {
            if (user.lastPayment == 0) {
                user.lastPayment = now;
                user.refStartTime = now;
                emit InvestorAdded(msg.sender);
            }

            // Create deposit
            user.deposits.push(Deposit({
                time: now,
                amount: msg.value
            }));
            require(user.deposits.length <= MAX_USER_DEPOSITS_COUNT, "Too many deposits per user");
            emit DepositAdded(msg.sender, user.deposits.length, msg.value);

            // Add to total deposits
            totalDeposits = totalDeposits.add(msg.value);
            emit TotalDepositsChanged(totalDeposits);

            // Add referral if possible
            if (user.referrer == address(0) && msg.data.length == 20) {
                address referrer = _bytesToAddress(msg.data);
                if (referrer != address(0) && referrer != msg.sender && users[referrer].refStartTime > 0 && now >= users[referrer].refStartTime.add(REFERRER_ACTIVATION_PERIOD))
                {
                    user.referrer = referrer;
                    msg.sender.transfer(msg.value.mul(REFBACK_PERCENT).div(ONE_HUNDRED_PERCENTS));
                    emit ReferrerAdded(msg.sender, referrer);
                }
            }

            // Referrers fees
            referrer = users[msg.sender].referrer;
            for (i = 0; referrer != address(0) && i < referralPercents.length; i++) {
                uint256 refAmount = msg.value.mul(referralPercents[i]).div(ONE_HUNDRED_PERCENTS);
                referrer.send(refAmount); // solium-disable-line security/no-send
                emit ReferrerPayed(msg.sender, referrer, msg.value, refAmount, i);
                referrer = users[referrer].referrer;
            }

            // Marketing and team fees
            uint256 marketingFee = msg.value.mul(MARKETING_FEE).div(ONE_HUNDRED_PERCENTS);
            uint256 teamFee = msg.value.mul(TEAM_FEE).div(ONE_HUNDRED_PERCENTS);
            uint256 charityFee = msg.value.mul(CHARITY_FEE).div(ONE_HUNDRED_PERCENTS);
            marketing.send(marketingFee); // solium-disable-line security/no-send
            team.send(teamFee); // solium-disable-line security/no-send
            charity.send(charityFee); // solium-disable-line security/no-send
            emit FeePayed(msg.sender, marketingFee.add(teamFee));
        }

        // Create referrer for free
        if (user.deposits.length == 0 && msg.value == 0) {
            user.refStartTime = now;
        }
        emit BalanceChanged(address(this).balance);
    }

    function depositsCountForUser(address wallet) public view returns(uint256) {
        return users[wallet].deposits.length;
    }

    function depositForUser(address wallet, uint256 index) public view returns(uint256 time, uint256 amount) {
        time = users[wallet].deposits[index].time;
        amount = users[wallet].deposits[index].amount;
    }

    function dividendsSumForUser(address wallet) public view returns(uint256 dividendsSum) {
        return _dividendsSum(dividendsForUser(wallet));
    }

    function dividendsForUser(address wallet) public view returns(uint256[] dividends) {
        User storage user = users[wallet];
        dividends = new uint256[](user.deposits.length);

        for (uint i = 0; i < user.deposits.length; i++) {
            uint256 howOld = now.sub(user.deposits[i].time);
            uint256 duration = now.sub(user.lastPayment);
            if (howOld > MAX_DEPOSIT_TIME) {
                uint256 overtime = howOld.sub(MAX_DEPOSIT_TIME);
                duration = duration.sub(overtime);
            }

            dividends[i] = dividendsForAmountAndTime(user.deposits[i].amount, duration);
        }
    }

    function dividendsForAmountAndTime(uint256 amount, uint256 duration) public pure returns(uint256) {
        return amount
            .mul(DAILY_INTEREST).div(ONE_HUNDRED_PERCENTS)
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
}