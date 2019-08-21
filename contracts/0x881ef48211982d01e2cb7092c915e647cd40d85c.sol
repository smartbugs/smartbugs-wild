pragma solidity ^0.4.11;

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
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    uint256 public totalSupply;

    function balanceOf(address who) public constant returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public constant returns (uint256);

    function transferFrom(address from, address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping (address => uint256) balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));

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
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

}

/**
 * @title Shareable
 * @dev inheritable "property" contract that enables methods to be protected by requiring the
 * acquiescence of either a single, or, crucially, each of a number of, designated owners.
 * @dev Usage: use modifiers onlyOwner (just own owned) or onlyManyOwners(hash), whereby the same hash must be provided by some number (specified in constructor) of the set of owners (specified in the constructor) before the interior is executed.
 */
contract Shareable {

    event Confirmation(address owner, bytes32 operation);
    event Revoke(address owner, bytes32 operation);
    event RequirementChange(uint required);
    event OwnerAddition(address indexed owner);
    event OwnerRemoval(address indexed owner);

    // struct for the status of a pending operation.
    struct PendingState {
        uint256 index;
        uint256 yetNeeded;
        mapping (address => bool) ownersDone;
    }

    // the number of owners that must confirm the same operation before it is run.
    uint256 public required;

    // list of owners by index
    address[] owners;

    // hash table of owners by address
    mapping (address => bool) internal isOwner;

    // the ongoing operations.
    mapping (bytes32 => PendingState) internal pendings;

    // the ongoing operations by index
    bytes32[] internal pendingsIndex;

    /**
     * @dev Throws if address is null.
     * @param _address The address for check
     */
    modifier addressNotNull(address _address) {
        require(_address != address(0));
        _;
    }

    /**
     * @dev Throws if owners count less then quorum.
     * @param _ownersCount New owners count
     * @param _required New or old required param, min: 2
     */
    modifier validRequirement(uint256 _ownersCount, uint _required) {
        require(_required > 1 && _ownersCount >= _required);
        _;
    }

    /**
     * @dev Throws if owner does not exists.
     * @param owner The address for check
     */
    modifier ownerExists(address owner) {
        require(isOwner[owner]);
        _;
    }

    /**
     * @dev Throws if owner exists.
     * @param owner The address for check
     */
    modifier ownerDoesNotExist(address owner) {
        require(!isOwner[owner]);
        _;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner {
        require(isOwner[msg.sender]);
        _;
    }

    /**
     * @dev Modifier for multisig functions.
     * @param _operation The operation must have an intrinsic hash in order that later attempts can be
     * realised as the same underlying operation and thus count as confirmations.
     */
    modifier onlyManyOwners(bytes32 _operation) {
        if (confirmAndCheck(_operation)) {
            _;
        }
    }

    /**
     * @dev Constructor is given the number of sigs required to do protected "onlyManyOwners"
     * transactions as well as the selection of addresses capable of confirming them.
     * @param _additionalOwners A list of owners.
     * @param _required The amount required for a operation to be approved.
     */
    function Shareable(address[] _additionalOwners, uint256 _required)
        validRequirement(_additionalOwners.length + 1, _required)
    {
        owners.push(msg.sender);
        isOwner[msg.sender] = true;

        for (uint i = 0; i < _additionalOwners.length; i++) {
            require(!isOwner[_additionalOwners[i]] && _additionalOwners[i] != address(0));

            owners.push(_additionalOwners[i]);
            isOwner[_additionalOwners[i]] = true;
        }

        required = _required;
    }

    /**
     * @dev Allows to change the number of required confirmations.
     * @param _required Number of required confirmations.
     */
    function changeRequirement(uint _required)
        external
        validRequirement(owners.length, _required)
        onlyManyOwners(keccak256("change-requirement", _required))
    {
        required = _required;

        RequirementChange(_required);
    }

    /**
     * @dev Allows owners to add new owner with quorum.
     * @param _owner The address to join for ownership.
     */
    function addOwner(address _owner)
        external
        addressNotNull(_owner)
        ownerDoesNotExist(_owner)
        onlyManyOwners(keccak256("add-owner", _owner))
    {
        owners.push(_owner);
        isOwner[_owner] = true;

        OwnerAddition(_owner);
    }

    /**
     * @dev Allows owners to remove owner with quorum.
     * @param _owner The address to remove from ownership.
     */
    function removeOwner(address _owner)
        external
        addressNotNull(_owner)
        ownerExists(_owner)
        onlyManyOwners(keccak256("remove-owner", _owner))
        validRequirement(owners.length - 1, required)
    {
        // clear all pending operation list
        clearPending();

        isOwner[_owner] = false;

        for (uint256 i = 0; i < owners.length - 1; i++) {
            if (owners[i] == _owner) {
                owners[i] = owners[owners.length - 1];
                break;
            }
        }

        owners.length -= 1;

        OwnerRemoval(_owner);
    }

    /**
     * @dev Revokes a prior confirmation of the given operation.
     * @param _operation A string identifying the operation.
     */
    function revoke(bytes32 _operation)
        external
        onlyOwner
    {
        var pending = pendings[_operation];

        if (pending.ownersDone[msg.sender]) {
            pending.yetNeeded++;
            pending.ownersDone[msg.sender] = false;

            uint256 count = 0;
            for (uint256 i = 0; i < owners.length; i++) {
                if (hasConfirmed(_operation, owners[i])) {
                    count++;
                }
            }

            if (count <= 0) {
                pendingsIndex[pending.index] = pendingsIndex[pendingsIndex.length - 1];
                pendingsIndex.length--;
                delete pendings[_operation];
            }

            Revoke(msg.sender, _operation);
        }
    }

    /**
     * @dev Function to check is specific owner has already confirme the operation.
     * @param _operation The operation identifier.
     * @param _owner The owner address.
     * @return True if the owner has confirmed and false otherwise.
     */
    function hasConfirmed(bytes32 _operation, address _owner)
        constant
        addressNotNull(_owner)
        onlyOwner
        returns (bool)
    {
        return pendings[_operation].ownersDone[_owner];
    }

    /**
     * @dev Confirm and operation and checks if it's already executable.
     * @param _operation The operation identifier.
     * @return Returns true when operation can be executed.
     */
    function confirmAndCheck(bytes32 _operation)
        internal
        onlyOwner
        returns (bool)
    {
        var pending = pendings[_operation];

        // if we're not yet working on this operation, switch over and reset the confirmation status.
        if (pending.yetNeeded == 0) {
            clearOwnersDone(_operation);
            // reset count of confirmations needed.
            pending.yetNeeded = required;
            // reset which owners have confirmed (none).
            pendingsIndex.length++;
            pending.index = pendingsIndex.length++;
            pendingsIndex[pending.index] = _operation;
        }

        // make sure we (the message sender) haven't confirmed this operation previously.
        if (!hasConfirmed(_operation, msg.sender)) {
            Confirmation(msg.sender, _operation);

            // ok - check if count is enough to go ahead.
            if (pending.yetNeeded <= 1) {
                // enough confirmations: reset and run interior.
                clearOwnersDone(_operation);
                pendingsIndex[pending.index] = pendingsIndex[pendingsIndex.length - 1];
                pendingsIndex.length--;
                delete pendings[_operation];

                return true;
            } else {
                // not enough: record that this owner in particular confirmed.
                pending.yetNeeded--;
                pending.ownersDone[msg.sender] = true;
            }
        } else {
            revert();
        }

        return false;
    }

    /**
     * @dev Clear ownersDone in operation.
     * @param _operation The operation identifier.
     */
    function clearOwnersDone(bytes32 _operation)
        internal
        onlyOwner
    {
        for (uint256 i = 0; i < owners.length; i++) {
            if (pendings[_operation].ownersDone[owners[i]]) {
                pendings[_operation].ownersDone[owners[i]] = false;
            }
        }
    }

    /**
     * @dev Clear the pending list.
     */
    function clearPending()
        internal
        onlyOwner
    {
        uint256 length = pendingsIndex.length;

        for (uint256 i = 0; i < length; ++i) {
            clearOwnersDone(pendingsIndex[i]);
            delete pendings[pendingsIndex[i]];
        }

        pendingsIndex.length = 0;
    }
}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) allowed;


    /**
     * @dev Transfer tokens from one address to another
     * @param _from address The address which you want to send tokens from
     * @param _to address The address which you want to transfer to
     * @param _value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));

        uint256 _allowance = allowed[_from][msg.sender];

        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
        // require (_value <= _allowance);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
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
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     */
    function increaseApproval(address _spender, uint _addedValue)
        returns (bool success) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    function decreaseApproval(address _spender, uint _subtractedValue)
        returns (bool success) {
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

/**
 * @title MintableToken
 * @dev Simple ERC20 Token example, with mintable token creation.
 */
contract MintableToken is StandardToken, Shareable {
    event Mint(uint256 iteration, address indexed to, uint256 amount);

    // total supply limit
    uint256 public totalSupplyLimit;

    // the number of blocks to the next supply
    uint256 public numberOfBlocksBetweenSupplies;

    // mint is available after the block number
    uint256 public nextSupplyAfterBlock;

    // the current iteration of the supply
    uint256 public currentIteration = 1;

    // the amount of tokens available supply in prev iteration
    uint256 private prevIterationSupplyLimit = 0;

    /**
     * @dev Throws if minting are not allowed.
     * @param _amount The amount of tokens to mint.
     */
    modifier canMint(uint256 _amount) {
        // check block height
        require(block.number >= nextSupplyAfterBlock);

        // check total supply limit
        require(totalSupply.add(_amount) <= totalSupplyLimit);

        // check supply amount in current iteration
        require(_amount <= currentIterationSupplyLimit());

        _;
    }

    /**
     * @dev Constructor
     * @param _initialSupplyAddress The address that will recieve the initial minted tokens.
     * @param _initialSupply The amount of tokens to initial mint.
     * @param _firstIterationSupplyLimit The amount of token to limit first iteration.
     * @param _totalSupplyLimit The amount of tokens to finish mint.
     * @param _numberOfBlocksBetweenSupplies Number of blocks for the next mint.
     * @param _additionalOwners A list of owners.
     * @param _required The amount required for a transaction to be approved.
     */
    function MintableToken(
        address _initialSupplyAddress,
        uint256 _initialSupply,
        uint256 _firstIterationSupplyLimit,
        uint256 _totalSupplyLimit,
        uint256 _numberOfBlocksBetweenSupplies,
        address[] _additionalOwners,
        uint256 _required
    )
        Shareable(_additionalOwners, _required)
    {
        require(_initialSupplyAddress != address(0) && _initialSupply > 0);

        prevIterationSupplyLimit = _firstIterationSupplyLimit;
        totalSupplyLimit = _totalSupplyLimit;
        numberOfBlocksBetweenSupplies = _numberOfBlocksBetweenSupplies;
        nextSupplyAfterBlock = block.number.add(_numberOfBlocksBetweenSupplies);

        totalSupply = totalSupply.add(_initialSupply);
        balances[_initialSupplyAddress] = balances[_initialSupplyAddress].add(_initialSupply);
    }

    /**
     * @dev Returns the limit on the supply in the current iteration.
     */
    function currentIterationSupplyLimit()
        public
        constant
        returns (uint256 maxSupply)
    {
        if (currentIteration == 1) {
            maxSupply = prevIterationSupplyLimit;
        } else {
            maxSupply = prevIterationSupplyLimit.mul(9881653713).div(10000000000);

            if (maxSupply > (totalSupplyLimit.sub(totalSupply))) {
                maxSupply = totalSupplyLimit.sub(totalSupply);
            }
        }
    }

    /**
     * @dev Function to init minting tokens
     * @param _to The address that will recieve the minted tokens.
     * @param _amount The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address _to, uint256 _amount)
        external
        canMint(_amount)
        onlyManyOwners(keccak256("mint", _to, _amount))
        returns (bool)
    {
        prevIterationSupplyLimit = currentIterationSupplyLimit();
        nextSupplyAfterBlock = block.number.add(numberOfBlocksBetweenSupplies);

        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);

        Mint(currentIteration, _to, _amount);
        Transfer(0x0, _to, _amount);

        currentIteration = currentIteration.add(1);

        clearPending();

        return true;
    }
}

/**
 * @title OTN ERC20 token
 */
contract OTNToken is MintableToken {
    // token name
    string public name = "Open Trading Network";

    // token symbol
    string public symbol = "OTN";

    // token decimals
    uint256 public decimals = 18;

    /**
     * @dev Constructor
     * @param _initialSupplyAddress The address that will recieve the initial minted tokens.
     * @param _additionalOwners A list of owners.
     */
    function OTNToken(
        address _initialSupplyAddress,
        address[] _additionalOwners
    )
        MintableToken(
            _initialSupplyAddress,
            79000000e18,            // initial supply
            350000e18,              // first iteration max supply
            100000000e18,           // max supply for all time
            100,                    // supply iteration every 100 blocks (17 sec per block)
            _additionalOwners,      // additional owners
            2                       // required number for a operations to be approved
    )
    {

    }

}