pragma solidity ^0.4.8;

/**
 * Very basic owned/mortal boilerplate.  Used for basically everything, for
 * security/access control purposes.
 */
contract Owned {
  address owner;

  modifier onlyOwner {
    if (msg.sender != owner) {
      throw;
    }
    _;
  }

  /**
   * Basic constructor.  The sender is the owner.
   */
  function Owned() {
    owner = msg.sender;
  }

  /**
   * Transfers ownership of the contract to a new owner.
   * @param newOwner  Who gets to inherit this thing.
   */
  function transferOwnership(address newOwner) onlyOwner {
    owner = newOwner;
  }

  /**
   * Shuts down the contract and removes it from the blockchain state.
   * Only available to the owner.
   */
  function shutdown() onlyOwner {
    selfdestruct(owner);
  }

  /**
   * Withdraw all the funds from this contract.
   * Only available to the owner.
   */
  function withdraw() onlyOwner {
    if (!owner.send(this.balance)) {
      throw;
    }
  }
}

contract LotteryRoundInterface {
  bool public winningNumbersPicked;
  uint256 public closingBlock;

  function pickTicket(bytes4 picks) payable;
  function randomTicket() payable;

  function proofOfSalt(bytes32 salt, uint8 N) constant returns(bool);
  function closeGame(bytes32 salt, uint8 N);
  function claimOwnerFee(address payout);
  function withdraw();
  function shutdown();
  function distributeWinnings();
  function claimPrize();

  function paidOut() constant returns(bool);
  function transferOwnership(address newOwner);
}

/**
 * The meat of the game.  Holds all the rules around picking numbers,
 * attempting to establish good sources of entropy, holding the pre-selected
 * entropy sources (salt) in a way that is not publicly-revealed, etc.
 * The gist is that this is a bit of a PRNG, that advances its entropy each
 * time a ticket is picked.
 *
 * Provides the means to both pick specific numbers or have the PRNG select
 * them for the ticketholder.
 *
 * Also controls payout of winners for a particular round.
 */
contract LotteryRound is LotteryRoundInterface, Owned {

  /*
    Constants
   */
  // public version string
  string constant VERSION = '0.1.2';

  // round length
  uint256 constant ROUND_LENGTH = 43200;  // approximately a week

  // payout fraction (in thousandths):
  uint256 constant PAYOUT_FRACTION = 950;

  // Cost per ticket
  uint constant TICKET_PRICE = 1 finney;

  // valid pick mask
  bytes1 constant PICK_MASK = 0x3f; // 0-63

  /*
    Public variables
   */
  // Pre-selected salt, hashed N times
  // serves as proof-of-salt
  bytes32 public saltHash;

  // single hash of salt.N.salt
  // serves as proof-of-N
  // 0 < N < 256
  bytes32 public saltNHash;

  // closing time.
  uint256 public closingBlock;

  // winning numbers
  bytes4 public winningNumbers;

  // This becomes true when the numbers have been picked
  bool public winningNumbersPicked = false;

  // This becomes populated if anyone wins
  address[] public winners;

  // Stores a flag to signal if the winner has winnings to be claimed
  mapping(address => bool) public winningsClaimable;

  /**
   * Current picks are from 0 to 63, or 2^6 - 1.
   * Current number of picks is 4
   * Rough odds of winning will be 1 in (2^6)^4, assuming even distributions, etc
   */
  mapping(bytes4 => address[]) public tickets;
  uint256 public nTickets = 0;

  // Set when winners are drawn, and represents the amount of the contract's current balance that can be paid out.
  uint256 public prizePool;

  // Set when winners are drawn, and signifies the amount each winner will receive.  In the event of multiple
  // winners, this will be prizePool / winners.length
  uint256 public prizeValue;

  // The fee at the time winners were picked (if there were winners).  This is the portion of the contract's balance
  // that goes to the contract owner.
  uint256 public ownerFee;

  // This will be the sha3 hash of the previous entropy + some additional inputs (e.g. randomly-generated hashes, etc)
  bytes32 private accumulatedEntropy;

  modifier beforeClose {
    if (block.number > closingBlock) {
      throw;
    }
    _;
  }

  modifier beforeDraw {
    if (block.number <= closingBlock || winningNumbersPicked) {
      throw;
    }
    _;
  }

  modifier afterDraw {
    if (winningNumbersPicked == false) {
      throw;
    }
    _;
  }

  // Emitted when the round starts, broadcasting the hidden entropy params, closing block
  // and game version.
  event LotteryRoundStarted(
    bytes32 saltHash,
    bytes32 saltNHash,
    uint256 closingBlock,
    string version
  );

  // Broadcasted any time a user purchases a ticket.
  event LotteryRoundDraw(
    address indexed ticketHolder,
    bytes4 indexed picks
  );

  // Broadcast when the round is completed, revealing the hidden entropy sources
  // and the winning picks.
  event LotteryRoundCompleted(
    bytes32 salt,
    uint8 N,
    bytes4 indexed winningPicks,
    uint256 closingBalance
  );

  // Broadcast for each winner.
  event LotteryRoundWinner(
    address indexed ticketHolder,
    bytes4 indexed picks
  );

  /**
   * Creates a new Lottery round, and sets the round's parameters.
   *
   * Note that this will implicitly set the factory to be the owner,
   * meaning the factory will need to be able to transfer ownership,
   * to its owner, the C&C contract.
   *
   * @param _saltHash       Hashed salt.  Will be hashed with sha3 N times
   * @param _saltNHash      Hashed proof of N, in the format sha3(salt+N+salt)
   */
  function LotteryRound(
    bytes32 _saltHash,
    bytes32 _saltNHash
  ) payable {
    saltHash = _saltHash;
    saltNHash = _saltNHash;
    closingBlock = block.number + ROUND_LENGTH;
    LotteryRoundStarted(
      saltHash,
      saltNHash,
      closingBlock,
      VERSION
    );
    // start this off with some really poor entropy.
    accumulatedEntropy = block.blockhash(block.number - 1);
  }

  /**
   * Attempt to generate a new pseudo-random number, while advancing the internal entropy
   * of the contract.  Uses a two-phase approach: first, generates a simple offset [0-255]
   * from simple entropy sources (accumulated, sender, block number).  Uses this offset
   * to index into the history of blockhashes, to attempt to generate some stronger entropy
   * by including previous block hashes.
   *
   * Then advances the interal entropy by rehashing it with the chosen number.
   */
  function generatePseudoRand(bytes32 seed) internal returns(bytes32) {
    uint8 pseudoRandomOffset = uint8(uint256(sha256(
      seed,
      block.difficulty,
      block.coinbase,
      block.timestamp,
      accumulatedEntropy
    )) & 0xff);
    // WARNING: This assumes block.number > 256... If block.number < 256, the below block.blockhash could return 0
    // This is probably only an issue in testing, but shouldn't be a problem there.
    uint256 pseudoRandomBlock = block.number - pseudoRandomOffset - 1;
    bytes32 pseudoRand = sha3(
      block.number,
      block.blockhash(pseudoRandomBlock),
      block.difficulty,
      block.timestamp,
      accumulatedEntropy
    );
    accumulatedEntropy = sha3(accumulatedEntropy, pseudoRand);
    return pseudoRand;
  }

  /**
   * Buy a ticket with pre-selected picks
   * @param picks User's picks.
   */
  function pickTicket(bytes4 picks) payable beforeClose {
    if (msg.value != TICKET_PRICE) {
      throw;
    }
    // don't allow invalid picks.
    for (uint8 i = 0; i < 4; i++) {
      if (picks[i] & PICK_MASK != picks[i]) {
        throw;
      }
    }
    tickets[picks].push(msg.sender);
    nTickets++;
    generatePseudoRand(bytes32(picks)); // advance the accumulated entropy
    LotteryRoundDraw(msg.sender, picks);
  }

  /**
   * Interal function to generate valid picks.  Used by both the random
   * ticket functionality, as well as when generating winning picks.
   * Even though the picks are a fixed-width byte array, each pick is
   * chosen separately (e.g. a bytes4 will result in 4 separate sha3 hashes
   * used as sources).
   *
   * Masks the first byte of the seed to use as an offset into the next PRNG,
   * then replaces the seed with the new PRNG.  Pulls a single byte from the
   * resultant offset, masks it to be valid, then adds it to the accumulator.
   *
   * @param seed  The PRNG seed used to pick the numbers.
   */
  function pickValues(bytes32 seed) internal returns (bytes4) {
    bytes4 picks;
    uint8 offset;
    for (uint8 i = 0; i < 4; i++) {
      offset = uint8(seed[0]) & 0x1f;
      seed = sha3(seed, msg.sender);
      picks = (picks >> 8) | bytes1(seed[offset] & PICK_MASK);
    }
    return picks;
  }

  /**
   * Picks a random ticket, using the internal PRNG and accumulated entropy
   */
  function randomTicket() payable beforeClose {
    if (msg.value != TICKET_PRICE) {
      throw;
    }
    bytes32 pseudoRand = generatePseudoRand(bytes32(msg.sender));
    bytes4 picks = pickValues(pseudoRand);
    tickets[picks].push(msg.sender);
    nTickets++;
    LotteryRoundDraw(msg.sender, picks);
  }

  /**
   * Public means to prove the salt after numbers are picked.  Not technically necessary
   * for this to be external, because it will be called during the round close process.
   * If the hidden entropy parameters don't match, the contract will refuse to pick
   * numbers or close.
   *
   * @param salt          Hidden entropy source
   * @param N             Secret value proving how to obtain the hashed entropy from the source.
   */
  function proofOfSalt(bytes32 salt, uint8 N) constant returns(bool) {
    // Proof-of-N:
    bytes32 _saltNHash = sha3(salt, N, salt);
    if (_saltNHash != saltNHash) {
      return false;
    }

    // Proof-of-salt:
    bytes32 _saltHash = sha3(salt);
    for (var i = 1; i < N; i++) {
      _saltHash = sha3(_saltHash);
    }
    if (_saltHash != saltHash) {
      return false;
    }
    return true;
  }

  /**
   * Internal function to handle tabulating the winners, including edge cases around
   * duplicate winners.  Split out into its own method partially to enable proper
   * testing.
   *
   * @param salt          Hidden entropy source.  Emitted here
   * @param N             Key to the hidden entropy source.
   * @param winningPicks  The winning picks.
   */
  function finalizeRound(bytes32 salt, uint8 N, bytes4 winningPicks) internal {
    winningNumbers = winningPicks;
    winningNumbersPicked = true;
    LotteryRoundCompleted(salt, N, winningNumbers, this.balance);

    var _winners = tickets[winningNumbers];
    // if we have winners:
    if (_winners.length > 0) {
      // let's dedupe and broadcast the winners before figuring out the prize pool situation.
      for (uint i = 0; i < _winners.length; i++) {
        var winner = _winners[i];
        if (!winningsClaimable[winner]) {
          winners.push(winner);
          winningsClaimable[winner] = true;
          LotteryRoundWinner(winner, winningNumbers);
        }
      }
      // now let's wrap this up by finalizing the prize pool value:
      // There may be some rounding errors in here, but it should only amount to a couple wei.
      prizePool = this.balance * PAYOUT_FRACTION / 1000;
      prizeValue = prizePool / winners.length;

      // Note that the owner doesn't get to claim a fee until the game is won.
      ownerFee = this.balance - prizePool;
    }
    // we done.
  }

  /**
   * Reveal the secret sources of entropy, then use them to pick winning numbers.
   *
   * Note that by using no dynamic (e.g. blockhash-based) sources of entropy,
   * censoring this transaction will not change the final outcome of the picks.
   *
   * @param salt          Hidden entropy.
   * @param N             Number of times to hash the hidden entropy to produce the value provided at creation.
   */
  function closeGame(bytes32 salt, uint8 N) onlyOwner beforeDraw {
    // Don't allow picking numbers multiple times.
    if (winningNumbersPicked == true) {
      throw;
    }

    // prove the pre-selected salt is actually legit.
    if (proofOfSalt(salt, N) != true) {
      throw;
    }

    bytes32 pseudoRand = sha3(
      salt,
      nTickets,
      accumulatedEntropy
    );
    finalizeRound(salt, N, pickValues(pseudoRand));
  }

  /**
   * Sends the owner's fee to the specified address.  Note that the
   * owner can only be paid if there actually was a winner. In the
   * event no one wins, the entire balance is carried over into the
   * next round.  No double-dipping here.
   * @param payout        Address to send the owner fee to.
   */
  function claimOwnerFee(address payout) onlyOwner afterDraw {
    if (ownerFee > 0) {
      uint256 value = ownerFee;
      ownerFee = 0;
      if (!payout.send(value)) {
        throw;
      }
    }
  }

  /**
   * Used to withdraw the balance when the round is completed.  This
   * only works if there are either no winners, or all winners + the
   * owner have been paid.
   */
  function withdraw() onlyOwner afterDraw {
    if (paidOut() && ownerFee == 0) {
      if (!owner.send(this.balance)) {
        throw;
      }
    }
  }

  /**
   * Same as above.  This is mostly here because it's overriding the method
   * inherited from `Owned`
   */
  function shutdown() onlyOwner afterDraw {
    if (paidOut() && ownerFee == 0) {
      selfdestruct(owner);
    }
  }

  /**
   * Attempt to pay the winners, if any.  If any `send`s fail, the winner
   * will have to collect their winnings on their own.
   */
  function distributeWinnings() onlyOwner afterDraw {
    if (winners.length > 0) {
      for (uint i = 0; i < winners.length; i++) {
        address winner = winners[i];
        bool unclaimed = winningsClaimable[winner];
        if (unclaimed) {
          winningsClaimable[winner] = false;
          if (!winner.send(prizeValue)) {
            // If I can't send you money, dumbshit, you get to claim it on your own.
            // maybe next time don't use a contract or try to exploit the game.
            // Regardless, you're on your own.  Happy birthday to the ground.
            winningsClaimable[winner] = true;
          }
        }
      }
    }
  }

  /**
   * Returns true if it's after the draw, and either there are no winners, or all the winners have been paid.
   * @return {bool}
   */
  function paidOut() constant returns(bool) {
    // no need to use the modifier on this function, just do the same check
    // and return false instead.
    if (winningNumbersPicked == false) {
      return false;
    }
    if (winners.length > 0) {
      bool claimed = true;
      // if anyone hasn't been sent or claimed their earnings,
      // we still have money to pay out.
      for (uint i = 0; claimed && i < winners.length; i++) {
        claimed = claimed && !winningsClaimable[winners[i]];
      }
      return claimed;
    } else {
      // no winners, nothing to pay.
      return true;
    }
  }

  /**
   * Winners can claim their own prizes using this.  If they do
   * something stupid like use a contract, this gives them a
   * a second chance at withdrawing their funds.  Note that
   * this shares an interlock with `distributeWinnings`.
   */
  function claimPrize() afterDraw {
    if (winningsClaimable[msg.sender] == false) {
      // get. out!
      throw;
    }
    winningsClaimable[msg.sender] = false;
    if (!msg.sender.send(prizeValue)) {
      // you really are a dumbshit, aren't you.
      throw;
    }
  }

  // Man! What do I look like? A charity case?
  // Please.
  // You can't buy me, hot dog man!
  function () {
    throw;
  }
}