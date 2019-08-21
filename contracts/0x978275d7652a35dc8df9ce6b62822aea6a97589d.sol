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