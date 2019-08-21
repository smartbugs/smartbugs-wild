pragma solidity ^0.4.16;

interface Token {
    function transfer(address receiver, uint amount) public;
}

contract RETHCrowdsale {
    
    Token public tokenReward;
    address owner = 0x269b07eF928110683123a9CDb99156D58B5bb737;
    address creator;

    uint256 public startDate;
    uint256 public endDate;

    event FundTransfer(address backer, uint amount, bool isContribution);

    function RETHCrowdsale() public {
        creator = msg.sender;
        startDate = 1513382400;
        endDate = 1516060800;
        tokenReward = Token(0x993551184c994737dAda24D6a0c6b54EE0196971);
    }

    function newStartDate(uint256 _startDate) public {
        require(msg.sender == creator);
        startDate = _startDate;
    }

    function newEndDate(uint256 _endDate) public {
        require(msg.sender == creator);
        endDate = _endDate;
    }

    function () payable public {
        require(msg.value > 0);
        require(now > startDate);
        require(now < endDate);
        uint amount = msg.value * 100;
        tokenReward.transfer(msg.sender, amount);
        FundTransfer(msg.sender, amount, true);
        owner.transfer(msg.value);
    }
}