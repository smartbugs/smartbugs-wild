pragma solidity ^0.4.17;

library SafeMath {
    
    /**
     *  Sub function asserts that b is less than or equal to a.
     * */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * Add function avoids overflow.
    * */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) constant public returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) constant public returns (uint256);
    function transferFrom(address from, address to, uint256 value) public  returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BasicToken is ERC20Basic {

    using SafeMath for uint256;

    //keeps a record of the total balances of each ETH address.
    mapping (address => uint256) balances;

    modifier onlyPayloadSize(uint size) {
        if (msg.data.length < size + 4) {
        revert();
        }
        _;
    }

    /**
     * Transfer function makes it possible for users to transfer their Hire tokens to another
     * ETH address.
     * 
     * @param _to the address of the recipient.
     * @param _amount the amount of Hire tokens to be sent.
     * */
    function transfer(address _to, uint256 _amount) public onlyPayloadSize(2 * 32) returns (bool) {
        require(balances[msg.sender] >= _amount);
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(msg.sender, _to, _amount);
        return true;
    }

    /**
     * BalanceOf function returns the total balance of the queried address.
     * 
     * @param _addr the address which is being queried.
     * */
    function balanceOf(address _addr) public constant returns (uint256) {
        return balances[_addr];
    }
}

contract AdvancedToken is BasicToken, ERC20 {
    
    //keeps a record of all the allowances from one ETH address to another.
    mapping (address => mapping (address => uint256)) allowances; 
    
    /**
     * TransferFrom function allows users to spend ETH on another's behalf, given that the _owner
     * has allowed them to. 
     * 
     * @param _from the address of the owner.
     * @param _to the address of the recipient.
     * @param _amount the total amount of tokens to be sent. '
     * */
    function transferFrom(address _from, address _to, uint256 _amount) public onlyPayloadSize(3 * 32) returns (bool) {
        require(allowances[_from][msg.sender] >= _amount && balances[_from] >= _amount);
        allowances[_from][msg.sender] = allowances[_from][msg.sender].sub(_amount);
        balances[_from] = balances[_from].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(_from, _to, _amount);
        return true;
    }

    /**
     * Approve function allows users to allow others to spend a specified amount tokens on
     * their behalf.
     * 
     * @param _spender the address of the spended who is being granted permission to spend tokens.
     * @param _amount the total amount of tokens the spender is allowed to spend.
     * */
    function approve(address _spender, uint256 _amount) public returns (bool) {
        allowances[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    /**
     * Allowance function returns the total allowance from one address to another.
     * 
     * @param _owner the address of the owner of the token.
     * @param _spender the address of the spender who has or has not been allowed to spend
     * the owners tokens.
     * */
    function allowance(address _owner, address _spender) public constant returns (uint256) {
        return allowances[_owner][_spender];
    }

}

contract Hire is AdvancedToken {

    uint8 public decimals;
    string public name;
    string public symbol;
    address public owner;

    /**
    * Constructor initializes the total supply to 100,000,000, the token name to
    * Hire, the token symbol to HIRE, sets the decimals to 18 and automatically 
    * sends all tokens to the owner of the contract upon deployment.
    * */
    function Hire() public {
        totalSupply = 100000000e18;
        decimals = 18;
        name = "Hire";
        symbol = "HIRE";
        owner = 0xaAa34A22Bd3F496b3A8648367CeeA9c03B130A30;
        balances[owner] = totalSupply;
    }
}