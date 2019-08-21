pragma solidity ^0.4.24;

/**
 *
 * ETH CRYPTOCURRENCY DISTRIBUTION PROJECT
 * Web              - https://winethfree.com
 * Twitter          - https://twitter.com/winethfree
 * Telegram_channel - https://t.me/winethfree
 * Telegram_group   - https://t.me/wef_group
 *
 * __          ___         ______ _______ _    _   ______
 * \ \        / (_)       |  ____|__   __| |  | | |  ____|
 *  \ \  /\  / / _ _ __   | |__     | |  | |__| | | |__ _ __ ___  ___
 *   \ \/  \/ / | | '_ \  |  __|    | |  |  __  | |  __| '__/ _ \/ _ \
 *    \  /\  /  | | | | | | |____   | |  | |  | | | |  | | |  __/  __/
 *     \/  \/   |_|_| |_| |______|  |_|  |_|  |_| |_|  |_|  \___|\___|
 */

contract WinEthFree{

    // investor gets 2% interest per day to return.
    struct Investor {
        uint waveNum;      // wave Num
        uint investment;    // investment gets 2% interest per day
        uint payableInterest;  // payable interest until last pay time
        uint paidInterest;   // interest already paid
        uint payTime;
    }

    // Lottery ticket number from beginNum to endNum.
    struct LotteryTicket {
        address player;
        uint beginNum;
        uint endNum;
        bool conservative; // winner would not return interest for conservative wager.
    }

    enum WagerType { Conservative, Aggressive, Interest }

    Leverage private leverage;

    modifier onlyLeverage() {
        require(msg.sender == address(leverage), "access denied");
        _;
    }

    event LogNextWave();
    event LogNextBet();
    event LogWithdrawInterest(address, uint);
    event LogInvestChange(address, uint, uint, uint);
    event LogBet(WagerType, address, uint, uint, uint, uint);
    event LogPayWinnerPrize(address, uint, uint);

    address private admin;
    uint private constant commissionPercent = 10;

    uint private constant ratePercent = 2;
    uint private constant ratePeriod = 24 hours;
    uint private constant minInvestment = 10 finney;  //       0.01 ETH

    uint private constant leverageMultiple = 10;
    uint private constant minInterestWager = minInvestment / leverageMultiple;
    uint private constant prize1st = 1 ether;
    uint private constant prize2nd = 20 finney;
    uint private constant winnerNum = 11;
    uint private constant minPrizePool = prize1st + prize2nd * (winnerNum - 1);   // 1 + 0.02 * 10 ETH
    uint private constant prizePercent = 50;

    uint private waveNum;

    mapping (address => Investor) private investors;

    uint private activeTicketSlotSum;
    LotteryTicket[] private lotteryTickets;
    uint private ticketSum;
    uint private prizePool;
    uint private roundStartup;

    function isInvestor(address addr) private view returns (bool) {
        return investors[addr].waveNum == waveNum;
    }

    function resetInvestor(address addr) private {
        investors[addr].waveNum--;
    }

    function calcInterest(address addr) private returns (uint) {

        if (!isInvestor(addr)) {
            return 0;
        }

        uint investment = investors[addr].investment;
        uint paidInterest = investors[addr].paidInterest;

        if (investment <= paidInterest) {
            // investment decreases when player wins prize, could be less than paid interest.
            resetInvestor(addr);

            emit LogInvestChange(addr, 0, 0, 0);

            return 0;
        }

        uint payableInterest = investors[addr].payableInterest;
        uint payTime = investors[addr].payTime;

        uint interest = investment * ratePercent / 100 * (now - payTime) / ratePeriod;
        interest += payableInterest;

        uint restInterest = investment - paidInterest;

        if (interest > restInterest) {
            interest = restInterest;
        }

        return interest;
    }

    function takeInterest(address addr) private returns(uint) {
        uint interest = calcInterest(addr);

        if (interest < minInterestWager) {
            return 0;
        }

        // round down to FINNEY
        uint interestRoundDown = uint(interest / minInterestWager) * minInterestWager;

        investors[addr].payableInterest = interest - interestRoundDown;
        investors[addr].paidInterest += interestRoundDown;
        investors[addr].payTime = now;

        emit LogInvestChange(
            addr, investors[addr].payableInterest,
            investors[addr].paidInterest, investors[addr].investment
            );

        return interestRoundDown;
    }

    function withdrawInterest(address addr) private {
        uint interest = takeInterest(addr);

        if (interest == 0) {
            return;
        }

        uint balance = address(this).balance - prizePool;
        bool outOfBalance;

        if (balance <= interest) {
            outOfBalance = true;
            interest = balance;
        }

        addr.transfer(interest);

        emit LogWithdrawInterest(addr, interest);

        if (outOfBalance) {
            nextWave();
        }
    }

    // new investment or add more investment
    function doInvest(address addr, uint value) private {

        uint interest = calcInterest(addr);

        if (interest > 0) {
            // update payable Interest from last pay time.
            investors[addr].payableInterest = interest;
        }

        if (isInvestor(addr)) {
            // add more investment
            investors[addr].investment += value;
            investors[addr].payTime = now;
        } else {
            // new investment
            investors[addr].waveNum = waveNum;
            investors[addr].investment = value;
            investors[addr].payableInterest = 0;
            investors[addr].paidInterest = 0;
            investors[addr].payTime = now;
        }

        emit LogInvestChange(
            addr, investors[addr].payableInterest,
            investors[addr].paidInterest, investors[addr].investment
            );
    }

    // Change to not return interest if the player wins a prize.
    function WinnerNotReturn(address addr) private {

        // investment could be less than wager, if nextWave() triggered.
        if (investors[addr].investment >= minInvestment) {
            investors[addr].investment -= minInvestment;

            emit LogInvestChange(
                addr, investors[addr].payableInterest,
                investors[addr].paidInterest, investors[addr].investment
                );
        }
    }

    // wageType: 0 for conservative, 1 for aggressive, 2 for interest
    function doBet(address addr, uint value, WagerType wagerType) private returns(bool){
        uint ticketNum;
        bool conservative;

        if (wagerType != WagerType.Interest) {
            takeCommission(value);
        }

        if (value >= minInvestment) {
            // take 50% wager as winner's prize pool
            prizePool += value * prizePercent / 100;
        }

        if (wagerType == WagerType.Conservative) {
            // conservative, 0.01 ETH for 1 ticket
            ticketNum = value / minInvestment;
            conservative = true;
        } else if (wagerType == WagerType.Aggressive) {
            // aggressive
            ticketNum = value * leverageMultiple / minInvestment;
        } else {
            // interest
            ticketNum = value * leverageMultiple / minInvestment;
        }

        if (activeTicketSlotSum == lotteryTickets.length) {
            lotteryTickets.length++;
        }

        uint slot = activeTicketSlotSum++;
        lotteryTickets[slot].player = addr;
        lotteryTickets[slot].conservative = conservative;
        lotteryTickets[slot].beginNum = ticketSum;
        ticketSum += ticketNum;
        lotteryTickets[slot].endNum = ticketSum - 1;

        emit LogBet(wagerType, addr, value, lotteryTickets[slot].beginNum, lotteryTickets[slot].endNum, prizePool);

        if (prizePool >= minPrizePool) {

            if (address(this).balance - prizePool >= minInvestment) {
                // last one gets extra 0.01 ETH award.
                addr.transfer(minInvestment);
            }

            drawLottery();
            nextBet();
        }
    }

    function drawLottery() private {
        uint[] memory luckyTickets = getLuckyTickets();

        payTicketsPrize(luckyTickets);
    }

    function random(uint i) private view returns(uint) {
        // take last block hash as random seed
        return uint(keccak256(abi.encodePacked(blockhash(block.number - 1), i)));
    }

    function getLuckyTickets() private view returns(uint[] memory) {

        // lucky ticket number, 1 for first prize(1 ETH), 10 for second prize(0.02 ETH)
        uint[] memory luckyTickets = new uint[](winnerNum);

        uint num;
        uint k;

        for (uint i = 0;; i++) {
            num = random(i) % ticketSum;
            bool duplicate = false;
            for (uint j = 0; j < k; j++) {
                if (num == luckyTickets[j]) {
                    // random seed may generate duplicated lucky numbers.
                    duplicate = true;
                    break;
                }
            }

            if (!duplicate) {
                luckyTickets[k++] = num;

                if (k == winnerNum)
                    break;
            }
        }

        return luckyTickets;
    }

    function sort(uint[] memory data) private {
        if (data.length == 0)
            return;
        quickSort(data, 0, data.length - 1);
    }

    function quickSort(uint[] memory arr, uint left, uint right) private {
        uint i = left;
        uint j = right;
        if(i == j) return;
        uint pivot = arr[uint(left + (right - left) / 2)];
        while (i <= j) {
            while (arr[i] < pivot) i++;
            while (pivot < arr[j]) j--;
            if (i <= j) {
                (arr[i], arr[j]) = (arr[j], arr[i]);
                i++;
                j--;
            }
        }
        if (left < j)
            quickSort(arr, left, j);
        if (i < right)
            quickSort(arr, i, right);
    }

    function payTicketsPrize(uint[] memory luckyTickets) private {

        uint j;
        uint k;
        uint prize;

        uint prize1st_num = luckyTickets[0];

        sort(luckyTickets);

        for (uint i = 0 ; i < activeTicketSlotSum; i++) {
            uint beginNum = lotteryTickets[i].beginNum;
            uint endNum = lotteryTickets[i].endNum;

            for (k = j; k < luckyTickets.length; k++) {
                uint luckyNum = luckyTickets[k];

                if (luckyNum == prize1st_num) {
                    prize = prize1st;
                } else {
                    prize = prize2nd;
                }

                if (beginNum <= luckyNum && luckyNum <= endNum) {
                    address winner = lotteryTickets[i].player;
                    winner.transfer(prize);

                    emit LogPayWinnerPrize(winner, luckyNum, prize);

                    // winner would not get the interest(2% per day)
                    // for conservative wager
                    if (lotteryTickets[i].conservative) {
                        WinnerNotReturn(winner);
                    }

                    // found luckyTickets[k]
                    j = k + 1;
                } else {
                    // break on luckyTickets[k]
                    j = k;
                    break;
                }
            }

            if (j == luckyTickets.length) {
                break;
            }
        }
    }

    constructor(address addr) public {
        admin = addr;

        // create Leverage contract instance
        leverage = new Leverage();

        nextWave();
        nextBet();
    }

    function nextWave() private {
        waveNum++;
        emit LogNextWave();
    }

    function nextBet() private {

        prizePool = 0;
        roundStartup = now;

        activeTicketSlotSum = 0;
        ticketSum = 0;

        emit LogNextBet();
    }

    function() payable public {

        if (msg.sender == address(leverage)) {
            // from Leverage Contract
            return;
        }

        // value round down
        uint value = uint(msg.value / minInvestment) * minInvestment;


        if (value < minInvestment) {
            withdrawInterest(msg.sender);

        } else {
            doInvest(msg.sender, value);

            doBet(msg.sender, value, WagerType.Conservative);
        }
    }

    function takeCommission(uint value) private {
        uint commission = value * commissionPercent / 100;
        admin.transfer(commission);
    }

    function doLeverageBet(address addr, uint value) public onlyLeverage {
        if (value < minInvestment) {

            uint interest = takeInterest(addr);

            if (interest > 0)
                doBet(addr, interest, WagerType.Interest);

        } else {
            doBet(addr, value, WagerType.Aggressive);
        }
    }

    function getLeverageAddress() public view returns(address) {
        return address(leverage);
    }

}

contract Leverage {

    WinEthFree private mainContract;
    uint private constant minInvestment = 10 finney;

    constructor() public {
        mainContract = WinEthFree(msg.sender);
    }

    function() payable public {

        uint value = msg.value;
        if (value > 0) {
            address(mainContract).transfer(value);
        }

        // round down
        value = uint(value / minInvestment) * minInvestment;

        mainContract.doLeverageBet(msg.sender, value);
    }

}