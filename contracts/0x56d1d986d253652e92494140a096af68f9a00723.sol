pragma solidity 0.4.24;

contract AccessControl {
     /// @dev Emited when contract is upgraded - See README.md for updgrade plan
    event ContractUpgrade(address newContract);

    // The addresses of the accounts (or contracts) that can execute actions within each roles.
    address public ceoAddress;

    uint public totalTipForDeveloper = 0;

    // @dev Keeps track whether the contract is paused. When that is true, most actions are blocked
    bool public paused = false;

    /// @dev Access modifier for CEO-only functionality
    modifier onlyCEO() {
        require(msg.sender == ceoAddress, "You're not a CEO!");
        _;
    }

    /// @dev Wrong send eth! It's will tip for developer
    function () public payable{
        totalTipForDeveloper = totalTipForDeveloper + msg.value;
    }

    /// @dev Add tip for developer
    /// @param valueTip The value of tip
    function addTipForDeveloper(uint valueTip) internal {
        totalTipForDeveloper += valueTip;
    }

    /// @dev Developer can withdraw tip.
    function withdrawTipForDeveloper() external onlyCEO {
        require(totalTipForDeveloper > 0, "Need more tip to withdraw!");
        msg.sender.transfer(totalTipForDeveloper);
        totalTipForDeveloper = 0;
    }

    /// @dev Assigns a new address to act as the CEO. Only available to the current CEO.
    /// @param _newCEO The address of the new CEO
    function setCEO(address _newCEO) external onlyCEO {
        require(_newCEO != address(0), "Address to set CEO wrong!");

        ceoAddress = _newCEO;
    }

    /*Pausable functionality adapted from OpenZeppelin */

    /// @dev Modifier to allow actions only when the contract IS NOT paused
    modifier whenNotPaused() {
        require(!paused, "Paused!");
        _;
    }

    /// @dev Modifier to allow actions only when the contract IS paused
    modifier whenPaused {
        require(paused, "Not paused!");
        _;
    }

    /// @dev Called by any "C-level" role to pause the contract. Used only when
    ///  a bug or exploit is detected and we need to limit damage.
    function pause() external onlyCEO whenNotPaused {
        paused = true;
    }

    /// @dev Unpauses the smart contract. Can only be called by the CEO, since
    ///  one reason we may pause the contract is when CFO or COO accounts are
    ///  compromised.
    /// @notice This is public rather than external so it can be called by
    ///  derived contracts.
    function unpause() public onlyCEO whenPaused {
        // can't unpause if contract was upgraded
        paused = false;
    }
}

contract RPSCore is AccessControl {
    uint constant ROCK = 1000;
    uint constant PAPER = 2000;
    uint constant SCISSOR = 3000;

    uint constant GAME_RESULT_DRAW = 1;
    uint constant GAME_RESULT_HOST_WIN = 2;
    uint constant GAME_RESULT_GUEST_WIN = 3;

    uint constant GAME_STATE_AVAILABLE_TO_JOIN = 1;
    uint constant GAME_STATE_WAITING_HOST_REVEAL = 2;

    uint constant DEVELOPER_TIP_PERCENT = 1;
    uint constant DEVELOPER_TIP_MIN = 0.0005 ether;

    uint constant VALUE_BET_MIN = 0.02 ether;
    uint constant VALUE_BET_MAX = 2 ether;

    uint constant TIME_GAME_EXPIRE = 1 hours;

    struct Game {
        uint id;
        uint state;
        uint timeExpire;
        uint valueBet;
        uint gestureGuest;
        address addressHost;
        address addressGuest;
        bytes32 hashGestureHost;
    }

    event LogCloseGameSuccessed(uint _id, uint _valueReturn);
    event LogCreateGameSuccessed(uint _id, uint _valuePlayerHostBid);
    event LogJoinGameSuccessed(uint _id);
    event LogRevealGameSuccessed(uint _id,
                                    uint _result,
                                    address indexed _addressPlayerWin,
                                    address indexed _addressPlayerLose,
                                    uint _valuePlayerWin,
                                    uint _valuePlayerLose,
                                    uint _gesturePlayerWin,
                                    uint _gesturePlayerLose);
 
    uint public totalCreatedGame;
    uint public totalAvailableGames;
    Game[] public arrAvailableGames;

    mapping(uint => uint) idToIndexAvailableGames;


    constructor() public {
        ceoAddress = msg.sender;

        totalCreatedGame = 0;
        totalAvailableGames = 0;
    }

    function createGame(bytes32 _hashGestureHost)
        external
        payable
        verifiedValueBetWithRule(msg.value)
    {
        Game memory game = Game({
            id: totalCreatedGame + 1,
            state: GAME_STATE_AVAILABLE_TO_JOIN,
            timeExpire: 0,
            valueBet: msg.value,
            addressHost: msg.sender,
            hashGestureHost: _hashGestureHost,
            addressGuest: 0,
            gestureGuest: 0
        });

        arrAvailableGames.push(game);
        idToIndexAvailableGames[game.id] = arrAvailableGames.length - 1;

        totalCreatedGame++;
        totalAvailableGames++;

        emit LogCreateGameSuccessed(game.id, game.valueBet);
    }

    function joinGame(uint _id, uint _gestureGuest)
        external
        payable
        verifiedValueBetWithRule(msg.value)
        verifiedGameAvailable(_id)
        verifiedGameExist(_id)
    {
        Game storage game = arrAvailableGames[idToIndexAvailableGames[_id]];

        require(msg.sender != game.addressHost, "Can't join game cretead by host");
        require(msg.value == game.valueBet, "Value bet to battle not extractly with value bet of host");
       
        game.addressGuest = msg.sender;
        game.gestureGuest = _gestureGuest;
        game.state = GAME_STATE_WAITING_HOST_REVEAL;
        game.timeExpire = now + TIME_GAME_EXPIRE;

        emit LogJoinGameSuccessed(_id);
    }

    function revealGameByHost(uint _id, uint _gestureHost, bytes32 _secretKey) external payable verifiedGameExist(_id) {
        bytes32 proofHashGesture = getProofGesture(_gestureHost, _secretKey);
        Game storage game = arrAvailableGames[idToIndexAvailableGames[_id]];
        Game memory gameCached = arrAvailableGames[idToIndexAvailableGames[_id]];

        require(gameCached.state == GAME_STATE_WAITING_HOST_REVEAL, "Game not in state waiting reveal");
        require(now <= gameCached.timeExpire, "Host time reveal ended");
        require(gameCached.addressHost == msg.sender, "You're not host this game");
        require(gameCached.hashGestureHost == proofHashGesture, "Can't verify gesture and secret key of host");
        require(verifyGesture(_gestureHost) && verifyGesture(gameCached.gestureGuest), "Can't verify gesture of host or guest");

        uint result = GAME_RESULT_DRAW;

        //Result: [Draw] => Return money to host and guest players (No fee)
        if(_gestureHost == gameCached.gestureGuest) {
            result = GAME_RESULT_DRAW;
            sendPayment(gameCached.addressHost, gameCached.valueBet);
            sendPayment(gameCached.addressGuest, gameCached.valueBet);
            game.valueBet = 0;
            destroyGame(_id);
            emit LogRevealGameSuccessed(_id,
                                        GAME_RESULT_DRAW,
                                        gameCached.addressHost,
                                        gameCached.addressGuest,
                                        0,
                                        0,
                                        _gestureHost, 
                                        gameCached.gestureGuest);
        }
        else {
            if(_gestureHost == ROCK) 
                result = gameCached.gestureGuest == SCISSOR ? GAME_RESULT_HOST_WIN : GAME_RESULT_GUEST_WIN;
            else
                if(_gestureHost == PAPER) 
                    result = (gameCached.gestureGuest == ROCK ? GAME_RESULT_HOST_WIN : GAME_RESULT_GUEST_WIN);
                else
                    if(_gestureHost == SCISSOR) 
                        result = (gameCached.gestureGuest == PAPER ? GAME_RESULT_HOST_WIN : GAME_RESULT_GUEST_WIN);

            //Result: [Win] => Return money to winner (Winner will pay 1% fee)
            uint valueTip = getValueTip(gameCached.valueBet);
            addTipForDeveloper(valueTip);
            
            if(result == GAME_RESULT_HOST_WIN) {
                sendPayment(gameCached.addressHost, gameCached.valueBet * 2 - valueTip);
                game.valueBet = 0;
                destroyGame(_id);    
                emit LogRevealGameSuccessed(_id,
                                            GAME_RESULT_HOST_WIN,
                                            gameCached.addressHost,
                                            gameCached.addressGuest,
                                            gameCached.valueBet - valueTip,
                                            gameCached.valueBet,
                                            _gestureHost, 
                                            gameCached.gestureGuest);
            }
            else {
                sendPayment(gameCached.addressGuest, gameCached.valueBet * 2 - valueTip);
                game.valueBet = 0;
                destroyGame(_id);
                emit LogRevealGameSuccessed(_id,
                                            GAME_RESULT_GUEST_WIN,
                                            gameCached.addressGuest,
                                            gameCached.addressHost,
                                            gameCached.valueBet - valueTip,
                                            gameCached.valueBet,
                                            gameCached.gestureGuest, 
                                            _gestureHost);
            }          
        }
    }

    function revealGameByGuest(uint _id) external payable verifiedGameExist(_id) {
        Game storage game = arrAvailableGames[idToIndexAvailableGames[_id]];
        Game memory gameCached = arrAvailableGames[idToIndexAvailableGames[_id]];

        require(gameCached.state == GAME_STATE_WAITING_HOST_REVEAL, "Game not in state waiting reveal");
        require(now > gameCached.timeExpire, "Host time reveal not ended");
        require(gameCached.addressGuest == msg.sender, "You're not guest this game");

        uint valueTip = getValueTip(gameCached.valueBet);
        addTipForDeveloper(valueTip);

        sendPayment(gameCached.addressGuest, gameCached.valueBet * 2 - valueTip);
        game.valueBet = 0;
        destroyGame(_id);
        emit LogRevealGameSuccessed(_id,
                                    GAME_RESULT_GUEST_WIN,
                                    gameCached.addressGuest,
                                    gameCached.addressHost,
                                    gameCached.valueBet - valueTip,
                                    gameCached.valueBet,
                                    gameCached.gestureGuest, 
                                    0);
    }

    function closeMyGame(uint _id) external payable verifiedHostOfGame(_id) verifiedGameAvailable(_id) {
        Game storage game = arrAvailableGames[idToIndexAvailableGames[_id]];

        require(game.state == GAME_STATE_AVAILABLE_TO_JOIN, "Battle already! Waiting your reveal! Refesh page");

        uint valueBetCached = game.valueBet;
        sendPayment(game.addressHost, valueBetCached);
        game.valueBet = 0;
        destroyGame(_id);
        emit LogCloseGameSuccessed(_id, valueBetCached);
    }

    function getAvailableGameWithID(uint _id) 
        public
        view
        verifiedGameExist(_id) 
        returns (uint id, uint state, uint valueBest, uint timeExpireRemaining, address addressHost, address addressGuest) 
    {
        Game storage game = arrAvailableGames[idToIndexAvailableGames[_id]];
        timeExpireRemaining = game.timeExpire - now;
        timeExpireRemaining = (timeExpireRemaining < 0 ? 0 : timeExpireRemaining);

        return(game.id, game.state, game.valueBet, game.timeExpire, game.addressHost, game.addressGuest);
    }

    function destroyGame(uint _id) private {
        removeGameInfoFromArray(idToIndexAvailableGames[_id]);
        delete idToIndexAvailableGames[_id];
        totalAvailableGames--;
    }

    function removeGameInfoFromArray(uint _index) private {
        if(_index >= 0 && arrAvailableGames.length > 0) {
            if(_index == arrAvailableGames.length - 1)
            arrAvailableGames.length--;
            else {
                arrAvailableGames[_index] = arrAvailableGames[arrAvailableGames.length - 1];
                idToIndexAvailableGames[arrAvailableGames[_index].id] = _index;
                arrAvailableGames.length--;
            }
        }
    }

    function getValueTip(uint _valueWin) private pure returns(uint) {
        uint valueTip = _valueWin * DEVELOPER_TIP_PERCENT / 100;

        if(valueTip < DEVELOPER_TIP_MIN)
            valueTip = DEVELOPER_TIP_MIN;

        return valueTip;
    }

    function sendPayment(address _receiver, uint _amount) private {
        _receiver.transfer(_amount);
    }

    function getProofGesture(uint _gesture, bytes32 _secretKey) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(_gesture, _secretKey));
    }

    function verifyGesture(uint _gesture) private pure returns (bool) {
        return (_gesture == ROCK || _gesture == PAPER || _gesture == SCISSOR);
    }

    modifier verifiedGameAvailable(uint _id) {
        require(arrAvailableGames[idToIndexAvailableGames[_id]].addressGuest == 0, "Have guest already");
        _;
    }

    modifier verifiedGameExist(uint _id) {
        require(idToIndexAvailableGames[_id] >= 0, "Game ID not exist!");
        _;
    }

    modifier verifiedHostOfGame(uint _id) {
        require(msg.sender == arrAvailableGames[idToIndexAvailableGames[_id]].addressHost, "Verify host of game failed");
        _;
    }

    modifier verifiedValueBetWithRule(uint _valueBet) {
        require(_valueBet >= VALUE_BET_MIN && _valueBet <= VALUE_BET_MAX, "Your value bet out of rule");
        _;
    }

}