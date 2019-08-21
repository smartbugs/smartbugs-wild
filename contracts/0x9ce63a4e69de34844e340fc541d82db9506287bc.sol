contract MultiAsset {
    function owner(bytes32 _symbol) constant returns(address);
    function isCreated(bytes32 _symbol) constant returns(bool);
    function totalSupply(bytes32 _symbol) constant returns(uint);
    function balanceOf(address _holder, bytes32 _symbol) constant returns(uint);
    function transfer(address _to, uint _value, bytes32 _symbol) returns(bool);
    function proxyTransferWithReference(address _to, uint _value, bytes32 _symbol, string _reference) returns(bool);
    function proxyTransferToICAPWithReference(bytes32 _icap, uint _value, string _reference) returns(bool);
    function proxyApprove(address _spender, uint _value, bytes32 _symbol) returns(bool);
    function allowance(address _from, address _spender, bytes32 _symbol) constant returns(uint);
    function proxyTransferFromWithReference(address _from, address _to, uint _value, bytes32 _symbol, string _reference) returns(bool);
    function proxyTransferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference) returns(bool);
    function proxySetCosignerAddress(address _address, bytes32 _symbol) returns(bool);
}

contract OpenDollar {
    event Transfer(address indexed from, address indexed to, uint value);
    event Approve(address indexed from, address indexed spender, uint value);

    MultiAsset public multiAsset;
    bytes32 public symbol;

    function init(address _multiAsset, bytes32 _symbol) returns(bool) {
        MultiAsset ma = MultiAsset(_multiAsset);
        if (address(multiAsset) != 0x0 || !ma.isCreated(_symbol)) {
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
        return transferWithReference(_to, _value, "");
    }

    function transferWithReference(address _to, uint _value, string _reference) returns(bool) {
        if (!multiAsset.proxyTransferWithReference(_to, _value, symbol, _reference)) {
            return false;
        }
        return true;
    }

    function transferToICAP(bytes32 _icap, uint _value) returns(bool) {
        return transferToICAPWithReference(_icap, _value, "");
    }

    function transferToICAPWithReference(bytes32 _icap, uint _value, string _reference) returns(bool) {
        if (!multiAsset.proxyTransferToICAPWithReference(_icap, _value, _reference)) {
            return false;
        }
        return true;
    }
    
    function transferFrom(address _from, address _to, uint _value) returns(bool) {
        return transferFromWithReference(_from, _to, _value, "");
    }

    function transferFromWithReference(address _from, address _to, uint _value, string _reference) returns(bool) {
        if (!multiAsset.proxyTransferFromWithReference(_from, _to, _value, symbol, _reference)) {
            return false;
        }
        return true;
    }

    function transferFromToICAP(address _from, bytes32 _icap, uint _value) returns(bool) {
        return transferFromToICAPWithReference(_from, _icap, _value, "");
    }

    function transferFromToICAPWithReference(address _from, bytes32 _icap, uint _value, string _reference) returns(bool) {
        if (!multiAsset.proxyTransferFromToICAPWithReference(_from, _icap, _value, _reference)) {
            return false;
        }
        return true;
    }

    function approve(address _spender, uint _value) returns(bool) {
        if (!multiAsset.proxyApprove(_spender, _value, symbol)) {
            return false;
        }
        return true;
    }

    function setCosignerAddress(address _cosigner) returns(bool) {
        if (!multiAsset.proxySetCosignerAddress(_cosigner, symbol)) {
            return false;
        }
        return true;
    }

    function emitTransfer(address _from, address _to, uint _value) onlyMultiAsset() {
        Transfer(_from, _to, _value);
    }

    function emitApprove(address _from, address _spender, uint _value) onlyMultiAsset() {
        Approve(_from, _spender, _value);
    }

    function sendToOwner() returns(bool) {
        return multiAsset.transfer(multiAsset.owner(symbol), balanceOf(address(this)), symbol);
    }
}