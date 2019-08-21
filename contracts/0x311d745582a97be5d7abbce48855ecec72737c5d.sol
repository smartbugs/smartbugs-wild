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

/* The authentication manager details user accounts that have access to certain priviledges and keeps a permanent ledger of who has and has had these rights. */
contract AuthenticationManager {
   
    /* Map addresses to admins */
    mapping (address => bool) adminAddresses;

    /* Map addresses to account readers */
    mapping (address => bool) accountReaderAddresses;

    /* Map addresses to account minters */
    mapping (address => bool) accountMinterAddresses;

    /* Details of all admins that have ever existed */
    address[] adminAudit;

    /* Details of all account readers that have ever existed */
    address[] accountReaderAudit;

    /* Details of all account minters that have ever existed */
    address[] accountMinterAudit;

    /* Fired whenever an admin is added to the contract. */
    event AdminAdded(address addedBy, address admin);

    /* Fired whenever an admin is removed from the contract. */
    event AdminRemoved(address removedBy, address admin);

    /* Fired whenever an account-reader contract is added. */
    event AccountReaderAdded(address addedBy, address account);

    /* Fired whenever an account-reader contract is removed. */
    event AccountReaderRemoved(address removedBy, address account);

    /* Fired whenever an account-minter contract is added. */
    event AccountMinterAdded(address addedBy, address account);

    /* Fired whenever an account-minter contract is removed. */
    event AccountMinterRemoved(address removedBy, address account);

    /* When this contract is first setup we use the creator as the first admin */    
    function AuthenticationManager() {
        /* Set the first admin to be the person creating the contract */
        adminAddresses[msg.sender] = true;
        AdminAdded(0, msg.sender);
        adminAudit.length++;
        adminAudit[adminAudit.length - 1] = msg.sender;
    }

    /* Gets whether or not the specified address is currently an admin */
    function isCurrentAdmin(address _address) constant returns (bool) {
        return adminAddresses[_address];
    }

    /* Gets whether or not the specified address has ever been an admin */
    function isCurrentOrPastAdmin(address _address) constant returns (bool) {
        for (uint256 i = 0; i < adminAudit.length; i++)
            if (adminAudit[i] == _address)
                return true;
        return false;
    }

    /* Gets whether or not the specified address is currently an account reader */
    function isCurrentAccountReader(address _address) constant returns (bool) {
        return accountReaderAddresses[_address];
    }

    /* Gets whether or not the specified address has ever been an admin */
    function isCurrentOrPastAccountReader(address _address) constant returns (bool) {
        for (uint256 i = 0; i < accountReaderAudit.length; i++)
            if (accountReaderAudit[i] == _address)
                return true;
        return false;
    }

    /* Gets whether or not the specified address is currently an account minter */
    function isCurrentAccountMinter(address _address) constant returns (bool) {
        return accountMinterAddresses[_address];
    }

    /* Gets whether or not the specified address has ever been an admin */
    function isCurrentOrPastAccountMinter(address _address) constant returns (bool) {
        for (uint256 i = 0; i < accountMinterAudit.length; i++)
            if (accountMinterAudit[i] == _address)
                return true;
        return false;
    }

    /* Adds a user to our list of admins */
    function addAdmin(address _address) {
        /* Ensure we're an admin */
        if (!isCurrentAdmin(msg.sender))
            throw;

        // Fail if this account is already admin
        if (adminAddresses[_address])
            throw;
        
        // Add the user
        adminAddresses[_address] = true;
        AdminAdded(msg.sender, _address);
        adminAudit.length++;
        adminAudit[adminAudit.length - 1] = _address;

    }

    /* Removes a user from our list of admins but keeps them in the history audit */
    function removeAdmin(address _address) {
        /* Ensure we're an admin */
        if (!isCurrentAdmin(msg.sender))
            throw;

        /* Don't allow removal of self */
        if (_address == msg.sender)
            throw;

        // Fail if this account is already non-admin
        if (!adminAddresses[_address])
            throw;

        /* Remove this admin user */
        adminAddresses[_address] = false;
        AdminRemoved(msg.sender, _address);
    }

    /* Adds a user/contract to our list of account readers */
    function addAccountReader(address _address) {
        /* Ensure we're an admin */
        if (!isCurrentAdmin(msg.sender))
            throw;

        // Fail if this account is already in the list
        if (accountReaderAddresses[_address])
            throw;
        
        // Add the account reader
        accountReaderAddresses[_address] = true;
        AccountReaderAdded(msg.sender, _address);
        accountReaderAudit.length++;
        accountReaderAudit[accountReaderAudit.length - 1] = _address;
    }

    /* Removes a user/contracts from our list of account readers but keeps them in the history audit */
    function removeAccountReader(address _address) {
        /* Ensure we're an admin */
        if (!isCurrentAdmin(msg.sender))
            throw;

        // Fail if this account is already not in the list
        if (!accountReaderAddresses[_address])
            throw;

        /* Remove this account reader */
        accountReaderAddresses[_address] = false;
        AccountReaderRemoved(msg.sender, _address);
    }

    /* Add a contract to our list of account minters */
    function addAccountMinter(address _address) {
        /* Ensure we're an admin */
        if (!isCurrentAdmin(msg.sender))
            throw;

        // Fail if this account is already in the list
        if (accountMinterAddresses[_address])
            throw;
        
        // Add the minter
        accountMinterAddresses[_address] = true;
        AccountMinterAdded(msg.sender, _address);
        accountMinterAudit.length++;
        accountMinterAudit[accountMinterAudit.length - 1] = _address;
    }

    /* Removes a user/contracts from our list of account readers but keeps them in the history audit */
    function removeAccountMinter(address _address) {
        /* Ensure we're an admin */
        if (!isCurrentAdmin(msg.sender))
            throw;

        // Fail if this account is already not in the list
        if (!accountMinterAddresses[_address])
            throw;

        /* Remove this minter account */
        accountMinterAddresses[_address] = false;
        AccountMinterRemoved(msg.sender, _address);
    }
}

// parse a raw bitcoin transaction byte array
library BTC {
    // Convert a variable integer into something useful and return it and
    // the index to after it.
    function parseVarInt(bytes txBytes, uint pos) returns (uint, uint) {
        // the first byte tells us how big the integer is
        var ibit = uint8(txBytes[pos]);
        pos += 1;  // skip ibit

        if (ibit < 0xfd) {
            return (ibit, pos);
        } else if (ibit == 0xfd) {
            return (getBytesLE(txBytes, pos, 16), pos + 2);
        } else if (ibit == 0xfe) {
            return (getBytesLE(txBytes, pos, 32), pos + 4);
        } else if (ibit == 0xff) {
            return (getBytesLE(txBytes, pos, 64), pos + 8);
        }
    }
    // convert little endian bytes to uint
    function getBytesLE(bytes data, uint pos, uint bits) returns (uint) {
        if (bits == 8) {
            return uint8(data[pos]);
        } else if (bits == 16) {
            return uint16(data[pos])
                 + uint16(data[pos + 1]) * 2 ** 8;
        } else if (bits == 32) {
            return uint32(data[pos])
                 + uint32(data[pos + 1]) * 2 ** 8
                 + uint32(data[pos + 2]) * 2 ** 16
                 + uint32(data[pos + 3]) * 2 ** 24;
        } else if (bits == 64) {
            return uint64(data[pos])
                 + uint64(data[pos + 1]) * 2 ** 8
                 + uint64(data[pos + 2]) * 2 ** 16
                 + uint64(data[pos + 3]) * 2 ** 24
                 + uint64(data[pos + 4]) * 2 ** 32
                 + uint64(data[pos + 5]) * 2 ** 40
                 + uint64(data[pos + 6]) * 2 ** 48
                 + uint64(data[pos + 7]) * 2 ** 56;
        }
    }
    // scan the full transaction bytes and return the first two output
    // values (in satoshis) and addresses (in binary)
    function getFirstTwoOutputs(bytes txBytes)
             returns (uint, bytes20, uint, bytes20)
    {
        uint pos;
        uint[] memory input_script_lens = new uint[](2);
        uint[] memory output_script_lens = new uint[](2);
        uint[] memory script_starts = new uint[](2);
        uint[] memory output_values = new uint[](2);
        bytes20[] memory output_addresses = new bytes20[](2);

        pos = 4;  // skip version

        (input_script_lens, pos) = scanInputs(txBytes, pos, 0);

        (output_values, script_starts, output_script_lens, pos) = scanOutputs(txBytes, pos, 2);

        for (uint i = 0; i < 2; i++) {
            var pkhash = parseOutputScript(txBytes, script_starts[i], output_script_lens[i]);
            output_addresses[i] = pkhash;
        }

        return (output_values[0], output_addresses[0],
                output_values[1], output_addresses[1]);
    }
    // Check whether `btcAddress` is in the transaction outputs *and*
    // whether *at least* `value` has been sent to it.
    function checkValueSent(bytes txBytes, bytes20 btcAddress, uint value)
             returns (bool)
    {
        uint pos = 4;  // skip version
        (, pos) = scanInputs(txBytes, pos, 0);  // find end of inputs

        // scan *all* the outputs and find where they are
        var (output_values, script_starts, output_script_lens,) = scanOutputs(txBytes, pos, 0);

        // look at each output and check whether it at least value to btcAddress
        for (uint i = 0; i < output_values.length; i++) {
            var pkhash = parseOutputScript(txBytes, script_starts[i], output_script_lens[i]);
            if (pkhash == btcAddress && output_values[i] >= value) {
                return true;
            }
        }
    }
    // scan the inputs and find the script lengths.
    // return an array of script lengths and the end position
    // of the inputs.
    // takes a 'stop' argument which sets the maximum number of
    // outputs to scan through. stop=0 => scan all.
    function scanInputs(bytes txBytes, uint pos, uint stop)
             returns (uint[], uint)
    {
        uint n_inputs;
        uint halt;
        uint script_len;

        (n_inputs, pos) = parseVarInt(txBytes, pos);

        if (stop == 0 || stop > n_inputs) {
            halt = n_inputs;
        } else {
            halt = stop;
        }

        uint[] memory script_lens = new uint[](halt);

        for (var i = 0; i < halt; i++) {
            pos += 36;  // skip outpoint
            (script_len, pos) = parseVarInt(txBytes, pos);
            script_lens[i] = script_len;
            pos += script_len + 4;  // skip sig_script, seq
        }

        return (script_lens, pos);
    }
    // scan the outputs and find the values and script lengths.
    // return array of values, array of script lengths and the
    // end position of the outputs.
    // takes a 'stop' argument which sets the maximum number of
    // outputs to scan through. stop=0 => scan all.
    function scanOutputs(bytes txBytes, uint pos, uint stop)
             returns (uint[], uint[], uint[], uint)
    {
        uint n_outputs;
        uint halt;
        uint script_len;

        (n_outputs, pos) = parseVarInt(txBytes, pos);

        if (stop == 0 || stop > n_outputs) {
            halt = n_outputs;
        } else {
            halt = stop;
        }

        uint[] memory script_starts = new uint[](halt);
        uint[] memory script_lens = new uint[](halt);
        uint[] memory output_values = new uint[](halt);

        for (var i = 0; i < halt; i++) {
            output_values[i] = getBytesLE(txBytes, pos, 64);
            pos += 8;

            (script_len, pos) = parseVarInt(txBytes, pos);
            script_starts[i] = pos;
            script_lens[i] = script_len;
            pos += script_len;
        }

        return (output_values, script_starts, script_lens, pos);
    }
    // Slice 20 contiguous bytes from bytes `data`, starting at `start`
    function sliceBytes20(bytes data, uint start) returns (bytes20) {
        uint160 slice = 0;
        for (uint160 i = 0; i < 20; i++) {
            slice += uint160(data[i + start]) << (8 * (19 - i));
        }
        return bytes20(slice);
    }
    // returns true if the bytes located in txBytes by pos and
    // script_len represent a P2PKH script
    function isP2PKH(bytes txBytes, uint pos, uint script_len) returns (bool) {
        return (script_len == 25)           // 20 byte pubkeyhash + 5 bytes of script
            && (txBytes[pos] == 0x76)       // OP_DUP
            && (txBytes[pos + 1] == 0xa9)   // OP_HASH160
            && (txBytes[pos + 2] == 0x14)   // bytes to push
            && (txBytes[pos + 23] == 0x88)  // OP_EQUALVERIFY
            && (txBytes[pos + 24] == 0xac); // OP_CHECKSIG
    }
    // returns true if the bytes located in txBytes by pos and
    // script_len represent a P2SH script
    function isP2SH(bytes txBytes, uint pos, uint script_len) returns (bool) {
        return (script_len == 23)           // 20 byte scripthash + 3 bytes of script
            && (txBytes[pos + 0] == 0xa9)   // OP_HASH160
            && (txBytes[pos + 1] == 0x14)   // bytes to push
            && (txBytes[pos + 22] == 0x87); // OP_EQUAL
    }
    // Get the pubkeyhash / scripthash from an output script. Assumes
    // pay-to-pubkey-hash (P2PKH) or pay-to-script-hash (P2SH) outputs.
    // Returns the pubkeyhash/ scripthash, or zero if unknown output.
    function parseOutputScript(bytes txBytes, uint pos, uint script_len)
             returns (bytes20)
    {
        if (isP2PKH(txBytes, pos, script_len)) {
            return sliceBytes20(txBytes, pos + 3);
        } else if (isP2SH(txBytes, pos, script_len)) {
            return sliceBytes20(txBytes, pos + 2);
        } else {
            return;
        }
    }
}

contract LockinManager {
    using SafeMath for uint256;

    /*Defines the structure for a lock*/
    struct Lock {
        uint256 amount;
        uint256 unlockDate;
        uint256 lockedFor;
    }
    
    /*Object of Lock*/    
    Lock lock;

    /*Value of default lock days*/
    uint256 defaultAllowedLock = 7;

    /* mapping of list of locked address with array of locks for a particular address */
    mapping (address => Lock[]) public lockedAddresses;

    /* mapping of valid contracts with their lockin timestamp */
    mapping (address => uint256) public allowedContracts;

    /* list of locked days mapped with their locked timestamp*/
    mapping (uint => uint256) public allowedLocks;

    /* Defines our interface to the token contract */
    Token token;

    /* Defines the admin contract we interface with for credentails. */
    AuthenticationManager authenticationManager;

     /* Fired whenever lock day is added by the admin. */
    event LockedDayAdded(address _admin, uint256 _daysLocked, uint256 timestamp);

     /* Fired whenever lock day is removed by the admin. */
    event LockedDayRemoved(address _admin, uint256 _daysLocked, uint256 timestamp);

     /* Fired whenever valid contract is added by the admin. */
    event ValidContractAdded(address _admin, address _validAddress, uint256 timestamp);

     /* Fired whenever valid contract is removed by the admin. */
    event ValidContractRemoved(address _admin, address _validAddress, uint256 timestamp);

    /* Create a new instance of this fund with links to other contracts that are required. */
    function LockinManager(address _token, address _authenticationManager) {
      
        /* Setup access to our other contracts and validate their versions */
        token  = Token(_token);
        authenticationManager = AuthenticationManager(_authenticationManager);
    }
   
    /* This modifier allows a method to only be called by current admins */
    modifier adminOnly {
        if (!authenticationManager.isCurrentAdmin(msg.sender)) throw;
        _;
    }

    /* This modifier allows a method to only be called by token contract */
    modifier validContractOnly {
        require(allowedContracts[msg.sender] != 0);

        _;
    }

    /* Gets the length of locked values for an account */
    function getLocks(address _owner) validContractOnly constant returns (uint256) {
        return lockedAddresses[_owner].length;
    }

    function getLock(address _owner, uint256 count) validContractOnly returns(uint256 amount, uint256 unlockDate, uint256 lockedFor) {
        amount     = lockedAddresses[_owner][count].amount;
        unlockDate = lockedAddresses[_owner][count].unlockDate;
        lockedFor   = lockedAddresses[_owner][count].lockedFor;
    }
    
    /* Gets amount for which an address is locked with locked index */
    function getLocksAmount(address _owner, uint256 count) validContractOnly returns(uint256 amount) {        
        amount = lockedAddresses[_owner][count].amount;
    }

    /* Gets unlocked timestamp for which an address is locked with locked index */
    function getLocksUnlockDate(address _owner, uint256 count) validContractOnly returns(uint256 unlockDate) {
        unlockDate = lockedAddresses[_owner][count].unlockDate;
    }

    /* Gets days for which an address is locked with locked index */
    function getLocksLockedFor(address _owner, uint256 count) validContractOnly returns(uint256 lockedFor) {
        lockedFor = lockedAddresses[_owner][count].lockedFor;
    }

    /* Locks tokens for an address for the default number of days */
    function defaultLockin(address _address, uint256 _value) validContractOnly
    {
        lockIt(_address, _value, defaultAllowedLock);
    }

    /* locks tokens for sender for n days*/
    function lockForDays(uint256 _value, uint256 _days) 
    {
        require( ! ifInAllowedLocks(_days));        

        require(token.availableBalance(msg.sender) >= _value);
        
        lockIt(msg.sender, _value, _days);     
    }

    function lockIt(address _address, uint256 _value, uint256 _days) internal {

        // expiry will be calculated as 24 * 60 * 60
        uint256 _expiry = now + _days.mul(86400);
        lockedAddresses[_address].push(Lock(_value, _expiry, _days));        
    }

    /* check if input day is present in locked days */
    function ifInAllowedLocks(uint256 _days) constant returns(bool) {
        return allowedLocks[_days] == 0;
    }

    /* Adds a day to our list of allowedLocks */
    function addAllowedLock(uint _day) adminOnly {

        // Fail if day is already present in locked days
        if (allowedLocks[_day] != 0)
            throw;
        
        // Add day in locked days 
        allowedLocks[_day] = now;
        LockedDayAdded(msg.sender, _day, now);
    }

    /* Remove allowed Lock */
    function removeAllowedLock(uint _day) adminOnly {

        // Fail if day doesnot exist in allowedLocks
        if ( allowedLocks[_day] ==  0)
            throw;

        /* Remove locked day  */
        allowedLocks[_day] = 0;
        LockedDayRemoved(msg.sender, _day, now);
    }

    /* Adds a address to our list of allowedContracts */
    function addValidContract(address _address) adminOnly {

        // Fail if address is already present in valid contracts
        if (allowedContracts[_address] != 0)
            throw;
        
        // add an address in allowedContracts
        allowedContracts[_address] = now;

        ValidContractAdded(msg.sender, _address, now);
    }

    /* Removes allowed contract from the list of allowedContracts */
    function removeValidContract(address _address) adminOnly {

        // Fail if address doesnot exist in allowedContracts
        if ( allowedContracts[_address] ==  0)
            throw;

        /* Remove allowed contract from allowedContracts  */
        allowedContracts[_address] = 0;

        ValidContractRemoved(msg.sender, _address, now);
    }

    /* Set default allowed lock */
    function setDefaultAllowedLock(uint _days) adminOnly {
        defaultAllowedLock = _days;
    }
}

/* The Token itself is a simple extension of the ERC20 that allows for granting other Token contracts special rights to act on behalf of all transfers. */
contract Token {
    using SafeMath for uint256;

    /* Map all our our balances for issued tokens */
    mapping (address => uint256) public balances;

    /* Map between users and their approval addresses and amounts */
    mapping(address => mapping (address => uint256)) allowed;

    /* List of all token holders */
    address[] allTokenHolders;

    /* The name of the contract */
    string public name;

    /* The symbol for the contract */
    string public symbol;

    /* How many DPs are in use in this contract */
    uint8 public decimals;

    /* Defines the current supply of the token in its own units */
    uint256 totalSupplyAmount = 0;
    
    /* Defines the address of the Refund Manager contract which is the only contract to destroy tokens. */
    address public refundManagerContractAddress;

    /* Defines the admin contract we interface with for credentails. */
    AuthenticationManager authenticationManager;

    /* Instance of lockin contract */
    LockinManager lockinManager;

    /** @dev Returns the balance that a given address has available for transfer.
      * @param _owner The address of the token owner.
      */
    function availableBalance(address _owner) constant returns(uint256) {
        
        uint256 length =  lockinManager.getLocks(_owner);
    
        uint256 lockedValue = 0;
        
        for(uint256 i = 0; i < length; i++) {

            if(lockinManager.getLocksUnlockDate(_owner, i) > now) {
                uint256 _value = lockinManager.getLocksAmount(_owner, i);    
                lockedValue = lockedValue.add(_value);                
            }
        }
        
        return balances[_owner].sub(lockedValue);
    }

    /* Fired when the fund is eventually closed. */
    event FundClosed();
    
    /* Our transfer event to fire whenever we shift SMRT around */
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    /* Our approval event when one user approves another to control */
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    /* Create a new instance of this fund with links to other contracts that are required. */
    function Token(address _authenticationManagerAddress) {
        // Setup defaults
        name = "PIE (Authorito Capital)";
        symbol = "PIE";
        decimals = 18;

        /* Setup access to our other contracts */
        authenticationManager = AuthenticationManager(_authenticationManagerAddress);        
    }

    modifier onlyPayloadSize(uint numwords) {
        assert(msg.data.length == numwords * 32 + 4);
        _;
    }

    /* This modifier allows a method to only be called by account readers */
    modifier accountReaderOnly {
        if (!authenticationManager.isCurrentAccountReader(msg.sender)) throw;
        _;
    }

    /* This modifier allows a method to only be called by current admins */
    modifier adminOnly {
        if (!authenticationManager.isCurrentAdmin(msg.sender)) throw;
        _;
    }   
    
    function setLockinManagerAddress(address _lockinManager) adminOnly {
        lockinManager = LockinManager(_lockinManager);
    }

    function setRefundManagerContract(address _refundManagerContractAddress) adminOnly {
        refundManagerContractAddress = _refundManagerContractAddress;
    }

    /* Transfer funds between two addresses that are not the current msg.sender - this requires approval to have been set separately and follows standard ERC20 guidelines */
    function transferFrom(address _from, address _to, uint256 _amount) onlyPayloadSize(3) returns (bool) {
        
        if (availableBalance(_from) >= _amount && allowed[_from][msg.sender] >= _amount && _amount > 0 && balances[_to].add(_amount) > balances[_to]) {
            bool isNew = balances[_to] == 0;
            balances[_from] = balances[_from].sub(_amount);
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_amount);
            balances[_to] = balances[_to].add(_amount);
            if (isNew)
                tokenOwnerAdd(_to);
            if (balances[_from] == 0)
                tokenOwnerRemove(_from);
            Transfer(_from, _to, _amount);
            return true;
        }
        return false;
    }

    /* Returns the total number of holders of this currency. */
    function tokenHolderCount() accountReaderOnly constant returns (uint256) {
        return allTokenHolders.length;
    }

    /* Gets the token holder at the specified index. */
    function tokenHolder(uint256 _index) accountReaderOnly constant returns (address) {
        return allTokenHolders[_index];
    }
 
    /* Adds an approval for the specified account to spend money of the message sender up to the defined limit */
    function approve(address _spender, uint256 _amount) onlyPayloadSize(2) returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    /* Gets the current allowance that has been approved for the specified spender of the owner address */
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /* Gets the total supply available of this token */
    function totalSupply() constant returns (uint256) {
        return totalSupplyAmount;
    }

    /* Gets the balance of a specified account */
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    /* Transfer the balance from owner's account to another account */
    function transfer(address _to, uint256 _amount) onlyPayloadSize(2) returns (bool) {
                
        /* Check if sender has balance and for overflows */
        if (availableBalance(msg.sender) < _amount || balances[_to].add(_amount) < balances[_to])
            return false;

        /* Do a check to see if they are new, if so we'll want to add it to our array */
        bool isRecipientNew = balances[_to] == 0;

        /* Add and subtract new balances */
        balances[msg.sender] = balances[msg.sender].sub(_amount);
        balances[_to] = balances[_to].add(_amount);
        
        /* Consolidate arrays if they are new or if sender now has empty balance */
        if (isRecipientNew)
            tokenOwnerAdd(_to);
        if (balances[msg.sender] <= 0)
            tokenOwnerRemove(msg.sender);

        /* Fire notification event */
        Transfer(msg.sender, _to, _amount);
        return true; 
    }

    /* If the specified address is not in our owner list, add them - this can be called by descendents to ensure the database is kept up to date. */
    function tokenOwnerAdd(address _addr) internal {
        /* First check if they already exist */
        uint256 tokenHolderCount = allTokenHolders.length;
        for (uint256 i = 0; i < tokenHolderCount; i++)
            if (allTokenHolders[i] == _addr)
                /* Already found so we can abort now */
                return;
        
        /* They don't seem to exist, so let's add them */
        allTokenHolders.length++;
        allTokenHolders[allTokenHolders.length - 1] = _addr;
    }

    /* If the specified address is in our owner list, remove them - this can be called by descendents to ensure the database is kept up to date. */
    function tokenOwnerRemove(address _addr) internal {
        /* Find out where in our array they are */
        uint256 tokenHolderCount = allTokenHolders.length;
        uint256 foundIndex = 0;
        bool found = false;
        uint256 i;
        for (i = 0; i < tokenHolderCount; i++)
            if (allTokenHolders[i] == _addr) {
                foundIndex = i;
                found = true;
                break;
            }
        
        /* If we didn't find them just return */
        if (!found)
            return;
        
        /* We now need to shuffle down the array */
        for (i = foundIndex; i < tokenHolderCount - 1; i++)
            allTokenHolders[i] = allTokenHolders[i + 1];
        allTokenHolders.length--;
    }

    /* Mint new tokens - this can only be done by special callers (i.e. the ICO management) during the ICO phase. */
    function mintTokens(address _address, uint256 _amount) onlyPayloadSize(2) {

        /* if it is comming from account minter */
        if ( ! authenticationManager.isCurrentAccountMinter(msg.sender))
            throw;

        /* Mint the tokens for the new address*/
        bool isNew = balances[_address] == 0;
        totalSupplyAmount = totalSupplyAmount.add(_amount);
        balances[_address] = balances[_address].add(_amount);

        lockinManager.defaultLockin(_address, _amount);        

        if (isNew)
            tokenOwnerAdd(_address);
        Transfer(0, _address, _amount);
    }

    /** This will destroy the tokens of the investor and called by sale contract only at the time of refund. */
    function destroyTokens(address _investor, uint256 tokenCount) returns (bool) {
        
        /* Can only be called by refund manager, also refund manager address must not be empty */
        if ( refundManagerContractAddress  == 0x0 || msg.sender != refundManagerContractAddress)
            throw;

        uint256 balance = availableBalance(_investor);

        if (balance < tokenCount) {
            return false;
        }

        balances[_investor] -= tokenCount;
        totalSupplyAmount -= tokenCount;

        if(balances[_investor] <= 0)
            tokenOwnerRemove(_investor);

        return true;
    }
}

contract Tokensale {
    using SafeMath for uint256;
    
    /* Defines whether or not the  Token Contract address has yet been set.  */
    bool public tokenContractDefined = false;
    
    /* Defines whether or not we are in the Sale phase */
    bool public salePhase = true;

    /* Defines the sale price of ethereum during Sale */
    uint256 public ethereumSaleRate = 700; // The number of tokens to be minted for every ETH

    /* Defines the sale price of bitcoin during Sale */
    uint256 public bitcoinSaleRate = 14000; // The number of tokens to be minted for every BTC

    /* Defines our interface to the  Token contract. */
    Token token;

    /* Defines the admin contract we interface with for credentails. */
    AuthenticationManager authenticationManager;

    /* Claimed Transactions from btc relay. */
    mapping(uint256 => bool) public transactionsClaimed;

    /* Defines the minimum ethereum to invest during Sale */
    uint256 public minimunEthereumToInvest = 0;

    /* Defines the minimum btc to invest during Sale */
    uint256 public minimunBTCToInvest = 0;

    /* Defines our event fired when the Sale is closed */
    event SaleClosed();

    /* Defines our event fired when the Sale is reopened */
    event SaleStarted();

    /* Ethereum Rate updated by the admin. */
    event EthereumRateUpdated(uint256 rate, uint256 timestamp);

    /* Bitcoin Rate updated by the admin. */
    event BitcoinRateUpdated(uint256 rate, uint256 timestamp);

    /* Minimun Ethereum Investment updated by the admin. */
    event MinimumEthereumInvestmentUpdated(uint256 _value, uint256 timestamp);

    /* Minimun Bitcoin Investment updated by the admin. */
    event MinimumBitcoinInvestmentUpdated(uint256 _value, uint256 timestamp);

    /* Ensures that once the Sale is over this contract cannot be used until the point it is destructed. */
    modifier onlyDuringSale {

        if (!tokenContractDefined || (!salePhase)) throw;
        _;
    }

    /* This modifier allows a method to only be called by current admins */
    modifier adminOnly {
        if (!authenticationManager.isCurrentAdmin(msg.sender)) throw;
        _;
    }

    /* Create the  token sale and define the address of the main authentication Manager address. */
    function Tokensale(address _authenticationManagerAddress) {        
                
        /* Setup access to our other contracts */
        authenticationManager = AuthenticationManager(_authenticationManagerAddress);
    }

    /* Set the Token contract address as a one-time operation.  This happens after all the contracts are created and no
       other functionality can be used until this is set. */
    function setTokenContractAddress(address _tokenContractAddress) adminOnly {
        /* This can only happen once in the lifetime of this contract */
        if (tokenContractDefined)
            throw;

        /* Setup access to our other contracts */
        token = Token(_tokenContractAddress);

        tokenContractDefined = true;
    }

    /* Run this function when transaction has been verified by the btc relay */
    function processBTCTransaction(bytes txn, uint256 _txHash, address ethereumAddress, bytes20 bitcoinAddress) adminOnly returns (uint256)
    {
        /* Transaction is already claimed */
        if(transactionsClaimed[_txHash] != false) 
            throw;

        var (outputValue1, outputAddress1, outputValue2, outputAddress2) = BTC.getFirstTwoOutputs(txn);

        if(BTC.checkValueSent(txn, bitcoinAddress, 1))
        {
            require(outputValue1 >= minimunBTCToInvest);

             //multiply by exchange rate
            uint256 tokensPurchased = outputValue1 * bitcoinSaleRate * (10**10);  

            token.mintTokens(ethereumAddress, tokensPurchased);

            transactionsClaimed[_txHash] = true;
        }
        else
        {
            // value was not sent to this btc address
            throw;
        }
    }

    function btcTransactionClaimed(uint256 _txHash) returns(bool) {
        return transactionsClaimed[_txHash];
    }   
    
    // fallback function can be used to buy tokens
    function () payable {
    
        buyTokens(msg.sender);
    
    }

    /* Handle receiving ether in Sale phase - we work out how much the user has bought, allocate a suitable balance and send their change */
    function buyTokens(address beneficiary) onlyDuringSale payable {

        require(beneficiary != 0x0);
        require(validPurchase());
        
        uint256 weiAmount = msg.value;

        uint256 tokensPurchased = weiAmount.mul(ethereumSaleRate);
        
        /* Increase their new balance if they actually purchased any */
        if (tokensPurchased > 0)
        {
            token.mintTokens(beneficiary, tokensPurchased);
        }
    }

    // @return true if the transaction can buy tokens
    function validPurchase() internal constant returns (bool) {

        bool nonZeroPurchase = ( msg.value != 0 && msg.value >= minimunEthereumToInvest);
        return nonZeroPurchase;
    }

    /* Rate on which */
    function setEthereumRate(uint256 _rate) adminOnly {

        ethereumSaleRate = _rate;

        /* Audit this */
        EthereumRateUpdated(ethereumSaleRate, now);
    }

      /* Rate on which */
    function setBitcoinRate(uint256 _rate) adminOnly {

        bitcoinSaleRate = _rate;

        /* Audit this */
        BitcoinRateUpdated(bitcoinSaleRate, now);
    }    

        /* update min Ethereum to invest */
    function setMinimumEthereumToInvest(uint256 _value) adminOnly {

        minimunEthereumToInvest = _value;

        /* Audit this */
        MinimumEthereumInvestmentUpdated(_value, now);
    }    

          /* update minimum Bitcoin to invest */
    function setMinimumBitcoinToInvest(uint256 _value) adminOnly {

        minimunBTCToInvest = _value;

        /* Audit this */
        MinimumBitcoinInvestmentUpdated(_value, now);
    }

      /* Close the Sale phase and transition to execution phase */
    function close() adminOnly onlyDuringSale {

        // Close the Sale
        salePhase = false;
        SaleClosed();

        // Withdraw funds to the caller
        if (!msg.sender.send(this.balance))
            throw;
    }

    /* Open the sale phase*/
    function openSale() adminOnly {        
        salePhase = true;
        SaleStarted();
    }
}