pragma solidity ^0.4.24;
library Datasets {
    struct Player {
        uint256 currentroundIn0;
        uint256 currentroundIn1;
        uint256 allRoundIn;
        uint256 win;    // total winnings vault
        uint256 lastwin;
        uint256 withdrawed;
    }
    struct Round {
        uint256 strt;   // height round started
        uint256 end;    // height round ended
        bool ended;
        uint256 etc0;//etc for bull
        uint256 etc1;//etc for bear
        int win;//0 for bull,1 for bear
    }
    struct totalData{
        uint256 bullTotalIn;
        uint256 bearTotalIn;
        uint256 bullTotalWin;
        uint256 bearTotalWin;
    }
}
contract Lotteryevents {
    event onBuys
    (
        address addr,
        uint256 amount,
        uint8 _team
    );
    event onWithdraw
    (
        address playerAddress,
        uint256 out,
        uint256 timeStamp
    );
    event onBuyAndDistribute
    (
        uint256 rid,
        uint256 strt,   // height round started
        uint256 end,    // height round ended
        uint256 etc0,//etc for bull
        uint256 etc1,//etc for bear
        int win//0 for bull,1 for bear
    );
}
contract NXlottery is Lotteryevents{
    using SafeMath for *;
    uint8 constant private rndGap_ = 100;
    uint8 constant private lotteryHei_ = 10;
    uint8 constant private fee = 5;
    uint8 constant private maxLimit=200;
    uint256 constant private splitThreshold=3000000000000000000;
    uint256 private feeLeft=0;
    address private creator;
    Datasets.Round private currRound;
    Datasets.Round private lastRound;//lastRound=currRound when clearing
    uint256 private rID_=1;    // round id number / total rounds that have happened
    address[] private allAddress;//allAddress.push(addre)
    mapping (address => Datasets.Player) private allPlayer;
    Datasets.totalData private total;
    constructor() public {
        creator = msg.sender;
        uint256 curr=block.number;
        currRound.strt = curr;
        currRound.end = curr+rndGap_;
        currRound.ended = false;
        currRound.win = 0;
    }
    function getFee()
        isCreator()
        public
        view
        returns(uint256)
    {
        return (feeLeft);
    }
    function getBlock()
        public
    {
       splitPot();//lotteryHei_
    }
    function withdrawFee(uint256 amount)
        isCreator()
        public
    {
        if(feeLeft>=amount)
        {
            feeLeft=feeLeft.sub(amount);
            msg.sender.transfer(amount);
        }
    }
    function playerWithdraw(uint256 amount)
        public
    {
        address _customerAddress = msg.sender;
        uint256 left=allPlayer[_customerAddress].win.sub(allPlayer[_customerAddress].withdrawed);

        if(left>=amount)
        {
            allPlayer[_customerAddress].withdrawed=allPlayer[_customerAddress].withdrawed.add(amount);
            _customerAddress.transfer(amount);
            emit Lotteryevents.onWithdraw(msg.sender, amount, now);
        }
    }
    modifier isHuman() {
        address _addr = msg.sender;
        require (_addr == tx.origin);
        uint256 _codeLength;

        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }

    modifier isWithinLimits(uint256 amount) {
        require(amount >= 10000000000000000, "too little");//0.01
        require(amount <= 100000000000000000000, "too much");//100
        _;
    }
    modifier canClearing() {
        require(currRound.end-lotteryHei_<=block.number, "cannot clearing");
        require(currRound.ended==false, "already cleared");
        _;
    }
    modifier isCreator() {
        require(creator == msg.sender, "not creator");
        _;
    }

    function()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {
        allBuyAmount(msg.value,0);
    }
    function reinvest(uint256 amount, uint8 _team)
        isHuman()
        public
    {
        address _customerAddress = msg.sender;
        uint256 left=allPlayer[_customerAddress].win.sub(allPlayer[_customerAddress].withdrawed);

        if(left>=amount)
        {
            allPlayer[_customerAddress].withdrawed=allPlayer[_customerAddress].withdrawed.add(amount);
            allBuyAmount(amount,_team);
        }
    }
    function buy(uint8 _team)
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {
        allBuyAmount(msg.value,_team);
    }
    function allBuyAmount(uint256 amount,uint8 _team)
        internal
    {
        require((_team == 0)||(_team == 1),"team 0 or 1");
        Core(msg.sender,amount,_team);
        emit Lotteryevents.onBuys
        (
            msg.sender,
            amount,
            _team
        );
    }
    function Core(address addr, uint256 amount, uint8 _team)
        private
    {
        if((block.number>=currRound.end-lotteryHei_))
        {
            if(block.number < currRound.end){
                uint256 currAllIn=currRound.etc0+currRound.etc1;
                if(currAllIn<splitThreshold){
                    currRound.end=block.number+rndGap_;
                } else {
                    allPlayer[addr].win+=amount;
                    return;
                }
            } else {
                allPlayer[addr].win+=amount;
                return;
            }
        }
        if(allAddress.length>=maxLimit)
        {
            allPlayer[addr].win+=amount;
            return;
        }
        uint i=0;
        for (;i < allAddress.length; i++) {
            if(addr==allAddress[i])
                break;
        }
        if(i>=allAddress.length){
            allAddress.push(addr);
        }
        if(_team==0){
            allPlayer[addr].currentroundIn0=allPlayer[addr].currentroundIn0.add(amount);
            currRound.etc0=currRound.etc0.add(amount);
            total.bullTotalIn=total.bullTotalIn.add(amount);
        }else{
            allPlayer[addr].currentroundIn1=allPlayer[addr].currentroundIn1.add(amount);
            currRound.etc1=currRound.etc1.add(amount);
            total.bearTotalIn=total.bearTotalIn.add(amount);
        }
        allPlayer[msg.sender].allRoundIn=allPlayer[msg.sender].allRoundIn.add(amount);
    }
    // Lottery
    function splitPot()
        canClearing()
        private
    {
        uint256 currAllIn=currRound.etc0+currRound.etc1;
        if(currAllIn<splitThreshold){
            currRound.end=block.number+rndGap_;
            return;
        }
        if(currRound.end > block.number){
            return;
        }

        uint8 whichTeamWin=sha(currRound.end); //Determine the winning team
        if(currRound.etc0 <= 0){
        	if(allAddress.length>=maxLimit){//Doomed to failure
        		whichTeamWin = 1;
        	}else{
        		currRound.end=block.number+rndGap_;
        		return;
        	}
        }
        if(currRound.etc1 <= 0){
        	if(allAddress.length>=maxLimit){//Doomed to failure
        		whichTeamWin = 0;
        	}else{
        		currRound.end=block.number+rndGap_;
        		return;
        	}
        }

        currRound.win=whichTeamWin;
        uint256 fees=currAllIn.mul(fee).div(100);
        uint256 pot=currAllIn.sub(fees);
        feeLeft=feeLeft.add(fees);

        uint256 currentIn;
        if(whichTeamWin==0){
            currentIn=currRound.etc0;
        }else{
            currentIn=currRound.etc1;
        }
        //Distribution prize pool
        for (uint i=0;i < allAddress.length; i++) {
            address curr=allAddress[i];

            uint256 temp;
            if(whichTeamWin==0){
                temp=allPlayer[curr].currentroundIn0;
            }else{
                temp=allPlayer[curr].currentroundIn1;
            }
            uint256 amount=0;
            if(temp > 0)
            {
                 amount=pot.mul(temp).div(currentIn);
                 allPlayer[curr].win=allPlayer[curr].win.add(amount);
            }
            allPlayer[curr].lastwin=amount;
            allPlayer[curr].currentroundIn0=0;
            allPlayer[curr].currentroundIn1=0;
        }
        currRound.ended=true;
        lastRound=currRound;
        emit Lotteryevents.onBuyAndDistribute
        (
            rID_,
            lastRound.strt,
            lastRound.end,
            lastRound.etc0,
            lastRound.etc1,
            lastRound.win
        );

        uint256 currBlock=block.number+1;
        rID_++;
        currRound.strt = currBlock;
        currRound.end = currBlock+rndGap_;
        currRound.ended = false;
        currRound.win = 0;
        currRound.etc0=0;
        currRound.etc1=0;

        if(whichTeamWin==0){
            total.bullTotalWin=total.bullTotalWin.add(pot);
        }else{
            total.bearTotalWin=total.bearTotalWin.add(pot);
        }

        delete allAddress;
        allAddress.length=0;
    }
    function getAddressLength()
        public
        view
        returns(uint256)
    {
        return (allAddress.length);
    }
    function getAddressArray()constant public returns(address,address)
    {
        return (allAddress[0],allAddress[1]);
    }

    function getCurrentRoundLeft()
        public
        view
        returns(uint256)
    {
        uint256 _now = block.number;

        if (_now < currRound.end)
            return( (currRound.end).sub(_now) );
        else
            return(0);
    }
    function getEndowmentBalance() constant public returns (uint)
    {
    	return address(this).balance;
    }
    function getCreator() constant public returns (address)
    {
    	return creator;
    }
    function sha(uint256 end) constant private returns(uint8)
    {
        bytes32 h=blockhash(end-lotteryHei_);
        if(h[31]&(0x0f)>8)
        return 1;
        return 0;  //0 for bull,1 for bear;
    }

    function getLastRoundInfo()
      public
      view
      returns (uint256,uint256,uint256,uint256,bool,int)
    {
        return
        (
            lastRound.strt,
            lastRound.end,
            lastRound.etc0,
            lastRound.etc1,
            lastRound.ended,
            lastRound.win
        );
    }
  	function getCurrentInfo()
      public
      view
      returns (uint256,uint256,uint256,uint256,uint256,bool,int)
    {
        return
        (
            rID_,
            currRound.strt,
            currRound.end,
            currRound.etc0,
            currRound.etc1,
            currRound.ended,
            currRound.win
        );
    }
    function getTotalInfo()
      public
      view
      returns (uint256,uint256,uint256,uint256)
    {
        return
        (
            total.bullTotalIn,
            total.bearTotalIn,
            total.bullTotalWin,
            total.bearTotalWin
        );
    }
    function getPlayerInfoByAddress(address addr)
        public
        view
        returns (uint256, uint256,uint256, uint256, uint256, uint256)
    {
        address _addr=addr;
        if (_addr == address(0))
        {
            _addr = msg.sender;
        }

        return
        (
            allPlayer[_addr].currentroundIn0,
            allPlayer[_addr].currentroundIn1,
            allPlayer[_addr].allRoundIn,
            allPlayer[_addr].win,
            allPlayer[_addr].lastwin,
            allPlayer[_addr].withdrawed
        );
    }

    function kill()public
    {
        if (msg.sender == creator)
            selfdestruct(creator);  // kills this contract and sends remaining funds back to creator
    }
}
library SafeMath {

    function mul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }
}