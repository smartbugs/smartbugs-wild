pragma solidity ^0.4.13;

interface EtherShare {
    function allShare(uint ShareID, uint ReplyID) returns (address,string,uint,bool,string);
}

// Enable users to reward authors from EtherShare and record the reward
contract EtherShareReward {
    EtherShare ES = EtherShare(0xc86bdf9661c62646194ef29b1b8f5fe226e8c97e);
    
    struct oneReward {
        address from;
        uint value;
    }
    mapping(uint => mapping(uint => oneReward[])) public allRewards;
    
    function Reward(uint ShareID, uint ReplyID) payable public {
        address to;
        (to,,,,) = ES.allShare(ShareID,ReplyID); // get the author
        to.transfer(msg.value);
        allRewards[ShareID][ReplyID].push(oneReward(msg.sender, msg.value)); // record the reward
    }

    function getSum(uint ShareID, uint ReplyID) view public returns (uint) {
        uint sum = 0;
        for (uint i=0; i<allRewards[ShareID][ReplyID].length; ++i)
            sum += allRewards[ShareID][ReplyID][i].value;
        return sum;
    }
}