pragma solidity ^0.4.25;


/**
* @title ThorMutual
* @author Leo
* @dev Thor Mutual for TRX, WAVES, ADA, ERC20 and so on
*/


contract Utils {

    uint constant DAILY_PERIOD = 1;
    uint constant WEEKLY_PERIOD = 7;

    int constant PRICE_DECIMALS = 10 ** 8;

    int constant INT_MAX = 2 ** 255 - 1;

    uint constant UINT_MAX = 2 ** 256 - 1;

}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    // /**
    //  * @dev Allows the current owner to relinquish control of the contract.
    //  * @notice Renouncing to ownership will leave the contract without an owner.
    //  * It will not be possible to call the functions with the `onlyOwner`
    //  * modifier anymore.
    //  */
    // function renounceOwnership() public onlyOwner {
    //     emit OwnershipTransferred(_owner, address(0));
    //     _owner = address(0);
    // }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


interface ThorMutualInterface {
    function getCurrentPeriod() external view returns(uint);
    function settle() external;
}


/**
 * @title ThorMutualToken
 * @dev Every ThorMutualToken contract is related with a specific token such as BTC/ETH/EOS/ERC20
 * functions, participants send ETH to this contract to take part in the Thor Mutual activity.
 */
contract ThorMutualToken is Ownable, Utils {
    string public thorMutualToken;

    // total deposit for a specific period
    mapping(uint => uint) amountOfDailyPeriod;

    // total deposit for a specific period
    mapping(uint => uint) amountOfWeeklyPeriod;

    // participant's total deposit fund
    mapping(address => uint) participantAmount;

    // participants
    address[] participants;

    // deposit info
    struct DepositInfo {
        uint blockTimeStamp;
        uint period;
        string token;
        uint amount;
    }

    // participant's total deposit history
    //mapping(address => DepositInfo[]) participantsHistory;
    mapping(address => uint[]) participantsHistoryTime;
    mapping(address => uint[]) participantsHistoryPeriod;
    mapping(address => uint[]) participantsHistoryAmount;

    // participant's total deposit fund for a specific period
    mapping(uint => mapping(address => uint)) participantAmountOfDailyPeriod;

    // participant's total deposit fund for a weekly period
    mapping(uint => mapping(address => uint)) participantAmountOfWeeklyPeriod;

    // participants for the daily period
    mapping(uint => address[]) participantsDaily;

    // participants for the weekly period
    mapping(uint => address[]) participantsWeekly;

    ThorMutualInterface public thorMutualContract;

    constructor(string _thorMutualToken, ThorMutualInterface _thorMutual) public {
        thorMutualToken = _thorMutualToken;
        thorMutualContract = _thorMutual;
    }

    event ThorDepositToken(address sender, uint256 amount);
    function() external payable {
        require(msg.value >= 0.001 ether);
        
        require(address(thorMutualContract) != address(0));
        address(thorMutualContract).transfer(msg.value);

        //uint currentPeriod;
        uint actualPeriod = 0;
        uint actualPeriodWeek = 0;

        actualPeriod = thorMutualContract.getCurrentPeriod();

        actualPeriodWeek = actualPeriod / WEEKLY_PERIOD;

        if (participantAmount[msg.sender] == 0) {
            participants.push(msg.sender);
        }

        if (participantAmountOfDailyPeriod[actualPeriod][msg.sender] == 0) {
            participantsDaily[actualPeriod].push(msg.sender);
        }

        if (participantAmountOfWeeklyPeriod[actualPeriodWeek][msg.sender] == 0) {
            participantsWeekly[actualPeriodWeek].push(msg.sender);
        }

        participantAmountOfDailyPeriod[actualPeriod][msg.sender] += msg.value;

        participantAmount[msg.sender] += msg.value;
        
        participantAmountOfWeeklyPeriod[actualPeriodWeek][msg.sender] += msg.value;

        amountOfDailyPeriod[actualPeriod] += msg.value;

        amountOfWeeklyPeriod[actualPeriodWeek] += msg.value;

        // DepositInfo memory depositInfo = DepositInfo(block.timestamp, actualPeriod, thorMutualToken, msg.value);

        // participantsHistory[msg.sender].push(depositInfo);

        participantsHistoryTime[msg.sender].push(block.timestamp);
        participantsHistoryPeriod[msg.sender].push(actualPeriod);
        participantsHistoryAmount[msg.sender].push(msg.value);

        emit ThorDepositToken(msg.sender, msg.value);
    }

    function setThorMutualContract(ThorMutualInterface _thorMutualContract) public onlyOwner{
        require(address(_thorMutualContract) != address(0));
        thorMutualContract = _thorMutualContract;
    }

    function getThorMutualContract() public view returns(address) {
        return thorMutualContract;
    }

    function setThorMutualToken(string _thorMutualToken) public onlyOwner {
        thorMutualToken = _thorMutualToken;
    }

    function getDepositDailyAmountofPeriod(uint period) external view returns(uint) {
        require(period >= 0);

        return amountOfDailyPeriod[period];
    }

    function getDepositWeeklyAmountofPeriod(uint period) external view returns(uint) {
        require(period >= 0);
        uint periodWeekly = period / WEEKLY_PERIOD;
        return amountOfWeeklyPeriod[periodWeekly];
    }

    function getParticipantsDaily(uint period) external view returns(address[], uint) {
        require(period >= 0);

        return (participantsDaily[period], participantsDaily[period].length);
    }

    function getParticipantsWeekly(uint period) external view returns(address[], uint) {
        require(period >= 0);

        uint periodWeekly = period / WEEKLY_PERIOD;
        return (participantsWeekly[periodWeekly], participantsWeekly[period].length);
    }

    function getParticipantAmountDailyPeriod(uint period, address participant) external view returns(uint) {
        require(period >= 0);

        return participantAmountOfDailyPeriod[period][participant];
    }

    function getParticipantAmountWeeklyPeriod(uint period, address participant) external view returns(uint) {
        require(period >= 0);

        uint periodWeekly = period / WEEKLY_PERIOD;
        return participantAmountOfWeeklyPeriod[periodWeekly][participant];
    }

    //function getParticipantHistory(address participant) public view returns(DepositInfo[]) {
    function getParticipantHistory(address participant) public view returns(uint[], uint[], uint[]) {

        return (participantsHistoryTime[participant], participantsHistoryPeriod[participant], participantsHistoryAmount[participant]);
        //return participantsHistory[participant];
    }

    function getSelfBalance() public view returns(uint) {
        return address(this).balance;
    }

    function withdraw(address receiver, uint amount) public onlyOwner {
        require(receiver != address(0));

        receiver.transfer(amount);
    }

}


interface ThorMutualTokenInterface {
    function getParticipantsDaily(uint period) external view returns(address[], uint);
    function getParticipantsWeekly(uint period) external view returns(address[], uint);
    function getDepositDailyAmountofPeriod(uint period) external view returns(uint);
    function getDepositWeeklyAmountofPeriod(uint period) external view returns(uint);
    function getParticipantAmountDailyPeriod(uint period, address participant) external view returns(uint);
    function getParticipantAmountWeeklyPeriod(uint period, address participant) external view returns(uint);
}

interface ThorMutualTokenPriceInterface {
    function getMaxDailyDrawdown(uint period) external view returns(address);
    function getMaxWeeklyDrawdown(uint period) external view returns(address);
}

interface ThorMutualWeeklyRewardInterface {
    function settleWeekly(address winner, uint amountWinner) external; 
}

contract ThorMutual is Ownable, Utils {

    string public thorMutual;

    // period update daily
    uint internal periodUpdateIndex = 0;

    // initial flag
    bool internal initialFlag = false;

    ThorMutualTokenPriceInterface public thorMutualTokenPrice;

    ThorMutualTokenInterface[] thorMutualTokens;

    ThorMutualWeeklyReward public thorMutualWeeklyReward;

    mapping(uint => address) winnerDailyTokens;
    mapping(uint => address) winnerWeeklyTokens;

    mapping(uint => uint) winnerDailyParticipantAmounts;
    mapping(uint => uint) winnerWeeklyParticipantAmounts;

    mapping(uint => uint) winnerDailyDepositAmounts;

    mapping(uint => address) winnerWeeklyAccounts;

    // daily winners' award
    mapping(uint => mapping(address => uint)) winnerDailyParticipantInfos;

    // weekly winners' award
    mapping(uint => mapping(address => uint)) winnerWeeklyParticipantInfos;

    // struct AwardInfo {
    //     address winner;
    //     uint awardAmount;
    // }

    // daily winners' address
    mapping(uint => address[]) winnerDailyParticipantAddrs;
    mapping(uint => uint[]) winnerDailyParticipantAwards;

    // weekly winners' info
    mapping(uint => address) winnerWeeklyParticipantAddrs;
    mapping(uint => uint) winnerWeeklyParticipantAwards;

    // 0.001 eth = 1 finney 
    // uint internal threadReward = 1 * 10 ** 15;

    // 
    uint internal distributeRatioOfDaily = 70;
    uint internal distributeRatioOfWeekly = 20;
    uint internal distributeRatioOfPlatform = 10;

    uint internal ratioWeekly = 5;

    // address of platform
    address internal rewardAddressOfPlatfrom;

    constructor() public {
        thorMutual = "ThorMutual";
    }

    event DepositToken(address token, uint256 amount);
    function() external payable {
        emit DepositToken(msg.sender, msg.value);
    }

    function setThorMutualParms(uint _distributeRatioOfDaily, uint _distributeRatioOfWeekly, uint _distributeRatioOfPlatform, uint _ratioWeekly) public onlyOwner {
        require(_distributeRatioOfDaily + _distributeRatioOfWeekly + _distributeRatioOfPlatform == 100);
        require(_ratioWeekly >= 0 && _ratioWeekly <= 10);

        distributeRatioOfDaily = _distributeRatioOfDaily;
        distributeRatioOfWeekly = _distributeRatioOfWeekly;
        distributeRatioOfPlatform = _distributeRatioOfPlatform;
        ratioWeekly = _ratioWeekly;
    }

    function getThorMutualParms() public view returns(uint, uint, uint, uint){
        return (distributeRatioOfDaily, distributeRatioOfWeekly, distributeRatioOfPlatform, ratioWeekly);
    }

    /**
     * @dev set thorMutualTokens' contract address
     * @param _thorMutualTokens _thorMutualTokens
     * @param _length _length
     */
    function setThorMutualTokenContracts(ThorMutualTokenInterface[] memory _thorMutualTokens, uint _length) public onlyOwner {
        require(_thorMutualTokens.length == _length);

        for (uint i = 0; i < _length; i++) {
            thorMutualTokens.push(_thorMutualTokens[i]);
        }
    }

    function initialPeriod() internal {
        periodUpdateIndex++;
    }

    /**
     * @dev return periodUpdateIndex, periodActual
     * @return the index return periodUpdateIndex, periodActual
     */
    function getCurrentPeriod() public view returns(uint) {
        return periodUpdateIndex;
    }

    function settle() external {

        require(address(thorMutualTokenPrice) == msg.sender);

        if(initialFlag == false) {
            initialFlag = true;

            initialPeriod();

            return;
        }

        dailySettle();

        if(periodUpdateIndex % WEEKLY_PERIOD == 0){
            weeklySettle();
        }

        periodUpdateIndex++;
    }

    event ThorMutualRewardOfPlatfrom(address, uint256);

    function dailySettle() internal {

        require(periodUpdateIndex >= 1);

        address maxDrawdownThorMutualTokenAddress;

        maxDrawdownThorMutualTokenAddress = thorMutualTokenPrice.getMaxDailyDrawdown(periodUpdateIndex);

        if (maxDrawdownThorMutualTokenAddress == address(0)) {
            return;
        }

        winnerDailyTokens[periodUpdateIndex-1] = maxDrawdownThorMutualTokenAddress;

        ThorMutualTokenInterface maxDrawdownThorMutualToken = ThorMutualTokenInterface(maxDrawdownThorMutualTokenAddress);

        address[] memory winners;
        (winners, ) = maxDrawdownThorMutualToken.getParticipantsDaily(periodUpdateIndex - 1);
        uint winnersLength = winners.length;

        winnerDailyParticipantAmounts[periodUpdateIndex-1] = winnersLength;

        uint amountOfPeriod = 0;
        uint i = 0;
        for (i = 0; i < thorMutualTokens.length; i++) {
            amountOfPeriod += thorMutualTokens[i].getDepositDailyAmountofPeriod(periodUpdateIndex - 1);
        }

        winnerDailyDepositAmounts[periodUpdateIndex-1] = amountOfPeriod;

        uint rewardAmountOfDaily = amountOfPeriod * distributeRatioOfDaily / 100;
        uint rewardAmountOfPlatform = amountOfPeriod * distributeRatioOfPlatform / 100;
        uint rewardAmountOfWeekly = amountOfPeriod - rewardAmountOfDaily - rewardAmountOfPlatform;
        
        uint amountOfTokenAndPeriod = maxDrawdownThorMutualToken.getDepositDailyAmountofPeriod(periodUpdateIndex - 1);

        for (i = 0; i < winnersLength; i++) {
            address rewardParticipant = winners[i];

            uint depositAmountOfParticipant = maxDrawdownThorMutualToken.getParticipantAmountDailyPeriod(periodUpdateIndex - 1, rewardParticipant);

            uint rewardAmountOfParticipant = depositAmountOfParticipant * rewardAmountOfDaily / amountOfTokenAndPeriod;

            // if (rewardAmountOfParticipant > threadReward) {
            rewardParticipant.transfer(rewardAmountOfParticipant);

            // record winner's info
            winnerDailyParticipantInfos[periodUpdateIndex - 1][rewardParticipant] = rewardAmountOfParticipant;

            winnerDailyParticipantAddrs[periodUpdateIndex - 1].push(rewardParticipant);
            winnerDailyParticipantAwards[periodUpdateIndex - 1].push(rewardAmountOfParticipant);

            // }
        }

        rewardAddressOfPlatfrom.transfer(rewardAmountOfPlatform);
        emit ThorMutualRewardOfPlatfrom(rewardAddressOfPlatfrom, rewardAmountOfPlatform);

        address(thorMutualWeeklyReward).transfer(rewardAmountOfWeekly);

    }

    function weeklySettle() internal {

        require(periodUpdateIndex >= WEEKLY_PERIOD);

        address maxDrawdownThorMutualTokenAddress;

        maxDrawdownThorMutualTokenAddress = thorMutualTokenPrice.getMaxWeeklyDrawdown(periodUpdateIndex);

        if (maxDrawdownThorMutualTokenAddress == address(0)) {
            return;
        }

        uint weeklyPeriod = (periodUpdateIndex - 1) / WEEKLY_PERIOD;

        winnerWeeklyTokens[weeklyPeriod] = maxDrawdownThorMutualTokenAddress;

        ThorMutualTokenInterface maxDrawdownThorMutualToken = ThorMutualTokenInterface(maxDrawdownThorMutualTokenAddress);

        address[] memory participants;
        (participants, ) = maxDrawdownThorMutualToken.getParticipantsWeekly(periodUpdateIndex - 1);
        uint winnersLength = participants.length;

        winnerWeeklyParticipantAmounts[weeklyPeriod] = winnersLength;

        //address[] winners;
        address winner;
        uint maxDeposit = 0;

        for (uint i = 0; i < winnersLength; i++) {
            address rewardParticipant = participants[i];

            uint depositAmountOfParticipant = maxDrawdownThorMutualToken.getParticipantAmountWeeklyPeriod(periodUpdateIndex - 1, rewardParticipant);

            if(depositAmountOfParticipant > maxDeposit) {
                winner = rewardParticipant;
                maxDeposit = depositAmountOfParticipant;
            }

        }

        winnerWeeklyAccounts[weeklyPeriod] = winner;

        uint thorMutualWeeklyRewardFund = address(thorMutualWeeklyReward).balance;

        uint winnerWeeklyAward = thorMutualWeeklyRewardFund * ratioWeekly / 10;

        thorMutualWeeklyReward.settleWeekly(winner, winnerWeeklyAward);

        // record winner's info

        winnerWeeklyParticipantInfos[weeklyPeriod][winner] = winnerWeeklyAward;

        winnerWeeklyParticipantAddrs[weeklyPeriod] = winner;
        winnerWeeklyParticipantAwards[weeklyPeriod] = winnerWeeklyAward;

    }

    function getDailyWinnerTokenInfo(uint period) public view returns(address, uint, uint, address[], uint[]) {
        require(period >= 0 && period < periodUpdateIndex);

        address token = winnerDailyTokens[period];

        uint participantAmount = winnerDailyParticipantAmounts[period];

        uint depositAmount = winnerDailyDepositAmounts[period];

        return (token, participantAmount, depositAmount, winnerDailyParticipantAddrs[period], winnerDailyParticipantAwards[period]);
    }

    function getWeeklyWinnerTokenInfo(uint period) public view returns(address, uint, address, address, uint) {
        require(period >= 0 && period < periodUpdateIndex);

        uint actualPeriod = period / WEEKLY_PERIOD;

        address token = winnerWeeklyTokens[actualPeriod];

        uint participantAmount = winnerWeeklyParticipantAmounts[actualPeriod];

        address winner = winnerWeeklyAccounts[actualPeriod];

        return (token, participantAmount, winner, winnerWeeklyParticipantAddrs[actualPeriod], winnerWeeklyParticipantAwards[actualPeriod]);
    }

    function getDailyAndWeeklyWinnerInfo(uint period, address winner) public view returns(uint, uint){
        require(period >= 0 && period < periodUpdateIndex);

        uint periodWeekly = period / WEEKLY_PERIOD;

        return (winnerDailyParticipantInfos[period][winner], winnerWeeklyParticipantInfos[periodWeekly][winner]);
    }

    /**
     * @dev set thorMutualTokenPrice's contract address
     * @param _thorMutualTokenPrice _thorMutualTokenPrice
     */
    function setThorMutualTokenPrice(ThorMutualTokenPriceInterface _thorMutualTokenPrice) public onlyOwner {
        require(address(_thorMutualTokenPrice) != address(0));
        thorMutualTokenPrice = _thorMutualTokenPrice;
    }

    function setRewardAddressOfPlatfrom(address _rewardAddressOfPlatfrom) public onlyOwner {
        require(_rewardAddressOfPlatfrom != address(0));
        rewardAddressOfPlatfrom = _rewardAddressOfPlatfrom;
    }

    function setThorMutualWeeklyReward(address _thorMutualWeeklyReward) public onlyOwner {
        require(_thorMutualWeeklyReward != address(0));
        thorMutualWeeklyReward = ThorMutualWeeklyReward(_thorMutualWeeklyReward);
    }

    function getSelfBalance() public view returns(uint) {
        return address(this).balance;
    }

    function withdraw(address receiver, uint amount) public onlyOwner {
        require(receiver != address(0));

        receiver.transfer(amount);
    }

}

contract ThorMutualWeeklyReward is Ownable, Utils {

    string public thorMutualWeeklyReward;

    address public thorMutual;

    constructor(ThorMutualInterface _thorMutual) public {
        thorMutualWeeklyReward = "ThorMutualWeeklyReward";
        thorMutual = address(_thorMutual);
    }

    event ThorMutualWeeklyRewardDeposit(uint256 amount);
    function() external payable {
        emit ThorMutualWeeklyRewardDeposit(msg.value);
    }

    event SettleWeekly(address winner, uint256 amount);
    function settleWeekly(address winner, uint amountWinner) external {

        require(msg.sender == thorMutual);
        require(winner != address(0));

        winner.transfer(amountWinner);

        emit SettleWeekly(winner, amountWinner);
    }

    function setThorMutualContract(address _thorMutualContract) public onlyOwner{
        require(_thorMutualContract != address(0));
        thorMutual = _thorMutualContract;
    }

    function getSelfBalance() public view returns(uint) {
        return address(this).balance;
    }

    function withdraw(address receiver, uint amount) public onlyOwner {
        require(receiver != address(0));

        receiver.transfer(amount);
    }

}

contract ThorMutualTokenPrice is Ownable, Utils {

    string public thorMutualTokenPrice;

    address[] internal tokensIncluded;
    mapping(address => bool) isTokenIncluded;

    ThorMutualInterface public thorMutualContract;

    struct TokenPrice{
        uint blockTimeStamp;
        uint price;
    }
    // mapping(address => TokenPrice) tokensPrice;

    mapping(uint => mapping(address => TokenPrice)) dailyTokensPrices;

    constructor(ThorMutualInterface _thorMutual) public {
        thorMutualTokenPrice = "ThorMutualTokenPrice";
        thorMutualContract = _thorMutual;
    }

    mapping(uint => int[]) dailyTokensPricesDrawdown;
    mapping(uint => int[]) weeklyTokensPricesDrawdown;

    mapping(uint =>ThorMutualTokenInterface) dailyTokenWinners;
    mapping(uint =>ThorMutualTokenInterface) weeklyTokenWinners;

    /**
     * @dev return all tokens included
     * @return string[], a list of tokens
     */
    function getTokensIncluded() public view returns(address[]) {
        return tokensIncluded;
    }

    function addTokensAndPrices(address[] _newTokens, uint[] _prices, uint _length) public onlyOwner {
        require(_length == _newTokens.length);
        require(_length == _prices.length);

        uint actualPeriod;
        actualPeriod = thorMutualContract.getCurrentPeriod();

        for (uint i = 0; i < _length; i++) {
            require(!isTokenIncluded[_newTokens[i]]);
            isTokenIncluded[_newTokens[i]] = true;
            tokensIncluded.push(_newTokens[i]);
            TokenPrice memory tokenPrice = TokenPrice(block.timestamp, _prices[i]);
            dailyTokensPrices[actualPeriod][_newTokens[i]] = tokenPrice;
        }
    }

    /**
     * @dev set prices of a list of tokens
     * @param _tokens a list of tokens
     * @param _prices a list of prices, actual price * (10 ** 8)
     */
    function setTokensPrice(address[] memory _tokens, uint[] memory _prices, bool isSettle) public onlyOwner {

        uint length = _tokens.length;

        uint actualPeriod;
        actualPeriod = thorMutualContract.getCurrentPeriod();

        require(length == _prices.length);
        require(length == tokensIncluded.length);

        for (uint i = 0; i < length; i++) {
            address token = _tokens[i];
            require(isTokenIncluded[token]);
            TokenPrice memory tokenPrice = TokenPrice(block.timestamp, _prices[i]);
            // tokensPrice[token] = tokenPrice;

            dailyTokensPrices[actualPeriod][token] = tokenPrice;
        }

        // calculate tokens' maxDrawdown
        if (isSettle == true && actualPeriod >= 1) {
            //thorMutualContract.settle();
            calculateMaxDrawdown(actualPeriod);
        }
    }

    function calculateMaxDrawdown(uint period) internal {
        ThorMutualTokenInterface dailyWinnerToken;
        ThorMutualTokenInterface weeklyWinnerToken;
        (dailyWinnerToken,) = _getMaxDrawdown(DAILY_PERIOD, period);

        if(period % WEEKLY_PERIOD == 0) {
            (weeklyWinnerToken,) = _getMaxDrawdown(WEEKLY_PERIOD, period);
            weeklyTokenWinners[period / WEEKLY_PERIOD] = weeklyWinnerToken;
        }

        dailyTokenWinners[period] = dailyWinnerToken;
        
    }

    function settle() public onlyOwner {
        require(address(thorMutualContract) != address(0));
        thorMutualContract.settle();
    }

    /**
     * @dev get prices of a list of tokens
     * @param period period
     */

    function getTokenPriceOfPeriod(address token, uint period) public view returns(uint) {
        require(isTokenIncluded[token]);
        require(period >= 0);

        return dailyTokensPrices[period][token].price;

    }

    function setThorMutualContract(ThorMutualInterface _thorMutualContract) public onlyOwner {
        require(address(_thorMutualContract) != address(0));
        thorMutualContract = _thorMutualContract;
    }

    /**
     * @dev return the index of token with daily maximum drawdown
     * @return the index of token with maximum drawdown
     */
    function getMaxDailyDrawdown(uint period) external view returns(ThorMutualTokenInterface) {

        return dailyTokenWinners[period];
    }

    /**
     * @dev return the index of token with weekly maximum drawdown
     * @return the index of token with maximum drawdown
     */
    function getMaxWeeklyDrawdown(uint period) external view returns(ThorMutualTokenInterface) {

        return weeklyTokenWinners[period / WEEKLY_PERIOD];
    }

    /**
     * @dev return the index of token with maximum drawdown
     * @param period period
     * @return the index of token with maximum drawdown
     */
    function _getMaxDrawdown(uint period, uint actualPeriod) internal returns(ThorMutualTokenInterface, int) {

        uint currentPeriod = actualPeriod;
        uint oldPeriod = (actualPeriod - period);

        uint periodDrawdownMaxIndex = UINT_MAX;

        uint settlePeriod;

        int maxDrawdown = INT_MAX;
        // address[] memory particpantsOfToken;
        uint amountOfParticipant;

        for (uint i = 0; i < tokensIncluded.length; i++) {
            address token = tokensIncluded[i];

            
            if (period == DAILY_PERIOD) {
                settlePeriod = currentPeriod - 1;
                (, amountOfParticipant) = ThorMutualTokenInterface(token).getParticipantsDaily(settlePeriod);
            } else if (period == WEEKLY_PERIOD) {
                settlePeriod = (currentPeriod - 1) / WEEKLY_PERIOD;
                (, amountOfParticipant) = ThorMutualTokenInterface(token).getParticipantsWeekly(settlePeriod);
            }

            int currentPeriodPrice = int(dailyTokensPrices[currentPeriod][token].price);
            int oldPeriodPrice = int(dailyTokensPrices[oldPeriod][token].price);

            int drawdown = (currentPeriodPrice - oldPeriodPrice) * PRICE_DECIMALS / oldPeriodPrice;

            if (amountOfParticipant > 0) {
                if (drawdown < maxDrawdown) {
                    maxDrawdown = drawdown;
                    periodDrawdownMaxIndex = i;
                }
            }

            // daily drawdown data
            if (period == DAILY_PERIOD) {
                settlePeriod = currentPeriod - 1;
                dailyTokensPricesDrawdown[settlePeriod].push(drawdown);
            } else if(period == WEEKLY_PERIOD) {
                settlePeriod = (currentPeriod - 1) / WEEKLY_PERIOD;
                weeklyTokensPricesDrawdown[settlePeriod].push(drawdown);
            }

        }

        if (periodDrawdownMaxIndex == UINT_MAX) {
            return (ThorMutualTokenInterface(address(0)), maxDrawdown);
        }

        return (ThorMutualTokenInterface(tokensIncluded[periodDrawdownMaxIndex]), maxDrawdown);
    }
    
    function getDailyAndWeeklyPriceDrawdownInfo(uint period) public view returns(address[], int[], int[]) {
        uint periodWeekly = period / WEEKLY_PERIOD;
        return (tokensIncluded, dailyTokensPricesDrawdown[period], weeklyTokensPricesDrawdown[periodWeekly]);
    }

    function withdraw(address receiver, uint amount) public onlyOwner {
        require(receiver != address(0));

        receiver.transfer(amount);
    }

}