pragma solidity ^0.4.10;

contract Slot {
    uint constant BET_EXPIRATION_BLOCKS = 250;
    uint constant MIN_BET = 0.01 ether;
    uint constant MAX_BET = 300000 ether;
    uint constant JACKPOT_PERCENT = 10;
    uint constant MINIPOT_PERCENT = 10;

    uint[][] REELS = [
                      [1,2,1,3,1,4,5,3,5,6],
                      [1,2,1,3,1,4,1,3,1,6],
                      [4,5,3,5,4,2,4,3,5,6]
                      ];

    uint[] SYMBOL_MASK = [0, 1, 2, 4, 8, 16, 32];

    uint[][] PAYTABLE = [
                         [0x010100, 2],
                         [0x010120, 4],
                         [0x010110, 4],
                         [0x040402, 8],
                         [0x040404, 8],
                         [0x080802, 12],
                         [0x080808, 12],
                         [0x202002, 16],
                         [0x020220, 16],
                         [0x202020, 100],
                         [0x020202, 9999]
                         ];

    address owner;
    address pendingOwner;
    uint acceptPrice;

    uint public pendingBetAmount;
    uint public jackpotPool;
    uint public minipotPool;
    uint public rollTimes;
    uint public minipotTimes;

    struct Roll {
        uint bet;
        uint8 lines;
        uint8 rollCount;
        uint blocknum;
        address next;
    }

    struct PartnerShare {
        address from;
        uint share;
    }

    event RollBegin(address indexed from, uint bet, uint8 lines, uint count);
    event RollEnd(address indexed from, uint bet, uint8 lines, uint32 wheel, uint win, uint minipot);

    mapping(address => Roll[]) public rolls;
    address public rollHead;
    address public rollTail;

    PartnerShare[] public partners;

    constructor () public {
        owner = msg.sender;
    }

    function setOwner(address newOwner, uint price) public {
        require (msg.sender == owner, "Only owner can set new owner.");
        require (newOwner != owner, "No need to set again.");
        pendingOwner = newOwner;
        acceptPrice = price;
    }

    function acceptOwner() payable public {
        require (msg.sender == pendingOwner, "You are not pending owner.");
        require (msg.value >= acceptPrice, "Amount not enough.");
        owner.transfer(acceptPrice);
        owner = pendingOwner;
    }

    // enable direct transfer ether to contract
    function() public payable {
        require (msg.value > 200 finney, 'Min investment required.');
        if (owner != msg.sender) {
            partners.push(PartnerShare(msg.sender, msg.value / 1 finney));
        }
    }

    function kill() external {
        require (msg.sender == owner, "Only owner can kill.");
        require (pendingBetAmount == 0, "All spins need processed befor self-destruct.");
        distribute();
        selfdestruct(owner);
    }

    function rollBlockNumber(address addr) public view returns (uint) {
        if (rolls[addr].length > 0) {
            return rolls[addr][0].blocknum;
        } else {
            return 0;
        }
    }

    function getPartnersCount() public view returns (uint) {
        return partners.length;
    }

    function jackpot() public view returns (uint) {
        return jackpotPool / 2;
    }

    function minipot() public view returns (uint) {
        return minipotPool / 2;
    }

    function roll(uint8 lines, uint8 count) public payable {
        require (rolls[msg.sender].length == 0, "Can't roll mutiple times.");

        uint betValue = msg.value / count;
        require (betValue >= MIN_BET && betValue <= MAX_BET, "Bet amount should be within range.");
        rolls[msg.sender].push(Roll(betValue, lines, count, block.number, address(0)));

        // append to roll linked list
        if (rollHead == address(0)) {
            rollHead = msg.sender;
        } else {
            rolls[rollTail][0].next = msg.sender;
        }
        rollTail = msg.sender;

        pendingBetAmount += msg.value;
        jackpotPool += msg.value * JACKPOT_PERCENT / 100;
        minipotPool += msg.value * MINIPOT_PERCENT / 100;

        emit RollBegin(msg.sender, betValue, lines, count);
    }

    function check(uint maxCount) public {
        require (maxCount > 0, 'No reason for check nothing');

        uint i = 0;
        address currentAddr = rollHead;

        while (i < maxCount && currentAddr != address(0)) {
            Roll storage rollReq = rolls[currentAddr][0];

            if (rollReq.blocknum >= block.number) {
                return;
            }

            checkRoll(currentAddr, rollReq);

            rollHead = rollReq.next;
            if (currentAddr == rollTail) {
                rollTail = address(0);
            }

            delete rolls[currentAddr];

            currentAddr = rollHead;
            i++;
        }
    }

    function checkRoll(address addr, Roll storage rollReq) private {
        uint totalWin = 0;

        if (block.number <= rollReq.blocknum + BET_EXPIRATION_BLOCKS) {
            for (uint x = 0; x < rollReq.rollCount; x++) {
                totalWin += doRoll(addr, rollReq.bet, rollReq.lines, rollReq.blocknum, pendingBetAmount + rollTimes + x);
            }
        } else {
            totalWin = rollReq.bet * rollReq.rollCount - 2300;
        }

        pendingBetAmount -= rollReq.bet * rollReq.rollCount;

        if (totalWin > 0) {
            if (address(this).balance > totalWin + 2300) {
                addr.transfer(totalWin);
            } else {
                partners.push(PartnerShare(addr, totalWin / 1 finney));
            }
        }
    }

    function doRoll(address addr, uint bet, uint8 lines, uint blocknum, uint seed) private returns (uint) {
        uint[3] memory stops;
        uint winRate;
        uint entropy;
        (stops, winRate, entropy) = calcRoll(addr, blocknum, seed);

        uint wheel = stops[0]<<16 | stops[1]<<8 | stops[2];
        uint win = bet * winRate;

        // Jackpot
        if (winRate == 9999) {
            win = jackpotPool / 2;
            jackpotPool -= win;
        }


        rollTimes++;

        uint minipotWin = 0;
        // Check minipot
        if (0xffff / (entropy >> 32 & 0xffff) > (100 * (minipotTimes + 1)) - rollTimes) {
            minipotTimes++;
            minipotWin = minipotPool / 2;
            minipotPool -= minipotWin;
        }

        emit RollEnd(addr, bet, lines, uint32(wheel), win, minipotWin);

        return win + minipotWin;
    }

    function calcRoll(address addr, uint blocknum, uint seed) public view returns (uint[3] memory stops, uint winValue, uint entropy) {
        require (block.number > blocknum, "Can't check in the same block or before.");
        require (block.number <= blocknum + BET_EXPIRATION_BLOCKS, "Can't check for too old block.");
        entropy = uint(keccak256(abi.encodePacked(addr, blockhash(blocknum), seed)));
        stops = [REELS[0][entropy % REELS[0].length],
                 REELS[1][(entropy >> 8) % REELS[1].length],
                 REELS[2][(entropy >> 16) % REELS[2].length]];
        winValue = calcPayout(stops[0], stops[1], stops[2]);
    }

    function calcPayout(uint p1, uint p2, uint p3) public view returns (uint) {
        uint line = SYMBOL_MASK[p1] << 16 | SYMBOL_MASK[p2] << 8 | SYMBOL_MASK[p3];
        uint pay = 0;

        for (uint i = 0; i < PAYTABLE.length; i++) {
            if (PAYTABLE[i][0] == line & PAYTABLE[i][0]) {
                pay = PAYTABLE[i][1];
            }
        }

        return pay;
    }

    function getBonus() public view returns (uint) {
        return address(this).balance - pendingBetAmount - jackpotPool - minipotPool;
    }

    function distribute() public returns (uint result) {
        bool isPartner = (owner == msg.sender);
        uint totalShare = 0;

        for (uint i = 0; i < partners.length; i++) {
            if (partners[i].from == msg.sender) {
                isPartner = true;
            }

            totalShare += partners[i].share;
        }

        require(isPartner, 'Only partner can distrubute bonus.');

        uint bonus = getBonus();

        if (totalShare > 0) {
            uint price = ((bonus / 10) * 6) / totalShare;

            if (price > 0) {
                for (uint j = 0; j < partners.length; j++) {
                    uint share = partners[j].share * price;
                    partners[j].from.transfer(share);
                    if (partners[j].from == msg.sender) {
                        result += share;
                    }
                }
            }

            if (price > 2 * 1 finney) {
                delete partners;
            }
        }

        uint ownerShare = (bonus / 10) * 4;
        owner.transfer(ownerShare);
        if (owner == msg.sender) {
            result += ownerShare;
        }
    }
}