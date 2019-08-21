pragma solidity 0.4.15;

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


  function Crowdsale(uint256 _startTime, uint256 _endTime, uint256 _rate, address _wallet) {
    require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(_wallet != 0x0);

    token = createTokenContract();
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    wallet = _wallet;
  }

  // creates the token to be sold.
  // override this method to have crowdsale of a specific mintable token.
  function createTokenContract() internal returns (MintableToken) {
    return new MintableToken();
  }


  // fallback function can be used to buy tokens
  function () payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    token.mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
  }

  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }


}

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
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract BlockbidCrowdsale is Crowdsale, Ownable {

  uint public goal;
  uint public cap;
  uint public earlybonus;
  uint public standardrate;
  bool public goalReached = false;
  bool public paused = false;
  uint public constant weeklength = 604800;

  mapping(address => uint) public weiContributed;
  address[] public contributors;

  event LogClaimRefund(address _address, uint _value);

  modifier notPaused() {
    if (paused) {
      revert();
    }
    _;
  }

  function BlockbidCrowdsale(uint _goal, uint _cap, uint _startTime, uint _endTime, uint _rate, uint _earlyBonus, address _wallet)
  Crowdsale(_startTime, _endTime, _rate, _wallet) public {
    require(_cap > 0);
    require(_goal > 0);

    standardrate = _rate;
    earlybonus = _earlyBonus;
    cap = _cap;
    goal = _goal;
  }

  // @return true if the transaction can buy tokens
  /*
  Added: - Must be under Cap
         - Requires user to send atleast 1 token's worth of ether
         - Needs to call updateRate() function to validate how much ether = 1 token
         -
  */
  function validPurchase() internal constant returns (bool) {

    updateRate();

    bool withinPeriod = (now >= startTime && now <= endTime);
    bool withinPurchaseLimit = (msg.value >= 0.1 ether && msg.value <= 100 ether);
    bool withinCap = (token.totalSupply() <= cap);
    return withinPeriod && withinPurchaseLimit && withinCap;
  }

  // function that will determine how many tokens have been created
  function tokensPurchased() internal constant returns (uint) {
    return rate.mul(msg.value).mul(100000000).div(1 ether);
  }

  /*
    function will identify what period of crowdsale we are in and update
    the rate.
    Rates are lower (e.g. 1:360 instead of 1:300) early on
    to give early bird discounts
  */
  function updateRate() internal returns (bool) {

    if (now >= startTime.add(weeklength.mul(4))) {
      rate = 200;
    }
    else if (now >= startTime.add(weeklength.mul(3))) {
      rate = standardrate;
    }
    else if (now >= startTime.add(weeklength.mul(2))) {
      rate = standardrate.add(earlybonus.sub(40));
    }
    else if (now >= startTime.add(weeklength)) {
      rate = standardrate.add(earlybonus.sub(20));
    }
    else {
      rate = standardrate.add(earlybonus);
    }

    return true;
  }

  function buyTokens(address beneficiary) notPaused public payable {
    require(beneficiary != 0x0);

    // enable wallet to deposit funds post ico and goals not reached
    if (msg.sender == wallet) {
      require(hasEnded());
      require(!goalReached);
    }
    // everybody else goes through standard validation
    else {
      require(validPurchase());
    }

    // update state
    weiRaised = weiRaised.add(msg.value);

    // if user already a contributor
    if (weiContributed[beneficiary] > 0) {
      weiContributed[beneficiary] = weiContributed[beneficiary].add(msg.value);
    }
    // new contributor
    else {
      weiContributed[beneficiary] = msg.value;
      contributors.push(beneficiary);
    }

    // update tokens for each individual
    token.mint(beneficiary, tokensPurchased());
    TokenPurchase(msg.sender, beneficiary, msg.value, tokensPurchased());
    token.mint(wallet, (tokensPurchased().div(4)));

    if (token.totalSupply() > goal) {
      goalReached = true;
    }

    // don't forward funds if wallet belongs to owner
    if (msg.sender != wallet) {
      forwardFunds();
    }
  }

  function getContributorsCount() public constant returns(uint) {
    return contributors.length;
  }

  // if crowdsale is unsuccessful, investors can claim refunds here
  function claimRefund() notPaused public returns (bool) {
    require(!goalReached);
    require(hasEnded());
    uint contributedAmt = weiContributed[msg.sender];
    require(contributedAmt > 0);
    weiContributed[msg.sender] = 0;
    msg.sender.transfer(contributedAmt);
    LogClaimRefund(msg.sender, contributedAmt);
    return true;
  }

  // allow owner to pause ico in case there is something wrong
  function setPaused(bool _val) onlyOwner public returns (bool) {
    paused = _val;
    return true;
  }

  // destroy contract and send all remaining ether back to wallet
  function kill() onlyOwner public {
    require(!goalReached);
    require(hasEnded());
    selfdestruct(wallet);
  }

  // create BID token
  function createTokenContract() internal returns (MintableToken) {
    return new BlockbidMintableToken();
  }

}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

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

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

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
    Transfer(0x0, _to, _amount);
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
}

contract BlockbidMintableToken is MintableToken {

  string public constant name = "Blockbid Token";
  string public constant symbol = "BID";
  uint8 public constant decimals = 8;

}