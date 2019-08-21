pragma solidity ^0.4.24;

interface Token {
    function transfer(address _to, uint256 _value) external;
}

contract BNCXCrowdsale {
    
    Token public tokenReward;
    address public creator;
    address public owner = 0x516A2F56A6a8f9A34AbF86C877d0252dC94AAA69;

    uint256 public startDate;
    uint256 public endDate;

    event FundTransfer(address backer, uint amount);

    constructor() public {
        creator = msg.sender;
        startDate = 1544832000;
        endDate = 1521331200;
        tokenReward = Token(0x5129bdfF6B065ce57cC7E7349bA681a0aC1D00cd);
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

    function setEndtDate(uint256 _endDate) public {
        require(msg.sender == creator);
        endDate = _endDate;      
    }

    function setToken(address _token) public {
        require(msg.sender == creator);
        tokenReward = Token(_token);      
    }
    
    function sendToken(address _to, uint256 _value) public {
        require(msg.sender == creator);
        tokenReward.transfer(_to, _value);      
    }
    
    function kill() public {
        require(msg.sender == creator);
        selfdestruct(owner);
    }

    function () payable public {
        require(msg.value > 0);
        require(now > startDate);
        require(now < endDate);
        uint256 amount = msg.value / 10000000000;
        
        // Stage 1
        if(now > startDate && now < 1516060800) {
            amount = msg.value * 625;
        }
        
        // Stage 2
        if(now > 1516060800 && now < 1518825600) {
            amount = msg.value * 235;
        }
        
        // Stage 3
        if(now > 1518825600 && now < endDate) {
            amount = msg.value * 118;
        }
        
        tokenReward.transfer(msg.sender, amount);
        emit FundTransfer(msg.sender, amount);
        owner.transfer(msg.value);
    }
}