pragma solidity 0.4.19;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256)  {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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
  
  function max(uint256 a, uint256 b) internal pure returns (uint256) {
    return a > b ? a : b;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;


  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
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

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


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
  function approve(address _spender, uint256 _value) public returns (bool) {
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
  function increaseApproval (address _spender, uint _addedValue)
    public
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue)
  public
    returns (bool success) {
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

/**
 * @title The OrigamiToken contract
 * @dev The OrigamiToken Token contract
 * @dev inherite from StandardToken and Ownable by Zeppelin
 * @author ori.network
 */
contract OrigamiToken is StandardToken, Ownable {
    string  public  constant name = "Origami Network";
    string  public  constant symbol = "ORI";
    uint8    public  constant decimals = 18;

    uint    public  transferableStartTime;

    address public  tokenSaleContract;
    address public  bountyWallet;


    modifier onlyWhenTransferEnabled() 
    {
        if ( now <= transferableStartTime ) {
            require(msg.sender == tokenSaleContract || msg.sender == bountyWallet || msg.sender == owner);
        }
        _;
    }

    modifier validDestination(address to) 
    {
        require(to != address(this));
        _;
    }

    function OrigamiToken(
        uint tokenTotalAmount, 
        uint _transferableStartTime, 
        address _admin, 
        address _bountyWallet) public
    {
        // Mint all tokens. Then disable minting forever.
        totalSupply_ = tokenTotalAmount * (10 ** uint256(decimals));

        // Send token to the contract
        balances[msg.sender] = totalSupply_;
        Transfer(address(0x0), msg.sender, totalSupply_);

        // Transferable start time will be set x days after sale end
        transferableStartTime = _transferableStartTime;
        // Keep the sale contrat to allow transfer from contract during the sale
        tokenSaleContract = msg.sender;
        //  Keep bounty wallet to distribute bounties before transfer is allowed
        bountyWallet = _bountyWallet;

        transferOwnership(_admin); // admin could drain tokens and eth that were sent here by mistake
    }

    /**
     * @dev override transfer token for a specified address to add onlyWhenTransferEnabled and validDestination
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint _value)
        public
        validDestination(_to)
        onlyWhenTransferEnabled
        returns (bool) 
    {
        return super.transfer(_to, _value);
    }

    /**
     * @dev override transferFrom token for a specified address to add onlyWhenTransferEnabled and validDestination
     * @param _from The address to transfer from.
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transferFrom(address _from, address _to, uint _value)
        public
        validDestination(_to)
        onlyWhenTransferEnabled
        returns (bool) 
    {
        return super.transferFrom(_from, _to, _value);
    }

    event Burn(address indexed _burner, uint _value);

    /**
     * @dev burn tokens
     * @param _value The amount to be burned.
     * @return always true (necessary in case of override)
     */
    function burn(uint _value) 
        public
        onlyWhenTransferEnabled
        returns (bool)
    {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        Burn(msg.sender, _value);
        Transfer(msg.sender, address(0x0), _value);
        return true;
    }

    /**
     * @dev burn tokens in the behalf of someone
     * @param _from The address of the owner of the token.
     * @param _value The amount to be burned.
     * @return always true (necessary in case of override)
     */
    function burnFrom(address _from, uint256 _value) 
        public
        onlyWhenTransferEnabled
        returns(bool) 
    {
        assert(transferFrom(_from, msg.sender, _value));
        return burn(_value);
    }

    /**
     * @dev transfer to owner any tokens send by mistake on this contracts
     * @param token The address of the token to transfer.
     * @param amount The amount to be transfered.
     */
    function emergencyERC20Drain(ERC20 token, uint amount )
        public
        onlyOwner 
    {
        token.transfer(owner, amount);
    }
}

/**
 * @title StandardCrowdsale 
 * @dev StandardCrowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 * @dev from Crowdsale by Zepellin.
 */
contract StandardCrowdsale {
  using SafeMath for uint256;

  // The token being sold
  StandardToken public token;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address where funds are collected
  address public wallet;

  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  /**
   * ORI modification : token is created by contract
   */
  function StandardCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) public {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != address(0));

    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
  }

  //fallback function can be used to buy tokens
  function () external payable {
    buyTokens(msg.sender);
  }

  //low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = getTokenAmount(weiAmount);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    // Override ORI : not mintable
    //token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }

  // Override this method to have a way to add business logic to your crowdsale when buying
  function getTokenAmount(uint256 weiAmount) internal view returns(uint256) {
    return weiAmount.mul(rate);
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }


  // @return true if the transaction can buy tokens
  function validPurchase() internal view returns (bool) {
    // Test is already done by origami token sale
    return true;
  }

}

/**
 * @title CappedCrowdsale
 * @dev Extension of Crowdsale with a max amount of funds raised
 */
contract CappedCrowdsale is StandardCrowdsale {
  using SafeMath for uint256;

  uint256 public cap;
  

  function CappedCrowdsale(uint256 _cap) public {
    require(_cap > 0);
    cap = _cap;
  }

  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    bool capReached = weiRaised >= cap;
    return capReached || super.hasEnded();
  }

  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  function validPurchase() internal view returns (bool) {
    bool withinCap = weiRaised < cap;
    return withinCap && super.validPurchase();
  }

}



/**
 * @title WhitelistedCrowdsale
 * @dev This is an extension to add whitelist to a crowdsale
 * @author ori.network
 *
 */
contract WhitelistedCrowdsale is StandardCrowdsale, Ownable {
    
    mapping(address=>bool) public registered;

    event RegistrationStatusChanged(address target, bool isRegistered);

    /**
     * @dev Changes registration status of an address for participation.
     * @param target Address that will be registered/deregistered.
     * @param isRegistered New registration status of address.
     */
    function changeRegistrationStatus(address target, bool isRegistered)
        public
        onlyOwner
    {
        registered[target] = isRegistered;
        RegistrationStatusChanged(target, isRegistered);
    }

    /**
     * @dev Changes registration statuses of addresses for participation.
     * @param targets Addresses that will be registered/deregistered.
     * @param isRegistered New registration status of addresses.
     */
    function changeRegistrationStatuses(address[] targets, bool isRegistered)
        public
        onlyOwner
    {
        for (uint i = 0; i < targets.length; i++) {
            changeRegistrationStatus(targets[i], isRegistered);
        }
    }

    /**
     * @dev overriding Crowdsale#validPurchase to add whilelist
     * @return true if investors can buy at the moment, false otherwise
     */
    function validPurchase() internal view  returns (bool) {
        return super.validPurchase() && registered[msg.sender];
    }
}

/**
 * @title OrigamiTokenSale
 * @dev 
 * We add new features to a base crowdsale using multiple inheritance.
 * We are using the following extensions:
 * CappedCrowdsale - sets a max boundary for raised funds
 * WhitelistedCrowdsale - add a whitelist
 *
 * The code is based on the contracts of Open Zeppelin and we add our contracts : OrigamiTokenSale, WhiteListedCrowdsale, CappedCrowdsale and the Origami Token
 *
 * @author ori.network
 */
contract OrigamiTokenSale is Ownable, CappedCrowdsale, WhitelistedCrowdsale {
    // hard cap of the token sale in ether
    uint private constant HARD_CAP_IN_WEI = 5000 ether;
    uint private constant HARD_CAP_IN_WEI_PRESALE = 1000 ether;

    // Bonus
    uint private constant BONUS_TWENTY_AMOUNT = 200 ether;
    uint private constant BONUS_TEN_AMOUNT = 100 ether;
    uint private constant BONUS_FIVE_AMOUNT = 50 ether;   
    
    // Maximum / Minimum contribution
    uint private constant MINIMUM_INVEST_IN_WEI_PRESALE = 0.5 ether;
    uint private constant CONTRIBUTOR_MAX_PRESALE_CONTRIBUTION = 50 ether;
    uint private constant MINIMUM_INVEST_IN_WEI_SALE = 0.1 ether;
    uint private constant CONTRIBUTOR_MAX_SALE_CONTRIBUTION = 500 ether;

    // TEAM WALLET
    address private constant ORIGAMI_WALLET = 0xf498ED871995C178a5815dd6D80AE60e1c5Ca2F4;
    
    // Token initialy distributed for the bounty
    address private constant BOUNTY_WALLET = 0xDBA7a16383658AeDf0A28Eabf2032479F128f26D;
    uint private constant BOUNTY_AMOUNT = 3000000e18;

    // PERIOD WHEN TOKEN IS NOT TRANSFERABLE AFTER THE SALE
    uint private constant PERIOD_AFTERSALE_NOT_TRANSFERABLE_IN_SEC = 7 days;    

    // Total of ORI supply
    uint private constant TOTAL_ORI_TOKEN_SUPPLY = 50000000;

    // Token sale rate from ETH to ORI
    uint private constant RATE_ETH_ORI = 6000;
    

    // start and end timestamp PRESALE
    uint256 public presaleStartTime;
    uint256 public presaleEndTime;
    uint256 private presaleEndedAt;
    uint256 public preSaleWeiRaised;
    
    // Bonus Times
    uint public firstWeekEndTime;
    uint public secondWeekEndTime;  
    
    
    // Check wei invested by contributor on presale
    mapping(address => uint256) wei_invested_by_contributor_in_presale;
    mapping(address => uint256) wei_invested_by_contributor_in_sale;

    event OrigamiTokenPurchase(address indexed beneficiary, uint256 value, uint256 final_tokens, uint256 initial_tokens, uint256 bonus);

    function OrigamiTokenSale(uint256 _presaleStartTime, uint256 _presaleEndTime, uint256 _startTime, uint256 _endTime, uint256 _firstWeekEndTime, uint256 _secondWeekEndTime) public
      WhitelistedCrowdsale()
      CappedCrowdsale(HARD_CAP_IN_WEI)
      StandardCrowdsale(_startTime, _endTime, RATE_ETH_ORI, ORIGAMI_WALLET)
    {
        // create the token
        token = createTokenContract();
        // Get presale start / end time
        presaleStartTime = _presaleStartTime;
        presaleEndTime = _presaleEndTime;
        firstWeekEndTime = _firstWeekEndTime;
        secondWeekEndTime = _secondWeekEndTime;

        // transfer token to bountry wallet
        token.transfer(BOUNTY_WALLET, BOUNTY_AMOUNT);
    }
    
    /**
     * @dev return if the presale is open
     */
    function preSaleOpen() 
        public
        view 
        returns(bool)
    {
        return (now >= presaleStartTime && now <= presaleEndTime && preSaleWeiRaised < HARD_CAP_IN_WEI_PRESALE);
    }
    
    /**
     * @dev return the sale ended at time
     */
    function preSaleEndedAt() 
        public
        view 
        returns(uint256)
    {
        return presaleEndedAt;
    }
    
    /**
     * @dev return if the sale is open
     */
    function saleOpen() 
        public
        view 
        returns(bool)
    {
        return (now >= startTime && now <= endTime);
    }
    
    /**
     * @dev get invested amount for an address
     * @param _address address of the wallet
     */
    function getInvestedAmount(address _address)
    public
    view
    returns (uint256)
    {
        uint256 investedAmount = wei_invested_by_contributor_in_presale[_address];
        investedAmount = investedAmount.add(wei_invested_by_contributor_in_sale[_address]);
        return investedAmount;
    }

    /**
     * @dev Get bonus from an invested amount
     * @param _weiAmount weiAmount that will be invested
     */
    function getBonusFactor(uint256 _weiAmount)
        private view returns(uint256)
    {
        // declaration bonuses
        uint256 bonus = 0;

        // If presale : bonus 15% otheriwse bonus on volume
        if(now >= presaleStartTime && now <= presaleEndTime) {
            bonus = 15;
        //si week 1 : 10%
        } else {        
          // Bonus 20 % if ETH >= 200
          if(_weiAmount >= BONUS_TWENTY_AMOUNT) {
              bonus = 20;
          }
          //  Bonus 10 % if ETH >= 100 or first week
          else if(_weiAmount >= BONUS_TEN_AMOUNT || now <= firstWeekEndTime) {
              bonus = 10;
          }
          // Bonus 10 % if ETH >= 20 or second week
          else if(_weiAmount >= BONUS_FIVE_AMOUNT || now <= secondWeekEndTime) {
              bonus = 5;
          }
        }
        
        return bonus;
    }
    
    // ORI : token are not mintable, transfer to wallet instead
    function buyTokens() 
       public 
       payable 
    {
        require(validPurchase());
        uint256 weiAmount = msg.value;

        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate);

        //get bonus
        uint256 bonus = getBonusFactor(weiAmount);
        
        // Calculate final bonus amount
        uint256 final_bonus_amount = (tokens * bonus) / 100;
        
         // Transfer bonus tokens to buyer and tokens
        uint256 final_tokens = tokens.add(final_bonus_amount);
        // Transfer token with bonus to buyer
        require(token.transfer(msg.sender, final_tokens)); 

         // Trigger event
        OrigamiTokenPurchase(msg.sender, weiAmount, final_tokens, tokens, final_bonus_amount);

        // Forward funds to team wallet
        forwardFunds();

        // update state
        weiRaised = weiRaised.add(weiAmount);

        // If cap reached, set end time to be able to transfer after x days
        if (preSaleOpen()) {
            wei_invested_by_contributor_in_presale[msg.sender] =  wei_invested_by_contributor_in_presale[msg.sender].add(weiAmount);
            preSaleWeiRaised = preSaleWeiRaised.add(weiAmount);
            if(weiRaised >= HARD_CAP_IN_WEI_PRESALE){
                presaleEndedAt = now;
            }
        }else{
            wei_invested_by_contributor_in_sale[msg.sender] =  wei_invested_by_contributor_in_sale[msg.sender].add(weiAmount);  
            if(weiRaised >= HARD_CAP_IN_WEI){
              endTime = now;
            }
        }
    }


    /**
     * 
     * @return the StandardToken created
     */
    function createTokenContract () 
      internal 
      returns(StandardToken) 
    {
        return new OrigamiToken(TOTAL_ORI_TOKEN_SUPPLY, endTime.add(PERIOD_AFTERSALE_NOT_TRANSFERABLE_IN_SEC), ORIGAMI_WALLET, BOUNTY_WALLET);
    }

    // fallback function can be used to buy tokens
    function () external
       payable 
    {
        buyTokens();
    }
    
    /**
     * @dev Returns the remaining possibled presale amount for a given wallet
     * @return amount remaining
     */
    function getContributorRemainingPresaleAmount(address wallet) public view returns(uint256) {
        uint256 invested_amount =  wei_invested_by_contributor_in_presale[wallet];
        return CONTRIBUTOR_MAX_PRESALE_CONTRIBUTION - invested_amount;
    }
    
        /**
     * @dev Returns the remaining possibled sale amount for a given wallet
     * @return amount remaining
     */
    function getContributorRemainingSaleAmount(address wallet) public view returns(uint256) {
        uint256 invested_amount =  wei_invested_by_contributor_in_sale[wallet];
        return CONTRIBUTOR_MAX_SALE_CONTRIBUTION - invested_amount;
    }

    /**
     * @dev Transfer the unsold tokens to the origami team
     * @dev Only for owner
     * @return the StandardToken created
     */
    function drainRemainingToken () 
      public
      onlyOwner
    {
        require(hasEnded());
        token.transfer(ORIGAMI_WALLET, token.balanceOf(this));
    }
    
    /**
     * @dev test if the purchase can be operated
     */
    function validPurchase () internal view returns(bool) 
    {
        // if presale, add to wei raise by contributor
        if (preSaleOpen()) {
            // Test presale Cap
            if(preSaleWeiRaised > HARD_CAP_IN_WEI_PRESALE){
                return false;
            }
            // Test minimum investing for contributor in presale
            if(msg.value < MINIMUM_INVEST_IN_WEI_PRESALE){
                 return false;
            }
            // Test global invested amount for presale per contributor
            uint256 maxInvestAmount = getContributorRemainingPresaleAmount(msg.sender);
            if(msg.value > maxInvestAmount){
              return false;
            }
        }else if(saleOpen()){
            // Test minimum investing for contributor in presale
            if(msg.value < MINIMUM_INVEST_IN_WEI_SALE){
                 return false;
            }
            
             //Test global invested amount for sale per contributor
             uint256 maxInvestAmountSale = getContributorRemainingSaleAmount(msg.sender);
             if(msg.value > maxInvestAmountSale){
               return false;
            }
        }else{
            return false;
        }

        //Check if we are in Presale and Presale hard cap not reached yet
        bool nonZeroPurchase = msg.value != 0;
        return super.validPurchase() && nonZeroPurchase;
    }

}