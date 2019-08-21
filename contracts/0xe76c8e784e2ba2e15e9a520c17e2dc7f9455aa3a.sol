pragma solidity 0.4.18;
/**
 * @title Masterium Token [MTI]
 * @author primeRev
 * @notice masterium [mti] token contract (tokensale, (cummulated) interest payouts, masternodes
 */


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {uint256 c = a * b; assert(a == 0 || c / a == b); return c;}
    //unused:: function div(uint256 a, uint256 b) internal pure returns (uint256) {uint256 c = a / b; return c;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {assert(b <= a); return a - b;}
    function add(uint256 a, uint256 b) internal pure returns (uint256) {uint256 c = a + b; assert(c >= a); return c;}
}

/**
 * @title ReentryProtected
 * @dev Mutex based reentry protection
 */
contract ReentryProtected {
    /*
    file:   ReentryProtection.sol (https://github.com/o0ragman0o/ReentryProtected)
    ver:    0.3.0
    updated:6-April-2016
    author: Darryl Morris
    email:  o0ragman0o AT gmail.com

    Mutex based reentry protection protect.

    This software is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU lesser General Public License for more details.
    <http://www.gnu.org/licenses/>.
    */
    // The reentry protection state mutex.
    bool __reMutex;

    // This modifier can be used on functions with external calls to
    // prevent reentry attacks.
    // Constraints:
    //   Protected functions must have only one point of exit.
    //   Protected functions cannot use the `return` keyword
    //   Protected functions return values must be through return parameters.
    modifier preventReentry() {
        require(!__reMutex);
        __reMutex = true;
        _;
        delete __reMutex;
        return;
    }
    /* unused::
    // This modifier can be applied to public access state mutation functions
    // to protect against reentry if a `preventReentry` function has already
    // set the mutex. This prevents the contract from being reenter under a
    // different memory context which can break state variable integrity.
    modifier noReentry() {
        require(!__reMutex);
        _;
    }
    */
}

/**
 * @title Masterium Token [MTI]
 * @author primeRev
 * @notice masterium [mti] token contract (tokensale, (cummulated) interest payouts, masternodes
 * @dev code is heavily commented, feel free to check it
 */
contract MasteriumToken is ReentryProtected  {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8  public decimals;
    string public version;

    // used to scale token amounts to 18 decimals
    uint256 internal constant TOKEN_MULTIPLIER = 1e18;

    address internal contractOwner;

    // DEBUG
    bool    internal debug = false;

    // in debugging mode
    uint256 internal constant DEBUG_SALEFACTOR = 1; // 100 -> additional factor for ETH to Token calculation
    uint256 internal constant DEBUG_STARTDELAY = 1 minutes;
    uint256 internal constant DEBUG_INTERVAL   = 1 days;

    // in production mode
    uint256 internal constant PRODUCTION_SALEFACTOR = 1;           // additional tokensale exchange rate factor Tokens per ETH: production = 1
    uint256 internal constant PRODUCTION_START      = 1511611200;  // tokensale starts at unittimestamp: 1511611200 = 11/25/2017 @ 12:00pm (UTC) (approx. +/-900 sec.)
    uint256 internal constant PRODUCTION_INTERVAL   = 30 days;

    event DebugValue(string text, uint256 value);



    struct Account {
        uint256 balance;                        // balance including already payed out interest
        uint256 lastPayoutInterval;             // interval-index of last payout
    }

    mapping(address => Account)                      internal accounts;
    mapping(address => mapping(address => uint256))  public allowed;


    uint256 internal _supplyTotal;
    uint256 internal _supplyLastPayoutInterval; // interval of last processed interest payout


    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // +
    // + interest stuff
    // +
    // + interest is payed out every 30 days (interval)
    // + interest-rate is a function of interval-index % periodicity
    // +
    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    struct InterestConfig {
        uint256 interval;           // interest is paid every x seconds (default: 30 days)
        uint256 periodicity;        // interest-rate change by time and restart after "periodicity"
        uint256 stopAtInterval;     // no more interest after stop-index
        uint256 startAtTimestamp;   // time the interval-index starts increasing
    }

    InterestConfig internal interestConfig; // set in constructor:: = InterestConfig(30 days,12,48,0);

    uint256[12] internal interestRates;
    uint256[4]  internal stageFactors;



    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // +
    // + masternode stuff
    // +
    // + every token-transaction costs a fee, payed in tokens (0.01)
    // + Masternodes earn the fees
    // + Masternodes get double interest
    // +
    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    struct StructMasternode {
        uint8   activeMasternodes;              // count of registered MN
        uint256 totalBalanceWei;                // in the contract deposited ether (in wei)
        uint256 rewardPool;                     // only used if no masternode is registered -> all transaction fees will be added to the rewardPool and payed out to the first masternode registering
        uint256 rewardsPayedTotal;              // log all payouts for MN-statistics

        uint256 miningRewardInTokens;           // masternodes can mine x tokens per interval
        uint256 totalTokensMinedRaw1e18;        // logging: total tokens mined till now

        uint256 transactionRewardInSubtokensRaw1e18;//fee, subtracted from token sender on every transaction

        uint256 minBalanceRequiredInTokens;     // to register a masternode -> a balance of 100000 tokens is required
        uint256 minBalanceRequiredInSubtokensRaw1e18;// (*1e18 for internal integer calculations)

        uint256 minDepositRequiredInEther;      // to register a masternode a deposit in ether is required -> is a function of count: "activeMasternodes"
        uint256 minDepositRequiredInWei;        // ... same in wei (for internal use)
        uint8   maxMasternodesAllowed;          // no more than x masternodes allowed, default: 22
    }

    struct Masternode {
        address addr;           // 160 bit      // wallet-addresses of masternode owner
        uint256 balanceWei;     //  96 bit      // amount ether deposited in the contract
        uint256 sinceInterval;                  // MN created at this interval-index
        uint256 lastMiningInterval;             // last interval a MN mined new coins
    }

    StructMasternode public masternode; // = StructMasternode(0,0,0,0,100000 ether, 0.01 ether,1,1 ether,22);
    Masternode[22]   public masternodes;
    uint8 internal constant maxMasternodes = 22;
    uint256 internal miningRewardInSubtokensRaw1e18; // (*1e18 for internal integer calculations)


    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // +
    // + tokensale stuff
    // +
    // + 20 Mio. Tokens created at contract start (admin wallet)
    // + contributers can buy by "Buy"-function -> ETH send to adminWallet
    // + contributers can buy by failsave-function -> ETH send to contract, admin can withdraw
    // +
    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    struct Structtokensale { // compiler limit: max. 16 vars -> stack too deep
        // 1 token = 1e18 subTokens (smallest token unit, used for internal integer processing)
        uint256 initialTokenSupplyRAW1e18;      // Tokens internal resolution: 1e18 = 1 Ether = 1e18 Wei
        uint256 initialTokenSupplyAmount;
        uint256 initialTokenSupplyFraction;

        uint256 minPaymentRequiredUnitWei;      // min. payment required for buying tokens, default: 0.0001 ETH
        uint256 maxPaymentAllowedUnitWei;       // limit max. allowed payment per buy to 100 ETH

        uint256 startAtTimestamp;               // unixtime the tokensale starts

        bool    tokenSaleClosed;                // set to true by admin (manually) or contract (automatically if max. supply reached) if sale is closed
        bool    tokenSalePaused;                // admin can temp. pause tokensale

        uint256 totalWeiRaised;                 // by tokensale
        uint256 totalWeiInFallback;       // if someone send ether directly to contract -> admin can withdraw this balance

        uint256 totalTokensDistributedRAW1e18;
        uint256 totalTokensDistributedAmount;
        uint256 totalTokensDistributedFraction;
    }

    Structtokensale public tokensale;
    address adminWallet;        // 160 bit
    bool    sendFundsToWallet;  // 1 bit    // default:true -> transfer eth on buy; false -> admin must withdraw
    uint256 internal contractCreationTimestamp;      // (approx.) creation time of contract -> base for interval-index calculation
    uint256[20] tokensaleFactor;

    /*  // debug only: log all contibuters */
    struct Contributor {
        address addr;
        uint256 amountWei;
        uint256 amountTokensUnit1e18;
        uint256 sinceInterval;
    }

    Contributor[] public tokensaleContributors; // array of all contributors
    /* */



    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // +
    // + contract constructor -> init default values
    // +
    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    function MasteriumToken() payable public { // constructor
        // contract creation: 3993317
        name     = (debug) ? "Masterium_Testnet" : "Masterium";
        symbol   = (debug) ? "MTITestnet" : "MTI";
        version  = (debug) ? "1.00.00.Testnet" : "1.00.00";
        decimals = 18; // internal resolution = 1e18 = 1 Wei

        contractOwner = msg.sender;

        adminWallet = 0xAb942256b49F0c841D371DC3dFe78beFea447a27;

        sendFundsToWallet = true;

        contractCreationTimestamp = _getTimestamp();

        // tokenSALE: 20 mio tokens created; all to sell;
        tokensale.initialTokenSupplyRAW1e18 = 20000000 * TOKEN_MULTIPLIER; // 20 mio tokens == 20 mio * 10^18 subtokens (smallest unit for internal processing);
        tokensale.initialTokenSupplyAmount  = tokensale.initialTokenSupplyRAW1e18 / TOKEN_MULTIPLIER;
        tokensale.initialTokenSupplyFraction= tokensale.initialTokenSupplyRAW1e18 % TOKEN_MULTIPLIER;

        // limit buy amount (per transaction) during tokensale to a range from 0.0001 to 100 ether per "buytokens"-command.
        tokensale.minPaymentRequiredUnitWei = 0.0001 ether; // translates to 0.0001 * 1e18
        tokensale.maxPaymentAllowedUnitWei  = 100 ether;    // translates to 100.00 * 1e18

        require(adminWallet != address(0));
        require(tokensale.initialTokenSupplyRAW1e18 > 0);
        require(tokensale.minPaymentRequiredUnitWei > 0);
        require(tokensale.maxPaymentAllowedUnitWei > tokensale.minPaymentRequiredUnitWei);

        tokensale.tokenSalePaused = false;
        tokensale.tokenSaleClosed = false;

        tokensale.totalWeiRaised = 0;               // total amount of tokens buyed during tokensale
        tokensale.totalWeiInFallback = 0;     // the faction of total amount which was done by failsafe = direct ether send to contract

        tokensale.totalTokensDistributedRAW1e18 = 0;
        tokensale.totalTokensDistributedAmount  = 0;
        tokensale.totalTokensDistributedFraction= 0;

        tokensale.startAtTimestamp = (debug) ? contractCreationTimestamp + _addTime(DEBUG_STARTDELAY) : PRODUCTION_START;// tokensale starts at x

        tokensaleFactor[0] = 2000;
        tokensaleFactor[1] = 1000;
        tokensaleFactor[2] = 800;
        tokensaleFactor[3] = 500;
        tokensaleFactor[4] = 500;
        tokensaleFactor[5] = 500;
        tokensaleFactor[6] = 500;
        tokensaleFactor[7] = 500;
        tokensaleFactor[8] = 500;
        tokensaleFactor[9] = 400;
        tokensaleFactor[10] = 400;
        tokensaleFactor[11] = 400;
        tokensaleFactor[12] = 200;
        tokensaleFactor[13] = 200;
        tokensaleFactor[14] = 200;
        tokensaleFactor[15] = 400;
        tokensaleFactor[16] = 500;
        tokensaleFactor[17] = 800;
        tokensaleFactor[18] = 1000;
        tokensaleFactor[19] = 2500;

        _supplyTotal = tokensale.initialTokenSupplyRAW1e18;
        _supplyLastPayoutInterval = 0;                                // interval (index) of last processed interest-payout (initiated by a gas operation)

        accounts[contractOwner].balance = tokensale.initialTokenSupplyRAW1e18;
        accounts[contractOwner].lastPayoutInterval = 0;
        //accounts[contractOwner].lastAction = contractCreationTimestamp;

        // MASTERNODE: masternodes earn all transaction fees from balance transfers and can mine new tokens
        masternode.transactionRewardInSubtokensRaw1e18 = 0.01 * (1 ether); // 0.01 * 1e18 subtokens = 0.01 token

        masternode.miningRewardInTokens = 50000; // 50'000 tokens to mine per masternode per interval
        miningRewardInSubtokensRaw1e18 = masternode.miningRewardInTokens * TOKEN_MULTIPLIER; // used for internal integer calculation

        masternode.totalTokensMinedRaw1e18 = 0; // logs the amount of tokens mined by masternodes

        masternode.minBalanceRequiredInTokens = 100000; //to register a masternode -> a balance of 100000 tokens is required
        masternode.minBalanceRequiredInSubtokensRaw1e18 = masternode.minBalanceRequiredInTokens * TOKEN_MULTIPLIER; // used for internal integer calculation

        masternode.maxMasternodesAllowed = uint8(maxMasternodes);
        masternode.activeMasternodes= 0;
        masternode.totalBalanceWei  = 0;
        masternode.rewardPool       = 0;
        masternode.rewardsPayedTotal= 0;

        masternode.minDepositRequiredInEther= requiredBalanceForMasternodeInEther();// to register a masternode -> a deposit of ether is required (a function of numMasternodes)
        masternode.minDepositRequiredInWei  = requiredBalanceForMasternodeInWei(); // used for internal integer calculation


        // INTEREST: every tokenholder earn interest (% of balance) at a fixed interval (once per 30 days)
        interestConfig.interval = _addTime( (debug) ? DEBUG_INTERVAL : PRODUCTION_INTERVAL ); // interest payout interval in seconds, default: every 30 days
        interestConfig.periodicity      = 12;    // interestIntervalCapped = intervalIDX % periodicity
        interestConfig.stopAtInterval   = 4 * interestConfig.periodicity;  // stop paying interest after x intervals (performance reasons)
        interestConfig.startAtTimestamp = tokensale.startAtTimestamp; // first payout is after one interval

        // interest is reduced every 30 days and reset to 1st every stage (after 12 intervals)
        interestRates[ 0] = 1000000000000; // interval 1 = 100%
        interestRates[ 1] =  800000000000; // 80%
        interestRates[ 2] =  600000000000;
        interestRates[ 3] =  400000000000;
        interestRates[ 4] =  200000000000;
        interestRates[ 5] =  100000000000;
        interestRates[ 6] =   50000000000;
        interestRates[ 7] =   50000000000;
        interestRates[ 8] =   30000000000;
        interestRates[ 9] =   40000000000;
        interestRates[10] =   20000000000;
        interestRates[11] =   10000000000; //   1%

        // interestRates are reduced by factor every 12 intervals = 1 stage
        stageFactors[0] =  1000000000000; // interval  1..12 = factor 1
        stageFactors[1] =  4000000000000; // interval 13..24 = factor 4
        stageFactors[2] =  8000000000000;
        stageFactors[3] = 16000000000000;
    }




    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // +
    // + ERC20 stuff
    // +
    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    //event InterestPayed(address indexed owner, uint256 interestPayed);

    // erc20: tramsferFrom:: Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    function approve(address _spender, uint256 _value) public returns (bool) {
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));
        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);
        return true;
    }

    // erc20: tramsferFrom:: Returns the amount which _spender is still allowed to withdraw from _owner
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    // erc20: tramsferFrom
    function increaseApproval (address _spender, uint256 _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);

        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    // erc20: tramsferFrom
    function decreaseApproval (address _spender, uint256 _subtractedValue) public returns (bool success) {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }

        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    // erc20: public (command): token transfer by owner to someone
    // attn: total = _value + transactionFee !!! -> account-balance >= _value + transactionFee
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        _setBalances(msg.sender, _to, _value); // will fail if not enough balance
        _sendFeesToMasternodes(masternode.transactionRewardInSubtokensRaw1e18);

        Transfer(msg.sender, _to, _value);
        return true;
    }

    // erc20: public (command): Send _value amount of tokens from address _from to address _to
    // attn: total = _value + transactionFee !!! -> account-balance >= _value + transactionFee
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        var _allowance = allowed[_from][msg.sender];
        allowed[_from][msg.sender] = _allowance.sub(_value); // will fail if no (not enough) allowance
        _setBalances(_from, _to, _value);  // will fail if not enough balance
        _sendFeesToMasternodes(masternode.transactionRewardInSubtokensRaw1e18);

        Transfer(_from, _to, _value);
        return true;
    }

    // erc20: public (read only)
    function totalSupply() public constant returns (uint256 /*totalSupply*/) {
        return _calcBalance(_supplyTotal, _supplyLastPayoutInterval, intervalNow());
    }

    // erc20
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return _calcBalance(accounts[_owner].balance, accounts[_owner].lastPayoutInterval, intervalNow());
    }

    // public (read only): just to look pretty -> split 1e18 reolution to mainunits and the fraction part, just for direct enduser lookylooky at contract variables
    function totalSupplyPretty() public constant returns (uint256 tokens, uint256 fraction) {
        uint256 _raw = totalSupply();
        tokens  = _raw / TOKEN_MULTIPLIER;
        fraction= _raw % TOKEN_MULTIPLIER;
    }

    // public (read only): just to look pretty -> split 1e18 reolution to mainunits and the fraction part, just for direct enduser lookylooky at contract variables
    function balanceOfPretty(address _owner) public constant returns (uint256 tokens, uint256 fraction) {
        uint256 _raw = balanceOf(_owner);
        tokens  = _raw / TOKEN_MULTIPLIER;
        fraction= _raw % TOKEN_MULTIPLIER;
    }


    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // +
    // + Interest stuff
    // +
    // + every token holder receives interest (based on token balance) at fixed intervals (by default: 30 days)
    // +
    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    // public (read only): stage = how many interval cycles completed; increase every 12 intervals by 1; 1 stage = approx. 1 year
    // stage is unsed in interest calculation -> yearly factor
    // unnecessary -> just for enduser lookylooky
    function stageNow() public constant returns (uint256) {
        return intervalNow() / interestConfig.periodicity;
    }

    // public (read only): interval = index of the active interest interval. first interval = 0; increase every 30 days by 1; 1 interval = approx 1 month
    // interval is used for interest payouts and validating masternode mining interval
    function intervalNow() public constant returns (uint256) {
        uint256 timestamp = _getTimestamp();
        return (timestamp < interestConfig.startAtTimestamp) ? 0 : (timestamp - interestConfig.startAtTimestamp) / interestConfig.interval;
    }

    // public (read only): unixtime to next interest payout
    // unnecessary -> just for enduser lookylooky
    function secToNextInterestPayout() public constant returns (uint256) {
        if (intervalNow() > interestConfig.stopAtInterval) return 0; // no interest after x intervals
        //shortcutted to return:
        //uint256 timestamp = _getTimestamp();
        //uint256 intNow = intervalNow();
        //uint256 nextPayoutTimestamp = interestConfig.startAtTimestamp + (intNow +1)* interestConfig.interval;
        //return nextPayoutTimestamp - timestamp;
        return (interestConfig.startAtTimestamp + (intervalNow() + 1) * interestConfig.interval) - _getTimestamp();
    }

    // public (read only): next interest payout rate in percent
    // unnecessary -> just for enduser lookylooky
    function interestNextInPercent() public constant returns (uint256 mainUnit, uint256 fraction) {
        uint256 _now = intervalNow();
        uint256 _raw = _calcBalance(100 * TOKEN_MULTIPLIER, _now, _now+1);
        mainUnit = (_raw - 100 * TOKEN_MULTIPLIER) / TOKEN_MULTIPLIER;
        fraction = (_raw - 100 * TOKEN_MULTIPLIER) % TOKEN_MULTIPLIER;
        return;
    }

    // internal (gas operation): triggered before any (gas costy operation) balance transaction -> account interest to balance of address
    // its for performance reasons: use a gas operation to add new (cumulated) interest to account-balance to reduce interest-calc-loop (balanceOf)
    function _requestInterestPayoutToTotalSupply() internal {
        // payout interest to balance and set new payout index
        uint256 oldbal = _supplyTotal;   // read last known balance == balance at timeindex: "_supplyLastPayoutInterval"
        uint256 newbal = totalSupply();                                 // do interest calculation loop from "lastPayoutInterval" to now
        if (oldbal < newbal) {  // if balance changed because of new interest ...
            _supplyTotal = newbal;
        }
        // set new lastPayoutInterval for use in calculation loop
        _supplyLastPayoutInterval = intervalNow(); // interest already payed out to _supplyTotal until this index (now)
    }

    // internal (gas operation): triggered before any (gas costy operation) balance transaction -> account interest to balance of address
    // its for performance reasons: use a gas operation to add new (cumulated) interest to account-balance to reduce interest-calc-loop (balanceOf)
    function _requestInterestPayoutToAccountBalance(address _owner) internal {
        // payout interest to balance and set new payout index
        uint256 oldbal = accounts[_owner].balance;  // read last known balance == balance at timeindex: "accounts[_owner].lastPayoutInterval"
        uint256 newbal = balanceOf(_owner);         // do interest calculation loop from "lastPayoutInterval" to now
        if (oldbal < newbal) {  // if balance changed because of new interest ...
            accounts[_owner].balance = newbal;

            //no need for logging this:: InterestPayed(_owner, newbal - oldbal);
        }
        // set new lastPayoutInterval for use in calculation loop
        accounts[_owner].lastPayoutInterval = intervalNow(); // interest already payed out to [owner].balance until this index (now)
    }

    // internal (gas operation): triggered by a transation-function -> pay interest to both addr; subtract transaction fee; do token-transfer
    // every call triggers the interest payout loop and adds the new balance internaly -> next loop can save cpu-cycles
    function _setBalances(address _from, address _to, uint256 _value) internal {
        require(_from != _to);
        require(_value > 0);

        // set new balance (and new "last payout index") including interest for both parties before transfer
        _requestInterestPayoutToAccountBalance(_from);   // set new balance including interest
        //uncommented to keep the transaction cheeper...::_requestInterestPayoutToAccountBalance(_to);     // set new balance including interest
        //uncommented to keep the transaction cheeper...::_requestInterestPayoutToTotalSupply();

        // there must be enough balance for transfer AND transaction-fee
        require(_value.add(masternode.transactionRewardInSubtokensRaw1e18) <= accounts[_from].balance);

        // if sender is a masternode: freeze 100k of tokens balance -> to release the balance it is required to deregister the masternode first
        if (masternodeIsValid(_from)) {
            require(accounts[_from].balance >= masternode.minBalanceRequiredInSubtokensRaw1e18.add(_value)); // masternodes: 100k balance is freezed
        }

        // SafeMath.sub will throw if there is not enough balance.
        accounts[_from].balance = accounts[_from].balance.sub(_value).sub(masternode.transactionRewardInSubtokensRaw1e18);
        accounts[_to].balance   = accounts[_to].balance.add(_value);
    }

    // internal (no gas): calc interest as a function of interval-index (loop from-interval to to-interval)
    function _calcBalance(uint256 _balance, uint256 _from, uint256 _to) internal constant returns (uint256) {
        // attn.: significant integer capping for balances < 1e-16 -> acceptable limitation
        uint256 _newbalance = _balance;
        if (_to > interestConfig.stopAtInterval) _to = interestConfig.stopAtInterval; // no (more) interest after x intervals (default: 48)
        if (_from < _to) { // interest index since last payout (storage operation in transfers) -> calc new balance
            for (uint256 idx = _from; idx < _to; idx++) { // loop over unpayed intervals (since last payout-operation till now)
                if (idx > 48) break; // hardcap: just for ... you know

                _newbalance += (_newbalance * interestRates[idx % interestConfig.periodicity]) / stageFactors[(idx / interestConfig.periodicity) % 4];
            }
            if (_newbalance < _balance) { _newbalance = _balance; } // failsave if some math goes wrong (overflow). who knows...
        }
        return _newbalance;
        /*  interest by time (1 interval == 30 days)
            stagefactor	interval	interest	 total supply	 sum %
            1           0             0.0000%    20'000'000.00   100.00%
            after 30 days
            1	        1	        100.0000%    40'000'000.00	 200.00%
            1	        2	         80.0000%	 72'000'000.00	 360.00%
            1	        3	         60.0000%	115'200'000.00	 576.00%
            1	        4	         40.0000%	161'280'000.00	 806.40%
            1	        5	         20.0000%	193'536'000.00	 967.68%
            1	        6	         10.0000%	212'889'600.00	1064.45%
            1	        7	          5.0000%	223'534'080.00	1117.67%
            1	        8	          5.0000%	234'710'784.00	1173.55%
            1	        9	          3.0000%	241'752'107.52	1208.76%
            1	        10	          3.0000%	249'004'670.75	1245.02%
            1	        11	          2.0000%	253'984'764.16	1269.92%
            1	        12	          1.0000%	256'524'611.80	1282.62%
            after 1 year: 1282.62% pa in year 1
            4	        13	         25.0000%	320'655'764.75	1603.28%
            4	        14	         20.0000%	384'786'917.70	1923.93%
            4	        15	         15.0000%	442'504'955.36	2212.52%
            4	        16	         10.0000%	486'755'450.89	2433.78%
            4	        17	          5.0000%	511'093'223.44	2555.47%
            4	        18	          2.5000%	523'870'554.03	2619.35%
            4	        19	          1.2500%	530'418'935.95	2652.09%
            4	        20	          1.2500%	537'049'172.65	2685.25%
            4	        21	          0.7500%	541'077'041.44	2705.39%
            4	        22	          0.7500%	545'135'119.26	2725.68%
            4	        23	          0.5000%	547'860'794.85	2739.30%
            4	        24	          0.2500%	549'230'446.84	2746.15%
            after 2 years: 214.10% pa in year 2
            8	        25	         12.5000%	617'884'252.69	3089.42%
            8	        26	         10.0000%	679'672'677.96	3398.36%
            8	        27	          7.5000%	730'648'128.81	3653.24%
            8	        28	          5.0000%	767'180'535.25	3835.90%
            8	        29	          2.5000%	786'360'048.63	3931.80%
            8	        30	          1.2500%	796'189'549.24	3980.95%
            8	        31	          0.6250%	801'165'733.92	4005.83%
            8	        32	          0.6250%	806'173'019.76	4030.87%
            8	        33	          0.3750%	809'196'168.58	4045.98%
            8	        34	          0.3750%	812'230'654.22	4061.15%
            8	        35	          0.2500%	814'261'230.85	4071.31%
            8	        36	          0.1250%	815'279'057.39	4076.40%
            after 3 years: 148.44% pa in year 3
            16	        37	          6.2500%	866'233'998.48	4331.17%
            16	        38	          5.0000%	909'545'698.40	4547.73%
            16	        39	          3.7500%	943'653'662.09	4718.27%
            16	        40	          2.5000%	967'245'003.64	4836.23%
            16	        41	          1.2500%	979'335'566.19	4896.68%
            16	        42	          0.6250%	985'456'413.48	4927.28%
            16	        43	          0.3125%	988'535'964.77	4942.68%
            16	        44	          0.3125%	991'625'139.66	4958.13%
            16	        45	          0.1875%	993'484'436.80	4967.42%
            16	        46	          0.1875%	995'347'220.12	4976.74%
            16	        47	          0.1250%	996'591'404.14	4982.96%
            16	        48	          0.0625%	997'214'273.77	4986.07%
            after 4 years: 122.32% pa in year 4
            16	        49 .. inf     0.0000%	997'214'273.77	4986.07%
        */
    }






    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // +
    // + Masternode stuff
    // +
    // + every registered masternodes receives a part of the transaction fee
    // + every masternode can mine 50´000 once every interval (30 days)
    // +
    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    event MasternodeRegistered(address indexed addr, uint256 amount);
    event MasternodeDeregistered(address indexed addr, uint256 amount);
    event MasternodeMinedTokens(address indexed addr, uint256 amount);
    event MasternodeTransferred(address fromAddr, address toAddr);
    event MasternodeRewardSend(uint256 amount);
    event MasternodeRewardAddedToRewardPool(uint256 amount);
    event MaxMasternodesAllowedChanged(uint8 newNumMaxMasternodesAllowed);
    event TransactionFeeChanged(uint256 newTransactionFee);
    event MinerRewardChanged(uint256 newMinerReward);

    // public (read only): unixtime to next interest payout
    // unnecessary -> just for enduser lookylooky
    function secToNextMiningInterval() public constant returns (uint256) {
        return secToNextInterestPayout();
    }

    // internal (read only):
    // unnecessary -> just for enduser lookylooky
    function requiredBalanceForMasternodeInEther() constant internal returns (uint256) {
        // 1st masternode = 1 ether required to deposit in contract
        // 2nd masternode = 4 ether
        // 3rd masternode = 9 ether
        // 4th masternode = 16 ether
        // 5th masternode = 25 ether
        // 6th masternode = 36 ether
        // 22th           = 484 ether
        return (masternode.activeMasternodes + 1) ** 2;
    }

    // internal (read only): used in masternodeRegister and Deregister
    function requiredBalanceForMasternodeInWei() constant internal returns (uint256) {
        return (1 ether) * (masternode.activeMasternodes + 1) ** 2;
    }

    // public (command): send ETH (requiredBalanceForMasternodeInEther) to contract to become a masternode
    function masternodeRegister() payable public {
        // gas: 104'000 / max: 140k
        require(msg.sender != address(0));
        require(masternode.activeMasternodes < masternode.maxMasternodesAllowed);       // max. masternodes allowed
        require(msg.value == requiredBalanceForMasternodeInWei() );                     // eth deposit
        require(_getMasternodeSlot(msg.sender) >= maxMasternodes);                      // only one masternode per address

        _requestInterestPayoutToTotalSupply();
        _requestInterestPayoutToAccountBalance(msg.sender); // do interest payout before checking balance
        require(accounts[msg.sender].balance >= masternode.minBalanceRequiredInSubtokensRaw1e18); // required token balance of 100k at addr to register a masternode
        //was: require(balanceOf(msg.sender) >= masternode.minBalanceRequiredInSubtokensRaw1e18); // required token balance of 100k at addr to register a masternode

        uint8 slot = _findEmptyMasternodeSlot();
        require(slot < maxMasternodes); // should never trigger

        masternodes[slot].addr = msg.sender;
        masternodes[slot].balanceWei = msg.value;
        masternodes[slot].sinceInterval = intervalNow();
        masternodes[slot].lastMiningInterval = intervalNow();

        masternode.activeMasternodes++;

        masternode.minDepositRequiredInEther= requiredBalanceForMasternodeInEther(); // attn: first inc activeMN
        masternode.minDepositRequiredInWei  = requiredBalanceForMasternodeInWei(); // attn: first inc activeMN

        masternode.totalBalanceWei = masternode.totalBalanceWei.add(msg.value);    // this balance could never be withdrawn by contract admin

        MasternodeRegistered(msg.sender, msg.value);
    }

    // public (command): close masternode and send deposited ETH back to owner
    function masternodeDeregister() public preventReentry returns (bool _success) {
        require(msg.sender != address(0));
        require(masternode.activeMasternodes > 0);
        require(masternode.totalBalanceWei > 0);
        require(this.balance >= masternode.totalBalanceWei + tokensale.totalWeiInFallback);

        uint8 slot = _getMasternodeSlot(msg.sender);
        require(slot < maxMasternodes); // masternode found in list?

        uint256 balanceWei = masternodes[slot].balanceWei;
        require(masternode.totalBalanceWei >= balanceWei);

        _requestInterestPayoutToTotalSupply();
        _requestInterestPayoutToAccountBalance(msg.sender); // do interest payout before checking balance

        masternodes[slot].addr = address(0);
        masternodes[slot].balanceWei = 0;
        masternodes[slot].sinceInterval = 0;
        masternodes[slot].lastMiningInterval = 0;

        masternode.totalBalanceWei = masternode.totalBalanceWei.sub(balanceWei);

        masternode.activeMasternodes--;

        masternode.minDepositRequiredInEther = requiredBalanceForMasternodeInEther(); // attn: first dec activeMN
        masternode.minDepositRequiredInWei   = requiredBalanceForMasternodeInWei(); // attn: first dec activeMN

        //if (!addr.send(balanceWei)) revert(); // send back ether to wallet of sender
        msg.sender.transfer(balanceWei); // send back ether to wallet of sender

        MasternodeDeregistered(msg.sender, balanceWei);
        _success = true;
        }

    // public (command): close masternode and send deposited ETH back to owner
    function masternodeMineTokens() public {
        // gas: up to 105000
        require(msg.sender != address(0));
        require(masternode.activeMasternodes > 0);

        uint256 _inow = intervalNow();
        require(_inow <= interestConfig.stopAtInterval); // mining stops after approx. 4 years (48 intervals by 30 days)

        uint8 slot = _getMasternodeSlot(msg.sender);
        require(slot < maxMasternodes); // masternode found in list?
        require(masternodes[slot].lastMiningInterval < _inow); // masternode did not already mine this interval?

        _requestInterestPayoutToTotalSupply();
        _requestInterestPayoutToAccountBalance(msg.sender);   // set new balance including interest
        require(accounts[msg.sender].balance >= masternode.minBalanceRequiredInSubtokensRaw1e18); // required token balance at addr to register a masternode
        //was: require(balanceOf(msg.sender) >= masternode.minBalanceRequiredInSubtokensRaw1e18); // required token balance of 100k at addr to register a masternode

        masternodes[slot].lastMiningInterval = _inow;

        uint256 _minedTokens = miningRewardInSubtokensRaw1e18;

        // SafeMath.sub will throw if there is not enough balance.
        accounts[msg.sender].balance = accounts[msg.sender].balance.add(_minedTokens);

        // attn.: _requestInterestPayoutToTotalSupply() must be called first to set lastPayoutInterval correctly
        _supplyTotal = _supplyTotal.add(_minedTokens);
        //_supplyMined = _supplyMined.add(_minedTokens);

        masternode.totalTokensMinedRaw1e18 = masternode.totalTokensMinedRaw1e18.add(_minedTokens);

        MasternodeMinedTokens(msg.sender, _minedTokens);
    }

    // public (command): owner of a masternode can transfer the mn (and the value in ETH) to another wallet address
    function masternodeTransferOwnership(address newAddr) public {
        require(masternode.activeMasternodes > 0);
        require(msg.sender != address(0));
        require(newAddr != address(0));
        require(newAddr != msg.sender);

        uint8 slot = _getMasternodeSlot(msg.sender);
        require(slot < maxMasternodes); // masternode found in list? only the owner of a masternode can transfer a masternode to a new address

        _requestInterestPayoutToTotalSupply();
        _requestInterestPayoutToAccountBalance(msg.sender); // do interest payout before moving masternode
        require(accounts[newAddr].balance >= masternode.minBalanceRequiredInSubtokensRaw1e18); // required token balance at addr to register a masternode
        //was: require(balanceOf(newAddr) >= masternode.minBalanceRequiredInSubtokensRaw1e18); // required token balance at addr to register a masternode

        masternodes[slot].addr = newAddr;

        MasternodeTransferred(msg.sender, newAddr);
    }

    // public (read only): check if addr is a masternode
    function masternodeIsValid(address addr) public constant returns (bool) {
        return (_getMasternodeSlot(addr) < maxMasternodes) && (balanceOf(addr) >= masternode.minBalanceRequiredInSubtokensRaw1e18);
    }

    // internal (read only):
    function _getMasternodeSlot(address addr) internal constant returns (uint8) {
        uint8 idx = maxMasternodes; // masternode.maxMasternodesAllowed;
        for (uint8 i = 0; i < maxMasternodes; i++) {
            if (masternodes[i].addr == addr) { // if sender is a registered masternode
                idx = i;
                break;
            }
        }
        return idx; // if idx == maxMasternodes (22) -> no entry found; valid masternode slots: 0 .. 21
    }

    // internal (read only): faster than push / pop operations on arrays
    function _findEmptyMasternodeSlot() internal constant returns (uint8) {
        uint8 idx = maxMasternodes; // masternode.maxMasternodesAllowed;

        if (masternode.activeMasternodes < maxMasternodes)
        for (uint8 i = 0; i < maxMasternodes; i++) {
            if (masternodes[i].addr == address(0) && masternodes[i].sinceInterval == 0) { // if slot empty
                idx = i;
                break;
            }
        }
        return idx; // if idx == maxMasternodes -> no entry found
    }

    // internal (command):
    function _sendFeesToMasternodes(uint256 _fee) internal {
        uint256 _pool = masternode.rewardPool;
        if (_fee + _pool > 0 && masternode.activeMasternodes > 0) { // if min. 1 masternode exists
            masternode.rewardPool = 0;
            uint256 part = (_fee + _pool) / masternode.activeMasternodes;
            uint256 sum = 0;
            address addr;
            for (uint8 i = 0; i < maxMasternodes; i++) {
                addr = masternodes[i].addr;
                if (addr != address(0)) {
                    accounts[addr].balance = (accounts[addr].balance).add(part); // send fee as reward
                    sum += part;
                }
            }
            if (sum < part) masternode.rewardPool = part - sum; // do not loose integer-div-roundings
            masternode.rewardsPayedTotal += sum;
            MasternodeRewardSend(sum);
        } else { // no masternodes -> collect fees for the first masternode registering
            masternode.rewardPool = masternode.rewardPool.add(_fee);
            MasternodeRewardAddedToRewardPool(_fee);
        }
    }



    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // +
    // + tokensale stuff
    // +
    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    event TokenSaleFinished();
    event TokenSaleClosed();
    event TokenSaleOpened();
    event TokenSalePaused(bool paused);

    // public (command): fallback function - can be used to buy tokens (attn.: can fail silently if not enough gas is provided)
    /* deactivated for user-safety */
    function () payable public {
        // gas used: 170000 to 251371 gaslimit: provide 500000 or more!!!
        _buyTokens(msg.sender, true); // triggers failsafe -> no direct transfer to contract-owner wallet to safe gas
    }
    /* */
    
    // public (command): official function to buy tokens during tokensale
    function tokensaleBuyTokens() payable public {
        _buyTokens(msg.sender, false); // direct transfer to contract-owner
    }

    // public (read only): calc the active sale stage as a function of already selled amount
    function tokensaleStageNow() public constant returns (uint256) {
        return tokensaleStageAt(tokensale.totalTokensDistributedRAW1e18);
    }

    // public (read only): calc the active sale stage as a function of any amount
    function tokensaleStageAt(uint256 _tokensdistibutedRAW1e18) public pure returns (uint256) {
        return _tokensdistibutedRAW1e18 / (1000000 * TOKEN_MULTIPLIER);
    }

    // public (read only): calc the active exchange factor (tokens per ETH) as a function of already selled amount
    function tokensaleTokensPerEtherNow() public constant returns (uint256) {
        return _tokensaleTokensPerEther(tokensale.totalTokensDistributedRAW1e18);
    }

    /*
    // public (read only): calc the active exchange factor (tokens per ETH) as a function of any amount
    function tokensaleTokensPerEtherAtAmount(uint256 _tokensdistibutedRAW1e18) public constant returns (uint256) {
        return _tokensaleTokensPerEther(_tokensdistibutedRAW1e18);
    }
    */
    /*
    // public (read only): calc the active exchange factor (tokens per ETH) as a function of any stage
    function tokensaleTokensPerEtherAtStage(uint256 _stage) public constant returns (uint256) {
        return _tokensaleTokensPerEther(_stage * 1000000 * TOKEN_MULTIPLIER);
    }
    */

    // internal (read only): calculate current exchange rate -> ether payed * factor = tokens distributed
    function _tokensaleTokensPerEther(uint256 _tokensdistibuted) internal constant returns (uint256) {
        uint256 factor = tokensaleFactor[tokensaleStageAt(_tokensdistibuted) % 20]; // % 20 == prevent array overflow on unexpected error
        return factor * ( (debug) ? DEBUG_SALEFACTOR : PRODUCTION_SALEFACTOR ); // debug only stuff

        // total tokens: 20 Mio
        // total ETH to buy all tokens: approx. 44400 ETH (444 in debug mode)
        /*
        stage tokens   tokens     ether     1 token      usd per stage                  1 token
            per stage per ether	per stage	in ether	 (300 usd/ETH)	sum usd	        in usd
        1	1'000'000	2'000	  500.00	0.00050000	  150'000.00	  150'000.00	0.1500
        2	1'000'000	1'000	1'000.00	0.00100000	  300'000.00	  450'000.00	0.3000
        3	1'000'000	  800	1'250.00	0.00125000	  375'000.00	  825'000.00	0.3750
        4	1'000'000	  500	2'000.00	0.00200000	  600'000.00	1'425'000.00	0.6000
        5	1'000'000	  500	2'000.00	0.00200000	  600'000.00	2'025'000.00	0.6000
        6	1'000'000	  500	2'000.00	0.00200000	  600'000.00	2'625'000.00	0.6000
        7	1'000'000	  500	2'000.00	0.00200000	  600'000.00	3'225'000.00	0.6000
        8	1'000'000	  500	2'000.00	0.00200000	  600'000.00	3'825'000.00	0.6000
        9	1'000'000	  500	2'000.00	0.00200000	  600'000.00	4'425'000.00	0.6000
        10	1'000'000	  400	2'500.00	0.00250000	  750'000.00	5'175'000.00	0.7500
        11	1'000'000	  400	2'500.00	0.00250000	  750'000.00	5'925'000.00	0.7500
        12	1'000'000	  400	2'500.00	0.00250000	  750'000.00	6'675'000.00	0.7500
        13	1'000'000	  200	5'000.00	0.00500000	1'500'000.00	8'175'000.00	1.5000
        14	1'000'000	  200	5'000.00	0.00500000	1'500'000.00	9'675'000.00	1.5000
        15	1'000'000	  200	5'000.00	0.00500000	1'500'000.00	11'175'000.00	1.5000
        16	1'000'000	  400	2'500.00	0.00250000	  750'000.00	11'925'000.00	0.7500
        17	1'000'000	  500	2'000.00	0.00200000	  600'000.00	12'525'000.00	0.6000
        18	1'000'000	  800	1'250.00	0.00125000	  375'000.00	12'900'000.00	0.3750
        19	1'000'000	1'000	1'000.00	0.00100000	  300'000.00	13'200'000.00	0.3000
        20	1'000'000	2'500	  400.00	0.00040000	  120'000.00	13'320'000.00	0.1200
           20'000'000	       44'400.00 ETH	       13'320'000.00	      average:	0.6700
	    */
    }

    // internal: token purchase function
    function _buyTokens(address addr, bool failsafe) internal {
        require(addr != address(0));
        require(msg.value > 0);
        require(msg.value >= tokensale.minPaymentRequiredUnitWei); // min. payment required
        require(msg.value <= tokensale.maxPaymentAllowedUnitWei); // max. payment allowed
        require(tokensaleStarted() && !tokensaleFinished() && !tokensalePaused());

        uint256 amountTokens;
        uint256 actExchangeRate = _tokensaleTokensPerEther(tokensale.totalTokensDistributedRAW1e18);
        uint256 amountTokensToBuyAtThisRate = msg.value * actExchangeRate;
        uint256 availableAtThisRate = (1000000 * TOKEN_MULTIPLIER) - ((tokensale.totalTokensDistributedRAW1e18) % (1000000 * TOKEN_MULTIPLIER));

        if (amountTokensToBuyAtThisRate <= availableAtThisRate) { // wei fits in this exchangerate-stage
            amountTokens = amountTokensToBuyAtThisRate;
        } else { // on border crossing (no more than 1 border crossing possible, because of max. buy limit of 100 ETH = 100 * 5000 = 0.5 mio)
            amountTokens = availableAtThisRate;
            //uint256 nextExchangeRate = _tokensaleTokensPerEther(tokensale.totalTokensDistributedRAW1e18 + amountTokens);
            //uint256 amountTokensToBuyAtNextRate = (msg.value - availableAtThisRate / actExchangeRate) * nextExchangeRate;

            amountTokens += (msg.value - availableAtThisRate / actExchangeRate) * _tokensaleTokensPerEther(tokensale.totalTokensDistributedRAW1e18 + amountTokens); //amountTokensToBuyAtNextRate;
        }

        require(amountTokens > 0);
        require(tokensale.totalTokensDistributedRAW1e18.add(amountTokens) <= tokensale.initialTokenSupplyRAW1e18); // check limit

        _requestInterestPayoutToTotalSupply();
        _requestInterestPayoutToAccountBalance(contractOwner); // do interest payout before changing balances
        _requestInterestPayoutToAccountBalance(addr); // do interest payout before changing balances

        tokensale.totalWeiRaised = tokensale.totalWeiRaised.add(msg.value);
        if (!sendFundsToWallet || failsafe) tokensale.totalWeiInFallback = tokensale.totalWeiInFallback.add(msg.value);

        tokensale.totalTokensDistributedRAW1e18 = tokensale.totalTokensDistributedRAW1e18.add(amountTokens);
        tokensale.totalTokensDistributedAmount = tokensale.totalTokensDistributedRAW1e18 / TOKEN_MULTIPLIER;
        tokensale.totalTokensDistributedFraction = tokensale.totalTokensDistributedRAW1e18 % TOKEN_MULTIPLIER;

        // SafeMath.sub will throw if there is not enough balance.
        accounts[contractOwner].balance = accounts[contractOwner].balance.sub(amountTokens);
        accounts[addr].balance = accounts[addr].balance.add(amountTokens);


        /* debug only */
        if (debug) {
            // update list of all contributors
            Contributor memory newcont;
            newcont.addr = addr;
            newcont.amountWei = msg.value;
            newcont.amountTokensUnit1e18 = amountTokens;
            newcont.sinceInterval = intervalNow();
            tokensaleContributors.push( newcont );
        }
        /* */

        // send tokens to wallet of sender from ether
        if (sendFundsToWallet && !failsafe) adminWallet.transfer(msg.value); // req. more gas

        TokensPurchased(contractOwner, addr, msg.value, amountTokens);
    }

    // public (read only): unixtime to next interest payout
    function tokensaleSecondsToStart() public constant returns (uint256) {
        //uint256 timestamp = _getTimestamp();
        return (tokensale.startAtTimestamp <= _getTimestamp()) ? 0 : tokensale.startAtTimestamp - _getTimestamp();
    }


    // @return true if tokensale has started
    function tokensaleStarted() internal constant returns (bool) {
        return _getTimestamp() >= tokensale.startAtTimestamp;
    }

    // @return true if tokensale ended
    function tokensaleFinished() internal constant returns (bool) {
        return (tokensale.totalTokensDistributedRAW1e18 >= tokensale.initialTokenSupplyRAW1e18 || tokensale.tokenSaleClosed);
    }

    // @return true if tokensale is paused
    function tokensalePaused() internal constant returns (bool) {
        return tokensale.tokenSalePaused;
    }


    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    // +
    // + admin only stuff
    // +
    // ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    event AdminTransferredOwnership(address indexed previousOwner, address indexed newOwner);
    event AdminChangedFundingWallet(address oldAddr, address newAddr);

    // public (admin only): contact control functions; contract creator only; all in one
    function adminCommand(uint8 command, address addr, uint256 fee) onlyOwner public returns (bool) {
        require(command >= 0 && command <= 255);
        if (command == 1) { // (EnumAdminCommand(command) == EnumAdminCommand.SendAllFailsafeEtherToAdminWallet
            // contract stores ETH:
            // - masternode.totalBalanceWei == never withdrawable by contract owner (only by each MN owner)
            // - tokensale.totalWeiInFallback
            // - maybe: locked ether by unforseen errors

            require(this.balance >= tokensale.totalWeiInFallback);

            uint256 _withdrawBalance = this.balance.sub(masternode.totalBalanceWei);
            require(_withdrawBalance > 0);

            adminWallet.transfer(_withdrawBalance);
            tokensale.totalWeiInFallback = 0;
            return true;
        } else

        if (command == 15) { // (EnumAdminCommand(command) == EnumAdminCommand.RecalculateTotalSupply
            // speed up realtime request to balance functions by periodic call this gas cost operation
            _requestInterestPayoutToTotalSupply();
            _requestInterestPayoutToAccountBalance(contractOwner); // do interest payout before changing balances
        } else

        if (command == 22) { // (EnumAdminCommand(command) == EnumAdminCommand.changeTransactionFee) {
            require(fee >= 0 && fee <= (9999 * TOKEN_MULTIPLIER) && fee != masternode.transactionRewardInSubtokensRaw1e18);
            masternode.transactionRewardInSubtokensRaw1e18 = fee;

            TransactionFeeChanged(fee);
            return true;
        } else
        if (command == 33) { // (EnumAdminCommand(command) == EnumAdminCommand.ChangeMinerReward) {
            require(fee >= 0 && fee <= (999999) && fee != masternode.miningRewardInTokens);

            masternode.miningRewardInTokens = fee;                              // 50'000 tokens to mine per masternode per interval
            miningRewardInSubtokensRaw1e18 = fee * TOKEN_MULTIPLIER; // used for internal integer calculation

            MinerRewardChanged(fee);
            return true;
        } else

        if (command == 111) { // (EnumAdminCommand(command) == EnumAdminCommand.CloseTokensale) {
            tokensale.tokenSaleClosed = true;

            TokenSaleClosed();
            return true;
        } else
        if (command == 112) { // (EnumAdminCommand(command) == EnumAdminCommand.OpenTokensale) {
            tokensale.tokenSaleClosed = false;

            TokenSaleOpened();
            return true;
        } else
        if (command == 113) { // (EnumAdminCommand(command) == EnumAdminCommand.PauseTokensale) {
            tokensale.tokenSalePaused = true;

            TokenSalePaused(true);
            return true;
        } else
        if (command == 114) { // (EnumAdminCommand(command) == EnumAdminCommand.UnpauseTokensale) {
            tokensale.tokenSalePaused = false;

            TokenSalePaused(false);
            return true;
        } else

        if (command == 150) { // (EnumAdminCommand(command) == EnumAdminCommand.TransferOwnership) {
            require(addr != address(0));
            address oldOwner = contractOwner;
            contractOwner = addr;

            AdminTransferredOwnership(oldOwner, addr);
            return true;
        } else
        if (command == 152) { // (EnumAdminCommand(command) == EnumAdminCommand.ChangeAdminWallet) {
            require(addr != address(0));
            require(addr != adminWallet);
            address oldAddr = adminWallet;
            adminWallet = addr;

            AdminChangedFundingWallet(oldAddr, addr);
            return true;
        } else

        if (command == 225) { // (EnumAdminCommand(command) == EnumAdminCommand.SelfDestuct) { // enabled during debug only!
            require(debug || PRODUCTION_START>_getTimestamp()); // only allowed in debugging mode = during development and in production mode before sale starts

            DebugValue("debug: suicide", this.balance);
            selfdestruct(contractOwner);
            return true;
        }
        /*else

        if (command == 236) { // (EnumAdminCommand(command) == EnumAdminCommand.SendAllEther) { // enabled during debug only!
            require(debug); // only allowed in debugging mode = during development

            DebugValue("debug: send all ether to admin", this.balance);
            contractOwner.transfer(this.balance);
            return true;
        } else
        if (command == 247) { // (EnumAdminCommand(command) == EnumAdminCommand.DisableDebugMode) { // re-enabling is impossible
            require(debug); // only allowed in debugging mode = during development

            DebugValue("debug: debug mode disabled - unreverable operation", this.balance);
            debug = false;
            return true;
        }*/
        return false;
    }

    modifier onlyOwner() {
        require(msg.sender == contractOwner);
        _;
    }

    function _getTimestamp() internal constant returns (uint256) {
        return now; // alias for block.timestamp;
        // eth-miner manipulation of timestamp (possible in a range up to 900 seconds) is acceptable because interval-functions are in a range from 7 to 30 days.
    }

    function _addTime(uint256 _sec) internal pure returns (uint256) {
        return _sec * (1 seconds); // in unittime
    }
}