pragma solidity ^0.4.19;

/**
 * Virtual Cash (VCA) Token 
 *
 * This is a very simple token with the following properties:
 *  - 20.000.000 tokens maximum supply
 *  - 15.000.000 crowdsale allocation
 *  - 5.000.000 initial supply to be use for Bonus, Airdrop, Marketing, Ads, Bounty, Future Dev, Reserved tokens
 *  - Investor receives bonus tokens from Company Wallet during bonus phases
 * 
 * Visit https://virtualcash.shop for more information and token holder benefits.
 */

	/**
	* @title SafeMath
	* @dev Math operations with safety checks that throw on error
	*/
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
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
	* @dev VCA_Token is StandardToken, Ownable
	*/
contract VCA_Token is StandardToken, Ownable {
  string public constant name = "Virtual Cash";
  string public constant symbol = "VCA";
  uint256 public constant decimals = 8;

  uint256 public constant UNIT = 10 ** decimals;

  address public companyWallet;
  address public admin;

  uint256 public tokenPrice = 0.00025 ether;
  uint256 public maxSupply = 20000000 * UNIT;
  uint256 public totalSupply = 0;
  uint256 public totalWeiReceived = 0;

  uint256 startDate  = 1517443260; //	12:01 GMT February 1 2018
  uint256 endDate    = 1522537260; //	12:00 GMT March 15 2018

  uint256 bonus35end = 1517702460; //	12:01 GMT February 4 2018
  uint256 bonus32end = 1517961660; //	12:01 GMT February 7 2018
  uint256 bonus29end = 1518220860; //	12:01 GMT February 10 2018
  uint256 bonus26end = 1518480060; //	12:01 GMT February 13 2018
  uint256 bonus23end = 1518825660; //	12:01 GMT February 17 2018
  uint256 bonus20end = 1519084860; //	12:01 GMT February 20 2018
  uint256 bonus17end = 1519344060; //	12:01 GMT February 23 2018
  uint256 bonus14end = 1519603260; //	12:01 GMT February 26 2018
  uint256 bonus11end = 1519862460; //	12:01 GMT March 1 2018
  uint256 bonus09end = 1520121660; //	12:01 GMT March 4 2018
  uint256 bonus06end = 1520380860; //	12:01 GMT March 7 2018
  uint256 bonus03end = 1520640060; //	12:01 GMT March 10 2018

	/**
	* event for token purchase logging
	* @param purchaser - who paid for the tokens
	* @param beneficiary - who got the tokens
	* @param value - weis paid for purchase
	* @param amount - amount of tokens purchased
	*/
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  event NewSale();

  modifier onlyAdmin() {
    require(msg.sender == admin);
    _;
  }

  function VCA_Token(address _companyWallet, address _admin) public {
    companyWallet = _companyWallet;
    admin = _admin;
    balances[companyWallet] = 5000000 * UNIT;
    totalSupply = totalSupply.add(5000000 * UNIT);
    Transfer(address(0x0), _companyWallet, 5000000 * UNIT);
  }

  function setAdmin(address _admin) public onlyOwner {
    admin = _admin;
  }

  function calcBonus(uint256 _amount) internal view returns (uint256) {
	              uint256 bonusPercentage = 35;
    if (now > bonus35end) bonusPercentage = 32;
    if (now > bonus32end) bonusPercentage = 29;
    if (now > bonus29end) bonusPercentage = 26;
    if (now > bonus26end) bonusPercentage = 23;
    if (now > bonus23end) bonusPercentage = 20;
    if (now > bonus20end) bonusPercentage = 17;
    if (now > bonus17end) bonusPercentage = 14;
    if (now > bonus14end) bonusPercentage = 11;
    if (now > bonus11end) bonusPercentage = 9;
    if (now > bonus09end) bonusPercentage = 6;
    if (now > bonus06end) bonusPercentage = 3;
    if (now > bonus03end) bonusPercentage = 0;
    return _amount * bonusPercentage / 100;
  }

  function buyTokens() public payable {
    require(now < endDate);
    require(now >= startDate);
    require(msg.value > 0);

    uint256 amount = msg.value * UNIT / tokenPrice;
    uint256 bonus = calcBonus(msg.value) * UNIT / tokenPrice;
    
    totalSupply = totalSupply.add(amount);
    
    require(totalSupply <= maxSupply);

    totalWeiReceived = totalWeiReceived.add(msg.value);

    balances[msg.sender] = balances[msg.sender].add(amount);
    
    TokenPurchase(msg.sender, msg.sender, msg.value, amount);
    
    Transfer(address(0x0), msg.sender, amount);

    if (bonus > 0) {
      Transfer(companyWallet, msg.sender, bonus);
      balances[companyWallet] -= bonus;
      balances[msg.sender] = balances[msg.sender].add(bonus);
    }

    companyWallet.transfer(msg.value);
  }

  function() public payable {
    buyTokens();
  }

	/***
	* This function is used to transfer tokens that have been bought through other means (credit card, bitcoin, etc), and to burn tokens after the sale.
	*/
  function sendTokens(address receiver, uint256 tokens) public onlyAdmin {
    require(now < endDate);
    require(now >= startDate);
    require(totalSupply + tokens * UNIT <= maxSupply);

    uint256 amount = tokens * UNIT;
    balances[receiver] += amount;
    totalSupply += amount;
    Transfer(address(0x0), receiver, amount);
  }

}