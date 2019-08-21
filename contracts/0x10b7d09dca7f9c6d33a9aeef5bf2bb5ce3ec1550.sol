//
// compiler: solcjs -o ./build/contracts --optimize --abi --bin <this file>
//  version: 0.4.15+commit.bbb8e64f.Emscripten.clang
//
pragma solidity ^0.4.15;

contract owned {
  address public owner;

  function owned() { owner = msg.sender; }

  modifier onlyOwner {
    if (msg.sender != owner) { revert(); }
    _;
  }

  function changeOwner( address newowner ) onlyOwner {
    owner = newowner;
  }

  function closedown() onlyOwner {
    selfdestruct( owner );
  }
}

// "extern" declare functions from token contract
interface JBX {
  function transfer(address to, uint256 value);
  function balanceOf( address owner ) constant returns (uint);
}

contract JBXICO is owned {

  uint public constant STARTTIME = 1510099200; // 08 NOV 2017 00:00 GMT
  uint public constant ENDTIME = 1512691200;   // 08 DEC 2017 00:00 GMT
  uint public constant JBXPERETH = 1500;       // price: approx $0.20 ea

  JBX public tokenSC;

  function JBXICO() {}

  function setToken( address tok ) onlyOwner {
    if ( tokenSC == address(0) )
      tokenSC = JBX(tok);
  }

  function() payable {
    if (now < STARTTIME || now > ENDTIME)
      revert();

    // (amountinwei/weipereth * jbx/eth) * ( (100 + bonuspercent)/100 )
    // = amountinwei*jbxpereth/weipereth*(bonus+100)/100
    uint qty =
      div(mul(div(mul(msg.value, JBXPERETH),1000000000000000000),(bonus()+100)),100);

    if (qty > tokenSC.balanceOf(address(this)) || qty < 1)
      revert();

    tokenSC.transfer( msg.sender, qty );
  }

  // unsold tokens can be claimed by owner after sale ends
  function claimUnsold() onlyOwner {
    if ( now < ENDTIME )
      revert();

    tokenSC.transfer( owner, tokenSC.balanceOf(address(this)) );
  }

  function withdraw( uint amount ) onlyOwner returns (bool) {
    if (amount <= this.balance)
      return owner.send( amount );

    return false;
  }

  function bonus() constant returns(uint) {
    uint elapsed = now - STARTTIME;

    if (elapsed < 48 hours) return 50;
    if (elapsed < 2 weeks) return 20;
    if (elapsed < 3 weeks) return 10;
    if (elapsed < 4 weeks) return 5;
    return 0;
  }

  // ref:
  // github.com/OpenZeppelin/zeppelin-solidity/
  // blob/master/contracts/math/SafeMath.sol
  function mul(uint256 a, uint256 b) constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) constant returns (uint256) {
    uint256 c = a / b;
    return c;
  }
}