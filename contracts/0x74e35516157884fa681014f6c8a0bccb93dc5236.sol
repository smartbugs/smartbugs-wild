pragma solidity ^0.4.23;

contract ODXVerifyAddress {

  event VerifyAddress(address indexed ethAddr, string indexed code);
  
  function verifyAddress(string memory code) public {
    bytes memory mCode = bytes(code);
    require (mCode.length>0);
    emit VerifyAddress(msg.sender, code);
  }
  
}