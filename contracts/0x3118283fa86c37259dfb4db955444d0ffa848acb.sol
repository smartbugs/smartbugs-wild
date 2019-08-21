pragma solidity ^0.4.24;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () public{
        owner = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "401: Only the contract owner can call this method.");
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

}

contract EthEggBase is Ownable{
    enum EggStatus{preSell, selling, brood, finished, notExist}
    enum MsgType{other, buySuccess, buyFail, sellSuccess, prIncome, chickenDie, eggNotEnough, hatch, moneyIncorrect, prSelf, prNotBuy}
    struct Egg{
        uint64 eggId;
        uint8 batchNum;
        EggStatus eggStatus;
        uint32 chickenId;
        address eggOwner;
    }

    struct Chicken{
        uint32 chickenId;
        uint8 bornNum;
        address chickenOwner;
    }

    Egg[] eggs;
    Chicken[] chickens;
    mapping(address=>uint32[]) userToChickenIds;
    mapping(address=>uint64[]) userToEggIds;    //the eggs for user's chicken brood only, not include eggs from buying


    uint8 currentBatchNum;
    uint64 currentSellEggIndex;
    uint256 currentPrice;
    uint256 initPrice;
    uint256 eggsCount=1;

    mapping(address=>uint32) userToChickenCnt;
    mapping(address=>uint32) userToDeadChickenCnt;
    mapping(uint8=>uint64) batchNumToCount;

    uint8 maxHatch;

    event Message(address _to, uint256 _val1, uint256 _val2, MsgType _msgType, uint64 _msgTime);
    event DebugBuy(address _to, address _from, uint256 _balance, uint64 _eggId, EggStatus _eggStatus, uint32 _chickenId);

    function calcPrice() internal {
        if (currentBatchNum == 0){
            currentPrice = initPrice;
        }else{
            currentPrice = initPrice * (9**uint256(currentBatchNum)) / (10**uint256(currentBatchNum));
        }

    }

    constructor() public {
        currentBatchNum = 0;

        maxHatch = 99;           //default 99
        batchNumToCount[0]=10;    //set to 100 default;

        initPrice = 1000000000000000000;
        calcPrice();
    }

    function initParams(uint64 _alphaEggCnt) public onlyOwner {
        require(eggs.length==0);
        // maxHatch = _maxHatch;           //default 99
        batchNumToCount[0]=_alphaEggCnt;    //set to 100 default;
        batchNumToCount[1]=_alphaEggCnt;
        batchNumToCount[2]=batchNumToCount[1]*2;
        batchNumToCount[3]=batchNumToCount[2]*2;
        batchNumToCount[4]=batchNumToCount[3]*2;
        calcBatchCnt(5,50);
    }

    //init 100 eggs, price:1 ether
    function initEggs(uint8 _genAmount) external {
        require(eggs.length < batchNumToCount[0], "402:Init Eth eggs already generated.");

        for (uint8 i=1; i <= _genAmount && eggs.length<=batchNumToCount[0]; i++){
            uint64 _eggId = uint64(eggs.length + 1);
            Egg memory _egg = Egg({
                eggId:_eggId,
                batchNum:currentBatchNum,
                eggStatus:EggStatus.selling,
                chickenId:0,    //that means not egg for any chicken
                eggOwner:owner  //the contract's egg
                });
            eggs.push(_egg);
        }
        eggsCount+=_genAmount;

    }

    function calcBatchCnt(uint8 _beginIndex, uint8 _endIndex) internal {
        require (_beginIndex >=5);
        require (_endIndex <= 50);
        require (batchNumToCount[_beginIndex]==0);
        for (uint8 _batchIndex=_beginIndex; _batchIndex< _endIndex; _batchIndex++){
            if (batchNumToCount[_batchIndex] == 0){
                batchNumToCount[_batchIndex] = batchNumToCount[_batchIndex-1] * 2 - batchNumToCount[_batchIndex-5];
            }
        }
    }

}
contract EthEggInfo is EthEggBase {

    function getPrice() external view returns (uint256){
        return currentPrice;
    }

    function getEggsCount() public view returns (uint256){
        return eggsCount - 1;
    }



    function getFarm() external view returns
    (uint32 [] chickenIds,
        EggStatus[] eggStatus1,
        EggStatus[] eggStatus2,
        EggStatus[] eggStatus3,
        EggStatus[] eggStatus4
    ){
        uint32[] memory _chickenIds = userToChickenIds[msg.sender];
        EggStatus[] memory _eggStatus1 = new EggStatus[](_getChickenCnt(msg.sender));
        EggStatus[] memory _eggStatus2 = new EggStatus[](_getChickenCnt(msg.sender));
        EggStatus[] memory _eggStatus3 = new EggStatus[](_getChickenCnt(msg.sender));
        EggStatus[] memory _eggStatus4 = new EggStatus[](_getChickenCnt(msg.sender));

        for (uint32 _index=0; _index < _chickenIds.length; _index++){
            Chicken memory _c = chickens[_chickenIds[_index]-1];
            uint8 _maxEggCount=4;
            uint64[] memory _eggIds = userToEggIds[msg.sender];
            for (uint64 j=0; j<_eggIds.length; j++){
                Egg memory _e = eggs[_eggIds[j]-1];
                if (_c.chickenId == _e.chickenId){
                    if (_maxEggCount==4){
                        _eggStatus1[_index] = getEggStatus(_e.eggStatus,_e.batchNum);
                    }else if(_maxEggCount==3){
                        _eggStatus2[_index] = getEggStatus(_e.eggStatus,_e.batchNum);
                    }else if(_maxEggCount==2){
                        _eggStatus3[_index] = getEggStatus(_e.eggStatus,_e.batchNum);
                    }else if(_maxEggCount==1){
                        _eggStatus4[_index] = getEggStatus(_e.eggStatus,_e.batchNum);
                    }
                    _maxEggCount--;
                }
            }
            for (;_maxEggCount>0;_maxEggCount--){
                if (_maxEggCount==4){
                    _eggStatus1[_index] = EggStatus.notExist;
                }else if(_maxEggCount==3){
                    _eggStatus2[_index] = EggStatus.notExist;
                }else if(_maxEggCount==2){
                    _eggStatus3[_index] = EggStatus.notExist;
                }else if(_maxEggCount==1){
                    _eggStatus4[_index] = EggStatus.notExist;
                }
            }
        }
        chickenIds = _chickenIds;
        eggStatus1 = _eggStatus1;
        eggStatus2 = _eggStatus2;
        eggStatus3 = _eggStatus3;
        eggStatus4 = _eggStatus4;
    }

    function getEggStatus(EggStatus _eggStatus, uint8 _batchNum) internal view returns(EggStatus){
        if (_batchNum > currentBatchNum && _eggStatus==EggStatus.selling){
            return EggStatus.preSell;
        }else{
            return _eggStatus;
        }
    }

    //The Amount of chicken alive
    function getChickenAmount() public view returns (uint32){
        return userToChickenCnt[msg.sender] - userToDeadChickenCnt[msg.sender];
    }

    //include dead and alive chickens
    function _getChickenCnt(address _user) internal view returns (uint16){
        uint128 _chickenSize = uint128(chickens.length);
        uint16 _userChickenCnt = 0;
        for(uint128 i=_chickenSize; i>0; i--){
            Chicken memory _c = chickens[i-1];
            if (_user == _c.chickenOwner){
                _userChickenCnt++;
            }
        }
        return _userChickenCnt;
    }

    function getFreeHatchCnt() public view returns(uint32){
        return _getFreeHatchCnt(msg.sender);
    }

    function _getFreeHatchCnt(address _user) internal view returns(uint32){
        uint32 _maxHatch = uint32(maxHatch);
        if (_maxHatch >= (userToChickenCnt[_user] - userToDeadChickenCnt[_user])){
            return _maxHatch - (userToChickenCnt[_user] - userToDeadChickenCnt[_user]);
        } else {
            return 0;
        }
    }


}
contract EthEggTx is EthEggInfo{
    function buy(uint8 _buyCount) external payable {
        uint8 _cnt = _buyCount;
        uint256 _val = msg.value;
        require(0<_buyCount && _buyCount<=10);
        if (eggsCount < _cnt){
            msg.sender.transfer(_val);
            emit Message(msg.sender, _val, 0, MsgType.eggNotEnough, uint64(now));
            return;
        }
        if (getFreeHatchCnt() < _buyCount){
            msg.sender.transfer(_val);
            emit Message(msg.sender, _val, 0, MsgType.hatch, uint64(now));
            return;
        }
        if (_val != currentPrice * _buyCount){
            msg.sender.transfer(_val);
            emit Message(msg.sender, _val, 0, MsgType.moneyIncorrect, uint64(now));
            return;
        }
        uint256 _servCharge = 0;
        for (uint64 i=currentSellEggIndex; i<eggs.length; i++){
            Egg storage _egg = eggs[i];
            if (getEggStatus(_egg.eggStatus, _egg.batchNum) == EggStatus.preSell){
                break;
            }
            _egg.eggStatus = EggStatus.brood;
            address _oldOwner = _egg.eggOwner;
            _egg.eggOwner = msg.sender;

            eggsCount--;

            _oldOwner.transfer(currentPrice * 7 / 10);
            _servCharge += currentPrice * 3/ 10;

            chickenBornEgg(_oldOwner, _egg.chickenId);

            eggBroodToChicken(msg.sender);

            _cnt--;

            //send sell success message.
            emit Message(_oldOwner, currentPrice * 7 / 10, uint256(_egg.chickenId), MsgType.sellSuccess, uint64(now));

            if (_cnt<=0){
                break;
            }
        }
        currentSellEggIndex = currentSellEggIndex + _buyCount - _cnt;
        _preSellToSelling();
        owner.transfer(_servCharge);

        //send buy success message.
        emit Message(msg.sender, _val, uint256(_buyCount - _cnt), MsgType.buySuccess, uint64(now));
    }

    //when user purchase an egg use a promote code
    function buyWithPr(uint8 _buyCount, address _prUser) external payable{
        uint8 _cnt = _buyCount;
        uint256 _val = msg.value;
        require(0<_buyCount && _buyCount<=10);
        if (msg.sender == _prUser){
            msg.sender.transfer(_val);
            emit Message(msg.sender, _val, 0, MsgType.prSelf, uint64(now));
            return;
        }
        if (userToChickenCnt[_prUser]==0){
            msg.sender.transfer(_val);
            emit Message(msg.sender, _val, 0, MsgType.prNotBuy, uint64(now));
            return;
        }
        if (eggsCount < _cnt){
            msg.sender.transfer(_val);
            emit Message(msg.sender, _val, 0, MsgType.eggNotEnough, uint64(now));
            return;
        }
        if (getFreeHatchCnt() < _buyCount){
            msg.sender.transfer(_val);
            emit Message(msg.sender, _val, 0, MsgType.hatch, uint64(now));
            return;
        }
        if (_val != currentPrice * _buyCount){
            msg.sender.transfer(_val);
            emit Message(msg.sender, _val, 0, MsgType.moneyIncorrect, uint64(now));
            return;
        }

        uint256 _servCharge = 0;
        uint256 _prIncome = 0;
        for (uint64 i=currentSellEggIndex; i<eggs.length; i++){
            Egg storage _egg = eggs[i];
            if (getEggStatus(_egg.eggStatus, _egg.batchNum) == EggStatus.preSell){
                break;
            }

            _egg.eggStatus = EggStatus.brood;
            address _oldOwner = _egg.eggOwner;
            _egg.eggOwner = msg.sender;

            eggsCount--;

            //debug message
            // emit DebugBuy(msg.sender, _oldOwner, currentPrice, _egg.eggId, getEggStatus(_egg.eggStatus, _egg.batchNum), _egg.chickenId);

            _oldOwner.transfer(currentPrice * 7 / 10);
            _prIncome += currentPrice * 8/ 100;
            _servCharge += currentPrice * 22/ 100;

            chickenBornEgg(_oldOwner, _egg.chickenId);

            // userToChickenCnt[msg.sender]++;
            eggBroodToChicken(msg.sender);

            _cnt--;

            //send sell success message.
            emit Message(_oldOwner, currentPrice * 7 / 10, uint256(_egg.chickenId), MsgType.sellSuccess, uint64(now));

            if (_cnt<=0){
                break;
            }
        }
        currentSellEggIndex = currentSellEggIndex + _buyCount - _cnt;
        _preSellToSelling();
        _prUser.transfer(_prIncome);
        owner.transfer(_servCharge);

        //send pr message.
        emit Message(_prUser, _prIncome, uint256(_buyCount - _cnt), MsgType.prIncome, uint64(now));

        //send buy success message.
        emit Message(msg.sender, _val, uint256(_buyCount - _cnt), MsgType.buySuccess, uint64(now));
    }

    function chickenBornEgg(address _user, uint32 _chickenId) internal {
        if (_user == owner){
            return;
        }

        if (_chickenId == 0){
            return;
        }

        Chicken storage _chicken = chickens[_chickenId-1];
        if (_chicken.bornNum < 4){
            _chicken.bornNum++;
            uint64 _eggId = uint64(eggs.length+1);
            uint8 _batchNum = _getBatchNumByEggId(_eggId);
            EggStatus _status = EggStatus.selling;
            Egg memory _egg = Egg({
                eggId: _eggId,
                batchNum: _batchNum,
                eggStatus: _status,
                chickenId: _chickenId,
                eggOwner: _user
                });
            eggs.push(_egg);
            userToEggIds[_user].push(_eggId);
        } else if (_chicken.bornNum == 4){
            userToDeadChickenCnt[_user]++;
            emit Message(_chicken.chickenOwner, uint256(_chickenId), uint256(_chicken.chickenId), MsgType.chickenDie, uint64(now));
        }
    }

    function eggBroodToChicken(address _user) internal {
        if (owner != _user && _getFreeHatchCnt(_user) > 0){
            uint32 _chickenId = uint32(chickens.length+1);
            Chicken memory _chicken = Chicken({
                chickenId:_chickenId,
                bornNum:0,
                chickenOwner:_user
                });
            chickens.push(_chicken);
            userToChickenCnt[_user]++;
            userToChickenIds[_user].push(_chickenId);

            //and then the chicken generate an egg.
            chickenBornEgg(_user, _chickenId);
        }

    }

    function _preSellToSelling() internal {
        if (getEggsCount()==0){
            currentBatchNum++;
            uint64 _cnt = 0;
            for(uint64 _index = currentSellEggIndex; _index < eggs.length; _index++){
                Egg memory _egg = eggs[_index];
                if (getEggStatus(_egg.eggStatus, _egg.batchNum) == EggStatus.preSell){
                    break;
                }
                if (getEggStatus(_egg.eggStatus, _egg.batchNum) == EggStatus.selling){
                    _cnt++;
                }
            }
            eggsCount = eggsCount + _cnt;
            if (getEggsCount()>0){
                calcPrice();
            }
        }
    }

    function _getBatchNumByEggId(uint64 _eggId) internal view returns(uint8){
        int128 _count = int128(_eggId);
        uint8 _batchNo = 0;
        for(;_batchNo<=49;_batchNo++){
            _count = _count - int128(batchNumToCount[_batchNo]);
            if (_count <= 0){
                break;
            }
        }
        return _batchNo;
    }


    function testEggIds() public view returns(uint64[]){
        uint64[] memory _ids = new uint64[](eggs.length);
        for(uint64 i=0; i < uint64(eggs.length); i++){
            _ids[i] = eggs[i].eggId;
        }
        return _ids;
    }

    function testChickenInfo(uint32 _chickenId) public view returns(uint32, uint8, address){
        require(_chickenId>0);
        Chicken memory _chicken = chickens[_chickenId-1];
        return (_chicken.chickenId, _chicken.bornNum, _chicken.chickenOwner);
    }

    function testEggInfo(uint64 _eggId) public view returns(uint64 cid, uint8 batchNum, EggStatus eggStatus, uint32 chickenId, address eggOwner){
        require(_eggId>0);
        Egg memory _egg = eggs[_eggId-1];
        uint8 _batchNum = _egg.batchNum;
        EggStatus _eggStatus = getEggStatus(_egg.eggStatus, _egg.batchNum);
        uint32 _chickenId = _egg.chickenId;
        address _eggOwner = _egg.eggOwner;
        return (_eggId, _batchNum, _eggStatus, _chickenId, _eggOwner);
    }

    function testChickenCnt() external view returns(uint32){
        return userToChickenCnt[msg.sender];
    }

    function testDeadChickenCnt() external view returns(uint32){
        return userToDeadChickenCnt[msg.sender];
    }
}