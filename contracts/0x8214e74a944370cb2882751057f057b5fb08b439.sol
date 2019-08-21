pragma solidity 0.4.25;

/** 
* ETH CRYPTOCURRENCY DISTRIBUTION PROJECT
* 
* Web              - https://333eth.io
* 
* Twitter          - https://twitter.com/333eth_io
* 
* Telegram_channel - https://t.me/Ethereum333
* 
* EN  Telegram_chat: https://t.me/Ethereum333_chat_en
* 
* RU  Telegram_chat: https://t.me/Ethereum333_chat_ru
* 
* KOR Telegram_chat: https://t.me/Ethereum333_chat_kor
* 
* Email:             mailto:support(at sign)333eth.io
* 
* 
* 
* AO Rules:
* 
* Shareholders are all participants of 333eth v1, v2 projects without exception
* 
* Received ETH share as follows:
* 
* 97% for losers, in projects 333eth v1, v2 in proportion to their losses
* 
* 3% for winners - the same amount.
* 
* 
* 
* Payment of dividends - every Saturday at 18.00 Moscow time.
* 
* The contract of the JSC prescribed a waiver of ownership. And payments are unchanged.
* 
* The specific amount of payments to each shareholder is determined by the success of the project. Your participation in previous projects determines your % in AO.
*/


library RecipientsStorage {
  struct Storage {
    mapping(address => Recipient) data;
    KeyFlag[] keys;
    uint size;
    uint losersValSum;
    uint winnersNum;
  }

  struct Recipient { 
    uint keyIndex;
    uint value;
    bool isWinner;
  }

  struct KeyFlag { 
    address key; 
    bool deleted;
  }

  function init(Storage storage s) internal {
    s.keys.length++;
  }

  function insert(Storage storage s, address key, uint value, bool isWinner) internal returns (bool) {
    uint keyIndex = s.data[key].keyIndex;
   
    if (!s.data[key].isWinner) {
      s.losersValSum -= s.data[key].value;
    }

    if (!isWinner) {
      s.losersValSum += value;
    }

    if (isWinner && !s.data[key].isWinner) {
      s.winnersNum++;
    }
    s.data[key].value = value;
    s.data[key].isWinner = isWinner;

    if (keyIndex > 0) {
      return true;
    }

    keyIndex = s.keys.length++;
    s.data[key].keyIndex = keyIndex;
    s.keys[keyIndex].key = key;
    s.size++;
    return true;
  }

  function remove(Storage storage s, address key) internal returns (bool) {
    uint keyIndex = s.data[key].keyIndex;
    if (keyIndex == 0) {
      return false;
    }

    if (s.data[key].isWinner) {
      s.winnersNum--;
    } else {
      s.losersValSum -= s.data[key].value;
    }
    
      
    delete s.data[key];
    s.keys[keyIndex].deleted = true;
    s.size--;
    return true;
  }

  function recipient(Storage storage s, address key) internal view returns (Recipient memory r) {
    return Recipient(s.data[key].keyIndex, s.data[key].value, s.data[key].isWinner);
  }
  
  function iterStart(Storage storage s) internal view returns (uint keyIndex) {
    return iterNext(s, 0);
  }

  function iterValid(Storage storage s, uint keyIndex) internal view returns (bool) {
    return keyIndex < s.keys.length;
  }

  function iterNext(Storage storage s, uint keyIndex) internal view returns (uint r_keyIndex) {
    r_keyIndex = keyIndex + 1;
    while (r_keyIndex < s.keys.length && s.keys[r_keyIndex].deleted) {
      r_keyIndex++;
    }
  }

  function iterGet(Storage storage s, uint keyIndex) internal view returns (address key, Recipient storage r) {
    key = s.keys[keyIndex].key;
    r = s.data[key];
  }
}


contract Accessibility {
  enum AccessRank { None, Payout, Manager, Full }
  mapping(address => AccessRank) internal m_admins;
  modifier onlyAdmin(AccessRank  r) {
    require(
      m_admins[msg.sender] == r || m_admins[msg.sender] == AccessRank.Full,
      "access denied"
    );
    _;
  }
  event LogProvideAccess(address indexed whom, AccessRank rank, uint when);

  constructor() public {
    m_admins[msg.sender] = AccessRank.Full;
    emit LogProvideAccess(msg.sender, AccessRank.Full, now);
  }
  
  function provideAccess(address addr, AccessRank rank) public onlyAdmin(AccessRank.Manager) {
    require(rank <= AccessRank.Manager, "cannot to give full access rank");
    if (m_admins[addr] != rank) {
      m_admins[addr] = rank;
      emit LogProvideAccess(addr, rank, now);
    }
  }

  function access(address addr) public view returns(AccessRank rank) {
    rank = m_admins[addr];
  }
}


library Percent {
  // Solidity automatically throws when dividing by 0
  struct percent {
    uint num;
    uint den;
  }
  // storage operations
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
    if (b >= a) return 0; // solium-disable-line lbrace
    return a - b;
  }

  function add(percent storage p, uint a) internal view returns (uint) {
    return a + mul(p, a);
  }

  // memory operations
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
    if (b >= a) return 0; // solium-disable-line lbrace
    return a - b;
  }

  function madd(percent memory p, uint a) internal pure returns (uint) {
    return a + mmul(p, a);
  }
}


contract AO is Accessibility {
  using Percent for Percent.percent;
  using RecipientsStorage for RecipientsStorage.Storage;
  
  uint public payPaymentTime;
  uint public payKeyIndex;
  uint public payValue;

  RecipientsStorage.Storage private m_recipients;
  Percent.percent private m_winnersPercent = Percent.percent(3, 100);
  Percent.percent private m_losersPercent = Percent.percent(97, 100);

  event LogPayDividends(address indexed addr, uint dividends, bool isWinner, uint when);
  event LogInsertRecipient(address indexed addr, uint value, bool isWinner, uint when);
  event LogRemoveRecipient(address indexed addr, uint when);

  constructor() public {
    m_recipients.init();
    payKeyIndex = m_recipients.iterStart();
  }

  function() external payable {}

  function payoutIsDone() public view returns(bool done) {
    return payKeyIndex == m_recipients.iterStart();
  }

  function losersValueSum() public view returns(uint sum) {
    return m_recipients.losersValSum;
  }

  function winnersNumber() public view returns(uint number) {
    return m_recipients.winnersNum;
  }

  function recipient(address addr) public view returns(uint value, bool isWinner, uint numerator, uint denominator) {
    RecipientsStorage.Recipient memory r = m_recipients.recipient(addr);
    (value, isWinner) = (r.value, r.isWinner);

    if (r.isWinner) {
      numerator = m_winnersPercent.num;
      denominator = m_winnersPercent.den * m_recipients.winnersNum;
    } else {
      numerator = m_losersPercent.num * r.value;
      denominator = m_losersPercent.den * m_recipients.losersValSum;
    }
  }

  function recipientsSize() public view returns(uint size) {
    return m_recipients.size;
  }

  function recipients() public view returns(address[] memory addrs, uint[] memory values, bool[] memory isWinners) {
    addrs = new address[](m_recipients.size);
    values = new uint[](m_recipients.size);
    isWinners = new bool[](m_recipients.size);
    RecipientsStorage.Recipient memory r;
    uint i = m_recipients.iterStart();
    uint c;

    for (i; m_recipients.iterValid(i); i = m_recipients.iterNext(i)) {
      (addrs[c], r) = m_recipients.iterGet(i);
      values[c] = r.value;
      isWinners[c] = r.isWinner;
      c++;
    }
  }

  function insertRecipients(address[] memory addrs, uint[] memory values, bool[] memory isWinners) public onlyAdmin(AccessRank.Full) {
    require(addrs.length == values.length && values.length == isWinners.length, "invalid arguments length");
    for (uint i; i < addrs.length; i++) {
      if (addrs[i] == address(0x0)) {
        continue;
      }
      if (m_recipients.insert(addrs[i], values[i], isWinners[i])) {
        emit LogInsertRecipient(addrs[i], values[i], isWinners[i], now);
      }
    }
  }

  function removeRecipients(address[] memory addrs) public onlyAdmin(AccessRank.Full) {
    for (uint i; i < addrs.length; i++) {
      if (m_recipients.remove(addrs[i])) {
        emit LogRemoveRecipient(addrs[i], now);
      }
    }
  }

  function payout() public onlyAdmin(AccessRank.Payout) { 
    if (payKeyIndex == m_recipients.iterStart()) {
      require(address(this).balance > 0, "zero balance");
      require(now > payPaymentTime + 12 hours, "the latest payment was earlier than 12 hours");
      payPaymentTime = now;
      payValue = address(this).balance;
    }

    uint dividends;
    uint i = payKeyIndex;
    uint valueForWinner = m_winnersPercent.mul(payValue) / m_recipients.winnersNum;
    uint valueForLosers = m_losersPercent.mul(payValue);
    RecipientsStorage.Recipient memory r;
    address rAddr;

    for (i; m_recipients.iterValid(i) && gasleft() > 60000; i = m_recipients.iterNext(i)) {
      (rAddr, r) = m_recipients.iterGet(i);
      if (r.isWinner) {
        dividends = valueForWinner;
      } else {
        dividends = valueForLosers * r.value / m_recipients.losersValSum;
      }
      if (rAddr.send(dividends)) {
        emit LogPayDividends(rAddr, dividends, r.isWinner, now);
      }
    }

    if (m_recipients.iterValid(i)) {
      payKeyIndex = i;
    } else {
      payKeyIndex = m_recipients.iterStart();
    }
  }
}