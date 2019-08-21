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

    function subVirus(address /*_addr*/, uint256 /*_value*/) public pure {}
    function claimPrizePool(address /*_addr*/, uint256 /*_value*/) public pure {} 
    function isContractMiniGame() public pure returns( bool /*_isContractMiniGame*/) {}
    function fallback() external payable {}
}
contract CryptoMiningWarInterface {
    uint256 public deadline; 
    function subCrystal( address /*_addr*/, uint256 /*_value*/ ) public pure {}
    function fallback() external payable {}
}
contract MemoryFactoryInterface {
    uint256 public factoryTotal;

    function setFactoryToal(uint256 /*_value*/) public {}
    function updateFactory(address /*_addr*/, uint256 /*_levelUp*/, uint256 /*_time*/) public {}
    function updateLevel(address /*_addr*/) public {}
    function addProgram(address /*_addr*/, uint256 /*_idx*/, uint256 /*_program*/) public {}
    function subProgram(address /*_addr*/, uint256 /*_idx*/, uint256 /*_program*/) public {}

    function getPrograms(address /*_addr*/) public view returns(uint256[]) {}
    function getLevel(address /*_addr*/) public view returns(uint256 /*_level*/) {}
    function getData(address /*_addr*/) public view returns(uint256 /*_level*/, uint256 /*_updateTime*/, uint256[] /*_programs*/) {} 
}
interface MiniGameInterface {
    function isContractMiniGame() external pure returns( bool _isContractMiniGame );
    function fallback() external payable;
}
contract CryptoProgramFactory {
    bool status = false;
	using SafeMath for uint256;

	address public administrator;

    uint256 private BASE_PRICE   = 0.1 ether; 
    uint256 private BASE_TIME    = 4 hours; 

    MemoryFactoryInterface   public Memory;
    CryptoMiningWarInterface public MiningWar;
    CryptoEngineerInterface  public Engineer;

    // factory info
    mapping(uint256 => Factory) public factories; 
    // minigame info
    mapping(address => bool)    public miniGames; 
   
    struct Factory {
        uint256 level;
        uint256 crystals;
        uint256 programPriceByCrystals;
        uint256 programPriceByDarkCrystals;
        uint256 programValue; // example with level one can more 15% virus an arena(programValue = 15);
        uint256 eth;
        uint256 time;
    }
    modifier isAdministrator()
    {
        require(msg.sender == administrator);
        _;
    }
    modifier onlyContractsMiniGame() 
    {
        require(miniGames[msg.sender] == true);
        _;
    }
    event UpdateFactory(address _addr, uint256 _crystals, uint256 _eth, uint256 _levelUp, uint256 _updateTime);
    event BuyProgarams(address _addr, uint256 _crystals, uint256 _darkCrystals, uint256[] _programs);
    constructor() public {
        administrator = msg.sender;
        // set interface contract
        setMiningWarInterface(0xf84c61bb982041c030b8580d1634f00fffb89059);
        setEngineerInterface(0x69fd0e5d0a93bf8bac02c154d343a8e3709adabf);
        setMemoryInterface(0xa2e6461e7a109ae070b9b064ca9448b301404784);
    }
    function initFactory() private 
    {       
        //                  level crystals programPriceByCrystals programPriceByDarkCrystals programValue ether            time                
        factories[0] = Factory(1, 100000,         10000,           0,                         10           ,BASE_PRICE * 0, BASE_TIME * 1);
        factories[1] = Factory(2, 500000,         20000,           0,                         15           ,BASE_PRICE * 1, BASE_TIME * 2);
        factories[2] = Factory(3, 1500000,        40000,           0,                         20           ,BASE_PRICE * 4, BASE_TIME * 3);
        factories[3] = Factory(4, 3000000,        80000,           0,                         5            ,BASE_PRICE * 5, BASE_TIME * 6);

        Memory.setFactoryToal(4);
    }
    function () public payable
    {
        
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
    function setupMiniGame( uint256 /*_miningWarRoundNumber*/, uint256 /*_miningWarDeadline*/ ) public
    {
    }
    // ---------------------------------------------------------------------------------------
    // SET INTERFACE CONTRACT
    // ---------------------------------------------------------------------------------------
    
    function setMemoryInterface(address _addr) public isAdministrator
    {
        Memory = MemoryFactoryInterface(_addr);
    }
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
    //--------------------------------------------------------------------------
    // SETTING CONTRACT MINI GAME 
    //--------------------------------------------------------------------------
    function setContractMiniGame( address _contractAddress ) public isAdministrator 
    {
        MiniGameInterface MiniGame = MiniGameInterface( _contractAddress );
        if( MiniGame.isContractMiniGame() == false ) { revert(); }

        miniGames[_contractAddress] = true;
    }
    function removeContractMiniGame(address _contractAddress) public isAdministrator
    {
        miniGames[_contractAddress] = false;
    }
    //--------------------------------------------------------------------------
    // SETTING FACTORY  
    //--------------------------------------------------------------------------
    function addFactory(
        uint256 _crystals, 
        uint256 _programPriceByCrystals,  
        uint256 _programPriceByDarkCrystals,  
        uint256 _programValue,  
        uint256 _eth, 
        uint256 _time
    ) public isAdministrator
    {
        uint256 factoryTotal = Memory.factoryTotal();
        factories[factoryTotal] = Factory(factoryTotal +1,_crystals,_programPriceByCrystals,_programPriceByDarkCrystals,_programValue,_eth,_time);
        factoryTotal += 1;
        Memory.setFactoryToal(factoryTotal);
    }
    function setProgramValue(uint256 _idx, uint256 _value) public isAdministrator
    {
        Factory storage f = factories[_idx];// factory update
        f.programValue = _value;
    }
    function setProgramPriceByCrystals(uint256 _idx, uint256 _value) public isAdministrator
    {
        Factory storage f = factories[_idx];// factory update
        f.programPriceByCrystals = _value;
    }
    function setProgramPriceByDarkCrystals(uint256 _idx, uint256 _value) public isAdministrator
    {
        Factory storage f = factories[_idx];// factory update
        f.programPriceByDarkCrystals = _value;
    }
    // --------------------------------------------------------------------------------------------------------------
    // MAIN CONTENT
    // --------------------------------------------------------------------------------------------------------------
    /**
    * @dev start the mini game
    */
    function startGame() public 
    {
        require(msg.sender == administrator);
        require(status == false);
        
        status = true;

        initFactory();
    }
    function updateFactory() public payable 
    {

        Memory.updateLevel(msg.sender);
        
        Factory memory f = factories[uint256(Memory.getLevel(msg.sender))];// factory update

        if (msg.value < f.eth) revert();

        MiningWar.subCrystal(msg.sender, f.crystals);

        uint256 updateTime = now + f.time;
        uint256 levelUp     = f.level;

        Memory.updateFactory(msg.sender, levelUp, updateTime);

        if (msg.value > 0) {
            uint256 fee = devFee(msg.value);
            address gameSponsor = Engineer.gameSponsor();
            gameSponsor.transfer(fee);
            administrator.transfer(fee);

            MiningWar.fallback.value(fee)();
            Engineer.fallback.value(SafeMath.sub(msg.value, 3 * fee))();
        }

        emit UpdateFactory(msg.sender, f.crystals, msg.value, levelUp, updateTime);
    }

    function buyProgarams(uint256[] _programs) public
    {
        require(_programs.length <= Memory.factoryTotal());

        Memory.updateLevel(msg.sender);

        uint256 factoryLevel = Memory.getLevel(msg.sender);
        uint256 crystals = 0;
        uint256 darkCrystals =0; 

        for (uint256 idx = 0; idx < _programs.length; idx ++) {
            Factory memory f = factories[idx];
            uint256 level = idx + 1;
            if (_programs[idx] > 0 && factoryLevel < level) revert();
            if (_programs[idx] > 0) {
                crystals     += SafeMath.mul(_programs[idx], f.programPriceByCrystals);
                darkCrystals += SafeMath.mul(_programs[idx], f.programPriceByDarkCrystals);
                Memory.addProgram(msg.sender, idx, _programs[idx]);
            }    
        }

        if (crystals > 0) MiningWar.subCrystal(msg.sender, crystals);
        // if (darkCrystals > 0) BossWannaCry.subDarkCrystal(msg.sender, darkCrystals);
        emit BuyProgarams(msg.sender, crystals, darkCrystals, _programs);
    }
    function subPrograms(address _addr, uint256[] _programs) public onlyContractsMiniGame
    {
        uint256 factoryTotal = Memory.factoryTotal();
        require(_programs.length <= factoryTotal);

        for (uint256 idx = 0; idx < _programs.length; idx++) {
            if (_programs[idx] > 0) Memory.subProgram(_addr, idx, _programs[idx]);
        }
    }
    function getData(address _addr) 
    public
    view
    returns(
        uint256   _factoryTotal,
        uint256   _factoryLevel,
        uint256   _factoryTime,
        uint256[] _programs
    ) {
        _factoryTotal = Memory.factoryTotal();
        (_factoryLevel, _factoryTime, _programs) = Memory.getData(_addr);
    }
    function getProgramsValue() public view returns(uint256[]) {
        uint256 factoryTotal = Memory.factoryTotal();
        uint256[] memory _programsValue = new uint256[](factoryTotal);
        
        for(uint256 idx = 0; idx < factoryTotal; idx++) {
            Factory memory f    = factories[idx];
            _programsValue[idx] = f.programValue;
        }
        return _programsValue;
    }
    // INTERFACE
    // --------------------------------------------------------------------------------------------------------------
    function devFee(uint256 _amount) private pure returns(uint256)
    {
        return SafeMath.div(SafeMath.mul(_amount, 5), 100);
    }
  
}