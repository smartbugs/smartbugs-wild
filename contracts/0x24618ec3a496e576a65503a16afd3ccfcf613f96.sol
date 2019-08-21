/**
 * Source Code first verified at https://etherscan.io on Tuesday, January 29, 2019
 (UTC) */

pragma solidity ^0.4.24;

// File: contracts/token/interfaces/IERC20Token.sol

/*
    ERC20 Standard Token interface
*/
contract IERC20Token {
    // these functions aren't abstract since the compiler emits automatically generated getter functions as external
    function name() public view returns (string) {}
    function symbol() public view returns (string) {}
    function decimals() public view returns (uint8) {}
    function totalSupply() public view returns (uint256) {}
    function balanceOf(address _owner) public view returns (uint256) { _owner; }
    function allowance(address _owner, address _spender) public view returns (uint256) { _owner; _spender; }

    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
}

// File: contracts/IBancorNetwork.sol

/*
    Bancor Network interface
*/
contract IBancorNetwork {
    function convert(IERC20Token[] _path, uint256 _amount, uint256 _minReturn) public payable returns (uint256);
    function convertFor(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, address _for) public payable returns (uint256);
    
    function convertForPrioritized3(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        uint256 _customVal,
        uint256 _block,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public payable returns (uint256);
    
    // deprecated, backward compatibility
    function convertForPrioritized2(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        uint256 _block,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public payable returns (uint256);

    // deprecated, backward compatibility
    function convertForPrioritized(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        uint256 _block,
        uint256 _nonce,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) public payable returns (uint256);
}

// File: contracts/ContractIds.sol

/**
    Id definitions for bancor contracts

    Can be used in conjunction with the contract registry to get contract addresses
*/
contract ContractIds {
    // generic
    bytes32 public constant CONTRACT_FEATURES = "ContractFeatures";
    bytes32 public constant CONTRACT_REGISTRY = "ContractRegistry";
    bytes32 public constant NON_STANDARD_TOKEN_REGISTRY = "NonStandardTokenRegistry";

    // bancor logic
    bytes32 public constant BANCOR_NETWORK = "BancorNetwork";
    bytes32 public constant BANCOR_FORMULA = "BancorFormula";
    bytes32 public constant BANCOR_GAS_PRICE_LIMIT = "BancorGasPriceLimit";
    bytes32 public constant BANCOR_CONVERTER_UPGRADER = "BancorConverterUpgrader";
    bytes32 public constant BANCOR_CONVERTER_FACTORY = "BancorConverterFactory";

    // BNT core
    bytes32 public constant BNT_TOKEN = "BNTToken";
    bytes32 public constant BNT_CONVERTER = "BNTConverter";

    // BancorX
    bytes32 public constant BANCOR_X = "BancorX";
    bytes32 public constant BANCOR_X_UPGRADER = "BancorXUpgrader";
}

// File: contracts/FeatureIds.sol

/**
    Id definitions for bancor contract features

    Can be used to query the ContractFeatures contract to check whether a certain feature is supported by a contract
*/
contract FeatureIds {
    // converter features
    uint256 public constant CONVERTER_CONVERSION_WHITELIST = 1 << 0;
}

// File: contracts/utility/interfaces/IWhitelist.sol

/*
    Whitelist interface
*/
contract IWhitelist {
    function isWhitelisted(address _address) public view returns (bool);
}

// File: contracts/converter/interfaces/IBancorConverter.sol

/*
    Bancor Converter interface
*/
contract IBancorConverter {
    function getReturn(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount) public view returns (uint256, uint256);
    function convert(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256);
    function conversionWhitelist() public view returns (IWhitelist) {}
    function conversionFee() public view returns (uint32) {}
    function connectors(address _address) public view returns (uint256, uint32, bool, bool, bool) { _address; }
    function getConnectorBalance(IERC20Token _connectorToken) public view returns (uint256);
    function claimTokens(address _from, uint256 _amount) public;
    // deprecated, backward compatibility
    function change(IERC20Token _fromToken, IERC20Token _toToken, uint256 _amount, uint256 _minReturn) public returns (uint256);
}

// File: contracts/converter/interfaces/IBancorFormula.sol

/*
    Bancor Formula interface
*/
contract IBancorFormula {
    function calculatePurchaseReturn(uint256 _supply, uint256 _connectorBalance, uint32 _connectorWeight, uint256 _depositAmount) public view returns (uint256);
    function calculateSaleReturn(uint256 _supply, uint256 _connectorBalance, uint32 _connectorWeight, uint256 _sellAmount) public view returns (uint256);
    function calculateCrossConnectorReturn(uint256 _fromConnectorBalance, uint32 _fromConnectorWeight, uint256 _toConnectorBalance, uint32 _toConnectorWeight, uint256 _amount) public view returns (uint256);
}

// File: contracts/converter/interfaces/IBancorGasPriceLimit.sol

/*
    Bancor Gas Price Limit interface
*/
contract IBancorGasPriceLimit {
    function gasPrice() public view returns (uint256) {}
    function validateGasPrice(uint256) public view;
}

// File: contracts/utility/interfaces/IOwned.sol

/*
    Owned contract interface
*/
contract IOwned {
    // this function isn't abstract since the compiler emits automatically generated getter functions as external
    function owner() public view returns (address) {}

    function transferOwnership(address _newOwner) public;
    function acceptOwnership() public;
}

// File: contracts/utility/Owned.sol

/*
    Provides support and utilities for contract ownership
*/
contract Owned is IOwned {
    address public owner;
    address public newOwner;

    event OwnerUpdate(address indexed _prevOwner, address indexed _newOwner);

    /**
        @dev constructor
    */
    constructor() public {
        owner = msg.sender;
    }

    // allows execution by the owner only
    modifier ownerOnly {
        require(msg.sender == owner);
        _;
    }

    /**
        @dev allows transferring the contract ownership
        the new owner still needs to accept the transfer
        can only be called by the contract owner

        @param _newOwner    new contract owner
    */
    function transferOwnership(address _newOwner) public ownerOnly {
        require(_newOwner != owner);
        newOwner = _newOwner;
    }

    /**
        @dev used by a new owner to accept an ownership transfer
    */
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnerUpdate(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

// File: contracts/utility/Utils.sol

/*
    Utilities & Common Modifiers
*/
contract Utils {
    /**
        constructor
    */
    constructor() public {
    }

    // verifies that an amount is greater than zero
    modifier greaterThanZero(uint256 _amount) {
        require(_amount > 0);
        _;
    }

    // validates an address - currently only checks that it isn't null
    modifier validAddress(address _address) {
        require(_address != address(0));
        _;
    }

    // verifies that the address is different than this contract address
    modifier notThis(address _address) {
        require(_address != address(this));
        _;
    }

}

// File: contracts/utility/interfaces/ITokenHolder.sol

/*
    Token Holder interface
*/
contract ITokenHolder is IOwned {
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public;
}

// File: contracts/token/interfaces/INonStandardERC20.sol

/*
    ERC20 Standard Token interface which doesn't return true/false for transfer, transferFrom and approve
*/
contract INonStandardERC20 {
    // these functions aren't abstract since the compiler emits automatically generated getter functions as external
    function name() public view returns (string) {}
    function symbol() public view returns (string) {}
    function decimals() public view returns (uint8) {}
    function totalSupply() public view returns (uint256) {}
    function balanceOf(address _owner) public view returns (uint256) { _owner; }
    function allowance(address _owner, address _spender) public view returns (uint256) { _owner; _spender; }

    function transfer(address _to, uint256 _value) public;
    function transferFrom(address _from, address _to, uint256 _value) public;
    function approve(address _spender, uint256 _value) public;
}

// File: contracts/utility/TokenHolder.sol

/*
    We consider every contract to be a 'token holder' since it's currently not possible
    for a contract to deny receiving tokens.

    The TokenHolder's contract sole purpose is to provide a safety mechanism that allows
    the owner to send tokens that were sent to the contract by mistake back to their sender.

    Note that we use the non standard ERC-20 interface which has no return value for transfer
    in order to support both non standard as well as standard token contracts.
    see https://github.com/ethereum/solidity/issues/4116
*/
contract TokenHolder is ITokenHolder, Owned, Utils {
    /**
        @dev constructor
    */
    constructor() public {
    }

    /**
        @dev withdraws tokens held by the contract and sends them to an account
        can only be called by the owner

        @param _token   ERC20 token contract address
        @param _to      account to receive the new amount
        @param _amount  amount to withdraw
    */
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount)
        public
        ownerOnly
        validAddress(_token)
        validAddress(_to)
        notThis(_to)
    {
        INonStandardERC20(_token).transfer(_to, _amount);
    }
}

// File: contracts/utility/SafeMath.sol

/*
    Library for basic math operations with overflow/underflow protection
*/
library SafeMath {
    /**
        @dev returns the sum of _x and _y, reverts if the calculation overflows

        @param _x   value 1
        @param _y   value 2

        @return sum
    */
    function add(uint256 _x, uint256 _y) internal pure returns (uint256) {
        uint256 z = _x + _y;
        require(z >= _x);
        return z;
    }

    /**
        @dev returns the difference of _x minus _y, reverts if the calculation underflows

        @param _x   minuend
        @param _y   subtrahend

        @return difference
    */
    function sub(uint256 _x, uint256 _y) internal pure returns (uint256) {
        require(_x >= _y);
        return _x - _y;
    }

    /**
        @dev returns the product of multiplying _x by _y, reverts if the calculation overflows

        @param _x   factor 1
        @param _y   factor 2

        @return product
    */
    function mul(uint256 _x, uint256 _y) internal pure returns (uint256) {
        // gas optimization
        if (_x == 0)
            return 0;

        uint256 z = _x * _y;
        require(z / _x == _y);
        return z;
    }

      /**
        @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

        @param _x   dividend
        @param _y   divisor

        @return quotient
    */
    function div(uint256 _x, uint256 _y) internal pure returns (uint256) {
        require(_y > 0);
        uint256 c = _x / _y;

        return c;
    }
}

// File: contracts/utility/interfaces/IContractRegistry.sol

/*
    Contract Registry interface
*/
contract IContractRegistry {
    function addressOf(bytes32 _contractName) public view returns (address);

    // deprecated, backward compatibility
    function getAddress(bytes32 _contractName) public view returns (address);
}

// File: contracts/utility/interfaces/IContractFeatures.sol

/*
    Contract Features interface
*/
contract IContractFeatures {
    function isSupported(address _contract, uint256 _features) public view returns (bool);
    function enableFeatures(uint256 _features, bool _enable) public;
}

// File: contracts/utility/interfaces/IAddressList.sol

/*
    Address list interface
*/
contract IAddressList {
    mapping (address => bool) public listedAddresses;
}

// File: contracts/token/interfaces/IEtherToken.sol

/*
    Ether Token interface
*/
contract IEtherToken is ITokenHolder, IERC20Token {
    function deposit() public payable;
    function withdraw(uint256 _amount) public;
    function withdrawTo(address _to, uint256 _amount) public;
}

// File: contracts/token/interfaces/ISmartToken.sol

/*
    Smart Token interface
*/
contract ISmartToken is IOwned, IERC20Token {
    function disableTransfers(bool _disable) public;
    function issue(address _to, uint256 _amount) public;
    function destroy(address _from, uint256 _amount) public;
}

// File: contracts/bancorx/interfaces/IBancorX.sol

contract IBancorX {
    function xTransfer(bytes32 _toBlockchain, bytes32 _to, uint256 _amount, uint256 _id) public;
    function getXTransferAmount(uint256 _xTransferId, address _for) public view returns (uint256);
}

// File: contracts/BancorNetwork.sol

/*
    The BancorNetwork contract is the main entry point for bancor token conversions.
    It also allows converting between any token in the bancor network to any other token
    in a single transaction by providing a conversion path.

    A note on conversion path -
    Conversion path is a data structure that's used when converting a token to another token in the bancor network
    when the conversion cannot necessarily be done by single converter and might require multiple 'hops'.
    The path defines which converters should be used and what kind of conversion should be done in each step.

    The path format doesn't include complex structure and instead, it is represented by a single array
    in which each 'hop' is represented by a 2-tuple - smart token & to token.
    In addition, the first element is always the source token.
    The smart token is only used as a pointer to a converter (since converter addresses are more likely to change).

    Format:
    [source token, smart token, to token, smart token, to token...]
*/
contract BancorNetwork is IBancorNetwork, TokenHolder, ContractIds, FeatureIds {
    using SafeMath for uint256;

    
    uint64 private constant MAX_CONVERSION_FEE = 1000000;

    address public signerAddress = 0x0;         // verified address that allows conversions with higher gas price
    IContractRegistry public registry;          // contract registry contract address

    mapping (address => bool) public etherTokens;       // list of all supported ether tokens
    mapping (bytes32 => bool) public conversionHashes;  // list of conversion hashes, to prevent re-use of the same hash

    /**
        @dev constructor

        @param _registry    address of a contract registry contract
    */
    constructor(IContractRegistry _registry) public validAddress(_registry) {
        registry = _registry;
    }

    // validates a conversion path - verifies that the number of elements is odd and that maximum number of 'hops' is 10
    modifier validConversionPath(IERC20Token[] _path) {
        require(_path.length > 2 && _path.length <= (1 + 2 * 10) && _path.length % 2 == 1);
        _;
    }

    /*
        @dev allows the owner to update the contract registry contract address

        @param _registry   address of a contract registry contract
    */
    function setRegistry(IContractRegistry _registry)
        public
        ownerOnly
        validAddress(_registry)
        notThis(_registry)
    {
        registry = _registry;
    }

    /*
        @dev allows the owner to update the signer address

        @param _signerAddress    new signer address
    */
    function setSignerAddress(address _signerAddress)
        public
        ownerOnly
        validAddress(_signerAddress)
        notThis(_signerAddress)
    {
        signerAddress = _signerAddress;
    }

    /**
        @dev allows the owner to register/unregister ether tokens

        @param _token       ether token contract address
        @param _register    true to register, false to unregister
    */
    function registerEtherToken(IEtherToken _token, bool _register)
        public
        ownerOnly
        validAddress(_token)
        notThis(_token)
    {
        etherTokens[_token] = _register;
    }

    /**
        @dev verifies that the signer address is trusted by recovering 
        the address associated with the public key from elliptic 
        curve signature, returns zero on error.
        notice that the signature is valid only for one conversion
        and expires after the give block.

        @return true if the signer is verified
    */
    function verifyTrustedSender(IERC20Token[] _path, uint256 _customVal, uint256 _block, address _addr, uint8 _v, bytes32 _r, bytes32 _s) private returns(bool) {
        bytes32 hash = keccak256(_block, tx.gasprice, _addr, msg.sender, _customVal, _path);

        // checking that it is the first conversion with the given signature
        // and that the current block number doesn't exceeded the maximum block
        // number that's allowed with the current signature
        require(!conversionHashes[hash] && block.number <= _block);

        // recovering the signing address and comparing it to the trusted signer
        // address that was set in the contract
        bytes32 prefixedHash = keccak256("\x19Ethereum Signed Message:\n32", hash);
        bool verified = ecrecover(prefixedHash, _v, _r, _s) == signerAddress;

        // if the signer is the trusted signer - mark the hash so that it can't
        // be used multiple times
        if (verified)
            conversionHashes[hash] = true;
        return verified;
    }

    /**
        @dev validates xConvert call by verifying the path format, claiming the callers tokens (if not ETH),
        and verifying the gas price limit

        @param _path        conversion path, see conversion path format above
        @param _amount      amount to convert from (in the initial source token)
        @param _block       if the current block exceeded the given parameter - it is cancelled
        @param _v           (signature[128:130]) associated with the signer address and helps to validate if the signature is legit
        @param _r           (signature[0:64]) associated with the signer address and helps to validate if the signature is legit
        @param _s           (signature[64:128]) associated with the signer address and helps to validate if the signature is legit
    */
    function validateXConversion(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _block,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) 
        private 
        validConversionPath(_path)    
    {
        // if ETH is provided, ensure that the amount is identical to _amount and verify that the source token is an ether token
        IERC20Token fromToken = _path[0];
        require(msg.value == 0 || (_amount == msg.value && etherTokens[fromToken]));

        // require that the dest token is BNT
        require(_path[_path.length - 1] == registry.addressOf(ContractIds.BNT_TOKEN));

        // if ETH was sent with the call, the source is an ether token - deposit the ETH in it
        // otherwise, we claim the tokens from the sender
        if (msg.value > 0) {
            IEtherToken(fromToken).deposit.value(msg.value)();
        } else {
            ensureTransferFrom(fromToken, msg.sender, this, _amount);
        }

        // verify gas price limit
        if (_v == 0x0 && _r == 0x0 && _s == 0x0) {
            IBancorGasPriceLimit gasPriceLimit = IBancorGasPriceLimit(registry.addressOf(ContractIds.BANCOR_GAS_PRICE_LIMIT));
            gasPriceLimit.validateGasPrice(tx.gasprice);
        } else {
            require(verifyTrustedSender(_path, _amount, _block, msg.sender, _v, _r, _s));
        }
    }

    /**
        @dev converts the token to any other token in the bancor network by following
        a predefined conversion path and transfers the result tokens to a target account
        note that the converter should already own the source tokens

        @param _path        conversion path, see conversion path format above
        @param _amount      amount to convert from (in the initial source token)
        @param _minReturn   if the conversion results in an amount smaller than the minimum return - it is cancelled, must be nonzero
        @param _for         account that will receive the conversion result

        @return tokens issued in return
    */
    function convertFor(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, address _for) public payable returns (uint256) {
        return convertForPrioritized3(_path, _amount, _minReturn, _for, _amount, 0x0, 0x0, 0x0, 0x0);
    }

    /**
        @dev converts the token to any other token in the bancor network
        by following a predefined conversion path and transfers the result
        tokens to a target account.
        this version of the function also allows the verified signer
        to bypass the universal gas price limit.
        note that the converter should already own the source tokens

        @param _path        conversion path, see conversion path format above
        @param _amount      amount to convert from (in the initial source token)
        @param _minReturn   if the conversion results in an amount smaller than the minimum return - it is cancelled, must be nonzero
        @param _for         account that will receive the conversion result
        @param _customVal   custom value that was signed for prioritized conversion
        @param _block       if the current block exceeded the given parameter - it is cancelled
        @param _v           (signature[128:130]) associated with the signer address and helps to validate if the signature is legit
        @param _r           (signature[0:64]) associated with the signer address and helps to validate if the signature is legit
        @param _s           (signature[64:128]) associated with the signer address and helps to validate if the signature is legit

        @return tokens issued in return
    */
    function convertForPrioritized3(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        uint256 _customVal,
        uint256 _block,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        public
        payable
        returns (uint256)
    {
        // if ETH is provided, ensure that the amount is identical to _amount and verify that the source token is an ether token
        IERC20Token fromToken = _path[0];
        require(msg.value == 0 || (_amount == msg.value && etherTokens[fromToken]));

        // if ETH was sent with the call, the source is an ether token - deposit the ETH in it
        // otherwise, we assume we already have the tokens
        if (msg.value > 0)
            IEtherToken(fromToken).deposit.value(msg.value)();

        return convertForInternal(_path, _amount, _minReturn, _for, _customVal, _block, _v, _r, _s);
    }

    /**
        @dev converts any other token to BNT in the bancor network
        by following a predefined conversion path and transfers the resulting
        tokens to BancorX.
        note that the network should already have been given allowance of the source token (if not ETH)

        @param _path             conversion path, see conversion path format above
        @param _amount           amount to convert from (in the initial source token)
        @param _minReturn        if the conversion results in an amount smaller than the minimum return - it is cancelled, must be nonzero
        @param _toBlockchain     blockchain BNT will be issued on
        @param _to               address/account on _toBlockchain to send the BNT to
        @param _conversionId     pre-determined unique (if non zero) id which refers to this transaction 

        @return the amount of BNT received from this conversion
    */
    function xConvert(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        bytes32 _toBlockchain,
        bytes32 _to,
        uint256 _conversionId
    )
        public
        payable
        returns (uint256)
    {
        return xConvertPrioritized(_path, _amount, _minReturn, _toBlockchain, _to, _conversionId, 0x0, 0x0, 0x0, 0x0);
    }

    /**
        @dev converts any other token to BNT in the bancor network
        by following a predefined conversion path and transfers the resulting
        tokens to BancorX.
        this version of the function also allows the verified signer
        to bypass the universal gas price limit.
        note that the network should already have been given allowance of the source token (if not ETH)

        @param _path            conversion path, see conversion path format above
        @param _amount          amount to convert from (in the initial source token)
        @param _minReturn       if the conversion results in an amount smaller than the minimum return - it is cancelled, must be nonzero
        @param _toBlockchain    blockchain BNT will be issued on
        @param _to              address/account on _toBlockchain to send the BNT to
        @param _conversionId    pre-determined unique (if non zero) id which refers to this transaction 
        @param _block           if the current block exceeded the given parameter - it is cancelled
        @param _v               (signature[128:130]) associated with the signer address and helps to validate if the signature is legit
        @param _r               (signature[0:64]) associated with the signer address and helps to validate if the signature is legit
        @param _s               (signature[64:128]) associated with the signer address and helps to validate if the signature is legit

        @return the amount of BNT received from this conversion
    */
    function xConvertPrioritized(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        bytes32 _toBlockchain,
        bytes32 _to,
        uint256 _conversionId,
        uint256 _block,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        public
        payable
        returns (uint256)
    {
        // do a lot of validation and transfers in separate function to work around 16 variable limit
        validateXConversion(_path, _amount, _block, _v, _r, _s);

        // convert to BNT and get the resulting amount
        (, uint256 retAmount) = convertByPath(_path, _amount, _minReturn, _path[0], this);

        // transfer the resulting amount to BancorX, and return the amount
        IBancorX(registry.addressOf(ContractIds.BANCOR_X)).xTransfer(_toBlockchain, _to, retAmount, _conversionId);

        return retAmount;
    }

    /**
        @dev converts token to any other token in the bancor network
        by following a predefined conversion paths and transfers the result
        tokens to a target account.

        @param _path        conversion path, see conversion path format above
        @param _amount      amount to convert from (in the initial source token)
        @param _minReturn   if the conversion results in an amount smaller than the minimum return - it is cancelled, must be nonzero
        @param _for         account that will receive the conversion result
        @param _block       if the current block exceeded the given parameter - it is cancelled
        @param _v           (signature[128:130]) associated with the signer address and helps to validate if the signature is legit
        @param _r           (signature[0:64]) associated with the signer address and helps to validate if the signature is legit
        @param _s           (signature[64:128]) associated with the signer address and helps to validate if the signature is legit

        @return tokens issued in return
    */
    function convertForInternal(
        IERC20Token[] _path, 
        uint256 _amount, 
        uint256 _minReturn, 
        address _for, 
        uint256 _customVal,
        uint256 _block,
        uint8 _v, 
        bytes32 _r, 
        bytes32 _s
    )
        private
        validConversionPath(_path)
        returns (uint256)
    {
        if (_v == 0x0 && _r == 0x0 && _s == 0x0) {
            IBancorGasPriceLimit gasPriceLimit = IBancorGasPriceLimit(registry.addressOf(ContractIds.BANCOR_GAS_PRICE_LIMIT));
            gasPriceLimit.validateGasPrice(tx.gasprice);
        }
        else {
            require(verifyTrustedSender(_path, _customVal, _block, _for, _v, _r, _s));
        }

        // if ETH is provided, ensure that the amount is identical to _amount and verify that the source token is an ether token
        IERC20Token fromToken = _path[0];

        IERC20Token toToken;
        
        (toToken, _amount) = convertByPath(_path, _amount, _minReturn, fromToken, _for);

        // finished the conversion, transfer the funds to the target account
        // if the target token is an ether token, withdraw the tokens and send them as ETH
        // otherwise, transfer the tokens as is
        if (etherTokens[toToken])
            IEtherToken(toToken).withdrawTo(_for, _amount);
        else
            ensureTransfer(toToken, _for, _amount);

        return _amount;
    }

    /**
        @dev executes the actual conversion by following the conversion path

        @param _path        conversion path, see conversion path format above
        @param _amount      amount to convert from (in the initial source token)
        @param _minReturn   if the conversion results in an amount smaller than the minimum return - it is cancelled, must be nonzero
        @param _fromToken   ERC20 token to convert from (the first element in the path)
        @param _for         account that will receive the conversion result

        @return ERC20 token to convert to (the last element in the path) & tokens issued in return
    */
    function convertByPath(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        IERC20Token _fromToken,
        address _for
    ) private returns (IERC20Token, uint256) {
        ISmartToken smartToken;
        IERC20Token toToken;
        IBancorConverter converter;

        // get the contract features address from the registry
        IContractFeatures features = IContractFeatures(registry.addressOf(ContractIds.CONTRACT_FEATURES));

        // iterate over the conversion path
        uint256 pathLength = _path.length;
        for (uint256 i = 1; i < pathLength; i += 2) {
            smartToken = ISmartToken(_path[i]);
            toToken = _path[i + 1];
            converter = IBancorConverter(smartToken.owner());
            checkWhitelist(converter, _for, features);

            // if the smart token isn't the source (from token), the converter doesn't have control over it and thus we need to approve the request
            if (smartToken != _fromToken)
                ensureAllowance(_fromToken, converter, _amount);

            // make the conversion - if it's the last one, also provide the minimum return value
            _amount = converter.change(_fromToken, toToken, _amount, i == pathLength - 2 ? _minReturn : 1);
            _fromToken = toToken;
        }
        return (toToken, _amount);
    }

    /**
        @dev returns the expected return amount for converting a specific amount by following
        a given conversion path.
        notice that there is no support for circular paths.

        @param _path        conversion path, see conversion path format above
        @param _amount      amount to convert from (in the initial source token)

        @return expected conversion return amount and conversion fee
    */
    function getReturnByPath(IERC20Token[] _path, uint256 _amount) public returns (uint256, uint256) {
        IERC20Token fromToken;
        ISmartToken smartToken; 
        IERC20Token toToken;
        IBancorConverter converter;
        uint256 amount;
        uint256 fee;
        uint256 supply;
        uint256 balance;
        uint32 weight;
        ISmartToken prevSmartToken;
        IBancorFormula formula = IBancorFormula(registry.getAddress(ContractIds.BANCOR_FORMULA));

        amount = _amount;
        fromToken = _path[0];

        // iterate over the conversion path
        for (uint256 i = 1; i < _path.length; i += 2) {
            smartToken = ISmartToken(_path[i]);
            toToken = _path[i + 1];
            converter = IBancorConverter(smartToken.owner());

            if (toToken == smartToken) { // buy the smart token
                // check if the current smart token supply was changed in the previous iteration
                supply = smartToken == prevSmartToken ? supply : smartToken.totalSupply();

                // validate input
                require(getConnectorSaleEnabled(converter, fromToken));

                // calculate the amount & the conversion fee
                balance = converter.getConnectorBalance(fromToken);
                weight = getConnectorWeight(converter, fromToken);
                amount = formula.calculatePurchaseReturn(supply, balance, weight, amount);
                fee = amount.mul(converter.conversionFee()).div(MAX_CONVERSION_FEE);
                amount -= fee;

                // update the smart token supply for the next iteration
                supply = smartToken.totalSupply() + amount;
            }
            else if (fromToken == smartToken) { // sell the smart token
                // check if the current smart token supply was changed in the previous iteration
                supply = smartToken == prevSmartToken ? supply : smartToken.totalSupply();

                // calculate the amount & the conversion fee
                balance = converter.getConnectorBalance(toToken);
                weight = getConnectorWeight(converter, toToken);
                amount = formula.calculateSaleReturn(supply, balance, weight, amount);
                fee = amount.mul(converter.conversionFee()).div(MAX_CONVERSION_FEE);
                amount -= fee;

                // update the smart token supply for the next iteration
                supply = smartToken.totalSupply() - amount;
            }
            else { // cross connector conversion
                (amount, fee) = converter.getReturn(fromToken, toToken, amount);
            }

            prevSmartToken = smartToken;
            fromToken = toToken;
        }

        return (amount, fee);
    }

    /**
        @dev checks whether the given converter supports a whitelist and if so, ensures that
        the account that should receive the conversion result is actually whitelisted

        @param _converter   converter to check for whitelist
        @param _for         account that will receive the conversion result
        @param _features    contract features contract address
    */
    function checkWhitelist(IBancorConverter _converter, address _for, IContractFeatures _features) private view {
        IWhitelist whitelist;

        // check if the converter supports the conversion whitelist feature
        if (!_features.isSupported(_converter, FeatureIds.CONVERTER_CONVERSION_WHITELIST))
            return;

        // get the whitelist contract from the converter
        whitelist = _converter.conversionWhitelist();
        if (whitelist == address(0))
            return;

        // check if the account that should receive the conversion result is actually whitelisted
        require(whitelist.isWhitelisted(_for));
    }

    /**
        @dev claims the caller's tokens, converts them to any other token in the bancor network
        by following a predefined conversion path and transfers the result tokens to a target account
        note that allowance must be set beforehand

        @param _path        conversion path, see conversion path format above
        @param _amount      amount to convert from (in the initial source token)
        @param _minReturn   if the conversion results in an amount smaller than the minimum return - it is cancelled, must be nonzero
        @param _for         account that will receive the conversion result

        @return tokens issued in return
    */
    function claimAndConvertFor(IERC20Token[] _path, uint256 _amount, uint256 _minReturn, address _for) public returns (uint256) {
        // we need to transfer the tokens from the caller to the converter before we follow
        // the conversion path, to allow it to execute the conversion on behalf of the caller
        // note: we assume we already have allowance
        IERC20Token fromToken = _path[0];
        ensureTransferFrom(fromToken, msg.sender, this, _amount);
        return convertFor(_path, _amount, _minReturn, _for);
    }

    /**
        @dev converts the token to any other token in the bancor network by following
        a predefined conversion path and transfers the result tokens back to the sender
        note that the converter should already own the source tokens

        @param _path        conversion path, see conversion path format above
        @param _amount      amount to convert from (in the initial source token)
        @param _minReturn   if the conversion results in an amount smaller than the minimum return - it is cancelled, must be nonzero

        @return tokens issued in return
    */
    function convert(IERC20Token[] _path, uint256 _amount, uint256 _minReturn) public payable returns (uint256) {
        return convertFor(_path, _amount, _minReturn, msg.sender);
    }

    /**
        @dev claims the caller's tokens, converts them to any other token in the bancor network
        by following a predefined conversion path and transfers the result tokens back to the sender
        note that allowance must be set beforehand

        @param _path        conversion path, see conversion path format above
        @param _amount      amount to convert from (in the initial source token)
        @param _minReturn   if the conversion results in an amount smaller than the minimum return - it is cancelled, must be nonzero

        @return tokens issued in return
    */
    function claimAndConvert(IERC20Token[] _path, uint256 _amount, uint256 _minReturn) public returns (uint256) {
        return claimAndConvertFor(_path, _amount, _minReturn, msg.sender);
    }

    /**
        @dev ensures transfer of tokens, taking into account that some ERC-20 implementations don't return
        true on success but revert on failure instead

        @param _token     the token to transfer
        @param _to        the address to transfer the tokens to
        @param _amount    the amount to transfer
    */
    function ensureTransfer(IERC20Token _token, address _to, uint256 _amount) private {
        IAddressList addressList = IAddressList(registry.addressOf(ContractIds.NON_STANDARD_TOKEN_REGISTRY));

        if (addressList.listedAddresses(_token)) {
            uint256 prevBalance = _token.balanceOf(_to);
            // we have to cast the token contract in an interface which has no return value
            INonStandardERC20(_token).transfer(_to, _amount);
            uint256 postBalance = _token.balanceOf(_to);
            assert(postBalance > prevBalance);
        } else {
            // if the token isn't whitelisted, we assert on transfer
            assert(_token.transfer(_to, _amount));
        }
    }

    /**
        @dev ensures transfer of tokens, taking into account that some ERC-20 implementations don't return
        true on success but revert on failure instead

        @param _token     the token to transfer
        @param _from      the address to transfer the tokens from
        @param _to        the address to transfer the tokens to
        @param _amount    the amount to transfer
    */
    function ensureTransferFrom(IERC20Token _token, address _from, address _to, uint256 _amount) private {
        IAddressList addressList = IAddressList(registry.addressOf(ContractIds.NON_STANDARD_TOKEN_REGISTRY));

        if (addressList.listedAddresses(_token)) {
            uint256 prevBalance = _token.balanceOf(_to);
            // we have to cast the token contract in an interface which has no return value
            INonStandardERC20(_token).transferFrom(_from, _to, _amount);
            uint256 postBalance = _token.balanceOf(_to);
            assert(postBalance > prevBalance);
        } else {
            // if the token isn't whitelisted, we assert on transfer
            assert(_token.transferFrom(_from, _to, _amount));
        }
    }

    /**
        @dev utility, checks whether allowance for the given spender exists and approves one if it doesn't.
        Note that we use the non standard erc-20 interface in which `approve` has no return value so that
        this function will work for both standard and non standard tokens

        @param _token   token to check the allowance in
        @param _spender approved address
        @param _value   allowance amount
    */
    function ensureAllowance(IERC20Token _token, address _spender, uint256 _value) private {
        // check if allowance for the given amount already exists
        if (_token.allowance(this, _spender) >= _value)
            return;

        // if the allowance is nonzero, must reset it to 0 first
        if (_token.allowance(this, _spender) != 0)
            INonStandardERC20(_token).approve(_spender, 0);

        // approve the new allowance
        INonStandardERC20(_token).approve(_spender, _value);
    }

    /**
        @dev returns the connector weight

        @param _converter       converter contract address
        @param _connector       connector's address to read from

        @return connector's weight
    */
    function getConnectorWeight(IBancorConverter _converter, IERC20Token _connector) 
        private
        view
        returns(uint32)
    {
        uint256 virtualBalance;
        uint32 weight;
        bool isVirtualBalanceEnabled;
        bool isSaleEnabled;
        bool isSet;
        (virtualBalance, weight, isVirtualBalanceEnabled, isSaleEnabled, isSet) = _converter.connectors(_connector);
        return weight;
    }

    /**
        @dev returns true if connector sale is enabled

        @param _converter       converter contract address
        @param _connector       connector's address to read from

        @return true if connector sale is enabled, otherwise - false
    */
    function getConnectorSaleEnabled(IBancorConverter _converter, IERC20Token _connector) 
        private
        view
        returns(bool)
    {
        uint256 virtualBalance;
        uint32 weight;
        bool isVirtualBalanceEnabled;
        bool isSaleEnabled;
        bool isSet;
        (virtualBalance, weight, isVirtualBalanceEnabled, isSaleEnabled, isSet) = _converter.connectors(_connector);
        return isSaleEnabled;
    }

    // deprecated, backward compatibility
    function convertForPrioritized2(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        uint256 _block,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )
        public
        payable
        returns (uint256)
    {
        return convertForPrioritized3(_path, _amount, _minReturn, _for, _amount, _block, _v, _r, _s);
    }

    // deprecated, backward compatibility
    function convertForPrioritized(
        IERC20Token[] _path,
        uint256 _amount,
        uint256 _minReturn,
        address _for,
        uint256 _block,
        uint256 _nonce,
        uint8 _v,
        bytes32 _r,
        bytes32 _s)
        public payable returns (uint256)
    {
        _nonce;
        return convertForPrioritized3(_path, _amount, _minReturn, _for, _amount, _block, _v, _r, _s);
    }
}

contract MyBancorNetwork is ContractIds {
    
    using SafeMath for uint256;
    
    BancorNetwork bancor = BancorNetwork(0x6690819Cb98c1211A8e38790d6cD48316Ed518Db);
    uint64 private constant MAX_CONVERSION_FEE = 1000000;

    /**
        @dev returns the expected return amount for converting a specific amount by following
        a given conversion path.
        notice that there is no support for circular paths.

        @param _path        conversion path, see conversion path format above
        @param _amount      amount to convert from (in the initial source token)

        @return expected conversion return amount and conversion fee
    */
    function getReturnByPath(IERC20Token[] _path, uint256 _amount) public view returns (uint256, uint256) {
        IERC20Token fromToken;
        ISmartToken smartToken; 
        IERC20Token toToken;
        IBancorConverter converter;
        uint256 amount;
        uint256 fee;
        uint256 supply;
        uint256 balance;
        uint32 weight;
        ISmartToken prevSmartToken;
        IBancorFormula formula = IBancorFormula(bancor.registry().getAddress(ContractIds.BANCOR_FORMULA));

        amount = _amount;
        fromToken = _path[0];

        // iterate over the conversion path
        for (uint256 i = 1; i < _path.length; i += 2) {
            smartToken = ISmartToken(_path[i]);
            toToken = _path[i + 1];
            converter = IBancorConverter(smartToken.owner());

            if (toToken == smartToken) { // buy the smart token
                // check if the current smart token supply was changed in the previous iteration
                supply = smartToken == prevSmartToken ? supply : smartToken.totalSupply();

                // validate input
                require(getConnectorSaleEnabled(converter, fromToken));

                // calculate the amount & the conversion fee
                balance = converter.getConnectorBalance(fromToken);
                weight = getConnectorWeight(converter, fromToken);
                amount = formula.calculatePurchaseReturn(supply, balance, weight, amount);
                fee = amount.mul(converter.conversionFee()).div(MAX_CONVERSION_FEE);
                amount -= fee;

                // update the smart token supply for the next iteration
                supply = smartToken.totalSupply() + amount;
            }
            else if (fromToken == smartToken) { // sell the smart token
                // check if the current smart token supply was changed in the previous iteration
                supply = smartToken == prevSmartToken ? supply : smartToken.totalSupply();

                // calculate the amount & the conversion fee
                balance = converter.getConnectorBalance(toToken);
                weight = getConnectorWeight(converter, toToken);
                amount = formula.calculateSaleReturn(supply, balance, weight, amount);
                fee = amount.mul(converter.conversionFee()).div(MAX_CONVERSION_FEE);
                amount -= fee;

                // update the smart token supply for the next iteration
                supply = smartToken.totalSupply() - amount;
            }
            else { // cross connector conversion
                (amount, fee) = fixGetReturn(
                    converter,
                    abi.encodeWithSelector(
                        converter.getReturn.selector,
                        fromToken,
                        toToken,
                        amount
                    )
                );
            }

            prevSmartToken = smartToken;
            fromToken = toToken;
        }

        return (amount, fee);
    }
    
    function fixGetReturn(address destination, bytes data) internal returns(uint256 amount, uint256 fee) {
        bytes memory ret = new bytes(64);
        bool success;
        assembly {
            success := call(
                sub(gas, 34710),
                destination,
                0,
                add(data, 32),
                mload(data),
                add(ret, 32),
                64
            )
        }
        
        if (success) {
            assembly {
                amount := mload(add(ret, 32))
                fee := mload(add(ret, 64))
            }
        }
    }
    
    /**
        @dev returns true if connector sale is enabled

        @param _converter       converter contract address
        @param _connector       connector's address to read from

        @return true if connector sale is enabled, otherwise - false
    */
    function getConnectorSaleEnabled(IBancorConverter _converter, IERC20Token _connector) 
        private
        view
        returns(bool)
    {
        uint256 virtualBalance;
        uint32 weight;
        bool isVirtualBalanceEnabled;
        bool isSaleEnabled;
        bool isSet;
        (virtualBalance, weight, isVirtualBalanceEnabled, isSaleEnabled, isSet) = _converter.connectors(_connector);
        return isSaleEnabled;
    }
    
    /**
        @dev returns the connector weight

        @param _converter       converter contract address
        @param _connector       connector's address to read from

        @return connector's weight
    */
    function getConnectorWeight(IBancorConverter _converter, IERC20Token _connector) 
        private
        view
        returns(uint32)
    {
        uint256 virtualBalance;
        uint32 weight;
        bool isVirtualBalanceEnabled;
        bool isSaleEnabled;
        bool isSet;
        (virtualBalance, weight, isVirtualBalanceEnabled, isSaleEnabled, isSet) = _converter.connectors(_connector);
        return weight;
    }
}