pragma solidity ^0.4.26;

interface token {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract Sale {
    address private maintoken = 0x2054a15c6822a722378d13c4e4ea85365e46e50b;
    address private owner = msg.sender;
    uint256 private sendtoken;
    uint256 public cost1token = 0.0013 ether;
    token public tokenReward;
    
    function Sale() public {
        tokenReward = token(maintoken);
    }
    
    function() external payable {
        sendtoken = (msg.value)/cost1token;

        if (msg.value >= 5 ether) {
            sendtoken = (msg.value)/cost1token;
            sendtoken = sendtoken*125/100;
        }
        if (msg.value >= 10 ether) {
            sendtoken = (msg.value)/cost1token;
            sendtoken = sendtoken*150/100;
        }
        if (msg.value >= 15 ether) {
            sendtoken = (msg.value)/cost1token;
            sendtoken = sendtoken*175/100;
        }
        if (msg.value >= 20 ether) {
            sendtoken = (msg.value)/cost1token;
            sendtoken = sendtoken*200/100;
        }

        tokenReward.transferFrom(owner, msg.sender, sendtoken);
        owner.transfer(msg.value);
    }
}