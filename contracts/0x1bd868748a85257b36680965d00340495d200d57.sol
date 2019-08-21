pragma solidity 0.5.9;

/**
 * @title BatchAttestationLogic
 * @notice AttestationLogic allows users to submit the root hash of a batch
 *  attestation Merkle tree
 */
contract BatchAttestationLogic {
  event BatchTraitAttested(
    bytes32 rootHash
    );

  /**
   * @notice Function for anyone to submit the root hash of a batch attestation merkle tree
   * @param _dataHash Root hash of batch merkle tree
   */
  function batchAttest(
    bytes32 _dataHash
  ) external {
    emit BatchTraitAttested(_dataHash);
  }
}