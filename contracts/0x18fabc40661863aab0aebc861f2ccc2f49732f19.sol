/*
INFERNO (BLAZE)

website:  https://inferno.cash

discord:  https://discord.gg/VCbevQ

2,000,000 BLAZE Initial Supply

1,000,000 BLAZE can be claimed on the website

2% Burn on Every Transfer

1% Goes to Cummunity Fund Project from Every Transfer

Community is chosen by the user every month


*/

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

  uint8 private _Tokendecimals;
  string private _Tokenname;
  string private _Tokensymbol;

  constructor(string memory name, string memory symbol, uint8 decimals) public {
   
   _Tokendecimals = decimals;
    _Tokenname = name;
    _Tokensymbol = symbol;
    
  }

  function name() public view returns(string memory) {
    return _Tokenname;
  }

  function symbol() public view returns(string memory) {
    return _Tokensymbol;
  }

  function decimals() public view returns(uint8) {
    return _Tokendecimals;
  }
}

/**end here**/

contract Inferno is ERC20Detailed {

  using SafeMath for uint256;
  mapping (address => uint256) private _InfernoTokenBalances;
  mapping (address => mapping (address => uint256)) private _allowed;
  mapping (address => uint256) public _lastClaimBlock;
  string constant tokenName = "Inferno";
  string constant tokenSymbol = "BLAZE";
  uint8  constant tokenDecimals = 18;
  uint256 _totalSupply = 2000000e18;
  uint256 public _nextClaimAmount = 1000e18;
  address public admin;
  uint256 public _InfernoFund = 2000000e18;
  bool public _allowClaims = false;
  address public _communityAccount;
  uint256 public _claimPrice = 0;
 
 
  constructor() public payable ERC20Detailed(tokenName, tokenSymbol, tokenDecimals) {
    //_mint(msg.sender, _totalSupply);
    admin = msg.sender;
    _communityAccount = msg.sender;   //just until we set one
  }



  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  function myTokens() public view returns (uint256) {
    return _InfernoTokenBalances[msg.sender];
  }

  function balanceOf(address owner) public view returns (uint256) {
    return _InfernoTokenBalances[owner];
  }

  function allowance(address owner, address spender) public view returns (uint256) {
    return _allowed[owner][spender];
  }

  function setAllowClaims(bool _setClaims) public {
    require(msg.sender == admin);
    _allowClaims = _setClaims;
  }

  function setCommunityAcccount(address _newAccount) public {
    require(msg.sender == admin);
    _communityAccount = _newAccount;
  }

  function setClaimPrice(uint256 _newPrice) public {    //normally price is zero, this will be bot defense if necessary
    require(msg.sender == admin);
    _claimPrice = _newPrice;
  }

  function distributeETH(address payable _to, uint _amount) public {
    require(msg.sender == admin);
    require(_amount <= address(this).balance);
    _to.transfer(_amount);
  }
  


  function transfer(address to, uint256 value) public returns (bool) {
    require(value <= _InfernoTokenBalances[msg.sender]);
    require(to != address(0));

    uint256 InfernoTokenDecay = value.div(50);   //2%
    uint256 tokensToTransfer = value.sub(InfernoTokenDecay);

    uint256 communityAmount = value.div(100);   //1%
    _InfernoTokenBalances[_communityAccount] = _InfernoTokenBalances[_communityAccount].add(communityAmount);
    tokensToTransfer = tokensToTransfer.sub(communityAmount);

    _InfernoTokenBalances[msg.sender] = _InfernoTokenBalances[msg.sender].sub(value);
    _InfernoTokenBalances[to] = _InfernoTokenBalances[to].add(tokensToTransfer);

    _totalSupply = _totalSupply.sub(InfernoTokenDecay);

    emit Transfer(msg.sender, to, tokensToTransfer);
    emit Transfer(msg.sender, address(0), InfernoTokenDecay);
    emit Transfer(msg.sender, _communityAccount, communityAmount);
    return true;
  }

  function multiTransfer(address[] memory receivers, uint256[] memory amounts) public {
    for (uint256 i = 0; i < receivers.length; i++) {
      transfer(receivers[i], amounts[i]);
    }
  }

  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  function transferFrom(address from, address to, uint256 value) public returns (bool) {
    require(value <= _InfernoTokenBalances[from]);
    require(value <= _allowed[from][msg.sender]);
    require(to != address(0));

    _InfernoTokenBalances[from] = _InfernoTokenBalances[from].sub(value);

    uint256 InfernoTokenDecay = value.div(50);
    uint256 tokensToTransfer = value.sub(InfernoTokenDecay);

     uint256 communityAmount = value.div(100);   //1%
    _InfernoTokenBalances[_communityAccount] = _InfernoTokenBalances[_communityAccount].add(communityAmount);
    tokensToTransfer = tokensToTransfer.sub(communityAmount);

    _InfernoTokenBalances[to] = _InfernoTokenBalances[to].add(tokensToTransfer);
    _totalSupply = _totalSupply.sub(InfernoTokenDecay);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);

    emit Transfer(from, to, tokensToTransfer);
    emit Transfer(from, address(0), InfernoTokenDecay);
    emit Transfer(from, _communityAccount, communityAmount);

    return true;
  }

  function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  function burn(uint256 amount) public {
    _burn(msg.sender, amount);
  }

  function _burn(address account, uint256 amount) internal {
    require(amount != 0);
    require(amount <= _InfernoTokenBalances[account]);
    _totalSupply = _totalSupply.sub(amount);
    _InfernoTokenBalances[account] = _InfernoTokenBalances[account].sub(amount);
    emit Transfer(account, address(0), amount);
  }

  function burnFrom(address account, uint256 amount) external {
    require(amount <= _allowed[account][msg.sender]);
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(amount);
    _burn(account, amount);
  }

  function claim() payable public  {
    require(_allowClaims || (msg.sender == admin));
    require((block.number.sub(_lastClaimBlock[msg.sender])) >= 5900);
    require((msg.value >= (_claimPrice.mul(_nextClaimAmount).div(1e18))) || (msg.sender == admin));
    _InfernoTokenBalances[msg.sender] = _InfernoTokenBalances[msg.sender].add(_nextClaimAmount);
    emit Transfer(address(this), msg.sender, _nextClaimAmount);
    _InfernoFund = _InfernoFund.add(_nextClaimAmount);
    _totalSupply = _totalSupply.add(_nextClaimAmount.mul(2));
    _nextClaimAmount = _nextClaimAmount.mul(999).div(1000);
    _lastClaimBlock[msg.sender] = block.number;
      
  }

  function distributeFund(address _to, uint256 _amount) public {
      require(msg.sender == admin);
      require(_amount <= _InfernoFund);
      _InfernoFund = _InfernoFund.sub(_amount);
      _InfernoTokenBalances[_to] = _InfernoTokenBalances[_to].add(_amount);
      emit Transfer(address(this), _to, _amount);
  }

}