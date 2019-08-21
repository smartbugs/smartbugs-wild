pragma solidity ^0.4.11;
/*
PAXCHANGE TOKEN

ERC-20 Token Standar Compliant - ConsenSys

Contract developer: Fares A. Akel C.
f.antonio.akel@gmail.com
MIT PGP KEY ID: 078E41CB
*/

/**
 * @title SafeMath by OpenZeppelin
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

}

contract ERC20Token { //Standar definition of a ERC20Token
    using SafeMath for uint256;
    mapping (address => uint256) balances; //A mapping of all balances per address
    mapping (address => mapping (address => uint256)) allowed; //A mapping of all allowances

    /**
    * @dev Get the balance of an specified address.
    * @param _owner The address to be query.
    */
    function balanceOf(address _owner) public constant returns (uint256 balance) {
      return balances[_owner];
    }

    /**
    * @dev transfer token to a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0)); //If you dont want that people destroy token
        require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }
    /**
    * @dev transfer token from an address to another specified address using allowance
    * @param _from The address where token comes.
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != address(0)); //If you dont want that people destroy token
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        balances[_to] = balances[_to].add(_value);
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }
    /**
    * @dev Assign allowance to an specified address to use the owner balance
    * @param _spender The address to be allowed to spend.
    * @param _value The amount to be allowed.
    */
    function approve(address _spender, uint256 _value) public returns (bool success) {
      allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
    /**
    * @dev Get the allowance of an specified address to use another address balance.
    * @param _owner The address of the owner of the tokens.
    * @param _spender The address of the allowed spender.
    */
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
    }
    /**
    *Log Events
    */
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract AssetPAXCHANGE is ERC20Token {
    string public name = 'PAXCHANGE TOKEN';
    uint8 public decimals = 18;
    string public symbol = 'PAXCHANGE';
    string public version = '0.1';
    uint256 public totalSupply = 50000000 * (10**uint256(decimals));

    function AssetPAXCHANGE() public {
        balances[0xFAB6368b0F7be60c573a6562d82469B5ED9e7eE6] = 50000 * (10**uint256(decimals)); //Fixed 0.1% for contract writer
        balances[this] = 49950000 * (10**uint256(decimals)); //Remaining keep on contract
        allowed[this][msg.sender] = 49950000 * (10**uint256(decimals)); //Creator has allowance of the rest on the contract
        /**
        *Log Events
        */
        Transfer(0, this, totalSupply);
        Transfer(this, 0xFAB6368b0F7be60c573a6562d82469B5ED9e7eE6, 50000 * (10**uint256(decimals)));
        Approval(this, msg.sender, 49950000 * (10**uint256(decimals)));

    }
    /**
    *@dev Function to handle callback calls
    */
    function() public {
        revert();
    }

}