pragma solidity ^0.4.21;

contract LockRequestable {

    uint256 public lockRequestCount;

    function LockRequestable() public {
        lockRequestCount = 0;
    }

    function generateLockId() internal returns (bytes32 lockId) {
        return keccak256(block.blockhash(block.number - 1), address(this), ++lockRequestCount);
    }
}

contract CustodianUpgradeable is LockRequestable {

    struct CustodianChangeRequest {
        address proposedNew;
    }

    address public custodian;

    mapping(bytes32 => CustodianChangeRequest) public custodianChangeReqs;

    function CustodianUpgradeable(
        address _custodian
    )
    LockRequestable()
    public
    {
        custodian = _custodian;
    }

    modifier onlyCustodian {
        require(msg.sender == custodian);
        _;
    }

    function requestCustodianChange(address _proposedCustodian) public returns (bytes32 lockId) {
        require(_proposedCustodian != address(0));

        lockId = generateLockId();

        custodianChangeReqs[lockId] = CustodianChangeRequest({
            proposedNew : _proposedCustodian
            });

        emit CustodianChangeRequested(lockId, msg.sender, _proposedCustodian);
    }

    function confirmCustodianChange(bytes32 _lockId) public onlyCustodian {
        custodian = getCustodianChangeReq(_lockId);
        delete custodianChangeReqs[_lockId];
        emit CustodianChangeConfirmed(_lockId, custodian);
    }

    function getCustodianChangeReq(bytes32 _lockId) private view returns (address _proposedNew) {
        CustodianChangeRequest storage changeRequest = custodianChangeReqs[_lockId];
        require(changeRequest.proposedNew != 0);
        return changeRequest.proposedNew;
    }

    event CustodianChangeRequested(
        bytes32 _lockId,
        address _msgSender,
        address _proposedCustodian
    );

    event CustodianChangeConfirmed(bytes32 _lockId, address _newCustodian);
}

contract ERC20ImplUpgradeable is CustodianUpgradeable {

    struct ImplChangeRequest {
        address proposedNew;
    }

    ERC20Impl public erc20Impl;

    mapping(bytes32 => ImplChangeRequest) public implChangeReqs;

    function ERC20ImplUpgradeable(address _custodian) CustodianUpgradeable(_custodian) public {
        erc20Impl = ERC20Impl(0x0);
    }

    modifier onlyImpl {
        require(msg.sender == address(erc20Impl));
        _;
    }

    function requestImplChange(address _proposedImpl) public returns (bytes32 lockId) {
        require(_proposedImpl != address(0));
        lockId = generateLockId();
        implChangeReqs[lockId] = ImplChangeRequest({
            proposedNew : _proposedImpl
            });
        emit ImplChangeRequested(lockId, msg.sender, _proposedImpl);
    }

    function confirmImplChange(bytes32 _lockId) public onlyCustodian {
        erc20Impl = getImplChangeReq(_lockId);
        delete implChangeReqs[_lockId];
        emit ImplChangeConfirmed(_lockId, address(erc20Impl));
    }

    function getImplChangeReq(bytes32 _lockId) private view returns (ERC20Impl _proposedNew) {
        ImplChangeRequest storage changeRequest = implChangeReqs[_lockId];
        require(changeRequest.proposedNew != address(0));
        return ERC20Impl(changeRequest.proposedNew);
    }

    event ImplChangeRequested(
        bytes32 _lockId,
        address _msgSender,
        address _proposedImpl
    );

    event ImplChangeConfirmed(bytes32 _lockId, address _newImpl);
}


contract NianLunServiceUpgradeable is CustodianUpgradeable {

    struct NianLunServiceChangeRequest {
        address proposedNew;
    }

    NianLunService public nianLunService;

    mapping(bytes32 => NianLunServiceChangeRequest) public nianLunServiceChangeReqs;

    function NianLunServiceUpgradeable(address _custodian) CustodianUpgradeable(_custodian) public {
        nianLunService = NianLunService(0x0);
    }

    modifier onlyNianLunService {
        require(msg.sender == address(nianLunService));
        _;
    }

    function requestNianLunServiceChange(address _proposedNianLunService) public returns (bytes32 lockId) {
        require(_proposedNianLunService != address(0));
        lockId = generateLockId();
        nianLunServiceChangeReqs[lockId] = NianLunServiceChangeRequest({
            proposedNew : _proposedNianLunService
            });
        emit NianLunServiceChangeRequested(lockId, msg.sender, _proposedNianLunService);
    }

    function confirmNianLunServiceChange(bytes32 _lockId) public onlyCustodian {
        nianLunService = getNianLunServiceChangeReq(_lockId);
        delete nianLunServiceChangeReqs[_lockId];
        emit NianLunServiceChangeConfirmed(_lockId, address(nianLunService));
    }

    function getNianLunServiceChangeReq(bytes32 _lockId) private view returns (NianLunService _proposedNew) {
        NianLunServiceChangeRequest storage changeRequest = nianLunServiceChangeReqs[_lockId];
        require(changeRequest.proposedNew != address(0));
        return NianLunService(changeRequest.proposedNew);
    }

    event NianLunServiceChangeRequested(
        bytes32 _lockId,
        address _msgSender,
        address _proposedNianLunService
    );

    event NianLunServiceChangeConfirmed(bytes32 _lockId, address _newNianLunService);
}

contract ERC20Interface {
    // METHODS
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#totalsupply
    function totalSupply() public view returns (uint256);

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#balanceof
    function balanceOf(address _owner) public view returns (uint256 balance);

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#transfer
    function transfer(address _to, uint256 _value) public returns (bool success);

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#transferfrom
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#approve
    function approve(address _spender, uint256 _value) public returns (bool success);

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#allowance
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    // EVENTS
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#transfer-1
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md#approval
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract ERC20Proxy is ERC20Interface, ERC20ImplUpgradeable, NianLunServiceUpgradeable {

    string public name;

    string public symbol;

    uint8 public decimals;

    function ERC20Proxy(
        string _name,
        string _symbol,
        uint8 _decimals,
        address _custodian
    )
    ERC20ImplUpgradeable(_custodian) NianLunServiceUpgradeable(_custodian)
    public
    {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    modifier onlyPermitted() {
        require(
            msg.sender == address(nianLunService) ||
            msg.sender == address(erc20Impl)
        );
        _;
    }

    function totalSupply() public view returns (uint256) {
        return erc20Impl.totalSupply();
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return erc20Impl.balanceOf(_owner);
    }

    function emitTransfer(address _from, address _to, uint256 _value) public onlyPermitted {
        emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        return erc20Impl.transferWithSender(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        return erc20Impl.transferFromWithSender(msg.sender, _from, _to, _value);
    }

    function emitApproval(address _owner, address _spender, uint256 _value) public onlyImpl {
        emit Approval(_owner, _spender, _value);
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        return erc20Impl.approveWithSender(msg.sender, _spender, _value);
    }

    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool success) {
        return erc20Impl.increaseApprovalWithSender(msg.sender, _spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool success) {
        return erc20Impl.decreaseApprovalWithSender(msg.sender, _spender, _subtractedValue);
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return erc20Impl.allowance(_owner, _spender);
    }
}

contract ERC20Impl {

    ERC20Proxy public erc20Proxy;

    ERC20Store public erc20Store;

    function ERC20Impl(
        address _erc20Proxy,
        address _erc20Store
    )
    public
    {
        erc20Proxy = ERC20Proxy(_erc20Proxy);
        erc20Store = ERC20Store(_erc20Store);
    }

    modifier onlyProxy {
        require(msg.sender == address(erc20Proxy));
        _;
    }

    modifier onlyPayloadSize(uint size) {
        assert(msg.data.length == size + 4);
        _;
    }

    function approveWithSender(
        address _sender,
        address _spender,
        uint256 _value
    )
    public
    onlyProxy
    returns (bool success)
    {
        require(_spender != address(0));
        // disallow unspendable approvals
        erc20Store.setAllowance(_sender, _spender, _value);
        erc20Proxy.emitApproval(_sender, _spender, _value);
        return true;
    }

    function increaseApprovalWithSender(
        address _sender,
        address _spender,
        uint256 _addedValue
    )
    public
    onlyProxy
    returns (bool success)
    {
        require(_spender != address(0));
        // disallow unspendable approvals
        uint256 currentAllowance = erc20Store.allowed(_sender, _spender);
        uint256 newAllowance = currentAllowance + _addedValue;

        require(newAllowance >= currentAllowance);

        erc20Store.setAllowance(_sender, _spender, newAllowance);
        erc20Proxy.emitApproval(_sender, _spender, newAllowance);
        return true;
    }

    function decreaseApprovalWithSender(
        address _sender,
        address _spender,
        uint256 _subtractedValue
    )
    public
    onlyProxy
    returns (bool success)
    {
        require(_spender != address(0));
        // disallow unspendable approvals
        uint256 currentAllowance = erc20Store.allowed(_sender, _spender);
        uint256 newAllowance = currentAllowance - _subtractedValue;

        require(newAllowance <= currentAllowance);

        erc20Store.setAllowance(_sender, _spender, newAllowance);
        erc20Proxy.emitApproval(_sender, _spender, newAllowance);
        return true;
    }

    function transferFromWithSender(
        address _sender,
        address _from,
        address _to,
        uint256 _value
    )
    public
    onlyProxy onlyPayloadSize(4 * 32)
    returns (bool success)
    {
        require(_to != address(0));

        uint256 balanceOfFrom = erc20Store.balances(_from);
        require(_value <= balanceOfFrom);

        uint256 senderAllowance = erc20Store.allowed(_from, _sender);
        require(_value <= senderAllowance);

        erc20Store.setBalance(_from, balanceOfFrom - _value);
        erc20Store.addBalance(_to, _value);
        erc20Store.setAllowance(_from, _sender, senderAllowance - _value);
        erc20Proxy.emitTransfer(_from, _to, _value);

        return true;
    }

    function transferWithSender(
        address _sender,
        address _to,
        uint256 _value
    )
    public onlyProxy onlyPayloadSize(3 * 32)
    returns (bool success)
    {
        require(_to != address(0));

        uint256 balanceOfSender = erc20Store.balances(_sender);
        require(_value <= balanceOfSender);

        erc20Store.setBalance(_sender, balanceOfSender - _value);
        erc20Store.addBalance(_to, _value);

        erc20Proxy.emitTransfer(_sender, _to, _value);

        return true;
    }

    function totalSupply() public view returns (uint256) {
        return erc20Store.totalSupply();
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return erc20Store.balances(_owner);
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return erc20Store.allowed(_owner, _spender);
    }

}

contract ERC20Store is ERC20ImplUpgradeable, NianLunServiceUpgradeable {

    uint256 public totalSupply;
    uint256 public createDate;

    address public foundation;
    address public team;
    address public partner;
    address public transit;

    mapping(address => uint256) public balances;

    mapping(address => mapping(address => uint256)) public allowed;

    mapping(address => uint256) public availableMap;

    function ERC20Store(address _custodian, address _foundation, address _team, address _partner, address _transit)
    ERC20ImplUpgradeable(_custodian) NianLunServiceUpgradeable(_custodian)
    public
    {
        createDate = now;
        foundation = _foundation;
        partner = _partner;
        team = _team;
        transit = _transit;
        availableMap[foundation] = 15120000000000000;
        availableMap[partner] = 3360000000000000;
        availableMap[team] = 2520000000000000;
    }

    modifier onlyPermitted
    {
        require(
            msg.sender == address(nianLunService) ||
            msg.sender == address(erc20Impl)
        );
        _;
    }

    function setTotalSupply(uint256 _newTotalSupply)
    public onlyPermitted
    {
        totalSupply = _newTotalSupply;
    }

    function setAllowance(address _owner, address _spender, uint256 _value)
    public onlyImpl
    {
        allowed[_owner][_spender] = _value;
    }

    function setBalance(address _owner, uint256 _newBalance)
    public onlyPermitted
    {
        balances[_owner] = _newBalance;
    }

    function addBalance(address _owner, uint256 _balanceIncrease)
    public onlyPermitted
    {
        balances[_owner] = balances[_owner] + _balanceIncrease;
    }

    function reduceAvailable(address _owner, uint256 _value)
    public onlyNianLunService
    {
        availableMap[_owner] = availableMap[_owner] - _value;
    }

}

contract NianLunService is LockRequestable, CustodianUpgradeable {

    struct PendingService {
        address sender;
        uint256 value;
        bool isPrint;
    }

    ERC20Proxy public erc20Proxy;

    ERC20Store public erc20Store;

    mapping(address => bool) public primaryBank;

    mapping(bytes32 => PendingService) public pendingServiceMap;

    function NianLunService(address _erc20Proxy, address _erc20Store, address _custodian)
    CustodianUpgradeable(_custodian)
    public
    {
        erc20Proxy = ERC20Proxy(_erc20Proxy);
        erc20Store = ERC20Store(_erc20Store);
    }

    modifier onlyPrimary
    {
        require(primaryBank[address(msg.sender)]);
        _;
    }

    modifier onlyPayloadSize(uint size) {
        assert(msg.data.length == size + 4);
        _;
    }

    function addPrimary(address _newPrimary)
    public onlyCustodian
    {
        primaryBank[_newPrimary] = true;
        emit PrimaryChanged(_newPrimary, true);
    }

    function removePrimary(address _removePrimary)
    public onlyCustodian
    {
        delete primaryBank[_removePrimary];
        emit PrimaryChanged(_removePrimary, false);
    }

    function authTransfer(address _from, address _to, uint256 _value)
    public onlyPrimary onlyPayloadSize(3 * 32)
    returns (bool success)
    {
        require(_to != address(0));
        uint256 balanceOfFrom = erc20Store.balances(_from);
        require(_value <= balanceOfFrom);

        erc20Store.setBalance(_from, balanceOfFrom - _value);
        erc20Store.addBalance(_to, _value);

        erc20Proxy.emitTransfer(_from, _to, _value);
        return true;
    }

    function batchPublishService(address[] _senders, uint256[] _values, bool[] _isPrints)
    public onlyPrimary
    returns (bool success)
    {
        require(_senders.length == _values.length);
        require(_isPrints.length == _values.length);

        uint256 numPublish = _senders.length;
        for (uint256 i = 0; i < numPublish; i++) {
            publishService(_senders[i], _values[i], _isPrints[i]);
        }
        return true;
    }

    function publishService(address _sender, uint256 _value, bool _isPrint)
    public onlyPrimary onlyPayloadSize(3 * 32)
    {
        require(_sender != address(0));

        bytes32 lockId = generateLockId();

        pendingServiceMap[lockId] = PendingService({
            sender : _sender,
            value : _value,
            isPrint : _isPrint
            });

        if (_isPrint) {
            // print value to transit;
            erc20Store.setTotalSupply(erc20Store.totalSupply() + _value);
            erc20Proxy.emitTransfer(address(0), erc20Store.transit(), _value);
        } else {
            // transfer value from sender to transit
            uint256 balanceOfSender = erc20Store.balances(_sender);
            if (_value > balanceOfSender) {
                delete pendingServiceMap[lockId];
                emit ServicePublished(lockId, _sender, _value, false);
                return;
            }
            erc20Store.setBalance(_sender, balanceOfSender - _value);
            erc20Proxy.emitTransfer(_sender, erc20Store.transit(), _value);
        }
        erc20Store.addBalance(erc20Store.transit(), _value);
        emit ServicePublished(lockId, _sender, _value, true);
    }

    function batchConfirmService(bytes32[] _lockIds, uint256[] _values, address[] _tos)
    public onlyPrimary
    returns (bool result)
    {
        require(_lockIds.length == _values.length);
        require(_lockIds.length == _tos.length);

        uint256 numConfirms = _lockIds.length;
        for (uint256 i = 0; i < numConfirms; i++) {
            confirmService(_lockIds[i], _values[i], _tos[i]);
        }
        return true;
    }

    function confirmService(bytes32 _lockId, uint256 _value, address _to)
    public onlyPrimary
    {
        PendingService storage service = pendingServiceMap[_lockId];

        address _sender = service.sender;
        uint256 _availableValue = service.value;
        bool _isPrint = service.isPrint;

        if (_value > _availableValue) {
            emit ServiceConfirmed(_lockId, _sender, _to, _value, false);
            return;
        }

        uint256 _restValue = _availableValue - _value;

        if (_restValue == 0) {
            delete pendingServiceMap[_lockId];
        } else {
            service.value = _restValue;
        }

        if (_isPrint) {
            releaseFoundation(_value);
        }

        uint256 balanceOfTransit = erc20Store.balances(erc20Store.transit());
        erc20Store.setBalance(erc20Store.transit(), balanceOfTransit - _value);
        erc20Store.addBalance(_to, _value);
        erc20Proxy.emitTransfer(erc20Store.transit(), _to, _value);
        emit ServiceConfirmed(_lockId, _sender, _to, _value, true);
    }

    function releaseFoundation(uint256 _value)
    private
    {
        uint256 foundationAvailable = erc20Store.availableMap(erc20Store.foundation());
        if (foundationAvailable <= 0) {
            return;
        }
        if (foundationAvailable < _value) {
            _value = foundationAvailable;
        }
        erc20Store.addBalance(erc20Store.foundation(), _value);
        erc20Store.setTotalSupply(erc20Store.totalSupply() + _value);
        erc20Store.reduceAvailable(erc20Store.foundation(), _value);
        erc20Proxy.emitTransfer(address(0), erc20Store.foundation(), _value);
    }

    function batchCancelService(bytes32[] _lockIds)
    public onlyPrimary
    returns (bool result)
    {
        uint256 numCancels = _lockIds.length;
        for (uint256 i = 0; i < numCancels; i++) {
            cancelService(_lockIds[i]);
        }
        return true;
    }

    function cancelService(bytes32 _lockId)
    public onlyPrimary
    {
        PendingService storage service = pendingServiceMap[_lockId];
        address _sender = service.sender;
        uint256 _value = service.value;
        bool _isPrint = service.isPrint;

        delete pendingServiceMap[_lockId];

        if (_isPrint) {
            // burn
            erc20Store.setTotalSupply(erc20Store.totalSupply() - _value);
            erc20Proxy.emitTransfer(erc20Store.transit(), address(0), _value);
        } else {
            // send back
            erc20Store.addBalance(_sender, _value);
            erc20Proxy.emitTransfer(erc20Store.transit(), _sender, _value);
        }
        uint256 balanceOfTransit = erc20Store.balances(erc20Store.transit());
        erc20Store.setBalance(erc20Store.transit(), balanceOfTransit - _value);
        emit ServiceCanceled(_lockId, _sender, _value);
    }

    function queryService(bytes32 _lockId)
    public view
    returns (address _sender, uint256 _value, bool _isPrint)
    {
        PendingService storage service = pendingServiceMap[_lockId];
        _sender = service.sender;
        _value = service.value;
        _isPrint = service.isPrint;
    }

    function releaseTeam()
    public
    returns (bool success)
    {
        uint256 teamAvailable = erc20Store.availableMap(erc20Store.team());
        if (teamAvailable > 0 && now > erc20Store.createDate() + 3 * 1 years) {
            erc20Store.addBalance(erc20Store.team(), teamAvailable);
            erc20Store.setTotalSupply(erc20Store.totalSupply() + teamAvailable);
            erc20Store.reduceAvailable(erc20Store.team(), teamAvailable);
            erc20Proxy.emitTransfer(address(0), erc20Store.team(), teamAvailable);
            return true;
        }
        return false;
    }

    function releasePartner()
    public
    returns (bool success)
    {
        uint256 partnerAvailable = erc20Store.availableMap(erc20Store.partner());
        if (partnerAvailable > 0) {
            erc20Store.addBalance(erc20Store.partner(), partnerAvailable);
            erc20Store.setTotalSupply(erc20Store.totalSupply() + partnerAvailable);
            erc20Store.reduceAvailable(erc20Store.partner(), partnerAvailable);
            erc20Proxy.emitTransfer(address(0), erc20Store.partner(), partnerAvailable);
            return true;
        }
        return false;
    }

    event ServicePublished(bytes32 _lockId, address _sender, uint256 _value, bool _result);

    event ServiceConfirmed(bytes32 _lockId, address _sender, address _to, uint256 _value, bool _result);

    event ServiceCanceled(bytes32 _lockId, address _sender, uint256 _value);

    event PrimaryChanged(address _primary, bool opt);

}