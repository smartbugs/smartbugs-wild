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
        assert(c >= a && c >= b);
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

contract OldToken is ERC20 {
    // flag to determine if address is for a real contract or not
    bool public isDecentBetToken;

    address public decentBetMultisig;
}

contract NextUpgradeAgent is SafeMath {
    address public owner;

    bool public isUpgradeAgent;

    function upgradeFrom(address _from, uint256 _value) public;

    function finalizeUpgrade() public;

    function setOriginalSupply() public;
}

/// @title Time-locked vault of tokens allocated to DecentBet after 365 days
contract NewDecentBetVault is SafeMath {

    // flag to determine if address is for a real contract or not
    bool public isDecentBetVault = false;

    NewDecentBetToken decentBetToken;

    address decentBetMultisig;

    uint256 unlockedAtTime;

    // 1 year lockup
    uint256 public constant timeOffset = 47 weeks;

    /// @notice Constructor function sets the DecentBet Multisig address and
    /// total number of locked tokens to transfer
    function NewDecentBetVault(address _decentBetMultisig) /** internal */ {
        if (_decentBetMultisig == 0x0) revert();
        decentBetToken = NewDecentBetToken(msg.sender);
        decentBetMultisig = _decentBetMultisig;
        isDecentBetVault = true;

        // 1 year later
        unlockedAtTime = safeAdd(getTime(), timeOffset);
    }

    /// @notice Transfer locked tokens to Decent.bet's multisig wallet
    function unlock() external {
        // Wait your turn!
        if (getTime() < unlockedAtTime) revert();
        // Will fail if allocation (and therefore toTransfer) is 0.
        if (!decentBetToken.transfer(decentBetMultisig, decentBetToken.balanceOf(this))) revert();
    }

    function getTime() internal returns (uint256) {
        return now;
    }

    // disallow ETH payments to TimeVault
    function() payable {
        revert();
    }

}

contract NewDecentBetToken is ERC20, SafeMath {

    // Token information
    bool public isDecentBetToken;

    string public constant name = "Decent.Bet Token";

    string public constant symbol = "DBET";

    uint256 public constant decimals = 18;  // decimal places

    uint256 public constant housePercentOfTotal = 10;

    uint256 public constant vaultPercentOfTotal = 18;

    uint256 public constant bountyPercentOfTotal = 2;

    uint256 public constant crowdfundPercentOfTotal = 70;

    // flag to determine if address is for a real contract or not
    bool public isNewToken = false;

    // Token information
    mapping (address => uint256) balances;

    mapping (address => mapping (address => uint256)) allowed;

    // Upgrade information
    NewUpgradeAgent public upgradeAgent;

    NextUpgradeAgent public nextUpgradeAgent;

    bool public finalizedNextUpgrade = false;

    address public nextUpgradeMaster;

    event Upgrade(address indexed _from, address indexed _to, uint256 _value);

    event UpgradeFinalized(address sender, address nextUpgradeAgent);

    event UpgradeAgentSet(address agent);

    uint256 public totalUpgraded;

    // Old Token Information
    OldToken public oldToken;

    address public decentBetMultisig;

    uint256 public oldTokenTotalSupply;

    NewDecentBetVault public timeVault;

    function NewDecentBetToken(address _upgradeAgent,
    address _oldToken, address _nextUpgradeMaster) public {

        isNewToken = true;

        isDecentBetToken = true;

        if (_upgradeAgent == 0x0) revert();
        upgradeAgent = NewUpgradeAgent(_upgradeAgent);

        if (_nextUpgradeMaster == 0x0) revert();
        nextUpgradeMaster = _nextUpgradeMaster;

        oldToken = OldToken(_oldToken);
        if (!oldToken.isDecentBetToken()) revert();
        oldTokenTotalSupply = oldToken.totalSupply();

        decentBetMultisig = oldToken.decentBetMultisig();
        if (!MultiSigWallet(decentBetMultisig).isMultiSigWallet()) revert();

        timeVault = new NewDecentBetVault(decentBetMultisig);
        if (!timeVault.isDecentBetVault()) revert();

        // Founder's supply : 18% of total goes to vault, time locked for 1 year
        uint256 vaultTokens = safeDiv(safeMul(oldTokenTotalSupply, vaultPercentOfTotal),
        crowdfundPercentOfTotal);
        balances[timeVault] = safeAdd(balances[timeVault], vaultTokens);
        Transfer(0, timeVault, vaultTokens);

        // House: 10% of total goes to Decent.bet for initial house setup
        uint256 houseTokens = safeDiv(safeMul(oldTokenTotalSupply, housePercentOfTotal),
        crowdfundPercentOfTotal);
        balances[decentBetMultisig] = safeAdd(balances[decentBetMultisig], houseTokens);
        Transfer(0, decentBetMultisig, houseTokens);

        // Bounties: 2% of total goes to Decent bet for bounties
        uint256 bountyTokens = safeDiv(safeMul(oldTokenTotalSupply, bountyPercentOfTotal),
        crowdfundPercentOfTotal);
        balances[decentBetMultisig] = safeAdd(balances[decentBetMultisig], bountyTokens);
        Transfer(0, decentBetMultisig, bountyTokens);

        totalSupply = safeAdd(safeAdd(vaultTokens, houseTokens), bountyTokens);
    }

    // Upgrade-related methods
    function createToken(address _target, uint256 _amount) public {
        if (msg.sender != address(upgradeAgent)) revert();
        if (_amount == 0) revert();

        balances[_target] = safeAdd(balances[_target], _amount);
        totalSupply = safeAdd(totalSupply, _amount);
        Transfer(_target, _target, _amount);
    }

    // ERC20 interface: transfer _value new tokens from msg.sender to _to
    function transfer(address _to, uint256 _value) returns (bool success) {
        if (_to == 0x0) revert();
        if (_to == address(upgradeAgent)) revert();
        if (_to == address(this)) revert();
        //if (_to == address(UpgradeAgent(upgradeAgent).oldToken())) revert();
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] = safeSub(balances[msg.sender], _value);
            balances[_to] = safeAdd(balances[_to], _value);
            Transfer(msg.sender, _to, _value);
            return true;
        }
        else {return false;}
    }

    // ERC20 interface: transfer _value new tokens from _from to _to
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        if (_to == 0x0) revert();
        if (_to == address(upgradeAgent)) revert();
        if (_to == address(this)) revert();
        //if (_to == address(UpgradeAgent(upgradeAgent).oldToken())) revert();
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value) {
            balances[_to] = safeAdd(balances[_to], _value);
            balances[_from] = safeSub(balances[_from], _value);
            allowed[_from][msg.sender] = safeSub(allowed[_from][msg.sender], _value);
            Transfer(_from, _to, _value);
            return true;
        }
        else {return false;}
    }

    // ERC20 interface: delegate transfer rights of up to _value new tokens from
    // msg.sender to _spender
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    // ERC20 interface: returns the amount of new tokens belonging to _owner
    // that _spender can spend via transferFrom
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    // ERC20 interface: returns the wmount of new tokens belonging to _owner
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    // Token upgrade functionality

    /// @notice Upgrade tokens to the new token contract.
    /// @param value The number of tokens to upgrade
    function upgrade(uint256 value) external {
        if (nextUpgradeAgent.owner() == 0x0) revert();
        // need a real upgradeAgent address
        if (finalizedNextUpgrade) revert();
        // cannot upgrade if finalized

        // Validate input value.
        if (value == 0) revert();
        if (value > balances[msg.sender]) revert();

        // update the balances here first before calling out (reentrancy)
        balances[msg.sender] = safeSub(balances[msg.sender], value);
        totalSupply = safeSub(totalSupply, value);
        totalUpgraded = safeAdd(totalUpgraded, value);
        nextUpgradeAgent.upgradeFrom(msg.sender, value);
        Upgrade(msg.sender, nextUpgradeAgent, value);
    }

    /// @notice Set address of next upgrade target contract and enable upgrade
    /// process.
    /// @param agent The address of the UpgradeAgent contract
    function setNextUpgradeAgent(address agent) external {
        if (agent == 0x0) revert();
        // don't set agent to nothing
        if (msg.sender != nextUpgradeMaster) revert();
        // Only a master can designate the next agent
        nextUpgradeAgent = NextUpgradeAgent(agent);
        if (!nextUpgradeAgent.isUpgradeAgent()) revert();
        nextUpgradeAgent.setOriginalSupply();
        UpgradeAgentSet(nextUpgradeAgent);
    }

    /// @notice Set address of next upgrade master and enable upgrade
    /// process.
    /// @param master The address that will manage upgrades, not the upgradeAgent contract address
    function setNextUpgradeMaster(address master) external {
        if (master == 0x0) revert();
        if (msg.sender != nextUpgradeMaster) revert();
        // Only a master can designate the next master
        nextUpgradeMaster = master;
    }

    /// @notice finalize the upgrade
    /// @dev Required state: Success
    function finalizeNextUpgrade() external {
        if (nextUpgradeAgent.owner() == 0x0) revert();
        // we need a valid upgrade agent
        if (msg.sender != nextUpgradeMaster) revert();
        // only upgradeMaster can finalize
        if (finalizedNextUpgrade) revert();
        // can't finalize twice

        finalizedNextUpgrade = true;
        // prevent future upgrades

        nextUpgradeAgent.finalizeUpgrade();
        // call finalize upgrade on new contract
        UpgradeFinalized(msg.sender, nextUpgradeAgent);
    }

    /// @dev Fallback function throws to avoid accidentally losing money
    function() {revert();}
}


//Test the whole process against this: https://www.kingoftheether.com/contract-safety-checklist.html
contract NewUpgradeAgent is SafeMath {

    // flag to determine if address is for a real contract or not
    bool public isUpgradeAgent = false;

    // Contract information
    address public owner;

    // Upgrade information
    bool public upgradeHasBegun = false;

    bool public finalizedUpgrade = false;

    OldToken public oldToken;

    address public decentBetMultisig;

    NewDecentBetToken public newToken;

    uint256 public originalSupply; // the original total supply of old tokens

    uint256 public correctOriginalSupply; // Correct original supply accounting for 30% minted at finalizeCrowdfunding

    uint256 public mintedPercentOfTokens = 30; // Amount of tokens that're minted at finalizeCrowdfunding

    uint256 public crowdfundPercentOfTokens = 70;

    uint256 public mintedTokens;

    event NewTokenSet(address token);

    event UpgradeHasBegun();

    event InvariantCheckFailed(uint oldTokenSupply, uint newTokenSupply, uint originalSupply, uint value);

    event InvariantCheckPassed(uint oldTokenSupply, uint newTokenSupply, uint originalSupply, uint value);

    function NewUpgradeAgent(address _oldToken) {
        owner = msg.sender;
        isUpgradeAgent = true;
        oldToken = OldToken(_oldToken);
        if (!oldToken.isDecentBetToken()) revert();
        decentBetMultisig = oldToken.decentBetMultisig();
        originalSupply = oldToken.totalSupply();
        mintedTokens = safeDiv(safeMul(originalSupply, mintedPercentOfTokens), crowdfundPercentOfTokens);
        correctOriginalSupply = safeAdd(originalSupply, mintedTokens);
    }

    /// @notice Check to make sure that the current sum of old and
    /// new version tokens is still equal to the original number of old version
    /// tokens
    /// @param _value The number of DBETs to upgrade
    function safetyInvariantCheck(uint256 _value) public {
        if (!newToken.isNewToken()) revert();
        // Abort if new token contract has not been set
        uint oldSupply = oldToken.totalSupply();
        uint newSupply = newToken.totalSupply();
        if (safeAdd(oldSupply, newSupply) != safeSub(correctOriginalSupply, _value)) {
            InvariantCheckFailed(oldSupply, newSupply, correctOriginalSupply, _value);
        } else {
            InvariantCheckPassed(oldSupply, newSupply, correctOriginalSupply, _value);
        }
    }

    /// @notice Sets the new token contract address
    /// @param _newToken The address of the new token contract
    function setNewToken(address _newToken) external {
        if (msg.sender != owner) revert();
        if (_newToken == 0x0) revert();
        if (upgradeHasBegun) revert();
        // Cannot change token after upgrade has begun

        newToken = NewDecentBetToken(_newToken);
        if (!newToken.isNewToken()) revert();
        NewTokenSet(newToken);
    }

    /// @notice Sets flag to prevent changing newToken after upgrade
    function setUpgradeHasBegun() internal {
        if (!upgradeHasBegun) {
            upgradeHasBegun = true;
            UpgradeHasBegun();
        }
    }

    /// @notice Creates new version tokens from the new token
    /// contract
    /// @param _from The address of the token upgrader
    /// @param _value The number of tokens to upgrade
    function upgradeFrom(address _from, uint256 _value) public {
        if(finalizedUpgrade) revert();
        if (msg.sender != address(oldToken)) revert();
        // Multisig can't upgrade since tokens are minted for it in new token constructor as it isn't part
        // of totalSupply of oldToken.
        if (_from == decentBetMultisig) revert();
        // only upgrade from oldToken
        if (!newToken.isNewToken()) revert();
        // need a real newToken!

        setUpgradeHasBegun();
        // Right here oldToken has already been updated, but corresponding
        // DBETs have not been created in the newToken contract yet
        safetyInvariantCheck(_value);

        newToken.createToken(_from, _value);

        //Right here totalSupply invariant must hold
        safetyInvariantCheck(0);
    }

    // Initializes original supply from old token total supply
    function setOriginalSupply() public {
        if (msg.sender != address(oldToken)) revert();
        originalSupply = oldToken.totalSupply();
    }

    function finalizeUpgrade() public {
        if (msg.sender != address(oldToken)) revert();
        finalizedUpgrade = true;
    }

    /// @dev Fallback function disallows depositing ether.
    function() {revert();}

}