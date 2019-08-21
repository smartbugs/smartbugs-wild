pragma solidity ^0.4.19;


contract Owned {
    address owner;

    modifier onlyowner() {
        if (msg.sender == owner) {
            _;
        }
    }

    function Owned() internal {
        owner = msg.sender;
    }
}


contract Mortal is Owned {
    function kill() public onlyowner {
        selfdestruct(owner);
    }
}


contract Slotthereum is Mortal {

    modifier onlyuser() {
        if (tx.origin == msg.sender) {
            _;
        } else {
            revert();
        }
    }

    Game[] public games;                                // games
    mapping (address => uint) private balances;         // balances per address
    uint public numberOfGames = 0;                      // number of games
    uint private minBetAmount = 100000000000000;        // minimum amount per bet
    uint private maxBetAmount = 1000000000000000000;    // maximum amount per bet
    bytes32 private seed;
    uint private nonce = 1;

    struct Game {
        address player;
        uint id;
        uint amount;
        uint8 start;
        uint8 end;
        uint8 number;
        bool win;
        uint prize;
        bytes32 hash;
        uint blockNumber;
    }

    event MinBetAmountChanged(uint amount);
    event MaxBetAmountChanged(uint amount);

    event GameRoll(
        address indexed player,
        uint indexed gameId,
        uint8 start,
        uint8 end,
        uint amount
    );

    event GameWin(
        address indexed player,
        uint indexed gameId,
        uint8 start,
        uint8 end,
        uint8 number,
        uint amount,
        uint prize
    );

    event GameLoose(
        address indexed player,
        uint indexed gameId,
        uint8 start,
        uint8 end,
        uint8 number,
        uint amount,
        uint prize
    );

    // function assert(bool assertion) internal {
    //     if (!assertion) {
    //         revert();
    //     }
    // }

    // function add(uint x, uint y) internal constant returns (uint z) {
    //     assert((z = x + y) >= x);
    // }

    function getNumber(bytes32 hash) onlyuser internal returns (uint8) {
        nonce++;
        seed = keccak256(block.timestamp, nonce);
        return uint8(keccak256(hash, seed))%(0+9)-0;
    }

    function notify(address player, uint gameId, uint8 start, uint8 end, uint8 number, uint amount, uint prize, bool win) internal {
        if (win) {
            GameWin(
                player,
                gameId,
                start,
                end,
                number,
                amount,
                prize
            );
        } else {
            GameLoose(
                player,
                gameId,
                start,
                end,
                number,
                amount,
                prize
            );
        }
    }

    function placeBet(uint8 start, uint8 end) onlyuser public payable returns (bool) {
        if (msg.value < minBetAmount) {
            return false;
        }

        if (msg.value > maxBetAmount) {
            return false;
        }

        uint8 counter = end - start + 1;

        if (counter > 7) {
            return false;
        }

        if (counter < 1) {
            return false;
        }

        uint gameId = games.length;
        games.length++;
        numberOfGames++;

        GameRoll(msg.sender, gameId, start, end, msg.value);

        games[gameId].id = gameId;
        games[gameId].player = msg.sender;
        games[gameId].amount = msg.value;
        games[gameId].start = start;
        games[gameId].end = end;
        games[gameId].prize = 1;
        games[gameId].hash = 0x0;
        games[gameId].blockNumber = block.number;

        if (gameId > 0) {
            uint lastGameId = gameId - 1;
            if (games[lastGameId].blockNumber != games[gameId].blockNumber) {
                games[lastGameId].hash = block.blockhash(block.number - 1);
                games[lastGameId].number = getNumber(games[lastGameId].hash);

                if ((games[lastGameId].number >= games[lastGameId].start) && (games[lastGameId].number <= games[lastGameId].end)) {
                    games[lastGameId].win = true;
                    uint dec = games[lastGameId].amount / 10;
                    uint parts = 10 - counter;
                    games[lastGameId].prize = games[lastGameId].amount + dec * parts;
                }

                games[lastGameId].player.transfer(games[lastGameId].prize);
                // balances[games[lastGameId].player] = add(balances[games[lastGameId].player], games[lastGameId].prize);

                notify(
                    games[lastGameId].player,
                    lastGameId,
                    games[lastGameId].start,
                    games[lastGameId].end,
                    games[lastGameId].number,
                    games[lastGameId].amount,
                    games[lastGameId].prize,
                    games[lastGameId].win
                );

                return true;
            }
            else {
                return false;
            }
        }
    }

    function getBalance() public constant returns (uint) {
        if ((balances[msg.sender] > 0) && (balances[msg.sender] < this.balance)) {
            return balances[msg.sender];
        }
        return 0;
    }

    // function withdraw() onlyuser public returns (uint) {
    //     uint amount = getBalance();
    //     if (amount > 0) {
    //         balances[msg.sender] = 0;
    //         msg.sender.transfer(amount);
    //         return amount;
    //     }
    //     return 0;
    // }

    function ownerWithdraw(uint amount) onlyowner public returns (uint) {
        if (amount <= this.balance) {
            msg.sender.transfer(amount);
            return amount;
        }
        return 0;
    }

    function setMinBetAmount(uint _minBetAmount) onlyowner public returns (uint) {
        minBetAmount = _minBetAmount;
        MinBetAmountChanged(minBetAmount);
        return minBetAmount;
    }

    function setMaxBetAmount(uint _maxBetAmount) onlyowner public returns (uint) {
        maxBetAmount = _maxBetAmount;
        MaxBetAmountChanged(maxBetAmount);
        return maxBetAmount;
    }

    function getGameIds() public constant returns(uint[]) {
        uint[] memory ids = new uint[](games.length);
        for (uint i = 0; i < games.length; i++) {
            ids[i] = games[i].id;
        }
        return ids;
    }

    function getGamePlayer(uint gameId) public constant returns(address) {
        return games[gameId].player;
    }

    function getGameHash(uint gameId) public constant returns(bytes32) {
        return games[gameId].hash;
    }

    function getGameBlockNumber(uint gameId) public constant returns(uint) {
        return games[gameId].blockNumber;
    }

    function getGameAmount(uint gameId) public constant returns(uint) {
        return games[gameId].amount;
    }

    function getGameStart(uint gameId) public constant returns(uint8) {
        return games[gameId].start;
    }

    function getGameEnd(uint gameId) public constant returns(uint8) {
        return games[gameId].end;
    }

    function getGameNumber(uint gameId) public constant returns(uint8) {
        return games[gameId].number;
    }

    function getGameWin(uint gameId) public constant returns(bool) {
        return games[gameId].win;
    }

    function getGamePrize(uint gameId) public constant returns(uint) {
        return games[gameId].prize;
    }

    function getMinBetAmount() public constant returns(uint) {
        return minBetAmount;
    }

    function getMaxBetAmount() public constant returns(uint) {
        return maxBetAmount;
    }

    function () public payable {
    }
}