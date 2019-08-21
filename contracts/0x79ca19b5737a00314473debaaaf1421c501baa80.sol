pragma solidity ^0.4.11;

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

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

contract SmartToken is Ownable {
  using SafeMath for uint256;

  uint256 public totalSupply;
  mapping(address => uint256) balances;
  mapping (address => mapping (address => uint256)) allowed;
  bool public mintingFinished = false;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Burn(address indexed burner, uint256 value);
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    uint256 _allowance = allowed[_from][msg.sender];
    require(_allowance > 0);
    require(_allowance >= _value);
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function increaseApproval (address _spender, uint _addedValue) returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function burn(uint256 _value) public {
      require(_value > 0);

      address burner = msg.sender;
      balances[burner] = balances[burner].sub(_value);
      totalSupply = totalSupply.sub(_value);
      Burn(burner, _value);
  }

  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
    return true;
  }

  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }

}

contract Token is SmartToken {

  using SafeMath for uint256;
  string public name = "Ponscoin";
  string public symbol = "PONS";
  uint public decimals = 6;
  uint256 public INITIAL_SUPPLY = 10000000;

  function Token() {
    owner = msg.sender;
    mint(msg.sender, INITIAL_SUPPLY * 1000000);
  }

  function transfer(address _to, uint _value) returns (bool success) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function () payable {
    revert();
  }

  function withdraw() onlyOwner {
    msg.sender.transfer(this.balance);
  }

  function withdrawSome(uint _value) onlyOwner {
    require(_value <= this.balance);
    msg.sender.transfer(_value);
  }

  function killContract(uint256 _value) onlyOwner {
    require(_value > 0);
    selfdestruct(owner);
  }
}

contract Sale is Ownable {
  using SafeMath for uint256;
  uint256 public rate = 162866449511000;
  Token public token;

  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

  function Sale() {
    owner = msg.sender;
  }

  function startSale(address _token) onlyOwner {
    token = Token(_token);
  }

  function updateRate(uint256 _rate) onlyOwner {
    rate = _rate;
  }

  function () payable {
    if(rate == 0){
      revert();
    }
    if(msg.value < rate){
      revert();
    }
    uint256 value = msg.value;
    uint256 tokens = value.mul(1000000).div(rate);
    if(token.transferFrom(owner, msg.sender, tokens)){
        TokenPurchase(msg.sender, msg.sender, value, tokens);
    } else {
      revert();
    }
  }

  function tokensAvailable() constant returns (uint256) {
    return token.balanceOf(owner);
  }

  function withdraw() onlyOwner {
    msg.sender.transfer(this.balance);
  }

  function withdrawSome(uint _value) onlyOwner {
    require(_value <= this.balance);
    msg.sender.transfer(_value);
  }

  function killContract(uint256 _value) onlyOwner {
    require(_value > 0);
    selfdestruct(owner);
  }
}