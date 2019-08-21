pragma solidity ^0.4.25;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address tokenOwner) external view returns (uint256);
    function allowance(address tokenOwner, address spender) external view returns (uint256);
    function transfer(address to, uint256 tokenAmount) external returns (bool);
    function approve(address spender, uint256 tokenAmount) external returns (bool);
    function transferFrom(address from, address to, uint256 tokenAmount) external returns (bool);
    function burn(uint256 tokenAmount) external returns (bool success);
    function burnFrom(address from, uint256 tokenAmount) external returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokenAmount);
    event Approval(address indexed tokenHolder, address indexed spender, uint256 tokenAmount);
    event Burn(address indexed from, uint256 tokenAmount);
}

interface tokenRecipient {
    function receiveApproval(address from, uint256 tokenAmount, address token, bytes extraData) external;
}


contract owned {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}



/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    /**
     * @dev Multiplies two numbers, reverts on overflow.
     */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b, "Multiplication overflow");

        return c;
    }

    /**
     * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0, "Division by 0"); // Solidity only automatically requires when dividing by 0
        uint256 c = _a / _b;
        // require(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a, "Subtraction overflow");
        uint256 c = _a - _b;

        return c;
    }

    /**
     * @dev Adds two numbers, reverts on overflow.
     */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a, "Addition overflow");

        return c;
    }

    /**
     * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "Dividing by 0");
        return a % b;
    }
}







contract BrewerscoinToken is owned, IERC20 {

    using SafeMath for uint256;

    uint256 private constant base = 1e18;
    uint256 constant MAX_UINT = 2**256 - 1;

    // Public variables of the token
    string public constant name = "Brewer's coin";
    string public constant symbol = "BREW";
    uint8 public constant decimals = 18;
    uint256 public totalSupply = 1e26;              // 100 million

    // This creates an array with all balances
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 tokenAmount);
    event Approval(address indexed tokenHolder, address indexed spender, uint256 tokenAmount);
    event Burn(address indexed from, uint256 tokenAmount);

    // Error messages
    string private constant NOT_ENOUGH_TOKENS = "Not enough tokens";
    string private constant NOT_ENOUGH_ETHER = "Not enough ether";
    string private constant NOT_ENOUGH_ALLOWANCE = "Not enough allowance";
    string private constant ADDRESS_0_NOT_ALLOWED = "Address 0 not allowed";

    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor() public {

        // put all tokens on owner balance
        balances[msg.sender] = totalSupply;

        // allow owner 2^256-1 tokens of this contract, the fee of buyBeer will be transfered to this contract
        allowance[this][msg.sender] = MAX_UINT;
    }

    /**
     * Total Supply
     *
     * Get the total supply of tokens
     */
    function totalSupply() external view returns (uint256) {
        return totalSupply;
    }

    /**
     * Function to check the amount of tokens that an tokenOwner allowed to a spender
     *
     * @param tokenOwner address The address which owns the funds
     * @param spender address The address which will spend the funds
     */
    function allowance(address tokenOwner, address spender) external view returns (uint256) {
        return allowance[tokenOwner][spender];
    }

    /**
     * Function to get the amount of tokens that an address contains
     *
     * @param tokenOwner address The address which owns the funds
     */
    function balanceOf(address tokenOwner) external view returns (uint256) {
        return balances[tokenOwner];
    }

    /**
     * Transfer tokens
     *
     * Send `tokenAmount` tokens to `to` from your account
     *
     * @param to the address of the recipient
     * @param tokenAmount the amount to send
     */
    function transfer(address to, uint256 tokenAmount) external returns (bool) {
        _transfer(msg.sender, to, tokenAmount);

        return true;
    }

    /**
     * Transfer tokens from other address if allowed
     *
     * Send `tokenAmount` tokens to `to` in behalf of `from`
     *
     * @param from The address of the sender
     * @param to The address of the recipient
     * @param tokenAmount the amount to send
     */
    function transferFrom(address from, address to, uint256 tokenAmount) external returns (bool) {

        // Check allowance
        require(tokenAmount <= allowance[from][msg.sender], NOT_ENOUGH_ALLOWANCE);

        // transfer
        _transfer(from, to, tokenAmount);

        // Subtract allowance
        allowance[from][msg.sender] = allowance[from][msg.sender].sub(tokenAmount);

        return true;
    }

    /**
     * Internal method for transferring tokens from one address to the other
     *
     * Send `tokenAmount` tokens to `to` in behalf of `from`
     *
     * @param from the address of the sender
     * @param to the address of the recipient
     * @param tokenAmount the amount of tokens to transfer
     */
    function _transfer(address from, address to, uint256 tokenAmount) internal {

        // Check if the sender has enough tokens
        require(tokenAmount <= balances[from], NOT_ENOUGH_TOKENS);

        // Prevent transfer to 0x0 address. Use burn() instead
        require(to != address(0), ADDRESS_0_NOT_ALLOWED);

        // Subtract tokens from sender
        balances[from] = balances[from].sub(tokenAmount);

        // Add the tokens to the recipient
        balances[to] = balances[to].add(tokenAmount);

        // Trigger event
        emit Transfer(from, to, tokenAmount);
    }

    /**
     * Set allowance for other address
     *
     * Allows `spender` to spend no more than `tokenAmount` tokens in your behalf
     *
     * @param spender The address authorized to spend
     * @param tokenAmount the max amount they can spend
     */
    function approve(address spender, uint256 tokenAmount) external returns (bool success) {
        return _approve(spender, tokenAmount);
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `spender` to spend no more than `tokenAmount` tokens in your behalf, and then ping the contract about it
     *
     * @param spender the address authorised to spend
     * @param tokenAmount the max amount they can spend
     * @param extraData some extra information to send to the approved contract
     */
    function approveAndCall(address spender, uint256 tokenAmount, bytes extraData) external returns (bool success) {
        tokenRecipient _spender = tokenRecipient(spender);
        if (_approve(spender, tokenAmount)) {
            _spender.receiveApproval(msg.sender, tokenAmount, this, extraData);
            return true;
        }
        return false;
    }

    /**
     * Set allowance for other address
     *
     * Allows `spender` to spend no more than `tokenAmount` tokens in your behalf
     *
     * @param spender The address authorized to spend
     * @param tokenAmount the max amount they can spend
     */
    function _approve(address spender, uint256 tokenAmount) internal returns (bool success) {
        allowance[msg.sender][spender] = tokenAmount;
        emit Approval(msg.sender, spender, tokenAmount);
        return true;
    }

    /**
     * Destroy tokens
     *
     * Remove `tokenAmount` tokens from the system irreversibly
     *
     * @param tokenAmount the amount of tokens to burn
     */
    function burn(uint256 tokenAmount) external returns (bool success) {

        _burn(msg.sender, tokenAmount);

        return true;
    }

    /**
     * Destroy tokens from other account
     *
     * Remove `tokenAmount` tokens from the system irreversibly on behalf of `from`.
     *
     * @param from the address of the sender
     * @param tokenAmount the amount of tokens to burn
     */
    function burnFrom(address from, uint256 tokenAmount) public returns (bool success) {

        // Check allowance
        require(tokenAmount <= allowance[from][msg.sender], NOT_ENOUGH_ALLOWANCE);

        // Burn
        _burn(from, tokenAmount);

        // Subtract from the sender's allowance
        allowance[from][msg.sender] = allowance[from][msg.sender].sub(tokenAmount);

        return true;
    }

    /**
     * Destroy tokens
     *
     * Remove `tokenAmount` tokens from the system irreversibly
     *
     * @param from the address to burn tokens from
     * @param tokenAmount the amount of tokens to burn
     */
    function _burn(address from, uint256 tokenAmount) internal {

        // Check if the sender has enough
        require(tokenAmount <= balances[from], NOT_ENOUGH_TOKENS);

        // Subtract from the sender
        balances[from] = balances[from].sub(tokenAmount);

        // Updates totalSupply
        totalSupply = totalSupply.sub(tokenAmount);

        // Burn tokens
        emit Burn(from, tokenAmount);
    }
}