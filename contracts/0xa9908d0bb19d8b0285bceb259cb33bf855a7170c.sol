pragma solidity ^0.4.25;

/**
* I'am advertisement contract , DO NOT send any ether here
* 
* EtherGlod Site: https://etherGold.me
* 
* EtherGlod Contract:0x4a9a5083135d0c80cce8e0f424336567e616ef64
* 
-------------------------------------------------------------------------------
 * What's is EtherGold
 *  - 1% advertisement and PR expenses FEE
 *  - You can refund anytime
 *  - GAIN 2% ~ 3% (up on your deposited value) PER 24 HOURS (every 5900 blocks)
 *  - 0 ~ 1 ether     2% 
 *  - 1 ~ 10 ether    2.5%
 *  - over 10 ether   3% 
 * 
 * Multi-level Referral Bonus
 *  - 5% for Direct 
 *  - 3% for Second Level
 *  - 1% for Third Level
 * 
 * How to use:
 *  1. Send any amount of ether to make an investment
 *  2a. Claim your profit by sending 0 ether transaction (every day, every week, i don't care unless you're spending too much on GAS)
 *  OR
 *  2b. Send more ether to reinvest AND get your profit at the same time
 *  OR
 *  2c. view on website: https://EtherGold.Me
 * 
 * How to refund:
 *  - Send 0.002 ether to refund
 *  - 1% refund fee
 *  - refundValue = (depositedValue - withdrewValue - refundFee) * 99%
 *  
 *
 * RECOMMENDED GAS LIMIT: 70000
 * RECOMMENDED GAS PRICE: https://ethgasstation.info/
 *
 * Contract reviewed and approved by pros! 
* 
**/
contract ERC20AdToken {
    using SafeMath for uint;
    using Zero for *;

    string public symbol;
    string public  name;
    uint8 public decimals = 0;
    uint256 public totalSupply;
    
    mapping (address => uint256) public balanceOf;
    mapping(address => address) public adtransfers;
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    
    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor(string _symbol, string _name) public {
        symbol = _symbol;
        name = _name;
        balanceOf[this] = 10000000000;
        totalSupply = 10000000000;
        emit Transfer(address(0), this, 10000000000);
    }

    function transfer(address to, uint tokens) public returns (bool success) {
        //This method do not send anything. It is only notify blockchain that Advertise Token Transfered
        //You can call this method for advertise this contract and invite new investors and gain 1% from each first investments.
        if(!adtransfers[to].notZero()){
            adtransfers[to] = msg.sender;
            emit Transfer(this, to, tokens);
        }
        return true;
    }
    
    function massAdvertiseTransfer(address[] addresses, uint tokens) public returns (bool success) {
        for (uint i = 0; i < addresses.length; i++) {
            if(!adtransfers[addresses[i]].notZero()){
                adtransfers[addresses[i]] = msg.sender;
                emit Transfer(this, addresses[i], tokens);
            }
        }
        
        return true;
    }

    function () public payable {
        revert();
    }

}


library SafeMath {
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return c;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

library Percent {
  // Solidity automatically throws when dividing by 0
  struct percent {
    uint num;
    uint den;
  }
  function mul(percent storage p, uint a) internal view returns (uint) {
    if (a == 0) {
      return 0;
    }
    return a*p.num/p.den;
  }

  function div(percent storage p, uint a) internal view returns (uint) {
    return a/p.num*p.den;
  }

  function sub(percent storage p, uint a) internal view returns (uint) {
    uint b = mul(p, a);
    if (b >= a) return 0;
    return a - b;
  }

  function add(percent storage p, uint a) internal view returns (uint) {
    return a + mul(p, a);
  }
}

library Zero {
  function requireNotZero(uint a) internal pure {
    require(a != 0, "require not zero");
  }

  function requireNotZero(address addr) internal pure {
    require(addr != address(0), "require not zero address");
  }

  function notZero(address addr) internal pure returns(bool) {
    return !(addr == address(0));
  }

  function isZero(address addr) internal pure returns(bool) {
    return addr == address(0);
  }
}

library ToAddress {
  function toAddr(uint source) internal pure returns(address) {
    return address(source);
  }

  function toAddr(bytes source) internal pure returns(address addr) {
    assembly { addr := mload(add(source,0x14)) }
    return addr;
  }
}