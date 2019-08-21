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


contract gameShare is safeApi{
    struct player
    {
        uint256 id;
        address addr;
        uint256 balance;//wei
        uint256 affNumLevel_1;
        uint256 affNumLevel_2;
        uint256 timeStamp;
    }
 
    mapping (uint256 => player)  player_;
    mapping (address => uint256)  playAddr_;
    mapping (uint256 => uint256)  playAff_;
    


    uint256 private autoPlayId_=123456;
    address  admin_;
    uint256  gameTicketWei_=0.01 ether;
    uint8  leve1Rewards_=50;//%
    uint8  leve2Rewards_=20;//%
    uint8  feeAmount_=100;


    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor() public {
        admin_ = msg.sender;
        getPlayId();
    }
    
    /* Send coins */
    function addGame(uint256 _affCode)
    safe() 
    isPlay() 
    external
    payable {
        
      if(_affCode == 0 &&  feeAmount_>0){
             feeAmount_--;
      }else{
         require(msg.value == gameTicketWei_,'Please pay the correct eth');
      }
       uint256 _pid=getPlayId();
      if(msg.value==0)
        return;
        uint256 adminAmount=msg.value;
        uint adminId=playAddr_[admin_];
        if( _affCode>0 && _affCode!=adminId && _affCode != _pid && player_[_affCode].id >0)
        {
             uint256 leve1Amount=safePercent(leve1Rewards_,gameTicketWei_);
             player_[_affCode].affNumLevel_1++;
             playAff_[_pid]=player_[_affCode].id;
             adminAmount-=leve1Amount;
             player_[_affCode].balance+=leve1Amount;
             uint256 leve2Pid=playAff_[_affCode];
              if(leve2Pid>0){
                uint256 leve2Amount=safePercent(leve2Rewards_,gameTicketWei_);
                player_[leve2Pid].affNumLevel_2++;
                adminAmount-=leve2Amount;
                player_[leve2Pid].balance+=leve2Amount;
              }
        }
        player_[adminId].balance=add(player_[adminId].balance,adminAmount);
}
    
    
    function withdraw(uint256 pid) safe() external{
        require(playAddr_[msg.sender] == pid,'Error Action');
        require(player_[pid].addr == msg.sender,'Error Action');
        require(player_[pid].balance >= gameTicketWei_,'Insufficient balance');
        uint256 balance =player_[pid].balance;
        player_[pid].balance=0;
        player_[pid].addr.transfer(balance);
    }
    
    
function getMyInfo()external view returns(uint,uint,uint,uint,uint){
       uint _pid =playAddr_[msg.sender];
       player memory _p=player_[_pid];
       return(
            _pid,
            _p.balance,
            _p.affNumLevel_1,
            _p.affNumLevel_2,
            _p.timeStamp
        );
  }
   
  //2020.01.01 Used to update the game
   function updateGame() external safe() {
        uint256 closeTime=1577808000;
        require(now > closeTime,'Time has not arrived');
        require(msg.sender == admin_,'Error');
        selfdestruct(admin_);
    }
    
    function getPlayId() private returns(uint256){
        
        address _addr=msg.sender;
         require(
                playAddr_[_addr] ==0,
                "Error Player 2"
            );
        
              autoPlayId_++;
              uint256 _pid=autoPlayId_;
              playAddr_[_addr]=_pid;
              player memory _p;
              _p.id=_pid;
              _p.addr=_addr;
              _p.timeStamp=now;
              player_[_pid]=_p;
              return _pid;
   }
   
     modifier  isPlay(){
            require(
                playAddr_[msg.sender] == 0,
                "Everyone can only participate once"
                );        
            _;
        }
    
      //Add extra prizes to the prize pool ETH
  function payment() external payable safe(){
    if(msg.value>0){
        uint adminId=playAddr_[admin_];
        player_[adminId].balance=add(player_[adminId].balance,msg.value);
    }
  }    
        
    
    function getShareAff(uint256 _affCode) external view returns(uint256,address,address){
        uint256 pid=playAddr_[msg.sender];
        uint256 level1pid=playAff_[pid];
        if(pid>0 && level1pid>0){
          uint256 level2Pid=playAff_[level1pid];
          return(
            player_[level1pid].id,
            player_[level1pid].addr,
            player_[level2Pid].addr
            );
        }
        uint256 level2Pid=playAff_[_affCode];
        return(
            player_[_affCode].id,
            player_[_affCode].addr,
            player_[level2Pid].addr
            );
    }
   
  
   function getFeeAmount() external view returns(uint8){
       return feeAmount_;
   }
   
    
}