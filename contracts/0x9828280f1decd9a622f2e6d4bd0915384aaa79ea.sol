pragma solidity ^0.5.8;

interface ERC20 {
    function transfer(address _to, uint256 _value) external returns (bool);
}

contract Ownable {
    address public owner;
    
    event SetOwner(address _prev, address _new);
    
    constructor() public {
        emit SetOwner(owner, msg.sender);
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }
    
    function setOwner(address _owner) external onlyOwner {
        emit SetOwner(owner, _owner);
        owner = _owner;
    }
}

contract Lock is Ownable {
    uint256 public constant MAX_LOCK_JUMP = 86400 * 365; // 1 year

    uint256 public lock;

    event SetLock(uint256 _prev, uint256 _new);
    
    constructor() public {
        lock = now;
        emit SetLock(0, now);
    }
    
    modifier onUnlocked() {
        require(now >= lock, "Wallet locked");
        _;
    }
    
    function setLock(uint256 _lock) external onlyOwner {
        require(_lock > lock, "Can't set lock to past");
        require(_lock - lock <= MAX_LOCK_JUMP, "Max lock jump exceeded");
        emit SetLock(lock, _lock);
        lock = _lock;
    }

    function withdraw(ERC20 _token, address _to, uint256 _value) external onlyOwner onUnlocked returns (bool) {
        return _token.transfer(_to, _value);
    }
    
    function call(address payable _to, uint256 _value, bytes calldata _data) external onlyOwner onUnlocked returns (bool, bytes memory) {
        return _to.call.value(_value)(_data);
    }
}