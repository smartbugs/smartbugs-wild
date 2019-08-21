pragma solidity ^0.4.10;

contract Metronome {

    // This is the constructor whose code is
    // run only when the contract is created.
    function Metronome() {
    }
    
    
    // total amount invested
    uint public invested = 0;
    
    // stores the last ping of every participants
    mapping (address => uint) public lastPing;
    // stores the balance of each participant
    mapping (address => uint) public balanceOf;
    // stores the value of rewards the last time a player collected rewards
    mapping (address => uint) public lastRewards;

    uint public constant largeConstant = 1000000 ether;
    // cumulative ratio of rewards over invested (multiplied by largeConstant)
    uint public cumulativeRatios = 0;
    
    // this array is not used in the rules of the game
    // it enables players to check the state of other players more easily
    mapping (uint => address) public participants;
    uint public countParticipants = 0;
    
    
    /** Private and Constant functions */
    
    // adds a player to the array of participants
    function addPlayer(address a) private {
        if (lastPing[a] == 0) {
            participants[countParticipants] = a;
            countParticipants = countParticipants + 1;
        }
        lastPing[a] = now;
    }
    
    
    // updates the balance and updates the total invested amount
    function modifyBalance(address a, uint x) private {
        balanceOf[a] = balanceOf[a] + x;
        invested = invested + x;
    }
    
    // creates a new reward that can be claimed by users
    function createReward(uint value, uint oldTotal) private {
        if (oldTotal > 0)
            cumulativeRatios = cumulativeRatios + (value * largeConstant) / oldTotal;
    }
    
    // function called to forbid a player from claiming all past rewards
    function forbid(address a) private {
        lastRewards[a] = cumulativeRatios;
    }
    
    // function to compute the next reward of a player
    function getReward(address a) constant returns (uint) {
        uint rewardsDifference = cumulativeRatios - lastRewards[a];
        return (rewardsDifference * balanceOf[a]) / largeConstant;
    }
    
    // function to compute the lost amount
    function losingAmount(address a, uint toShare) constant returns (uint) {
        return toShare - (((toShare*largeConstant)/invested)*balanceOf[a]) / largeConstant;
    }
    
    /** Public functions */
    
    // to be called every day
    function idle() {
        lastPing[msg.sender] = now;
    }
    
    // function called when a user wants to invest in the contract
    // after calling this function you cannot claim past rewards
    function invest() payable {
        uint reward = getReward(msg.sender);
        addPlayer(msg.sender);
        modifyBalance(msg.sender, msg.value);
        forbid(msg.sender);
        createReward(reward, invested);
    }
    
    // function called when a user wants to divest
    function divest(uint256 value) {
        require(value <= balanceOf[msg.sender]);
        
        uint reward = getReward(msg.sender);
        modifyBalance(msg.sender, -value);
        forbid(msg.sender);
        createReward(reward, invested);
        msg.sender.transfer(value);
    }
    
    // claims the rewards
    function claimRewards() {
        uint reward = getReward(msg.sender);
        modifyBalance(msg.sender,reward);
        forbid(msg.sender);
    }
    
    // used to take create a reward from the funds of someone who has not
    // idled in the last 10 minutes
    function poke(address a) {
        require(now > lastPing[a] + 14 hours && balanceOf[a] > 0);
        
        uint missed = getReward(a);
        uint toShare = balanceOf[a] / 10;
        uint toLose = losingAmount(a, toShare);
        
        createReward(toShare, invested);
        modifyBalance(a, -toLose);
        forbid(a);
        lastPing[a] = now;
        createReward(missed, invested);
    }
}