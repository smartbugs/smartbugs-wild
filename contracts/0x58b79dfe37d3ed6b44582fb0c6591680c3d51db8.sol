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

/**
 * This contract is pretty generic, as it really only serves to maintain a constant
 * address on the blockchain (through upgrades to the game logic), and to maintain
 * a history of previous rounds.  Note that the rounds will have had ownership
 * transferred to the curator (most likely), so there's mostly just here for
 * accounting purposes.
 *
 * A side effect of this is that finalizing a round has to happen from here.
 */
contract Lotto is Owned {

  address[] public previousRounds;

  LotteryGameLogicInterface public gameLogic;

  modifier onlyWhenUpgradeable {
    if (!gameLogic.isUpgradeAllowed()) {
      throw;
    }
    _;
  }

  modifier onlyGameLogic {
    if (msg.sender != address(gameLogic)) {
      throw;
    }
    _;
  }

  /**
   * Creates a new lottery contract.
   * @param initialGameLogic   The starting game logic.
   */
  function Lotto(address initialGameLogic) {
    gameLogic = LotteryGameLogicInterface(initialGameLogic);
  }

  /**
   * Upgrade the game logic.  Only possible to do when the game logic
   * has deemed it clear to do so.  Hands the old one over to the owner
   * for cleanup.  Expects the new logic to already be configured.
   * @param newLogic   New, already-configured game logic.
   */
  function setNewGameLogic(address newLogic) onlyOwner onlyWhenUpgradeable {
    gameLogic.transferOwnership(owner);
    gameLogic = LotteryGameLogicInterface(newLogic);
  }

  /**
   * Returns the current round.
   * @return address The current round (when applicable)
   */
  function currentRound() constant returns(address) {
    return gameLogic.currentRound();
  }

  /**
   * Used to finalize (e.g. pay winners) the current round, then log
   * it in the history.
   */
  function finalizeRound() onlyOwner {
    address roundAddress = gameLogic.finalizeRound();
    previousRounds.push(roundAddress);
  }

  /**
   * Tells how many previous rounds exist.
   */
  function previousRoundsCount() constant returns(uint) {
    return previousRounds.length;
  }

  // You must think I'm a joke
  // I ain't gonna be part of your system
  // Man! Pump that garbage in another man's veins
  function () {
    throw;
  }
}