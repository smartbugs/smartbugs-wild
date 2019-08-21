// Wallet contract that operates only in "right" branch.
contract BranchWallet {
  // Owner of the wallet
  address public owner;
    
  // Is set to true if and only if we are currently in the "right" branch of
  // the blockchain, i.e. the branch this wallet is operating in.
  bool public isRightBranch;

  // Instantiate the contract.
  //
  // @param owner owner of the contract
  // @isRightBranch whether we are currently in the "right" branch
  function BranchWallet (address _owner, bool _isRightBranch) {
    owner = _owner;
    isRightBranch = _isRightBranch;
  }

  // Only accept money in "right" branch.
  function () {
    if (!isRightBranch) throw;
  }

  // Execute a transaction using money from this wallet.
  //
  // @param to transaction destination
  // @param value transaction value
  // @param data transaction data
  function send (address _to, uint _value) {
    if (!isRightBranch) throw;
    if (msg.sender != owner) throw;
    if (!_to.send (_value)) throw;
  }

  // Execute a transaction using money from this wallet.
  //
  // @param to transaction destination
  // @param value transaction value
  // @param data transaction data
  function execute (address _to, uint _value, bytes _data) {
    if (!isRightBranch) throw;
    if (msg.sender != owner) throw;
    if (!_to.call.value (_value)(_data)) throw;
  }
}

// Simple smart contract that allows anyone to tell where we are currently in the
// "right" branch of blockchain.
contract BranchSender {
  // Is set to true if and only if we are currently in the "right" branch of
  // the blockchain.
  bool public isRightBranch;
}