pragma solidity 0.4.24;
/**
* Token swapper contract for CLASSY tokens
*/

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }
}

interface Token {

  function balanceOf(address _owner) external constant returns (uint256 balance);
  function transfer(address _to, uint256 _value) external returns (bool success);
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
  function approve(address _spender, uint256 _value) external returns (bool success);
  function allowance(address _owner, address _spender) external constant returns (uint256 remaining);
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}

interface ANYtoken {
  function balanceOf(address _owner) external constant returns (uint256 balance);
  function transfer(address _to, uint256 _value) external;
}

contract Swap {

  using SafeMath for uint;

  Token public tokenA;
  Token public tokenB;

  address public admin;

  constructor() public {

    tokenA = Token(0x30CC0e266cF33B8eaC6A99cBD98E39b890cfD69b);
    tokenB = Token(0x8Cc3B3E4F62070afb2f0Dfece7228376626c1b0C);
    admin = 0x71bAe8D36266F6a2115aa7E18A395e4676528100;

  }

  function changeAdmin(address newAdmin) public returns (bool){

    require(msg.sender == admin, "You are not allowed to do this");

    admin = newAdmin;

    return true;

  }

  function receiveApproval(address sender, uint value, address cont, bytes data) public returns (bool) {

    require(cont == address(tokenA),"This is not the expected caller");

    require(tokenA.transferFrom(sender,address(this),value),"An error ocurred whe getting the old tokens");

    uint toTransfer = value.mul(1e2); //Decimals correction
    require(tokenB.transfer(sender,toTransfer), "Not enough tokens on contract to swap");

    return true;

  }

  function tokenRecovery(address token) public returns (bool) {

    require(msg.sender == admin, "You are not allowed to do this");

    ANYtoken toGet = ANYtoken(token);

    uint balance = toGet.balanceOf(address(this));

    toGet.transfer(msg.sender,balance);

    return true;

  }

}