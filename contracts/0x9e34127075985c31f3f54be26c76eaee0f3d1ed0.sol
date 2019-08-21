pragma solidity ^0.4.16;

interface Token {
    function transfer(address _to, uint256 _value) external;
}

contract ETXCrowdsale {
    
    Token public tokenReward;
    address public creator;
    address public owner = 0xC745dA5e0CC68E6Ba91429Ec0F467939f4005Db6;

    uint256 private tokenSold;

    modifier isCreator() {
        require(msg.sender == creator);
        _;
    }

    event FundTransfer(address backer, uint amount, bool isContribution);

    function ETXCrowdsale() public {
        creator = msg.sender;
        tokenReward = Token(0x4CFB59BDfB47396e1720F7fF1C1e37071d927112);
    }

    function setOwner(address _owner) isCreator public {
        owner = _owner;      
    }

    function setCreator(address _creator) isCreator public {
        creator = _creator;      
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
        uint256 amount;
        
        // period 1
        if (now > 1519862400 && now < 1522018800 && tokenSold < 2100001) {
            amount = msg.value * 600;
        }

        // period 2
        if (now > 1522537200 && now < 1524697200 && tokenSold < 6300001) {
            amount = msg.value * 500;
        }

        // period 3
        if (now > 1525129200 && now < 1527721200 && tokenSold < 12600001) {
            amount = msg.value * 400;
        }

        tokenSold += amount / 1 ether;
        tokenReward.transfer(msg.sender, amount);
        FundTransfer(msg.sender, amount, true);
        owner.transfer(msg.value);
    }
}