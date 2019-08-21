pragma solidity ^0.4.21;

// File: contracts/Bankroll.sol

interface Bankroll {

    //Customer functions

    /// @dev Stores ETH funds for customer
    function credit(address _customerAddress, uint256 amount) external returns (uint256);

    /// @dev Debits address by an amount
    function debit(address _customerAddress, uint256 amount) external returns (uint256);

    /// @dev Withraws balance for address; returns amount sent
    function withdraw(address _customerAddress) external returns (uint256);

    /// @dev Retrieve the token balance of any single address.
    function balanceOf(address _customerAddress) external view returns (uint256);

    /// @dev Stats of any single address
    function statsOf(address _customerAddress) external view returns (uint256[8]);


    // System functions

    // @dev Deposit funds
    function deposit() external payable;

    // @dev Deposit on behalf of an address; it is not a credit
    function depositBy(address _customerAddress) external payable;

    // @dev Distribute house profit
    function houseProfit(uint256 amount)  external;


    /// @dev Get all the ETH stored in contract minus credits to customers
    function netEthereumBalance() external view returns (uint256);


    /// @dev Get all the ETH stored in contract
    function totalEthereumBalance() external view returns (uint256);

}

// File: contracts/SessionQueue.sol

/// A FIFO queue for storing addresses
contract SessionQueue {

    mapping(uint256 => address) private queue;
    uint256 private first = 1;
    uint256 private last = 0;

    /// @dev Push into queue
    function enqueue(address data) internal {
        last += 1;
        queue[last] = data;
    }

    /// @dev Returns true if the queue has elements in it
    function available() internal view returns (bool) {
        return last >= first;
    }

    /// @dev Returns the size of the queue
    function depth() internal view returns (uint256) {
        return last - first + 1;
    }

    /// @dev Pops from the head of the queue
    function dequeue() internal returns (address data) {
        require(last >= first);
        // non-empty queue

        data = queue[first];

        delete queue[first];
        first += 1;
    }

    /// @dev Returns the head of the queue without a pop
    function peek() internal view returns (address data) {
        require(last >= first);
        // non-empty queue

        data = queue[first];
    }
}

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
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: openzeppelin-solidity/contracts/ownership/Whitelist.sol

/**
 * @title Whitelist
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.
 * @dev This simplifies the implementation of "user permissions".
 */
contract Whitelist is Ownable {
  mapping(address => bool) public whitelist;

  event WhitelistedAddressAdded(address addr);
  event WhitelistedAddressRemoved(address addr);

  /**
   * @dev Throws if called by any account that's not whitelisted.
   */
  modifier onlyWhitelisted() {
    require(whitelist[msg.sender]);
    _;
  }

  /**
   * @dev add an address to the whitelist
   * @param addr address
   * @return true if the address was added to the whitelist, false if the address was already in the whitelist
   */
  function addAddressToWhitelist(address addr) onlyOwner public returns(bool success) {
    if (!whitelist[addr]) {
      whitelist[addr] = true;
      emit WhitelistedAddressAdded(addr);
      success = true;
    }
  }

  /**
   * @dev add addresses to the whitelist
   * @param addrs addresses
   * @return true if at least one address was added to the whitelist,
   * false if all addresses were already in the whitelist
   */
  function addAddressesToWhitelist(address[] addrs) onlyOwner public returns(bool success) {
    for (uint256 i = 0; i < addrs.length; i++) {
      if (addAddressToWhitelist(addrs[i])) {
        success = true;
      }
    }
  }

  /**
   * @dev remove an address from the whitelist
   * @param addr address
   * @return true if the address was removed from the whitelist,
   * false if the address wasn't in the whitelist in the first place
   */
  function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {
    if (whitelist[addr]) {
      whitelist[addr] = false;
      emit WhitelistedAddressRemoved(addr);
      success = true;
    }
  }

  /**
   * @dev remove addresses from the whitelist
   * @param addrs addresses
   * @return true if at least one address was removed from the whitelist,
   * false if all addresses weren't in the whitelist in the first place
   */
  function removeAddressesFromWhitelist(address[] addrs) onlyOwner public returns(bool success) {
    for (uint256 i = 0; i < addrs.length; i++) {
      if (removeAddressFromWhitelist(addrs[i])) {
        success = true;
      }
    }
  }

}

// File: contracts/Dice.sol

/*
 * Visit: https://p4rty.io
 * Discord: https://discord.gg/7y3DHYF
 * P4RTY DICE
 * Provably Fair Variable Chance DICE game
 * Roll Under  2 to 99
 * Play with ETH and play using previous winnings; withdraw anytime
 * Upgradable and connects to P4RTY Bankroll
 */





contract Dice is Whitelist, SessionQueue {

    using SafeMath for uint;

    /*
    * checks player profit, bet size and player number is within range
   */
    modifier betIsValid(uint _betSize, uint _playerNumber) {
        bool result = ((((_betSize * (100 - _playerNumber.sub(1))) / (_playerNumber.sub(1)) + _betSize)) * houseEdge / houseEdgeDivisor) - _betSize > maxProfit || _betSize < minBet || _playerNumber < minNumber || _playerNumber > maxNumber;
        require(!result);
        _;
    }

    /*
     * checks game is currently active
    */
    modifier gameIsActive {
        require(!gamePaused);
        _;
    }


    /**
     *
     * Events
    */

    event  onSessionOpen(
        uint indexed id,
        uint block,
        uint futureBlock,
        address player,
        uint wager,
        uint rollUnder,
        uint profit
    );

    event onSessionClose(
        uint indexed id,
        uint block,
        uint futureBlock,
        uint futureHash,
        uint seed,
        address player,
        uint wager,
        uint rollUnder,
        uint dieRoll,
        uint payout,
        bool timeout
    );

    event onCredit(address player, uint amount);
    event onWithdraw(address player, uint amount);

    /**
     *
     * Structs
    */

    struct Session {
        uint id;
        uint block;
        uint futureBlock;
        uint futureHash;
        address player;
        uint wager;
        uint dieRoll;
        uint seed;
        uint rollUnder;
        uint profit;
        uint payout;
        bool complete;
        bool timeout;

    }

    struct Stats {
        uint rolls;
        uint wagered;
        uint profit;
        uint wins;
        uint loss;
    }

    /*
     * game vars
    */
    uint constant public maxProfitDivisor = 1000000;
    uint constant public houseEdgeDivisor = 1000;
    uint constant public maxNumber = 99;
    uint constant public minNumber = 2;
    uint constant public futureDelta = 2;
    uint internal  sessionProcessingCap = 3;
    bool public gamePaused;
    bool public payoutsPaused;
    uint public houseEdge;
    uint public maxProfit;
    uint public maxProfitAsPercentOfHouse;
    uint maxPendingPayouts;
    uint public minBet;
    uint public totalSessions;
    uint public totalBets;
    uint public totalWon;
    uint public totalWagered;
    uint private seed;

    /*
    * player vars
   */

    mapping(address => Session) sessions;
    mapping(address => Stats) stats;

    mapping(bytes32 => bytes32) playerBetId;
    mapping(bytes32 => uint) playerBetValue;
    mapping(bytes32 => uint) playerTempBetValue;
    mapping(bytes32 => uint) playerDieResult;
    mapping(bytes32 => uint) playerNumber;
    mapping(address => uint) playerPendingWithdrawals;
    mapping(bytes32 => uint) playerProfit;
    mapping(bytes32 => uint) playerTempReward;

    //The House
    Bankroll public bankroll;



    constructor() public {
        /* init 990 = 99% (1% houseEdge)*/
        ownerSetHouseEdge(990);
        /* init 10,000 = 1%  */
        ownerSetMaxProfitAsPercentOfHouse(10000);
        /* init min bet (0.01 ether) */
        ownerSetMinBet(10000000000000000);
    }

    /**
     *
     *Update BankRoll address
     */
    function updateBankrollAddress(address bankrollAddress) onlyOwner public {
        bankroll = Bankroll(bankrollAddress);
        setMaxProfit();
    }

    function contractBalance() internal view returns (uint256){
        return bankroll.netEthereumBalance();
    }

    /**
    *
    *Play with ETH
    */

    function play(uint rollUnder) payable public {

        //Fund the bankroll; a player wins back profit on a wager (not a credit, just deposit)
        bankroll.depositBy.value(msg.value)(msg.sender);

        //Roll
        rollDice(rollUnder, msg.value);
    }


    /**
    *
    *Play with balance
    */

    function playWithVault(uint rollUnder, uint wager) public {
        //A player can play with a previous win which is store in their vault first
        require(bankroll.balanceOf(msg.sender) >= wager);

        //Reduce credit
        bankroll.debit(msg.sender, wager);

        //Roll
        rollDice(rollUnder, wager);
    }


    /*
    * private
    * player submit bet
    * only if game is active & bet is valid
   */
    function rollDice(uint rollUnder, uint wager) internal gameIsActive betIsValid(wager, rollUnder)
    {

        //Complete previous sessions
        processSessions();

        Session memory session = sessions[msg.sender];

        //Strictly cannot wager twice in the same block
        require(block.number != session.block, "Only one roll can be played at a time");

        // If there exists a roll, it must be completed
        if (session.block != 0 && !session.complete) {
            require(completeSession(msg.sender), "Only one roll can be played at a time");
        }

        //Increment Sessions
        totalSessions += 1;

        //Invalidate passive session components so it is processed
        session.complete = false;
        session.timeout = false;
        session.payout = 0;

        session.block = block.number;
        session.futureBlock = block.number + futureDelta;
        session.player = msg.sender;
        session.rollUnder = rollUnder;
        session.wager = wager;

        session.profit = profit(rollUnder, wager);

        session.id = generateSessionId(session);

        //Save new session
        sessions[msg.sender] = session;

        /* safely increase maxPendingPayouts liability - calc all pending payouts under assumption they win */
        maxPendingPayouts = maxPendingPayouts.add(session.profit);

        /* check contract can payout on win

        */
        require(maxPendingPayouts < contractBalance(), "Reached maximum wagers supported");

        /* total number of bets */
        totalBets += 1;

        /* total wagered */
        totalWagered += session.wager;


        /* Queue session, can be processed by another player */
        queueSession(session);

        /* Stats */
        stats[session.player].rolls += 1;
        stats[session.player].wagered += session.wager;

        /* provides accurate numbers for listeners */
        emit  onSessionOpen(session.id, session.block, session.futureBlock, session.player, session.wager, session.rollUnder, session.profit);
    }

    /// @dev Queue up dice session so that it can be processed by others
    function queueSession(Session session) internal {
        enqueue(session.player);

    }

    /// @dev Process sessions in bulk
    function processSessions() internal {
        uint256 count = 0;
        address session;

        while (available() && count < sessionProcessingCap) {

            //If the session isn't able to be completed because of the block none added later will be
            session = peek();

            if (sessions[session].complete || completeSession(session)) {
                dequeue();
                count++;
            } else {
                break;
            }
        }
    }


    /*
        @dev Proceses the session if possible by the given player
    */
    function closeSession() public {

        Session memory session = sessions[msg.sender];

        // If there exists a roll, it must be completed
        if (session.block != 0 && !session.complete) {
            require(completeSession(msg.sender), "Only one roll can be played at a time");
        }
    }




    /**
    *
    * Random num
    */
    function random(Session session) private returns (uint256, uint256, uint256){
        uint blockHash = uint256(blockhash(session.futureBlock));
        seed = uint256(keccak256(abi.encodePacked(seed, blockHash, session.id)));
        return (seed, blockHash, seed % maxNumber);
    }

    function profit(uint rollUnder, uint wager) public view returns (uint) {

        return ((((wager * (100 - (rollUnder.sub(1)))) / (rollUnder.sub(1)) + wager)) * houseEdge / houseEdgeDivisor) - wager;
    }

    /**
    *
    *Generates a unique sessionId and adds entropy to the overall random calc
    */
    function generateSessionId(Session session) private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(seed, blockhash(block.number - 1), totalSessions, session.player, session.wager, session.rollUnder, session.profit)));
    }


    /*
     * Process roll
     */
    function completeSession(address _customer) private returns (bool)
    {

        Session memory session = sessions[_customer];


        //A future block is not available until one after
        if (!(block.number > session.futureBlock)) {
            return false;
        }


        //If player does not claim it is a forefeit
        //The roll is automatically 100 which is invalid
        if (block.number - session.futureBlock > 256) {
            session.timeout = true;
            session.dieRoll = 100;
        } else {
            (session.seed, session.futureHash, session.dieRoll) = random(session);
            session.timeout = false;
        }

        //Decrement maxPendingPayouts
        maxPendingPayouts = maxPendingPayouts.sub(session.profit);


        /*
        * pay winner
        * update contract balance to calculate new max bet
        * send reward
        * if send of reward fails save value to playerPendingWithdrawals
        */
        if (session.dieRoll < session.rollUnder) {

            /* update total wei won */
            totalWon = totalWon.add(session.profit);

            /* safely calculate payout via profit plus original wager */
            session.payout = session.profit.add(session.wager);

            /* Stats */
            stats[session.player].profit += session.profit;
            stats[session.player].wins += 1;


            /*
            * Award Player
            */

            bankroll.credit(session.player, session.payout);

        }

        /*
        * no win
        * update contract balance to calculate new max bet
        * session.dieRoll >= session.rollUnder || session.timeout (but basically anything not winning
        */
        else {

            /*
            * ON LOSS
            * No need to debit the player; wager is paid to contract, not as a credit
            * Instruct bankroll to distribute profit to the house in realtime
            */

            bankroll.houseProfit(session.wager);

            /* Stats */
            stats[session.player].loss += 1;

        }

        /* update maximum profit */
        setMaxProfit();

        //Close the session
        closeSession(session);

        return true;

    }

    /// @dev Closes a session and fires event for audit
    function closeSession(Session session) internal {

        session.complete = true;

        //Save the last session info
        sessions[session.player] = session;
        emit onSessionClose(session.id, session.block, session.futureBlock, session.futureHash, session.seed, session.player, session.wager, session.rollUnder, session.dieRoll, session.payout, session.timeout);

    }

    /// @dev Returns true if there is an active session

    function isMining() public view returns (bool) {
        Session memory session = sessions[msg.sender];

        //A future block is not available until one after
        return session.block != 0 && !session.complete && block.number <= session.futureBlock;
    }

    /*
    * public function
    * Withdraw funds for current player
    */
    function withdraw() public
    {

        //OK to fail if a roll is happening; save gas
        closeSession();
        bankroll.withdraw(msg.sender);
    }

    /*
    * Return the balance of a given player
    *
    */
    function balanceOf(address player) public view returns (uint) {
        return bankroll.balanceOf(player);
    }

    /// @dev Stats of any single address
    function statsOf(address player) public view returns (uint256[5]){
        Stats memory s = stats[player];
        uint256[5] memory statArray = [s.rolls, s.wagered, s.profit, s.wins, s.loss];
        return statArray;
    }

    /// @dev Returns the last roll of a complete session for an address
    function lastSession(address player) public view returns (address, uint[7], bytes32[3], bool[2]) {
        Session memory s = sessions[player];
        return (s.player, [s.block, s.futureBlock, s.wager, s.dieRoll, s.rollUnder, s.profit, s.payout], [bytes32(s.id), bytes32(s.futureHash), bytes32(s.seed)], [s.complete, s.timeout]);
    }

    /*
    * internal function
    * sets max profit
    */
    function setMaxProfit() internal {
        if (address(bankroll) != address(0)) {
            maxProfit = (contractBalance() * maxProfitAsPercentOfHouse) / maxProfitDivisor;
        }
    }


    /* only owner address can set houseEdge */
    function ownerSetHouseEdge(uint newHouseEdge) public
    onlyOwner
    {
        houseEdge = newHouseEdge;
    }

    /* only owner address can set maxProfitAsPercentOfHouse */
    function ownerSetMaxProfitAsPercentOfHouse(uint newMaxProfitAsPercent) public
    onlyOwner
    {
        /* restrict each bet to a maximum profit of 1% contractBalance */
        require(newMaxProfitAsPercent <= 10000, "Maximum bet exceeded");
        maxProfitAsPercentOfHouse = newMaxProfitAsPercent;
        setMaxProfit();
    }

    /* only owner address can set minBet */
    function ownerSetMinBet(uint newMinimumBet) public
    onlyOwner
    {
        minBet = newMinimumBet;
    }

    /// @dev Set the maximum amount of sessions to be processed
    function ownerSetProcessingCap(uint cap) public onlyOwner {
        sessionProcessingCap = cap;
    }

    /* only owner address can set emergency pause #1 */
    function ownerPauseGame(bool newStatus) public
    onlyOwner
    {
        gamePaused = newStatus;
    }

}