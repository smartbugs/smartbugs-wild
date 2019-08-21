pragma solidity ^0.4.18;
// **-----------------------------------------------
// MoyToken Open Distribution Smart Contract.
// 30,000,000 tokens available via unique Open Distribution. 
// POWTokens Contract @ POWToken.eth
// Open Dsitribution Opens at the 1st Block of 2018.
// All operations can be monitored at etherscan.io

// -----------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/issues/20
// -------------------------------------------------

contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }
}

contract safeMath {
  function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    safeAssert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
    safeAssert(b > 0);
    uint256 c = a / b;
    safeAssert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
    safeAssert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    safeAssert(c>=a && c>=b);
    return c;
  }

  function safeAssert(bool assertion) internal pure {
    if (!assertion) revert();
  }
}

contract StandardToken is owned, safeMath {
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract POWTokenOpenDistribution is owned, safeMath {
  // owner/admin & token reward
  address        public admin = owner;      //admin address
  StandardToken  public tokenContract;     // address of MoibeTV MOY ERC20 Standard Token.

  // deployment variables for static supply sale
  uint256 public initialSupply;
  uint256 public tokensRemaining;

  // multi-sig addresses and price variable
  address public budgetWallet;      // budgetMultiSig for PowerLineUp.
  uint256 public tokensPerEthPrice;      // set initial value floating priceVar.
    
  // uint256 values for min,max,caps,tracking
  uint256 public amountRaised;                           
  uint256 public fundingCap;                          

  // loop control, startup and limiters
  string  public CurrentStatus = "";                          // current OpenDistribution status
  uint256 public fundingStartBlock;                           // OpenDistribution start block#
  uint256 public fundingEndBlock;                             // OpenDistribution end block#
  bool    public isOpenDistributionClosed = false;            // OpenDistribution completion boolean
  bool    public areFundsReleasedToBudget= false;             // boolean for MoibeTV to receive Eth or not, this allows MoibeTV to use Ether only if goal reached.
  bool    public isOpenDistributionSetup = false;             // boolean for OpenDistribution setup

  event Transfer(address indexed from, address indexed to, uint256 value); 
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Buy(address indexed _sender, uint256 _eth, uint256 _MOY);
  mapping(address => uint256) balancesArray;
  mapping(address => uint256) fundValue;

  // default function, map admin
  function POWTokenOpenDistribution() public onlyOwner {
    admin = msg.sender;
    CurrentStatus = "Tokens Released, Open Distribution deployed to chain";
  }

  // total number of tokens initially
  function initialMoySupply() public constant returns (uint256 tokenTotalSupply) {
      tokenTotalSupply = safeDiv(initialSupply,1000000000000000000);
  }

  // remaining number of tokens
  function remainingSupply() public constant returns (uint256 tokensLeft) {
      tokensLeft = tokensRemaining;
  }

  // setup the OpenDistribution parameters
  function setupOpenDistribution(uint256 _fundingStartBlock, uint256 _fundingEndBlock, address _tokenContract, address _budgetWallet) public onlyOwner returns (bytes32 response) {
      if ((msg.sender == admin)
      && (!(isOpenDistributionSetup))
      && (!(budgetWallet > 0))){
          // init addresses
          tokenContract = StandardToken(_tokenContract);                             //MoibeTV MOY tokens Smart Contract.
          budgetWallet = _budgetWallet;                 //Budget multisig.
          tokensPerEthPrice = 1000;                                                  //Regular Price 1 ETH = 1000 MOY.
          
          fundingCap = 3;                                        

          // update values
          amountRaised = 0;
          initialSupply = 30000000;                                      
          tokensRemaining = safeDiv(initialSupply,1);

          fundingStartBlock = _fundingStartBlock;
          fundingEndBlock = _fundingEndBlock;

          // configure OpenDistribution
          isOpenDistributionSetup = true;
          isOpenDistributionClosed = false;
          CurrentStatus = "OpenDistribution is setup";

          //gas reduction experiment
          setPrice();
          return "OpenDistribution is setup";
      } else if (msg.sender != admin) {
          return "Not Authorized";
      } else  {
          return "Campaign cannot be changed.";
      }
    }

    function setPrice() public {  //Verificar si es necesario que sea pública. 

      //Funding Starts at the 1st Block of the Year. The very 1st block of the year is 4830771 UTC+14(Christmas Islands).      
      //After that, all the CrowdSale is measured in UTC-11(Fiji), to give chance until the very last block of each day.    
        if (block.number >= fundingStartBlock && block.number <= fundingStartBlock+11520) { // First Day 300% Bonus, 1 ETH = 3000 MOY.
        tokensPerEthPrice = 3000; 
      } else if (block.number >= fundingStartBlock+11521 && block.number <= fundingStartBlock+46080) { // First Week 200% Bonus, 1 ETH = 2000 MOY.
        tokensPerEthPrice = 2000; //Regular Price for All Stages.
      } else if (block.number >= fundingStartBlock+46081 && block.number <= fundingStartBlock+86400) { // Second Week 150% Bonus, 1 ETH = 1500 MOY.
        tokensPerEthPrice = 2000; //Regular Price for All Stages.
      } else if (block.number >= fundingStartBlock+86401 && block.number <= fundingEndBlock) { // Regular Sale, final price for all users 1 ETH = 1000 MOY. 
        tokensPerEthPrice = 1000; //Regular Price for All Stages.
      }  
         }

    // default payable function when sending ether to this contract
    function () public payable {
      require(msg.data.length == 0);
      BuyMOYTokens();
    }

    function BuyMOYTokens() public payable {
      // 0. conditions (length, OpenDistribution setup, zero check, exceed funding contrib check, contract valid check, within funding block range check, balance overflow check etc.)
      require(!(msg.value == 0)
      && (isOpenDistributionSetup)
      && (block.number >= fundingStartBlock)
      && (block.number <= fundingEndBlock)
      && (tokensRemaining > 0));

      // 1. vars
      uint256 rewardTransferAmount = 0;

      // 2. effects
      setPrice();
      amountRaised = safeAdd(amountRaised,msg.value);
      rewardTransferAmount = safeDiv(safeMul(msg.value,tokensPerEthPrice),1);

      // 3. interaction
      tokensRemaining = safeSub(tokensRemaining, safeDiv(rewardTransferAmount,1));  // will cause throw if attempt to purchase over the token limit in one tx or at all once limit reached.
      tokenContract.transfer(msg.sender, rewardTransferAmount);

      // 4. events
      fundValue[msg.sender] = safeAdd(fundValue[msg.sender], msg.value);
      Transfer(this, msg.sender, msg.value); 
      Buy(msg.sender, msg.value, rewardTransferAmount);
    }

    function budgetMultiSigWithdraw(uint256 _amount) public onlyOwner {
      require(areFundsReleasedToBudget && (amountRaised >= fundingCap));
      budgetWallet.transfer(_amount);
    }

    function checkGoalReached() public onlyOwner returns (bytes32 response) { // return OpenDistribution status to owner for each result case, update public constant.
      // update state & status variables
      require (isOpenDistributionSetup);
      if ((amountRaised < fundingCap) && (block.number <= fundingEndBlock && block.number >= fundingStartBlock)) { // OpenDistribution in progress waiting for hardcap.
        areFundsReleasedToBudget = false;
        isOpenDistributionClosed = false;
        CurrentStatus = "OpenDistribution in progress, waiting to reach goal.";
        return "OpenDistribution in progress.";
      } else if ((amountRaised < fundingCap) && (block.number < fundingStartBlock)) { // OpenDistribution has not started.
        areFundsReleasedToBudget = false;
        isOpenDistributionClosed = false;
        CurrentStatus = "OpenDistribution is setup";
        return "OpenDistribution is setup";
      } else if ((amountRaised < fundingCap) && (block.number > fundingEndBlock)) { // OpenDistribution ended, total not achieved.
        areFundsReleasedToBudget = false;
        isOpenDistributionClosed = true;
        CurrentStatus = "OpenDistribution is Over.";
        return "OpenDistribution is Over";
      } else if ((amountRaised >= fundingCap) && (tokensRemaining == 0)) { // Distribution ended, all tokens gone.
          areFundsReleasedToBudget = true;
          isOpenDistributionClosed = true;
          CurrentStatus = "Successful OpenDistribution.";
          return "Successful OpenDistribution.";
      } else if ((amountRaised >= fundingCap) && (block.number > fundingEndBlock) && (tokensRemaining > 0)) { // OpenDistribution ended.
          areFundsReleasedToBudget = true;
          isOpenDistributionClosed = true;
          CurrentStatus = "Successful OpenDistribution.";
          return "Successful OpenDistribution";
      } else if ((amountRaised >= fundingCap) && (tokensRemaining > 0) && (block.number <= fundingEndBlock)) { // OpenDistribution in progress, objetive achieved!
        areFundsReleasedToBudget = true;
        isOpenDistributionClosed = false;
        CurrentStatus = "OpenDistribution in Progress, Goal Achieved.";
        return "Goal Achieved.";
      }
      setPrice();
    }
}