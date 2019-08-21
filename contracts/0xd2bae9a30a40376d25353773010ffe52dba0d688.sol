pragma solidity ^0.4.24;

// File: node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
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
  function isOwner() public view returns(bool) {
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

// File: node_modules/openzeppelin-solidity/contracts/introspection/IERC165.sol

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
  function supportsInterface(bytes4 interfaceId)
    external
    view
    returns (bool);
}

// File: node_modules/openzeppelin-solidity/contracts/token/ERC721/IERC721.sol

/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract IERC721 is IERC165 {

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 indexed tokenId
  );
  event Approval(
    address indexed owner,
    address indexed approved,
    uint256 indexed tokenId
  );
  event ApprovalForAll(
    address indexed owner,
    address indexed operator,
    bool approved
  );

  function balanceOf(address owner) public view returns (uint256 balance);
  function ownerOf(uint256 tokenId) public view returns (address owner);

  function approve(address to, uint256 tokenId) public;
  function getApproved(uint256 tokenId)
    public view returns (address operator);

  function setApprovalForAll(address operator, bool _approved) public;
  function isApprovedForAll(address owner, address operator)
    public view returns (bool);

  function transferFrom(address from, address to, uint256 tokenId) public;
  function safeTransferFrom(address from, address to, uint256 tokenId)
    public;

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes data
  )
    public;
}

// File: node_modules/openzeppelin-solidity/contracts/token/ERC721/IERC721Receiver.sol

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
  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes data
  )
    public
    returns(bytes4);
}

// File: node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
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
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

// File: node_modules/openzeppelin-solidity/contracts/utils/Address.sol

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
    // solium-disable-next-line security/no-inline-assembly
    assembly { size := extcodesize(account) }
    return size > 0;
  }

}

// File: node_modules/openzeppelin-solidity/contracts/introspection/ERC165.sol

/**
 * @title ERC165
 * @author Matt Condon (@shrugs)
 * @dev Implements ERC165 using a lookup table.
 */
contract ERC165 is IERC165 {

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
    require(interfaceId != 0xffffffff);
    _supportedInterfaces[interfaceId] = true;
  }
}

// File: node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721.sol

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

  bytes4 private constant _InterfaceId_ERC721 = 0x80ac58cd;
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

  constructor()
    public
  {
    // register the supported interfaces to conform to ERC721 via ERC165
    _registerInterface(_InterfaceId_ERC721);
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
  function isApprovedForAll(
    address owner,
    address operator
  )
    public
    view
    returns (bool)
  {
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
  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  )
    public
  {
    require(_isApprovedOrOwner(msg.sender, tokenId));
    require(to != address(0));

    _clearApproval(from, tokenId);
    _removeTokenFrom(from, tokenId);
    _addTokenTo(to, tokenId);

    emit Transfer(from, to, tokenId);
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
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  )
    public
  {
    // solium-disable-next-line arg-overflow
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
  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes _data
  )
    public
  {
    transferFrom(from, to, tokenId);
    // solium-disable-next-line arg-overflow
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
   *  is an operator of the owner, or is the owner of the token
   */
  function _isApprovedOrOwner(
    address spender,
    uint256 tokenId
  )
    internal
    view
    returns (bool)
  {
    address owner = ownerOf(tokenId);
    // Disable solium check because of
    // https://github.com/duaraghav8/Solium/issues/175
    // solium-disable-next-line operator-whitespace
    return (
      spender == owner ||
      getApproved(tokenId) == spender ||
      isApprovedForAll(owner, spender)
    );
  }

  /**
   * @dev Internal function to mint a new token
   * Reverts if the given token ID already exists
   * @param to The address that will own the minted token
   * @param tokenId uint256 ID of the token to be minted by the msg.sender
   */
  function _mint(address to, uint256 tokenId) internal {
    require(to != address(0));
    _addTokenTo(to, tokenId);
    emit Transfer(address(0), to, tokenId);
  }

  /**
   * @dev Internal function to burn a specific token
   * Reverts if the token does not exist
   * @param tokenId uint256 ID of the token being burned by the msg.sender
   */
  function _burn(address owner, uint256 tokenId) internal {
    _clearApproval(owner, tokenId);
    _removeTokenFrom(owner, tokenId);
    emit Transfer(owner, address(0), tokenId);
  }

  /**
   * @dev Internal function to add a token ID to the list of a given address
   * Note that this function is left internal to make ERC721Enumerable possible, but is not
   * intended to be called by custom derived contracts: in particular, it emits no Transfer event.
   * @param to address representing the new owner of the given token ID
   * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
   */
  function _addTokenTo(address to, uint256 tokenId) internal {
    require(_tokenOwner[tokenId] == address(0));
    _tokenOwner[tokenId] = to;
    _ownedTokensCount[to] = _ownedTokensCount[to].add(1);
  }

  /**
   * @dev Internal function to remove a token ID from the list of a given address
   * Note that this function is left internal to make ERC721Enumerable possible, but is not
   * intended to be called by custom derived contracts: in particular, it emits no Transfer event,
   * and doesn't clear approvals.
   * @param from address representing the previous owner of the given token ID
   * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
   */
  function _removeTokenFrom(address from, uint256 tokenId) internal {
    require(ownerOf(tokenId) == from);
    _ownedTokensCount[from] = _ownedTokensCount[from].sub(1);
    _tokenOwner[tokenId] = address(0);
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
  function _checkOnERC721Received(
    address from,
    address to,
    uint256 tokenId,
    bytes _data
  )
    internal
    returns (bool)
  {
    if (!to.isContract()) {
      return true;
    }
    bytes4 retval = IERC721Receiver(to).onERC721Received(
      msg.sender, from, tokenId, _data);
    return (retval == _ERC721_RECEIVED);
  }

  /**
   * @dev Private function to clear current approval of a given token ID
   * Reverts if the given address is not indeed the owner of the token
   * @param owner owner of the token
   * @param tokenId uint256 ID of the token to be transferred
   */
  function _clearApproval(address owner, uint256 tokenId) private {
    require(ownerOf(tokenId) == owner);
    if (_tokenApprovals[tokenId] != address(0)) {
      _tokenApprovals[tokenId] = address(0);
    }
  }
}

// File: node_modules/openzeppelin-solidity/contracts/token/ERC721/IERC721Enumerable.sol

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract IERC721Enumerable is IERC721 {
  function totalSupply() public view returns (uint256);
  function tokenOfOwnerByIndex(
    address owner,
    uint256 index
  )
    public
    view
    returns (uint256 tokenId);

  function tokenByIndex(uint256 index) public view returns (uint256);
}

// File: node_modules/openzeppelin-solidity/contracts/token/ERC721/ERC721Enumerable.sol

contract ERC721Enumerable is ERC165, ERC721, IERC721Enumerable {
  // Mapping from owner to list of owned token IDs
  mapping(address => uint256[]) private _ownedTokens;

  // Mapping from token ID to index of the owner tokens list
  mapping(uint256 => uint256) private _ownedTokensIndex;

  // Array with all token ids, used for enumeration
  uint256[] private _allTokens;

  // Mapping from token id to position in the allTokens array
  mapping(uint256 => uint256) private _allTokensIndex;

  bytes4 private constant _InterfaceId_ERC721Enumerable = 0x780e9d63;
  /**
   * 0x780e9d63 ===
   *   bytes4(keccak256('totalSupply()')) ^
   *   bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^
   *   bytes4(keccak256('tokenByIndex(uint256)'))
   */

  /**
   * @dev Constructor function
   */
  constructor() public {
    // register the supported interface to conform to ERC721 via ERC165
    _registerInterface(_InterfaceId_ERC721Enumerable);
  }

  /**
   * @dev Gets the token ID at a given index of the tokens list of the requested owner
   * @param owner address owning the tokens list to be accessed
   * @param index uint256 representing the index to be accessed of the requested tokens list
   * @return uint256 token ID at the given index of the tokens list owned by the requested address
   */
  function tokenOfOwnerByIndex(
    address owner,
    uint256 index
  )
    public
    view
    returns (uint256)
  {
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
   * @dev Internal function to add a token ID to the list of a given address
   * This function is internal due to language limitations, see the note in ERC721.sol.
   * It is not intended to be called by custom derived contracts: in particular, it emits no Transfer event.
   * @param to address representing the new owner of the given token ID
   * @param tokenId uint256 ID of the token to be added to the tokens list of the given address
   */
  function _addTokenTo(address to, uint256 tokenId) internal {
    super._addTokenTo(to, tokenId);
    uint256 length = _ownedTokens[to].length;
    _ownedTokens[to].push(tokenId);
    _ownedTokensIndex[tokenId] = length;
  }

  /**
   * @dev Internal function to remove a token ID from the list of a given address
   * This function is internal due to language limitations, see the note in ERC721.sol.
   * It is not intended to be called by custom derived contracts: in particular, it emits no Transfer event,
   * and doesn't clear approvals.
   * @param from address representing the previous owner of the given token ID
   * @param tokenId uint256 ID of the token to be removed from the tokens list of the given address
   */
  function _removeTokenFrom(address from, uint256 tokenId) internal {
    super._removeTokenFrom(from, tokenId);

    // To prevent a gap in the array, we store the last token in the index of the token to delete, and
    // then delete the last slot.
    uint256 tokenIndex = _ownedTokensIndex[tokenId];
    uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
    uint256 lastToken = _ownedTokens[from][lastTokenIndex];

    _ownedTokens[from][tokenIndex] = lastToken;
    // This also deletes the contents at the last position of the array
    _ownedTokens[from].length--;

    // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to
    // be zero. Then we can make sure that we will remove tokenId from the ownedTokens list since we are first swapping
    // the lastToken to the first position, and then dropping the element placed in the last position of the list

    _ownedTokensIndex[tokenId] = 0;
    _ownedTokensIndex[lastToken] = tokenIndex;
  }

  /**
   * @dev Internal function to mint a new token
   * Reverts if the given token ID already exists
   * @param to address the beneficiary that will own the minted token
   * @param tokenId uint256 ID of the token to be minted by the msg.sender
   */
  function _mint(address to, uint256 tokenId) internal {
    super._mint(to, tokenId);

    _allTokensIndex[tokenId] = _allTokens.length;
    _allTokens.push(tokenId);
  }

  /**
   * @dev Internal function to burn a specific token
   * Reverts if the token does not exist
   * @param owner owner of the token to burn
   * @param tokenId uint256 ID of the token being burned by the msg.sender
   */
  function _burn(address owner, uint256 tokenId) internal {
    super._burn(owner, tokenId);

    // Reorg all tokens array
    uint256 tokenIndex = _allTokensIndex[tokenId];
    uint256 lastTokenIndex = _allTokens.length.sub(1);
    uint256 lastToken = _allTokens[lastTokenIndex];

    _allTokens[tokenIndex] = lastToken;
    _allTokens[lastTokenIndex] = 0;

    _allTokens.length--;
    _allTokensIndex[tokenId] = 0;
    _allTokensIndex[lastToken] = tokenIndex;
  }
}

// File: node_modules/openzeppelin-solidity/contracts/token/ERC721/IERC721Metadata.sol

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract IERC721Metadata is IERC721 {
  function name() external view returns (string);
  function symbol() external view returns (string);
  function tokenURI(uint256 tokenId) external view returns (string);
}

// File: contracts/ERC721Metadata.sol

//import "../node_modules/openzeppelin-solidity/contracts/math/Safemath.sol";

contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {
  using SafeMath for uint256;

  event LockUpdate(uint256 indexed tokenId, uint256 fromLockedTo, uint256 fromLockId, uint256 toLockedTo, uint256 toLockId, uint256 callId);
  event StatsUpdate(uint256 indexed tokenId, uint256 fromLevel, uint256 fromWins, uint256 fromLosses, uint256 toLevel, uint256 toWins, uint256 toLosses);

  // Token name
  string private _name;

  // Token symbol
  string private _symbol;

  // Optional mapping for token URIs
  string private _baseURI;

  string private _description;

  string private _url;

  struct Character {
    uint256 mintedAt;
    uint256 genes;
    uint256 lockedTo;
    uint256 lockId;
    uint256 level;
    uint256 wins;
    uint256 losses;
  }

  mapping(uint256 => Character) characters; // tokenId => Character


  bytes4 private constant InterfaceId_ERC721Metadata = 0x5b5e139f;
  /**
   * 0x5b5e139f ===
   *   bytes4(keccak256('name()')) ^
   *   bytes4(keccak256('symbol()')) ^
   *   bytes4(keccak256('tokenURI(uint256)'))
   */

  /**
   * @dev Constructor function
   */
  constructor(string name, string symbol, string baseURI, string description, string url) public {
    _name = name;
    _symbol = symbol;
    _baseURI = baseURI;
    _description = description;
    _url = url;
    // register the supported interfaces to conform to ERC721 via ERC165
    _registerInterface(InterfaceId_ERC721Metadata);
  }

  /**
   * @dev Gets the token name
   * @return string representing the token name
   */
  function name() external view returns (string) {
    return _name;
  }

  /**
   * @dev Gets the token symbol
   * @return string representing the token symbol
   */
  function symbol() external view returns (string) {
    return _symbol;
  }

  /**
   * @dev Gets the contract description
   * @return string representing the contract description
   */
  function description() external view returns (string) {
    return _description;
  }

  /**
 * @dev Gets the project url
 * @return string representing the project url
 */
  function url() external view returns (string) {
    return _url;
  }

  /**
  * @dev Function to set the token base URI
  * @param newBaseUri string URI to assign
  */
  function _setBaseURI(string newBaseUri) internal {
    _baseURI = newBaseUri;
  }

  /**
  * @dev Function to set the contract description
  * @param newDescription string contract description to assign
  */
  function _setDescription(string newDescription) internal {
    _description = newDescription;
  }

  /**
   * @dev Function to set the project url
   * @param newUrl string project url to assign
   */
  function _setURL(string newUrl) internal {
    _url = newUrl;
  }


  /**
   * @dev Returns an URI for a given token ID
   * Throws if the token ID does not exist. May return an empty string.
   * @param tokenId uint256 ID of the token to query
   */
  function tokenURI(uint256 tokenId) external view returns (string) {
    require(_exists(tokenId));
    return string(abi.encodePacked(_baseURI, uint2str(tokenId)));
  }

  function _setMetadata(uint256 tokenId, uint256 genes, uint256 level) internal {
    require(_exists(tokenId));
    //    Character storage character = characters[_tokenId];
    characters[tokenId] = Character({
      mintedAt : now,
      genes : genes,
      lockedTo : 0,
      lockId : 0,
      level : level,
      wins : 0,
      losses : 0
      });
    emit StatsUpdate(tokenId, 0, 0, 0, level, 0, 0);

  }


  function _clearMetadata(uint256 tokenId) internal {
    require(_exists(tokenId));
    delete characters[tokenId];
  }

  /* LOCKS */

  function isFree(uint tokenId) public view returns (bool) {
    require(_exists(tokenId));
    return now > characters[tokenId].lockedTo;
  }


  function getLock(uint256 tokenId) external view returns (uint256 lockedTo, uint256 lockId) {
    require(_exists(tokenId));
    Character memory c = characters[tokenId];
    return (c.lockedTo, c.lockId);
  }

  function getLevel(uint256 tokenId) external view returns (uint256) {
    require(_exists(tokenId));
    return characters[tokenId].level;
  }

  function getGenes(uint256 tokenId) external view returns (uint256) {
    require(_exists(tokenId));
    return characters[tokenId].genes;
  }

  function getRace(uint256 tokenId) external view returns (uint256) {
    require(_exists(tokenId));
    return characters[tokenId].genes & 0xFFFF;
  }

  function getCharacter(uint256 tokenId) external view returns (
    uint256 mintedAt,
    uint256 genes,
    uint256 race,
    uint256 lockedTo,
    uint256 lockId,
    uint256 level,
    uint256 wins,
    uint256 losses
  ) {
    require(_exists(tokenId));
    Character memory c = characters[tokenId];
    return (c.mintedAt, c.genes, c.genes & 0xFFFF, c.lockedTo, c.lockId, c.level, c.wins, c.losses);
  }

  function _setLock(uint256 tokenId, uint256 lockedTo, uint256 lockId, uint256 callId) internal returns (bool) {
    require(isFree(tokenId));
    Character storage c = characters[tokenId];
    emit LockUpdate(tokenId, c.lockedTo, c.lockId, lockedTo, lockId, callId);
    c.lockedTo = lockedTo;
    c.lockId = lockId;
    return true;
  }

  /* CHARACTER LOGIC */

  function _addWin(uint256 tokenId, uint256 _winsCount, uint256 _levelUp) internal returns (bool) {
    require(_exists(tokenId));
    Character storage c = characters[tokenId];
    uint prevWins = c.wins;
    uint prevLevel = c.level;
    c.wins = c.wins.add(_winsCount);
    c.level = c.level.add(_levelUp);
    emit StatsUpdate(tokenId, prevLevel, prevWins, c.losses, c.level, c.wins, c.losses);
    return true;
  }

  function _addLoss(uint256 tokenId, uint256 _lossesCount, uint256 _levelDown) internal returns (bool) {
    require(_exists(tokenId));
    Character storage c = characters[tokenId];
    uint prevLosses = c.losses;
    uint prevLevel = c.level;
    c.losses = c.losses.add(_lossesCount);
    c.level = c.level > _levelDown ? c.level.sub(_levelDown) : 1;
    emit StatsUpdate(tokenId, prevLevel, c.wins, prevLosses, c.level, c.wins, c.losses);
    return true;
  }

  /**
  * @dev Convert uint to string
  * @param i The uint to convert
  * @return A string representation of uint.
  */
  function uint2str(uint i) internal pure returns (string) {
    if (i == 0) return "0";
    uint j = i;
    uint len;
    while (j != 0) {
      len++;
      j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint k = len - 1;
    while (i != 0) {
      bstr[k--] = byte(48 + i % 10);
      i /= 10;
    }
    return string(bstr);
  }


}

// File: lib/HasAgents.sol

/**
 * @title agents
 * @dev Library for managing addresses assigned to a agent.
 */
library Agents {
  using Address for address;

  struct Data {
    uint id;
    bool exists;
    bool allowance;
  }

  struct Agent {
    mapping(address => Data) data;
    mapping(uint => address) list;
  }

  /**
   * @dev give an account access to this agent
   */
  function add(Agent storage agent, address account, uint id, bool allowance) internal {
    require(!exists(agent, account));

    agent.data[account] = Data({
      id : id,
      exists : true,
      allowance : allowance
      });
    agent.list[id] = account;
  }

  /**
   * @dev remove an account's access to this agent
   */
  function remove(Agent storage agent, address account) internal {
    require(exists(agent, account));

    //if it not updated agent - clean list record
    if (agent.list[agent.data[account].id] == account) {
      delete agent.list[agent.data[account].id];
    }
    delete agent.data[account];
  }

  /**
   * @dev check if an account has this agent
   * @return bool
   */
  function exists(Agent storage agent, address account) internal view returns (bool) {
    require(account != address(0));
    //auto prevent existing of agents with updated address and same id
    return agent.data[account].exists && agent.list[agent.data[account].id] == account;
  }

  /**
  * @dev get agent id of the account
  * @return uint
  */
  function id(Agent storage agent, address account) internal view returns (uint) {
    require(exists(agent, account));
    return agent.data[account].id;
  }

  function byId(Agent storage agent, uint agentId) internal view returns (address) {
    address account = agent.list[agentId];
    require(account != address(0));
    require(agent.data[account].exists && agent.data[account].id == agentId);
    return account;
  }

  function allowance(Agent storage agent, address account) internal view returns (bool) {
    require(exists(agent, account));
    return account.isContract() && agent.data[account].allowance;
  }


}

contract HasAgents is Ownable {
  using Agents for Agents.Agent;

  event AgentAdded(address indexed account);
  event AgentRemoved(address indexed account);

  Agents.Agent private agents;

  constructor() internal {
    _addAgent(msg.sender, 0, false);
  }

  modifier onlyAgent() {
    require(isAgent(msg.sender));
    _;
  }

  function isAgent(address account) public view returns (bool) {
    return agents.exists(account);
  }

  function addAgent(address account, uint id, bool allowance) public onlyOwner {
    _addAgent(account, id, allowance);
  }

  function removeAgent(address account) public onlyOwner {
    _removeAgent(account);
  }

  function renounceAgent() public {
    _removeAgent(msg.sender);
  }

  function _addAgent(address account, uint id, bool allowance) internal {
    agents.add(account, id, allowance);
    emit AgentAdded(account);
  }

  function _removeAgent(address account) internal {
    agents.remove(account);
    emit AgentRemoved(account);
  }

  function getAgentId(address account) public view returns (uint) {
    return agents.id(account);
  }

//  function getCallerAgentId() public view returns (uint) {
//    return agents.id(msg.sender);
//  }

  function getAgentById(uint id) public view returns (address) {
    return agents.byId(id);
  }

  function isAgentHasAllowance(address account) public view returns (bool) {
    return agents.allowance(account);
  }
}

// File: node_modules/openzeppelin-solidity/contracts/utils/ReentrancyGuard.sol

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <remco@2π.com>, Eenae <alexey@mixbytes.io>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

  /// @dev counter to allow mutex lock with only one SSTORE operation
  uint256 private _guardCounter;

  constructor() internal {
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

// File: lib/HasDepositary.sol

/**
 * @title Contracts that should be able to recover tokens
 * @author SylTi
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.
 * This will prevent any accidental loss of tokens.
 */
contract HasDepositary is Ownable, ReentrancyGuard  {

  event Depositary(address depositary);

  address private _depositary;

//  constructor() internal {
//    _depositary = msg.sender;
//  }

  /// @notice The fallback function payable
  function() external payable {
    require(msg.value > 0);
//    _depositary.transfer(msg.value);
  }

  function depositary() external view returns (address) {
    return _depositary;
  }

  function setDepositary(address newDepositary) external onlyOwner {
    require(newDepositary != address(0));
    require(_depositary == address(0));
    _depositary = newDepositary;
    emit Depositary(newDepositary);
  }

  function withdraw() external onlyOwner nonReentrant {
    uint256 balance = address(this).balance;
    require(balance > 0);
    if (_depositary == address(0)) {
      owner().transfer(balance);
    } else {
      _depositary.transfer(balance);
    }
  }
}

// File: node_modules/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: lib/CanReclaimToken.sol

/**
 * @title Contracts that should be able to recover tokens
 * @author SylTi
 * @dev This allow a contract to recover any ERC20 token received in a contract by transferring the balance to the contract owner.
 * This will prevent any accidental loss of tokens.
 */
contract CanReclaimToken is Ownable {

  /**
   * @dev Reclaim all ERC20 compatible tokens
   * @param token ERC20 The address of the token contract
   */
  function reclaimToken(IERC20 token) external onlyOwner {
    if (address(token) == address(0)) {
      owner().transfer(address(this).balance);
      return;
    }
    uint256 balance = token.balanceOf(this);
    token.transfer(owner(), balance);
  }

}

// File: contracts/Heroes.sol

interface AgentContract {
  function isAllowed(uint _tokenId) external returns (bool);
}

contract Heroes is Ownable, ERC721, ERC721Enumerable, ERC721Metadata, HasAgents, HasDepositary {

  uint256 private lastId = 1000;

  event Mint(address indexed to, uint256 indexed tokenId);
  event Burn(address indexed from, uint256 indexed tokenId);


  constructor() HasAgents() ERC721Metadata(
      "CRYPTO HEROES", //name
      "CH ⚔️", //symbol
      "https://api.cryptoheroes.app/hero/", //baseURI
      "The first blockchain game in the world with famous characters and fights built on real cryptocurrency exchange quotations.", //description
      "https://cryptoheroes.app" //url
  ) public {}

  /**
   * @dev Function to set the token base URI
   * @param uri string URI to assign
   */
  function setBaseURI(string uri) external onlyOwner {
    _setBaseURI(uri);
  }
  function setDescription(string description) external onlyOwner {
    _setDescription(description);
  }
  function setURL(string url) external onlyOwner {
    _setURL(url);
  }

  /**
   * @dev override
   */
  function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
    return (
    super._isApprovedOrOwner(spender, tokenId) ||
    //approve tx from agents on behalf user
    //agent's functions must have onlyOwnerOf modifier to prevent phishing from 3-d party contracts
    (isAgent(spender) && super._isApprovedOrOwner(tx.origin, tokenId)) ||
    //just for exceptional cases, no reason to abuse
    owner() == spender
    );
  }


  /**
    * @dev Mints a token to an address
    * @param to The address that will receive the minted tokens.
    * @param genes token genes
    * @param level token level
    * @return A new token id.
    */
  function mint(address to, uint256 genes, uint256 level) public onlyAgent returns (uint) {
    lastId = lastId.add(1);
    return mint(lastId, to, genes, level);
//    _mint(to, lastId);
//    _setMetadata(lastId, genes, level);
//    emit Mint(to, lastId);
//    return lastId;
  }

  /**
  * @dev Mints a token with specific id to an address
  * @param to The address that will receive the minted tokens.
  * @param genes token genes
  * @param level token level
  * @return A new token id.
  */
  function mint(uint256 tokenId, address to, uint256 genes, uint256 level) public onlyAgent returns (uint) {
    _mint(to, tokenId);
    _setMetadata(tokenId, genes, level);
    emit Mint(to, tokenId);
    return tokenId;
  }


  /**
 * @dev Function to burn tokens from sender address
 * @param tokenId The token id to burn.
 * @return A burned token id.
 */
  function burn(uint256 tokenId) public returns (uint) {
    require(_isApprovedOrOwner(msg.sender, tokenId));
    address owner = ownerOf(tokenId);
    _clearMetadata(tokenId);
    _burn(owner, tokenId);
    emit Burn(owner, tokenId);
    return tokenId;
  }


  /* CHARACTER LOGIC */

  function addWin(uint256 _tokenId, uint _winsCount, uint _levelUp) external onlyAgent returns (bool){
    require(_addWin(_tokenId, _winsCount, _levelUp));
    return true;
  }

  function addLoss(uint256 _tokenId, uint _lossesCount, uint _levelDown) external onlyAgent returns (bool){
    require(_addLoss(_tokenId, _lossesCount, _levelDown));
    return true;
  }

  /* LOCKS */

  /*
   * Принудительно пере-блокируем свободного персонажа c текущего агента на указанный
   */
  function lock(uint256 _tokenId, uint256 _lockedTo, bool _onlyFreeze) external onlyAgent returns(bool) {
    require(_exists(_tokenId));
    uint agentId = getAgentId(msg.sender);
    Character storage c = characters[_tokenId];
    if (c.lockId != 0 && agentId != c.lockId) {
      //если текущий агент другой, то вызываем его функция "проверки  персонажа"
      address a = getAgentById(c.lockId);
      if (isAgentHasAllowance(a)) {
        AgentContract ac = AgentContract(a);
        require(ac.isAllowed(_tokenId));
      }
    }
    require(_setLock(_tokenId, _lockedTo, _onlyFreeze ? c.lockId : agentId, agentId));
    return true;
  }

  function unlock(uint256 _tokenId) external onlyAgent returns (bool){
    require(_exists(_tokenId));
    uint agentId = getAgentId(msg.sender);
    //only current owned agent allowed
    require(agentId == characters[_tokenId].lockId);
    require(_setLock(_tokenId, 0, 0, agentId));
    return true;
  }

  function isCallerAgentOf(uint _tokenId) public view returns (bool) {
    require(_exists(_tokenId));
    return isAgent(msg.sender) && getAgentId(msg.sender) == characters[_tokenId].lockId;
  }

  /**
  * @dev Transfers the ownership of a given token ID from the owner to another address
  * Usage of this method is discouraged, use `safeTransferFrom` whenever possible
  * Requires the msg sender to be the owner, approved, or operator
  * @param to address to receive the ownership of the given token ID
  * @param tokenId uint256 ID of the token to be transferred
 */
  function transfer(address to, uint256 tokenId) public {
    transferFrom(msg.sender, to, tokenId);
  }
}