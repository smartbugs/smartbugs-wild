pragma solidity ^0.4.19;

interface token {
    function transfer(address receiver, uint amount) public;
    function balanceOf(address _owner) public constant returns (uint balance);
}

contract Crowdsale {
    address public beneficiary = msg.sender;
    uint public price;
    token public tokenReward;
    bool crowdsaleClosed = false;

    event FundTransfer(address indexed backer, uint amount, bool isContribution);

    modifier onlyBy(address _account) { require(msg.sender == _account); _; }


    function Crowdsale(
        uint szaboCostOfEachToken,
        address addressOfTokenUsedAsReward
    ) public {
        price = szaboCostOfEachToken * 1 szabo;
        tokenReward = token(addressOfTokenUsedAsReward);
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () payable public{
        require(!crowdsaleClosed);
        uint amount = msg.value;
        uint tokenAmount = 1 ether * amount / price;
        tokenReward.transfer(msg.sender, tokenAmount);
        FundTransfer(msg.sender, amount, true);
    }

    function endCrowdsale() onlyBy(beneficiary) public{
        crowdsaleClosed = true;
    }

    function withdrawEther() onlyBy(beneficiary) public {
        beneficiary.transfer(this.balance);
    }

    function withdrawTokens() onlyBy(beneficiary) public {
        uint tokenBalance = tokenReward.balanceOf(this);

        tokenReward.transfer(beneficiary, tokenBalance);
    }
}