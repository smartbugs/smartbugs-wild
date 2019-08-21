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

contract Refund is IRefund, Ownable {

    uint startDate;

    function init(uint _tokensBase, address _tap, uint _startDate) public onlyOwner {
        tap = ITap(_tap);
        tokensBase = _tokensBase;
        startDate = _startDate;
    }

    function refundEther(uint _value) public onlyOwner returns (uint) {
        uint etherForRefund = calculateEtherForRefund(_value);
        refundedTokens += _value;
        return etherForRefund;
    }

    function calculateEtherForRefund(uint _tokensAmount) public view returns (uint) {
        require(startDate > 0 && now > startDate && tokensBase > 0);
        uint etherRemains = tap.remainsForTap();
        if (_tokensAmount == 0 || etherRemains == 0) {
            return 0;
        }

        uint etherForRefund;

        uint startPart = refundedTokens + 1;
        uint endValue = refundedTokens + _tokensAmount;
        require(endValue <= tokensBase);

        uint refundCoeff;
        uint nextStart;
        uint endPart;
        uint partTokensValue;
        uint tokensRemains = tokensBase - refundedTokens;

        while (true) {
            refundCoeff = _refundCoeff(startPart);
            nextStart = _nextStart(refundCoeff);
            endPart = nextStart - 1;
            if (endPart > endValue) endPart = endValue;
            partTokensValue = endPart - startPart + 1;
            etherForRefund += refundCoeff * (etherRemains - etherForRefund) * partTokensValue / tokensRemains / 100;
            if (nextStart > endValue) break;
            startPart = nextStart;
            tokensRemains -= partTokensValue;
        }
        return etherForRefund;
    }

    function _refundCoeff(uint _tokensValue) private view returns (uint) {
        uint refundedPercent = 100 * _tokensValue / tokensBase;
        if (refundedPercent < 10) {
            return 80;
        } else if (refundedPercent < 20) {
            return 85;
        } else if (refundedPercent < 30) {
            return 90;
        } else if (refundedPercent < 40) {
            return 95;
        } else {
            return 100;
        }
    }

    function _nextStart(uint _refundCoefficient) private view returns (uint) {
        uint res;
        if (_refundCoefficient == 80) {
            res = tokensBase * 10 / 100;
        } else if (_refundCoefficient == 85) {
            res = tokensBase * 20 / 100;
        } else if (_refundCoefficient == 90) {
            res = tokensBase * 30 / 100;
        } else if (_refundCoefficient == 95) {
            res = tokensBase * 40 / 100;
        } else {
            return tokensBase+1;
        }
        if (_refundCoeff(res) == _refundCoefficient) res += 1;
        return res;
    }
}