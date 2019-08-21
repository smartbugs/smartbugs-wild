pragma solidity ^0.4.24;

contract FUTC {
  function claimEth() public;
  function claimToken(address _tokenAddr, address _payee) public;
}
contract ERC20 {
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
}

contract FUTCHelper {
  address public constant FUTC1 = 0xf880d3C6DCDA42A7b2F6640703C5748557865B35;
  FUTC futc = FUTC(address(0xdaa6CD28E6aA9d656930cE4BB4FA93eEC96ee791));
  constructor() public {}
  function () public payable {}
  function transferEth() public {
    futc.claimEth();
    address(FUTC1).transfer(address(this).balance);
  }
  function transferToken(address _token) public {
    futc.claimToken(_token, address(this));
    uint amt = ERC20(_token).balanceOf(address(this));
    if (amt > 0) {
      ERC20(_token).transfer(FUTC1, amt);
    }
  }
}