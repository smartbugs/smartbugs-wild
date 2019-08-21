pragma solidity 0.5.8;
/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     */
    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;
        return c;
    }
}

/**
 * @title Owner parameters
 * @dev Define ownership parameters for this contract
 */
contract Owned { //This token contract is owned
    address public owner; //Owner address is public
    bool public lockSupply; //Supply Lock flag

    /**
     * @dev Contract constructor, define initial administrator
     */
    constructor() internal {
        owner = 0xA0c6f96035d0FA5F44D781060F84A0Bc6B8D87Ee; //Set initial owner to contract creator
        emit TransferOwnership(owner);
    }

    modifier onlyOwner() { //A modifier to define owner-only functions
        require(msg.sender == owner, "Not Allowed");
        _;
    }

    modifier supplyLock() { //A modifier to lock supply-change transactions
        require(lockSupply == false, "Supply is locked");
        _;
    }

    /**
     * @dev Function to set new owner address
     * @param _newOwner The address to transfer administration to
     */
    function transferAdminship(address _newOwner) public onlyOwner { //Owner can be transfered
        require(_newOwner != address(0), "Not allowed");
        owner = _newOwner;
        emit TransferOwnership(owner);
    }

    /**
     * @dev Function to set supply locks
     * @param _set boolean flag (true | false)
     */
    function setSupplyLock(bool _set) public onlyOwner { //Only the owner can set a lock on supply
        lockSupply = _set;
        emit SetSupplyLock(lockSupply);
    }

    //All owner actions have a log for public review
    event SetSupplyLock(bool _set);
    event TransferOwnership(address indexed newAdminister);
}

/**
 * Token contract interface
 */
contract ERC20TokenInterface {
    function balanceOf(address _owner) public view returns(uint256 value);
    function transfer(address _to, uint256 _value) public returns(bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool success);
    function approve(address _spender, uint256 _value) public returns(bool success);
    function allowance(address _owner, address _spender) public view returns(uint256 remaining);
}

/**
 * @title Token definition
 * @dev Define token parameters, including ERC20 ones
 */
contract ERC20Token is Owned, ERC20TokenInterface {
    using SafeMath for uint256;
    uint256 public totalSupply;
    mapping(address => uint256) balances; //A mapping of all balances per address
    mapping(address => mapping(address => uint256)) allowed; //A mapping of all allowances

    /**
     * @dev Get the balance of an specified address.
     * @param _owner The address to be query.
     */
    function balanceOf(address _owner) public view returns(uint256 value) {
        return balances[_owner];
    }

    /**
     * @dev transfer token to a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public returns(bool success) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @dev transfer token from an address to another specified address using allowance
     * @param _from The address where token comes.
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool success) {
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Assign allowance to an specified address to use the owner balance
     * @param _spender The address to be allowed to spend.
     * @param _value The amount to be allowed.
     */
    function approve(address _spender, uint256 _value) public returns(bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Get the allowance of an specified address to use another address balance.
     * @param _owner The address of the owner of the tokens.
     * @param _spender The address of the allowed spender.
     */
    function allowance(address _owner, address _spender) public view returns(uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * @dev Burn token of an specified address.
     * @param _value amount to burn.
     */
    function burnTokens(uint256 _value) public onlyOwner {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);

        emit Transfer(msg.sender, address(0), _value);
        emit Burned(msg.sender, _value);
    }

    /**
     * @dev Log Events
     */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    event Burned(address indexed _target, uint256 _value);
}

/**
 * @title Asset
 * @dev Initial supply creation
 */
contract Asset is ERC20Token {
    string public name = 'Orionix';
    uint8 public decimals = 18;
    string public symbol = 'ORX';
    string public version = '2';

    constructor() public {
        totalSupply = 600000000 * (10 ** uint256(decimals)); //initial token creation
        balances[0xA0c6f96035d0FA5F44D781060F84A0Bc6B8D87Ee] = totalSupply;
        emit Transfer(
            address(0),
            0xA0c6f96035d0FA5F44D781060F84A0Bc6B8D87Ee,
            balances[0xA0c6f96035d0FA5F44D781060F84A0Bc6B8D87Ee]);
    }

    /**
     *@dev Function to handle callback calls
     */
    function () external {
        revert("This contract cannot receive direct payments or fallback calls");
    }

}