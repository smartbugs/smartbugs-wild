pragma solidity ^0.4.16;

interface Token {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract LVRCrowdsale {
    
    Token public tokenReward;
    address public creator;
    address public owner = 0xC9167F51CDEa635634E6d92D25664379dde36484;

    uint256 public price;
    uint256 public startDate;
    uint256 public endDate;

    event FundTransfer(address backer, uint amount, bool isContribution);

    function LVRCrowdsale() public {
        creator = msg.sender;
        startDate = 1522839600;
        endDate = 1525431600;
        price = 1000;
        tokenReward = Token(0x7095E151aBD19e8C99abdfB4568F675f747f97F6);
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
    
    function setPrice(uint256 _price) public {
        require(msg.sender == creator);
        price = _price;      
    }

    function setToken(address _token) public {
        require(msg.sender == creator);
        tokenReward = Token(_token);      
    }
    
    function kill() public {
        require(msg.sender == creator);
        selfdestruct(owner);
    }

    function () payable public {
        require(msg.value > 0);
        require(now > startDate);
        require(now < endDate);
	    uint amount = msg.value * price;
        uint _amount = amount / 20;
        
        // period 1 : 30%
        if(now > 1522839600 && now < 1523098800) {
            amount += _amount * 6;
        }
        
        // period 2 : 20%
        if(now > 1523098800 && now < 1523703600) {
            amount += _amount * 4;
        }

        // period 3 : 10%
        if(now > 1523703600 && now < 1524913200) {
            amount += _amount * 2;
        }

        tokenReward.transferFrom(owner, msg.sender, amount);
        FundTransfer(msg.sender, amount, true);
        owner.transfer(msg.value);
    }
}