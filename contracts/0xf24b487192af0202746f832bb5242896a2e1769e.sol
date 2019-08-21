pragma solidity 0.4.19;

contract Admin {

    address public owner;
    mapping(address => bool) public AdminList;

    event AdministratorAdded(address indexed _invoker, address indexed _newAdministrator);
    event AdministratorRemoved(address indexed _invoker, address indexed _removedAdministrator);
    event OwnershipChanged(address indexed _invoker, address indexed _newOwner);

    function Admin() public {
        owner = msg.sender;
    }

    modifier OnlyAdmin() {
        require(msg.sender == owner || AdminList[msg.sender] == true);
        _;
    }

    modifier OnlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function MakeAdministrator(address AddressToAdd) public returns (bool success) {

        require(msg.sender == owner);
        require(AddressToAdd != address(0));
        AdminList[AddressToAdd] = true;
        AdministratorAdded(msg.sender, AddressToAdd);

        return true;

    }

    function RemoveAdministrator(address AddressToRemove) public returns (bool success) {

        require(msg.sender == owner);
        require(AddressToRemove != address(0));
        delete AdminList[AddressToRemove];
        AdministratorRemoved(msg.sender, AddressToRemove);

        return true;

    }

    function ChangeOwner(address AddressToMake) public returns (bool success) {

        require(msg.sender == owner);
        require(AddressToMake != address(0));
        require(owner != AddressToMake);
        owner = AddressToMake;
        OwnershipChanged(msg.sender, AddressToMake);

        return true;

    }

}

contract KoveredPay is Admin {

    bytes4 public symbol = "KVP";
    bytes16 public name = "KoveredPay";
    uint8 public decimals = 18;
    uint256 constant TotalSupply = 50000000000000000000000000;

    bool public TransfersEnabled;
    uint256 public TrustlessTransactions_TransactionHeight = 0;
    uint256 public MediatedTransactions_TransactionHeight = 0;
    uint128 public TrustlessTransaction_Protection_Seconds = 259200;
    uint128 public MediatedTransaction_Protection_Seconds = 2620800;
    address public InitialOwnerAddress = address(0);
    address public CoreMediator = address(0);
    uint256 public MediatorFees = 0;
    uint256 public LockInExpiry = 0;

    mapping(address => uint256) public UserBalances;
    mapping(address => mapping(address => uint256)) public Allowance;

    struct TrustlessTransaction {
        address _sender;
        address _receiver;
        uint256 _kvp_amount;
        bool _statusModified;
        bool _credited;
        bool _refunded;
        uint256 _time;
    }

    struct MediatedTransaction {
        address _sender;
        address _receiver;
        bool _mediator;
        uint256 _kvp_amount;
        uint256 _fee_amount;
        bool _satisfaction;
        bool _statusModified;
        bool _credited;
        uint256 _time;
    }

    mapping(uint256 => TrustlessTransaction) public TrustlessTransactions_Log;
    mapping(uint256 => MediatedTransaction) public MediatedTransactions_Log;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Trustless_Transfer(uint256 _id, address indexed _from, address indexed _to, uint256 _value);
    event Mediated_Transfer(uint256 _id, address indexed _from, address indexed _to, uint256 _value);
    event TrustlessTransferStatusModified(uint256 _transactionId, bool _newStatus);
    event MediatedTransferStatusModified(uint256 _transactionId, bool _newStatus);
    event TrustlessTransaction_Refunded(uint256 _transactionId, uint256 _amount);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function KoveredPay() public {

        UserBalances[msg.sender] = TotalSupply;
        CoreMediator = msg.sender;
        InitialOwnerAddress = msg.sender;
        LockInExpiry = add(block.timestamp, 15778463);
        TransfersEnabled = true;

    }

    function AlterMediatorSettings(address _newAddress, uint128 _fees) public OnlyAdmin returns (bool success) {

        CoreMediator = _newAddress;
        MediatorFees = _fees;

        return true;

    }

    function ChangeProtectionTime(uint _type, uint128 _seconds) public OnlyAdmin returns (bool success) {

        if (_type == 1) {
            TrustlessTransaction_Protection_Seconds = _seconds;
        } else {
            MediatedTransaction_Protection_Seconds = _seconds;
        }

        return true;

    }

    function TransferStatus(bool _newStatus) public OnlyAdmin returns (bool success) {

        TransfersEnabled = _newStatus;

        return true;

    }

    function TransferValidation(address sender, address recipient, uint256 amount) private view returns (bool success) {

        require(TransfersEnabled == true);
        require(amount > 0);
        require(recipient != address(0));
        require(UserBalances[sender] >= amount);
        require(sub(UserBalances[sender], amount) >= 0);
        require(add(UserBalances[recipient], amount) > UserBalances[recipient]);

        if (sender == InitialOwnerAddress && block.timestamp < LockInExpiry) {
            require(sub(UserBalances[sender], amount) >= 10000000000000000000000000);
        }

        return true;

    }

    function MultiTransfer(address[] _destinations, uint256[] _values) public OnlyAdmin returns (uint256) {

        uint256 i = 0;

        while (i < _destinations.length) {
            transfer(_destinations[i], _values[i]);
            i += 1;
        }

        return (i);

    }

    function transfer(address receiver, uint256 amount) public returns (bool _status) {

        require(TransferValidation(msg.sender, receiver, amount));
        UserBalances[msg.sender] = sub(UserBalances[msg.sender], amount);
        UserBalances[receiver] = add(UserBalances[receiver], amount);
        Transfer(msg.sender, receiver, amount);
        return true;

    }

    function transferFrom(address _owner, address _receiver, uint256 _amount) public returns (bool _status) {

        require(TransferValidation(_owner, _receiver, _amount));
        require(sub(Allowance[_owner][msg.sender], _amount) >= _amount);
        Allowance[_owner][msg.sender] = sub(Allowance[_owner][msg.sender], _amount);
        UserBalances[_owner] = sub(UserBalances[_owner], _amount);
        UserBalances[_receiver] = add(UserBalances[_receiver], _amount);
        Transfer(_owner, _receiver, _amount);
        return true;

    }

    function Send_TrustlessTransaction(address receiver, uint256 amount) public returns (uint256 transferId) {

        require(TransferValidation(msg.sender, receiver, amount));
        UserBalances[msg.sender] = sub(UserBalances[msg.sender], amount);
        TrustlessTransactions_TransactionHeight = TrustlessTransactions_TransactionHeight + 1;
        TrustlessTransactions_Log[TrustlessTransactions_TransactionHeight] = TrustlessTransaction(msg.sender, receiver, amount, false, false, false, block.timestamp);
        Trustless_Transfer(TrustlessTransactions_TransactionHeight, msg.sender, receiver, amount);
        return TrustlessTransactions_TransactionHeight;

    }

    function Send_MediatedTransaction(address receiver, uint256 amount) public returns (uint256 transferId) {

        require(TransferValidation(msg.sender, receiver, amount));
        UserBalances[msg.sender] = sub(UserBalances[msg.sender], amount);
        MediatedTransactions_TransactionHeight = MediatedTransactions_TransactionHeight + 1;
        MediatedTransactions_Log[MediatedTransactions_TransactionHeight] = MediatedTransaction(msg.sender, receiver, false, amount, 0, false, false, false, block.timestamp);
        Mediated_Transfer(MediatedTransactions_TransactionHeight, msg.sender, receiver, amount);
        return MediatedTransactions_TransactionHeight;

    }

    function Appoint_Mediator(uint256 _txid) public returns (bool success) {

        if (MediatedTransactions_Log[_txid]._sender == msg.sender || MediatedTransactions_Log[_txid]._receiver == msg.sender) {

            uint256 sent_on = MediatedTransactions_Log[_txid]._time;
            uint256 right_now = block.timestamp;
            uint256 difference = sub(right_now, sent_on);

            require(MediatedTransactions_Log[_txid]._mediator == false);
            require(MediatedTransactions_Log[_txid]._satisfaction == false);
            require(MediatedTransactions_Log[_txid]._statusModified == false);
            require(difference <= MediatedTransaction_Protection_Seconds);
            require(MediatedTransactions_Log[_txid]._credited == false);
            require(MediatedTransactions_Log[_txid]._kvp_amount >= MediatorFees);

            MediatedTransactions_Log[_txid]._mediator = true;
            MediatedTransactions_Log[_txid]._fee_amount = MediatorFees;

            return true;

        } else {

            return false;

        }

    }

    function Alter_TrustlessTransaction(uint256 _transactionId, bool _newStatus) public returns (bool _response) {

        uint256 sent_on = TrustlessTransactions_Log[_transactionId]._time;
        uint256 right_now = block.timestamp;
        uint256 difference = sub(right_now, sent_on);

        require(TransfersEnabled == true);
        require(TrustlessTransactions_Log[_transactionId]._statusModified == false);
        require(difference <= TrustlessTransaction_Protection_Seconds);
        require(TrustlessTransactions_Log[_transactionId]._sender == msg.sender);
        require(TrustlessTransactions_Log[_transactionId]._refunded == false);
        require(TrustlessTransactions_Log[_transactionId]._credited == false);

        if (_newStatus == true) {

            UserBalances[TrustlessTransactions_Log[_transactionId]._receiver] = add(UserBalances[TrustlessTransactions_Log[_transactionId]._receiver], TrustlessTransactions_Log[_transactionId]._kvp_amount);
            TrustlessTransactions_Log[_transactionId]._credited = true;

        } else {

            UserBalances[TrustlessTransactions_Log[_transactionId]._sender] = add(UserBalances[TrustlessTransactions_Log[_transactionId]._sender], TrustlessTransactions_Log[_transactionId]._kvp_amount);

        }

        TrustlessTransactions_Log[_transactionId]._statusModified = true;
        TrustlessTransferStatusModified(_transactionId, _newStatus);

        return true;

    }

    function Alter_MediatedTransaction(uint256 _transactionId, bool _newStatus) public returns (bool _response) {

        require(TransfersEnabled == true);
        require(MediatedTransactions_Log[_transactionId]._mediator == true);
        require(MediatedTransactions_Log[_transactionId]._statusModified == false);
        require(CoreMediator == msg.sender);
        require(MediatedTransactions_Log[_transactionId]._credited == false);

        uint256 newAmount = sub(MediatedTransactions_Log[_transactionId]._kvp_amount, MediatedTransactions_Log[_transactionId]._fee_amount);

        if (newAmount < 0) {
            newAmount = 0;
        }

        if (_newStatus == true) {

            UserBalances[MediatedTransactions_Log[_transactionId]._receiver] = add(UserBalances[MediatedTransactions_Log[_transactionId]._receiver], newAmount);
            MediatedTransactions_Log[_transactionId]._credited = true;

        } else {

            UserBalances[MediatedTransactions_Log[_transactionId]._sender] = add(UserBalances[MediatedTransactions_Log[_transactionId]._sender], newAmount);

        }

        UserBalances[CoreMediator] = add(UserBalances[CoreMediator], MediatedTransactions_Log[_transactionId]._fee_amount);

        MediatedTransactions_Log[_transactionId]._statusModified = true;
        MediatedTransferStatusModified(_transactionId, _newStatus);

        return true;

    }

    function Refund_TrustlessTransaction(uint256 _transactionId) public returns (bool _response) {

        require(TransfersEnabled == true);
        require(TrustlessTransactions_Log[_transactionId]._refunded == false);
        require(TrustlessTransactions_Log[_transactionId]._statusModified == true);
        require(TrustlessTransactions_Log[_transactionId]._credited == true);
        require(TrustlessTransactions_Log[_transactionId]._receiver == msg.sender);
        require(TransferValidation(msg.sender, TrustlessTransactions_Log[_transactionId]._sender, TrustlessTransactions_Log[_transactionId]._kvp_amount));
        require(sub(UserBalances[TrustlessTransactions_Log[_transactionId]._sender], TrustlessTransactions_Log[_transactionId]._kvp_amount) > 0);
        UserBalances[TrustlessTransactions_Log[_transactionId]._sender] = add(UserBalances[TrustlessTransactions_Log[_transactionId]._sender], TrustlessTransactions_Log[_transactionId]._kvp_amount);
        TrustlessTransactions_Log[_transactionId]._refunded = true;
        TrustlessTransaction_Refunded(_transactionId, TrustlessTransactions_Log[_transactionId]._kvp_amount);

        return true;

    }

    function Update_TrustlessTransaction(uint256 _transactionId) public returns (bool _response) {

        uint256 sent_on = TrustlessTransactions_Log[_transactionId]._time;
        uint256 right_now = block.timestamp;
        uint256 difference = sub(right_now, sent_on);

        require(TransfersEnabled == true);
        require(TrustlessTransactions_Log[_transactionId]._statusModified == false);
        require(difference > TrustlessTransaction_Protection_Seconds);
        require(TrustlessTransactions_Log[_transactionId]._refunded == false);
        require(TrustlessTransactions_Log[_transactionId]._credited == false);

        UserBalances[TrustlessTransactions_Log[_transactionId]._receiver] = add(UserBalances[TrustlessTransactions_Log[_transactionId]._receiver], TrustlessTransactions_Log[_transactionId]._kvp_amount);
        TrustlessTransactions_Log[_transactionId]._credited = true;
        TrustlessTransactions_Log[_transactionId]._statusModified = true;
        TrustlessTransferStatusModified(_transactionId, true);

        return true;

    }

    function Express_Satisfaction_MediatedTransaction(uint256 _transactionId) public returns (bool _response) {

        require(TransfersEnabled == true);
        require(MediatedTransactions_Log[_transactionId]._sender == msg.sender);
        require(MediatedTransactions_Log[_transactionId]._mediator == false);
        require(MediatedTransactions_Log[_transactionId]._statusModified == false);
        require(MediatedTransactions_Log[_transactionId]._credited == false);
        require(MediatedTransactions_Log[_transactionId]._satisfaction == false);

        UserBalances[MediatedTransactions_Log[_transactionId]._receiver] = add(UserBalances[MediatedTransactions_Log[_transactionId]._receiver], MediatedTransactions_Log[_transactionId]._kvp_amount);
        MediatedTransactions_Log[_transactionId]._credited = true;
        MediatedTransactions_Log[_transactionId]._statusModified = true;
        MediatedTransactions_Log[_transactionId]._satisfaction = true;
        MediatedTransferStatusModified(_transactionId, true);

        return true;

    }

    function Update_MediatedTransaction(uint256 _transactionId) public returns (bool _response) {

        uint256 sent_on = MediatedTransactions_Log[_transactionId]._time;
        uint256 right_now = block.timestamp;
        uint256 difference = sub(right_now, sent_on);

        require(TransfersEnabled == true);
        require(difference > MediatedTransaction_Protection_Seconds);
        require(MediatedTransactions_Log[_transactionId]._mediator == false);
        require(MediatedTransactions_Log[_transactionId]._statusModified == false);
        require(MediatedTransactions_Log[_transactionId]._credited == false);
        require(MediatedTransactions_Log[_transactionId]._satisfaction == false);

        UserBalances[MediatedTransactions_Log[_transactionId]._sender] = add(UserBalances[MediatedTransactions_Log[_transactionId]._sender], MediatedTransactions_Log[_transactionId]._kvp_amount);

        MediatedTransactions_Log[_transactionId]._statusModified = true;
        MediatedTransferStatusModified(_transactionId, false);

        return true;

    }

    function View_TrustlessTransaction_Info(uint256 _transactionId) public view returns (
        address _sender,
        address _receiver,
        uint256 _kvp_amount,
        uint256 _time
    ) {

        return (TrustlessTransactions_Log[_transactionId]._sender, TrustlessTransactions_Log[_transactionId]._receiver, TrustlessTransactions_Log[_transactionId]._kvp_amount, TrustlessTransactions_Log[_transactionId]._time);

    }

    function View_MediatedTransaction_Info(uint256 _transactionId) public view returns (
        address _sender,
        address _receiver,
        uint256 _kvp_amount,
        uint256 _fee_amount,
        uint256 _time
    ) {

        return (MediatedTransactions_Log[_transactionId]._sender, MediatedTransactions_Log[_transactionId]._receiver, MediatedTransactions_Log[_transactionId]._kvp_amount, MediatedTransactions_Log[_transactionId]._fee_amount, MediatedTransactions_Log[_transactionId]._time);

    }

    function View_TrustlessTransaction_Status(uint256 _transactionId) public view returns (
        bool _statusModified,
        bool _credited,
        bool _refunded
    ) {

        return (TrustlessTransactions_Log[_transactionId]._statusModified, TrustlessTransactions_Log[_transactionId]._credited, TrustlessTransactions_Log[_transactionId]._refunded);

    }

    function View_MediatedTransaction_Status(uint256 _transactionId) public view returns (
        bool _satisfaction,
        bool _statusModified,
        bool _credited
    ) {

        return (MediatedTransactions_Log[_transactionId]._satisfaction, MediatedTransactions_Log[_transactionId]._statusModified, MediatedTransactions_Log[_transactionId]._credited);

    }

    function approve(address spender, uint256 amount) public returns (bool approved) {
        require(amount > 0);
        require(UserBalances[spender] > 0);
        Allowance[msg.sender][spender] = amount;
        Approval(msg.sender, spender, amount);
        return true;
    }

    function balanceOf(address _address) public view returns (uint256 balance) {
        return UserBalances[_address];
    }

    function allowance(address owner, address spender) public view returns (uint256 smount_allowed) {
        return Allowance[owner][spender];
    }

    function totalSupply() public pure returns (uint256 _supply) {
        return TotalSupply;
    }

}