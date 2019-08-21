pragma solidity ^0.4.13;




interface ERC20Interface {
function totalSupply() external view returns (uint256);




function balanceOf(address who) external view returns (uint256);




function allowance(address owner, address spender)
external view returns (uint256);




function transfer(address to, uint256 value) external returns (bool);




function approve(address spender, uint256 value)
external returns (bool);




function transferFrom(address from, address to, uint256 value)
external returns (bool);




event Transfer(
address indexed from,
address indexed to,
uint256 value
);




event Approval(
address indexed owner,
address indexed spender,
uint256 value
);
}




contract OpsCoin is ERC20Interface {




/**
@notice © Copyright 2018 EYGS LLP and/or other members of the global Ernst & Young/EY network; pat. pending.
*/




using SafeMath for uint256;




string public symbol;
string public name;
address public owner;
uint256 public totalSupply;








mapping (address => uint256) private balances;
mapping (address => mapping (address => uint256)) private allowed;
mapping (address => mapping (address => uint)) private timeLock;








constructor() {
symbol = "OPS";
name = "EY OpsCoin";
totalSupply = 1000000;
owner = msg.sender;
balances[owner] = totalSupply;
emit Transfer(address(0), owner, totalSupply);
}




//only owner  modifier
modifier onlyOwner () {
require(msg.sender == owner);
_;
}




/**
self destruct added by westlad
*/
function close() public onlyOwner {
selfdestruct(owner);
}




/**
* @dev Gets the balance of the specified address.
* @param _address The address to query the balance of.
* @return An uint256 representing the amount owned by the passed address.
*/
function balanceOf(address _address) public view returns (uint256) {
return balances[_address];
}




/**
* @dev Function to check the amount of tokens that an owner allowed to a spender.
* @param _owner address The address which owns the funds.
* @param _spender address The address which will spend the funds.
* @return A uint256 specifying the amount of tokens still available for the spender.
*/
function allowance(address _owner, address _spender) public view returns (uint256)
{
return allowed[_owner][_spender];
}




/**
* @dev Total number of tokens in existence
*/
function totalSupply() public view returns (uint256) {
return totalSupply;
}








/**
* @dev Internal function that mints an amount of the token and assigns it to
* an account. This encapsulates the modification of balances such that the
* proper events are emitted.
* @param _account The account that will receive the created tokens.
* @param _amount The amount that will be created.
*/
function mint(address _account, uint256 _amount) public {
require(_account != 0);
require(_amount > 0);
totalSupply = totalSupply.add(_amount);
balances[_account] = balances[_account].add(_amount);
emit Transfer(address(0), _account, _amount);
}




/**
* @dev Internal function that burns an amount of the token of a given
* account.
* @param _account The account whose tokens will be burnt.
* @param _amount The amount that will be burnt.
*/
function burn(address _account, uint256 _amount) public {
require(_account != 0);
require(_amount <= balances[_account]);




totalSupply = totalSupply.sub(_amount);
balances[_account] = balances[_account].sub(_amount);
emit Transfer(_account, address(0), _amount);
}




/**
* @dev Internal function that burns an amount of the token of a given
* account, deducting from the sender's allowance for said account. Uses the
* internal burn function.
* @param _account The account whose tokens will be burnt.
* @param _amount The amount that will be burnt.
*/
function burnFrom(address _account, uint256 _amount) public {
require(_amount <= allowed[_account][msg.sender]);




allowed[_account][msg.sender] = allowed[_account][msg.sender].sub(_amount);
emit Approval(_account, msg.sender, allowed[_account][msg.sender]);
burn(_account, _amount);
}




/**
* @dev Transfer token for a specified address
* @param _to The address to transfer to.
* @param _value The amount to be transferred.
*/
function transfer(address _to, uint256 _value) public returns (bool) {
require(_value <= balances[msg.sender]);
require(_to != address(0));




balances[msg.sender] = balances[msg.sender].sub(_value);
balances[_to] = balances[_to].add(_value);
emit Transfer(msg.sender, _to, _value);
return true;
}




/**
* @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
* Beware that changing an allowance with this method brings the risk that someone may use both the old
* and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
* race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
* https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
* @param _spender The address which will spend the funds.
* @param _value The amount of tokens to be spent.
*/
function approve(address _spender, uint256 _value) public returns (bool) {
require(_spender != address(0));




allowed[msg.sender][_spender] = _value;
emit Approval(msg.sender, _spender, _value);
return true;
}




/**
* @dev Approve the passed address to spend the specified amount of tokens after a specfied amount of time on behalf of msg.sender.
* Beware that changing an allowance with this method brings the risk that someone may use both the old
* and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
* race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
* https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
* @param _spender The address which will spend the funds.
* @param _value The amount of tokens to be spent.
* @param _timeLockTill The time until when this amount cannot be withdrawn
*/
function approveAt(address _spender, uint256 _value, uint _timeLockTill) public returns (bool) {
require(_spender != address(0));




allowed[msg.sender][_spender] = _value;
timeLock[msg.sender][_spender] = _timeLockTill;
emit Approval(msg.sender, _spender, _value);
return true;
}




/**
* @dev Transfer tokens from one address to another
* @param _from address The address which you want to send tokens from
* @param _to address The address which you want to transfer to
* @param _value uint256 the amount of tokens to be transferred
*/
function transferFrom(address _from, address _to, uint256 _value) public returns (bool)
{
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
require(_to != address(0));




balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
emit Transfer(_from, _to, _value);
return true;
}




/**
* @dev Transfer tokens from one address to another
* @param _from address The address which you want to send tokens from
* @param _to address The address which you want to transfer to
* @param _value uint256 the amount of tokens to be transferred
*/
function transferFromAt(address _from, address _to, uint256 _value) public returns (bool)
{
require(_value <= balances[_from]);
require(_value <= allowed[_from][msg.sender]);
require(_to != address(0));
require(block.timestamp > timeLock[_from][msg.sender]);




balances[_from] = balances[_from].sub(_value);
balances[_to] = balances[_to].add(_value);
allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
emit Transfer(_from, _to, _value);
return true;
}




/**
* @dev Increase the amount of tokens that an owner allowed to a spender.
* approve should be called when allowed_[_spender] == 0. To increment
* allowed value is better to use this function to avoid 2 calls (and wait until
* the first transaction is mined)
* From MonolithDAO Token.sol
* @param _spender The address which will spend the funds.
* @param _addedValue The amount of tokens to increase the allowance by.
*/
function increaseAllowance(address _spender, uint256 _addedValue) public returns (bool)
{
require(_spender != address(0));




allowed[msg.sender][_spender] = (allowed[msg.sender][_spender].add(_addedValue));
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}




/**
* @dev Decrease the amount of tokens that an owner allowed to a spender.
* approve should be called when allowed_[_spender] == 0. To decrement
* allowed value is better to use this function to avoid 2 calls (and wait until
* the first transaction is mined)
* From MonolithDAO Token.sol
* @param _spender The address which will spend the funds.
* @param _subtractedValue The amount of tokens to decrease the allowance by.
*/
function decreaseAllowance(address _spender, uint256 _subtractedValue) public returns (bool)
{
require(_spender != address(0));




allowed[msg.sender][_spender] = (allowed[msg.sender][_spender].sub(_subtractedValue));
emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
return true;
}




}




library SafeMath {




/**
* @dev Multiplies two numbers, reverts on overflow.
*/
function mul(uint256 a, uint256 b) internal pure returns (uint256) {
// Gas optimization: this is cheaper than requiring 'a' not being zero, but the
// benefit is lost if 'b' is also tested.
// See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
if (a == 0) {
return 0;
}




uint256 c = a * b;
require(c / a == b);




return c;
}




/**
* @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
*/
function div(uint256 a, uint256 b) internal pure returns (uint256) {
require(b > 0); // Solidity only automatically asserts when dividing by 0
uint256 c = a / b;
// assert(a == b * c + a % b); // There is no case in which this doesn't hold




return c;
}




/**
* @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
*/
function sub(uint256 a, uint256 b) internal pure returns (uint256) {
require(b <= a);
uint256 c = a - b;




return c;
}




/**
* @dev Adds two numbers, reverts on overflow.
*/
function add(uint256 a, uint256 b) internal pure returns (uint256) {
uint256 c = a + b;
require(c >= a);




return c;
}




/**
* @dev Divides two numbers and returns the remainder (unsigned integer modulo),
* reverts when dividing by zero.
*/
function mod(uint256 a, uint256 b) internal pure returns (uint256) {
require(b != 0);
return a % b;
}
}