pragma solidity ^0.4.16;

interface token {
  function transfer(address receiver, uint amount);
  function balanceOf(address _owner) constant returns (uint256 balance);
  function burn(uint256 _value) public returns (bool success);
}

contract WHAPRESALEICO {
  address public beneficiary = 0x3aDbBe8DDe40A949dF54F2F5700b9D2Eb2cF1Bbb;
  uint public fundingGoal;
  uint public tokensForOneEth = 7000;
  uint public amountRaised;
  uint public icoEndTime;
  uint public bonusEndTime;
  uint public bonusPercentage = 20;
  token public tokenReward;
  uint256 public unsoldTokens;
  bool public fundingGoalReached = false;
  bool public preIcoOpen = false;
  mapping(address => uint256) public balanceOf;

  event GoalReached(address _beneficiary, uint _amountRaised);
  event FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constrctor function
     *
     * Setup the owner
     */
     function WHAPRESALEICO() {
      fundingGoal = 1400 * 1 ether;
      bonusEndTime = now + 1910 * 1 minutes;
      icoEndTime = now + 12770 * 1 minutes;
      tokenReward = token(0x3d8945DcfC11627a6a762F203bE3B1B14Db36C4C);
    }

    function safeMul(uint a, uint b) internal returns (uint) {
      uint c = a * b;
      assert(a == 0 || c / a == b);
      return c;
    }

    function safeDiv(uint a, uint b) internal returns (uint) {
      assert(b > 0);
      uint c = a / b;
      assert(a == b * c + a % b);
      return c;
    }
    
    function safeSub(uint a, uint b) internal returns (uint) {
      assert(b <= a);
      return a - b;
    }

    function safeAdd(uint a, uint b) internal returns (uint) {
      uint c = a + b;
      assert(c >= a);
      return c;
    }

    function () payable {
      require(now<icoEndTime); 
      require(preIcoOpen); 
      require(msg.value > 0);

      uint amount = msg.value;
      balanceOf[msg.sender] += amount;
      amountRaised += amount;
      if (now >= bonusEndTime) {
        uint tokens = safeMul(msg.value, tokensForOneEth);
      } else 
      {
        uint tokenswobonus = safeMul(msg.value, tokensForOneEth);
        uint bonusamount = safeMul(safeDiv(tokenswobonus,100), bonusPercentage);
        tokens = safeAdd(tokenswobonus,bonusamount);
      }

      tokenReward.transfer(msg.sender, tokens);
      FundTransfer(msg.sender, amount, true);
      unsoldTokens = tokenReward.balanceOf(address(this));
    }

    modifier aftericoEndTime() { if (now >= icoEndTime) _; }


    function checkGoalReached() aftericoEndTime {
      if (amountRaised >= fundingGoal){
        fundingGoalReached = true;
        GoalReached(beneficiary, amountRaised);
      }
      preIcoOpen = false;
    }

    function pausePreIco() {
      require(preIcoOpen); 
      require(beneficiary == msg.sender);
      preIcoOpen = false;
    }

    function reStartPreIco() {
      require(!preIcoOpen); 
      require(beneficiary == msg.sender);
      preIcoOpen = true;
    }

    function changeBonusPercentage(uint newBonusPercentage) {
     require(beneficiary == msg.sender);
     require(newBonusPercentage > 0);
     require(newBonusPercentage <= 50);
     bonusPercentage = newBonusPercentage;
   }

   function prolongPreIco(uint addMinutes) {
     require(beneficiary == msg.sender);
     icoEndTime = icoEndTime + addMinutes * 1 minutes;   
   }

   function shortenPreIco(uint removeMinutes) {
     require(beneficiary == msg.sender);
     require((icoEndTime - removeMinutes * 1 minutes)>now);
     require((icoEndTime - removeMinutes * 1 minutes)>bonusEndTime);
     icoEndTime = icoEndTime - removeMinutes * 1 minutes;   
   }

   function prolongBonusPreIco(uint addMinutes) {
    require(beneficiary == msg.sender);
    require((bonusEndTime + addMinutes * 1 minutes) <= icoEndTime);
    bonusEndTime = bonusEndTime + addMinutes * 1 minutes;
  }
  function shortenBonusPreIco(uint removeMinutes) {
    require(beneficiary == msg.sender);
    require((icoEndTime - removeMinutes * 1 minutes)>now);
    require((bonusEndTime - removeMinutes * 1 minutes) <= icoEndTime);
    bonusEndTime = bonusEndTime - removeMinutes * 1 minutes;
  }

  function burnAllLeftTokens() aftericoEndTime {
    require(beneficiary == msg.sender);
    unsoldTokens = tokenReward.balanceOf(address(this));
    tokenReward.burn(unsoldTokens);
  }

  function updateUnsoldTokens() {
    unsoldTokens = tokenReward.balanceOf(address(this));
  }

  function Withdrawal() {
    require(beneficiary == msg.sender);
    if (beneficiary.send(amountRaised)) {
      FundTransfer(beneficiary, amountRaised, false);
    }
  }
}