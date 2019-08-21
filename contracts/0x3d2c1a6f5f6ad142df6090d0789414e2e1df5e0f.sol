pragma solidity ^0.4.24;
// pragma experimental ABIEncoderV2;

interface CitizenInterface {
    function addEarlyIncome(address _sender) external payable;
    function pushTicketRefIncome(address _sender) external payable;
    function addTicketEthSpend(address _citizen, uint256 _value) external payable;
    function addWinIncome(address _citizen, uint256 _value) external;
    function pushEarlyIncome() external payable;
    function getRef(address _address) external view returns(address);
    function isCitizen(address _address) external view returns(bool);
}

interface DAAInterface {
    function pushDividend() external payable;
}

library SafeMath {
    int256 constant private INT256_MIN = -2**255;

    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Multiplies two signed integers, reverts on overflow.
    */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN)); // This is the only case of overflow not detected by the check below

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Integer division of two signed integers truncating the quotient, reverts on division by zero.
    */
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0); // Solidity only automatically asserts when dividing by 0
        require(!(b == -1 && a == INT256_MIN)); // This is the only case of overflow

        int256 c = a / b;

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Subtracts two signed integers, reverts on overflow.
    */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Adds two signed integers, reverts on overflow.
    */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


library Helper {
    using SafeMath for uint256;
    
        
    function bytes32ToUint(bytes32 n) 
        public
        pure
        returns (uint256) 
    {
        return uint256(n);
    }
    
    function stringToBytes32(string memory source) 
        public
        pure
        returns (bytes32 result) 
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
    
    function stringToUint(string memory source) 
        public
        pure
        returns (uint256)
    {
        return bytes32ToUint(stringToBytes32(source));
    }
    
    function validUsername(string _username)
        public
        pure
        returns(bool)
    {
        uint256 len = bytes(_username).length;
        // Im Raum [4, 18]
        if ((len < 4) || (len > 18)) return false;
        // Letzte Char != ' '
        if (bytes(_username)[len-1] == 32) return false;
        // Erste Char != '0'
        return uint256(bytes(_username)[0]) != 48;
    }   
    
    function getRandom(uint256 _seed, uint256 _range)
        public
        pure
        returns(uint256)
    {
        if (_range == 0) return _seed;
        return (_seed % _range) + 1;
    }

}

contract Ticket {
    using SafeMath for uint256;
    
    modifier buyable() {
        require(block.timestamp > round[currentRound].startRound, "Not start, back later please");
        require(block.timestamp < round[currentRound].endRoundByClock1&&(round[currentRound].endRoundByClock2==0 ||block.timestamp < round[currentRound].endRoundByClock2), "round over");
        _;
    }
    
    modifier onlyAdmin() {
        require(msg.sender == devTeam1, "admin required");
        _;
    }
    
    modifier registered(){
        require(citizenContract.isCitizen(msg.sender), "must be a citizen");
        _;
    }
        
    modifier onlyCoreContract() {
        require(isCoreContract[msg.sender], "admin required");
        _;
    }
    
    event BuyATicket(
        address indexed buyer,
        uint256 ticketFrom,
        uint256 ticketTo,
        uint256 creationDate
    );

    address devTeam1;
    address devTeam2;
    address devTeam3;
    address devTeam4;
    
    uint256 TICKET_PRICE = 2*10**15; // 3 demical 0.002
    
    uint256 constant public ZOOM = 1000;
    uint256 constant public PBASE = 24;
    uint256 constant public RDIVIDER = 50000;
    uint256 constant public PMULTI = 48;
    
    // percent
    uint256 constant public EARLY_PERCENT = 20;
    uint256 constant public EARLY_PERCENT_FOR_CURRENT = 70;
    uint256 constant public EARLY_PERCENT_FOR_PREVIOUS = 30;
    uint256 constant public REVENUE_PERCENT = 17;
    uint256 constant public DEV_PERCENT = 3;
    uint256 constant public DIVIDEND_PERCENT = 10;
    uint256 constant public REWARD_PERCENT = 50;
    
    //  reward part
    uint256 constant public LAST_BUY_PERCENT = 20;
    uint8[6] public JACKPOT_PERCENT = [uint8(25),5,5,5,5,5];
    uint256 constant public MOST_SPENDER_PERCENT = 5;
    uint256 constant public MOST_F1_EARNED_PERCENT = 4;
    uint8[5] public DRAW_PERCENT = [uint8(6),1,1,1,1]; // 3 demicel 0.2%
    uint256 constant public NEXTROUND_PERCENT = 20;
    
    uint256 constant public F1_LIMIT = 1 ether;
    
    // clock
    uint8 constant public MULTI_TICKET = 3;
    uint256 constant public LIMMIT_CLOCK_2_ETH = 300 ether;
    uint256 constant public ONE_MIN = 60;
    uint256 constant public ONE_HOUR = 3600; 
    uint256 constant public ONE_DAY = 24 * ONE_HOUR;
    
    // contract
    CitizenInterface public citizenContract;
    DAAInterface public DAAContract;
    mapping (address => bool) public isCoreContract;
    uint256 public coreContractSum;
    address[] public coreContracts;
    
    struct Round {
        uint256 priviousTicketSum;
        uint256 ticketSum;
        uint256 totalEth;
        uint256 totalEthRoundSpend;

        address[] participant;
        mapping(address => uint256) participantTicketAmount;
        mapping(address => uint256) citizenTicketSpend;
        mapping(address => uint256) RefF1Sum;
        mapping(uint256 => Slot) ticketSlot; // from 1
        uint256 ticketSlotSum;              // last
        mapping( address => uint256[]) pSlot;
        
        uint256 earlyIncomeMarkSum;
        mapping(address => uint256) earlyIncomeMark;
        
        uint256 startRound;
        uint256 endRoundByClock1;
        uint256 endRoundByClock2;
        uint256 endRound;
        uint8 numberClaimed;
        
        
        bool is_running_clock2;
    }
    uint256 public totalEthSpendTicket;
    uint256 public ticketSum;
    mapping(address => uint256) public ticketSumByAddress;
    mapping(uint256=> Round) public round;
    uint256 public currentRound=0;
    mapping(address => uint256) earlyIncomeRoundPulled;
    address[4] mostSpender;
    address[4] mostF1Earnerd;
    mapping(address => uint256) mostF1EarnerdId;
    mapping(address => uint256) mostSpenderId;
    mapping(uint256 => address[])  roundWinner;
        
    struct Slot {
        address buyer;
        uint256 ticketFrom;
        uint256 ticketTo;
    }
    
    

    constructor (address[4] _devTeam)
        public
    {
        devTeam1 = _devTeam[0]; 
        devTeam2 = _devTeam[1]; 
        devTeam3 = _devTeam[2]; 
        devTeam4 = _devTeam[3]; 
        currentRound=0;
        round[currentRound].startRound = 1560693600;
        round[currentRound].endRoundByClock1 = round[currentRound].startRound.add(48*ONE_HOUR);
        round[currentRound].endRound = round[currentRound].endRoundByClock1;
    }
    
       // DAAContract, TicketContract, CitizenContract 
    function joinNetwork(address[3] _contract)
        public
    {
        require(address(citizenContract) == 0x0,"already setup");
        citizenContract = CitizenInterface(_contract[2]);
        DAAContract = DAAInterface(_contract[0]);
        for(uint256 i =0; i<3; i++){
            isCoreContract[_contract[i]]=true;
            coreContracts.push(_contract[i]);
        }
        coreContractSum = 3;
    }
    
    function addCoreContract(address _address) public  // [dev1]
        onlyAdmin()
    {
        require(_address!=0x0,"Invalid address");
        isCoreContract[_address] = true;
        coreContracts.push(_address);
        coreContractSum+=1;
    }
    
    function getRestHour() private view returns(uint256){
        uint256 tempCurrentRound;
        if (now>round[currentRound].startRound){
            tempCurrentRound=currentRound;
        }
        else{
            tempCurrentRound=currentRound-1;
        }
        if (now>round[tempCurrentRound].endRound) return 0;
        return round[tempCurrentRound].endRound.sub(now);
    }
    
    function getRestHourClock2() private view returns(uint256){
        if (round[currentRound].is_running_clock2){
            if ((round[currentRound].endRoundByClock2.sub(now)).div(ONE_HOUR)>0){
                return (round[currentRound].endRoundByClock2.sub(now)).div(ONE_HOUR);
            }
            return 0;
        }
        return 48;
    }
    
    function getTicketPrice() public view returns(uint256){
        if (round[currentRound].is_running_clock2){
            return TICKET_PRICE + TICKET_PRICE*(50-getRestHourClock2())*4/100;
        }
        return TICKET_PRICE;
    }
    
    function softMostF1(address _ref) private {
        uint256 citizen_spender = round[currentRound].RefF1Sum[_ref];
        uint256 i=1;
        while (i<4) {
            if (mostF1Earnerd[i]==0x0||(mostF1Earnerd[i]!=0x0&&round[currentRound].RefF1Sum[mostF1Earnerd[i]]<citizen_spender)){
                if (mostF1EarnerdId[_ref]!=0&&mostF1EarnerdId[_ref]<i){
                    break;
                }
                if (mostF1EarnerdId[_ref]!=0){
                    mostF1Earnerd[mostF1EarnerdId[_ref]]=0x0;
                }
                address temp1 = mostF1Earnerd[i];
                address temp2;
                uint256 j=i+1;
                while (j<4&&temp1!=0x0){
                    temp2 = mostF1Earnerd[j];
                    mostF1Earnerd[j]=temp1;
                    mostF1EarnerdId[temp1]=j;
                    temp1 = temp2;
                    j++;
                }
                mostF1Earnerd[i]=_ref;
                mostF1EarnerdId[_ref]=i;
                break;
            }
            i++;
        }
    } 
    

    function softMostSpender(address _ref) private {
        uint256 citizen_spender = round[currentRound].citizenTicketSpend[_ref];
        uint256 i=1;
        while (i<4) {
            if (mostSpender[i]==0x0||(mostSpender[i]!=0x0&&round[currentRound].citizenTicketSpend[mostSpender[i]]<citizen_spender)){
                if (mostSpenderId[_ref]!=0&&mostSpenderId[_ref]<i){
                    break;
                }
                if (mostSpenderId[_ref]!=0){
                    mostSpender[mostSpenderId[_ref]]=0x0;
                }
                address temp1 = mostSpender[i];
                address temp2;
                uint256 j=i+1;
                while (j<4&&temp1!=0x0){
                    temp2 = mostSpender[j];
                    mostSpender[j]=temp1;
                    mostSpenderId[temp1]=j;
                    temp1 = temp2;
                    j++;
                }
                mostSpender[i]=_ref;
                mostSpenderId[_ref]=i;
                break;
            }
            i++;
        }
    } 
    
    function addTicketEthSpend(address _sender,uint256 _value) private{
        citizenContract.addTicketEthSpend(_sender,_value);
        
        address refAdress = citizenContract.getRef(_sender);
        if (refAdress != devTeam3 && round[currentRound].citizenTicketSpend[_sender]<F1_LIMIT){ // devTeam3 cannot receiver this arward.
            uint256 valueFromF1;
            
            //  limmit at 1 ether
            if (round[currentRound].citizenTicketSpend[_sender].add(_value)>F1_LIMIT){
                uint256 temp = round[currentRound].citizenTicketSpend[_sender].add(_value).sub(F1_LIMIT);
                valueFromF1 = _value.sub(temp);
            } else {
                valueFromF1 = _value;
            }
            
            // sum f1 deposit
            round[currentRound].RefF1Sum[refAdress] = round[currentRound].RefF1Sum[refAdress].add(valueFromF1);
            
            //  find max mostF1Earnerd
            softMostF1(refAdress);
            
        }
        
        round[currentRound].citizenTicketSpend[_sender] = round[currentRound].citizenTicketSpend[_sender].add(_value);
        
        // find max mostSpender
        softMostSpender(_sender);
        
        // calculate total
        totalEthSpendTicket = totalEthSpendTicket.add(_value);
    }
    
    
    function isAddressTicket(uint256 _round,uint256 _slot, uint256 _ticket) private view returns(bool){
        Slot storage temp = round[_round].ticketSlot[_slot];
        if (temp.ticketFrom<=_ticket&&_ticket<=temp.ticketTo) return true;
        return false;
    }
    
    function getAddressTicket(uint256 _round, uint256 _ticket) public view returns(address){
        uint256 _from = 0;
        uint256 _to = round[_round].ticketSlotSum;
        uint256 _mid;
        
        while(_from<=_to){
            _mid = (_from+_to).div(2);
            if (isAddressTicket(_round,_mid,_ticket)) return round[_round].ticketSlot[_mid].buyer;
            if (_ticket<round[_round].ticketSlot[_mid].ticketFrom){
                _to = _mid-1;
            }
            else {
                _from = _mid+1;
            }
        }
        
        // if errors
        return round[_round].ticketSlot[_mid].buyer;
    }
    
    function drawWinner() public registered() {
        // require(round[currentRound].participantTicketAmount[msg.sender] > 0, "must buy at least 1 ticket");
        require(round[currentRound].endRound.add(ONE_MIN)<now);
        
        // address lastbuy = getAddressTicket(currentRound, round[currentRound].ticketSum-1);
        address lastbuy = round[currentRound].ticketSlot[round[currentRound].ticketSlotSum].buyer;
        roundWinner[currentRound].push(lastbuy);
        uint256 arward_last_buy = round[currentRound].totalEth*LAST_BUY_PERCENT/100;
        lastbuy.transfer(arward_last_buy);
        citizenContract.addWinIncome(lastbuy,arward_last_buy);
        
        mostSpender[1].transfer(round[currentRound].totalEth*MOST_SPENDER_PERCENT/100);
        citizenContract.addWinIncome(mostSpender[1],round[currentRound].totalEth*MOST_SPENDER_PERCENT/100);
        mostF1Earnerd[1].transfer(round[currentRound].totalEth*MOST_F1_EARNED_PERCENT/100);
        citizenContract.addWinIncome(mostF1Earnerd[1],round[currentRound].totalEth*MOST_F1_EARNED_PERCENT/100);
        roundWinner[currentRound].push(mostSpender[1]);
        roundWinner[currentRound].push(mostF1Earnerd[1]);
        
        uint256 _seed = getSeed();
        for (uint256 i = 0; i < 6; i++){
            uint256 winNumber = Helper.getRandom(_seed, round[currentRound].ticketSum);
            if (winNumber==0) winNumber= round[currentRound].ticketSum;
            address winCitizen = getAddressTicket(currentRound,winNumber);
            winCitizen.transfer(round[currentRound].totalEth.mul(JACKPOT_PERCENT[i]).div(100));
            citizenContract.addWinIncome(winCitizen,round[currentRound].totalEth.mul(JACKPOT_PERCENT[i]).div(100));
            roundWinner[currentRound].push(winCitizen);
            _seed = _seed + (_seed / 10);
        }
        
        
        uint256 totalEthLastRound = round[currentRound].totalEth*NEXTROUND_PERCENT/100;
        // Next Round
        delete mostSpender;
        delete mostF1Earnerd;
        currentRound = currentRound+1;
        round[currentRound].startRound = now.add(12*ONE_HOUR);
        round[currentRound].totalEth = totalEthLastRound;
        round[currentRound].endRoundByClock1 = now.add(60*ONE_HOUR); //12+48
        round[currentRound].endRound = round[currentRound].endRoundByClock1;
        claim();
    }
    
    function claim() public registered() {
        // require drawed winner
        require(currentRound>0&&round[currentRound].ticketSum==0);
        uint256 lastRound = currentRound-1;
        // require 5 citizen can draw
        require(round[lastRound].numberClaimed<5);
        // require time;
        require(round[lastRound].endRound.add(ONE_MIN)<now);
        address _sender = msg.sender;
        roundWinner[lastRound].push(_sender);
        uint256 numberClaimed = round[lastRound].numberClaimed;
        uint256 _arward = round[currentRound-1].totalEth*DRAW_PERCENT[numberClaimed]/1000;
        _sender.transfer(_arward);
        citizenContract.addWinIncome(_sender,_arward);
        round[lastRound].numberClaimed = round[lastRound].numberClaimed+1;
        round[lastRound].endRound = now.add(5*ONE_MIN);
    }
    
    function getEarlyIncomeMark(uint256 _ticketSum) public pure returns(uint256){
        uint256 base = _ticketSum * ZOOM / RDIVIDER;
        uint256 expo = base.mul(base).mul(base); //^3
        expo = expo.mul(expo).mul(PMULTI); 
        expo =  expo.div(ZOOM**5);
        return (1 + PBASE*ZOOM / (1*ZOOM + expo));
    }

    function buyTicket(uint256 _quantity) payable public registered() buyable() returns(bool) {
        uint256 ethDeposit = msg.value;
        address _sender = msg.sender;
        require(_quantity*getTicketPrice()==ethDeposit,"Not enough eth for current quantity");
        
        // after one day sale  | extra time
        if (now>=round[currentRound].startRound.add(ONE_DAY)){
            uint256 extraTime = _quantity.mul(30);
            if (round[currentRound].endRoundByClock1.add(extraTime)>now.add(ONE_DAY)){
                round[currentRound].endRoundByClock1 = now.add(ONE_DAY);
            } else {
                round[currentRound].endRoundByClock1 = round[currentRound].endRoundByClock1.add(extraTime);
            }
        }
        
        // F1, most spender
        addTicketEthSpend(_sender, ethDeposit);
        
        
        if (round[currentRound].participantTicketAmount[_sender]==0){
            round[currentRound].participant.push(_sender);
        }
        // //  Occupied Slot
        if(round[currentRound].is_running_clock2){
            _quantity=_quantity.mul(MULTI_TICKET);
        }
        
        uint256 ticketSlotSumTemp = round[currentRound].ticketSlotSum.add(1);
        round[currentRound].ticketSlotSum = ticketSlotSumTemp;
        round[currentRound].ticketSlot[ticketSlotSumTemp].buyer = _sender;
        round[currentRound].ticketSlot[ticketSlotSumTemp].ticketFrom = round[currentRound].ticketSum+1;
        
        // 20% Early Income Mark
        uint256 earlyIncomeMark = getEarlyIncomeMark(round[currentRound].ticketSum);
        earlyIncomeMark = earlyIncomeMark.mul(_quantity);
        round[currentRound].earlyIncomeMarkSum = earlyIncomeMark.add(round[currentRound].earlyIncomeMarkSum);
        round[currentRound].earlyIncomeMark[_sender] = earlyIncomeMark.add(round[currentRound].earlyIncomeMark[_sender]);
        
        round[currentRound].ticketSum = round[currentRound].ticketSum.add(_quantity);
        ticketSum = ticketSum.add(_quantity);
        ticketSumByAddress[_sender] = ticketSumByAddress[_sender].add(_quantity);
        round[currentRound].ticketSlot[ticketSlotSumTemp].ticketTo = round[currentRound].ticketSum;
        round[currentRound].participantTicketAmount[_sender] = round[currentRound].participantTicketAmount[_sender].add(_quantity);
        round[currentRound].pSlot[_sender].push(ticketSlotSumTemp);
        emit BuyATicket(_sender, round[currentRound].ticketSlot[ticketSlotSumTemp].ticketFrom, round[currentRound].ticketSlot[ticketSlotSumTemp].ticketTo, now);
            
        // 20% EarlyIncome
        uint256 earlyIncome=  ethDeposit*EARLY_PERCENT/100;
        citizenContract.pushEarlyIncome.value(earlyIncome)();
        
        // 17% Revenue
        uint256 revenue =  ethDeposit*REVENUE_PERCENT/100;
        citizenContract.pushTicketRefIncome.value(revenue)(_sender);
        
        // 10% Devidend
        uint256 devidend =  ethDeposit*DIVIDEND_PERCENT/100;
        DAAContract.pushDividend.value(devidend)();
        
        // 3% devTeam
        uint256 devTeamPaid = ethDeposit*DEV_PERCENT/100;
        devTeam1.transfer(devTeamPaid);
        
        // 50% reward
        uint256 rewardPaid = ethDeposit*REWARD_PERCENT/100;
        round[currentRound].totalEth = rewardPaid.add(round[currentRound].totalEth);
        
        round[currentRound].totalEthRoundSpend = ethDeposit.add(round[currentRound].totalEthRoundSpend);
        
        // Run clock 2
        if (round[currentRound].is_running_clock2==false&&((currentRound==0 && round[currentRound].totalEth>=LIMMIT_CLOCK_2_ETH)||(currentRound>0&&round[currentRound].totalEth>round[currentRound-1].totalEth))){
            round[currentRound].is_running_clock2=true;
            round[currentRound].endRoundByClock2 = now.add(48*ONE_HOUR);
        }
        uint256 tempEndRound = round[currentRound].endRoundByClock2;
        // update endround Time
        if (round[currentRound].endRoundByClock2>round[currentRound].endRoundByClock1||round[currentRound].endRoundByClock2==0){
            tempEndRound = round[currentRound].endRoundByClock1;
        }
        round[currentRound].endRound = tempEndRound;
        
        return true;
    }
    
    // early income real time display
    function getEarlyIncomeView(address _sender, bool _current) public view returns(uint256){
        uint256 _last_round = earlyIncomeRoundPulled[_sender];
        uint256 _currentRound = currentRound;
        if (_current) {
            _currentRound = _currentRound.add(1);
        }
        if (_last_round + 100 < _currentRound) _last_round = _currentRound - 100;

        uint256 _sum;
        for (uint256 i = _last_round;i<_currentRound;i++){
            _sum = _sum.add(getEarlyIncomeByRound(_sender, i));
        }
        return _sum;
    }
    
    //  early income pull
    function getEarlyIncomePull(address _sender) onlyCoreContract() public returns(uint256){
        uint256 _last_round = earlyIncomeRoundPulled[_sender];
        if (_last_round + 100 < currentRound) _last_round = currentRound - 100;
        uint256 _sum;
        for (uint256 i = _last_round;i<currentRound;i++){
            _sum = _sum.add(getEarlyIncomeByRound(_sender, i));
        }
        earlyIncomeRoundPulled[_sender] = currentRound;
        return _sum;
    }
    
    function getEarlyIncomeByRound(address _buyer, uint256 _round) public view returns(uint256){
        uint256 _previous_round;
        _previous_round = _round-1;
            if (_round==0) _previous_round = 0;
        uint256 _sum=0;
        uint256 _totalEth = round[_round].totalEthRoundSpend*EARLY_PERCENT/100;
        uint256 _currentAmount = _totalEth*EARLY_PERCENT_FOR_CURRENT/100;
        uint256 _previousAmount = _totalEth*EARLY_PERCENT_FOR_PREVIOUS/100;
        
        if (round[_round].earlyIncomeMarkSum>0){
             _sum = round[_round].earlyIncomeMark[_buyer].mul(_currentAmount).div(round[_round].earlyIncomeMarkSum);
        }
        if (round[_previous_round].earlyIncomeMarkSum>0){
            _sum = _sum.add(round[_previous_round].earlyIncomeMark[_buyer].mul(_previousAmount).div(round[_previous_round].earlyIncomeMarkSum));
        }
        return _sum;
    }

    function getSeed()
        public
        view
        returns (uint64)
    {
        return uint64(keccak256(block.timestamp, block.difficulty));
    }
    
    function sendTotalEth() onlyAdmin() public {
        DAAContract.pushDividend.value(address(this).balance)();
        round[currentRound].totalEth=0;
    }
    
    function getMostSpender() public view returns(address[4]){
        return mostSpender;
    }
    
    function getMostF1Earnerd() public view returns(address[4]){
        return mostF1Earnerd;
    }
    
    function getResultWinner(uint256 _round) public view returns(address[]){
        require(_round<currentRound);
        return roundWinner[_round];
    }
    
    function getCitizenTicketSpend(uint256 _round, address _sender) public view returns(uint256){
        return round[_round].citizenTicketSpend[_sender];
    }
    
    function getCititzenTicketSum(uint256 _round) public view returns(uint256){
        address _sender =msg.sender;
        return round[_round].participantTicketAmount[_sender];
    }
    
    function getRefF1Sum(uint256 _round, address _sender) public view returns(uint256){
        return round[_round].RefF1Sum[_sender];
    }
    
    function getLastBuy(uint256 _round) public view returns(address){
        return round[_round].ticketSlot[round[_round].ticketSlotSum].buyer;
    }
    
    function getCitizenSumSlot(uint256 _round) public view returns(uint256){
        address _sender = msg.sender;
        return round[_round].pSlot[_sender].length;
    }
    
    function getCitizenSlotId(uint256 _round, uint256 _id) public view returns(uint256){
        address _sender = msg.sender;
        return round[_round].pSlot[_sender][_id];
    }
    
    function getCitizenSlot(uint256 _round, uint256 _slotId) public view returns(address, uint256, uint256){
        Slot memory _slot = round[_round].ticketSlot[_slotId];
        return (_slot.buyer,_slot.ticketFrom,_slot.ticketTo);
    }
    
}