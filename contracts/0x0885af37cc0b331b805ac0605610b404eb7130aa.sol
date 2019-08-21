pragma solidity ^0.5.0;

/**
 * (E)t)h)e)x) Jackpot Contract 
 *  This smart-contract is the part of Ethex Lottery fair game.
 *  See latest version at https://github.com/ethex-bet/ethex-lottery 
 *  http://ethex.bet
 */

contract EthexJackpot {
    mapping(uint256 => address payable) tickets;
    uint256 public numberEnd;
    uint256 public dailyAmount;
    uint256 public weeklyAmount;
    uint256 public monthlyAmount;
    uint256 public seasonalAmount;
    bool private dailyProcessed;
    bool private weeklyProcessed;
    bool private monthlyProcessed;
    bool private seasonalProcessed;
    uint256 private dailyNumberStartPrev;
    uint256 private weeklyNumberStartPrev;
    uint256 private monthlyNumberStartPrev;
    uint256 private seasonalNumberStartPrev;
    uint256 private dailyStart;
    uint256 private weeklyStart;
    uint256 private monthlyStart;
    uint256 private seasonalStart;
    uint256 private dailyEnd;
    uint256 private weeklyEnd;
    uint256 private monthlyEnd;
    uint256 private seasonalEnd;
    uint256 private dailyNumberStart;
    uint256 private weeklyNumberStart;
    uint256 private monthlyNumberStart;
    uint256 private seasonalNumberStart;
    uint256 private dailyNumberEndPrev;
    uint256 private weeklyNumberEndPrev;
    uint256 private monthlyNumberEndPrev;
    uint256 private seasonalNumberEndPrev;
    address public lotoAddress;
    address payable private owner;
    
    event Jackpot (
        uint256 number,
        uint256 count,
        uint256 amount,
        byte jackpotType
    );
    
    event Ticket (
        bytes16 indexed id,
        uint256 number
    );
    
    uint256 constant DAILY = 5000;
    uint256 constant WEEKLY = 35000;
    uint256 constant MONTHLY = 140000;
    uint256 constant SEASONAL = 420000;
    
    constructor() public payable {
        owner = msg.sender;
        dailyStart = block.number / DAILY * DAILY;
        dailyEnd = dailyStart + DAILY;
        dailyProcessed = true;
        weeklyStart = block.number / WEEKLY * WEEKLY;
        weeklyEnd = weeklyStart + WEEKLY;
        weeklyProcessed = true;
        monthlyStart = block.number / MONTHLY * MONTHLY;
        monthlyEnd = monthlyStart + MONTHLY;
        monthlyProcessed = true;
        seasonalStart = block.number / SEASONAL * SEASONAL;
        seasonalEnd = seasonalStart + SEASONAL;
        seasonalProcessed = true;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyLoto {
        require(msg.sender == lotoAddress, "Loto only");
        _;
    }
    
    function migrate(address payable newContract) external onlyOwner {
        newContract.transfer(address(this).balance);
    }

    function registerTicket(bytes16 id, address payable gamer) external onlyLoto {
        uint256 number = numberEnd + 1;
        if (block.number >= dailyEnd) {
            setDaily();
            dailyNumberStart = number;
        }
        if (block.number >= weeklyEnd) {
            setWeekly();
            weeklyNumberStart = number;
        }
        if (block.number >= monthlyEnd) {
            setMonthly();
            monthlyNumberStart = number;
        }
        if (block.number >= seasonalEnd) {
            setSeasonal();
            seasonalNumberStart = number;
        }
        numberEnd = number;
        tickets[number] = gamer;
        emit Ticket(id, number);
    }
    
    function setLoto(address loto) external onlyOwner {
        lotoAddress = loto;
    }
    
    function payIn() external payable {
        uint256 amount = msg.value / 4;
        dailyAmount += amount;
        weeklyAmount += amount;
        monthlyAmount += amount;
        seasonalAmount += amount;
    }
    
    function settleJackpot() external {
        if (block.number >= dailyEnd) {
            setDaily();
        }
        if (block.number >= weeklyEnd) {
            setWeekly();
        }
        if (block.number >= monthlyEnd) {
            setMonthly();
        }
        if (block.number >= seasonalEnd) {
            setSeasonal();
        }
        
        if (block.number == dailyStart)
            return;
        
        uint48 modulo = uint48(bytes6(blockhash(dailyStart) << 29));
        
        uint256 dailyPayAmount;
        uint256 weeklyPayAmount;
        uint256 monthlyPayAmount;
        uint256 seasonalPayAmount;
        uint256 dailyWin;
        uint256 weeklyWin;
        uint256 monthlyWin;
        uint256 seasonalWin;
        if (dailyProcessed == false) {
            dailyPayAmount = dailyAmount; 
            dailyAmount = 0;
            dailyProcessed = true;
            dailyWin = getNumber(dailyNumberStartPrev, dailyNumberEndPrev, modulo);
            emit Jackpot(dailyWin, dailyNumberEndPrev - dailyNumberStartPrev + 1, dailyPayAmount, 0x01);
        }
        if (weeklyProcessed == false) {
            weeklyPayAmount = weeklyAmount;
            weeklyAmount = 0;
            weeklyProcessed = true;
            weeklyWin = getNumber(weeklyNumberStartPrev, weeklyNumberEndPrev, modulo);
            emit Jackpot(weeklyWin, weeklyNumberEndPrev - weeklyNumberStartPrev + 1, weeklyPayAmount, 0x02);
        }
        if (monthlyProcessed == false) {
            monthlyPayAmount = monthlyAmount;
            monthlyAmount = 0;
            monthlyProcessed = true;
            monthlyWin = getNumber(monthlyNumberStartPrev, monthlyNumberEndPrev, modulo);
            emit Jackpot(monthlyWin, monthlyNumberEndPrev - monthlyNumberStartPrev + 1, monthlyPayAmount, 0x04);
        }
        if (seasonalProcessed == false) {
            seasonalPayAmount = seasonalAmount;
            seasonalAmount = 0;
            seasonalProcessed = true;
            seasonalWin = getNumber(seasonalNumberStartPrev, seasonalNumberEndPrev, modulo);
            emit Jackpot(seasonalWin, seasonalNumberEndPrev - seasonalNumberStartPrev + 1, seasonalPayAmount, 0x08);
        }
        if (dailyPayAmount > 0)
            tickets[dailyWin].transfer(dailyPayAmount);
        if (weeklyPayAmount > 0)
            tickets[weeklyWin].transfer(weeklyPayAmount);
        if (monthlyPayAmount > 0)
            tickets[monthlyWin].transfer(monthlyPayAmount);
        if (seasonalPayAmount > 0)
            tickets[seasonalWin].transfer(seasonalPayAmount);
    }
    
    function setDaily() private {
        dailyProcessed = dailyNumberEndPrev == numberEnd;
        dailyStart = dailyEnd;
        dailyEnd = dailyStart + DAILY;
        dailyNumberStartPrev = dailyNumberStart;
        dailyNumberEndPrev = numberEnd;
    }
    
    function setWeekly() private {
        weeklyProcessed = weeklyNumberEndPrev == numberEnd;
        weeklyStart = weeklyEnd;
        weeklyEnd = weeklyStart + WEEKLY;
        weeklyNumberStartPrev = weeklyNumberStart;
        weeklyNumberEndPrev = numberEnd;
    }
    
    function setMonthly() private {
        monthlyProcessed = monthlyNumberEndPrev == numberEnd;
        monthlyStart = monthlyEnd;
        monthlyEnd = monthlyStart + MONTHLY;
        monthlyNumberStartPrev = monthlyNumberStart;
        monthlyNumberEndPrev = numberEnd;
    }
    
    function setSeasonal() private {
        seasonalProcessed = seasonalNumberEndPrev == numberEnd;
        seasonalStart = seasonalEnd;
        seasonalEnd = seasonalStart + SEASONAL;
        seasonalNumberStartPrev = seasonalNumberStart;
        seasonalNumberEndPrev = numberEnd;
    }
    
    function getNumber(uint256 startNumber, uint256 endNumber, uint48 modulo) pure private returns (uint256) {
        return startNumber + modulo % (endNumber - startNumber + 1);
    }
}