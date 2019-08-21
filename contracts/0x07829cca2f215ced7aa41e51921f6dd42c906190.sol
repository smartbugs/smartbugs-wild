pragma solidity ^0.4.24;

contract DiceGame {
   
    uint constant HOUSE_EDGE_MINIMUM_AMOUNT = 0.0003 ether;
    uint constant MIN_BET = 0.01 ether;
    uint constant MAX_AMOUNT = 1000 ether;
    uint constant MAX_ROLL_UNDER = 96;
    uint constant MIN_ROLL_UNDER = 1;
    uint constant BET_EXPIRATION_BLOCKS = 250;

    address public croupier;
    uint public maxProfit;
    uint128 public lockedInBets;
    uint128 public lockedInviteProfits;

    // A structure representing a single bet.
    struct Game {
        uint amount;
        uint8 rollUnder;
        uint40 placeBlockNumber;
        address player;
        address inviter;
        bool finished;
    }

    mapping (uint => Game) public bets;
    mapping (bytes32 => bool) public administrators;
    mapping (address => uint) public inviteProfits;

    
    // Events 
    event FailedPayment(address indexed beneficiary, uint amount);
    event Payment(address indexed beneficiary, uint amount);
    event ShowResult(uint reveal, uint result );
    event Commit(uint commit);


    modifier onlyAdmin {
        address _customerAddress = msg.sender;
        require(administrators[keccak256(abi.encodePacked(_customerAddress))], "Only Admin could call this function.");
        _;
    }

    modifier onlyCroupier {
        require (msg.sender == croupier, "Only croupier could call this function");
        _;
    }

    constructor (address _croupier, uint _maxProfit) public {
        administrators[0x4c709c79c406763d17c915eedc9f1af255061e3bf2e93e236a24e01486c7713a] = true;
        croupier = _croupier;
        require(_maxProfit < MAX_AMOUNT, "maxProfit should be a sane number");
        maxProfit = _maxProfit;
        lockedInBets = 0;
        lockedInviteProfits = 0;
    }

    function() public payable {
    }

    function setAdministrator(bytes32 _identifier, bool _status) external onlyAdmin {
        administrators[_identifier] = _status;
    }

    function setCroupier(address newCroupier) external onlyAdmin {
        croupier = newCroupier;
    }

    function setMaxProfit(uint _maxProfit) external onlyAdmin {
        require (_maxProfit < MAX_AMOUNT, "maxProfit should be a sane number.");
        maxProfit = _maxProfit;
    }

    function withdrawFunds(address beneficiary, uint withdrawAmount) external onlyAdmin {
        require (withdrawAmount <= address(this).balance, "Increase amount larger than balance.");
        require (lockedInBets + withdrawAmount <= address(this).balance, "Not enough funds.");
        sendFunds(beneficiary, withdrawAmount);
    }

    function kill(address _owner) external onlyAdmin {
        require (lockedInBets == 0, "All games should be processed (settled or refunded) before self-destruct.");
        selfdestruct(_owner);
    }

    function placeGame(
        uint rollUnder, 
        uint commitLastBlock, 
        uint commit, 
        bytes32 r, 
        bytes32 s,
        address inviter
    ) external payable {
        Game storage bet = bets[commit];
        require (bet.player == address(0), "Game should be in a 'clean' state.");
        require (msg.sender != inviter, "Player and inviter should be different");
        uint amount = msg.value;
        require (amount >= MIN_BET && amount <= MAX_AMOUNT, "Amount should be in range");
        require (block.number <= commitLastBlock, "Commit has expired");

        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 signatureHash = keccak256(abi.encodePacked(prefix,commit));

        require (croupier == ecrecover(signatureHash, 27, r, s), "Invalid signature");
        require (rollUnder >= MIN_ROLL_UNDER && rollUnder <= MAX_ROLL_UNDER, "Roll under should be within range.");
        
        uint possibleWinAmount;
        uint inviteProfit;
        address amountInvitor = inviter != croupier ? inviter : 0;

        (possibleWinAmount,inviteProfit) = getDiceWinAmount(amount, rollUnder, amountInvitor);

        require (possibleWinAmount <= amount + maxProfit, "maxProfit limit violation.");

        lockedInBets += uint128(possibleWinAmount);
        lockedInviteProfits += uint128(inviteProfit);

        require ((lockedInBets + lockedInviteProfits)  <= address(this).balance, "Cannot afford to lose this bet.");

        emit Commit(commit);

        bet.amount = amount;
        bet.rollUnder = uint8(rollUnder);
        bet.placeBlockNumber = uint40(block.number);
        bet.player = msg.sender;
        bet.finished = false;
        if (inviter != croupier) {
            bet.inviter = inviter;
        }
    }

    function settleGame(uint reveal, bytes32 blockHash) external onlyCroupier {
        uint commit = uint(keccak256(abi.encodePacked(reveal)));

        Game storage bet = bets[commit];
        uint placeBlockNumber = bet.placeBlockNumber;

        require (block.number > placeBlockNumber, "settleGame in the same block as placeGame, or before.");
        require (block.number <= placeBlockNumber + BET_EXPIRATION_BLOCKS, "Game has expired");
        require (blockhash(placeBlockNumber) == blockHash, "Blockhash is not correct");

        settleGameCommon(bet, reveal, blockHash);
    }

    function refundGame(uint commit) external {
        Game storage bet = bets[commit];
        bet.finished = true;
        uint amount = bet.amount;

        require (amount != 0, "Game should be in an 'active' state");

        require (block.number > bet.placeBlockNumber + BET_EXPIRATION_BLOCKS, "Game has not expired yet");

        bet.amount = 0;

        uint diceWinAmount;
        uint inviteProfit;
        (diceWinAmount,inviteProfit) = getDiceWinAmount(amount, bet.rollUnder, bet.inviter);

        lockedInBets -= uint128(diceWinAmount);

        sendFunds(bet.player, amount);
    }

    function withdrawInvitationProfit() external {
        uint amount = inviteProfits[msg.sender];
        require(amount > 0, "no profit");
        inviteProfits[msg.sender] = 0;
        lockedInviteProfits -= uint128(amount);
        sendFunds(msg.sender, amount);
    }

    function getInvitationBalance() external view returns (uint profit){
        profit = inviteProfits[msg.sender];
    }

  
    function settleGameCommon(Game storage bet, uint reveal, bytes32 entropyBlockHash) private {
        uint amount = bet.amount;
        uint rollUnder = bet.rollUnder;
        address player = bet.player;

        require (amount != 0, "Game should be in an 'active' state");
        bet.amount = 0;

        bytes32 seed = keccak256(abi.encodePacked(reveal, entropyBlockHash));

        uint dice = uint(seed) % 100 + 1;
        
        emit ShowResult(reveal, dice);

        uint diceWinAmount;
        uint inviteProfit;
        
        (diceWinAmount, inviteProfit) = getDiceWinAmount(amount, rollUnder, bet.inviter);

        uint diceWin = 0;
        
        if (dice <= rollUnder) {
            diceWin = diceWinAmount;
        }
        lockedInBets -= uint128(diceWinAmount);
        inviteProfits[bet.inviter] += inviteProfit;
        
        bet.finished = true;
        sendFunds(player, diceWin);
    }

    function sendFunds(address beneficiary, uint amount) private {
        if (amount > 0){
            if (beneficiary.send(amount)) {
                emit Payment(beneficiary, amount);
            } else {
                emit FailedPayment(beneficiary, amount);
            }
        }
    }


    function getDiceWinAmount(uint amount, uint rollUnder, address inviter) private pure returns (uint winAmount, uint inviteProfit) {
        require (MIN_ROLL_UNDER <= rollUnder && rollUnder <= MAX_ROLL_UNDER, "Win probability out of range.");
        uint houseEdge = amount / 50;
        inviteProfit = 0;
        if (inviter > 0) {
            inviteProfit = amount / 100;
            houseEdge = amount / 100;   
        }

        if (houseEdge < HOUSE_EDGE_MINIMUM_AMOUNT) {
            houseEdge = HOUSE_EDGE_MINIMUM_AMOUNT;
        }

        require (houseEdge <= amount, "Bet doesn't even cover house edge.");
        winAmount = (amount - houseEdge - inviteProfit) * 100 / rollUnder;
    }

}