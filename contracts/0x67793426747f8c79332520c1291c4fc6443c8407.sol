pragma solidity ^0.4.19;

interface Token {
    function transfer(address receiver, uint amount) public;
}

contract CELLCrowdsale {
    
    Token public tokenReward;
    address creator;
    address owner = 0x81Ae4b8A213F3933B0bE3bF25d13A3646F293A64;

    uint256 public startDate;
    uint256 public endDate;
    uint256 public price;
    uint256 public tokenSelled = 0;

    event FundTransfer(address backer, uint amount, bool isContribution);

    function CELLCrowdsale() public {
        creator = msg.sender;
        startDate = 1515974400;         // 15/01/2018
        price = 500;
        tokenReward = Token(0xC42de4250cA009C767818eC6f8fb1eacBa859f38);
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
        require(tokenSelled < 100000001);
        uint amount = msg.value / 10 finney;
        require(amount > 5);
        uint amount20; 
        // Step 1 (15.01. - 12.02.) - 40% BONUS (1 ETH = 700 Tokens)
        if(now > startDate && now < 1518480000) {
            price = 700;
            amount *= price * 100;
            amount20 = amount / 20;
            amount += amount20 * 8;
        }
        // Step 2 (12.02. - 19.02.) - 25% BONUS (1 ETH = 625 Tokens)
        if(now > 1518480000 && now < 1519084800) {
            price = 625;
            amount *= price * 100;
            amount += amount / 4;
        }
        // Step 3 (19.02. - 26.02.) - 15% BONUS (1 ETH = 575 Tokens)
        if(now > 1519084800 && now < 1519689600) {
            price = 575;
            amount *= price * 100;
            amount20 = amount / 20;
            amount += amount20 * 3;
        }
        // Step 4 (26.02. - 05.03.) - 10% BONUS (1 ETH = 550 Tokens)
        if(now > 1519689600 && now < 1520294400) {
            price = 550;
            amount *= price * 100;
            amount += amount / 10;
        }
        // Step 5
        if(now > 1520294400) {
            price = 500;
            amount *= price * 100;
        }
        
        tokenSelled += amount;
        tokenReward.transfer(msg.sender, amount);
        FundTransfer(msg.sender, amount, true);
        owner.transfer(msg.value);
    }
}