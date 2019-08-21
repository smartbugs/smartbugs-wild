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

/// @title access policy based on Access Control Lists concept
/// @dev Allows to assign an address to a set of roles (n:n relation) and querying if such specific assignment exists.
///     This assignment happens in two contexts:
///         - contract context which allows to build a set of local permissions enforced for particular contract
///         - global context which defines set of global permissions that apply to any contract using this RoleBasedAccessPolicy as Access Policy
///     Permissions are cascading as follows
///         - evaluate permission for given subject for given object (local context)
///         - evaluate permission for given subject for all objects (global context)
///         - evaluate permissions for any subject (everyone) for given object (everyone local context)
///         - evaluate permissions for any subject (everyone) for all objects (everyone global context)
///         - if still unset then disallow
///     Permission is cascaded up only if it was evaluated as Unset at particular level. See EVERYONE and GLOBAL definitions for special values (they are 0x0 addresses)
///     RoleBasedAccessPolicy is its own policy. When created, creator has ROLE_ACCESS_CONTROLLER role. Right pattern is to transfer this control to some other (non deployer) account and then destroy deployer private key.
///     See IAccessControlled for definitions of subject, object and role
contract RoleBasedAccessPolicy is
    IAccessPolicy,
    AccessControlled,
    Reclaimable
{

    ////////////////
    // Types
    ////////////////

    // Łukasiewicz logic values
    enum TriState {
        Unset,
        Allow,
        Deny
    }

    ////////////////////////
    // Constants
    ////////////////////////

    IAccessControlled private constant GLOBAL = IAccessControlled(0x0);

    address private constant EVERYONE = 0x0;

    ////////////////////////
    // Mutable state
    ////////////////////////

    /// @dev subject → role → object → allowed
    mapping (address =>
        mapping(bytes32 =>
            mapping(address => TriState))) private _access;

    /// @notice used to enumerate all users assigned to given role in object context
    /// @dev object → role → addresses
    mapping (address =>
        mapping(bytes32 => address[])) private _accessList;

    ////////////////////////
    // Events
    ////////////////////////

    /// @dev logs change of permissions, 'controller' is an address with ROLE_ACCESS_CONTROLLER
    event LogAccessChanged(
        address controller,
        address indexed subject,
        bytes32 role,
        address indexed object,
        TriState oldValue,
        TriState newValue
    );

    event LogAccess(
        address indexed subject,
        bytes32 role,
        address indexed object,
        bytes4 verb,
        bool granted
    );

    ////////////////////////
    // Constructor
    ////////////////////////

    function RoleBasedAccessPolicy()
        AccessControlled(this) // We are our own policy. This is immutable.
        public
    {
        // Issue the local and global AccessContoler role to creator
        _access[msg.sender][ROLE_ACCESS_CONTROLLER][this] = TriState.Allow;
        _access[msg.sender][ROLE_ACCESS_CONTROLLER][GLOBAL] = TriState.Allow;
        // Update enumerator accordingly so those permissions are visible as any other
        updatePermissionEnumerator(msg.sender, ROLE_ACCESS_CONTROLLER, this, TriState.Unset, TriState.Allow);
        updatePermissionEnumerator(msg.sender, ROLE_ACCESS_CONTROLLER, GLOBAL, TriState.Unset, TriState.Allow);
    }

    ////////////////////////
    // Public functions
    ////////////////////////

    // Overrides `AccessControlled.setAccessPolicy(IAccessPolicy,address)`
    function setAccessPolicy(IAccessPolicy, address)
        public
        only(ROLE_ACCESS_CONTROLLER)
    {
        // `RoleBasedAccessPolicy` always controls its
        // own access. Disallow changing this by overriding
        // the `AccessControlled.setAccessPolicy` function.
        revert();
    }

    // Implements `IAccessPolicy.allowed(address, bytes32, address, bytes4)`
    function allowed(
        address subject,
        bytes32 role,
        address object,
        bytes4 verb
    )
        public
        // constant // NOTE: Solidity does not allow subtyping interfaces
        returns (bool)
    {
        bool set = false;
        bool allow = false;
        TriState value = TriState.Unset;

        // Cascade local, global, everyone local, everyone global
        value = _access[subject][role][object];
        set = value != TriState.Unset;
        allow = value == TriState.Allow;
        if (!set) {
            value = _access[subject][role][GLOBAL];
            set = value != TriState.Unset;
            allow = value == TriState.Allow;
        }
        if (!set) {
            value = _access[EVERYONE][role][object];
            set = value != TriState.Unset;
            allow = value == TriState.Allow;
        }
        if (!set) {
            value = _access[EVERYONE][role][GLOBAL];
            set = value != TriState.Unset;
            allow = value == TriState.Allow;
        }
        // If none is set then disallow
        if (!set) {
            allow = false;
        }

        // Log and return
        LogAccess(subject, role, object, verb, allow);
        return allow;
    }

    // Assign a role to a user globally
    function setUserRole(
        address subject,
        bytes32 role,
        IAccessControlled object,
        TriState newValue
    )
        public
        only(ROLE_ACCESS_CONTROLLER)
    {
        setUserRolePrivate(subject, role, object, newValue);
    }

    // Atomically change a set of role assignments
    function setUserRoles(
        address[] subjects,
        bytes32[] roles,
        IAccessControlled[] objects,
        TriState[] newValues
    )
        public
        only(ROLE_ACCESS_CONTROLLER)
    {
        require(subjects.length == roles.length);
        require(subjects.length == objects.length);
        require(subjects.length == newValues.length);
        for(uint256 i = 0; i < subjects.length; ++i) {
            setUserRolePrivate(subjects[i], roles[i], objects[i], newValues[i]);
        }
    }

    function getValue(
        address subject,
        bytes32 role,
        IAccessControlled object
    )
        public
        constant
        returns (TriState)
    {
        return _access[subject][role][object];
    }

    function getUsers(
        IAccessControlled object,
        bytes32 role
    )
        public
        constant
        returns (address[])
    {
        return _accessList[object][role];
    }

    ////////////////////////
    // Private functions
    ////////////////////////

    function setUserRolePrivate(
        address subject,
        bytes32 role,
        IAccessControlled object,
        TriState newValue
    )
        private
    {
        // An access controler is not allowed to revoke his own right on this
        // contract. This prevents access controlers from locking themselves
        // out. We also require the current contract to be its own policy for
        // this to work. This is enforced elsewhere.
        require(role != ROLE_ACCESS_CONTROLLER || subject != msg.sender || object != this);

        // Fetch old value and short-circuit no-ops
        TriState oldValue = _access[subject][role][object];
        if(oldValue == newValue) {
            return;
        }

        // Update the mapping
        _access[subject][role][object] = newValue;

        // Update permission in enumerator
        updatePermissionEnumerator(subject, role, object, oldValue, newValue);

        // Log
        LogAccessChanged(msg.sender, subject, role, object, oldValue, newValue);
    }

    function updatePermissionEnumerator(
        address subject,
        bytes32 role,
        IAccessControlled object,
        TriState oldValue,
        TriState newValue
    )
        private
    {
        // Update the list on add / remove
        address[] storage list = _accessList[object][role];
        // Add new subject only when going form Unset to Allow/Deny
        if(oldValue == TriState.Unset && newValue != TriState.Unset) {
            list.push(subject);
        }
        // Remove subject when unsetting Allow/Deny
        if(oldValue != TriState.Unset && newValue == TriState.Unset) {
            for(uint256 i = 0; i < list.length; ++i) {
                if(list[i] == subject) {
                    // replace unset address with last address in the list, cut list size
                    list[i] = list[list.length - 1];
                    delete list[list.length - 1];
                    list.length -= 1;
                    // there will be no more matches
                    break;
                }
            }
        }
    }
}