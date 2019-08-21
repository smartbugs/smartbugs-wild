pragma solidity >=0.4.24 <0.6.0;

// Grabbed from OpenZeppelin: https://github.com/OpenZeppelin/openzeppelin-solidity

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

// Grabbed from OpenZeppelin: https://github.com/OpenZeppelin/openzeppelin-solidity

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

contract INX is IERC20{
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowed;
    uint256 internal _totalSupply;
    string public _name = "InnovaMinex";
    string public _symbol = "INX";
    uint8 public _decimals = 6;

    modifier validDestination( address to ) {
        require(to != address(0x0));
        require(to != address(this) );
        _;
    }

    modifier enoughFunds ( address from, uint256 amount ) {
        require(_balances[from]>=amount);
        _;
    }

    constructor() public {
        /*Don't assume contract balance is zero on creation: 
         * https://github.com/ConsenSys/smart-contract-best-practices/issues/61
         */
        require(address(this).balance == 0);
        
        //300 Million INX 
        uint INITIAL_SUPPLY = uint(300000000) * ( uint(10) ** _decimals);
        _totalSupply = INITIAL_SUPPLY;
        _balances[msg.sender] = INITIAL_SUPPLY;
    }


    function name() public view returns (string memory) {
        return _name;
    }


    function symbol() public view returns (string memory) {
        return _symbol;
    }


    function decimals() public view returns (uint) {
        return _decimals;
    }


    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint) {
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
    function transfer(address to, uint256 value) public validDestination(to) enoughFunds(msg.sender, value) returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brought the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. The solution applied to mitigate this
     * race condition is to require to first reset the spender's allowance to 0 and thenset the desired value 
     * afterwards: https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public validDestination(spender) enoughFunds(msg.sender, value) returns (bool) {
        //This method should only be called when no previous allowance exists for the spender or if it's being reset.
        //If a previous allowance exists, increaseAllowance() or decreaseAllowance() must be used instead.
        require(_allowed[msg.sender][spender] == 0 || value == 0);
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
    function transferFrom(address from, address to, uint256 value) public validDestination(to) enoughFunds(from, value) returns (bool) {
        require(_allowed[from][msg.sender]>=value);
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * existing allowed value it's required to use this function to avoid 2 calls 
     * (and wait until the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public validDestination(spender) returns (bool) {
        require(_allowed[msg.sender][spender] != 0 && addedValue != 0);
        uint finalAllowed = _allowed[msg.sender][spender].add(addedValue);
        require(_balances[msg.sender]>=finalAllowed);
        _allowed[msg.sender][spender] = finalAllowed;
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve must be called when allowed_[_spender] == 0. To decrement
     * allowed value it's required to use this function to avoid 2 calls 
     * (and wait until the first transaction is mined). 
     * IMPORTANT: However, to RESET the allowance to 0, approve is the method to be called.
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public validDestination(spender) returns (bool) {
        require(_allowed[msg.sender][spender] != 0 && subtractedValue != 0 && subtractedValue < _allowed[msg.sender][spender]);
        uint finalAllowed = _allowed[msg.sender][spender].sub(subtractedValue);
        require(_balances[msg.sender]>=finalAllowed);
        _allowed[msg.sender][spender] = finalAllowed;
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) private validDestination(to) enoughFunds(from, value){ 
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

}