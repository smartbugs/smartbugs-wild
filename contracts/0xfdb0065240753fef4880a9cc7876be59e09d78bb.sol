pragma solidity ^0.4.24;

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
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

contract Ownable {
  address public owner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }
  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20Interface {
  string public name;
  string public symbol;
  uint8 public decimals;
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  
}

contract ApproveAndCallFallBack {
  function receiveApproval(address from, uint256 value, address token, bytes data) public;
}

contract ERC20Token is Ownable, ERC20Interface {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;
  mapping(address => mapping(address => uint256)) internal allowed;

  function balanceOf(address _owner) public view returns (uint256){
    return balances[_owner];
  }
  function _transfer(address _from, address _to, uint256 _value) internal returns (bool) {
    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }
  function transfer(address _to, uint256 _value) public returns (bool) {
    return _transfer(msg.sender,_to,_value);
  }

  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(msg.sender != _from);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    return _transfer(_from, _to, _value);
  }

  event Burn(address indexed from, uint256 value);

  function burnFrom(address _from, uint _value) public returns (bool) {
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    balances[_from] = balances[_from].sub(_value);
    totalSupply = totalSupply.sub(_value);
    emit Burn(_from, _value);
    return true;
  }
  function approveAndCall(address _spender, uint _value, bytes data) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    ApproveAndCallFallBack(_spender).receiveApproval(msg.sender, _value, this, data);
    return true;
  }
}

contract CryptoCow is ERC20Token{
  using SafeMath for uint256;

  uint256 constant _190EC6 = 1642182;
  uint256 constant _C8763 = 821091;
  constructor(uint256 initialSupply) public payable{
    totalSupply = initialSupply;
    balances[0xbeef] = initialSupply;
    name = "CryptoCow";
    symbol = "COW";
    decimals = 18;
  }
  function () public payable{
  }

  event Award(address indexed awardee, uint256 amount);

  function award(address _awardee, uint256 _amount) public onlyOwner {
    balances[_awardee] = balances[_awardee].add(_amount);
    balances[0xbeef] = balances[0xbeef].add(_amount.div(10));
    totalSupply = totalSupply.add(_amount.mul(11).div(10));
    emit Award(_awardee, _amount);
  }

  function selltoken(uint256 _amount) public {
    uint256 tokenValue = calculateTokenSell(_amount);
    _transfer(msg.sender, 0xbeef, _amount);
    tokenValue = tokenValue.sub(tokenValue.div(40));
    msg.sender.transfer(tokenValue);
  }

  function buyToken() public payable {
    uint256 tokenBought = calculateTokenBuy(msg.value, address(this).balance.sub(msg.value));
    tokenBought = tokenBought.sub(tokenBought.div(40));
    _transfer(0xbeef, msg.sender, tokenBought);
  }
  //magic formula from EtherShrimpFarm
  function calculateTrade(uint256 rt, uint256 rs, uint256 bs) public pure returns (uint256) {
    //(_190EC6*bs)/(_C8763+((_190EC6*rs+_C8763*rt)/rt));
    return _190EC6.mul(bs).div(_C8763.add(_190EC6.mul(rs).add(_C8763.mul(rt)).div(rt)));
  }
  function calculateTokenSell(uint256 amount) public view returns (uint256) {
    return calculateTrade(amount, balances[0xbeef], address(this).balance);
  }
  function calculateTokenBuy(uint256 eth, uint256 contractBalance) public view returns (uint256) {
    return calculateTrade(eth, contractBalance, balances[0xbeef]);
  }
  function calculateTokenBuySimple(uint256 eth) public view returns (uint256) {
    return calculateTokenBuy(eth, address(this).balance);
  }
  function getBalance() public view returns (uint256) {
    return address(this).balance;
  }
  function poolTokenBalance() public view returns (uint256) {
    return balances[0xbeef];
  }
  function transferAnyERC20Token(address tokenAddress, uint _value) public onlyOwner returns (bool success) {
    return ERC20Interface(tokenAddress).transfer(owner, _value);
  }
}