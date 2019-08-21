pragma solidity ^0.4.18;

interface token {
    function transfer(address receiver, uint amount) public;
}

contract Crowdsale {
    address public owner;
    uint public amountRaised;
    uint public deadline;
    uint public rateOfEther;
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool crowdsaleClosed = false;

    event FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function Crowdsale(
        uint durationInMinutes,
        address addressOfTokenUsedAsReward
    ) public {
        owner = msg.sender;
        deadline = now + durationInMinutes * 1 minutes;
        rateOfEther = 42352;
        tokenReward = token(addressOfTokenUsedAsReward);
    }

function setPrice(uint tokenRateOfEachEther) public {
    if(msg.sender == owner) {
      rateOfEther = tokenRateOfEachEther;
    }
}

function changeOwner (address newOwner) public {
  if(msg.sender == owner) {
    owner = newOwner;
  }
}

function changeCrowdsale(bool isClose) public {
    if(msg.sender == owner) {
        crowdsaleClosed = isClose;
    }
}


  function finishPresale(uint value) public {
    if(msg.sender == owner) {
        if(owner.send(value)) {
            FundTransfer(owner, value, false);
        }
    }
  }

    function buyToken() payable public {
        require(!crowdsaleClosed);
        require(now <= deadline);
        uint amount = msg.value;
        amountRaised += amount;
        uint tokens = amount * rateOfEther;
        balanceOf[msg.sender] += tokens;
        tokenReward.transfer(msg.sender, tokens);
        FundTransfer(msg.sender, tokens, true);
    }
    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function () payable public {
        buyToken();
    }
}