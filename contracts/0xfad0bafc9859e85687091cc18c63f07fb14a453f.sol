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
contract Ownable {
  address private _owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    _owner = msg.sender;
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
    emit OwnershipRenounced(_owner);
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
contract FINPointRecord is Ownable {
    using SafeMath for uint256;

    // claimRate is the multiplier to calculate the number of FIN ERC20 claimable per FIN points reorded
    // e.g., 100 = 1:1 claim ratio
    // this claim rate can be seen as a kind of airdrop for exsisting FIN point holders at the time of claiming
    uint256 public claimRate;

    // an address map used to store the per account claimable FIN ERC20 record
    // as a result of swapped FIN points
    mapping (address => uint256) public claimableFIN;

    event FINRecordCreate(
        address indexed _recordAddress,
        uint256 _finPointAmount,
        uint256 _finERC20Amount
    );

    event FINRecordUpdate(
        address indexed _recordAddress,
        uint256 _finPointAmount,
        uint256 _finERC20Amount
    );

    event FINRecordMove(
        address indexed _oldAddress,
        address indexed _newAddress,
        uint256 _finERC20Amount
    );

    event ClaimRateSet(uint256 _claimRate);

    /**
     * Throws if claim rate is not set
    */
    modifier canRecord() {
        require(claimRate > 0);
        _;
    }
    /**
     * @dev sets the claim rate for FIN ERC20
     * @param _claimRate is the claim rate applied during record creation
    */
    function setClaimRate(uint256 _claimRate) public onlyOwner{
        require(_claimRate <= 1000); // maximum 10x migration rate
        require(_claimRate >= 100); // minimum 1x migration rate
        claimRate = _claimRate;
        emit ClaimRateSet(claimRate);
    }

    /**
    * @dev Used to calculate and store the amount of claimable FIN ERC20 from existing FIN point balances
    * @param _recordAddress - the registered address assigned to FIN ERC20 claiming
    * @param _finPointAmount - the original amount of FIN points to be moved, this param should always be entered as base units
    * i.e., 1 FIN = 10**18 base units
    * @param _applyClaimRate - flag to apply the claim rate or not, any Finterra Technologies company FIN point allocations
    * are strictly moved at one to one and do not recive the claim (airdrop) bonus applied to FIN point user balances
    */
    function recordCreate(address _recordAddress, uint256 _finPointAmount, bool _applyClaimRate) public onlyOwner canRecord {
        require(_finPointAmount >= 100000); // minimum allowed FIN 0.000000000001 (in base units) to avoid large rounding errors

        uint256 finERC20Amount;

        if(_applyClaimRate == true) {
            finERC20Amount = _finPointAmount.mul(claimRate).div(100);
        } else {
            finERC20Amount = _finPointAmount;
        }

        claimableFIN[_recordAddress] = claimableFIN[_recordAddress].add(finERC20Amount);

        emit FINRecordCreate(_recordAddress, _finPointAmount, claimableFIN[_recordAddress]);
    }

    /**
    * @dev Used to calculate and update the amount of claimable FIN ERC20 from existing FIN point balances
    * @param _recordAddress - the registered address assigned to FIN ERC20 claiming
    * @param _finPointAmount - the original amount of FIN points to be migrated, this param should always be entered as base units
    * i.e., 1 FIN = 10**18 base units
    * @param _applyClaimRate - flag to apply claim rate or not, any Finterra Technologies company FIN point allocations
    * are strictly migrated at one to one and do not recive the claim (airdrop) bonus applied to FIN point user balances
    */
    function recordUpdate(address _recordAddress, uint256 _finPointAmount, bool _applyClaimRate) public onlyOwner canRecord {
        require(_finPointAmount >= 100000); // minimum allowed FIN 0.000000000001 (in base units) to avoid large rounding errors

        uint256 finERC20Amount;

        if(_applyClaimRate == true) {
            finERC20Amount = _finPointAmount.mul(claimRate).div(100);
        } else {
            finERC20Amount = _finPointAmount;
        }

        claimableFIN[_recordAddress] = finERC20Amount;

        emit FINRecordUpdate(_recordAddress, _finPointAmount, claimableFIN[_recordAddress]);
    }

    /**
    * @dev Used to move FIN ERC20 records from one address to another, primarily in case a user has lost access to their originally registered account
    * @param _oldAddress - the original registered address
    * @param _newAddress - the new registerd address
    */
    function recordMove(address _oldAddress, address _newAddress) public onlyOwner canRecord {
        require(claimableFIN[_oldAddress] != 0);
        require(claimableFIN[_newAddress] == 0);

        claimableFIN[_newAddress] = claimableFIN[_oldAddress];
        claimableFIN[_oldAddress] = 0;

        emit FINRecordMove(_oldAddress, _newAddress, claimableFIN[_newAddress]);
    }

    /**
    * @dev Used to retrieve the FIN ERC20 migration records for an address, for FIN ERC20 claiming
    * @param _recordAddress - the registered address where FIN ERC20 tokens can be claimed
    * @return uint256 - the amount of recorded FIN ERC20 after FIN point migration
    */
    function recordGet(address _recordAddress) public view returns (uint256) {
        return claimableFIN[_recordAddress];
    }

    // cannot send ETH to this contract
    function () public payable {
        revert (); 
    }  

}
contract Claimable is Ownable {
    // FINPointRecord var definition
    FINPointRecord public finPointRecordContract;

    // an address map used to store the mintAllowed flag, so we do not mint more than once
    mapping (address => bool) public isMinted;

    event RecordSourceTransferred(
        address indexed previousRecordContract,
        address indexed newRecordContract
    );


    /**
    * @dev The Claimable constructor sets the original `claimable record contract` to the provided _claimContract
    * address.
    */
    constructor(FINPointRecord _finPointRecordContract) public {
        finPointRecordContract = _finPointRecordContract;
    }


    /**
    * @dev Allows to change the record information source contract.
    * @param _newRecordContract The address of the new record contract
    */
    function transferRecordSource(FINPointRecord _newRecordContract) public onlyOwner {
        _transferRecordSource(_newRecordContract);
    }

    /**
    * @dev Transfers the reference of the record contract to a newRecordContract.
    * @param _newRecordContract The address of the new record contract
    */
    function _transferRecordSource(FINPointRecord _newRecordContract) internal {
        require(_newRecordContract != address(0));
        emit RecordSourceTransferred(finPointRecordContract, _newRecordContract);
        finPointRecordContract = _newRecordContract;
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
    event Approval(address indexed owner,address indexed spender,uint256 value);

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
    // var for storing the the TimeLock contract deployment address (for vesting FIN allocations)
    TimeLock public timeLockContract;

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
contract TimeLock {
    //FINERC20 var definition
    MintableToken public ERC20Contract;
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
    * @dev Constructor in which we pass the ERC20Contract address for reference and method calls
    */

    constructor(MintableToken _ERC20Contract) public {
        ERC20Contract = _ERC20Contract;
    }

    function timeLockTokens(uint256 _lockTimeS) public {

        uint256 lockAmount = ERC20Contract.allowance(msg.sender, this); // get this time lock contract's approved amount of tokens


        require(lockAmount != 0); // check that this time lock contract has been approved to lock an amount of tokens on the msg.sender's behalf

        if (accounts[msg.sender].balance > 0) { // if locked balance already exists, add new amount to the old balance and retain the same release time
            accounts[msg.sender].balance = SafeMath.add(accounts[msg.sender].balance, lockAmount);
      } else { // else populate the balance and set the release time for the newly locked balance
            accounts[msg.sender].balance = lockAmount;
            accounts[msg.sender].releaseTime = SafeMath.add(block.timestamp, _lockTimeS);
        }

        emit Lock(msg.sender, lockAmount, accounts[msg.sender].releaseTime);

        ERC20Contract.transferFrom(msg.sender, this, lockAmount);

    }

    function tokenRelease() public {
        // check if user has funds due for pay out because lock time is over
        require (accounts[msg.sender].balance != 0 && accounts[msg.sender].releaseTime <= block.timestamp);
        uint256 transferUnlockedBalance = accounts[msg.sender].balance;
        accounts[msg.sender].balance = 0;
        accounts[msg.sender].releaseTime = 0;
        emit UnLock(msg.sender, transferUnlockedBalance, block.timestamp);
        ERC20Contract.transfer(msg.sender, transferUnlockedBalance);
    }

    /**
    * @dev Used to retrieve FIN ERC20 contract address that this deployment is attatched to
    * @return address - the FIN ERC20 contract address that this deployment is attatched to
    */
    function getERC20() public view returns (address) {
        return ERC20Contract;
    }
}
contract FINERC20Migrate is Ownable {
    using SafeMath for uint256;

    // Address map used to store the per account migratable FIN balances
    // as per the account's FIN ERC20 tokens on the Ethereum Network

    mapping (address => uint256) public migratableFIN;
    
    MintableToken public ERC20Contract;

    constructor(MintableToken _finErc20) public {
        ERC20Contract = _finErc20;
    }   

    // Note: _totalMigratableFIN is a running total of FIN claimed as migratable in this contract, 
    // but does not represent the actual amount of FIN migrated to the Gallactic network
    event FINMigrateRecordUpdate(
        address indexed _account,
        uint256 _totalMigratableFIN
    ); 

    /**
    * @dev Used to calculate and store the amount of FIN ERC20 token balances to be migrated to the Gallactic network
    * 
    * @param _balanceToMigrate - the requested balance to reserve for migration (in most cases this should be the account's total balance)
    *    - primarily included as a parameter for simple validation on the Gallactic side of the migration
    */
    function initiateMigration(uint256 _balanceToMigrate) public {
        uint256 migratable = ERC20Contract.migrateTransfer(msg.sender, _balanceToMigrate);
        migratableFIN[msg.sender] = migratableFIN[msg.sender].add(migratable);
        emit FINMigrateRecordUpdate(msg.sender, migratableFIN[msg.sender]);
    }

    /**
    * @dev Used to retrieve the FIN ERC20 total migration records for an Etheruem account
    * @param _account - the account to be checked for a migratable balance
    * @return uint256 - the running total amount of migratable FIN ERC20 tokens
    */
    function getFINMigrationRecord(address _account) public view returns (uint256) {
        return migratableFIN[_account];
    }

    /**
    * @dev Used to retrieve FIN ERC20 contract address that this deployment is attatched to
    * @return address - the FIN ERC20 contract address that this deployment is attatched to
    */
    function getERC20() public view returns (address) {
        return ERC20Contract;
    }
}
contract MintableToken is StandardToken, Claimable {
    event Mint(address indexed to, uint256 amount);
    event MintFinished();
    event SetMigrationAddress(address _finERC20MigrateAddress);
    event SetTimeLockAddress(address _timeLockAddress);
    event MigrationStarted();
    event Migrated(address indexed account, uint256 amount);

    bool public mintingFinished = false;

    // var for storing the the FINERC20Migrate contract deployment address (for migration to the GALLACTIC network)
    FINERC20Migrate public finERC20MigrationContract;

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /**
     * @dev Modifier allowing only the set FINERC20Migrate.sol deployment to call a function
    */
    modifier onlyMigrate {
        require(msg.sender == address(finERC20MigrationContract));
        _;
    }

    /**
    * @dev Constructor to pass the finPointMigrationContract address to the Claimable constructor
    */
    constructor(FINPointRecord _finPointRecordContract, string _name, string _symbol, uint8 _decimals)

    public
    Claimable(_finPointRecordContract)
    StandardToken(_name, _symbol, _decimals) {

    }

   // fallback to prevent send ETH to this contract
    function () public payable {
        revert (); 
    }  

    /**
    * @dev Allows addresses with FIN migration records to claim thier ERC20 FIN tokens. This is the only way minting can occur.
    * @param _ethAddress address for the token holder
    */
    function mintAllowance(address _ethAddress) public onlyOwner {
        require(finPointRecordContract.recordGet(_ethAddress) != 0);
        require(isMinted[_ethAddress] == false);
        isMinted[_ethAddress] = true;
        mint(msg.sender, finPointRecordContract.recordGet(_ethAddress));
        approve(_ethAddress, finPointRecordContract.recordGet(_ethAddress));
    }

    /**
    * @dev Function to mint tokens
    * @param _to The address that will receive the minted tokens.
    * @param _amount The amount of tokens to mint.
    * @return A boolean that indicates if the operation was successful.
    */
    function mint(
        address _to,
        uint256 _amount
    )
        private
        canMint
        returns (bool)
    {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    /**
    * @dev Function to stop all minting of new tokens.
    * @return True if the operation was successful.
    */
    function finishMinting() public onlyOwner canMint returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }

   /**
    * @dev Function to set the migration contract address
    * @return True if the operation was successful.
    */
    function setMigrationAddress(FINERC20Migrate _finERC20MigrationContract) public onlyOwner returns (bool) {
        // check that this FIN ERC20 deployment is the migration contract's attached ERC20 token
        require(_finERC20MigrationContract.getERC20() == address(this));

        finERC20MigrationContract = _finERC20MigrationContract;
        emit SetMigrationAddress(_finERC20MigrationContract);
        return true;
    }

   /**
    * @dev Function to set the TimeLock contract address
    * @return True if the operation was successful.
    */
    function setTimeLockAddress(TimeLock _timeLockContract) public onlyOwner returns (bool) {
        // check that this FIN ERC20 deployment is the timelock contract's attached ERC20 token
        require(_timeLockContract.getERC20() == address(this));

        timeLockContract = _timeLockContract;
        emit SetTimeLockAddress(_timeLockContract);
        return true;
    }

   /**
    * @dev Function to start the migration period
    * @return True if the operation was successful.
    */
    function startMigration() onlyOwner public returns (bool) {
        require(migrationStart == false);
        // check that the FIN migration contract address is set
        require(finERC20MigrationContract != address(0));
        // // check that the TimeLock contract address is set
        require(timeLockContract != address(0));

        migrationStart = true;
        emit MigrationStarted();

        return true;
    }

    /**
     * @dev Function to modify the FIN ERC-20 balance in compliance with migration to FIN ERC-777 on the GALLACTIC Network
     *      - called by the FIN-ERC20-MIGRATE FINERC20Migrate.sol Migration Contract to record the amount of tokens to be migrated
     * @dev modifier onlyMigrate - Permissioned only to the deployed FINERC20Migrate.sol Migration Contract
     * @param _account The Ethereum account which holds some FIN ERC20 balance to be migrated to Gallactic
     * @param _amount The amount of FIN ERC20 to be migrated
    */
    function migrateTransfer(address _account, uint256 _amount) onlyMigrate public returns (uint256) {

        require(migrationStart == true);

        uint256 userBalance = balanceOf(_account);
        require(userBalance >= _amount);

        emit Migrated(_account, _amount);

        balances[_account] = balances[_account].sub(_amount);

        return _amount;
    }

}