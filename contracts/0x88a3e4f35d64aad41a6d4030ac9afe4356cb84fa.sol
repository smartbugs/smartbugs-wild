pragma solidity ^0.4.17;

//Based on OpenZeppelin's SafeMath
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
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
}

//Presearch Token (PRE)
contract preToken {
  using SafeMath for uint256;

  //Vanity settings
  string public constant name = "Presearch";
  string public constant symbol = "PRE";
  uint8 public constant decimals = 18;
  uint public totalSupply = 0;

  //Maximum supply of tokens that can ever be created 1,000,000,000
  uint256 public constant maxSupply = 1000000000e18;

  //Supply of tokens minted for presale distribution 250,000,000
  uint256 public constant initialSupply = 250000000e18;

  //Mappings
  mapping (address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;

  //Contract owner address for additional permission
  address public owner;

  //CrowdsaleAddress to allow for token distribution to presale purchasers before the unlockDate
  address public crowdsaleAddress;

  //Allow trades at November 30th 2017 00:00:00 AM EST
  uint public unlockDate = 1512018000;

  //Events
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  //Prevent short address attack
  modifier onlyPayloadSize(uint size) {
     assert(msg.data.length == size + 4);
     _;
   }

  //Checks if now is before unlock date and the msg.sender is not the contract owner or the crowdsaleAddress
  //Allows the owner or crowdsaleAddress to transfer before the unlock date to facilitate distribution
  modifier tradable {
      if (now < unlockDate && msg.sender != owner && msg.sender != crowdsaleAddress) revert();
      _;
    }

  //Checks if msg.sender is the contract owner
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  //Sends the initial supply of 250,000,000 tokens to the creator, sets the totalSupply, sets the owner and crowdsaleAddress to the deployer
  function preToken() public {
    balances[msg.sender] = initialSupply;
    totalSupply = initialSupply;
    owner = msg.sender;
    crowdsaleAddress = msg.sender;
  }

  //balances
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
   }

  //ERC-20 transfer with SafeMath
  function transfer(address _to, uint256 _value) public onlyPayloadSize(2 * 32) tradable returns (bool success) {
    require(_to != address(0));
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  //ERC-20 transferFrom with SafeMath
  function transferFrom(address _from, address _to, uint256 _value) public onlyPayloadSize(2 * 32) tradable returns (bool success) {
    require(_from != address(0) && _to != address(0));
    uint256 _allowance = allowed[_from][msg.sender];
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  //ERC-20 approve spender
  function approve(address _spender, uint256 _value) public returns (bool success) {
    require(_spender != address(0));
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  //ERC-20 allowance
  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  //Allows only the contract owner to transfer ownership to someone else
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  //Allows only the owner to create new tokens as long as the number of tokens attempting to be minted
  //plus the current totalSupply is less than or equal to 1,000,000,000
  //increases the totalSupply by the amount of tokens minted
  function mint(uint256 _amount) public onlyOwner {
    if (totalSupply.add(_amount) <= maxSupply){
      balances[msg.sender] = balances[msg.sender].add(_amount);
      totalSupply = totalSupply.add(_amount);
    }else{
      revert();
    }
  }

  //Allows the contract owner to burn (destroy) their own tokens
  //Decreases the totalSupply so that tokens could be minted again at later date
  function burn(uint256 _amount) public onlyOwner {
    require(balances[msg.sender] >= _amount);
    balances[msg.sender] = balances[msg.sender].sub(_amount);
    totalSupply = totalSupply.sub(_amount);
  }

  //Allows the owner to set the crowdsaleAddress
  function setCrowdsaleAddress(address newCrowdsaleAddress) public onlyOwner {
    require(newCrowdsaleAddress != address(0));
    crowdsaleAddress = newCrowdsaleAddress;
  }

  //Allow the owner to update the unlockDate to allow trading sooner, but not later than the original unlockDate
  function updateUnlockDate(uint _newDate) public onlyOwner {
    require (_newDate <= 1512018000);
      unlockDate=_newDate;
  }

}