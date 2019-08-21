pragma solidity 0.4.24;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
    }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
  function safeTransfer(
    IERC20 token,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transfer(to, value));
  }

  function safeTransferFrom(
    IERC20 token,
    address from,
    address to,
    uint256 value
  )
    internal
  {
    require(token.transferFrom(from, to, value));
  }

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
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale,
 * allowing investors to purchase tokens with ether. This contract implements
 * such functionality in its most fundamental form and can be extended to provide additional
 * functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing tokens, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overridden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropriate to concatenate
 * behavior.
 */
contract Crowdsale is Ownable {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  // The token being sold
  IERC20 public _token;

  // Address where funds are collected
  address public _wallet;

  // How many token units a buyer gets per wei.
  // The rate is the conversion between wei and the smallest and indivisible token unit.
  // So, if you are using a rate of 1 with a ERC20Detailed token with 3 decimals called TOK
  // 1 wei will give you 1 unit, or 0.001 TOK.
  uint256 public _rate;

  // Amount of wei raised
  uint256 public _weiRaised;

  /**
   * Event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokensPurchased(
    address indexed purchaser,
    address indexed beneficiary,
    uint256 value,
    uint256 amount
  );

  /**
   * @param rate Number of token units a buyer gets per wei
   * @dev The rate is the conversion between wei and the smallest and indivisible
   * token unit. So, if you are using a rate of 1 with a ERC20Detailed token
   * with 3 decimals called TOK, 1 wei will give you 1 unit, or 0.001 TOK.
   * @param wallet Address where collected funds will be forwarded to
   * @param token Address of the token being sold
   */
  constructor(uint256 rate, address wallet, IERC20 token) public {
    require(rate > 0);
    require(wallet != address(0));
    require(token != address(0));

    _rate = rate;
    _wallet = wallet;
    _token = token;
  }

  // -----------------------------------------
  // Crowdsale external interface
  // -----------------------------------------

  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  function () external payable {
    buyTokens(msg.sender);
  }

  /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param beneficiary Address performing the token purchase
   */
  function buyTokens(address beneficiary) public payable {

    uint256 weiAmount = msg.value;
    _preValidatePurchase(beneficiary, weiAmount);

    // calculate token amount to be created
    uint256 tokens = _getTokenAmount(weiAmount);

    // update state
    _weiRaised = _weiRaised.add(weiAmount);

    _processPurchase(beneficiary, tokens);
    emit TokensPurchased(
      msg.sender,
      beneficiary,
      weiAmount,
      tokens
    );

    _updatePurchasingState(beneficiary, weiAmount);

    _forwardFunds();
    _postValidatePurchase(beneficiary, weiAmount);
  }

  // -----------------------------------------
  // Internal interface (extensible)
  // -----------------------------------------

  /**
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use `super` in contracts that inherit from Crowdsale to extend their validations.
   * Example from CappedCrowdsale.sol's _preValidatePurchase method:
   *   super._preValidatePurchase(beneficiary, weiAmount);
   *   require(weiRaised().add(weiAmount) <= cap);
   * @param beneficiary Address performing the token purchase
   * @param weiAmount Value in wei involved in the purchase
   */
  function _preValidatePurchase(
    address beneficiary,
    uint256 weiAmount
  )
    internal
  {
    require(beneficiary != address(0));
    require(weiAmount != 0);
  }

  /**
   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.
   * @param beneficiary Address performing the token purchase
   * @param weiAmount Value in wei involved in the purchase
   */
  function _postValidatePurchase(
    address beneficiary,
    uint256 weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.
   * @param beneficiary Address performing the token purchase
   * @param tokenAmount Number of tokens to be emitted
   */
  function _deliverTokens(
    address beneficiary,
    uint256 tokenAmount
  )
    internal
  {
    _token.transferFrom(owner,beneficiary, tokenAmount);
  }

  /**
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.
   * @param beneficiary Address receiving the tokens
   * @param tokenAmount Number of tokens to be purchased
   */
  function _processPurchase(
    address beneficiary,
    uint256 tokenAmount
  )
    internal
  {
    _deliverTokens(beneficiary, tokenAmount);
  }

  /**
   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)
   * @param beneficiary Address receiving the tokens
   * @param weiAmount Value in wei involved in the purchase
   */
  function _updatePurchasingState(
    address beneficiary,
    uint256 weiAmount
  )
    internal
  {
    // optional override
  }

  /**
   * @dev Override to extend the way in which ether is converted to tokens.
   * @param weiAmount Value in wei to be converted into tokens
   * @return Number of tokens that can be purchased with the specified _weiAmount
   */
  function _getTokenAmount(uint256 weiAmount)
    internal view returns (uint256)
  {
    return weiAmount.mul(_rate);
  }

  /**
   * @dev Determines how ETH is stored/forwarded on purchases.
   */
  function _forwardFunds() internal {
    _wallet.transfer(msg.value);
  }
}


/**
 * @title TimedCrowdsale
 * @dev Crowdsale accepting contributions only within a time frame.
 */
contract TimedCrowdsale is Crowdsale {
  using SafeMath for uint256;

  uint256 public _openingTime;
  uint256 public _closingTime;

  /**
   * @dev Reverts if not in crowdsale time range.
   */
  modifier onlyWhileOpen {
    require(isOpen());
    _;
  }

  /**
   * @dev Constructor, takes crowdsale opening and closing times.
   * @param openingTime Crowdsale opening time
   * @param closingTime Crowdsale closing time
   */
  constructor(uint256 openingTime, uint256 closingTime) public {
    // solium-disable-next-line security/no-block-members
    require(openingTime >= block.timestamp);
    require(closingTime >= openingTime);

    _openingTime = openingTime;
    _closingTime = closingTime;
  }


  /**
   * @return true if the crowdsale is open, false otherwise.
   */
  function isOpen() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return block.timestamp >= _openingTime && block.timestamp <= _closingTime;
  }

  /**
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.
   * @return Whether crowdsale period has elapsed
   */
  function hasClosed() public view returns (bool) {
    // solium-disable-next-line security/no-block-members
    return block.timestamp > _closingTime;
  }

  /**
   * @dev Extend parent behavior requiring to be within contributing period
   * @param beneficiary Token purchaser
   * @param weiAmount Amount of wei contributed
   */
  function _preValidatePurchase(
    address beneficiary,
    uint256 weiAmount
  )
    internal
    onlyWhileOpen
  {
    super._preValidatePurchase(beneficiary, weiAmount);
  }

}

/**
 * @title EscrowAccountCrowdsale.
 */
contract EscrowAccountCrowdsale is TimedCrowdsale {
  using SafeMath for uint256;
  EscrowVault public vault;
  /**
   * @dev Constructor, creates EscrowAccountCrowdsale.
   */
  function EscrowAccountCrowdsale() public {
    vault = new EscrowVault(_wallet);
  }
  /**
   * @dev Investors can claim refunds here if whitelisted is unsuccessful
   */
  function returnInvestoramount(address _beneficiary, uint256 _percentage) internal onlyOwner {
    vault.refund(_beneficiary);
  }

 /**
   * @dev Investors can claim refunds here if whitelisted is unsuccessful
   */
  function adminChargeForDebit(address _beneficiary, uint256 _adminCharge) internal onlyOwner {
    vault.debitForFailed(_beneficiary,_adminCharge);
  }

  function afterWhtelisted(address _beneficiary) internal onlyOwner{
      vault.closeAfterWhitelisted(_beneficiary);
  }
  
  function afterWhtelistedBuy(address _beneficiary) internal {
      vault.closeAfterWhitelisted(_beneficiary);
  }
  /**
   * @dev Overrides Crowdsale fund forwarding, sending funds to vault.
   */
  function _forwardFunds() internal {
    vault.deposit.value(msg.value)(msg.sender);
  }

}

/**
 * @title EscrowVault
 * @dev This contract is used for storing funds while a crowdsale
 * is in progress. Supports refunding the money if whitelist fails,
 * and forwarding it if whitelist is successful.
 */
contract EscrowVault is Ownable {
  using SafeMath for uint256;
  mapping (address => uint256) public deposited;
  address public wallet;
  event Closed();
  event Refunded(address indexed beneficiary, uint256 weiAmount);
  /**
   * @param _wallet Vault address
   */
  function EscrowVault(address _wallet) public {
    require(_wallet != address(0));
    wallet = _wallet;   
  }
  /**
   * @param investor Investor address
   */
  function deposit(address investor) onlyOwner  payable {
    deposited[investor] = deposited[investor].add(msg.value);
  }
  
  /**
   * @dev Transfers deposited amount to wallet address after verification is completed.
   * @param _beneficiary depositor address.
   */
  function closeAfterWhitelisted(address _beneficiary) onlyOwner public { 
    uint256 depositedValue = deposited[_beneficiary];
    deposited[_beneficiary] = 0;
    wallet.transfer(depositedValue);
  }
  
  /**
   * @param investor Investor address
   */
  function debitForFailed(address investor, uint256 _debit)public onlyOwner  {
     uint256 depositedValue = deposited[investor];
     depositedValue=depositedValue.sub(_debit);
     wallet.transfer(_debit);
     deposited[investor] = depositedValue;
  }
   
  /**
   * @dev 
   * @param investor Investor address
   */
  function refund(address investor)public onlyOwner  {
    uint256 depositedValue = deposited[investor];
    investor.transfer(depositedValue);
     emit Refunded(investor, depositedValue);
     deposited[investor] = 0;
  }
}

/**
 * @title PostDeliveryCrowdsale
 * @dev Crowdsale that locks tokens from withdrawal until it whitelisted and crowdsale ends.
 */
contract PostDeliveryCrowdsale is TimedCrowdsale {
  using SafeMath for uint256;

  mapping(address => uint256) public _balances;

  /**
   * @dev Withdraw tokens only after whitelisted ends and after crowdsale ends.
   */
  function withdrawTokens() public {
   require(hasClosed());
    uint256 amount = _balances[msg.sender];
    require(amount > 0);
    _balances[msg.sender] = 0;
    _deliverTokens(msg.sender, amount);
  }
  
   /**
    * @dev Debits token for the failed verification
    * @param _beneficiary address from which tokens debited
    * @param _token amount of tokens to be debited
    */
    
   function failedWhitelistForDebit(address _beneficiary,uint256 _token) internal  {
    require(_beneficiary != address(0));
    uint256 amount = _balances[_beneficiary];
    _balances[_beneficiary] = amount.sub(_token);
  }
  
   /**
    * @dev debits entire tokens after refund, if verification completely failed
    * @param _beneficiary address from which tokens debited
    */
   function failedWhitelist(address _beneficiary) internal  {
    require(_beneficiary != address(0));
    uint256 amount = _balances[_beneficiary];
    _balances[_beneficiary] = 0;
  }
  
  function getInvestorDepositAmount(address _investor) public constant returns(uint256 paid){
     return _balances[_investor];
  }

  /**
   * @dev Overrides parent by storing balances instead of issuing tokens right away.
   * @param _beneficiary Token purchaser
   * @param _tokenAmount Amount of tokens purchased
   */
  function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {
    _balances[_beneficiary] = _balances[_beneficiary].add(_tokenAmount);
  }

}


contract BitcoinageCrowdsale is TimedCrowdsale,EscrowAccountCrowdsale,PostDeliveryCrowdsale {

 enum Stage {KYC_FAILED, KYC_SUCCESS,AML_FAILED, AML_SUCCESS} 	
  //stage PreSale or PublicSale
  enum Phase {PRESALE, PUBLICSALE}
  //stage ICO
  Phase public phase;
 
  uint256 private constant DECIMALFACTOR = 10**uint256(18);
  uint256 public _totalSupply=200000000 * DECIMALFACTOR;
  uint256 public presale=5000000* DECIMALFACTOR;
  uint256 public publicsale=110000000* DECIMALFACTOR;
  uint256 public teamAndAdvisorsAndBountyAllocation = 12000000 * DECIMALFACTOR;
  uint256 public operatingBudgetAllocation = 5000000 * DECIMALFACTOR;
  uint256 public tokensVested = 28000000 * DECIMALFACTOR;
 
  struct whitelisted{
       Stage  stage;
 }
  uint256 public adminCharge=0.025 ether;
  uint256 public minContribAmount = 0.2 ether; // min invesment
  mapping(address => whitelisted) public whitelist;
  // How much ETH each address has invested to this crowdsale
  mapping (address => uint256) public investedAmountOf;
    // How many distinct addresses have invested
  uint256 public investorCount;
    // decimalFactor
 
  event updateRate(uint256 tokenRate, uint256 time);
  
   /**
 	* @dev BitcoinageCrowdsale is a base contract for managing a token crowdsale.
 	* BitcoinageCrowdsale have a start and end timestamps, where investors can make
 	* token purchases and the crowdsale will assign them tokens based
 	* on a token per ETH rate. Funds collected are forwarded to a wallet
 	* as they arrive.
 	*/
  
 function BitcoinageCrowdsale(uint256 _starttime, uint256 _endTime, uint256 _rate, address _wallet,IERC20 _token)
  TimedCrowdsale(_starttime,_endTime)Crowdsale(_rate, _wallet,_token)
  {
      phase = Phase.PRESALE;
  }
    
  /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
  function () external payable {
    buyTokens(msg.sender);
  }
  
  /**
   * @dev token purchased on sending ether
   * @param _beneficiary Address performing the token purchase
   */
  function buyTokens(address _beneficiary) public payable onlyWhileOpen{
    require(_beneficiary != address(0));
    require(validPurchase());
  
    uint256 weiAmount = msg.value;
    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(_rate);
     if(phase==Phase.PRESALE){
        assert(presale>=tokens);
        presale=presale.sub(tokens);
    }else{
        assert(publicsale>=tokens);
        publicsale=publicsale.sub(tokens);
    }
    
     _forwardFunds();
         _processPurchase(_beneficiary, tokens);
    if(investedAmountOf[msg.sender] == 0) {
           // A new investor
           investorCount++;
        }
        // Update investor
      investedAmountOf[msg.sender] = investedAmountOf[msg.sender].add(weiAmount);
        
      if(whitelist[_beneficiary].stage==Stage.AML_SUCCESS){
                afterWhtelistedBuy(_beneficiary);
      }
      
  }
   
    function validPurchase() internal constant returns (bool) {
    bool minContribution = minContribAmount <= msg.value;
    return  minContribution;
  }
  


 /**
   * @dev Reverts if beneficiary is not whitelisted. Can be used when extending this contract.
   */
  modifier isWhitelisted(address _beneficiary) {
    require(whitelist[_beneficiary].stage==Stage.AML_SUCCESS);
    _;
  }

  /**
   * @dev Adds single address to whitelist.
   * @param _beneficiary Address to be added to the whitelist
   */
  function addToWhitelist(address _beneficiary,uint256 _stage) external onlyOwner {
     require(_beneficiary != address(0));
     if(_stage==1){
         
         failedWhitelistForDebit(_beneficiary,_rate.mul(adminCharge));
         adminChargeForDebit(_beneficiary,adminCharge);
         whitelist[_beneficiary].stage=Stage.KYC_FAILED;
         uint256 value=investedAmountOf[_beneficiary];
         value=value.sub(adminCharge);
         investedAmountOf[_beneficiary]=value;
         
     }else if(_stage==2){
         
         whitelist[_beneficiary].stage=Stage.KYC_SUCCESS;
         
     }else if(_stage==3){
         
         whitelist[_beneficiary].stage=Stage.AML_FAILED;
         returnInvestoramount(_beneficiary,adminCharge);
         failedWhitelist(_beneficiary);
         investedAmountOf[_beneficiary]=0;
         
     }else if(_stage==4){
         
         whitelist[_beneficiary].stage=Stage.AML_SUCCESS;
         afterWhtelisted( _beneficiary); 
    
     }
  }
 
  /**
   * @dev Withdraw tokens only after Investors added into whitelist .
   */
  function withdrawTokens() public isWhitelisted(msg.sender)  {
    uint256 amount = _balances[msg.sender];
    require(amount > 0);
    _deliverTokens(msg.sender, amount);
    _balances[msg.sender] = 0;
  }
  
 /**
 * @dev Change crowdsale ClosingTime
 * @param  _endTime is End time in Seconds
 */
  function changeEndtime(uint256 _endTime) public onlyOwner {
    require(_endTime > 0); 
    _closingTime = _endTime;
  }
    
    /**
 * @dev Change crowdsale OpeningTime
 * @param  _startTime is End time in Seconds
 */
  function changeStarttime(uint256 _startTime) public onlyOwner {
    require(_startTime > 0); 
    _openingTime = _startTime;
  }
    
 /**
   * @dev Change Stage.
   * @param _rate for ETH Per Token
   */
  function changeStage(uint256 _rate) public onlyOwner {
     require(_rate>0);
     _rate=_rate;
     phase=Phase.PUBLICSALE;
  }

 /**
 * @dev Change Token rate per ETH
 * @param  _rate is set the current rate of AND Token
 */
  function changeRate(uint256 _rate) public onlyOwner {
    require(_rate > 0); 
    _rate = _rate;
    emit updateRate(_rate,block.timestamp);
  }
  
 /**
   * @dev Change adminCharge Amount.
   * @param _adminCharge for debit ETH amount
   */
  function changeAdminCharge(uint256 _adminCharge) public onlyOwner {
     require(_adminCharge > 0);
     adminCharge=_adminCharge;
  }
  
    
 /**
   * @dev transfer tokens to advisor and bounty team.
   * @param to for recipiant address
   * @param tokens is amount of tokens
   */
  
    function transferTeamAndAdvisorsAndBountyAllocation  (address to, uint256 tokens) public onlyOwner {
         require (
            to != 0x0 && tokens > 0 && teamAndAdvisorsAndBountyAllocation >= tokens
         );
        _deliverTokens(to, tokens);
         teamAndAdvisorsAndBountyAllocation = teamAndAdvisorsAndBountyAllocation.sub(tokens);
    }
     
     /**
   * @dev transfer vested tokens.
   * @param to for recipiant address
   * @param tokens is amount of tokens
   */
     
     function transferTokensVested(address to, uint256 tokens) public onlyOwner {
         require (
            to != 0x0 && tokens > 0 && tokensVested >= tokens
         );
        _deliverTokens(to, tokens);
         tokensVested = tokensVested.sub(tokens);
     }
     
      /**
   * @dev transfer tokens to operating team.
   * @param to for recipiant address
   * @param tokens is amount of tokens
   */
     
     function transferOperatingBudgetAllocation(address to, uint256 tokens) public onlyOwner {
         require (
            to != 0x0 && tokens > 0 && operatingBudgetAllocation >= tokens
         );
        _deliverTokens(to, tokens);
         operatingBudgetAllocation = operatingBudgetAllocation.sub(tokens);
     }
}