pragma solidity ^0.5.0;


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

contract MakePayable {
    function makePayable(address x) internal pure returns (address payable) {
        return address(uint160(x));
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

contract ERC20Token is IERC20Token, SafeMath {
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(balances[msg.sender] >= _value);

        balances[msg.sender] = safeSub(balances[msg.sender], _value);
        balances[_to] = safeAdd(balances[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);

        balances[_to] = safeAdd(balances[_to], _value);
        balances[_from] = safeSub(balances[_from], _value);
        allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }
}

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

contract WinbixToken is IWinbixToken, ERC20Token, Ownable, MakePayable {

    mapping (address => bool) private frozen;
    mapping (address => uint256) private votableBalances;
    mapping (address => uint256) private accruableBalances;


    modifier onlyIssuer() {
        require(msg.sender == issuer);
        _;
    }

    modifier canTransfer(address _from, address _to) {
        require((transferAllowed && !frozen[_from] && !frozen[_to]) || _from == issuer || isPayable[_to]);
        _;
    }


    constructor() public {
        name = "Winbix Token";
        symbol = "WBX";
        decimals = 18;
        totalSupply = 0;
    }

    function setIssuer(address _address) public onlyOwner {
        issuer = _address;
        emit SetIssuer(_address);
    }

    function freeze(address _address) public onlyIssuer {
        if (frozen[_address]) return;
        frozen[_address] = true;
        emit FreezeWallet(_address);
    }

    function unfreeze(address _address) public onlyIssuer {
        if (!frozen[_address]) return;
        frozen[_address] = false;
        emit UnfreezeWallet(_address);
    }

    function isFrozen(address _address) public returns (bool) {
        return frozen[_address];
    }

    function issue(address _to, uint256 _value) public onlyIssuer {
        totalSupply = safeAdd(totalSupply, _value);
        balances[_to] += _value;
        emit IssueTokens(_to, _value);
    }

    function issueVotable(address _to, uint256 _value) public onlyIssuer {
        votableTotal = safeAdd(votableTotal, _value);
        votableBalances[_to] += _value;
        require(votableBalances[_to] <= balances[_to]);
        emit IssueVotable(_to, _value);
    }

    function issueAccruable(address _to, uint256 _value) public onlyIssuer {
        accruableTotal = safeAdd(accruableTotal, _value);
        accruableBalances[_to] += _value;
        require(accruableBalances[_to] <= balances[_to]);
        emit IssueAccruable(_to, _value);
    }

    function votableBalanceOf(address _address) public view returns (uint256) {
        return votableBalances[_address];
    }

    function accruableBalanceOf(address _address) public view returns (uint256) {
        return accruableBalances[_address];
    }

    function burn(uint256 _value) public {
        if (_value == 0) return;
        burnTokens(msg.sender, _value);
        minimizeSpecialBalances(msg.sender);
    }

    function burnAll() public {
        burn(balances[msg.sender]);
    }

    function burnTokens(address _from, uint256 _value) private {
        require(balances[_from] >= _value);
        totalSupply -= _value;
        balances[_from] -= _value;
        emit BurnTokens(_from, _value);
    }

    function allowTransfer(bool _allowTransfer) public onlyIssuer {
        if (_allowTransfer == transferAllowed) {
            return;
        }
        transferAllowed = _allowTransfer;
        emit TransferAllowed(_allowTransfer);
    }

    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = safeAdd(allowed[msg.sender][_spender], _addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
        uint256 oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue >= oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue - _subtractedValue;
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function transfer(address _to, uint256 _value) public canTransfer(msg.sender, _to) returns (bool) {
        bool res = super.transfer(_to, _value);
        if (isPayable[_to]) IWinbixPayable(_to).catchWinbix(msg.sender, _value);
        processSpecialBalances(msg.sender, _to, _value);
        return res;
    }

    function transferFrom(address _from, address _to, uint256 _value) public canTransfer(_from, _to) returns (bool) {
        bool res = super.transferFrom(_from, _to, _value);
        if (isPayable[_to]) IWinbixPayable(_to).catchWinbix(makePayable(_from), _value);
        processSpecialBalances(_from, _to, _value);
        return res;
    }

    function processSpecialBalances(address _from, address _to, uint256 _value) private {
        if (_value == 0) return;
        if (balances[_to] == 0) {
            reduceSpecialBalances(_from, _value);
        } else {
            minimizeSpecialBalances(_from);
        }
    }

    function reduceSpecialBalances(address _address, uint256 _value) private {
        uint256 value = _value;
        if (value > votableBalances[_address]) {
            value = votableBalances[_address];
        }
        if (value > 0) {
            votableBalances[_address] -= value;
            votableTotal -= value;
            emit BurnVotable(_address, value);
        }
        value = _value;
        if (value > accruableBalances[_address]) {
            value = accruableBalances[_address];
        }
        if (value > 0) {
            accruableBalances[_address] -= value;
            accruableTotal -= value;
            emit BurnAccruable(_address, value);
        }
    }

    function minimizeSpecialBalances(address _address) private {
        uint256 delta;
        uint256 tokenBalance = balanceOf(_address);
        if (tokenBalance < votableBalances[_address]) {
            delta = votableBalances[_address] - tokenBalance;
            votableBalances[_address] = tokenBalance;
            votableTotal -= delta;
            emit BurnVotable(_address, delta);
        }
        if (tokenBalance < accruableBalances[_address]) {
            delta = accruableBalances[_address] - tokenBalance;
            accruableBalances[_address] = tokenBalance;
            accruableTotal -= delta;
            emit BurnAccruable(_address, delta);
        }
    }

    function setMePayable(bool _state) public onlyIssuer {
        if (isPayable[msg.sender] == _state) return;
        isPayable[msg.sender] = _state;
        emit SetPayable(msg.sender, _state);
    }
}