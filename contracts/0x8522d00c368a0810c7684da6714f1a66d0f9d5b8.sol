pragma solidity ^0.4.16;

interface Token {
    function transfer(address receiver, uint amount) public;
}

contract KaiserExTokenCrowdsale {
    
    Token public tokenReward;
    address ICOowner = 0x60Bb29928F16D1295731A1B72516892D33b1e8df;

    uint256 public startDate;
    uint256 public endPresaleDate;
    uint256 public endDate;

    uint256 public presaleAmount;

    event FundTransfer(address backer, uint amount, bool isContribution);

    function KaiserExTokenCrowdsale() public {
        startDate = 1513209600;  // 14/12/2017 GMT
        endPresaleDate = startDate + 8 days;
        endDate = endPresaleDate + 30 days;
        tokenReward = Token(0xA9931dEf75784C50e27506d9acC4c58611bd5103);
        presaleAmount = 12000000 * 1 ether;
    }

    function () payable public {
        require(msg.value > 0);
        require(now > startDate);
        require(now < endDate);
        uint amount = msg.value * 1000;
        if(now < endPresaleDate) {
        	amount = msg.value * 1200;
        	require(presaleAmount >= amount);
        	presaleAmount -= amount;
        }
        require(amount >= 5 * 1 ether);
        tokenReward.transfer(msg.sender, amount);
        FundTransfer(msg.sender, amount, true);
        ICOowner.transfer(msg.value);
    }
}