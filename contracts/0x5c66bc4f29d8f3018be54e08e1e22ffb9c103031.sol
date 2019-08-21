pragma solidity ^0.4.23;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


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
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: contracts/Adminable.sol

/**
 * @title Adminable
 * @dev The adminable contract has an admin address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Adminable is Ownable {
    address public admin;

    event AdminTransferred(address indexed previousAdmin, address indexed newAdmin);

    /**
     * @dev The Mintable constructor sets the original `minter` of the contract to the sender
     * account.
     */
    constructor() public {
        admin = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the admin.
     */
    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin is allowed to execute this method.");
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the admin to newAdmin
     */
    function transferAdmin(address newAdmin) public onlyOwner {
        require(newAdmin != address(0));
        emit AdminTransferred(admin, newAdmin);
        admin = newAdmin;
    }
}

// File: contracts/EpicsLimitedEdition.sol

contract EpicsLimitedEdition is Ownable, Adminable {
    event LimitedEditionRunCreated(uint256 runId);
    event UUIDAdded(uint256 runId, string uuid);

    struct LimitedEditionRun {
        string name;
        uint32 cardCount;
        string created;
    }

    LimitedEditionRun[] runs;
    mapping (string => uint256) internal uuidToRunId;
    mapping (string => uint256) internal nameToRunId;
    mapping (uint256 => string[]) internal runToUuids;
    mapping (string => bool) internal uuidExists;
    mapping (string => bool) internal runExists;


    function createRun(string name, uint32 cardCount, string created) public onlyAdmin {
        require(runExists[name] == false, "Limited edition run with that name already exists.");
        LimitedEditionRun memory _run = LimitedEditionRun({name: name, cardCount: cardCount, created: created});
        uint256 _runId = runs.push(_run) - 1;
        runToUuids[_runId] = new string[](0);
        nameToRunId[name] = _runId;
        runExists[name] = true;
        emit LimitedEditionRunCreated(_runId);
    }

    function getRun(uint256 runId) public view returns (string name, uint32 cardCount, string created) {
        require(runId < runs.length, "Run ID does not exist.");
        LimitedEditionRun memory run = runs[runId];
        name = run.name;
        cardCount = run.cardCount;
        created = run.created;
    }

    function getRunIdForName(string name) public view returns (uint256 runId) {
        require(runExists[name] == true, "Run with that name does not exist.");
        return nameToRunId[name];
    }

    function getRunIdForUUID(string uuid) public view returns (uint256 runId) {
        require(uuidExists[uuid] == true, "UUID is not added to any run.");
        return uuidToRunId[uuid];
    }

    function getRunUUIDAtIndex(uint256 runId, uint256 index) public view returns (string uuid) {
        require(runId < runs.length, "Run ID does not exist.");
        require(index < runToUuids[runId].length, "That UUID index is out of range.");
        uuid = runToUuids[runId][index];
    }

    function getTotalRuns() public constant returns (uint256 totalRuns) {
        return runs.length;
    }

    function add1UUID(uint256 runId, string uuid) public onlyAdmin {
        require(runId < runs.length, "Run ID does not exist.");
        require(uuidExists[uuid] == false, "UUID already added.");
        runToUuids[runId].push(uuid);
        uuidToRunId[uuid] = runId;
        uuidExists[uuid] = true;
        emit UUIDAdded(runId, uuid);
    }

    function add5UUIDs(uint256 runId, string uuid1, string uuid2, string uuid3, string uuid4, string uuid5) public onlyAdmin {
        add1UUID(runId, uuid1);
        add1UUID(runId, uuid2);
        add1UUID(runId, uuid3);
        add1UUID(runId, uuid4);
        add1UUID(runId, uuid5);
    }

    function add10UUIDs(uint256 runId, string uuid1, string uuid2, string uuid3, string uuid4, string uuid5,
                        string uuid6, string uuid7, string uuid8, string uuid9, string uuid10) public onlyAdmin {
        add1UUID(runId, uuid1);
        add1UUID(runId, uuid2);
        add1UUID(runId, uuid3);
        add1UUID(runId, uuid4);
        add1UUID(runId, uuid5);
        add1UUID(runId, uuid6);
        add1UUID(runId, uuid7);
        add1UUID(runId, uuid8);
        add1UUID(runId, uuid9);
        add1UUID(runId, uuid10);
    }
}