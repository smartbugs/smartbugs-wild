pragma solidity 0.4.25;

library Math {
    function min(uint a, uint b) internal pure returns(uint) {
        if (a > b) {
            return b;
    }
        return a;
    }
}


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


library Percent {
    struct percent {
      uint num;
      uint den;
    }

    // storage
    function mul(percent storage p, uint a) internal view returns (uint) {
      if (a == 0) {
        return 0;
      }
      return a*p.num/p.den;
    }

    function div(percent storage p, uint a) internal view returns (uint) {
      return a/p.num*p.den;
    }

    function sub(percent storage p, uint a) internal view returns (uint) {
      uint b = mul(p, a);
      if (b >= a) {
        return 0;
      }
      return a - b;
    }

    function add(percent storage p, uint a) internal view returns (uint) {
      return a + mul(p, a);
    }

    function toMemory(percent storage p) internal view returns (Percent.percent memory) {
      return Percent.percent(p.num, p.den);
    }

    // memory
    function mmul(percent memory p, uint a) internal pure returns (uint) {
      if (a == 0) {
        return 0;
      }
      return a*p.num/p.den;
    }

    function mdiv(percent memory p, uint a) internal pure returns (uint) {
      return a/p.num*p.den;
    }

    function msub(percent memory p, uint a) internal pure returns (uint) {
      uint b = mmul(p, a);
      if (b >= a) {
        return 0;
      }
      return a - b;
    }

    function madd(percent memory p, uint a) internal pure returns (uint) {
      return a + mmul(p, a);
    }
}


library Address {
    function toAddress(bytes source) internal pure returns(address addr) {
      assembly { addr := mload(add(source,0x14)) }
      return addr;
    }

    function isNotContract(address addr) internal view returns(bool) {
      uint length;
      assembly { length := extcodesize(addr) }
      return length == 0;
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


contract Accessibility {
    address private owner;
    modifier onlyOwner() {
        require(msg.sender == owner, "Access denied");
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
    struct Investor {
        uint investment;
        uint paymentTime;
        uint maxPayout; 
        bool exit;
    }

    uint public size;

    mapping (address => Investor) private investors;

    function isInvestor(address addr) public view returns (bool) {
      return investors[addr]. investment > 0;
    }

    function investorInfo(address addr) public view returns(uint investment, uint paymentTime,uint maxPayout,bool exit) {
        investment = investors[addr].investment;
        paymentTime = investors[addr].paymentTime;
        maxPayout = investors[addr].maxPayout;
        exit = investors[addr].exit;
    }

    function newInvestor(address addr, uint investment, uint paymentTime) public onlyOwner returns (bool) {
        // initialize new investor to investment and maxPayout = 2x investment
        Investor storage inv = investors[addr];
        if (inv.investment != 0 || investment == 0) {
            return false;
        }
        inv.exit = false;
        inv.investment = investment; 
        inv.maxPayout = investment.mul(2); 
        inv.paymentTime = paymentTime;
        size++;
        return true;
    }

    function addInvestment(address addr, uint investment,uint dividends) public onlyOwner returns (bool) {
        if (investors[addr].investment == 0) {
            return false;
        }
        investors[addr].investment += investment;

        // Update maximum payout exlude dividends
        investors[addr].maxPayout += (investment-dividends).mul(2);
        return true;
    }

    function setPaymentTime(address addr, uint paymentTime) public onlyOwner returns (bool) {
        if(investors[addr].exit){
            return true;
        }
        if (investors[addr].investment == 0) {
            return false;
        }
        investors[addr].paymentTime = paymentTime;
        return true;
    }
    function investorExit(address addr)  public onlyOwner returns (bool){
        investors[addr].exit = true;
        investors[addr].maxPayout = 0;
        investors[addr].investment = 0;
    }
    function payout(address addr, uint dividend) public onlyOwner returns (uint) {
        uint dividendToPay = 0;
        if(investors[addr].maxPayout <= dividend){
            dividendToPay = investors[addr].maxPayout;
            investorExit(addr);
        } else{
            dividendToPay = dividend;
            investors[addr].maxPayout -= dividend;
      }
        return dividendToPay;
    }
}


library RapidGrowthProtection {
  using RapidGrowthProtection for rapidGrowthProtection;

  struct rapidGrowthProtection {
    uint startTimestamp;
    uint maxDailyTotalInvestment;
    uint8 activityDays;
    mapping(uint8 => uint) dailyTotalInvestment;
  }

  function maxInvestmentAtNow(rapidGrowthProtection storage rgp) internal view returns(uint) {
    uint day = rgp.currDay();
    if (day == 0 || day > rgp.activityDays) {
      return 0;
    }
    if (rgp.dailyTotalInvestment[uint8(day)] >= rgp.maxDailyTotalInvestment) {
      return 0;
    }
    return rgp.maxDailyTotalInvestment - rgp.dailyTotalInvestment[uint8(day)];
  }

    function isActive(rapidGrowthProtection storage rgp) internal view returns(bool) {
        uint day = rgp.currDay();
        return day != 0 && day <= rgp.activityDays;
    }

  function saveInvestment(rapidGrowthProtection storage rgp, uint investment) internal returns(bool) {
    uint day = rgp.currDay();
    if (day == 0 || day > rgp.activityDays) {
      return false;
    }
    if (rgp.dailyTotalInvestment[uint8(day)] + investment > rgp.maxDailyTotalInvestment) {
      return false;
    }
    rgp.dailyTotalInvestment[uint8(day)] += investment;
    return true;
  }

  function startAt(rapidGrowthProtection storage rgp, uint timestamp) internal {
    rgp.startTimestamp = timestamp;

    // restart
    for (uint8 i = 1; i <= rgp.activityDays; i++) {
      if (rgp.dailyTotalInvestment[i] != 0) {
        delete rgp.dailyTotalInvestment[i];
      }
    }
  }

  function currDay(rapidGrowthProtection storage rgp) internal view returns(uint day) {
    if (rgp.startTimestamp > now) {
      return 0;
    }
    day = (now - rgp.startTimestamp) / 24 hours + 1; // +1 for skipping zero day
  }
}


library BonusPool {
    using BonusPool for bonusPool;
    struct bonusLevel {
        uint bonusAmount;
        bool triggered;
        uint triggeredTimestamp; 
        bool bonusSet;
    }

    struct bonusPool {
        uint8 nextLevelToTrigger;
        mapping(uint8 => bonusLevel) bonusLevels;
    }

    function setBonus(bonusPool storage self,uint8 level,uint amount) internal {
        require(!self.bonusLevels[level].bonusSet,"Bonus already set");
        self.bonusLevels[level].bonusAmount = amount;
        self.bonusLevels[level].bonusSet = true;
        self.bonusLevels[level].triggered = false;
    }
    
    function hasMetBonusTriggerLevel(bonusPool storage self) internal returns(bool){
        bonusLevel storage nextBonusLevel = self.bonusLevels[self.nextLevelToTrigger];
        if(address(this).balance >= nextBonusLevel.bonusAmount){
            if(nextBonusLevel.triggered){
                self.goToNextLevel();
                return false;
            }
            return true;
        }
        return false;
    }

    function prizeToPool(bonusPool storage self) internal returns(uint){
        return self.bonusLevels[self.nextLevelToTrigger].bonusAmount;
    }

    function goToNextLevel(bonusPool storage self) internal {
        self.bonusLevels[self.nextLevelToTrigger].triggered = true;
        self.nextLevelToTrigger += 1;
    }
}





contract Myethsss is Accessibility {
    using RapidGrowthProtection for RapidGrowthProtection.rapidGrowthProtection;
    using BonusPool for BonusPool.bonusPool;
    using Percent for Percent.percent;
    using SafeMath for uint;
    using Math for uint;

    // easy read for investors
    using Address for *;
    using Zero for *;

    RapidGrowthProtection.rapidGrowthProtection private m_rgp;
    BonusPool.bonusPool private m_bonusPool;
    mapping(address => bool) private m_referrals;
    InvestorsStorage private m_investors;
    uint totalRealBalance;
    // automatically generates getters
    uint public constant minInvesment = 0.1 ether; //       0.1 eth
    uint public constant maxBalance = 366e5 ether; // 36 600 000 eth
    address public advertisingAddress;
    address public adminsAddress;
    address public riskAddress;
    address public bonusAddress;
    uint public investmentsNumber;
    uint public waveStartup;

  // percents
    Percent.percent private m_1_percent = Percent.percent(1, 100);           //   1/100  *100% = 1%
    Percent.percent private m_1_66_percent = Percent.percent(166, 10000);           //   166/10000*100% = 1.66%
    Percent.percent private m_2_66_percent = Percent.percent(266, 10000);    // 266/10000*100% = 2.66%
    Percent.percent private m_6_66_percent = Percent.percent(666, 10000);    // 666/10000*100% = 6.66% refer bonus
    Percent.percent private m_adminsPercent = Percent.percent(5, 100);       //   5/100  *100% = 5%
    Percent.percent private m_advertisingPercent = Percent.percent(5, 100); // 5/1000  *100% = 5%
    Percent.percent private m_riskPercent = Percent.percent(5, 100); // 5/1000  *100% = 5%
    Percent.percent private m_bonusPercent = Percent.percent(666, 10000);           //   666/10000  *100% = 6.66%

    modifier balanceChanged {
        _;
    }

    modifier notFromContract() {
        require(msg.sender.isNotContract(), "only externally accounts");
        _;
    }

    constructor() public {
        adminsAddress = msg.sender;
        advertisingAddress = msg.sender;
        riskAddress=msg.sender;
        bonusAddress = msg.sender;
        nextWave();
    }

    function() public payable {
        if (msg.value.isZero()) {
            getMyDividends();
            return;
        }
        doInvest(msg.data.toAddress());
    }

    function doDisown() public onlyOwner {
        disown();
    }
// uint timestamp
    function init() public onlyOwner {
        m_rgp.startTimestamp = now + 1;
        m_rgp.maxDailyTotalInvestment = 5000 ether;
        m_rgp.activityDays = 21;
        // Set bonus pool tier
        m_bonusPool.setBonus(0,3000 ether);
        m_bonusPool.setBonus(1,6000 ether);
        m_bonusPool.setBonus(2,10000 ether);
        m_bonusPool.setBonus(3,15000 ether);
        m_bonusPool.setBonus(4,20000 ether);
        m_bonusPool.setBonus(5,25000 ether);
        m_bonusPool.setBonus(6,30000 ether);
        m_bonusPool.setBonus(7,35000 ether);
        m_bonusPool.setBonus(8,40000 ether);
        m_bonusPool.setBonus(9,45000 ether);
        m_bonusPool.setBonus(10,50000 ether);
        m_bonusPool.setBonus(11,60000 ether);
        m_bonusPool.setBonus(12,70000 ether);
        m_bonusPool.setBonus(13,80000 ether);
        m_bonusPool.setBonus(14,90000 ether);
        m_bonusPool.setBonus(15,100000 ether);
        m_bonusPool.setBonus(16,150000 ether);
        m_bonusPool.setBonus(17,200000 ether);
        m_bonusPool.setBonus(18,500000 ether);
        m_bonusPool.setBonus(19,1000000 ether);




    }

    function getBonusAmount(uint8 level) public view returns(uint){
        return m_bonusPool.bonusLevels[level].bonusAmount;
        
    }
    function doBonusPooling() public onlyOwner {
        require(m_bonusPool.hasMetBonusTriggerLevel(),"Has not met next bonus requirement");
        bonusAddress.transfer(m_bonusPercent.mul(m_bonusPool.prizeToPool()));
        m_bonusPool.goToNextLevel();
    }

    function setAdvertisingAddress(address addr) public onlyOwner {
        addr.requireNotZero();
        advertisingAddress = addr;
    }

    function setAdminsAddress(address addr) public onlyOwner {
        addr.requireNotZero();
        adminsAddress = addr;
    }

    function setRiskAddress(address addr) public onlyOwner{
        addr.requireNotZero();
        riskAddress=addr;
    }

    function setBonusAddress(address addr) public onlyOwner {
        addr.requireNotZero();
        bonusAddress = addr;
    }


    function rapidGrowthProtectionmMaxInvestmentAtNow() public view returns(uint investment) {
        investment = m_rgp.maxInvestmentAtNow();
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

    function percent2() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_1_66_percent.num, m_1_66_percent.den);
    }

    function percent3_33() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_2_66_percent.num, m_2_66_percent.den);
    }

    function advertisingPercent() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_advertisingPercent.num, m_advertisingPercent.den);
    }

    function adminsPercent() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_adminsPercent.num, m_adminsPercent.den);
    }
    function riskPercent() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_riskPercent.num, m_riskPercent.den);
    }

    function investorInfo(address investorAddr) public view returns(uint investment, uint paymentTime,uint maxPayout,bool exit, bool isReferral) {
        (investment, paymentTime,maxPayout,exit) = m_investors.investorInfo(investorAddr);
        isReferral = m_referrals[investorAddr];
    }

    function investorDividendsAtNow(address investorAddr) public view returns(uint dividends) {
        dividends = calcDividends(investorAddr);
    }

    function dailyPercentAtNow() public view returns(uint numerator, uint denominator) {
        Percent.percent memory p = dailyPercent();
        (numerator, denominator) = (p.num, p.den);
    }

    function refBonusPercentAtNow() public view returns(uint numerator, uint denominator) {
        Percent.percent memory p = refBonusPercent();
        (numerator, denominator) = (p.num, p.den);
    }

    function getMyDividends() public notFromContract balanceChanged {
      // calculate dividends
        uint dividends = calcDividends(msg.sender);
        require (dividends.notZero(), "cannot pay zero dividends");
        // deduct payout from max
        dividends = m_investors.payout(msg.sender,dividends);
            // update investor payment timestamp
        assert(m_investors.setPaymentTime(msg.sender, now));
      // check enough eth - goto next wave if needed
        if (address(this).balance <= dividends) {
                // nextWave();
            dividends = address(this).balance;
        }

      // transfer dividends to investor
        msg.sender.transfer(dividends);
    }

    function doInvest(address referrerAddr) public payable notFromContract balanceChanged {
        uint investment = msg.value;
        uint receivedEther = msg.value;
        require(investment >= minInvesment, "investment must be >= minInvesment");
        require(address(this).balance <= maxBalance, "the contract eth balance limit");

        if (m_rgp.isActive()) {
        // use Rapid Growth Protection if needed
            uint rpgMaxInvest = m_rgp.maxInvestmentAtNow();
            rpgMaxInvest.requireNotZero();
            investment = Math.min(investment, rpgMaxInvest);
            assert(m_rgp.saveInvestment(investment));

      } 

      // send excess of ether if needed
        if (receivedEther > investment) {
            uint excess = receivedEther - investment;
            msg.sender.transfer(excess);
            receivedEther = investment;
      }

      // commission
        advertisingAddress.transfer(m_advertisingPercent.mul(receivedEther));
        adminsAddress.transfer(m_adminsPercent.mul(receivedEther));
        riskAddress.transfer(m_riskPercent.mul(receivedEther));

        bool senderIsInvestor = m_investors.isInvestor(msg.sender);

      // ref system works only once and only on first invest
        if (referrerAddr.notZero() && !senderIsInvestor && !m_referrals[msg.sender] &&
            referrerAddr != msg.sender && m_investors.isInvestor(referrerAddr)) {

            m_referrals[msg.sender] = true;
            // add referral bonus to referee's investments and pay investor's refer bonus
            uint refBonus = refBonusPercent().mmul(investment);
            // Investment increase 2.66%
            uint refBonuss = refBonusPercentt().mmul(investment);
            // ADD referee bonus to referee investment and maxinvestment
            investment += refBonuss;
            // PAY referer refer bonus directly
            referrerAddr.transfer(refBonus);                                    
            // emit LogNewReferral(msg.sender, referrerAddr, now, refBonus);
        }

      // automatic reinvest - prevent burning dividends
        uint dividends = calcDividends(msg.sender);
        if (senderIsInvestor && dividends.notZero()) {
            investment += dividends;
        }

        if (senderIsInvestor) {
                // update existing investor
            assert(m_investors.addInvestment(msg.sender, investment, dividends));
            assert(m_investors.setPaymentTime(msg.sender, now));
        } else {
            // create new investor
            assert(m_investors.newInvestor(msg.sender, investment, now));
        }

        investmentsNumber++;
    }

    function getMemInvestor(address investorAddr) internal view returns(InvestorsStorage.Investor memory) {
        (uint investment, uint paymentTime,uint maxPayout,bool exit) = m_investors.investorInfo(investorAddr);
        return InvestorsStorage.Investor(investment, paymentTime,maxPayout,exit);
    }

    function calcDividends(address investorAddr) internal view returns(uint dividends) {
        InvestorsStorage.Investor memory investor = getMemInvestor(investorAddr);

      // safe gas if dividends will be 0,  
        if (investor.investment.isZero()
        // || now.sub(investor.paymentTime) < 1 minutes
        ) {
            return 0;
        }

        // for prevent burning daily dividends if 24h did not pass - calculate it per 10 min interval
        // if daily percent is X, then 10min percent = X / (24h / 10 min) = X / 144

        // and we must to get numbers of 10 min interval after investor got payment:
        // (now - investor.paymentTime) / 10min

        // finaly calculate dividends = ((now - investor.paymentTime) / 10min) * (X * investor.investment)  / 144)
        Percent.percent memory p = dailyPercent();
        // dividends = ((now - investor.paymentTime) / 10 minutes) * (p.mmul(investor.investment) / 144);
        dividends = ((now - investor.paymentTime) / 10 minutes) * (p.mmul(investor.investment) / 144);
      //  dividends =  p.mmul(investor.investment);
    }

    function dailyPercent() internal view returns(Percent.percent memory p) {
        uint balance = address(this).balance;

      // (2) 1.66% if balance < 50 000 ETH
    
      // (1) 1% if >50 000 ETH

        if (balance < 50000 ether) {
            p = m_1_66_percent.toMemory();    // (2)
        } else {
            p = m_1_percent.toMemory();    // (1)
        }
    }

    function refBonusPercent() internal view returns(Percent.percent memory p) {
      //fix refer bonus payment to 6.66%
      p = m_6_66_percent.toMemory();
    }

function refBonusPercentt() internal view returns(Percent.percent memory p) {
      //fix refer bonus to 2.66%
      p = m_2_66_percent.toMemory();
    }

    function nextWave() private {
        m_investors = new InvestorsStorage();
        investmentsNumber = 0;
        waveStartup = now;
        m_rgp.startAt(now);
    }
}