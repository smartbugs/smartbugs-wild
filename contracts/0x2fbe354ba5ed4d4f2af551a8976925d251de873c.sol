pragma solidity ^0.4.11;

contract Token {
    bytes32 public standard;
    bytes32 public name;
    bytes32 public symbol;
    uint256 public totalSupply;
    uint8 public decimals;
    bool public allowTransactions;
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    function transfer(address _to, uint256 _value) returns (bool success);
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
}


contract DVIP {
  function feeFor(address from, address to, uint256 amount) constant external returns (uint256 value);
}

contract Assertive {
  function assert(bool assertion) {
    if (!assertion) throw;
  }
}

contract Owned is Assertive {
  address internal owner;
  event SetOwner(address indexed previousOwner, address indexed newOwner);
  function Owned () {
    owner = msg.sender;
  }
  modifier onlyOwner {
    assert(msg.sender == owner);
    _;
  }
  function setOwner(address newOwner) onlyOwner {
    SetOwner(owner, newOwner);
    owner = newOwner;
  }
  function getOwner() returns (address out) {
    return owner;
  }
}

contract Math is Assertive {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }
}

contract Exchange is Math, Owned {

  mapping (address => mapping (address => uint256)) public tokens;

  mapping (bytes32 => uint256) public orderFills;
  address public feeAccount;
  address public dvipAddress;
  address public feeMakeExporter;
  address public feeTakeExporter;
  event Order(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, uint256 expires, uint256 nonce, address user, uint8 v, bytes32 r, bytes32 s);
  event Cancel(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, uint256 expires, uint256 nonce, address user, uint8 v, bytes32 r, bytes32 s);
  event Trade(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, address get, address give, bytes32 hash);
  event Deposit(address token, address user, uint256 amount, uint256 balance);
  event Withdraw(address token, address user, uint256 amount, uint256 balance);

  function Exchange(address feeAccount_, address dvipAddress_) {
    feeAccount = feeAccount_;
    dvipAddress = dvipAddress_;
    feeMakeExporter = 0x00000000000000000000000000000000000000f7;
    feeTakeExporter = 0x00000000000000000000000000000000000000f8;
  }

  function setFeeAccount(address feeAccount_) onlyOwner {
    feeAccount = feeAccount_;
  }

  function setDVIP(address dvipAddress_) onlyOwner {
    dvipAddress = dvipAddress_;
  }

  function() {
    throw;
  }

  function deposit(address token, uint256 amount) payable {
    if (token == address(0)) {
      tokens[address(0)][msg.sender] = safeAdd(tokens[address(0)][msg.sender], msg.value);
    } else {
      if (msg.value != 0) throw;
      tokens[token][msg.sender] = safeAdd(tokens[token][msg.sender], amount);
      if (!Token(token).transferFrom(msg.sender, this, amount)) throw;
    }
    Deposit(token, msg.sender, amount, tokens[token][msg.sender]);
  }

  function withdraw(address token, uint256 amount) {
    if (tokens[token][msg.sender] < amount) throw;
    tokens[token][msg.sender] = safeSub(tokens[token][msg.sender], amount);
    if (token == address(0)) {
      if (!msg.sender.send(amount)) throw;
    } else {
      if (!Token(token).transfer(msg.sender, amount)) throw;
    }
    Withdraw(token, msg.sender, amount, tokens[token][msg.sender]);
  }

  function balanceOf(address token, address user) constant returns (uint256) {
    return tokens[token][user];
  }

  uint256 internal feeTake;
  uint256 internal feeMake;
  uint256 internal feeTerm;
  bytes32 internal tradeHash;

  function trade(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, uint256 expires, uint256 nonce, address user, uint8 v, bytes32 r, bytes32 s, uint256 amount) {
    //amount is in amountBuy terms
    tradeHash = sha3(this, tokenBuy, amountBuy, tokenSell, amountSell, expires, nonce, user);
    if (!(
      ecrecover(sha3("\x19Ethereum Signed Message:\n32", tradeHash),v,r,s) == user &&
      block.number <= expires &&
      safeAdd(orderFills[tradeHash], amount) <= amountBuy &&
      tokens[tokenBuy][msg.sender] >= amount &&
      tokens[tokenSell][user] >= safeMul(amountSell, amount) / amountBuy
    )) throw;
    feeMake = DVIP(dvipAddress).feeFor(feeMakeExporter, msg.sender, 1 ether);
    feeTake = DVIP(dvipAddress).feeFor(feeTakeExporter, user, 1 ether);
    tokens[tokenBuy][msg.sender] = safeSub(tokens[tokenBuy][msg.sender], amount);
    feeTerm = safeMul(amount, ((1 ether) - feeMake)) / (1 ether);
    tokens[tokenBuy][user] = safeAdd(tokens[tokenBuy][user], feeTerm);
    feeTerm = safeMul(amount, feeMake) / (1 ether);
    tokens[tokenBuy][feeAccount] = safeAdd(tokens[tokenBuy][feeAccount], feeTerm);
    feeTerm = safeMul(amountSell, amount) / amountBuy;
    tokens[tokenSell][user] = safeSub(tokens[tokenSell][user], feeTerm);
    feeTerm = safeMul(safeMul(((1 ether) - feeTake), amountSell), amount) / amountBuy / (1 ether);
    tokens[tokenSell][msg.sender] = safeAdd(tokens[tokenSell][msg.sender], feeTerm);
    feeTerm = safeMul(safeMul(feeTake, amountSell), amount) / amountBuy / (1 ether);
    tokens[tokenSell][feeAccount] = safeAdd(tokens[tokenSell][feeAccount], feeTerm);
    orderFills[tradeHash] = safeAdd(orderFills[tradeHash], amount);
    Trade(tokenBuy, amount, tokenSell, amountSell * amount / amountBuy, user, msg.sender, tradeHash);
  }

  bytes32 internal testHash;
  uint256 internal amountSelln;

  function testTrade(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, uint256 expires, uint256 nonce, address user, uint8 v, bytes32 r, bytes32 s, uint256 amount, address sender) constant returns (uint8 code) {
    testHash = sha3(this, tokenBuy, amountBuy, tokenSell, amountSell, expires, nonce, user);
    if (tokens[tokenBuy][sender] < amount) return 1;
    if (ecrecover(sha3("\x19Ethereum Signed Message:\n32", testHash), v, r, s) != user) return 4;
    amountSelln = safeMul(amountSell, amount) / amountBuy;
    if (tokens[tokenSell][user] < amountSelln) return 5;
    if (block.number > expires) return 6;
    if (safeAdd(orderFills[testHash], amount) > amountBuy) return 7;
    return 0;
  }
  function cancelOrder(address tokenBuy, uint256 amountBuy, address tokenSell, uint256 amountSell, uint256 expires, uint256 nonce, uint8 v, bytes32 r, bytes32 s, address user) {
    bytes32 hash = sha3(this, tokenBuy, amountBuy, tokenSell, amountSell, expires, nonce, user);
    if (ecrecover(sha3("\x19Ethereum Signed Message:\n32", hash),v,r,s) != msg.sender) throw;
    orderFills[hash] = amountBuy;
    Cancel(tokenBuy, amountBuy, tokenSell, amountSell, expires, nonce, msg.sender, v, r, s);
  }
}