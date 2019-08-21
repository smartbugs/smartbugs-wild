pragma solidity ^0.4.19;
contract TrustWallet {

    struct User {
        // How many seconds the user has to wait between initiating the
        // transaction and finalizing the transaction. This cannot be
        // changed.
        uint waiting_time;

        address added_by;
        uint time_added;

        address removed_by;
        uint time_removed;

        // When this user added another user. (This is to prevent a user from
        // adding many users too quickly).
        uint time_added_another_user;
    }

    struct Transaction {
        address destination;
        uint value;
        bytes data;

        address initiated_by;
        uint time_initiated;

        address finalized_by;
        uint time_finalized;

        // True if this trasaction was executed. If false, this means it was canceled.
        bool is_executed;
        // True if the execution call was successful
        bool execution_successful;
    }

    Transaction[] public transactions;
    mapping (address => User) public users;
    address[] public userAddresses;

    modifier onlyActiveUsersAllowed() {
        require(users[msg.sender].time_added != 0);
        require(users[msg.sender].time_removed == 0);
        _;
    }

    modifier transactionMustBePending() {
        require(isTransactionPending());
        _;
    }

    modifier transactionMustNotBePending() {
        require(!isTransactionPending());
        _;
    }

    // Returns true if there is a transaction pending.
    function isTransactionPending() public constant returns (bool) {
        if (transactions.length == 0) return false;
        return transactions[transactions.length - 1].time_initiated > 0 &&
            transactions[transactions.length - 1].time_finalized == 0;
    }

    // Returns the balance of this contract.
    function balance() public constant returns (uint) {
        return address(this).balance;
    }

    // Returns the balance of this contract.
    function transactionCount() public constant returns (uint) {
        return transactions.length;
    }

    // Constructor. Creates the first user.
    function TrustWallet(address first_user) public {
        users[first_user] = User({
            waiting_time: 0,
            time_added: now,
            added_by: 0x0,
            time_removed: 0,
            removed_by: 0x0,
            time_added_another_user: now
        });
        userAddresses.push(first_user);
    }

    function () public payable {}

    // Initiates a transaction. There must not be any pending transaction.
    function initiateTransaction(address _destination, uint _value, bytes _data)
        public
        onlyActiveUsersAllowed()
        transactionMustNotBePending()
    {
        transactions.push(Transaction({
            destination: _destination,
            value: _value,
            data: _data,
            initiated_by: msg.sender,
            time_initiated: now,
            finalized_by: 0x0,
            time_finalized: 0,
            is_executed: false,
            execution_successful: false
        }));
    }

    // Executes the transaction. The waiting_time of the the transaction
    // initiated_by must have passed in order to call this function. Any active
    // user is able to call this function.
    function executeTransaction()
        public
        onlyActiveUsersAllowed()
        transactionMustBePending()
    {
        Transaction storage transaction = transactions[transactions.length - 1];
        require(now > transaction.time_initiated + users[transaction.initiated_by].waiting_time);
        transaction.is_executed = true;
        transaction.time_finalized = now;
        transaction.finalized_by = msg.sender;
        transaction.execution_successful = transaction.destination.call.value(
            transaction.value)(transaction.data);
    }

    // Cancels the transaction. The waiting_time of the user who is trying
    // to cancel must be lower or equal to the waiting_time of the
    // transaction initiated_by.
    function cancelTransaction()
        public
        onlyActiveUsersAllowed()
        transactionMustBePending()
    {
        // Users with a higher priority can do this
        Transaction storage transaction = transactions[transactions.length - 1];
        // Either the sender is a higher priority user
        require(users[msg.sender].waiting_time <=
            users[transaction.initiated_by].waiting_time);
        transaction.time_finalized = now;
        transaction.finalized_by = msg.sender;
    }

    // Adds a user to the wallet. The waiting time of the new user must
    // be greater or equal to the waiting_time of the sender. A user that
    // already exists or was removed cannot be added. To prevent spam,
    // a user must wait waiting_time before adding another user.
    function addUser(address new_user, uint new_user_time)
        public
        onlyActiveUsersAllowed()
    {
        require(users[new_user].time_added == 0);
        require(users[new_user].time_removed == 0);

        User storage sender = users[msg.sender];
        require(now > sender.waiting_time + sender.time_added_another_user);
        require(new_user_time >= sender.waiting_time);

        sender.time_added_another_user = now;
        users[new_user] = User({
            waiting_time: new_user_time,
            time_added: now,
            added_by: msg.sender,
            time_removed: 0,
            removed_by: 0x0,
            // The new user will have to wait one waiting_time before being
            // able to add a new user.
            time_added_another_user: now
        });
        userAddresses.push(new_user);
    }

    // Removes a user. The sender must have a lower or equal waiting_time
    // as the user that she is trying to remove.
    function removeUser(address userAddr)
        public
        onlyActiveUsersAllowed()
    {
        require(users[userAddr].time_removed == 0);
        require(users[userAddr].time_added != 0);

        User storage sender = users[msg.sender];
        require(sender.waiting_time <= users[userAddr].waiting_time);

        users[userAddr].removed_by = msg.sender;
        users[userAddr].time_removed = now;
    }
}

contract TrustWalletFactory {
    mapping (address => TrustWallet[]) public wallets;

    function createWallet() public {
        wallets[msg.sender].push(new TrustWallet(msg.sender));
    }
}