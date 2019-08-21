// Simple smart contract that allows anyone to send ether from one address to
// another in certain branch of the blockchain only.  This contract is supposed
// to be used after hard forks to clearly separate "classic" ether from "new"
// ether.
contract BranchSender {
  // Is set to true if and only if we are currently in the "right" branch of
  // the blockchain, i.e. the branch this contract allows sending money in.
  bool public isRightBranch;

  // Instantiate the contract.
  //
  // @param blockNumber number of block in the "right" blockchain whose hash is
  //        known
  // @param blockHash known hash of the given block in the "right" blockchain
  function BranchSender(uint blockNumber, bytes32 blockHash) {
    if (msg.value > 0) throw; // We do not accept any money here

    isRightBranch = (block.number < 256 || blockNumber > block.number - 256) &&
                    (blockNumber < block.number) &&
                    (block.blockhash (blockNumber) == blockHash);
  }

  // Default function just throw.
  function () {
    throw;
  }

  // If we are currently in the "right" branch of the blockchain, send money to
  // the given recipient.  Otherwise, throw.
  //
  // @param recipient address to send money to if we are currently in the
  //                  "right" branch of the blockchain
  function send (address recipient) {
    if (!isRightBranch) throw;
    if (!recipient.send (msg.value)) throw;
  }
}