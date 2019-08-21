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
    struct BoostData {
        address owner;
        uint256 boostRate;
        uint256 basePrice;
    }
    mapping(uint256 => BoostData) public boostData;
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
    function addVirus(address /*_addr*/, uint256 /*_value*/) public pure {}
    function claimPrizePool(address /*_addr*/, uint256 /*_value*/) public pure {} 
    function isContractMiniGame() public pure returns( bool /*_isContractMiniGame*/) {}
}
contract CryptoMiningWarInterface {
    uint256 public deadline; 
    uint256 public roundNumber = 0;
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
    function getBoosterData(uint256 /*idx*/) public pure returns (address /*owner*/,uint256 /*boostRate*/, uint256 /*startingLevel*/, 
        uint256 /*startingTime*/, uint256 /*currentPrice*/, uint256 /*halfLife*/) {}
    function addHashrate( address /*_addr*/, uint256 /*_value*/ ) public pure {}
    function addCrystal( address /*_addr*/, uint256 /*_value*/ ) public pure {}
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
contract CryptoDepositInterface {
    uint256 public round = 0;
    mapping(address => Player) public players;
    struct Player {
        uint256 currentRound;
        uint256 lastRound;
        uint256 reward;
        uint256 share; // your crystals share in current round 
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
contract CryptoBeginnerQuest {
    using SafeMath for uint256;

    address private administrator;
    // mini game
    CryptoEngineerInterface     public Engineer;
    CryptoDepositInterface      public Deposit;
    CryptoMiningWarInterface    public MiningWar;
    CryptoAirdropGameInterface  public AirdropGame;
    CryptoBossWannaCryInterface public BossWannaCry;
    
    // mining war info
    uint256 private miningWarDeadline;
    uint256 private miningWarRound;

    /** 
    * @dev player information
    */
    mapping(address => Player)           private players;
    // quest information
    mapping(address => MinerQuest)       private minerQuests;
    mapping(address => EngineerQuest)    private engineerQuests;
    mapping(address => DepositQuest)     private depositQuests;
    mapping(address => JoinAirdropQuest) private joinAirdropQuests;
    mapping(address => AtkBossQuest)     private atkBossQuests;
    mapping(address => AtkPlayerQuest)   private atkPlayerQuests;
    mapping(address => BoosterQuest)     private boosterQuests;
    mapping(address => RedbullQuest)     private redbullQuests;
   
    struct Player {
        uint256 miningWarRound;
        uint256 currentQuest;
    }
    struct MinerQuest {
        bool ended;
    }
    struct EngineerQuest {
        bool ended;
    }
    struct DepositQuest {
        uint256 currentDepositRound;
        uint256 share; // current deposit of player
        bool ended;
    }
    struct JoinAirdropQuest {
        uint256 airdropGameId;    // current airdrop game id
        uint256 totalJoinAirdrop; // total join the airdrop game
        bool ended;
    }
    struct AtkBossQuest {
        uint256 dameBossWannaCry; // current dame boss
        uint256 levelBossWannaCry; // current boss player atk
        bool ended;
    }
    struct AtkPlayerQuest {
        uint256 nextTimeAtkPlayer; // 
        bool ended;
    }
    struct BoosterQuest {
        bool ended;
    }
    struct RedbullQuest {
        bool ended;
    }

    event ConfirmQuest(address player, uint256 questType, uint256 reward, uint256 typeReward); // 1 : crystals, 2: hashrate, 3: virus
    modifier isAdministrator()
    {
        require(msg.sender == administrator);
        _;
    }
    
    constructor() public {
        administrator = msg.sender;
        // init contract interface  
        setMiningWarInterface(0xf84c61bb982041c030b8580d1634f00fffb89059);
        setEngineerInterface(0x69fd0e5d0a93bf8bac02c154d343a8e3709adabf);
        setAirdropGameInterface(0x5b813a2f4b58183d270975ab60700740af00a3c9);
        setBossWannaCryInterface(0x54e96d609b183196de657fc7380032a96f27f384);
        setDepositInterface(0xd67f271c2d3112d86d6991bfdfc8f9f27286bc4b);
    }
    function () public payable
    {
        
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
    function setDepositInterface(address _addr) public isAdministrator
    {
        CryptoDepositInterface depositInterface = CryptoDepositInterface(_addr);
        
        require(depositInterface.isContractMiniGame() == true);

        Deposit = depositInterface;
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
    /** 
    * @dev Main Contract call this function to setup mini game.
    */
    function setupMiniGame( uint256 _miningWarRoundNumber, uint256 _miningWarDeadline ) public
    {
        miningWarDeadline = _miningWarDeadline;
        miningWarRound    = _miningWarRoundNumber;
    }
    /**
    * @dev start the mini game
    */
    function setupGame() public 
    {
        require(msg.sender == administrator);
        require(miningWarDeadline == 0);
        miningWarDeadline = getMiningWarDealine();
        miningWarRound    = getMiningWarRound();
    }
    function confirmQuest() public 
    {
        if (miningWarRound != players[msg.sender].miningWarRound) {
            players[msg.sender].currentQuest = 0;
            players[msg.sender].miningWarRound = miningWarRound;
        }    
        bool _isFinish;
        bool _ended;
        (_isFinish, _ended) = checkQuest(msg.sender);
        require(miningWarDeadline > now);
        require(_isFinish == true);
        require(_ended == false);

        if (players[msg.sender].currentQuest == 0) confirmGetFreeQuest(msg.sender);
        if (players[msg.sender].currentQuest == 1) confirmMinerQuest(msg.sender);
        if (players[msg.sender].currentQuest == 2) confirmEngineerQuest(msg.sender);
        if (players[msg.sender].currentQuest == 3) confirmDepositQuest(msg.sender);
        if (players[msg.sender].currentQuest == 4) confirmJoinAirdropQuest(msg.sender);
        if (players[msg.sender].currentQuest == 5) confirmAtkBossQuest(msg.sender);
        if (players[msg.sender].currentQuest == 6) confirmAtkPlayerQuest(msg.sender);
        if (players[msg.sender].currentQuest == 7) confirmBoosterQuest(msg.sender);
        if (players[msg.sender].currentQuest == 8) confirmRedbullQuest(msg.sender);

        if (players[msg.sender].currentQuest <= 7) addQuest(msg.sender);
    }
    function checkQuest(address _addr) public view returns(bool _isFinish, bool _ended) 
    {
        if (players[_addr].currentQuest == 0) (_isFinish, _ended) = checkGetFreeQuest(_addr);
        if (players[_addr].currentQuest == 1) (_isFinish, _ended) = checkMinerQuest(_addr);
        if (players[_addr].currentQuest == 2) (_isFinish, _ended) = checkEngineerQuest(_addr);
        if (players[_addr].currentQuest == 3) (_isFinish, _ended) = checkDepositQuest(_addr);
        if (players[_addr].currentQuest == 4) (_isFinish, _ended) = checkJoinAirdropQuest(_addr);
        if (players[_addr].currentQuest == 5) (_isFinish, _ended) = checkAtkBossQuest(_addr);
        if (players[_addr].currentQuest == 6) (_isFinish, _ended) = checkAtkPlayerQuest(_addr);
        if (players[_addr].currentQuest == 7) (_isFinish, _ended) = checkBoosterQuest(_addr);
        if (players[_addr].currentQuest == 8) (_isFinish, _ended) = checkRedbullQuest(_addr);
    }
    
    function getData(address _addr) 
    public
    view
    returns(
        uint256 _miningWarRound,
        uint256 _currentQuest,
        bool _isFinish,
        bool _endedQuest
    ) {
        Player memory p          = players[_addr];
        _miningWarRound          = p.miningWarRound;
        _currentQuest            = p.currentQuest;
        if (_miningWarRound != miningWarRound) _currentQuest = 0;
        (_isFinish, _endedQuest) = checkQuest(_addr);
    }
    // ---------------------------------------------------------------------------------------------------------------------------------
    // INTERNAL 
    // ---------------------------------------------------------------------------------------------------------------------------------
    function addQuest(address _addr) private
    {
        Player storage p      = players[_addr];
        p.currentQuest += 1;

        if (p.currentQuest == 1) addMinerQuest(_addr); 
        if (p.currentQuest == 2) addEngineerQuest(_addr); 
        if (p.currentQuest == 3) addDepositQuest(_addr); 
        if (p.currentQuest == 4) addJoinAirdropQuest(_addr); 
        if (p.currentQuest == 5) addAtkBossQuest(_addr); 
        if (p.currentQuest == 6) addAtkPlayerQuest(_addr); 
        if (p.currentQuest == 7) addBoosterQuest(_addr); 
        if (p.currentQuest == 8) addRedbullQuest(_addr); 
    }
    // ---------------------------------------------------------------------------------------------------------------------------------
    // CONFIRM QUEST INTERNAL 
    // ---------------------------------------------------------------------------------------------------------------------------------
    function confirmGetFreeQuest(address _addr) private
    {
        MiningWar.addCrystal(_addr, 100);

        emit ConfirmQuest(_addr, 1, 100, 1);
    }
    function confirmMinerQuest(address _addr) private
    {
        MinerQuest storage pQ = minerQuests[_addr];
        pQ.ended = true;
        MiningWar.addCrystal(_addr, 100);

        emit ConfirmQuest(_addr, 2, 100, 1);
    }
    function confirmEngineerQuest(address _addr) private
    {
        EngineerQuest storage pQ = engineerQuests[_addr];
        pQ.ended = true;
        MiningWar.addCrystal(_addr, 400);

        emit ConfirmQuest(_addr, 3, 400, 1);
    }
    function confirmDepositQuest(address _addr) private
    {
        DepositQuest storage pQ = depositQuests[_addr];
        pQ.ended = true;
        MiningWar.addHashrate(_addr, 200);

        emit ConfirmQuest(_addr, 4, 200, 2);
    }
    function confirmJoinAirdropQuest(address _addr) private
    {
        JoinAirdropQuest storage pQ = joinAirdropQuests[_addr];
        pQ.ended = true;
        Engineer.addVirus(_addr, 10);

        emit ConfirmQuest(_addr, 5, 10, 3);
    }
    function confirmAtkBossQuest(address _addr) private
    {
        AtkBossQuest storage pQ = atkBossQuests[_addr];
        pQ.ended = true;
        Engineer.addVirus(_addr, 10);

        emit ConfirmQuest(_addr, 6, 10, 3);
    }
    function confirmAtkPlayerQuest(address _addr) private
    {
        AtkPlayerQuest storage pQ = atkPlayerQuests[_addr];
        pQ.ended = true;
        MiningWar.addCrystal(_addr, 10000);

        emit ConfirmQuest(_addr, 7, 10000, 1);
    }   
    function confirmBoosterQuest(address _addr) private
    {
        BoosterQuest storage pQ = boosterQuests[_addr];
        pQ.ended = true;
        Engineer.addVirus(_addr, 100);

        emit ConfirmQuest(_addr, 8, 100, 3);
    }
    function confirmRedbullQuest(address _addr) private
    {
        RedbullQuest storage pQ = redbullQuests[_addr];
        pQ.ended = true;
        Engineer.addVirus(_addr, 100);

        emit ConfirmQuest(_addr, 9, 100, 3);
    }
    // --------------------------------------------------------------------------------------------------------------
    // ADD QUEST INTERNAL
    // --------------------------------------------------------------------------------------------------------------
    function addMinerQuest(address _addr) private
    {
         MinerQuest storage pQ = minerQuests[_addr];
         pQ.ended = false;
    }
    function addEngineerQuest(address _addr) private
    {
         EngineerQuest storage pQ = engineerQuests[_addr];
         pQ.ended = false;
    }
    function addDepositQuest(address _addr) private
    {
        DepositQuest storage pQ = depositQuests[_addr];
        uint256 currentDepositRound;
        uint256 share;
        (currentDepositRound, share) = getPlayerDepositData(_addr);
        pQ.currentDepositRound       = currentDepositRound;
        pQ.share                     = share;
        pQ.ended = false;
    }
    function addJoinAirdropQuest(address _addr) private
    {
        uint256 airdropGameId;    // current airdrop game id
        uint256 totalJoinAirdrop;
        (airdropGameId , totalJoinAirdrop) = getPlayerAirdropGameData(_addr);
        JoinAirdropQuest storage pQ = joinAirdropQuests[_addr];

        pQ.airdropGameId    = airdropGameId;
        pQ.totalJoinAirdrop = totalJoinAirdrop;
        pQ.ended = false;
    }
    function addAtkBossQuest(address _addr) private
    {
        uint256 dameBossWannaCry; // current dame boss
        uint256 levelBossWannaCry;
        (levelBossWannaCry, dameBossWannaCry) = getPlayerBossWannaCryData(_addr);

        AtkBossQuest storage pQ = atkBossQuests[_addr];
        pQ.levelBossWannaCry = levelBossWannaCry;
        pQ.dameBossWannaCry  = dameBossWannaCry;
        pQ.ended = false;
    }
    function addAtkPlayerQuest(address _addr) private
    {
        AtkPlayerQuest storage pQ = atkPlayerQuests[_addr];
        pQ.nextTimeAtkPlayer = getNextTimeAtkPlayer(_addr);
        pQ.ended = false;
    }   
    function addBoosterQuest(address _addr) private
    {
        BoosterQuest storage pQ = boosterQuests[_addr];
        pQ.ended = false;
    }
    function addRedbullQuest(address _addr) private
    {
        RedbullQuest storage pQ = redbullQuests[_addr];
        pQ.ended = false;
    }
    // --------------------------------------------------------------------------------------------------------------
    // CHECK QUEST INTERNAL
    // --------------------------------------------------------------------------------------------------------------
    function checkGetFreeQuest(address _addr) private view returns(bool _isFinish, bool _ended)
    {
        if (players[_addr].currentQuest > 0) _ended = true;
        if (miningWarRound == getMiningWarRoundOfPlayer(_addr)) _isFinish = true;
    }
    function checkMinerQuest(address _addr) private view returns(bool _isFinish, bool _ended)
    {
        MinerQuest memory pQ = minerQuests[_addr];
        _ended = pQ.ended;
        if (getMinerLv1(_addr) >= 10) _isFinish = true;
    }
    function checkEngineerQuest(address _addr) private view returns(bool _isFinish, bool _ended)
    {
        EngineerQuest memory pQ = engineerQuests[_addr];
        _ended = pQ.ended;
        if (getEngineerLv1(_addr) >= 10) _isFinish = true;
    }
    function checkDepositQuest(address _addr) private view returns(bool _isFinish, bool _ended)
    {
        DepositQuest memory pQ = depositQuests[_addr];
        _ended = pQ.ended;
        uint256 currentDepositRound;
        uint256 share;
        (currentDepositRound, share) = getPlayerDepositData(_addr);
        if ((currentDepositRound != pQ.currentDepositRound) || (share > pQ.share)) _isFinish = true;
    }
    function checkJoinAirdropQuest(address _addr) private view returns(bool _isFinish, bool _ended)
    {
        JoinAirdropQuest memory pQ = joinAirdropQuests[_addr];
        _ended = pQ.ended;
        uint256 airdropGameId;    // current airdrop game id
        uint256 totalJoinAirdrop;
        (airdropGameId , totalJoinAirdrop) = getPlayerAirdropGameData(_addr);
        if (
            (pQ.airdropGameId != airdropGameId) ||
            (pQ.airdropGameId == airdropGameId && totalJoinAirdrop > pQ.totalJoinAirdrop)
            ) {
            _isFinish = true;
        }
    }
    function checkAtkBossQuest(address _addr) private view returns(bool _isFinish, bool _ended)
    {
        AtkBossQuest memory pQ = atkBossQuests[_addr];
        _ended = pQ.ended;
        uint256 dameBossWannaCry; // current dame boss
        uint256 levelBossWannaCry;
        (levelBossWannaCry, dameBossWannaCry) = getPlayerBossWannaCryData(_addr);
        if (
            (pQ.levelBossWannaCry != levelBossWannaCry) ||
            (pQ.levelBossWannaCry == levelBossWannaCry && dameBossWannaCry > pQ.dameBossWannaCry)
            ) {
            _isFinish = true;
        }
    }
    function checkAtkPlayerQuest(address _addr) private view returns(bool _isFinish, bool _ended)
    {
        AtkPlayerQuest memory pQ = atkPlayerQuests[_addr];
        _ended = pQ.ended;
        uint256 nextTimeAtkPlayer = getNextTimeAtkPlayer(_addr);
        if (nextTimeAtkPlayer > pQ.nextTimeAtkPlayer) _isFinish = true;
    }   
    function checkBoosterQuest(address _addr) private view returns(bool _isFinish, bool _ended)
    {
        BoosterQuest memory pQ = boosterQuests[_addr];
        _ended = pQ.ended;
        address[5] memory boosters = getBoosters();
        for(uint256 idx = 0; idx < 5; idx++) {
            if (boosters[idx] == _addr) _isFinish = true;
        }

    }
    function checkRedbullQuest(address _addr) private view returns(bool _isFinish, bool _ended)
    {
        RedbullQuest memory pQ = redbullQuests[_addr];
        _ended = pQ.ended;
        address[5] memory redbulls = getRedbulls();
        for(uint256 idx = 0; idx < 5; idx++) {
            if (redbulls[idx] == _addr) _isFinish = true;
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
    function getMiningWarRound() private view returns(uint256)
    {
        return MiningWar.roundNumber();
    }
    function getBoosters() public view returns(address[5] _boosters)
    {
        for (uint256 idx = 0; idx < 5; idx++) {
            address owner;
            (owner, , , , , ) = MiningWar.getBoosterData(idx);
            _boosters[idx] = owner;
        }
    }
    function getMinerLv1(address _addr) private view returns(uint256 _total)
    {
        uint256[8] memory _minersCount;
        (, , , _minersCount, , , , ) = MiningWar.getPlayerData(_addr);
        _total = _minersCount[0];
    }
    function getMiningWarRoundOfPlayer(address _addr) private view returns(uint256 _roundNumber) 
    {
        (_roundNumber, , , , , ) = MiningWar.players(_addr);
    }
    // ENGINEER
    function getRedbulls() public view returns(address[5] _redbulls)
    {
        for (uint256 idx = 0; idx < 5; idx++) {
            address owner;
            (owner, , ) = Engineer.boostData(idx);
            _redbulls[idx] = owner;
        }
    }
    function getNextTimeAtkPlayer(address _addr) private view returns(uint256 _nextTimeAtk)
    {
        (, , , , , , , _nextTimeAtk,) = Engineer.getPlayerData(_addr);
    }
    function getEngineerLv1(address _addr) private view returns(uint256 _total)
    {
        uint256[8] memory _engineersCount;
        (, , , , , , _engineersCount, ,) = Engineer.getPlayerData(_addr);
        _total = _engineersCount[0];
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
    // DEPOSIT
    function getPlayerDepositData(address _addr) private view returns(uint256 _currentRound, uint256 _share)
    {
        (_currentRound, , , _share ) = Deposit.players(_addr);
    }
}