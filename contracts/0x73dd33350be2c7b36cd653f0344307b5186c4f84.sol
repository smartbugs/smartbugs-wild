pragma solidity ^0.5.0;

library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _burnFrom(address account, uint256 value) internal {
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }
}

contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Pausable is Ownable {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    modifier whenPaused() {
        require(_paused);
        _;
    }

    function pause() public onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function unpause() public onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

contract ERC20Pausable is ERC20, Pausable {
    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transfer(to, value);
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint addedValue) public whenNotPaused returns (bool success) {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint subtractedValue) public whenNotPaused returns (bool success) {
        return super.decreaseAllowance(spender, subtractedValue);
    }
}

contract RAID is ERC20Pausable, ERC20Detailed {
    string internal constant INVALID_TOKEN_VALUES = "Invalid token values";
    string internal constant NOT_ENOUGH_TOKENS = "Not enough tokens";
    string internal constant ALREADY_LOCKED = "Tokens already locked";
    string internal constant NOT_LOCKED = "No tokens locked";
    string internal constant AMOUNT_ZERO = "Amount can not be 0";
    string internal constant EXPIRED_ADDRESS = "Expired Address";

    uint256 public constant INITIAL_SUPPLY = 100000000000 * (10 ** uint256(18));

    mapping(address => bytes32[]) public lockReason;

    struct lockToken {
        uint256 amount;
        uint256 validity;
        bool claimed;
    }

    mapping(address => mapping(bytes32 => lockToken)) public locked;

    event Locked(address indexed _of, bytes32 indexed _reason, uint256 _amount, uint256 _validity);
    event Unlocked(address indexed _of, bytes32 indexed _reason, uint256 _amount);

    event RemoveLock(address indexed _of, bytes32 indexed _reason, uint256 _amount, uint256 _validity);
    event RemoveExpired(address indexed _of, uint256 _amount, uint256 _validity);

    constructor ()
    ERC20Detailed ("RAID", "RAID", 18)
    public {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    // ERC20 회수
    function claimToken(ERC20 token, address _to, uint256 _value) public onlyOwner returns (bool) {
        token.transfer(_to, _value);
        return true;
    }

    // 특정 Account에 지정된 기간동안 락업된 토큰을 전송
    function transferWithLock(address _to, bytes32 _reason, uint256 _amount, uint256 _time) public onlyOwner returns (bool) {
        uint256 validUntil = now.add(_time);

        require(tokensLocked(_to, _reason) == 0, ALREADY_LOCKED);
        require(_amount != 0, AMOUNT_ZERO);

        if (locked[_to][_reason].amount == 0)
            lockReason[_to].push(_reason);

        transfer(address(this), _amount);

        locked[_to][_reason] = lockToken(_amount, validUntil, false);
        
        emit Locked(_to, _reason, _amount, validUntil);
        return true;
    }

    // 락업 정보 삭제
    function removeLock(address _of, bytes32 _reason) public onlyOwner returns (bool deleted) {
        require(!locked[_of][_reason].claimed, EXPIRED_ADDRESS);
        this.transfer(_of, locked[_of][_reason].amount);
        delete locked[_of][_reason];
        
        emit RemoveLock(_of, _reason, locked[_of][_reason].amount, locked[_of][_reason].validity);
        return true;
    }

    // // 만료된 락업 정보 삭제
    function removeExpired(address _of) public onlyOwner returns (bool deleted) {
        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            if (locked[_of][lockReason[_of][i]].claimed) {
                delete locked[_of][lockReason[_of][i]];
                emit RemoveExpired(_of, locked[_of][lockReason[_of][i]].amount, locked[_of][lockReason[_of][i]].validity);
                deleted = true;
            }
        }
        return deleted;
    }

    // 특정 Account의 토큰을 지정된 기간동안 락업
    function lock(bytes32 _reason, uint256 _amount, uint256 _time, address _of) public onlyOwner returns (bool) {
        uint256 validUntil = now.add(_time);

        require(_amount <= _balances[_of], NOT_ENOUGH_TOKENS);
        require(tokensLocked(_of, _reason) == 0, ALREADY_LOCKED);
        require(_amount != 0, AMOUNT_ZERO);

        if (locked[_of][_reason].amount == 0)
            lockReason[_of].push(_reason);

        _balances[address(this)] = _balances[address(this)].add(_amount);
        _balances[_of] = _balances[_of].sub(_amount);
        locked[_of][_reason] = lockToken(_amount, validUntil, false);

        emit Locked(_of, _reason, _amount, validUntil);
        return true;
    }

    // 특정 Account의 사유에 대해 락업 잔액 확인
    function tokensLocked(address _of, bytes32 _reason) public view returns (uint256 amount) {
        if (!locked[_of][_reason].claimed)
            amount = locked[_of][_reason].amount;
    }

    // 특정 Account, 사유, 시간에 대해 락업 잔액 확인
    function tokensLockedAtTime(address _of, bytes32 _reason, uint256 _time) public view returns (uint256 amount) {
        if (locked[_of][_reason].validity > _time)
            amount = locked[_of][_reason].amount;
    }

    // 특정 Account의 총 락업 잔액 확인
    function totalBalanceOf(address _of) public view returns (uint256 amount) {
        amount = balanceOf(_of);

        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            amount = amount.add(tokensLocked(_of, lockReason[_of][i]));
        }   
    }    

    // 사유에 대한 락업 기간을 연장
    function extendLock(bytes32 _reason, uint256 _time, address _of) public onlyOwner returns (bool) {
        require(tokensLocked(_of, _reason) > 0, NOT_LOCKED);

        locked[_of][_reason].validity = locked[_of][_reason].validity.add(_time);

        emit Locked(_of, _reason, locked[_of][_reason].amount, locked[_of][_reason].validity);
        return true;
    }

    // 사유에 대해 소유자 수량을 보내어 락업 수량 추가
    function increaseLockAmount(bytes32 _reason, uint256 _amount, address _of) public onlyOwner returns (bool) {
        require(tokensLocked(_of, _reason) > 0, NOT_LOCKED);
        transfer(address(this), _amount);

        locked[_of][_reason].amount = locked[_of][_reason].amount.add(_amount);

        emit Locked(_of, _reason, locked[_of][_reason].amount, locked[_of][_reason].validity);
        return true;
    }

    // 특정 Account의 사유에 대해 만료된 락업 잔액 확인
    function tokensUnlockable(address _of, bytes32 _reason) public view returns (uint256 amount) {
        if (locked[_of][_reason].validity <= now && !locked[_of][_reason].claimed)
            amount = locked[_of][_reason].amount;
    }

    // 특정 Account에 락업된 토큰을 모두 언락
    function unlock(address _of) public onlyOwner returns (uint256 unlockableTokens) {
        uint256 lockedTokens;

        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            lockedTokens = tokensUnlockable(_of, lockReason[_of][i]);
            if (lockedTokens > 0) {
                unlockableTokens = unlockableTokens.add(lockedTokens);
                locked[_of][lockReason[_of][i]].claimed = true;
                emit Unlocked(_of, lockReason[_of][i], lockedTokens);
            }
        }  

        if (unlockableTokens > 0)
            this.transfer(_of, unlockableTokens);
    }

    // 특정 Account에 언락 가능한 총 토큰 잔액
    function getUnlockableTokens(address _of) public view returns (uint256 unlockableTokens) {
        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            unlockableTokens = unlockableTokens.add(tokensUnlockable(_of, lockReason[_of][i]));
        }  
    }
}