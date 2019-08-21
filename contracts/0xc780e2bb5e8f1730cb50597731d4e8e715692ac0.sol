pragma solidity ^0.4.24;

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
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        //        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        //        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract ERC20Interface {

    // Getters
    function totalSupply() public view returns (uint);

    function balanceOf(address tokenOwner) public view returns (uint balance);

    function allowance(address tokenOwner, address spender) public view returns (uint remaining);

    // Write the State
    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    // Events
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}

contract ERC20 is ERC20Interface {

    // Link the SafeMath library
    using SafeMath for uint;

    // declare the storage
    mapping(address => mapping(address => uint)) private _allowance;
    mapping(address => uint) internal _balanceOf;

    uint internal _totalSupply;

    uint8 public constant decimals = 18;

    function _transfer(address from, address to, uint tokens) private returns (bool success) {
        _balanceOf[from] = _balanceOf[from].sub(tokens);
        _balanceOf[to] = _balanceOf[to].add(tokens);

        success = true;

        emit Transfer(from, to, tokens);
    }

    // Getters
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    function balanceOf(address tokenOwner) public view returns (uint balance) {
        balance = _balanceOf[tokenOwner];
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        remaining = _allowance[tokenOwner][spender];
        return remaining;
    }

    // Write the State
    function transfer(address to, uint tokens) public returns (bool success) {
        success = _transfer(msg.sender, to, tokens);
    }

    function approve(address spender, uint tokens) public returns (bool success) {
        _allowance[msg.sender][spender] = tokens;

        success = true;

        emit Approval(msg.sender, spender, tokens);
    }

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        _allowance[from][msg.sender] = _allowance[from][msg.sender].sub(tokens);

        success = _transfer(from, to, tokens);
    }

}

contract Ownerable {
    address public owner;

    constructor () public {
        owner = msg.sender;
    }

    function setOwner(address newOwner) onlyOwner public {
        owner = newOwner;
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Only owner can perform this tx.");
        _;
    }
}

contract CryptoDa is ERC20, Ownerable {
    string public constant name = "CryptoDa";
    string public constant symbol = "CDA";

    address public issuer = address(0);

    constructor (address _issuer) public {
        _totalSupply = 5000000 ether;
        issuer = _issuer;
        _balanceOf[issuer] = _totalSupply;
    }

    function setIssuer(address newIssuer) public onlyOwner returns (bool success){
        require(newIssuer != address(0), "Cannot set 0x0 as a new issuer address.");

        if (issuer != address(0)) {
            _balanceOf[newIssuer] = _balanceOf[issuer];
            _balanceOf[issuer] = 0;
        }

        issuer = newIssuer;

        success = true;
    }
}