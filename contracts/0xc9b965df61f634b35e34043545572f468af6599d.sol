pragma solidity >0.5.0;
// ------------------------------------------------------------------------
// TEN Token by Tentech Group OU Limited.
// An ERC20 standard
//
// author: Tentech Group Team
// contact: Jason Nguyen jason.ng@tentech.io
//--------------------------------------------------------------------------
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
    
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a>b) return a;
        return b;
    }
}
contract ERC20RcvContract { 
    function tokenFallback(address _from, uint _value) public;
}

contract ERC20  {

    using SafeMath for uint;

    /// @notice check if the address  `_addr` is a contract or not
    /// @param _addr The address of the recipient
    function isContract(address _addr) private view returns (bool) {
        uint length;
         assembly {
             //retrieve the size of the code on target address, this needs assembly
             length := extcodesize(_addr)
         }
         return (length>0);
    }
 
    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    function transfer(address _to, uint _value) public returns (bool){

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        if(isContract(_to)) {
            ERC20RcvContract receiver = ERC20RcvContract(_to);
            receiver.tokenFallback(msg.sender, _value);
        }
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool){

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

        if(isContract(_to)) {
            ERC20RcvContract receiver = ERC20RcvContract(_to);
            receiver.tokenFallback(msg.sender, _value);
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint _value) public returns (bool){
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) public view returns (uint remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint) balances;
    mapping (address => mapping (address => uint)) allowed;
    uint public totalSupply;

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

contract TenToken is ERC20 { 

    string public symbol="GDEM";       
    string public name ="TEN Token";

    uint8 public decimals=6;          
    address public walletOwner;

    constructor() public 
    {
        totalSupply = 10**9 * (10**6);  //1 Billion token
        balances[msg.sender] = totalSupply;               
        walletOwner = msg.sender;
        // [EPI20 standard] https://eips.ethereum.org/EIPS/eip-20
        // A token contract which creates new tokens SHOULD trigger a Transfer event with the _from address set to 0x0 when tokens are created.
        emit Transfer(0x0000000000000000000000000000000000000000, walletOwner, totalSupply);
    }

    // Receice Ether in exchange for tokens 
    function() external payable {
        revert();
    }
}