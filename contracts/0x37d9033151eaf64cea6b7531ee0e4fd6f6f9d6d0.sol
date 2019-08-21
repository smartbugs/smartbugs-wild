pragma solidity ^0.4.25;

contract EthCrystal
{

    /*
        EthCrystal.com
        Thanks for choosing us!

        ███████╗████████╗██╗  ██╗ ██████╗██████╗ ██╗   ██╗███████╗████████╗ █████╗ ██╗         ██████╗ ██████╗ ███╗   ███╗
        ██╔════╝╚══██╔══╝██║  ██║██╔════╝██╔══██╗╚██╗ ██╔╝██╔════╝╚══██╔══╝██╔══██╗██║        ██╔════╝██╔═══██╗████╗ ████║
        █████╗     ██║   ███████║██║     ██████╔╝ ╚████╔╝ ███████╗   ██║   ███████║██║        ██║     ██║   ██║██╔████╔██║
        ██╔══╝     ██║   ██╔══██║██║     ██╔══██╗  ╚██╔╝  ╚════██║   ██║   ██╔══██║██║        ██║     ██║   ██║██║╚██╔╝██║
        ███████╗   ██║   ██║  ██║╚██████╗██║  ██║   ██║   ███████║   ██║   ██║  ██║███████╗██╗╚██████╗╚██████╔╝██║ ╚═╝ ██║
        ╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝

        #######               #####
        #       ##### #    # #     # #####  #   #  ####  #####   ##   #           ####   ####  #    #
        #         #   #    # #       #    #  # #  #        #    #  #  #          #    # #    # ##  ##
        #####     #   ###### #       #    #   #    ####    #   #    # #          #      #    # # ## #
        #         #   #    # #       #####    #        #   #   ###### #      ### #      #    # #    #
        #         #   #    # #     # #   #    #   #    #   #   #    # #      ### #    # #    # #    #
        #######   #   #    #  #####  #    #   #    ####    #   #    # ###### ###  ####   ####  #    #

        Telegram: t.me/EthCrystalGame
        
        This is the second versoin of our smart-contract.
        We have fixed all bugs and set the new speed values for Rounds so it is easier for users to play.
        The first smart-contract address is: 0x5c6d8bb345f4299c76f24fc771ef04dd160c4d36
        
        There is no code which can be only executed by the contract creators.

    */
    using SafeMath for *;

    // Tower Type details
    struct TowersInfoList {
        string name; // Tower name
        uint256 timeLimit; // Maximum time increasement
        uint256 warriorToTime; // Amount of seconds each warrior adds
        uint256 currentRoundID; // Current Round ID
        uint256 growthCoefficient; // Each warrior being bought increases the price of the next warrior. 
        uint256 winnerShare; // % to winner after the round [Active Fond]
        uint256 nextRound; // % to next round pot
        uint256 dividendShare; // % as dividends to holders after the round

        mapping (uint256 => TowersInfo) RoundList; // Here the Rounds for each Tower are stored
    }
    
    // Round details
    struct TowersInfo {
        uint256 roundID; // The Current Round ID
        uint256 towerBalance; // Balance for distribution in the end
        uint256 totalBalance; // Total balance with referrer or dev %
        uint256 totalWarriors; // Total warriors being bought
        uint256 timeToFinish; // The time when the round will be finished
        uint256 timeLimit; // The maximum increasement
        uint256 warriorToTime; // Amount of seconds each warrior adds
        uint256 bonusPot; // % of tower balance from the previous round
        address lastPlayer; // The last player bought warriors
    }

    // Player Details
    struct PlayerInfo {
        uint256 playerID; // Player's Unique Identifier
        address playerAddress; // Player's Ethereum Address
        address referralAddress; // Store the Ethereum Address of the referrer
        string nickname; // Player's Nickname
        mapping (uint256 => TowersRoundInfo) TowersList;
    }

    
    struct TowersRoundInfo {
        uint256 _TowerType;
        mapping (uint256 => PlayerRoundInfo) RoundList;
    }
    
    // All player's warriors for a particular Round
    struct PlayerRoundInfo {
        uint256 warriors;
        uint256 cashedOut; // To Allow cashing out before the game finished
    }
    
    // In-Game balance (Returnings + Referral Payings)
    struct ReferralInfo {
        uint256 balance;
    }

    uint256 public playerID_counter = 1; // The Unique Identifier for the next created player

    uint256 public devShare = 5; // % to devs
    uint256 public affShare = 10; // bounty % to reffers

    mapping (address => PlayerInfo) public players; // Storage for players
    mapping (uint256 => PlayerInfo) public playersByID; // Duplicate of the storage for players

    mapping (address => ReferralInfo) public aff; // Storage for player refferal and returnings balances.

    mapping (uint256 => TowersInfoList) public GameRounds; // Storage for Tower Rounds

    address public ownerAddress; // The address of the contract creator
    
    event BuyEvent(address player, uint256 TowerID, uint256 RoundID, uint256 TotalWarriors, uint256 WarriorPrice, uint256 TimeLeft);

    constructor() public {
        ownerAddress = msg.sender; // Setting the address of the contact creator

        // Creating Tower Types
        GameRounds[0] = TowersInfoList("Crystal Tower", 60*60*3,  60*3, 0,      10000000000000,     35, 15, 50);
        GameRounds[1] = TowersInfoList("Red Tower",     60*60*3,  60*3, 0,      20000000000000,     25,  5, 70);
        GameRounds[2] = TowersInfoList("Gold Tower",    60*60*3,  60*3, 0,     250000000000000,     40, 10, 50);
        GameRounds[3] = TowersInfoList("Purple Tower",  60*60*6,  60*3, 0,    5000000000000000,     30, 10, 60);
        GameRounds[4] = TowersInfoList("Silver Tower",  60*60*6,  60*3, 0,    1000000000000000,     35, 15, 50);
        GameRounds[5] = TowersInfoList("Black Tower",   60*60*6,  60*3, 0,    1000000000000000,     65, 10, 25);
        GameRounds[6] = TowersInfoList("Toxic Tower",   60*60*6,  60*3, 0,    2000000000000000,     65, 10, 25);

        // Creating first Rounds for each Tower Type
        newRound(0);
        newRound(1);
        newRound(2);
        newRound(3);
        newRound(4);
        newRound(5);
        newRound(6);
    }

    /**
     * @dev Creates a new Round of a paricular Tower
     * @param _TowerType the tower type (0 to 6)
     */
    function newRound (uint256 _TowerType) private {
        GameRounds[_TowerType].currentRoundID++;
        GameRounds[_TowerType].RoundList[GameRounds[_TowerType].currentRoundID] = TowersInfo(GameRounds[_TowerType].currentRoundID, 0, 0, 0, now+GameRounds[_TowerType].timeLimit, GameRounds[_TowerType].timeLimit, GameRounds[_TowerType].warriorToTime,
        GameRounds[_TowerType].RoundList[GameRounds[_TowerType].currentRoundID-1].towerBalance*GameRounds[_TowerType].nextRound/100, // Moving nextRound% of the finished round balance to the next round
        0x0); // New round
    }
    
    
    /**
     * @dev Use to buy warriors for the current round of a particular Tower
     * When the Round ends, somebody have to buy 1 warrior to start the new round.
     * All ETH the player overpaid will be sent back to his balance ("referralBalance").
     * @param _TowerType the tower type (0 to 6)
     * @param _WarriorsAmount the amoun of warriors player would like to buy (at least 1)
     * @param _referralID Default Value: 0. The ID of the player which will receive the 10% of the warriors cost.
     */
    function buyWarriors (uint256 _TowerType, uint _WarriorsAmount, uint256 _referralID) public payable {
        require (msg.value > 10000000); // To prevent % abusing
        require (_WarriorsAmount >= 1 && _WarriorsAmount < 1000000000); // The limitation of the amount of warriors being bought in 1 time
        require (GameRounds[_TowerType].timeLimit > 0); // Checking if the _TowerType exists

        if (players[msg.sender].playerID == 0){ // this is the new player
            if (_referralID > 0 && _referralID != players[msg.sender].playerID && _referralID == playersByID[_referralID].playerID){
                setNickname("", playersByID[_referralID].playerAddress);  // Creating a new player...
            }else{
                setNickname("", ownerAddress);
            }
        }

        if (GameRounds[_TowerType].RoundList[GameRounds[_TowerType].currentRoundID].timeToFinish < now){
            // The game was ended. Starting the new game...

            // Sending pot to the winner
            aff[GameRounds[_TowerType].RoundList[GameRounds[_TowerType].currentRoundID].lastPlayer].balance += GameRounds[_TowerType].RoundList[GameRounds[_TowerType].currentRoundID].towerBalance*GameRounds[_TowerType].winnerShare/100;

            // Sending the bonus pot to the winner
            aff[GameRounds[_TowerType].RoundList[GameRounds[_TowerType].currentRoundID].lastPlayer].balance += GameRounds[_TowerType].RoundList[GameRounds[_TowerType].currentRoundID].bonusPot;

            newRound(_TowerType);
            //Event Winner and the new round
            //return;
        }

        // Getting the price of the current warrior
        uint256 _totalWarriors = GameRounds[_TowerType].RoundList[GameRounds[_TowerType].currentRoundID].totalWarriors;
        uint256 _warriorPrice = (_totalWarriors+1)*GameRounds[_TowerType].growthCoefficient; // Warrior Price

        uint256 _value = (_WarriorsAmount*_warriorPrice)+(((_WarriorsAmount-1)*(_WarriorsAmount-1)+_WarriorsAmount-1)/2)*GameRounds[_TowerType].growthCoefficient;

        require (msg.value >= _value); // Player pays enough

        uint256 _ethToTake = affShare+devShare; // 15%


        players[msg.sender].TowersList[_TowerType].RoundList[GameRounds[_TowerType].currentRoundID].warriors += _WarriorsAmount;

        if (players[players[msg.sender].referralAddress].playerID > 0 && players[msg.sender].referralAddress != ownerAddress){
            // To referrer and devs. In this case, referrer gets 10%, devs get 5%
            aff[players[msg.sender].referralAddress].balance += _value*affShare/100; // 10%
            aff[ownerAddress].balance += _value*devShare/100; // 5%
        } else {
            // To devs only. In this case, devs get 10%
            _ethToTake = affShare;
            aff[ownerAddress].balance += _value*_ethToTake/100; // 10%
        }

        if (msg.value-_value > 0){
            aff[msg.sender].balance += msg.value-_value; // Returning to player the rest of eth
        }

        GameRounds[_TowerType].RoundList[GameRounds[_TowerType].currentRoundID].towerBalance += _value*(100-_ethToTake)/100; // 10-15%
        GameRounds[_TowerType].RoundList[GameRounds[_TowerType].currentRoundID].totalBalance += _value;
        GameRounds[_TowerType].RoundList[GameRounds[_TowerType].currentRoundID].totalWarriors += _WarriorsAmount;
        GameRounds[_TowerType].RoundList[GameRounds[_TowerType].currentRoundID].lastPlayer = msg.sender;

        // Timer increasement
        GameRounds[_TowerType].RoundList[GameRounds[_TowerType].currentRoundID].timeToFinish += (_WarriorsAmount).mul(GameRounds[_TowerType].RoundList[GameRounds[_TowerType].currentRoundID].warriorToTime);

        // if the finish time is longer than the finish
        if (GameRounds[_TowerType].RoundList[GameRounds[_TowerType].currentRoundID].timeToFinish > now+GameRounds[_TowerType].RoundList[GameRounds[_TowerType].currentRoundID].timeLimit){
            GameRounds[_TowerType].RoundList[GameRounds[_TowerType].currentRoundID].timeToFinish = now+GameRounds[_TowerType].RoundList[GameRounds[_TowerType].currentRoundID].timeLimit;
        }
        
        uint256 TotalWarriors = GameRounds[_TowerType].RoundList[GameRounds[_TowerType].currentRoundID].totalWarriors;
        uint256 TimeLeft = GameRounds[_TowerType].RoundList[GameRounds[_TowerType].currentRoundID].timeToFinish;
        
        // Event about the new potential winner and some Tower Details
        emit BuyEvent(msg.sender,
        _TowerType,
        GameRounds[_TowerType].currentRoundID,
        TotalWarriors,
        (TotalWarriors+1)*GameRounds[_TowerType].growthCoefficient,
        TimeLeft);
        
        return;
    }

    /**
     * @dev Claim the player's dividends of any round.
     * @param _TowerType the tower type (0 to 6)
     * @param _RoundID the round ID
     */
    function dividendCashout (uint256 _TowerType, uint256 _RoundID) public {
        require (GameRounds[_TowerType].timeLimit > 0);

        uint256 _warriors = players[msg.sender].TowersList[_TowerType].RoundList[_RoundID].warriors;
        require (_warriors > 0);
        uint256 _totalEarned = _warriors*GameRounds[_TowerType].RoundList[_RoundID].towerBalance*GameRounds[_TowerType].dividendShare/GameRounds[_TowerType].RoundList[_RoundID].totalWarriors/100;
        uint256 _alreadyCashedOut = players[msg.sender].TowersList[_TowerType].RoundList[_RoundID].cashedOut;
        uint256 _earnedNow = _totalEarned-_alreadyCashedOut;
        require (_earnedNow > 0); // The total amount of dividends haven't been received by the player yet

        players[msg.sender].TowersList[_TowerType].RoundList[_RoundID].cashedOut = _totalEarned;

        if (!msg.sender.send(_earnedNow)){
            players[msg.sender].TowersList[_TowerType].RoundList[_RoundID].cashedOut = _alreadyCashedOut;
        }
        return;
    }

    /**
     * @dev Claim the player's In-Game balance such as returnings and referral payings.
     */
    function referralCashout () public {
        require (aff[msg.sender].balance > 0);

        uint256 _balance = aff[msg.sender].balance;

        aff[msg.sender].balance = 0;

        if (!msg.sender.send(_balance)){
            aff[msg.sender].balance = _balance;
        }
    }

    /**
     * @dev Creates the new account
     * @param nickname the nickname player would like to use (better to leave it empty)
     * @param _referralAddress (the address of the player who invited the user)
     */
    function setNickname (string nickname, address _referralAddress)
    public {
        if (players[msg.sender].playerID == 0){
            players[msg.sender] = PlayerInfo (playerID_counter, msg.sender, _referralAddress, nickname);
            playersByID[playerID_counter] = PlayerInfo (playerID_counter, msg.sender, _referralAddress, nickname);
            playerID_counter++;
        }else{
            players[msg.sender].nickname = nickname;
            playersByID[players[msg.sender].playerID].nickname = nickname;
        }
    }


    /**
     * @dev The following functions are for the web-site implementation to get details about Towers, Rounds and Players
     */
     
    function _playerRoundsInfo (address _playerAddress, uint256 _TowerType, uint256 _RoundID)
    public
    view
    returns (uint256, uint256, uint256, uint256, bool, address) {
        uint256 _warriors = players[_playerAddress].TowersList[_TowerType].RoundList[_RoundID].warriors;
        TowersInfo memory r = GameRounds[_TowerType].RoundList[_RoundID];
        bool isFinished = true;
        if (r.timeToFinish > now){
            isFinished = false;
        }
        return (
        r.towerBalance*GameRounds[_TowerType].winnerShare/100,
        _currentPlayerAmountUnclaimed(_playerAddress, _TowerType, _RoundID),
        _warriors,
        r.totalWarriors,
        isFinished,
        r.lastPlayer);
    }


    function _currentPlayerAmountUnclaimed (address _playerAddress, uint256 _TowerType, uint256 _RoundID)
    public
    view
    returns (uint256) {
        if (_RoundID == 0){
            _RoundID = GameRounds[_TowerType].currentRoundID;
        }
        uint256 _warriors = players[_playerAddress].TowersList[_TowerType].RoundList[_RoundID].warriors;
        uint256 _totalForCashOut = (_warriors*GameRounds[_TowerType].RoundList[_RoundID].towerBalance*GameRounds[_TowerType].dividendShare/GameRounds[_TowerType].RoundList[_RoundID].totalWarriors/100);
        uint256 _unclaimedAmount = _totalForCashOut-players[_playerAddress].TowersList[_TowerType].RoundList[_RoundID].cashedOut;
        return (_unclaimedAmount);
    }
    
    function _playerInfo (uint256 _playerID)
    public
    view
    returns (uint256, address, string, uint256) {
        return (playersByID[_playerID].playerID,
        playersByID[_playerID].playerAddress,
        playersByID[_playerID].nickname,
        aff[playersByID[_playerID].playerAddress].balance);
    }

    function _playerBalance (address _playerAddress)
    public
    view
    returns (uint256) {
        return aff[_playerAddress].balance;
    }

    function _TowerRoundDetails (uint256 _TowerType, uint256 _RoundID)
    public
    view
    returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, address) {
        TowersInfo memory r = GameRounds[_TowerType].RoundList[_RoundID];
        return (
        r.roundID,
        r.towerBalance,
        r.totalBalance,
        r.totalWarriors,
        r.timeToFinish,
        r.timeLimit,
        r.warriorToTime,
        r.bonusPot,
        r.lastPlayer
        );
    }
}

library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }

    /**
     * @dev gives square root of given x.
     */
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y)
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y)
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }

    /**
     * @dev gives square. multiplies x by x
     */
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }

    /**
     * @dev x to the power of y
     */
    function pwr(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }
}