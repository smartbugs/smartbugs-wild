pragma solidity ^0.4.24;

// File: contracts/interfaces/Token.sol

contract Token {
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);
    function approve(address _spender, uint256 _value) public returns (bool success);
    function increaseApproval (address _spender, uint _addedValue) public returns (bool success);
    function balanceOf(address _owner) public view returns (uint256 balance);
}

// File: contracts/interfaces/TokenConverter.sol

contract TokenConverter {
    address public constant ETH_ADDRESS = 0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee;
    function getReturn(Token _fromToken, Token _toToken, uint256 _fromAmount) external view returns (uint256 amount);
    function convert(Token _fromToken, Token _toToken, uint256 _fromAmount, uint256 _minReturn) external payable returns (uint256 amount);
}

// File: contracts/utils/Ownable.sol

contract Ownable {
    address public owner;

    event SetOwner(address _owner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Sender not owner");
        _;
    }

    constructor() public {
        owner = msg.sender;
        emit SetOwner(msg.sender);
    }

    /**
        @dev Transfers the ownership of the contract.

        @param _to Address of the new owner
    */
    function setOwner(address _to) external onlyOwner returns (bool) {
        require(_to != address(0), "Owner can't be 0x0");
        owner = _to;
        emit SetOwner(_to);
        return true;
    } 
}

// File: contracts/interfaces/Oracle.sol

/**
    @dev Defines the interface of a standard RCN oracle.

    The oracle is an agent in the RCN network that supplies a convertion rate between RCN and any other currency,
    it's primarily used by the exchange but could be used by any other agent.
*/
contract Oracle is Ownable {
    uint256 public constant VERSION = 4;

    event NewSymbol(bytes32 _currency);

    mapping(bytes32 => bool) public supported;
    bytes32[] public currencies;

    /**
        @dev Returns the url where the oracle exposes a valid "oracleData" if needed
    */
    function url() public view returns (string);

    /**
        @dev Returns a valid convertion rate from the currency given to RCN

        @param symbol Symbol of the currency
        @param data Generic data field, could be used for off-chain signing
    */
    function getRate(bytes32 symbol, bytes data) public returns (uint256 rate, uint256 decimals);

    /**
        @dev Adds a currency to the oracle, once added it cannot be removed

        @param ticker Symbol of the currency

        @return if the creation was done successfully
    */
    function addCurrency(string ticker) public onlyOwner returns (bool) {
        bytes32 currency = encodeCurrency(ticker);
        NewSymbol(currency);
        supported[currency] = true;
        currencies.push(currency);
        return true;
    }

    /**
        @return the currency encoded as a bytes32
    */
    function encodeCurrency(string currency) public pure returns (bytes32 o) {
        require(bytes(currency).length <= 32);
        assembly {
            o := mload(add(currency, 32))
        }
    }
    
    /**
        @return the currency string from a encoded bytes32
    */
    function decodeCurrency(bytes32 b) public pure returns (string o) {
        uint256 ns = 256;
        while (true) { if (ns == 0 || (b<<ns-8) != 0) break; ns -= 8; }
        assembly {
            ns := div(ns, 8)
            o := mload(0x40)
            mstore(0x40, add(o, and(add(add(ns, 0x20), 0x1f), not(0x1f))))
            mstore(o, ns)
            mstore(add(o, 32), b)
        }
    }
    
}

// File: contracts/interfaces/Engine.sol

contract Engine {
    uint256 public VERSION;
    string public VERSION_NAME;

    enum Status { initial, lent, paid, destroyed }
    struct Approbation {
        bool approved;
        bytes data;
        bytes32 checksum;
    }

    function getTotalLoans() public view returns (uint256);
    function getOracle(uint index) public view returns (Oracle);
    function getBorrower(uint index) public view returns (address);
    function getCosigner(uint index) public view returns (address);
    function ownerOf(uint256) public view returns (address owner);
    function getCreator(uint index) public view returns (address);
    function getAmount(uint index) public view returns (uint256);
    function getPaid(uint index) public view returns (uint256);
    function getDueTime(uint index) public view returns (uint256);
    function getApprobation(uint index, address _address) public view returns (bool);
    function getStatus(uint index) public view returns (Status);
    function isApproved(uint index) public view returns (bool);
    function getPendingAmount(uint index) public returns (uint256);
    function getCurrency(uint index) public view returns (bytes32);
    function cosign(uint index, uint256 cost) external returns (bool);
    function approveLoan(uint index) public returns (bool);
    function transfer(address to, uint256 index) public returns (bool);
    function takeOwnership(uint256 index) public returns (bool);
    function withdrawal(uint index, address to, uint256 amount) public returns (bool);
    function identifierToIndex(bytes32 signature) public view returns (uint256);
}

// File: contracts/interfaces/Cosigner.sol

/**
    @dev Defines the interface of a standard RCN cosigner.

    The cosigner is an agent that gives an insurance to the lender in the event of a defaulted loan, the confitions
    of the insurance and the cost of the given are defined by the cosigner. 

    The lender will decide what cosigner to use, if any; the address of the cosigner and the valid data provided by the
    agent should be passed as params when the lender calls the "lend" method on the engine.
    
    When the default conditions defined by the cosigner aligns with the status of the loan, the lender of the engine
    should be able to call the "claim" method to receive the benefit; the cosigner can define aditional requirements to
    call this method, like the transfer of the ownership of the loan.
*/
contract Cosigner {
    uint256 public constant VERSION = 2;
    
    /**
        @return the url of the endpoint that exposes the insurance offers.
    */
    function url() public view returns (string);
    
    /**
        @dev Retrieves the cost of a given insurance, this amount should be exact.

        @return the cost of the cosign, in RCN wei
    */
    function cost(address engine, uint256 index, bytes data, bytes oracleData) public view returns (uint256);
    
    /**
        @dev The engine calls this method for confirmation of the conditions, if the cosigner accepts the liability of
        the insurance it must call the method "cosign" of the engine. If the cosigner does not call that method, or
        does not return true to this method, the operation fails.

        @return true if the cosigner accepts the liability
    */
    function requestCosign(Engine engine, uint256 index, bytes data, bytes oracleData) public returns (bool);
    
    /**
        @dev Claims the benefit of the insurance if the loan is defaulted, this method should be only calleable by the
        current lender of the loan.

        @return true if the claim was done correctly.
    */
    function claim(address engine, uint256 index, bytes oracleData) external returns (bool);
}

// File: contracts/interfaces/ERC721.sol

contract ERC721 {
    /*
   // ERC20 compatible functions
   function name() public view returns (string _name);
   function symbol() public view returns (string _symbol);
   function totalSupply() public view returns (uint256 _totalSupply);
   function balanceOf(address _owner) public view returns (uint _balance);
   // Functions that define ownership
   function ownerOf(uint256) public view returns (address owner);
   function approve(address, uint256) public returns (bool);
   function takeOwnership(uint256) public returns (bool);
   function transfer(address, uint256) public returns (bool);
   function setApprovalForAll(address _operator, bool _approved) public returns (bool);
   function getApproved(uint256 _tokenId) public view returns (address);
   function isApprovedForAll(address _owner, address _operator) public view returns (bool);
   function transferFrom(address from, address to, uint256 index) public returns (bool);
   // Token metadata
   function tokenMetadata(uint256 _tokenId) public view returns (string info);
   */
   // Events
   event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
   event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
   event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
}

// File: contracts/utils/SafeMath.sol

library SafeMath {
    function add(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x + y;
        require((z >= x) && (z >= y), "Add overflow");
        return z;
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256) {
        require(x >= y, "Sub underflow");
        uint256 z = x - y;
        return z;
    }

    function mult(uint256 x, uint256 y) internal pure returns (uint256) {
        uint256 z = x * y;
        require((x == 0)||(z/x == y), "Mult overflow");
        return z;
    }
}

// File: contracts/utils/ERC165.sol

/**
 * @title ERC165
 * @author Matt Condon (@shrugs)
 * @dev Implements ERC165 using a lookup table.
 */
contract ERC165 {
    bytes4 private constant _InterfaceId_ERC165 = 0x01ffc9a7;
    /**
    * 0x01ffc9a7 ===
    *   bytes4(keccak256('supportsInterface(bytes4)'))
    */

    /**
    * @dev a mapping of interface id to whether or not it's supported
    */
    mapping(bytes4 => bool) private _supportedInterfaces;

    /**
    * @dev A contract implementing SupportsInterfaceWithLookup
    * implement ERC165 itself
    */
    constructor()
        internal
    {
        _registerInterface(_InterfaceId_ERC165);
    }

    /**
    * @dev implement supportsInterface(bytes4) using a lookup table
    */
    function supportsInterface(bytes4 interfaceId)
        external
        view
        returns (bool)
    {
        return _supportedInterfaces[interfaceId];
    }

    /**
    * @dev internal method for registering an interface
    */
    function _registerInterface(bytes4 interfaceId)
        internal
    {
        require(interfaceId != 0xffffffff, "Can't register 0xffffffff");
        _supportedInterfaces[interfaceId] = true;
    }
}

// File: contracts/ERC721Base.sol

interface URIProvider {
    function tokenURI(uint256 _tokenId) external view returns (string);
}

contract ERC721Base is ERC165 {
    using SafeMath for uint256;

    mapping(uint256 => address) private _holderOf;
    mapping(address => uint256[]) private _assetsOf;
    mapping(address => mapping(address => bool)) private _operators;
    mapping(uint256 => address) private _approval;
    mapping(uint256 => uint256) private _indexOfAsset;

    bytes4 private constant ERC721_RECEIVED = 0x150b7a02;
    bytes4 private constant ERC721_RECEIVED_LEGACY = 0xf0b9e5ba;

    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    bytes4 private constant ERC_721_INTERFACE = 0x80ac58cd;
    bytes4 private constant ERC_721_METADATA_INTERFACE = 0x5b5e139f;
    bytes4 private constant ERC_721_ENUMERATION_INTERFACE = 0x780e9d63;

    constructor(
        string name,
        string symbol
    ) public {
        _name = name;
        _symbol = symbol;

        _registerInterface(ERC_721_INTERFACE);
        _registerInterface(ERC_721_METADATA_INTERFACE);
        _registerInterface(ERC_721_ENUMERATION_INTERFACE);
    }

    // ///
    // ERC721 Metadata
    // ///

    /// ERC-721 Non-Fungible Token Standard, optional metadata extension
    /// See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
    /// Note: the ERC-165 identifier for this interface is 0x5b5e139f.

    event SetURIProvider(address _uriProvider);

    string private _name;
    string private _symbol;

    URIProvider private _uriProvider;

    // @notice A descriptive name for a collection of NFTs in this contract
    function name() external view returns (string) {
        return _name;
    }

    // @notice An abbreviated name for NFTs in this contract
    function symbol() external view returns (string) {
        return _symbol;
    }

    /**
    * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    * @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    *  3986. The URI may point to a JSON file that conforms to the "ERC721
    *  Metadata JSON Schema".
    */
    function tokenURI(uint256 _tokenId) external view returns (string) {
        require(_holderOf[_tokenId] != 0, "Asset does not exist");
        URIProvider provider = _uriProvider;
        return provider == address(0) ? "" : provider.tokenURI(_tokenId);
    }

    function _setURIProvider(URIProvider _provider) internal returns (bool) {
        emit SetURIProvider(_provider);
        _uriProvider = _provider;
        return true;
    }
 
    // ///
    // ERC721 Enumeration
    // ///

    ///  ERC-721 Non-Fungible Token Standard, optional enumeration extension
    ///  See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
    ///  Note: the ERC-165 identifier for this interface is 0x780e9d63.

    uint256[] private _allTokens;

    function allTokens() external view returns (uint256[]) {
        return _allTokens;
    }

    function assetsOf(address _owner) external view returns (uint256[]) {
        return _assetsOf[_owner];
    }

    /**
     * @dev Gets the total amount of assets stored by the contract
     * @return uint256 representing the total amount of assets
     */
    function totalSupply() external view returns (uint256) {
        return _allTokens.length;
    }

    /**
    * @notice Enumerate valid NFTs
    * @dev Throws if `_index` >= `totalSupply()`.
    * @param _index A counter less than `totalSupply()`
    * @return The token identifier for the `_index`th NFT,
    *  (sort order not specified)
    */
    function tokenByIndex(uint256 _index) external view returns (uint256) {
        require(_index < _allTokens.length, "Index out of bounds");
        return _allTokens[_index];
    }

    /**
    * @notice Enumerate NFTs assigned to an owner
    * @dev Throws if `_index` >= `balanceOf(_owner)` or if
    *  `_owner` is the zero address, representing invalid NFTs.
    * @param _owner An address where we are interested in NFTs owned by them
    * @param _index A counter less than `balanceOf(_owner)`
    * @return The token identifier for the `_index`th NFT assigned to `_owner`,
    *   (sort order not specified)
    */
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256) {
        require(_owner != address(0), "0x0 Is not a valid owner");
        require(_index < _balanceOf(_owner), "Index out of bounds");
        return _assetsOf[_owner][_index];
    }

    //
    // Asset-centric getter functions
    //

    /**
     * @dev Queries what address owns an asset. This method does not throw.
     * In order to check if the asset exists, use the `exists` function or check if the
     * return value of this call is `0`.
     * @return uint256 the assetId
     */
    function ownerOf(uint256 _assetId) external view returns (address) {
        return _ownerOf(_assetId);
    }
    function _ownerOf(uint256 _assetId) internal view returns (address) {
        return _holderOf[_assetId];
    }

    //
    // Holder-centric getter functions
    //
    /**
     * @dev Gets the balance of the specified address
     * @param _owner address to query the balance of
     * @return uint256 representing the amount owned by the passed address
     */
    function balanceOf(address _owner) external view returns (uint256) {
        return _balanceOf(_owner);
    }
    function _balanceOf(address _owner) internal view returns (uint256) {
        return _assetsOf[_owner].length;
    }

    //
    // Authorization getters
    //

    /**
     * @dev Query whether an address has been authorized to move any assets on behalf of someone else
     * @param _operator the address that might be authorized
     * @param _assetHolder the address that provided the authorization
     * @return bool true if the operator has been authorized to move any assets
     */
    function isApprovedForAll(
        address _operator,
        address _assetHolder
    ) external view returns (bool) {
        return _isApprovedForAll(_operator, _assetHolder);
    }
    function _isApprovedForAll(
        address _operator,
        address _assetHolder
    ) internal view returns (bool) {
        return _operators[_assetHolder][_operator];
    }

    /**
     * @dev Query what address has been particularly authorized to move an asset
     * @param _assetId the asset to be queried for
     * @return bool true if the asset has been approved by the holder
     */
    function getApprovedAddress(uint256 _assetId) external view returns (address) {
        return _getApprovedAddress(_assetId);
    }
    function _getApprovedAddress(uint256 _assetId) internal view returns (address) {
        return _approval[_assetId];
    }

    /**
     * @dev Query if an operator can move an asset.
     * @param _operator the address that might be authorized
     * @param _assetId the asset that has been `approved` for transfer
     * @return bool true if the asset has been approved by the holder
     */
    function isAuthorized(address _operator, uint256 _assetId) external view returns (bool) {
        return _isAuthorized(_operator, _assetId);
    }
    function _isAuthorized(address _operator, uint256 _assetId) internal view returns (bool) {
        require(_operator != 0, "0x0 is an invalid operator");
        address owner = _ownerOf(_assetId);
        if (_operator == owner) {
            return true;
        }
        return _isApprovedForAll(_operator, owner) || _getApprovedAddress(_assetId) == _operator;
    }

    //
    // Authorization
    //

    /**
     * @dev Authorize a third party operator to manage (send) msg.sender's asset
     * @param _operator address to be approved
     * @param _authorized bool set to true to authorize, false to withdraw authorization
     */
    function setApprovalForAll(address _operator, bool _authorized) external {
        if (_operators[msg.sender][_operator] != _authorized) {
            _operators[msg.sender][_operator] = _authorized;
            emit ApprovalForAll(_operator, msg.sender, _authorized);
        }
    }

    /**
     * @dev Authorize a third party operator to manage one particular asset
     * @param _operator address to be approved
     * @param _assetId asset to approve
     */
    function approve(address _operator, uint256 _assetId) external {
        address holder = _ownerOf(_assetId);
        require(msg.sender == holder || _isApprovedForAll(msg.sender, holder), "msg.sender can't approve");
        if (_getApprovedAddress(_assetId) != _operator) {
            _approval[_assetId] = _operator;
            emit Approval(holder, _operator, _assetId);
        }
    }

    //
    // Internal Operations
    //

    function _addAssetTo(address _to, uint256 _assetId) internal {
        // Store asset owner
        _holderOf[_assetId] = _to;

        // Store index of the asset
        uint256 length = _balanceOf(_to);
        _assetsOf[_to].push(_assetId);
        _indexOfAsset[_assetId] = length;

        // Save main enumerable
        _allTokens.push(_assetId);
    }

    function _transferAsset(address _from, address _to, uint256 _assetId) internal {
        uint256 assetIndex = _indexOfAsset[_assetId];
        uint256 lastAssetIndex = _balanceOf(_from).sub(1);

        if (assetIndex != lastAssetIndex) {
            // Replace current asset with last asset
            uint256 lastAssetId = _assetsOf[_from][lastAssetIndex];
            // Insert the last asset into the position previously occupied by the asset to be removed
            _assetsOf[_from][assetIndex] = lastAssetId;
        }

        // Resize the array
        _assetsOf[_from][lastAssetIndex] = 0;
        _assetsOf[_from].length--;

        // Change owner
        _holderOf[_assetId] = _to;

        // Update the index of positions of the asset
        uint256 length = _balanceOf(_to);
        _assetsOf[_to].push(_assetId);
        _indexOfAsset[_assetId] = length;
    }

    function _clearApproval(address _holder, uint256 _assetId) internal {
        if (_approval[_assetId] != 0) {
            _approval[_assetId] = 0;
            emit Approval(_holder, 0, _assetId);
        }
    }

    //
    // Supply-altering functions
    //

    function _generate(uint256 _assetId, address _beneficiary) internal {
        require(_holderOf[_assetId] == 0, "Asset already exists");

        _addAssetTo(_beneficiary, _assetId);

        emit Transfer(0x0, _beneficiary, _assetId);
    }

    //
    // Transaction related operations
    //

    modifier onlyHolder(uint256 _assetId) {
        require(_ownerOf(_assetId) == msg.sender, "msg.sender Is not holder");
        _;
    }

    modifier onlyAuthorized(uint256 _assetId) {
        require(_isAuthorized(msg.sender, _assetId), "msg.sender Not authorized");
        _;
    }

    modifier isCurrentOwner(address _from, uint256 _assetId) {
        require(_ownerOf(_assetId) == _from, "Not current owner");
        _;
    }

    modifier addressDefined(address _target) {
        require(_target != address(0), "Target can't be 0x0");
        _;
    }

    /**
     * @dev Alias of `safeTransferFrom(from, to, assetId, '')`
     *
     * @param _from address that currently owns an asset
     * @param _to address to receive the ownership of the asset
     * @param _assetId uint256 ID of the asset to be transferred
     */
    function safeTransferFrom(address _from, address _to, uint256 _assetId) external {
        return _doTransferFrom(_from, _to, _assetId, "", true);
    }

    /**
     * @dev Securely transfers the ownership of a given asset from one address to
     * another address, calling the method `onNFTReceived` on the target address if
     * there's code associated with it
     *
     * @param _from address that currently owns an asset
     * @param _to address to receive the ownership of the asset
     * @param _assetId uint256 ID of the asset to be transferred
     * @param _userData bytes arbitrary user information to attach to this transfer
     */
    function safeTransferFrom(address _from, address _to, uint256 _assetId, bytes _userData) external {
        return _doTransferFrom(_from, _to, _assetId, _userData, true);
    }

    /**
     * @dev Transfers the ownership of a given asset from one address to another address
     * Warning! This function does not attempt to verify that the target address can send
     * tokens.
     *
     * @param _from address sending the asset
     * @param _to address to receive the ownership of the asset
     * @param _assetId uint256 ID of the asset to be transferred
     */
    function transferFrom(address _from, address _to, uint256 _assetId) external {
        return _doTransferFrom(_from, _to, _assetId, "", false);
    }

    /**
     * Internal function that moves an asset from one holder to another
     */
    function _doTransferFrom(
        address _from,
        address _to,
        uint256 _assetId,
        bytes _userData,
        bool _doCheck
    )
        internal
        onlyAuthorized(_assetId)
        addressDefined(_to)
        isCurrentOwner(_from, _assetId)
    {
        address holder = _holderOf[_assetId];
        _clearApproval(holder, _assetId);
        _transferAsset(holder, _to, _assetId);

        if (_doCheck && _isContract(_to)) {
            // Call dest contract
            uint256 success;
            bytes32 result;
            // Perform check with the new safe call
            // onERC721Received(address,address,uint256,bytes)
            (success, result) = _noThrowCall(
                _to,
                abi.encodeWithSelector(
                    ERC721_RECEIVED,
                    msg.sender,
                    holder,
                    _assetId,
                    _userData
                )
            );

            if (success != 1 || result != ERC721_RECEIVED) {
                // Try legacy safe call
                // onERC721Received(address,uint256,bytes)
                (success, result) = _noThrowCall(
                    _to,
                    abi.encodeWithSelector(
                        ERC721_RECEIVED_LEGACY,
                        holder,
                        _assetId,
                        _userData
                    )
                );

                require(
                    success == 1 && result == ERC721_RECEIVED_LEGACY,
                    "Contract rejected the token"
                );
            }
        }

        emit Transfer(holder, _to, _assetId);
    }

    //
    // Utilities
    //

    function _isContract(address _addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(_addr) }
        return size > 0;
    }

    function _noThrowCall(
        address _contract,
        bytes _data
    ) internal returns (uint256 success, bytes32 result) {
        assembly {
            let x := mload(0x40)

            success := call(
                            gas,                  // Send all gas
                            _contract,            // To addr
                            0,                    // Send ETH
                            add(0x20, _data),     // Input is data past the first 32 bytes
                            mload(_data),         // Input size is the lenght of data
                            x,                    // Store the ouput on x
                            0x20                  // Output is a single bytes32, has 32 bytes
                        )

            result := mload(x)
        }
    }
}

// File: contracts/utils/SafeWithdraw.sol

contract SafeWithdraw is Ownable {
    function withdrawTokens(Token token, address to, uint256 amount) external onlyOwner returns (bool) {
        require(to != address(0), "Can't transfer to address 0x0");
        return token.transfer(to, amount);
    }
    
    function withdrawErc721(ERC721Base token, address to, uint256 id) external onlyOwner returns (bool) {
        require(to != address(0), "Can't transfer to address 0x0");
        token.transferFrom(this, to, id);
    }
    
    function withdrawEth(address to, uint256 amount) external onlyOwner returns (bool) {
        to.transfer(amount);
        return true;
    }
}

// File: contracts/utils/BytesUtils.sol

contract BytesUtils {
    function readBytes32(bytes data, uint256 index) internal pure returns (bytes32 o) {
        require(data.length / 32 > index);
        assembly {
            o := mload(add(data, add(32, mul(32, index))))
        }
    }
}

// File: contracts/MortgageManager.sol

contract LandMarket {
    struct Auction {
        // Auction ID
        bytes32 id;
        // Owner of the NFT
        address seller;
        // Price (in wei) for the published item
        uint256 price;
        // Time when this sale ends
        uint256 expiresAt;
    }

    mapping (uint256 => Auction) public auctionByAssetId;
    function executeOrder(uint256 assetId, uint256 price) public;
}

contract Land is ERC721 {
    function updateLandData(int x, int y, string data) public;
    function decodeTokenId(uint value) view public returns (int, int);
    function safeTransferFrom(address from, address to, uint256 assetId) public;
    function ownerOf(uint256 landID) public view returns (address);
    function setUpdateOperator(uint256 assetId, address operator) external;
}

/**
    @notice The contract is used to handle all the lifetime of a mortgage, uses RCN for the Loan and Decentraland for the parcels. 

    Implements the Cosigner interface of RCN, and when is tied to a loan it creates a new ERC721 to handle the ownership of the mortgage.

    When the loan is resolved (paid, pardoned or defaulted), the mortgaged parcel can be recovered. 

    Uses a token converter to buy the Decentraland parcel with MANA using the RCN tokens received.
*/
contract MortgageManager is Cosigner, ERC721Base, SafeWithdraw, BytesUtils {
    uint256 constant internal PRECISION = (10**18);
    uint256 constant internal RCN_DECIMALS = 18;

    bytes32 public constant MANA_CURRENCY = 0x4d414e4100000000000000000000000000000000000000000000000000000000;
    uint256 public constant REQUIRED_ALLOWANCE = 1000000000 * 10**18;

    event RequestedMortgage(
        uint256 _id,
        address _borrower,
        address _engine,
        uint256 _loanId,
        address _landMarket,
        uint256 _landId,
        uint256 _deposit,
        address _tokenConverter
    );

    event ReadedOracle(
        address _oracle,
        bytes32 _currency,
        uint256 _decimals,
        uint256 _rate
    );

    event StartedMortgage(uint256 _id);
    event CanceledMortgage(address _from, uint256 _id);
    event PaidMortgage(address _from, uint256 _id);
    event DefaultedMortgage(uint256 _id);
    event UpdatedLandData(address _updater, uint256 _parcel, string _data);
    event SetCreator(address _creator, bool _status);
    event SetEngine(address _engine, bool _status);

    Token public rcn;
    Token public mana;
    Land public land;
    
    constructor(
        Token _rcn,
        Token _mana,
        Land _land
    ) public ERC721Base("Decentraland RCN Mortgage", "LAND-RCN-M") {
        rcn = _rcn;
        mana = _mana;
        land = _land;
        mortgages.length++;
    }

    enum Status { Pending, Ongoing, Canceled, Paid, Defaulted }

    struct Mortgage {
        LandMarket landMarket;
        address owner;
        Engine engine;
        uint256 loanId;
        uint256 deposit;
        uint256 landId;
        uint256 landCost;
        Status status;
        TokenConverter tokenConverter;
    }

    uint256 internal flagReceiveLand;

    Mortgage[] public mortgages;

    mapping(address => bool) public creators;
    mapping(address => bool) public engines;

    mapping(uint256 => uint256) public mortgageByLandId;
    mapping(address => mapping(uint256 => uint256)) public loanToLiability;

    function url() public view returns (string) {
        return "";
    }

    function setEngine(address engine, bool authorized) external onlyOwner returns (bool) {
        emit SetEngine(engine, authorized);
        engines[engine] = authorized;
        return true;
    }

    function setURIProvider(URIProvider _provider) external onlyOwner returns (bool) {
        return _setURIProvider(_provider);
    }

    /**
        @notice Sets a new third party creator
        
        The third party creator can request loans for other borrowers. The creator should be a trusted contract, it could potentially take funds.
    
        @param creator Address of the creator
        @param authorized Enables or disables the permission

        @return true If the operation was executed
    */
    function setCreator(address creator, bool authorized) external onlyOwner returns (bool) {
        emit SetCreator(creator, authorized);
        creators[creator] = authorized;
        return true;
    }

    /**
        @notice Returns the cost of the cosigner

        This cosigner does not have any risk or maintenance cost, so its free.

        @return 0, because it's free
    */
    function cost(address, uint256, bytes, bytes) public view returns (uint256) {
        return 0;
    }

    /**
        @notice Requests a mortgage with a loan identifier

        @dev The loan should exist in the designated engine

        @param engine RCN Engine
        @param loanIdentifier Identifier of the loan asociated with the mortgage
        @param deposit MANA to cover part of the cost of the parcel
        @param landId ID of the parcel to buy with the mortgage
        @param tokenConverter Token converter used to exchange RCN - MANA

        @return id The id of the mortgage
    */
    function requestMortgage(
        Engine engine,
        bytes32 loanIdentifier,
        uint256 deposit,
        LandMarket landMarket,
        uint256 landId,
        TokenConverter tokenConverter
    ) external returns (uint256 id) {
        return requestMortgageId(engine, landMarket, engine.identifierToIndex(loanIdentifier), deposit, landId, tokenConverter);
    }

    /**
        @notice Request a mortgage with a loan id

        @dev The loan should exist in the designated engine

        @param engine RCN Engine
        @param loanId Id of the loan asociated with the mortgage
        @param deposit MANA to cover part of the cost of the parcel
        @param landId ID of the parcel to buy with the mortgage
        @param tokenConverter Token converter used to exchange RCN - MANA

        @return id The id of the mortgage
    */
    function requestMortgageId(
        Engine engine,
        LandMarket landMarket,
        uint256 loanId,
        uint256 deposit,
        uint256 landId,
        TokenConverter tokenConverter
    ) public returns (uint256 id) {
        // Validate the associated loan
        require(engine.getCurrency(loanId) == MANA_CURRENCY, "Loan currency is not MANA");
        address borrower = engine.getBorrower(loanId);

        require(engines[engine], "Engine not authorized");
        require(engine.getStatus(loanId) == Engine.Status.initial, "Loan status is not inital");
        require(
            msg.sender == borrower || (msg.sender == engine.getCreator(loanId) && creators[msg.sender]),
            "Creator should be borrower or authorized"
        );
        require(engine.isApproved(loanId), "Loan is not approved");
        require(rcn.allowance(borrower, this) >= REQUIRED_ALLOWANCE, "Manager cannot handle borrower's funds");
        require(tokenConverter != address(0), "Token converter not defined");
        require(loanToLiability[engine][loanId] == 0, "Liability for loan already exists");

        // Get the current parcel cost
        uint256 landCost;
        (, , landCost, ) = landMarket.auctionByAssetId(landId);
        uint256 loanAmount = engine.getAmount(loanId);

        // the remaining will be sent to the borrower
        require(loanAmount + deposit >= landCost, "Not enought total amount");

        // Pull the deposit and lock the tokens
        require(mana.transferFrom(msg.sender, this, deposit), "Error pulling mana");
        
        // Create the liability
        id = mortgages.push(Mortgage({
            owner: borrower,
            engine: engine,
            loanId: loanId,
            deposit: deposit,
            landMarket: landMarket,
            landId: landId,
            landCost: landCost,
            status: Status.Pending,
            tokenConverter: tokenConverter
        })) - 1;

        loanToLiability[engine][loanId] = id;

        emit RequestedMortgage({
            _id: id,
            _borrower: borrower,
            _engine: engine,
            _loanId: loanId,
            _landMarket: landMarket,
            _landId: landId,
            _deposit: deposit,
            _tokenConverter: tokenConverter
        });
    }

    /**
        @notice Cancels an existing mortgage
        @dev The mortgage status should be pending
        @param id Id of the mortgage
        @return true If the operation was executed

    */
    function cancelMortgage(uint256 id) external returns (bool) {
        Mortgage storage mortgage = mortgages[id];
        
        // Only the owner of the mortgage and if the mortgage is pending
        require(msg.sender == mortgage.owner, "Only the owner can cancel the mortgage");
        require(mortgage.status == Status.Pending, "The mortgage is not pending");
        
        mortgage.status = Status.Canceled;

        // Transfer the deposit back to the borrower
        require(mana.transfer(msg.sender, mortgage.deposit), "Error returning MANA");

        emit CanceledMortgage(msg.sender, id);
        return true;
    }

    /**
        @notice Request the cosign of a loan

        Buys the parcel and locks its ownership until the loan status is resolved.
        Emits an ERC721 to manage the ownership of the mortgaged property.
    
        @param engine Engine of the loan
        @param index Index of the loan
        @param data Data with the mortgage id
        @param oracleData Oracle data to calculate the loan amount

        @return true If the cosign was performed
    */
    function requestCosign(Engine engine, uint256 index, bytes data, bytes oracleData) public returns (bool) {
        // The first word of the data MUST contain the index of the target mortgage
        Mortgage storage mortgage = mortgages[uint256(readBytes32(data, 0))];
        
        // Validate that the loan matches with the mortgage
        // and the mortgage is still pending
        require(mortgage.engine == engine, "Engine does not match");
        require(mortgage.loanId == index, "Loan id does not match");
        require(mortgage.status == Status.Pending, "Mortgage is not pending");
        require(engines[engine], "Engine not authorized");

        // Update the status of the mortgage to avoid reentrancy
        mortgage.status = Status.Ongoing;

        // Mint mortgage ERC721 Token
        _generate(uint256(readBytes32(data, 0)), mortgage.owner);

        // Transfer the amount of the loan in RCN to this contract
        uint256 loanAmount = convertRate(engine.getOracle(index), engine.getCurrency(index), oracleData, engine.getAmount(index));
        require(rcn.transferFrom(mortgage.owner, this, loanAmount), "Error pulling RCN from borrower");
        
        // Convert the RCN into MANA using the designated
        // and save the received MANA
        uint256 boughtMana = convertSafe(mortgage.tokenConverter, rcn, mana, loanAmount);
        delete mortgage.tokenConverter;

        // Load the new cost of the parcel, it may be changed
        uint256 currentLandCost;
        (, , currentLandCost, ) = mortgage.landMarket.auctionByAssetId(mortgage.landId);
        require(currentLandCost <= mortgage.landCost, "Parcel is more expensive than expected");
        
        // Buy the land and lock it into the mortgage contract
        require(mana.approve(mortgage.landMarket, currentLandCost), "Error approving mana transfer");
        flagReceiveLand = mortgage.landId;
        mortgage.landMarket.executeOrder(mortgage.landId, currentLandCost);
        require(mana.approve(mortgage.landMarket, 0), "Error removing approve mana transfer");
        require(flagReceiveLand == 0, "ERC721 callback not called");
        require(land.ownerOf(mortgage.landId) == address(this), "Error buying parcel");

        // Set borrower as update operator
        land.setUpdateOperator(mortgage.landId, mortgage.owner);

        // Calculate the remaining amount to send to the borrower and 
        // check that we didn't expend any contract funds.
        uint256 totalMana = boughtMana.add(mortgage.deposit);        
        uint256 rest = totalMana.sub(currentLandCost);

        // Return rest of MANA to the owner
        require(mana.transfer(mortgage.owner, rest), "Error returning MANA");
        
        // Cosign contract, 0 is the RCN required
        require(mortgage.engine.cosign(index, 0), "Error performing cosign");
        
        // Save mortgage id registry
        mortgageByLandId[mortgage.landId] = uint256(readBytes32(data, 0));

        // Emit mortgage event
        emit StartedMortgage(uint256(readBytes32(data, 0)));

        return true;
    }

    /**
        @notice Converts tokens using a token converter
        @dev Does not trust the token converter, validates the return amount
        @param converter Token converter used
        @param from Tokens to sell
        @param to Tokens to buy
        @param amount Amount to sell
        @return bought Bought amount
    */
    function convertSafe(
        TokenConverter converter,
        Token from,
        Token to,
        uint256 amount
    ) internal returns (uint256 bought) {
        require(from.approve(converter, amount), "Error approve convert safe");
        uint256 prevBalance = to.balanceOf(this);
        bought = converter.convert(from, to, amount, 1);
        require(to.balanceOf(this).sub(prevBalance) >= bought, "Bought amount incorrect");
        require(from.approve(converter, 0), "Error remove approve convert safe");
    }

    /**
        @notice Claims the mortgage when the loan status is resolved and transfers the ownership of the parcel to which corresponds.

        @dev Deletes the mortgage ERC721

        @param engine RCN Engine
        @param loanId Loan ID
        
        @return true If the claim succeded
    */
    function claim(address engine, uint256 loanId, bytes) external returns (bool) {
        uint256 mortgageId = loanToLiability[engine][loanId];
        Mortgage storage mortgage = mortgages[mortgageId];

        // Validate that the mortgage wasn't claimed
        require(mortgage.status == Status.Ongoing, "Mortgage not ongoing");
        require(mortgage.loanId == loanId, "Mortgage don't match loan id");

        if (mortgage.engine.getStatus(loanId) == Engine.Status.paid || mortgage.engine.getStatus(loanId) == Engine.Status.destroyed) {
            // The mortgage is paid
            require(_isAuthorized(msg.sender, mortgageId), "Sender not authorized");

            mortgage.status = Status.Paid;
            // Transfer the parcel to the borrower
            land.safeTransferFrom(this, msg.sender, mortgage.landId);
            emit PaidMortgage(msg.sender, mortgageId);
        } else if (isDefaulted(mortgage.engine, loanId)) {
            // The mortgage is defaulted
            require(msg.sender == mortgage.engine.ownerOf(loanId), "Sender not lender");
            
            mortgage.status = Status.Defaulted;
            // Transfer the parcel to the lender
            land.safeTransferFrom(this, msg.sender, mortgage.landId);
            emit DefaultedMortgage(mortgageId);
        } else {
            revert("Mortgage not defaulted/paid");
        }

        // Delete mortgage id registry
        delete mortgageByLandId[mortgage.landId];

        return true;
    }

    /**
        @notice Defines a custom logic that determines if a loan is defaulted or not.

        @param engine RCN Engines
        @param index Index of the loan

        @return true if the loan is considered defaulted
    */
    function isDefaulted(Engine engine, uint256 index) public view returns (bool) {
        return engine.getStatus(index) == Engine.Status.lent &&
            engine.getDueTime(index).add(7 days) <= block.timestamp;
    }

    /**
        @dev An alternative version of the ERC721 callback, required by a bug in the parcels contract
    */
    function onERC721Received(uint256 _tokenId, address, bytes) external returns (bytes4) {
        if (msg.sender == address(land) && flagReceiveLand == _tokenId) {
            flagReceiveLand = 0;
            return bytes4(keccak256("onERC721Received(address,uint256,bytes)"));
        }
    }

    /**
        @notice Callback used to accept the ERC721 parcel tokens

        @dev Only accepts tokens if flag is set to tokenId, resets the flag when called
    */
    function onERC721Received(address, uint256 _tokenId, bytes) external returns (bytes4) {
        if (msg.sender == address(land) && flagReceiveLand == _tokenId) {
            flagReceiveLand = 0;
            return bytes4(keccak256("onERC721Received(address,uint256,bytes)"));
        }
    }

    /**
        @notice Last callback used to accept the ERC721 parcel tokens

        @dev Only accepts tokens if flag is set to tokenId, resets the flag when called
    */
    function onERC721Received(address, address, uint256 _tokenId, bytes) external returns (bytes4) {
        if (msg.sender == address(land) && flagReceiveLand == _tokenId) {
            flagReceiveLand = 0;
            return bytes4(0x150b7a02);
        }
    }

    /**
        @dev Reads data from a bytes array
    */
    function getData(uint256 id) public pure returns (bytes o) {
        assembly {
            o := mload(0x40)
            mstore(0x40, add(o, and(add(add(32, 0x20), 0x1f), not(0x1f))))
            mstore(o, 32)
            mstore(add(o, 32), id)
        }
    }
    
    /**
        @notice Enables the owner of a parcel to update the data field

        @param id Id of the mortgage
        @param data New data

        @return true If data was updated
    */
    function updateLandData(uint256 id, string data) external returns (bool) {
        require(_isAuthorized(msg.sender, id), "Sender not authorized");
        (int256 x, int256 y) = land.decodeTokenId(mortgages[id].landId);
        land.updateLandData(x, y, data);
        emit UpdatedLandData(msg.sender, id, data);
        return true;
    }

    /**
        @dev Replica of the convertRate function of the RCN Engine, used to apply the oracle rate
    */
    function convertRate(Oracle oracle, bytes32 currency, bytes data, uint256 amount) internal returns (uint256) {
        if (oracle == address(0)) {
            return amount;
        } else {
            (uint256 rate, uint256 decimals) = oracle.getRate(currency, data);
            emit ReadedOracle(oracle, currency, decimals, rate);
            require(decimals <= RCN_DECIMALS, "Decimals exceeds max decimals");
            return amount.mult(rate.mult(10**(RCN_DECIMALS-decimals))) / PRECISION;
        }
    }

    //////
    // Override transfer
    //////
    function _doTransferFrom(
        address _from,
        address _to,
        uint256 _assetId,
        bytes _userData,
        bool _doCheck
    )
        internal
    {
        ERC721Base._doTransferFrom(_from, _to, _assetId, _userData, _doCheck);
        land.setUpdateOperator(mortgages[_assetId].landId, _to);
    }
}

// File: contracts/interfaces/NanoLoanEngine.sol

interface NanoLoanEngine {
    function createLoan(address _oracleContract, address _borrower, bytes32 _currency, uint256 _amount, uint256 _interestRate,
        uint256 _interestRatePunitory, uint256 _duesIn, uint256 _cancelableAt, uint256 _expirationRequest, string _metadata) public returns (uint256);
    function getIdentifier(uint256 index) public view returns (bytes32);
    function registerApprove(bytes32 identifier, uint8 v, bytes32 r, bytes32 s) public returns (bool);
    function pay(uint index, uint256 _amount, address _from, bytes oracleData) public returns (bool);
    function rcn() public view returns (Token);
    function getOracle(uint256 index) public view returns (Oracle);
    function getAmount(uint256 index) public view returns (uint256);
    function getCurrency(uint256 index) public view returns (bytes32);
    function convertRate(Oracle oracle, bytes32 currency, bytes data, uint256 amount) public view returns (uint256);
    function lend(uint index, bytes oracleData, Cosigner cosigner, bytes cosignerData) public returns (bool);
    function transfer(address to, uint256 index) public returns (bool);
}

// File: contracts/utils/LrpSafeMath.sol

library LrpSafeMath {
    function safeAdd(uint256 x, uint256 y) internal pure returns(uint256) {
        uint256 z = x + y;
        require((z >= x) && (z >= y));
        return z;
    }

    function safeSubtract(uint256 x, uint256 y) internal pure returns(uint256) {
        require(x >= y);
        uint256 z = x - y;
        return z;
    }

    function safeMult(uint256 x, uint256 y) internal pure returns(uint256) {
        uint256 z = x * y;
        require((x == 0)||(z/x == y));
        return z;
    }

    function min(uint256 a, uint256 b) internal pure returns(uint256) {
        if (a < b) { 
            return a;
        } else { 
            return b; 
        }
    }
    
    function max(uint256 a, uint256 b) internal pure returns(uint256) {
        if (a > b) { 
            return a;
        } else { 
            return b; 
        }
    }
}

// File: contracts/ConverterRamp.sol

contract ConverterRamp is Ownable {
    using LrpSafeMath for uint256;

    address public constant ETH_ADDRESS = 0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee;
    uint256 public constant AUTO_MARGIN = 1000001;

    uint256 public constant I_MARGIN_SPEND = 0;
    uint256 public constant I_MAX_SPEND = 1;
    uint256 public constant I_REBUY_THRESHOLD = 2;

    uint256 public constant I_ENGINE = 0;
    uint256 public constant I_INDEX = 1;

    uint256 public constant I_PAY_AMOUNT = 2;
    uint256 public constant I_PAY_FROM = 3;

    uint256 public constant I_LEND_COSIGNER = 2;

    event RequiredRebuy(address token, uint256 amount);
    event Return(address token, address to, uint256 amount);
    event OptimalSell(address token, uint256 amount);
    event RequiredRcn(uint256 required);
    event RunAutoMargin(uint256 loops, uint256 increment);

    function pay(
        TokenConverter converter,
        Token fromToken,
        bytes32[4] loanParams,
        bytes oracleData,
        uint256[3] convertRules
    ) external payable returns (bool) {
        Token rcn = NanoLoanEngine(address(loanParams[I_ENGINE])).rcn();

        uint256 initialBalance = rcn.balanceOf(this);
        uint256 requiredRcn = getRequiredRcnPay(loanParams, oracleData);
        emit RequiredRcn(requiredRcn);

        uint256 optimalSell = getOptimalSell(converter, fromToken, rcn, requiredRcn, convertRules[I_MARGIN_SPEND]);
        emit OptimalSell(fromToken, optimalSell);

        pullAmount(fromToken, optimalSell);
        uint256 bought = convertSafe(converter, fromToken, rcn, optimalSell);

        // Pay loan
        require(
            executeOptimalPay({
                params: loanParams,
                oracleData: oracleData,
                rcnToPay: bought
            }),
            "Error paying the loan"
        );

        require(
            rebuyAndReturn({
                converter: converter,
                fromToken: rcn,
                toToken: fromToken,
                amount: rcn.balanceOf(this) - initialBalance,
                spentAmount: optimalSell,
                convertRules: convertRules
            }),
            "Error rebuying the tokens"
        );

        require(rcn.balanceOf(this) == initialBalance, "Converter balance has incremented");
        return true;
    }

    function requiredLendSell(
        TokenConverter converter,
        Token fromToken,
        bytes32[3] loanParams,
        bytes oracleData,
        bytes cosignerData,
        uint256[3] convertRules
    ) external view returns (uint256) {
        Token rcn = NanoLoanEngine(address(loanParams[0])).rcn();
        return getOptimalSell(
            converter,
            fromToken,
            rcn,
            getRequiredRcnLend(loanParams, oracleData, cosignerData),
            convertRules[I_MARGIN_SPEND]
        );
    }

    function requiredPaySell(
        TokenConverter converter,
        Token fromToken,
        bytes32[4] loanParams,
        bytes oracleData,
        uint256[3] convertRules
    ) external view returns (uint256) {
        Token rcn = NanoLoanEngine(address(loanParams[0])).rcn();
        return getOptimalSell(
            converter,
            fromToken,
            rcn,
            getRequiredRcnPay(loanParams, oracleData),
            convertRules[I_MARGIN_SPEND]
        );
    }

    function lend(
        TokenConverter converter,
        Token fromToken,
        bytes32[3] loanParams,
        bytes oracleData,
        bytes cosignerData,
        uint256[3] convertRules
    ) external payable returns (bool) {
        Token rcn = NanoLoanEngine(address(loanParams[0])).rcn();
        uint256 initialBalance = rcn.balanceOf(this);
        uint256 requiredRcn = getRequiredRcnLend(loanParams, oracleData, cosignerData);
        emit RequiredRcn(requiredRcn);

        uint256 optimalSell = getOptimalSell(converter, fromToken, rcn, requiredRcn, convertRules[I_MARGIN_SPEND]);
        emit OptimalSell(fromToken, optimalSell);

        pullAmount(fromToken, optimalSell);      
        uint256 bought = convertSafe(converter, fromToken, rcn, optimalSell);

        // Lend loan
        require(rcn.approve(address(loanParams[0]), bought));
        require(executeLend(loanParams, oracleData, cosignerData), "Error lending the loan");
        require(rcn.approve(address(loanParams[0]), 0));
        require(executeTransfer(loanParams, msg.sender), "Error transfering the loan");

        require(
            rebuyAndReturn({
                converter: converter,
                fromToken: rcn,
                toToken: fromToken,
                amount: rcn.balanceOf(this) - initialBalance,
                spentAmount: optimalSell,
                convertRules: convertRules
            }),
            "Error rebuying the tokens"
        );

        require(rcn.balanceOf(this) == initialBalance);
        return true;
    }

    function pullAmount(
        Token token,
        uint256 amount
    ) private {
        if (token == ETH_ADDRESS) {
            require(msg.value >= amount, "Error pulling ETH amount");
            if (msg.value > amount) {
                msg.sender.transfer(msg.value - amount);
            }
        } else {
            require(token.transferFrom(msg.sender, this, amount), "Error pulling Token amount");
        }
    }

    function transfer(
        Token token,
        address to,
        uint256 amount
    ) private {
        if (token == ETH_ADDRESS) {
            to.transfer(amount);
        } else {
            require(token.transfer(to, amount), "Error sending tokens");
        }
    }

    function rebuyAndReturn(
        TokenConverter converter,
        Token fromToken,
        Token toToken,
        uint256 amount,
        uint256 spentAmount,
        uint256[3] memory convertRules
    ) internal returns (bool) {
        uint256 threshold = convertRules[I_REBUY_THRESHOLD];
        uint256 bought = 0;

        if (amount != 0) {
            if (amount > threshold) {
                bought = convertSafe(converter, fromToken, toToken, amount);
                emit RequiredRebuy(toToken, amount);
                emit Return(toToken, msg.sender, bought);
                transfer(toToken, msg.sender, bought);
            } else {
                emit Return(fromToken, msg.sender, amount);
                transfer(fromToken, msg.sender, amount);
            }
        }

        uint256 maxSpend = convertRules[I_MAX_SPEND];
        require(spentAmount.safeSubtract(bought) <= maxSpend || maxSpend == 0, "Max spend exceeded");
        
        return true;
    } 

    function getOptimalSell(
        TokenConverter converter,
        Token fromToken,
        Token toToken,
        uint256 requiredTo,
        uint256 extraSell
    ) internal returns (uint256 sellAmount) {
        uint256 sellRate = (10 ** 18 * converter.getReturn(toToken, fromToken, requiredTo)) / requiredTo;
        if (extraSell == AUTO_MARGIN) {
            uint256 expectedReturn = 0;
            uint256 optimalSell = applyRate(requiredTo, sellRate);
            uint256 increment = applyRate(requiredTo / 100000, sellRate);
            uint256 returnRebuy;
            uint256 cl;

            while (expectedReturn < requiredTo && cl < 10) {
                optimalSell += increment;
                returnRebuy = converter.getReturn(fromToken, toToken, optimalSell);
                optimalSell = (optimalSell * requiredTo) / returnRebuy;
                expectedReturn = returnRebuy;
                cl++;
            }
            emit RunAutoMargin(cl, increment);

            return optimalSell;
        } else {
            return applyRate(requiredTo, sellRate).safeMult(uint256(100000).safeAdd(extraSell)) / 100000;
        }
    }

    function convertSafe(
        TokenConverter converter,
        Token fromToken,
        Token toToken,
        uint256 amount
    ) internal returns (uint256 bought) {
        if (fromToken != ETH_ADDRESS) require(fromToken.approve(converter, amount));
        uint256 prevBalance = toToken != ETH_ADDRESS ? toToken.balanceOf(this) : address(this).balance;
        uint256 sendEth = fromToken == ETH_ADDRESS ? amount : 0;
        uint256 boughtAmount = converter.convert.value(sendEth)(fromToken, toToken, amount, 1);
        require(
            boughtAmount == (toToken != ETH_ADDRESS ? toToken.balanceOf(this) : address(this).balance) - prevBalance,
            "Bought amound does does not match"
        );
        if (fromToken != ETH_ADDRESS) require(fromToken.approve(converter, 0));
        return boughtAmount;
    }

    function executeOptimalPay(
        bytes32[4] memory params,
        bytes oracleData,
        uint256 rcnToPay
    ) internal returns (bool) {
        NanoLoanEngine engine = NanoLoanEngine(address(params[I_ENGINE]));
        uint256 index = uint256(params[I_INDEX]);
        Oracle oracle = engine.getOracle(index);

        uint256 toPay;

        if (oracle == address(0)) {
            toPay = rcnToPay;
        } else {
            uint256 rate;
            uint256 decimals;
            bytes32 currency = engine.getCurrency(index);

            (rate, decimals) = oracle.getRate(currency, oracleData);
            toPay = (rcnToPay * (10 ** (18 - decimals + (18 * 2)) / rate)) / 10 ** 18;
        }

        Token rcn = engine.rcn();
        require(rcn.approve(engine, rcnToPay));
        require(engine.pay(index, toPay, address(params[I_PAY_FROM]), oracleData), "Error paying the loan");
        require(rcn.approve(engine, 0));
        
        return true;
    }

    function executeLend(
        bytes32[3] memory params,
        bytes oracleData,
        bytes cosignerData
    ) internal returns (bool) {
        NanoLoanEngine engine = NanoLoanEngine(address(params[I_ENGINE]));
        uint256 index = uint256(params[I_INDEX]);
        return engine.lend(index, oracleData, Cosigner(address(params[I_LEND_COSIGNER])), cosignerData);
    }

    function executeTransfer(
        bytes32[3] memory params,
        address to
    ) internal returns (bool) {
        return NanoLoanEngine(address(params[0])).transfer(to, uint256(params[1]));
    }

    function applyRate(
        uint256 amount,
        uint256 rate
    ) pure internal returns (uint256) {
        return amount.safeMult(rate) / 10 ** 18;
    }

    function getRequiredRcnLend(
        bytes32[3] memory params,
        bytes oracleData,
        bytes cosignerData
    ) internal returns (uint256 required) {
        NanoLoanEngine engine = NanoLoanEngine(address(params[I_ENGINE]));
        uint256 index = uint256(params[I_INDEX]);
        Cosigner cosigner = Cosigner(address(params[I_LEND_COSIGNER]));

        if (cosigner != address(0)) {
            required += cosigner.cost(engine, index, cosignerData, oracleData);
        }
        required += engine.convertRate(engine.getOracle(index), engine.getCurrency(index), oracleData, engine.getAmount(index));
    }
    
    function getRequiredRcnPay(
        bytes32[4] memory params,
        bytes oracleData
    ) internal returns (uint256) {
        NanoLoanEngine engine = NanoLoanEngine(address(params[I_ENGINE]));
        uint256 index = uint256(params[I_INDEX]);
        uint256 amount = uint256(params[I_PAY_AMOUNT]);
        return engine.convertRate(engine.getOracle(index), engine.getCurrency(index), oracleData, amount);
    }

    function sendTransaction(
        address to,
        uint256 value,
        bytes data
    ) external onlyOwner returns (bool) {
        return to.call.value(value)(data);
    }

    function() external {}
}

// File: contracts/MortgageHelper.sol

/**
    @notice Set of functions to operate the mortgage manager in less transactions
*/
contract MortgageHelper is Ownable {
    using LrpSafeMath for uint256;

    MortgageManager public mortgageManager;
    NanoLoanEngine public nanoLoanEngine;
    Token public rcn;
    Token public mana;
    LandMarket public landMarket;
    TokenConverter public tokenConverter;
    ConverterRamp public converterRamp;

    address public manaOracle;
    uint256 public requiredTotal = 105;

    uint256 public rebuyThreshold = 0.001 ether;
    uint256 public marginSpend = 500;
    uint256 public maxSpend = 300;

    bytes32 public constant MANA_CURRENCY = 0x4d414e4100000000000000000000000000000000000000000000000000000000;

    event NewMortgage(address borrower, uint256 loanId, uint256 landId, uint256 mortgageId);
    event PaidLoan(address engine, uint256 loanId, uint256 amount);

    event SetRebuyThreshold(uint256 _prev, uint256 _new);
    event SetMarginSpend(uint256 _prev, uint256 _new);
    event SetMaxSpend(uint256 _prev, uint256 _new);
    event SetRequiredTotal(uint256 _prev, uint256 _new);

    event SetTokenConverter(address _prev, address _new);
    event SetConverterRamp(address _prev, address _new);
    event SetManaOracle(address _manaOracle);
    event SetEngine(address _engine);
    event SetLandMarket(address _landMarket);
    event SetMortgageManager(address _mortgageManager);

    constructor(
        MortgageManager _mortgageManager,
        NanoLoanEngine _nanoLoanEngine,
        LandMarket _landMarket,
        address _manaOracle,
        TokenConverter _tokenConverter,
        ConverterRamp _converterRamp
    ) public {
        mortgageManager = _mortgageManager;
        nanoLoanEngine = _nanoLoanEngine;
        rcn = _mortgageManager.rcn();
        mana = _mortgageManager.mana();
        landMarket = _landMarket;
        manaOracle = _manaOracle;
        tokenConverter = _tokenConverter;
        converterRamp = _converterRamp;

        // Sanity checks
        require(_nanoLoanEngine.rcn() == rcn, "RCN Mismatch");
        require(_mortgageManager.engines(_nanoLoanEngine), "Engine is not approved");
        require(_isContract(mana), "MANA should be a contract");
        require(_isContract(rcn), "RCN should be a contract");
        require(_isContract(_tokenConverter), "Token converter should be a contract");
        require(_isContract(_landMarket), "Land market should be a contract");
        require(_isContract(_converterRamp), "Converter ramp should be a contract");
        require(_isContract(_manaOracle), "MANA Oracle should be a contract");
        require(_isContract(_mortgageManager), "Mortgage manager should be a contract");

        emit SetConverterRamp(converterRamp, _converterRamp);
        emit SetTokenConverter(tokenConverter, _tokenConverter);

        emit SetEngine(_nanoLoanEngine);
        emit SetLandMarket(_landMarket);
        emit SetMortgageManager(_mortgageManager);
        emit SetManaOracle(_manaOracle);

        emit SetMaxSpend(0, maxSpend);
        emit SetMarginSpend(0, marginSpend);
        emit SetRebuyThreshold(0, rebuyThreshold);
        emit SetRequiredTotal(0, requiredTotal);
    }

    /**
        @dev Creates a loan using an array of parameters

        @param params 0 - Ammount
                      1 - Interest rate
                      2 - Interest rate punitory
                      3 - Dues in
                      4 - Cancelable at
                      5 - Expiration of request

        @param metadata Loan metadata

        @return Id of the loan

    */
    function createLoan(uint256[6] memory params, string metadata) internal returns (uint256) {
        return nanoLoanEngine.createLoan(
            manaOracle,
            msg.sender,
            MANA_CURRENCY,
            params[0],
            params[1],
            params[2],
            params[3],
            params[4],
            params[5],
            metadata
        );
    }

    /**
        @notice Sets a max amount to expend when performing the payment
        @dev Only owner
        @param _maxSpend New maxSPend value
        @return true If the change was made
    */
    function setMaxSpend(uint256 _maxSpend) external onlyOwner returns (bool) {
        emit SetMaxSpend(maxSpend, _maxSpend);
        maxSpend = _maxSpend;
        return true;
    }

    /**
        @notice Sets required total of the mortgage
        @dev Only owner
        @param _requiredTotal New requiredTotal value
        @return true If the change was made
    */
    function setRequiredTotal(uint256 _requiredTotal) external onlyOwner returns (bool) {
        emit SetRequiredTotal(requiredTotal, _requiredTotal);
        requiredTotal = _requiredTotal;
        return true;
    }


    /**
        @notice Sets a new converter ramp to delegate the pay of the loan
        @dev Only owner
        @param _converterRamp Address of the converter ramp contract
        @return true If the change was made
    */
    function setConverterRamp(ConverterRamp _converterRamp) external onlyOwner returns (bool) {
        require(_isContract(_converterRamp), "Should be a contract");
        emit SetConverterRamp(converterRamp, _converterRamp);
        converterRamp = _converterRamp;
        return true;
    }

    /**
        @notice Sets a new min of tokens to rebuy when paying a loan
        @dev Only owner
        @param _rebuyThreshold New rebuyThreshold value
        @return true If the change was made
    */
    function setRebuyThreshold(uint256 _rebuyThreshold) external onlyOwner returns (bool) {
        emit SetRebuyThreshold(rebuyThreshold, _rebuyThreshold);
        rebuyThreshold = _rebuyThreshold;
        return true;
    }

    /**
        @notice Sets how much the converter ramp is going to oversell to cover fees and gaps
        @dev Only owner
        @param _marginSpend New marginSpend value
        @return true If the change was made
    */
    function setMarginSpend(uint256 _marginSpend) external onlyOwner returns (bool) {
        emit SetMarginSpend(marginSpend, _marginSpend);
        marginSpend = _marginSpend;
        return true;
    }

    /**
        @notice Sets the token converter used to convert the MANA into RCN when performing the payment
        @dev Only owner
        @param _tokenConverter Address of the tokenConverter contract
        @return true If the change was made
    */
    function setTokenConverter(TokenConverter _tokenConverter) external onlyOwner returns (bool) {
        require(_isContract(_tokenConverter), "Should be a contract");
        emit SetTokenConverter(tokenConverter, _tokenConverter);
        tokenConverter = _tokenConverter;
        return true;
    }

    function setManaOracle(address _manaOracle) external onlyOwner returns (bool) {
        require(_isContract(_manaOracle), "Should be a contract");
        emit SetManaOracle(_manaOracle);
        manaOracle = _manaOracle;
        return true;
    }

    function setEngine(NanoLoanEngine _engine) external onlyOwner returns (bool) {
        require(_isContract(_engine), "Should be a contract");
        emit SetEngine(_engine);
        nanoLoanEngine = _engine;
        return true;
    }

    function setLandMarket(LandMarket _landMarket) external onlyOwner returns (bool) {
        require(_isContract(_landMarket), "Should be a contract");
        emit SetLandMarket(_landMarket);
        landMarket = _landMarket;
        return true;
    }

    function setMortgageManager(MortgageManager _mortgageManager) external onlyOwner returns (bool) {
        require(_isContract(_mortgageManager), "Should be a contract");
        emit SetMortgageManager(_mortgageManager);
        mortgageManager = _mortgageManager;
        return true;
    }

    /**
        @notice Request a loan and attachs a mortgage request

        @dev Requires the loan signed by the borrower

        @param loanParams   0 - Ammount
                            1 - Interest rate
                            2 - Interest rate punitory
                            3 - Dues in
                            4 - Cancelable at
                            5 - Expiration of request
        @param metadata Loan metadata
        @param landId Land to buy with the mortgage
        @param v Loan signature by the borrower
        @param r Loan signature by the borrower
        @param s Loan signature by the borrower

        @return The id of the mortgage
    */
    function requestMortgage(
        uint256[6] loanParams,
        string metadata,
        uint256 landId,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256) {
        // Create a loan with the loanParams and metadata
        uint256 loanId = createLoan(loanParams, metadata);

        // Load NanoLoanEngine address
        NanoLoanEngine _nanoLoanEngine = nanoLoanEngine;

        // Approve the created loan with the provided signature
        require(_nanoLoanEngine.registerApprove(_nanoLoanEngine.getIdentifier(loanId), v, r, s), "Signature not valid");

        // Calculate the requested amount for the mortgage deposit
        uint256 requiredDeposit = ((readLandCost(landId) * requiredTotal) / 100) - _nanoLoanEngine.getAmount(loanId);
        
        // Pull the required deposit amount
        Token _mana = mana;
        _tokenTransferFrom(_mana, msg.sender, this, requiredDeposit);
        require(_mana.approve(mortgageManager, requiredDeposit), "Error approve MANA transfer");

        // Create the mortgage request
        uint256 mortgageId = mortgageManager.requestMortgageId(
            Engine(_nanoLoanEngine),
            landMarket,
            loanId,
            requiredDeposit, 
            landId,
            tokenConverter
        );

        require(_mana.approve(mortgageManager, 0), "Error remove approve MANA transfer");

        emit NewMortgage(msg.sender, loanId, landId, mortgageId);
        
        return mortgageId;
    }

    function readLandCost(uint256 _landId) internal view returns (uint256 landCost) {
        (, , landCost, ) = landMarket.auctionByAssetId(_landId);
    }

    /**
        @notice Pays a loan using mana

        @dev The amount to pay must be set on mana

        @param engine RCN Engine
        @param loan Loan id to pay
        @param amount Amount in MANA to pay

        @return True if the payment was performed
    */
    function pay(address engine, uint256 loan, uint256 amount) external returns (bool) {
        emit PaidLoan(engine, loan, amount);

        bytes32[4] memory loanParams = [
            bytes32(engine),
            bytes32(loan),
            bytes32(amount),
            bytes32(msg.sender)
        ];

        uint256[3] memory converterParams = [
            marginSpend,
            amount.safeMult(uint256(100000).safeAdd(maxSpend)) / 100000,
            rebuyThreshold
        ];

        require(address(converterRamp).delegatecall(
            bytes4(0x86ee863d),
            address(tokenConverter),
            address(mana),
            loanParams,
            0x140,
            converterParams,
            0x0
        ), "Error delegate pay call");
    }

    function _tokenTransferFrom(Token token, address from, address to, uint256 amount) internal {
        require(token.balanceOf(from) >= amount, "From balance is not enough");
        require(token.allowance(from, address(this)) >= amount, "Allowance is not enough");
        require(token.transferFrom(from, to, amount), "Transfer failed");
    }

    function _isContract(address addr) internal view returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}