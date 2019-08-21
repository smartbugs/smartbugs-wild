pragma solidity 0.4.25;

/// @title provides subject to role checking logic
contract IAccessPolicy {

    ////////////////////////
    // Public functions
    ////////////////////////

    /// @notice We don't make this function constant to allow for state-updating access controls such as rate limiting.
    /// @dev checks if subject belongs to requested role for particular object
    /// @param subject address to be checked against role, typically msg.sender
    /// @param role identifier of required role
    /// @param object contract instance context for role checking, typically contract requesting the check
    /// @param verb additional data, in current AccessControll implementation msg.sig
    /// @return if subject belongs to a role
    function allowed(
        address subject,
        bytes32 role,
        address object,
        bytes4 verb
    )
        public
        returns (bool);
}

/// @title enables access control in implementing contract
/// @dev see AccessControlled for implementation
contract IAccessControlled {

    ////////////////////////
    // Events
    ////////////////////////

    /// @dev must log on access policy change
    event LogAccessPolicyChanged(
        address controller,
        IAccessPolicy oldPolicy,
        IAccessPolicy newPolicy
    );

    ////////////////////////
    // Public functions
    ////////////////////////

    /// @dev allows to change access control mechanism for this contract
    ///     this method must be itself access controlled, see AccessControlled implementation and notice below
    /// @notice it is a huge issue for Solidity that modifiers are not part of function signature
    ///     then interfaces could be used for example to control access semantics
    /// @param newPolicy new access policy to controll this contract
    /// @param newAccessController address of ROLE_ACCESS_CONTROLLER of new policy that can set access to this contract
    function setAccessPolicy(IAccessPolicy newPolicy, address newAccessController)
        public;

    function accessPolicy()
        public
        constant
        returns (IAccessPolicy);

}

contract StandardRoles {

    ////////////////////////
    // Constants
    ////////////////////////

    // @notice Soldity somehow doesn't evaluate this compile time
    // @dev role which has rights to change permissions and set new policy in contract, keccak256("AccessController")
    bytes32 internal constant ROLE_ACCESS_CONTROLLER = 0xac42f8beb17975ed062dcb80c63e6d203ef1c2c335ced149dc5664cc671cb7da;
}

/// @title Granular code execution permissions
/// @notice Intended to replace existing Ownable pattern with more granular permissions set to execute smart contract functions
///     for each function where 'only' modifier is applied, IAccessPolicy implementation is called to evaluate if msg.sender belongs to required role for contract being called.
///     Access evaluation specific belong to IAccessPolicy implementation, see RoleBasedAccessPolicy for details.
/// @dev Should be inherited by a contract requiring such permissions controll. IAccessPolicy must be provided in constructor. Access policy may be replaced to a different one
///     by msg.sender with ROLE_ACCESS_CONTROLLER role
contract AccessControlled is IAccessControlled, StandardRoles {

    ////////////////////////
    // Mutable state
    ////////////////////////

    IAccessPolicy private _accessPolicy;

    ////////////////////////
    // Modifiers
    ////////////////////////

    /// @dev limits function execution only to senders assigned to required 'role'
    modifier only(bytes32 role) {
        require(_accessPolicy.allowed(msg.sender, role, this, msg.sig));
        _;
    }

    ////////////////////////
    // Constructor
    ////////////////////////

    constructor(IAccessPolicy policy) internal {
        require(address(policy) != 0x0);
        _accessPolicy = policy;
    }

    ////////////////////////
    // Public functions
    ////////////////////////

    //
    // Implements IAccessControlled
    //

    function setAccessPolicy(IAccessPolicy newPolicy, address newAccessController)
        public
        only(ROLE_ACCESS_CONTROLLER)
    {
        // ROLE_ACCESS_CONTROLLER must be present
        // under the new policy. This provides some
        // protection against locking yourself out.
        require(newPolicy.allowed(newAccessController, ROLE_ACCESS_CONTROLLER, this, msg.sig));

        // We can now safely set the new policy without foot shooting.
        IAccessPolicy oldPolicy = _accessPolicy;
        _accessPolicy = newPolicy;

        // Log event
        emit LogAccessPolicyChanged(msg.sender, oldPolicy, newPolicy);
    }

    function accessPolicy()
        public
        constant
        returns (IAccessPolicy)
    {
        return _accessPolicy;
    }
}

/// @title standard access roles of the Platform
/// @dev constants are kept in CODE not in STORAGE so they are comparatively cheap
contract AccessRoles {

    ////////////////////////
    // Constants
    ////////////////////////

    // NOTE: All roles are set to the keccak256 hash of the
    // CamelCased role name, i.e.
    // ROLE_LOCKED_ACCOUNT_ADMIN = keccak256("LockedAccountAdmin")

    // May issue (generate) Neumarks
    bytes32 internal constant ROLE_NEUMARK_ISSUER = 0x921c3afa1f1fff707a785f953a1e197bd28c9c50e300424e015953cbf120c06c;

    // May burn Neumarks it owns
    bytes32 internal constant ROLE_NEUMARK_BURNER = 0x19ce331285f41739cd3362a3ec176edffe014311c0f8075834fdd19d6718e69f;

    // May create new snapshots on Neumark
    bytes32 internal constant ROLE_SNAPSHOT_CREATOR = 0x08c1785afc57f933523bc52583a72ce9e19b2241354e04dd86f41f887e3d8174;

    // May enable/disable transfers on Neumark
    bytes32 internal constant ROLE_TRANSFER_ADMIN = 0xb6527e944caca3d151b1f94e49ac5e223142694860743e66164720e034ec9b19;

    // may reclaim tokens/ether from contracts supporting IReclaimable interface
    bytes32 internal constant ROLE_RECLAIMER = 0x0542bbd0c672578966dcc525b30aa16723bb042675554ac5b0362f86b6e97dc5;

    // represents legally platform operator in case of forks and contracts with legal agreement attached. keccak256("PlatformOperatorRepresentative")
    bytes32 internal constant ROLE_PLATFORM_OPERATOR_REPRESENTATIVE = 0xb2b321377653f655206f71514ff9f150d0822d062a5abcf220d549e1da7999f0;

    // allows to deposit EUR-T and allow addresses to send and receive EUR-T. keccak256("EurtDepositManager")
    bytes32 internal constant ROLE_EURT_DEPOSIT_MANAGER = 0x7c8ecdcba80ce87848d16ad77ef57cc196c208fc95c5638e4a48c681a34d4fe7;

    // allows to register identities and change associated claims keccak256("IdentityManager")
    bytes32 internal constant ROLE_IDENTITY_MANAGER = 0x32964e6bc50f2aaab2094a1d311be8bda920fc4fb32b2fb054917bdb153a9e9e;

    // allows to replace controller on euro token and to destroy tokens without withdraw kecckak256("EurtLegalManager")
    bytes32 internal constant ROLE_EURT_LEGAL_MANAGER = 0x4eb6b5806954a48eb5659c9e3982d5e75bfb2913f55199877d877f157bcc5a9b;

    // allows to change known interfaces in universe kecckak256("UniverseManager")
    bytes32 internal constant ROLE_UNIVERSE_MANAGER = 0xe8d8f8f9ea4b19a5a4368dbdace17ad71a69aadeb6250e54c7b4c7b446301738;

    // allows to exchange gas for EUR-T keccak("GasExchange")
    bytes32 internal constant ROLE_GAS_EXCHANGE = 0x9fe43636e0675246c99e96d7abf9f858f518b9442c35166d87f0934abef8a969;

    // allows to set token exchange rates keccak("TokenRateOracle")
    bytes32 internal constant ROLE_TOKEN_RATE_ORACLE = 0xa80c3a0c8a5324136e4c806a778583a2a980f378bdd382921b8d28dcfe965585;
}

contract IEthereumForkArbiter {

    ////////////////////////
    // Events
    ////////////////////////

    event LogForkAnnounced(
        string name,
        string url,
        uint256 blockNumber
    );

    event LogForkSigned(
        uint256 blockNumber,
        bytes32 blockHash
    );

    ////////////////////////
    // Public functions
    ////////////////////////

    function nextForkName()
        public
        constant
        returns (string);

    function nextForkUrl()
        public
        constant
        returns (string);

    function nextForkBlockNumber()
        public
        constant
        returns (uint256);

    function lastSignedBlockNumber()
        public
        constant
        returns (uint256);

    function lastSignedBlockHash()
        public
        constant
        returns (bytes32);

    function lastSignedTimestamp()
        public
        constant
        returns (uint256);

}

/**
 * @title legally binding smart contract
 * @dev General approach to paring legal and smart contracts:
 * 1. All terms and agreement are between two parties: here between smart conctract legal representation and platform investor.
 * 2. Parties are represented by public Ethereum addresses. Platform investor is and address that holds and controls funds and receives and controls Neumark token
 * 3. Legal agreement has immutable part that corresponds to smart contract code and mutable part that may change for example due to changing regulations or other externalities that smart contract does not control.
 * 4. There should be a provision in legal document that future changes in mutable part cannot change terms of immutable part.
 * 5. Immutable part links to corresponding smart contract via its address.
 * 6. Additional provision should be added if smart contract supports it
 *  a. Fork provision
 *  b. Bugfixing provision (unilateral code update mechanism)
 *  c. Migration provision (bilateral code update mechanism)
 *
 * Details on Agreement base class:
 * 1. We bind smart contract to legal contract by storing uri (preferably ipfs or hash) of the legal contract in the smart contract. It is however crucial that such binding is done by smart contract legal representation so transaction establishing the link must be signed by respective wallet ('amendAgreement')
 * 2. Mutable part of agreement may change. We should be able to amend the uri later. Previous amendments should not be lost and should be retrievable (`amendAgreement` and 'pastAgreement' functions).
 * 3. It is up to deriving contract to decide where to put 'acceptAgreement' modifier. However situation where there is no cryptographic proof that given address was really acting in the transaction should be avoided, simplest example being 'to' address in `transfer` function of ERC20.
 *
**/
contract IAgreement {

    ////////////////////////
    // Events
    ////////////////////////

    event LogAgreementAccepted(
        address indexed accepter
    );

    event LogAgreementAmended(
        address contractLegalRepresentative,
        string agreementUri
    );

    /// @dev should have access restrictions so only contractLegalRepresentative may call
    function amendAgreement(string agreementUri) public;

    /// returns information on last amendment of the agreement
    /// @dev MUST revert if no agreements were set
    function currentAgreement()
        public
        constant
        returns
        (
            address contractLegalRepresentative,
            uint256 signedBlockTimestamp,
            string agreementUri,
            uint256 index
        );

    /// returns information on amendment with index
    /// @dev MAY revert on non existing amendment, indexing starts from 0
    function pastAgreement(uint256 amendmentIndex)
        public
        constant
        returns
        (
            address contractLegalRepresentative,
            uint256 signedBlockTimestamp,
            string agreementUri,
            uint256 index
        );

    /// returns the number of block at wchich `signatory` signed agreement
    /// @dev MUST return 0 if not signed
    function agreementSignedAtBlock(address signatory)
        public
        constant
        returns (uint256 blockNo);

    /// returns number of amendments made by contractLegalRepresentative
    function amendmentsCount()
        public
        constant
        returns (uint256);
}

/**
 * @title legally binding smart contract
 * @dev read IAgreement for details
**/
contract Agreement is
    IAgreement,
    AccessControlled,
    AccessRoles
{

    ////////////////////////
    // Type declarations
    ////////////////////////

    /// @notice agreement with signature of the platform operator representative
    struct SignedAgreement {
        address contractLegalRepresentative;
        uint256 signedBlockTimestamp;
        string agreementUri;
    }

    ////////////////////////
    // Immutable state
    ////////////////////////

    IEthereumForkArbiter private ETHEREUM_FORK_ARBITER;

    ////////////////////////
    // Mutable state
    ////////////////////////

    // stores all amendments to the agreement, first amendment is the original
    SignedAgreement[] private _amendments;

    // stores block numbers of all addresses that signed the agreement (signatory => block number)
    mapping(address => uint256) private _signatories;

    ////////////////////////
    // Modifiers
    ////////////////////////

    /// @notice logs that agreement was accepted by platform user
    /// @dev intended to be added to functions that if used make 'accepter' origin to enter legally binding agreement
    modifier acceptAgreement(address accepter) {
        acceptAgreementInternal(accepter);
        _;
    }

    modifier onlyLegalRepresentative(address legalRepresentative) {
        require(mCanAmend(legalRepresentative));
        _;
    }

    ////////////////////////
    // Constructor
    ////////////////////////

    constructor(IAccessPolicy accessPolicy, IEthereumForkArbiter forkArbiter)
        AccessControlled(accessPolicy)
        internal
    {
        require(forkArbiter != IEthereumForkArbiter(0x0));
        ETHEREUM_FORK_ARBITER = forkArbiter;
    }

    ////////////////////////
    // Public functions
    ////////////////////////

    function amendAgreement(string agreementUri)
        public
        onlyLegalRepresentative(msg.sender)
    {
        SignedAgreement memory amendment = SignedAgreement({
            contractLegalRepresentative: msg.sender,
            signedBlockTimestamp: block.timestamp,
            agreementUri: agreementUri
        });
        _amendments.push(amendment);
        emit LogAgreementAmended(msg.sender, agreementUri);
    }

    function ethereumForkArbiter()
        public
        constant
        returns (IEthereumForkArbiter)
    {
        return ETHEREUM_FORK_ARBITER;
    }

    function currentAgreement()
        public
        constant
        returns
        (
            address contractLegalRepresentative,
            uint256 signedBlockTimestamp,
            string agreementUri,
            uint256 index
        )
    {
        require(_amendments.length > 0);
        uint256 last = _amendments.length - 1;
        SignedAgreement storage amendment = _amendments[last];
        return (
            amendment.contractLegalRepresentative,
            amendment.signedBlockTimestamp,
            amendment.agreementUri,
            last
        );
    }

    function pastAgreement(uint256 amendmentIndex)
        public
        constant
        returns
        (
            address contractLegalRepresentative,
            uint256 signedBlockTimestamp,
            string agreementUri,
            uint256 index
        )
    {
        SignedAgreement storage amendment = _amendments[amendmentIndex];
        return (
            amendment.contractLegalRepresentative,
            amendment.signedBlockTimestamp,
            amendment.agreementUri,
            amendmentIndex
        );
    }

    function agreementSignedAtBlock(address signatory)
        public
        constant
        returns (uint256 blockNo)
    {
        return _signatories[signatory];
    }

    function amendmentsCount()
        public
        constant
        returns (uint256)
    {
        return _amendments.length;
    }

    ////////////////////////
    // Internal functions
    ////////////////////////

    /// provides direct access to derived contract
    function acceptAgreementInternal(address accepter)
        internal
    {
        if(_signatories[accepter] == 0) {
            require(_amendments.length > 0);
            _signatories[accepter] = block.number;
            emit LogAgreementAccepted(accepter);
        }
    }

    //
    // MAgreement Internal interface (todo: extract)
    //

    /// default amend permission goes to ROLE_PLATFORM_OPERATOR_REPRESENTATIVE
    function mCanAmend(address legalRepresentative)
        internal
        returns (bool)
    {
        return accessPolicy().allowed(legalRepresentative, ROLE_PLATFORM_OPERATOR_REPRESENTATIVE, this, msg.sig);
    }
}

contract IsContract {

    ////////////////////////
    // Internal functions
    ////////////////////////

    function isContract(address addr)
        internal
        constant
        returns (bool)
    {
        uint256 size;
        // takes 700 gas
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}

contract ITokenMetadata {

    ////////////////////////
    // Public functions
    ////////////////////////

    function symbol()
        public
        constant
        returns (string);

    function name()
        public
        constant
        returns (string);

    function decimals()
        public
        constant
        returns (uint8);
}

/// @title adds token metadata to token contract
/// @dev see Neumark for example implementation
contract TokenMetadata is ITokenMetadata {

    ////////////////////////
    // Immutable state
    ////////////////////////

    // The Token's name: e.g. DigixDAO Tokens
    string private NAME;

    // An identifier: e.g. REP
    string private SYMBOL;

    // Number of decimals of the smallest unit
    uint8 private DECIMALS;

    // An arbitrary versioning scheme
    string private VERSION;

    ////////////////////////
    // Constructor
    ////////////////////////

    /// @notice Constructor to set metadata
    /// @param tokenName Name of the new token
    /// @param decimalUnits Number of decimals of the new token
    /// @param tokenSymbol Token Symbol for the new token
    /// @param version Token version ie. when cloning is used
    constructor(
        string tokenName,
        uint8 decimalUnits,
        string tokenSymbol,
        string version
    )
        public
    {
        NAME = tokenName;                                 // Set the name
        SYMBOL = tokenSymbol;                             // Set the symbol
        DECIMALS = decimalUnits;                          // Set the decimals
        VERSION = version;
    }

    ////////////////////////
    // Public functions
    ////////////////////////

    function name()
        public
        constant
        returns (string)
    {
        return NAME;
    }

    function symbol()
        public
        constant
        returns (string)
    {
        return SYMBOL;
    }

    function decimals()
        public
        constant
        returns (uint8)
    {
        return DECIMALS;
    }

    function version()
        public
        constant
        returns (string)
    {
        return VERSION;
    }
}

contract IBasicToken {

    ////////////////////////
    // Events
    ////////////////////////

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    ////////////////////////
    // Public functions
    ////////////////////////

    /// @dev This function makes it easy to get the total number of tokens
    /// @return The total number of tokens
    function totalSupply()
        public
        constant
        returns (uint256);

    /// @param owner The address that's balance is being requested
    /// @return The balance of `owner` at the current block
    function balanceOf(address owner)
        public
        constant
        returns (uint256 balance);

    /// @notice Send `amount` tokens to `to` from `msg.sender`
    /// @param to The address of the recipient
    /// @param amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address to, uint256 amount)
        public
        returns (bool success);

}

contract IERC20Allowance {

    ////////////////////////
    // Events
    ////////////////////////

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    ////////////////////////
    // Public functions
    ////////////////////////

    /// @dev This function makes it easy to read the `allowed[]` map
    /// @param owner The address of the account that owns the token
    /// @param spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens of owner that spender is allowed
    ///  to spend
    function allowance(address owner, address spender)
        public
        constant
        returns (uint256 remaining);

    /// @notice `msg.sender` approves `spender` to spend `amount` tokens on
    ///  its behalf. This is a modified version of the ERC20 approve function
    ///  to be a little bit safer
    /// @param spender The address of the account able to transfer the tokens
    /// @param amount The amount of tokens to be approved for transfer
    /// @return True if the approval was successful
    function approve(address spender, uint256 amount)
        public
        returns (bool success);

    /// @notice Send `amount` tokens to `to` from `from` on the condition it
    ///  is approved by `from`
    /// @param from The address holding the tokens being transferred
    /// @param to The address of the recipient
    /// @param amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function transferFrom(address from, address to, uint256 amount)
        public
        returns (bool success);

}

contract IERC20Token is IBasicToken, IERC20Allowance {

}

contract IERC677Callback {

    ////////////////////////
    // Public functions
    ////////////////////////

    // NOTE: This call can be initiated by anyone. You need to make sure that
    // it is send by the token (`require(msg.sender == token)`) or make sure
    // amount is valid (`require(token.allowance(this) >= amount)`).
    function receiveApproval(
        address from,
        uint256 amount,
        address token, // IERC667Token
        bytes data
    )
        public
        returns (bool success);

}

contract IERC677Allowance is IERC20Allowance {

    ////////////////////////
    // Public functions
    ////////////////////////

    /// @notice `msg.sender` approves `spender` to send `amount` tokens on
    ///  its behalf, and then a function is triggered in the contract that is
    ///  being approved, `spender`. This allows users to use their tokens to
    ///  interact with contracts in one function call instead of two
    /// @param spender The address of the contract able to transfer the tokens
    /// @param amount The amount of tokens to be approved for transfer
    /// @return True if the function call was successful
    function approveAndCall(address spender, uint256 amount, bytes extraData)
        public
        returns (bool success);

}

contract IERC677Token is IERC20Token, IERC677Allowance {
}

contract Math {

    ////////////////////////
    // Internal functions
    ////////////////////////

    // absolute difference: |v1 - v2|
    function absDiff(uint256 v1, uint256 v2)
        internal
        pure
        returns(uint256)
    {
        return v1 > v2 ? v1 - v2 : v2 - v1;
    }

    // divide v by d, round up if remainder is 0.5 or more
    function divRound(uint256 v, uint256 d)
        internal
        pure
        returns(uint256)
    {
        return add(v, d/2) / d;
    }

    // computes decimal decimalFraction 'frac' of 'amount' with maximum precision (multiplication first)
    // both amount and decimalFraction must have 18 decimals precision, frac 10**18 represents a whole (100% of) amount
    // mind loss of precision as decimal fractions do not have finite binary expansion
    // do not use instead of division
    function decimalFraction(uint256 amount, uint256 frac)
        internal
        pure
        returns(uint256)
    {
        // it's like 1 ether is 100% proportion
        return proportion(amount, frac, 10**18);
    }

    // computes part/total of amount with maximum precision (multiplication first)
    // part and total must have the same units
    function proportion(uint256 amount, uint256 part, uint256 total)
        internal
        pure
        returns(uint256)
    {
        return divRound(mul(amount, part), total);
    }

    //
    // Open Zeppelin Math library below
    //

    function mul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    function min(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return a < b ? a : b;
    }

    function max(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        return a > b ? a : b;
    }
}

/// @title internal token transfer function
/// @dev see BasicSnapshotToken for implementation
contract MTokenTransfer {

    ////////////////////////
    // Internal functions
    ////////////////////////

    /// @dev This is the actual transfer function in the token contract, it can
    ///  only be called by other functions in this contract.
    /// @param from The address holding the tokens being transferred
    /// @param to The address of the recipient
    /// @param amount The amount of tokens to be transferred
    /// @dev  reverts if transfer was not successful
    function mTransfer(
        address from,
        address to,
        uint256 amount
    )
        internal;
}

/// @title controls token transfers
/// @dev BasicSnapshotToken observes this interface, Neumark contract implements it
contract MTokenTransferController {

    ////////////////////////
    // Internal functions
    ////////////////////////

    /// @notice Notifies the controller about a token transfer allowing the
    ///  controller to react if desired
    /// @param from The origin of the transfer
    /// @param to The destination of the transfer
    /// @param amount The amount of the transfer
    /// @return False if the controller does not authorize the transfer
    function mOnTransfer(
        address from,
        address to,
        uint256 amount
    )
        internal
        returns (bool allow);

}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is
    MTokenTransfer,
    MTokenTransferController,
    IBasicToken,
    Math
{

    ////////////////////////
    // Mutable state
    ////////////////////////

    mapping(address => uint256) internal _balances;

    uint256 internal _totalSupply;

    ////////////////////////
    // Public functions
    ////////////////////////

    /**
    * @dev transfer token for a specified address
    * @param to The address to transfer to.
    * @param amount The amount to be transferred.
    */
    function transfer(address to, uint256 amount)
        public
        returns (bool)
    {
        mTransfer(msg.sender, to, amount);
        return true;
    }

    /// @dev This function makes it easy to get the total number of tokens
    /// @return The total number of tokens
    function totalSupply()
        public
        constant
        returns (uint256)
    {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner)
        public
        constant
        returns (uint256 balance)
    {
        return _balances[owner];
    }

    ////////////////////////
    // Internal functions
    ////////////////////////

    //
    // Implements MTokenTransfer
    //

    function mTransfer(address from, address to, uint256 amount)
        internal
    {
        require(to != address(0));
        require(mOnTransfer(from, to, amount));

        _balances[from] = sub(_balances[from], amount);
        _balances[to] = add(_balances[to], amount);
        emit Transfer(from, to, amount);
    }
}

/// @title controls spending approvals
/// @dev TokenAllowance observes this interface, Neumark contract implements it
contract MTokenAllowanceController {

    ////////////////////////
    // Internal functions
    ////////////////////////

    /// @notice Notifies the controller about an approval allowing the
    ///  controller to react if desired
    /// @param owner The address that calls `approve()`
    /// @param spender The spender in the `approve()` call
    /// @param amount The amount in the `approve()` call
    /// @return False if the controller does not authorize the approval
    function mOnApprove(
        address owner,
        address spender,
        uint256 amount
    )
        internal
        returns (bool allow);

    /// @notice Allows to override allowance approved by the owner
    ///         Primary role is to enable forced transfers, do not override if you do not like it
    ///         Following behavior is expected in the observer
    ///         approve() - should revert if mAllowanceOverride() > 0
    ///         allowance() - should return mAllowanceOverride() if set
    ///         transferFrom() - should override allowance if mAllowanceOverride() > 0
    /// @param owner An address giving allowance to spender
    /// @param spender An address getting  a right to transfer allowance amount from the owner
    /// @return current allowance amount
    function mAllowanceOverride(
        address owner,
        address spender
    )
        internal
        constant
        returns (uint256 allowance);
}

/// @title token spending approval and transfer
/// @dev implements token approval and transfers and exposes relevant part of ERC20 and ERC677 approveAndCall
///     may be mixed in with any basic token (implementing mTransfer) like BasicSnapshotToken or MintableSnapshotToken to add approval mechanism
///     observes MTokenAllowanceController interface
///     observes MTokenTransfer
contract TokenAllowance is
    MTokenTransfer,
    MTokenAllowanceController,
    IERC20Allowance,
    IERC677Token
{

    ////////////////////////
    // Mutable state
    ////////////////////////

    // `allowed` tracks rights to spends others tokens as per ERC20
    // owner => spender => amount
    mapping (address => mapping (address => uint256)) private _allowed;

    ////////////////////////
    // Constructor
    ////////////////////////

    constructor()
        internal
    {
    }

    ////////////////////////
    // Public functions
    ////////////////////////

    //
    // Implements IERC20Token
    //

    /// @dev This function makes it easy to read the `allowed[]` map
    /// @param owner The address of the account that owns the token
    /// @param spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens of _owner that _spender is allowed
    ///  to spend
    function allowance(address owner, address spender)
        public
        constant
        returns (uint256 remaining)
    {
        uint256 override = mAllowanceOverride(owner, spender);
        if (override > 0) {
            return override;
        }
        return _allowed[owner][spender];
    }

    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
    ///  its behalf. This is a modified version of the ERC20 approve function
    ///  where allowance per spender must be 0 to allow change of such allowance
    /// @param spender The address of the account able to transfer the tokens
    /// @param amount The amount of tokens to be approved for transfer
    /// @return True or reverts, False is never returned
    function approve(address spender, uint256 amount)
        public
        returns (bool success)
    {
        // Alerts the token controller of the approve function call
        require(mOnApprove(msg.sender, spender, amount));

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender,0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((amount == 0 || _allowed[msg.sender][spender] == 0) && mAllowanceOverride(msg.sender, spender) == 0);

        _allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    ///  is approved by `_from`
    /// @param from The address holding the tokens being transferred
    /// @param to The address of the recipient
    /// @param amount The amount of tokens to be transferred
    /// @return True if the transfer was successful, reverts in any other case
    function transferFrom(address from, address to, uint256 amount)
        public
        returns (bool success)
    {
        uint256 allowed = mAllowanceOverride(from, msg.sender);
        if (allowed == 0) {
            // The standard ERC 20 transferFrom functionality
            allowed = _allowed[from][msg.sender];
            // yes this will underflow but then we'll revert. will cost gas however so don't underflow
            _allowed[from][msg.sender] -= amount;
        }
        require(allowed >= amount);
        mTransfer(from, to, amount);
        return true;
    }

    //
    // Implements IERC677Token
    //

    /// @notice `msg.sender` approves `_spender` to send `_amount` tokens on
    ///  its behalf, and then a function is triggered in the contract that is
    ///  being approved, `_spender`. This allows users to use their tokens to
    ///  interact with contracts in one function call instead of two
    /// @param spender The address of the contract able to transfer the tokens
    /// @param amount The amount of tokens to be approved for transfer
    /// @return True or reverts, False is never returned
    function approveAndCall(
        address spender,
        uint256 amount,
        bytes extraData
    )
        public
        returns (bool success)
    {
        require(approve(spender, amount));

        success = IERC677Callback(spender).receiveApproval(
            msg.sender,
            amount,
            this,
            extraData
        );
        require(success);

        return true;
    }

    ////////////////////////
    // Internal functions
    ////////////////////////

    //
    // Implements default MTokenAllowanceController
    //

    // no override in default implementation
    function mAllowanceOverride(
        address /*owner*/,
        address /*spender*/
    )
        internal
        constant
        returns (uint256)
    {
        return 0;
    }
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 */
contract StandardToken is
    IERC20Token,
    BasicToken,
    TokenAllowance
{

}

/// @title uniquely identifies deployable (non-abstract) platform contract
/// @notice cheap way of assigning implementations to knownInterfaces which represent system services
///         unfortunatelly ERC165 does not include full public interface (ABI) and does not provide way to list implemented interfaces
///         EIP820 still in the making
/// @dev ids are generated as follows keccak256("neufund-platform:<contract name>")
///      ids roughly correspond to ABIs
contract IContractId {
    /// @param id defined as above
    /// @param version implementation version
    function contractId() public pure returns (bytes32 id, uint256 version);
}

/// @title current ERC223 fallback function
/// @dev to be used in all future token contract
/// @dev NEU and ICBMEtherToken (obsolete) are the only contracts that still uses IERC223LegacyCallback
contract IERC223Callback {

    ////////////////////////
    // Public functions
    ////////////////////////

    function tokenFallback(address from, uint256 amount, bytes data)
        public;

}

contract IERC223Token is IERC20Token, ITokenMetadata {

    /// @dev Departure: We do not log data, it has no advantage over a standard
    ///     log event. By sticking to the standard log event we
    ///     stay compatible with constracts that expect and ERC20 token.

    // event Transfer(
    //    address indexed from,
    //    address indexed to,
    //    uint256 amount,
    //    bytes data);


    /// @dev Departure: We do not use the callback on regular transfer calls to
    ///     stay compatible with constracts that expect and ERC20 token.

    // function transfer(address to, uint256 amount)
    //     public
    //     returns (bool);

    ////////////////////////
    // Public functions
    ////////////////////////

    function transfer(address to, uint256 amount, bytes data)
        public
        returns (bool);
}

/// @title granular token controller based on MSnapshotToken observer pattern
contract ITokenController {

    ////////////////////////
    // Public functions
    ////////////////////////

    /// @notice see MTokenTransferController
    /// @dev additionally passes broker that is executing transaction between from and to
    ///      for unbrokered transfer, broker == from
    function onTransfer(address broker, address from, address to, uint256 amount)
        public
        constant
        returns (bool allow);

    /// @notice see MTokenAllowanceController
    function onApprove(address owner, address spender, uint256 amount)
        public
        constant
        returns (bool allow);

    /// @notice see MTokenMint
    function onGenerateTokens(address sender, address owner, uint256 amount)
        public
        constant
        returns (bool allow);

    /// @notice see MTokenMint
    function onDestroyTokens(address sender, address owner, uint256 amount)
        public
        constant
        returns (bool allow);

    /// @notice controls if sender can change controller to newController
    /// @dev for this to succeed TYPICALLY current controller must be already migrated to a new one
    function onChangeTokenController(address sender, address newController)
        public
        constant
        returns (bool);

    /// @notice overrides spender allowance
    /// @dev may be used to implemented forced transfers in which token controller may override approved allowance
    ///      with any > 0 value and then use transferFrom to execute such transfer
    ///      This by definition creates non-trustless token so do not implement this call if you do not need trustless transfers!
    ///      Implementer should not allow approve() to be executed if there is an overrride
    //       Implemented should return allowance() taking into account override
    function onAllowance(address owner, address spender)
        public
        constant
        returns (uint256 allowanceOverride);
}

/// @title hooks token controller to token contract and allows to replace it
contract ITokenControllerHook {

    ////////////////////////
    // Events
    ////////////////////////

    event LogChangeTokenController(
        address oldController,
        address newController,
        address by
    );

    ////////////////////////
    // Public functions
    ////////////////////////

    /// @notice replace current token controller
    /// @dev please note that this process is also controlled by existing controller
    function changeTokenController(address newController)
        public;

    /// @notice returns current controller
    function tokenController()
        public
        constant
        returns (address currentController);

}

contract IWithdrawableToken {

    ////////////////////////
    // Public functions
    ////////////////////////

    /// @notice withdraws from a token holding assets
    /// @dev amount of asset should be returned to msg.sender and corresponding balance burned
    function withdraw(uint256 amount)
        public;
}

contract EuroToken is
    Agreement,
    IERC677Token,
    StandardToken,
    IWithdrawableToken,
    ITokenControllerHook,
    TokenMetadata,
    IERC223Token,
    IsContract,
    IContractId
{
    ////////////////////////
    // Constants
    ////////////////////////

    string private constant NAME = "Euro Token";

    string private constant SYMBOL = "EUR-T";

    uint8 private constant DECIMALS = 18;

    ////////////////////////
    // Mutable state
    ////////////////////////

    ITokenController private _tokenController;

    ////////////////////////
    // Events
    ////////////////////////

    /// on each deposit (increase of supply) of EUR-T
    /// 'by' indicates account that executed the deposit function for 'to' (typically bank connector)
    event LogDeposit(
        address indexed to,
        address by,
        uint256 amount,
        bytes32 reference
    );

    // proof of requested deposit initiated by token holder
    event LogWithdrawal(
        address indexed from,
        uint256 amount
    );

    // proof of settled deposit
    event LogWithdrawSettled(
        address from,
        address by, // who settled
        uint256 amount, // settled amount, after fees, negative interest rates etc.
        uint256 originalAmount, // original amount withdrawn
        bytes32 withdrawTxHash, // hash of withdraw transaction
        bytes32 reference // reference number of withdraw operation at deposit manager
    );

    /// on destroying the tokens without withdraw (see `destroyTokens` function below)
    event LogDestroy(
        address indexed from,
        address by,
        uint256 amount
    );

    ////////////////////////
    // Modifiers
    ////////////////////////

    modifier onlyIfDepositAllowed(address to, uint256 amount) {
        require(_tokenController.onGenerateTokens(msg.sender, to, amount));
        _;
    }

    modifier onlyIfWithdrawAllowed(address from, uint256 amount) {
        require(_tokenController.onDestroyTokens(msg.sender, from, amount));
        _;
    }

    ////////////////////////
    // Constructor
    ////////////////////////

    constructor(
        IAccessPolicy accessPolicy,
        IEthereumForkArbiter forkArbiter,
        ITokenController tokenController
    )
        Agreement(accessPolicy, forkArbiter)
        StandardToken()
        TokenMetadata(NAME, DECIMALS, SYMBOL, "")
        public
    {
        require(tokenController != ITokenController(0x0));
        _tokenController = tokenController;
    }

    ////////////////////////
    // Public functions
    ////////////////////////

    /// @notice deposit 'amount' of EUR-T to address 'to', attaching correlating `reference` to LogDeposit event
    /// @dev deposit may happen only in case 'to' can receive transfer in token controller
    ///     by default KYC is required to receive deposits
    function deposit(address to, uint256 amount, bytes32 reference)
        public
        only(ROLE_EURT_DEPOSIT_MANAGER)
        onlyIfDepositAllowed(to, amount)
        acceptAgreement(to)
    {
        require(to != address(0));
        _balances[to] = add(_balances[to], amount);
        _totalSupply = add(_totalSupply, amount);
        emit LogDeposit(to, msg.sender, amount, reference);
        emit Transfer(address(0), to, amount);
    }

    /// @notice runs many deposits within one transaction
    /// @dev deposit may happen only in case 'to' can receive transfer in token controller
    ///     by default KYC is required to receive deposits
    function depositMany(address[] to, uint256[] amount, bytes32[] reference)
        public
    {
        require(to.length == amount.length);
        require(to.length == reference.length);
        for (uint256 i = 0; i < to.length; i++) {
            deposit(to[i], amount[i], reference[i]);
        }
    }

    /// @notice withdraws 'amount' of EUR-T by burning required amount and providing a proof of whithdrawal
    /// @dev proof is provided in form of log entry. based on that proof deposit manager will make a bank transfer
    ///     by default controller will check the following: KYC and existence of working bank account
    function withdraw(uint256 amount)
        public
        onlyIfWithdrawAllowed(msg.sender, amount)
        acceptAgreement(msg.sender)
    {
        destroyTokensPrivate(msg.sender, amount);
        emit LogWithdrawal(msg.sender, amount);
    }

    /// @notice issued by deposit manager when withdraw request was settled. typicaly amount that could be settled will be lower
    ///         than amount withdrawn: banks charge negative interest rates and various fees that must be deduced
    ///         reference number is attached that may be used to identify withdraw operation at deposit manager
    function settleWithdraw(address from, uint256 amount, uint256 originalAmount, bytes32 withdrawTxHash, bytes32 reference)
        public
        only(ROLE_EURT_DEPOSIT_MANAGER)
    {
        emit LogWithdrawSettled(from, msg.sender, amount, originalAmount, withdrawTxHash, reference);
    }

    /// @notice this method allows to destroy EUR-T belonging to any account
    ///     note that EURO is fiat currency and is not trustless, EUR-T is also
    ///     just internal currency of Neufund platform, not general purpose stable coin
    ///     we need to be able to destroy EUR-T if ordered by authorities
    function destroy(address owner, uint256 amount)
        public
        only(ROLE_EURT_LEGAL_MANAGER)
    {
        destroyTokensPrivate(owner, amount);
        emit LogDestroy(owner, msg.sender, amount);
    }

    //
    // Implements ITokenControllerHook
    //

    function changeTokenController(address newController)
        public
    {
        require(_tokenController.onChangeTokenController(msg.sender, newController));
        _tokenController = ITokenController(newController);
        emit LogChangeTokenController(_tokenController, newController, msg.sender);
    }

    function tokenController()
        public
        constant
        returns (address)
    {
        return _tokenController;
    }

    //
    // Implements IERC223Token
    //
    function transfer(address to, uint256 amount, bytes data)
        public
        returns (bool success)
    {
        return ierc223TransferInternal(msg.sender, to, amount, data);
    }

    /// @notice convenience function to deposit and immediately transfer amount
    /// @param depositTo which account to deposit to and then transfer from
    /// @param transferTo where to transfer after deposit
    /// @param depositAmount amount to deposit
    /// @param transferAmount total amount to transfer, must be <= balance after deposit
    /// @dev intended to deposit from bank account and invest in ETO
    function depositAndTransfer(
        address depositTo,
        address transferTo,
        uint256 depositAmount,
        uint256 transferAmount,
        bytes data,
        bytes32 reference
    )
        public
        returns (bool success)
    {
        deposit(depositTo, depositAmount, reference);
        return ierc223TransferInternal(depositTo, transferTo, transferAmount, data);
    }

    //
    // Implements IContractId
    //

    function contractId() public pure returns (bytes32 id, uint256 version) {
        return (0xfb5c7e43558c4f3f5a2d87885881c9b10ff4be37e3308579c178bf4eaa2c29cd, 0);
    }

    ////////////////////////
    // Internal functions
    ////////////////////////

    //
    // Implements MTokenController
    //

    function mOnTransfer(
        address from,
        address to,
        uint256 amount
    )
        internal
        acceptAgreement(from)
        returns (bool allow)
    {
        address broker = msg.sender;
        if (broker != from) {
            // if called by the depositor (deposit and send), ignore the broker flag
            bool isDepositor = accessPolicy().allowed(msg.sender, ROLE_EURT_DEPOSIT_MANAGER, this, msg.sig);
            // this is not very clean but alternative (give brokerage rights to all depositors) is maintenance hell
            if (isDepositor) {
                broker = from;
            }
        }
        return _tokenController.onTransfer(broker, from, to, amount);
    }

    function mOnApprove(
        address owner,
        address spender,
        uint256 amount
    )
        internal
        acceptAgreement(owner)
        returns (bool allow)
    {
        return _tokenController.onApprove(owner, spender, amount);
    }

    function mAllowanceOverride(
        address owner,
        address spender
    )
        internal
        constant
        returns (uint256)
    {
        return _tokenController.onAllowance(owner, spender);
    }

    //
    // Observes MAgreement internal interface
    //

    /// @notice euro token is legally represented by separate entity ROLE_EURT_LEGAL_MANAGER
    function mCanAmend(address legalRepresentative)
        internal
        returns (bool)
    {
        return accessPolicy().allowed(legalRepresentative, ROLE_EURT_LEGAL_MANAGER, this, msg.sig);
    }

    ////////////////////////
    // Private functions
    ////////////////////////

    function destroyTokensPrivate(address owner, uint256 amount)
        private
    {
        require(_balances[owner] >= amount);
        _balances[owner] = sub(_balances[owner], amount);
        _totalSupply = sub(_totalSupply, amount);
        emit Transfer(owner, address(0), amount);
    }

    /// @notice internal transfer function that checks permissions and calls the tokenFallback
    function ierc223TransferInternal(address from, address to, uint256 amount, bytes data)
        private
        returns (bool success)
    {
        BasicToken.mTransfer(from, to, amount);

        // Notify the receiving contract.
        if (isContract(to)) {
            // in case of re-entry (1) transfer is done (2) msg.sender is different
            IERC223Callback(to).tokenFallback(from, amount, data);
        }
        return true;
    }
}