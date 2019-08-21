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

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract PIPOT is Owner {
    using SafeMath for uint256;
    event Game(uint _game, uint indexed _time);
    event ChangePrice(uint _price);
    event Ticket(
        address indexed _address,
        uint indexed _game,
        uint _number,
        uint _time,
        uint _price
    );
    
    event ChangeFee(uint _fee);
    event Winner(address _winnerAddress, uint _price, uint _jackpot);
    event Lose(uint _price, uint _currentJackpot);
    
    // Game fee.
    uint public fee = 20;
    // Current game number.
    uint public game;
    // Ticket price.
    uint public ticketPrice = 0.1 ether;
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
    mapping(uint => mapping(uint => address[])) orders;

    
    // Funds distributor address.
    address public fundsDistributor;

    /**
    * @dev Check sender address and compare it to an owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function PIPOT(
        address distributor
    )
    public Owner(msg.sender)
    {
        fundsDistributor = distributor;
        startGame();
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
    
    function start(uint winPrice) public onlyOwner() {
        if (players[game].length > 0) {
            pickTheWinner(winPrice);
        }
        startGame();
    }

    function changeTicketPrice(uint price) 
        public 
        onlyOwner() 
    {
        ticketPrice = price;
        emit ChangePrice(price);
    }
    
    function changeFee(uint _fee) 
        public 
        onlyOwner() 
    {
        fee = _fee;
        emit ChangeFee(_fee);
    }
    
    function buyTicket(uint betPrice) public payable {
        require(isActive);
        require(msg.value == ticketPrice);
        
        
        uint playerNumber =  players[game].length;
        
        players[game].push(msg.sender);
        orders[game][betPrice].push(msg.sender);
        
        uint distribute = msg.value * fee / 100;
        
        jackpot[game] += (msg.value - distribute);
        
        fundsDistributor.transfer(distribute);
        
        emit Ticket(msg.sender, game, playerNumber, now, betPrice);
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
        if (toogleStatus) {
            isActive = !isActive;
            toogleStatus = false;
        }
        emit Game(game, now);
    }

    function pickTheWinner(uint winPrice) internal {
        
        uint toPlayer;
        
        toPlayer = jackpot[game]/orders[game][winPrice].length;
        
        if(orders[game][winPrice].length > 0){
            for(uint i = 0; i < orders[game][winPrice].length;i++){
                orders[game][winPrice][i].transfer(toPlayer);
                emit Winner(orders[game][winPrice][i], winPrice, toPlayer);
            }   
        }else{
            emit Lose(winPrice, jackpot[game]);
        }
        
        allTimeJackpot += toPlayer;
        allTimePlayers += players[game].length;
    }
}