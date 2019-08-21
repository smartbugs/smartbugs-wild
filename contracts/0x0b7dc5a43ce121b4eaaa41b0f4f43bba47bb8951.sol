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

/// @title allows deriving contract to recover any token or ether that it has balance of
/// @notice note that this opens your contracts to claims from various people saying they lost tokens and they want them back
///     be ready to handle such claims
/// @dev use with care!
///     1. ROLE_RECLAIMER is allowed to claim tokens, it's not returning tokens to original owner
///     2. in derived contract that holds any token by design you must override `reclaim` and block such possibility.
///         see ICBMLockedAccount as an example
contract Reclaimable is AccessControlled, AccessRoles {

    ////////////////////////
    // Constants
    ////////////////////////

    IBasicToken constant internal RECLAIM_ETHER = IBasicToken(0x0);

    ////////////////////////
    // Public functions
    ////////////////////////

    function reclaim(IBasicToken token)
        public
        only(ROLE_RECLAIMER)
    {
        address reclaimer = msg.sender;
        if(token == RECLAIM_ETHER) {
            reclaimer.transfer(address(this).balance);
        } else {
            uint256 balance = token.balanceOf(this);
            require(token.transfer(reclaimer, balance));
        }
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

/// @title controls approvals and transfers
/// @dev The token controller contract must implement these functions, see Neumark as example
/// @dev please note that controller may be a separate contract that is called from mOnTransfer and mOnApprove functions
contract MTokenController is MTokenTransferController, MTokenAllowanceController {
}

contract TrustlessTokenController is
    MTokenController
{
    ////////////////////////
    // Internal functions
    ////////////////////////

    //
    // Implements MTokenController
    //

    function mOnTransfer(
        address /*from*/,
        address /*to*/,
        uint256 /*amount*/
    )
        internal
        returns (bool allow)
    {
        return true;
    }

    function mOnApprove(
        address /*owner*/,
        address /*spender*/,
        uint256 /*amount*/
    )
        internal
        returns (bool allow)
    {
        return true;
    }
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

contract IWithdrawableToken {

    ////////////////////////
    // Public functions
    ////////////////////////

    /// @notice withdraws from a token holding assets
    /// @dev amount of asset should be returned to msg.sender and corresponding balance burned
    function withdraw(uint256 amount)
        public;
}

contract EtherToken is
    IsContract,
    IContractId,
    AccessControlled,
    StandardToken,
    TrustlessTokenController,
    IWithdrawableToken,
    TokenMetadata,
    IERC223Token,
    Reclaimable
{
    ////////////////////////
    // Constants
    ////////////////////////

    string private constant NAME = "Ether Token";

    string private constant SYMBOL = "ETH-T";

    uint8 private constant DECIMALS = 18;

    ////////////////////////
    // Events
    ////////////////////////

    event LogDeposit(
        address indexed to,
        uint256 amount
    );

    event LogWithdrawal(
        address indexed from,
        uint256 amount
    );

    event LogWithdrawAndSend(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    ////////////////////////
    // Constructor
    ////////////////////////

    constructor(IAccessPolicy accessPolicy)
        AccessControlled(accessPolicy)
        StandardToken()
        TokenMetadata(NAME, DECIMALS, SYMBOL, "")
        Reclaimable()
        public
    {
    }

    ////////////////////////
    // Public functions
    ////////////////////////

    /// deposit msg.value of Ether to msg.sender balance
    function deposit()
        public
        payable
    {
        depositPrivate();
        emit Transfer(address(0), msg.sender, msg.value);
    }

    /// @notice convenience function to deposit and immediately transfer amount
    /// @param transferTo where to transfer after deposit
    /// @param amount total amount to transfer, must be <= balance after deposit
    /// @param data erc223 data
    /// @dev intended to deposit from simple account and invest in ETO
    function depositAndTransfer(address transferTo, uint256 amount, bytes data)
        public
        payable
    {
        depositPrivate();
        transfer(transferTo, amount, data);
    }

    /// withdraws and sends 'amount' of ether to msg.sender
    function withdraw(uint256 amount)
        public
    {
        withdrawPrivate(amount);
        msg.sender.transfer(amount);
    }

    /// @notice convenience function to withdraw and transfer to external account
    /// @param sendTo address to which send total amount
    /// @param amount total amount to withdraw and send
    /// @dev function is payable and is meant to withdraw funds on accounts balance and token in single transaction
    /// @dev BEWARE that msg.sender of the funds is Ether Token contract and not simple account calling it.
    /// @dev  when sent to smart conctract funds may be lost, so this is prevented below
    function withdrawAndSend(address sendTo, uint256 amount)
        public
        payable
    {
        // must send at least what is in msg.value to being another deposit function
        require(amount >= msg.value, "NF_ET_NO_DEPOSIT");
        if (amount > msg.value) {
            uint256 withdrawRemainder = amount - msg.value;
            withdrawPrivate(withdrawRemainder);
        }
        emit LogWithdrawAndSend(msg.sender, sendTo, amount);
        sendTo.transfer(amount);
    }

    //
    // Implements IERC223Token
    //

    function transfer(address to, uint256 amount, bytes data)
        public
        returns (bool)
    {
        BasicToken.mTransfer(msg.sender, to, amount);

        // Notify the receiving contract.
        if (isContract(to)) {
            // in case of re-entry (1) transfer is done (2) msg.sender is different
            IERC223Callback(to).tokenFallback(msg.sender, amount, data);
        }
        return true;
    }

    //
    // Overrides Reclaimable
    //

    /// @notice allows EtherToken to reclaim tokens wrongly sent to its address
    /// @dev as EtherToken by design has balance of Ether (native Ethereum token)
    ///     such reclamation is not allowed
    function reclaim(IBasicToken token)
        public
    {
        // forbid reclaiming ETH hold in this contract.
        require(token != RECLAIM_ETHER);
        Reclaimable.reclaim(token);
    }

    //
    // Implements IContractId
    //

    function contractId() public pure returns (bytes32 id, uint256 version) {
        return (0x75b86bc24f77738576716a36431588ae768d80d077231d1661c2bea674c6373a, 0);
    }


    ////////////////////////
    // Private functions
    ////////////////////////

    function depositPrivate()
        private
    {
        _balances[msg.sender] = add(_balances[msg.sender], msg.value);
        _totalSupply = add(_totalSupply, msg.value);
        emit LogDeposit(msg.sender, msg.value);
    }

    function withdrawPrivate(uint256 amount)
        private
    {
        require(_balances[msg.sender] >= amount);
        _balances[msg.sender] = sub(_balances[msg.sender], amount);
        _totalSupply = sub(_totalSupply, amount);
        emit LogWithdrawal(msg.sender, amount);
        emit Transfer(msg.sender, address(0), amount);
    }
}