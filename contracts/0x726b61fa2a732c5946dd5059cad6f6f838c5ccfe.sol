pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------------------------
// by Gifto
// author: Gifto Team
// Contact: datwhnguyen@gmail.com

/// @title Multisignature wallet - Allows multiple parties to agree on transactions before execution.

contract MultiSigWallet {

    event Confirmation(address sender, bytes32 transactionId);
    event Revocation(address sender, bytes32 transactionId);
    event Submission(bytes32 transactionId);
    event Execution(bytes32 transactionId);
    event Deposit(address sender, uint value);
    event OwnerAddition(address owner);
    event OwnerRemoval(address owner);
    event RequirementChange(uint required);
    event CoinCreation(address coin);

    mapping (bytes32 => Transaction) public transactions;
    mapping (bytes32 => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isOwner;
    address[] owners;
    bytes32[] transactionList;
    uint public required;

    struct Transaction {
        address destination;
        uint value;
        bytes data;
        uint nonce;
        bool executed;
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

    modifier confirmed(bytes32 transactionId, address owner) {
        require(confirmations[transactionId][owner]);
        _;
    }

    modifier notConfirmed(bytes32 transactionId, address owner) {
        require(!confirmations[transactionId][owner]);
        _;
    }

    modifier notExecuted(bytes32 transactionId) {
        require(!transactions[transactionId].executed);
        _;
    }

    modifier notNull(address destination) {
        require(destination != 0);
        _;
    }

    modifier validRequirement(uint _ownerCount, uint _required) {
        require(   _required <= _ownerCount
                && _required > 0 );
        _;
    }
    
    /// @dev Contract constructor sets initial owners and required number of confirmations.
    /// @param _owners List of initial owners.
    /// @param _required Number of required confirmations.
    function MultiSigWallet(address[] _owners, uint _required)
        validRequirement(_owners.length, _required)
        public {
        for (uint i=0; i<_owners.length; i++) {
            // check duplicate owner and invalid address
            if (isOwner[_owners[i]] || _owners[i] == 0){
                revert();
            }
            // assign new owner
            isOwner[_owners[i]] = true;
        }
        owners = _owners;
        required = _required;
    }

    ///  Fallback function allows to deposit ether.
    function()
        public
        payable {
        if (msg.value > 0)
            Deposit(msg.sender, msg.value);
    }

    /// @dev Allows to add a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of new owner.
    function addOwner(address owner)
        public
        onlyWallet
        ownerDoesNotExist(owner) {
        isOwner[owner] = true;
        owners.push(owner);
        OwnerAddition(owner);
    }

    /// @dev Allows to remove an owner. Transaction has to be sent by wallet.
    /// @param owner Address of owner.
    function removeOwner(address owner)
        public
        onlyWallet
        ownerExists(owner) {
        // DO NOT remove last owner
        require(owners.length > 1);
        
        isOwner[owner] = false;
        for (uint i=0; i<owners.length - 1; i++)
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        owners.length -= 1;
        if (required > owners.length)
            changeRequirement(owners.length);
        OwnerRemoval(owner);
    }

    /// @dev Update the minimum required owner for transaction validation
    /// @param _required number of owners
    function changeRequirement(uint _required)
        public
        onlyWallet
        validRequirement(owners.length, _required) {
        required = _required;
        RequirementChange(_required);
    }

    /// @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @param nonce 
    /// @return transactionId.
    function addTransaction(address destination, uint value, bytes data, uint nonce)
        private
        notNull(destination)
        returns (bytes32 transactionId) {
        // transactionId = sha3(destination, value, data, nonce);
        transactionId = keccak256(destination, value, data, nonce);
        if (transactions[transactionId].destination == 0) {
            transactions[transactionId] = Transaction({
                destination: destination,
                value: value,
                data: data,
                nonce: nonce,
                executed: false
            });
            transactionList.push(transactionId);
            Submission(transactionId);
        }
    }

    /// @dev Allows an owner to submit and confirm a transaction.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @param nonce 
    /// @return transactionId.
    function submitTransaction(address destination, uint value, bytes data, uint nonce)
        external
        ownerExists(msg.sender)
        returns (bytes32 transactionId) {
        transactionId = addTransaction(destination, value, data, nonce);
        confirmTransaction(transactionId);
    }

    /// @dev Allows an owner to confirm a transaction.
    /// @param transactionId transaction Id.
    function confirmTransaction(bytes32 transactionId)
        public
        ownerExists(msg.sender)
        notConfirmed(transactionId, msg.sender) {
        confirmations[transactionId][msg.sender] = true;
        Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    
    /// @dev Allows anyone to execute a confirmed transaction.
    /// @param transactionId transaction Id.
    function executeTransaction(bytes32 transactionId)
        public
        notExecuted(transactionId) {
        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId]; 
            txn.executed = true;
            if (!txn.destination.call.value(txn.value)(txn.data))
                revert();
            Execution(transactionId);
        }
    }

    /// @dev Allows an owner to revoke a confirmation for a transaction.
    /// @param transactionId transaction Id.
    function revokeConfirmation(bytes32 transactionId)
        external
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId) {
        confirmations[transactionId][msg.sender] = false;
        Revocation(msg.sender, transactionId);
    }

    /// @dev Returns the confirmation status of a transaction.
    /// @param transactionId transaction Id.
    /// @return Confirmation status.
    function isConfirmed(bytes32 transactionId)
        public
        constant
        returns (bool) {
        uint count = 0;
        for (uint i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required)
                return true;
    }

    /*
     * Web3 call functions
     */
    /// @dev Returns number of confirmations of a transaction.
    /// @param transactionId transaction Id.
    /// @return Number of confirmations.
    function confirmationCount(bytes32 transactionId)
        external
        constant
        returns (uint count) {
        for (uint i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]])
                count += 1;
    }

    ///  @dev Return list of transactions after filters are applied
    ///  @param isPending pending status
    ///  @return List of transactions
    function filterTransactions(bool isPending)
        private
        constant
        returns (bytes32[] _transactionList) {
        bytes32[] memory _transactionListTemp = new bytes32[](transactionList.length);
        uint count = 0;
        for (uint i=0; i<transactionList.length; i++)
            if (transactions[transactionList[i]].executed != isPending)
            {
                _transactionListTemp[count] = transactionList[i];
                count += 1;
            }
        _transactionList = new bytes32[](count);
        for (i=0; i<count; i++)
            if (_transactionListTemp[i] > 0)
                _transactionList[i] = _transactionListTemp[i];
    }

    /// @dev Returns list of pending transactions
    function getPendingTransactions()
        external
        constant
        returns (bytes32[]) {
        return filterTransactions(true);
    }

    /// @dev Returns list of executed transactions
    function getExecutedTransactions()
        external
        constant
        returns (bytes32[]) {
        return filterTransactions(false);
    }
}