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

contract Accessibility {
    address internal owner;
    modifier onlyOwner() {
        require(msg.sender == owner, "access denied");
        _;
    }

    modifier isHuman() {
        address _addr = msg.sender;
        uint _codeLength;

        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }
}

contract SicBo is Accessibility {
    // using SafeMath for *;

    struct Record {
        uint blockNum;
        address player;
        uint8[] index;
        uint16[] bet;
    }

    uint public pWagerPrice = 10 finney;
    uint public pMaxWins = 5 ether;

    uint public seqId = 0;
    uint public drawId = 0;

    mapping(uint => Record) private gRecords;

    function() payable public {
        gCroupiers[msg.sender] = true;
    }

    mapping(address => bool) private gCroupiers;

    modifier onlyCroupier {
        require(gCroupiers[msg.sender] == true, "OnlyCroupier methods called by non-croupier.");
        _;
    }

    function setCroupier(address addr) external onlyOwner {
        gCroupiers[addr] = true;
    }

    function setMaxWin(uint value) external onlyCroupier {
        pMaxWins = value;
    }

    function setWagerPrice(uint value) external onlyCroupier {
        pWagerPrice = value;
    }

    function withdraw(address receive, uint value) external onlyOwner {
        require(address(this).balance >= value, "no enough balance");
        receive.transfer(value);
    }

    function sortRandomNums() private view returns(uint[] memory) {

        uint random = uint(keccak256(abi.encodePacked(blockhash(block.number - 1), block.difficulty, block.coinbase, now)));

        uint[] memory nums = new uint[](3);
        nums[0] = (random & 0xFFFFFFFFFFFFFFFF) % 6 + 1;
        nums[1] = ((random >> 64) & 0xFFFFFFFFFFFFFFFF) % 6 + 1;
        nums[2] = (random >> 128) % 6 + 1;

        sort(nums);
        return(nums);
    }

    function sort(uint[] memory data) private pure {
        uint temp;
        if (data[0] > data[1]) {
            temp = data[0];
            data[0] = data[1];
            data[1] = temp;
        }

        if (data[1] > data[2]) {
            temp = data[1];
            data[1] = data[2];
            data[2] = temp;
        }

        if (data[0] > data[1]) {
            temp = data[0];
            data[0] = data[1];
            data[1] = temp;
        }
    }

    function betMatch(uint8[] memory index, uint16[] memory value, uint[] memory nums) private pure returns(uint win) {
        uint sum = nums[0] + nums[1] + nums[2];

        uint wager;
        uint matched;
        uint i;
        uint k;

        for (uint j = 0; j < index.length; j++) {
            i = index[j];
            wager = value[j];

            if (wager == 0)
                continue;

            if (i == 0) {
                // sum: 3 - 10, odds: 1
                if (sum < 11 && (nums[0] != nums[1] || nums[1] != nums[2])) {
                    win += wager * 2;
                }
            } else if (i == 1) {
                // sum: 11 - 18, odds: 1
                if (sum > 10 && (nums[0] != nums[1] || nums[1] != nums[2])) {
                    win += wager * 2;
                }
            } else if (i == 2) {
                // num: [1, 1, x], odds: 10
                if (nums[0] == 1 && nums[1] == 1) {
                    win += wager * 11;
                }
            } else if (i == 3) {
                // num: [2, 2, x], odds: 10
                if ((nums[0] == 2 && nums[1] == 2) || (nums[1] == 2 && nums[2] == 2)) {
                    win += wager * 11;
                }
            } else if (i == 4) {
                // num: [3, 3, x], odds: 10
                if ((nums[0] == 3 && nums[1] == 3) || (nums[1] == 3 && nums[2] == 3)) {
                    win += wager * 11;
                }
            } else if (i == 5) {
                // num: [4, 4, x], odds: 10
                if ((nums[0] == 4 && nums[1] == 4) || (nums[1] == 4 && nums[2] == 4)) {
                    win += wager * 11;
                }
            } else if (i == 6) {
                // num: [5, 5, x], odds: 10
                if ((nums[0] == 5 && nums[1] == 5) || (nums[1] == 5 && nums[2] == 5)) {
                    win += wager * 11;
                }
            } else if (i == 7) {
                // num: [6, 6, x], odds: 10
                if ((nums[0] == 6 && nums[1] == 6) || (nums[1] == 6 && nums[2] == 6)) {
                    win += wager * 11;
                }
            } else if (i == 8) {
                // num: [1, 1, 1], odds: 180
                if (sum == 3) {
                    win += wager * 181;
                }
            } else if (i == 9) {
                // num: [2, 2, 2], odds: 180
                if (nums[0] == 2 && nums[1] == 2 && nums[2] == 2) {
                    win += wager * 181;
                }
            } else if (i == 10) {
                // num: [3, 3, 3], odds: 180
                if (nums[0] == 3 && nums[1] == 3 && nums[2] == 3) {
                    win += wager * 181;
                }
            } else if (i == 11) {
                // num: [4, 4, 4], odds: 180
                if (nums[0] == 4 && nums[1] == 4 && nums[2] == 4) {
                    win += wager * 181;
                }
            } else if (i == 12) {
                // num: [5, 5, 5], odds: 180
                if (nums[0] == 5 && nums[1] == 5 && nums[2] == 5) {
                    win += wager * 181;
                }
            } else if (i == 13) {
                // num: [6, 6, 6], odds: 180
                if (sum == 18) {
                    win += wager * 181;
                }
            } else if (i == 14) {
                // num: [x, x, x], odds: 30
                if (nums[0] == nums[1] && nums[1] == nums[2]) {
                    win += wager * 31;
                }
            } else if (i == 15) {
                // sum: 4, odds: 60
                if (sum == 4) {
                    win += wager * 61;
                }
            } else if (i == 16) {
                // sum: 5, odds: 30
                if (sum == 5) {
                    win += wager * 31;
                }
            } else if (i == 17) {
                // sum: 6, odds: 18
                if (sum == 6) {
                    win += wager * 19;
                }
            } else if (i == 18) {
                // sum: 7, odds: 12
                if (sum == 7) {
                    win += wager * 13;
                }
            } else if (i == 19) {
                // sum: 8, odds: 8
                if (sum == 8) {
                    win += wager * 9;
                }
            } else if (i == 20) {
                // sum: 9, odds: 6
                if (sum == 9) {
                    win += wager * 7;
                }
            } else if (i == 21) {
                // sum: 10, odds: 6
                if (sum == 10) {
                    win += wager * 7;
                }
            } else if (i == 22) {
                // sum: 11, odds: 6
                if (sum == 11) {
                    win += wager * 7;
                }
            } else if (i == 23) {
                // sum: 12, odds: 6
                if (sum == 12) {
                    win += wager * 7;
                }
            } else if (i == 24) {
                // sum: 13, odds: 8
                if (sum == 13) {
                    win += wager * 9;
                }
            } else if (i == 25) {
                // sum: 14, odds: 12
                if (sum == 14) {
                    win += wager * 13;
                }
            } else if (i == 26) {
                // sum: 15, odds: 18
                if (sum == 15) {
                    win += wager * 19;
                }
            } else if (i == 27) {
                // sum: 16, odds: 30
                if (sum == 16) {
                    win += wager * 31;
                }
            } else if (i == 28) {
                // sum: 17, odds: 60
                if (sum == 17) {
                    win += wager * 61;
                }
            } else if (i == 29) {
                // num: [1, 2, x], odds: 5
                if (nums[0] == 1 && (nums[1] == 2 || nums[2] == 2)) {
                    win += wager * 6;
                }
            } else if (i == 30) {
                // num: [1, 3, x], odds: 5
                if (nums[0] == 1 && (nums[1] == 3 || nums[2] == 3)) {
                    win += wager * 6;
                }
            } else if (i == 31) {
                // num: [1, 4, x], odds: 5
                if (nums[0] == 1 && (nums[1] == 4 || nums[2] == 4)) {
                    win += wager * 6;
                }
            } else if (i == 32) {
                // num: [1, 5, x], odds: 5
                if (nums[0] == 1 && (nums[1] == 5 || nums[2] == 5)) {
                    win += wager * 6;
                }
            } else if (i == 33) {
                // num: [1, 6, x], odds: 5
                if (nums[0] == 1 && (nums[1] == 6 || nums[2] == 6)) {
                    win += wager * 6;
                }
            } else if (i == 34) {
                // num: [2, 3, x], odds: 5
                if ((nums[0] == 2 && nums[1] == 3) || (nums[1] == 2 && nums[2] == 3)) {
                    win += wager * 6;
                }
            } else if (i == 35) {
                // num: [2, 4, x], odds: 5
                if ((nums[0] == 2 && nums[1] == 4) || (nums[1] == 2 && nums[2] == 4) || (nums[0] == 2 && nums[2] == 4)) {
                    win += wager * 6;
                }
            } else if (i == 36) {
                // num: [2, 5, x], odds: 5
                if ((nums[0] == 2 && nums[1] == 5) || (nums[1] == 2 && nums[2] == 5) || (nums[0] == 2 && nums[2] == 5)) {
                    win += wager * 6;
                }
            } else if (i == 37) {
                // num: [2, 6, x], odds: 5
                if ((nums[0] == 2 && nums[1] == 6) || (nums[1] == 2 && nums[2] == 6) || (nums[0] == 2 && nums[2] == 6)) {
                    win += wager * 6;
                }
            } else if (i == 38) {
                // num: [3, 4, x], odds: 5
                if ((nums[0] == 3 && nums[1] == 4) || (nums[1] == 3 && nums[2] == 4)) {
                    win += wager * 6;
                }
            } else if (i == 39) {
                // num: [3, 5, x], odds: 5
                if ((nums[0] == 3 && nums[1] == 5) || (nums[1] == 3 && nums[2] == 5) || (nums[0] == 3 && nums[2] == 5)) {
                    win += wager * 6;
                }
            } else if (i == 40) {
                // num: [3, 6, x], odds: 5
                if ((nums[0] == 3 && nums[1] == 6) || (nums[1] == 3 && nums[2] == 6) || (nums[0] == 3 && nums[2] == 6)) {
                    win += wager * 6;
                }
            } else if (i == 41) {
                // num: [4, 5, x], odds: 5
                if ((nums[0] == 4 && nums[1] == 5) || (nums[1] == 4 && nums[2] == 5)) {
                    win += wager * 6;
                }
            } else if (i == 42) {
                // num: [4, 6, x], odds: 5
                if ((nums[0] == 4 && nums[1] == 6) || (nums[1] == 4 && nums[2] == 6) || (nums[0] == 4 && nums[2] == 6)) {
                    win += wager * 6;
                }
            } else if (i == 43) {
                // num: [5, 6, x], odds: 5
                if ((nums[0] == 5 && nums[1] == 6) || (nums[1] == 5 && nums[2] == 6)) {
                    win += wager * 6;
                }
            } else if (i == 44) {
                // num: num of 1, odds: num of 1
                matched = 0;
                for (k = 0; k < 3; k++) {
                    if (nums[k] == 1) {
                        matched += 1;
                    }
                }
                if (matched > 0) {
                    win += wager * (matched + 1);
                }
            } else if (i == 45) {
                // num: num of 2, odds: num of 2
                matched = 0;
                for (k = 0; k < 3; k++) {
                    if (nums[k] == 2) {
                        matched += 1;
                    }
                }
                if (matched > 0) {
                    win += wager * (matched + 1);
                }
            } else if (i == 46) {
                // num: num of 3, odds: num of 3
                matched = 0;
                for (k = 0; k < 3; k++) {
                    if (nums[k] == 3) {
                        matched += 1;
                    }
                }
                if (matched > 0) {
                    win += wager * (matched + 1);
                }
            } else if (i == 47) {
                // num: num of 4, odds: num of 4
                matched = 0;
                for (k = 0; k < 3; k++) {
                    if (nums[k] == 4) {
                        matched += 1;
                    }
                }
                if (matched > 0) {
                    win += wager * (matched + 1);
                }
            } else if (i == 48) {
                // num: num of 5, odds: num of 5
                matched = 0;
                for (k = 0; k < 3; k++) {
                    if (nums[k] == 5) {
                        matched += 1;
                    }
                }
                if (matched > 0) {
                    win += wager * (matched + 1);
                }
            } else {
                // num: num of 6, odds: num of 6
                matched = 0;
                for (k = 0; k < 3; k++) {
                    if (nums[k] == 6) {
                        matched += 1;
                    }
                }
                if (matched > 0) {
                    win += wager * (matched + 1);
                }
            }
        }
    }

    event LogBet(address, uint8[], uint16[], uint[], uint);

    function doBet(uint8[] memory index, uint16[] memory bet) isHuman() payable public {
        uint value = msg.value;
        address sender = msg.sender;

        require(value >= pWagerPrice, "too little wager");
        require(index.length == bet.length, "wrong params");
        require(address(this).balance >= pMaxWins, "out of balance");

        uint wagers;
        uint8 j;

        for (uint8 i = 0; i < index.length; i++) {
            j = index[i];
            require(j >= 0 && j < 50, "wrong index");
            wagers += bet[i];
        }
        require(value / pWagerPrice == wagers, "wrong bet");

        uint id = seqId++;

        gRecords[id].blockNum = block.number;
        gRecords[id].player = sender;
        gRecords[id].index = index;
        gRecords[id].bet = bet;
    }

    function drawLottery(address player, uint8[] memory index, uint16[] memory bet, uint[] memory nums) private {
        uint wins;
        uint maxWins = pMaxWins / pWagerPrice;

        wins = betMatch(index, bet, nums);

        if (wins > 0) {
            if ( wins > maxWins) {
                wins = maxWins;
            }

            player.transfer(wins * pWagerPrice);
        }

        emit LogBet(player, index, bet, nums, wins);
    }

    function settleBet() external onlyCroupier {
        uint[] memory nums = sortRandomNums();

        if (drawId == seqId)
            return;

        for (uint i = drawId; i < seqId && gRecords[i].blockNum < block.number; i++) {
            drawLottery(gRecords[i].player, gRecords[i].index, gRecords[i].bet, nums);
        }
        drawId = i;
    }
}