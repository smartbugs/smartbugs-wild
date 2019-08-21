pragma solidity ^0.4.17;

// ----------------------------------------------------------------------------
// Token Trustee Implementation
//
// Copyright (c) 2017 OpenST Ltd.
// https://simpletoken.org/
//
// The MIT Licence.
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// SafeMath Library Implementation
//
// Copyright (c) 2017 OpenST Ltd.
// https://simpletoken.org/
//
// The MIT Licence.
//
// Based on the SafeMath library by the OpenZeppelin team.
// Copyright (c) 2016 Smart Contract Solutions, Inc.
// https://github.com/OpenZeppelin/zeppelin-solidity
// The MIT License.
// ----------------------------------------------------------------------------


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;

        assert(a == 0 || c / a == b);

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity automatically throws when dividing by 0
        uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);

        return a - b;
    }


    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;

        assert(c >= a);

        return c;
    }
}

//
// Implements basic ownership with 2-step transfers.
//
contract Owned {

    address public owner;
    address public proposedOwner;

    event OwnershipTransferInitiated(address indexed _proposedOwner);
    event OwnershipTransferCompleted(address indexed _newOwner);


    function Owned() public {
        owner = msg.sender;
    }


    modifier onlyOwner() {
        require(isOwner(msg.sender));
        _;
    }


    function isOwner(address _address) internal view returns (bool) {
        return (_address == owner);
    }


    function initiateOwnershipTransfer(address _proposedOwner) public onlyOwner returns (bool) {
        proposedOwner = _proposedOwner;

        OwnershipTransferInitiated(_proposedOwner);

        return true;
    }


    function completeOwnershipTransfer() public returns (bool) {
        require(msg.sender == proposedOwner);

        owner = proposedOwner;
        proposedOwner = address(0);

        OwnershipTransferCompleted(owner);

        return true;
    }
}

//
// Implements a more advanced ownership and permission model based on owner,
// admin and ops per Simple Token key management specification.
//
contract OpsManaged is Owned {

    address public opsAddress;
    address public adminAddress;

    event AdminAddressChanged(address indexed _newAddress);
    event OpsAddressChanged(address indexed _newAddress);


    function OpsManaged() public
        Owned()
    {
    }


    modifier onlyAdmin() {
        require(isAdmin(msg.sender));
        _;
    }


    modifier onlyAdminOrOps() {
        require(isAdmin(msg.sender) || isOps(msg.sender));
        _;
    }


    modifier onlyOwnerOrAdmin() {
        require(isOwner(msg.sender) || isAdmin(msg.sender));
        _;
    }


    modifier onlyOps() {
        require(isOps(msg.sender));
        _;
    }


    function isAdmin(address _address) internal view returns (bool) {
        return (adminAddress != address(0) && _address == adminAddress);
    }


    function isOps(address _address) internal view returns (bool) {
        return (opsAddress != address(0) && _address == opsAddress);
    }


    function isOwnerOrOps(address _address) internal view returns (bool) {
        return (isOwner(_address) || isOps(_address));
    }


    // Owner and Admin can change the admin address. Address can also be set to 0 to 'disable' it.
    function setAdminAddress(address _adminAddress) external onlyOwnerOrAdmin returns (bool) {
        require(_adminAddress != owner);
        require(_adminAddress != address(this));
        require(!isOps(_adminAddress));

        adminAddress = _adminAddress;

        AdminAddressChanged(_adminAddress);

        return true;
    }


    // Owner and Admin can change the operations address. Address can also be set to 0 to 'disable' it.
    function setOpsAddress(address _opsAddress) external onlyOwnerOrAdmin returns (bool) {
        require(_opsAddress != owner);
        require(_opsAddress != address(this));
        require(!isAdmin(_opsAddress));

        opsAddress = _opsAddress;

        OpsAddressChanged(_opsAddress);

        return true;
    }
}

contract SimpleTokenConfig {

    string  public constant TOKEN_SYMBOL   = "ST";
    string  public constant TOKEN_NAME     = "Simple Token";
    uint8   public constant TOKEN_DECIMALS = 18;

    uint256 public constant DECIMALSFACTOR = 10**uint256(TOKEN_DECIMALS);
    uint256 public constant TOKENS_MAX     = 800000000 * DECIMALSFACTOR;
}

contract ERC20Interface {

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function name() public view returns (string);
    function symbol() public view returns (string);
    function decimals() public view returns (uint8);
    function totalSupply() public view returns (uint256);

    function balanceOf(address _owner) public view returns (uint256 balance);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
}

//
// Standard ERC20 implementation, with ownership.
//
contract ERC20Token is ERC20Interface, Owned {

    using SafeMath for uint256;

    string  private tokenName;
    string  private tokenSymbol;
    uint8   private tokenDecimals;
    uint256 internal tokenTotalSupply;

    mapping(address => uint256) balances;
    mapping(address => mapping (address => uint256)) allowed;


    function ERC20Token(string _symbol, string _name, uint8 _decimals, uint256 _totalSupply) public
        Owned()
    {
        tokenSymbol      = _symbol;
        tokenName        = _name;
        tokenDecimals    = _decimals;
        tokenTotalSupply = _totalSupply;
        balances[owner]  = _totalSupply;

        // According to the ERC20 standard, a token contract which creates new tokens should trigger
        // a Transfer event and transfers of 0 values must also fire the event.
        Transfer(0x0, owner, _totalSupply);
    }


    function name() public view returns (string) {
        return tokenName;
    }


    function symbol() public view returns (string) {
        return tokenSymbol;
    }


    function decimals() public view returns (uint8) {
        return tokenDecimals;
    }


    function totalSupply() public view returns (uint256) {
        return tokenTotalSupply;
    }


    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }


    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }


    function transfer(address _to, uint256 _value) public returns (bool success) {
        // According to the EIP20 spec, "transfers of 0 values MUST be treated as normal
        // transfers and fire the Transfer event".
        // Also, should throw if not enough balance. This is taken care of by SafeMath.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(msg.sender, _to, _value);

        return true;
    }


    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        balances[_from] = balances[_from].sub(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        Transfer(_from, _to, _value);

        return true;
    }


    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowed[msg.sender][_spender] = _value;

        Approval(msg.sender, _spender, _value);

        return true;
    }
}

//
// SimpleToken is a standard ERC20 token with some additional functionality:
// - It has a concept of finalize
// - Before finalize, nobody can transfer tokens except:
//     - Owner and operations can transfer tokens
//     - Anybody can send back tokens to owner
// - After finalize, no restrictions on token transfers
//

//
// Permissions, according to the ST key management specification.
//
//                                    Owner    Admin   Ops
// transfer (before finalize)           x               x
// transferForm (before finalize)       x               x
// finalize                                      x
//

contract SimpleToken is ERC20Token, OpsManaged, SimpleTokenConfig {

    bool public finalized;


    // Events
    event Burnt(address indexed _from, uint256 _amount);
    event Finalized();


    function SimpleToken() public
        ERC20Token(TOKEN_SYMBOL, TOKEN_NAME, TOKEN_DECIMALS, TOKENS_MAX)
        OpsManaged()
    {
        finalized = false;
    }


    // Implementation of the standard transfer method that takes into account the finalize flag.
    function transfer(address _to, uint256 _value) public returns (bool success) {
        checkTransferAllowed(msg.sender, _to);

        return super.transfer(_to, _value);
    }


    // Implementation of the standard transferFrom method that takes into account the finalize flag.
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        checkTransferAllowed(msg.sender, _to);

        return super.transferFrom(_from, _to, _value);
    }


    function checkTransferAllowed(address _sender, address _to) private view {
        if (finalized) {
            // Everybody should be ok to transfer once the token is finalized.
            return;
        }

        // Owner and Ops are allowed to transfer tokens before the sale is finalized.
        // This allows the tokens to move from the TokenSale contract to a beneficiary.
        // We also allow someone to send tokens back to the owner. This is useful among other
        // cases, for the Trustee to transfer unlocked tokens back to the owner (reclaimTokens).
        require(isOwnerOrOps(_sender) || _to == owner);
    }

    // Implement a burn function to permit msg.sender to reduce its balance
    // which also reduces tokenTotalSupply
    function burn(uint256 _value) public returns (bool success) {
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        tokenTotalSupply = tokenTotalSupply.sub(_value);

        Burnt(msg.sender, _value);

        return true;
    }


    // Finalize method marks the point where token transfers are finally allowed for everybody.
    function finalize() external onlyAdmin returns (bool success) {
        require(!finalized);

        finalized = true;

        Finalized();

        return true;
    }
}

//
// Implements a simple trustee which can release tokens based on
// an explicit call from the owner.
//

//
// Permissions, according to the ST key management specification.
//
//                                Owner    Admin   Ops   Revoke
// grantAllocation                           x      x
// revokeAllocation                                        x
// processAllocation                                x
// reclaimTokens                             x
// setRevokeAddress                 x                      x
//

contract Trustee is OpsManaged {

    using SafeMath for uint256;


    SimpleToken public tokenContract;

    struct Allocation {
        uint256 amountGranted;
        uint256 amountTransferred;
        bool    revokable;
    }

    // The trustee has a special 'revoke' key which is allowed to revoke allocations.
    address public revokeAddress;

    // Total number of tokens that are currently allocated.
    // This does not include tokens that have been processed (sent to an address) already or
    // the ones in the trustee's account that have not been allocated yet.
    uint256 public totalLocked;

    mapping (address => Allocation) public allocations;


    //
    // Events
    //
    event AllocationGranted(address indexed _from, address indexed _account, uint256 _amount, bool _revokable);
    event AllocationRevoked(address indexed _from, address indexed _account, uint256 _amountRevoked);
    event AllocationProcessed(address indexed _from, address indexed _account, uint256 _amount);
    event RevokeAddressChanged(address indexed _newAddress);
    event TokensReclaimed(uint256 _amount);


    function Trustee(SimpleToken _tokenContract) public
        OpsManaged()
    {
        require(address(_tokenContract) != address(0));

        tokenContract = _tokenContract;
    }


    modifier onlyOwnerOrRevoke() {
        require(isOwner(msg.sender) || isRevoke(msg.sender));
        _;
    }


    modifier onlyRevoke() {
        require(isRevoke(msg.sender));
        _;
    }


    function isRevoke(address _address) private view returns (bool) {
        return (revokeAddress != address(0) && _address == revokeAddress);
    }


    // Owner and revoke can change the revoke address. Address can also be set to 0 to 'disable' it.
    function setRevokeAddress(address _revokeAddress) external onlyOwnerOrRevoke returns (bool) {
        require(_revokeAddress != owner);
        require(!isAdmin(_revokeAddress));
        require(!isOps(_revokeAddress));

        revokeAddress = _revokeAddress;

        RevokeAddressChanged(_revokeAddress);

        return true;
    }


    // Allows admin or ops to create new allocations for a specific account.
    function grantAllocation(address _account, uint256 _amount, bool _revokable) public onlyAdminOrOps returns (bool) {
        require(_account != address(0));
        require(_account != address(this));
        require(_amount > 0);

        // Can't create an allocation if there is already one for this account.
        require(allocations[_account].amountGranted == 0);

        if (isOps(msg.sender)) {
            // Once the token contract is finalized, the ops key should not be able to grant allocations any longer.
            // Before finalized, it is used by the TokenSale contract to allocate pre-sales.
            require(!tokenContract.finalized());
        }

        totalLocked = totalLocked.add(_amount);
        require(totalLocked <= tokenContract.balanceOf(address(this)));

        allocations[_account] = Allocation({
            amountGranted     : _amount,
            amountTransferred : 0,
            revokable         : _revokable
        });

        AllocationGranted(msg.sender, _account, _amount, _revokable);

        return true;
    }


    // Allows the revoke key to revoke allocations, if revoke is allowed.
    function revokeAllocation(address _account) external onlyRevoke returns (bool) {
        require(_account != address(0));

        Allocation memory allocation = allocations[_account];

        require(allocation.revokable);

        uint256 ownerRefund = allocation.amountGranted.sub(allocation.amountTransferred);

        delete allocations[_account];

        totalLocked = totalLocked.sub(ownerRefund);

        AllocationRevoked(msg.sender, _account, ownerRefund);

        return true;
    }


    // Push model which allows ops to transfer tokens to the beneficiary.
    // The exact amount to transfer is calculated based on agreements with
    // the beneficiaries. Here we only restrict that the total amount transfered cannot
    // exceed what has been granted.
    function processAllocation(address _account, uint256 _amount) external onlyOps returns (bool) {
        require(_account != address(0));
        require(_amount > 0);

        Allocation storage allocation = allocations[_account];

        require(allocation.amountGranted > 0);

        uint256 transferable = allocation.amountGranted.sub(allocation.amountTransferred);

        if (transferable < _amount) {
           return false;
        }

        allocation.amountTransferred = allocation.amountTransferred.add(_amount);

        // Note that transfer will fail if the token contract has not been finalized yet.
        require(tokenContract.transfer(_account, _amount));

        totalLocked = totalLocked.sub(_amount);

        AllocationProcessed(msg.sender, _account, _amount);

        return true;
    }


    // Allows the admin to claim back all tokens that are not currently allocated.
    // Note that the trustee should be able to move tokens even before the token is
    // finalized because SimpleToken allows sending back to owner specifically.
    function reclaimTokens() external onlyAdmin returns (bool) {
        uint256 ownBalance = tokenContract.balanceOf(address(this));

        // If balance <= amount locked, there is nothing to reclaim.
        require(ownBalance > totalLocked);

        uint256 amountReclaimed = ownBalance.sub(totalLocked);

        address tokenOwner = tokenContract.owner();
        require(tokenOwner != address(0));

        require(tokenContract.transfer(tokenOwner, amountReclaimed));

        TokensReclaimed(amountReclaimed);

        return true;
    }
}

// ----------------------------------------------------------------------------
// Pausable Contract Implementation
//
// Copyright (c) 2017 OpenST Ltd.
// https://simpletoken.org/
//
// The MIT Licence.
//
// Based on the Pausable contract by the OpenZeppelin team.
// Copyright (c) 2016 Smart Contract Solutions, Inc.
// https://github.com/OpenZeppelin/zeppelin-solidity
// The MIT License.
// ----------------------------------------------------------------------------

contract Pausable is OpsManaged {

  event Pause();
  event Unpause();

  bool public paused = false;


  modifier whenNotPaused() {
    require(!paused);
    _;
  }


  modifier whenPaused() {
    require(paused);
    _;
  }


  function pause() public onlyAdmin whenNotPaused {
    paused = true;

    Pause();
  }


  function unpause() public onlyAdmin whenPaused {
    paused = false;

    Unpause();
  }
}

contract TokenSaleConfig is SimpleTokenConfig {

    uint256 public constant PHASE1_START_TIME         = 1510664400; // 2017-11-14, 13:00:00 UTC
    uint256 public constant PHASE2_START_TIME         = 1510750800; // 2017-11-15, 13:00:00 UTC
    uint256 public constant END_TIME                  = 1512133199; // 2017-12-01, 12:59:59 UTC
    uint256 public constant CONTRIBUTION_MIN          = 0.1 ether;
    uint256 public constant CONTRIBUTION_MAX          = 10000.0 ether;

    // This is the maximum number of tokens each individual account is allowed to
    // buy during Phase 1 of the token sale (whitelisted phase)
    // Calculated based on 300 USD/ETH * 10 ETH / 0.0833 USD / token = ~36,000
    uint256 public constant PHASE1_ACCOUNT_TOKENS_MAX = 36000     * DECIMALSFACTOR;

    uint256 public constant TOKENS_SALE               = 240000000 * DECIMALSFACTOR;
    uint256 public constant TOKENS_FOUNDERS           = 80000000  * DECIMALSFACTOR;
    uint256 public constant TOKENS_ADVISORS           = 80000000  * DECIMALSFACTOR;
    uint256 public constant TOKENS_EARLY_BACKERS      = 44884831  * DECIMALSFACTOR;
    uint256 public constant TOKENS_ACCELERATOR        = 217600000 * DECIMALSFACTOR;
    uint256 public constant TOKENS_FUTURE             = 137515169 * DECIMALSFACTOR;

    // We use a default for when the contract is deployed but this can be changed afterwards
    // by calling the setTokensPerKEther function
    // For the public sale, tokens are priced at 0.0833 USD/token.
    // So if we have 300 USD/ETH -> 300,000 USD/KETH / 0.0833 USD/token = ~3,600,000
    uint256 public constant TOKENS_PER_KETHER         = 3600000;

    // Constant used by buyTokens as part of the cost <-> tokens conversion.
    // 18 for ETH -> WEI, TOKEN_DECIMALS (18 for Simple Token), 3 for the K in tokensPerKEther.
    uint256 public constant PURCHASE_DIVIDER          = 10**(uint256(18) - TOKEN_DECIMALS + 3);

}

//
// Implementation of the 1st token sale for Simple Token
//
// * Lifecycle *
// Initialization sequence should be as follow:
//    1. Deploy SimpleToken contract
//    2. Deploy Trustee contract
//    3. Deploy TokenSale contract
//    4. Set operationsAddress of SimpleToken contract to TokenSale contract
//    5. Set operationsAddress of Trustee contract to TokenSale contract
//    6. Set operationsAddress of TokenSale contract to some address
//    7. Transfer tokens from owner to TokenSale contract
//    8. Transfer tokens from owner to Trustee contract
//    9. Initialize TokenSale contract
//
// Pre-sale sequence:
//    - Set tokensPerKEther
//    - Set phase1AccountTokensMax
//    - Add presales
//    - Add allocations for founders, advisors, etc.
//    - Update whitelist
//
// After-sale sequence:
//    1. Finalize the TokenSale contract
//    2. Finalize the SimpleToken contract
//    3. Set operationsAddress of TokenSale contract to 0
//    4. Set operationsAddress of SimpleToken contract to 0
//    5. Set operationsAddress of Trustee contract to some address
//
// Anytime
//    - Add/Remove allocations
//

//
// Permissions, according to the ST key management specification.
//
//                                Owner    Admin   Ops
// initialize                       x
// changeWallet                              x
// updateWhitelist                                  x
// setTokensPerKEther                        x
// setPhase1AccountTokensMax                 x
// addPresale                                x
// pause / unpause                           x
// reclaimTokens                             x
// burnUnsoldTokens                          x
// finalize                                  x
//

contract TokenSale is OpsManaged, Pausable, TokenSaleConfig { // Pausable is also Owned

    using SafeMath for uint256;


    // We keep track of whether the sale has been finalized, at which point
    // no additional contributions will be permitted.
    bool public finalized;

    // The sale end time is initially defined by the END_TIME constant but it
    // may get extended if the sale is paused.
    uint256 public endTime;
    uint256 public pausedTime;

    // Number of tokens per 1000 ETH. See TokenSaleConfig for details.
    uint256 public tokensPerKEther;

    // Keeps track of the maximum amount of tokens that an account is allowed to purchase in phase 1.
    uint256 public phase1AccountTokensMax;

    // Address where the funds collected during the sale will be forwarded.
    address public wallet;

    // Token contract that the sale contract will interact with.
    SimpleToken public tokenContract;

    // Trustee contract to hold on token balances. The following token pools will be held by trustee:
    //    - Founders
    //    - Advisors
    //    - Early investors
    //    - Presales
    Trustee public trusteeContract;

    // Total amount of tokens sold during presale + public sale. Excludes pre-sale bonuses.
    uint256 public totalTokensSold;

    // Total amount of tokens given as bonus during presale. Will influence accelerator token balance.
    uint256 public totalPresaleBase;
    uint256 public totalPresaleBonus;

    // Map of addresses that have been whitelisted in advance (and passed KYC).
    // The whitelist value indicates what phase (1 or 2) the address has been whitelisted for.
    // Addresses whitelisted for phase 1 can also contribute during phase 2.
    mapping(address => uint8) public whitelist;


    //
    // EVENTS
    //
    event Initialized();
    event PresaleAdded(address indexed _account, uint256 _baseTokens, uint256 _bonusTokens);
    event WhitelistUpdated(address indexed _account, uint8 _phase);
    event TokensPurchased(address indexed _beneficiary, uint256 _cost, uint256 _tokens, uint256 _totalSold);
    event TokensPerKEtherUpdated(uint256 _amount);
    event Phase1AccountTokensMaxUpdated(uint256 _tokens);
    event WalletChanged(address _newWallet);
    event TokensReclaimed(uint256 _amount);
    event UnsoldTokensBurnt(uint256 _amount);
    event Finalized();


    function TokenSale(SimpleToken _tokenContract, Trustee _trusteeContract, address _wallet) public
        OpsManaged()
    {
        require(address(_tokenContract) != address(0));
        require(address(_trusteeContract) != address(0));
        require(_wallet != address(0));

        require(PHASE1_START_TIME >= currentTime());
        require(PHASE2_START_TIME > PHASE1_START_TIME);
        require(END_TIME > PHASE2_START_TIME);
        require(TOKENS_PER_KETHER > 0);
        require(PHASE1_ACCOUNT_TOKENS_MAX > 0);

        // Basic check that the constants add up to TOKENS_MAX
        uint256 partialAllocations = TOKENS_FOUNDERS.add(TOKENS_ADVISORS).add(TOKENS_EARLY_BACKERS);
        require(partialAllocations.add(TOKENS_SALE).add(TOKENS_ACCELERATOR).add(TOKENS_FUTURE) == TOKENS_MAX);

        wallet                 = _wallet;
        pausedTime             = 0;
        endTime                = END_TIME;
        finalized              = false;
        tokensPerKEther        = TOKENS_PER_KETHER;
        phase1AccountTokensMax = PHASE1_ACCOUNT_TOKENS_MAX;

        tokenContract   = _tokenContract;
        trusteeContract = _trusteeContract;
    }


    // Initialize is called to check some configuration parameters.
    // It expects that a certain amount of tokens have already been assigned to the sale contract address.
    function initialize() external onlyOwner returns (bool) {
        require(totalTokensSold == 0);
        require(totalPresaleBase == 0);
        require(totalPresaleBonus == 0);

        uint256 ownBalance = tokenContract.balanceOf(address(this));
        require(ownBalance == TOKENS_SALE);

        // Simple check to confirm that tokens are present
        uint256 trusteeBalance = tokenContract.balanceOf(address(trusteeContract));
        require(trusteeBalance >= TOKENS_FUTURE);

        Initialized();

        return true;
    }


    // Allows the admin to change the wallet where ETH contributions are sent.
    function changeWallet(address _wallet) external onlyAdmin returns (bool) {
        require(_wallet != address(0));
        require(_wallet != address(this));
        require(_wallet != address(trusteeContract));
        require(_wallet != address(tokenContract));

        wallet = _wallet;

        WalletChanged(wallet);

        return true;
    }



    //
    // TIME
    //

    function currentTime() public view returns (uint256 _currentTime) {
        return now;
    }


    modifier onlyBeforeSale() {
        require(hasSaleEnded() == false);
        require(currentTime() < PHASE1_START_TIME);
       _;
    }


    modifier onlyDuringSale() {
        require(hasSaleEnded() == false && currentTime() >= PHASE1_START_TIME);
        _;
    }

    modifier onlyAfterSale() {
        // require finalized is stronger than hasSaleEnded
        require(finalized);
        _;
    }


    function hasSaleEnded() private view returns (bool) {
        // if sold out or finalized, sale has ended
        if (totalTokensSold >= TOKENS_SALE || finalized) {
            return true;
        // else if sale is not paused (pausedTime = 0) 
        // and endtime has past, then sale has ended
        } else if (pausedTime == 0 && currentTime() >= endTime) {
            return true;
        // otherwise it is not past and not paused; or paused
        // and as such not ended
        } else {
            return false;
        }
    }



    //
    // WHITELIST
    //

    // Allows ops to add accounts to the whitelist.
    // Only those accounts will be allowed to contribute during the sale.
    // _phase = 1: Can contribute during phases 1 and 2 of the sale.
    // _phase = 2: Can contribute during phase 2 of the sale only.
    // _phase = 0: Cannot contribute at all (not whitelisted).
    function updateWhitelist(address _account, uint8 _phase) external onlyOps returns (bool) {
        require(_account != address(0));
        require(_phase <= 2);
        require(!hasSaleEnded());

        whitelist[_account] = _phase;

        WhitelistUpdated(_account, _phase);

        return true;
    }



    //
    // PURCHASES / CONTRIBUTIONS
    //

    // Allows the admin to set the price for tokens sold during phases 1 and 2 of the sale.
    function setTokensPerKEther(uint256 _tokensPerKEther) external onlyAdmin onlyBeforeSale returns (bool) {
        require(_tokensPerKEther > 0);

        tokensPerKEther = _tokensPerKEther;

        TokensPerKEtherUpdated(_tokensPerKEther);

        return true;
    }


    // Allows the admin to set the maximum amount of tokens that an account can buy during phase 1 of the sale.
    function setPhase1AccountTokensMax(uint256 _tokens) external onlyAdmin onlyBeforeSale returns (bool) {
        require(_tokens > 0);

        phase1AccountTokensMax = _tokens;

        Phase1AccountTokensMaxUpdated(_tokens);

        return true;
    }


    function () external payable whenNotPaused onlyDuringSale {
        buyTokens();
    }


    // This is the main function to process incoming ETH contributions.
    function buyTokens() public payable whenNotPaused onlyDuringSale returns (bool) {
        require(msg.value >= CONTRIBUTION_MIN);
        require(msg.value <= CONTRIBUTION_MAX);
        require(totalTokensSold < TOKENS_SALE);

        // All accounts need to be whitelisted to purchase.
        uint8 whitelistedPhase = whitelist[msg.sender];
        require(whitelistedPhase > 0);

        uint256 tokensMax = TOKENS_SALE.sub(totalTokensSold);

        if (currentTime() < PHASE2_START_TIME) {
            // We are in phase 1 of the sale
            require(whitelistedPhase == 1);

            uint256 accountBalance = tokenContract.balanceOf(msg.sender);

            // Can only purchase up to a maximum per account.
            // Calculate how much of that amount is still available.
            uint256 phase1Balance = phase1AccountTokensMax.sub(accountBalance);

            if (phase1Balance < tokensMax) {
                tokensMax = phase1Balance;
            }
        }

        require(tokensMax > 0);

        uint256 tokensBought = msg.value.mul(tokensPerKEther).div(PURCHASE_DIVIDER);
        require(tokensBought > 0);

        uint256 cost = msg.value;
        uint256 refund = 0;

        if (tokensBought > tokensMax) {
            // Not enough tokens available for full contribution, we will do partial.
            tokensBought = tokensMax;

            // Calculate actual cost for partial amount of tokens.
            cost = tokensBought.mul(PURCHASE_DIVIDER).div(tokensPerKEther);

            // Calculate refund for contributor.
            refund = msg.value.sub(cost);
        }

        totalTokensSold = totalTokensSold.add(tokensBought);

        // Transfer tokens to the account
        require(tokenContract.transfer(msg.sender, tokensBought));

        // Issue a ETH refund for any unused portion of the funds.
        if (refund > 0) {
            msg.sender.transfer(refund);
        }

        // Transfer the contribution to the wallet
        wallet.transfer(msg.value.sub(refund));

        TokensPurchased(msg.sender, cost, tokensBought, totalTokensSold);

        // If all tokens available for sale have been sold out, finalize the sale automatically.
        if (totalTokensSold == TOKENS_SALE) {
            finalizeInternal();
        }

        return true;
    }


    //
    // PRESALES
    //

    // Allows the admin to record pre-sales, before the public sale starts. Presale base tokens come out of the
    // main sale pool (the 30% allocation) while bonus tokens come from the remaining token pool.
    function addPresale(address _account, uint256 _baseTokens, uint256 _bonusTokens) external onlyAdmin onlyBeforeSale returns (bool) {
        require(_account != address(0));

        // Presales may have 0 bonus tokens but need to have a base amount of tokens sold.
        require(_baseTokens > 0);
        require(_bonusTokens < _baseTokens);

        // We do not count bonus tokens as part of the sale cap.
        totalTokensSold = totalTokensSold.add(_baseTokens);
        require(totalTokensSold <= TOKENS_SALE);

        uint256 ownBalance = tokenContract.balanceOf(address(this));
        require(_baseTokens <= ownBalance);

        totalPresaleBase  = totalPresaleBase.add(_baseTokens);
        totalPresaleBonus = totalPresaleBonus.add(_bonusTokens);

        // Move base tokens to the trustee
        require(tokenContract.transfer(address(trusteeContract), _baseTokens));

        // Presale allocations are marked as locked, they cannot be removed by the owner.
        uint256 tokens = _baseTokens.add(_bonusTokens);
        require(trusteeContract.grantAllocation(_account, tokens, false /* revokable */));

        PresaleAdded(_account, _baseTokens, _bonusTokens);

        return true;
    }


    //
    // PAUSE / UNPAUSE
    //

    // Allows the owner or admin to pause the sale for any reason.
    function pause() public onlyAdmin whenNotPaused {
        require(hasSaleEnded() == false);

        pausedTime = currentTime();

        return super.pause();
    }


    // Unpause may extend the end time of the public sale.
    // Note that we do not extend the start time of each phase.
    // Currently does not extend phase 1 end time, only final end time.
    function unpause() public onlyAdmin whenPaused {

        // If owner unpauses before sale starts, no impact on end time.
        uint256 current = currentTime();

        // If owner unpauses after sale starts, calculate how to extend end.
        if (current > PHASE1_START_TIME) {
            uint256 timeDelta;

            if (pausedTime < PHASE1_START_TIME) {
                // Pause was triggered before the start time, extend by time that
                // passed from proposed start time until now.
                timeDelta = current.sub(PHASE1_START_TIME);
            } else {
                // Pause was triggered while the sale was already started.
                // Extend end time by amount of time since pause.
                timeDelta = current.sub(pausedTime);
            }

            endTime = endTime.add(timeDelta);
        }

        pausedTime = 0;

        return super.unpause();
    }


    // Allows the admin to move bonus tokens still available in the sale contract
    // out before burning all remaining unsold tokens in burnUnsoldTokens().
    // Used to distribute bonuses to token sale participants when the sale has ended
    // and all bonuses are known.
    function reclaimTokens(uint256 _amount) external onlyAfterSale onlyAdmin returns (bool) {
        uint256 ownBalance = tokenContract.balanceOf(address(this));
        require(_amount <= ownBalance);
        
        address tokenOwner = tokenContract.owner();
        require(tokenOwner != address(0));

        require(tokenContract.transfer(tokenOwner, _amount));

        TokensReclaimed(_amount);

        return true;
    }


    // Allows the admin to burn all unsold tokens in the sale contract.
    function burnUnsoldTokens() external onlyAfterSale onlyAdmin returns (bool) {
        uint256 ownBalance = tokenContract.balanceOf(address(this));

        require(tokenContract.burn(ownBalance));

        UnsoldTokensBurnt(ownBalance);

        return true;
    }


    // Allows the admin to finalize the sale and complete allocations.
    // The SimpleToken.admin also needs to finalize the token contract
    // so that token transfers are enabled.
    function finalize() external onlyAdmin returns (bool) {
        return finalizeInternal();
    }


    // The internal one will be called if tokens are sold out or
    // the end time for the sale is reached, in addition to being called
    // from the public version of finalize().
    function finalizeInternal() private returns (bool) {
        require(!finalized);

        finalized = true;

        Finalized();

        return true;
    }
}