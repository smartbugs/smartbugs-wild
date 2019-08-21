contract ProofOfExistence {

  mapping (string => uint) private proofs;

  function notarize(string sha256) {

    bytes memory b_hash = bytes(sha256);
    
    if ( b_hash.length == 64 ){
      if ( proofs[sha256] == 0 ){
        proofs[sha256] = block.timestamp;
      }
    }
  }
  
  function verify(string sha256) constant returns (uint) {
    return proofs[sha256];
  }
  
}