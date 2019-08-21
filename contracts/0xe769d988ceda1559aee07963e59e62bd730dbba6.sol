pragma solidity ^0.4.16;

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
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
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
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

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
  function transfer(address _to, uint256 _value) returns (bool) {
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
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

   mapping (address => mapping (address => uint256)) allowed;


   /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amout of tokens to be transfered
    */
   function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
     var _allowance = allowed[_from][msg.sender];

     // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
     // require (_value <= _allowance);

     balances[_to] = balances[_to].add(_value);
     balances[_from] = balances[_from].sub(_value);
     allowed[_from][msg.sender] = _allowance.sub(_value);
     Transfer(_from, _to, _value);
     return true;
   }

   /**
    * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
   function approve(address _spender, uint256 _value) returns (bool) {

     // To change the approve amount you first have to reduce the addresses`
     //  allowance to zero by calling `approve(_spender, 0)` if it is not
     //  already 0 to mitigate the race condition described here:
     //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     require((_value == 0) || (allowed[msg.sender][_spender] == 0));

     allowed[msg.sender][_spender] = _value;
     Approval(msg.sender, _spender, _value);
     return true;
   }

   /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will spend the funds.
    * @return A uint256 specifing the amount of tokens still avaible for the spender.
    */
   function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
     return allowed[_owner][_spender];
   }

 }

contract MintableToken is StandardToken, Ownable {
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will recieve the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Transfer(0X0, _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}

contract WisePlat is MintableToken {
  string public name = "WisePlat Token";
  string public symbol = "WISE";
  uint256 public decimals = 18;
  address public bountyWallet = 0x0;

  bool public transferStatus = false;

  /**
   * @dev modifier that throws if trading has not started yet
   */
  modifier hasStartedTransfer() {
    require(transferStatus || msg.sender == bountyWallet);
    _;
  }

  /**
   * @dev Allows the owner to enable transfer.
   */
  function startTransfer() public onlyOwner {
    transferStatus = true;
  }
  /**
   * @dev Allows the owner to stop transfer.
   */
  function stopTransfer() public onlyOwner {
    transferStatus = false;
  }

  function setbountyWallet(address _bountyWallet) public onlyOwner {
    bountyWallet = _bountyWallet;
  }

  /**
   * @dev Allows anyone to transfer the WISE tokens once transfer has started
   * @param _to the recipient address of the tokens.
   * @param _value number of tokens to be transfered.
   */
  function transfer(address _to, uint _value) hasStartedTransfer returns (bool){
    return super.transfer(_to, _value);
  }

  /**
   * @dev Allows anyone to transfer the WISE tokens once transfer has started
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint _value) hasStartedTransfer returns (bool){
    return super.transferFrom(_from, _to, _value);
  }
}

contract WisePlatSale is Ownable {
  using SafeMath for uint256;

  // The token being offered
  WisePlat public token;

  // start and end block where investments are allowed (both inclusive)
  uint256 public constant startTimestamp	= 1509274800;		//Pre-ICO start						2017/10/29 @ 11:00:00 (UTC)
  uint256 public constant middleTimestamp	= 1511607601;		//Pre-ICO finish and ICO start		2017/11/25 @ 11:00:01 (UTC)
  uint256 public constant endTimestamp		= 1514764799;		//ICO finish						2017/12/31 @ 23:59:59 (UTC)

  // address where funds are collected
  address public constant devWallet 		= 0x00d6F1eA4238e8d9f1C33B7500CB89EF3e91190c;
  address public constant proWallet 		= 0x6501BDA688e8AC6C9cD96dc2DFBd6bDF3e886C05;
  address public constant bountyWallet 		= 0x354FFa86F138883b880C282000B5005E867E8eE4;
  address public constant remainderWallet	= 0x656C64D5C8BADe2a56A564B12706eE89bbe486EA;
  address public constant fundsWallet		= 0x06D49e8aA90b1413A641D69c6B8AC154f5c9FE92;
 
  // how many token units a buyer gets per wei
  uint256 public rate						= 10;
  uint256 public constant ratePreICO		= 20;	//on Pre-ICO it is 20 WISE for 1 ETH
  uint256 public constant rateICO			= 15;	//on ICO it is 15 WISE for 1 ETH
  
  // amount of raised money in wei
  uint256 public weiRaised;

  // minimum contribution to participate in token offer
  uint256 public constant minContribution 		= 0.1 ether;
  uint256 public constant minContribution_mBTC 	= 10;
  uint256 public rateBTCxETH 					= 17;

  // WISE tokens
  uint256 public constant tokensTotal		=	 10000000 * 1e18;		//WISE Total tokens				10,000,000.00
  uint256 public constant tokensCrowdsale	=	  7000000 * 1e18;		//WISE tokens for Crowdsale		 7,000,000.00
  uint256 public constant tokensDevelopers  =	  1900000 * 1e18;		//WISE tokens for Developers	 1,900,000.00
  uint256 public constant tokensPromotion	=	  1000000 * 1e18;		//WISE tokens for Promotion		 1,000,000.00
  uint256 public constant tokensBounty      = 	   100000 * 1e18;		//WISE tokens for Bounty		   100,000.00
  uint256 public tokensRemainder;  
  
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  event TokenClaim4BTC(address indexed purchaser_evt, address indexed beneficiary_evt, uint256 value_evt, uint256 amount_evt, uint256 btc_evt, uint256 rateBTCxETH_evt);
  event SaleClosed();

  function WisePlatSale() {
    token = new WisePlat();
	token.mint(devWallet, tokensDevelopers);
	token.mint(proWallet, tokensPromotion);
	token.mint(bountyWallet, tokensBounty);
	token.setbountyWallet(bountyWallet);		//allow transfer for bountyWallet
    require(startTimestamp >= now);
    require(endTimestamp >= startTimestamp);
  }

  // check if valid purchase
  modifier validPurchase {
    require(now >= startTimestamp);
    require(now <= endTimestamp);
    require(msg.value >= minContribution);
    require(tokensTotal > token.totalSupply());
    _;
  }
  // check if valid claim for BTC
  modifier validPurchase4BTC {
    require(now >= startTimestamp);
    require(now <= endTimestamp);
    require(tokensTotal > token.totalSupply());
    _;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    bool timeLimitReached = now > endTimestamp;
    bool allOffered = tokensTotal <= token.totalSupply();
    return timeLimitReached || allOffered;
  }

  // low level token purchase function
  function buyTokens(address beneficiary) payable validPurchase {
    require(beneficiary != 0x0);

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
	if (now < middleTimestamp) {rate = ratePreICO;} else {rate = rateICO;}
    uint256 tokens = weiAmount.mul(rate);
    
	require(token.totalSupply().add(tokens) <= tokensTotal);
	
    // update state
    weiRaised = weiRaised.add(weiAmount);
    
    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);
    fundsWallet.transfer(msg.value);	//transfer funds to fundsWallet
  }
  
  //claim tokens buyed for mBTC
  function claimTokens4mBTC(address beneficiary, uint256 mBTC) validPurchase4BTC public onlyOwner {
    require(beneficiary != 0x0);
	require(mBTC >= minContribution_mBTC);

	//uint256 _BTC = mBTC.div(1000);			//convert mBTC	to BTC
	//uint256 _ETH = _BTC.mul(rateBTCxETH);		//convert BTC	to ETH
    //uint256 weiAmount = _ETH * 1e18;			//convert ETH	to wei
	uint256 weiAmount = mBTC.mul(rateBTCxETH) * 1e15;	//all convert in one line mBTC->BTC->ETH->wei

    // calculate token amount to be created
	if (now < middleTimestamp) {rate = ratePreICO;} else {rate = rateICO;}
    uint256 tokens = weiAmount.mul(rate);
    
	require(token.totalSupply().add(tokens) <= tokensTotal);
	
    // update state
    weiRaised = weiRaised.add(weiAmount);
    
    token.mint(beneficiary, tokens);
    TokenClaim4BTC(msg.sender, beneficiary, weiAmount, tokens, mBTC, rateBTCxETH);
    //fundsWallet.transfer(msg.value);	//transfer funds to fundsWallet	- already should be transfered to BTC wallet
  }

  // to enable transfer
  function startTransfers() public onlyOwner {
	token.startTransfer();
  }
  
  // to stop transfer
  function stopTransfers() public onlyOwner {
	token.stopTransfer();
  }
  
  // to correct exchange rate ETH for BTC
  function correctExchangeRateBTCxETH(uint256 _rateBTCxETH) public onlyOwner {
	require(_rateBTCxETH != 0);
	rateBTCxETH = _rateBTCxETH;
  }
  
  // finish mining coins and transfer ownership of WISE token to owner
  function finishMinting() public onlyOwner {
    require(hasEnded());
    uint issuedTokenSupply = token.totalSupply();			
	tokensRemainder = tokensTotal.sub(issuedTokenSupply);
	if (tokensRemainder > 0) {token.mint(remainderWallet, tokensRemainder);}
    token.finishMinting();
    token.transferOwnership(owner);
    SaleClosed();
  }

  // fallback function can be used to buy tokens
  function () payable {
    buyTokens(msg.sender);
  }
  
  /**
  * @dev Reclaim all ERC20Basic compatible tokens
  * @param tokenAddr address The address of the token contract
  */
  function reclaimToken(address tokenAddr) external onlyOwner {
	require(!isTokenOfferedToken(tokenAddr));
    ERC20Basic tokenInst = ERC20Basic(tokenAddr);
    uint256 balance = tokenInst.balanceOf(this);
    tokenInst.transfer(msg.sender, balance);
  }
  function isTokenOfferedToken(address tokenAddr) returns(bool) {
        return token == tokenAddr;
  }
 
}