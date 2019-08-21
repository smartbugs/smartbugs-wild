pragma solidity ^0.4.25;

interface token {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract Partner {
    address private maintoken = 0x1ad1b64f47a9c25cdceff021e5fd124a856ba1b1;
    address private owner = 0xA07eAaac653e2502139Ad23E69b9348CB235C2BC;
    address private partner = 0xef189f9182ed3f78903b17144994f389dc4ab24c;
    uint256 private sendtoken;
    uint256 public cost1token;
    uint256 private ether60;
    uint256 private ether40;
    token public tokenReward;
    
    function Partner() public {
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
        
        ether40 = (msg.value)*40/100;
        ether60 = (msg.value)-ether40;
        owner.transfer(ether60);
        partner.transfer(ether40);
    }
}