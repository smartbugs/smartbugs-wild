pragma solidity ^0.4.15;

/**
 * Math operations with safety checks
 */
library SafeMath {
  function mul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}




/**
 * @title  
 * @dev DatTokenSale is a contract for managing a token crowdsale.
 * DatTokenSale have a start and end date, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a refundable valut 
 * as they arrive.
 */
contract DatumTokenSale is  Ownable {

  using SafeMath for uint256;

  address public whiteListControllerAddress;

  //lookup addresses for whitelist
  mapping (address => bool) public whiteListAddresses;

  //lookup addresses for special bonuses
  mapping (address => uint) public bonusAddresses;

  //loopup for max token amount per user allowed
  mapping(address => uint256) public maxAmountAddresses;

  //loopup for balances
  mapping(address => uint256) public balances;

  // start and end date where investments are allowed (both inclusive)
  uint256 public startDate = 1509282000;//29 Oct 2017 13:00:00 +00:00 UTC
  //uint256 public startDate = 1509210891;//29 Oct 2017 13:00:00 +00:00 UTC
  
  uint256 public endDate = 1511960400; //29 Nov 2017 13:00:00 +00:00 UTC

  // Minimum amount to participate (wei for internal usage)
  uint256 public minimumParticipationAmount = 300000000000000000 wei; //0.1 ether

  // Maximum amount to participate
  uint256 public maximalParticipationAmount = 1000 ether; //1000 ether

  // address where funds are collected
  address wallet;

  // how many token units a buyer gets per ether
  uint256 rate = 25000;

  // amount of raised money in wei
  uint256 private weiRaised;

  //flag for final of crowdsale
  bool public isFinalized = false;

  //cap for the sale in ether
  uint256 public cap = 61200 ether; //61200 ether

  //total tokenSupply
  uint256 public totalTokenSupply = 1530000000 ether;

  // amount of tokens sold
  uint256 public tokensInWeiSold;

  uint private bonus1Rate = 28750;
  uint private bonus2Rate = 28375;
  uint private bonus3Rate = 28000;
  uint private bonus4Rate = 27625;
  uint private bonus5Rate = 27250;
  uint private bonus6Rate = 26875;
  uint private bonus7Rate = 26500;
  uint private bonus8Rate = 26125;
  uint private bonus9Rate = 25750;
  uint private bonus10Rate = 25375;
   
  event Finalized();
  /**
  * @notice Log an event for each funding contributed during the public phase
  * @notice Events are not logged when the constructor is being executed during
  *         deployment, so the preallocations will not be logged
  */
  event LogParticipation(address indexed sender, uint256 value);
  

  /**
  * @notice Log an event for each funding contributed converted to earned tokens
  * @notice Events are not logged when the constructor is being executed during
  *         deployment, so the preallocations will not be logged
  */
  event LogTokenReceiver(address indexed sender, uint256 value);


  /**
  * @notice Log an event for each funding contributed converted to earned tokens
  * @notice Events are not logged when the constructor is being executed during
  *         deployment, so the preallocations will not be logged
  */
  event LogTokenRemover(address indexed sender, uint256 value);
  
  function DatumTokenSale(address _wallet) payable {
    wallet = _wallet;
  }

  function () payable {
    require(whiteListAddresses[msg.sender]);
    require(validPurchase());

    buyTokens(msg.value);
  }

  // low level token purchase function
  function buyTokens(uint256 amount) internal {
    //get ammount in wei
    uint256 weiAmount = amount;

    // update state
    weiRaised = weiRaised.add(weiAmount);

    // get token amount
    uint256 tokens = getTokenAmount(weiAmount);
    tokensInWeiSold = tokensInWeiSold.add(tokens);

    //fire token receive event
    LogTokenReceiver(msg.sender, tokens);

    //update balances for user
    balances[msg.sender] = balances[msg.sender].add(tokens);

    //fire eth purchase event
    LogParticipation(msg.sender,msg.value);

    //forward funds to wallet
    forwardFunds(amount);
  }


  // manually update the tokens sold count to reserve tokens or update stats if other way bought
  function reserveTokens(address _address, uint256 amount)
  {
    require(msg.sender == whiteListControllerAddress);

    //update balances for user
    balances[_address] = balances[_address].add(amount);

    //fire event
    LogTokenReceiver(_address, amount);

    tokensInWeiSold = tokensInWeiSold.add(amount);
  }

  //release tokens from sold statistist, used if the account was not verified with KYC
  function releaseTokens(address _address, uint256 amount)
  {
    require(msg.sender == whiteListControllerAddress);

    balances[_address] = balances[_address].sub(amount);

    //fire event
    LogTokenRemover(_address, amount);

    tokensInWeiSold = tokensInWeiSold.sub(amount);
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds(uint256 amount) internal {
    wallet.transfer(amount);
  }

  // should be called after crowdsale ends or to emergency stop the sale
  function finalize() onlyOwner {
    require(!isFinalized);
    Finalized();
    isFinalized = true;
  }

  function setWhitelistControllerAddress(address _controller) onlyOwner
  {
     whiteListControllerAddress = _controller;
  }

  function addWhitelistAddress(address _addressToAdd)
  {
      require(msg.sender == whiteListControllerAddress);
      whiteListAddresses[_addressToAdd] = true;
  }

  function addSpecialBonusConditions(address _address, uint _bonusPercent, uint256 _maxAmount) 
  {
      require(msg.sender == whiteListControllerAddress);

      bonusAddresses[_address] = _bonusPercent;
      maxAmountAddresses[_address] = _maxAmount;
  }

  function removeSpecialBonusConditions(address _address) 
  {
      require(msg.sender == whiteListControllerAddress);

      delete bonusAddresses[_address];
      delete maxAmountAddresses[_address];
  }

  function addWhitelistAddresArray(address[] _addressesToAdd)
  {
      require(msg.sender == whiteListControllerAddress);

      for (uint256 i = 0; i < _addressesToAdd.length;i++) 
      {
        whiteListAddresses[_addressesToAdd[i]] = true;
      }
      
  }

  function removeWhitelistAddress(address _addressToAdd)
  {
      require(msg.sender == whiteListControllerAddress);

      delete whiteListAddresses[_addressToAdd];
  }


    function getTokenAmount(uint256 weiAmount) internal returns (uint256 tokens){
        //add bonus
        uint256 bonusRate = getBonus();

        //check for special bonus and override rate if exists
        if(bonusAddresses[msg.sender] != 0)
        {
            uint bonus = bonusAddresses[msg.sender];
            //TODO: CALUC SHCHECK
            bonusRate = rate.add((rate.mul(bonus)).div(100));
        } 

        // calculate token amount to be created
        uint256 weiTokenAmount = weiAmount.mul(bonusRate);
        return weiTokenAmount;
    }


    //When a user buys our token they will recieve a bonus depedning on time:,
    function getBonus() internal constant returns (uint256 amount){
        uint diffInSeconds = now - startDate;
        uint diffInHours = (diffInSeconds/60)/60;
        
        // 10/29/2017 - 11/1/2017
        if(diffInHours < 72){
            return bonus1Rate;
        }

        // 11/1/2017 - 11/4/2017
        if(diffInHours >= 72 && diffInHours < 144){
            return bonus2Rate;
        }

        // 11/4/2017 - 11/7/2017
        if(diffInHours >= 144 && diffInHours < 216){
            return bonus3Rate;
        }

        // 11/7/2017 - 11/10/2017
        if(diffInHours >= 216 && diffInHours < 288){
            return bonus4Rate;
        }

         // 11/10/2017 - 11/13/2017
        if(diffInHours >= 288 && diffInHours < 360){
            return bonus5Rate;
        }

         // 11/13/2017 - 11/16/2017
        if(diffInHours >= 360 && diffInHours < 432){
            return bonus6Rate;
        }

         // 11/16/2017 - 11/19/2017
        if(diffInHours >= 432 && diffInHours < 504){
            return bonus7Rate;
        }

         // 11/19/2017 - 11/22/2017
        if(diffInHours >= 504 && diffInHours < 576){
            return bonus8Rate;
        }

          // 11/22/2017 - 11/25/2017
        if(diffInHours >= 576 && diffInHours < 648){
            return bonus9Rate;
        }

          // 11/25/2017 - 11/28/2017
        if(diffInHours >= 648 && diffInHours < 720){
            return bonus10Rate;
        }

        return rate; 
    }

  // @return true if the transaction can buy tokens
  // check for valid time period, min amount and within cap
  function validPurchase() internal constant returns (bool) {
    uint256 tokenAmount = getTokenAmount(msg.value);
    bool withinPeriod = startDate <= now && endDate >= now;
    bool nonZeroPurchase = msg.value != 0;
    bool minAmount = msg.value >= minimumParticipationAmount;
    bool maxAmount = msg.value <= maximalParticipationAmount;
    bool withTokensSupply = tokensInWeiSold.add(tokenAmount) <= totalTokenSupply;
    //bool withinCap = weiRaised.add(msg.value) <= cap;
    bool withMaxAmountForAddress = maxAmountAddresses[msg.sender] == 0 || balances[msg.sender].add(tokenAmount) <= maxAmountAddresses[msg.sender];

    if(maxAmountAddresses[msg.sender] != 0)
    {
      maxAmount = balances[msg.sender].add(tokenAmount) <= maxAmountAddresses[msg.sender];
    }

    return withinPeriod && nonZeroPurchase && minAmount && !isFinalized && withTokensSupply && withMaxAmountForAddress && maxAmount;
  }

    // @return true if the goal is reached
  function capReached() public constant returns (bool) {
    return tokensInWeiSold >= totalTokenSupply;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return isFinalized;
  }

}