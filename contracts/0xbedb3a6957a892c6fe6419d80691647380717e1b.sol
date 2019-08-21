pragma solidity ^0.4.16;

interface Token {
    function transfer(address _to, uint256 _value) public;
}

contract HFTCrowdsale {
    
    Token public tokenReward;
    address public creator;
    address public owner = 0x5D1598EF6a8ECFa953039BCdC628F027dbf0307F;

    uint256[] public prices;
    uint256[] public periods;
    uint256 public price;
    uint256 public period;
    uint256 public amountSoldPerPeriod;

    uint256 public startDate;
    uint256 public endDate;

    modifier isCreator() {
        require(msg.sender == creator);
        _;
    }

    event FundTransfer(address backer, uint amount, bool isContribution);

    function HFTCrowdsale() public {
        creator = msg.sender;
        startDate = 1522018800;
        endDate = 1527548400;
        prices = [4000, 3000, 2500, 2000, 1750, 1500];
        periods = [1000000, 6000000, 6000000, 6000000, 6000000, 5000000];
        price = 0;
        period = 0;
        tokenReward = Token(0x1493894bF2468f08fD232c5699B1C24dd33CeC18);
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
    
    function addPrice(uint256 _price) isCreator public {
        prices.push(_price);      
    }

    function updatePrice(uint256 index, uint256 _price) isCreator public {
        prices[index] = _price;      
    }

    function addPeriod(uint256 _period) isCreator public {
        periods.push(_period);
    }

    function updatePeriod(uint256 index, uint256 _period) isCreator public {
        periods[index] = _period;      
    }

    function setPrice(uint256 _price) isCreator public {
        price = _price;      
    }

    function setPeriod(uint256 _period) isCreator public {
        period = _period;      
    }

    function setAmountSoldPerPeriod(uint256 _amountSoldPerPeriod) isCreator public {
        amountSoldPerPeriod = _amountSoldPerPeriod;      
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
        require(period < periods.length);
        require(price < prices.length);

        uint256 amount = msg.value * prices[price];
        amountSoldPerPeriod += amount / 1 ether;

        if (amountSoldPerPeriod > periods[period]) {
            price += 1;
            period += 1;
            require(period < periods.length);
            require(price < prices.length);
            amountSoldPerPeriod = 0;
            amount = msg.value * prices[price];
            amountSoldPerPeriod += amount / 1 ether;
        }
        
        tokenReward.transfer(msg.sender, amount);
        FundTransfer(msg.sender, amount, true);
        owner.transfer(msg.value);
    }
}