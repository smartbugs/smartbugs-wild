pragma solidity ^0.4.17;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address internal owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


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
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

}

/**
 * @title TradePlaceCrowdsale
 * @author HamzaYasin1 - Github
 * @dev TradePlaceCrowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them EXTP tokens based
 * on a EXTP token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */













/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

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

    uint256 _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
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
    returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue)
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
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */

  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(msg.sender, _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }

  function burnTokens(uint256 _unsoldTokens) onlyOwner public returns (bool) {
    totalSupply = SafeMath.sub(totalSupply, _unsoldTokens);
  }

}









/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

/**
 * @title Med-h Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract Crowdsale is Ownable, Pausable {

  using SafeMath for uint256;

  /**
   *  @MintableToken token - Token Object
   *  @address wallet - Wallet Address
   *  @uint256 rate - Tokens per Ether
   *  @uint256 weiRaised - Total funds raised in Ethers
  */
  MintableToken internal token;
  address internal wallet;
  uint256 public rate;
  uint256 internal weiRaised;

 /**
    *  @uint256 preICOstartTime - pre ICO Start Time
    *  @uint256 preICOEndTime - pre ICO End Time
    *  @uint256 ICOstartTime - ICO Start Time
    *  @uint256 ICOEndTime - ICO End Time
    */
    uint256 public preICOstartTime;
    uint256 public preICOEndTime;
  
    uint256 public ICOstartTime;
    uint256 public ICOEndTime;
    
    // Weeks in UTC

    uint public StageTwo;
    uint public StageThree;
    uint public StageFour;

    /**
    *  @uint preIcoBonus 
    *  @uint StageOneBonus
    *  @uint StageTwoBonus
    *  @uint StageThreeBonus 
    */
    uint public preIcoBonus;
    uint public StageOneBonus;
    uint public StageTwoBonus;
    uint public StageThreeBonus;

    /**
    *  @uint256 totalSupply - Total supply of tokens  ~ 500,000,000 EXTP 
    *  @uint256 publicSupply - Total public Supply  ~ 20 percent
    *  @uint256 preIcoSupply - Total PreICO Supply from Public Supply ~ 10 percent
    *  @uint256 icoSupply - Total ICO Supply from Public Supply ~ 10 percent
    *  @uint256 bountySupply - Total Bounty Supply ~ 10 percent
    *  @uint256 reserveSupply - Total Reserve Supply ~ 20 percent
    *  @uint256 advisorSupply - Total Advisor Supply ~ 10 percent
    *  @uint256 founderSupply - Total Founder Supply ~ 20 percent
    *  @uint256 teamSupply - Total team Supply ~ 10 percent
    *  @uint256 rewardSupply - Total reward Supply ~ 10 percent
    */
    uint256 public totalSupply = SafeMath.mul(500000000, 1 ether); // 500000000
    uint256 public publicSupply = SafeMath.mul(100000000, 1 ether);
    uint256 public preIcoSupply = SafeMath.mul(50000000, 1 ether);                     
    uint256 public icoSupply = SafeMath.mul(50000000, 1 ether);

    uint256 public bountySupply = SafeMath.mul(50000000, 1 ether);
    uint256 public reserveSupply = SafeMath.mul(100000000, 1 ether);
    uint256 public advisorSupply = SafeMath.mul(50000000, 1 ether);
    uint256 public founderSupply = SafeMath.mul(100000000, 1 ether);
    uint256 public teamSupply = SafeMath.mul(50000000, 1 ether);
    uint256 public rewardSupply = SafeMath.mul(50000000, 1 ether);
  
    /**
    *  @uint256 advisorTimeLock - Advisor Timelock 
    *  @uint256 founderfounderTimeLock - Founder and Team Timelock 
    *  @uint256 reserveTimeLock - Company Reserved Timelock 
    *  @uint256 reserveTimeLock - Team Timelock 
    */
    uint256 public founderTimeLock;
    uint256 public advisorTimeLock;
    uint256 public reserveTimeLock;
    uint256 public teamTimeLock;

    // count the number of function calls
    uint public founderCounter = 0; // internal
    uint public teamCounter = 0;
    uint public advisorCounter = 0;
  /**
    *  @bool checkUnsoldTokens - 
    *  @bool upgradeICOSupply - Boolean variable updates when the PreICO tokens added to ICO supply
    *  @bool grantReserveSupply - Boolean variable updates when reserve tokens minted
    */
    bool public checkBurnTokens;
    bool public upgradeICOSupply;
    bool public grantReserveSupply;

 /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    /**
   * function Crowdsale - Parameterized Constructor
   * @param _startTime - StartTime of Crowdsale
   * @param _endTime - EndTime of Crowdsale
   * @param _rate - Tokens against Ether
   * @param _wallet - MultiSignature Wallet Address
   */
 function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != 0x0);

    token = createTokenContract();
    preICOstartTime = _startTime; // Dec - 10 - 2018
    preICOEndTime =  1547769600; //SafeMath.add(preICOstartTime,3 minutes);   Jan - 18 - 2019 
    ICOstartTime =  1548633600; //SafeMath.add(preICOEndTime, 1 minutes); Jan - 28 - 2019
    ICOEndTime = _endTime; // March - 19 - 2019
    rate = _rate; 
    wallet = _wallet;

    /** Calculations of Bonuses in private Sale or Pre-ICO */
    preIcoBonus = SafeMath.div(SafeMath.mul(rate,20),100);
    StageOneBonus = SafeMath.div(SafeMath.mul(rate,15),100);
    StageTwoBonus = SafeMath.div(SafeMath.mul(rate,10),100);
    StageThreeBonus = SafeMath.div(SafeMath.mul(rate,5),100);

    /** ICO bonuses week calculations */
    StageTwo = SafeMath.add(ICOstartTime, 12 days); //12 days
    StageThree = SafeMath.add(StageTwo, 12 days);
    StageFour = SafeMath.add(StageThree, 12 days);

    /** Vested Period calculations for team and advisors*/
    founderTimeLock = SafeMath.add(ICOEndTime, 3 minutes);
    advisorTimeLock = SafeMath.add(ICOEndTime, 3 minutes);
    reserveTimeLock = SafeMath.add(ICOEndTime, 3 minutes);
    teamTimeLock = SafeMath.add(ICOEndTime, 3 minutes);
    
    checkBurnTokens = false;
    upgradeICOSupply = false;
    grantReserveSupply = false;
  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
  }
  /**
   * function preIcoTokens - Calculate Tokens in of PRE-ICO 
   */
  function preIcoTokens(uint256 weiAmount, uint256 tokens) internal returns (uint256) {
  
    require(preIcoSupply > 0);
    tokens = SafeMath.add(tokens, weiAmount.mul(preIcoBonus));
    tokens = SafeMath.add(tokens, weiAmount.mul(rate));

    require(preIcoSupply >= tokens);
    
    preIcoSupply = preIcoSupply.sub(tokens);        
    publicSupply = publicSupply.sub(tokens);

    return tokens;     
  }

  /**
   * function icoTokens - Calculate Tokens in Main ICO
   */
  function icoTokens(uint256 weiAmount, uint256 tokens, uint256 accessTime) internal returns (uint256) {

    require(icoSupply > 0);
      
      if ( accessTime <= StageTwo ) { 
        tokens = SafeMath.add(tokens, weiAmount.mul(StageOneBonus));
      } else if (( accessTime <= StageThree ) && (accessTime > StageTwo)) {  
        tokens = SafeMath.add(tokens, weiAmount.mul(StageTwoBonus));
      } else if (( accessTime <= StageFour ) && (accessTime > StageThree)) {  
        tokens = SafeMath.add(tokens, weiAmount.mul(StageThreeBonus));
      }
        tokens = SafeMath.add(tokens, weiAmount.mul(rate)); 
      require(icoSupply >= tokens);
      
      icoSupply = icoSupply.sub(tokens);        
      publicSupply = publicSupply.sub(tokens);

      return tokens;
  }
  

  // fallback function can be used to buy tokens
  function () payable {
    buyTokens(msg.sender);
  }

  // High level token purchase function
  function buyTokens(address beneficiary) whenNotPaused public payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;
    // minimum investment should be 0.05 ETH 
    require((weiAmount >= 50000000000000000));
    
    uint256 accessTime = now;
    uint256 tokens = 0;


   if ((accessTime >= preICOstartTime) && (accessTime <= preICOEndTime)) {
           tokens = preIcoTokens(weiAmount, tokens);

    } else if ((accessTime >= ICOstartTime) && (accessTime <= ICOEndTime)) {
       if (!upgradeICOSupply) {
          icoSupply = SafeMath.add(icoSupply,preIcoSupply);
          upgradeICOSupply = true;
        }
       tokens = icoTokens(weiAmount, tokens, accessTime);
    } else {
      revert();
    }
    
    weiRaised = weiRaised.add(weiAmount);
     if(msg.data.length == 20) {
    address referer = bytesToAddress(bytes(msg.data));
    // self-referrer check
    require(referer != msg.sender);
    uint refererTokens = tokens.mul(6).div(100);
    // bonus for referrer
    token.mint(referer, refererTokens);
  }
    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    forwardFunds();
  }

  // send ether to the fund collection wallet
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

function bytesToAddress(bytes source) internal pure returns(address) {
  uint result;
  uint mul = 1;
  for(uint i = 20; i > 0; i--) {
    result += uint8(source[i-1])*mul;
    mul = mul*256;
  }
  return address(result);
}
  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= preICOstartTime && now <= ICOEndTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
      return now > ICOEndTime;
  }

  function getTokenAddress() onlyOwner public returns (address) {
    return token;
  }

}





contract Allocations is Crowdsale {

    function bountyDrop(address[] recipients, uint256[] values) public onlyOwner {

        for (uint256 i = 0; i < recipients.length; i++) {
            values[i] = SafeMath.mul(values[i], 1 ether);
            require(bountySupply >= values[i]);
            bountySupply = SafeMath.sub(bountySupply,values[i]);

            token.mint(recipients[i], values[i]);
        }
    }

    function rewardDrop(address[] recipients, uint256[] values) public onlyOwner {

        for (uint256 i = 0; i < recipients.length; i++) {
            values[i] = SafeMath.mul(values[i], 1 ether);
            require(rewardSupply >= values[i]);
            rewardSupply = SafeMath.sub(rewardSupply,values[i]);

            token.mint(recipients[i], values[i]);
        }
    }

    function grantAdvisorToken(address beneficiary ) public onlyOwner {
        require((advisorCounter < 4) && (advisorTimeLock < now));
        advisorTimeLock = SafeMath.add(advisorTimeLock, 2 minutes);
        token.mint(beneficiary,SafeMath.div(advisorSupply, 4));
        advisorCounter = SafeMath.add(advisorCounter, 1);    
    }

    function grantFounderToken(address founderAddress) public onlyOwner {
        require((founderCounter < 4) && (founderTimeLock < now));
        founderTimeLock = SafeMath.add(founderTimeLock, 2 minutes);
        token.mint(founderAddress,SafeMath.div(founderSupply, 4));
        founderCounter = SafeMath.add(founderCounter, 1);        
    }

    function grantTeamToken(address teamAddress) public onlyOwner {
        require((teamCounter < 2) && (teamTimeLock < now));
        teamTimeLock = SafeMath.add(teamTimeLock, 2 minutes);
        token.mint(teamAddress,SafeMath.div(teamSupply, 4));
        teamCounter = SafeMath.add(teamCounter, 1);        
    }

    function grantReserveToken(address beneficiary) public onlyOwner {
        require((!grantReserveSupply) && (now > reserveTimeLock));
        grantReserveSupply = true;
        token.mint(beneficiary,reserveSupply);
        reserveSupply = 0;
    }

    function transferFunds(address[] recipients, uint256[] values) public onlyOwner {
        require(!checkBurnTokens);
        for (uint256 i = 0; i < recipients.length; i++) {
            values[i] = SafeMath.mul(values[i], 1 ether);
            require(publicSupply >= values[i]);
            publicSupply = SafeMath.sub(publicSupply,values[i]);
            token.mint(recipients[i], values[i]); 
            }
    } 

    function burnToken() public onlyOwner returns (bool) {
        require(hasEnded());
        require(!checkBurnTokens);
        // token.burnTokens(icoSupply);
        totalSupply = SafeMath.sub(totalSupply, icoSupply);
        publicSupply = 0;
        preIcoSupply = 0;
        icoSupply = 0;
        checkBurnTokens = true;

        return true;
    }

}





/**
 * @title CappedCrowdsale
 * @dev Extension of Crowdsale with a max amount of funds raised
 */
contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 internal cap;

  function CappedCrowdsale(uint256 _cap) {
    require(_cap > 0);
    cap = _cap;
  }

  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  function validPurchase() internal constant returns (bool) {
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return super.validPurchase() && withinCap;
  }

  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    bool capReached = weiRaised >= cap;
    return super.hasEnded() || capReached;
  }

}










/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCrowdsale is Crowdsale {
  using SafeMath for uint256;

  bool isFinalized = false;

  event Finalized();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalizeCrowdsale() onlyOwner public {
    require(!isFinalized);
    require(hasEnded());
    
    finalization();
    Finalized();
    
    isFinalized = true;
    }
  

  /**
   * @dev Can be overridden to add finalization logic. The overriding function
   * should call super.finalization() to ensure the chain of finalization is
   * executed entirely.
   */
  function finalization() internal {
  }
}






/**
 * @title RefundVault
 * @dev This contract is used for storing funds while a crowdsale
 * is in progress. Supports refunding the money if crowdsale fails,
 * and forwarding it if crowdsale is successful.
 */
contract RefundVault is Ownable {
  using SafeMath for uint256;

  enum State { Active, Refunding, Closed }

  mapping (address => uint256) public deposited;
  address public wallet;
  State public state;

  event Closed();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);

  function RefundVault(address _wallet) {
    require(_wallet != 0x0);
    wallet = _wallet;
    state = State.Active;
  }

  function deposit(address investor) onlyOwner public payable {
    require(state == State.Active);
    deposited[investor] = deposited[investor].add(msg.value);
  }

  function close() onlyOwner public {
    require(state == State.Active);
    state = State.Closed;
    Closed();
    wallet.transfer(this.balance);
  }

  function enableRefunds() onlyOwner public {
    require(state == State.Active);
    state = State.Refunding;
    RefundsEnabled();
  }

  function refund(address investor) public {
    require(state == State.Refunding);
    uint256 depositedValue = deposited[investor];
    deposited[investor] = 0;
    investor.transfer(depositedValue);
    Refunded(investor, depositedValue);
  }
}



/**
 * @title RefundableCrowdsale
 * @dev Extension of Crowdsale contract that adds a funding goal, and
 * the possibility of users getting a refund if goal is not met.
 * Uses a RefundVault as the crowdsale's vault.
 */
contract RefundableCrowdsale is FinalizableCrowdsale {
  using SafeMath for uint256;

  // minimum amount of funds to be raised in weis
  uint256 internal goal;
  // refund vault used to hold funds while crowdsale is running
  RefundVault private vault;

  function RefundableCrowdsale(uint256 _goal) {
    require(_goal > 0);
    vault = new RefundVault(wallet);
    goal = _goal;
  }

  // We're overriding the fund forwarding from Crowdsale.
  // In addition to sending the funds, we want to call
  // the RefundVault deposit function
  function forwardFunds() internal {
    vault.deposit.value(msg.value)(msg.sender);
  }

  // if crowdsale is unsuccessful, investors can claim refunds here
  function claimRefund() public {
    require(isFinalized);
    require(!goalReached());

    vault.refund(msg.sender);
  }

  // vault finalization task, called when owner calls finalize()
  function finalization() internal {
    if (goalReached()) { 
      vault.close();
    } else {
      vault.enableRefunds();
    }
    super.finalization();
  
  }

  /**
   * @dev Checks whether funding goal was reached. 
   * @return Whether funding goal was reached
   */
  function goalReached() public view returns (bool) {
    return weiRaised >= (goal - (5000 * 1 ether));
  }

  function getVaultAddress() onlyOwner public returns (address) {
    return vault;
  }
}

/**
 * @title EXTP Token
 * @author HamzaYasin1 - Github
 */


contract TradePlaceToken is MintableToken {

  string public constant name = "Trade PLace";
  string public constant symbol = "EXTP";
  uint8 public constant decimals = 18;
  uint256 public totalSupply = SafeMath.mul(500000000 , 1 ether); //500000000
}





contract TradePlaceCrowdsale is Crowdsale, CappedCrowdsale, RefundableCrowdsale, Allocations {
    /** Constructor TradePlaceCrowdsale */
    function TradePlaceCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, uint256 _cap, uint256 _goal, address _wallet)
    CappedCrowdsale(_cap)
    FinalizableCrowdsale()
    RefundableCrowdsale(_goal)
    Crowdsale(_startTime, _endTime, _rate, _wallet)
    {
    }

    /**TradePlaceToken Contract is generating from here */
    function createTokenContract() internal returns (MintableToken) {
        return new TradePlaceToken();
    }
}