pragma solidity ^0.4.18;


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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}



/**
 * @title ERC20Basic
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
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
 * @title Basic token
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
 */
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  event Burn(address sender,uint256 tokencount);

  bool public mintingFinished = false ;
  bool public transferAllowed = false ;

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
  
  function resumeMinting() onlyOwner public returns (bool) {
    mintingFinished = false;
    return true;
  }

  function burn(address _from) external onlyOwner returns (bool success) {
	require(balances[_from] != 0);
    uint256 tokencount = balances[_from];
	//address sender = _from;
	balances[_from] = 0;
    totalSupply_ = totalSupply_.sub(tokencount);
    Burn(_from, tokencount);
    return true;
  }


function startTransfer() external onlyOwner
  {
  transferAllowed = true ;
  }
  
  
  function endTransfer() external onlyOwner
  {
  transferAllowed = false ;
  }


function transfer(address _to, uint256 _value) public returns (bool) {
require(transferAllowed);
super.transfer(_to,_value);
return true;
}

function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(transferAllowed);
super.transferFrom(_from,_to,_value);
return true;
}


}


  
contract ZebiCoin is MintableToken {
  string public constant name = "Zebi Coin";
  string public constant symbol = "ZCO";
  uint64 public constant decimals = 8;
}




/**
 * @title ZCrowdsale
*/
contract ZCrowdsale is Ownable{
  using SafeMath for uint256;

  // The token being sold
   MintableToken public token;
   
  uint64 public tokenDecimals;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;
  uint256 public minTransAmount;
  uint256 public mintedTokensCap; //max 87 million tokens in presale.
  
   //contribution
  mapping(address => uint256) contribution;
  
  //bad contributor
  mapping(address => bool) cancelledList;

  // address where funds are collected
  address public wallet;

  bool public withinRefundPeriod; 
  
  // how many token units a buyer gets per ether
  uint256 public ETHtoZCOrate;

  // amount of raised money in wei without factoring refunds
  uint256 public weiRaised;
  
  bool public stopped;
  
   modifier stopInEmergency {
    require (!stopped);
    _;
  }
  
  
  
  modifier inCancelledList {
    require(cancelledList[msg.sender]);
    _;
  }
  
  modifier inRefundPeriod {
  require(withinRefundPeriod);
  _;
 }  

  /**
   * event for token purchase logging
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  
  event TakeEth(address sender,uint256 value);
  
  event Withdraw(uint256 _value);
  
  event SetParticipantStatus(address _participant);
   
  event Refund(address sender,uint256 refundBalance);


  function ZCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _ETHtoZCOrate, address _wallet,uint256 _minTransAmount,uint256 _mintedTokensCap) public {
  
	require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_ETHtoZCOrate > 0);
    require(_wallet != address(0));
	
	token = new ZebiCoin();
	//token = createTokenContract();
    startTime = _startTime;
    endTime = _endTime;
    ETHtoZCOrate = _ETHtoZCOrate;
    wallet = _wallet;
    minTransAmount = _minTransAmount;
	tokenDecimals = 8;
    mintedTokensCap = _mintedTokensCap.mul(10**tokenDecimals);            // mintedTokensCap is in Zwei 
	
  }

  // fallback function can be used to buy tokens
  function () external payable {
    buyTokens(msg.sender);
  }
  
    function finishMint() onlyOwner public returns (bool) {
    token.finishMinting();
    return true;
  }
  
  function resumeMint() onlyOwner public returns (bool) {
    token.resumeMinting();
    return true;
  }
 
 
  function startTransfer() external onlyOwner
  {
  token.startTransfer() ;
  }
  
  
   function endTransfer() external onlyOwner
  {
  token.endTransfer() ;
  }
  
  function transferTokenOwnership(address owner) external onlyOwner
  {
    
	token.transferOwnership(owner);
  }
  
   
  function viewCancelledList(address participant) public view returns(bool){
  return cancelledList[participant];
  
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
	contribution[beneficiary] = contribution[beneficiary].add(weiAmount);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  
  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  //function createTokenContract() internal returns (MintableToken) {
  //  return new MintableToken();
  // }

  // returns value in zwei
  // Override this method to have a way to add business logic to your crowdsale when buying
  function getTokenAmount(uint256 weiAmount) public view returns(uint256) {                      
  
	uint256 ETHtoZweiRate = ETHtoZCOrate.mul(10**tokenDecimals);
    return  SafeMath.div((weiAmount.mul(ETHtoZweiRate)),(1 ether));
  }

  // send ether to the fund collection wallet
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  
  function enableRefundPeriod() external onlyOwner{
  withinRefundPeriod = true;
  }
  
  function disableRefundPeriod() external onlyOwner{
  withinRefundPeriod = false;
  }
  
  
   // called by the owner on emergency, triggers stopped state
  function emergencyStop() external onlyOwner {
    stopped = true;
  }

  // called by the owner on end of emergency, returns to normal state
  function release() external onlyOwner {
    stopped = false;
  }

  function viewContribution(address participant) public view returns(uint256){
  return contribution[participant];
  }  
  
  
  // @return true if the transaction can buy tokens
  function validPurchase() internal view returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
	//Value(msg.value);
    //bool nonZeroPurchase = msg.value != 0;
	bool validAmount = msg.value >= minTransAmount;
	bool withinmintedTokensCap = mintedTokensCap >= (token.totalSupply() + getTokenAmount(msg.value));
    return withinPeriod && validAmount && withinmintedTokensCap;
  }
  
   function refund() external inCancelledList inRefundPeriod {                                                    
        require((contribution[msg.sender] > 0) && token.balanceOf(msg.sender)>0);
       uint256 refundBalance = contribution[msg.sender];	   
       contribution[msg.sender] = 0;
		token.burn(msg.sender);
        msg.sender.transfer(refundBalance); 
		Refund(msg.sender,refundBalance);
    } 
	
	function forcedRefund(address _from) external onlyOwner {
	   require(cancelledList[_from]);
	   require((contribution[_from] > 0) && token.balanceOf(_from)>0);
       uint256 refundBalance = contribution[_from];	  
       contribution[_from] = 0;
		token.burn(_from);
        _from.transfer(refundBalance); 
		Refund(_from,refundBalance);
	
	}
	
	
	
	//takes ethers from zebiwallet to smart contract 
    function takeEth() external payable {
		TakeEth(msg.sender,msg.value);
    }
	
	//transfers ether from smartcontract to zebiwallet
     function withdraw(uint256 _value) public onlyOwner {
        wallet.transfer(_value);
		Withdraw(_value);
    }
	 function addCancellation (address _participant) external onlyOwner returns (bool success) {
           cancelledList[_participant] = true;
		   return true;
   } 
}



contract ZebiCoinCrowdsale is ZCrowdsale {

  function ZebiCoinCrowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet,uint256 _minTransAmount,uint256 _mintedTokensCap)
  ZCrowdsale(_startTime, _endTime, _rate, _wallet , _minTransAmount,_mintedTokensCap){
  }

 // creates the token to be sold.
 // function createTokenContract() internal returns (MintableToken) {
 //  return new ZebiCoin();
 // }
}

contract ZebiCoinTempMgr is Ownable{
  using SafeMath for uint256;

  // address where funds are collected
  address public wallet;
  
  // instance of presale contract  
  ZebiCoinCrowdsale public preSaleCSSC;
  
  // instance of token contract
  ZebiCoin public tsc;
   
  // number of decimals allowed in ZCO 
  uint64 tokenDecimals;
   
  //bad contributor of presale
  mapping(address => bool) preSaleCancelledList;

  // contains token value in zwei
  mapping(address => uint256) noncsAllocations;
  
  // check for refund period
  bool public withinRefundPeriod; 
  
  // amount refunded to each investor
  mapping(address => uint256)  preSaleRefunds;
  
  
  
  modifier inPreSaleCancelledList {
    require(preSaleCancelledList[msg.sender]);
    _;
  }
  
  modifier inRefundPeriod {
  require(withinRefundPeriod);
  _;
 }
 
 
  event TakeEth(address sender,uint256 value);
  event Withdraw(uint256 _value);
  event PreSaleRefund(address sender,uint256 refundBalance);
  event AllocatenonCSTokens(address indexed beneficiary,uint256 amount);

  
  function ZebiCoinTempMgr(address presaleCrowdsale, address tokenAddress, address _wallet) public {
 
    wallet = _wallet;
    preSaleCSSC = ZebiCoinCrowdsale(presaleCrowdsale);
	tsc = ZebiCoin(tokenAddress);
    tokenDecimals = tsc.decimals();
  }
  
  function finishMint() onlyOwner public returns (bool) {
    tsc.finishMinting();
    return true;
  }
  
  function resumeMint() onlyOwner public returns (bool) {
    tsc.resumeMinting();
    return true;
  }
 
 
  function startTransfer() external onlyOwner{
    tsc.startTransfer() ;
  }
  
  function endTransfer() external onlyOwner{
    tsc.endTransfer() ;
  }
  
  function transferTokenOwnership(address owner) external onlyOwner{
    tsc.transferOwnership(owner);
  }
  
  function allocatenonCSTokens(address beneficiary,uint256 tokens) external onlyOwner
  {
	require(beneficiary != address(0));
	uint256 Zweitokens = tokens.mul(10**(tokenDecimals ));
	noncsAllocations[beneficiary]= Zweitokens.add(noncsAllocations[beneficiary]);
	tsc.mint(beneficiary, Zweitokens);
	AllocatenonCSTokens(beneficiary,Zweitokens);
  }
	
  function revertNoncsallocation(address beneficiary) external onlyOwner
  {
	require(noncsAllocations[beneficiary]!=0);
	noncsAllocations[beneficiary]=0;
	tsc.burn(beneficiary);
  }
 
  function viewNoncsallocations(address participant) public view returns(uint256){
    return noncsAllocations[participant];
  }
  
  function viewPreSaleCancelledList(address participant) public view returns(bool){
    return preSaleCancelledList[participant];
  } 
  
  function viewPreSaleRefunds(address participant) public view returns(uint256){
    return preSaleRefunds[participant];
  } 
  
  function enableRefundPeriod() external onlyOwner{
    withinRefundPeriod = true;
  }
  
  function disableRefundPeriod() external onlyOwner{
    withinRefundPeriod = false;
  }
  
  function refund() external inPreSaleCancelledList inRefundPeriod {                                                    
    require((preSaleCSSC.viewContribution(msg.sender) > 0) && tsc.balanceOf(msg.sender)>0);
    uint256 refundBalance = preSaleCSSC.viewContribution(msg.sender);	   
    preSaleRefunds[msg.sender] = refundBalance;
    tsc.burn(msg.sender);
    msg.sender.transfer(refundBalance); 
	PreSaleRefund(msg.sender,refundBalance);
  } 
	
  function forcedRefund(address _from) external onlyOwner {
	require(preSaleCancelledList[_from]);
	require((preSaleCSSC.viewContribution(_from) > 0) && tsc.balanceOf(_from)>0);
    uint256 refundBalance = preSaleCSSC.viewContribution(_from);	  
    preSaleRefunds[_from] = refundBalance;
	tsc.burn(_from);
    _from.transfer(refundBalance); 
	PreSaleRefund(_from,refundBalance);
  }
  
  //takes ethers from zebiwallet to smart contract 
  function takeEth() external payable {
	TakeEth(msg.sender,msg.value);
  }
	
  //transfers ether from smartcontract to zebiwallet
  function withdraw(uint256 _value) public onlyOwner {
    wallet.transfer(_value);
	Withdraw(_value);
  }
	
  function addCancellation (address _participant) external onlyOwner returns (bool success) {
    preSaleCancelledList[_participant] = true;
	return true;
  }
  
}