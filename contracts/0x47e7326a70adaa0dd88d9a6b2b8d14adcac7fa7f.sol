pragma solidity ^0.5.0;


contract IOwnable {

    address public owner;
    address public newOwner;

    event OwnerChanged(address _oldOwner, address _newOwner);

    function changeOwner(address _newOwner) public;
    function acceptOwnership() public;
}

contract IVoting is IOwnable {

    uint public startDate;
    uint public endDate;
    uint public votesYes;
    uint public votesNo;
    uint8 public subject;
    uint public nextVotingDate;


    event InitVoting(uint startDate, uint endDate, uint8 subject);
    event Vote(address _address, int _vote);

    function initProlongationVoting() public;
    function initTapChangeVoting(uint8 newPercent) public;
    function inProgress() public view returns (bool);
    function yes(address _address, uint _votes) public;
    function no(address _address, uint _votes) public;
    function vote(address _address) public view returns (int);
    function votesTotal() public view returns (uint);
    function isSubjectApproved() public view returns (bool);
}

contract Ownable is IOwnable {

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    constructor() public {
        owner = msg.sender;
        emit OwnerChanged(address(0), owner);
    }

    function changeOwner(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnerChanged(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract SafeMath {

    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0);
        uint256 c = a / b;
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(a >= b);
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Voting is IVoting, SafeMath, Ownable {

    uint16 private currentVoting;
    mapping (address => int) private votes;
    mapping (address => uint16) private lastVoting;
    bool private prolongationVoted;

    function inProgress() public view returns (bool) {
        return now >= startDate && now <= endDate;
    }

    function init(uint _startDate, uint _duration, uint8 _subject) private {
        require(!inProgress());
        require(_startDate >= now);
        require(_subject > 0 && _subject <= 100);
        currentVoting += 1;
        startDate = _startDate;
        endDate = _startDate + _duration;
        votesYes = 0;
        votesNo = 0;
        subject = _subject;
        emit InitVoting(_startDate, endDate, subject);
    }

    function yes(address _address, uint _votes) public onlyOwner {
        require(inProgress());
        require(lastVoting[_address] < currentVoting);
        require(_votes > 0);
        lastVoting[_address] = currentVoting;
        votes[_address] = int(_votes);
        votesYes = safeAdd(votesYes, _votes);
        emit Vote(_address, int(_votes));
    }

    function no(address _address, uint _votes) public onlyOwner {
        require(inProgress());
        require(lastVoting[_address] < currentVoting);
        require(_votes > 0);
        lastVoting[_address] = currentVoting;
        votes[_address] = 0 - int(_votes);
        votesNo = safeAdd(votesNo, _votes);
        emit Vote(_address, 0 - int(_votes));
    }

    function vote(address _address) public view returns (int) {
        if (lastVoting[_address] == currentVoting) {
            return votes[_address];
        } else {
            return 0;
        }
    }

    function votesTotal() public view returns (uint) {
        return safeAdd(votesYes, votesNo);
    }

    function isSubjectApproved() public view returns (bool) {
        return votesYes > votesNo;
    }

    function initProlongationVoting() public onlyOwner {
        require(!prolongationVoted);
        init(now, 24 hours, 30);
        prolongationVoted = true;
    }

    function initTapChangeVoting(uint8 newPercent) public onlyOwner {
        require(now > nextVotingDate);
        init(now, 14 days, newPercent);
        nextVotingDate = now + 30 days;
    }
}