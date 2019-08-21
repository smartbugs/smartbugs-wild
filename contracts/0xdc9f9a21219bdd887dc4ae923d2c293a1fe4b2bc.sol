pragma solidity ^0.4.19;

contract Spineth
{
    /// The states the game will transition through
    enum State
    {
        WaitingForPlayers, // the game has been created by a player and is waiting for an opponent
        WaitingForReveal, // someone has joined and also placed a bet, we are now waiting for the creator to their reveal bet
        Complete // the outcome of the game is determined and players can withdraw their earnings
    }

    /// All possible event types
    enum Event
    {
        Create,
        Cancel,
        Join,
        Reveal,
        Expire,
        Complete,
        Withdraw,
        StartReveal
    }
    
    // The game state associated with a single game between two players
    struct GameInstance
    {
        // Address for players of this game
        // player1 is always the creator
        address player1;
        address player2;
    
        // How much is being bet this game
        uint betAmountInWei;
    
        // The wheelBet for each player
        // For player1, the bet starts as a hash and is only changed to the real bet once revealed
        uint wheelBetPlayer1;
        uint wheelBetPlayer2;
    
        // The final wheel position after game is complete
        uint wheelResult;
    
        // The time by which the creator of the game must reveal his bet after an opponent joins
        // If the creator does not reveal in time, the opponent can expire the game, causing them to win the maximal amount of their bet
        uint expireTime;

        // Current state of the game    
        State state;

        // Tracks whether each player has withdrawn their earnings yet
        bool withdrawnPlayer1;
        bool withdrawnPlayer2;
    }

    /// How many places there are on the wheel that a bet can be placed
    uint public constant WHEEL_SIZE = 19;
    
    /// What percentage of your opponent's bet a player wins for each place on 
    /// the wheel they are closer to the result than their opponent
    /// i.e. If player1 distance from result = 4 and player2 distance from result = 6
    /// then player1 earns (6-4) x WIN_PERCENT_PER_DISTANCE = 20% of player2's bet
    uint public constant WIN_PERCENT_PER_DISTANCE = 10;

    /// The percentage charged on earnings that are won
    uint public constant FEE_PERCENT = 2;

    /// The minimum amount that can be bet
    uint public minBetWei = 1 finney;
    
    /// The maximum amount that can be bet
    uint public maxBetWei = 10 ether;
    
    /// The amount of time creators have to reavel their bets before
    /// the game can be expired by an opponent
    uint public maxRevealSeconds = 3600 * 24;

    /// The account that will receive fees and can configure min/max bet options
    address public authority;

    /// Counters that tracks how many games have been created by each player
    /// This is used to generate a unique game id per player
    mapping(address => uint) private counterContext;

    /// Context for all created games
    mapping(uint => GameInstance) public gameContext;

    /// List of all currently open gameids
    uint[] public openGames;

    /// Indexes specific to each player
    mapping(address => uint[]) public playerActiveGames;
    mapping(address => uint[]) public playerCompleteGames;    

    /// Event fired when a game's state changes
    event GameEvent(uint indexed gameId, address indexed player, Event indexed eventType);

    /// Create the contract and verify constant configurations make sense
    function Spineth() public
    {
        // Make sure that the maximum possible win distance (WHEEL_SIZE / 2)
        // multiplied by the WIN_PERCENT_PER_DISTANCE is less than 100%
        // If it's not, then a maximally won bet can't be paid out
        require((WHEEL_SIZE / 2) * WIN_PERCENT_PER_DISTANCE < 100);

        authority = msg.sender;
    }
    
    // Change authority
    // Can only be called by authority
    function changeAuthority(address newAuthority) public
    {
        require(msg.sender == authority);

        authority = newAuthority;
    }

    // Change min/max bet amounts
    // Can only be called by authority
    function changeBetLimits(uint minBet, uint maxBet) public
    {
        require(msg.sender == authority);
        require(maxBet >= minBet);

        minBetWei = minBet;
        maxBetWei = maxBet;
    }
    
    // Internal helper function to add elements to an array
    function arrayAdd(uint[] storage array, uint element) private
    {
        array.push(element);
    }

    // Internal helper function to remove element from an array
    function arrayRemove(uint[] storage array, uint element) private
    {
        for(uint i = 0; i < array.length; ++i)
        {
            if(array[i] == element)
            {
                array[i] = array[array.length - 1];
                delete array[array.length - 1];
                --array.length;
                break;
            }
        }
    }

    /// Get next game id to be associated with a player address
    function getNextGameId(address player) public view
        returns (uint)
    {
        uint counter = counterContext[player];

        // Addresses are 160 bits so we can safely shift them up by (256 - 160 = 96 bits)
        // to make room for the counter in the bottom 96 bits
        // This means a single player cannot theoretically create more than 2^96 games
        // which should more than enough for the lifetime of any player.
        uint result = (uint(player) << 96) + counter;

        // Check that we didn't overflow the counter (this will never happen)
        require((result >> 96) == uint(player));

        return result;
    }

    /// Used to calculate the bet hash given a wheel bet and a player secret.
    /// Used by a game creator to calculate their bet bash off chain first.
    /// When bet is revealed, contract will use this function to verify the revealed bet is valid
    function createWheelBetHash(uint gameId, uint wheelBet, uint playerSecret) public pure
        returns (uint)
    {
        require(wheelBet < WHEEL_SIZE);
        return uint(keccak256(gameId, wheelBet, playerSecret));
    }
    
    /// Create and initialize a game instance with the sent bet amount.
    /// The creator will automatically become a participant of the game.
    /// gameId must be the return value of getNextGameId(...) for the sender
    /// wheelPositionHash should be calculated using createWheelBetHash(...)
    function createGame(uint gameId, uint wheelPositionHash) public payable
    {
        // Make sure the player passed the correct value for the game id
        require(getNextGameId(msg.sender) == gameId);

        // Get the game instance and ensure that it doesn't already exist
        GameInstance storage game = gameContext[gameId];
        require(game.betAmountInWei == 0); 
        
        // Must provide non-zero bet
        require(msg.value > 0);
        
        // Restrict betting amount
        // NOTE: Game creation can be disabled by setting min/max bet to 0
        require(msg.value >= minBetWei && msg.value <= maxBetWei);

        // Increment the create game counter for this player
        counterContext[msg.sender] = counterContext[msg.sender] + 1;

        // Update game state
        // The creator becomes player1
        game.state = State.WaitingForPlayers;
        game.betAmountInWei = msg.value;
        game.player1 = msg.sender;
        game.wheelBetPlayer1 = wheelPositionHash;
        
        // This game is now open to others and active for the player
        arrayAdd(openGames, gameId);
        arrayAdd(playerActiveGames[msg.sender], gameId);

        // Fire event for the creation of this game
        GameEvent(gameId, msg.sender, Event.Create);
    }
    
    /// Cancel a game that was created but never had another player join
    /// A creator can use this function if they have been waiting too long for another
    /// player and want to get their bet funds back. NOTE. Once someone joins
    /// the game can no longer be cancelled.
    function cancelGame(uint gameId) public
    {
        // Get the game instance and check that it exists
        GameInstance storage game = gameContext[gameId];
        require(game.betAmountInWei > 0); 

        // Can only cancel if we are still waiting for other participants
        require(game.state == State.WaitingForPlayers);
        
        // Is the sender the creator?
        require(game.player1 == msg.sender);

        // Update game state
        // Mark earnings as already withdrawn since we are returning the bet amount
        game.state = State.Complete;
        game.withdrawnPlayer1 = true;

        // This game is no longer open and no longer active for the player
        arrayRemove(openGames, gameId);
        arrayRemove(playerActiveGames[msg.sender], gameId);

        // Fire event for player canceling this game
        GameEvent(gameId, msg.sender, Event.Cancel);

        // Transfer the player's bet amount back to them
        msg.sender.transfer(game.betAmountInWei);
    }

    /// Join an open game instance
    /// Sender must provide an amount of wei equal to betAmountInWei
    /// After the second player has joined, the creator will have maxRevealSeconds to reveal their bet
    function joinGame(uint gameId, uint wheelBet) public payable
    {
        // Get the game instance and check that it exists
        GameInstance storage game = gameContext[gameId];
        require(game.betAmountInWei > 0); 
        
        // Only allowed to participate while we are waiting for players
        require(game.state == State.WaitingForPlayers);
        
        // Can't join a game that you created
        require(game.player1 != msg.sender);
        
        // Is there space available?
        require(game.player2 == 0);

        // Must pay the amount of the bet to play
        require(msg.value == game.betAmountInWei);

        // Make sure the wheelBet makes sense
        require(wheelBet < WHEEL_SIZE);

        // Update game state
        // The sender becomes player2
        game.state = State.WaitingForReveal;
        game.player2 = msg.sender;
        game.wheelBetPlayer2 = wheelBet;
        game.expireTime = now + maxRevealSeconds; // After expireTime the game can be expired

        // This game is no longer open, and is now active for the joiner
        arrayRemove(openGames, gameId);
        arrayAdd(playerActiveGames[msg.sender], gameId);

        // Fire event for player joining this game
        GameEvent(gameId, msg.sender, Event.Join);

        // Fire event for creator, letting them know they need to reveal their bet now
        GameEvent(gameId, game.player1, Event.StartReveal);
    }
    
    /// This can be called by the joining player to force the game to end once the expire
    /// time has been reached. This is a safety measure to ensure the game can be completed
    /// in case where the creator decides to not to reveal their bet. In this case, the creator
    /// will lose the maximal amount of their bet
    function expireGame(uint gameId) public
    {
        // Get the game instance and check that it exists
        GameInstance storage game = gameContext[gameId];
        require(game.betAmountInWei > 0); 

        // Only expire from the WaitingForReveal state
        require(game.state == State.WaitingForReveal);
        
        // Has enough time passed to perform this action?
        require(now > game.expireTime);
        
        // Can only expire the game if you are the second player
        require(msg.sender == game.player2);

        // Player1 (creator) did not reveal bet in time
        // Complete the game in favor of player2
        game.wheelResult = game.wheelBetPlayer2;
        game.wheelBetPlayer1 = (game.wheelBetPlayer2 + (WHEEL_SIZE / 2)) % WHEEL_SIZE;
        
        // This game is complete, the withdrawEarnings flow can now be invoked
        game.state = State.Complete;

        // Fire an event for the player forcing this game to end
        GameEvent(gameId, game.player1, Event.Expire);
        GameEvent(gameId, game.player2, Event.Expire);
    }
    
    /// Once a player has joined the game, the creator must reveal their bet
    /// by providing the same playerSecret that was passed to createGame(...)
    function revealBet(uint gameId, uint playerSecret) public
    {
        // Get the game instance and check that it exists
        GameInstance storage game = gameContext[gameId];
        require(game.betAmountInWei > 0); 

        // We can only reveal bets during the revealing bets state
        require(game.state == State.WaitingForReveal);

        // Only the creator does this
        require(game.player1 == msg.sender);

        uint i; // Loop counter used below

        // Find the wheelBet the player made by enumerating the hash
        // possibilities. It is done this way so the player only has to
        // remember their secret in order to revel the bet
        for(i = 0; i < WHEEL_SIZE; ++i)
        {
            // Find the bet that was provided in createGame(...)
            if(createWheelBetHash(gameId, i, playerSecret) == game.wheelBetPlayer1)
            {
                // Update the bet to the revealed value
                game.wheelBetPlayer1 = i;
                break;
            }
        }
        
        // Make sure we successfully revealed the bet, otherwise
        // the playerSecret was invalid
        require(i < WHEEL_SIZE);
        
        // Fire an event for the revealing of the bet
        GameEvent(gameId, msg.sender, Event.Reveal);

        // Use the revealed bets to calculate the wheelResult
        // NOTE: Neither player knew the unrevealed state of both bets when making their
        // bet, so the combination can be used to generate a random number neither player could anticipate.
        // This algorithm was tested for good outcome distribution for arbitrary hash values
        uint256 hashResult = uint256(keccak256(gameId, now, game.wheelBetPlayer1, game.wheelBetPlayer2));
        uint32 randomSeed = uint32(hashResult >> 0)
                          ^ uint32(hashResult >> 32)
                          ^ uint32(hashResult >> 64)
                          ^ uint32(hashResult >> 96)
                          ^ uint32(hashResult >> 128)
                          ^ uint32(hashResult >> 160)
                          ^ uint32(hashResult >> 192)
                          ^ uint32(hashResult >> 224);

        uint32 randomNumber = randomSeed;
        randomNumber ^= (randomNumber >> 11);
        randomNumber ^= (randomNumber << 7) & 0x9D2C5680;
        randomNumber ^= (randomNumber << 15) & 0xEFC60000;
        randomNumber ^= (randomNumber >> 18);

        // Update game state        
        game.wheelResult = randomNumber % WHEEL_SIZE;
        game.state = State.Complete;
        
        // Fire an event for the completion of the game
        GameEvent(gameId, game.player1, Event.Complete);
        GameEvent(gameId, game.player2, Event.Complete);
    }

    /// A utility function to get the minimum distance between two selections
    /// on a wheel of WHEEL_SIZE wrapping around at 0
    function getWheelDistance(uint value1, uint value2) private pure
        returns (uint)
    {
        // Make sure the values are within range
        require(value1 < WHEEL_SIZE && value2 < WHEEL_SIZE);

        // Calculate the distance of value1 with respect to value2
        uint dist1 = (WHEEL_SIZE + value1 - value2) % WHEEL_SIZE;
        
        // Calculate the distance going the other way around the wheel
        uint dist2 = WHEEL_SIZE - dist1;

        // Whichever distance is shorter is the wheel distance
        return (dist1 < dist2) ? dist1 : dist2;
    }

    /// Once the game is complete, use this function to get the results of
    /// the game. Returns:
    /// - the amount of wei charged for the fee
    /// - the amount of wei to be paid out to player1
    /// - the amount of wei to be paid out to player2
    /// The sum of all the return values is exactly equal to the contributions
    /// of both player bets. i.e. 
    ///     feeWei + weiPlayer1 + weiPlayer2 = 2 * betAmountInWei
    function calculateEarnings(uint gameId) public view
        returns (uint feeWei, uint weiPlayer1, uint weiPlayer2)
    {
        // Get the game instance and check that it exists
        GameInstance storage game = gameContext[gameId];
        require(game.betAmountInWei > 0); 

        // It doesn't make sense to call this function when the game isn't complete
        require(game.state == State.Complete);
        
        uint distancePlayer1 = getWheelDistance(game.wheelBetPlayer1, game.wheelResult);
        uint distancePlayer2 = getWheelDistance(game.wheelBetPlayer2, game.wheelResult);

        // Outcome if there is a tie
        feeWei = 0;
        weiPlayer1 = game.betAmountInWei;
        weiPlayer2 = game.betAmountInWei;

        uint winDist = 0;
        uint winWei = 0;
        
        // Player one was closer, so they won
        if(distancePlayer1 < distancePlayer2)
        {
            winDist = distancePlayer2 - distancePlayer1;
            winWei = game.betAmountInWei * (winDist * WIN_PERCENT_PER_DISTANCE) / 100;

            feeWei = winWei * FEE_PERCENT / 100;
            weiPlayer1 += winWei - feeWei;
            weiPlayer2 -= winWei;
        }
        // Player two was closer, so they won
        else if(distancePlayer2 < distancePlayer1)
        {
            winDist = distancePlayer1 - distancePlayer2;
            winWei = game.betAmountInWei * (winDist * WIN_PERCENT_PER_DISTANCE) / 100;

            feeWei = winWei * FEE_PERCENT / 100;
            weiPlayer2 += winWei - feeWei;
            weiPlayer1 -= winWei;
        }
        // Same distance, so it was a tie (see above)
    }
    
    /// Once the game is complete, each player can withdraw their earnings
    /// A fee is charged on winnings only and provided to the contract authority
    function withdrawEarnings(uint gameId) public
    {
        // Get the game instance and check that it exists
        GameInstance storage game = gameContext[gameId];
        require(game.betAmountInWei > 0); 

        require(game.state == State.Complete);
        
        var (feeWei, weiPlayer1, weiPlayer2) = calculateEarnings(gameId);

        bool payFee = false;
        uint withdrawAmount = 0;

        if(game.player1 == msg.sender)
        {
            // Can't have already withrawn
            require(game.withdrawnPlayer1 == false);
            
            game.withdrawnPlayer1 = true; // They can't withdraw again
            
            // If player1 was the winner, they will pay the fee
            if(weiPlayer1 > weiPlayer2)
            {
                payFee = true;
            }
            
            withdrawAmount = weiPlayer1;
        }
        else if(game.player2 == msg.sender)
        {
            // Can't have already withrawn
            require(game.withdrawnPlayer2 == false);
            
            game.withdrawnPlayer2 = true;

            // If player2 was the winner, they will pay the fee
            if(weiPlayer2 > weiPlayer1)
            {
                payFee = true;
            }
            
            withdrawAmount = weiPlayer2;
        }
        else
        {
            // The sender isn't a participant
            revert();
        }

        // This game is no longer active for this player, and now moved to complete for this player
        arrayRemove(playerActiveGames[msg.sender], gameId);
        arrayAdd(playerCompleteGames[msg.sender], gameId);

        // Fire an event for the withdrawing of funds
        GameEvent(gameId, msg.sender, Event.Withdraw);

        // Pay the fee, if necessary
        if(payFee == true)
        {
            authority.transfer(feeWei);
        }
    
        // Transfer sender their outcome
        msg.sender.transfer(withdrawAmount);
    }
}