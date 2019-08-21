pragma solidity ^0.4.18;


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

contract IOwned {
  function owner() public constant returns (address) { owner; }
  function transferOwnership(address _newOwner) public;
}

contract Owned is IOwned {
  address public owner;

  function Owned() public {
    owner = msg.sender;
  }

  modifier validAddress(address _address) {
    require(_address != 0x0);
    _;
  }
  modifier onlyOwner {
    assert(msg.sender == owner);
    _;
  }
  
  function transferOwnership(address _newOwner) public validAddress(_newOwner) onlyOwner {
    require(_newOwner != owner);
    
    owner = _newOwner;
  }
}



contract IERC20Token {
  function name() public constant returns (string) { name; }
  function symbol() public constant returns (string) { symbol; }
  function decimals() public constant returns (uint8) { decimals; }
  function totalSupply() public constant returns (uint256) { totalSupply; }
  function balanceOf(address _owner) public constant returns (uint256 balance) { _owner; balance; }
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) { _owner; _spender; remaining; }

  function transfer(address _to, uint256 _value) public returns (bool);
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
  function approve(address _spender, uint256 _value) public returns (bool);
}

contract ERC20Token is IERC20Token {
  using SafeMath for uint256;

  string public standard = 'Token 0.1';
  string public name = '';
  string public symbol = '';
  uint8 public decimals = 0;
  uint256 public totalSupply = 0;
  mapping (address => uint256) public balanceOf;
  mapping (address => mapping (address => uint256)) public allowance;

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  function ERC20Token(string _name, string _symbol, uint8 _decimals) public {
    require(bytes(_name).length > 0 && bytes(_symbol).length > 0);
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }

  modifier validAddress(address _address) {
    require(_address != 0x0);
    _;
  }

  function transfer(address _to, uint256 _value) public validAddress(_to) returns (bool) {
    balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
    balanceOf[_to] = balanceOf[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public validAddress(_to) returns (bool) {
    allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
    balanceOf[_from] = balanceOf[_from].sub(_value);
    balanceOf[_to] = balanceOf[_to].add(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public validAddress(_spender) returns (bool) {
    require(_value == 0 || allowance[msg.sender][_spender] == 0);
    allowance[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }
}


contract ISerenityToken {
  function initialSupply () public constant returns (uint256) { initialSupply; }

  function totalSoldTokens () public constant returns (uint256) { totalSoldTokens; }
  function totalProjectToken() public constant returns (uint256) { totalProjectToken; }

  function fundingEnabled() public constant returns (bool) { fundingEnabled; }
  function transfersEnabled() public constant returns (bool) { transfersEnabled; }
}

contract SerenityToken is ISerenityToken, ERC20Token, Owned {
  using SafeMath for uint256;
 
  address public fundingWallet;
  bool public fundingEnabled = true;
  uint256 public maxSaleToken = 3500000;
  uint256 public initialSupply = 350000 ether;
  uint256 public totalSoldTokens;
  uint256 public totalProjectToken;
  uint256 private totalLockToken;
  bool public transfersEnabled = false; 

  mapping (address => bool) private fundingWallets;
  mapping (address => allocationLock) public allocations;

  struct allocationLock {
    uint256 value;
    uint256 end;
    bool locked;
  }

  event Finalize(address indexed _from, uint256 _value);
  event Lock(address indexed _from, address indexed _to, uint256 _value, uint256 _end);
  event Unlock(address indexed _from, address indexed _to, uint256 _value);
  event DisableTransfers(address indexed _from);

  function SerenityToken() ERC20Token("SERENITY INVEST", "SERENITY", 18) public {
    fundingWallet = msg.sender; 

    balanceOf[fundingWallet] = maxSaleToken;

    fundingWallets[fundingWallet] = true;
    fundingWallets[0x47c8F28e6056374aBA3DF0854306c2556B104601] = true;
  }

  modifier validAddress(address _address) {
    require(_address != 0x0);
    _;
  }

  modifier transfersAllowed(address _address) {
    if (fundingEnabled) {
      require(fundingWallets[_address]);
    }

    require(transfersEnabled);
    _;
  }

  function transfer(address _to, uint256 _value) public validAddress(_to) transfersAllowed(msg.sender) returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public validAddress(_to) transfersAllowed(_from) returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function lock(address _to, uint256 _value, uint256 _end) internal validAddress(_to) onlyOwner returns (bool) {
    require(_value > 0);

    assert(totalProjectToken > 0);
    totalLockToken = totalLockToken.add(_value);
    assert(totalProjectToken >= totalLockToken);

    require(allocations[_to].value == 0);

    // Assign a new lock.
    allocations[_to] = allocationLock({
      value: _value,
      end: _end,
      locked: true
    });

    Lock(this, _to, _value, _end);

    return true;
  }

  function unlock() external {
    require(allocations[msg.sender].locked);
    require(now >= allocations[msg.sender].end);
    
    balanceOf[msg.sender] = balanceOf[msg.sender].add(allocations[msg.sender].value);

    allocations[msg.sender].locked = false;

    Transfer(this, msg.sender, allocations[msg.sender].value);
    Unlock(this, msg.sender, allocations[msg.sender].value);
  }

  function finalize() external onlyOwner {
    require(fundingEnabled);
    
    totalSoldTokens = maxSaleToken.sub(balanceOf[fundingWallet]);

    totalProjectToken = totalSoldTokens.mul(15).div(100);

    lock(0x47c8F28e6056374aBA3DF0854306c2556B104601, totalProjectToken, now);
    
    // Zeroing a cold wallet.
    balanceOf[fundingWallet] = 0;

    // End of crowdfunding.
    fundingEnabled = false;
    transfersEnabled = true;

    // End of crowdfunding.
    Transfer(this, fundingWallet, 0);
    Finalize(msg.sender, totalSupply);
  }

  function disableTransfers() external onlyOwner {
    require(transfersEnabled);

    transfersEnabled = false;

    DisableTransfers(msg.sender);
  }

  function disableFundingWallets(address _address) external onlyOwner {
    require(fundingEnabled);
    require(fundingWallet != _address);
    require(fundingWallets[_address]);

    fundingWallets[_address] = false;
  }
}



contract Crowdsale {
  using SafeMath for uint256;

  SerenityToken public token;

  mapping(uint256 => uint8) icoWeeksDiscounts; 

  uint256 public preStartTime = 1510704000;
  uint256 public preEndTime = 1512086400; 

  bool public isICOStarted = false; 
  uint256 public icoStartTime; 
  uint256 public icoEndTime; 

  address public wallet = 0x47c8F28e6056374aBA3DF0854306c2556B104601;
  uint256 public tokensPerEth = 10;
  uint256 public weiRaised;
  uint256 public ethRaised;

  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  modifier validAddress(address _address) {
    require(_address != 0x0);
    _;
  }

  function Crowdsale() public {
    token = createTokenContract();
    initDiscounts();
  }

  function initDiscounts() internal {
    icoWeeksDiscounts[0] = 40;
    icoWeeksDiscounts[1] = 35;
    icoWeeksDiscounts[2] = 30;
    icoWeeksDiscounts[3] = 25;
    icoWeeksDiscounts[4] = 20;
    icoWeeksDiscounts[5] = 10;
  }

  function createTokenContract() internal returns (SerenityToken) {
    return new SerenityToken();
  }

  function () public payable {
    buyTokens(msg.sender);
  }

  function getTimeDiscount() internal returns(uint8) {
    require(isICOStarted == true);
    require(icoStartTime < now);
    require(icoEndTime > now);

    uint256 weeksPassed = (now - icoStartTime) / 7 days;
    return icoWeeksDiscounts[weeksPassed];
  } 

  function getTotalSoldDiscount() internal returns(uint8) {
    require(isICOStarted == true);
    require(icoStartTime < now);
    require(icoEndTime > now);

    uint256 totalSold = token.totalSoldTokens();

    if (totalSold < 150000)
      return 50;
    else if (totalSold < 250000)
      return 40;
    else if (totalSold < 500000)
      return 35;
    else if (totalSold < 700000)
      return 30;
    else if (totalSold < 1100000)
      return 25;
    else if (totalSold < 2100000)
      return 20;
    else if (totalSold < 3500000)
      return 10;
  }

  function getDiscount() internal constant returns (uint8) {
    if (!isICOStarted)
      return 50;
    else {
      uint8 timeDiscount = getTimeDiscount();
      uint8 totalSoldDiscount = getTotalSoldDiscount();

      if (timeDiscount < totalSoldDiscount)
        return timeDiscount;
      else 
        return totalSoldDiscount;
    }
  }

  function buyTokens(address beneficiary) public validAddress(beneficiary) payable {
    require(validPurchase());
    require(msg.value > 1 ether);

    uint256 ethAmount = msg.value / 1 ether;

    uint8 discountPercents = getDiscount();
    uint256 costWithDiscount = tokensPerEth.div(100 - discountPercents).mul(100);
    uint256 tokens = ethAmount.mul(costWithDiscount);

    weiRaised = weiRaised.add(ethAmount * 1 ether);

    token.transfer(beneficiary, tokens);
    TokenPurchase(msg.sender, beneficiary, ethAmount * 1 ether , tokens);

    forwardFunds();
  }

  function activeteICO(uint256 _icoEndTime) public {
    require(msg.sender == wallet);
    require(_icoEndTime >= now);
    require(_icoEndTime >= preEndTime);
    require(isICOStarted == false);
      
    isICOStarted = true;
    icoEndTime = _icoEndTime;
  }

  function forwardFunds() internal {
    wallet.transfer(msg.value);
  }

  function validPurchase() internal constant returns (bool) {
    bool withinPresalePeriod = now >= preStartTime && now <= preEndTime;
    bool withinICOPeriod = isICOStarted && now >= icoStartTime && now <= icoEndTime;

    bool nonZeroPurchase = msg.value != 0;
    
    return (withinPresalePeriod || withinICOPeriod) && nonZeroPurchase;
  }
}