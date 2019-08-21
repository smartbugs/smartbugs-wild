pragma solidity 0.4.19;

interface token {
    function transfer(address _to, uint256 _value) public;
}
/// @title Multisignature wallet - Allows multiple parties to agree on transactions before execution.
contract MultiSigWallet {
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
    event EthDailyLimitChange(uint limit);
    event MtcDailyLimitChange(uint limit);
    event TokenChange(address _token);
    /*
     *  Constants
     */
    uint constant public MAX_OWNER_COUNT = 10;
    /*
     *  Storage
     */
    mapping(uint => Transaction) public transactions;
    mapping(uint => mapping(address => bool)) public confirmations;
    mapping(address => bool) public isOwner;
    address[] public owners;
    uint public required;
    uint public transactionCount;
    uint public ethDailyLimit;
    uint public mtcDailyLimit;
    uint public dailySpent;
    uint public mtcDailySpent;
    uint public lastDay;
    uint public mtcLastDay;
    token public MTC;

    struct Transaction {
        address destination;
        uint value;
        bytes data;
        string description;
        bool executed;
    }
    /*
     *  Modifiers
     */
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
        require(!transactions[transactionId].executed);
        _;
    }
    modifier notNull(address _address) {
        require(_address != 0);
        _;
    }
    modifier validRequirement(uint ownerCount, uint _required) {
        require(ownerCount <= MAX_OWNER_COUNT
        && _required <= ownerCount
        && _required != 0
        && ownerCount != 0);
        _;
    }
    modifier validDailyEthLimit(uint _limit) {
        require(_limit >= 0);
        _;
    }
    modifier validDailyMTCLimit(uint _limit) {
        require(_limit >= 0);
        _;
    }
    /// @dev Fallback function allows to deposit ether.
    function()
    payable public
    {
        if (msg.value > 0)
            Deposit(msg.sender, msg.value);
    }
    /*
     * Public functions
     */
    /// @dev Contract constructor sets initial owners and required number of confirmations.
    /// @param _owners List of initial owners.
    /// @param _required Number of required confirmations.
    function MultiSigWallet(address[] _owners, uint _required, uint _ethDailyLimit, uint _mtcDailyLimit)
    public
    validRequirement(_owners.length, _required)
    {
        for (uint i = 0; i < _owners.length; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != 0);
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
        ethDailyLimit = _ethDailyLimit * 1 ether;
        mtcDailyLimit = _mtcDailyLimit * 1 ether;
        lastDay = toDays(now);
        mtcLastDay = toDays(now);
    }

    function toDays(uint _time) pure internal returns (uint) {
        return _time / (60 * 60 * 24);
    }

    /// @dev Allows to add a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of new owner.
    function addOwner(address owner)
    public
    onlyWallet
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
    onlyWallet
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
    onlyWallet
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
    onlyWallet
    validRequirement(owners.length, _required)
    {
        required = _required;
        RequirementChange(_required);
    }

    /// @dev Allows to change the eth daily transfer limit. Transaction has to be sent by wallet.
    /// @param _limit Daily eth limit.
    function changeEthDailyLimit(uint _limit)
    public
    onlyWallet
    validDailyEthLimit(_limit)
    {
        ethDailyLimit = _limit;
        EthDailyLimitChange(_limit);
    }

    /// @dev Allows to change the mtc daily transfer limit. Transaction has to be sent by wallet.
    /// @param _limit Daily mtc limit.
    function changeMtcDailyLimit(uint _limit)
    public
    onlyWallet
    validDailyMTCLimit(_limit)
    {
        mtcDailyLimit = _limit;
        MtcDailyLimitChange(_limit);
    }

    /// @dev Allows to change the token address. Transaction has to be sent by wallet.
    /// @param _token token address.
    function setToken(address _token)
    public
    onlyWallet
    {
        MTC = token(_token);
        TokenChange(_token);
    }

    /// @dev Allows an owner to submit and confirm a transaction.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param description Transaction description.
    /// @param data Transaction data payload.
    /// @return Returns transaction ID.
    function submitTransaction(address destination, uint value, string description, bytes data)
    public
    returns (uint transactionId)
    {
        transactionId = addTransaction(destination, value, description, data);
        confirmTransaction(transactionId);
    }
    /// @dev Allows an owner to confirm a transaction.
    /// @param transactionId Transaction ID.
    function confirmTransaction(uint transactionId)
    public
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
    ownerExists(msg.sender)
    confirmed(transactionId, msg.sender)
    notExecuted(transactionId)
    {
        confirmations[transactionId][msg.sender] = false;
        Revocation(msg.sender, transactionId);
    }
    /// @dev Allows anyone to execute a confirmed transaction.
    /// @param _to Destination address.
    /// @param _value amount.
    function softEthTransfer(address _to, uint _value)
    public
    ownerExists(msg.sender)
    {
        require(_value > 0);
        _value *= 1 finney;
        if (lastDay != toDays(now)) {
            dailySpent = 0;
            lastDay = toDays(now);
        }
        require((dailySpent + _value) <= ethDailyLimit);
        if (_to.send(_value)) {
            dailySpent += _value;
        } else {
            revert();
        }
    }

    /// @dev Allows anyone to execute a confirmed transaction.
    /// @param _to Destination address.
    /// @param _value amount.
    function softMtcTransfer(address _to, uint _value)
    public
    ownerExists(msg.sender)
    {
        require(_value > 0);
        _value *= 1 ether;
        if (mtcLastDay != toDays(now)) {
            mtcDailySpent = 0;
            mtcLastDay = toDays(now);
        }
        require((mtcDailySpent + _value) <= mtcDailyLimit);
        MTC.transfer(_to, _value);
        mtcDailySpent += _value;

    }

    /// @dev Allows anyone to execute a confirmed transaction.
    /// @param transactionId Transaction ID.
    function executeTransaction(uint transactionId)
    public
    ownerExists(msg.sender)
    confirmed(transactionId, msg.sender)
    notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];
            txn.executed = true;
            if (txn.destination.call.value(txn.value)(txn.data))
                Execution(transactionId);
            else {
                ExecutionFailure(transactionId);
                txn.executed = false;
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
    /// @param description Transaction description.
    /// @param data Transaction data payload.
    /// @return Returns transaction ID.
    function addTransaction(address destination, uint value, string description, bytes data)
    internal
    notNull(destination)
    returns (uint transactionId)
    {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination : destination,
            value : value,
            description : description,
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
    function getTransactionDescription(uint transactionId)
    public
    constant
    returns (string description)
    {
        Transaction storage txn = transactions[transactionId];
        return txn.description;
    }
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