// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.2;

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
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

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.2;

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.5.2;



/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://eips.ethereum.org/EIPS/eip-20
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
     * @return A uint256 representing the amount owned by the passed address.
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
     * @dev Transfer token to a specified address
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
        _approve(msg.sender, spender, value);
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
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when _allowed[msg.sender][spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when _allowed[msg.sender][spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
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
     * @dev Approve an address to spend another addresses' tokens.
     * @param owner The address that owns the tokens.
     * @param spender The address that will spend the tokens.
     * @param value The number of tokens that can be spent.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
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
        _burn(account, value);
        _approve(account, msg.sender, _allowed[account][msg.sender].sub(value));
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol

pragma solidity ^0.5.2;


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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol

pragma solidity ^0.5.2;


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
     * @param from address The account whose tokens will be burned.
     * @param value uint256 The amount of token to be burned.
     */
    function burnFrom(address from, uint256 value) public {
        _burnFrom(from, value);
    }
}

// File: openzeppelin-solidity/contracts/access/Roles.sol

pragma solidity ^0.5.2;

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

pragma solidity ^0.5.2;


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

pragma solidity ^0.5.2;


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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Pausable.sol

pragma solidity ^0.5.2;



/**
 * @title Pausable token
 * @dev ERC20 modified with pausable transfers.
 */
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

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.2;

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
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
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

// File: openzeppelin-solidity/contracts/math/Math.sol

pragma solidity ^0.5.2;

/**
 * @title Math
 * @dev Assorted math operations
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Calculates the average of two numbers. Since these are integers,
     * averages of an even and odd number cannot be represented, and will be
     * rounded down.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

// File: contracts/token/ERC20/library/Snapshots.sol

/**
 * @title Snapshot
 * @dev Utility library of the Snapshot structure, including getting value.
 * @author Validity Labs AG <info@validitylabs.org>
 */
pragma solidity 0.5.7;




library Snapshots {
    using Math for uint256;
    using SafeMath for uint256;

    /**
     * @notice This structure stores the historical value associate at a particular blocknumber
     * @param fromBlock The blocknumber of the creation of the snapshot
     * @param value The value to be recorded
     */
    struct Snapshot {
        uint256 fromBlock;
        uint256 value;
    }

    struct SnapshotList {
        Snapshot[] history;
    }

    /**
     * @notice This function creates snapshots for certain value...
     * @dev To avoid having two Snapshots with the same block.number, we check if the last
     * existing one is the current block.number, we update the last Snapshot
     * @param item The SnapshotList to be operated
     * @param _value The value associated the the item that is going to have a snapshot
     */
    function createSnapshot(SnapshotList storage item, uint256 _value) internal {
        uint256 length = item.history.length;
        if (length == 0 || (item.history[length.sub(1)].fromBlock < block.number)) {
            item.history.push(Snapshot(block.number, _value));
        } else {
            // When the last existing snapshot is ready to be updated
            item.history[length.sub(1)].value = _value;
        }
    }

    /**
     * @notice Find the index of the item in the SnapshotList that contains information
     * corresponding to the blockNumber. (FindLowerBond of the array)
     * @dev The binary search logic is inspired by the Arrays.sol from Openzeppelin
     * @param item The list of Snapshots to be queried
     * @param blockNumber The block number of the queried moment
     * @return The index of the Snapshot array
     */
    function findBlockIndex(
        SnapshotList storage item, 
        uint256 blockNumber
    ) 
        internal
        view 
        returns (uint256)
    {
        // Find lower bound of the array
        uint256 length = item.history.length;

        // Return value for extreme cases: If no snapshot exists and/or the last snapshot
        if (item.history[length.sub(1)].fromBlock <= blockNumber) {
            return length.sub(1);
        } else {
            // Need binary search for the value
            uint256 low = 0;
            uint256 high = length.sub(1);

            while (low < high.sub(1)) {
                uint256 mid = Math.average(low, high);
                // mid will always be strictly less than high and it rounds down
                if (item.history[mid].fromBlock <= blockNumber) {
                    low = mid;
                } else {
                    high = mid;
                }
            }
            return low;
        }   
    }

    /**
     * @notice This function returns the value of the corresponding Snapshot
     * @param item The list of Snapshots to be queried
     * @param blockNumber The block number of the queried moment
     * @return The value of the queried moment
     */
    function getValueAt(
        SnapshotList storage item, 
        uint256 blockNumber
    )
        internal
        view
        returns (uint256)
    {
        if (item.history.length == 0 || blockNumber < item.history[0].fromBlock) {
            return 0;
        } else {
            uint256 index = findBlockIndex(item, blockNumber);
            return item.history[index].value;
        }
    }
}

// File: contracts/token/ERC20/IERC20Snapshot.sol

/**
 * @title Interface ERC20 SnapshotToken (abstract contract)
 * @author Validity Labs AG <info@validitylabs.org>
 */

pragma solidity 0.5.7;  


/* solhint-disable no-empty-blocks */
interface IERC20Snapshot {   
    /**
    * @dev Queries the balance of `_owner` at a specific `_blockNumber`
    * @param _owner The address from which the balance will be retrieved
    * @param _blockNumber The block number when the balance is queried
    * @return The balance at `_blockNumber`
    */
    function balanceOfAt(address _owner, uint _blockNumber) external view returns (uint256);

    /**
    * @notice Total amount of tokens at a specific `_blockNumber`.
    * @param _blockNumber The block number when the totalSupply is queried
    * @return The total amount of tokens at `_blockNumber`
    */
    function totalSupplyAt(uint _blockNumber) external view returns(uint256);
}

// File: contracts/token/ERC20/ERC20Snapshot.sol

/**
 * @title Snapshot Token
 * @dev This is an ERC20 compatible token that takes snapshots of account balances.
 * @author Validity Labs AG <info@validitylabs.org>
 */
pragma solidity 0.5.7;  





contract ERC20Snapshot is ERC20, IERC20Snapshot {
    using Snapshots for Snapshots.SnapshotList;

    mapping(address => Snapshots.SnapshotList) private _snapshotBalances; 
    Snapshots.SnapshotList private _snapshotTotalSupply;   

    event AccountSnapshotCreated(address indexed account, uint256 indexed blockNumber, uint256 value);
    event TotalSupplySnapshotCreated(uint256 indexed blockNumber, uint256 value);

    /**
     * @notice Return the historical supply of the token at a certain time
     * @param blockNumber The block number of the moment when token supply is queried
     * @return The total supply at "blockNumber"
     */
    function totalSupplyAt(uint256 blockNumber) external view returns (uint256) {
        return _snapshotTotalSupply.getValueAt(blockNumber);
    }

    /**
     * @notice Return the historical balance of an account at a certain time
     * @param owner The address of the token holder
     * @param blockNumber The block number of the moment when token supply is queried
     * @return The balance of the queried token holder at "blockNumber"
     */
    function balanceOfAt(address owner, uint256 blockNumber) 
        external 
        view 
        returns (uint256) 
    {
        return _snapshotBalances[owner].getValueAt(blockNumber);
    }

    /** OVERRIDE
     * @notice Transfer tokens between two accounts while enforcing the update of Snapshots
     * @param from The address to transfer from
     * @param to The address to transfer to
     * @param value The amount to be transferred
     */
    function _transfer(address from, address to, uint256 value) internal {
        super._transfer(from, to, value);

        _snapshotBalances[from].createSnapshot(balanceOf(from));
        _snapshotBalances[to].createSnapshot(balanceOf(to));

        emit AccountSnapshotCreated(from, block.number, balanceOf(from));
        emit AccountSnapshotCreated(to, block.number, balanceOf(to));
    }

    /** OVERRIDE
     * @notice Mint tokens to one account while enforcing the update of Snapshots
     * @param account The address that receives tokens
     * @param value The amount of tokens to be created
     */
    function _mint(address account, uint256 value) internal {
        super._mint(account, value);

        _snapshotBalances[account].createSnapshot(balanceOf(account));
        _snapshotTotalSupply.createSnapshot(totalSupply());
        
        emit AccountSnapshotCreated(account, block.number, balanceOf(account));
        emit TotalSupplySnapshotCreated(block.number, totalSupply());
    }

    /** OVERRIDE
     * @notice Burn tokens of one account
     * @param account The address whose tokens will be burnt
     * @param value The amount of tokens to be burnt
     */
    function _burn(address account, uint256 value) internal {
        super._burn(account, value);

        _snapshotBalances[account].createSnapshot(balanceOf(account));
        _snapshotTotalSupply.createSnapshot(totalSupply());

        emit AccountSnapshotCreated(account, block.number, balanceOf(account));
        emit TotalSupplySnapshotCreated(block.number, totalSupply());
    }
}

// File: contracts/token/ERC20/ERC20ForcedTransfer.sol

/**
 * @title ERC20Confiscatable
 * @author Validity Labs AG <info@validitylabs.org>
 */

pragma solidity 0.5.7;  





contract ERC20ForcedTransfer is Ownable, ERC20 {
    /*** EVENTS ***/
    event ForcedTransfer(address indexed account, uint256 amount, address indexed receiver);

    /*** FUNCTIONS ***/
    /**
    * @notice takes funds from _confiscatee and sends them to _receiver
    * @param _confiscatee address who's funds are being confiscated
    * @param _receiver address who's receiving the funds 
    * @param _amount uint256 amount of tokens to force transfer away
    */
    function forceTransfer(address _confiscatee, address _receiver, uint256 _amount) public onlyOwner {
        _transfer(_confiscatee, _receiver, _amount);

        emit ForcedTransfer(_confiscatee, _amount, _receiver);
    }
}

// File: contracts/utils/Utils.sol

/**
 * @title Manageable Contract
 * @author Validity Labs AG <info@validitylabs.org>
 */
 
pragma solidity 0.5.7;


contract Utils {
    /** MODIFIERS **/
    modifier onlyValidAddress(address _address) {
        require(_address != address(0), "invalid address");
        _;
    }
}

// File: contracts/management/Manageable.sol

/**
 * @title Manageable Contract
 * @author Validity Labs AG <info@validitylabs.org>
 */
 
 pragma solidity 0.5.7;



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

    /** OVERRIDE 
    * @notice does not allow owner to give up ownership
    */
    function renounceOwnership() public onlyOwner {
        revert("Cannot renounce ownership");
    }
}

// File: contracts/whitelist/GlobalWhitelist.sol

/**
 * @title Global Whitelist Contract
 * @author Validity Labs AG <info@validitylabs.org>
 */

pragma solidity 0.5.7;




contract GlobalWhitelist is Ownable, Manageable {
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
    function addAddressesToWhitelist(address[] calldata _addresses) external {
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
    function removeAddressesFromWhitelist(address[] calldata _addresses) external {
        for (uint256 i = 0; i < _addresses.length; i++) {
            removeAddressFromWhitelist(_addresses[i]);
        }
    }

    /** 
    * @notice toggle the whitelist by the parent contract; ExporoTokenFactory
    */
    function toggleWhitelist() external onlyOwner {
        isWhitelisting = isWhitelisting ? false : true;

        if (isWhitelisting) {
            emit GlobalWhitelistEnabled(msg.sender);
        } else {
            emit GlobalWhitelistDisabled(msg.sender);
        }
    }
}

// File: contracts/token/ERC20/ERC20Whitelist.sol

/**
 * @title ERC20Whitelist
 * @author Validity Labs AG <info@validitylabs.org>
 */

pragma solidity 0.5.7;  





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
        isWhitelisting = isWhitelisting ? false : true;
        
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

// File: contracts/token/ERC20/ERC20DocumentRegistry.sol

/**
 * @title ERC20 Document Registry Contract
 * @author Validity Labs AG <info@validitylabs.org>
 */
 
 pragma solidity 0.5.7;




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

    event LogDocumentedAdded(string documentUri, uint256 indexed documentIndex);

    /**
    * @notice adds a document's uri from IPFS to the array
    * @param documentUri string
    */
    function addDocument(string calldata documentUri) external onlyOwner {
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
    function currentDocument() external view 
        returns (uint256 timestamp, string memory documentUri, uint256 index) {
            require(_documents.length > 0, "no documents exist");
            uint256 last = _documents.length.sub(1);

            HashedDocument storage document = _documents[last];
            return (document.timestamp, document.documentUri, last);
        }

    /**
    * @notice fetches a document's uri
    * @param documentIndex uint256
    * @return uint256, string, uint256 
    */
    function getDocument(uint256 documentIndex) external view
        returns (uint256 timestamp, string memory documentUri, uint256 index) {
            require(documentIndex < _documents.length, "invalid index");

            HashedDocument storage document = _documents[documentIndex];
            return (document.timestamp, document.documentUri, documentIndex);
        }

    /**
    * @notice return the total amount of documents in the array
    * @return uint256
    */
    function documentCount() external view returns (uint256) {
        return _documents.length;
    }
}

// File: contracts/token/ERC20/ERC20BatchSend.sol

/**
 * @title Batch Send
 * @author Validity Labs AG <info@validitylabs.org>
 */

pragma solidity 0.5.7;



contract ERC20BatchSend is ERC20 {
    /**
     * @dev Allows the transfer of token amounts to multiple addresses.
     * @param beneficiaries Array of addresses that would receive the tokens.
     * @param amounts Array of amounts to be transferred per beneficiary.
     */
    function batchSend(address[] calldata beneficiaries, uint256[] calldata amounts) external {
        require(beneficiaries.length == amounts.length, "mismatched array lengths");

        uint256 length = beneficiaries.length;

        for (uint256 i = 0; i < length; i++) {
            transfer(beneficiaries[i], amounts[i]);
        }
    }
}

// File: contracts/exporo/ExporoToken.sol

/**
 * @title Exporo Token Contract
 * @author Validity Labs AG <info@validitylabs.org>
 */

pragma solidity 0.5.7;












contract ExporoToken is Ownable, ERC20Snapshot, ERC20Detailed, ERC20Burnable, ERC20ForcedTransfer, ERC20Whitelist, ERC20BatchSend, ERC20Pausable, ERC20DocumentRegistry {
    /*** FUNCTIONS ***/
    /**
    * @dev constructor
    * @param _name string
    * @param _symbol string
    * @param _decimal uint8
    * @param _whitelist address
    * @param _initialSupply uint256 initial total supply cap. can be 0
    * @param _recipient address to recieve the tokens
    */
    /* solhint-disable */
    constructor(string memory _name, string memory _symbol, uint8 _decimal, address _whitelist, uint256 _initialSupply, address _recipient)
        public 
        ERC20Detailed(_name, _symbol, _decimal) {
            _mint(_recipient, _initialSupply);

            whitelist = GlobalWhitelist(_whitelist);
        }
    /* solhint-enable */
}