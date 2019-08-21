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
*/



library RecipientsStorage {
  struct Storage {
    mapping(address => Recipient) data;
    KeyFlag[] keys;
    uint size;
  }

  struct Recipient { 
    uint keyIndex;
    Percent.percent percent;
    bool isLocked;
  }

  struct KeyFlag { 
    address key; 
    bool deleted;
  }

  function init(Storage storage s) internal {
    s.keys.length++;
  }

  function insert(Storage storage s, address key, Percent.percent memory percent, bool isLocked) internal returns (bool) {
    if (s.data[key].isLocked) {
      return false;
    }

    uint keyIndex = s.data[key].keyIndex;
    s.data[key].percent = percent;
    s.data[key].isLocked = isLocked;
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
    if (s.data[key].isLocked) {
      return false;
    }

    uint keyIndex = s.data[key].keyIndex;
    if (keyIndex == 0) {
      return false;
    }
      
    delete s.data[key];
    s.keys[keyIndex].deleted = true;
    s.size--;
  }

  function unlock(Storage storage s, address key) internal returns (bool) {
    if (s.data[key].keyIndex == 0) {
      return false;
    }
    s.data[key].isLocked = false;
    return true;
  }
  

  function recipient(Storage storage s, address key) internal view returns (Recipient memory r) {
    return Recipient(s.data[key].keyIndex, s.data[key].percent, s.data[key].isLocked);
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

  function iterGet(Storage storage s, uint keyIndex) internal view returns (address key, Recipient memory r) {
    key = s.keys[keyIndex].key;
    r = Recipient(s.data[key].keyIndex, s.data[key].percent, s.data[key].isLocked);
  }
}


contract Accessibility {
  enum AccessRank { None, Payout, Full }
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


contract Distributor is Accessibility {
  using Percent for Percent.percent;
  using RecipientsStorage for RecipientsStorage.Storage;
  RecipientsStorage.Storage private m_recipients;

  uint public startupAO;
  uint public payPaymentTime;
  uint public payKeyIndex;
  uint public payValue;

  event LogPayDividends(address indexed addr, uint when, uint value);

  constructor() public {
    m_recipients.init();
    payKeyIndex = m_recipients.iterStart();
  }

  function() external payable {}


  function payoutIsDone() public view returns(bool done) {
    return payKeyIndex == m_recipients.iterStart();
  }

  function initAO(address AO) public onlyAdmin(AccessRank.Full) {
    require(startupAO == 0, "cannot reinit");
    Percent.percent memory r = Percent.percent(74, 100); // 1% for payout bot
    bool isLocked = true;
    startupAO = now;
    m_recipients.insert(AO, r, isLocked);
  }

  function unlockAO(address AO) public onlyAdmin(AccessRank.Full) {
    require(startupAO > 0, "cannot unlock zero AO");
    require((startupAO + 3 * 365 days) <= now, "cannot unlock if 3 years not pass");
    m_recipients.unlock(AO);
  }

  function recipient(address addr) public view returns(uint numerator, uint denominator, bool isLocked) {
    RecipientsStorage.Recipient memory r = m_recipients.recipient(addr);
    return (r.percent.num, r.percent.den, r.isLocked);
  }

  function recipientsSize() public view returns(uint size) {
    return m_recipients.size;
  }

  function recipients() public view returns(address[] memory addrs, uint[] memory nums, uint[] memory dens, bool[] memory isLockeds) {
    addrs = new address[](m_recipients.size);
    nums = new uint[](m_recipients.size);
    dens = new uint[](m_recipients.size);
    isLockeds = new bool[](m_recipients.size);
    RecipientsStorage.Recipient memory r;
    uint i = m_recipients.iterStart();
    uint c;

    for (i; m_recipients.iterValid(i); i = m_recipients.iterNext(i)) {
      (addrs[c], r) = m_recipients.iterGet(i);
      nums[c] = r.percent.num;
      dens[c] = r.percent.den;
      isLockeds[c] = r.isLocked;
      c++;
    }
  }

  function insertRecipients(address[] memory addrs, uint[] memory nums, uint[] memory dens) public onlyAdmin(AccessRank.Full) {
    require(addrs.length == nums.length && nums.length == dens.length, "invalid arguments length");
    bool isLocked = false;
    for (uint i; i < addrs.length; i++) {
      if (addrs[i] == address(0x0) || dens[i] == 0) {
        continue;
      }
      m_recipients.insert(addrs[i], Percent.percent(nums[i], dens[i]), isLocked);
    }
  }

  function removeRecipients(address[] memory addrs) public onlyAdmin(AccessRank.Full) {
    for (uint i; i < addrs.length; i++) {
      m_recipients.remove(addrs[i]);
    }
  }

  function payout() public onlyAdmin(AccessRank.Payout) { 
    if (payKeyIndex == m_recipients.iterStart()) {
      require(address(this).balance > 0, "zero balance");
      require(now>payPaymentTime+12 hours, "the latest payment was earlier than 12 hours");
      payPaymentTime = now;
      payValue = address(this).balance;
    }
    
    uint i = payKeyIndex;
    uint dividends;
    RecipientsStorage.Recipient memory r;
    address rAddr;

    for (i; m_recipients.iterValid(i) && gasleft() > 60000; i = m_recipients.iterNext(i)) {
      (rAddr, r) = m_recipients.iterGet(i);
      dividends = r.percent.mmul(payValue);
      if (rAddr.send(dividends)) {
        emit LogPayDividends(rAddr, now, dividends); 
      }
    }

    if (m_recipients.iterValid(i)) {
      payKeyIndex = i;
    } else {
      payKeyIndex = m_recipients.iterStart();
    }
  }
}