pragma solidity ^0.5.6;

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

interface tokenRecipient { 
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; 
}

contract Blackstone {
    using SafeMath for uint256;
   
    // Defining Variables & Mapping 
    string public name = "Blackstone";
    string public symbol = "BLST";
    uint256 public decimals = 0;
    uint256 public totalSupply = 40000000;
    
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    
    event Transfer (address indexed _from, address indexed _to, uint256 _value);
    event Approval (address indexed _owner, address indexed _spender, uint256 _value);
    event Burn (address indexed _from, uint256 _value);
    
    // Constructor to Deploy the ERC20 Token
    constructor() public {
            name;
            symbol;
            decimals;
            balanceOf[msg.sender] = totalSupply;
    }
    
    // Transfer Function
    function _transfer(address _from, address _to, uint256 _value) internal {
    	require(_from != address(0));
    	require(_to != address(0));
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to].add(_value) >= balanceOf[_to]);
        uint256 previousBalances = balanceOf[_from].add(balanceOf[_to]);
        
        balanceOf[_from] = balanceOf[_from].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        
        emit Transfer (_from, _to, _value);
        assert(balanceOf[_from].add(balanceOf[_to]) == previousBalances);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }
    
    // Transfer delegated Tokens
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }
    
    // Delegate/Approve spender a certain amount of Tokens
    function approve(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0));
        require(balanceOf[msg.sender] >= _value);
        require(allowance[msg.sender][_spender].add(_value) >= allowance[msg.sender][_spender]);
        
        allowance[msg.sender][_spender] = _value;
        
        emit Approval (msg.sender, _spender, _value);
        return true;
    }
    
    // Increase delegated amount
    function increaseAllowance(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0));
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[msg.sender] >= allowance[msg.sender][_spender].add(_value));
        require(allowance[msg.sender][_spender].add(_value) >= allowance[msg.sender][_spender]);

        allowance[msg.sender][_spender] = allowance[msg.sender][_spender].add(_value);

        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    // Decrease delegated amount
    function decreaseAllowance(address _spender, uint256 _value) public returns (bool success) {
        require(_spender != address(0));
        
        allowance[msg.sender][_spender] = allowance[msg.sender][_spender].sub(_value);
        
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // Ping the contract about approved spender spendings
    function approveAndCall(address _spender, uint256 _value, bytes memory _extradata) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if(approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, address(this), _extradata);
            return true;
        }
    }
    
    // Tokenburn
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        
        emit Burn (msg.sender, _value);
        return true;
    }
    
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(_from != address(0));
        require(balanceOf[_from] >= _value);
        require(_value <= allowance[_from][msg.sender]);
        
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        totalSupply = totalSupply.sub(_value);
        
        emit Burn (msg.sender, _value);
        return true;
    }
    
}