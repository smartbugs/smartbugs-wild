pragma solidity ^0.4.18;

// ----------------------------------------------------------------------------
// RubleCoin TokenSale. version 1.0
//
// Enjoy. (c) Slava Brall / Begemot-Begemot Ltd 2018. The MIT Licence.
// ----------------------------------------------------------------------------
 
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
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
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
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
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
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
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

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
    totalSupply = totalSupply.add(_amount);
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

//Token parameters

contract NationalMoney is MintableToken{
	string public constant name = "National Money";
	string public constant symbol = "RUBC";
	uint public constant decimals = 2;

	
}

/**
 * @title BetonatorCoinCrowdsale
 * @dev BetonatorCoinCrowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to an owner
 * as they arrive.
 */
contract RubleCoinCrowdsale is Ownable {
  string public constant name = "National Money Contract";
  using SafeMath for uint256;

  // The token being sold
  MintableToken public token;

  uint256 public startTime = 0;
  uint256 public discountEndTime = 0;
  uint256 public endTime = 0;
  
  bool public isDiscount = true;
  bool public isRunning = false;
  
  address public fundAddress = 0;
  
  address public fundAddress2 = 0;

  // rate is how many ETH cost 10000 packs of 2500 RUBC. 
  //rate approximately equals 10000 * 400/ (ETH in RUB). It's always an integer!
  //for example if ETH costs 1100 USD, USD costs 56 RUB, and we want 2500 RUBC cost 400 RUB
  //2500 RUBC = 400 / (56 *1100) = 0,00649... so we should set rate = 65
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;
  
  string public contractStatus = "Not started";
  
  uint public tokensMinted = 0;
  
  uint public minimumSupply = 2500; //minimum token amount to sale at one transaction

  event TokenPurchase(address indexed purchaser, uint256 value, uint integer_value, uint256 amount, uint integer_amount, uint256 tokensMinted);


  function RubleCoinCrowdsale(uint256 _rate, address _fundAddress, address _fundAddress2) public {
    require(_rate > 0);
	require (_rate < 1000);

    token = createTokenContract();
    startTime = now;
	
    rate = _rate;
	fundAddress = _fundAddress;
	fundAddress2 = _fundAddress2;
	
	contractStatus = "Sale with discount";
	isDiscount = true;
	isRunning = true;
  }
  
  function setRate(uint _rate) public onlyOwner {
	  require (isRunning);

	  require (_rate > 0);
	  require (_rate <=1000);
	  rate = _rate;
  }
  
    function fullPriceStage() public onlyOwner {
	  require (isRunning);

	  isDiscount = false;
	  discountEndTime = now;
	  contractStatus = "Full price sale";
  }

    function finishCrowdsale() public onlyOwner {
	  require (isRunning);

	  isRunning = false;
	  endTime = now;
	  contractStatus = "Crowdsale is finished";
	  
  }

  function createTokenContract() internal returns (NationalMoney) {
    return new NationalMoney();
  }


  // fallback function can be used to buy tokens
  function () external payable {
	require(isRunning);
	
    buyTokens();
  }

  // low level token purchase function
  function buyTokens() public payable {
    require(validPurchase());
    require (isRunning);

    uint256 weiAmount = msg.value;

	uint minWeiAmount = rate.mul(10 ** 18).div(10000); // should be additional mul 10
	if (isDiscount) {
		minWeiAmount = minWeiAmount.mul(3).div(4);
	}
	
	uint tokens = weiAmount.mul(2500).div(minWeiAmount).mul(100);
	uint tokensToOwner = tokens.mul(11).div(10000);

    
    weiRaised = weiRaised.add(weiAmount);

    token.mint(msg.sender, tokens);
	token.mint(owner, tokensToOwner);
	
	tokensMinted = tokensMinted.add(tokens);
	tokensMinted = tokensMinted.add(tokensToOwner);
    TokenPurchase(msg.sender, weiAmount, weiAmount.div(10**14), tokens, tokens.div(10**2), tokensMinted);

    forwardFunds();
  }
  

  function forwardFunds() internal {
	uint toOwner = msg.value.div(100);
	uint toFund = msg.value.mul(98).div(100);
	
    owner.transfer(toOwner);
	fundAddress.transfer(toFund);
	fundAddress2.transfer(toOwner);
	
  }
  

  // @return true if the transaction can buy tokens
  function validPurchase() internal view returns (bool) {
    bool withinPeriod = startTime > 0;
	
	uint minAmount = (rate - 1).mul(10 ** 18).div(10000); //check the correctness!
	if (isDiscount) {
		minAmount = minAmount.mul(3).div(4);
	}
	bool validAmount = msg.value > minAmount;
		
    return withinPeriod && validAmount;
  }


}