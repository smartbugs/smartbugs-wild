pragma solidity ^0.4.23;

// File: contracts/ReinvestProxy.sol

/*
 * Visit: https://p4rty.io
 * Discord: https://discord.gg/7y3DHYF
 * Copyright Mako Labs LLC 2018 All Rights Reseerved
*/
interface ReinvestProxy {

    /// @dev Converts all incoming ethereum to tokens for the caller,
    function reinvestFor(address customer) external payable;

}

// File: openzeppelin-solidity/contracts/math/Math.sol

/**
 * @title Math
 * @dev Assorted math operations
 */
library Math {
  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/P4RTYDaoVault.sol

/*
 * Visit: https://p4rty.io
 * Discord: https://discord.gg/7y3DHYF
 * Copyright Mako Labs LLC 2018 All Rights Reseerved
*/

contract P4RTYDaoVault is Whitelist {


    /*=================================
    =            MODIFIERS            =
    =================================*/

    /// @dev Only people with profits
    modifier onlyDivis {
        require(myDividends() > 0);
        _;
    }


    /*==============================
    =            EVENTS            =
    ==============================*/

    event onStake(
        address indexed customerAddress,
        uint256 stakedTokens,
        uint256 timestamp
    );

    event onDeposit(
        address indexed fundingSource,
        uint256 ethDeposited,
        uint    timestamp
    );

    event onWithdraw(
        address indexed customerAddress,
        uint256 ethereumWithdrawn,
        uint timestamp
    );

    event onReinvestmentProxy(
        address indexed customerAddress,
        address indexed destinationAddress,
        uint256 ethereumReinvested
    );




    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/


    uint256 constant internal magnitude = 2 ** 64;


    /*=================================
     =            DATASETS            =
     ================================*/

    // amount of shares for each address (scaled number)
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => int256) internal payoutsTo_;

    //Initial deposits backed by one virtual share that cannot be unstaked
    uint256 internal tokenSupply_ = 1;
    uint256 internal profitPerShare_;

    ERC20 public p4rty;


    /*=======================================
    =            PUBLIC FUNCTIONS           =
    =======================================*/

    constructor(address _p4rtyAddress) Ownable() public {

        p4rty = ERC20(_p4rtyAddress);

    }

    /**
     * @dev Fallback function to handle ethereum that was send straight to the contract
     */
    function() payable public {
        deposit();
    }

    /// @dev Internal function to actually purchase the tokens.
    function deposit() payable public  {

        uint256 _incomingEthereum = msg.value;
        address _fundingSource = msg.sender;

        // take the amount of dividends gained through this transaction, and allocates them evenly to each shareholder
        profitPerShare_ += (_incomingEthereum * magnitude / tokenSupply_);


        // fire event
        emit onDeposit(_fundingSource, _incomingEthereum, now);

    }

    function stake(uint _amountOfTokens) public {


        //Approval has to happen separately directly with p4rty
        //p4rty.approve(<DAO>, _amountOfTokens);

        address _customerAddress = msg.sender;

        //Customer needs to have P4RTY
        require(p4rty.balanceOf(_customerAddress) > 0);



        uint256 _balance = p4rty.balanceOf(_customerAddress);
        uint256 _stakeAmount = Math.min256(_balance,_amountOfTokens);

        require(_stakeAmount > 0);
        p4rty.transferFrom(_customerAddress, address(this), _stakeAmount);

        //Add to the tokenSupply_
        tokenSupply_ = SafeMath.add(tokenSupply_, _stakeAmount);

        // update circulating supply & the ledger address for the customer
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _stakeAmount);

        // Tells the contract that the buyer doesn't deserve dividends for the tokens before they owned them;
        // really i know you think you do but you don't
        int256 _updatedPayouts = (int256) (profitPerShare_ * _stakeAmount);
        payoutsTo_[_customerAddress] += _updatedPayouts;

        emit onStake(_customerAddress, _amountOfTokens, now);
    }

    /// @dev Withdraws all of the callers earnings.
    function withdraw() onlyDivis public {

        address _customerAddress = msg.sender;
        // setup data
        uint256 _dividends = dividendsOf(_customerAddress);

        // update dividend tracker
        payoutsTo_[_customerAddress] += (int256) (_dividends * magnitude);


        // lambo delivery service
        _customerAddress.transfer(_dividends);

        // fire event
        emit onWithdraw(_customerAddress, _dividends, now);
    }

    function reinvestByProxy(address _customerAddress) onlyWhitelisted public {
        // setup data
        uint256 _dividends = dividendsOf(_customerAddress);

        // update dividend tracker
        payoutsTo_[_customerAddress] += (int256) (_dividends * magnitude);


        // dispatch a buy order with the virtualized "withdrawn dividends"
        ReinvestProxy reinvestProxy =  ReinvestProxy(msg.sender);
        reinvestProxy.reinvestFor.value(_dividends)(_customerAddress);

        emit onReinvestmentProxy(_customerAddress,msg.sender,_dividends);

    }


    /*=====================================
    =      HELPERS AND CALCULATORS        =
    =====================================*/

    /**
     * @dev Method to view the current Ethereum stored in the contract
     *  Example: totalEthereumBalance()
     */
    function totalEthereumBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /// @dev Retrieve the total token supply.
    function totalSupply() public view returns (uint256) {
        return tokenSupply_;
    }

    /// @dev Retrieve the tokens owned by the caller.
    function myTokens() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }

    /// @dev The percentage of the
    function votingPower(address _customerAddress) public view returns (uint256) {
        return SafeMath.div(balanceOf(_customerAddress), totalSupply());
    }

    /**
     * @dev Retrieve the dividends owned by the caller.
     *  If `_includeReferralBonus` is to to 1/true, the referral bonus will be included in the calculations.
     *  The reason for this, is that in the frontend, we will want to get the total divs (global + ref)
     *  But in the internal calculations, we want them separate.
     */
    function myDividends() public view returns (uint256) {
        return dividendsOf(msg.sender);

    }

    /// @dev Retrieve the token balance of any single address.
    function balanceOf(address _customerAddress) public view returns (uint256) {
        return tokenBalanceLedger_[_customerAddress];
    }

    /// @dev Retrieve the dividend balance of any single address.
    function dividendsOf(address _customerAddress) public view returns (uint256) {
        return (uint256) ((int256) (profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
    }

}

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

// File: contracts/P4RTYRelay.sol

/*
 * Visit: https://p4rty.io
 * Discord: https://discord.gg/7y3DHYF
*/

interface P4RTYRelay {
    /**
    * @dev Will relay to internal implementation
    * @param beneficiary Token purchaser
    * @param tokenAmount Number of tokens to be minted
    */
    function relay(address beneficiary, uint256 tokenAmount) external;
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

// File: contracts/P6.sol

// solhint-disable-line






/*
 * Visit: https://p4rty.io
 * Discord: https://discord.gg/7y3DHYF
 * Stable + DIVIS: Whale and Minow Friendly
 * Fees balanced for maximum dividends for ALL
 * Active depositors rewarded with P4RTY tokens
 * 50% of ETH value in earned P4RTY token rewards
 * 2% of dividends fund a gaming bankroll; gaming profits are paid back into P6
 * P4RTYRelay is notified on all dividend producing transactions
 * Smart Launch phase which is anti-whale & anti-snipe
 *
 * P6
 * The worry free way to earn A TON OF ETH & P4RTY reward tokens
 *
 * -> What?
 * The first Ethereum Bonded Pure Dividend Token:
 * [✓] The only dividend printing press that is part of the P4RTY Entertainment Network
 * [✓] Earn ERC20 P4RTY tokens on all ETH deposit activities
 * [✓] 3% P6 Faucet for free P6 / P4RTY
 * [✓] Auto-Reinvests
 * [✓] 10% exchange fees on buys and sells
 * [✓] 100 tokens to activate faucet
 *
 * -> How?
 * To replay or use the faucet the contract must be fully launched
 * To sell or transfer you need to be vested (maximum of 3 days) after a reinvest
*/

contract P6 is Whitelist, SessionQueue {


    /*=================================
    =            MODIFIERS            =
    =================================*/

    /// @dev Only people with tokens
    modifier onlyTokenHolders {
        require(myTokens() > 0);
        _;
    }

    /// @dev Only people with profits
    modifier onlyDivis {
        require(myDividends(true) > 0);
        _;
    }

    /// @dev Only invested; If participating in prelaunch have to buy tokens
    modifier invested {
        require(stats[msg.sender].invested > 0, "Must buy tokens once to withdraw");

        _;

    }

    /// @dev After every reinvest features are protected by a cooloff to vest funds
    modifier cooledOff {
        require(msg.sender == owner && !contractIsLaunched || now - bot[msg.sender].coolOff > coolOffPeriod);
        _;
    }

    /// @dev The faucet has a rewardPeriod
    modifier teamPlayer {
        require(msg.sender == owner || now - lastReward[msg.sender] > rewardProcessingPeriod, "No spamming");
        _;
    }

    /// @dev Functions only available after launch
    modifier launched {
        require(contractIsLaunched || msg.sender == owner, "Contract not lauched");
        _;
    }


    /*==============================
    =            EVENTS            =
    ==============================*/

    event onLog(
        string heading,
        address caller,
        address subj,
        uint val
    );

    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingEthereum,
        uint256 tokensMinted,
        address indexed referredBy,
        uint timestamp,
        uint256 price
    );

    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 ethereumEarned,
        uint timestamp,
        uint256 price
    );

    event onReinvestment(
        address indexed customerAddress,
        uint256 ethereumReinvested,
        uint256 tokensMinted
    );

    event onCommunityReward(
        address indexed sourceAddress,
        address indexed destinationAddress,
        uint256 ethereumEarned
    );

    event onReinvestmentProxy(
        address indexed customerAddress,
        address indexed destinationAddress,
        uint256 ethereumReinvested
    );

    event onWithdraw(
        address indexed customerAddress,
        uint256 ethereumWithdrawn
    );

    event onDeposit(
        address indexed customerAddress,
        uint256 ethereumDeposited
    );

    // ERC20
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );


    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/

    /// @dev 10% dividends for token purchase
    uint256  internal entryFee_ = 10;

    /// @dev 1% dividends for token transfer
    uint256  internal transferFee_ = 1;

    /// @dev 10% dividends for token selling
    uint256  internal exitFee_ = 10;

    /// @dev 3% of entryFee_  is given to faucet
    /// traditional referral mechanism repurposed as a many to many faucet
    /// powers auto reinvest
    uint256  internal referralFee_ = 30;

    /// @dev 20% of entryFee/exit fee is given to Bankroll
    uint256  internal maintenanceFee_ = 20;
    address  internal maintenanceAddress;

    //Advanced Config
    uint256 constant internal bankrollThreshold = 0.5 ether;
    uint256 constant internal botThreshold = 0.01 ether;
    uint256 constant rewardProcessingPeriod = 6 hours;
    uint256 constant reapPeriod = 7 days;
    uint256 public  maxProcessingCap = 10;

    uint256 public coolOffPeriod = 3 days;
    uint256 public launchETHMaximum = 20 ether;
    bool public contractIsLaunched = false;
    uint public lastReaped;


    uint256 constant internal tokenPriceInitial_ = 0.0000001 ether;
    uint256 constant internal tokenPriceIncremental_ = 0.00000001 ether;

    uint256 constant internal magnitude = 2 ** 64;

    /// @dev proof of stake (defaults at 100 tokens)
    uint256 public stakingRequirement = 100e18;


    /*=================================
     =            DATASETS            =
     ================================*/

    // bookkeeping for autoreinvest
    struct Bot {
        bool active;
        bool queued;
        uint256 lastBlock;
        uint256 coolOff;
    }

    // Onchain Stats!!!
    struct Stats {
        uint invested;
        uint reinvested;
        uint withdrawn;
        uint rewarded;
        uint contributed;
        uint transferredTokens;
        uint receivedTokens;
        uint xInvested;
        uint xReinvested;
        uint xRewarded;
        uint xContributed;
        uint xWithdrawn;
        uint xTransferredTokens;
        uint xReceivedTokens;
    }


    // amount of shares for each address (scaled number)
    mapping(address => uint256) internal lastReward;
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal referralBalance_;
    mapping(address => int256) internal payoutsTo_;
    mapping(address => Bot) internal bot;
    mapping(address => Stats) internal stats;
    //on chain referral tracking
    mapping(address => address) public referrals;
    uint256 internal tokenSupply_;
    uint256 internal profitPerShare_;

    P4RTYRelay public relay;
    Bankroll public bankroll;
    bool internal bankrollEnabled = true;

    /*=======================================
    =            PUBLIC FUNCTIONS           =
    =======================================*/

    constructor(address relayAddress)  public {

        relay = P4RTYRelay(relayAddress);
        updateMaintenanceAddress(msg.sender);
    }

    //Maintenance Functions

    /// @dev Minted P4RTY tokens are sent to the maintenance address
    function updateMaintenanceAddress(address maintenance) onlyOwner public {
        maintenanceAddress = maintenance;
    }

    /// @dev Update the bankroll; 2% of dividends go to the bankroll
    function updateBankrollAddress(address bankrollAddress) onlyOwner public {
        bankroll = Bankroll(bankrollAddress);
    }

    /// @dev The cap determines the amount of addresses processed when a user runs the faucet
    function updateProcessingCap(uint cap) onlyOwner public {
        require(cap >= 5 && cap <= 15, "Capacity set outside of policy range");
        maxProcessingCap = cap;
    }

    /// @dev Updates the coolOff period where reinvest must vest
    function updateCoolOffPeriod(uint coolOff) onlyOwner public {
        require(coolOff >= 5 minutes && coolOff <= 3 days);
        coolOffPeriod = coolOff;
    }

    /// @dev Opens the contract for public use outside of the launch phase
    function launchContract() onlyOwner public {
        contractIsLaunched = true;
    }


    //Bot Functions

    /* Activates the bot and queues if necessary; else removes */
    function activateBot(bool auto) public {
        bot[msg.sender].active = auto;

        //Spam protection for customerAddress
        if (bot[msg.sender].active) {
            if (!bot[msg.sender].queued) {
                bot[msg.sender].queued = true;
                enqueue(msg.sender);
            }
        }
    }

    /* Returns if the sender has the reinvestment not enabled */
    function botEnabled() public view returns (bool){
        return bot[msg.sender].active;
    }


    function fundBankRoll(uint256 amount) internal {
        bankroll.deposit.value(amount)();
    }

    /// @dev Converts all incoming ethereum to tokens for the caller, and passes down the referral addy (if any)
    function buyFor(address _customerAddress) onlyWhitelisted public payable returns (uint256) {
        return purchaseTokens(_customerAddress, msg.value);
    }

    /// @dev Converts all incoming ethereum to tokens for the caller
    function buy() public payable returns (uint256) {
        if (contractIsLaunched){
            //ETH sent during prelaunch needs to be processed
            if(stats[msg.sender].invested == 0 && referralBalance_[msg.sender] > 0){
                reinvestFor(msg.sender);
            }
            return purchaseTokens(msg.sender, msg.value);
        }  else {
            //Just deposit funds
            return deposit();
        }
    }

    function deposit() internal returns (uint256) {
        require(msg.value > 0);

        //Just add to the referrals for sidelined ETH
        referralBalance_[msg.sender] = SafeMath.add(referralBalance_[msg.sender], msg.value);

        require(referralBalance_[msg.sender] <= launchETHMaximum, "Exceeded investment cap");

        emit onDeposit(msg.sender, msg.value);

        return 0;

    }

    /**
     * @dev Fallback function to handle ethereum that was send straight to the contract
     *  Unfortunately we cannot use a referral address this way.
     */
    function() payable public {
        purchaseTokens(msg.sender, msg.value);
    }

    /// @dev Converts all of caller's dividends to tokens.
    function reinvest() onlyDivis launched public {
        reinvestFor(msg.sender);
    }

    /// @dev Allows owner to reinvest on behalf of a supporter
    function investSupporter(address _customerAddress) public onlyOwner {
        require(!contractIsLaunched, "Contract already opened");
        reinvestFor(_customerAddress);
    }

    /// @dev Internal utility method for reinvesting
    function reinvestFor(address _customerAddress) internal {

        // fetch dividends
        uint256 _dividends = totalDividends(_customerAddress, false);
        // retrieve ref. bonus later in the code

        payoutsTo_[_customerAddress] += (int256) (_dividends * magnitude);

        // retrieve ref. bonus
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;

        // dispatch a buy order with the virtualized "withdrawn dividends"
        uint256 _tokens = purchaseTokens(_customerAddress, _dividends);

        // fire event
        emit onReinvestment(_customerAddress, _dividends, _tokens);

        //Stats
        stats[_customerAddress].reinvested = SafeMath.add(stats[_customerAddress].reinvested, _dividends);
        stats[_customerAddress].xReinvested += 1;

        //Refresh the coolOff
        bot[_customerAddress].coolOff = now;

    }

    /// @dev Withdraws all of the callers earnings.
    function withdraw() onlyDivis  invested public {
        withdrawFor(msg.sender);
    }

    /// @dev Utility function for withdrawing earnings
    function withdrawFor(address _customerAddress) internal {

        // setup data
        uint256 _dividends = totalDividends(_customerAddress, false);
        // get ref. bonus later in the code

        // update dividend tracker
        payoutsTo_[_customerAddress] += (int256) (_dividends * magnitude);

        // add ref. bonus
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;

        // lambo delivery service
        _customerAddress.transfer(_dividends);

        //stats
        stats[_customerAddress].withdrawn = SafeMath.add(stats[_customerAddress].withdrawn, _dividends);
        stats[_customerAddress].xWithdrawn += 1;

        // fire event
        emit onWithdraw(_customerAddress, _dividends);
    }


    /// @dev Liquifies tokens to ethereum.
    function sell(uint256 _amountOfTokens) onlyTokenHolders cooledOff public {
        address _customerAddress = msg.sender;

        //Selling deactivates auto reinvest
        bot[_customerAddress].active = false;


        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        uint256 _tokens = _amountOfTokens;
        uint256 _ethereum = tokensToEthereum_(_tokens);


        uint256 _undividedDividends = SafeMath.div(SafeMath.mul(_ethereum, exitFee_), 100);
        uint256 _maintenance = SafeMath.div(SafeMath.mul(_undividedDividends, maintenanceFee_), 100);
        //maintenance and referral come out of the exitfee
        uint256 _dividends = SafeMath.sub(_undividedDividends, _maintenance);
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _undividedDividends);

        // burn the sold tokens
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);

        // update dividends tracker
        int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens + (_taxedEthereum * magnitude));
        payoutsTo_[_customerAddress] -= _updatedPayouts;


        //Apply maintenance fee to the bankroll
        fundBankRoll(_maintenance);

        // dividing by zero is a bad idea
        if (tokenSupply_ > 0) {
            // update the amount of dividends per token
            profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
        }

        // fire event
        emit onTokenSell(_customerAddress, _tokens, _taxedEthereum, now, buyPrice());

        //GO!!! Bankroll Bot GO!!!
        brbReinvest(_customerAddress);
    }

    //@dev Bankroll Bot can only transfer 10% of funds during a reapPeriod
    //Its funds will always be locked because it always reinvests
    function reap(address _toAddress) public onlyOwner {
        require(now - lastReaped > reapPeriod, "Reap not available, too soon");
        lastReaped = now;
        transferTokens(owner, _toAddress, SafeMath.div(balanceOf(owner), 10));

    }

    /**
     * @dev Transfer tokens from the caller to a new holder.
     *  Remember, there's a 1% fee here as well.
     */
    function transfer(address _toAddress, uint256 _amountOfTokens) onlyTokenHolders cooledOff external returns (bool){
        address _customerAddress = msg.sender;
        return transferTokens(_customerAddress, _toAddress, _amountOfTokens);
    }

    /// @dev Utility function for transfering tokens
    function transferTokens(address _customerAddress, address _toAddress, uint256 _amountOfTokens)  internal returns (bool){

        // make sure we have the requested tokens
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);

        // withdraw all outstanding dividends first
        if (totalDividends(_customerAddress,true) > 0) {
            withdrawFor(_customerAddress);
        }

        // liquify a percentage of the tokens that are transfered
        // these are dispersed to shareholders
        uint256 _tokenFee = SafeMath.div(SafeMath.mul(_amountOfTokens, transferFee_), 100);
        uint256 _taxedTokens = SafeMath.sub(_amountOfTokens, _tokenFee);
        uint256 _dividends = tokensToEthereum_(_tokenFee);

        // burn the fee tokens
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokenFee);

        // exchange tokens
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _taxedTokens);

        // update dividend trackers
        payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);
        payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _taxedTokens);

        // disperse dividends among holders
        profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);

        // fire event
        emit Transfer(_customerAddress, _toAddress, _taxedTokens);

        //Stats
        stats[_customerAddress].xTransferredTokens += 1;
        stats[_customerAddress].transferredTokens += _amountOfTokens;
        stats[_toAddress].receivedTokens += _taxedTokens;
        stats[_toAddress].xReceivedTokens += 1;

        // ERC20
        return true;
    }


    /*=====================================
    =      HELPERS AND CALCULATORS        =
    =====================================*/

    /**
     * @dev Method to view the current Ethereum stored in the contract
     *  Example: totalEthereumBalance()
     */
    function totalEthereumBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /// @dev Retrieve the total token supply.
    function totalSupply() public view returns (uint256) {
        return tokenSupply_;
    }

    /// @dev Retrieve the tokens owned by the caller.
    function myTokens() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }

    /**
     * @dev Retrieve the dividends owned by the caller.
     *  If `_includeReferralBonus` is to to 1/true, the referral bonus will be included in the calculations.
     *  The reason for this, is that in the frontend, we will want to get the total divs (global + ref)
     *  But in the internal calculations, we want them separate.
     */
    /**
     * @dev Retrieve the dividends owned by the caller.
     *  If `_includeReferralBonus` is to to 1/true, the referral bonus will be included in the calculations.
     *  The reason for this, is that in the frontend, we will want to get the total divs (global + ref)
     *  But in the internal calculations, we want them separate.
     */
    function myDividends(bool _includeReferralBonus) public view returns (uint256) {
        return totalDividends(msg.sender, _includeReferralBonus);
    }

    function totalDividends(address _customerAddress, bool _includeReferralBonus) internal view returns (uint256) {
        return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress);
    }

    /// @dev Retrieve the token balance of any single address.
    function balanceOf(address _customerAddress) public view returns (uint256) {
        return tokenBalanceLedger_[_customerAddress];
    }

    /// @dev Stats of any single address
    function statsOf(address _customerAddress) public view returns (uint256[14]){
        Stats memory s = stats[_customerAddress];
        uint256[14] memory statArray = [s.invested, s.withdrawn, s.rewarded, s.contributed, s.transferredTokens, s.receivedTokens, s.xInvested, s.xRewarded, s.xContributed, s.xWithdrawn, s.xTransferredTokens, s.xReceivedTokens, s.reinvested, s.xReinvested];
        return statArray;
    }

    /// @dev Retrieve the dividend balance of any single address.
    function dividendsOf(address _customerAddress) public view returns (uint256) {
        return (uint256) ((int256) (profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
    }

    /// @dev Return the sell price of 1 individual token.
    function sellPrice() public view returns (uint256) {
        // our calculation relies on the token supply, so we need supply. Doh.
        if (tokenSupply_ == 0) {
            return tokenPriceInitial_ - tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _dividends = SafeMath.div(_ethereum, exitFee_);
            uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
            return _taxedEthereum;
        }

    }

    /// @dev Return the buy price of 1 individual token.
    function buyPrice() public view returns (uint256) {
        // our calculation relies on the token supply, so we need supply. Doh.
        if (tokenSupply_ == 0) {
            return tokenPriceInitial_ + tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _dividends = SafeMath.div(_ethereum, entryFee_);
            uint256 _taxedEthereum = SafeMath.add(_ethereum, _dividends);
            return _taxedEthereum;
        }

    }

    /// @dev Function for the frontend to dynamically retrieve the price scaling of buy orders.
    function calculateTokensReceived(uint256 _ethereumToSpend) public view returns (uint256) {
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereumToSpend, entryFee_), 100);
        uint256 _taxedEthereum = SafeMath.sub(_ethereumToSpend, _dividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);

        return _amountOfTokens;
    }

    /// @dev Function for the frontend to dynamically retrieve the price scaling of sell orders.
    function calculateEthereumReceived(uint256 _tokensToSell) public view returns (uint256) {
        require(_tokensToSell <= tokenSupply_);
        uint256 _ethereum = tokensToEthereum_(_tokensToSell);
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, exitFee_), 100);
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
        return _taxedEthereum;
    }


    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/

    /// @dev Internal function to actually purchase the tokens.
    function purchaseTokens(address _customerAddress, uint256 _incomingEthereum) internal returns (uint256) {
        // data setup
        address _referredBy = msg.sender;
        uint256 _undividedDividends = SafeMath.div(SafeMath.mul(_incomingEthereum, entryFee_), 100);
        uint256 _maintenance = SafeMath.div(SafeMath.mul(_undividedDividends, maintenanceFee_), 100);
        uint256 _referralBonus = SafeMath.div(SafeMath.mul(_undividedDividends, referralFee_), 100);
        //maintenance and referral come out of the buyin
        uint256 _dividends = SafeMath.sub(_undividedDividends, SafeMath.add(_referralBonus, _maintenance));
        uint256 _taxedEthereum = SafeMath.sub(_incomingEthereum, _undividedDividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        uint256 _fee = _dividends * magnitude;
        uint256 _tokenAllocation = SafeMath.div(_incomingEthereum, 2);


        // prevents overflow in the case that the pyramid somehow magically starts being used by everyone in the world
        // (or hackers)
        // and yes we know that the safemath function automatically rules out the "greater then" equasion.
        require(_amountOfTokens > 0 && SafeMath.add(_amountOfTokens, tokenSupply_) > tokenSupply_);

        //Apply maintenance fee to bankroll
        fundBankRoll(_maintenance);

        // is the user referred by a masternode?
        if (

        // no cheating!
            _referredBy != _customerAddress &&

            // does the referrer have at least X whole tokens?
            // i.e is the referrer a godly chad masternode
            tokenBalanceLedger_[_referredBy] >= stakingRequirement
        ) {
            // wealth redistribution
            referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus);

            //Stats
            stats[_referredBy].rewarded = SafeMath.add(stats[_referredBy].rewarded, _referralBonus);
            stats[_referredBy].xRewarded += 1;
            stats[_customerAddress].contributed = SafeMath.add(stats[_customerAddress].contributed, _referralBonus);
            stats[_customerAddress].xContributed += 1;

            //It pays to play
            emit onCommunityReward(_customerAddress, _referredBy, _referralBonus);
        } else {
            // no ref purchase
            // add the referral bonus back to the global dividends cake
            _dividends = SafeMath.add(_dividends, _referralBonus);
            _fee = _dividends * magnitude;
        }

        // we can't give people infinite ethereum
        if (tokenSupply_ > 0) {
            // add tokens to the pool
            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);

            // take the amount of dividends gained through this transaction, and allocates them evenly to each shareholder
            profitPerShare_ += (_dividends * magnitude / tokenSupply_);

            // calculate the amount of tokens the customer receives over his purchase
            _fee = _fee - (_fee - (_amountOfTokens * (_dividends * magnitude / tokenSupply_)));
        } else {
            // add tokens to the pool
            tokenSupply_ = _amountOfTokens;
        }

        // update circulating supply & the ledger address for the customer
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);

        // Tells the contract that the buyer doesn't deserve dividends for the tokens before they owned them;
        // really i know you think you do but you don't
        int256 _updatedPayouts = (int256) (profitPerShare_ * _amountOfTokens - _fee);
        payoutsTo_[_customerAddress] += _updatedPayouts;

        //Notifying the relay is simple and should represent the total economic activity which is the _incomingEthereum
        //Every player is a customer and mints their own tokens when the buy or reinvest, relay P4RTY 50/50
        relay.relay(maintenanceAddress, _tokenAllocation);
        relay.relay(_customerAddress, _tokenAllocation);

        // fire event
        emit onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens, _referredBy, now, buyPrice());

        //Stats
        stats[_customerAddress].invested = SafeMath.add(stats[_customerAddress].invested, _incomingEthereum);
        stats[_customerAddress].xInvested += 1;

        //GO!!! Bankroll Bot GO!!!
        brbReinvest(_customerAddress);

        return _amountOfTokens;
    }

    /**
     * Calculate Token price based on an amount of incoming ethereum
     * It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;
     * Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.
     */
    function ethereumToTokens_(uint256 _ethereum) internal view returns (uint256)
    {
        uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;
        uint256 _tokensReceived =
        (
        (
        // underflow attempts BTFO
        SafeMath.sub(
            (sqrt
        (
            (_tokenPriceInitial ** 2)
            +
            (2 * (tokenPriceIncremental_ * 1e18) * (_ethereum * 1e18))
            +
            (((tokenPriceIncremental_) ** 2) * (tokenSupply_ ** 2))
            +
            (2 * (tokenPriceIncremental_) * _tokenPriceInitial * tokenSupply_)
        )
            ), _tokenPriceInitial
        )
        ) / (tokenPriceIncremental_)
        ) - (tokenSupply_)
        ;

        return _tokensReceived;
    }

    /**
     * Calculate token sell value.
     * It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;
     * Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.
     */
    function tokensToEthereum_(uint256 _tokens) internal view returns (uint256)
    {

        uint256 tokens_ = (_tokens + 1e18);
        uint256 _tokenSupply = (tokenSupply_ + 1e18);
        uint256 _etherReceived =
        (
        // underflow attempts BTFO
        SafeMath.sub(
            (
            (
            (
            tokenPriceInitial_ + (tokenPriceIncremental_ * (_tokenSupply / 1e18))
            ) - tokenPriceIncremental_
            ) * (tokens_ - 1e18)
            ), (tokenPriceIncremental_ * ((tokens_ ** 2 - tokens_) / 1e18)) / 2
        )
        / 1e18);
        return _etherReceived;
    }


    /// @dev Returns true if the tokens are fully vested after a reinvest
    function isVested() public view returns (bool) {
        return now - bot[msg.sender].coolOff > coolOffPeriod;
    }

    /*
        Is end user eligible to process rewards?
    */
    function rewardAvailable() public view returns (bool){
        return available() && now - lastReward[msg.sender] > rewardProcessingPeriod &&
        tokenBalanceLedger_[msg.sender] >= stakingRequirement;
    }

    /// @dev Returns timer info used for the vesting and the faucet
    function timerInfo() public view returns (uint, uint[2], uint[2]){
        return (now, [bot[msg.sender].coolOff, coolOffPeriod], [lastReward[msg.sender], rewardProcessingPeriod]);
    }


    //This is where all your gas goes, sorry
    //Not sorry, you probably only paid 1 gwei
    function sqrt(uint x) internal pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }

    //
    // BankRollBot Functions
    //

    //Reinvest on all buys and sells
    function brbReinvest(address _customerAddress) internal {
        if (_customerAddress != owner && bankrollEnabled) {
            if (totalDividends(owner, true) > bankrollThreshold) {
                reinvestFor(owner);
            }
        }


    }

    /*
        Can only be run once per day from the caller avoid bots
        Minimum of 100 P6
        Minimum of 5 P4RTY + amount minted based on dividends processed in 24 hour period
    */
    function processRewards() public teamPlayer launched {
        require(tokenBalanceLedger_[msg.sender] >= stakingRequirement, "Must meet staking requirement");


        uint256 count = 0;
        address _customer;

        while (available() && count < maxProcessingCap) {

            //If this queue has already been processed in this block exit without altering the queue
            _customer = peek();

            if (bot[_customer].lastBlock == block.number){
                break;
            }

            //Pop
            dequeue();


            //Update tracking
            bot[_customer].lastBlock = block.number;
            bot[_customer].queued = false;

            //User could have deactivated while still being queued
            if (bot[_customer].active) {

                //Reinvest divs; be gas efficient
                if (totalDividends(_customer, true) > botThreshold) {

                    //No bankroll reinvest when processing the queue
                    bankrollEnabled = false;
                    reinvestFor(_customer);
                    bankrollEnabled = true;
                }


                enqueue(_customer);
                bot[_customer].queued = true;
            }

            count++;
        }

        lastReward[msg.sender] = now;
        reinvestFor(msg.sender);
    }



}

// File: contracts/P4RTYBankrollVault.sol

/*
 * Visit: https://p4rty.io
 * Discord: https://discord.gg/7y3DHYF
*/

contract P4RTYBankrollVault is Whitelist {

    using SafeMath for uint;

    /*==============================
    =            EVENTS            =
    ==============================*/

    event onDeposit(
        address indexed fundingSource,
        uint256 ethDeposited,
        uint    timestamp
    );

    event onCredit(
        address indexed customerAddress,
        uint256 ethCredited,
        uint    timestamp
    );

    event onDebit(
        address indexed customerAddress,
        uint256 ethDedited,
        uint    timestamp
    );



    event onWithdraw(
        address indexed customerAddress,
        uint256 ethereumWithdrawn,
        uint timestamp
    );

    event onAirdrop(
        address contractAddress,
        uint256 ethereumSent,
        uint timestamp
    );



    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/

    uint256 public daoFee = 10;
    uint256 public p6Fee = 15;
    uint256 constant public outboundThreshold = 0.5 ether;
    uint256 internal p6Outbound = 0;
    uint256 internal daoOutbound =0;


    /*=================================
     =            DATASETS            =
     ================================*/

    struct Stats {
        uint deposit;
        uint credit;
        uint debit;
        uint withdrawn;
        uint xDeposit;
        uint xCredit;
        uint xDebit;
        uint xWithdrawn;
    }

    // amount of shares for each address (scaled number)
    mapping(address => uint256) internal vault;
    mapping(address => Stats) internal stats;
    uint256 internal totalCustomerCredit;
    P6 public p6;
    P4RTYDaoVault public dao;


    /*=======================================
    =            PUBLIC FUNCTIONS           =
    =======================================*/

    constructor(address daoAddress) public {
        dao = P4RTYDaoVault(daoAddress);
    }

    function updateP6Fee(uint256 fee) public onlyOwner {
        require ( fee >= 1 && fee <= 25);
        p6Fee = fee;
    }

    function updateDaoFee(uint256 fee) public onlyOwner {
        require ( fee >= 1 && fee <= 25);
        daoFee = fee;
    }

    function updateP6Address(address p6Address) public onlyOwner {
        p6 = P6(p6Address);
    }

    //Customer functions


    /// @dev Stores ETH funds for customer
    function credit(address _customerAddress, uint256 amount) onlyWhitelisted external returns (uint256){
        vault[_customerAddress] = vault[_customerAddress].add(amount);

        totalCustomerCredit = totalCustomerCredit.add(amount);

        //Stats
        stats[_customerAddress].credit = stats[_customerAddress].credit.add(amount);
        stats[_customerAddress].xCredit += 1;

        emit onCredit(_customerAddress, amount, now);

        return vault[_customerAddress];

    }

    /// @dev Debits address by an amount or sets to zero
    function debit(address _customerAddress, uint256 amount) onlyWhitelisted external returns (uint256){

        //No money movement; usually a lost wager
        vault[_customerAddress] = Math.max256(0, vault[_customerAddress].sub(amount));

        totalCustomerCredit = totalCustomerCredit.sub(amount);

        //Stats
        stats[_customerAddress].debit = stats[_customerAddress].debit.add(amount);
        stats[_customerAddress].xDebit += 1;

        emit onWithdraw(_customerAddress, amount, now);

        return vault[_customerAddress];
    }

    /// @dev Withraws balance for address; returns amount sent
    function withdraw(address _customerAddress) onlyWhitelisted external returns (uint256){
        require(vault[_customerAddress] > 0);

        uint256 amount = vault[_customerAddress];

        vault[_customerAddress] = 0;
        totalCustomerCredit = totalCustomerCredit.sub(amount);

        _customerAddress.transfer(amount);

        //Stats
        stats[_customerAddress].withdrawn = stats[_customerAddress].withdrawn.add(amount);
        stats[_customerAddress].xWithdrawn += 1;

        emit onWithdraw(_customerAddress, amount, now);
    }

    function houseProfit(uint256 amount) onlyWhitelisted external {
        fundP6(amount);
        fundDao(amount);
    }

    /// @dev Retrieve the token balance of any single address.
    function balanceOf(address _customerAddress)  onlyWhitelisted external view returns (uint256) {
        return vault[_customerAddress];
    }

    /// @dev Stats of any single address
    function statsOf(address _customerAddress) public view returns (uint256[8]){
        Stats memory s = stats[_customerAddress];
        uint256[8] memory statArray = [s.deposit, s.credit, s.debit, s.withdrawn,
        s.xDeposit, s.xCredit, s.xDebit, s.xWithdrawn];
        return statArray;
    }


    // System functions


    /**
     * @dev Fallback function to handle ethereum that was send straight to the contract
     * Should just deposit so that we can accept funds from contracts as well using transfer
     */
    function() payable public {
        emit onDeposit(msg.sender, msg.value, now);
    }

    /// @dev Proper way to fund bankrollvault; don't use fallback
    function deposit() payable public  {
        // fire event
        emit onDeposit(msg.sender, msg.value, now);
    }

    /// @dev Proper way to fund bankrollvault by a specific customer
    function depositBy(address _customerAddress ) onlyWhitelisted payable external {
        // fire event; profit do not immediately shared with Snowfall

        //Stats
        stats[_customerAddress].deposit = stats[_customerAddress].deposit.add(msg.value);
        stats[_customerAddress].xDeposit += 1;

        emit onDeposit(_customerAddress, msg.value, now);
    }

    /**
    * @dev The bridge to the launch ecosystem. Community has to participate to dump divs
    * Should
    */
    function fundP6(uint256 amount) internal {
        uint256 fee = amount.mul(p6Fee).div(100);

        p6Outbound = p6Outbound.add(fee);

        //GO P6 GO!!!
        if (p6Outbound >= outboundThreshold){
            fee = p6Outbound;
            p6Outbound = 0;
            p6.buyFor.value(fee)(owner);
            emit onAirdrop(address(p6), fee, now);
        }

    }

    /**
    * @dev The bridge to the launch ecosystem. Community has to participate to dump divs
    * Should
    */
    function fundDao(uint256 amount) internal {
        uint256 fee = amount.mul(daoFee).div(100);

        daoOutbound = daoOutbound.add(fee);

        //GO P6 GO!!!
        if (daoOutbound >= outboundThreshold){
            fee = daoOutbound;
            daoOutbound = 0;
            dao.deposit.value(fee)();
            emit onAirdrop(address(dao), fee, now);
        }

    }

    /**
      * @dev Get all the ETH stored in contract
      *
      */
    function totalEthereumBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @dev Get all the ETH stored in contract minus credits to customers
     *
     */
    function netEthereumBalance() public view returns (uint256) {
        return address(this).balance.sub(totalCustomerCredit);
    }
}