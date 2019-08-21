pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

// File: contracts/Lava.sol

contract Lava {

  using SafeMath for uint;

  struct Rand {
      address submitter;
      uint value;
  }

  struct PredUnit {
      address submitter;
      uint value;
  }

  event receivedRand(address indexed _from, uint _value);
  event receivedPred(address indexed _from, uint[] _window);
  event requestedRand(address indexed _from, uint _value); // who requested a value and the value they received

  uint MAXRAND = 100; // all rands, cyclical array
  uint RANDPRICE = 857 wei;
  uint RANDDEPOSIT = 1 wei;
  uint PREDWAGER = 1 wei;
  uint CURRIDX = 1; // current index in rands
  uint nWinners = 0;
  bool predPeat = false; // true if preders paid out >= once but can still win again if submitRand() has not been called since, else false

  mapping(uint => Rand) private rands; // cyclical array
  mapping(uint => bool) public randExists; // true if random number exists at index in cyclical array, else false
  mapping(uint => PredUnit) public winners; // winning PredUnits
  mapping(uint => PredUnit[]) public arrIdx2predUnitArr; // all predictions per each index in cyclical array
  mapping(uint => bool) public arrIdx2lost; // true if rander at index lost to a preder, else false (default false)

  constructor () public payable {
    for (uint i=0; i<MAXRAND; i++) {
      randExists[i] = false;
      arrIdx2lost[i] = false;
    }
    rands[0] = Rand({submitter: address(this), value: 0});
    arrIdx2lost[0] = true;
  }

  function submitRand(uint _value) public payable {
    // √ create Rand struct
    // √ add new Rand struct to rands
    // √ register/ledger deposit
    require(msg.value >= RANDDEPOSIT);
    require(_value >= 1); // min support
    require(_value <= 65536); // max support
    Rand memory newRand = Rand({
      submitter: msg.sender,
      value: _value
    });
    if (!arrIdx2lost[CURRIDX]) { rands[CURRIDX].submitter.transfer(RANDDEPOSIT); } // return deposit rander being booted from cyclical array
    rands[CURRIDX] = newRand;
    arrIdx2lost[CURRIDX] = false;
    randExists[CURRIDX] = true;
    if (predPeat) { delete arrIdx2predUnitArr[CURRIDX]; } // reset array
    predPeat = false;
    CURRIDX = (CURRIDX.add(1)).mod(MAXRAND);
    emit receivedRand(msg.sender, _value);
  }

  function submitPredWindow(uint[] _guess) public payable {
    // √ create accessible PredUnits
    // √ create accessible PredWindow
    // √ add to preds
    // √ register/ledger deposit
    require(msg.value >= PREDWAGER.mul(_guess.length)); // 1 wager per prediction
    require(_guess.length <= MAXRAND);
    uint outputIdx = wrapSub(CURRIDX, 1, MAXRAND);
    for (uint i=0; i<_guess.length; i++) {
      PredUnit memory newUnit = PredUnit({
        submitter: msg.sender,
        value: _guess[i]
      });
      arrIdx2predUnitArr[(i+outputIdx) % MAXRAND].push(newUnit);
    }
    emit receivedPred(msg.sender, _guess);
  }

  function requestRand() public payable returns (uint) {
    // √ register/ledger payment
    // √ initiates auditing process (was there a correct prediction)
    // √ sends payments to appropriate players (rander recency or preder relative wager)
    // √ returns rand from timeline of most current timestamp
    require(msg.value >= RANDPRICE);
    uint outputIdx = wrapSub(CURRIDX, 1, MAXRAND);
    uint idx;
    uint val;
    uint i;
    uint reward;
    if (predPeat) {
        reward = RANDPRICE.div(nWinners);
        for (i=0; i<nWinners; i++) { winners[i].submitter.transfer(reward); } // pay winning preders
    } else {
        nWinners = 0;
        for (i=0; i<arrIdx2predUnitArr[outputIdx].length; i++) {
          if (arrIdx2predUnitArr[outputIdx][i].value == rands[outputIdx].value) {
            winners[i] = arrIdx2predUnitArr[outputIdx][i]; // enumerate winning PredUnits
            nWinners++;
          }
        }
        if (nWinners > 0) { // at least one preder wins
          if (arrIdx2lost[outputIdx]) { reward = RANDPRICE.div(nWinners); } // if random number was predicted already or if constructor is rander
          else { reward = PREDWAGER.add(RANDPRICE.div(nWinners)); } // if random number was not predicted already
          for (i=0; i<nWinners; i++) { winners[i].submitter.transfer(reward); } // pay winning preders
          winners[0].submitter.transfer(address(this).balance); // send pot to first correct preder
          for (i=0; i<MAXRAND; i++) { arrIdx2lost[i] = true; } // all randers suffer
          predPeat = true;
        } else { // a single rander won, all recent randers get paid from earliest to last
          idx = wrapSub(outputIdx, 0, MAXRAND);
          rands[idx].submitter.transfer(RANDPRICE.div(4)); // extra winnings for the rander to submit the actual requested random number
          for (i=0; i<MAXRAND; i++) {
            idx = wrapSub(outputIdx, i, MAXRAND);
            val = i.add(2);
            if (randExists[idx]) { rands[idx].submitter.transfer(RANDPRICE.div(val.mul(val))); }
          }
        }
    }
    emit requestedRand(msg.sender, rands[outputIdx].value);
    return rands[outputIdx].value;
  }

  function wrapSub(uint a, uint b, uint c) public pure returns(uint) { return uint(int(a) - int(b)).mod(c); } // computes (a-b)%c

  function () public payable {}
}