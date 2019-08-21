pragma solidity ^0.4.18;

contract myOwned {
    address public contractOwner;
    function myOwned() public { contractOwner = msg.sender; }
    modifier onlyOwner { require(msg.sender == contractOwner); _;}
    function exOwner(address newOwner) onlyOwner public { contractOwner = newOwner;}
}

interface token {
    function transfer(address receiver, uint amount) public;
}

contract EPOsale is myOwned {
    uint public startDate;
    uint public stopDate;
    uint public saleSupply;
    uint public fundingGoal;
    uint public amountRaised;
    token public contractTokenReward;
    address public contractWallet;
    mapping(address => uint256) public balanceOf;
    event TakeBackToken(uint amount);
    event FundTransfer(address backer, uint amount, bool isContribution);

    function EPOsale (
        uint _startDate,
        uint _stopDate,
        uint _saleSupply,
        uint _fundingGoal,
        address _contractWallet,
        address _contractTokenReward
    ) public {
        startDate = _startDate;
        stopDate = _stopDate;
        saleSupply = _saleSupply;
        fundingGoal = _fundingGoal;
        contractWallet = _contractWallet;
        contractTokenReward = token(_contractTokenReward);
    }
    
    function getCurrentTimestamp () internal constant returns (uint256) {
        return now;
    }

    function saleActive() public constant returns (bool) {
        return (now >= startDate && now <= stopDate);
    }

    function getRateAt(uint256 at) public constant returns (uint256) {
        if (at < startDate) {return 0;} 
        else if (at < (startDate + 168 hours)) {return 3000;} 
        else if (at < (startDate + 336 hours)) {return 2750;} 
        else if (at < (startDate + 504 hours)) {return 2625;} 
        else if (at <= stopDate) {return 2500;} 
        else if (at > stopDate) {return 0;}
    }

    function getRateNow() public constant returns (uint256) {
        return getRateAt(now);
    }

    function () public payable {
        require(saleActive());
        require(msg.value >= 0.05 ether);
        uint amount = msg.value;
        amountRaised += amount/10000000000000000;
        uint price = 0.00000001 ether/getRateAt(now);
        contractTokenReward.transfer(msg.sender, amount/price);
        contractWallet.transfer(msg.value);
        FundTransfer(msg.sender, amount, true);
    }

    function saleEnd(uint restAmount) public onlyOwner {
        require(!saleActive());
        require(now > stopDate );
        contractTokenReward.transfer(contractWallet, restAmount);
        TakeBackToken(restAmount);
    }
}