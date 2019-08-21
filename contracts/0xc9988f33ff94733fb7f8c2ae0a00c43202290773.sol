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

interface SM {

    function isValidSubscription(
        bytes32 subscriptionHash,
        bytes calldata signatures
    ) external view returns (bool);

    function execSubscription (
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 dataGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes calldata meta,
        bytes calldata signatures) external returns (bool);

    function cancelSubscriptionAsRecipient(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 dataGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes calldata meta,
        bytes calldata signatures) external returns (bool);
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


/// @title SecuredTokenTransfer - Secure token transfer
/// @author Richard Meissner - <richard@gnosis.pm>
contract SecuredTokenTransfer {

    /// @dev Transfers a token and returns if it was a success
    /// @param token Token that should be transferred
    /// @param receiver Receiver to whom the token should be transferred
    /// @param amount The amount of tokens that should be transferred
    function transferToken (
        address token, 
        address receiver,
        uint256 amount
    )
        internal
        returns (bool transferred)
    {
        bytes memory data = abi.encodeWithSignature("transfer(address,uint256)", receiver, amount);
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let success := call(sub(gas, 10000), token, 0, add(data, 0x20), mload(data), 0, 0)
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, returndatasize)
            switch returndatasize 
            case 0 { transferred := success }
            case 0x20 { transferred := iszero(or(iszero(success), iszero(mload(ptr)))) }
            default { transferred := 0 }
        }
    }
}

interface ERC20 {
    function totalSupply() external view returns (uint256 supply);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value) external returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    function approve(address _spender, uint256 _value) external returns (bool success);

    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    function decimals() external view returns (uint256 digits);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract MerchantModule is Module, SecuredTokenTransfer {

    using DSMath for uint256;

    OracleRegistry public oracleRegistry;

    event IncomingPayment(uint256 payment);
    event PaymentSent(address asset, address receiver, uint256 payment);


    function setup(address _oracleRegistry)
    public
    {
        setManager();
        require(
            address(oracleRegistry) == address(0),
            "MerchantModule::setup: INVALID_STATE: ORACLE_REGISTRY_SET"
        );
        oracleRegistry = OracleRegistry(_oracleRegistry);
    }

    function()
    payable
    external
    {
        emit IncomingPayment(msg.value);
    }

    function split(
        address tokenAddress
    )
    public
    returns (bool)
    {
        require(
            msg.sender == oracleRegistry.getNetworkExecutor(),
            "MerchantModule::split: INVALID_DATA: MSG_SENDER_NOT_EXECUTOR"
        );

        address payable networkWallet = oracleRegistry.getNetworkWallet();
        address payable merchantWallet = address(manager);

        if (tokenAddress == address(0)) {

            uint256 splitterBalanceStart = address(this).balance;
            if (splitterBalanceStart == 0) return false;
            //
            uint256 fee = oracleRegistry.getNetworkFee(address(0));


            uint256 networkBalanceStart = networkWallet.balance;

            uint256 merchantBalanceStart = merchantWallet.balance;


            uint256 networkSplit = splitterBalanceStart.wmul(fee);

            uint256 merchantSplit = splitterBalanceStart.sub(networkSplit);


            require(merchantSplit > networkSplit, "Split Math is Wrong");
            //pay network

            networkWallet.transfer(networkSplit);
            emit PaymentSent(address(0x0), networkWallet, networkSplit);
            //pay merchant

            merchantWallet.transfer(merchantSplit);
            emit PaymentSent(address(0x0), merchantWallet, merchantSplit);

            require(
                (networkBalanceStart.add(networkSplit) == networkWallet.balance)
                &&
                (merchantBalanceStart.add(merchantSplit) == merchantWallet.balance),
                "MerchantModule::withdraw: INVALID_EXEC SPLIT_PAYOUT"
            );
        } else {

            ERC20 token = ERC20(tokenAddress);

            uint256 splitterBalanceStart = token.balanceOf(address(this));


            if (splitterBalanceStart == 0) return false;

            uint256 fee = oracleRegistry.getNetworkFee(address(token));


            uint256 merchantBalanceStart = token.balanceOf(merchantWallet);


            uint256 networkSplit = splitterBalanceStart.wmul(fee);


            uint256 merchantSplit = splitterBalanceStart.sub(networkSplit);


            require(
                networkSplit.add(merchantSplit) == splitterBalanceStart,
                "MerchantModule::withdraw: INVALID_EXEC TOKEN_SPLIT"
            );

            //pay network

            require(
                transferToken(address(token), networkWallet, networkSplit),
                "MerchantModule::withdraw: INVALID_EXEC TOKEN_NETWORK_PAYOUT"
            );

            emit PaymentSent(address(token), networkWallet, networkSplit);

            //pay merchant
            require(
                transferToken(address(token), merchantWallet, merchantSplit),
                "MerchantModule::withdraw: INVALID_EXEC TOKEN_MERCHANT_PAYOUT"
            );
            emit PaymentSent(address(token), merchantWallet, merchantSplit);
        }
        return true;
    }


    function cancelCXSubscription(
        address customer,
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
    authorized
    {
        SM(customer).cancelSubscriptionAsRecipient(
            to,
            value,
            data,
            operation,
            safeTxGas,
            dataGas,
            gasPrice,
            gasToken,
            refundReceiver,
            meta,
            signatures
        );
    }

}