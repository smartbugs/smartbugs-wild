pragma solidity 0.4.25;

// File: openzeppelin-solidity/contracts/introspection/ERC165.sol

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

// File: openzeppelin-solidity/contracts/introspection/SupportsInterfaceWithLookup.sol

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

// File: openzeppelin-solidity/contracts/token/ERC721/ERC721Basic.sol

/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Basic is ERC165 {

  bytes4 internal constant InterfaceId_ERC721 = 0x80ac58cd;
  /*
   * 0x80ac58cd ===
   *   bytes4(keccak256('balanceOf(address)')) ^
   *   bytes4(keccak256('ownerOf(uint256)')) ^
   *   bytes4(keccak256('approve(address,uint256)')) ^
   *   bytes4(keccak256('getApproved(uint256)')) ^
   *   bytes4(keccak256('setApprovalForAll(address,bool)')) ^
   *   bytes4(keccak256('isApprovedForAll(address,address)')) ^
   *   bytes4(keccak256('transferFrom(address,address,uint256)')) ^
   *   bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^
   *   bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'))
   */

  bytes4 internal constant InterfaceId_ERC721Exists = 0x4f558e79;
  /*
   * 0x4f558e79 ===
   *   bytes4(keccak256('exists(uint256)'))
   */

  bytes4 internal constant InterfaceId_ERC721Enumerable = 0x780e9d63;
  /**
   * 0x780e9d63 ===
   *   bytes4(keccak256('totalSupply()')) ^
   *   bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^
   *   bytes4(keccak256('tokenByIndex(uint256)'))
   */

  bytes4 internal constant InterfaceId_ERC721Metadata = 0x5b5e139f;
  /**
   * 0x5b5e139f ===
   *   bytes4(keccak256('name()')) ^
   *   bytes4(keccak256('symbol()')) ^
   *   bytes4(keccak256('tokenURI(uint256)'))
   */

  event Transfer(
    address indexed _from,
    address indexed _to,
    uint256 indexed _tokenId
  );
  event Approval(
    address indexed _owner,
    address indexed _approved,
    uint256 indexed _tokenId
  );
  event ApprovalForAll(
    address indexed _owner,
    address indexed _operator,
    bool _approved
  );

  function balanceOf(address _owner) public view returns (uint256 _balance);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  function exists(uint256 _tokenId) public view returns (bool _exists);

  function approve(address _to, uint256 _tokenId) public;
  function getApproved(uint256 _tokenId)
    public view returns (address _operator);

  function setApprovalForAll(address _operator, bool _approved) public;
  function isApprovedForAll(address _owner, address _operator)
    public view returns (bool);

  function transferFrom(address _from, address _to, uint256 _tokenId) public;
  function safeTransferFrom(address _from, address _to, uint256 _tokenId)
    public;

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    public;
}

// File: openzeppelin-solidity/contracts/token/ERC721/ERC721.sol

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Enumerable is ERC721Basic {
  function totalSupply() public view returns (uint256);
  function tokenOfOwnerByIndex(
    address _owner,
    uint256 _index
  )
    public
    view
    returns (uint256 _tokenId);

  function tokenByIndex(uint256 _index) public view returns (uint256);
}


/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Metadata is ERC721Basic {
  function name() external view returns (string _name);
  function symbol() external view returns (string _symbol);
  function tokenURI(uint256 _tokenId) public view returns (string);
}


/**
 * @title ERC-721 Non-Fungible Token Standard, full implementation interface
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {
}

// File: openzeppelin-solidity/contracts/token/ERC721/ERC721Receiver.sol

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
contract ERC721Receiver {
  /**
   * @dev Magic value to be returned upon successful reception of an NFT
   *  Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`,
   *  which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
   */
  bytes4 internal constant ERC721_RECEIVED = 0x150b7a02;

  /**
   * @notice Handle the receipt of an NFT
   * @dev The ERC721 smart contract calls this function on the recipient
   * after a `safetransfer`. This function MAY throw to revert and reject the
   * transfer. Return of other than the magic value MUST result in the
   * transaction being reverted.
   * Note: the contract address is always the message sender.
   * @param _operator The address which called `safeTransferFrom` function
   * @param _from The address which previously owned the token
   * @param _tokenId The NFT identifier which is being transferred
   * @param _data Additional data with no specified format
   * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
   */
  function onERC721Received(
    address _operator,
    address _from,
    uint256 _tokenId,
    bytes _data
  )
    public
    returns(bytes4);
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

// File: openzeppelin-solidity/contracts/AddressUtils.sol

/**
 * Utility library of inline functions on addresses
 */
library AddressUtils {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   * as the code is not actually created until after the constructor finishes.
   * @param _addr address to check
   * @return whether the target address is a contract
   */
  function isContract(address _addr) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    // solium-disable-next-line security/no-inline-assembly
    assembly { size := extcodesize(_addr) }
    return size > 0;
  }

}

// File: openzeppelin-solidity/contracts/token/ERC721/ERC721BasicToken.sol

/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721BasicToken is SupportsInterfaceWithLookup, ERC721Basic {

  using SafeMath for uint256;
  using AddressUtils for address;

  // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
  // which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
  bytes4 private constant ERC721_RECEIVED = 0x150b7a02;

  // Mapping from token ID to owner
  mapping (uint256 => address) internal tokenOwner;

  // Mapping from token ID to approved address
  mapping (uint256 => address) internal tokenApprovals;

  // Mapping from owner to number of owned token
  mapping (address => uint256) internal ownedTokensCount;

  // Mapping from owner to operator approvals
  mapping (address => mapping (address => bool)) internal operatorApprovals;

  constructor()
    public
  {
    // register the supported interfaces to conform to ERC721 via ERC165
    _registerInterface(InterfaceId_ERC721);
    _registerInterface(InterfaceId_ERC721Exists);
  }

  /**
   * @dev Gets the balance of the specified address
   * @param _owner address to query the balance of
   * @return uint256 representing the amount owned by the passed address
   */
  function balanceOf(address _owner) public view returns (uint256) {
    require(_owner != address(0));
    return ownedTokensCount[_owner];
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
   * @dev Returns whether the specified token exists
   * @param _tokenId uint256 ID of the token to query the existence of
   * @return whether the token exists
   */
  function exists(uint256 _tokenId) public view returns (bool) {
    address owner = tokenOwner[_tokenId];
    return owner != address(0);
  }

  /**
   * @dev Approves another address to transfer the given token ID
   * The zero address indicates there is no approved address.
   * There can only be one approved address per token at a given time.
   * Can only be called by the token owner or an approved operator.
   * @param _to address to be approved for the given token ID
   * @param _tokenId uint256 ID of the token to be approved
   */
  function approve(address _to, uint256 _tokenId) public {
    address owner = ownerOf(_tokenId);
    require(_to != owner);
    require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

    tokenApprovals[_tokenId] = _to;
    emit Approval(owner, _to, _tokenId);
  }

  /**
   * @dev Gets the approved address for a token ID, or zero if no address set
   * @param _tokenId uint256 ID of the token to query the approval of
   * @return address currently approved for the given token ID
   */
  function getApproved(uint256 _tokenId) public view returns (address) {
    return tokenApprovals[_tokenId];
  }

  /**
   * @dev Sets or unsets the approval of a given operator
   * An operator is allowed to transfer all tokens of the sender on their behalf
   * @param _to operator address to set the approval
   * @param _approved representing the status of the approval to be set
   */
  function setApprovalForAll(address _to, bool _approved) public {
    require(_to != msg.sender);
    operatorApprovals[msg.sender][_to] = _approved;
    emit ApprovalForAll(msg.sender, _to, _approved);
  }

  /**
   * @dev Tells whether an operator is approved by a given owner
   * @param _owner owner address which you want to query the approval of
   * @param _operator operator address which you want to query the approval of
   * @return bool whether the given operator is approved by the given owner
   */
  function isApprovedForAll(
    address _owner,
    address _operator
  )
    public
    view
    returns (bool)
  {
    return operatorApprovals[_owner][_operator];
  }

  /**
   * @dev Transfers the ownership of a given token ID to another address
   * Usage of this method is discouraged, use `safeTransferFrom` whenever possible
   * Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
  */
  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    public
  {
    require(isApprovedOrOwner(msg.sender, _tokenId));
    require(_from != address(0));
    require(_to != address(0));

    clearApproval(_from, _tokenId);
    removeTokenFrom(_from, _tokenId);
    addTokenTo(_to, _tokenId);

    emit Transfer(_from, _to, _tokenId);
  }

  /**
   * @dev Safely transfers the ownership of a given token ID to another address
   * If the target address is a contract, it must implement `onERC721Received`,
   * which is called upon a safe transfer, and return the magic value
   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
   * the transfer is reverted.
   *
   * Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
  */
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    public
  {
    // solium-disable-next-line arg-overflow
    safeTransferFrom(_from, _to, _tokenId, "");
  }

  /**
   * @dev Safely transfers the ownership of a given token ID to another address
   * If the target address is a contract, it must implement `onERC721Received`,
   * which is called upon a safe transfer, and return the magic value
   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
   * the transfer is reverted.
   * Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
   * @param _data bytes data to send along with a safe transfer check
   */
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    public
  {
    transferFrom(_from, _to, _tokenId);
    // solium-disable-next-line arg-overflow
    require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
  }

  /**
   * @dev Returns whether the given spender can transfer a given token ID
   * @param _spender address of the spender to query
   * @param _tokenId uint256 ID of the token to be transferred
   * @return bool whether the msg.sender is approved for the given token ID,
   *  is an operator of the owner, or is the owner of the token
   */
  function isApprovedOrOwner(
    address _spender,
    uint256 _tokenId
  )
    internal
    view
    returns (bool)
  {
    address owner = ownerOf(_tokenId);
    // Disable solium check because of
    // https://github.com/duaraghav8/Solium/issues/175
    // solium-disable-next-line operator-whitespace
    return (
      _spender == owner ||
      getApproved(_tokenId) == _spender ||
      isApprovedForAll(owner, _spender)
    );
  }

  /**
   * @dev Internal function to mint a new token
   * Reverts if the given token ID already exists
   * @param _to The address that will own the minted token
   * @param _tokenId uint256 ID of the token to be minted by the msg.sender
   */
  function _mint(address _to, uint256 _tokenId) internal {
    require(_to != address(0));
    addTokenTo(_to, _tokenId);
    emit Transfer(address(0), _to, _tokenId);
  }

  /**
   * @dev Internal function to burn a specific token
   * Reverts if the token does not exist
   * @param _tokenId uint256 ID of the token being burned by the msg.sender
   */
  function _burn(address _owner, uint256 _tokenId) internal {
    clearApproval(_owner, _tokenId);
    removeTokenFrom(_owner, _tokenId);
    emit Transfer(_owner, address(0), _tokenId);
  }

  /**
   * @dev Internal function to clear current approval of a given token ID
   * Reverts if the given address is not indeed the owner of the token
   * @param _owner owner of the token
   * @param _tokenId uint256 ID of the token to be transferred
   */
  function clearApproval(address _owner, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _owner);
    if (tokenApprovals[_tokenId] != address(0)) {
      tokenApprovals[_tokenId] = address(0);
    }
  }

  /**
   * @dev Internal function to add a token ID to the list of a given address
   * @param _to address representing the new owner of the given token ID
   * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
   */
  function addTokenTo(address _to, uint256 _tokenId) internal {
    require(tokenOwner[_tokenId] == address(0));
    tokenOwner[_tokenId] = _to;
    ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
  }

  /**
   * @dev Internal function to remove a token ID from the list of a given address
   * @param _from address representing the previous owner of the given token ID
   * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
   */
  function removeTokenFrom(address _from, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _from);
    ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
    tokenOwner[_tokenId] = address(0);
  }

  /**
   * @dev Internal function to invoke `onERC721Received` on a target address
   * The call is not executed if the target address is not a contract
   * @param _from address representing the previous owner of the given token ID
   * @param _to target address that will receive the tokens
   * @param _tokenId uint256 ID of the token to be transferred
   * @param _data bytes optional data to send along with the call
   * @return whether the call correctly returned the expected magic value
   */
  function checkAndCallSafeTransfer(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    internal
    returns (bool)
  {
    if (!_to.isContract()) {
      return true;
    }
    bytes4 retval = ERC721Receiver(_to).onERC721Received(
      msg.sender, _from, _tokenId, _data);
    return (retval == ERC721_RECEIVED);
  }
}

// File: openzeppelin-solidity/contracts/token/ERC721/ERC721Token.sol

/**
 * @title Full ERC721 Token
 * This implementation includes all the required and some optional functionality of the ERC721 standard
 * Moreover, it includes approve all functionality using operator terminology
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Token is SupportsInterfaceWithLookup, ERC721BasicToken, ERC721 {

  // Token name
  string internal name_;

  // Token symbol
  string internal symbol_;

  // Mapping from owner to list of owned token IDs
  mapping(address => uint256[]) internal ownedTokens;

  // Mapping from token ID to index of the owner tokens list
  mapping(uint256 => uint256) internal ownedTokensIndex;

  // Array with all token ids, used for enumeration
  uint256[] internal allTokens;

  // Mapping from token id to position in the allTokens array
  mapping(uint256 => uint256) internal allTokensIndex;

  // Optional mapping for token URIs
  mapping(uint256 => string) internal tokenURIs;

  /**
   * @dev Constructor function
   */
  constructor(string _name, string _symbol) public {
    name_ = _name;
    symbol_ = _symbol;

    // register the supported interfaces to conform to ERC721 via ERC165
    _registerInterface(InterfaceId_ERC721Enumerable);
    _registerInterface(InterfaceId_ERC721Metadata);
  }

  /**
   * @dev Gets the token name
   * @return string representing the token name
   */
  function name() external view returns (string) {
    return name_;
  }

  /**
   * @dev Gets the token symbol
   * @return string representing the token symbol
   */
  function symbol() external view returns (string) {
    return symbol_;
  }

  /**
   * @dev Returns an URI for a given token ID
   * Throws if the token ID does not exist. May return an empty string.
   * @param _tokenId uint256 ID of the token to query
   */
  function tokenURI(uint256 _tokenId) public view returns (string) {
    require(exists(_tokenId));
    return tokenURIs[_tokenId];
  }

  /**
   * @dev Gets the token ID at a given index of the tokens list of the requested owner
   * @param _owner address owning the tokens list to be accessed
   * @param _index uint256 representing the index to be accessed of the requested tokens list
   * @return uint256 token ID at the given index of the tokens list owned by the requested address
   */
  function tokenOfOwnerByIndex(
    address _owner,
    uint256 _index
  )
    public
    view
    returns (uint256)
  {
    require(_index < balanceOf(_owner));
    return ownedTokens[_owner][_index];
  }

  /**
   * @dev Gets the total amount of tokens stored by the contract
   * @return uint256 representing the total amount of tokens
   */
  function totalSupply() public view returns (uint256) {
    return allTokens.length;
  }

  /**
   * @dev Gets the token ID at a given index of all the tokens in this contract
   * Reverts if the index is greater or equal to the total number of tokens
   * @param _index uint256 representing the index to be accessed of the tokens list
   * @return uint256 token ID at the given index of the tokens list
   */
  function tokenByIndex(uint256 _index) public view returns (uint256) {
    require(_index < totalSupply());
    return allTokens[_index];
  }

  /**
   * @dev Internal function to set the token URI for a given token
   * Reverts if the token ID does not exist
   * @param _tokenId uint256 ID of the token to set its URI
   * @param _uri string URI to assign
   */
  function _setTokenURI(uint256 _tokenId, string _uri) internal {
    require(exists(_tokenId));
    tokenURIs[_tokenId] = _uri;
  }

  /**
   * @dev Internal function to add a token ID to the list of a given address
   * @param _to address representing the new owner of the given token ID
   * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
   */
  function addTokenTo(address _to, uint256 _tokenId) internal {
    super.addTokenTo(_to, _tokenId);
    uint256 length = ownedTokens[_to].length;
    ownedTokens[_to].push(_tokenId);
    ownedTokensIndex[_tokenId] = length;
  }

  /**
   * @dev Internal function to remove a token ID from the list of a given address
   * @param _from address representing the previous owner of the given token ID
   * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
   */
  function removeTokenFrom(address _from, uint256 _tokenId) internal {
    super.removeTokenFrom(_from, _tokenId);

    // To prevent a gap in the array, we store the last token in the index of the token to delete, and
    // then delete the last slot.
    uint256 tokenIndex = ownedTokensIndex[_tokenId];
    uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
    uint256 lastToken = ownedTokens[_from][lastTokenIndex];

    ownedTokens[_from][tokenIndex] = lastToken;
    // This also deletes the contents at the last position of the array
    ownedTokens[_from].length--;

    // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to
    // be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we are first swapping
    // the lastToken to the first position, and then dropping the element placed in the last position of the list

    ownedTokensIndex[_tokenId] = 0;
    ownedTokensIndex[lastToken] = tokenIndex;
  }

  /**
   * @dev Internal function to mint a new token
   * Reverts if the given token ID already exists
   * @param _to address the beneficiary that will own the minted token
   * @param _tokenId uint256 ID of the token to be minted by the msg.sender
   */
  function _mint(address _to, uint256 _tokenId) internal {
    super._mint(_to, _tokenId);

    allTokensIndex[_tokenId] = allTokens.length;
    allTokens.push(_tokenId);
  }

  /**
   * @dev Internal function to burn a specific token
   * Reverts if the token does not exist
   * @param _owner owner of the token to burn
   * @param _tokenId uint256 ID of the token being burned by the msg.sender
   */
  function _burn(address _owner, uint256 _tokenId) internal {
    super._burn(_owner, _tokenId);

    // Clear metadata (if any)
    if (bytes(tokenURIs[_tokenId]).length != 0) {
      delete tokenURIs[_tokenId];
    }

    // Reorg all tokens array
    uint256 tokenIndex = allTokensIndex[_tokenId];
    uint256 lastTokenIndex = allTokens.length.sub(1);
    uint256 lastToken = allTokens[lastTokenIndex];

    allTokens[tokenIndex] = lastToken;
    allTokens[lastTokenIndex] = 0;

    allTokens.length--;
    allTokensIndex[_tokenId] = 0;
    allTokensIndex[lastToken] = tokenIndex;
  }

}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}

// File: contracts/common/IDatabase.sol

interface IDatabase {
    
    function createEntry() external payable returns (uint256);
    function auth(uint256, address) external;
    function deleteEntry(uint256) external;
    function fundEntry(uint256) external payable;
    function claimEntryFunds(uint256, uint256) external;
    function updateEntryCreationFee(uint256) external;
    function updateDatabaseDescription(string) external;
    function addDatabaseTag(bytes32) external;
    function updateDatabaseTag(uint8, bytes32) external;
    function removeDatabaseTag(uint8) external;
    function readEntryMeta(uint256) external view returns (
        address,
        address,
        uint256,
        uint256,
        uint256,
        uint256
    );
    function getChaingearID() external view returns (uint256);
    function getEntriesIDs() external view returns (uint256[]);
    function getIndexByID(uint256) external view returns (uint256);
    function getEntryCreationFee() external view returns (uint256);
    function getEntriesStorage() external view returns (address);
    function getSchemaDefinition() external view returns (string);
    function getDatabaseBalance() external view returns (uint256);
    function getDatabaseDescription() external view returns (string);
    function getDatabaseTags() external view returns (bytes32[]);
    function getDatabaseSafe() external view returns (address);
    function getSafeBalance() external view returns (uint256);
    function getDatabaseInitStatus() external view returns (bool);
    function pause() external;
    function unpause() external;
    function transferAdminRights(address) external;
    function getAdmin() external view returns (address);
    function getPaused() external view returns (bool);
    function transferOwnership(address) external;
    function deletePayees() external;
}

// File: contracts/common/IDatabaseBuilder.sol

interface IDatabaseBuilder {
    
    function deployDatabase(
        address[],
        uint256[],
        string,
        string
    ) external returns (IDatabase);
    function setChaingearAddress(address) external;
    function getChaingearAddress() external view returns (address);
    function getOwner() external view returns (address);
}

// File: contracts/common/Safe.sol

/**
* @title Chaingear - the novel Ethereum database framework
* @author cyber•Congress, Valery litvin (@litvintech)
* @notice not audited, not recommend to use in mainnet
*/
contract Safe {
    
    address private owner;

    constructor() public
    {
        owner = msg.sender;
    }

    function()
        external
        payable
    {
        require(msg.sender == owner);
    }

    function claim(address _entryOwner, uint256 _amount)
        external
    {
        require(msg.sender == owner);
        require(_amount <= address(this).balance);
        require(_entryOwner != address(0));
        
        _entryOwner.transfer(_amount);
    }

    function getOwner()
        external
        view
        returns(address)
    {
        return owner;
    }
}

// File: contracts/common/IChaingear.sol

interface IChaingear {
    
    function addDatabaseBuilderVersion(
        string,
        IDatabaseBuilder,
        string,
        string
    ) external;
    function updateDatabaseBuilderDescription(string, string) external;
    function depricateDatabaseBuilder(string) external;
    function createDatabase(
        string,
        address[],
        uint256[],
        string,
        string
    ) external payable returns (address, uint256);
    function deleteDatabase(uint256) external;
    function fundDatabase(uint256) external payable;
    function claimDatabaseFunds(uint256, uint256) external;
    function updateCreationFee(uint256) external;
    function getAmountOfBuilders() external view returns (uint256);
    function getBuilderByID(uint256) external view returns(string);
    function getDatabaseBuilder(string) external view returns(address, string, string, bool);
    function getDatabasesIDs() external view returns (uint256[]);
    function getDatabaseIDByAddress(address) external view returns (uint256);
    function getDatabaseAddressByName(string) external view returns (address);
    function getDatabaseSymbolByID(uint256) external view returns (string);
    function getDatabaseIDBySymbol(string) external view returns (uint256);
    function getDatabase(uint256) external view returns (
        string,
        string,
        address,
        string,
        uint256,
        address,
        uint256
    );
    function getDatabaseBalance(uint256) external view returns (uint256, uint256);
    function getChaingearDescription() external pure returns (string);
    function getCreationFeeWei() external view returns (uint256);
    function getSafeBalance() external view returns (uint256);
    function getSafeAddress() external view returns (address);
    function getNameExist(string) external view returns (bool);
    function getSymbolExist(string) external view returns (bool);
}

// File: contracts/common/PaymentSplitter.sol

/**
 * @title PaymentSplitter
 * @dev This contract can be used when payments need to be received by a group
 * of people and split proportionately to some number of shares they own.
 */
contract PaymentSplitter {
    
    using SafeMath for uint256;

    uint256 internal totalShares;
    uint256 internal totalReleased;

    mapping(address => uint256) internal shares;
    mapping(address => uint256) internal released;
    address[] internal payees;
    
    event PayeeAdded(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);

    constructor (address[] _payees, uint256[] _shares)
        public
        payable
    {
        _initializePayess(_payees, _shares);
    }

    function ()
        external
        payable
    {
        emit PaymentReceived(msg.sender, msg.value);
    }

    function getTotalShares()
        external
        view
        returns (uint256)
    {
        return totalShares;
    }

    function getTotalReleased()
        external
        view
        returns (uint256)
    {
        return totalReleased;
    }

    function getShares(address _account)
        external
        view
        returns (uint256)
    {
        return shares[_account];
    }

    function getReleased(address _account)
        external
        view
        returns (uint256)
    {
        return released[_account];
    }

    function getPayee(uint256 _index)
        external
        view
        returns (address)
    {
        return payees[_index];
    }
    
    function getPayeesCount() 
        external
        view
        returns (uint256)
    {   
        return payees.length;
    }

    function release(address _account) 
        public
    {
        require(shares[_account] > 0);

        uint256 totalReceived = address(this).balance.add(totalReleased);
        uint256 payment = totalReceived.mul(shares[_account]).div(totalShares).sub(released[_account]);

        require(payment != 0);

        released[_account] = released[_account].add(payment);
        totalReleased = totalReleased.add(payment);

        _account.transfer(payment);
        
        emit PaymentReleased(_account, payment);
    }
    
    function _initializePayess(address[] _payees, uint256[] _shares)
        internal
    {
        require(payees.length == 0);
        require(_payees.length == _shares.length);
        require(_payees.length > 0 && _payees.length <= 8);

        for (uint256 i = 0; i < _payees.length; i++) {
            _addPayee(_payees[i], _shares[i]);
        }
    }

    function _addPayee(
        address _account,
        uint256 _shares
    ) 
        internal
    {
        require(_account != address(0));
        require(_shares > 0);
        require(shares[_account] == 0);

        payees.push(_account);
        shares[_account] = _shares;
        totalShares = totalShares.add(_shares);
        
        emit PayeeAdded(_account, _shares);
    }
}

// File: contracts/chaingear/FeeSplitterChaingear.sol

contract FeeSplitterChaingear is PaymentSplitter, Ownable {
    
    event PayeeAddressChanged(
        uint8 payeeIndex, 
        address oldAddress, 
        address newAddress
    );

    constructor(address[] _payees, uint256[] _shares)
        public
        payable
        PaymentSplitter(_payees, _shares)
    { }
    
    function changePayeeAddress(uint8 _payeeIndex, address _newAddress)
        external
        onlyOwner
    {
        require(_payeeIndex < 12);
        require(payees[_payeeIndex] != _newAddress);
        
        address oldAddress = payees[_payeeIndex];
        shares[_newAddress] = shares[oldAddress];
        released[_newAddress] = released[oldAddress];
        payees[_payeeIndex] = _newAddress;

        delete shares[oldAddress];
        delete released[oldAddress];

        emit PayeeAddressChanged(_payeeIndex, oldAddress, _newAddress);
    }

}

// File: contracts/common/ERC721MetadataValidation.sol

library ERC721MetadataValidation {

    function validateName(string _base) 
        internal
        pure
    {
        bytes memory _baseBytes = bytes(_base);
        for (uint i = 0; i < _baseBytes.length; i++) {
            require(_baseBytes[i] >= 0x61 && _baseBytes[i] <= 0x7A || _baseBytes[i] >= 0x30 && _baseBytes[i] <= 0x39 || _baseBytes[i] == 0x2D);
        }
    }

    function validateSymbol(string _base) 
        internal
        pure
    {
        bytes memory _baseBytes = bytes(_base);
        for (uint i = 0; i < _baseBytes.length; i++) {
            require(_baseBytes[i] >= 0x41 && _baseBytes[i] <= 0x5A || _baseBytes[i] >= 0x30 && _baseBytes[i] <= 0x39);
        }
    }
}

// File: contracts/chaingear/Chaingear.sol

/**
* @title Chaingear - the novel Ethereum database framework
* @author cyber•Congress, Valery litvin (@litvintech)
* @notice not audited, not recommend to use in mainnet
*/
contract Chaingear is IChaingear, Ownable, SupportsInterfaceWithLookup, Pausable, FeeSplitterChaingear, ERC721Token {

    using SafeMath for uint256;
    using ERC721MetadataValidation for string;

    /*
    *  Storage
    */

    struct DatabaseMeta {
        IDatabase databaseContract;
        address creatorOfDatabase;
        string versionOfDatabase;
        string linkABI;
        uint256 createdTimestamp;
        uint256 currentWei;
        uint256 accumulatedWei;
    }

    struct DatabaseBuilder {
        IDatabaseBuilder builderAddress;
        string linkToABI;
        string description;
        bool operational;
    }

    DatabaseMeta[] private databases;
    mapping(string => bool) private databasesNamesIndex;
    mapping(string => bool) private databasesSymbolsIndex;

    uint256 private headTokenID = 0;
    mapping(address => uint256) private databasesIDsByAddressesIndex;
    mapping(string => address) private databasesAddressesByNameIndex;
    mapping(uint256 => string) private databasesSymbolsByIDIndex;
    mapping(string => uint256) private databasesIDsBySymbolIndex;

    uint256 private amountOfBuilders = 0;
    mapping(uint256 => string) private buildersVersionIndex;
    mapping(string => DatabaseBuilder) private buildersVersion;

    Safe private chaingearSafe;
    uint256 private databaseCreationFeeWei = 1 finney;

    string private constant CHAINGEAR_DESCRIPTION = "The novel Ethereum database framework";
    bytes4 private constant INTERFACE_CHAINGEAR_EULER_ID = 0xea1db66f; 
    bytes4 private constant INTERFACE_DATABASE_V1_EULER_ID = 0xf2c320c4;
    bytes4 private constant INTERFACE_DATABASE_BUILDER_EULER_ID = 0xce8bbf93;
    
    /*
    *  Events
    */
    event DatabaseBuilderAdded(
        string version,
        IDatabaseBuilder builderAddress,
        string linkToABI,
        string description
    );
    event DatabaseDescriptionUpdated(string version, string description);
    event DatabaseBuilderDepricated(string version);
    event DatabaseCreated(
        string name,
        address databaseAddress,
        address creatorAddress,
        uint256 databaseChaingearID
    );
    event DatabaseDeleted(
        string name,
        address databaseAddress,
        address creatorAddress,
        uint256 databaseChaingearID
    );
    event DatabaseFunded(
        uint256 databaseID,
        address sender,
        uint256 amount
    );
    event DatabaseFundsClaimed(
        uint256 databaseID,
        address claimer,
        uint256 amount
    );    
    event CreationFeeUpdated(uint256 newFee);

    /*
    *  Constructor
    */

    constructor(address[] _beneficiaries, uint256[] _shares)
        public
        ERC721Token ("CHAINGEAR", "CHG")
        FeeSplitterChaingear (_beneficiaries, _shares)
    {
        chaingearSafe = new Safe();
        _registerInterface(INTERFACE_CHAINGEAR_EULER_ID);
    }

    /*
    *  Modifiers
    */

    modifier onlyOwnerOf(uint256 _databaseID){
        require(ownerOf(_databaseID) == msg.sender);
        _;
    }

    /*
    *  External functions
    */

    function addDatabaseBuilderVersion(
        string _version,
        IDatabaseBuilder _builderAddress,
        string _linkToABI,
        string _description
    )
        external
        onlyOwner
        whenNotPaused
    {
        require(buildersVersion[_version].builderAddress == address(0));

        SupportsInterfaceWithLookup support = SupportsInterfaceWithLookup(_builderAddress);
        require(support.supportsInterface(INTERFACE_DATABASE_BUILDER_EULER_ID));

        buildersVersion[_version] = (DatabaseBuilder(
        {
            builderAddress: _builderAddress,
            linkToABI: _linkToABI,
            description: _description,
            operational: true
        }));
        buildersVersionIndex[amountOfBuilders] = _version;
        amountOfBuilders = amountOfBuilders.add(1);
        
        emit DatabaseBuilderAdded(
            _version,
            _builderAddress,
            _linkToABI,
            _description
        );
    }

    function updateDatabaseBuilderDescription(string _version, string _description)
        external
        onlyOwner
        whenNotPaused
    {
        require(buildersVersion[_version].builderAddress != address(0));
        buildersVersion[_version].description = _description;    
        emit DatabaseDescriptionUpdated(_version, _description);
    }
    
    function depricateDatabaseBuilder(string _version)
        external
        onlyOwner
        whenPaused
    {
        require(buildersVersion[_version].builderAddress != address(0));
        require(buildersVersion[_version].operational == true);
        buildersVersion[_version].operational = false;
        emit DatabaseBuilderDepricated(_version);
    }

    function createDatabase(
        string    _version,
        address[] _beneficiaries,
        uint256[] _shares,
        string    _name,
        string    _symbol
    )
        external
        payable
        whenNotPaused
        returns (address, uint256)
    {
        _name.validateName();
        _symbol.validateSymbol();
        require(buildersVersion[_version].builderAddress != address(0));
        require(buildersVersion[_version].operational == true);
        require(databaseCreationFeeWei == msg.value);
        require(databasesNamesIndex[_name] == false);
        require(databasesSymbolsIndex[_symbol] == false);

        return _deployDatabase(
            _version,
            _beneficiaries,
            _shares,
            _name,
            _symbol
        );
    }

    function deleteDatabase(uint256 _databaseID)
        external
        onlyOwnerOf(_databaseID)
        whenNotPaused
    {
        uint256 databaseIndex = allTokensIndex[_databaseID];
        IDatabase database = databases[databaseIndex].databaseContract;
        require(database.getSafeBalance() == uint256(0));
        require(database.getPaused() == true);
        
        string memory databaseName = ERC721(database).name();
        string memory databaseSymbol = ERC721(database).symbol();
        
        delete databasesNamesIndex[databaseName];
        delete databasesSymbolsIndex[databaseSymbol];
        delete databasesIDsByAddressesIndex[database];  
        delete databasesIDsBySymbolIndex[databaseSymbol];
        delete databasesSymbolsByIDIndex[_databaseID];

        uint256 lastDatabaseIndex = databases.length.sub(1);
        DatabaseMeta memory lastDatabase = databases[lastDatabaseIndex];
        databases[databaseIndex] = lastDatabase;
        delete databases[lastDatabaseIndex];
        databases.length--;

        super._burn(msg.sender, _databaseID);
        database.transferOwnership(msg.sender);
        
        emit DatabaseDeleted(
            databaseName,
            database,
            msg.sender,
            _databaseID
        );
    }

    function fundDatabase(uint256 _databaseID)
        external
        whenNotPaused
        payable
    {
        require(exists(_databaseID) == true);
        uint256 databaseIndex = allTokensIndex[_databaseID];

        uint256 currentWei = databases[databaseIndex].currentWei.add(msg.value);
        databases[databaseIndex].currentWei = currentWei;

        uint256 accumulatedWei = databases[databaseIndex].accumulatedWei.add(msg.value);
        databases[databaseIndex].accumulatedWei = accumulatedWei;

        emit DatabaseFunded(_databaseID, msg.sender, msg.value);
        address(chaingearSafe).transfer(msg.value);
    }

    function claimDatabaseFunds(uint256 _databaseID, uint256 _amount)
        external
        onlyOwnerOf(_databaseID)
        whenNotPaused
    {
        uint256 databaseIndex = allTokensIndex[_databaseID];

        uint256 currentWei = databases[databaseIndex].currentWei;
        require(_amount <= currentWei);

        databases[databaseIndex].currentWei = currentWei.sub(_amount);

        emit DatabaseFundsClaimed(_databaseID, msg.sender, _amount);
        chaingearSafe.claim(msg.sender, _amount);
    }

    function updateCreationFee(uint256 _newFee)
        external
        onlyOwner
        whenPaused
    {
        databaseCreationFeeWei = _newFee;
        emit CreationFeeUpdated(_newFee);
    }

    /*
    *  Views
    */

    function getAmountOfBuilders()
        external
        view
        returns(uint256)
    {
        return amountOfBuilders;
    }

    function getBuilderByID(uint256 _id)
        external
        view
        returns(string)
    {
        return buildersVersionIndex[_id];
    }

    function getDatabaseBuilder(string _version)
        external
        view
        returns (
            address,
            string,
            string,
            bool
        )
    {
        return(
            buildersVersion[_version].builderAddress,
            buildersVersion[_version].linkToABI,
            buildersVersion[_version].description,
            buildersVersion[_version].operational
        );
    }

    function getDatabasesIDs()
        external
        view
        returns(uint256[])
    {
        return allTokens;
    }

    function getDatabaseIDByAddress(address _databaseAddress)
        external
        view
        returns(uint256)
    {
        uint256 databaseID = databasesIDsByAddressesIndex[_databaseAddress];
        return databaseID;
    }
    
    function getDatabaseAddressByName(string _name)
        external
        view
        returns(address)
    {
        return databasesAddressesByNameIndex[_name];
    }

    function getDatabaseSymbolByID(uint256 _databaseID)
        external
        view
        returns(string)
    {
        return databasesSymbolsByIDIndex[_databaseID];
    }

    function getDatabaseIDBySymbol(string _symbol)
        external
        view
        returns(uint256)
    {
        return databasesIDsBySymbolIndex[_symbol];
    }

    function getDatabase(uint256 _databaseID)
        external
        view
        returns (
            string,
            string,
            address,
            string,
            uint256,
            address,
            uint256
        )
    {
        uint256 databaseIndex = allTokensIndex[_databaseID];
        IDatabase databaseAddress = databases[databaseIndex].databaseContract;

        return (
            ERC721(databaseAddress).name(),
            ERC721(databaseAddress).symbol(),
            databaseAddress,
            databases[databaseIndex].versionOfDatabase,
            databases[databaseIndex].createdTimestamp,
            databaseAddress.getAdmin(),
            ERC721(databaseAddress).totalSupply()
        );
    }

    function getDatabaseBalance(uint256 _databaseID)
        external
        view
        returns (uint256, uint256)
    {
        uint256 databaseIndex = allTokensIndex[_databaseID];

        return (
            databases[databaseIndex].currentWei,
            databases[databaseIndex].accumulatedWei
        );
    }

    function getChaingearDescription()
        external
        pure
        returns (string)
    {
        return CHAINGEAR_DESCRIPTION;
    }

    function getCreationFeeWei()
        external
        view
        returns (uint256)
    {
        return databaseCreationFeeWei;
    }

    function getSafeBalance()
        external
        view
        returns (uint256)
    {
        return address(chaingearSafe).balance;
    }

    function getSafeAddress()
        external
        view
        returns (address)
    {
        return chaingearSafe;
    }

    function getNameExist(string _name)
        external
        view
        returns (bool)
    {
        return databasesNamesIndex[_name];
    }

    function getSymbolExist(string _symbol)
        external
        view
        returns (bool)
    {
        return databasesSymbolsIndex[_symbol];
    }

    /*
    *  Public functions
    */

    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        public
        whenNotPaused
    {
        uint256 databaseIndex = allTokensIndex[_tokenId];
        IDatabase database = databases[databaseIndex].databaseContract;
        require(address(database).balance == 0);
        require(database.getPaused() == true);
        super.transferFrom(_from, _to, _tokenId);
        
        IDatabase databaseAddress = databases[databaseIndex].databaseContract;
        databaseAddress.deletePayees();
        databaseAddress.transferAdminRights(_to);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        public
        whenNotPaused
    {
        safeTransferFrom(
            _from,
            _to,
            _tokenId,
            ""
        );
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    )
        public
        whenNotPaused
    {
        transferFrom(_from, _to, _tokenId);

        require(
            checkAndCallSafeTransfer(
                _from,
                _to,
                _tokenId,
                _data
        ));
    }

    /*
    *  Private functions
    */

    function _deployDatabase(
        string    _version,
        address[] _beneficiaries,
        uint256[] _shares,
        string    _name,
        string    _symbol
    )
        private
        returns (address, uint256)
    {
        IDatabaseBuilder builder = buildersVersion[_version].builderAddress;
        IDatabase databaseContract = builder.deployDatabase(
            _beneficiaries,
            _shares,
            _name,
            _symbol
        );

        address databaseAddress = address(databaseContract);

        SupportsInterfaceWithLookup support = SupportsInterfaceWithLookup(databaseAddress);
        require(support.supportsInterface(INTERFACE_DATABASE_V1_EULER_ID));
        require(support.supportsInterface(InterfaceId_ERC721));
        require(support.supportsInterface(InterfaceId_ERC721Metadata));
        require(support.supportsInterface(InterfaceId_ERC721Enumerable));

        DatabaseMeta memory database = (DatabaseMeta(
        {
            databaseContract: databaseContract,
            creatorOfDatabase: msg.sender,
            versionOfDatabase: _version,
            linkABI: buildersVersion[_version].linkToABI,
            createdTimestamp: block.timestamp,
            currentWei: 0,
            accumulatedWei: 0
        }));

        databases.push(database);

        databasesNamesIndex[_name] = true;
        databasesSymbolsIndex[_symbol] = true;

        uint256 newTokenID = headTokenID;
        databasesIDsByAddressesIndex[databaseAddress] = newTokenID;
        super._mint(msg.sender, newTokenID);
        databasesSymbolsByIDIndex[newTokenID] = _symbol;
        databasesIDsBySymbolIndex[_symbol] = newTokenID;
        databasesAddressesByNameIndex[_name] = databaseAddress;
        headTokenID = headTokenID.add(1);

        emit DatabaseCreated(
            _name,
            databaseAddress,
            msg.sender,
            newTokenID
        );

        databaseContract.transferAdminRights(msg.sender);
        return (databaseAddress, newTokenID);
    }

}