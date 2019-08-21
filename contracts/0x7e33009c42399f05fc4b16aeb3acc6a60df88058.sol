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

// File: contracts/converter/interfaces/IBancorConverterUpgrader.sol

/*
    Bancor Converter Upgrader interface
*/
contract IBancorConverterUpgrader {
    function upgrade(bytes32 _version) public;
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

// File: contracts/token/interfaces/ISmartToken.sol

/*
    Smart Token interface
*/
contract ISmartToken is IOwned, IERC20Token {
    function disableTransfers(bool _disable) public;
    function issue(address _to, uint256 _amount) public;
    function destroy(address _from, uint256 _amount) public;
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

// File: contracts/converter/interfaces/IBancorConverterFactory.sol

/*
    Bancor Converter Factory interface
*/
contract IBancorConverterFactory {
    function createConverter(
        ISmartToken _token,
        IContractRegistry _registry,
        uint32 _maxConversionFee,
        IERC20Token _connectorToken,
        uint32 _connectorWeight
    )
    public returns (address);
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

// File: contracts/utility/interfaces/IContractFeatures.sol

/*
    Contract Features interface
*/
contract IContractFeatures {
    function isSupported(address _contract, uint256 _features) public view returns (bool);
    function enableFeatures(uint256 _features, bool _enable) public;
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

    // bancor logic
    bytes32 public constant BANCOR_NETWORK = "BancorNetwork";
    bytes32 public constant BANCOR_FORMULA = "BancorFormula";
    bytes32 public constant BANCOR_GAS_PRICE_LIMIT = "BancorGasPriceLimit";
    bytes32 public constant BANCOR_CONVERTER_UPGRADER = "BancorConverterUpgrader";
    bytes32 public constant BANCOR_CONVERTER_FACTORY = "BancorConverterFactory";

    // Ids of BNT converter and BNT token
    bytes32 public constant BNT_TOKEN = "BNTToken";
    bytes32 public constant BNT_CONVERTER = "BNTConverter";

    // Id of BancorX contract
    bytes32 public constant BANCOR_X = "BancorX";
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

// File: contracts/converter/BancorConverterUpgrader.sol

/*
    Bancor converter dedicated interface
*/
contract IBancorConverterExtended is IBancorConverter, IOwned {
    function token() public view returns (ISmartToken) {}
    function maxConversionFee() public view returns (uint32) {}
    function conversionFee() public view returns (uint32) {}
    function connectorTokenCount() public view returns (uint16);
    function reserveTokenCount() public view returns (uint16);
    function connectorTokens(uint256 _index) public view returns (IERC20Token) { _index; }
    function reserveTokens(uint256 _index) public view returns (IERC20Token) { _index; }
    function setConversionWhitelist(IWhitelist _whitelist) public;
    function transferTokenOwnership(address _newOwner) public;
    function withdrawTokens(IERC20Token _token, address _to, uint256 _amount) public;
    function acceptTokenOwnership() public;
    function transferManagement(address _newManager) public;
    function acceptManagement() public;
    function setConversionFee(uint32 _conversionFee) public;
    function addConnector(IERC20Token _token, uint32 _weight, bool _enableVirtualBalance) public;
    function updateConnector(IERC20Token _connectorToken, uint32 _weight, bool _enableVirtualBalance, uint256 _virtualBalance) public;
    function getConnectorBalance(IERC20Token _connectorToken) public view returns (uint256);
    function getReserveBalance(IERC20Token _reserveToken) public view returns (uint256);
    function reserves(address _address) public view returns (
        uint256 virtualBalance, 
        uint32 weight, 
        bool isVirtualBalanceEnabled, 
        bool isPurchaseEnabled, 
        bool isSet
    );
}

/*
    Bancor Converter Upgrader

    The Bancor converter upgrader contract allows upgrading an older Bancor converter
    contract (0.4 and up) to the latest version.
    To begin the upgrade process, first transfer the converter ownership to the upgrader
    contract and then call the upgrade function.
    At the end of the process, the ownership of the newly upgraded converter will be transferred
    back to the original owner.
    The address of the new converter is available in the ConverterUpgrade event.
*/
contract BancorConverterUpgrader is IBancorConverterUpgrader, Owned, ContractIds, FeatureIds {
    string public version = '0.3';

    IContractRegistry public registry;                      // contract registry contract address

    // triggered when the contract accept a converter ownership
    event ConverterOwned(address indexed _converter, address indexed _owner);
    // triggered when the upgrading process is done
    event ConverterUpgrade(address indexed _oldConverter, address indexed _newConverter);

    /**
        @dev constructor
    */
    constructor(IContractRegistry _registry) public {
        registry = _registry;
    }

    /*
        @dev allows the owner to update the contract registry contract address

        @param _registry   address of a contract registry contract
    */
    function setRegistry(IContractRegistry _registry) public ownerOnly {
        registry = _registry;
    }

    /**
        @dev upgrades an old converter to the latest version
        will throw if ownership wasn't transferred to the upgrader before calling this function.
        ownership of the new converter will be transferred back to the original owner.
        fires the ConverterUpgrade event upon success.
        can only be called by a converter

        @param _version old converter version
    */
    function upgrade(bytes32 _version) public {
        upgradeOld(IBancorConverter(msg.sender), _version);
    }

    /**
        @dev upgrades an old converter to the latest version
        will throw if ownership wasn't transferred to the upgrader before calling this function.
        ownership of the new converter will be transferred back to the original owner.
        fires the ConverterUpgrade event upon success.

        @param _converter   old converter contract address
        @param _version     old converter version
    */
    function upgradeOld(IBancorConverter _converter, bytes32 _version) public {
        bool formerVersions = false;
        if (_version == "0.4")
            formerVersions = true;
        IBancorConverterExtended converter = IBancorConverterExtended(_converter);
        address prevOwner = converter.owner();
        acceptConverterOwnership(converter);
        IBancorConverterExtended newConverter = createConverter(converter);
        copyConnectors(converter, newConverter, formerVersions);
        copyConversionFee(converter, newConverter);
        transferConnectorsBalances(converter, newConverter, formerVersions);                
        ISmartToken token = converter.token();

        if (token.owner() == address(converter)) {
            converter.transferTokenOwnership(newConverter);
            newConverter.acceptTokenOwnership();
        }

        converter.transferOwnership(prevOwner);
        newConverter.transferOwnership(prevOwner);
        newConverter.transferManagement(prevOwner);

        emit ConverterUpgrade(address(converter), address(newConverter));
    }

    /**
        @dev the first step when upgrading a converter is to transfer the ownership to the local contract.
        the upgrader contract then needs to accept the ownership transfer before initiating
        the upgrade process.
        fires the ConverterOwned event upon success

        @param _oldConverter       converter to accept ownership of
    */
    function acceptConverterOwnership(IBancorConverterExtended _oldConverter) private {
        _oldConverter.acceptOwnership();
        emit ConverterOwned(_oldConverter, this);
    }

    /**
        @dev creates a new converter with same basic data as the original old converter
        the newly created converter will have no connectors at this step.

        @param _oldConverter    old converter contract address

        @return the new converter  new converter contract address
    */
    function createConverter(IBancorConverterExtended _oldConverter) private returns(IBancorConverterExtended) {
        IWhitelist whitelist;
        ISmartToken token = _oldConverter.token();
        uint32 maxConversionFee = _oldConverter.maxConversionFee();

        IBancorConverterFactory converterFactory = IBancorConverterFactory(registry.addressOf(ContractIds.BANCOR_CONVERTER_FACTORY));
        address converterAddress  = converterFactory.createConverter(
            token,
            registry,
            maxConversionFee,
            IERC20Token(address(0)),
            0
        );

        IBancorConverterExtended converter = IBancorConverterExtended(converterAddress);
        converter.acceptOwnership();
        converter.acceptManagement();

        // get the contract features address from the registry
        IContractFeatures features = IContractFeatures(registry.addressOf(ContractIds.CONTRACT_FEATURES));

        if (features.isSupported(_oldConverter, FeatureIds.CONVERTER_CONVERSION_WHITELIST)) {
            whitelist = _oldConverter.conversionWhitelist();
            if (whitelist != address(0))
                converter.setConversionWhitelist(whitelist);
        }

        return converter;
    }

    /**
        @dev copies the connectors from the old converter to the new one.
        note that this will not work for an unlimited number of connectors due to block gas limit constraints.

        @param _oldConverter    old converter contract address
        @param _newConverter    new converter contract address
        @param _isLegacyVersion true if the converter version is under 0.5
    */
    function copyConnectors(IBancorConverterExtended _oldConverter, IBancorConverterExtended _newConverter, bool _isLegacyVersion)
        private
    {
        uint256 virtualBalance;
        uint32 weight;
        bool isVirtualBalanceEnabled;
        bool isPurchaseEnabled;
        bool isSet;
        uint16 connectorTokenCount = _isLegacyVersion ? _oldConverter.reserveTokenCount() : _oldConverter.connectorTokenCount();

        for (uint16 i = 0; i < connectorTokenCount; i++) {
            address connectorAddress = _isLegacyVersion ? _oldConverter.reserveTokens(i) : _oldConverter.connectorTokens(i);
            (virtualBalance, weight, isVirtualBalanceEnabled, isPurchaseEnabled, isSet) = readConnector(
                _oldConverter,
                connectorAddress,
                _isLegacyVersion
            );

            IERC20Token connectorToken = IERC20Token(connectorAddress);
            _newConverter.addConnector(connectorToken, weight, isVirtualBalanceEnabled);

            if (isVirtualBalanceEnabled)
                _newConverter.updateConnector(connectorToken, weight, isVirtualBalanceEnabled, virtualBalance);
        }
    }

    /**
        @dev copies the conversion fee from the old converter to the new one

        @param _oldConverter    old converter contract address
        @param _newConverter    new converter contract address
    */
    function copyConversionFee(IBancorConverterExtended _oldConverter, IBancorConverterExtended _newConverter) private {
        uint32 conversionFee = _oldConverter.conversionFee();
        _newConverter.setConversionFee(conversionFee);
    }

    /**
        @dev transfers the balance of each connector in the old converter to the new one.
        note that the function assumes that the new converter already has the exact same number of
        also, this will not work for an unlimited number of connectors due to block gas limit constraints.

        @param _oldConverter    old converter contract address
        @param _newConverter    new converter contract address
        @param _isLegacyVersion true if the converter version is under 0.5
    */
    function transferConnectorsBalances(IBancorConverterExtended _oldConverter, IBancorConverterExtended _newConverter, bool _isLegacyVersion)
        private
    {
        uint256 connectorBalance;
        uint16 connectorTokenCount = _isLegacyVersion ? _oldConverter.reserveTokenCount() : _oldConverter.connectorTokenCount();

        for (uint16 i = 0; i < connectorTokenCount; i++) {
            address connectorAddress = _isLegacyVersion ? _oldConverter.reserveTokens(i) : _oldConverter.connectorTokens(i);
            IERC20Token connector = IERC20Token(connectorAddress);
            connectorBalance = connector.balanceOf(_oldConverter);
            _oldConverter.withdrawTokens(connector, address(_newConverter), connectorBalance);
        }
    }

    /**
        @dev returns the connector settings

        @param _converter       old converter contract address
        @param _address         connector's address to read from
        @param _isLegacyVersion true if the converter version is under 0.5

        @return connector's settings
    */
    function readConnector(IBancorConverterExtended _converter, address _address, bool _isLegacyVersion) 
        private
        view
        returns(uint256 virtualBalance, uint32 weight, bool isVirtualBalanceEnabled, bool isPurchaseEnabled, bool isSet)
    {
        return _isLegacyVersion ? _converter.reserves(_address) : _converter.connectors(_address);
    }
}