contract SafeMath {
  function safeMul(uint a, uint b) internal constant returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal constant returns (uint) {
    require(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal constant returns (uint) {
    require(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal constant returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }
}

contract PreICO is SafeMath {
  mapping (address => uint) public balance;
  uint public tokensIssued;

  address public ethWallet;

  uint public startPreico; // block
  uint public endPreico; // timestamp

  // Tokens with decimals
  uint public limit;

  event e_Purchase(address who, uint amount);

  modifier onTime() {
    require(block.number >= startPreico && now <= endPreico);

    _;
  }

  function PreICO(uint start, uint end, uint tokens, address wallet) {
    startPreico = start;
    endPreico = end;
    limit = tokens;
    ethWallet = wallet;
  }

  function() payable {
    buy();
  }

  function buy() onTime payable {
    uint numTokens = safeDiv(safeMul(msg.value, getRate(msg.value)), 1 ether);
    assert(tokensIssued + numTokens <= limit);

    ethWallet.transfer(msg.value);
    balance[msg.sender] += numTokens;
    tokensIssued += numTokens;

    e_Purchase(msg.sender, numTokens);
  }

  function getRate(uint value) constant returns (uint rate) {
    if(value < 150 ether)
      revert();
    else if(value < 300 ether)
      rate = 5800*10**18;
    else if(value < 1500 ether)
      rate = 6000*10**18;
    else if(value < 3000 ether)
      rate = 6200*10**18;
    else if(value >= 3000 ether)
      rate = 6400*10**18;
  }
}