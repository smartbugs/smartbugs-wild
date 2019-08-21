pragma solidity ^0.4.25;

interface token {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract Sale {
    address private maintoken = 0x1ad1b64f47a9c25cdceff021e5fd124a856ba1b1;
    address private owner = msg.sender;
    uint256 private sendtoken;
    uint256 private cost1token;
    token public tokenReward;
    
    function Sale() public {
        tokenReward = token(maintoken);
    }
    
    function() external payable {
        cost1token = 0.0000056 ether;
        
        if ( now > 1547586000 ) {
            cost1token = 0.0000195 ether;
        }

        if ( now > 1556226000 ) {
            cost1token = 0.000028 ether;
        }
        
        sendtoken = (msg.value)/cost1token;
        tokenReward.transferFrom(owner, msg.sender, sendtoken);
        owner.transfer(msg.value);
    }
}