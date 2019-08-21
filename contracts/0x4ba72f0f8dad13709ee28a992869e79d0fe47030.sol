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
    // address[] public moderators;
    uint16 public totalModerators = 0;
    mapping (address => bool) public moderators;
    bool public isMaintaining = true;

    function BasicAccessControl() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlyModerators() {
        require(msg.sender == owner || moderators[msg.sender] == true);
        _;
    }

    modifier isActive {
        require(!isMaintaining);
        _;
    }

    function ChangeOwner(address _newOwner) onlyOwner public {
        if (_newOwner != address(0)) {
            owner = _newOwner;
        }
    }


    function AddModerator(address _newModerator) onlyOwner public {
        if (moderators[_newModerator] == false) {
            moderators[_newModerator] = true;
            totalModerators += 1;
        }
    }
    
    function RemoveModerator(address _oldModerator) onlyOwner public {
        if (moderators[_oldModerator] == true) {
            moderators[_oldModerator] = false;
            totalModerators -= 1;
        }
    }

    function UpdateMaintaining(bool _isMaintaining) onlyOwner public {
        isMaintaining = _isMaintaining;
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
        ERROR_INVALID_AMOUNT,
        ERROR_OBJ_NOT_FOUND,
        ERROR_OBJ_INVALID_OWNERSHIP
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

interface EtheremonBattleInterface {
    function isOnBattle(uint64 _objId) constant external returns(bool) ;
    function getMonsterCP(uint64 _objId) constant external returns(uint64);
}

contract EtheremonTrade is EtheremonEnum, BasicAccessControl, SafeMath {
    
    uint8 constant public GEN0_NO = 24;

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
    
    // Gen0 has return price & no longer can be caught when this contract is deployed
    struct Gen0Config {
        uint32 classId;
        uint256 originalPrice;
        uint256 returnPrice;
        uint32 total; // total caught (not count those from eggs)
    }
    
    struct BorrowItem {
        uint index;
        address owner;
        address borrower;
        uint256 price;
        bool lent;
        uint releaseTime;
    }
    
    struct SellingItem {
        uint index;
        uint256 price;
    }
    
    struct SoldItem {
        uint64 objId;
        uint256 price;
        uint time;
    }
    
    // data contract
    address public dataContract;
    address public battleContract;
    mapping(uint32 => Gen0Config) public gen0Config;
    
    // for selling
    mapping(uint64 => SellingItem) public sellingDict;
    uint32 public totalSellingItem;
    uint64[] public sellingList;
    
    // for borrowing
    mapping(uint64 => BorrowItem) public borrowingDict;
    uint32 public totalBorrowingItem;
    uint64[] public borrowingList;
    
    mapping(address => uint64[]) public lendingList;
    mapping(address => SoldItem[]) public soldList;
    
    // trading fee
    uint16 public tradingFeePercentage = 1;
    uint8 public maxLendingItem = 10;
    
    modifier requireDataContract {
        require(dataContract != address(0));
        _;
    }
    
    modifier requireBattleContract {
        require(battleContract != address(0));
        _;
    }
    
    // event
    event EventPlaceSellOrder(address indexed seller, uint64 objId);
    event EventBuyItem(address indexed buyer, uint64 objId);
    event EventOfferBorrowingItem(address indexed lender, uint64 objId);
    event EventAcceptBorrowItem(address indexed borrower, uint64 objId);
    event EventGetBackItem(address indexed owner, uint64 objId);
    event EventFreeTransferItem(address indexed sender, address indexed receiver, uint64 objId);
    event EventRelease(address indexed trainer, uint64 objId);
    
    // constructor
    function EtheremonTrade(address _dataContract, address _battleContract) public {
        dataContract = _dataContract;
        battleContract = _battleContract;
    }
    
     // admin & moderators
    function setOriginalPriceGen0() onlyModerators public {
        gen0Config[1] = Gen0Config(1, 0.3 ether, 0.003 ether, 374);
        gen0Config[2] = Gen0Config(2, 0.3 ether, 0.003 ether, 408);
        gen0Config[3] = Gen0Config(3, 0.3 ether, 0.003 ether, 373);
        gen0Config[4] = Gen0Config(4, 0.2 ether, 0.002 ether, 437);
        gen0Config[5] = Gen0Config(5, 0.1 ether, 0.001 ether, 497);
        gen0Config[6] = Gen0Config(6, 0.3 ether, 0.003 ether, 380); 
        gen0Config[7] = Gen0Config(7, 0.2 ether, 0.002 ether, 345);
        gen0Config[8] = Gen0Config(8, 0.1 ether, 0.001 ether, 518); 
        gen0Config[9] = Gen0Config(9, 0.1 ether, 0.001 ether, 447);
        gen0Config[10] = Gen0Config(10, 0.2 ether, 0.002 ether, 380); 
        gen0Config[11] = Gen0Config(11, 0.2 ether, 0.002 ether, 354);
        gen0Config[12] = Gen0Config(12, 0.2 ether, 0.002 ether, 346);
        gen0Config[13] = Gen0Config(13, 0.2 ether, 0.002 ether, 351); 
        gen0Config[14] = Gen0Config(14, 0.2 ether, 0.002 ether, 338);
        gen0Config[15] = Gen0Config(15, 0.2 ether, 0.002 ether, 341);
        gen0Config[16] = Gen0Config(16, 0.35 ether, 0.0035 ether, 384);
        gen0Config[17] = Gen0Config(17, 1 ether, 0.01 ether, 305); 
        gen0Config[18] = Gen0Config(18, 0.1 ether, 0.001 ether, 427);
        gen0Config[19] = Gen0Config(19, 1 ether, 0.01 ether, 304);
        gen0Config[20] = Gen0Config(20, 0.4 ether, 0.05 ether, 82);
        gen0Config[21] = Gen0Config(21, 1, 1, 123);
        gen0Config[22] = Gen0Config(22, 0.2 ether, 0.001 ether, 468);
        gen0Config[23] = Gen0Config(23, 0.5 ether, 0.0025 ether, 302);
        gen0Config[24] = Gen0Config(24, 1 ether, 0.005 ether, 195);
    }
    
    function setContract(address _dataContract, address _battleContract) onlyModerators public {
        dataContract = _dataContract;
        battleContract = _battleContract;
    }
    
    function updateConfig(uint16 _fee, uint8 _maxLendingItem) onlyModerators public {
        tradingFeePercentage = _fee;
        maxLendingItem = _maxLendingItem;
    }
    
    function withdrawEther(address _sendTo, uint _amount) onlyModerators public {
        // no user money is kept in this contract, only trasaction fee
        if (_amount > this.balance) {
            revert();
        }
        _sendTo.transfer(_amount);
    }
    
    
    // helper
    function removeSellingItem(uint64 _itemId) private {
        SellingItem storage item = sellingDict[_itemId];
        if (item.index == 0)
            return;
        
        if (item.index <= sellingList.length) {
            // Move an existing element into the vacated key slot.
            sellingDict[sellingList[sellingList.length-1]].index = item.index;
            sellingList[item.index-1] = sellingList[sellingList.length-1];
            sellingList.length -= 1;
            delete sellingDict[_itemId];
        }
    }
    
    function addSellingItem(uint64 _itemId, uint256 _price) private {
        SellingItem storage item = sellingDict[_itemId];
        item.price = _price;
        
        if (item.index == 0) {
            item.index = ++sellingList.length;
            sellingList[item.index - 1] = _itemId;
        }
    }

    function removeBorrowingItem(uint64 _itemId) private {
        BorrowItem storage item = borrowingDict[_itemId];
        if (item.index == 0)
            return;
        
        if (item.index <= borrowingList.length) {
            // Move an existing element into the vacated key slot.
            borrowingDict[borrowingList[borrowingList.length-1]].index = item.index;
            borrowingList[item.index-1] = borrowingList[borrowingList.length-1];
            borrowingList.length -= 1;
            delete borrowingDict[_itemId];
        }
    }

    function addBorrowingItem(address _owner, uint64 _itemId, uint256 _price, uint _releaseTime) private {
        BorrowItem storage item = borrowingDict[_itemId];
        item.owner = _owner;
        item.borrower = address(0);
        item.price = _price;
        item.lent = false;
        item.releaseTime = _releaseTime;
        
        if (item.index == 0) {
            item.index = ++borrowingList.length;
            borrowingList[item.index - 1] = _itemId;
        }
    }
    
    function transferMonster(address _to, uint64 _objId) private {
        EtheremonDataBase data = EtheremonDataBase(dataContract);

        MonsterObjAcc memory obj;
        (obj.monsterId, obj.classId, obj.trainer, obj.exp, obj.createIndex, obj.lastClaimIndex, obj.createTime) = data.getMonsterObj(_objId);

        // clear balance for gen 0
        if (obj.classId <= GEN0_NO) {
            Gen0Config storage gen0 = gen0Config[obj.classId];
            if (gen0.classId == obj.classId) {
                if (obj.lastClaimIndex < gen0.total) {
                    uint32 gap = uint32(safeSubtract(gen0.total, obj.lastClaimIndex));
                    if (gap > 0) {
                        data.addExtraBalance(obj.trainer, safeMult(gap, gen0.returnPrice));
                        // reset total (accept name is cleared :( )
                        data.setMonsterObj(obj.monsterId, " name me ", obj.exp, obj.createIndex, gen0.total);
                    }
                }
            }
        }
        
        // transfer owner
        data.removeMonsterIdMapping(obj.trainer, _objId);
        data.addMonsterIdMapping(_to, _objId);
    }
    
    function addItemLendingList(address _trainer, uint64 _objId) private {
        if (_trainer != address(0)) {
            uint64[] storage objList = lendingList[_trainer];
            for (uint index = 0; index < objList.length; index++) {
                if (objList[index] == _objId) {
                    return;
                }
            }
            objList.push(_objId);
        }
    }
    
    function removeItemLendingList(address _trainer, uint64 _objId) private {
        uint foundIndex = 0;
        uint64[] storage objList = lendingList[_trainer];
        for (; foundIndex < objList.length; foundIndex++) {
            if (objList[foundIndex] == _objId) {
                break;
            }
        }
        if (foundIndex < objList.length) {
            objList[foundIndex] = objList[objList.length-1];
            delete objList[objList.length-1];
            objList.length--;
        }
    }
    
    // public
    function placeSellOrder(uint64 _objId, uint256 _price) requireDataContract requireBattleContract isActive external {
        if (_price == 0)
            revert();
        // not on borrowing
        BorrowItem storage item = borrowingDict[_objId];
        if (item.index > 0)
            revert();
        // not on battle 
        EtheremonBattleInterface battle = EtheremonBattleInterface(battleContract);
        if (battle.isOnBattle(_objId))
            revert();
        
        // check ownership
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        MonsterObjAcc memory obj;
        uint32 _ = 0;
        (obj.monsterId, obj.classId, obj.trainer, obj.exp, _, _, obj.createTime) = data.getMonsterObj(_objId);
        
        if (obj.monsterId != _objId) {
            revert();
        }
        
        if (obj.trainer != msg.sender) {
            revert();
        }
        
        // on selling, then just update price
        if (sellingDict[_objId].index > 0){
            sellingDict[_objId].price = _price;
        } else {
            addSellingItem(_objId, _price);
        }
        EventPlaceSellOrder(msg.sender, _objId);
    }
    
    function removeSellOrder(uint64 _objId) requireDataContract requireBattleContract isActive external {
        if (sellingDict[_objId].index == 0)
            revert();
        
        // check ownership
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        MonsterObjAcc memory obj;
        uint32 _ = 0;
        (obj.monsterId, obj.classId, obj.trainer, obj.exp, _, _, obj.createTime) = data.getMonsterObj(_objId);
        
        if (obj.monsterId != _objId) {
            revert();
        }
        
        if (obj.trainer != msg.sender) {
            revert();
        }
        
        removeSellingItem(_objId);
    }
    
    function buyItem(uint64 _objId) requireDataContract requireBattleContract isActive external payable {
        // check item is valid to sell 
        uint256 requestPrice = sellingDict[_objId].price;
        if (requestPrice == 0 || msg.value != requestPrice) {
            revert();
        }
        
        // check obj
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        MonsterObjAcc memory obj;
        uint32 _ = 0;
        (obj.monsterId, obj.classId, obj.trainer, obj.exp, _, _, obj.createTime) = data.getMonsterObj(_objId);
        if (obj.monsterId != _objId) {
            revert();
        }
        // can not buy from yourself
        if (obj.trainer == msg.sender) {
            revert();
        }
        
        address oldTrainer = obj.trainer;
        uint256 fee = requestPrice * tradingFeePercentage / 100;
        removeSellingItem(_objId);
        transferMonster(msg.sender, _objId);
        oldTrainer.transfer(safeSubtract(requestPrice, fee));
        
        SoldItem memory soldItem = SoldItem(_objId, requestPrice, block.timestamp);
        soldList[oldTrainer].push(soldItem);
        EventBuyItem(msg.sender, _objId);
    }
    
    function offerBorrowingItem(uint64 _objId, uint256 _price, uint _releaseTime) requireDataContract requireBattleContract isActive external {
        // make sure it is not on sale 
        if (sellingDict[_objId].price > 0 || _price == 0)
            revert();
        // not on lent
        BorrowItem storage item = borrowingDict[_objId];
        if (item.lent == true)
            revert();
        // not on battle 
        EtheremonBattleInterface battle = EtheremonBattleInterface(battleContract);
        if (battle.isOnBattle(_objId))
            revert();
        
        
        // check ownership
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        MonsterObjAcc memory obj;
        uint32 _ = 0;
        (obj.monsterId, obj.classId, obj.trainer, obj.exp, _, _, obj.createTime) = data.getMonsterObj(_objId);
        
        if (obj.monsterId != _objId) {
            revert();
        }
        
        if (obj.trainer != msg.sender) {
            revert();
        }
        
        if (item.index > 0) {
            // update info 
            item.price = _price;
            item.releaseTime = _releaseTime;
        } else {
            addBorrowingItem(msg.sender, _objId, _price, _releaseTime);
        }
        EventOfferBorrowingItem(msg.sender, _objId);
    }
    
    function removeBorrowingOfferItem(uint64 _objId) requireDataContract requireBattleContract isActive external {
        BorrowItem storage item = borrowingDict[_objId];
        if (item.index == 0)
            revert();
        
        if (item.owner != msg.sender)
            revert();
        if (item.lent == true)
            revert();
        
        removeBorrowingItem(_objId);
    }
    
    function borrowItem(uint64 _objId) requireDataContract requireBattleContract isActive external payable {
        BorrowItem storage item = borrowingDict[_objId];
        if (item.index == 0)
            revert();
        if (item.lent == true)
            revert();
        uint256 itemPrice = item.price;
        if (itemPrice != msg.value)
            revert();
        

        // check obj
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        MonsterObjAcc memory obj;
        uint32 _ = 0;
        (obj.monsterId, obj.classId, obj.trainer, obj.exp, _, _, obj.createTime) = data.getMonsterObj(_objId);
        if (obj.monsterId != _objId) {
            revert();
        }
        // can not borrow from yourself
        if (obj.trainer == msg.sender) {
            revert();
        }
        
        uint256 fee = itemPrice * tradingFeePercentage / 100;
        item.borrower = msg.sender;
        item.releaseTime += block.timestamp;
        item.lent = true;
        address oldOwner = obj.trainer;
        transferMonster(msg.sender, _objId);
        oldOwner.transfer(safeSubtract(itemPrice, fee));
        addItemLendingList(oldOwner, _objId);
        EventAcceptBorrowItem(msg.sender, _objId);
    }
    
    function getBackLendingItem(uint64 _objId) requireDataContract requireBattleContract isActive external {
        BorrowItem storage item = borrowingDict[_objId];
        if (item.index == 0)
            revert();
        if (item.lent == false)
            revert();
        if (item.releaseTime > block.timestamp)
            revert();
        
        if (msg.sender != item.owner)
            revert();
        
        removeBorrowingItem(_objId);
        transferMonster(msg.sender, _objId);
        removeItemLendingList(msg.sender, _objId);
        EventGetBackItem(msg.sender, _objId);
    }
    
    function freeTransferItem(uint64 _objId, address _receiver) requireDataContract requireBattleContract external {
        // make sure it is not on sale 
        if (sellingDict[_objId].price > 0)
            revert();
        // not on borrowing
        BorrowItem storage item = borrowingDict[_objId];
        if (item.index > 0)
            revert();
        // not on battle 
        EtheremonBattleInterface battle = EtheremonBattleInterface(battleContract);
        if (battle.isOnBattle(_objId))
            revert();
        
        // check ownership
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        MonsterObjAcc memory obj;
        uint32 _ = 0;
        (obj.monsterId, obj.classId, obj.trainer, obj.exp, _, _, obj.createTime) = data.getMonsterObj(_objId);
        
        if (obj.monsterId != _objId) {
            revert();
        }
        
        if (obj.trainer != msg.sender) {
            revert();
        }
        
        transferMonster(_receiver, _objId);
        EventFreeTransferItem(msg.sender, _receiver, _objId);
    }
    
    function release(uint64 _objId) requireDataContract requireBattleContract external {
        // make sure it is not on sale 
        if (sellingDict[_objId].price > 0)
            revert();
        // not on borrowing
        BorrowItem storage item = borrowingDict[_objId];
        if (item.index > 0)
            revert();
        // not on battle 
        EtheremonBattleInterface battle = EtheremonBattleInterface(battleContract);
        if (battle.isOnBattle(_objId))
            revert();
        
        // check ownership
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        MonsterObjAcc memory obj;
        uint32 _ = 0;
        (obj.monsterId, obj.classId, obj.trainer, obj.exp, _, _, obj.createTime) = data.getMonsterObj(_objId);
        
        // can not release gen 0
        if (obj.classId <= GEN0_NO) {
            revert();
        }
        
        if (obj.monsterId != _objId) {
            revert();
        }
        
        if (obj.trainer != msg.sender) {
            revert();
        }
        
        data.removeMonsterIdMapping(msg.sender, _objId);
        EventRelease(msg.sender, _objId);
    }
    
    // read access
    
    function getBasicObjInfo(uint64 _objId) constant public returns(uint32, address, uint32, uint32){
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        MonsterObjAcc memory obj;
        (obj.monsterId, obj.classId, obj.trainer, obj.exp, obj.createIndex, obj.lastClaimIndex, obj.createTime) = data.getMonsterObj(_objId);
        return (obj.classId, obj.trainer, obj.exp, obj.createIndex);
    }
    
    function getBasicObjInfoWithBp(uint64 _objId) constant public returns(uint32, uint32, uint32, uint64) {
        EtheremonDataBase data = EtheremonDataBase(dataContract);
        MonsterObjAcc memory obj;
        (obj.monsterId, obj.classId, obj.trainer, obj.exp, obj.createIndex, obj.lastClaimIndex, obj.createTime) = data.getMonsterObj(_objId);
        EtheremonBattleInterface battle = EtheremonBattleInterface(battleContract);
        uint64 bp = battle.getMonsterCP(_objId);
        return (obj.classId, obj.exp, obj.createIndex, bp);
    }
    
    function getTotalSellingItem() constant external returns(uint) {
        return sellingList.length;
    }

    function getSellingItem(uint _index) constant external returns(uint64 objId, uint32 classId, uint32 exp, uint64 bp, address trainer, uint createIndex, uint256 price) {
        objId = sellingList[_index];
        if (objId > 0) {
            (classId, trainer, exp, createIndex) = getBasicObjInfo(objId);
            EtheremonBattleInterface battle = EtheremonBattleInterface(battleContract);
            bp = battle.getMonsterCP(objId);
            price = sellingDict[objId].price;
        }
    }
    
    function getSellingItemByObjId(uint64 _objId) constant external returns(uint32 classId, uint32 exp, uint64 bp, address trainer, uint createIndex, uint256 price) {
        price = sellingDict[_objId].price;
        if (price > 0) {
            (classId, trainer, exp, createIndex) = getBasicObjInfo(_objId);
            EtheremonBattleInterface battle = EtheremonBattleInterface(battleContract);
            bp = battle.getMonsterCP(_objId);
        }
    }

    function getTotalBorrowingItem() constant external returns(uint) {
        return borrowingList.length;
    }

    function getBorrowingItem(uint _index) constant external returns(uint64 objId, address owner, address borrower, 
        uint256 price, bool lent, uint releaseTime, uint32 classId, uint32 exp, uint32 createIndex, uint64 bp) {
        objId = borrowingList[_index];
        BorrowItem storage item = borrowingDict[objId];
        owner = item.owner;
        borrower = item.borrower;
        price = item.price;
        lent = item.lent;
        releaseTime = item.releaseTime;
        
        (classId, exp, createIndex, bp) = getBasicObjInfoWithBp(objId);
    }
    
    function getBorrowingItemByObjId(uint64 _objId) constant external returns(uint index, address owner, address borrower, 
        uint256 price, bool lent, uint releaseTime, uint32 classId, uint32 exp, uint32 createIndex, uint64 bp) {
        BorrowItem storage item = borrowingDict[_objId];
        index = item.index;
        owner = item.owner;
        borrower = item.borrower;
        price = item.price;
        lent = item.lent;
        releaseTime = item.releaseTime;
        
        (classId, exp, createIndex, bp) = getBasicObjInfoWithBp(_objId);
    }
    
    function getSoldItemLength(address _trainer) constant external returns(uint) {
        return soldList[_trainer].length;
    }
    
    function getSoldItem(address _trainer, uint _index) constant external returns(uint64 objId, uint32 classId, uint32 exp, uint64 bp, address currentOwner, 
        uint createIndex, uint256 price, uint time) {
        if (_index > soldList[_trainer].length)
            return;
        SoldItem memory soldItem = soldList[_trainer][_index];
        objId = soldItem.objId;
        price = soldItem.price;
        time = soldItem.time;
        if (objId > 0) {
            (classId, currentOwner, exp, createIndex) = getBasicObjInfo(objId);
            EtheremonBattleInterface battle = EtheremonBattleInterface(battleContract);
            bp = battle.getMonsterCP(objId);
        }
    }
    
    function getLendingItemLength(address _trainer) constant external returns(uint) {
        return lendingList[_trainer].length;
    }
    
    function getLendingItemInfo(address _trainer, uint _index) constant external returns(uint64 objId, address owner, address borrower, 
        uint256 price, bool lent, uint releaseTime, uint32 classId, uint32 exp, uint32 createIndex, uint64 bp) {
        if (_index > lendingList[_trainer].length)
            return;
        objId = lendingList[_trainer][_index];
        BorrowItem storage item = borrowingDict[objId];
        owner = item.owner;
        borrower = item.borrower;
        price = item.price;
        lent = item.lent;
        releaseTime = item.releaseTime;
        
        (classId, exp, createIndex, bp) = getBasicObjInfoWithBp(objId);
    }
    
    function getTradingInfo(uint64 _objId) constant external returns(uint256 sellingPrice, uint256 lendingPrice, bool lent, uint releaseTime) {
        sellingPrice = sellingDict[_objId].price;
        BorrowItem storage item = borrowingDict[_objId];
        lendingPrice = item.price;
        lent = item.lent;
        releaseTime = item.releaseTime;
    }
    
    function isOnTrading(uint64 _objId) constant external returns(bool) {
        return (sellingDict[_objId].price > 0 || borrowingDict[_objId].owner != address(0));
    }
}