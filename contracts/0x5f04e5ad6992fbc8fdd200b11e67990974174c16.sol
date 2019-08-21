pragma solidity 0.4.25;


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title ERC664Balances interface
 * @dev see https://github.com/ethereum/EIPs/issues/644
 */
interface IERC664Balances {
    function getBalance(address _acct) external view returns(uint balance);

    function incBalance(address _acct, uint _val) external returns(bool success);

    function decBalance(address _acct, uint _val) external returns(bool success);

    function getAllowance(address _owner, address _spender) external view returns(uint remaining);

    function setApprove(address _sender, address _spender, uint256 _value) external returns(bool success);

    function decApprove(address _from, address _spender, uint _value) external returns(bool success);

    function getModule(address _acct) external view returns (bool success);

    function setModule(address _acct, bool _set) external returns(bool success);

    function getTotalSupply() external view returns(uint);

    function incTotalSupply(uint _val) external returns(bool success);

    function decTotalSupply(uint _val) external returns(bool success);

    function transferRoot(address _new) external returns(bool success);

    event BalanceAdj(address indexed Module, address indexed Account, uint Amount, string Polarity);

    event ModuleSet(address indexed Module, bool indexed Set);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two numbers, reverts on overflow.
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
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


/**
 * @title Owned
 * @author Adria Massanet <adria@codecontext.io>
 * @notice The Owned contract has an owner address, and provides basic
 *  authorization control functions, this simplifies & the implementation of
 *  user permissions; this contract has three work flows for a change in
 *  ownership, the first requires the new owner to validate that they have the
 *  ability to accept ownership, the second allows the ownership to be
 *  directly transferred without requiring acceptance, and the third allows for
 *  the ownership to be removed to allow for decentralization
 */
contract Owned {

    address public owner;
    address public newOwnerCandidate;

    event OwnershipRequested(address indexed by, address indexed to);
    event OwnershipTransferred(address indexed from, address indexed to);
    event OwnershipRemoved();

    /**
     * @dev The constructor sets the `msg.sender` as the`owner` of the contract
     */
    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev `owner` is the only address that can call a function with this
     * modifier
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev In this 1st option for ownership transfer `proposeOwnership()` must
     *  be called first by the current `owner` then `acceptOwnership()` must be
     *  called by the `newOwnerCandidate`
     * @notice `onlyOwner` Proposes to transfer control of the contract to a
     *  new owner
     * @param _newOwnerCandidate The address being proposed as the new owner
     */
    function proposeOwnership(address _newOwnerCandidate) external onlyOwner {
        newOwnerCandidate = _newOwnerCandidate;
        emit OwnershipRequested(msg.sender, newOwnerCandidate);
    }

    /**
     * @notice Can only be called by the `newOwnerCandidate`, accepts the
     *  transfer of ownership
     */
    function acceptOwnership() external {
        require(msg.sender == newOwnerCandidate);

        address oldOwner = owner;
        owner = newOwnerCandidate;
        newOwnerCandidate = 0x0;

        emit OwnershipTransferred(oldOwner, owner);
    }

    /**
     * @dev In this 2nd option for ownership transfer `changeOwnership()` can
     *  be called and it will immediately assign ownership to the `newOwner`
     * @notice `owner` can step down and assign some other address to this role
     * @param _newOwner The address of the new owner
     */
    function changeOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != 0x0);

        address oldOwner = owner;
        owner = _newOwner;
        newOwnerCandidate = 0x0;

        emit OwnershipTransferred(oldOwner, owner);
    }

    /**
     * @dev In this 3rd option for ownership transfer `removeOwnership()` can
     *  be called and it will immediately assign ownership to the 0x0 address;
     *  it requires a 0xdece be input as a parameter to prevent accidental use
     * @notice Decentralizes the contract, this operation cannot be undone
     * @param _dac `0xdac` has to be entered for this function to work
     */
    function removeOwnership(address _dac) external onlyOwner {
        require(_dac == 0xdac);
        owner = 0x0;
        newOwnerCandidate = 0x0;
        emit OwnershipRemoved();
    }
}

/**
 * @title Safe Guard Contract
 * @author Panos
 */
contract SafeGuard is Owned {

    event Transaction(address indexed destination, uint value, bytes data);

    /**
     * @dev Allows owner to execute a transaction.
     */
    function executeTransaction(address destination, uint value, bytes data)
    public
    onlyOwner
    {
        require(externalCall(destination, value, data.length, data));
        emit Transaction(destination, value, data);
    }

    /**
     * @dev call has been separated into its own function in order to take advantage
     *  of the Solidity's code generator to produce a loop that copies tx.data into memory.
     */
    function externalCall(address destination, uint value, uint dataLength, bytes data)
    private
    returns (bool) {
        bool result;
        assembly { // solhint-disable-line no-inline-assembly
            let x := mload(0x40)   // "Allocate" memory for output
            // (0x40 is where "free memory" pointer is stored by convention)
            let d := add(data, 32) // First 32 bytes are the padded length of data, so exclude that
            result := call(
            sub(gas, 34710), // 34710 is the value that solidity is currently emitting
            // It includes callGas (700) + callVeryLow (3, to pay for SUB) + callValueTransferGas (9000) +
            // callNewAccountGas (25000, in case the destination address does not exist and needs creating)
            destination,
            value,
            d,
            dataLength, // Size of the input (in bytes) - this is what fixes the padding problem
            x,
            0                  // Output is ignored, therefore the output size is zero
            )
        }
        return result;
    }
}

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

    constructor (string name, string symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns (string) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
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
     * @dev Transfer tokens from one address to another
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
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
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
        // this function needs to emit an event with the updated approval.
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
    }
}


/**
 * @title ERC664 Standard Balances Contract
 * @author chrisfranko
 */
contract ERC664Balances is IERC664Balances, SafeGuard {
    using SafeMath for uint256;

    uint256 public totalSupply;

    event BalanceAdj(address indexed module, address indexed account, uint amount, string polarity);
    event ModuleSet(address indexed module, bool indexed set);

    mapping(address => bool) public modules;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowed;

    modifier onlyModule() {
        require(modules[msg.sender]);
        _;
    }

    /**
     * @notice Constructor to create ERC664Balances
     * @param _initialAmount Database initial amount
     */
    constructor(uint256 _initialAmount) public {
        balances[msg.sender] = _initialAmount;
        totalSupply = _initialAmount;
        emit BalanceAdj(address(0), msg.sender, _initialAmount, "+");
    }

    /**
     * @notice Set allowance of `_spender` in behalf of `_sender` at `_value`
     * @param _sender Owner account
     * @param _spender Spender account
     * @param _value Value to approve
     * @return Operation status
     */
    function setApprove(address _sender, address _spender, uint256 _value) external onlyModule returns (bool) {
        allowed[_sender][_spender] = _value;
        return true;
    }

    /**
     * @notice Decrease allowance of `_spender` in behalf of `_from` at `_value`
     * @param _from Owner account
     * @param _spender Spender account
     * @param _value Value to decrease
     * @return Operation status
     */
    function decApprove(address _from, address _spender, uint _value) external onlyModule returns (bool) {
        allowed[_from][_spender] = allowed[_from][_spender].sub(_value);
        return true;
    }

    /**
    * @notice Increase total supply by `_val`
    * @param _val Value to increase
    * @return Operation status
    */
    function incTotalSupply(uint _val) external onlyOwner returns (bool) {
        totalSupply = totalSupply.add(_val);
        return true;
    }

    /**
     * @notice Decrease total supply by `_val`
     * @param _val Value to decrease
     * @return Operation status
     */
    function decTotalSupply(uint _val) external onlyOwner returns (bool) {
        totalSupply = totalSupply.sub(_val);
        return true;
    }

    /**
     * @notice Set/Unset `_acct` as an authorized module
     * @param _acct Module address
     * @param _set Module set status
     * @return Operation status
     */
    function setModule(address _acct, bool _set) external onlyOwner returns (bool) {
        modules[_acct] = _set;
        emit ModuleSet(_acct, _set);
        return true;
    }

    /**
     * @notice Change database owner
     * @param _newOwner The new owner address
     */
    function transferRoot(address _newOwner) external onlyOwner returns(bool) {
        owner = _newOwner;
        return true;
    }

    /**getBalance
     * @notice Get `_acct` balance
     * @param _acct Target account to get balance.
     * @return The account balance
     */
    function getBalance(address _acct) external view returns (uint256) {
        return balances[_acct];
    }

    /**
     * @notice Get allowance of `_spender` in behalf of `_owner`
     * @param _owner Owner account
     * @param _spender Spender account
     * @return Allowance
     */
    function getAllowance(address _owner, address _spender) external view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
     * @notice Get if `_acct` is an authorized module
     * @param _acct Module address
     * @return Operation status
     */
    function getModule(address _acct) external view returns (bool) {
        return modules[_acct];
    }

    /**
     * @notice Get total supply
     * @return Total supply
     */
    function getTotalSupply() external view returns (uint256) {
        return totalSupply;
    }

    /**
     * @notice Increment `_acct` balance by `_val`
     * @param _acct Target account to increment balance.
     * @param _val Value to increment
     * @return Operation status
     */
    function incBalance(address _acct, uint _val) public onlyModule returns (bool) {
        balances[_acct] = balances[_acct].add(_val);
        emit BalanceAdj(msg.sender, _acct, _val, "+");
        return true;
    }

    /**
     * @notice Decrement `_acct` balance by `_val`
     * @param _acct Target account to decrement balance.
     * @param _val Value to decrement
     * @return Operation status
     */
    function decBalance(address _acct, uint _val) public onlyModule returns (bool) {
        balances[_acct] = balances[_acct].sub(_val);
        emit BalanceAdj(msg.sender, _acct, _val, "-");
        return true;
    }
}

/**
 * @title ERC664 Database Contract
 * @author Panos
 */
contract DStore is ERC664Balances {

    /**
     * @notice Database construction
     * @param _totalSupply The total supply of the token
     */
    constructor(uint256 _totalSupply) public
    ERC664Balances(_totalSupply) {

    }

    /**
     * @notice Increase total supply by `_val`
     * @param _val Value to increase
     * @return Operation status
     */
    // solhint-disable-next-line no-unused-vars
    function incTotalSupply(uint _val) external onlyOwner returns (bool) {
        return false;
    }

    /**
     * @notice Decrease total supply by `_val`
     * @param _val Value to decrease
     * @return Operation status
     */
    // solhint-disable-next-line no-unused-vars
    function decTotalSupply(uint _val) external onlyOwner returns (bool) {
        return false;
    }

    /**
     * @notice moving `_amount` from `_from` to `_to`
     * @param _from The sender address
     * @param _to The receiving address
     * @param _amount The moving amount
     * @return bool The move result
     */
    function move(address _from, address _to, uint256 _amount) external
    onlyModule
    returns (bool) {
        balances[_from] = balances[_from].sub(_amount);
        emit BalanceAdj(msg.sender, _from, _amount, "-");
        balances[_to] = balances[_to].add(_amount);
        emit BalanceAdj(msg.sender, _to, _amount, "+");
        return true;
    }

    /**
     * @notice Increase allowance of `_spender` in behalf of `_from` at `_value`
     * @param _from Owner account
     * @param _spender Spender account
     * @param _value Value to increase
     * @return Operation status
     */
    function incApprove(address _from, address _spender, uint _value) external onlyModule returns (bool) {
        allowed[_from][_spender] = allowed[_from][_spender].add(_value);
        return true;
    }

    /**
     * @notice Increment `_acct` balance by `_val`
     * @param _acct Target account to increment balance.
     * @param _val Value to increment
     * @return Operation status
     */
    // solhint-disable-next-line no-unused-vars
    function incBalance(address _acct, uint _val) public
    onlyModule
    returns (bool) {
        return false;
    }

    /**
     * @notice Decrement `_acct` balance by `_val`
     * @param _acct Target account to decrement balance.
     * @param _val Value to decrement
     * @return Operation status
     */
    // solhint-disable-next-line no-unused-vars
    function decBalance(address _acct, uint _val) public
    onlyModule
    returns (bool) {
        return false;
    }
}

/**
 * @title PreDeriveum
 * @dev The Deriveum pre token.
 *
 */
contract PreDeriveum is ERC20, ERC20Detailed, SafeGuard {
    uint256 public constant INITIAL_SUPPLY = 10000000000;
    DStore public tokenDB;

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     */
    constructor () public ERC20Detailed("Pre-Deriveum", "PDER", 0) {
        tokenDB = new DStore(INITIAL_SUPPLY);
        require(tokenDB.setModule(address(this), true));
        require(tokenDB.move(address(this), msg.sender, INITIAL_SUPPLY));
        require(tokenDB.transferRoot(msg.sender));
        emit Transfer(address(0), msg.sender, INITIAL_SUPPLY);
    }

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return tokenDB.getTotalSupply();
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns (uint256) {
        return tokenDB.getBalance(owner);
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return tokenDB.getAllowance(owner, spender);
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

        require(tokenDB.setApprove(msg.sender, spender, value));
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        uint256 allow = tokenDB.getAllowance(from, msg.sender);
        allow = allow.sub(value);
        require(tokenDB.setApprove(from, msg.sender, allow));
        _transfer(from, to, value);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        uint256 allow = tokenDB.getAllowance(msg.sender, spender);
        allow = allow.add(addedValue);
        require(tokenDB.setApprove(msg.sender, spender, allow));
        emit Approval(msg.sender, spender, allow);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        uint256 allow = tokenDB.getAllowance(msg.sender, spender);
        allow = allow.sub(subtractedValue);
        require(tokenDB.setApprove(msg.sender, spender, allow));
        emit Approval(msg.sender, spender, allow);
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

        require(tokenDB.move(from, to, value));
        emit Transfer(from, to, value);
    }
}