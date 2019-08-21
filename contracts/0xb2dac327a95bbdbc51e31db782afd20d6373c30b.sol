pragma solidity ^0.4.16;

interface Token {
    function transfer(address _to, uint256 _value) public;
}

contract BXXCrowdsale {
    
    Token public tokenReward;
    address public creator;
    address public owner = 0x54aEe5794e0e012775D9E3E86Eb6a7edf0e0380F;

    uint256 public price;
    uint256 public startDate;
    uint256 public endDate;

    modifier isCreator() {
        require(msg.sender == creator);
        _;
    }

    event FundTransfer(address backer, uint amount, bool isContribution);

    function BXXCrowdsale() public {
        creator = msg.sender;
        startDate = 1518393600;
        endDate = 1523142000;
        price = 5000;
        tokenReward = Token(0x53562419E435cBAe65d73E7EAe2723A43E6cd887);
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

    function () payable public {
        require(msg.value > 0);
        require(now > startDate);
        require(now < endDate);
	    uint amount = msg.value * price;
        tokenReward.transfer(msg.sender, amount);
        FundTransfer(msg.sender, amount, true);
        owner.transfer(msg.value);
    }
}