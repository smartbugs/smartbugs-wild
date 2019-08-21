pragma solidity 0.4.24;

// File: contracts\misc\Ownable.sol

contract Ownable 
{
    address public owner;

    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
      address indexed previousOwner,
      address indexed newOwner
    );

    constructor() public 
    {
        owner = msg.sender;
    }

    modifier onlyOwner() 
    {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public 
    onlyOwner 
    {
        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal 
    {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

// File: contracts\misc\SafeMath.sol

library SafeMath 
{
    function mul(uint256 a, uint256 b) internal pure 
    returns (uint256 c) 
    {
        if (a == 0) 
        {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure 
    returns (uint256) 
    {
        return a / b;
    }

    function sub(uint256 a, uint256 b) internal pure 
    returns (uint256) 
    {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure 
    returns (uint256 c) 
    {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

// File: contracts\token\ERC20Basic.sol

contract ERC20Basic 
{
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: contracts\token\BasicToken.sol

contract BasicToken is ERC20Basic 
{
    using SafeMath for uint256;
    mapping(address => uint256) balances;
    
    uint256 totalSupply_;

    function totalSupply() public view 
    returns (uint256) 
    {
        return totalSupply_;
    }

    function transfer(address _to, uint256 _value) public 
    returns (bool) 
    {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view 
    returns (uint256) 
    {
        return balances[_owner];
    }
}

// File: contracts\token\BurnableToken.sol

contract BurnableToken is BasicToken, Ownable
{
    event Burn(address indexed burner, uint256 value);

    function burn(address burnAddress, uint256 value) public 
    onlyOwner
    {
        require(value <= balances[burnAddress]);

        balances[burnAddress] = balances[burnAddress].sub(value);
        totalSupply_ = totalSupply_.sub(value);
        emit Burn(burnAddress, value);
        emit Transfer(burnAddress, address(0), value);
    }
}

// File: contracts\token\ERC20.sol

contract ERC20 is ERC20Basic 
{
    function allowance(address owner, address spender) public view returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool); 
    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts\token\StandardToken.sol

contract StandardToken is ERC20, BasicToken 
{
    mapping (address => mapping (address => uint256)) internal allowed;

    function transferFrom(address _from, address _to, uint256 _value) public
    returns (bool)
    {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }


    function approve(address _spender, uint256 _value) public 
    returns (bool) 
    {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view
    returns (uint256)
    {
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint256 _addedValue) public
    returns (bool)
    {
        allowed[msg.sender][_spender] = (
        allowed[msg.sender][_spender].add(_addedValue));
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public
    returns (bool)
    {
        uint256 oldValue = allowed[msg.sender][_spender];

        if (_subtractedValue > oldValue) 
        {
            allowed[msg.sender][_spender] = 0;
        } 
        else 
        {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }

        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

// File: contracts\token\MintableToken.sol

contract MintableToken is StandardToken, Ownable 
{
    event Mint(address indexed to, uint256 amount);

    function mint(address _to, uint256 _amount) public
    onlyOwner
    returns (bool)
    {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }
}

// File: contracts\token\Pausable.sol

contract Pausable is Ownable 
{
    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }

    function pause() public
    onlyOwner 
    whenNotPaused  
    {
        paused = true;
        emit Pause();
    }

    function unpause() public
    onlyOwner 
    whenPaused  
    {
        paused = false;
        emit Unpause();
    }
}

// File: contracts\IndexToken.sol

contract IndexToken is BurnableToken, MintableToken, Pausable
{
    string constant public name = "Coffee Token";
    string constant public symbol = "dqr";

    uint public decimals = 18;
}