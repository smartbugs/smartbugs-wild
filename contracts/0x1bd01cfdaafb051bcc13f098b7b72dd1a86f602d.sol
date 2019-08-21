pragma solidity ^0.4.24;

contract Robocalls  {
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {}
}

contract RobocallsTokenSale  {
    address public owner;
    uint   public startDate;
    uint   public bonusEnds;
    uint   public endDate;
    address public main_addr;
    Robocalls r;
    
    
    constructor() public {
        owner = msg.sender;
        bonusEnds = now + 8 weeks;
        endDate = now + 8 weeks;
        startDate = now;
        main_addr = 0xAD7615B0524849918AEe77e6c2285Dd7e8468650;
        r = Robocalls(main_addr);
    }
    
    
    function setEndDate(uint _newEndDate ) public {
        require(msg.sender==owner);
        endDate =  _newEndDate;
    } 
    
    function setBonusEndDate(uint _newBonusEndDate ) public {
        require(msg.sender==owner);
        bonusEnds =  _newBonusEndDate;
    } 
    
    // ------------------------------------------------------------------------
    // CrowdSale Function 10,000,000 RCALLS Tokens per 1 ETH
    // ------------------------------------------------------------------------
    function () public payable {
        require(now >= startDate && now <= endDate);
        uint tokens;
        if (now <= bonusEnds) {
            tokens = msg.value * 13000000;
        } else {
            tokens = msg.value * 10000000;
        }
        r.transferFrom(owner,msg.sender, tokens);
        owner.transfer(msg.value);
    }

}