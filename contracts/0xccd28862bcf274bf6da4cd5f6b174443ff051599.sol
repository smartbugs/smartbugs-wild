pragma solidity 0.4.25;


/**
*
* ETH INVESTMENT SMART PLATFORM - ETHUP
* Web               - https://ethup.io
* GitHub            - https://github.com/ethup/ethup
* Twitter           - https://twitter.com/ethup1
* Youtube           - https://www.youtube.com/channel/UC4JMZcpySACj4lGbXLJm9KQ
* EN  Telegram_chat: https://t.me/Ethup_en
* RU  Telegram_chat: https://t.me/Ethup_ru
* KOR Telegram_chat: https://t.me/Ethup_kor
* CN  Telegram_chat: https://t.me/Ethup_cn
* Email:             mailto:info(at sign)ethup.io
* 
* 
*  - GAIN 1% - 4% PER 24 HOURS
*  - Life-long payments
*  - The revolutionary reliability
*  - Minimal contribution 0.01 ETH
*  - Currency and payment - ETH
*  - Contribution allocation schemes:
*    -- 85,0% payments
*    --   10% marketing
*    --    5% technical support
*
*   ---About the Project
*  Blockchain-enabled smart contracts have opened a new era of trustless relationships without 
*  intermediaries. This technology opens incredible financial possibilities. Our automated investment 
*  smart platform is written into a smart contract, uploaded to the Ethereum blockchain and can be 
*  freely accessed online. In order to insure our investors' complete security, full control over the 
*  project has been transferred from the organizers to the smart contract: nobody can influence the 
*  system's permanent autonomous functioning.
* 
* ---How to use:
*  1. Select a level and send from ETH wallet to the smart contract address 0xeccf2a50fca80391b0380188255866f0fc7fe852
*     any amount from 0.01 to 50 ETH.
*
*       Level 1: from 0.01 to 0.1 ETH - 1%
*       Level 2: from 0.1 to 1 ETH - 1.5%
*       Level 3: from 1 to 5 ETH - 2.0%
*       Level 4: from 5 to 10 ETH - 2.5%
*       Level 5: from 10 to 20 ETH - 3%.
*       Level 6: from 20 to 30 ETH - 3.5%
*       Level 7: from 30 to 50 ETH - 4%
*
*  2. Verify your transaction in the history of your application (wallet) or etherscan.io, specifying the address 
*     of your wallet.
*  3a. Claim your profit by sending 0 ether transaction (every day, every week, i don't care unless you're 
*      spending too much on GAS) to the smart contract address 0xeccf2a50fca80391b0380188255866f0fc7fe852.
*  OR
*  3b. For add investment, you need to deposit the amount that you want to add and the 
*      accrued interest automatically summed to your new contribution.
*  
* RECOMMENDED GAS LIMIT: 210000
* RECOMMENDED GAS PRICE: https://ethgasstation.info/
* You can check the payments on the etherscan.io site, in the "Internal Txns" tab of your wallet.
*
* Every 24 hours from the moment of the deposit or from the last successful write-off of the accrued interest, 
* the smart contract will transfer your dividends to your account that corresponds to the number of your wallet. 
* Dividends are accrued until 150% of the investment is paid.
* After receiving 150% of all invested funds (or 50% of profits), your wallet will disconnected from payments. 
* You can make reinvestment by receiving an additional + 10% for the deposit amount and continue the participation. 
* The bonus will received only by the participant who has already received 150% of the profits and invests again.
*
* The amount of daily charges depends on the sum of all the participant's contributions to the smart contract.
*
* In case you make a contribution without first removing the accrued interest,
* it is added to your new contribution and credited to your account in smart contract
*
* ---Additional tools embedded in the smart contract:
*     - Referral program 5%. The same bonus gets referral and referrer.
*     - Reinvestment. After full payment of your first investment, you can receive a 10% bonus for reinvesting funds. 
*       You can reinvest any amount.
*     - BOOST mode. Get the percentage of your funds remaining in the system. 
*
* ---It is not allowed to transfer from exchanges, only from your personal ETH wallet, for which you 
* have private keys.
* 
* Contracts reviewed and approved by pros!
* 
* Main contract - EthUp. Scroll down to find it.
*/ 


library Zero {
    function requireNotZero(address addr) internal pure {
        require(addr != address(0), "require not zero address");
    }

    function requireNotZero(uint val) internal pure {
        require(val != 0, "require not zero value");
    }

    function notZero(address addr) internal pure returns(bool) {
        return !(addr == address(0));
    }

    function isZero(address addr) internal pure returns(bool) {
        return addr == address(0);
    }

    function isZero(uint a) internal pure returns(bool) {
        return a == 0;
    }

    function notZero(uint a) internal pure returns(bool) {
        return a != 0;
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

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

library Percent {
    using SafeMath for uint;

    // Solidity automatically throws when dividing by 0
    struct percent {
        uint num;
        uint den;
    }

    function mul(percent storage p, uint a) internal view returns (uint) {
        if (a == 0) {
            return 0;
        }
        return a.mul(p.num).div(p.den);
    }

    function div(percent storage p, uint a) internal view returns (uint) {
        return a.div(p.num).mul(p.den);
    }

    function sub(percent storage p, uint a) internal view returns (uint) {
        uint b = mul(p, a);
        if (b >= a) {
            return 0; // solium-disable-line lbrace
        }
        return a.sub(b);
    }

    function add(percent storage p, uint a) internal view returns (uint) {
        return a.add(mul(p, a));
    }

    function toMemory(percent storage p) internal view returns (Percent.percent memory) {
        return Percent.percent(p.num, p.den);
    }

    // memory
    function mmul(percent memory p, uint a) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        return a.mul(p.num).div(p.den);
    }

    function mdiv(percent memory p, uint a) internal pure returns (uint) {
        return a.div(p.num).mul(p.den);
    }

    function msub(percent memory p, uint a) internal pure returns (uint) {
        uint b = mmul(p, a);
        if (b >= a) {
            return 0;
        }
        return a.sub(b);
    }

    function madd(percent memory p, uint a) internal pure returns (uint) {
        return a.add(mmul(p, a));
    }
}

library ToAddress {

    function toAddress(bytes source) internal pure returns(address addr) {
        assembly { addr := mload(add(source, 0x14)) }
        return addr;
    }

    function isNotContract(address addr) internal view returns(bool) {
        uint length;
        assembly { length := extcodesize(addr) }
        return length == 0;
    }
}

contract Accessibility {

    address private owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "access denied");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function disown() internal {
        delete owner;
    }
}

contract InvestorsStorage is Accessibility {
    using SafeMath for uint;

    struct Dividends {
        uint value;     //paid
        uint limit;
        uint deferred;  //not paid yet
    }

    struct Investor {
        uint investment;
        uint paymentTime;
        Dividends dividends;
    }

    uint public size;

    mapping (address => Investor) private investors;

    function isInvestor(address addr) public view returns (bool) {
        return investors[addr].investment > 0;
    }

    function investorInfo(
        address addr
    )
        public
        view
        returns (
            uint investment,
            uint paymentTime,
            uint value,
            uint limit,
            uint deferred
        )
    {
        investment = investors[addr].investment;
        paymentTime = investors[addr].paymentTime;
        value = investors[addr].dividends.value;
        limit = investors[addr].dividends.limit;
        deferred = investors[addr].dividends.deferred;
    }

    function newInvestor(
        address addr,
        uint investment,
        uint paymentTime,
        uint dividendsLimit
    )
        public
        onlyOwner
        returns (
            bool
        )
    {
        Investor storage inv = investors[addr];
        if (inv.investment != 0 || investment == 0) {
            return false;
        }
        inv.investment = investment;
        inv.paymentTime = paymentTime;
        inv.dividends.limit = dividendsLimit;
        size++;
        return true;
    }

    function addInvestment(address addr, uint investment) public onlyOwner returns (bool) {
        if (investors[addr].investment == 0) {
            return false;
        }
        investors[addr].investment = investors[addr].investment.add(investment);
        return true;
    }

    function setPaymentTime(address addr, uint paymentTime) public onlyOwner returns (bool) {
        if (investors[addr].investment == 0) {
            return false;
        }
        investors[addr].paymentTime = paymentTime;
        return true;
    }

    function addDeferredDividends(address addr, uint dividends) public onlyOwner returns (bool) {
        if (investors[addr].investment == 0) {
            return false;
        }
        investors[addr].dividends.deferred = investors[addr].dividends.deferred.add(dividends);
        return true;
    }

    function addDividends(address addr, uint dividends) public onlyOwner returns (bool) {
        if (investors[addr].investment == 0) {
            return false;
        }
        if (investors[addr].dividends.value + dividends > investors[addr].dividends.limit) {
            investors[addr].dividends.value = investors[addr].dividends.limit;
        } else {
            investors[addr].dividends.value = investors[addr].dividends.value.add(dividends);
        }
        return true;
    }

    function setNewInvestment(address addr, uint investment, uint limit) public onlyOwner returns (bool) {
        if (investors[addr].investment == 0) {
            return false;
        }
        investors[addr].investment = investment;
        investors[addr].dividends.limit = limit;
        // reset payment dividends
        investors[addr].dividends.value = 0;
        investors[addr].dividends.deferred = 0;

        return true;
    }

    function addDividendsLimit(address addr, uint limit) public onlyOwner returns (bool) {
        if (investors[addr].investment == 0) {
            return false;
        }
        investors[addr].dividends.limit = investors[addr].dividends.limit.add(limit);

        return true;
    }
}

contract EthUp is Accessibility {
    using Percent for Percent.percent;
    using SafeMath for uint;
    using Zero for *;
    using ToAddress for *;

    // investors storage - iterable map;
    InvestorsStorage private m_investors;
    mapping(address => bool) private m_referrals;

    // automatically generates getters
    address public advertisingAddress;
    address public adminsAddress;
    uint public investmentsNumber;
    uint public constant MIN_INVESTMENT = 10 finney; // 0.01 eth
    uint public constant MAX_INVESTMENT = 50 ether;
    uint public constant MAX_BALANCE = 1e5 ether; // 100 000 eth

    // percents
    Percent.percent private m_1_percent = Percent.percent(1, 100);          //  1/100   *100% = 1%
    Percent.percent private m_1_5_percent = Percent.percent(15, 1000);      //  15/1000 *100% = 1.5%
    Percent.percent private m_2_percent = Percent.percent(2, 100);          //  2/100   *100% = 2%
    Percent.percent private m_2_5_percent = Percent.percent(25, 1000);      //  25/1000 *100% = 2.5%
    Percent.percent private m_3_percent = Percent.percent(3, 100);          //  3/100   *100% = 3%
    Percent.percent private m_3_5_percent = Percent.percent(35, 1000);      //  35/1000 *100% = 3.5%
    Percent.percent private m_4_percent = Percent.percent(4, 100);          //  4/100   *100% = 4%

    Percent.percent private m_refPercent = Percent.percent(5, 100);         //  5/100   *100% = 5%
    Percent.percent private m_adminsPercent = Percent.percent(5, 100);      //  5/100   *100% = 5%
    Percent.percent private m_advertisingPercent = Percent.percent(1, 10);  //  1/10    *100% = 10%

    Percent.percent private m_maxDepositPercent = Percent.percent(15, 10);  //  15/10   *100% = 150%
    Percent.percent private m_reinvestPercent = Percent.percent(1, 10);     //  10/100  *100% = 10%

    // more events for easy read from blockchain
    event LogSendExcessOfEther(address indexed addr, uint when, uint value, uint investment, uint excess);
    event LogNewInvestor(address indexed addr, uint when);
    event LogNewInvestment(address indexed addr, uint when, uint investment, uint value);
    event LogNewReferral(address indexed addr, address indexed referrerAddr, uint when, uint refBonus);
    event LogReinvest(address indexed addr, uint when, uint investment);
    event LogPayDividends(address indexed addr, uint when, uint value);
    event LogPayReferrerBonus(address indexed addr, uint when, uint value);
    event LogBalanceChanged(uint when, uint balance);
    event LogDisown(uint when);

    modifier balanceChanged() {
        _;
        emit LogBalanceChanged(now, address(this).balance);
    }

    modifier notFromContract() {
        require(msg.sender.isNotContract(), "only externally accounts");
        _;
    }

    modifier checkPayloadSize(uint size) {
        require(msg.data.length >= size + 4);
        _;
    }

    constructor() public {
        adminsAddress = msg.sender;
        advertisingAddress = msg.sender;

        m_investors = new InvestorsStorage();
        investmentsNumber = 0;
    }

    function() public payable {
        // investor get him dividends
        if (msg.value.isZero()) {
            getMyDividends();
            return;
        }

        // sender do invest
        doInvest(msg.sender, msg.data.toAddress());
    }

    function doDisown() public onlyOwner {
        disown();
        emit LogDisown(now);
    }

    function investorsNumber() public view returns(uint) {
        return m_investors.size();
    }

    function balanceETH() public view returns(uint) {
        return address(this).balance;
    }

    function percent1() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_1_percent.num, m_1_percent.den);
    }

    function percent1_5() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_1_5_percent.num, m_1_5_percent.den);
    }

    function percent2() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_2_percent.num, m_2_percent.den);
    }

    function percent2_5() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_2_5_percent.num, m_2_5_percent.den);
    }

    function percent3() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_3_percent.num, m_3_percent.den);
    }

    function percent3_5() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_3_5_percent.num, m_3_5_percent.den);
    }

    function percent4() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_4_percent.num, m_4_percent.den);
    }

    function advertisingPercent() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_advertisingPercent.num, m_advertisingPercent.den);
    }

    function adminsPercent() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_adminsPercent.num, m_adminsPercent.den);
    }

    function maxDepositPercent() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_maxDepositPercent.num, m_maxDepositPercent.den);
    }

    function investorInfo(
        address investorAddr
    )
        public
        view
        returns (
            uint investment,
            uint paymentTime,
            uint dividends,
            uint dividendsLimit,
            uint dividendsDeferred,
            bool isReferral
        )
    {
        (
            investment,
            paymentTime,
            dividends,
            dividendsLimit,
            dividendsDeferred
        ) = m_investors.investorInfo(investorAddr);

        isReferral = m_referrals[investorAddr];
    }

    function getInvestorDividendsAtNow(
        address investorAddr
    )
        public
        view
        returns (
            uint dividends
        )
    {
        dividends = calcDividends(investorAddr);
    }

    function getDailyPercentAtNow(
        address investorAddr
    )
        public
        view
        returns (
            uint numerator,
            uint denominator
        )
    {
        InvestorsStorage.Investor memory investor = getMemInvestor(investorAddr);

        Percent.percent memory p = getDailyPercent(investor.investment);
        (numerator, denominator) = (p.num, p.den);
    }

    function getRefBonusPercentAtNow() public view returns(uint numerator, uint denominator) {
        Percent.percent memory p = getRefBonusPercent();
        (numerator, denominator) = (p.num, p.den);
    }

    function getMyDividends() public notFromContract balanceChanged {
        // calculate dividends
        uint dividends = calcDividends(msg.sender);
        require(dividends.notZero(), "cannot to pay zero dividends");

        // update investor payment timestamp
        assert(m_investors.setPaymentTime(msg.sender, now));

        // check enough eth
        if (address(this).balance < dividends) {
            dividends = address(this).balance;
        }

        // update payouts dividends
        assert(m_investors.addDividends(msg.sender, dividends));

        // transfer dividends to investor
        msg.sender.transfer(dividends);
        emit LogPayDividends(msg.sender, now, dividends);
    }

    // for fiat investors and bounty program
    function createInvest(
        address investorAddress,
        address referrerAddr
    )
        public
        payable
        notFromContract
        balanceChanged
        onlyOwner
    {
        //require(adminsAddress == msg.sender, "only admin can do invest from new investor");
        doInvest(investorAddress, referrerAddr);
    }

    function doInvest(
        address investorAddress,
        address referrerAddr
    )
        public
        payable
        notFromContract
        balanceChanged
    {
        uint investment = msg.value;
        uint receivedEther = msg.value;

        require(investment >= MIN_INVESTMENT, "investment must be >= MIN_INVESTMENT");
        require(address(this).balance + investment <= MAX_BALANCE, "the contract eth balance limit");

        // send excess of ether if needed
        if (receivedEther > MAX_INVESTMENT) {
            uint excess = receivedEther - MAX_INVESTMENT;
            investment = MAX_INVESTMENT;
            investorAddress.transfer(excess);
            emit LogSendExcessOfEther(investorAddress, now, receivedEther, investment, excess);
        }

        // commission
        uint advertisingCommission = m_advertisingPercent.mul(investment);
        uint adminsCommission = m_adminsPercent.mul(investment);
        advertisingAddress.transfer(advertisingCommission);
        adminsAddress.transfer(adminsCommission);

        bool senderIsInvestor = m_investors.isInvestor(investorAddress);

        // ref system works only once and only on first invest
        if (referrerAddr.notZero() &&
            !senderIsInvestor &&
            !m_referrals[investorAddress] &&
            referrerAddr != investorAddress &&
            m_investors.isInvestor(referrerAddr)) {

            // add referral bonus to investor`s and referral`s investments
            uint refBonus = getRefBonusPercent().mmul(investment);
            assert(m_investors.addInvestment(referrerAddr, refBonus)); // add referrer bonus
            investment = investment.add(refBonus);                     // add referral bonus
            m_referrals[investorAddress] = true;
            emit LogNewReferral(investorAddress, referrerAddr, now, refBonus);
        }

        // Dividends cannot be greater then 150% from investor investment
        uint maxDividends = getMaxDepositPercent().mmul(investment);

        if (senderIsInvestor) {
            // check for reinvest
            InvestorsStorage.Investor memory investor = getMemInvestor(investorAddress);
            if (investor.dividends.value == investor.dividends.limit) {
                uint reinvestBonus = getReinvestBonusPercent().mmul(investment);
                investment = investment.add(reinvestBonus);
                maxDividends = getMaxDepositPercent().mmul(investment);
                // reinvest
                assert(m_investors.setNewInvestment(investorAddress, investment, maxDividends));
                emit LogReinvest(investorAddress, now, investment);
            } else {
                // prevent burning dividends
                uint dividends = calcDividends(investorAddress);
                if (dividends.notZero()) {
                    assert(m_investors.addDeferredDividends(investorAddress, dividends));
                }
                // update existing investor investment
                assert(m_investors.addInvestment(investorAddress, investment));
                assert(m_investors.addDividendsLimit(investorAddress, maxDividends));
            }
            assert(m_investors.setPaymentTime(investorAddress, now));
        } else {
            // create new investor
            assert(m_investors.newInvestor(investorAddress, investment, now, maxDividends));
            emit LogNewInvestor(investorAddress, now);
        }

        investmentsNumber++;
        emit LogNewInvestment(investorAddress, now, investment, receivedEther);
    }

    function setAdvertisingAddress(address addr) public onlyOwner {
        addr.requireNotZero();
        advertisingAddress = addr;
    }

    function setAdminsAddress(address addr) public onlyOwner {
        addr.requireNotZero();
        adminsAddress = addr;
    }

    function getMemInvestor(
        address investorAddr
    )
        internal
        view
        returns (
            InvestorsStorage.Investor memory
        )
    {
        (
            uint investment,
            uint paymentTime,
            uint dividends,
            uint dividendsLimit,
            uint dividendsDeferred
        ) = m_investors.investorInfo(investorAddr);

        return InvestorsStorage.Investor(
            investment,
            paymentTime,
            InvestorsStorage.Dividends(
                dividends,
                dividendsLimit,
                dividendsDeferred)
        );
    }

    function calcDividends(address investorAddr) internal view returns(uint dividends) {
        InvestorsStorage.Investor memory investor = getMemInvestor(investorAddr);
        uint interval = 1 days;
        uint pastTime = now.sub(investor.paymentTime);

        // safe gas if dividends will be 0
        if (investor.investment.isZero() || pastTime < interval) {
            return 0;
        }

        // paid dividends cannot be greater then 150% from investor investment
        if (investor.dividends.value >= investor.dividends.limit) {
            return 0;
        }

        Percent.percent memory p = getDailyPercent(investor.investment);
        Percent.percent memory c = Percent.percent(p.num + p.den, p.den);

        uint intervals = pastTime.div(interval);
        uint totalDividends = investor.dividends.limit.add(investor.investment).sub(investor.dividends.value).sub(investor.dividends.deferred);

        dividends = investor.investment;
        for (uint i = 0; i < intervals; i++) {
            dividends = c.mmul(dividends);
            if (dividends > totalDividends) {
                dividends = totalDividends.add(investor.dividends.deferred);
                break;
            }
        }

        dividends = dividends.sub(investor.investment);

        //uint totalDividends = dividends + investor.dividends;
        //if (totalDividends >= investor.dividendsLimit) {
        //    dividends = investor.dividendsLimit - investor.dividends;
        //}
    }

    function getMaxDepositPercent() internal view returns(Percent.percent memory p) {
        p = m_maxDepositPercent.toMemory();
    }

    function getDailyPercent(uint value) internal view returns(Percent.percent memory p) {
        // (1) 1% if 0.01 ETH <= value < 0.1 ETH
        // (2) 1.5% if 0.1 ETH <= value < 1 ETH
        // (3) 2% if 1 ETH <= value < 5 ETH
        // (4) 2.5% if 5 ETH <= value < 10 ETH
        // (5) 3% if 10 ETH <= value < 20 ETH
        // (6) 3.5% if 20 ETH <= value < 30 ETH
        // (7) 4% if 30 ETH <= value <= 50 ETH

        if (MIN_INVESTMENT <= value && value < 100 finney) {
            p = m_1_percent.toMemory();                     // (1)
        } else if (100 finney <= value && value < 1 ether) {
            p = m_1_5_percent.toMemory();                   // (2)
        } else if (1 ether <= value && value < 5 ether) {
            p = m_2_percent.toMemory();                     // (3)
        } else if (5 ether <= value && value < 10 ether) {
            p = m_2_5_percent.toMemory();                   // (4)
        } else if (10 ether <= value && value < 20 ether) {
            p = m_3_percent.toMemory();                     // (5)
        } else if (20 ether <= value && value < 30 ether) {
            p = m_3_5_percent.toMemory();                   // (6)
        } else if (30 ether <= value && value <= MAX_INVESTMENT) {
            p = m_4_percent.toMemory();                     // (7)
        }
    }

    function getRefBonusPercent() internal view returns(Percent.percent memory p) {
        p = m_refPercent.toMemory();
    }

    function getReinvestBonusPercent() internal view returns(Percent.percent memory p) {
        p = m_reinvestPercent.toMemory();
    }
}