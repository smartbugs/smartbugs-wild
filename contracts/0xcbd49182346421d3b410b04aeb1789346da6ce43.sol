pragma solidity ^0.5.0;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Ownable {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
        newOwner = address(0);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    modifier onlyNewOwner() {
        require(msg.sender != address(0));
        require(msg.sender == newOwner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0));
        newOwner = _newOwner;
    }

    function acceptOwnership() public onlyNewOwner returns(bool) {
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}

contract ERC20 {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function allowance(address owner, address spender) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract GrabityCoin is ERC20, Ownable, Pausable {

    using SafeMath for uint256;

    struct LockupInfo {
        uint256 releaseTime;
        uint256 lockupBalance;
        uint256 termOfMonth;
    }

    string public name;
    string public symbol;
    uint8 constant public decimals =18;
    uint256 internal initialSupply;
    uint256 internal totalSupply_;
    uint256 internal mintCap;

    mapping(address => uint256) internal balances;
    mapping(address => bool) internal locks;
    mapping(address => bool) public frozen;
    mapping(address => mapping(address => uint256)) internal allowed;
    mapping(address => LockupInfo[]) internal lockupInfo;
    
    uint256[36] internal unlockPeriodUnixTimeStamp;
    
    address implementation;

    event Lock(address indexed holder, uint256 value);
    event Unlock(address indexed holder, uint256 value);
    event Burn(address indexed owner, uint256 value);
    event Mint(uint256 value);
    event Freeze(address indexed holder);
    event Unfreeze(address indexed holder);

    modifier notFrozen(address _holder) {
        require(!frozen[_holder]);
        _;
    }

    constructor() public {
        name = "Grabity Coin";
        symbol = "GBT";
        initialSupply = 10000000000; // 10,000,000,000개
        totalSupply_ = initialSupply * 10 ** uint(decimals);
        mintCap = 10000000000 * 10 ** uint(decimals); //10,000,000,000
        balances[owner] = totalSupply_;
        
        unlockPeriodUnixTimeStamp = [
                1559347200, 1561939200, 1564617600, 1567296000, 1569888000, 1572566400, 1575158400, 
                1577836800, 1580515200, 1583020800, 1585699200, 1588291200, 1590969600, 1593561600, 1596240000, 1598918400, 1601510400, 1604188800, 1606780800,
                1609459200, 1612137600, 1614556800, 1617235200, 1619827200, 1622505600, 1625097600, 1627776000, 1630454400, 1633046400, 1635724800, 1638316800,
                1640995200, 1643673600, 1646092800, 1648771200, 1651363200
            ];

        emit Transfer(address(0), owner, totalSupply_);
    }

    function () payable external {
        address impl = implementation;
        require(impl != address(0));
        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, impl, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)
            
            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
        }
    }
    function _setImplementation(address _newImp) internal {
        implementation = _newImp;
    }
    
    function upgradeTo(address _newImplementation) public onlyOwner {
        require(implementation != _newImplementation);
        _setImplementation(_newImplementation);
    }

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function transfer(address _to, uint256 _value) public whenNotPaused notFrozen(msg.sender) returns (bool) {
        if (locks[msg.sender]) {
            autoUnlock(msg.sender);
        }
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
     function multiTransfer(address[] memory _toList, uint256[] memory _valueList) public whenNotPaused notFrozen(msg.sender) returns(bool){
        if(_toList.length != _valueList.length){
            revert();
        }
        
        for(uint256 i = 0; i < _toList.length; i++){
            transfer(_toList[i], _valueList[i]);
        }
        
        return true;
    }
    
     function multiTransferWithLockup(address[] memory _toList, uint256[] memory _dateIndex, uint256[] memory _valueList, uint256[] memory _termOfMonthList) public onlyOwner returns(bool){
        if((_toList.length != _valueList.length) || (_valueList.length != _termOfMonthList.length)){
            revert();
        }
        
        for(uint256 i = 0; i < _toList.length; i++){
            distribute(_toList[i], _valueList[i]);
        
            lockupAsTermOfMonth(_toList[i], _dateIndex[i], _valueList[i], _termOfMonthList[i]);
        }
        
        return true;
    }
    
    function balanceOf(address _holder) public view returns (uint256 balance) {
        uint256 lockedBalance = 0;
        if(locks[_holder]) {
            for(uint256 idx = 0; idx < lockupInfo[_holder].length ; idx++ ) {
                lockedBalance = lockedBalance.add(lockupInfo[_holder][idx].lockupBalance);
            }
        }
        return balances[_holder] + lockedBalance;
    }
    
    function currentBalanceOf(address _holder) public view returns(uint256 balance){
        uint256 unlockedBalance = 0;
        if(locks[_holder]){
            for(uint256 idx =0; idx < lockupInfo[_holder].length; idx++){
                if( lockupInfo[_holder][idx].releaseTime <= now){
                    unlockedBalance = unlockedBalance.add(lockupInfo[_holder][idx].lockupBalance);
                }
            }
        }
        return balances[_holder] + unlockedBalance;
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused notFrozen(_from)returns (bool) {
        if (locks[_from]) {
            autoUnlock(_from);
        }
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));
        allowed[msg.sender][spender] = (allowed[msg.sender][spender].add(addedValue));

        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    function decreaseAllowance( address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));
        allowed[msg.sender][spender] = (allowed[msg.sender][spender].sub(subtractedValue));

        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    function allowance(address _holder, address _spender) public view returns (uint256) {
        return allowed[_holder][_spender];
    }

    function lock(address _holder, uint256 _releaseStart, uint256 _amount, uint256 _termOfMonth) public onlyOwner returns(bool){
        require(balances[_holder] >= _amount);
        balances[_holder] = balances[_holder].sub(_amount);
        
        lockupInfo[_holder].push(
            LockupInfo(_releaseStart, _amount, _termOfMonth)    
        );
        
        locks[_holder] = true;
        
        emit Lock(_holder, _amount);
        
        return true;
        
    }

    function _unlock(address _holder, uint256 _idx) internal returns (bool) {
        require(locks[_holder]);
        require(_idx < lockupInfo[_holder].length);
        LockupInfo storage lockupinfo = lockupInfo[_holder][_idx];
        uint256 releaseAmount = lockupinfo.lockupBalance;
        
        delete lockupInfo[_holder][_idx];
        
        lockupInfo[_holder][_idx] = lockupInfo[_holder][lockupInfo[_holder].length.sub(1)];
        
        lockupInfo[_holder].length -= 1;
        
        if(lockupInfo[_holder].length == 0){
            locks[_holder] = false;
        }
        
        emit Unlock(_holder, releaseAmount);
        balances[_holder] = balances[_holder].add(releaseAmount);
        
        return true;
    }

    function unlock(address _holder, uint256 _idx) public onlyOwner returns (bool) {
        _unlock(_holder, _idx);
    }

    function freezeAccount(address _holder) public onlyOwner returns (bool) {
        require(!frozen[_holder]);
        frozen[_holder] = true;
        emit Freeze(_holder);
        return true;
    }

    function unfreezeAccount(address _holder) public onlyOwner returns (bool) {
        require(frozen[_holder]);
        frozen[_holder] = false;
        emit Unfreeze(_holder);
        return true;
    }

    function getNowTime() public view returns(uint256) {
        return now;
    }

    function showLockState(address _holder, uint256 _idx) public view returns (bool, uint256, uint256, uint256, uint256) {
        if(locks[_holder]) {
            return (
                locks[_holder],
                lockupInfo[_holder].length,
                lockupInfo[_holder][_idx].releaseTime,
                lockupInfo[_holder][_idx].lockupBalance,
                lockupInfo[_holder][_idx].termOfMonth
            );
        } else {
            return (
                locks[_holder],
                lockupInfo[_holder].length,
                0,0,0
            );

        }
    }
    
    function lockupAsTermOfMonth(address _holder, uint256 _dateIndex, uint256 _amount, uint256 _termOfMonth) internal returns (bool) {
        if(_termOfMonth == 0){
            lock(_holder, unlockPeriodUnixTimeStamp[_dateIndex], _amount, _termOfMonth);
        }else{
            uint256 lockupAmountPerRatio = _amount /  _termOfMonth;
            uint256 lockupAmountRemainder = _amount % _termOfMonth;
            
            for(uint256 i=0; i < _termOfMonth; i++){
                if(i != _termOfMonth - 1){
                    lock(_holder, unlockPeriodUnixTimeStamp[_dateIndex+i], lockupAmountPerRatio, _termOfMonth);
                }else{
                    lock(_holder, unlockPeriodUnixTimeStamp[_dateIndex+i], lockupAmountPerRatio+lockupAmountRemainder, _termOfMonth);
                }
            }
        }
        return true;
    }

    function distribute(address _to, uint256 _value) public onlyOwner returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function distributeWithLockup(address _holder, uint256 _dateIndex, uint256 _amount, uint256 _termOfMonth) public onlyOwner returns (bool) {
        distribute(_holder, _amount);
    
        lockupAsTermOfMonth(_holder, _dateIndex, _amount, _termOfMonth);
        return true;
    }
    
    function claimToken(ERC20 token, address _to, uint256 _value) public onlyOwner returns (bool) {
        token.transfer(_to, _value);
        return true;
    }

    function burn(uint256 _value) public onlyOwner returns (bool success) {
        require(_value <= balances[msg.sender]);
        address burner = msg.sender;
        balances[burner] = balances[burner].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        emit Burn(burner, _value);
        emit Transfer(burner, address(0), _value);
        return true;
    }

    function mint(address _to, uint256 _amount) onlyOwner public returns (bool) {
        require(mintCap >= totalSupply_.add(_amount));
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

     function autoUnlock(address _holder) internal returns(bool){
        if(locks[_holder] == false){
            return true;
        }
        
        for(uint256 idx = 0; idx < lockupInfo[_holder].length; idx++){
            if(lockupInfo[_holder][idx].releaseTime <= now)
            {
                if(_unlock(_holder, idx)){
                    idx -= 1;
                }
            }
        }
        return true;
    }
}