pragma solidity 0.5.8;

/**
 * @title SafeMath 
 * @dev Unsigned math operations with safety checks that revert on error.
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
     * @dev Subtracts two unsigned integers, reverts on underflow (i.e. if subtrahend is greater than minuend).
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
}

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

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
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
        require(isOwner(), "The caller must be owner");
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
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
        require(newOwner != address(0), "Cannot transfer control of the contract to the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @title Standard ERC20 token
 * @dev Implementation of the basic standard token.
 */
contract StandardToken is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;

    mapping (address => mapping (address => uint256)) internal _allowed;

    uint256 internal _totalSupply;
    
    /**
     * @dev Total number of tokens in existence.
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
     * @dev Transfer token to a specified address.
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
     * @dev Transfer token for a specified address.
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "Cannot transfer to the zero address");

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * @dev Approve an address to spend another addresses' tokens.
     * @param owner The address that owns the tokens.
     * @param spender The address that will spend the tokens.
     * @param value The number of tokens that can be spent.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0), "Cannot approve to the zero address");
        require(owner != address(0), "Setter cannot be the zero address");

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

}

/**
 *  @title FreezableToken
 */
contract FreezableToken is StandardToken, Ownable {
    mapping(address=>bool) internal _frozenAccount;

    event FrozenAccount(address indexed target, bool frozen);

    /**
     * @dev Returns whether the specified address is frozen.
     * @param account A specified address.
     */
    function frozenAccount(address account) public view returns(bool){
        return _frozenAccount[account];
    }

    /**
     * @dev Check if the specified address is frozen. Requires the specified address not to be frozen.
     * @param account A specified address.
     */
    function frozenCheck(address account) internal view {
        require(!frozenAccount(account), "Address has been frozen");
    }

    /**
     * @dev Modify the frozen status of the specified address.
     * @param account A specified address.
     * @param frozen Frozen status, true: freeze, false: unfreeze.
     */
    function freeze(address account, bool frozen) public onlyOwner {
  	    _frozenAccount[account] = frozen;
  	    emit FrozenAccount(account, frozen);
    }

    /**
     * @dev Rewrite the transfer function to check if the address participating is frozen.
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        frozenCheck(msg.sender);
        frozenCheck(_to);
        return super.transfer(_to, _value);
    }

    /**
     * @dev Rewrite the transferFrom function to check if the address participating is frozen.
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        frozenCheck(msg.sender);
        frozenCheck(_from);
        frozenCheck(_to);
        return super.transferFrom(_from, _to, _value);
    }    

    /**
     * @dev Rewrite the _approve function to check if the address participating is frozen.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        frozenCheck(owner);
        frozenCheck(spender);
        super._approve(owner, spender, value);
    }

}

/**
 * @title MintableToken
 * @dev Implement the function of ERC20 token minting.
 */
contract MintableToken is FreezableToken {
    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0), "Cannot mint to the zero address");

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Function to mint tokens
     * @param to The address that will receive the minted tokens.
     * @param value The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address to, uint256 value) public onlyOwner returns (bool) {
        frozenCheck(to);
        _mint(to, value);
        return true;
    }
}

/**
 * @title BurnableToken
 * @dev Implement the function of ERC20 token burning.
 */
contract BurnableToken is FreezableToken {

    /**
    * @dev Burns a specific amount of tokens.
    * @param _value The amount of token to be burned.
    */
    function burn(uint256 _value) public onlyOwner {
        _burn(msg.sender, _value);
    }

    /**
    * @dev Burns a specific amount of tokens from the target address and decrements allowance
    * @param _from address The address which you want to send tokens from
    * @param _value uint256 The amount of token to be burned
    */
    function burnFrom(address _from, uint256 _value) public onlyOwner {
        require(_value <= _allowed[_from][msg.sender], "Not enough allowance");
        _allowed[_from][msg.sender] = _allowed[_from][msg.sender].sub(_value);
        _burn(_from, _value);
    }

    function _burn(address _who, uint256 _value) internal {
        require(_value <= _balances[_who], "Not enough token balance");
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure
        _balances[_who] = _balances[_who].sub(_value);
        _totalSupply = _totalSupply.sub(_value);
        emit Transfer(_who, address(0), _value);
    }
}

contract GGCToken is MintableToken, BurnableToken {
    string public constant name = "Global Gold Coins"; // name of Token 
    string public constant symbol = "GGC"; // symbol of Token 
    uint8 public constant decimals = 18;

    /**
     * @dev Transfer tokens to multiple addresses.
     */
    function airdrop(address[] memory addressList, uint256[] memory amountList) public onlyOwner returns (bool) {
        uint256 length = addressList.length;
        require(addressList.length == amountList.length, "Inconsistent array length");
        require(length > 0 && length <= 150, "Invalid number of transfer objects");
        uint256 amount;
        for (uint256 i = 0; i < length; i++) {
            frozenCheck(addressList[i]);
            require(amountList[i] > 0, "The transfer amount cannot be 0");
            require(addressList[i] != address(0), "Cannot transfer to the zero address");
            amount = amount.add(amountList[i]);
            _balances[addressList[i]] = _balances[addressList[i]].add(amountList[i]);
            emit Transfer(msg.sender, addressList[i], amountList[i]);
        }
        require(_balances[msg.sender] >= amount, "Not enough tokens to transfer");
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        return true;
    }        
}