pragma solidity ^0.4.24;

contract Ownable{

 address public owner;
 
 event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

   constructor() public {
     owner = msg.sender;
   }

   modifier onlyOwner() {
     require(msg.sender == owner);
    _;
   }
    
   function transferOwnership(address newOwner) public onlyOwner {
     require(newOwner != address(0));
     emit OwnershipTransferred(owner, newOwner);
     owner = newOwner;
   }
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
    
contract MintableToken is Ownable {

  using SafeMath for uint256;

  uint256 public totalSupply;

  event Mint(address indexed to, uint256 amount);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event MintFinished();

  bool public mintingFinished = false;
  
  address public saleAgent;

  mapping (address => uint256) balances;
  
  function setSaleAgent(address newSaleAgnet) public onlyOwner {
    saleAgent = newSaleAgnet;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(msg.sender == saleAgent);
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

  function mint(address _to, uint256 _amount) public returns (bool) {
    require(msg.sender == saleAgent && !mintingFinished);
    
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    return true;
  }

  function finishMinting() public returns (bool) {
    require((msg.sender == saleAgent || msg.sender == owner) && !mintingFinished);
    mintingFinished = true;
    emit MintFinished();
    return true;
  }

}

contract TokenSale is Ownable {

  using SafeMath for uint;
  uint public period;
  uint public price = 1000000000000000000;
  uint public start;
  uint public minInvestedLimit = 100000000000000000;
  uint public hardcap = 25000000000000000000000;
  uint public invested;

  MintableToken public token;

  bool public PreICO = true;

  address public wallet;

  mapping(address => bool) public whiteList;
  
  modifier isUnderHardcap() {
    require(invested < hardcap);
    _;
  }

  modifier PhaseCheck() {
    if(PreICO == true)
    require(whiteList[msg.sender]);
    _;
  }

  modifier minInvestLimited(uint value) {
    require(value >= minInvestedLimit);
    _;
  }

  function addToWhiteList(address _address) public onlyOwner {
    whiteList[_address] = true;
  }
  
  function deleteFromWhiteList(address _address) public onlyOwner {
    whiteList[_address] = false;
  }

  function preicofinish() public onlyOwner {
    PreICO = false;
  }
  
  function icofinish() public onlyOwner {
    token.finishMinting();
  }

  function GRW() public onlyOwner {
    PreICO = true;
  }

  function setToken(address newToken) public onlyOwner {
    token = MintableToken(newToken);
  }

  function setWallet(address newWallet) public onlyOwner {
    wallet = newWallet;
  }

  function setStart(uint newStart) public onlyOwner {
    start = newStart;
  }
  
  function setPeriod(uint newPeriod) public onlyOwner {
    period = newPeriod;
  }
  
  function endSaleDate() public view returns(uint) {
    return start.add(period * 1 days);
  }
  
  function calculateTokens(uint _invested) internal view returns(uint) {
    return _invested.mul(price).div(1 ether);
  }

  function mintTokens(address to, uint tokens) internal {
    token.mint(this, tokens);
    token.transfer(to, tokens);
  }

  function mintTokensByETH(address to, uint _invested) internal isUnderHardcap returns(uint) {
    invested = invested.add(_invested);
    uint tokens = calculateTokens(_invested);
    mintTokens(to, tokens);
    return tokens;
  }

  function fallback() internal minInvestLimited(msg.value) PhaseCheck returns(uint) {
    require(now >= start && now < endSaleDate());
    wallet.transfer(msg.value);
    return mintTokensByETH(msg.sender, msg.value);
  }

  function () public payable {
    fallback();
  }

}

contract GrowUpToken is MintableToken {

  string public constant name = "GrowUpToken";

  string public constant symbol = "GRW";

  uint32 public constant decimals = 0;

}