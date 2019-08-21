pragma solidity ^0.5.0;

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
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

// File: contracts/IAlkionToken.sol

/**
 * @title AlkionToken interface based ERC-20
 * @dev www.alkion.io  
 */
interface IAlkionToken {
    function transfer(address sender, address to, uint256 value) external returns (bool);
    function approve(address sender, address spender, uint256 value) external returns (bool);
    function transferFrom(address sender, address from, address to, uint256 value) external returns (uint256);
	function burn(address sender, uint256 value) external;
	function burnFrom(address sender, address from, uint256 value) external returns(uint256);
	
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
	function totalBalanceOf(address who) external view returns (uint256);
	function lockedBalanceOf(address who) external view returns (uint256);     
    function allowance(address owner, address spender) external view returns (uint256);
	
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);    
}

// File: contracts/AlkionToken.sol

/**
 * @title Alkion Token
 * @dev Very simple ERC20 Token example, where all tokens are pre-assigned to the creator.
 * Note they can later distribute these tokens as they wish using `transfer` and other
 * `ERC20` functions.
 */
contract AlkionToken is IERC20, Pausable, Ownable {

	string internal constant NOT_OWNER = 'You are not owner';
	string internal constant INVALID_TARGET_ADDRESS = 'Invalid target address';
	
	IAlkionToken internal _tokenImpl;
		
	modifier onlyOwner() {
		require(isOwner(), NOT_OWNER);
		_;
	}
		
	constructor() 
		public 
	{	
	}
	
	function impl(IAlkionToken tokenImpl)
		onlyOwner 
		public 
	{
		require(address(tokenImpl) != address(0), INVALID_TARGET_ADDRESS);
		_tokenImpl = tokenImpl;
	}
	
	function addressImpl() 
		public 
		view 
		returns (address) 
	{
		if(!isOwner()) return address(0);
		return address(_tokenImpl);
	} 
	
	function totalSupply() 
		public 
		view 
		returns (uint256) 
	{
		return _tokenImpl.totalSupply();
	}
	
	function balanceOf(address who) 
		public 
		view 
		returns (uint256) 
	{
		return _tokenImpl.balanceOf(who);
	}
	
	function allowance(address owner, address spender)
		public 
		view 
		returns (uint256) 
	{
		return _tokenImpl.allowance(owner, spender);
	}
	
	function transfer(address to, uint256 value) 
		whenNotPaused 
		public 
		returns (bool result) 
	{
		result = _tokenImpl.transfer(msg.sender, to, value);
		emit Transfer(msg.sender, to, value);
	}
	
	function approve(address spender, uint256 value)
		whenNotPaused 
		public 
		returns (bool result) 
	{
		result = _tokenImpl.approve(msg.sender, spender, value);
		emit Approval(msg.sender, spender, value);
	}
	
	function transferFrom(address from, address to, uint256 value)
		whenNotPaused 
		public 
		returns (bool) 
	{
		uint256 aB = _tokenImpl.transferFrom(msg.sender, from, to, value);
		emit Transfer(from, to, value);
		emit Approval(from, msg.sender, aB);
		return true;
	}
	
	function burn(uint256 value) 
		public 
	{
		_tokenImpl.burn(msg.sender, value);
		emit Transfer(msg.sender, address(0), value);
	}

	function burnFrom(address from, uint256 value) 
		public 
	{
		uint256 aB = _tokenImpl.burnFrom(msg.sender, from, value);
		emit Transfer(from, address(0), value);
		emit Approval(from, msg.sender, aB);
	}

	function totalBalanceOf(address _of) 
		public 
		view 
		returns (uint256)
	{
		return _tokenImpl.totalBalanceOf(_of);
	}
	
	function lockedBalanceOf(address _of) 
		public 
		view 
		returns (uint256)
	{
		return _tokenImpl.lockedBalanceOf(_of);
	}
}