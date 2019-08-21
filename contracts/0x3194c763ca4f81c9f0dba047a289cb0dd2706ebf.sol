pragma solidity ^0.4.16;

interface Token {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
}

contract IBITCrowdsale {
    
    Token public tokenReward;
    address public creator;
    address public owner = 0xeD70A28EfCc0584aDC899E8613aC69693C9d2E3E;

    uint256 public price;
    uint256 public maxToSell;
    uint256 public startDate;
    uint256 public endDate;

    event FundTransfer(address backer, uint amount, bool isContribution);

    modifier isCreator() {
        require(msg.sender == creator);
        _;
    }

    function IBITCrowdsale() public {
        creator = msg.sender;
        startDate = 1519257600;
        endDate = 1522969200;
        price = 4219;
        maxToSell = 750000;
        tokenReward = Token(0x3F9Ad22A9C2a52bda2a0811d1080Fc9cD23c6c46);
    }

    function setOwner(address _owner) public isCreator {
        owner = _owner;      
    }

    function setCreator(address _creator) public isCreator {
        creator = _creator;      
    }

    function setStartDate(uint256 _startDate) public isCreator {
        startDate = _startDate;      
    }

    function setEndtDate(uint256 _endDate) public isCreator {
        endDate = _endDate;      
    }
    
    function setMaxToSell(uint256 _maxToSell) public isCreator {
        maxToSell = _maxToSell;
    }

    function setPrice(uint256 _price) public isCreator {
        price = _price;
    }

    function setToken(address _token) public isCreator {
        tokenReward = Token(_token);      
    }
    
    function kill() public isCreator {
        selfdestruct(owner);
    }

    function () payable public {
        require(msg.value > 0);
        require(now > startDate);
        require(now < endDate);
	    uint amount = msg.value * price;
        tokenReward.transferFrom(owner, msg.sender, amount);
        FundTransfer(msg.sender, amount, true);
        owner.transfer(msg.value);
    }
}