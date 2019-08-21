contract DSFalseFallback {
    function() returns (bool) {
        return false;
    }
}

contract DSTrueFallback {
    function() returns (bool) {
        return true;
    }
}

contract DSAuthModesEnum {
    enum DSAuthModes {
        Owner,
        Authority
    }
}

contract DSAuthUtils is DSAuthModesEnum {
    function setOwner( DSAuthorized what, address owner ) internal {
        what.updateAuthority( owner, DSAuthModes.Owner );
    }
    function setAuthority( DSAuthorized what, DSAuthority authority ) internal {
        what.updateAuthority( authority, DSAuthModes.Authority );
    }
}
contract DSAuthorizedEvents is DSAuthModesEnum {
    event DSAuthUpdate( address indexed auth, DSAuthModes indexed mode );
}


// `DSAuthority` is the interface which `DSAuthorized` (`DSAuth`) contracts expect
// their authority to be when they are in the remote auth mode.
contract DSAuthority {
    // `can_call` will be called with these arguments in the caller's
    // scope if it is coming from an `auth()` call:
    // `DSAuthority(_ds_authority).can_call(msg.sender, address(this), msg.sig);`
    function canCall( address caller
                    , address callee
                    , bytes4 sig )
             constant
             returns (bool);
}


contract AcceptingAuthority is DSTrueFallback {}
contract RejectingAuthority is DSFalseFallback {}

// `DSAuthorized` is a mixin contract which enables standard authorization patterns.
// It has a shorter alias `auth/auth.sol: DSAuth` because it is so common.
contract DSAuthorized is DSAuthModesEnum, DSAuthorizedEvents
{
    // There are two "modes":
    // * "owner mode", where `auth()` simply checks if the sender is `_authority`.
    //   This is the default mode, when `_auth_mode` is false.
    // * "authority mode", where `auth()` makes a call to
    // `DSAuthority(_authority).canCall(sender, this, sig)` to ask if the
    // call should be allowed.
    DSAuthModes  public _auth_mode;
    DSAuthority  public _authority;

    function DSAuthorized() {
        _authority = DSAuthority(msg.sender);
        _auth_mode = DSAuthModes.Owner;
        DSAuthUpdate( msg.sender, DSAuthModes.Owner );
    }

    // Attach the `auth()` modifier to functions to protect them.
    modifier auth() {
        if( isAuthorized() ) {
            _
        } else {
            throw;
        }
    }
    // A version of `auth()` which implicitly returns garbage instead of throwing.
    modifier try_auth() {
        if( isAuthorized() ) {
            _
        }
    }

    // An internal helper function for if you want to use the `auth()` logic
    // someplace other than the modifier (like in a fallback function).
    function isAuthorized() internal returns (bool is_authorized) {
        if( _auth_mode == DSAuthModes.Owner ) {
            return msg.sender == address(_authority);
        }
        if( _auth_mode == DSAuthModes.Authority ) { // use `canCall` in "authority" mode
            return _authority.canCall( msg.sender, address(this), msg.sig );
        }
        throw;
    }

    // This function is used to both transfer the authority and update the mode.
    // Be extra careful about setting *both* correctly every time.
    function updateAuthority( address new_authority, DSAuthModes mode )
             auth()
    {
        _authority = DSAuthority(new_authority);
        _auth_mode = mode;
        DSAuthUpdate( new_authority, mode );
    }
}






contract DSAuth is DSAuthorized {} //, is DSAuthorizedEvents, DSAuthModesEnum
contract DSAuthUser is DSAuthUtils {} //, is DSAuthModesEnum {}

contract DSActionStructUser {
    struct Action {
        address target;
        uint value;
        bytes calldata;
        // bool triggered;
    }
    // todo store call_ret by default?
}
// A base contract used by governance contracts in `gov` and by the generic `DSController`.
contract DSBaseActor is DSActionStructUser {
    // todo gas???
    function tryExec(Action a) internal returns (bool call_ret) {
        return a.target.call.value(a.value)(a.calldata);
    }
    function exec(Action a) internal {
        if(!tryExec(a)) {
            throw;
        }
    }
    function tryExec( address target, bytes calldata, uint value)
             internal
             returns (bool call_ret)
    {
        return target.call.value(value)(calldata);
    }
    function exec( address target, bytes calldata, uint value)
             internal
    {
        if(!tryExec(target, calldata, value)) {
            throw;
        }
    }
}

contract DSEasyMultisigEvents {
    event MemberAdded(address who);
    event Proposed(uint indexed action_id, bytes calldata);
    event Confirmed(uint indexed action_id, address who);
    event Triggered(uint indexed action_id);
}

/* A multisig actor optimized for ease of use.
 * The user never has to pack their own calldata. Instead, use `easyPropose`.
 * This eliminates the need for UI support or helper contracts.
 *
 * To set up the multisig, specify the arguments, then add members
 *
 * First, call the multisig contract itself as if it were your target contract,
 * with the correct calldata. You can make Solidity and web3.js to do this for
 * you very easily by casting the multisig address as the target type.
 * Then, you call `easyPropose` with the missing arguments. This calls `propose`.
 *
 * "last calldata" is "local" to the `msg.sender`. This makes it usable directly
 * from keys (but still not as secure as if it were atomic using a helper contract).
 *
 * In Soldity:
 * 1) `TargetType(address(multisig)).doAction(arg1, arg2);`
 * 2) `multisig.easyPropose(address(target), value);`
 *
 * This is equivalent to `propose(address(my_target), <calldata>, value);`,
 * where calldata is correctly formatted for `TargetType(target).doAction(arg1, arg2)`
 */
contract DSEasyMultisig is DSBaseActor
                         , DSEasyMultisigEvents
                         , DSAuthUser
                         , DSAuth
{
    // How many confirmations an action needs to execute.
    uint _required;
    // How many members this multisig has. Members must be distinct addresses.
    uint _member_count;
    // Auto-locks once this reaches zero - easy setup phase.
    uint _members_remaining;
    // Maximum time between proposal time and trigger time.
    uint _expiration;
    // Action counter
    uint _last_action_id;


    struct action {
        address target;
        bytes calldata;
        uint value;

        uint confirmations; // If this number reaches `required`, you can trigger
        uint expiration; // Last timestamp this action can execute
        bool triggered; // Was this action successfully triggered (multisig does not catch exceptions)
    }

    mapping( uint => action ) actions;

    // action_id -> member -> confirmed
    mapping( uint => mapping( address => bool ) ) confirmations;
    // A record of the last fallback calldata recorded for this sender.
    // This is an easy way to create proposals for most actions.
    mapping( address => bytes ) easy_calldata;
    // Only these addresses can add confirmations
    mapping( address => bool ) is_member;

    function DSEasyMultisig( uint required, uint member_count, uint expiration ) {
        _required = required;
        _member_count = member_count;
        _members_remaining = member_count;
        _expiration = expiration;
    }
    // The authority can add members until they reach `member_count`, and then
    // the contract is finalized (`updateAuthority(0, DSAuthModes.Owner)`),
    // meaning addMember will always throw.
    function addMember( address who ) auth()
    {
        if( is_member[who] ) {
            throw;
        }
        is_member[who] = true;
        MemberAdded(who);
        _members_remaining--;
        if( _members_remaining == 0 ) {
            updateAuthority( address(0x0), DSAuthModes.Owner );
        }
    }
    function isMember( address who ) constant returns (bool) {
        return is_member[who];
    }

    // Some constant getters
    function getInfo()
             constant
             returns ( uint required, uint members, uint expiration, uint last_proposed_action)
    {
        return (_required, _member_count, _expiration, _last_action_id);
    }
    // Public getter for the action mapping doesn't work in web3.js yet
    function getActionStatus(uint action_id)
             constant
             returns (uint confirmations, uint expiration, bool triggered, address target, uint eth_value)
    {
        var a = actions[action_id];
        return (a.confirmations, a.expiration, a.triggered, a.target, a.value);
    }

    // `propose` an action using the calldata from this sender's last call.
    function easyPropose( address target, uint value ) returns (uint action_id) {
        return propose( target, easy_calldata[msg.sender], value );
    }
    function() {
        easy_calldata[msg.sender] = msg.data;
    }

    // Propose an action.
    // Anyone can propose an action.
    // Only members can confirm actions.
    function propose( address target, bytes calldata, uint value )
             returns (uint action_id)
    {
        action memory a;
        a.target = target;
        a.calldata = calldata;
        a.value = value;
        a.expiration = block.timestamp + _expiration;
        // Increment first because, 0 is not a valid ID.
        _last_action_id++;
        actions[_last_action_id] = a;
        Proposed(_last_action_id, calldata);
        return _last_action_id;
    }

    // Attempts to confirm the action.
    // Only members can confirm actions.
    function confirm( uint action_id ) returns (bool confirmed) {
        if( !is_member[msg.sender] ) {
            throw;
        }
        if( confirmations[action_id][msg.sender] ) {
            throw;
        }
        if( action_id > _last_action_id ) {
            throw;
        }
        var a = actions[action_id];
        if( block.timestamp > a.expiration ) {
            throw;
        }
        if( a.triggered ) {
            throw;
        }
        confirmations[action_id][msg.sender] = true;
        a.confirmations = a.confirmations + 1;
        actions[action_id] = a;
        Confirmed(action_id, msg.sender);
    }

    // Attempts to trigger the action.
    // Fails if there are not enough confirmations or if the action has expired.
    function trigger( uint action_id ) {
        var a = actions[action_id];
        if( a.confirmations < _required ) {
            throw;
        }
        if( block.timestamp > a.expiration ) {
            throw;
        }
        if( a.triggered ) {
            throw;
        }
        if( this.balance < a.value ) {
            throw;
        }
        a.triggered = true;
        exec( a.target, a.calldata, a.value );
        actions[action_id] = a;
        Triggered(action_id);
    }
}