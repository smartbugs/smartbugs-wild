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
    uint256 public startBetRed;

    Bettor[] public bettorsBlue;
    Bettor[] public bettorsRed;

    Event[] public history;

    mapping (address => uint) public balance;

    address private feeCollector;

    DiscountToken discountToken;

    constructor() public {
        marketCapBlue = 0;
        marketCapRed = 0;
        
        startBetBlue = 0;
        startBetRed = 0;
        
        feeCollector = 0xfd4e7b9f4f97330356f7d1b5ddb9843f2c3e9d87;
        discountToken = DiscountToken(0x40430713e9fa954cf33562b8469ad94ab3e14c10);
        lastLevelChangeBlock = block.number;
        moonLevel = 500 finney;
    }

    function getBetAmount() private returns (uint256) {
        require (msg.value >= 100 finney);

        uint256 betAmount = msg.value;
        if (discountToken.balanceOf(msg.sender) == 0) {
            uint256 comission = betAmount * 4 / 100;
            betAmount -= comission;
            balance[feeCollector] += comission;
        }

        return betAmount;
    }

    function betBlueCoin() public payable {
        uint256 betAmount = getBetAmount();

        marketCapBlue += betAmount;
        bettorsBlue.push(Bettor({account:msg.sender, amount:betAmount}));

        checkMoon();
    }

    function betRedCoin() public payable {
        uint256 betAmount = getBetAmount();

        marketCapRed += betAmount;
        bettorsRed.push(Bettor({account:msg.sender, amount:betAmount}));

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