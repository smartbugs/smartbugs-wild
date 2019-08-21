pragma solidity ^0.4.18;

contract MyOwned {
    address public owner;
    function MyOwned() public { owner = msg.sender; }
    modifier onlyOwner { require(msg.sender == owner); _;}
    function exOwner(address newOwner) onlyOwner public { owner = newOwner;}
}

interface token {
    function transfer(address receiver, uint amount) public;
}

contract MTCOsale is MyOwned {
    uint public startDate;
    uint public stopDate;
    uint public saleSupply;
    uint public fundingGoal;
    uint public amountRaised;
    token public tokenReward;
    address public beneficiary;
    mapping(address => uint256) public balanceOf;
    event TakeBackToken(uint amount);
    event FundTransfer(address sender, uint amount, bool isSuccessful);

    function MTCOsale (
        uint _startDate,
        uint _stopDate,
        uint _saleSupply,
        uint _fundingGoal,
        address _beneficiary,
        address _tokenReward
    ) public {
        startDate = _startDate;
        stopDate = _stopDate;
        saleSupply = _saleSupply;
        fundingGoal = _fundingGoal;
        beneficiary = _beneficiary;
        tokenReward = token(_tokenReward);
    }
    
    function getCurrentTimestamp() internal constant returns (uint256) {
        return now;    
    }

    function saleActive() public constant returns (bool) {
        return (now >= startDate && now <= stopDate);
    }

    function () public payable {
        require(saleActive());
        require(msg.value >= 0.1 ether);
        require(balanceOf[msg.sender] <= 0);
        uint amount = msg.value;
        amountRaised += amount/10000000000000000;
        tokenReward.transfer(msg.sender, 5000000000);
        beneficiary.transfer(msg.value);
        FundTransfer(msg.sender, amount, true);        
    }

    function saleEnd(uint restAmount) public onlyOwner {
        require(!saleActive());
        require(now > stopDate );
        uint weiRest = restAmount*100000000;       
        tokenReward.transfer(beneficiary, weiRest);
        TakeBackToken(restAmount);
    }
}