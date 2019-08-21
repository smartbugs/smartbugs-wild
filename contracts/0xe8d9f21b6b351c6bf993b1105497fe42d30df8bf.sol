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




contract Verifier{
function verifyTx(
uint[2],
uint[2],
uint[2][2],
uint[2],
uint[2],
uint[2],
uint[2],
uint[2],
address
) public pure returns (bool){}




/**
@notice © Copyright 2018 EYGS LLP and/or other members of the global Ernst & Young/EY network; pat. pending.
*/
function getInputBits(uint, address) public view returns(bytes8){}
}




contract OpsCoinShield{




/**
@notice © Copyright 2018 EYGS LLP and/or other members of the global Ernst & Young/EY network; pat. pending.




Contract to enable the management of ZKSnark-hidden coin transactions.
*/




address public owner;
bytes8[merkleWidth] ns; //store spent token nullifiers
uint constant merkleWidth = 256;
uint constant merkleDepth = 9;
uint constant lastRow = merkleDepth-1;
uint private balance = 0;
bytes8[merkleWidth] private zs; //array holding the commitments.  Basically the bottom row of the merkle tree
uint private zCount; //remember the number of commitments we hold
uint private nCount; //remember the number of commitments we spent
bytes8[] private roots; //holds each root we've calculated so that we can pull the one relevant to the prover
uint private currentRootIndex; //holds the index for the current root so that the
//prover can provide it later and this contract can look up the relevant root
Verifier private mv; //the verification smart contract that the mint function uses
Verifier private sv; //the verification smart contract that the transfer function uses
OpsCoin private ops; //the OpsCoin ERC20-like token contract
struct Proof { //recast this as a struct because otherwise, as a set of local variable, it takes too much stack space
uint[2] a;
uint[2] a_p;
uint[2][2] b;
uint[2] b_p;
uint[2] c;
uint[2] c_p;
uint[2] h;
uint[2] k;
}
//Proof proof; //not used - proof is now set per address
mapping(address => Proof) private proofs;




constructor(address mintVerifier, address transferVerifier, address opsCoin) public {
// TODO - you can get a way with a single, generic verifier.
owner = msg.sender;
mv = Verifier(mintVerifier);
sv = Verifier(transferVerifier);
ops = OpsCoin(opsCoin);
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








function getMintVerifier() public view returns(address){
return address(mv);
}




function getTransferVerifier() public view returns(address){
return address(sv);
}




function getOpsCoin() public view returns(address){
return address(ops);
}




/**
The mint function accepts opscoin and creates the same amount as a commitment.
*/
function mint(uint amount) public {
//first, verify the proof




bool result = mv.verifyTx(
proofs[msg.sender].a,
proofs[msg.sender].a_p,
proofs[msg.sender].b,
proofs[msg.sender].b_p,
proofs[msg.sender].c,
proofs[msg.sender].c_p,
proofs[msg.sender].h,
proofs[msg.sender].k,
msg.sender);




require(result); //the proof must check out
//transfer OPS from the sender to this contract
ops.transferFrom(msg.sender, address(this), amount);
//save the commitments
bytes8 z = mv.getInputBits(64, msg.sender);//recover the input params from MintVerifier
zs[zCount++] = z; //add the token
require(uint(mv.getInputBits(0, msg.sender))==amount); //check we've been correctly paid
bytes8 root = merkle(0,0); //work out the Merkle root as it's now different
currentRootIndex = roots.push(root)-1; //and save it to the list
}




/**
The transfer function transfers a commitment to a new owner
*/
function transfer() public {
//verification contract
bool result = sv.verifyTx(
proofs[msg.sender].a,
proofs[msg.sender].a_p,
proofs[msg.sender].b,
proofs[msg.sender].b_p,
proofs[msg.sender].c,
proofs[msg.sender].c_p,
proofs[msg.sender].h,
proofs[msg.sender].k,
msg.sender);
require(result); //the proof must verify. The spice must flow.




bytes8 nc = sv.getInputBits(0, msg.sender);
bytes8 nd = sv.getInputBits(64, msg.sender);
bytes8 ze = sv.getInputBits(128, msg.sender);
bytes8 zf = sv.getInputBits(192, msg.sender);
for (uint i=0; i<nCount; i++) { //check this is an unspent coin
require(ns[i]!=nc && ns[i]!=nd);
}
ns[nCount++] = nc; //remember we spent it
ns[nCount++] = nd; //remember we spent it
zs[zCount++] = ze; //add Bob's commitment to the list of commitments
zs[zCount++] = zf; //add Alice's commitment to the list of commitment
bytes8 root = merkle(0,0); //work out the Merkle root as it's now different
currentRootIndex = roots.push(root)-1; //and save it to the list
}




function burn(address payTo) public {
//first, verify the proof
bool result = mv.verifyTx(
proofs[msg.sender].a,
proofs[msg.sender].a_p,
proofs[msg.sender].b,
proofs[msg.sender].b_p,
proofs[msg.sender].c,
proofs[msg.sender].c_p,
proofs[msg.sender].h,
proofs[msg.sender].k,
msg.sender);




require(result); //the proof must check out ok
//transfer OPS from this contract to the nominated address
bytes8 C = mv.getInputBits(0, msg.sender);//recover the coin value
uint256 value = uint256(C); //convert the coin value to a uint
ops.transfer(payTo, value); //and pay the man
bytes8 Nc = mv.getInputBits(64, msg.sender); //recover the nullifier
ns[nCount++] = Nc; //add the nullifier to the list of nullifiers
bytes8 root = merkle(0,0); //work out the Merkle root as it's now different
currentRootIndex = roots.push(root)-1; //and save it to the list
}




/**
This function is only needed because mint and transfer otherwise use too many
local variables for the limited stack space, rather than pass a proof as
parameters to these functions (more logical)
*/
function setProofParams(
uint[2] a,
uint[2] a_p,
uint[2][2] b,
uint[2] b_p,
uint[2] c,
uint[2] c_p,
uint[2] h,
uint[2] k)
public {
//TODO there must be a shorter way to do this:
proofs[msg.sender].a[0] = a[0];
proofs[msg.sender].a[1] = a[1];
proofs[msg.sender].a_p[0] = a_p[0];
proofs[msg.sender].a_p[1] = a_p[1];
proofs[msg.sender].b[0][0] = b[0][0];
proofs[msg.sender].b[0][1] = b[0][1];
proofs[msg.sender].b[1][0] = b[1][0];
proofs[msg.sender].b[1][1] = b[1][1];
proofs[msg.sender].b_p[0] = b_p[0];
proofs[msg.sender].b_p[1] = b_p[1];
proofs[msg.sender].c[0] = c[0];
proofs[msg.sender].c[1] = c[1];
proofs[msg.sender].c_p[0] = c_p[0];
proofs[msg.sender].c_p[1] = c_p[1];
proofs[msg.sender].h[0] = h[0];
proofs[msg.sender].h[1] = h[1];
proofs[msg.sender].k[0] = k[0];
proofs[msg.sender].k[1] = k[1];
}




function getTokens() public view returns(bytes8[merkleWidth], uint root) {
//need the commitments to compute a proof and also an index to look up the current
//root.
return (zs,currentRootIndex);
}




/**
Function to return the root that was current at rootIndex
*/
function getRoot(uint rootIndex) view public returns(bytes8) {
return roots[rootIndex];
}




function computeMerkle() public view returns (bytes8){//for backwards compat
return merkle(0,0);
}




function merkle(uint r, uint t) public view returns (bytes8) {
//This is a recursive approach, which seems efficient but we do end up
//calculating the whole tree from scratch each time.  Need to look at storing
//intermediate values and seeing if that will make it cheaper.
if (r==lastRow) {
return zs[t];
} else {
return bytes8(sha256(merkle(r+1,2*t)^merkle(r+1,2*t+1))<<192);
}
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