pragma solidity ^0.4.11;

// accepted from zeppelin-solidity https://github.com/OpenZeppelin/zeppelin-solidity
/*
 * ERC20 interface
 * see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);

  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

// accepted from zeppelin-solidity https://github.com/OpenZeppelin/zeppelin-solidity

/**
 * Math operations with safety checks
 */
contract SafeMath {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

  function assert(bool assertion) internal {
    if (!assertion) {
      throw;
    }
  }
}

/// @title Multisignature wallet - Allows multiple parties to agree on transactions before execution.
/// @author Stefan George - <stefan.george@consensys.net>
contract MultiSigWallet {

    // flag to determine if address is for a real contract or not
    bool public isMultiSigWallet = false;

    uint constant public MAX_OWNER_COUNT = 50;

    event Confirmation(address indexed sender, uint indexed transactionId);
    event Revocation(address indexed sender, uint indexed transactionId);
    event Submission(uint indexed transactionId);
    event Execution(uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);
    event Deposit(address indexed sender, uint value);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);
    event RequirementChange(uint required);

    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isOwner;
    address[] public owners;
    uint public required;
    uint public transactionCount;

    struct Transaction {
        address destination;
        uint value;
        bytes data;
        bool executed;
    }

    modifier onlyWallet() {
        if (msg.sender != address(this)) throw;
        _;
    }

    modifier ownerDoesNotExist(address owner) {
        if (isOwner[owner]) throw;
        _;
    }

    modifier ownerExists(address owner) {
        if (!isOwner[owner]) throw;
        _;
    }

    modifier transactionExists(uint transactionId) {
        if (transactions[transactionId].destination == 0) throw;
        _;
    }

    modifier confirmed(uint transactionId, address owner) {
        if (!confirmations[transactionId][owner]) throw;
        _;
    }

    modifier notConfirmed(uint transactionId, address owner) {
        if (confirmations[transactionId][owner]) throw;
        _;
    }

    modifier notExecuted(uint transactionId) {
        if (transactions[transactionId].executed) throw;
        _;
    }

    modifier notNull(address _address) {
        if (_address == 0) throw;
        _;
    }

    modifier validRequirement(uint ownerCount, uint _required) {
        if (ownerCount > MAX_OWNER_COUNT) throw;
        if (_required > ownerCount) throw;
        if (_required == 0) throw;
        if (ownerCount == 0) throw;
        _;
    }

    /// @dev Fallback function allows to deposit ether.
    function()
        payable
    {
        if (msg.value > 0)
            Deposit(msg.sender, msg.value);
    }

    /*
     * Public functions
     */
    /// @dev Contract constructor sets initial owners and required number of confirmations.
    /// @param _owners List of initial owners.
    /// @param _required Number of required confirmations.
    function MultiSigWallet(address[] _owners, uint _required)
        public
        validRequirement(_owners.length, _required)
    {
        for (uint i=0; i<_owners.length; i++) {
            if (isOwner[_owners[i]] || _owners[i] == 0) throw;
            isOwner[_owners[i]] = true;
        }
        isMultiSigWallet = true;
        owners = _owners;
        required = _required;
    }

    /// @dev Allows to add a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of new owner.
    function addOwner(address owner)
        public
        onlyWallet
        ownerDoesNotExist(owner)
        notNull(owner)
        validRequirement(owners.length + 1, required)
    {
        isOwner[owner] = true;
        owners.push(owner);
        OwnerAddition(owner);
    }

    /// @dev Allows to remove an owner. Transaction has to be sent by wallet.
    /// @param owner Address of owner.
    function removeOwner(address owner)
        public
        onlyWallet
        ownerExists(owner)
    {
        isOwner[owner] = false;
        for (uint i=0; i<owners.length - 1; i++)
            if (owners[i] == owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        owners.length -= 1;
        if (required > owners.length)
            changeRequirement(owners.length);
        OwnerRemoval(owner);
    }

    /// @dev Allows to replace an owner with a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of owner to be replaced.
    /// @param owner Address of new owner.
    function replaceOwner(address owner, address newOwner)
        public
        onlyWallet
        ownerExists(owner)
        ownerDoesNotExist(newOwner)
    {
        for (uint i=0; i<owners.length; i++)
            if (owners[i] == owner) {
                owners[i] = newOwner;
                break;
            }
        isOwner[owner] = false;
        isOwner[newOwner] = true;
        OwnerRemoval(owner);
        OwnerAddition(newOwner);
    }

    /// @dev Allows to change the number of required confirmations. Transaction has to be sent by wallet.
    /// @param _required Number of required confirmations.
    function changeRequirement(uint _required)
        public
        onlyWallet
        validRequirement(owners.length, _required)
    {
        required = _required;
        RequirementChange(_required);
    }

    /// @dev Allows an owner to submit and confirm a transaction.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @return Returns transaction ID.
    function submitTransaction(address destination, uint value, bytes data)
        public
        returns (uint transactionId)
    {
        transactionId = addTransaction(destination, value, data);
        confirmTransaction(transactionId);
    }

    /// @dev Allows an owner to confirm a transaction.
    /// @param transactionId Transaction ID.
    function confirmTransaction(uint transactionId)
        public
        ownerExists(msg.sender)
        transactionExists(transactionId)
        notConfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId][msg.sender] = true;
        Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    /// @dev Allows an owner to revoke a confirmation for a transaction.
    /// @param transactionId Transaction ID.
    function revokeConfirmation(uint transactionId)
        public
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {
        confirmations[transactionId][msg.sender] = false;
        Revocation(msg.sender, transactionId);
    }

    /// @dev Returns the confirmation status of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Confirmation status.
    function isConfirmed(uint transactionId)
        public
        constant
        returns (bool)
    {
        uint count = 0;
        for (uint i=0; i<owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
    }

    /*
     * Internal functions
     */

    /// @dev Allows anyone to execute a confirmed transaction.
    /// @param transactionId Transaction ID.
    function executeTransaction(uint transactionId)
       internal
       notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            Transaction tx = transactions[transactionId];
            tx.executed = true;
            if (tx.destination.call.value(tx.value)(tx.data))
                Execution(transactionId);
            else {
                ExecutionFailure(transactionId);
                tx.executed = false;
            }
        }
    }

    /// @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @return Returns transaction ID.
    function addTransaction(address destination, uint value, bytes data)
        internal
        notNull(destination)
        returns (uint transactionId)
    {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            executed: false
        });
        transactionCount += 1;
        Submission(transactionId);
    }

    /*
     * Web3 call functions
     */
    /// @dev Returns number of confirmations of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Number of confirmations.
    function getConfirmationCount(uint transactionId)
        public
        constant
        returns (uint count)
    {
        for (uint i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]])
                count += 1;
    }

    /// @dev Returns total number of transactions after filers are applied.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return Total number of transactions after filters are applied.
    function getTransactionCount(bool pending, bool executed)
        public
        constant
        returns (uint count)
    {
        for (uint i=0; i<transactionCount; i++)
            if ((pending && !transactions[i].executed) ||
                (executed && transactions[i].executed))
                count += 1;
    }

    /// @dev Returns list of owners.
    /// @return List of owner addresses.
    function getOwners()
        public
        constant
        returns (address[])
    {
        return owners;
    }

    /// @dev Returns array with owner addresses, which confirmed transaction.
    /// @param transactionId Transaction ID.
    /// @return Returns array of owner addresses.
    function getConfirmations(uint transactionId)
        public
        constant
        returns (address[] _confirmations)
    {
        address[] memory confirmationsTemp = new address[](owners.length);
        uint count = 0;
        uint i;
        for (i=0; i<owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i=0; i<count; i++)
            _confirmations[i] = confirmationsTemp[i];
    }

    /// @dev Returns list of transaction IDs in defined range.
    /// @param from Index start position of transaction array.
    /// @param to Index end position of transaction array.
    /// @param pending Include pending transactions.
    /// @param executed Include executed transactions.
    /// @return Returns array of transaction IDs.
    function getTransactionIds(uint from, uint to, bool pending, bool executed)
        public
        constant
        returns (uint[] _transactionIds)
    {
        uint[] memory transactionIdsTemp = new uint[](transactionCount);
        uint count = 0;
        uint i;
        for (i=0; i<transactionCount; i++)
          if ((pending && !transactions[i].executed) ||
              (executed && transactions[i].executed))
            {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        _transactionIds = new uint[](to - from);
        for (i=from; i<to; i++)
            _transactionIds[i - from] = transactionIdsTemp[i];
    }
}

contract UpgradeAgent is SafeMath {
  address public owner;
  bool public isUpgradeAgent;
  function upgradeFrom(address _from, uint256 _value) public;
  function setOriginalSupply() public;
}

// @title BCDC Token vault, locked tokens for 1 month (Dev Team) and 1 year for Founders
contract BCDCVault is SafeMath {

    // flag to determine if address is for a real contract or not
    bool public isBCDCVault = false;

    BCDCToken bcdcToken;

    // address of our private MultiSigWallet contract
    address bcdcMultisig;
    // number of block unlock for developers
    uint256 public unlockedBlockForDev;
    // number of block unlock for founders
    uint256 public unlockedBlockForFounders;
    // It should be 1 * 30 days * 24 hours * 60 minutes * 60 seconds / 17
    // We can set small for testing purpose
    uint256 public numBlocksLockedDev;
    // It should be 12 months * 30 days * 24 hours * 60 minutes * 60 seconds / 17
    // We can set small for testing purpose
    uint256 public numBlocksLockedFounders;

    // flag to determine all the token for developers already unlocked or not
    bool public unlockedAllTokensForDev = false;
    // flag to determine all the token for founders already unlocked or not
    bool public unlockedAllTokensForFounders = false;

    // Constructor function sets the BCDC Multisig address and
    // total number of locked tokens to transfer
    function BCDCVault(address _bcdcMultisig,uint256 _numBlocksLockedForDev,uint256 _numBlocksLockedForFounders) {
        // If it's not bcdcMultisig address then throw
        if (_bcdcMultisig == 0x0) throw;
        // Initalized bcdcToken
        bcdcToken = BCDCToken(msg.sender);
        // Initalized bcdcMultisig address
        bcdcMultisig = _bcdcMultisig;
        // Mark it as BCDCVault
        isBCDCVault = true;
        //Initalized numBlocksLockedDev and numBlocksLockedFounders with block number
        numBlocksLockedDev = _numBlocksLockedForDev;
        numBlocksLockedFounders = _numBlocksLockedForFounders;
        // Initalized unlockedBlockForDev with block number
        // according to current block
        unlockedBlockForDev = safeAdd(block.number, numBlocksLockedDev); // 30 days of blocks later
        // Initalized unlockedBlockForFounders with block number
        // according to current block
        unlockedBlockForFounders = safeAdd(block.number, numBlocksLockedFounders); // 365 days of blocks later
    }

    // Transfer Development Team Tokens To MultiSigWallet - 30 Days Locked
    function unlockForDevelopment() external {
        // If it has not reached 30 days mark do not transfer
        if (block.number < unlockedBlockForDev) throw;
        // If it is already unlocked then do not allowed
        if (unlockedAllTokensForDev) throw;
        // Mark it as unlocked
        unlockedAllTokensForDev = true;
        // Will fail if allocation (and therefore toTransfer) is 0.
        uint256 totalBalance = bcdcToken.balanceOf(this);
        // transfer half of token to development team
        uint256 developmentTokens = safeDiv(safeMul(totalBalance, 50), 100);
        if (!bcdcToken.transfer(bcdcMultisig, developmentTokens)) throw;
    }

    //  Transfer Founders Team Tokens To MultiSigWallet - 365 Days Locked
    function unlockForFounders() external {
        // If it has not reached 365 days mark do not transfer
        if (block.number < unlockedBlockForFounders) throw;
        // If it is already unlocked then do not allowed
        if (unlockedAllTokensForFounders) throw;
        // Mark it as unlocked
        unlockedAllTokensForFounders = true;
        // Will fail if allocation (and therefore toTransfer) is 0.
        if (!bcdcToken.transfer(bcdcMultisig, bcdcToken.balanceOf(this))) throw;
        // So that ether will not be trapped here.
        if (!bcdcMultisig.send(this.balance)) throw;
    }

    // disallow payment after unlock block
    function () payable {
        if (block.number >= unlockedBlockForFounders) throw;
    }

}

// @title BCDC Token Contract with Token Sale Functionality as well
contract BCDCToken is SafeMath, ERC20 {

    // flag to determine if address is for a real contract or not
    bool public isBCDCToken = false;
    bool public upgradeAgentStatus = false;
    // Address of Owner for this Contract
    address public owner;

    // Define the current state of crowdsale
    enum State{PreFunding, Funding, Success, Failure}

    // Token related information
    string public constant name = "BCDC Token";
    string public constant symbol = "BCDC";
    uint256 public constant decimals = 18;  // decimal places

    // Mapping of token balance and allowed address for each address with transfer limit
    mapping (address => uint256) balances;
    // This is only for refund purpose, as we have price range during different weeks of Crowdfunding,
    //  need to maintain total investment done so refund would be exactly same.
    mapping (address => uint256) investment;
    mapping (address => mapping (address => uint256)) allowed;

    // Crowdsale information
    bool public finalizedCrowdfunding = false;
    // flag to determine is perallocation done or not
    bool public preallocated = false;
    uint256 public fundingStartBlock; // crowdsale start block
    uint256 public fundingEndBlock; // crowdsale end block
    // change price of token when current block reached

    // Maximum Token Sale (Crowdsale + Early Sale + Supporters)
    // Approximate 250 millions ITS + 125 millions for early investors + 75 Millions to Supports
    uint256 public tokenSaleMax;
    // Min tokens needs to be sold out for success
    // Approximate 1/4 of 250 millions
    uint256 public tokenSaleMin;
    //1 Billion BCDC Tokens
    uint256 public constant maxTokenSupply = 1000000000 ether;
    // Team token percentages to store in time vault
    uint256 public constant vaultPercentOfTotal = 5;
    // Project Reserved Fund Token %
    uint256 public constant reservedPercentTotal = 25;

    // Multisig Wallet Address
    address public bcdcMultisig;
    // Project Reserve Fund address
    address bcdcReserveFund;
    // BCDC's time-locked vault
    BCDCVault public timeVault;

    // Events for refund process
    event Refund(address indexed _from, uint256 _value);
    event Upgrade(address indexed _from, address indexed _to, uint256 _value);
    event UpgradeFinalized(address sender, address upgradeAgent);
    event UpgradeAgentSet(address agent);
    // BCDC:ETH exchange rate
    uint256 tokensPerEther;

    // @dev To Halt in Emergency Condition
    bool public halted;

    bool public finalizedUpgrade = false;
    address public upgradeMaster;
    UpgradeAgent public upgradeAgent;
    uint256 public totalUpgraded;


    // Constructor function sets following
    // @param bcdcMultisig address of bcdcMultisigWallet
    // @param fundingStartBlock block number at which funding will start
    // @param fundingEndBlock block number at which funding will end
    // @param tokenSaleMax maximum number of token to sale
    // @param tokenSaleMin minimum number of token to sale
    // @param tokensPerEther number of token to sale per ether
    function BCDCToken(address _bcdcMultiSig,
                      address _upgradeMaster,
                      uint256 _fundingStartBlock,
                      uint256 _fundingEndBlock,
                      uint256 _tokenSaleMax,
                      uint256 _tokenSaleMin,
                      uint256 _tokensPerEther,
                      uint256 _numBlocksLockedForDev,
                      uint256 _numBlocksLockedForFounders) {
        // Is not bcdcMultisig address correct then throw
        if (_bcdcMultiSig == 0) throw;
        // Is funding already started then throw
        if (_upgradeMaster == 0) throw;

        if (_fundingStartBlock <= block.number) throw;
        // If fundingEndBlock or fundingStartBlock value is not correct then throw
        if (_fundingEndBlock   <= _fundingStartBlock) throw;
        // If tokenSaleMax or tokenSaleMin value is not correct then throw
        if (_tokenSaleMax <= _tokenSaleMin) throw;
        // If tokensPerEther value is 0 then throw
        if (_tokensPerEther == 0) throw;
        // Mark it is BCDCToken
        isBCDCToken = true;
        // Initalized all param
        upgradeMaster = _upgradeMaster;
        fundingStartBlock = _fundingStartBlock;
        fundingEndBlock = _fundingEndBlock;
        tokenSaleMax = _tokenSaleMax;
        tokenSaleMin = _tokenSaleMin;
        tokensPerEther = _tokensPerEther;
        // Initalized timeVault as BCDCVault
        timeVault = new BCDCVault(_bcdcMultiSig,_numBlocksLockedForDev,_numBlocksLockedForFounders);
        // If timeVault is not BCDCVault then throw
        if (!timeVault.isBCDCVault()) throw;
        // Initalized bcdcMultisig address
        bcdcMultisig = _bcdcMultiSig;
        // Initalized owner
        owner = msg.sender;
        // MultiSigWallet is not bcdcMultisig then throw
        if (!MultiSigWallet(bcdcMultisig).isMultiSigWallet()) throw;
    }
    // Ownership related modifer and functions
    // @dev Throws if called by any account other than the owner
    modifier onlyOwner() {
      if (msg.sender != owner) {
        throw;
      }
      _;
    }

    // @dev Allows the current owner to transfer control of the contract to a newOwner.
    // @param newOwner The address to transfer ownership to.
    function transferOwnership(address newOwner) onlyOwner {
      if (newOwner != address(0)) {
        owner = newOwner;
      }
    }

    // @param _bcdcReserveFund Ether Address for Project Reserve Fund
    // This has to be called before preAllocation
    // Only to be called by Owner of this contract
    function setBcdcReserveFund(address _bcdcReserveFund) onlyOwner{
        if (getState() != State.PreFunding) throw;
        if (preallocated) throw; // Has to be done before preallocation
        if (_bcdcReserveFund == 0x0) throw;
        bcdcReserveFund = _bcdcReserveFund;
    }

    // @param who The address of the investor to check balance
    // @return balance tokens of investor address
    function balanceOf(address who) constant returns (uint) {
        return balances[who];
    }

    // @param who The address of the investor to check investment amount
    // @return total investment done by ethereum address
    // This method is only usable up to Crowdfunding ends (Success or Fail)
    // So if tokens are transfered post crowdsale investment will not change.
    function checkInvestment(address who) constant returns (uint) {
        return investment[who];
    }

    // @param owner The address of the account owning tokens
    // @param spender The address of the account able to transfer the tokens
    // @return Amount of remaining tokens allowed to spent
    function allowance(address owner, address spender) constant returns (uint) {
        return allowed[owner][spender];
    }

    //  Transfer `value` BCDC tokens from sender's account
    // `msg.sender` to provided account address `to`.
    // @dev Required state: Success
    // @param to The address of the recipient
    // @param value The number of BCDC tokens to transfer
    // @return Whether the transfer was successful or not
    function transfer(address to, uint value) returns (bool ok) {
        if (getState() != State.Success) throw; // Abort if crowdfunding was not a success.
        uint256 senderBalance = balances[msg.sender];
        if ( senderBalance >= value && value > 0) {
            senderBalance = safeSub(senderBalance, value);
            balances[msg.sender] = senderBalance;
            balances[to] = safeAdd(balances[to], value);
            Transfer(msg.sender, to, value);
            return true;
        }
        return false;
    }

    //  Transfer `value` BCDC tokens from sender 'from'
    // to provided account address `to`.
    // @dev Required state: Success
    // @param from The address of the sender
    // @param to The address of the recipient
    // @param value The number of BCDC to transfer
    // @return Whether the transfer was successful or not
    function transferFrom(address from, address to, uint value) returns (bool ok) {
        if (getState() != State.Success) throw; // Abort if crowdfunding was not a success.
        if (balances[from] >= value &&
            allowed[from][msg.sender] >= value &&
            value > 0)
        {
            balances[to] = safeAdd(balances[to], value);
            balances[from] = safeSub(balances[from], value);
            allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], value);
            Transfer(from, to, value);
            return true;
        } else { return false; }
    }

    //  `msg.sender` approves `spender` to spend `value` tokens
    // @param spender The address of the account able to transfer the tokens
    // @param value The amount of wei to be approved for transfer
    // @return Whether the approval was successful or not
    function approve(address spender, uint value) returns (bool ok) {
        if (getState() != State.Success) throw; // Abort if not in Success state.
        allowed[msg.sender][spender] = value;
        Approval(msg.sender, spender, value);
        return true;
    }

    // Sale of the tokens. Investors can call this method to invest into BCDC Tokens
    // Only when it's in funding mode. In case of emergecy it will be halted.
    function() payable stopIfHalted external {
        // Allow only to invest in funding state
        if (getState() != State.Funding) throw;

        // Sorry !! We do not allow to invest with 0 as value
        if (msg.value == 0) throw;

        // multiply by exchange rate to get newly created token amount
        uint256 createdTokens = safeMul(msg.value, tokensPerEther);

        // Wait we crossed maximum token sale goal. It's successful token sale !!
        if (safeAdd(createdTokens, totalSupply) > tokenSaleMax) throw;

        // Call to Internal function to assign tokens
        assignTokens(msg.sender, createdTokens);

        // Track the investment for each address till crowdsale ends
        investment[msg.sender] = safeAdd(investment[msg.sender], msg.value);
    }

    // To allocate tokens to Project Fund - eg. RecycleToCoin before Token Sale
    // Tokens allocated to these will not be count in totalSupply till the Token Sale Success and Finalized in finalizeCrowdfunding()
    function preAllocation() onlyOwner stopIfHalted external {
        // Allow only in Pre Funding Mode
        if (getState() != State.PreFunding) throw;
        // Check if BCDC Reserve Fund is set or not
        if (bcdcReserveFund == 0x0) throw;
        // To prevent multiple call by mistake
        if (preallocated) throw;
        preallocated = true;
        // 25% of overall Token Supply to project reseve fund
        uint256 projectTokens = safeDiv(safeMul(maxTokenSupply, reservedPercentTotal), 100);
        // At this time we will not add to totalSupply because these are not part of Sale
        // It will be added in totalSupply once the Token Sale is Finalized
        balances[bcdcReserveFund] = projectTokens;
        // Log the event
        Transfer(0, bcdcReserveFund, projectTokens);
    }

    // BCDC accepts Early Investment through manual process in Fiat Currency
    // BCDC Team will assign the tokens to investors manually through this function
    function earlyInvestment(address earlyInvestor, uint256 assignedTokens) onlyOwner stopIfHalted external {
        // Allow only in Pre Funding Mode And Funding Mode
        if (getState() != State.PreFunding && getState() != State.Funding) throw;
        // Check if earlyInvestor address is set or not
        if (earlyInvestor == 0x0) throw;
        // By mistake tokens mentioned as 0, save the cost of assigning tokens.
        if (assignedTokens == 0 ) throw;

        // Call to Internal function to assign tokens
        assignTokens(earlyInvestor, assignedTokens);

        // Track the investment for each address
        // Refund for this investor is taken care by out side the contract.because they are investing in their fiat currency
        //investment[earlyInvestor] = safeAdd(investment[earlyInvestor], etherValue);
    }

    // Function will transfer the tokens to investor's address
    // Common function code for Early Investor and Crowdsale Investor
    function assignTokens(address investor, uint256 tokens) internal {
        // Creating tokens and  increasing the totalSupply
        totalSupply = safeAdd(totalSupply, tokens);

        // Assign new tokens to the sender
        balances[investor] = safeAdd(balances[investor], tokens);

        // Finally token created for sender, log the creation event
        Transfer(0, investor, tokens);
    }

    // Finalize crowdfunding
    // Finally - Transfer the Ether to Multisig Wallet
    function finalizeCrowdfunding() stopIfHalted external {
        // Abort if not in Funding Success state.
        if (getState() != State.Success) throw; // don't finalize unless we won
        if (finalizedCrowdfunding) throw; // can't finalize twice (so sneaky!)

        // prevent more creation of tokens
        finalizedCrowdfunding = true;

        // Check if Unsold tokens out 450 millions
        // 250 Millions Sale + 125 Millions for Early Investors + 75 Millions for Supporters
        uint256 unsoldTokens = safeSub(tokenSaleMax, totalSupply);

        // Founders and Tech Team Tokens Goes to Vault, Locked for 1 month (Tech) and 1 year(Team)
        uint256 vaultTokens = safeDiv(safeMul(maxTokenSupply, vaultPercentOfTotal), 100);
        totalSupply = safeAdd(totalSupply, vaultTokens);
        balances[timeVault] = safeAdd(balances[timeVault], vaultTokens);
        Transfer(0, timeVault, vaultTokens);

        // Only transact if there are any unsold tokens
        if(unsoldTokens > 0) {
            totalSupply = safeAdd(totalSupply, unsoldTokens);
            // Remaining unsold tokens assign to multisig wallet
            balances[bcdcMultisig] = safeAdd(balances[bcdcMultisig], unsoldTokens);// Assign Reward Tokens to Multisig wallet
            Transfer(0, bcdcMultisig, unsoldTokens);
        }

        // Add pre allocated tokens to project reserve fund to totalSupply
        uint256 preallocatedTokens = safeDiv(safeMul(maxTokenSupply, reservedPercentTotal), 100);
        // project tokens already counted, so only add preallcated tokens
        totalSupply = safeAdd(totalSupply, preallocatedTokens);
        // 250 millions reward tokens to multisig (equal to reservefund prellocation).
        // Reward to token holders on their commitment with BCDC (25 % of 1 billion = 250 millions)
        uint256 rewardTokens = safeDiv(safeMul(maxTokenSupply, reservedPercentTotal), 100);
        balances[bcdcMultisig] = safeAdd(balances[bcdcMultisig], rewardTokens);// Assign Reward Tokens to Multisig wallet
        totalSupply = safeAdd(totalSupply, rewardTokens);

        // Total Supply Should not be greater than 1 Billion
        if (totalSupply > maxTokenSupply) throw;
        // Transfer ETH to the BCDC Multisig address.
        if (!bcdcMultisig.send(this.balance)) throw;
    }

    // Call this function to get the refund of investment done during Crowdsale
    // Refund can be done only when Min Goal has not reached and Crowdsale is over
    function refund() external {
        // Abort if not in Funding Failure state.
        if (getState() != State.Failure) throw;

        uint256 bcdcValue = balances[msg.sender];
        if (bcdcValue == 0) throw;
        balances[msg.sender] = 0;
        totalSupply = safeSub(totalSupply, bcdcValue);

        uint256 ethValue = investment[msg.sender];
        investment[msg.sender] = 0;
        Refund(msg.sender, ethValue);
        if (!msg.sender.send(ethValue)) throw;
    }

    // This will return the current state of Token Sale
    // Read only method so no transaction fees
    function getState() public constant returns (State){
      if (block.number < fundingStartBlock) return State.PreFunding;
      else if (block.number <= fundingEndBlock && totalSupply < tokenSaleMax) return State.Funding;
      else if (totalSupply >= tokenSaleMin || upgradeAgentStatus) return State.Success;
      else return State.Failure;
    }

    // Token upgrade functionality

    /// @notice Upgrade tokens to the new token contract.
    /// @dev Required state: Success
    /// @param value The number of tokens to upgrade
    function upgrade(uint256 value) external {
        if (!upgradeAgentStatus) throw;
        /*if (getState() != State.Success) throw; // Abort if not in Success state.*/
        if (upgradeAgent.owner() == 0x0) throw; // need a real upgradeAgent address
        if (finalizedUpgrade) throw; // cannot upgrade if finalized

        // Validate input value.
        if (value == 0) throw;
        if (value > balances[msg.sender]) throw;

        // update the balances here first before calling out (reentrancy)
        balances[msg.sender] = safeSub(balances[msg.sender], value);
        totalSupply = safeSub(totalSupply, value);
        totalUpgraded = safeAdd(totalUpgraded, value);
        upgradeAgent.upgradeFrom(msg.sender, value);
        Upgrade(msg.sender, upgradeAgent, value);
    }

    /// @notice Set address of upgrade target contract and enable upgrade
    /// process.
    /// @dev Required state: Success
    /// @param agent The address of the UpgradeAgent contract
    function setUpgradeAgent(address agent) external {
        if (getState() != State.Success) throw; // Abort if not in Success state.
        if (agent == 0x0) throw; // don't set agent to nothing
        if (msg.sender != upgradeMaster) throw; // Only a master can designate the next agent
        upgradeAgent = UpgradeAgent(agent);
        if (!upgradeAgent.isUpgradeAgent()) throw;
        // this needs to be called in success condition to guarantee the invariant is true
        upgradeAgentStatus = true;
        upgradeAgent.setOriginalSupply();
        UpgradeAgentSet(upgradeAgent);
    }

    /// @notice Set address of upgrade target contract and enable upgrade
    /// process.
    /// @dev Required state: Success
    /// @param master The address that will manage upgrades, not the upgradeAgent contract address
    function setUpgradeMaster(address master) external {
        if (getState() != State.Success) throw; // Abort if not in Success state.
        if (master == 0x0) throw;
        if (msg.sender != upgradeMaster) throw; // Only a master can designate the next master
        upgradeMaster = master;
    }

    // These modifier and functions related to halt the sale in case of emergency

    // @dev Use this as function modifier that should not execute if contract state Halted
    modifier stopIfHalted {
      if(halted) throw;
      _;
    }

    // @dev Use this as function modifier that should execute only if contract state Halted
    modifier runIfHalted{
      if(!halted) throw;
      _;
    }

    // @dev called by only owner in case of any emergecy situation
    function halt() external onlyOwner{
      halted = true;
    }

    // @dev called by only owner to stop the emergency situation
    function unhalt() external onlyOwner{
      halted = false;
    }

    // This method is only use for transfer bcdctoken from bcdcReserveFund
    // @dev Required state: is bcdcReserveFund set
    // @param to The address of the recipient
    // @param value The number of BCDC tokens to transfer
    // @return Whether the transfer was successful or not
    function reserveTokenClaim(address claimAddress,uint256 token) onlyBcdcReserve returns (bool ok){
      // Check if BCDC Reserve Fund is set or not
      if ( bcdcReserveFund == 0x0) throw;
      uint256 senderBalance = balances[msg.sender];
      if(senderBalance >= token && token>0){
        senderBalance = safeSub(senderBalance, token);
        balances[msg.sender] = senderBalance;
        balances[claimAddress] = safeAdd(balances[claimAddress], token);
        Transfer(msg.sender, claimAddress, token);
        return true;
      }
      return false;
    }

    // This method is for getting bcdctoken as rewards
	  // @param tokens The number of tokens back for rewards
  	function backTokenForRewards(uint256 tokens) external{
  		// Check that token available for transfer
  		if(balances[msg.sender] < tokens && tokens <= 0) throw;

  		// Debit tokens from msg.sender
  		balances[msg.sender] = safeSub(balances[msg.sender], tokens);

  		// Credit tokens into bcdcReserveFund
  		balances[bcdcReserveFund] = safeAdd(balances[bcdcReserveFund], tokens);
  		Transfer(msg.sender, bcdcReserveFund, tokens);
  	}

    // bcdcReserveFund related modifer and functions
    // @dev Throws if called by any account other than the bcdcReserveFund owner
    modifier onlyBcdcReserve() {
      if (msg.sender != bcdcReserveFund) {
        throw;
      }
      _;
    }
}