pragma solidity ^0.4.18;

contract Ownable {
address public owner;


event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

function Ownable() public {
owner = msg.sender;
}

modifier onlyOwner() {
require(msg.sender == owner);
_;
}

function transferOwnership(address newOwner) public onlyOwner {
require(newOwner != address(0));
OwnershipTransferred(owner, newOwner);
owner = newOwner;
}
}

contract Pausable is Ownable {
event Pause();
event Unpause();

bool public paused = false;

modifier whenNotPaused() {
require(!paused);
_;
}

modifier whenPaused() {
require(paused);
_;
}

function pause() onlyOwner whenNotPaused public {
paused = true;
Pause();
}

function unpause() onlyOwner whenPaused public {
paused = false;
Unpause();
}
}

contract ERC20Basic {
uint256 public totalSupply;
function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);
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
}


contract BasicToken is ERC20Basic {
using SafeMath for uint256;

mapping(address => uint256) balances;

function transfer(address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[msg.sender]);

balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}

function balanceOf(address _owner) public view returns (uint256 balance) {
return balances[_owner];
}
}

contract StandardToken is ERC20, BasicToken {

mapping (address => mapping (address => uint256)) internal allowed;

function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
require(_to != address(0));
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);

balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
Transfer(_from, _to, _value);
return true;
}

function approve(address _spender, uint256 _value) public returns (bool) {
allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}

function allowance(address _owner, address _spender) public view returns (uint256) {
return allowed[_owner][_spender];
}

function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}

function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
uint oldValue = allowed[msg.sender][_spender];
if (_subtractedValue > oldValue) {
allowed[msg.sender][_spender] = 0;
} else {
allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
}
Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}
}

contract MintableToken is StandardToken, Ownable {
event Mint(address indexed to, uint256 amount);
event MintFinished();

bool public mintingFinished = false;


modifier canMint() {
require(!mintingFinished);
_;
}

function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
totalSupply = totalSupply.add(_amount);
balances[_to] = balances[_to].add(_amount);
Mint(_to, _amount);
Transfer(address(0), _to, _amount);
return true;
}

function finishMinting() onlyOwner canMint public returns (bool) {
mintingFinished = true;
MintFinished();
return true;
}
}

contract TokenConfig {

string  public constant TOKEN_SYMBOL   = "GYM";
string  public constant TOKEN_NAME     = "GYM Rewards";
uint8   public constant TOKEN_DECIMALS = 18;

uint256 public constant DECIMALSFACTOR = 10**uint256(TOKEN_DECIMALS);
}

contract TokenSaleConfig is TokenConfig {

uint256 public constant START_TIME                = 1516406400; 
uint256 public constant PHASE2_START_TIME         = 1517443200; 
uint256 public constant PHASE3_START_TIME         = 1518739200; 
uint256 public constant PHASE4_START_TIME         = 1519862400; 
uint256 public constant PHASE5_START_TIME         = 1521158400; 
uint256 public constant END_TIME                  = 1522540800; 

uint256 public constant TIER1_RATE                  =  160000;
uint256 public constant TIER2_RATE                  =  150000;
uint256 public constant TIER3_RATE                  =  125000;
uint256 public constant TIER4_RATE                  =  115000;
uint256 public constant TIER5_RATE                  =  100000;


uint256 public constant CONTRIBUTION_MIN          = 1 * 10 ** 16; // 0.01 ether
uint256 public constant CONTRIBUTION_MAX          = 100000 ether;

uint256 public constant MAX_TOKENS_SALE               = 2000000000  * DECIMALSFACTOR;  // 13,500 ETH HARDCAP
uint256 public constant MAX_TOKENS_FOUNDERS           =  100000000  * DECIMALSFACTOR; // 10%
uint256 public constant MAX_TOKENS_ADVISORS           =  150000000  * DECIMALSFACTOR; // 15%
uint256 public constant MAX_TOKENS_EARLY_INVESTORS    =  150000000  * DECIMALSFACTOR; // 15%
uint256 public constant MAX_TOKENS_AIRDROPS_BOUNTIES  =    5000000  * DECIMALSFACTOR; // 3.125 Airdrops/Bounties
//uint256 public constant TOKENS_ACCELERATOR_MAX    = 257558034 * DECIMALSFACTOR;
//uint256 public constant TOKENS_FUTURE             = 120000000 * DECIMALSFACTOR;
}



contract GYMRewardsToken is MintableToken, TokenConfig {

string public constant name = TOKEN_NAME;
string public constant symbol = TOKEN_SYMBOL;
uint8 public constant decimals = TOKEN_DECIMALS;
}

contract GYMRewardsCrowdsale is Pausable, TokenSaleConfig {
using SafeMath for uint256;

GYMRewardsToken public token;

uint256 public startTime;
uint256 public tier2Time;
uint256 public tier3Time;
uint256 public tier4Time;
uint256 public tier5Time;
uint256 public endTime;

address public wallet;

uint256 public weiRaised;

uint256 public tokensMintedForSale;
uint256 public tokensMintedForOperations;

bool public isFinalized = false;
bool public bountiesMinted = false;
bool public opMinted = false;


event Finalized();

modifier onlyDuringSale() {
require(hasStarted() && !hasEnded());
_;
}

modifier onlyAfterSale() {
require(hasEnded());
_;
}

event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
event BountiesMinted(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


function GYMRewardsCrowdsale(address _wallet) public {

require(_wallet != address(0));


token = createTokenContract();
startTime = START_TIME;
tier2Time = PHASE2_START_TIME;
tier3Time = PHASE3_START_TIME;
tier4Time = PHASE4_START_TIME;
tier5Time = PHASE5_START_TIME;
endTime = END_TIME;
wallet = _wallet;
mintBounties(wallet);
}

function createTokenContract() internal returns (GYMRewardsToken) {
return new GYMRewardsToken();
}

function () public payable whenNotPaused onlyDuringSale {
buyTokens(msg.sender);
}

function mintBounties(address beneficiary) public onlyOwner{
	if (opMinted == false)
	{
		opMinted = true;
		tokensMintedForOperations.add(MAX_TOKENS_AIRDROPS_BOUNTIES);
		token.mint(beneficiary, MAX_TOKENS_AIRDROPS_BOUNTIES);

		BountiesMinted(owner, beneficiary, MAX_TOKENS_AIRDROPS_BOUNTIES, MAX_TOKENS_AIRDROPS_BOUNTIES);
	}
}

function buyTokens(address beneficiary) public payable whenNotPaused onlyDuringSale {
require(beneficiary != address(0));
require(msg.value > 0); 

uint256 weiAmount = msg.value;

uint256 exchangeRate = calculateTierBonus();
uint256 tokens = weiAmount.mul(exchangeRate);

// Debe cambiar si se quiere vender mas del 100% de los tokens
require (tokensMintedForSale.add(tokens) <= MAX_TOKENS_SALE);


weiRaised = weiRaised.add(weiAmount); 
tokensMintedForSale = tokensMintedForSale.add(tokens); 

token.mint(beneficiary, tokens);

TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

if (tokensMintedForSale == MAX_TOKENS_SALE) {
finalizeInternal();
}

forwardFunds();
}

function calculateTierBonus() public view returns (uint256){

if(now >= startTime && now < tier2Time){
return TIER1_RATE;
}

if(now >= tier2Time && now < tier3Time){
return TIER2_RATE;
}

if(now >= tier3Time && now <= tier4Time){
return TIER3_RATE;
}

if(now >= tier4Time && now <= tier5Time){
return TIER4_RATE;
}

if(now >= tier5Time && now <= endTime){
return TIER5_RATE;
}


}

function finalizeInternal() internal returns (bool) {
require(!isFinalized);

isFinalized = true;
Finalized();
return true;
}

function forwardFunds() internal {
wallet.transfer(msg.value);
}

function hasEnded() public constant returns (bool) {
bool _saleIsOver = now > endTime;
return _saleIsOver || isFinalized;
}

function hasStarted() public constant returns (bool) {
return now >= startTime;
}

function tellTime() public constant returns (uint) {
return now;
}
}