pragma solidity ^0.5.0;

interface IERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
    uint256 c = add(a,m);
    uint256 d = sub(c,1);
    return mul(div(d,m),m);
  }
}

contract ERC20Detailed is IERC20 {

  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(string memory name, string memory symbol, uint8 decimals) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

  function name() public view returns(string memory) {
    return _name;
  }

  function symbol() public view returns(string memory) {
    return _symbol;
  }

  function decimals() public view returns(uint8) {
    return _decimals;
  }
}

contract Incinerate is ERC20Detailed {

  using SafeMath for uint256;
  mapping (address => uint256) private _balances;
  mapping (address => mapping (address => uint256)) private _allowed;

 

  string constant tokenSymbol = "INC8";
  string constant tokenName = "Incinerate Token";
  uint8  constant tokenDecimals = 2;
  uint256 _totalSupply = 10000000000;
  uint256 public basePercent = 100000;
  uint256 constant MAX_UINT = 2**256 - 1;

  constructor() public payable ERC20Detailed(tokenName, tokenSymbol, tokenDecimals) {
    _mint(msg.sender, _totalSupply);
  }

  function totalSupply() public view returns (uint256) {
    return _totalSupply.div(100);
  }

  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner].div(100);
  }

  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowed[owner][spender].div(100);
  }

  function findFivePercent(uint256 value) public view returns (uint256)  {
    uint256 roundValue = value; //.ceil(basePercent);
    uint256 fivePercent = roundValue.mul(basePercent).div(20000);
    return fivePercent;
  }

  function transfer(address to, uint256 value) public returns (bool) {
      uint256 scaledValue = value.mul(100);
      
    require(scaledValue <= _balances[msg.sender]);
    require(to != address(0));

    uint256 tokensToBurn = findFivePercent(scaledValue).div(100);
    uint256 tokensToTransfer = scaledValue.sub(tokensToBurn);

    _balances[msg.sender] = _balances[msg.sender].sub(scaledValue);
    _balances[to] = _balances[to].add(tokensToTransfer);

    _totalSupply = _totalSupply.sub(tokensToBurn);

    emit Transfer(msg.sender, to, tokensToTransfer.div(100));
    emit Transfer(msg.sender, address(0), tokensToBurn.ceil(100).div(100));
    return true;
  }

  function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {
    for (uint256 i = 0; i < receivers.length; i++) {
      transfer(receivers[i], amounts[i]);
    }
  }

  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));
    
    if(value == MAX_UINT) {
         _allowed[msg.sender][spender] = value;
         emit Approval(msg.sender, spender, value);
    } else {
    
         uint256 scaledValue = value.mul(100);
         _allowed[msg.sender][spender] = scaledValue;
         emit Approval(msg.sender, spender, value);
  
    }
      return true;
  }

  function transferFrom(address from, address to, uint256 value) public returns (bool) {
       uint256 scaledValue = value.mul(100);
    require(scaledValue <= _balances[from]);
    require(scaledValue <= _allowed[from][msg.sender]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(scaledValue);

    uint256 tokensToBurn = findFivePercent(scaledValue).div(100);
    uint256 tokensToTransfer = scaledValue.sub(tokensToBurn);

    _balances[to] = _balances[to].add(tokensToTransfer);
    _totalSupply = _totalSupply.sub(tokensToBurn);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(scaledValue);

    emit Transfer(from, to, tokensToTransfer.div(100));
    emit Transfer(from, address(0), tokensToBurn.ceil(100).div(100));

    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    require(spender != address(0));
    uint256 scaledValue = addedValue.mul(100);
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(scaledValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender].div(100));
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    require(spender != address(0));
     uint256 scaledValue = subtractedValue.mul(100);
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(scaledValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender].div(100));
    return true;
  }

  function _mint(address account, uint256 amount) internal {
    require(amount != 0);
    _balances[account] = _balances[account].add(amount);
    emit Transfer(address(0), account, amount.div(100));
  }

  function burn(uint256 amount) external {
    _burn(msg.sender, amount);
  }

  function _burn(address account, uint256 amount) internal {
     uint256 scaledAmount = amount.mul(100);
    require(scaledAmount != 0);
    require(scaledAmount <= _balances[account]);
    _totalSupply = _totalSupply.sub(scaledAmount);
    _balances[account] = _balances[account].sub(scaledAmount);
    emit Transfer(account, address(0), amount);
  }

  function burnFrom(address account, uint256 amount) external {
        uint256 scaledAmount = amount.mul(100);
    require(scaledAmount <= _allowed[account][msg.sender]);
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(scaledAmount);
    _burn(account, amount);
  }
}