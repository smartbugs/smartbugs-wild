contract Assertive {
  function assert(bool assertion) {
    if (!assertion) throw;
  }
}

contract TokenRecipient {
  function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData);
}

contract Owned is Assertive {
  address internal owner;
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
  function getOwner() returns (address out) {
    return owner;
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

contract TrustEvents {
  event AuthInit(address indexed from);
  event AuthComplete(address indexed from, address indexed with);
  event AuthPending(address indexed from);
  event Unauthorized(address indexed from);
  event InitCancel(address indexed from);
  event NothingToCancel(address indexed from);
  event SetMasterKey(address indexed from);
  event AuthCancel(address indexed from, address indexed with);
  event NameRegistered(address indexed from, bytes32 indexed name);
}

contract Trust is StateTransferrable, TrustEvents {
  mapping (address => bool) public masterKeys;
  mapping (address => bytes32) public nameRegistry;
  address[] public masterKeyIndex;
  mapping (address => bool) public masterKeyActive;
  mapping (address => bool) public trustedClients;
  mapping (uint256 => address) public functionCalls;
  mapping (address => uint256) public functionCalling;
  function activateMasterKey(address addr) internal {
    if (!masterKeyActive[addr]) {
      masterKeyActive[addr] = true;
      masterKeyIndex.push(addr);
    }
  }
  function setTrustedClient(address addr) onlyOwnerUnlocked setter {
    trustedClients[addr] = true;
  }
  function untrustClient(address addr) multisig(sha3(msg.data)) {
    trustedClients[addr] = false;
  }
  function trustClient(address addr) multisig(sha3(msg.data)) {
    trustedClients[addr] = true;
  }
  function setMasterKey(address addr) onlyOwnerUnlocked {
    assert(!masterKeys[addr]);
    activateMasterKey(addr);
    masterKeys[addr] = true;
    SetMasterKey(msg.sender);
  }
  modifier onlyMasterKey {
    assert(masterKeys[msg.sender]);
    _
  }
  function extractMasterKeyIndexLength() returns (uint256 length) {
    return masterKeyIndex.length;
  }
  function resetAction(uint256 hash) internal {
    address addr = functionCalls[hash];
    functionCalls[hash] = 0x0;
    functionCalling[addr] = 0;
  }
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
  function voteOutMasterKey(address addr) multisig(sha3(msg.data)) {
    assert(masterKeys[addr]);
    masterKeys[addr] = false;
  }
  function voteInMasterKey(address addr) multisig(sha3(msg.data)) {
    assert(!masterKeys[addr]);
    activateMasterKey(addr);
    masterKeys[addr] = true;
  }
  function identify(bytes32 name) onlyMasterKey {
    nameRegistry[msg.sender] = name;
    NameRegistered(msg.sender, name);
  }
  function nameFor(address addr) returns (bytes32 name) {
    return nameRegistry[addr];
  }
}

contract TrustClient is StateTransferrable, TrustEvents {
  address public trustAddress;
  function setTrust(address addr) setter onlyOwnerUnlocked {
    trustAddress = addr;
  }
  function nameFor(address addr) constant returns (bytes32 name) {
    return Trust(trustAddress).nameFor(addr);
  }
  function cancel() returns (uint8 status) {
    assert(trustAddress != address(0x0));
    uint8 code = Trust(trustAddress).authCancel(msg.sender);
    if (code == 0) Unauthorized(msg.sender);
    else if (code == 1) NothingToCancel(msg.sender);
    else if (code == 2) AuthCancel(msg.sender, msg.sender);
    return code;
  }
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
}
contract Relay {
  function relayReceiveApproval(address _caller, address _spender, uint256 _amount, bytes _extraData) returns (bool success);
}
contract TokenBase is Owned {
    bytes32 public standard = 'Token 0.1';
    bytes32 public name;
    bytes32 public symbol;
    uint256 public totalSupply;
    bool public allowTransactions;

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

contract Precision {
  uint8 public decimals;
}
contract Token is TokenBase, Precision {}
contract Util {
  function pow10(uint256 a, uint8 b) internal returns (uint256 result) {
    for (uint8 i = 0; i < b; i++) {
      a *= 10;
    }
    return a;
  }
  function div10(uint256 a, uint8 b) internal returns (uint256 result) {
    for (uint8 i = 0; i < b; i++) {
      a /= 10;
    }
    return a;
  }
  function max(uint256 a, uint256 b) internal returns (uint256 res) {
    if (a >= b) return a;
    return b;
  }
}

/**
 * @title DVIP Contract. DCAsset Membership Token contract.
 *
 * @author Ray Pulver, ray@decentralizedcapital.com
 */
contract DVIP is Token, StateTransferrable, TrustClient, Util {

  uint256 public totalSupply;

  mapping (address => bool) public frozenAccount;

  mapping (address => address[]) public allowanceIndex;
  mapping (address => mapping (address => bool)) public allowanceActive;
  address[] public accountIndex;
  mapping (address => bool) public accountActive;
  address public oversightAddress;
  uint256 public expiry;

  uint256 public treasuryBalance;

  bool public isActive;
  mapping (address => uint256) public exportFee;
  address[] public exportFeeIndex;
  mapping (address => bool) exportFeeActive;

  mapping (address => uint256) public importFee;
  address[] public importFeeIndex;
  mapping (address => bool) importFeeActive;

  event FrozenFunds(address target, bool frozen);
  event PrecisionSet(address indexed from, uint8 precision);
  event TransactionsShutDown(address indexed from);
  event FeeSetup(address indexed from, address indexed target, uint256 amount);


  /**
   * Constructor.
   *
   */
  function DVIP() {
    isActive = true;
    treasuryBalance = 0;
    totalSupply = 0;
    name = "DVIP";
    symbol = "DVIP";
    decimals = 6;
    allowTransactions = true;
    expiry = 1514764800; //1 jan 2018
  }


  /* ---------------  modifiers  --------------*/

  /**
   * Makes sure a method is only called by an overseer.
   */
  modifier onlyOverseer {
    assert(msg.sender == oversightAddress);
    _
  }

  /* ---------------  setter methods, only for the unlocked state --------------*/


  /**
   * Sets the oversight address (not the contract).
   *
   * @param addr The oversight contract address.
   */
  function setOversight(address addr) onlyOwnerUnlocked setter {
    oversightAddress = addr;
  }


  /**
   * Sets the total supply
   *
   * @param total Total supply of the asset.
   */
  function setTotalSupply(uint256 total) onlyOwnerUnlocked setter {
    totalSupply = total;
  }

  /**
   * Set the Token Standard the contract applies to.
   *
   * @param std the Standard.
   */
  function setStandard(bytes32 std) onlyOwnerUnlocked setter {
    standard = std;
  }

  /**
   * Sets the name of the contraxt
   *
   * @param _name the name.
   */
  function setName(bytes32 _name) onlyOwnerUnlocked setter {
    name = _name;
  }

  /**
   * Sets the symbol
   *
   * @param sym The Symbol
   */
  function setSymbol(bytes32 sym) onlyOwnerUnlocked setter {
    symbol = sym;
  }

  /**
   * Sets the precision
   *
   * @param precision Amount of decimals
   */
  function setPrecisionDirect(uint8 precision) onlyOwnerUnlocked {
    decimals = precision;
    PrecisionSet(msg.sender, precision);
  }

  /**
   * Sets the balance of a certain account.
   *
   * @param addr Address of the account
   * @param amount Amount of assets to set on the account
   */
  function setAccountBalance(address addr, uint256 amount) onlyOwnerUnlocked {
    balanceOf[addr] = amount;
    activateAccount(addr);
  }

  /**
   * Sets an allowance from a specific account to a specific account.
   *
   * @param from From-part of the allowance
   * @param to To-part of the allowance
   * @param amount Amount of the allowance
   */
  function setAccountAllowance(address from, address to, uint256 amount) onlyOwnerUnlocked {
    allowance[from][to] = amount;
    activateAllowanceRecord(from, to);
  }

  /**
   * Sets the treasure balance to a certain account.
   *
   * @param amount Amount of assets to pre-set in the treasury
   */
  function setTreasuryBalance(uint256 amount) onlyOwnerUnlocked {
    treasuryBalance = amount;
  }

  /**
   * Sets a certain account on frozen/unfrozen
   *
   * @param addr Account that will be frozen/unfrozen
   * @param frozen Boolean to freeze or unfreeze
   */
  function setAccountFrozenStatus(address addr, bool frozen) onlyOwnerUnlocked {
    activateAccount(addr);
    frozenAccount[addr] = frozen;
  }

  /**
   * Sets up a import fee for a certain address.
   *
   * @param addr Address that will require fee
   * @param fee Amount of fee
   */
  function setupImportFee(address addr, uint256 fee) onlyOwnerUnlocked {
    importFee[addr] = fee;
    activateImportFeeChargeRecord(addr);
    FeeSetup(msg.sender, addr, fee);
  }
 
  /**
   * Sets up a export fee for a certain address.
   *
   * @param addr Address that will require fee
   * @param fee Amount of fee
   */
  function setupExportFee(address addr, uint256 fee) onlyOwnerUnlocked {
    exportFee[addr] = fee;
    activateExportFeeChargeRecord(addr);
    FeeSetup(msg.sender, addr, fee);
  }

  /* ---------------  main token methods  --------------*/


  /**
   * @notice Transfer `_amount` from `msg.sender.address()` to `_to`.
   *
   * @param _to Address that will receive.
   * @param _amount Amount to be transferred.
   */
  function transfer(address _to, uint256 _amount) returns (bool success) {
    assert(allowTransactions);
    assert(!frozenAccount[msg.sender]);
    assert(balanceOf[msg.sender] >= _amount);
    assert(balanceOf[_to] + _amount >= balanceOf[_to]);
    activateAccount(msg.sender);
    activateAccount(_to);
    balanceOf[msg.sender] -= _amount;
    if (_to == address(this)) treasuryBalance += _amount;
    else balanceOf[_to] += _amount;
    Transfer(msg.sender, _to, _amount);
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
    assert(allowTransactions);
    assert(!frozenAccount[msg.sender]);
    assert(!frozenAccount[_from]);
    assert(balanceOf[_from] >= _amount);
    assert(balanceOf[_to] + _amount >= balanceOf[_to]);
    assert(_amount <= allowance[_from][msg.sender]);
    balanceOf[_from] -= _amount;
    balanceOf[_to] += _amount;
    allowance[_from][msg.sender] -= _amount;
    activateAccount(_from);
    activateAccount(_to);
    activateAccount(msg.sender);
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
  function approveAndCall(address _spender, uint256 _amount, bytes _extraData) returns (bool success) {
    assert(allowTransactions);
    assert(!frozenAccount[msg.sender]);
    allowance[msg.sender][_spender] = _amount;
    activateAccount(msg.sender);
    activateAccount(_spender);
    activateAllowanceRecord(msg.sender, _spender);
    TokenRecipient spender = TokenRecipient(_spender);
    spender.receiveApproval(msg.sender, _amount, this, _extraData);
    Approval(msg.sender, _spender, _amount);
    return true;
  }

  /**
   * @notice Approve spender `_spender` to transfer `_amount` from `msg.sender.address()`
   *
   * @param _spender Address that receives the cheque
   * @param _amount Amount on the cheque
   * @return result of the method call
   */
  function approve(address _spender, uint256 _amount) returns (bool success) {
    assert(allowTransactions);
    assert(!frozenAccount[msg.sender]);
    allowance[msg.sender][_spender] = _amount;
    activateAccount(msg.sender);
    activateAccount(_spender);
    activateAllowanceRecord(msg.sender, _spender);
    Approval(msg.sender, _spender, _amount);
    return true;
  }

  /* ---------------  multisig admin methods  --------------*/



  /**
   * @notice Sets the expiry time in milliseconds since 1970.
   *
   * @param ts milliseconds since 1970.
   *
   */
  function setExpiry(uint256 ts) multisig(sha3(msg.data)) {
    expiry = ts;
  }

  /**
   * @notice Mints `mintedAmount` new tokens to the hotwallet `hotWalletAddress`.
   *
   * @param mintedAmount Amount of new tokens to be minted.
   */
  function mint(uint256 mintedAmount) multisig(sha3(msg.data)) {
    treasuryBalance += mintedAmount;
    totalSupply += mintedAmount;
  }

  /**
   * @notice Destroys `destroyAmount` new tokens from the hotwallet `hotWalletAddress`
   *
   * @param destroyAmount Amount of new tokens to be minted.
   */
  function destroyTokens(uint256 destroyAmount) multisig(sha3(msg.data)) {
    assert(treasuryBalance >= destroyAmount);
    treasuryBalance -= destroyAmount;
    totalSupply -= destroyAmount;
  }

  /**
   * @notice Transfers `amount` from the treasury to `to`
   *
   * @param to Address to transfer to
   * @param amount Amount to transfer from treasury
   */
  function transferFromTreasury(address to, uint256 amount) multisig(sha3(msg.data)) {
    assert(treasuryBalance >= amount);
    treasuryBalance -= amount;
    balanceOf[to] += amount;
    activateAccount(to);
  }

  /* ---------------  fee setting administration methods  --------------*/

  /**
   * @notice Sets an import fee of `fee` on address `addr`
   *
   * @param addr Address for which the fee is valid
   * @param addr fee Fee
   *
   */
  function setImportFee(address addr, uint256 fee) multisig(sha3(msg.data)) {
    uint256 max = 1;
    max = pow10(1, decimals);
    assert(fee <= max);
    importFee[addr] = fee;
    activateImportFeeChargeRecord(addr);
  }

  /**
   * @notice Sets an export fee of `fee` on address `addr`
   *
   * @param addr Address for which the fee is valid
   * @param addr fee Fee
   *
   */
  function setExportFee(address addr, uint256 fee) multisig(sha3(msg.data)) {
    uint256 max = 1;
    max = pow10(1, decimals);
    assert(fee <= max);
    exportFee[addr] = fee;
    activateExportFeeChargeRecord(addr);
  }


  /* ---------------  multisig emergency methods --------------*/

  /**
   * @notice Sets allow transactions to `allow`
   *
   * @param allow Allow or disallow transactions
   */
  function voteAllowTransactions(bool allow) multisig(sha3(msg.data)) {
    assert(allow != allowTransactions);
    allowTransactions = allow;
  }

  /**
   * @notice Destructs the contract and sends remaining `this.balance` Ether to `beneficiary`
   *
   * @param beneficiary Beneficiary of remaining Ether on contract
   */
  function voteSuicide(address beneficiary) multisig(sha3(msg.data)) {
    selfdestruct(beneficiary);
  }

  /**
   * @notice Sets frozen to `freeze` for account `target`
   *
   * @param addr Address to be frozen/unfrozen
   * @param freeze Freeze/unfreeze account
   */
  function freezeAccount(address addr, bool freeze) multisig(sha3(msg.data)) {
    frozenAccount[addr] = freeze;
    activateAccount(addr);
  }

  /**
   * @notice Seizes `seizeAmount` of tokens from `address` and transfers it to hotwallet
   *
   * @param addr Adress to seize tokens from
   * @param amount Amount of tokens to seize
   */
  function seizeTokens(address addr, uint256 amount) multisig(sha3(msg.data)) {
    assert(balanceOf[addr] >= amount);
    assert(frozenAccount[addr]);
    activateAccount(addr);
    balanceOf[addr] -= amount;
    treasuryBalance += amount;
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
    uint256 fee = exportFee[from] + importFee[to];
    if (fee == 0) return 0;
    uint256 amountHeld;
    bool discounted = true;
    uint256 oneDVIPUnit;
    if (exportFee[from] == 0 && balanceOf[from] != 0 && now < expiry) {
      amountHeld = balanceOf[from];
    } else if (importFee[to] == 0 && balanceOf[to] != 0 && now < expiry) {
      amountHeld = balanceOf[to];
    } else discounted = false;
    if (discounted) {
      oneDVIPUnit = pow10(1, decimals);
      if (amountHeld > oneDVIPUnit) amountHeld = oneDVIPUnit;
      uint256 remaining = oneDVIPUnit - amountHeld;
      return div10(amount*fee*remaining, decimals*2);
    }
    return div10(amount*fee, decimals);
  }


  /* ---------------  overseer methods for emergency --------------*/

  /**
   * @notice Shuts down all transaction and approval options on the asset contract
   */
  function shutdownTransactions() onlyOverseer {
    allowTransactions = false;
    TransactionsShutDown(msg.sender);
  }

  /* ---------------  helper methods for siphoning --------------*/

  function extractAccountAllowanceRecordLength(address addr) constant returns (uint256 len) {
    return allowanceIndex[addr].length;
  }

  function extractAccountLength() constant returns (uint256 length) {
    return accountIndex.length;
  }

  /* ---------------  private methods --------------*/

  function activateAccount(address addr) internal {
    if (!accountActive[addr]) {
      accountActive[addr] = true;
      accountIndex.push(addr);
    }
  }

  function activateAllowanceRecord(address from, address to) internal {
    if (!allowanceActive[from][to]) {
      allowanceActive[from][to] = true;
      allowanceIndex[from].push(to);
    }
  }

  function activateExportFeeChargeRecord(address addr) internal {
    if (!exportFeeActive[addr]) {
      exportFeeActive[addr] = true;
      exportFeeIndex.push(addr);
    }
  }

  function activateImportFeeChargeRecord(address addr) internal {
    if (!importFeeActive[addr]) {
      importFeeActive[addr] = true;
      importFeeIndex.push(addr);
    }
  }
  function extractImportFeeChargeLength() returns (uint256 length) {
    return importFeeIndex.length;
  }

  function extractExportFeeChargeLength() returns (uint256 length) {
    return exportFeeIndex.length;
  }
}

/**
 * @title DCAssetBackend Contract
 *
 * @author Ray Pulver, ray@decentralizedcapital.com
 */
contract DCAssetBackend is Owned, Precision, StateTransferrable, TrustClient, Util {

  bytes32 public standard = 'Token 0.1';
  bytes32 public name;
  bytes32 public symbol;

  bool public allowTransactions;

  event Approval(address indexed from, address indexed spender, uint256 amount);

  mapping (address => uint256) public balanceOf;
  mapping (address => mapping (address => uint256)) public allowance;

  event Transfer(address indexed from, address indexed to, uint256 value);

  uint256 public totalSupply;

  address public hotWalletAddress;
  address public assetAddress;
  address public oversightAddress;
  address public membershipAddress;

  mapping (address => bool) public frozenAccount;

  mapping (address => address[]) public allowanceIndex;
  mapping (address => mapping (address => bool)) public allowanceActive;
  address[] public accountIndex;
  mapping (address => bool) public accountActive;

  bool public isActive;
  uint256 public treasuryBalance;

  mapping (address => uint256) public feeCharge;
  address[] public feeChargeIndex;
  mapping (address => bool) feeActive;

  event FrozenFunds(address target, bool frozen);
  event PrecisionSet(address indexed from, uint8 precision);
  event TransactionsShutDown(address indexed from);
  event FeeSetup(address indexed from, address indexed target, uint256 amount);


  /**
   * Constructor.
   *
   * @param tokenName Name of the Token
   * @param tokenSymbol The Token Symbol
   */
  function DCAssetBackend(bytes32 tokenSymbol, bytes32 tokenName) {
    isActive = true;
    name = tokenName;
    symbol = tokenSymbol;
    decimals = 6;
    allowTransactions = true;
  }

  /* ---------------  modifiers  --------------*/

  /**
   * Makes sure a method is only called by an overseer.
   */
  modifier onlyOverseer {
    assert(msg.sender == oversightAddress);
    _
  }

  /**
   * Make sure only the front end Asset can call the transfer methods
   */
   modifier onlyAsset {
    assert(msg.sender == assetAddress);
    _
   }

  /* ---------------  setter methods, only for the unlocked state --------------*/


  /**
   * Sets the hot wallet contract address
   *
   * @param addr Address of the Hotwallet
   */
  function setHotWallet(address addr) onlyOwnerUnlocked setter {
    hotWalletAddress = addr;
  }

  /**
    * Sets the token facade contract address
    *
    * @param addr Address of the front-end Asset
    */
  function setAsset(address addr) onlyOwnerUnlocked setter {
    assetAddress = addr;
  }

  /**
   * Sets the membership contract address
   *
   * @param addr Address of the membership contract
   */
  function setMembership(address addr) onlyOwnerUnlocked setter {
    membershipAddress = addr;
  }

  /**
   * Sets the oversight address (not the contract).
   *
   * @param addr The oversight contract address.
   */
  function setOversight(address addr) onlyOwnerUnlocked setter {
    oversightAddress = addr;
  }

  /**
   * Sets the total supply
   *
   * @param total Total supply of the asset.
   */
  function setTotalSupply(uint256 total) onlyOwnerUnlocked setter {
    totalSupply = total;
  }

  /**
   * Set the Token Standard the contract applies to.
   *
   * @param std the Standard.
   */
  function setStandard(bytes32 std) onlyOwnerUnlocked setter {
    standard = std;
  }

  /**
   * Sets the name of the contraxt
   *
   * @param _name the name.
   */
  function setName(bytes32 _name) onlyOwnerUnlocked setter {
    name = _name;
  }

  /**
   * Sets the symbol
   *
   * @param sym The Symbol
   */
  function setSymbol(bytes32 sym) onlyOwnerUnlocked setter {
    symbol = sym;
  }

  /**
   * Sets the precision
   *
   * @param precision Amount of decimals
   */
  function setPrecisionDirect(uint8 precision) onlyOwnerUnlocked {
    decimals = precision;
    PrecisionSet(msg.sender, precision);
  }

  /**
   * Sets the balance of a certain account.
   *
   * @param addr Address of the account
   * @param amount Amount of assets to set on the account
   */
  function setAccountBalance(address addr, uint256 amount) onlyOwnerUnlocked {
    balanceOf[addr] = amount;
    activateAccount(addr);
  }

  /**
   * Sets an allowance from a specific account to a specific account.
   *
   * @param from From-part of the allowance
   * @param to To-part of the allowance
   * @param amount Amount of the allowance
   */
  function setAccountAllowance(address from, address to, uint256 amount) onlyOwnerUnlocked {
    allowance[from][to] = amount;
    activateAllowanceRecord(from, to);
  }

  /**
   * Sets the treasure balance to a certain account.
   *
   * @param amount Amount of assets to pre-set in the treasury
   */
  function setTreasuryBalance(uint256 amount) onlyOwnerUnlocked {
    treasuryBalance = amount;
  }

  /**
   * Sets a certain account on frozen/unfrozen
   *
   * @param addr Account that will be frozen/unfrozen
   * @param frozen Boolean to freeze or unfreeze
   */
  function setAccountFrozenStatus(address addr, bool frozen) onlyOwnerUnlocked {
    activateAccount(addr);
    frozenAccount[addr] = frozen;
  }

  /* ---------------  main token methods  --------------*/


  /**
   * @notice Transfer `_amount` from `_caller` to `_to`.
   *
   * @param _caller Origin address
   * @param _to Address that will receive.
   * @param _amount Amount to be transferred.
   */
  function transfer(address _caller, address _to, uint256 _amount) onlyAsset returns (bool success) {
    assert(allowTransactions);
    assert(!frozenAccount[_caller]);
    assert(balanceOf[_caller] >= _amount);
    assert(balanceOf[_to] + _amount >= balanceOf[_to]);
    activateAccount(_caller);
    activateAccount(_to);
    balanceOf[_caller] -= _amount;
    if (_to == address(this)) treasuryBalance += _amount;
    else {
        uint256 fee = feeFor(_caller, _to, _amount);
        balanceOf[_to] += _amount - fee;
        treasuryBalance += fee;
    }
    Transfer(_caller, _to, _amount);
    return true;
  }

  /**
   * @notice Transfer `_amount` from `_from` to `_to`, invoked by `_caller`.
   *
   * @param _caller Invoker of the call (owner of the allowance)
   * @param _from Origin address
   * @param _to Address that will receive
   * @param _amount Amount to be transferred.
   * @return result of the method call
   */
  function transferFrom(address _caller, address _from, address _to, uint256 _amount) onlyAsset returns (bool success) {
    assert(allowTransactions);
    assert(!frozenAccount[_caller]);
    assert(!frozenAccount[_from]);
    assert(balanceOf[_from] >= _amount);
    assert(balanceOf[_to] + _amount >= balanceOf[_to]);
    assert(_amount <= allowance[_from][_caller]);
    balanceOf[_from] -= _amount;
    uint256 fee = feeFor(_from, _to, _amount);
    balanceOf[_to] += _amount - fee;
    treasuryBalance += fee;
    allowance[_from][_caller] -= _amount;
    activateAccount(_from);
    activateAccount(_to);
    activateAccount(_caller);
    Transfer(_from, _to, _amount);
    return true;
  }

  /**
   * @notice Approve Approves spender `_spender` to transfer `_amount` from `_caller`
   *
   * @param _caller Address that grants the allowance
   * @param _spender Address that receives the cheque
   * @param _amount Amount on the cheque
   * @param _extraData Consequential contract to be executed by spender in same transcation.
   * @return result of the method call
   */
  function approveAndCall(address _caller, address _spender, uint256 _amount, bytes _extraData) onlyAsset returns (bool success) {
    assert(allowTransactions);
    assert(!frozenAccount[_caller]);
    allowance[_caller][_spender] = _amount;
    activateAccount(_caller);
    activateAccount(_spender);
    activateAllowanceRecord(_caller, _spender);
    TokenRecipient spender = TokenRecipient(_spender);
    assert(Relay(assetAddress).relayReceiveApproval(_caller, _spender, _amount, _extraData));
    Approval(_caller, _spender, _amount);
    return true;
  }

  /**
   * @notice Approve Approves spender `_spender` to transfer `_amount` from `_caller`
   *
   * @param _caller Address that grants the allowance
   * @param _spender Address that receives the cheque
   * @param _amount Amount on the cheque
   * @return result of the method call
   */
  function approve(address _caller, address _spender, uint256 _amount) onlyAsset returns (bool success) {
    assert(allowTransactions);
    assert(!frozenAccount[_caller]);
    allowance[_caller][_spender] = _amount;
    activateAccount(_caller);
    activateAccount(_spender);
    activateAllowanceRecord(_caller, _spender);
    Approval(_caller, _spender, _amount);
    return true;
  }

  /* ---------------  multisig admin methods  --------------*/


  /**
   * @notice Mints `mintedAmount` new tokens to the hotwallet `hotWalletAddress`.
   *
   * @param mintedAmount Amount of new tokens to be minted.
   */
  function mint(uint256 mintedAmount) multisig(sha3(msg.data)) {
    activateAccount(hotWalletAddress);
    balanceOf[hotWalletAddress] += mintedAmount;
    totalSupply += mintedAmount;
  }

  /**
   * @notice Destroys `destroyAmount` new tokens from the hotwallet `hotWalletAddress`
   *
   * @param destroyAmount Amount of new tokens to be minted.
   */
  function destroyTokens(uint256 destroyAmount) multisig(sha3(msg.data)) {
    assert(balanceOf[hotWalletAddress] >= destroyAmount);
    activateAccount(hotWalletAddress);
    balanceOf[hotWalletAddress] -= destroyAmount;
    totalSupply -= destroyAmount;
  }

  /**
   * @notice Transfers `amount` from the treasury to `to`
   *
   * @param to Address to transfer to
   * @param amount Amount to transfer from treasury
   */
  function transferFromTreasury(address to, uint256 amount) multisig(sha3(msg.data)) {
    assert(treasuryBalance >= amount);
    treasuryBalance -= amount;
    balanceOf[to] += amount;
    activateAccount(to);
  }

  /* ---------------  multisig emergency methods --------------*/

  /**
   * @notice Sets allow transactions to `allow`
   *
   * @param allow Allow or disallow transactions
   */
  function voteAllowTransactions(bool allow) multisig(sha3(msg.data)) {
    if (allow == allowTransactions) throw;
    allowTransactions = allow;
  }

  /**
   * @notice Destructs the contract and sends remaining `this.balance` Ether to `beneficiary`
   *
   * @param beneficiary Beneficiary of remaining Ether on contract
   */
  function voteSuicide(address beneficiary) multisig(sha3(msg.data)) {
    selfdestruct(beneficiary);
  }

  /**
   * @notice Sets frozen to `freeze` for account `target`
   *
   * @param addr Address to be frozen/unfrozen
   * @param freeze Freeze/unfreeze account
   */
  function freezeAccount(address addr, bool freeze) multisig(sha3(msg.data)) {
    frozenAccount[addr] = freeze;
    activateAccount(addr);
  }

  /**
   * @notice Seizes `seizeAmount` of tokens from `address` and transfers it to hotwallet
   *
   * @param addr Adress to seize tokens from
   * @param amount Amount of tokens to seize
   */
  function seizeTokens(address addr, uint256 amount) multisig(sha3(msg.data)) {
    assert(balanceOf[addr] >= amount);
    assert(frozenAccount[addr]);
    activateAccount(addr);
    balanceOf[addr] -= amount;
    balanceOf[hotWalletAddress] += amount;
  }

  /* ---------------  overseer methods for emergency --------------*/

  /**
   * @notice Shuts down all transaction and approval options on the asset contract
   */
  function shutdownTransactions() onlyOverseer {
    allowTransactions = false;
    TransactionsShutDown(msg.sender);
  }

  /* ---------------  helper methods for siphoning --------------*/

  function extractAccountAllowanceRecordLength(address addr) returns (uint256 len) {
    return allowanceIndex[addr].length;
  }

  function extractAccountLength() returns (uint256 length) {
    return accountIndex.length;
  }


  /* ---------------  private methods --------------*/

  function activateAccount(address addr) internal {
    if (!accountActive[addr]) {
      accountActive[addr] = true;
      accountIndex.push(addr);
    }
  }

  function activateAllowanceRecord(address from, address to) internal {
    if (!allowanceActive[from][to]) {
      allowanceActive[from][to] = true;
      allowanceIndex[from].push(to);
    }
  }
  function feeFor(address a, address b, uint256 amount) returns (uint256 value) {
    if (membershipAddress == address(0x0)) return 0;
    return DVIP(membershipAddress).feeFor(a, b, amount);
  }
}


/**
 * @title DCAssetFacade, Facade for the underlying back-end dcasset token contract. Allow to be updated later.
 *
 * @author P.S.D. Reitsma, peter@decentralizedcapital.com
 *
 */
contract DCAsset is TokenBase, StateTransferrable, TrustClient, Relay {

   address public backendContract;

   /**
    * Constructor
    *
    *
    */
   function DCAsset(address _backendContract) {
     backendContract = _backendContract;
   }

   function standard() constant returns (bytes32 std) {
     return DCAssetBackend(backendContract).standard();
   }

   function name() constant returns (bytes32 nm) {
     return DCAssetBackend(backendContract).name();
   }

   function symbol() constant returns (bytes32 sym) {
     return DCAssetBackend(backendContract).symbol();
   }

   function decimals() constant returns (uint8 precision) {
     return DCAssetBackend(backendContract).decimals();
   }
  
   function allowance(address from, address to) constant returns (uint256 res) {
     return DCAssetBackend(backendContract).allowance(from, to);
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

   /* ---------------  main token methods  --------------*/

   /**
    * @notice Returns the balance of `_address`.
    *
    * @param _address The address of the balance.
    */
   function balanceOf(address _address) constant returns (uint256 balance) {
      return DCAssetBackend(backendContract).balanceOf(_address);
   }

   /**
    * @notice Returns the total supply of the token
    *
    */
   function totalSupply() constant returns (uint256 balance) {
      return DCAssetBackend(backendContract).totalSupply();
   }

  /**
   * @notice Transfer `_amount` to `_to`.
   *
   * @param _to Address that will receive.
   * @param _amount Amount to be transferred.
   */
   function transfer(address _to, uint256 _amount) returns (bool success)  {
      if (!DCAssetBackend(backendContract).transfer(msg.sender, _to, _amount)) throw;
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
      if (!DCAssetBackend(backendContract).approveAndCall(msg.sender, _spender, _amount, _extraData)) throw;
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
      if (!DCAssetBackend(backendContract).approve(msg.sender, _spender, _amount)) throw;
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
      if (!DCAssetBackend(backendContract).transferFrom(msg.sender, _from, _to, _amount)) throw;
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
  function feeFor(address _from, address _to, uint256 _amount) returns (uint256 amount) {
      return DCAssetBackend(backendContract).feeFor(_from, _to, _amount);
  }

  /* ---------------  to be called by backend  --------------*/

  function relayReceiveApproval(address _caller, address _spender, uint256 _amount, bytes _extraData) returns (bool success) {
     assert(msg.sender == backendContract);
     TokenRecipient spender = TokenRecipient(_spender);
     spender.receiveApproval(_caller, _amount, this, _extraData);
     return true;
  }

}