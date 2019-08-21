pragma solidity ^0.4.19;

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
  function transferOwnership(address newOwner) public onlyOwner{
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
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
 * @title 
 * @dev Very simple ERC20 Token that can be minted.
 * It is meant to be used in a crowdsale contract.
 */
contract ChariotToken is StandardToken, Ownable {

  string public constant name = "Chariot Coin";
  string public constant symbol = "TOM";
  uint8 public constant decimals = 18;
  event Mint(address indexed to, uint256 amount);
  event MintFinished();
  event MintPaused(bool pause);

  bool public mintingFinished = false;
  bool public mintingPaused = false;
  address public saleAgent = address(0);

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier unpauseMint() {
    require(!mintingPaused);
    _;
  }

  function setSaleAgent(address newSaleAgnet) public {
    require(msg.sender == saleAgent || msg.sender == owner);
    saleAgent = newSaleAgnet;
  }

  /**
   * @dev Function to pause/unpause minting new tokens.
   * @return True if minting was pause.
   * @return False if minting was unpause
   */
  function pauseMinting(bool _mintingPaused) canMint public returns (bool) {
    require((msg.sender == saleAgent || msg.sender == owner));
    mintingPaused = _mintingPaused;
    MintPaused(_mintingPaused);
    return _mintingPaused;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) canMint unpauseMint public returns (bool) {
    require(msg.sender == saleAgent || msg.sender == owner);
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(address(this), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() canMint public returns (bool) {
    require((msg.sender == saleAgent || msg.sender == owner));
    mintingFinished = true;
    MintFinished();
    return true;
  }

  event Burn(address indexed burner, uint256 value);

    /**
     * @dev Burns a specific amount of tokens.
     * @param _value The amount of token to be burned.
     */
    function burn(uint256 _value) public {
        require(_value <= balances[msg.sender]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply = totalSupply.sub(_value);
        Burn(burner, _value);
    }

  function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(msg.sender == saleAgent || msg.sender == owner);
        require(balances[_from] >= _value);// Check if the targeted balance is enough
        require(_value <= allowed[_from][msg.sender]);// Check allowance
        balances[_from] = balances[_from].sub(_value); // Subtract from the targeted balance
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value); // Subtract from the sender's allowance
        totalSupply = totalSupply.sub(_value);
        Burn(_from, _value);
        return true;
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
contract TokenSale is Ownable{
  using SafeMath for uint256;
  // start and end timestamps where investments are allowed (both inclusive)
   // The token being sold
  ChariotToken public token;

  uint256 public startTime;
  uint256 public endTime;

  uint256 public initialSupply = 37600000 * 1 ether;

  // bool public checkDiscountStage = true;
  uint256 limit;
  uint256 period;
  // address where funds are collected
  address public wallet;

  // one token per one rate, token default = 0.001 ETH = 1 TOM
  uint256 public rate = 1000;

  // Company addresses
  address public TeamAndAdvisors;
  address public Investors;
  address public EADC;
  address public Bounty;

  // amount of raised money in wei
  uint256 public weiRaised;
  uint256 public weiSoftCap = 800 * 1 ether;
  uint256 public weiHardCap = 1600 * 1 ether;

  modifier saleIsOn() {
      require(now > startTime && now < endTime);
      require(weiRaised <= weiHardCap);
      require(initialSupply >= token.totalSupply());
      _;
  }

  uint256 discountStage1 = 60;
  uint256 discountStage2 = 55;
  uint256 discountStage3 = 50;
  uint256 discountStage4 = 40;

  function setDiscountStage(
    uint256 _newDiscountStage1,
    uint256 _newDiscountStage2,
    uint256 _newDiscountStage3,
    uint256 _newDiscountStage4
    ) onlyOwner public {
    discountStage1 = _newDiscountStage1;
    discountStage2 = _newDiscountStage2;
    discountStage3 = _newDiscountStage3;
    discountStage4 = _newDiscountStage4;
  }

  function setTime(uint _startTime, uint _endTime) public onlyOwner {
    require(now < _endTime && _startTime < _endTime);
    endTime = _endTime;
    startTime = _startTime;
  }

  function setRate(uint _newRate) public onlyOwner {
    rate = _newRate;
  }

  function setTeamAddress(
    address _TeamAndAdvisors,
    address _Investors,
    address _EADC,
    address _Bounty,
    address _wallet) public onlyOwner {
    TeamAndAdvisors = _TeamAndAdvisors;
    Investors = _Investors;
    EADC = _EADC;
    Bounty = _Bounty;
    wallet = _wallet;
  }

  function getDiscountStage() public view returns (uint256) {
    if(now < startTime + 5 days) {
        return discountStage1;
      } else if(now >= startTime + 5 days && now < startTime + 10 days) {
        return discountStage2;
      } else if(now >= startTime + 10 days && now < startTime + 15 days) {
        return discountStage3;
      } else if(now >= startTime + 15 days && now < endTime) {
        return discountStage4;
      }
  }

  /**
   * events for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  event TokenPartners(address indexed purchaser, address indexed beneficiary, uint256 amount);

  function TokenSale(
    uint256 _startTime,
    uint256 _endTime,
    address _wallet,
    uint256 _limit,
    uint256 _period,
    address _TeamAndAdvisors,
    address _Investors,
    address _Bounty,
    address _EADC
    ) public {
    require(_wallet != address(0));
    require(_TeamAndAdvisors != address(0));
    require(_Investors != address(0));
    require(_EADC != address(0));
    require(_Bounty != address(0));
    require(_endTime > _startTime);
    require(now < _startTime);
    token = new ChariotToken();
    startTime = _startTime;
    endTime = _endTime;
    wallet = _wallet;
    limit = _limit * 1 ether;
    period = _period;
    TeamAndAdvisors = _TeamAndAdvisors;
    Investors = _Investors;
    EADC = _EADC;
    Bounty = _Bounty;
    token.setSaleAgent(owner);
  }

  function updatePrice() returns(uint256){
    uint256 _days = now.sub(startTime).div(1 days); // days after startTime
    return (_days % period).add(1).mul(rate); // rate in this period
  }
  
  function setLimit(uint256 _newLimit) public onlyOwner {
    limit = _newLimit * 1 ether;
  }

  // @ value - tokens for sale
  function isUnderLimit(uint256 _value) public returns (bool){
    uint256 _days = now.sub(startTime).div(1 days); // days after startTime
    uint256 coinsLimit = (_days % period).add(1).mul(limit); // limit coins in this period
    return (msg.sender).balance.add(_value) <= coinsLimit;
  }

  function buyTokens(address beneficiary) saleIsOn public payable {
    require(beneficiary != address(0));

    uint256 weiAmount = msg.value;
    uint256 all = 100;
    uint256 tokens;
    
    // calculate token amount to be created
    tokens = weiAmount.mul(updatePrice()).mul(100).div(all.sub(getDiscountStage()));

    // update state
    weiRaised = weiRaised.add(weiAmount);
    if(endTime.sub(now).div(1 days) > 5) {
      require(isUnderLimit(tokens));
    }

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    wallet.transfer(weiAmount.mul(30).div(100));
    Investors.transfer(weiAmount.mul(65).div(100));
    EADC.transfer(weiAmount.mul(5).div(100));

    uint256 taaTokens = tokens.mul(27).div(100);
    uint256 bountyTokens = tokens.mul(3).div(100);

    token.mint(TeamAndAdvisors, taaTokens);
    token.mint(Bounty, bountyTokens);

    TokenPartners(msg.sender, TeamAndAdvisors, taaTokens);
    TokenPartners(msg.sender, Bounty, bountyTokens);  
  }

  // fallback function can be used to buy tokens
  function () external payable {
    buyTokens(msg.sender);
  }

  // @return true if tokensale event has ended
  function hasEnded() public view returns (bool) {
    return now > endTime;
  }
}