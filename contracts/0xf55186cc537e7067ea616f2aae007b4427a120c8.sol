// File: openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol

pragma solidity ^0.5.2;

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {
    /// @dev counter to allow mutex lock with only one SSTORE operation
    uint256 private _guardCounter;

    constructor () internal {
        // The counter starts at one to prevent changing it from zero to a non-zero
        // value, which is a more expensive operation.
        _guardCounter = 1;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter);
    }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.2;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
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
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: contracts/lib/CommonValidationsLibrary.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;


library CommonValidationsLibrary {

    /**
     * Ensures that an address array is not empty.
     *
     * @param  _addressArray       Address array input
     */
    function validateNonEmpty(
        address[] calldata _addressArray
    )
        external
        pure
    {
        require(
            _addressArray.length > 0,
            "Address array length must be > 0"
        );
    }

    /**
     * Ensures that an address array and uint256 array are equal length
     *
     * @param  _addressArray       Address array input
     * @param  _uint256Array       Uint256 array input
     */
    function validateEqualLength(
        address[] calldata _addressArray,
        uint256[] calldata _uint256Array
    )
        external
        pure
    {
        require(
            _addressArray.length == _uint256Array.length,
            "Input length mismatch"
        );
    }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.2;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/core/interfaces/ITransferProxy.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;

/**
 * @title ITransferProxy
 * @author Set Protocol
 *
 * The ITransferProxy interface provides a light-weight, structured way to interact with the
 * TransferProxy contract from another contract.
 */
interface ITransferProxy {

    /* ============ External Functions ============ */

    /**
     * Transfers tokens from an address (that has set allowance on the proxy).
     * Can only be called by authorized core contracts.
     *
     * @param  _token          The address of the ERC20 token
     * @param  _quantity       The number of tokens to transfer
     * @param  _from           The address to transfer from
     * @param  _to             The address to transfer to
     */
    function transfer(
        address _token,
        uint256 _quantity,
        address _from,
        address _to
    )
        external;

    /**
     * Transfers tokens from an address (that has set allowance on the proxy).
     * Can only be called by authorized core contracts.
     *
     * @param  _tokens         The addresses of the ERC20 token
     * @param  _quantities     The numbers of tokens to transfer
     * @param  _from           The address to transfer from
     * @param  _to             The address to transfer to
     */
    function batchTransfer(
        address[] calldata _tokens,
        uint256[] calldata _quantities,
        address _from,
        address _to
    )
        external;
}

// File: contracts/core/interfaces/IVault.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;

/**
 * @title IVault
 * @author Set Protocol
 *
 * The IVault interface provides a light-weight, structured way to interact with the Vault
 * contract from another contract.
 */
interface IVault {

    /*
     * Withdraws user's unassociated tokens to user account. Can only be
     * called by authorized core contracts.
     *
     * @param  _token          The address of the ERC20 token
     * @param  _to             The address to transfer token to
     * @param  _quantity       The number of tokens to transfer
     */
    function withdrawTo(
        address _token,
        address _to,
        uint256 _quantity
    )
        external;

    /*
     * Increment quantity owned of a token for a given address. Can
     * only be called by authorized core contracts.
     *
     * @param  _token           The address of the ERC20 token
     * @param  _owner           The address of the token owner
     * @param  _quantity        The number of tokens to attribute to owner
     */
    function incrementTokenOwner(
        address _token,
        address _owner,
        uint256 _quantity
    )
        external;

    /*
     * Decrement quantity owned of a token for a given address. Can only
     * be called by authorized core contracts.
     *
     * @param  _token           The address of the ERC20 token
     * @param  _owner           The address of the token owner
     * @param  _quantity        The number of tokens to deattribute to owner
     */
    function decrementTokenOwner(
        address _token,
        address _owner,
        uint256 _quantity
    )
        external;

    /**
     * Transfers tokens associated with one account to another account in the vault
     *
     * @param  _token          Address of token being transferred
     * @param  _from           Address token being transferred from
     * @param  _to             Address token being transferred to
     * @param  _quantity       Amount of tokens being transferred
     */

    function transferBalance(
        address _token,
        address _from,
        address _to,
        uint256 _quantity
    )
        external;


    /*
     * Withdraws user's unassociated tokens to user account. Can only be
     * called by authorized core contracts.
     *
     * @param  _tokens          The addresses of the ERC20 tokens
     * @param  _owner           The address of the token owner
     * @param  _quantities      The numbers of tokens to attribute to owner
     */
    function batchWithdrawTo(
        address[] calldata _tokens,
        address _to,
        uint256[] calldata _quantities
    )
        external;

    /*
     * Increment quantites owned of a collection of tokens for a given address. Can
     * only be called by authorized core contracts.
     *
     * @param  _tokens          The addresses of the ERC20 tokens
     * @param  _owner           The address of the token owner
     * @param  _quantities      The numbers of tokens to attribute to owner
     */
    function batchIncrementTokenOwner(
        address[] calldata _tokens,
        address _owner,
        uint256[] calldata _quantities
    )
        external;

    /*
     * Decrements quantites owned of a collection of tokens for a given address. Can
     * only be called by authorized core contracts.
     *
     * @param  _tokens          The addresses of the ERC20 tokens
     * @param  _owner           The address of the token owner
     * @param  _quantities      The numbers of tokens to attribute to owner
     */
    function batchDecrementTokenOwner(
        address[] calldata _tokens,
        address _owner,
        uint256[] calldata _quantities
    )
        external;

   /**
     * Transfers tokens associated with one account to another account in the vault
     *
     * @param  _tokens           Addresses of tokens being transferred
     * @param  _from             Address tokens being transferred from
     * @param  _to               Address tokens being transferred to
     * @param  _quantities       Amounts of tokens being transferred
     */
    function batchTransferBalance(
        address[] calldata _tokens,
        address _from,
        address _to,
        uint256[] calldata _quantities
    )
        external;

    /*
     * Get balance of particular contract for owner.
     *
     * @param  _token    The address of the ERC20 token
     * @param  _owner    The address of the token owner
     */
    function getOwnerBalance(
        address _token,
        address _owner
    )
        external
        view
        returns (uint256);
}

// File: contracts/core/lib/CoreState.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;




/**
 * @title CoreState
 * @author Set Protocol
 *
 * The CoreState library maintains all state for the Core contract thus
 * allowing it to operate across multiple mixins.
 */
contract CoreState {

    /* ============ Structs ============ */

    struct State {
        // Protocol state of operation
        uint8 operationState;

        // Address of the TransferProxy contract
        address transferProxy;

        // Address of the Vault contract
        address vault;

        // Instance of transferProxy contract
        ITransferProxy transferProxyInstance;

        // Instance of Vault Contract
        IVault vaultInstance;

        // Mapping of exchange enumeration to address
        mapping(uint8 => address) exchangeIds;

        // Mapping of approved modules
        mapping(address => bool) validModules;

        // Mapping of tracked SetToken factories
        mapping(address => bool) validFactories;

        // Mapping of tracked rebalancing price libraries
        mapping(address => bool) validPriceLibraries;

        // Mapping of tracked SetTokens
        mapping(address => bool) validSets;

        // Mapping of tracked disabled SetTokens
        mapping(address => bool) disabledSets;

        // Array of tracked SetTokens
        address[] setTokens;

        // Array of tracked modules
        address[] modules;

        // Array of tracked factories
        address[] factories;

        // Array of tracked exchange wrappers
        address[] exchanges;

        // Array of tracked auction price libraries
        address[] priceLibraries;
    }

    /* ============ State Variables ============ */

    State public state;

    /* ============ Public Getters ============ */

    /**
     * Return uint8 representing the operational state of the protocol
     *
     * @return uint8           Uint8 representing the operational state of the protocol
     */
    function operationState()
        external
        view
        returns (uint8)
    {
        return state.operationState;
    }

    /**
     * Return address belonging to given exchangeId.
     *
     * @param  _exchangeId       ExchangeId number
     * @return address           Address belonging to given exchangeId
     */
    function exchangeIds(
        uint8 _exchangeId
    )
        external
        view
        returns (address)
    {
        return state.exchangeIds[_exchangeId];
    }

    /**
     * Return transferProxy address.
     *
     * @return address       transferProxy address
     */
    function transferProxy()
        external
        view
        returns (address)
    {
        return state.transferProxy;
    }

    /**
     * Return vault address
     *
     * @return address        vault address
     */
    function vault()
        external
        view
        returns (address)
    {
        return state.vault;
    }

    /**
     * Return boolean indicating if address is valid factory.
     *
     * @param  _factory       Factory address
     * @return bool           Boolean indicating if enabled factory
     */
    function validFactories(
        address _factory
    )
        external
        view
        returns (bool)
    {
        return state.validFactories[_factory];
    }

    /**
     * Return boolean indicating if address is valid module.
     *
     * @param  _module        Factory address
     * @return bool           Boolean indicating if enabled factory
     */
    function validModules(
        address _module
    )
        external
        view
        returns (bool)
    {
        return state.validModules[_module];
    }

    /**
     * Return boolean indicating if address is valid Set.
     *
     * @param  _set           Set address
     * @return bool           Boolean indicating if valid Set
     */
    function validSets(
        address _set
    )
        external
        view
        returns (bool)
    {
        return state.validSets[_set];
    }

    /**
     * Return boolean indicating if address is a disabled Set.
     *
     * @param  _set           Set address
     * @return bool           Boolean indicating if is a disabled Set
     */
    function disabledSets(
        address _set
    )
        external
        view
        returns (bool)
    {
        return state.disabledSets[_set];
    }

    /**
     * Return boolean indicating if address is a valid Rebalancing Price Library.
     *
     * @param  _priceLibrary    Price library address
     * @return bool             Boolean indicating if valid Price Library
     */
    function validPriceLibraries(
        address _priceLibrary
    )
        external
        view
        returns (bool)
    {
        return state.validPriceLibraries[_priceLibrary];
    }

    /**
     * Return array of all valid Set Tokens.
     *
     * @return address[]      Array of valid Set Tokens
     */
    function setTokens()
        external
        view
        returns (address[] memory)
    {
        return state.setTokens;
    }

    /**
     * Return array of all valid Modules.
     *
     * @return address[]      Array of valid modules
     */
    function modules()
        external
        view
        returns (address[] memory)
    {
        return state.modules;
    }

    /**
     * Return array of all valid factories.
     *
     * @return address[]      Array of valid factories
     */
    function factories()
        external
        view
        returns (address[] memory)
    {
        return state.factories;
    }

    /**
     * Return array of all valid exchange wrappers.
     *
     * @return address[]      Array of valid exchange wrappers
     */
    function exchanges()
        external
        view
        returns (address[] memory)
    {
        return state.exchanges;
    }

    /**
     * Return array of all valid price libraries.
     *
     * @return address[]      Array of valid price libraries
     */
    function priceLibraries()
        external
        view
        returns (address[] memory)
    {
        return state.priceLibraries;
    }
}

// File: contracts/core/extensions/CoreOperationState.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;




/**
 * @title CoreOperationState
 * @author Set Protocol
 *
 * The CoreOperationState contract contains methods to alter state of variables that track
 * Core dependency addresses.
 */
contract CoreOperationState is
    Ownable,
    CoreState
{

    /* ============ Enum ============ */

    /**
     * Operational:
     * All Accounting and Issuance related functions are available for usage during this stage
     *
     * Shut Down:
     * Only functions which allow users to redeem and withdraw funds are allowed during this stage
     */
    enum OperationState {
        Operational,
        ShutDown,
        InvalidState
    }

    /* ============ Events ============ */

    event OperationStateChanged(
        uint8 _prevState,
        uint8 _newState
    );

    /* ============ Modifiers ============ */

    modifier whenOperational() {
        require(
            state.operationState == uint8(OperationState.Operational),
            "WhenOperational"
        );
        _;
    }

    /* ============ External Functions ============ */

    /**
     * Updates the operation state of the protocol.
     * Can only be called by owner of Core.
     *
     * @param  _operationState   Uint8 representing the current protocol operation state
     */
    function setOperationState(
        uint8 _operationState
    )
        external
        onlyOwner
    {
        require(
            _operationState < uint8(OperationState.InvalidState) &&
            _operationState != state.operationState,
            "InvalidOperationState"
        );

        emit OperationStateChanged(
            state.operationState,
            _operationState
        );

        state.operationState = _operationState;
    }
}

// File: contracts/core/extensions/CoreAccounting.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;







/**
 * @title CoreAccounting
 * @author Set Protocol
 *
 * The CoreAccounting contract interfaces with the vault and transfer proxies for
 * storage of tokenized assets.
 */
contract CoreAccounting is
    CoreState,
    CoreOperationState,
    ReentrancyGuard
{
    // Use SafeMath library for all uint256 arithmetic
    using SafeMath for uint256;

    /* ============ External Functions ============ */

    /**
     * Deposit a quantity of tokens to the vault and attribute to sender.
     *
     * @param  _token           Address of the token
     * @param  _quantity        Amount of tokens to deposit
     */
    function deposit(
        address _token,
        uint256 _quantity
    )
        external
        nonReentrant
        whenOperational
    {
        // Don't deposit if quantity <= 0
        if (_quantity > 0) {
            // Call TransferProxy contract to transfer user tokens to Vault
            state.transferProxyInstance.transfer(
                _token,
                _quantity,
                msg.sender,
                state.vault
            );

            // Call Vault contract to attribute deposited tokens to user
            state.vaultInstance.incrementTokenOwner(
                _token,
                msg.sender,
                _quantity
            );
        }
    }

    /**
     * Withdraw a quantity of tokens from the vault and deattribute from sender.
     *
     * @param  _token           Address of the token
     * @param  _quantity        Amount of tokens to withdraw
     */
    function withdraw(
        address _token,
        uint256 _quantity
    )
        external
        nonReentrant
    {
        // Don't withdraw if quantity <= 0
        if (_quantity > 0) {
            // Call Vault contract to deattribute withdrawn tokens from user
            state.vaultInstance.decrementTokenOwner(
                _token,
                msg.sender,
                _quantity
            );

            // Call Vault contract to withdraw tokens from Vault to user
            state.vaultInstance.withdrawTo(
                _token,
                msg.sender,
                _quantity
            );
        }
    }

    /**
     * Deposit multiple tokens to the vault and attribute to sender.
     * Quantities should be in the order of the addresses of the tokens being deposited.
     *
     * @param  _tokens            Array of the addresses of the tokens
     * @param  _quantities        Array of the amounts of tokens to deposit
     */
    function batchDeposit(
        address[] calldata _tokens,
        uint256[] calldata _quantities
    )
        external
        nonReentrant
        whenOperational
    {
        // Call internal batch deposit function
        batchDepositInternal(
            msg.sender,
            msg.sender,
            _tokens,
            _quantities
        );
    }

    /**
     * Withdraw multiple tokens from the vault and deattribute from sender.
     * Quantities should be in the order of the addresses of the tokens being withdrawn.
     *
     * @param  _tokens            Array of the addresses of the tokens
     * @param  _quantities        Array of the amounts of tokens to withdraw
     */
    function batchWithdraw(
        address[] calldata _tokens,
        uint256[] calldata _quantities
    )
        external
        nonReentrant
    {
        // Call internal batch withdraw function
        batchWithdrawInternal(
            msg.sender,
            msg.sender,
            _tokens,
            _quantities
        );
    }

    /**
     * Transfer tokens associated with the sender's account in vault to another user's
     * account in vault.
     *
     * @param  _token           Address of token being transferred
     * @param  _to              Address of user receiving tokens
     * @param  _quantity        Amount of tokens being transferred
     */
    function internalTransfer(
        address _token,
        address _to,
        uint256 _quantity
    )
        external
        nonReentrant
        whenOperational
    {
        state.vaultInstance.transferBalance(
            _token,
            msg.sender,
            _to,
            _quantity
        );
    }

    /* ============ Internal Functions ============ */

    /**
     * Internal function that deposits multiple tokens to the vault.
     * Quantities should be in the order of the addresses of the tokens being deposited.
     *
     * @param  _from              Address to transfer tokens from
     * @param  _to                Address to credit for deposits
     * @param  _tokens            Array of the addresses of the tokens being deposited
     * @param  _quantities        Array of the amounts of tokens to deposit
     */
    function batchDepositInternal(
        address _from,
        address _to,
        address[] memory _tokens,
        uint256[] memory _quantities
    )
        internal
        whenOperational
    {
        // Confirm an empty _tokens or quantity array is not passed
        CommonValidationsLibrary.validateNonEmpty(_tokens);

        // Confirm there is one quantity for every token address
        CommonValidationsLibrary.validateEqualLength(_tokens, _quantities);

        state.transferProxyInstance.batchTransfer(
            _tokens,
            _quantities,
            _from,
            state.vault
        );

        state.vaultInstance.batchIncrementTokenOwner(
            _tokens,
            _to,
            _quantities
        );
    }

    /**
     * Internal function that withdraws multiple tokens from the vault.
     * Quantities should be in the order of the addresses of the tokens being withdrawn.
     *
     * @param  _from              Address to decredit for withdrawals
     * @param  _to                Address to transfer tokens to
     * @param  _tokens            Array of the addresses of the tokens being withdrawn
     * @param  _quantities        Array of the amounts of tokens to withdraw
     */
    function batchWithdrawInternal(
        address _from,
        address _to,
        address[] memory _tokens,
        uint256[] memory _quantities
    )
        internal
    {
        // Confirm an empty _tokens or quantity array is not passed
        CommonValidationsLibrary.validateNonEmpty(_tokens);

        // Confirm there is one quantity for every token address
        CommonValidationsLibrary.validateEqualLength(_tokens, _quantities);

        // Call Vault contract to deattribute withdrawn tokens from user
        state.vaultInstance.batchDecrementTokenOwner(
            _tokens,
            _from,
            _quantities
        );

        // Call Vault contract to withdraw tokens from Vault to user
        state.vaultInstance.batchWithdrawTo(
            _tokens,
            _to,
            _quantities
        );
    }
}

// File: contracts/lib/AddressArrayUtils.sol

// Pulled in from Cryptofin Solidity package in order to control Solidity compiler version
// https://github.com/cryptofinlabs/cryptofin-solidity/blob/master/contracts/array-utils/AddressArrayUtils.sol

pragma solidity 0.5.7;


library AddressArrayUtils {

    /**
     * Finds the index of the first occurrence of the given element.
     * @param A The input array to search
     * @param a The value to find
     * @return Returns (index and isIn) for the first occurrence starting from index 0
     */
    function indexOf(address[] memory A, address a) internal pure returns (uint256, bool) {
        uint256 length = A.length;
        for (uint256 i = 0; i < length; i++) {
            if (A[i] == a) {
                return (i, true);
            }
        }
        return (0, false);
    }

    /**
    * Returns true if the value is present in the list. Uses indexOf internally.
    * @param A The input array to search
    * @param a The value to find
    * @return Returns isIn for the first occurrence starting from index 0
    */
    function contains(address[] memory A, address a) internal pure returns (bool) {
        bool isIn;
        (, isIn) = indexOf(A, a);
        return isIn;
    }

    /// @return Returns index and isIn for the first occurrence starting from
    /// end
    function indexOfFromEnd(address[] memory A, address a) internal pure returns (uint256, bool) {
        uint256 length = A.length;
        for (uint256 i = length; i > 0; i--) {
            if (A[i - 1] == a) {
                return (i, true);
            }
        }
        return (0, false);
    }

    /**
     * Returns the combination of the two arrays
     * @param A The first array
     * @param B The second array
     * @return Returns A extended by B
     */
    function extend(address[] memory A, address[] memory B) internal pure returns (address[] memory) {
        uint256 aLength = A.length;
        uint256 bLength = B.length;
        address[] memory newAddresses = new address[](aLength + bLength);
        for (uint256 i = 0; i < aLength; i++) {
            newAddresses[i] = A[i];
        }
        for (uint256 j = 0; j < bLength; j++) {
            newAddresses[aLength + j] = B[j];
        }
        return newAddresses;
    }

    /**
     * Returns the array with a appended to A.
     * @param A The first array
     * @param a The value to append
     * @return Returns A appended by a
     */
    function append(address[] memory A, address a) internal pure returns (address[] memory) {
        address[] memory newAddresses = new address[](A.length + 1);
        for (uint256 i = 0; i < A.length; i++) {
            newAddresses[i] = A[i];
        }
        newAddresses[A.length] = a;
        return newAddresses;
    }

    /**
     * Returns the combination of two storage arrays.
     * @param A The first array
     * @param B The second array
     * @return Returns A appended by a
     */
    function sExtend(address[] storage A, address[] storage B) internal {
        uint256 length = B.length;
        for (uint256 i = 0; i < length; i++) {
            A.push(B[i]);
        }
    }

    /**
     * Returns the intersection of two arrays. Arrays are treated as collections, so duplicates are kept.
     * @param A The first array
     * @param B The second array
     * @return The intersection of the two arrays
     */
    function intersect(address[] memory A, address[] memory B) internal pure returns (address[] memory) {
        uint256 length = A.length;
        bool[] memory includeMap = new bool[](length);
        uint256 newLength = 0;
        for (uint256 i = 0; i < length; i++) {
            if (contains(B, A[i])) {
                includeMap[i] = true;
                newLength++;
            }
        }
        address[] memory newAddresses = new address[](newLength);
        uint256 j = 0;
        for (uint256 k = 0; k < length; k++) {
            if (includeMap[k]) {
                newAddresses[j] = A[k];
                j++;
            }
        }
        return newAddresses;
    }

    /**
     * Returns the union of the two arrays. Order is not guaranteed.
     * @param A The first array
     * @param B The second array
     * @return The union of the two arrays
     */
    function union(address[] memory A, address[] memory B) internal pure returns (address[] memory) {
        address[] memory leftDifference = difference(A, B);
        address[] memory rightDifference = difference(B, A);
        address[] memory intersection = intersect(A, B);
        return extend(leftDifference, extend(intersection, rightDifference));
    }

    /**
     * Alternate implementation
     * Assumes there are no duplicates
     */
    function unionB(address[] memory A, address[] memory B) internal pure returns (address[] memory) {
        bool[] memory includeMap = new bool[](A.length + B.length);
        uint256 count = 0;
        for (uint256 i = 0; i < A.length; i++) {
            includeMap[i] = true;
            count++;
        }
        for (uint256 j = 0; j < B.length; j++) {
            if (!contains(A, B[j])) {
                includeMap[A.length + j] = true;
                count++;
            }
        }
        address[] memory newAddresses = new address[](count);
        uint256 k = 0;
        for (uint256 m = 0; m < A.length; m++) {
            if (includeMap[m]) {
                newAddresses[k] = A[m];
                k++;
            }
        }
        for (uint256 n = 0; n < B.length; n++) {
            if (includeMap[A.length + n]) {
                newAddresses[k] = B[n];
                k++;
            }
        }
        return newAddresses;
    }

    /**
     * Computes the difference of two arrays. Assumes there are no duplicates.
     * @param A The first array
     * @param B The second array
     * @return The difference of the two arrays
     */
    function difference(address[] memory A, address[] memory B) internal pure returns (address[] memory) {
        uint256 length = A.length;
        bool[] memory includeMap = new bool[](length);
        uint256 count = 0;
        // First count the new length because can't push for in-memory arrays
        for (uint256 i = 0; i < length; i++) {
            address e = A[i];
            if (!contains(B, e)) {
                includeMap[i] = true;
                count++;
            }
        }
        address[] memory newAddresses = new address[](count);
        uint256 j = 0;
        for (uint256 k = 0; k < length; k++) {
            if (includeMap[k]) {
                newAddresses[j] = A[k];
                j++;
            }
        }
        return newAddresses;
    }

    /**
    * @dev Reverses storage array in place
    */
    function sReverse(address[] storage A) internal {
        address t;
        uint256 length = A.length;
        for (uint256 i = 0; i < length / 2; i++) {
            t = A[i];
            A[i] = A[A.length - i - 1];
            A[A.length - i - 1] = t;
        }
    }

    /**
    * Removes specified index from array
    * Resulting ordering is not guaranteed
    * @return Returns the new array and the removed entry
    */
    function pop(address[] memory A, uint256 index)
        internal
        pure
        returns (address[] memory, address)
    {
        uint256 length = A.length;
        address[] memory newAddresses = new address[](length - 1);
        for (uint256 i = 0; i < index; i++) {
            newAddresses[i] = A[i];
        }
        for (uint256 j = index + 1; j < length; j++) {
            newAddresses[j - 1] = A[j];
        }
        return (newAddresses, A[index]);
    }

    /**
     * @return Returns the new array
     */
    function remove(address[] memory A, address a)
        internal
        pure
        returns (address[] memory)
    {
        (uint256 index, bool isIn) = indexOf(A, a);
        if (!isIn) {
            revert();
        } else {
            (address[] memory _A,) = pop(A, index);
            return _A;
        }
    }

    function sPop(address[] storage A, uint256 index) internal returns (address) {
        uint256 length = A.length;
        if (index >= length) {
            revert("Error: index out of bounds");
        }
        address entry = A[index];
        for (uint256 i = index; i < length - 1; i++) {
            A[i] = A[i + 1];
        }
        A.length--;
        return entry;
    }

    /**
    * Deletes address at index and fills the spot with the last address.
    * Order is not preserved.
    * @return Returns the removed entry
    */
    function sPopCheap(address[] storage A, uint256 index) internal returns (address) {
        uint256 length = A.length;
        if (index >= length) {
            revert("Error: index out of bounds");
        }
        address entry = A[index];
        if (index != length - 1) {
            A[index] = A[length - 1];
            delete A[length - 1];
        }
        A.length--;
        return entry;
    }

    /**
     * Deletes address at index. Works by swapping it with the last address, then deleting.
     * Order is not preserved
     * @param A Storage array to remove from
     */
    function sRemoveCheap(address[] storage A, address a) internal {
        (uint256 index, bool isIn) = indexOf(A, a);
        if (!isIn) {
            revert("Error: entry not found");
        } else {
            sPopCheap(A, index);
            return;
        }
    }

    /**
     * Returns whether or not there's a duplicate. Runs in O(n^2).
     * @param A Array to search
     * @return Returns true if duplicate, false otherwise
     */
    function hasDuplicate(address[] memory A) internal pure returns (bool) {
        if (A.length == 0) {
            return false;
        }
        for (uint256 i = 0; i < A.length - 1; i++) {
            for (uint256 j = i + 1; j < A.length; j++) {
                if (A[i] == A[j]) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * Returns whether the two arrays are equal.
     * @param A The first array
     * @param B The second array
     * @return True is the arrays are equal, false if not.
     */
    function isEqual(address[] memory A, address[] memory B) internal pure returns (bool) {
        if (A.length != B.length) {
            return false;
        }
        for (uint256 i = 0; i < A.length; i++) {
            if (A[i] != B[i]) {
                return false;
            }
        }
        return true;
    }

    /**
     * Returns the elements indexed at indexArray.
     * @param A The array to index
     * @param indexArray The array to use to index
     * @return Returns array containing elements indexed at indexArray
     */
    function argGet(address[] memory A, uint256[] memory indexArray)
        internal
        pure
        returns (address[] memory)
    {
        address[] memory array = new address[](indexArray.length);
        for (uint256 i = 0; i < indexArray.length; i++) {
            array[i] = A[indexArray[i]];
        }
        return array;
    }

}

// File: contracts/lib/TimeLockUpgrade.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;




/**
 * @title TimeLockUpgrade
 * @author Set Protocol
 *
 * The TimeLockUpgrade contract contains a modifier for handling minimum time period updates
 */
contract TimeLockUpgrade is
    Ownable
{
    using SafeMath for uint256;

    /* ============ State Variables ============ */

    // Timelock Upgrade Period in seconds
    uint256 public timeLockPeriod;

    // Mapping of upgradable units and initialized timelock
    mapping(bytes32 => uint256) public timeLockedUpgrades;

    /* ============ Events ============ */

    event UpgradeRegistered(
        bytes32 _upgradeHash,
        uint256 _timestamp
    );

    /* ============ Modifiers ============ */

    modifier timeLockUpgrade() {
        // If the time lock period is 0, then allow non-timebound upgrades.
        // This is useful for initialization of the protocol and for testing.
        if (timeLockPeriod == 0) {
            _;

            return;
        }

        // The upgrade hash is defined by the hash of the transaction call data,
        // which uniquely identifies the function as well as the passed in arguments.
        bytes32 upgradeHash = keccak256(
            abi.encodePacked(
                msg.data
            )
        );

        uint256 registrationTime = timeLockedUpgrades[upgradeHash];

        // If the upgrade hasn't been registered, register with the current time.
        if (registrationTime == 0) {
            timeLockedUpgrades[upgradeHash] = block.timestamp;

            emit UpgradeRegistered(
                upgradeHash,
                block.timestamp
            );

            return;
        }

        require(
            block.timestamp >= registrationTime.add(timeLockPeriod),
            "TimeLockUpgrade: Time lock period must have elapsed."
        );

        // Reset the timestamp to 0
        timeLockedUpgrades[upgradeHash] = 0;

        // Run the rest of the upgrades
        _;
    }

    /* ============ Function ============ */

    /**
     * Change timeLockPeriod period. Generally called after initially settings have been set up.
     *
     * @param  _timeLockPeriod   Time in seconds that upgrades need to be evaluated before execution
     */
    function setTimeLockPeriod(
        uint256 _timeLockPeriod
    )
        external
        onlyOwner
    {
        // Only allow setting of the timeLockPeriod if the period is greater than the existing
        require(
            _timeLockPeriod > timeLockPeriod,
            "TimeLockUpgrade: New period must be greater than existing"
        );

        timeLockPeriod = _timeLockPeriod;
    }
}

// File: contracts/core/extensions/CoreAdmin.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;






/**
 * @title CoreAdmin
 * @author Set Protocol
 *
 * The CoreAdmin contract contains methods to alter state of variables that track
 * Core dependency addresses.
 */
contract CoreAdmin is
    Ownable,
    CoreState,
    TimeLockUpgrade
{
    using AddressArrayUtils for address[];

    /* ============ Events ============ */

    event FactoryAdded(
        address _factory
    );

    event FactoryRemoved(
        address _factory
    );

    event ExchangeAdded(
        uint8 _exchangeId,
        address _exchange
    );

    event ExchangeRemoved(
        uint8 _exchangeId
    );

    event ModuleAdded(
        address _module
    );

    event ModuleRemoved(
        address _module
    );

    event SetDisabled(
        address _set
    );

    event SetReenabled(
        address _set
    );

    event PriceLibraryAdded(
        address _priceLibrary
    );

    event PriceLibraryRemoved(
        address _priceLibrary
    );

    /* ============ External Functions ============ */

    /**
     * Add a factory from the mapping of tracked factories.
     * Can only be called by owner of Core.
     *
     * @param  _factory   Address of the factory conforming to ISetFactory
     */
    function addFactory(
        address _factory
    )
        external
        onlyOwner
        timeLockUpgrade
    {
        require(
            !state.validFactories[_factory]
        );

        state.validFactories[_factory] = true;

        state.factories = state.factories.append(_factory);

        emit FactoryAdded(
            _factory
        );
    }

    /**
     * Remove a factory from the mapping of tracked factories.
     * Can only be called by owner of Core.
     *
     * @param  _factory   Address of the factory conforming to ISetFactory
     */
    function removeFactory(
        address _factory
    )
        external
        onlyOwner
    {
        require(
            state.validFactories[_factory]
        );

        state.factories = state.factories.remove(_factory);

        state.validFactories[_factory] = false;

        emit FactoryRemoved(
            _factory
        );
    }

    /**
     * Add an exchange address with the mapping of tracked exchanges.
     * Can only be called by owner of Core.
     *
     * @param _exchangeId   Enumeration of exchange within the mapping
     * @param _exchange     Address of the exchange conforming to IExchangeWrapper
     */
    function addExchange(
        uint8 _exchangeId,
        address _exchange
    )
        external
        onlyOwner
        timeLockUpgrade
    {
        require(
            state.exchangeIds[_exchangeId] == address(0)
        );

        state.exchangeIds[_exchangeId] = _exchange;

        state.exchanges = state.exchanges.append(_exchange);

        emit ExchangeAdded(
            _exchangeId,
            _exchange
        );
    }

    /**
     * Remove an exchange address with the mapping of tracked exchanges.
     * Can only be called by owner of Core.
     *
     * @param _exchangeId   Enumeration of exchange within the mapping
     * @param _exchange     Address of the exchange conforming to IExchangeWrapper
     */
    function removeExchange(
        uint8 _exchangeId,
        address _exchange
    )
        external
        onlyOwner
    {
        require(
            state.exchangeIds[_exchangeId] != address(0) &&
            state.exchangeIds[_exchangeId] == _exchange
        );

        state.exchanges = state.exchanges.remove(_exchange);

        state.exchangeIds[_exchangeId] = address(0);

        emit ExchangeRemoved(
            _exchangeId
        );
    }

    /**
     * Add a module address with the mapping of tracked modules.
     * Can only be called by owner of Core.
     *
     * @param _module     Address of the module
     */
    function addModule(
        address _module
    )
        external
        onlyOwner
        timeLockUpgrade
    {
        require(
            !state.validModules[_module]
        );

        state.validModules[_module] = true;

        state.modules = state.modules.append(_module);

        emit ModuleAdded(
            _module
        );
    }

    /**
     * Remove a module address with the mapping of tracked modules.
     * Can only be called by owner of Core.
     *
     * @param _module   Enumeration of module within the mapping
     */
    function removeModule(
        address _module
    )
        external
        onlyOwner
    {
        require(
            state.validModules[_module]
        );

        state.modules = state.modules.remove(_module);

        state.validModules[_module] = false;

        emit ModuleRemoved(
            _module
        );
    }

    /**
     * Disables a Set from the mapping and array of tracked Sets.
     * Can only be called by owner of Core.
     *
     * @param  _set       Address of the Set
     */
    function disableSet(
        address _set
    )
        external
        onlyOwner
    {
        require(
            state.validSets[_set]
        );

        state.setTokens = state.setTokens.remove(_set);

        state.validSets[_set] = false;

        state.disabledSets[_set] = true;

        emit SetDisabled(
            _set
        );
    }

    /**
     * Enables a Set from the mapping and array of tracked Sets if it has been previously disabled
     * Can only be called by owner of Core.
     *
     * @param  _set       Address of the Set
     */
    function reenableSet(
        address _set
    )
        external
        onlyOwner
    {
        require(
            state.disabledSets[_set]
        );

        state.setTokens = state.setTokens.append(_set);

        state.validSets[_set] = true;

        state.disabledSets[_set] = false;

        emit SetReenabled(
            _set
        );
    }

    /**
     * Add a price library from the mapping of tracked price libraries.
     * Can only be called by owner of Core.
     *
     * @param  _priceLibrary   Address of the price library
     */
    function addPriceLibrary(
        address _priceLibrary
    )
        external
        onlyOwner
        timeLockUpgrade
    {
        require(
            !state.validPriceLibraries[_priceLibrary]
        );

        state.validPriceLibraries[_priceLibrary] = true;

        state.priceLibraries = state.priceLibraries.append(_priceLibrary);

        emit PriceLibraryAdded(
            _priceLibrary
        );
    }

    /**
     * Remove a price library from the mapping of tracked price libraries.
     * Can only be called by owner of Core.
     *
     * @param  _priceLibrary   Address of the price library
     */
    function removePriceLibrary(
        address _priceLibrary
    )
        external
        onlyOwner
    {
        require(
            state.validPriceLibraries[_priceLibrary]
        );

        state.priceLibraries = state.priceLibraries.remove(_priceLibrary);

        state.validPriceLibraries[_priceLibrary] = false;

        emit PriceLibraryRemoved(
            _priceLibrary
        );
    }
}

// File: contracts/core/interfaces/ISetFactory.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;


/**
 * @title ISetFactory
 * @author Set Protocol
 *
 * The ISetFactory interface provides operability for authorized contracts
 * to interact with SetTokenFactory
 */
interface ISetFactory {

    /* ============ External Functions ============ */

    /**
     * Return core address
     *
     * @return address        core address
     */
    function core()
        external
        returns (address);

    /**
     * Deploys a new Set Token and adds it to the valid list of SetTokens
     *
     * @param  _components           The address of component tokens
     * @param  _units                The units of each component token
     * @param  _naturalUnit          The minimum unit to be issued or redeemed
     * @param  _name                 The bytes32 encoded name of the new Set
     * @param  _symbol               The bytes32 encoded symbol of the new Set
     * @param  _callData             Byte string containing additional call parameters
     * @return setTokenAddress       The address of the new Set
     */
    function createSet(
        address[] calldata _components,
        uint[] calldata _units,
        uint256 _naturalUnit,
        bytes32 _name,
        bytes32 _symbol,
        bytes calldata _callData
    )
        external
        returns (address);
}

// File: contracts/core/extensions/CoreFactory.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;




/**
 * @title CoreFactory
 * @author Set Protocol
 *
 * The CoreFactory contract contains Set Token creation operations
 */
contract CoreFactory is
    CoreState
{
    /* ============ Events ============ */

    event SetTokenCreated(
        address indexed _setTokenAddress,
        address _factory,
        address[] _components,
        uint256[] _units,
        uint256 _naturalUnit,
        bytes32 _name,
        bytes32 _symbol
    );

    /* ============ External Functions ============ */

    /**
     * Deploys a new Set Token and adds it to the valid list of SetTokens
     *
     * @param  _factory              The address of the Factory to create from
     * @param  _components           The address of component tokens
     * @param  _units                The units of each component token
     * @param  _naturalUnit          The minimum unit to be issued or redeemed
     * @param  _name                 The bytes32 encoded name of the new Set
     * @param  _symbol               The bytes32 encoded symbol of the new Set
     * @param  _callData             Byte string containing additional call parameters
     * @return setTokenAddress       The address of the new Set
     */
    function createSet(
        address _factory,
        address[] calldata _components,
        uint256[] calldata _units,
        uint256 _naturalUnit,
        bytes32 _name,
        bytes32 _symbol,
        bytes calldata _callData
    )
        external
        returns (address)
    {
        // Verify Factory is linked to Core
        require(
            state.validFactories[_factory],
            "CreateSet"
        );

        // Create the Set
        address newSetTokenAddress = ISetFactory(_factory).createSet(
            _components,
            _units,
            _naturalUnit,
            _name,
            _symbol,
            _callData
        );

        // Add Set to the mapping of tracked Sets
        state.validSets[newSetTokenAddress] = true;

        // Add Set to the array of tracked Sets
        state.setTokens.push(newSetTokenAddress);

        // Emit Set Token creation log
        emit SetTokenCreated(
            newSetTokenAddress,
            _factory,
            _components,
            _units,
            _naturalUnit,
            _name,
            _symbol
        );

        return newSetTokenAddress;
    }
}

// File: contracts/lib/CommonMath.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;



library CommonMath {
    using SafeMath for uint256;

    /**
     * Calculates and returns the maximum value for a uint256
     *
     * @return  The maximum value for uint256
     */
    function maxUInt256()
        internal
        pure
        returns (uint256)
    {
        return 2 ** 256 - 1;
    }

    /**
    * @dev Performs the power on a specified value, reverts on overflow.
    */
    function safePower(
        uint256 a,
        uint256 pow
    )
        internal
        pure
        returns (uint256)
    {
        require(a > 0);

        uint256 result = 1;
        for (uint256 i = 0; i < pow; i++){
            uint256 previousResult = result;

            // Using safemath multiplication prevents overflows
            result = previousResult.mul(a);
        }

        return result;
    }

    /**
     * Checks for rounding errors and returns value of potential partial amounts of a principal
     *
     * @param  _principal       Number fractional amount is derived from
     * @param  _numerator       Numerator of fraction
     * @param  _denominator     Denominator of fraction
     * @return uint256          Fractional amount of principal calculated
     */
    function getPartialAmount(
        uint256 _principal,
        uint256 _numerator,
        uint256 _denominator
    )
        internal
        pure
        returns (uint256)
    {
        // Get remainder of partial amount (if 0 not a partial amount)
        uint256 remainder = mulmod(_principal, _numerator, _denominator);

        // Return if not a partial amount
        if (remainder == 0) {
            return _principal.mul(_numerator).div(_denominator);
        }

        // Calculate error percentage
        uint256 errPercentageTimes1000000 = remainder.mul(1000000).div(_numerator.mul(_principal));

        // Require error percentage is less than 0.1%.
        require(
            errPercentageTimes1000000 < 1000,
            "CommonMath.getPartialAmount: Rounding error exceeds bounds"
        );

        return _principal.mul(_numerator).div(_denominator);
    }

}

// File: contracts/core/lib/CoreIssuanceLibrary.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;





/**
 * @title CoreIssuanceLibrary
 * @author Set Protocol
 *
 * This library contains functions for calculating deposit, withdrawal,and transfer quantities
 */
library CoreIssuanceLibrary {

    using SafeMath for uint256;

    /**
     * Calculate the quantities required to deposit and decrement during issuance. Takes into account
     * the tokens an owner already has in the vault.
     *
     * @param _components                           Addresses of components
     * @param _componentQuantities                  Component quantities to increment and withdraw
     * @param _owner                                Address to deposit and decrement quantities from
     * @param _vault                                Address to vault
     * @return uint256[] decrementQuantities        Quantities to decrement from vault
     * @return uint256[] depositQuantities          Quantities to deposit into the vault
     */
    function calculateDepositAndDecrementQuantities(
        address[] calldata _components,
        uint256[] calldata _componentQuantities,
        address _owner,
        address _vault
    )
        external
        view
        returns (
            uint256[] memory /* decrementQuantities */,
            uint256[] memory /* depositQuantities */
        )
    {
        uint256 componentCount = _components.length;
        uint256[] memory decrementTokenOwnerValues = new uint256[](componentCount);
        uint256[] memory depositQuantities = new uint256[](componentCount);

        for (uint256 i = 0; i < componentCount; i++) {
            // Fetch component quantity in vault
            uint256 vaultBalance = IVault(_vault).getOwnerBalance(
                _components[i],
                _owner
            );

            // If the vault holds enough components, decrement the full amount
            if (vaultBalance >= _componentQuantities[i]) {
                decrementTokenOwnerValues[i] = _componentQuantities[i];
            } else {
                // User has less than required amount, decrement the vault by full balance
                if (vaultBalance > 0) {
                    decrementTokenOwnerValues[i] = vaultBalance;
                }

                depositQuantities[i] = _componentQuantities[i].sub(vaultBalance);
            }
        }

        return (
            decrementTokenOwnerValues,
            depositQuantities
        );
    }

    /**
     * Calculate the quantities required to withdraw and increment during redeem and withdraw. Takes into
     * account a bitmask exclusion parameter.
     *
     * @param _componentQuantities                  Component quantities to increment and withdraw
     * @param _toExclude                            Mask of indexes of tokens to exclude from withdrawing
     * @return uint256[] incrementQuantities        Quantities to increment in vault
     * @return uint256[] withdrawQuantities         Quantities to withdraw from vault
     */
    function calculateWithdrawAndIncrementQuantities(
        uint256[] calldata _componentQuantities,
        uint256 _toExclude
    )
        external
        pure
        returns (
            uint256[] memory /* incrementQuantities */,
            uint256[] memory /* withdrawQuantities */
        )
    {
        uint256 componentCount = _componentQuantities.length;
        uint256[] memory incrementTokenOwnerValues = new uint256[](componentCount);
        uint256[] memory withdrawToValues = new uint256[](componentCount);

        // Loop through and decrement vault balances for the set, withdrawing if requested
        for (uint256 i = 0; i < componentCount; i++) {
            // Calculate bit index of current component
            uint256 componentBitIndex = CommonMath.safePower(2, i);

            // Transfer to user unless component index is included in _toExclude
            if ((_toExclude & componentBitIndex) != 0) {
                incrementTokenOwnerValues[i] = _componentQuantities[i];
            } else {
                withdrawToValues[i] = _componentQuantities[i];
            }
        }

        return (
            incrementTokenOwnerValues,
            withdrawToValues
        );
    }

    /**
     * Calculate the required component quantities required for issuance or rdemption for a given
     * quantity of Set Tokens
     *
     * @param _componentUnits   The units of the component token
     * @param _naturalUnit      The natural unit of the Set token
     * @param _quantity         The number of tokens being redeem
     * @return uint256[]        Required quantities in base units of components
     */
    function calculateRequiredComponentQuantities(
        uint256[] calldata _componentUnits,
        uint256 _naturalUnit,
        uint256 _quantity
    )
        external
        pure
        returns (uint256[] memory)
    {
        require(
            _quantity.mod(_naturalUnit) == 0,
            "CoreIssuanceLibrary: Quantity must be a multiple of nat unit"
        );

        uint256[] memory tokenValues = new uint256[](_componentUnits.length);

        // Transfer the underlying tokens to the corresponding token balances
        for (uint256 i = 0; i < _componentUnits.length; i++) {
            tokenValues[i] = _quantity.div(_naturalUnit).mul(_componentUnits[i]);
        }

        return tokenValues;
    }

}

// File: contracts/core/interfaces/ISetToken.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;

/**
 * @title ISetToken
 * @author Set Protocol
 *
 * The ISetToken interface provides a light-weight, structured way to interact with the
 * SetToken contract from another contract.
 */
interface ISetToken {

    /* ============ External Functions ============ */

    /*
     * Get natural unit of Set
     *
     * @return  uint256       Natural unit of Set
     */
    function naturalUnit()
        external
        view
        returns (uint256);

    /*
     * Get addresses of all components in the Set
     *
     * @return  componentAddresses       Array of component tokens
     */
    function getComponents()
        external
        view
        returns (address[] memory);

    /*
     * Get units of all tokens in Set
     *
     * @return  units       Array of component units
     */
    function getUnits()
        external
        view
        returns (uint256[] memory);

    /*
     * Checks to make sure token is component of Set
     *
     * @param  _tokenAddress     Address of token being checked
     * @return  bool             True if token is component of Set
     */
    function tokenIsComponent(
        address _tokenAddress
    )
        external
        view
        returns (bool);

    /*
     * Mint set token for given address.
     * Can only be called by authorized contracts.
     *
     * @param  _issuer      The address of the issuing account
     * @param  _quantity    The number of sets to attribute to issuer
     */
    function mint(
        address _issuer,
        uint256 _quantity
    )
        external;

    /*
     * Burn set token for given address
     * Can only be called by authorized contracts
     *
     * @param  _from        The address of the redeeming account
     * @param  _quantity    The number of sets to burn from redeemer
     */
    function burn(
        address _from,
        uint256 _quantity
    )
        external;

    /**
    * Transfer token for a specified address
    *
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(
        address to,
        uint256 value
    )
        external;
}

// File: contracts/core/lib/SetTokenLibrary.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;




library SetTokenLibrary {
    using SafeMath for uint256;

    struct SetDetails {
        uint256 naturalUnit;
        address[] components;
        uint256[] units;
    }

    /**
     * Validates that passed in tokens are all components of the Set
     *
     * @param _set                      Address of the Set
     * @param _tokens                   List of tokens to check
     */
    function validateTokensAreComponents(
        address _set,
        address[] calldata _tokens
    )
        external
        view
    {
        for (uint256 i = 0; i < _tokens.length; i++) {
            // Make sure all tokens are members of the Set
            require(
                ISetToken(_set).tokenIsComponent(_tokens[i]),
                "SetTokenLibrary.validateTokensAreComponents: Component must be a member of Set"
            );

        }
    }

    /**
     * Validates that passed in quantity is a multiple of the natural unit of the Set.
     *
     * @param _set                      Address of the Set
     * @param _quantity                   Quantity to validate
     */
    function isMultipleOfSetNaturalUnit(
        address _set,
        uint256 _quantity
    )
        external
        view
    {
        require(
            _quantity.mod(ISetToken(_set).naturalUnit()) == 0,
            "SetTokenLibrary.isMultipleOfSetNaturalUnit: Quantity is not a multiple of nat unit"
        );
    }

    /**
     * Retrieves the Set's natural unit, components, and units.
     *
     * @param _set                      Address of the Set
     * @return SetDetails               Struct containing the natural unit, components, and units
     */
    function getSetDetails(
        address _set
    )
        internal
        view
        returns (SetDetails memory)
    {
        // Declare interface variables
        ISetToken setToken = ISetToken(_set);

        // Fetch set token properties
        uint256 naturalUnit = setToken.naturalUnit();
        address[] memory components = setToken.getComponents();
        uint256[] memory units = setToken.getUnits();

        return SetDetails({
            naturalUnit: naturalUnit,
            components: components,
            units: units
        });
    }
}

// File: contracts/core/extensions/CoreIssuance.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;









/**
 * @title CoreIssuance
 * @author Set Protocol
 *
 * The CoreIssuance contract contains function related to issuing and redeeming Sets.
 */
contract CoreIssuance is
    CoreState,
    CoreOperationState,
    ReentrancyGuard
{
    // Use SafeMath library for all uint256 arithmetic
    using SafeMath for uint256;

    /* ============ Events ============ */

    event SetIssued(
        address _setAddress,
        uint256 _quantity
    );

    event SetRedeemed(
        address _setAddress,
        uint256 _quantity
    );

    /* ============ External Functions ============ */

    /**
     * Issues a specified Set for a specified quantity to the caller
     * using the caller's components from the wallet and vault.
     *
     * @param  _set          Address of the Set to issue
     * @param  _quantity     Number of tokens to issue
     */
    function issue(
        address _set,
        uint256 _quantity
    )
        external
        nonReentrant
    {
        issueInternal(
            msg.sender,
            msg.sender,
            _set,
            _quantity
        );
    }

    /**
     * Converts user's components into Set Tokens owned by the user and stored in Vault
     *
     * @param _set          Address of the Set
     * @param _quantity     Number of tokens to redeem
     */
    function issueInVault(
        address _set,
        uint256 _quantity
    )
        external
        nonReentrant
    {
        issueInVaultInternal(
            msg.sender,
            _set,
            _quantity
        );
    }

    /**
     * Issues a specified Set for a specified quantity to the recipient
     * using the caller's components from the wallet and vault.
     *
     * @param  _recipient    Address to issue to
     * @param  _set          Address of the Set to issue
     * @param  _quantity     Number of tokens to issue
     */
    function issueTo(
        address _recipient,
        address _set,
        uint256 _quantity
    )
        external
        nonReentrant
    {
        issueInternal(
            msg.sender,
            _recipient,
            _set,
            _quantity
        );
    }

    /**
     * Exchange Set tokens for underlying components to the user held in the Vault.
     *
     * @param  _set          Address of the Set to redeem
     * @param  _quantity     Number of tokens to redeem
     */
    function redeem(
        address _set,
        uint256 _quantity
    )
        external
        nonReentrant
    {
        redeemInternal(
            msg.sender,
            msg.sender,
            _set,
            _quantity
        );
    }

    /**
     * Composite method to redeem and withdraw with a single transaction
     *
     * Normally, you should expect to be able to withdraw all of the tokens.
     * However, some have central abilities to freeze transfers (e.g. EOS). _toExclude
     * allows you to optionally specify which component tokens to exclude when
     * redeeming. They will remain in the vault under the users' addresses.
     *
     * @param _set          Address of the Set
     * @param _to           Address to withdraw or attribute tokens to
     * @param _quantity     Number of tokens to redeem
     * @param _toExclude    Mask of indexes of tokens to exclude from withdrawing
     */
    function redeemAndWithdrawTo(
        address _set,
        address _to,
        uint256 _quantity,
        uint256 _toExclude
    )
        external
        nonReentrant
    {
        uint256[] memory componentTransferValues = redeemAndDecrementVault(
            _set,
            msg.sender,
            _quantity
        );

        // Calculate the withdraw and increment quantities to specified address
        uint256[] memory incrementTokenOwnerValues;
        uint256[] memory withdrawToValues;
        (
            incrementTokenOwnerValues,
            withdrawToValues
        ) = CoreIssuanceLibrary.calculateWithdrawAndIncrementQuantities(
            componentTransferValues,
            _toExclude
        );

        address[] memory components = ISetToken(_set).getComponents();

        // Increment excluded components to the specified address
        state.vaultInstance.batchIncrementTokenOwner(
            components,
            _to,
            incrementTokenOwnerValues
        );

        // Withdraw non-excluded components and attribute to specified address
        state.vaultInstance.batchWithdrawTo(
            components,
            _to,
            withdrawToValues
        );
    }

    /**
     * Convert the caller's Set tokens held in the vault into underlying components to the user
     * held in the Vault.
     *
     * @param _set          Address of the Set
     * @param _quantity     Number of tokens to redeem
     */
    function redeemInVault(
        address _set,
        uint256 _quantity
    )
        external
        nonReentrant
    {
        // Decrement ownership of Set token in the vault
        state.vaultInstance.decrementTokenOwner(
            _set,
            msg.sender,
            _quantity
        );

        redeemInternal(
            state.vault,
            msg.sender,
            _set,
            _quantity
        );
    }

    /**
     * Redeem Set token and return components to specified recipient. The components
     * are left in the vault after redemption in the recipient's name.
     *
     * @param _recipient    Recipient of Set being issued
     * @param _set          Address of the Set
     * @param _quantity     Number of tokens to redeem
     */
    function redeemTo(
        address _recipient,
        address _set,
        uint256 _quantity
    )
        external
        nonReentrant
    {
        redeemInternal(
            msg.sender,
            _recipient,
            _set,
            _quantity
        );
    }

    /* ============ Internal Functions ============ */

    /**
     * Exchange components for Set tokens, accepting any owner
     * Used in issue, issueTo, and issueInVaultInternal
     *
     * @param  _componentOwner  Address to use tokens from
     * @param  _setRecipient    Address to issue Set to
     * @param  _set             Address of the Set to issue
     * @param  _quantity        Number of tokens to issue
     */
    function issueInternal(
        address _componentOwner,
        address _setRecipient,
        address _set,
        uint256 _quantity
    )
        internal
        whenOperational
    {
        // Verify Set was created by Core and is enabled
        require(
            state.validSets[_set],
            "IssueInternal"
        );

        // Validate quantity is multiple of natural unit
        SetTokenLibrary.isMultipleOfSetNaturalUnit(_set, _quantity);

        SetTokenLibrary.SetDetails memory setToken = SetTokenLibrary.getSetDetails(_set);

        // Calculate component quantities required to issue
        uint256[] memory requiredComponentQuantities = CoreIssuanceLibrary.calculateRequiredComponentQuantities(
            setToken.units,
            setToken.naturalUnit,
            _quantity
        );

        // Calculate the withdraw and increment quantities to caller
        uint256[] memory decrementTokenOwnerValues;
        uint256[] memory depositValues;
        (
            decrementTokenOwnerValues,
            depositValues
        ) = CoreIssuanceLibrary.calculateDepositAndDecrementQuantities(
            setToken.components,
            requiredComponentQuantities,
            _componentOwner,
            state.vault
        );

        // Decrement components used for issuance in vault
        state.vaultInstance.batchDecrementTokenOwner(
            setToken.components,
            _componentOwner,
            decrementTokenOwnerValues
        );

        // Deposit tokens used for issuance into vault
        state.transferProxyInstance.batchTransfer(
            setToken.components,
            depositValues,
            _componentOwner,
            state.vault
        );

        // Increment the vault balance of the set token for the components
        state.vaultInstance.batchIncrementTokenOwner(
            setToken.components,
            _set,
            requiredComponentQuantities
        );

        // Issue set token
        ISetToken(_set).mint(
            _setRecipient,
            _quantity
        );

        emit SetIssued(
            _set,
            _quantity
        );
    }

    /**
     * Converts recipient's components into Set Tokens held directly in Vault.
     * Used in issueInVault
     *
     * @param _recipient    Address to issue to
     * @param _set          Address of the Set
     * @param _quantity     Number of tokens to issue
     */
    function issueInVaultInternal(
        address _recipient,
        address _set,
        uint256 _quantity
    )
        internal
    {
        issueInternal(
            _recipient,
            state.vault,
            _set,
            _quantity
        );

        // Increment ownership of Set token in the vault
        state.vaultInstance.incrementTokenOwner(
            _set,
            _recipient,
            _quantity
        );
    }

    /**
     * Exchange Set tokens for underlying components. Components are attributed in the vault.
     * Used in redeem, redeemInVault, and redeemTo
     *
     * @param _burnAddress       Address to burn tokens from
     * @param _incrementAddress  Address to increment component tokens to
     * @param _set               Address of the Set to redeem
     * @param _quantity          Number of tokens to redeem
     */
    function redeemInternal(
        address _burnAddress,
        address _incrementAddress,
        address _set,
        uint256 _quantity
    )
        internal
    {
        uint256[] memory componentQuantities = redeemAndDecrementVault(
            _set,
            _burnAddress,
            _quantity
        );

        // Increment the component amount
        address[] memory components = ISetToken(_set).getComponents();
        state.vaultInstance.batchIncrementTokenOwner(
            components,
            _incrementAddress,
            componentQuantities
        );
    }

   /**
     * Private method that validates inputs, redeems Set, and decrements
     * the components in the vault
     *
     * @param _set                  Address of the Set to redeem
     * @param _burnAddress          Address to burn tokens from
     * @param _quantity             Number of tokens to redeem
     * @return componentQuantities  Transfer value of components
     */
    function redeemAndDecrementVault(
        address _set,
        address _burnAddress,
        uint256 _quantity
    )
        private
        returns (uint256[] memory)
    {
        // Verify Set was created by Core and is enabled
        require(
            state.validSets[_set],
            "RedeemAndDecrementVault"
        );

        // Validate quantity is multiple of natural unit
        SetTokenLibrary.isMultipleOfSetNaturalUnit(_set, _quantity);

        // Burn the Set token (thereby decrementing the Set balance)
        ISetToken(_set).burn(
            _burnAddress,
            _quantity
        );

        SetTokenLibrary.SetDetails memory setToken = SetTokenLibrary.getSetDetails(_set);

        // Calculate component quantities to redeem
        uint256[] memory componentQuantities = CoreIssuanceLibrary.calculateRequiredComponentQuantities(
            setToken.units,
            setToken.naturalUnit,
            _quantity
        );

        // Decrement components from Set's possession
        state.vaultInstance.batchDecrementTokenOwner(
            setToken.components,
            _set,
            componentQuantities
        );

        emit SetRedeemed(
            _set,
            _quantity
        );

        return componentQuantities;
    }
}

// File: contracts/core/interfaces/ICoreAccounting.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;


/**
 * @title ICoreAccounting
 * @author Set Protocol
 *
 * The ICoreAccounting Contract defines all the functions exposed in the CoreIssuance
 * extension.
 */
contract ICoreAccounting {

    /* ============ Internal Functions ============ */

    /**
     * Internal function that deposits multiple tokens to the vault.
     * Quantities should be in the order of the addresses of the tokens being deposited.
     *
     * @param  _from              Address to transfer tokens from
     * @param  _to                Address to credit for deposits
     * @param  _tokens            Array of the addresses of the tokens being deposited
     * @param  _quantities        Array of the amounts of tokens to deposit
     */
    function batchDepositInternal(
        address _from,
        address _to,
        address[] memory _tokens,
        uint[] memory _quantities
    )
        internal;

    /**
     * Internal function that withdraws multiple tokens from the vault.
     * Quantities should be in the order of the addresses of the tokens being withdrawn.
     *
     * @param  _from              Address to decredit for withdrawals
     * @param  _to                Address to transfer tokens to
     * @param  _tokens            Array of the addresses of the tokens being withdrawn
     * @param  _quantities        Array of the amounts of tokens to withdraw
     */
    function batchWithdrawInternal(
        address _from,
        address _to,
        address[] memory _tokens,
        uint256[] memory _quantities
    )
        internal;
}

// File: contracts/core/interfaces/ICoreIssuance.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;


/**
 * @title ICoreIssuance
 * @author Set Protocol
 *
 * The ICoreIssuance Contract defines all the functions exposed in the CoreIssuance
 * extension.
 */
contract ICoreIssuance {

    /* ============ Internal Functions ============ */

    /**
     * Exchange components for Set tokens, accepting any owner
     *
     * @param  _owner        Address to use tokens from
     * @param  _recipient    Address to issue Set to
     * @param  _set          Address of the Set to issue
     * @param  _quantity     Number of tokens to issue
     */
    function issueInternal(
        address _owner,
        address _recipient,
        address _set,
        uint256 _quantity
    )
        internal;

    /**
     * Converts recipient's components into Set Tokens held directly in Vault
     *
     * @param _recipient    Address to issue to
     * @param _set          Address of the Set
     * @param _quantity     Number of tokens to issue
     */
    function issueInVaultInternal(
        address _recipient,
        address _set,
        uint256 _quantity
    )
        internal;

    /**
     * Exchange Set tokens for underlying components
     *
     * @param _burnAddress       Address to burn tokens from
     * @param _incrementAddress  Address to increment component tokens to
     * @param _set               Address of the Set to redeem
     * @param _quantity          Number of tokens to redeem
     */
    function redeemInternal(
        address _burnAddress,
        address _incrementAddress,
        address _set,
        uint256 _quantity
    )
        internal;
}

// File: contracts/core/extensions/CoreModuleInteraction.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;






/**
 * @title CoreModularInteraction
 * @author Set Protocol
 *
 * Extension used to expose internal accounting and issuance functions, vault, and proxy functions
 * to modules.
 */
contract CoreModuleInteraction is
    ICoreAccounting,
    ICoreIssuance,
    CoreState,
    ReentrancyGuard
{
    modifier onlyModule() {
        onlyModuleCallable();
        _;
    }

    function onlyModuleCallable() internal view {
        require(
            state.validModules[msg.sender],
            "OnlyModule"
        );
    }

    /**
     * Exposes internal function that deposits tokens to the vault, exposed to system
     * modules. Quantities should be in the order of the addresses of the tokens being
     * deposited.
     *
     * @param  _from              Address to transfer tokens from
     * @param  _to                Address to credit for deposits
     * @param  _token             Address of the token being deposited
     * @param  _quantity          Amount of tokens to deposit
     */
    function depositModule(
        address _from,
        address _to,
        address _token,
        uint256 _quantity
    )
        external
        onlyModule
    {
        address[] memory tokenArray = new address[](1);
        tokenArray[0] = _token;

        uint256[] memory quantityArray = new uint256[](1);
        quantityArray[0] = _quantity;

        batchDepositInternal(
            _from,
            _to,
            tokenArray,
            quantityArray
        );
    }

    /**
     * Exposes internal function that deposits multiple tokens to the vault, exposed to system
     * modules. Quantities should be in the order of the addresses of the tokens being
     * deposited.
     *
     * @param  _from              Address to transfer tokens from
     * @param  _to                Address to credit for deposits
     * @param  _tokens            Array of the addresses of the tokens being deposited
     * @param  _quantities        Array of the amounts of tokens to deposit
     */
    function batchDepositModule(
        address _from,
        address _to,
        address[] calldata _tokens,
        uint256[] calldata _quantities
    )
        external
        onlyModule
    {
        batchDepositInternal(
            _from,
            _to,
            _tokens,
            _quantities
        );
    }

    /**
     * Exposes internal function that withdraws multiple tokens to the vault, exposed to system
     * modules. Quantities should be in the order of the addresses of the tokens being
     * withdrawn.
     *
     * @param  _from              Address to decredit for withdrawals
     * @param  _to                Address to transfer tokens to
     * @param  _token             Address of the token being withdrawn
     * @param  _quantity          Amount of tokens to withdraw
     */
    function withdrawModule(
        address _from,
        address _to,
        address _token,
        uint256 _quantity
    )
        external
        onlyModule
    {
        address[] memory tokenArray = new address[](1);
        tokenArray[0] = _token;

        uint256[] memory quantityArray = new uint256[](1);
        quantityArray[0] = _quantity;

        batchWithdrawInternal(
            _from,
            _to,
            tokenArray,
            quantityArray
        );
    }

    /**
     * Exposes internal function that withdraws multiple tokens from the vault, to system
     * modules. Quantities should be in the order of the addresses of the tokens being withdrawn.
     *
     * @param  _from              Address to decredit for withdrawals
     * @param  _to                Address to transfer tokens to
     * @param  _tokens            Array of the addresses of the tokens being withdrawn
     * @param  _quantities        Array of the amounts of tokens to withdraw
     */
    function batchWithdrawModule(
        address _from,
        address _to,
        address[] calldata _tokens,
        uint256[] calldata _quantities
    )
        external
        onlyModule
    {
        batchWithdrawInternal(
            _from,
            _to,
            _tokens,
            _quantities
        );
    }

    /**
     * Expose internal function that exchanges components for Set tokens,
     * accepting any owner, to system modules
     *
     * @param  _componentOwner  Address to use tokens from
     * @param  _setRecipient    Address to issue Set to
     * @param  _set          Address of the Set to issue
     * @param  _quantity     Number of tokens to issue
     */
    function issueModule(
        address _componentOwner,
        address _setRecipient,
        address _set,
        uint256 _quantity
    )
        external
        onlyModule
    {
        issueInternal(
            _componentOwner,
            _setRecipient,
            _set,
            _quantity
        );
    }

    /**
     * Converts recipient's components into Set Token's held directly in Vault
     *
     * @param _recipient    Address to issue to
     * @param _set          Address of the Set
     * @param _quantity     Number of tokens to redeem
     */
    function issueInVaultModule(
        address _recipient,
        address _set,
        uint256 _quantity
    )
        external
        onlyModule
    {
        issueInVaultInternal(
            _recipient,
            _set,
            _quantity
        );
    }

    /**
     * Expose internal function that exchanges Set tokens for components,
     * accepting any owner, to system modules
     *
     * @param  _burnAddress         Address to burn token from
     * @param  _incrementAddress    Address to increment component tokens to
     * @param  _set                 Address of the Set to redeem
     * @param  _quantity            Number of tokens to redeem
     */
    function redeemModule(
        address _burnAddress,
        address _incrementAddress,
        address _set,
        uint256 _quantity
    )
        external
        onlyModule
    {
        redeemInternal(
            _burnAddress,
            _incrementAddress,
            _set,
            _quantity
        );
    }

    /**
     * Expose vault function that increments user's balance in the vault.
     * Available to system modules
     *
     * @param  _tokens          The addresses of the ERC20 tokens
     * @param  _owner           The address of the token owner
     * @param  _quantities      The numbers of tokens to attribute to owner
     */
    function batchIncrementTokenOwnerModule(
        address[] calldata _tokens,
        address _owner,
        uint256[] calldata _quantities
    )
        external
        onlyModule
    {
        state.vaultInstance.batchIncrementTokenOwner(
            _tokens,
            _owner,
            _quantities
        );
    }

    /**
     * Expose vault function that decrement user's balance in the vault
     * Only available to system modules.
     *
     * @param  _tokens          The addresses of the ERC20 tokens
     * @param  _owner           The address of the token owner
     * @param  _quantities      The numbers of tokens to attribute to owner
     */
    function batchDecrementTokenOwnerModule(
        address[] calldata _tokens,
        address _owner,
        uint256[] calldata _quantities
    )
        external
        onlyModule
    {
        state.vaultInstance.batchDecrementTokenOwner(
            _tokens,
            _owner,
            _quantities
        );
    }

    /**
     * Expose vault function that transfer vault balances between users
     * Only available to system modules.
     *
     * @param  _tokens           Addresses of tokens being transferred
     * @param  _from             Address tokens being transferred from
     * @param  _to               Address tokens being transferred to
     * @param  _quantities       Amounts of tokens being transferred
     */
    function batchTransferBalanceModule(
        address[] calldata _tokens,
        address _from,
        address _to,
        uint256[] calldata _quantities
    )
        external
        onlyModule
    {
        state.vaultInstance.batchTransferBalance(
            _tokens,
            _from,
            _to,
            _quantities
        );
    }

    /**
     * Transfers token from one address to another using the transfer proxy.
     * Only available to system modules.
     *
     * @param  _token          The address of the ERC20 token
     * @param  _quantity       The number of tokens to transfer
     * @param  _from           The address to transfer from
     * @param  _to             The address to transfer to
     */
    function transferModule(
        address _token,
        uint256 _quantity,
        address _from,
        address _to
    )
        external
        onlyModule
    {
        state.transferProxyInstance.transfer(
            _token,
            _quantity,
            _from,
            _to
        );
    }

    /**
     * Expose transfer proxy function to transfer tokens from one address to another
     * Only available to system modules.
     *
     * @param  _tokens         The addresses of the ERC20 token
     * @param  _quantities     The numbers of tokens to transfer
     * @param  _from           The address to transfer from
     * @param  _to             The address to transfer to
     */
    function batchTransferModule(
        address[] calldata _tokens,
        uint256[] calldata _quantities,
        address _from,
        address _to
    )
        external
        onlyModule
    {
        state.transferProxyInstance.batchTransfer(
            _tokens,
            _quantities,
            _from,
            _to
        );
    }
}

// File: contracts/core/Core.sol

/*
    Copyright 2018 Set Labs Inc.

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
*/

pragma solidity 0.5.7;









/**
 * @title Core
 * @author Set Protocol
 *
 * The Core contract acts as a coordinator handling issuing, redeeming, and
 * creating Sets, as well as all collateral flows throughout the system. Core
 * is also responsible for tracking state and exposing methods to modules
 */
 /* solium-disable-next-line no-empty-blocks */
contract Core is
    CoreAccounting,
    CoreAdmin,
    CoreFactory,
    CoreIssuance,
    CoreModuleInteraction
{
    /**
     * Constructor function for Core
     *
     * @param _transferProxy       The address of the transfer proxy
     * @param _vault               The address of the vault
     */
    constructor(
        address _transferProxy,
        address _vault
    )
        public
    {
        // Commit passed address to transferProxyAddress state variable
        state.transferProxy = _transferProxy;

        // Instantiate instance of transferProxy
        state.transferProxyInstance = ITransferProxy(_transferProxy);

        // Commit passed address to vault state variable
        state.vault = _vault;

        // Instantiate instance of vault
        state.vaultInstance = IVault(_vault);
    }
}