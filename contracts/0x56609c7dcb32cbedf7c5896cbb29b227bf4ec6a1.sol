pragma solidity ^0.4.16;

interface Token {
    function transfer(address _to, uint256 _value) public;
}

contract EFTCrowdsale {
    
    Token public tokenReward;
    address public creator;
    address public owner = 0x515C1c5bA34880Bc00937B4a483E026b0956B364;

    uint256 public price;
    uint256 public startDate;
    uint256 public endDate;

    modifier isCreator() {
        require(msg.sender == creator);
        _;
    }

    event FundTransfer(address backer, uint amount, bool isContribution);

    function EFTCrowdsale() public {
        creator = msg.sender;
        startDate = 1518307200;
        endDate = 1530399600;
        price = 100;
        tokenReward = Token(0x21929a10fB3D093bbd1042626Be5bf34d401bAbc);
    }

    function setOwner(address _owner) isCreator public {
        owner = _owner;      
    }

    function setCreator(address _creator) isCreator public {
        creator = _creator;      
    }

    function setStartDate(uint256 _startDate) isCreator public {
        startDate = _startDate;      
    }

    function setEndtDate(uint256 _endDate) isCreator public {
        endDate = _endDate;      
    }
    
    function setPrice(uint256 _price) isCreator public {
        price = _price;      
    }

    function setToken(address _token) isCreator public {
        tokenReward = Token(_token);      
    }

    function sendToken(address _to, uint256 _value) isCreator public {
        tokenReward.transfer(_to, _value);      
    }

    function kill() isCreator public {
        selfdestruct(owner);
    }

    function () payable public {
        require(msg.value > 0);
        require(now > startDate);
        require(now < endDate);
	    uint amount = msg.value * price;
        uint _amount = amount / 5;

        // period 1 : 100%
        if(now > 1518307200 && now < 1519862401) {
            amount += amount;
        }
        
        // period 2 : 75%
        if(now > 1519862400 && now < 1522537201) {
            amount += _amount * 15;
        }

        // Pperiod 3 : 50%
        if(now > 1522537200 && now < 1525129201) {
            amount += _amount * 10;
        }

        // Pperiod 4 : 25%
        if(now > 1525129200 && now < 1527807601) { 
            amount += _amount * 5;
        }

        // Pperiod 5 : 10%
        if(now > 1527807600 && now < 1530399600) {
            amount += _amount * 2;
        }

        tokenReward.transfer(msg.sender, amount);
        FundTransfer(msg.sender, amount, true);
        owner.transfer(msg.value);
    }
}