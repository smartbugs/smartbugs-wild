pragma solidity > 0.4.99 <0.6.0;

interface IERC20Token {
    function balanceOf(address owner) external returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function burn(uint256 _value) external returns (bool);
    function decimals() external returns (uint256);
    function approve(address _spender, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
}

contract Ownable {
  address payable public _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
  * @dev The Ownable constructor sets the original `owner` of the contract to the sender
  * account.
  */
  constructor() internal {
    _owner = tx.origin;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
  * @return the address of the owner.
  */
  function owner() public view returns(address) {
    return _owner;
  }

  /**
  * @dev Throws if called by any account other than the owner.
  */
  modifier onlyOwner() {
    require(isOwner());
    _;
  }

  /**
  * @return true if `msg.sender` is the owner of the contract.
  */
  function isOwner() public view returns(bool) {
    return msg.sender == _owner;
  }

  /**
  * @dev Allows the current owner to relinquish control of the contract.
  * @notice Renouncing to ownership will leave the contract without an owner.
  * It will not be possible to call the functions with the `onlyOwner`
  * modifier anymore.
  */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
  * @dev Allows the current owner to transfer control of the contract to a newOwner.
  * @param newOwner The address to transfer ownership to.
  */
  function transferOwnership(address payable newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
  * @dev Transfers control of the contract to a newOwner.
  * @param newOwner The address to transfer ownership to.
  */
  function _transferOwnership(address payable newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}
contract ERC20Interface {
    
    string public name;
    string public symbol;
    uint8 public decimals;
    uint public totalSupply;
    

    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public returns (uint256 remaining);


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
}

contract ERC20 is ERC20Interface {
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) allowed;
    

    constructor(string memory _name, string memory _symbol, uint8 _decimals, uint256 _totalSupply) public {
       name =  _name;
       symbol = _symbol;
       decimals = _decimals;
       totalSupply = _totalSupply * 10 ** uint256(_decimals);
       balanceOf[tx.origin] = totalSupply;
    }

    function transfer(address _to, uint256 _value) public returns (bool success){
        require(_to != address(0));
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[ _to] + _value >= balanceOf[ _to]); 

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        require(_to != address(0));
        require(allowed[msg.sender][_from] >= _value);
        require(balanceOf[_from] >= _value);
        require(balanceOf[ _to] + _value >= balanceOf[ _to]);

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        allowed[msg.sender][_from] -= _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function approve(address _spender, uint256 _value) public returns (bool success){
        allowed[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public returns (uint256 remaining){
         return allowed[_owner][_spender];
    }

}

contract ERC20Token is ERC20, Ownable {

    string public constant createdBy = "AssetSplit.org - the guys who cut the pizza";

    event AddSupply(uint amount);
    event Burn(address target, uint amount);
    event Sold(address buyer, uint256 amount);
    
    constructor (string memory _name, string memory _symbol, uint8 _decimals, uint _totalSupply) 
        ERC20(_name, _symbol, _decimals, _totalSupply) public {
        }
   
    function transfer(address _to, uint256 _value) public returns (bool success) {
        success = _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        require(allowed[_from][msg.sender] >= _value);
        success =  _transfer(_from, _to, _value);
        allowed[_from][msg.sender]  -= _value;
    }

    function _transfer(address _from, address _to, uint256 _value) internal returns (bool) {
      require(_to != address(0));

      require(balanceOf[_from] >= _value);
      require(balanceOf[ _to] + _value >= balanceOf[ _to]);

      balanceOf[_from] -= _value;
      balanceOf[_to] += _value;

   
      emit Transfer(_from, _to, _value);
      return true;
    }

    function burn(uint256 _value) public returns (bool success) {
       require(balanceOf[msg.sender] >= _value);

       totalSupply -= _value; 
       balanceOf[msg.sender] -= _value;

       emit Burn(msg.sender, _value);
       return true;
    }

    function burnFrom(address _from, uint256 _value)  public returns (bool success) {
        require(balanceOf[_from] >= _value);
        require(allowed[_from][msg.sender] >= _value);

        totalSupply -= _value; 
        balanceOf[msg.sender] -= _value;
        allowed[_from][msg.sender] -= _value;

        emit Burn(msg.sender, _value);
        return true;
    }
}