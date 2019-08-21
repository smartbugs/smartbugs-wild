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
 
    mapping (uint256 => player) public player_;
    mapping (address => uint256) public playAddr_;
    mapping (uint256 => uint256) public playAff_;
    
    mapping (address => uint256) private contractWhite;
    address [] private contractWhitelist;
    
    mapping(address=>uint256) public otherGameAff_;
    
    uint256 private autoPlayId_=123456;
    address public admin_;
    uint256 public gameTicketWei_=10000000000000000;//0.01 ether
    uint8 public leve1Rewards_=50;//%
    uint8 public leve2Rewards_=20;//%
    uint256 public feeAmount_=200;


    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor() public {
        admin_ = msg.sender;
        getPlayId();
        contractWhitelist.push(address(0));
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
        if(_affCode>0 && _affCode != _pid && player_[_affCode].id >0)
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
        player_[playAddr_[admin_]].balance=add(player_[playAddr_[admin_]].balance,adminAmount);
    }
    
    
    function withdraw(uint256 pid) safe() external{
        require(playAddr_[msg.sender] == pid,'Error Action');
        require(player_[pid].addr == msg.sender,'Error Action');
        require(player_[pid].balance >= gameTicketWei_,'Insufficient balance');
        uint256 balance =player_[pid].balance;
        player_[pid].balance=0;
        player_[pid].addr.transfer(balance);
    }
    

    
    function getPlayId() private returns(uint256){
        
         require(
                playAddr_[msg.sender] ==0,
                "Error Player"
            );
        
        autoPlayId_++;
        uint256 _pid=autoPlayId_;
       
        playAddr_[msg.sender]=_pid;
        player_[_pid].id=_pid;
        player_[_pid].addr=msg.sender;
        player_[_pid].balance=0;
        player_[_pid].timeStamp=now;    
        return _pid;
   }
   
     modifier  isPlay(){
            require(
                playAddr_[msg.sender] == 0,
                "Everyone can only participate once"
                );        
            _;
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
        
    function getOtherGameAff() external view returns(uint256,address,address){
        uint256 pid=otherGameAff_[msg.sender];
        require(pid>0 && player_[pid].id>0);
        uint256 level2Pid = playAff_[pid];
        return(
            pid,
            player_[pid].addr,
            player_[level2Pid].addr
            );
    }
  
    //Create a user's sharing relationship
    function addOtherGameAff(uint256 pid,address myAddr,address level1,address level2) public{
        
        uint256 _codeLength;
        address _addr = msg.sender;
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength > 0, "Sender not authorized!");
        require(contractWhite[_addr]>0,'ERROR');
        require(address(0)!= myAddr);
        require(pid >0 && address(0)!= level1 && player_[pid].addr == level1,'Error1');
        require(myAddr!=level1,'Error4');
        require(myAddr!=level2,'Error4');
        uint256  level2Pid=playAff_[pid];
        require(level2==player_[level2Pid].addr,'Error2');
        uint256 addfPid=otherGameAff_[myAddr];        
        if(addfPid>0){
            require(addfPid ==pid);
            return;
        }
        otherGameAff_[myAddr]=pid;
    }
    
    //update Can get a contract to share information
    function updateCW(address addr,uint8 status) external safe(){
        require(msg.sender==admin_);
        if(status==0){
            if(contractWhite[addr]==0){
                contractWhitelist.push(addr);
                contractWhite[addr]=contractWhitelist.length;
            }
        }else{
           delete contractWhitelist[contractWhite[addr]];
           delete  contractWhite[addr];
        }
    }
    
      //2020.01.01 Close Game
   function closeGame() external safe() {
        uint256 closeTime=1577808000;
        require(now > closeTime,'Time has not arrived');
        require(msg.sender == admin_,'Error');
        selfdestruct(admin_);
    }
    
    function getCwList() external  safe()  view returns( address []){
         require(msg.sender==admin_);
         return contractWhitelist;
    }
        
}