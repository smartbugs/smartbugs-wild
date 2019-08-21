pragma solidity ^0.4.25;

/*
* CryptoMiningWar - Build your own empire on Blockchain
* Author: InspiGames
* Website: https://cryptominingwar.github.io/
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

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}
contract CryptoEngineerInterface {
    uint256 public prizePool = 0;
    address public gameSponsor;
    function getPlayerData(address /*_addr*/) 
    public 
    pure 
    returns(
        uint256 /*_engineerRoundNumber*/, 
        uint256 /*_virusNumber*/, 
        uint256 /*_virusDefence*/, 
        uint256 /*_research*/, 
        uint256 /*_researchPerDay*/, 
        uint256 /*_lastUpdateTime*/, 
        uint256[8] /*_engineersCount*/, 
        uint256 /*_nextTimeAtk*/,
        uint256 /*_endTimeUnequalledDef*/
    ) {}
    function fallback() public payable {}
    function claimPrizePool(address /*_addr*/, uint256 /*_value*/) public pure {} 
    function isContractMiniGame() public pure returns( bool /*_isContractMiniGame*/) {}
}
contract CryptoMiningWarInterface {
    uint256 public deadline; 
    mapping(address => PlayerData) public players;
    struct PlayerData {
        uint256 roundNumber;
        mapping(uint256 => uint256) minerCount;
        uint256 hashrate;
        uint256 crystals;
        uint256 lastUpdateTime;
        uint256 referral_count;
        uint256 noQuest;
    }
    function getPlayerData(address /*addr*/) public pure
    returns (
        uint256 /*crystals*/, 
        uint256 /*lastupdate*/, 
        uint256 /*hashratePerDay*/, 
        uint256[8] /*miners*/, 
        uint256 /*hasBoost*/, 
        uint256 /*referral_count*/, 
        uint256 /*playerBalance*/, 
        uint256 /*noQuest*/ 
        ) {}
    function subCrystal( address /*_addr*/, uint256 /*_value*/ ) public pure {}
}
contract CryptoAirdropGameInterface {
    mapping(address => PlayerData) public players;
    struct PlayerData {
        uint256 currentMiniGameId;
        uint256 lastMiniGameId; 
        uint256 win;
        uint256 share;
        uint256 totalJoin;
        uint256 miningWarRoundNumber;
    }
    function isContractMiniGame() public pure returns( bool /*_isContractMiniGame*/ ) {}
}
contract CryptoBossWannaCryInterface {
    mapping(address => PlayerData) public players;
    struct PlayerData {
        uint256 currentBossRoundNumber;
        uint256 lastBossRoundNumber;
        uint256 win;
        uint256 share;
        uint256 dame; 
        uint256 nextTimeAtk;
    }
    function isContractMiniGame() public pure returns( bool /*_isContractMiniGame*/ ) {}
}
contract CrystalDeposit {
    using SafeMath for uint256;

    bool private init = false;
    address private administrator;
    // mini game
    uint256 private round = 0;
    uint256 private HALF_TIME       = 1 days;
    uint256 private RESET_QUEST_TIME= 4 hours;
    uint256 constant private RESET_QUEST_FEE = 0.005 ether; 
    address private engineerAddress;

    CryptoEngineerInterface     public Engineer;
    CryptoMiningWarInterface    public MiningWar;
    CryptoAirdropGameInterface  public AirdropGame;
    CryptoBossWannaCryInterface public BossWannaCry;
    
    // mining war info
    uint256 private miningWarDeadline;
    uint256 constant private CRTSTAL_MINING_PERIOD = 86400;
    /** 
    * @dev mini game information
    */
    mapping(uint256 => Game) public games;
    // quest info 
    mapping(uint256 => Quest) public quests;

    mapping(address => PlayerQuest) public playersQuests;
    /** 
    * @dev player information
    */
    mapping(address => Player) public players;
   
    struct Game {
        uint256 round;
        uint256 crystals;
        uint256 prizePool;
        uint256 endTime;
        bool ended; 
    }
    struct Player {
        uint256 currentRound;
        uint256 lastRound;
        uint256 reward;
        uint256 share; // your crystals share in current round 
        uint256 questSequence;
        uint256 totalQuestFinish;
        uint256 resetFreeTime;
    }
    struct Quest {
        uint256 typeQuest;
        uint256 levelOne;
        uint256 levelTwo;
        uint256 levelThree;
        uint256 levelFour;
    }
    struct PlayerQuest {
        bool haveQuest;
        uint256 questId;
        uint256 level;
        uint256 numberOfTimes;
        uint256 deposit;
        uint256 miningWarRound;   // current mining war round player join
        uint256 referralCount;    // current referral_count
        uint256 totalMiner;       // current total miner
        uint256 totalEngineer;    // current total engineer
        uint256 airdropGameId;    // current airdrop game id
        uint256 totalJoinAirdrop; // total join the airdrop game
        uint256 nextTimeAtkPlayer; // 
        uint256 dameBossWannaCry; // current dame boss
        uint256 levelBossWannaCry; // current boss player atk
    }
    event EndRound(uint256 round, uint256 crystals, uint256 prizePool, uint256 endTime);
    event AddPlayerQuest(address player, uint256 questId, uint256 questLv, uint256 deposit);
    event ConfirmQuest(address player, uint256 questId, uint256 questLv, uint256 deposit, uint256 bonus, uint256 percent);
    modifier isAdministrator()
    {
        require(msg.sender == administrator);
        _;
    }
    modifier disableContract()
    {
        require(tx.origin == msg.sender);
        _;
    }

    constructor() public {
        administrator = msg.sender;
        initQuests();
        engineerAddress = address(0x69fd0e5d0a93bf8bac02c154d343a8e3709adabf);
        setMiningWarInterface(0xf84c61bb982041c030b8580d1634f00fffb89059);
        setEngineerInterface(engineerAddress);
        setAirdropGameInterface(0x5b813a2f4b58183d270975ab60700740af00a3c9);
        setBossWannaCryInterface(0x54e96d609b183196de657fc7380032a96f27f384);
    }
    function initQuests() private
    {
                  //     type   level 1   level 2   level 3   level 4
        quests[0] = Quest(1     , 5       , 10      , 15      , 20   ); // Win x Starter Quest
        quests[1] = Quest(2     , 1       , 2       , 3       , 4    ); // Buy x Miner
        quests[2] = Quest(3     , 1       , 2       , 3       , 4    ); // Buy x Engineer
        quests[3] = Quest(4     , 1       , 1       , 1       , 1    ); // Join An Airdrop Game
        quests[4] = Quest(5     , 1       , 1       , 1       , 1    ); // Attack x Player
        quests[5] = Quest(6     , 100     , 1000    , 10000   ,100000); // Attack x Hp Boss WannaCry
    }
    function () public payable
    {
        if (engineerAddress != msg.sender) addCurrentPrizePool(msg.value);   
    }
    // ---------------------------------------------------------------------------------------
    // SET INTERFACE CONTRACT
    // ---------------------------------------------------------------------------------------
    
    function setMiningWarInterface(address _addr) public isAdministrator
    {
        MiningWar = CryptoMiningWarInterface(_addr);
    }
    function setEngineerInterface(address _addr) public isAdministrator
    {
        CryptoEngineerInterface engineerInterface = CryptoEngineerInterface(_addr);
        
        require(engineerInterface.isContractMiniGame() == true);

        engineerAddress = _addr;
        Engineer = engineerInterface;
    }
    function setAirdropGameInterface(address _addr) public isAdministrator
    {
        CryptoAirdropGameInterface airdropGameInterface = CryptoAirdropGameInterface(_addr);
        
        require(airdropGameInterface.isContractMiniGame() == true);

        AirdropGame = airdropGameInterface;
    }
    function setBossWannaCryInterface(address _addr) public isAdministrator
    {
        CryptoBossWannaCryInterface bossWannaCryInterface = CryptoBossWannaCryInterface(_addr);
        
        require(bossWannaCryInterface.isContractMiniGame() == true);

        BossWannaCry = bossWannaCryInterface;
    }
    /** 
    * @dev MainContract used this function to verify game's contract
    */
    function isContractMiniGame() public pure returns( bool _isContractMiniGame )
    {
        _isContractMiniGame = true;
    }
    function upgrade(address addr) public isAdministrator
    {
        selfdestruct(addr);
    }
    // ---------------------------------------------------------------------------------------------
    // SETUP GAME
    // ---------------------------------------------------------------------------------------------
    function setHalfTime(uint256 _time) public isAdministrator
    {
        HALF_TIME = _time;
    }
    function setResetQuestTime(uint256 _time) public isAdministrator
    {
        RESET_QUEST_TIME = _time;
    }
    /** 
    * @dev Main Contract call this function to setup mini game.
    */
    function setupMiniGame( uint256 /*_miningWarRoundNumber*/, uint256 _miningWarDeadline ) public
    {
        miningWarDeadline = _miningWarDeadline;
    }
    /**
    * @dev start the mini game
    */
    function startGame() public 
    {
        require(msg.sender == administrator);
        require(init == false);
        init = true;
        miningWarDeadline = getMiningWarDealine();

        games[round].ended = true;
    
        startRound();
    }
    function startRound() private
    {
        require(games[round].ended == true);

        uint256 crystalsLastRound = games[round].crystals;
        uint256 prizePoolLastRound= games[round].prizePool; 

        round = round + 1;

        uint256 endTime = now + HALF_TIME;
        // claim 5% of current prizePool as rewards.
        uint256 engineerPrizePool = getEngineerPrizePool();
        uint256 prizePool = SafeMath.div(SafeMath.mul(engineerPrizePool, 5),100); 

        Engineer.claimPrizePool(address(this), prizePool);
        
        if (crystalsLastRound <= 0) prizePool = SafeMath.add(prizePool, prizePoolLastRound);
        
        games[round] = Game(round, 0, prizePool, endTime, false);
    }
    function endRound() private
    {
        require(games[round].ended == false);
        require(games[round].endTime <= now);

        Game storage g = games[round];
        g.ended = true;
        
        startRound();

        emit EndRound(g.round, g.crystals, g.prizePool, g.endTime);
    }
    /**
    * @dev player send crystals to the pot
    */
    function share(uint256 _value) public disableContract
    {
        require(miningWarDeadline > now);
        require(games[round].ended == false);
        require(_value >= 10000);
        require(playersQuests[msg.sender].haveQuest == false);

        MiningWar.subCrystal(msg.sender, _value); 

        if (games[round].endTime <= now) endRound();
        
        updateReward(msg.sender);

        uint256 _share = SafeMath.mul(_value, CRTSTAL_MINING_PERIOD);
        
        addPlayerQuest(msg.sender, _share);
    }
    function freeResetQuest(address _addr) public disableContract
    {
        _addr = msg.sender;
        resetQuest(_addr);
    }
    function instantResetQuest(address _addr) public payable disableContract
    {
        require(msg.value >= RESET_QUEST_FEE);

        _addr = msg.sender;

        uint256 fee = devFee(msg.value);
        address gameSponsor = getGameSponsor();
        gameSponsor.transfer(fee);
        administrator.transfer(fee);

        uint256 prizePool = msg.value - (fee * 2);
        addEngineerPrizePool(prizePool);
        resetQuest(_addr);
    }
    function confirmQuest(address _addr) public disableContract
    {
        _addr = msg.sender;
        bool _isFinish;
        (_isFinish, ,) = checkQuest(_addr);
        require(_isFinish == true);
        require(playersQuests[_addr].haveQuest  == true);

        if (games[round].endTime <= now) endRound();
        
        updateReward(_addr);

        Player storage p      = players[_addr];
        Game storage g        = games[round];
        PlayerQuest storage pQ = playersQuests[_addr];

        uint256 _share = pQ.deposit;
        uint256 rate = 0;
        // bonus
        // lv 4 50 - 100 %
        if (pQ.questId == 2) rate = 50 + randomNumber(_addr, 0, 51);
        if (pQ.questId == 0 && pQ.level == 4) rate = 50 + randomNumber(_addr, 0, 51); 
        if (pQ.questId == 1 && pQ.level == 4) rate = 50 + randomNumber(_addr, 0, 51);
        if (pQ.questId == 5 && pQ.level == 4) rate = 50 + randomNumber(_addr, 0, 51);
        // lv 3 25 - 75 %
        if (pQ.questId == 0 && pQ.level == 3) rate = 25 + randomNumber(_addr, 0, 51); 
        if (pQ.questId == 1 && pQ.level == 3) rate = 25 + randomNumber(_addr, 0, 51);
        if (pQ.questId == 5 && pQ.level == 3) rate = 25 + randomNumber(_addr, 0, 51);
        // lv 2 10 - 50 %
        if (pQ.questId == 0 && pQ.level == 2) rate = 10 + randomNumber(_addr, 0, 41); 
        if (pQ.questId == 1 && pQ.level == 2) rate = 10 + randomNumber(_addr, 0, 41);
        if (pQ.questId == 5 && pQ.level == 2) rate = 10 + randomNumber(_addr, 0, 41);
        if (pQ.questId == 3) rate = 10 + randomNumber(_addr, 0, 51);
        // lv 1 0 - 25 %
        if (pQ.questId == 0 && pQ.level == 1) rate = randomNumber(_addr, 0, 26); 
        if (pQ.questId == 1 && pQ.level == 1) rate = randomNumber(_addr, 0, 26);
        if (pQ.questId == 5 && pQ.level == 1) rate = randomNumber(_addr, 0, 26);
        if (pQ.questId == 4) rate = randomNumber(_addr, 0, 26);

        if (rate > 0) _share += SafeMath.div(SafeMath.mul(_share, rate), 100);

        g.crystals = SafeMath.add(g.crystals, _share);
        
        if (p.currentRound == round) {
            p.share = SafeMath.add(p.share, _share);
        } else {
            p.share = _share;
            p.currentRound = round;
        }

        p.questSequence += 1; 
        p.totalQuestFinish += 1; 
        pQ.haveQuest = false;

        emit ConfirmQuest(_addr, pQ.questId, pQ.level, pQ.deposit, SafeMath.sub(_share, pQ.deposit), rate);

        pQ.deposit = 0; 
    }
    function checkQuest(address _addr) public view returns(bool _isFinish, uint256 _numberOfTimes, uint256 _number) 
    {
        PlayerQuest memory pQ = playersQuests[_addr];

        if (pQ.questId == 0) (_isFinish, _numberOfTimes, _number ) = checkWonStarterQuest(_addr); 
        if (pQ.questId == 1) (_isFinish, _numberOfTimes, _number ) = checkBuyMinerQuest(_addr); 
        if (pQ.questId == 2) (_isFinish, _numberOfTimes, _number ) = checkBuyEngineerQuest(_addr); 
        if (pQ.questId == 3) (_isFinish, _numberOfTimes, _number ) = checkJoinAirdropQuest(_addr); 
        if (pQ.questId == 4) (_isFinish, _numberOfTimes, _number ) = checkAtkPlayerQuest(_addr); 
        if (pQ.questId == 5) (_isFinish, _numberOfTimes, _number ) = ckeckAtkBossWannaCryQuest(_addr); 
    }
    
    function getData(address _addr) 
    public
    view
    returns(
        // current game
        uint256 _prizePool,
        uint256 _crystals,
        uint256 _endTime,
        // player info
        uint256 _reward,
        uint256 _share,
        uint256 _questSequence,
        // current quest of player
        uint256 _deposit,
        uint256 _resetFreeTime,
        uint256 _typeQuest,
        uint256 _numberOfTimes, 
        uint256 _number,
        bool _isFinish,
        bool _haveQuest
    ) {
         (_prizePool, _crystals, _endTime) = getCurrentGame();
         (_reward, _share, _questSequence, , _resetFreeTime)   = getPlayerData(_addr);
         (_haveQuest, _typeQuest, _isFinish, _numberOfTimes, _number, _deposit) = getCurrentQuest(_addr);
         
    }
    function withdrawReward() public disableContract
    {
        if (games[round].endTime <= now) endRound();
        
        updateReward(msg.sender);
        Player storage p = players[msg.sender];
        uint256 balance  = p.reward; 
        if (address(this).balance >= balance) {
             msg.sender.transfer(balance);
            // update player
            p.reward = 0;     
        }
    }
    // ---------------------------------------------------------------------------------------------------------------------------------
    // INTERNAL
    // ---------------------------------------------------------------------------------------------------------------------------------
    function addCurrentPrizePool(uint256 _value) private
    {
        require(games[round].ended == false);
        require(init == true);
        games[round].prizePool += _value; 
    }
    function devFee(uint256 _amount) private pure returns(uint256)
    {
        return SafeMath.div(SafeMath.mul(_amount, 5), 100);
    }
    function resetQuest(address _addr) private 
    {
        if (games[round].endTime <= now) endRound();
        
        updateReward(_addr);

        uint256 currentQuestId= playersQuests[_addr].questId; 
        uint256 questId       = randomNumber(_addr, 0, 6);

        if (currentQuestId == questId && questId < 5) questId += 1; 
        if (currentQuestId == questId && questId >= 5) questId -= 1; 

        uint256 level         = 1 + randomNumber(_addr, questId + 1, 4);
        uint256 numberOfTimes = getNumberOfTimesQuest(questId, level);

        if (questId == 0) addWonStarterQuest(_addr); // won x starter quest
        if (questId == 1) addBuyMinerQuest(_addr); // buy x miner
        if (questId == 2) addBuyEngineerQuest(_addr); // buy x engineer
        if (questId == 3) addJoinAirdropQuest(_addr); // join airdrop game
        if (questId == 4) addAtkPlayerQuest(_addr); // atk a player
        if (questId == 5) addAtkBossWannaCryQuest(_addr); // atk hp boss

        PlayerQuest storage pQ = playersQuests[_addr];
        
        players[_addr].questSequence = 0;
        players[_addr].resetFreeTime = now + RESET_QUEST_TIME;

        pQ.questId       = questId;
        pQ.level         = level;
        pQ.numberOfTimes = numberOfTimes;
        emit AddPlayerQuest(_addr, questId, level, pQ.deposit);
    }
    function getCurrentGame() private view returns(uint256 _prizePool, uint256 _crystals, uint256 _endTime)
    {
        Game memory g = games[round];
        _prizePool = g.prizePool;
        _crystals  = g.crystals;
        _endTime   = g.endTime;
    }
    function getCurrentQuest(address _addr) private view returns(bool _haveQuest, uint256 _typeQuest, bool _isFinish, uint256 _numberOfTimes, uint256 _number, uint256 _deposit)
    {   
        PlayerQuest memory pQ = playersQuests[_addr];
        _haveQuest     = pQ.haveQuest;
        _deposit       = pQ.deposit;
        _typeQuest = quests[pQ.questId].typeQuest;
        (_isFinish, _numberOfTimes, _number) = checkQuest(_addr);
    }
    function getPlayerData(address _addr) private view returns(uint256 _reward, uint256 _share, uint256 _questSequence, uint256 _totalQuestFinish, uint256 _resetFreeTime)
    {
        Player memory p = players[_addr];
        _reward           = p.reward;
        _questSequence    = p.questSequence;
        _totalQuestFinish = p.totalQuestFinish;
        _resetFreeTime    = p.resetFreeTime;
        if (p.currentRound == round) _share = players[_addr].share; 
        if (p.currentRound != p.lastRound) _reward += calculateReward(_addr, p.currentRound);
    }
    function updateReward(address _addr) private
    {
        Player storage p = players[_addr];
        
        if ( 
            games[p.currentRound].ended == true &&
            p.lastRound < p.currentRound
            ) {
            p.reward = SafeMath.add(p.reward, calculateReward(msg.sender, p.currentRound));
            p.lastRound = p.currentRound;
        }
    }
      /**
    * @dev calculate reward
    */
    function randomNumber(address _addr, uint256 randNonce, uint256 _maxNumber) private view returns(uint256)
    {
        return uint256(keccak256(abi.encodePacked(now, _addr, randNonce))) % _maxNumber;
    }
    function calculateReward(address _addr, uint256 _round) private view returns(uint256)
    {
        Player memory p = players[_addr];
        Game memory g = games[_round];
        if (g.endTime > now) return 0;
        if (g.crystals == 0) return 0; 
        return SafeMath.div(SafeMath.mul(g.prizePool, p.share), g.crystals);
    }
    // --------------------------------------------------------------------------------------------------------------
    // ADD QUEST INTERNAL
    // --------------------------------------------------------------------------------------------------------------
    function addPlayerQuest(address _addr, uint256 _share) private
    {
        uint256 questId       = randomNumber(_addr, 0, 6);
        uint256 level         = 1 + randomNumber(_addr, questId + 1, 4);
        uint256 numberOfTimes = getNumberOfTimesQuest(questId, level);

        if (questId == 0) addWonStarterQuest(_addr); // won x starter quest
        if (questId == 1) addBuyMinerQuest(_addr); // buy x miner
        if (questId == 2) addBuyEngineerQuest(_addr); // buy x engineer
        if (questId == 3) addJoinAirdropQuest(_addr); // join airdrop game
        if (questId == 4) addAtkPlayerQuest(_addr); // atk a player
        if (questId == 5) addAtkBossWannaCryQuest(_addr); // atk hp boss

        PlayerQuest storage pQ = playersQuests[_addr];
        pQ.deposit       = _share;
        pQ.haveQuest     = true;
        pQ.questId       = questId;
        pQ.level         = level;
        pQ.numberOfTimes = numberOfTimes;

        players[_addr].resetFreeTime = now + RESET_QUEST_TIME;

        emit AddPlayerQuest(_addr, questId, level, _share);
    }
    function getNumberOfTimesQuest(uint256 _questId, uint256 _level) private view returns(uint256)
    {
        Quest memory q = quests[_questId];

        if (_level == 1) return q.levelOne;
        if (_level == 2) return q.levelTwo;
        if (_level == 3) return q.levelThree;
        if (_level == 4) return q.levelFour;

        return 0;
    } 
    function addWonStarterQuest(address _addr) private
    {
        uint256 miningWarRound;
        uint256 referralCount;
        (miningWarRound, referralCount) = getPlayerMiningWarData(_addr);

        playersQuests[_addr].miningWarRound = miningWarRound;
        playersQuests[_addr].referralCount  = referralCount;
    }
    
    function addBuyMinerQuest(address _addr) private
    {
        uint256 miningWarRound;
        (miningWarRound, ) = getPlayerMiningWarData(_addr);

        playersQuests[_addr].totalMiner     = getTotalMiner(_addr);
        playersQuests[_addr].miningWarRound = miningWarRound;
    }
    function addBuyEngineerQuest(address _addr) private
    {
        playersQuests[_addr].totalEngineer = getTotalEngineer(_addr);
    }
    function addJoinAirdropQuest(address _addr) private
    {
        uint256 airdropGameId;    // current airdrop game id
        uint256 totalJoinAirdrop;
        (airdropGameId , totalJoinAirdrop) = getPlayerAirdropGameData(_addr);

        playersQuests[_addr].airdropGameId    = airdropGameId;
        playersQuests[_addr].totalJoinAirdrop = totalJoinAirdrop;
        
    }
    function addAtkPlayerQuest(address _addr) private
    {        
        playersQuests[_addr].nextTimeAtkPlayer = getNextTimeAtkPlayer(_addr);
    }
    function addAtkBossWannaCryQuest(address _addr) private
    {
        uint256 dameBossWannaCry; // current dame boss
        uint256 levelBossWannaCry;
        (levelBossWannaCry, dameBossWannaCry) = getPlayerBossWannaCryData(_addr);

        playersQuests[_addr].levelBossWannaCry = levelBossWannaCry;
        playersQuests[_addr].dameBossWannaCry  = dameBossWannaCry;
    }
    // --------------------------------------------------------------------------------------------------------------
    // CHECK QUEST INTERNAL
    // --------------------------------------------------------------------------------------------------------------
    function checkWonStarterQuest(address _addr) private view returns(bool _isFinish, uint256 _numberOfTimes, uint256 _number)
    {
        PlayerQuest memory pQ = playersQuests[_addr];

        uint256 miningWarRound;
        uint256 referralCount;
        (miningWarRound, referralCount) = getPlayerMiningWarData(_addr);

        _numberOfTimes = pQ.numberOfTimes;
        if (pQ.miningWarRound != miningWarRound) _number = referralCount;
        if (pQ.miningWarRound == miningWarRound) _number = SafeMath.sub(referralCount, pQ.referralCount);    
        if (
            (pQ.miningWarRound != miningWarRound && referralCount >= pQ.numberOfTimes) ||
            (pQ.miningWarRound == miningWarRound && referralCount >= SafeMath.add(pQ.referralCount, pQ.numberOfTimes)) 
            ) {
            _isFinish = true;
        } 
        
    }
    function checkBuyMinerQuest(address _addr) private view returns(bool _isFinish, uint256 _numberOfTimes, uint256 _number)
    {
        PlayerQuest memory pQ = playersQuests[_addr];
        uint256 miningWarRound;
        (miningWarRound, ) = getPlayerMiningWarData(_addr);
        uint256 totalMiner = getTotalMiner(_addr);

        _numberOfTimes = pQ.numberOfTimes;
        if (pQ.miningWarRound != miningWarRound) _number = totalMiner;
        if (pQ.miningWarRound == miningWarRound) _number = SafeMath.sub(totalMiner, pQ.totalMiner); 
        if (
            (pQ.miningWarRound != miningWarRound && totalMiner >= pQ.numberOfTimes) ||
            (pQ.miningWarRound == miningWarRound && totalMiner >= SafeMath.add(pQ.totalMiner, pQ.numberOfTimes))
            ) {
            _isFinish = true;
        }
    }
    function checkBuyEngineerQuest(address _addr) private view returns(bool _isFinish, uint256 _numberOfTimes, uint256 _number)
    {
        PlayerQuest memory pQ = playersQuests[_addr];

        uint256 totalEngineer = getTotalEngineer(_addr);
        _numberOfTimes = pQ.numberOfTimes;
        _number = SafeMath.sub(totalEngineer, pQ.totalEngineer); 
        if (totalEngineer >= SafeMath.add(pQ.totalEngineer, pQ.numberOfTimes)) {
            _isFinish = true;
        }
    }
    function checkJoinAirdropQuest(address _addr) private view returns(bool _isFinish, uint256 _numberOfTimes, uint256 _number)
    {
        PlayerQuest memory pQ = playersQuests[_addr];

        uint256 airdropGameId;    // current airdrop game id
        uint256 totalJoinAirdrop;
        (airdropGameId , totalJoinAirdrop) = getPlayerAirdropGameData(_addr);
        _numberOfTimes = pQ.numberOfTimes;
        if (
            (pQ.airdropGameId != airdropGameId) ||
            (pQ.airdropGameId == airdropGameId && totalJoinAirdrop >= SafeMath.add(pQ.totalJoinAirdrop, pQ.numberOfTimes))
            ) {
            _isFinish = true;
            _number = _numberOfTimes;
        }
    }
    function checkAtkPlayerQuest(address _addr) private view returns(bool _isFinish, uint256 _numberOfTimes, uint256 _number)
    {
        PlayerQuest memory pQ = playersQuests[_addr];

        uint256 nextTimeAtkPlayer = getNextTimeAtkPlayer(_addr);
        _numberOfTimes = pQ.numberOfTimes;
        if (nextTimeAtkPlayer > pQ.nextTimeAtkPlayer) {
            _isFinish = true;
            _number = _numberOfTimes;
        }
    }
    function ckeckAtkBossWannaCryQuest(address _addr) private view returns(bool _isFinish, uint256 _numberOfTimes, uint256 _number)
    {
        PlayerQuest memory pQ = playersQuests[_addr];

        uint256 dameBossWannaCry; // current dame boss
        uint256 levelBossWannaCry;
        (levelBossWannaCry, dameBossWannaCry) = getPlayerBossWannaCryData(_addr);
        _numberOfTimes = pQ.numberOfTimes;
        if (pQ.levelBossWannaCry != levelBossWannaCry) _number = dameBossWannaCry;
        if (pQ.levelBossWannaCry == levelBossWannaCry) _number = SafeMath.sub(dameBossWannaCry, pQ.dameBossWannaCry);
        if (
            (pQ.levelBossWannaCry != levelBossWannaCry && dameBossWannaCry >= pQ.numberOfTimes) ||
            (pQ.levelBossWannaCry == levelBossWannaCry && dameBossWannaCry >= SafeMath.add(pQ.dameBossWannaCry, pQ.numberOfTimes))
            ) {
            _isFinish = true;
        }
    }

    // --------------------------------------------------------------------------------------------------------------
    // INTERFACE FUNCTION INTERNAL
    // --------------------------------------------------------------------------------------------------------------
    // Mining War
    function getMiningWarDealine () private view returns(uint256)
    {
        return MiningWar.deadline();
    }
    
    function getTotalMiner(address _addr) private view returns(uint256 _total)
    {
        uint256[8] memory _minersCount;
        (, , , _minersCount, , , , ) = MiningWar.getPlayerData(_addr);
        for (uint256 idx = 0; idx < 8; idx ++) {
            _total += _minersCount[idx];
        }
    }
    function getPlayerMiningWarData(address _addr) private view returns(uint256 _roundNumber, uint256 _referral_count) 
    {
        (_roundNumber, , , , _referral_count, ) = MiningWar.players(_addr);
    }
    // ENGINEER
    function addEngineerPrizePool(uint256 _value) private 
    {
        Engineer.fallback.value(_value)();
    }
    function getGameSponsor() public view returns(address)
    {
        return Engineer.gameSponsor();
    }
    function getEngineerPrizePool() private view returns(uint256)
    {
        return Engineer.prizePool();
    }
    function getNextTimeAtkPlayer(address _addr) private view returns(uint256 _nextTimeAtk)
    {
        (, , , , , , , _nextTimeAtk,) = Engineer.getPlayerData(_addr);
    }
    function getTotalEngineer(address _addr) private view returns(uint256 _total)
    {
        uint256[8] memory _engineersCount;
        (, , , , , , _engineersCount, ,) = Engineer.getPlayerData(_addr);
        for (uint256 idx = 0; idx < 8; idx ++) {
            _total += _engineersCount[idx];
        }
    }
    // AIRDROP GAME
    function getPlayerAirdropGameData(address _addr) private view returns(uint256 _currentGameId, uint256 _totalJoin)
    {
        (_currentGameId, , , , _totalJoin, ) = AirdropGame.players(_addr);
    }
    // BOSS WANNACRY
    function getPlayerBossWannaCryData(address _addr) private view returns(uint256 _currentBossRoundNumber, uint256 _dame)
    {
        (_currentBossRoundNumber, , , , _dame, ) = BossWannaCry.players(_addr);
    }
}