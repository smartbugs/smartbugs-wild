pragma solidity ^0.4.23;

/**
*
* Investment project for the distribution of cryptocurrency Ethereum
* Web              - http://magic-eth.com/ 
* Youtube          - https://www.youtube.com/channel/UCZ2P-5NMSHdveoK9e_BRUBw/ 
* Email:           - support(at sign)magic-eth.com 
* 
* 
* - Payments from 3% to 6% every 24 hours
* - Lifetime payments
* - Reliability Smart Contract
* - Minimum deposit 0.03 ETH
* - Currency and Payment - Ethereum (ETH)
* - Distribution of deposits:
* - 80% For payments to participants of the Fund
* - 5% INSURANCE FUND
* - 10% Advertising and project development
* - 1% Commission services and transactions
* - 2% Payroll fund
* - 2% Technical support
*    
*
*   ---About the Project
* Intellectual contracts with Blockchain support have opened a new era of secure relationships without intermediaries.
This technology opens up incredible financial opportunities. Our automated investment model
and asset allocation is written in a smart contract, loaded into the Ethereum blockchain and opened for public access on the Internet and in Blockchain. To ensure the complete safety of all our investors and safe investments, full control over the project was transferred from the organizers to the Smart contract - and now no one can influence continuous autonomous functioning of the system.
* 
* ---How to use:
*  1. Send from ETH wallet to the smart contract address
*     any amount from 0.03 ETH.
*  2. Verify your transaction in the history of your application or etherscan.io, specifying the address 
*     of your wallet.
*  3. Get your profit by sending 0 live transactions (every day, every week, at any time, but not more often than once per 24 hours.
*  4. To reinvest, you need to deposit the amount you want to reinvest, and the interest accrued is automatically added to your new deposit.
*  
* RECOMMENDED GAS LIMIT: 200000
* RECOMMENDED GAS PRICE: https://ethgasstation.info/
* You can check the payments on the etherscan.io site, in the "Internal Txns" tab of your wallet.
*
* ---Referral system:
*   Affiliate program has 3 levels: First level - 3%, second level - 2%, third level - 1%.
*
* Attention! It is not allowed to transfer from exchanges, only from your personal wallet ETH, for which you have private keys.
* 
* More information can be found on the website - http://magic-eth.com/ 
*
* Main contract - Magic. Scroll down to find it.
*/ 



contract InvestorsStorage {
  struct investor {
    uint keyIndex;
    uint value;
    uint paymentTime;
    uint refBonus;
  }
  struct itmap {
    mapping(address => investor) data;
    address[] keys;
  }
  itmap private s;
  address private owner;

  modifier onlyOwner() {
    require(msg.sender == owner, "access denied");
    _;
  }

  constructor() public {
    owner = msg.sender;
    s.keys.length++;
  }

  function insert(address addr, uint value) public onlyOwner returns (bool) {
    uint keyIndex = s.data[addr].keyIndex;
    if (keyIndex != 0) return false;
    s.data[addr].value = value;
    keyIndex = s.keys.length++;
    s.data[addr].keyIndex = keyIndex;
    s.keys[keyIndex] = addr;
    return true;
  }

  function investorFullInfo(address addr) public view returns(uint, uint, uint, uint) {
    return (
      s.data[addr].keyIndex,
      s.data[addr].value,
      s.data[addr].paymentTime,
      s.data[addr].refBonus
    );
  }

  function investorBaseInfo(address addr) public view returns(uint, uint, uint) {
    return (
      s.data[addr].value,
      s.data[addr].paymentTime,
      s.data[addr].refBonus
    );
  }

  function investorShortInfo(address addr) public view returns(uint, uint) {
    return (
      s.data[addr].value,
      s.data[addr].refBonus
    );
  }

  function addRefBonus(address addr, uint refBonus) public onlyOwner returns (bool) {
    if (s.data[addr].keyIndex == 0) return false;
    s.data[addr].refBonus += refBonus;
    return true;
  }

  function addValue(address addr, uint value) public onlyOwner returns (bool) {
    if (s.data[addr].keyIndex == 0) return false;
    s.data[addr].value += value;
    return true;
  }

  function setPaymentTime(address addr, uint paymentTime) public onlyOwner returns (bool) {
    if (s.data[addr].keyIndex == 0) return false;
    s.data[addr].paymentTime = paymentTime;
    return true;
  }

  function setRefBonus(address addr, uint refBonus) public onlyOwner returns (bool) {
    if (s.data[addr].keyIndex == 0) return false;
    s.data[addr].refBonus = refBonus;
    return true;
  }

  function keyFromIndex(uint i) public view returns (address) {
    return s.keys[i];
  }

  function contains(address addr) public view returns (bool) {
    return s.data[addr].keyIndex > 0;
  }

  function size() public view returns (uint) {
    return s.keys.length;
  }

  function iterStart() public pure returns (uint) {
    return 1;
  }
}


library SafeMath {
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

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return c;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}



library Percent {
  // Solidity automatically throws when dividing by 0
  struct percent {
    uint num;
    uint den;
  }
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
    if (b >= a) return 0;
    return a - b;
  }

  function add(percent storage p, uint a) internal view returns (uint) {
    return a + mul(p, a);
  }
}


contract Accessibility {
  enum AccessRank { None, Payout, Paymode, Full }
  mapping(address => AccessRank) internal m_admins;
  modifier onlyAdmin(AccessRank  r) {
    require(
      m_admins[msg.sender] == r || m_admins[msg.sender] == AccessRank.Full,
      "access denied"
    );
    _;
  }
  event LogProvideAccess(address indexed whom, uint when,  AccessRank rank);

  constructor() public {
    m_admins[msg.sender] = AccessRank.Full;
    emit LogProvideAccess(msg.sender, now, AccessRank.Full);
  }

  function provideAccess(address addr, AccessRank rank) public onlyAdmin(AccessRank.Full) {
    require(rank <= AccessRank.Full, "invalid access rank");
    require(m_admins[addr] != AccessRank.Full, "cannot change full access rank");
    if (m_admins[addr] != rank) {
      m_admins[addr] = rank;
      emit LogProvideAccess(addr, now, rank);
    }
  }

  function access(address addr) public view returns(AccessRank rank) {
    rank = m_admins[addr];
  }
}


contract PaymentSystem {
  // https://consensys.github.io/smart-contract-best-practices/recommendations/#favor-pull-over-push-for-external-calls
  enum Paymode { Push, Pull }
  struct PaySys {
    uint latestTime;
    uint latestKeyIndex;
    Paymode mode;
  }
  PaySys internal m_paysys;

  modifier atPaymode(Paymode mode) {
    require(m_paysys.mode == mode, "pay mode does not the same");
    _;
  }
  event LogPaymodeChanged(uint when, Paymode indexed mode);

  function paymode() public view returns(Paymode mode) {
    mode = m_paysys.mode;
  }

  function changePaymode(Paymode mode) internal {
    require(mode <= Paymode.Pull, "invalid pay mode");
    if (mode == m_paysys.mode ) return;
    if (mode == Paymode.Pull) require(m_paysys.latestTime != 0, "cannot set pull pay mode if latest time is 0");
    if (mode == Paymode.Push) m_paysys.latestTime = 0;
    m_paysys.mode = mode;
    emit LogPaymodeChanged(now, m_paysys.mode);
  }
}


library Zero {
  function requireNotZero(uint a) internal pure {
    require(a != 0, "require not zero");
  }

  function requireNotZero(address addr) internal pure {
    require(addr != address(0), "require not zero address");
  }

  function notZero(address addr) internal pure returns(bool) {
    return !(addr == address(0));
  }

  function isZero(address addr) internal pure returns(bool) {
    return addr == address(0);
  }
}


library ToAddress {
  function toAddr(uint source) internal pure returns(address) {
    return address(source);
  }

  function toAddr(bytes source) internal pure returns(address addr) {
    assembly { addr := mload(add(source,0x14)) }
    return addr;
  }
}


contract Magic is Accessibility, PaymentSystem {
  using Percent for Percent.percent;
  using SafeMath for uint;
  using Zero for *;
  using ToAddress for *;

  // investors storage - iterable map;
  InvestorsStorage private m_investors;
  mapping(address => bool) private m_referrals;
  bool private m_nextWave;

  // automatically generates getters
  address public adminAddr;
  address public payerAddr;
  uint public waveStartup;
  uint public investmentsNum;
  uint public constant minInvesment = 30 finney; // 0.03 eth
  uint public constant maxBalance = 333e5 ether; // 33,300,000 eth
  uint public constant pauseOnNextWave = 168 hours;

    //float percents
    Percent.percent private m_dividendsPercent30 = Percent.percent(30, 1000); // 30/1000*100% = 3%
    Percent.percent private m_dividendsPercent35 = Percent.percent(35, 1000); // 35/1000*100% = 3.5%
    Percent.percent private m_dividendsPercent40 = Percent.percent(40, 1000); // 40/1000*100% = 4%
    Percent.percent private m_dividendsPercent45 = Percent.percent(45, 1000); // 45/1000*100% = 4.5%
    Percent.percent private m_dividendsPercent50 = Percent.percent(50, 1000); // 50/1000*100% = 5%
    Percent.percent private m_dividendsPercent55 = Percent.percent(55, 1000); // 55/1000*100% = 5.5%
    Percent.percent private m_dividendsPercent60 = Percent.percent(60, 1000); // 60/1000*100% = 6%


  Percent.percent private m_adminPercent = Percent.percent(15, 100); // 15/100*100% = 15%
  Percent.percent private m_payerPercent = Percent.percent(5, 100); // 5/100*100% = 5%

  Percent.percent private m_refLvlOnePercent = Percent.percent(3, 100); // 3/100*100% = 3%
  Percent.percent private m_refLvlTwoPercent = Percent.percent(2, 100); // 2/100*100% = 2%
  Percent.percent private m_refLvlThreePercent = Percent.percent(1, 100); // 1/100*100% = 1%


  // more events for easy read from blockchain
  event LogNewInvestor(address indexed addr, uint when, uint value);
  event LogNewInvesment(address indexed addr, uint when, uint value);
  event LogNewReferral(address indexed addr, uint when, uint value);
  event LogPayDividends(address indexed addr, uint when, uint value);
  event LogPayReferrerBonus(address indexed addr, uint when, uint value);
  event LogBalanceChanged(uint when, uint balance);
  event LogAdminAddrChanged(address indexed addr, uint when);
  event LogPayerAddrChanged(address indexed addr, uint when);
  event LogNextWave(uint when);

  modifier balanceChanged {
    _;
    emit LogBalanceChanged(now, address(this).balance);
  }

  modifier notOnPause() {
    require(waveStartup+pauseOnNextWave <= now, "pause on next wave not expired");
    _;
  }

  constructor() public {
    adminAddr = msg.sender;
    emit LogAdminAddrChanged(msg.sender, now);

    payerAddr = msg.sender;
    emit LogPayerAddrChanged(msg.sender, now);

    nextWave();
    waveStartup = waveStartup.sub(pauseOnNextWave);
  }

  function() public payable {
    // investor get him dividends
    if (msg.value == 0) {
      getMyDividends();
      return;
    }

    // sender do invest
    address a = msg.data.toAddr();
    address[3] memory refs;
    if (a.notZero()) {
      refs[0] = a;
      doInvest(refs);
    } else {
      doInvest(refs);
    }
  }

  function investorsNumber() public view returns(uint) {
    return m_investors.size()-1;
    // -1 because see InvestorsStorage constructor where keys.length++
  }

  function balanceETH() public view returns(uint) {
    return address(this).balance;
  }


  function payerPercent() public view returns(uint numerator, uint denominator) {
    (numerator, denominator) = (m_payerPercent.num, m_payerPercent.den);
  }
  function dividendsPercent30() public view returns(uint numerator, uint denominator) {
    (numerator, denominator) = (m_dividendsPercent30.num, m_dividendsPercent30.den);
  }
  function dividendsPercent35() public view returns(uint numerator, uint denominator) {
    (numerator, denominator) = (m_dividendsPercent35.num, m_dividendsPercent35.den);
  }
  function dividendsPercent40() public view returns(uint numerator, uint denominator) {
    (numerator, denominator) = (m_dividendsPercent40.num, m_dividendsPercent40.den);
  }
  function dividendsPercent45() public view returns(uint numerator, uint denominator) {
    (numerator, denominator) = (m_dividendsPercent45.num, m_dividendsPercent45.den);
  }
  function dividendsPercent50() public view returns(uint numerator, uint denominator) {
    (numerator, denominator) = (m_dividendsPercent50.num, m_dividendsPercent50.den);
  }
  function dividendsPercent55() public view returns(uint numerator, uint denominator) {
    (numerator, denominator) = (m_dividendsPercent55.num, m_dividendsPercent55.den);
  }
  function dividendsPercent60() public view returns(uint numerator, uint denominator) {
    (numerator, denominator) = (m_dividendsPercent60.num, m_dividendsPercent60.den);
  }
  function adminPercent() public view returns(uint numerator, uint denominator) {
    (numerator, denominator) = (m_adminPercent.num, m_adminPercent.den);
  }
  function referrerLvlOnePercent() public view returns(uint numerator, uint denominator) {
    (numerator, denominator) = (m_refLvlOnePercent.num, m_refLvlOnePercent.den);
  }
  function referrerLvlTwoPercent() public view returns(uint numerator, uint denominator) {
    (numerator, denominator) = (m_refLvlTwoPercent.num, m_refLvlTwoPercent.den);
  }
  function referrerLvlThreePercent() public view returns(uint numerator, uint denominator) {
    (numerator, denominator) = (m_refLvlThreePercent.num, m_refLvlThreePercent.den);
  }

  function investorInfo(address addr) public view returns(uint value, uint paymentTime, uint refBonus, bool isReferral) {
    (value, paymentTime, refBonus) = m_investors.investorBaseInfo(addr);
    isReferral = m_referrals[addr];
  }

  function latestPayout() public view returns(uint timestamp) {
    return m_paysys.latestTime;
  }

  function getMyDividends() public notOnPause atPaymode(Paymode.Pull) balanceChanged {
    // check investor info
    InvestorsStorage.investor memory investor = getMemInvestor(msg.sender);
    require(investor.keyIndex > 0, "sender is not investor");
    if (investor.paymentTime < m_paysys.latestTime) {
      assert(m_investors.setPaymentTime(msg.sender, m_paysys.latestTime));
      investor.paymentTime = m_paysys.latestTime;
    }

    // calculate days after latest payment
    uint256 daysAfter = now.sub(investor.paymentTime).div(24 hours);
    require(daysAfter > 0, "the latest payment was earlier than 24 hours");
    assert(m_investors.setPaymentTime(msg.sender, now));

    uint value = 0;

    if (address(this).balance < 500 ether){
      value = m_dividendsPercent30.mul(investor.value) * daysAfter;
    }
    if (500 ether <= address(this).balance && address(this).balance < 1000 ether){
      value = m_dividendsPercent35.mul(investor.value) * daysAfter;
    }
    if (1000 ether <= address(this).balance && address(this).balance < 2000 ether){
      value = m_dividendsPercent40.mul(investor.value) * daysAfter;
    }
    if (2000 ether <= address(this).balance && address(this).balance < 3000 ether){
      value = m_dividendsPercent45.mul(investor.value) * daysAfter;
    }
    if (3000 ether <= address(this).balance && address(this).balance < 4000 ether){
      value = m_dividendsPercent50.mul(investor.value) * daysAfter;
    }
    if (4000 ether <= address(this).balance && address(this).balance < 5000 ether){
      value = m_dividendsPercent55.mul(investor.value) * daysAfter;
    }
    if (5000 ether <= address(this).balance){
      value = m_dividendsPercent60.mul(investor.value) * daysAfter;
    }

    // check enough eth
    if (address(this).balance < value + investor.refBonus) {
      nextWave();
      return;
    }

    // send dividends and ref bonus
    if (investor.refBonus > 0) {
      assert(m_investors.setRefBonus(msg.sender, 0));
      sendDividendsWithRefBonus(msg.sender, value, investor.refBonus);
    } else {
      sendDividends(msg.sender, value);
    }
  }

  function doInvest(address[3] refs) public payable notOnPause balanceChanged {
    require(msg.value >= minInvesment, "msg.value must be >= minInvesment");
    require(address(this).balance <= maxBalance, "the contract eth balance limit");

    uint value = msg.value;
    // ref system works only once for sender-referral
    if (!m_referrals[msg.sender]) {
      // level 1
      if (notZeroNotSender(refs[0]) && m_investors.contains(refs[0])) {
        uint rewardL1 = m_refLvlOnePercent.mul(value);
        assert(m_investors.addRefBonus(refs[0], rewardL1)); // referrer 1 bonus
        m_referrals[msg.sender] = true;
        value = m_dividendsPercent30.add(value); // referral bonus
        emit LogNewReferral(msg.sender, now, value);
        // level 2
        if (notZeroNotSender(refs[1]) && m_investors.contains(refs[1]) && refs[0] != refs[1]) {
          uint rewardL2 = m_refLvlTwoPercent.mul(value);
          assert(m_investors.addRefBonus(refs[1], rewardL2)); // referrer 2 bonus
          // level 3
          if (notZeroNotSender(refs[2]) && m_investors.contains(refs[2]) && refs[0] != refs[2] && refs[1] != refs[2]) {
            uint rewardL3 = m_refLvlThreePercent.mul(value);
            assert(m_investors.addRefBonus(refs[2], rewardL3)); // referrer 3 bonus
          }
        }
      }
    }

    // commission
    adminAddr.transfer(m_adminPercent.mul(msg.value));
    payerAddr.transfer(m_payerPercent.mul(msg.value));

    // write to investors storage
    if (m_investors.contains(msg.sender)) {
      assert(m_investors.addValue(msg.sender, value));
    } else {
      assert(m_investors.insert(msg.sender, value));
      emit LogNewInvestor(msg.sender, now, value);
    }

    if (m_paysys.mode == Paymode.Pull)
      assert(m_investors.setPaymentTime(msg.sender, now));

    emit LogNewInvesment(msg.sender, now, value);
    investmentsNum++;
  }

  function payout() public notOnPause onlyAdmin(AccessRank.Payout) atPaymode(Paymode.Push) balanceChanged {
    if (m_nextWave) {
      nextWave();
      return;
    }

    // if m_paysys.latestKeyIndex == m_investors.iterStart() then payout NOT in process and we must check latest time of payment.
    if (m_paysys.latestKeyIndex == m_investors.iterStart()) {
      require(now>m_paysys.latestTime+12 hours, "the latest payment was earlier than 12 hours");
      m_paysys.latestTime = now;
    }

    uint i = m_paysys.latestKeyIndex;
    uint value;
    uint refBonus;
    uint size = m_investors.size();
    address investorAddr;

    // gasleft and latest key index  - prevent gas block limit
    for (i; i < size && gasleft() > 50000; i++) {
      investorAddr = m_investors.keyFromIndex(i);
      (value, refBonus) = m_investors.investorShortInfo(investorAddr);
      value = m_dividendsPercent30.mul(value);

      if (address(this).balance < value + refBonus) {
        m_nextWave = true;
        break;
      }

      if (refBonus > 0) {
        require(m_investors.setRefBonus(investorAddr, 0), "internal error");
        sendDividendsWithRefBonus(investorAddr, value, refBonus);
        continue;
      }

      sendDividends(investorAddr, value);
    }

    if (i == size)
      m_paysys.latestKeyIndex = m_investors.iterStart();
    else
      m_paysys.latestKeyIndex = i;
  }

  function setAdminAddr(address addr) public onlyAdmin(AccessRank.Full) {
    addr.requireNotZero();
    if (adminAddr != addr) {
      adminAddr = addr;
      emit LogAdminAddrChanged(addr, now);
    }
  }

  function setPayerAddr(address addr) public onlyAdmin(AccessRank.Full) {
    addr.requireNotZero();
    if (payerAddr != addr) {
      payerAddr = addr;
      emit LogPayerAddrChanged(addr, now);
    }
  }

  function setPullPaymode() public onlyAdmin(AccessRank.Paymode) atPaymode(Paymode.Push) {
    changePaymode(Paymode.Pull);
  }

  function getMemInvestor(address addr) internal view returns(InvestorsStorage.investor) {
    (uint a, uint b, uint c, uint d) = m_investors.investorFullInfo(addr);
    return InvestorsStorage.investor(a, b, c, d);
  }

  function notZeroNotSender(address addr) internal view returns(bool) {
    return addr.notZero() && addr != msg.sender;
  }

  function sendDividends(address addr, uint value) private {
    if (addr.send(value)) emit LogPayDividends(addr, now, value);
  }

  function sendDividendsWithRefBonus(address addr, uint value,  uint refBonus) private {
    if (addr.send(value+refBonus)) {
      emit LogPayDividends(addr, now, value);
      emit LogPayReferrerBonus(addr, now, refBonus);
    }
  }

  function nextWave() private {
    m_investors = new InvestorsStorage();
    changePaymode(Paymode.Push);
    m_paysys.latestKeyIndex = m_investors.iterStart();
    investmentsNum = 0;
    waveStartup = now;
    m_nextWave = false;
    emit LogNextWave(now);
  }
}