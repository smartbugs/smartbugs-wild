pragma solidity 0.4.18;

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: contracts/TokenRegistry.sol

/**
 * The TokenRegistry is a basic registry mapping token symbols
 * to their known, deployed addresses on the current blockchain.
 *
 * Note that the TokenRegistry does *not* mediate any of the
 * core protocol's business logic, but, rather, is a helpful
 * utility for Terms Contracts to use in encoding, decoding, and
 * resolving the addresses of currently deployed tokens.
 *
 * At this point in time, administration of the Token Registry is
 * under Dharma Labs' control.  With more sophisticated decentralized
 * governance mechanisms, we intend to shift ownership of this utility
 * contract to the Dharma community.
 */
contract TokenRegistry is Ownable {
    mapping (bytes32 => TokenAttributes) public symbolHashToTokenAttributes;
    string[256] public tokenSymbolList;
    uint8 public tokenSymbolListLength;

    struct TokenAttributes {
        // The ERC20 contract address.
        address tokenAddress;
        // The index in `tokenSymbolList` where the token's symbol can be found.
        uint tokenIndex;
        // The name of the given token, e.g. "Canonical Wrapped Ether"
        string name;
        // The number of digits that come after the decimal place when displaying token value.
        uint8 numDecimals;
    }

    /**
     * Maps the given symbol to the given token attributes.
     */
    function setTokenAttributes(
        string _symbol,
        address _tokenAddress,
        string _tokenName,
        uint8 _numDecimals
    )
        public onlyOwner
    {
        bytes32 symbolHash = keccak256(_symbol);

        // Attempt to retrieve the token's attributes from the registry.
        TokenAttributes memory attributes = symbolHashToTokenAttributes[symbolHash];

        if (attributes.tokenAddress == address(0)) {
            // The token has not yet been added to the registry.
            attributes.tokenAddress = _tokenAddress;
            attributes.numDecimals = _numDecimals;
            attributes.name = _tokenName;
            attributes.tokenIndex = tokenSymbolListLength;

            tokenSymbolList[tokenSymbolListLength] = _symbol;
            tokenSymbolListLength++;
        } else {
            // The token has already been added to the registry; update attributes.
            attributes.tokenAddress = _tokenAddress;
            attributes.numDecimals = _numDecimals;
            attributes.name = _tokenName;
        }

        // Update this contract's storage.
        symbolHashToTokenAttributes[symbolHash] = attributes;
    }

    /**
     * Given a symbol, resolves the current address of the token the symbol is mapped to.
     */
    function getTokenAddressBySymbol(string _symbol) public view returns (address) {
        bytes32 symbolHash = keccak256(_symbol);

        TokenAttributes storage attributes = symbolHashToTokenAttributes[symbolHash];

        return attributes.tokenAddress;
    }

    /**
     * Given the known index of a token within the registry's symbol list,
     * returns the address of the token mapped to the symbol at that index.
     *
     * This is a useful utility for compactly encoding the address of a token into a
     * TermsContractParameters string -- by encoding a token by its index in a
     * a 256 slot array, we can represent a token by a 1 byte uint instead of a 20 byte address.
     */
    function getTokenAddressByIndex(uint _index) public view returns (address) {
        string storage symbol = tokenSymbolList[_index];

        return getTokenAddressBySymbol(symbol);
    }

    /**
     * Given a symbol, resolves the index of the token the symbol is mapped to within the registry's
     * symbol list.
     */
    function getTokenIndexBySymbol(string _symbol) public view returns (uint) {
        bytes32 symbolHash = keccak256(_symbol);

        TokenAttributes storage attributes = symbolHashToTokenAttributes[symbolHash];

        return attributes.tokenIndex;
    }

    /**
     * Given an index, resolves the symbol of the token at that index in the registry's
     * token symbol list.
     */
    function getTokenSymbolByIndex(uint _index) public view returns (string) {
        return tokenSymbolList[_index];
    }

    /**
     * Given a symbol, returns the name of the token the symbol is mapped to within the registry's
     * symbol list.
     */
    function getTokenNameBySymbol(string _symbol) public view returns (string) {
        bytes32 symbolHash = keccak256(_symbol);

        TokenAttributes storage attributes = symbolHashToTokenAttributes[symbolHash];

        return attributes.name;
    }

    /**
     * Given the symbol for a token, returns the number of decimals as provided in
     * the associated TokensAttribute struct.
     *
     * Example:
     *   getNumDecimalsFromSymbol("REP");
     *   => 18
     */
    function getNumDecimalsFromSymbol(string _symbol) public view returns (uint8) {
        bytes32 symbolHash = keccak256(_symbol);

        TokenAttributes storage attributes = symbolHashToTokenAttributes[symbolHash];

        return attributes.numDecimals;
    }

    /**
     * Given the index for a token in the registry, returns the number of decimals as provided in
     * the associated TokensAttribute struct.
     *
     * Example:
     *   getNumDecimalsByIndex(1);
     *   => 18
     */
    function getNumDecimalsByIndex(uint _index) public view returns (uint8) {
        string memory symbol = getTokenSymbolByIndex(_index);

        return getNumDecimalsFromSymbol(symbol);
    }

    /**
     * Given the index for a token in the registry, returns the name of the token as provided in
     * the associated TokensAttribute struct.
     *
     * Example:
     *   getTokenNameByIndex(1);
     *   => "Canonical Wrapped Ether"
     */
    function getTokenNameByIndex(uint _index) public view returns (string) {
        string memory symbol = getTokenSymbolByIndex(_index);

        string memory tokenName = getTokenNameBySymbol(symbol);

        return tokenName;
    }

    /**
     * Given the symbol for a token in the registry, returns a tuple containing the token's address,
     * the token's index in the registry, the token's name, and the number of decimals.
     *
     * Example:
     *   getTokenAttributesBySymbol("WETH");
     *   => ["0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2", 1, "Canonical Wrapped Ether", 18]
     */
    function getTokenAttributesBySymbol(string _symbol)
        public
        view
        returns (
            address,
            uint,
            string,
            uint
        )
    {
        bytes32 symbolHash = keccak256(_symbol);

        TokenAttributes storage attributes = symbolHashToTokenAttributes[symbolHash];

        return (
            attributes.tokenAddress,
            attributes.tokenIndex,
            attributes.name,
            attributes.numDecimals
        );
    }

    /**
     * Given the index for a token in the registry, returns a tuple containing the token's address,
     * the token's symbol, the token's name, and the number of decimals.
     *
     * Example:
     *   getTokenAttributesByIndex(1);
     *   => ["0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2", "WETH", "Canonical Wrapped Ether", 18]
     */
    function getTokenAttributesByIndex(uint _index)
        public
        view
        returns (
            address,
            string,
            string,
            uint8
        )
    {
        string memory symbol = getTokenSymbolByIndex(_index);

        bytes32 symbolHash = keccak256(symbol);

        TokenAttributes storage attributes = symbolHashToTokenAttributes[symbolHash];

        return (
            attributes.tokenAddress,
            symbol,
            attributes.name,
            attributes.numDecimals
        );
    }
}