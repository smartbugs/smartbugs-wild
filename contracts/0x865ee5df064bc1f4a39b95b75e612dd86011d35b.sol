pragma solidity 0.4.25;

interface IERC20 {
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
}

contract LotteryTicket {
    address owner;
    string public constant name = "LotteryTicket";
    string public constant symbol = "✓";
    event Transfer(address indexed from, address indexed to, uint256 value);
    constructor() public {
        owner = msg.sender;
    }
    function emitEvent(address addr) public {
        require(msg.sender == owner);
        emit Transfer(msg.sender, addr, 1);
    }
}

contract WinnerTicket {
    address owner;
    string public constant name = "WinnerTicket";
    string public constant symbol = "✓";
    event Transfer(address indexed from, address indexed to, uint256 value);
    constructor() public {
        owner = msg.sender;
    }
    function emitEvent(address addr) public {
        require(msg.sender == owner);
        emit Transfer(msg.sender, addr, 1);
    }
}

contract Ownable {
    address public owner;
    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract Storage {
    address game;

    mapping (address => uint256) public amount;
    mapping (uint256 => address[]) public level;
    uint256 public count;
    uint256 public maximum;

    constructor() public {
        game = msg.sender;
    }

    function purchase(address addr) public {
        require(msg.sender == game);

        amount[addr]++;
        if (amount[addr] > 1) {
            level[amount[addr]].push(addr);
            if (amount[addr] > 2) {
                for (uint256 i = 0; i < level[amount[addr] - 1].length; i++) {
                    if (level[amount[addr] - 1][i] == addr) {
                        delete level[amount[addr] - 1][i];
                        break;
                    }
                }
            } else if (amount[addr] == 2) {
                count++;
            }
            if (amount[addr] > maximum) {
                maximum = amount[addr];
            }
        }

    }

    function draw(uint256 goldenWinners) public view returns(address[] addresses) {

        addresses = new address[](goldenWinners);
        uint256 winnersCount;

        for (uint256 i = maximum; i >= 2; i--) {
            for (uint256 j = 0; j < level[i].length; j++) {
                if (level[i][j] != address(0)) {
                    addresses[winnersCount] = level[i][j];
                    winnersCount++;
                    if (winnersCount == goldenWinners) {
                        return;
                    }
                }
            }
        }

    }

}

contract RefStorage is Ownable {

    IERC20 public token;

    mapping (address => bool) public contracts;

    uint256 public prize = 0.00005 ether;
    uint256 public interval = 100;

    mapping (address => Player) public players;
    struct Player {
        uint256 tickets;
        uint256 checkpoint;
        address referrer;
    }

    event ReferrerAdded(address player, address referrer);
    event BonusSent(address recipient, uint256 amount);

    modifier restricted() {
        require(contracts[msg.sender]);
        _;
    }

    constructor() public {
        token = IERC20(address(0x9f9EFDd09e915C1950C5CA7252fa5c4F65AB049B));
    }

    function changeContracts(address contractAddr) public onlyOwner {
        contracts[contractAddr] = true;
    }

    function changePrize(uint256 newPrize) public onlyOwner {
        prize = newPrize;
    }

    function changeInterval(uint256 newInterval) public onlyOwner {
        interval = newInterval;
    }

    function newTicket() external restricted {
        players[tx.origin].tickets++;
        if (players[tx.origin].referrer != address(0) && (players[tx.origin].tickets - players[tx.origin].checkpoint) % interval == 0) {
            if (token.balanceOf(address(this)) >= prize * 2) {
                token.transfer(tx.origin, prize);
                emit BonusSent(tx.origin, prize);
                token.transfer(players[tx.origin].referrer, prize);
                emit BonusSent(players[tx.origin].referrer, prize);
            }
        }
    }

    function addReferrer(address referrer) external restricted {
        if (players[tx.origin].referrer == address(0) && players[referrer].tickets >= interval && referrer != tx.origin) {
            players[tx.origin].referrer = referrer;
            players[tx.origin].checkpoint = players[tx.origin].tickets;

            emit ReferrerAdded(tx.origin, referrer);
        }
    }

    function sendBonus(address winner) external restricted {
        if (token.balanceOf(address(this)) >= prize) {
            token.transfer(winner, prize);

            emit BonusSent(winner, prize);
        }
    }

    function withdrawERC20(address ERC20Token, address recipient) external onlyOwner {
        uint256 amount = IERC20(ERC20Token).balanceOf(address(this));
        IERC20(ERC20Token).transfer(recipient, amount);
    }

    function ticketsOf(address player) public view returns(uint256) {
        return players[player].tickets;
    }

    function referrerOf(address player) public view returns(address) {
        return players[player].referrer;
    }
}

contract Lottery1ETH is Ownable {

    Storage public x;
    RefStorage public RS;
    LotteryTicket public LT;
    WinnerTicket public WT;

    uint256 constant public PRICE = 0.01 ether;

    address[] public players;

    uint256 public limit = 100;

    uint256 public futureblock;

    uint256 public gameCount;

    bool public paused;

    uint256[] silver    = [10, 0.02 ether];
    uint256[] gold      = [2,  0.05 ether];
    uint256[] brilliant = [1,  0.50 ether];

    event NewPlayer(address indexed addr, uint256 indexed gameCount);
    event SilverWinner(address indexed addr, uint256 prize, uint256 indexed gameCount);
    event GoldenWinner(address indexed addr, uint256 prize, uint256 indexed gameCount);
    event BrilliantWinner(address indexed addr, uint256 prize, uint256 indexed gameCount);
    event txCostRefunded(address indexed addr, uint256 amount);
    event FeePayed(address indexed owner, uint256 amount);

    modifier notFromContract() {
        address addr = msg.sender;
        uint256 size;
        assembly { size := extcodesize(addr) }
        require(size <= 0);
        _;
    }

    constructor(address RS_Addr) public {
        x = new Storage();
        LT = new LotteryTicket();
        WT = new WinnerTicket();
        RS = RefStorage(RS_Addr);
        gameCount++;
    }

    function() public payable notFromContract {

        if (players.length == 0 && paused) {
            revert();
        }

        if (players.length == limit) {
            drawing();

            if (players.length == 0 && paused || msg.value < PRICE) {
                msg.sender.transfer(msg.value);
                return;
            }

        }

        require(msg.value >= PRICE);

        if (msg.value > PRICE) {
            msg.sender.transfer(msg.value - PRICE);
        }

        if (msg.data.length != 0) {
            RS.addReferrer(bytesToAddress(bytes(msg.data)));
        }

        players.push(msg.sender);
        x.purchase(msg.sender);
        RS.newTicket();
        LT.emitEvent(msg.sender);
        emit NewPlayer(msg.sender, gameCount);

        if (players.length == limit) {
            drawing();
        }

    }

    function drawing() internal {

        require(block.number > futureblock, "Awaiting for a future block");

        if (block.number >= futureblock + 240) {
            futureblock = block.number + 10;
            return;
        }

        uint256 gas = gasleft();

        for (uint256 i = 0; i < silver[0]; i++) {
            address winner = players[uint((blockhash(futureblock - 1 - i))) % players.length];
            winner.send(silver[1]);
            WT.emitEvent(winner);
            emit SilverWinner(winner, silver[1], gameCount);
        }

        uint256 goldenWinners = gold[0];
        uint256 goldenPrize = gold[1];
        if (x.count() < gold[0]) {
            goldenWinners = x.count();
            goldenPrize = gold[0] * gold[1] / x.count();
        }
        if (goldenWinners != 0) {
            address[] memory addresses = x.draw(goldenWinners);
            for (uint256 k = 0; k < addresses.length; k++) {
                addresses[k].send(goldenPrize);
                RS.sendBonus(addresses[k]);
                WT.emitEvent(addresses[k]);
                emit GoldenWinner(addresses[k], goldenPrize, gameCount);
            }
        }

        uint256 laps = 7;
        uint256 winnerIdx;
        uint256 indexes = players.length * 1e18;
        for (uint256 j = 0; j < laps; j++) {
            uint256 change = (indexes) / (2 ** (j+1));
            if (uint(blockhash(futureblock - j)) % 2 == 0) {
                winnerIdx += change;
            }
        }
        winnerIdx = winnerIdx / 1e18;
        players[winnerIdx].send(brilliant[1]);
        WT.emitEvent(players[winnerIdx]);
        emit BrilliantWinner(players[winnerIdx], brilliant[1], gameCount);

        players.length = 0;
        futureblock = 0;
        x = new Storage();
        gameCount++;

        uint256 txCost = tx.gasprice * (gas - gasleft());
        msg.sender.send(txCost);
        emit txCostRefunded(msg.sender, txCost);

        uint256 fee = address(this).balance - msg.value;
        owner.send(fee);
        emit FeePayed(owner, fee);

    }

    function pause() public onlyOwner {
        paused = true;
    }

    function unpause() public onlyOwner {
        paused = false;
    }

    function withdrawERC20(address ERC20Token, address recipient) external onlyOwner {
        uint256 amount = IERC20(ERC20Token).balanceOf(address(this));
        IERC20(ERC20Token).transfer(recipient, amount);
    }

    function bytesToAddress(bytes source) internal pure returns(address parsedReferrer) {
        assembly {
            parsedReferrer := mload(add(source,0x14))
        }
        return parsedReferrer;
    }

    function amountOfPlayers() public view returns(uint) {
        return players.length;
    }

    function referrerOf(address player) external view returns(address) {
        return RS.referrerOf(player);
    }

    function ticketsOf(address player) external view returns(uint256) {
        return RS.ticketsOf(player);
    }

}