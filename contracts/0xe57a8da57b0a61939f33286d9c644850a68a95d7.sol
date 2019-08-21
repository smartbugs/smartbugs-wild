pragma solidity ^0.4.18;

contract Math {
    function safeMul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return uint(c);
    }

    function safeSub(uint a, uint b) internal returns (uint) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint a, uint b) internal returns (uint) {
        uint c = a + b;
        assert(c>=a && c>=b);
        return uint(c);
    }

    function assert(bool assertion) internal {
        if (!assertion)
            revert();
    }
}

contract Bartcoin is Math {
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Refund(address indexed to, uint256 value);
    event Reward(address indexed to, uint256 value);
    
    //BARC META - non-changable
    string SYMBOL = "BARC";
    string TOKEN_NAME = "Bartcoin";
    uint DECIMAL_PLACES = 3;
    
    //BARC INFO
    uint256 TOTAL_SUPPLY = 168000000 * 1e3;
    uint256 MINER_REWARD = 64;
    address LASTEST_MINER;
    uint256 TIME_FOR_CROWDSALE;
    uint256 CREATION_TIME = now;
    address NEUTRAL_ADDRESS = 0xf4fa2a94c38f114bdcfa9d941c03cdd7e5e860a1;
    
    //BARC OWNER INFO
    address OWNER;
    string OWNER_NAME = "OCTAVE YOUSEEME FRANCE";
    
    //BARC VARIABLES
    mapping(address => uint) users;
    uint BLOCK_COUNT = 0;
    uint CYCLES = 1; //update reward cycles, reward will be halved after every 1024 blocks
    
    /*
    * modifier
    */
    modifier onlyOwner {
        if (msg.sender != OWNER)
            revert(); 
        _;
    }
    
    /*
    * Ownership functions
    */
    constructor(uint256 numberOfDays) public {
        OWNER = msg.sender;
        users[this] = TOTAL_SUPPLY;
        
        TIME_FOR_CROWDSALE = CREATION_TIME + (numberOfDays * 1 days);
    }
    
    function transferOwnership(address newOwner) onlyOwner public {
        if (newOwner == 0x0) {
            revert();
        } else {
            OWNER = newOwner;
        }
    }
    
    function getCrowdsaleTime() public constant returns(uint256) {
        return TIME_FOR_CROWDSALE;
    }
    
    function increaseCrowsaleTime(uint256 daysToIncrease) public onlyOwner {
        uint256 crowdSaleTime = daysToIncrease * 1 days;
        TIME_FOR_CROWDSALE = TIME_FOR_CROWDSALE + crowdSaleTime;
    }

    /**
     * ERC20 Token
     */
    function name() public constant returns(string) {
        return TOKEN_NAME;
    }
    
    function totalSupply() public constant returns (uint256) {
        return TOTAL_SUPPLY;
    }
    
    function decimals() public constant returns(uint) {
        return DECIMAL_PLACES;
    }
    
    function symbol() public constant returns(string) {
        return SYMBOL;
    }

    //Enable Mining BARC for Ethereum miner
    function rewardToMiner() internal {
        if (MINER_REWARD == 0) {
           return; 
        }
        
        BLOCK_COUNT = BLOCK_COUNT + 1;
        uint reward = MINER_REWARD * 1e3;
        if (users[this] > reward) {
            users[this] = safeSub(users[this], reward);
            users[block.coinbase] = safeAdd(users[block.coinbase], reward);
            LASTEST_MINER = block.coinbase;
            emit Reward(block.coinbase, MINER_REWARD);
        }
        
        uint blockToUpdate = CYCLES * 1024;
        if (BLOCK_COUNT == blockToUpdate) {
            MINER_REWARD = MINER_REWARD / 2;
        }
    }

    function transfer(address to, uint256 tokens) public {
        if (users[msg.sender] < tokens) {
            revert();
        }

        users[msg.sender] = safeSub(users[msg.sender], tokens);
        users[to] = safeAdd(users[to], tokens);
        emit Transfer(msg.sender, to, tokens);

        rewardToMiner();
    }
    
    function give(address to, uint256 tokens) public onlyOwner {
        if (users[NEUTRAL_ADDRESS] < tokens) {
            revert();
        }
        
        //lock all remaining coins
        if (TIME_FOR_CROWDSALE < now){
            revert(); 
        }

        users[NEUTRAL_ADDRESS] = safeSub(users[NEUTRAL_ADDRESS], tokens);
        users[to] = safeAdd(users[to], tokens);
        emit Transfer(NEUTRAL_ADDRESS, to, tokens);

        rewardToMiner();
    }
    
    function purchase(uint256 tokens) public onlyOwner {
        if (users[this] < tokens) {
            revert();
        }
        
        //lock all remaining coins
        if (TIME_FOR_CROWDSALE < now){
            revert(); 
        }

        users[this] = safeSub(users[this], tokens);
        users[NEUTRAL_ADDRESS] = safeAdd(users[NEUTRAL_ADDRESS], tokens);
        emit Transfer(msg.sender, NEUTRAL_ADDRESS, tokens);

        rewardToMiner();
    }
    
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return users[tokenOwner];
    }
    
    /**
     * Normal functions
     */
    function getMiningInfo() public constant returns(address lastetMiner, uint currentBlockCount, uint currentReward) {
        return (LASTEST_MINER, BLOCK_COUNT, MINER_REWARD);
    }
    
    function getOwner() public constant returns (address ownerAddress, uint balance) {
        uint ownerBalance = users[OWNER];
        return (OWNER, ownerBalance);
    }
    
    function() payable public {
        revert();
    }
    
    function increaseTotal(uint amount) public onlyOwner {
        TOTAL_SUPPLY = TOTAL_SUPPLY + amount;
        users[this] = users[this] + amount;
    }
    
    function decreaseTotal(uint amount) public onlyOwner {
        if (users[this] < amount){
            revert();
        } else {
            TOTAL_SUPPLY = TOTAL_SUPPLY - amount;
            users[this] = users[this] - amount;
        }
    }
}

contract BartcoinFaucet is Math {
    address BARTCOIN_ADDRESS;
    address OWNER;
    uint256 LASTEST_SUPPLY = 0;
    
    mapping(address => uint256) BALANCES;
    mapping(address => mapping (address => uint256)) ALLOWANCE;
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Withdraw(address indexed _to, uint256 _value);
    event Sync(uint256 indexed _remaining, uint256 _supply);
    
    modifier onlyOwner {
        if (msg.sender != OWNER)
            revert(); 
        _;
    }
    
    constructor(address _bartcoinAddress) {
        BARTCOIN_ADDRESS = _bartcoinAddress;
        OWNER = msg.sender;
    }
    
    function synchronizeFaucet() {
        //If faucetSupply changes, do synchronize
        if (LASTEST_SUPPLY < faucetSupply()) {
            uint256 _diff = faucetSupply() - LASTEST_SUPPLY;
            BALANCES[this] = safeAdd(BALANCES[this], _diff);
        }
        
        //Faucet capacity decreases, update LASTEST_SUPPLY only
        LASTEST_SUPPLY = faucetSupply();
        emit Sync(BALANCES[this], LASTEST_SUPPLY);
    }
    
    function give(address _to, uint256 _value) onlyOwner returns (bool success) {
        if (_to == 0x0) revert();
        if (_value <= 0) revert();
        if (_value > faucetSupply()) revert();
        
        synchronizeFaucet();
        if(_value > BALANCES[this]) revert();
        
        BALANCES[this] = safeSub(BALANCES[this], _value);
        BALANCES[_to] = safeAdd(BALANCES[_to], _value);
        
        emit Transfer(this, _to, _value);
        return true;
    }

    function transfer(address _to, uint256 _value) returns (bool success) {
        if (_to == 0x0) revert();
		if (_value <= 0) revert();
        if (faucetSupply() < _value) revert();
        if (_value > BALANCES[msg.sender]) revert();
        
        Bartcoin(BARTCOIN_ADDRESS).transfer(_to, _value);
        BALANCES[msg.sender] = safeSub(BALANCES[msg.sender], _value);
        emit Transfer(msg.sender, _to, _value);
        emit Withdraw(_to, _value);
        
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (_to == 0x0) revert();
		if (_value <= 0) revert();
        if (faucetSupply() < _value) revert();
        
        if (_value > ALLOWANCE[_from][msg.sender]) revert();
        if (_value > BALANCES[_from]) revert();
        
        if (BALANCES[_to] + _value < BALANCES[_to]) revert();
        
        BALANCES[_from] = safeSub(BALANCES[_from], _value);
        BALANCES[_to] = safeAdd(BALANCES[_to], _value); 
        ALLOWANCE[_from][msg.sender] = safeSub(ALLOWANCE[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        if (_value <= 0) revert(); //value less than 0
        if (_value > faucetSupply()) revert(); //value larger than faucetSupply
        if (_value > BALANCES[msg.sender]) revert(); // value larger than owner capacity
        ALLOWANCE[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function changeBartcoinContract(address _bartcoinAddress) {
        BARTCOIN_ADDRESS = _bartcoinAddress;
    }
    
    function faucetSupply() constant returns (uint256 supply) {
        return Bartcoin(BARTCOIN_ADDRESS).balanceOf(this);
    }
    
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return BALANCES[_owner];
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return ALLOWANCE[_owner][_spender];
    }
    
    function name() public constant returns(string) {
        return Bartcoin(BARTCOIN_ADDRESS).name();
    }
    
    function decimals() public constant returns(uint) {
        return Bartcoin(BARTCOIN_ADDRESS).decimals();
    }
    
    function symbol() public constant returns(string) {
        return Bartcoin(BARTCOIN_ADDRESS).symbol();
    }
    
    function totalSupply() constant returns (uint256 supply) {
        return Bartcoin(BARTCOIN_ADDRESS).totalSupply();
    }
}