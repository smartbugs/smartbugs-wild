pragma solidity ^0.4.16;

interface Token {
    function transfer(address receiver, uint amount) public;
}

contract ASCCrowdsale {
    
    Token public tokenReward;
    address creator;
    address owner = 0xb99776950E24a1D580d8c1622ab6C92002aEc169;

    uint256 public startDate;
    uint256 public endDate;
    uint256 public price;

    event FundTransfer(address backer, uint amount, bool isContribution);

    function ASCCrowdsale() public {
        creator = msg.sender;
        startDate = 1452038400;     // 06/01/2018
        endDate = 1521586800;       // 21/03/2018
        price = 72000;
        tokenReward = Token(0xE5b7301D818299487b744900923A40cF7d1f0242);
    }

    function setOwner(address _owner) public {
        require(msg.sender == creator);
        owner = _owner;      
    }

    function setCreator(address _creator) public {
        require(msg.sender == creator);
        creator = _creator;      
    }    

    function setStartDate(uint256 _startDate) public {
        require(msg.sender == creator);
        startDate = _startDate;      
    }

    function setEndDate(uint256 _endDate) public {
        require(msg.sender == creator);
        endDate = _endDate;      
    }

    function setPrice(uint256 _price) public {
        require(msg.sender == creator);
        price = _price;      
    }

    function sendToken(address receiver, uint amount) public {
        require(msg.sender == creator);
        tokenReward.transfer(receiver, amount);
        FundTransfer(receiver, amount, true);    
    }

    function () payable public {
        require(msg.value > 0);
        require(now > startDate);
        require(now < endDate);
        uint amount = msg.value * price;
        uint amount10 = amount / 10;

        // period 1 : 60%
        if(now > startDate && now < 1516230000) {
            amount += amount10 * 6;
        }

        // Pperiod 2 : 40%
        if(now > 1516230000 && now < 1517439600) {
            amount += amount10 * 4;
        }

        // period 3 : 20%
        if(now > 1517439600 && now < 1518649200) {
            amount += amount10 * 2;
        }

        // period 4 : 10%
        if(now > 1518649200 && now < 1519858800) {
            amount += amount10;
        }

        tokenReward.transfer(msg.sender, amount);
        FundTransfer(msg.sender, amount, true);
        owner.transfer(msg.value);
    }
}