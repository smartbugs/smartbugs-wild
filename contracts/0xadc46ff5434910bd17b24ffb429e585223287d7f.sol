/*

DVIP Terms of Service

The following Terms of Service specify the agreement between Decentralized Capital Ltd. (DC) and the purchaser of DVIP Memberships (customer/member). By purchasing, using, or possessing the DVIP token you agree to be legally bound by these terms, which shall take effect immediately upon purchase of the membership.


1. Rights of DVIP Membership holders: Each membership entitles the customer to ZERO transaction fees on all on-chain transfers of DC Assets, and ½ off fees for purchasing and redeeming DC Assets through Crypto Capital. DVIP also entitles the customer to discounts on select future Decentralized Capital Ltd. services. These discounts only apply to the fees specified on the DC website. DC is not responsible for any fees charged by third parties including, but not limited to, dapps, exchanges, Crypto Capital, and Coinapult.

2. DVIP membership rights expire on January 1st, 2020. Upon expiration of membership benefits, each 1/100th of a token is redeemable for an additional $1.50 in fees on eligible DC products. This additional discount expires on January 1st, 2022.

3. Customers can purchase more than one membership, but only one membership can be active at a time for any one wallet. Under no circumstances are members eligible for a refund on the DVIP purchase.

4. DVIP tokens are not equity in Decentralized Capital ltd. and do not give holders any power over Decentralized Capital ltd. including, but not limited to, shareholder voting, a claim on assets, or input into how Decentralized Capital ltd. is governed and managed.

5. Possession of the DVIP token operates as proof of membership, and DVIP tokens can be transferred to any other wallet on Ethereum. If the DVIP token is transferred to a 3rd party, the membership benefits no longer pertain to the original party. In the event of a transfer, membership benefits will apply only AFTER a one week incubation period; any withdrawal initiated prior to the end of this incubation period will be charged the standard transaction fee. DC reserves the right to adjust the duration of the incubation period; the incubation period will never be more than one month. Changes to the DVIP balance will reset the incubation period for any DVIP that is not fully incubated. Active DVIP is not affected by balance changes.

6. DVIP membership benefits are only available to individual users. Platforms such as exchanges and dapps can hold DVIP, but the transaction fee discounts specified in section 1 will not apply.

7. Membership benefits are executed via the DC smart contract system; the DC membership must be held in the wallet used for DC Asset transactions in order for the discounts to apply. No transaction fees will be waived for members who receive transactions using a wallet that does not hold their DVIP tokens.

8. In the event of bankruptcy: DVIP is valid until January 1st, 2020. In the event that Decentralized Capital Ltd. ceases operations, DVIP does not represent any claim on company assets nor does Decentralized Capital Ltd. have any further commitment to holders of DVIP, such as a refund on the purchase of the DVIP.

9. Future Sale of DVIP: Total DVIP supply is capped at 2,000, 1,500 of which are available for purchase during this initial sale. Any DVIP not sold in the initial membership sale will be destroyed, further reducing the total supply of DVIP. The remaining 500 memberships will be sold at a later date.

10. DVIP Buyback Rights: Decentralized Capital Ltd. reserves the right to repurchase the DVIP from token holders at any time. Repurchase will occur at the average price of all markets where DVIP is listed.

11. Entire Agreement. The foregoing Membership Terms & Conditions contain the entire terms and agreements in connection with Member's participation in the DC service and no representations, inducements, promises or agreement, or otherwise, between DC and the Member not included herein, shall be of any force or effect. If any of the foregoing terms or provisions shall be invalid or unenforceable, the remaining terms and provisions hereof shall not be affected.

12. This agreement shall be governed by and construed under, and the legal relations among the parties hereto shall be determined in accordance with, the laws of the United Kingdom of Great Britain and Northern Ireland.

*/

contract Assertive {
  function assert(bool assertion) {
    if (!assertion) throw;
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

contract StateTransferrable is Owned {
  bool internal locked;
  event Locked(address indexed from);
  event PropertySet(address indexed from);
  modifier onlyIfUnlocked {
    assert(!locked);
    _
  }
  modifier setter {
    _
    PropertySet(msg.sender);
  }
  modifier onlyOwnerUnlocked {
    assert(!locked && msg.sender == owner);
    _
  }
  function lock() onlyOwner onlyIfUnlocked {
    locked = true;
    Locked(msg.sender);
  }
  function isLocked() returns (bool status) {
    return locked;
  }
}

contract TokenRecipient {
  function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData);
}

contract Relay {
  function relayReceiveApproval(address _caller, address _spender, uint256 _amount, bytes _extraData) returns (bool success);
}

contract TokenBase is Owned {
    bytes32 public standard = 'Token 0.1';
    bytes32 public name;
    bytes32 public symbol;
    bool public allowTransactions;
    uint256 public totalSupply;

    event Approval(address indexed from, address indexed spender, uint256 amount);

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);

    function transfer(address _to, uint256 _value) returns (bool success);
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);

    function () {
        throw;
    }
}

contract TrustEvents {
  event AuthInit(address indexed from);
  event AuthComplete(address indexed from, address indexed with);
  event AuthPending(address indexed from);
  event Unauthorized(address indexed from);
  event InitCancel(address indexed from);
  event NothingToCancel(address indexed from);
  event SetMasterKey(address indexed from);
  event AuthCancel(address indexed from, address indexed with);
}

contract Trust is StateTransferrable, TrustEvents {

  mapping (address => bool) public masterKeys;
  mapping (address => bytes32) public nameRegistry;
  address[] public masterKeyIndex;
  mapping (address => bool) public masterKeyActive;
  mapping (address => bool) public trustedClients;
  mapping (uint256 => address) public functionCalls;
  mapping (address => uint256) public functionCalling;

  /* ---------------  modifiers  --------------*/

  modifier multisig (bytes32 hash) {
    if (!masterKeys[msg.sender]) {
      Unauthorized(msg.sender);
    } else if (functionCalling[msg.sender] == 0) {
      if (functionCalls[uint256(hash)] == 0x0) {
        functionCalls[uint256(hash)] = msg.sender;
        functionCalling[msg.sender] = uint256(hash);
        AuthInit(msg.sender);
      } else {
        AuthComplete(functionCalls[uint256(hash)], msg.sender);
        resetAction(uint256(hash));
        _
      }
    } else {
      AuthPending(msg.sender);
    }
  }

  /* ---------------  setter methods, only for the unlocked state --------------*/

  /**
   * @notice Sets a master key
   *
   * @param addr Address
   */
  function setMasterKey(address addr) onlyOwnerUnlocked {
    assert(!masterKeys[addr]);
    activateMasterKey(addr);
    masterKeys[addr] = true;
    SetMasterKey(msg.sender);
  }

  /**
   * @notice Adds a trusted client
   *
   * @param addr Address
   */
  function setTrustedClient(address addr) onlyOwnerUnlocked setter {
    trustedClients[addr] = true;
  }

  /* ---------------  methods to be called by a Master Key  --------------*/



  /* ---------------  multisig admin methods  --------------*/

  /**
   * @notice remove contract `addr` from the list of trusted contracts
   *
   * @param addr Address of client contract to be removed
   */
  function untrustClient(address addr) multisig(sha3(msg.data)) {
    trustedClients[addr] = false;
  }

  /**
   * @notice add contract `addr` to the list of trusted contracts
   *
   * @param addr Address of contract to be added
   */
  function trustClient(address addr) multisig(sha3(msg.data)) {
    trustedClients[addr] = true;
  }

  /**
   * @notice remove key `addr` to the list of master keys
   *
   * @param addr Address of the masterkey
   */
  function voteOutMasterKey(address addr) multisig(sha3(msg.data)) {
    assert(masterKeys[addr]);
    masterKeys[addr] = false;
  }

  /**
   * @notice add key `addr` to the list of master keys
   *
   * @param addr Address of the masterkey
   */
  function voteInMasterKey(address addr) multisig(sha3(msg.data)) {
    assert(!masterKeys[addr]);
    activateMasterKey(addr);
    masterKeys[addr] = true;
  }

  /* ---------------  methods to be called by Trusted Client Contracts  --------------*/


  /**
   * @notice Cancel outstanding multisig method call from address `from`. Called from trusted clients.
   *
   * @param from Address that issued the call that needs to be cancelled
   */
  function authCancel(address from) external returns (uint8 status) {
    if (!masterKeys[from] || !trustedClients[msg.sender]) {
      Unauthorized(from);
      return 0;
    }
    uint256 call = functionCalling[from];
    if (call == 0) {
      NothingToCancel(from);
      return 1;
    } else {
      AuthCancel(from, from);
      functionCalling[from] = 0;
      functionCalls[call] = 0x0;
      return 2;
    }
  }

  /**
   * @notice Authorize multisig call on a trusted client. Called from trusted clients.
   *
   * @param from Address from which call is made.
   * @param hash of method call
   */
  function authCall(address from, bytes32 hash) external returns (uint8 code) {
    if (!masterKeys[from] || !trustedClients[msg.sender]) {
      Unauthorized(from);
      return 0;
    }
    if (functionCalling[from] == 0) {
      if (functionCalls[uint256(hash)] == 0x0) {
        functionCalls[uint256(hash)] = from;
        functionCalling[from] = uint256(hash);
        AuthInit(from);
        return 1;
      } else {
        AuthComplete(functionCalls[uint256(hash)], from);
        resetAction(uint256(hash));
        return 2;
      }
    } else {
      AuthPending(from);
      return 3;
    }
  }

  /* ---------------  methods to be called directly on the contract --------------*/

  /**
   * @notice cancel any outstanding multisig call
   *
   */
  function cancel() returns (uint8 code) {
    if (!masterKeys[msg.sender]) {
      Unauthorized(msg.sender);
      return 0;
    }
    uint256 call = functionCalling[msg.sender];
    if (call == 0) {
      NothingToCancel(msg.sender);
      return 1;
    } else {
      AuthCancel(msg.sender, msg.sender);
      uint256 hash = functionCalling[msg.sender];
      functionCalling[msg.sender] = 0x0;
      functionCalls[hash] = 0;
      return 2;
    }
  }

  /* ---------------  private methods --------------*/

  function resetAction(uint256 hash) internal {
    address addr = functionCalls[hash];
    functionCalls[hash] = 0x0;
    functionCalling[addr] = 0;
  }

  function activateMasterKey(address addr) internal {
    if (!masterKeyActive[addr]) {
      masterKeyActive[addr] = true;
      masterKeyIndex.push(addr);
    }
  }

  /* ---------------  helper methods for siphoning --------------*/

  function extractMasterKeyIndexLength() returns (uint256 length) {
    return masterKeyIndex.length;
  }

}


contract TrustClient is StateTransferrable, TrustEvents {

  address public trustAddress;

  modifier multisig (bytes32 hash) {
    assert(trustAddress != address(0x0));
    address current = Trust(trustAddress).functionCalls(uint256(hash));
    uint8 code = Trust(trustAddress).authCall(msg.sender, hash);
    if (code == 0) Unauthorized(msg.sender);
    else if (code == 1) AuthInit(msg.sender);
    else if (code == 2) {
      AuthComplete(current, msg.sender);
      _
    }
    else if (code == 3) {
      AuthPending(msg.sender);
    }
  }
  
  function setTrust(address addr) setter onlyOwnerUnlocked {
    trustAddress = addr;
  }

  function cancel() returns (uint8 status) {
    assert(trustAddress != address(0x0));
    uint8 code = Trust(trustAddress).authCancel(msg.sender);
    if (code == 0) Unauthorized(msg.sender);
    else if (code == 1) NothingToCancel(msg.sender);
    else if (code == 2) AuthCancel(msg.sender, msg.sender);
    return code;
  }

}

contract DVIPBackend {
  uint8 public decimals;
  function assert(bool assertion) {
    if (!assertion) throw;
  }
  bytes32 public standard = 'Token 0.1';
  bytes32 public name;
  bytes32 public symbol;
  bool public allowTransactions;
  uint256 public totalSupply;

  event Approval(address indexed from, address indexed spender, uint256 amount);
  event PropertySet(address indexed from);

  mapping (address => uint256) public balanceOf;
  mapping (address => mapping (address => uint256)) public allowance;

/*
  mapping (address => bool) public balanceOfActive;
  address[] public balanceOfIndex;
*/

/*
  mapping (address => bool) public allowanceActive;
  address[] public allowanceIndex;

  mapping (address => mapping (address => bool)) public allowanceRecordActive;
  mapping (address => address[]) public allowanceRecordIndex;
*/

  event Transfer(address indexed from, address indexed to, uint256 value);

  uint256 public baseFeeDivisor;
  uint256 public feeDivisor;
  uint256 public singleDVIPQty;

  function () {
    throw;
  }

  bool public locked;
  address public owner;

  modifier onlyOwnerUnlocked {
    assert(msg.sender == owner && !locked);
    _
  }

  modifier onlyOwner {
    assert(msg.sender == owner);
    _
  }

  function lock() onlyOwnerUnlocked returns (bool success) {
    locked = true;
    PropertySet(msg.sender);
    return true;
  }

  function setOwner(address _address) onlyOwner returns (bool success) {
    owner = _address;
    PropertySet(msg.sender);
    return true;
  }

  uint256 public expiry;
  uint8 public feeDecimals;

  struct Validity {
    uint256 last;
    uint256 ts;
  }

  mapping (address => Validity) public validAfter;
  uint256 public mustHoldFor;
  address public hotwalletAddress;
  address public frontendAddress;
  mapping (address => bool) public frozenAccount;
/*
  mapping (address => bool) public frozenAccountActive;
  address[] public frozenAccountIndex;
*/
  mapping (address => uint256) public exportFee;
/*
  mapping (address => bool) public exportFeeActive;
  address[] public exportFeeIndex;
*/

  event FeeSetup(address indexed from, address indexed target, uint256 amount);
  event Processed(address indexed sender);

  modifier onlyAsset {
    if (msg.sender != frontendAddress) throw;
    _
  }

  /**
   * Constructor.
   *
   */
  function DVIPBackend(address _hotwalletAddress, address _frontendAddress) {
    owner = msg.sender;
    hotwalletAddress = _hotwalletAddress;
    frontendAddress = _frontendAddress;
    allowTransactions = true;
    totalSupply = 0;
    name = "DVIP";
    symbol = "DVIP";
    feeDecimals = 6;
    decimals = 1;
    expiry = 1514764800; //1 jan 2018
    mustHoldFor = 604800;
    precalculate();
  }

  function setHotwallet(address _address) onlyOwnerUnlocked {
    hotwalletAddress = _address;
    PropertySet(msg.sender);
  }

  function setFrontend(address _address) onlyOwnerUnlocked {
    frontendAddress = _address;
    PropertySet(msg.sender);
  } 

  /**
   * @notice Transfer `_amount` from `msg.sender.address()` to `_to`.
   *
   * @param _to Address that will receive.
   * @param _amount Amount to be transferred.
   */
  function transfer(address caller, address _to, uint256 _amount) onlyAsset returns (bool success) {
    assert(allowTransactions);
    assert(balanceOf[caller] >= _amount);
    assert(balanceOf[_to] + _amount >= balanceOf[_to]);
    assert(!frozenAccount[caller]);
    assert(!frozenAccount[_to]);
    balanceOf[caller] -= _amount;
    // activateBalance(caller);
    // activateBalance(_to);
    uint256 preBalance = balanceOf[_to];
    balanceOf[_to] += _amount;
    bool alreadyMax = preBalance >= singleDVIPQty;
    if (!alreadyMax) {
      if (now >= validAfter[_to].ts + mustHoldFor) validAfter[_to].last = preBalance;
      validAfter[_to].ts = now;
    }
    if (validAfter[caller].last > balanceOf[caller]) validAfter[caller].last = balanceOf[caller];
    Transfer(caller, _to, _amount);
    return true;
  }

  /**
   * @notice Transfer `_amount` from `_from` to `_to`.
   *
   * @param _from Origin address
   * @param _to Address that will receive
   * @param _amount Amount to be transferred.
   * @return result of the method call
   */
  function transferFrom(address caller, address _from, address _to, uint256 _amount) onlyAsset returns (bool success) {
    assert(allowTransactions);
    assert(balanceOf[_from] >= _amount);
    assert(balanceOf[_to] + _amount >= balanceOf[_to]);
    assert(_amount <= allowance[_from][caller]);
    assert(!frozenAccount[caller]);
    assert(!frozenAccount[_from]);
    assert(!frozenAccount[_to]);
    balanceOf[_from] -= _amount;
    uint256 preBalance = balanceOf[_to];
    balanceOf[_to] += _amount;
    // activateBalance(_from);
    // activateBalance(_to);
    allowance[_from][caller] -= _amount;
    bool alreadyMax = preBalance >= singleDVIPQty;
    if (!alreadyMax) {
      if (now >= validAfter[_to].ts + mustHoldFor) validAfter[_to].last = preBalance;
      validAfter[_to].ts = now;
    }
    if (validAfter[_from].last > balanceOf[_from]) validAfter[_from].last = balanceOf[_from];
    Transfer(_from, _to, _amount);
    return true;
  }

  /**
   * @notice Approve spender `_spender` to transfer `_amount` from `msg.sender.address()`
   *
   * @param _spender Address that receives the cheque
   * @param _amount Amount on the cheque
   * @param _extraData Consequential contract to be executed by spender in same transcation.
   * @return result of the method call
   */
  function approveAndCall(address caller, address _spender, uint256 _amount, bytes _extraData) onlyAsset returns (bool success) {
    assert(allowTransactions);
    allowance[caller][_spender] = _amount;
    // activateAllowance(caller, _spender);
    Relay(frontendAddress).relayReceiveApproval(caller, _spender, _amount, _extraData);
    Approval(caller, _spender, _amount);
    return true;
  }

  /**
   * @notice Approve spender `_spender` to transfer `_amount` from `msg.sender.address()`
   *
   * @param _spender Address that receives the cheque
   * @param _amount Amount on the cheque
   * @return result of the method call
   */
  function approve(address caller, address _spender, uint256 _amount) onlyAsset returns (bool success) {
    assert(allowTransactions);
    allowance[caller][_spender] = _amount;
    // activateAllowance(caller, _spender);
    Approval(caller, _spender, _amount);
    return true;
  }

  /* ---------------  multisig admin methods  --------------*/



  /**
   * @notice Sets the expiry time in milliseconds since 1970.
   *
   * @param ts milliseconds since 1970.
   *
   */
  function setExpiry(uint256 ts) onlyOwner {
    expiry = ts;
    Processed(msg.sender);
  }

  /**
   * @notice Mints `mintedAmount` new tokens to the hotwallet `hotWalletAddress`.
   *
   * @param mintedAmount Amount of new tokens to be minted.
   */
  function mint(uint256 mintedAmount) onlyOwner {
    balanceOf[hotwalletAddress] += mintedAmount;
   // activateBalance(hotwalletAddress);
    totalSupply += mintedAmount;
    Processed(msg.sender);
  }

  function freezeAccount(address target, bool frozen) onlyOwner {
    frozenAccount[target] = frozen;
    // activateFrozenAccount(target);
    Processed(msg.sender);
  }

  function seizeTokens(address target, uint256 amount) onlyOwner {
    assert(balanceOf[target] >= amount);
    assert(frozenAccount[target]);
    balanceOf[target] -= amount;
    balanceOf[hotwalletAddress] += amount;
    Transfer(target, hotwalletAddress, amount);
  }

  function destroyTokens(uint256 amt) onlyOwner {
    assert(balanceOf[hotwalletAddress] >= amt);
    balanceOf[hotwalletAddress] -= amt;
    Processed(msg.sender);
  }

  /**
   * @notice Sets an export fee of `fee` on address `addr`
   *
   * @param addr Address for which the fee is valid
   * @param addr fee Fee
   *
   */
  function setExportFee(address addr, uint256 fee) onlyOwner {
    exportFee[addr] = fee;
   // activateExportFee(addr);
    Processed(msg.sender);
  }

  function setHoldingPeriod(uint256 ts) onlyOwner {
    mustHoldFor = ts;
    Processed(msg.sender);
  }

  function setAllowTransactions(bool allow) onlyOwner {
    allowTransactions = allow;
    Processed(msg.sender);
  }

  /* --------------- fee calculation method ---------------- */

  /**
   * @notice 'Returns the fee for a transfer from `from` to `to` on an amount `amount`.
   *
   * Fee's consist of a possible
   *    - import fee on transfers to an address
   *    - export fee on transfers from an address
   * DVIP ownership on an address
   *    - reduces fee on a transfer from this address to an import fee-ed address
   *    - reduces the fee on a transfer to this address from an export fee-ed address
   * DVIP discount does not work for addresses that have an import fee or export fee set up against them.
   *
   * DVIP discount goes up to 100%
   *
   * @param from From address
   * @param to To address
   * @param amount Amount for which fee needs to be calculated.
   *
   */
  function feeFor(address from, address to, uint256 amount) constant external returns (uint256 value) {
    uint256 fee = exportFee[from];
    if (fee == 0) return 0;
    if (now >= expiry) return amount*fee / baseFeeDivisor;
    uint256 amountHeld;
    if (balanceOf[to] != 0) {
      if (validAfter[to].ts + mustHoldFor < now) amountHeld = balanceOf[to];
      else amountHeld = validAfter[to].last;
      if (amountHeld >= singleDVIPQty) return 0;
      return amount*fee*(singleDVIPQty - amountHeld) / feeDivisor;
    } else return amount*fee / baseFeeDivisor;
  }
  function precalculate() internal returns (bool success) {
    baseFeeDivisor = pow10(1, feeDecimals);
    feeDivisor = pow10(1, feeDecimals + decimals);
    singleDVIPQty = pow10(1, decimals);
  }
  function div10(uint256 a, uint8 b) internal returns (uint256 result) {
    for (uint8 i = 0; i < b; i++) {
      a /= 10;
    }
    return a;
  }
  function pow10(uint256 a, uint8 b) internal returns (uint256 result) {
    for (uint8 i = 0; i < b; i++) {
      a *= 10;
    }
    return a;
  }
  /*
  function activateBalance(address address_) internal {
    if (!balanceOfActive[address_]) {
      balanceOfActive[address_] = true;
      balanceOfIndex.push(address_);
    }
  }
  function activateFrozenAccount(address address_) internal {
    if (!frozenAccountActive[address_]) {
      frozenAccountActive[address_] = true;
      frozenAccountIndex.push(address_);
    }
  }
  function activateAllowance(address from, address to) internal {
    if (!allowanceActive[from]) {
      allowanceActive[from] = true;
      allowanceIndex.push(from);
    }
    if (!allowanceRecordActive[from][to]) {
      allowanceRecordActive[from][to] = true;
      allowanceRecordIndex[from].push(to);
    }
  }
  function activateExportFee(address address_) internal {
    if (!exportFeeActive[address_]) {
      exportFeeActive[address_] = true;
      exportFeeIndex.push(address_);
    }
  }
  function extractBalanceOfLength() constant returns (uint256 length) {
    return balanceOfIndex.length;
  }
  function extractAllowanceLength() constant returns (uint256 length) {
    return allowanceIndex.length;
  }
  function extractAllowanceRecordLength(address from) constant returns (uint256 length) {
    return allowanceRecordIndex[from].length;
  }
  function extractFrozenAccountLength() constant returns (uint256 length) {
    return frozenAccountIndex.length;
  }
  function extractFeeLength() constant returns (uint256 length) {
    return exportFeeIndex.length;
  }
  */
}

/**
 * @title DVIP
 *
 * @author Raymond Pulver IV
 *
 */
contract DVIP is TokenBase, StateTransferrable, TrustClient, Relay {

   address public backendContract;

   /**
    * Constructor
    *
    *
    */
   function DVIP(address _backendContract) {
     backendContract = _backendContract;
   }

   function standard() constant returns (bytes32 std) {
     return DVIPBackend(backendContract).standard();
   }

   function name() constant returns (bytes32 nm) {
     return DVIPBackend(backendContract).name();
   }

   function symbol() constant returns (bytes32 sym) {
     return DVIPBackend(backendContract).symbol();
   }

   function decimals() constant returns (uint8 precision) {
     return DVIPBackend(backendContract).decimals();
   }
  
   function allowance(address from, address to) constant returns (uint256 res) {
     return DVIPBackend(backendContract).allowance(from, to);
   }


   /* ---------------  multisig admin methods  --------------*/


   /**
    * @notice Sets the backend contract to `_backendContract`. Can only be switched by multisig.
    *
    * @param _backendContract Address of the underlying token contract.
    */
   function setBackend(address _backendContract) multisig(sha3(msg.data)) {
     backendContract = _backendContract;
   }
   function setBackendOwner(address _backendContract) onlyOwnerUnlocked {
     backendContract = _backendContract;
   }

   /* ---------------  main token methods  --------------*/

   /**
    * @notice Returns the balance of `_address`.
    *
    * @param _address The address of the balance.
    */
   function balanceOf(address _address) constant returns (uint256 balance) {
      return DVIPBackend(backendContract).balanceOf(_address);
   }

   /**
    * @notice Returns the total supply of the token
    *
    */
   function totalSupply() constant returns (uint256 balance) {
      return DVIPBackend(backendContract).totalSupply();
   }

  /**
   * @notice Transfer `_amount` to `_to`.
   *
   * @param _to Address that will receive.
   * @param _amount Amount to be transferred.
   */
   function transfer(address _to, uint256 _amount) returns (bool success)  {
      if (!DVIPBackend(backendContract).transfer(msg.sender, _to, _amount)) throw;
      Transfer(msg.sender, _to, _amount);
      return true;
   }

  /**
   * @notice Approve Approves spender `_spender` to transfer `_amount`.
   *
   * @param _spender Address that receives the cheque
   * @param _amount Amount on the cheque
   * @param _extraData Consequential contract to be executed by spender in same transcation.
   * @return result of the method call
   */
   function approveAndCall(address _spender, uint256 _amount, bytes _extraData) returns (bool success) {
      if (!DVIPBackend(backendContract).approveAndCall(msg.sender, _spender, _amount, _extraData)) throw;
      Approval(msg.sender, _spender, _amount);
      return true;
   }

  /**
   * @notice Approve Approves spender `_spender` to transfer `_amount`.
   *
   * @param _spender Address that receives the cheque
   * @param _amount Amount on the cheque
   * @return result of the method call
   */
   function approve(address _spender, uint256 _amount) returns (bool success) {
      if (!DVIPBackend(backendContract).approve(msg.sender, _spender, _amount)) throw;
      Approval(msg.sender, _spender, _amount);
      return true;
   }

  /**
   * @notice Transfer `_amount` from `_from` to `_to`.
   *
   * @param _from Origin address
   * @param _to Address that will receive
   * @param _amount Amount to be transferred.
   * @return result of the method call
   */
  function transferFrom(address _from, address _to, uint256 _amount) returns (bool success) {
      if (!DVIPBackend(backendContract).transferFrom(msg.sender, _from, _to, _amount)) throw;
      Transfer(_from, _to, _amount);
      return true;
  }

  /**
   * @notice Returns fee for transferral of `_amount` from `_from` to `_to`.
   *
   * @param _from Origin address
   * @param _to Address that will receive
   * @param _amount Amount to be transferred.
   * @return height of the fee
   */
  function feeFor(address _from, address _to, uint256 _amount) constant returns (uint256 amount) {
      return DVIPBackend(backendContract).feeFor(_from, _to, _amount);
  }

  /* ---------------  to be called by backend  --------------*/

  function relayReceiveApproval(address _caller, address _spender, uint256 _amount, bytes _extraData) returns (bool success) {
     assert(msg.sender == backendContract);
     TokenRecipient spender = TokenRecipient(_spender);
     spender.receiveApproval(_caller, _amount, this, _extraData);
     return true;
  }

}