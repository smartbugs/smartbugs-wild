pragma solidity ^0.4.24;

library SafeMath { 
function mul(uint256 a, uint256 b) internal pure returns (uint256) { 
if (a == 0) {
return 0;
}

uint256 c = a * b;
require(c / a == b);

return c;
} 
function div(uint256 a, uint256 b) internal pure returns (uint256) {
require(b > 0);
uint256 c = a / b; 
return c;
} 
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
require(b <= a);
uint256 c = a - b;

return c;
} 
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
require(c >= a);

return c;
} 
function mod(uint256 a, uint256 b) internal pure returns (uint256) {
require(b != 0);
return a % b;
}
}

contract ERC20Interface {
function totalSupply() public constant returns (uint);
function balanceOf(address tokenOwner) public constant returns (uint balance);
function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
function transfer(address to, uint tokens) public returns (bool success);
function approve(address spender, uint tokens) public returns (bool success);
function transferFrom(address from, address to, uint tokens) public returns (bool success);

event Transfer(address indexed from, address indexed to, uint tokens);
event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}  
contract ApproveAndCallFallBack {
function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
} 
contract Owned {
address public owner;
address public newOwner;

event OwnershipTransferred(address indexed _from, address indexed _to);

constructor() public {
owner = msg.sender;
}

modifier onlyOwner {
require(msg.sender == owner);
_;
}

function transferOwnership(address _newOwner) public onlyOwner {
newOwner = _newOwner;
}
function acceptOwnership() public {
require(msg.sender == newOwner);
emit OwnershipTransferred(owner, newOwner);
owner = newOwner;
newOwner = address(0);
}
}  
contract FixedSupplyToken is ERC20Interface, Owned {
using SafeMath for uint;

string public symbol;
string public  name;
uint8 public decimals;
uint _totalSupply; 

bool public crowdsaleEnabled;
uint public ethPerToken;
uint public bonusMinEth;
uint public bonusPct; 

mapping(address => uint) balances;
mapping(address => mapping(address => uint)) allowed; 
event Burn(address indexed from, uint256 value);
event Bonus(address indexed from, uint256 value);  
constructor() public {
symbol = "DN8";
name = "PLDGR.ORG";
decimals = 18;
_totalSupply = 450000000000000000000000000;


crowdsaleEnabled = false;
ethPerToken = 20000;
bonusMinEth = 0;
bonusPct = 0; 

balances[owner] = _totalSupply;
emit Transfer(address(0), owner, _totalSupply);
} 
function totalSupply() public view returns (uint) {
return _totalSupply.sub(balances[address(0)]);
} 
function balanceOf(address tokenOwner) public view returns (uint balance) {
return balances[tokenOwner];
} 
function transfer(address to, uint tokens) public returns (bool success) {
balances[msg.sender] = balances[msg.sender].sub(tokens);
balances[to] = balances[to].add(tokens);
emit Transfer(msg.sender, to, tokens);
return true;
} 
function approve(address spender, uint tokens) public returns (bool success) {
allowed[msg.sender][spender] = tokens;
emit Approval(msg.sender, spender, tokens);
return true;
} 
function transferFrom(address from, address to, uint tokens) public returns (bool success) {
balances[from] = balances[from].sub(tokens);
allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
balances[to] = balances[to].add(tokens);
emit Transfer(from, to, tokens);
return true;
} 
function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
return allowed[tokenOwner][spender];
} 
function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
allowed[msg.sender][spender] = tokens;
emit Approval(msg.sender, spender, tokens);
ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
return true;
} 
function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
return ERC20Interface(tokenAddress).transfer(owner, tokens);
} 
function () public payable { 
require(crowdsaleEnabled);  
uint ethValue = msg.value; 
uint tokens = ethValue.mul(ethPerToken); 
if(bonusPct > 0 && ethValue >= bonusMinEth){ 
uint bonus = tokens.div(100).mul(bonusPct); 
emit Bonus(msg.sender, bonus); 
tokens = tokens.add(bonus);
} 
balances[owner] = balances[owner].sub(tokens);
balances[msg.sender] = balances[msg.sender].add(tokens); 
emit Transfer(owner, msg.sender, tokens);
}  
function enableCrowdsale() public onlyOwner{
crowdsaleEnabled = true; 
} 
function disableCrowdsale() public onlyOwner{
crowdsaleEnabled = false; 
} 
function setTokenPrice(uint _ethPerToken) public onlyOwner{ 
ethPerToken = _ethPerToken;
}  
function setBonus(uint _bonusPct, uint _minEth) public onlyOwner {
bonusMinEth = _minEth;
bonusPct = _bonusPct;
} 
function burn(uint256 _value) public onlyOwner {
require(_value > 0);
require(_value <= balances[msg.sender]); 

address burner = msg.sender; 
balances[burner] = balances[burner].sub(_value); 
_totalSupply = _totalSupply.sub(_value);

emit Burn(burner, _value); 
}  
function withdraw(uint _amount) onlyOwner public {
require(_amount > 0); 
require(_amount <= address(this).balance);     

owner.transfer(_amount);
}


}