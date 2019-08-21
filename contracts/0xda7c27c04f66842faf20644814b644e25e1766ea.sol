pragma solidity ^0.4.11;

contract Ownable {
  // replace with proper zeppelin smart contract
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender != owner)
      throw;
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0))
      owner = newOwner;
  }
}


contract Destructable is Ownable {
  function selfdestruct() external onlyOwner {
    // free ethereum network state when done
    selfdestruct(owner);
  }
}


contract Math {
  // scale of the emulated fixed point operations
  uint constant public FP_SCALE = 10000;

  // todo: should be a library
  function divRound(uint v, uint d) internal constant returns(uint) {
    // round up if % is half or more
    return (v + (d/2)) / d;
  }

  function absDiff(uint v1, uint v2) public constant returns(uint) {
    return v1 > v2 ? v1 - v2 : v2 - v1;
  }

  function safeMul(uint a, uint b) public constant returns (uint) {
    uint c = a * b;
    if (a == 0 || c / a == b)
      return c;
    else
      throw;
  }

  function safeAdd(uint a, uint b) internal constant returns (uint) {
    uint c = a + b;
    if (!(c>=a && c>=b))
      throw;
    return c;
  }
}


contract TimeSource {
  uint32 private mockNow;

  function currentTime() public constant returns (uint32) {
    // we do not support dates much into future (Sun, 07 Feb 2106 06:28:15 GMT)
    if (block.timestamp > 0xFFFFFFFF)
      throw;
    return mockNow > 0 ? mockNow : uint32(block.timestamp);
  }

  function mockTime(uint32 t) public {
    // no mocking on mainnet
    if (block.number > 3316029)
      throw;
    mockNow = t;
  }
}


contract BaseOptionsConverter {

  // modifiers are inherited, check `owned` pattern
  //   http://solidity.readthedocs.io/en/develop/contracts.html#function-modifiers
  modifier onlyESOP() {
    if (msg.sender != getESOP())
      throw;
    _;
  }

  // returns ESOP address which is a sole executor of exerciseOptions function
  function getESOP() public constant returns (address);
  // deadline for employees to exercise options
  function getExercisePeriodDeadline() public constant returns (uint32);

  // exercise of options for given employee and amount, please note that employee address may be 0
  // .. in which case the intention is to burn options
  function exerciseOptions(address employee, uint poolOptions, uint extraOptions, uint bonusOptions,
    bool agreeToAcceleratedVestingBonusConditions) onlyESOP public;
}

contract ESOPTypes {
  // enums are numbered starting from 0. NotSet is used to check for non existing mapping
  enum EmployeeState { NotSet, WaitingForSignature, Employed, Terminated, OptionsExercised }
  // please note that 32 bit unsigned int is used to represent UNIX time which is enough to represent dates until Sun, 07 Feb 2106 06:28:15 GMT
  // storage access is optimized so struct layout is important
  struct Employee {
      // when vesting starts
      uint32 issueDate;
      // wait for employee signature until that time
      uint32 timeToSign;
      // date when employee was terminated, 0 for not terminated
      uint32 terminatedAt;
      // when fade out starts, 0 for not set, initally == terminatedAt
      // used only when calculating options returned to pool
      uint32 fadeoutStarts;
      // poolOptions employee gets (exit bonus not included)
      uint32 poolOptions;
      // extra options employee gets (neufund will not this option)
      uint32 extraOptions;
      // time at which employee got suspended, 0 - not suspended
      uint32 suspendedAt;
      // what is employee current status, takes 8 bit in storage
      EmployeeState state;
      // index in iterable mapping
      uint16 idx;
      // reserve until full 256 bit word
      //uint24 reserved;
  }

  function serializeEmployee(Employee memory employee)
    internal
    constant
    returns(uint[9] emp)
  {
      // guess what: struct layout in memory is aligned to word (256 bits)
      // struct in storage is byte aligned
      assembly {
        // return memory aligned struct as array of words
        // I just wonder when 'employee' memory is deallocated
        // answer: memory is not deallocated until transaction ends
        emp := employee
      }
  }

  function deserializeEmployee(uint[9] serializedEmployee)
    internal
    constant
    returns (Employee memory emp)
  {
      assembly { emp := serializedEmployee }
  }
}


contract CodeUpdateable is Ownable {
    // allows to stop operations and migrate data to different contract
    enum CodeUpdateState { CurrentCode, OngoingUpdate /*, CodeUpdated*/}
    CodeUpdateState public codeUpdateState;

    modifier isCurrentCode() {
      if (codeUpdateState != CodeUpdateState.CurrentCode)
        throw;
      _;
    }

    modifier inCodeUpdate() {
      if (codeUpdateState != CodeUpdateState.OngoingUpdate)
        throw;
      _;
    }

    function beginCodeUpdate() public onlyOwner isCurrentCode {
      codeUpdateState = CodeUpdateState.OngoingUpdate;
    }

    function cancelCodeUpdate() public onlyOwner inCodeUpdate {
      codeUpdateState = CodeUpdateState.CurrentCode;
    }

    function completeCodeUpdate() public onlyOwner inCodeUpdate {
      selfdestruct(owner);
    }
}

contract EmployeesList is ESOPTypes, Ownable, Destructable {
  event CreateEmployee(address indexed e, uint32 poolOptions, uint32 extraOptions, uint16 idx);
  event UpdateEmployee(address indexed e, uint32 poolOptions, uint32 extraOptions, uint16 idx);
  event ChangeEmployeeState(address indexed e, EmployeeState oldState, EmployeeState newState);
  event RemoveEmployee(address indexed e);
  mapping (address => Employee) employees;
  // addresses in the mapping, ever
  address[] public addresses;

  function size() external constant returns (uint16) {
    return uint16(addresses.length);
  }

  function setEmployee(address e, uint32 issueDate, uint32 timeToSign, uint32 terminatedAt, uint32 fadeoutStarts,
    uint32 poolOptions, uint32 extraOptions, uint32 suspendedAt, EmployeeState state)
    external
    onlyOwner
    returns (bool isNew)
  {
    uint16 empIdx = employees[e].idx;
    if (empIdx == 0) {
      // new element
      uint size = addresses.length;
      if (size == 0xFFFF)
        throw;
      isNew = true;
      empIdx = uint16(size + 1);
      addresses.push(e);
      CreateEmployee(e, poolOptions, extraOptions, empIdx);
    } else {
      isNew = false;
      UpdateEmployee(e, poolOptions, extraOptions, empIdx);
    }
    employees[e] = Employee({
        issueDate: issueDate,
        timeToSign: timeToSign,
        terminatedAt: terminatedAt,
        fadeoutStarts: fadeoutStarts,
        poolOptions: poolOptions,
        extraOptions: extraOptions,
        suspendedAt: suspendedAt,
        state: state,
        idx: empIdx
      });
  }

  function changeState(address e, EmployeeState state)
    external
    onlyOwner
  {
    if (employees[e].idx == 0)
      throw;
    ChangeEmployeeState(e, employees[e].state, state);
    employees[e].state = state;
  }

  function setFadeoutStarts(address e, uint32 fadeoutStarts)
    external
    onlyOwner
  {
    if (employees[e].idx == 0)
      throw;
    UpdateEmployee(e, employees[e].poolOptions, employees[e].extraOptions, employees[e].idx);
    employees[e].fadeoutStarts = fadeoutStarts;
  }

  function removeEmployee(address e)
    external
    onlyOwner
    returns (bool)
  {
    uint16 empIdx = employees[e].idx;
    if (empIdx > 0) {
        delete employees[e];
        delete addresses[empIdx-1];
        RemoveEmployee(e);
        return true;
    }
    return false;
  }

  function terminateEmployee(address e, uint32 issueDate, uint32 terminatedAt, uint32 fadeoutStarts, EmployeeState state)
    external
    onlyOwner
  {
    if (state != EmployeeState.Terminated)
        throw;
    Employee employee = employees[e]; // gets reference to storage and optimizer does it with one SSTORE
    if (employee.idx == 0)
      throw;
    ChangeEmployeeState(e, employee.state, state);
    employee.state = state;
    employee.issueDate = issueDate;
    employee.terminatedAt = terminatedAt;
    employee.fadeoutStarts = fadeoutStarts;
    employee.suspendedAt = 0;
    UpdateEmployee(e, employee.poolOptions, employee.extraOptions, employee.idx);
  }

  function getEmployee(address e)
    external
    constant
    returns (uint32, uint32, uint32, uint32, uint32, uint32, uint32, EmployeeState)
  {
      Employee employee = employees[e];
      if (employee.idx == 0)
        throw;
      // where is struct zip/unzip :>
      return (employee.issueDate, employee.timeToSign, employee.terminatedAt, employee.fadeoutStarts,
        employee.poolOptions, employee.extraOptions, employee.suspendedAt, employee.state);
  }

   function hasEmployee(address e)
     external
     constant
     returns (bool)
   {
      // this is very inefficient - whole word is loaded just to check this
      return employees[e].idx != 0;
    }

  function getSerializedEmployee(address e)
    external
    constant
    returns (uint[9])
  {
    Employee memory employee = employees[e];
    if (employee.idx == 0)
      throw;
    return serializeEmployee(employee);
  }
}


contract ERC20OptionsConverter is BaseOptionsConverter, TimeSource, Math {
  // see base class for explanations
  address esopAddress;
  uint32 exercisePeriodDeadline;
  // balances for converted options
  mapping(address => uint) internal balances;
  // total supply
  uint public totalSupply;

  // deadline for all options conversion including company's actions
  uint32 public optionsConversionDeadline;

  event Transfer(address indexed from, address indexed to, uint value);

  modifier converting() {
    // throw after deadline
    if (currentTime() >= exercisePeriodDeadline)
      throw;
    _;
  }

  modifier converted() {
    // throw before deadline
    if (currentTime() < optionsConversionDeadline)
      throw;
    _;
  }


  function getESOP() public constant returns (address) {
    return esopAddress;
  }

  function getExercisePeriodDeadline() public constant returns(uint32) {
    return exercisePeriodDeadline;
  }

  function exerciseOptions(address employee, uint poolOptions, uint extraOptions, uint bonusOptions,
    bool agreeToAcceleratedVestingBonusConditions)
    public
    onlyESOP
    converting
  {
    // if no overflow on totalSupply, no overflows later
    uint options = safeAdd(safeAdd(poolOptions, extraOptions), bonusOptions);
    totalSupply = safeAdd(totalSupply, options);
    balances[employee] += options;
    Transfer(0, employee, options);
  }

  function transfer(address _to, uint _value) converted public {
    if (balances[msg.sender] < _value)
      throw;
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    Transfer(msg.sender, _to, _value);
  }

  function balanceOf(address _owner) constant public returns (uint balance) {
    return balances[_owner];
  }

  function () payable {
    throw;
  }

  function ERC20OptionsConverter(address esop, uint32 exerciseDeadline, uint32 conversionDeadline) {
    esopAddress = esop;
    exercisePeriodDeadline = exerciseDeadline;
    optionsConversionDeadline = conversionDeadline;
  }
}

contract ESOPMigration {
  modifier onlyOldESOP() {
    if (msg.sender != getOldESOP())
      throw;
    _;
  }

  // returns ESOP address which is a sole executor of exerciseOptions function
  function getOldESOP() public constant returns (address);

  // migrate employee to new ESOP contract, throws if not possible
  // in simplest case new ESOP contract should derive from this contract and implement abstract methods
  // employees list is available for inspection by employee address
  // poolOptions and extraOption is amount of options transferred out of old ESOP contract
  function migrate(address employee, uint poolOptions, uint extraOptions) onlyOldESOP public;
}

contract ESOP is ESOPTypes, CodeUpdateable, TimeSource {
  // employee changed events
  event ESOPOffered(address indexed employee, address company, uint32 poolOptions, uint32 extraOptions);
  event EmployeeSignedToESOP(address indexed employee);
  event SuspendEmployee(address indexed employee, uint32 suspendedAt);
  event ContinueSuspendedEmployee(address indexed employee, uint32 continuedAt, uint32 suspendedPeriod);
  event TerminateEmployee(address indexed employee, address company, uint32 terminatedAt, TerminationType termType);
  event EmployeeOptionsExercised(address indexed employee, address exercisedFor, uint32 poolOptions, bool disableAcceleratedVesting);
  event EmployeeMigrated(address indexed employee, address migration, uint pool, uint extra);
  // esop changed events
  event ESOPOpened(address company);
  event OptionsConversionOffered(address company, address converter, uint32 convertedAt, uint32 exercisePeriodDeadline);
  enum ESOPState { New, Open, Conversion }
  // use retrun codes until revert opcode is implemented
  enum ReturnCodes { OK, InvalidEmployeeState, TooLate, InvalidParameters, TooEarly  }
  // event raised when return code from a function is not OK, when OK is returned one of events above is raised
  event ReturnCode(ReturnCodes rc);
  enum TerminationType { Regular, BadLeaver }

  //CONFIG
  OptionsCalculator public optionsCalculator;
  // total poolOptions in The Pool
  uint public totalPoolOptions;
  // ipfs hash of document establishing this ESOP
  bytes public ESOPLegalWrapperIPFSHash;
  // company address
  address public companyAddress;
  // root of immutable root of trust pointing to given ESOP implementation
  address public rootOfTrust;
  // default period for employee signature
  uint32 constant public MINIMUM_MANUAL_SIGN_PERIOD = 2 weeks;

  // STATE
  // poolOptions that remain to be assigned
  uint public remainingPoolOptions;
  // state of ESOP
  ESOPState public esopState; // automatically sets to Open (0)
  // list of employees
  EmployeesList public employees;
  // how many extra options inserted
  uint public totalExtraOptions;
  // when conversion event happened
  uint32 public conversionOfferedAt;
  // employee conversion deadline
  uint32 public exerciseOptionsDeadline;
  // option conversion proxy
  BaseOptionsConverter public optionsConverter;

  // migration destinations per employee
  mapping (address => ESOPMigration) private migrations;

  modifier hasEmployee(address e) {
    // will throw on unknown address
    if (!employees.hasEmployee(e))
      throw;
    _;
  }

  modifier onlyESOPNew() {
    if (esopState != ESOPState.New)
      throw;
    _;
  }

  modifier onlyESOPOpen() {
    if (esopState != ESOPState.Open)
      throw;
    _;
  }

  modifier onlyESOPConversion() {
    if (esopState != ESOPState.Conversion)
      throw;
    _;
  }

  modifier onlyCompany() {
    if (companyAddress != msg.sender)
      throw;
    _;
  }

  function distributeAndReturnToPool(uint distributedOptions, uint idx)
    internal
    returns (uint)
  {
    // enumerate all employees that were offered poolOptions after than fromIdx -1 employee
    Employee memory emp;
    for (uint i = idx; i < employees.size(); i++) {
      address ea = employees.addresses(i);
      if (ea != 0) { // address(0) is deleted employee
        emp = _loademp(ea);
        // skip employees with no poolOptions and terminated employees
        if (emp.poolOptions > 0 && ( emp.state == EmployeeState.WaitingForSignature || emp.state == EmployeeState.Employed) ) {
          uint newoptions = optionsCalculator.calcNewEmployeePoolOptions(distributedOptions);
          emp.poolOptions += uint32(newoptions);
          distributedOptions -= uint32(newoptions);
          _saveemp(ea, emp);
        }
      }
    }
    return distributedOptions;
  }

  function removeEmployeesWithExpiredSignaturesAndReturnFadeout()
    onlyESOPOpen
    isCurrentCode
    public
  {
    // removes employees that didn't sign and sends their poolOptions back to the pool
    // computes fadeout for terminated employees and returns it to pool
    // we let anyone to call that method and spend gas on it
    Employee memory emp;
    uint32 ct = currentTime();
    for (uint i = 0; i < employees.size(); i++) {
      address ea = employees.addresses(i);
      if (ea != 0) { // address(0) is deleted employee
        var ser = employees.getSerializedEmployee(ea);
        emp = deserializeEmployee(ser);
        // remove employees with expired signatures
        if (emp.state == EmployeeState.WaitingForSignature && ct > emp.timeToSign) {
          remainingPoolOptions += distributeAndReturnToPool(emp.poolOptions, i+1);
          totalExtraOptions -= emp.extraOptions;
          // actually this just sets address to 0 so iterator can continue
          employees.removeEmployee(ea);
        }
        // return fadeout to pool
        if (emp.state == EmployeeState.Terminated && ct > emp.fadeoutStarts) {
          var (returnedPoolOptions, returnedExtraOptions) = optionsCalculator.calculateFadeoutToPool(ct, ser);
          if (returnedPoolOptions > 0 || returnedExtraOptions > 0) {
            employees.setFadeoutStarts(ea, ct);
            // options from fadeout are not distributed to other employees but returned to pool
            remainingPoolOptions += returnedPoolOptions;
            // we maintain extraPool for easier statistics
            totalExtraOptions -= returnedExtraOptions;
          }
        }
      }
    }
  }

  function openESOP(uint32 pTotalPoolOptions, bytes pESOPLegalWrapperIPFSHash)
    external
    onlyCompany
    onlyESOPNew
    isCurrentCode
    returns (ReturnCodes)
  {
    // options are stored in unit32
    if (pTotalPoolOptions > 1100000 || pTotalPoolOptions < 10000) {
      return _logerror(ReturnCodes.InvalidParameters);
    }

    totalPoolOptions = pTotalPoolOptions;
    remainingPoolOptions = totalPoolOptions;
    ESOPLegalWrapperIPFSHash = pESOPLegalWrapperIPFSHash;

    esopState = ESOPState.Open;
    ESOPOpened(companyAddress);
    return ReturnCodes.OK;
  }

  function offerOptionsToEmployee(address e, uint32 issueDate, uint32 timeToSign, uint32 extraOptions, bool poolCleanup)
    external
    onlyESOPOpen
    onlyCompany
    isCurrentCode
    returns (ReturnCodes)
  {
    // do not add twice
    if (employees.hasEmployee(e)) {
      return _logerror(ReturnCodes.InvalidEmployeeState);
    }
    if (timeToSign < currentTime() + MINIMUM_MANUAL_SIGN_PERIOD) {
      return _logerror(ReturnCodes.TooLate);
    }
    if (poolCleanup) {
      // recover poolOptions for employees with expired signatures
      // return fade out to pool
      removeEmployeesWithExpiredSignaturesAndReturnFadeout();
    }
    uint poolOptions = optionsCalculator.calcNewEmployeePoolOptions(remainingPoolOptions);
    if (poolOptions > 0xFFFFFFFF)
      throw;
    Employee memory emp = Employee({
      issueDate: issueDate, timeToSign: timeToSign, terminatedAt: 0, fadeoutStarts: 0, poolOptions: uint32(poolOptions),
      extraOptions: extraOptions, suspendedAt: 0, state: EmployeeState.WaitingForSignature, idx: 0
    });
    _saveemp(e, emp);
    remainingPoolOptions -= poolOptions;
    totalExtraOptions += extraOptions;
    ESOPOffered(e, companyAddress, uint32(poolOptions), extraOptions);
    return ReturnCodes.OK;
  }

  // todo: implement group add someday, however func distributeAndReturnToPool gets very complicated
  // todo: function calcNewEmployeePoolOptions(uint remaining, uint8 groupSize)
  // todo: function addNewEmployeesToESOP(address[] emps, uint32 issueDate, uint32 timeToSign)

  function offerOptionsToEmployeeOnlyExtra(address e, uint32 issueDate, uint32 timeToSign, uint32 extraOptions)
    external
    onlyESOPOpen
    onlyCompany
    isCurrentCode
    returns (ReturnCodes)
  {
    // do not add twice
    if (employees.hasEmployee(e)) {
      return _logerror(ReturnCodes.InvalidEmployeeState);
    }
    if (timeToSign < currentTime() + MINIMUM_MANUAL_SIGN_PERIOD) {
      return _logerror(ReturnCodes.TooLate);
    }
    Employee memory emp = Employee({
      issueDate: issueDate, timeToSign: timeToSign, terminatedAt: 0, fadeoutStarts: 0, poolOptions: 0,
      extraOptions: extraOptions, suspendedAt: 0, state: EmployeeState.WaitingForSignature, idx: 0
    });
    _saveemp(e, emp);
    totalExtraOptions += extraOptions;
    ESOPOffered(e, companyAddress, 0, extraOptions);
    return ReturnCodes.OK;
  }

  function increaseEmployeeExtraOptions(address e, uint32 extraOptions)
    external
    onlyESOPOpen
    onlyCompany
    isCurrentCode
    hasEmployee(e)
    returns (ReturnCodes)
  {
    Employee memory emp = _loademp(e);
    if (emp.state != EmployeeState.Employed && emp.state != EmployeeState.WaitingForSignature) {
      return _logerror(ReturnCodes.InvalidEmployeeState);
    }
    emp.extraOptions += extraOptions;
    _saveemp(e, emp);
    totalExtraOptions += extraOptions;
    ESOPOffered(e, companyAddress, 0, extraOptions);
    return ReturnCodes.OK;
  }

  function employeeSignsToESOP()
    external
    hasEmployee(msg.sender)
    onlyESOPOpen
    isCurrentCode
    returns (ReturnCodes)
  {
    Employee memory emp = _loademp(msg.sender);
    if (emp.state != EmployeeState.WaitingForSignature) {
      return _logerror(ReturnCodes.InvalidEmployeeState);
    }
    uint32 t = currentTime();
    if (t > emp.timeToSign) {
      remainingPoolOptions += distributeAndReturnToPool(emp.poolOptions, emp.idx);
      totalExtraOptions -= emp.extraOptions;
      employees.removeEmployee(msg.sender);
      return _logerror(ReturnCodes.TooLate);
    }
    employees.changeState(msg.sender, EmployeeState.Employed);
    EmployeeSignedToESOP(msg.sender);
    return ReturnCodes.OK;
  }

  function toggleEmployeeSuspension(address e, uint32 toggledAt)
    external
    onlyESOPOpen
    onlyCompany
    hasEmployee(e)
    isCurrentCode
    returns (ReturnCodes)
  {
    Employee memory emp = _loademp(e);
    if (emp.state != EmployeeState.Employed) {
      return _logerror(ReturnCodes.InvalidEmployeeState);
    }
    if (emp.suspendedAt == 0) {
      //suspend action
      emp.suspendedAt = toggledAt;
      SuspendEmployee(e, toggledAt);
    } else {
      if (emp.suspendedAt > toggledAt) {
        return _logerror(ReturnCodes.TooLate);
      }
      uint32 suspendedPeriod = toggledAt - emp.suspendedAt;
      // move everything by suspension period by changing issueDate
      emp.issueDate += suspendedPeriod;
      emp.suspendedAt = 0;
      ContinueSuspendedEmployee(e, toggledAt, suspendedPeriod);
    }
    _saveemp(e, emp);
    return ReturnCodes.OK;
  }

  function terminateEmployee(address e, uint32 terminatedAt, uint8 terminationType)
    external
    onlyESOPOpen
    onlyCompany
    hasEmployee(e)
    isCurrentCode
    returns (ReturnCodes)
  {
    // terminates an employee
    TerminationType termType = TerminationType(terminationType);
    Employee memory emp = _loademp(e);
    // todo: check termination time against issueDate
    if (terminatedAt < emp.issueDate) {
      return _logerror(ReturnCodes.InvalidParameters);
    }
    if (emp.state == EmployeeState.WaitingForSignature)
      termType = TerminationType.BadLeaver;
    else if (emp.state != EmployeeState.Employed) {
      return _logerror(ReturnCodes.InvalidEmployeeState);
    }
    // how many poolOptions returned to pool
    uint returnedOptions;
    uint returnedExtraOptions;
    if (termType == TerminationType.Regular) {
      // regular termination, compute suspension
      if (emp.suspendedAt > 0 && emp.suspendedAt < terminatedAt)
        emp.issueDate += terminatedAt - emp.suspendedAt;
      // vesting applies
      returnedOptions = emp.poolOptions - optionsCalculator.calculateVestedOptions(terminatedAt, emp.issueDate, emp.poolOptions);
      returnedExtraOptions = emp.extraOptions - optionsCalculator.calculateVestedOptions(terminatedAt, emp.issueDate, emp.extraOptions);
      employees.terminateEmployee(e, emp.issueDate, terminatedAt, terminatedAt, EmployeeState.Terminated);
    } else if (termType == TerminationType.BadLeaver) {
      // bad leaver - employee is kicked out from ESOP, return all poolOptions
      returnedOptions = emp.poolOptions;
      returnedExtraOptions = emp.extraOptions;
      employees.removeEmployee(e);
    }
    remainingPoolOptions += distributeAndReturnToPool(returnedOptions, emp.idx);
    totalExtraOptions -= returnedExtraOptions;
    TerminateEmployee(e, companyAddress, terminatedAt, termType);
    return ReturnCodes.OK;
  }

  function offerOptionsConversion(BaseOptionsConverter converter)
    external
    onlyESOPOpen
    onlyCompany
    isCurrentCode
    returns (ReturnCodes)
  {
    uint32 offerMadeAt = currentTime();
    if (converter.getExercisePeriodDeadline() - offerMadeAt < MINIMUM_MANUAL_SIGN_PERIOD) {
      return _logerror(ReturnCodes.TooLate);
    }
    // exerciseOptions must be callable by us
    if (converter.getESOP() != address(this)) {
      return _logerror(ReturnCodes.InvalidParameters);
    }
    // return to pool everything we can
    removeEmployeesWithExpiredSignaturesAndReturnFadeout();
    // from now vesting and fadeout stops, no new employees may be added
    conversionOfferedAt = offerMadeAt;
    exerciseOptionsDeadline = converter.getExercisePeriodDeadline();
    optionsConverter = converter;
    // this is very irreversible
    esopState = ESOPState.Conversion;
    OptionsConversionOffered(companyAddress, address(converter), offerMadeAt, exerciseOptionsDeadline);
    return ReturnCodes.OK;
  }

  function exerciseOptionsInternal(uint32 calcAtTime, address employee, address exerciseFor,
    bool disableAcceleratedVesting)
    internal
    returns (ReturnCodes)
  {
    Employee memory emp = _loademp(employee);
    if (emp.state == EmployeeState.OptionsExercised) {
      return _logerror(ReturnCodes.InvalidEmployeeState);
    }
    // if we are burning options then send 0
    if (exerciseFor != address(0)) {
      var (pool, extra, bonus) = optionsCalculator.calculateOptionsComponents(serializeEmployee(emp),
        calcAtTime, conversionOfferedAt, disableAcceleratedVesting);
      }
    // call before options conversion contract to prevent re-entry
    employees.changeState(employee, EmployeeState.OptionsExercised);
    // exercise options in the name of employee and assign those to exerciseFor
    optionsConverter.exerciseOptions(exerciseFor, pool, extra, bonus, !disableAcceleratedVesting);
    EmployeeOptionsExercised(employee, exerciseFor, uint32(pool + extra + bonus), !disableAcceleratedVesting);
    return ReturnCodes.OK;
  }

  function employeeExerciseOptions(bool agreeToAcceleratedVestingBonusConditions)
    external
    onlyESOPConversion
    hasEmployee(msg.sender)
    isCurrentCode
    returns (ReturnCodes)
  {
    uint32 ct = currentTime();
    if (ct > exerciseOptionsDeadline) {
      return _logerror(ReturnCodes.TooLate);
    }
    return exerciseOptionsInternal(ct, msg.sender, msg.sender, !agreeToAcceleratedVestingBonusConditions);
  }

  function employeeDenyExerciseOptions()
    external
    onlyESOPConversion
    hasEmployee(msg.sender)
    isCurrentCode
    returns (ReturnCodes)
  {
    uint32 ct = currentTime();
    if (ct > exerciseOptionsDeadline) {
      return _logerror(ReturnCodes.TooLate);
    }
    // burn the options by sending to 0
    return exerciseOptionsInternal(ct, msg.sender, address(0), true);
  }

  function exerciseExpiredEmployeeOptions(address e, bool disableAcceleratedVesting)
    external
    onlyESOPConversion
    onlyCompany
    hasEmployee(e)
    isCurrentCode
  returns (ReturnCodes)
  {
    // company can convert options for any employee that did not converted (after deadline)
    uint32 ct = currentTime();
    if (ct <= exerciseOptionsDeadline) {
      return _logerror(ReturnCodes.TooEarly);
    }
    return exerciseOptionsInternal(ct, e, companyAddress, disableAcceleratedVesting);
  }

  function allowEmployeeMigration(address employee, ESOPMigration migration)
    external
    onlyESOPOpen
    hasEmployee(employee)
    onlyCompany
    isCurrentCode
    returns (ReturnCodes)
  {
    if (address(migration) == 0)
      throw;
    // only employed and terminated users may migrate
    Employee memory emp = _loademp(employee);
    if (emp.state != EmployeeState.Employed && emp.state != EmployeeState.Terminated) {
      return _logerror(ReturnCodes.InvalidEmployeeState);
    }
    migrations[employee] = migration; // can be cleared with 0 address
    return ReturnCodes.OK;
  }

  function employeeMigratesToNewESOP(ESOPMigration migration)
    external
    onlyESOPOpen
    hasEmployee(msg.sender)
    isCurrentCode
    returns (ReturnCodes)
  {
    // employee may migrate to new ESOP contract with different rules
    // if migration not set up by company then throw
    if (address(migration) == 0 || migrations[msg.sender] != migration)
      throw;
    // first give back what you already own
    removeEmployeesWithExpiredSignaturesAndReturnFadeout();
    // only employed and terminated users may migrate
    Employee memory emp = _loademp(msg.sender);
    if (emp.state != EmployeeState.Employed && emp.state != EmployeeState.Terminated) {
      return _logerror(ReturnCodes.InvalidEmployeeState);
    }
    // with accelerated vesting if possible - take out all possible options
    var (pool, extra, _) = optionsCalculator.calculateOptionsComponents(serializeEmployee(emp), currentTime(), 0, false);
    delete migrations[msg.sender];
    // execute migration procedure
    migration.migrate(msg.sender, pool, extra);
    // extra options are moved to new contract
    totalExtraOptions -= emp.state == EmployeeState.Employed ? emp.extraOptions : extra;
    // pool options are moved to new contract and removed from The Pool
    // please note that separate Pool will manage migrated options and
    // algorithm that returns to pool and distributes will not be used
    totalPoolOptions -= emp.state == EmployeeState.Employed ? emp.poolOptions : pool;
    // gone from current contract
    employees.removeEmployee(msg.sender);
    EmployeeMigrated(msg.sender, migration, pool, extra);
    return ReturnCodes.OK;
  }

  function calcEffectiveOptionsForEmployee(address e, uint32 calcAtTime)
    public
    constant
    hasEmployee(e)
    isCurrentCode
    returns (uint)
  {
    return optionsCalculator.calculateOptions(employees.getSerializedEmployee(e), calcAtTime, conversionOfferedAt, false);
  }

  function _logerror(ReturnCodes c) private returns (ReturnCodes) {
    ReturnCode(c);
    return c;
  }

  function _loademp(address e) private constant returns (Employee memory) {
    return deserializeEmployee(employees.getSerializedEmployee(e));
  }

  function _saveemp(address e, Employee memory emp) private {
    employees.setEmployee(e, emp.issueDate, emp.timeToSign, emp.terminatedAt, emp.fadeoutStarts, emp.poolOptions,
      emp.extraOptions, emp.suspendedAt, emp.state);
  }

  function completeCodeUpdate() public onlyOwner inCodeUpdate {
    employees.transferOwnership(msg.sender);
    CodeUpdateable.completeCodeUpdate();
  }

  function()
      payable
  {
      throw;
  }

  function ESOP(address company, address pRootOfTrust, OptionsCalculator pOptionsCalculator, EmployeesList pEmployeesList) {
    //esopState = ESOPState.New; // thats initial value
    companyAddress = company;
    rootOfTrust = pRootOfTrust;
    employees = pEmployeesList;
    optionsCalculator = pOptionsCalculator;
  }
}




contract OptionsCalculator is Ownable, Destructable, Math, ESOPTypes {
  // cliff duration in seconds
  uint public cliffPeriod;
  // vesting duration in seconds
  uint public vestingPeriod;
  // maximum promille that can fade out
  uint public maxFadeoutPromille;
  // minimal options after fadeout
  function residualAmountPromille() public constant returns(uint) { return FP_SCALE - maxFadeoutPromille; }
  // exit bonus promille
  uint public bonusOptionsPromille;
  // per mille of unassigned poolOptions that new employee gets
  uint public newEmployeePoolPromille;
  // options per share
  uint public optionsPerShare;
  // options strike price
  uint constant public STRIKE_PRICE = 1;
  // company address
  address public companyAddress;
  // checks if calculator i initialized
  function hasParameters() public constant returns(bool) { return optionsPerShare > 0; }

  modifier onlyCompany() {
    if (companyAddress != msg.sender)
      throw;
    _;
  }

  function calcNewEmployeePoolOptions(uint remainingPoolOptions)
    public
    constant
    returns (uint)
  {
    return divRound(remainingPoolOptions * newEmployeePoolPromille, FP_SCALE);
  }

  function calculateVestedOptions(uint t, uint vestingStarts, uint options)
    public
    constant
    returns (uint)
  {
    if (t <= vestingStarts)
      return 0;
    // apply vesting
    uint effectiveTime = t - vestingStarts;
    // if within cliff nothing is due
    if (effectiveTime < cliffPeriod)
      return 0;
    else
      return  effectiveTime < vestingPeriod ? divRound(options * effectiveTime, vestingPeriod) : options;
  }

  function applyFadeoutToOptions(uint32 t, uint32 issueDate, uint32 terminatedAt, uint options, uint vestedOptions)
    public
    constant
    returns (uint)
  {
    if (t < terminatedAt)
      return vestedOptions;
    uint timefromTermination = t - terminatedAt;
    // fadeout duration equals to employment duration
    uint employmentPeriod = terminatedAt - issueDate;
    // minimum value of options at the end of fadeout, it is a % of all employee's options
    uint minFadeValue = divRound(options * (FP_SCALE - maxFadeoutPromille), FP_SCALE);
    // however employee cannot have more than options after fadeout than he was vested at termination
    if (minFadeValue >= vestedOptions)
      return vestedOptions;
    return timefromTermination > employmentPeriod ?
      minFadeValue  :
      (minFadeValue + divRound((vestedOptions - minFadeValue) * (employmentPeriod - timefromTermination), employmentPeriod));
  }

  function calculateOptionsComponents(uint[9] employee, uint32 calcAtTime, uint32 conversionOfferedAt,
    bool disableAcceleratedVesting)
    public
    constant
    returns (uint, uint, uint)
  {
    // returns tuple of (vested pool options, vested extra options, bonus)
    Employee memory emp = deserializeEmployee(employee);
    // no options for converted options or when esop is not singed
    if (emp.state == EmployeeState.OptionsExercised || emp.state == EmployeeState.WaitingForSignature)
      return (0,0,0);
    // no options when esop is being converted and conversion deadline expired
    bool isESOPConverted = conversionOfferedAt > 0 && calcAtTime >= conversionOfferedAt; // this function time-travels
    uint issuedOptions = emp.poolOptions + emp.extraOptions;
    // employee with no options
    if (issuedOptions == 0)
      return (0,0,0);
    // if emp is terminated but we calc options before term, simulate employed again
    if (calcAtTime < emp.terminatedAt && emp.terminatedAt > 0)
      emp.state = EmployeeState.Employed;
    uint vestedOptions = issuedOptions;
    bool accelerateVesting = isESOPConverted && emp.state == EmployeeState.Employed && !disableAcceleratedVesting;
    if (!accelerateVesting) {
      // choose vesting time
      uint32 calcVestingAt = emp.state ==
        // if terminated then vesting calculated at termination
        EmployeeState.Terminated ? emp.terminatedAt :
        // if employee is supended then compute vesting at suspension time
        (emp.suspendedAt > 0 && emp.suspendedAt < calcAtTime ? emp.suspendedAt :
        // if conversion offer then vesting calucated at time the offer was made
        conversionOfferedAt > 0 ? conversionOfferedAt :
        // otherwise use current time
        calcAtTime);
      vestedOptions = calculateVestedOptions(calcVestingAt, emp.issueDate, issuedOptions);
    }
    // calc fadeout for terminated employees
    if (emp.state == EmployeeState.Terminated) {
      // use conversion event time to compute fadeout to stop fadeout on conversion IF not after conversion date
      vestedOptions = applyFadeoutToOptions(isESOPConverted ? conversionOfferedAt : calcAtTime,
        emp.issueDate, emp.terminatedAt, issuedOptions, vestedOptions);
    }
    var (vestedPoolOptions, vestedExtraOptions) = extractVestedOptionsComponents(emp.poolOptions, emp.extraOptions, vestedOptions);
    // if (vestedPoolOptions + vestedExtraOptions != vestedOptions) throw;
    return  (vestedPoolOptions, vestedExtraOptions,
      accelerateVesting ? divRound(vestedPoolOptions*bonusOptionsPromille, FP_SCALE) : 0 );
  }

  function calculateOptions(uint[9] employee, uint32 calcAtTime, uint32 conversionOfferedAt, bool disableAcceleratedVesting)
    public
    constant
    returns (uint)
  {
    var (vestedPoolOptions, vestedExtraOptions, bonus) = calculateOptionsComponents(employee, calcAtTime,
      conversionOfferedAt, disableAcceleratedVesting);
    return vestedPoolOptions + vestedExtraOptions + bonus;
  }

  function extractVestedOptionsComponents(uint issuedPoolOptions, uint issuedExtraOptions, uint vestedOptions)
    public
    constant
    returns (uint, uint)
  {
    // breaks down vested options into pool options and extra options components
    if (issuedExtraOptions == 0)
      return (vestedOptions, 0);
    uint poolOptions = divRound(issuedPoolOptions*vestedOptions, issuedPoolOptions + issuedExtraOptions);
    return (poolOptions, vestedOptions - poolOptions);
  }

  function calculateFadeoutToPool(uint32 t, uint[9] employee)
    public
    constant
    returns (uint, uint)
  {
    Employee memory emp = deserializeEmployee(employee);

    uint vestedOptions = calculateVestedOptions(emp.terminatedAt, emp.issueDate, emp.poolOptions);
    uint returnedPoolOptions = applyFadeoutToOptions(emp.fadeoutStarts, emp.issueDate, emp.terminatedAt, emp.poolOptions, vestedOptions) -
      applyFadeoutToOptions(t, emp.issueDate, emp.terminatedAt, emp.poolOptions, vestedOptions);
    uint vestedExtraOptions = calculateVestedOptions(emp.terminatedAt, emp.issueDate, emp.extraOptions);
    uint returnedExtraOptions = applyFadeoutToOptions(emp.fadeoutStarts, emp.issueDate, emp.terminatedAt, emp.extraOptions, vestedExtraOptions) -
      applyFadeoutToOptions(t, emp.issueDate, emp.terminatedAt, emp.extraOptions, vestedExtraOptions);

    return (returnedPoolOptions, returnedExtraOptions);
  }

  function simulateOptions(uint32 issueDate, uint32 terminatedAt, uint32 poolOptions,
    uint32 extraOptions, uint32 suspendedAt, uint8 employeeState, uint32 calcAtTime)
    public
    constant
    returns (uint)
  {
    Employee memory emp = Employee({issueDate: issueDate, terminatedAt: terminatedAt,
      poolOptions: poolOptions, extraOptions: extraOptions, state: EmployeeState(employeeState),
      timeToSign: issueDate+2 weeks, fadeoutStarts: terminatedAt, suspendedAt: suspendedAt,
      idx:1});
    return calculateOptions(serializeEmployee(emp), calcAtTime, 0, false);
  }

  function setParameters(uint32 pCliffPeriod, uint32 pVestingPeriod, uint32 pResidualAmountPromille,
    uint32 pBonusOptionsPromille, uint32 pNewEmployeePoolPromille, uint32 pOptionsPerShare)
    external
    onlyCompany
  {
    if (pResidualAmountPromille > FP_SCALE || pBonusOptionsPromille > FP_SCALE || pNewEmployeePoolPromille > FP_SCALE
     || pOptionsPerShare == 0)
      throw;
    if (pCliffPeriod > pVestingPeriod)
      throw;
    // initialization cannot be called for a second time
    if (hasParameters())
      throw;
    cliffPeriod = pCliffPeriod;
    vestingPeriod = pVestingPeriod;
    maxFadeoutPromille = FP_SCALE - pResidualAmountPromille;
    bonusOptionsPromille = pBonusOptionsPromille;
    newEmployeePoolPromille = pNewEmployeePoolPromille;
    optionsPerShare = pOptionsPerShare;
  }

  function OptionsCalculator(address pCompanyAddress) {
    companyAddress = pCompanyAddress;
  }
}

contract ProceedsOptionsConverter is Ownable, ERC20OptionsConverter {
  mapping (address => uint) internal withdrawals;
  uint[] internal payouts;

  function makePayout() converted payable onlyOwner public {
    // it does not make sense to distribute less than ether
    if (msg.value < 1 ether)
      throw;
    payouts.push(msg.value);
  }

  function withdraw() converted public returns (uint) {
    // withdraw for msg.sender
    uint balance = balanceOf(msg.sender);
    if (balance == 0)
      return 0;
    uint paymentId = withdrawals[msg.sender];
    // if all payouts for given token holder executed then exit
    if (paymentId == payouts.length)
      return 0;
    uint payout = 0;
    for (uint i = paymentId; i<payouts.length; i++) {
      // it is safe to make payouts pro-rata: (1) token supply will not change - check converted/conversion modifiers
      // -- (2) balances will not change: check transfer override which limits transfer between accounts
      // NOTE: safeMul throws on overflow, can lock users out of their withdrawals if balance is very high
      // @remco I know. any suggestions? expression below gives most precision
      uint thisPayout = divRound(safeMul(payouts[i], balance), totalSupply);
      payout += thisPayout;
    }
    // change now to prevent re-entry (not necessary due to low send() gas limit)
    withdrawals[msg.sender] = payouts.length;
    if (payout > 0) {
      // now modify payout within 1000 weis as we had rounding errors coming from pro-rata amounts
      // @remco maximum rounding error is (num_employees * num_payments) / 2 with the mean 0
      // --- 1000 wei is still nothing, please explain me what problem you see here
      if ( absDiff(this.balance, payout) < 1000 wei )
        payout = this.balance; // send all
      //if(!msg.sender.call.value(payout)()) // re entry test
      //  throw;
      if (!msg.sender.send(payout))
        throw;
    }
    return payout;
  }

  function transfer(address _to, uint _value) public converted {
    // if anything was withdrawn then block transfer to prevent multiple withdrawals
    // todo: we could allow transfer to new account (no token balance)
    // todo: we could allow transfer between account that fully withdrawn (but what's the point? -token has 0 value then)
    // todo: there are a few other edge cases where there's transfer and no double spending
    if (withdrawals[_to] > 0 || withdrawals[msg.sender] > 0)
      throw;
    ERC20OptionsConverter.transfer(_to, _value);
  }

  function ProceedsOptionsConverter(address esop, uint32 exerciseDeadline, uint32 conversionDeadline)
    ERC20OptionsConverter(esop, exerciseDeadline, conversionDeadline)
  {
  }
}

contract RoT is Ownable {
    address public ESOPAddress;
    event ESOPAndCompanySet(address ESOPAddress, address companyAddress);

    function setESOP(address ESOP, address company) public onlyOwner {
      // owner sets ESOP and company only once then passes ownership to company
      // initially owner is a developer/admin
      ESOPAddress = ESOP;
      transferOwnership(company);
      ESOPAndCompanySet(ESOP, company);
    }

    function killOnUnsupportedFork() public onlyOwner {
      // this method may only be called by company on unsupported forks
      delete ESOPAddress;
      selfdestruct(owner);
    }
}