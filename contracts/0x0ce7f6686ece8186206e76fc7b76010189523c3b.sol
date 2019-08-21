pragma solidity >=0.5.0;

contract MakeYourBet {

    address payable owner;
    uint256 gameId;
    uint256 totalBank;

    bool calculatingResultPhase;

    struct Bet {
        uint256 gameId;
        uint256 totalBet;
    }

    mapping(address => Bet) public bets;
    address payable[] players;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier isNotCalculatingResultsPhase() {
        require(calculatingResultPhase == false);
        _;
    }

    modifier startCalculatingResultsPhase() {
        require(calculatingResultPhase == false);
        calculatingResultPhase = true;
        _;
        calculatingResultPhase = false;
    }

    function appendToList(address payable _addr) private {
        players.push(_addr);
    }

    constructor() public {
        gameId = 1;
        totalBank = 0;
        players.length = 0;
        owner = msg.sender;
    }

    function () external payable {
        require(msg.value > 0);
        if (bets[msg.sender].gameId == 0) {
            bets[msg.sender] = Bet(
                {gameId: gameId, totalBet: msg.value}
            );
            appendToList(msg.sender);
        } else {
            if (bets[msg.sender].gameId == gameId) {
                bets[msg.sender].totalBet += msg.value;
            } else {
                bets[msg.sender].gameId = gameId;
                bets[msg.sender].totalBet = msg.value;
                appendToList(msg.sender);
            }
        }
        totalBank += msg.value;
    }

    function getGameId() external view returns (uint256) {
        return gameId;
    }

    function getOwner() external view returns (address) {
        return owner;
    }

    function getPlayersNum() external view returns (uint256) {
        return players.length;
    }

    function getPlayerById(uint256 _id) external view returns (address) {
        require(_id >= 0 && _id < players.length);
        return players[_id];
    }

    function getPlayerBet(address _addr) external view returns (uint256) {
        if (bets[_addr].gameId != gameId) {
            return 0x0;
        }
        return bets[_addr].totalBet;
    }

    function getTotalBank() external view returns (uint256) {
        return totalBank;
    }

    function getLeader() public view returns (address payable, uint256) {
        address payable winnerAddress = address(0x0);
        for (uint256 index = 0; index < players.length; index++) {
            address payable currentAddress = players[index];
            uint256 playerGameId = bets[currentAddress].gameId;
            uint256 currentBet = bets[currentAddress].totalBet;
            if (playerGameId == gameId && currentBet > bets[winnerAddress].totalBet) {
                winnerAddress = currentAddress;
            }
        }
        return (winnerAddress, bets[winnerAddress].totalBet);
    }

    function payWinnerAndStartNewGame() external payable onlyOwner startCalculatingResultsPhase returns (bool result) {
        address payable winnerAddress;
        uint256 winnerBet;
        
        (winnerAddress, winnerBet) = getLeader();
        
        if (winnerAddress != address(0x0)) {
            uint256 totalWin = totalBank - winnerBet;
            uint256 winningFee = totalWin / 15;
            totalWin -= winningFee;
            owner.transfer(winningFee);
            winnerAddress.transfer(totalWin + winnerBet);
            result = true;
        } else {
            result = false;
        }

        gameId += 1;
        players.length = 0;
        totalBank = 0;
    }

}