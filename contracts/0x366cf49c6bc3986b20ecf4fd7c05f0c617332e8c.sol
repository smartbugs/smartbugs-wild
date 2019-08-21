pragma solidity ^0.5.5;

/**
 * @title IERC165
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
 */
interface IERC165 {
    /**
     * @notice Query if a contract implements an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @dev Interface identification is specified in ERC-165. This function
     * uses less than 30,000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/**
 * @title ERC165
 * @author Matt Condon (@shrugs)
 * @dev Implements ERC165 using a lookup table.
 */
contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    /**
     * 0x01ffc9a7 ===
     *     bytes4(keccak256('supportsInterface(bytes4)'))
     */

    /**
     * @dev a mapping of interface id to whether or not it's supported
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    /**
     * @dev A contract implementing SupportsInterfaceWithLookup
     * implement ERC165 itself
     */
    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev implement supportsInterface(bytes4) using a lookup table
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    /**
     * @dev internal method for registering an interface
     */
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff);
        _supportedInterfaces[interfaceId] = true;
    }
}

/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    function balanceOf(address owner) public view returns (uint256 balance);
    function ownerOf(uint256 tokenId) public view returns (address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
contract IERC721Receiver {
    /**
     * @notice Handle the receipt of an NFT
     * @dev The ERC721 smart contract calls this function on the recipient
     * after a `safeTransfer`. This function MUST return the function selector,
     * otherwise the caller will revert the transaction. The selector to be
     * returned can be obtained as `this.onERC721Received.selector`. This
     * function MAY throw to revert and reject the transfer.
     * Note: the ERC721 contract address is always the message sender.
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
        public returns (bytes4);
}

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

/**
 * Utility library of inline functions on addresses
 */
library Address {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721 is ERC165, IERC721 {
    using SafeMath for uint256;
    using Address for address;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 internal constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from token ID to owner
    mapping (uint256 => address) public _tokenOwner;

    // Mapping from owner to number of owned token
    mapping (address => uint256) public _ownedTokensCount;

    bytes4 internal constant _INTERFACE_ID_ERC721 = 0xab7fecf1;
    /*
     * 0xab7fecf1 ===
     *     bytes4(keccak256('balanceOf(address)')) ^
     *     bytes4(keccak256('ownerOf(uint256)')) ^
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'))
     */

    constructor () public {
        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    /**
     * @dev Gets the balance of the specified address
     * @param owner address to query the balance of
     * @return uint256 representing the amount owned by the passed address
     */
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0));
        return _ownedTokensCount[owner];
    }

    /**
     * @dev Gets the owner of the specified token ID
     * @param tokenId uint256 ID of the token to query the owner of
     * @return owner address currently marked as the owner of the given token ID
     */
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _tokenOwner[tokenId];
        require(owner != address(0));
        return owner;
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        require(ownerOf(tokenId) == from);
        require(to != address(0));
        require(_checkOnERC721Received(from, to, tokenId, _data));
        _ownedTokensCount[from] = _ownedTokensCount[from].sub(1);
        _ownedTokensCount[to] = _ownedTokensCount[to].add(1);
        _tokenOwner[tokenId] = to;
        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Returns whether the specified token exists
     * @param tokenId uint256 ID of the token to query the existence of
     * @return whether the token exists
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    /**
     * @dev Internal function to mint a new token
     * Reverts if the given token ID already exists
     * @param to The address that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0));
        require(!_exists(tokenId));
        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to]= _ownedTokensCount[to].add(1);
        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Internal function to invoke `onERC721Received` on a target address
     * The call is not executed if the target address is not a contract
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }
        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {

    // Token class name e.g. "2019 Coachella Gathering Trophies" 
    string internal _name;

    // Token class symbol e.g. "CGT19"
    string internal _symbol;

    // Mapping for token URIs
    mapping(uint256 => string) internal _tokenURIs;

    // // Optional mapping for token names
    mapping(uint256 => string) internal _tokenNames;

    bytes4 internal constant _INTERFACE_ID_ERC721_METADATA = 0xbc7bebe8;
    /**
     * 0xbc7bebe8 ===
     *     bytes4(keccak256('name()')) ^
     *     bytes4(keccak256('symbol()')) ^
     *     bytes4(keccak256('tokenURI(uint256)')) ^
     *     bytes4(keccak256('tokenName(uint256)'))
     */

    /**
     * @dev Constructor function
     */
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    /**
     * @dev Gets the token name
     * @return string representing the token name
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev Gets the token symbol
     * @return string representing the token symbol
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns an URI for a given token ID
     * Throws if the token ID does not exist. May return an empty string.
     * @param tokenId uint256 ID of the token to query
     */
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId));
        return _tokenURIs[tokenId];
    }

    /**
     * @dev Returns a trophy name for a given token ID
     * Throws if the token ID does not exist. May return an empty string.
     * @param tokenId uint256 ID of the token to query
     */
    function tokenName(uint256 tokenId) external view returns (string memory) {
        require(_exists(tokenId));
        return _tokenNames[tokenId];
    }

    /**
     * @dev Internal function to set the token URI for a given token
     * Reverts if the token ID does not exist
     * @param tokenId uint256 ID of the token to set its URI
     * @param uri string URI to assign
     */
    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        require(_exists(tokenId));
        _tokenURIs[tokenId] = uri;
    }

    /**
     * @dev Internal function that extracts the part of a string based on the desired length and offset. The
     *      offset and length must not exceed the lenth of the base string.
     * 
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string that will be used for 
     *              extracting the sub string from
     * @param _length The length of the sub string to extract
     * @param _offset The starting point to extract the sub string from
     * @return string The extracted sub string
     */

    function _substring(string memory _base, int _length, int _offset) internal pure returns (string memory) {
        bytes memory _baseBytes = bytes(_base);

        assert(uint(_offset+_length) <= _baseBytes.length);

        string memory _tmp = new string(uint(_length));
        bytes memory _tmpBytes = bytes(_tmp);

        uint j = 0;
            for(uint i = uint(_offset); i < uint(_offset+_length); i++) {
                _tmpBytes[j++] = _baseBytes[i];
            }
            return string(_tmpBytes);
        }
}

/**
 * @title Gather Standard Trophies - Gathering-based Non-Fungible ERC721 Tokens 
 * @author Victor Rortvedt (@vrortvedt)
 * This implementation includes all the required and some optional functionality of the ERC721 standard
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract GatherStandardTrophies is ERC721, ERC721Metadata {

    // Address of contract deployer/trophy minter
    address public creator;

     /**
     * @dev Modifier limiting certain functions to creator address
     */
    modifier onlyCreator() {
        require(creator == msg.sender);
        _;
    }

    /**
     * @dev Constructor function
     */
    constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {
        name = _name;
        symbol = _symbol;
        creator = msg.sender;
    }

    /**
     * @dev Mints six standard trophies at conclusion of gathering
     * @param winners Array containing six addresses of trophy winners 
     * @param uri String containing ordered list of all trophies' URI info, in 59 character length chunks pointing to ipfs URL
     */
    function mintStandardTrophies(address[] memory winners, string memory uri) public onlyCreator {
        mintSchmoozerTrophy((winners[0]), _substring(uri,59,0));
        mintCupidTrophy((winners[1]), _substring(uri,59,59));
        mintMVPTrophy((winners[2]), _substring(uri,59,118));
        mintHumanRouterTrophy((winners[3]), _substring(uri,59,177));
        mintOracleTrophy((winners[4]), _substring(uri,59,236));
        mintKevinBaconTrophy((winners[5]), _substring(uri,59,295));
    }

    /**
     * @dev Public function that mints Schmoozer trophy at conclusion of gathering to gatherNode with most connections made
     * @param winner Address of trophy winner 
     * @param uri String containing IPFS link to URI info
     */
    function mintSchmoozerTrophy(address winner, string memory uri) public onlyCreator {
        _mint(winner, 1);
        _tokenNames[1] = "Schmoozer Trophy";
        _tokenURIs[1] = uri;
    }

    /**
     * @dev Public function that mints Cupid trophy at conclusion of gathering to gatherNode with most matches made
     * @param winner Address of trophy winner 
     * @param uri String containing IPFS link to URI info
     */
    function mintCupidTrophy(address winner, string memory uri) public onlyCreator  {
        _mint(winner, 2);
        _tokenNames[2] = "Cupid Trophy";
        _tokenURIs[2] = uri;
    } 
    
    /**
     * @dev Public function that mints  MVP trophy at conclusion of gathering to gatherNode with most total points
     * @param winner Address of trophy winner 
     * @param uri String containing IPFS link to URI info
     */ 
    function mintMVPTrophy(address winner, string memory uri) public onlyCreator {
        _mint(winner, 3);
        _tokenNames[3] = "MVP Trophy";
        _tokenURIs[3] = uri;
    } 

    /**
     * @dev Public function that mints Human Router trophy at conclusion of gathering to gatherNode with most recommendations made
     * @param winner Address of trophy winner 
     * @param uri String containing IPFS link to URI info
     */
    function mintHumanRouterTrophy(address winner, string memory uri) public onlyCreator {
        _mint(winner, 4);
        _tokenNames[4] = "Human Router Trophy";
        _tokenURIs[4] = uri;
    }
    
    /**
     * @dev Public function that mints Oracle trophy at conclusion of gathering to gatherNode with most supermatches 
     * @param winner Address of trophy winner 
     * @param uri String containing IPFS link to URI info
     */
    function mintOracleTrophy(address winner, string memory uri) public onlyCreator {
        _mint(winner, 5);
        _tokenNames[5] = "Oracle Trophy";
        _tokenURIs[5] = uri;
    } 


    /**
     * @dev Public function that mints Kevin Bacon trophy at conclusion of gathering 
     * to gatherNode with fewest average degrees of separation from all other gatherNodes
     * @param winner Address of trophy winner 
     * @param uri String containing IPFS link to URI info
     */
    function mintKevinBaconTrophy(address winner, string memory uri) public onlyCreator {
        _mint(winner, 6);
        _tokenNames[6] = "Kevin Bacon Trophy";
        _tokenURIs[6] = uri;
    }   

}