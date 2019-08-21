pragma solidity ^0.4.19;


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
  function Ownable() public {
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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract JouleAPI {
    event Invoked(address indexed _invoker, address indexed _address, bool _status, uint _usedGas);
    event Registered(address indexed _registrant, address indexed _address, uint _timestamp, uint _gasLimit, uint _gasPrice);
    event Unregistered(address indexed _registrant, address indexed _address, uint _timestamp, uint _gasLimit, uint _gasPrice, uint _amount);

    /**
     * @dev Registers the specified contract to invoke at the specified time with the specified gas and price.
     * @notice Registration requires the specified amount of ETH in value, to cover invoke bonus. See getPrice method.
     *
     * @param _address      Contract's address. Contract MUST implements Checkable interface.
     * @param _timestamp    Timestamp at what moment contract should be called. It MUST be in future.
     * @param _gasLimit     Gas which will be posted to call.
     * @param _gasPrice     Gas price which is recommended to use for this invocation.
     * @return Amount of change.
     */
    function register(address _address, uint _timestamp, uint _gasLimit, uint _gasPrice) external payable returns (uint);

    /**
     * @dev Registers the specified contract to invoke at the specified time with the specified gas and price.
     * @notice Registration requires the specified amount of ETH in value, to cover invoke bonus. See getPrice method.
     * @notice If value would be more then required (see getPrice) change will be returned to msg.sender (not to _registrant!).
     *
     * @param _registrant   Any address which will be owners for this registration. Only he can unregister. Useful for calling from contract.
     * @param _address      Contract's address. Contract MUST implements Checkable interface.
     * @param _timestamp    Timestamp at what moment contract should be called. It MUST be in future.
     * @param _gasLimit     Gas which will be posted to call.
     * @param _gasPrice     Gas price which is recommended to use for this invocation.
     * @return Amount of change.
     */
    function registerFor(address _registrant, address _address, uint _timestamp, uint _gasLimit, uint _gasPrice) public payable returns (uint);

    /**
     * @dev Remove registration of the specified contract (with exact parameters) by the specified key. See findKey method for looking for key.
     * @notice It returns not full amount of ETH.
     * @notice Only registrant can remove their registration.
     * @notice Only registrations in future can be removed.
     *
     * @param _key          Contract key, to fast finding during unregister. See findKey method for getting key.
     * @param _address      Contract's address. Contract MUST implements Checkable interface.
     * @param _timestamp    Timestamp at what moment contract should be called. It MUST be in future.
     * @param _gasLimit     Gas which will be posted to call.
     * @param _gasPrice     Gas price which is recommended to use for this invocation.
     * @return Amount of refund.
     */
    function unregister(bytes32 _key, address _address, uint _timestamp, uint _gasLimit, uint _gasPrice) external returns (uint);

    /**
     * @dev Invokes next contracts in the queue.
     * @notice Eth amount to cover gas will be returned if gas price is equal or less then specified for contract. Check getTop for right gas price.
     * @return Reward amount.
     */
    function invoke() public returns (uint);

    /**
     * @dev Invokes next contracts in the queue.
     * @notice Eth amount to cover gas will be returned if gas price is equal or less then specified for contract. Check getTop for right gas price.
     * @param _invoker Any address from which event will be threw. Useful for calling from contract.
     * @return Reward amount.
     */
    function invokeFor(address _invoker) public returns (uint);

    /**
     * @dev Invokes the top contract in the queue.
     * @notice Eth amount to cover gas will be returned if gas price is equal or less then specified for contract. Check getTop for right gas price.
     * @return Reward amount.
     */
    function invokeOnce() public returns (uint);

    /**
     * @dev Invokes the top contract in the queue.
     * @notice Eth amount to cover gas will be returned if gas price is equal or less then specified for contract. Check getTop for right gas price.
     * @param _invoker Any address from which event will be threw. Useful for calling from contract.
     * @return Reward amount.
     */
    function invokeOnceFor(address _invoker) public returns (uint);

    /**
     * @dev Calculates required to register amount of WEI.
     *
     * @param _gasLimit Gas which will be posted to call.
     * @param _gasPrice Gas price which is recommended to use for this invocation.
     * @return Amount in wei.
     */
    function getPrice(uint _gasLimit, uint _gasPrice) external view returns (uint);

    /**
     * @dev Gets how many contracts are registered (and not invoked).
     */
    function getCount() public view returns (uint);

    /**
     * @dev Gets top contract (the next to invoke).
     *
     * @return contractAddress  The contract address.
     * @return timestamp        The invocation timestamp.
     * @return gasLimit         The contract gas.
     * @return gasPrice         The invocation expected price.
     * @return invokeGas        The minimal amount of gas to invoke (including gas for joule).
     * @return rewardAmount     The amount of reward for invocation.
     */
    function getTopOnce() external view returns (
        address contractAddress,
        uint timestamp,
        uint gasLimit,
        uint gasPrice,
        uint invokeGas,
        uint rewardAmount
    );

    /**
     * @dev Gets one next contract by the specified previous in order to invoke.
     *
     * @param _contractAddress  The previous contract address.
     * @param _timestamp        The previous invocation timestamp.
     * @param _gasLimit         The previous invocation maximum gas.
     * @param _gasPrice         The previous invocation expected price.
     * @return contractAddress  The contract address.
     * @return gasLimit         The contract gas.
     * @return gasPrice         The invocation expected price.
     * @return invokeGas        The minimal amount of gas to invoke (including gas for joule).
     * @return rewardAmount     The amount of reward for invocation.
     */
    function getNextOnce(address _contractAddress,
                     uint _timestamp,
                     uint _gasLimit,
                     uint _gasPrice) public view returns (
        address contractAddress,
        uint timestamp,
        uint gasLimit,
        uint gasPrice,
        uint invokeGas,
        uint rewardAmount
    );

    /**
     * @dev Gets _count next contracts by the specified previous in order to invoke.
     * @notice Unlike getTop this method return exact _count values.
     *
     * @param _count            The count of result contracts.
     * @param _contractAddress  The previous contract address.
     * @param _timestamp        The previous invocation timestamp.
     * @param _gasLimit         The previous invocation maximum gas.
     * @param _gasPrice         The previous invocation expected price.
     * @return contractAddress  The contract address.
     * @return gasLimit         The contract gas.
     * @return gasPrice         The invocation expected price.
     * @return invokeGas        The minimal amount of gas to invoke (including gas for joule).
     * @return rewardAmount     The amount of reward for invocation.
     */
    function getNext(uint _count,
                address _contractAddress,
                uint _timestamp,
                uint _gasLimit,
                uint _gasPrice) external view returns (
        address[] addresses,
        uint[] timestamps,
        uint[] gasLimits,
        uint[] gasPrices,
        uint[] invokeGases,
        uint[] rewardAmounts
    );

    /**
     * @dev Gets top _count contracts (in order to invoke).
     *
     * @param _count            How many records will be returned.
     * @return addresses        The contracts addresses.
     * @return timestamps       The invocation timestamps.
     * @return gasLimits        The contract gas.
     * @return gasPrices        The invocation expected price.
     * @return invokeGases      The minimal amount of gas to invoke (including gas for joule).
     * @return rewardAmounts    The amount of reward for invocation.
     */
    function getTop(uint _count) external view returns (
        address[] addresses,
        uint[] timestamps,
        uint[] gasLimits,
        uint[] gasPrices,
        uint[] invokeGases,
        uint[] rewardAmounts
    );

    /**
     * @dev Finds key for the registration with exact parameters. Be careful, key might be changed because of other registrations.
     * @param _address      Contract's address. Contract MUST implements Checkable interface.
     * @param _timestamp    Timestamp at what moment contract should be called. It MUST be in future.
     * @param _gasLimit     Gas which will be posted to call.
     * @param _gasPrice     Gas price which is recommended to use for this invocation.
     * @return _key         Key of the specified registration.
     */
    function findKey(address _address, uint _timestamp, uint _gasLimit, uint _gasPrice) public view returns (bytes32);

    /**
     * @dev Gets actual code version.
     * @return Code version. Mask: 0xff.0xff.0xffff-0xffffffff (major.minor.build-hash)
     */
    function getVersion() external view returns (bytes8);

    /**
     * @dev Gets minimal gas price, specified by maintainer.
     */
    function getMinGasPrice() public view returns (uint);
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
contract TransferToken is Ownable {
    function transferToken(ERC20Basic _token, address _to, uint _value) public onlyOwner {
        _token.transfer(_to, _value);
    }
}
contract JouleProxyAPI {
    /**
     * Function hash is: 0x73027f6d
     */
    function callback(address _invoker, address _address, uint _timestamp, uint _gasLimit, uint _gasPrice) public returns (bool);
}
contract CheckableContract {
    event Checked();
    /*
     * Function hash is 0x919840ad.
     */
    function check() public;
}

contract usingConsts {
    uint constant GWEI = 0.001 szabo;

    // this values influence to the reward price! do not change for already registered contracts!
    uint constant TRANSACTION_GAS = 22000;
    // remaining gas - amount of gas to finish transaction after invoke
    uint constant REMAINING_GAS = 30000;
    // joule gas - gas to joule (including proxy and others) invocation, excluding contract gas
    uint constant JOULE_GAS = TRANSACTION_GAS + REMAINING_GAS + 5000;

    // minimal default gas price (because of network load)
    uint32 constant DEFAULT_MIN_GAS_PRICE_GWEI = 20;
    // min gas price
    uint constant MIN_GAS_PRICE = GWEI;
    // max gas price
    uint constant MAX_GAS_PRICE = 0xffffffff * GWEI;
    // not, it mist be less then 0x00ffffff, because high bytes might be used for storing flags
    uint constant MAX_GAS = 4000000;
    // Code version
    bytes8 constant VERSION = 0x0108000000000000;
    //                          ^^ - major
    //                            ^^ - minor
    //                              ^^^^ - build
    //                                  ^^^^^^^^ - git hash
}


library KeysUtils {
    // Such order is important to load from state
    struct Object {
        uint32 gasPriceGwei;
        uint32 gasLimit;
        uint32 timestamp;
        address contractAddress;
    }

    function toKey(Object _obj) internal pure returns (bytes32) {
        return toKey(_obj.contractAddress, _obj.timestamp, _obj.gasLimit, _obj.gasPriceGwei);
    }

    function toKeyFromStorage(Object storage _obj) internal view returns (bytes32 _key) {
        assembly {
            _key := sload(_obj_slot)
        }
    }

    function toKey(address _address, uint _timestamp, uint _gasLimit, uint _gasPrice) internal pure returns (bytes32 result) {
        result = 0x0000000000000000000000000000000000000000000000000000000000000000;
        //         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ - address (20 bytes)
        //                                                 ^^^^^^^^ - timestamp (4 bytes)
        //                                                         ^^^^^^^^ - gas limit (4 bytes)
        //                                                                 ^^^^^^^^ - gas price (4 bytes)
        assembly {
            result := or(result, mul(_address, 0x1000000000000000000000000))
            result := or(result, mul(and(_timestamp, 0xffffffff), 0x10000000000000000))
            result := or(result, mul(and(_gasLimit, 0xffffffff), 0x100000000))
            result := or(result, and(_gasPrice, 0xffffffff))
        }
    }

    function toMemoryObject(bytes32 _key, Object memory _dest) internal pure {
        assembly {
            mstore(_dest, and(_key, 0xffffffff))
            mstore(add(_dest, 0x20), and(div(_key, 0x100000000), 0xffffffff))
            mstore(add(_dest, 0x40), and(div(_key, 0x10000000000000000), 0xffffffff))
            mstore(add(_dest, 0x60), div(_key, 0x1000000000000000000000000))
        }
    }

    function toObject(bytes32 _key) internal pure returns (Object memory _dest) {
        toMemoryObject(_key, _dest);
    }

    function toStateObject(bytes32 _key, Object storage _dest) internal {
        assembly {
            sstore(_dest_slot, _key)
        }
    }

    function getTimestamp(bytes32 _key) internal pure returns (uint result) {
        assembly {
            result := and(div(_key, 0x10000000000000000), 0xffffffff)
        }
    }
}

contract Restriction {
    mapping (address => bool) internal accesses;

    function Restriction() public {
        accesses[msg.sender] = true;
    }

    function giveAccess(address _addr) public restricted {
        accesses[_addr] = true;
    }

    function removeAccess(address _addr) public restricted {
        delete accesses[_addr];
    }

    function hasAccess() public constant returns (bool) {
        return accesses[msg.sender];
    }

    modifier restricted() {
        require(hasAccess());
        _;
    }
}

contract JouleStorage is Restriction {
    mapping(bytes32 => bytes32) map;

    function get(bytes32 _key) public view returns (bytes32 _value) {
        return map[_key];
    }

    function set(bytes32 _key, bytes32 _value) public restricted {
        map[_key] = _value;
    }

    function del(bytes32 _key) public restricted {
        delete map[_key];
    }

    function getAndDel(bytes32 _key) public restricted returns (bytes32 _value) {
        _value = map[_key];
        delete map[_key];
    }

    function swap(bytes32 _from, bytes32 _to) public restricted returns (bytes32 _value) {
        _value = map[_to];
        map[_to] = map[_from];
        delete map[_from];
    }
}

contract JouleIndexCore {
    using KeysUtils for bytes32;
    uint constant YEAR = 0x1DFE200;
    bytes32 constant HEAD = 0x0;

    // YEAR -> week -> hour -> minute
    JouleStorage public state;

    function JouleIndexCore(JouleStorage _storage) public {
        state = _storage;
    }

    function insertIndex(bytes32 _key) internal {
        uint timestamp = _key.getTimestamp();
        bytes32 year = toKey(timestamp, YEAR);
        bytes32 headLow;
        bytes32 headHigh;
        (headLow, headHigh) = fromValue(state.get(HEAD));
        if (year < headLow || headLow == 0 || year > headHigh) {
            if (year < headLow || headLow == 0) {
                headLow = year;
            }
            if (year > headHigh) {
                headHigh = year;
            }
            state.set(HEAD, toValue(headLow, headHigh));
        }

        bytes32 week = toKey(timestamp, 1 weeks);
        bytes32 low;
        bytes32 high;
        (low, high) = fromValue(state.get(year));
        if (week < low || week > high) {
            if (week < low || low == 0) {
                low = week;
            }
            if (week > high) {
                high = week;
            }
            state.set(year, toValue(low, high));
        }

        (low, high) = fromValue(state.get(week));
        bytes32 hour = toKey(timestamp, 1 hours);
        if (hour < low || hour > high) {
            if (hour < low || low == 0) {
                low = hour;
            }
            if (hour > high) {
                high = hour;
            }
            state.set(week, toValue(low, high));
        }

        (low, high) = fromValue(state.get(hour));
        bytes32 minute = toKey(timestamp, 1 minutes);
        if (minute < low || minute > high) {
            if (minute < low || low == 0) {
                low = minute;
            }
            if (minute > high) {
                high = minute;
            }
            state.set(hour, toValue(low, high));
        }

        (low, high) = fromValue(state.get(minute));
        bytes32 tsKey = toKey(timestamp);
        if (tsKey < low || tsKey > high) {
            if (tsKey < low || low == 0) {
                low = tsKey;
            }
            if (tsKey > high) {
                high = tsKey;
            }
            state.set(minute, toValue(low, high));
        }

        state.set(tsKey, _key);
    }

    /**
     * @dev Update key value from the previous state to new. Timestamp MUST be the same on both keys.
     */
    function updateIndex(bytes32 _prev, bytes32 _key) internal {
        uint timestamp = _key.getTimestamp();
        bytes32 tsKey = toKey(timestamp);
        bytes32 prevKey = state.get(tsKey);
        // on the same timestamp might be other key, in that case we do not need to update it
        if (prevKey != _prev) {
            return;
        }
        state.set(tsKey, _key);
    }

    function findFloorKeyYear(uint _timestamp, bytes32 _low, bytes32 _high) view private returns (bytes32) {
        bytes32 year = toKey(_timestamp, YEAR);
        if (year < _low) {
            return 0;
        }
        if (year > _high) {
            // week
            (low, high) = fromValue(state.get(_high));
            // hour
            (low, high) = fromValue(state.get(high));
            // minute
            (low, high) = fromValue(state.get(high));
            // ts
            (low, high) = fromValue(state.get(high));
            return state.get(high);
        }

        bytes32 low;
        bytes32 high;

        while (year >= _low) {
            (low, high) = fromValue(state.get(year));
            if (low != 0) {
                bytes32 key = findFloorKeyWeek(_timestamp, low, high);
                if (key != 0) {
                    return key;
                }
            }
            // 0x1DFE200 = 52 weeks = 31449600
            assembly {
                year := sub(year, 0x1DFE200)
            }
        }

        return 0;
    }

    function findFloorKeyWeek(uint _timestamp, bytes32 _low, bytes32 _high) view private returns (bytes32) {
        bytes32 week = toKey(_timestamp, 1 weeks);
        if (week < _low) {
            return 0;
        }

        bytes32 low;
        bytes32 high;

        if (week > _high) {
            // hour
            (low, high) = fromValue(state.get(_high));
            // minute
            (low, high) = fromValue(state.get(high));
            // ts
            (low, high) = fromValue(state.get(high));
            return state.get(high);
        }

        while (week >= _low) {
            (low, high) = fromValue(state.get(week));
            if (low != 0) {
                bytes32 key = findFloorKeyHour(_timestamp, low, high);
                if (key != 0) {
                    return key;
                }
            }

            // 1 weeks = 604800
            assembly {
                week := sub(week, 604800)
            }
        }
        return 0;
    }


    function findFloorKeyHour(uint _timestamp, bytes32 _low, bytes32 _high) view private returns (bytes32) {
        bytes32 hour = toKey(_timestamp, 1 hours);
        if (hour < _low) {
            return 0;
        }

        bytes32 low;
        bytes32 high;

        if (hour > _high) {
            // minute
            (low, high) = fromValue(state.get(_high));
            // ts
            (low, high) = fromValue(state.get(high));
            return state.get(high);
        }

        while (hour >= _low) {
            (low, high) = fromValue(state.get(hour));
            if (low != 0) {
                bytes32 key = findFloorKeyMinute(_timestamp, low, high);
                if (key != 0) {
                    return key;
                }
            }

            // 1 hours = 3600
            assembly {
                hour := sub(hour, 3600)
            }
        }
        return 0;
    }

    function findFloorKeyMinute(uint _timestamp, bytes32 _low, bytes32 _high) view private returns (bytes32) {
        bytes32 minute = toKey(_timestamp, 1 minutes);
        if (minute < _low) {
            return 0;
        }

        bytes32 low;
        bytes32 high;

        if (minute > _high) {
            // ts
            (low, high) = fromValue(state.get(_high));
            return state.get(high);
        }

        while (minute >= _low) {
            (low, high) = fromValue(state.get(minute));
            if (low != 0) {
                bytes32 key = findFloorKeyTimestamp(_timestamp, low, high);
                if (key != 0) {
                    return key;
                }
            }

            // 1 minutes = 60
            assembly {
                minute := sub(minute, 60)
            }
        }

        return 0;
    }

    function findFloorKeyTimestamp(uint _timestamp, bytes32 _low, bytes32 _high) view private returns (bytes32) {
        bytes32 tsKey = toKey(_timestamp);
        if (tsKey < _low) {
            return 0;
        }
        if (tsKey > _high) {
            return state.get(_high);
        }

        while (tsKey >= _low) {
            bytes32 key = state.get(tsKey);
            if (key != 0) {
                return key;
            }
            assembly {
                tsKey := sub(tsKey, 1)
            }
        }
        return 0;
    }

    function findFloorKeyIndex(uint _timestamp) view internal returns (bytes32) {
//        require(_timestamp > 0xffffffff);
//        if (_timestamp < 1515612415) {
//            return 0;
//        }

        bytes32 yearLow;
        bytes32 yearHigh;
        (yearLow, yearHigh) = fromValue(state.get(HEAD));

        return findFloorKeyYear(_timestamp, yearLow, yearHigh);
    }

    function toKey(uint _timestamp, uint rounder) pure private returns (bytes32 result) {
        // 0x0...00000000000000000
        //        ^^^^^^^^ - rounder marker (eg, to avoid crossing first day of year with year)
        //                ^^^^^^^^ - rounded moment (year, week, etc)
        assembly {
            result := or(mul(rounder, 0x100000000), mul(div(_timestamp, rounder), rounder))
        }
    }

    function toValue(bytes32 _lowKey, bytes32 _highKey) pure private returns (bytes32 result) {
        assembly {
            result := or(mul(_lowKey, 0x10000000000000000), _highKey)
        }
    }

    function fromValue(bytes32 _value) pure private returns (bytes32 _lowKey, bytes32 _highKey) {
        assembly {
            _lowKey := and(div(_value, 0x10000000000000000), 0xffffffffffffffff)
            _highKey := and(_value, 0xffffffffffffffff)
        }
    }

    function toKey(uint timestamp) pure internal returns (bytes32) {
        return bytes32(timestamp);
    }
}

contract JouleContractHolder is JouleIndexCore, usingConsts {
    using KeysUtils for bytes32;
    uint internal length;
    bytes32 public head;

    function JouleContractHolder(bytes32 _head, uint _length, JouleStorage _storage) public
            JouleIndexCore(_storage) {
        head = _head;
        length = _length;
    }

    function insert(address _address, uint _timestamp, uint _gasLimit, uint _gasPrice) internal {
        length ++;
        bytes32 id = KeysUtils.toKey(_address, _timestamp, _gasLimit, _gasPrice);
        if (head == 0) {
            head = id;
            insertIndex(id);
//            Found(0xffffffff);
            return;
        }
        bytes32 previous = findFloorKeyIndex(_timestamp);

        // reject duplicate key on the end
        require(previous != id);
        // reject duplicate in the middle
        require(state.get(id) == 0);

        uint prevTimestamp = previous.getTimestamp();
//        Found(prevTimestamp);
        uint headTimestamp = head.getTimestamp();
        // add as head, prevTimestamp == 0 or in the past
        if (prevTimestamp < headTimestamp) {
            state.set(id, head);
            head = id;
        }
        // add after the previous
        else {
            state.set(id, state.get(previous));
            state.set(previous, id);
        }
        insertIndex(id);
    }

    function updateGas(bytes32 _key, address _address, uint _timestamp, uint _gasLimit, uint _gasPrice, uint _newGasLimit) internal {
        bytes32 id = KeysUtils.toKey(_address, _timestamp, _gasLimit, _gasPrice);
        bytes32 newId = KeysUtils.toKey(_address, _timestamp, _newGasLimit, _gasPrice);
        if (id == head) {
            bytes32 afterHead = state.get(id);
            head = newId;
            state.set(newId, afterHead);
            return;
        }

        require(state.get(_key) == id);
        state.set(_key, newId);
        state.swap(id, newId);
        updateIndex(id, newId);
    }

    function next() internal {
        head = state.getAndDel(head);
        length--;
    }

    function getCount() public view returns (uint) {
        return length;
    }

    function getRecord(bytes32 _parent) internal view returns (bytes32 _record) {
        if (_parent == 0) {
            _record = head;
        }
        else {
            _record = state.get(_parent);
        }
    }

    /**
     * @dev Find previous key for existing value.
     */
    function findPrevious(address _address, uint _timestamp, uint _gasLimit, uint _gasPrice) internal view returns (bytes32) {
        bytes32 target = KeysUtils.toKey(_address, _timestamp, _gasLimit, _gasPrice);
        bytes32 previous = head;
        if (target == previous) {
            return 0;
        }
        // if it is not head time
        if (_timestamp != previous.getTimestamp()) {
            previous = findFloorKeyIndex(_timestamp - 1);
        }
        bytes32 current = state.get(previous);
        while (current != target) {
            previous = current;
            current = state.get(previous);
        }
        return previous;
    }
}

contract JouleVault is Ownable {
    address public joule;

    function setJoule(address _joule) public onlyOwner {
        joule = _joule;
    }

    modifier onlyJoule() {
        require(msg.sender == address(joule));
        _;
    }

    function withdraw(address _receiver, uint _amount) public onlyJoule {
        _receiver.transfer(_amount);
    }

    function () public payable {

    }
}

contract JouleCore is JouleContractHolder {
    JouleVault public vault;
    uint32 public minGasPriceGwei = DEFAULT_MIN_GAS_PRICE_GWEI;
    using KeysUtils for bytes32;

    function JouleCore(JouleVault _vault, bytes32 _head, uint _length, JouleStorage _storage) public
        JouleContractHolder(_head, _length, _storage) {
        vault = _vault;
    }

    function innerRegister(address _registrant, address _address, uint _timestamp, uint _gasLimit, uint _gasPrice) internal returns (uint) {
        uint price = getPriceInner(_gasLimit, _gasPrice);
        require(msg.value >= price);
        vault.transfer(price);

        // this restriction to avoid attack to brake index tree (crossing key)
        require(_address != 0);
        require(_timestamp > now);
        require(_timestamp < 0x100000000);
        require(_gasLimit <= MAX_GAS);
        require(_gasLimit != 0);
        // from 1 gwei to 0x100000000 gwei
        require(_gasPrice >= minGasPriceGwei * GWEI);
        require(_gasPrice < MAX_GAS_PRICE);
        // 0 means not yet registered
        require(_registrant != 0x0);

        uint innerGasPrice = _gasPrice / GWEI;
        insert(_address, _timestamp, _gasLimit, innerGasPrice);
        saveRegistrant(_registrant, _address, _timestamp, _gasLimit, innerGasPrice);

        if (msg.value > price) {
            msg.sender.transfer(msg.value - price);
            return msg.value - price;
        }
        return 0;
    }

    function saveRegistrant(address _registrant, address _address, uint _timestamp, uint, uint) internal {
        bytes32 id = KeysUtils.toKey(_address, _timestamp, 0, 0);
        require(state.get(id) == 0);
        state.set(id, bytes32(_registrant));
    }

    function getRegistrant(address _address, uint _timestamp, uint, uint) internal view returns (address) {
        bytes32 id = KeysUtils.toKey(_address, _timestamp, 0, 0);
        return address(state.get(id));
    }

    function delRegistrant(KeysUtils.Object memory current) internal {
        bytes32 id = KeysUtils.toKey(current.contractAddress, current.timestamp, 0, 0);
        state.del(id);
    }

    function findKey(address _address, uint _timestamp, uint _gasLimit, uint _gasPrice) public view returns (bytes32) {
        require(_address != 0);
        require(_timestamp > now);
        require(_timestamp < 0x100000000);
        require(_gasLimit < MAX_GAS);
        require(_gasPrice > GWEI);
        require(_gasPrice < 0x100000000 * GWEI);
        return findPrevious(_address, _timestamp, _gasLimit, _gasPrice / GWEI);
    }

    function innerUnregister(address _registrant, bytes32 _key, address _address, uint _timestamp, uint _gasLimit, uint _gasPrice) internal returns (uint) {
        // only future registrations might be updated, to avoid race condition in block (with invoke)
        require(_timestamp > now);
        // to avoid removing already removed keys
        require(_gasLimit != 0);
        uint innerGasPrice = _gasPrice / GWEI;
        // check registrant
        address registrant = getRegistrant(_address, _timestamp, _gasLimit, innerGasPrice);
        require(registrant == _registrant);

        updateGas(_key, _address, _timestamp, _gasLimit, innerGasPrice, 0);
        uint amount = _gasLimit * _gasPrice;
        if (amount != 0) {
            vault.withdraw(registrant, amount);
        }
        return amount;
    }

    function getPrice(uint _gasLimit, uint _gasPrice) external view returns (uint) {
        require(_gasLimit <= MAX_GAS);
        require(_gasPrice > GWEI);
        require(_gasPrice < 0x100000000 * GWEI);

        return getPriceInner(_gasLimit, _gasPrice);
    }

    function getPriceInner(uint _gasLimit, uint _gasPrice) internal pure returns (uint) {
        // if this logic will be changed, look also to the innerUnregister method
        return (_gasLimit + JOULE_GAS) * _gasPrice;
    }

    function getVersion() external view returns (bytes8) {
        return VERSION;
    }

    function getTop(uint _count) external view returns (
        address[] _addresses,
        uint[] _timestamps,
        uint[] _gasLimits,
        uint[] _gasPrices,
        uint[] _invokeGases,
        uint[] _rewardAmounts
    ) {
        uint amount = _count <= length ? _count : length;

        _addresses = new address[](amount);
        _timestamps = new uint[](amount);
        _gasLimits = new uint[](amount);
        _gasPrices = new uint[](amount);
        _invokeGases = new uint[](amount);
        _rewardAmounts = new uint[](amount);

        bytes32 current = getRecord(0);
        for (uint i = 0; i < amount; i ++) {
            KeysUtils.Object memory obj = current.toObject();
            _addresses[i] = obj.contractAddress;
            _timestamps[i] = obj.timestamp;
            uint gasLimit = obj.gasLimit;
            _gasLimits[i] = gasLimit;
            uint gasPrice = obj.gasPriceGwei * GWEI;
            _gasPrices[i] = gasPrice;
            uint invokeGas = gasLimit + JOULE_GAS;
            _invokeGases[i] = invokeGas;
            _rewardAmounts[i] = invokeGas * gasPrice;
            current = getRecord(current);
        }
    }

    function getTopOnce() external view returns (
        address contractAddress,
        uint timestamp,
        uint gasLimit,
        uint gasPrice,
        uint invokeGas,
        uint rewardAmount
    ) {
        KeysUtils.Object memory obj = getRecord(0).toObject();

        contractAddress = obj.contractAddress;
        timestamp = obj.timestamp;
        gasLimit = obj.gasLimit;
        gasPrice = obj.gasPriceGwei * GWEI;
        invokeGas = gasLimit + JOULE_GAS;
        rewardAmount = invokeGas * gasPrice;
    }

    function getNextOnce(address _contractAddress,
                     uint _timestamp,
                     uint _gasLimit,
                     uint _gasPrice) public view returns (
        address contractAddress,
        uint timestamp,
        uint gasLimit,
        uint gasPrice,
        uint invokeGas,
        uint rewardAmount
    ) {
        if (_timestamp == 0) {
            return this.getTopOnce();
        }

        bytes32 prev = KeysUtils.toKey(_contractAddress, _timestamp, _gasLimit, _gasPrice / GWEI);
        bytes32 current = getRecord(prev);
        KeysUtils.Object memory obj = current.toObject();

        contractAddress = obj.contractAddress;
        timestamp = obj.timestamp;
        gasLimit = obj.gasLimit;
        gasPrice = obj.gasPriceGwei * GWEI;
        invokeGas = gasLimit + JOULE_GAS;
        rewardAmount = invokeGas * gasPrice;
    }

    function getNext(uint _count,
                    address _contractAddress,
                    uint _timestamp,
                    uint _gasLimit,
                    uint _gasPrice) external view returns (address[] _addresses,
                                                        uint[] _timestamps,
                                                        uint[] _gasLimits,
                                                        uint[] _gasPrices,
                                                        uint[] _invokeGases,
                                                        uint[] _rewardAmounts) {
        _addresses = new address[](_count);
        _timestamps = new uint[](_count);
        _gasLimits = new uint[](_count);
        _gasPrices = new uint[](_count);
        _invokeGases = new uint[](_count);
        _rewardAmounts = new uint[](_count);

        bytes32 prev;
        if (_timestamp != 0) {
            prev = KeysUtils.toKey(_contractAddress, _timestamp, _gasLimit, _gasPrice / GWEI);
        }

        uint index = 0;
        while (index < _count) {
            bytes32 current = getRecord(prev);
            if (current == 0) {
                break;
            }
            KeysUtils.Object memory obj = current.toObject();

            _addresses[index] = obj.contractAddress;
            _timestamps[index] = obj.timestamp;
            _gasLimits[index] = obj.gasLimit;
            _gasPrices[index] = obj.gasPriceGwei * GWEI;
            _invokeGases[index] = obj.gasLimit + JOULE_GAS;
            _rewardAmounts[index] = (obj.gasLimit + JOULE_GAS) * obj.gasPriceGwei * GWEI;

            prev = current;
            index ++;
        }
    }

    function next(KeysUtils.Object memory current) internal {
        delRegistrant(current);
        next();
    }


    function innerInvoke(address _invoker) internal returns (uint _amount) {
        KeysUtils.Object memory current = KeysUtils.toObject(head);

        uint amount;
        while (current.timestamp != 0 && current.timestamp < now && msg.gas > (current.gasLimit + REMAINING_GAS)) {
            if (current.gasLimit != 0) {
                invokeCallback(_invoker, current);
            }

            amount += getPriceInner(current.gasLimit, current.gasPriceGwei * GWEI);
            next(current);
            current = head.toObject();
        }
        if (amount > 0) {
            vault.withdraw(msg.sender, amount);
        }
        return amount;
    }

    function innerInvokeOnce(address _invoker) internal returns (uint _amount) {
        KeysUtils.Object memory current = head.toObject();
        next(current);
        if (current.gasLimit != 0) {
            invokeCallback(_invoker, current);
        }

        uint amount = getPriceInner(current.gasLimit, current.gasPriceGwei * GWEI);

        if (amount > 0) {
            vault.withdraw(msg.sender, amount);
        }
        return amount;
    }


    function invokeCallback(address, KeysUtils.Object memory _record) internal returns (bool) {
        require(msg.gas >= _record.gasLimit);
        return _record.contractAddress.call.gas(_record.gasLimit)(0x919840ad);
    }

}


contract JouleBehindProxy is JouleCore, Ownable, TransferToken {
    JouleProxyAPI public proxy;

    function JouleBehindProxy(JouleVault _vault, bytes32 _head, uint _length, JouleStorage _storage) public
        JouleCore(_vault, _head, _length, _storage) {
    }

    function setProxy(JouleProxyAPI _proxy) public onlyOwner {
        proxy = _proxy;
    }

    modifier onlyProxy() {
        require(msg.sender == address(proxy));
        _;
    }

    function setMinGasPrice(uint _minGasPrice) public onlyOwner {
        require(_minGasPrice >= MIN_GAS_PRICE);
        require(_minGasPrice <= MAX_GAS_PRICE);
        minGasPriceGwei = uint32(_minGasPrice / GWEI);
    }

    function registerFor(address _registrant, address _address, uint _timestamp, uint _gasLimit, uint _gasPrice) public payable onlyProxy returns (uint) {
        return innerRegister(_registrant, _address, _timestamp, _gasLimit, _gasPrice);
    }

    function unregisterFor(address _registrant, bytes32 _key, address _address, uint _timestamp, uint _gasLimit, uint _gasPrice) public onlyProxy returns (uint) {
        return innerUnregister(_registrant, _key, _address, _timestamp, _gasLimit, _gasPrice);
    }

    function invokeFor(address _invoker) public onlyProxy returns (uint) {
        return innerInvoke(_invoker);
    }

    function invokeOnceFor(address _invoker) public onlyProxy returns (uint) {
        return innerInvokeOnce(_invoker);
    }

    function invokeCallback(address _invoker, KeysUtils.Object memory _record) internal returns (bool) {
        return proxy.callback(_invoker, _record.contractAddress, _record.timestamp, _record.gasLimit, _record.gasPriceGwei * GWEI);
    }
}

contract JouleProxy is JouleProxyAPI, JouleAPI, Ownable, TransferToken, usingConsts {
    JouleBehindProxy public joule;

    function setJoule(JouleBehindProxy _joule) public onlyOwner {
        joule = _joule;
    }

    modifier onlyJoule() {
        require(msg.sender == address(joule));
        _;
    }

    function () public payable {
    }

    function getCount() public view returns (uint) {
        return joule.getCount();
    }

    function register(address _address, uint _timestamp, uint _gasLimit, uint _gasPrice) external payable returns (uint) {
        return registerFor(msg.sender, _address, _timestamp, _gasLimit, _gasPrice);
    }

    function registerFor(address _registrant, address _address, uint _timestamp, uint _gasLimit, uint _gasPrice) public payable returns (uint) {
        Registered(_registrant, _address, _timestamp, _gasLimit, _gasPrice);
        uint change = joule.registerFor.value(msg.value)(_registrant, _address, _timestamp, _gasLimit, _gasPrice);
        if (change > 0) {
            msg.sender.transfer(change);
        }
        return change;
    }

    function unregister(bytes32 _key, address _address, uint _timestamp, uint _gasLimit, uint _gasPrice) external returns (uint) {
        // unregister will return funds to registrant, not to msg.sender (unlike register)
        uint amount = joule.unregisterFor(msg.sender, _key, _address, _timestamp, _gasLimit, _gasPrice);
        Unregistered(msg.sender, _address, _timestamp, _gasLimit, _gasPrice, amount);
        return amount;
    }

    function findKey(address _address, uint _timestamp, uint _gasLimit, uint _gasPrice) public view returns (bytes32) {
        return joule.findKey(_address, _timestamp, _gasLimit, _gasPrice);
    }

    function invoke() public returns (uint) {
        return invokeFor(msg.sender);
    }

    function invokeFor(address _invoker) public returns (uint) {
        uint amount = joule.invokeFor(_invoker);
        if (amount > 0) {
            msg.sender.transfer(amount);
        }
        return amount;
    }

    function invokeOnce() public returns (uint) {
        return invokeOnceFor(msg.sender);
    }

    function invokeOnceFor(address _invoker) public returns (uint) {
        uint amount = joule.invokeOnceFor(_invoker);
        if (amount > 0) {
            msg.sender.transfer(amount);
        }
        return amount;
    }


    function getPrice(uint _gasLimit, uint _gasPrice) external view returns (uint) {
        return joule.getPrice(_gasLimit, _gasPrice);
    }

    function getTopOnce() external view returns (
        address contractAddress,
        uint timestamp,
        uint gasLimit,
        uint gasPrice,
        uint invokeGas,
        uint rewardAmount
    ) {
        (contractAddress, timestamp, gasLimit, gasPrice, invokeGas, rewardAmount) = joule.getTopOnce();
    }

    function getNextOnce(address _contractAddress,
                     uint _timestamp,
                     uint _gasLimit,
                     uint _gasPrice) public view returns (
        address contractAddress,
        uint timestamp,
        uint gasLimit,
        uint gasPrice,
        uint invokeGas,
        uint rewardAmount
    ) {
        (contractAddress, timestamp, gasLimit, gasPrice, invokeGas, rewardAmount) = joule.getNextOnce(_contractAddress, _timestamp, _gasLimit, _gasPrice);
    }


    function getNext(uint _count,
                    address _contractAddress,
                    uint _timestamp,
                    uint _gasLimit,
                    uint _gasPrice) external view returns (
        address[] _addresses,
        uint[] _timestamps,
        uint[] _gasLimits,
        uint[] _gasPrices,
        uint[] _invokeGases,
        uint[] _rewardAmounts
    ) {
        _addresses = new address[](_count);
        _timestamps = new uint[](_count);
        _gasLimits = new uint[](_count);
        _gasPrices = new uint[](_count);
        _invokeGases = new uint[](_count);
        _rewardAmounts = new uint[](_count);

        uint i = 0;

        (_addresses[i], _timestamps[i], _gasLimits[i], _gasPrices[i], _invokeGases[i], _rewardAmounts[i]) = joule.getNextOnce(_contractAddress, _timestamp, _gasLimit, _gasPrice);

        for (i += 1; i < _count; i ++) {
            if (_timestamps[i - 1] == 0) {
                break;
            }
            (_addresses[i], _timestamps[i], _gasLimits[i], _gasPrices[i], _invokeGases[i], _rewardAmounts[i]) = joule.getNextOnce(_addresses[i - 1], _timestamps[i - 1], _gasLimits[i - 1], _gasPrices[i - 1]);
        }
    }


    function getTop(uint _count) external view returns (
        address[] _addresses,
        uint[] _timestamps,
        uint[] _gasLimits,
        uint[] _gasPrices,
        uint[] _invokeGases,
        uint[] _rewardAmounts
    ) {
        uint length = joule.getCount();
        uint amount = _count <= length ? _count : length;

        _addresses = new address[](amount);
        _timestamps = new uint[](amount);
        _gasLimits = new uint[](amount);
        _gasPrices = new uint[](amount);
        _invokeGases = new uint[](amount);
        _rewardAmounts = new uint[](amount);

        uint i = 0;

        (_addresses[i], _timestamps[i], _gasLimits[i], _gasPrices[i], _invokeGases[i], _rewardAmounts[i]) = joule.getTopOnce();

        for (i += 1; i < amount; i ++) {
            (_addresses[i], _timestamps[i], _gasLimits[i], _gasPrices[i], _invokeGases[i], _rewardAmounts[i]) = joule.getNextOnce(_addresses[i - 1], _timestamps[i - 1], _gasLimits[i - 1], _gasPrices[i - 1]);
        }
    }

    function getVersion() external view returns (bytes8) {
        return joule.getVersion();
    }

    function getMinGasPrice() public view returns (uint) {
        return joule.minGasPriceGwei() * GWEI;
    }

    function callback(address _invoker, address _address, uint, uint _gasLimit, uint) public onlyJoule returns (bool) {
        require(msg.gas >= _gasLimit);
        uint gas = msg.gas;
        bool status = _address.call.gas(_gasLimit)(0x919840ad);
        Invoked(_invoker, _address, status, gas - msg.gas);
        return status;
    }
}