pragma solidity ^0.4.24;

contract DiscountToken { mapping (address => uint256) public balanceOf; }

contract TwoCoinsOneMoonGame {
    struct Bettor {
        address account;
        uint256 amount;
        uint256 amountEth;
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
    uint256 public lastActionBlock;
    uint256 public moonLevel;

    uint256 public marketCapBlue;
    uint256 public marketCapRed;

    uint256 public jackpotBlue;
    uint256 public jackpotRed;
    
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

    bool isPaused;

    constructor() public {
        marketCapBlue = 0;
        marketCapRed = 0;

        jackpotBlue = 0;
        jackpotRed = 0;
        
        startBetBlue = 0;
        startBetRed = 0;

        endBetBlue = 0;
        endBetRed = 0;

        publisher = msg.sender;
        feeCollector = 0xfD4e7B9F4F97330356F7d1b5DDB9843F2C3e9d87;
        discountToken = DiscountToken(0x25a803EC5d9a14D41F1Af5274d3f2C77eec80CE9);
        lastLevelChangeBlock = block.number;

        lastActionBlock = block.number;
        moonLevel = 5 * (uint256(10) ** 17);
        isPaused = false;
    }

    function getBetAmountGNC(uint256 marketCap, uint256 tokenCount, uint256 betAmount) private view returns (uint256) {
        require (msg.value >= 100 finney);

        uint256 betAmountGNC = 0;
        if (marketCap < 1 * moonLevel / 100) {
            betAmountGNC += 10 * betAmount;
        }
        else if (marketCap < 2 * moonLevel / 100) {
            betAmountGNC += 8 * betAmount;
        }
        else if (marketCap < 5 * moonLevel / 100) {
            betAmountGNC += 5 * betAmount;
        }
        else if (marketCap < 10 * moonLevel / 100) {
            betAmountGNC += 4 * betAmount;
        }
        else if (marketCap < 20 * moonLevel / 100) {
            betAmountGNC += 3 * betAmount;
        }
        else if (marketCap < 33 * moonLevel / 100) {
            betAmountGNC += 2 * betAmount;
        }
        else {
            betAmountGNC += betAmount;
        }

        if (tokenCount != 0) {
            if (tokenCount >= 2 && tokenCount <= 4) {
                betAmountGNC = betAmountGNC *  105 / 100;
            }
            if (tokenCount >= 5 && tokenCount <= 9) {
                betAmountGNC = betAmountGNC *  115 / 100;
            }
            if (tokenCount >= 10 && tokenCount <= 20) {
                betAmountGNC = betAmountGNC *  135 / 100;
            }
            if (tokenCount >= 21 && tokenCount <= 41) {
                betAmountGNC = betAmountGNC *  170 / 100;
            }
            if (tokenCount >= 42) {
                betAmountGNC = betAmountGNC *  200 / 100;
            }
        }
        return betAmountGNC;
    }

    function putMessage(string message) public {
        if (msg.sender == publisher) {
            publisherMessage = message;
        }
    }

    function togglePause(bool paused) public {
        if (msg.sender == publisher) {
            isPaused = paused;
        }
    }

    function getBetAmountETH(uint256 tokenCount) private returns (uint256) {
        uint256 betAmount = msg.value;
        if (tokenCount == 0) {
            uint256 comission = betAmount * 38 / 1000;
            betAmount -= comission;
            balance[feeCollector] += comission;
        }
        return betAmount;
    }

    function betBlueCoin(uint256 actionBlock) public payable {
        require (!isPaused || marketCapBlue > 0 || actionBlock == lastActionBlock);

        uint256 tokenCount = discountToken.balanceOf(msg.sender);
        uint256 betAmountETH = getBetAmountETH(tokenCount);
        uint256 betAmountGNC = getBetAmountGNC(marketCapBlue, tokenCount, betAmountETH);

        jackpotBlue += betAmountETH;
        marketCapBlue += betAmountGNC;
        bettorsBlue.push(Bettor({account:msg.sender, amount:betAmountGNC, amountEth:betAmountETH}));
        endBetBlue = bettorsBlue.length;
        lastActionBlock = block.number;

        checkMoon();
    }

    function betRedCoin(uint256 actionBlock) public payable {
        require (!isPaused || marketCapRed > 0 || actionBlock == lastActionBlock);

        uint256 tokenCount = discountToken.balanceOf(msg.sender);
        uint256 betAmountETH = getBetAmountETH(tokenCount);
        uint256 betAmountGNC = getBetAmountGNC(marketCapBlue, tokenCount, betAmountETH);

        jackpotRed += betAmountETH;
        marketCapRed += betAmountGNC;
        bettorsRed.push(Bettor({account:msg.sender, amount:betAmountGNC, amountEth: betAmountETH}));
        endBetRed = bettorsRed.length;
        lastActionBlock = block.number;

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
                balance[bettorsBlue[i].account] += bettorsBlue[i].amountEth;
                balance[bettorsBlue[i].account] += 10**18 * bettorsBlue[i].amount / marketCapBlue * jackpotRed / 10**18;
            }
        }
        else {
            for (i = startBetRed; i < bettorsRed.length; i++) {
                balance[bettorsRed[i].account] += bettorsRed[i].amountEth;
                balance[bettorsRed[i].account] += 10**18 * bettorsRed[i].amount / marketCapRed * jackpotBlue / 10**18;
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

        jackpotBlue = 0;
        jackpotRed = 0;
        
        startBetBlue = bettorsBlue.length;
        startBetRed = bettorsRed.length;
    }

    function checkMoon() private {
        if (block.number - lastLevelChangeBlock > 2880) {
           moonLevel = moonLevel / 2;
           addEvent(2);
        }
        if (marketCapBlue >= moonLevel || marketCapRed >= moonLevel) {
            burstBubble();
        }
    }
}