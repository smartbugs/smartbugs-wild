pragma solidity ^0.4.24;

/**
 * @title Module
 * @dev Interface for a module. 
 * A module MUST implement the addModule() method to ensure that a wallet with at least one module
 * can never end up in a "frozen" state.
 * @author Julien Niset - <julien@argent.xyz>
 */
interface Module {

    /**
     * @dev Inits a module for a wallet by e.g. setting some wallet specific parameters in storage.
     * @param _wallet The wallet.
     */
    function init(BaseWallet _wallet) external;

    /**
     * @dev Adds a module to a wallet.
     * @param _wallet The target wallet.
     * @param _module The modules to authorise.
     */
    function addModule(BaseWallet _wallet, Module _module) external;

    /**
    * @dev Utility method to recover any ERC20 token that was sent to the
    * module by mistake. 
    * @param _token The token to recover.
    */
    function recoverToken(address _token) external;
}

/**
 * @title BaseModule
 * @dev Basic module that contains some methods common to all modules.
 * @author Julien Niset - <julien@argent.xyz>
 */
contract BaseModule is Module {

    // The adddress of the module registry.
    ModuleRegistry internal registry;

    event ModuleCreated(bytes32 name);
    event ModuleInitialised(address wallet);

    constructor(ModuleRegistry _registry, bytes32 _name) public {
        registry = _registry;
        emit ModuleCreated(_name);
    }

    /**
     * @dev Throws if the sender is not the target wallet of the call.
     */
    modifier onlyWallet(BaseWallet _wallet) {
        require(msg.sender == address(_wallet), "BM: caller must be wallet");
        _;
    }

    /**
     * @dev Throws if the sender is not the owner of the target wallet or the module itself.
     */
    modifier onlyOwner(BaseWallet _wallet) {
        require(msg.sender == address(this) || isOwner(_wallet, msg.sender), "BM: must be an owner for the wallet");
        _;
    }

    /**
     * @dev Throws if the sender is not the owner of the target wallet.
     */
    modifier strictOnlyOwner(BaseWallet _wallet) {
        require(isOwner(_wallet, msg.sender), "BM: msg.sender must be an owner for the wallet");
        _;
    }

    /**
     * @dev Inits the module for a wallet by logging an event.
     * The method can only be called by the wallet itself.
     * @param _wallet The wallet.
     */
    function init(BaseWallet _wallet) external onlyWallet(_wallet) {
        emit ModuleInitialised(_wallet);
    }

    /**
     * @dev Adds a module to a wallet. First checks that the module is registered.
     * @param _wallet The target wallet.
     * @param _module The modules to authorise.
     */
    function addModule(BaseWallet _wallet, Module _module) external strictOnlyOwner(_wallet) {
        require(registry.isRegisteredModule(_module), "BM: module is not registered");
        _wallet.authoriseModule(_module, true);
    }

    /**
    * @dev Utility method enbaling anyone to recover ERC20 token sent to the
    * module by mistake and transfer them to the Module Registry. 
    * @param _token The token to recover.
    */
    function recoverToken(address _token) external {
        uint total = ERC20(_token).balanceOf(address(this));
        ERC20(_token).transfer(address(registry), total);
    }

    /**
     * @dev Helper method to check if an address is the owner of a target wallet.
     * @param _wallet The target wallet.
     * @param _addr The address.
     */
    function isOwner(BaseWallet _wallet, address _addr) internal view returns (bool) {
        return _wallet.owner() == _addr;
    }
}

/**
 * @title RelayerModule
 * @dev Base module containing logic to execute transactions signed by eth-less accounts and sent by a relayer. 
 * @author Julien Niset - <julien@argent.xyz>
 */
contract RelayerModule is Module {

    uint256 constant internal BLOCKBOUND = 10000;

    mapping (address => RelayerConfig) public relayer; 

    struct RelayerConfig {
        uint256 nonce;
        mapping (bytes32 => bool) executedTx;
    }

    event TransactionExecuted(address indexed wallet, bool indexed success, bytes32 signedHash);

    /**
     * @dev Throws if the call did not go through the execute() method.
     */
    modifier onlyExecute {
        require(msg.sender == address(this), "RM: must be called via execute()");
        _;
    }

    /* ***************** Abstract method ************************* */

    /**
    * @dev Gets the number of valid signatures that must be provided to execute a
    * specific relayed transaction.
    * @param _wallet The target wallet.
    * @param _data The data of the relayed transaction.
    * @return The number of required signatures.
    */
    function getRequiredSignatures(BaseWallet _wallet, bytes _data) internal view returns (uint256);

    /**
    * @dev Validates the signatures provided with a relayed transaction.
    * The method MUST throw if one or more signatures are not valid.
    * @param _wallet The target wallet.
    * @param _data The data of the relayed transaction.
    * @param _signHash The signed hash representing the relayed transaction.
    * @param _signatures The signatures as a concatenated byte array.
    */
    function validateSignatures(BaseWallet _wallet, bytes _data, bytes32 _signHash, bytes _signatures) internal view returns (bool);

    /* ************************************************************ */

    /**
    * @dev Executes a relayed transaction.
    * @param _wallet The target wallet.
    * @param _data The data for the relayed transaction
    * @param _nonce The nonce used to prevent replay attacks.
    * @param _signatures The signatures as a concatenated byte array.
    * @param _gasPrice The gas price to use for the gas refund.
    * @param _gasLimit The gas limit to use for the gas refund.
    */
    function execute(
        BaseWallet _wallet,
        bytes _data, 
        uint256 _nonce, 
        bytes _signatures, 
        uint256 _gasPrice,
        uint256 _gasLimit
    )
        external
        returns (bool success)
    {
        uint startGas = gasleft();
        bytes32 signHash = getSignHash(address(this), _wallet, 0, _data, _nonce, _gasPrice, _gasLimit);
        require(checkAndUpdateUniqueness(_wallet, _nonce, signHash), "RM: Duplicate request");
        require(verifyData(address(_wallet), _data), "RM: the wallet authorized is different then the target of the relayed data");
        uint256 requiredSignatures = getRequiredSignatures(_wallet, _data);
        if((requiredSignatures * 65) == _signatures.length) {
            if(verifyRefund(_wallet, _gasLimit, _gasPrice, requiredSignatures)) {
                if(requiredSignatures == 0 || validateSignatures(_wallet, _data, signHash, _signatures)) {
                    // solium-disable-next-line security/no-call-value
                    success = address(this).call(_data);
                    refund(_wallet, startGas - gasleft(), _gasPrice, _gasLimit, requiredSignatures, msg.sender);
                }
            }
        }
        emit TransactionExecuted(_wallet, success, signHash); 
    }

    /**
    * @dev Gets the current nonce for a wallet.
    * @param _wallet The target wallet.
    */
    function getNonce(BaseWallet _wallet) external view returns (uint256 nonce) {
        return relayer[_wallet].nonce;
    }

    /**
    * @dev Generates the signed hash of a relayed transaction according to ERC 1077.
    * @param _from The starting address for the relayed transaction (should be the module)
    * @param _to The destination address for the relayed transaction (should be the wallet)
    * @param _value The value for the relayed transaction
    * @param _data The data for the relayed transaction
    * @param _nonce The nonce used to prevent replay attacks.
    * @param _gasPrice The gas price to use for the gas refund.
    * @param _gasLimit The gas limit to use for the gas refund.
    */
    function getSignHash(
        address _from,
        address _to, 
        uint256 _value, 
        bytes _data, 
        uint256 _nonce,
        uint256 _gasPrice,
        uint256 _gasLimit
    ) 
        internal 
        pure
        returns (bytes32) 
    {
        return keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                keccak256(abi.encodePacked(byte(0x19), byte(0), _from, _to, _value, _data, _nonce, _gasPrice, _gasLimit))
        ));
    }

    /**
    * @dev Checks if the relayed transaction is unique.
    * @param _wallet The target wallet.
    * @param _nonce The nonce
    * @param _signHash The signed hash of the transaction
    */
    function checkAndUpdateUniqueness(BaseWallet _wallet, uint256 _nonce, bytes32 _signHash) internal returns (bool) {
        if(relayer[_wallet].executedTx[_signHash] == true) {
            return false;
        }
        relayer[_wallet].executedTx[_signHash] = true;
        return true;
    }

    /**
    * @dev Checks that a nonce has the correct format and is valid. 
    * It must be constructed as nonce = {block number}{timestamp} where each component is 16 bytes.
    * @param _wallet The target wallet.
    * @param _nonce The nonce
    */
    function checkAndUpdateNonce(BaseWallet _wallet, uint256 _nonce) internal returns (bool) {
        if(_nonce <= relayer[_wallet].nonce) {
            return false;
        }   
        uint256 nonceBlock = (_nonce & 0xffffffffffffffffffffffffffffffff00000000000000000000000000000000) >> 128;
        if(nonceBlock > block.number + BLOCKBOUND) {
            return false;
        }
        relayer[_wallet].nonce = _nonce;
        return true;    
    }

    /**
    * @dev Recovers the signer at a given position from a list of concatenated signatures.
    * @param _signedHash The signed hash
    * @param _signatures The concatenated signatures.
    * @param _index The index of the signature to recover.
    */
    function recoverSigner(bytes32 _signedHash, bytes _signatures, uint _index) internal pure returns (address) {
        uint8 v;
        bytes32 r;
        bytes32 s;
        // we jump 32 (0x20) as the first slot of bytes contains the length
        // we jump 65 (0x41) per signature
        // for v we load 32 bytes ending with v (the first 31 come from s) then apply a mask
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            r := mload(add(_signatures, add(0x20,mul(0x41,_index))))
            s := mload(add(_signatures, add(0x40,mul(0x41,_index))))
            v := and(mload(add(_signatures, add(0x41,mul(0x41,_index)))), 0xff)
        }
        require(v == 27 || v == 28); 
        return ecrecover(_signedHash, v, r, s);
    }

    /**
    * @dev Refunds the gas used to the Relayer. 
    * For security reasons the default behavior is to not refund calls with 0 or 1 signatures. 
    * @param _wallet The target wallet.
    * @param _gasUsed The gas used.
    * @param _gasPrice The gas price for the refund.
    * @param _gasLimit The gas limit for the refund.
    * @param _signatures The number of signatures used in the call.
    * @param _relayer The address of the Relayer.
    */
    function refund(BaseWallet _wallet, uint _gasUsed, uint _gasPrice, uint _gasLimit, uint _signatures, address _relayer) internal {
        uint256 amount = 29292 + _gasUsed; // 21000 (transaction) + 7620 (execution of refund) + 672 to log the event + _gasUsed
        // only refund if gas price not null, more than 1 signatures, gas less than gasLimit
        if(_gasPrice > 0 && _signatures > 1 && amount <= _gasLimit) {
            if(_gasPrice > tx.gasprice) {
                amount = amount * tx.gasprice;
            }
            else {
                amount = amount * _gasPrice;
            }
            _wallet.invoke(_relayer, amount, "");
        }
    }

    /**
    * @dev Returns false if the refund is expected to fail.
    * @param _wallet The target wallet.
    * @param _gasUsed The expected gas used.
    * @param _gasPrice The expected gas price for the refund.
    */
    function verifyRefund(BaseWallet _wallet, uint _gasUsed, uint _gasPrice, uint _signatures) internal view returns (bool) {
        if(_gasPrice > 0 
            && _signatures > 1 
            && (address(_wallet).balance < _gasUsed * _gasPrice || _wallet.authorised(this) == false)) {
            return false;
        }
        return true;
    }

    /**
    * @dev Checks that the wallet address provided as the first parameter of the relayed data is the same
    * as the wallet passed as the input of the execute() method. 
    @return false if the addresses are different.
    */
    function verifyData(address _wallet, bytes _data) private pure returns (bool) {
        require(_data.length >= 36, "RM: Invalid dataWallet");
        address dataWallet;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            //_data = {length:32}{sig:4}{_wallet:32}{...}
            dataWallet := mload(add(_data, 0x24))
        }
        return dataWallet == _wallet;
    }

    /**
    * @dev Parses the data to extract the method signature. 
    */
    function functionPrefix(bytes _data) internal pure returns (bytes4 prefix) {
        require(_data.length >= 4, "RM: Invalid functionPrefix");
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            prefix := mload(add(_data, 0x20))
        }
    }
}

/**
 * @title LimitManager
 * @dev Module to transfer tokens (ETH or ERC20) based on a security context (daily limit, whitelist, etc).
 * @author Julien Niset - <julien@argent.xyz>
 */
contract LimitManager is BaseModule {

    // large limit when the limit can be considered disabled
    uint128 constant internal LIMIT_DISABLED = uint128(-1); // 3.40282366920938463463374607431768211455e+38

    using SafeMath for uint256;

    struct LimitManagerConfig {
        // The global limit
        Limit limit;
        // whitelist
        DailySpent dailySpent;
    } 

    struct Limit {
        // the current limit
        uint128 current;
        // the pending limit if any
        uint128 pending;
        // when the pending limit becomes the current limit
        uint64 changeAfter;
    }

    struct DailySpent {
        // The amount already spent during the current period
        uint128 alreadySpent;
        // The end of the current period
        uint64 periodEnd;
    }

    // wallet specific storage
    mapping (address => LimitManagerConfig) internal limits;
    // The default limit
    uint256 public defaultLimit;

    // *************** Events *************************** //

    event LimitChanged(address indexed wallet, uint indexed newLimit, uint64 indexed startAfter);

    // *************** Constructor ********************** //

    constructor(uint256 _defaultLimit) public {
        defaultLimit = _defaultLimit;
    }

    // *************** External/Public Functions ********************* //

    /**
     * @dev Inits the module for a wallet by setting the limit to the default value.
     * @param _wallet The target wallet.
     */
    function init(BaseWallet _wallet) external onlyWallet(_wallet) {
        Limit storage limit = limits[_wallet].limit;
        if(limit.current == 0 && limit.changeAfter == 0) {
            limit.current = uint128(defaultLimit);
        }
    }

    /**
     * @dev Changes the global limit. 
     * The limit is expressed in ETH and the change is pending for the security period.
     * @param _wallet The target wallet.
     * @param _newLimit The new limit.
     * @param _securityPeriod The security period.
     */
    function changeLimit(BaseWallet _wallet, uint256 _newLimit, uint256 _securityPeriod) internal {
        Limit storage limit = limits[_wallet].limit;
        // solium-disable-next-line security/no-block-members
        uint128 currentLimit = (limit.changeAfter > 0 && limit.changeAfter < now) ? limit.pending : limit.current;
        limit.current = currentLimit;
        limit.pending = uint128(_newLimit);
        // solium-disable-next-line security/no-block-members
        limit.changeAfter = uint64(now.add(_securityPeriod));
        // solium-disable-next-line security/no-block-members
        emit LimitChanged(_wallet, _newLimit, uint64(now.add(_securityPeriod)));
    }

    // *************** Internal Functions ********************* //

    /**
    * @dev Gets the current global limit for a wallet.
    * @param _wallet The target wallet.
    * @return the current limit expressed in ETH.
    */
    function getCurrentLimit(BaseWallet _wallet) public view returns (uint256 _currentLimit) {
        Limit storage limit = limits[_wallet].limit;
        _currentLimit = uint256(currentLimit(limit.current, limit.pending, limit.changeAfter));
    }

    /**
    * @dev Gets a pending limit for a wallet if any.
    * @param _wallet The target wallet.
    * @return the pending limit (in ETH) and the time at chich it will become effective.
    */
    function getPendingLimit(BaseWallet _wallet) external view returns (uint256 _pendingLimit, uint64 _changeAfter) {
        Limit storage limit = limits[_wallet].limit;
        // solium-disable-next-line security/no-block-members
        return ((now < limit.changeAfter)? (uint256(limit.pending), limit.changeAfter) : (0,0));
    }

    /**
    * @dev Gets the amount of tokens that has not yet been spent during the current period.
    * @param _wallet The target wallet.
    * @return the amount of tokens (in ETH) that has not been spent yet and the end of the period.
    */
    function getDailyUnspent(BaseWallet _wallet) external view returns (uint256 _unspent, uint64 _periodEnd) {
        uint256 globalLimit = getCurrentLimit(_wallet);
        DailySpent storage expense = limits[_wallet].dailySpent;
        // solium-disable-next-line security/no-block-members
        if(now > expense.periodEnd) {
            _unspent = globalLimit;
            _periodEnd = uint64(now + 24 hours);
        }
        else {
            _unspent = globalLimit - expense.alreadySpent;
            _periodEnd = expense.periodEnd;
        }
    }

    /**
    * @dev Helper method to check if a transfer is within the limit.
    * If yes the daily unspent for the current period is updated.
    * @param _wallet The target wallet.
    * @param _amount The amount for the transfer
    */
    function checkAndUpdateDailySpent(BaseWallet _wallet, uint _amount) internal returns (bool) {
        Limit storage limit = limits[_wallet].limit;
        uint128 current = currentLimit(limit.current, limit.pending, limit.changeAfter);
        if(isWithinDailyLimit(_wallet, current, _amount)) {
            updateDailySpent(_wallet, current, _amount);
            return true;
        }
        return false;
    }

    /**
    * @dev Helper method to update the daily spent for the current period.
    * @param _wallet The target wallet.
    * @param _limit The current limit for the wallet.
    * @param _amount The amount to add to the daily spent.
    */
    function updateDailySpent(BaseWallet _wallet, uint128 _limit, uint _amount) internal {
        if(_limit != LIMIT_DISABLED) {
            DailySpent storage expense = limits[_wallet].dailySpent;
            if (expense.periodEnd < now) {
                expense.periodEnd = uint64(now + 24 hours);
                expense.alreadySpent = uint128(_amount);
            }
            else {
                expense.alreadySpent += uint128(_amount);
            }
        }
    }

    /**
    * @dev Checks if a transfer amount is withing the daily limit for a wallet.
    * @param _wallet The target wallet.
    * @param _limit The current limit for the wallet.
    * @param _amount The transfer amount.
    * @return true if the transfer amount is withing the daily limit.
    */
    function isWithinDailyLimit(BaseWallet _wallet, uint _limit, uint _amount) internal view returns (bool)  {
        DailySpent storage expense = limits[_wallet].dailySpent;
        if(_limit == LIMIT_DISABLED) {
            return true;
        }
        else if (expense.periodEnd < now) {
            return (_amount <= _limit);
        } else {
            return (expense.alreadySpent + _amount <= _limit && expense.alreadySpent + _amount >= expense.alreadySpent);
        }
    }

    /**
    * @dev Helper method to get the current limit from a Limit struct.
    * @param _current The value of the current parameter
    * @param _pending The value of the pending parameter
    * @param _changeAfter The value of the changeAfter parameter
    */
    function currentLimit(uint128 _current, uint128 _pending, uint64 _changeAfter) internal view returns (uint128) {
        if(_changeAfter > 0 && _changeAfter < now) {
            return _pending;
        }
        return _current;
    }
}

contract TokenPriceProvider {

    using SafeMath for uint256;

    // Mock token address for ETH
    address constant internal ETH_TOKEN_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    // Address of Kyber's trading contract
    address constant internal KYBER_NETWORK_ADDRESS = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;

    mapping(address => uint256) public cachedPrices;

    function syncPrice(ERC20 token) public {
        uint256 expectedRate;
        (expectedRate,) = kyberNetwork().getExpectedRate(token, ERC20(ETH_TOKEN_ADDRESS), 10000);
        cachedPrices[token] = expectedRate;
    }

    //
    // Convenience functions
    //

    function syncPriceForTokenList(ERC20[] tokens) public {
        for(uint16 i = 0; i < tokens.length; i++) {
            syncPrice(tokens[i]);
        }
    }

    /**
     * @dev Converts the value of _amount tokens in ether.
     * @param _amount the amount of tokens to convert (in 'token wei' twei)
     * @param _token the ERC20 token contract
     * @return the ether value (in wei) of _amount tokens with contract _token
     */
    function getEtherValue(uint256 _amount, address _token) public view returns (uint256) {
        uint256 decimals = ERC20(_token).decimals();
        uint256 price = cachedPrices[_token];
        return price.mul(_amount).div(10**decimals);
    }

    //
    // Internal
    //

    function kyberNetwork() internal view returns (KyberNetwork) {
        return KyberNetwork(KYBER_NETWORK_ADDRESS);
    }
}

contract KyberNetwork {

    function getExpectedRate(
        ERC20 src,
        ERC20 dest,
        uint srcQty
    )
        public
        view
        returns (uint expectedRate, uint slippageRate);

    function trade(
        ERC20 src,
        uint srcAmount,
        ERC20 dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId
    )
        public
        payable
        returns(uint);
}

/* The MIT License (MIT)

Copyright (c) 2016 Smart Contract Solutions, Inc.

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }

    /**
    * @dev Returns ceil(a / b).
    */
    function ceil(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        if(a % b == 0) {
            return c;
        }
        else {
            return c + 1;
        }
    }
}

/**
 * ERC20 contract interface.
 */
contract ERC20 {
    function totalSupply() public view returns (uint);
    function decimals() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
}

/**
 * @title Owned
 * @dev Basic contract to define an owner.
 * @author Julien Niset - <julien@argent.xyz>
 */
contract Owned {

    // The owner
    address public owner;

    event OwnerChanged(address indexed _newOwner);

    /**
     * @dev Throws if the sender is not the owner.
     */
    modifier onlyOwner {
        require(msg.sender == owner, "Must be owner");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    /**
     * @dev Lets the owner transfer ownership of the contract to a new owner.
     * @param _newOwner The new owner.
     */
    function changeOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "Address must not be null");
        owner = _newOwner;
        emit OwnerChanged(_newOwner);
    }
}

/**
 * @title ModuleRegistry
 * @dev Registry of authorised modules. 
 * Modules must be registered before they can be authorised on a wallet.
 * @author Julien Niset - <julien@argent.xyz>
 */
contract ModuleRegistry is Owned {

    mapping (address => Info) internal modules;
    mapping (address => Info) internal upgraders;

    event ModuleRegistered(address indexed module, bytes32 name);
    event ModuleDeRegistered(address module);
    event UpgraderRegistered(address indexed upgrader, bytes32 name);
    event UpgraderDeRegistered(address upgrader);

    struct Info {
        bool exists;
        bytes32 name;
    }

    /**
     * @dev Registers a module.
     * @param _module The module.
     * @param _name The unique name of the module.
     */
    function registerModule(address _module, bytes32 _name) external onlyOwner {
        require(!modules[_module].exists, "MR: module already exists");
        modules[_module] = Info({exists: true, name: _name});
        emit ModuleRegistered(_module, _name);
    }

    /**
     * @dev Deregisters a module.
     * @param _module The module.
     */
    function deregisterModule(address _module) external onlyOwner {
        require(modules[_module].exists, "MR: module does not exists");
        delete modules[_module];
        emit ModuleDeRegistered(_module);
    }

        /**
     * @dev Registers an upgrader.
     * @param _upgrader The upgrader.
     * @param _name The unique name of the upgrader.
     */
    function registerUpgrader(address _upgrader, bytes32 _name) external onlyOwner {
        require(!upgraders[_upgrader].exists, "MR: upgrader already exists");
        upgraders[_upgrader] = Info({exists: true, name: _name});
        emit UpgraderRegistered(_upgrader, _name);
    }

    /**
     * @dev Deregisters an upgrader.
     * @param _upgrader The _upgrader.
     */
    function deregisterUpgrader(address _upgrader) external onlyOwner {
        require(upgraders[_upgrader].exists, "MR: upgrader does not exists");
        delete upgraders[_upgrader];
        emit UpgraderDeRegistered(_upgrader);
    }

    /**
    * @dev Utility method enbaling the owner of the registry to claim any ERC20 token that was sent to the
    * registry.
    * @param _token The token to recover.
    */
    function recoverToken(address _token) external onlyOwner {
        uint total = ERC20(_token).balanceOf(address(this));
        ERC20(_token).transfer(msg.sender, total);
    } 

    /**
     * @dev Gets the name of a module from its address.
     * @param _module The module address.
     * @return the name.
     */
    function moduleInfo(address _module) external view returns (bytes32) {
        return modules[_module].name;
    }

    /**
     * @dev Gets the name of an upgrader from its address.
     * @param _upgrader The upgrader address.
     * @return the name.
     */
    function upgraderInfo(address _upgrader) external view returns (bytes32) {
        return upgraders[_upgrader].name;
    }

    /**
     * @dev Checks if a module is registered.
     * @param _module The module address.
     * @return true if the module is registered.
     */
    function isRegisteredModule(address _module) external view returns (bool) {
        return modules[_module].exists;
    }

    /**
     * @dev Checks if a list of modules are registered.
     * @param _modules The list of modules address.
     * @return true if all the modules are registered.
     */
    function isRegisteredModule(address[] _modules) external view returns (bool) {
        for(uint i = 0; i < _modules.length; i++) {
            if (!modules[_modules[i]].exists) {
                return false;
            }
        }
        return true;
    }  

    /**
     * @dev Checks if an upgrader is registered.
     * @param _upgrader The upgrader address.
     * @return true if the upgrader is registered.
     */
    function isRegisteredUpgrader(address _upgrader) external view returns (bool) {
        return upgraders[_upgrader].exists;
    } 
}

/**
 * @title DappRegistry
 * @dev Registry of dapp contracts and methods that have been authorised by Argent. 
 * Registered methods can be authorised immediately for a dapp key and a wallet while 
 * the authoirsation of unregistered methods is delayed for 24 hours. 
 * @author Julien Niset - <julien@argent.xyz>
 */
contract DappRegistry is Owned {

    // [contract][signature][bool]
    mapping (address => mapping (bytes4 => bool)) internal authorised;

    event Registered(address indexed _contract, bytes4[] _methods);
    event Deregistered(address indexed _contract, bytes4[] _methods);

    /**
     * @dev Registers a list of methods for a dapp contract.
     * @param _contract The dapp contract.
     * @param _methods The dapp methods.
     */
    function register(address _contract, bytes4[] _methods) external onlyOwner {
        for(uint i = 0; i < _methods.length; i++) {
            authorised[_contract][_methods[i]] = true;
        }
        emit Registered(_contract, _methods);
    }

    /**
     * @dev Deregisters a list of methods for a dapp contract.
     * @param _contract The dapp contract.
     * @param _methods The dapp methods.
     */
    function deregister(address _contract, bytes4[] _methods) external onlyOwner {
        for(uint i = 0; i < _methods.length; i++) {
            authorised[_contract][_methods[i]] = false;
        }
        emit Deregistered(_contract, _methods);
    }

    /**
     * @dev Checks if a list of methods are registered for a dapp contract.
     * @param _contract The dapp contract.
     * @param _method The dapp methods.
     * @return true if all the methods are registered.
     */
    function isRegistered(address _contract, bytes4 _method) external view returns (bool) {
        return authorised[_contract][_method];
    }  

    /**
     * @dev Checks if a list of methods are registered for a dapp contract.
     * @param _contract The dapp contract.
     * @param _methods The dapp methods.
     * @return true if all the methods are registered.
     */
    function isRegistered(address _contract, bytes4[] _methods) external view returns (bool) {
        for(uint i = 0; i < _methods.length; i++) {
            if (!authorised[_contract][_methods[i]]) {
                return false;
            }
        }
        return true;
    }  
}

/**
 * @title Storage
 * @dev Base contract for the storage of a wallet.
 * @author Julien Niset - <julien@argent.xyz>
 */
contract Storage {

    /**
     * @dev Throws if the caller is not an authorised module.
     */
    modifier onlyModule(BaseWallet _wallet) {
        require(_wallet.authorised(msg.sender), "TS: must be an authorized module to call this method");
        _;
    }
}

/**
 * @title GuardianStorage
 * @dev Contract storing the state of wallets related to guardians and lock.
 * The contract only defines basic setters and getters with no logic. Only modules authorised
 * for a wallet can modify its state.
 * @author Julien Niset - <julien@argent.xyz>
 * @author Olivier Van Den Biggelaar - <olivier@argent.im>
 */
contract GuardianStorage is Storage {

    struct GuardianStorageConfig {
        // the list of guardians
        address[] guardians;
        // the info about guardians
        mapping (address => GuardianInfo) info;
        // the lock's release timestamp
        uint256 lock; 
        // the module that set the last lock
        address locker;
    }

    struct GuardianInfo {
        bool exists;
        uint128 index;
    }

    // wallet specific storage
    mapping (address => GuardianStorageConfig) internal configs;

    // *************** External Functions ********************* //

    /**
     * @dev Lets an authorised module add a guardian to a wallet.
     * @param _wallet The target wallet.
     * @param _guardian The guardian to add.
     */
    function addGuardian(BaseWallet _wallet, address _guardian) external onlyModule(_wallet) {
        GuardianStorageConfig storage config = configs[_wallet];
        config.info[_guardian].exists = true;
        config.info[_guardian].index = uint128(config.guardians.push(_guardian) - 1);
    }

    /**
     * @dev Lets an authorised module revoke a guardian from a wallet.
     * @param _wallet The target wallet.
     * @param _guardian The guardian to revoke.
     */
    function revokeGuardian(BaseWallet _wallet, address _guardian) external onlyModule(_wallet) {
        GuardianStorageConfig storage config = configs[_wallet];
        address lastGuardian = config.guardians[config.guardians.length - 1];
        if (_guardian != lastGuardian) {
            uint128 targetIndex = config.info[_guardian].index;
            config.guardians[targetIndex] = lastGuardian;
            config.info[lastGuardian].index = targetIndex;
        }
        config.guardians.length--;
        delete config.info[_guardian];
    }

    /**
     * @dev Returns the number of guardians for a wallet.
     * @param _wallet The target wallet.
     * @return the number of guardians.
     */
    function guardianCount(BaseWallet _wallet) external view returns (uint256) {
        return configs[_wallet].guardians.length;
    }
    
    /**
     * @dev Gets the list of guaridans for a wallet.
     * @param _wallet The target wallet.
     * @return the list of guardians.
     */
    function getGuardians(BaseWallet _wallet) external view returns (address[]) {
        GuardianStorageConfig storage config = configs[_wallet];
        address[] memory guardians = new address[](config.guardians.length);
        for (uint256 i = 0; i < config.guardians.length; i++) {
            guardians[i] = config.guardians[i];
        }
        return guardians;
    }

    /**
     * @dev Checks if an account is a guardian for a wallet.
     * @param _wallet The target wallet.
     * @param _guardian The account.
     * @return true if the account is a guardian for a wallet.
     */
    function isGuardian(BaseWallet _wallet, address _guardian) external view returns (bool) {
        return configs[_wallet].info[_guardian].exists;
    }

    /**
     * @dev Lets an authorised module set the lock for a wallet.
     * @param _wallet The target wallet.
     * @param _releaseAfter The epoch time at which the lock should automatically release.
     */
    function setLock(BaseWallet _wallet, uint256 _releaseAfter) external onlyModule(_wallet) {
        configs[_wallet].lock = _releaseAfter;
        if(_releaseAfter != 0 && msg.sender != configs[_wallet].locker) {
            configs[_wallet].locker = msg.sender;
        }
    }

    /**
     * @dev Checks if the lock is set for a wallet.
     * @param _wallet The target wallet.
     * @return true if the lock is set for the wallet.
     */
    function isLocked(BaseWallet _wallet) external view returns (bool) {
        return configs[_wallet].lock > now;
    }

    /**
     * @dev Gets the time at which the lock of a wallet will release.
     * @param _wallet The target wallet.
     * @return the time at which the lock of a wallet will release, or zero if there is no lock set.
     */
    function getLock(BaseWallet _wallet) external view returns (uint256) {
        return configs[_wallet].lock;
    }

    /**
     * @dev Gets the address of the last module that modified the lock for a wallet.
     * @param _wallet The target wallet.
     * @return the address of the last module that modified the lock for a wallet.
     */
    function getLocker(BaseWallet _wallet) external view returns (address) {
        return configs[_wallet].locker;
    }
}

/**
 * @title DappStorage
 * @dev Contract storing the state of wallets related to authorised dapps.
 * The contract only defines basic setters and getters with no logic. Only modules authorised
 * for a wallet can modify its state.
 * @author Olivier Van Den Biggelaar - <olivier@argent.im>
 */
contract DappStorage is Storage {

    // [wallet][dappkey][contract][signature][bool]
    mapping (address => mapping (address => mapping (address => mapping (bytes4 => bool)))) internal whitelistedMethods;
    
    // *************** External Functions ********************* //

    /**
     * @dev (De)authorizes an external contract's methods to be called by a dapp key of the wallet.
     * @param _wallet The wallet.
     * @param _dapp The address of the signing key.
     * @param _contract The contract address.
     * @param _signatures The methods' signatures.
     * @param _authorized true to whitelist, false to blacklist.
     */
    function setMethodAuthorization(
        BaseWallet _wallet, 
        address _dapp, 
        address _contract, 
        bytes4[] _signatures, 
        bool _authorized
    ) 
        external 
        onlyModule(_wallet) 
    {
        for(uint i = 0; i < _signatures.length; i++) {
            whitelistedMethods[_wallet][_dapp][_contract][_signatures[i]] = _authorized;
        }
    }

    /**
     * @dev Gets the authorization status for an external contract's method.
     * @param _wallet The wallet.
     * @param _dapp The address of the signing key.
     * @param _contract The contract address.
     * @param _signature The call signature.
     * @return true if the method is whitelisted, false otherwise
     */
    function getMethodAuthorization(BaseWallet _wallet, address _dapp, address _contract, bytes4 _signature) external view returns (bool) {
        return whitelistedMethods[_wallet][_dapp][_contract][_signature];
    }
}

/**
 * @title BaseWallet
 * @dev Simple modular wallet that authorises modules to call its invoke() method.
 * Based on https://gist.github.com/Arachnid/a619d31f6d32757a4328a428286da186 by 
 * @author Julien Niset - <julien@argent.xyz>
 */
contract BaseWallet {

    // The implementation of the proxy
    address public implementation;
    // The owner 
    address public owner;
    // The authorised modules
    mapping (address => bool) public authorised;
    // The enabled static calls
    mapping (bytes4 => address) public enabled;
    // The number of modules
    uint public modules;
    
    event AuthorisedModule(address indexed module, bool value);
    event EnabledStaticCall(address indexed module, bytes4 indexed method);
    event Invoked(address indexed module, address indexed target, uint indexed value, bytes data);
    event Received(uint indexed value, address indexed sender, bytes data);
    event OwnerChanged(address owner);
    
    /**
     * @dev Throws if the sender is not an authorised module.
     */
    modifier moduleOnly {
        require(authorised[msg.sender], "BW: msg.sender not an authorized module");
        _;
    }

    /**
     * @dev Inits the wallet by setting the owner and authorising a list of modules.
     * @param _owner The owner.
     * @param _modules The modules to authorise.
     */
    function init(address _owner, address[] _modules) external {
        require(owner == address(0) && modules == 0, "BW: wallet already initialised");
        require(_modules.length > 0, "BW: construction requires at least 1 module");
        owner = _owner;
        modules = _modules.length;
        for(uint256 i = 0; i < _modules.length; i++) {
            require(authorised[_modules[i]] == false, "BW: module is already added");
            authorised[_modules[i]] = true;
            Module(_modules[i]).init(this);
            emit AuthorisedModule(_modules[i], true);
        }
    }
    
    /**
     * @dev Enables/Disables a module.
     * @param _module The target module.
     * @param _value Set to true to authorise the module.
     */
    function authoriseModule(address _module, bool _value) external moduleOnly {
        if (authorised[_module] != _value) {
            if(_value == true) {
                modules += 1;
                authorised[_module] = true;
                Module(_module).init(this);
            }
            else {
                modules -= 1;
                require(modules > 0, "BW: wallet must have at least one module");
                delete authorised[_module];
            }
            emit AuthorisedModule(_module, _value);
        }
    }

    /**
    * @dev Enables a static method by specifying the target module to which the call
    * must be delegated.
    * @param _module The target module.
    * @param _method The static method signature.
    */
    function enableStaticCall(address _module, bytes4 _method) external moduleOnly {
        require(authorised[_module], "BW: must be an authorised module for static call");
        enabled[_method] = _module;
        emit EnabledStaticCall(_module, _method);
    }

    /**
     * @dev Sets a new owner for the wallet.
     * @param _newOwner The new owner.
     */
    function setOwner(address _newOwner) external moduleOnly {
        require(_newOwner != address(0), "BW: address cannot be null");
        owner = _newOwner;
        emit OwnerChanged(_newOwner);
    }
    
    /**
     * @dev Performs a generic transaction.
     * @param _target The address for the transaction.
     * @param _value The value of the transaction.
     * @param _data The data of the transaction.
     */
    function invoke(address _target, uint _value, bytes _data) external moduleOnly {
        // solium-disable-next-line security/no-call-value
        require(_target.call.value(_value)(_data), "BW: call to target failed");
        emit Invoked(msg.sender, _target, _value, _data);
    }

    /**
     * @dev This method makes it possible for the wallet to comply to interfaces expecting the wallet to
     * implement specific static methods. It delegates the static call to a target contract if the data corresponds 
     * to an enabled method, or logs the call otherwise.
     */
    function() public payable {
        if(msg.data.length > 0) { 
            address module = enabled[msg.sig];
            if(module == address(0)) {
                emit Received(msg.value, msg.sender, msg.data);
            } 
            else {
                require(authorised[module], "BW: must be an authorised module for static call");
                // solium-disable-next-line security/no-inline-assembly
                assembly {
                    calldatacopy(0, 0, calldatasize())
                    let result := staticcall(gas, module, 0, calldatasize(), 0, 0)
                    returndatacopy(0, 0, returndatasize())
                    switch result 
                    case 0 {revert(0, returndatasize())} 
                    default {return (0, returndatasize())}
                }
            }
        }
    }
}

/**
 * @title DappManager
 * @dev Module to enable authorised dapps to transfer tokens (ETH or ERC20) on behalf of a wallet.
 * @author Olivier Van Den Biggelaar - <olivier@argent.im>
 */
contract DappManager is BaseModule, RelayerModule, LimitManager {

    bytes32 constant NAME = "DappManager";

    bytes4 constant internal CONFIRM_AUTHORISATION_PREFIX = bytes4(keccak256("confirmAuthorizeCall(address,address,address,bytes4[])"));
    bytes4 constant internal CALL_CONTRACT_PREFIX = bytes4(keccak256("callContract(address,address,address,uint256,bytes)"));

    // Mock token address for ETH
    address constant internal ETH_TOKEN = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    using SafeMath for uint256;

    // // The Guardian storage 
    GuardianStorage public guardianStorage;
    // The Dapp limit storage
    DappStorage public dappStorage;
    // The authorised dapp registry
    DappRegistry public dappRegistry;
    // The security period
    uint256 public securityPeriod;
    // the security window
    uint256 public securityWindow;

    struct DappManagerConfig {
        // the time at which a dapp authorisation can be confirmed
        mapping (bytes32 => uint256) pending;
    }

    // the wallet specific storage
    mapping (address => DappManagerConfig) internal configs;

    // *************** Events *************************** //
  
    event Transfer(address indexed wallet, address indexed token, uint256 indexed amount, address to, bytes data);    
    event ContractCallAuthorizationRequested(address indexed _wallet, address indexed _dapp, address indexed _contract, bytes4[] _signatures);
    event ContractCallAuthorizationCanceled(address indexed _wallet, address indexed _dapp, address indexed _contract, bytes4[] _signatures);
    event ContractCallAuthorized(address indexed _wallet, address indexed _dapp, address indexed _contract, bytes4[] _signatures);
    event ContractCallDeauthorized(address indexed _wallet, address indexed _dapp, address indexed _contract, bytes4[] _signatures);

    // *************** Modifiers *************************** //

    /**
     * @dev Throws unless called by this contract or by _dapp.
     */
    modifier onlyExecuteOrDapp(address _dapp) {
        require(msg.sender == address(this) || msg.sender == _dapp, "DM: must be called by dapp or via execute()");
        _;
    }

    /**
     * @dev Throws if the wallet is locked.
     */
    modifier onlyWhenUnlocked(BaseWallet _wallet) {
        // solium-disable-next-line security/no-block-members
        require(!guardianStorage.isLocked(_wallet), "DM: wallet must be unlocked");
        _;
    }

    // *************** Constructor ********************** //

    constructor(
        ModuleRegistry _registry,
        DappRegistry _dappRegistry,
        DappStorage _dappStorage, 
        GuardianStorage _guardianStorage,
        uint256 _securityPeriod,
        uint256 _securityWindow,
        uint256 _defaultLimit
    ) 
        BaseModule(_registry, NAME)
        LimitManager(_defaultLimit)
        public 
    {
        dappStorage = _dappStorage;
        guardianStorage = _guardianStorage;
        dappRegistry = _dappRegistry;
        securityPeriod = _securityPeriod;
        securityWindow = _securityWindow;
    }

    // *************** External/Public Functions ********************* //

    /**
    * @dev lets a dapp call an arbitrary contract from a wallet.
    * @param _wallet The target wallet.
    * @param _dapp The authorised dapp.
    * @param _to The destination address
    * @param _amount The amoun6 of ether to transfer
    * @param _data The data for the transaction
    */
    function callContract(
        BaseWallet _wallet,
        address _dapp,
        address _to, 
        uint256 _amount, 
        bytes _data
    ) 
        external 
        onlyExecuteOrDapp(_dapp)
        onlyWhenUnlocked(_wallet)
    {
        require(isAuthorizedCall(_wallet, _dapp, _to, _data), "DM: Contract call not authorized");
        require(checkAndUpdateDailySpent(_wallet, _amount), "DM: Dapp limit exceeded");
        doCall(_wallet, _to, _amount, _data);
    }

    /**
     * @dev Authorizes an external contract's methods to be called by a dapp key of the wallet.
     * @param _wallet The wallet.
     * @param _dapp The address of the signing key.
     * @param _contract The target contract address.
     * @param _signatures The method signatures.
     */
    function authorizeCall(
        BaseWallet _wallet, 
        address _dapp,
        address _contract,
        bytes4[] _signatures
    ) 
        external 
        onlyOwner(_wallet) 
        onlyWhenUnlocked(_wallet)
    {
        require(_contract != address(0), "DM: Contract address cannot be null");
        if(dappRegistry.isRegistered(_contract, _signatures)) {
            // authorise immediately
            dappStorage.setMethodAuthorization(_wallet, _dapp, _contract, _signatures, true);
            emit ContractCallAuthorized(_wallet, _dapp, _contract, _signatures);
        }
        else {
            bytes32 id = keccak256(abi.encodePacked(address(_wallet), _dapp, _contract, _signatures, true));
            configs[_wallet].pending[id] = now + securityPeriod;
            emit ContractCallAuthorizationRequested(_wallet, _dapp, _contract, _signatures);
        }
    }

    /**
     * @dev Deauthorizes an external contract's methods to be called by a dapp key of the wallet.
     * @param _wallet The wallet.
     * @param _dapp The address of the signing key.
     * @param _contract The target contract address.
     * @param _signatures The method signatures.
     */
    function deauthorizeCall(
        BaseWallet _wallet, 
        address _dapp,
        address _contract,
        bytes4[] _signatures
    ) 
        external 
        onlyOwner(_wallet) 
        onlyWhenUnlocked(_wallet)
    {
        dappStorage.setMethodAuthorization(_wallet, _dapp, _contract, _signatures, false);
        emit ContractCallDeauthorized(_wallet, _dapp, _contract, _signatures);
    }

    /**
     * @dev Confirms the authorisation of an external contract's methods to be called by a dapp key of the wallet.
     * @param _wallet The wallet.
     * @param _dapp The address of the signing key.
     * @param _contract The target contract address.
     * @param _signatures The method signatures.
     */
    function confirmAuthorizeCall(
        BaseWallet _wallet, 
        address _dapp,
        address _contract,
        bytes4[] _signatures
    ) 
        external 
        onlyWhenUnlocked(_wallet)
    {
        bytes32 id = keccak256(abi.encodePacked(address(_wallet), _dapp, _contract, _signatures, true));
        DappManagerConfig storage config = configs[_wallet];
        require(config.pending[id] > 0, "DM: No pending authorisation for the target dapp");
        require(config.pending[id] < now, "DM: Too early to confirm pending authorisation");
        require(now < config.pending[id] + securityWindow, "GM: Too late to confirm pending authorisation");
        dappStorage.setMethodAuthorization(_wallet, _dapp, _contract, _signatures, true);
        delete config.pending[id];
        emit ContractCallAuthorized(_wallet, _dapp, _contract, _signatures);
    }

    /**
     * @dev Cancels an authorisation request for an external contract's methods to be called by a dapp key of the wallet.
     * @param _wallet The wallet.
     * @param _dapp The address of the signing key.
     * @param _contract The target contract address.
     * @param _signatures The method signatures.
     */
    function cancelAuthorizeCall(
        BaseWallet _wallet, 
        address _dapp,
        address _contract,
        bytes4[] _signatures
    )
        public 
        onlyOwner(_wallet) 
        onlyWhenUnlocked(_wallet) 
    {
        bytes32 id = keccak256(abi.encodePacked(address(_wallet), _dapp, _contract, _signatures, true));
        DappManagerConfig storage config = configs[_wallet];
        require(config.pending[id] > 0, "DM: No pending authorisation for the target dapp");
        delete config.pending[id];
        emit ContractCallAuthorizationCanceled(_wallet, _dapp, _contract, _signatures);
    }

    /**
    * @dev Checks if a contract call is authorized for a given signing key.
    * @param _wallet The target wallet.
    * @param _dapp The address of the signing key.
    * @param _to The address of the contract to call
    * @param _data The call data
    * @return true if the contract call is authorised for the wallet.
    */
    function isAuthorizedCall(BaseWallet _wallet, address _dapp, address _to, bytes _data) public view returns (bool _isAuthorized) {
        if(_data.length >= 4) {
            return dappStorage.getMethodAuthorization(_wallet, _dapp, _to, functionPrefix(_data));
        }
        // the fallback method must be authorized
        return dappStorage.getMethodAuthorization(_wallet, _dapp, _to, "");
    }

    /**
     * @dev Lets the owner of a wallet change its dapp limit. 
     * The limit is expressed in ETH. Changes to the limit take 24 hours.
     * @param _wallet The target wallet.
     * @param _newLimit The new limit.
     */
    function changeLimit(BaseWallet _wallet, uint256 _newLimit) public onlyOwner(_wallet) onlyWhenUnlocked(_wallet) {
        changeLimit(_wallet, _newLimit, securityPeriod);
    }

    /**
     * @dev Convenience method to disable the limit
     * The limit is disabled by setting it to an arbitrary large value.
     * @param _wallet The target wallet.
     */
    function disableLimit(BaseWallet _wallet) external onlyOwner(_wallet) onlyWhenUnlocked(_wallet) {
        changeLimit(_wallet, LIMIT_DISABLED, securityPeriod);
    }

    /**
    * @dev Internal method to instruct a wallet to call an extrenal contract.
    * @param _wallet The target wallet.
    * @param _to The external contract.
    * @param _value The amount of ETH for the call
    * @param _data The data of the call.
    */

    function doCall(BaseWallet _wallet, address _to, uint256 _value, bytes _data) internal {
        _wallet.invoke(_to, _value, _data);
        emit Transfer(_wallet, ETH_TOKEN, _value, _to, _data);
    }

    // *************** Implementation of RelayerModule methods ********************* //

    // Overrides refund to add the refund in the daily limit.
    function refund(BaseWallet _wallet, uint _gasUsed, uint _gasPrice, uint _gasLimit, uint _signatures, address _relayer) internal {
        // 21000 (transaction) + 7620 (execution of refund) + 7324 (execution of updateDailySpent) + 672 to log the event + _gasUsed
        uint256 amount = 36616 + _gasUsed; 
        if(_gasPrice > 0 && _signatures > 0 && amount <= _gasLimit) {
            if(_gasPrice > tx.gasprice) {
                amount = amount * tx.gasprice;
            }
            else {
                amount = amount * _gasPrice;
            }
            updateDailySpent(_wallet, uint128(getCurrentLimit(_wallet)), amount);
            _wallet.invoke(_relayer, amount, "");
        }
    }

    // Overrides verifyRefund to add the refund in the daily limit.
    function verifyRefund(BaseWallet _wallet, uint _gasUsed, uint _gasPrice, uint _signatures) internal view returns (bool) {
        if(_gasPrice > 0 && _signatures > 0 && (
                address(_wallet).balance < _gasUsed * _gasPrice 
                || isWithinDailyLimit(_wallet, getCurrentLimit(_wallet), _gasUsed * _gasPrice) == false
                || _wallet.authorised(this) == false
        ))
        {
            return false;
        }
        return true;
    }

    // Overrides to use the incremental nonce and save some gas
    function checkAndUpdateUniqueness(BaseWallet _wallet, uint256 _nonce, bytes32 _signHash) internal returns (bool) {
        return checkAndUpdateNonce(_wallet, _nonce);
    }

    function validateSignatures(BaseWallet _wallet, bytes _data, bytes32 _signHash, bytes _signatures) internal view returns (bool) {
        address signer = recoverSigner(_signHash, _signatures, 0);
        if(functionPrefix(_data) == CALL_CONTRACT_PREFIX) {
            // "RM: Invalid dapp in data"
            if(_data.length < 68) {
                return false;
            }
            address dapp;
            // solium-disable-next-line security/no-inline-assembly
            assembly {
                //_data = {length:32}{sig:4}{_wallet:32}{_dapp:32}{...}
                dapp := mload(add(_data, 0x44))
            }
            return dapp == signer; // "DM: dapp and signer must be the same"
        } else {
            return isOwner(_wallet, signer); // "DM: signer must be owner"
        }
    }

    function getRequiredSignatures(BaseWallet _wallet, bytes _data) internal view returns (uint256) {
        bytes4 methodId = functionPrefix(_data);
        if (methodId == CONFIRM_AUTHORISATION_PREFIX) {
            return 0;
        }
        return 1;
    }
}