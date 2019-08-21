pragma solidity ^0.4.13;

interface MigrationAgent {
  function migrateFrom(address _from, uint256 _value);
}

contract PoolAllocations {

  // ERC20 basic token contract being held
  ERC20Basic public token;

 // allocations map
  mapping (address => lockEntry) public allocations;

  // lock entry
  struct lockEntry {
      uint256 totalAmount;        // total amount of token for a user
      uint256 firstReleaseAmount; // amount to be released 
      uint256 nextRelease;        // amount to be released every month
      uint256 restOfTokens;       // the rest of tokens if not divisible
      bool isFirstRelease;        // just flag
      uint numPayoutCycles;       // only after 3 years
  }

  // max number of payout cycles
  uint public maxNumOfPayoutCycles;

  // first release date
  uint public startDay;

  // defines how many of cycles should be released immediately
  uint public cyclesStartFrom = 1;

  uint public payoutCycleInDays;

  function PoolAllocations(ERC20Basic _token) public {
    token = _token;
  }

  /**
   * @dev claims tokens held by time lock
   */
  function claim() public {
    require(now >= startDay);

     var elem = allocations[msg.sender];
    require(elem.numPayoutCycles > 0);

    uint256 tokens = 0;
    uint cycles = getPayoutCycles(elem.numPayoutCycles);

    if (elem.isFirstRelease) {
      elem.isFirstRelease = false;
      tokens += elem.firstReleaseAmount;
      tokens += elem.restOfTokens;
    } else {
      require(cycles > 0);
    }

    tokens += elem.nextRelease * cycles;

    elem.numPayoutCycles -= cycles;

    assert(token.transfer(msg.sender, tokens));
  }

  function getPayoutCycles(uint payoutCyclesLeft) private constant returns (uint) {
    uint cycles = uint((now - startDay) / payoutCycleInDays) + cyclesStartFrom;

    if (cycles > maxNumOfPayoutCycles) {
       cycles = maxNumOfPayoutCycles;
    }

    return cycles - (maxNumOfPayoutCycles - payoutCyclesLeft);
  }

  function createAllocationEntry(uint256 total, uint256 first, uint256 next, uint256 rest) internal returns(lockEntry) {
    return lockEntry(total, // total
                     first, // first
                     next,  // next
                     rest,  // rest
                     true,  //isFirstRelease
                     maxNumOfPayoutCycles); //payoutCyclesLeft
  }
}

contract PoolBLock is PoolAllocations {

  uint256 public constant totalAmount = 911567810300063801255851777;

  function PoolBLock(ERC20Basic _token) PoolAllocations(_token) {

    // setup policy
    maxNumOfPayoutCycles = 5; // 20% * 5 = 100%
    startDay = now;
    cyclesStartFrom = 1; // the first payout cycles is released immediately
    payoutCycleInDays = 180 days; // 20% of tokens will be released every 6 months

    // allocations
    allocations[0x2f09079059b85c11DdA29ed62FF26F99b7469950] = createAllocationEntry(182313562060012760251170355, 0, 36462712412002552050234071, 0);
    allocations[0x3634acA3cf97dCC40584dB02d53E290b5b4b65FA] = createAllocationEntry(182313562060012760251170355, 0, 36462712412002552050234071, 0);
    allocations[0x768D9F044b9c8350b041897f08cA77AE871AeF1C] = createAllocationEntry(182313562060012760251170355, 0, 36462712412002552050234071, 0);
    allocations[0xb96De72d3fee8c7B6c096Ddeab93bf0b3De848c4] = createAllocationEntry(182313562060012760251170355, 0, 36462712412002552050234071, 0);
    allocations[0x2f97bfD7a479857a9028339Ce2426Fc3C62D96Bd] = createAllocationEntry(182313562060012760251170357, 0, 36462712412002552050234071, 2);
  }
}

contract PoolCLock is PoolAllocations {

  uint256 public constant totalAmount = 911567810300063801255851777;

  function PoolCLock(ERC20Basic _token) PoolAllocations(_token) {
    
    // setup policy
    maxNumOfPayoutCycles = 5; // 20% * 5 = 100%
    startDay = now;
    cyclesStartFrom = 1; // the first payout cycles is released immediately
    payoutCycleInDays = 180 days; // 20% of tokens will be released every 6 months

    // allocations
    allocations[0x0d02A3365dFd745f76225A0119fdD148955f821E] = createAllocationEntry(182313562060012760251170355, 0, 36462712412002552050234071, 0);
    allocations[0x0deF4A4De337771c22Ac8C8D4b9C5Fec496841A5] = createAllocationEntry(182313562060012760251170355, 0, 36462712412002552050234071, 0);
    allocations[0x467600367BdBA1d852dbd8C1661a5E6a2Be5F6C8] = createAllocationEntry(182313562060012760251170355, 0, 36462712412002552050234071, 0);
    allocations[0x92E01739142386E4820eC8ddC3AFfF69de99641a] = createAllocationEntry(182313562060012760251170355, 0, 36462712412002552050234071, 0);
    allocations[0x1E0a7E0706373d0b76752448ED33cA1E4070753A] = createAllocationEntry(182313562060012760251170357, 0, 36462712412002552050234071, 2);
  }
}

contract PoolDLock is PoolAllocations {

  uint256 public constant totalAmount = 546940686180038280753511066;

  function PoolDLock(ERC20Basic _token) PoolAllocations(_token) {
    
    // setup policy
    maxNumOfPayoutCycles = 36; // total * .5 / 36
    startDay = now + 3 years;  // first release date
    cyclesStartFrom = 0;
    payoutCycleInDays = 30 days; // 1/36 of tokens will be released every month

    // allocations
    allocations[0x4311F6F65B411f546c7DD8841A344614297Dbf62] = createAllocationEntry(
      182313562060012760251170355, // total
      91156781030006380125585177,  // first release
      2532132806389066114599588,   // next release
      10                           // the rest
    );
     allocations[0x3b52Ab408cd499A1456af83AC095fCa23C014e0d] = createAllocationEntry(
      182313562060012760251170355, // total
      91156781030006380125585177,  // first release
      2532132806389066114599588,   // next release
      10                           // the rest
    );
     allocations[0x728D5312FbbdFBcC1b9582E619f6ceB6412B98E4] = createAllocationEntry(
      182313562060012760251170356, // total
      91156781030006380125585177,  // first release
      2532132806389066114599588,   // next release
      11                           // the rest
    );
  }
}

contract Pausable {
  event Pause();
  event Unpause();

  bool public paused = false;
  address public owner;

  function Pausable(address _owner) {
    owner = _owner;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS paused
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev modifier to allow actions only when the contract IS NOT paused
   */
  modifier whenPaused {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused returns (bool) {
    paused = true;
    Pause();
    return true;
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused returns (bool) {
    paused = false;
    Unpause();
    return true;
  }
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
   * @dev Fix for the ERC20 short address attack.
   */
  modifier onlyPayloadSize(uint numwords) {
      assert(msg.data.length == numwords * 32 + 4);
      _;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) onlyPayloadSize(2) returns (bool) {
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
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) onlyPayloadSize(2) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

contract BlockvToken is StandardToken, Pausable {

  string public constant name = "BLOCKv Token"; // Set the token name for display
  string public constant symbol = "VEE";        // Set the token symbol for display
  uint8  public constant decimals = 18;         // Set the number of decimals for display

  PoolBLock public poolBLock;
  PoolCLock public poolCLock;
  PoolDLock public poolDLock;

  uint256 public constant totalAmountOfTokens = 3646271241200255205023407108;
  uint256 public constant amountOfTokensPoolA = 1276194934420089321758192488;
  uint256 public constant amountOfTokensPoolB = 911567810300063801255851777;
  uint256 public constant amountOfTokensPoolC = 911567810300063801255851777;
  uint256 public constant amountOfTokensPoolD = 546940686180038280753511066;

  // migration
  address public migrationMaster;
  address public migrationAgent;
  uint256 public totalMigrated;
  event Migrate(address indexed _from, address indexed _to, uint256 _value);

  /**
   * @dev BlockvToken Constructor
   * Runs only on initial contract creation.
   */
  function BlockvToken(address _migrationMaster) Pausable(_migrationMaster) {
    require(_migrationMaster != 0);
    migrationMaster = _migrationMaster;

    totalSupply = totalAmountOfTokens; // Set the total supply

    balances[msg.sender] = amountOfTokensPoolA;
    Transfer(0x0, msg.sender, amountOfTokensPoolA);
  
    // time-locked tokens
    poolBLock = new PoolBLock(this);
    poolCLock = new PoolCLock(this);
    poolDLock = new PoolDLock(this);

    balances[poolBLock] = amountOfTokensPoolB;
    balances[poolCLock] = amountOfTokensPoolC;
    balances[poolDLock] = amountOfTokensPoolD;

    Transfer(0x0, poolBLock, amountOfTokensPoolB);
    Transfer(0x0, poolCLock, amountOfTokensPoolC);
    Transfer(0x0, poolDLock, amountOfTokensPoolD);
  }

  /**
   * @dev Transfer token for a specified address when not paused
   * @param _to The address to transfer to.
   * @param _value The amount to be transferred.
   */
  function transfer(address _to, uint256 _value) whenNotPaused returns (bool) {
    require(_to != address(0));
    require(_to != address(this));
    return super.transfer(_to, _value);
  }

  /**
   * @dev Transfer tokens from one address to another when not paused
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) whenNotPaused returns (bool) {
    require(_to != address(0));
    require(_from != _to);
    require(_to != address(this));
    return super.transferFrom(_from, _to, _value);
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender when not paused.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) whenNotPaused returns (bool) {
    require(_spender != address(0));
    require(_spender != address(this));
    return super.approve(_spender, _value);
  }

  /**
  * Token migration support:
  */

  /** 
  * @notice Migrate tokens to the new token contract.
  * @dev Required state: Operational Migration
  * @param _value The amount of token to be migrated
  */
  function migrate(uint256 _value) external {
    require(migrationAgent != 0);
    require(_value != 0);
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    totalSupply = totalSupply.sub(_value);
    totalMigrated = totalMigrated.add(_value);
    MigrationAgent(migrationAgent).migrateFrom(msg.sender, _value);
    
    Migrate(msg.sender, migrationAgent, _value);
  }

  /**
  * @dev Set address of migration target contract and enable migration process.
  * @param _agent The address of the MigrationAgent contract
  */
  function setMigrationAgent(address _agent) external {
    require(_agent != 0);
    require(migrationAgent == 0);
    require(msg.sender == migrationMaster);

    migrationAgent = _agent;
  }

  function setMigrationMaster(address _master) external {
    require(_master != 0);
    require(msg.sender == migrationMaster);

    migrationMaster = _master;
  }
}