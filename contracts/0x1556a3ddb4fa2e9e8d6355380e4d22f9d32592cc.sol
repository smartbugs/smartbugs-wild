/*
 * Safe Math Smart Contract.
 * Author: Mikhail Vladimirov <mikhail.vladimirov@gmail.com>
 */
pragma solidity ^0.4.16;

/**
 * Provides methods to safely add, subtract and multiply uint256 numbers.
 */
contract SafeMath {
  uint256 constant private MAX_UINT256 =
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

  /**
   * Add two uint256 values, throw in case of overflow.
   *
   * @param x first value to add
   * @param y second value to add
   * @return x + y
   */
  function safeAdd (uint256 x, uint256 y)
  constant internal
  returns (uint256 z) {
    assert (x <= MAX_UINT256 - y);
    return x + y;
  }

  /**
   * Subtract one uint256 value from another, throw in case of underflow.
   *
   * @param x value to subtract from
   * @param y value to subtract
   * @return x - y
   */
  function safeSub (uint256 x, uint256 y)
  constant internal
  returns (uint256 z) {
    assert (x >= y);
    return x - y;
  }

  /**
   * Multiply two uint256 values, throw in case of overflow.
   *
   * @param x first value to multiply
   * @param y second value to multiply
   * @return x * y
   */
  function safeMul (uint256 x, uint256 y)
  constant internal
  returns (uint256 z) {
    if (y == 0) return 0; // Prevent division by zero at the next line
    assert (x <= MAX_UINT256 / y);
    return x * y;
  }
} 

/*
 * ERC-20 Standard Token Smart Contract Interface.
 * Author: Mikhail Vladimirov <mikhail.vladimirov@gmail.com>
 */
pragma solidity ^0.4.16;

/**
 * ERC-20 standard token interface, as defined
 * <a href="http://github.com/ethereum/EIPs/issues/20">here</a>.
 */
contract Token {
  /**
   * Get total number of tokens in circulation.
   *
   * @return total number of tokens in circulation
   */
  function totalSupply () constant returns (uint256 supply);

  /**
   * Get number of tokens currently belonging to given owner.
   *
   * @param _owner address to get number of tokens currently belonging to the
   *        owner of
   * @return number of tokens currently belonging to the owner of given address
   */
  function balanceOf (address _owner) constant returns (uint256 balance);

  /**
   * Transfer given number of tokens from message sender to given recipient.
   *
   * @param _to address to transfer tokens to the owner of
   * @param _value number of tokens to transfer to the owner of given address
   * @return true if tokens were transferred successfully, false otherwise
   */
  function transfer (address _to, uint256 _value) returns (bool success);

  /**
   * Transfer given number of tokens from given owner to given recipient.
   *
   * @param _from address to transfer tokens from the owner of
   * @param _to address to transfer tokens to the owner of
   * @param _value number of tokens to transfer from given owner to given
   *        recipient
   * @return true if tokens were transferred successfully, false otherwise
   */
  function transferFrom (address _from, address _to, uint256 _value)
  returns (bool success);

  /**
   * Allow given spender to transfer given number of tokens from message sender.
   *
   * @param _spender address to allow the owner of to transfer tokens from
   *        message sender
   * @param _value number of tokens to allow to transfer
   * @return true if token transfer was successfully approved, false otherwise
   */
  function approve (address _spender, uint256 _value) returns (bool success);

  /**
   * Tell how many tokens given spender is currently allowed to transfer from
   * given owner.
   *
   * @param _owner address to get number of tokens allowed to be transferred
   *        from the owner of
   * @param _spender address to get number of tokens allowed to be transferred
   *        by the owner of
   * @return number of tokens given spender is currently allowed to transfer
   *         from given owner
   */
  function allowance (address _owner, address _spender) constant
  returns (uint256 remaining);

  /**
   * Logged when tokens were transferred from one owner to another.
   *
   * @param _from address of the owner, tokens were transferred from
   * @param _to address of the owner, tokens were transferred to
   * @param _value number of tokens transferred
   */
  event Transfer (address indexed _from, address indexed _to, uint256 _value);

  /**
   * Logged when owner approved his tokens to be transferred by some spender.
   *
   * @param _owner owner who approved his tokens to be transferred
   * @param _spender spender who were allowed to transfer the tokens belonging
   *        to the owner
   * @param _value number of tokens belonging to the owner, approved to be
   *        transferred by the spender
   */
  event Approval (
    address indexed _owner, address indexed _spender, uint256 _value);
} 

/*
 * Abstract base contract for Token Smart Contracts that may create snapshots of
 * token holder balances.
 * Author: Mikhail Vladimirov <mikhail.vladimirov@gmail.com>
 */
pragma solidity ^0.4.16;


/**
 * Abstract base contract Token Smart Contracts that support snapshots of token
 * holder balances.
 */
contract AbstractSnapshottableToken is SafeMath, Token {
  /**
   * Maximum number of tokens in circulation (2^256 - 1).
   */
  uint256 constant MAX_TOKENS = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

  /**
   * Maximum value of uint256 type, i.e. 2^256-1.
   */
  uint256 constant MAX_UINT256 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

  /**
   * Maximum value of address represented as uint256, i.e. 2^160-1.
   */
  uint256 constant MAX_ADDRESS = 0x00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

  /**
   * 2^160.
   */
  uint256 constant TWO_160 = 0x00010000000000000000000000000000000000000000;

  /**
   * Create new Abstract Snapshottable Token smart contract.
   */
  function AbstractSnapshottableToken () {
    snapshots.length = 1; // Reserve zero ID.
  }

  /**
   * Get total number of tokens in circulation.
   *
   * @return total number of tokens in circulation
   */
  function totalSupply () constant returns (uint256 supply) {
    return tokensCount;
  }

  /**
   * Get total number of tokens in circulation as is was at the moment when
   * snapshot with given index was created.
   *
   * @param _index index of the snapshot to get total number of tokens in
   *        circulation at the moment of
   * @return total number of tokens in circulation at the moment snapshot with
   *         given index was created
   */
  function totalSupplyAt (uint256 _index) constant returns (uint256 supply) {
    require (_index > 0);
    require (_index < snapshots.length);

    return snapshots [_index].tokensCount;
  }

  /**
   * Get number of tokens currently belonging to the owner of given address.
   *
   * @param _owner address to get number of tokens currently belonging to the
   *        owner of
   * @return number of tokens currently belonging to the owner of given address
   */
  function balanceOf (address _owner) constant returns (uint256 balance) {
    return accounts [_owner].balance;
  }

  /**
   * Get number of tokens owner of the given address had at the moment when
   * snapshot with given index was created.
   *
   * @param _owner address to get number of tokens for the owner of
   * @param _index index of the snapshot to get number of tokens at the time of
   * @return number of tokens owner of the given address had at the moment the
   *         snapshot with given index was created
   */
  function balanceOfAt (address _owner, uint256 _index)
    constant returns (uint256 balance) {
    require (_index > 0);
    require (_index < snapshots.length);

    if (_index > accounts [_owner].lastSnapshotIndex)
      return accounts [_owner].balance;
    else {
      uint8 level = 0;
      while (_index > 0) {
        uint256 v = historicalBalances [_owner][level][_index];
        if (v != 0) return v;

        _index >>= 1;
        level += 1; // Overflow is possible here, but is harmless
      }

      return 0;
    }
  }

  /**
   * Get first address that probably had non-zero token balance at the moment
   * snapshot with given index was created.
   *
   * @param _index index of the snapshot to get first address the probably had
   *        non-zero token balance at the moment of
   * @return flag that tells whether there is at least one address that probably
   *         had non-zero token balance at the moment of snapshot with given
   *         index (hasResult); and the fist address that probably had non-zero
   *         token balance at the moment snapshot with given index was created
   *         or zero if there are no such addresses (result)
   */
  function firstAddressAt (uint256 _index)
    constant returns (bool hasResult, address result) {
    require (_index > 0);
    require (_index < snapshots.length);
    uint256 rawFirstAddress = snapshots [_index].firstAddress;
    hasResult = rawFirstAddress != MAX_UINT256;
    result = hasResult ?
      address (rawFirstAddress & MAX_ADDRESS) :
        0;
  }

  /**
   * Get next address that probably had non-zero token balance at the moment
   * certain snapshot was created.
   *
   * @param _address previous address that probably had non-zero token balance
   *        at the moment of certain snapshot
   * @return flag that tells whether there is next address that probably had
   *         non-zero token balance at the moment of snapshot with given index
   *         (hasResult); and the next address that probably had non-zero
   *         token balance at the moment of snapshot with given index was
   *         created or zero if there are no such addresses (result)
   */
  function nextAddress (address _address)
    constant returns (bool hasResult, address result) {
    uint256 rawNextAddress = nextAddresses [_address];
    require (rawNextAddress != 0);
    hasResult = rawNextAddress != MAX_UINT256;
    result = hasResult ?
      address (rawNextAddress & MAX_ADDRESS) :
        0;
  }

  /**
   * Transfer given number of tokens from message sender to given recipient.
   *
   * @param _to address to transfer tokens to the owner of
   * @param _value number of tokens to transfer to the owner of given address
   * @return true if tokens were transferred successfully, false otherwise
   */
  function transfer (address _to, uint256 _value) returns (bool success) {
    return doTransfer (msg.sender, _to, _value);
  }

  /**
   * Transfer given number of tokens from given owner to given recipient.
   *
   * @param _from address to transfer tokens from the owner of
   * @param _to address to transfer tokens to the owner of
   * @param _value number of tokens to transfer from given owner to given
   *        recipient
   * @return true if tokens were transferred successfully, false otherwise
   */
  function transferFrom (address _from, address _to, uint256 _value)
  returns (bool success) {
    if (_value > approved [_from][msg.sender]) return false;
    else if (doTransfer (_from, _to, _value)) {
      approved [_from][msg.sender] =
        safeSub (approved[_from][msg.sender], _value);
      return true;
    } else return false;
  }

  /**
   * Allow given spender to transfer given number of tokens from message sender.
   *
   * @param _spender address to allow the owner of to transfer tokens from
   *        message sender
   * @param _value number of tokens to allow to transfer
   * @return true if token transfer was successfully approved, false otherwise
   */
  function approve (address _spender, uint256 _value) returns (bool success) {
    approved [msg.sender][_spender] = _value;
    Approval (msg.sender, _spender, _value);
    return true;
  }

  /**
   * Tell how many tokens given spender is currently allowed to transfer from
   * given owner.
   *
   * @param _owner address to get number of tokens allowed to be transferred
   *        from the owner of
   * @param _spender address to get number of tokens allowed to be transferred
   *        by the owner of
   * @return number of tokens given spender is currently allowed to transfer
   *         from given owner
   */
  function allowance (address _owner, address _spender) constant
  returns (uint256 remaining) {
    return approved [_owner][_spender];
  }

  /**
   * Create snapshot of token holder balances.
   *
   * @return index of new created snapshot
   */
  function snapshot () returns (uint256 index) {
    index = snapshots.length++;
    snapshots [index].tokensCount = tokensCount;
    snapshots [index].firstAddress = firstAddress;
    Snapshot (index);
  }

  /**
   * Transfer given number of tokens from the owner of given from address to the
   * owner of given to address.
   *
   * @param _from address to transfer tokens from the owner of
   * @param _to address to transfer tokens to the owner of
   * @param _value number of tokens to transfer
   * @return true if tokens were transferred successfully, false otherwise
   */
  function doTransfer (address _from, address _to, uint256 _value)
    internal returns (bool success) {
    if (_value > accounts [_from].balance) return false;
    else if (_value > 0 && _from != _to) {
      saveAddress (_to);
      updateHistoricalBalances (_from);
      updateHistoricalBalances (_to);
      accounts [_from].balance = safeSub (accounts [_from].balance, _value);
      accounts [_to].balance = safeAdd (accounts [_to].balance, _value);
      Transfer (_from, _to, _value);
      return true;
    } else return true;
  }

  /**
   * Create given number of tokens and give them to message sender.
   *
   * @param _value number of tokens to create
   * @return true on success, false on error
   */
  function doCreateTokens (uint256 _value) internal returns (bool success) {
    if (_value > safeSub (MAX_TOKENS, tokensCount)) return false;
    else if (_value > 0) {
      saveAddress (msg.sender);
      updateHistoricalBalances (msg.sender);
      accounts [msg.sender].balance =
        safeAdd (accounts [msg.sender].balance, _value);
      tokensCount = safeAdd (tokensCount, _value);
      return true;
    } else return true;
  }

  /**
   * Update historical balances for given token owner.
   *
   * @param _owner token owner to update historical balances for
   */
  function updateHistoricalBalances (address _owner) internal {
    uint256 balance = accounts [_owner].balance;
    uint256 nextSnapshotIndex = snapshots.length;
    uint256 lastNextSnapshotIndex =
      safeAdd (accounts [_owner].lastSnapshotIndex, 1);
    if (nextSnapshotIndex > lastNextSnapshotIndex) {
      if (balance > 0) {
        setHistoricalBalance (
          _owner, lastNextSnapshotIndex, nextSnapshotIndex, balance);
      }
      accounts [_owner].lastSnapshotIndex =
        safeSub (nextSnapshotIndex, 1);
    }
  }

  /**
   * Set historical balance for the owner of given address as it was at the
   * moments of snapshots with indexes in given range.
   *
   * @param _owner address to set the historical balance for the owner of
   * @param _from beginning of the snapshot index range (inclusive)
   * @param _to end of the snapshot index range (exclusive)
   * @param _balance value to set balance to
   */
  function setHistoricalBalance (
    address _owner, uint256 _from, uint256 _to, uint256 _balance)
    internal {
    assert (_from > 0);
    assert (_to >= _from);
    assert (_balance > 0);

    uint8 level = 0;
    while (_from < _to) {
      if (_from & 1 == 1) {
        // Overflow is not possible here because _from < _to
        historicalBalances [_owner][level][_from++] = _balance;
      }

      if (_to & 1 == 1) {
        // Underflow is not possible here, because _to & 1 == 1
        historicalBalances [_owner][level][--_to] = _balance;
      }

      _from >>= 1;
      _to >>= 1;
      level += 1; // Even for snapshot index range 1..2^256-1 overflow will
                  // not happen here
    }
  }

  /**
   * Add address to the list of addresses that ever had non-zero token balance.
   *
   * @param _address address to be added to the list of addresses that ever had
   *        non-zero token balance
   */
  function saveAddress (address _address) internal {
    if (nextAddresses [_address] == 0) {
      nextAddresses [_address] = firstAddress;
      firstAddress = TWO_160 | uint256(_address);
    }
  }

  /**
   * Total number of tokens in circulation.
   */
  uint256 tokensCount;

  /**
   * All snapshots ever created.
   */
  SnapshotInfo [] snapshots;

  /**
   * Maps addresses of token owners to states of their accounts.
   */
  mapping (address => Account) accounts;

  /**
   * First address that ever had non-zero token balance plus 2^160, or 2^256-1
   * if there are no such addresses.
   */
  uint256 firstAddress = MAX_UINT256;

  /**
   * Mapping from address that ever had non-zero token balance to the next
   * address that ever had non-zero token balance plus 2^160 or 2^256-1 if there
   * are no more such addresses.
   */
  mapping (address => uint256) nextAddresses;

  /**
   * Historical balances of token owners.  If for some address, level and index,
   * where level >= 0 and index > 0, historicalBalances[address][level][index]
   * is non-zero, then owner of given address had this many tokens at the
   * time moments of snapshots with indexes from (index * 2^level) to
   * ((index + 1) * 2^level - 1) inclusive.
   * For each snapshot, there should be at most one level with non-zero
   * value at corresponding index.
   */
  mapping (address => mapping (uint8 => mapping (uint256 => uint256)))
    historicalBalances;

  /**
   * Maps addresses of token owners to mappings from addresses of spenders to
   * how many tokens belonging to the owner, the spender is currently allowed to
   * transfer.
   */
  mapping (address => mapping (address => uint256)) approved;

  /**
   * Encapsulates information about snapshot.
   */
  struct SnapshotInfo {
    /**
     * Total number of tokens in circulation at the moment of snapshot.
     */
    uint256 tokensCount;

    /**
     * Value of firstAddress field at the moment of snapshot.
     */
    uint256 firstAddress;
  }

  /**
   * Encapsulates information about token owner's balance.
   */
  struct Account {
    /**
     * Number of tokens currently belonging to the token owner.
     */
    uint256 balance;

    /**
     * Index of the last snapshot before the moment historical balances were
     * last updated for this token owner.
     */
    uint256 lastSnapshotIndex;
  }

  /**
   * Logged when new snapshot was created.
   *
   * @param _index index of the new snapshot
   */
  event Snapshot (uint256 indexed _index);
}


/*
 * Standard Snapshottable Token Smart Contract.
 * Author: Mikhail Vladimirov <mikhail.vladimirov@gmail.com>
 */

/**
 * Standard Snapshottable Token Smart Contract.
 */
contract StandardSnapshottableToken is AbstractSnapshottableToken {
  /**
   * Create new Standard Snapshottable Token Smart Contract and make
   * message sender the owner of the smart contract.
   */
  function StandardSnapshottableToken ()
    AbstractSnapshottableToken () {
    owner = msg.sender;
  }

  /**
   * Transfer given number of tokens from message sender to given recipient.
   *
   * @param _to address to transfer tokens to the owner of
   * @param _value number of tokens to transfer to the owner of given address
   * @return true if tokens were transferred successfully, false otherwise
   */
  function transfer (address _to, uint256 _value) returns (bool success) {
    if (frozen) return false;
    else return AbstractSnapshottableToken.transfer (_to, _value);
  }

  /**
   * Transfer given number of tokens from given owner to given recipient.
   *
   * @param _from address to transfer tokens from the owner of
   * @param _to address to transfer tokens to the owner of
   * @param _value number of tokens to transfer from given owner to given
   *        recipient
   * @return true if tokens were transferred successfully, false otherwise
   */
  function transferFrom (address _from, address _to, uint256 _value)
  returns (bool success) {
    if (frozen) return false;
    else
      return AbstractSnapshottableToken.transferFrom (_from, _to, _value);
  }

  /**
   * Create given number of tokens and give them to message sender.  May only be
   * called by the owner of the smart contract.
   *
   * @param _value number of tokens to create
   * @return true on success, false on error
   */
  function createTokens (uint256 _value) returns (bool success) {
    require (msg.sender == owner);

    return doCreateTokens (_value);
  }

  /**
   * Freeze token transfers.  May only be called by the owner of the smart
   * contract.
   */
  function freezeTransfers () {
    require (msg.sender == owner);

    if (!frozen)
    {
      frozen = true;
      Freeze ();
    }
  }

  /**
   * Unfreeze token transfers.  May only be called by the owner of the smart
   * contract.
   */
  function unfreezeTransfers () {
    require (msg.sender == owner);

    if (frozen) {
      frozen = false;
      Unfreeze ();
    }
  }

  /**
   * Set new owner address.  May only be called by the owner of the smart
   * contract.
   *
   * @param _newOwner new owner address
   */
  function setOwner (address _newOwner) {
    require (msg.sender == owner);

    owner = _newOwner;
  }

  /**
   * Owner of this smart contract.
   */
  address owner;

  /**
   * Whether token transfers are currently frozen.
   */
  bool frozen;

  /**
   * Logged when token transfers were frozen.
   */
  event Freeze ();

  /**
   * Logged when token transfers were unfrozen.
   */
  event Unfreeze ();
}


/*
 * Science Blockchain Token Smart Contract.
 * Author: Mikhail Vladimirov <mikhail.vladimirov@gmail.com>
 */

/**
 * Science Blockchain Token Smart Contract.
 */
contract ScienceBlockchainToken is StandardSnapshottableToken {
  /**
   * Create new Science Blockchain Token smart contract and make message sender
   * to be the owner of smart contract and to be a snapshot creator.
   */
  function ScienceBlockchainToken ()
    StandardSnapshottableToken () {
    snapshotCreator = msg.sender;
  }

  /**
   * Create snapshot of token holder balances.
   *
   * @return index of new created snapshot
   */
  function snapshot () returns (uint256 index) {
    require (msg.sender == snapshotCreator);
    return AbstractSnapshottableToken.snapshot ();
  }

  /**
   * Get name of this token.
   *
   * @return name of this token
   */
  function name () constant returns (string result) {
    return "SCIENCE BLOCKCHAIN";
  }

  /**
   * Get symbol of this token.
   *
   * @return symbol of this token
   */
  function symbol () constant returns (string result) {
    return "SCI";
  }

  /**
   * Get number of decimals for this token.
   *
   * @return number of decimals for this token
   */
  function decimals () constant returns (uint8 result) {
    return 0;
  }

  /**
   * Burn given number of tokens belonging to message sender.
   *
   * @param _value number of tokens to burn
   * @return true if tokens were burned successfully, false otherwise
   */
  function burnTokens (uint256 _value) returns (bool success) {
    uint256 balance = accounts [msg.sender].balance;
    if (_value > balance) return false;
    if (_value > 0) {
      updateHistoricalBalances (msg.sender);
      accounts [msg.sender].balance = safeSub (balance, _value);
      tokensCount = safeSub (tokensCount, _value);
      return true;
    }
    return true;
  }

  /**
   * Set new snapshot creator address.
   *
   * @param _snapshotCreator new snapshot creator address
   */
  function setSnapshotCreator (address _snapshotCreator) {
    require (msg.sender == owner);
    snapshotCreator = _snapshotCreator;
  }

  /**
   * Address of snapshot creator, i.e. the one allowed to create snapshots.
   */
  address snapshotCreator;
}