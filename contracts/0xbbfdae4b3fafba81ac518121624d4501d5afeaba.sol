/*
 ______   _________  ___   ___   _______    _______             ________  ______      
/_____/\ /________/\/__/\ /__/\ /______/\  /______/\           /_______/\/_____/\     
\::::_\/_\__.::.__\/\::\ \\  \ \\::::__\/__\::::__\/__         \__.::._\/\:::_ \ \    
 \:\/___/\  \::\ \   \::\/_\ .\ \\:\ /____/\\:\ /____/\  ___      \::\ \  \:\ \ \ \   
  \::___\/_  \::\ \   \:: ___::\ \\:\\_  _\/ \:\\_  _\/ /__/\     _\::\ \__\:\ \ \ \  
   \:\____/\  \::\ \   \: \ \\::\ \\:\_\ \ \  \:\_\ \ \ \::\ \   /__\::\__/\\:\_\ \ \ 
    \_____\/   \__\/    \__\/ \::\/ \_____\/   \_____\/  \:_\/   \________\/ \_____\/ 
  ______ _______ _    _    _____  ____   ____  _____     _____          __  __ ______  _____ 
 |  ____|__   __| |  | |  / ____|/ __ \ / __ \|  __ \   / ____|   /\   |  \/  |  ____|/ ____|
 | |__     | |  | |__| | | |  __| |  | | |  | | |  | | | |  __   /  \  | \  / | |__  | (___  
 |  __|    | |  |  __  | | | |_ | |  | | |  | | |  | | | | |_ | / /\ \ | |\/| |  __|  \___ \ 
 | |____   | |  | |  | | | |__| | |__| | |__| | |__| | | |__| |/ ____ \| |  | | |____ ____) |
 |______|  |_|  |_|  |_|  \_____|\____/ \____/|_____/   \_____/_/    \_\_|  |_|______|_____/ 
                                                                                             
                                                         BY : LmsSky@Gmail.com
*/                            
pragma solidity ^0.4.25;
pragma experimental "v0.5.0";
contract safeApi{
    
   modifier safe(){
        address _addr = msg.sender;
        require (_addr == tx.origin,'Error Action!');
        uint256 _codeLength;
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "Sender not authorized!");
            _;
    }


    
 function toBytes(uint256 _num) internal returns (bytes _ret) {
   assembly {
        _ret := mload(0x10)
        mstore(_ret, 0x20)
        mstore(add(_ret, 0x20), _num)
    }
}

function subStr(string _s, uint start, uint end) internal pure returns (string){
        bytes memory s = bytes(_s);
        string memory copy = new string(end - start);
//        string memory copy = new string(5);
          uint k = 0;
        for (uint i = start; i < end; i++){ 
            bytes(copy)[k++] = bytes(_s)[i];
        }
        return copy;
    }
     

 function safePercent(uint256 a,uint256 b) 
      internal
      constant
      returns(uint256)
      {
        assert(a>0 && a <=100);
        return  div(mul(b,a),100);
      }
      
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
 
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0∂
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
 
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
 
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

}
contract gameFinances is safeApi{
mapping(bytes32=>uint)  validQueryId;
    struct player
    {
        uint64 id;
        uint32 affNumLevel_1;
        uint32 affNumLevel_2;
        uint32 timeStamp;
        uint balance;//wei
        uint gameBalance;
        address addr;
    }

    struct  gameConfig
    {
         uint8 eachPct;
         uint8 feePct;
         uint8 poolPct;
         uint8 adminPct;
         uint8 levelPct1;
         uint8 levelPct2;
         uint16 index;
         uint32 maxPct;
         uint64 autoPlayId;
    }
    
   struct  orderInfo
    {  
       uint64 pid;
       uint32 pct;
       uint32 times;
       uint eth;
       uint balance;
    }
    
    struct gameInfo{
       uint64 winner;
       uint32 pointer;
       uint bonus;//Additional bonuses other than the prize pool are issued by the admin
       uint totalEth;
       uint lastTime;
       uint startTime;
       orderInfo[] list;
       mapping(uint64=>playerRecord) pinfo;
    }
    
      struct  playerRecord
    {  
       bool status;
       uint32 times;
    } 
    
    event join(
        uint16 indexed index,
        uint key,
        address indexed addr
    );
    
   
    event next_game(
        uint16 indexed index
        ); 
    
     mapping (uint64 => player)  player_;
     mapping (address => uint64)  playAddr_;
     mapping (uint64 => uint64)  playAff_;
     mapping(uint16 =>gameInfo) gameInfo_;

     gameConfig  gameConfig_;
     address  admin_;
  
     constructor() public {
         admin_ = msg.sender;
         getPlayId(msg.sender);
         gameConfig_.eachPct=20;
         gameConfig_.maxPct=100;
         gameConfig_.feePct=6;
         gameConfig_.poolPct=70;
         gameConfig_.adminPct=15;
         gameConfig_.levelPct1=10;
         gameConfig_.levelPct2=5;
         gameConfig_.index=1;
         gameInfo_[1].startTime=now;
    }
    
function  joinGame(address _level1, address _level2) external payable safe(){
        uint16 _index=gameConfig_.index;
        gameInfo storage _g=gameInfo_[_index];
        uint _now=now;
        if(_g.lastTime>0){
          require(_g.lastTime+86400 >_now,'Please wait for the start of the next round');
        }
        uint64 _pid=getPlayId(msg.sender);
        initAddf(_pid,_level1,_level2);
        uint _value=msg.value;
        require(_value>=0.1 ether && _value<= 100 ether,'Eth Error');
        require(_value%0.1 ether==0,'Eth Error2');
        playerRecord storage _pr=_g.pinfo[_pid];
        _g.totalEth=add(_g.totalEth,_value);
        require(_pr.status==false,'Last settlement has not been completed');
        _pr.status=true;
        _pr.times++;
         gameMatch(_g,_value);
         uint32 _pct=gameConfig_.maxPct;
        if(_pr.times<5){
               _pct=_pr.times * gameConfig_.eachPct;
        }
        uint _balance = add(_value,safePercent(_pct,_value));
        _g.list.push(orderInfo(
            _pid,
            _pct,
             _pr.times,
            _value,
            _balance
          ));
      _g.lastTime=_now;

      emit join(_index,_g.list.length,msg.sender);
}

//Start the next round of games
function nextGame() external safe(){
    require(msg.sender == admin_,'Error 1');
    uint16 _index=gameConfig_.index;
    uint  _endTime=gameInfo_[_index].lastTime+86400;
    uint _now=now;
    require(_now > _endTime,'Error 2');
     emit next_game(_index);
     uint _lastIndex=gameInfo_[_index].list.length;
     //Transfer to the winner
     if(_lastIndex>0){
         uint64 _winnerId=gameInfo_[_index].list[_lastIndex-1].pid;
         uint _prizePool=safePercent(gameConfig_.feePct,gameInfo_[_index].totalEth);
         _prizePool=safePercent(gameConfig_.poolPct,_prizePool);
         _prizePool=add(_prizePool,gameInfo_[_index].bonus);//Additional bonuses other than the prize pool are issued by the admin
         uint _adminFee =  safePercent(gameConfig_.feePct,_prizePool);//Admin fee
         uint64 _adminId=playAddr_[admin_];
         player_[_adminId].balance=add(player_[_adminId].balance,_adminFee);
         uint _winnerAmount=sub(_prizePool,_adminFee);
         player_[_winnerId].addr.transfer(_winnerAmount);
     }
    _index++;
    gameConfig_.index=_index;
    gameInfo_[_index].startTime=_now;
}

function gameMatch(gameInfo storage _g,  uint _value) private{
        uint _length=_g.list.length;
        if(_length==0){
             uint64 adminId=playAddr_[admin_];
             player_[adminId].gameBalance=add(player_[adminId].gameBalance,_value);
             return;
        }
            uint _myBalance=_value;
            for(uint32 i=_g.pointer;i<_length;i++){
                orderInfo storage  _gip=_g.list[i];
                if(_gip.balance==0)
                     break;
                if(_myBalance>=_gip.balance){
                    _g.pinfo[_gip.pid].status=false;
                    _myBalance=sub(_myBalance,_gip.balance);
                    player_[_gip.pid].gameBalance=add( player_[_gip.pid].gameBalance,_gip.balance);
                    _gip.balance=0;
                    _g.pointer++;
                }else{
                    _gip.balance=sub(_gip.balance,_myBalance);
                    player_[_gip.pid].gameBalance=add(player_[_gip.pid].gameBalance,_myBalance);
                    _myBalance=0;
                    break;
               }
            }
            if(_myBalance>0){
                uint64 adminId=playAddr_[admin_];
                player_[adminId].gameBalance=add(player_[adminId].gameBalance,_myBalance);
            }
}
    
function initAddf(uint64 _pid,address _level1, address _level2) private{
    
            address  _errorAddr=address(0);
            uint64 _level1Pid=playAff_[_pid];
            if(_level1Pid>0 || _level1 ==_errorAddr || _level1==_level2 || msg.sender==_level1 || msg.sender==_level2)
               return;
           if(_level1Pid==0 && _level1 == _errorAddr){
                  uint64 adminId=playAddr_[admin_];
                  playAff_[_pid]=adminId;
                  return;
           }
              _level1Pid= playAddr_[_level1];
              if(_level1Pid==0){
                 _level1Pid=getPlayId(_level1);
              }
                  player_[_level1Pid].affNumLevel_1++;
                  playAff_[_pid]=_level1Pid;
                  uint64 _level2Pid=playAff_[_level1Pid];
                  
                  if(_level2Pid==0 &&  _level2 == _errorAddr){
                     return;   
                  }
                     _level2Pid= playAddr_[_level2];
                    if(_level2Pid==0){
                       _level2Pid=getPlayId(_level2);
                        playAff_[_level1Pid]=_level2Pid;
                    }
                    player_[_level2Pid].affNumLevel_2++;
}

    
function withdraw(uint64 pid) safe() external{
        require(playAddr_[msg.sender] == pid,'Error Action');
        require(player_[pid].addr == msg.sender,'Error Action');
        require(player_[pid].balance > 0,'Insufficient balance');
        uint balance =player_[pid].balance;
        player_[pid].balance=0;
        player_[pid].addr.transfer(balance);
}


 function withdrawGame(uint64 pid) safe() external{
        require(playAddr_[msg.sender] == pid,'Error Action');
        require(player_[pid].addr == msg.sender,'Error Action');
        require(player_[pid].gameBalance >0,'Insufficient balance');
        uint _balance =player_[pid].gameBalance;
        player_[pid].gameBalance=0;
        uint64 _level1Pid=playAff_[pid];
        uint64 _adminId=playAddr_[admin_];
        //Withdrawal fee
        uint _fee=safePercent(gameConfig_.feePct,_balance);
        //The prize pool has been increased when the investment is added, there is no need to operate here.
        //Admin
        uint _adminAmount=safePercent(gameConfig_.adminPct,_fee);
        
        //1 Level
        uint levellAmount=safePercent(gameConfig_.levelPct1,_fee);
        
        //2 Level
        uint level2Amount=safePercent(gameConfig_.levelPct2,_fee);
        if(_level1Pid >0 && _level1Pid!=_adminId){
            player_[_level1Pid].balance=add(player_[_level1Pid].balance,levellAmount);
            uint64 _level2Pid=playAff_[_level1Pid];
             if(_level2Pid>0){
                player_[_level2Pid].balance=add(player_[_level2Pid].balance,level2Amount);
             }else{
                _adminAmount=add(_adminAmount,level2Amount);
             }
        }else{
            _adminAmount=add(_adminAmount,add(levellAmount,level2Amount));
        }
        player_[_adminId].balance=add(player_[_adminId].balance,_adminAmount);
        return player_[pid].addr.transfer(sub(_balance,_fee));
    }
   
     //2020.01.01 Used to update the game
   function updateGame() external safe() {
        uint time=1577808000;
        require(now > time,'Time has not arrived');
        require(msg.sender == admin_,'Error');
        selfdestruct(admin_);
    }
   
    function getPlayId(address addr) private returns(uint64){
        require (address(0)!=addr,'Error Addr');
        if(playAddr_[addr] >0){
         return playAddr_[addr];
        }
              gameConfig_.autoPlayId++;
              playAddr_[addr]=  gameConfig_.autoPlayId;
              player memory _p;
              _p.id=  gameConfig_.autoPlayId;
              _p.addr=addr;
              _p.timeStamp=uint32(now);
              player_[gameConfig_.autoPlayId]=_p;
              return gameConfig_.autoPlayId;
   }
   
   function getGameInfo(uint16 _index)external view returns(
       uint16,uint,uint,uint,uint,uint,uint
       ){ 
        gameInfo memory _g;
       if(_index==0){
             _g=gameInfo_[gameConfig_.index];
       }else{
             _g=gameInfo_[_index];
       }
       return(
             gameConfig_.index,
             _g.bonus,//Additional bonuses other than the prize pool are issued by the admin
            _g.totalEth,
            _g.startTime,
            _g.lastTime,
            _g.list.length,
            gameInfo_[gameConfig_.index].list.length
        );
  }
  
  function getOrderInfo(uint16 _index, uint64 _key)external view returns(uint32,uint,uint,uint32){ 
           uint64 _pid =playAddr_[msg.sender];
       orderInfo memory _g=gameInfo_[_index].list[_key];
       require(_g.pid==_pid,'Error 404');
       return(
            _g.pct,
            _g.eth,
            _g.balance,
            _g.times
        );
  }
    
  function getMyGameStatus(uint16 _index)external view returns (bool,uint32){
         uint64 _pid =playAddr_[msg.sender];
         playerRecord memory _g;
       if(_index>0){
           _g=gameInfo_[_index].pinfo[_pid];
       }else{
             _g=gameInfo_[gameConfig_.index].pinfo[_pid];
       }
      return (
            _g.status,
            _g.times
          );
  }
  
 function getMyInfo()external view returns(uint64,uint,uint32,uint32,uint32,uint){ 
       uint64 _pid =playAddr_[msg.sender];
       player memory _p=player_[_pid];
       return(
            _pid,
            _p.balance,
            _p.affNumLevel_1,
            _p.affNumLevel_2,
            _p.timeStamp,
            _p.gameBalance
        );
  }
  
  //Add extra prizes to the prize pool ETH
  function payment() external payable safe(){
      //Additional bonuses other than the prize pool are issued by the admin
      if(msg.value>0)
     gameInfo_[gameConfig_.index].bonus=add(gameInfo_[gameConfig_.index].bonus,msg.value);
  }
  

  function getConfig() external view returns(
       uint8,uint8,uint8,uint8,uint8,uint8,uint32
       ){
     return (      
         gameConfig_.eachPct,
         gameConfig_.feePct,
         gameConfig_.poolPct,
         gameConfig_.adminPct,
         gameConfig_.levelPct1,
         gameConfig_.levelPct2,
        gameConfig_.maxPct
      );
    }
}