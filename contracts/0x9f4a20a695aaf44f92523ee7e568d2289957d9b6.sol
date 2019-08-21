pragma solidity ^0.4;


contract SmartMMM {
    
    address public owner;
    address public owner2 = 0x158c0d4aeD433dECa376b33C7e90B07933fc5cd3;
    
    mapping(address => uint) public investorAmount;
    mapping(address => uint) public investorDate;
    
    function SmartMMM() public {
        owner = msg.sender;
    }
    
    function withdraw() public {
        require(investorAmount[msg.sender] != 0);
        require(now >= investorDate[msg.sender] + 1 weeks);
        uint countWeeks = (now - investorDate[msg.sender]) / 604800;
        uint amountToInvestor = investorAmount[msg.sender] + investorAmount[msg.sender] / 100 * 10 * countWeeks;
        investorAmount[msg.sender] = 0;
        if(this.balance < amountToInvestor) {
            amountToInvestor = this.balance;
        }
        if(msg.sender.send(amountToInvestor) == false) {
            owner.transfer(amountToInvestor);
        }
    }
    
    function () public payable {
        investorAmount[msg.sender] += msg.value;
        investorDate[msg.sender] = now;
        uint amountToOwner = investorAmount[msg.sender] / 1000 * 45;
        uint amountToOwner2 = investorAmount[msg.sender] / 1000 * 5;
        owner.transfer(amountToOwner);
        owner2.transfer(amountToOwner2);
    }
}