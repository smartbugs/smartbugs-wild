pragma solidity ^0.4.13;

contract Tiles {

    uint public constant NUM_TILES = 256;
    uint constant SIDE_LENGTH = 16;
    uint private constant STARTING_GAME_NUMBER = 1;
    uint public DEFAULT_GAME_COST = 5000000000000000;

    address private owner;

    uint public currentGameNumber;
    uint public currentGameBalance;
    uint public numTilesClaimed;
    Tile[16][16] public tiles;
    bool public gameStopped;
    uint public gameEarnings;
    bool public willChangeCost;
    uint public currentGameCost;
    uint public nextGameCost;

    mapping (address => uint) public pendingWithdrawals;
    mapping (uint => address) public gameToWinner;

    struct Tile {
        uint gameClaimed;
        address claimedBy;
    }

    event GameWon(uint indexed gameNumber, address indexed winner);
    event TileClaimed(uint indexed gameNumber, uint indexed xCoord, uint indexed yCoord, address claimedBy);
    event WinningsClaimed(address indexed claimedBy, uint indexed amountClaimed);
    event FailedToClaim(address indexed claimedBy, uint indexed amountToClaim);
    event PrintWinningInfo(bytes32 hash, uint xCoord, uint yCoord);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier gameRunning() {
        require(!gameStopped);
        _;
    }

    modifier gameNotRunning() {
        require(gameStopped == true);
        _;
    }

    function Tiles() payable {
        owner = msg.sender;
        currentGameNumber = STARTING_GAME_NUMBER;
        currentGameCost = DEFAULT_GAME_COST;
        numTilesClaimed = 0;
        gameStopped = false;
        gameEarnings = 0;
        willChangeCost = false;
        nextGameCost = DEFAULT_GAME_COST;
    }

    function cancelContract() onlyOwner returns (bool) {
        gameStopped = true;
        refundTiles();
        refundWinnings();
    }

    function getRightCoordinate(byte input) returns(uint) {
        byte val = input & byte(15);
        return uint(val);
    }

    function getLeftCoordinate(byte input) returns(uint) {
        byte val = input >> 4;
        return uint(val);
    }

    function determineWinner() private {
        bytes32 winningHash = block.blockhash(block.number - 1);
        byte winningPair = winningHash[31];
        uint256 winningX = getRightCoordinate(winningPair);
        uint256 winningY = getLeftCoordinate(winningPair);
        address winner = tiles[winningX][winningY].claimedBy;
        PrintWinningInfo(winningHash, winningX, winningY);
        GameWon(currentGameNumber, winner);
        resetGame(winner);
    }

    function claimTile(uint xCoord, uint yCoord, uint gameNumber) gameRunning payable {
        if (gameNumber != currentGameNumber || tiles[xCoord][yCoord].gameClaimed == currentGameNumber) {
            revert();
        }
        require(msg.value == currentGameCost);

        currentGameBalance += msg.value;
        tiles[xCoord][yCoord] = Tile(currentGameNumber, msg.sender);
        TileClaimed(currentGameNumber, xCoord, yCoord, msg.sender);
        numTilesClaimed += 1;
        if (numTilesClaimed == NUM_TILES) {
            determineWinner();
        }
    }

    function resetGame(address winner) private {
        uint winningAmount = uint(currentGameBalance) * uint(9) / uint(10);
        uint remainder = currentGameBalance - winningAmount;
        currentGameBalance = 0;

        gameToWinner[currentGameNumber] = winner;
        currentGameNumber++;
        numTilesClaimed = 0;

        pendingWithdrawals[winner] += winningAmount;
        gameEarnings += remainder;

        if (willChangeCost) {
            currentGameCost = nextGameCost;
            willChangeCost = false;
        }
    }

    // todo: optimize this
    function refundTiles() private {
        Tile memory currTile;
        for (uint i = 0; i < SIDE_LENGTH; i++) {
            for (uint j = 0; j < SIDE_LENGTH; j++) {
                currTile = tiles[i][j];
                if (currTile.gameClaimed == currentGameNumber) {
                    // could accumulate transactions and pay less gas
                    if (currTile.claimedBy.send(currentGameCost)) {
                        tiles[i][j] = Tile(0, 0x0);
                    }
                }
            }
        }
    }

    function refundWinnings() private {
        address currAddress;
        uint currAmount;
        for (uint i = STARTING_GAME_NUMBER; i <= currentGameNumber; i++) {
            currAddress = gameToWinner[i];
            currAmount = pendingWithdrawals[currAddress];
            if (currAmount != 0) {
                if (currAddress.send(currAmount)) {
                    pendingWithdrawals[currAddress] = 0;
                }
            }
        }
    }

    function claimWinnings() {
        if (pendingWithdrawals[msg.sender] != 0) {
            if (msg.sender.send(pendingWithdrawals[msg.sender])) {
                WinningsClaimed(msg.sender, pendingWithdrawals[msg.sender]);
                pendingWithdrawals[msg.sender] = 0;
            } else {
                FailedToClaim(msg.sender, pendingWithdrawals[msg.sender]);
            }
        }
    }

    function updateGameCost(uint newGameCost) onlyOwner returns (bool) {
        // todo: should we validate something here?
        nextGameCost = newGameCost;
        willChangeCost = true;
    }

    function claimOwnersEarnings() onlyOwner {
        if (gameEarnings != 0) {
            if (owner.send(gameEarnings)) {
                gameEarnings = 0;
            }
        }
    }
}