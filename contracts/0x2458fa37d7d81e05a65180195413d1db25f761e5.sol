pragma solidity ^0.4.2;

contract SpiceMembers {
    enum MemberLevel { None, Member, Manager, Director }
    struct Member {
        uint id;
        MemberLevel level;
        bytes32 info;
    }

    mapping (address => Member) member;

    address public owner;
    mapping (uint => address) public memberAddress;
    uint public memberCount;

    event TransferOwnership(address indexed sender, address indexed owner);
    event AddMember(address indexed sender, address indexed member);
    event RemoveMember(address indexed sender, address indexed member);
    event SetMemberLevel(address indexed sender, address indexed member, MemberLevel level);
    event SetMemberInfo(address indexed sender, address indexed member, bytes32 info);

    function SpiceMembers() {
        owner = msg.sender;

        memberCount = 1;
        memberAddress[memberCount] = owner;
        member[owner] = Member(memberCount, MemberLevel.None, 0);
    }

    modifier onlyOwner {
        if (msg.sender != owner) throw;
        _;
    }

    modifier onlyManager {
        if (msg.sender != owner && memberLevel(msg.sender) < MemberLevel.Manager) throw;
        _;
    }
    
    function transferOwnership(address _target) onlyOwner {
        // If new owner has no memberId, create one
        if (member[_target].id == 0) {
            memberCount++;
            memberAddress[memberCount] = _target;
            member[_target] = Member(memberCount, MemberLevel.None, 0);
        }
        owner = _target;
        TransferOwnership(msg.sender, owner);
    }

    function addMember(address _target) onlyManager {
        // Make sure trying to add an existing member throws an error
        if (memberLevel(_target) != MemberLevel.None) throw;

        // If added member has no memberId, create one
        if (member[_target].id == 0) {
            memberCount++;
            memberAddress[memberCount] = _target;
            member[_target] = Member(memberCount, MemberLevel.None, 0);
        }

        // Set memberLevel to initial value with basic access
        member[_target].level = MemberLevel.Member;
        AddMember(msg.sender, _target);
    }

    function removeMember(address _target) {
        // Make sure trying to remove a non-existing member throws an error
        if (memberLevel(_target) == MemberLevel.None) throw;
        // Make sure members are only allowed to delete members lower than their level
        if (msg.sender != owner && memberLevel(msg.sender) <= memberLevel(_target)) throw;

        member[_target].level = MemberLevel.None;
        RemoveMember(msg.sender, _target);
    }

    function setMemberLevel(address _target, MemberLevel level) {
        // Make sure all levels are larger than None but not higher than Director
        if (level == MemberLevel.None || level > MemberLevel.Director) throw;
        // Make sure the _target is currently already a member
        if (memberLevel(_target) == MemberLevel.None) throw;
        // Make sure the new level is lower level than we are (we cannot overpromote)
        if (msg.sender != owner && memberLevel(msg.sender) <= level) throw;
        // Make sure the member is currently on lower level than we are
        if (msg.sender != owner && memberLevel(msg.sender) <= memberLevel(_target)) throw;

        member[_target].level = level;
        SetMemberLevel(msg.sender, _target, level);
    }

    function setMemberInfo(address _target, bytes32 info) {
        // Make sure the target is currently already a member
        if (memberLevel(_target) == MemberLevel.None) throw;
        // Make sure the member is currently on lower level than we are
        if (msg.sender != owner && msg.sender != _target && memberLevel(msg.sender) <= memberLevel(_target)) throw;

        member[_target].info = info;
        SetMemberInfo(msg.sender, _target, info);
    }

    function memberId(address _target) constant returns (uint) {
        return member[_target].id;
    }

    function memberLevel(address _target) constant returns (MemberLevel) {
        return member[_target].level;
    }

    function memberInfo(address _target) constant returns (bytes32) {
        return member[_target].info;
    }
}

contract SpiceControlled {
    SpiceMembers members;

    modifier onlyOwner {
        if (!hasOwnerAccess(msg.sender)) throw;
        _;
    }

    modifier onlyDirector {
        if (!hasDirectorAccess(msg.sender)) throw;
        _;
    }

    modifier onlyManager {
        if (!hasManagerAccess(msg.sender)) throw;
        _;
    }

    modifier onlyMember {
        if (!hasMemberAccess(msg.sender)) throw;
        _;
    }

    function SpiceControlled(address membersAddress) {
        members = SpiceMembers(membersAddress);
    }

    function hasOwnerAccess(address _target) internal returns (bool) {
        return (_target == members.owner());
    }

    function hasDirectorAccess(address _target) internal returns (bool) {
        return (members.memberLevel(_target) >= SpiceMembers.MemberLevel.Director || hasOwnerAccess(_target));
    }

    function hasManagerAccess(address _target) internal returns (bool) {
        return (members.memberLevel(_target) >= SpiceMembers.MemberLevel.Manager || hasOwnerAccess(_target));
    }
    
    function hasMemberAccess(address _target) internal returns (bool) {
        return (members.memberLevel(_target) >= SpiceMembers.MemberLevel.Member || hasOwnerAccess(_target));
    }
}

contract IPayoutCalculator {
    function calculatePayout(bytes32 _info, uint _duration) returns (uint);
}

contract SpicePayroll is SpiceControlled {
    struct PayrollEntry {
        bool available;
        uint duration;
        bool processed;
        uint payout;
    }

    address creator;

    uint public fromBlock;
    uint public toBlock;

    mapping (bytes32 => PayrollEntry) entries;
    bytes32[] infos;

    address calculator;
    bool public locked;

    event NewPayroll(address indexed creator);
    event FailedMarking(bytes32 indexed info, bytes32 indexed description, uint total, int duration);
    event AddMarking(bytes32 indexed info, bytes32 indexed description, int duration, uint total);
    event ProcessMarkings(bytes32 indexed info, uint total, uint duration, uint payout);
    event AllMarkingsProcessed(address indexed calculator, uint maxDuration, uint fromBlock, uint toBlock);

    event ModifyMarking(bytes32 indexed info, uint duration, uint payout);
    event SetPayrollLocked(bool locked);

    modifier onlyCreator {
        if (msg.sender != creator) throw;
        _;
    }

    modifier onlyUnprocessed {
        if (calculator != 0) throw;
        _;
    }
    
    modifier onlyProcessed {
        if (calculator == 0) throw;
        _;
    }

    modifier onlyUnlocked {
        if (locked) throw;
        _;
    }

    function SpicePayroll(address _members) SpiceControlled(_members) {
        creator = msg.sender;
        fromBlock = block.number;
        NewPayroll(msg.sender);
    }

    function addMarking(bytes32 _info, bytes32 _description, int _duration) onlyCreator onlyUnprocessed returns(bool) {
        // Check if the duration would become negative as a result of this marking
        // and if it does, mark this as failed and return false to indicate failure.
        if (_duration < 0 && entries[_info].duration < uint(-_duration)) {
          FailedMarking(_info, _description, entries[_info].duration, _duration);
          return false;
        }

        // If info not added yet, add it to the infos array
        PayrollEntry entry = entries[_info];
        if (!entry.available) {
            entry.available = true;
            infos.push(_info);
        }

        // Modify entry duration and send marking event
        if (_duration < 0) {
            entry.duration -= uint(-_duration);
        } else {
            entry.duration += uint(_duration);
        }
        AddMarking(_info, _description, _duration, entry.duration);
        return true;
    }

    function processMarkings(address _calculator, uint _maxDuration) onlyCreator onlyUnprocessed {
        calculator = _calculator;
        for (uint i = 0; i < infos.length; i++) {
            bytes32 info = infos[i];
            PayrollEntry entry = entries[info];

            uint originalDuration = entry.duration;
            entry.duration = (originalDuration <= _maxDuration) ? originalDuration : _maxDuration;
            entry.payout = IPayoutCalculator(calculator).calculatePayout(info, entry.duration);
            ProcessMarkings(info, originalDuration, entry.duration, entry.payout);
        }
        toBlock = block.number;
        AllMarkingsProcessed(_calculator, _maxDuration, fromBlock, toBlock);
    }

    function modifyMarking(bytes32 _info, uint _duration) onlyDirector onlyProcessed onlyUnlocked {
        if (!entries[_info].available) throw;

        PayrollEntry entry = entries[_info];
        entry.duration = _duration;
        entry.payout = IPayoutCalculator(calculator).calculatePayout(_info, _duration);
        ModifyMarking(_info, entry.duration, entry.payout);
    }

    function lock() onlyDirector {
        locked = true;
        SetPayrollLocked(locked);
    }

    function unlock() onlyOwner {
        locked = false;
        SetPayrollLocked(locked);
    }

    function processed() constant returns (bool) {
        return (calculator != 0);
    }

    function duration(bytes32 _info) constant returns (uint) {
        return entries[_info].duration;
    }

    function payout(bytes32 _info) constant returns (uint) {
        return entries[_info].payout;
    }

    function entryInfo(uint _index) constant returns (bytes32) {
        return infos[_index];
    }

    function entryCount() constant returns (uint) {
        return infos.length;
    }
}

contract SpiceHours is SpiceControlled {
    address[] public payrolls;

    event MarkHours(bytes32 indexed info, bytes32 indexed description, int duration, bool success);
    event ProcessPayroll(address indexed payroll, uint maxDuration);
    event CreatePayroll(address indexed payroll);

    function SpiceHours(address _members) SpiceControlled(_members) {
        payrolls[payrolls.length++] = new SpicePayroll(members);
        CreatePayroll(payrolls[payrolls.length-1]);
    }

    function markHours(bytes32 _info, bytes32 _description, int _duration) onlyMember {
        if (!hasManagerAccess(msg.sender) && members.memberInfo(msg.sender) != _info) throw;
        if (_duration == 0) throw;
        if (_info == 0) throw;

        SpicePayroll payroll = SpicePayroll(payrolls[payrolls.length-1]);
        bool success = payroll.addMarking(_info, _description, _duration);
        MarkHours(_info, _description, _duration, success);
    }

    function markHours(bytes32 _description, int _duration) {
        markHours(members.memberInfo(msg.sender), _description, _duration);
    }

    function processPayroll(address _calculator, uint _maxDuration) onlyDirector {
        SpicePayroll payroll = SpicePayroll(payrolls[payrolls.length-1]);
        payroll.processMarkings(_calculator, _maxDuration);
        ProcessPayroll(payroll, _maxDuration);

        payrolls[payrolls.length++] = new SpicePayroll(members);
        CreatePayroll(payrolls[payrolls.length-1]);
    }

    function hasPayroll(address _address) constant returns (bool) {
        for (uint i; i < payrolls.length; i++) {
            if (payrolls[i] == _address) return true;
        }
        return false;
    }

    function payrollCount() constant returns (uint) {
        return payrolls.length;
    }
}