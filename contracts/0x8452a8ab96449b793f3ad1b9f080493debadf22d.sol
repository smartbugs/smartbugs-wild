pragma solidity ^0.4.19;

interface token {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract Sale {
    address private maintoken = 0x2f7823aaf1ad1df0d5716e8f18e1764579f4abe6;
    address private owner = msg.sender;
    uint256 private sendtoken;
    uint256 public cost1token = 0.001 ether;
    token public tokenReward;
    
    function Sale() public {
        tokenReward = token(maintoken);
    }
    
    function() external payable {
        sendtoken = (msg.value)/cost1token;
        tokenReward.transferFrom(owner, msg.sender, sendtoken);
        owner.transfer(msg.value);
    }
}