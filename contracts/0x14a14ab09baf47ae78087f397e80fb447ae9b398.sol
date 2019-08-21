pragma solidity ^0.4.24;

// File: contracts\token\ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  function totalSupply() public view returns (uint256);
  function balanceOf(address owner) public view returns (uint256);
  function allowance(address owner, address spender) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts\common\Ownable.sol

contract Ownable {
  address private _owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  modifier onlyOwner() {
    require(msg.sender == _owner, "Unauthorized.");
    _;
  }

  constructor() public {
    _owner = msg.sender;
  }

  function owner() public view returns (address) {
    return _owner;
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "Non-zero address required.");
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

// File: contracts\common\SafeMath.sol

library SafeMath {

  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b, "Invalid argument.");

    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0, "Invalid argument.");
    uint256 c = _a / _b;

    return c;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a, "Invalid argument.");
    uint256 c = _a - _b;

    return c;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a, "Invalid argument.");

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0, "Invalid argument.");
    return a % b;
  }
}

// File: contracts\token\StandardToken.sol

contract StandardToken is ERC20, Ownable {
  using SafeMath for uint256;

  uint256 internal _totalSupply;

  mapping (address => uint256) internal _balances;
  mapping (address => mapping (address => uint256)) internal _allowed;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);

  constructor(uint256 initialSupply) public {
    _totalSupply = initialSupply;
    _balances[msg.sender] = initialSupply;
  }

  function () public payable {
    revert("You cannot buy tokens.");
  }

  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
   * Transfer
   */

  function transfer(address to, uint256 value) public returns (bool) {
    require(to != address(0), "Non-zero address required.");
    require(_balances[msg.sender] >= value, "Insufficient balance.");

    _balances[msg.sender] = _balances[msg.sender].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(msg.sender, to, value);
    return true;
  }

  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    require(to != address(0), "Non-zero address required.");
    require(_balances[from] >= value, "Insufficient balance.");
    require(_allowed[from][msg.sender] >= value, "Insufficient balance.");

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    emit Transfer(from, to, value);
    return true;
  }

  /**
   * Approve
   */

  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowed[owner][spender];
  }

  function approve(address spender, uint256 value) public returns (bool) {
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }
}

// File: contracts\token\ERC223.sol

/**
 * @title ERC223 interface
 * @dev see https://github.com/ethereum/EIPs/issues/223
 */
contract ERC223 {
  function name() public view returns (string);
  function symbol() public view returns (string);
  function decimals() public view returns (uint8);

  function transfer(address to, uint256 value, bytes data) public returns (bool);
  function transferFrom(address from, address to, uint256 value, bytes data) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value, bytes data);
}

contract ERC223Receiver {
  function tokenFallback(address from, uint256 value, bytes data) public;
}

// File: contracts\token\MintableToken.sol

contract MintableToken {
  function mintingFinished() public view returns (bool);
  function finishMinting() public returns (bool);

  function mint(address to, uint256 value) public returns (bool);
}

// File: contracts\token\BurnableToken.sol

contract BurnableToken {
  function burn(uint256 value) public returns (bool);
  function burnFrom(address from, uint256 value) public returns (bool);
}

// File: contracts\token\ExtendedToken.sol

contract ExtendedToken is StandardToken, ERC223, MintableToken, BurnableToken {
  using SafeMath for uint256;

  string internal _name;
  string internal _symbol;
  uint8 internal _decimals;
  bool internal _mintingFinished;

  event Burn(address indexed account, uint256 value);
  event Mint(address indexed account, uint256 value);
  event MintingFinished();

  constructor(uint256 totalSupply, string name, string symbol, uint8 decimals) StandardToken(totalSupply) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
    _mintingFinished = false;
  }

  function name() public view returns (string) {
    return _name;
  }

  function symbol() public view returns (string) {
    return _symbol;
  }

  function decimals() public view returns (uint8) {
    return _decimals;
  }

  /**
   * Transfer
   */

  function transfer(address to, uint256 value) public returns (bool) {
    bytes memory empty;
    return transfer(to, value, empty);
  }

  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    bytes memory empty;
    return transferFrom(from, to, value, empty);
  }

  function transfer(address to, uint256 value, bytes data) public returns (bool) {
    if (_isContract(to)) {
      ERC223Receiver receiver = ERC223Receiver(to);
      receiver.tokenFallback(msg.sender, value, data);

      super.transfer(to, value);

      emit Transfer(msg.sender, to, value, data);
      return true;
    }

    return super.transfer(to, value);
  }

  function transferFrom(address from, address to, uint256 value, bytes data) public returns (bool) {
    if (_isContract(to)) {
      ERC223Receiver receiver = ERC223Receiver(to);
      receiver.tokenFallback(from, value, data);

      super.transferFrom(from, to, value);

      emit Transfer(from, to, value, data);
      return true;
    }

    return super.transferFrom(from, to, value);
  }

  /**
   * Burn
   */

  function burn(uint256 value) public returns (bool) {
    require(_balances[msg.sender] >= value, "Insufficient balance.");

    return _burn(msg.sender, value);
  }

  function burnFrom(address from, uint256 value) public returns (bool) {
    require(from != address(0), "Non-zero address required.");
    require(_balances[from] >= value, "Insufficient balance.");
    require(_allowed[from][msg.sender] >= value, "Insufficient balance.");

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    return _burn(from, value);
  }

  function _burn(address from, uint256 value) private returns (bool) {
    _totalSupply = _totalSupply.sub(value);
    _balances[from] = _balances[from].sub(value);
    emit Transfer(from, address(0), value);
    emit Burn(from, value);
    return true;
  }

  /**
   * Mint
   */

  function mintingFinished() public view returns(bool) {
    return _mintingFinished;
  }

  function finishMinting() public returns (bool) {
    require(_mintingFinished == false, "");
    _mintingFinished = true;
    emit MintingFinished();
    return true;
  }

  function mint(address to, uint256 value) public returns (bool) {
    require(to != address(0), "Non-zero address required.");

    _totalSupply = _totalSupply.add(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(address(0), to, value);
    emit Mint(to, value);
    return true;
  }

  /**
   * Etc
   */

  function _isContract(address _account) private view returns (bool) {
    uint256 size = 0;
    // solium-disable-next-line security/no-inline-assembly
    assembly { size := extcodesize(_account) }
    return size > 0;
  }
}

// File: contracts\LivePodToken.sol

contract LivePodToken is ExtendedToken {
  using SafeMath for uint256;

  bool private _tradingStarted;
  address private _preSaleAgent;
  address private _publicSaleAgent;

  event TradeStarted();

  constructor() ExtendedToken(0 * (10 ** 18), "LIVEPOD TOKEN", "LVPD", 18) public {
    _tradingStarted = false;
    _preSaleAgent = 0;
    _publicSaleAgent = 0;
  }

  /**
   * Transfer
   */

  function transfer(address to, uint256 value) public hasStartedTrading returns (bool) {
    return super.transfer(to, value);
  }

  function transferFrom(address from, address to, uint256 value) public hasStartedTrading returns (bool) {
    return super.transferFrom(from, to, value);
  }

  function approve(address spender, uint256 value) public hasStartedTrading returns (bool) {
    return super.approve(spender, value);
  }

  function transfer(address to, uint256 value, bytes data) public hasStartedTrading returns (bool) {
    return super.transfer(to, value, data);
  }

  function transferFrom(address from, address to, uint256 value, bytes data) public hasStartedTrading returns (bool) {
    return super.transferFrom(from, to, value, data);
  }

  /**
   * Trade
   */

  modifier hasStartedTrading() {
    require(_tradingStarted, "The trade has not started yet.");
    _;
  }

  function trading() public view returns (bool) {
    return _tradingStarted;
  }

  function startTrading() public onlyOwnerAndAgents returns (bool) {
    _tradingStarted = true;
    emit TradeStarted();
    return true;
  }

  /**
   * Agents
   */

  function setPreSaleAgent(address agent) public onlyOwner returns (bool) {
    require(agent != address(0), "Non-zero address required.");

    _preSaleAgent = agent;
    return true;
  }

  function setPublicSaleAgent(address agent) public onlyOwner returns (bool) {
    require(agent != address(0), "Non-zero address required.");

    _publicSaleAgent = agent;
    return true;
  }

  modifier onlyOwnerAndAgents() {
    require((msg.sender == owner()) || (msg.sender == _preSaleAgent) || (msg.sender == _publicSaleAgent), "Unauthorized.");
    _;
  }

  /**
   * Mint
   */

  function finishMinting() public onlyOwner returns (bool) {
    return super.finishMinting();
  }

  function mint(address to, uint256 value) public onlyOwnerAndAgents returns (bool) {
    require(!_tradingStarted, "Trading has started.");

    return super.mint(to, value);
  }

  /**
   * Etc
   */

  function transferAnyERC20Token(address tokenAddress, uint256 amount) public onlyOwner returns (bool) {
    return ERC20(tokenAddress).transfer(owner(), amount);
  }

  function destroy() public onlyOwner {
    selfdestruct(owner());
  }
}