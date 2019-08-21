pragma solidity ^0.4.0;

// Visit ethersphere.io for more information

contract EtherSphere {
    mapping(address => uint) bidPool;
    address[] public bidders;
    address highestBidder;
    uint bidderArraySize;
    uint public numBidders;
    uint public minBid;
    uint public interval = 1 days;
    uint public rewardPool;
    uint public todaysBidTotal;
    uint public endOfDay;
    uint public previousRoundJackpot;
    uint public highestBid;
    uint public minBidMultiplier = 10;
    //Jackpot triggers when todaysBidTotal > rewardPool * 1.05
    uint public jackpotConditionPercent = 105;
    //Max bid as a proportion of reward pool pre-jackpot. Disabled by default
    uint public maxBidPercent; 
    
    function EtherSphere(){
        etherSphereHost = msg.sender;
        minBid = 0.01 ether;
        rewardPool = 0;
        cost = 0;
        numBidders = 0;
        todaysBidTotal = 0;
        previousRoundJackpot = 0;
        highestBid = 0;
        bidderArraySize = 0;
        maxBidPercent = 100; 
        endOfDay = now + interval;
    }
    
    function inject() ismain payable{
        rewardPool += msg.value;
    }
    
    function addEtherToSphere() private{
        if (msg.value < minBid) throw;
        if (triggerPreJackpotLimit()) throw;
        
        bidPool[msg.sender] += msg.value;
        if (bidPool[msg.sender] > highestBid) {
            highestBid = bidPool[msg.sender];
            highestBidder = msg.sender;
        }
        todaysBidTotal += msg.value;
    }
    
    function triggerPreJackpotLimit() private returns(bool){
        if (maxBidPercent == 100) return false;
        bool willBidExceedPreJackpotLimit = rewardPool * maxBidPercent / 100 < msg.value + bidPool[msg.sender];
        bool willBePostJackpot = (todaysBidTotal + msg.value) >= (rewardPool * jackpotConditionPercent / 100);
        return willBidExceedPreJackpotLimit && !willBePostJackpot;
    }
    
    function () payable{
        if (shouldCompleteDay()) completeDay();
        recordSenderIfNecessary();
        addEtherToSphere();
    }
    
    function recordSenderIfNecessary() private{
       if (bidPool[msg.sender] == 0){
            setMinBid();
            if (msg.value < minBid) throw;
            if (numBidders >= bidderArraySize){
                bidders.push(msg.sender);
                numBidders++;
                bidderArraySize++;
            }
            else {
                bidders[numBidders] = msg.sender;
                numBidders++;
            }
            setMinBid();
        }
    }
    
    function completeDay() private{
        if (doTriggerJackpot()) {
            triggerJackpot();
        }
        else {
            previousRoundJackpot = 0;
        }
        if (numBidders > 0) {
            distributeReward();
            fees();
            endOfDay = endOfDay + interval;
        }
        else {
            endOfDay = endOfDay + interval;
            return;
        }
        uint poolReserved = todaysBidTotal / 20;
        rewardPool = todaysBidTotal - poolReserved;
        cost += poolReserved;
        todaysBidTotal = 0;
        highestBid = 0;
        numBidders = 0;
    }
    
    //Jackpot condition, happens when today's total bids is more than or equals to current pool * condition percent
    function doTriggerJackpot() private constant returns (bool){
        return numBidders > 0 && todaysBidTotal > (rewardPool * jackpotConditionPercent / 100);
    }
    
    //Reward all participants
    function distributeReward() private{
        uint portion = 0;
        uint distributed = 0;
        for (uint i = 0; i < numBidders; i++){
            address bidderAddress = bidders[i];
            if (i < numBidders - 1){
                portion = bidPool[bidderAddress] * rewardPool / todaysBidTotal;
            }
            else {
                portion = rewardPool - distributed;
            }
            distributed += portion;
            bidPool[bidderAddress] = 0;
            sendPortion(portion, bidderAddress);
        }
    }
    
    function triggerJackpot() private{
        uint rewardAmount = rewardPool * 35 / 100;
        rewardPool -= rewardAmount;
        previousRoundJackpot = rewardAmount;
        sendPortion(rewardAmount, highestBidder);
    }
    
    function sendPortion(uint amount, address target) private{
        target.send(amount);
    }
    
    function shouldCompleteDay() private returns (bool){
        return now > endOfDay;
    }
    
    function containsSender() private constant returns (bool){
        for (uint i = 0; i < numBidders; i++){
            if (bidders[i] == msg.sender)
                return true;
        }
        return false; 
    }
    
    //Change minimum bids as more bidders enter. minBidMultiplier default = 10
    function setMinBid() private{
        uint bid = 0.001 ether;
        if (numBidders > 5){
            bid = 0.01 ether;
            if (numBidders > 50){
                bid = 0.02 ether;
                if (numBidders > 100){
                    bid = 0.05 ether;
                    if (numBidders > 150){
                        bid = 0.1 ether;
                        if (numBidders > 200){
                            bid = 0.5 ether;
                            if (numBidders > 250){
                                bid = 2.5 ether;
                                if (numBidders > 300){
                                    bid = 5 ether;
                                    if (numBidders > 350){
                                        bid = 10 ether;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        minBid = minBidMultiplier * bid;
    }
    
    //administrative functionalities
    address etherSphereHost;
    uint cost;
    
    //In case we run out of gas
    function manualEndDay() ismain payable{
        if (shouldCompleteDay()) completeDay();
    }
    //Change bid multiplier to manage volume
    function changeMinBidMultiplier(uint bidMultiplier) ismain payable{
        minBidMultiplier = bidMultiplier;
    }
    
    //Change prejackpot cap to prevent game rigging
    function changePreJackpotBidLimit(uint bidLimit) ismain payable{
        if (bidLimit == 0) throw;
        maxBidPercent = bidLimit;
    }
    
    modifier ismain() {
        if (msg.sender != etherSphereHost) throw;
        _;
    }
    
    //Clear fees to EtherSphereHost
    function fees() private {
        if (cost == 0) return;
        etherSphereHost.send(cost);
        cost = 0;
    }
    
    //Manual claim
    function _fees() ismain payable{
        fees();
    }
    
    function end() ismain payable{
        //Allow for termination if game is inactive for more than 7 days
        if (now > endOfDay + 7 * interval && msg.sender == etherSphereHost)
            suicide(etherSphereHost);
    }
}