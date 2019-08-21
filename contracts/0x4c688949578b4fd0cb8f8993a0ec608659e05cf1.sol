pragma solidity 0.4.15;

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

    function AccessControlled(IAccessPolicy policy) internal {
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
        LogAccessPolicyChanged(msg.sender, oldPolicy, newPolicy);
    }

    function accessPolicy()
        public
        constant
        returns (IAccessPolicy)
    {
        return _accessPolicy;
    }
}

contract AccessRoles {

    ////////////////////////
    // Constants
    ////////////////////////

    // NOTE: All roles are set to the keccak256 hash of the
    // CamelCased role name, i.e.
    // ROLE_LOCKED_ACCOUNT_ADMIN = keccak256("LockedAccountAdmin")

    // may setup LockedAccount, change disbursal mechanism and set migration
    bytes32 internal constant ROLE_LOCKED_ACCOUNT_ADMIN = 0x4675da546d2d92c5b86c4f726a9e61010dce91cccc2491ce6019e78b09d2572e;

    // may setup whitelists and abort whitelisting contract with curve rollback
    bytes32 internal constant ROLE_WHITELIST_ADMIN = 0xaef456e7c864418e1d2a40d996ca4febf3a7e317fe3af5a7ea4dda59033bbe5c;

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
}

contract IBasicToken {

    ////////////////////////
    // Events
    ////////////////////////

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 amount);

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
///         see LockedAccount as an example
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
            reclaimer.transfer(this.balance);
        } else {
            uint256 balance = token.balanceOf(this);
            require(token.transfer(reclaimer, balance));
        }
    }
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

contract EthereumForkArbiter is
    IEthereumForkArbiter,
    AccessControlled,
    AccessRoles,
    Reclaimable
{
    ////////////////////////
    // Mutable state
    ////////////////////////

    string private _nextForkName;

    string private _nextForkUrl;

    uint256 private _nextForkBlockNumber;

    uint256 private _lastSignedBlockNumber;

    bytes32 private _lastSignedBlockHash;

    uint256 private _lastSignedTimestamp;

    ////////////////////////
    // Constructor
    ////////////////////////

    function EthereumForkArbiter(IAccessPolicy accessPolicy)
        AccessControlled(accessPolicy)
        Reclaimable()
        public
    {
    }

    ////////////////////////
    // Public functions
    ////////////////////////

    /// @notice Announce that a particular future Ethereum fork will the one taken by the contract. The contract on the other branch should be considered invalid. Once the fork has happened, it will additionally be confirmed by signing a block on the fork. Notice that forks may happen unannounced.
    function announceFork(
        string name,
        string url,
        uint256 blockNumber
    )
        public
        only(ROLE_PLATFORM_OPERATOR_REPRESENTATIVE)
    {
        require(blockNumber == 0 || blockNumber > block.number);

        // Store announcement
        _nextForkName = name;
        _nextForkUrl = url;
        _nextForkBlockNumber = blockNumber;

        // Log
        LogForkAnnounced(_nextForkName, _nextForkUrl, _nextForkBlockNumber);
    }

    /// @notice Declare that the current fork (as identified by a blockhash) is the valid fork. The valid fork is always the one with the most recent signature.
    function signFork(uint256 number, bytes32 hash)
        public
        only(ROLE_PLATFORM_OPERATOR_REPRESENTATIVE)
    {
        require(block.blockhash(number) == hash);

        // Reset announcement
        delete _nextForkName;
        delete _nextForkUrl;
        delete _nextForkBlockNumber;

        // Store signature
        _lastSignedBlockNumber = number;
        _lastSignedBlockHash = hash;
        _lastSignedTimestamp = block.timestamp;

        // Log
        LogForkSigned(_lastSignedBlockNumber, _lastSignedBlockHash);
    }

    function nextForkName()
        public
        constant
        returns (string)
    {
        return _nextForkName;
    }

    function nextForkUrl()
        public
        constant
        returns (string)
    {
        return _nextForkUrl;
    }

    function nextForkBlockNumber()
        public
        constant
        returns (uint256)
    {
        return _nextForkBlockNumber;
    }

    function lastSignedBlockNumber()
        public
        constant
        returns (uint256)
    {
        return _lastSignedBlockNumber;
    }

    function lastSignedBlockHash()
        public
        constant
        returns (bytes32)
    {
        return _lastSignedBlockHash;
    }

    function lastSignedTimestamp()
        public
        constant
        returns (uint256)
    {
        return _lastSignedTimestamp;
    }
}