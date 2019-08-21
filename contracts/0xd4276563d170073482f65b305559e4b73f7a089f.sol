pragma solidity ^0.4.24;

pragma experimental ABIEncoderV2;

contract JanKenPonEvents {
	event onJoinGame(
        address player,
        uint256 buyer_keys,
        uint256 round,
        uint256 curPrice,
        uint256 endTime
    );
    
    event onWithdrawBenefit();
    
    event onSellOrder();
    
    event onCancelOrder();
    
    event onBuyOrder();
    
    event onStartGame(
        uint256 curPrice,
        uint256 round,
        uint256 endTime
    );
    
    event onPK(
        uint256 playerA,
        uint256 cardA,
        uint256 playerB,
        uint256 cardB
    );
}

library JanKenPonData {

	 struct playerPacket{
        uint256 pId;
        address owner;
        uint8[3] cards;
        uint8 cardIndex;
        uint8 stars;
        bool isSelling;
        uint256 price;
        uint256 count;
		bool isWithDrawWiner;
        bool isWithDrawShare;
        bool isWithdrawBenefit;
		bool isWithDrawLastBuyer;
    }

    struct rateTeam {
        uint256 curPrice;
        uint256 incPrice;
        uint256 rateCom;
        uint256 rateWin;
        uint256 rateLast;
        uint256 rateBen;
        uint256 rateShare;
        uint256 rateNext;
    }

    struct Round {
        address lastWiner;
        uint256 lastBuyerId;
        uint256 pId_inc;
        uint256 rand_begin;
        uint256[] success_pIds;
        uint256[] failed_pIds;
        uint256[] order_pIds;
        uint256  endTime;
        uint256 totalCoin;
        uint256 totalCount;
        bool  is_activated;
		bool  isWithDrawCom;
        rateTeam team;
        mapping(address => uint256[])  mAddr_pid;
        mapping(uint256 => JanKenPonData.playerPacket)  mId_upk;
        mapping(uint8 => uint256) mCardId_count;
    }
}


contract JanKenPon is JanKenPonEvents {

    using SafeMath for *;

    address private creator;
    uint256 private round_Id;
    uint256 private rand_nonce;
    
    uint256 private indexA;
    
    uint256 constant private conmaxTime = 72 hours;
    uint256 constant private intervelTime = 30 seconds;
    
    mapping (uint256 => JanKenPonData.Round) private rounds;

    

   
    
constructor ()
        public
    {
        creator = msg.sender;
    }
    
function updateEndTime(uint256 keys)
    private
    {
     uint256 nowTime = now;
     uint256 newTime;

     if (nowTime > rounds[round_Id].endTime){
         setGameOver();
         rounds[round_Id].totalCoin = address(this).balance;
         return;
     }
     
     newTime = (keys).mul(intervelTime).add(rounds[round_Id].endTime);

     if (newTime < (conmaxTime).add(nowTime))
            rounds[round_Id].endTime = newTime;
     else
            rounds[round_Id].endTime = conmaxTime.add(now);
     
     }

function getGameInfo()
    public
    constant
    returns(uint256,uint256,uint256,uint256,uint256)
    {
        return(round_Id,rounds[round_Id].pId_inc,rounds[round_Id].success_pIds.length,rounds[round_Id].failed_pIds.length,address(this).balance);
    }
    
function getEndTime()
    public
    constant
    returns(uint256)
    {
        return rounds[round_Id].endTime;
    }

function getRand()
    constant
    public
    returns(uint256)
    {
        return rounds[round_Id].rand_begin;
    }

function getJKPCount()
    constant
    public
    returns(uint256,uint256,uint256)
    {
        return (rounds[round_Id].mCardId_count[0],rounds[round_Id].mCardId_count[1],rounds[round_Id].mCardId_count[2]);
    }
    
function destoryGame()
    isCreator()
    public
    {
        selfdestruct(creator);
    }
    
function startGame()
    isCreator()
    isOver()
    public
    {   
        round_Id ++;
        
        rounds[round_Id] = JanKenPonData.Round({
            lastWiner:address(0),
            lastBuyerId: 0,
            pId_inc:0,
            rand_begin:rand_pId(7,15),
            success_pIds: new uint256[](0),
            failed_pIds: new uint256[](0),
            order_pIds: new uint256[](0),
            endTime: now.add(conmaxTime),
            is_activated:true,
			isWithDrawCom:false,
            totalCoin:0,
            totalCount:0,
            team:JanKenPonData.rateTeam({
                rateCom:10,
                rateNext:20,
                rateWin:5,
                rateLast:10,
                rateBen:25,
                rateShare:30,
                curPrice:uint256(2000000000000000)+uint256(10000000000000).mul(round_Id-1),
                incPrice:10000000000000
            })
        });
        emit onStartGame(rounds[round_Id].team.curPrice,round_Id,rounds[round_Id].endTime);
    }

function getRate()
    public
    constant
    returns(uint256,uint256,uint256,uint256,uint256,uint256)
    {
        return (rounds[round_Id].team.rateCom,rounds[round_Id].team.rateNext,rounds[round_Id].team.rateWin,rounds[round_Id].team.rateLast,rounds[round_Id].team.rateBen,rounds[round_Id].team.rateShare);
    }
    
function getCreator() 
    public
    constant
    returns(address)
    {
        return creator;
    }

function getSuccessAndFailedIds()
    public
    constant
    returns(uint256[],uint256[])
    {
        return(rounds[round_Id].success_pIds,rounds[round_Id].failed_pIds);
    }
    
function getPlayerIds(address player)
    public
    constant
    returns(uint256[])
    {
        return rounds[round_Id].mAddr_pid[player];
    }
    
function getSuccessDetail(uint256 id)
    public
    constant
    returns(address,uint8[3],uint8,bool,uint256,uint256)
    {
        JanKenPonData.playerPacket memory player = rounds[round_Id].mId_upk[id];
        
        return (player.owner,player.cards,player.stars,player.isSelling,player.price,player.count);
    }
    
function getFailedDetail(uint256 id)
    public
    constant
    returns(address,uint8[3],uint8,uint256)
    {
         JanKenPonData.playerPacket memory player = rounds[round_Id].mId_upk[id];
        
        return (player.owner,player.cards,player.stars,player.count);
    }

function getBalance()
    public
    constant
    returns(uint256)
{
    return address(this).balance;
}

function getRoundBalance(uint256 roundId)
    public
    constant
    returns(uint256)
    {
        return rounds[roundId].totalCoin;
    }

function getLastWiner(uint256 roundId)
    public 
    constant
    returns(address)
    {
        return rounds[roundId].lastWiner;
    }

function getGameStatus() 
    public
    constant
    returns(uint256,bool)
    {
        return (round_Id,rounds[round_Id].is_activated);
    }

function setLastWiner(address ply)
    private
    {
        rounds[round_Id].lastWiner = ply;
    }


function joinGame(uint8[3] cards, uint256 count) 
    isActivated()
    isHuman()
    isEnough(msg.value)
    payable
    public
    {    
        require(msg.value >= currentPrice().mul(count),"value not enough");

        for (uint256 j = 0; j < cards.length; j ++){
            require(cards[j] == 0 || cards[j] == 1 || cards[j] == 2,"card type not right");
            rounds[round_Id].mCardId_count[cards[j]]++;
        }
        
        updateEndTime(count);
        rounds[round_Id].mAddr_pid[msg.sender].push(rounds[round_Id].pId_inc);
        rounds[round_Id].mId_upk[rounds[round_Id].pId_inc] = JanKenPonData.playerPacket({
            pId:rounds[round_Id].pId_inc,
            owner:msg.sender,
            stars:3,
            cards:cards,
            cardIndex:0,
            isSelling:false,
            price:0,
            isWithDrawWiner:false,
            isWithDrawShare:false,
            isWithDrawLastBuyer:false,
            isWithdrawBenefit:false,
            count:count
        });
        rounds[round_Id].lastBuyerId = rounds[round_Id].pId_inc;
        indexPK(rounds[round_Id].pId_inc);
        rounds[round_Id].pId_inc ++;
        rounds[round_Id].totalCount += count;
        rounds[round_Id].totalCoin += msg.value;
        emit onJoinGame(msg.sender,cards.length,round_Id,currentPrice(),rounds[round_Id].endTime);
    }

function getLastKey(uint256 roundId)
    public
    constant
    returns(uint256)
    {
        return rounds[roundId].lastBuyerId;
    }
    
function currentPrice()
    public
    constant
    returns(uint256)
    {
        return rounds[round_Id].team.curPrice;
    }

function getOrders()
    public
    constant
    returns(uint256[])
    {
        return rounds[round_Id].order_pIds;
    }
    
function doOrder(uint256 pid,uint256 price)
    isActivated()
    public
    {
        require(rounds[round_Id].mId_upk[pid].owner == msg.sender && rounds[round_Id].mId_upk[pid].stars > 5 &&  rounds[round_Id].mId_upk[pid].cardIndex > 2 &&  rounds[round_Id].mId_upk[pid].isSelling == false,"condition not ok");
        
         rounds[round_Id].mId_upk[pid].isSelling = true;
         rounds[round_Id].mId_upk[pid].price = price;
         
         rounds[round_Id].order_pIds.push(pid);
         
         emit onSellOrder();
    }

function cancelOrder(uint256 pid)
    isActivated()
    public
    {
        require(rounds[round_Id].mId_upk[pid].isSelling == true && rounds[round_Id].mId_upk[pid].owner == msg.sender,"condition not ok");

        rounds[round_Id].mId_upk[pid].isSelling = false;
        rounds[round_Id].mId_upk[pid].price = 0;
        
        emit onCancelOrder();
    }

function buyOrder(uint256 buyerId,uint256 sellerId)
    isActivated()
    payable
    public  
{
    require(rounds[round_Id].mId_upk[sellerId].isSelling == true && msg.value >= rounds[round_Id].mId_upk[sellerId].price && rounds[round_Id].mId_upk[buyerId].owner == msg.sender,"condition not right");

    rounds[round_Id].mId_upk[sellerId].owner.transfer(msg.value.mul(9)/10);
    rounds[round_Id].mId_upk[sellerId].stars --;
    rounds[round_Id].mId_upk[buyerId].stars ++;
    
    if(rounds[round_Id].mId_upk[buyerId].stars > 4){
        rounds[round_Id].success_pIds.push(buyerId);
    }

    rounds[round_Id].mId_upk[sellerId].price = 0;
    rounds[round_Id].mId_upk[sellerId].isSelling = false;
    
    emit onBuyOrder();
}

function withdrawWiner(uint256 roundId,uint256 pId)
	isOver()
    payable
    public
{
    JanKenPonData.playerPacket memory player = rounds[roundId].mId_upk[pId];
    
    if (player.stars > 4 && player.cardIndex > 2 && player.isWithDrawWiner == false && player.owner == rounds[roundId].lastWiner) {
        uint256 winer = (rounds[roundId].totalCoin).mul(rounds[roundId].team.rateWin)/100;
        rounds[roundId].mId_upk[pId].owner.transfer(winer);
        rounds[roundId].mId_upk[pId].isWithDrawWiner = true;
    }
}

function getWithdrawShare(uint256 roundId)
    constant
    public
    returns(uint256)
    {
        uint256 share = 0;
        uint256 lastwin = 0;

        share = (rounds[roundId].totalCoin).mul(rounds[roundId].team.rateShare)/100/rounds[roundId].success_pIds.length;

        if(msg.sender == rounds[roundId].lastWiner){
                lastwin = (rounds[roundId].totalCoin).mul(rounds[roundId].team.rateWin)/100;
        }
        return share.add(lastwin);
    }
    
function withdrawShare(uint256 roundId,uint256 pId)
	isOver()
    payable
    public
{   
    uint256 share = 0;
    uint256 lastwin = 0;
    
    JanKenPonData.playerPacket memory player = rounds[roundId].mId_upk[pId];

    if (player.stars > 4 && player.cardIndex > 2 && player.isWithDrawShare == false && rounds[roundId].success_pIds.length > 0) {

            share = (rounds[roundId].totalCoin).mul(rounds[roundId].team.rateShare)/100/rounds[roundId].success_pIds.length;

            if(player.owner == rounds[roundId].lastWiner && player.isWithDrawWiner == false){
                lastwin = (rounds[roundId].totalCoin).mul(rounds[roundId].team.rateWin)/100;
                rounds[roundId].mId_upk[pId].isWithDrawWiner = true;
            }
            rounds[roundId].mId_upk[pId].owner.transfer(share.add(lastwin));
            rounds[roundId].mId_upk[pId].isWithDrawShare = true;
    }
}

function withdrawCom(uint256 roundId)
    isCreator()
	isOver()
    payable
    public
{
     if (rounds[roundId].isWithDrawCom == false){
        uint256 comm = (rounds[roundId].totalCoin).mul(rounds[roundId].team.rateCom)/100;
        creator.transfer(comm);
        rounds[roundId].isWithDrawCom = true;
    }
}

function withdrawBenefit(uint256 roundId,uint256 pId)
	isOver()
    payable
    public
    {
        uint256 benefit = 0;
        uint256 lastbuyer = 0;

        if (rounds[roundId].pId_inc > 1 && rounds[roundId].mId_upk[pId].owner == msg.sender && pId != rounds[roundId].lastBuyerId  && rounds[roundId].mId_upk[pId].isWithdrawBenefit == false){
           
            uint256 curPid = rounds[roundId].pId_inc.sub(1);
            
            uint256 totleIds = curPid.mul(curPid.add(1))/2;
            
            uint256 uAmount = rounds[roundId].mId_upk[pId].count;
            
            JanKenPonData.Round  memory r= rounds[roundId];
            
            uint256 benefitCoin = r.totalCoin.mul(r.team.rateBen)/100;
            
            benefit = (benefitCoin.mul(uAmount).mul(curPid.sub(pId))/r.totalCount/totleIds);
            
            if (pId == rounds[roundId].lastBuyerId && rounds[roundId].mId_upk[pId].isWithDrawLastBuyer == false) {
                 lastbuyer = (rounds[round_Id].totalCoin).mul(rounds[roundId].team.rateLast)/100;
                 rounds[roundId].mId_upk[pId].isWithDrawLastBuyer = true;
            }

            msg.sender.transfer(benefit.add(lastbuyer));
            
            rounds[roundId].mId_upk[pId].isWithdrawBenefit = true;
        }
        
        emit onWithdrawBenefit();
    }

function getBenefit(uint256 roundId,uint256 pId)
    public
    constant
    returns(uint256,uint256,bool,bool)
    {   
        uint256 benefit = 0;
        uint256 lastbuyer = 0;
    
        JanKenPonData.Round memory r = rounds[roundId];
        JanKenPonData.playerPacket memory p =  rounds[roundId].mId_upk[pId];
        
        if (r.pId_inc > 1){
            
            uint256 curPid = r.pId_inc.sub(1);
            
            uint256 totleIds = curPid.mul(curPid.add(1))/2;
            
            uint256 benefitCoin = r.totalCoin.mul(r.team.rateBen)/100;
            
            benefit = (benefitCoin.mul(p.count).mul(curPid.sub(pId))/r.totalCount/totleIds);

             if (pId == r.lastBuyerId &&  rounds[roundId].mId_upk[pId].isWithDrawLastBuyer == false) {
                 lastbuyer = (r.totalCoin).mul(r.team.rateLast)/100;
            }
            return ( p.count,benefit.add(lastbuyer), p.isWithdrawBenefit,r.is_activated);
        }else{
            return (0,0,false,false);
        }
    }
    
function setGameOver()
    private
{
    require(rounds[round_Id].is_activated, "the game has ended");

    rounds[round_Id].is_activated = false;
}

function()
    payable
    {
    }

function getTotalCount(uint256 roundId)
    constant
    public
    returns(uint256)
    {
        return rounds[roundId].totalCount;
    }

function getSuccessCount()
    constant
    public
    returns(uint256)
    {
        return rounds[round_Id].success_pIds.length;
    }

function getFailedCount()
    constant
    public
    returns(uint256)
    {
        return rounds[round_Id].failed_pIds.length;
    }
    
function indexPK(uint256 indexB) 
    private
{
        if (rounds[round_Id].pId_inc < rounds[round_Id].rand_begin){
            return;
        }
        uint8 cardA = rounds[round_Id].mId_upk[indexA].cards[rounds[round_Id].mId_upk[indexA].cardIndex];
        uint8 cardB = rounds[round_Id].mId_upk[indexB].cards[rounds[round_Id].mId_upk[indexB].cardIndex];
        
        uint8 result = cardPK(cardA,cardB);

        if (result == 0){
            rounds[round_Id].mId_upk[indexA].stars ++;
            rounds[round_Id].mId_upk[indexB].stars --;
        }else if (result == 2){
            rounds[round_Id].mId_upk[indexA].stars --;
            rounds[round_Id].mId_upk[indexB].stars ++;
        }

        rounds[round_Id].mId_upk[indexA].cardIndex ++;
        rounds[round_Id].mId_upk[indexB].cardIndex ++;

        if (rounds[round_Id].mId_upk[indexA].cardIndex > 2){
            if (rounds[round_Id].mId_upk[indexA].stars > 4) {
                rounds[round_Id].success_pIds.push(indexA);
                rounds[round_Id].lastWiner = rounds[round_Id].mId_upk[indexA].owner;
            }else{
                 rounds[round_Id].failed_pIds.push(indexA);
            }
            indexA++;
        }
        emit onPK(indexA,cardA,indexB,cardB);
}

function cardPK(uint8 cA,uint8 cB)
    isCardOK(cA)
    isCardOK(cB)
    private
    returns(uint8) 
{
    rounds[round_Id].mCardId_count[cA]--;
    rounds[round_Id].mCardId_count[cB]--;
    
    if(cA == 0){
            if(cB == 2){
                return 0;
            }else if (cB == 1){
                return 2;
            }
            return 1;
    }
    if (cA == 1){
            if(cB == 0){
                return 0;
            }else if (cB == 2){
                return 2;
            }
            return 1;
    }
    if (cA == 2){
            if(cB == 1){
                return 0;
            }else if (cB == 0){
                return 2;
            }
            return 1;
    }                 
}


function rand_pId(uint256 min,uint256 max)
        private 
        returns(uint256)
    {   
        if (max == 0){
            return 0;
        }
        rand_nonce++;
        uint256 seed = uint256(keccak256(abi.encodePacked(
             (block.timestamp).add
             (rand_nonce).add
             (now)
            )));
        return uint256(min + (seed%(max-min)));
    }

//====================================modifier=============================//

modifier isCreator() {
    require(msg.sender == creator, "only creator can do");
    _;
}

modifier isHuman() {
        address addr = msg.sender;
        uint256 codeLength;
        
        assembly {codeLength := extcodesize(addr)}
        require(codeLength == 0, "sorry humans only");
        _;
    }

modifier isOver() {
        require(rounds[round_Id].is_activated == false, "game is activated");
        _;
    }

modifier isActivated() {
        require(rounds[round_Id].is_activated == true, "game not begin"); 
        _;
    }

modifier isEnough(uint256 eth) {
    require(eth >= 1000000000, "not a valid currency");
    _;
}

modifier isCardsOK(uint8[3] cards){
    bool isOK = true;
    for(uint256 i=0;i< cards.length;i++){
        if (cards[i] != 0 && cards[i] != 1 && cards[i] != 2) {
            isOK = false;
        }
    }
    require(isOK, "card type not right");
    _;
}

modifier isCardOK(uint256 card) {
    bool isOK = false;
    if (card == 0 || card == 1 || card == 2) {
            isOK = true;
    }
     require(isOK, "card type not right");
    _;
}
 //==========================================================================//

}



library SafeMath {
    
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
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

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256) 
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c) 
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }
    
    /**
     * @dev gives square root of given x.
     */
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y) 
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y) 
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }
    
    /**
     * @dev gives square. multiplies x by x
     */
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }
    
    /**
     * @dev x to the power of y 
     */
    function pwr(uint256 x, uint256 y)
        internal 
        pure 
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else 
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }
}