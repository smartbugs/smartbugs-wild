pragma solidity ^0.4.11;

contract OriginalMyDocAuthenticity {
    
  mapping (string => uint) private authenticity;

  function storeAuthenticity(string sha256) {
    if (checkAuthenticity(sha256) == 0) {
        authenticity[sha256] = now;
    }   
  }

  function checkAuthenticity(string sha256) constant returns (uint) {
    return authenticity[sha256];
  }
}