pragma solidity ^0.4.18;




/// note: during any ownership changes all pending operations (waiting for more signatures) are cancelled
// TODO acceptOwnership
contract multiowned {

    // TYPES

    // struct for the status of a pending operation.
    struct MultiOwnedOperationPendingState {
    // count of confirmations needed
    uint yetNeeded;

    // bitmap of confirmations where owner #ownerIndex's decision corresponds to 2**ownerIndex bit
    uint ownersDone;

    // position of this operation key in m_multiOwnedPendingIndex
    uint index;
    }

    // EVENTS

    event Confirmation(address owner, bytes32 operation);
    event Revoke(address owner, bytes32 operation);
    event FinalConfirmation(address owner, bytes32 operation);

    // some others are in the case of an owner changing.
    event OwnerChanged(address oldOwner, address newOwner);
    event OwnerAdded(address newOwner);
    event OwnerRemoved(address oldOwner);

    // the last one is emitted if the required signatures change
    event RequirementChanged(uint newRequirement);

    // MODIFIERS

    // simple single-sig function modifier.
    modifier onlyowner {
        require(isOwner(msg.sender));
        _;
    }
    // multi-sig function modifier: the operation must have an intrinsic hash in order
    // that later attempts can be realised as the same underlying operation and
    // thus count as confirmations.
    modifier onlymanyowners(bytes32 _operation) {
        if (confirmAndCheck(_operation)) {
            _;
        }
        // Even if required number of confirmations has't been collected yet,
        // we can't throw here - because changes to the state have to be preserved.
        // But, confirmAndCheck itself will throw in case sender is not an owner.
    }

    modifier validNumOwners(uint _numOwners) {
        require(_numOwners > 0 && _numOwners <= c_maxOwners);
        _;
    }

    modifier multiOwnedValidRequirement(uint _required, uint _numOwners) {
        require(_required > 0 && _required <= _numOwners);
        _;
    }

    modifier ownerExists(address _address) {
        require(isOwner(_address));
        _;
    }

    modifier ownerDoesNotExist(address _address) {
        require(!isOwner(_address));
        _;
    }

    modifier multiOwnedOperationIsActive(bytes32 _operation) {
        require(isOperationActive(_operation));
        _;
    }

    // METHODS

    // constructor is given number of sigs required to do protected "onlymanyowners" transactions
    // as well as the selection of addresses capable of confirming them (msg.sender is not added to the owners!).
    function multiowned(address[] _owners, uint _required)
    validNumOwners(_owners.length)
    multiOwnedValidRequirement(_required, _owners.length)
    {
        assert(c_maxOwners <= 255);

        m_numOwners = _owners.length;
        m_multiOwnedRequired = _required;

        for (uint i = 0; i < _owners.length; ++i)
        {
            address owner = _owners[i];
            // invalid and duplicate addresses are not allowed
            require(0 != owner && !isOwner(owner) /* not isOwner yet! */);

            uint currentOwnerIndex = checkOwnerIndex(i + 1 /* first slot is unused */);
            m_owners[currentOwnerIndex] = owner;
            m_ownerIndex[owner] = currentOwnerIndex;
        }

        assertOwnersAreConsistent();
    }

    /// @notice replaces an owner `_from` with another `_to`.
    /// @param _from address of owner to replace
    /// @param _to address of new owner
    // All pending operations will be canceled!
    function changeOwner(address _from, address _to)
    external
    ownerExists(_from)
    ownerDoesNotExist(_to)
    onlymanyowners(sha3(msg.data))
    {
        assertOwnersAreConsistent();

        clearPending();
        uint ownerIndex = checkOwnerIndex(m_ownerIndex[_from]);
        m_owners[ownerIndex] = _to;
        m_ownerIndex[_from] = 0;
        m_ownerIndex[_to] = ownerIndex;

        assertOwnersAreConsistent();
        OwnerChanged(_from, _to);
    }

    /// @notice adds an owner
    /// @param _owner address of new owner
    // All pending operations will be canceled!
    function addOwner(address _owner)
    external
    ownerDoesNotExist(_owner)
    validNumOwners(m_numOwners + 1)
    onlymanyowners(sha3(msg.data))
    {
        assertOwnersAreConsistent();

        clearPending();
        m_numOwners++;
        m_owners[m_numOwners] = _owner;
        m_ownerIndex[_owner] = checkOwnerIndex(m_numOwners);

        assertOwnersAreConsistent();
        OwnerAdded(_owner);
    }

    /// @notice removes an owner
    /// @param _owner address of owner to remove
    // All pending operations will be canceled!
    function removeOwner(address _owner)
    external
    ownerExists(_owner)
    validNumOwners(m_numOwners - 1)
    multiOwnedValidRequirement(m_multiOwnedRequired, m_numOwners - 1)
    onlymanyowners(sha3(msg.data))
    {
        assertOwnersAreConsistent();

        clearPending();
        uint ownerIndex = checkOwnerIndex(m_ownerIndex[_owner]);
        m_owners[ownerIndex] = 0;
        m_ownerIndex[_owner] = 0;
        //make sure m_numOwners is equal to the number of owners and always points to the last owner
        reorganizeOwners();

        assertOwnersAreConsistent();
        OwnerRemoved(_owner);
    }

    /// @notice changes the required number of owner signatures
    /// @param _newRequired new number of signatures required
    // All pending operations will be canceled!
    function changeRequirement(uint _newRequired)
    external
    multiOwnedValidRequirement(_newRequired, m_numOwners)
    onlymanyowners(sha3(msg.data))
    {
        m_multiOwnedRequired = _newRequired;
        clearPending();
        RequirementChanged(_newRequired);
    }

    /// @notice Gets an owner by 0-indexed position
    /// @param ownerIndex 0-indexed owner position
    function getOwner(uint ownerIndex) public constant returns (address) {
        return m_owners[ownerIndex + 1];
    }

    /// @notice Gets owners
    /// @return memory array of owners
    function getOwners() public constant returns (address[]) {
        address[] memory result = new address[](m_numOwners);
        for (uint i = 0; i < m_numOwners; i++)
        result[i] = getOwner(i);

        return result;
    }

    /// @notice checks if provided address is an owner address
    /// @param _addr address to check
    /// @return true if it's an owner
    function isOwner(address _addr) public constant returns (bool) {
        return m_ownerIndex[_addr] > 0;
    }

    /// @notice Tests ownership of the current caller.
    /// @return true if it's an owner
    // It's advisable to call it by new owner to make sure that the same erroneous address is not copy-pasted to
    // addOwner/changeOwner and to isOwner.
    function amIOwner() external constant onlyowner returns (bool) {
        return true;
    }

    /// @notice Revokes a prior confirmation of the given operation
    /// @param _operation operation value, typically sha3(msg.data)
    function revoke(bytes32 _operation)
    external
    multiOwnedOperationIsActive(_operation)
    onlyowner
    {
        uint ownerIndexBit = makeOwnerBitmapBit(msg.sender);
        var pending = m_multiOwnedPending[_operation];
        require(pending.ownersDone & ownerIndexBit > 0);

        assertOperationIsConsistent(_operation);

        pending.yetNeeded++;
        pending.ownersDone -= ownerIndexBit;

        assertOperationIsConsistent(_operation);
        Revoke(msg.sender, _operation);
    }

    /// @notice Checks if owner confirmed given operation
    /// @param _operation operation value, typically sha3(msg.data)
    /// @param _owner an owner address
    function hasConfirmed(bytes32 _operation, address _owner)
    external
    constant
    multiOwnedOperationIsActive(_operation)
    ownerExists(_owner)
    returns (bool)
    {
        return !(m_multiOwnedPending[_operation].ownersDone & makeOwnerBitmapBit(_owner) == 0);
    }

    // INTERNAL METHODS

    function confirmAndCheck(bytes32 _operation)
    private
    onlyowner
    returns (bool)
    {
        if (512 == m_multiOwnedPendingIndex.length)
        // In case m_multiOwnedPendingIndex grows too much we have to shrink it: otherwise at some point
        // we won't be able to do it because of block gas limit.
        // Yes, pending confirmations will be lost. Dont see any security or stability implications.
        // TODO use more graceful approach like compact or removal of clearPending completely
        clearPending();

        var pending = m_multiOwnedPending[_operation];

        // if we're not yet working on this operation, switch over and reset the confirmation status.
        if (! isOperationActive(_operation)) {
            // reset count of confirmations needed.
            pending.yetNeeded = m_multiOwnedRequired;
            // reset which owners have confirmed (none) - set our bitmap to 0.
            pending.ownersDone = 0;
            pending.index = m_multiOwnedPendingIndex.length++;
            m_multiOwnedPendingIndex[pending.index] = _operation;
            assertOperationIsConsistent(_operation);
        }

        // determine the bit to set for this owner.
        uint ownerIndexBit = makeOwnerBitmapBit(msg.sender);
        // make sure we (the message sender) haven't confirmed this operation previously.
        if (pending.ownersDone & ownerIndexBit == 0) {
            // ok - check if count is enough to go ahead.
            assert(pending.yetNeeded > 0);
            if (pending.yetNeeded == 1) {
                // enough confirmations: reset and run interior.
                delete m_multiOwnedPendingIndex[m_multiOwnedPending[_operation].index];
                delete m_multiOwnedPending[_operation];
                FinalConfirmation(msg.sender, _operation);
                return true;
            }
            else
            {
                // not enough: record that this owner in particular confirmed.
                pending.yetNeeded--;
                pending.ownersDone |= ownerIndexBit;
                assertOperationIsConsistent(_operation);
                Confirmation(msg.sender, _operation);
            }
        }
    }

    // Reclaims free slots between valid owners in m_owners.
    // TODO given that its called after each removal, it could be simplified.
    function reorganizeOwners() private {
        uint free = 1;
        while (free < m_numOwners)
        {
            // iterating to the first free slot from the beginning
            while (free < m_numOwners && m_owners[free] != 0) free++;

            // iterating to the first occupied slot from the end
            while (m_numOwners > 1 && m_owners[m_numOwners] == 0) m_numOwners--;

            // swap, if possible, so free slot is located at the end after the swap
            if (free < m_numOwners && m_owners[m_numOwners] != 0 && m_owners[free] == 0)
            {
                // owners between swapped slots should't be renumbered - that saves a lot of gas
                m_owners[free] = m_owners[m_numOwners];
                m_ownerIndex[m_owners[free]] = free;
                m_owners[m_numOwners] = 0;
            }
        }
    }

    function clearPending() private onlyowner {
        uint length = m_multiOwnedPendingIndex.length;
        // TODO block gas limit
        for (uint i = 0; i < length; ++i) {
            if (m_multiOwnedPendingIndex[i] != 0)
            delete m_multiOwnedPending[m_multiOwnedPendingIndex[i]];
        }
        delete m_multiOwnedPendingIndex;
    }

    function checkOwnerIndex(uint ownerIndex) private constant returns (uint) {
        assert(0 != ownerIndex && ownerIndex <= c_maxOwners);
        return ownerIndex;
    }

    function makeOwnerBitmapBit(address owner) private constant returns (uint) {
        uint ownerIndex = checkOwnerIndex(m_ownerIndex[owner]);
        return 2 ** ownerIndex;
    }

    function isOperationActive(bytes32 _operation) private constant returns (bool) {
        return 0 != m_multiOwnedPending[_operation].yetNeeded;
    }


    function assertOwnersAreConsistent() private constant {
        assert(m_numOwners > 0);
        assert(m_numOwners <= c_maxOwners);
        assert(m_owners[0] == 0);
        assert(0 != m_multiOwnedRequired && m_multiOwnedRequired <= m_numOwners);
    }

    function assertOperationIsConsistent(bytes32 _operation) private constant {
        var pending = m_multiOwnedPending[_operation];
        assert(0 != pending.yetNeeded);
        assert(m_multiOwnedPendingIndex[pending.index] == _operation);
        assert(pending.yetNeeded <= m_multiOwnedRequired);
    }


    // FIELDS

    uint constant c_maxOwners = 250;

    // the number of owners that must confirm the same operation before it is run.
    uint public m_multiOwnedRequired;


    // pointer used to find a free slot in m_owners
    uint public m_numOwners;

    // list of owners (addresses),
    // slot 0 is unused so there are no owner which index is 0.
    // TODO could we save space at the end of the array for the common case of <10 owners? and should we?
    address[256] internal m_owners;

    // index on the list of owners to allow reverse lookup: owner address => index in m_owners
    mapping(address => uint) internal m_ownerIndex;


    // the ongoing operations.
    mapping(bytes32 => MultiOwnedOperationPendingState) internal m_multiOwnedPending;
    bytes32[] internal m_multiOwnedPendingIndex;
}

/**
 * @title Helps contracts guard agains rentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>
 * @notice If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

    /**
     * @dev We use a single lock for the whole contract.
     */
    bool private rentrancy_lock = false;

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * @notice If you mark a function `nonReentrant`, you should also
     * mark it `external`. Calling one nonReentrant function from
     * another is not supported. Instead, you can implement a
     * `private` function doing the actual work, and a `external`
     * wrapper marked as `nonReentrant`.
     */
    modifier nonReentrant() {
        require(!rentrancy_lock);
        rentrancy_lock = true;
        _;
        rentrancy_lock = false;
    }

}


/**
 * @title Contract which is owned by owners and operated by controller.
 *
 * @notice Provides a way to set up an entity (typically other contract) entitled to control actions of this contract.
 * Controller is set up by owners or during construction.
 *
 * @dev controller check is performed by onlyController modifier.
 */
contract MultiownedControlled is multiowned {

    event ControllerSet(address controller);
    event ControllerRetired(address was);


    modifier onlyController {
        require(msg.sender == m_controller);
        _;
    }


    // PUBLIC interface

    function MultiownedControlled(address[] _owners, uint _signaturesRequired, address _controller)
    multiowned(_owners, _signaturesRequired)
    {
        m_controller = _controller;
        ControllerSet(m_controller);
    }

    /// @dev sets the controller
    function setController(address _controller) external onlymanyowners(sha3(msg.data)) {
        m_controller = _controller;
        ControllerSet(m_controller);
    }

    /// @dev ability for controller to step down
    function detachController() external onlyController {
        address was = m_controller;
        m_controller = address(0);
        ControllerRetired(was);
    }


    // FIELDS

    /// @notice address of entity entitled to mint new tokens
    address public m_controller;
}


/// @title utility methods and modifiers of arguments validation
contract ArgumentsChecker {

    /// @dev check which prevents short address attack
    modifier payloadSizeIs(uint size) {
        require(msg.data.length == size + 4 /* function selector */);
        _;
    }

    /// @dev check that address is valid
    modifier validAddress(address addr) {
        require(addr != address(0));
        _;
    }
}


/// @title registry of funds sent by investors
contract FundsRegistry is ArgumentsChecker, MultiownedControlled, ReentrancyGuard {
    using SafeMath for uint256;

    enum State {
    // gathering funds
    GATHERING,
    // returning funds to investors
    REFUNDING,
    // funds can be pulled by owners
    SUCCEEDED
    }

    event StateChanged(State _state);
    event Invested(address indexed investor, uint256 amount);
    event EtherSent(address indexed to, uint value);
    event RefundSent(address indexed to, uint value);


    modifier requiresState(State _state) {
        require(m_state == _state);
        _;
    }


    // PUBLIC interface

    function FundsRegistry(address[] _owners, uint _signaturesRequired, address _controller)
    MultiownedControlled(_owners, _signaturesRequired, _controller)
    {
    }

    /// @dev performs only allowed state transitions
    function changeState(State _newState)
    external
    onlyController
    {
        assert(m_state != _newState);

        if (State.GATHERING == m_state) {   assert(State.REFUNDING == _newState || State.SUCCEEDED == _newState); }
        else assert(false);

        m_state = _newState;
        StateChanged(m_state);
    }

    /// @dev records an investment
    function invested(address _investor)
    external
    payable
    onlyController
    requiresState(State.GATHERING)
    {
        uint256 amount = msg.value;
        require(0 != amount);
        assert(_investor != m_controller);

        // register investor
        if (0 == m_weiBalances[_investor])
        m_investors.push(_investor);

        // register payment
        totalInvested = totalInvested.add(amount);
        m_weiBalances[_investor] = m_weiBalances[_investor].add(amount);

        Invested(_investor, amount);
    }

    /// @notice owners: send `value` of ether to address `to`, can be called if crowdsale succeeded
    /// @param to where to send ether
    /// @param value amount of wei to send
    function sendEther(address to, uint value)
    external
    validAddress(to)
    onlymanyowners(sha3(msg.data))
    requiresState(State.SUCCEEDED)
    {
        require(value > 0 && this.balance >= value);
        to.transfer(value);
        EtherSent(to, value);
    }

    /// @notice withdraw accumulated balance, called by payee in case crowdsale failed
    function withdrawPayments(address payee)
    external
    nonReentrant
    onlyController
    requiresState(State.REFUNDING)
    {
        uint256 payment = m_weiBalances[payee];

        require(payment != 0);
        require(this.balance >= payment);

        totalInvested = totalInvested.sub(payment);
        m_weiBalances[payee] = 0;

        payee.transfer(payment);
        RefundSent(payee, payment);
    }

    function getInvestorsCount() external constant returns (uint) { return m_investors.length; }


    // FIELDS

    /// @notice total amount of investments in wei
    uint256 public totalInvested;

    /// @notice state of the registry
    State public m_state = State.GATHERING;

    /// @dev balances of investors in wei
    mapping(address => uint256) public m_weiBalances;

    /// @dev list of unique investors
    address[] public m_investors;
}


///123
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
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


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param _owner address The address which owns the funds.
     * @param _spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}



/// @title StandardToken which can be minted by another contract.
contract MintableToken {
    event Mint(address indexed to, uint256 amount);

    /// @dev mints new tokens
    function mint(address _to, uint256 _amount) public;
}



/**
 * MetropolMintableToken
 */
contract MetropolMintableToken is StandardToken, MintableToken {

    event Mint(address indexed to, uint256 amount);

    function mint(address _to, uint256 _amount) public;//todo propose return value

    /**
     * Function to mint tokens
     * Internal for not forgetting to add access modifier
     *
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     *
     * @return A boolean that indicates if the operation was successful.
     */
    function mintInternal(address _to, uint256 _amount) internal returns (bool) {
        require(_amount>0);
        require(_to!=address(0));

        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(address(0), _to, _amount);

        return true;
    }

}

/**
 * Contract which is operated by controller.
 *
 * Provides a way to set up an entity (typically other contract) entitled to control actions of this contract.
 *
 * Controller check is performed by onlyController modifier.
 */
contract Controlled {

    address public m_controller;

    event ControllerSet(address controller);
    event ControllerRetired(address was);


    modifier onlyController {
        require(msg.sender == m_controller);
        _;
    }

    function setController(address _controller) external;

    /**
     * Sets the controller. Internal for not forgetting to add access modifier
     */
    function setControllerInternal(address _controller) internal {
        m_controller = _controller;
        ControllerSet(m_controller);
    }

    /**
     * Ability for controller to step down
     */
    function detachController() external onlyController {
        address was = m_controller;
        m_controller = address(0);
        ControllerRetired(was);
    }
}


/**
 * MintableControlledToken
 */
contract MintableControlledToken is MetropolMintableToken, Controlled {

    /**
     * Function to mint tokens
     *
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     *
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount) public onlyController {
        super.mintInternal(_to, _amount);
    }

}


/**
 * BurnableToken
 */
contract BurnableToken is StandardToken {

    event Burn(address indexed from, uint256 amount);

    function burn(address _from, uint256 _amount) public returns (bool);

    /**
     * Function to burn tokens
     * Internal for not forgetting to add access modifier
     *
     * @param _from The address to burn tokens from.
     * @param _amount The amount of tokens to burn.
     *
     * @return A boolean that indicates if the operation was successful.
     */
    function burnInternal(address _from, uint256 _amount) internal returns (bool) {
        require(_amount>0);
        require(_amount<=balances[_from]);

        totalSupply = totalSupply.sub(_amount);
        balances[_from] = balances[_from].sub(_amount);
        Burn(_from, _amount);
        Transfer(_from, address(0), _amount);

        return true;
    }

}


/**
 * BurnableControlledToken
 */
contract BurnableControlledToken is BurnableToken, Controlled {

    /**
     * Function to burn tokens
     *
     * @param _from The address to burn tokens from.
     * @param _amount The amount of tokens to burn.
     *
     * @return A boolean that indicates if the operation was successful.
     */
    function burn(address _from, uint256 _amount) public onlyController returns (bool) {
        return super.burnInternal(_from, _amount);
    }

}



/**
 * Contract which is owned by owners and operated by controller.
 *
 * Provides a way to set up an entity (typically other contract) entitled to control actions of this contract.
 * Controller is set up by owners or during construction.
 *
 */
contract MetropolMultiownedControlled is Controlled, multiowned {


    function MetropolMultiownedControlled(address[] _owners, uint256 _signaturesRequired)
    multiowned(_owners, _signaturesRequired)
    public
    {
        // nothing here
    }

    /**
     * Sets the controller
     */
    function setController(address _controller) external onlymanyowners(sha3(msg.data)) {
        super.setControllerInternal(_controller);
    }

}



/// @title StandardToken which circulation can be delayed and started by another contract.
/// @dev To be used as a mixin contract.
/// The contract is created in disabled state: circulation is disabled.
contract CirculatingToken is StandardToken {

    event CirculationEnabled();

    modifier requiresCirculation {
        require(m_isCirculating);
        _;
    }


    // PUBLIC interface

    function transfer(address _to, uint256 _value) requiresCirculation returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) requiresCirculation returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) requiresCirculation returns (bool) {
        return super.approve(_spender, _value);
    }


    // INTERNAL functions

    function enableCirculation() internal returns (bool) {
        if (m_isCirculating)
        return false;

        m_isCirculating = true;
        CirculationEnabled();
        return true;
    }


    // FIELDS

    /// @notice are the circulation started?
    bool public m_isCirculating;
}




/**
 * CirculatingControlledToken
 */
contract CirculatingControlledToken is CirculatingToken, Controlled {

    /**
     * Allows token transfers
     */
    function startCirculation() external onlyController {
        assert(enableCirculation());    // must be called once
    }
}



/**
 * MetropolToken
 */
contract MetropolToken is
    StandardToken,
    Controlled,
    MintableControlledToken,
    BurnableControlledToken,
    CirculatingControlledToken,
    MetropolMultiownedControlled
{
    string internal m_name = '';
    string internal m_symbol = '';
    uint8 public constant decimals = 18;

    /**
     * MetropolToken constructor
     */
    function MetropolToken(address[] _owners)
        MetropolMultiownedControlled(_owners, 2)
        public
    {
        require(3 == _owners.length);
    }

    function name() public constant returns (string) {
        return m_name;
    }
    function symbol() public constant returns (string) {
        return m_symbol;
    }

    function setNameSymbol(string _name, string _symbol) external onlymanyowners(sha3(msg.data)) {
        require(bytes(m_name).length==0);
        require(bytes(_name).length!=0 && bytes(_symbol).length!=0);

        m_name = _name;
        m_symbol = _symbol;
    }

}


/////////123
/**
 * @title Basic crowdsale stat
 * @author Eenae
 */
contract ICrowdsaleStat {

    /// @notice amount of funds collected in wei
    function getWeiCollected() public constant returns (uint);

    /// @notice amount of tokens minted (NOT equal to totalSupply() in case token is reused!)
    function getTokenMinted() public constant returns (uint);
}

/**
 * @title Interface for code which processes and stores investments.
 * @author Eenae
 */
contract IInvestmentsWalletConnector {
    /// @dev process and forward investment
    function storeInvestment(address investor, uint payment) internal;

    /// @dev total investments amount stored using storeInvestment()
    function getTotalInvestmentsStored() internal constant returns (uint);

    /// @dev called in case crowdsale succeeded
    function wcOnCrowdsaleSuccess() internal;

    /// @dev called in case crowdsale failed
    function wcOnCrowdsaleFailure() internal;
}


/// @title Base contract for simple crowdsales
contract SimpleCrowdsaleBase is ArgumentsChecker, ReentrancyGuard, IInvestmentsWalletConnector, ICrowdsaleStat {
    using SafeMath for uint256;

    event FundTransfer(address backer, uint amount, bool isContribution);

    function SimpleCrowdsaleBase(address token)
    validAddress(token)
    {
        m_token = MintableToken(token);
    }


    // PUBLIC interface: payments

    // fallback function as a shortcut
    function() payable {
        require(0 == msg.data.length);
        buy();  // only internal call here!
    }

    /// @notice crowdsale participation
    function buy() public payable {     // dont mark as external!
        buyInternal(msg.sender, msg.value, 0);
    }


    // INTERNAL

    /// @dev payment processing
    function buyInternal(address investor, uint payment, uint extraBonuses)
    internal
    nonReentrant
    {
        require(payment >= getMinInvestment());
        require(getCurrentTime() >= getStartTime() || ! mustApplyTimeCheck(investor, payment) /* for final check */);
        if (getCurrentTime() >= getEndTime()) {

            finish();
        }

        if (m_finished) {
            // saving provided gas
            investor.transfer(payment);
            return;
        }

        uint startingWeiCollected = getWeiCollected();
        uint startingInvariant = this.balance.add(startingWeiCollected);

        uint change;
        if (hasHardCap()) {
            // return or update payment if needed
            uint paymentAllowed = getMaximumFunds().sub(getWeiCollected());
            assert(0 != paymentAllowed);

            if (paymentAllowed < payment) {
                change = payment.sub(paymentAllowed);
                payment = paymentAllowed;
            }
        }

        // issue tokens
        uint tokens = calculateTokens(investor, payment, extraBonuses);
        m_token.mint(investor, tokens);
        m_tokensMinted += tokens;

        // record payment
        storeInvestment(investor, payment);
        assert((!hasHardCap() || getWeiCollected() <= getMaximumFunds()) && getWeiCollected() > startingWeiCollected);
        FundTransfer(investor, payment, true);

        if (hasHardCap() && getWeiCollected() == getMaximumFunds())
        finish();

        if (change > 0)
        investor.transfer(change);

        assert(startingInvariant == this.balance.add(getWeiCollected()).add(change));
    }

    function finish() internal {
        if (m_finished)
        return;

        if (getWeiCollected() >= getMinimumFunds())
        wcOnCrowdsaleSuccess();
        else
        wcOnCrowdsaleFailure();

        m_finished = true;
    }


    // Other pluggables

    /// @dev says if crowdsale time bounds must be checked
    function mustApplyTimeCheck(address /*investor*/, uint /*payment*/) constant internal returns (bool) {
        return true;
    }

    /// @notice whether to apply hard cap check logic via getMaximumFunds() method
    function hasHardCap() constant internal returns (bool) {
        return getMaximumFunds() != 0;
    }

    /// @dev to be overridden in tests
    function getCurrentTime() internal constant returns (uint) {
        return now;
    }

    /// @notice maximum investments to be accepted during pre-ICO
    function getMaximumFunds() internal constant returns (uint);

    /// @notice minimum amount of funding to consider crowdsale as successful
    function getMinimumFunds() internal constant returns (uint);

    /// @notice start time of the pre-ICO
    function getStartTime() internal constant returns (uint);

    /// @notice end time of the pre-ICO
    function getEndTime() internal constant returns (uint);

    /// @notice minimal amount of investment
    function getMinInvestment() public constant returns (uint) {
        return 10 finney;
    }

    /// @dev calculates token amount for given investment
    function calculateTokens(address investor, uint payment, uint extraBonuses) internal constant returns (uint);


    // ICrowdsaleStat

    function getWeiCollected() public constant returns (uint) {
        return getTotalInvestmentsStored();
    }

    /// @notice amount of tokens minted (NOT equal to totalSupply() in case token is reused!)
    function getTokenMinted() public constant returns (uint) {
        return m_tokensMinted;
    }


    // FIELDS

    /// @dev contract responsible for token accounting
    MintableToken public m_token;

    uint m_tokensMinted;

    bool m_finished = false;
}


/// @title Stateful mixin add state to contact and handlers for it
contract SimpleStateful {
    enum State { INIT, RUNNING, PAUSED, FAILED, SUCCEEDED }

    event StateChanged(State _state);

    modifier requiresState(State _state) {
        require(m_state == _state);
        _;
    }

    modifier exceptState(State _state) {
        require(m_state != _state);
        _;
    }

    function changeState(State _newState) internal {
        assert(m_state != _newState);

        if (State.INIT == m_state) {
            assert(State.RUNNING == _newState);
        }
        else if (State.RUNNING == m_state) {
            assert(State.PAUSED == _newState || State.FAILED == _newState || State.SUCCEEDED == _newState);
        }
        else if (State.PAUSED == m_state) {
            assert(State.RUNNING == _newState || State.FAILED == _newState);
        }
        else assert(false);

        m_state = _newState;
        StateChanged(m_state);
    }

    function getCurrentState() internal view returns(State) {
        return m_state;
    }

    /// @dev state of sale
    State public m_state = State.INIT;
}



/**
 * Stores investments in FundsRegistry.
 */
contract MetropolFundsRegistryWalletConnector is IInvestmentsWalletConnector {

    function MetropolFundsRegistryWalletConnector(address _fundsAddress)
    public
    {
        require(_fundsAddress!=address(0));
        m_fundsAddress = FundsRegistry(_fundsAddress);
    }

    /// @dev process and forward investment
    function storeInvestment(address investor, uint payment) internal
    {
        m_fundsAddress.invested.value(payment)(investor);
    }

    /// @dev total investments amount stored using storeInvestment()
    function getTotalInvestmentsStored() internal constant returns (uint)
    {
        return m_fundsAddress.totalInvested();
    }

    /// @dev called in case crowdsale succeeded
    function wcOnCrowdsaleSuccess() internal {
        m_fundsAddress.changeState(FundsRegistry.State.SUCCEEDED);
        m_fundsAddress.detachController();
    }

    /// @dev called in case crowdsale failed
    function wcOnCrowdsaleFailure() internal {
        m_fundsAddress.changeState(FundsRegistry.State.REFUNDING);
    }

    /// @notice address of wallet which stores funds
    FundsRegistry public m_fundsAddress;
}


/**
 * Crowdsale with state
 */
contract StatefulReturnableCrowdsale is
SimpleCrowdsaleBase,
SimpleStateful,
multiowned,
MetropolFundsRegistryWalletConnector
{

    /** Last recorded funds */
    uint256 public m_lastFundsAmount;

    event Withdraw(address payee, uint amount);

    /**
     * Automatic check for unaccounted withdrawals
     * @param _investor optional refund parameter
     * @param _payment optional refund parameter
     */
    modifier fundsChecker(address _investor, uint _payment) {
        uint atTheBeginning = getTotalInvestmentsStored();
        if (atTheBeginning < m_lastFundsAmount) {
            changeState(State.PAUSED);
            if (_payment > 0) {
                _investor.transfer(_payment);     // we cant throw (have to save state), so refunding this way
            }
            // note that execution of further (but not preceding!) modifiers and functions ends here
        } else {
            _;

            if (getTotalInvestmentsStored() < atTheBeginning) {
                changeState(State.PAUSED);
            } else {
                m_lastFundsAmount = getTotalInvestmentsStored();
            }
        }
    }

    /**
     * Triggers some state changes based on current time
     */
    modifier timedStateChange() {
        if (getCurrentState() == State.INIT && getCurrentTime() >= getStartTime()) {
            changeState(State.RUNNING);
        }

        _;
    }


    /**
     * Constructor
     */
    function StatefulReturnableCrowdsale(
    address _token,
    address _funds,
    address[] _owners,
    uint _signaturesRequired
    )
    public
    SimpleCrowdsaleBase(_token)
    multiowned(_owners, _signaturesRequired)
    MetropolFundsRegistryWalletConnector(_funds)
    validAddress(_token)
    validAddress(_funds)
    {
    }

    function pauseCrowdsale()
    public
    onlyowner
    requiresState(State.RUNNING)
    {
        changeState(State.PAUSED);
    }
    function continueCrowdsale()
    public
    onlymanyowners(sha3(msg.data))
    requiresState(State.PAUSED)
    {
        changeState(State.RUNNING);

        if (getCurrentTime() >= getEndTime()) {
            finish();
        }
    }
    function failCrowdsale()
    public
    onlymanyowners(sha3(msg.data))
    requiresState(State.PAUSED)
    {
        wcOnCrowdsaleFailure();
        m_finished = true;
    }

    function withdrawPayments()
    public
    nonReentrant
    requiresState(State.FAILED)
    {
        Withdraw(msg.sender, m_fundsAddress.m_weiBalances(msg.sender));
        m_fundsAddress.withdrawPayments(msg.sender);
    }


    /**
     * Additional check of contributing process since we have state
     */
    function buyInternal(address _investor, uint _payment, uint _extraBonuses)
    internal
    timedStateChange
    exceptState(State.PAUSED)
    fundsChecker(_investor, _payment)
    {
        if (!mustApplyTimeCheck(_investor, _payment)) {
            require(State.RUNNING == m_state || State.INIT == m_state);
        }
        else
        {
            require(State.RUNNING == m_state);
        }

        super.buyInternal(_investor, _payment, _extraBonuses);
    }


    /// @dev called in case crowdsale succeeded
    function wcOnCrowdsaleSuccess() internal {
        super.wcOnCrowdsaleSuccess();

        changeState(State.SUCCEEDED);
    }

    /// @dev called in case crowdsale failed
    function wcOnCrowdsaleFailure() internal {
        super.wcOnCrowdsaleFailure();

        changeState(State.FAILED);
    }

}


/**
 * MetropolCrowdsale
 */
contract MetropolCrowdsale is StatefulReturnableCrowdsale {

    uint256 public m_startTimestamp;
    uint256 public m_softCap;
    uint256 public m_hardCap;
    uint256 public m_exchangeRate;
    address public m_foundersTokensStorage;
    bool public m_initialSettingsSet = false;

    modifier requireSettingsSet() {
        require(m_initialSettingsSet);
        _;
    }

    function MetropolCrowdsale(address _token, address _funds, address[] _owners)
        public
        StatefulReturnableCrowdsale(_token, _funds, _owners, 2)
    {
        require(3 == _owners.length);

        //2030-01-01, not to start crowdsale
        m_startTimestamp = 1893456000;
    }

    /**
     * Set exchange rate before start
     */
    function setInitialSettings(
            address _foundersTokensStorage,
            uint256 _startTimestamp,
            uint256 _softCapInEther,
            uint256 _hardCapInEther,
            uint256 _tokensForOneEther
        )
        public
        timedStateChange
        requiresState(State.INIT)
        onlymanyowners(sha3(msg.data))
        validAddress(_foundersTokensStorage)
    {
        //no check for settings set
        //can be set multiple times before ICO

        require(_startTimestamp!=0);
        require(_softCapInEther!=0);
        require(_hardCapInEther!=0);
        require(_tokensForOneEther!=0);

        m_startTimestamp = _startTimestamp;
        m_softCap = _softCapInEther * 1 ether;
        m_hardCap = _hardCapInEther * 1 ether;
        m_exchangeRate = _tokensForOneEther;
        m_foundersTokensStorage = _foundersTokensStorage;

        m_initialSettingsSet = true;
    }

    /**
     * Set exchange rate before start
     */
    function setExchangeRate(uint256 _tokensForOneEther)
        public
        timedStateChange
        requiresState(State.INIT)
        onlymanyowners(sha3(msg.data))
    {
        m_exchangeRate = _tokensForOneEther;
    }

    /**
     * withdraw payments by investor on fail
     */
    function withdrawPayments() public requireSettingsSet {
        getToken().burn(
            msg.sender,
            getToken().balanceOf(msg.sender)
        );

        super.withdrawPayments();
    }


    // INTERNAL
    /**
     * Additional check of initial settings set
     */
    function buyInternal(address _investor, uint _payment, uint _extraBonuses)
        internal
        requireSettingsSet
    {
        super.buyInternal(_investor, _payment, _extraBonuses);
    }


    /**
     * All users except deployer must check time before contributing
     */
    function mustApplyTimeCheck(address investor, uint payment) constant internal returns (bool) {
        return !isOwner(investor);
    }

    /**
     * For min investment check
     */
    function getMinInvestment() public constant returns (uint) {
        return 1 wei;
    }

    /**
     * Get collected funds (internally from FundsRegistry)
     */
    function getWeiCollected() public constant returns (uint) {
        return getTotalInvestmentsStored();
    }

    /**
     * Minimum amount of funding to consider crowdsale as successful
     */
    function getMinimumFunds() internal constant returns (uint) {
        return m_softCap;
    }

    /**
     * Maximum investments to be accepted during crowdsale
     */
    function getMaximumFunds() internal constant returns (uint) {
        return m_hardCap;
    }

    /**
     * Start time of the crowdsale
     */
    function getStartTime() internal constant returns (uint) {
        return m_startTimestamp;
    }

    /**
     * End time of the crowdsale
     */
    function getEndTime() internal constant returns (uint) {
        return m_startTimestamp + 60 days;
    }

    /**
     * Formula for calculating tokens from contributed ether
     */
    function calculateTokens(address /*investor*/, uint payment, uint /*extraBonuses*/)
        internal
        constant
        returns (uint)
    {
        uint256 secondMonth = m_startTimestamp + 30 days;
        if (getCurrentTime() <= secondMonth) {
            return payment.mul(m_exchangeRate);
        } else if (getCurrentTime() <= secondMonth + 1 weeks) {
            return payment.mul(m_exchangeRate).mul(100).div(105);
        } else if (getCurrentTime() <= secondMonth + 2 weeks) {
            return payment.mul(m_exchangeRate).mul(100).div(110);
        } else if (getCurrentTime() <= secondMonth + 3 weeks) {
            return payment.mul(m_exchangeRate).mul(100).div(115);
        } else if (getCurrentTime() <= secondMonth + 4 weeks) {
            return payment.mul(m_exchangeRate).mul(100).div(120);
        } else {
            return payment.mul(m_exchangeRate).mul(100).div(125);
        }
    }

    /**
     * Additional on-success actions
     */
    function wcOnCrowdsaleSuccess() internal {
        super.wcOnCrowdsaleSuccess();

        //20% of total totalSupply to team
        m_token.mint(
            m_foundersTokensStorage,
            getToken().totalSupply().mul(20).div(80)
        );


        getToken().startCirculation();
        getToken().detachController();
    }

    /**
     * Returns attached token
     */
    function getToken() internal returns(MetropolToken) {
        return MetropolToken(m_token);
    }
}