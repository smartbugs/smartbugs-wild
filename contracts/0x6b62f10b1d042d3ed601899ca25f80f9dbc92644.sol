pragma solidity ^0.4.24;

contract DiscountToken { mapping (address => uint256) public balanceOf; }

contract TwoCoinsOneMoonGame {
    struct Bettor {
        address account;
        uint256 amount;
    }

    struct Event {
        uint256 winner; //0 - blue; 1 - red
        uint256 newMoonLevel;
        uint256 block;
        uint256 blueCap;
        uint256 redCap;
    }

    uint256 public lastLevelChangeBlock;
    uint256 public lastEventId;
    uint256 public moonLevel;

    uint256 public marketCapBlue;
    uint256 public marketCapRed;
    
    uint256 public startBetBlue;
    uint256 public endBetBlue;
    uint256 public startBetRed;
    uint256 public endBetRed;

    Bettor[] public bettorsBlue;
    Bettor[] public bettorsRed;

    Event[] public history;

    mapping (address => uint) public balance;

    address private feeCollector;

    DiscountToken discountToken;

    string public publisherMessage;
    address publisher;

    constructor() public {
        marketCapBlue = 0;
        marketCapRed = 0;
        
        startBetBlue = 0;
        startBetRed = 0;
        endBetBlue = 0;
        endBetRed = 0;

        publisher = msg.sender;
        feeCollector = 0xfD4e7B9F4F97330356F7d1b5DDB9843F2C3e9d87;
        discountToken = DiscountToken(0x25a803EC5d9a14D41F1Af5274d3f2C77eec80CE9);
        lastLevelChangeBlock = block.number;
        moonLevel = 500 finney;
    }

    function getBetAmount() private returns (uint256) {
        require (msg.value >= 100 finney);

        uint256 betAmount = msg.value;
        if (discountToken.balanceOf(msg.sender) == 0) {
            uint256 comission = betAmount * 48 / 1000;
            betAmount -= comission;
            balance[feeCollector] += comission;
        }

        return betAmount;
    }

    function putMessage(string message) public {
        if (msg.sender == publisher) {
            publisherMessage = message;
        }
    }

    function betBlueCoin() public payable {
        uint256 betAmount = getBetAmount();

        marketCapBlue += betAmount;
        bettorsBlue.push(Bettor({account:msg.sender, amount:betAmount}));
        endBetBlue = bettorsBlue.length;

        checkMoon();
    }

    function betRedCoin() public payable {
        uint256 betAmount = getBetAmount();

        marketCapRed += betAmount;
        bettorsRed.push(Bettor({account:msg.sender, amount:betAmount}));
        endBetRed = bettorsRed.length;

        checkMoon();
    }

    function withdraw() public {
        if (balance[feeCollector] != 0) {
            uint256 fee = balance[feeCollector];
            balance[feeCollector] = 0;
            feeCollector.call.value(fee)();
        }

        uint256 amount = balance[msg.sender];
        balance[msg.sender] = 0;
        msg.sender.transfer(amount);
    }

    function depositBalance(uint256 winner) private {
        uint256 i;
        if (winner == 0) {
            for (i = startBetBlue; i < bettorsBlue.length; i++) {
                balance[bettorsBlue[i].account] += bettorsBlue[i].amount;
                balance[bettorsBlue[i].account] += 10**18 * bettorsBlue[i].amount / marketCapBlue * marketCapRed / 10**18;
            }
        }
        else {
            for (i = startBetRed; i < bettorsRed.length; i++) {
                balance[bettorsRed[i].account] += bettorsRed[i].amount;
                balance[bettorsRed[i].account] += 10**18 * bettorsRed[i].amount / marketCapRed * marketCapBlue / 10**18;
            }
        }
    }

    function addEvent(uint256 winner) private {
        history.push(Event({winner: winner, newMoonLevel: moonLevel, block: block.number, blueCap: marketCapBlue, redCap: marketCapRed}));
        lastEventId = history.length - 1;
        lastLevelChangeBlock = block.number;
    }

    function burstBubble() private {
        uint256 winner;
        if (marketCapBlue == marketCapRed) {
            winner = block.number % 2;
        }
        else if (marketCapBlue > marketCapRed) {
            winner = 0;
        }
        else {
            winner = 1;
        }
        depositBalance(winner);
        moonLevel = moonLevel * 2;
        addEvent(winner);

        marketCapBlue = 0;
        marketCapRed = 0;
        
        startBetBlue = bettorsBlue.length;
        startBetRed = bettorsRed.length;
    }

    function checkMoon() private {
        if (block.number - lastLevelChangeBlock > 42000) {
           moonLevel = moonLevel / 2;
           addEvent(2);
        }
        if (marketCapBlue >= moonLevel || marketCapRed >= moonLevel) {
            burstBubble();
        }
    }
}