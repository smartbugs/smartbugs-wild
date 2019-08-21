pragma solidity < 0.6;

contract Game365Meta {

    /**
        owner setting
     */
    address payable public owner;

    // Croupier account.
    address public croupier = address(0x0);

    // The address corresponding to a private key used to sign placeBet commits.
    address public secretSigner = address(0x0);

    // Adjustable max bet profit and start winning the jackpot. Used to cap bets against dynamic odds.
    uint public maxProfit = 5 ether;
    uint public minJackpotWinAmount = 0.1 ether;

    /*
        set constants
    */
    uint constant HOUSE_EDGE_PERCENT = 1;
    uint constant HOUSE_EDGE_MINIMUM_AMOUNT = 0.0003 ether; 

    // Chance to win jackpot (currently 0.1%) and fee deducted into jackpot fund.
    uint public constant MIN_JACKPOT_BET = 0.1 ether;
    uint public constant JACKPOT_MODULO = 1000; 
    uint constant JACKPOT_FEE = 0.001 ether; 

    // There is minimum and maximum bets.
    uint public constant MIN_BET = 0.01 ether;
    uint constant MAX_AMOUNT = 300000 ether; 
    
    // Modulo is a number of equiprobable outcomes in a game:
    //  - 2 for coin flip
    //  - 6 for dice
    //  - 6*6 = 36 for double dice
    //  - 100 for etheroll
    //  - 37 for roulette
    //  etc.
    // It's called so because 256-bit entropy is treated like a huge integer and
    // the remainder of its division by modulo is considered bet outcome.
    uint constant MAX_MODULO = 100;
    uint constant MAX_MASK_MODULO = 40;

    // This is a check on bet mask overflow.
    uint constant MAX_BET_MASK = 2 ** MAX_MASK_MODULO;

    // EVM BLOCKHASH opcode can query no further than 256 blocks into the
    // past. Given that settleBet uses block hash of placeBet as one of
    // complementary entropy sources, we cannot process bets older than this
    // threshold. On rare occasions our croupier may fail to invoke
    // settleBet in this timespan due to technical issues or extreme Ethereum
    // congestion; such bets can be refunded via invoking refundBet.
    uint constant BET_EXPIRATION_BLOCKS = 250;

    // This are some constants making O(1) population count in placeBet possible.
    // See whitepaper for intuition and proofs behind it.
    uint constant POPCNT_MULT = 0x0000000000002000000000100000000008000000000400000000020000000001;
    uint constant POPCNT_MASK = 0x0001041041041041041041041041041041041041041041041041041041041041;
    uint constant POPCNT_MODULO = 0x3F; // decimal:63, binary:111111
    
    /**
        24h Total bet amounts/counts
     */    
    uint256 public lockedInBets_;
    uint256 public lockedInJackpot_;
    
    struct Bet {
        // Wager amount in wei.
        uint amount;
        // Modulo of a game.
        uint8 modulo;
        // Number of winning outcomes, used to compute winning payment (* modulo/rollUnder),
        // and used instead of mask for games with modulo > MAX_MASK_MODULO.
        uint8 rollUnder;
        // Block number of placeBet tx.
        uint40 placeBlockNumber;
        // Bit mask representing winning bet outcomes (see MAX_MASK_MODULO comment).
        uint40 mask;
        // Address of a gambler, used to pay out winning bets.
        address payable gambler;
    }
    mapping(uint256 => Bet) bets;

    // Events that are issued to make statistic recovery easier.
    event FailedPayment(uint commit, address indexed beneficiary, uint amount, uint jackpotAmount);
    event Payment(uint commit, address indexed beneficiary, uint amount, uint jackpotAmount);
    event JackpotPayment(address indexed beneficiary, uint amount);
    event Commit(uint256 commit);
    
    /**
        Constructor
     */
    constructor () 
        public
    {
        owner = msg.sender;
    }

    /**
        Modifier
    */
    // Standard modifier on methods invokable only by contract owner.
    modifier onlyOwner {
        require (msg.sender == owner, "OnlyOwner methods called by non-owner.");
        _;
    }
    
    // Standard modifier on methods invokable only by contract owner.
    modifier onlyCroupier {
        require (msg.sender == croupier, "OnlyCroupier methods called by non-croupier.");
        _;
    }

    // See comment for "secretSigner" variable.
    function setSecretSigner(address newSecretSigner) external onlyOwner {
        secretSigner = newSecretSigner;
    }

    // Change the croupier address.
    function setCroupier(address newCroupier) external onlyOwner {
        croupier = newCroupier;
    }

    function setMaxProfit(uint _maxProfit) public onlyOwner {
        require (_maxProfit < MAX_AMOUNT, "maxProfit should be a sane number.");
        maxProfit = _maxProfit;
    }

    function setMinJackPotWinAmount(uint _minJackpotAmount) public onlyOwner {
        minJackpotWinAmount = _minJackpotAmount;
    }

    // This function is used to bump up the jackpot fund. Cannot be used to lower it.
    function increaseJackpot(uint increaseAmount) external onlyOwner {
        require (increaseAmount <= address(this).balance, "Increase amount larger than balance.");
        require (lockedInJackpot_ + lockedInBets_ + increaseAmount <= address(this).balance, "Not enough funds.");
        lockedInJackpot_ += uint128(increaseAmount);
    }

    // Funds withdrawal to cover costs of our operation.
    function withdrawFunds(address payable beneficiary, uint withdrawAmount) external onlyOwner {
        require (withdrawAmount <= address(this).balance, "Increase amount larger than balance.");
        sendFunds(1, beneficiary, withdrawAmount, 0);
    }
    
    // Contract may be destroyed only when there are no ongoing bets,
    // either settled or refunded. All funds are transferred to contract owner.
    function kill() external onlyOwner {
        selfdestruct(owner);
    }

    // Fallback function deliberately left empty. It's primary use case
    // is to top up the bank roll.
    function () external payable {
    }
    
    function placeBet(uint256 betMask, uint256 modulo, uint256 commitLastBlock, uint256 commit, bytes32 r, bytes32 s) 
        external
        payable 
    {
        Bet storage bet = bets[commit];
        require(bet.gambler == address(0), "already betting same commit number");

        uint256 amount = msg.value;
        require (modulo > 1 && modulo <= MAX_MODULO, "Modulo should be within range.");
        require (amount >= MIN_BET && amount <= MAX_AMOUNT, "Amount should be within range.");
        require (betMask > 0 && betMask < MAX_BET_MASK, "Mask should be within range.");

        require (block.number <= commitLastBlock, "Commit has expired.");

        //@DEV It will be changed later.
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, commit));
        require (secretSigner == ecrecover(prefixedHash, 28, r, s), "ECDSA signature is not valid.");


        // Winning amount and jackpot increase.
        uint rollUnder;
        // uint mask;
        
        // Small modulo games specify bet outcomes via bit mask.
        // rollUnder is a number of 1 bits in this mask (population count).
        // This magical looking formula is an efficient way to compute population
        // count on EVM for numbers below 2**40. For detailed proof consult
        // the our whitepaper.
        if(modulo <= MAX_MASK_MODULO){
            rollUnder = ((betMask * POPCNT_MULT) & POPCNT_MASK) % POPCNT_MODULO;
            // mask = betMask;  //Stack too deep, try removing local variables.
        }else{
            require (betMask > 0 && betMask <= modulo, "High modulo range, betMask larger than modulo.");
            rollUnder = betMask;
        }

        uint possibleWinAmount;
        uint jackpotFee;

        (possibleWinAmount, jackpotFee) = getDiceWinAmount(amount, modulo, rollUnder);

        // Enforce max profit limit.
        require (possibleWinAmount <= amount + maxProfit, "maxProfit limit violation.");

        // Lock funds.
        lockedInBets_ += uint128(possibleWinAmount);
        lockedInJackpot_ += uint128(jackpotFee);

        // Check whether contract has enough funds to process this bet.
        require (lockedInJackpot_ + lockedInBets_ <= address(this).balance, "Cannot afford to lose this bet.");
        
        // Record commit in logs.
        emit Commit(commit);

        bet.amount = amount;
        bet.modulo = uint8(modulo);
        bet.rollUnder = uint8(rollUnder);
        bet.placeBlockNumber = uint40(block.number);
        bet.mask = uint40(betMask);
        bet.gambler = msg.sender;
    }
    
    // This is the method used to settle 99% of bets. To process a bet with a specific
    // "commit", settleBet should supply a "reveal" number that would Keccak256-hash to
    // "commit". "blockHash" is the block hash of placeBet block as seen by croupier; it
    // is additionally asserted to prevent changing the bet outcomes on Ethereum reorgs.
    function settleBet(uint reveal, bytes32 blockHash) external onlyCroupier {
        uint commit = uint(keccak256(abi.encodePacked(reveal)));

        Bet storage bet = bets[commit];
        uint placeBlockNumber = bet.placeBlockNumber;

        // Check that bet has not expired yet (see comment to BET_EXPIRATION_BLOCKS).
        require (block.number > placeBlockNumber, "settleBet in the same block as placeBet, or before.");
        require (block.number <= placeBlockNumber + BET_EXPIRATION_BLOCKS, "Blockhash can't be queried by EVM.");
        require (blockhash(placeBlockNumber) == blockHash, "Does not matched blockHash.");

        // Settle bet using reveal and blockHash as entropy sources.
        settleBetCommon(bet, reveal, blockHash);
    }

    // Common settlement code for settleBet & settleBetUncleMerkleProof.
    function settleBetCommon(Bet storage bet, uint reveal, bytes32 entropyBlockHash) private {
        // Fetch bet parameters into local variables (to save gas).
        uint commit = uint(keccak256(abi.encodePacked(reveal)));
        uint amount = bet.amount;
        uint modulo = bet.modulo;
        uint rollUnder = bet.rollUnder;
        address payable gambler = bet.gambler;

        // Check that bet is in 'active' state.
        require (amount != 0, "Bet should be in an 'active' state");

        // Move bet into 'processed' state already.
        bet.amount = 0;
        
        // The RNG - combine "reveal" and blockhash of placeBet using Keccak256. Miners
        // are not aware of "reveal" and cannot deduce it from "commit" (as Keccak256
        // preimage is intractable), and house is unable to alter the "reveal" after
        // placeBet have been mined (as Keccak256 collision finding is also intractable).
        bytes32 entropy = keccak256(abi.encodePacked(reveal, entropyBlockHash));

        // Do a roll by taking a modulo of entropy. Compute winning amount.
        uint dice = uint(entropy) % modulo;

        uint diceWinAmount;
        uint _jackpotFee;
        (diceWinAmount, _jackpotFee) = getDiceWinAmount(amount, modulo, rollUnder);

        uint diceWin = 0;
        uint jackpotWin = 0;

        // Determine dice outcome.
        if (modulo <= MAX_MASK_MODULO) {
            // For small modulo games, check the outcome against a bit mask.
            if ((2 ** dice) & bet.mask != 0) {
                diceWin = diceWinAmount;
            }
        } else {
            // For larger modulos, check inclusion into half-open interval.
            if (dice < rollUnder) {
                diceWin = diceWinAmount;
            }
        }

        // Unlock the bet amount, regardless of the outcome.
        lockedInBets_ -= uint128(diceWinAmount);

        // Roll for a jackpot (if eligible).
        if (amount >= MIN_JACKPOT_BET && lockedInJackpot_ >= minJackpotWinAmount) {
            // The second modulo, statistically independent from the "main" dice roll.
            // Effectively you are playing two games at once!
            uint jackpotRng = (uint(entropy) / modulo) % JACKPOT_MODULO;

            // Bingo!
            if (jackpotRng == 0) {
                jackpotWin = lockedInJackpot_;
                lockedInJackpot_ = 0;
            }
        }

        // Log jackpot win.
        if (jackpotWin > 0) {
            emit JackpotPayment(gambler, jackpotWin);
        }

        // Send the funds to gambler.
        sendFunds(commit, gambler, diceWin, jackpotWin);
    }

    function getDiceWinAmount(uint amount, uint modulo, uint rollUnder) private pure returns (uint winAmount, uint jackpotFee) {
        require (0 < rollUnder && rollUnder <= modulo, "Win probability out of range.");

        jackpotFee = amount >= MIN_JACKPOT_BET ? JACKPOT_FEE : 0;

        uint houseEdge = amount * HOUSE_EDGE_PERCENT / 100;

        if (houseEdge < HOUSE_EDGE_MINIMUM_AMOUNT) {
            houseEdge = HOUSE_EDGE_MINIMUM_AMOUNT;
        }

        require (houseEdge + jackpotFee <= amount, "Bet doesn't even cover house edge.");
        winAmount = (amount - houseEdge - jackpotFee) * modulo / rollUnder;
    }
    
    // Refund transaction - return the bet amount of a roll that was not processed in a
    // due timeframe. Processing such blocks is not possible due to EVM limitations (see
    // BET_EXPIRATION_BLOCKS comment above for details). In case you ever find yourself
    // in a situation like this, just contact the our support, however nothing
    // precludes you from invoking this method yourself.
    function refundBet(uint commit) external {
        // Check that bet is in 'active' state.
        Bet storage bet = bets[commit];
        uint amount = bet.amount;

        require (amount != 0, "Bet should be in an 'active' state");

        // Check that bet has already expired.
        require (block.number > bet.placeBlockNumber + BET_EXPIRATION_BLOCKS, "Blockhash can't be queried by EVM.");

        // Move bet into 'processed' state, release funds.
        bet.amount = 0;
        
        uint diceWinAmount;
        uint jackpotFee;
        (diceWinAmount, jackpotFee) = getDiceWinAmount(amount, bet.modulo, bet.rollUnder);

        lockedInBets_ -= uint128(diceWinAmount);
        lockedInJackpot_ -= uint128(jackpotFee);

        // Send the refund.
        sendFunds(commit, bet.gambler, amount, 0);
    }

    // Helper routine to process the payment.
    function sendFunds(uint commit, address payable beneficiary, uint diceWin, uint jackpotWin) private {
        uint amount = diceWin + jackpotWin == 0 ? 1 wei : diceWin + jackpotWin;
        uint successLogAmount = diceWin;

        if (beneficiary.send(amount)) {
            emit Payment(commit, beneficiary, successLogAmount, jackpotWin);
        } else {
            emit FailedPayment(commit, beneficiary, amount, 0);
        }
    }
}