/**+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                            abcLotto: a Block Chain Lottery

                            Don't trust anyone but the CODE!
 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
 /*
 * This product is protected under license.  Any unauthorized copy, modification, or use without 
 * express written consent from the creators is prohibited.
 */

/**+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                            - this is a 5/16 lotto, choose 5 numbers in 1-16.
                            - per ticket has two chance to win the jackpot, daily and weekly.
                            - daily jackpot need choose 5 right numbers.
                            - weekly jackpot need choose 5 rights numbers with right sequence.
                            - you must have an inviter then to buy.
                            - act as inviter will get bonus.
 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/
 pragma solidity ^0.4.20;
/**
* @title abc address resolver interface. 
 */ 
contract abcResolverI{
    function getWalletAddress() public view returns (address);
    function getBookAddress() public view returns (address);
    function getControllerAddress() public view returns (address);
}

/**
* @title inviter book interface. 
 */ 
contract inviterBookI{
    function isRoot(address addr) public view returns(bool);
    function hasInviter(address addr) public view returns(bool);
    function setInviter(address addr, string inviter) public;
    function pay(address addr) public payable;
}

/**
* @title abcLotto : data structure, buy and reward functions.
* @dev a decentralized lottery application. 
 */ 
 contract abcLotto{
     using SafeMath for *;
     
     //global varibles
     abcResolverI public resolver;
     address public controller;
     inviterBookI public book;
     address public wallet;

     uint32 public currentRound;   //current round, plus 1 every day;
     uint8 public currentState; //1 - bet period, 2 - freeze period, 3 - draw period.
     uint32[] public amounts;	//buy amount per round.
     uint32[] public addrs; //buy addresses per round.
     bool[] public drawed;    //lottery draw finished mark.
     
     uint public rollover = 0;
     uint[] public poolUsed;
     
     //constant
     uint constant ABC_GAS_CONSUME = 50; //this abc Dapp cost, default 50/1000.
     uint constant INVITER_FEE = 100; // inviter fee, default 100/1000;
     uint constant SINGLE_BET_PRICE = 50000000000000000;    // single bet price is 0.05 ether.
     uint constant THISDAPP_DIV = 1000;
     uint constant POOL_ALLOCATION_WEEK = 500;
     uint constant POOL_ALLOCATION_JACKPOT = 618;
     uint constant MAX_BET_AMOUNT = 100;   //per address can bet amount must be less than 100 per round.
     uint8 constant MAX_BET_NUM = 16;
     uint8 constant MIN_BET_NUM = 1;

     //data structures
     struct UnitBet{
         uint8[5] _nums;
		 bool _payed1;  //daily
         bool _payed2;  //weekly
     }
     struct AddrBets{
         UnitBet[] _unitBets;
     }    
     struct RoundBets{
         mapping (address=>AddrBets) _roundBets;
     }
     RoundBets[] allBets;
     
     struct BetKeyEntity{
         mapping (bytes5=>uint32) _entity;
     }     
     BetKeyEntity[] betDaily;
     BetKeyEntity[] betWeekly;

     struct Jackpot{
	     uint8[5] _results;
     }
     Jackpot[] dailyJackpot;
     Jackpot[] weeklyJackpot;
     
     //events
     event OnBuy(address user, uint32 round, uint32 index, uint8[5] nums);
     event OnRewardDaily(address user, uint32 round, uint32 index, uint reward);
     event OnRewardWeekly(address user, uint32 round, uint32 index,uint reward);
     event OnRewardDailyFailed(address user, uint32 round, uint32 index);
     event OnRewardWeeklyFailed(address user, uint32 round, uint32 index);
     event OnNewRound(uint32 round);
     event OnFreeze(uint32 round);
     event OnUnFreeze(uint32 round);
     event OnDrawStart(uint32 round);
     event OnDrawFinished(uint32 round, uint8[5] jackpot);
     event BalanceNotEnough();
     
      //modifier
     modifier onlyController {
         require(msg.sender == controller);
         _;
     }     
     
     modifier onlyBetPeriod {
         require(currentState == 1);
         _;
     }
     
     modifier onlyHuman {
         require(msg.sender == tx.origin);
         _;
     }
     
     //check contract interface, are they upgrated?
     modifier abcInterface {
        if((address(resolver)==0)||(getCodeSize(address(resolver))==0)){
            if(abc_initNetwork()){
                wallet = resolver.getWalletAddress();
                book = inviterBookI(resolver.getBookAddress());
                controller = resolver.getControllerAddress();
            }
        }
        else{
            if(wallet != resolver.getWalletAddress())
                wallet = resolver.getWalletAddress();

            if(address(book) != resolver.getBookAddress())
                book = inviterBookI(resolver.getBookAddress());
                
            if(controller != resolver.getControllerAddress())
                controller = resolver.getControllerAddress();
        }    

        _;        
     }

     /**
     * @dev fallback funtion, this contract don't accept ether directly.
     */
     function() public payable { 
         revert();
     }

     /**
     * @dev init address resolver.
     */ 
     function abc_initNetwork() internal returns(bool) { 
         //mainnet
         if (getCodeSize(0xde4413799c73a356d83ace2dc9055957c0a5c335)>0){     
            resolver = abcResolverI(0xde4413799c73a356d83ace2dc9055957c0a5c335);
            return true;
         }               
   
         //others ...

         return false;
     }     
    /**
    * @dev get code size of appointed address.
     */
     function getCodeSize(address _addr) internal view returns(uint _size) {
         assembly {
             _size := extcodesize(_addr)
         }
     }
    //+++++++++++++++++++++++++                  public operation functions               +++++++++++++++++++++++++++++++++++++
    /**
    * @dev buy: buy a new ticket.
     */
    function buy(uint8[5] nums, string inviter) 
        public
        payable
        onlyBetPeriod
        onlyHuman
        abcInterface
        returns (uint)
     {
         //check number range 1-16, no repeat number.
         if(!isValidNum(nums)) revert();
         //doesn't offer enough value.
         if(msg.value < SINGLE_BET_PRICE) revert();
         
         //check daily amount is less than MAX_BET_AMOUNT
         uint _am = allBets[currentRound-1]._roundBets[msg.sender]._unitBets.length.add(1);      
         if( _am > MAX_BET_AMOUNT) revert();
         
         //update storage varibles.
         amounts[currentRound-1]++;
         if(allBets[currentRound-1]._roundBets[msg.sender]._unitBets.length <= 0)
            addrs[currentRound-1]++;
            
         //insert bet record.
         UnitBet memory _bet;
         _bet._nums = nums;
         _bet._payed1 = false;
         _bet._payed2 = false;
         allBets[currentRound-1]._roundBets[msg.sender]._unitBets.push(_bet);
         
         //increase key-value records.
         bytes5 _key;
         _key = generateCombinationKey(nums);
         betDaily[currentRound-1]._entity[_key]++;
         _key = generatePermutationKey(nums);
         uint32 week = (currentRound-1) / 7;
         betWeekly[week]._entity[_key]++;
         
         //refund extra value.
         if(msg.value > SINGLE_BET_PRICE){
             msg.sender.transfer(msg.value.sub(SINGLE_BET_PRICE));
         }

         //has inviter?
         if(book.hasInviter(msg.sender) || book.isRoot(msg.sender)){
            book.pay.value(SINGLE_BET_PRICE.mul(INVITER_FEE).div(THISDAPP_DIV))(msg.sender);
         }
         else{
            book.setInviter(msg.sender, inviter);
            book.pay.value(SINGLE_BET_PRICE.mul(INVITER_FEE).div(THISDAPP_DIV))(msg.sender);
         }
         
        //emit event
        emit OnBuy(msg.sender, currentRound, uint32(allBets[currentRound-1]._roundBets[msg.sender]._unitBets.length), nums);
        return allBets[currentRound-1]._roundBets[msg.sender]._unitBets.length;
         
     }
     /**
     * @dev rewardDaily: apply for daily reward.
     */     
     function rewardDaily(uint32 round, uint32 index)
        public 
        onlyBetPeriod 
        onlyHuman  
        returns(uint) 
     {
         require(round>0 && round<=currentRound);
         require(drawed[round-1]);
         require(index>0 && index<=allBets[round-1]._roundBets[msg.sender]._unitBets.length);
         require(!allBets[round-1]._roundBets[msg.sender]._unitBets[index-1]._payed1);

         uint8[5] memory nums = allBets[round-1]._roundBets[msg.sender]._unitBets[index-1]._nums;
         
         bytes5 key = generateCombinationKey(nums);
         bytes5 jackpot = generateCombinationKey(dailyJackpot[round-1]._results);
         if(key != jackpot) return;
         
         uint win_amount = betDaily[round-1]._entity[key];
         if(win_amount <= 0) return;

         uint amount = amounts[round-1];
         uint total = SINGLE_BET_PRICE.mul(amount).mul(THISDAPP_DIV-INVITER_FEE).div(THISDAPP_DIV).mul(THISDAPP_DIV - POOL_ALLOCATION_WEEK).div(THISDAPP_DIV);
         uint pay = total.mul(THISDAPP_DIV - ABC_GAS_CONSUME).div(THISDAPP_DIV).div(win_amount);

         //pay action
         if(pay > address(this).balance){
            emit BalanceNotEnough();
            revert();             
         }
         allBets[round-1]._roundBets[msg.sender]._unitBets[index-1]._payed1 = true;
         if(!msg.sender.send(pay)){
            emit OnRewardDailyFailed(msg.sender, round, index);
            revert();
         }
         
         emit OnRewardDaily(msg.sender, round, index, pay);
         return pay;
     }      
     
     /**
     * @dev rewardWeekly: apply for weekly reward.
      */
     function rewardWeekly(uint32 round, uint32 index) 
        public 
        onlyBetPeriod 
        onlyHuman
        returns(uint) 
     {
         require(round>0 && round<=currentRound);
         require(drawed[round-1]);
         require(index>0 && index<=allBets[round-1]._roundBets[msg.sender]._unitBets.length);
         require(!allBets[round-1]._roundBets[msg.sender]._unitBets[index-1]._payed2);

         uint32 week = (round-1)/7 + 1;
         uint8[5] memory nums = allBets[round-1]._roundBets[msg.sender]._unitBets[index-1]._nums;
         
         bytes5 key = generatePermutationKey(nums);
         bytes5 jackpot = generatePermutationKey(weeklyJackpot[week-1]._results);
         if(key != jackpot) return;
         
         uint32 win_amount = betWeekly[week-1]._entity[key];
         if(win_amount <= 0) return;     

         uint pay = poolUsed[week-1].div(win_amount);
         
         //pay action
         if(pay > address(this).balance){
            emit BalanceNotEnough();
            return;             
         }
         allBets[round-1]._roundBets[msg.sender]._unitBets[index-1]._payed2 = true;
         if(!msg.sender.send(pay)){
            emit OnRewardWeeklyFailed(msg.sender, round, index);
            revert();
         }
         
        emit OnRewardWeekly(msg.sender, round, index, pay);
        return pay;
     }
     //+++++++++++++++++++++++++                  pure or view functions               +++++++++++++++++++++++++++++++++++++
     /**
     * @dev getSingleBet: get self's bet record.
      */
    function getSingleBet(uint32 round, uint32 index) 
        public 
        view 
        returns(uint8[5] nums, bool payed1, bool payed2)
     {
         if(round == 0 || round > currentRound) return;

         uint32 iLen = uint32(allBets[round-1]._roundBets[msg.sender]._unitBets.length);
         if(iLen <= 0) return;
         if(index == 0 || index > iLen) return;
         
         nums = allBets[round-1]._roundBets[msg.sender]._unitBets[index-1]._nums;
         payed1 = allBets[round-1]._roundBets[msg.sender]._unitBets[index-1]._payed1;
         payed2 = allBets[round-1]._roundBets[msg.sender]._unitBets[index-1]._payed2;
     }
     /**
     * @dev getAmountDailybyNum: get the daily bet amount of a set of numbers.
      */
     function getAmountDailybyNum(uint32 round, uint8[5] nums) 
        public 
        view 
        returns(uint32)
    {
         if(round == 0 || round > currentRound) return 0;       
         bytes5 _key = generateCombinationKey(nums);
         
         return betDaily[round-1]._entity[_key];
     }

     /**
     * @dev getAmountWeeklybyNum: get the weekly bet amount of a set of numbers.
      */     
     function getAmountWeeklybyNum(uint32 week, uint8[5] nums) 
        public 
        view 
        returns(uint32)
    {
         if(week == 0 || currentRound < (week-1)*7) return 0;
         
         bytes5 _key = generatePermutationKey(nums);
         return betWeekly[week-1]._entity[_key];
     }
     
     /**
     * @dev getDailyJackpot: some day's Jackpot.
      */
     function getDailyJackpot(uint32 round) 
        public 
        view 
        returns(uint8[5] jackpot, uint32 amount)
    {
         if(round == 0 || round > currentRound) return;
         jackpot = dailyJackpot[round-1]._results;
         amount = getAmountDailybyNum(round, jackpot);
     }

     /**
     * @dev getWeeklyJackpot: some week's Jackpot.
      */
     function getWeeklyJackpot(uint32 week) 
        public 
        view 
        returns(uint8[5] jackpot, uint32 amount)
    {
         if(week == 0 || week > currentRound/7) return;
         jackpot = weeklyJackpot[week - 1]._results;
         amount = getAmountWeeklybyNum(week, jackpot);
     }

     //+++++++++++++++++++++++++                  controller functions               +++++++++++++++++++++++++++++++++++++
     /**
      * @dev start new round.
     */ 
    function nextRound() 
        abcInterface
        public 
        onlyController
    {
         //current round must be drawed.
         if(currentRound > 0)
            require(drawed[currentRound-1]);
         
         currentRound++;
         currentState = 1;
         
         amounts.length++;
         addrs.length++;
         drawed.length++;
         
         RoundBets memory _rb;
         allBets.push(_rb);
         
         BetKeyEntity memory _en1;
         betDaily.push(_en1);
         
         Jackpot memory _b1;
         dailyJackpot.push(_b1);
         //if is a weekend or beginning.
         if((currentRound-1) % 7 == 0){
             BetKeyEntity memory _en2;
             betWeekly.push(_en2);
             Jackpot memory _b2;
             weeklyJackpot.push(_b2);
             poolUsed.length++;
         }
         emit OnNewRound(currentRound);
     }

    /**
    * @dev freeze: enter freeze period.
     */
    function freeze() 
        abcInterface
        public
        onlyController 
    {
        currentState = 2;
        emit OnFreeze(currentRound);
    }

    /**
    * @dev freeze: enter freeze period.
     */
    function unfreeze()
        abcInterface
        public 
        onlyController 
    {
        require(currentState == 2);
        currentState = 1;
        emit OnUnFreeze(currentRound);
    }
    
    /**
    * @dev draw: enter freeze period.
     */
    function draw() 
        abcInterface 
        public 
        onlyController
    {
        require(!drawed[currentRound-1]);
        currentState = 3;
        emit OnDrawStart(currentRound);
    }

    /**
    * @dev controller have generated and set Jackpot.
     */
    function setJackpot(uint8[5] jackpot) 
        abcInterface
        public
        onlyController
    {
        require(currentState==3 && !drawed[currentRound-1]);
        //check jackpot range 1-16, no repeat number.
        if(!isValidNum(jackpot)) return;
  
        uint _fee = 0;

        //mark daily entity's prize.-----------------------------------------------------------------------------------
        uint8[5] memory _jackpot1 = sort(jackpot);
        dailyJackpot[currentRound-1]._results = _jackpot1;
        bytes5 _key = generateCombinationKey(_jackpot1);
        uint total = SINGLE_BET_PRICE.mul(amounts[currentRound-1]).mul(THISDAPP_DIV-INVITER_FEE).div(THISDAPP_DIV).mul(THISDAPP_DIV - POOL_ALLOCATION_WEEK).div(THISDAPP_DIV);
        uint win_amount = uint(betDaily[currentRound-1]._entity[_key]);
        uint _bonus_sum;

        if( win_amount <= 0){
            rollover = rollover.add(total);
        }
        else{
            _bonus_sum = total.mul(THISDAPP_DIV - ABC_GAS_CONSUME).div(THISDAPP_DIV).div(win_amount).mul(win_amount);
            _fee = _fee.add(total.sub(_bonus_sum));
        }
         //end mark.-----------------------------------------------------------------------------------

        //mark weekly entity's prize.---------------------------------------------------------------------------------------
        if((currentRound > 0) && (currentRound % 7 == 0)){
            uint32 _week = currentRound/7;
            weeklyJackpot[_week-1]._results = jackpot;
           _key = generatePermutationKey(jackpot);
            uint32 _amounts = getAmountWeekly(_week);
            total = SINGLE_BET_PRICE.mul(_amounts).mul(THISDAPP_DIV-INVITER_FEE).div(THISDAPP_DIV).mul(POOL_ALLOCATION_WEEK).div(THISDAPP_DIV);
            win_amount = uint(betWeekly[_week-1]._entity[_key]);

            if(win_amount > 0){
                total = total.add(rollover);
                _bonus_sum = total.mul(POOL_ALLOCATION_JACKPOT).div(THISDAPP_DIV);
                rollover = total.sub(_bonus_sum);

                poolUsed[_week-1] = _bonus_sum.mul(THISDAPP_DIV - ABC_GAS_CONSUME).div(THISDAPP_DIV).div(win_amount).mul(win_amount);
                _fee = _fee.add(_bonus_sum.sub(poolUsed[_week-1]));
            }
            else{
                rollover = rollover.add(total);
            }
        }
        //end mark.-----------------------------------------------------------------------------------
        drawed[currentRound-1] = true;
        wallet.transfer(_fee);
        emit OnDrawFinished(currentRound, jackpot);
    }

     //+++++++++++++++++++++++++                  internal functions               +++++++++++++++++++++++++++++++++++++
     /**
     * @dev getAmountWeekly: the bet amount of a week.
      */
     function getAmountWeekly(uint32 week) internal view returns(uint32){
         if(week == 0 || currentRound < (week-1)*7) return 0;

         uint32 _ret;
         uint8 i;
         if(currentRound > week*7){
             for(i=0; i<7; i++){
                 _ret += amounts[(week-1)*7+i];
             }
         }
         else{
             uint8 j = uint8((currentRound-1) % 7);
             for(i=0;i<=j;i++){
                 _ret += amounts[(week-1)*7+i];
             }
         }
         return _ret;
     }
     /**
     * @dev check if is a valid set of number.
     * @param nums : chosen number.
     */
     function isValidNum(uint8[5] nums) internal pure returns(bool){
         for(uint i = 0; i<5; i++){
             if(nums[i] < MIN_BET_NUM || nums[i] > MAX_BET_NUM) 
                return false;
         }
         if(hasRepeat(nums)) return false;
         
         return true;
    }
    
     /**
     * @dev sort 5 numbers.
     *      don't want to change input numbers sequence, so copy it at first.
     * @param nums : input numbers.
     */
    function sort(uint8[5] nums) internal pure returns(uint8[5]){
        uint8[5] memory _nums;
        uint8 i;
        for(i=0;i<5;i++)
            _nums[i] = nums[i];
            
        uint8 j;
        uint8 temp;
        for(i =0; i<5-1; i++){
            for(j=0; j<5-i-1;j++){
                if(_nums[j]>_nums[j+1]){
                    temp = _nums[j];
                    _nums[j] = _nums[j+1];
                    _nums[j+1] = temp;
                }
            }
        }
        return _nums;
    }
    
    /**
     * @dev does has repeat number?
     * @param nums : input numbers.
     */
    function hasRepeat(uint8[5] nums) internal pure returns(bool){
         uint8 i;
         uint8 j;
         for(i =0; i<5-1; i++){
             for(j=i; j<5-1;j++){
                 if(nums[i]==nums[j+1]) return true;
             }
         }
        return false;       
    }
    
    /**
     * @dev generate Combination key, need sort at first.
     */ 
    function generateCombinationKey(uint8[5] nums) internal pure returns(bytes5){
        uint8[5] memory temp = sort(nums);
        bytes5 ret;
        ret = (ret | byte(temp[4])) >> 8;
        ret = (ret | byte(temp[3])) >> 8;
        ret = (ret | byte(temp[2])) >> 8;
        ret = (ret | byte(temp[1])) >> 8;
        ret = ret | byte(temp[0]);
        
        return ret; 
    }
    
    /**
     * @dev generate Permutation key.
     */ 
    function generatePermutationKey(uint8[5] nums) internal pure returns(bytes5){
        bytes5 ret;
        ret = (ret | byte(nums[4])) >> 8;
        ret = (ret | byte(nums[3])) >> 8;
        ret = (ret | byte(nums[2])) >> 8;
        ret = (ret | byte(nums[1])) >> 8;
        ret = ret | byte(nums[0]);
        
        return ret;         
    }
}

/**
 * @title SafeMath : it's from openzeppelin.
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Subtracts two 32 bit numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub_32(uint32 a, uint32 b) internal pure returns (uint32) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }

  /**
  * @dev Adds two 32 bit numbers, throws on overflow.
  */
  function add_32(uint32 a, uint32 b) internal pure returns (uint32 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}