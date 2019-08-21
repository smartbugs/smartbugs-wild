pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}












/**
 * @title ERC165
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
 */
interface ERC165 {

  /**
   * @notice Query if a contract implements an interface
   * @param _interfaceId The interface identifier, as specified in ERC-165
   * @dev Interface identification is specified in ERC-165. This function
   * uses less than 30,000 gas.
   */
  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool);
}



/**
 * @title SupportsInterfaceWithLookup
 * @author Matt Condon (@shrugs)
 * @dev Implements ERC165 using a lookup table.
 */
contract SupportsInterfaceWithLookup is ERC165 {

  bytes4 public constant InterfaceId_ERC165 = 0x01ffc9a7;
  /**
   * 0x01ffc9a7 ===
   *   bytes4(keccak256('supportsInterface(bytes4)'))
   */

  /**
   * @dev a mapping of interface id to whether or not it's supported
   */
  mapping(bytes4 => bool) internal supportedInterfaces;

  /**
   * @dev A contract implementing SupportsInterfaceWithLookup
   * implement ERC165 itself
   */
  constructor()
    public
  {
    _registerInterface(InterfaceId_ERC165);
  }

  /**
   * @dev implement supportsInterface(bytes4) using a lookup table
   */
  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool)
  {
    return supportedInterfaces[_interfaceId];
  }

  /**
   * @dev private method for registering an interface
   */
  function _registerInterface(bytes4 _interfaceId)
    internal
  {
    require(_interfaceId != 0xffffffff);
    supportedInterfaces[_interfaceId] = true;
  }
}







contract Contract is Ownable, SupportsInterfaceWithLookup {
    /**
     * @notice this.owner.selector ^ this.renounceOwnership.selector ^ this.transferOwnership.selector
        ^ this.template.selector
     */
    bytes4 public constant InterfaceId_Contract = 0x6125ede5;

    Template public template;

    constructor(address _owner) public {
        require(_owner != address(0));

        template = Template(msg.sender);
        owner = _owner;

        _registerInterface(InterfaceId_Contract);
    }
}


/**
 * @title Template
 * @notice Template instantiates `Contract`s of the same form.
 */
contract Template is Ownable, SupportsInterfaceWithLookup {
    /**
     * @notice this.owner.selector ^ this.renounceOwnership.selector ^ this.transferOwnership.selector
        ^ this.bytecodeHash.selector ^ this.price.selector ^ this.beneficiary.selector
        ^ this.name.selector ^ this.description.selector ^ this.setNameAndDescription.selector
        ^ this.instantiate.selector
     */
    bytes4 public constant InterfaceId_Template = 0xd48445ff;

    mapping(string => string) nameOfLocale;
    mapping(string => string) descriptionOfLocale;
    /**
     * @notice Hash of EVM bytecode to be instantiated.
     */
    bytes32 public bytecodeHash;
    /**
     * @notice Price to pay when instantiating
     */
    uint public price;
    /**
     * @notice Address to receive payment
     */
    address public beneficiary;

    /**
     * @notice Logged when a new `Contract` instantiated.
     */
    event Instantiated(address indexed creator, address indexed contractAddress);

    /**
     * @param _bytecodeHash Hash of EVM bytecode
     * @param _price Price of instantiating in wei
     * @param _beneficiary Address to transfer _price when instantiating
     */
    constructor(
        bytes32 _bytecodeHash,
        uint _price,
        address _beneficiary
    ) public {
        bytecodeHash = _bytecodeHash;
        price = _price;
        beneficiary = _beneficiary;
        if (price > 0) {
            require(beneficiary != address(0));
        }

        _registerInterface(InterfaceId_Template);
    }

    /**
     * @param _locale IETF language tag(https://en.wikipedia.org/wiki/IETF_language_tag)
     * @return Name in `_locale`.
     */
    function name(string _locale) public view returns (string) {
        return nameOfLocale[_locale];
    }

    /**
     * @param _locale IETF language tag(https://en.wikipedia.org/wiki/IETF_language_tag)
     * @return Description in `_locale`.
     */
    function description(string _locale) public view returns (string) {
        return descriptionOfLocale[_locale];
    }

    /**
     * @param _locale IETF language tag(https://en.wikipedia.org/wiki/IETF_language_tag)
     * @param _name Name to set
     * @param _description Description to set
     */
    function setNameAndDescription(string _locale, string _name, string _description) public onlyOwner {
        nameOfLocale[_locale] = _name;
        descriptionOfLocale[_locale] = _description;
    }

    /**
     * @notice `msg.sender` is passed as first argument for the newly created `Contract`.
     * @param _bytecode Bytecode corresponding to `bytecodeHash`
     * @param _args If arguments where passed to this function, those will be appended to the arguments for `Contract`.
     * @return Newly created contract account's address
     */
    function instantiate(bytes _bytecode, bytes _args) public payable returns (address contractAddress) {
        require(bytecodeHash == keccak256(_bytecode));
        bytes memory calldata = abi.encodePacked(_bytecode, _args);
        assembly {
            contractAddress := create(0, add(calldata, 0x20), mload(calldata))
        }
        if (contractAddress == address(0)) {
            revert("Cannot instantiate contract");
        } else {
            Contract c = Contract(contractAddress);
            // InterfaceId_ERC165
            require(c.supportsInterface(0x01ffc9a7));
            // InterfaceId_Contract
            require(c.supportsInterface(0x6125ede5));

            if (price > 0) {
                require(msg.value == price);
                beneficiary.transfer(msg.value);
            }
            emit Instantiated(msg.sender, contractAddress);
        }
    }
}


/**
 * @title Registry
 * @notice Registry maintains Contracts by version.
 */
contract Registry is Ownable {
    bool opened;
    string[] identifiers;
    mapping(string => address) registrantOfIdentifier;
    mapping(string => uint[]) versionsOfIdentifier;
    mapping(string => mapping(uint => Template)) templateOfVersionOfIdentifier;

    constructor(bool _opened) Ownable() public {
        opened = _opened;
    }

    /**
     * @notice Open the Registry so that anyone can register.
     */
    function open() onlyOwner public {
        opened = true;
    }

    /**
     * @notice Registers a new `Template`.
     * @param _identifier If any template was registered for the same identifier, the registrant of the templates must be the same.
     * @param _version If any template was registered for the same identifier, new version must be greater than the old one.
     * @param _template Template to be registered.
     */
    function register(string _identifier, uint _version, Template _template) public {
        require(opened || msg.sender == owner);

        // InterfaceId_ERC165
        require(_template.supportsInterface(0x01ffc9a7));
        // InterfaceId_Template
        require(_template.supportsInterface(0xd48445ff));

        address registrant = registrantOfIdentifier[_identifier];
        require(registrant == address(0) || registrant == msg.sender, "identifier already registered by another registrant");
        if (registrant == address(0)) {
            identifiers.push(_identifier);
            registrantOfIdentifier[_identifier] = msg.sender;
        }

        uint[] storage versions = versionsOfIdentifier[_identifier];
        if (versions.length > 0) {
            require(_version > versions[versions.length - 1], "new version must be greater than old versions");
        }
        versions.push(_version);
        templateOfVersionOfIdentifier[_identifier][_version] = _template;
    }

    function numberOfIdentifiers() public view returns (uint size) {
        return identifiers.length;
    }

    function identifierAt(uint _index) public view returns (string identifier) {
        return identifiers[_index];
    }

    function versionsOf(string _identifier) public view returns (uint[] version) {
        return versionsOfIdentifier[_identifier];
    }

    function templateOf(string _identifier, uint _version) public view returns (Template template) {
        return templateOfVersionOfIdentifier[_identifier][_version];
    }

    function latestTemplateOf(string _identifier) public view returns (Template template) {
        uint[] storage versions = versionsOfIdentifier[_identifier];
        return templateOfVersionOfIdentifier[_identifier][versions[versions.length - 1]];
    }
}


/**
 * @title Strategy Registry
 * @notice `Template` to be registered must be a `StrategyTemplate`.
 */
contract ERC20SaleStrategyRegistry is Registry(false) {
}