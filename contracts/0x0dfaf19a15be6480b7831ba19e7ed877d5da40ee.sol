contract Owner {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function Owner(address _owner) public {
        owner = _owner;
    }

    function changeOwner(address _newOwnerAddr) public onlyOwner {
        require(_newOwnerAddr != address(0));
        owner = _newOwnerAddr;
    }
}

contract XPOT is Owner {
    
    event Game(uint _game, uint indexed _time);

    event Ticket(
        address indexed _address,
        uint indexed _game,
        uint _number,
        uint _time
    );
    
    // Game fee.
    uint8 public fee = 10;
    // Current game number.
    uint public game;
    // Ticket price.
    uint public ticketPrice = 0.01 ether;
    // New ticket price.
    uint public newPrice;
    // All-time game jackpot.
    uint public allTimeJackpot = 0;
    // All-time game players count
    uint public allTimePlayers = 0;
    
    // Game status.
    bool public isActive = true;
    // The variable that indicates game status switching.
    bool public toogleStatus = false;
    // The array of all games
    uint[] public games;
    
    // Store game jackpot.
    mapping(uint => uint) jackpot;
    // Store game players.
    mapping(uint => address[]) players;
    
    // Funds distributor address.
    address public fundsDistributor;

    /**
    * @dev Check sender address and compare it to an owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function XPOT(
        address distributor
    ) 
     public Owner(msg.sender)
    {
        fundsDistributor = distributor;
        startGame();
    }

    function() public payable {
        buyTicket(address(0));
    }

    function getPlayedGamePlayers() 
        public
        view
        returns (uint)
    {
        return getPlayersInGame(game);
    }

    function getPlayersInGame(uint playedGame) 
        public 
        view
        returns (uint)
    {
        return players[playedGame].length;
    }

    function getPlayedGameJackpot() 
        public 
        view
        returns (uint) 
    {
        return getGameJackpot(game);
    }
    
    function getGameJackpot(uint playedGame) 
        public 
        view 
        returns(uint)
    {
        return jackpot[playedGame];
    }
    
    function toogleActive() public onlyOwner() {
        if (!isActive) {
            isActive = true;
        } else {
            toogleStatus = !toogleStatus;
        }
    }
    
    function start() public onlyOwner() {
        if (players[game].length > 0) {
            pickTheWinner();
        }
        startGame();
    }

    function changeTicketPrice(uint price) 
        public 
        onlyOwner() 
    {
        newPrice = price;
    }


    /**
    * @dev Get random number.
    * @dev Random number calculation depends on block timestamp,
    * @dev difficulty, number and hash.
    *
    * @param min Minimal number.
    * @param max Maximum number.
    * @param time Timestamp.
    * @param difficulty Block difficulty.
    * @param number Block number.
    * @param bHash Block hash.
    */
    function randomNumber(
        uint min,
        uint max,
        uint time,
        uint difficulty,
        uint number,
        bytes32 bHash
    ) 
        public 
        pure 
        returns (uint) 
    {
        min ++;
        max ++;

        uint random = uint(keccak256(
            time * 
            difficulty * 
            number *
            uint(bHash)
        ))%10 + 1;
       
        uint result = uint(keccak256(random))%(min+max)-min;
        
        if (result > max) {
            result = max;
        }
        
        if (result < min) {
            result = min;
        }
        
        result--;

        return result;
    }
    
    /**
    * @dev The payable method that accepts ether and adds the player to the game.
    */
    function buyTicket(address partner) public payable {
        require(isActive);
        require(msg.value == ticketPrice);
        
        jackpot[game] += msg.value;
        
        uint playerNumber =  players[game].length;
        players[game].push(msg.sender);

        emit Ticket(msg.sender, game, playerNumber, now);
    }

    /**
    * @dev Start the new game.
    * @dev Checks ticket price changes, if exists new ticket price the price will be changed.
    * @dev Checks game status changes, if exists request for changing game status game status 
    * @dev will be changed.
    */
    function startGame() internal {
        require(isActive);

        game = block.number;
        if (newPrice != 0) {
            ticketPrice = newPrice;
            newPrice = 0;
        }
        if (toogleStatus) {
            isActive = !isActive;
            toogleStatus = false;
        }
        emit Game(game, now);
    }

    /**
    * @dev Pick the winner.
    * @dev Check game players, depends on player count provides next logic:
    * @dev - if in the game is only one player, by game rules the whole jackpot 
    * @dev without commission returns to him.
    * @dev - if more than one player smart contract randomly selects one player, 
    * @dev calculates commission and after that jackpot transfers to the winner,
    * @dev commision to founders.
    */
    function pickTheWinner() internal {
        uint winner;
        uint toPlayer;
        if (players[game].length == 1) {
            toPlayer = jackpot[game];
            players[game][0].transfer(jackpot[game]);
            winner = 0;
        } else {
            winner = randomNumber(
                0,
                players[game].length - 1,
                block.timestamp,
                block.difficulty,
                block.number,
                blockhash(block.number - 1)
            );
        
            uint distribute = jackpot[game] * fee / 100;
            toPlayer = jackpot[game] - distribute;
            players[game][winner].transfer(toPlayer);
            fundsDistributor.transfer(distribute);
        }
        
        allTimeJackpot += toPlayer;
        allTimePlayers += players[game].length;
    }
}