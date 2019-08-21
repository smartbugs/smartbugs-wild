// File: node_modules\openzeppelin-solidity\contracts\introspection\IERC165.sol

pragma solidity ^0.5.0;

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

// File: node_modules\openzeppelin-solidity\contracts\token\ERC721\IERC721.sol

pragma solidity ^0.5.0;


/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);
    function ownerOf(uint256 tokenId) public view returns (address owner);

    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);

    function transferFrom(address from, address to, uint256 tokenId) public;
    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

// File: node_modules\openzeppelin-solidity\contracts\token\ERC721\IERC721Receiver.sol

pragma solidity ^0.5.0;

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

// File: node_modules\openzeppelin-solidity\contracts\math\SafeMath.sol

pragma solidity ^0.5.0;

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

// File: node_modules\openzeppelin-solidity\contracts\utils\Address.sol

pragma solidity ^0.5.0;

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

// File: node_modules\openzeppelin-solidity\contracts\introspection\ERC165.sol

pragma solidity ^0.5.0;


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

// File: node_modules\openzeppelin-solidity\contracts\token\ERC721\ERC721.sol

pragma solidity ^0.5.0;






/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721 is ERC165, IERC721 {
    using SafeMath for uint256;
    using Address for address;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from token ID to owner
    mapping (uint256 => address) private _tokenOwner;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to number of owned token
    mapping (address => uint256) private _ownedTokensCount;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
    /*
     * 0x80ac58cd ===
     *     bytes4(keccak256('balanceOf(address)')) ^
     *     bytes4(keccak256('ownerOf(uint256)')) ^
     *     bytes4(keccak256('approve(address,uint256)')) ^
     *     bytes4(keccak256('getApproved(uint256)')) ^
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) ^
     *     bytes4(keccak256('isApprovedForAll(address,address)')) ^
     *     bytes4(keccak256('transferFrom(address,address,uint256)')) ^
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^
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
     * @dev Approves another address to transfer the given token ID
     * The zero address indicates there is no approved address.
     * There can only be one approved address per token at a given time.
     * Can only be called by the token owner or an approved operator.
     * @param to address to be approved for the given token ID
     * @param tokenId uint256 ID of the token to be approved
     */
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /**
     * @dev Gets the approved address for a token ID, or zero if no address set
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to query the approval of
     * @return address currently approved for the given token ID
     */
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId));
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev Sets or unsets the approval of a given operator
     * An operator is allowed to transfer all tokens of the sender on their behalf
     * @param to operator address to set the approval
     * @param approved representing the status of the approval to be set
     */
    function setApprovalForAll(address to, bool approved) public {
        require(to != msg.sender);
        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    /**
     * @dev Tells whether an operator is approved by a given owner
     * @param owner owner address which you want to query the approval of
     * @param operator operator address which you want to query the approval of
     * @return bool whether the given operator is approved by the given owner
     */
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev Transfers the ownership of a given token ID to another address
     * Usage of this method is discouraged, use `safeTransferFrom` whenever possible
     * Requires the msg sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
    */
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_isApprovedOrOwner(msg.sender, tokenId));

        _transferFrom(from, to, tokenId);
    }

    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     *
     * Requires the msg sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
    */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
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
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data));
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
     * @dev Returns whether the given spender can transfer a given token ID
     * @param spender address of the spender to query
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     *    is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
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
        _ownedTokensCount[to] = _ownedTokensCount[to].add(1);

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev Internal function to burn a specific token
     * Reverts if the token does not exist
     * Deprecated, use _burn(uint256) instead.
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(address owner, uint256 tokenId) internal {
        require(ownerOf(tokenId) == owner);

        _clearApproval(tokenId);

        _ownedTokensCount[owner] = _ownedTokensCount[owner].sub(1);
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Internal function to burn a specific token
     * Reverts if the token does not exist
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(uint256 tokenId) internal {
        _burn(ownerOf(tokenId), tokenId);
    }

    /**
     * @dev Internal function to transfer ownership of a given token ID to another address.
     * As opposed to transferFrom, this imposes no restrictions on msg.sender.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
    */
    function _transferFrom(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from);
        require(to != address(0));

        _clearApproval(tokenId);

        _ownedTokensCount[from] = _ownedTokensCount[from].sub(1);
        _ownedTokensCount[to] = _ownedTokensCount[to].add(1);

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
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

    /**
     * @dev Private function to clear current approval of a given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _clearApproval(uint256 tokenId) private {
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}

// File: node_modules\openzeppelin-solidity\contracts\token\ERC721\IERC721Enumerable.sol

pragma solidity ^0.5.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract IERC721Enumerable is IERC721 {
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) public view returns (uint256);
}

// File: node_modules\openzeppelin-solidity\contracts\token\ERC721\ERC721Enumerable.sol

pragma solidity ^0.5.0;




/**
 * @title ERC-721 Non-Fungible Token with optional enumeration extension logic
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Enumerable is ERC165, ERC721, IERC721Enumerable {
    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) private _ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private _ownedTokensIndex;

    // Array with all token ids, used for enumeration
    uint256[] private _allTokens;

    // Mapping from token id to position in the allTokens array
    mapping(uint256 => uint256) private _allTokensIndex;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;
    /**
     * 0x780e9d63 ===
     *     bytes4(keccak256('totalSupply()')) ^
     *     bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^
     *     bytes4(keccak256('tokenByIndex(uint256)'))
     */

    /**
     * @dev Constructor function
     */
    constructor () public {
        // register the supported interface to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    /**
     * @dev Gets the token ID at a given index of the tokens list of the requested owner
     * @param owner address owning the tokens list to be accessed
     * @param index uint256 representing the index to be accessed of the requested tokens list
     * @return uint256 token ID at the given index of the tokens list owned by the requested address
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {
        require(index < balanceOf(owner));
        return _ownedTokens[owner][index];
    }

    /**
     * @dev Gets the total amount of tokens stored by the contract
     * @return uint256 representing the total amount of tokens
     */
    function totalSupply() public view returns (uint256) {
        return _allTokens.length;
    }

    /**
     * @dev Gets the token ID at a given index of all the tokens in this contract
     * Reverts if the index is greater or equal to the total number of tokens
     * @param index uint256 representing the index to be accessed of the tokens list
     * @return uint256 token ID at the given index of the tokens list
     */
    function tokenByIndex(uint256 index) public view returns (uint256) {
        require(index < totalSupply());
        return _allTokens[index];
    }

    /**
     * @dev Internal function to transfer ownership of a given token ID to another address.
     * As opposed to transferFrom, this imposes no restrictions on msg.sender.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
    */
    function _transferFrom(address from, address to, uint256 tokenId) internal {
        super._transferFrom(from, to, tokenId);

        _removeTokenFromOwnerEnumeration(from, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);
    }

    /**
     * @dev Internal function to mint a new token
     * Reverts if the given token ID already exists
     * @param to address the beneficiary that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _mint(address to, uint256 tokenId) internal {
        super._mint(to, tokenId);

        _addTokenToOwnerEnumeration(to, tokenId);

        _addTokenToAllTokensEnumeration(tokenId);
    }

    /**
     * @dev Internal function to burn a specific token
     * Reverts if the token does not exist
     * Deprecated, use _burn(uint256) instead
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(address owner, uint256 tokenId) internal {
        super._burn(owner, tokenId);

        _removeTokenFromOwnerEnumeration(owner, tokenId);
        // Since tokenId will be deleted, we can clear its slot in _ownedTokensIndex to trigger a gas refund
        _ownedTokensIndex[tokenId] = 0;

        _removeTokenFromAllTokensEnumeration(tokenId);
    }

    /**
     * @dev Gets the list of token IDs of the requested owner
     * @param owner address owning the tokens
     * @return uint256[] List of token IDs owned by the requested address
     */
    function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {
        return _ownedTokens[owner];
    }

    /**
     * @dev Private function to add a token to this extension's ownership-tracking data structures.
     * @param to address representing the new owner of the given token ID
     * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {
        _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
        _ownedTokens[to].push(tokenId);
    }

    /**
     * @dev Private function to add a token to this extension's token tracking data structures.
     * @param tokenId uint256 ID of the token to be added to the tokens list
     */
    function _addTokenToAllTokensEnumeration(uint256 tokenId) private {
        _allTokensIndex[tokenId] = _allTokens.length;
        _allTokens.push(tokenId);
    }

    /**
     * @dev Private function to remove a token from this extension's ownership-tracking data structures. Note that
     * while the token is not assigned a new owner, the _ownedTokensIndex mapping is _not_ updated: this allows for
     * gas optimizations e.g. when performing a transfer operation (avoiding double writes).
     * This has O(1) time complexity, but alters the order of the _ownedTokens array.
     * @param from address representing the previous owner of the given token ID
     * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {
        // To prevent a gap in from's tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
        uint256 tokenIndex = _ownedTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary
        if (tokenIndex != lastTokenIndex) {
            uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

            _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
            _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
        }

        // This also deletes the contents at the last position of the array
        _ownedTokens[from].length--;

        // Note that _ownedTokensIndex[tokenId] hasn't been cleared: it still points to the old slot (now occcupied by
        // lasTokenId, or just over the end of the array if the token was the last one).
    }

    /**
     * @dev Private function to remove a token from this extension's token tracking data structures.
     * This has O(1) time complexity, but alters the order of the _allTokens array.
     * @param tokenId uint256 ID of the token to be removed from the tokens list
     */
    function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {
        // To prevent a gap in the tokens array, we store the last token in the index of the token to delete, and
        // then delete the last slot (swap and pop).

        uint256 lastTokenIndex = _allTokens.length.sub(1);
        uint256 tokenIndex = _allTokensIndex[tokenId];

        // When the token to delete is the last token, the swap operation is unnecessary. However, since this occurs so
        // rarely (when the last minted token is burnt) that we still do the swap here to avoid the gas cost of adding
        // an 'if' statement (like in _removeTokenFromOwnerEnumeration)
        uint256 lastTokenId = _allTokens[lastTokenIndex];

        _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
        _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

        // This also deletes the contents at the last position of the array
        _allTokens.length--;
        _allTokensIndex[tokenId] = 0;
    }
}

// File: node_modules\openzeppelin-solidity\contracts\token\ERC721\IERC721Metadata.sol

pragma solidity ^0.5.0;


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// File: node_modules\openzeppelin-solidity\contracts\token\ERC721\ERC721Metadata.sol

pragma solidity ^0.5.0;




contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;
    /**
     * 0x5b5e139f ===
     *     bytes4(keccak256('name()')) ^
     *     bytes4(keccak256('symbol()')) ^
     *     bytes4(keccak256('tokenURI(uint256)'))
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
     * @dev Internal function to burn a specific token
     * Reverts if the token does not exist
     * Deprecated, use _burn(uint256) instead
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned by the msg.sender
     */
    function _burn(address owner, uint256 tokenId) internal {
        super._burn(owner, tokenId);

        // Clear metadata (if any)
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

// File: node_modules\openzeppelin-solidity\contracts\token\ERC721\ERC721Full.sol

pragma solidity ^0.5.0;




/**
 * @title Full ERC721 Token
 * This implementation includes all the required and some optional functionality of the ERC721 standard
 * Moreover, it includes approve all functionality using operator terminology
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Full is ERC721, ERC721Enumerable, ERC721Metadata {
    constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {
        // solhint-disable-previous-line no-empty-blocks
    }
}

// File: contracts\GameData.sol

pragma solidity 0.5.0;


contract GameData {
    struct Animal {
        uint256 wildAnimalId;
        uint256 xp;
        uint16 effectiveness;
        uint16[3] accessories;      
    }
}

// File: node_modules\openzeppelin-solidity\contracts\ownership\Ownable.sol

pragma solidity ^0.5.0;

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
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
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

// File: contracts\Restricted.sol

pragma solidity 0.5.0;



contract Restricted is Ownable {
    mapping(address => bool) private addressIsAdmin;
    bool private isActive = true;

    modifier onlyAdmin() {
        require(addressIsAdmin[msg.sender] || msg.sender == owner(), "Sender is not admin");
        _;
    }

    modifier contractIsActive() {
        require(isActive, "Contract is not active");
        _;
    }

    function addAdmin(address adminAddress) public onlyOwner {
        addressIsAdmin[adminAddress] = true;
    }

    function removeAdmin(address adminAddress) public onlyOwner {
        addressIsAdmin[adminAddress] = false;
    }

    function pauseContract() public onlyOwner {
        isActive = false;
    }

    function activateContract() public onlyOwner {
        isActive = true;
    }
}

// File: contracts\IDnaRepository.sol

pragma solidity 0.5.0;


contract IDnaRepository {
    function getDna(uint256 _dnaId)
        public
        view
        returns(
            uint animalId,
            address owner,
            uint16 effectiveness,
            uint256 id
        );
}

// File: contracts\IServal.sol

pragma solidity 0.5.0;



contract IServal is IDnaRepository {
    function getAnimal(uint256 _animalId)
        public
        view
        returns(
            uint256 countryId,
            bytes32 name,
            uint8 rarity,
            uint256 currentValue,
            uint256 targetValue,
            address owner,
            uint256 id
        );
}

// File: contracts\IMarketplace.sol

pragma solidity 0.5.0;


contract IMarketplace {
    function createAuction(
        uint256 _tokenId,
        uint128 startPrice,
        uint128 endPrice,
        uint128 duration
    )
        external;
}

// File: contracts\CryptoServalV2.sol

pragma solidity 0.5.0;









contract CryptoServalV2 is ERC721Full("CryptoServalGame", "CSG"), GameData, Restricted {
    address private servalChainAddress;
    IServal private cryptoServalContract;
    IDnaRepository private dnaRepositoryContract;
    IMarketplace private marketplaceContract;

    mapping(uint256 => bool) private usedNonces;
    mapping(address => uint256) private addressToGems;

    mapping(bytes32 => bool) private withdrawnHashedContractAnimals;
    mapping(bytes32 => bool) private withdrawnHashedRepositoryAnimals;

    Animal[] internal animals;

    uint256 private syncCost = 0.003 ether;
    uint256 private spawnCost = 0.01 ether;

    uint256 private spawnWindow = 1 hours;
    uint256[3] private rarityToSpawnGemCost = [30, 60, 90];

    using SafeMath for uint256;

    event GemsAddedEvent(
        address to,
        uint256 gemAmount
    );

    event XpAddedEvent(
        uint256 animalId,
        uint256 xpAmount
    );

    event AccessoryAddedEvent(
        uint256 animalId,
        uint8 accessorySlot,
        uint16 accessoryId
    );

    function setServalChainAddress(address newServalChainAddress) external onlyAdmin() {
        servalChainAddress = newServalChainAddress;
    }

    function setCryptoServalContract(address cryptoServalContractAddress) external onlyAdmin() {
        cryptoServalContract = IServal(cryptoServalContractAddress);
    }

    function setDnaRepositoryContract(address dnaRepositoryContractAddress) external onlyAdmin() {
        dnaRepositoryContract = IDnaRepository(dnaRepositoryContractAddress);
    }

    function setMarketplaceContract(address marketplaceContractAddress) external onlyAdmin() {
        marketplaceContract = IMarketplace(marketplaceContractAddress);
    }

    function setSyncCost(uint256 _syncCost) external onlyAdmin() {
        syncCost = _syncCost;
    }

    function setSpawnCost(uint256 _spawnCost) external onlyAdmin() {
        spawnCost = _spawnCost;
    }

    function setRarityToSpawnGemCost(uint8 index, uint256 targetValue) external onlyAdmin {
        rarityToSpawnGemCost[index] = targetValue;
    }

    function sequenceContractDna(uint256 wildAnimalId, uint256[] calldata dnaIds) external {
        require(!isWithdrawnFromContract(msg.sender, wildAnimalId), "Animal was already minted from contract");  
        withdrawnHashedContractAnimals[keccak256(abi.encodePacked(msg.sender, wildAnimalId))] = true;
        sequenceDna(wildAnimalId, dnaIds, cryptoServalContract);  
    }

    function sequenceRepositoryDna(uint256 wildAnimalId, uint256[] calldata dnaIds) external {
        require(!isWithdrawnFromRepository(msg.sender, wildAnimalId), "Animal was already minted from repository");  
        withdrawnHashedRepositoryAnimals[keccak256(abi.encodePacked(msg.sender, wildAnimalId))] = true;
        sequenceDna(wildAnimalId, dnaIds, dnaRepositoryContract);  
    }

    function spawnOffspring(
        uint256 wildAnimalId,
        uint16 effectiveness,
        uint256 timestamp,
        uint256 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
        )
        external
        payable
        usesNonce(nonce)
        spawnPriced()
    {        
        require(now < timestamp.add(spawnWindow), "Animal spawn expired");
        require(effectiveness <= 100, "Invalid effectiveness");
        require(isServalChainSigner(
                keccak256(abi.encodePacked(wildAnimalId, effectiveness, timestamp, nonce, msg.sender, this)),
                v,
                r,
                s
            ), "Invalid signature");

        uint8 rarity;
        (, , rarity, , , ,) = cryptoServalContract.getAnimal(wildAnimalId);
        // SafeMath reverts if sender does not have enough gems
        addressToGems[msg.sender] = addressToGems[msg.sender].sub(rarityToSpawnGemCost[rarity]);
        mintAnimal(wildAnimalId, effectiveness, msg.sender);
    }
        
    function requestGems(
        uint256 amount,
        uint256 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
        )
        external
        payable        
        usesNonce(nonce)
        syncPriced()
    {
        require(isServalChainSigner(
            keccak256(abi.encodePacked(amount, nonce, msg.sender, this)), v, r, s),
            "Invalid signature"
            );        
        addGems(msg.sender, amount);        
    }

    function addXp(
        uint256 animalId,
        uint256 xpToAdd,
        uint256 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
        )
        external
        payable
        syncPriced()
        usesNonce(nonce)
    {
        require(isServalChainSigner(
            keccak256(abi.encodePacked(animalId, xpToAdd, nonce, msg.sender, this)), v, r, s),
            "Invalid signature"
            );
        animals[animalId].xp = animals[animalId].xp.add(xpToAdd);

        emit XpAddedEvent(animalId, xpToAdd);
    }
      
    function addAccessories(
        uint256 animalId,
        uint8 accessorySlot,
        uint16 accessoryId,
        uint256 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
        )
        external
        payable
        syncPriced()      
        usesNonce(nonce)
    {
        require(isServalChainSigner(
                keccak256(abi.encodePacked(animalId, accessorySlot, accessoryId, nonce, msg.sender, this)),
                v,
                r,
                s
            ),
            "Invalid signature"
            );        
        require(msg.sender == ownerOf(animalId));
        require(animals[animalId].accessories[accessorySlot] == 0);     
        
        animals[animalId].accessories[accessorySlot] = accessoryId;
        emit AccessoryAddedEvent(animalId, accessorySlot, accessoryId);
    }

    function fuseAnimal(uint256 animalId) external payable syncPriced() {        
        Animal memory animal = animals[animalId];

        address wildAnimalOwner;
        uint8 rarity;
        (, , rarity, , , wildAnimalOwner,) = cryptoServalContract.getAnimal(animal.wildAnimalId);
        
        uint256 gemsToAdd = uint256(animal.effectiveness).div(4);
        uint256 rarityMultiplier = uint256(rarity).add(1);

        if (gemsToAdd > 2) {            
            gemsToAdd = gemsToAdd.mul(rarityMultiplier);
        }

        _burn(msg.sender, animalId);
        delete animals[animalId];

        addGems(msg.sender, gemsToAdd);
        addGems(wildAnimalOwner, rarityMultiplier.mul(5));
    }

    function createAuction(
        uint256 _tokenId,
        uint128 startPrice,
        uint128 endPrice,
        uint128 duration
    )
        external
    {
        // approve, not a transfer, let marketplace confirm the original owner and take ownership
        approve(address(marketplaceContract), _tokenId);
        marketplaceContract.createAuction(_tokenId, startPrice, endPrice, duration);
    } 

    function getAnimal(uint256 animalId)
    external
    view
    returns(
        address owner,
        uint256 wildAnimalId,
        uint256 xp,
        uint16 effectiveness,
        uint16[3] memory accessories
    )
    {
        Animal memory animal = animals[animalId];
        return (
            ownerOf(animalId),
            animal.wildAnimalId,
            animal.xp,
            animal.effectiveness,
            animal.accessories
        );
    }

    function getPlayerAnimals(address playerAddress)
        external
        view
        returns(uint256[] memory)
    {
        return _tokensOfOwner(playerAddress);
    }

    function getPlayerGems(address addr) external view returns(uint256) {
        return addressToGems[addr];
    }

    function getSyncCost() external view returns(uint256) {
        return syncCost;
    }

    function getSpawnCost() external view returns(uint256) {
        return spawnCost;
    }

    function getRarityToSpawnGemCost(uint8 index) public view returns(uint256) {
        return rarityToSpawnGemCost[index];
    }

    function isWithdrawnFromContract(address owner, uint256 wildAnimalId) public view returns(bool) {
        return withdrawnHashedContractAnimals[keccak256(abi.encodePacked(owner, wildAnimalId))];
    }

    function isWithdrawnFromRepository(address owner, uint256 wildAnimalId) public view returns(bool) {
        return withdrawnHashedRepositoryAnimals[keccak256(abi.encodePacked(owner, wildAnimalId))]; 
    }

    function isServalChainSigner(bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public view returns (bool) {
        return servalChainAddress == ecrecover(msgHash, v, r, s);
    }

    function withdrawContract() public onlyOwner {
        msg.sender.transfer(address(this).balance);
    }

    function sequenceDna(uint256 animalToSpawn, uint256[] memory dnaIds, IDnaRepository dnaContract) private {
        uint256 highestEffectiveness = 0;
        uint256 sumOfEffectiveness = 0;

        require(!hasDuplicateMember(dnaIds), "DNA array contains the same cards");
        
        for (uint256 i = 0; i < dnaIds.length; i++) {
            uint animalId;
            address owner;
            uint16 effectiveness;
            uint256 id;

            (animalId, owner, effectiveness, id) = dnaContract.getDna(dnaIds[i]);

            require(animalId == animalToSpawn, "Provided DNA has incorrect wild animal id");
            require(msg.sender == owner, "Sender is not owner of DNA");

            if (effectiveness > highestEffectiveness) { 
                highestEffectiveness = effectiveness;
            }

            sumOfEffectiveness = sumOfEffectiveness.add(effectiveness);
        }
        
        uint256 effectivenessBonus = (sumOfEffectiveness.sub(highestEffectiveness)).div(10); 
        uint256 finalEffectiveness = highestEffectiveness.add(effectivenessBonus);
        if (finalEffectiveness > 100) {
            addGems(msg.sender, finalEffectiveness.sub(100));
            
            finalEffectiveness = 100;            
        }
        
        mintAnimal(animalToSpawn, uint16(finalEffectiveness), msg.sender);
    }

    function hasDuplicateMember(uint256[] memory uintArray) private pure returns(bool) {
        uint256 uintArrayLength = uintArray.length;
        for (uint256 i = 0; i < uintArrayLength - 1; i++) {
            for (uint256 u = i + 1; u < uintArrayLength; u++) {
                if (uintArray[i] == uintArray[u]) {
                    return true;
                }
            }
        }

        return false;
    }

    function mintAnimal(uint256 wildAnimalId, uint16 effectiveness, address mintTo) private
    {
        Animal memory animal = Animal(
            wildAnimalId,
            0,
            effectiveness,
            [uint16(0), uint16(0), uint16(0)]
        ); 
        uint256 id = animals.length; // id before push
        animals.push(animal);
        _mint(mintTo, id);
    }

    function addGems(address receiver, uint256 gemsCount) private {
        addressToGems[receiver] = addressToGems[receiver].add(gemsCount);

        emit GemsAddedEvent(receiver, gemsCount);
    }

    modifier usesNonce(uint256 nonce) {
        require(!usedNonces[nonce], "Nonce already used");
        usedNonces[nonce] = true;
        _;
    }

    modifier syncPriced() {
        require(msg.value == syncCost, "Sync price not paid");
        _;
    }

    modifier spawnPriced() {
        require(msg.value == spawnCost, "Mint price not paid");
        _;
    }
}