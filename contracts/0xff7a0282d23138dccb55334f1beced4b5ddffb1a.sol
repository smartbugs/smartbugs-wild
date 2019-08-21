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

// File: openzeppelin-solidity/contracts/access/roles/MinterRole.sol

pragma solidity ^0.5.2;


contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol

pragma solidity ^0.5.2;



/**
 * @title ERC20Mintable
 * @dev ERC20 minting logic
 */
contract ERC20Mintable is ERC20, MinterRole {
    /**
     * @dev Function to mint tokens
     * @param to The address that will receive the minted tokens.
     * @param value The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address to, uint256 value) public onlyMinter returns (bool) {
        _mint(to, value);
        return true;
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

// File: contracts/ComplianceService.sol

pragma solidity ^0.5.2;

/// @notice Standard interface for `ComplianceService`s
contract ComplianceService {

    /*
    * @notice This method *MUST* be called by `BlueshareToken`s during `transfer()` and `transferFrom()`.
    *         The implementation *SHOULD* check whether or not a transfer can be approved.
    *
    * @dev    This method *MAY* call back to the token contract specified by `_token` for
    *         more information needed to enforce trade approval.
    *
    * @param  _token The address of the token to be transfered
    * @param  _spender The address of the spender of the token
    * @param  _from The address of the sender account
    * @param  _to The address of the receiver account
    * @param  _amount The quantity of the token to trade
    *
    * @return uint8 The reason code: 0 means success.  Non-zero values are left to the implementation
    *               to assign meaning.
    */
    function check(address _token, address _spender, address _from, address _to, uint256 _amount) public returns (uint8);

    /*
    * @notice This method *MUST* be called by `BlueshareToken`s during `forceTransferFrom()`. 
    *         Accessible only by admins, used for forced tokens transfer
    *         The implementation *SHOULD* check whether or not a transfer can be approved.
    *
    * @dev    This method *MAY* call back to the token contract specified by `_token` for
    *         more information needed to enforce trade approval.
    *
    * @param  _token The address of the token to be transfered
    * @param  _spender The address of the spender of the token *Admin or Owner*
    * @param  _from The address of the sender account
    * @param  _to The address of the receiver account
    * @param  _amount The quantity of the token to trade
    *
    * @return uint8 The reason code: 0 means success.  Non-zero values are left to the implementation
    *               to assign meaning.
    */
    function forceCheck(address _token, address _spender, address _from, address _to, uint256 _amount) public returns (uint8);

    /**
    * @notice This method *MUST* be called by `BlueshareToken`s during  during `transfer()` and `transferFrom()`.
    *         The implementation *SHOULD* check whether or not a transfer can be approved.
    *
    * @dev    This method  *MAY* call back to the token contract specified by `_token` for
    *         information needed to enforce trade approval if needed
    *
    * @param  _token The address of the token to be transfered
    * @param  _spender The address of the spender of the token (unused in this implementation)
    * @param  _holder The address of the sender account, our holder
    * @param  _balance The balance of our holder
    * @param  _amount The amount he or she whants to send
    *
    * @return `true` if the trade should be approved and `false` if the trade should not be approved
    */
    function checkVested(address _token, address _spender, address _holder, uint256 _balance, uint256 _amount) public returns (bool);
}

// File: contracts/DividendService.sol

pragma solidity ^0.5.2;

/// @notice Standard interface for `DividendService`s
contract DividendService {

    /**
    * @param _token The address of the token assigned with this `DividendService`
    * @param _spender The address of the spender for this transaction
    * @param _holder The address of the holder of the token
    * @param _interval The time interval / year for which the dividends are paid or not
    * @return uint8 The reason code: 0 means not paid.  Non-zero values are left to the implementation
    *               to assign meaning.
    */
    function check(address _token, address _spender, address _holder, uint _interval) public returns (uint8);
}

// File: contracts/ServiceRegistry.sol

pragma solidity ^0.5.2;




/// @notice regulator - A service that points to a `ComplianceService` contract
/// @notice dividend - A service that points to a `DividendService` contract
contract ServiceRegistry is Ownable {
    address public regulator;
    address public dividend;

    /**
    * @notice Triggered when regulator or dividend service address is replaced
    */
    event ReplaceService(address oldService, address newService);

    /**
    * @dev Validate contract address
    * Credit: https://github.com/Dexaran/ERC223-token-standard/blob/Recommended/ERC223_Token.sol#L107-L114
    *
    * @param _addr The address of a smart contract
    */
    modifier withContract(address _addr) {
        uint length;
        assembly { length := extcodesize(_addr) }
        require(length > 0);
        _;
    }

    /**
    * @notice Constructor
    *
    * @param _regulator The address of the `ComplianceService` contract
    * @param _dividend The address of the `DividendService` contract
    *
    */
    constructor(address _regulator, address _dividend) public {
        regulator = _regulator;
        dividend = _dividend;
    }

    /**
    * @notice Replaces the address pointer to the `ComplianceService` contract
    *
    * @dev This method is only callable by the contract's owner
    *
    * @param _regulator The address of the new `ComplianceService` contract
    */
    function replaceRegulator(address _regulator) public onlyOwner withContract(_regulator) {
        require(regulator != _regulator, "The address cannot be the same");

        address oldRegulator = regulator;
        regulator = _regulator;
        emit ReplaceService(oldRegulator, regulator);
    }

    /**
    * @notice Replaces the address pointer to the `DividendService` contract
    *
    * @dev This method is only callable by the contract's owner
    *
    * @param _dividend The address of the new `DividendService` contract
    */
    function replaceDividend(address _dividend) public onlyOwner withContract(_dividend) {
        require(dividend != _dividend, "The address cannot be the same");

        address oldDividend = dividend;
        dividend = _dividend;
        emit ReplaceService(oldDividend, dividend);
    }
}

// File: contracts/BlueshareToken.sol

pragma solidity ^0.5.2;







/// @notice An ERC-20 token that has the ability to check for trade validity
contract BlueshareToken is ERC20Detailed, ERC20Mintable, Ownable {

    /**
    * @notice Token decimals setting (used when constructing ERC20Detailed)
    */
    uint8 constant public BLUESHARETOKEN_DECIMALS = 0;

    /**
    * International Securities Identification Number (ISIN)
    */
    string constant public ISIN = "CH0465030796";

    /**
    * @notice Triggered when regulator checks pass or fail
    */
    event CheckComplianceStatus(uint8 reason, address indexed spender, address indexed from, address indexed to, uint256 value);

    /**
    * @notice Triggered when regulator checks pass or fail
    */
    event CheckVestingStatus(bool reason, address indexed spender, address indexed from, uint256 balance, uint256 value);

    /**
    * @notice Triggered when dividend checks pass or fail
    */
    event CheckDividendStatus(uint8 reason, address indexed spender, address indexed holder, uint interval);

    /**
    * @notice Address of the `ServiceRegistry` that has the location of the
    *         `ComplianceService` contract responsible for checking trade permissions and 
    *         `DividendService` contract responsible for checking dividend state.
    */
    ServiceRegistry public registry;

    /**
    * @notice Constructor
    *
    * @param _registry Address of `ServiceRegistry` contract
    * @param _name Name of the token: See ERC20Detailed
    * @param _symbol Symbol of the token: See ERC20Detailed
    */
    constructor(ServiceRegistry _registry, string memory _name, string memory _symbol) public
      ERC20Detailed(_name, _symbol, BLUESHARETOKEN_DECIMALS)
    {
        require(address(_registry) != address(0), "Uninitialized or undefined address");

        registry = _registry;
    }

    /**
    * @notice ERC-20 overridden function that include logic to check for trade validity.
    *
    * @param _to The address of the receiver
    * @param _value The number of tokens to transfer
    *
    * @return `true` if successful and `false` if unsuccessful
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_checkVested(msg.sender, balanceOf(msg.sender), _value), "Cannot send vested amount!");
        require(_check(msg.sender, _to, _value), "Cannot transfer!");

        return super.transfer(_to, _value);
    }

    /**
    * @notice ERC-20 overridden function that include logic to check for trade validity.
    *
    * @param _from The address of the sender
    * @param _to The address of the receiver
    * @param _value The number of tokens to transfer
    *
    * @return `true` if successful and `false` if unsuccessful
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_checkVested(_from, balanceOf(_from), _value), "Cannot send vested amount!");
        require(_check(_from, _to, _value), "Cannot transfer!");
        
        return super.transferFrom(_from, _to, _value);
    }

    /**
    * @notice ERC-20 extended function that include logic to check for trade validity with admin rights.
    *
    * @param _from The address of the old wallet
    * @param _to The address of the new wallet
    * @param _value The number of tokens to transfer
    *
    */
    function forceTransferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_forceCheck(_from, _to, _value), "Not allowed!");

        _transfer(_from, _to, _value);
        return true;
    }

    /**
    * @notice The public function for checking divident payout status
    *
    * @param _holder The address of the token's holder
    * @param _interval The interval for divident's status
    */
    function dividendStatus(address _holder, uint _interval) public returns (uint8) {
        return _checkDividend(_holder, _interval);
    }

    /**
    * @notice Performs the regulator check
    *
    * @dev This method raises a CheckComplianceStatus event indicating success or failure of the check
    *
    * @param _from The address of the sender
    * @param _to The address of the receiver
    * @param _value The number of tokens to transfer
    *
    * @return `true` if the check was successful and `false` if unsuccessful
    */
    function _check(address _from, address _to, uint256 _value) private returns (bool) {
        uint8 reason = _regulator().check(address(this), msg.sender, _from, _to, _value);

        emit CheckComplianceStatus(reason, msg.sender, _from, _to, _value);

        return reason == 0;
    }

    /**
    * @notice Performs the regulator forceCheck, accessable only by admins
    *
    * @dev This method raises a CheckComplianceStatus event indicating success or failure of the check
    *
    * @param _from The address of the sender
    * @param _to The address of the receiver
    * @param _value The number of tokens to transfer
    *
    * @return `true` if the check was successful and `false` if unsuccessful
    */
    function _forceCheck(address _from, address _to, uint256 _value) private returns (bool) {
        uint8 allowance = _regulator().forceCheck(address(this), msg.sender, _from, _to, _value);

        emit CheckComplianceStatus(allowance, msg.sender, _from, _to, _value);

        return allowance == 0;
    }

    /**
    * @notice Performs the regulator check
    *
    * @dev This method raises a CheckVestingStatus event indicating success or failure of the check
    *
    * @param _participant The address of the participant
    * @param _balance The balance of the sender
    * @param _value The number of tokens to transfer
    *
    * @return `true` if the check was successful and `false` if unsuccessful
    */
    function _checkVested(address _participant, uint256 _balance, uint256 _value) private returns (bool) {
        bool allowed = _regulator().checkVested(address(this), msg.sender, _participant, _balance, _value);

        emit CheckVestingStatus(allowed, msg.sender, _participant, _balance, _value);

        return allowed;
    }

    /**
    * @notice Performs the dividend check
    *
    * @dev This method raises a CheckDividendStatus event indicating success or failure of the check
    *
    * @param _address The address of the holder
    * @param _interval The time interval / year for which the dividends are paid or not
    *
    * @return `true` if the check was successful and `false` if unsuccessful
    */
    function _checkDividend(address _address, uint _interval) private returns (uint8) {
        uint8 status = _dividend().check(address(this), msg.sender, _address, _interval);

        emit CheckDividendStatus(status, msg.sender, _address, _interval);

        return status;
    }

    /**
    * @notice Retreives the address of the `ComplianceService` that manages this token.
    *
    * @dev This function *MUST NOT* memoize the `ComplianceService` address.  This would
    *      break the ability to upgrade the `ComplianceService`.
    *
    * @return The `ComplianceService` that manages this token.
    */
    function _regulator() public view returns (ComplianceService) {
        return ComplianceService(registry.regulator());
    }

    /**
    * @notice Retreives the address of the `DividendService` that manages this token.
    *
    * @dev This function *MUST NOT* memoize the `DividendService` address.  This would
    *      break the ability to upgrade the `DividendService`.
    *
    * @return The `DividendService` that manages this token.
    */
    function _dividend() public view returns (DividendService) {
        return DividendService(registry.dividend());
    }
}