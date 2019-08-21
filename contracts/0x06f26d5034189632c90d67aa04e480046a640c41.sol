/*
 * EtherLab is an investment fund.
 * Telegram: https://t.me/EtherLabBot.
 * The profit is 1.5% for 24 hours.
 * The deposit is included in the payments, 100 days after the deposit is over and eliminated.
 * Minimum deposit is 0.01 ETH.
 * Each deposit is a new deposit contributed to the community.
 * No more than 50 deposits from one ETH wallet are allowed.
 * Referral system:
 *   Line 1 - 3%
 *   Line 2 - 1.5%
 *   Line 3 - 0.5%
 * If you indicate your referral, you get 2% refback.
 */

pragma solidity ^0.4.24;

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

contract EtherLab {
    using SafeMath for uint256;
    
    uint256 constant public TOTAL = 10000;                              // 100%
    uint256 constant public DIVIDENTS = 150;                            // 1.5%
    uint256 constant public MARKETING = 2000;                           // 20%
    uint256 constant public COMISSION = 500;                            // 5%
    uint256 constant public DEPOSIT_TIME = 100 days;                    // 150%
    uint256 constant public REFBACK = 200;                              // 2%
    uint256[] /*constant*/ public referralPercents = [300, 150, 50];   // 3%, 1.5%, 0.5%
    uint256 constant public ACTIVATE = 0;
    uint256 constant public MAX_DEPOSITS = 50;

    struct Deposit {
        uint256 time;
        uint256 amount;
    }

    struct User {
        address referrer;
        uint256 firstTime;
        uint256 lastPayment;
        Deposit[] deposits;
    }
    
    address public marketing = 0xa559c2a74407CA8B283A928E8cb561A3f977AFD7;
    address public team = 0xc0138acF1b97224E08Fd5E71f46FBEa71d481805;
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
    
    function() public payable {
        require(running, "EtherLab is not running");
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
                if (now >= user.deposits[i].time.add(DEPOSIT_TIME)) {
                    user.deposits[i] = user.deposits[user.deposits.length - 1];
                    user.deposits.length -= 1;
                    i -= 1;
                }
            }
        }

        // Deposit
        if (msg.value > 0) {
            if (user.firstTime == 0) {
                user.firstTime = now;
                user.lastPayment = now;
                emit InvestorAdded(msg.sender);
            }

            // Create deposit
            user.deposits.push(Deposit({
                time: now,
                amount: msg.value
            }));
            require(user.deposits.length <= MAX_DEPOSITS, "Too many deposits per user");
            emit DepositAdded(msg.sender, user.deposits.length, msg.value);

            // Add to total deposits
            totalDeposits = totalDeposits.add(msg.value);
            emit TotalDepositsChanged(totalDeposits);

            // Add referral if possible
            if (user.referrer == address(0) && msg.data.length == 20) {
                address referrer = _bytesToAddress(msg.data);
                if (referrer != address(0) && referrer != msg.sender && users[referrer].firstTime > 0 && now >= users[referrer].firstTime.add(ACTIVATE))
                {
                    user.referrer = referrer;
                    msg.sender.transfer(msg.value.mul(REFBACK).div(TOTAL));
                    emit ReferrerAdded(msg.sender, referrer);
                }
            }

            // Referrers fees
            referrer = users[msg.sender].referrer;
            for (i = 0; referrer != address(0) && i < referralPercents.length; i++) {
                uint256 refAmount = msg.value.mul(referralPercents[i]).div(TOTAL);
                referrer.send(refAmount); // solium-disable-line security/no-send
                emit ReferrerPayed(msg.sender, referrer, msg.value, refAmount, i);
                referrer = users[referrer].referrer;
            }

            // Marketing and team fees
            uint256 marketingFee = msg.value.mul(MARKETING).div(TOTAL);
            uint256 teamFee = msg.value.mul(COMISSION).div(TOTAL);
            marketing.send(marketingFee); // solium-disable-line security/no-send
            team.send(teamFee); // solium-disable-line security/no-send
            emit FeePayed(msg.sender, marketingFee.add(teamFee));
        }

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
            if (howOld > DEPOSIT_TIME) {
                uint256 overtime = howOld.sub(DEPOSIT_TIME);
                duration = duration.sub(overtime);
            }

            dividends[i] = dividendsForAmountAndTime(user.deposits[i].amount, duration);
        }
    }

    function dividendsForAmountAndTime(uint256 amount, uint256 duration) public pure returns(uint256) {
        return amount
            .mul(DIVIDENTS).div(TOTAL)
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