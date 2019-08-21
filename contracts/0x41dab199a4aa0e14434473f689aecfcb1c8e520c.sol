contract MultiSigERC20Token
{
    uint constant public MAX_OWNER_COUNT = 50;
	
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 8;
    uint256 public totalSupply;
	address[] public owners;
	
	// Variables for multisig
	uint256 public required;
    uint public transactionCount;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    event FrozenFunds(address target, bool frozen);
	event Confirmation(address indexed sender, uint indexed transactionId);
    event Revocation(address indexed sender, uint indexed transactionId);
    event Submission(uint indexed transactionId,string operation, address source, address destination, uint256 value, string reason);
    event Execution(uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);
    event Deposit(address indexed sender, uint value);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint required);
	
	// Mappings
    mapping (uint => MetaTransaction) public transactions;
    mapping (address => uint256) public withdrawalLimit;
    mapping (uint => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isOwner;
	mapping (address => bool) public frozenAccount;
    mapping (address => uint256) public balanceOf;

    // Meta data for pending and executed Transactions
    struct MetaTransaction {
        address source;
        address destination;
        uint value;
        bool executed;
        uint operation;
        string reason;
    }

    // Modifiers

    modifier ownerDoesNotExist(address owner) {
        require (!isOwner[owner]);
        _;
    }

    modifier ownerExists(address owner) {
        require (isOwner[owner]);
        _;
    }

    modifier transactionExists(uint transactionId) {
        require (transactions[transactionId].destination != 0);
        _;
    }

    modifier confirmed(uint transactionId, address owner) {
        require (confirmations[transactionId][owner]);
        _;
    }

    modifier notConfirmed(uint transactionId, address owner) {
        require (!confirmations[transactionId][owner]);
        _;
    }

    modifier notExecuted(uint transactionId) {
        require (!transactions[transactionId].executed);
        _;
    }

    modifier notNull(address _address) {
        require (_address != 0);
        _;
    }

    /// @dev Fallback function allows to deposit ether.
    function() payable public
    {
        if (msg.value > 0)
        {
            emit Deposit(msg.sender, msg.value);
        }
    }

    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the contract and sets owner to the 
     * creator of the contract
     */
   constructor(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        balanceOf[this] = totalSupply;                      // Give the contract all initial tokens
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
		isOwner[msg.sender] = true;                         // Set Owner to Contract Creator
		required = 1;
		owners.push(msg.sender);
    }

    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check if the sender is frozen
        require(!frozenAccount[_from]);
        // Check if the recipient is frozen
        require(!frozenAccount[_to]);
        // Check for overflows
        require(balanceOf[_to] + _value > balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }
	
	
    /// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
    /// @param target Address to be frozen
    /// @param freeze either to freeze it or not
    function freezeAccount(address target, bool freeze) internal {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }
	
    /// @dev Allows to add a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of new owner.
    function addOwner(address owner)
        internal
        ownerDoesNotExist(owner)
        notNull(owner)
    {
        isOwner[owner] = true;
        owners.push(owner);
        required = required + 1;
        emit OwnerAddition(owner);
    }

    /// @dev Allows to remove an owner. Transaction has to be sent by wallet.
    /// @param owner Address of owner.
    function removeOwner(address owner)
        internal
        ownerExists(owner)
    {
        isOwner[owner] = false;
        for (uint i=0; i<owners.length - 1; i++)
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        owners.length -= 1;
        if (required > owners.length)
            changeRequirement(owners.length);
        emit OwnerRemoval(owner);
    }

    /// @dev Allows to replace an owner with a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of owner to be replaced.
    /// @param owner Address of new owner.
    function replaceOwner(address owner, address newOwner)
        internal
        ownerExists(owner)
        ownerDoesNotExist(newOwner)
    {
        for (uint i=0; i<owners.length; i++)
            if (owners[i] == owner) {
                owners[i] = newOwner;
                break;
            }
        isOwner[owner] = false;
        isOwner[newOwner] = true;
        emit OwnerRemoval(owner);
        emit OwnerAddition(newOwner);
    }

    /// @dev Allows to change the number of required confirmations. Transaction has to be sent by wallet.
    /// @param _required Number of required confirmations.
    function changeRequirement(uint256 _required)
        internal
    {
        required = _required;
        emit RequirementChange(_required);
    }

    /// @dev Allows an owner to submit and confirm a transaction.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @return Returns transaction ID.
    function submitTransaction(address source, address destination, uint256 value, uint operation, string reason)
        public
        returns (uint transactionId)
    {
        transactionId = transactionCount;
        transactions[transactionId] = MetaTransaction({
            source: source,
            destination: destination,
            value: value,
            operation: operation,
            executed: false,
            reason: reason
        });
        
        transactionCount += 1;
        
        if(operation == 1) // Operation 1 is Add Owner
        {
            emit Submission(transactionId,"Add Owner", source, destination, value, reason);
        }
        else if(operation == 2) // Operation 2 is Remove Owner
        {
            emit Submission(transactionId,"Remove Owner", source, destination, value, reason);
        }
        else if(operation == 3) // Operation 3 is Replace Owner
        {
            emit Submission(transactionId,"Replace Owner", source, destination, value, reason);
        }
        else if(operation == 4) // Operation 4 is Freeze Account
        {
            emit Submission(transactionId,"Freeze Account", source, destination, value, reason);
        }
        else if(operation == 5) // Operation 5 is UnFreeze Account
        {
            emit Submission(transactionId,"UnFreeze Account", source, destination, value, reason);
        }
        else if(operation == 6) // Operation 6 is change rquirement
        {
            emit Submission(transactionId,"Change Requirement", source, destination, value, reason);
        }
        else if(operation == 7) // Operation 7 is Issue Tokens from Contract
        {
            emit Submission(transactionId,"Issue Tokens", source, destination, value, reason);
        }
        else if(operation == 8) // Operation 8 is Admin Transfer Tokens
        {
            emit Submission(transactionId,"Admin Transfer Tokens", source, destination, value, reason);
        }
        else if(operation == 9) // Operation 9 is Set Owners Unsigned Withdrawal Limit
        {
            emit Submission(transactionId,"Set Unsigned Ethereum Withdrawal Limit", source, destination, value, reason);
        }
        else if(operation == 10) // Operation 10 is Admin Withdraw Ether without multisig
        {
            emit Submission(transactionId,"Unsigned Ethereum Withdrawal", source, destination, value, reason);
        }
        else if(operation == 11) // Operation 11 is Admin Withdraw Ether with multisig
        {
            emit Submission(transactionId,"Withdraw Ethereum", source, destination, value, reason);
        }
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
        emit Confirmation(msg.sender, transactionId);
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
        emit Revocation(msg.sender, transactionId);
    }

    /// @dev Allows anyone to execute a confirmed transaction.
    /// @param transactionId Transaction ID.
    function executeTransaction(uint transactionId)
        public
        notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            MetaTransaction storage transaction = transactions[transactionId];

            if(transaction.operation == 1) // Operation 1 is Add Owner
            {
                addOwner(transaction.destination);
                
                transaction.executed = true;
                emit Execution(transactionId);
            }
            else if(transaction.operation == 2) // Operation 2 is Remove Owner
            {
                removeOwner(transaction.destination);
                
                transaction.executed = true;
                emit Execution(transactionId);
            }
            else if(transaction.operation == 3) // Operation 3 is Replace Owner
            {
                replaceOwner(transaction.source,transaction.destination);
                
                transaction.executed = true;
                emit Execution(transactionId);
            }
            else if(transaction.operation == 4) // Operation 4 is Freeze Account
            {
                freezeAccount(transaction.destination,true);
                
                transaction.executed = true;
                emit Execution(transactionId);
            }
            else if(transaction.operation == 5) // Operation 5 is UnFreeze Account
            {
                freezeAccount(transaction.destination, false);
                
                transaction.executed = true;
                emit Execution(transactionId);
            }
            else if(transaction.operation == 6) // Operation 6 is UnFreeze Account
            {
                changeRequirement(transaction.value);
                
                transaction.executed = true;
                emit Execution(transactionId);
            }
            else if(transaction.operation == 7) // Operation 7 is Issue Tokens from Contract
            {
                _transfer(this,transaction.destination,transaction.value);
                
                transaction.executed = true;
                emit Execution(transactionId);
            }
            else if(transaction.operation == 8) // Operation 8 is Admin Transfer Tokens
            {
                _transfer(transaction.source,transaction.destination,transaction.value);
                
                transaction.executed = true;
                emit Execution(transactionId);
            }
            else if(transaction.operation == 9) // Operation 9 is Set Owners Unsigned Withdrawal Limit
            {
                require(isOwner[transaction.destination]);
                withdrawalLimit[transaction.destination] = transaction.value;
                
                transaction.executed = true;
                emit Execution(transactionId);
            }
            else if(transaction.operation == 11) // Operation 11 is Admin Withdraw Ether with multisig
            {
                require(isOwner[transaction.destination]);
                
                transaction.destination.transfer(transaction.value);
                
                transaction.executed = true;
                emit Execution(transactionId);
            }
        }
        else if(transaction.operation == 10) // Operation 10 is Admin Withdraw Ether without multisig
        {
            require(isOwner[transaction.destination]);
            require(withdrawalLimit[transaction.destination] <= transaction.value);
            
            withdrawalLimit[transaction.destination] -= transaction.value;
            
            assert(withdrawalLimit[transaction.destination] > 0);
            
            transaction.destination.transfer(transaction.value);
            transaction.executed = true;
            emit Execution(transactionId);
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
        for (uint i=0; i<owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
    }

    /*
     * Internal functions
     */
   
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
        for (uint i=0; i<owners.length; i++)
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
        for (uint i=0; i<transactionCount; i++)
            if (   pending && !transactions[i].executed
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
        for (i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i=0; i<count; i++)
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
        for (i=0; i<transactionCount; i++)
            if (   pending && !transactions[i].executed
                || executed && transactions[i].executed)
            {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        _transactionIds = new uint[](to - from);
        for (i=from; i<to; i++)
            _transactionIds[i - from] = transactionIdsTemp[i];
    }
}