pragma solidity ^0.5.0;

// File: openzeppelin-solidity/contracts/access/Roles.sol

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

// File: openzeppelin-solidity/contracts/access/roles/PauserRole.sol

contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender));
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
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
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
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
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: contracts/AlkionToken.sol

/**
 * @title Alkion Token
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */
contract AlkionToken is Pausable, Ownable {
  	using SafeMath for uint256;
  	
	string internal constant ALREADY_LOCKED = 'Tokens already locked';
	string internal constant NOT_LOCKED = 'No tokens locked';
	string internal constant AMOUNT_ZERO = 'Amount can not be 0';
	string internal constant NOT_OWNER = 'You are not owner';
	string internal constant NOT_ADMIN = 'You are not admin';
	string internal constant NOT_ENOUGH_TOKEN = 'Not enough token';
	string internal constant NOT_ENOUGH_ALLOWED = 'Not enough allowed';
	string internal constant INVALID_TARGET_ADDRESS = 'Invalid target address';
	string internal constant UNABLE_DEPOSIT = 'Unable to deposit';

	string 	public constant name 		= "Alkion Token";
	string 	public constant symbol 		= "ALK";
	uint8 	public constant decimals 	= 18;
  
	uint256 internal constant INITIAL_SUPPLY = 50000000000 * (10 ** uint256(decimals));
	    
    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowed;

    uint256 internal _totalSupply;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);    		
	
	// -----
	
	mapping(address => bytes32[]) internal lockReason;
	
	uint256 internal sellingTime = 99999999999999;

    struct lockToken {
        uint256 amount;
        uint256 validity;
        bool claimed;
    }
    
    mapping(address => mapping(bytes32 => lockToken)) internal locked;
        
    event Locked(
        address indexed _of,
        bytes32 indexed _reason,
        uint256 _amount,
        uint256 _validity
    );

    event Unlocked(
        address indexed _of,
        bytes32 indexed _reason,
        uint256 _amount
    );
    
    // --
    
	modifier onlyOwner() {
		require(isOwner(), NOT_OWNER);
		_;
	}
	
	// --
  
	constructor() 
		public 
	{	
		_mint(msg.sender, INITIAL_SUPPLY);	
	}
		
	function startSelling(uint256 _time)
		onlyOwner
		public 
	{
		require(_time != 0);
		sellingTime = _time;
	}
	
	function whenSelling()
		public
		view
		returns (uint256) 	
	{
		if(!isOwner()) return 0;
		return sellingTime;
	}
	
    function totalSupply() 
    	public 
    	view 
    	returns (uint256) 
    {
        return _totalSupply;
    }

    function balanceOf(address owner) 
    	public 
    	view 
    	returns (uint256 amount) 
    {
        amount = _balances[owner];
        for (uint256 i = 0; i < lockReason[owner].length; i++) {
            amount = amount.add(tokensLocked(owner, lockReason[owner][i]));
        }        
    }
    
    function lockedBalanceOf(address _of)
        public
        view
        returns (uint256 amount)
    {
        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            amount = amount.add(tokensLocked(_of, lockReason[_of][i]));
        }
    }    

    function allowance(address owner, address spender) 
    	public 
    	view 
    	returns (uint256) 
    {
        return _allowed[owner][spender];
    }	
	
	function approve(address spender, uint256 value)
		whenNotPaused 
		public 
		returns (bool) 
	{
        require(spender != address(0));
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;		
	}
		
	function transferFrom(address from, address to, uint256 value)
		whenNotPaused 
		public 
		returns (bool) 
	{
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;		
	}	

	function transfer(address to, uint256 value)
		whenNotPaused
		public
		returns (bool) 
	{
        _transfer(msg.sender, to, value);
        return true;		
	}
	
    function transferWithLock(address _from, address _to, bytes32 _reason, uint256 _amount, uint256 _time)
    	whenNotPaused
    	onlyOwner
        public
        returns (bool)
    {	        
	    require(_amount <= _balances[_from], NOT_ENOUGH_TOKEN);
	    require(_to != address(0), INVALID_TARGET_ADDRESS);
        require(tokensLocked(_to, _reason) == 0, ALREADY_LOCKED);	            
        require(_amount != 0, AMOUNT_ZERO);
            
        uint256 validUntil = _time; 

        if (locked[_to][_reason].amount == 0)
            lockReason[_to].push(_reason);
	
	    _balances[_from] = _balances[_from].sub(_amount);
        locked[_to][_reason] = lockToken(_amount, validUntil, false);
        
        emit Locked(_to, _reason, _amount, validUntil);
        return true;
    }
    
    function transferCancelWithLock(address _from, address _to, bytes32 _reason)
        whenNotPaused
        onlyOwner
        public
        returns (bool)
    {
    	uint256 l = tokensLocked(_from, _reason);
		require(l > 0, NOT_LOCKED);
		
		locked[_from][_reason].claimed = true;
		_balances[_to] = _balances[_to].add(l);
		return true;
    }
    
    function tokensLocked(address _of, bytes32 _reason)
        public
        view
        returns (uint256 amount)
    {
        if (!locked[_of][_reason].claimed)
            amount = locked[_of][_reason].amount;
    }    
    
    function tokensLockedAtTime(address _of, bytes32 _reason, uint256 _time)
        public
        view
        returns (uint256 amount)
    {
        uint256 t = sellingTime.add(locked[_of][_reason].validity);
        if (t > _time)
            amount = locked[_of][_reason].amount;        
	}
        
    function extendLock(address _to, bytes32 _reason, uint256 _time)
    	whenNotPaused
    	onlyOwner
        public
        returns (bool)
    {
        require(tokensLocked(_to, _reason) > 0, NOT_LOCKED);

        locked[_to][_reason].validity = locked[_to][_reason].validity.add(_time);

        emit Locked(_to, _reason, locked[_to][_reason].amount, locked[_to][_reason].validity);
        return true;
    } 
    
    function tokensUnlockable(address _of, bytes32 _reason)
        public
        view
        returns (uint256 amount)
    {
		uint256 t = sellingTime.add(locked[_of][_reason].validity);
        if (t <= now && !locked[_of][_reason].claimed)
            amount = locked[_of][_reason].amount;		        
    }
    
    function unlock(address _of)
    	whenNotPaused
    	onlyOwner
        public
        returns (uint256 unlockableTokens)
    {	
        uint256 lockedTokens;

        for (uint256 i = 0; i < lockReason[_of].length; i++) {
            lockedTokens = tokensUnlockable(_of, lockReason[_of][i]);
            if (lockedTokens > 0) {
                unlockableTokens = unlockableTokens.add(lockedTokens);
                locked[_of][lockReason[_of][i]].claimed = true;
                emit Unlocked(_of, lockReason[_of][i], lockedTokens);
            }
        }
        
        if (unlockableTokens > 0) {
			_balances[_of] = _balances[_of].add(unlockableTokens);
        }
    }
    
    function countLockedReasons(address _of)
		public
		view
		returns (uint256)    
    {
    	return lockReason[_of].length;
    }
    
	function lockedReason(address _of, uint256 _idx)
		public
		view
		returns (bytes32)
	{
		if(_idx >= lockReason[_of].length) 
			return bytes32(0);
		return lockReason[_of][_idx];
	}
	
    function lockedTime(address _of, bytes32 _reason)
        public
        view
        returns (uint256 validity)
    {
    	validity = 0;
        if (!locked[_of][_reason].claimed)
            validity = locked[_of][_reason].validity;
    }
    
    function burn(uint256 value)
    	whenNotPaused 
    	public 
    {
        _burn(msg.sender, value);
    }

    function burnFrom(address from, uint256 value)
    	whenNotPaused     
    	public 
    {
        _burnFrom(from, value);
    }
    
    function _mint(address account, uint256 value) 
    	internal 
    {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }
        
    function _transfer(address from, address to, uint256 value) 
    	internal 
    {   
    	require(value != 0, AMOUNT_ZERO); 
	    require(value <= _balances[from], NOT_ENOUGH_TOKEN);
	    require(to != address(0), INVALID_TARGET_ADDRESS);	            
        
        uint256 lockedBalance = lockedBalanceOf(to);
        require(lockedBalance == 0, UNABLE_DEPOSIT);

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }    
    
    function _burn(address account, uint256 value) 
    	internal 
    {
        require(account != address(0), INVALID_TARGET_ADDRESS);
        require(value <= _balances[account], NOT_ENOUGH_TOKEN);

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    function _burnFrom(address account, uint256 value) 
    	internal 
    {
    	require(value <= _allowed[account][msg.sender], NOT_ENOUGH_ALLOWED);
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }            	
}