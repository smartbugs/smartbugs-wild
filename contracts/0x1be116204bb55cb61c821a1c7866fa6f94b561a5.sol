/*
The MIT License (MIT)

Copyright (c) 2016 DFINITY Stiftung 

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

/**
 * title:  The DFINITY Stiftung donation contract (FDC).
 * author: Timo Hanke 
 *
 * This contract 
 *  - accepts on-chain donations for the foundation in ether 
 *  - tracks on-chain and off-chain donations made to the foundation
 *  - assigns unrestricted tokens to addresses provided by donors
 *  - assigns restricted tokens to DFINITY Stiftung and early contributors 
 *
 * On-chain donations are received in ether are converted to Swiss francs (CHF).
 * Off-chain donations are received and recorded directly in Swiss francs.
 * Tokens are assigned at a rate of 10 tokens per CHF. 
 *
 * There are two types of tokens initially. Unrestricted tokens are assigned to
 * donors and restricted tokens are assigned to DFINITY Stiftung and early 
 * contributors. Restricted tokens are converted to unrestricted tokens in the 
 * finalization phase, after which only unrestricted tokens exist.
 *
 * After the finalization phase, tokens assigned to DFINITY Stiftung and early 
 * contributors will make up a pre-defined share of all tokens. This is achieved
 * through burning excess restricted tokens before their restriction is removed.
 */

pragma solidity ^0.4.6;

// import "TokenTracker.sol";

/**
 * title:  A contract that tracks numbers of tokens assigned to addresses. 
 * author: Timo Hanke 
 *
 * Optionally, assignments can be chosen to be of "restricted type". 
 * Being "restricted" means that the token assignment may later be partially
 * reverted (or the tokens "burned") by the contract. 
 *
 * After all token assignments are completed the contract
 *   - burns some restricted tokens
 *   - releases the restriction on the remaining tokens
 * The percentage of tokens that burned out of each assignment of restricted
 * tokens is calculated to achieve the following condition:
 *   - the remaining formerly restricted tokens combined have a pre-configured
 *     share (percentage) among all remaining tokens.
 *
 * Once the conversion process has started the contract enters a state in which
 * no more assignments can be made.
 */

contract TokenTracker {
  // Share of formerly restricted tokens among all tokens in percent 
  uint public restrictedShare; 

  // Mapping from address to number of tokens assigned to the address
  mapping(address => uint) public tokens;

  // Mapping from address to number of tokens assigned to the address that
  // underly a restriction
  mapping(address => uint) public restrictions;
  
  // Total number of (un)restricted tokens currently in existence
  uint public totalRestrictedTokens; 
  uint public totalUnrestrictedTokens; 
  
  // Total number of individual assignment calls have been for (un)restricted
  // tokens
  uint public totalRestrictedAssignments; 
  uint public totalUnrestrictedAssignments; 

  // State flag. Assignments can only be made if false. 
  // Starting the conversion (burn) process irreversibly sets this to true. 
  bool public assignmentsClosed = false;
  
  // The multiplier (defined by nominator and denominator) that defines the
  // fraction of all restricted tokens to be burned. 
  // This is computed after assignments have ended and before the conversion
  // process starts.
  uint public burnMultDen;
  uint public burnMultNom;

  function TokenTracker(uint _restrictedShare) {
    // Throw if restricted share >= 100
    if (_restrictedShare >= 100) { throw; }
    
    restrictedShare = _restrictedShare;
  }
  
  /** 
   * PUBLIC functions
   *
   *  - isUnrestricted (getter)
   *  - multFracCeiling (library function)
   *  - isRegistered(addr) (getter)
   */
  
  /**
   * Return true iff the assignments are closed and there are no restricted
   * tokens left 
   */
  function isUnrestricted() constant returns (bool) {
    return (assignmentsClosed && totalRestrictedTokens == 0);
  }

  /**
   * Return the ceiling of (x*a)/b
   *
   * Edge cases:
   *   a = 0: return 0
   *   b = 0, a != 0: error (solidity throws on division by 0)
   */
  function multFracCeiling(uint x, uint a, uint b) returns (uint) {
    // Catch the case a = 0
    if (a == 0) { return 0; }
    
    // Rounding up is the same as adding 1-epsilon and rounding down.
    // 1-epsilon is modeled as (b-1)/b below.
    return (x * a + (b - 1)) / b; 
  }
    
  /**
   * Return true iff the address has tokens assigned (resp. restricted tokens)
   */
  function isRegistered(address addr, bool restricted) constant returns (bool) {
    if (restricted) {
      return (restrictions[addr] > 0);
    } else {
      return (tokens[addr] > 0);
    }
  }

  /**
   * INTERNAL functions
   *
   *  - assign
   *  - closeAssignments 
   *  - unrestrict 
   */
   
  /**
   * Assign (un)restricted tokens to given address
   */
  function assign(address addr, uint tokenAmount, bool restricted) internal {
    // Throw if assignments have been closed
    if (assignmentsClosed) { throw; }

    // Assign tokens
    tokens[addr] += tokenAmount;

    // Record restrictions and update total counters
    if (restricted) {
      totalRestrictedTokens += tokenAmount;
      totalRestrictedAssignments += 1;
      restrictions[addr] += tokenAmount;
    } else {
      totalUnrestrictedTokens += tokenAmount;
      totalUnrestrictedAssignments += 1;
    }
  }

  /**
   * Close future assignments.
   *
   * This is irreversible and closes all future assignments.
   * The function can only be called once.
   *
   * A call triggers the calculation of what fraction of restricted tokens
   * should be burned by subsequent calls to the unrestrict() function.
   * The result of this calculation is a multiplication factor whose nominator
   * and denominator are stored in the contract variables burnMultNom,
   * burnMultDen.
   */
  function closeAssignmentsIfOpen() internal {
    // Return if assignments are not open
    if (assignmentsClosed) { return; } 
    
    // Set the state to "closed"
    assignmentsClosed = true;

    /*
     *  Calculate the total number of tokens that should remain after
     *  conversion.  This is based on the total number of unrestricted tokens
     *  assigned so far and the pre-configured share that the remaining
     *  formerly restricted tokens should have.
     */
    uint totalTokensTarget = (totalUnrestrictedTokens * 100) / 
      (100 - restrictedShare);
    
    // The total number of tokens in existence now.
    uint totalTokensExisting = totalRestrictedTokens + totalUnrestrictedTokens;
      
    /*
     * The total number of tokens that need to be burned to bring the existing
     * number down to the target number. If the existing number is lower than
     * the target then we won't burn anything.
     */
    uint totalBurn = 0; 
    if (totalTokensExisting > totalTokensTarget) {
      totalBurn = totalTokensExisting - totalTokensTarget; 
    }

    // The fraction of restricted tokens to be burned (by nominator and
    // denominator).
    burnMultNom = totalBurn;
    burnMultDen = totalRestrictedTokens;
    
    /*
     * For verifying the correctness of the above calculation it may help to
     * note the following.
     * Given 0 <= restrictedShare < 100, we have:
     *  - totalTokensTarget >= totalUnrestrictedTokens
     *  - totalTokensExisting <= totalRestrictedTokens + totalTokensTarget
     *  - totalBurn <= totalRestrictedTokens
     *  - burnMultNom <= burnMultDen
     * Also note that burnMultDen = 0 means totalRestrictedTokens = 0, in which
     * burnMultNom = 0 as well.
     */
  }

  /**
   * Unrestrict (convert) all restricted tokens assigned to the given address
   *
   * This function can only be called after assignments have been closed via
   * closeAssignments().
   * The return value is the number of restricted tokens that were burned in
   * the conversion.
   */
  function unrestrict(address addr) internal returns (uint) {
    // Throw is assignments are not yet closed
    if (!assignmentsClosed) { throw; }

    // The balance of restricted tokens for the given address 
    uint restrictionsForAddr = restrictions[addr];
    
    // Throw if there are none
    if (restrictionsForAddr == 0) { throw; }

    // Apply the burn multiplier to the balance of restricted tokens
    // The result is the ceiling of the value: 
    // (restrictionForAddr * burnMultNom) / burnMultDen
    uint burn = multFracCeiling(restrictionsForAddr, burnMultNom, burnMultDen);

    // Remove the tokens to be burned from the address's balance
    tokens[addr] -= burn;
    
    // Delete record of restrictions 
    delete restrictions[addr];
    
    // Update the counters for total (un)restricted tokens
    totalRestrictedTokens   -= restrictionsForAddr;
    totalUnrestrictedTokens += restrictionsForAddr - burn;
      
    return burn;
  }
}

// import "Phased.sol";

/*
 * title: Contract that advances through multiple configurable phases over time
 * author: Timo Hanke 
 * 
 * Phases are defined by their transition times. The moment one phase ends the
 * next one starts. Each time belongs to exactly one phase.
 *
 * The contract allows a limited set of changes to be applied to the phase
 * transitions while the contract is active.  As a matter of principle, changes
 * are prohibited from effecting the past. They may only ever affect future
 * phase transitions.
 *
 * The permitted changes are:
 *   - add a new phase after the last one
 *   - end the current phase right now and transition to the next phase
 *     immediately 
 *   - delay the start of a future phase (thereby pushing out all subsequent
 *     phases by an equal amount of time)
 *   - define a maximum delay for a specified phase 
 */
 

contract Phased {
  /**
   * Array of transition times defining the phases
   *   
   * phaseEndTime[i] is the time when phase i has just ended.
   * Phase i is defined as the following time interval: 
   *   [ phaseEndTime[i-1], * phaseEndTime[i] )
   */
  uint[] public phaseEndTime;

  /**
   * Number of phase transitions N = phaseEndTime.length 
   *
   * There are N+1 phases, numbered 0,..,N.
   * The first phase has no start and the last phase has no end.
   */
  uint public N; 

  /**
   *  Maximum delay for phase transitions
   *
   *  maxDelay[i] is the maximum amount of time by which the transition
   *  phaseEndTime[i] can be delayed.
  */
  mapping(uint => uint) public maxDelay; 

  /*
   * The contract has no constructor.
   * The contract initialized itself with no phase transitions (N = 0) and one
   * phase (N+1=1).
   *
   * There are two PUBLIC functions (getters):
   *  - getPhaseAtTime
   *  - isPhase
   *  - getPhaseStartTime
   *
   * Note that both functions are guaranteed to return the same value when
   * called twice with the same argument (but at different times).
   */

  /**
   * Return the number of the phase to which the given time belongs.
   *
   * Return value i means phaseEndTime[i-1] <= time < phaseEndTime[i].
   * The given time must not be in the future (because future phase numbers may
   * still be subject to change).
   */
  function getPhaseAtTime(uint time) constant returns (uint n) {
    // Throw if time is in the future
    if (time > now) { throw; }
    
    // Loop until we have found the "active" phase
    while (n < N && phaseEndTime[n] <= time) {
      n++;
    }
  }

  /**
   * Return true if the given time belongs to the given phase.
   *
   * Returns the logical equivalent of the expression 
   *   (phaseEndTime[i-1] <= time < phaseEndTime[i]).
   *
   * The given time must not be in the future (because future phase numbers may
   * still be subject to change).
   */
  function isPhase(uint time, uint n) constant returns (bool) {
    // Throw if time is in the future
    if (time > now) { throw; }
    
    // Throw if index is out-of-range
    if (n >= N) { throw; }
    
    // Condition 1
    if (n > 0 && phaseEndTime[n-1] > time) { return false; } 
    
    // Condition 2
    if (n < N && time >= phaseEndTime[n]) { return false; } 
   
    return true; 
  }
  
  /**
   * Return the start time of the given phase.
   *
   * This function is provided for convenience.
   * The given phase number must not be 0, as the first phase has no start time.
   * If calling for a future phase number the caller must be aware that future
   * phase times can be subject to change.
   */
  function getPhaseStartTime(uint n) constant returns (uint) {
    // Throw if phase is the first phase
    if (n == 0) { throw; }
   
    return phaseEndTime[n-1];
  }
    
  /*
   *  There are 4 INTERNAL functions:
   *    1. addPhase
   *    2. setMaxDelay
   *    3. delayPhaseEndBy
   *    4. endCurrentPhaseIn
   *
   *  This contract does not implement access control to these function, so
   *  they are made internal.
   */
   
  /**
   * 1. Add a phase after the last phase.
   *
   * The argument is the new endTime of the phase currently known as the last
   * phase, or, in other words the start time of the newly introduced phase.  
   * All calls to addPhase() MUST be with strictly increasing time arguments.
   * It is not allowed to add a phase transition that lies in the past relative
   * to the current block time.
   */
  function addPhase(uint time) internal {
    // Throw if new transition time is not strictly increasing
    if (N > 0 && time <= phaseEndTime[N-1]) { throw; } 

    // Throw if new transition time is not in the future
    if (time <= now) { throw; }
   
    // Append new transition time to array 
    phaseEndTime.push(time);
    N++;
  }
  
  /**
   * 2. Define a limit on the amount of time by which the given transition (i)
   *    can be delayed.
   *
   * By default, transitions can not be delayed (limit = 0).
   */
  function setMaxDelay(uint i, uint timeDelta) internal {
    // Throw if index is out-of-range
    if (i >= N) { throw; }

    maxDelay[i] = timeDelta;
  }

  /**
   * 3. Delay the end of the given phase (n) by the given time delta. 
   *
   * The given phase must not have ended.
   *
   * This function can be called multiple times for the same phase. 
   * The defined maximum delay will be enforced across multiple calls.
   */
  function delayPhaseEndBy(uint n, uint timeDelta) internal {
    // Throw if index is out of range
    if (n >= N) { throw; }

    // Throw if phase has already ended
    if (now >= phaseEndTime[n]) { throw; }

    // Throw if the requested delay is higher than the defined maximum for the
    // transition
    if (timeDelta > maxDelay[n]) { throw; }

    // Subtract from the current max delay, so maxDelay is honored across
    // multiple calls
    maxDelay[n] -= timeDelta;

    // Push out all subsequent transitions by the same amount
    for (uint i = n; i < N; i++) {
      phaseEndTime[i] += timeDelta;
    }
  }

  /**
   * 4. End the current phase early.
   *
   * The current phase must not be the last phase, as the last phase has no end.
   * The current phase will end at time now plus the given time delta.
   *
   * The minimal allowed time delta is 1. This is avoid a race condition for 
   * other transactions that are processed in the same block. 
   * Setting phaseEndTime[n] to now would push all later transactions from the 
   * same block into the next phase.
   * If the specified timeDelta is 0 the function gracefully bumps it up to 1.
   */
  function endCurrentPhaseIn(uint timeDelta) internal {
    // Get the current phase number
    uint n = getPhaseAtTime(now);

    // Throw if we are in the last phase
    if (n >= N) { throw; }
   
    // Set timeDelta to the minimal allowed value
    if (timeDelta == 0) { 
      timeDelta = 1; 
    }
    
    // The new phase end should be earlier than the currently defined phase
    // end, otherwise we don't change it.
    if (now + timeDelta < phaseEndTime[n]) { 
      phaseEndTime[n] = now + timeDelta;
    }
  }
}

// import "StepFunction.sol";

/*
 * title:  A configurable step function 
 * author: Timo Hanke 
 *
 * The contract implements a step function going down from an initialValue to 0
 * in a number of steps (nSteps).
 * The steps are distributed equally over a given time (phaseLength).
 * Having n steps means that the time phaseLength is divided into n+1
 * sub-intervalls of equal length during each of which the function value is
 * constant. 
 */

contract StepFunction {
  uint public phaseLength;
  uint public nSteps;
  uint public step;

  function StepFunction(uint _phaseLength, uint _initialValue, uint _nSteps) {
    // Throw if phaseLength does not leave enough room for number of steps
    if (_nSteps > _phaseLength) { throw; } 
  
    // The reduction in value per step 
    step = _initialValue / _nSteps;
    
    // Throw if _initialValue was not divisible by _nSteps
    if ( step * _nSteps != _initialValue) { throw; } 

    phaseLength = _phaseLength;
    nSteps = _nSteps; 
  }
 
  /*
   * Note the following edge cases.
   *   initialValue = 0: is valid and will create the constant zero function
   *   nSteps = 0: is valid and will create the constant zero function (only 1
   *   sub-interval)
   *   phaseLength < nSteps: is valid, but unlikely to be intended (so the
   *   constructor throws)
   */
  
  /**
   * Evaluate the step function at a given time  
   *
   * elapsedTime MUST be in the intervall [0,phaseLength)
   * The return value is between initialValue and 0, never negative.
   */
  function getStepFunction(uint elapsedTime) constant returns (uint) {
    // Throw is elapsedTime is out-of-range
    if (elapsedTime >= phaseLength) { throw; }
    
    // The function value will bel calculated from the end value backwards.
    // Hence we need the time left, which will lie in the intervall
    // [0,phaseLength)
    uint timeLeft  = phaseLength - elapsedTime - 1; 

    // Calculate the number of steps away from reaching end value
    // When verifying the forumla below it may help to note:
    //   at elapsedTime = 0 stepsLeft evaluates to nSteps,
    //   at elapsedTime = -1 stepsLeft would evaluate to nSteps + 1.
    uint stepsLeft = ((nSteps + 1) * timeLeft) / phaseLength; 

    // Apply the step function
    return stepsLeft * step;
  }
}

// import "Targets.sol";

/*
 * title: Contract implementing counters with configurable targets
 * author: Timo Hanke 
 *
 * There is an arbitrary number of counters. Each counter is identified by its
 * counter id, a uint. Counters can never decrease.
 * 
 * The contract has no constructor. The target values are set and re-set via
 * setTarget().
 */

contract Targets {

  // Mapping from counter id to counter value 
  mapping(uint => uint) public counter;
  
  // Mapping from counter id to target value 
  mapping(uint => uint) public target;

  // A public getter that returns whether the target was reached
  function targetReached(uint id) constant returns (bool) {
    return (counter[id] >= target[id]);
  }
  
  /*
   * Modifying counter or target are internal functions.
   */
  
  // (Re-)set the target
  function setTarget(uint id, uint _target) internal {
    target[id] = _target;
  }
 
  // Add to the counter 
  // The function returns whether this current addition makes the counter reach
  // or cross its target value 
  function addTowardsTarget(uint id, uint amount) 
    internal 
    returns (bool firstReached) 
  {
    firstReached = (counter[id] < target[id]) && 
                   (counter[id] + amount >= target[id]);
    counter[id] += amount;
  }
}

// import "Parameters.sol";

/**
 * title:  Configuration parameters for the FDC
 * author: Timo Hanke 
 */

contract Parameters {

  /*
   * Time Constants
   *
   * Phases are, in this order: 
   *  earlyContribution (defined by end time)
   *  pause
   *  donation round0 (defined by start and end time)
   *  pause
   *  donation round1 (defined by start and end time)
   *  pause
   *  finalization (defined by start time, ends manually)
   *  done
   */

  // The start of round 0 is set to 2017-01-17 19:00 of timezone Europe/Zurich
  uint public constant round0StartTime      = 1484676000; 
  
  // The start of round 1 is set to 2017-05-17 19:00 of timezone Europe/Zurich
  // TZ="Europe/Zurich" date -d "2017-05-17 19:00" "+%s"
  uint public constant round1StartTime      = 1495040400; 
  
  // Transition times that are defined by duration
  uint public constant round0EndTime        = round0StartTime + 6 weeks;
  uint public constant round1EndTime        = round1StartTime + 6 weeks;
  uint public constant finalizeStartTime    = round1EndTime   + 1 weeks;
  
  // The finalization phase has a dummy end time because it is ended manually
  uint public constant finalizeEndTime      = finalizeStartTime + 1000 years;
  
  // The maximum time by which donation round 1 can be delayed from the start 
  // time defined above
  uint public constant maxRoundDelay     = 270 days;

  // The time for which donation rounds remain open after they reach their 
  // respective targets   
  uint public constant gracePeriodAfterRound0Target  = 1 days;
  uint public constant gracePeriodAfterRound1Target  = 0 days;

  /*
   * Token issuance
   * 
   * The following configuration parameters completely govern all aspects of the 
   * token issuance.
   */
  
  // Tokens assigned for the equivalent of 1 CHF in donations
  uint public constant tokensPerCHF = 10; 
  
  // Minimal donation amount for a single on-chain donation
  uint public constant minDonation = 1 ether; 
 
  // Bonus in percent added to donations throughout donation round 0 
  uint public constant round0Bonus = 200; 
  
  // Bonus in percent added to donations at beginning of donation round 1  
  uint public constant round1InitialBonus = 25;
  
  // Number of down-steps for the bonus during donation round 1
  uint public constant round1BonusSteps = 5;
 
  // The CHF targets for each of the donation rounds, measured in cents of CHF 
  uint public constant millionInCents = 10**6 * 100;
  uint public constant round0Target = 1 * millionInCents; 
  uint public constant round1Target = 20 * millionInCents;

  // Share of tokens eventually assigned to DFINITY Stiftung and early 
  // contributors in % of all tokens eventually in existence
  uint public constant earlyContribShare = 22; 
}

// FDC.sol

contract FDC is TokenTracker, Phased, StepFunction, Targets, Parameters {
  // An identifying string, set by the constructor
  string public name;
  
  /*
   * Phases
   *
   * The FDC over its lifetime runs through a number of phases. These phases are
   * tracked by the base contract Phased.
   *
   * The FDC maps the chronologically defined phase numbers to semantically 
   * defined states.
   */

  // The FDC states
  enum state {
    pause,         // Pause without any activity 
    earlyContrib,  // Registration of DFINITY Stiftung/early contributions
    round0,        // Donation round 0  
    round1,        // Donation round 1 
    offChainReg,   // Grace period for registration of off-chain donations
    finalization,  // Adjustment of DFINITY Stiftung/early contribution tokens
                   // down to their share
    done           // Read-only phase
  }

  // Mapping from phase number (from the base contract Phased) to FDC state 
  mapping(uint => state) stateOfPhase;

  /*
   * Tokens
   *
   * The FDC uses base contract TokenTracker to:
   *  - track token assignments for 
   *      - donors (unrestricted tokens)
   *      - DFINITY Stiftung/early contributors (restricted tokens)
   *  - convert DFINITY Stiftung/early contributor tokens down to their share
   *
   * The FDC uses the base contract Targets to:
   *  - track the targets measured in CHF for each donation round
   *
   * The FDC itself:
   *  - tracks the memos of off-chain donations (and prevents duplicates)
   *  - tracks donor and early contributor addresses in two lists
   */
   
  // Mapping to store memos that have been used 
  mapping(bytes32 => bool) memoUsed;

  // List of registered addresses (each address will appear in one)
  address[] public donorList;  
  address[] public earlyContribList;  
  
  /*
   * Exchange rate and ether handling
   *
   * The FDC keeps track of:
   *  - the exchange rate between ether and Swiss francs
   *  - the total and per address ether donations
   */
   
  // Exchange rate between ether and Swiss francs
  uint public weiPerCHF;       
  
  // Total number of Wei donated on-chain so far 
  uint public totalWeiDonated; 
  
  // Mapping from address to total number of Wei donated for the address
  mapping(address => uint) public weiDonated; 

  /*
   * Access control 
   * 
   * The following three addresses have access to restricted functions of the 
   * FDC and to the donated funds.
   */
   
  // Wallet address to which on-chain donations are being forwarded
  address public foundationWallet; 
  
  // Address that is allowed to register DFINITY Stiftung/early contributions
  // and off-chain donations and to delay donation round 1
  address public registrarAuth; 
  
  // Address that is allowed to update the exchange rate
  address public exchangeRateAuth; 

  // Address that is allowed to update the other authenticated addresses
  address public masterAuth; 

  /*
   * Global variables
   */
 
  // The phase numbers of the donation phases (set by the constructor, 
  // thereafter constant)
  uint phaseOfRound0;
  uint phaseOfRound1;
  
  /*
   * Events
   *
   *  - DonationReceipt:     logs an on-chain or off-chain donation
   *  - EarlyContribReceipt: logs the registration of early contribution 
   *  - BurnReceipt:         logs the burning of token during finalization
   */
  event DonationReceipt (address indexed addr,          // DFN address of donor
                         string indexed currency,       // donation currency
                         uint indexed bonusMultiplierApplied, // depends stage
                         uint timestamp,                // time occurred
                         uint tokenAmount,              // DFN to b recommended
                         bytes32 memo);                 // unique note e.g TxID
  event EarlyContribReceipt (address indexed addr,      // DFN address of donor 
                             uint tokenAmount,          // *restricted* tokens
                             bytes32 memo);             // arbitrary note
  event BurnReceipt (address indexed addr,              // DFN address adjusted
                     uint tokenAmountBurned);           // DFN deleted by adj.

  /**
   * Constructor
   *
   * The constructor defines 
   *  - the privileged addresses for access control
   *  - the phases in base contract Phased
   *  - the mapping between phase numbers and states
   *  - the targets in base contract Targets 
   *  - the share for early contributors in base contract TokenTracker
   *  - the step function for the bonus calculation in donation round 1 
   *
   * All configuration parameters are taken from base contract Parameters.
   */
  function FDC(address _masterAuth, string _name)
    TokenTracker(earlyContribShare)
    StepFunction(round1EndTime-round1StartTime, round1InitialBonus, 
                 round1BonusSteps) 
  {
    /*
     * Set identifying string
     */
    name = _name;

    /*
     * Set privileged addresses for access control
     */
    foundationWallet  = _masterAuth;
    masterAuth     = _masterAuth;
    exchangeRateAuth  = _masterAuth;
    registrarAuth  = _masterAuth;

    /*
     * Initialize base contract Phased
     * 
     *           |------------------------- Phase number (0-7)
     *           |    |-------------------- State name
     *           |    |               |---- Transition number (0-6)
     *           V    V               V
     */
    stateOfPhase[0] = state.earlyContrib; 
    addPhase(round0StartTime);     // 0
    stateOfPhase[1] = state.round0;
    addPhase(round0EndTime);       // 1 
    stateOfPhase[2] = state.offChainReg;
    addPhase(round1StartTime);     // 2
    stateOfPhase[3] = state.round1;
    addPhase(round1EndTime);       // 3 
    stateOfPhase[4] = state.offChainReg;
    addPhase(finalizeStartTime);   // 4 
    stateOfPhase[5] = state.finalization;
    addPhase(finalizeEndTime);     // 5 
    stateOfPhase[6] = state.done;

    // Let the other functions know what phase numbers the donation rounds were
    // assigned to
    phaseOfRound0 = 1;
    phaseOfRound1 = 3;
    
    // Maximum delay for start of donation rounds 
    setMaxDelay(phaseOfRound0 - 1, maxRoundDelay);
    setMaxDelay(phaseOfRound1 - 1, maxRoundDelay);

    /*
     * Initialize base contract Targets
     */
    setTarget(phaseOfRound0, round0Target);
    setTarget(phaseOfRound1, round1Target);
  }
  
  /*
   * PUBLIC functions
   * 
   * Un-authenticated:
   *  - getState
   *  - getMultiplierAtTime
   *  - donateAsWithChecksum
   *  - finalize
   *  - empty
   *  - getStatus
   *
   * Authenticated:
   *  - registerEarlyContrib
   *  - registerOffChainDonation
   *  - setExchangeRate
   *  - delayRound1
   *  - setFoundationWallet
   *  - setRegistrarAuth
   *  - setExchangeRateAuth
   *  - setAdminAuth
   */

  /**
   * Get current state at the current block time 
   */
  function getState() constant returns (state) {
    return stateOfPhase[getPhaseAtTime(now)];
  }
  
  /**
   * Return the bonus multiplier at a given time
   *
   * The given time must  
   *  - lie in one of the donation rounds, 
   *  - not lie in the future.
   * Otherwise there is no valid multiplier.
   */
  function getMultiplierAtTime(uint time) constant returns (uint) {
    // Get phase number (will throw if time lies in the future)
    uint n = getPhaseAtTime(time);

    // If time lies in donation round 0 we return the constant multiplier 
    if (stateOfPhase[n] == state.round0) {
      return 100 + round0Bonus;
    }

    // If time lies in donation round 1 we return the step function
    if (stateOfPhase[n] == state.round1) {
      return 100 + getStepFunction(time - getPhaseStartTime(n));
    }

    // Throw outside of donation rounds
    throw;
  }

  /**
   * Send donation in the name a the given address with checksum
   *
   * The second argument is a checksum which must equal the first 4 bytes of the
   * SHA-256 digest of the byte representation of the address.
   */
  function donateAsWithChecksum(address addr, bytes4 checksum) 
    payable 
    returns (bool) 
  {
    // Calculate SHA-256 digest of the address 
    bytes32 hash = sha256(addr);
    
    // Throw is the checksum does not match the first 4 bytes
    if (bytes4(hash) != checksum) { throw ; }

    // Call un-checksummed donate function 
    return donateAs(addr);
  }

  /**
   * Finalize the balance for the given address
   *
   * This function triggers the conversion (and burn) of the restricted tokens
   * that are assigned to the given address.
   *
   * This function is only available during the finalization phase. It manages
   * the calls to closeAssignments() and unrestrict() of TokenTracker.
   */
  function finalize(address addr) {
    // Throw if we are not in the finalization phase 
    if (getState() != state.finalization) { throw; }

    // Close down further assignments in TokenTracker
    closeAssignmentsIfOpen(); 

    // Burn tokens
    uint tokensBurned = unrestrict(addr); 
    
    // Issue burn receipt
    BurnReceipt(addr, tokensBurned);

    // If no restricted tokens left
    if (isUnrestricted()) { 
      // then end the finalization phase immediately
      endCurrentPhaseIn(0); 
    }
  }

  /**
   * Send any remaining balance to the foundation wallet
   */
  function empty() returns (bool) {
    return foundationWallet.call.value(this.balance)();
  }

  /**
   * Get status information from the FDC
   *
   * This function returns a mix of
   *  - global status of the FDC
   *  - global status of the FDC specific for one of the two donation rounds
   *  - status related to a specific token address (DFINITY address)
   *  - status (balance) of an external Ethereum account 
   *
   * Arguments are:
   *  - donationRound: donation round to query (0 or 1)
   *  - dfnAddr: token address to query
   *  - fwdAddr: external Ethereum address to query
   */
  function getStatus(uint donationRound, address dfnAddr, address fwdAddr)
    public constant
    returns (
      state currentState,     // current state (an enum)
      uint fxRate,            // exchange rate of CHF -> ETH (Wei/CHF)
      uint currentMultiplier, // current bonus multiplier (0 if invalid)
      uint donationCount,     // total individual donations made (a count)
      uint totalTokenAmount,  // total DFN planned allocated to donors
      uint startTime,         // expected start time of specified donation round
      uint endTime,           // expected end time of specified donation round
      bool isTargetReached,   // whether round target has been reached
      uint chfCentsDonated,   // total value donated in specified round as CHF
      uint tokenAmount,       // total DFN planned allocted to donor (user)
      uint fwdBalance,        // total ETH (in Wei) waiting in fowarding address
      uint donated)           // total ETH (in Wei) donated by DFN address 
  {
    // The global status
    currentState = getState();
    if (currentState == state.round0 || currentState == state.round1) {
      currentMultiplier = getMultiplierAtTime(now);
    } 
    fxRate = weiPerCHF;
    donationCount = totalUnrestrictedAssignments;
    totalTokenAmount = totalUnrestrictedTokens;
   
    // The round specific status
    if (donationRound == 0) {
      startTime = getPhaseStartTime(phaseOfRound0);
      endTime = getPhaseStartTime(phaseOfRound0 + 1);
      isTargetReached = targetReached(phaseOfRound0);
      chfCentsDonated = counter[phaseOfRound0];
    } else {
      startTime = getPhaseStartTime(phaseOfRound1);
      endTime = getPhaseStartTime(phaseOfRound1 + 1);
      isTargetReached = targetReached(phaseOfRound1);
      chfCentsDonated = counter[phaseOfRound1];
    }
    
    // The status specific to the DFN address
    tokenAmount = tokens[dfnAddr];
    donated = weiDonated[dfnAddr];
    
    // The status specific to the Ethereum address
    fwdBalance = fwdAddr.balance;
  }
  
  /**
   * Set the exchange rate between ether and Swiss francs in Wei per CHF
   *
   * Must be called from exchangeRateAuth.
   */
  function setWeiPerCHF(uint weis) {
    // Require permission
    if (msg.sender != exchangeRateAuth) { throw; }

    // Set the global state variable for exchange rate 
    weiPerCHF = weis;
  }

  /**
   * Register early contribution in the name of the given address
   *
   * Must be called from registrarAuth.
   *
   * Arguments are:
   *  - addr: address to the tokens are assigned
   *  - tokenAmount: number of restricted tokens to assign
   *  - memo: optional dynamic bytes of data to appear in the receipt
   */
  function registerEarlyContrib(address addr, uint tokenAmount, bytes32 memo) {
    // Require permission
    if (msg.sender != registrarAuth) { throw; }

    // Reject registrations outside the early contribution phase
    if (getState() != state.earlyContrib) { throw; }

    // Add address to list if new
    if (!isRegistered(addr, true)) {
      earlyContribList.push(addr);
    }
    
    // Assign restricted tokens in TokenTracker
    assign(addr, tokenAmount, true);
    
    // Issue early contribution receipt
    EarlyContribReceipt(addr, tokenAmount, memo);
  }

  /**
   * Register off-chain donation in the name of the given address
   *
   * Must be called from registrarAuth.
   *
   * Arguments are:
   *  - addr: address to the tokens are assigned
   *  - timestamp: time when the donation came in (determines round and bonus)
   *  - chfCents: value of the donation in cents of Swiss francs
   *  - currency: the original currency of the donation (three letter string)
   *  - memo: optional bytes of data to appear in the receipt
   *
   * The timestamp must not be in the future. This is because the timestamp 
   * defines the donation round and the multiplier and future phase times are
   * still subject to change.
   *
   * If called during a donation round then the timestamp must lie in the same 
   * phase and if called during the extended period for off-chain donations then
   * the timestamp must lie in the immediately preceding donation round. 
   */
  function registerOffChainDonation(address addr, uint timestamp, uint chfCents, 
                                    string currency, bytes32 memo)
  {
    // Require permission
    if (msg.sender != registrarAuth) { throw; }

    // The current phase number and state corresponding state
    uint currentPhase = getPhaseAtTime(now);
    state currentState = stateOfPhase[currentPhase];
    
    // Reject registrations outside the two donation rounds (incl. their
    // extended registration periods for off-chain donations)
    if (currentState != state.round0 && currentState != state.round1 &&
        currentState != state.offChainReg) {
      throw;
    }
   
    // Throw if timestamp is in the future
    if (timestamp > now) { throw; }
   
    // Phase number and corresponding state of the timestamp  
    uint timestampPhase = getPhaseAtTime(timestamp);
    state timestampState = stateOfPhase[timestampPhase];
   
    // Throw if called during a donation round and the timestamp does not match
    // that phase.
    if ((currentState == state.round0 || currentState == state.round1) &&
        (timestampState != currentState)) { 
      throw;
    }
    
    // Throw if called during the extended period for off-chain donations and
    // the timestamp does not lie in the immediately preceding donation phase.
    if (currentState == state.offChainReg && timestampPhase != currentPhase-1) {
      throw;
    }

    // Throw if the memo is duplicated
    if (memoUsed[memo]) {
      throw;
    }

    // Set the memo item to true
    memoUsed[memo] = true;

    // Do the book-keeping
    bookDonation(addr, timestamp, chfCents, currency, memo);
  }

  /**
   * Delay a donation round
   *
   * Must be called from the address registrarAuth.
   *
   * This function delays the start of donation round 1 by the given time delta
   * unless the time delta is bigger than the configured maximum delay.
   */
  function delayDonPhase(uint donPhase, uint timedelta) {
    // Require permission
    if (msg.sender != registrarAuth) { throw; }

    // Pass the call on to base contract Phased
    // Delaying the start of a donation round is the same as delaying the end 
    // of the preceding phase
    if (donPhase == 0) {
      delayPhaseEndBy(phaseOfRound0 - 1, timedelta);
    } else if (donPhase == 1) {
      delayPhaseEndBy(phaseOfRound1 - 1, timedelta);
    }
  }

  /**
   * Set the forwarding address for donated ether
   * 
   * Must be called from the address masterAuth before donation round 0 starts.
   */
  function setFoundationWallet(address newAddr) {
    // Require permission
    if (msg.sender != masterAuth) { throw; }
    
    // Require phase before round 0
    if (getPhaseAtTime(now) >= phaseOfRound0) { throw; }
 
    foundationWallet = newAddr;
  }

  /**
   * Set new authenticated address for setting exchange rate
   * 
   * Must be called from the address masterAuth.
   */
  function setExchangeRateAuth(address newAuth) {
    // Require permission
    if (msg.sender != masterAuth) { throw; }
 
    exchangeRateAuth = newAuth;
  }

  /**
   * Set new authenticated address for registrations
   * 
   * Must be called from the address masterAuth.
   */
  function setRegistrarAuth(address newAuth) {
    // Require permission
    if (msg.sender != masterAuth) { throw; }
 
    registrarAuth = newAuth;
  }

  /**
   * Set new authenticated address for admin
   * 
   * Must be called from the address masterAuth.
   */
  function setMasterAuth(address newAuth) {
    // Require permission
    if (msg.sender != masterAuth) { throw; }
 
    masterAuth = newAuth;
  }

  /*
   * PRIVATE functions
   *
   *  - donateAs
   *  - bookDonation
   */
  
  /**
   * Process on-chain donation in the name of the given address 
   *
   * This function is private because it shall only be called through its 
   * wrapper donateAsWithChecksum.
   */
  function donateAs(address addr) private returns (bool) {
    // The current state
    state st = getState();
    
    // Throw if current state is not a donation round
    if (st != state.round0 && st != state.round1) { throw; }

    // Throw if donation amount is below minimum
    if (msg.value < minDonation) { throw; }

    // Throw if the exchange rate is not yet defined
    if (weiPerCHF == 0) { throw; } 

    // Update counters for ether donations
    totalWeiDonated += msg.value;
    weiDonated[addr] += msg.value;

    // Convert ether to Swiss francs
    uint chfCents = (msg.value * 100) / weiPerCHF;
    
    // Do the book-keeping
    bookDonation(addr, now, chfCents, "ETH", "");

    // Forward balance to the foundation wallet
    return foundationWallet.call.value(this.balance)();
  }

  /**
   * Put an accepted donation in the books.
   *
   * This function
   *  - cannot throw as all checks have been done before, 
   *  - is agnostic to the source of the donation (on-chain or off-chain)
   *  - is agnostic to the currency 
   *    (the currency argument is simply passed through to the DonationReceipt)
   *
   */
  function bookDonation(address addr, uint timestamp, uint chfCents, 
                        string currency, bytes32 memo) private
  {
    // The current phase
    uint phase = getPhaseAtTime(timestamp);
    
    // Add amount to the counter of the current phase
    bool targetReached = addTowardsTarget(phase, chfCents);
    
    // If the target was crossed then start the grace period
    if (targetReached && phase == getPhaseAtTime(now)) {
      if (phase == phaseOfRound0) {
        endCurrentPhaseIn(gracePeriodAfterRound0Target);
      } else if (phase == phaseOfRound1) {
        endCurrentPhaseIn(gracePeriodAfterRound1Target);
      }
    }

    // Bonus multiplier that was valid at the given time 
    uint bonusMultiplier = getMultiplierAtTime(timestamp);
    
    // Apply bonus to amount in Swiss francs
    chfCents = (chfCents * bonusMultiplier) / 100;

    // Convert Swiss francs to amount of tokens
    uint tokenAmount = (chfCents * tokensPerCHF) / 100;

    // Add address to list if new
    if (!isRegistered(addr, false)) {
      donorList.push(addr);
    }
    
    // Assign unrestricted tokens in TokenTracker
    assign(addr,tokenAmount,false);

    // Issue donation receipt
    DonationReceipt(addr, currency, bonusMultiplier, timestamp, tokenAmount, 
                    memo);
  }
}