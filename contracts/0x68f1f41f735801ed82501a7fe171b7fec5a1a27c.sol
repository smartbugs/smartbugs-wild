pragma solidity ^0.5.2;
// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : dave@akomba.com
// released under Apache 2.0 licence
// input  /Users/GustavoIbarra/Projects/Solidity/blockchain-asset-registry/contracts/vRC20.sol
// flattened :  Thursday, 11-Apr-19 23:33:19 UTC
interface IVersioned {
    event AppendedData( string data, uint256 versionIndex );

    /*
    * @dev fallback function
    */
    function() external;

    /**
    * @dev Appends data to a string[] list
    * @param _data any string. Could be an IPFS hash
    */
    function appendData(string calldata _data) external returns (bool);

    /**
    * @dev Gets the current index of the data list
    */
    function getVersionIndex() external view returns (uint count);
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

contract Ownable {

    /**
    * @dev The current owner of the contract
    */
    address payable private _owner;
    
    /**
    * @dev A list of the contract owners
    */
    address[] private _owners;

    /**
    * @dev The pending owner. 
    * The current owner must have transferred the contract to this address
    * The pending owner must claim the ownership
    */
    address payable private _pendingOwner;

    /**
    * @dev A list of addresses that are allowed to transfer 
    * the contract ownership on behalf of the current owner
    */
    mapping (address => mapping (address => bool)) internal allowed;

    event PendingTransfer( address indexed owner, address indexed pendingOwner );
    event OwnershipTransferred( address indexed previousOwner, address indexed newOwner );
    event Approval( address indexed owner, address indexed trustee );
    event RemovedApproval( address indexed owner, address indexed trustee );

    /**
    * @dev Modifier throws if called by any account other than the pendingOwner.
    */
    modifier onlyPendingOwner {
        require(isPendingOwner());
        _;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
    * @dev The Asset constructor sets the original `owner` 
    * of the contract to the sender account.
    */
    constructor() public {
        _owner = msg.sender;
        _owners.push(_owner);
        emit OwnershipTransferred(address(0), _owner);
    }

    /*
    * @dev fallback function
    */
    function() external {}

    /**
     * @return the set asset owner
     */
    function owner() public view returns (address payable) {
        return _owner;
    }
    
    /**
     * @return the set asset owner
     */
    function owners() public view returns (address[] memory) {
        return _owners;
    }
    
    /**
     * @return the set asset pendingOwner
     */
    function pendingOwner() public view returns (address) {
        return _pendingOwner;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }
    
    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isPendingOwner() public view returns (bool) {
        return msg.sender == _pendingOwner;
    }

    /**
    * @dev Allows the current owner to set the pendingOwner address.
    * @param pendingOwner_ The address to transfer ownership to.
    */
    function transferOwnership(address payable pendingOwner_) onlyOwner public {
        _pendingOwner = pendingOwner_;
        emit PendingTransfer(_owner, _pendingOwner);
    }


    /**
    * @dev Allows an approved trustee to set the pendingOwner address.
    * @param pendingOwner_ The address to transfer ownership to.
    */
    function transferOwnershipFrom(address payable pendingOwner_) public {
        require(allowance(msg.sender));
        _pendingOwner = pendingOwner_;
        emit PendingTransfer(_owner, _pendingOwner);
    }

    /**
    * @dev Allows the pendingOwner address to finalize the transfer.
    */
    function claimOwnership() onlyPendingOwner public {
        _owner = _pendingOwner;
        _owners.push(_owner);
        _pendingOwner = address(0);
        emit OwnershipTransferred(_owner, _pendingOwner);
    }

    /**
    * @dev Approve the passed address to transfer the Asset on behalf of msg.sender.
    * @param trustee The address which will spend the funds.
    */
    function approve(address trustee) onlyOwner public returns (bool) {
        allowed[msg.sender][trustee] = true;
        emit Approval(msg.sender, trustee);
        return true;
    }

    /**
    * @dev Approve the passed address to transfer the Asset on behalf of msg.sender.
    * @param trustee The address which will spend the funds.
    */
    function removeApproval(address trustee) onlyOwner public returns (bool) {
        allowed[msg.sender][trustee] = false;
        emit RemovedApproval(msg.sender, trustee);
        return true;
    }

    /**
    * @dev Function to check if a trustee is allowed to transfer on behalf the owner
    * @param trustee address The address which will spend the funds.
    * @return A bool specifying if the trustee can still transfer the Asset
    */
    function allowance(address trustee) public view returns (bool) {
        return allowed[_owner][trustee];
    }
}

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

contract Versioned is IVersioned {

    string[] public data;
    
    event AppendedData( 
        string data, 
        uint256 versionIndex
    );

    /*
    * @dev fallback function
    */
    function() external {}

    /**
    * @dev Add data to the _data array
    * @param _data string data
    */
    function appendData(string memory _data) public returns (bool) {
        return _appendData(_data);
    }
    
    /**
    * @dev Add data to the _data array
    * @param _data string data
    */
    function _appendData(string memory _data) internal returns (bool) {
        data.push(_data);
        emit AppendedData(_data, getVersionIndex());
        return true;
    }

    /**
    * @dev Gets the current index of the data list
    */
    function getVersionIndex() public view returns (uint count) {
        return data.length - 1;
    }
}

contract vRC20 is ERC20, ERC20Detailed, Versioned, Ownable {

    constructor (
        uint256 supply,
        string memory name,
        string memory symbol,
        uint8 decimals
    ) public ERC20Detailed (name, symbol, decimals) {
        _mint(msg.sender, supply);
    }

    /**
    * @dev Add data to the _data array
    * @param _data string data
    */
    function appendData(string memory _data) public onlyOwner returns (bool) {
        return _appendData(_data);
    }
}