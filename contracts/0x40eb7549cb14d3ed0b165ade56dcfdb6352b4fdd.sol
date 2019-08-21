pragma solidity ^0.4.11;
contract Ownable {
  address public owner;
  function Ownable() {
    owner = 0x587c04e40346171dE18341fc9027395c3FdA83ab;
  }
  modifier onlyOwner() {
    if (msg.sender != owner) {
      throw;
    }
    _;
  }
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}
contract Token{
  function transfer(address to, uint value) returns (bool);
}
contract SendLove is Ownable {
    function multisend(address _tokenAddr, address[] _to, uint256[] _value)
    returns (bool _success) {
        assert(_to.length == _value.length);
        assert(_to.length <= 150);
        // loop through to addresses and send value
        for (uint8 i = 0; i < _to.length; i++) {
                assert((Token(_tokenAddr).transfer(_to[i], _value[i])) == true);
            }
            return true;
        }
}