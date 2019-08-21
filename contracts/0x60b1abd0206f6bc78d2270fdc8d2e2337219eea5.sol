pragma solidity ^0.4.24;

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

contract BIWINToken {
    using SafeMath for uint256;
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    address public owner;
    
    address public betaAddress;
    address public alphaAddress;
    
    mapping (address => uint256) public balanceOf;
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    constructor(uint256 initialSupply, string tokenName, string tokenSymbol, address alphaAddr, address betaAddr) {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        name = tokenName;                                   
        symbol = tokenSymbol;
        betaAddress = betaAddr;
        alphaAddress = alphaAddr;
        owner = msg.sender;
        balanceOf[alphaAddress] = totalSupply;
        balanceOf[betaAddress] = 0;
    }
    modifier onlyGame() {
        require(msg.sender == alphaAddress);
        _;
    }
    
    function queryBalanceOf(address addr) public returns(uint256) {
        require(addr != 0x0);
        return balanceOf[addr];
    }
    
   function queryOwnerAddr() public constant returns(address) {
        return owner;
    }
    
    function _transfer(address from, address to, uint256 value) internal {
        require(to != 0x0);
        require(balanceOf[from] >= value);
        require(balanceOf[to] + value > balanceOf[to]);
        uint previousBalances = balanceOf[from] + balanceOf[to];
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        Transfer(from, to, value);
        assert(balanceOf[from] + balanceOf[to] == previousBalances);
    }
    function transferToBetaAddress(address to, uint256 value) onlyGame {
        require(to == betaAddress);
        _transfer(msg.sender, to, value);
    }
    
    function transfer(address to, uint256 value) public {
        require(to != betaAddress);
        require(msg.sender != alphaAddress);
        _transfer(msg.sender, to, value);
    }
}