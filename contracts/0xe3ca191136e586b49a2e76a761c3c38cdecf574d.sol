/*

DVIP Terms of Service

By purchasing, using, and possessing the DVIP token you agree to be legally bound by these terms, which shall take effect immediately upon receipt of the token.

1. Rights of DVIP holders: Each membership entitles the customer to ZERO transaction fees on all on-chain transfers of DC Assets, and ½ off fees for purchasing and redeeming DC Assets through Crypto Capital. DVIP also entitles the customer to discounts on select future DC services. These discounts only apply to the fees specified on the decentralized capital website. DC is not responsible for any fees charged by third parties including, but not limited to, dapps, exchanges, Crypto Capital, and Coinapult.

2. DVIP membership rights expire on January 1st, 2020.

3. Customers can purchase more than one membership, but only one membership can be active at a time for any one wallet. DVIP can only be purchased in whole number increments. Under no circumstances are members eligible for a refund on the DVIP purchase.

4. DVIP tokens are not equity in Decentralized Capital and do not give holders any power over Decentralized Capital including, but not limited to, shareholder voting, a claim on assets, or input into how Decentralized Capital is governed and managed.

5. Possession of the DVIP token operates as proof of membership, and  DVIP tokens can be transferred to any other wallet on Ethereum. If the DVIP token is transferred to a 3rd party, the membership benefits no longer pertain to the original party. In the event of a transfer, membership benefits will apply only AFTER a 24 hour incubation period; any withdrawal initiated prior to the end of this incubation period will be charged the standard transaction fee. DC reserves the right to adjust the duration of the incubation period; the incubation period will never be more than 7 days.

6. DVIP membership benefits are only available to individual users. Platforms such as exchanges and dapps can hold DVIP, but the transaction fee discounts specified in section 1 will not apply.

7. Membership benefits are executed via the DC smart contract system; the DC membership must be held in the wallet used for DC Asset transactions in order for the discounts to apply. No transaction fees will be waived for members who receive transactions using a wallet that does not hold their DVIP token.

8. In the event of bankruptcy: DVIP is valid until January 1st, 2020. In the event that Decentralized Capital ceases operations, DVIP does not represent any claim on company assets nor does Decentralized Capital have any further commitment to holders of DVIP, such as a refund on the purchase of the DVIP.

9. Future DVIP sales: 2500 DVIP have been created, and 2000 will be sold in the initial membership sale. The remaining 500 memberships will be used for marketing events, both leading up to and after the sale, as well as future sale on the open market to generate further revenue. DC reserves the right to create and sell more DVIP in the future, however the total amount of DVIP is capped at 10,000.

10. Entire Agreement: The foregoing Membership Terms & Conditions contain the entire terms and agreements in connection with Member's participation in the DC service and no representations, inducements, promises or agreement, or otherwise, between DC and the Member not included herein, shall be of any force or effect. If any of the foregoing terms or provisions shall be invalid or unenforceable, the remaining terms and provisions hereof shall not be affected.

11. This agreement shall be governed by and construed under, and the legal relations among the parties hereto shall be determined in accordance with the laws of the United Kingdom of Great Britain and Northern Ireland.

*/

contract DVIP {
  function transfer(address to, uint256 value) returns (bool success);
}

contract Assertive {
  function assert(bool assertion) {
    if (!assertion) throw;
  }
}

contract Math is Assertive {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }
}

contract Owned is Assertive {
  address public owner;
  event SetOwner(address indexed previousOwner, address indexed newOwner);
  function Owned () {
    owner = msg.sender;
  }
  modifier onlyOwner {
    assert(msg.sender == owner);
    _
  }
  function setOwner(address newOwner) onlyOwner {
    SetOwner(owner, newOwner);
    owner = newOwner;
  }
}

contract MembershipVendor is Owned, Math {
  event MembershipPurchase(address indexed from, uint256 indexed amount, uint256 indexed price);
  event PropertySet(address indexed from, bytes32 indexed sig, bytes32 indexed args);
  address public dvipAddress;
  address public beneficiary;
  uint256 public price;
  string public tos;
  string[] public terms;
  function setToS(string _tos) onlyOwner returns (bool success) {
    tos = _tos;
    PropertySet(msg.sender, msg.sig, sha3(tos));
    return true;
  }
  function pushTerm(string term) onlyOwner returns (bool success) {
    terms.push(term);
    PropertySet(msg.sender, msg.sig, sha3(term));
    return true;
  }
  function setTerm(uint256 idx, string term) onlyOwner returns (bool success) {
    terms[idx] = term;
    PropertySet(msg.sender, msg.sig, sha3(idx, term));
    return true;
  }
  function setBeneficiary(address addr) onlyOwner returns (bool success) {
    beneficiary = addr;
    PropertySet(msg.sender, msg.sig, bytes32(addr));
    return true;
  }
  function withdraw(address addr, uint256 amt) onlyOwner returns (bool success) {
    if (!addr.send(amt)) throw;
    return true;
  }
  function setDVIP(address addr) onlyOwner returns (bool success) {
    dvipAddress = addr;
    PropertySet(msg.sender, msg.sig, bytes32(addr));
    return true;
  }
  function setPrice(uint256 _price) onlyOwner returns (bool success) {
    price = _price;
    PropertySet(msg.sender, msg.sig, bytes32(_price));
    return true;
  }
  function () {
    if (msg.value < price) throw;
    uint256 qty = msg.value / price;
    uint256 val = safeMul(price, qty);
    if (!DVIP(dvipAddress).transfer(msg.sender, qty)) throw;
    if (msg.value > val && !msg.sender.send(safeSub(msg.value, val))) throw;
    if (beneficiary != address(0x0) && !beneficiary.send(val)) throw;
  }
}