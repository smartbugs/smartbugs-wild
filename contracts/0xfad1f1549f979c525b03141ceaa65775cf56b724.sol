/*************************************************************************
 * This contract has been merged with solidify
 * https://github.com/tiesnetwork/solidify
 *************************************************************************/
 
 pragma solidity ^0.4.11;

/*************************************************************************
 * import "./StandardToken.sol" : start
 *************************************************************************/


/*************************************************************************
 * import "./SafeMath.sol" : start
 *************************************************************************/


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b)  constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b)  constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b)  constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b)  constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
/*************************************************************************
 * import "./SafeMath.sol" : end
 *************************************************************************/


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken {

  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Transfer(address indexed from, address indexed to, uint256 value);

  uint256 public totalSupply;

  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  event Pause();
  event Unpause();

  bool public paused = false;

  using SafeMath for uint256;

  mapping (address => mapping (address => uint256)) internal allowed;
  mapping(address => uint256) balances;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function StandardToken() {
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

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value)  public whenNotPaused returns (bool) {
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

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value)  public whenNotPaused returns (bool) {
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
   * Beware - changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value)  public whenNotPaused returns (bool) {
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
  function increaseApproval (address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
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
/*************************************************************************
 * import "./StandardToken.sol" : end
 *************************************************************************/

contract CoinsOpenToken is StandardToken
{


  // Token informations
  string public constant name = "COT";
  string public constant symbol = "COT";
  uint8 public constant decimals = 18;

  uint public totalSupply = 23000000000000000000000000;
  uint256 public presaleSupply = 2000000000000000000000000;
  uint256 public saleSupply = 13000000000000000000000000;
  uint256 public reserveSupply = 8000000000000000000000000;

  uint256 public saleStartTime = 1511136000; /* Monday, November 20, 2017 12:00:00 AM */
  uint256 public saleEndTime = 1513728000; /* Wednesday, December 20, 2017 12:00:00 AM */
  uint256 public preSaleStartTime = 1508457600; /* Friday, October 20, 2017 12:00:00 AM */
  uint256 public developerLock = 1500508800;

  uint256 public totalWeiRaised = 0;

  uint256 public preSaleTokenPrice = 1400;
  uint256 public saleTokenPrice = 700;

  mapping (address => uint256) lastDividend;
  mapping (uint256 =>uint256) dividendList;
  uint256 currentDividend = 0;
  uint256 dividendAmount = 0;

  struct BuyOrder {
      uint256 wether;
      address receiver;
      address payer;
      bool presale;
  }

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount, bool presale);

  /**
   * event for notifying of a Ether received to distribute as dividend
   * @param amount of dividend received
   */
  event DividendAvailable(uint amount);

  /**
   * event triggered when sending dividend to owner
   * @param receiver who is receiving the payout
   * @param amountofether paid received
   */
  event SendDividend(address indexed receiver, uint amountofether);

  function() payable {
    if (msg.sender == owner) {
      giveDividend();
    } else {
      buyTokens(msg.sender);
    }
  }

  function endSale() whenNotPaused {
    require (!isInSale());
    require (saleSupply != 0);
    reserveSupply = reserveSupply.add(saleSupply);
  }

  /**
   * Buy tokens during the sale/presale
   * @param _receiver who should receive the tokens
   */
  function buyTokens(address _receiver) payable whenNotPaused {
    require (msg.value != 0);
    require (_receiver != 0x0);
    require (isInSale());
    bool isPresale = isInPresale();
    if (!isPresale) {
      checkPresale();
    }
    uint256 tokenPrice = saleTokenPrice;
    if (isPresale) {
      tokenPrice = preSaleTokenPrice;
    }
    uint256 tokens = (msg.value).mul(tokenPrice);
    if (isPresale) {
      if (presaleSupply < tokens) {
        msg.sender.transfer(msg.value);
        return;
      }
    } else {
      if (saleSupply < tokens) {
        msg.sender.transfer(msg.value);
        return;
      }
    }
    checkDividend(_receiver);
    TokenPurchase(msg.sender, _receiver, msg.value, tokens, isPresale);
    totalWeiRaised = totalWeiRaised.add(msg.value);
    Transfer(0x0, _receiver, tokens);
    balances[_receiver] = balances[_receiver].add(tokens);
    if (isPresale) {
      presaleSupply = presaleSupply.sub(tokens);
    } else {
      saleSupply = saleSupply.sub(tokens);
    }
  }

  /**
   * @dev Pay this function to add the dividends
   */
  function giveDividend() payable whenNotPaused {
    require (msg.value != 0);
    dividendAmount = dividendAmount.add(msg.value);
    dividendList[currentDividend] = (msg.value).mul(10000000000).div(totalSupply);
    currentDividend = currentDividend.add(1);
    DividendAvailable(msg.value);
  }

  /**
   * @dev Returns true if we are still in pre sale period
   * @param _account The address to check and send dividends
   */
  function checkDividend(address _account) whenNotPaused {
    if (lastDividend[_account] != currentDividend) {
      if (balanceOf(_account) != 0) {
        uint256 toSend = 0;
        for (uint i = lastDividend[_account]; i < currentDividend; i++) {
          toSend += balanceOf(_account).mul(dividendList[i]).div(10000000000);
        }
        if (toSend > 0 && toSend <= dividendAmount) {
          _account.transfer(toSend);
          dividendAmount = dividendAmount.sub(toSend);
          SendDividend(_account, toSend);
        }
      }
      lastDividend[_account] = currentDividend;
    }
  }

  /**
  * @dev transfer token for a specified address checking if they are dividends to pay
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    checkDividend(msg.sender);
    return super.transfer(_to, _value);
  }

  /**
   * @dev Transfer tokens from one address to another checking if they are dividends to pay
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    checkDividend(_from);
    return super.transferFrom(_from, _to, _value);
  }

  /**
   * @dev Returns true if we are still in pre sale period
   */
  function isInPresale() constant returns (bool) {
    return saleStartTime > now;
  }

  /**
   * @dev Returns true if we are still in sale period
   */
  function isInSale() constant returns (bool) {
    return saleEndTime >= now && preSaleStartTime <= now;
  }

  // @return true if the transaction can buy tokens
  function checkPresale() internal {
    if (!isInPresale() && presaleSupply > 0) {
      saleSupply = saleSupply.add(presaleSupply);
      presaleSupply = 0;
    }
  }

  /**
   * Distribute tokens from the reserve
   * @param _amount Amount to transfer
   * @param _receiver Address of the receiver
   */
  function distributeReserveSupply(uint256 _amount, address _receiver) onlyOwner whenNotPaused {
    require (_amount <= reserveSupply);
    require (now >= developerLock);
    checkDividend(_receiver);
    balances[_receiver] = balances[_receiver].add(_amount);
    reserveSupply.sub(_amount);
    Transfer(0x0, _receiver, _amount);
  }

  /**
   * Withdraw some Ether from contract
   */
  function withdraw(uint _amount) onlyOwner {
    require (_amount != 0);
    require (_amount < this.balance);
    (msg.sender).transfer(_amount);
  }

  /**
   * Withdraw Ether from contract
   */
  function withdrawEverything() onlyOwner {
    (msg.sender).transfer(this.balance);
  }

}