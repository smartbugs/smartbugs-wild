pragma solidity ^0.5.8;
contract ProofOfExistence {
    event Attestation(bytes32 indexed hash);
    function attest(bytes32 hash) public {
        emit Attestation(hash);
    }
}