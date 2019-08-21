pragma solidity ^0.4.25;

// ----------------------------------------------------------------------------
// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol
// ----------------------------------------------------------------------------
library SafeMath {
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(a >= b);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

// ----------------------------------------------------------------------------
// https://github.com/ethereum/EIPs/issues/179
// ----------------------------------------------------------------------------
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

// ----------------------------------------------------------------------------
// https://github.com/ethereum/EIPs/issues/20
// ----------------------------------------------------------------------------
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool); 
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    uint256 totalSupply_;
    mapping(address => uint256) balances;

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
}

// ----------------------------------------------------------------------------
// https://github.com/ethereum/EIPs/issues/20
// ----------------------------------------------------------------------------
contract StandardToken is ERC20, BasicToken {
    mapping(address => mapping(address => uint256)) internal allowed;

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = (allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
        uint256 oldValue = allowed[msg.sender][_spender];

        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } 
        else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}

// ----------------------------------------------------------------------------
// junil@cy2code.com
// ----------------------------------------------------------------------------
contract OwnableToken is StandardToken {
    uint256 public constant OPERATOR_MAX_COUNT = 10;
    uint256 public operatorCount;

    address public owner;
    address[OPERATOR_MAX_COUNT] public operator;
    mapping(address => string) operatorName;

    event ChangeOwner(address indexed prevOwner, address indexed newOwner);
    event AddOperator(address indexed Operator, string name);
    event RemoveOperator(address indexed Operator);

    constructor() public {
        owner = msg.sender;
        operatorCount = 0;

        for (uint256 i = 0; i < OPERATOR_MAX_COUNT; i++) {
            operator[i] = address(0);
        }
    }

    modifier onlyOwner() {
        require(msg.sender == owner); 
        _; 
    }
    
    modifier onlyOperator() {
        require(msg.sender == owner || checkOperator(msg.sender) == true);
        _;
    }
    
    function checkOperator(address _operator) private view returns (bool) {
        for (uint256 i = 0; i < OPERATOR_MAX_COUNT; i++) {
            if (_operator == operator[i]) {
                return true;
            }
        }

        revert();
    }

    function changeOwner(address _newOwner) external onlyOwner returns (bool) {
        require(_newOwner != address(0));
        
        emit ChangeOwner(owner, _newOwner);
        owner = _newOwner;
        return true;
    }

    function addOperator(address _newOperator, string _name) external onlyOwner returns (bool) {
        require(_newOperator != address(0));

        for (uint256 i = 0; i < OPERATOR_MAX_COUNT; i++) {
            if (_newOperator == operator[i]) {
                revert();
            }
        }        
        
        for (i = 0; i < OPERATOR_MAX_COUNT; i++) {
            if (operator[i] == address(0)) {
                operator[i] = _newOperator;
                operatorName[operator[i]] = _name;
                operatorCount++;

                emit AddOperator(_newOperator, _name);
                return true;
            }
        }

        revert();
    }

    function removeOperator(address _operator) external onlyOwner returns (bool) {
        for (uint256 i = 0; i < OPERATOR_MAX_COUNT; i++) {
            if (_operator == operator[i]) {
                operatorName[operator[i]] = "";
                operator[i] = address(0);
                operatorCount--;

                emit RemoveOperator(_operator);
                return true;
            }
        }        

        revert();
    }

    function getOperatorName(address _operator) external onlyOwner view returns (string) {
        return operatorName[_operator];
    }
}

// ----------------------------------------------------------------------------
// junil@cy2code.com
// ----------------------------------------------------------------------------
contract RestrictAmount is OwnableToken {
    mapping(address => uint256) public keepAmount;

    event LockAmount(address indexed addr, uint256 indexed amount);
    event DecLockAmount(address indexed addr, uint256 indexed amount);
    event UnlockAmount(address indexed addr);

    function lockAmount(address _address, uint256 _amount) external onlyOperator returns (bool) {
        keepAmount[_address] = _amount;

        if (_amount > 0) emit LockAmount(_address, _amount);
        else emit UnlockAmount(_address);
    }

    function decLockAmount(address _address, uint256 _amount) external onlyOperator returns (bool) {
        uint256 amount = _amount;
        if (amount > keepAmount[_address]) {
            amount = keepAmount[_address];
        }

        keepAmount[_address] = keepAmount[_address].sub(amount);
        emit DecLockAmount(_address, _amount);
    }
}

// ----------------------------------------------------------------------------
// junil@cy2code.com
// ----------------------------------------------------------------------------
contract LockAccount is OwnableToken {
    enum LOCK_STATE { unlock, lock, timeLock }

    struct lockInfo {
        LOCK_STATE lock;
        string reason;
        uint256 time;
    }

    mapping(address => lockInfo) lockAccount;

    event LockAddr(address indexed addr, string indexed reason, uint256 time);
    event UnlockAddr(address indexed addr);
    
    modifier checkLockAccount {
        if (   lockAccount[msg.sender].lock == LOCK_STATE.timeLock
            && lockAccount[msg.sender].time <= now ) {
            lockAccount[msg.sender].time = 0;
            lockAccount[msg.sender].reason = "";
            lockAccount[msg.sender].lock = LOCK_STATE.unlock;        
            emit UnlockAddr(msg.sender);
        }

        require(   lockAccount[msg.sender].lock != LOCK_STATE.lock
                && lockAccount[msg.sender].lock != LOCK_STATE.timeLock);
        _;
    }
    
    function lockAddr(address _address, string _reason, uint256 _untilTime) public onlyOperator returns (bool) {
        require(_address != address(0));
        require(_address != owner);
        require(_untilTime == 0 || _untilTime > now);

        if (_untilTime == 0) {
            lockAccount[_address].lock = LOCK_STATE.lock;
        }
        else {
            lockAccount[_address].lock = LOCK_STATE.timeLock;
        }
        
        lockAccount[_address].reason = _reason;
        lockAccount[_address].time = _untilTime;
        emit LockAddr(_address, _reason, _untilTime);
        return true;
    }
    
    function unlockAddr(address _address) public onlyOwner returns (bool) {
        lockAccount[_address].time = 0;
        lockAccount[_address].reason = "";
        lockAccount[_address].lock = LOCK_STATE.unlock;        
        emit UnlockAddr(_address);
        return true;
    } 

    function getLockInfo(address _address) public returns (LOCK_STATE, string, uint256) {
        if (
               lockAccount[_address].lock == LOCK_STATE.timeLock
            && lockAccount[_address].time <= now ) {
            lockAccount[_address].time = 0;
            lockAccount[_address].reason = "";
            lockAccount[_address].lock = LOCK_STATE.unlock;        
        }

        return (  lockAccount[_address].lock
                , lockAccount[_address].reason
                , lockAccount[_address].time );
    }
}

// ----------------------------------------------------------------------------
// junil@cy2code.com
// ----------------------------------------------------------------------------
contract TransferFromOperator is RestrictAmount, LockAccount {
    function transferToMany(address[] _to, uint256[] _value) onlyOperator checkLockAccount external returns (bool) {
        require(_to.length == _value.length);

        uint256 i;
        uint256 totValue = 0;
        for (i = 0; i < _to.length; i++) {
            require(_to[i] != address(0));
            totValue = totValue.add(_value[i]);
        }
        require(balances[msg.sender].sub(keepAmount[msg.sender]) >= totValue);

        for (i = 0; i < _to.length; i++) {
            balances[msg.sender] = balances[msg.sender].sub(_value[i]);
            balances[_to[i]] = balances[_to[i]].add(_value[i]);
            emit Transfer(msg.sender, _to[i], _value[i]);
        }

        return true;
    }

    function transferFromOperator(address _to, uint256 _value) onlyOperator checkLockAccount public returns (bool) {
        require(_to != address(0));
        require(balances[msg.sender].sub(keepAmount[msg.sender]) >= _value);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
}

// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
contract Pausable is OwnableToken {
    bool public paused = false;

    event Pause();
    event Unpause();

    modifier whenNotPaused() {
        require(!paused); 
        _; 
    }
    
    modifier whenPaused() {
        require(paused); 
        _; 
    }

    function pause() external onlyOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    function unpause() external onlyOwner whenPaused {
        paused = false;
        emit Unpause();
    }
}

// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
contract ControlledToken is Pausable, TransferFromOperator
{
    function transfer(address _to, uint256 _value) public whenNotPaused checkLockAccount returns (bool) {
        require(balances[msg.sender].sub(keepAmount[msg.sender]) >= _value);
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused checkLockAccount returns (bool) {
        require(balances[_from].sub(keepAmount[_from]) >= _value);
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public whenNotPaused checkLockAccount onlyOperator returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint256 _addedValue) public whenNotPaused checkLockAccount onlyOperator returns (bool) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public whenNotPaused checkLockAccount onlyOperator returns (bool) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}

// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
contract Burnable is OwnableToken {
    event Burn(address indexed burner, uint256 value);

    function burn(uint256 _value) onlyOwner public {
        require(_value <= balances[owner]);

        balances[owner] = balances[owner].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Transfer(owner, address(0), _value);
        emit Burn(msg.sender, _value);
    }
}

// ----------------------------------------------------------------------------
// https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
// ----------------------------------------------------------------------------
contract Mintable is OwnableToken {
    bool public mintingFinished = false;

    event Mint(address indexed to, uint256 value);
    event MintFinished();

    modifier canMint() {
        require(!mintingFinished); 
        _; 
    }

    function mint(address _to, uint256 _value) onlyOwner canMint public returns (bool) {
        require(_to != address(0));

        totalSupply_ = totalSupply_.add(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(address(0), _to, _value);
        emit Mint(_to, _value);
        return true;
    }

    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }
}

// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
contract ManageSupplyToken is Mintable, Burnable {
    /* ... */
}

// ----------------------------------------------------------------------------
// junil@cy2code.com
// ----------------------------------------------------------------------------
contract PPCToken is ControlledToken, ManageSupplyToken {
    uint256 private constant INIT_SUPPLY = 1900000000;
    string public name = "PHILLIPS PAY COIN";
    string public symbol = "PPC";
    uint256 public decimals = 1;
    uint256 public initSupply = INIT_SUPPLY * (10 ** uint(decimals));

    constructor() payable public {
        totalSupply_ = initSupply;
        balances[msg.sender] = totalSupply_;
        emit Transfer(0x0, msg.sender, totalSupply_);
    }
}