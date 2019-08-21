pragma solidity ^0.4.13;

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

contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  function Ownable() {
    owner = msg.sender;
  }
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BasicToken is ERC20Basic, Ownable {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  bool transferAllowed = false;

  function setTransferAllowed(bool _transferAllowed) public onlyOwner {
    transferAllowed = _transferAllowed;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);
    require(transferAllowed);

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
//StandardToken.sol
contract StandardToken is ERC20, BasicToken {
  using SafeMath for uint256;

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
    require(transferAllowed);

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
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));
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
}

contract MatToken is Ownable, StandardToken {
  string public constant name = "MiniApps Token";
  string public constant symbol = "MAT";
  uint   public constant decimals = 18;
  
  // token units
  uint256 public constant MAT_UNIT = 10**uint256(decimals);
  uint256 constant MILLION_MAT = 10**6 * MAT_UNIT;
  uint256 constant THOUSAND_MAT = 10**3 * MAT_UNIT;

  // Token distribution: crowdsale - 50%, partners - 35%, team - 15%, total 20M  
  uint256 public constant MAT_CROWDSALE_SUPPLY_LIMIT = 10 * MILLION_MAT;
  uint256 public constant MAT_TEAM_SUPPLY_LIMIT = 7 * MILLION_MAT;
  uint256 public constant MAT_PARTNERS_SUPPLY_LIMIT = 3 * MILLION_MAT;
  uint256 public constant MAT_TOTAL_SUPPLY_LIMIT = MAT_CROWDSALE_SUPPLY_LIMIT + MAT_TEAM_SUPPLY_LIMIT + MAT_PARTNERS_SUPPLY_LIMIT;
}

contract MatBonus is MatToken {
  uint256 public constant TOTAL_SUPPLY_UPPER_BOUND = 14000 * THOUSAND_MAT;
  uint256 public constant TOTAL_SUPPLY_BOTTOM_BOUND = 11600 * THOUSAND_MAT;

  function calcBonus(uint256 tokens) internal returns (uint256){
    if (totalSupply <= TOTAL_SUPPLY_BOTTOM_BOUND)
      return tokens.mul(8).div(100);
    else if (totalSupply > TOTAL_SUPPLY_BOTTOM_BOUND && totalSupply <= TOTAL_SUPPLY_UPPER_BOUND)
      return tokens.mul(5).div(100);
    else
      return 0;
  }
}

contract MatBase is Ownable, MatToken, MatBonus {
 using SafeMath for uint256;
  
  uint256 public constant _START_DATE = 1508284800; //  Wednesday, 18-Oct-17 00:00:00 UTC in RFC 2822
  uint256 public constant _END_DATE = 1513641600; // Tuesday, 19-Dec-17 00:00:00 UTC in RFC 2822
  uint256 public constant CROWDSALE_PRICE = 100; // 100 MAT per ETH
  address public constant ICO_ADDRESS = 0x6075a5A0620861cfeF593a51A01aF0fF179168C7;
  address public constant PARTNERS_WALLET =  0x39467d5B39F1d24BC8479212CEd151ad469B0D7E;
  address public constant TEAM_WALLET = 0xe1d32147b08b2a7808026D4A94707E321ccc7150;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;
  function setStartTime(uint256 _startTime) onlyOwner
  {
    startTime = _startTime;
  }
  function setEndTime(uint256 _endTime) onlyOwner
  {
    endTime = _endTime;
  }

  // address  where funds are collected
  address public wallet;
  address public p_wallet;
  address public t_wallet;

  // total amount of raised money in wei
  uint256 public totalCollected;
  // how many token units a buyer gets per wei
  uint256 public rate;
  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }
  event Mint(address indexed purchaser, uint256 amount);
  event Bonus(address indexed purchaser,uint256 amount);
  function mint(address _to, uint256 _tokens) internal returns (bool) {
    totalSupply = totalSupply.add(_tokens);
    require(totalSupply <= whiteListLimit);
    require(totalSupply <= MAT_TOTAL_SUPPLY_LIMIT);

    balances[_to] = balances[_to].add(_tokens);
    Mint(_to, _tokens);
    Transfer(0x0, _to, _tokens);
    return true;
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
  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amountTokens amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amountTokens,
    string referral);

  // fallback function can be used to buy tokens
  function () payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {
    buyTokensReferral(beneficiary, "");
  }

  // low level token purchase function
  function buyTokensReferral(address beneficiary, string referral) public payable {
    require(msg.value > 0);
    require(beneficiary != 0x0);
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);
    uint256 bonus = calcBonus(tokens);

    // update state
    totalCollected = totalCollected.add(weiAmount);

    if (!buyTokenWL(tokens)) mint(beneficiary, bonus);
    mint(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens, referral);
    forwardFunds();
  }

//whitelist
  bool isWhitelistOn;
  uint256 public whiteListLimit;

  enum WLS {notlisted,listed,fulfilled}
  struct FundReservation {
    WLS status;
    uint256  reserved;
  }
  mapping ( address => FundReservation ) whitelist;

  function stopWhitelistReservetion() onlyOwner public { 
    whiteListLimit = MAT_TOTAL_SUPPLY_LIMIT; 
  }

  function setWhiteListStatus(bool _isWhitelistOn) onlyOwner public {
    isWhitelistOn = _isWhitelistOn;
  }

  function buyTokenWL(uint256 tokens) internal returns (bool)
  { 
    require(isWhitelistOn);
    require(now >= startTime);
    if (whitelist[msg.sender].status == WLS.listed) {
      uint256 reservation = whitelist[msg.sender].reserved;
      uint256 low = reservation.mul(9).div(10);
      uint256 upper = reservation.mul(11).div(10);
      
      if( low <= msg.value && msg.value <= upper) {
        whitelist[msg.sender].status == WLS.fulfilled;
        uint256 bonus = tokens / 10;
        mint(msg.sender, bonus);
        Bonus(msg.sender,bonus);
        return true;
      }
    }
    return false;
  }
  event White(address indexed to, uint256 reservation);
  function regWL(address wlmember, uint256 reservation) onlyOwner public returns (bool status)
  {
    require(now < endTime);
    require(whitelist[wlmember].status == WLS.notlisted);
    
    whitelist[wlmember].status = WLS.listed;
    whitelist[wlmember].reserved = reservation;
    
    whiteListLimit = whiteListLimit.sub(reservation.mul(CROWDSALE_PRICE).mul(11).div(10));
    White(wlmember,reservation);
    return true;
  }
  address public constant PRESALE_CONTRACT = 0x503FE694CE047eCB51952b79eCAB2A907Afe8ACd;
    /**
   * @dev presale token conversion 
   *
   * @param _to holder of presale tokens
   * @param _pretokens The amount of presale tokens to be spent.
   * @param _tokens The amount of presale tokens to be minted on crowdsale, the rest transfer from partners pool
   */
  function convert(address _to, uint256 _pretokens, uint256 _tokens) onlyOwner public returns (bool){
    require(now <= endTime);
    require(_to != address(0));
    require(_pretokens >=  _tokens);
    
    mint(_to, _tokens); //implicit transfer event
    
    uint256 theRest = _pretokens.sub(_tokens);
    require(balances[PARTNERS_WALLET] >= theRest);
    
    if (theRest > 0) {
      balances[PARTNERS_WALLET] = balances[PARTNERS_WALLET].sub(theRest);
      balances[_to] = balances[_to].add(theRest);
      Transfer(PARTNERS_WALLET, _to, theRest); //explicit transfer event
    }
    uint256 amount = _pretokens.div(rate);
    totalCollected = totalCollected.add(amount);
    return true;
  }
  function MatBase() {
    startTime = _START_DATE;
    endTime = _END_DATE;
    wallet = ICO_ADDRESS;
    rate = CROWDSALE_PRICE;
    p_wallet = PARTNERS_WALLET;
    t_wallet = TEAM_WALLET;
    balances[p_wallet] =  MAT_PARTNERS_SUPPLY_LIMIT;
    balances[t_wallet] = MAT_TEAM_SUPPLY_LIMIT;
    totalSupply = MAT_PARTNERS_SUPPLY_LIMIT + MAT_TEAM_SUPPLY_LIMIT;
    whiteListLimit = MAT_TOTAL_SUPPLY_LIMIT;
  }
}