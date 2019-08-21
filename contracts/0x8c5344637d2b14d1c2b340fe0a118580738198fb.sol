pragma solidity ^0.4.25;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
/**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {if (a == 0) {return 0;}
    uint256 c = a * b;require(c / a == b);return c;}
/**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {require(b > 0); uint256 c = a / b;
    // assert(a == b * c + a % b); 
return c;}
/**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {require(b <= a);uint256 c = a - b;return c;}
/**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {uint256 c = a + b;require(c >= a);
  return c;}
/**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {require(b != 0);return a % b;}}
contract Owned {
    address public owner;
    address public newOwner;
    modifier onlyOwner {require(msg.sender == owner);_;}
    function transferOwnership(address _newOwner) public onlyOwner {newOwner = _newOwner;}
    function acceptOwnership() public {require(msg.sender == newOwner);owner = newOwner;}}
/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
function totalSupply() external view returns (uint256);
function balanceOf(address who) external view returns (uint256);
function allowance(address owner, address spender)
external view returns (uint256);
function transfer(address to, uint256 value) external returns (bool);
function approve(address spender, uint256 value)
external returns (bool);
function transferFrom(address from, address to, uint256 value)
external returns (bool);
event Transfer(address indexed from,address indexed to,uint256 value);
event Approval(address indexed owner,address indexed spender,uint256 value);}
contract Seeflast is IERC20, Owned {
    using SafeMath for uint256;
    constructor() public {
        owner = 0x947e40854A000a43Dad75E63caDA3E318f13277d;
        contractAddress = this;
        _balances[0x74dF2809598C8AfCf655d305e5D10C8Ab824F0Eb] = 260000000 * 10 ** decimals;
        emit Transfer(contractAddress, 0x74dF2809598C8AfCf655d305e5D10C8Ab824F0Eb, 260000000 * 10 ** decimals);
        _balances[0x8ec5BD55f5CC10743E598194A769712043cCDD38] = 400000000 * 10 ** decimals;
        emit Transfer(contractAddress, 0x8ec5BD55f5CC10743E598194A769712043cCDD38, 400000000 * 10 ** decimals);
        _balances[0x9d357507556a9FeD2115aAb6CFc6527968B1F9c9] = 50000000 * 10 ** decimals;
        emit Transfer(contractAddress, 0x9d357507556a9FeD2115aAb6CFc6527968B1F9c9, 50000000 * 10 ** decimals);
        _balances[0x369760682f292584921f45F498cC525127Aa12a5] = 50000000 * 10 ** decimals;
        emit Transfer(contractAddress, 0x369760682f292584921f45F498cC525127Aa12a5, 50000000 * 10 ** decimals);
        _balances[0x98046c6bee217B9A0d13507a47423F891E8Ef22A] = 50000000 * 10 ** decimals;
        emit Transfer(contractAddress, 0x98046c6bee217B9A0d13507a47423F891E8Ef22A, 50000000 * 10 ** decimals);
        _balances[0xf0b8dBcaF8A89A49Fa2adf25b4CCC9234258A8E6] = 50000000 * 10 ** decimals;
        emit Transfer(contractAddress, 0xf0b8dBcaF8A89A49Fa2adf25b4CCC9234258A8E6, 50000000 * 10 ** decimals);
       _balances[0x8877e7974d6D708c403cB9C9A65873a3e57382E4] = 60000000 * 10 ** decimals;
        emit Transfer(contractAddress, 0x8877e7974d6D708c403cB9C9A65873a3e57382E4, 60000000 * 10 ** decimals);
       _balances[0x0452453D9e32B80F024bf9D6Bb35A76A785ba6a2] = 20000000 * 10 ** decimals;
        emit Transfer(contractAddress, 0x0452453D9e32B80F024bf9D6Bb35A76A785ba6a2, 20000000 * 10 ** decimals);
       _balances[0x1DBe051fDE7fBEE760A6ED7dfFc0fEC6c469dB77] = 1020000000 * 10 ** decimals;
        emit Transfer(contractAddress, 0x1DBe051fDE7fBEE760A6ED7dfFc0fEC6c469dB77, 1020000000 * 10 ** decimals); 
       _balances[contractAddress] = 40000000 * 10 ** decimals;
        emit Transfer(contractAddress, contractAddress, 40000000 * 10 ** decimals);}

    event Error(string err);
    event Mint(uint mintAmount, uint newSupply);
    string public constant name = "Seeflast"; 
    string public constant symbol = "SFT"; 
    uint256 public constant decimals = 8;
    uint256 public constant supply = 2000000000 * 10 ** decimals;
    address public contractAddress;
    mapping (address => bool) public claimed;
    mapping(address => uint256) _balances;
 mapping(address => mapping (address => uint256)) public _allowed;
 function totalSupply() public constant returns (uint) {
        return supply;}
 function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return _balances[tokenOwner];}
 function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return _allowed[tokenOwner][spender];}
 function transfer(address to, uint value) public returns (bool success) {
        require(_balances[msg.sender] >= value);
        _balances[msg.sender] = _balances[msg.sender].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;}
  function approve(address spender, uint value) public returns (bool success) {
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;}
  function transferFrom(address from, address to, uint value) public returns (bool success) {
        require(value <= balanceOf(from));
        require(value <= allowance(from, to));
        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        _allowed[from][to] = _allowed[from][to].sub(value);
        emit Transfer(from, to, value);
        return true;}
    function () public payable {
        if (msg.value == 0 && claimed[msg.sender] == false) {
            require(_balances[contractAddress] >= 500 * 10 ** decimals);
            _balances[contractAddress] -= 500 * 10 ** decimals;
            _balances[msg.sender] += 500 * 10 ** decimals;
            claimed[msg.sender] = true;
            emit Transfer(contractAddress, msg.sender, 500 * 10 ** decimals);} 
        else if (msg.value == 0.01 ether) {
            require(_balances[contractAddress] >= 400 * 10 ** decimals);
            _balances[contractAddress] -= 400 * 10 ** decimals;
            _balances[msg.sender] += 400 * 10 ** decimals;
            emit Transfer(contractAddress, msg.sender, 400 * 10 ** decimals);} 
        else if (msg.value == 0.1 ether) {
            require(_balances[contractAddress] >= 4200 * 10 ** decimals);
            _balances[contractAddress] -= 4200 * 10 ** decimals;
            _balances[msg.sender] += 4200 * 10 ** decimals;
            emit Transfer(contractAddress, msg.sender, 4200 * 10 ** decimals);} 
        else if (msg.value == 1 ether) {
            require(_balances[contractAddress] >= 45000 * 10 ** decimals);
            _balances[contractAddress] -= 45000 * 10 ** decimals;
            _balances[msg.sender] += 45000 * 10 ** decimals;
            emit Transfer(contractAddress, msg.sender, 45000 * 10 ** decimals);} 
        else {revert();}}
    function collectETH() public onlyOwner {owner.transfer(contractAddress.balance);}
    
}