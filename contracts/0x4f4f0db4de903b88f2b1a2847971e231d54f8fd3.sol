pragma solidity ^0.4.16;

/*
	@title GEEToken
*/

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {


    address owner;

    event OwnershipTransferred(address indexed _previousOwner, address indexed _newOwner);

    function Ownable() {
        owner = msg.sender;
        OwnershipTransferred (address(0), owner);
    }

    function transferOwnership(address _newOwner)
        public
        onlyOwner
        notZeroAddress(_newOwner)
    {
        owner = _newOwner;
        OwnershipTransferred(msg.sender, _newOwner);
    }

    //Only owner can call function
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier notZeroAddress(address _address) {
        require(_address != address(0));
        _;
    }

}

/*
	Trustable saves trusted addresses
*/
contract Trustable is Ownable {


    //Only trusted addresses are able to transfer tokens during the Crowdsale
    mapping (address => bool) trusted;

    event AddTrusted (address indexed _trustable);
    event RemoveTrusted (address indexed _trustable);

    function Trustable() {
        trusted[msg.sender] = true;
        AddTrusted(msg.sender);
    }

    //Add new trusted address
    function addTrusted(address _address)
        external
        onlyOwner
        notZeroAddress(_address)
    {
        trusted[_address] = true;
        AddTrusted(_address);
    }

    //Remove address from a trusted list
    function removeTrusted(address _address)
        external
        onlyOwner
        notZeroAddress(_address)
    {
        trusted[_address] = false;
        RemoveTrusted(_address);
    }

}

contract Pausable is Trustable {


    //To check if Token is paused
    bool public paused;
    //Block number on pause
    uint256 public pauseBlockNumber;
    //Block number on resume
    uint256 public resumeBlockNumber;

    event Pause(uint256 _blockNumber);
    event Unpause(uint256 _blockNumber);

    function pause()
        public
        onlyOwner
        whenNotPaused
    {
        paused = true;
        pauseBlockNumber = block.number;
        resumeBlockNumber = 0;
        Pause(pauseBlockNumber);
    }

    function unpause()
        public
        onlyOwner
        whenPaused
    {
        paused = false;
        resumeBlockNumber = block.number;
        pauseBlockNumber = 0;
        Unpause(resumeBlockNumber);
    }

    modifier whenNotPaused {
        require(!paused);
        _;
    }

    modifier whenPaused {
        require(paused);
        _;
    }

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /*
        @return sum of a and b
    */
    function ADD (uint256 a, uint256 b) internal returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    /*
        @return difference of a and b
    */
    function SUB (uint256 a, uint256 b) internal returns (uint256) {
        assert(a >= b);
        return a - b;
    }
    
}

/*
	ERC20 Token Standart
	https://github.com/ethereum/EIPs/issues/20
	https://theethereum.wiki/w/index.php/ERC20_Token_Standard
*/

contract ERC20 {


    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function totalSupply() external constant returns (uint);

    function balanceOf(address _owner) external constant returns (uint256);

    function transfer(address _to, uint256 _value) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);

    function approve(address _spender, uint256 _value) external returns (bool);

    function allowance(address _owner, address _spender) external constant returns (uint256);

}

/*
	Contract determines token
*/
contract Token is ERC20, Pausable {


    using SafeMath for uint256;

    //Total amount of Gee
    uint256 _totalSupply = 100 * (10**6) * (10**8);

    //end of crowdsale
    uint256 public crowdsaleEndBlock = 4695000;
    //max end of crowdsale
    uint256 public constant MAX_END_BLOCK_NUMBER = 4890000;

    //Balances for each account
    mapping (address => uint256)  balances;
    //Owner of the account approves the transfer of an amount to another account
    mapping (address => mapping (address => uint256)) allowed;

    //Notifies users about the amount burnt
    event Burn(address indexed _from, uint256 _value);
    //Notifies users about end block change
    event CrowdsaleEndChanged (uint256 _crowdsaleEnd, uint256 _newCrowdsaleEnd);

    //return _totalSupply of the Token
    function totalSupply() external constant returns (uint256 totalTokenSupply) {
        totalTokenSupply = _totalSupply;
    }

    //What is the balance of a particular account?
    function balanceOf(address _owner)
        external
        constant
        returns (uint256 balance)
    {
        return balances[_owner];
    }

    //Transfer the balance from owner's account to another account
    function transfer(address _to, uint256 _amount)
        external
        notZeroAddress(_to)
        whenNotPaused
        canTransferOnCrowdsale(msg.sender)
        returns (bool success)
    {
        balances[msg.sender] = balances[msg.sender].SUB(_amount);
        balances[_to] = balances[_to].ADD(_amount);
        Transfer(msg.sender, _to, _amount);
        return true;
    }

    // Send _value amount of tokens from address _from to address _to
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the _from account has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    function transferFrom(address _from, address _to, uint256 _amount)
        external
        notZeroAddress(_to)
        whenNotPaused
        canTransferOnCrowdsale(msg.sender)
        canTransferOnCrowdsale(_from)
        returns (bool success)
    {
        //Require allowance to be not too big
        require(allowed[_from][msg.sender] >= _amount);
        balances[_from] = balances[_from].SUB(_amount);
        balances[_to] = balances[_to].ADD(_amount);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].SUB(_amount);
        Transfer(_from, _to, _amount);
        return true;
    }

    // Allow _spender to withdraw from your account, multiple times, up to the _value amount.
    // If this function is called again it overwrites the current allowance with _value.
    function approve(address _spender, uint256 _amount)
        external
        whenNotPaused
        notZeroAddress(_spender)
        returns (bool success)
    {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    //Return how many tokens left that you can spend from
    function allowance(address _owner, address _spender)
        external
        constant
        returns (uint256 remaining)
    {
        return allowed[_owner][_spender];
    }

    /**
     * To increment allowed value is better to use this function to avoid 2 calls
     * From MonolithDAO Token.sol
     */

    function increaseApproval(address _spender, uint256 _addedValue)
        external
        whenNotPaused
        returns (bool success)
    {
        uint256 increased = allowed[msg.sender][_spender].ADD(_addedValue);
        require(increased <= balances[msg.sender]);
        //Cannot approve more coins then you have
        allowed[msg.sender][_spender] = increased;
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue)
        external
        whenNotPaused
        returns (bool success)
    {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.SUB(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function burn(uint256 _value) external returns (bool success) {
        require(trusted[msg.sender]);
        //Subtract from the sender
        balances[msg.sender] = balances[msg.sender].SUB(_value);
        //Update _totalSupply
        _totalSupply = _totalSupply.SUB(_value);
        Burn(msg.sender, _value);
        return true;
    }

    function updateCrowdsaleEndBlock (uint256 _crowdsaleEndBlock) external onlyOwner {

        require(block.number <= crowdsaleEndBlock);                 //Crowdsale must be active
        require(_crowdsaleEndBlock >= block.number);
        require(_crowdsaleEndBlock <= MAX_END_BLOCK_NUMBER);        //Transfers can only be unlocked earlier

        uint256 currentEndBlockNumber = crowdsaleEndBlock;
        crowdsaleEndBlock = _crowdsaleEndBlock;
        CrowdsaleEndChanged (currentEndBlockNumber, _crowdsaleEndBlock);
    }

    //Override transferOwnership()
    function transferOwnership(address _newOwner) public afterCrowdsale {
        super.transferOwnership(_newOwner);
    }

    //Override pause()
    function pause() public afterCrowdsale {
        super.pause();
    }

    modifier canTransferOnCrowdsale (address _address) {
        if (block.number <= crowdsaleEndBlock) {
            //Require the end of funding or msg.sender to be trusted
            require(trusted[_address]);
        }
        _;
    }

    //Some functions should work only after the Crowdsale
    modifier afterCrowdsale {
        require(block.number > crowdsaleEndBlock);
        _;
    }

}

/*
	Inspired by Civic and Golem

*/

/*
	Interface of migrate agent contract (the new token contract)
*/
contract MigrateAgent {

    function migrateFrom(address _tokenHolder, uint256 _amount) external returns (bool);

}

contract MigratableToken is Token {

    MigrateAgent public migrateAgent;

    //Total migrated tokens
    uint256 public totalMigrated;

    /**
     * Migrate states.
     *
     * - NotAllowed: The child contract has not reached a condition where the upgrade can bgun
     * - WaitingForAgent: Token allows upgrade, but we don't have a new agent yet
     * - ReadyToMigrate: The agent is set, but not a single token has been upgraded yet
     * - Migrating: Upgrade agent is set and the balance holders can upgrade their tokens
     *
     */
    enum MigrateState {Unknown, NotAllowed, WaitingForAgent, ReadyToMigrate, Migrating}
    event Migrate (address indexed _from, address indexed _to, uint256 _value);
    event MigrateAgentSet (address _agent);

    function migrate(uint256 _value) external {
        MigrateState state = getMigrateState();
        //Migrating has started
        require(state == MigrateState.ReadyToMigrate || state == MigrateState.Migrating);
        //Migrates user balance
        balances[msg.sender] = balances[msg.sender].SUB(_value);
        //Migrates total supply
        _totalSupply = _totalSupply.SUB(_value);
        //Counts migrated tokens
        totalMigrated = totalMigrated.ADD(_value);
        //Upgrade agent reissues the tokens
        migrateAgent.migrateFrom(msg.sender, _value);
        Migrate(msg.sender, migrateAgent, _value);
    }

    /*
        Set migrating agent and start migrating
    */
    function setMigrateAgent(MigrateAgent _agent)
    external
    onlyOwner
    notZeroAddress(_agent)
    afterCrowdsale
    {
        //cannot interrupt migrating
        require(getMigrateState() != MigrateState.Migrating);
        //set migrate agent
        migrateAgent = _agent;
        //Emit event
        MigrateAgentSet(migrateAgent);
    }

    /*
        Migrating status
    */
    function getMigrateState() public constant returns (MigrateState) {
        if (block.number <= crowdsaleEndBlock) {
            //Migration is not allowed on funding
            return MigrateState.NotAllowed;
        } else if (address(migrateAgent) == address(0)) {
            //Migrating address is not set
            return MigrateState.WaitingForAgent;
        } else if (totalMigrated == 0) {
            //Migrating hasn't started yet
            return MigrateState.ReadyToMigrate;
        } else {
            //Migrating
            return MigrateState.Migrating;
        }

    }

}

/*
	Contract defines specific token
*/
contract GEEToken is MigratableToken {

    
    //Name of the token
    string public constant name = "Geens Platform Token";
    //Symbol of the token
    string public constant symbol = "GEE";
    //Number of decimals of GEE
    uint8 public constant decimals = 8;

    //Team allocation
    //Team wallet that will be unlocked after ICO
    address public constant TEAM0 = 0x9B4df4ac63B6049DD013090d3F639Fd2EA5A02d3;
    //Team wallet that will be unlocked after 0.5 year after ICO
    address public constant TEAM1 = 0x4df9348239f6C1260Fc5d0611755cc1EF830Ff6c;
    //Team wallet that will be unlocked after 1 year after ICO
    address public constant TEAM2 = 0x4902A52F95d9D47531Bed079B5B028c7F89ad47b;
    //0.5 year after ICO
    uint256 public constant UNLOCK_TEAM_1 = 1528372800;
    //1 year after ICO
    uint256 public constant UNLOCK_TEAM_2 = 1544184000;
    //1st team wallet balance
    uint256 public team1Balance;
    //2nd team wallet balance
    uint256 public team2Balance;

    //Community allocation
    address public constant COMMUNITY = 0x265FC1d98f3C0D42e4273F542917525C3c3F925A;

    //2.4%
    uint256 private constant TEAM0_THOUSANDTH = 24;
    //3.6%
    uint256 private constant TEAM1_THOUSANDTH = 36;
    //6%
    uint256 private constant TEAM2_THOUSANDTH = 60;
    //67%
    uint256 private constant ICO_THOUSANDTH = 670;
    //21%
    uint256 private constant COMMUNITY_THOUSANDTH = 210;
    //100%
    uint256 private constant DENOMINATOR = 1000;

    function GEEToken() {
        //67% of _totalSupply
        balances[msg.sender] = _totalSupply * ICO_THOUSANDTH / DENOMINATOR;
        //2.4% of _totalSupply
        balances[TEAM0] = _totalSupply * TEAM0_THOUSANDTH / DENOMINATOR;
        //3.6% of _totalSupply
        team1Balance = _totalSupply * TEAM1_THOUSANDTH / DENOMINATOR;
        //6% of _totalSupply
        team2Balance = _totalSupply * TEAM2_THOUSANDTH / DENOMINATOR;
        //21% of _totalSupply
        balances[COMMUNITY] =  _totalSupply * COMMUNITY_THOUSANDTH / DENOMINATOR;

        Transfer (this, msg.sender, balances[msg.sender]);
        Transfer (this, TEAM0, balances[TEAM0]);
        Transfer (this, COMMUNITY, balances[COMMUNITY]);

    }

    //Check if team wallet is unlocked
    function unlockTeamTokens(address _address) external onlyOwner {
        if (_address == TEAM1) {
            require(UNLOCK_TEAM_1 <= now);
            require (team1Balance > 0);
            balances[TEAM1] = team1Balance;
            team1Balance = 0;
            Transfer (this, TEAM1, balances[TEAM1]);
        } else if (_address == TEAM2) {
            require(UNLOCK_TEAM_2 <= now);
            require (team2Balance > 0);
            balances[TEAM2] = team2Balance;
            team2Balance = 0;
            Transfer (this, TEAM2, balances[TEAM2]);
        }
    }

}