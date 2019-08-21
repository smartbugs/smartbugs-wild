pragma solidity 0.4.19;


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

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    //Variables
    address public owner;

    address public newOwner;

    //    Modifiers
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
        owner = msg.sender;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param _newOwner The address to transfer ownership to.
     */
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        newOwner = _newOwner;

    }

    function acceptOwnership() public {
        if (msg.sender == newOwner) {
            owner = newOwner;
        }
    }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public constant returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {

    using SafeMath for uint256;

    mapping (address => uint256) public balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood:
        https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;

    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

contract SparkERC20 is StandardToken, Ownable {

    using SafeMath for uint256;

    /* Public variables of the token */
    uint256 public creationBlock;

    uint8 public decimals;

    string public name;

    string public symbol;

    string public standard;

    bool public locked;

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function SparkERC20(
        uint256 _totalSupply,
        string _tokenName,
        uint8 _decimalUnits,
        string _tokenSymbol,
        bool _transferAllSupplyToOwner,
        bool _locked
    ) public {
        standard = "ERC20 0.1";
        locked = _locked;
        totalSupply = _totalSupply;

        if (_transferAllSupplyToOwner) {
            balances[msg.sender] = totalSupply;
        } else {
            balances[this] = totalSupply;
        }
        name = _tokenName;
        // Set the name for display purposes
        symbol = _tokenSymbol;
        // Set the symbol for display purposes
        decimals = _decimalUnits;
        // Amount of decimals for display purposes
        creationBlock = block.number;
    }

    /* public methods */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(locked == false);
        return super.transfer(_to, _value);
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        if (locked) {
            return false;
        }
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool success) {
        if (locked) {
            return false;
        }
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success) {
        if (locked) {
            return false;
        }
        return super.decreaseApproval(_spender, _subtractedValue);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (locked) {
            return false;
        }

        return super.transferFrom(_from, _to, _value);
    }

}

/*
This contract manages the minters and the modifier to allow mint to happen only if called by minters
This contract contains basic minting functionality though
*/
contract MintingERC20 is SparkERC20 {

    // Variables
    uint256 public maxSupply;

    mapping (address => bool) public minters;

    // Modifiers
    modifier onlyMinters() {
        require(true == minters[msg.sender]);
        _;
    }

    function MintingERC20(
        uint256 _initialSupply,
        uint256 _maxSupply,
        string _tokenName,
        uint8 _decimals,
        string _symbol,
        bool _transferAllSupplyToOwner,
        bool _locked
    ) public SparkERC20(
        _initialSupply,
        _tokenName,
        _decimals,
        _symbol,
        _transferAllSupplyToOwner,
        _locked
    )
    {
        standard = "MintingERC20 0.1";
        minters[msg.sender] = true;
        maxSupply = _maxSupply;
    }

    function addMinter(address _newMinter) public onlyOwner {
        minters[_newMinter] = true;
    }

    function removeMinter(address _minter) public onlyOwner {
        minters[_minter] = false;
    }

    function mint(address _addr, uint256 _amount) public onlyMinters returns (uint256) {
        if (_amount == uint256(0)) {
            return uint256(0);
        }

        if (totalSupply.add(_amount) > maxSupply) {
            return uint256(0);
        }

        totalSupply = totalSupply.add(_amount);
        balances[_addr] = balances[_addr].add(_amount);
        Transfer(address(0), _addr, _amount);

        return _amount;
    }

}

contract Spark is MintingERC20 {

    ICO public ico;

    SparkDividends public dividends;

    bool public transferFrozen = true;

    function Spark(
        string _tokenName,
        uint8 _decimals,
        string _symbol,
        uint256 _maxSupply,
        bool _locked
    ) public MintingERC20(0, _maxSupply, _tokenName, _decimals, _symbol, false, _locked)
    {
        standard = "Spark 0.1";
    }

    function setICO(address _ico) public onlyOwner {
        require(_ico != address(0));
        ico = ICO(_ico);
    }

    function setSparkDividends(address _dividends) public onlyOwner {
        require(address(0) != _dividends);
        dividends = SparkDividends(_dividends);
    }

    function setLocked(bool _locked) public onlyOwner {
        locked = _locked;
    }

    // prevent manual minting tokens when ICO is active;
    function mint(address _addr, uint256 _amount) public onlyMinters returns (uint256) {
        uint256 mintedAmount;
        if (msg.sender == owner) {
            require(address(ico) != address(0));
            if (!ico.isActive() && block.timestamp >= ico.startTime()) {
                mintedAmount = super.mint(_addr, _amount);
            }
        } else {
            mintedAmount = super.mint(_addr, _amount);
        }

        if (mintedAmount == _amount) {
            require(address(dividends) != address(0));
            dividends.logAccount(_addr, _amount);
        }

        return mintedAmount;
    }

    // Allow token transfer.
    function freezing(bool _transferFrozen) public onlyOwner {
        if (address(ico) != address(0) && !ico.isActive() && block.timestamp >= ico.startTime()) {
            transferFrozen = _transferFrozen;
        }
    }

    // ERC20 functions
    // =========================
    function transfer(address _to, uint _value) public returns (bool) {
        require(!transferFrozen);

        bool status = super.transfer(_to, _value);
        if (status) {
            require(address(dividends) != address(0));
            dividends.logAccount(msg.sender, 0);
            dividends.logAccount(_to, 0);
        }

        return status;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        require(!transferFrozen);

        bool status = super.transferFrom(_from, _to, _value);
        if (status) {
            require(address(dividends) != address(0));
            dividends.logAccount(_from, 0);
            dividends.logAccount(_to, 0);
        }

        return status;

    }

}

contract WhiteList is Ownable {

    mapping (address => bool) public whitelist;

    /* events */
    event WhitelistSet(address contributorAddress);

    event WhitelistUnset(address contributorAddress);

    modifier onlyWhitelisted() {
        require(true == whitelist[msg.sender]);
        _;
    }

    function WhiteList() public {
        whitelist[msg.sender] = true;
    }

    function addToWhitelist(address _address) public onlyOwner {
        whitelist[_address] = true;
        WhitelistSet(_address);
    }

    function removeFromWhitelist(address _address) public onlyOwner {
        whitelist[_address] = false;
        WhitelistUnset(_address);
    }

}

contract SparkDividends is Ownable {

    using SafeMath for uint256;

    Spark public spark;

    ICO public ico;

    address public treasuryAddress;

    mapping(address => DividendData[]) public accounts;

    FundsData[] public funds;

    struct DividendData {
        uint256 period;
        uint256 day;
        uint256 balance;
    }

    struct FundsData {
        uint256 period;
        uint256 ethersAmount;
    }

    event Disbursed(address indexed holder, uint256 value);

    modifier onlySparkContracts() {
        require(msg.sender == address(spark) || msg.sender == address(ico));
        _;
    }

    function SparkDividends(
        address _spark,
        address _ico,
        address _treasuryAddress
    ) public {
        require(_spark != address(0) && _ico != address(0) && _treasuryAddress != address(0));
        spark = Spark(_spark);
        ico = ICO(_ico);
        treasuryAddress = _treasuryAddress;
    }

    function setSpark(address _spark) public onlyOwner {
        require(_spark != address(0));
        spark = Spark(_spark);
    }

    function setICO(address _ico) public onlyOwner {
        require(_ico != address(0));
        ico = ICO(_ico);
    }

    function setTreasuryAddress(address _treasuryAddress) public onlyOwner {
        require(_treasuryAddress != address(0));
        treasuryAddress = _treasuryAddress;
    }

    function transferEthers() public onlyOwner {
        owner.transfer(this.balance);
    }

    function logAccount(address _address, uint256 _amount) public onlySparkContracts returns (bool) {
        uint256 day = 0;
        uint256 period = 1;

        if (now > ico.endTime()) {
            (period, day) = getPeriod(now);
        }

        if (_address != address(0) && period > 0) {
            if (day != 0 && _amount > 0) {
                logData(_address, period, 0, _amount);
            }

            logData(_address, period, day, 0);

            return true;
        }

        return false;
    }

    function setEtherAmount() public payable returns (bool) {
        if (msg.value == 0) {
            return false;
        }

        uint256 day = 0;
        uint256 period = 1;

        if (now > ico.endTime()) {
            (period, day) = getPeriod(now);
        }

        uint256 index = getFundsDataIndex(period);

        if (index == funds.length) {
            funds.push(FundsData(period, msg.value));
        } else {
            funds[index].ethersAmount = funds[index].ethersAmount.add(msg.value);
        }

        return true;
    }

    function claim() public returns (bool) {
        uint256 currentDay;
        uint256 currentPeriod;
        bool status;
        (currentPeriod, currentDay) = getPeriod(now);
        if (currentPeriod == 1) {
            return false;
        }

        uint256 dividendAmount;
        uint256 outdatedAmount;
        (dividendAmount, outdatedAmount) = calculateAmount(msg.sender, currentPeriod, currentDay);

        if (dividendAmount == 0) {
            return false;
        }

        msg.sender.transfer(dividendAmount);

        if (outdatedAmount > 0) {
            treasuryAddress.transfer(outdatedAmount);
        }

        if (cleanDividendsData(msg.sender, currentPeriod)) {
            Disbursed(msg.sender, dividendAmount);
            status = true;
        }

        require(status);
        return true;
    }

    function calculateAmount(
        address _address,
        uint256 _currentPeriod,
        uint256 _currentDay
    ) public view returns (uint256 totalAmount, uint256 totalOutdated) {
        for (uint256 i = 0; i < accounts[_address].length; i++) {
            if (accounts[_address][i].period < _currentPeriod) {
                uint256 index = getFundsDataIndex(accounts[_address][i].period);
                if (index == funds.length) {
                    continue;
                }
                uint256 dayEthers = funds[index].ethersAmount.div(90);
                uint256 balance;
                uint256 to = 90;

                if (
                    accounts[_address].length > i.add(1) &&
                    accounts[_address][i.add(1)].period == accounts[_address][i].period
                ) {
                    to = accounts[_address][i.add(1)].day;
                }

                for (uint256 j = accounts[_address][i].day; j < to; j++) {
                    balance = getBalanceByDay(_address, accounts[_address][i].period, j);
                    if (_currentPeriod.sub(accounts[_address][i].period) > 1 && _currentDay > 2) {
                        totalOutdated = totalOutdated.add(balance.mul(dayEthers).div(spark.maxSupply()));
                    } else {
                        totalAmount = totalAmount.add(balance.mul(dayEthers).div(spark.maxSupply()));
                    }
                }
            }
        }
    }

    function logData(address _address, uint256 _period, uint256 _day, uint256 _amount) internal {
        uint256 index = getDividendDataIndex(_address, _period, _day);
        if (accounts[_address].length == index) {
            accounts[_address].push(DividendData(_period, _day, spark.balanceOf(_address).sub(_amount)));
        } else if (_amount == 0) {
            accounts[_address][index].balance = spark.balanceOf(_address);
        }
    }

    function getPeriod(uint256 _time) internal view returns (uint256, uint256) {
        uint256 day = uint(_time.sub(ico.endTime()) % 90 days).div(1 days);
        uint256 period = _time.sub(ico.endTime()).div(90 days);

        return (++period, day);
    }

    function cleanDividendsData(address _address, uint256 _currentPeriod) internal returns (bool) {
        for (uint256 i = 0; i < accounts[_address].length; i++) {
            if (accounts[_address][i].period < _currentPeriod) {
                for (uint256 j = i; j < accounts[_address].length.sub(1); j++) {
                    DividendData storage dividend = accounts[_address][j];

                    dividend.period = accounts[_address][j.add(1)].period;
                    dividend.day = accounts[_address][j.add(1)].day;
                    dividend.balance = accounts[_address][j.add(1)].balance;
                }
                delete accounts[_address][accounts[_address].length.sub(1)];
                accounts[_address].length--;
                i--;
            }
        }

        return true;
    }

    function getFundsDataIndex(uint256 _period) internal view returns (uint256) {
        for (uint256 i = 0; i < funds.length; i++) {
            if (funds[i].period == _period) {
                return i;
            }
        }

        return funds.length;
    }

    function getBalanceByDay(address _address, uint256 _period, uint256 _day) internal view returns (uint256) {
        for (uint256 i = accounts[_address].length.sub(1); i >= 0; i--) {
            if (accounts[_address][i].period == _period && accounts[_address][i].day <= _day) {
                return accounts[_address][i].balance;
            }
        }

        return 0;
    }

    function getDividendDataIndex(address _address, uint256 _period, uint256 _day) internal view returns (uint256) {
        for (uint256 i = 0; i < accounts[_address].length; i++) {
            if (accounts[_address][i].period == _period && accounts[_address][i].day == _day) {
                return i;
            }
        }

        return accounts[_address].length;
    }

}

contract Multivest is Ownable {
    /* public variables */
    mapping (address => bool) public allowedMultivests;

    /* events */
    event MultivestSet(address multivest);

    event MultivestUnset(address multivest);

    event Contribution(address holder, uint256 value, uint256 tokens);

    modifier onlyAllowedMultivests(address _addresss) {
        require(allowedMultivests[_addresss] == true);
        _;
    }

    /* constructor */
    function Multivest(address _multivest) public {
        allowedMultivests[_multivest] = true;
    }

    function setAllowedMultivest(address _address) public onlyOwner {
        allowedMultivests[_address] = true;
        MultivestSet(_address);
    }

    function unsetAllowedMultivest(address _address) public onlyOwner {
        allowedMultivests[_address] = false;
        MultivestUnset(_address);
    }

    function multivestBuy(address _address, uint256 _value) public onlyAllowedMultivests(msg.sender) {
        require(buy(_address, _value) == true);
    }

    function multivestBuy(
        address _address,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public payable onlyAllowedMultivests(verify(keccak256(msg.sender), _v, _r, _s)) {
        require(_address == msg.sender && buy(msg.sender, msg.value) == true);
    }

    function verify(bytes32 _hash, uint8 _v, bytes32 _r, bytes32 _s) internal pure returns(address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";

        return ecrecover(keccak256(prefix, _hash), _v, _r, _s);
    }

    function buy(address _address, uint256 value) internal returns (bool);

}

contract SellableToken is Multivest {

    using SafeMath for uint256;

    // The token being sold
    Spark public spark;

    // start and end timestamps where investments are allowed (both inclusive)
    uint256 public startTime;
    uint256 public endTime;

    // amount of sold tokens
    uint256 public soldTokens;

    // amount of raised money in wei
    uint256 public collectedEthers;

    // address where funds are collected
    address public etherHolder;

    address public tokensHolder;

    Bonus[] public bonuses;

    struct Bonus {
        uint256 maxAmount;
        uint256 bonus;
    }

    function SellableToken(
        address _multivestAddress,
        address _etherHolder,
        address _tokensHolder,
        address _spark,
        uint256 _startTime,
        uint256 _endTime
    ) public Multivest(_multivestAddress)
    {
        require(_spark != address(0) && _etherHolder != address(0) && _tokensHolder != address(0));
        spark = Spark(_spark);
        etherHolder = _etherHolder;
        tokensHolder = _tokensHolder;

        require(_startTime < _endTime);

        startTime = _startTime;
        endTime = _endTime;
    }

    function setSpark(address _spark) public onlyOwner {
        require(_spark != address(0));
        spark = Spark(_spark);
    }

    function setEtherHolder(address _etherHolder) public onlyOwner {
        require(_etherHolder != address(0));
        etherHolder = _etherHolder;
    }

    function setTokenHolder(address _tokensHolder) public onlyOwner {
        require(_tokensHolder != address(0));
        tokensHolder = _tokensHolder;
    }

    function transferEthers() public onlyOwner {
        etherHolder.transfer(this.balance);
    }

    // @return true if sale period is active
    function isActive() public constant returns (bool) {
        if (soldTokens == spark.maxSupply()) {
            return false;
        }
        return withinPeriod();
    }

    // @return true if the transaction can buy tokens
    function withinPeriod() public constant returns (bool) {
        return block.timestamp >= startTime && block.timestamp <= endTime;
    }
}

contract ICO is SellableToken, WhiteList {

    uint256 public price;

    function ICO(
        address _multivestAddress,
        address _etherHolder,
        address _tokensHolder,
        address _spark,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _price
    ) public SellableToken(
        _multivestAddress,
        _etherHolder,
        _tokensHolder,
        _spark,
        _startTime,
        _endTime
    ) WhiteList() {
        require(_price > 0);
        price = _price;

        bonuses.push(Bonus(uint(10000000).mul(uint(10) ** spark.decimals()), uint256(150)));
        bonuses.push(Bonus(uint(15000000).mul(uint(10) ** spark.decimals()), uint256(125)));
        bonuses.push(Bonus(uint(20000000).mul(uint(10) ** spark.decimals()), uint256(110)));
    }

    function() public payable onlyWhitelisted {
        require(buy(msg.sender, msg.value) == true);
    }

    function allocateUnsoldTokens() public {
        if (!isActive() && block.timestamp >= startTime) {
            uint256 amount = spark.maxSupply().sub(soldTokens);
            require(amount > 0 && spark.mint(tokensHolder, amount) == amount);
            soldTokens = spark.maxSupply();
        }
    }

    function calculateTokensAmount(uint256 _value) public view returns (uint256 amount) {
        amount = _value.mul(uint(10) ** spark.decimals()).div(price);
        amount = amount.add(calculateBonusAmount(amount));
    }

    function calculateEthersAmount(uint256 _tokens) public view returns (uint256 ethers, uint256 bonus) {
        if (_tokens == 0) {
            return (0, 0);
        }

        ethers = _tokens.mul(price).div(uint(10) ** spark.decimals());
        bonus = calculateBonusAmount(_tokens);
    }

    function buy(address _address, uint256 _value) internal returns (bool) {
        if (_value == 0) {
            return false;
        }

        require(withinPeriod() && _address != address(0));

        uint256 amount = calculateTokensAmount(_value);

        require(amount > 0 && spark.mint(_address, amount) == amount);

        collectedEthers = collectedEthers.add(_value);
        soldTokens = soldTokens.add(amount);

        Contribution(_address, _value, amount);

        return true;
    }

    function calculateBonusAmount(uint256 _amount) internal view returns (uint256) {
        uint256 newSoldTokens = soldTokens;
        uint256 remainingValue = _amount;

        for (uint i = 0; i < bonuses.length; i++) {

            if (bonuses[i].maxAmount > soldTokens) {
                uint256 amount = remainingValue.mul(bonuses[i].bonus).div(100);
                if (newSoldTokens.add(amount) > bonuses[i].maxAmount) {
                    uint256 diff = bonuses[i].maxAmount.sub(newSoldTokens);
                    remainingValue = remainingValue.sub(diff.mul(100).div(bonuses[i].bonus));
                    newSoldTokens = newSoldTokens.add(diff);
                } else {
                    remainingValue = 0;
                    newSoldTokens = newSoldTokens.add(amount);
                }

                if (remainingValue == 0) {
                    break;
                }
            }
        }

        return newSoldTokens.add(remainingValue).sub(soldTokens.add(_amount));
    }

}