pragma solidity ^0.5.0;



/// @title SelfAuthorized - authorizes current contract to perform actions
/// @author Richard Meissner - <richard@gnosis.pm>
contract SelfAuthorized {
    modifier authorized() {
        require(msg.sender == address(this), "Method can only be called from this contract");
        _;
    }
}


/// @title MasterCopy - Base for master copy contracts (should always be first super contract)
/// @author Richard Meissner - <richard@gnosis.pm>
contract MasterCopy is SelfAuthorized {
  // masterCopy always needs to be first declared variable, to ensure that it is at the same location as in the Proxy contract.
  // It should also always be ensured that the address is stored alone (uses a full word)
    address masterCopy;

  /// @dev Allows to upgrade the contract. This can only be done via a Safe transaction.
  /// @param _masterCopy New contract address.
    function changeMasterCopy(address _masterCopy)
        public
        authorized
    {
        // Master copy address cannot be null.
        require(_masterCopy != address(0), "Invalid master copy address provided");
        masterCopy = _masterCopy;
    }
}


/// @title Enum - Collection of enums
/// @author Richard Meissner - <richard@gnosis.pm>
contract Enum {
    enum Operation {
        Call,
        DelegateCall,
        Create
    }
}


/// @title EtherPaymentFallback - A contract that has a fallback to accept ether payments
/// @author Richard Meissner - <richard@gnosis.pm>
contract EtherPaymentFallback {

    /// @dev Fallback function accepts Ether transactions.
    function ()
        external
        payable
    {

    }
}


/// @title Executor - A contract that can execute transactions
/// @author Richard Meissner - <richard@gnosis.pm>
contract Executor is EtherPaymentFallback {

    event ContractCreation(address newContract);

    function execute(address to, uint256 value, bytes memory data, Enum.Operation operation, uint256 txGas)
        internal
        returns (bool success)
    {
        if (operation == Enum.Operation.Call)
            success = executeCall(to, value, data, txGas);
        else if (operation == Enum.Operation.DelegateCall)
            success = executeDelegateCall(to, data, txGas);
        else {
            address newContract = executeCreate(data);
            success = newContract != address(0);
            emit ContractCreation(newContract);
        }
    }

    function executeCall(address to, uint256 value, bytes memory data, uint256 txGas)
        internal
        returns (bool success)
    {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := call(txGas, to, value, add(data, 0x20), mload(data), 0, 0)
        }
    }

    function executeDelegateCall(address to, bytes memory data, uint256 txGas)
        internal
        returns (bool success)
    {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := delegatecall(txGas, to, add(data, 0x20), mload(data), 0, 0)
        }
    }

    function executeCreate(bytes memory data)
        internal
        returns (address newContract)
    {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            newContract := create(0, add(data, 0x20), mload(data))
        }
    }
}


/// @title Module Manager - A contract that manages modules that can execute transactions via this contract
/// @author Stefan George - <stefan@gnosis.pm>
/// @author Richard Meissner - <richard@gnosis.pm>
contract ModuleManager is SelfAuthorized, Executor {

    event EnabledModule(Module module);
    event DisabledModule(Module module);

    address public constant SENTINEL_MODULES = address(0x1);

    mapping (address => address) internal modules;
    
    function setupModules(address to, bytes memory data)
        internal
    {
        require(modules[SENTINEL_MODULES] == address(0), "Modules have already been initialized");
        modules[SENTINEL_MODULES] = SENTINEL_MODULES;
        if (to != address(0))
            // Setup has to complete successfully or transaction fails.
            require(executeDelegateCall(to, data, gasleft()), "Could not finish initialization");
    }

    /// @dev Allows to add a module to the whitelist.
    ///      This can only be done via a Safe transaction.
    /// @param module Module to be whitelisted.
    function enableModule(Module module)
        public
        authorized
    {
        // Module address cannot be null or sentinel.
        require(address(module) != address(0) && address(module) != SENTINEL_MODULES, "Invalid module address provided");
        // Module cannot be added twice.
        require(modules[address(module)] == address(0), "Module has already been added");
        modules[address(module)] = modules[SENTINEL_MODULES];
        modules[SENTINEL_MODULES] = address(module);
        emit EnabledModule(module);
    }

    /// @dev Allows to remove a module from the whitelist.
    ///      This can only be done via a Safe transaction.
    /// @param prevModule Module that pointed to the module to be removed in the linked list
    /// @param module Module to be removed.
    function disableModule(Module prevModule, Module module)
        public
        authorized
    {
        // Validate module address and check that it corresponds to module index.
        require(address(module) != address(0) && address(module) != SENTINEL_MODULES, "Invalid module address provided");
        require(modules[address(prevModule)] == address(module), "Invalid prevModule, module pair provided");
        modules[address(prevModule)] = modules[address(module)];
        modules[address(module)] = address(0);
        emit DisabledModule(module);
    }

    /// @dev Allows a Module to execute a Safe transaction without any further confirmations.
    /// @param to Destination address of module transaction.
    /// @param value Ether value of module transaction.
    /// @param data Data payload of module transaction.
    /// @param operation Operation type of module transaction.
    function execTransactionFromModule(address to, uint256 value, bytes memory data, Enum.Operation operation)
        public
        returns (bool success)
    {
        // Only whitelisted modules are allowed.
        require(msg.sender != SENTINEL_MODULES && modules[msg.sender] != address(0), "Method can only be called from an enabled module");
        // Execute transaction without further confirmations.
        success = execute(to, value, data, operation, gasleft());
    }

    /// @dev Returns array of modules.
    /// @return Array of modules.
    function getModules()
        public
        view
        returns (address[] memory)
    {
        // Calculate module count
        uint256 moduleCount = 0;
        address currentModule = modules[SENTINEL_MODULES];
        while(currentModule != SENTINEL_MODULES) {
            currentModule = modules[currentModule];
            moduleCount ++;
        }
        address[] memory array = new address[](moduleCount);

        // populate return array
        moduleCount = 0;
        currentModule = modules[SENTINEL_MODULES];
        while(currentModule != SENTINEL_MODULES) {
            array[moduleCount] = currentModule;
            currentModule = modules[currentModule];
            moduleCount ++;
        }
        return array;
    }
}


/// @title Module - Base class for modules.
/// @author Stefan George - <stefan@gnosis.pm>
/// @author Richard Meissner - <richard@gnosis.pm>
contract Module is MasterCopy {

    ModuleManager public manager;

    modifier authorized() {
        require(msg.sender == address(manager), "Method can only be called from manager");
        _;
    }

    function setManager()
        internal
    {
        // manager can only be 0 at initalization of contract.
        // Check ensures that setup function can only be called once.
        require(address(manager) == address(0), "Manager has already been set");
        manager = ModuleManager(msg.sender);
    }
}

/// @title OwnerManager - Manages a set of owners and a threshold to perform actions.
/// @author Stefan George - <stefan@gnosis.pm>
/// @author Richard Meissner - <richard@gnosis.pm>
contract OwnerManager is SelfAuthorized {

    event AddedOwner(address owner);
    event RemovedOwner(address owner);
    event ChangedThreshold(uint256 threshold);

    address public constant SENTINEL_OWNERS = address(0x1);

    mapping(address => address) internal owners;
    uint256 ownerCount;
    uint256 internal threshold;

    /// @dev Setup function sets initial storage of contract.
    /// @param _owners List of Safe owners.
    /// @param _threshold Number of required confirmations for a Safe transaction.
    function setupOwners(address[] memory _owners, uint256 _threshold)
        internal
    {
        // Threshold can only be 0 at initialization.
        // Check ensures that setup function can only be called once.
        require(threshold == 0, "Owners have already been setup");
        // Validate that threshold is smaller than number of added owners.
        require(_threshold <= _owners.length, "Threshold cannot exceed owner count");
        // There has to be at least one Safe owner.
        require(_threshold >= 1, "Threshold needs to be greater than 0");
        // Initializing Safe owners.
        address currentOwner = SENTINEL_OWNERS;
        for (uint256 i = 0; i < _owners.length; i++) {
            // Owner address cannot be null.
            address owner = _owners[i];
            require(owner != address(0) && owner != SENTINEL_OWNERS, "Invalid owner address provided");
            // No duplicate owners allowed.
            require(owners[owner] == address(0), "Duplicate owner address provided");
            owners[currentOwner] = owner;
            currentOwner = owner;
        }
        owners[currentOwner] = SENTINEL_OWNERS;
        ownerCount = _owners.length;
        threshold = _threshold;
    }

    /// @dev Allows to add a new owner to the Safe and update the threshold at the same time.
    ///      This can only be done via a Safe transaction.
    /// @param owner New owner address.
    /// @param _threshold New threshold.
    function addOwnerWithThreshold(address owner, uint256 _threshold)
        public
        authorized
    {
        // Owner address cannot be null.
        require(owner != address(0) && owner != SENTINEL_OWNERS, "Invalid owner address provided");
        // No duplicate owners allowed.
        require(owners[owner] == address(0), "Address is already an owner");
        owners[owner] = owners[SENTINEL_OWNERS];
        owners[SENTINEL_OWNERS] = owner;
        ownerCount++;
        emit AddedOwner(owner);
        // Change threshold if threshold was changed.
        if (threshold != _threshold)
            changeThreshold(_threshold);
    }

    /// @dev Allows to remove an owner from the Safe and update the threshold at the same time.
    ///      This can only be done via a Safe transaction.
    /// @param prevOwner Owner that pointed to the owner to be removed in the linked list
    /// @param owner Owner address to be removed.
    /// @param _threshold New threshold.
    function removeOwner(address prevOwner, address owner, uint256 _threshold)
        public
        authorized
    {
        // Only allow to remove an owner, if threshold can still be reached.
        require(ownerCount - 1 >= _threshold, "New owner count needs to be larger than new threshold");
        // Validate owner address and check that it corresponds to owner index.
        require(owner != address(0) && owner != SENTINEL_OWNERS, "Invalid owner address provided");
        require(owners[prevOwner] == owner, "Invalid prevOwner, owner pair provided");
        owners[prevOwner] = owners[owner];
        owners[owner] = address(0);
        ownerCount--;
        emit RemovedOwner(owner);
        // Change threshold if threshold was changed.
        if (threshold != _threshold)
            changeThreshold(_threshold);
    }

    /// @dev Allows to swap/replace an owner from the Safe with another address.
    ///      This can only be done via a Safe transaction.
    /// @param prevOwner Owner that pointed to the owner to be replaced in the linked list
    /// @param oldOwner Owner address to be replaced.
    /// @param newOwner New owner address.
    function swapOwner(address prevOwner, address oldOwner, address newOwner)
        public
        authorized
    {
        // Owner address cannot be null.
        require(newOwner != address(0) && newOwner != SENTINEL_OWNERS, "Invalid owner address provided");
        // No duplicate owners allowed.
        require(owners[newOwner] == address(0), "Address is already an owner");
        // Validate oldOwner address and check that it corresponds to owner index.
        require(oldOwner != address(0) && oldOwner != SENTINEL_OWNERS, "Invalid owner address provided");
        require(owners[prevOwner] == oldOwner, "Invalid prevOwner, owner pair provided");
        owners[newOwner] = owners[oldOwner];
        owners[prevOwner] = newOwner;
        owners[oldOwner] = address(0);
        emit RemovedOwner(oldOwner);
        emit AddedOwner(newOwner);
    }

    /// @dev Allows to update the number of required confirmations by Safe owners.
    ///      This can only be done via a Safe transaction.
    /// @param _threshold New threshold.
    function changeThreshold(uint256 _threshold)
        public
        authorized
    {
        // Validate that threshold is smaller than number of owners.
        require(_threshold <= ownerCount, "Threshold cannot exceed owner count");
        // There has to be at least one Safe owner.
        require(_threshold >= 1, "Threshold needs to be greater than 0");
        threshold = _threshold;
        emit ChangedThreshold(threshold);
    }

    function getThreshold()
        public
        view
        returns (uint256)
    {
        return threshold;
    }

    function isOwner(address owner)
        public
        view
        returns (bool)
    {
        return owner != SENTINEL_OWNERS && owners[owner] != address(0);
    }

    /// @dev Returns array of owners.
    /// @return Array of Safe owners.
    function getOwners()
        public
        view
        returns (address[] memory)
    {
        address[] memory array = new address[](ownerCount);

        // populate return array
        uint256 index = 0;
        address currentOwner = owners[SENTINEL_OWNERS];
        while(currentOwner != SENTINEL_OWNERS) {
            array[index] = currentOwner;
            currentOwner = owners[currentOwner];
            index ++;
        }
        return array;
    }
}

/// @title GEnum - Collection of enums for subscriptions
/// @author Andrew Redden - <andrew@groundhog.network>
contract GEnum {
    enum SubscriptionStatus {
        INIT,
        TRIAL,
        VALID,
        CANCELLED,
        EXPIRED
    }

    enum Period {
        INIT,
        DAY,
        WEEK,
        MONTH,
        YEAR
    }
}


/// @title SignatureDecoder - Decodes signatures that a encoded as bytes
/// @author Ricardo Guilherme Schmidt (Status Research & Development GmbH) 
/// @author Richard Meissner - <richard@gnosis.pm>
contract SignatureDecoder {
    
    /// @dev Recovers address who signed the message 
    /// @param messageHash operation ethereum signed message hash
    /// @param messageSignature message `txHash` signature
    /// @param pos which signature to read
    function recoverKey (
        bytes32 messageHash, 
        bytes memory messageSignature,
        uint256 pos
    )
        internal
        pure
        returns (address) 
    {
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = signatureSplit(messageSignature, pos);
        return ecrecover(messageHash, v, r, s);
    }

    /// @dev divides bytes signature into `uint8 v, bytes32 r, bytes32 s`
    /// @param pos which signature to read
    /// @param signatures concatenated rsv signatures
    function signatureSplit(bytes memory signatures, uint256 pos)
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        // The signature format is a compact form of:
        //   {bytes32 r}{bytes32 s}{uint8 v}
        // Compact means, uint8 is not padded to 32 bytes.
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let signaturePos := mul(0x41, pos)
            r := mload(add(signatures, add(signaturePos, 0x20)))
            s := mload(add(signatures, add(signaturePos, 0x40)))
            // Here we are loading the last 32 bytes, including 31 bytes
            // of 's'. There is no 'mload8' to do this.
            //
            // 'byte' is not working due to the Solidity parser, so lets
            // use the second best option, 'and'
            v := and(mload(add(signatures, add(signaturePos, 0x41))), 0xff)
        }
    }
}

// ----------------------------------------------------------------------------
// BokkyPooBah's DateTime Library v1.00
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
// dayOfWeek | 1 ... 7       | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018.
//
// GNU Lesser General Public License 3.0
// https://www.gnu.org/licenses/lgpl-3.0.en.html
// ----------------------------------------------------------------------------

library BokkyPooBahsDateTimeLibrary {

    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;

    uint constant DOW_MON = 1;
    uint constant DOW_TUE = 2;
    uint constant DOW_WED = 3;
    uint constant DOW_THU = 4;
    uint constant DOW_FRI = 5;
    uint constant DOW_SAT = 6;
    uint constant DOW_SUN = 7;

    // ------------------------------------------------------------------------
    // Calculate the number of days from 1970/01/01 to year/month/day using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and subtracting the offset 2440588 so that 1970/01/01 is day 0
    //
    // days = day
    //      - 32075
    //      + 1461 * (year + 4800 + (month - 14) / 12) / 4
    //      + 367 * (month - 2 - (month - 14) / 12 * 12) / 12
    //      - 3 * ((year + 4900 + (month - 14) / 12) / 100) / 4
    //      - offset
    // ------------------------------------------------------------------------
    function _daysFromDate(uint year, uint month, uint day) internal pure returns (uint _days) {
        require(year >= 1970);
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);

        int __days = _day
        - 32075
        + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
        + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
        - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
        - OFFSET19700101;

        _days = uint(__days);
    }

    // ------------------------------------------------------------------------
    // Calculate year/month/day from the number of days since 1970/01/01 using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and adding the offset 2440588 so that 1970/01/01 is day 0
    //
    // int L = days + 68569 + offset
    // int N = 4 * L / 146097
    // L = L - (146097 * N + 3) / 4
    // year = 4000 * (L + 1) / 1461001
    // L = L - 1461 * year / 4 + 31
    // month = 80 * L / 2447
    // dd = L - 2447 * month / 80
    // L = month / 11
    // month = month + 2 - 12 * L
    // year = 100 * (N - 49) + year + L
    // ------------------------------------------------------------------------
    function _daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {
        int __days = int(_days);

        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

    function timestampFromDate(uint year, uint month, uint day) internal pure returns (uint timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }
    function timestampFromDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (uint timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + hour * SECONDS_PER_HOUR + minute * SECONDS_PER_MINUTE + second;
    }
    function timestampToDate(uint timestamp) internal pure returns (uint year, uint month, uint day) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function timestampToDateTime(uint timestamp) internal pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }

    function isValidDate(uint year, uint month, uint day) internal pure returns (bool valid) {
        if (year >= 1970 && month > 0 && month <= 12) {
            uint daysInMonth = _getDaysInMonth(year, month);
            if (day > 0 && day <= daysInMonth) {
                valid = true;
            }
        }
    }
    function isValidDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (bool valid) {
        if (isValidDate(year, month, day)) {
            if (hour < 24 && minute < 60 && second < 60) {
                valid = true;
            }
        }
    }
    function isLeapYear(uint timestamp) internal pure returns (bool leapYear) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }
    function _isLeapYear(uint year) internal pure returns (bool leapYear) {
        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }
    function isWeekDay(uint timestamp) internal pure returns (bool weekDay) {
        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }
    function isWeekEnd(uint timestamp) internal pure returns (bool weekEnd) {
        weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
    }
    function getDaysInMonth(uint timestamp) internal pure returns (uint daysInMonth) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        daysInMonth = _getDaysInMonth(year, month);
    }
    function _getDaysInMonth(uint year, uint month) internal pure returns (uint daysInMonth) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }
    // 1 = Monday, 7 = Sunday
    function getDayOfWeek(uint timestamp) internal pure returns (uint dayOfWeek) {
        uint _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = (_days + 3) % 7 + 1;
    }

    function getYear(uint timestamp) internal pure returns (uint year) {
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getMonth(uint timestamp) internal pure returns (uint month) {
        uint year;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getDay(uint timestamp) internal pure returns (uint day) {
        uint year;
        uint month;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getHour(uint timestamp) internal pure returns (uint hour) {
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }
    function getMinute(uint timestamp) internal pure returns (uint minute) {
        uint secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }
    function getSecond(uint timestamp) internal pure returns (uint second) {
        second = timestamp % SECONDS_PER_MINUTE;
    }

    function addYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year += _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = (month - 1) % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        require(newTimestamp >= timestamp);
    }
    function addMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp);
    }
    function addSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _seconds;
        require(newTimestamp >= timestamp);
    }

    function subYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year -= _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = yearMonth % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        require(newTimestamp <= timestamp);
    }
    function subMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp <= timestamp);
    }
    function subSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _seconds;
        require(newTimestamp <= timestamp);
    }

    function diffYears(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _years) {
        require(fromTimestamp <= toTimestamp);
        uint fromYear;
        uint fromMonth;
        uint fromDay;
        uint toYear;
        uint toMonth;
        uint toDay;
        (fromYear, fromMonth, fromDay) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (toYear, toMonth, toDay) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }
    function diffMonths(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _months) {
        require(fromTimestamp <= toTimestamp);
        uint fromYear;
        uint fromMonth;
        uint fromDay;
        uint toYear;
        uint toMonth;
        uint toDay;
        (fromYear, fromMonth, fromDay) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (toYear, toMonth, toDay) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }
    function diffDays(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _days) {
        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }
    function diffHours(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _hours) {
        require(fromTimestamp <= toTimestamp);
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }
    function diffMinutes(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _minutes) {
        require(fromTimestamp <= toTimestamp);
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }
    function diffSeconds(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _seconds) {
        require(fromTimestamp <= toTimestamp);
        _seconds = toTimestamp - fromTimestamp;
    }
}
/// math.sol -- mixin for inline numerical wizardry

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.


library DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    function tmul(uint x, uint y, uint z) internal pure returns (uint a) {
        require(z != 0);
        a = add(mul(x, y), z / 2) / z;
    }

    function tdiv(uint x, uint y, uint z) internal pure returns (uint a) {
        a = add(mul(x, z), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}


interface OracleRegistry {

    function read(
        uint256 currencyPair
    ) external view returns (bytes32);

    function getNetworkExecutor()
    external
    view
    returns (address);

    function getNetworkWallet()
    external
    view
    returns (address payable);

    function getNetworkFee(address asset)
    external
    view
    returns (uint256 fee);
}

/// @title SubscriptionModule - A module with support for Subscription Payments
/// @author Andrew Redden - <andrew@groundhog.network>
contract SubscriptionModule is Module, SignatureDecoder {

    using BokkyPooBahsDateTimeLibrary for uint256;
    using DSMath for uint256;
    string public constant NAME = "Groundhog";
    string public constant VERSION = "0.1.0";

    bytes32 public domainSeparator;
    address public oracleRegistry;

    //keccak256(
    //    "EIP712Domain(address verifyingContract)"
    //);
    bytes32 public constant DOMAIN_SEPARATOR_TYPEHASH = 0x035aff83d86937d35b32e04f0ddc6ff469290eef2f1b692d8a815c89404d4749;

    //keccak256(
    //  "SafeSubTx(address to,uint256 value,bytes data,uint8 operation,uint256 safeTxGas,uint256 dataGas,uint256 gasPrice,address gasToken,address refundReceiver,bytes meta)"
    //)
    bytes32 public constant SAFE_SUB_TX_TYPEHASH = 0x4494907805e3ceba396741b2837174bdf548ec2cbe03f5448d7fa8f6b1aaf98e;

    //keccak256(
    //  "SafeSubCancelTx(bytes32 subscriptionHash,string action)"
    //)
    bytes32 public constant SAFE_SUB_CANCEL_TX_TYPEHASH = 0xef5a0c558cb538697e29722572248a2340a367e5079b08a00b35ef5dd1e66faa;

    mapping(bytes32 => Meta) public subscriptions;

    struct Meta {
        GEnum.SubscriptionStatus status;
        uint256 nextWithdraw;
        uint256 endDate;
        uint256 cycle;
    }

    event NextPayment(
        bytes32 indexed subscriptionHash,
        uint256 nextWithdraw
    );

    event OraclizedDenomination(
        bytes32 indexed subscriptionHash,
        uint256 dynPriceFormat,
        uint256 conversionRate,
        uint256 paymentTotal
    );
    event StatusChanged(
        bytes32 indexed subscriptionHash,
        GEnum.SubscriptionStatus prev,
        GEnum.SubscriptionStatus next
    );

    /// @dev Setup function sets manager
    function setup(
        address _oracleRegistry
    )
    public
    {
        setManager();

        require(
            domainSeparator == 0,
            "SubscriptionModule::setup: INVALID_STATE: DOMAIN_SEPARATOR_SET"
        );

        domainSeparator = keccak256(
            abi.encode(
                DOMAIN_SEPARATOR_TYPEHASH,
                address(this)
            )
        );

        require(
            oracleRegistry == address(0),
            "SubscriptionModule::setup: INVALID_STATE: ORACLE_REGISTRY_SET"
        );

        oracleRegistry = _oracleRegistry;
    }

    /// @dev Allows to execute a Safe transaction confirmed by required number of owners and then pays the account that submitted the transaction.
    ///      Note: The fees are always transferred, even if the user transaction fails.
    /// @param to Destination address of Safe transaction.
    /// @param value Ether value of Safe transaction.
    /// @param data Data payload of Safe transaction.
    /// @param operation Operation type of Safe transaction.
    /// @param safeTxGas Gas that should be used for the Safe transaction.
    /// @param dataGas Gas costs for data used to trigger the safe transaction and to pay the payment transfer
    /// @param gasPrice Gas price that should be used for the payment calculation.
    /// @param gasToken Token address (or 0 if ETH) that is used for the payment.
    /// @param refundReceiver payout address or 0 if tx.origin
    /// @param meta Packed bytes data {address refundReceiver (required}, {uint256 period (required}, {uint256 offChainID (required}, {uint256 endDate (optional}
    /// @param signatures Packed signature data ({bytes32 r}{bytes32 s}{uint2568 v})
    /// @return success boolean value of execution

    function execSubscription(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 dataGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory meta,
        bytes memory signatures
    )
    public
    returns
    (
        bool
    )
    {
        uint256 startGas = gasleft();

        bytes memory subHashData = encodeSubscriptionData(
            to, value, data, operation, // Transaction info
            safeTxGas, dataGas, gasPrice, gasToken,
            refundReceiver, meta
        );

        require(
            gasleft() >= safeTxGas,
            "SubscriptionModule::execSubscription: INVALID_DATA: WALLET_TX_GAS"
        );

        require(
            _checkHash(
                keccak256(subHashData), signatures
            ),
            "SubscriptionModule::execSubscription: INVALID_DATA: SIGNATURES"
        );

        _paySubscription(
            to, value, data, operation,
            keccak256(subHashData), meta
        );

        // We transfer the calculated tx costs to the refundReceiver to avoid sending it to intermediate contracts that have made calls
        if (gasPrice > 0) {
            _handleTxPayment(
                startGas,
                dataGas,
                gasPrice,
                gasToken,
                refundReceiver
            );
        }

        return true;
    }

    function _processMeta(
        bytes memory meta
    )
    internal
    view
    returns (
        uint256 conversionRate,
        uint256[4] memory outMeta
    )
    {
        require(
            meta.length == 160,
            "SubscriptionModule::_processMeta: INVALID_DATA: META_LENGTH"
        );


        (
        uint256 oracle,
        uint256 period,
        uint256 offChainID,
        uint256 startDate,
        uint256 endDate
        ) = abi.decode(
            meta,
            (uint, uint, uint, uint, uint) //5 slots
        );

        if (oracle != uint256(0)) {

            bytes32 rate = OracleRegistry(oracleRegistry).read(oracle);
            conversionRate = uint256(rate);
        } else {
            conversionRate = uint256(0);
        }

        return (conversionRate, [period, offChainID, startDate, endDate]);
    }

    function _paySubscription(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        bytes32 subscriptionHash,
        bytes memory meta
    )
    internal
    {
        uint256 conversionRate;
        uint256[4] memory processedMetaData;

        (conversionRate, processedMetaData) = _processMeta(meta);

        bool processPayment = _processSub(subscriptionHash, processedMetaData);

        if (processPayment) {

            //Oracle Registry address data is in slot1
            if (conversionRate != uint256(0)) {

                //when in priceFeed format, price feeds are denominated in Ether but converted to the feed pairing
                //ETHUSD, WBTC/USD
                require(
                    value > 1.00 ether,
                    "SubscriptionModule::_paySubscription: INVALID_FORMAT: DYNAMIC_PRICE_FORMAT"
                );

                uint256 payment = value.wdiv(conversionRate);

                emit OraclizedDenomination(
                    subscriptionHash,
                    value,
                    conversionRate,
                    payment
                );

                value = payment;
            }

            require(
                manager.execTransactionFromModule(to, value, data, operation),
                "SubscriptionModule::_paySubscription: INVALID_EXEC: PAY_SUB"
            );
        }
    }

    function _handleTxPayment(
        uint256 gasUsed,
        uint256 dataGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver
    )
    internal
    {
        uint256 amount = gasUsed.sub(gasleft()).add(dataGas).mul(gasPrice);
        // solium-disable-next-line security/no-tx-origin
        address receiver = refundReceiver == address(0) ? tx.origin : refundReceiver;

        if (gasToken == address(0)) {

            // solium-disable-next-line security/no-send
            require(
                manager.execTransactionFromModule(receiver, amount, "0x", Enum.Operation.Call),
                "SubscriptionModule::_handleTxPayment: FAILED_EXEC: PAYMENT_ETH"
            );
        } else {

            bytes memory data = abi.encodeWithSignature("transfer(address,uint256)", receiver, amount);
            // solium-disable-next-line security/no-inline-assembly
            require(
                manager.execTransactionFromModule(gasToken, 0, data, Enum.Operation.Call),
                "SubscriptionModule::_handleTxPayment: FAILED_EXEC: PAYMENT_GAS_TOKEN"
            );
        }
    }

    function _checkHash(
        bytes32 hash,
        bytes memory signatures
    )
    internal
    view
    returns (
        bool valid
    )
    {
        // There cannot be an owner with address 0.
        address lastOwner = address(0);
        address currentOwner;
        uint256 i;
        uint256 threshold = OwnerManager(address(manager)).getThreshold();
        // Validate threshold is reached.
        valid = false;

        for (i = 0; i < threshold; i++) {

            currentOwner = recoverKey(
                hash,
                signatures, i
            );

            require(
                OwnerManager(address(manager)).isOwner(currentOwner),
                "SubscriptionModule::_checkHash: INVALID_DATA: SIGNATURE_NOT_OWNER"
            );

            require(
                currentOwner > lastOwner,
                "SubscriptionModule::_checkHash: INVALID_DATA: SIGNATURE_OUT_ORDER"
            );

            lastOwner = currentOwner;
        }

        valid = true;
    }


    /// @dev Allows to execute a Safe transaction confirmed by required number of owners and then pays the account that submitted the transaction.
    ///      Note: The fees are always transferred, even if the user transaction fails.
    /// @param subscriptionHash bytes32 hash of on chain sub
    /// @return bool isValid returns the validity of the subscription
    function isValidSubscription(
        bytes32 subscriptionHash,
        bytes memory signatures
    )
    public
    view
    returns (bool isValid)
    {

        Meta storage sub = subscriptions[subscriptionHash];

        //exit early if we can
        if (sub.status == GEnum.SubscriptionStatus.INIT) {
            return _checkHash(
                subscriptionHash,
                signatures
            );
        }

        if (sub.status == GEnum.SubscriptionStatus.EXPIRED || sub.status == GEnum.SubscriptionStatus.CANCELLED) {

            require(
                sub.endDate != 0,
                "SubscriptionModule::isValidSubscription: INVALID_STATE: SUB_STATUS"
            );

            isValid = (now <= sub.endDate);
        } else if (
            (sub.status == GEnum.SubscriptionStatus.TRIAL && sub.nextWithdraw <= now)
            ||
            (sub.status == GEnum.SubscriptionStatus.VALID)
        ) {
            isValid = true;
        } else {
            isValid = false;
        }
    }

    function cancelSubscriptionAsManager(
        bytes32 subscriptionHash
    )
    authorized
    public
    returns (bool) {

        _cancelSubscription(subscriptionHash);

        return true;
    }

    function cancelSubscriptionAsRecipient(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 dataGas,
        uint256 gasPrice,
        address gasToken,
        address refundReceiver,
        bytes memory meta,
        bytes memory signatures
    )
    public
    returns (bool) {


        bytes memory subHashData = encodeSubscriptionData(
            to, value, data, operation, // Transaction info
            safeTxGas, dataGas, gasPrice, gasToken,
            refundReceiver, meta
        );

        require(
            _checkHash(keccak256(subHashData), signatures),
            "SubscriptionModule::cancelSubscriptionAsRecipient: INVALID_DATA: SIGNATURES"
        );

        //if no value, assume its an ERC20 token, remove the to argument from the data
        if (value == uint(0)) {

            address recipient;
            // solium-disable-next-line security/no-inline-assembly
            assembly {
                recipient := div(mload(add(add(data, 0x20), 16)), 0x1000000000000000000000000)
            }
            require(msg.sender == recipient, "SubscriptionModule::isRecipient: MSG_SENDER_NOT_RECIPIENT_ERC");
        } else {

            //we are sending ETH, so check the sender matches to argument
            require(msg.sender == to, "SubscriptionModule::isRecipient: MSG_SENDER_NOT_RECIPIENT_ETH");
        }

        _cancelSubscription(keccak256(subHashData));

        return true;
    }


    /// @dev Allows to execute a Safe transaction confirmed by required number of owners and then pays the account that
    /// submitted the transaction.
    /// @return bool hash of on sub to revoke or cancel
    function cancelSubscription(
        bytes32 subscriptionHash,
        bytes memory signatures
    )
    public
    returns (bool)
    {

        bytes32 cancelHash = getSubscriptionActionHash(subscriptionHash, "cancel");

        require(
            _checkHash(cancelHash, signatures),
            "SubscriptionModule::cancelSubscription: INVALID_DATA: SIGNATURES_INVALID"
        );

        _cancelSubscription(subscriptionHash);

        return true;
    }


    function _cancelSubscription(bytes32 subscriptionHash)
    internal
    {

        Meta storage sub = subscriptions[subscriptionHash];


        require(
            (sub.status != GEnum.SubscriptionStatus.CANCELLED && sub.status != GEnum.SubscriptionStatus.EXPIRED),
            "SubscriptionModule::_cancelSubscription: INVALID_STATE: SUB_STATUS"
        );

        emit StatusChanged(
            subscriptionHash,
            sub.status,
            GEnum.SubscriptionStatus.CANCELLED
        );

        sub.status = GEnum.SubscriptionStatus.CANCELLED;

        if (sub.status != GEnum.SubscriptionStatus.INIT) {
            sub.endDate = sub.nextWithdraw;
        }

        sub.nextWithdraw = 0;

        emit NextPayment(
            subscriptionHash,
            sub.nextWithdraw
        );
    }

    /// @dev used to help mitigate stack issues
    /// @return bool
    function _processSub(
        bytes32 subscriptionHash,
        uint256[4] memory processedMeta
    )
    internal
    returns (bool)
    {
        uint256 period = processedMeta[0];
        uint256 offChainID = processedMeta[1];
        uint256 startDate = processedMeta[2];
        uint256 endDate = processedMeta[3];

        uint256 withdrawHolder;
        Meta storage sub = subscriptions[subscriptionHash];

        require(
            (sub.status != GEnum.SubscriptionStatus.EXPIRED && sub.status != GEnum.SubscriptionStatus.CANCELLED),
            "SubscriptionModule::_processSub: INVALID_STATE: SUB_STATUS"
        );


        if (sub.status == GEnum.SubscriptionStatus.INIT) {

            if (endDate != 0) {

                require(
                    endDate >= now,
                    "SubscriptionModule::_processSub: INVALID_DATA: SUB_END_DATE"
                );
                sub.endDate = endDate;
            }

            if (startDate != 0) {

                require(
                    startDate >= now,
                    "SubscriptionModule::_processSub: INVALID_DATA: SUB_START_DATE"
                );
                sub.nextWithdraw = startDate;
                sub.status = GEnum.SubscriptionStatus.TRIAL;

                emit StatusChanged(
                    subscriptionHash,
                    GEnum.SubscriptionStatus.INIT,
                    GEnum.SubscriptionStatus.TRIAL
                );
                //emit here because of early method exit after trial setup
                emit NextPayment(
                    subscriptionHash,
                    sub.nextWithdraw
                );

                return false;
            } else {

                sub.nextWithdraw = now;
                sub.status = GEnum.SubscriptionStatus.VALID;
                emit StatusChanged(
                    subscriptionHash,
                    GEnum.SubscriptionStatus.INIT,
                    GEnum.SubscriptionStatus.VALID
                );
            }

        } else if (sub.status == GEnum.SubscriptionStatus.TRIAL) {

            require(
                now >= startDate,
                "SubscriptionModule::_processSub: INVALID_STATE: SUB_START_DATE"
            );
            sub.nextWithdraw = now;
            sub.status = GEnum.SubscriptionStatus.VALID;

            emit StatusChanged(
                subscriptionHash,
                GEnum.SubscriptionStatus.TRIAL,
                GEnum.SubscriptionStatus.VALID
            );
        }

        require(
            sub.status == GEnum.SubscriptionStatus.VALID,
            "SubscriptionModule::_processSub: INVALID_STATE: SUB_STATUS"
        );

        require(
            now >= sub.nextWithdraw && sub.nextWithdraw != 0,
            "SubscriptionModule::_processSub: INVALID_STATE: SUB_NEXT_WITHDRAW"
        );

        if (
            period == uint256(GEnum.Period.DAY)
        ) {
            withdrawHolder = BokkyPooBahsDateTimeLibrary.addDays(sub.nextWithdraw, 1);
        } else if (
            period == uint256(GEnum.Period.WEEK)
        ) {
            withdrawHolder = BokkyPooBahsDateTimeLibrary.addDays(sub.nextWithdraw, 7);
        } else if (
            period == uint256(GEnum.Period.MONTH)
        ) {
            withdrawHolder = BokkyPooBahsDateTimeLibrary.addMonths(sub.nextWithdraw, 1);
        } else if (
            period == uint256(GEnum.Period.YEAR)
        ) {
            withdrawHolder = BokkyPooBahsDateTimeLibrary.addYears(sub.nextWithdraw, 1);
        } else {
            revert("SubscriptionModule::_processSub: INVALID_DATA: PERIOD");
        }

        //if a subscription is expiring and its next withdraw timeline is beyond hte time of the expiration
        //modify the status
        if (sub.endDate != 0 && withdrawHolder >= sub.endDate) {

            sub.nextWithdraw = 0;
            emit StatusChanged(
                subscriptionHash,
                sub.status,
                GEnum.SubscriptionStatus.EXPIRED
            );
            sub.status = GEnum.SubscriptionStatus.EXPIRED;
        } else {
            sub.nextWithdraw = withdrawHolder;
        }

        emit NextPayment(
            subscriptionHash,
            sub.nextWithdraw
        );

        return true;
    }


    function getSubscriptionMetaBytes(
        uint256 oracle,
        uint256 period,
        uint256 offChainID,
        uint256 startDate,
        uint256 endDate
    )
    public
    pure
    returns (bytes memory)
    {
        return abi.encodePacked(
            oracle,
            period,
            offChainID,
            startDate,
            endDate
        );
    }

    /// @dev Returns hash to be signed by owners.
    /// @param to Destination address.
    /// @param value Ether value.
    /// @param data Data payload.
    /// @param operation Operation type.
    /// @param safeTxGas Gas that should be used for the safe transaction.
    /// @param dataGas Gas costs for data used to trigger the safe transaction.
    /// @param gasPrice Maximum gas price that should be used for this transaction.
    /// @param gasToken Token address (or 0 if ETH) that is used for the payment.
    /// @param meta bytes refundReceiver / period / offChainID / endDate
    /// @return Subscription hash.
    function getSubscriptionHash(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 dataGas,
        uint256 gasPrice,
        address gasToken,
        address refundReceiver,
        bytes memory meta
    )
    public
    view
    returns (bytes32)
    {
        return keccak256(
            encodeSubscriptionData(
                to,
                value,
                data,
                operation,
                safeTxGas,
                dataGas,
                gasPrice,
                gasToken,
                refundReceiver,
                meta
            )
        );
    }

    /// @dev Returns hash to be signed by owners for cancelling a subscription
    function getSubscriptionActionHash(
        bytes32 subscriptionHash,
        string memory action
    )
    public
    view
    returns (bytes32)
    {

        bytes32 safeSubCancelTxHash = keccak256(
            abi.encode(
                SAFE_SUB_CANCEL_TX_TYPEHASH,
                subscriptionHash,
                keccak256(abi.encodePacked(action))
            )
        );

        return keccak256(
            abi.encodePacked(
                byte(0x19),
                byte(0x01),
                domainSeparator,
                safeSubCancelTxHash
            )
        );
    }


    /// @dev Returns the bytes that are hashed to be signed by owners.
    /// @param to Destination address.
    /// @param value Ether value.
    /// @param data Data payload.
    /// @param operation Operation type.
    /// @param safeTxGas Fas that should be used for the safe transaction.
    /// @param gasToken Token address (or 0 if ETH) that is used for the payment.
    /// @param meta bytes packed data(refund address, period, offChainID, endDate
    /// @return Subscription hash bytes.
    function encodeSubscriptionData(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 dataGas,
        uint256 gasPrice,
        address gasToken,
        address refundReceiver,
        bytes memory meta
    )
    public
    view
    returns (bytes memory)
    {
        bytes32 safeSubTxHash = keccak256(
            abi.encode(
                SAFE_SUB_TX_TYPEHASH,
                to,
                value,
                keccak256(data),
                operation,
                safeTxGas,
                dataGas,
                gasPrice,
                gasToken,
                refundReceiver,
                keccak256(meta)
            )
        );

        return abi.encodePacked(
            byte(0x19),
            byte(0x01),
            domainSeparator,
            safeSubTxHash
        );
    }

    /// @dev Allows to estimate a Safe transaction.
    ///      This method is only meant for estimation purpose, therfore two different protection mechanism against execution in a transaction have been made:
    ///      1.) The method can only be called from the safe itself
    ///      2.) The response is returned with a revert
    ///      When estimating set `from` to the address of the safe.
    ///      Since the `estimateGas` function includes refunds, call this method to get an estimated of the costs that are deducted from the safe with `execTransaction`
    /// @param to Destination address of Safe transaction.
    /// @param value Ether value of Safe transaction.
    /// @param data Data payload of Safe transaction.
    /// @param operation Operation type of Safe transaction.
    /// @param meta meta data of subscription agreement
    /// @return Estimate without refunds and overhead fees (base transaction and payload data gas costs).
    function requiredTxGas(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        bytes memory meta
    )
    public
    returns (uint256)
    {
        //check to ensure this method doesn't actually get executed outside of a call function
        require(
            msg.sender == address(this),
            "SubscriptionModule::requiredTxGas: INVALID_DATA: MSG_SENDER"

        );

        uint256 startGas = gasleft();
        // We don't provide an error message here, as we use it to return the estimate
        // solium-disable-next-line error-reason

        (uint256 conversionRate, uint256[4] memory pMeta) = _processMeta(meta);

        //Oracle Registry address data is in slot1
        if (conversionRate != uint256(0)) {

            require(
                value > 1.00 ether,
                "SubscriptionModule::requiredTxGas: INVALID_FORMAT: DYNAMIC_PRICE_FORMAT"
            );

            uint256 payment = value.wdiv(conversionRate);
            value = payment;
        }

        require(
            manager.execTransactionFromModule(to, value, data, operation),
            "SubscriptionModule::requiredTxGas: INVALID_EXEC: SUB_PAY"
        );

        uint256 requiredGas = startGas.sub(gasleft());
        // Convert response to string and return via error message
        revert(string(abi.encodePacked(requiredGas)));

    }
}