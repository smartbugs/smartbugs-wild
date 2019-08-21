pragma solidity ^0.4.16;

interface Token {
    function transfer(address receiver, uint amount) public;
}

contract JOUL3SCrowdsale {
    
    Token public tokenReward;
    address creator;
    address owner = 0x825C8b603fAcB1144767D5a39C7B6AaA7Aa403f4;

    uint256 public startDate;
    uint256 public endDate;
    uint256 public price;

    event FundTransfer(address backer, uint amount, bool isContribution);

    function JOUL3SCrowdsale() public {
        creator = msg.sender;
        startDate = 1514761200;     // 01/01/2018
        endDate = 1530396000;       // 01/07/2018
        price = 100;
        tokenReward = Token(0x4aae3a2dA70c499797EdF4A4139b68454eC07883);
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

        // period 1 : Early Backers 50%
        if(now > startDate && now < 1522533600) {
            amount += amount / 2;
        }

        // Pperiod 2 : Presale 25%
        if(now > 1522533600 && now < 1525384800) {
            amount += amount / 4;
        }

        // period 3 : Launch 20%
        if(now > 1525384800 && now < 1526076000) {
            amount += amount / 5;
        }
        
        tokenReward.transfer(msg.sender, amount);
        FundTransfer(msg.sender, amount, true);
        owner.transfer(msg.value);
    }
}