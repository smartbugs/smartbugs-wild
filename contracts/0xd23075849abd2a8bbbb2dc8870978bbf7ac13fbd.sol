pragma solidity ^0.4.16;

interface Game {
    event GameStarted(uint betAmount);
    event NewPlayerAdded(uint numPlayers, uint prizeAmount);
    event GameFinished(address winner);
    
    function () public payable;                                   //Participate in game. Proxy for play method
    function play() public payable;                               //Participate in game.
    function getPrizeAmount() public constant returns (uint);     //Get potential or actual prize amount
    function getNumWinners() public constant returns(uint, uint);
    function getPlayers() public constant returns(address[]);           //Get full list of players
    function getWinners() public view returns(address[] memory players,
                                                uint[] memory prizes);  //Get winners. Accessable only when finished
    function getStat() public constant returns(uint, uint, uint);       //Short stat on game
    
    function calcaultePrizes() public returns (uint[]);
    
    function finish() public;                        //Closes game chooses winner
    
    function revoke() public;                        //Stop game and return money to players
    // function move(address nextGame);              //Move players bets to another game
}

library TicketLib {
    struct Ticket {
        bool is_winner;
        bool is_active;
        uint block_number;
        uint block_time;
        uint num_votes;
        uint prize;
    }
}

contract UnilotPrizeCalculator {
    //Calculation constants
    uint  constant accuracy                   = 1000000000000000000;
    uint  constant MAX_X_FOR_Y                = 195;  // 19.5
    
    uint  constant minPrizeCoeficent          = 1;
    uint  constant percentOfWinners           = 5;    // 5%
    uint  constant percentOfFixedPrizeWinners = 20;   // 20%
    uint  constant gameCommision              = 20;   // 20%
    uint  constant bonusGameCommision         = 5;    // 5%
    uint  constant tokenHolerGameCommision    = 5;    // 5%
    // End Calculation constants
    
    event Debug(uint);
    
    function getPrizeAmount(uint totalAmount)
        public
        pure
        returns (uint result)
    {
        uint totalCommision = gameCommision
                            + bonusGameCommision
                            + tokenHolerGameCommision;
        
        //Calculation is odd on purpose.  It is a sort of ceiling effect to
        // maximize amount of prize
        result = ( totalAmount - ( ( totalAmount * totalCommision) / 100) );
        
        return result;
    }
    
    function getNumWinners(uint numPlayers)
        public
        pure
        returns (uint numWinners, uint numFixedAmountWinners)
    {
        // Calculation is odd on purpose. It is a sort of ceiling effect to
        // maximize number of winners
        uint totaNumlWinners = ( numPlayers - ( (numPlayers * ( 100 - percentOfWinners ) ) / 100 ) );
        
        
        numFixedAmountWinners = (totaNumlWinners * percentOfFixedPrizeWinners) / 100;
        numWinners = totaNumlWinners - numFixedAmountWinners;
        
        return (numWinners, numFixedAmountWinners);
    }
    
    function calcaultePrizes(uint bet, uint numPlayers)
        public
        pure
        returns (uint[50] memory prizes)
    {
        var (numWinners, numFixedAmountWinners) = getNumWinners(numPlayers);
        
        require( uint(numWinners + numFixedAmountWinners) <= prizes.length );
        
        uint[] memory y = new uint[]((numWinners - 1));
        uint z = 0; // Sum of all Y values
        
        if ( numWinners == 1 ) {
            prizes[0] = getPrizeAmount(uint(bet*numPlayers));
            
            return prizes;
        } else if ( numWinners < 1 ) {
            return prizes;
        }
        
        for (uint i = 0; i < y.length; i++) {
            y[i] = formula( (calculateStep(numWinners) * i) );
            z += y[i];
        }
        
        bool stop = false;
        
        for (i = 0; i < 10; i++) {
            uint[5] memory chunk = distributePrizeCalculation(
                i, z, y, numPlayers, bet);
            
            for ( uint j = 0; j < chunk.length; j++ ) {
                if ( ( (i * chunk.length) + j ) >= ( numWinners + numFixedAmountWinners ) ) {
                    stop = true;
                    break;
                }
                
                prizes[ (i * chunk.length) + j ] = chunk[j];
            }
            
            if ( stop ) {
                break;
            }
        }
        
        return prizes;
    }
    
    function distributePrizeCalculation (uint chunkNumber, uint z, uint[] memory y, uint totalNumPlayers, uint bet)
        private
        pure
        returns (uint[5] memory prizes)
    {
        var(numWinners, numFixedAmountWinners) = getNumWinners(totalNumPlayers);
        uint prizeAmountForDeligation = getPrizeAmount( (totalNumPlayers * bet) );
        prizeAmountForDeligation -= uint( ( bet * minPrizeCoeficent ) * uint( numWinners + numFixedAmountWinners ) );
        
        uint mainWinnerBaseAmount = ( (prizeAmountForDeligation * accuracy) / ( ( ( z * accuracy ) / ( 2 * y[0] ) ) + ( 1 * accuracy ) ) );
        uint undeligatedAmount    = prizeAmountForDeligation;
        
        uint startPoint = chunkNumber * prizes.length;
        
        for ( uint i = 0; i < prizes.length; i++ ) {
            if ( i >= uint(numWinners + numFixedAmountWinners) ) {
                break;
            }
            prizes[ i ] = (bet * minPrizeCoeficent);
            uint extraPrize = 0;
            
            if ( i == ( numWinners - 1 ) ) {
                extraPrize = undeligatedAmount;
            } else if ( i == 0 && chunkNumber == 0 ) {
                extraPrize = mainWinnerBaseAmount;
            } else if ( ( startPoint + i ) < numWinners ) {
                extraPrize = ( ( y[ ( startPoint + i ) - 1 ] * (prizeAmountForDeligation - mainWinnerBaseAmount) ) / z);
            }
            
            prizes[ i ] += extraPrize;
            undeligatedAmount -= extraPrize;
        }
        
        return prizes;
    }
    
    function formula(uint x)
        public
        pure
        returns (uint y)
    {
        y = ( (1 * accuracy**2) / (x + (5*accuracy/10))) - ((5 * accuracy) / 100);
        
        return y;
    }
    
    function calculateStep(uint numWinners)
        public
        pure
        returns(uint step)
    {
        step = ( MAX_X_FOR_Y * accuracy / 10 ) / numWinners;
        
        return step;
    }
}

contract BaseUnilotGame is Game {
    enum State {
        ACTIVE,
        ENDED,
        REVOKING,
        REVOKED,
        MOVED
    }
    
    event PrizeResultCalculated(uint size, uint[] prizes);
    
    State state;
    address administrator;
    uint bet;
    
    mapping (address => TicketLib.Ticket) internal tickets;
    address[] internal ticketIndex;
    
    UnilotPrizeCalculator calculator;
    
    //Modifiers
    modifier onlyAdministrator() {
        require(msg.sender == administrator);
        _;
    }
    
    modifier onlyPlayer() {
        require(msg.sender != administrator);
        _;
    }
    
    modifier validBet() {
        require(msg.value == bet);
        _;
    }
    
    modifier activeGame() {
        require(state == State.ACTIVE);
        _;
    }
    
    modifier inactiveGame() {
        require(state != State.ACTIVE);
        _;
    }
    
    modifier finishedGame() {
        require(state == State.ENDED);
        _;
    }
    
    //Private methods
    
    
    function ()
        public
        payable
        validBet
        onlyPlayer
    {
        play();
    }
    
    function play() public payable;
    
    function getState()
        public
        view
        returns(State)
    {
        return state;
    }
    
    function getBet()
        public
        view
        returns (uint)
    {
        return bet;
    }
    
    function getPlayers()
        public
        constant
        returns(address[])
    {
        return ticketIndex;
    }
    
    function getPlayerDetails(address player)
        public
        view
        inactiveGame
        returns (bool, bool, uint, uint, uint, uint)
    {
        TicketLib.Ticket memory ticket = tickets[player];
        
        return (ticket.is_winner, ticket.is_active,
        ticket.block_number, ticket.block_time, ticket.num_votes, ticket.prize);
    }
    
    function getWinners()
        public
        view
        finishedGame
        returns(address[] memory players, uint[] memory prizes)
    {
        var(numWinners, numFixedAmountWinners) = getNumWinners();
        uint totalNumWinners = numWinners + numFixedAmountWinners;
        players = new address[](totalNumWinners);
        prizes = new uint[](totalNumWinners);
        
        uint index = 0;
        
        for (uint i = 0; i < ticketIndex.length; i++) {
            if (tickets[ticketIndex[i]].is_winner == true) {
                players[index] = ticketIndex[i];
                prizes[index] = tickets[ticketIndex[i]].prize;
                index++;
            }
        }
        
        return (players, prizes);
    }
    
    function getNumWinners()
        public
        constant
        returns (uint, uint)
    {
        var(numWinners, numFixedAmountWinners) = calculator.getNumWinners(ticketIndex.length);

        return (numWinners, numFixedAmountWinners);
    }
    
    function getPrizeAmount()
        public
        constant
        returns (uint result)
    {
        uint totalAmount = this.balance;
        
        if ( state == State.ENDED ) {
            totalAmount = bet * ticketIndex.length;
        }
        
        result = calculator.getPrizeAmount(totalAmount);
        
        return result;
    }
    
    function getStat()
        public
        constant
        returns ( uint, uint, uint )
    {
        var (numWinners, numFixedAmountWinners) = getNumWinners();
        return (ticketIndex.length, getPrizeAmount(), uint(numWinners + numFixedAmountWinners));
    }

    function calcaultePrizes()
        public
        returns(uint[] memory result)
    {
        var(numWinners, numFixedAmountWinners) = getNumWinners();
        uint totalNumWinners = ( numWinners + numFixedAmountWinners );
        result = new uint[]( totalNumWinners );
        
        
        uint[50] memory prizes = calculator.calcaultePrizes(
        bet, ticketIndex.length);
        
        for (uint i = 0; i < totalNumWinners; i++) {
            result[i] = prizes[i];
        }
        
        return result;
    }
    
    function revoke()
        public
        onlyAdministrator
        activeGame
    {
        for (uint i = 0; i < ticketIndex.length; i++) {
            tickets[ticketIndex[i]].is_active = false;
            ticketIndex[i].transfer(bet);
        }
        
        state = State.REVOKED;
    }
}

contract UnilotTailEther is BaseUnilotGame {
    
    uint winnerIndex;
    
    //Public methods
    function UnilotTailEther(uint betAmount, address calculatorContractAddress)
        public
    {
        state = State.ACTIVE;
        administrator = msg.sender;
        bet = betAmount;
        
        calculator = UnilotPrizeCalculator(calculatorContractAddress);
        
        GameStarted(betAmount);
    }
    
    function play()
        public
        payable
        validBet
        onlyPlayer
    {
        require(tickets[msg.sender].block_number == 0);
        require(ticketIndex.length < 200);
        
        tickets[msg.sender].is_winner    = false;
        tickets[msg.sender].is_active    = true;
        tickets[msg.sender].block_number = block.number;
        tickets[msg.sender].block_time   = block.timestamp;
        tickets[msg.sender].num_votes    = 0;
        
        ticketIndex.push(msg.sender);
        
        NewPlayerAdded(ticketIndex.length, getPrizeAmount());
    }
    
    function finish()
        public
        onlyAdministrator
        activeGame
    {
        uint max_votes;
        
        for (uint i = 0; i < ticketIndex.length; i++) {
            TicketLib.Ticket memory ticket = tickets[ticketIndex[i]];
            uint vote = ( ( ticket.block_number * ticket.block_time ) + uint(ticketIndex[i]) ) % ticketIndex.length;
            
            tickets[ticketIndex[vote]].num_votes += 1;
            uint ticketNumVotes = tickets[ticketIndex[vote]].num_votes;
            
            if ( ticketNumVotes > max_votes ) {
                max_votes = ticketNumVotes;
                winnerIndex = vote;
            }
        }
        
        uint[] memory prizes = calcaultePrizes();
        
        uint lastId = winnerIndex;
        
        for ( i = 0; i < prizes.length; i++ ) {
            if (tickets[ticketIndex[lastId]].is_active) {
                tickets[ticketIndex[lastId]].prize = prizes[i];
                tickets[ticketIndex[lastId]].is_winner = true;
                ticketIndex[lastId].transfer(prizes[i]);
            } else {
                i--;
            }
            
            if ( lastId <= 0 ) {
                lastId = ticketIndex.length;
            }
            
            lastId -= 1;
        }
        
        administrator.transfer(this.balance);
        
        state = State.ENDED;
        
        GameFinished(ticketIndex[winnerIndex]);
    }
}