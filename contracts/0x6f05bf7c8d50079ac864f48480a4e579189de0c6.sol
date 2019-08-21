pragma solidity ^0.4.24;

/**
* @title Ownable
* @dev The Ownable contract has an owner address, and provides basic authorization control
* functions, this simplifies the implementation of "user permissions".
*/

contract Ownable {
    address public owner;

    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() public {
        owner = msg.sender;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
    * @dev Allows the current owner to relinquish control of the contract.
    * @notice Renouncing to ownership will leave the contract without an owner.
    * It will not be possible to call the functions with the `onlyOwner`
    * modifier anymore.
    */
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    /**
    * @dev Transfers control of the contract to a newOwner.
    * @param _newOwner The address to transfer ownership to.
    */
    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
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
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

//==================================================
// QIU3D Events
//==================================================
contract QIU3Devents {
    //fired whenever buy ticket
    event onNewTicket(
        address indexed player,
        uint256 indexed matchId,
        uint256 indexed ticketId,
        uint256 fullMatResOpt,
        uint256 goalsOpt,
        uint256 gapGoalsOpt,
        uint256 bothGoalOpt,
        uint256 halfAndFullMatResOpt,
        uint256 ticketValue,     
        uint256 cost
    );
    //fired whenever buy bet
    event onNewBet(
        address indexed player,
        uint256 indexed matchId,
        uint256 indexed betId,
        uint256 option,
        uint256 odds,
        uint256 cost
    );

    //fired at end match
    event onEndMatch(
        uint256 indexed matchId,
        uint256 compressData
    );

    //fired at buy ticket with player invite
    event onInvite(
        address indexed player,
        address indexed inviter,
        uint256 profit
    );

    //fired at withdraw
    event onWithdraw(
        address indexed player,
        uint256 withdraw,
        uint256 withdrawType    //0-withdraw 1-buy ticket 2-buy bet
    );
}

//==================================================
// QIU3D contract setup
//==================================================
contract QIU3D is QIU3Devents, Ownable {
    using SafeMath for *;

    //match data interface
    Q3DMatchDataInterface private MatchDataInt_;
    //foundation address, default is owner
    address private foundationAddress_;

    //jackpot and dividend percentage settings
    uint256 constant private TxTJPPercentage = 63;  //Ticket jackpot percentage in Ticket fund
    uint256 constant private BxTJPPercentage = 27;  //Bet jackpot percentage in Ticket fund
    uint256 constant private BxBJPPercentage = 90;  //Bet jackpot percentage in Bet fund
    uint256 constant private DxTJPPercentage = 10;  //Dividend percentage in Ticket fund
    uint256 constant private DxBJPPercentage = 10;  //Dividend percentage in Bet fund
    uint256 constant private TxDJPPercentage = 90;  //Tikcet dividend percentage in all Dividend
    uint256 constant private FxDJPPercentage = 10;  //Foundation dividend percentage in all Dividend

    //ticket options default invalid value
    uint256 constant InvalidFullMatchResult = 0;
    uint256 constant InvalidTotalGoals = 88;
    uint256 constant InvalidGapGoals = 88;
    uint256 constant InvalidBothGoals = 0;
    uint256 constant InvalidHalfAndFullMatchResult = 0; 

    //ticket price settings
    uint256 constant private TicketInitPrice = 100000000000000;     //Ticket initial price when match begin 
    uint256 constant private TicketIncreasePrice = 100000000000;    //Ticket increase price by each transaction
    uint256 constant private PriceThreshold = 1000;                 //Speed up price incrase whenever ticket value is a large number

    //bet settings
    uint256 constant private OddsCommission = 10;         //Bet Odds commission
    uint256 constant private OddsOpenPercentage = 30;     //Bet Odds open percentage
    uint256 constant private OddsMaxDeviation = 5;        //Whenever frontend odds less than actual odds, player should accept the deviation

    //invite settings
    uint256 constant private InviteProfitPercentage = 10;  //profit percentage by invite player

    //Match data
    uint256 public openMatchId_;                                            //current opening matchId
    uint256[] public matchIds_;                                             //match Id list
    mapping(uint256 => QIU3Ddatasets.Match) public matches_;                //(matchId => Match) return match by match ID
    mapping(uint256 => QIU3Ddatasets.MatchBetOptions) public betOptions_;   //(matchId => MatchBetOptions) return bet options by match ID

    //Player data
    mapping(address => QIU3Ddatasets.Player) public players_;       //(address => Player) return player by player address    

    //ticket option values storage array
    //|2-0| full match result option array
    //|12-3| total goals option array
    //|23-13| gap goals option array
    //|25-24| both goals option array
    //|34-26| half and full match result option array
    mapping(uint256 => uint256[35]) public ticketOptionValues_;    //(matchId => array[35]) return ticket option value by match ID

    constructor(address _matchDataAddress) public
    {
        openMatchId_ = 0; 
        MatchDataInt_ = Q3DMatchDataInterface(_matchDataAddress);
        foundationAddress_ = msg.sender;
    }

    /**
     * @dev update foundation address
     **/
    function setFoundationAddress(address _foundationAddr) public onlyOwner
    {
        foundationAddress_ = _foundationAddr;
    }

    //==================================================
    // Modifier
    //==================================================
    modifier isHuman() 
    {
        require(msg.sender == tx.origin, "sorry humans only");
        _;
    }

    modifier isWithinLimits(uint256 _eth) 
    {
        require(_eth >= 1000000000, "pocket lint: not a valid currency");
        _;    
    }

    /**
     * @dev whenever player transfer eth to contract, default select match full time result is draw
     **/
    function() public isHuman() isWithinLimits(msg.value) payable
    {
        buyTicketCore_(
            openMatchId_, 
            2, 
            InvalidTotalGoals, 
            InvalidGapGoals, 
            InvalidBothGoals, 
            InvalidHalfAndFullMatchResult, 
            msg.value, 
            address(0));
    }

    //==================================================
    // public functions (interact with contract)
    //==================================================
    /**
     * @dev player buy ticket with match options
     * @param _matchId the ID of match
     * @param _fullMatResOpt full time result (1-3), 0 to none
     * @param _goalsOpt total goals (0-9), other values to none
     * @param _gapGoalsOpt home team goals minus away team goals mapping value (0-10), mapping value = actual gap goals + 5, other values to none
     * @param _bothGoalOpt both team goal (1-2)， 0 to none
     * @param _halfAndFullMatResOpt match half time result and full time result (1-9)， 0 to none
     * @param _inviteAddr address of invite player
     */
    function buyTicket(
        uint256 _matchId,
        uint256 _fullMatResOpt,
        uint256 _goalsOpt,
        uint256 _gapGoalsOpt,
        uint256 _bothGoalOpt,
        uint256 _halfAndFullMatResOpt,
        address _inviteAddr
        ) 
        public
        isHuman() isWithinLimits(msg.value) payable
    {
        buyTicketCore_(
            _matchId, 
            _fullMatResOpt, 
            _goalsOpt, 
            _gapGoalsOpt, 
            _bothGoalOpt, 
            _halfAndFullMatResOpt, 
            msg.value, 
            _inviteAddr);
    }

     /**
     * @dev player buy ticket with vault
     * @param _matchId the ID of match
     * @param _fullMatResOpt full time result (1-3), 0 to none
     * @param _goalsOpt total goals (0-9), other values to none
     * @param _gapGoalsOpt home team goals minus away team goals mapping value (0-10), mapping value = actual gap goals + 5, other values to none
     * @param _bothGoalOpt both team goal (1-2)， 0 to none
     * @param _halfAndFullMatResOpt match half time result and full time result (1-9)， 0 to none
     * @param _vaultEth pay eth value from vault
     * @param _inviteAddr address of invite player
     */
    function buyTicketWithVault(
        uint256 _matchId,
        uint256 _fullMatResOpt,
        uint256 _goalsOpt,
        uint256 _gapGoalsOpt,
        uint256 _bothGoalOpt,
        uint256 _halfAndFullMatResOpt,
        uint256 _vaultEth,
        address _inviteAddr
        )
        public
        isHuman() isWithinLimits(_vaultEth)
    {
        uint256 withdrawn = 0;
        uint256 totalProfit = 0; 
        (totalProfit, withdrawn) = getPlayerVault_();
        require(totalProfit >= withdrawn.add(_vaultEth), "no balance");
        QIU3Ddatasets.Player storage _player_ = players_[msg.sender];
        _player_.withdraw = withdrawn.add(_vaultEth);
        buyTicketCore_(
            _matchId, 
            _fullMatResOpt, 
            _goalsOpt, 
            _gapGoalsOpt, 
            _bothGoalOpt, 
            _halfAndFullMatResOpt, 
            _vaultEth, 
            _inviteAddr);
        emit onWithdraw(msg.sender, _vaultEth, 1);
    }


    /**
     * @dev player buy bet with bet option for current match
     * @param _option match full time result, 0 - home win, 1 - draw , 2 - away win
     * @param _odds odds value player want to buy
     */

    function bet(uint256 _option, uint256 _odds) public
        isHuman() isWithinLimits(msg.value) payable
    {
        betCore_(_option, _odds, msg.value);
    }


    /**
     * @dev player buy bet with vault
     * @param _option match full time result, 0 - home win, 1 - draw , 2 - away win
     * @param _odds odds value player want to buy
     * @param _vaultEth pay eth value from vault
     */

    function betWithVault(uint256 _option, uint256 _odds, uint256 _vaultEth) public
        isHuman() isWithinLimits(_vaultEth)
    {
        uint256 withdrawn = 0;
        uint256 totalProfit = 0; 
        (totalProfit, withdrawn) = getPlayerVault_();
        require(totalProfit >= withdrawn.add(_vaultEth), "no balance");
        QIU3Ddatasets.Player storage _player_ = players_[msg.sender];
        _player_.withdraw = withdrawn.add(_vaultEth);
        betCore_(_option, _odds, _vaultEth);
        emit onWithdraw(msg.sender, _vaultEth, 2);
    }

    
    /**
     * @dev player withdraw profit and dividend, everytime player call withdraw will empty balance
     */
    function withdraw() public isHuman()
    {
        uint256 withdrawn = 0;
        uint256 totalProfit = 0; 
        (totalProfit, withdrawn) = getPlayerVault_();
        require(totalProfit > withdrawn, "no balance");
        QIU3Ddatasets.Player storage _player_ = players_[msg.sender];
        _player_.withdraw = totalProfit;
        msg.sender.transfer(totalProfit.sub(withdrawn));
        emit onWithdraw(msg.sender, totalProfit.sub(withdrawn), 0);
    }

    //==================================================
    // view functions (getter in contract)
    //==================================================
    /** 
     * @dev returns game basic information
     * @return the ID of current match
     * @return ticket price in real time
     * @return the timestamp when match end
     * @return total tickt fund from player buy ticket
     * @return total bet fund from player buy bet
     */
    function getGameInfo() public view returns(uint256, uint256, uint256, uint256, uint256)
    {
        QIU3Ddatasets.Match memory _match_ = matches_[openMatchId_];
        if(openMatchId_ == 0){
            return (openMatchId_, TicketInitPrice, 0, 0, 0);
        }else{
            return (openMatchId_, _match_.currentPrice, _match_.endts, _match_.ticketFund, _match_.betFund);
        }
    }

    /** 
     * @dev returns player information in QIU3D game
     * @return last match id which player buy ticket
     * @return total withdraw amount
     * @return total invite profit
     * @return total ticket profit
     * @return total ticket dividend
     * @return total bet profit
     */
    function getPlayerInGame() public view returns(uint256, uint256, uint256, uint256, uint256, uint256)
    {
        QIU3Ddatasets.Player memory _player_ = players_[msg.sender];
        uint256 totalTicketProfit = 0;
        uint256 totalTicketDividend = 0;
        uint256 totalBetProfit = 0;
        for(uint i = 0 ; i < _player_.matchIds.length; i++){
            uint256 ticketProfit = 0;
            uint256 ticketDividend = 0;
            uint256 betProfit = 0;
            (ticketProfit, ticketDividend, betProfit) = getPlayerProfitInMatch(_player_.matchIds[i]);
            totalTicketProfit = totalTicketProfit.add(ticketProfit);
            totalTicketDividend = totalTicketDividend.add(ticketDividend);
            totalBetProfit = totalBetProfit.add(betProfit);
        }
        return (
            _player_.lastBuyTicketMatchId,
            _player_.withdraw,
            _player_.inviteProfit,
            totalTicketProfit,
            totalTicketDividend,
            totalBetProfit
        );
    }

    /** 
     * @dev returns player profit in special match
     * @param matchId ID of match
     * @return ticket dividend, show before match end.
     * @return ticket profit, show after match end.
     * @return bet profit, show after match end.
     */
    function getPlayerProfitInMatch(uint256 matchId) public view returns(uint256, uint256, uint256)
    {
        uint256 ticketProfit;
        uint256 ticketDividend;
        (ticketProfit, ticketDividend) = getTicketProfitAndDividend(matchId, 0);
        uint256 betProfit = getBetProfit_(matchId);
        return(ticketProfit, ticketDividend, betProfit);
    }

    /** 
     * @dev returns the current bet information 
     * @return return if bet opened
     * @return home win odds
     * @return draw odds
     * @return away win odds
     * @return home team win max sell
     * @return draw win max sell
     * @return away team win max sell
     */
    function getBet() public view returns(bool, uint256, uint256, uint256, uint256, uint256, uint256)
    {
        QIU3Ddatasets.BetReturns memory _betReturn_;
        _betReturn_ = getBetReturns_(_betReturn_);
        return(
            _betReturn_.opened,
            _betReturn_.homeOdds,
            _betReturn_.drawOdds,
            _betReturn_.awayOdds,
            _betReturn_.homeMaxSell,
            _betReturn_.drawMaxSell,
            _betReturn_.awayMaxSell
        );
    }

    /** 
     * @dev returns player's ticket profit and profit in special match
     */
    function getTicketProfitAndDividend(uint256 _matchId, uint256 _ticketId) public view returns(uint256, uint256)
    {
        uint256 totalTicketProfit = 0;
        uint256 totalTicketDividend = 0;
        uint256 _remainTicketJackpot = 0;
        QIU3Ddatasets.Match storage _match_ = matches_[_matchId];
        QIU3Ddatasets.TicketEventIntReturns memory _profitReturns_;
        if(_match_.ended){
            uint256 _ticketJackpot = getTicketJackpot_(_matchId, getBetClearedProfit_(_matchId, _match_.compressedData));
            _profitReturns_ = calculateTicketProfitAssign_(_matchId, _match_.compressedData, _ticketJackpot, _profitReturns_);
            if(_profitReturns_.count == 0){
                _remainTicketJackpot = _ticketJackpot;
            }
        }
        QIU3Ddatasets.MatchPlayer memory _matchPlayer_ = _match_.matchPlayers[msg.sender];
        for(uint i = 0; i < _matchPlayer_.ticketIds.length; i++){
            uint256 tId = 0;
            if(_ticketId != 0){
                tId = _ticketId;
            }else{
                tId = _matchPlayer_.ticketIds[i];
            }
            totalTicketProfit = totalTicketProfit.add(
                calculateTicketProfit_(_matchId, _profitReturns_, _match_.tickets[tId]));
            totalTicketDividend = totalTicketDividend.add(
                calculateTicketDividend_(_matchId, _remainTicketJackpot, _match_.tickets[tId]));
            if(_ticketId != 0){
                //so disgusting code, but gas you know.
                break;
            }
        }
        return (totalTicketProfit, totalTicketDividend);
    }

    //==================================================
    // private functions - calculate player ticket and bet profit
    //==================================================
    /** 
     * @dev calculate one ticket profit in special match
     */
    function calculateTicketProfit_(
        uint256 _matchId, 
        QIU3Ddatasets.TicketEventIntReturns memory _profitReturns_, 
        QIU3Ddatasets.Ticket memory _ticket_
        ) private view returns(uint256)
    {
        uint256 ticketProfit = 0;
        QIU3Ddatasets.Match memory _match_ = matches_[_matchId];
        if(_match_.ended && _profitReturns_.count > 0){
            QIU3Ddatasets.TicketEventBoolReturns memory _compareReturns_ = compareOptionsResult_(
                _ticket_.compressedData, _match_.compressedData, _compareReturns_);
            uint256 optionTicketValue = _ticket_.ticketValue.div(_ticket_.compressedData.div(10000000));
            if(_compareReturns_.fullMatch){
                ticketProfit = ticketProfit.add((_profitReturns_.fullMatch.mul(optionTicketValue)).div(1000000000000000000));
            }
            if(_compareReturns_.totalGoal){
                ticketProfit = ticketProfit.add((_profitReturns_.totalGoal.mul(optionTicketValue)).div(1000000000000000000));
            }
            if(_compareReturns_.gapGoal){
                ticketProfit = ticketProfit.add((_profitReturns_.gapGoal.mul(optionTicketValue)).div(1000000000000000000));
            }
            if(_compareReturns_.bothGoal){
                ticketProfit = ticketProfit.add((_profitReturns_.bothGoal.mul(optionTicketValue)).div(1000000000000000000));
            }
            if(_compareReturns_.halfAndFullMatch){
                ticketProfit = ticketProfit.add((_profitReturns_.halfAndFullMatch.mul(optionTicketValue)).div(1000000000000000000));
            }
        }
        return ticketProfit;
    }

    /** 
     * @dev calculate one ticket dividend in special match
     */
    function calculateTicketDividend_(
        uint256 _matchId, 
        uint256 _remainTicketJackpot, 
        QIU3Ddatasets.Ticket memory _ticket_
        ) private view returns(uint256)
    {
        uint256 totalDividend = 0;
        totalDividend = getTicketDividendFromJackpot_(_matchId, _remainTicketJackpot);
        uint256 totalOptionValues;
        (totalOptionValues, ) = getTotalOptionValues_(_matchId);
        uint256 dividendPerTicket = (totalDividend.mul(1000000000000000000)).div(totalOptionValues);
        uint256 dividend = (_ticket_.ticketValue.mul(dividendPerTicket)).div(1000000000000000000);
        return dividend;
    }

    /** 
     * @dev calculate ticket profit assign in special match, returns all option profit
     */
    function calculateTicketProfitAssign_(
        uint256 _matchId, 
        uint256 _compressResult, 
        uint256 _ticketJackpot, 
        QIU3Ddatasets.TicketEventIntReturns memory _eventReturns_
        ) private view returns(QIU3Ddatasets.TicketEventIntReturns)
    {
        QIU3Ddatasets.TicketEventIntReturns memory _optionReturns_ = getDecompressedOptions_(_compressResult, _optionReturns_);

        uint256 fullMatchValue = ticketOptionValues_[_matchId][_optionReturns_.fullMatch.sub(1)];
        if(fullMatchValue > 0){
            _eventReturns_.count = _eventReturns_.count.add(1);
        }

        uint256 totalGoalValue = 0;
        if(_optionReturns_.totalGoal != InvalidTotalGoals){
            totalGoalValue = ticketOptionValues_[_matchId][_optionReturns_.totalGoal.add(3)];
            if(totalGoalValue > 0){
                _eventReturns_.count = _eventReturns_.count.add(1);
            }
        }

        uint256 gapGoalValue = 0;
        if(_optionReturns_.gapGoal != InvalidGapGoals){
            gapGoalValue = ticketOptionValues_[_matchId][_optionReturns_.gapGoal.add(13)];
            if(gapGoalValue > 0){
                _eventReturns_.count = _eventReturns_.count.add(1);
            }
        }
        uint256 bothGoalValue = ticketOptionValues_[_matchId][_optionReturns_.bothGoal.add(23)];
        if(bothGoalValue > 0){
            _eventReturns_.count = _eventReturns_.count.add(1);
        }
        uint256 halfAndFullMatchValue = ticketOptionValues_[_matchId][_optionReturns_.halfAndFullMatch.add(25)];
        if(halfAndFullMatchValue > 0){
            _eventReturns_.count = _eventReturns_.count.add(1);
        }
        if(_eventReturns_.count != 0){
            uint256 perJackpot = _ticketJackpot.div(_eventReturns_.count);
            if(fullMatchValue > 0){
                _eventReturns_.fullMatch = perJackpot.mul(1000000000000000000).div(fullMatchValue);
            }
            if(totalGoalValue > 0){
                _eventReturns_.totalGoal = perJackpot.mul(1000000000000000000).div(totalGoalValue);
            }
            if(gapGoalValue > 0){
                _eventReturns_.gapGoal = perJackpot.mul(1000000000000000000).div(gapGoalValue);
            }
            if(bothGoalValue > 0){
                _eventReturns_.bothGoal = perJackpot.mul(1000000000000000000).div(bothGoalValue);
            }
            if(halfAndFullMatchValue > 0){
                _eventReturns_.halfAndFullMatch = perJackpot.mul(1000000000000000000).div(halfAndFullMatchValue);
            }
        }
        return(_eventReturns_);
    }

    /** 
     * @dev get player bet profit in special match
     */
    function getBetProfit_(uint256 _matchId) public view returns(uint256)
    {
        uint256 betProfit = 0;
        QIU3Ddatasets.Match storage _match_ = matches_[_matchId];
        if(_match_.ended){
            QIU3Ddatasets.MatchPlayer memory _matchPlayer_ = _match_.matchPlayers[msg.sender];
            for(uint i = 0; i < _matchPlayer_.betIds.length; i++){
                uint256 _betId = _matchPlayer_.betIds[i];
                betProfit = betProfit.add(calculateBetProfit_(_match_, _betId));
            }
        }
        return betProfit;
    }


    /** 
     * @dev calculate one bet profit in special match
     */
    function calculateBetProfit_(QIU3Ddatasets.Match storage _match_, uint256 betId) private view returns(uint256){
        QIU3Ddatasets.Bet memory _bet_ = _match_.bets[betId];
        uint256 option = _match_.compressedData % 10;
        //odds option is different with match's full match result option, need +1
        if(option == _bet_.option.add(1)){
            return (_bet_.odds.mul(_bet_.cost)).div(100);
        }else{
            return 0;
        }
    }

    /** 
    * @dev get bet cleared profit
    */
    function getBetClearedProfit_(uint256 _matchId, uint256 _compressedData) private view returns(uint256)
    {
        uint256 _totalBetJackpot = getBetJackpot_(_matchId);
        QIU3Ddatasets.MatchBetOptions memory _betOption_ = betOptions_[_matchId];
        uint256 matchResult = _compressedData % 10;
        if(matchResult == 1){
            return _totalBetJackpot.sub(_betOption_.homeBetReturns);
        }else if(matchResult == 2){
            return _totalBetJackpot.sub(_betOption_.drawBetReturns);
        }else {
            return _totalBetJackpot.sub(_betOption_.awayBetReturns);
        }
    }

    /** 
     * @dev get player total profit and withdraw
     */
    function getPlayerVault_() private view returns(uint256, uint256){
        uint256 withdrawn = 0;
        uint256 inviteProfit = 0;
        uint256 ticketProfit = 0;
        uint256 ticketDividend = 0;
        uint256 betProfit = 0;
        (,withdrawn, inviteProfit, ticketProfit, ticketDividend, betProfit) = getPlayerInGame();
        uint256 totalProfit = ((inviteProfit.add(ticketProfit)).add(ticketDividend)).add(betProfit);
        return (totalProfit, withdrawn);
    }

    //==================================================
    // private functions - buy ticket
    //==================================================
    /** 
    * @dev buy ticket core
    */
    function buyTicketCore_(
        uint256 _matchId,
        uint256 _fullMatResOpt,
        uint256 _goalsOpt,
        uint256 _gapGoalsOpt,
        uint256 _bothGoalOpt,
        uint256 _halfAndFullMatResOpt,
        uint256 _eth,
        address _inviteAddr
        ) private
    {
        determineMatch_(_matchId);
        QIU3Ddatasets.Match storage _match_ = matches_[openMatchId_];
        require(!_match_.ended && _match_.endts > now, "no match open, wait for next match");

        uint256 _inviteProfit = grantInvitation_(_eth, _inviteAddr);

        QIU3Ddatasets.Ticket memory _ticket_;
        //generate new ticket ID
        uint256 _ticketId = _match_.ticketIds.length.add(1);
        _ticket_.ticketId = _ticketId;
        _ticket_.compressedData = getCompressedOptions_(_fullMatResOpt, _goalsOpt, _gapGoalsOpt, _bothGoalOpt, _halfAndFullMatResOpt);
        _ticket_.playerAddr = msg.sender;
        _ticket_.cost = _eth;
        _ticket_.ticketValue = (_eth.mul(1000000000000000000)).div(_match_.currentPrice);
        
        _match_.ticketIds.push(_ticketId);
        _match_.tickets[_ticketId] = _ticket_;
        _match_.ticketFund = _match_.ticketFund.add(_ticket_.cost.sub(_inviteProfit));
        _match_.currentPrice = getTicketPrice_(_match_.currentPrice, _ticket_.ticketValue);
    
        updatePlayerWithTicket_(_ticket_, _match_);
        updateMatchTicketOptions_(openMatchId_, _ticket_.compressedData, _ticket_.ticketValue);

        emit onNewTicket(
            msg.sender, 
            openMatchId_, 
            _ticketId, 
            _fullMatResOpt,
            _goalsOpt,
            _gapGoalsOpt,
            _bothGoalOpt,
            _halfAndFullMatResOpt,
            _ticket_.ticketValue,
            _eth
        );
    }

    /** 
    * @dev determine if active new match
    */
    function determineMatch_(uint256 _matchId) private
    {
        require(_matchId > 0, "invalid match ID");
        if(_matchId != openMatchId_){
            if(openMatchId_ == 0){
                startNewMatch_(_matchId);
            }else{
                bool ended;
                uint256 halfHomeGoals;
                uint256 halfAwayGoals;
                uint256 homeGoals;
                uint256 awayGoals;
                (ended, halfHomeGoals, halfAwayGoals, homeGoals, awayGoals) = MatchDataInt_.getMatchStatus(openMatchId_);
                require(ended, "waiting match end");
                QIU3Ddatasets.Match storage _match_ = matches_[openMatchId_];
                if(!_match_.ended){
                    _match_.ended = true;
                    _match_.compressedData = getCompressedMatchResult_(halfHomeGoals, halfAwayGoals, homeGoals, awayGoals);
                    emit onEndMatch(openMatchId_, _match_.compressedData);
                    uint256 _fundationDividend = getFoundationDividendFromJackpot_(openMatchId_);
                    foundationAddress_.transfer(_fundationDividend);
                }
                startNewMatch_(_matchId);
            }
        }
    }

    /** 
    * @dev start a new match
    */
    function startNewMatch_(uint256 _matchId) private
    {
        uint256 _newMatchId;
        uint256 _kickoffTime;
        (_newMatchId,_kickoffTime) = MatchDataInt_.getOpenMatchBaseInfo();

        require(_matchId == _newMatchId, "match ID invalid");
        require(_newMatchId > openMatchId_, "No more match opening");
        openMatchId_ = _newMatchId;
        QIU3Ddatasets.Match memory _match_;
        _match_.matchId = _newMatchId;
        _match_.endts = _kickoffTime;
        _match_.currentPrice = TicketInitPrice;
        matchIds_.push(_newMatchId);
        matches_[_newMatchId] = _match_;
    }

    /** 
    * @dev grant invitor profit
    */
    function grantInvitation_(uint256 _eth, address _inviteAddr) private returns(uint256)
    {
        uint256 _inviteProfit = 0;
        if(_inviteAddr != address(0) && _inviteAddr != msg.sender && (players_[_inviteAddr].lastBuyTicketMatchId == openMatchId_)){
            _inviteProfit = (_eth.mul(InviteProfitPercentage)).div(100);
            players_[_inviteAddr].inviteProfit = players_[_inviteAddr].inviteProfit.add(_inviteProfit);
            emit onInvite(msg.sender, _inviteAddr, _inviteProfit);
        }
        return _inviteProfit;
    }

    /**
    * @dev update player data whenever player buy ticket
    */
    function updatePlayerWithTicket_(QIU3Ddatasets.Ticket memory _ticket_, QIU3Ddatasets.Match storage _match_) private
    {
        QIU3Ddatasets.Player storage _player_ = players_[_ticket_.playerAddr];
        _player_.lastBuyTicketMatchId = openMatchId_;

        QIU3Ddatasets.MatchPlayer storage _matchPlayer_ = _match_.matchPlayers[_ticket_.playerAddr];
        _matchPlayer_.ticketIds.push(_ticket_.ticketId);

        bool playerInThisMatch = false;
        for(uint i = 0 ; i < _player_.matchIds.length; i ++){
            if(openMatchId_ == _player_.matchIds[i]){
                playerInThisMatch = true;
            }
        }
        if(!playerInThisMatch){
            _player_.matchIds.push(openMatchId_);
        }
    }

    /**
    * @dev update match data with ticket options, also check if the bet could opened
    */
    function updateMatchTicketOptions_(uint256 _matchId, uint256 _compressedData, uint256 _ticketValue) private
    {
        QIU3Ddatasets.TicketEventBoolReturns memory _validReturns_ = getValidOptions_(_compressedData, _validReturns_);
        QIU3Ddatasets.TicketEventIntReturns memory _optionReturns_ = getDecompressedOptions_(_compressedData, _optionReturns_);
        //option value in ticket = total ticket value / valid options
        uint256 _optionValue = _ticketValue.div(_validReturns_.count);
        if(_validReturns_.fullMatch){
            ticketOptionValues_[_matchId][_optionReturns_.fullMatch.sub(1)] = ticketOptionValues_[_matchId][_optionReturns_.fullMatch.sub(1)].add(_optionValue);
        }
        if(_validReturns_.totalGoal){
            ticketOptionValues_[_matchId][_optionReturns_.totalGoal.add(3)] = ticketOptionValues_[_matchId][_optionReturns_.totalGoal.add(3)].add(_optionValue);
        }
        if(_validReturns_.gapGoal){
            ticketOptionValues_[_matchId][_optionReturns_.gapGoal.add(13)] = ticketOptionValues_[_matchId][_optionReturns_.gapGoal.add(13)].add(_optionValue);
        }
        if(_validReturns_.bothGoal){
            ticketOptionValues_[_matchId][_optionReturns_.bothGoal.add(23)] = ticketOptionValues_[_matchId][_optionReturns_.bothGoal.add(23)].add(_optionValue);
        }
        if(_validReturns_.halfAndFullMatch){
            ticketOptionValues_[_matchId][_optionReturns_.halfAndFullMatch.add(25)] = ticketOptionValues_[_matchId][_optionReturns_.halfAndFullMatch.add(25)].add(_optionValue);
        }

        QIU3Ddatasets.MatchBetOptions storage _betOption_ = betOptions_[_matchId];

        //open gambling conditions
        if(!_betOption_.betOpened){
            //condition 1: at least one player selected each full match result option(home/draw/away) 
            if(ticketOptionValues_[_matchId][0] != 0 && ticketOptionValues_[_matchId][1] != 0 && ticketOptionValues_[_matchId][2] != 0){
                uint256 totalOptionValues;
                uint256 fullMatchOptionValue;
                (totalOptionValues, fullMatchOptionValue) = getTotalOptionValues_(_matchId);
                //condition 2: full match result option value / total option value > 30%
                if((fullMatchOptionValue.mul(100)).div(totalOptionValues) > OddsOpenPercentage){
                    _betOption_.betOpened = true;
                }
            }
        }
    }

    /**
    * @dev get new ticket price
    */
    function getTicketPrice_(uint256 _currentPrice, uint256 _ticketValue) internal pure returns(uint256)
    {
        uint256 tv = _ticketValue.div(1000000000000000000);
        if(tv < PriceThreshold){
            //newPrice = _currentPrice + TicketIncreasePrice
            return (_currentPrice.add(TicketIncreasePrice));
        }else{
            //newPrice = _currentPrice + TicketIncreasePrice * (_ticketValue/PriceThreshold + 1)
            return (_currentPrice.add(TicketIncreasePrice.mul((tv.div(PriceThreshold)).add(1))));
        }
    }  


    //==================================================
    // private functions - ticket options operations
    //==================================================
    /**
    * @dev get total ticket value in current match
    */
    function getTotalOptionValues_(uint256 _matchId) private view returns (uint256, uint256)
    {
        uint256 _totalCount = 0;
        uint256 _fullMatchResult = 0;
        for(uint i = 0 ; i < ticketOptionValues_[_matchId].length; i++){
            if(i <= 2){
                _fullMatchResult = _fullMatchResult.add(ticketOptionValues_[_matchId][i]);
            }
            _totalCount = _totalCount.add(ticketOptionValues_[_matchId][i]);
        }
        return (_totalCount, _fullMatchResult);
    }


    /**
    * @dev compress ticket options value to uint256
    */
    function getCompressedOptions_(uint256 _fullResult, uint256 _totalGoals, uint256 _gapGoals, uint256 _bothGoals, uint256 _halfAndFullResult) 
        private pure returns (uint256)
    {
        //Ticket default settings
        uint256 fullMatResOpt = InvalidFullMatchResult; 
        uint256 goalsOpt = InvalidTotalGoals; 
        uint256 gapGoalsOpt = InvalidGapGoals; 
        uint256 bothGoalOpt = InvalidBothGoals; 
        uint256 halfAndFullMatResOpt = InvalidHalfAndFullMatchResult; 
        uint256 vaildOptions = 0;

        if(_fullResult > 0 && _fullResult <= 3){
            vaildOptions = vaildOptions.add(1);
            fullMatResOpt = _fullResult;
        }
        if(_totalGoals <= 9){
            vaildOptions = vaildOptions.add(1);
            goalsOpt = _totalGoals;
        }
        if(_gapGoals <= 10 ){
            vaildOptions = vaildOptions.add(1);
            gapGoalsOpt = _gapGoals;
        }
        if(_bothGoals == 1 || _bothGoals == 2){
            vaildOptions = vaildOptions.add(1);
            bothGoalOpt = _bothGoals;
        }
        if(_halfAndFullResult > 0 && _halfAndFullResult <= 9){
            vaildOptions = vaildOptions.add(1);
            halfAndFullMatResOpt = _halfAndFullResult;
        }
        //if no vaild option be seleced, select full match result is draw by default
        if(vaildOptions == 0){
            vaildOptions = 1;
            fullMatResOpt == 2;
        }
        uint256 compressedData = fullMatResOpt;
        compressedData = compressedData.add(goalsOpt.mul(10));
        compressedData = compressedData.add(gapGoalsOpt.mul(1000));
        compressedData = compressedData.add(bothGoalOpt.mul(100000));
        compressedData = compressedData.add(halfAndFullMatResOpt.mul(1000000));
        compressedData = compressedData.add(vaildOptions.mul(10000000));
        return (compressedData);
    }

    /**
    * @dev check ticket option's valid count
    */
    function getValidOptions_(uint256 _compressData, QIU3Ddatasets.TicketEventBoolReturns memory _eventReturns_) 
        private pure returns (QIU3Ddatasets.TicketEventBoolReturns)
    {
        _eventReturns_.fullMatch = (_compressData % 10 != InvalidFullMatchResult);
        _eventReturns_.totalGoal = ((_compressData % 1000)/10 != InvalidTotalGoals);
        _eventReturns_.gapGoal = ((_compressData % 100000)/1000 != InvalidGapGoals);
        _eventReturns_.bothGoal = ((_compressData % 1000000)/100000 != InvalidBothGoals);
        _eventReturns_.halfAndFullMatch = ((_compressData % 10000000)/1000000 != InvalidHalfAndFullMatchResult);
        _eventReturns_.count = _compressData/10000000;
        return (_eventReturns_);
    }

    //==================================================
    // private functions - buy bet
    //==================================================
    
    /** 
    * @dev buy bet core
    */
    function betCore_(uint256 _option, uint256 _odds, uint256 _eth) private
    {
        require(_option < 3, "invalid bet option");
        QIU3Ddatasets.Match storage _match_ = matches_[openMatchId_];
        require(!_match_.ended && _match_.endts > now, "no match open, wait for next match");
        QIU3Ddatasets.BetReturns memory _betReturn_;
        _betReturn_ = getBetReturns_(_betReturn_);
        require(_betReturn_.opened, "bet not open");

        QIU3Ddatasets.Bet memory _bet_;
        if(_option == 0){
            require(msg.value <= _betReturn_.homeMaxSell, "not enough to sell");
            require(_odds <= _betReturn_.homeOdds, "invalid odds");
            if(_odds < _betReturn_.homeOdds){
                //when user bet odds less than live bet, only accept the deviation < 3%
                require(((_betReturn_.homeOdds - _odds).mul(100)).div(_betReturn_.homeOdds) <= OddsMaxDeviation, "Odds already changed");
            }
            _bet_.odds = _betReturn_.homeOdds;
        }else if(_option == 1){
            require(msg.value <= _betReturn_.drawMaxSell, "not enough to sell");
            require(_odds <= _betReturn_.drawOdds, "invalid odds");
            if(_odds < _betReturn_.drawOdds){
                //when user bet odds less than live bet, only accept the deviation < 3%
                require(((_betReturn_.drawOdds - _odds).mul(100)).div(_betReturn_.drawOdds) <= OddsMaxDeviation, "Odds already changed");
            }
            _bet_.odds = _betReturn_.drawOdds;
        }else if(_option == 2){
            require(msg.value <= _betReturn_.awayMaxSell, "not enough to sell");
            require(_odds <= _betReturn_.awayOdds, "invalid odds");
            if(_odds < _betReturn_.awayOdds){
                //when user bet odds less than live bet, only accept the deviation < 3%
                require(((_betReturn_.awayOdds - _odds).mul(100)).div(_betReturn_.awayOdds) <= OddsMaxDeviation, "Odds already changed");
            }
            _bet_.odds = _betReturn_.awayOdds;
        }

        //generate new bet ID
        uint256 _betId = _match_.betIds.length.add(1);
        _bet_.betId = _betId;
        _bet_.option = _option;
        _bet_.playerAddr = msg.sender;
        _bet_.cost = _eth;

        _match_.betFund = _match_.betFund.add(_eth);
        _match_.betIds.push(_betId);
        _match_.bets[_betId] = _bet_;

        updatePlayerWithBet_(_bet_, _match_);
        updateMatchBetOptions_(_bet_);
        
        emit onNewBet(msg.sender, _match_.matchId, _betId, _option, _bet_.odds, _eth);
    }

    /**
    * @dev get bet return information
    */
    function getBetReturns_(QIU3Ddatasets.BetReturns memory _betReturn_) private view returns(QIU3Ddatasets.BetReturns)
    {
        QIU3Ddatasets.MatchBetOptions memory _betOption_ = betOptions_[openMatchId_];
        if(_betOption_.betOpened){
            uint256 _totalValue = ticketOptionValues_[openMatchId_][0] + ticketOptionValues_[openMatchId_][1] + ticketOptionValues_[openMatchId_][2];
            _betReturn_.homeOdds = calOdds_(_totalValue, ticketOptionValues_[openMatchId_][0]);
            _betReturn_.drawOdds = calOdds_(_totalValue, ticketOptionValues_[openMatchId_][1]);
            _betReturn_.awayOdds = calOdds_(_totalValue, ticketOptionValues_[openMatchId_][2]);

            uint256 _totalBetJackpot = getBetJackpot_(openMatchId_);
            _betReturn_.homeMaxSell = ((_totalBetJackpot.sub(_betOption_.homeBetReturns)).mul(100)).div(_betReturn_.homeOdds);
            _betReturn_.drawMaxSell = ((_totalBetJackpot.sub(_betOption_.drawBetReturns)).mul(100)).div(_betReturn_.drawOdds);
            _betReturn_.awayMaxSell = ((_totalBetJackpot.sub(_betOption_.awayBetReturns)).mul(100)).div(_betReturn_.awayOdds);
            _betReturn_.opened = true;
        }
        return (_betReturn_);
    }
    
    /**
    * @dev update player information with bet 
    */
    function updatePlayerWithBet_(QIU3Ddatasets.Bet memory _bet_, QIU3Ddatasets.Match storage _match_) private
    {
        QIU3Ddatasets.MatchPlayer storage _matchPlayer_ = _match_.matchPlayers[_bet_.playerAddr];
        _matchPlayer_.betIds.push(_bet_.betId);

        QIU3Ddatasets.Player storage _player_ = players_[_bet_.playerAddr];
        bool playerInThisMatch = false;
        for(uint i = 0 ; i < _player_.matchIds.length; i ++){
            if(openMatchId_ == _player_.matchIds[i]){
                playerInThisMatch = true;
            }
        }
        if(!playerInThisMatch){
            _player_.matchIds.push(openMatchId_);
        }
    }

    /**
    * @dev update bet return with bet 
    */
    function updateMatchBetOptions_(QIU3Ddatasets.Bet memory _bet_) private
    {
        QIU3Ddatasets.MatchBetOptions storage _betOption_ = betOptions_[openMatchId_];
        if(_bet_.option == 0){
            _betOption_.homeBetReturns = _betOption_.homeBetReturns.add((_bet_.cost.mul(_bet_.odds)).div(100));
        }else if(_bet_.option == 1){
            _betOption_.drawBetReturns = _betOption_.drawBetReturns.add((_bet_.cost.mul(_bet_.odds)).div(100));
        }else if(_bet_.option == 2){
            _betOption_.awayBetReturns = _betOption_.awayBetReturns.add((_bet_.cost.mul(_bet_.odds)).div(100));
        }
    }

    /**
    * @dev calculate bet odds
    */
    function calOdds_(uint256 _totalValue, uint256 _optionValue) private pure returns(uint256){
        uint256 _odds = (_totalValue.mul(100)).div(_optionValue);
        uint256 _commission = _odds.div(OddsCommission);
        return (_odds - _commission);
    }


    //==================================================
    // private functions - jackpot and dividend
    //==================================================
    /**
    * @dev get bet jackpot
    */
    function getBetJackpot_(uint256 _matchId) private view returns(uint256)
    {
        QIU3Ddatasets.Match memory _match_ = matches_[_matchId];
        uint256 _betJackpot = ((_match_.ticketFund.mul(BxTJPPercentage)).div(100)).add((_match_.betFund.mul(BxBJPPercentage)).div(100));
        return (_betJackpot);
    }

    /**
    * @dev get ticket jackpot
    */
    function getTicketJackpot_(uint256 _matchId, uint256 _remainBetJackpot) private view returns(uint256)
    {
        QIU3Ddatasets.Match memory _match_ = matches_[_matchId];
        uint256 _ticketJackpot = (_match_.ticketFund.mul(TxTJPPercentage)).div(100);
        _ticketJackpot = _ticketJackpot.add(_remainBetJackpot);
        return (_ticketJackpot);
    }

    /**
    * @dev get ticket dividend
    */
    function getTicketDividendFromJackpot_(uint256 _matchId, uint256 _remainTicketJackpot) private view returns(uint256)
    {
        QIU3Ddatasets.Match memory _match_ = matches_[_matchId];
        uint256 _totalDividend = (_match_.ticketFund.mul(DxTJPPercentage)).div(100);
        if(_match_.ended){
            _totalDividend = _totalDividend.add((_match_.betFund.mul(DxBJPPercentage)).div(100));
            _totalDividend = _totalDividend.add(_remainTicketJackpot);
        }
        uint256 _ticketDividend = (_totalDividend.mul(TxDJPPercentage)).div(100);
        return (_ticketDividend);
    }

    /**
    * @dev get foundation dividend
    */
    function getFoundationDividendFromJackpot_(uint256 _matchId) private view returns(uint256)
    {
        QIU3Ddatasets.Match memory _match_ = matches_[_matchId];
        uint256 _totalDividend = ((_match_.ticketFund.mul(DxTJPPercentage)).div(100)).add((_match_.betFund.mul(DxBJPPercentage)).div(100));

        uint256 _betClearedProfit = getBetClearedProfit_(_matchId, _match_.compressedData);
        uint256 _ticketJackpot = getTicketJackpot_(_matchId, _betClearedProfit);
        QIU3Ddatasets.TicketEventIntReturns memory _profitReturns_ = calculateTicketProfitAssign_(
            _matchId, 
            _match_.compressedData, 
            _ticketJackpot, 
            _profitReturns_);
        
        if(_profitReturns_.count == 0){
            _totalDividend = _totalDividend.add(_ticketJackpot);
        }

        uint256 _foundationDividend = (_totalDividend.mul(FxDJPPercentage)).div(100);
        return (_foundationDividend);
    }

    /**
    * @dev compare two compressed ticket option and return bool resuts
    */
    function compareOptionsResult_(uint256 optionData, uint256 resultData, QIU3Ddatasets.TicketEventBoolReturns memory _eventReturns_) 
        private pure returns(QIU3Ddatasets.TicketEventBoolReturns)
    {
        _eventReturns_.fullMatch = (optionData % 10 == resultData % 10);
        _eventReturns_.totalGoal = ((optionData % 1000)/10 == (resultData % 1000)/10) && ((resultData % 1000)/10 != InvalidTotalGoals);
        _eventReturns_.gapGoal = ((optionData % 100000)/1000 == (resultData % 100000)/1000) && ((resultData % 100000)/1000 != InvalidGapGoals);
        _eventReturns_.bothGoal = ((optionData % 1000000)/100000 == (resultData % 1000000)/100000);
        _eventReturns_.halfAndFullMatch = ((optionData % 10000000)/1000000 == (resultData % 10000000)/1000000);
        return (_eventReturns_);
    }

    /**
    * @dev convert match score to ticket options value and compress to uint256
    */
    function getCompressedMatchResult_(uint256 _halfHomeGoals, uint256 _halfAwayGoals, uint256 _homeGoals, uint256 _awayGoals)
        private pure returns (uint256)
    {
        uint256 validCount = 5;
        //calculate full time match result
        uint256 fullMatchResult;
        //calculate gap goal = home goals - away goals
        uint256 gapGoal;
        if(_homeGoals >= _awayGoals){
            gapGoal = (_homeGoals.sub(_awayGoals)).add(5);
            if(gapGoal > 10){
                gapGoal = InvalidGapGoals;
                validCount = validCount.sub(1);
            }
        }else{
            gapGoal = _awayGoals.sub(_homeGoals);
            if(gapGoal > 5){
                gapGoal = InvalidGapGoals;
                validCount = validCount.sub(1);
            }else{
                gapGoal = 5 - gapGoal;
            }
        }
        uint256 halfAndFullResult;
        //calculate half and full time match result
        if(_homeGoals > _awayGoals){
            fullMatchResult = 1;
            if(_halfHomeGoals > _halfAwayGoals){
                halfAndFullResult = 1;
            }else if(_halfHomeGoals == _halfAwayGoals){
                halfAndFullResult = 2;
            }else{
                halfAndFullResult = 3;
            }
        }else if(_homeGoals == _awayGoals){
            fullMatchResult = 2;
            if(_halfHomeGoals > _halfAwayGoals){
                halfAndFullResult = 4;
            }else if(_halfHomeGoals == _halfAwayGoals){
                halfAndFullResult = 5;
            }else{
                halfAndFullResult = 6;
            }
        }else{
            fullMatchResult = 3;
            if(_halfHomeGoals > _halfAwayGoals){
                halfAndFullResult = 7;
            }else if(_halfHomeGoals == _halfAwayGoals){
                halfAndFullResult = 8;
            }else{
                halfAndFullResult = 9;
            }
        }
        //calculate both team goals result
        uint256 bothGoalResult = 1;
        if(_homeGoals == 0 || _awayGoals == 0){
            bothGoalResult = 2;
        }
        //calculate total goals result
        uint256 totalGoalResult = _homeGoals + _awayGoals;
        if(totalGoalResult > 9){
            totalGoalResult = InvalidTotalGoals;
            validCount = validCount.sub(1);
        }

        uint256 compressedData = fullMatchResult;
        compressedData = compressedData.add(totalGoalResult.mul(10));
        compressedData = compressedData.add(gapGoal.mul(1000));
        compressedData = compressedData.add(bothGoalResult.mul(100000));
        compressedData = compressedData.add(halfAndFullResult.mul(1000000));
        compressedData = compressedData.add(validCount.mul(10000000));

        return (compressedData);
    }

    /**
    * @dev decompress ticket options
    */
    function getDecompressedOptions_(uint256 _compressData, QIU3Ddatasets.TicketEventIntReturns memory _eventReturns_) 
        private pure returns (QIU3Ddatasets.TicketEventIntReturns)
    {
        _eventReturns_.fullMatch = _compressData % 10;
        _eventReturns_.totalGoal = (_compressData % 1000)/10;
        _eventReturns_.gapGoal = (_compressData % 100000)/1000;
        _eventReturns_.bothGoal = (_compressData % 1000000)/100000;
        _eventReturns_.halfAndFullMatch = (_compressData % 10000000)/1000000;
        _eventReturns_.count = _compressData/10000000;
        return (_eventReturns_);
    }
}


//==================================================
// Interface
//==================================================
interface Q3DMatchDataInterface {
   function getOpenMatchBaseInfo() external view returns(uint256, uint256);
   function getMatchStatus(uint256 _matchId) external view returns(bool, uint256, uint256, uint256, uint256);
}

//==================================================
// Structs - Storage 
//==================================================

library QIU3Ddatasets{

    struct Match{
        bool ended;                     //if match ended
        uint256 matchId;                //ID of soccer match      
        uint256 endts;                  //match end timestamp
        uint256 currentPrice;           //current ticket price
        uint256 ticketFund;             //fund of ticket
        uint256 betFund;                //fund of bet
        uint256 compressedData;         //compressed options for match result
        uint256[] ticketIds;            //ticket IDs in this match
        uint256[] betIds;               //bet IDs in this match
        mapping(uint256 => Ticket) tickets; //(ticketID => Ticket) return card by cardId
        mapping(uint256 => Bet) bets;   //(betId => Bet) return bet by betId
        mapping(address => MatchPlayer) matchPlayers;   //(address => MatchPlayer) return player in match by address
    }

    struct Player{
        uint256 lastBuyTicketMatchId;   //save the last match ID when player buy ticket, check the player have right to invit other players
        uint256 inviteProfit;   //profit by invite player
        uint256 withdraw;       //player total withdraw
        uint256[] matchIds;     //IDs of player join matches
    }

    struct MatchPlayer{
        uint256[] ticketIds; 
        uint256[] betIds;
    }

    //====== Ticket Options ======
    // compressedData Ticet Options
    // [7][6][5][4-3][2-1][0]
    // [0]: Full time match result option(0 - 9)
        // 0 - none
        // 1 - home team win 
        // 2 - draw
        // 3 - away team win 
    // [2-1]: Full time total goals option(0 - 9)
        // 88 - none
    // [4-3]: Home goals minus Away goals option(0 - 99)
        // 88 - none
    // [5]: Both team goal(0 - 9)
        // 0 - none
        // 1 - yes
        // 2 - no
    // [6]: Half and full time match result option(0 - 9)
        // 0 - none
        // 1 - home/home
        // 2 - home/draw
        // 3 - home/away
        // 4 - draw/home
        // 5 - draw/draw
        // 6 - draw/away
        // 7 - away/home
        // 8 - away/draw
        // 9 - away/away
    // [7]: valid option count(0 - 9)
    struct Ticket{
        uint256 compressedData;     //compressed ticket options data
        uint256 ticketId;       //ID of ticket
        address playerAddr;     //address of player
        uint256 ticketValue;    //value of ticket
        uint256 cost;           //cost of buy ticket
    }

    struct Bet{
        uint256 betId;          //ID of bet
        address playerAddr;     //address of player
        uint256 option;           //player selected option (0 - home, 1 - draw , 2- away)
        uint256 odds;           //odds when player bet
        uint256 cost;           //cost of bet
    }

    struct MatchBetOptions{
        bool betOpened;
        uint256 homeBetReturns;
        uint256 drawBetReturns;
        uint256 awayBetReturns;
    }

    //==================================================
    // Structs - Returns value
    //==================================================
    struct BetReturns{
        bool opened;
        uint256 homeOdds;
        uint256 drawOdds;
        uint256 awayOdds;
        uint256 homeMaxSell;
        uint256 drawMaxSell;
        uint256 awayMaxSell; 
    }

    struct TicketEventIntReturns{
        uint256 fullMatch;
        uint256 totalGoal;
        uint256 gapGoal;
        uint256 bothGoal;
        uint256 halfAndFullMatch;
        uint256 count;
    }

    struct TicketEventBoolReturns{
        bool fullMatch;
        bool totalGoal;
        bool gapGoal;
        bool bothGoal;
        bool halfAndFullMatch;
        uint256 count;
    }
}