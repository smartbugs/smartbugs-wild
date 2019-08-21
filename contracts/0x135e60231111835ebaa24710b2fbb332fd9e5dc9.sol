pragma solidity ^0.5.0;

/**
 *
 * @author Alejandro Diaz <Alejandro.Diaz.666@protonmail.com>
 *
 * Overview:
 * This is an implimentation of a dividend-paying token, with a special transfer from a holding address.
 * A fixed number of tokens are minted in the constructor, with some amount initially owned by the contract
 * owner; and some amount owned by a reserve address. The reserve address cannot transfer tokens to any
 * other address, except as directed by a trusted partner-contract.
 *
 * Dividends are awarded token holders following the technique outlined by Nick Johnson in
 *  https://medium.com/ @ weka/dividend-bearing-tokens-on-ethereum-42d01c710657
 *
 * The technique is:
 *   previous_due + [ p(x) * t(x)/N ] + [ p(x+1) * t(x+1)/N ] + ...
 *   where p(x) is the x'th income payment received by the contract
 *         t(x) is the number of tokens held by the token-holder at the time of p(x)
 *         N    is the total number of tokens, which never changes
 *
 * assume that t(x) takes on 3 values, t(a), t(b) and t(c), at times a, b, and c;
 * and that there are multiple payments at times between a and b: x, x+1, x+2...
 * and multiple payments at times between b and c: y, x+y, y+2...
 * and multiple payments at times greater than c: z, z+y, z+2...
 * then factoring:
 *
 *   current_due = { (t(a) * [p(x) + p(x+1)]) ... + (t(a) * [p(x) + p(y-1)]) ... +
 *                   (t(b) * [p(y) + p(y+1)]) ... + (t(b) * [p(y) + p(z-1)]) ... +
 *                   (t(c) * [p(z) + p(z+1)]) ... + (t(c) * [p(z) + p(now)]) } / N
 *
 * or
 *
 *   current_due = { (t(a) * period_a_income) +
 *                   (t(b) * period_b_income) +
 *                   (t(c) * period_c_income) } / N
 *
 * if we designate current_due * N as current-points, then
 *
 *   currentPoints = {  (t(a) * period_a_income) +
 *                      (t(b) * period_b_income) +
 *                      (t(c) * period_c_income) }
 *
 * or more succictly, if we recompute current points before a token-holder's number of
 * tokens, T, is about to change:
 *
 *   currentPoints = previous_points + (T * current-period-income)
 *
 * when we want to do a payout, we'll calculate:
 *  current_due = current-points / N
 *
 * we'll keep track of a token-holder's current-period-points, which is:
 *   T * current-period-income
 * by taking a snapshot of income collected exactly when the current period began; that is, the when the
 * number of tokens last changed. that is, we keep a running count of total income received
 *
 *   totalIncomeReceived = p(x) + p(x+1) + p(x+2)
 *
 * (which happily is the same for all token holders) then, before any token holder changes their number of
 * tokens we compute (for that token holder):
 *
 *  function calcCurPointsForAcct(acct) {
 *    currentPoints[acct] += (totalIncomeReceived - lastSnapshot[acct]) * T[acct]
 *    lastSnapshot[acct] = totalIncomeReceived
 *  }
 *
 * in the withdraw fcn, all we need is:
 *
 *  function withdraw(acct) {
 *    calcCurPointsForAcct(acct);
 *    current_amount_due = currentPoints[acct] / N
 *    currentPoints[acct] = 0;
 *    send(current_amount_due);
 *  }
 *
 */
//import './SafeMath.sol';
/*
    Overflow protected math functions
*/
contract SafeMath {
    /**
        constructor
    */
    constructor() public {
    }

    /**
        @dev returns the sum of _x and _y, asserts if the calculation overflows

        @param _x   value 1
        @param _y   value 2

        @return sum
    */
    function safeAdd(uint256 _x, uint256 _y) pure internal returns (uint256) {
        uint256 z = _x + _y;
        assert(z >= _x);
        return z;
    }

    /**
        @dev returns the difference of _x minus _y, asserts if the subtraction results in a negative number

        @param _x   minuend
        @param _y   subtrahend

        @return difference
    */
    function safeSub(uint256 _x, uint256 _y) pure internal returns (uint256) {
        assert(_x >= _y);
        return _x - _y;
    }

    /**
        @dev returns the product of multiplying _x by _y, asserts if the calculation overflows

        @param _x   factor 1
        @param _y   factor 2

        @return product
    */
    function safeMul(uint256 _x, uint256 _y) pure internal returns (uint256) {
        uint256 z = _x * _y;
        assert(_x == 0 || z / _x == _y);
        return z;
    }
}

//import './iERC20Token.sol';
// Token standard API
// https://github.com/ethereum/EIPs/issues/20
contract iERC20Token {
  function balanceOf( address who ) public view returns (uint value);
  function allowance( address owner, address spender ) public view returns (uint remaining);

  function transfer( address to, uint value) public returns (bool ok);
  function transferFrom( address from, address to, uint value) public returns (bool ok);
  function approve( address spender, uint value ) public returns (bool ok);

  event Transfer( address indexed from, address indexed to, uint value);
  event Approval( address indexed owner, address indexed spender, uint value);

  //these are implimented via automatic getters
  //function name() public view returns (string _name);
  //function symbol() public view returns (string _symbol);
  //function decimals() public view returns (uint8 _decimals);
  //function totalSupply() public view returns (uint256 _totalSupply);
}

//import './iDividendToken.sol';
// simple interface for withdrawing dividends
contract iDividendToken {
  function checkDividends(address _addr) view public returns(uint _ethAmount);
  function withdrawDividends() public returns (uint _amount);
}

//import './iPlpPointsRedeemer.sol';
// interface for redeeming PLP Points
contract iPlpPointsRedeemer {
  function reserveTokens() public view returns (uint remaining);
  function transferFromReserve(address _to, uint _value) public;
}

contract PirateLotteryProfitToken is iERC20Token, iDividendToken, iPlpPointsRedeemer, SafeMath {

  event PaymentEvent(address indexed from, uint amount);
  event TransferEvent(address indexed from, address indexed to, uint amount);
  event ApprovalEvent(address indexed from, address indexed to, uint amount);

  struct tokenHolder {
    uint tokens;           // num tokens currently held in this acct, aka balance
    uint currentPoints;    // updated before token balance changes, or before a withdrawal. credit for owning tokens
    uint lastSnapshot;     // snapshot of global TotalPoints, last time we updated this acct's currentPoints
  }

  bool    public isLocked;
  uint8   public decimals;
  string  public symbol;
  string  public name;
  address payable public owner;
  address payable public reserve;            // reserve account
  uint256 public  totalSupply;               // total token supply. never changes
  uint256 public  holdoverBalance;           // funds received, but not yet distributed
  uint256 public  totalReceived;

  mapping (address => mapping (address => uint)) approvals;  //transfer approvals, from -> to
  mapping (address => tokenHolder) public tokenHolders;
  mapping (address => bool) public trusted;


  //
  // modifiers
  //
  modifier ownerOnly {
    require(msg.sender == owner, "owner only");
    _;
  }
  modifier unlockedOnly {
    require(!isLocked, "unlocked only");
    _;
  }
  modifier notReserve {
    require(msg.sender != reserve, "reserve is barred");
    _;
  }
  modifier trustedOnly {
    require(trusted[msg.sender] == true, "trusted only");
    _;
  }
  //this is to protect from short-address attack. use this to verify size of args, especially when an address arg preceeds
  //a value arg. see: https://www.reddit.com/r/ethereum/comments/63s917/worrysome_bug_exploit_with_erc20_token/dfwmhc3/
  modifier onlyPayloadSize(uint256 size) {
    assert(msg.data.length >= size + 4);
    _;
  }

  //
  //constructor
  //
  constructor(uint256 _totalSupply, uint256 _reserveSupply, address payable _reserve, uint8 _decimals, string memory _name, string memory _symbol) public {
    totalSupply = _totalSupply;
    reserve = _reserve;
    decimals = _decimals;
    name = _name;
    symbol = _symbol;
    owner = msg.sender;
    tokenHolders[reserve].tokens = _reserveSupply;
    tokenHolders[owner].tokens = safeSub(totalSupply, _reserveSupply);
  }

  function setTrust(address _trustedAddr, bool _trust) public ownerOnly unlockedOnly {
    trusted[_trustedAddr] = _trust;
  }

  function lock() public ownerOnly {
    isLocked = true;
  }


  //
  // ERC-20
  //
  function transfer(address _to, uint _value) public onlyPayloadSize(2*32) notReserve returns (bool success) {
    if (tokenHolders[msg.sender].tokens >= _value) {
      //first credit sender with points accrued so far.. must do this before number of held tokens changes
      calcCurPointsForAcct(msg.sender);
      tokenHolders[msg.sender].tokens = safeSub(tokenHolders[msg.sender].tokens, _value);
      //if destination is a new tokenholder then we are setting his "last" snapshot to the current totalPoints
      if (tokenHolders[_to].lastSnapshot == 0)
        tokenHolders[_to].lastSnapshot = totalReceived;
      //credit destination acct with points accrued so far.. must do this before number of held tokens changes
      calcCurPointsForAcct(_to);
      tokenHolders[_to].tokens = safeAdd(tokenHolders[_to].tokens, _value);
      emit TransferEvent(msg.sender, _to, _value);
      return true;
    } else {
      return false;
    }
  }


  // transfer from reserve is prevented by preventing reserve from generating approval
  function transferFrom(address _from, address _to, uint _value) onlyPayloadSize(3*32) public returns (bool success) {
    //prevent wrap:
    if (tokenHolders[_from].tokens >= _value && approvals[_from][msg.sender] >= _value) {
      //first credit source acct with points accrued so far.. must do this before number of held tokens changes
      calcCurPointsForAcct(_from);
      tokenHolders[_from].tokens = safeSub(tokenHolders[_from].tokens, _value);
      //if destination is a new tokenreserve then we are setting his "last" snapshot to the current totalPoints
      if (tokenHolders[_to].lastSnapshot == 0)
        tokenHolders[_to].lastSnapshot = totalReceived;
      //credit destination acct with points accrued so far.. must do this before number of held tokens changes
      calcCurPointsForAcct(_to);
      tokenHolders[_to].tokens = safeAdd(tokenHolders[_to].tokens, _value);
      approvals[_from][msg.sender] = safeSub(approvals[_from][msg.sender], _value);
      emit TransferEvent(_from, _to, _value);
      return true;
    } else {
      return false;
    }
  }


  function balanceOf(address _owner) public view returns (uint balance) {
    balance = tokenHolders[_owner].tokens;
  }


  function approve(address _spender, uint _value) public onlyPayloadSize(2*32) notReserve returns (bool success) {
    approvals[msg.sender][_spender] = _value;
    emit ApprovalEvent(msg.sender, _spender, _value);
    return true;
  }


  function allowance(address _owner, address _spender) public view returns (uint remaining) {
    return approvals[_owner][_spender];
  }

  //
  // END ERC20
  //


  //
  // iTransferPointsRedeemer
  //
  function reserveTokens() public view returns (uint remaining) {
    return tokenHolders[reserve].tokens;
  }


  //
  // transfer from reserve, initiated from a trusted partner-contract
  //
  function transferFromReserve(address _to, uint _value) onlyPayloadSize(2*32) public trustedOnly {
    require(_value >= 10 || tokenHolders[reserve].tokens < 10, "minimum redmption is 10 tokens");
    require(tokenHolders[reserve].tokens >= _value, "reserve has insufficient tokens");
    //first credit source acct with points accrued so far.. must do this before number of held tokens changes
    calcCurPointsForAcct(reserve);
    tokenHolders[reserve].tokens = safeSub(tokenHolders[reserve].tokens, _value);
    //if destination is a new tokenholder then we are setting his "last" snapshot to the current totalPoints
    if (tokenHolders[_to].lastSnapshot == 0)
      tokenHolders[_to].lastSnapshot = totalReceived;
    //credit destination acct with points accrued so far.. must do this before number of held tokens changes
    calcCurPointsForAcct(_to);
    tokenHolders[_to].tokens = safeAdd(tokenHolders[_to].tokens, _value);
    emit TransferEvent(reserve, _to, _value);
  }


  //
  // calc current points for a token holder; that is, points that are due to this token holder for all dividends
  // received by the contract during the current "period". the period began the last time this fcn was called, at which
  // time we updated the account's snapshot of the running point count, totalReceived. during the period the account's
  // number of tokens must not have changed. so always call this fcn before changing the number of tokens.
  //
  function calcCurPointsForAcct(address _acct) internal {
    uint256 _newPoints = safeMul(safeSub(totalReceived, tokenHolders[_acct].lastSnapshot), tokenHolders[_acct].tokens);
    tokenHolders[_acct].currentPoints = safeAdd(tokenHolders[_acct].currentPoints, _newPoints);
    tokenHolders[_acct].lastSnapshot = totalReceived;
  }


  //
  // default payable function. funds receieved here become dividends.
  //
  function () external payable {
    holdoverBalance = safeAdd(holdoverBalance, msg.value);
    totalReceived = safeAdd(totalReceived, msg.value);
  }


  //
  // check my dividends
  //
  function checkDividends(address _addr) view public returns(uint _amount) {
    //don't call calcCurPointsForAcct here, cuz this is a constant fcn
    uint _currentPoints = tokenHolders[_addr].currentPoints +
      ((totalReceived - tokenHolders[_addr].lastSnapshot) * tokenHolders[_addr].tokens);
    _amount = _currentPoints / totalSupply;
  }


  //
  // withdraw my dividends
  //
  function withdrawDividends() public returns (uint _amount) {
    calcCurPointsForAcct(msg.sender);
    _amount = tokenHolders[msg.sender].currentPoints / totalSupply;
    uint _pointsUsed = safeMul(_amount, totalSupply);
    tokenHolders[msg.sender].currentPoints = safeSub(tokenHolders[msg.sender].currentPoints, _pointsUsed);
    holdoverBalance = safeSub(holdoverBalance, _amount);
    msg.sender.transfer(_amount);
  }


  //only available before the contract is locked
  function killContract() public ownerOnly unlockedOnly {
    selfdestruct(owner);
  }

}