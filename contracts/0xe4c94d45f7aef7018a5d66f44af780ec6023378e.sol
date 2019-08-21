contract MultiAsset {
    function isCreated(bytes32 _symbol) constant returns(bool);
    function owner(bytes32 _symbol) constant returns(address);
    function totalSupply(bytes32 _symbol) constant returns(uint);
    function balanceOf(address _holder, bytes32 _symbol) constant returns(uint);
    function transfer(address _to, uint _value, bytes32 _symbol) returns(bool);
    function proxyTransferWithReference(address _to, uint _value, bytes32 _symbol, string _reference) returns(bool);
    function proxyTransferToICAPWithReference(bytes32 _icap, uint _value, string _reference) returns(bool);
    function proxyApprove(address _spender, uint _value, bytes32 _symbol) returns(bool);
    function allowance(address _from, address _spender, bytes32 _symbol) constant returns(uint);
    function transferFromWithReference(address _from, address _to, uint _value, bytes32 _symbol, string _reference) returns(bool);
    function transferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference) returns(bool);
    function proxyTransferFromWithReference(address _from, address _to, uint _value, bytes32 _symbol, string _reference) returns(bool);
    function proxyTransferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference) returns(bool);
    function proxySetCosignerAddress(address _address, bytes32 _symbol) returns(bool);
}

contract Ambi {
    function getNodeAddress(bytes32 _name) constant returns (address);
    function addNode(bytes32 _name, address _addr) external returns (bool);
    function hasRelation(bytes32 _from, bytes32 _role, address _to) constant returns (bool);
}

contract EtherTreasuryInterface {
    function withdraw(address _to, uint _value) returns(bool);
}

contract Safe {
    // Should always be placed as first modifier!
    modifier noValue {
        if (msg.value > 0) {
            // Internal Out Of Gas/Throw: revert this transaction too;
            // Call Stack Depth Limit reached: revert this transaction too;
            // Recursive Call: safe, no any changes applied yet, we are inside of modifier.
            _safeSend(msg.sender, msg.value);
        }
        _
    }

    modifier onlyHuman {
        if (_isHuman()) {
            _
        }
    }

    modifier noCallback {
        if (!isCall) {
            _
        }
    }

    modifier immutable(address _address) {
        if (_address == 0) {
            _
        }
    }

    address stackDepthLib;
    function setupStackDepthLib(address _stackDepthLib) immutable(address(stackDepthLib)) returns(bool) {
        stackDepthLib = _stackDepthLib;
        return true;
    }

    modifier requireStackDepth(uint16 _depth) {
        if (stackDepthLib == 0x0) {
            throw;
        }
        if (_depth > 1023) {
            throw;
        }
        if (!stackDepthLib.delegatecall(0x32921690, stackDepthLib, _depth)) {
            throw;
        }
        _
    }

    // Must not be used inside the functions that have noValue() modifier!
    function _safeFalse() internal noValue() returns(bool) {
        return false;
    }

    function _safeSend(address _to, uint _value) internal {
        if (!_unsafeSend(_to, _value)) {
            throw;
        }
    }

    function _unsafeSend(address _to, uint _value) internal returns(bool) {
        return _to.call.value(_value)();
    }

    function _isContract() constant internal returns(bool) {
        return msg.sender != tx.origin;
    }

    function _isHuman() constant internal returns(bool) {
        return !_isContract();
    }

    bool private isCall = false;
    function _setupNoCallback() internal {
        isCall = true;
    }

    function _finishNoCallback() internal {
        isCall = false;
    }
}

contract Asset is Safe {
    event Transfer(address indexed from, address indexed to, uint value);
    event Approve(address indexed from, address indexed spender, uint value);

    MultiAsset public multiAsset;
    bytes32 public symbol;

    function init(address _multiAsset, bytes32 _symbol) noValue() immutable(address(multiAsset)) returns(bool) {
        MultiAsset ma = MultiAsset(_multiAsset);
        if (!ma.isCreated(_symbol)) {
            return false;
        }
        multiAsset = ma;
        symbol = _symbol;
        return true;
    }

    modifier onlyMultiAsset() {
        if (msg.sender == address(multiAsset)) {
            _
        }
    }

    function totalSupply() constant returns(uint) {
        return multiAsset.totalSupply(symbol);
    }

    function balanceOf(address _owner) constant returns(uint) {
        return multiAsset.balanceOf(_owner, symbol);
    }

    function allowance(address _from, address _spender) constant returns(uint) {
        return multiAsset.allowance(_from, _spender, symbol);
    }

    function transfer(address _to, uint _value) returns(bool) {
        return __transferWithReference(_to, _value, "");
    }

    function transferWithReference(address _to, uint _value, string _reference) returns(bool) {
        return __transferWithReference(_to, _value, _reference);
    }

    function __transferWithReference(address _to, uint _value, string _reference) private noValue() returns(bool) {
        return _isHuman() ?
            multiAsset.proxyTransferWithReference(_to, _value, symbol, _reference) :
            multiAsset.transferFromWithReference(msg.sender, _to, _value, symbol, _reference);
    }

    function transferToICAP(bytes32 _icap, uint _value) returns(bool) {
        return __transferToICAPWithReference(_icap, _value, "");
    }

    function transferToICAPWithReference(bytes32 _icap, uint _value, string _reference) returns(bool) {
        return __transferToICAPWithReference(_icap, _value, _reference);
    }

    function __transferToICAPWithReference(bytes32 _icap, uint _value, string _reference) private noValue() returns(bool) {
        return _isHuman() ?
            multiAsset.proxyTransferToICAPWithReference(_icap, _value, _reference) :
            multiAsset.transferFromToICAPWithReference(msg.sender, _icap, _value, _reference);
    }
    
    function transferFrom(address _from, address _to, uint _value) returns(bool) {
        return __transferFromWithReference(_from, _to, _value, "");
    }

    function transferFromWithReference(address _from, address _to, uint _value, string _reference) returns(bool) {
        return __transferFromWithReference(_from, _to, _value, _reference);
    }

    function __transferFromWithReference(address _from, address _to, uint _value, string _reference) private noValue() onlyHuman() returns(bool) {
        return multiAsset.proxyTransferFromWithReference(_from, _to, _value, symbol, _reference);
    }

    function transferFromToICAP(address _from, bytes32 _icap, uint _value) returns(bool) {
        return __transferFromToICAPWithReference(_from, _icap, _value, "");
    }

    function transferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference) returns(bool) {
        return __transferFromToICAPWithReference(_from, _icap, _value, _reference);
    }

    function __transferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference) private noValue() onlyHuman() returns(bool) {
        return multiAsset.proxyTransferFromToICAPWithReference(_from, _icap, _value, _reference);
    }

    function approve(address _spender, uint _value) noValue() onlyHuman() returns(bool) {
        return multiAsset.proxyApprove(_spender, _value, symbol);
    }

    function setCosignerAddress(address _cosigner) noValue() onlyHuman() returns(bool) {
        return multiAsset.proxySetCosignerAddress(_cosigner, symbol);
    }

    function emitTransfer(address _from, address _to, uint _value) onlyMultiAsset() {
        Transfer(_from, _to, _value);
    }

    function emitApprove(address _from, address _spender, uint _value) onlyMultiAsset() {
        Approve(_from, _spender, _value);
    }

    function sendToOwner() noValue() returns(bool) {
        address owner = multiAsset.owner(symbol);
        uint balance = this.balance;
        bool success = true;
        if (balance > 0) {
            success = _unsafeSend(owner, balance);
        }
        return multiAsset.transfer(owner, balanceOf(owner), symbol) && success;
    }
}

contract AmbiEnabled {
    Ambi public ambiC;
    bool public isImmortal;
    bytes32 public name;

    modifier checkAccess(bytes32 _role) {
        if(address(ambiC) != 0x0 && ambiC.hasRelation(name, _role, msg.sender)){
            _
        }
    }
    
    function getAddress(bytes32 _name) constant returns (address) {
        return ambiC.getNodeAddress(_name);
    }

    function setAmbiAddress(address _ambi, bytes32 _name) returns (bool){
        if(address(ambiC) != 0x0){
            return false;
        }
        Ambi ambiContract = Ambi(_ambi);
        if(ambiContract.getNodeAddress(_name)!=address(this)) {
            if (!ambiContract.addNode(_name, address(this))){
                return false;
            }
        }
        name = _name;
        ambiC = ambiContract;
        return true;
    }

    function immortality() checkAccess("owner") returns(bool) {
        isImmortal = true;
        return true;
    }

    function remove() checkAccess("owner") returns(bool) {
        if (isImmortal) {
            return false;
        }
        selfdestruct(msg.sender);
        return true;
    }
}

contract CryptoCarbon is Asset, AmbiEnabled {
    uint public txGasPriceLimit = 21000000000;
    uint public refundGas = 40000;
    uint public transferCallGas = 21000;
    uint public transferWithReferenceCallGas = 21000;
    uint public transferFromCallGas = 21000;
    uint public transferFromWithReferenceCallGas = 21000;
    uint public transferToICAPCallGas = 21000;
    uint public transferToICAPWithReferenceCallGas = 21000;
    uint public transferFromToICAPCallGas = 21000;
    uint public transferFromToICAPWithReferenceCallGas = 21000;
    uint public approveCallGas = 21000;
    uint public forwardCallGas = 21000;
    uint public setCosignerCallGas = 21000;
    uint public absMinFee;
    uint public feePercent; // set up in 1/100 of percent, 10 is 0.1%
    uint public absMaxFee;
    EtherTreasuryInterface public treasury;
    address public feeAddress;
    bool private __isAllowed;
    mapping(bytes32 => address) public allowedForwards;

    function setFeeStructure(uint _absMinFee, uint _feePercent, uint _absMaxFee) noValue() checkAccess("cron") returns (bool) {
        if(_feePercent > 10000 || _absMaxFee < _absMinFee) {
            return false;
        }
        absMinFee = _absMinFee;
        feePercent = _feePercent;
        absMaxFee = _absMaxFee;
        return true;
    }

    function setupFee(address _feeAddress) noValue() checkAccess("admin") returns(bool) {
        feeAddress = _feeAddress;
        return true;
    }

    function updateRefundGas() noValue() checkAccess("setup") returns(uint) {
        uint startGas = msg.gas;
        // just to simulate calculations
        uint refund = (startGas - msg.gas + refundGas) * tx.gasprice;
        if (tx.gasprice > txGasPriceLimit) {
            return 0;
        }
        // end
        if (!_refund(5000000000000000)) {
            return 0;
        }
        refundGas = startGas - msg.gas;
        return refundGas;
    }

    function setOperationsCallGas(
        uint _transfer,
        uint _transferFrom,
        uint _transferToICAP,
        uint _transferFromToICAP,
        uint _transferWithReference,
        uint _transferFromWithReference,
        uint _transferToICAPWithReference,
        uint _transferFromToICAPWithReference,
        uint _approve,
        uint _forward,
        uint _setCosigner
    )
        noValue()
        checkAccess("setup")
        returns(bool)
    {
        transferCallGas = _transfer;
        transferFromCallGas = _transferFrom;
        transferToICAPCallGas = _transferToICAP;
        transferFromToICAPCallGas = _transferFromToICAP;
        transferWithReferenceCallGas = _transferWithReference;
        transferFromWithReferenceCallGas = _transferFromWithReference;
        transferToICAPWithReferenceCallGas = _transferToICAPWithReference;
        transferFromToICAPWithReferenceCallGas = _transferFromToICAPWithReference;
        approveCallGas = _approve;
        forwardCallGas = _forward;
        setCosignerCallGas = _setCosigner;
        return true;
    }

    function setupTreasury(address _treasury, uint _txGasPriceLimit) checkAccess("admin") returns(bool) {
        if (_txGasPriceLimit == 0) {
            return _safeFalse();
        }
        treasury = EtherTreasuryInterface(_treasury);
        txGasPriceLimit = _txGasPriceLimit;
        if (msg.value > 0) {
            _safeSend(_treasury, msg.value);
        }
        return true;
    }

    function setForward(bytes4 _msgSig, address _forward) noValue() checkAccess("admin") returns(bool) {
        allowedForwards[sha3(_msgSig)] = _forward;
        return true;
    }

    function _stringGas(string _string) constant internal returns(uint) {
        return bytes(_string).length * 75; // ~75 gas per byte, empirical shown 68-72.
    }

    function _transferFee(address _feeFrom, uint _value, string _reference) internal returns(bool) {
        if (feeAddress == 0x0 || feeAddress == _feeFrom || _value == 0) {
            return true;
        }
        return multiAsset.transferFromWithReference(_feeFrom, feeAddress, _value, symbol, _reference);
    }

    function _returnFee(address _to, uint _value) internal returns(bool, bool) {
        if (feeAddress == 0x0 || feeAddress == _to || _value == 0) {
            return (false, true);
        }
        if (!multiAsset.transferFromWithReference(feeAddress, _to, _value, symbol, "Fee return")) {
            throw;
        }
        return (false, true);
    }

    function _applyRefund(uint _startGas) internal returns(bool) {
        uint refund = (_startGas - msg.gas + refundGas) * tx.gasprice;
        return _refund(refund);
    }

    function _refund(uint _value) internal returns(bool) {
        if (tx.gasprice > txGasPriceLimit) {
            return false;
        }
        return treasury.withdraw(tx.origin, _value);
    }

    function _allow() internal {
        __isAllowed = true;
    }

    function _disallow() internal {
        __isAllowed = false;
    }

    function calculateFee(uint _value) constant returns(uint) {
        uint fee = (_value * feePercent) / 10000;
        if (fee < absMinFee) {
            return absMinFee;
        }
        if (fee > absMaxFee) {
            return absMaxFee;
        }
        return fee;
    }

    function calculateFeeDynamic(uint _value, uint _additionalGas) constant returns(uint) {
        uint fee = calculateFee(_value);
        if (_additionalGas <= 7500) {
            return fee;
        }
        // Assuming that absMinFee covers at least 100000 gas refund, let's add another absMinFee
        // for every other 100000 additional gas.
        uint additionalFee = ((_additionalGas / 100000) + 1) * absMinFee;
        return fee + additionalFee;
    }

    function takeFee(address _feeFrom, uint _value, string _reference) noValue() checkAccess("fee") returns(bool) {
        return _transferFee(_feeFrom, _value, _reference);
    }

    function _transfer(address _to, uint _value) internal returns(bool, bool) {
        uint startGas = msg.gas + transferCallGas;
        uint fee = calculateFee(_value);
        if (!_transferFee(msg.sender, fee, "Transfer fee")) {
            return (false, false);
        }
        _allow();
        bool success = super.transfer(_to, _value);
        _disallow();
        if (!success) {
            return _returnFee(msg.sender, fee);
        }
        return (true, _applyRefund(startGas));
    }

    function _transferFrom(address _from, address _to, uint _value) internal returns(bool, bool) {
        uint startGas = msg.gas + transferFromCallGas;
        _allow();
        uint fee = calculateFee(_value);
        if (!_transferFee(_from, fee, "Transfer fee")) {
            return (false, false);
        }
        _allow();
        bool success = super.transferFrom(_from, _to, _value);
        _disallow();
        if (!success) {
            return _returnFee(_from, fee);
        }
        return (true, _applyRefund(startGas));
    }

    function _transferToICAP(bytes32 _icap, uint _value) internal returns(bool, bool) {
        uint startGas = msg.gas + transferToICAPCallGas;
        uint fee = calculateFee(_value);
        if (!_transferFee(msg.sender, fee, "Transfer fee")) {
            return (false, false);
        }
        _allow();
        bool success = super.transferToICAP(_icap, _value);
        _disallow();
        if (!success) {
            return _returnFee(msg.sender, fee);
        }
        return (true, _applyRefund(startGas));
    }

    function _transferFromToICAP(address _from, bytes32 _icap, uint _value) internal returns(bool, bool) {
        uint startGas = msg.gas + transferFromToICAPCallGas;
        uint fee = calculateFee(_value);
        if (!_transferFee(_from, fee, "Transfer fee")) {
            return (false, false);
        }
        _allow();
        bool success = super.transferFromToICAP(_from, _icap, _value);
        _disallow();
        if (!success) {
            return _returnFee(_from, fee);
        }
        return (true, _applyRefund(startGas));
    }

    function _transferWithReference(address _to, uint _value, string _reference) internal returns(bool, bool) {
        uint startGas = msg.gas + transferWithReferenceCallGas;
        uint additionalGas = _stringGas(_reference);
        uint fee = calculateFeeDynamic(_value, additionalGas);
        if (!_transferFee(msg.sender, fee, "Transfer fee")) {
            return (false, false);
        }
        _allow();
        bool success = super.transferWithReference(_to, _value, _reference);
        _disallow();
        if (!success) {
            return _returnFee(msg.sender, fee);
        }
        return (true, _applyRefund(startGas + additionalGas));
    }

    function _transferFromWithReference(address _from, address _to, uint _value, string _reference) internal returns(bool, bool) {
        uint startGas = msg.gas + transferFromWithReferenceCallGas;
        uint additionalGas = _stringGas(_reference);
        uint fee = calculateFeeDynamic(_value, additionalGas);
        if (!_transferFee(_from, fee, "Transfer fee")) {
            return (false, false);
        }
        _allow();
        bool success = super.transferFromWithReference(_from, _to, _value, _reference);
        _disallow();
        if (!success) {
            return _returnFee(_from, fee);
        }
        return (true, _applyRefund(startGas + additionalGas));
    }

    function _transferToICAPWithReference(bytes32 _icap, uint _value, string _reference) internal returns(bool, bool) {
        uint startGas = msg.gas + transferToICAPWithReferenceCallGas;
        uint additionalGas = _stringGas(_reference);
        uint fee = calculateFeeDynamic(_value, additionalGas);
        if (!_transferFee(msg.sender, fee, "Transfer fee")) {
            return (false, false);
        }
        _allow();
        bool success = super.transferToICAPWithReference(_icap, _value, _reference);
        _disallow();
        if (!success) {
            return _returnFee(msg.sender, fee);
        }
        return (true, _applyRefund(startGas + additionalGas));
    }

    function _transferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference) internal returns(bool, bool) {
        uint startGas = msg.gas + transferFromToICAPWithReferenceCallGas;
        uint additionalGas = _stringGas(_reference);
        uint fee = calculateFeeDynamic(_value, additionalGas);
        if (!_transferFee(_from, fee, "Transfer fee")) {
            return (false, false);
        }
        _allow();
        bool success = super.transferFromToICAPWithReference(_from, _icap, _value, _reference);
        _disallow();
        if (!success) {
            return _returnFee(_from, fee);
        }
        return (true, _applyRefund(startGas + additionalGas));
    }

    function _approve(address _spender, uint _value) internal returns(bool, bool) {
        uint startGas = msg.gas + approveCallGas;
        // Don't take fee when enabling fee taking.
        // Don't refund either.
        if (_spender == address(this)) {
            return (super.approve(_spender, _value), false);
        }
        uint fee = calculateFee(0);
        if (!_transferFee(msg.sender, fee, "Approve fee")) {
            return (false, false);
        }
        _allow();
        bool success = super.approve(_spender, _value);
        _disallow();
        if (!success) {
            return _returnFee(msg.sender, fee);
        }
        return (true, _applyRefund(startGas));
    }

    function _setCosignerAddress(address _cosigner) internal returns(bool, bool) {
        uint startGas = msg.gas + setCosignerCallGas;
        uint fee = calculateFee(0);
        if (!_transferFee(msg.sender, fee, "Cosigner fee")) {
            return (false, false);
        }
        if (!super.setCosignerAddress(_cosigner)) {
            return _returnFee(msg.sender, fee);
        }
        return (true, _applyRefund(startGas));
    }

    function transfer(address _to, uint _value) returns(bool) {
        bool success;
        (success,) = _transfer(_to, _value);
        return success;
    }

    function transferFrom(address _from, address _to, uint _value) returns(bool) {
        bool success;
        (success,) = _transferFrom(_from, _to, _value);
        return success;
    }

    function transferToICAP(bytes32 _icap, uint _value) returns(bool) {
        bool success;
        (success,) = _transferToICAP(_icap, _value);
        return success;
    }

    function transferFromToICAP(address _from, bytes32 _icap, uint _value) returns(bool) {
        bool success;
        (success,) = _transferFromToICAP(_from, _icap, _value);
        return success;
    }

    function transferWithReference(address _to, uint _value, string _reference) returns(bool) {
        bool success;
        (success,) = _transferWithReference(_to, _value, _reference);
        return success;
    }

    function transferFromWithReference(address _from, address _to, uint _value, string _reference) returns(bool) {
        bool success;
        (success,) = _transferFromWithReference(_from, _to, _value, _reference);
        return success;
    }

    function transferToICAPWithReference(bytes32 _icap, uint _value, string _reference) returns(bool) {
        bool success;
        (success,) = _transferToICAPWithReference(_icap, _value, _reference);
        return success;
    }

    function transferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference) returns(bool) {
        bool success;
        (success,) = _transferFromToICAPWithReference(_from, _icap, _value, _reference);
        return success;
    }

    function approve(address _spender, uint _value) returns(bool) {
        bool success;
        (success,) = _approve(_spender, _value);
        return success;
    }

    function setCosignerAddress(address _cosigner) returns(bool) {
        bool success;
        (success,) = _setCosignerAddress(_cosigner);
        return success;
    }

    function checkTransfer(address _to, uint _value) constant returns(bool, bool) {
        return _transfer(_to, _value);
    }

    function checkTransferFrom(address _from, address _to, uint _value) constant returns(bool, bool) {
        return _transferFrom(_from, _to, _value);
    }

    function checkTransferToICAP(bytes32 _icap, uint _value) constant returns(bool, bool) {
        return _transferToICAP(_icap, _value);
    }

    function checkTransferFromToICAP(address _from, bytes32 _icap, uint _value) constant returns(bool, bool) {
        return _transferFromToICAP(_from, _icap, _value);
    }

    function checkTransferWithReference(address _to, uint _value, string _reference) constant returns(bool, bool) {
        return _transferWithReference(_to, _value, _reference);
    }

    function checkTransferFromWithReference(address _from, address _to, uint _value, string _reference) constant returns(bool, bool) {
        return _transferFromWithReference(_from, _to, _value, _reference);
    }

    function checkTransferToICAPWithReference(bytes32 _icap, uint _value, string _reference) constant returns(bool, bool) {
        return _transferToICAPWithReference(_icap, _value, _reference);
    }

    function checkTransferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference) constant returns(bool, bool) {
        return _transferFromToICAPWithReference(_from, _icap, _value, _reference);
    }

    function checkApprove(address _spender, uint _value) constant returns(bool, bool) {
        return _approve(_spender, _value);
    }

    function checkSetCosignerAddress(address _cosigner) constant returns(bool, bool) {
        return _setCosignerAddress(_cosigner);
    }

    function checkForward(bytes _data) constant returns(bool, bool) {
        return _forward(allowedForwards[sha3(_data[0], _data[1], _data[2], _data[3])], _data);
    }

    function _forward(address _to, bytes _data) internal returns(bool, bool) {
        uint startGas = msg.gas + forwardCallGas;
        uint additionalGas = (_data.length * 50);  // 50 gas per byte;
        if (_to == 0x0) {
            return (false, _safeFalse());
        }
        uint fee = calculateFeeDynamic(0, additionalGas);
        if (!_transferFee(msg.sender, fee, "Forward fee")) {
            return (false, false);
        }
        if (!_to.call.value(msg.value)(_data)) {
            _returnFee(msg.sender, fee);
            return (false, _safeFalse());
        }
        return (true, _applyRefund(startGas + additionalGas));
    }

    function () returns(bool) {
        bool success;
        (success,) = _forward(allowedForwards[sha3(msg.sig)], msg.data);
        return success;
    }

    function emitTransfer(address _from, address _to, uint _value) onlyMultiAsset() {
        Transfer(_from, _to, _value);
        if (__isAllowed) {
            return;
        }
        if (feeAddress == 0x0 || _to == feeAddress || _from == feeAddress) {
            return;
        }
        if (_transferFee(_from, calculateFee(_value), "Transfer fee")) {
            return;
        }
        throw;
    }

    function emitApprove(address _from, address _spender, uint _value) onlyMultiAsset() {
        Approve(_from, _spender, _value);
        if (__isAllowed) {
            return;
        }
        if (feeAddress == 0x0 || _spender == address(this)) {
            return;
        }
        if (_transferFee(_from, calculateFee(0), "Approve fee")) {
            return;
        }
        throw;
    }
}