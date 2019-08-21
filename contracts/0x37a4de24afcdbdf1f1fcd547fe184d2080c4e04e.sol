pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: openzeppelin-solidity/contracts/introspection/IERC165.sol

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

// File: openzeppelin-solidity/contracts/token/ERC721/IERC721.sol

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

// File: openzeppelin-solidity/contracts/token/ERC721/IERC721Receiver.sol

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

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: openzeppelin-solidity/contracts/utils/Address.sol

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

// File: openzeppelin-solidity/contracts/introspection/ERC165.sol

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

// File: openzeppelin-solidity/contracts/token/ERC721/ERC721.sol

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

// File: openzeppelin-solidity/contracts/token/ERC721/IERC721Enumerable.sol

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

// File: openzeppelin-solidity/contracts/token/ERC721/ERC721Enumerable.sol

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

// File: openzeppelin-solidity/contracts/token/ERC721/IERC721Metadata.sol

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract IERC721Metadata is IERC721 {
  function name() external view returns (string);
  function symbol() external view returns (string);
  function tokenURI(uint256 tokenId) external view returns (string);
}

// File: openzeppelin-solidity/contracts/token/ERC721/ERC721Metadata.sol

contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {
  // Token name
  string private _name;

  // Token symbol
  string private _symbol;

  // Optional mapping for token URIs
  mapping(uint256 => string) private _tokenURIs;

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
  constructor(string name, string symbol) public {
    _name = name;
    _symbol = symbol;

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
   * @dev Returns an URI for a given token ID
   * Throws if the token ID does not exist. May return an empty string.
   * @param tokenId uint256 ID of the token to query
   */
  function tokenURI(uint256 tokenId) external view returns (string) {
    require(_exists(tokenId));
    return _tokenURIs[tokenId];
  }

  /**
   * @dev Internal function to set the token URI for a given token
   * Reverts if the token ID does not exist
   * @param tokenId uint256 ID of the token to set its URI
   * @param uri string URI to assign
   */
  function _setTokenURI(uint256 tokenId, string uri) internal {
    require(_exists(tokenId));
    _tokenURIs[tokenId] = uri;
  }

  /**
   * @dev Internal function to burn a specific token
   * Reverts if the token does not exist
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

// File: openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol

/**
 * @title Full ERC721 Token
 * This implementation includes all the required and some optional functionality of the ERC721 standard
 * Moreover, it includes approve all functionality using operator terminology
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Full is ERC721, ERC721Enumerable, ERC721Metadata {
  constructor(string name, string symbol) ERC721Metadata(name, symbol)
    public
  {
  }
}

// File: contracts/Referrers.sol

contract Referrers is Ownable {
    using SafeMath for uint256;

    // Referrer bonus in %
    uint public referrerBonusSale;
    uint public referrerBonusWin;
    uint public _referrerId;
    // mapping referrerId to address
    mapping(uint => address) public referrerToAddress;
    // Tickets referals: tokeId => referrerId
    mapping(uint => uint) public ticketToReferrer;
    // Tickets of referrer
    mapping(uint => uint[]) public referrerTickets;
    // mapping address to referrerId
    mapping(address => uint) public addressToReferrer;
    mapping(uint => uint) public totalEarnReferrer;

    constructor() public {
        referrerBonusSale = 8;
        referrerBonusWin = 2;
        _referrerId = 0;
    }

    function _setTicketReferrer(uint _tokenId, uint _referrer) internal {
        require(ticketToReferrer[_tokenId] == 0);
        ticketToReferrer[_tokenId] = _referrer;
        referrerTickets[_referrer].push(_tokenId);
    }

    function registerReferrer() public {
        require(addressToReferrer[msg.sender] == 0);
        _referrerId = _referrerId.add(1);
        addressToReferrer[msg.sender] = _referrerId;
        referrerToAddress[_referrerId] = msg.sender;
    }

    function getReferrerTickets(uint _referrer) public view returns (uint[]) {
        return referrerTickets[_referrer];
    }

    // Admin methods
    function setReferrerBonusWin(uint _amount) public onlyOwner {
        referrerBonusWin = _amount;
    }

    function setReferrerBonusSale(uint _amount) public onlyOwner {
        referrerBonusSale = _amount;
    }
    //End admin methods
}

// File: contracts/Utils.sol

library Utils {
    function pack(uint[] _data) internal pure returns(uint) {
        uint result = 0;
        for (uint i=0;i<_data.length;i++) {
            result += 2**_data[i];
        }
        return result;
    }

    function unpack(uint _data, uint _maxBallsCount) internal pure returns(uint[]) {
        uint[] memory result = new uint256[](_maxBallsCount);
        uint iPosition = 0;
        uint i = 0;
        while (_data != 0) {
            if ((_data & 1) == 1) {
                result[iPosition] = i;
                iPosition++;
            }
            i++;
            _data >>= 1;
        }
        return result;
    }

    function popcount(uint x) public pure returns(uint) {
        uint count;
        for (count=0; x > 0; count++) {
            x &= x - 1;
        }
        return count;
    }

    function getBonusAmount(uint _amount, uint _bonusPercent) internal pure returns (uint) {
        return _amount * _bonusPercent / 100;
    }

    function addr2str(address _addr) internal pure returns(string) {
        bytes32 value = bytes32(uint256(_addr));
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint(value[i + 12] >> 4)];
            str[3+i*2] = alphabet[uint(value[i + 12] & 0x0f)];
        }
        return string(str);
    }
}

// File: contracts/Balance.sol

library Balance {
    using SafeMath for uint256;

    struct BalanceStorage {
        // users/referrals balances
        mapping(address => uint) balances;
        mapping(address => uint) totalEarn;
    }

    // Add amount wei to address balance
    function _addBalance(BalanceStorage storage self, address _address, uint _amount) internal {
        self.balances[_address] = self.balances[_address].add(_amount);
        self.totalEarn[_address] = self.totalEarn[_address].add(_amount);
    }

    function _subBalance(BalanceStorage storage self, address _address, uint _amount) internal {
        self.balances[_address] = self.balances[_address].sub(_amount);
        self.totalEarn[_address] = self.totalEarn[_address].sub(_amount);
    }

    function _clearBalance(BalanceStorage storage self, address _address) internal {
        self.balances[_address] = 0;
    }

    function _getBalance(BalanceStorage storage self, address _address) internal view returns (uint){
        return self.balances[_address];
    }

    function _getTotalEarn(BalanceStorage storage self, address _address) internal view returns (uint){
        return self.totalEarn[_address];
    }
}

// File: contracts/CryptoBall645.sol

//Write your own contracts here. Currently compiles using solc v0.4.15+commit.bbb8e64f.
pragma solidity ^0.4.25;







contract DrawContractI {
    function ticketToDraw(uint _tokenId) public returns (uint);
    function drawNumber() public returns (uint);
    function drawTime(uint _drawNumber) public returns (uint);
    function ticketPrizes(uint _tokenId) public returns (uint);
    function registerTicket(uint _tokenId, uint[] _numbers, uint _ticketPrice, uint _ownerBonusSale, uint _referrerBonusSale, uint _drawNumber) external;
    function checkTicket(uint _tokenId) external;
    function addSuperPrize(uint _amount) external;
}

contract CryptoBall645 is ERC721Full("Crypto balls 6/45", "B645"), Ownable, Referrers {
    using Balance for Balance.BalanceStorage;
    Balance.BalanceStorage balance;

    event OwnerBonus(address indexed _to, uint _amount);
    event ReferrerBonus(address indexed _to, uint _amount);

    using SafeMath for uint256;

    uint constant public MAX_BALLS_COUNT = 6;
    uint constant public MAX_BALL_NUMBER = 45;

    //Bonus of contract owner
    uint public ownerBonusSale = 25;
    uint public ownerBonusWin = 0;

    uint public ticketPrice = 0.01 ether;

    uint public tokenIds = 0;
    mapping(uint => uint) public mintDate;

    DrawContractI drawContract;
    address public drawContractAddress;

    modifier onlyDrawContract() {
        require(msg.sender == drawContractAddress);
        _;
    }

    modifier allowBuyTicket() {
        require(msg.value == ticketPrice);
        _;
    }

    modifier allowBuyTicketCount(uint _drawCount) {
        require(msg.value == ticketPrice*_drawCount);
        _;
    }

    modifier allowRegisterTicket(uint[] _numbers) {
        require(_numbers.length == MAX_BALLS_COUNT);
        for (uint i = 0; i < MAX_BALLS_COUNT; i++) {
            require(_numbers[i] > 0);
            require(_numbers[i] <= MAX_BALL_NUMBER);
            for (uint t = 0; t < MAX_BALLS_COUNT; t++) {
                if (t == i) {
                    continue;
                }
                require(_numbers[t]!=_numbers[i]);
            }
        }
        _;
    }

    /**
      * @dev Guarantees msg.sender is owner of the given token
      * @param _tokenId uint256 ID of the token to validate its ownership belongs to msg.sender
      */
    modifier onlyOwnerOf(uint256 _tokenId) {
        require(ownerOf(_tokenId) == msg.sender);
        _;
    }

    // Update ticket price
    function setTicketPrice(uint _amount) external onlyOwner {
        ticketPrice = _amount;
    }

    // Update sale bonus for owner
    function setOwnerBonusSale(uint _amount) external onlyOwner {
        ownerBonusSale = _amount;
    }

    // Update win bonus for owner
    function setOwnerBonusWin(uint _amount) external onlyOwner {
        ownerBonusWin = _amount;
    }

    function setDrawContract(address _address) public onlyOwner {
        drawContractAddress = _address;
        drawContract = DrawContractI(_address);
    }

    function burn(uint _tokenId) external onlyOwner {
        require((now - mintDate[_tokenId]) / 60 / 60 / 24 > 30);
        require(drawContract.ticketToDraw(_tokenId) == 0);
        uint _refundPrice = ticketPrice * (100 - ownerBonusSale - referrerBonusSale) / 100;
        balance._addBalance(owner(), _refundPrice);
        _burn(ownerOf(_tokenId), _tokenId);
    }

    // Tokens list of user
    function getMyTickets() public view returns (uint256[]) {
        uint _myTotalTokens = balanceOf(msg.sender);
        uint[] memory _myTokens = new uint[](_myTotalTokens);
        uint k = 0;
        for (uint i = 0; i <= totalSupply(); i++) {
            uint _myTokenId = tokenOfOwnerByIndex(msg.sender, i);
            if (_myTokenId > 0) {
                _myTokens[k] = _myTokenId;
                k++;
                if (k >= _myTotalTokens) {
                    break;
                }
            }
        }
        return _myTokens;
    }

    // Buy ticket
    function _buyToken(address _to, uint _referrerId) private returns (uint) {
        tokenIds = tokenIds.add(1);
        uint _tokenId = tokenIds;
        _mint(_to, _tokenId);
        transferFrom(ownerOf(_tokenId), msg.sender, _tokenId);
        mintDate[_tokenId] = now;
        // Send bonus to the owner
        _addOwnerBonus(ticketPrice, ownerBonusSale);
        // Send bonus to the referrer if referrerId was sent and referrer was registered
        if (_referrerId == 0) {
            _referrerId = addressToReferrer[owner()];
        }
        if (_referrerId > 0 && referrerToAddress[_referrerId] > 0) {
            _addReferrerBonus(_referrerId, ticketPrice, referrerBonusSale);
            _setTicketReferrer(_tokenId, _referrerId);
        }
        return _tokenId;
    }

    function() public payable {
        require(msg.value >= ticketPrice);
        uint ticketsCount = msg.value / ticketPrice;
        uint returnCount = msg.value % ticketPrice;

        if (returnCount > 0) {
            msg.sender.transfer(returnCount);
        }
        for (uint i = 1; i <= ticketsCount; i++) {
            _buyToken(msg.sender, 0);
        }
    }

    // User buy new ticket
    function buyTicket(uint _referrerId) public payable allowBuyTicket {
        _buyToken(msg.sender, _referrerId);
    }

    // Buy, fill and register ticket
    function buyAndRegisterTicket(uint _referrerId, uint[] _numbers, uint _drawCount) public payable allowBuyTicketCount(_drawCount) allowRegisterTicket(_numbers) returns (uint){
        uint _drawNumber = drawContract.drawNumber();
        for (uint i = 0; i<_drawCount; i++) {
            uint _tokenId = _buyToken(msg.sender, _referrerId);
            uint _draw = _drawNumber + i;
            drawContract.registerTicket(_tokenId, _numbers, ticketPrice, ownerBonusSale, referrerBonusSale, _draw);
        }
    }

    // Register ticket to the nearest drawing
    function registerTicket(uint _tokenId, uint[] _numbers, uint _drawNumber) public onlyOwnerOf(_tokenId) allowRegisterTicket(_numbers) {
        //Ticket not yet filled
        require(drawContract.ticketToDraw(_tokenId) == 0);
        drawContract.registerTicket(_tokenId, _numbers, ticketPrice, ownerBonusSale, referrerBonusSale, _drawNumber);
    }

    function _checkTicket(uint _tokenId, address _receiver) private returns (bool) {
        drawContract.checkTicket(_tokenId);
        uint _prize = drawContract.ticketPrizes(_tokenId);
        if (_prize > 0) {
            if (_prize == ticketPrice) {
                _buyToken(_receiver, ticketToReferrer[_tokenId]);
                balance._subBalance(owner(), ticketPrice);
            } else {
                _addPriceToBalance(_tokenId, _prize, _receiver);
            }
        }
        return true;
    }

    // Check ticket and move prize to balance
    function checkTicket(uint _tokenId) public {
        require(_exists(_tokenId));
        require(_checkTicket(_tokenId, ownerOf(_tokenId)));
    }

    // Contract owner can withdraw prizes after 30 days if winner didn't withdraw it
    function withdrawTicketPrize(uint _tokenId) public onlyOwner {
        require(_exists(_tokenId));
        uint _ticketDraw = drawContract.ticketToDraw(_tokenId);
        require((now - drawContract.drawTime(_ticketDraw)) / 60 / 60 / 24 > 30);
        require(_checkTicket(_tokenId, owner()));
    }

    function _addPriceToBalance(uint _tokenId, uint _prizeAmount, address _receiver) private {
        uint _ownerBonus = Utils.getBonusAmount(_prizeAmount, ownerBonusWin);
        uint _referrerBonus = Utils.getBonusAmount(_prizeAmount, referrerBonusWin);
        uint _referrerId = ticketToReferrer[_tokenId];
        uint winnerPrizeAmount = _prizeAmount - _ownerBonus - _referrerBonus;
        balance._addBalance(_receiver, winnerPrizeAmount);
        _addReferrerBonus(_referrerId, winnerPrizeAmount, referrerBonusWin);
        _addOwnerBonus(winnerPrizeAmount, ownerBonusWin);
    }

    // Get My balance
    function getMyBalance() public view returns (uint){
        return balance._getBalance(msg.sender);
    }

    // Withdraw My balance
    function withdrawMyBalance() public {
        uint _userBalance = balance._getBalance(msg.sender);
        require(_userBalance > 0);
        require(address(this).balance >= _userBalance);
        balance._clearBalance(msg.sender);
        msg.sender.transfer(_userBalance);
        emit Transfer(this, msg.sender, _userBalance);
    }

    function withdrawBalanceAmount(uint _amount) public {
        uint _userBalance = balance._getBalance(msg.sender);
        require(_userBalance > 0);
        require(_amount <= _userBalance);
        require(address(this).balance >= _amount);
        balance._subBalance(msg.sender, _amount);
        msg.sender.transfer(_amount);
        emit Transfer(this, msg.sender, _amount);
    }

    function _addReferrerBonus(uint _referrer, uint _fromAmount, uint _bonusPercent) internal {
        address _referrerAddress = referrerToAddress[_referrer];
        if (_referrerAddress == address(0)) {
            _referrerAddress = owner();
        }
        uint _amount = Utils.getBonusAmount(_fromAmount, _bonusPercent);
        if (_amount > 0) {
            balance._addBalance(_referrerAddress, _amount);
            totalEarnReferrer[_referrer] = totalEarnReferrer[_referrer].add(_amount);
            emit ReferrerBonus(_referrerAddress, _amount);
        }
    }

    function _addOwnerBonus(uint _fromAmount, uint _bonusPercent) internal {
        uint _amount = Utils.getBonusAmount(_fromAmount, _bonusPercent);
        if (_amount > 0) {
            balance._addBalance(owner(), _amount);
            emit OwnerBonus(owner(), _amount);
        }
    }

    function addBalance(address _address, uint _amount) external onlyDrawContract {
        balance._addBalance(_address, _amount);
    }

    function addSuperPrize() public payable {
        drawContract.addSuperPrize(msg.value);
    }
}