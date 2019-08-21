pragma solidity ^0.4.18;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title ERC721 interface
 * @dev see https://github.com/ethereum/eips/issues/721
 */
contract ERC721 {
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _tokenId
    );
    event Approval(
        address indexed _owner,
        address indexed _approved,
        uint256 _tokenId
    );

    function balanceOf(address _owner) public view returns (uint256 _balance);

    function ownerOf(uint256 _tokenId) public view returns (address _owner);

    function transfer(address _to, uint256 _tokenId) public;

    function approve(address _to, uint256 _tokenId) public;

    function takeOwnership(uint256 _tokenId) public;
}

// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token/ERC721/ERC721Token.sol

/**
 * @title ERC721Token
 * Generic implementation for the required functionality of the ERC721 standard
 */
contract NFTKred is ERC721 {
    using SafeMath for uint256;

    // Public variables of the contract
    string public name;
    string public symbol;

    // Most Ethereum contracts use 18 decimals, but we restrict it to 7 here
    // for portability to and from Stellar.
    uint8 public valueDecimals = 7;

    // Numeric data
    mapping(uint => uint) public nftBatch;
    mapping(uint => uint) public nftSequence;
    mapping(uint => uint) public nftCount;

    // The face value of the NFT must be intrinsic so that smart contracts can work with it
    // Sale price and last sale price are available via the metadata endpoints
    mapping(uint => uint256) public nftValue;

    // NFT strings - these are expensive to store, but necessary for API compatibility
    // And string manipulation is also expensive

    // Not to be confused with name(), which returns the contract name
    mapping(uint => string) public nftName;

    // The NFT type, e.g. coin, card, badge, ticket
    mapping(uint => string) public nftType;

    // API address of standard metadata
    mapping(uint => string) public nftURIs;

    // IPFS address of extended metadata
    mapping(uint => string) public tokenIPFSs;

    // Total amount of tokens
    uint256 private totalTokens;

    // Mapping from token ID to owner
    mapping(uint256 => address) private tokenOwner;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private tokenApprovals;

    // Mapping from owner to list of owned token IDs
    mapping(address => uint256[]) private ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private ownedTokensIndex;

    // Metadata accessors
    function name() external view returns (string _name) {
        return name;
    }

    function symbol() external view returns (string _symbol) {
        return symbol;
    }

    function tokenURI(uint256 _tokenId) public view returns (string) {
        require(exists(_tokenId));
        return nftURIs[_tokenId];
    }

    function tokenIPFS(uint256 _tokenId) public view returns (string) {
        require(exists(_tokenId));
        return tokenIPFSs[_tokenId];
    }

    /**
    * @dev Returns whether the specified token exists
    * @param _tokenId uint256 ID of the token to query the existence of
    * @return whether the token exists
    */
    function exists(uint256 _tokenId) public view returns (bool) {
        address owner = tokenOwner[_tokenId];
        return owner != address(0);
    }

    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    /* constructor( */
    constructor(
        string tokenName,
        string tokenSymbol
    ) public {
        name = tokenName;
        // Set the name for display purposes
        symbol = tokenSymbol;
        // Set the symbol for display purposes
    }

    /**
    * @dev Guarantees msg.sender is owner of the given token
    * @param _tokenId uint256 ID of the token to validate its ownership belongs to msg.sender
    */
    modifier onlyOwnerOf(uint256 _tokenId) {
        require(ownerOf(_tokenId) == msg.sender);
        _;
    }

    /**
    * @dev Gets the total amount of tokens stored by the contract
    * @return uint256 representing the total amount of tokens
    */
    function totalSupply() public view returns (uint256) {
        return totalTokens;
    }

    /**
    * @dev Gets the balance of the specified address
    * @param _owner address to query the balance of
    * @return uint256 representing the amount owned by the passed address
    */
    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0));
        return ownedTokens[_owner].length;
    }

    /**
    * @dev Gets the list of tokens owned by a given address
    * @param _owner address to query the tokens of
    * @return uint256[] representing the list of tokens owned by the passed address
    */
    function tokensOf(address _owner) public view returns (uint256[]) {
        return ownedTokens[_owner];
    }

    /**
    * @dev Gets the owner of the specified token ID
    * @param _tokenId uint256 ID of the token to query the owner of
    * @return owner address currently marked as the owner of the given token ID
    */
    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = tokenOwner[_tokenId];
        require(owner != address(0));
        return owner;
    }

    /**
     * @dev Gets the approved address to take ownership of a given token ID
     * @param _tokenId uint256 ID of the token to query the approval of
     * @return address currently approved to take ownership of the given token ID
     */
    function approvedFor(uint256 _tokenId) public view returns (address) {
        return tokenApprovals[_tokenId];
    }

    /**
    * @dev Transfers the ownership of a given token ID to another address
    * @param _to address to receive the ownership of the given token ID
    * @param _tokenId uint256 ID of the token to be transferred
    */
    function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        clearApprovalAndTransfer(msg.sender, _to, _tokenId);
    }

    /**
    * @dev Approves another address to claim for the ownership of the given token ID
    * @param _to address to be approved for the given token ID
    * @param _tokenId uint256 ID of the token to be approved
    */
    function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        address owner = ownerOf(_tokenId);
        require(_to != owner);
        if (approvedFor(_tokenId) != 0 || _to != 0) {
            tokenApprovals[_tokenId] = _to;
            emit Approval(owner, _to, _tokenId);
        }
    }

    /**
    * @dev Claims the ownership of a given token ID
    * @param _tokenId uint256 ID of the token being claimed by the msg.sender
    */
    function takeOwnership(uint256 _tokenId) public {
        require(isApprovedFor(msg.sender, _tokenId));
        clearApprovalAndTransfer(ownerOf(_tokenId), msg.sender, _tokenId);
    }

    // Mint an NFT - should this be a smart contract function dependent on CKr tokens?
    function mint(
        address _to,
        uint256 _tokenId,
        uint _batch,
        uint _sequence,
        uint _count,
        uint256 _value,
        string _type,
        string _IPFS,
        string _tokenURI
    ) public /* onlyNonexistentToken(_tokenId) */
    {
        // Addresses for direct test (Ethereum wallet) and live test (Geth server)
        require(
            msg.sender == 0x979e636D308E86A2D9cB9B2eA5986d6E2f89FcC1 ||
            msg.sender == 0x0fEB00CAe329050915035dF479Ce6DBf747b01Fd
        );
        require(_to != address(0));
        require(nftValue[_tokenId] == 0);

        // Batch details - also available from the metadata endpoints
        nftBatch[_tokenId] = _batch;
        nftSequence[_tokenId] = _sequence;
        nftCount[_tokenId] = _count;

        // Value in CKr + 7 trailing zeroes (to reflect Stellar)
        nftValue[_tokenId] = _value;

        // Token type
        nftType[_tokenId] = _type;

        // Metadata access via IPFS (canonical URL)
        tokenIPFSs[_tokenId] = _IPFS;

        // Metadata access via API (canonical url - add /{platform} for custom-formatted data for your platform
        nftURIs[_tokenId] = _tokenURI;

        addToken(_to, _tokenId);
        emit Transfer(address(0), _to, _tokenId);
    }


    /**
    * @dev Burns a specific token
    * @param _tokenId uint256 ID of the token being burned by the msg.sender
    */
    function _burn(uint256 _tokenId) onlyOwnerOf(_tokenId) internal {
        if (approvedFor(_tokenId) != 0) {
            clearApproval(msg.sender, _tokenId);
        }
        removeToken(msg.sender, _tokenId);
        emit Transfer(msg.sender, 0x0, _tokenId);
    }

    /**
     * @dev Tells whether the msg.sender is approved for the given token ID or not
     * This function is not private so it can be extended in further implementations like the operatable ERC721
     * @param _owner address of the owner to query the approval of
     * @param _tokenId uint256 ID of the token to query the approval of
     * @return bool whether the msg.sender is approved for the given token ID or not
     */
    function isApprovedFor(address _owner, uint256 _tokenId) internal view returns (bool) {
        return approvedFor(_tokenId) == _owner;
    }

    /**
    * @dev Internal function to clear current approval and transfer the ownership of a given token ID
    * @param _from address which you want to send tokens from
    * @param _to address which you want to transfer the token to
    * @param _tokenId uint256 ID of the token to be transferred
    */
    function clearApprovalAndTransfer(address _from, address _to, uint256 _tokenId) internal {
        require(_to != address(0));
        require(_to != ownerOf(_tokenId));
        require(ownerOf(_tokenId) == _from);

        clearApproval(_from, _tokenId);
        removeToken(_from, _tokenId);
        addToken(_to, _tokenId);
        emit Transfer(_from, _to, _tokenId);
    }

    /**
    * @dev Internal function to clear current approval of a given token ID
    * @param _tokenId uint256 ID of the token to be transferred
    */
    function clearApproval(address _owner, uint256 _tokenId) private {
        require(ownerOf(_tokenId) == _owner);
        tokenApprovals[_tokenId] = 0;
        emit Approval(_owner, 0, _tokenId);
    }

    /**
    * @dev Internal function to add a token ID to the list of a given address
    * @param _to address representing the new owner of the given token ID
    * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
    */
    function addToken(address _to, uint256 _tokenId) private {
        require(tokenOwner[_tokenId] == address(0));
        tokenOwner[_tokenId] = _to;
        uint256 length = balanceOf(_to);
        ownedTokens[_to].push(_tokenId);
        ownedTokensIndex[_tokenId] = length;
        totalTokens = totalTokens.add(1);
    }

    /**
    * @dev Internal function to remove a token ID from the list of a given address
    * @param _from address representing the previous owner of the given token ID
    * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
    */
    function removeToken(address _from, uint256 _tokenId) private {
        require(ownerOf(_tokenId) == _from);

        uint256 tokenIndex = ownedTokensIndex[_tokenId];
        uint256 lastTokenIndex = balanceOf(_from).sub(1);
        uint256 lastToken = ownedTokens[_from][lastTokenIndex];

        tokenOwner[_tokenId] = 0;
        ownedTokens[_from][tokenIndex] = lastToken;
        ownedTokens[_from][lastTokenIndex] = 0;
        // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to
        // be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we are first swapping
        // the lastToken to the first position, and then dropping the element placed in the last position of the list

        ownedTokens[_from].length--;
        ownedTokensIndex[_tokenId] = 0;
        ownedTokensIndex[lastToken] = tokenIndex;
        totalTokens = totalTokens.sub(1);
    }

    /**
    * @dev Returns `true` if the contract implements `interfaceID` and `interfaceID` is not 0xffffffff, `false` otherwise
    * @param  _interfaceID The interface identifier, as specified in ERC-165
    */
    function supportsInterface(bytes4 _interfaceID) public pure returns (bool) {

        if (_interfaceID == 0xffffffff) {
            return false;
        }
        return _interfaceID == 0x01ffc9a7 ||  // From ERC721Base
               _interfaceID == 0x7c0633c6 ||  // From ERC721Base
               _interfaceID == 0x80ac58cd ||  // ERC721
               _interfaceID == 0x5b5e139f;    // ERC712Metadata
    }
}