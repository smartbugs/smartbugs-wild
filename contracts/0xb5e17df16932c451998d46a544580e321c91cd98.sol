pragma solidity ^0.4.23;

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

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

// File: zeppelin-solidity/contracts/math/SafeMath.sol

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

// File: zeppelin-solidity/contracts/token/ERC20/BasicToken.sol

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

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}

// File: zeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender)
    public view returns (uint256);

  function transferFrom(address from, address to, uint256 value)
    public returns (bool);

  function approve(address spender, uint256 value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: zeppelin-solidity/contracts/token/ERC20/StandardToken.sol

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
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
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
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
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
  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
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
  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: kuende-token/contracts/KuendeCoinToken.sol

/**
 * @title KuendeCoinToken
 * @author https://bit-sentinel.com
 */
contract KuendeCoinToken is StandardToken, Ownable {
  /**
   * @dev event for logging enablement of transfers
   */
  event EnabledTransfers();

  /**
   * @dev event for logging crowdsale address set
   * @param crowdsale address Address of the crowdsale
   */
  event SetCrowdsaleAddress(address indexed crowdsale);

  // Address of the crowdsale.
  address public crowdsale;

  // Public variables of the Token.
  string public name = "KuendeCoin"; 
  uint8 public decimals = 18;
  string public symbol = "KNC";

  // If the token is transferable or not.
  bool public transferable = false;

  /**
   * @dev Initialize the KuendeCoinToken and transfer the initialBalance to the
   *      contract creator. 
   */
  constructor(address initialAccount, uint256 initialBalance) public {
    totalSupply_ = initialBalance;
    balances[initialAccount] = initialBalance;
    emit Transfer(0x0, initialAccount, initialBalance);
  }

  /**
   * @dev Ensure the transfer is valid.
   */
  modifier canTransfer() {
    require(transferable || (crowdsale != address(0) && crowdsale == msg.sender));
    _; 
  }

  /**
   * @dev Enable the transfers of this token. Can only be called once.
   */
  function enableTransfers() external onlyOwner {
    require(!transferable);
    transferable = true;
    emit EnabledTransfers();
  }

  /**
   * @dev Set the crowdsale address.
   * @param _addr address
   */
  function setCrowdsaleAddress(address _addr) external onlyOwner {
    require(_addr != address(0));
    crowdsale = _addr;
    emit SetCrowdsaleAddress(_addr);
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public canTransfer returns (bool) {
    return super.transfer(_to, _value);
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public canTransfer returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }
}

// File: contracts/KuendeCrowdsale.sol

/**
 * @title KuendeCrowdsale
 * @author https://bit-sentinel.com
 * @dev Inspired by: https://github.com/OpenZeppelin/zeppelin-solidity/tree/master/contracts/crowdsale
 */
contract KuendeCrowdsale is Ownable {
  using SafeMath for uint256;

  /**
   * @dev event for change wallet address logging
   * @param newWallet address that got set
   * @param oldWallet address that was changed from
   */
  event ChangedWalletAddress(address indexed newWallet, address indexed oldWallet);
  
  /**
   * @dev event for token purchase logging
   * @param investor who purchased tokens
   * @param value weis paid for purchase
   * @param amount of tokens purchased
   */
  event TokenPurchase(address indexed investor, uint256 value, uint256 amount);

  // definition of an Investor
  struct Investor {
    uint256 weiBalance;    // Amount of invested wei (0 for PreInvestors)
    uint256 tokenBalance;  // Amount of owned tokens
    bool whitelisted;      // Flag for marking an investor as whitelisted
    bool purchasing;       // Lock flag
  }

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // address that can whitelist new investors
  address public registrar;

  // wei to token exchange rate
  uint256 public exchangeRate;

  // address where funds are collected
  address public wallet;

  // token contract
  KuendeCoinToken public token;

  // crowdsale sale cap
  uint256 public cap;

  // crowdsale investor cap
  uint256 public investorCap;

  // minimum investment
  uint256 public constant minInvestment = 100 finney;

  // gas price limit. 100 gwei.
  uint256 public constant gasPriceLimit = 1e11 wei;

  // amount of raised money in wei
  uint256 public weiRaised;

  // storage for the investors repository
  uint256 public numInvestors;
  mapping (address => Investor) public investors;

  /**
   * @dev Create a new instance of the KuendeCrowdsale contract
   * @param _startTime     uint256 Crowdsale start time timestamp in unix format.
   * @param _endTime       uint256 Crowdsale end time timestamp in unix format.
   * @param _cap           uint256 Hard cap in wei.
   * @param _exchangeRate  uint256 1 token value in wei.
   * @param _registrar     address Address that can whitelist investors.
   * @param _wallet        address Address of the wallet that will collect the funds.
   * @param _token         address Token smart contract address.
   */
  constructor (
    uint256 _startTime,
    uint256 _endTime,
    uint256 _cap,
    uint256 _exchangeRate,
    address _registrar,
    address _wallet,
    address _token
  )
    public
  {
    // validate parameters
    require(_startTime > now);
    require(_endTime > _startTime);
    require(_cap > 0);
    require(_exchangeRate > 0);
    require(_registrar != address(0));
    require(_wallet != address(0));
    require(_token != address(0));

    // update storage
    startTime = _startTime;
    endTime = _endTime;
    cap = _cap;
    exchangeRate = _exchangeRate;
    registrar = _registrar;
    wallet = _wallet;
    token = KuendeCoinToken(_token);
  }

  /**
   * @dev Ensure the crowdsale is not started
   */
  modifier notStarted() { 
    require(now < startTime);
    _;
  }

  /**
   * @dev Ensure the crowdsale is not notEnded
   */
  modifier notEnded() { 
    require(now <= endTime);
    _;
  }
  
  /**
   * @dev Fallback function can be used to buy tokens
   */
  function () external payable {
    buyTokens();
  }

  /**
   * @dev Change the wallet address
   * @param _wallet address
   */
  function changeWalletAddress(address _wallet) external notStarted onlyOwner {
    // validate call against the rules
    require(_wallet != address(0));
    require(_wallet != wallet);

    // update storage
    address _oldWallet = wallet;
    wallet = _wallet;

    // trigger event
    emit ChangedWalletAddress(_wallet, _oldWallet);
  }

  /**
   * @dev Whitelist multiple investors at once
   * @param addrs address[]
   */
  function whitelistInvestors(address[] addrs) external {
    require(addrs.length > 0 && addrs.length <= 30);
    for (uint i = 0; i < addrs.length; i++) {
      whitelistInvestor(addrs[i]);
    }
  }

  /**
   * @dev Whitelist a new investor
   * @param addr address
   */
  function whitelistInvestor(address addr) public notEnded {
    require((msg.sender == registrar || msg.sender == owner) && !limited());
    if (!investors[addr].whitelisted && addr != address(0)) {
      investors[addr].whitelisted = true;
      numInvestors++;
    }
  }

  /**
   * @dev Low level token purchase function
   */
  function buyTokens() public payable {
    // update investor cap.
    updateInvestorCap();

    address investor = msg.sender;

    // validate purchase    
    validPurchase();

    // lock investor account
    investors[investor].purchasing = true;

    // get the msg wei amount
    uint256 weiAmount = msg.value.sub(refundExcess());

    // value after refunds should be greater or equal to minimum investment
    require(weiAmount >= minInvestment);

    // calculate token amount to be sold
    uint256 tokens = weiAmount.mul(1 ether).div(exchangeRate);

    // update storage
    weiRaised = weiRaised.add(weiAmount);
    investors[investor].weiBalance = investors[investor].weiBalance.add(weiAmount);
    investors[investor].tokenBalance = investors[investor].tokenBalance.add(tokens);

    // transfer tokens
    require(transfer(investor, tokens));

    // trigger event
    emit TokenPurchase(msg.sender, weiAmount, tokens);

    // forward funds
    wallet.transfer(weiAmount);

    // unlock investor account
    investors[investor].purchasing = false;
  }

  /**
  * @dev Update the investor cap.
  */
  function updateInvestorCap() internal {
    require(now >= startTime);

    if (investorCap == 0) {
      investorCap = cap.div(numInvestors);
    }
  }

  /**
   * @dev Wrapper over token's transferFrom function. Ensures the call is valid.
   * @param  to    address
   * @param  value uint256
   * @return bool
   */
  function transfer(address to, uint256 value) internal returns (bool) {
    if (!(
      token.allowance(owner, address(this)) >= value &&
      token.balanceOf(owner) >= value &&
      token.crowdsale() == address(this)
    )) {
      return false;
    }
    return token.transferFrom(owner, to, value);
  }
  
  /**
   * @dev Refund the excess weiAmount back to the investor so the caps aren't reached
   * @return uint256 the weiAmount after refund
   */
  function refundExcess() internal returns (uint256 excess) {
    uint256 weiAmount = msg.value;
    address investor = msg.sender;

    // calculate excess for investorCap
    if (limited() && !withinInvestorCap(investor, weiAmount)) {
      excess = investors[investor].weiBalance.add(weiAmount).sub(investorCap);
      weiAmount = msg.value.sub(excess);
    }

    // calculate excess for crowdsale cap
    if (!withinCap(weiAmount)) {
      excess = excess.add(weiRaised.add(weiAmount).sub(cap));
    }
    
    // refund and update weiAmount
    if (excess > 0) {
      investor.transfer(excess);
    }
  }

  /**
   * @dev Validate the purchase. Reverts if purchase is invalid
   */
  function validPurchase() internal view {
    require (msg.sender != address(0));           // valid investor address
    require (tx.gasprice <= gasPriceLimit);       // tx gas price doesn't exceed limit
    require (!investors[msg.sender].purchasing);  // investor not already purchasing
    require (startTime <= now && now <= endTime); // within crowdsale period
    require (investorCap != 0);                   // investor cap initialized
    require (msg.value >= minInvestment);         // value should exceed or be equal to minimum investment
    require (whitelisted(msg.sender));            // check if investor is whitelisted
    require (withinCap(0));                       // check if purchase is within cap
    require (withinInvestorCap(msg.sender, 0));   // check if purchase is within investor cap
  }

  /**
   * @dev Check if by adding the provided _weiAmomunt the cap is not exceeded
   * @param weiAmount uint256
   * @return bool
   */
  function withinCap(uint256 weiAmount) internal view returns (bool) {
    return weiRaised.add(weiAmount) <= cap;
  }

  /**
   * @dev Check if by adding the provided weiAmount to investor's account the investor
   *      cap is not excedeed
   * @param investor  address
   * @param weiAmount uint256
   * @return bool
   */
  function withinInvestorCap(address investor, uint256 weiAmount) internal view returns (bool) {
    return limited() ? investors[investor].weiBalance.add(weiAmount) <= investorCap : true;
  }

  /**
   * @dev Check if the given address is whitelisted for token purchases
   * @param investor address
   * @return bool
   */
  function whitelisted(address investor) internal view returns (bool) {
    return investors[investor].whitelisted;
  }

  /**
   * @dev Check if the crowdsale is limited
   * @return bool
   */
  function limited() internal view returns (bool) {
    return  startTime <= now && now < startTime.add(3 days);
  }
}