pragma solidity ^0.4.8;

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
    /// @param newOwner Address of new owner.
    /// @param index the indx of the owner to be replaced
    function replaceOwnerIndexed(address owner, address newOwner, uint index)
        public
        onlyWallet
        ownerExists(owner)
        ownerDoesNotExist(newOwner)
    {
        if (owners[index] != owner) throw;
        owners[index] = newOwner;
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



contract NewToken is ERC20 {}

contract UpgradeAgent is SafeMath {
  address public owner;
  bool public isUpgradeAgent;
  NewToken public newToken;
  uint256 public originalSupply; // the original total supply of old tokens
  bool public upgradeHasBegun;
  function upgradeFrom(address _from, uint256 _value) public;
}

/// @title Time-locked vault of tokens allocated to Lunyr after 180 days
contract LUNVault is SafeMath {

    // flag to determine if address is for a real contract or not
    bool public isLUNVault = false;

    LunyrToken lunyrToken;
    address lunyrMultisig;
    uint256 unlockedAtBlockNumber;
    //uint256 public constant numBlocksLocked = 1110857;
    // smaller lock for testing
    uint256 public constant numBlocksLocked = 1110857;

    /// @notice Constructor function sets the Lunyr Multisig address and
    /// total number of locked tokens to transfer
    function LUNVault(address _lunyrMultisig) internal {
        if (_lunyrMultisig == 0x0) throw;
        lunyrToken = LunyrToken(msg.sender);
        lunyrMultisig = _lunyrMultisig;
        isLUNVault = true;
        unlockedAtBlockNumber = safeAdd(block.number, numBlocksLocked); // 180 days of blocks later
    }

    /// @notice Transfer locked tokens to Lunyr's multisig wallet
    function unlock() external {
        // Wait your turn!
        if (block.number < unlockedAtBlockNumber) throw;
        // Will fail if allocation (and therefore toTransfer) is 0.
        if (!lunyrToken.transfer(lunyrMultisig, lunyrToken.balanceOf(this))) throw;
    }

    // disallow payment this is for LUN not ether
    function () { throw; }

}

/// @title Lunyr crowdsale contract
contract LunyrToken is SafeMath, ERC20 {

    // flag to determine if address is for a real contract or not
    bool public isLunyrToken = false;

    // State machine
    enum State{PreFunding, Funding, Success, Failure}

    // Token information
    string public constant name = "Lunyr Token";
    string public constant symbol = "LUN";
    uint256 public constant decimals = 18;  // decimal places
    uint256 public constant crowdfundPercentOfTotal = 78;
    uint256 public constant vaultPercentOfTotal = 15;
    uint256 public constant lunyrPercentOfTotal = 7;
    uint256 public constant hundredPercent = 100;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    // Upgrade information
    address public upgradeMaster;
    UpgradeAgent public upgradeAgent;
    uint256 public totalUpgraded;

    // Crowdsale information
    bool public finalizedCrowdfunding = false;
    uint256 public fundingStartBlock; // crowdsale start block
    uint256 public fundingEndBlock; // crowdsale end block
    uint256 public constant tokensPerEther = 44; // LUN:ETH exchange rate
    uint256 public constant tokenCreationMax = safeMul(250000 ether, tokensPerEther);
    uint256 public constant tokenCreationMin = safeMul(25000 ether, tokensPerEther);
    // for testing on testnet
    //uint256 public constant tokenCreationMax = safeMul(10 ether, tokensPerEther);
    //uint256 public constant tokenCreationMin = safeMul(3 ether, tokensPerEther);

    address public lunyrMultisig;
    LUNVault public timeVault; // Lunyr's time-locked vault

    event Upgrade(address indexed _from, address indexed _to, uint256 _value);
    event Refund(address indexed _from, uint256 _value);
    event UpgradeFinalized(address sender, address upgradeAgent);
    event UpgradeAgentSet(address agent);

    // For mainnet, startBlock = 3445888, endBlock = 3618688
    function LunyrToken(address _lunyrMultisig,
                        address _upgradeMaster,
                        uint256 _fundingStartBlock,
                        uint256 _fundingEndBlock) {

        if (_lunyrMultisig == 0) throw;
        if (_upgradeMaster == 0) throw;
        if (_fundingStartBlock <= block.number) throw;
        if (_fundingEndBlock   <= _fundingStartBlock) throw;
        isLunyrToken = true;
        upgradeMaster = _upgradeMaster;
        fundingStartBlock = _fundingStartBlock;
        fundingEndBlock = _fundingEndBlock;
        timeVault = new LUNVault(_lunyrMultisig);
        if (!timeVault.isLUNVault()) throw;
        lunyrMultisig = _lunyrMultisig;
        if (!MultiSigWallet(lunyrMultisig).isMultiSigWallet()) throw;
    }

    function balanceOf(address who) constant returns (uint) {
        return balances[who];
    }

    /// @notice Transfer `value` LUN tokens from sender's account
    /// `msg.sender` to provided account address `to`.
    /// @notice This function is disabled during the funding.
    /// @dev Required state: Success
    /// @param to The address of the recipient
    /// @param value The number of LUN to transfer
    /// @return Whether the transfer was successful or not
    function transfer(address to, uint256 value) returns (bool ok) {
        if (getState() != State.Success) throw; // Abort if crowdfunding was not a success.
        if (to == 0x0) throw;
        if (to == address(upgradeAgent)) throw;
        //if (to == address(upgradeAgent.newToken())) throw;
        uint256 senderBalance = balances[msg.sender];
        if (senderBalance >= value && value > 0) {
            senderBalance = safeSub(senderBalance, value);
            balances[msg.sender] = senderBalance;
            balances[to] = safeAdd(balances[to], value);
            Transfer(msg.sender, to, value);
            return true;
        }
        return false;
    }

    /// @notice Transfer `value` LUN tokens from sender 'from'
    /// to provided account address `to`.
    /// @notice This function is disabled during the funding.
    /// @dev Required state: Success
    /// @param from The address of the sender
    /// @param to The address of the recipient
    /// @param value The number of LUN to transfer
    /// @return Whether the transfer was successful or not
    function transferFrom(address from, address to, uint value) returns (bool ok) {
        if (getState() != State.Success) throw; // Abort if not in Success state.
        if (to == 0x0) throw;
        if (to == address(upgradeAgent)) throw;
        //if (to == address(upgradeAgent.newToken())) throw;
        if (balances[from] >= value &&
            allowed[from][msg.sender] >= value)
        {
            balances[to] = safeAdd(balances[to], value);
            balances[from] = safeSub(balances[from], value);
            allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], value);
            Transfer(from, to, value);
            return true;
        } else { return false; }
    }

    /// @notice `msg.sender` approves `spender` to spend `value` tokens
    /// @param spender The address of the account able to transfer the tokens
    /// @param value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address spender, uint256 value) returns (bool ok) {
        if (getState() != State.Success) throw; // Abort if not in Success state.
        allowed[msg.sender][spender] = value;
        Approval(msg.sender, spender, value);
        return true;
    }

    /// @param owner The address of the account owning tokens
    /// @param spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address owner, address spender) constant returns (uint) {
        return allowed[owner][spender];
    }

    // Token upgrade functionality

    /// @notice Upgrade tokens to the new token contract.
    /// @dev Required state: Success
    /// @param value The number of tokens to upgrade
    function upgrade(uint256 value) external {
        if (getState() != State.Success) throw; // Abort if not in Success state.
        if (upgradeAgent.owner() == 0x0) throw; // need a real upgradeAgent address

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
        if (address(upgradeAgent) != 0x0 && upgradeAgent.upgradeHasBegun()) throw; // Don't change the upgrade agent
        upgradeAgent = UpgradeAgent(agent);
        // upgradeAgent must be created and linked to LunyrToken after crowdfunding is over
        if (upgradeAgent.originalSupply() != totalSupply) throw;
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

    function setMultiSigWallet(address newWallet) external {
      if (msg.sender != lunyrMultisig) throw;
      MultiSigWallet wallet = MultiSigWallet(newWallet);
      if (!wallet.isMultiSigWallet()) throw;
      lunyrMultisig = newWallet;
    }

    // Crowdfunding:

    // don't just send ether to the contract expecting to get tokens
    function() { throw; }


    /// @notice Create tokens when funding is active.
    /// @dev Required state: Funding
    /// @dev State transition: -> Funding Success (only if cap reached)
    function create() payable external {
        // Abort if not in Funding Active state.
        // The checks are split (instead of using or operator) because it is
        // cheaper this way.
        if (getState() != State.Funding) throw;

        // Do not allow creating 0 or more than the cap tokens.
        if (msg.value == 0) throw;

        // multiply by exchange rate to get newly created token amount
        uint256 createdTokens = safeMul(msg.value, tokensPerEther);

        // we are creating tokens, so increase the totalSupply
        totalSupply = safeAdd(totalSupply, createdTokens);

        // don't go over the limit!
        if (totalSupply > tokenCreationMax) throw;

        // Assign new tokens to the sender
        balances[msg.sender] = safeAdd(balances[msg.sender], createdTokens);

        // Log token creation event
        Transfer(0, msg.sender, createdTokens);
    }

    /// @notice Finalize crowdfunding
    /// @dev If cap was reached or crowdfunding has ended then:
    /// create LUN for the Lunyr Multisig and developer,
    /// transfer ETH to the Lunyr Multisig address.
    /// @dev Required state: Success
    function finalizeCrowdfunding() external {
        // Abort if not in Funding Success state.
        if (getState() != State.Success) throw; // don't finalize unless we won
        if (finalizedCrowdfunding) throw; // can't finalize twice (so sneaky!)

        // prevent more creation of tokens
        finalizedCrowdfunding = true;

        // Endowment: 15% of total goes to vault, timelocked for 6 months
        // uint256 vaultTokens = safeDiv(safeMul(totalSupply, vaultPercentOfTotal), hundredPercent);
        uint256 vaultTokens = safeDiv(safeMul(totalSupply, vaultPercentOfTotal), crowdfundPercentOfTotal);
        balances[timeVault] = safeAdd(balances[timeVault], vaultTokens);
        Transfer(0, timeVault, vaultTokens);

        // Endowment: 7% of total goes to lunyr for marketing and bug bounty
        uint256 lunyrTokens = safeDiv(safeMul(totalSupply, lunyrPercentOfTotal), crowdfundPercentOfTotal);
        balances[lunyrMultisig] = safeAdd(balances[lunyrMultisig], lunyrTokens);
        Transfer(0, lunyrMultisig, lunyrTokens);

        totalSupply = safeAdd(safeAdd(totalSupply, vaultTokens), lunyrTokens);

        // Transfer ETH to the Lunyr Multisig address.
        if (!lunyrMultisig.send(this.balance)) throw;
    }

    /// @notice Get back the ether sent during the funding in case the funding
    /// has not reached the minimum level.
    /// @dev Required state: Failure
    function refund() external {
        // Abort if not in Funding Failure state.
        if (getState() != State.Failure) throw;

        uint256 lunValue = balances[msg.sender];
        if (lunValue == 0) throw;
        balances[msg.sender] = 0;
        totalSupply = safeSub(totalSupply, lunValue);

        uint256 ethValue = safeDiv(lunValue, tokensPerEther); // lunValue % tokensPerEther == 0
        Refund(msg.sender, ethValue);
        if (!msg.sender.send(ethValue)) throw;
    }

    /// @notice This manages the crowdfunding state machine
    /// We make it a function and do not assign the result to a variable
    /// So there is no chance of the variable being stale
    function getState() public constant returns (State){
      // once we reach success, lock in the state
      if (finalizedCrowdfunding) return State.Success;
      if (block.number < fundingStartBlock) return State.PreFunding;
      else if (block.number <= fundingEndBlock && totalSupply < tokenCreationMax) return State.Funding;
      else if (totalSupply >= tokenCreationMin) return State.Success;
      else return State.Failure;
    }
}