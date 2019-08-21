pragma solidity ^0.4.18;

/**
 * How addresses of non ERC20 coins were defined:
 * address(web3.sha3(coin_symbol_in_upper_case))
 * 
 * Example for BTC:
 * web3.sha3('BTC') = 0xe98e2830be1a7e4156d656a7505e65d08c67660dc618072422e9c78053c261e9
 * address(0xe98e2830be1a7e4156d656a7505e65d08c67660dc618072422e9c78053c261e9) = 0x505e65d08c67660dc618072422e9c78053c261e9
 */
contract CoinLib {
    
    // Bitcoin and forks:
    address public constant btc = address(0xe98e2830be1a7e4156d656a7505e65d08c67660dc618072422e9c78053c261e9);
    address public constant bch = address(0xc157673705e9a7d6253fb36c51e0b2c9193b9b560fd6d145bd19ecdf6b3a873b);
    address public constant btg = address(0x4e5f418e667aa2b937135735d3deb218f913284dd429fa56a60a2a8c2d913f6c);
    
    // Ethereum and forks:
    address public constant eth = address(0xaaaebeba3810b1e6b70781f14b2d72c1cb89c0b2b320c43bb67ff79f562f5ff4);
    address public constant etc = address(0x49b019f3320b92b2244c14d064de7e7b09dbc4c649e8650e7aa17e5ce7253294);
    
    // Bitcoin relatives:
    address public constant ltc = address(0xfdd18b7aa4e2107a72f3310e2403b9bd7ace4a9f01431002607b3b01430ce75d);
    address public constant doge = address(0x9a3f52b1b31ae58da40209f38379e78c3a0756495a0f585d0b3c84a9e9718f9d);
    
    // Anons/privacy coins: 
    address public constant dash = address(0x279c8d120dfdb1ac051dfcfe9d373ee1d16624187fd2ed07d8817b7f9da2f07b);
    address public constant xmr = address(0x8f7631e03f6499d6370dbfd69bc9be2ac2a84e20aa74818087413a5c8e085688);
    address public constant zec = address(0x85118a02446a6ea7372cee71b5fc8420a3f90277281c88f5c237f3edb46419a6);
    address public constant bcn = address(0x333433c3d35b6491924a29fbd93a9852a3c64d3d5b9229c073a047045d57cbe4);
    address public constant pivx = address(0xa8b003381bf1e14049ab83186dd79e07408b0884618bc260f4e76ccd730638c7);
    
    // Smart contracts:
    address public constant ada = address(0x4e1e6d8aa1ff8f43f933718e113229b0ec6b091b699f7a8671bcbd606da36eea);
    address public constant xem = address(0x5f83a7d8f46444571fbbd0ea2d2613ab294391cb1873401ac6090df731d949e5);
    address public constant neo = address(0x6dc5790d7c4bfaaa2e4f8e2cd517bacd4a3831f85c0964e56f2743cbb847bc46);
    address public constant eos = 0x86Fa049857E0209aa7D9e616F7eb3b3B78ECfdb0; // Address of ERC20 token.
    
    address[] internal oldSchool = [btc, ltc, eth, dash];
    address[] internal btcForks = [btc, bch, btg];
    address[] internal smart = [eth, ada, eos, xem];
    address[] internal anons = [dash, xmr, zec, bcn];
    
    function getBtcForkCoins() public view returns (address[]) {
        return btcForks;
    }
    
    function getOldSchoolCoins() public view returns (address[]) {
        return oldSchool;
    }
    
    function getPrivacyCoins() public view returns (address[]) {
        return anons;
    }
    
    function getSmartCoins() public view returns (address[]) {
        return smart;
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract SuperOwners {

    address public owner1;
    address public pendingOwner1;
    
    address public owner2;
    address public pendingOwner2;

    function SuperOwners(address _owner1, address _owner2) internal {
        require(_owner1 != address(0));
        owner1 = _owner1;
        
        require(_owner2 != address(0));
        owner2 = _owner2;
    }

    modifier onlySuperOwner1() {
        require(msg.sender == owner1);
        _;
    }
    
    modifier onlySuperOwner2() {
        require(msg.sender == owner2);
        _;
    }
    
    /** Any of the owners can execute this. */
    modifier onlySuperOwner() {
        require(isSuperOwner(msg.sender));
        _;
    }
    
    /** Is msg.sender any of the owners. */
    function isSuperOwner(address _addr) public view returns (bool) {
        return _addr == owner1 || _addr == owner2;
    }

    /** 
     * Safe transfer of ownership in 2 steps. Once called, a newOwner needs 
     * to call claimOwnership() to prove ownership.
     */
    function transferOwnership1(address _newOwner1) onlySuperOwner1 public {
        pendingOwner1 = _newOwner1;
    }
    
    function transferOwnership2(address _newOwner2) onlySuperOwner2 public {
        pendingOwner2 = _newOwner2;
    }

    function claimOwnership1() public {
        require(msg.sender == pendingOwner1);
        owner1 = pendingOwner1;
        pendingOwner1 = address(0);
    }
    
    function claimOwnership2() public {
        require(msg.sender == pendingOwner2);
        owner2 = pendingOwner2;
        pendingOwner2 = address(0);
    }
}

contract MultiOwnable is SuperOwners {

    mapping (address => bool) public ownerMap;
    address[] public ownerHistory;

    event OwnerAddedEvent(address indexed _newOwner);
    event OwnerRemovedEvent(address indexed _oldOwner);

    function MultiOwnable(address _owner1, address _owner2) 
        SuperOwners(_owner1, _owner2) internal {}

    modifier onlyOwner() {
        require(isOwner(msg.sender));
        _;
    }

    function isOwner(address owner) public view returns (bool) {
        return isSuperOwner(owner) || ownerMap[owner];
    }
    
    function ownerHistoryCount() public view returns (uint) {
        return ownerHistory.length;
    }

    // Add extra owner
    function addOwner(address owner) onlySuperOwner public {
        require(owner != address(0));
        require(!ownerMap[owner]);
        ownerMap[owner] = true;
        ownerHistory.push(owner);
        OwnerAddedEvent(owner);
    }

    // Remove extra owner
    function removeOwner(address owner) onlySuperOwner public {
        require(ownerMap[owner]);
        ownerMap[owner] = false;
        OwnerRemovedEvent(owner);
    }
}

contract Pausable is MultiOwnable {

    bool public paused;

    modifier ifNotPaused {
        require(!paused);
        _;
    }

    modifier ifPaused {
        require(paused);
        _;
    }

    // Called by the owner on emergency, triggers paused state
    function pause() external onlySuperOwner {
        paused = true;
    }

    // Called by the owner on end of emergency, returns to normal state
    function resume() external onlySuperOwner ifPaused {
        paused = false;
    }
}

contract ERC20 {

    uint256 public totalSupply;

    function balanceOf(address _owner) public view returns (uint256 balance);

    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is ERC20 {
    
    using SafeMath for uint;

    mapping(address => uint256) balances;
    
    mapping(address => mapping(address => uint256)) allowed;

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value > 0);
        require(_value <= balances[msg.sender]);
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /// @dev Allows allowed third party to transfer tokens from one address to another. Returns success.
    /// @param _from Address from where tokens are withdrawn.
    /// @param _to Address to where tokens are sent.
    /// @param _value Number of tokens to transfer.
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value > 0);
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);
        
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /// @dev Sets approved amount of tokens for spender. Returns success.
    /// @param _spender Address of allowed account.
    /// @param _value Number of approved tokens.
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /// @dev Returns number of allowed tokens for given address.
    /// @param _owner Address of token owner.
    /// @param _spender Address of token spender.
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
}

contract CommonToken is StandardToken, MultiOwnable {

    string public name;
    string public symbol;
    uint256 public totalSupply;
    uint8 public decimals = 18;
    string public version = 'v0.1';

    address public seller;     // The main account that holds all tokens at the beginning and during tokensale.

    uint256 public saleLimit;  // (e18) How many tokens can be sold in total through all tiers or tokensales.
    uint256 public tokensSold; // (e18) Number of tokens sold through all tiers or tokensales.
    uint256 public totalSales; // Total number of sales (including external sales) made through all tiers or tokensales.

    // Lock the transfer functions during tokensales to prevent price speculations.
    bool public locked = true;
    
    event SellEvent(address indexed _seller, address indexed _buyer, uint256 _value);
    event ChangeSellerEvent(address indexed _oldSeller, address indexed _newSeller);
    event Burn(address indexed _burner, uint256 _value);
    event Unlock();

    function CommonToken(
        address _owner1,
        address _owner2,
        address _seller,
        string _name,
        string _symbol,
        uint256 _totalSupplyNoDecimals,
        uint256 _saleLimitNoDecimals
    ) MultiOwnable(_owner1, _owner2) public {

        require(_seller != address(0));
        require(_totalSupplyNoDecimals > 0);
        require(_saleLimitNoDecimals > 0);

        seller = _seller;
        name = _name;
        symbol = _symbol;
        totalSupply = _totalSupplyNoDecimals * 1e18;
        saleLimit = _saleLimitNoDecimals * 1e18;
        balances[seller] = totalSupply;

        Transfer(0x0, seller, totalSupply);
    }
    
    modifier ifUnlocked(address _from, address _to) {
        require(!locked || isOwner(_from) || isOwner(_to));
        _;
    }
    
    /** Can be called once by super owner. */
    function unlock() onlySuperOwner public {
        require(locked);
        locked = false;
        Unlock();
    }

    function changeSeller(address newSeller) onlySuperOwner public returns (bool) {
        require(newSeller != address(0));
        require(seller != newSeller);

        address oldSeller = seller;
        uint256 unsoldTokens = balances[oldSeller];
        balances[oldSeller] = 0;
        balances[newSeller] = balances[newSeller].add(unsoldTokens);
        Transfer(oldSeller, newSeller, unsoldTokens);

        seller = newSeller;
        ChangeSellerEvent(oldSeller, newSeller);
        
        return true;
    }

    function sellNoDecimals(address _to, uint256 _value) public returns (bool) {
        return sell(_to, _value * 1e18);
    }

    function sell(address _to, uint256 _value) onlyOwner public returns (bool) {

        // Check that we are not out of limit and still can sell tokens:
        require(tokensSold.add(_value) <= saleLimit);

        require(_to != address(0));
        require(_value > 0);
        require(_value <= balances[seller]);

        balances[seller] = balances[seller].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(seller, _to, _value);

        totalSales++;
        tokensSold = tokensSold.add(_value);
        SellEvent(seller, _to, _value);

        return true;
    }
    
    /**
     * Until all tokens are sold, tokens can be transfered to/from owner's accounts.
     */
    function transfer(address _to, uint256 _value) ifUnlocked(msg.sender, _to) public returns (bool) {
        return super.transfer(_to, _value);
    }

    /**
     * Until all tokens are sold, tokens can be transfered to/from owner's accounts.
     */
    function transferFrom(address _from, address _to, uint256 _value) ifUnlocked(_from, _to) public returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function burn(uint256 _value) public returns (bool) {
        require(_value > 0);
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value) ;
        totalSupply = totalSupply.sub(_value);
        Transfer(msg.sender, 0x0, _value);
        Burn(msg.sender, _value);

        return true;
    }
}

contract RaceToken is CommonToken {
    
    function RaceToken() CommonToken(
        0x229B9Ef80D25A7e7648b17e2c598805d042f9e56, // __OWNER1__
        0xcd7cF1D613D5974876AfBfd612ED6AFd94093ce7, // __OWNER2__
        0x2821e1486D604566842FF27F626aF133FddD5f89, // __SELLER__
        'Coin Race',
        'RACE',
        100 * 1e6, // 100m tokens in total.
        70 * 1e6   // 70m tokens for sale.
    ) public {}
}

library RaceCalc {
    
    using SafeMath for uint;
    
    // Calc a stake of a driver based on his current time.
    // We use linear regression, so the more time passed since 
    // the start of the race, the less stake of a final reward he will receive.
    function calcStake(
        uint _currentTime, // Example: 1513533600 - 2017-12-17 18:00:00 UTC
        uint _finishTime   // Example: 1513537200 - 2017-12-17 19:00:00 UTC
    ) public pure returns (uint) {
        
        require(_currentTime > 0);
        require(_currentTime < _finishTime);
        
        return _finishTime.sub(_currentTime);
    }
    
    // Calc gain of car at the finish of a race.
    // Result can be negative.
    // 100% is represented as 10^8 to be more precious.
    function calcGainE8(
        uint _startRateToUsdE8, // Example: 345
        uint _finishRateToUsdE8 // Example: 456
    ) public pure returns (int) {
        
        require(_startRateToUsdE8 > 0);
        require(_finishRateToUsdE8 > 0);
        
        int diff = int(_finishRateToUsdE8) - int(_startRateToUsdE8);
        return (diff * 1e8) / int(_startRateToUsdE8);
    }
    
    function calcPrizeTokensE18(
        uint totalTokens, 
        uint winningStake, 
        uint driverStake
    ) public pure returns (uint) {
        
        if (totalTokens == 0) return 0;
        if (winningStake == 0) return 0;
        if (driverStake == 0) return 0;
        if (winningStake == driverStake) return totalTokens;
        
        require(winningStake > driverStake);
        uint share = driverStake.mul(1e8).div(winningStake);
        return totalTokens.mul(share).div(1e8);
    }
}

/** 
 * Here we implement all token methods that require msg.sender to be albe 
 * to perform operations on behalf of GameWallet from other CoinRace contracts 
 * like a particular contract of RaceGame.
 */
contract CommonWallet is MultiOwnable {
    
    RaceToken public token;
    
    event ChangeTokenEvent(address indexed _oldAddress, address indexed _newAddress);
    
    function CommonWallet(address _owner1, address _owner2) 
        MultiOwnable(_owner1, _owner2) public {}
    
    function setToken(address _token) public onlySuperOwner {
        require(_token != 0);
        require(_token != address(token));
        
        ChangeTokenEvent(token, _token);
        token = RaceToken(_token);
    }
    
    function transfer(address _to, uint256 _value) onlyOwner public returns (bool) {
        return token.transfer(_to, _value);
    }
    
    function transferFrom(address _from, address _to, uint256 _value) onlyOwner public returns (bool) {
        return token.transferFrom(_from, _to, _value);
    }
    
    function approve(address _spender, uint256 _value) onlyOwner public returns (bool) {
        return token.approve(_spender, _value);
    }
    
    function burn(uint256 _value) onlySuperOwner public returns (bool) {
        return token.burn(_value);
    }
    
    /** Amount of tokens that players of CoinRace bet during the games and haven't claimed yet. */
    function balance() public view returns (uint256) {
        return token.balanceOf(this);
    }
    
    function balanceOf(address _owner) public view returns (uint256) {
        return token.balanceOf(_owner);
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return token.allowance(_owner, _spender);
    }
}

contract GameWallet is CommonWallet {
    
    function GameWallet() CommonWallet(
        0x229B9Ef80D25A7e7648b17e2c598805d042f9e56, // __OWNER1__
        0xcd7cF1D613D5974876AfBfd612ED6AFd94093ce7  // __OWNER2__
    ) public {}
}

library RaceLib {
    
    using SafeMath for uint;
    
    function makeBet(
        Race storage _race, 
        address _driver, 
        address _car, 
        uint _tokensE18
    ) public {
        require(!isFinished(_race));
        
        var bet = Bet({
            driver: _driver,
            car: _car,
            tokens: _tokensE18,
            time: now
        });

        _race.betsByDriver[_driver].push(bet);
        _race.betsByCar[_car].push(bet);
            
        if (_race.tokensByCarAndDriver[_car][_driver] == 0) {
            _race.driverCountByCar[_car] = _race.driverCountByCar[_car] + 1;
        }
        
        _race.tokensByCar[_car] = _race.tokensByCar[_car].add(_tokensE18);
        _race.tokensByCarAndDriver[_car][_driver] = 
            _race.tokensByCarAndDriver[_car][_driver].add(_tokensE18);
        
        uint stakeTime = bet.time;
        if (bet.time < _race.leftGraceTime && _race.leftGraceTime > 0) stakeTime = _race.leftGraceTime;
        if (bet.time > _race.rightGraceTime && _race.rightGraceTime > 0) stakeTime = _race.rightGraceTime;
        uint stake = RaceCalc.calcStake(stakeTime, _race.finishTime);
        _race.stakeByCar[_car] = _race.stakeByCar[_car].add(stake);
        _race.stakeByCarAndDriver[_car][_driver] = 
            _race.stakeByCarAndDriver[_car][_driver].add(stake);
        
        _race.totalTokens = _race.totalTokens.add(_tokensE18);
    }
    
    function hasDriverJoined(
        Race storage _race, 
        address _driver
    ) public view returns (bool) {
        return betCountByDriver(_race, _driver) > 0;
    }
    
    function betCountByDriver(
        Race storage _race, 
        address _driver
    ) public view returns (uint) {
        return _race.betsByDriver[_driver].length;
    }
    
    function betCountByCar(
        Race storage _race, 
        address _car
    ) public view returns (uint) {
        return _race.betsByCar[_car].length;
    }
    
    function startCar(
        Race storage _race, 
        address _car,
        uint _rateToUsdE8
    ) public {
        require(_rateToUsdE8 > 0);
        require(_race.carRates[_car].startRateToUsdE8 == 0);
        _race.carRates[_car].startRateToUsdE8 = _rateToUsdE8;
    }
    
    function finish(
        Race storage _race
    ) public {
        require(!_race.finished);
        require(now >= _race.finishTime);
        _race.finished = true;
    }
    
    function isFinished(
        Race storage _race
    ) public view returns (bool) {
        return _race.finished;
    }
    
    struct Race {
        
        uint id;
        
        uint leftGraceTime;
        
        uint rightGraceTime;
        
        uint startTime;
        
        uint finishTime;
        
        bool finished;
        
        uint finishedCarCount;
        
        // 0 - if race is not finished yet.
        address firstCar;
        
        // Total amount of tokens tha thave been bet on all cars during the race: 
        uint totalTokens;
        
        uint driverCount;
        
        // num of driver => driver's address.
        mapping (uint => address) drivers;
        
        // car_address => total_drivers_that_made_bet_on_this_car
        mapping (address => uint) driverCountByCar;
        
        // driver_address => bets by driver
        mapping (address => Bet[]) betsByDriver;
        
        // car_address => bets on this car.
        mapping (address => Bet[]) betsByCar;
        
        // car_address => total_tokens_bet_on_this_car
        mapping (address => uint) tokensByCar;
        
        // car_address => driver_address => total_tokens_bet_on_this_car_by_this_driver
        mapping (address => mapping (address => uint)) tokensByCarAndDriver;

        // car_address => stake_by_all_drivers
        mapping (address => uint) stakeByCar;

        // car_address => driver_address => stake
        mapping (address => mapping (address => uint)) stakeByCarAndDriver;

        // car_address => its rates to USD.
        mapping (address => CarRates) carRates;

        // int because it can be negative value if finish rate is lower.
        mapping (address => int) gainByCar;
        
        mapping (address => bool) isFinishedCar;
        
        // driver_address => amount of tokens (e18) that have been claimed by driver.
        mapping (address => uint) tokensClaimedByDriver;
    }
    
    struct Bet {
        address driver;
        address car;
        uint tokens;
        uint time;
    }
    
    struct CarRates {
        uint startRateToUsdE8;
        uint finishRateToUsdE8;
    }
}

contract CommonRace is MultiOwnable {
    
    using SafeMath for uint;
    using RaceLib for RaceLib.Race;
    
    GameWallet public wallet;
    
    // The name of the game.
    string public name;
    
    address[] public cars;
    
    mapping (address => bool) public isKnownCar;
    
    RaceLib.Race[] public races;
    
    address[] public drivers;

    mapping (address => bool) public isKnownDriver;
    
    modifier ifWalletDefined() {
        require(address(wallet) != address(0));
        _;
    }
    
    function CommonRace(
        address _owner1,
        address _owner2,
        address[] _cars,
        string _name
    ) MultiOwnable(_owner1, _owner2) public {
        require(_cars.length > 0);

        name = _name;
        cars = _cars;
        
        for (uint16 i = 0; i < _cars.length; i++) {
            isKnownCar[_cars[i]] = true;
        }
    }
    
    function getNow() public view returns (uint) {
        return now;
    }
    
    function raceCount() public view returns (uint) {
        return races.length;
    }
    
    function carCount() public view returns (uint) {
        return cars.length;
    }
    
    function driverCount() public view returns (uint) {
        return drivers.length;
    }
    
    function setWallet(address _newWallet) onlySuperOwner public {
        require(wallet != _newWallet);
        require(_newWallet != 0);
        
        GameWallet newWallet = GameWallet(_newWallet);
        wallet = newWallet;
    }

    function lastLapId() public view returns (uint) {
        require(races.length > 0);
        return races.length - 1;
    }

    function nextLapId() public view returns (uint) {
        return races.length;
    }
    
    function getRace(uint _lapId) internal view returns (RaceLib.Race storage race) {
        race = races[_lapId];
        require(race.startTime > 0); // if startTime is > 0 then race is real.
    }
    
    /**
     * _durationSecs - A duration of race in seconds.
     * 
     * Structure of _carsAndRates:
     *   N-th elem is a car addr.
     *   (N+1)-th elem is car rate.
     */
    function startNewRace(
        uint _newLapId, 
        uint[] _carsAndRates,
        uint _durationSecs,
        uint _leftGraceSecs, // How many seconds from the start we should not apply penalty for stake of bet?
        uint _rightGraceSecs // How many seconds before the finish we should not apply penalty for stake of bet?
    ) onlyOwner public {
        require(_newLapId == nextLapId());
        require(_carsAndRates.length == (cars.length * 2));
        require(_durationSecs > 0);
        
        if (_leftGraceSecs > 0) require(_leftGraceSecs <= _durationSecs);
        if (_rightGraceSecs > 0) require(_rightGraceSecs <= _durationSecs);
        
        uint finishTime = now.add(_durationSecs);
        
        races.push(RaceLib.Race({
            id: _newLapId,
            leftGraceTime: now + _leftGraceSecs,
            rightGraceTime: finishTime - _rightGraceSecs,
            startTime: now,
            finishTime: finishTime,
            finished: false,
            finishedCarCount: 0,
            firstCar: 0,
            totalTokens: 0,
            driverCount: 0
        }));
        RaceLib.Race storage race = races[_newLapId];

        uint8 j = 0;
        for (uint8 i = 0; i < _carsAndRates.length; i += 2) {
            address car = address(_carsAndRates[j++]);
            uint startRateToUsdE8 = _carsAndRates[j++];
            require(isKnownCar[car]);
            race.startCar(car, startRateToUsdE8);
        }
    }

    /**
     * Structure of _carsAndRates:
     *   N-th elem is a car addr.
     *   (N+1)-th elem is car rate.
     */
    function finishRace(
        uint _lapId, 
        uint[] _carsAndRates
    ) onlyOwner public {
        require(_carsAndRates.length == (cars.length * 2));
        
        RaceLib.Race storage race = getRace(_lapId);
        race.finish();
        
        int maxGain = 0;
        address firstCar; // The first finished car.
        
        uint8 j = 0;
        for (uint8 i = 0; i < _carsAndRates.length; i += 2) {
            address car = address(_carsAndRates[j++]);
            uint finishRateToUsdE8 = _carsAndRates[j++];
            require(!isCarFinished(_lapId, car));
            
            // Mark car as finished:
            RaceLib.CarRates storage rates = race.carRates[car];
            rates.finishRateToUsdE8 = finishRateToUsdE8;
            race.isFinishedCar[car] = true;
            race.finishedCarCount++;
            
            // Calc gain of car:
            int gain = RaceCalc.calcGainE8(rates.startRateToUsdE8, finishRateToUsdE8);
            race.gainByCar[car] = gain;
            if (i == 0 || gain > maxGain) {
                maxGain = gain;
                firstCar = car;
            }
        }
        
        // The first finished car should be found.
        require(firstCar != 0);
        race.firstCar = firstCar;
    }
    
    function finishRaceThenStartNext(
        uint _lapId, 
        uint[] _carsAndRates,
        uint _durationSecs,
        uint _leftGraceSecs, // How many seconds from the start we should not apply penalty for stake of bet?
        uint _rightGraceSecs // How many seconds before the finish we should not apply penalty for stake of bet?
    ) onlyOwner public {
        finishRace(_lapId, _carsAndRates);
        startNewRace(_lapId + 1, _carsAndRates, _durationSecs, _leftGraceSecs, _rightGraceSecs);
    }
    
    function isLastRaceFinsihed() public view returns (bool) {
        return isLapFinished(lastLapId());
    }
    
    function isLapFinished(
        uint _lapId
    ) public view returns (bool) {
        return getRace(_lapId).isFinished();
    }
    
    // Unused func.
    // function shouldFinishLap(
    //     uint _lapId
    // ) public view returns (bool) {
    //     RaceLib.Race storage lap = getRace(_lapId);
    //     // 'now' will not work for Ganache
    //     return !lap.isFinished() && now >= lap.finishTime;
    // }
    
    function lapStartTime(
        uint _lapId
    ) public view returns (uint) {
        return getRace(_lapId).startTime;
    }
    
    function lapFinishTime(
        uint _lapId
    ) public view returns (uint) {
        return getRace(_lapId).finishTime;
    }
    
    function isCarFinished(
        uint _lapId,
        address _car
    ) public view returns (bool) {
        require(isKnownCar[_car]);
        return getRace(_lapId).isFinishedCar[_car];
    }
    
    function allCarsFinished(
        uint _lapId
    ) public view returns (bool) {
        return finishedCarCount(_lapId) == cars.length;
    }
    
    function finishedCarCount(
        uint _lapId
    ) public view returns (uint) {
        return getRace(_lapId).finishedCarCount;
    }
    
    function firstCar(
        uint _lapId
    ) public view returns (address) {
        return getRace(_lapId).firstCar;
    }
    
    function isWinningDriver(
        uint _lapId, 
        address _driver
    ) public view returns (bool) {
        RaceLib.Race storage race = getRace(_lapId);
        return race.tokensByCarAndDriver[race.firstCar][_driver] > 0;
    }
    
    /**
     * This is helper function usefull when debugging contract or checking state on Etherscan.
     */
    function myUnclaimedTokens(
        uint _lapId
    ) public view returns (uint) {
        return unclaimedTokens(_lapId, msg.sender);
    }
    
    /** 
     * Calculate how much tokens a winning driver can claim once race is over.
     * Claimed tokens will be added back to driver's token balance.
     * Formula = share of all tokens based on bets made on winning car.
     * Tokens in format e18.
     */
    function unclaimedTokens(
        uint _lapId,
        address _driver
    ) public view returns (uint) {
        RaceLib.Race storage race = getRace(_lapId);
        
        // if driver has claimed his tokens already.
        if (race.tokensClaimedByDriver[_driver] > 0) return 0;
        
        if (!race.isFinished()) return 0;
        if (race.firstCar == 0) return 0;
        if (race.totalTokens == 0) return 0;
        if (race.stakeByCar[race.firstCar] == 0) return 0;
        
        // Size of driver's stake on the first finished car.
        uint driverStake = race.stakeByCarAndDriver[race.firstCar][_driver];
        if (driverStake == 0) return 0;

        return RaceCalc.calcPrizeTokensE18(
            race.totalTokens, 
            race.stakeByCar[race.firstCar],
            driverStake
        );
    }

    function claimTokens(
        uint _lapId
    ) public ifWalletDefined {
        address driver = msg.sender;
        uint tokens = unclaimedTokens(_lapId, driver);
        require(tokens > 0);
        // Transfer prize tokens from game wallet to driver's address:
        require(wallet.transfer(driver, tokens));
        getRace(_lapId).tokensClaimedByDriver[driver] = tokens;
    }
    
    function makeBet(
        uint _lapId,
        address _car, 
        uint _tokensE18
    ) public ifWalletDefined {
        address driver = msg.sender;
        require(isKnownCar[_car]);
        
        // NOTE: Remember that driver needs to call Token(address).approve(wallet, tokens) 
        // or this contract will not be able to do the transfer on your behalf.
        
        // Transfer tokens from driver to game wallet:
        require(wallet.transferFrom(msg.sender, wallet, _tokensE18));
        getRace(_lapId).makeBet(driver, _car, _tokensE18);
        
        if (!isKnownDriver[driver]) {
            isKnownDriver[driver] = true;
            drivers.push(driver);
        }
    }
    
    /**
     * Result array format:
     * [
     * N+0: COIN_ADDRESS (ex: 0x0000000000000000000000000000000000012301)
     * N+1: MY_BET_TOKENS_E18
     * ... repeat ...
     * ]
     */
    function myBetsInLap(
        uint _lapId
    ) public view returns (uint[] memory totals) {
        RaceLib.Race storage race = getRace(_lapId);
        totals = new uint[](cars.length * 2);
        uint8 j = 0;
        address car;
        for (uint8 i = 0; i < cars.length; i++) {
            car = cars[i];
            totals[j++] = uint(car);
            totals[j++] = race.tokensByCarAndDriver[car][msg.sender];
        }
    }
    
    /**
     * Result array format:
     * [
     * 0: START_DATE_UNIX_TS
     * 1: DURATION_SEC
     * 2: FIRST_CAR_ID
     * 3: !!! NEW !!! MY_UNCLAIMED_TOKENS
     * 
     * N+0: COIN_ADDRESS (ex: 0x0000000000000000000000000000000000012301)
     * N+1: START_RATE_E8
     * N+2: END_RATE_E8
     * N+3: DRIVER_COUNT
     * N+4: TOTAL_BET_TOKENS_E18
     * N+5: MY_BET_TOKENS_E18
     * N+6: !!! NEW !!! GAIN_E8
     * ... repeat for each car...
     * ]
     */
    function lapTotals(
        uint _lapId
    ) public view returns (int[] memory totals) {
        RaceLib.Race storage race = getRace(_lapId);
        totals = new int[](5 + cars.length * 7);
        
        uint _myUnclaimedTokens = 0;
        if (isLapFinished(_lapId)) {
            _myUnclaimedTokens = unclaimedTokens(_lapId, msg.sender);
        }
        
        address car;
        uint8 j = 0;
        totals[j++] = int(now);
        totals[j++] = int(race.startTime);
        totals[j++] = int(race.finishTime - race.startTime);
        totals[j++] = int(race.firstCar);
        totals[j++] = int(_myUnclaimedTokens);
        
        for (uint8 i = 0; i < cars.length; i++) {
            car = cars[i];
            totals[j++] = int(car);
            totals[j++] = int(race.carRates[car].startRateToUsdE8);
            totals[j++] = int(race.carRates[car].finishRateToUsdE8);
            totals[j++] = int(race.driverCountByCar[car]);
            totals[j++] = int(race.tokensByCar[car]);
            totals[j++] = int(race.tokensByCarAndDriver[car][msg.sender]);
            totals[j++] = race.gainByCar[car];
        }
    }
}

contract RaceOldSchool4h is CommonRace, CoinLib {
    
    function RaceOldSchool4h() CommonRace(
        0x229B9Ef80D25A7e7648b17e2c598805d042f9e56, // __OWNER1__
        0xcd7cF1D613D5974876AfBfd612ED6AFd94093ce7, // __OWNER2__
        oldSchool,
        'Old School'
    ) public {}
}

contract RaceBtcForks4h is CommonRace, CoinLib {
    
    function RaceBtcForks4h() CommonRace(
        0x229B9Ef80D25A7e7648b17e2c598805d042f9e56, // __OWNER1__
        0xcd7cF1D613D5974876AfBfd612ED6AFd94093ce7, // __OWNER2__
        btcForks,
        'Bitcoin Forks'
    ) public {}
}

contract RaceSmart4h is CommonRace, CoinLib {
    
    function RaceSmart4h() CommonRace(
        0x229B9Ef80D25A7e7648b17e2c598805d042f9e56, // __OWNER1__
        0xcd7cF1D613D5974876AfBfd612ED6AFd94093ce7, // __OWNER2__
        smart,
        'Smart Coins'
    ) public {}
}

contract RaceAnons4h is CommonRace, CoinLib {
    
    function RaceAnons4h() CommonRace(
        0x229B9Ef80D25A7e7648b17e2c598805d042f9e56, // __OWNER1__
        0xcd7cF1D613D5974876AfBfd612ED6AFd94093ce7, // __OWNER2__
        anons,
        'Anonymouses'
    ) public {}
}