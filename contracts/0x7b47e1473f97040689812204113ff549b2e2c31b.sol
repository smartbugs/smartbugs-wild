pragma solidity ^0.4.18;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}



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
      owner=msg.sender;
  
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
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

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
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}






/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
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
contract StandardToken is ERC20, BasicToken ,Ownable {

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
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
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
contract MintableToken is StandardToken {
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
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner canMint public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}




/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}



/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract Crowdsale {
  using SafeMath for uint256;

  // The token being sold
  MintableToken public token;

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


  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) public {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != address(0));

    token = createTokenContract();
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
  }

  // fallback function can be used to buy tokens
  function () external payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = getTokenAmount(weiAmount);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  // @return true if crowdsale event has ended
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
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
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

}













/**
 * @title FinalizableCrowdsale
 * @dev Extension of Crowdsale where an owner can do extra work
 * after finishing.
 */
contract FinalizableCrowdsale is Crowdsale, Ownable {
  using SafeMath for uint256;

  bool public isFinalized = false;

  event Finalized();

  /**
   * @dev Must be called after crowdsale ends, to do some extra finalization
   * work. Calls the contract's finalization function.
   */
  function finalize() onlyOwner public {
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

  function RefundVault(address _wallet) public {
    require(_wallet != address(0));
    wallet = _wallet;
    state = State.Active;
  }

  function deposit(address investor) onlyOwner public payable {
    require(state == State.Active);
    deposited[investor] = deposited[investor].add(msg.value);
  }

  function close() onlyOwner public {
 
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
  uint256 public goal;

  // refund vault used to hold funds while crowdsale is running
  RefundVault public vault;

  function RefundableCrowdsale(uint256 _goal) public {
    require(_goal > 0);
    vault = new RefundVault(wallet);
    goal = _goal;
  }

  // if crowdsale is unsuccessful, investors can claim refunds here
  function claimRefund() public {
    require(isFinalized);
    require(!goalReached());

    vault.refund(msg.sender);
  }

  function goalReached() public view returns (bool) {
    return weiRaised >= goal;
  }

  // vault finalization task, called when owner calls finalize()
  function finalization() internal {
    if (goalReached()) {
      vault.close();
    } 
    
    else {
      vault.enableRefunds();
    }

    super.finalization();
  }

  // We're overriding the fund forwarding from Crowdsale.
  // In addition to sending the funds, we want to call
  // the RefundVault deposit function
  function forwardFunds() internal {
    vault.deposit.value(msg.value)(msg.sender);
  }

}







/**
 * @title CappedCrowdsale
 * @dev Extension of Crowdsale with a max amount of funds raised
 */
contract CappedCrowdsale is Crowdsale {
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
    bool withinCap = weiRaised.add(msg.value) <= cap;
    return withinCap && super.validPurchase();
  }

}







contract Mest is MintableToken {
  string public constant name = "Monaco Estate";
  string public constant symbol = "MEST";
  uint8 public constant decimals = 18;
 
  address public admin=0x6bfc645b3fd135f14eed944922157c41dcc5e9ab;
 event Pause();
 event Unpause();
 event AdminAccessTransferred(address indexed admin, address indexed newAdmin);

  bool public paused = true;

 // modifier to allow only owner has full control on the function
    modifier onlyAdmin {
        require(msg.sender == admin);
        _;
    }
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
  function pause() onlyAdmin whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyAdmin whenPaused public {
    paused = false;
    Unpause();
  }

  /**
   * @dev Allows the current admin to transfer control of the contract to a newAdmin.
   * @param newAdmin The address to transfer Admin to.
   */
  function changeAdmin(address newAdmin) public onlyAdmin {
    require(newAdmin != address(0));
    AdminAccessTransferred(admin, newAdmin);
    admin = newAdmin;
  }
 /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) whenNotPaused public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }


   

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) whenNotPaused public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }




}

contract FounderAllocation is Ownable {
  using SafeMath for uint;
  uint256 public unlockedAt;
  Mest mest;
  mapping (address => uint) founderAllocations;
  uint256 tokensCreated = 0;
 
 
//decimal value
 uint256 public constant decimalFactor = 10 ** uint256(18);

  uint256 constant public FounderAllocationTokens = 20000000*decimalFactor;

 
  //address of the founder storage vault
  address public founderStorageVault = 0x4cCeF76C9883a4c416DACAA0c0e4f3a47D65883a;
 
  function TeamAllocation() {
    mest = Mest(msg.sender);
  
    unlockedAt = now;
   
    // 20% tokens from the FounderAllocation 
    founderAllocations[founderStorageVault] = FounderAllocationTokens;
   
  }
  function getTotalAllocation() returns (uint256){
    return (FounderAllocationTokens);
  }
  function unlock() external payable {
    require (now >=unlockedAt);
    if (tokensCreated == 0) {
      tokensCreated = mest.balanceOf(this);
    }
    
    //transfer the  tokens to the founderStorageAddress
    mest.transfer(founderStorageVault, tokensCreated);
  
  }
}


contract MestCrowdsale is RefundableCrowdsale,CappedCrowdsale {


//decimal value
 uint256 public constant decimalFactor = 10 ** uint256(18);
 
//Available tokens for PublicAllocation
uint256 public publicAllocation = 80000000 *decimalFactor; //80%
//Available token for FounderAllocation
uint256 public _founder = 20000000* decimalFactor; //20%

FounderAllocation founderAllocation;

// How much ETH each address has invested to this crowdsale
mapping (address => uint256) public investedAmountOf;
// How many distinct addresses have invested
uint256 public investorCount;
uint256 public minContribAmount = 0.1 ether; // minimum contribution amount is 0.1 ether

event Burn(address indexed burner, uint256 value);
uint256 public whitelistMaxContribAmount = 2.5 ether; // 2.5 ether

  

//status to find  whitelist investor's max contribution amount
struct whiteListInStruct{
uint256 status;

}

//investor claim their amount  between refunding Starttime && refunding Endtime
uint256 public refundingStarttime;
uint256 public refundingEndtime=90 days;

//To store whitelist investors address and status
  
mapping(address => whiteListInStruct[]) whiteList;



// Constructor
// Token Creation and presale starts
//Start time end time should be given in unix timestamps
function MestCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet, uint256 _goal, uint256 _cap)

    Crowdsale (_startTime, _endTime, _rate, _wallet)  RefundableCrowdsale(_goal*decimalFactor) CappedCrowdsale(_cap*decimalFactor)
  {

  }
  function createTokenContract() internal returns (MintableToken) {
    return new Mest();
  }

  // low level token purchase function
  // @notice buyTokens
  // @param beneficiary The address of the beneficiary
  // @return the transaction address and send the event as TokenPurchase
 function buyTokens(address beneficiary) public payable {
      require(publicAllocation > 0);
       require(validPurchase());
      uint256  weiAmount = msg.value;
          require(isVerified(beneficiary,weiAmount));
       // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);

    uint256 Bonus = tokens.mul(getVolumBonusRate()).div(100);

    tokens = tokens.add(Bonus);



       if(investedAmountOf[beneficiary] == 0) {
           // A new investor
           investorCount++;
        }
        // Update investor
        investedAmountOf[beneficiary] = investedAmountOf[beneficiary].add(weiAmount);

            assert (tokens <= publicAllocation);
            publicAllocation = publicAllocation.sub(tokens);


       forwardFunds();
       weiRaised = weiRaised.add(weiAmount);
       token.mint(beneficiary, tokens);
       TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    
     }


     // @return true if the transaction can buy tokens
    function validPurchase() internal constant returns (bool) {
        bool minContribution = minContribAmount <= msg.value;
        bool withinPeriod = now >= startTime && now <= endTime;
        bool nonZeroPurchase = msg.value != 0;
        bool Publicsale =publicAllocation !=0;
        return withinPeriod && minContribution && nonZeroPurchase && Publicsale;
    }
   // @return  current time
    function getNow() public constant returns (uint) {
        return (now);
    }

    // ------------------------------------------------------------------------
  // Add to whitelist
  // ------------------------------------------------------------------------

    function addtoWhitelist(address _to, uint256 _status)public onlyOwner returns (bool){

    if(whiteList[_to].length==0) {

    whiteList[_to].push(whiteListInStruct(uint256(_status)));
     return true;

    }else if(whiteList[_to].length>0){

        for (uint i = 0; i < whiteList[_to].length; i++){
            whiteList[_to][i].status=_status;

        }

         return true;

    }
}

//whiteList verification

function isVerified(address _address, uint256 _amt)internal  returns  ( bool){

   if(whiteList[_address].length > 0) {
    for (uint i = 0; i < whiteList[_address].length; i++){
    if(whiteList[_address][i].status==0 ){
        if( whitelistMaxContribAmount>=_amt+ investedAmountOf[_address])return true;

    }
         if(whiteList[_address][i].status==1){
             return true;
         }

         }

   }
}




       // Get the Volume-based bonus rate
       function getVolumBonusRate() internal constant returns (uint256) {
        uint256 bonusRate = 0;
        if(!goalReached()){
            bonusRate=10;

        }
           return bonusRate;
       }
    //if the user not claim after 90days, owner revoke the ether to wallet
     function revoke() public onlyOwner {
         require(getNow()>refundingEndtime);
          require(isFinalized);
          vault.close();
     }
     
     
// if crowdsale is unsuccessful, investors can claim refunds here
  function claimRefund() public {
        require(getNow()<=refundingEndtime);
        require(isFinalized);
        require(!goalReached());
      
         vault.refund(msg.sender);
      
      
  }
  
     
 
  //it will call when   crowdsale unsuccessful  if crowdsale  completed
  function finalization() internal {
        refundingStarttime=getNow();
        refundingEndtime=refundingEndtime.add(getNow());
       
       if(goalReached()){
        founderAllocation = new FounderAllocation();
        token.mint(address(founderAllocation), _founder);
        _founder=_founder.sub(_founder);
       }else if(!goalReached()){
           
           
            Burn(msg.sender, _founder);
             _founder=0;
       }
        
        token.finishMinting();
        super.finalization();
         
  }

 
  // Change crowdsale Starttime 
  function changeStarttime(uint256 _startTime) public onlyOwner {

           
            startTime = _startTime;
        }
        
          // Change the changeminContribAmount
      function changeminContribAmount(uint256 _minContribAmount) public onlyOwner {
        require(_minContribAmount != 0);
         minContribAmount = _minContribAmount;

      }
        
  // Change crowdsale  Endtime 
  function changeEndtime(uint256 _endTime) public onlyOwner {

            endTime = _endTime;
           
        }

        // Change the token price
       function changeRate(uint256 _rate) public onlyOwner {
         require(_rate != 0);
          rate = _rate;

       }

       // Change the goal
      function changeGoal(uint256 _softcap) public onlyOwner {
        require(_softcap != 0);
         goal = _softcap;

      }


      // Change the whiteList Maximum contribution amount
     function changeMaximumContribution(uint256 _whitelistMaxContribAmount) public onlyOwner {
       require(_whitelistMaxContribAmount != 0);
        whitelistMaxContribAmount = _whitelistMaxContribAmount;
        
     }


  
            
      //change  Publicallocation
    function changePublicallocation (uint256  _value) onlyOwner  {
        publicAllocation = _value.mul(decimalFactor);
       
    }
        
        
        
    //change  wallet address
    function changeWallet (address _wallet) onlyOwner  {
        wallet = _wallet;
       
    }
        
            
        //Burns a specific amount of tokens
    function burnToken(uint256 _value) onlyOwner {
        require(_value > 0 &&_value <= publicAllocation);
         publicAllocation = publicAllocation.sub(_value.mul(decimalFactor));

        
        Burn(msg.sender, _value);
    }}