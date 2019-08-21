pragma solidity ^0.4.13;
library SafeMath {    
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  } 
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  } 
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }  
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BasicToken is ERC20Basic {
  
  using SafeMath for uint256;
  bool public teamStakesFrozen = true;
  mapping(address => uint256) balances;
  address public owner;
  
  function BasicToken() public {
    owner = msg.sender;
  }
  
  modifier notFrozen() {
    require(msg.sender != owner || (msg.sender == owner && !teamStakesFrozen));
    _;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public notFrozen returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }
}

contract StandardToken is ERC20, BasicToken {
  mapping (address => mapping (address => uint256)) internal allowed;
  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public notFrozen returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public notFrozen returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }
}

contract RI is StandardToken {
  string public constant name = "Fundaria Stake";
  string public constant symbol = "RI";
  uint8 public constant decimals = 0;
}

contract Sale is RI {

    using SafeMath for uint;

/********** 
 * Common *
 **********/

    // THIS IS KEY VARIABLE AND DEFINED ACCORDING TO VALUE OF PLANNED COSTS ON THE PAGE https://business.fundaria.com
    uint public poolCapUSD = 1002750;
    // USD per 1 ether, added 10% aproximatelly to secure from wrong low price. We need add 10% of Stakes to supply to cover such price.
    uint public usdPerEther = 360;
    uint public supplyCap; // Current total supply cap according to lastStakePriceUSCents and poolCapUSD 
    uint public businessPlannedPeriodDuration = 365 days; // total period planned for business activity
    uint public businessPlannedPeriodEndTimestamp;
    uint public teamCap; // team Stakes capacity
    uint8 public teamShare = 45; // share for team
    uint public distributedTeamStakes; // distributed Stakes to team   
    uint public contractCreatedTimestamp; // when this contract was created  
    address public pool = 0x335C415D7897B2cb2a2562079400Fb6eDf54a7ab; // initial pool wallet address    

/********** 
 * Bounty *
 **********/
 
    uint public distributedBountyStakes; // bounty advisors Stakes distributed total    
    uint public bountyCap; // bounty advisors Stakes capacity    
    uint8 public bountyShare = 7; // share for bounty    
    
/*********** 
 * Sale *
 ***********/
    // data to store invested wei value & Stakes for Investor
    struct saleData {
      uint stakes; // how many Stakes where recieved by this Investor total
      uint invested; // how much wei this Investor invested total
      uint bonusStakes; // how many bonus Stakes where recieved by this Investor
      uint guideReward; // Investment Guide reward amount
      address guide; // address of Investment Guide
    }
    mapping (address=>saleData) public saleStat; // invested value + Stakes data for every Investor        
    uint public saleStartTimestamp = 1511546400; // 1511546400 regular Stakes sale start date            
    uint public saleEndTimestamp = 1513965600; // 1513965600
    uint public distributedSaleStakes; // distributed stakes to all Investors
    uint public totalInvested; //how many invested total
    uint public totalWithdrawn; //how many withdrawn total
    uint public saleCap; // regular sale Stakes capacity   
    uint8 public saleShare = 45; // share for regular sale
    uint public lastStakePriceUSCents; // Stake price in U.S. cents is determined according to current timestamp (the further - the higher price)    
    uint[] public targetPrice;    
    bool public priceIsFrozen = false; // stop increasing the price temporary (in case of low demand. Can be called only after saleEndTimestamp)       
    
/************************************ 
 * Bonus Stakes & Investment Guides *
 ************************************/    
    // data to store Investment Guide reward
    struct guideData {
      bool registered; // is this Investment Guide registered
      uint accumulatedPotentialReward; // how many reward wei are potentially available
      uint withdrawnReward; // how much reward wei where withdrawn by this Investment Guide already
    }
    mapping (address=>guideData) public guidesStat; // mapping of Investment Guides datas    
    uint public bonusCap; // max amount of bonus Stakes availabe
    uint public distributedBonusStakes; // how many bonus Stakes are already distributed
    uint public bonusShare = 3; // share of bonus Stakes in supplyCap
    uint8 public guideInvestmentAttractedShareToPay = 10; // reward for the Investment Guide

/*
  WANT TO EARN ON STAKES SALE ?
  BECOME INVESTMENT GUIDE AND RECIEVE 10% OF ATTRACTED INVESTMENT !
  INTRODUCE YOURSELF ON FUNDARIA.COM@GMAIL.COM & GIVE YOUR WALLET ADDRESS
*/
    
/************* 
 * Promotion *
 *************/
    
    uint public maxAmountForSalePromotion = 30 ether; // How many we can use for promotion of sale
    uint public withdrawnAmountForSalePromotion;    

/********************************************* 
 * To Pool transfers & Investment withdrawal *
 *********************************************/

    uint8 public financePeriodsCount = 12; // How many finance periods in planned period
    uint[] public financePeriodsTimestamps; // Supportive array for searching current finance period
    uint public transferedToPool; // how much wei transfered to pool already

/* EVENTS */

    event StakesSale(address to, uint weiInvested, uint stakesRecieved, uint teamStakesRecieved, uint stake_price_us_cents);
    event BountyDistributed(address to, uint bountyStakes);
    event TransferedToPool(uint weiAmount, uint8 currentFinancialPeriodNo);
    event InvestmentWithdrawn(address to, uint withdrawnWeiAmount, uint stakesBurned, uint8 remainedFullFinancialPeriods);
    event UsdPerEtherChanged(uint oldUsdPerEther, uint newUsdPerEther);
    event BonusDistributed(address to, uint bonusStakes, address guide, uint accumulatedPotentialReward);
    event PoolCapChanged(uint oldCapUSD, uint newCapUSD);
    event RegisterGuide(address investmentGuide);
    event TargetPriceChanged(uint8 N, uint oldTargetPrice, uint newTargetPrice);
    
    modifier onlyOwner() {
      require(msg.sender==owner);
      _;
    }
  /**
   * @dev Determine duration of finance period, fill array with finance periods timestamps,
   *      set businessPlannedPeriodEndTimestamp and contractCreatedTimestamp,    
   */      
    function Sale() public {     
      uint financePeriodDuration = businessPlannedPeriodDuration/financePeriodsCount; // quantity of seconds in chosen finance period
      // making array with timestamps of every finance period end date
      for(uint8 i=0; i<financePeriodsCount; i++) {
        financePeriodsTimestamps.push(saleEndTimestamp+financePeriodDuration*(i+1));  
      }
      businessPlannedPeriodEndTimestamp = saleEndTimestamp+businessPlannedPeriodDuration; 
      contractCreatedTimestamp = now;
      targetPrice.push(1); // Initial Stake price mark in U.S. cents (1 cent = $0.01)  
      targetPrice.push(10); // price mark at the sale period start timestamp      
      targetPrice.push(100); // price mark at the sale period end timestamp       
      targetPrice.push(1000); // price mark at hte end of business planned period          
    }
  /**
   * @dev How many investment remained? Maximum investment is poolCapUSD
   * @return remainingInvestment in wei   
   */     
    function remainingInvestment() public view returns(uint) {
      return poolCapUSD.div(usdPerEther).mul(1 ether).sub(totalInvested);  
    }
  /**
   * @dev Dynamically set caps
   */       
    function setCaps() internal {
      // remaining Stakes are determined only from remainingInvestment
      saleCap = distributedSaleStakes+stakeForWei(remainingInvestment()); // max available Stakes for sale including already distributed
      supplyCap = saleCap.mul(100).div(saleShare); // max available Stakes for supplying
      teamCap = supplyCap.mul(teamShare).div(100); // max available team Stakes
      bonusCap = supplyCap.mul(bonusShare).div(100); // max available Stakes for bonus
      bountyCap = supplyCap.sub(saleCap).sub(teamCap).sub(bonusCap); // max available Stakes for bounty        
    }
  /**
   * @dev Dynamically set the price of Stake in USD cents, which depends on current timestamp (price grows with time)
   */       
    function setStakePriceUSCents() internal {
        uint targetPriceFrom;
        uint targetPriceTo;
        uint startTimestamp;
        uint endTimestamp;
      // set price for pre sale period      
      if(now < saleStartTimestamp) {
        targetPriceFrom = targetPrice[0];
        targetPriceTo = targetPrice[1];
        startTimestamp = contractCreatedTimestamp;
        endTimestamp = saleStartTimestamp;        
      // set price for sale period
      } else if(now >= saleStartTimestamp && now < saleEndTimestamp) {
        targetPriceFrom = targetPrice[1];
        targetPriceTo = targetPrice[2];
        startTimestamp = saleStartTimestamp;
        endTimestamp = saleEndTimestamp;    
      // set price for post sale period
      } else if(now >= saleEndTimestamp && now < businessPlannedPeriodEndTimestamp) {
        targetPriceFrom = targetPrice[2];
        targetPriceTo = targetPrice[3];
        startTimestamp = saleEndTimestamp;
        endTimestamp = businessPlannedPeriodEndTimestamp;    
      }     
      lastStakePriceUSCents = targetPriceFrom + ((now-startTimestamp)*(targetPriceTo-targetPriceFrom))/(endTimestamp-startTimestamp);       
    }  
  /**
   * @dev Recieve wei and process Stakes sale
   */    
    function() payable public {
      require(msg.sender != address(0));
      require(msg.value > 0); // process only requests with wei
      require(now < businessPlannedPeriodEndTimestamp); // no later then at the end of planned period
      processSale();       
    }
  /**
   * @dev Process Stakes sale
   */       
    function processSale() internal {
      if(!priceIsFrozen) { // refresh price only if price is not frozen
        setStakePriceUSCents();
      }
      setCaps();    

        uint teamStakes; // Stakes for the team according to teamShare
        uint saleStakes; // Stakes for the Sale
        uint weiInvested; // weiInvested now by this Investor
        uint trySaleStakes = stakeForWei(msg.value); // try to get this quantity of Stakes

      if(trySaleStakes > 1) {
        uint tryDistribute = distributedSaleStakes+trySaleStakes; // try to distribute this tryStakes        
        if(tryDistribute <= saleCap) { // saleCap not reached
          saleStakes = trySaleStakes; // all tryStakes can be sold
          weiInvested = msg.value; // all current wei are accepted                    
        } else {
          saleStakes = saleCap-distributedSaleStakes; // only remnant of Stakes are available
          weiInvested = weiForStake(saleStakes); // wei for available remnant of Stakes 
        }
        teamStakes = (saleStakes*teamShare).div(saleShare); // part of Stakes for a team        
        if(saleStakes > 0) {          
          balances[owner] += teamStakes; // rewarding team according to teamShare
          totalSupply += teamStakes; // supplying team Stakes
          distributedTeamStakes += teamStakes; // saving distributed team Stakes 
          saleSupply(msg.sender, saleStakes, weiInvested, teamStakes); // process saleSupply
          if(saleStat[msg.sender].guide != address(0)) { // we have Investment Guide to reward and distribute bonus Stakes
            distributeBonusStakes(msg.sender, saleStakes, weiInvested);  
          }          
        }        
        if(tryDistribute > saleCap) {
          msg.sender.transfer(msg.value-weiInvested); // return remnant
        }        
      } else {
        msg.sender.transfer(msg.value); // return incorrect wei
      }
    }
  /**
   * @dev Transfer Stakes from owner balance to buyer balance & saving data to saleStat storage
   * @param _to is address of buyer 
   * @param _stakes is quantity of Stakes transfered 
   * @param _wei is value invested        
   */ 
    function saleSupply(address _to, uint _stakes, uint _wei, uint team_stakes) internal {
      require(_stakes > 0);   
      balances[_to] = balances[_to].add(_stakes); // to
      totalSupply = totalSupply.add(_stakes);
      distributedSaleStakes = distributedSaleStakes.add(_stakes);
      totalInvested = totalInvested.add(_wei); // adding to total investment
      // saving stat
      saleStat[_to].stakes = saleStat[_to].stakes.add(_stakes); // stating Stakes bought       
      saleStat[_to].invested = saleStat[_to].invested.add(_wei); // stating wei invested
      StakesSale(_to, _wei, _stakes, team_stakes, lastStakePriceUSCents);
    }      
  /**
   * @dev Set new owner
   * @param new_owner new owner  
   */    
    function setNewOwner(address new_owner) public onlyOwner {
      owner = new_owner; 
    }
  /**
   * @dev Set new ether price in USD. Should be changed when price grow-fall 5%-10%
   * @param new_usd_per_ether new price  
   */    
    function setUsdPerEther(uint new_usd_per_ether) public onlyOwner {
      UsdPerEtherChanged(usdPerEther, new_usd_per_ether);
      usdPerEther = new_usd_per_ether; 
    }
  /**
   * @dev Set address of wallet where investment will be transfered for further using in business transactions
   * @param _pool new address of the Pool   
   */         
    function setPoolAddress(address _pool) public onlyOwner {
      pool = _pool;  
    }
  /**
   * @dev Change Pool capacity in USD
   * @param new_pool_cap_usd new Pool cap in $   
   */    
    function setPoolCapUSD(uint new_pool_cap_usd) public onlyOwner {
      PoolCapChanged(poolCapUSD, new_pool_cap_usd);
      poolCapUSD = new_pool_cap_usd; 
    }
  /**
   * @dev Register Investment Guide
   * @param investment_guide address of Investment Guide   
   */     
    function registerGuide(address investment_guide) public onlyOwner {
      guidesStat[investment_guide].registered = true;
      RegisterGuide(investment_guide);
    }
  /**
   * @dev Stop increasing price dynamically. Set it as static temporary. 
   */   
    function freezePrice() public onlyOwner {
      priceIsFrozen = true; 
    }
  /**
   * @dev Continue increasing price dynamically (the standard, usual algorithm).
   */       
    function unfreezePrice() public onlyOwner {
      priceIsFrozen = false; // this means that price is unfrozen  
    }
  /**
   * @dev Ability to tune dynamic price changing with time.
   */       
    function setTargetPrice(uint8 n, uint stake_price_us_cents) public onlyOwner {
      TargetPriceChanged(n, targetPrice[n], stake_price_us_cents);
      targetPrice[n] = stake_price_us_cents;
    }  
  /**
   * @dev Get and set address of Investment Guide and distribute bonus Stakes and Guide reward
   * @param key address of Investment Guide   
   */     
    function getBonusStakesPermanently(address key) public {
      require(guidesStat[key].registered);
      require(saleStat[msg.sender].guide == address(0)); // Investment Guide is not applied yet for this Investor
      saleStat[msg.sender].guide = key; // apply Guide 
      if(saleStat[msg.sender].invested > 0) { // we have invested value, process distribution of bonus Stakes and rewarding a Guide     
        distributeBonusStakes(msg.sender, saleStat[msg.sender].stakes, saleStat[msg.sender].invested);
      }
    }
  /**
   * @dev Distribute bonus Stakes to Investor according to bonusShare
   * @param _to to which Investor to distribute
   * @param added_stakes how many Stakes are added by this Investor    
   * @param added_wei how much wei are invested by this Investor 
   * @return wei quantity        
   */       
    function distributeBonusStakes(address _to, uint added_stakes, uint added_wei) internal {
      uint added_bonus_stakes = (added_stakes*((bonusShare*100).div(saleShare)))/100; // how many bonus Stakes to add
      require(distributedBonusStakes+added_bonus_stakes <= bonusCap); // check is bonus cap is not overflowed
      uint added_potential_reward = (added_wei*guideInvestmentAttractedShareToPay)/100; // reward for the Guide
      guidesStat[saleStat[_to].guide].accumulatedPotentialReward += added_potential_reward; // save reward for the Guide
      saleStat[_to].guideReward += added_potential_reward; // add guideReward wei value for stat
      saleStat[_to].bonusStakes += added_bonus_stakes; // add bonusStakes for stat    
      balances[_to] += added_bonus_stakes; // transfer bonus Stakes
      distributedBonusStakes += added_bonus_stakes; // save bonus Stakes distribution
      totalSupply += added_bonus_stakes; // increase totalSupply
      BonusDistributed(_to, added_bonus_stakes, saleStat[_to].guide, added_potential_reward);          
    }
  /**
   * @dev Show how much wei can withdraw Investment Guide
   * @param _guide address of registered guide 
   * @return wei quantity        
   */     
    function guideRewardToWithdraw(address _guide) public view returns(uint) {
      uint8 current_finance_period = 0;
      for(uint8 i=0; i < financePeriodsCount; i++) {
        current_finance_period = i+1;
        if(now<financePeriodsTimestamps[i]) {          
          break;
        }
      }
      // reward to withdraw depends on current finance period and do not include potentially withdaw amount of investment
      return (guidesStat[_guide].accumulatedPotentialReward*current_finance_period)/financePeriodsCount - guidesStat[_guide].withdrawnReward;  
    }  
  /**
   * @dev Show share of Stakes on some address related to full supply capacity
   * @param my_address my or someone address
   * @return share of Stakes in % (floored to less number. If less then 1, null is showed)        
   */      
    function myStakesSharePercent(address my_address) public view returns(uint) {
      return (balances[my_address]*100)/supplyCap;
    }
  
  /*
    weiForStake & stakeForWei functions sometimes show not correct translated value from dapp interface (view) 
    because lastStakePriceUSCents sometimes temporary outdated (in view mode)
    but it doesn't mean that execution itself is not correct  
  */  
  
  /**
   * @dev Translate wei to Stakes
   * @param input_wei is wei to translate into stakes, 
   * @return Stakes quantity        
   */ 
    function stakeForWei(uint input_wei) public view returns(uint) {
      return ((input_wei*usdPerEther*100)/1 ether)/lastStakePriceUSCents;    
    }  
  /**
   * @dev Translate Stakes to wei
   * @param input_stake is stakes to translate into wei
   * @return wei quantity        
   */ 
    function weiForStake(uint input_stake) public view returns(uint) {
      return (input_stake*lastStakePriceUSCents*1 ether)/(usdPerEther*100);    
    } 
  /**
   * @dev Transfer wei from this contract to pool wallet partially only, 
   *      1) for funding promotion of Stakes sale   
   *      2) according to share (finance_periods_last + current_finance_period) / business_planned_period
   */    
    function transferToPool() public onlyOwner {      
      uint available; // available funds for transfering to pool    
      uint amountToTransfer; // amount to transfer to pool
      // promotional funds
      if(now < saleEndTimestamp) {
        require(withdrawnAmountForSalePromotion < maxAmountForSalePromotion); // withdrawn not maximum promotional funds
        available = totalInvested/financePeriodsCount; // avaialbe only part of total value of total invested funds        
        // current contract balance + witdrawn promo funds is less or equal to max promo funds
        if(available+withdrawnAmountForSalePromotion <= maxAmountForSalePromotion) {
          withdrawnAmountForSalePromotion += available;
          transferedToPool += available;
          amountToTransfer = available;         
        } else {
          // contract balance + witdrawn promo funds more then maximum promotional funds 
          amountToTransfer = maxAmountForSalePromotion-withdrawnAmountForSalePromotion;
          withdrawnAmountForSalePromotion = maxAmountForSalePromotion;
          transferedToPool = maxAmountForSalePromotion;
        }
        pool.transfer(amountToTransfer);
        TransferedToPool(amountToTransfer, 0);             
      } else {
        // search end timestamp of current financial period
        for(uint8 i=0; i < financePeriodsCount; i++) {
          // found end timestamp of current financial period OR now is later then business planned end date (transfer wei remnant)
          if(now < financePeriodsTimestamps[i] || (i == financePeriodsCount-1 && now > financePeriodsTimestamps[i])) {   
            available = ((i+1)*(totalInvested+totalWithdrawn))/financePeriodsCount; // avaialbe only part of total value of total invested funds
            // not all available funds are transfered at the moment
            if(available > transferedToPool) {
              amountToTransfer = available-transferedToPool;
              if(amountToTransfer > this.balance) {
                amountToTransfer = this.balance;  
              }
              transferedToPool += amountToTransfer;
              pool.transfer(amountToTransfer);                           
              TransferedToPool(amountToTransfer, i+1);
            }
            break;    
          }
        }
      }      
    }  
  /**
   * @dev Investor can withdraw part of his/her investment.
   *      A size of this part depends on how many financial periods last and how many remained.
   *      Investor gives back all stakes which he/she got for his/her investment.     
   */       
    function withdrawInvestment() public {
      require(saleStat[msg.sender].stakes > 0);
      require(balances[msg.sender] >= saleStat[msg.sender].stakes+saleStat[msg.sender].bonusStakes); // Investor has needed stakes to return
      require(now > saleEndTimestamp); // do not able to withdraw investment before end of regular sale period
      uint remained; // all investment which are available to withdraw by all Investors
      uint to_withdraw; // available funds to withdraw for this particular Investor
      for(uint8 i=0; i < financePeriodsCount-1; i++) {
        if(now<financePeriodsTimestamps[i]) { // find end timestamp of current financial period          
          remained = totalInvested - ((i+1)*totalInvested)/financePeriodsCount; // remained investment to withdraw by all Investors 
          to_withdraw = (saleStat[msg.sender].invested*remained)/totalInvested; // investment to withdraw by this Investor
          uint sale_stakes_to_burn = saleStat[msg.sender].stakes+saleStat[msg.sender].bonusStakes; // returning all Stakes saved in saleStat[msg.sender]
          uint team_stakes_to_burn = (saleStat[msg.sender].stakes*teamShare)/saleShare; // team Stakes are also burned
          balances[owner] = balances[owner].sub(team_stakes_to_burn); // burn appropriate team Stakes
          distributedTeamStakes -= team_stakes_to_burn; // remove team Stakes from distribution         
          balances[msg.sender] = balances[msg.sender].sub(sale_stakes_to_burn); // burn stakes got for invested wei
          totalInvested = totalInvested.sub(to_withdraw); // decrease invested total value
          totalSupply = totalSupply.sub(sale_stakes_to_burn).sub(team_stakes_to_burn); // totalSupply is decreased
          distributedSaleStakes -= saleStat[msg.sender].stakes;
          if(saleStat[msg.sender].guide != address(0)) { // we have Guide and bonusStakes
            // potential reward for the Guide is decreased proportionally
            guidesStat[saleStat[msg.sender].guide].accumulatedPotentialReward -= (saleStat[msg.sender].guideReward - ((i+1)*saleStat[msg.sender].guideReward)/financePeriodsCount); 
            distributedBonusStakes -= saleStat[msg.sender].bonusStakes;
            saleStat[msg.sender].bonusStakes = 0;
            saleStat[msg.sender].guideReward = 0;          
          }
          saleStat[msg.sender].stakes = 0; // nullify Stakes recieved value          
          saleStat[msg.sender].invested = 0; // nullify wei invested value
          totalWithdrawn += to_withdraw;
          msg.sender.transfer(to_withdraw); // witdraw investment
          InvestmentWithdrawn(msg.sender, to_withdraw, sale_stakes_to_burn, financePeriodsCount-i-1);          
          break;  
        }
      }      
    }
  /**
   * @dev Distribute bounty rewards for bounty tasks
   * @param _to is address of bounty hunter
   * @param _stakes is quantity of Stakes transfered       
   */     
    function distributeBounty(address _to, uint _stakes) public onlyOwner {
      require(distributedBountyStakes+_stakes <= bountyCap); // no more then maximum capacity can be distributed
      balances[_to] = balances[_to].add(_stakes); // to
      totalSupply += _stakes; 
      distributedBountyStakes += _stakes; // adding to total bounty distributed
      BountyDistributed(_to, _stakes);    
    }  
  /**
   * @dev Unfreeze team Stakes. Only after excessed Stakes have burned.
   */      
    function unFreeze() public onlyOwner {
      // only after planned period
      if(now > businessPlannedPeriodEndTimestamp) {
        teamStakesFrozen = false; // make team stakes available for transfering
      }  
    }
}