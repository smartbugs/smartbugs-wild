/** 
*   ________  __                  __          __      __                        _______             __        __        __    __     
*  |        \|  \                |  \        |  \    |  \                      |       \           |  \      |  \      |  \  |  \    
*  | $$$$$$$$ \$$ _______    ____| $$       _| $$_   | $$____    ______        | $$$$$$$\  ______  | $$____  | $$____   \$$ _| $$_   
*  | $$__    |  \|       \  /      $$      |   $$ \  | $$    \  /      \       | $$__| $$ |      \ | $$    \ | $$    \ |  \|   $$ \  
*  | $$  \   | $$| $$$$$$$\|  $$$$$$$       \$$$$$$  | $$$$$$$\|  $$$$$$\      | $$    $$  \$$$$$$\| $$$$$$$\| $$$$$$$\| $$ \$$$$$$  
*  | $$$$$   | $$| $$  | $$| $$  | $$        | $$ __ | $$  | $$| $$    $$      | $$$$$$$\ /      $$| $$  | $$| $$  | $$| $$  | $$ __ 
*  | $$      | $$| $$  | $$| $$__| $$        | $$|  \| $$  | $$| $$$$$$$$      | $$  | $$|  $$$$$$$| $$__/ $$| $$__/ $$| $$  | $$|  \
*  | $$      | $$| $$  | $$ \$$    $$         \$$  $$| $$  | $$ \$$     \      | $$  | $$ \$$    $$| $$    $$| $$    $$| $$   \$$  $$
*   \$$       \$$ \$$   \$$  \$$$$$$$          \$$$$  \$$   \$$  \$$$$$$$       \$$   \$$  \$$$$$$$ \$$$$$$$  \$$$$$$$  \$$    \$$$$
*
*
*             ╔═╗┌─┐┌─┐┬┌─┐┬┌─┐┬   ┌─────────────────────────┐ ╦ ╦┌─┐┌┐ ╔═╗┬┌┬┐┌─┐ 
*             ║ ║├┤ ├┤ ││  │├─┤│   │https://findtherabbit.me │ ║║║├┤ ├┴┐╚═╗│ │ ├┤  
*             ╚═╝└  └  ┴└─┘┴┴ ┴┴─┘ └─┬─────────────────────┬─┘ ╚╩╝└─┘└─┘╚═╝┴ ┴ └─┘      
*/


// File: contracts/lib/SafeMath.sol

pragma solidity 0.5.4;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

// File: contracts/Messages.sol

pragma solidity 0.5.4;

/**
 * EIP712 Ethereum typed structured data hashing and signing
*/
contract Messages {
    struct AcceptGame {
        uint256 bet;
        bool isHost;
        address opponentAddress;
        bytes32 hashOfMySecret;
        bytes32 hashOfOpponentSecret;
    }
    
    struct SecretData {
        bytes32 salt;
        uint8 secret;
    }

    /**
     * Domain separator encoding per EIP 712.
     * keccak256(
     *     "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)"
     * )
     */
    bytes32 public constant EIP712_DOMAIN_TYPEHASH = 0xd87cd6ef79d4e2b95e15ce8abf732db51ec771f1ca2edccf22a46c729ac56472;

    /**
     * AcceptGame struct type encoding per EIP 712
     * keccak256(
     *     "AcceptGame(uint256 bet,bool isHost,address opponentAddress,bytes32 hashOfMySecret,bytes32 hashOfOpponentSecret)"
     * )
     */
    bytes32 private constant ACCEPTGAME_TYPEHASH = 0x5ceee84403c984fbd9fb4ebf11b09c4f28f87290116c8b7f24a3e2a89d26588f;

    /**
     * Domain separator per EIP 712
     */
    bytes32 public DOMAIN_SEPARATOR;

    /**
     * @notice Calculates acceptGameHash according to EIP 712.
     * @param _acceptGame AcceptGame instance to hash.
     * @return bytes32 EIP 712 hash of _acceptGame.
     */
    function _hash(AcceptGame memory _acceptGame) internal pure returns (bytes32) {
        return keccak256(abi.encode(
            ACCEPTGAME_TYPEHASH,
            _acceptGame.bet,
            _acceptGame.isHost,
            _acceptGame.opponentAddress,
            _acceptGame.hashOfMySecret,
            _acceptGame.hashOfOpponentSecret
        ));
    }

    /**
     * @notice Calculates secretHash according to EIP 712.
     * @param _salt Salt of the gamer.
     * @param _secret Secret of the gamer.
     */
    function _hashOfSecret(bytes32 _salt, uint8 _secret) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(_salt, _secret));
    }

    /**
     * @return the recovered address from the signature
     */
    function _recoverAddress(
        bytes32 messageHash,
        bytes memory signature
    )
        internal
        view
        returns (address) 
    {
        bytes32 r;
        bytes32 s;
        bytes1 v;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := mload(add(signature, 0x60))
        }
        bytes32 digest = keccak256(abi.encodePacked(
            "\x19\x01",
            DOMAIN_SEPARATOR,
            messageHash
        ));
        return ecrecover(digest, uint8(v), r, s);
    }

    /**
     * @return the address of the gamer signing the AcceptGameMessage
     */
    function _getSignerAddress(
        uint256 _value,
        bool _isHost,
        address _opponentAddress,
        bytes32 _hashOfMySecret,
        bytes32 _hashOfOpponentSecret,
        bytes memory signature
    ) 
        internal
        view
        returns (address playerAddress) 
    {   
        AcceptGame memory message = AcceptGame({
            bet: _value,
            isHost: _isHost,
            opponentAddress: _opponentAddress,
            hashOfMySecret: _hashOfMySecret,
            hashOfOpponentSecret: _hashOfOpponentSecret
        });
        bytes32 messageHash = _hash(message);
        playerAddress = _recoverAddress(messageHash, signature);
    }
}

// File: contracts/Ownable.sol

pragma solidity 0.5.4;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "not owner");
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/Claimable.sol

pragma solidity 0.5.4;


/**
 * @title Claimable
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.
 * This allows the new owner to accept the transfer.
 */
contract Claimable is Ownable {
  address public pendingOwner;

  /**
   * @dev Modifier throws if called by any account other than the pendingOwner.
   */
  modifier onlyPendingOwner() {
    require(msg.sender == pendingOwner, "not pending owner");
    _;
  }

  /**
   * @dev Allows the current owner to set the pendingOwner address.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    pendingOwner = newOwner;
  }

  /**
   * @dev Allows the pendingOwner address to finalize the transfer.
   */
  function claimOwnership() public onlyPendingOwner {
    emit OwnershipTransferred(_owner, pendingOwner);
    _owner = pendingOwner;
    pendingOwner = address(0);
  }
}

// File: contracts/lib/ERC20Basic.sol

pragma solidity 0.5.4;

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
}

// File: contracts/FindTheRabbit.sol

pragma solidity 0.5.4;





/**
 * @title FindTheRabbit
 * @dev Base game contract
 */
contract FindTheRabbit is Messages, Claimable {
    using SafeMath for uint256;
    enum GameState { 
        Invalid, // Default value for a non-created game
        HostBetted, // A player, who initiated an offchain game and made a bet
        JoinBetted, // A player, who joined the game and made a bet
        Filled, // Both players made bets
        DisputeOpenedByHost, // Dispute is opened by the initiating player
        DisputeOpenedByJoin, // Dispute is opened by the joining player
        DisputeWonOnTimeoutByHost, // Dispute is closed on timeout and the prize was taken by the initiating player 
        DisputeWonOnTimeoutByJoin, // Dispute is closed on timeout and the prize was taken by the joining player 
        CanceledByHost, // The joining player has not made a bet and the game is closed by the initiating player
        CanceledByJoin, // The initiating player has not made a bet and the game is closed by the joining player
        WonByHost, // The initiating has won the game
        WonByJoin // The joining player has won the game
    }
    //Event is triggered after both players have placed their bets
    event GameCreated(
        address indexed host, 
        address indexed join, 
        uint256 indexed bet, 
        bytes32 gameId, 
        GameState state
    );
    //Event is triggered after the first bet has been placed
    event GameOpened(bytes32 gameId, address indexed player);
    //Event is triggered after the game has been closed
    event GameCanceled(bytes32 gameId, address indexed player, address indexed opponent);
    /**
     * @dev Event triggered after after opening a dispute
     * @param gameId 32 byte game identifier
     * @param disputeOpener is a player who opened a dispute
     * @param defendant is a player against whom a dispute is opened
     */
    event DisputeOpened(bytes32 gameId, address indexed disputeOpener, address indexed defendant);
    //Event is triggered after a dispute is resolved by the function resolveDispute()
    event DisputeResolved(bytes32 gameId, address indexed player);
    //Event is triggered after a dispute is closed after the amount of time specified in disputeTimer
    event DisputeClosedOnTimeout(bytes32 gameId, address indexed player);
    //Event is triggered after sending the winning to the winner
    event WinnerReward(address indexed winner, uint256 amount);
    //Event is triggered after the jackpot is sent to the winner
    event JackpotReward(bytes32 gameId, address player, uint256 amount);
    //Event is triggered after changing the gameId that claims the jackpot
    event CurrentJackpotGame(bytes32 gameId);
    //Event is triggered after sending the reward to the referrer
    event ReferredReward(address referrer, uint256 amount);
    // Emitted when calimTokens function is invoked.
    event ClaimedTokens(address token, address owner, uint256 amount);
    
    //The address of the contract that will verify the signature per EIP 712.
    //In this case, the current address of the contract.
    address public verifyingContract = address(this);
    //An disambiguating salt for the protocol per EIP 712.
    //Set through the constructor.
    bytes32 public salt;

    //An address of the creators' account receiving the percentage of Commission for the game
    address payable public teamWallet;
    
    //Percentage of commission from the game that is sent to the creators
    uint256 public commissionPercent;
    
    //Percentage of reward to the player who invited new players
    //0.1% is equal 1
    //0.5% is equal 5
    //1% is equal 10
    //10% is equal 100
    uint256 public referralPercent;

    //Maximum allowed value of the referralPercent. (10% = 100)
    uint256 public maxReferralPercent = 100;
    
    //Minimum bet value to create a new game
    uint256 public minBet = 0.01 ether; 
    
    //Percentage of game commission added to the jackpot value
    uint256 public jackpotPercent;
    
    //Jackpot draw time in UNIX time stamp format.
    uint256 public jackpotDrawTime;
    
    //Current jackpot value
    uint256 public jackpotValue;
    
    //The current value of the gameId of the applicant for the jackpot.
    bytes32 public jackpotGameId;
    
    //Number of seconds added to jackpotDrawTime each time a new game is added to the jackpot.
    uint256 public jackpotGameTimerAddition;
    
    //Initial timeout for a new jackpot round.
    uint256 public jackpotAccumulationTimer;
    
    //Timeout in seconds during which the dispute cannot be opened.
    uint256 public revealTimer;
    
    //Maximum allowed value of the minRevealTimer in seconds. 
    uint256 public maxRevealTimer;
    
    //Minimum allowed value of the minRevealTimer in seconds. 
    uint256 public minRevealTimer;
    
    //Timeout in seconds during which the dispute cannot be closed 
    //and players can call the functions win() and resolveDispute().
    uint256 public disputeTimer; 
    
    //Maximum allowed value of the maxDisputeTimer in seconds. 
    uint256 public maxDisputeTimer;
    
    //Minimum allowed value of the minDisputeTimer in seconds. 
    uint256 public minDisputeTimer; 

    //Timeout in seconds after the first bet 
    //during which the second player's bet is expected 
    //and the game cannot be closed.
    uint256 public waitingBetTimer;
    
    //Maximum allowed value of the waitingBetTimer in seconds. 
    uint256 public maxWaitingBetTimer;
    
    //Minimum allowed value of the waitingBetTimer in seconds. 
    uint256 public minWaitingBetTimer;
    
    //The time during which the game must be completed to qualify for the jackpot.
    uint256 public gameDurationForJackpot;

    uint256 public chainId;

    //Mapping for storing information about all games
    mapping(bytes32 => Game) public games;
    //Mapping for storing information about all disputes
    mapping(bytes32 => Dispute) public disputes;
    //Mapping for storing information about all players
    mapping(address => Statistics) public players;

    struct Game {
        uint256 bet; // bet value for the game
        address payable host; // address of the initiating player
        address payable join; // address of the joining player
        uint256 creationTime; // the time of the last bet in the game.
        GameState state; // current state of the game
        bytes hostSignature; // the value of the initiating player's signature
        bytes joinSignature; // the value of the joining player's signature
        bytes32 gameId; // 32 byte game identifier
    }

    struct Dispute {
        address payable disputeOpener; //  address of the player, who opened the dispute.
        uint256 creationTime; // dispute opening time of the dispute.
        bytes32 opponentHash; // hash from an opponent's secret and salt
        uint256 secret; // secret value of the player, who opened the dispute
        bytes32 salt; // salt value of the player, who opened the dispute
        bool isHost; // true if the player initiated the game.
    }

    struct Statistics {
        uint256 totalGames; // totalGames played by the player
        uint256 totalUnrevealedGames; // total games that have been disputed against a player for unrevealing the secret on time
        uint256 totalNotFundedGames; // total number of games a player has not send funds on time
        uint256 totalOpenedDisputes; // total number of disputed games created by a player against someone for unrevealing the secret on time
        uint256 avgBetAmount; //  average bet value
    }

    /**
     * @dev Throws if the game state is not Filled. 
     */
    modifier isFilled(bytes32 _gameId) {
        require(games[_gameId].state == GameState.Filled, "game state is not Filled");
        _;
    }

    /**
     * @dev Throws if the game is not Filled or dispute has not been opened.
     */
    modifier verifyGameState(bytes32 _gameId) {
        require(
            games[_gameId].state == GameState.DisputeOpenedByHost ||
            games[_gameId].state == GameState.DisputeOpenedByJoin || 
            games[_gameId].state == GameState.Filled,
            "game state are not Filled or OpenedDispute"
        );
        _;
    }

    /**
     * @dev Throws if at least one player has not made a bet.
     */
    modifier isOpen(bytes32 _gameId) {
        require(
            games[_gameId].state == GameState.HostBetted ||
            games[_gameId].state == GameState.JoinBetted,
            "game state is not Open");
        _;
    }

    /**
     * @dev Throws if called by any account other than the participant's one in this game.
     */
    modifier onlyParticipant(bytes32 _gameId) {
        require(
            games[_gameId].host == msg.sender || games[_gameId].join == msg.sender,
            "you are not a participant of this game"
        );
        _;
    }

    /**
     * @dev Setting the parameters of the contract.
     * Description of the main parameters can be found above.
     * @param _chainId Id of the current chain.
     * @param _maxValueOfTimer maximum value for revealTimer, disputeTimer and waitingBetTimer.
     * Minimum values are set with revealTimer, disputeTimer, and waitingBetTimer values passed to the constructor.
     */
    constructor (
        uint256 _chainId, 
        address payable _teamWallet,
        uint256 _commissionPercent,
        uint256 _jackpotPercent,
        uint256 _referralPercent,
        uint256 _jackpotGameTimerAddition,
        uint256 _jackpotAccumulationTimer,
        uint256 _revealTimer,
        uint256 _disputeTimer,
        uint256 _waitingBetTimer,
        uint256 _gameDurationForJackpot,
        bytes32 _salt,
        uint256 _maxValueOfTimer
    ) public {
        teamWallet = _teamWallet;
        jackpotDrawTime = getTime().add(_jackpotAccumulationTimer);
        jackpotAccumulationTimer = _jackpotAccumulationTimer;
        commissionPercent = _commissionPercent;
        jackpotPercent = _jackpotPercent;
        referralPercent = _referralPercent;
        jackpotGameTimerAddition = _jackpotGameTimerAddition;
        revealTimer = _revealTimer;
        minRevealTimer = _revealTimer;
        maxRevealTimer = _maxValueOfTimer;
        disputeTimer = _disputeTimer;
        minDisputeTimer = _disputeTimer;
        maxDisputeTimer = _maxValueOfTimer;
        waitingBetTimer = _waitingBetTimer;
        minWaitingBetTimer = _waitingBetTimer;
        maxWaitingBetTimer = _maxValueOfTimer;
        gameDurationForJackpot = _gameDurationForJackpot;
        salt = _salt;
        chainId = _chainId;
        DOMAIN_SEPARATOR = keccak256(abi.encode(
            EIP712_DOMAIN_TYPEHASH,
            keccak256("Find The Rabbit"),
            keccak256("0.1"),
            _chainId,
            verifyingContract,
            salt
        ));
    }

    /**
     * @dev Change the current waitingBetTimer value. 
     * Change can be made only within the maximum and minimum values.
     * @param _waitingBetTimer is a new value of waitingBetTimer
     */
    function setWaitingBetTimerValue(uint256 _waitingBetTimer) external onlyOwner {
        require(_waitingBetTimer >= minWaitingBetTimer, "must be more than minWaitingBetTimer");
        require(_waitingBetTimer <= maxWaitingBetTimer, "must be less than maxWaitingBetTimer");
        waitingBetTimer = _waitingBetTimer;
    }

    /**
     * @dev Change the current disputeTimer value. 
     * Change can be made only within the maximum and minimum values.
     * @param _disputeTimer is a new value of disputeTimer.
     */
    function setDisputeTimerValue(uint256 _disputeTimer) external onlyOwner {
        require(_disputeTimer >= minDisputeTimer, "must be more than minDisputeTimer");
        require(_disputeTimer <= maxDisputeTimer, "must be less than maxDisputeTimer");
        disputeTimer = _disputeTimer;
    }

    /**
     * @dev Change the current revealTimer value. 
     * Change can be made only within the maximum and minimum values.
     * @param _revealTimer is a new value of revealTimer
     */
    function setRevealTimerValue(uint256 _revealTimer) external onlyOwner {
        require(_revealTimer >= minRevealTimer, "must be more than minRevealTimer");
        require(_revealTimer <= maxRevealTimer, "must be less than maxRevealTimer");
        revealTimer = _revealTimer;
    }

    /**
     * @dev Change the current minBet value. 
     * @param _newValue is a new value of minBet.
     */
    function setMinBetValue(uint256 _newValue) external onlyOwner {
        require(_newValue != 0, "must be greater than 0");
        minBet = _newValue;
    }

    /**
     * @dev Change the current jackpotGameTimerAddition.
     * Change can be made only within the maximum and minimum values.
     * Jackpot should not hold significant value
     * @param _jackpotGameTimerAddition is a new value of jackpotGameTimerAddition
     */
    function setJackpotGameTimerAddition(uint256 _jackpotGameTimerAddition) external onlyOwner {
        if (chainId == 1) {
            // jackpot must be less than 150 DAI. 1 ether = 150 DAI
            require(jackpotValue <= 1 ether);
        }
        if (chainId == 99) {
            // jackpot must be less than 150 DAI. 1 POA = 0.03 DAI
            require(jackpotValue <= 4500 ether);
        }
        require(_jackpotGameTimerAddition >= 2 minutes, "must be more than 2 minutes");
        require(_jackpotGameTimerAddition <= 1 hours, "must be less than 1 hour");
        jackpotGameTimerAddition = _jackpotGameTimerAddition;
    }

    /**
     * @dev Change the current referralPercent value.
     * Example:
     * 1  = 0.1%
     * 5  = 0.5%
     * 10 = 1%
     * @param _newValue is a new value of referralPercent.
     */
    function setReferralPercentValue(uint256 _newValue) external onlyOwner {
        require(_newValue <= maxReferralPercent, "must be less than maxReferralPercent");
        referralPercent = _newValue;
    }

    /**
     * @dev Change the current commissionPercent value.
     * Example:
     * 1  = 1%
     * @param _newValue is a new value of commissionPercent.
     */
    function setCommissionPercent(uint256 _newValue) external onlyOwner {
        require(_newValue <= 20, "must be less than 20");
        commissionPercent = _newValue;
    }

    /**
     * @dev Change the current teamWallet address. 
     * @param _newTeamWallet is a new teamWallet address.
     */
    function setTeamWalletAddress(address payable _newTeamWallet) external onlyOwner {
        require(_newTeamWallet != address(0));
        teamWallet = _newTeamWallet;
    }

    /**
     * @return information about the jackpot.
     */
    function getJackpotInfo() 
        external 
        view 
        returns (
            uint256 _jackpotDrawTime, 
            uint256 _jackpotValue, 
            bytes32 _jackpotGameId
        ) 
    {
        _jackpotDrawTime = jackpotDrawTime;
        _jackpotValue = jackpotValue;
        _jackpotGameId = jackpotGameId;
    }

    /**
     * @return timers used for games.
     */
    function getTimers() 
        external
        view 
        returns (
            uint256 _revealTimer,
            uint256 _disputeTimer, 
            uint256 _waitingBetTimer, 
            uint256 _jackpotAccumulationTimer 
        )
    {
        _revealTimer = revealTimer;
        _disputeTimer = disputeTimer;
        _waitingBetTimer = waitingBetTimer;
        _jackpotAccumulationTimer = jackpotAccumulationTimer;
    }

    /**
     * @dev Transfer of tokens from the contract  
     * @param _token the address of the tokens to be transferred.
     */
    function claimTokens(address _token) public onlyOwner {
        ERC20Basic erc20token = ERC20Basic(_token);
        uint256 balance = erc20token.balanceOf(address(this));
        erc20token.transfer(owner(), balance);
        emit ClaimedTokens(_token, owner(), balance);
    }

    /**
     * @dev Allows to create a game and place a bet. 
     * @param _isHost True if the sending account initiated the game.
     * @param _hashOfMySecret Hash value of the sending account's secret and salt.
     * @param _hashOfOpponentSecret Hash value of the opponent account's secret and salt.
     * @param _hostSignature Signature of the initiating player from the following values:
     *   bet,
     *   isHost,                 // true
     *   opponentAddress,        // join address
     *   hashOfMySecret,         // hash of host secret
     *   hashOfOpponentSecret    // hash of join secret
     * @param _joinSignature Signature of the joining player from the following values:
     *   bet,
     *   isHost,                 // false
     *   opponentAddress,        // host address
     *   hashOfMySecret,         // hash of join secret
     *   hashOfOpponentSecret    // hash of host secret
     */
    function createGame(
        bool _isHost,
        bytes32 _hashOfMySecret,
        bytes32 _hashOfOpponentSecret,
        bytes memory _hostSignature,
        bytes memory _joinSignature
    )
        public 
        payable
    {       
        require(msg.value >= minBet, "must be greater than the minimum value");
        bytes32 gameId = getGameId(_hostSignature, _joinSignature);
        address opponent = _getSignerAddress(
            msg.value,
            !_isHost, 
            msg.sender,
            _hashOfOpponentSecret, 
            _hashOfMySecret,
            _isHost ? _joinSignature : _hostSignature);
        require(opponent != msg.sender, "send your opponent's signature");
        Game storage game = games[gameId];
        if (game.gameId == 0){
            _recordGameInfo(msg.value, _isHost, gameId, opponent, _hostSignature, _joinSignature);
            emit GameOpened(game.gameId, msg.sender);
        } else {
            require(game.host == msg.sender || game.join == msg.sender, "you are not paticipant in this game");
            require(game.state == GameState.HostBetted || game.state == GameState.JoinBetted, "the game is not Opened");
            if (_isHost) {
                require(game.host == msg.sender, "you are not the host in this game");
                require(game.join == opponent, "invalid join signature");
                require(game.state == GameState.JoinBetted, "you have already made a bet");
            } else {
                require(game.join == msg.sender, "you are not the join in this game.");
                require(game.host == opponent, "invalid host signature");
                require(game.state == GameState.HostBetted, "you have already made a bet");
            }
            game.creationTime = getTime();
            game.state = GameState.Filled;
            emit GameCreated(game.host, game.join, game.bet, game.gameId, game.state);
        }
    }

    /**
     * @dev If the disclosure is true, the winner gets a prize. 
     * @notice a referrer will be sent a reward to.
     * only if the referrer has previously played the game and the sending account has not.
     * @param _gameId 32 byte game identifier.
     * @param _hostSecret The initiating player's secret.
     * @param _hostSalt The initiating player's salt.
     * @param _joinSecret The joining player's secret.
     * @param _joinSalt The joining player's salt.
     * @param _referrer The winning player's referrer. The referrer must have played games.
     */
    function win(
        bytes32 _gameId,
        uint8 _hostSecret,
        bytes32 _hostSalt,
        uint8 _joinSecret,
        bytes32 _joinSalt,
        address payable _referrer
    ) 
        public
        verifyGameState(_gameId)
        onlyParticipant(_gameId)
    {
        Game storage game = games[_gameId];
        bytes32 hashOfHostSecret = _hashOfSecret(_hostSalt, _hostSecret);
        bytes32 hashOfJoinSecret = _hashOfSecret(_joinSalt, _joinSecret);

        address host = _getSignerAddress(
            game.bet,
            true, 
            game.join,
            hashOfHostSecret,
            hashOfJoinSecret, 
            game.hostSignature
        );
        address join = _getSignerAddress(
            game.bet,
            false, 
            game.host,
            hashOfJoinSecret,
            hashOfHostSecret,
            game.joinSignature
        );
        require(host == game.host && join == game.join, "invalid reveals");
        address payable winner;
        if (_hostSecret == _joinSecret){
            winner = game.join;
            game.state = GameState.WonByJoin;
        } else {
            winner = game.host;
            game.state = GameState.WonByHost;
        }
        if (isPlayerExist(_referrer) && _referrer != msg.sender) {
            _processPayments(game.bet, winner, _referrer);
        }
        else {
            _processPayments(game.bet, winner, address(0));
        }
        _jackpotPayoutProcessing(_gameId); 
        _recordStatisticInfo(game.host, game.join, game.bet);
    }

    /**
     * @dev If during the time specified in revealTimer one of the players does not send 
     * the secret and salt to the opponent, the player can open a dispute.
     * @param _gameId 32 byte game identifier
     * @param _secret Secret of the player, who opens the dispute.
     * @param _salt Salt of the player, who opens the dispute.
     * @param _isHost True if the sending account initiated the game.
     * @param _hashOfOpponentSecret The hash value of the opponent account's secret and salt.
     */
    function openDispute(
        bytes32 _gameId,
        uint8 _secret,
        bytes32 _salt,
        bool _isHost,
        bytes32 _hashOfOpponentSecret
    )
        public
        onlyParticipant(_gameId)
    {
        require(timeUntilOpenDispute(_gameId) == 0, "the waiting time for revealing is not over yet");
        Game storage game = games[_gameId];
        require(isSecretDataValid(
            _gameId,
            _secret,
            _salt,
            _isHost,
            _hashOfOpponentSecret
        ), "invalid salt or secret");
        _recordDisputeInfo(_gameId, msg.sender, _hashOfOpponentSecret, _secret, _salt, _isHost);
        game.state = _isHost ? GameState.DisputeOpenedByHost : GameState.DisputeOpenedByJoin;
        address defendant = _isHost ? game.join : game.host;
        players[msg.sender].totalOpenedDisputes = (players[msg.sender].totalOpenedDisputes).add(1);
        players[defendant].totalUnrevealedGames = (players[defendant].totalUnrevealedGames).add(1);
        emit DisputeOpened(_gameId, msg.sender, defendant);
    }

    /**
     * @dev Allows the accused player to make a secret disclosure 
     * and pick up the winnings in case of victory.
     * @param _gameId 32 byte game identifier.
     * @param _secret An accused player's secret.
     * @param _salt An accused player's salt.
     * @param _isHost True if the sending account initiated the game.
     * @param _hashOfOpponentSecret The hash value of the opponent account's secret and salt.
     */
    function resolveDispute(
        bytes32 _gameId,
        uint8 _secret,
        bytes32 _salt,
        bool _isHost,
        bytes32 _hashOfOpponentSecret
    ) 
        public
        returns(address payable winner)
    {
        require(isDisputeOpened(_gameId), "there is no dispute");
        Game storage game = games[_gameId];
        Dispute memory dispute = disputes[_gameId];
        require(msg.sender != dispute.disputeOpener, "only for the opponent");
        require(isSecretDataValid(
            _gameId,
            _secret,
            _salt,
            _isHost,
            _hashOfOpponentSecret
        ), "invalid salt or secret");
        if (_secret == dispute.secret) {
            winner = game.join;
            game.state = GameState.WonByJoin;
        } else {
            winner = game.host;
            game.state = GameState.WonByHost;
        }
        _processPayments(game.bet, winner, address(0));
        _jackpotPayoutProcessing(_gameId);
        _recordStatisticInfo(game.host, game.join, game.bet);
        emit DisputeResolved(_gameId, msg.sender);
    }

    /**
     * @dev If during the time specified in disputeTimer the accused player does not manage to resolve a dispute
     * the player, who has opened the dispute, can close the dispute and get the win.
     * @param _gameId 32 byte game identifier.
     * @return address of the winning player.
     */
    function closeDisputeOnTimeout(bytes32 _gameId) public returns (address payable winner) {
        Game storage game = games[_gameId];
        Dispute memory dispute = disputes[_gameId];
        require(timeUntilCloseDispute(_gameId) == 0, "the time has not yet come out");
        winner = dispute.disputeOpener;
        game.state = (winner == game.host) ? GameState.DisputeWonOnTimeoutByHost : GameState.DisputeWonOnTimeoutByJoin;
        _processPayments(game.bet, winner, address(0));
        _jackpotPayoutProcessing(_gameId);
        _recordStatisticInfo(game.host, game.join, game.bet);
        emit DisputeClosedOnTimeout(_gameId, msg.sender);
    }

    /**
     * @dev If one of the player made a bet and during the time specified in waitingBetTimer
     * the opponent does not make a bet too, the player can take his bet back.
     * @param _gameId 32 byte game identifier.
     */
    function cancelGame(
        bytes32 _gameId
    ) 
        public
        onlyParticipant(_gameId) 
    {
        require(timeUntilCancel(_gameId) == 0, "the waiting time for the second player's bet is not over yet");
        Game storage game = games[_gameId];
        address payable recipient;
        recipient = game.state == GameState.HostBetted ? game.host : game.join;
        address defendant = game.state == GameState.HostBetted ? game.join : game.host;
        game.state = (recipient == game.host) ? GameState.CanceledByHost : GameState.CanceledByJoin;
        recipient.transfer(game.bet);
        players[defendant].totalNotFundedGames = (players[defendant].totalNotFundedGames).add(1);
        emit GameCanceled(_gameId, msg.sender, defendant);
    }

    /**
     * @dev Jackpot draw if the time has come and there is a winner.
     */
    function drawJackpot() public {
        require(isJackpotAvailable(), "is not avaliable yet");
        require(jackpotGameId != 0, "no game to claim on the jackpot");
        require(jackpotValue != 0, "jackpot's empty");
        _payoutJackpot();
    }

    /**
     * @return true if there is open dispute for given `_gameId`
     */
    function isDisputeOpened(bytes32 _gameId) public view returns(bool) {
        return (
            games[_gameId].state == GameState.DisputeOpenedByHost ||
            games[_gameId].state == GameState.DisputeOpenedByJoin
        );
    }
    
    /**
     * @return true if a player played at least one game and did not Cancel it.
     */
    function isPlayerExist(address _player) public view returns (bool) {
        return players[_player].totalGames != 0;
    }

    /**
     * @return the time after which a player can close the game.
     * @param _gameId 32 byte game identifier.
     */
    function timeUntilCancel(
        bytes32 _gameId
    )
        public
        view 
        isOpen(_gameId) 
        returns (uint256 remainingTime) 
    {
        uint256 timePassed = getTime().sub(games[_gameId].creationTime);
        if (waitingBetTimer > timePassed) {
            return waitingBetTimer.sub(timePassed);
        } else {
            return 0;
        }
    }

    /**
     * @return the time after which a player can open the dispute.
     * @param _gameId 32 byte game identifier.
     */
    function timeUntilOpenDispute(
        bytes32 _gameId
    )
        public
        view 
        isFilled(_gameId) 
        returns (uint256 remainingTime) 
    {
        uint256 timePassed = getTime().sub(games[_gameId].creationTime);
        if (revealTimer > timePassed) {
            return revealTimer.sub(timePassed);
        } else {
            return 0;
        }
    }

    /**
     * @return the time after which a player can close the dispute opened by him.
     * @param _gameId 32 byte game identifier.
     */
    function timeUntilCloseDispute(
        bytes32 _gameId
    )
        public
        view 
        returns (uint256 remainingTime) 
    {
        require(isDisputeOpened(_gameId), "there is no open dispute");
        uint256 timePassed = getTime().sub(disputes[_gameId].creationTime);
        if (disputeTimer > timePassed) {
            return disputeTimer.sub(timePassed);
        } else {
            return 0;
        }
    }

    /**
     * @return the current time in UNIX timestamp format. 
     */
    function getTime() public view returns(uint) {
        return block.timestamp;
    }

    /**
     * @return the current game state.
     * @param _gameId 32 byte game identifier
     */
    function getGameState(bytes32 _gameId) public view returns(GameState) {
        return games[_gameId].state;
    }

    /**
     * @return true if the sent secret and salt match the genuine ones.
     * @param _gameId 32 byte game identifier.
     * @param _secret A player's secret.
     * @param _salt A player's salt.
     * @param _isHost True if the sending account initiated the game.
     * @param _hashOfOpponentSecret The hash value of the opponent account's secret and salt.
     */
    function isSecretDataValid(
        bytes32 _gameId,
        uint8 _secret,
        bytes32 _salt,
        bool _isHost,
        bytes32 _hashOfOpponentSecret
    )
        public
        view
        returns (bool)
    {
        Game memory game = games[_gameId];
        bytes32 hashOfPlayerSecret = _hashOfSecret(_salt, _secret);
        address player = _getSignerAddress(
            game.bet,
            _isHost, 
            _isHost ? game.join : game.host,
            hashOfPlayerSecret,
            _hashOfOpponentSecret, 
            _isHost ? game.hostSignature : game.joinSignature
        );
        require(msg.sender == player, "the received address does not match with msg.sender");
        if (_isHost) {
            return player == game.host;
        } else {
            return player == game.join;
        }
    }

    /**
     * @return true if the jackpotDrawTime has come.
     */
    function isJackpotAvailable() public view returns (bool) {
        return getTime() >= jackpotDrawTime;
    }

    function isGameAllowedForJackpot(bytes32 _gameId) public view returns (bool) {
        return getTime() - games[_gameId].creationTime < gameDurationForJackpot;
    }

    /**
     * @return an array of statuses for the listed games.
     * @param _games array of games identifier.
     */
    function getGamesStates(bytes32[] memory _games) public view returns(GameState[] memory) {
        GameState[] memory _states = new GameState[](_games.length);
        for (uint i=0; i<_games.length; i++) {
            Game storage game = games[_games[i]];
            _states[i] = game.state;
        }
        return _states;
    }

    /**
     * @return an array of Statistics for the listed players.
     * @param _players array of players' addresses.
     */
    function getPlayersStatistic(address[] memory _players) public view returns(uint[] memory) {
        uint[] memory _statistics = new uint[](_players.length * 5);
        for (uint i=0; i<_players.length; i++) {
            Statistics storage player = players[_players[i]];
            _statistics[5*i + 0] = player.totalGames;
            _statistics[5*i + 1] = player.totalUnrevealedGames;
            _statistics[5*i + 2] = player.totalNotFundedGames;
            _statistics[5*i + 3] = player.totalOpenedDisputes;
            _statistics[5*i + 4] = player.avgBetAmount;
        }
        return _statistics;
    }

    /**
     * @return GameId generated for current values of the signatures.
     * @param _signatureHost Signature of the initiating player.
     * @param _signatureJoin Signature of the joining player.
     */
    function getGameId(bytes memory _signatureHost, bytes memory _signatureJoin) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_signatureHost, _signatureJoin));
    }

    /**
     * @dev jackpot draw.
     */
    function _payoutJackpot() internal {
        Game storage jackpotGame = games[jackpotGameId];
        uint256 reward = jackpotValue.div(2);
        jackpotValue = 0;
        jackpotGameId = 0;
        jackpotDrawTime = (getTime()).add(jackpotAccumulationTimer);
        if (jackpotGame.host.send(reward)) {
            emit JackpotReward(jackpotGame.gameId, jackpotGame.host, reward.mul(2));
        }
        if (jackpotGame.join.send(reward)) {
            emit JackpotReward(jackpotGame.gameId, jackpotGame.join, reward.mul(2));
        }
    }
    /**
     * @dev adds the completed game to the jackpot draw.
     * @param _gameId 32 byte game identifier.
     */ 
    function _addGameToJackpot(bytes32 _gameId) internal {
        jackpotDrawTime = jackpotDrawTime.add(jackpotGameTimerAddition);
        jackpotGameId = _gameId;
        emit CurrentJackpotGame(_gameId);
    }

    /**
     * @dev update jackpot info.
     * @param _gameId 32 byte game identifier.
     */ 
    function _jackpotPayoutProcessing(bytes32 _gameId) internal {
        if (isJackpotAvailable()) {
            if (jackpotGameId != 0 && jackpotValue != 0) {
                _payoutJackpot();
            }
            else {
                jackpotDrawTime = (getTime()).add(jackpotAccumulationTimer);
            }
        }
        if (isGameAllowedForJackpot(_gameId)) {
            _addGameToJackpot(_gameId);
        }
    }
    
    /**
     * @dev take a commission to the creators, reward to referrer, and commission for the jackpot from the winning amount.
     * Sending prize to winner.
     * @param _bet bet in the current game.
     * @param _winner the winner's address.
     * @param _referrer the referrer's address.
     */ 
    function _processPayments(uint256 _bet, address payable _winner, address payable _referrer) internal {
        uint256 doubleBet = (_bet).mul(2);
        uint256 commission = (doubleBet.mul(commissionPercent)).div(100);        
        uint256 jackpotPart = (doubleBet.mul(jackpotPercent)).div(100);
        uint256 winnerStake;
        if (_referrer != address(0) && referralPercent != 0 ) {
            uint256 referrerPart = (doubleBet.mul(referralPercent)).div(1000);
            winnerStake = doubleBet.sub(commission).sub(jackpotPart).sub(referrerPart);
            if (_referrer.send(referrerPart)) {
                emit ReferredReward(_referrer, referrerPart);
            }
        }
        else {
            winnerStake = doubleBet.sub(commission).sub(jackpotPart);
        }
        jackpotValue = jackpotValue.add(jackpotPart);
        _winner.transfer(winnerStake);
        teamWallet.transfer(commission);
        emit WinnerReward(_winner, winnerStake);
    }

    /**
     * @dev filling in the "Game" structure.
     */ 
    function _recordGameInfo(
        uint256 _value,
        bool _isHost, 
        bytes32 _gameId, 
        address _opponent,
        bytes memory _hostSignature,
        bytes memory _joinSignature
    ) internal {
        Game memory _game = Game({
            bet: _value,
            host: _isHost ? msg.sender : address(uint160(_opponent)),
            join: _isHost ? address(uint160(_opponent)) : msg.sender,
            creationTime: getTime(),
            state: _isHost ? GameState.HostBetted : GameState.JoinBetted ,
            gameId: _gameId,
            hostSignature: _hostSignature,
            joinSignature: _joinSignature
        });
        games[_gameId] = _game;  
    }

    /**
     * @dev filling in the "Dispute" structure.
     */ 
    function _recordDisputeInfo(
        bytes32 _gameId,
        address payable _disputeOpener,
        bytes32 _hashOfOpponentSecret,
        uint8 _secret,
        bytes32 _salt,
        bool _isHost 
    ) internal {
        Dispute memory _dispute = Dispute({
            disputeOpener: _disputeOpener,
            creationTime: getTime(),
            opponentHash: _hashOfOpponentSecret,
            secret: _secret,
            salt: _salt,
            isHost: _isHost
        });
        disputes[_gameId] = _dispute;
    }

    /**
     * @dev filling in the "Statistics" structure.
     */ 
    function _recordStatisticInfo(address _host, address _join, uint256 _bet) internal {
        Statistics storage statHost = players[_host];
        Statistics storage statJoin = players[_join];
        statHost.avgBetAmount = _calculateAvgBet(_host, _bet);
        statJoin.avgBetAmount = _calculateAvgBet(_join, _bet);
        statHost.totalGames = (statHost.totalGames).add(1);
        statJoin.totalGames = (statJoin.totalGames).add(1);
    }

    /**
     * @dev recalculation of an average bet value for a player.
     * @param _player the address of the player.
     * @param _bet bet from the last played game.
     */ 
    function _calculateAvgBet(address _player, uint256 _bet) internal view returns (uint256 newAvgBetValue){
        Statistics storage statistics = players[_player];
        uint256 totalBets = (statistics.avgBetAmount).mul(statistics.totalGames).add(_bet);
        newAvgBetValue = totalBets.div(statistics.totalGames.add(1));
    }

}