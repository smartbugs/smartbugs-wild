pragma solidity ^0.4.11;

contract Roshambo {
    enum State { Unrealized, Created, Joined, Ended }
    enum Result { Unfinished, Draw, Win, Loss, Forfeit }
    enum ResultType { None, StraightUp, Tiebroken, SuperDraw } 
    struct Game {
        address player1;
        address player2;
        uint value;
        bytes32 hiddenMove1;
        uint8 move1; // 0 = not set, 1 = Rock, 2 = Paper, 3 = Scissors
        uint8 move2;
        uint gameStart;
        uint8 tiebreaker;
        uint8 tiebreaker1;
        uint8 tiebreaker2;
        State state;
        Result result;
        ResultType resultType;
    }
    
    address public owner1;
    uint8 constant feeDivisor = 100;
    uint constant revealTime = 7 days;
    bool paused;
    bool expired;
    uint gameIdCounter;
    
    event Deposit(address indexed player, uint amount);
    event Withdraw(address indexed player, uint amount);
    event GameCreated(address indexed player1, address indexed player2, uint indexed gameId, uint value, bytes32 hiddenMove1);
    event GameJoined(address indexed player1, address indexed player2, uint indexed gameId, uint value, uint8 move2, uint gameStart);
    event GameEnded(address indexed player1, address indexed player2, uint indexed gameId, uint value, Result result, ResultType resultType);
    
    mapping(address => uint) public balances;
    mapping(address => uint) public totalWon;
    mapping(address => uint) public totalLost;
    
    Game [] public games;
    mapping(address => string) public playerNames;
    mapping(uint => bool) public nameTaken;
    mapping(bytes32 => bool) public secretTaken;
    
    modifier onlyOwner { require(msg.sender == owner1); _; }
    modifier notPaused { require(!paused); _; }
    modifier notExpired { require(!expired); _; }

    function Roshambo() public {
        owner1 = msg.sender;
        paused = true;
    }

    function rand(uint8 min, uint8 max) constant internal returns (uint8){
        return uint8(block.blockhash(block.number-min))% max + min;
    }
    
    function getGames() constant internal returns (Game []) {
        return games;
    }
    
    function totalProfit(address player) constant internal returns (int) {
        if (totalLost[player] > totalWon[player]) {
            return -int(totalLost[player] - totalWon[player]);
        }
        else {
            return int(totalWon[player] - totalLost[player]);
        }
    }
    
    function createGame(bytes32 move, uint val, address player2) public
    payable notPaused notExpired returns (uint gameId) {
        deposit();
        require(balances[msg.sender] >= val);
        require(!secretTaken[move]);
        secretTaken[move] = true;
        balances[msg.sender] -= val;
        gameId = gameIdCounter;
        games.push(Game(msg.sender, player2, val, move, 0, 0, 0, 0, 0, 0, State.Created, Result(0), ResultType(0)));

        GameCreated(msg.sender, player2, gameId, val, move);
        gameIdCounter++;
    }
    
    function abortGame(uint gameId) public notPaused returns (bool success) {
        Game storage thisGame = games[gameId];
        require(thisGame.player1 == msg.sender);
        require(thisGame.state == State.Created);
        thisGame.state = State.Ended;

        GameEnded(thisGame.player1, thisGame.player2, gameId, thisGame.value, Result(0), ResultType.StraightUp);

        msg.sender.transfer(thisGame.value);
        return true;
    }
    
    function joinGame(uint gameId, uint8 move, uint8 tiebreaker) public payable notPaused returns (bool success) {
        Game storage thisGame = games[gameId];
        require(thisGame.state == State.Created);
        require(move > 0 && move <= 3);
        if (thisGame.player2 == 0x0) {
            thisGame.player2 = msg.sender;
        }
        else {
            require(thisGame.player2 == msg.sender);
        }
        require(thisGame.value == msg.value);
        thisGame.gameStart = now;
        thisGame.state = State.Joined;
        thisGame.move2 = move;
        thisGame.tiebreaker2 = tiebreaker;

        GameJoined(thisGame.player1, thisGame.player2, gameId, thisGame.value, thisGame.move2, thisGame.gameStart);
        return true;
    }
    
    function revealMove(uint gameId, uint8 move, uint8 tiebreaker, string secret) public notPaused returns (Result result) {
        Game storage thisGame = games[gameId];
        ResultType resultType = ResultType.None;
        require(thisGame.state == State.Joined);
        require(thisGame.player1 == msg.sender);
        require(thisGame.hiddenMove1 == keccak256(uint(move), uint(tiebreaker), secret));
        thisGame.move1 = move;
        thisGame.tiebreaker1 = tiebreaker;
        if (move > 0 && move <= 3) {
            result = Result(((3 + move - thisGame.move2) % 3) + 1); 
        }
        else { // Player 1 submitted invalid move
            result = Result.Loss;
        }
        thisGame.state = State.Ended;
        address winner;
        if (result != Result.Draw) {
            resultType = ResultType.StraightUp;
        }

        if (result == Result.Draw) {
            thisGame.tiebreaker = rand(1, 100);

            int8 player1Tiebreaker =  int8(thisGame.tiebreaker) - int8(thisGame.tiebreaker1);
            if(player1Tiebreaker < 0) {
                player1Tiebreaker = player1Tiebreaker * int8(-1);
            }
            int8 player2Tiebreaker = int8(thisGame.tiebreaker) - int8(thisGame.tiebreaker2);
            if(player2Tiebreaker < 0) {
                player2Tiebreaker = player2Tiebreaker * int8(-1);
            }

            if(player1Tiebreaker == player2Tiebreaker) {
                resultType = ResultType.SuperDraw;
                balances[thisGame.player1] += thisGame.value;
                balances[thisGame.player2] += thisGame.value;
            }else{
                resultType = ResultType.Tiebroken;
                if(player1Tiebreaker < player2Tiebreaker) {
                    result = Result.Win;
                }else{
                    result = Result.Loss;
                }
            }
        }
        
        if(resultType != ResultType.SuperDraw) {
            if (result == Result.Win) {
                winner = thisGame.player1;
                totalLost[thisGame.player2] += thisGame.value;
            }
            else {
                winner = thisGame.player2;
                totalLost[thisGame.player1] += thisGame.value;
            }
            uint fee = (thisGame.value) / feeDivisor;
            balances[owner1] += fee*2;
            totalWon[winner] += thisGame.value - fee*2;
            // No re-entrancy attack is possible because
            // the state has already been set to State.Ended
            winner.transfer((thisGame.value*2) - fee*2);
        }

        thisGame.result = result;
        thisGame.resultType = resultType;

        GameEnded(thisGame.player1, thisGame.player2, gameId, thisGame.value, result, resultType);
    }
    
    function forfeitGame(uint gameId) public notPaused returns (bool success) {
        Game storage thisGame = games[gameId];
        require(thisGame.state == State.Joined);
        require(thisGame.player1 == msg.sender);
        
        uint fee = (thisGame.value) / feeDivisor; 
        balances[owner1] += fee*2;
        totalLost[thisGame.player1] += thisGame.value;
        totalWon[thisGame.player2] += thisGame.value - fee*2;
        thisGame.state = State.Ended;
        thisGame.result = Result.Forfeit; // Loss for player 1

        GameEnded(thisGame.player1, thisGame.player2, gameId, thisGame.value, thisGame.result, ResultType.StraightUp);
        
        thisGame.player2.transfer((thisGame.value*2) - fee*2);
        return true;
    }
    
    function claimGame(uint gameId) public notPaused returns (bool success) {
        Game storage thisGame = games[gameId];
        require(thisGame.state == State.Joined);
        require(thisGame.player2 == msg.sender);
        require(thisGame.gameStart + revealTime < now); 
        
        uint fee = (thisGame.value) / feeDivisor;
        balances[owner1] += fee*2;
        totalLost[thisGame.player1] += thisGame.value;
        totalWon[thisGame.player2] += thisGame.value - fee*2;
        thisGame.state = State.Ended;
        thisGame.result = Result.Forfeit; // Loss for player 1
        
        GameEnded(thisGame.player1, thisGame.player2, gameId, thisGame.value, thisGame.result, ResultType.StraightUp);

        thisGame.player2.transfer((thisGame.value*2) - fee*2);
        return true;
    }
    
    function donate() public payable returns (bool success) {
        require(msg.value != 0);
        balances[owner1] += msg.value;

        return true;
    }
    function deposit() public payable returns (bool success) {
        require(msg.value != 0);
        balances[msg.sender] += msg.value;

        Deposit(msg.sender, msg.value);
        return true;
    }
    function withdraw() public returns (bool success) {
        uint amount = balances[msg.sender];
        if (amount == 0) return false;
        balances[msg.sender] = 0;
        msg.sender.transfer(amount);

        Withdraw(msg.sender, amount);
        return true;
    }
    
    function pause(bool setpause) public onlyOwner {
        paused = setpause;
    }
    
    function expire(bool setexpire) public onlyOwner {
        expired = setexpire;
    }
    
    function setOwner(address newOwner) public {
        require(msg.sender == owner1);
        owner1 = newOwner;
    }
    
}