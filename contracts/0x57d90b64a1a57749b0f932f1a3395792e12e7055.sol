contract Ambi {
    function getNodeAddress(bytes32 _name) constant returns (address);
    function addNode(bytes32 _name, address _addr) external returns (bool);
    function hasRelation(bytes32 _from, bytes32 _role, address _to) constant returns (bool);
}

contract PotRewards {
    function transfer(address _from, address _to, uint _amount);
}

contract PosRewards {
    function transfer(address _from, address _to);
}

contract ElcoinInterface {
    function rewardTo(address _to, uint _amount) returns (bool);
}

contract EtherTreasuryInterface {
    function withdraw(address _to, uint _value) returns(bool);
}

contract MetaCoinInterface {
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approved(address indexed _owner, address indexed _spender, uint256 _value);
	event Unapproved(address indexed _owner, address indexed _spender);

	function totalSupply() constant returns (uint256 supply){}
	function balanceOf(address _owner) constant returns (uint256 balance){}
	function transfer(address _to, uint256 _value) returns (bool success){}
	function transferFrom(address _from, address _to, uint256 _value) returns (bool success){}
	function approve(address _spender, uint256 _value) returns (bool success){}
	function unapprove(address _spender) returns (bool success){}
	function allowance(address _owner, address _spender) constant returns (uint256 remaining){}
}

contract ElcoinDb {
    function getBalance(address addr) constant returns(uint balance);
    function deposit(address addr, uint amount, bytes32 hash, uint time) returns (bool res);
    function withdraw(address addr, uint amount, bytes32 hash, uint time) returns (bool res);
}

contract AmbiEnabled {
    Ambi ambiC;
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
            bool isNode = ambiContract.addNode(_name, address(this));
            if (!isNode){
                return false;
            }   
        }
        name = _name;
        ambiC = ambiContract;
        return true;
    }

    function remove() checkAccess("owner") {
        suicide(msg.sender);
    }
}

contract Elcoin is AmbiEnabled, MetaCoinInterface {

    event Error(uint8 indexed code, address indexed origin, address indexed sender);

    mapping (address => uint) public recoveredIndex;
    address[] public recovered;

    uint public totalSupply;
    uint public absMinFee; // set up in 1/1000000 of Elcoin
    uint public feePercent; // set up in 1/100 of percent, 10 is 0.1%
    uint public absMaxFee; // set up in 1/1000000 of Elcoin
    address public feeAddr;

    function Elcoin() {
        recovered.length++;
        feeAddr = tx.origin;
        _setFeeStructure(0, 0, 1);
    }

    function _db() internal constant returns (ElcoinDb) {
        return ElcoinDb(getAddress("elcoinDb"));
    }

    function _setFeeStructure(uint _absMinFee, uint _feePercent, uint _absMaxFee) internal returns (bool) {
        if(_absMinFee < 0 || _feePercent < 0 || _feePercent > 10000 || _absMaxFee < 0 || _absMaxFee < _absMinFee) {
            Error(1, tx.origin, msg.sender);
            return false;
        }
        absMinFee = _absMinFee;
        feePercent = _feePercent;
        absMaxFee = _absMaxFee;
        return true;
    }

    function _rawTransfer(ElcoinDb _db, address _from, address _to, uint _value) internal {
        _db.withdraw(_from, _value, 0, 0);
        uint fee = calculateFee(_value);
        uint net = _value - fee;
        _db.deposit(_to, net, 0, 0);

        Transfer(_from, _to, _value);
        if (fee > 0) {
            _db.deposit(feeAddr, fee, 0, 0);
        }
    }

    function _transfer(ElcoinDb _db, address _from, address _to, uint _value) internal returns (bool) {
        if (_value < absMinFee) {
            return false;
        }
        if (_from == _to) {
            return false;
        }
        uint balance = _db.getBalance(_from);

        if (balance < _value) {
            return false;
        }
        _rawTransfer(_db, _from, _to, _value);

        return true;
    }

    function _transferWithReward(ElcoinDb _db, address _from, address _to, uint _value) internal returns (bool) {
        if (!_transfer(_db, _from, _to, _value)) {
            Error(2, tx.origin, msg.sender);
            return false;
        }

        address pos = getAddress("elcoinPoS");
        address pot = getAddress("elcoinPoT");
        if (pos != 0x0) {
            PosRewards(pos).transfer(_from, _to);
        }
        if (pot != 0x0) {
            PotRewards(pot).transfer(_from, _to, _value);
        }
        return true;
    }

    function _recoverAccount(ElcoinDb _db, address _old, address _new) internal returns (bool) {
        uint pos =  recovered.length++;
        recovered[pos] = _old;
        recoveredIndex[_old] = pos;
        uint balance = _db.getBalance(_old);
        var rv = _db.withdraw(_old, balance, 0, 0);
        if (!rv) {
            Error(5, tx.origin, msg.sender);
            return false;
        }
        _db.deposit(_new, balance, 0, 0);

        return true;
    }

    modifier notRecoveredAccount(address _account) {
        if(recoveredIndex[_account] == 0x0) {
            _
        }
        else {
            return;
        }
    }

    function balanceOf(address _account) constant returns (uint) {
        return _db().getBalance(_account);
    }

    function calculateFee(uint _amount) constant returns (uint) {
        uint fee = (_amount * feePercent) / 10000;

        if (fee < absMinFee) {
            return absMinFee;
        }

        if (fee > absMaxFee) {
            return absMaxFee;
        }

        return fee;
    }

    function issueCoin(address _to, uint _value, uint _totalSupply) checkAccess("currencyOwner") returns (bool) {
        if (totalSupply > 0) {
            Error(6, tx.origin, msg.sender);
            return false;
        }

        bool dep = _db().deposit(_to, _value, 0, 0);
        totalSupply = _totalSupply;
        return dep;
    }

    function batchTransfer(address[] _to, uint[] _value) checkAccess("currencyOwner") returns (bool) {
        if (_to.length != _value.length) {
            Error(7, tx.origin, msg.sender);
            return false;
        }

        uint totalToSend = 0;
        for (uint8 i = 0; i < _value.length; i++) {
            totalToSend += _value[i];
        }

        ElcoinDb db = _db();
        if (db.getBalance(msg.sender) < totalToSend) {
            Error(8, tx.origin, msg.sender);
            return false;
        }

        db.withdraw(msg.sender, totalToSend, 0, 0);
        for (uint8 j = 0; j < _to.length; j++) {
            db.deposit(_to[j], _value[j], 0, 0);
            Transfer(msg.sender, _to[j], _value[j]);
        }

        return true;
    }

    function transfer(address _to, uint _value) returns (bool) {
        uint startGas = msg.gas + transferCallGas;
        if (!_transferWithReward(_db(), msg.sender, _to, _value)) {
            return false;
        }
        uint refund = (startGas - msg.gas + refundGas) * tx.gasprice;
        return _refund(refund);
    }

    function transferPool(address _from, address _to, uint _value) checkAccess("pool") returns (bool) {
        return _transferWithReward(_db(), _from, _to, _value);
    }

    function rewardTo(address _to, uint _amount) checkAccess("reward") returns (bool) {
        bool result = _db().deposit(_to, _amount, 0, 0);
        if (result) {
            totalSupply += _amount;
        }

        return result;
    }

    function recoverAccount(address _old, address _new) checkAccess("recovery") notRecoveredAccount(_old) returns (bool) {
        return _recoverAccount(_db(), _old, _new);
    }

    function setFeeAddr(address _feeAddr) checkAccess("currencyOwner") {
        feeAddr = _feeAddr;
    }

    function setFee(uint _absMinFee, uint _feePercent, uint _absMaxFee) checkAccess("cron") returns (bool) {
        return _setFeeStructure(_absMinFee, _feePercent, _absMaxFee);
    }

    uint public txGasPriceLimit = 21000000000;
    uint public transferCallGas = 21000;
    uint public refundGas = 15000;
    EtherTreasuryInterface treasury;

    function setupTreasury(address _treasury, uint _txGasPriceLimit) checkAccess("currencyOwner") returns (bool) {
        if (_txGasPriceLimit == 0) {
            return false;
        }
        treasury = EtherTreasuryInterface(_treasury);
        txGasPriceLimit = _txGasPriceLimit;
        if (msg.value > 0 && !address(treasury).send(msg.value)) {
            throw;
        }
        return true;
    }

    function updateRefundGas() checkAccess("currencyOwner") returns (uint) {
        uint startGas = msg.gas;
        uint refund = (startGas - msg.gas + refundGas) * tx.gasprice; // just to simulate calculations, dunno if optimizer will remove this.
        if (!_refund(1)) {
            return 0;
        }
        refundGas = startGas - msg.gas;
        return refundGas;
    }

    function setOperationsCallGas(uint _transfer) checkAccess("currencyOwner") returns (bool) {
        transferCallGas = _transfer;
        return true;
    }

    function _refund(uint _value) internal returns (bool) {
        if (tx.gasprice > txGasPriceLimit) {
            return false;
        }
        return treasury.withdraw(tx.origin, _value);
    }
}