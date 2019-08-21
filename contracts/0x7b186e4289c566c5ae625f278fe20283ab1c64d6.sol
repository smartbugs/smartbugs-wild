pragma solidity ^0.4.16;

interface Token {
    function transfer(address _to, uint256 _value) external;
}

contract TPCCrowdsale {
    
    Token public tokenReward;
    address public creator;
    address public owner = 0x1a7416F68b0e7D917Baa86010BD8FF2B0e5C12a0;

    uint256 public startDate;

    modifier isCreator() {
        require(msg.sender == creator);
        _;
    }

    event FundTransfer(address backer, uint amount, bool isContribution);

    function TPCCrowdsale() public {
        creator = msg.sender;
        startDate = now;
        tokenReward = Token(0x414B23B9deb0dA531384c5Db2ac5a99eE2e07a57);
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
        uint256 amount;
        uint256 _amount;
        
        // Pre-sale period
        if (now > startDate && now < 1519862400) {
            amount = msg.value * 12477;
            _amount = amount / 5;
            amount += _amount * 3;
        }

        // Spring period
        if (now > 1519862399 && now < 1527807600) {
            amount = msg.value * 12477;
            _amount = amount / 5;
            amount += _amount * 2;
        }

        // Summer period
        if (now > 1527807599 && now < 1535756400) {
            amount = msg.value * 6238;
            _amount = amount / 10;
            amount += _amount * 3;
        }

        // Autumn period
        if (now > 1535756399 && now < 1543622400) {
            amount = msg.value * 3119;
            _amount = amount / 5;
            amount += _amount;
        }

        // Winter period
        if (now > 1543622399 && now < 1551398400) {
            amount = msg.value * 1559;
            _amount = amount / 10;
            amount += _amount;
        }
        
        // 1-10 ETH
        if (msg.value >= 1 ether && msg.value < 10 ether) {
            _amount = amount / 10;
            amount += _amount * 3;
        }

        // 10 ETH
        if (msg.value >= 10 ether) {
            amount += amount / 2;
        }

        tokenReward.transfer(msg.sender, amount);
        FundTransfer(msg.sender, amount, true);
        owner.transfer(msg.value);
    }
}