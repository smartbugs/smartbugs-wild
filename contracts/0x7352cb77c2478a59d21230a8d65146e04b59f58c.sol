pragma solidity ^0.4.19;

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

contract TransferToken is Ownable {
    function transferToken(ERC20Basic _token, address _to, uint _value) public onlyOwner {
        _token.transfer(_to, _value);
    }
}


contract JouleProxyAPI {
    /**
     * Function hash is: 0x73027f6d
     */
    function callback(address _contract) public;
}

contract CheckableContract {
    event Checked();
    /*
     * Function hash is 0x919840ad.
     */
    function check() public;
}


contract JouleAPI {
    event Invoked(address indexed _address, bool _status, uint _usedGas);
    event Registered(address indexed _address, uint _timestamp, uint _gasLimit, uint _gasPrice);

    /**
     * @dev Registers the specified contract to invoke at the specified time with the specified gas and price.
     * @notice It required amount of ETH as value, to cover gas usage. See getPrice method.
     *
     * @param _address Contract's address. Contract MUST implements Checkable interface.
     * @param _timestamp Timestamp at what moment contract should be called. It MUST be in future.
     * @param _gasLimit Gas which will be posted to call.
     * @param _gasPrice Gas price which is recommended to use for this invocation.
     */
    function register(address _address, uint _timestamp, uint _gasLimit, uint _gasPrice) external payable returns (uint);

    /**
     * @dev Invokes next contracts in the queue.
     * @notice Eth amount to cover gas will be returned if gas price is equal or less then specified for contract. Check getTop for right gas price.
     * @return Reward amount.
     */
    function invoke() public returns (uint);

    /**
     * @dev Invokes the top contract in the queue.
     * @notice Eth amount to cover gas will be returned if gas price is equal or less then specified for contract. Check getTop for right gas price.
     * @return Reward amount.
     */
    function invokeTop() public returns (uint);

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
     * @return gasLimit         The invocation maximum gas.
     * @return gasPrice         The invocation expected price.
     */
    function getTop() external view returns (
        address contractAddress,
        uint timestamp,
        uint gasLimit,
        uint gasPrice
    );

    /**
     * @dev Gets top _count contracts (in order to invoke).
     *
     * @param _count        How many records will be returned.
     * @return addresses    The contracts addresses.
     * @return timestamps   The invocation timestamps.
     * @return gasLimits    The invocation gas limits.
     * @return gasPrices    The invocation expected prices.
     */
    function getTop(uint _count) external view returns (
        address[] addresses,
        uint[] timestamps,
        uint[] gasLimits,
        uint[] gasPrices
    );

    /**
     * @dev Gets actual code version.
     * @return Code version. Mask: 0xff.0xff.0xffff-0xffffffff (major.minor.build-hash)
     */
    function getVersion() external view returns (bytes8);
}



contract usingConsts {
    uint constant GWEI = 0.001 szabo;
    // this value influence to the reward price! do not change for already registered contracts!
    uint constant IDLE_GAS = 22273;
    uint constant MAX_GAS = 4000000;
    // Code version
    bytes8 constant VERSION = 0x0100001300000000;
    //                        ^^ - major
    //                          ^^ - minor
    //                            ^^^^ - build
    //                                ^^^^^^^^ - git hash
}


contract JouleIndex {
    using KeysUtils for bytes32;
    uint constant YEAR = 0x1DFE200;

    // year -> month -> day -> hour
    mapping (bytes32 => bytes32) index;
    bytes32 head;

    function insert(bytes32 _key) public {
        uint timestamp = _key.getTimestamp();
        bytes32 year = toKey(timestamp, YEAR);
        bytes32 headLow;
        bytes32 headHigh;
        (headLow, headHigh) = fromValue(head);
        if (year < headLow || headLow == 0 || year > headHigh) {
            if (year < headLow || headLow == 0) {
                headLow = year;
            }
            if (year > headHigh) {
                headHigh = year;
            }
            head = toValue(headLow, headHigh);
        }

        bytes32 week = toKey(timestamp, 1 weeks);
        bytes32 low;
        bytes32 high;
        (low, high) = fromValue(index[year]);
        if (week < low || week > high) {
            if (week < low || low == 0) {
                low = week;
            }
            if (week > high) {
                high = week;
            }
            index[year] = toValue(low, high);
        }

        (low, high) = fromValue(index[week]);
        bytes32 hour = toKey(timestamp, 1 hours);
        if (hour < low || hour > high) {
            if (hour < low || low == 0) {
                low = hour;
            }
            if (hour > high) {
                high = hour;
            }
            index[week] = toValue(low, high);
        }

        (low, high) = fromValue(index[hour]);
        bytes32 minute = toKey(timestamp, 1 minutes);
        if (minute < low || minute > high) {
            if (minute < low || low == 0) {
                low = minute;
            }
            if (minute > high) {
                high = minute;
            }
            index[hour] = toValue(low, high);
        }

        (low, high) = fromValue(index[minute]);
        bytes32 tsKey = toKey(timestamp);
        if (tsKey < low || tsKey > high) {
            if (tsKey < low || low == 0) {
                low = tsKey;
            }
            if (tsKey > high) {
                high = tsKey;
            }
            index[minute] = toValue(low, high);
        }

        index[tsKey] = _key;
    }

    function findFloorKeyYear(uint _timestamp, bytes32 _low, bytes32 _high) view internal returns (bytes32) {
        bytes32 year = toKey(_timestamp, YEAR);
        if (year < _low) {
            return 0;
        }
        if (year > _high) {
            // week
            (low, high) = fromValue(index[_high]);
            // hour
            (low, high) = fromValue(index[high]);
            // minute
            (low, high) = fromValue(index[high]);
            // ts
            (low, high) = fromValue(index[high]);
            return index[high];
        }

        bytes32 low;
        bytes32 high;

        while (year >= _low) {
            (low, high) = fromValue(index[year]);
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

    function findFloorKeyWeek(uint _timestamp, bytes32 _low, bytes32 _high) view internal returns (bytes32) {
        bytes32 week = toKey(_timestamp, 1 weeks);
        if (week < _low) {
            return 0;
        }

        bytes32 low;
        bytes32 high;

        if (week > _high) {
            // hour
            (low, high) = fromValue(index[_high]);
            // minute
            (low, high) = fromValue(index[high]);
            // ts
            (low, high) = fromValue(index[high]);
            return index[high];
        }

        while (week >= _low) {
            (low, high) = fromValue(index[week]);
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


    function findFloorKeyHour(uint _timestamp, bytes32 _low, bytes32 _high) view internal returns (bytes32) {
        bytes32 hour = toKey(_timestamp, 1 hours);
        if (hour < _low) {
            return 0;
        }

        bytes32 low;
        bytes32 high;

        if (hour > _high) {
            // minute
            (low, high) = fromValue(index[_high]);
            // ts
            (low, high) = fromValue(index[high]);
            return index[high];
        }

        while (hour >= _low) {
            (low, high) = fromValue(index[hour]);
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

    function findFloorKeyMinute(uint _timestamp, bytes32 _low, bytes32 _high) view internal returns (bytes32) {
        bytes32 minute = toKey(_timestamp, 1 minutes);
        if (minute < _low) {
            return 0;
        }

        bytes32 low;
        bytes32 high;

        if (minute > _high) {
            // ts
            (low, high) = fromValue(index[_high]);
            return index[high];
        }

        while (minute >= _low) {
            (low, high) = fromValue(index[minute]);
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

    function findFloorKeyTimestamp(uint _timestamp, bytes32 _low, bytes32 _high) view internal returns (bytes32) {
        bytes32 tsKey = toKey(_timestamp);
        if (tsKey < _low) {
            return 0;
        }
        if (tsKey > _high) {
            return index[_high];
        }

        while (tsKey >= _low) {
            bytes32 key = index[tsKey];
            if (key != 0) {
                return key;
            }
            assembly {
                tsKey := sub(tsKey, 1)
            }
        }
        return 0;
    }

    function findFloorKey(uint _timestamp) view public returns (bytes32) {
//        require(_timestamp > 0xffffffff);
//        if (_timestamp < 1515612415) {
//            return 0;
//        }

        bytes32 yearLow;
        bytes32 yearHigh;
        (yearLow, yearHigh) = fromValue(head);

        return findFloorKeyYear(_timestamp, yearLow, yearHigh);
    }

    function toKey(uint _timestamp, uint rounder) pure internal returns (bytes32 result) {
        // 0x0...00000000000000000
        //        ^^^^^^^^ - rounder marker (eg, to avoid crossing first day of year with year)
        //                ^^^^^^^^ - rounded moment (year, week, etc)
        assembly {
            result := or(mul(rounder, 0x100000000), mul(div(_timestamp, rounder), rounder))
        }
    }

    function toValue(bytes32 _lowKey, bytes32 _highKey) pure internal returns (bytes32 result) {
        assembly {
            result := or(mul(_lowKey, 0x10000000000000000), _highKey)
        }
    }

    function fromValue(bytes32 _value) pure internal returns (bytes32 _lowKey, bytes32 _highKey) {
        assembly {
            _lowKey := and(div(_value, 0x10000000000000000), 0xffffffffffffffff)
            _highKey := and(_value, 0xffffffffffffffff)
        }
    }


    function toKey(uint timestamp) pure internal returns (bytes32) {
        return bytes32(timestamp);
    }
}


contract JouleContractHolder is usingConsts {
    using KeysUtils for bytes32;
//    event Found(uint timestamp);
    uint internal length;
    bytes32 head;
    mapping (bytes32 => bytes32) objects;
    JouleIndex index;

    function JouleContractHolder() public {
        index = new JouleIndex();
    }

    function insert(address _address, uint _timestamp, uint _gasLimit, uint _gasPrice) internal {
        length ++;
        bytes32 id = KeysUtils.toKey(_address, _timestamp, _gasLimit, _gasPrice);
        if (head == 0) {
            head = id;
            index.insert(id);
//            Found(0xffffffff);
            return;
        }
        bytes32 previous = index.findFloorKey(_timestamp);

        // reject duplicate key on the end
        require(previous != id);
        // reject duplicate in the middle
        require(objects[id] == 0);

        uint prevTimestamp = previous.getTimestamp();
//        Found(prevTimestamp);
        uint headTimestamp = head.getTimestamp();
        // add as head, prevTimestamp == 0 or in the past
        if (prevTimestamp < headTimestamp) {
            objects[id] = head;
            head = id;
        }
        // add after the previous
        else {
            objects[id] = objects[previous];
            objects[previous] = id;
        }
        index.insert(id);
    }

    function next() internal returns (KeysUtils.Object memory _next) {
        head = objects[head];
        length--;
        _next = head.toObject();
    }

    function getCount() public view returns (uint) {
        return length;
    }

    function getTop(uint _count) external view returns (
        address[] _addresses,
        uint[] _timestamps,
        uint[] _gasLimits,
        uint[] _gasPrices
    ) {
        uint amount = _count <= length ? _count : length;

        _addresses = new address[](amount);
        _timestamps = new uint[](amount);
        _gasLimits = new uint[](amount);
        _gasPrices = new uint[](amount);

        bytes32 current = head;
        for (uint i = 0; i < amount; i ++) {
            KeysUtils.Object memory obj = current.toObject();
            _addresses[i] = obj.contractAddress;
            _timestamps[i] = obj.timestamp;
            _gasLimits[i] = obj.gasLimit;
            _gasPrices[i] = obj.gasPriceGwei * GWEI;
            current = objects[current];
        }
        }

    function getTop() external view returns (
        address contractAddress,
        uint timestamp,
        uint gasLimit,
        uint gasPrice
    ) {
        KeysUtils.Object memory obj = head.toObject();

        contractAddress = obj.contractAddress;
        timestamp = obj.timestamp;
        gasLimit = obj.gasLimit;
        gasPrice = obj.gasPriceGwei * GWEI;
    }
    
        function getNext(address _contractAddress,
                     uint _timestamp,
                     uint _gasLimit,
                     uint _gasPrice) public view returns (
        address contractAddress,
        uint timestamp,
        uint gasLimit,
        uint gasPrice
    ) {
        if (_timestamp == 0) {
            return this.getTop();
        }

        bytes32 prev = KeysUtils.toKey(_contractAddress, _timestamp, _gasLimit, _gasPrice / GWEI);
        bytes32 current = objects[prev];
        KeysUtils.Object memory obj = current.toObject();

        contractAddress = obj.contractAddress;
        timestamp = obj.timestamp;
        gasLimit = obj.gasLimit;
        gasPrice = obj.gasPriceGwei * GWEI;
    }

}


contract Joule is JouleAPI, JouleContractHolder {
    function register(address _address, uint _timestamp, uint _gasLimit, uint _gasPrice) external payable returns (uint) {
        uint price = this.getPrice(_gasLimit, _gasPrice);
        require(msg.value >= price);

        require(_timestamp > now);
        require(_timestamp < 0x100000000);
        require(_gasLimit < MAX_GAS);
        // from 1 gwei to 0x100000000 gwei
        require(_gasPrice > GWEI);
        require(_gasPrice < 0x100000000 * GWEI);

        insert(_address, _timestamp, _gasLimit, _gasPrice / GWEI);

        Registered(_address, _timestamp, _gasLimit, _gasPrice);

        if (msg.value > price) {
            msg.sender.transfer(msg.value - price);
            return msg.value - price;
        }
        return 0;
    }

    function getPrice(uint _gasLimit, uint _gasPrice) external view returns (uint) {
        require(_gasLimit < 4300000);
        require(_gasPrice > GWEI);
        require(_gasPrice < 0x100000000 * GWEI);

        return getPriceInner(_gasLimit, _gasPrice);
    }

    function getPriceInner(uint _gasLimit, uint _gasPrice) internal pure returns (uint) {
        return (_gasLimit + IDLE_GAS) * _gasPrice;
    }

    function invoke() public returns (uint) {
        return innerInvoke(invokeCallback);
    }

    function invokeTop() public returns (uint) {
        return innerInvokeTop(invokeCallback);
    }

    function getVersion() external view returns (bytes8) {
        return VERSION;
    }

    function innerInvoke(function (address, uint) internal returns (bool) _callback) internal returns (uint _amount) {
        KeysUtils.Object memory current = KeysUtils.toObject(head);

        uint amount;
        while (current.timestamp != 0 && current.timestamp < now && msg.gas >= current.gasLimit) {
            uint gas = msg.gas;
            bool status = _callback(current.contractAddress, current.gasLimit);
//            current.contractAddress.call.gas(current.gasLimit)(0x919840ad);
            gas -= msg.gas;
            Invoked(current.contractAddress, status, gas);

            amount += getPriceInner(current.gasLimit, current.gasPriceGwei * GWEI);
            current = next();
        }
        if (amount > 0) {
            msg.sender.transfer(amount);
        }
        return amount;
    }

    function innerInvokeTop(function (address, uint) internal returns (bool) _callback) internal returns (uint _amount) {
        KeysUtils.Object memory current = KeysUtils.toObject(head);
        uint gas = msg.gas;
        bool status = _callback(current.contractAddress, current.gasLimit);
        gas -= msg.gas;

        Invoked(current.contractAddress, status, gas);

        uint amount = getPriceInner(current.gasLimit, current.gasPriceGwei * GWEI);

        if (amount > 0) {
            msg.sender.transfer(amount);
        }
        return amount;
    }


    function invokeCallback(address _contract, uint _gas) internal returns (bool) {
        return _contract.call.gas(_gas)(0x919840ad);
    }

}


contract JouleBehindProxy is Joule, Ownable, TransferToken {
    address public proxy;

    function setProxy(address _proxy) public onlyOwner {
        proxy = _proxy;
    }

    modifier onlyProxy() {
        require(msg.sender == proxy);
        _;
    }

    function invoke() public onlyProxy returns (uint) {
        return super.invoke();
    }

    function invokeTop() public onlyProxy returns (uint) {
        return super.invokeTop();
    }

    function invokeCallback(address _contract, uint _gas) internal returns (bool) {
        return proxy.call.gas(_gas)(0x73027f6d, _contract);
    }
}

contract JouleProxy is JouleProxyAPI, JouleAPI, Ownable, TransferToken {
    JouleBehindProxy public joule;

    function setJoule(JouleBehindProxy _joule) public onlyOwner {
        joule = _joule;
    }

    modifier onlyJoule() {
        require(msg.sender == address(joule));
        _;
    }

    function () public payable onlyJoule {
    }

    function getCount() public view returns (uint) {
        return joule.getCount();
    }

    function register(address _address, uint _timestamp, uint _gasLimit, uint _gasPrice) external payable returns (uint) {
        uint change = joule.register.value(msg.value)(_address, _timestamp, _gasLimit, _gasPrice);
        if (change > 0) {
            msg.sender.transfer(change);
        }
        return change;
    }

    function invoke() public returns (uint) {
        uint amount = joule.invoke();
        if (amount > 0) {
            msg.sender.transfer(amount);
        }
        return amount;
    }

    function invokeTop() public returns (uint) {
        uint amount = joule.invokeTop();
        if (amount > 0) {
            msg.sender.transfer(amount);
        }
        return amount;
    }

    function getPrice(uint _gasLimit, uint _gasPrice) external view returns (uint) {
        return joule.getPrice(_gasLimit, _gasPrice);
    }

    function getTop() external view returns (
        address contractAddress,
        uint timestamp,
        uint gasLimit,
        uint gasPrice
    ) {
        (contractAddress, timestamp, gasLimit, gasPrice) = joule.getTop();
    }

    function getNext(address _contractAddress,
                     uint _timestamp,
                     uint _gasLimit,
                     uint _gasPrice) public view returns (
        address contractAddress,
        uint timestamp,
        uint gasLimit,
        uint gasPrice
    ) {
        (contractAddress, timestamp, gasLimit, gasPrice) = joule.getNext(_contractAddress, _timestamp, _gasLimit, _gasPrice);
    }



    function getTop(uint _count) external view returns (
        address[] _addresses,
        uint[] _timestamps,
        uint[] _gasLimits,
        uint[] _gasPrices
    ) {
        uint length = joule.getCount();
        uint amount = _count <= length ? _count : length;

        _addresses = new address[](amount);
        _timestamps = new uint[](amount);
        _gasLimits = new uint[](amount);
        _gasPrices = new uint[](amount);

        address contractAddress;
        uint timestamp;
        uint gasLimit;
        uint gasPrice;

        (contractAddress, timestamp, gasLimit, gasPrice) = joule.getTop();
        _addresses[0] = contractAddress;
        _timestamps[0] = timestamp;
        _gasLimits[0] = gasLimit;
        _gasPrices[0] = gasPrice;

        for (uint i = 1; i < amount; i ++) {
            (contractAddress, timestamp, gasLimit, gasPrice) = joule.getNext(contractAddress, timestamp, gasLimit, gasPrice);
            _addresses[i] = contractAddress;
            _timestamps[i] = timestamp;
            _gasLimits[i] = gasLimit;
            _gasPrices[i] = gasPrice;
        }
    }

    function getVersion() external view returns (bytes8) {
        return joule.getVersion();
    }

    function callback(address _contract) public onlyJoule {
        CheckableContract(_contract).check();
    }
}