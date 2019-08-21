pragma solidity ^0.4.13;

contract Ownable {
  address public owner;


  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }
}

contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract Peony is Ownable {

  string public version;
  string public unit = "piece";
  uint256 public total;
  struct Bullion {
    string index;
    string unit;
    uint256 amount;
    string ipfs;
  }
  bytes32[] public storehouseIndex;
  mapping (bytes32 => Bullion) public storehouse;
  address public tokenAddress;
  uint256 public rate = 10;
  PeonyToken token;





  function Peony(string _version) {
    version = _version;
  }




  event Stock (
    string index,
    string unit,
    uint256 amount,
    string ipfs,
    uint256 total
  );

  event Ship (
    string index,
    uint256 total
  );

  event Mint (
    uint256 amount,
    uint256 total
  );

  event Reduce (
    uint256 amount,
    uint256 total
  );





  function stock(string _index, string _unit, uint256 _amount, string _ipfs) onlyOwner returns (bool);

  function ship(string _index) onlyOwner returns (bool);

  function mint(uint256 _ptAmount) onlyOwner returns (bool);

  function reduce(uint256 _tokenAmount) onlyOwner returns (bool);

  function setRate(uint256 _rate) onlyOwner returns (bool);

  function setTokenAddress(address _address) onlyOwner returns (bool);



  function convert2Peony(uint256 _amount) constant returns (uint256);

  function convert2PeonyToken(uint256 _amount) constant returns (uint256);

  function info(string _index) constant returns (string, string, uint256, string);

  function suicide() onlyOwner returns (bool);
}

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
  mapping(address => uint256) public transferLimits;

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

  modifier isPeonyContract() {
    require(peony != 0x0);
    require(msg.sender == peony);
    _;
  }

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
   * @notice Reduce digital artwork tokens for changing physical artwork
   * @param amount Reduce token amount
   */
  function reduce(uint256 amount) isPeonyContract returns (bool) {
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
   * Implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20
   * @notice send `_value` token to `_to`
   * @param _to The address of the recipient
   * @param _value The amount of token to be transferred
   * @return Whether the transfer was successful or not
   */
  function transfer(address _to, uint256 _value) returns (bool) {
    require(_to != address(0));
    require(transferLimits[msg.sender] == 0 || transferLimits[msg.sender] >= _value);

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
   *
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

  /**
   * @notice Set transfer upper limit
   * @param transferLimit Transfer upper limit
   * @return Whether the operation was successful or not
   */
  function setTransferLimit(uint256 transferLimit) returns (bool) {
    transferLimits[msg.sender] = transferLimit;
  }

  /**
   * @notice Delete the contract
   */
  function suicide() onlyOwner returns (bool) {
    selfdestruct(owner);
    return true;
  }
}

library ConvertStringByte {
  function bytes32ToString(bytes32 x) constant returns (string) {
    bytes memory bytesString = new bytes(32);
    uint charCount = 0;
    for (uint j = 0; j < 32; j++) {
      byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
      if (char != 0) {
          bytesString[charCount] = char;
          charCount++;
      }
    }
    bytes memory bytesStringTrimmed = new bytes(charCount);
    for (j = 0; j < charCount; j++) {
      bytesStringTrimmed[j] = bytesString[j];
    }
    return string(bytesStringTrimmed);
  }

  function stringToBytes32(string memory source) returns (bytes32 result) {
    assembly {
      result := mload(add(source, 32))
    }
  }
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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