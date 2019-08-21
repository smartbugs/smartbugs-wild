pragma solidity ^0.4.16;

interface Token {
    function transfer(address receiver, uint amount) public;
}

contract WEACrowdsale {
    
    Token public token;
    address creator;
    address owner = 0x0;

    uint256 public startDate;
    uint256 public endDate;
    uint256 public price;
    
    bool active = false;

    event FundTransfer(address backer, uint amount, bool isContribution);

    function WEACrowdsale() public {
        creator = msg.sender;
        startDate = 1515970800;     // 15/01/2018
        endDate = 1518735600;       // 15/02/2018
        price = 30;
        token = Token(0x4916f730A7B60C56Bcfc8B79Dd29bA1c0f244228);
        active = true;
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

    function setToken(address _address) public {
        require(msg.sender == creator);
        token = Token(_address);      
    }

    function sendToken(address receiver, uint amount) public {
        require(msg.sender == creator);
        token.transfer(receiver, amount);
        FundTransfer(receiver, amount, true);    
    }

    function start() public {
        require(msg.sender == creator);
        active = true;      
    }
    
    function stop() public {
        require(msg.sender == creator);
        active = false;      
    }

    function () payable public {
        require(active);
        require(msg.value > 0);
        require(now > startDate);
        require(now < endDate);
        uint amount = msg.value * price;
        amount = amount / 1 ether;
        require(amount > 0);
        token.transfer(msg.sender, amount);
        FundTransfer(msg.sender, amount, true);
        owner.transfer(msg.value);
    }
}