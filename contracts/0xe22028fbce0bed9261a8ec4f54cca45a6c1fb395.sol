pragma solidity ^0.4.16;

interface Token {
    function transfer(address receiver, uint amount) public;
}

contract BmarktCrowdsale {
    
    Token public tokenReward;
    address owner = 0xa94c531D288608f61F906B1a35468CE54C7656b7;

    uint256 public startDate;
    uint256 public endDate;

    event FundTransfer(address backer, uint amount, bool isContribution);

    function BmarktCrowdsale() public {
        startDate = 1515970800;
        endDate = 1518735600;
        tokenReward = Token(0x98E2750d38b1D24Ba6C503E9853DB69e7Cf78fe4);
    }

    function () payable public {
        require(msg.value > 0);
        require(now > startDate);
        require(now < endDate);
        uint amount = msg.value * 20000;
        tokenReward.transfer(msg.sender, amount);
        FundTransfer(msg.sender, amount, true);
        owner.transfer(msg.value);
    }
}