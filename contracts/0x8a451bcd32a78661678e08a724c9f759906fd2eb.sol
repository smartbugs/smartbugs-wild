pragma solidity ^0.5.0;


contract IOwnable {

    address public owner;
    address public newOwner;

    event OwnerChanged(address _oldOwner, address _newOwner);

    function changeOwner(address _newOwner) public;
    function acceptOwnership() public;
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


contract IERC20Token {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value)  public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value)  public returns (bool success);
    function approve(address _spender, uint256 _value)  public returns (bool success);
    function allowance(address _owner, address _spender)  public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract IWinbixToken is IERC20Token {

    uint256 public votableTotal;
    uint256 public accruableTotal;
    address public issuer;
    bool public transferAllowed;

    mapping (address => bool) public isPayable;

    event SetIssuer(address _address);
    event TransferAllowed(bool _newState);
    event FreezeWallet(address _address);
    event UnfreezeWallet(address _address);
    event IssueTokens(address indexed _to, uint256 _value);
    event IssueVotable(address indexed _to, uint256 _value);
    event IssueAccruable(address indexed _to, uint256 _value);
    event BurnTokens(address indexed _from, uint256 _value);
    event BurnVotable(address indexed _from, uint256 _value);
    event BurnAccruable(address indexed _from, uint256 _value);
    event SetPayable(address _address, bool _state);

    function setIssuer(address _address) public;
    function allowTransfer(bool _allowTransfer) public;
    function freeze(address _address) public;
    function unfreeze(address _address) public;
    function isFrozen(address _address) public returns (bool);
    function issue(address _to, uint256 _value) public;
    function issueVotable(address _to, uint256 _value) public;
    function issueAccruable(address _to, uint256 _value) public;
    function votableBalanceOf(address _address) public view returns (uint256);
    function accruableBalanceOf(address _address) public view returns (uint256);
    function burn(uint256 _value) public;
    function burnAll() public;
    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool);
    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool);
    function setMePayable(bool _state) public;
}

contract IWinbixPayable {

    function catchWinbix(address payable _from, uint256 _value) external;

}

contract WinbixPayable is IWinbixPayable {

    IWinbixToken internal winbixToken;

    function winbixPayable(address payable _from, uint256 _value) internal;

    function catchWinbix(address payable _from, uint256 _value) external {
        require(address(msg.sender) == address(winbixToken));
        winbixPayable(_from, _value);
    }

}


contract IVerificationList is IOwnable {

    event Accept(address _address);
    event Reject(address _address);
    event SendToCheck(address _address);
    event RemoveFromList(address _address);
    
    function isAccepted(address _address) public view returns (bool);
    function isRejected(address _address) public view returns (bool);
    function isOnCheck(address _address) public view returns (bool);
    function isInList(address _address) public view returns (bool);
    function isNotInList(address _address) public view returns (bool);
    function isAcceptedOrNotInList(address _address) public view returns (bool);
    function getState(address _address) public view returns (uint8);
    
    function accept(address _address) public;
    function reject(address _address) public;
    function toCheck(address _address) public;
    function remove(address _address) public;
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

contract ITap is IOwnable {

    uint8[12] public tapPercents = [2, 2, 3, 11, 11, 17, 11, 11, 8, 8, 8, 8];
    uint8 public nextTapNum;
    uint8 public nextTapPercent = tapPercents[nextTapNum];
    uint public nextTapDate;
    uint public remainsForTap;
    uint public baseEther;

    function init(uint _baseEther, uint _startDate) public;
    function changeNextTap(uint8 _newPercent) public;
    function getNext() public returns (uint);
    function subRemainsForTap(uint _delta) public;
}

contract IRefund is IOwnable {
    
    ITap public tap;
    uint public refundedTokens;
    uint public tokensBase;

    function init(uint _tokensBase, address _tap, uint _startDate) public;
    function refundEther(uint _value) public returns (uint);
    function calculateEtherForRefund(uint _tokensAmount) public view returns (uint);
}

contract PreDAICO is Ownable, WinbixPayable, SafeMath {

    enum KycStates { None, OnCheck, Accepted, Rejected }
    enum VotingType { None, Prolongation, TapChange }

    uint constant SOFTCAP = 6250000 ether;
    uint constant HARDCAP = 25000000 ether;
    uint constant TOKENS_FOR_MARKETING = 2500000 ether;
    uint constant TOKENS_FOR_ISSUE = 27500000 ether;

    uint constant MIN_PURCHASE = 0.1 ether;

    uint constant SKIP_TIME = 15 minutes;

    uint constant PRICE1 = 550 szabo;
    uint constant PRICE2 = 600 szabo;
    uint constant PRICE3 = 650 szabo;
    uint constant PRICE4 = 700 szabo;
    uint constant PRICE5 = 750 szabo;

    uint public soldTokens;
    uint public recievedEther;
    uint public etherAfterKyc;
    uint public tokensAfterKyc;
    uint public refundedTokens;

    IVerificationList public buyers;
    IVoting public voting;
    ITap public tap;
    IRefund public refund;

    address public kycChecker;

    mapping (address => uint) public etherPaid;
    mapping (address => uint) public wbxSold;

    uint public startDate;
    uint public endDate;
    uint public additionalTime;

    uint public tokensForMarketingTotal;
    uint public tokensForMarketingRemains;

    VotingType private votingType;
    bool private votingApplied = true;


    event HardcapCompiled();
    event SoftcapCompiled();
    event Tap(address _address, uint _value);
    event Refund(address _address, uint _tokenAmount, uint _etherAmount);

    modifier isProceeds {
        require(now >= startDate && now <= endDate);
        _;
    }

    modifier onlyKycChecker {
        require(msg.sender == kycChecker);
        _;
    }

    function setExternals(
        address _winbixToken,
        address _buyers,
        address _voting,
        address _tap,
        address _refund
    ) public onlyOwner {
        if (address(winbixToken) == address(0)) {
            winbixToken = IWinbixToken(_winbixToken);
            winbixToken.setMePayable(true);
        }
        if (address(buyers) == address(0)) {
            buyers = IVerificationList(_buyers);
            buyers.acceptOwnership();
        }
        if (address(voting) == address(0)) {
            voting = IVoting(_voting);
            voting.acceptOwnership();
        }
        if (address(tap) == address(0)) {
            tap = ITap(_tap);
            tap.acceptOwnership();
        }
        if (address(refund) == address(0)) {
            refund = IRefund(_refund);
            refund.acceptOwnership();
        }
        kycChecker = msg.sender;
    }

    function setKycChecker(address _address) public onlyOwner {
        kycChecker = _address;
    }

    function startPreDaico() public onlyOwner {
        require(
            (startDate == 0) &&
            address(buyers) != address(0) &&
            address(voting) != address(0) &&
            address(tap) != address(0) &&
            address(refund) != address(0)
        );
        winbixToken.issue(address(this), TOKENS_FOR_ISSUE);
        startDate = now;
        endDate = now + 60 days;
    }

    function () external payable isProceeds {
        require(soldTokens < HARDCAP && msg.value >= MIN_PURCHASE);

        uint etherValue = msg.value;
        uint tokenPrice = getTokenPrice();
        uint tokenValue = safeMul(etherValue, 1 ether) / tokenPrice;
        uint newSum = safeAdd(soldTokens, tokenValue);
        bool softcapNotYetCompiled = soldTokens < SOFTCAP;

        buyers.toCheck(msg.sender);
        winbixToken.freeze(msg.sender);

        if (newSum > HARDCAP) {
            uint forRefund = safeMul((newSum - HARDCAP), tokenPrice) / (1 ether);
            address(msg.sender).transfer(forRefund);
            etherValue = safeSub(etherValue, forRefund);
            tokenValue = safeSub(HARDCAP, soldTokens);
        }

        soldTokens += tokenValue;
        recievedEther += etherValue;
        etherPaid[msg.sender] += etherValue;
        wbxSold[msg.sender] += tokenValue;

        winbixToken.transfer(msg.sender, tokenValue);
        winbixToken.issueVotable(msg.sender, tokenValue);
        winbixToken.issueAccruable(msg.sender, tokenValue);

        if (softcapNotYetCompiled && soldTokens >= SOFTCAP) {
            emit SoftcapCompiled();
        }
        if (soldTokens == HARDCAP) {
            endDate = now;
            emit HardcapCompiled();
        }
    }

    function getTokenPrice() public view returns (uint) {
        if (soldTokens <= 5000000 ether) {
            return PRICE1;
        } else if (soldTokens <= 10000000 ether) {
            return PRICE2;
        } else if (soldTokens <= 15000000 ether) {
            return PRICE3;
        } else if (soldTokens <= 20000000 ether) {
            return PRICE4;
        } else {
            return PRICE5;
        }
    }

    function kycSuccess(address _address) public onlyKycChecker {
        require(now > endDate + SKIP_TIME && now < endDate + additionalTime + 15 days);
        require(!buyers.isAccepted(_address));
        etherAfterKyc += etherPaid[_address];
        tokensAfterKyc += wbxSold[_address];
        winbixToken.unfreeze(_address);
        buyers.accept(_address);
    }

    function kycFail(address _address) public onlyKycChecker {
        require(now > endDate + SKIP_TIME && now < endDate + additionalTime + 15 days);
        require(!buyers.isRejected(_address));
        if (buyers.isAccepted(_address)) {
            etherAfterKyc -= etherPaid[_address];
            tokensAfterKyc -= wbxSold[_address];
        }
        winbixToken.freeze(_address);
        buyers.reject(_address);
    }

    function getKycState(address _address) public view returns (KycStates) {
        return KycStates(buyers.getState(_address));
    }


    function prepareTokensAfterKyc() public {
        require(tokensForMarketingTotal == 0);
        require(now > endDate + additionalTime + 15 days + SKIP_TIME && soldTokens >= SOFTCAP);
        tokensForMarketingTotal = tokensAfterKyc / 10;
        tokensForMarketingRemains = tokensForMarketingTotal;
        winbixToken.burn(TOKENS_FOR_ISSUE - soldTokens - tokensForMarketingTotal);
        winbixToken.allowTransfer(true);
        tap.init(etherAfterKyc, endDate + additionalTime + 17 days + SKIP_TIME);
        refund.init(tokensAfterKyc, address(tap), endDate + 45 days);
    }

    function transferTokensForMarketing(address _to, uint _value) public onlyOwner {
        require(_value <= tokensForMarketingRemains && buyers.isAcceptedOrNotInList(_to));
        winbixToken.transfer(_to, _value);
        winbixToken.issueAccruable(_to, _value);
        tokensForMarketingRemains -= _value;
    }

    function burnTokensIfSoftcapNotCompiled() public {
        require(endDate > 0 && now > endDate + 2 days + SKIP_TIME && soldTokens < SOFTCAP);
        winbixToken.burnAll();
    }


    function getTap() public onlyOwner {
        uint tapValue = tap.getNext();
        address(msg.sender).transfer(tapValue);
        emit Tap(msg.sender, tapValue);
    }


    function getVotingSubject() public view returns (uint8) {
        return voting.subject();
    }

    function initCrowdsaleProlongationVoting() public onlyOwner {
        require(now >= endDate + SKIP_TIME && now <= endDate + 12 hours);
        require(soldTokens >= SOFTCAP * 75 / 100);
        require(soldTokens <= HARDCAP * 90 / 100);
        voting.initProlongationVoting();
        votingApplied = false;
        additionalTime = 2 days;
        votingType = VotingType.Prolongation;
    }

    function initTapChangeVoting(uint8 newPercent) public onlyOwner {
        require(tokensForMarketingTotal > 0);
        require(now > endDate + 17 days);
        voting.initTapChangeVoting(newPercent);
        votingApplied = false;
        votingType = VotingType.TapChange;
    }

    function isVotingInProgress() public view returns (bool) {
        return voting.inProgress();
    }

    function getVotingWeight(address _address) public view returns (uint) {
        if (votingType == VotingType.TapChange && !buyers.isAccepted(_address)) {
            return 0;
        }
        return winbixToken.votableBalanceOf(_address);
    }

    function voteYes() public {
        voting.yes(msg.sender, getVotingWeight(msg.sender));
    }

    function voteNo() public {
        voting.no(msg.sender, getVotingWeight(msg.sender));
    }

    function getVote(address _address) public view returns (int) {
        return voting.vote(_address);
    }

    function getVotesTotal() public view returns (uint) {
        return voting.votesTotal();
    }

    function isSubjectApproved() public view returns (bool) {
        return voting.isSubjectApproved();
    }

    function applyVotedProlongation() public {
        require(now < endDate + 2 days);
        require(votingType == VotingType.Prolongation);
        require(!votingApplied);
        require(!voting.inProgress());
        votingApplied = true;
        if (voting.isSubjectApproved()) {
            startDate = endDate + 2 days;
            endDate = startDate + 30 days;
            additionalTime = 0;
        }
    }

    function applyVotedPercent() public {
        require(votingType == VotingType.TapChange);
        require(!votingApplied);
        require(!voting.inProgress());
        require(now < voting.nextVotingDate());
        votingApplied = true;
        if (voting.isSubjectApproved()) {
            tap.changeNextTap(voting.subject());
        }
    }


    function refundableBalanceOf(address _address) public view returns (uint) {
        if (!buyers.isAcceptedOrNotInList(_address)) return 0;
        return winbixToken.votableBalanceOf(_address);
    }

    function calculateEtherForRefund(uint _tokensAmount) public view returns (uint) {
        return refund.calculateEtherForRefund(_tokensAmount);
    }


    function winbixPayable(address payable _from, uint256 _value) internal {
        if (_value == 0) return;
        uint etherValue;
        KycStates state = getKycState(_from);
        if (
            (soldTokens < SOFTCAP && now > endDate + 2 days) ||
            ((state == KycStates.Rejected || state == KycStates.OnCheck) && (now > endDate + additionalTime + 17 days))
        ) {
            etherValue = etherPaid[_from];
            require(etherValue > 0 && _value == wbxSold[_from]);
            _from.transfer(etherValue);
            etherPaid[_from] = 0;
            wbxSold[_from] = 0;
            winbixToken.unfreeze(_from);
        } else {
            require(winbixToken.votableBalanceOf(_from) >= _value);
            etherValue = refund.refundEther(_value);
            _from.transfer(etherValue);
            tap.subRemainsForTap(etherValue);
            emit Refund(_from, _value, etherValue);
        }
        winbixToken.burn(_value);
    }
}