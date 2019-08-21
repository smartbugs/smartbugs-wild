pragma solidity ^0.4.22;

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
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

contract TokenERC20 {
    using SafeMath for uint256;
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public _totalSupply;

    // This creates an array with all balances
    mapping (address => uint256) public _balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    // This generates a public event on the blockchain that will notify clients
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    /**
     * Constrctor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        _totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        _balanceOf[msg.sender] = _totalSupply;                // Give the creator all initial tokens
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
    }

    function balanceOf(address _addr) public view returns (uint256) {
        return _balanceOf[_addr];
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint256 _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(_balanceOf[_from] >= _value);
        // Check for overflows
        require(_balanceOf[_to].add(_value) > _balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = _balanceOf[_from].add(_balanceOf[_to]);
        _balanceOf[_from] = _balanceOf[_from].sub(_value);
        _balanceOf[_to] = _balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(_balanceOf[_from].add(_balanceOf[_to]) == previousBalances);
    }
    /**
     * Send `_value` tokens to `_to` in behalf of `_from`
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }
    /**
     * Set allowance for other address
     * Allows `_spender` to spend no more than `_value` tokens in your behalf
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    /**
     * Set allowance for other address and notify
     * Allows `_spender` to spend no more than `_value` tokens in your behalf, and then ping the contract about it
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
}

/******************************************/
/*       ADVANCED TOKEN STARTS HERE       */
/******************************************/

contract MGT is owned, TokenERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) private _frozenOf;
    event FrozenFunds(address _taget,  uint256 _value);
    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) TokenERC20(initialSupply, tokenName, tokenSymbol) public {

    }
    function transfer(address _to, uint256 _value)  public returns (bool) {
        if (_value > 0 && _balanceOf[msg.sender].sub(_frozenOf[msg.sender]) >= _value) {
            _transfer(msg.sender, _to, _value);
            return true;
        } else {
            return false;
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        if (_value > 0 && allowance[_from][msg.sender] > 0 &&
            allowance[_from][msg.sender] >= _value &&
            _balanceOf[_from].sub(_frozenOf[_from]) >= _value
            ) {
            _transfer(_from, _to, _value);
            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
            emit Transfer(_from, _to, _value);
            return true;
        } else {
            return false;
        }
    }
    
    
    function frozen(address _frozenaddress, uint256 _value) onlyOwner public returns (bool) {
        if (_value >= 0 && _balanceOf[_frozenaddress] >= _value) {
            _frozenOf[_frozenaddress] = _value;
            emit FrozenFunds(_frozenaddress, _value);
            return true;
        } else {
            return false;
        }
    }

    
    function frozenOf(address _frozenaddress) public view returns (uint256) {
        return _frozenOf[_frozenaddress];
    }

    /**
     * Set allowance for candy airdrop
     * Allows `_spender` to spend no more than `_value` tokens in token owner behalf
     *
     * @param _owner the address of token owner
     * @param _spender the address authorized to spend
     * @param _value the max amount they can spend
     */
    function approveAirdrop(address _owner, address _spender, uint256 _value) public returns (bool success) {
        allowance[_owner][_spender] = _value;
        emit Approval(_owner, _spender, _value);
        return true;
    }

    /**
     * Transfer tokens from other address by airdrop
     *
     * Send `_value` tokens to `_to` in behalf of `_from` from '_owner'
     *
     * @param _owner The address of the token owner
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferAirdrop(address _owner, address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][_owner]);
        allowance[_from][_owner] = allowance[_from][_owner].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * destruct contract 
     */
    function kill() onlyOwner public {
        selfdestruct(owner);
    }
}