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

contract LotteryRoundFactoryInterface {
  string public VERSION;
  function transferOwnership(address newOwner);
}

contract LotteryRoundFactoryInterfaceV1 is LotteryRoundFactoryInterface {
  function createRound(bytes32 _saltHash, bytes32 _saltNHash) payable returns(address);
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
 * The base interface is what the parent contract expects to be able to use.
 * If rules change in the future, and new logic is introduced, it only has to
 * implement these methods, wtih the role of the curator being used
 * to execute the additional functionality (if any).
 */
contract LotteryGameLogicInterface {
  address public currentRound;
  function finalizeRound() returns(address);
  function isUpgradeAllowed() constant returns(bool);
  function transferOwnership(address newOwner);
}

contract LotteryGameLogicInterfaceV1 is LotteryGameLogicInterface {
  function deposit() payable;
  function setCurator(address newCurator);
}


/**
 * Core game logic.  Handlings management of rounds, carry-over balances,
 * paying winners, etc.  Separate from the main contract because it's more
 * tightly-coupled to the factory/round logic than the game logic.  This
 * allows for new rules in the future (e.g. partial picks, etc).  Carries
 * the caveat that it cannot be upgraded until the current rules produce
 * a winner, and can only be upgraded in the period between a winner under
 * the current rules and the next round being started.
 */
contract LotteryGameLogic is LotteryGameLogicInterfaceV1, Owned {

  LotteryRoundFactoryInterfaceV1 public roundFactory;

  address public curator;

  LotteryRoundInterface public currentRound;

  modifier onlyWhenNoRound {
    if (currentRound != LotteryRoundInterface(0)) {
      throw;
    }
    _;
  }

  modifier onlyBeforeDraw {
    if (
      currentRound == LotteryRoundInterface(0) ||
      block.number <= currentRound.closingBlock() ||
      currentRound.winningNumbersPicked() == true
    ) {
      throw;
    }
    _;
  }

  modifier onlyAfterDraw {
    if (
      currentRound == LotteryRoundInterface(0) ||
      currentRound.winningNumbersPicked() == false
    ) {
      throw;
    }
    _;
  }

  modifier onlyCurator {
    if (msg.sender != curator) {
      throw;
    }
    _;
  }

  modifier onlyFromCurrentRound {
    if (msg.sender != address(currentRound)) {
      throw;
    }
    _;
  }

  /**
   * Creates the core logic of the lottery.  Requires a round factory
   * and an initial curator.
   * @param _roundFactory  The factory to generate new rounds
   * @param _curator       The initial curator
   */
  function LotteryGameLogic(address _roundFactory, address _curator) {
    roundFactory = LotteryRoundFactoryInterfaceV1(_roundFactory);
    curator = _curator;
  }

  /**
   * Allows the curator to hand over curation responsibilities to someone else.
   * @param newCurator  The new curator
   */
  function setCurator(address newCurator) onlyCurator onlyWhenNoRound {
    curator = newCurator;
  }

  /**
   * Specifies whether or not upgrading this contract is allowed.  In general, if there
   * is a round underway, or this contract is holding a balance, upgrading is not allowed.
   */
  function isUpgradeAllowed() constant returns(bool) {
    return currentRound == LotteryRoundInterface(0) && this.balance < 1 finney;
  }

  /**
   * Starts a new round.  Can only be started by the curator, and only when there is no round
   * currently underway
   * @param saltHash    Secret salt, hashed N times.
   * @param saltNHash   Proof of N, in the form of sha3(salt, N, salt)
   */
  function startRound(bytes32 saltHash, bytes32 saltNHash) onlyCurator onlyWhenNoRound {
    if (this.balance > 0) {
      currentRound = LotteryRoundInterface(
        roundFactory.createRound.value(this.balance)(saltHash, saltNHash)
      );
    } else {
      currentRound = LotteryRoundInterface(roundFactory.createRound(saltHash, saltNHash));
    }
  }

  /**
   * Reveal the chosen salt and number of hash iterations, then close the current roundn
   * and pick the winning numbers
   * @param salt   The original salt
   * @param N      The original N
   */
  function closeRound(bytes32 salt, uint8 N) onlyCurator onlyBeforeDraw {
    currentRound.closeGame(salt, N);
  }

  /**
   * Finalize the round before returning it back to the the parent contract for
   * historical purposes.  Attempts to pay winners and the curator if there was a winning
   * draw, otherwise, pulls the balance out of the round before handing over ownership
   * to the curator.
   */
  function finalizeRound() onlyOwner onlyAfterDraw returns(address) {
    address roundAddress = address(currentRound);
    if (!currentRound.paidOut()) {
      // we'll only make one attempt here to pay the winners
      currentRound.distributeWinnings();
      currentRound.claimOwnerFee(curator);
    } else if (currentRound.balance > 0) {
      // otherwise, we have no winners, so just pull out funds in
      // preparation for the next round.
      currentRound.withdraw();
    }

    // be sure someone can handle disputes, etc, if they arise.
    // not that they'll be able to *do* anything, but they can at least
    // try calling `distributeWinnings()` again...
    currentRound.transferOwnership(curator);

    // clear this shit out.
    delete currentRound;

    // if there are or were any problems distributing winnings, the winners can attempt to withdraw
    // funds for themselves.  The contracts won't be destroyed so long as they have funds to pay out.
    // handling them might require special care or something.

    return roundAddress;
  }

  /**
   * Mostly just used for testing.  Technically, this contract may be seeded with an initial deposit
   * before
   */
  function deposit() payable onlyOwner onlyWhenNoRound {
    // noop, just used for depositing funds during an upgrade.
  }

  /**
   * Only accept payments from the current round.  Required due to calling `.withdraw` at round's end.
   */
  function () payable onlyFromCurrentRound {
    // another noop, since we can only receive funds from the current round.
  }
}