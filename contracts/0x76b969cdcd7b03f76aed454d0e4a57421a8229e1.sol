/**
*所發行數字牡丹（即BitPeony），其最終解釋權為Bitcaps.club所有，並保留所有修改權利。
*本專項衍生之營運政策、交易模式等資訊，其最新修訂版本，詳見官網（http://www.bitcaps.club/）正式公告。官網擁有上述公告之最終解釋權，並保留所有修改權利。
*/

/**
*Abstract contract for the full ERC 20 Token standard
*https://github.com/ethereum/EIPs/issues/20
*/
pragma solidity ^0.4.13;

/**
* @title ERC20Basic
* @dev Simpler version of ERC20 interface
* @dev see https://github.com/ethereum/EIPs/issues/20
*/
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
* @dev simple own functions
* @dev see https://github.com/ethereum/EIPs/issues/20
*/
contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  function Ownable() {
    owner = msg.sender;
  }

  /**
  * This contract only defines a modifier but does not use it
  * it will be used in derived contracts.
  * The function body is inserted where the special symbol
  * "_;" in the definition of a modifier appears.
  * This means that if the owner calls this function, the
  * function is executed and otherwise, an exception is  thrown.
  */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
  * @dev Allows the current owner to transfer control of the contract to a newOwner.
  * @param newOwner The address to transfer ownership to.
  */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

/**
* @title Basic token
* @dev Basic version of ERC20 Standard
* @dev see https://github.com/ethereum/EIPs/issues/20
*/
contract PeonyToken is Ownable, ERC20 {
  using SafeMath for uint256;
  string public version;
  string public name;
  string public symbol;
  uint256 public decimals;
  address public peony;
  mapping(address => mapping (address => uint256)) allowed;
  mapping(address => uint256) balances;
  uint256 public totalSupply;
  uint256 public totalSupplyLimit;

  /**
  * @dev Basic version of ERC20 Standard
  * @dev see https://github.com/ethereum/EIPs/issues/20
  * This function is executed once in the initial stage.
  */
  function PeonyToken(
    string _version,
    uint256 initialSupply,
    uint256 totalSupplyLimit_,
    string tokenName,
    uint8 decimalUnits,
    string tokenSymbol
    ) {
    require(totalSupplyLimit_ == 0 || totalSupplyLimit_ >= initialSupply);
    version = _version;
    balances[msg.sender] = initialSupply;
    totalSupply = initialSupply;
    totalSupplyLimit = totalSupplyLimit_;
    name = tokenName;
    symbol = tokenSymbol;
    decimals = decimalUnits;
  }

  /**
  * This contract only defines a modifier but does not use it
  * it will be used in derived contracts.
  * The function body is inserted where the special symbol
  * "_;" in the definition of a modifier appears.
  * This means that if the owner calls this function, the
  * function is executed and otherwise, an exception is  thrown.
  */
  modifier isPeonyContract() {
    require(peony != 0x0);
    require(msg.sender == peony);
    _;
  }

  /**
  * This contract only defines a modifier but does not use it
  * it will be used in derived contracts.
  * The function body is inserted where the special symbol
  * "_;" in the definition of a modifier appears.
  * This means that if the owner calls this function, the
  * function is executed and otherwise, an exception is  thrown.
  */
  modifier isOwnerOrPeonyContract() {
    require(msg.sender != address(0) && (msg.sender == peony || msg.sender == owner));
    _;
  }

  /**
  * @notice produce `amount` of tokens to `_owner`
  * @param amount The amount of tokens to produce
  * @return Whether or not producing was successful
  */
  function produce(uint256 amount) isPeonyContract returns (bool) {
    require(totalSupplyLimit == 0 || totalSupply.add(amount) <= totalSupplyLimit);

    balances[owner] = balances[owner].add(amount);
    totalSupply = totalSupply.add(amount);

    return true;
  }

  /**
  * @notice consume digital artwork tokens for changing physical artwork
  * @param amount consume token amount
  */
  function consume(uint256 amount) isPeonyContract returns (bool) {
    require(balances[owner].sub(amount) >= 0);
    require(totalSupply.sub(amount) >= 0);
    balances[owner] = balances[owner].sub(amount);
    totalSupply = totalSupply.sub(amount);

    return true;
  }

  /**
  * @notice Set address of Peony contract.
  * @param _address the address of Peony contract
  */
  function setPeonyAddress(address _address) onlyOwner returns (bool) {
    require(_address != 0x0);

    peony = _address;
    return true;
  }

  /**
  * Implements ERC 20 Token standard:https://github.com/ethereum/EIPs/issues/20
  * @notice send `_value` token to `_to`
  * @param _to The address of the recipient
  * @param _value The amount of token to be transferred
  * @return Whether the transfer was successful or not
  */
  function transfer(address _to, uint256 _value) returns (bool) {
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);

    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Transfer tokens from one address to another
  * @param _from address The address which you want to send tokens from
  * @param _to address The address which you want to transfer to
  * @param _value uint256 the amount of tokens to be transferred
  */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
  * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
  * Beware that changing an allowance with this method brings the risk that someone may use both the old
  * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
  * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
  * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
  * @param _spender The address which will spend the funds.
  * @param _value The amount of tokens to be spent.
  */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
  * @dev Function to check the amount of tokens that an owner allowed to a spender.
  * @param _owner address The address which owns the funds.
  * @param _spender address The address which will spend the funds.
  * @return A uint256 specifying the amount of tokens still available for the spender.
  */
  function allowance(address _owner, address _spender) public constant returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
  * @notice return total amount of tokens uint256 public totalSupply;
  * @param _owner The address from which the balance will be retrieved
  * @return The balance
  */
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }
}

/**
*Math operations with safety checks
*/
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}