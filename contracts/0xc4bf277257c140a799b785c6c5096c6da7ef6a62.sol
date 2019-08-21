pragma solidity >=0.4.24 <0.5.0;

/**
 *
 *  @title AddressMap
 *  @dev Map of unique indexed addresseses.
 *
 *  **NOTE**
 *    The internal collections are one-based.
 *    This is simply because null values are expressed as zero,
 *    which makes it hard to check for the existence of items within the array,
 *    or grabbing the first item of an array for non-existent items.
 *
 *    This is only exposed internally, so callers still use zero-based indices.
 *
 */
library AddressMap {
    address constant ZERO_ADDRESS = address(0);

    struct Data {
        int256 count;
        mapping(address => int256) indices;
        mapping(int256 => address) items;
    }

    /**
     *  Appends the address to the end of the map, if the addres is not
     *  zero and the address doesn't currently exist.
     *  @param addr The address to append.
     *  @return true if the address was added.
     */
    function append(Data storage self, address addr)
    internal
    returns (bool) {
        if (addr == ZERO_ADDRESS) {
            return false;
        }

        int256 index = self.indices[addr] - 1;
        if (index >= 0 && index < self.count) {
            return false;
        }

        self.count++;
        self.indices[addr] = self.count;
        self.items[self.count] = addr;
        return true;
    }

    /**
     *  Removes the given address from the map.
     *  @param addr The address to remove from the map.
     *  @return true if the address was removed.
     */
    function remove(Data storage self, address addr)
    internal
    returns (bool) {
        int256 oneBasedIndex = self.indices[addr];
        if (oneBasedIndex < 1 || oneBasedIndex > self.count) {
            return false;  // address doesn't exist, or zero.
        }

        // When the item being removed is not the last item in the collection,
        // replace that item with the last one, otherwise zero it out.
        //
        //  If {2} is the item to be removed
        //     [0, 1, 2, 3, 4]
        //  The result would be:
        //     [0, 1, 4, 3]
        //
        if (oneBasedIndex < self.count) {
            // Replace with last item
            address last = self.items[self.count];  // Get the last item
            self.indices[last] = oneBasedIndex;     // Update last items index to current index
            self.items[oneBasedIndex] = last;       // Update current index to last item
            delete self.items[self.count];          // Delete the last item, since it's moved
        } else {
            // Delete the address
            delete self.items[oneBasedIndex];
        }

        delete self.indices[addr];
        self.count--;
        return true;
    }

    /**
     *  Retrieves the address at the given index.
     *  THROWS when the index is invalid.
     *  @param index The index of the item to retrieve.
     *  @return The address of the item at the given index.
     */
    function at(Data storage self, int256 index)
    internal
    view
    returns (address) {
        require(index >= 0 && index < self.count, "Index outside of bounds.");
        return self.items[index + 1];
    }

    /**
     *  Gets the index of the given address.
     *  @param addr The address of the item to get the index for.
     *  @return The index of the given address.
     */
    function indexOf(Data storage self, address addr)
    internal
    view
    returns (int256) {
        if (addr == ZERO_ADDRESS) {
            return -1;
        }

        int256 index = self.indices[addr] - 1;
        if (index < 0 || index >= self.count) {
            return -1;
        }
        return index;
    }

    /**
     *  Returns whether or not the given address exists within the map.
     *  @param addr The address to check for existence.
     *  @return If the given address exists or not.
     */
    function exists(Data storage self, address addr)
    internal
    view
    returns (bool) {
        int256 index = self.indices[addr] - 1;
        return index >= 0 && index < self.count;
    }

    /**
     * Clears all items within the map.
     */
    function clear(Data storage self)
    internal {
        self.count = 0;
    }

}

/**
 *
 *  @title AccountMap
 *  @dev Map of unique indexed accounts.
 *
 *  **NOTE**
 *    The internal collections are one-based.
 *    This is simply because null values are expressed as zero,
 *    which makes it hard to check for the existence of items within the array,
 *    or grabbing the first item of an array for non-existent items.
 *
 *    This is only exposed internally, so callers still use zero-based indices.
 *
 */
library AccountMap {
    address constant ZERO_ADDRESS = address(0);

    struct Account {
        address addr;
        uint8 kind;
        bool frozen;
        address parent;
    }

    struct Data {
        int256 count;
        mapping(address => int256) indices;
        mapping(int256 => Account) items;
    }

    /**
     *  Appends the address to the end of the map, if the addres is not
     *  zero and the address doesn't currently exist.
     *  @param addr The address to append.
     *  @return true if the address was added.
     */
    function append(Data storage self, address addr, uint8 kind, bool isFrozen, address parent)
    internal
    returns (bool) {
        if (addr == ZERO_ADDRESS) {
            return false;
        }

        int256 index = self.indices[addr] - 1;
        if (index >= 0 && index < self.count) {
            return false;
        }

        self.count++;
        self.indices[addr] = self.count;
        self.items[self.count] = Account(addr, kind, isFrozen, parent);
        return true;
    }

    /**
     *  Removes the given address from the map.
     *  @param addr The address to remove from the map.
     *  @return true if the address was removed.
     */
    function remove(Data storage self, address addr)
    internal
    returns (bool) {
        int256 oneBasedIndex = self.indices[addr];
        if (oneBasedIndex < 1 || oneBasedIndex > self.count) {
            return false;  // address doesn't exist, or zero.
        }

        // When the item being removed is not the last item in the collection,
        // replace that item with the last one, otherwise zero it out.
        //
        //  If {2} is the item to be removed
        //     [0, 1, 2, 3, 4]
        //  The result would be:
        //     [0, 1, 4, 3]
        //
        if (oneBasedIndex < self.count) {
            // Replace with last item
            Account storage last = self.items[self.count];  // Get the last item
            self.indices[last.addr] = oneBasedIndex;        // Update last items index to current index
            self.items[oneBasedIndex] = last;               // Update current index to last item
            delete self.items[self.count];                  // Delete the last item, since it's moved
        } else {
            // Delete the account
            delete self.items[oneBasedIndex];
        }

        delete self.indices[addr];
        self.count--;
        return true;
    }

    /**
     *  Retrieves the address at the given index.
     *  THROWS when the index is invalid.
     *  @param index The index of the item to retrieve.
     *  @return The address of the item at the given index.
     */
    function at(Data storage self, int256 index)
    internal
    view
    returns (Account) {
        require(index >= 0 && index < self.count, "Index outside of bounds.");
        return self.items[index + 1];
    }

    /**
     *  Gets the index of the given address.
     *  @param addr The address of the item to get the index for.
     *  @return The index of the given address.
     */
    function indexOf(Data storage self, address addr)
    internal
    view
    returns (int256) {
        if (addr == ZERO_ADDRESS) {
            return -1;
        }

        int256 index = self.indices[addr] - 1;
        if (index < 0 || index >= self.count) {
            return -1;
        }
        return index;
    }

    /**
     *  Gets the Account for the given address.
     *  THROWS when an account doesn't exist for the given address.
     *  @param addr The address of the item to get.
     *  @return The account of the given address.
     */
    function get(Data storage self, address addr)
    internal
    view
    returns (Account) {
        return at(self, indexOf(self, addr));
    }

    /**
     *  Returns whether or not the given address exists within the map.
     *  @param addr The address to check for existence.
     *  @return If the given address exists or not.
     */
    function exists(Data storage self, address addr)
    internal
    view
    returns (bool) {
        int256 index = self.indices[addr] - 1;
        return index >= 0 && index < self.count;
    }

    /**
     * Clears all items within the map.
     */
    function clear(Data storage self)
    internal {
        self.count = 0;
    }

}

/**
 *  @title Ownable
 *  @dev Provides a modifier that requires the caller to be the owner of the contract.
 */
contract Ownable {
    address public owner;

    event OwnerTransferred(
        address indexed oldOwner,
        address indexed newOwner
    );

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Owner account is required");
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwner(address newOwner)
    public
    onlyOwner {
        require(newOwner != owner, "New Owner cannot be the current owner");
        require(newOwner != address(0), "New Owner cannot be zero address");
        address prevOwner = owner;
        owner = newOwner;
        emit OwnerTransferred(prevOwner, newOwner);
    }
}

/**
 *  @title Lockable
 *  @dev The Lockable contract adds the ability for the contract owner to set the lock status
 *  of the account. A modifier is provided that checks the throws when the contract is
 *  in the locked state.
 */
contract Lockable is Ownable {
    bool public isLocked;

    constructor() public {
        isLocked = false;
    }

    modifier isUnlocked() {
        require(!isLocked, "Contract is currently locked for modification");
        _;
    }

    /**
     *  Set the contract to a read-only state.
     *  @param locked The locked state to set the contract to.
     */
    function setLocked(bool locked)
    onlyOwner
    external {
        require(isLocked != locked, "Contract already in requested lock state");

        isLocked = locked;
    }
}

/**
 *  @title Destroyable
 *  @dev The Destroyable contract alows the owner address to `selfdestruct` the contract.
 */
contract Destroyable is Ownable {
    /**
     *  Allow the owner to destroy this contract.
     */
    function kill()
    onlyOwner
    external {
        selfdestruct(owner);
    }
}

/**
 *  Contract to facilitate locking and self destructing.
 */
contract LockableDestroyable is Lockable, Destroyable { }

/**
 *  @title Registry Storage
 */
contract Storage is Ownable, LockableDestroyable {
    struct Mapping {
        address key;
        address value;
    }

    using AccountMap for AccountMap.Data;
    using AddressMap for AddressMap.Data;

    // ------------------------------- Variables -------------------------------
    // Nmber of data slots available for accounts
    uint8 MAX_DATA = 30;

    // Accounts
    AccountMap.Data public accounts;

    // Account Data
    //   - mapping of:
    //     (address        => (index =>    data))
    mapping(address => mapping(uint8 => bytes32)) public data;

    // Address write permissions
    //     (kind  => address)
    mapping(uint8 => AddressMap.Data) public permissions;


    // ------------------------------- Modifiers -------------------------------
    /**
     *  Ensures the `msg.sender` has permission for the given kind/type of account.
     *  
     *    - The `owner` account is always allowed
     *    - Addresses/Contracts must have a corresponding entry, for the given kind
     */
    modifier isAllowed(uint8 kind) {
        require(kind > 0, "Invalid, or missing permission");
        if (msg.sender != owner) {
            require(permissions[kind].exists(msg.sender), "Missing permission");
        }
        _;
    }


    // ---------------------------- Address Getters ----------------------------
    /**
     *  Gets the account at the given index
     *  THROWS when the index is out-of-bounds
     *  @param index The index of the item to retrieve
     *  @return The address, kind, frozen status, and parent of the account at the given index
     */
    function accountAt(int256 index)
    external
    view
    returns(address, uint8, bool, address) {
        AccountMap.Account memory acct = accounts.at(index);
        return (acct.addr, acct.kind, acct.frozen, acct.parent);
    }

    /**
     *  Gets the account for the given address
     *  THROWS when the account doesn't exist
     *  @param addr The address of the item to retrieve
     *  @return The address, kind, frozen status, and parent of the account at the given index
     */
    function accountGet(address addr)
    external
    view
    returns(uint8, bool, address) {
        AccountMap.Account memory acct = accounts.get(addr);
        return (acct.kind, acct.frozen, acct.parent);
    }

    /**
     *  Gets the parent address for the given account address
     *  THROWS when the account doesn't exist
     *  @param addr The address of the account
     *  @return The parent address
     */
    function accountParent(address addr)
    external
    view
    returns(address) {
        return accounts.get(addr).parent;
    }

    /**
     *  Gets the account kind, for the given account address
     *  THROWS when the account doesn't exist
     *  @param addr The address of the account
     *  @return The kind of account
     */
    function accountKind(address addr)
    external
    view
    returns(uint8) {
        return accounts.get(addr).kind;
    }

    /**
     *  Gets the frozen status of the account
     *  THROWS when the account doesn't exist
     *  @param addr The address of the account
     *  @return The frozen status of the account
     */
    function accountFrozen(address addr)
    external
    view
    returns(bool) {
        return accounts.get(addr).frozen;
    }

    /**
     *  Gets the index of the account
     *  Returns -1 for missing accounts
     *  @param addr The address of the account to get the index for
     *  @return The index of the given account address
     */
    function accountIndexOf(address addr)
    external
    view
    returns(int256) {
        return accounts.indexOf(addr);
    }

    /**
     *  Returns wether or not the given address exists
     *  @param addr The account address
     *  @return If the given address exists
     */
    function accountExists(address addr)
    external
    view
    returns(bool) {
        return accounts.exists(addr);
    }

    /**
     *  Returns wether or not the given address exists for the given kind
     *  @param addr The account address
     *  @param kind The kind of address
     *  @return If the given address exists with the given kind
     */
    function accountExists(address addr, uint8 kind)
    external
    view
    returns(bool) {
        int256 index = accounts.indexOf(addr);
        if (index < 0) {
            return false;
        }
        return accounts.at(index).kind == kind;
    }


    // -------------------------- Permission Getters ---------------------------
    /**
     *  Retrieves the permission address at the index for the given type
     *  THROWS when the index is out-of-bounds
     *  @param kind The kind of permission
     *  @param index The index of the item to retrieve
     *  @return The permission address of the item at the given index
     */
    function permissionAt(uint8 kind, int256 index)
    external
    view
    returns(address) {
        return permissions[kind].at(index);
    }

    /**
     *  Gets the index of the permission address for the given type
     *  Returns -1 for missing permission
     *  @param kind The kind of perission
     *  @param addr The address of the permission to get the index for
     *  @return The index of the given permission address
     */
    function permissionIndexOf(uint8 kind, address addr)
    external
    view
    returns(int256) {
        return permissions[kind].indexOf(addr);
    }

    /**
     *  Returns wether or not the given permission address exists for the given type
     *  @param kind The kind of permission
     *  @param addr The address to check for permission
     *  @return If the given address has permission or not
     */
    function permissionExists(uint8 kind, address addr)
    external
    view
    returns(bool) {
        return permissions[kind].exists(addr);
    }

    // -------------------------------------------------------------------------

    /**
     *  Adds an account to storage
     *  THROWS when `msg.sender` doesn't have permission
     *  THROWS when the account already exists
     *  @param addr The address of the account
     *  @param kind The kind of account
     *  @param isFrozen The frozen status of the account
     *  @param parent The account parent/owner
     */
    function addAccount(address addr, uint8 kind, bool isFrozen, address parent)
    isUnlocked
    isAllowed(kind)
    external {
        require(accounts.append(addr, kind, isFrozen, parent), "Account already exists");
    }

    /**
     *  Sets an account's frozen status
     *  THROWS when the account doesn't exist
     *  @param addr The address of the account
     *  @param frozen The frozen status of the account
     */
    function setAccountFrozen(address addr, bool frozen)
    isUnlocked
    isAllowed(accounts.get(addr).kind)
    external {
        // NOTE: Not bounds checking `index` here, as `isAllowed` ensures the address exists.
        //       Indices are one-based internally, so we need to add one to compensate.
        int256 index = accounts.indexOf(addr) + 1;
        accounts.items[index].frozen = frozen;
    }

    /**
     *  Removes an account from storage
     *  THROWS when the account doesn't exist
     *  @param addr The address of the account
     */
    function removeAccount(address addr)
    isUnlocked
    isAllowed(accounts.get(addr).kind)
    external {
        bytes32 ZERO_BYTES = bytes32(0);
        mapping(uint8 => bytes32) accountData = data[addr];

        // Remove data
        for (uint8 i = 0; i < MAX_DATA; i++) {
            if (accountData[i] != ZERO_BYTES) {
                delete accountData[i];
            }
        }

        // Remove account
        accounts.remove(addr);
    }

    /**
     *  Sets data for an address/caller
     *  THROWS when the account doesn't exist
     *  @param addr The address
     *  @param index The index of the data
     *  @param customData The data store set
     */
    function setAccountData(address addr, uint8 index, bytes32 customData)
    isUnlocked
    isAllowed(accounts.get(addr).kind)
    external {
        require(index < MAX_DATA, "index outside of bounds");
        data[addr][index] = customData;
    }

    /**
     *  Grants the address permission for the given kind
     *  @param kind The kind of address
     *  @param addr The address
     */
    function grantPermission(uint8 kind, address addr)
    isUnlocked
    isAllowed(kind)
    external {
        permissions[kind].append(addr);
    }

    /**
     *  Revokes the address permission for the given kind
     *  @param kind The kind of address
     *  @param addr The address
     */
    function revokePermission(uint8 kind, address addr)
    isUnlocked
    isAllowed(kind)
    external {
        permissions[kind].remove(addr);
    }

}

interface ERC20 {
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);

    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 value) external returns (bool);
    function balanceOf(address who) external view returns (uint256);
    function totalSupply() external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

library AdditiveMath {
    /**
     *  Adds two numbers and returns the result
     *  THROWS when the result overflows
     *  @return The sum of the arguments
     */
    function add(uint256 x, uint256 y)
    internal
    pure
    returns (uint256) {
        uint256 sum = x + y;
        require(sum >= x, "Results in overflow");
        return sum;
    }

    /**
     *  Subtracts two numbers and returns the result
     *  THROWS when the result underflows
     *  @return The difference of the arguments
     */
    function subtract(uint256 x, uint256 y)
    internal
    pure
    returns (uint256) {
        require(y <= x, "Results in underflow");
        return x - y;
    }
}

interface ComplianceRule {

    /**
     * @param from The address of the sender
     * @param to The address of the receiver
     * @param toKind The kind of the to address
     * @param store The Storage contract
     * @return true if transfer is allowed
     */
    function canTransfer(address from, address to, uint8 toKind, Storage store)
    external
    view
    returns(bool);
}

interface Compliance {

    /**
     * This event is emitted when an address's frozen status has changed.
     * @param addr The address whose frozen status has been updated.
     * @param isFrozen Whether the custodian is being frozen.
     * @param owner The address that updated the frozen status.
     */
    event AddressFrozen(
        address indexed addr,
        bool indexed isFrozen,
        address indexed owner
    );

    /**
     *  Sets an address frozen status for this token
     *  @param addr The address to update frozen status.
     *  @param freeze Frozen status of the address.
     */
    function setAddressFrozen(address addr, bool freeze)
    external;

    /**
     *  Returns all of the current compliance rules for this token
     *  @param kind The bucket of rules to get.
     *  @return List of all compliance rules.
     */
    function getRules(uint8 kind)
    view
    external
    returns(ComplianceRule[]);

    /**
     *  Replaces all of the existing rules with the given ones
     *  @param kind The bucket of rules to set.
     *  @param rules New compliance rules.
     */
    function setRules(uint8 kind, ComplianceRule[] rules)
    external;

    /**
     *  Checks if a transfer can occur between the from/to addresses.
     *  Both addressses must be valid, unfrozen, and pass all compliance rule checks.
     *  @param from The address of the sender.
     *  @param to The address of the receiver.
     *  @return If a transfer can occure between the from/to addresses.
     */
    function canTransfer(address from, address to)
    view
    external
    returns(bool);

}

contract T0ken is ERC20, Ownable, LockableDestroyable {
    // ------------------------------- Variables -------------------------------
    using AdditiveMath for uint256;

    using AddressMap for AddressMap.Data;
    AddressMap.Data public shareholders;

    mapping(address => address) public cancellations;
    mapping(address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) private allowed;

    address public issuer;
    bool public issuingFinished = false;
    uint256 internal totalSupplyTokens;
    address constant internal ZERO_ADDRESS = address(0);
    Compliance public compliance;
    Storage public store;

    // Possible 3rd party integration variables
    string public constant name = "TZERO PREFERRED";
    string public constant symbol = "TZROP";
    uint8 public constant decimals = 0;

    // ------------------------------- Modifiers -------------------------------
    modifier transferCheck(uint256 value, address fromAddr) {
        require(value <= balances[fromAddr], "Balance is more than from address has");
        _;
    }

    modifier isNotCancelled(address addr) {
        require(cancellations[addr] == ZERO_ADDRESS, "Address has been cancelled");
        _;
    }

    modifier onlyIssuer() {
        require(msg.sender == issuer, "Only issuer allowed");
        _;
    }

    modifier canIssue() {
        require(!issuingFinished, "Issuing is already finished");
        _;
    }

    modifier canTransfer(address fromAddress, address toAddress) {
        if(fromAddress == issuer) {
            require(store.accountExists(toAddress), "The to address does not exist");
        }
        else {
            require(compliance.canTransfer(fromAddress, toAddress), "Address cannot transfer");
        }
        _;
    }

    modifier canTransferFrom(address fromAddress, address toAddress) {
        if(msg.sender == owner) {
            require(store.accountExists(toAddress), "The to address does not exist");
        }
        else {
            require(compliance.canTransfer(fromAddress, toAddress), "Address cannot transfer");
        }
        _;
    }

    // -------------------------- Events -------------------------------

    /**
     *  This event is emitted when an address is cancelled and replaced with
     *  a new address.  This happens in the case where a shareholder has
     *  lost access to their original address and needs to have their share
     *  reissued to a new address.  This is the equivalent of issuing replacement
     *  share certificates.
     *  @param original The address being superseded.
     *  @param replacement The new address.
     *  @param sender The address that caused the address to be superseded.
    */
    event VerifiedAddressSuperseded(address indexed original, address indexed replacement, address indexed sender);
    event IssuerSet(address indexed previousIssuer, address indexed newIssuer);
    event Issue(address indexed to, uint256 amount);
    event IssueFinished();


    // ---------------------------- Getters ----------------------------

    /**
    * @return total number of tokens in existence
    */
    function totalSupply()
    external
    view
    returns (uint256) {
        return totalSupplyTokens;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param addr The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address addr)
    external
    view
    returns (uint256) {
        return balances[addr];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param addrOwner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address addrOwner, address spender)
    isUnlocked
    external
    view
    returns (uint256) {
        return allowed[addrOwner][spender];
    }

    /**
     *  By counting the number of token holders using `holderCount`
     *  you can retrieve the complete list of token holders, one at a time.
     *  It MUST throw if `index >= holderCount()`.
     *  @param index The zero-based index of the holder.
     *  @return the address of the token holder with the given index.
     */
    function holderAt(int256 index)
    external
    view
    returns (address){
        return shareholders.at(index);
    }

    /**
     *  Checks to see if the supplied address is a share holder.
     *  @param addr The address to check.
     *  @return true if the supplied address owns a token.
     */
    function isHolder(address addr)
    external
    view
    returns (bool) {
        return shareholders.exists(addr);
    }

    /**
     *  Checks to see if the supplied address was superseded.
     *  @param addr The address to check.
     *  @return true if the supplied address was superseded by another address.
     */
    function isSuperseded(address addr)
    onlyOwner
    external
    view
    returns (bool) {
        return cancellations[addr] != ZERO_ADDRESS;
    }

    /**
     *  Gets the most recent address, given a superseded one.
     *  Addresses may be superseded multiple times, so this function needs to
     *  follow the chain of addresses until it reaches the final, verified address.
     *  @param addr The superseded address.
     *  @return the verified address that ultimately holds the share.
     */
    function getSuperseded(address addr)
    onlyOwner
    public
    view
    returns (address) {
        require(addr != ZERO_ADDRESS, "Non-zero address required");
        address candidate = cancellations[addr];
        if (candidate == ZERO_ADDRESS) {
            return ZERO_ADDRESS;
        }
        return candidate;
    }

    // -----------------------------------------------------------------

    function setCompliance(address newComplianceAddress)
    isUnlocked
    onlyOwner
    external {
        compliance = Compliance(newComplianceAddress);
    }

    function setStorage(Storage s)
    isUnlocked
    onlyOwner
    external {
        store = s;
    }

    /**
    * @dev transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    *  The `transfer` function MUST NOT allow transfers to addresses that
    *  have not been verified and added to the contract.
    *  If the `to` address is not currently a shareholder then it MUST become one.
    *  If the transfer will reduce `msg.sender`'s balance to 0 then that address
    *  MUST be removed from the list of shareholders.
    */
    function transfer(address to, uint256 value)
    isUnlocked
    isNotCancelled(to)
    transferCheck(value, msg.sender)
    canTransfer(msg.sender, to)
    public
    returns (bool) {
        balances[msg.sender] = balances[msg.sender].subtract(value);
        balances[to] = balances[to].add(value);

        // Adds the shareholder, if they don't already exist.
        shareholders.append(to);

        // Remove the shareholder if they no longer hold tokens.
        if (balances[msg.sender] == 0) {
            shareholders.remove(msg.sender);
        }

        emit Transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     *  The `transferFrom` function MUST NOT allow transfers to addresses that
     *  have not been verified and added to the contract.
     *  If the `to` address is not currently a shareholder then it MUST become one.
     *  If the transfer will reduce `from`'s balance to 0 then that address
     *  MUST be removed from the list of shareholders.
     */
    function transferFrom(address from, address to, uint256 value)
    public
    transferCheck(value, from)
    isNotCancelled(to)
    canTransferFrom(from, to)
    isUnlocked
    returns (bool) {
        if(msg.sender != owner) {
            require(value <= allowed[from][msg.sender], "Value exceeds what is allowed to transfer");
            allowed[from][msg.sender] = allowed[from][msg.sender].subtract(value);
        }

        balances[from] = balances[from].subtract(value);
        balances[to] = balances[to].add(value);

        // Adds the shareholder, if they don't already exist.
        shareholders.append(to);

        // Remove the shareholder if they no longer hold tokens.
        if (balances[msg.sender] == 0) {
            shareholders.remove(from);
        }

        emit Transfer(from, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     *
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value)
    isUnlocked
    external
    returns (bool) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function setIssuer(address newIssuer)
    isUnlocked
    onlyOwner
    external {
        issuer = newIssuer;
        emit IssuerSet(issuer, newIssuer);
    }

    /**
     * Tokens will be issued only to the issuer's address
     * @param quantity The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function issueTokens(uint256 quantity)
    isUnlocked
    onlyIssuer
    canIssue
    public
    returns (bool) {
        address issuer = msg.sender;
        totalSupplyTokens = totalSupplyTokens.add(quantity);
        balances[issuer] = balances[issuer].add(quantity);
        shareholders.append(issuer);
        emit Issue(issuer, quantity);
        return true;
    }

    function finishIssuing()
    isUnlocked
    onlyIssuer
    canIssue
    public
    returns (bool) {
        issuingFinished = true;
        emit IssueFinished();
        return issuingFinished;
    }

    /**
     *  Cancel the original address and reissue the Tokens to the replacement address.
     *
     *  ***It's on the issuer to make sure the replacement address belongs to a verified investor.***
     *
     *  Access to this function MUST be strictly controlled.
     *  The `original` address MUST be removed from the set of verified addresses.
     *  Throw if the `original` address supplied is not a shareholder.
     *  Throw if the replacement address is not a verified address.
     *  This function MUST emit the `VerifiedAddressSuperseded` event.
     *  @param original The address to be superseded. This address MUST NOT be reused.
     *  @param replacement The address  that supersedes the original. This address MUST be verified.
     */
    function cancelAndReissue(address original, address replacement)
    isUnlocked
    onlyOwner
    isNotCancelled(replacement)
    external {
        // replace the original address in the shareholders mapping
        // and update all the associated mappings
        require(shareholders.exists(original) && !shareholders.exists(replacement), "Original doesn't exist or replacement does");
        shareholders.remove(original);
        shareholders.append(replacement);
        cancellations[original] = replacement;
        balances[replacement] = balances[original];
        balances[original] = 0;
        emit VerifiedAddressSuperseded(original, replacement, msg.sender);
    }

}