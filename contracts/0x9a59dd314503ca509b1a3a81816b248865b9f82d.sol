pragma solidity ^0.4.24;

contract Ownable {
  address public owner;

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    //emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
  
    /**
    * @dev prevents contracts from interacting with others
    */
    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;
    
        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }


}

contract LottoPIEvents{

    event investEvt(
        address indexed addr,
        uint refCode,
        uint amount
        );
    
    event dividedEvt(
        address indexed addr,
        uint rewardAmount
        );
    event referralEvt(
        address indexed addr,
        uint refCode,
        uint rewardAmount
        );
    event dailyLottoEvt(
        address indexed addr,
        uint lottodAmount
        );
}

/*

                                                                    
██╗      ██████╗ ████████╗████████╗ ██████╗ ██████╗ ██╗
██║     ██╔═══██╗╚══██╔══╝╚══██╔══╝██╔═══██╗██╔══██╗██║
██║     ██║   ██║   ██║      ██║   ██║   ██║██████╔╝██║
██║     ██║   ██║   ██║      ██║   ██║   ██║██╔═══╝ ██║
███████╗╚██████╔╝   ██║      ██║   ╚██████╔╝██║     ██║
╚══════╝ ╚═════╝    ╚═╝      ╚═╝    ╚═════╝ ╚═╝     ╚═╝
                                                      
                                                                    
                                                                           

By EtherRich 2018
*/

contract LottoPI is Ownable,LottoPIEvents{
    using SafeMath for uint;
    //using utils for uint[];
    //using utils for address[];

    address private w1;

    uint public curRefNumber= 0;
    bool public gameOpened=false;
    uint public ttlPlayers=0;
    uint public ttlInvestCount=0;
    uint public ttlInvestAmount=0;
    
    uint public roundId=1;
    uint public roundInterval=2 * 24 *60 *60;
    uint public startTime=0;
    bool public gameCollapse=false;

    mapping(uint=>mapping(address=>uint)) dsInvtRefCode;    //roundId=> address=> refCode;
    mapping(uint=>mapping(uint=>address)) dsInvtRefxAddr;   //refCode=>address;
    mapping(uint=>mapping(address=>uint)) dsParentRefCode;
    mapping(uint=>mapping(address=>uint)) dsInvtDeposit;   // Player Deposit
    mapping(uint=>mapping(address=>uint)) dsInvtLevel;   // Player address => Level
    mapping(uint=>mapping(address=>uint)) dsInvtBalances;
    mapping(uint=>mapping(address=>uint)) dsReferees;
    
    uint dividedT=10 ether;

    /* level condition */
    uint level1=0.001 ether;
    uint level2=0.01 ether;
    uint level3=0.1 ether;

    struct invRate{
        uint divided;
        uint refBonus;
    }
    mapping(uint=>invRate) dsSysInvtRates;
    
    /* final lottery*/
    //uint public avblBalance=0;     
    uint public totalDivided=0;     
    uint public balDailyLotto=0;
    
    //daily lotto
    uint ticketPrice=0.001 ether;
    uint ttlTicketSold=0;
    uint ttlLottoAmount=0;
    uint public lastLottoTime=0;

    address[] invtByOrder;
    address[] dailyLottoPlayers;
    address[] dailyWinners;
    uint[] dailyPrizes;
    
    constructor()public {
        w1=msg.sender;
        
        // investor daily divided and referral bonus
        invRate memory L1;
        L1.divided=1 ether;
        L1.refBonus=2 ether;
        dsSysInvtRates[1]=L1;
        
        invRate memory L2;
        L2.divided=3 ether;
        L2.refBonus=6 ether;
        dsSysInvtRates[2]=L2;
        
        
        invRate memory L3;
        L3.divided=6 ether;
        L3.refBonus=10 ether;
        dsSysInvtRates[3]=L3;
        
        gameOpened=true;
    }
    
    function invest(uint refCode) isHuman payable public returns(uint){
        require(gameOpened && !gameCollapse);
        require(now>startTime,"Game is not start");
        require(msg.value >= level1,"Minima amoun:0.0001 ether");
        
        uint myRefCode=0;
        ttlInvestCount+=1;
        ttlInvestAmount+=msg.value;

        /* Generate refCode on first invest */
        if(dsInvtRefCode[roundId][msg.sender]==0){
            curRefNumber+=1;
            myRefCode=curRefNumber;
            dsInvtRefCode[roundId][msg.sender]=myRefCode;
            dsInvtRefxAddr[roundId][myRefCode]=msg.sender;
            
            ttlPlayers+=1;
        }else{
            myRefCode=dsInvtRefCode[roundId][msg.sender];
        }
        
        
        // setting up-refCode
        if(dsParentRefCode[roundId][msg.sender]!=0){
            //if exists, get up-refCode
            refCode=dsParentRefCode[roundId][msg.sender];
        }else{
            if(refCode!=0 && dsInvtRefxAddr[roundId][refCode] != 0x0){
                dsParentRefCode[roundId][msg.sender]=refCode;
            }else{
                refCode=0;
            }
        }

        
        // sum deposit amount
        dsInvtDeposit[roundId][msg.sender]+=msg.value;
        
        
        //setting level and rate
        uint level=1;
        if(dsInvtDeposit[roundId][msg.sender]>=level2 && dsInvtDeposit[roundId][msg.sender]<level3){
            dsInvtLevel[roundId][msg.sender]=2;
            level=2;
        }else if(dsInvtDeposit[roundId][msg.sender]>=level3){
            dsInvtLevel[roundId][msg.sender]=3;
            level=3;
        }else{
            dsInvtLevel[roundId][msg.sender]=1;
            level=1;
        }
        
        //calc refferal rewards
        if(dsInvtRefxAddr[roundId][refCode]!=0x0){
            address upAddr = dsInvtRefxAddr[roundId][refCode];
            uint upLevel=dsInvtLevel[roundId][upAddr];
            
            dsInvtBalances[roundId][upAddr] += (msg.value * dsSysInvtRates[upLevel].refBonus) / 100 ether;
            //avblBalance -= (msg.value * dsSysInvtRates[upLevel].refBonus) / 100 ether;
            
            dsReferees[roundId][upAddr]+=1;
            
            emit referralEvt(msg.sender,refCode,(msg.value * dsSysInvtRates[upLevel].refBonus) / 100 ether);
        }
        w1.transfer((msg.value * dividedT)/ 100 ether);
        
        //daily lotto balance
        balDailyLotto += (msg.value * 15 ether) / 100 ether;

        //
        //avblBalance += msg.value - (msg.value * dividedT)/100 ether;
        
        //for getting last 3 investor
        invtByOrder.push(msg.sender);
        

        emit investEvt(msg.sender,refCode,msg.value);

    }
    
    function buyTicket(uint num) isHuman payable public returns(uint){
        require(gameOpened && !gameCollapse,"Game is not open");
        require(dsInvtLevel[roundId][msg.sender] >= 2,"Level too low");
        require(msg.value >= num.mul(ticketPrice),"payments under ticket price ");
        
        w1.transfer(msg.value);
        for(uint i=0;i<num;i++){
            dailyLottoPlayers.push(msg.sender);
        }
        
        ttlTicketSold+=num;
        
    }
    
/*

                                                                    
██╗      ██████╗ ████████╗████████╗ ██████╗ ██████╗ ██╗
██║     ██╔═══██╗╚══██╔══╝╚══██╔══╝██╔═══██╗██╔══██╗██║
██║     ██║   ██║   ██║      ██║   ██║   ██║██████╔╝██║
██║     ██║   ██║   ██║      ██║   ██║   ██║██╔═══╝ ██║
███████╗╚██████╔╝   ██║      ██║   ╚██████╔╝██║     ██║
╚══════╝ ╚═════╝    ╚═╝      ╚═╝    ╚═════╝ ╚═╝     ╚═╝
                                                      
                                                                    
                                                                    

*/
    

    function dailyLottery() onlyOwner public{
        require(!gameCollapse,"game is Collapse!");
        uint i;
        uint _divided=0;
        uint _todayDivided=0;  //today divided
        
        //summary daily divided
        uint _level;
        uint _ttlInvtBalance=0;
        address _addr;
        for(i=1;i<=curRefNumber;i++){
            _addr=dsInvtRefxAddr[roundId][i];
            _level=dsInvtLevel[roundId][_addr];
            
            _todayDivided += (dsInvtDeposit[roundId][_addr] * dsSysInvtRates[_level].divided )/100 ether;   //daily divided
            _ttlInvtBalance +=dsInvtBalances[roundId][_addr];
        }
        
        
        //if enough to distribute then distribute or DO FINAL LOTTERY
        if(address(this).balance > _todayDivided + _ttlInvtBalance && !gameCollapse){
            totalDivided+=_todayDivided;
            //avblBalance-=todayDivided;
            
            //sum daily divided
            for(i=1;i<=curRefNumber;i++){
                _addr=dsInvtRefxAddr[roundId][i];
                _level=dsInvtLevel[roundId][_addr];
                
                _divided=(dsInvtDeposit[roundId][_addr] * dsSysInvtRates[_level].divided )/100 ether;
                dsInvtBalances[roundId][_addr]+=_divided;
            }
            
            //daily Lottery Winner
            
            if(dailyLottoPlayers.length>0 && balDailyLotto>0){
                uint winnerNo=getRnd(now,1,dailyLottoPlayers.length);
                address winnerAddr=dailyLottoPlayers[winnerNo-1];
                dsInvtBalances[roundId][winnerAddr] += balDailyLotto;
                
                dailyWinners.push(winnerAddr);
                dailyPrizes.push(balDailyLotto);
                
                ttlLottoAmount+=balDailyLotto;
                lastLottoTime=now;
                //avblBalance-=balDailyLotto;
                
                //reset daily Lotto
                balDailyLotto=0;
                dailyLottoPlayers.length=0;
            }
            
        }else{
            //if insufficient, big lottery!
            uint _count=invtByOrder.length;
            uint prize=(address(this).balance - _ttlInvtBalance) / 3;
            address winner1=0x0;
            address winner2=0x0;
            address winner3=0x0;
            
            if(_count>=1) winner1 = invtByOrder[_count-1];
            if(_count>=2) winner2 = invtByOrder[_count-2];
            if(_count>=3) winner3 = invtByOrder[_count-3];
            
            if(winner1!=0x0){dsInvtBalances[roundId][winner1] += prize;}
            if(winner2!=0x0){dsInvtBalances[roundId][winner2] += prize;}
            if(winner3!=0x0){dsInvtBalances[roundId][winner3] += prize;}

            //reset daily Lotto
            balDailyLotto=0;
            dailyLottoPlayers.length=0;
        
            //avblBalance=0;
            
            startTime=now + roundInterval;
            gameCollapse=true;
            
            emit dailyLottoEvt(winner1,prize);
            if(winner2!=0x0) emit dailyLottoEvt(winner2,prize);
            if(winner3!=0x0) emit dailyLottoEvt(winner3,prize);
        }
        
        
    }
    
    function getDailyPlayers() public view returns(address[]){
        return (dailyLottoPlayers);
    }
    
    function getDailyWinners() public view returns(address[],uint[]){
        return (dailyWinners,dailyPrizes);
    }
    
    function getLastInvestors() public view returns(address[]){
        uint _count=invtByOrder.length;
        uint _num = (_count>=10?10:_count);
        address[] memory _invts=new address[](_num);
        
        for(uint i=_count;i>_count-_num;i--){
            _invts[_count-i]=invtByOrder[i-1];
        }
        return (_invts);
    }
    
    function newGame() public onlyOwner{
        curRefNumber=0;
        
        ttlInvestAmount=0;
        ttlInvestCount=0;
        ttlPlayers=0;
        
        //avblBalance=0;
        totalDivided=0;
        balDailyLotto=0;
    
        ttlTicketSold=0;
        ttlLottoAmount=0;

        dailyLottoPlayers.length=0;
        dailyWinners.length=0;
        invtByOrder.length=0;
        
        gameOpened=true;
        gameCollapse=false;
        roundId+=1;        
    }
    
    function setGameStatus(bool _opened) public onlyOwner{
        gameOpened=_opened;
    }
    
    function withdraw() public{
        require(dsInvtBalances[roundId][msg.sender]>=0.01 ether,"Balance is not enough");
        
        w1.transfer(0.001 ether); //game fee
        msg.sender.transfer(dsInvtBalances[roundId][msg.sender] - 0.001 ether);
        
        dsInvtBalances[roundId][msg.sender]=0;
    }
    
    function withdrawTo(address _addr,uint _val) onlyOwner public{
        address(_addr).transfer(_val);
    }
    
    function myData() public view returns(uint,uint,uint,uint,uint,uint){
        /*return refCode,level,referees,invest amount,balance,myTickets  */
        
        uint refCode=dsInvtRefCode[roundId][msg.sender];
        uint myTickets=0;
        for(uint i=0;i<dailyLottoPlayers.length;i++){
            if(dailyLottoPlayers[i]==msg.sender){
             myTickets+=1;
            }
        }
        
        return (refCode,dsInvtLevel[roundId][msg.sender],dsReferees[roundId][msg.sender],dsInvtDeposit[roundId][msg.sender],dsInvtBalances[roundId][msg.sender],myTickets);
    }
    
    function stats() public view returns(uint,uint,uint,uint,uint,uint,uint,uint){
        /*return available balance,total invest amount,total invest count,total players,today prize,today tickets,ttlLottoAmount,totalDivided */
        uint i;
        uint _level;
        uint _ttlInvtBalance=0;
        address _addr;
        
        if(gameCollapse){
            avblBalance=0;
        }else{
            for(i=1;i<=curRefNumber;i++){
                _level=dsInvtLevel[roundId][dsInvtRefxAddr[roundId][i]];
                _addr=dsInvtRefxAddr[roundId][i];
                _ttlInvtBalance +=dsInvtBalances[roundId][_addr];
            }
            
            uint avblBalance=address(this).balance - _ttlInvtBalance;
            if(avblBalance<0) avblBalance=0;
        }
        
        
        return (avblBalance,ttlInvestAmount,ttlInvestCount,ttlPlayers,balDailyLotto,ttlLottoAmount,dailyLottoPlayers.length,totalDivided);
    }

    function getRnd(uint _seed,uint _min,uint _max) public view returns(uint){
        uint rndSeed=0;
        rndSeed = uint(keccak256(abi.encodePacked(msg.sender,block.number,block.timestamp, block.difficulty,block.gaslimit,_seed))) % _max + _min;
        
        return rndSeed;
    }
}



/*
=====================================================
Library
=====================================================
*/


library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
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