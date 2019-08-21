pragma solidity ^0.4.18;

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

contract ERC20Interface {
    function balanceOf(address _owner) public constant returns (uint balance) {}
    function transfer(address _to, uint _value) public returns (bool success) {}
    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {}
}

contract Exchanger {
    using SafeMath for uint;
  // Decimals 18
  ERC20Interface dai = ERC20Interface(0x89d24a6b4ccb1b6faa2625fe562bdd9a23260359);
  // Decimals 6
  ERC20Interface usdt = ERC20Interface(0xdac17f958d2ee523a2206206994597c13d831ec7);

  address creator = 0x34f1e87e890b5683ef7b011b16055113c7194c35;
  uint feeDAI = 5000000000000000;
  uint feeUSDT = 5000;

  function getDAI(uint _amountInDollars) public returns (bool) {
    // Must first call approve for the usdt contract
    usdt.transferFrom(msg.sender, this, _amountInDollars * (10 ** 6));
    dai.transfer(msg.sender, _amountInDollars.mul(((10 ** 18) - feeDAI)));
    return true;
  }

  function getUSDT(uint _amountInDollars) public returns (bool) {
    // Must first call approve for the dai contract
    dai.transferFrom(msg.sender, this, _amountInDollars * (10 ** 18));
    usdt.transfer(msg.sender, _amountInDollars.mul(((10 ** 6) - feeUSDT)));
    return true;
  }

  function withdrawEquity(uint _amountInDollars, bool isUSDT) public returns (bool) {
    require(msg.sender == creator);
    if(isUSDT) {
      usdt.transfer(creator, _amountInDollars * (10 ** 6));
    } else {
      dai.transfer(creator, _amountInDollars * (10 ** 18));
    }
    return true;
  }
}