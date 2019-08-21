pragma solidity 0.5.7;
/**
 * Cycle TOKEN Contract
 * ERC-20 Token Standard Compliant
 */

/**
 * @title SafeMath by OpenZeppelin
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

}

/**
 * @title ERC20 Token minimal interface
 */
contract token {

    function balanceOf(address _owner) public view returns(uint256 balance);
    //Since some tokens doesn't return a bool on transfer, this general interface
    //doesn't include a return on the transfer fucntion to be widely compatible
    function transfer(address _to, uint256 _value) public;

}

/**
 * Token contract interface for external use
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
 * @dev Define token paramters including ERC20 ones
 */
contract ERC20Token is ERC20TokenInterface { //Standard definition of a ERC20Token

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
        require(_to != address(0)); //If you dont want that people destroy token
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
        require(_to != address(0)); //If you dont want that people destroy token
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
     * @dev Log Events
     */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/**
 * @title Asset
 * @dev Initial supply creation
 */
contract Asset is ERC20Token {

    string public name = 'Cycle';
    uint8 public decimals = 8;
    string public symbol = 'CYCLE';
    string public version = '1';
    address public owner; //owner address is public

    constructor(uint initialSupply, address initialOwner) public {
        owner = initialOwner;
        totalSupply = initialSupply * (10 ** uint256(decimals)); //initial token creation
        balances[owner] = totalSupply;
        emit Transfer(address(0), owner, balances[owner]);
    }

    /**
     * @notice Function to recover ANY token stuck on contract accidentally
     * In case of recover of stuck tokens please contact contract owners
     */
    function recoverTokens(token _address, address _to) public {
        require(msg.sender == owner);
        require(_to != address(0));
        uint256 remainder = _address.balanceOf(address(this)); //Check remainder tokens
        _address.transfer(_to, remainder); //Transfer tokens to creator
    }

    function changeOwner(address newOwner) external {
        require(msg.sender == owner);
        require(newOwner != address(0));
        owner = newOwner;
    }

    /**
     *@dev Function to handle callback calls
     */
    function () external {
        revert();
    }

}