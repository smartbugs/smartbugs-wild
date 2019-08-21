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
  uint256 public maxSaleToken = 3500000 ether;
  uint256 public initialSupply = 3500000 ether;
  uint256 public totalSoldTokens = 0;
  uint256 public totalProjectToken;
  bool public transfersEnabled = false;

  mapping (address => bool) private fundingWallets;

  event Finalize(address indexed _from, uint256 _value);
  event DisableTransfers(address indexed _from);

  function SerenityToken() ERC20Token("SERENITY", "SERENITY", 18) public {
    fundingWallet = msg.sender; 

    balanceOf[fundingWallet] = maxSaleToken;
    balanceOf[0x47c8F28e6056374aBA3DF0854306c2556B104601] = maxSaleToken;
    balanceOf[0xCAD0AfB8Ec657D0DB9518B930855534f6433360f] = maxSaleToken;
    balanceOf[0x041375343c3Bd1Bb28b40b5Ce7b4665A9a6e21D0] = maxSaleToken;

    fundingWallets[fundingWallet] = true;
    fundingWallets[0x47c8F28e6056374aBA3DF0854306c2556B104601] = true;
    fundingWallets[0xCAD0AfB8Ec657D0DB9518B930855534f6433360f] = true;
    fundingWallets[0x041375343c3Bd1Bb28b40b5Ce7b4665A9a6e21D0] = true;
  }

  modifier validAddress(address _address) {
    require(_address != 0x0);
    _;
  }

  modifier transfersAllowed(address _address) {
    if (fundingEnabled) {
      require(fundingWallets[_address]);
    }
    else {
      require(transfersEnabled);
    }
    _;
  }

  function transfer(address _to, uint256 _value) public validAddress(_to) transfersAllowed(msg.sender) returns (bool) {
    return super.transfer(_to, _value);
  }

  function autoTransfer(address _to, uint256 _value) public validAddress(_to) onlyOwner returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public validAddress(_to) transfersAllowed(_from) returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function getTotalSoldTokens() public constant returns (uint256) {
    uint256 result = 0;
    result = result.add(maxSaleToken.sub(balanceOf[fundingWallet]));
    result = result.add(maxSaleToken.sub(balanceOf[0x47c8F28e6056374aBA3DF0854306c2556B104601]));
    result = result.add(maxSaleToken.sub(balanceOf[0xCAD0AfB8Ec657D0DB9518B930855534f6433360f]));
    result = result.add(maxSaleToken.sub(balanceOf[0x041375343c3Bd1Bb28b40b5Ce7b4665A9a6e21D0]));
    return result;
  }

  function finalize() external onlyOwner {
    require(fundingEnabled);
    
    totalSoldTokens = getTotalSoldTokens();

    totalProjectToken = totalSoldTokens.mul(15).div(100);

    // Zeroing a cold wallet.
    balanceOf[fundingWallet] = 0;
    balanceOf[0xCAD0AfB8Ec657D0DB9518B930855534f6433360f] = 0;
    balanceOf[0x041375343c3Bd1Bb28b40b5Ce7b4665A9a6e21D0] = 0;

    // Shareholders/bounties
    balanceOf[0x47c8F28e6056374aBA3DF0854306c2556B104601] = totalProjectToken;

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

  function enableFundingWallets(address _address) external onlyOwner {
    require(fundingEnabled);
    require(fundingWallet != _address);

    fundingWallets[_address] = true;
  }
}