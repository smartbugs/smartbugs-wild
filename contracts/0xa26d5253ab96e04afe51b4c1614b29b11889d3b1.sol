pragma solidity ^0.4.17;

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




// NOTE: BasicToken only has partial ERC20 support
contract Ico is BasicToken {
  address owner;
  uint256 public teamNum;
  mapping(address => bool) team;

  // expose these for ERC20 tools
  string public constant name = "LUNA";
  string public constant symbol = "LUNA";
  uint8 public constant decimals = 18;

  // Significant digits tokenPrecision
  uint256 private constant tokenPrecision = 10e17;

  // TODO: set this final, this equates to an amount
  // in dollars.
  uint256 public constant hardCap = 32000 * tokenPrecision;

  // Tokens frozen supply
  uint256 public tokensFrozen = 0;

  uint256 public tokenValue = 1 * tokenPrecision;

  // struct representing a dividends snapshot
  struct DividendSnapshot {
    uint256 totalSupply;
    uint256 dividendsIssued;
    uint256 managementDividends;
  }
  // An array of all the DividendSnapshot so far
  DividendSnapshot[] dividendSnapshots;

  // Mapping of user to the index of the last dividend that was awarded to zhie
  mapping(address => uint256) lastDividend;

  // Management fees share express as 100/%: eg. 20% => 100/20 = 5
  uint256 public constant managementFees = 10;

  // Assets under management in USD
  uint256 public aum = 0;

  // number of tokens investors will receive per eth invested
  uint256 public tokensPerEth;

  // Ico start/end timestamps, between which (inclusively) investments are accepted
  uint public icoStart;
  uint public icoEnd;

  // drip percent in 100 / percentage
  uint256 public dripRate = 50;

  // current registred change address
  address public currentSaleAddress;

  // custom events
  event Freeze(address indexed from, uint256 value);
  event Participate(address indexed from, uint256 value);
  event Reconcile(address indexed from, uint256 period, uint256 value);

  /**
   * ICO constructor
   * Define ICO details and contribution period
   */
  function Ico(uint256 _icoStart, uint256 _icoEnd, address[] _team, uint256 _tokensPerEth) public {
    // require (_icoStart >= now);
    require (_icoEnd >= _icoStart);
    require (_tokensPerEth > 0);

    owner = msg.sender;

    icoStart = _icoStart;
    icoEnd = _icoEnd;
    tokensPerEth = _tokensPerEth;

    // initialize the team mapping with true when part of the team
    teamNum = _team.length;
    for (uint256 i = 0; i < teamNum; i++) {
      team[_team[i]] = true;
    }

    // as a safety measure tempory set the sale address to something else than 0x0
    currentSaleAddress = owner;
  }

  /**
   * Modifiers
   */
  modifier onlyOwner() {
    require (msg.sender == owner);
    _;
  }

  modifier onlyTeam() {
    require (team[msg.sender] == true);
    _;
  }

  modifier onlySaleAddress() {
    require (msg.sender == currentSaleAddress);
    _;
  }

  /**
   *
   * Function allowing investors to participate in the ICO.
   * Specifying the beneficiary will change who will receive the tokens.
   * Fund tokens will be distributed based on amount of ETH sent by investor, and calculated
   * using tokensPerEth value.
   */
  function participate(address beneficiary) public payable {
    require (beneficiary != address(0));
    require (now >= icoStart && now <= icoEnd);
    require (msg.value > 0);

    uint256 ethAmount = msg.value;
    uint256 numTokens = ethAmount.mul(tokensPerEth);

    require(totalSupply.add(numTokens) <= hardCap);

    balances[beneficiary] = balances[beneficiary].add(numTokens);
    totalSupply = totalSupply.add(numTokens);
    tokensFrozen = totalSupply * 2;
    aum = totalSupply;

    owner.transfer(ethAmount);
    // Our own custom event to monitor ICO participation
    Participate(beneficiary, numTokens);
    // Let ERC20 tools know of token hodlers
    Transfer(0x0, beneficiary, numTokens);
  }

  /**
   *
   * We fallback to the partcipate function
   */
  function () external payable {
     participate(msg.sender);
  }

  /**
   * Internal burn function, only callable by team
   *
   * @param _amount is the amount of tokens to burn.
   */
  function freeze(uint256 _amount) public onlySaleAddress returns (bool) {
    reconcileDividend(msg.sender);
    require(_amount <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    totalSupply = totalSupply.sub(_amount);
    tokensFrozen = tokensFrozen.add(_amount);

    aum = aum.sub(tokenValue.mul(_amount).div(tokenPrecision));

    Freeze(msg.sender, _amount);
    Transfer(msg.sender, 0x0, _amount);
    return true;
  }

  /**
   * Calculate the divends for the current period given the AUM profit
   *
   * @param totalProfit is the amount of total profit in USD.
   */
  function reportProfit(int256 totalProfit, address saleAddress) public onlyTeam returns (bool) {
    // first we new dividends if this period was profitable
    if (totalProfit > 0) {
      // We only care about 50% of this, as the rest is reinvested right away
      uint256 profit = uint256(totalProfit).mul(tokenPrecision).div(2);

      // this will throw if there are not enough tokens
      addNewDividends(profit);
    }

    // then we drip
    drip(saleAddress);

    // adjust AUM
    aum = aum.add(uint256(totalProfit).mul(tokenPrecision));

    // register the sale address
    currentSaleAddress = saleAddress;

    return true;
  }


  function drip(address saleAddress) internal {
    uint256 dripTokens = tokensFrozen.div(dripRate);

    tokensFrozen = tokensFrozen.sub(dripTokens);
    totalSupply = totalSupply.add(dripTokens);
    aum = aum.add(tokenValue.mul(dripTokens).div(tokenPrecision));

    reconcileDividend(saleAddress);
    balances[saleAddress] = balances[saleAddress].add(dripTokens);
    Transfer(0x0, saleAddress, dripTokens);
  }

  /**
   * Calculate the divends for the current period given the dividend
   * amounts (USD * tokenPrecision).
   */
  function addNewDividends(uint256 profit) internal {
    uint256 newAum = aum.add(profit); // 18 sig digits
    tokenValue = newAum.mul(tokenPrecision).div(totalSupply); // 18 sig digits
    uint256 totalDividends = profit.mul(tokenPrecision).div(tokenValue); // 18 sig digits
    uint256 managementDividends = totalDividends.div(managementFees); // 17 sig digits
    uint256 dividendsIssued = totalDividends.sub(managementDividends); // 18 sig digits

    // make sure we have enough in the frozen fund
    require(tokensFrozen >= totalDividends);

    dividendSnapshots.push(DividendSnapshot(totalSupply, dividendsIssued, managementDividends));

    // add the previous amount of given dividends to the totalSupply
    totalSupply = totalSupply.add(totalDividends);
    tokensFrozen = tokensFrozen.sub(totalDividends);
  }

  /**
   * Withdraw all funds and kill fund smart contract
   */
  function liquidate() public onlyTeam returns (bool) {
    selfdestruct(owner);
  }


  // getter to retrieve divident owed
  function getOwedDividend(address _owner) public view returns (uint256 total, uint256[]) {
    uint256[] memory noDividends = new uint256[](0);
    // And the address' current balance
    uint256 balance = BasicToken.balanceOf(_owner);
    // retrieve index of last dividend this address received
    // NOTE: the default return value of a mapping is 0 in this case
    uint idx = lastDividend[_owner];
    if (idx == dividendSnapshots.length) return (total, noDividends);
    if (balance == 0 && team[_owner] != true) return (total, noDividends);

    uint256[] memory dividends = new uint256[](dividendSnapshots.length - idx - i);
    uint256 currBalance = balance;
    for (uint i = idx; i < dividendSnapshots.length; i++) {
      // We should be able to remove the .mul(tokenPrecision) and .div(tokenPrecision) and apply them once
      // at the beginning and once at the end, but we need to math it out
      uint256 dividend = currBalance.mul(tokenPrecision).div(dividendSnapshots[i].totalSupply).mul(dividendSnapshots[i].dividendsIssued).div(tokenPrecision);

      // Add the management dividends in equal parts if the current address is part of the team
      if (team[_owner] == true) {
        dividend = dividend.add(dividendSnapshots[i].managementDividends.div(teamNum));
      }

      total = total.add(dividend);

      dividends[i - idx] = dividend;

      currBalance = currBalance.add(dividend);
    }

    return (total, dividends);
  }

  // monkey patches
  function balanceOf(address _owner) public view returns (uint256) {
    var (owedDividend, /* dividends */) = getOwedDividend(_owner);
    return BasicToken.balanceOf(_owner).add(owedDividend);
  }


  // Reconcile all outstanding dividends for an address
  // into its balance.
  function reconcileDividend(address _owner) internal {
    var (owedDividend, dividends) = getOwedDividend(_owner);

    for (uint i = 0; i < dividends.length; i++) {
      if (dividends[i] > 0) {
        Reconcile(_owner, lastDividend[_owner] + i, dividends[i]);
        Transfer(0x0, _owner, dividends[i]);
      }
    }

    if(owedDividend > 0) {
      balances[_owner] = balances[_owner].add(owedDividend);
    }

    // register this user as being owed no further dividends
    lastDividend[_owner] = dividendSnapshots.length;
  }

  function transfer(address _to, uint256 _amount) public returns (bool) {
    reconcileDividend(msg.sender);
    reconcileDividend(_to);
    return BasicToken.transfer(_to, _amount);
  }

}