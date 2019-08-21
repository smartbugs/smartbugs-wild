pragma solidity ^0.4.25;



/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
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
contract DateTimeEnabled {
        /*
         *  Date and Time utilities for ethereum contracts
         *
         */
        struct DateTime {
                uint16 year;
                uint8 month;
                uint8 day;
                uint8 hour;
                uint8 minute;
                uint8 second;
                uint8 weekday;
        }

        uint constant DAY_IN_SECONDS = 86400;
        uint constant YEAR_IN_SECONDS = 31536000;
        uint constant LEAP_YEAR_IN_SECONDS = 31622400;

        uint constant HOUR_IN_SECONDS = 3600;
        uint constant MINUTE_IN_SECONDS = 60;

        uint16 constant ORIGIN_YEAR = 1970;

        function isLeapYear(uint16 year) internal constant returns (bool) {
                if (year % 4 != 0) {
                        return false;
                }
                if (year % 100 != 0) {
                        return true;
                }
                if (year % 400 != 0) {
                        return false;
                }
                return true;
        }

        function leapYearsBefore(uint year) internal constant returns (uint) {
                year -= 1;
                return year / 4 - year / 100 + year / 400;
        }

        function getDaysInMonth(uint8 month, uint16 year) internal constant returns (uint8) {
                if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
                        return 31;
                }
                else if (month == 4 || month == 6 || month == 9 || month == 11) {
                        return 30;
                }
                else if (isLeapYear(year)) {
                        return 29;
                }
                else {
                        return 28;
                }
        }

        function parseTimestamp(uint timestamp) internal returns (DateTime dt) {
                uint secondsAccountedFor = 0;
                uint buf;
                uint8 i;

                // Year
                dt.year = getYear(timestamp);
                buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
                secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

                // Month
                uint secondsInMonth;
                for (i = 1; i <= 12; i++) {
                        secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
                        if (secondsInMonth + secondsAccountedFor > timestamp) {
                                dt.month = i;
                                break;
                        }
                        secondsAccountedFor += secondsInMonth;
                }

                // Day
                for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
                        if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                                dt.day = i;
                                break;
                        }
                        secondsAccountedFor += DAY_IN_SECONDS;
                }

                // Hour
                dt.hour = getHour(timestamp);

                // Minute
                dt.minute = getMinute(timestamp);

                // Second
                dt.second = getSecond(timestamp);

                // Day of week.
                dt.weekday = getWeekday(timestamp);
        }

        function getYear(uint timestamp) internal constant returns (uint16) {
                uint secondsAccountedFor = 0;
                uint16 year;
                uint numLeapYears;

                // Year
                year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
                numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
                secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

                while (secondsAccountedFor > timestamp) {
                        if (isLeapYear(uint16(year - 1))) {
                                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
                        }
                        else {
                                secondsAccountedFor -= YEAR_IN_SECONDS;
                        }
                        year -= 1;
                }
                return year;
        }

        function getMonth(uint timestamp) internal constant returns (uint8) {
                return parseTimestamp(timestamp).month;
        }

        function getDay(uint timestamp) internal constant returns (uint8) {
                return parseTimestamp(timestamp).day;
        }

        function getHour(uint timestamp) internal constant returns (uint8) {
                return uint8((timestamp / 60 / 60) % 24);
        }

        function getMinute(uint timestamp) internal constant returns (uint8) {
                return uint8((timestamp / 60) % 60);
        }

        function getSecond(uint timestamp) internal constant returns (uint8) {
                return uint8(timestamp % 60);
        }

        function getWeekday(uint timestamp) internal constant returns (uint8) {
                return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day) internal constant returns (uint timestamp) {
                return toTimestamp(year, month, day, 0, 0, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) internal constant returns (uint timestamp) {
                return toTimestamp(year, month, day, hour, 0, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) internal constant returns (uint timestamp) {
                return toTimestamp(year, month, day, hour, minute, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) internal constant returns (uint timestamp) {
                uint16 i;

                // Year
                for (i = ORIGIN_YEAR; i < year; i++) {
                        if (isLeapYear(i)) {
                                timestamp += LEAP_YEAR_IN_SECONDS;
                        }
                        else {
                                timestamp += YEAR_IN_SECONDS;
                        }
                }

                // Month
                uint8[12] memory monthDayCounts;
                monthDayCounts[0] = 31;
                if (isLeapYear(year)) {
                        monthDayCounts[1] = 29;
                }
                else {
                        monthDayCounts[1] = 28;
                }
                monthDayCounts[2] = 31;
                monthDayCounts[3] = 30;
                monthDayCounts[4] = 31;
                monthDayCounts[5] = 30;
                monthDayCounts[6] = 31;
                monthDayCounts[7] = 31;
                monthDayCounts[8] = 30;
                monthDayCounts[9] = 31;
                monthDayCounts[10] = 30;
                monthDayCounts[11] = 31;

                for (i = 1; i < month; i++) {
                        timestamp += DAY_IN_SECONDS * monthDayCounts[i - 1];
                }

                // Day
                timestamp += DAY_IN_SECONDS * (day - 1);

                // Hour
                timestamp += HOUR_IN_SECONDS * (hour);

                // Minute
                timestamp += MINUTE_IN_SECONDS * (minute);

                // Second
                timestamp += second;

                return timestamp;
        }
        
        function addDaystoTimeStamp(uint16 _daysToBeAdded) internal  returns(uint){
            return now + DAY_IN_SECONDS*_daysToBeAdded;
        }

        function addMinutestoTimeStamp(uint8 _minutesToBeAdded) internal  returns(uint){
            return now + MINUTE_IN_SECONDS*_minutesToBeAdded;
        }


        function printDatestamp(uint timestamp) internal returns (uint16,uint8,uint8,uint8,uint8,uint8) {
            DateTime memory dt;
            dt = parseTimestamp(timestamp);
            return (dt.year,dt.month,dt.day,dt.hour,dt.minute,dt.second);
        }
        
        function currentTimeStamp() internal returns (uint) {
            return now;
        }
}


contract ERC20 {
    function totalSupply() view public returns (uint _totalSupply);
    function balanceOf(address _owner) view public returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) view public returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}


contract BaseToken is ERC20 {
    
    address public owner;
    using SafeMath for uint256;
    
    bool public tokenStatus = false;
    
    modifier ownerOnly(){
        require(msg.sender == owner);
        _;
    }

    
    modifier onlyWhenTokenIsOn(){
        require(tokenStatus == true);
        _;
    }


    function onOff () ownerOnly external{
        tokenStatus = !tokenStatus;    
    }


    /**
       * @dev Fix for the ERC20 short address attack.
    */
    modifier onlyPayloadSize(uint size) {
        require(msg.data.length >= size + 4);
        _;
    }    
    mapping (address => uint256) public balances;
    mapping(address => mapping(address => uint256)) allowed;

    //Token Details
    string public symbol = "BASE";
    string public name = "Base Token";
    uint8 public decimals = 18;

    uint256 public totalSupply; //will be instantiated in the derived Contracts
    
    function totalSupply() view public returns (uint256 ){
        return totalSupply;
    }


    function balanceOf(address _owner) view public returns (uint balance){
        return balances[_owner];
    }
    
    function transfer(address _to, uint _value) onlyWhenTokenIsOn onlyPayloadSize(2 * 32) public returns (bool success){
        //_value = _value.mul(1e18);
        require(
            balances[msg.sender]>=_value 
            && _value > 0);
            balances[msg.sender] = balances[msg.sender].sub(_value);
            balances[_to] = balances[_to].add(_value);
            emit Transfer(msg.sender,_to,_value);
            return true;
    }
    
    function transferFrom(address _from, address _to, uint _value) onlyWhenTokenIsOn onlyPayloadSize(3 * 32) public returns (bool success){
        //_value = _value.mul(10**decimals);
        require(
            allowed[_from][msg.sender]>= _value
            && balances[_from] >= _value
            && _value >0 
            );
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
            
    }
    
    function approve(address _spender, uint _value) onlyWhenTokenIsOn public returns (bool success){
        //_value = _value.mul(10**decimals);
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) view public returns (uint remaining){
        return allowed[_owner][_spender];
    }

    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    

}




contract ICO is BaseToken,DateTimeEnabled{

    uint256 base = 10;
    uint256 multiplier;

    address ownerMultisig;

    struct ICOPhase {
        string phaseName;
        uint256 tokensStaged;
        uint256 tokensAllocated;
        uint256 iRate;
        uint256 fRate;
        uint256 intialTime;
        uint256 closingTime;
       // uint256 RATE;
        bool saleOn;
        uint deadline;
    }

    uint8 public currentICOPhase;
    
    mapping(address=>uint256) public ethContributedBy;
    uint256 public totalEthRaised;
    uint256 public totalTokensSoldTillNow;

    mapping(uint8=>ICOPhase) public icoPhases;
    uint8 icoPhasesIndex=1;
    
    function getEthContributedBy(address _address) view public returns(uint256){
        return ethContributedBy[_address];
    }

    function getTotalEthRaised() view public returns(uint256){
        return totalEthRaised;
    }

    function getTotalTokensSoldTillNow() view public returns(uint256){
        return totalTokensSoldTillNow;
    }

    
    function addICOPhase(string _phaseName,uint256 _tokensStaged,uint256 _iRate, uint256 _fRate,uint256 _intialTime,uint256 _closingTime) ownerOnly public{
        icoPhases[icoPhasesIndex].phaseName = _phaseName;
        icoPhases[icoPhasesIndex].tokensStaged = _tokensStaged;
        icoPhases[icoPhasesIndex].iRate = _iRate;
        icoPhases[icoPhasesIndex].fRate = _fRate;
        icoPhases[icoPhasesIndex].intialTime = _intialTime;
        icoPhases[icoPhasesIndex].closingTime = _closingTime;
        icoPhases[icoPhasesIndex].tokensAllocated = 0;
        icoPhases[icoPhasesIndex].saleOn = false;
        //icoPhases[icoPhasesIndex].deadline = _deadline;
        icoPhasesIndex++;
    }

    function toggleSaleStatus() ownerOnly external{
        icoPhases[currentICOPhase].saleOn = !icoPhases[currentICOPhase].saleOn;
    }
    function changefRate(uint256 _fRate) ownerOnly external{
        icoPhases[currentICOPhase].fRate = _fRate;
    }
    function changeCurrentICOPhase(uint8 _newPhase) ownerOnly external{ //Only provided for exception handling in case some faulty phase has been added by the owner using addICOPhase
        currentICOPhase = _newPhase;
    }

    function changeCurrentPhaseDeadline(uint8 _numdays) ownerOnly external{
        icoPhases[currentICOPhase].closingTime= addDaystoTimeStamp(_numdays); //adds number of days to now and that becomes the new deadline
    }
    
    function transferOwnership(address newOwner) ownerOnly external{
        if (newOwner != address(0)) {
          owner = newOwner;
        }
    }
    
}
contract MultiRound is ICO{
    function newICORound(uint256 _newSupply) ownerOnly public{//This is different from Stages which means multiple parts of one round
        _newSupply = _newSupply.mul(multiplier);
        balances[owner] = balances[owner].add(_newSupply);
        totalSupply = totalSupply.add(_newSupply);
    }

    function destroyUnsoldTokens(uint256 _tokens) ownerOnly public{
        _tokens = _tokens.mul(multiplier);
        totalSupply = totalSupply.sub(_tokens);
        balances[owner] = balances[owner].sub(_tokens);
    }

    
}

contract ReferralEnabledToken is BaseToken{

    
    struct referral {
        address referrer;
        uint8 referrerPerc;// this is the percentage referrer will get in ETH. 
        uint8 refereePerc; // this is the discount Refereee will get 
    }

    struct redeemedReferral {
        address referee;
        uint timestamp;
        uint ethContributed;
        uint rewardGained;
    }
    mapping(address=>referral) public referrals;
    
    uint8 public currentReferralRewardPercentage=10;
    uint8 public currentReferralDiscountPercentage=10;
    
    mapping(address=>uint256) public totalEthRewards;
    mapping(address=>mapping(uint16=>redeemedReferral)) referrerRewards;
    mapping(address=>uint16) referrerRewardIndex;
    
    function totalEthRewards(address _address) view public returns(uint256){
        totalEthRewards[_address];
    }
    
    function createReferral(address _referrer, address _referree) public returns (bool) {
        require(_referrer != _referree);
        require (referrals[_referree].referrer == address(0) || referrals[_referree].referrer==msg.sender);
        referrals[_referree].referrer = _referrer;
        referrals[_referree].referrerPerc = currentReferralRewardPercentage;
        referrals[_referree].refereePerc = currentReferralDiscountPercentage;
        return true;
    }
    
    function getReferrerRewards(address _referrer, uint16 _index) view public returns(address,uint,uint,uint){
        redeemedReferral r = referrerRewards[_referrer][_index];
        return(r.referee,r.timestamp,r.ethContributed,r.rewardGained);
    }
    
    function getReferrerIndex(address _referrer) view public returns(uint16) {
        return(referrerRewardIndex[_referrer]);
    }
    
    
    function getReferrerTotalRewards(address _referrer) view public returns(uint){
        return (totalEthRewards[_referrer]);
    }
    
    function getReferral(address _refereeId) constant public returns(address,uint8,uint8) {
        referral memory r = referrals[_refereeId];
        return(r.referrer,r.referrerPerc,r.refereePerc);
    } 

    function changeReferralPerc(uint8 _newPerc) ownerOnly external{
        currentReferralRewardPercentage = _newPerc;
    }

    function changeRefereePerc(uint8 _newPerc) ownerOnly external{
        currentReferralDiscountPercentage = _newPerc;
    }
}
contract killable is ICO {
    
    function killContract() ownerOnly external{
        selfdestruct(ownerMultisig);
    }
}
//TODO - ADD Total ETH raised and Record token wise contribution    
contract RefineMediumToken is ICO,killable,MultiRound,ReferralEnabledToken  {
 //   uint256 intialTime = 1542043381;
 //   uint256 closingTime = 1557681781;
    uint256 constant alloc1perc=50; //TEAM ALLOCATION
    address constant alloc1Acc = 0xF0B50870e5d01FbfE783F6e76994A0BA94d34fe9; //CORETEAM Address (test-TestRPC4)

    uint256 constant alloc2perc=50;//in percent -- ADVISORS ALLOCATION
    address constant alloc2Acc = 0x3c3daEd0733cDBB26c298443Cec93c48426CC4Bd; //TestRPC5

    uint256 constant alloc3perc=50;//in percent -- Bounty Allocation
    address constant alloc3Acc = 0xAc5c102B4063615053C29f9B4DC8001D529037Cd; //TestRPC6

    uint256 constant alloc4perc=50;//in percent -- Reserved LEAVE IT TO ZERO IF NO MORE ALLOCATIONS ARE THERE
    address constant alloc4Acc = 0xf080966E970AC351A9D576846915bBE049Fe98dB; //TestRPC7

    address constant ownerMultisig = 0xc4010efafaf53be13498efcffa04df931dc1592a; //Test4
    mapping(address=>uint) blockedTill;    

    constructor() public{
        symbol = "XRM";
        name = "Refine Medium Token";
        decimals = 18;
        multiplier=base**decimals;

        totalSupply = 300000000*multiplier;//300 mn-- extra 18 zeroes are for the wallets which use decimal variable to show the balance 
        owner = msg.sender;

        balances[owner]=totalSupply;
        currentICOPhase = 1;
        addICOPhase("Private Sale",15000000*multiplier,1550,1550,1558742400,1560556800);
        runAllocations();
    }

    function runAllocations() ownerOnly public{
        balances[owner]=((1000-(alloc1perc+alloc2perc+alloc3perc+alloc4perc))*totalSupply)/1000;
        
        balances[alloc1Acc]=(alloc1perc*totalSupply)/1000;
        blockedTill[alloc1Acc] = addDaystoTimeStamp(2);
        
        balances[alloc2Acc]=(alloc2perc*totalSupply)/1000;
        blockedTill[alloc2Acc] = addDaystoTimeStamp(2);
        
        balances[alloc3Acc]=(alloc3perc*totalSupply)/1000;
        blockedTill[alloc3Acc] = addDaystoTimeStamp(2);
        
        balances[alloc4Acc]=(alloc4perc*totalSupply)/1000;
        blockedTill[alloc4Acc] = addDaystoTimeStamp(2);
        
    }

    function showRate(uint256 _epoch) public view returns (uint256){
         ICOPhase storage i = icoPhases[currentICOPhase];
         uint256 epoch = _epoch.sub(i.intialTime);
         uint256 timeRange = i.closingTime.sub(i.intialTime);
         uint256 rateRange = i.iRate.sub(i.fRate);
         return (i.iRate*100000000000).sub((epoch.mul(rateRange)*100000000000).div(timeRange));
    }
    function currentRate() public view returns (uint256){
         ICOPhase storage i = icoPhases[currentICOPhase];
         uint256 epoch = now.sub(i.intialTime);
         uint256 timeRange = i.closingTime.sub(i.intialTime);
         uint256 rateRange = i.iRate.sub(i.fRate);
         return ((i.iRate*100000000000).sub((epoch.mul(rateRange)*100000000000).div(timeRange)))/100000000000;
    }
    function () payable public{
        createTokens();
    }   

    
    function createTokens() payable public{
        ICOPhase storage i = icoPhases[currentICOPhase]; 
        require(msg.value > 0
            && i.saleOn == true);
        
        uint256 totalreferrerPerc = 0;
        
       // uint256 tokens = msg.value.mul((i.RATE*(100+r.refereePerc))/100);
       uint256 tokens =   msg.value.mul((currentRate()*(100+r.refereePerc))/100);
        balances[owner] = balances[owner].sub(tokens);
        balances[msg.sender] = balances[msg.sender].add(tokens);
        i.tokensAllocated = i.tokensAllocated.add(tokens);
        totalTokensSoldTillNow = totalTokensSoldTillNow.add(tokens); 
        
        ethContributedBy[msg.sender] = ethContributedBy[msg.sender].add(msg.value);
        totalEthRaised = totalEthRaised.add(msg.value);
        referral storage r = referrals[msg.sender];
        uint8 counter = 1;
        while(r.referrer != 0 && counter <= 2){
                       
            counter = counter + 1;            
            
            uint16 currIndex = referrerRewardIndex[r.referrer] + 1;
            uint rewardGained = (r.referrerPerc*msg.value)/100;
            referrerRewardIndex[r.referrer] = currIndex;
            referrerRewards[r.referrer][currIndex].referee = msg.sender;
            referrerRewards[r.referrer][currIndex].timestamp = now;
            referrerRewards[r.referrer][currIndex].ethContributed = msg.value;
            referrerRewards[r.referrer][currIndex].rewardGained = rewardGained ;
            totalEthRewards[r.referrer] = totalEthRewards[r.referrer].add(rewardGained);
            r.referrer.transfer(rewardGained);
                
            totalreferrerPerc = totalreferrerPerc + r.referrerPerc;
            r = referrals[r.referrer];
            
        }
        ownerMultisig.transfer(((100-totalreferrerPerc)*msg.value)/100);

        //Token Disbursement

        
        if(i.tokensAllocated>=i.tokensStaged){
            i.saleOn = !i.saleOn; 
            currentICOPhase++;
        }
        
    }
    
    
    
    function transfer(address _to, uint _value) onlyWhenTokenIsOn onlyPayloadSize(2 * 32) public returns (bool success){
        //_value = _value.mul(1e18);
        require(
            balances[msg.sender]>=_value 
            && _value > 0
            && now > blockedTill[msg.sender]
        );
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender,_to,_value);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint _value) onlyWhenTokenIsOn onlyPayloadSize(3 * 32) public returns (bool success){
        //_value = _value.mul(10**decimals);
        require(
            allowed[_from][msg.sender]>= _value
            && balances[_from] >= _value
            && _value >0 
            && now > blockedTill[_from]            
        );

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
            
    }
    event Burn(address indexed _burner, uint _value);
    function burn(uint _value) ownerOnly returns (bool)
    {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
        emit Transfer(msg.sender, address(0x0), _value);
        return true;
    }
     event Mint(address indexed to, uint256 amount);
    event MintFinished();

     bool public mintingFinished = false;


     modifier canMint() {
     require(!mintingFinished);
     _;
   }
    function mint(address _to, uint256 _amount) ownerOnly canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() ownerOnly canMint public returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
    
}