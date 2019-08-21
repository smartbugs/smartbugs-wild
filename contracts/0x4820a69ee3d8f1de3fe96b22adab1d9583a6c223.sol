/* file: openzeppelin-solidity/contracts/ownership/Ownable.sol */
pragma solidity ^0.5.0;

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

/* eof (openzeppelin-solidity/contracts/ownership/Ownable.sol) */
/* file: openzeppelin-solidity/contracts/math/SafeMath.sol */
pragma solidity ^0.5.0;

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

/* eof (openzeppelin-solidity/contracts/math/SafeMath.sol) */
/* file: ./contracts/utils/Utils.sol */
/**
 * @title Manageable Contract
 * @author Validity Labs AG <info@validitylabs.org>
 */
 
pragma solidity ^0.5.4;


contract Utils {
    /** MODIFIERS **/
    modifier onlyValidAddress(address _address) {
        require(_address != address(0), "invalid address");
        _;
    }
}

/* eof (./contracts/utils/Utils.sol) */
/* file: ./contracts/management/Manageable.sol */
/**
 * @title Manageable Contract
 * @author Validity Labs AG <info@validitylabs.org>
 */
 
 pragma solidity ^0.5.4;


contract Manageable is Ownable, Utils {
    mapping(address => bool) public isManager;     // manager accounts

    /** EVENTS **/
    event ChangedManager(address indexed manager, bool active);

    /** MODIFIERS **/
    modifier onlyManager() {
        require(isManager[msg.sender], "is not manager");
        _;
    }

    /**
    * @notice constructor sets the deployer as a manager
    */
    constructor() public {
        setManager(msg.sender, true);
    }

    /**
     * @notice enable/disable an account to be a manager
     * @param _manager address address of the manager to create/alter
     * @param _active bool flag that shows if the manager account is active
     */
    function setManager(address _manager, bool _active) public onlyOwner onlyValidAddress(_manager) {
        isManager[_manager] = _active;
        emit ChangedManager(_manager, _active);
    }
}

/* eof (./contracts/management/Manageable.sol) */
/* file: ./contracts/whitelist/GlobalWhitelist.sol */
/**
 * @title Global Whitelist Contract
 * @author Validity Labs AG <info@validitylabs.org>
 */

pragma solidity ^0.5.4;



contract GlobalWhitelist is Ownable, Manageable {
    using SafeMath for uint256;
    
    mapping(address => bool) public isWhitelisted; // addresses of who's whitelisted
    bool public isWhitelisting = true;             // whitelisting enabled by default

    /** EVENTS **/
    event ChangedWhitelisting(address indexed registrant, bool whitelisted);
    event GlobalWhitelistDisabled(address indexed manager);
    event GlobalWhitelistEnabled(address indexed manager);

    /**
    * @dev add an address to the whitelist
    * @param _address address
    */
    function addAddressToWhitelist(address _address) public onlyManager onlyValidAddress(_address) {
        isWhitelisted[_address] = true;
        emit ChangedWhitelisting(_address, true);
    }

    /**
    * @dev add addresses to the whitelist
    * @param _addresses addresses array
    */
    function addAddressesToWhitelist(address[] memory _addresses) public {
        for (uint256 i = 0; i < _addresses.length; i++) {
            addAddressToWhitelist(_addresses[i]);
        }
    }

    /**
    * @dev remove an address from the whitelist
    * @param _address address
    */
    function removeAddressFromWhitelist(address _address) public onlyManager onlyValidAddress(_address) {
        isWhitelisted[_address] = false;
        emit ChangedWhitelisting(_address, false);
    }

    /**
    * @dev remove addresses from the whitelist
    * @param _addresses addresses
    */
    function removeAddressesFromWhitelist(address[] memory _addresses) public {
        for (uint256 i = 0; i < _addresses.length; i++) {
            removeAddressFromWhitelist(_addresses[i]);
        }
    }

    /** 
    * @notice toggle the whitelist by the parent contract; ExporoTokenFactory
    */
    function toggleWhitelist() public onlyOwner {
        isWhitelisting ? isWhitelisting = false : isWhitelisting = true;
        if (isWhitelisting) {
            emit GlobalWhitelistEnabled(msg.sender);
        } else {
            emit GlobalWhitelistDisabled(msg.sender);
        }
    }
}

/* eof (./contracts/whitelist/GlobalWhitelist.sol) */
/* file: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol */
pragma solidity ^0.5.0;

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

/* eof (openzeppelin-solidity/contracts/token/ERC20/IERC20.sol) */
/* file: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol */
pragma solidity ^0.5.0;


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }
}

/* eof (openzeppelin-solidity/contracts/token/ERC20/ERC20.sol) */
/* file: openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol */
pragma solidity ^0.5.0;


/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

/* eof (openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol) */
/* file: openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol */
pragma solidity ^0.5.0;


/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract ERC20Burnable is ERC20 {
    /**
     * @dev Burns a specific amount of tokens.
     * @param value The amount of token to be burned.
     */
    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    /**
     * @dev Burns a specific amount of tokens from the target address and decrements allowance
     * @param from address The address which you want to send tokens from
     * @param value uint256 The amount of token to be burned
     */
    function burnFrom(address from, uint256 value) public {
        _burnFrom(from, value);
    }
}

/* eof (openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol) */
/* file: openzeppelin-solidity/contracts/access/Roles.sol */
pragma solidity ^0.5.0;

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

/* eof (openzeppelin-solidity/contracts/access/Roles.sol) */
/* file: openzeppelin-solidity/contracts/access/roles/PauserRole.sol */
pragma solidity ^0.5.0;


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

/* eof (openzeppelin-solidity/contracts/access/roles/PauserRole.sol) */
/* file: openzeppelin-solidity/contracts/lifecycle/Pausable.sol */
pragma solidity ^0.5.0;


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

/* eof (openzeppelin-solidity/contracts/lifecycle/Pausable.sol) */
/* file: openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol */
pragma solidity ^0.5.0;


/**
 * @title Pausable token
 * @dev ERC20 modified with pausable transfers.
 **/
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

/* eof (openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol) */
/* file: ./contracts/token/ERC20/IERC20Snapshot.sol */
/**
 * @title Interface ERC20 SnapshotToken (abstract contract)
 * @author Validity Labs AG <info@validitylabs.org>
 */

pragma solidity ^0.5.4;  


/* solhint-disable no-empty-blocks */
contract IERC20Snapshot {   
    /**
    * @dev Queries the balance of `_owner` at a specific `_blockNumber`
    * @param _owner The address from which the balance will be retrieved
    * @param _blockNumber The block number when the balance is queried
    * @return The balance at `_blockNumber`
    */
    function balanceOfAt(address _owner, uint _blockNumber) public view returns (uint256) {}

    /**
    * @notice Total amount of tokens at a specific `_blockNumber`.
    * @param _blockNumber The block number when the totalSupply is queried
    * @return The total amount of tokens at `_blockNumber`
    */
    function totalSupplyAt(uint _blockNumber) public view returns(uint256) {}
}

/* eof (./contracts/token/ERC20/IERC20Snapshot.sol) */
/* file: ./contracts/token/ERC20/ERC20Snapshot.sol */
/**
 * @title ERC20 Snapshot Token
 * inspired by Jordi Baylina's MiniMeToken to record historical balances
 * @author Validity Labs AG <info@validitylabs.org>
 */

pragma solidity ^0.5.4;  



contract ERC20Snapshot is IERC20Snapshot, ERC20 {   
    using SafeMath for uint256;

    /**
    * @dev `Snapshot` is the structure that attaches a block number to a
    * given value. The block number attached is the one that last changed the value
    */
    struct Snapshot {
        uint128 fromBlock;  // `fromBlock` is the block number at which the value was generated from
        uint128 value;  // `value` is the amount of tokens at a specific block number
    }

    /**
    * @dev `_snapshotBalances` is the map that tracks the balance of each address, in this
    * contract when the balance changes the block number that the change
    * occurred is also included in the map
    */
    mapping (address => Snapshot[]) private _snapshotBalances;

    // Tracks the history of the `_totalSupply` & '_mintedSupply' of the token
    Snapshot[] private _snapshotTotalSupply;

    /*** FUNCTIONS ***/
    /** OVERRIDE
    * @dev Send `_value` tokens to `_to` from `msg.sender`
    * @param _to The address of the recipient
    * @param _value The amount of tokens to be transferred
    * @return Whether the transfer was successful or not
    */
    function transfer(address _to, uint256 _value) public returns (bool result) {
        result = super.transfer(_to, _value);
        createSnapshot(msg.sender, _to);
    }

    /** OVERRIDE
    * @dev Send `_value` tokens to `_to` from `_from` on the condition it is approved by `_from`
    * @param _from The address holding the tokens being transferred
    * @param _to The address of the recipient
    * @param _value The amount of tokens to be transferred
    * @return True if the transfer was successful
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool result) {
        result = super.transferFrom(_from, _to, _value);
        createSnapshot(_from, _to);
    }

    /**
    * @dev Queries the balance of `_owner` at a specific `_blockNumber`
    * @param _owner The address from which the balance will be retrieved
    * @param _blockNumber The block number when the balance is queried
    * @return The balance at `_blockNumber`
    */
    function balanceOfAt(address _owner, uint _blockNumber) public view returns (uint256) {
        return getValueAt(_snapshotBalances[_owner], _blockNumber);
    }

    /**
    * @dev Total supply cap of tokens at a specific `_blockNumber`.
    * @param _blockNumber The block number when the totalSupply is queried
    * @return The total supply cap of tokens at `_blockNumber`
    */
    function totalSupplyAt(uint _blockNumber) public view returns(uint256) {
        return getValueAt(_snapshotTotalSupply, _blockNumber);
    }

    /*** Internal functions ***/
    /**
    * @dev Updates snapshot mappings for _from and _to and emit an event
    * @param _from The address holding the tokens being transferred
    * @param _to The address of the recipient
    * @return True if the transfer was successful
    */
    function createSnapshot(address _from, address _to) internal {
        updateValueAtNow(_snapshotBalances[_from], balanceOf(_from));
        updateValueAtNow(_snapshotBalances[_to], balanceOf(_to));
    }

    /**
    * @dev `getValueAt` retrieves the number of tokens at a given block number
    * @param checkpoints The history of values being queried
    * @param _block The block number to retrieve the value at
    * @return The number of tokens being queried
    */
    function getValueAt(Snapshot[] storage checkpoints, uint _block) internal view returns (uint) {
        if (checkpoints.length == 0) return 0;

        // Shortcut for the actual value
        if (_block >= checkpoints[checkpoints.length.sub(1)].fromBlock) {
            return checkpoints[checkpoints.length.sub(1)].value;
        }

        if (_block < checkpoints[0].fromBlock) {
            return 0;
        } 

        // Binary search of the value in the array
        uint min;
        uint max = checkpoints.length.sub(1);

        while (max > min) {
            uint mid = (max.add(min).add(1)).div(2);
            if (checkpoints[mid].fromBlock <= _block) {
                min = mid;
            } else {
                max = mid.sub(1);
            }
        }

        return checkpoints[min].value;
    }

    /**
    * @dev `updateValueAtNow` used to update the `_snapshotBalances` map and the `_snapshotTotalSupply`
    * @param checkpoints The history of data being updated
    * @param _value The new number of tokens
    */
    function updateValueAtNow(Snapshot[] storage checkpoints, uint _value) internal {
        if ((checkpoints.length == 0) || (checkpoints[checkpoints.length.sub(1)].fromBlock < block.number)) {
            checkpoints.push(Snapshot(uint128(block.number), uint128(_value)));
        } else {
            checkpoints[checkpoints.length.sub(1)].value = uint128(_value);
        }
    }
}

/* eof (./contracts/token/ERC20/ERC20Snapshot.sol) */
/* file: ./contracts/token/ERC20/ERC20ForcedTransfer.sol */
/**
 * @title ERC20Confiscatable
 * @author Validity Labs AG <info@validitylabs.org>
 */

pragma solidity ^0.5.4;  



contract ERC20ForcedTransfer is Ownable, ERC20 {
    /*** EVENTS ***/
    event ForcedTransfer(address indexed account, uint256 amount, address indexed receiver);

    /*** FUNCTIONS ***/
    /**
    * @notice takes funds from _confiscatee and sends them to _receiver
    * @param _confiscatee address who's funds are being confiscated
    * @param _receiver address who's receiving the funds 
    */
    function forceTransfer(address _confiscatee, address _receiver) public onlyOwner {
        uint256 balance = balanceOf(_confiscatee);
        _transfer(_confiscatee, _receiver, balance);
        emit ForcedTransfer(_confiscatee, balance, _receiver);
    }
}

/* eof (./contracts/token/ERC20/ERC20ForcedTransfer.sol) */
/* file: ./contracts/token/ERC20/ERC20Whitelist.sol */
/**
 * @title ERC20Whitelist
 * @author Validity Labs AG <info@validitylabs.org>
 */

pragma solidity ^0.5.4;  



contract ERC20Whitelist is Ownable, ERC20 {   
    GlobalWhitelist public whitelist;
    bool public isWhitelisting = true;  // default to true

    /** EVENTS **/
    event ESTWhitelistingEnabled();
    event ESTWhitelistingDisabled();

    /*** FUNCTIONS ***/
    /**
    * @notice disables whitelist per individual EST
    * @dev parnent contract, ExporoTokenFactory, is owner
    */
    function toggleWhitelist() external onlyOwner {
        isWhitelisting ? isWhitelisting = false : isWhitelisting = true;
        if (isWhitelisting) {
            emit ESTWhitelistingEnabled();
        } else {
            emit ESTWhitelistingDisabled();
        }
    }

    /** OVERRIDE
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    * @return bool
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        if (checkWhitelistEnabled()) {
            checkIfWhitelisted(msg.sender);
            checkIfWhitelisted(_to);
        }
        return super.transfer(_to, _value);
    }

    /** OVERRIDE
    * @dev Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    * @return bool
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        if (checkWhitelistEnabled()) {
            checkIfWhitelisted(_from);
            checkIfWhitelisted(_to);
        }
        return super.transferFrom(_from, _to, _value);
    }

    /**
    * @dev check if whitelisting is in effect versus local and global bools
    * @return bool
    */
    function checkWhitelistEnabled() public view returns (bool) {
        // local whitelist
        if (isWhitelisting) {
            // global whitelist
            if (whitelist.isWhitelisting()) {
                return true;
            }
        }

        return false;
    }

    /*** INTERNAL/PRIVATE ***/
    /**
    * @dev check if the address has been whitelisted by the Whitelist contract
    * @param _account address of the account to check
    */
    function checkIfWhitelisted(address _account) internal view {
        require(whitelist.isWhitelisted(_account), "not whitelisted");
    }
}

/* eof (./contracts/token/ERC20/ERC20Whitelist.sol) */
/* file: ./contracts/token/ERC20/ERC20DocumentRegistry.sol */
/**
 * @title ERC20 Document Registry Contract
 * @author Validity Labs AG <info@validitylabs.org>
 */
 
 pragma solidity ^0.5.4;



/**
 * @notice Prospectus and Quarterly Reports stored hashes via IPFS
 * @dev read IAgreement for details under /contracts/neufund/standards
*/
// solhint-disable not-rely-on-time
contract ERC20DocumentRegistry is Ownable {
    using SafeMath for uint256;

    struct HashedDocument {
        uint256 timestamp;
        string documentUri;
    }

    // array of all documents 
    HashedDocument[] private _documents;

    event LogDocumentedAdded(string documentUri, uint256 documentIndex);

    /**
    * @notice adds a document's uri from IPFS to the array
    * @param documentUri string
    */
    function addDocument(string memory documentUri) public onlyOwner {
        require(bytes(documentUri).length > 0, "invalid documentUri");

        HashedDocument memory document = HashedDocument({
            timestamp: block.timestamp,
            documentUri: documentUri
        });

        _documents.push(document);

        emit LogDocumentedAdded(documentUri, _documents.length.sub(1));
    }

    /**
    * @notice fetch the latest document on the array
    * @return uint256, string, uint256 
    */
    function currentDocument() public view 
        returns (uint256 timestamp, string memory documentUri, uint256 index) {
            require(_documents.length > 0, "no documents exist");
            uint256 last = _documents.length.sub(1);

            HashedDocument storage document = _documents[last];
            return (document.timestamp, document.documentUri, last);
        }

    /**
    * @notice adds a document's uri from IPFS to the array
    * @param documentIndex uint256
    * @return uint256, string, uint256 
    */
    function getDocument(uint256 documentIndex) public view
        returns (uint256 timestamp, string memory documentUri, uint256 index) {
            require(documentIndex < _documents.length, "invalid index");

            HashedDocument storage document = _documents[documentIndex];
            return (document.timestamp, document.documentUri, documentIndex);
        }

    /**
    * @notice return the total amount of documents in the array
    * @return uint256
    */
    function documentCount() public view returns (uint256) {
        return _documents.length;
    }
}

/* eof (./contracts/token/ERC20/ERC20DocumentRegistry.sol) */
/* file: ./contracts/exporo/ExporoToken.sol */
/**
 * @title Exporo Token Contract
 * @author Validity Labs AG <info@validitylabs.org>
 */

pragma solidity ^0.5.4;



contract SampleToken is Ownable, ERC20, ERC20Detailed {
    /*** FUNCTIONS ***/
    /**
    * @dev constructor
    * @param _name string
    * @param _symbol string
    * @param _decimal uint8
    * @param _initialSupply uint256 initial total supply cap. can be 0
    * @param _recipient address to recieve the tokens
    */
    /* solhint-disable */
    constructor(string memory _name, string memory _symbol, uint8 _decimal, uint256 _initialSupply, address _recipient)
        public 
        ERC20Detailed(_name, _symbol, _decimal) {
            _mint(_recipient, _initialSupply);
        }
    /* solhint-enable */
}

/* eof (./contracts/exporo/ExporoToken.sol) */
/* file: ./contracts/exporo/ExporoTokenFactory.sol */
/**
 * @title Exporo Token Factory Contract
 * @author Validity Labs AG <info@validitylabs.org>
 */

pragma solidity ^0.5.4;



/* solhint-disable max-line-length */
/* solhint-disable separate-by-one-line-in-contract */
contract SampleTokenFactory is Ownable, Manageable {
    address public whitelist;

    /*** EVENTS ***/
    event NewTokenDeployed(address indexed contractAddress, string name, string symbol, uint8 decimals);
   

    /**
    * @dev allows owner to launch a new token with a new name, symbol, and decimals.
    * Defaults to using whitelist stored in this contract. If _whitelist is address(0), else it will use
    * _whitelist as the param to pass into the new token's constructor upon deployment 
    * @param _name string
    * @param _symbol string
    * @param _decimals uint8 
    * @param _initialSupply uint256 initial total supply cap
    * @param _recipient address to recieve the initial token supply
    */
    function newToken(string memory _name, string memory _symbol, uint8 _decimals, uint256 _initialSupply, address _recipient) 
        public 
        onlyManager 
        onlyValidAddress(_recipient)
        returns (address) {
            require(bytes(_name).length > 0, "name cannot be blank");
            require(bytes(_symbol).length > 0, "symbol cannot be blank");
            require(_initialSupply > 0, "supply cannot be 0");

            SampleToken token = new SampleToken(_name, _symbol, _decimals, _initialSupply, _recipient);

            emit NewTokenDeployed(address(token), _name, _symbol, _decimals);
            
            return address(token);
        }
}

/* eof (./contracts/exporo/ExporoTokenFactory.sol) */