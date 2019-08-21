contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
   * @return true if `msg.sender` is the owner of the contract.
   */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}
contract ERC20Interface {

    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function allowance(address owner, address spender)public view returns (uint256);
    function transferFrom(address from, address to, uint256 value)public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}
contract StandardToken is ERC20Interface {

    using SafeMath for uint256;

    mapping(address => uint256) public balances;
    mapping (address => mapping (address => uint256)) internal allowed;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply_;

    // the following variables need to be here for scoping to properly freeze normal transfers after migration has started
    // migrationStart flag
    bool public migrationStart;
    // var for storing the the TimeLock contract deployment address (for vesting GTX allocations)
    TimeLock timeLockContract;

    /**
     * @dev Modifier for allowing only TimeLock transactions to occur after the migration period has started
    */
    modifier migrateStarted {
        if(migrationStart == true){
            require(msg.sender == address(timeLockContract));
        }
        _;
    }

    constructor(string _name, string _symbol, uint8 _decimals) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

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
    function transfer(address _to, uint256 _value) public migrateStarted returns (bool) {
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
        migrateStarted
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
contract GTXERC20Migrate is Ownable {
    using SafeMath for uint256;

    // Address map used to store the per account claimable GTX Network Tokens
    // as per the user's GTX ERC20 on the Ethereum Network

    mapping (address => uint256) public migratableGTX;

    GTXToken public ERC20;

    constructor(GTXToken _ERC20) public {
        ERC20 = _ERC20;
    }

    // Note: _totalMigratableGTX is a running total of GTX, migratable in this contract,
    // but does not represent the actual amount of GTX migrated to the Gallactic network
    event GTXRecordUpdate(
        address indexed _recordAddress,
        uint256 _totalMigratableGTX
    );

    /**
    * @dev Used to calculate and store the amount of GTX ERC20 token balances to be migrated to the Gallactic network
    * i.e., 1 GTX = 10**18 base units
    * @param _balanceToMigrate - the requested balance to reserve for migration (in most cases this should be the account's total balance)
    * primarily included as a parameter for simple validation on the Gallactic side of the migration
    */
    function initiateGTXMigration(uint256 _balanceToMigrate) public {
        uint256 migratable = ERC20.migrateTransfer(msg.sender,_balanceToMigrate);
        migratableGTX[msg.sender] = migratableGTX[msg.sender].add(migratable);
        emit GTXRecordUpdate(msg.sender, migratableGTX[msg.sender]);
    }

}
contract TimeLock {
    //GTXERC20 var definition
    GTXToken public ERC20;
    // custom data structure to hold locked funds and time
    struct accountData {
        uint256 balance;
        uint256 releaseTime;
    }

    event Lock(address indexed _tokenLockAccount, uint256 _lockBalance, uint256 _releaseTime);
    event UnLock(address indexed _tokenUnLockAccount, uint256 _unLockBalance, uint256 _unLockTime);

    // only one locked account per address
    mapping (address => accountData) public accounts;

    /**
    * @dev Constructor in which we pass the ERC20 Contract address for reference and method calls
    */

    constructor(GTXToken _ERC20) public {
        ERC20 = _ERC20;
    }

    function timeLockTokens(uint256 _lockTimeS) public {

        uint256 lockAmount = ERC20.allowance(msg.sender, this); // get this time lock contract's approved amount of tokens
        require(lockAmount != 0); // check that this time lock contract has been approved to lock an amount of tokens on the msg.sender's behalf
        if (accounts[msg.sender].balance > 0) { // if locked balance already exists, add new amount to the old balance and retain the same release time
            accounts[msg.sender].balance = SafeMath.add(accounts[msg.sender].balance, lockAmount);
        } else { // else populate the balance and set the release time for the newly locked balance
            accounts[msg.sender].balance = lockAmount;
            accounts[msg.sender].releaseTime = SafeMath.add(block.timestamp , _lockTimeS);
        }

        emit Lock(msg.sender, lockAmount, accounts[msg.sender].releaseTime);
        ERC20.transferFrom(msg.sender, this, lockAmount);

    }

    function tokenRelease() public {
        // check if user has funds due for pay out because lock time is over
        require (accounts[msg.sender].balance != 0 && accounts[msg.sender].releaseTime <= block.timestamp);
        uint256 transferUnlockedBalance = accounts[msg.sender].balance;
        accounts[msg.sender].balance = 0;
        accounts[msg.sender].releaseTime = 0;
        emit UnLock(msg.sender, transferUnlockedBalance, block.timestamp);
        ERC20.transfer(msg.sender, transferUnlockedBalance);
    }

    // some helper functions for demo purposes (not required)
    function getLockedFunds(address _account) view public returns (uint _lockedBalance) {
        return accounts[_account].balance;
    }

    function getReleaseTime(address _account) view public returns (uint _releaseTime) {
        return accounts[_account].releaseTime;
    }

}
contract GTXToken is StandardToken, Ownable{
    using SafeMath for uint256;
    event SetMigrationAddress(address GTXERC20MigrateAddress);
    event SetAuctionAddress(address GTXAuctionContractAddress);
    event SetTimeLockAddress(address _timeLockAddress);
    event Migrated(address indexed account, uint256 amount);
    event MigrationStarted();


    //global variables
    GTXRecord public gtxRecord;
    GTXPresale public gtxPresale;
    uint256 public totalAllocation;

    // var for storing the the GTXRC20Migrate contract deployment address (for migration to the GALLACTIC network)
    TimeLock timeLockContract;
    GTXERC20Migrate gtxMigrationContract;
    GTXAuction gtxAuctionContract;

    /**
     * @dev Modifier for only GTX migration contract address
    */
    modifier onlyMigrate {
        require(msg.sender == address(gtxMigrationContract));
        _;
    }

    /**
     * @dev Modifier for only gallactic Auction contract address
    */
    modifier onlyAuction {
        require(msg.sender == address(gtxAuctionContract));
        _;
    }

    /**
     * @dev Constructor to pass the GTX ERC20 arguments
     * @param _totalSupply the total token supply (Initial Proposal is 1,000,000,000)
     * @param _gtxRecord the GTXRecord contract address to use for records keeping
     * @param _gtxPresale the GTXPresale contract address to use for records keeping
     * @param _name ERC20 Token Name (Gallactic Token)
     * @param _symbol ERC20 Token Symbol (GTX)
     * @param _decimals ERC20 Token Decimal precision value (18)
    */
    constructor(uint256 _totalSupply, GTXRecord _gtxRecord, GTXPresale _gtxPresale, string _name, string _symbol, uint8 _decimals)
    StandardToken(_name,_symbol,_decimals) public {
        require(_gtxRecord != address(0), "Must provide a Record address");
        require(_gtxPresale != address(0), "Must provide a PreSale address");
        require(_gtxPresale.getStage() > 0, "Presale must have already set its allocation");
        require(_gtxRecord.maxRecords().add(_gtxPresale.totalPresaleTokens()) <= _totalSupply, "Records & PreSale allocation exceeds the proposed total supply");

        totalSupply_ = _totalSupply; // unallocated until passAuctionAllocation is called
        gtxRecord = _gtxRecord;
        gtxPresale = _gtxPresale;
    }

    /**
    * @dev Fallback reverts any ETH payment
    */
    function () public payable {
        revert ();
    }

    /**
    * @dev Safety function for reclaiming ERC20 tokens
    * @param _token address of the ERC20 contract
    */
    function recoverLost(ERC20Interface _token) public onlyOwner {
        _token.transfer(owner(), _token.balanceOf(this));
    }

    /**
    * @dev Function to set the migration contract address
    * @return True if the operation was successful.
    */
    function setMigrationAddress(GTXERC20Migrate _gtxMigrateContract) public onlyOwner returns (bool) {
        require(_gtxMigrateContract != address(0), "Must provide a Migration address");
        // check that this GTX ERC20 deployment is the migration contract's attached ERC20 token
        require(_gtxMigrateContract.ERC20() == address(this), "Migration contract does not have this token assigned");

        gtxMigrationContract = _gtxMigrateContract;
        emit SetMigrationAddress(_gtxMigrateContract);
        return true;
    }

    /**
    * @dev Function to set the Auction contract address
    * @return True if the operation was successful.
    */
    function setAuctionAddress(GTXAuction _gtxAuctionContract) public onlyOwner returns (bool) {
        require(_gtxAuctionContract != address(0), "Must provide an Auction address");
        // check that this GTX ERC20 deployment is the Auction contract's attached ERC20 token
        require(_gtxAuctionContract.ERC20() == address(this), "Auction contract does not have this token assigned");

        gtxAuctionContract = _gtxAuctionContract;
        emit SetAuctionAddress(_gtxAuctionContract);
        return true;
    }

    /**
    * @dev Function to set the TimeLock contract address
    * @return True if the operation was successful.
    */
    function setTimeLockAddress(TimeLock _timeLockContract) public onlyOwner returns (bool) {
        require(_timeLockContract != address(0), "Must provide a TimeLock address");
        // check that this GTX ERC20 deployment is the TimeLock contract's attached ERC20 token
        require(_timeLockContract.ERC20() == address(this), "TimeLock contract does not have this token assigned");

        timeLockContract = _timeLockContract;
        emit SetTimeLockAddress(_timeLockContract);
        return true;
    }

    /**
    * @dev Function to start the migration period
    * @return True if the operation was successful.
    */
    function startMigration() onlyOwner public returns (bool) {
        require(migrationStart == false, "startMigration has already been run");
        // check that the GTX migration contract address is set
        require(gtxMigrationContract != address(0), "Migration contract address must be set");
        // check that the GTX Auction contract address is set
        require(gtxAuctionContract != address(0), "Auction contract address must be set");
        // check that the TimeLock contract address is set
        require(timeLockContract != address(0), "TimeLock contract address must be set");

        migrationStart = true;
        emit MigrationStarted();

        return true;
    }

    /**
     * @dev Function to pass the Auction Allocation to the Auction Contract Address
     * @dev modifier onlyAuction Permissioned only to the Gallactic Auction Contract Owner
     * @param _auctionAllocation The GTX Auction Allocation Amount (Initial Proposal 400,000,000 tokens)
    */

    function passAuctionAllocation(uint256 _auctionAllocation) public onlyAuction {
        //check GTX Record creation has stopped.
        require(gtxRecord.lockRecords() == true, "GTXRecord contract lock state should be true");

        uint256 gtxRecordTotal = gtxRecord.totalClaimableGTX();
        uint256 gtxPresaleTotal = gtxPresale.totalPresaleTokens();

        totalAllocation = _auctionAllocation.add(gtxRecordTotal).add(gtxPresaleTotal);
        require(totalAllocation <= totalSupply_, "totalAllocation must be less than totalSupply");
        balances[gtxAuctionContract] = totalAllocation;
        emit Transfer(address(0), gtxAuctionContract, totalAllocation);
        uint256 remainingTokens = totalSupply_.sub(totalAllocation);
        balances[owner()] = remainingTokens;
        emit Transfer(address(0), owner(), totalAllocation);
    }

    /**
     * @dev Function to modify the GTX ERC-20 balance in compliance with migration to GTX network tokens on the GALLACTIC Network
     *      - called by the GTX-ERC20-MIGRATE GTXERC20Migrate.sol Migration Contract to record the amount of tokens to be migrated
     * @dev modifier onlyMigrate - Permissioned only to the deployed GTXERC20Migrate.sol Migration Contract
     * @param _account The Ethereum account which holds some GTX ERC20 balance to be migrated to Gallactic
     * @param _amount The amount of GTX ERC20 to be migrated
    */
    function migrateTransfer(address _account, uint256 _amount) onlyMigrate public returns (uint256) {
        require(migrationStart == true);
        uint256 userBalance = balanceOf(_account);
        require(userBalance >= _amount);

        emit Migrated(_account, _amount);
        balances[_account] = balances[_account].sub(_amount);
        return _amount;
    }

    /**
     * @dev Function to get the GTX Record contract address
    */
    function getGTXRecord() public view returns (address) {
        return address(gtxRecord);
    }

    /**
     * @dev Function to get the total auction allocation
    */
    function getAuctionAllocation() public view returns (uint256){
        require(totalAllocation != 0, "Auction allocation has not been set yet");
        return totalAllocation;
    }
}
contract GTXRecord is Ownable {
    using SafeMath for uint256;

    // conversionRate is the multiplier to calculate the number of GTX claimable per FIN Point converted
    // e.g., 100 = 1:1 conversion ratio
    uint256 public conversionRate;

    // a flag for locking record changes, lockRecords is only settable by the owner
    bool public lockRecords;

    // Maximum amount of recorded GTX able to be stored on this contract
    uint256 public maxRecords;

    // Total number of claimable GTX converted from FIN Points
    uint256 public totalClaimableGTX;

    // an address map used to store the per account claimable GTX
    // as a result of converted FIN Points
    mapping (address => uint256) public claimableGTX;

    event GTXRecordCreate(
        address indexed _recordAddress,
        uint256 _finPointAmount,
        uint256 _gtxAmount
    );

    event GTXRecordUpdate(
        address indexed _recordAddress,
        uint256 _finPointAmount,
        uint256 _gtxAmount
    );

    event GTXRecordMove(
        address indexed _oldAddress,
        address indexed _newAddress,
        uint256 _gtxAmount
    );

    event LockRecords();

    /**
     * Throws if conversionRate is not set or if the lockRecords flag has been set to true
    */
    modifier canRecord() {
        require(conversionRate > 0);
        require(!lockRecords);
        _;
    }

    /**
     * @dev GTXRecord constructor
     * @param _maxRecords is the maximum numer of GTX records this contract can store (used for sanity checks on GTX ERC20 totalsupply)
    */
    constructor (uint256 _maxRecords) public {
        maxRecords = _maxRecords;
    }

    /**
     * @dev sets the GTX Conversion rate
     * @param _conversionRate is the rate applied during FIN Point to GTX conversion
    */
    function setConversionRate(uint256 _conversionRate) external onlyOwner{
        require(_conversionRate <= 1000); // maximum 10x conversion rate
        require(_conversionRate > 0); // minimum .01x conversion rate
        conversionRate = _conversionRate;
    }

   /**
    * @dev Function to lock record changes on this contracts
    * @return True if the operation was successful.
    */
    function lock() public onlyOwner returns (bool) {
        lockRecords = true;
        emit LockRecords();
        return true;
    }

    /**
    * @dev Used to calculate and store the amount of claimable GTX for those exsisting FIN point holders
    * who opt to convert FIN points for GTX
    * @param _recordAddress - the registered address where GTX can be claimed from
    * @param _finPointAmount - the amount of FINs to be converted for GTX, this param should always be entered as base units
    * i.e., 1 FIN = 10**18 base units
    * @param _applyConversionRate - flag to apply conversion rate or not, any Finterra Technologies company GTX conversion allocations
    * are strictly covnerted at one to one and do not recive the conversion bonus applied to FIN point user balances
    */
    function recordCreate(address _recordAddress, uint256 _finPointAmount, bool _applyConversionRate) public onlyOwner canRecord {
        require(_finPointAmount >= 100000, "cannot be less than 100000 FIN (in WEI)"); // minimum allowed FIN 0.000000000001 (in base units) to avoid large rounding errors
        uint256 afterConversionGTX;
        if(_applyConversionRate == true) {
            afterConversionGTX = _finPointAmount.mul(conversionRate).div(100);
        } else {
            afterConversionGTX = _finPointAmount;
        }
        claimableGTX[_recordAddress] = claimableGTX[_recordAddress].add(afterConversionGTX);
        totalClaimableGTX = totalClaimableGTX.add(afterConversionGTX);
        require(totalClaimableGTX <= maxRecords, "total token record (contverted GTX) cannot exceed GTXRecord token limit");
        emit GTXRecordCreate(_recordAddress, _finPointAmount, claimableGTX[_recordAddress]);
    }

    /**
    * @dev Used to calculate and update the amount of claimable GTX for those exsisting FIN point holders
    * who opt to convert FIN points for GTX
    * @param _recordAddress - the registered address where GTX can be claimed from
    * @param _finPointAmount - the amount of FINs to be converted for GTX, this param should always be entered as base units
    * i.e., 1 FIN = 10**18 base units
    * @param _applyConversionRate - flag to apply conversion rate or do one for one conversion, any Finterra Technologies company FIN point allocations
    * are strictly converted at one to one and do not recive the cnversion bonus applied to FIN point user balances
    */
    function recordUpdate(address _recordAddress, uint256 _finPointAmount, bool _applyConversionRate) public onlyOwner canRecord {
        require(_finPointAmount >= 100000, "cannot be less than 100000 FIN (in WEI)"); // minimum allowed FIN 0.000000000001 (in base units) to avoid large rounding errors
        uint256 afterConversionGTX;
        totalClaimableGTX = totalClaimableGTX.sub(claimableGTX[_recordAddress]);
        if(_applyConversionRate == true) {
            afterConversionGTX  = _finPointAmount.mul(conversionRate).div(100);
        } else {
            afterConversionGTX  = _finPointAmount;
        }
        claimableGTX[_recordAddress] = afterConversionGTX;
        totalClaimableGTX = totalClaimableGTX.add(claimableGTX[_recordAddress]);
        require(totalClaimableGTX <= maxRecords, "total token record (contverted GTX) cannot exceed GTXRecord token limit");
        emit GTXRecordUpdate(_recordAddress, _finPointAmount, claimableGTX[_recordAddress]);
    }

    /**
    * @dev Used to move GTX records from one address to another, primarily in case a user has lost access to their originally registered account
    * @param _oldAddress - the original registered address
    * @param _newAddress - the new registerd address
    */
    function recordMove(address _oldAddress, address _newAddress) public onlyOwner canRecord {
        require(claimableGTX[_oldAddress] != 0, "cannot move a zero record");
        require(claimableGTX[_newAddress] == 0, "destination must not already have a claimable record");

        claimableGTX[_newAddress] = claimableGTX[_oldAddress];
        claimableGTX[_oldAddress] = 0;

        emit GTXRecordMove(_oldAddress, _newAddress, claimableGTX[_newAddress]);
    }

}
contract GTXPresale is Ownable {
    using SafeMath for uint256;

    // a flag for locking record changes, lockRecords is only settable by the owner
    bool public lockRecords;

    // Total GTX allocated for presale
    uint256 public totalPresaleTokens;

    // Total Claimable GTX which is the Amount of GTX sold during presale
    uint256 public totalClaimableGTX;

    // an address map used to store the per account claimable GTX and their bonus
    mapping (address => uint256) public presaleGTX;
    mapping (address => uint256) public bonusGTX;
    mapping (address => uint256) public claimableGTX;

    // Bonus Arrays for presale amount based Bonus calculation
    uint256[11] public bonusPercent; // 11 possible bonus percentages (with values 0 - 100 each)
    uint256[11] public bonusThreshold; // 11 thresholds values to calculate bonus based on the presale tokens (in cents).

    // Enums for Stages
    Stages public stage;

    /*
     *  Enums
     */
    enum Stages {
        PresaleDeployed,
        Presale,
        ClaimingStarted
    }

    /*
     *  Modifiers
     */
    modifier atStage(Stages _stage) {
        require(stage == _stage, "function not allowed at current stage");
        _;
    }

    event Setup(
        uint256 _maxPresaleTokens,
        uint256[] _bonusThreshold,
        uint256[] _bonusPercent
    );

    event GTXRecordCreate(
        address indexed _recordAddress,
        uint256 _gtxTokens
    );

    event GTXRecordUpdate(
        address indexed _recordAddress,
        uint256 _gtxTokens
    );

    event GTXRecordMove(
        address indexed _oldAddress,
        address indexed _newAddress,
        uint256 _gtxTokens
    );

    event LockRecords();

    constructor() public{
        stage = Stages.PresaleDeployed;
    }

   /**
    * @dev Function to lock record changes on this contract
    * @return True if the operation was successful.
    */
    function lock() public onlyOwner returns (bool) {
        lockRecords = true;
        stage = Stages.ClaimingStarted;
        emit LockRecords();
        return true;
    }

    /**
     * @dev setup function sets up the bonus percent and bonus thresholds for MD module tokens
     * @param _maxPresaleTokens is the maximum tokens allocated for presale
     * @param _bonusThreshold is an array of thresholds of GTX Tokens in dollars to calculate bonus%
     * @param _bonusPercent is an array of bonus% from 0-100
    */
    function setup(uint256 _maxPresaleTokens, uint256[] _bonusThreshold, uint256[] _bonusPercent) external onlyOwner atStage(Stages.PresaleDeployed) {
        require(_bonusPercent.length == _bonusThreshold.length, "Length of bonus percent array and bonus threshold should be equal");
        totalPresaleTokens =_maxPresaleTokens;
        for(uint256 i=0; i< _bonusThreshold.length; i++) {
            bonusThreshold[i] = _bonusThreshold[i];
            bonusPercent[i] = _bonusPercent[i];
        }
        stage = Stages.Presale; //Once the inital parameters are set the Presale Record Creation can be started
        emit Setup(_maxPresaleTokens,_bonusThreshold,_bonusPercent);
    }

    /**
    * @dev Used to store the amount of Presale GTX tokens for those who purchased Tokens during the presale
    * @param _recordAddress - the registered address where GTX can be claimed from
    * @param _gtxTokens - the amount of presale GTX tokens, this param should always be entered as Boson (base units)
    * i.e., 1 GTX = 10**18 Boson
    */
    function recordCreate(address _recordAddress, uint256 _gtxTokens) public onlyOwner atStage(Stages.Presale) {
        // minimum allowed GTX 0.000000000001 (in Boson) to avoid large rounding errors
        require(_gtxTokens >= 100000, "Minimum allowed GTX tokens is 100000 Bosons");
        totalClaimableGTX = totalClaimableGTX.sub(claimableGTX[_recordAddress]);
        presaleGTX[_recordAddress] = presaleGTX[_recordAddress].add(_gtxTokens);
        bonusGTX[_recordAddress] = calculateBonus(_recordAddress);
        claimableGTX[_recordAddress] = presaleGTX[_recordAddress].add(bonusGTX[_recordAddress]);

        totalClaimableGTX = totalClaimableGTX.add(claimableGTX[_recordAddress]);
        require(totalClaimableGTX <= totalPresaleTokens, "total token record (presale GTX + bonus GTX) cannot exceed presale token limit");
        emit GTXRecordCreate(_recordAddress, claimableGTX[_recordAddress]);
    }


    /**
    * @dev Used to calculate and update the amount of claimable GTX for those who purchased Tokens during the presale
    * @param _recordAddress - the registered address where GTX can be claimed from
    * @param _gtxTokens - the amount of presale GTX tokens, this param should always be entered as Boson (base units)
    * i.e., 1 GTX = 10**18 Boson
    */
    function recordUpdate(address _recordAddress, uint256 _gtxTokens) public onlyOwner atStage(Stages.Presale){
        // minimum allowed GTX 0.000000000001 (in Boson) to avoid large rounding errors
        require(_gtxTokens >= 100000, "Minimum allowed GTX tokens is 100000 Bosons");
        totalClaimableGTX = totalClaimableGTX.sub(claimableGTX[_recordAddress]);
        presaleGTX[_recordAddress] = _gtxTokens;
        bonusGTX[_recordAddress] = calculateBonus(_recordAddress);
        claimableGTX[_recordAddress] = presaleGTX[_recordAddress].add(bonusGTX[_recordAddress]);
        
        totalClaimableGTX = totalClaimableGTX.add(claimableGTX[_recordAddress]);
        require(totalClaimableGTX <= totalPresaleTokens, "total token record (presale GTX + bonus GTX) cannot exceed presale token limit");
        emit GTXRecordUpdate(_recordAddress, claimableGTX[_recordAddress]);
    }

    /**
    * @dev Used to move GTX records from one address to another, primarily in case a user has lost access to their originally registered account
    * @param _oldAddress - the original registered address
    * @param _newAddress - the new registerd address
    */
    function recordMove(address _oldAddress, address _newAddress) public onlyOwner atStage(Stages.Presale){
        require(claimableGTX[_oldAddress] != 0, "cannot move a zero record");
        require(claimableGTX[_newAddress] == 0, "destination must not already have a claimable record");

        //Moving the Presale GTX
        presaleGTX[_newAddress] = presaleGTX[_oldAddress];
        presaleGTX[_oldAddress] = 0;

        //Moving the Bonus GTX
        bonusGTX[_newAddress] = bonusGTX[_oldAddress];
        bonusGTX[_oldAddress] = 0;

        //Moving the claimable GTX
        claimableGTX[_newAddress] = claimableGTX[_oldAddress];
        claimableGTX[_oldAddress] = 0;

        emit GTXRecordMove(_oldAddress, _newAddress, claimableGTX[_newAddress]);
    }


    /**
     * @dev calculates the bonus percentage based on the total number of GTX tokens
     * @param _receiver is the registered address for which bonus is calculated
     * @return returns the calculated bonus tokens
    */
    function calculateBonus(address _receiver) public view returns(uint256 bonus) {
        uint256 gtxTokens = presaleGTX[_receiver];
        for(uint256 i=0; i < bonusThreshold.length; i++) {
            if(gtxTokens >= bonusThreshold[i]) {
                bonus = (bonusPercent[i].mul(gtxTokens)).div(100);
            }
        }
        return bonus;
    }

    /**
    * @dev Used to retrieve the total GTX tokens for GTX claiming after the GTX ICO
    * @return uint256 - Presale stage
    */
    function getStage() public view returns (uint256) {
        return uint(stage);
    }

}
contract GTXAuction is Ownable {
    using SafeMath for uint256;

    /*
     *  Events
     */
    event Setup(uint256 etherPrice, uint256 hardCap, uint256 ceiling, uint256 floor, uint256[] bonusThreshold, uint256[] bonusPercent);
    event BidSubmission(address indexed sender, uint256 amount);
    event ClaimedTokens(address indexed recipient, uint256 sentAmount);
    event Collected(address collector, address multiSigAddress, uint256 amount);
    event SetMultiSigAddress(address owner, address multiSigAddress);

    /*
     *  Storage
     */
    // GTX Contract objects required to allocate GTX Tokens and FIN converted GTX Tokens
    GTXToken public ERC20;
    GTXRecord public gtxRecord;
    GTXPresale public gtxPresale;

    // Auction specific uint256 Bid variables
    uint256 public maxTokens; // the maximum number of tokens for distribution during the auction
    uint256 public remainingCap; // Remaining amount in wei to reach the hardcap target
    uint256 public totalReceived; // Keep track of total ETH in Wei received during the bidding phase
    uint256 public maxTotalClaim; // a running total of the maximum possible tokens that can be claimed by bidder (including bonuses)
    uint256 public totalAuctionTokens; // Total tokens for the accumulated bid amount and the bonus
    uint256 public fundsClaimed;  // Keep track of cumulative ETH funds for which the tokens have been claimed

    // Auction specific uint256 Time variables
    uint256 public startBlock; // the number of the block when the auction bidding period was started
    uint256 public biddingPeriod; // the number of blocks for the bidding period of the auction
    uint256 public endBlock; // the last possible block of the bidding period
    uint256 public waitingPeriod; // the number of days of the cooldown/audit period after the bidding phase has ended

    // Auction specific uint256 Price variables
    uint256 public etherPrice; // 2 decimal precision, e.g., $1.00 = 100
    uint256 public ceiling; // entered as a paremeter in USD cents; calculated as the equivalent "ceiling" value in ETH - given the etherPrice
    uint256 public floor; // entered as a paremeter in USD cents; calculated as the equivalent "floor" value in ETH - given the etherPrice
    uint256 public hardCap; // entered as a paremeter in USD cents; calculated as the equivalent "hardCap" value in ETH - given the etherPrice
    uint256 public priceConstant; // price calculation factor to generate the price curve per block
    uint256 public finalPrice; // the final Bid Price achieved
    uint256 constant public WEI_FACTOR = 10**18; // wei conversion factor
    
    //generic variables
    uint256 public participants; 
    address public multiSigAddress; // a multisignature contract address to keep the auction funds

    // Auction maps to calculate Bids and Bonuses
    mapping (address => uint256) public bids; // total bids in wei per account
    mapping (address => uint256) public bidTokens; // tokens calculated for the submitted bids
    mapping (address => uint256) public totalTokens; // total tokens is the accumulated tokens of bidTokens, presaleTokens, gtxrecordTokens and bonusTokens
    mapping (address => bool) public claimedStatus; // claimedStatus is the claimed status of the user

    // Map of whitelisted address for participation in the Auction
    mapping (address => bool) public whitelist;

    // Auction arrays for bid amount based Bonus calculation
    uint256[11] public bonusPercent; // 11 possible bonus percentages (with values 0 - 100 each)
    uint256[11] public bonusThresholdWei; // 11 thresholds values to calculate bonus based on the bid amount in wei.

    // Enums for Stages
    Stages public stage;

    /*
     *  Enums
     */
    enum Stages {
        AuctionDeployed,
        AuctionSetUp,
        AuctionStarted,
        AuctionEnded,
        ClaimingStarted,
        ClaimingEnded
    }

    /*
     *  Modifiers
     */
    modifier atStage(Stages _stage) {
        require(stage == _stage, "not the expected stage");
        _;
    }

    modifier timedTransitions() {
        if (stage == Stages.AuctionStarted && block.number >= endBlock) {
            finalizeAuction();
            msg.sender.transfer(msg.value);
            return;
        }
        if (stage == Stages.AuctionEnded && block.number >= endBlock.add(waitingPeriod)) {
            stage = Stages.ClaimingStarted;
        }
        _;
    }

    modifier onlyWhitelisted(address _participant) {
        require(whitelist[_participant] == true, "account is not white listed");
        _;
    }

    /// GTXAuction Contract Constructor
    /// @dev Constructor sets the basic auction information
    /// @param _gtxToken the GTX ERC20 token contract address
    /// @param _gtxRecord the GTX Record contract address
    /// @param _gtxPresale the GTX presale contract address
    /// @param _biddingPeriod the number of blocks the bidding period of the auction will run - Initial decision of 524160 (~91 Days)
    /// @param _waitingPeriod the waiting period post Auction End before claiming - Initial decision of 172800 (-30 days)


    constructor (
        GTXToken _gtxToken,
        GTXRecord _gtxRecord,
        GTXPresale _gtxPresale,
        uint256 _biddingPeriod,
        uint256 _waitingPeriod
    )
       public
    {
        require(_gtxToken != address(0), "Must provide a Token address");
        require(_gtxRecord != address(0), "Must provide a Record address");
        require(_gtxPresale != address(0), "Must provide a PreSale address");
        require(_biddingPeriod > 0, "The bidding period must be a minimum 1 block");
        require(_waitingPeriod > 0, "The waiting period must be a minimum 1 block");

        ERC20 = _gtxToken;
        gtxRecord = _gtxRecord;
        gtxPresale = _gtxPresale;
        waitingPeriod = _waitingPeriod;
        biddingPeriod = _biddingPeriod;

        uint256 gtxSwapTokens = gtxRecord.maxRecords();
        uint256 gtxPresaleTokens = gtxPresale.totalPresaleTokens();
        maxTotalClaim = maxTotalClaim.add(gtxSwapTokens).add(gtxPresaleTokens);

        // Set the contract stage to Auction Deployed
        stage = Stages.AuctionDeployed;
    }

    // fallback to revert ETH sent to this contract
    function () public payable {
        bid(msg.sender);
    }

    /**
    * @dev Safety function for reclaiming ERC20 tokens
    * @param _token address of the ERC20 contract
    */
    function recoverTokens(ERC20Interface _token) external onlyOwner {
        if(address(_token) == address(ERC20)) {
            require(uint(stage) >= 3, "auction bidding must be ended to recover");
            if(currentStage() == 3 || currentStage() == 4) {
                _token.transfer(owner(), _token.balanceOf(address(this)).sub(maxTotalClaim));
            } else {
                _token.transfer(owner(), _token.balanceOf(address(this)));
            }
        } else {
            _token.transfer(owner(), _token.balanceOf(address(this)));
        }
    }

    ///  @dev Function to whitelist participants during the crowdsale
    ///  @param _bidder_addresses Array of addresses to whitelist
    function addToWhitelist(address[] _bidder_addresses) external onlyOwner {
        for (uint32 i = 0; i < _bidder_addresses.length; i++) {
            if(_bidder_addresses[i] != address(0) && whitelist[_bidder_addresses[i]] == false){
                whitelist[_bidder_addresses[i]] = true;
            }
        }
    }

    ///  @dev Function to remove the whitelististed participants
    ///  @param _bidder_addresses is an array of accounts to remove form the whitelist
    function removeFromWhitelist(address[] _bidder_addresses) external onlyOwner {
        for (uint32 i = 0; i < _bidder_addresses.length; i++) {
            if(_bidder_addresses[i] != address(0) && whitelist[_bidder_addresses[i]] == true){
                whitelist[_bidder_addresses[i]] = false;
            }
        }
    }

    /// @dev Setup function sets eth pricing information and the floor and ceiling of the Dutch auction bid pricing
    /// @param _maxTokens the maximum public allocation of tokens - Initial decision for 400 Million GTX Tokens to be allocated for ICO
    /// @param _etherPrice for calculating Gallactic Auction price curve - Should be set 1 week before the auction starts, denominated in USD cents
    /// @param _hardCap Gallactic Auction maximum accepted total contribution - Initial decision to be $100,000,000.00 or 10000000000 (USD cents)
    /// @param _ceiling Gallactic Auction Price curve ceiling price - Initial decision to be 500 (USD cents)
    /// @param _floor Gallactic Auction Price curve floor price - Initial decision to be 30 (USD cents)
    /// @param _bonusThreshold is an array of thresholds for the bid amount to set the bonus% (thresholds entered in USD cents, converted to ETH equivalent based on ETH price)
    /// @param _bonusPercent is an array of bonus% based on the threshold of bid

    function setup(
        uint256 _maxTokens,
        uint256 _etherPrice,
        uint256 _hardCap,
        uint256 _ceiling,
        uint256 _floor,
        uint256[] _bonusThreshold,
        uint256[] _bonusPercent
    )
        external
        onlyOwner
        atStage(Stages.AuctionDeployed)
        returns (bool)
    {
        require(_maxTokens > 0,"Max Tokens should be > 0");
        require(_etherPrice > 0,"Ether price should be > 0");
        require(_hardCap > 0,"Hard Cap should be > 0");
        require(_floor < _ceiling,"Floor must be strictly less than the ceiling");
        require(_bonusPercent.length == 11 && _bonusThreshold.length == 11, "Length of bonus percent array and bonus threshold should be 11");

        maxTokens = _maxTokens;
        etherPrice = _etherPrice;

        // Allocate Crowdsale token amounts (Permissible only to this GTXAuction Contract)
        // Address needs to be set in GTXToken before Auction Setup)
        ERC20.passAuctionAllocation(maxTokens);

        // Validate allocation amount
        require(ERC20.balanceOf(address(this)) == ERC20.getAuctionAllocation(), "Incorrect balance assigned by auction allocation");

        // ceiling, floor, hardcap and bonusThreshholds in Wei and priceConstant setting
        ceiling = _ceiling.mul(WEI_FACTOR).div(_etherPrice); // result in WEI
        floor = _floor.mul(WEI_FACTOR).div(_etherPrice); // result in WEI
        hardCap = _hardCap.mul(WEI_FACTOR).div(_etherPrice); // result in WEI
        for (uint32 i = 0; i<_bonusPercent.length; i++) {
            bonusPercent[i] = _bonusPercent[i];
            bonusThresholdWei[i] = _bonusThreshold[i].mul(WEI_FACTOR).div(_etherPrice);
        }
        remainingCap = hardCap.sub(remainingCap);
        // used for the bidding price curve
        priceConstant = (biddingPeriod**3).div((biddingPeriod.add(1).mul(ceiling).div(floor)).sub(biddingPeriod.add(1)));

        // Initializing Auction Setup Stage
        stage = Stages.AuctionSetUp;
        emit Setup(_etherPrice,_hardCap,_ceiling,_floor,_bonusThreshold,_bonusPercent);
    }

    /// @dev Changes auction price curve variables before auction is started.
    /// @param _etherPrice New Ether Price in Cents.
    /// @param _hardCap New hardcap amount in Cents.
    /// @param _ceiling New auction ceiling price in Cents.
    /// @param _floor New auction floor price in Cents.
    /// @param _bonusThreshold is an array of thresholds for the bid amount to set the bonus%
    /// @param _bonusPercent is an array of bonus% based on the threshold of bid

    function changeSettings(
        uint256 _etherPrice,
        uint256 _hardCap,
        uint256 _ceiling,
        uint256 _floor,
        uint256[] _bonusThreshold,
        uint256[] _bonusPercent
    )
        external
        onlyOwner
        atStage(Stages.AuctionSetUp)
    {
        require(_etherPrice > 0,"Ether price should be > 0");
        require(_hardCap > 0,"Hard Cap should be > 0");
        require(_floor < _ceiling,"floor must be strictly less than the ceiling");
        require(_bonusPercent.length == _bonusThreshold.length, "Length of bonus percent array and bonus threshold should be equal");
        etherPrice = _etherPrice;
        ceiling = _ceiling.mul(WEI_FACTOR).div(_etherPrice); // recalculate ceiling, result in WEI
        floor = _floor.mul(WEI_FACTOR).div(_etherPrice); // recalculate floor, result in WEI
        hardCap = _hardCap.mul(WEI_FACTOR).div(_etherPrice); // recalculate hardCap, result in WEI
        for (uint i = 0 ; i<_bonusPercent.length; i++) {
            bonusPercent[i] = _bonusPercent[i];
            bonusThresholdWei[i] = _bonusThreshold[i].mul(WEI_FACTOR).div(_etherPrice);
        }
        remainingCap = hardCap.sub(remainingCap);
        // recalculate price constant
        priceConstant = (biddingPeriod**3).div((biddingPeriod.add(1).mul(ceiling).div(floor)).sub(biddingPeriod.add(1)));
        emit Setup(_etherPrice,_hardCap,_ceiling,_floor,_bonusThreshold,_bonusPercent);
    }

    /// @dev Starts auction and sets startBlock and endBlock.
    function startAuction()
        public
        onlyOwner
        atStage(Stages.AuctionSetUp)
    {
        // set the stage to Auction Started and bonus stage to First Stage
        stage = Stages.AuctionStarted;
        startBlock = block.number;
        endBlock = startBlock.add(biddingPeriod);
    }

    /// @dev Implements a moratorium on claiming so that company can eventually recover all remaining tokens (in case of lost accounts who can/will never claim) - any remaining claims must contact the company directly
    function endClaim()
        public
        onlyOwner
        atStage(Stages.ClaimingStarted)
    {
        require(block.number >= endBlock.add(biddingPeriod), "Owner can end claim only after 3 months");   //Owner can force end the claim only after 3 months. This is to protect the owner from ending the claim before users could claim
        // set the stage to Claiming Ended
        stage = Stages.ClaimingEnded;
    }

    /// @dev setup multisignature address to keep the funds safe
    /// @param _multiSigAddress is the multisignature contract address
    /// @return true if the address was set successfully  
    function setMultiSigAddress(address _multiSigAddress) external onlyOwner returns(bool){
        require(_multiSigAddress != address(0), "not a valid multisignature address");
        multiSigAddress = _multiSigAddress;
        emit SetMultiSigAddress(msg.sender,multiSigAddress);
        return true;
    }

    // Owner can collect ETH any number of times
    function collect() external onlyOwner returns (bool) {
        require(multiSigAddress != address(0), "multisignature address is not set");
        multiSigAddress.transfer(address(this).balance);
        emit Collected(msg.sender, multiSigAddress, address(this).balance);
        return true;
    }

    /// @dev Allows to send a bid to the auction.
    /// @param _receiver Bid will be assigned to this address if set.
    function bid(address _receiver)
        public
        payable
        timedTransitions
        atStage(Stages.AuctionStarted)
    {
        require(msg.value > 0, "bid must be larger than 0");
        require(block.number <= endBlock ,"Auction has ended");
        if (_receiver == 0x0) {
            _receiver = msg.sender;
        }
        assert(bids[_receiver].add(msg.value) >= msg.value);

        uint256 maxWei = hardCap.sub(totalReceived); // remaining accetable funds without the current bid value
        require(msg.value <= maxWei, "Hardcap limit will be exceeded");
        participants = participants.add(1);
        bids[_receiver] = bids[_receiver].add(msg.value);

        uint256 maxAcctClaim = bids[_receiver].mul(WEI_FACTOR).div(calcTokenPrice(endBlock)); // max claimable tokens given bids total amount
        maxAcctClaim = maxAcctClaim.add(bonusPercent[10].mul(maxAcctClaim).div(100)); // max claimable tokens (including bonus)
        maxTotalClaim = maxTotalClaim.add(maxAcctClaim); // running total of max claim liability

        totalReceived = totalReceived.add(msg.value);

        remainingCap = hardCap.sub(totalReceived);
        if(remainingCap == 0){
            finalizeAuction(); // When maxWei is equal to the hardcap the auction will end and finalizeAuction is triggered.
        }
        assert(totalReceived >= msg.value);
        emit BidSubmission(_receiver, msg.value);
    }

    /// @dev Claims tokens for bidder after auction.
    function claimTokens()
        public
        timedTransitions
        onlyWhitelisted(msg.sender)
        atStage(Stages.ClaimingStarted)
    {
        require(!claimedStatus[msg.sender], "User already claimed");
        // validate that GTXRecord contract has been locked - set to true
        require(gtxRecord.lockRecords(), "gtx records record updating must be locked");
        // validate that GTXPresale contract has been locked - set to true
        require(gtxPresale.lockRecords(), "presale record updating must be locked");

        // Update the total amount of ETH funds for which tokens have been claimed
        fundsClaimed = fundsClaimed.add(bids[msg.sender]);

        //total tokens accumulated for an user
        uint256 accumulatedTokens = calculateTokens(msg.sender);

        // Set receiver bid to 0 before assigning tokens
        bids[msg.sender] = 0;
        totalTokens[msg.sender] = 0;

        claimedStatus[msg.sender] = true;
        require(ERC20.transfer(msg.sender, accumulatedTokens), "transfer failed");

        emit ClaimedTokens(msg.sender, accumulatedTokens);
        assert(bids[msg.sender] == 0);
    }

    /// @dev calculateTokens calculates the sum of GTXRecord Tokens, Presale Tokens, BidTokens and Bonus Tokens
    /// @param _receiver is the address of the receiver to calculate the tokens.
    function calculateTokens(address _receiver) private returns(uint256){
        // Check for GTX Record Tokens
        uint256 gtxRecordTokens = gtxRecord.claimableGTX(_receiver);

        // Check for Presale Record Tokens
        uint256 gtxPresaleTokens = gtxPresale.claimableGTX(_receiver);

        //Calculate the total bid tokens
        bidTokens[_receiver] = bids[_receiver].mul(WEI_FACTOR).div(finalPrice);

        //Calculate the total bonus tokens for the bids
        uint256 bonusTokens = calculateBonus(_receiver);

        uint256 auctionTokens = bidTokens[_receiver].add(bonusTokens);

        totalAuctionTokens = totalAuctionTokens.add(auctionTokens);

        //Sum all the tokens accumulated
        totalTokens[msg.sender] = gtxRecordTokens.add(gtxPresaleTokens).add(auctionTokens);
        return totalTokens[msg.sender];
    }

    /// @dev Finalize the Auction and set the final token price
    /// no more bids allowed
    function finalizeAuction()
        private
    {
        // remainingFunds should be 0 at this point
        require(remainingCap == 0 || block.number >= endBlock, "cap or block condition not met");

        stage = Stages.AuctionEnded;
        if (block.number < endBlock){
            finalPrice = calcTokenPrice(block.number);
            endBlock = block.number;
        } else {
            finalPrice = calcTokenPrice(endBlock);
        }
    }

    /// @dev calculates the bonus for the total bids
    /// @param _receiver is the address of the bidder to calculate the bonus
    /// @return returns the calculated bonus tokens
    function calculateBonus(address _receiver) private view returns(uint256 bonusTokens){
        for (uint256 i=0; i < bonusThresholdWei.length; i++) {
            if(bids[_receiver] >= bonusThresholdWei[i]){
                bonusTokens = bonusPercent[i].mul(bidTokens[_receiver]).div(100); // bonusAmount is calculated in wei
            }
        }
        return bonusTokens;
    }

    // public getters
    /// @dev Calculates the token price (WEI per GTX) at the given block number
    /// @param _bidBlock is the block number
    /// @return Returns the token price - Wei per GTX
    function calcTokenPrice(uint256 _bidBlock) public view returns(uint256){

        require(_bidBlock >= startBlock && _bidBlock <= endBlock, "pricing only given in the range of startBlock and endBlock");

        uint256 currentBlock = _bidBlock.sub(startBlock);
        uint256 decay = (currentBlock ** 3).div(priceConstant);
        return ceiling.mul(currentBlock.add(1)).div(currentBlock.add(decay).add(1));
    }

    /// @dev Returns correct stage, even if a function with a timedTransitions modifier has not been called yet
    /// @return Returns current auction stage.
    function currentStage()
        public
        view
        returns (uint)
    {
        return uint(stage);
    }

}