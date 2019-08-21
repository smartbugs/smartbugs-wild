pragma solidity ^0.4.15;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract RNTMultiSigWallet {
    /*
     *  Events
     */
    event Confirmation(address indexed sender, uint indexed transactionId);

    event Revocation(address indexed sender, uint indexed transactionId);

    event Submission(uint indexed transactionId);

    event Execution(uint indexed transactionId);

    event ExecutionFailure(uint indexed transactionId);

    event Deposit(address indexed sender, uint value);

    event OwnerAddition(address indexed owner);

    event OwnerRemoval(address indexed owner);

    event RequirementChange(uint required);

    event Pause();

    event Unpause();

    /*
     *  Constants
     */
    uint constant public MAX_OWNER_COUNT = 10;

    uint constant public ADMINS_COUNT = 2;

    /*
     *  Storage
     */
    mapping (uint => WalletTransaction) public transactions;

    mapping (uint => mapping (address => bool)) public confirmations;

    mapping (address => bool) public isOwner;

    mapping (address => bool) public isAdmin;

    address[] public owners;

    address[] public admins;

    uint public required;

    uint public transactionCount;

    bool public paused = false;

    struct WalletTransaction {
    address sender;
    address destination;
    uint value;
    bytes data;
    bool executed;
    }

    /*
     *  Modifiers
     */

    /// @dev Modifier to make a function callable only when the contract is not paused.
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /// @dev Modifier to make a function callable only when the contract is paused.
    modifier whenPaused() {
        require(paused);
        _;
    }

    modifier onlyWallet() {
        require(msg.sender == address(this));
        _;
    }

    modifier ownerDoesNotExist(address owner) {
        require(!isOwner[owner]);
        _;
    }

    modifier ownerExists(address owner) {
        require(isOwner[owner]);
        _;
    }

    modifier adminExists(address admin) {
        require(isAdmin[admin]);
        _;
    }

    modifier adminDoesNotExist(address admin) {
        require(!isAdmin[admin]);
        _;
    }

    modifier transactionExists(uint transactionId) {
        require(transactions[transactionId].destination != 0);
        _;
    }

    modifier confirmed(uint transactionId, address owner) {
        require(confirmations[transactionId][owner]);
        _;
    }

    modifier notConfirmed(uint transactionId, address owner) {
        require(!confirmations[transactionId][owner]);
        _;
    }

    modifier notExecuted(uint transactionId) {
        if (transactions[transactionId].executed)
        require(false);
        _;
    }

    modifier notNull(address _address) {
        require(_address != 0);
        _;
    }

    modifier validRequirement(uint ownerCount, uint _required) {
        if (ownerCount > MAX_OWNER_COUNT
        || _required > ownerCount
        || _required == 0
        || ownerCount == 0) {
            require(false);
        }
        _;
    }

    modifier validAdminsCount(uint adminsCount) {
        require(adminsCount == ADMINS_COUNT);
        _;
    }

    /// @dev Fallback function allows to deposit ether.
    function()
    whenNotPaused
    payable
    {
        if (msg.value > 0)
        Deposit(msg.sender, msg.value);
    }

    /*
     * Public functions
     */
    /// @dev Contract constructor sets initial admins and required number of confirmations.
    /// @param _admins List of initial owners.
    /// @param _required Number of required confirmations.
    function RNTMultiSigWallet(address[] _admins, uint _required)
    public
        //    validAdminsCount(_admins.length)
        //    validRequirement(_admins.length, _required)
    {
        for (uint i = 0; i < _admins.length; i++) {
            require(_admins[i] != 0 && !isOwner[_admins[i]] && !isAdmin[_admins[i]]);
            isAdmin[_admins[i]] = true;
            isOwner[_admins[i]] = true;
        }

        admins = _admins;
        owners = _admins;
        required = _required;
    }

    /// @dev called by the owner to pause, triggers stopped state
    function pause() adminExists(msg.sender) whenNotPaused public {
        paused = true;
        Pause();
    }

    /// @dev called by the owner to unpause, returns to normal state
    function unpause() adminExists(msg.sender) whenPaused public {
        paused = false;
        Unpause();
    }

    /// @dev Allows to add a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of new owner.
    function addOwner(address owner)
    public
    whenNotPaused
    adminExists(msg.sender)
    ownerDoesNotExist(owner)
    notNull(owner)
    validRequirement(owners.length + 1, required)
    {
        isOwner[owner] = true;
        owners.push(owner);
        OwnerAddition(owner);
    }

    /// @dev Allows to remove an owner. Transaction has to be sent by wallet.
    /// @param owner Address of owner.
    function removeOwner(address owner)
    public
    whenNotPaused
    adminExists(msg.sender)
    adminDoesNotExist(owner)
    ownerExists(owner)
    {
        isOwner[owner] = false;
        for (uint i = 0; i < owners.length - 1; i++)
        if (owners[i] == owner) {
            owners[i] = owners[owners.length - 1];
            break;
        }
        owners.length -= 1;
        if (required > owners.length)
        changeRequirement(owners.length);
        OwnerRemoval(owner);
    }

    /// @dev Allows to replace an owner with a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of owner to be replaced.
    /// @param newOwner Address of new owner.
    function replaceOwner(address owner, address newOwner)
    public
    whenNotPaused
    adminExists(msg.sender)
    adminDoesNotExist(owner)
    ownerExists(owner)
    ownerDoesNotExist(newOwner)
    {
        for (uint i = 0; i < owners.length; i++)
        if (owners[i] == owner) {
            owners[i] = newOwner;
            break;
        }
        isOwner[owner] = false;
        isOwner[newOwner] = true;
        OwnerRemoval(owner);
        OwnerAddition(newOwner);
    }

    /// @dev Allows to change the number of required confirmations. Transaction has to be sent by wallet.
    /// @param _required Number of required confirmations.
    function changeRequirement(uint _required)
    public
    whenNotPaused
    adminExists(msg.sender)
    validRequirement(owners.length, _required)
    {
        required = _required;
        RequirementChange(_required);
    }

    /// @dev Allows an owner to submit and confirm a transaction.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @return Returns transaction ID.
    function submitTransaction(address destination, uint value, bytes data)
    public
    whenNotPaused
    ownerExists(msg.sender)
    returns (uint transactionId)
    {
        transactionId = addTransaction(destination, value, data);
        confirmTransaction(transactionId);
    }

    /// @dev Allows an owner to confirm a transaction.
    /// @param transactionId Transaction ID.
    function confirmTransaction(uint transactionId)
    public
    whenNotPaused
    ownerExists(msg.sender)
    transactionExists(transactionId)
    notConfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId][msg.sender] = true;
        Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    /// @dev Allows an owner to revoke a confirmation for a transaction.
    /// @param transactionId Transaction ID.
    function revokeConfirmation(uint transactionId)
    public
    whenNotPaused
    ownerExists(msg.sender)
    confirmed(transactionId, msg.sender)
    notExecuted(transactionId)
    {
        confirmations[transactionId][msg.sender] = false;
        Revocation(msg.sender, transactionId);
    }

    /// @dev Allows anyone to execute a confirmed transaction.
    /// @param transactionId Transaction ID.
    function executeTransaction(uint transactionId)
    public
    whenNotPaused
    ownerExists(msg.sender)
    confirmed(transactionId, msg.sender)
    notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            WalletTransaction storage walletTransaction = transactions[transactionId];
            walletTransaction.executed = true;
            if (walletTransaction.destination.call.value(walletTransaction.value)(walletTransaction.data))
            Execution(transactionId);
            else {
                ExecutionFailure(transactionId);
                walletTransaction.executed = false;
            }
        }
    }

    /// @dev Returns the confirmation status of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Confirmation status.
    function isConfirmed(uint transactionId)
    public
    constant
    returns (bool)
    {
        uint count = 0;
        for (uint i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
            count += 1;
            if (count == required)
            return true;
        }
    }

    /*
     * Internal functions
     */
    /// @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @return Returns transaction ID.
    function addTransaction(address destination, uint value, bytes data)
    internal
    notNull(destination)
    returns (uint transactionId)
    {
        transactionId = transactionCount;
        transactions[transactionId] = WalletTransaction({
        sender : msg.sender,
        destination : destination,
        value : value,
        data : data,
        executed : false
        });
        transactionCount += 1;
        Submission(transactionId);
    }

    /*
     * Web3 call functions
     */
    /// @dev Returns number of confirmations of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Number of confirmations.
    function getConfirmationCount(uint transactionId)
    public
    constant
    returns (uint count)
    {
        for (uint i = 0; i < owners.length; i++)
        if (confirmations[transactionId][owners[i]])
        count += 1;
    }

    /// @dev Returns total number of transactions after filers are applied.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return Total number of transactions after filters are applied.
    function getTransactionCount(bool pending, bool executed)
    public
    constant
    returns (uint count)
    {
        for (uint i = 0; i < transactionCount; i++)
        if (pending && !transactions[i].executed
        || executed && transactions[i].executed)
        count += 1;
    }

    /// @dev Returns list of owners.
    /// @return List of owner addresses.
    function getOwners()
    public
    constant
    returns (address[])
    {
        return owners;
    }

    // @dev Returns list of admins.
    // @return List of admin addresses
    function getAdmins()
    public
    constant
    returns (address[])
    {
        return admins;
    }

    /// @dev Returns array with owner addresses, which confirmed transaction.
    /// @param transactionId Transaction ID.
    /// @return Returns array of owner addresses.
    function getConfirmations(uint transactionId)
    public
    constant
    returns (address[] _confirmations)
    {
        address[] memory confirmationsTemp = new address[](owners.length);
        uint count = 0;
        uint i;
        for (i = 0; i < owners.length; i++)
        if (confirmations[transactionId][owners[i]]) {
            confirmationsTemp[count] = owners[i];
            count += 1;
        }
        _confirmations = new address[](count);
        for (i = 0; i < count; i++)
        _confirmations[i] = confirmationsTemp[i];
    }

    /// @dev Returns list of transaction IDs in defined range.
    /// @param from Index start position of transaction array.
    /// @param to Index end position of transaction array.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return Returns array of transaction IDs.
    function getTransactionIds(uint from, uint to, bool pending, bool executed)
    public
    constant
    returns (uint[] _transactionIds)
    {
        uint[] memory transactionIdsTemp = new uint[](transactionCount);
        uint count = 0;
        uint i;
        for (i = 0; i < transactionCount; i++)
        if (pending && !transactions[i].executed
        || executed && transactions[i].executed)
        {
            transactionIdsTemp[count] = i;
            count += 1;
        }
        _transactionIds = new uint[](to - from);
        for (i = from; i < to; i++)
        _transactionIds[i - from] = transactionIdsTemp[i];
    }
}

contract RntPresaleEthereumDeposit is Pausable {
    using SafeMath for uint256;

    uint256 public overallTakenEther = 0;

    mapping (address => uint256) public receivedEther;

    struct Donator {
        address addr;
        uint256 donated;
    }

    Donator[] donators;

    RNTMultiSigWallet public wallet;

    function RntPresaleEthereumDeposit(address _walletAddress) {
        wallet = RNTMultiSigWallet(_walletAddress);
    }

    function updateDonator(address _address) internal {
        bool isFound = false;
        for (uint i = 0; i < donators.length; i++) {
            if (donators[i].addr == _address) {
                donators[i].donated =  receivedEther[_address];
                isFound = true;
                break;
            }
        }
        if (!isFound) {
            donators.push(Donator(_address, receivedEther[_address]));
        }
    }

    function getDonatorsNumber() external constant returns(uint256) {
        return donators.length;
    }

    function getDonator(uint pos) external constant returns(address, uint256) {
        return (donators[pos].addr, donators[pos].donated);
    }

    /*
     * Fallback function for sending ether to wallet and update donators info
     */
    function() whenNotPaused payable {
        wallet.transfer(msg.value);

        overallTakenEther = overallTakenEther.add(msg.value);
        receivedEther[msg.sender] = receivedEther[msg.sender].add(msg.value);

        updateDonator(msg.sender);
    }

    function receivedEtherFrom(address _from) whenNotPaused constant public returns(uint256) {
        return receivedEther[_from];
    }

    function myEther() whenNotPaused constant public returns(uint256) {
        return receivedEther[msg.sender];
    }
}