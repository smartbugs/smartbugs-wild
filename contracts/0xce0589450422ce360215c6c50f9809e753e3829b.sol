pragma solidity ^0.4.15;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() {
        owner = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) onlyOwner public {
        require(newOwner != address(0));
        OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <remco@2π.com>
 * @dev This tries to block incoming ether to prevent accidental loss of Ether. Should Ether end up
 * in the contract, it will allow the owner to reclaim this ether.
 * @notice Ether can still be send to this contract by:
 * calling functions labeled `payable`
 * `selfdestruct(contract_address)`
 * mining directly to the contract address
*/
contract HasNoEther is Ownable {

    /**
    * @dev Constructor that rejects incoming Ether
    * @dev The `payable` flag is added so we can access `msg.value` without compiler warning. If we
    * leave out payable, then Solidity will allow inheriting contracts to implement a payable
    * constructor. By doing it this way we prevent a payable constructor from working. Alternatively
    * we could use assembly to access msg.value.
    */
    function HasNoEther() payable {
        require(msg.value == 0);
    }

    /**
     * @dev Disallows direct send by settings a default function without the `payable` flag.
     */
    function() external {
    }

    /**
     * @dev Transfer all Ether held by the contract to the owner.
     */
    function reclaimEther() external onlyOwner {
        assert(owner.send(this.balance));
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * Fixed crowdsale pricing - everybody gets the same price.
 */
contract PricingStrategy is HasNoEther {
    using SafeMath for uint;

    /* How many weis one token costs */
    uint256 public oneTokenInWei;

    address public crowdsaleAddress;

    function PricingStrategy(address _crowdsale) {
        crowdsaleAddress = _crowdsale;
    }

    modifier onlyCrowdsale() {
        require(msg.sender == crowdsaleAddress);
        _;
    }

    /**
     * Calculate the current price for buy in amount.
     *
     */
    function calculatePrice(uint256 _value, uint256 _decimals) public constant returns (uint) {
        uint256 multiplier = 10 ** _decimals;
        uint256 weiAmount = _value.mul(multiplier);
        uint256 tokens = weiAmount.div(oneTokenInWei);
        return tokens;
    }

    function setTokenPriceInWei(uint _oneTokenInWei) onlyCrowdsale public returns (bool) {
        oneTokenInWei = _oneTokenInWei;
        return true;
    }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() onlyOwner whenPaused public {
        paused = false;
        Unpause();
    }
}

contract RNTMultiSigWallet {
    /*
     *  Events
     */
    event Confirmation(address indexed sender, uint indexed transactionId);

    event Revocation(address indexed sender, uint indexed transactionId);

    event Submission(uint indexed transactionId);

    event Execution(uint indexed transactionId);

    event ExecutionFailure(uint indexed transactionId);

    event Deposit(address indexed sender, uint value);

    event OwnerAddition(address indexed owner);

    event OwnerRemoval(address indexed owner);

    event RequirementChange(uint required);

    event Pause();

    event Unpause();

    /*
     *  Constants
     */
    uint constant public MAX_OWNER_COUNT = 10;

    uint constant public ADMINS_COUNT = 2;

    /*
     *  Storage
     */
    mapping(uint => WalletTransaction) public transactions;

    mapping(uint => mapping(address => bool)) public confirmations;

    mapping(address => bool) public isOwner;

    mapping(address => bool) public isAdmin;

    address[] public owners;

    address[] public admins;

    uint public required;

    uint public transactionCount;

    bool public paused = false;

    struct WalletTransaction {
        address sender;
        address destination;
        uint value;
        bytes data;
        bool executed;
    }

    /*
     *  Modifiers
     */

    /// @dev Modifier to make a function callable only when the contract is not paused.
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /// @dev Modifier to make a function callable only when the contract is paused.
    modifier whenPaused() {
        require(paused);
        _;
    }

    modifier onlyWallet() {
        require(msg.sender == address(this));
        _;
    }

    modifier ownerDoesNotExist(address owner) {
        require(!isOwner[owner]);
        _;
    }

    modifier ownerExists(address owner) {
        require(isOwner[owner]);
        _;
    }

    modifier adminExists(address admin) {
        require(isAdmin[admin]);
        _;
    }

    modifier adminDoesNotExist(address admin) {
        require(!isAdmin[admin]);
        _;
    }

    modifier transactionExists(uint transactionId) {
        require(transactions[transactionId].destination != 0);
        _;
    }

    modifier confirmed(uint transactionId, address owner) {
        require(confirmations[transactionId][owner]);
        _;
    }

    modifier notConfirmed(uint transactionId, address owner) {
        require(!confirmations[transactionId][owner]);
        _;
    }

    modifier notExecuted(uint transactionId) {
        if (transactions[transactionId].executed)
            require(false);
        _;
    }

    modifier notNull(address _address) {
        require(_address != 0);
        _;
    }

    modifier validRequirement(uint ownerCount, uint _required) {
        if (ownerCount > MAX_OWNER_COUNT
        || _required > ownerCount
        || _required == 0
        || ownerCount == 0) {
            require(false);
        }
        _;
    }

    modifier validAdminsCount(uint adminsCount) {
        require(adminsCount == ADMINS_COUNT);
        _;
    }

    /// @dev Fallback function allows to deposit ether.
    function()
    whenNotPaused
    payable
    {
        if (msg.value > 0)
            Deposit(msg.sender, msg.value);
    }

    /*
     * Public functions
     */
    /// @dev Contract constructor sets initial admins and required number of confirmations.
    /// @param _admins List of initial owners.
    /// @param _required Number of required confirmations.
    function RNTMultiSigWallet(address[] _admins, uint _required)
    public
        //    validAdminsCount(_admins.length)
        //    validRequirement(_admins.length, _required)
    {
        for (uint i = 0; i < _admins.length; i++) {
            require(_admins[i] != 0 && !isOwner[_admins[i]] && !isAdmin[_admins[i]]);
            isAdmin[_admins[i]] = true;
            isOwner[_admins[i]] = true;
        }

        admins = _admins;
        owners = _admins;
        required = _required;
    }

    /// @dev called by the owner to pause, triggers stopped state
    function pause() adminExists(msg.sender) whenNotPaused public {
        paused = true;
        Pause();
    }

    /// @dev called by the owner to unpause, returns to normal state
    function unpause() adminExists(msg.sender) whenPaused public {
        paused = false;
        Unpause();
    }

    /// @dev Allows to add a new owner. Transaction has to be sent by wallet.
    /// @param owner Address of new owner.
    function addOwner(address owner)
    public
    whenNotPaused
    adminExists(msg.sender)
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
    whenNotPaused
    adminExists(msg.sender)
    adminDoesNotExist(owner)
    ownerExists(owner)
    {
        isOwner[owner] = false;
        for (uint i = 0; i < owners.length - 1; i++)
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
    function replaceOwner(address owner, address newOwner)
    public
    whenNotPaused
    adminExists(msg.sender)
    adminDoesNotExist(owner)
    ownerExists(owner)
    ownerDoesNotExist(newOwner)
    {
        for (uint i = 0; i < owners.length; i++)
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
    whenNotPaused
    adminExists(msg.sender)
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
    whenNotPaused
    ownerExists(msg.sender)
    returns (uint transactionId)
    {
        transactionId = addTransaction(destination, value, data);
        confirmTransaction(transactionId);
    }

    /// @dev Allows an owner to confirm a transaction.
    /// @param transactionId Transaction ID.
    function confirmTransaction(uint transactionId)
    public
    whenNotPaused
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
    whenNotPaused
    ownerExists(msg.sender)
    confirmed(transactionId, msg.sender)
    notExecuted(transactionId)
    {
        confirmations[transactionId][msg.sender] = false;
        Revocation(msg.sender, transactionId);
    }

    /// @dev Allows anyone to execute a confirmed transaction.
    /// @param transactionId Transaction ID.
    function executeTransaction(uint transactionId)
    public
    whenNotPaused
    ownerExists(msg.sender)
    confirmed(transactionId, msg.sender)
    notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            WalletTransaction storage walletTransaction = transactions[transactionId];
            walletTransaction.executed = true;
            if (walletTransaction.destination.call.value(walletTransaction.value)(walletTransaction.data))
                Execution(transactionId);
            else {
                ExecutionFailure(transactionId);
                walletTransaction.executed = false;
            }
        }
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
        for (uint i = 0; i < owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
    }

    /*
     * Internal functions
     */
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
        transactions[transactionId] = WalletTransaction({
            sender : msg.sender,
            destination : destination,
            value : value,
            data : data,
            executed : false
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
        for (uint i = 0; i < owners.length; i++)
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
        for (uint i = 0; i < transactionCount; i++)
            if (pending && !transactions[i].executed
            || executed && transactions[i].executed)
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

    // @dev Returns list of admins.
    // @return List of admin addresses
    function getAdmins()
    public
    constant
    returns (address[])
    {
        return admins;
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
        for (i = 0; i < owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                confirmationsTemp[count] = owners[i];
                count += 1;
            }
        _confirmations = new address[](count);
        for (i = 0; i < count; i++)
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
        for (i = 0; i < transactionCount; i++)
            if (pending && !transactions[i].executed
            || executed && transactions[i].executed)
            {
                transactionIdsTemp[count] = i;
                count += 1;
            }
        _transactionIds = new uint[](to - from);
        for (i = from; i < to; i++)
            _transactionIds[i - from] = transactionIdsTemp[i];
    }
}

contract RntPresaleEthereumDeposit is Pausable {
    using SafeMath for uint256;

    uint256 public overallTakenEther = 0;

    mapping(address => uint256) public receivedEther;

    struct Donator {
        address addr;
        uint256 donated;
    }

    Donator[] donators;

    RNTMultiSigWallet public wallet;

    function RntPresaleEthereumDeposit(address _walletAddress) {
        wallet = RNTMultiSigWallet(_walletAddress);
    }

    function updateDonator(address _address) internal {
        bool isFound = false;
        for (uint i = 0; i < donators.length; i++) {
            if (donators[i].addr == _address) {
                donators[i].donated = receivedEther[_address];
                isFound = true;
                break;
            }
        }
        if (!isFound) {
            donators.push(Donator(_address, receivedEther[_address]));
        }
    }

    function getDonatorsNumber() external constant returns (uint256) {
        return donators.length;
    }

    function getDonator(uint pos) external constant returns (address, uint256) {
        return (donators[pos].addr, donators[pos].donated);
    }

    /*
     * Fallback function for sending ether to wallet and update donators info
     */
    function() whenNotPaused payable {
        wallet.transfer(msg.value);

        overallTakenEther = overallTakenEther.add(msg.value);
        receivedEther[msg.sender] = receivedEther[msg.sender].add(msg.value);

        updateDonator(msg.sender);
    }

    function receivedEtherFrom(address _from) whenNotPaused constant public returns (uint256) {
        return receivedEther[_from];
    }

    function myEther() whenNotPaused constant public returns (uint256) {
        return receivedEther[msg.sender];
    }
}

contract PresaleFinalizeAgent is HasNoEther {
    using SafeMath for uint256;

    RntPresaleEthereumDeposit public deposit;

    address public crowdsaleAddress;

    mapping(address => uint256) public tokensForAddress;

    uint256 public weiPerToken = 0;

    bool public sane = true;

    function PresaleFinalizeAgent(address _deposit, address _crowdsale){
        deposit = RntPresaleEthereumDeposit(_deposit);
        crowdsaleAddress = _crowdsale;
    }

    modifier onlyCrowdsale() {
        require(msg.sender == crowdsaleAddress);
        _;
    }

    function isSane() public constant returns (bool) {
        return sane;
    }

    function setCrowdsaleAddress(address _address) onlyOwner public {
        crowdsaleAddress = _address;
    }

    function finalizePresale(uint256 presaleTokens) onlyCrowdsale public {
        require(sane);
        uint256 overallEther = deposit.overallTakenEther();
        uint256 multiplier = 10 ** 18;
        overallEther = overallEther.mul(multiplier);
        weiPerToken = overallEther.div(presaleTokens);
        require(weiPerToken > 0);
        sane = false;
    }
}

contract IRntToken {
    uint256 public decimals = 18;

    uint256 public totalSupply = 1000000000 * (10 ** 18);

    string public name = "RNT Token";

    string public code = "RNT";


    function balanceOf() public constant returns (uint256 balance);

    function transfer(address _to, uint _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
}

contract RntCrowdsale is Pausable {
    using SafeMath for uint256;

    enum Status {Unknown, Presale, ICO, Finalized} // Crowdsale status

    Status public currentStatus = Status.Unknown;

    bool public isPresaleStarted = false;

    bool public isPresaleFinalized = false;

    bool public isIcoStarted = false;

    bool public isIcoFinalized = false;

    uint256 public icoReceivedWei;

    uint256 public icoTokensSold;

    uint256 public icoInvestmentsCount = 0;

    mapping(address => uint256) public icoInvestments;

    mapping(address => uint256) public icoTokenTransfers;

    IRntToken public token;

    PricingStrategy public pricingStrategy;

    PresaleFinalizeAgent public presaleFinalizeAgent;

    RntPresaleEthereumDeposit public deposit;

    address public wallet;

    address public proxy;

    mapping(address => bool) public tokensAllocationAllowed;

    uint public presaleStartTime;

    uint public presaleEndTime;

    uint public icoStartTime;

    uint public icoEndTime;

    /**
    @notice A new investment was made.
    */
    event Invested(address indexed investor, uint weiAmount, uint tokenAmount, bytes16 indexed customerId);

    event PresaleStarted(uint timestamp);

    event PresaleFinalized(uint timestamp);

    event IcoStarted(uint timestamp);

    event IcoFinalized(uint timestamp);

    /**
    @notice Token price was calculated.
    */
    event TokensPerWeiReceived(uint tokenPrice);

    /**
    @notice Presale tokens was claimed.
    */
    event PresaleTokensClaimed(uint count);

    function RntCrowdsale(address _tokenAddress) {
        token = IRntToken(_tokenAddress);
    }

    /**
    @notice Allow call function only if crowdsale on specified status.
    */
    modifier inStatus(Status status) {
        require(getCrowdsaleStatus() == status);
        _;
    }

    /**
    @notice Check that address can allocate tokens.
    */
    modifier canAllocateTokens {
        require(tokensAllocationAllowed[msg.sender] == true);
        _;
    }

    /**
    @notice Allow address to call allocate function.
    @param _addr Address for allowance
    @param _allow Allowance
    */
    function allowAllocation(address _addr, bool _allow) onlyOwner external {
        tokensAllocationAllowed[_addr] = _allow;
    }

    /**
    @notice Set PresaleFinalizeAgent address.
    @dev Used to calculate price for one token.
    */
    function setPresaleFinalizeAgent(address _agentAddress) whenNotPaused onlyOwner external {
        presaleFinalizeAgent = PresaleFinalizeAgent(_agentAddress);
    }

    /**
    @notice Set PricingStrategy address.
    @dev Used to calculate tokens that will be received through investment.
    */
    function setPricingStartegy(address _pricingStrategyAddress) whenNotPaused onlyOwner external {
        pricingStrategy = PricingStrategy(_pricingStrategyAddress);
    }

    /**
    @notice Set RNTMultiSigWallet address.
    @dev Wallet for invested wei.
    */
    function setMultiSigWallet(address _walletAddress) whenNotPaused onlyOwner external {
        wallet = _walletAddress;
    }


    /**
    @notice Set RntTokenProxy address.
    */
    function setBackendProxyBuyer(address _proxyAddress) whenNotPaused onlyOwner external {
        proxy = _proxyAddress;
    }

    /**
    @notice Set RntPresaleEhtereumDeposit address.
    @dev Deposit used to calculate presale tokens.
    */
    function setPresaleEthereumDeposit(address _depositAddress) whenNotPaused onlyOwner external {
        deposit = RntPresaleEthereumDeposit(_depositAddress);
    }

    /**
    @notice Get current crowdsale status.
    @return { One of possible crowdsale statuses [Unknown, Presale, ICO, Finalized] }
    */
    function getCrowdsaleStatus() constant public returns (Status) {
        return currentStatus;
    }

    /**
    @notice Start presale and track start time.
    */
    function startPresale() whenNotPaused onlyOwner external {
        require(!isPresaleStarted);

        currentStatus = Status.Presale;
        isPresaleStarted = true;

        presaleStartTime = now;
        PresaleStarted(presaleStartTime);
    }

    /**
    @notice Finalize presale, calculate token price, track finalize time.
    */
    function finalizePresale() whenNotPaused onlyOwner external {
        require(isPresaleStarted && !isPresaleFinalized);
        require(presaleFinalizeAgent.isSane());

        uint256 presaleSupply = token.totalSupply();

        // Presale supply is 20% of total
        presaleSupply = presaleSupply.div(5);

        presaleFinalizeAgent.finalizePresale(presaleSupply);
        uint tokenWei = presaleFinalizeAgent.weiPerToken();
        pricingStrategy.setTokenPriceInWei(tokenWei);
        TokensPerWeiReceived(tokenWei);

        require(tokenWei > 0);

        currentStatus = Status.Unknown;
        isPresaleFinalized = true;

        presaleEndTime = now;
        PresaleFinalized(presaleEndTime);
    }

    /**
    @notice Start ICO and track start time.
    */
    function startIco() whenNotPaused onlyOwner external {
        require(!isIcoStarted && isPresaleFinalized);

        currentStatus = Status.ICO;
        isIcoStarted = true;

        icoStartTime = now;
        IcoStarted(icoStartTime);
    }

    /**
    @notice Finalize ICO and track finalize time.
    */
    function finalizeIco() whenNotPaused onlyOwner external {
        require(!isIcoFinalized && isIcoStarted);

        currentStatus = Status.Finalized;
        isIcoFinalized = true;

        icoEndTime = now;
        IcoFinalized(icoEndTime);
    }


    /**
    @notice Handle invested wei.
    @dev Send some amount of wei to wallet and get tokens that will be calculated according Pricing Strategy.
         It will transfer ether to wallet only if investment did inside ethereum using payable method.
    @param _receiver The Ethereum address who receives the tokens.
    @param _customerUuid (optional) UUID v4 to track the successful payments on the server side.
    */
    function investInternal(address _receiver, bytes16 _customerUuid) private {
        uint weiAmount = msg.value;

        uint256 tokenAmount = pricingStrategy.calculatePrice(weiAmount, 18);

        require(tokenAmount != 0);

        if (icoInvestments[_receiver] == 0) {
            // A new investor
            icoInvestmentsCount++;
        }
        icoInvestments[_receiver] = icoInvestments[_receiver].add(weiAmount);
        icoTokenTransfers[_receiver] = icoTokenTransfers[_receiver].add(tokenAmount);
        icoReceivedWei = icoReceivedWei.add(weiAmount);
        icoTokensSold = icoTokensSold.add(tokenAmount);

        assignTokens(owner, _receiver, tokenAmount);

        // Pocket the money
        wallet.transfer(weiAmount);

        // Tell us invest was success
        Invested(_receiver, weiAmount, tokenAmount, _customerUuid);
    }

    /**
    @notice Handle tokens allocating.
    @dev Uses when tokens was bought not in ethereum
    @param _receiver The Ethereum address who receives the tokens.
    @param _customerUuid (optional) UUID v4 to track the successful payments on the server side.
    @param _weiAmount Wei amount, that should be specified only if user was invested out
    */
    function allocateInternal(address _receiver, bytes16 _customerUuid, uint256 _weiAmount) private {
        uint256 tokenAmount = pricingStrategy.calculatePrice(_weiAmount, 18);

        require(tokenAmount != 0);

        if (icoInvestments[_receiver] == 0) {
            // A new investor
            icoInvestmentsCount++;
        }
        icoInvestments[_receiver] = icoInvestments[_receiver].add(_weiAmount);
        icoTokenTransfers[_receiver] = icoTokenTransfers[_receiver].add(tokenAmount);
        icoReceivedWei = icoReceivedWei.add(_weiAmount);
        icoTokensSold = icoTokensSold.add(tokenAmount);

        assignTokens(owner, _receiver, tokenAmount);

        // Tell us invest was success
        Invested(_receiver, _weiAmount, tokenAmount, _customerUuid);
    }

    /**
    @notice Allocate tokens to specified address.
    @dev Function that should be used only by proxy to handle payments outside ethereum.
    @param _receiver The Ethereum address who receives the tokens.
    @param _customerUuid (optional) UUID v4 to track the successful payments on the server side.
    @param _weiAmount User invested amount of money in wei.
    */
    function allocateTokens(address _receiver, bytes16 _customerUuid, uint256 _weiAmount) whenNotPaused canAllocateTokens public {
        allocateInternal(_receiver, _customerUuid, _weiAmount);
    }

    /**
    @notice Make an investment.
    @dev Can be called only at ICO status. Should have wei != 0.
    @param _customerUuid (optional) UUID v4 to track the successful payments on the server side
    */
    function invest(bytes16 _customerUuid) whenNotPaused inStatus(Status.ICO) public payable {
        investInternal(msg.sender, _customerUuid);
    }

    /**
    @notice Function for claiming tokens for presale investors.
    @dev Can be called only after presale ends. Tokens will be transfered to callers address.
    */
    function claimPresaleTokens() whenNotPaused external {
        require(isPresaleFinalized == true);

        uint256 senderEther = deposit.receivedEtherFrom(msg.sender);
        uint256 multiplier = 10 ** 18;
        senderEther = senderEther.mul(multiplier);
        uint256 tokenWei = pricingStrategy.oneTokenInWei();
        uint256 tokensAmount = senderEther.div(tokenWei);

        require(tokensAmount > 0);
        token.transferFrom(owner, msg.sender, tokensAmount);
        PresaleTokensClaimed(tokensAmount);
    }

    /**
    @notice Transfer issued tokens to the investor.
    */
    function assignTokens(address _from, address _receiver, uint _tokenAmount) private {
        token.transferFrom(_from, _receiver, _tokenAmount);
    }
}