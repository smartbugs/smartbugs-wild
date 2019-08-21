pragma solidity ^0.4.15;


/**
* @title SafeMath
* @dev Math operations with safety checks that throw on error
*/
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

contract ERC20 {
uint256 public totalSupply;
function balanceOf(address who) constant returns (uint256);
function transfer(address to, uint256 value) returns (bool);
event Transfer(address indexed from, address indexed to, uint256 value);
function allowance(address owner, address spender) constant returns (uint256);
function transferFrom(address from, address to, uint256 value) returns (bool);
function approve(address spender, uint256 value) returns (bool);
event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BasicToken is ERC20 {
using SafeMath for uint256;

mapping(address => uint256) balances;
mapping (address => mapping (address => uint256)) allowed;
modifier nonZeroEth(uint _value) {
require(_value > 0);
_;
}

modifier onlyPayloadSize() {
require(msg.data.length >= 68);
_;
}
/**
* @dev transfer token for a specified address
* @param _to The address to transfer to.
* @param _value The amount to be transferred.
*/

function transfer(address _to, uint256 _value) nonZeroEth(_value) onlyPayloadSize returns (bool) {
if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]){
balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
Transfer(msg.sender, _to, _value);
return true;
}else{
return false;
}
}

/**
* @dev Transfer tokens from one address to another
* @param _from address The address which you want to send tokens from
* @param _to address The address which you want to transfer to
* @param _value uint256 the amout of tokens to be transfered
*/

function transferFrom(address _from, address _to, uint256 _value) nonZeroEth(_value) onlyPayloadSize returns (bool) {
if(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]){
uint256 _allowance = allowed[_from][msg.sender];
allowed[_from][msg.sender] = _allowance.sub(_value);
balances[_to] = balances[_to].add(_value);
balances[_from] = balances[_from].sub(_value);
Transfer(_from, _to, _value);
return true;
}else{
return false;
}
}


/**
* @dev Gets the balance of the specified address.
* @param _owner The address to query the the balance of.
* @return An uint256 representing the amount owned by the passed address.
*/

function balanceOf(address _owner) constant returns (uint256 balance) {
return balances[_owner];
}

function approve(address _spender, uint256 _value) returns (bool) {

// To change the approve amount you first have to reduce the addresses`
// allowance to zero by calling `approve(_spender, 0)` if it is not
// already 0 to mitigate the race condition described here:
// https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
require((_value == 0) || (allowed[msg.sender][_spender] == 0));

allowed[msg.sender][_spender] = _value;
Approval(msg.sender, _spender, _value);
return true;
}

/**
* @dev Function to check the amount of tokens that an owner allowed to a spender.
* @param _owner address The address which owns the funds.
* @param _spender address The address which will spend the funds.
* @return A uint256 specifing the amount of tokens still avaible for the spender.
*/
function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
return allowed[_owner][_spender];
}

}


contract RPTToken is BasicToken {

using SafeMath for uint256;

string public name = "RPT Token"; //name of the token
string public symbol = "RPT"; // symbol of the token
uint8 public decimals = 18; // decimals
uint256 public totalSupply = 100000000 * 10**18; // total supply of RPT Tokens

// variables
uint256 public keyEmployeeAllocation; // fund allocated to key employee
uint256 public totalAllocatedTokens; // variable to regulate the funds allocation
uint256 public tokensAllocatedToCrowdFund; // funds allocated to crowdfund

// addresses
address public founderMultiSigAddress = 0xf96E905091d38ca25e06C014fE67b5CA939eE83D; // multi sign address of founders which hold
address public crowdFundAddress; // address of crowdfund contract

//events
event ChangeFoundersWalletAddress(uint256 _blockTimeStamp, address indexed _foundersWalletAddress);
event TransferPreAllocatedFunds(uint256 _blockTimeStamp , address _to , uint256 _value);

//modifiers
modifier onlyCrowdFundAddress() {
require(msg.sender == crowdFundAddress);
_;
}

modifier nonZeroAddress(address _to) {
require(_to != 0x0);
_;
}

modifier onlyFounders() {
require(msg.sender == founderMultiSigAddress);
_;
}

// creation of the token contract
function RPTToken (address _crowdFundAddress) {
crowdFundAddress = _crowdFundAddress;

// Token Distribution
tokensAllocatedToCrowdFund = 70 * 10 ** 24; // 70 % allocation of totalSupply
keyEmployeeAllocation = 30 * 10 ** 24; // 30 % allocation of totalSupply

// Assigned balances to respective stakeholders
balances[founderMultiSigAddress] = keyEmployeeAllocation;
balances[crowdFundAddress] = tokensAllocatedToCrowdFund;

totalAllocatedTokens = balances[founderMultiSigAddress];
}

// function to keep track of the total token allocation
function changeTotalSupply(uint256 _amount) onlyCrowdFundAddress {
totalAllocatedTokens = totalAllocatedTokens.add(_amount);
}

// function to change founder multisig wallet address
function changeFounderMultiSigAddress(address _newFounderMultiSigAddress) onlyFounders nonZeroAddress(_newFounderMultiSigAddress) {
founderMultiSigAddress = _newFounderMultiSigAddress;
ChangeFoundersWalletAddress(now, founderMultiSigAddress);
}

}