pragma solidity ^0.4.24;

/*
 * ETH SMART GAME DISTRIBUTION PROJECT
 * Web:                     https://efirica.io
 * Telegram_channel:        https://t.me/efirica_io
 * EN Telegram_chat:        https://t.me/efirica_chat
 * RU Telegram_chat:        https://t.me/efirica_chat_ru
 * Telegram Support:        @efirica
 * 
 * - GAIN 0.5-5% per 24 HOURS lifetime income without invitations
 * - Life-long payments
 * - New technologies on blockchain
 * - Unique code (without admin, automatic % health for lifelong game, not fork !!! )
 * - Minimal contribution 0.01 eth
 * - Currency and payment - ETH
 * - Contribution allocation schemes:
 *    -- 99% payments (In some cases, the included 10% marketing to players when specifying a referral link)
 *    -- 1% technical support
 * 
 * --- About the Project
 * EFIRICA - smart game contract, new technologies on blockchain ETH, have opened code allowing
 *           to work autonomously without admin for as long as possible with honest smart code.
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

// File: contracts/Efirica.sol

contract Efirica {
    using SafeMath for uint256;

    uint256 constant public ONE_HUNDRED_PERCENTS = 10000;
    uint256 constant public LOWEST_DIVIDEND_PERCENTS = 50; // 0.50%
    uint256 constant public HIGHEST_DIVIDEND_PERCENTS = 500; // 5.00%
    uint256[] /*constant*/ public referralPercents = [500, 300, 200]; // 5%, 3%, 2%

    address public admin = msg.sender;
    uint256 public totalDeposits = 0;
    uint256 public currentPercents = 500; // 5%
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public joinedAt;
    mapping(address => uint256) public updatedAt;
    mapping(address => address) public referrers;

    event InvestorAdded(address investor);
    event ReferrerAdded(address investor, address referrer);
    event DepositAdded(address investor, uint256 deposit, uint256 amount);
    event DividendPayed(address investor, uint256 dividend);
    event ReferrerPayed(address investor, address referrer, uint256 amount);
    event AdminFeePayed(address investor, uint256 amount);
    event TotalDepositsChanged(uint256 totalDeposits);
    event BalanceChanged(uint256 balance);
    
    function() public payable {
        // Dividends
        uint256 dividends = dividendsForUser(msg.sender);
        if (dividends > 0) {
            if (dividends > address(this).balance) {
                dividends = address(this).balance;
            }
            msg.sender.transfer(dividends);
            updatedAt[msg.sender] = now; // solium-disable-line security/no-block-members
            currentPercents = generalPercents();
            emit DividendPayed(msg.sender, dividends);
        }

        // Deposit
        if (msg.value > 0) {
            if (deposits[msg.sender] == 0) {
                joinedAt[msg.sender] = now; // solium-disable-line security/no-block-members
                emit InvestorAdded(msg.sender);
            }
            updatedAt[msg.sender] = now; // solium-disable-line security/no-block-members
            deposits[msg.sender] = deposits[msg.sender].add(msg.value);
            emit DepositAdded(msg.sender, deposits[msg.sender], msg.value);

            totalDeposits = totalDeposits.add(msg.value);
            emit TotalDepositsChanged(totalDeposits);

            // Add referral if possible
            if (referrers[msg.sender] == address(0) && msg.data.length == 20) {
                address referrer = bytesToAddress(msg.data);
                if (referrer != address(0) && deposits[referrer] > 0 && now >= joinedAt[referrer].add(1 days)) { // solium-disable-line security/no-block-members
                    referrers[msg.sender] = referrer;
                    emit ReferrerAdded(msg.sender, referrer);
                }
            }

            // Referrers fees
            referrer = referrers[msg.sender];
            for (uint i = 0; referrer != address(0) && i < referralPercents.length; i++) {
                uint256 refAmount = msg.value.mul(referralPercents[i]).div(ONE_HUNDRED_PERCENTS);
                referrer.send(refAmount); // solium-disable-line security/no-send
                emit ReferrerPayed(msg.sender, referrer, refAmount);
                referrer = referrers[referrer];
            }

            // Admin fee 1%
            uint256 adminFee = msg.value.div(100);
            admin.send(adminFee); // solium-disable-line security/no-send
            emit AdminFeePayed(msg.sender, adminFee);
        }

        emit BalanceChanged(address(this).balance);
    }

    function dividendsForUser(address user) public view returns(uint256) {
        return dividendsForPercents(user, percentsForUser(user));
    }

    function dividendsForPercents(address user, uint256 percents) public view returns(uint256) {
        return deposits[user]
            .mul(percents).div(ONE_HUNDRED_PERCENTS)
            .mul(now.sub(updatedAt[user])).div(1 days); // solium-disable-line security/no-block-members
    }

    function percentsForUser(address user) public view returns(uint256) {
        uint256 percents = generalPercents();

        // Referrals should have increased percents (+10%)
        if (referrers[user] != address(0)) {
            percents = percents.mul(110).div(100);
        }

        return percents;
    }

    function generalPercents() public view returns(uint256) {
        // From 5% to 0.5% with 0.1% step (45 steps) while health drops from 100% to 0% 
        uint256 percents = LOWEST_DIVIDEND_PERCENTS.add(
            HIGHEST_DIVIDEND_PERCENTS.sub(LOWEST_DIVIDEND_PERCENTS)
                .mul(healthPercents().mul(45).div(ONE_HUNDRED_PERCENTS)).div(45)
        );

        // Percents should never increase
        if (percents > currentPercents) {
            percents = currentPercents;
        }

        return percents;
    }

    function healthPercents() public view returns(uint256) {
        if (totalDeposits == 0) {
            return ONE_HUNDRED_PERCENTS;
        }

        return address(this).balance
            .mul(ONE_HUNDRED_PERCENTS).div(totalDeposits);
    }

    function bytesToAddress(bytes data) internal pure returns(address addr) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            addr := mload(add(data, 0x14)) 
        }
    }
}