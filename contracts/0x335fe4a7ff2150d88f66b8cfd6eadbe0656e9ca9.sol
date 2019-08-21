pragma solidity ^0.4.19;

/* Interface for ERC20 Tokens */
contract Token {
    bytes32 public standard;
    bytes32 public name;
    bytes32 public symbol;
    uint256 public totalSupply;
    uint8 public decimals;
    bool public allowTransactions;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    function transfer(address _to, uint256 _value) returns (bool success);
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
}

// The DMEX base Contract
contract Exchange {
    function assert(bool assertion) {
        if (!assertion) throw;
    }

    // Safe Multiply Function - prevents integer overflow 
    function safeMul(uint a, uint b) returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    // Safe Subtraction Function - prevents integer overflow 
    function safeSub(uint a, uint b) returns (uint) {
        assert(b <= a);
        return a - b;
    }

    // Safe Addition Function - prevents integer overflow 
    function safeAdd(uint a, uint b) returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return c;
    }

    address public owner; // holds the address of the contract owner
    mapping (address => bool) public admins; // mapping of admin addresses
    mapping (address => bool) public futuresContracts; // mapping of connected futures contracts
    mapping (address => uint256) public futuresContractsAddedBlock; // mapping of connected futures contracts and connection block numbers
    event SetFuturesContract(address futuresContract, bool isFuturesContract);

    // Event fired when the owner of the contract is changed
    event SetOwner(address indexed previousOwner, address indexed newOwner);

    // Allows only the owner of the contract to execute the function
    modifier onlyOwner {
        assert(msg.sender == owner);
        _;
    }

    // Changes the owner of the contract
    function setOwner(address newOwner) onlyOwner {
        SetOwner(owner, newOwner);
        owner = newOwner;
    }

    // Owner getter function
    function getOwner() returns (address out) {
        return owner;
    }

    // Adds or disables an admin account
    function setAdmin(address admin, bool isAdmin) onlyOwner {
        admins[admin] = isAdmin;
    }


    // Adds or disables a futuresContract address
    function setFuturesContract(address futuresContract, bool isFuturesContract) onlyOwner {
        futuresContracts[futuresContract] = isFuturesContract;
        if (fistFuturesContract == address(0))
        {
            fistFuturesContract = futuresContract;
        }
        futuresContractsAddedBlock[futuresContract] = block.number;
        emit SetFuturesContract(futuresContract, isFuturesContract);
    }

    // Allows for admins only to call the function
    modifier onlyAdmin {
        if (msg.sender != owner && !admins[msg.sender]) throw;
        _;
    }

    // Allows for futures contracts only to call the function
    modifier onlyFuturesContract {
        if (!futuresContracts[msg.sender]) throw;
        _;
    }

    function() external {
        throw;
    }

    //mapping (address => mapping (address => uint256)) public tokens; // mapping of token addresses to mapping of balances  // tokens[token][user]
    //mapping (address => mapping (address => uint256)) public reserve; // mapping of token addresses to mapping of reserved balances  // reserve[token][user]
    mapping (address => mapping (address => uint256)) public balances; // mapping of token addresses to mapping of balances and reserve (bitwise compressed) // balances[token][user]

    mapping (address => uint256) public lastActiveTransaction; // mapping of user addresses to last transaction block
    mapping (bytes32 => uint256) public orderFills; // mapping of orders to filled qunatity
    
    mapping (address => mapping (address => bool)) public userAllowedFuturesContracts; // mapping of allowed futures smart contracts per user
    mapping (address => uint256) public userFirstDeposits; // mapping of user addresses and block number of first deposit

    address public feeAccount; // the account that receives the trading fees
    address public EtmTokenAddress; // the address of the EtherMium token
    address public fistFuturesContract; // 0x if there are no futures contracts set yet

    uint256 public inactivityReleasePeriod; // period in blocks before a user can use the withdraw() function
    mapping (bytes32 => bool) public withdrawn; // mapping of withdraw requests, makes sure the same withdrawal is not executed twice
    uint256 public makerFee; // maker fee in percent expressed as a fraction of 1 ether (0.1 ETH = 10%)
    uint256 public takerFee; // taker fee in percent expressed as a fraction of 1 ether (0.1 ETH = 10%)

    enum Errors {
        INVLID_PRICE,           // Order prices don't match
        INVLID_SIGNATURE,       // Signature is invalid
        TOKENS_DONT_MATCH,      // Maker/taker tokens don't match
        ORDER_ALREADY_FILLED,   // Order was already filled
        GAS_TOO_HIGH            // Too high gas fee
    }

    // Trade event fired when a trade is executed
    event Trade(
        address takerTokenBuy, uint256 takerAmountBuy,
        address takerTokenSell, uint256 takerAmountSell,
        address maker, address indexed taker,
        uint256 makerFee, uint256 takerFee,
        uint256 makerAmountTaken, uint256 takerAmountTaken,
        bytes32 indexed makerOrderHash, bytes32 indexed takerOrderHash
    );

    // Deposit event fired when a deposit took place
    event Deposit(address indexed token, address indexed user, uint256 amount, uint256 balance);

    // Withdraw event fired when a withdrawal was executed
    event Withdraw(address indexed token, address indexed user, uint256 amount, uint256 balance, uint256 withdrawFee);
    event WithdrawTo(address indexed token, address indexed to, address indexed from, uint256 amount, uint256 balance, uint256 withdrawFee);

    // Fee change event
    event FeeChange(uint256 indexed makerFee, uint256 indexed takerFee);

    // Allow futuresContract 
    event AllowFuturesContract(address futuresContract, address user);


    // Log event, logs errors in contract execution (used for debugging)
    event LogError(uint8 indexed errorId, bytes32 indexed makerOrderHash, bytes32 indexed takerOrderHash);
    event LogUint(uint8 id, uint256 value);
    event LogBool(uint8 id, bool value);
    event LogAddress(uint8 id, address value);

    // Change inactivity release period event
    event InactivityReleasePeriodChange(uint256 value);

    // Order cancelation event
    event CancelOrder(
        bytes32 indexed cancelHash,
        bytes32 indexed orderHash,
        address indexed user,
        address tokenSell,
        uint256 amountSell,
        uint256 cancelFee
    );

    // Sets the inactivity period before a user can withdraw funds manually
    function setInactivityReleasePeriod(uint256 expiry) onlyOwner returns (bool success) {
        if (expiry > 1000000) throw;
        inactivityReleasePeriod = expiry;

        emit InactivityReleasePeriodChange(expiry);
        return true;
    }

    // Constructor function, initializes the contract and sets the core variables
    function Exchange(address feeAccount_, uint256 makerFee_, uint256 takerFee_, uint256 inactivityReleasePeriod_) {
        owner = msg.sender;
        feeAccount = feeAccount_;
        inactivityReleasePeriod = inactivityReleasePeriod_;
        makerFee = makerFee_;
        takerFee = takerFee_;
    }

    // Changes the fees
    function setFees(uint256 makerFee_, uint256 takerFee_) onlyOwner {
        require(makerFee_ < 10 finney && takerFee_ < 10 finney); // The fees cannot be set higher then 1%
        makerFee = makerFee_;
        takerFee = takerFee_;

        emit FeeChange(makerFee, takerFee);
    }

    



    function updateBalanceAndReserve (address token, address user, uint256 balance, uint256 reserve) private
    {
        uint256 character = uint256(balance);
        character |= reserve<<128;

        balances[token][user] = character;
    }

    function updateBalance (address token, address user, uint256 balance) private returns (bool)
    {
        uint256 character = uint256(balance);
        character |= getReserve(token, user)<<128;

        balances[token][user] = character;
        return true;
    }

    function updateReserve (address token, address user, uint256 reserve) private
    {
        uint256 character = uint256(balanceOf(token, user));
        character |= reserve<<128;

        balances[token][user] = character;
    }

    function decodeBalanceAndReserve (address token, address user) returns (uint256[2])
    {
        uint256 character = balances[token][user];
        uint256 balance = uint256(uint128(character));
        uint256 reserve = uint256(uint128(character>>128));

        return [balance, reserve];
    }

    function futuresContractAllowed (address futuresContract, address user) returns (bool)
    {
        if (fistFuturesContract == futuresContract) return true;
        if (userAllowedFuturesContracts[user][futuresContract] == true) return true;
        if (futuresContractsAddedBlock[futuresContract] < userFirstDeposits[user]) return true;

        return false;
    }

    // Returns the balance of a specific token for a specific user
    function balanceOf(address token, address user) view returns (uint256) {
        //return tokens[token][user];
        return decodeBalanceAndReserve(token, user)[0];
    }

    // Returns the reserved amound of token for user
    function getReserve(address token, address user) public view returns (uint256) { 
        //return reserve[token][user];  
        return decodeBalanceAndReserve(token, user)[1];
    }

    // Sets reserved amount for specific token and user (can only be called by futures contract)
    function setReserve(address token, address user, uint256 amount) onlyFuturesContract returns (bool success) { 
        if (!futuresContractAllowed(msg.sender, user)) throw;
        if (availableBalanceOf(token, user) < amount) throw; 
        updateReserve(token, user, amount);
        return true; 
    }

    // Updates user balance (only can be used by futures contract)
    function setBalance(address token, address user, uint256 amount) onlyFuturesContract returns (bool success)     {
        if (!futuresContractAllowed(msg.sender, user)) throw;
        updateBalance(token, user, amount);
        return true;
        
    }

    function subBalanceAddReserve(address token, address user, uint256 subBalance, uint256 addReserve) onlyFuturesContract returns (bool)
    {
        if (!futuresContractAllowed(msg.sender, user)) throw;
        updateBalanceAndReserve(token, user, safeSub(balanceOf(token, user), subBalance), safeAdd(getReserve(token, user), addReserve));
    }

    function addBalanceSubReserve(address token, address user, uint256 addBalance, uint256 subReserve) onlyFuturesContract returns (bool)
    {
        if (!futuresContractAllowed(msg.sender, user)) throw;
        updateBalanceAndReserve(token, user, safeAdd(balanceOf(token, user), addBalance), safeSub(getReserve(token, user), subReserve));
    }

    function subBalanceSubReserve(address token, address user, uint256 subBalance, uint256 subReserve) onlyFuturesContract returns (bool)
    {
        if (!futuresContractAllowed(msg.sender, user)) throw;
        updateBalanceAndReserve(token, user, safeSub(balanceOf(token, user), subBalance), safeSub(getReserve(token, user), subReserve));
    }

    // Returns the available balance of a specific token for a specific user
    function availableBalanceOf(address token, address user) view returns (uint256) {
        return safeSub(balanceOf(token, user), getReserve(token, user));
    }

    // Returns the inactivity release perios
    function getInactivityReleasePeriod() view returns (uint256)
    {
        return inactivityReleasePeriod;
    }

    // Increases the user balance
    function addBalance(address token, address user, uint256 amount) private
    {
        updateBalance(token, user, safeAdd(balanceOf(token, user), amount));
    }

    // Decreases user balance
    function subBalance(address token, address user, uint256 amount) private
    {
        if (availableBalanceOf(token, user) < amount) throw; 
        updateBalance(token, user, safeSub(balanceOf(token, user), amount));
    }


    // Deposit ETH to contract
    function deposit() payable {
        //tokens[address(0)][msg.sender] = safeAdd(tokens[address(0)][msg.sender], msg.value); // adds the deposited amount to user balance
        addBalance(address(0), msg.sender, msg.value); // adds the deposited amount to user balance
        if (userFirstDeposits[msg.sender] == 0) userFirstDeposits[msg.sender] = block.number;
        lastActiveTransaction[msg.sender] = block.number; // sets the last activity block for the user
        emit Deposit(address(0), msg.sender, msg.value, balanceOf(address(0), msg.sender)); // fires the deposit event
    }

    // Deposit token to contract
    function depositToken(address token, uint128 amount) {
        //tokens[token][msg.sender] = safeAdd(tokens[token][msg.sender], amount); // adds the deposited amount to user balance
        //if (amount != uint128(amount) || safeAdd(amount, balanceOf(token, msg.sender)) != uint128(amount)) throw;
        addBalance(token, msg.sender, amount); // adds the deposited amount to user balance

        if (userFirstDeposits[msg.sender] == 0) userFirstDeposits[msg.sender] = block.number;
        lastActiveTransaction[msg.sender] = block.number; // sets the last activity block for the user
        if (!Token(token).transferFrom(msg.sender, this, amount)) throw; // attempts to transfer the token to this contract, if fails throws an error
        emit Deposit(token, msg.sender, amount, balanceOf(token, msg.sender)); // fires the deposit event
    }

    function withdraw(address token, uint256 amount) returns (bool success) {
        //if (safeSub(block.number, lastActiveTransaction[msg.sender]) < inactivityReleasePeriod) throw; // checks if the inactivity period has passed
        //if (tokens[token][msg.sender] < amount) throw; // checks that user has enough balance
        if (availableBalanceOf(token, msg.sender) < amount) throw;

        //tokens[token][msg.sender] = safeSub(tokens[token][msg.sender], amount); 
        subBalance(token, msg.sender, amount); // subtracts the withdrawed amount from user balance

        if (token == address(0)) { // checks if withdrawal is a token or ETH, ETH has address 0x00000... 
            if (!msg.sender.send(amount)) throw; // send ETH
        } else {
            if (!Token(token).transfer(msg.sender, amount)) throw; // Send token
        }
        emit Withdraw(token, msg.sender, amount, balanceOf(token, msg.sender), 0); // fires the Withdraw event
    }

    function userAllowFuturesContract(address futuresContract)
    {
        if (!futuresContracts[futuresContract]) throw;
        userAllowedFuturesContracts[msg.sender][futuresContract] = true;

        emit AllowFuturesContract(futuresContract, msg.sender);
    }

    function allowFuturesContractForUser(address futuresContract, address user, uint8 v, bytes32 r, bytes32 s) onlyAdmin
    {
        if (!futuresContracts[futuresContract]) throw;
        bytes32 hash = keccak256(this, futuresContract); 
        if (ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash), v, r, s) != user) throw; // checks that the provided signature is valid
        userAllowedFuturesContracts[user][futuresContract] = true;

        emit AllowFuturesContract(futuresContract, user);
    }

    function allowFuturesContractForUserByFuturesContract(address user, uint8 v, bytes32 r, bytes32 s) onlyFuturesContract returns (bool)
    {
        if (!futuresContracts[msg.sender]) return false;
        bytes32 hash = keccak256(this, msg.sender); 
        if (ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash), v, r, s) != user) return false; // checks that the provided signature is valid
        userAllowedFuturesContracts[user][msg.sender] = true;

        emit AllowFuturesContract(msg.sender, user);

        return true;
    }

    

    // Withdrawal function used by the server to execute withdrawals
    function adminWithdraw(
        address token, // the address of the token to be withdrawn
        uint256 amount, // the amount to be withdrawn
        address user, // address of the user
        uint256 nonce, // nonce to make the request unique
        uint8 v, // part of user signature
        bytes32 r, // part of user signature
        bytes32 s, // part of user signature
        uint256 feeWithdrawal // the transaction gas fee that will be deducted from the user balance
    ) onlyAdmin returns (bool success) {
        bytes32 hash = keccak256(this, token, amount, user, nonce); // creates the hash for the withdrawal request
        if (withdrawn[hash]) throw; // checks if the withdrawal was already executed, if true, throws an error
        withdrawn[hash] = true; // sets the withdrawal as executed
        if (ecrecover(keccak256("\x19Ethereum Signed Message:\n32", hash), v, r, s) != user) throw; // checks that the provided signature is valid
        if (feeWithdrawal > 50 finney) feeWithdrawal = 50 finney; // checks that the gas fee is not higher than 0.05 ETH


        //if (tokens[token][user] < amount) throw; // checks that user has enough balance
        if (availableBalanceOf(token, user) < amount) throw; // checks that user has enough balance

        //tokens[token][user] = safeSub(tokens[token][user], amount); // subtracts the withdrawal amount from the user balance
        subBalance(token, user, amount); // subtracts the withdrawal amount from the user balance

        //tokens[address(0)][user] = safeSub(tokens[address(0x0)][user], feeWithdrawal); // subtracts the gas fee from the user ETH balance
        subBalance(address(0), user, feeWithdrawal); // subtracts the gas fee from the user ETH balance

        //tokens[address(0)][feeAccount] = safeAdd(tokens[address(0)][feeAccount], feeWithdrawal); // moves the gas fee to the feeAccount
        addBalance(address(0), feeAccount, feeWithdrawal); // moves the gas fee to the feeAccount

        if (token == address(0)) { // checks if the withdrawal is in ETH or Tokens
            if (!user.send(amount)) throw; // sends ETH
        } else {
            if (!Token(token).transfer(user, amount)) throw; // sends tokens
        }
        lastActiveTransaction[user] = block.number; // sets last user activity block
        emit Withdraw(token, user, amount, balanceOf(token, user), feeWithdrawal); // fires the withdraw event
    }

    function batchAdminWithdraw(
        address[] token, // the address of the token to be withdrawn
        uint256[] amount, // the amount to be withdrawn
        address[] user, // address of the user
        uint256[] nonce, // nonce to make the request unique
        uint8[] v, // part of user signature
        bytes32[] r, // part of user signature
        bytes32[] s, // part of user signature
        uint256[] feeWithdrawal // the transaction gas fee that will be deducted from the user balance
    ) onlyAdmin 
    {
        for (uint i = 0; i < amount.length; i++) {
            adminWithdraw(
                token[i],
                amount[i],
                user[i],
                nonce[i],
                v[i],
                r[i],
                s[i],
                feeWithdrawal[i]
            );
        }
    }

 

    function getMakerTakerBalances(address token, address maker, address taker) view returns (uint256[4])
    {
        return [
            balanceOf(token, maker),
            balanceOf(token, taker),
            getReserve(token, maker),
            getReserve(token, taker)
        ];
    }

    

    // Structure that holds order values, used inside the trade() function
    struct OrderPair {
        uint256 makerAmountBuy;     // amount being bought by the maker
        uint256 makerAmountSell;    // amount being sold by the maker
        uint256 makerNonce;         // maker order nonce, makes the order unique
        uint256 takerAmountBuy;     // amount being bought by the taker
        uint256 takerAmountSell;    // amount being sold by the taker
        uint256 takerNonce;         // taker order nonce
        uint256 takerGasFee;        // taker gas fee, taker pays the gas
        uint256 takerIsBuying;      // true/false taker is the buyer

        address makerTokenBuy;      // token bought by the maker
        address makerTokenSell;     // token sold by the maker
        address maker;              // address of the maker
        address takerTokenBuy;      // token bought by the taker
        address takerTokenSell;     // token sold by the taker
        address taker;              // address of the taker

        bytes32 makerOrderHash;     // hash of the maker order
        bytes32 takerOrderHash;     // has of the taker order
    }

    // Structure that holds trade values, used inside the trade() function
    struct TradeValues {
        uint256 qty;                // amount to be trade
        uint256 invQty;             // amount to be traded in the opposite token
        uint256 makerAmountTaken;   // final amount taken by the maker
        uint256 takerAmountTaken;   // final amount taken by the taker
    }

    // Trades balances between user accounts
    function trade(
        uint8[2] v,
        bytes32[4] rs,
        uint256[8] tradeValues,
        address[6] tradeAddresses
    ) onlyAdmin returns (uint filledTakerTokenAmount)
    {

        /* tradeValues
          [0] makerAmountBuy
          [1] makerAmountSell
          [2] makerNonce
          [3] takerAmountBuy
          [4] takerAmountSell
          [5] takerNonce
          [6] takerGasFee
          [7] takerIsBuying

          tradeAddresses
          [0] makerTokenBuy
          [1] makerTokenSell
          [2] maker
          [3] takerTokenBuy
          [4] takerTokenSell
          [5] taker
        */

        OrderPair memory t  = OrderPair({
            makerAmountBuy  : tradeValues[0],
            makerAmountSell : tradeValues[1],
            makerNonce      : tradeValues[2],
            takerAmountBuy  : tradeValues[3],
            takerAmountSell : tradeValues[4],
            takerNonce      : tradeValues[5],
            takerGasFee     : tradeValues[6],
            takerIsBuying   : tradeValues[7],

            makerTokenBuy   : tradeAddresses[0],
            makerTokenSell  : tradeAddresses[1],
            maker           : tradeAddresses[2],
            takerTokenBuy   : tradeAddresses[3],
            takerTokenSell  : tradeAddresses[4],
            taker           : tradeAddresses[5],

            //                                tokenBuy           amountBuy       tokenSell          amountSell      nonce           user
            makerOrderHash  : keccak256(this, tradeAddresses[0], tradeValues[0], tradeAddresses[1], tradeValues[1], tradeValues[2], tradeAddresses[2]),
            takerOrderHash  : keccak256(this, tradeAddresses[3], tradeValues[3], tradeAddresses[4], tradeValues[4], tradeValues[5], tradeAddresses[5])
        });

        // Checks the signature for the maker order
        if (ecrecover(keccak256("\x19Ethereum Signed Message:\n32", t.makerOrderHash), v[0], rs[0], rs[1]) != t.maker)
        {
            emit LogError(uint8(Errors.INVLID_SIGNATURE), t.makerOrderHash, t.takerOrderHash);
            return 0;
        }
       
       // Checks the signature for the taker order
        if (ecrecover(keccak256("\x19Ethereum Signed Message:\n32", t.takerOrderHash), v[1], rs[2], rs[3]) != t.taker)
        {
            emit LogError(uint8(Errors.INVLID_SIGNATURE), t.makerOrderHash, t.takerOrderHash);
            return 0;
        }


        // Checks that orders trade the right tokens
        if (t.makerTokenBuy != t.takerTokenSell || t.makerTokenSell != t.takerTokenBuy)
        {
            emit LogError(uint8(Errors.TOKENS_DONT_MATCH), t.makerOrderHash, t.takerOrderHash);
            return 0;
        } // tokens don't match


        // Cheks that gas fee is not higher than 10%
        if (t.takerGasFee > 100 finney)
        {
            emit LogError(uint8(Errors.GAS_TOO_HIGH), t.makerOrderHash, t.takerOrderHash);
            return 0;
        } // takerGasFee too high


        // Checks that the prices match.
        // Taker always pays the maker price. This part checks that the taker price is as good or better than the maker price
        if (!(
        (t.takerIsBuying == 0 && safeMul(t.makerAmountSell, 1 ether) / t.makerAmountBuy >= safeMul(t.takerAmountBuy, 1 ether) / t.takerAmountSell)
        ||
        (t.takerIsBuying > 0 && safeMul(t.makerAmountBuy, 1 ether) / t.makerAmountSell <= safeMul(t.takerAmountSell, 1 ether) / t.takerAmountBuy)
        ))
        {
            emit LogError(uint8(Errors.INVLID_PRICE), t.makerOrderHash, t.takerOrderHash);
            return 0; // prices don't match
        }

        // Initializing trade values structure
        TradeValues memory tv = TradeValues({
            qty                 : 0,
            invQty              : 0,
            makerAmountTaken    : 0,
            takerAmountTaken    : 0
        });
        
        // maker buy, taker sell
        if (t.takerIsBuying == 0)
        {
            // traded quantity is the smallest quantity between the maker and the taker, takes into account amounts already filled on the orders
            tv.qty = min(safeSub(t.makerAmountBuy, orderFills[t.makerOrderHash]), safeSub(t.takerAmountSell, safeMul(orderFills[t.takerOrderHash], t.takerAmountSell) / t.takerAmountBuy));
            if (tv.qty == 0)
            {
                // order was already filled
                emit LogError(uint8(Errors.ORDER_ALREADY_FILLED), t.makerOrderHash, t.takerOrderHash);
                return 0;
            }

            // the traded quantity in opposite token terms
            tv.invQty = safeMul(tv.qty, t.makerAmountSell) / t.makerAmountBuy;

           
            // take fee from Token balance
            tv.makerAmountTaken                         = safeSub(tv.qty, safeMul(tv.qty, makerFee) / (1 ether));                                       // net amount received by maker, excludes maker fee
            //tokens[t.makerTokenBuy][feeAccount]         = safeAdd(tokens[t.makerTokenBuy][feeAccount],      safeMul(tv.qty, makerFee) / (1 ether));     // add maker fee to feeAccount
            addBalance(t.makerTokenBuy, feeAccount, safeMul(tv.qty, makerFee) / (1 ether)); // add maker fee to feeAccount
        

        
            // take fee from Token balance
            tv.takerAmountTaken                         = safeSub(safeSub(tv.invQty, safeMul(tv.invQty, takerFee) / (1 ether)), safeMul(tv.invQty, t.takerGasFee) / (1 ether));                             // amount taken from taker minus taker fee
            //tokens[t.takerTokenBuy][feeAccount]         = safeAdd(tokens[t.takerTokenBuy][feeAccount], safeAdd(safeMul(tv.invQty, takerFee) / (1 ether), safeMul(tv.invQty, t.takerGasFee) / (1 ether)));   // add taker fee to feeAccount
            addBalance(t.takerTokenBuy, feeAccount, safeAdd(safeMul(tv.invQty, takerFee) / (1 ether), safeMul(tv.invQty, t.takerGasFee) / (1 ether))); // add taker fee to feeAccount


            //tokens[t.makerTokenSell][t.maker]           = safeSub(tokens[t.makerTokenSell][t.maker],           tv.invQty);                              // subtract sold token amount from maker balance
            subBalance(t.makerTokenSell, t.maker, tv.invQty); // subtract sold token amount from maker balance

            //tokens[t.makerTokenBuy][t.maker]            = safeAdd(tokens[t.makerTokenBuy][t.maker],            tv.makerAmountTaken);                    // add bought token amount to maker
            addBalance(t.makerTokenBuy, t.maker, tv.makerAmountTaken); // add bought token amount to maker

            //tokens[t.makerTokenBuy][tv.makerReferrer]   = safeAdd(tokens[t.makerTokenBuy][tv.makerReferrer],   safeMul(tv.qty,    makerAffiliateFee) / (1 ether)); // add affiliate commission to maker affiliate balance


            //tokens[t.takerTokenSell][t.taker]           = safeSub(tokens[t.takerTokenSell][t.taker],           tv.qty);                                 // subtract the sold token amount from taker
            subBalance(t.takerTokenSell, t.taker, tv.qty); // subtract the sold token amount from taker

            //tokens[t.takerTokenBuy][t.taker]            = safeAdd(tokens[t.takerTokenBuy][t.taker],            tv.takerAmountTaken);                    // amount received by taker, excludes taker fee
            //tokens[t.takerTokenBuy][tv.takerReferrer]   = safeAdd(tokens[t.takerTokenBuy][tv.takerReferrer],   safeMul(tv.invQty, takerAffiliateFee) / (1 ether)); // add affiliate commission to taker affiliate balance
            addBalance(t.takerTokenBuy, t.taker, tv.takerAmountTaken); // amount received by taker, excludes taker fee
        
            orderFills[t.makerOrderHash]                = safeAdd(orderFills[t.makerOrderHash], tv.qty);                                                // increase the maker order filled amount
            orderFills[t.takerOrderHash]                = safeAdd(orderFills[t.takerOrderHash], safeMul(tv.qty, t.takerAmountBuy) / t.takerAmountSell); // increase the taker order filled amount
            lastActiveTransaction[t.maker]              = block.number; // set last activity block number for maker
            lastActiveTransaction[t.taker]              = block.number; // set last activity block number for taker

            // fire Trade event
            emit Trade(
                t.takerTokenBuy, tv.qty,
                t.takerTokenSell, tv.invQty,
                t.maker, t.taker,
                makerFee, takerFee,
                tv.makerAmountTaken , tv.takerAmountTaken,
                t.makerOrderHash, t.takerOrderHash
            );
            return tv.qty;
        }
        // maker sell, taker buy
        else
        {
            // traded quantity is the smallest quantity between the maker and the taker, takes into account amounts already filled on the orders
            tv.qty = min(safeSub(t.makerAmountSell,  safeMul(orderFills[t.makerOrderHash], t.makerAmountSell) / t.makerAmountBuy), safeSub(t.takerAmountBuy, orderFills[t.takerOrderHash]));
            if (tv.qty == 0)
            {
                // order was already filled
                emit LogError(uint8(Errors.ORDER_ALREADY_FILLED), t.makerOrderHash, t.takerOrderHash);
                return 0;
            }            

            // the traded quantity in opposite token terms
            tv.invQty = safeMul(tv.qty, t.makerAmountBuy) / t.makerAmountSell;
            
           
            // take fee from ETH balance
            tv.makerAmountTaken                         = safeSub(tv.invQty, safeMul(tv.invQty, makerFee) / (1 ether));                                 // net amount received by maker, excludes maker fee
            //tokens[t.makerTokenBuy][feeAccount]         = safeAdd(tokens[t.makerTokenBuy][feeAccount],      safeMul(tv.invQty, makerFee) / (1 ether));  // add maker fee to feeAccount
            addBalance(t.makerTokenBuy, feeAccount, safeMul(tv.invQty, makerFee) / (1 ether)); // add maker fee to feeAccount
     

            // process fees for taker
            
            // take fee from ETH balance
            tv.takerAmountTaken                         = safeSub(safeSub(tv.qty, safeMul(tv.qty, takerFee) / (1 ether)), safeMul(tv.qty, t.takerGasFee) / (1 ether));                                  // amount taken from taker minus taker fee
            //tokens[t.takerTokenBuy][feeAccount]         = safeAdd(tokens[t.takerTokenBuy][feeAccount], safeAdd(safeMul(tv.qty, takerFee) / (1 ether), safeMul(tv.qty, t.takerGasFee) / (1 ether)));     // add taker fee to feeAccount
            addBalance(t.takerTokenBuy, feeAccount, safeAdd(safeMul(tv.qty, takerFee) / (1 ether), safeMul(tv.qty, t.takerGasFee) / (1 ether))); // add taker fee to feeAccount



            //tokens[t.makerTokenSell][t.maker]           = safeSub(tokens[t.makerTokenSell][t.maker],           tv.qty); // subtract sold token amount from maker balance
            subBalance(t.makerTokenSell, t.maker, tv.qty); // subtract sold token amount from maker balance

            //tv.makerAmountTaken                         = safeSub(tv.invQty, safeMul(tv.invQty, makerFee) / (1 ether));   // net amount received by maker, excludes maker fee
            //tokens[t.makerTokenBuy][t.maker]            = safeAdd(tokens[t.makerTokenBuy][t.maker],            tv.makerAmountTaken); // add bought token amount to maker
            addBalance(t.makerTokenBuy, t.maker, tv.makerAmountTaken); // add bought token amount to maker

            //tokens[t.makerTokenBuy][tv.makerReferrer]   = safeAdd(tokens[t.makerTokenBuy][tv.makerReferrer],   safeMul(tv.invQty, makerAffiliateFee) / (1 ether)); // add affiliate commission to maker affiliate balance

            //tokens[t.takerTokenSell][t.taker]           = safeSub(tokens[t.takerTokenSell][t.taker],           tv.invQty); // subtract the sold token amount from taker
            subBalance(t.takerTokenSell, t.taker, tv.invQty);

            //tv.takerAmountTaken                         = safeSub(safeSub(tv.qty,    safeMul(tv.qty, takerFee) / (1 ether)), safeMul(tv.qty, t.takerGasFee) / (1 ether)); // amount taken from taker minus taker fee
            //tokens[t.takerTokenBuy][t.taker]            = safeAdd(tokens[t.takerTokenBuy][t.taker],            tv.takerAmountTaken); // amount received by taker, excludes taker fee
            addBalance(t.takerTokenBuy, t.taker, tv.takerAmountTaken); // amount received by taker, excludes taker fee

            //tokens[t.takerTokenBuy][tv.takerReferrer]   = safeAdd(tokens[t.takerTokenBuy][tv.takerReferrer],   safeMul(tv.qty,    takerAffiliateFee) / (1 ether)); // add affiliate commission to taker affiliate balance

            //tokens[t.makerTokenBuy][feeAccount]     = safeAdd(tokens[t.makerTokenBuy][feeAccount],      safeMul(tv.invQty, safeSub(makerFee, makerAffiliateFee)) / (1 ether)); // add maker fee excluding affiliate commission to feeAccount
            //tokens[t.takerTokenBuy][feeAccount]     = safeAdd(tokens[t.takerTokenBuy][feeAccount],      safeAdd(safeMul(tv.qty,    safeSub(takerFee, takerAffiliateFee)) / (1 ether), safeMul(tv.qty, t.takerGasFee) / (1 ether))); // add taker fee excluding affiliate commission to feeAccount

            orderFills[t.makerOrderHash]            = safeAdd(orderFills[t.makerOrderHash], tv.invQty); // increase the maker order filled amount
            orderFills[t.takerOrderHash]            = safeAdd(orderFills[t.takerOrderHash], tv.qty);  // increase the taker order filled amount
            lastActiveTransaction[t.maker]          = block.number; // set last activity block number for maker
            lastActiveTransaction[t.taker]          = block.number; // set last activity block number for taker

            // fire Trade event
            emit Trade(
                t.takerTokenBuy, tv.qty,
                t.takerTokenSell, tv.invQty,
                t.maker, t.taker,
                makerFee, takerFee,
                tv.makerAmountTaken , tv.takerAmountTaken,
                t.makerOrderHash, t.takerOrderHash
            );
            return tv.qty;
        }
    }


    // Executes multiple trades in one transaction, saves gas fees
    function batchOrderTrade(
        uint8[2][] v,
        bytes32[4][] rs,
        uint256[8][] tradeValues,
        address[6][] tradeAddresses
    ) onlyAdmin
    {
        for (uint i = 0; i < tradeAddresses.length; i++) {
            trade(
                v[i],
                rs[i],
                tradeValues[i],
                tradeAddresses[i]
            );
        }
    }

    // Cancels order by setting amount filled to toal order amount
    function cancelOrder(
		/*
		[0] orderV
		[1] cancelV
		*/
	    uint8[2] v,

		/*
		[0] orderR
		[1] orderS
		[2] cancelR
		[3] cancelS
		*/
	    bytes32[4] rs,

		/*
		[0] orderAmountBuy
		[1] orderAmountSell
		[2] orderNonce
		[3] cancelNonce
		[4] cancelFee
		*/
		uint256[5] cancelValues,

		/*
		[0] orderTokenBuy
		[1] orderTokenSell
		[2] orderUser
		[3] cancelUser
		*/
		address[4] cancelAddresses
    ) onlyAdmin {
        // Order values should be valid and signed by order owner
        bytes32 orderHash = keccak256(
	        this, cancelAddresses[0], cancelValues[0], cancelAddresses[1],
	        cancelValues[1], cancelValues[2], cancelAddresses[2]
        );
        require(ecrecover(keccak256("\x19Ethereum Signed Message:\n32", orderHash), v[0], rs[0], rs[1]) == cancelAddresses[2]);

        // Cancel action should be signed by order owner
        bytes32 cancelHash = keccak256(this, orderHash, cancelAddresses[3], cancelValues[3]);
        require(ecrecover(keccak256("\x19Ethereum Signed Message:\n32", cancelHash), v[1], rs[2], rs[3]) == cancelAddresses[3]);

        // Order owner should be the same as cancel's initiator
        require(cancelAddresses[2] == cancelAddresses[3]);

        // Do not allow to cancel already canceled or filled orders
        require(orderFills[orderHash] != cancelValues[0]);

        // Cancel gas fee cannot exceed 0.05 ETh
        if (cancelValues[4] > 50 finney) {
            cancelValues[4] = 50 finney;
        }

        // Take cancel fee
        // This operation throws an error if fee amount is greater than the user balance
        //tokens[address(0)][cancelAddresses[3]] = safeSub(tokens[address(0)][cancelAddresses[3]], cancelValues[4]);
        subBalance(address(0), cancelAddresses[3], cancelValues[4]);

        // Cancel order by setting amount filled to total order value, i.e. making the order filled
        orderFills[orderHash] = cancelValues[0];

        // Fire cancel order event
        emit CancelOrder(cancelHash, orderHash, cancelAddresses[3], cancelAddresses[1], cancelValues[1], cancelValues[4]);
    }

    // Returns the smaller of two values
    function min(uint a, uint b) private pure returns (uint) {
        return a < b ? a : b;
    }
}