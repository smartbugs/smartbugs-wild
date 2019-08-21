//////////////////////////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////////////////////////

pragma solidity ^0.4.21;


// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol 2018-04-24 add
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Base {
    using SafeMath for uint256;
    uint public createTime = now;
    address public owner;   
    uint public currentEventId = 1;
    uint256 public ownerDividend = 0 ;
    uint256 public thisEther = 0 ;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function setOwner(address _newOwner)  public  onlyOwner {
        require(msg.sender == tx.origin);
        userRefund();
        owner = _newOwner;
    }

    function getEventId() internal returns(uint _result) {  
        _result = currentEventId;
        currentEventId ++;
    }

    function userRefund() public onlyOwner returns(bool _result) {
        require(msg.sender == tx.origin);
        if(ownerDividend > 0 ){
            msg.sender.transfer(ownerDividend);
            ownerDividend = 0 ;
        }
        return true;
    }
}
    
contract FreeCell is Base{

    string constant public name = "FreeCell";
    uint256 public curPosition = 0;
    uint public lastPlayTime = 0;
    uint public expirationTime = 24 hours;

    uint256 public BASE_BET_ETHER = 0.01 ether;
    uint public REWARD_WIN_MULTIPLE_PER = 60;
    uint public PRE_WIN_MULTIPLE_PER = 30;
    uint public KING_WIN_MULTIPLE_PER = REWARD_WIN_MULTIPLE_PER + PRE_WIN_MULTIPLE_PER;
    uint public REWARD_NUM = 200;
    uint public REWARD_FORWARD_POSITION = REWARD_NUM - 1 ;
    uint public CELL_ADD_SPACE = 0.0005 ether ; 
    uint public STEP_SIZE = 50 ;
    uint public MAX_LENGTH = 1000000 ; 

    function FreeCell() public {
        require(REWARD_WIN_MULTIPLE_PER.add(PRE_WIN_MULTIPLE_PER) < 100) ;
        require(curPosition == 0);
        owner = msg.sender;
        lastPlayTime = now;
    }

    struct betInfo {
        address addr;
        uint256 card;
    }

    mapping (uint256 => betInfo) public playerBetInfoOf;
    mapping (uint256 => uint256) public resultOf;

    event OnGetAward(uint256 indexed _position,  address indexed _player, uint256 indexed _card, uint256  _prePosition, uint256 _rewardMoney, uint8 _type, uint256 _eventId, uint256 _eventTime);
    event OnPlay(uint256 indexed _position,  address indexed _player, uint256 indexed _card, uint256 _eventId, uint256 _eventTime);

    function playBatch(uint256 num) public payable returns(bool _result){
        require(msg.sender == tx.origin);
        uint256 userMoney = msg.value;

        if(now.sub(lastPlayTime) > expirationTime){
            getEventId();
            address _lastPalayUser = playerBetInfoOf[curPosition].addr ;
            uint256 _toLastPlayer = _rewardKing(1, MAX_LENGTH,_lastPalayUser,uint8(4));  
            if(userMoney > 0){
                msg.sender.transfer(userMoney);
            }
            if(_toLastPlayer > 0 ){
                _lastPalayUser.transfer(_toLastPlayer);
            }
            lastPlayTime = now ;
            _result = true;
            return ;
        }else{
            lastPlayTime = now ;
        }

        for(uint256 i = 0;i < num; i++){
            (_result,userMoney) = _play(userMoney);
            if(!_result){
                break ; 
            }
        }
        if(userMoney > 0){
            msg.sender.transfer(userMoney);
        }
    }

    function play() public payable returns(bool _result){
        require(msg.sender == tx.origin);
        uint256 userMoney = msg.value;

        if(now.sub(lastPlayTime) > expirationTime){
            getEventId();
            address _lastPalayUser = playerBetInfoOf[curPosition].addr ;
            uint256 _toLastPlayer = _rewardKing(1, MAX_LENGTH,_lastPalayUser,uint8(4));  
            if(userMoney > 0){
                msg.sender.transfer(userMoney);
            }
            if(_toLastPlayer > 0 ){
                _lastPalayUser.transfer(_toLastPlayer);
            }
            lastPlayTime = now ;
            _result = true;
            return ;
        }else{
            lastPlayTime = now ;
        }

        (_result,userMoney) = _play(userMoney);
        require(_result);
        if(userMoney > 0){
            msg.sender.transfer(userMoney);
        }
    }

    function _isKingKong(uint256 _card) private pure returns(bool _result){
        _result = false;
        if(_card % 111111 == 0){
           _result = true ;
        }
    }

    function _isStraight(uint256 _card) private pure returns(bool _result){
        _result = false;
        if(_card >= 543210){
            if(_isKingKong(_card.sub(12345)) || _isKingKong(_card.sub(543210))){
                _result = true ;
            }
        }else if(_card > 123455){
            if(_isKingKong(_card.sub(12345))){
                _result = true ;
            }
        }else{
            _result = false;
        }
    }

    function viewPosition(uint256 _card) public view returns(uint256 _position) {
        _position = resultOf[_card];
        if(_position > curPosition || playerBetInfoOf[_position].card != _card){
            _position = 0 ;
        }
    }

    function viewBetEther(uint256 _position) public view returns(uint256 _betEther) {
        _betEther = _position.sub(1).div(STEP_SIZE).mul(CELL_ADD_SPACE).add(BASE_BET_ETHER);
        return _betEther;
    }

    function viewNeedBetEther(uint256 num) public view returns(uint256 _betEther) {
        require(num <= 20) ;
        return  viewSumEther(curPosition.add(1),curPosition.add(num));
    }

    function _sumEther(uint256 _position) private view returns(uint256 _totalEther){
        if(_position < STEP_SIZE){
            return _position.mul(BASE_BET_ETHER);     
        }else if(_position % STEP_SIZE == 0){
            return viewBetEther(_position).add(BASE_BET_ETHER).mul(_position).div(2);       
        }else{
            uint256 _remainder = _position % STEP_SIZE;
            uint256 _bak = _position.sub(_remainder);
            return viewBetEther(_bak).add(BASE_BET_ETHER).mul(_bak).div(2).add(viewBetEther(_position).mul(_remainder));          
        }
    }
    
    function viewSumEther(uint256 _prePosition,uint256 _curPosition) public view returns(uint256 _betEther) {
        if(_prePosition <= 1){
            return _sumEther(_curPosition);
        }
        return _sumEther(_curPosition).sub(_sumEther(_prePosition.sub(1)));
    }

    function _play(uint256 _userMoney) private returns(bool _result,uint256 _toUserMoney){
        _result = false;
        _toUserMoney = _userMoney;
        
        uint256 _betEther = viewBetEther(curPosition.add(1));
        if(_toUserMoney < _betEther){
            return (_result,_toUserMoney);
        }

        curPosition++;
        _toUserMoney= _toUserMoney.sub(_betEther);                   
        thisEther = thisEther.add(_betEther);
        
        uint256 seed = uint256(
            keccak256(
                block.timestamp,
                block.difficulty,
                uint256(keccak256(block.coinbase))/(now),
                block.gaslimit,
                uint256(keccak256(msg.sender))/ (now),
                block.number,
                _betEther,
                getEventId(),
                gasleft()
            )
        );

        uint256 _card =  seed % MAX_LENGTH; 

        emit OnPlay(curPosition, msg.sender, _card, currentEventId, now);

        uint256 _toRewardPlayer = 0;
        if(_isKingKong(_card) || _isStraight(_card)){
            if(curPosition > REWARD_FORWARD_POSITION){
               uint256 _prePosition = curPosition.sub(REWARD_FORWARD_POSITION);
            }else{
                _prePosition = 1;
            }            
            _toRewardPlayer = _rewardKing(_prePosition, _card,msg.sender,uint8(3));
            _toUserMoney= _toUserMoney.add(_toRewardPlayer);  
            _result = true;
            return (_result,_toUserMoney);
       }

       _prePosition = resultOf[_card];
       if(_prePosition != 0 && _prePosition < curPosition && playerBetInfoOf[_prePosition].card == _card ){
            _toRewardPlayer = _reward(_prePosition, _card);
            _toUserMoney= _toUserMoney.add(_toRewardPlayer); 
            _result = true;
            return (_result,_toUserMoney);
       }else{
            betInfo memory bi = betInfo({
                addr :  msg.sender,
                card : _card
            });
            playerBetInfoOf[curPosition] = bi;
            resultOf[_card]=curPosition;
            _result = true;
            return (_result,_toUserMoney);
       }
    }

    function _reward(uint256 _prePosition,uint256 _card) private returns(uint256 _toRewardPlayer){
        _toRewardPlayer = 0;
        require(_prePosition >= 1);

        betInfo memory bi = playerBetInfoOf[_prePosition];
        require(bi.addr != 0x0);

        uint256 _sumRewardMoney = viewSumEther(_prePosition, curPosition);
 
        _toRewardPlayer = _sumRewardMoney.mul(REWARD_WIN_MULTIPLE_PER).div(100) ;
        uint256 _toPrePlayer = _sumRewardMoney.mul(PRE_WIN_MULTIPLE_PER).div(100) ;
        uint256 _toOwner = _sumRewardMoney.sub(_toRewardPlayer).sub(_toPrePlayer);

        emit OnGetAward(curPosition,msg.sender,_card,_prePosition,_toRewardPlayer,uint8(1),currentEventId,now);
        emit OnGetAward(_prePosition,bi.addr,_card,curPosition,_toPrePlayer,uint8(2),currentEventId,now);

        curPosition = _prePosition.sub(1);
        thisEther = thisEther.sub(_sumRewardMoney);
        ownerDividend = ownerDividend.add(_toOwner);
        if(msg.sender != bi.addr){
            bi.addr.transfer(_toPrePlayer);
        }else{
           _toRewardPlayer = _toRewardPlayer.add(_toPrePlayer);
        }
    }
        
    function _rewardKing(uint256 _prePosition,uint256 _card, address _user,uint8 _type) private returns(uint256 _toRewardPlayer){
        _toRewardPlayer = 0;
        require(_prePosition >= 1);
   
        uint256 _sumRewardMoney = viewSumEther(_prePosition, curPosition);
        _toRewardPlayer = _sumRewardMoney.mul(KING_WIN_MULTIPLE_PER).div(100) ; 
        uint256 _toOwner = _sumRewardMoney.sub(_toRewardPlayer);

        emit OnGetAward(curPosition,_user,_card,_prePosition,_toRewardPlayer,_type,currentEventId,now);
        
        curPosition = _prePosition.sub(1);
        thisEther = thisEther.sub(_sumRewardMoney);
        ownerDividend = ownerDividend.add(_toOwner);
    }
}