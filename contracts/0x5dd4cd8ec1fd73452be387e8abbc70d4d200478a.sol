pragma solidity ^0.5.0;

/**
 * @title AccessDelegated
 * @dev Modified version of standard Ownable Contract
 * The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */


contract IReputationToken {
    function migrateOut(IReputationToken _destination, uint256 _attotokens) public returns (bool);
    function migrateIn(address _reporter, uint256 _attotokens) public returns (bool);
    function trustedReportingParticipantTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
    function trustedMarketTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
    function trustedDisputeWindowTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
    function trustedUniverseTransfer(address _source, address _destination, uint256 _attotokens) public returns (bool);
    function getUniverse() public view returns (IUniverse);
    function getTotalMigrated() public view returns (uint256);
    function getTotalTheoreticalSupply() public view returns (uint256);
    function mintForReportingParticipant(uint256 _amountMigrated) public returns (bool);
}

contract IUniverse {
    
    function createYesNoMarket(uint256 _endTime, uint256 _feePerEthInWei, address _designatedReporterAddress, address _denominationToken, bytes32 _topic, string memory _description, string memory _extraInfo) public payable;
    
    function fork() public returns (bool);
    function getParentUniverse() public view returns (IUniverse);
    function getChildUniverse(bytes32 _parentPayoutDistributionHash) public view returns (IUniverse);
    function getForkEndTime() public view returns (uint256);
    function getForkReputationGoal() public view returns (uint256);
    function getParentPayoutDistributionHash() public view returns (bytes32);
    function getDisputeRoundDurationInSeconds() public view returns (uint256);
    function getOpenInterestInAttoEth() public view returns (uint256);
    function getRepMarketCapInAttoEth() public view returns (uint256);
    function getTargetRepMarketCapInAttoEth() public view returns (uint256);
    function getOrCacheValidityBond() public returns (uint256);
    function getOrCacheDesignatedReportStake() public returns (uint256);
    function getOrCacheDesignatedReportNoShowBond() public returns (uint256);
    function getOrCacheReportingFeeDivisor() public returns (uint256);
    function getDisputeThresholdForFork() public view returns (uint256);
    function getDisputeThresholdForDisputePacing() public view returns (uint256);
    function getInitialReportMinValue() public view returns (uint256);
    function calculateFloatingValue(uint256 _badMarkets, uint256 _totalMarkets, uint256 _targetDivisor, uint256 _previousValue, uint256 _defaultValue, uint256 _floor) public pure returns (uint256 _newValue);
    function getOrCacheMarketCreationCost() public returns (uint256);
    function isParentOf(IUniverse _shadyChild) public view returns (bool);
    function updateTentativeWinningChildUniverse(bytes32 _parentPayoutDistributionHash) public returns (bool);
    function addMarketTo() public returns (bool);
    function removeMarketFrom() public returns (bool);
    function decrementOpenInterest(uint256 _amount) public returns (bool);
    function decrementOpenInterestFromMarket(uint256 _amount) public returns (bool);
    function incrementOpenInterest(uint256 _amount) public returns (bool);
    function incrementOpenInterestFromMarket(uint256 _amount) public returns (bool);
    function getWinningChildUniverse() public view returns (IUniverse);
    function isForking() public view returns (bool);
}


contract AccessDelegated {

  /**
   * @dev ownership set via mapping with the following levels of access:
   * 0 - access level given to all addresses by default
   * 1 - limited access
   * 2 - priveleged access
   * 3 - manager access
   * 4 - owner access
   */

    mapping(address => uint256) public accessLevel;

    event AccessLevelSet(
        address accessSetFor,
        uint256 accessLevel,
        address setBy
    );
    event AccessRevoked(
        address accessRevoked,
        uint256 previousAccessLevel,
        address revokedBy
    );


    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() public {
        accessLevel[msg.sender] = 4;
    }

    /// Modifiers to restrict access to only those ABOVE a specific access level

    modifier requiresNoAccessLevel () {
        require(
            accessLevel[msg.sender] >= 0,
            "Access level greater than or equal to 0 required"
        );
        _;
    }

    modifier requiresLimitedAccessLevel () {
        require(
            accessLevel[msg.sender] >= 1,
            "Access level greater than or equal to 1 required"
        );
        _;
    }

    modifier requiresPrivelegedAccessLevel () {
        require(
            accessLevel[msg.sender] >= 2,
            "Access level greater than or equal to 2 required"
        );
        _;
    }

    modifier requiresManagerAccessLevel () {
        require(
            accessLevel[msg.sender] >= 3,
            "Access level greater than or equal to 3 required"
        );
        _;
    }

    modifier requiresOwnerAccessLevel () {
        require(
            accessLevel[msg.sender] >= 4,
            "Access level greater than or equal to 4 required"
        );
        _;
    }

    /// Modifiers to restrict access to ONLY a specific access level

    modifier limitedAccessLevelOnly () {
        require(accessLevel[msg.sender] == 1, "Access level 1 required");
        _;
    }

    modifier privelegedAccessLevelOnly () {
        require(accessLevel[msg.sender] == 2, "Access level 2 required");
        _;
    }

    modifier managerAccessLevelOnly () {
        require(accessLevel[msg.sender] == 3, "Access level 3 required");
        _;
    }

    modifier adminAccessLevelOnly () {
        require(accessLevel[msg.sender] == 4, "Access level 4 required");
        _;
    }


    /**
     * @dev setAccessLevel for a user restricted to contract owner
     * @dev Ideally, check for whole number should be implemented (TODO)
     * @param _user address that access level is to be set for
     * @param _access uint256 level of access to give 0, 1, 2, 3.
     */
    function setAccessLevel(
        address _user,
        uint256 _access
    )
        public
        adminAccessLevelOnly
    {
        require(
            accessLevel[_user] < 4,
            "Cannot setAccessLevel for Admin Level Access User"
        ); /// owner access not allowed to be set

        if (_access < 0 || _access > 4) {
            revert("erroneous access level");
        } else {
            accessLevel[_user] = _access;
        }

        emit AccessLevelSet(_user, _access, msg.sender);
    }

    function revokeAccess(address _user) public adminAccessLevelOnly {
        /// admin cannot revoke own access
        require(
            accessLevel[_user] < 4,
            "admin cannot revoke their own access"
        );
        uint256 currentAccessLevel = accessLevel[_user];
        accessLevel[_user] = 0;

        emit AccessRevoked(_user, currentAccessLevel, msg.sender);
    }

    /**
     * @dev getAccessLevel for a _user given their address
     * @param _user address of user to return access level
     * @return uint256 access level of _user
     */
    function getAccessLevel(address _user) public view returns (uint256) {
        return accessLevel[_user];
    }

    /**
     * @dev helper function to make calls more efficient
     * @return uint256 access level of the caller
     */
    function myAccessLevel() public view returns (uint256) {
        return getAccessLevel(msg.sender);
    }

}

// contract accessRestrictions {

//     mapping(address => mapping(uint => uint)) public transactionLimits;

//     /// COUNT OF USERS WITH ACCESS LEVELS FOR LIMITATION AND RECORD KEEPING
// }

/**
* @title ERC20Basic
* @dev Simpler version of ERC20 interface
* See https://github.com/ethereum/EIPs/issues/179
*/
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
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


/**
* @title Basic token
* @dev Basic version of StandardToken, with no allowances.
*/
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    uint256 totalSupply_;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
    * @dev Transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

}


/**
* @title ERC20 interface
* @dev see https://github.com/ethereum/EIPs/issues/20
*/
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender)
        public view returns (uint256);

    function transferFrom(address from, address to, uint256 value)
        public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


/**
* @title Standard ERC20 token
*
* @dev Implementation of the basic standard token.
* https://github.com/ethereum/EIPs/issues/20
* Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
*/
contract Token is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;


    /**
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    )
        public
        returns (bool)
    {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
    function allowance(
        address _owner,
        address _spender
    )
        public
        view
        returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    /**
    * @dev Increase the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed[_spender] == 0. To increment
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param _spender The address which will spend the funds.
    * @param _addedValue The amount of tokens to increase the allowance by.
    */
    function increaseApproval(
        address _spender,
        uint256 _addedValue
    )
        public
        returns (bool)
    {
        allowed[msg.sender][_spender] = (
        allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
    * @dev Decrease the amount of tokens that an owner allowed to a spender.
    * approve should be called when allowed[_spender] == 0. To decrement
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param _spender The address which will spend the funds.
    * @param _subtractedValue The amount of tokens to decrease the allowance by.
    */
    function decreaseApproval(
        address _spender,
        uint256 _subtractedValue
    )
        public
        returns (bool)
    {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

/**
     * @title StakeToken
     */
contract StakeToken is Token {

    string public constant NAME = "TestTokenERC20"; // solium-disable-line uppercase
    string public constant SYMBOL = "T20"; // solium-disable-line uppercase
    uint8 public constant DECIMALS = 18; // solium-disable-line uppercase
    uint256 public constant INITIAL_SUPPLY = 10000 * (10 ** uint256(DECIMALS));

    /**
    * @dev Constructor that gives msg.sender all of existing tokens.
    */
    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
    }

    /**
     * @notice get some tokens to use for testing purposes
     * @dev mints some tokens to the function caller
     */
    function giveMeTokens() public {
        balances[msg.sender] += INITIAL_SUPPLY;
        totalSupply_ += INITIAL_SUPPLY;
    }
}

contract StakingContract {
    using SafeMath for *;

    event TokensStaked(address msgSender, address txOrigin, uint256 _amount);

    address public stakingTokenAddress;

    // Token used for staking
    StakeToken stakingToken;

    // The default duration of stake lock-in (in seconds)
    uint256 public defaultLockInDuration;

    // To save on gas, rather than create a separate mapping for totalStakedFor & personalStakes,
    //  both data structures are stored in a single mapping for a given addresses.
    //
    // It's possible to have a non-existing personalStakes, but have tokens in totalStakedFor
    //  if other users are staking on behalf of a given address.
    mapping (address => StakeContract) public stakeHolders;

    // Struct for personal stakes (i.e., stakes made by this address)
    // unlockedTimestamp - when the stake unlocks (in seconds since Unix epoch)
    // actualAmount - the amount of tokens in the stake
    // stakedFor - the address the stake was staked for
    struct Stake {
        uint256 unlockedTimestamp;
        uint256 actualAmount;
        address stakedFor;
    }

    // Struct for all stake metadata at a particular address
    // totalStakedFor - the number of tokens staked for this address
    // personalStakeIndex - the index in the personalStakes array.
    // personalStakes - append only array of stakes made by this address
    // exists - whether or not there are stakes that involve this address
    struct StakeContract {
        uint256 totalStakedFor;

        uint256 personalStakeIndex;

        Stake[] personalStakes;

        bool exists;
    }

    event Staked(address indexed user, uint256 amount, uint256 total, bytes data);
    event Unstaked(address indexed user, uint256 amount, uint256 total, bytes data);


    constructor() public {

    }

    modifier canStake(address _address, uint256 _amount) {
        require(
            stakingToken.transferFrom(_address, address(this), _amount),
            "Stake required");
        _;
    }


    function initForTests(address _token) public {
        stakingTokenAddress = _token;
        // StakeToken(stakingTokenAddress).giveMeTokens();
        // StakeToken(stakingTokenAddress).balanceOf(this);
        stakingToken = StakeToken(stakingTokenAddress);
    }


    function stake(uint256 _amount) public returns (bool) {
        createStake(
            msg.sender,
            _amount);
        return true;
    }


    function createStake(
        address _address,
        uint256 _amount
    )
        internal
        canStake(msg.sender, _amount)
    {
        if (!stakeHolders[msg.sender].exists) {
            stakeHolders[msg.sender].exists = true;
        }

        stakeHolders[_address].totalStakedFor = stakeHolders[_address].totalStakedFor.add(_amount);
        stakeHolders[msg.sender].personalStakes.push(
            Stake(
                block.timestamp.add(2000),
                _amount,
                _address)
            );

    }


    function withdrawStake(
        uint256 _amount
    )
        internal
    {
        Stake storage personalStake = stakeHolders[msg.sender].personalStakes[stakeHolders[msg.sender].personalStakeIndex];

        // Check that the current stake has unlocked & matches the unstake amount
        require(
            personalStake.unlockedTimestamp <= block.timestamp,
            "The current stake hasn't unlocked yet");

        require(
            personalStake.actualAmount == _amount,
            "The unstake amount does not match the current stake");

        // Transfer the staked tokens from this contract back to the sender
        // Notice that we are using transfer instead of transferFrom here, so
        //  no approval is needed beforehand.
        require(
            stakingToken.transfer(msg.sender, _amount),
            "Unable to withdraw stake");

        stakeHolders[personalStake.stakedFor].totalStakedFor = stakeHolders[personalStake.stakedFor]
            .totalStakedFor.sub(personalStake.actualAmount);

        personalStake.actualAmount = 0;
        stakeHolders[msg.sender].personalStakeIndex++;
    }


}

contract AccessDelegatedTokenStorage is AccessDelegated {

    using SafeMath for *;

///|=:=|=:=|=:=|=:=|=:=|=:=|=:=|~Type Declarations~|=:=|=:=|=:=|=:=|=:=|=:=|=:=|\\\

    /// Token Balance for users with deposited tokens
    mapping(address => uint256) public userTokenBalance;

///|=:=|=:=|=:=|=:=|=:=|=:=|=:=|~~~~~Constants~~~~~|=:=|=:=|=:=|=:=|=:=|=:=|=:=|\\\

    // uint256 public constant TOKEN_DECIMALS = 18;
    // uint256 public constant PPB = 10 ** TOKEN_DECIMALS;

///|=:=|=:=|=:=|=:=|=:=|=:=|=:=|~~State Variables~~|=:=|=:=|=:=|=:=|=:=|=:=|=:=|\\\

    /// Total number of deposited tokens
    uint256 public totalTokenBalance;
    uint256 public stakedTokensReceivable;
    uint256 public approvedTokensPayable;

    /// Address of the token contract assigned to this contract
    // address public tokenAddress;
    // StakeToken public stakingToken; 
    address public token;
    address public tokenStakingContractAddress;
    address public augurUniverseAddress;


///|=:=|=:=|=:=|=:=|=:=|=:=|=:=|~~~~~~Events~~~~~~~|=:=|=:=|=:=|=:=|=:=|=:=|=:=|\\\

    // Event that logs the balance change of a user within this contract
    event UserBalanceChange(address indexed user, uint256 previousBalance, uint256 currentBalance);
    event TokenDeposit(address indexed user, uint256 amount);
    event TokenWithdrawal(address indexed user, uint256 amount);

///|=:=|=:=|=:=|=:=|=:=|=:=|=:=|~~~~~Modifiers~~~~~|=:=|=:=|=:=|=:=|=:=|=:=|=:=|\\\


///|=:=|=:=|=:=|=:=|=:=|=:=|=:=|~~~~Constructor~~~~|=:=|=:=|=:=|=:=|=:=|=:=|=:=|\\\

    constructor () public {
        // stakingToken = _stakingToken;
    }

///|=:=|=:=|=:=|=:=|=:=|=:=|=:=|~Fallback~Function~|=:=|=:=|=:=|=:=|=:=|=:=|=:=|\\\


///|=:=|=:=|=:=|=:=|=:=|=:=|=:=|Delegated~Token~Functions|=:=|=:=|=:=|=:=|=:=|=:=|=:=|\\\

    function delegatedTotalSupply() public view returns (uint256) {
        return StakeToken(token).totalSupply();
    }

    function delegatedBalanceOf(address _balanceHolder) public view returns (uint256) {
        return StakeToken(token).balanceOf(_balanceHolder);
    }

    function delegatedAllowance(address _owner, address _spender) public view returns (uint256) {
        return StakeToken(token).allowance(_owner, _spender);
    }

    function delegatedApprove(address _spender, uint256 _value) public adminAccessLevelOnly returns (bool) {
        return StakeToken(token).approve(_spender, _value);
    }

    function delegatedTransferFrom(address _from, address _to, uint256 _value) public adminAccessLevelOnly returns (bool) {
        return StakeToken(token).transferFrom(_from, _to, _value);
    }

    function delegatedTokenTransfer(address _to, uint256 _value) public adminAccessLevelOnly returns (bool) {
        return StakeToken(token).transfer(_to, _value);
    }

    function delegatedIncreaseApproval(address _spender, uint256 _addedValue) public adminAccessLevelOnly returns (bool) {
        return StakeToken(token).increaseApproval(_spender, _addedValue);
    }

    function delegatedDecreaseApproval(address _spender, uint256 _subtractedValue) public adminAccessLevelOnly returns (bool) {
        return StakeToken(token).decreaseApproval(_spender, _subtractedValue);
    }

    function delegatedStake(uint256 _amount) public returns (bool) {
        require(StakingContract(tokenStakingContractAddress).stake(_amount), "staking must be successful");
        stakedTokensReceivable += _amount;
        approvedTokensPayable -= _amount;
    }

    function delegatedApproveSpender(address _address, uint256 _amount) public returns (bool) {
        require(StakeToken(token).approve(_address, _amount), "approval must be successful");
        approvedTokensPayable += _amount;
    }
    
    function depositEther() public payable {
        
    }
    
    function delegatedCreateYesNoMarket(
        uint256 _endTime,
        uint256 _feePerEthInWei,
        address _denominationToken,
        address _designatedReporterAddress,
        bytes32 _topic,
        string memory _description,
        string memory _extraInfo) public payable {
            IUniverse(augurUniverseAddress).createYesNoMarket(
        _endTime,
        _feePerEthInWei,
        _denominationToken,
        _designatedReporterAddress,
        _topic,
        _description,
        _extraInfo);
        }
    // function stakeFor(address user, uint256 amount, bytes data) public returns (bool);
    // function unstake(uint256 amount, bytes data) public returns (bool);
    // function totalStakedFor(address addr) public view returns (uint256);
    // function totalStaked() public view returns (uint256);

///|=:=|=:=|=:=|=:=|=:=|=:=|=:=|~Public~~Functions~|=:=|=:=|=:=|=:=|=:=|=:=|=:=|\\\

    // /**
    //  * @dev setTokenContract sets the token contract for use within this contract
    //  * @param _token address of the token contract to set
    //  */
    
    function setTokenContract(address _token) external {
        token = _token;
    }

    function setTokenStakingContract(address _stakingContractAddress) external {
        tokenStakingContractAddress = _stakingContractAddress;
    }
    
    function setAugurUniverse(address augurUniverse) external {
        augurUniverseAddress = address(IUniverse(augurUniverse));
    }

    /**
     * @notice Deposit funds into contract.
     * @dev the amount of deposit is determined by allowance of this contract
     */
    function depositToken(address _user) public {


        uint256 allowance = StakeToken(token).allowance(_user, address(this));
        uint256 oldBalance = userTokenBalance[_user];
        uint256 newBalance = oldBalance.add(allowance);
        require(StakeToken(token).transferFrom(_user, address(this), allowance), "transfer failed");

        /// Update user balance
        userTokenBalance[_user] = newBalance;

        /// update the total balance for the token
        totalTokenBalance = totalTokenBalance.add(allowance);

        // assert(StakeToken(token).balanceOf(address(this)) == totalTokenBalance);

        /// Fire event and return some goodies
        emit UserBalanceChange(_user, oldBalance, newBalance);
    }
    
    function proxyDepositToken(address _user, uint256 _amount) external {
        uint256 oldBalance = userTokenBalance[_user];
        uint256 newBalance = oldBalance.add(_amount);
        
        /// Update user balance
        userTokenBalance[_user] = newBalance;

        /// update the total balance for the token
        totalTokenBalance = totalTokenBalance.add(_amount);
        
        emit UserBalanceChange(_user, oldBalance, newBalance);
    }
    

    function checkTotalBalanceExternal() public view returns (uint256, uint256) {
        return (StakeToken(token).balanceOf(address(this)), StakeToken(token).balanceOf(address(this)));
    }

    function balanceChecks() public view returns (uint256, uint256, uint256, uint256) {
        return (
            stakedTokensReceivable,
            approvedTokensPayable,
            totalTokenBalance,
            StakeToken(token).balanceOf(address(tokenStakingContractAddress))
        );
    }


    /**
     * @dev withdrawTokens allows the initial depositing user to withdraw tokens previously deposited
     * @param _user address of the user making the withdrawal
     * @param _amount uint256 of token to be withdrawn
     */
    function withdrawTokens(address _user, uint256 _amount) public returns (bool) {

        // solium-ignore-next-line
        // require(tx.origin == _user, "tx origin does not match _user");
        
        uint256 currentBalance = userTokenBalance[_user];

        require(_amount <= currentBalance, "Withdraw amount greater than current balance");

        uint256 newBalance = currentBalance.sub(_amount);

        require(StakeToken(token).transfer(_user, _amount), "error during token transfer");

        /// Update user balance
        userTokenBalance[_user] = newBalance;

        /// update the total balance for the token
        totalTokenBalance = SafeMath.sub(totalTokenBalance, _amount);

        /// Fire event and return some goodies
        emit TokenWithdrawal(_user, _amount);
        emit UserBalanceChange(_user, currentBalance, newBalance);
    }

    /**
     * @dev makeDeposit function calls deposit token passing msg.sender as the user
     */
    function makeDeposit() public { 
        depositToken(msg.sender);
    }

    /**
     * @dev makeDeposit function calls deposit token passing msg.sender as the user
     * @param _amount uint256 of token to withdraw
     */
    function makeWithdrawal(uint256 _amount) public { 
        withdrawTokens(msg.sender, _amount);
        emit TokenWithdrawal(msg.sender, _amount);
    }


    /**
     * @dev getUserTokenBalance returns the token balance given a user address
     * @param _user address of the user for balance retrieval
     */
    function getUserTokenBalance(address _user) public view returns (uint256 balance) {
        return userTokenBalance[_user];
    }

    /**
     * @dev getstakingToken returns the address of the token set for this contract
     */
    function getTokenAddress() public view returns (address tokenContract) {
        return token;
    }

///|=:=|=:=|=:=|=:=|=:=|=:=|=:=|Internal~~Functions|=:=|=:=|=:=|=:=|=:=|=:=|=:=|\\\


///|=:=|=:=|=:=|=:=|=:=|=:=|=:=|~Private~Functions~|=:=|=:=|=:=|=:=|=:=|=:=|=:=|\\\

    
}