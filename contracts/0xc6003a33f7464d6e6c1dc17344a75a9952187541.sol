pragma solidity ^0.5.0;


library ECRecovery {

  /**
   * @dev Recover signer address from a message by using his signature
   * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
   * @param sig bytes signature, the signature is generated using web3.eth.sign()
   */
  function recover(bytes32 hash, bytes memory sig) public pure returns (address) {
    bytes32 r;
    bytes32 s;
    uint8 v;

    //Check the signature length
    if (sig.length != 65) {
      return (address(0));
    }

    // Divide the signature in r, s and v variables
    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
    }

    // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
    if (v < 27) {
      v += 27;
    }

    // If the version is correct return the signer address
    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      return ecrecover(hash, v, r, s);
    }
  }
} 


/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}



library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
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
    mapping (address => mapping (address => uint256)) internal _allowances;
    uint256 internal _totalSupply;

    constructor() internal {
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address who) public view returns (uint256) {
        return _balances[who];
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowances[from][msg.sender].sub(value));
        return true;
    }

    function _transfer(address _from, address to, uint256 value) internal {
        require(_from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _balances[_from] = _balances[_from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(_from, to, value);
    }

    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

}

contract Ownable {
    address public owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    using SafeMath for uint256;
    uint256 public startdate;

    constructor() internal {
        owner = msg.sender;
        startdate = now;
    }

    modifier onlyOwner() {
        require(msg.sender == owner,"Ownable: caller is not owner.");
        _;
    }

    function transferOwnership(address newOwner) public;

    function _transferOwnership(address newOwner) internal onlyOwner {
        require(newOwner != address(0), "Ownable: address is zero.");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role.");
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function renounceMinter() public;

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

contract Mintable is MinterRole{
     uint256 private _cap;
     event Mint(address indexed minter, address receiver, uint256 value);

    constructor (uint256 cap) internal {
        require(cap > 0, "ERC20Capped: cap is 0");
        _cap = cap;
    }

    function renounceMinter() public;

    function addMinter(address minter) public;

    function removeMinter(address minter) public;

    function cap() public view returns (uint256) {
        return _cap;
    }

    function mint(address to, uint256 value) public onlyMinter returns (bool) {
        _mint(to, value);
        emit Mint(msg.sender, to, value);
        return true;
    }

    function _mint(address account, uint256 value) internal;
}

contract Pausable {
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
        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    function _unpause() internal whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }

    function pause() public;
    function unpause() public;
}

contract Burnable {
    event Burn(address burner, uint256 value);

    constructor () internal {}
    function burn(address account, uint256 value) public;

    function _burn(address account, uint256 value) internal{
        emit Burn(account, value);
    }
}

contract Lockable {
    uint256 internal _totalLocked = 0;
    event Lock(address beneficiary, uint256 amount, uint256 releaseTime);

    mapping(address => uint256) internal _lock_list_period;
    mapping(address => bool) internal _lock_list;
    mapping(address => uint256) internal _revocable;

    modifier notLocked() {
        require(_lock_list[msg.sender] == true, "Lockable: sender address is locked.");
        _;
    }

    function totalLocked() public view returns (uint256){
        return _totalLocked;
    }

    function mintLockedToken(address addr, uint256 tokens, uint256 _duration) public;

    function releaseLockedToken() public returns (bool);

    function isLocked(address addr) public view returns (bool) {
        return _lock_list[addr];
    }

    function lockedPeriod(address addr) public view returns (uint256) {
        return _lock_list_period[addr];
    }

    function lockedBalance(address addr) public view returns (uint256) {
        return _revocable[addr];
    }
}

contract DelegatorRole {
    using Roles for Roles.Role;

    event DelegatorAdded(address indexed account);
    event DelegatorRemoved(address indexed account);

    Roles.Role private _delegators;

    constructor () internal {
        _addDelegator(msg.sender);
    }

    modifier onlyDelegator() {
        require(isDelegator(msg.sender), "DelegatorRole: caller does not have the Delegator role.");
        _;
    }

    function isDelegator(address account) public view returns (bool) {
        return _delegators.has(account);
    }

    function renounceDelegator() public;

    function _addDelegator(address account) internal {
        _delegators.add(account);
        emit DelegatorAdded(account);
    }

    function _removeDelegator(address account) internal {
        _delegators.remove(account);
        emit DelegatorRemoved(account);
    }
}

contract Delegatable is DelegatorRole{
    using ECRecovery for bytes32;
    using SafeMath for uint;

    uint16 private _feeRate;
    address private _feeCollector;
    mapping(address => uint256) internal _nonces;
    event Delegated(address delegator, address sender, address receiver, uint256 value, uint256 nonce);

    constructor () internal{
        _feeRate = 10; //0.01%
        _feeCollector = msg.sender;
    }

    function setFeeRate(uint16 _rate) public;

    function setFeeCollector(address _collector) public;

    function addDelegator(address minter) public;

    function removeDelegator(address minter) public;

    function renounceDelegator() public;

    function _setFeeRate(uint16 _rate) internal{
        _feeRate = _rate;
    }

    function _setFeeCollector(address _collector) internal{
        _feeCollector = _collector;
    }

    function feeRate() public view returns (uint16){
        return _feeRate;
    }

    function feeCollector() public view returns (address){
        return _feeCollector;
    }

    function nonceOf(address _addr) public view returns (uint256 nonce){
        return _nonces[_addr];
    }

    function _delegatedTransfer(address _from, address _to, uint256 _value, uint256 _fee) internal returns(bool success);

    function delegatedTransfer(address _from, address _to, uint256 _value, uint256 _nonce, bytes calldata _signature) external onlyDelegator returns(bool success){
        require(_nonce == nonceOf(_from), "Delegatable: nonce is not correct");

        bytes32 hash = keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            keccak256(abi.encodePacked(_from, _to, _value, _nonce)))
        );
        address sender = hash.recover(_signature);

        // fee
        uint _fee = _value.mul(_feeRate).div(uint(100000));

        if(_from == sender){
            if(_delegatedTransfer(_from, _to, _value, _fee)){
                uint256 newNonce = nonceOf(_from).add(uint256(1));
                _nonces[_from] = newNonce;
                emit Delegated(msg.sender, _from, _to, _value, newNonce);
                return true;
            }
            else{
                return false;
            }
        } else {
            return false;
        }
    }
}

contract TrustShoreToken is ERC20, Ownable, Mintable, Pausable, Burnable, Lockable, Delegatable{
    string private _name = "TrustShore";
    string private _symbol = "TST";
    uint8 private _decimals = 18;

    constructor (uint256 cap) public Mintable(cap){
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

    //Override Mintable
    function _mint(address account, uint256 value) internal {
        require(account != address(0), "Mintable: mint to the zero address.");
        require(totalSupply().add(value).add(totalLocked()) <= cap(), "Mintable: cap exceeded.");

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    function renounceMinter() public {
        require(msg.sender != owner, "Mintable: Owner cannot renounce. Transfer owner first.");
        super._removeMinter(msg.sender);
    }

    function addMinter(address minter) public onlyOwner{
        super._addMinter(minter);

    }

    function removeMinter(address minter) public onlyOwner{
        super._removeMinter(minter);
    }

    //Override Ownerble
    function transferOwnership(address newOwner) public{
        require(msg.sender == owner, "Ownable: only owner transfer ownership");
        addMinter(newOwner);
        addDelegator(newOwner);
        removeMinter(owner);
        removeDelegator(owner);
        super._transferOwnership(newOwner);
    }

    //Override Pausable
    function pause() public onlyOwner {
        require(!paused(), "Pausable: Already paused.");
        super._pause();
    }

    function unpause() public onlyOwner {
        require(paused(), "Pausable: Not paused.");
        super._unpause();
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(!paused(), "Pausable: token transfer is paused.");
        super._transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        require(value > 0, "transferFrom: value is must be greater than zero.");
        require(balanceOf(from) >= value, "transferFrom: balance of from address is not enough");
        require(_allowances[from][msg.sender] >= value, "transferFrom: sender are not allowed to send.");

        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        return super.approve(spender, value);
    }

    //Override Burnable
    function burn(address account, uint256 value) public onlyOwner {
        require(account != address(0), "Burnable: burn from the zero address");
        require(_balances[account] >= value, "Burnable: not enough tokens");
        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        super._burn(account, value);
        emit Transfer(account, address(0), value);
    }

    //Apply SafeTransfer
    function safeTransfer(address to, uint256 value) public {
        require(!_isContract(to),"SafeTransfer: receiver is contract");
        transfer(to,value);
    }

    function safeTransferFrom(address from, address to, uint256 value) public {
        require(!_isContract(from),"SafeTransfer: sender is contract");
        require(!_isContract(to),"SafeTransfer: receiver is contract");
        transferFrom(from, to, value);
    }

    function safeApprove(address spender, uint256 value) public {
        require(value != 0, "SafeTransfer: approve from non-zero to non-zero allowance");
        require(!_isContract(spender),"SafeTransfer: spender is contract");
        approve(spender, value);
    }

    function _isContract(address _addr) private view returns (bool is_contract){
        uint length;
        assembly {
            length := extcodesize(_addr)
        }
        return (length>0);
    }

    //Override Lockable
    function mintLockedToken(address addr, uint256 tokens, uint256 _duration) public {
        require(msg.sender == owner, "Lockable: only owner can lock token ");
        require(_totalSupply.add(totalLocked()).add(tokens) <= cap(), "Lockable: locked tokens can not exceed total cap.");
        require(_lock_list[addr] == false, "Lockable: this address is already locked");

        uint256 releaseTime = block.timestamp.add(_duration.mul(1 minutes));

        //if(_lock_list[addr] == true) {
        //    _totalLocked.sub(_revocable[addr]);
        //}

        _lock_list_period[addr] = releaseTime;
        _lock_list[addr] = true;
        _revocable[addr] = tokens;
        _totalLocked = _totalLocked.add(tokens);

        emit Lock(addr, tokens, releaseTime);
    }

    function releaseLockedToken() public returns (bool) {
        require(_lock_list[msg.sender] == true);
        require(_revocable[msg.sender] > 0);

        uint256 releaseTime = _lock_list_period[msg.sender];
        uint256 currentTime = block.timestamp;

        if(currentTime > releaseTime) {
            uint256 tokens = _revocable[msg.sender];

            _lock_list_period[msg.sender] = 0;
            _lock_list[msg.sender] = false;
            _revocable[msg.sender] = 0;
            _totalSupply = _totalSupply.add(tokens);
            _balances[msg.sender] = _balances[msg.sender].add(tokens);
            return true;
        } else {
            return false;
        }
    }

    //Override Delegatable
    function setFeeRate(uint16 _rate) public{
        require(msg.sender == owner, "Delegatable: only owner change the fee rate");
        _setFeeRate(_rate);
    }

    function setFeeCollector(address _collector) public{
        require(msg.sender == owner, "Delegatable: only owner change the fee collector");
        _setFeeCollector(_collector);
    }

    function renounceDelegator() public {
        require(msg.sender != owner, "Delegatable : Owner cannot renounce. Transfer owner first.");
        super._removeDelegator(msg.sender);
    }

    function _delegatedTransfer(address _from, address _to, uint256 _value, uint256 _fee) internal returns(bool success){
        uint _amount = _value.add(_fee);

        if (balanceOf(_from) < _amount)
            return false;
        _balances[_from] = balanceOf(_from).sub(_amount);
        _balances[_to] = balanceOf(_to).add(_value);
        _balances[feeCollector()] = balanceOf(feeCollector()).add(_fee);
        emit Transfer(_from, _to, _value);
        emit Transfer(_from, feeCollector(), _fee);
        return true;
    }

    function addDelegator(address delegator) public onlyOwner{
        super._addDelegator(delegator);

    }

    function removeDelegator(address delegator) public onlyOwner{
        super._removeDelegator(delegator);
    }
}