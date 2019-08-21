// A Ponzi scheme where old investors are payed with the funds received from new investors.
// Unlike what is out there in the market, the contract creator received no funds - if you
// don't do work, you cannot expect to be paid. People who put in the funds receive all the
// returns. Owners can particiapte themselves, there is no leaching off the top and slowing
// down payouts for the participants.
contract ZeroPonzi {
  // minimum & maxium entry values
  uint public constant MIN_VALUE = 100 finney;
  uint public constant MAX_VALUE = 10 ether;

  // the return multiplier & divisors, yielding 1.25 (125%) returns
  uint public constant RET_MUL = 125;
  uint public constant RET_DIV = 100;

  // entry structure, storing the address & yield
  struct Payout {
    address addr;
    uint yield;
  }

  // our actual queued payouts, index of current & total distributed
  Payout[] public payouts;
  uint public payoutIndex = 0;
  uint public payoutTotal = 0;

  // construtor, no additional requirements
  function ZeroPonzi() {
  }

  // single entry point, add entry & pay what we can
  function() {
    // we only accept values in range
    if ((msg.value < MIN_VALUE) || (msg.value > MAX_VALUE)) {
      throw;
    }

    // queue the current entry as a future payout recipient
    uint entryIndex = payouts.length;
    payouts.length += 1;
    payouts[entryIndex].addr = msg.sender;
    payouts[entryIndex].yield = (msg.value * RET_MUL) / RET_DIV;

    // send payouts while we can afford to do so
    while (payouts[payoutIndex].yield < this.balance) {
      payoutTotal += payouts[payoutIndex].yield;
      payouts[payoutIndex].addr.send(payouts[payoutIndex].yield);
      payoutIndex += 1;
    }
  }
}