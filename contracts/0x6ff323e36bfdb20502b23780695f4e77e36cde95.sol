// Single-owner wallet that keeps ETC and ETH separately and helps preventing
// replaying both, incoming and outgoing transactions.
//
// Once instantiated, the contract sets up three addressed:
// 1. Address to be used to send and receive ETC.  This address will reject all
//    incoming ETH transfers, so its ETH balance will always be zero;
// 2. Address to be used to send and receive ETH.  This address will reject all
//    incoming ETC transfers, so its ETC balance will always be zero;
// 3. Address to be used to receive payments in both flavors of ether or even
//    unsplit replayable ETC+ETH payments.  Ether coming to this address will
//    be automatically classified and distributed among address 1 and address 2.
contract TriWallet {
  // Is set to true in the forked branch and to false in classic branch.
  bool public thisIsFork;

  // Address of ETC subwallet.
  address public etcWallet;

  // Address of ETH subwallet.
  address public ethWallet;

  // Log address of ETC subwallet
  event ETCWalletCreated(address etcWalletAddress);

  // Log address of ETH subwallet
  event ETHWalletCreated(address ethWalletAddress);

  // Instantiate the contract.
  function TriWallet () {
    // Check whether we are in fork branch or in classic one
    thisIsFork = BranchSender (0x23141df767233776f7cbbec497800ddedaa4c684).isRightBranch ();
    
    // Create ETC subwallet
    etcWallet = new BranchWallet (msg.sender, !thisIsFork);
    
    // Create ETH subwallet
    ethWallet = new BranchWallet (msg.sender, thisIsFork);
  
    // Log address of ETC subwallet
    ETCWalletCreated (etcWallet);

    // Log address of ETH subwallet
    ETHWalletCreated (ethWallet);
  }

  // Distribute pending balance between ETC and ETH subwallets.
  function distribute () {
    if (thisIsFork) {
      // Send all ETH to ETH subwallet
      if (!ethWallet.send (this.balance)) throw;
    } else {
      // Send all ETC to ETC subwallet
      if (!etcWallet.send (this.balance)) throw;
    }
  }
}

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