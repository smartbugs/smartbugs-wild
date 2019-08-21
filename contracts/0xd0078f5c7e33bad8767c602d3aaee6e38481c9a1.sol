pragma solidity 0.4.18;


/**
 * @title Multisignature wallet
 * @dev Allows multiple parties to agree on transactions before execution
 * @author Stefan George <stefan.george@consensys.net>
 * @author Jakub Stefanski (https://github.com/jstefanski)
 */
contract MultiSigWallet {

    uint256 constant public MAX_OWNER_COUNT = 50;

    mapping (uint256 => Transaction) public transactions;
    mapping (uint256 => mapping (address => bool)) public confirmations;

    mapping (address => bool) public isOwner;
    address[] public owners;

    uint256 public required;
    uint256 public transactionCount;

    struct Transaction {
        address destination;
        uint256 value;
        bytes data;
        bool executed;
    }

    event Confirmation(address indexed sender, uint256 indexed transactionId);

    event Revocation(address indexed sender, uint256 indexed transactionId);

    event Submission(uint256 indexed transactionId);

    event Execution(uint256 indexed transactionId);

    event ExecutionFailure(uint256 indexed transactionId);

    event Deposit(address indexed sender, uint256 value);

    event OwnerAddition(address indexed owner);

    event OwnerRemoval(address indexed owner);

    event RequirementChange(uint256 required);

    modifier onlyWallet() {
        require(msg.sender == address(this));
        _;
    }

    modifier onlyOwnerDoesNotExist(address owner) {
        require(!isOwner[owner]);
        _;
    }

    modifier onlyOwnerExists(address owner) {
        require(isOwner[owner]);
        _;
    }

    modifier onlyTransactionExists(uint256 transactionId) {
        require(transactions[transactionId].destination != address(0));
        _;
    }

    modifier onlyConfirmed(uint256 transactionId, address owner) {
        require(confirmations[transactionId][owner]);
        _;
    }

    modifier onlyNotConfirmed(uint256 transactionId, address owner) {
        require(!confirmations[transactionId][owner]);
        _;
    }

    modifier onlyNotExecuted(uint256 transactionId) {
        require(!transactions[transactionId].executed);
        _;
    }

    modifier onlyValid(address _address) {
        require(_address != 0);
        _;
    }

    modifier onlyValidRequirement(uint256 ownerCount, uint256 _required) {
        require(ownerCount > 0);
        require(ownerCount <= MAX_OWNER_COUNT);
        require(_required > 0);
        require(_required <= ownerCount);
        _;
    }

    /**
     * @dev Contract constructor sets initial owners and required number of confirmations
     * @param _owners List of initial owners
     * @param _required Number of required confirmations
     */
    function MultiSigWallet(address[] _owners, uint256 _required)
        public
        onlyValidRequirement(_owners.length, _required)
    {
        for (uint256 i = 0; i < _owners.length; i++) {
            require(!isOwner[_owners[i]] && _owners[i] != address(0));

            isOwner[_owners[i]] = true;
        }

        owners = _owners;
        required = _required;
    }

    /**
     * @dev Fallback function allows ETH deposits
     */
    function() public payable {
        if (msg.value > 0) {
            Deposit(msg.sender, msg.value);
        }
    }

    /**
     * @dev Add a new owner
     * @dev Transaction has to be sent by wallet
     * @param owner The address of a new owner
     */
    function addOwner(address owner)
        public
        onlyWallet
        onlyValid(owner)
        onlyOwnerDoesNotExist(owner)
        onlyValidRequirement(owners.length + 1, required)
    {
        isOwner[owner] = true;
        owners.push(owner);

        OwnerAddition(owner);
    }

    /**
     * @dev Remove an owner
     * @dev Transaction has to be sent by wallet
     * @param owner The address of an owner
     */
    function removeOwner(address owner)
        public
        onlyWallet
        onlyOwnerExists(owner)
    {
        isOwner[owner] = false;

        for (uint256 i = 0; i < owners.length - 1; i++) {
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                owners.length -= 1;
                break;
            }
        }

        if (required > owners.length) {
            changeRequirement(owners.length);
        }

        OwnerRemoval(owner);
    }

    /**
     * @dev Replace the owner with a new owner
     * @dev Transaction has to be sent by wallet
     * @param owner The address of owner to be replaced
     * @param newOwner The address of new owner
     */
    function replaceOwner(address owner, address newOwner)
        public
        onlyWallet
        onlyOwnerExists(owner)
        onlyOwnerDoesNotExist(newOwner)
    {
        for (uint256 i = 0; i < owners.length; i++) {
            if (owners[i] == owner) {
                owners[i] = newOwner;
                break;
            }
        }

        isOwner[owner] = false;
        isOwner[newOwner] = true;

        OwnerRemoval(owner);
        OwnerAddition(newOwner);
    }

    /**
     * @dev Change the number of required confirmations
     * @dev Transaction has to be sent by wallet
     * @param _required The number of required confirmations
     */
    function changeRequirement(uint256 _required)
        public
        onlyWallet
        onlyValidRequirement(owners.length, _required)
    {
        required = _required;
        RequirementChange(_required);
    }

    /**
     * @dev Submit and confirm a transaction
     * @dev Transaction has to be sent by wallet
     * @param destination The transaction target address
     * @param value The transaction ETH value
     * @param data The transaction data payload
     * @return A transaction ID
     */
    function submitTransaction(address destination, uint256 value, bytes data)
        public
        onlyOwnerExists(msg.sender)
        returns (uint256 transactionId)
    {
        transactionId = addTransaction(destination, value, data);
        confirmTransaction(transactionId);
    }

    /**
     * @dev Confirm the transaction
     * @param transactionId The transaction ID
     */
    function confirmTransaction(uint256 transactionId)
        public
        onlyOwnerExists(msg.sender)
        onlyTransactionExists(transactionId)
        onlyNotConfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId][msg.sender] = true;
        Confirmation(msg.sender, transactionId);

        executeTransaction(transactionId);
    }

    /**
     * @dev Revoke the transaction confirmation
     * @param transactionId The transaction ID
     */
    function revokeConfirmation(uint256 transactionId)
        public
        onlyOwnerExists(msg.sender)
        onlyConfirmed(transactionId, msg.sender)
        onlyNotExecuted(transactionId)
    {
        confirmations[transactionId][msg.sender] = false;
        Revocation(msg.sender, transactionId);
    }

    /**
     * @dev Execute confirmed transaction
     * @param transactionId The transaction ID
     */
    function executeTransaction(uint256 transactionId)
        public
        onlyOwnerExists(msg.sender)
        onlyConfirmed(transactionId, msg.sender)
        onlyNotExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];
            txn.executed = true;

            /* solhint-disable avoid-call-value */
            if (txn.destination.call.value(txn.value)(txn.data)) {
                Execution(transactionId);
            } else {
                ExecutionFailure(transactionId);
                txn.executed = false;
            }
            /* solhint-enable avoid-call-value */
        }
    }

    /**
     * @dev Check confirmation status of the transaction
     * @param transactionId The transaction ID
     * @return True if transaction is confirmed, otherwise False
     */
    function isConfirmed(uint256 transactionId)
        public
        view
        returns (bool)
    {
        uint256 count = 0;
        for (uint256 i=0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]]) {
                count += 1;
            }

            if (count == required) {
                return true;
            }
        }
    }

    /**
     * @dev Get number of confirmations of the transaction
     * @param transactionId The transaction ID
     * @return Number of confirmations
     */
    function getConfirmationCount(uint256 transactionId)
        public
        view
        returns (uint256 count)
    {
        for (uint256 i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]]) {
                count += 1;
            }
        }
    }

    /**
     * @dev Get total number of transactions after filers are applied
     * @param pending Include pending transactions
     * @param executed Include executed transactions
     * @return Total number of transactions after filters are applied
     */
    function getTransactionCount(bool pending, bool executed)
        public
        view
        returns (uint256 count)
    {
        for (uint256 i = 0; i < transactionCount; i++) {
            bool txExecuted = transactions[i].executed;

            if ((pending && !txExecuted) || (executed && txExecuted)) {
                count += 1;
            }
        }
    }

    /**
     * @dev Get list of owners
     * @return List of owner addresses
     */
    function getOwners()
        public
        view
        returns (address[])
    {
        return owners;
    }

    /**
     * @dev Get array with owner addresses that confirmed the transaction
     * @param transactionId The transaction ID
     * @return Array of owner addresses that confirmed the transaction
     */
    function getConfirmations(uint256 transactionId)
        public
        view
        returns (address[] _confirmations)
    {
        address[] memory confirmationsTemp = new address[](owners.length);
        uint256 count = 0;
        uint256 i;

        for (i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        }

        _confirmations = new address[](count);
        for (i = 0; i < count; i++) {
            _confirmations[i] = confirmationsTemp[i];
        }
    }

    /**
     * @dev Get list of transaction IDs in defined range
     * @param from Index start position of transaction array
     * @param to Index end position of transaction array
     * @param pending Include pending transactions
     * @param executed Include executed transactions
     * @return Array of transaction IDs
     */
    function getTransactionIds(
        uint256 from,
        uint256 to,
        bool pending,
        bool executed
    )
        public
        view
        returns (uint256[] _transactionIds)
    {
        uint256[] memory transactionIdsTemp = new uint256[](transactionCount);
        uint256 count = 0;
        uint256 i;

        for (i = 0; i < transactionCount; i++) {
            bool txExecuted = transactions[i].executed;

            if ((pending && !txExecuted) || (executed && txExecuted)) {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        }

        _transactionIds = new uint256[](to - from);
        for (i = from; i < to; i++) {
            _transactionIds[i - from] = transactionIdsTemp[i];
        }
    }

    /**
     * @dev Add a new transaction to the transaction mapping
     * @param destination The transaction target address
     * @param value The transaction ether value
     * @param data The transaction data payload
     * @return The transaction ID
     */
    function addTransaction(address destination, uint256 value, bytes data)
        internal
        onlyValid(destination)
        returns (uint256 transactionId)
    {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            executed: false
        });
        transactionCount += 1;

        Submission(transactionId);
    }
}