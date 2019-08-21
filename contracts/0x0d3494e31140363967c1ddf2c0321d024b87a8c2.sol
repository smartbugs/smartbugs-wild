pragma solidity ^0.4.24;


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


contract ERC20 {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  function mint(address to, uint256 value) public returns (bool ok);
}



contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  constructor() public {
    owner = msg.sender;
  }


  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}



contract DAOToken is ERC20, Ownable {
  using SafeMath for uint256;

  string public constant name = "Pi Token";
  string public constant symbol = "PI";
  uint8 public constant decimals = 18;
  //uint256 public constant INITIAL_SUPPLY = 9000000 * (10 ** uint256(decimals));
  uint256 public constant INITIAL_SUPPLY = 0;

  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) internal allowed;

  uint256 totalSupply_;
  uint OneYearLater;


  address public crowdsale;


  event NewDAOContract(address indexed previousDAOContract, address indexed newDAOContract);
   event NewCrowdContract(address indexed previousCrowdContract, address indexed newCrowdContract);


  constructor() public {
    owner = msg.sender;

OneYearLater = now + 365 days;

    totalSupply_ = INITIAL_SUPPLY;
    balances[owner] = INITIAL_SUPPLY;
    emit Transfer(0x0, owner, INITIAL_SUPPLY);
    crowdsale = 0x0;
  }



  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }


  function setCrowd(address crowd) onlyOwner external {
    require(crowdsale == 0x0);
    crowdsale = crowd;
  }


    function mint(address _address, uint _value) public returns (bool success) {


        require(now < OneYearLater);

        require(msg.sender == crowdsale);

        balances[_address] = balanceOf(_address).add(_value);
        totalSupply_ = totalSupply_.add(_value);

        balances[owner] = balanceOf(owner).add(_value);
        totalSupply_ = totalSupply_.add(_value);

        return true;


}


  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _balance = _balanceOf(msg.sender);
    require(_value <= _balance);


    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);

    emit Transfer(msg.sender, _to, _value);
    return true;
  }


  function balanceOf(address _owner) public view returns (uint256 balance) {
    return _balanceOf(_owner);
  }


  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    uint256 _balance = _balanceOf(_from);
    require(_value <= _balance);

    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }


  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }


  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }




  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }


  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }


  function approveAndCall(
    address _spender,
    uint256 _value,
    bytes _data
  )
  public
  payable
  returns (bool)
  {
    require(_spender != address(this));

    approve(_spender, _value);


    require(_spender.call.value(msg.value)(_data));

    return true;
  }


  function transferAndCall(
    address _to,
    uint256 _value,
    bytes _data
  )
  public
  payable
  returns (bool)
  {
    require(_to != address(this));

    transfer(_to, _value);


    require(_to.call.value(msg.value)(_data));
    return true;
  }


  function transferFromAndCall(
    address _from,
    address _to,
    uint256 _value,
    bytes _data
  )
  public payable returns (bool)
  {
    require(_to != address(this));

    transferFrom(_from, _to, _value);


    require(_to.call.value(msg.value)(_data));
    return true;
  }


  function increaseApprovalAndCall(
    address _spender,
    uint _addedValue,
    bytes _data
  )
  public
  payable
  returns (bool)
  {
    require(_spender != address(this));

    increaseApproval(_spender, _addedValue);


    require(_spender.call.value(msg.value)(_data));

    return true;
  }


  function decreaseApprovalAndCall(
    address _spender,
    uint _subtractedValue,
    bytes _data
  )
  public
  payable
  returns (bool)
  {
    require(_spender != address(this));

    decreaseApproval(_spender, _subtractedValue);


    require(_spender.call.value(msg.value)(_data));

    return true;
  }



  function pureBalanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }



  function _balanceOf(address _owner) internal view returns (uint256) {
    return balances[_owner];
  }


}