// File: contracts-separate/Ownable.sol

pragma solidity >=0.4.25 <0.6.0;

contract Ownable {
    //이 contract가 owner로 갖고있는 address는 단 하나
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    //현재 call을 보낸(contract를 작성한) 주소가 owner이다.
    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can execute this function");
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner; //owner transferred
        newOwner = address(0); // newOwner address to 0x0
    }
}

// File: contracts-separate/Freezable.sol

pragma solidity >=0.4.25 <0.6.0;


contract Freezable is Ownable { 
    mapping (address => bool) internal isFrozen;
        
    uint256 public _unfreezeDateTime = 1559390400; // 06/01/2019 @ 12:00pm (UTC) || https://www.unixtimestamp.com

    event globalUnfreezeDatetimeModified(uint256);
    event FreezeFunds(address target, bool frozen);

    /**
     * Modifier for checking if the account is not frozen
     */
    modifier onlyNotFrozen(address a) {
        require(!isFrozen[a], "Any account in this function must not be frozen");
        _;
    }

    /**
     * Modifier for checking if the ICO freezing period has ended so that transactions can be accepted.
     */
    modifier onlyAfterUnfreeze() {
        require(block.timestamp >= _unfreezeDateTime, "You cannot tranfer tokens before unfreeze date" );
        _;
    }
    /**
    * @dev Total number of tokens in existence
    */
    function getUnfreezeDateTime() public view returns (uint256) {
        return _unfreezeDateTime;
    }

    /**
     * @dev set Unfreeze date for every users.
     * @param unfreezeDateTime The given date and time for unfreezing all the existing accounts.
     */
    function setUnfreezeDateTime(uint256 unfreezeDateTime) onlyOwner public {
        _unfreezeDateTime = unfreezeDateTime;
        emit globalUnfreezeDatetimeModified(unfreezeDateTime); 
    }

    /**
     * @dev Gets the freezing status of the account, not relevant with the _unfreezeDateTime
     */
    function isAccountFrozen( address target ) public view returns (bool) {
        return isFrozen[target];
    }

    /**
     * @dev Internal function that freezes the given address
     * @param target The account that will be frozen/unfrozen.
     * @param doFreeze to freeze or unfreeze.
     */
    function freeze(address target, bool doFreeze) onlyOwner public {
        if( msg.sender == target ) {
            revert();
        }

        isFrozen[target] = doFreeze;
        emit FreezeFunds(target, doFreeze);
    }
}

// File: contracts-separate/SafeMath.sol

pragma solidity >=0.4.25 <0.6.0;
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

// File: contracts-separate/IERC20.sol

pragma solidity >=0.4.25 <0.6.0;

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

// File: contracts-separate/TokenStorage.sol

pragma solidity >=0.4.25 <0.6.0;
 

contract TokenStorage  {
    uint256 internal _totalSupply;
    mapping (address => uint256) internal _balances;
    mapping (address => mapping(address => uint256)) internal _allowed;
}

// File: contracts-separate/AddressGuard.sol

pragma solidity >=0.4.25 <0.6.0;

contract AddressGuard {
    modifier onlyAddressNotZero(address addr) {
        require(addr != address(0), "The address must not be 0x0");
        _;   
    }
}

// File: contracts-separate/TokenRescue.sol

pragma solidity >=0.4.25 <0.6.0;




/**
 * @title TokenRescue
 * @dev Rescue the lost ERC20 token
 * inspred by DreamTeamToken
 */
contract TokenRescue is Ownable, AddressGuard {
    address internal rescueAddr;

    modifier onlyRescueAddr {
        require(msg.sender == rescueAddr);
        _;
    }

    function setRescueAddr(address addr) onlyAddressNotZero(addr) onlyOwner public{
        rescueAddr = addr;
    }

    function getRescueAddr() public view returns(address) {
        return rescueAddr;
    }

    function rescueLostTokensByOwn(IERC20 lostTokenContract, uint256 value) external onlyRescueAddr {
        lostTokenContract.transfer(rescueAddr, value);
    }

    function rescueLostTokenByThisTokenOwner (IERC20 lostTokenContract, uint256 value) external onlyOwner {
        lostTokenContract.transfer(rescueAddr, value);
    } 
    
}

// File: contracts-separate/FinentToken.sol

pragma solidity >=0.4.25 <0.6.0;









/**
 * @title FinentToken
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * 
 This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
contract FinentToken is IERC20, Ownable, Freezable, TokenStorage, AddressGuard, TokenRescue {
    using SafeMath for uint256;
    string private _name;

    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;

    /**
     * @dev Constructor of FinentToken
     */
    constructor() public {
        _name = "Finent Token";
        _symbol = "FNT";
        _decimals = 18; //normal...
        _mint(msg.sender, 1000000000 * 10 ** uint256(_decimals));
    }

    /**
    * @dev Gets the name of the token
    */
    function name() public view returns (string memory) {
        return _name;
    }
    
    /**
    * @dev Gets the symbol of the token
    */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
    * @dev Gets the decimals of the token
    */
    function decimals() public view returns (uint256) {
        return _decimals;
    }

    /**
     * @dev Gets the balance of address zero
     */
    function balanceOfZero() public view returns (uint256) {
        return _balances[address(0)];
    }

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply - _balances[address(0)];
    }

    
    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) onlyAddressNotZero(owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) onlyAddressNotZero(owner) onlyAddressNotZero(spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) onlyNotFrozen(msg.sender) onlyNotFrozen(_to) onlyAfterUnfreeze onlyAddressNotZero(_to) public returns (bool) {
        _transfer(msg.sender, _to, _value);
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
    function approve(address spender, uint256 value) public onlyAddressNotZero(spender) returns (bool) {
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) onlyNotFrozen(msg.sender) onlyNotFrozen(_from) onlyNotFrozen(_to) onlyAfterUnfreeze public returns (bool) {
        _allowed[_from][msg.sender] = _allowed[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        emit Approval(_from, msg.sender, _allowed[_from][msg.sender]);
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
    function increaseAllowance(address spender, uint256 addedValue) onlyAddressNotZero(spender) public returns (bool) {
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
    function decreaseAllowance(address spender, uint256 subtractedValue) onlyAddressNotZero(spender) public returns (bool) {
        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev burn token from specific addr
     * @param addr The given addr to burn the token from.
     * @param value The amount to be burnt.
     */
    function burn(address addr, uint256 value) onlyOwner onlyAddressNotZero(addr) public {
        _burn(addr, value);
    }

    /**
     * @dev burn token from owner
     * @param value The amount to be burnt.
     */
    function burnFromOwner(uint256 value) onlyOwner public {
        _burn(msg.sender, value);
    }

    /**
     * @dev mint token from owner
     * @param value The amount to be minted.
     */
    function mint(uint256 value) onlyOwner public {
        _mint(msg.sender, value);
    }

    /**
     * @dev distribute token to addr and determine to freeze or not
     * @param addr The given addr to distribute the token.
     * @param value The amount to be distributed
     * @param doFreeze to freeze or unfreeze
     */
    function distribute(address addr, uint256 value, bool doFreeze) onlyOwner public {
        _distribute(addr, value, doFreeze);
    }

    /**
    * @dev Transfer token for a specified addresses
    * @param _from The address to transfer from.
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function _transfer(address _from, address _to, uint256 _value) internal {
        _balances[_from] = _balances[_from].sub(_value);
        _balances[_to] = _balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
    }

    /**
    * @dev Distribute token for a specified addresses
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    * @param doFreeze to freeze or unfreeze.
    */
    function _distribute(address to, uint256 value, bool doFreeze) onlyOwner internal {
        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);

        if( doFreeze && msg.sender != to ) {
            freeze( to, true );
        }

        emit Transfer(msg.sender, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
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

    
    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () external payable {
        revert();
    }

}