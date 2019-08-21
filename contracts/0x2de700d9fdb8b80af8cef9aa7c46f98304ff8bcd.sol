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

contract KUNA_SHARES is Safe {
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