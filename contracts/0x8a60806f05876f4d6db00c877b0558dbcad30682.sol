pragma solidity ^0.4.16;

// copyright contact@Etheremon.com

contract SafeMath {

    /* function assert(bool assertion) internal { */
    /*   if (!assertion) { */
    /*     throw; */
    /*   } */
    /* }      // assert no longer needed once solidity is on 0.4.10 */

    function safeAdd(uint256 x, uint256 y) pure internal returns(uint256) {
      uint256 z = x + y;
      assert((z >= x) && (z >= y));
      return z;
    }

    function safeSubtract(uint256 x, uint256 y) pure internal returns(uint256) {
      assert(x >= y);
      uint256 z = x - y;
      return z;
    }

    function safeMult(uint256 x, uint256 y) pure internal returns(uint256) {
      uint256 z = x * y;
      assert((x == 0)||(z/x == y));
      return z;
    }

}

contract BasicAccessControl {
    address public owner;
    address[] public moderators;

    function BasicAccessControl() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyModerators() {
        if (msg.sender != owner) {
            bool found = false;
            for (uint index = 0; index < moderators.length; index++) {
                if (moderators[index] == msg.sender) {
                    found = true;
                    break;
                }
            }
            require(found);
        }
        _;
    }

    function ChangeOwner(address _newOwner) onlyOwner public {
        if (_newOwner != address(0)) {
            owner = _newOwner;
        }
    }

    function Kill() onlyOwner public {
        selfdestruct(owner);
    }

    function AddModerator(address _newModerator) onlyOwner public {
        if (_newModerator != address(0)) {
            for (uint index = 0; index < moderators.length; index++) {
                if (moderators[index] == _newModerator) {
                    return;
                }
            }
            moderators.push(_newModerator);
        }
    }
    
    function RemoveModerator(address _oldModerator) onlyOwner public {
        uint foundIndex = 0;
        for (; foundIndex < moderators.length; foundIndex++) {
            if (moderators[foundIndex] == _oldModerator) {
                break;
            }
        }
        if (foundIndex < moderators.length) {
            moderators[foundIndex] = moderators[moderators.length-1];
            delete moderators[moderators.length-1];
            moderators.length--;
        }
    }
}


contract EtheremonEnum {

    enum ResultCode {
        SUCCESS,
        ERROR_CLASS_NOT_FOUND,
        ERROR_LOW_BALANCE,
        ERROR_SEND_FAIL,
        ERROR_NOT_TRAINER,
        ERROR_NOT_ENOUGH_MONEY,
        ERROR_INVALID_AMOUNT
    }
    
    enum ArrayType {
        CLASS_TYPE,
        STAT_STEP,
        STAT_START,
        STAT_BASE,
        OBJ_SKILL
    }
}

contract EtheremonDataBase is EtheremonEnum, BasicAccessControl, SafeMath {
    
    uint64 public totalMonster;
    uint32 public totalClass;
    
    // write
    function addElementToArrayType(ArrayType _type, uint64 _id, uint8 _value) onlyModerators public returns(uint);
    function removeElementOfArrayType(ArrayType _type, uint64 _id, uint8 _value) onlyModerators public returns(uint);
    function setMonsterClass(uint32 _classId, uint256 _price, uint256 _returnPrice, bool _catchable) onlyModerators public returns(uint32);
    function addMonsterObj(uint32 _classId, address _trainer, string _name) onlyModerators public returns(uint64);
    function setMonsterObj(uint64 _objId, string _name, uint32 _exp, uint32 _createIndex, uint32 _lastClaimIndex) onlyModerators public;
    function increaseMonsterExp(uint64 _objId, uint32 amount) onlyModerators public;
    function decreaseMonsterExp(uint64 _objId, uint32 amount) onlyModerators public;
    function removeMonsterIdMapping(address _trainer, uint64 _monsterId) onlyModerators public;
    function addMonsterIdMapping(address _trainer, uint64 _monsterId) onlyModerators public;
    function clearMonsterReturnBalance(uint64 _monsterId) onlyModerators public returns(uint256 amount);
    function collectAllReturnBalance(address _trainer) onlyModerators public returns(uint256 amount);
    function transferMonster(address _from, address _to, uint64 _monsterId) onlyModerators public returns(ResultCode);
    function addExtraBalance(address _trainer, uint256 _amount) onlyModerators public returns(uint256);
    function deductExtraBalance(address _trainer, uint256 _amount) onlyModerators public returns(uint256);
    function setExtraBalance(address _trainer, uint256 _amount) onlyModerators public;
    
    // read
    function getSizeArrayType(ArrayType _type, uint64 _id) constant public returns(uint);
    function getElementInArrayType(ArrayType _type, uint64 _id, uint _index) constant public returns(uint8);
    function getMonsterClass(uint32 _classId) constant public returns(uint32 classId, uint256 price, uint256 returnPrice, uint32 total, bool catchable);
    function getMonsterObj(uint64 _objId) constant public returns(uint64 objId, uint32 classId, address trainer, uint32 exp, uint32 createIndex, uint32 lastClaimIndex, uint createTime);
    function getMonsterName(uint64 _objId) constant public returns(string name);
    function getExtraBalance(address _trainer) constant public returns(uint256);
    function getMonsterDexSize(address _trainer) constant public returns(uint);
    function getMonsterObjId(address _trainer, uint index) constant public returns(uint64);
    function getExpectedBalance(address _trainer) constant public returns(uint256);
    function getMonsterReturn(uint64 _objId) constant public returns(uint256 current, uint256 total);
}

contract EtheremonProcessor is EtheremonEnum, BasicAccessControl, SafeMath {
    
    uint8 public STAT_COUNT = 6;
    uint8 public STAT_MAX = 32;
    
    struct MonsterClassAcc {
        uint32 classId;
        uint256 price;
        uint256 returnPrice;
        uint32 total;
        bool catchable;
    }

    struct MonsterObjAcc {
        uint64 monsterId;
        uint32 classId;
        address trainer;
        string name;
        uint32 exp;
        uint32 createIndex;
        uint32 lastClaimIndex;
        uint createTime;
    }
    
    // data contract
    address public dataContract;
    
    function EtheremonProcessor(address _dataContract) public {
        dataContract = _dataContract;
    }

    // internal
    modifier requireDataContract {
        require(dataContract != 0x0);
        _;
    }
    

    // event
    event EventCatchMonster(address indexed trainer, ResultCode result, uint64 objId);
    event EventCashOut(address indexed trainer, ResultCode result, uint256 amount);
    event EventWithdrawEther(address indexed sendTo, ResultCode result, uint256 amount);
 
     // admin
    function withdrawEther(address _sendTo, uint _amount) onlyOwner public returns(ResultCode) {
        if (_amount > this.balance) {
            EventWithdrawEther(_sendTo, ResultCode.ERROR_INVALID_AMOUNT, 0);
            return ResultCode.ERROR_INVALID_AMOUNT;
        }
        
        _sendTo.transfer(_amount);
        EventWithdrawEther(_sendTo, ResultCode.SUCCESS, _amount);
        return ResultCode.SUCCESS;
    }
    
    function setDataContract(address _dataContract) onlyModerators public {
        dataContract = _dataContract;
    }
    
    function addMonsterClassBasic(uint32 _classId, uint8 _type, uint256 _price, uint256 _returnPrice,
        uint8 _ss1, uint8 _ss2, uint8 _ss3, uint8 _ss4, uint8 _ss5, uint8 _ss6) onlyModerators public {
            
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        data.setMonsterClass(_classId, _price, _returnPrice, true);
        data.addElementToArrayType(ArrayType.CLASS_TYPE, uint64(_classId), _type);
        
        // add stat step
        data.addElementToArrayType(ArrayType.STAT_START, uint64(_classId), _ss1);
        data.addElementToArrayType(ArrayType.STAT_START, uint64(_classId), _ss2);
        data.addElementToArrayType(ArrayType.STAT_START, uint64(_classId), _ss3);
        data.addElementToArrayType(ArrayType.STAT_START, uint64(_classId), _ss4);
        data.addElementToArrayType(ArrayType.STAT_START, uint64(_classId), _ss5);
        data.addElementToArrayType(ArrayType.STAT_START, uint64(_classId), _ss6);
        
    }
    
    function addMonsterClassExtend(uint32 _classId, uint8 _type2, uint8 _type3, 
        uint8 _st1, uint8 _st2, uint8 _st3, uint8 _st4, uint8 _st5, uint8 _st6 ) onlyModerators public {
        
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        if (_type2 > 0) {
            data.addElementToArrayType(ArrayType.CLASS_TYPE, uint64(_classId), _type2);
        }
        if (_type3 > 0) {
            data.addElementToArrayType(ArrayType.CLASS_TYPE, uint64(_classId), _type3);
        }
        
        // add stat base
        data.addElementToArrayType(ArrayType.STAT_STEP, uint64(_classId), _st1);
        data.addElementToArrayType(ArrayType.STAT_STEP, uint64(_classId), _st2);
        data.addElementToArrayType(ArrayType.STAT_STEP, uint64(_classId), _st3);
        data.addElementToArrayType(ArrayType.STAT_STEP, uint64(_classId), _st4);
        data.addElementToArrayType(ArrayType.STAT_STEP, uint64(_classId), _st5);
        data.addElementToArrayType(ArrayType.STAT_STEP, uint64(_classId), _st6);
        
    }
    
    // helper
    function getRandom(uint8 maxRan, uint8 index) constant public returns(uint8) {
        uint256 genNum = uint256(block.blockhash(block.number-1));
        for (uint8 i = 0; i < index && i < 6; i ++) {
            genNum /= 256;
        }
        return uint8(genNum % maxRan);
    }
    
    function () payable public {
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        data.addExtraBalance(msg.sender, msg.value);
    }
    
    // public
    
    function catchMonster(uint32 _classId, string _name) requireDataContract public payable returns(ResultCode) {
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        MonsterClassAcc memory class;
        (class.classId, class.price, class.returnPrice, class.total, class.catchable) = data.getMonsterClass(_classId);
        
        if (class.classId == 0 || class.catchable == false) {
            EventCatchMonster(msg.sender, ResultCode.ERROR_CLASS_NOT_FOUND, 0);
            return ResultCode.ERROR_CLASS_NOT_FOUND;
        }
        
        uint256 totalBalance = safeAdd(msg.value, data.getExtraBalance(msg.sender));
        uint256 payPrice = class.price;
        if (payPrice > totalBalance) {
            data.addExtraBalance(msg.sender, msg.value);
            EventCatchMonster(msg.sender, ResultCode.ERROR_LOW_BALANCE, 0);
            return ResultCode.ERROR_LOW_BALANCE;
        }
        
        // deduct the balance
        data.setExtraBalance(msg.sender, safeSubtract(totalBalance, payPrice));
        
        // add monster
        uint64 objId = data.addMonsterObj(_classId, msg.sender, _name);
        // generate base stat
        for (uint i=0; i < STAT_COUNT; i+= 1) {
            uint8 value = getRandom(STAT_MAX, uint8(i)) + data.getElementInArrayType(ArrayType.STAT_START, uint64(_classId), i);
            data.addElementToArrayType(ArrayType.STAT_BASE, objId, value);
        }

        // calculate the price
        uint256 distributedPrice = safeMult(class.returnPrice, class.total + 2);
        if (payPrice < distributedPrice) {
            payPrice = distributedPrice;
            // update price
            data.setMonsterClass(_classId, distributedPrice, class.returnPrice, true);
        }
        
        EventCatchMonster(msg.sender, ResultCode.SUCCESS, objId);
        return ResultCode.SUCCESS;
    }
    
    function cashOut(uint256 _amount) requireDataContract public returns(ResultCode) {
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        
        uint256 totalAmount = data.collectAllReturnBalance(msg.sender);
        // default to cash out all
        if (_amount == 0) {
            _amount = totalAmount;
        }
        if (_amount > totalAmount) {
            EventCashOut(msg.sender, ResultCode.ERROR_LOW_BALANCE, 0);
            return ResultCode.ERROR_LOW_BALANCE;
        }
        
        // check contract has enough money
        if (this.balance < _amount) {
            EventCashOut(msg.sender, ResultCode.ERROR_NOT_ENOUGH_MONEY, 0);
            return ResultCode.ERROR_NOT_ENOUGH_MONEY;
        }
        
        if (_amount > 0) {
            data.deductExtraBalance(msg.sender, _amount);
            if (!msg.sender.send(_amount)) {
                data.addExtraBalance(msg.sender, _amount);
                EventCashOut(msg.sender, ResultCode.ERROR_SEND_FAIL, 0);
                return ResultCode.ERROR_SEND_FAIL;
            }
        }
        
        EventCashOut(msg.sender, ResultCode.SUCCESS, _amount);
        return ResultCode.SUCCESS;
    }
    
    function getTrainerBalance(address _trainer) constant public returns(uint256) {
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        return data.getExpectedBalance(_trainer);
    }
    
    function getMonsterClassBasic(uint32 _classId) constant public returns(uint256, uint256, uint256, bool) {
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        MonsterClassAcc memory class;
        (class.classId, class.price, class.returnPrice, class.total, class.catchable) = data.getMonsterClass(_classId);
        return (class.price, class.returnPrice, class.total, class.catchable);
    }

    function getLevel(uint32 exp) pure internal returns (uint8) {
        uint8 level = 1;
        uint8 requirement = 100;
        while(level < 100 && exp > requirement) {
            exp -= requirement;
            level += 1;
            requirement = requirement * 12 / 10 + 5;
        }
        return level;
    }

    function getMonsterLevel(uint64 _objId) constant public returns(uint8) {
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        MonsterObjAcc memory obj;
        uint32 _ = 0;
        (obj.monsterId, obj.classId, obj.trainer, obj.exp, _, _, obj.createTime) = data.getMonsterObj(_objId);
     
        return getLevel(obj.exp);
    }
    
    function getMonsterCP(uint64 _objId) constant public returns(uint64) {
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        MonsterObjAcc memory obj;
        uint32 _ = 0;
        (obj.monsterId, obj.classId, obj.trainer, obj.exp, _, _, obj.createTime) = data.getMonsterObj(_objId);
     
        uint baseSize = data.getSizeArrayType(ArrayType.STAT_BASE, obj.monsterId);
        if (baseSize == 0)
            return 0;
        
        uint256 total = 0;
        for(uint i=0; i < baseSize; i+=1) {
            total += data.getElementInArrayType(ArrayType.STAT_BASE, obj.monsterId, i);
            total += safeMult(data.getElementInArrayType(ArrayType.STAT_STEP, uint64(obj.classId), i), getLevel(obj.exp));
        }
        
        return uint64(total/baseSize);
    }
}