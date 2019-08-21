pragma solidity ^0.5.0;

/**
  * @title DSMath
  * @author MakerDAO
  * @notice Safe math contracts from Maker.
  */
contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

/**
  * @title Owned
  * @author Gavin Wood?
  * @notice Primitive owner properties, modifiers and methods for a single
  *     to own a particular contract.
  */
contract Owned {
    address public owner = msg.sender;

    modifier isOwner {
        assert(msg.sender == owner); _;
    }

    function changeOwner(address account) external isOwner {
        owner = account;
    }
}

/**
  * @title Pausable
  * @author MakerDAO?
  * @notice Primitive events, methods, properties for a contract which can be
        paused by a single owner.
  */
contract Pausable is Owned {
    event Pause();
    event Unpause();

    bool public paused;

    modifier pausable {
        assert(!paused); _;
    }

    function pause() external isOwner {
        paused = true;

        emit Pause();
    }

    function unpause() external isOwner {
        paused = false;

        emit Unpause();
    }
}

/**
  * @title BurnerAccount
  * @author UnityCoin Team
  * @notice Primitive events, methods, properties for a contract which has a
          special burner account that is Owned by a single account.
  */
contract BurnerAccount is Owned {
    address public burner;

    modifier isOwnerOrBurner {
        assert(msg.sender == burner || msg.sender == owner); _;
    }

    function changeBurner(address account) external isOwner {
        burner = account;
    }
}

/**
  * @title IntervalBased
  * @author UnityCoin Team
  * @notice Primitive events, methods, properties for a contract which has a
  *        interval system, that can be changed in-flight.
  *
  *        Here we create a system in which any valid unixtimestamp can reduce
  *        down to a specific interval number, based on a start time, duration
  *        and offset.
  *
  *        Interval Derivation
  *        number = offset + ((timestamp - start time) / intervalDuration)
  *
  *        Note, when your changing the interval params in flight, we must
  *        set the offset to the most current interval number, as to not
  *        disrupt previously used interval numbers / mechanics
  */
contract IntervalBased is DSMath {
    // the start interval
    uint256 public intervalStartTimestamp;

    // interval duration (e.g. 1 days)
    uint256 public intervalDuration;

    // the max amount of intervals that can be processed for interest claim
    uint256 public intervalMaximum;

    // interval offset
    uint256 public intervalOffset;

    function changeDuration(uint256 duration) internal {
      // protect againt unecessary change of offset and starttimestamp
      if (duration == intervalDuration) { return; }

      // offset all previous intervals
      intervalOffset = intervalNumber(block.timestamp);

      // set new duration
      intervalDuration = duration;

      // restart timestamp to current
      intervalStartTimestamp = block.timestamp;
    }

    // get the interval number from start position
    // every timestamp should have an interval past the start timestamp..
    function intervalNumber(uint256 timestamp) public view returns(uint256 number) {
        return add(intervalOffset, sub(timestamp, intervalStartTimestamp) / intervalDuration);
    }
}

/**
  * @title ERC20Events
  * @author EIP20 Authors
  * @notice Primitive events for the ERC20 event specification.
  */
contract ERC20Events {
    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}

/**
  * @title ERC20
  * @author EIP/ERC20 Authors
  * @author BokkyPooBah / Bok Consulting Pty Ltd 2018.
  * @notice The ERC20 standard contract interface.
  */
contract ERC20 is ERC20Events {
    function totalSupply() external view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint);
    function allowance(address tokenOwner, address spender) external view returns (uint);

    function approve(address spender, uint amount) public returns (bool);
    function transfer(address to, uint amount) external returns (bool);
    function transferFrom(
        address from, address to, uint amount
    ) public returns (bool);
}

/**
  * @title ERC20Token
  * @author BokkyPooBah / Bok Consulting Pty Ltd 2018.
  * @author UnityCoin Team
  * @author MakerDAO
  * @notice An ERC20 Token implimentation based roughly off of MakerDAO's
  *       version DSToken.
  */
contract ERC20Token is DSMath, ERC20 {
    // Standard EIP20 Name, Symbol, Decimals
    string public symbol = "USDC";
    string public name = "UnityCoinTest";
    string public version = "1.0.0";
    uint8 public decimals = 18;

    // Balances for each account
    mapping(address => uint256) balances;

    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint256)) approvals;

    // Standard EIP20: BalanceOf, Transfer, TransferFrom, Allow, Allowance methods..
    // Get the token balance for account `tokenOwner`
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    // Transfer the balance from owner's account to another account
    function transfer(address to, uint256 tokens) external returns (bool success) {
        return transferFrom(msg.sender, to, tokens);
    }

    // Send `tokens` amount of tokens from address `from` to address `to`
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the from account has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    function transferFrom(address from, address to, uint256 tokens) public returns (bool success) {
        if (from != msg.sender) {
            approvals[from][msg.sender] = sub(approvals[from][msg.sender], tokens);
        }

        balances[from] = sub(balances[from], tokens);
        balances[to] = add(balances[to], tokens);

        emit Transfer(from, to, tokens);
        return true;
    }

    // Allow `spender` to withdraw from your account, multiple times, up to the `tokens` amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address spender, uint256 tokens) public returns (bool success) {
        approvals[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) external view returns (uint remaining) {
        return approvals[tokenOwner][spender];
    }
}

/**
  * @title InterestRateBased
  * @author UnityCoin Team
  * @notice A compount interest module which allows for the recording of balance
  *       events and interest rate changes.
  *
  *       Compound Interest Aglo:
  *       compound interest owed = (principle * ( 1 + Rate / 100 ) * N) – principle;
  *
  *       This module uses the interval system IntervalBased.
  *       The module is time based and thus we accept that miners can manipulate
  *       time.
  *
  *       Rate's are specified (as per DSMath imp.) in 10 pow 27 always.
  *       Rates are recorded in an array `interestRates` and thus are indexed.
  *
  *       Everytime a balance is recorded, we also make sure to set an updatable
  *       pointer to the most recent InterestRate index `intervalToInterestIndex`.
  *
  *       This module provides a way to calculate compound interest owed,
  *       given the interest rates and balance records are recoded properly.
  */
contract InterestRateBased is IntervalBased {
    // Interest Rate Record
    struct InterestRate {
        uint256 interval;
        uint256 rate; // >= 10 ** 27
    }

    // Interval to interest rate
    InterestRate[] public interestRates;

    // uint256(interval) => uint256(interest index)
    mapping(uint256 => uint256) public intervalToInterestIndex;

    // Balance Records
    struct BalanceRecord {
        uint256 interval;
        uint256 intervalOffset;
        uint256 balance;
    }

    // address(token holder) => uint256(interval) => BalanceChange
    mapping(address => BalanceRecord[]) public balanceRecords;

    // address(tokenOwner) => uint256(balance index)
    mapping(address => uint256) public lastClaimedBalanceIndex;

    // include balance of method, is ERC20 compliant for tokens
    function balanceOf(address tokenOwner) public view returns (uint);

    // VIEW: get current interest rate
    function latestInterestRate() external view returns (uint256 rateAsRay, uint256 asOfInterval) {
        uint256 latestRateIndex = interestRates.length > 0 ? sub(interestRates.length, 1) : 0;

        return (interestRates[latestRateIndex].rate, interestRates[latestRateIndex].interval);
    }

    // getters
    function numInterestRates() public view returns (uint256) {
      return interestRates.length;
    }

    // getters
    function numBalanceRecords(address tokenOwner) public view returns (uint256) {
      return balanceRecords[tokenOwner].length;
    }

    // interest owed
    function interestOwed(address tokenOwner)
        public
        view
        returns (uint256 amountOwed, uint256 balanceIndex, uint256 interval) {

        // check for no balance records..
        if (balanceRecords[tokenOwner].length == 0) {
          return (0, 0, 0);
        }

        // balance index
        amountOwed = 0;
        balanceIndex = lastClaimedBalanceIndex[tokenOwner];
        interval = balanceRecords[tokenOwner][balanceIndex].intervalOffset;

        // current principle and interest rate
        uint256 principle = 0; // current principle value
        uint256 interestRate = 0; // current interest rate

        // interval markers and interval offset
        uint256 nextBalanceInterval = interval; // set to starting interval for setup
        uint256 nextInterestInterval = interval; // set to starting interval for setup

        // enforce interval maximum, last claim offset difference with max
        assert(sub(intervalNumber(block.timestamp), intervalOffset) < intervalMaximum);

        // this for loop should only hit either interest or balance change records, and in theory process only
        // what is required to calculate compound interest with general computaitonal efficiency
        // yes, maybe in the future adding a MIN here would be good..
        while (interval < intervalNumber(block.timestamp)) {

            // set interest rates for given interval
            if (interval == nextInterestInterval) {
                uint256 interestIndex = intervalToInterestIndex[interval];

                // set rate with current interval
                interestRate = interestRates[interestIndex].rate;

                // check if look ahead next index is greater than rates length, if so, go to max interval, otherwise next up
                nextInterestInterval = add(interestIndex, 1) >= interestRates.length
                    ? intervalNumber(block.timestamp)
                    : interestRates[add(interestIndex, 1)].interval;
            }

            // setup principle with whats on record at given interval
            if (interval == nextBalanceInterval) {
                // get current principle at current balance index, add with amount previously owed in interest
                principle = add(balanceRecords[tokenOwner][balanceIndex].balance, amountOwed);

                // increase balance index ahead now that we have the balance
                balanceIndex = add(balanceIndex, 1);

                // check if the new blance index exceeds, set next interval to limit or next interval on record
                nextBalanceInterval = balanceIndex >= balanceRecords[tokenOwner].length
                    ? intervalNumber(block.timestamp)
                    : balanceRecords[tokenOwner][balanceIndex].interval;
            }

            // apply compound interest to principle, subtract original principle, add to amount owed
            amountOwed = add(amountOwed, sub(wmul(principle,
                rpow(interestRate,
                    sub(min(nextBalanceInterval, nextInterestInterval), interval)) / 10 ** 9),
                        principle));

            // set interval to next nearest major balance or interest (or both) change
            interval = min(nextBalanceInterval, nextInterestInterval);
        }

        // return amount owed, adjusted balance index, and the last interval set / used
        return (amountOwed, (balanceIndex > 0 ? sub(balanceIndex, 1) : 0), interval);
    }

    // record users balance (max 2 writes additional per person per transfer)
    function recordBalance(address tokenOwner) internal {
        // todays current interval id
        uint256 todaysInterval = intervalNumber(block.timestamp);

        // last balance index
        uint256 latestBalanceIndex = balanceRecords[tokenOwner].length > 0
            ? sub(balanceRecords[tokenOwner].length, 1) : 0;

        // always update the current record (i.e. todays interval)
        // record balance record (if latest record is for today, add to it, otherwise add a record)
        if (balanceRecords[tokenOwner].length > 0
            && balanceRecords[tokenOwner][latestBalanceIndex].interval == todaysInterval) {
            balanceRecords[tokenOwner][latestBalanceIndex].balance = balanceOf(tokenOwner);
        } else {
            balanceRecords[tokenOwner].push(BalanceRecord({
                interval: todaysInterval,
                intervalOffset: todaysInterval,
                balance: balanceOf(tokenOwner)
            }));
        }

        // if no interval to interest mapping exists, map it (should always be at least a length of one)
        if (intervalToInterestIndex[todaysInterval] <= 0) {
            intervalToInterestIndex[todaysInterval] = sub(interestRates.length, 1); }
    }

    // record a new intrest rate change
    function recordInterestRate(uint256 rate) internal {
        // min number precision for rate.. might need to add a max here.
        assert(rate >= RAY);

        // todays current interval id
        uint256 todaysInterval = intervalNumber(block.timestamp);

        // last balance index
        uint256 latestRateIndex = interestRates.length > 0
            ? sub(interestRates.length, 1) : 0;

        // always update todays interval
        // record balance record (if latest record is for today, add to it, otherwise add a record)
        if (interestRates.length > 0
            && interestRates[latestRateIndex].interval == todaysInterval) {
            interestRates[latestRateIndex].rate = rate;
        } else {
            interestRates.push(InterestRate({
                interval: todaysInterval,
                rate: rate
            }));
        }

        // map the interval to interest index always
        intervalToInterestIndex[todaysInterval] = sub(interestRates.length, 1);
    }
}

/**
  * @title PausableCompoundInterestERC20
  * @author UnityCoin Team
  * @notice An implimentation of a mintable, pausable, burnable, compound interest based
  *       ERC20 token.
  *
  *       The token has a few *special* properties.
  *         - a special burner account (which can burn tokens in its account)
  *         - a special supply tracking pool account / mechanism
  *         - a special interest pool account which interest payments are drawn from
  *         - you cannot transfer from / to any pool (supply or interest)
  *         - you cannot claim interest on the interest pool account
  *         - by all accounts the interest and supply accounts dont really exist
  *           and are used for internal accounting purposes.
  *
  *       Minting / burning / pausing style is based roughly on DSToken from maker.
  *
  *       Whenever we burn, mint, change rates we update the supply pool,
  *       which intern updates the totalSupply return.
  *
  *       The TotalSupply of this token should be as follows:
  *       total supply = supply issued + total interest accued up to current interval
  *
  *       The special `burner` account can only burn tokens sent to it's account.
  *       You can think of it as a HOT burn account.
  *       The provider can ultimatly burn any account.
  */
contract PausableCompoundInterestERC20 is Pausable, BurnerAccount, InterestRateBased, ERC20Token {
    // Non EIP20 Standard Constants, Variables and Events
    event Mint(address indexed to, uint256 tokens);
    event Burn(uint256 tokens);
    event InterestRateChange(uint256 intervalDuration, uint256 intervalExpiry, uint256 indexed interestRateIndex);
    event InterestClaimed(address indexed tokenOwner, uint256 amountOwed);

    // the interest pool account address, that wont be included in total supply
    // hex generated with linux system entropy + dice + keys (private key thrown out)
    address public constant interestPool = address(0xd365131390302b58A61E265744288097Bd53532e);

    // this is the based supply pool address, which is used to calculate total supply with interest accured
    // hex generated with linux system entropy + dice + keys (private key thrown out)
    address public constant supplyPool = address(0x85c05851ef3175aeFBC74EcA16F174E22b5acF28);

    // is not a pool account
    modifier isNotPool(address tokenOwner) {
        assert(tokenOwner != supplyPool && tokenOwner != interestPool); _;
    }

    // total supply with amount owed
    function totalSupply() external view returns (uint256 supplyWithAccruedInterest) {
        (uint256 amountOwed,,) = interestOwed(supplyPool);

        return add(balanceOf(supplyPool), amountOwed);
    }

    // Dai/Maker style minting
    function mint(address to, uint256 amount) public isOwner pausable isNotPool(to) {
        // any time the supply pool changes, we need to update it's interest owed
        claimInterestOwed(supplyPool);

        balances[supplyPool] = add(balances[supplyPool], amount);
        balances[to] = add(balances[to], amount);

        recordBalance(supplyPool);
        recordBalance(to);

        emit Mint(to, amount);
    }

    // the burner can only burn tokens in the burn account
    function burn(address account) external isOwnerOrBurner pausable isNotPool(account) {
        // target burn address
        address target = msg.sender == burner ? burner : account;

        // any time the supply pool changes, we need to update it's interest owed
        claimInterestOwed(supplyPool);

        emit Burn(balances[target]);

        balances[supplyPool] = sub(balances[supplyPool], balances[target]);
        balances[target] = 0;

        // technially the burner account can claim interest, not that it should matter
        recordBalance(supplyPool);
        recordBalance(target);
    }

    // change interest rates
    function changeInterestRate(
        uint256 duration,
        uint256 maximum,
        uint256 interestRate,
        uint256 increasePool,
        uint256 decreasePool) public isOwner pausable {
        // claim up supply pool amount
        if (interestRates.length > 0) {
          claimInterestOwed(supplyPool); }

        // set duration and maximum
        changeDuration(duration);

        // set interval maximum
        intervalMaximum = maximum;

        // record interest rate..
        recordInterestRate(interestRate);

        // set interest pool, no balance needs to be recorded here as this is the interest pool
        balances[interestPool] = sub(add(balances[interestPool], increasePool),
          decreasePool);
    }

    // hard token set for interest pool
    function setInterestPool(uint256 tokens) external isOwner pausable {
        balances[interestPool] = tokens;
        // no need to record balance as this is the interest pool account..
    }

    // claim interest owed
    function claimInterestOwed(address tokenOwner) public pausable {
        // cant claim interest on the interest pool
        assert(tokenOwner != interestPool);

        // calculate interest balances and new record indexes
        (uint256 amountOwed, uint256 balanceIndex, uint256 interval) = interestOwed(tokenOwner);

        // set last balance index used (it's always one ahead so subtract one)
        lastClaimedBalanceIndex[tokenOwner] = balanceIndex;

        // set interval offset
        if (balanceRecords[tokenOwner].length > 0) {
          balanceRecords[tokenOwner][balanceIndex].intervalOffset = interval;
        }

        // increase the balance of the account, reduce interest pool
        if (tokenOwner != supplyPool) {
          balances[interestPool] = sub(balances[interestPool], amountOwed);
        }

        // set new token owner balance, record balance event
        balances[tokenOwner] = add(balances[tokenOwner], amountOwed);
        recordBalance(tokenOwner);

        // fire the interest claimed event
        emit InterestClaimed(tokenOwner, amountOwed);
    }

    function transferFrom(address from, address to, uint256 tokens) public pausable isNotPool(from) isNotPool(to) returns (bool success) {
        super.transferFrom(from, to, tokens);

        recordBalance(from);
        recordBalance(to);

        return true;
    }

    // Allow `spender` to withdraw from your account, multiple times, up to the `tokens` amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address spender, uint256 tokens) public pausable isNotPool(spender) returns (bool success) {
        return super.approve(spender, tokens);
    }
}

/**
  * @title SignableCompoundInterestERC20
  * @author UnityCoin Team
  * @notice A meta-transaction enabled version of the PausableCompoundInterestERC20
  *       this allows you to do a signed transfer or claim using EIP712 signature format.
  *
  *       We also impliment a constructor here.
  *
  *       A sender can essentially build EIP712 Claim to specific funds, whereby
  *       someone else (the `feeRecipient`) can recieve a pre-specified fee for
  *       sending the transaction on-behalf of the sender.
  *
  *       At anytime the sender can invalide the transfer / claim release hash of
  *       a claim / transfer they have signed.
  *
  *       Written claims also have nonce's to make them unique, and expiries
  *       to remove the change of holding attacks.
  */
contract SignableCompoundInterestERC20 is PausableCompoundInterestERC20 {
    // EIP712 Hashes and Seporators
    bytes32 constant public EIP712_DOMAIN_TYPEHASH = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)");
    bytes32 constant public SIGNEDTRANSFER_TYPEHASH = keccak256("SignedTransfer(address to,uint256 tokens,address feeRecipient,uint256 fee,uint256 expiry,bytes32 nonce)");
    bytes32 constant public SIGNEDINTERESTCLAIM_TYPEHASH = keccak256("SignedInterestClaim(address feeRecipient,uint256 fee,uint256 expiry,bytes32 nonce)");
    bytes32 public DOMAIN_SEPARATOR = keccak256(abi.encode(
        EIP712_DOMAIN_TYPEHASH, // EIP712
        keccak256("UnityCoin"), // app name
        keccak256("1"), // app version
        uint256(1), // chain id
        address(this), // verifying contract
        bytes32(0x111857f4a3edcb7462eabc03bfe733db1e3f6cdc2b7971ee739626c98268ae12) // salt
    ));

    // address(tokenOwner signer) => bytes32(releaseHash) => bool(was release hash used)
    mapping(address => mapping(bytes32 => bool)) public releaseHashes;

    event SignedTransfer(address indexed from, address indexed to, uint256 tokens, bytes32 releaseHash);
    event SignedInterestClaim(address indexed from, bytes32 releaseHash);

    // constructor for the entire token
    constructor(
        address tokenOwner, // main token controller
        address tokenBurner, // burner account

        uint256 initialSupply, // total supply amount

        uint256 interestIntervalStartTimestamp, // start time
        uint256 interestIntervalDurationSeconds, // interval duration
        uint256 interestIntervalMaximum, // interest expiry
        uint256 interestPoolSize, // total interest pool size
        uint256 interestRate) public {
        // setup the burner account
        burner = tokenBurner;

        // setup the interest mechnics
        intervalStartTimestamp = interestIntervalStartTimestamp;

        // set duration
        intervalDuration = interestIntervalDurationSeconds;

        // set interest rates
        changeInterestRate(interestIntervalDurationSeconds,
            interestIntervalMaximum,
            interestRate, interestPoolSize, 0);

        // mint to the token owner the initial supply
        mint(tokenOwner, initialSupply);

        // set the provider
        owner = tokenOwner;
    }

    // allow someone else to pay the gas fee for this token, by taking a fee within the token itself.
    function signedTransfer(address to,
        uint256 tokens,
        address feeRecipient,
        uint256 fee,
        uint256 expiry,
        bytes32 nonce,
        uint8 v, bytes32 r, bytes32 s) external returns (bool success) {
        bytes32 releaseHash = keccak256(abi.encodePacked(
           "\x19\x01",
           DOMAIN_SEPARATOR,
           keccak256(abi.encode(SIGNEDTRANSFER_TYPEHASH, to, tokens, feeRecipient, fee, expiry, nonce))
        ));
        address from = ecrecover(releaseHash, v, r, s);

        // check expiry, release hash and balances
        assert(block.timestamp < expiry);
        assert(releaseHashes[from][releaseHash] == false);

        // waste out release hash
        releaseHashes[from][releaseHash] = true;

        // allow funds to be transfered.
        approvals[from][msg.sender] = add(tokens, fee);

        // transfer funds
        transferFrom(from, to, tokens);
        transferFrom(from, feeRecipient, fee);

        emit SignedTransfer(from, to, tokens, releaseHash);

        return true;
    }

    // allow someone else to fire the claim interest owed method, and get paid a fee in the token to do so
    function signedInterestClaim(
        address feeRecipient,
        uint256 fee,
        uint256 expiry,
        bytes32 nonce,
        uint8 v, bytes32 r, bytes32 s) external returns (bool success) {
        bytes32 releaseHash = keccak256(abi.encodePacked(
           "\x19\x01",
           DOMAIN_SEPARATOR,
           keccak256(abi.encode(SIGNEDINTERESTCLAIM_TYPEHASH, feeRecipient, fee, expiry, nonce))
        ));
        address from = ecrecover(releaseHash, v, r, s);

        // check expiry, release hash and balances
        assert(block.timestamp < expiry);
        assert(releaseHashes[from][releaseHash] == false);

        // waste out release hash
        releaseHashes[from][releaseHash] = true;

        // claim interest owed
        claimInterestOwed(from);

        // allow funds to be transfered.
        approvals[from][msg.sender] = fee;

        // transfer funds
        transferFrom(from, feeRecipient, fee);

        emit SignedInterestClaim(from, releaseHash);

        return true;
    }

    // this allows a token user to invalidate approved release hashes at anytime..
    function invalidateHash(bytes32 releaseHash) external pausable {
      releaseHashes[msg.sender][releaseHash] = true;
    }
}