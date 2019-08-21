pragma solidity ^0.4.11;


contract IPFSEvents {
	event HashAdded(address PubKey, string IPFSHash, uint ttl);
	event HashRemoved(address PubKey, string IPFSHash);
}

contract Multimember {

    // TYPES

    // struct for the status of a pending operation.
    struct PendingState {
        uint yetNeeded;
        uint membersDone;
        uint index;
    }

    // EVENTS

    // this contract only has seven types of events: it can accept a confirmation, in which case
    // we record member and operation (hash) alongside it.
    event Confirmation(address member, bytes32 operation);
    event Revoke(address member, bytes32 operation);
    // some others are in the case of an member changing.
    event MemberChanged(address oldMember, address newMember);
    event MemberAdded(address newMember);
    event MemberRemoved(address oldMember);
    // the last one is emitted if the required signatures change
    event RequirementChanged(uint newRequirement);

    // MODIFIERS

    // simple single-sig function modifier.
    modifier onlymember {
        if (isMember(msg.sender))
            _;
    }
    // multi-sig function modifier: the operation must have an intrinsic hash in order
    // that later attempts can be realised as the same underlying operation and
    // thus count as confirmations.
    modifier onlymanymembers(bytes32 _operation) {
        if (confirmAndCheck(_operation))
            _;
    }

    // METHODS

    // constructor is given number of sigs required to do protected "onlymanymembers" transactions
    // as well as the selection of addresses capable of confirming them.
    function Multimember(address[] _members, uint _required) public {
        m_numMembers = _members.length + 1;
        m_members[1] = uint(msg.sender);
        m_memberIndex[uint(msg.sender)] = 1;
        for (uint i = 0; i < _members.length; ++i) {
            m_members[2 + i] = uint(_members[i]);
            m_memberIndex[uint(_members[i])] = 2 + i;
        }
        m_required = _required;
    }
    
    // Revokes a prior confirmation of the given operation
    function revoke(bytes32 _operation) external {
        uint memberIndex = m_memberIndex[uint(msg.sender)];
        // make sure they're an member
        if (memberIndex == 0) 
            return;
        uint memberIndexBit = 2**memberIndex;
        var pending = m_pending[_operation];
        if (pending.membersDone & memberIndexBit > 0) {
            pending.yetNeeded++;
            pending.membersDone -= memberIndexBit;
            Revoke(msg.sender, _operation);
        }
    }
    
    // Replaces an member `_from` with another `_to`.
    function changeMember(address _from, address _to) onlymanymembers(keccak256(_from,_to)) external {
        if (isMember(_to)) 
            return;
        uint memberIndex = m_memberIndex[uint(_from)];
        if (memberIndex == 0) 
            return;

        clearPending();
        m_members[memberIndex] = uint(_to);
        m_memberIndex[uint(_from)] = 0;
        m_memberIndex[uint(_to)] = memberIndex;
        MemberChanged(_from, _to);
    }
    
    function addMember(address _member) onlymanymembers(keccak256(_member)) public {
        if (isMember(_member)) 
            return;

        clearPending();
        if (m_numMembers >= c_maxMembers)
            reorganizeMembers();
        if (m_numMembers >= c_maxMembers)
            return;
        m_numMembers++;
        m_members[m_numMembers] = uint(_member);
        m_memberIndex[uint(_member)] = m_numMembers;
        MemberAdded(_member);
    }
    
    function removeMember(address _member) onlymanymembers(keccak256(_member)) public {
        uint memberIndex = m_memberIndex[uint(_member)];
        if (memberIndex == 0) 
            return;
        if (m_required > m_numMembers - 1) 
            return;

        m_members[memberIndex] = 0;
        m_memberIndex[uint(_member)] = 0;
        clearPending();
        reorganizeMembers(); //make sure m_numMembers is equal to the number of members and always points to the optimal free slot
        MemberRemoved(_member);
    }
    
    function changeRequirement(uint _newRequired) onlymanymembers(keccak256(_newRequired)) external {
        if (_newRequired > m_numMembers) 
            return;
        m_required = _newRequired;
        clearPending();
        RequirementChanged(_newRequired);
    }
    
    function isMember(address _addr) public constant returns (bool) { 
        return m_memberIndex[uint(_addr)] > 0;
    }
    
    function hasConfirmed(bytes32 _operation, address _member) external constant returns (bool) {
        var pending = m_pending[_operation];
        uint memberIndex = m_memberIndex[uint(_member)];

        // make sure they're an member
        if (memberIndex == 0) 
            return false;

        // determine the bit to set for this member.
        uint memberIndexBit = 2**memberIndex;
        return !(pending.membersDone & memberIndexBit == 0);
    }
    
    // INTERNAL METHODS

    function confirmAndCheck(bytes32 _operation) internal returns (bool) {
        // determine what index the present sender is:
        uint memberIndex = m_memberIndex[uint(msg.sender)];
        // make sure they're an member
        if (memberIndex == 0) 
            return;

        var pending = m_pending[_operation];
        // if we're not yet working on this operation, switch over and reset the confirmation status.
        if (pending.yetNeeded == 0) {
            // reset count of confirmations needed.
            pending.yetNeeded = m_required;
            // reset which members have confirmed (none) - set our bitmap to 0.
            pending.membersDone = 0;
            pending.index = m_pendingIndex.length++;
            m_pendingIndex[pending.index] = _operation;
        }
        // determine the bit to set for this member.
        uint memberIndexBit = 2**memberIndex;
        // make sure we (the message sender) haven't confirmed this operation previously.
        if (pending.membersDone & memberIndexBit == 0) {
            Confirmation(msg.sender, _operation);
            // ok - check if count is enough to go ahead.
            if (pending.yetNeeded <= 1) {
                // enough confirmations: reset and run interior.
                delete m_pendingIndex[m_pending[_operation].index];
                delete m_pending[_operation];
                return true;
            } else {
                // not enough: record that this member in particular confirmed.
                pending.yetNeeded--;
                pending.membersDone |= memberIndexBit;
            }
        }
    }

    function reorganizeMembers() private returns (bool) {
        uint free = 1;
        while (free < m_numMembers) {
            while (free < m_numMembers && m_members[free] != 0) {
                free++;
            } 

            while (m_numMembers > 1 && m_members[m_numMembers] == 0) {
                m_numMembers--;
            } 

            if (free < m_numMembers && m_members[m_numMembers] != 0 && m_members[free] == 0) {
                m_members[free] = m_members[m_numMembers];
                m_memberIndex[m_members[free]] = free;
                m_members[m_numMembers] = 0;
            }
        }
    }
    
    function clearPending() internal {
        uint length = m_pendingIndex.length;
        for (uint i = 0; i < length; ++i) {
            if (m_pendingIndex[i] != 0) {
                delete m_pending[m_pendingIndex[i]];
            }
        }
        delete m_pendingIndex;
    }
        
    // FIELDS

    // the number of members that must confirm the same operation before it is run.
    uint public m_required;
    // pointer used to find a free slot in m_members
    uint public m_numMembers;
    
    // list of members
    uint[256] m_members;
    uint constant c_maxMembers = 250;
    // index on the list of members to allow reverse lookup
    mapping(uint => uint) m_memberIndex;
    // the ongoing operations.
    mapping(bytes32 => PendingState) m_pending;
    bytes32[] m_pendingIndex;
}

contract IPFSProxy is IPFSEvents, Multimember {
	mapping(address => mapping( address => bool)) public complained;
	mapping(address => uint) public complaint;
	uint public banThreshold;
	uint public sizeLimit;
	address[] members;
	
	/**
	* @dev Throws if called by any account other than a valid member. 
	*/
	modifier onlyValidMembers {
		require (isMember(msg.sender));
		_;
	}

    event ContractAdded(address PubKey, uint ttl);
    event ContractRemoved(address PubKey);
	event Banned(string IPFSHash);
	event BanAttempt(address complainer, address _Member, uint complaints );
	event PersistLimitChanged(uint Limit);	

	/**
	* @dev Constructor - adds the owner of the contract to the list of valid members
	*/
	function IPFSProxy() Multimember (members, 1) public {
		addContract(this, 0);
		updateBanThreshold(1);
		setTotalPersistLimit(10000000000); //10 GB
	}

	/**
	* @dev Add hash to persistent storage
	* @param _IPFSHash The ipfs hash to propagate.
	* @param _ttl amount of time is seconds to persist this. 
	*/
	function addHash(string _IPFSHash, uint _ttl) public onlyValidMembers {
		HashAdded(msg.sender,_IPFSHash,_ttl);
	}

	/**
	* @dev Remove hash from persistent storage
	* @param _IPFSHash The ipfs hash to propagate.	
	*/
	function removeHash(string _IPFSHash) public onlyValidMembers {
		HashRemoved(msg.sender,_IPFSHash);
	}


	/** 
	* Add a contract to watch list. Each node will then 
	* watch it for `HashAdded(msg.sender,_IPFSHash,_ttl);` 
	* events and it will cache these events
	*/

	function addContract(address _toWatch, uint _ttl) public onlyValidMembers {
		ContractAdded(_toWatch, _ttl);
	}

	/**
	* @dev Remove contract from watch list
	*/
	function removeContract(address _contractAddress) public onlyValidMembers {
		ContractRemoved(_contractAddress);
	}

	/**
	*@dev removes a member who exceeds the cap
	*/
	function banMember (address _Member, string _evidence) public onlyValidMembers {
		require(isMember(_Member));
		require(!complained[msg.sender][_Member]);
		complained[msg.sender][_Member] = true;
		complaint[_Member] += 1;	
		if (complaint[_Member] >= banThreshold) { 
			removeMember(_Member);
			if (!isMember(_Member)) {
				Banned(_evidence);
			} 
		} else {
			BanAttempt(msg.sender, _Member, complaint[_Member]);
		}
	}
	/**
	* @dev update ban threshold
	*/
	function updateBanThreshold (uint _banThreshold) public onlymanymembers(keccak256(_banThreshold)) {
		banThreshold = _banThreshold;
	}

	/**
	* @dev set total allowed upload
	*
	**/
	function setTotalPersistLimit (uint _limit) public onlymanymembers(keccak256(_limit)) {
		sizeLimit = _limit;
		PersistLimitChanged(_limit);
	}
}