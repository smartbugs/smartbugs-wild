pragma solidity ^0.4.24;

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

// File: contracts/library/token/ERC721Manager.sol

/**
 * @title ERC721Manager
 *
 * @dev This library implements OpenZepellin's ERC721 implementation (as of 7/31/2018) as
 * an external library, in order to keep contract sizes smaller.
 *
 * Released under the MIT License.
 *
 *
 * The MIT License (MIT)
 *
 * Copyright (c) 2016 Smart Contract Solutions, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */
library ERC721Manager {

    using SafeMath for uint256;

    // We define the events on both the library and the client, so that the events emitted here are detected
    // as if they had been emitted by the client
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

    struct ERC721Data {
        // List of supported interfaces
        mapping (bytes4 => bool) supportedInterfaces;

        // Mapping from token ID to owner
        mapping (uint256 => address) tokenOwner;

        // Mapping from token ID to approved address
        mapping (uint256 => address) tokenApprovals;

        // Mapping from owner to number of owned token
        mapping (address => uint256) ownedTokensCount;

        // Mapping from owner to operator approvals
        mapping (address => mapping (address => bool)) operatorApprovals;


        // Token name
        string name_;

        // Token symbol
        string symbol_;

        // Mapping from owner to list of owned token IDs
        mapping(address => uint256[]) ownedTokens;

        // Mapping from token ID to index of the owner tokens list
        mapping(uint256 => uint256) ownedTokensIndex;

        // Array with all token ids, used for enumeration
        uint256[] allTokens;

        // Mapping from token id to position in the allTokens array
        mapping(uint256 => uint256) allTokensIndex;

        // Optional mapping for token URIs
        mapping(uint256 => string) tokenURIs;
    }

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant ERC721_RECEIVED = 0x150b7a02;


    bytes4 private constant InterfaceId_ERC165 = 0x01ffc9a7;
    /**
     * 0x01ffc9a7 ===
     *   bytes4(keccak256('supportsInterface(bytes4)'))
     */

    bytes4 private constant InterfaceId_ERC721 = 0x80ac58cd;
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

    bytes4 private constant InterfaceId_ERC721Exists = 0x4f558e79;
    /*
     * 0x4f558e79 ===
     *   bytes4(keccak256('exists(uint256)'))
     */

    bytes4 private constant InterfaceId_ERC721Enumerable = 0x780e9d63;
    /**
     * 0x780e9d63 ===
     *   bytes4(keccak256('totalSupply()')) ^
     *   bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^
     *   bytes4(keccak256('tokenByIndex(uint256)'))
     */

    bytes4 private constant InterfaceId_ERC721Metadata = 0x5b5e139f;
    /**
     * 0x5b5e139f ===
     *   bytes4(keccak256('name()')) ^
     *   bytes4(keccak256('symbol()')) ^
     *   bytes4(keccak256('tokenURI(uint256)'))
     */


    function initialize(ERC721Data storage self, string _name, string _symbol) external {
        self.name_ = _name;
        self.symbol_ = _symbol;

        // register the supported interface to conform to ERC165
        _registerInterface(self, InterfaceId_ERC165);

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(self, InterfaceId_ERC721);
        _registerInterface(self, InterfaceId_ERC721Exists);
        _registerInterface(self, InterfaceId_ERC721Enumerable);
        _registerInterface(self, InterfaceId_ERC721Metadata);
    }

    function _registerInterface(ERC721Data storage self, bytes4 _interfaceId) private {
        self.supportedInterfaces[_interfaceId] = true;
    }

    function supportsInterface(ERC721Data storage self, bytes4 _interfaceId) external view returns (bool) {
        return self.supportedInterfaces[_interfaceId];
    }

    /**
     * @dev Gets the balance of the specified address
     * @param _owner address to query the balance of
     * @return uint256 representing the amount owned by the passed address
     */
    function balanceOf(ERC721Data storage self, address _owner) public view returns (uint256) {
        require(_owner != address(0));
        return self.ownedTokensCount[_owner];
    }

    /**
     * @dev Gets the owner of the specified token ID
     * @param _tokenId uint256 ID of the token to query the owner of
     * @return owner address currently marked as the owner of the given token ID
     */
    function ownerOf(ERC721Data storage self, uint256 _tokenId) public view returns (address) {
        address owner = self.tokenOwner[_tokenId];
        require(owner != address(0));
        return owner;
    }

    /**
     * @dev Returns whether the specified token exists
     * @param _tokenId uint256 ID of the token to query the existence of
     * @return whether the token exists
     */
    function exists(ERC721Data storage self, uint256 _tokenId) public view returns (bool) {
        address owner = self.tokenOwner[_tokenId];
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
    function approve(ERC721Data storage self, address _to, uint256 _tokenId) external {
        address owner = ownerOf(self, _tokenId);
        require(_to != owner);
        require(msg.sender == owner || isApprovedForAll(self, owner, msg.sender));

        self.tokenApprovals[_tokenId] = _to;

        emit Approval(owner, _to, _tokenId);
    }

    /**
     * @dev Gets the approved address for a token ID, or zero if no address set
     * @param _tokenId uint256 ID of the token to query the approval of
     * @return address currently approved for the given token ID
     */
    function getApproved(ERC721Data storage self, uint256 _tokenId) public view returns (address) {
        return self.tokenApprovals[_tokenId];
    }

    /**
     * @dev Sets or unsets the approval of a given operator
     * An operator is allowed to transfer all tokens of the sender on their behalf
     * @param _to operator address to set the approval
     * @param _approved representing the status of the approval to be set
     */
    function setApprovalForAll(ERC721Data storage self, address _to, bool _approved) external {
        require(_to != msg.sender);
        self.operatorApprovals[msg.sender][_to] = _approved;
        emit ApprovalForAll(msg.sender, _to, _approved);
    }

    /**
     * @dev Tells whether an operator is approved by a given owner
     * @param _owner owner address which you want to query the approval of
     * @param _operator operator address which you want to query the approval of
     * @return bool whether the given operator is approved by the given owner
     */
    function isApprovedForAll(
        ERC721Data storage self,
        address _owner,
        address _operator
    ) public view returns (bool) {
        return self.operatorApprovals[_owner][_operator];
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
        ERC721Data storage self,
        address _from,
        address _to,
        uint256 _tokenId
    ) public {
        require(isApprovedOrOwner(self, msg.sender, _tokenId));
        require(_from != address(0));
        require(_to != address(0));

        _clearApproval(self, _from, _tokenId);
        _removeTokenFrom(self, _from, _tokenId);
        _addTokenTo(self, _to, _tokenId);

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
        ERC721Data storage self,
        address _from,
        address _to,
        uint256 _tokenId
    ) external {
        // solium-disable-next-line arg-overflow
        safeTransferFrom(self, _from, _to, _tokenId, "");
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
        ERC721Data storage self,
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    ) public {
        transferFrom(self, _from, _to, _tokenId);
        // solium-disable-next-line arg-overflow
        require(_checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
    }

    /**
     * @dev Internal function to clear current approval of a given token ID
     * Reverts if the given address is not indeed the owner of the token
     * @param _owner owner of the token
     * @param _tokenId uint256 ID of the token to be transferred
     */
    function _clearApproval(ERC721Data storage self, address _owner, uint256 _tokenId) internal {
        require(ownerOf(self, _tokenId) == _owner);
        if (self.tokenApprovals[_tokenId] != address(0)) {
            self.tokenApprovals[_tokenId] = address(0);
        }
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
    function _checkAndCallSafeTransfer(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    ) internal returns (bool) {
        if (!_isContract(_to)) {
            return true;
        }
        bytes4 retval = IERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
        return (retval == ERC721_RECEIVED);
    }

    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param _addr address to check
     * @return whether the target address is a contract
     */
    function _isContract(address _addr) internal view returns (bool) {
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


    /**
     * @dev Gets the token name
     * @return string representing the token name
     */
    function name(ERC721Data storage self) external view returns (string) {
        return self.name_;
    }

    /**
     * @dev Gets the token symbol
     * @return string representing the token symbol
     */
    function symbol(ERC721Data storage self) external view returns (string) {
        return self.symbol_;
    }

    /**
     * @dev Returns an URI for a given token ID
     * Throws if the token ID does not exist. May return an empty string.
     * @param _tokenId uint256 ID of the token to query
     */
    function tokenURI(ERC721Data storage self, uint256 _tokenId) external view returns (string) {
        require(exists(self, _tokenId));
        return self.tokenURIs[_tokenId];
    }

    /**
     * @dev Gets the token ID at a given index of the tokens list of the requested owner
     * @param _owner address owning the tokens list to be accessed
     * @param _index uint256 representing the index to be accessed of the requested tokens list
     * @return uint256 token ID at the given index of the tokens list owned by the requested address
     */
    function tokenOfOwnerByIndex(
        ERC721Data storage self,
        address _owner,
        uint256 _index
    ) external view returns (uint256) {
        require(_index < balanceOf(self, _owner));
        return self.ownedTokens[_owner][_index];
    }

    /**
     * @dev Gets the total amount of tokens stored by the contract
     * @return uint256 representing the total amount of tokens
     */
    function totalSupply(ERC721Data storage self) external view returns (uint256) {
        return self.allTokens.length;
    }

    /**
     * @dev Gets the token ID at a given index of all the tokens in this contract
     * Reverts if the index is greater or equal to the total number of tokens
     * @param _index uint256 representing the index to be accessed of the tokens list
     * @return uint256 token ID at the given index of the tokens list
     */
    function tokenByIndex(ERC721Data storage self, uint256 _index) external view returns (uint256) {
        require(_index < self.allTokens.length);
        return self.allTokens[_index];
    }

    /**
     * @dev Function to set the token URI for a given token
     * Reverts if the token ID does not exist
     * @param _tokenId uint256 ID of the token to set its URI
     * @param _uri string URI to assign
     */
    function setTokenURI(ERC721Data storage self, uint256 _tokenId, string _uri) external {
        require(exists(self, _tokenId));
        self.tokenURIs[_tokenId] = _uri;
    }

    /**
     * @dev Internal function to add a token ID to the list of a given address
     * @param _to address representing the new owner of the given token ID
     * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
     */
    function _addTokenTo(ERC721Data storage self, address _to, uint256 _tokenId) internal {
        require(self.tokenOwner[_tokenId] == address(0));
        self.tokenOwner[_tokenId] = _to;
        self.ownedTokensCount[_to] = self.ownedTokensCount[_to].add(1);

        uint256 length = self.ownedTokens[_to].length;
        self.ownedTokens[_to].push(_tokenId);
        self.ownedTokensIndex[_tokenId] = length;
    }

    /**
     * @dev Internal function to remove a token ID from the list of a given address
     * @param _from address representing the previous owner of the given token ID
     * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
     */
    function _removeTokenFrom(ERC721Data storage self, address _from, uint256 _tokenId) internal {
        require(ownerOf(self, _tokenId) == _from);
        self.ownedTokensCount[_from] = self.ownedTokensCount[_from].sub(1);
        self.tokenOwner[_tokenId] = address(0);

        // To prevent a gap in the array, we store the last token in the index of the token to delete, and
        // then delete the last slot.
        uint256 tokenIndex = self.ownedTokensIndex[_tokenId];
        uint256 lastTokenIndex = self.ownedTokens[_from].length.sub(1);
        uint256 lastToken = self.ownedTokens[_from][lastTokenIndex];

        self.ownedTokens[_from][tokenIndex] = lastToken;
        self.ownedTokens[_from].length--;
        // ^ This also deletes the contents at the last position of the array

        // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to
        // be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we are first swapping
        // the lastToken to the first position, and then dropping the element placed in the last position of the list

        self.ownedTokensIndex[_tokenId] = 0;
        self.ownedTokensIndex[lastToken] = tokenIndex;
    }

    /**
     * @dev Function to mint a new token
     * Reverts if the given token ID already exists
     * @param _to address the beneficiary that will own the minted token
     * @param _tokenId uint256 ID of the token to be minted by the msg.sender
     */
    function mint(ERC721Data storage self, address _to, uint256 _tokenId) external {
        require(_to != address(0));
        _addTokenTo(self, _to, _tokenId);
        emit Transfer(address(0), _to, _tokenId);

        self.allTokensIndex[_tokenId] = self.allTokens.length;
        self.allTokens.push(_tokenId);
    }

    /**
     * @dev Function to burn a specific token
     * Reverts if the token does not exist
     * @param _owner owner of the token to burn
     * @param _tokenId uint256 ID of the token being burned by the msg.sender
     */
    function burn(ERC721Data storage self, address _owner, uint256 _tokenId) external {
        _clearApproval(self, _owner, _tokenId);
        _removeTokenFrom(self, _owner, _tokenId);
        emit Transfer(_owner, address(0), _tokenId);

        // Clear metadata (if any)
        if (bytes(self.tokenURIs[_tokenId]).length != 0) {
            delete self.tokenURIs[_tokenId];
        }

        // Reorg all tokens array
        uint256 tokenIndex = self.allTokensIndex[_tokenId];
        uint256 lastTokenIndex = self.allTokens.length.sub(1);
        uint256 lastToken = self.allTokens[lastTokenIndex];

        self.allTokens[tokenIndex] = lastToken;
        self.allTokens[lastTokenIndex] = 0;

        self.allTokens.length--;
        self.allTokensIndex[_tokenId] = 0;
        self.allTokensIndex[lastToken] = tokenIndex;
    }

    /**
     * @dev Returns whether the given spender can transfer a given token ID
     * @param _spender address of the spender to query
     * @param _tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     *  is an operator of the owner, or is the owner of the token
     */
    function isApprovedOrOwner(
        ERC721Data storage self,
        address _spender,
        uint256 _tokenId
    ) public view returns (bool) {
        address owner = ownerOf(self, _tokenId);
        // Disable solium check because of
        // https://github.com/duaraghav8/Solium/issues/175
        // solium-disable-next-line operator-whitespace
        return (
            _spender == owner
            || getApproved(self, _tokenId) == _spender
            || isApprovedForAll(self, owner, _spender)
        );
    }

}

// File: contracts/library/token/ERC721Token.sol

/**
 * @title ERC721Token
 *
 * @dev This token interfaces with the OpenZepellin's ERC721 implementation (as of 7/31/2018) as
 * an external library, in order to keep contract sizes smaller.  Intended for use with the
 * ERC721Manager.sol, also provided.
 *
 * Both files are released under the MIT License.
 *
 *
 * The MIT License (MIT)
 *
 * Copyright (c) 2016 Smart Contract Solutions, Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */
contract ERC721Token is ERC165, ERC721 {

    ERC721Manager.ERC721Data internal erc721Data;

    // We define the events on both the library and the client, so that the events emitted here are detected
    // as if they had been emitted by the client
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


    constructor(string _name, string _symbol) public {
        ERC721Manager.initialize(erc721Data, _name, _symbol);
    }

    function supportsInterface(bytes4 _interfaceId) external view returns (bool) {
        return ERC721Manager.supportsInterface(erc721Data, _interfaceId);
    }

    function balanceOf(address _owner) public view returns (uint256 _balance) {
        return ERC721Manager.balanceOf(erc721Data, _owner);
    }

    function ownerOf(uint256 _tokenId) public view returns (address _owner) {
        return ERC721Manager.ownerOf(erc721Data, _tokenId);
    }

    function exists(uint256 _tokenId) public view returns (bool _exists) {
        return ERC721Manager.exists(erc721Data, _tokenId);
    }

    function approve(address _to, uint256 _tokenId) public {
        ERC721Manager.approve(erc721Data, _to, _tokenId);
    }

    function getApproved(uint256 _tokenId) public view returns (address _operator) {
        return ERC721Manager.getApproved(erc721Data, _tokenId);
    }

    function setApprovalForAll(address _to, bool _approved) public {
        ERC721Manager.setApprovalForAll(erc721Data, _to, _approved);
    }

    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return ERC721Manager.isApprovedForAll(erc721Data, _owner, _operator);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public {
        ERC721Manager.transferFrom(erc721Data, _from, _to, _tokenId);
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public {
        ERC721Manager.safeTransferFrom(erc721Data, _from, _to, _tokenId);
    }

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    ) public {
        ERC721Manager.safeTransferFrom(erc721Data, _from, _to, _tokenId, _data);
    }


    function totalSupply() public view returns (uint256) {
        return ERC721Manager.totalSupply(erc721Data);
    }

    function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256 _tokenId) {
        return ERC721Manager.tokenOfOwnerByIndex(erc721Data, _owner, _index);
    }

    function tokenByIndex(uint256 _index) public view returns (uint256) {
        return ERC721Manager.tokenByIndex(erc721Data, _index);
    }

    function name() external view returns (string _name) {
        return erc721Data.name_;
    }

    function symbol() external view returns (string _symbol) {
        return erc721Data.symbol_;
    }

    function tokenURI(uint256 _tokenId) public view returns (string) {
        return ERC721Manager.tokenURI(erc721Data, _tokenId);
    }


    function _mint(address _to, uint256 _tokenId) internal {
        ERC721Manager.mint(erc721Data, _to, _tokenId);
    }

    function _burn(address _owner, uint256 _tokenId) internal {
        ERC721Manager.burn(erc721Data, _owner, _tokenId);
    }

    function _setTokenURI(uint256 _tokenId, string _uri) internal {
        ERC721Manager.setTokenURI(erc721Data, _tokenId, _uri);
    }

    function isApprovedOrOwner(
        address _spender,
        uint256 _tokenId
    ) public view returns (bool) {
        return ERC721Manager.isApprovedOrOwner(erc721Data, _spender, _tokenId);
    }
}

// File: contracts/library/data/PRNG.sol

/**
 * Implementation of the xorshift128+ PRNG
 */
library PRNG {

    struct Data {
        uint64 s0;
        uint64 s1;
    }

    function next(Data storage self) external returns (uint64) {
        uint64 x = self.s0;
        uint64 y = self.s1;

        self.s0 = y;
        x ^= x << 23; // a
        self.s1 = x ^ y ^ (x >> 17) ^ (y >> 26); // b, c
        return self.s1 + y;
    }
}

// File: contracts/library/data/EnumerableSetAddress.sol

/**
 * @title EnumerableSetAddress
 * @dev Library containing logic for an enumerable set of address values -- supports checking for presence, adding,
 * removing elements, and enumerating elements (without preserving order between mutable operations).
 */
library EnumerableSetAddress {

    struct Data {
        address[] elements;
        mapping(address => uint160) elementToIndex;
    }

    /**
     * @dev Returns whether the set contains a given element
     *
     * @param self Data storage Reference to set data
     * @param value address Value being checked for existence
     * @return bool
     */
    function contains(Data storage self, address value) external view returns (bool) {
        uint160 mappingIndex = self.elementToIndex[value];
        return (mappingIndex < self.elements.length) && (self.elements[mappingIndex] == value);
    }

    /**
     * @dev Adds a new element to the set.  Element must not belong to set yet.
     *
     * @param self Data storage Reference to set data
     * @param value address Value being added
     */
    function add(Data storage self, address value) external {
        uint160 mappingIndex = self.elementToIndex[value];
        require(!((mappingIndex < self.elements.length) && (self.elements[mappingIndex] == value)));

        self.elementToIndex[value] = uint160(self.elements.length);
        self.elements.push(value);
    }

    /**
     * @dev Removes an element from the set.  Element must already belong to set.
     *
     * @param self Data storage Reference to set data
     * @param value address Value being removed
     */
    function remove(Data storage self, address value) external {
        uint160 currentElementIndex = self.elementToIndex[value];
        require((currentElementIndex < self.elements.length) && (self.elements[currentElementIndex] == value));

        uint160 lastElementIndex = uint160(self.elements.length - 1);
        address lastElement = self.elements[lastElementIndex];

        self.elements[currentElementIndex] = lastElement;
        self.elements[lastElementIndex] = 0;
        self.elements.length--;

        self.elementToIndex[lastElement] = currentElementIndex;
        self.elementToIndex[value] = 0;
    }

    /**
     * @dev Gets the number of elements on the set.
     *
     * @param self Data storage Reference to set data
     * @return uint160
     */
    function size(Data storage self) external view returns (uint160) {
        return uint160(self.elements.length);
    }

    /**
     * @dev Gets the N-th element from the set, 0-indexed.  Note that the ordering is not necessarily consistent
     * before and after add, remove operations.
     *
     * @param self Data storage Reference to set data
     * @param index uint160 0-indexed position of the element being queried
     * @return address
     */
    function get(Data storage self, uint160 index) external view returns (address) {
        return self.elements[index];
    }

    /**
     * @dev Mark the set as empty (not containing any further elements).
     *
     * @param self Data storage Reference to set data
     */
    function clear(Data storage self) external {
        self.elements.length = 0;
    }

    /**
     * @dev Copy all data from a source set to a target set
     *
     * @param source Data storage Reference to source data
     * @param target Data storage Reference to target data
     */
    function copy(Data storage source, Data storage target) external {
        uint160 numElements = uint160(source.elements.length);

        target.elements.length = numElements;
        for (uint160 index = 0; index < numElements; index++) {
            address element = source.elements[index];
            target.elements[index] = element;
            target.elementToIndex[element] = index;
        }
    }

    /**
     * @dev Adds all elements from another set into this set, if they are not already present
     *
     * @param self Data storage Reference to set being edited
     * @param other Data storage Reference to set items are being added from
     */
    function addAll(Data storage self, Data storage other) external {
        uint160 numElements = uint160(other.elements.length);

        for (uint160 index = 0; index < numElements; index++) {
            address value = other.elements[index];

            uint160 mappingIndex = self.elementToIndex[value];
            if (!((mappingIndex < self.elements.length) && (self.elements[mappingIndex] == value))) {
                self.elementToIndex[value] = uint160(self.elements.length);
                self.elements.push(value);
            }
        }
    }

}

// File: contracts/library/data/EnumerableSet256.sol

/**
 * @title EnumerableSet256
 * @dev Library containing logic for an enumerable set of uint256 values -- supports checking for presence, adding,
 * removing elements, and enumerating elements (without preserving order between mutable operations).
 */
library EnumerableSet256 {

    struct Data {
        uint256[] elements;
        mapping(uint256 => uint256) elementToIndex;
    }

    /**
     * @dev Returns whether the set contains a given element
     *
     * @param self Data storage Reference to set data
     * @param value uint256 Value being checked for existence
     * @return bool
     */
    function contains(Data storage self, uint256 value) external view returns (bool) {
        uint256 mappingIndex = self.elementToIndex[value];
        return (mappingIndex < self.elements.length) && (self.elements[mappingIndex] == value);
    }

    /**
     * @dev Adds a new element to the set.  Element must not belong to set yet.
     *
     * @param self Data storage Reference to set data
     * @param value uint256 Value being added
     */
    function add(Data storage self, uint256 value) external {
        uint256 mappingIndex = self.elementToIndex[value];
        require(!((mappingIndex < self.elements.length) && (self.elements[mappingIndex] == value)));

        self.elementToIndex[value] = uint256(self.elements.length);
        self.elements.push(value);
    }

    /**
     * @dev Removes an element from the set.  Element must already belong to set yet.
     *
     * @param self Data storage Reference to set data
     * @param value uint256 Value being added
     */
    function remove(Data storage self, uint256 value) external {
        uint256 currentElementIndex = self.elementToIndex[value];
        require((currentElementIndex < self.elements.length) && (self.elements[currentElementIndex] == value));

        uint256 lastElementIndex = uint256(self.elements.length - 1);
        uint256 lastElement = self.elements[lastElementIndex];

        self.elements[currentElementIndex] = lastElement;
        self.elements[lastElementIndex] = 0;
        self.elements.length--;

        self.elementToIndex[lastElement] = currentElementIndex;
        self.elementToIndex[value] = 0;
    }

    /**
     * @dev Gets the number of elements on the set.
     *
     * @param self Data storage Reference to set data
     * @return uint256
     */
    function size(Data storage self) external view returns (uint256) {
        return uint256(self.elements.length);
    }

    /**
     * @dev Gets the N-th element from the set, 0-indexed.  Note that the ordering is not necessarily consistent
     * before and after add, remove operations.
     *
     * @param self Data storage Reference to set data
     * @param index uint256 0-indexed position of the element being queried
     * @return uint256
     */
    function get(Data storage self, uint256 index) external view returns (uint256) {
        return self.elements[index];
    }

    /**
     * @dev Mark the set as empty (not containing any further elements).
     *
     * @param self Data storage Reference to set data
     */
    function clear(Data storage self) external {
        self.elements.length = 0;
    }
}

// File: contracts/library/data/URIDistribution.sol

/**
 * @title URIDistribution
 * @dev Library responsible for maintaining a weighted distribution of URIs
 */
library URIDistribution {

    struct Data {
        uint16[] cumulativeWeights;
        mapping(uint16 => string) uris;
    }

    /**
     * @dev Adds a URI to the distribution, with a given weight
     *
     * @param self Data storage Distribution data reference
     * @param weight uint16 Relative distribution weight
     * @param uri string URI to be stored
     */
    function addURI(Data storage self, uint16 weight, string uri) external {
        if (weight == 0) return;

        if (self.cumulativeWeights.length == 0) {
            self.cumulativeWeights.push(weight);
        } else {
            self.cumulativeWeights.push(self.cumulativeWeights[uint16(self.cumulativeWeights.length - 1)] + weight);
        }
        self.uris[uint16(self.cumulativeWeights.length - 1)] = uri;
    }

    /**
     * @dev Gets an URI from the distribution, with the given random seed
     *
     * @param self Data storage Distribution data reference
     * @param seed uint64
     * @return string
     */
    function getURI(Data storage self, uint64 seed) external view returns (string) {
        uint16 n = uint16(self.cumulativeWeights.length);
        uint16 modSeed = uint16(seed % uint64(self.cumulativeWeights[n - 1]));

        uint16 left = 0;
        uint16 right = n;
        uint16 mid;

        while (left < right) {
            mid = uint16((uint24(left) + uint24(right)) / 2);
            if (self.cumulativeWeights[mid] <= modSeed) {
                left = mid + 1;
            } else {
                right = mid;
            }
        }
        return self.uris[left];
    }
}

// File: contracts/library/game/GameDataLib.sol

/**
 * @title GameDataLib
 *
 * Library containing data structures and logic for game entities.
 */
library GameDataLib {

    /** Data structures */

    struct Butterfly {
        // data encoding butterfly appearance
        uint64 gene;

        // time this butterfly was created
        uint64 createdTimestamp;

        // last time this butterfly changed owner
        uint64 lastTimestamp;

        // set of owners, current and former
        EnumerableSetAddress.Data previousAddresses;
    }

    struct Heart {
        // ID of butterfly that generated this heart
        uint256 butterflyId;

        // time this heart was generated
        uint64 snapshotTimestamp;

        // set of owners, current and former, at time heart was generated
        EnumerableSetAddress.Data previousAddresses;
    }

    struct Flower {
        // Whether this address has ever claimed a butterfly
        bool isClaimed;

        // Data encoding flower appearance
        uint64 gene;

        // Data encoding the garden's timezone
        uint64 gardenTimezone;

        // Data encoding the creation timestamp
        uint64 createdTimestamp;

        // index of the flower registration
        uint160 flowerIndex;
    }

    struct URIMappingData {
        URIDistribution.Data flowerURIs;
        string whiteFlowerURI;

        URIDistribution.Data butterflyLiveURIs;
        URIDistribution.Data butterflyDeadURIs;
        URIDistribution.Data heartURIs;
    }

    // possible types of NFT
    enum TokenType {
        Butterfly,
        Heart
    }

    struct Data {
        // global pseudo-randomization seed
        PRNG.Data seed;

        // next ID available for token generation
        uint256 nextId;

        // token type data
        mapping (uint256 => TokenType) tokenToType;
        mapping (uint8 => mapping (address => EnumerableSet256.Data)) typedOwnedTokens;
        mapping (uint8 => EnumerableSet256.Data) typedTokens;

        // token data
        mapping (uint256 => Butterfly) butterflyData;
        mapping (uint256 => Heart) heartData;

        // owner data
        mapping (address => Flower) flowerData;
        address[] claimedFlowers;

        // URI mapping data
        URIMappingData uriMappingData;
    }

    /** Viewer methods */

    /**
     * @dev Gets game information associated with a specific butterfly.
     * Requires ID to be a valid butterfly.
     *
     * @param self Data storage Reference to game data
     * @param butterflyId uint256 ID of butterfly being queried
     *
     * @return gene uint64
     * @return createdTimestamp uint64
     * @return lastTimestamp uint64
     * @return numOwners uint160
     */
    function getButterflyInfo(
        Data storage self,
        uint256 butterflyId
    ) external view returns (
        uint64 gene,
        uint64 createdTimestamp,
        uint64 lastTimestamp,
        uint160 numOwners
    ) {
        Butterfly storage butterfly = self.butterflyData[butterflyId];
        require(butterfly.createdTimestamp != 0);

        gene = butterfly.gene;
        createdTimestamp = butterfly.createdTimestamp;
        lastTimestamp = butterfly.lastTimestamp;
        numOwners = uint160(butterfly.previousAddresses.elements.length);
    }

    /**
     * @dev Gets game information associated with a specific heart.
     * Requires ID to be a valid heart.
     *
     * @param self Data storage Reference to game data
     * @param heartId uint256 ID of heart being queried
     *
     * @return butterflyId uint256
     * @return gene uint64
     * @return snapshotTimestamp uint64
     * @return numOwners uint160
     */
    function getHeartInfo(
        Data storage self,
        uint256 heartId
    ) external view returns (
        uint256 butterflyId,
        uint64 gene,
        uint64 snapshotTimestamp,
        uint160 numOwners
    ) {
        Heart storage heart = self.heartData[heartId];
        require(heart.snapshotTimestamp != 0);

        butterflyId = heart.butterflyId;
        gene = self.butterflyData[butterflyId].gene;
        snapshotTimestamp = heart.snapshotTimestamp;
        numOwners = uint160(heart.previousAddresses.elements.length);
    }

    /**
     * @dev Gets game information associated with a specific flower.
     *
     * @param self Data storage Reference to game data
     * @param flowerAddress address Address of the flower being queried
     *
     * @return isClaimed bool
     * @return gene uint64
     * @return gardenTimezone uint64
     * @return createdTimestamp uint64
     * @return flowerIndex uint160
     */
    function getFlowerInfo(
        Data storage self,
        address flowerAddress
    ) external view returns (
        bool isClaimed,
        uint64 gene,
        uint64 gardenTimezone,
        uint64 createdTimestamp,
        uint160 flowerIndex
    ) {
        Flower storage flower = self.flowerData[flowerAddress];

        isClaimed = flower.isClaimed;
        if (isClaimed) {
            gene = flower.gene;
            gardenTimezone = flower.gardenTimezone;
            createdTimestamp = flower.createdTimestamp;
            flowerIndex = flower.flowerIndex;
        }
    }

    /**
     * @dev Returns the N-th owner associated with a butterfly.
     * Requires ID to be a valid butterfly, and owner index to be smaller than the number of owners.
     *
     * @param self Data storage Reference to game data
     * @param butterflyId uint256 ID of butterfly being queried
     * @param index uint160 Index of owner being queried
     *
     * @return address
     */
    function getButterflyOwnerByIndex(
        Data storage self,
        uint256 butterflyId,
        uint160 index
    ) external view returns (address) {
        Butterfly storage butterfly = self.butterflyData[butterflyId];
        require(butterfly.createdTimestamp != 0);

        return butterfly.previousAddresses.elements[index];
    }

    /**
     * @dev Returns the N-th owner associated with a heart's snapshot.
     * Requires ID to be a valid butterfly, and owner index to be smaller than the number of owners.
     *
     * @param self Data storage Reference to game data
     * @param heartId uint256 ID of heart being queried
     * @param index uint160 Index of owner being queried
     *
     * @return address
     */
    function getHeartOwnerByIndex(
        Data storage self,
        uint256 heartId,
        uint160 index
    ) external view returns (address) {
        Heart storage heart = self.heartData[heartId];
        require(heart.snapshotTimestamp != 0);

        return heart.previousAddresses.elements[index];
    }

    /**
     * @dev Determines whether the game logic allows a transfer of a butterfly to another address.
     * Conditions:
     * - The receiver address must have already claimed a butterfly
     * - The butterfly's last timestamp is within the last 24 hours
     * - The receiver address must have never claimed *this* butterfly
     * OR
     * - The receiver is 0x0
     *
     * @param self Data storage Reference to game data
     * @param butterflyId uint256 ID of butterfly being queried
     * @param receiver address Address of potential receiver
     * @param currentTimestamp uint64
     */
    function canReceiveButterfly(
        Data storage self,
        uint256 butterflyId,
        address receiver,
        uint64 currentTimestamp
    ) public view returns (bool) {
        Butterfly storage butterfly = self.butterflyData[butterflyId];

        // butterfly must exist
        if (butterfly.createdTimestamp == 0)
            return false;

        // can always transfer to 0 (destroying it)
        if (receiver == address(0x0))
            return true;

        // butterfly must have been last updated on the last day
        if (currentTimestamp < butterfly.lastTimestamp || currentTimestamp - butterfly.lastTimestamp > 1 days)
            return false;

        // receiver must have already claimed
        Flower storage flower = self.flowerData[receiver];
        if (!flower.isClaimed) return false;

        // receiver must have never owned this butterfly
        return !EnumerableSetAddress.contains(butterfly.previousAddresses, receiver);
    }


    /** Editor methods */

    /**
     * @dev Claims a flower and an initial butterfly for a given address.
     * Requires address to have not claimed previously
     *
     * @param self Data storage Reference to game data
     * @param claimer address Address making the claim
     * @param gardenTimezone uint64
     * @param currentTimestamp uint64
     *
     * @return butterflyId uint256 ID for the new butterfly
     */
    function claim(
        Data storage self,
        address claimer,
        uint64 gardenTimezone,
        uint64 currentTimestamp
    ) external returns (uint256 butterflyId) {
        Flower storage flower = self.flowerData[claimer];

        // require address has not claimed before
        require(!flower.isClaimed);
        // assert no overflow on IDs
        require(self.nextId + 1 != 0);

        // get butterfly ID
        butterflyId = self.nextId;
        // assert ID is not being reused
        Butterfly storage butterfly = self.butterflyData[butterflyId];
        require(butterfly.createdTimestamp == 0);
        // update counter
        self.nextId++;

        // update flower data
        flower.isClaimed = true;
        flower.gardenTimezone = gardenTimezone;
        flower.createdTimestamp = currentTimestamp;
        flower.gene = PRNG.next(self.seed);
        flower.flowerIndex = uint160(self.claimedFlowers.length);

        // update butterfly data
        butterfly.gene = PRNG.next(self.seed);
        butterfly.createdTimestamp = currentTimestamp;
        butterfly.lastTimestamp = currentTimestamp;
        EnumerableSetAddress.add(butterfly.previousAddresses, claimer);

        // update butterfly token data
        self.tokenToType[butterflyId] = TokenType.Butterfly;

        // register butterfly token
        EnumerableSet256.add(self.typedOwnedTokens[uint8(TokenType.Butterfly)][claimer], butterflyId);
        EnumerableSet256.add(self.typedTokens[uint8(TokenType.Butterfly)], butterflyId);

        // register address
        self.claimedFlowers.push(claimer);
    }

    /**
     * @dev Logs a transfer of a butterfly between two addresses, leaving a heart behind.
     *
     * Conditions:
     * - The receiver address must have already claimed a butterfly
     * - The butterfly's last timestamp is within the last 24 hours
     *
     * @param self Data storage Reference to game data
     * @param butterflyId uint256 ID of butterfly being queried
     * @param sender Address of sender
     * @param receiver address Address of potential receiver
     * @param currentTimestamp uint64
     *
     * @return heartId uint256 ID for the new heart
     */
    function transferButterfly(
        Data storage self,
        uint256 butterflyId,
        address sender,
        address receiver,
        uint64 currentTimestamp
    ) external returns (uint256 heartId) {
        // require transfer conditions to be satisfied
        require(canReceiveButterfly(self, butterflyId, receiver, currentTimestamp));

        // require no overflow on IDs
        require(self.nextId + 1 != 0);
        // get heart ID
        heartId = self.nextId;
        // assert ID is not being reused
        Heart storage heart = self.heartData[heartId];
        require(heart.snapshotTimestamp == 0);
        // update counter
        self.nextId++;

        // update heart data
        heart.butterflyId = butterflyId;
        heart.snapshotTimestamp = currentTimestamp;
        Butterfly storage butterfly = self.butterflyData[butterflyId];

        // update heart token heartId
        self.tokenToType[heartId] = TokenType.Heart;

        // update butterfly data
        butterfly.lastTimestamp = currentTimestamp;
        EnumerableSetAddress.add(butterfly.previousAddresses, receiver);

        // update heart addresses
        EnumerableSetAddress.copy(butterfly.previousAddresses, heart.previousAddresses);

        // update butterfly register
        EnumerableSet256.remove(self.typedOwnedTokens[uint8(TokenType.Butterfly)][sender], butterflyId);
        EnumerableSet256.add(self.typedOwnedTokens[uint8(TokenType.Butterfly)][receiver], butterflyId);

        // update heart register
        EnumerableSet256.add(self.typedOwnedTokens[uint8(TokenType.Heart)][sender], heartId);
        EnumerableSet256.add(self.typedTokens[uint8(TokenType.Heart)], heartId);
    }

    /**
     * @dev Logs a transfer of a heart between two addresses
     *
     * @param self Data storage Reference to game data
     * @param heartId uint256 ID of heart being queried
     * @param sender Address of sender
     * @param receiver address Address of potential receiver
     */
    function transferHeart(
        Data storage self,
        uint256 heartId,
        address sender,
        address receiver
    ) external {
        // update heart register
        EnumerableSet256.remove(self.typedOwnedTokens[uint8(TokenType.Heart)][sender], heartId);
        EnumerableSet256.add(self.typedOwnedTokens[uint8(TokenType.Heart)][receiver], heartId);
    }

    /**
     * @dev Returns the total number of tokens for a given type, owned by a specific address
     *
     * @param self Data storage Reference to game data
     * @param tokenType uint8
     * @param _owner address
     *
     * @return uint256
     */
    function typedBalanceOf(Data storage self, uint8 tokenType, address _owner) public view returns (uint256) {
        return self.typedOwnedTokens[tokenType][_owner].elements.length;
    }

    /**
     * @dev Returns the total number of tokens for a given type
     *
     * @param self Data storage Reference to game data
     * @param tokenType uint8
     *
     * @return uint256
     */
    function typedTotalSupply(Data storage self, uint8 tokenType) public view returns (uint256) {
        return self.typedTokens[tokenType].elements.length;
    }


    /**
     * @dev Returns the I-th token of a specific type owned by an index
     *
     * @param self Data storage Reference to game data
     * @param tokenType uint8
     * @param _owner address
     * @param _index uint256
     *
     * @return uint256
     */
    function typedTokenOfOwnerByIndex(
        Data storage self,
        uint8 tokenType,
        address _owner,
        uint256 _index
    ) external view returns (uint256) {
        return self.typedOwnedTokens[tokenType][_owner].elements[_index];
    }

    /**
     * @dev Returns the I-th token of a specific type
     *
     * @param self Data storage Reference to game data
     * @param tokenType uint8
     * @param _index uint256
     *
     * @return uint256
     */
    function typedTokenByIndex(
        Data storage self,
        uint8 tokenType,
        uint256 _index
    ) external view returns (uint256) {
        return self.typedTokens[tokenType].elements[_index];
    }

    /**
     * @dev Gets the total number of claimed flowers
     *
     * @param self Data storage Reference to game data
     * @return uint160
     */
    function totalFlowers(Data storage self) external view returns (uint160) {
        return uint160(self.claimedFlowers.length);
    }

    /**
     * @dev Gets the address of the N-th flower
     *
     * @param self Data storage Reference to game data
     * @return address
     */
    function getFlowerByIndex(Data storage self, uint160 index) external view returns (address) {
        return self.claimedFlowers[index];
    }

    /** Admin methods **/

    /**
     * @dev Registers a new flower URI with the corresponding weight
     *
     * @param self Data storage Reference to game data
     * @param weight uint16 Relative weight for the occurrence of this URI
     * @param uri string
     */
    function addFlowerURI(Data storage self, uint16 weight, string uri) external {
        URIDistribution.addURI(self.uriMappingData.flowerURIs, weight, uri);
    }

    /**
     * @dev Registers the flower URI for address 0
     *
     * @param self Data storage Reference to game data
     * @param uri string
     */
    function setWhiteFlowerURI(Data storage self, string uri) external {
        self.uriMappingData.whiteFlowerURI = uri;
    }

    /**
     * @dev Gets the flower URI for address 0
     *
     * @param self Data storage Reference to game data
     * @return string
     */
    function getWhiteFlowerURI(Data storage self) external view returns (string) {
        return self.uriMappingData.whiteFlowerURI;
    }

    /**
     * @dev Registers a new butterfly URI with the corresponding weight
     *
     * @param self Data storage Reference to game data
     * @param weight uint16 Relative weight for the occurrence of this URI
     * @param liveUri string
     * @param deadUri string
     * @param heartUri string
     */
    function addButterflyURI(Data storage self, uint16 weight, string liveUri, string deadUri, string heartUri) external {
        URIDistribution.addURI(self.uriMappingData.butterflyLiveURIs, weight, liveUri);
        URIDistribution.addURI(self.uriMappingData.butterflyDeadURIs, weight, deadUri);
        URIDistribution.addURI(self.uriMappingData.heartURIs, weight, heartUri);
    }

    /**
     * @dev Returns the URI mapped to a particular flower.
     * Requires flower to be claimed / exist.
     *
     * @param self Data storage Reference to game data
     * @param flowerAddress address Flower being queried
     * @return string
     */
    function getFlowerURI(Data storage self, address flowerAddress) external view returns (string) {
        Flower storage flower = self.flowerData[flowerAddress];
        require(flower.isClaimed);
        return URIDistribution.getURI(self.uriMappingData.flowerURIs, flower.gene);
    }

    /**
     * @dev Returns the URI mapped to a particular butterfly -- selecting the URI for it being alive
     * or dead based on the current timestamp.
     * Requires butterfly to exist.
     *
     * @param self Data storage Reference to game data
     * @param erc721Data ERC721Manager.ERC721Data storage Reference to ownership data
     * @param butterflyId uint256 ID of the butterfly being queried
     * @param currentTimestamp uint64
     * @return string
     */
    function getButterflyURI(
        Data storage self,
        ERC721Manager.ERC721Data storage erc721Data,
        uint256 butterflyId,
        uint64 currentTimestamp
    ) external view returns (string) {
        Butterfly storage butterfly = self.butterflyData[butterflyId];
        require(butterfly.createdTimestamp != 0);

        if (erc721Data.tokenOwner[butterflyId] == 0
            || currentTimestamp < butterfly.lastTimestamp
            || currentTimestamp - butterfly.lastTimestamp > 1 days) {
            return URIDistribution.getURI(self.uriMappingData.butterflyDeadURIs, butterfly.gene);
        }
        return URIDistribution.getURI(self.uriMappingData.butterflyLiveURIs, butterfly.gene);
    }

    /**
     * @dev Returns the URI for a particular butterfly gene -- useful for seeing the butterfly "as it was"
     * when it dropped a heart
     *
     * @param self Daata storage Reference to game data
     * @param gene uint64
     * @param isAlive bool
     * @return string
     */
    function getButterflyURIFromGene(
        Data storage self,
        uint64 gene,
        bool isAlive
    ) external view returns (string) {
        if (isAlive) {
            return URIDistribution.getURI(self.uriMappingData.butterflyLiveURIs, gene);
        }
        return URIDistribution.getURI(self.uriMappingData.butterflyDeadURIs, gene);
    }

    /**
     * @dev Returns the URI mapped to hearts
     *
     * @param self Data storage Reference to game data
     * @param heartId uint256 ID of heart being queried
     * @return string
     */
    function getHeartURI(Data storage self, uint256 heartId) external view returns (string) {
        Heart storage heart = self.heartData[heartId];
        require(heart.snapshotTimestamp != 0);

        uint64 gene = self.butterflyData[heart.butterflyId].gene;
        return URIDistribution.getURI(self.uriMappingData.heartURIs, gene);
    }

}

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

// File: contracts\game\Main.sol

/**
 * @title Main
 *
 * Main contract for LittleButterflies.  Implements the ERC721 EIP for Non-Fungible Tokens.
 */
contract Main is ERC721Token, Ownable {

    GameDataLib.Data internal data;

    // Set our token name and symbol
    constructor() ERC721Token("LittleButterfly", "BFLY") public {
        // initialize PRNG values
        data.seed.s0 = uint64(now);
        data.seed.s1 = uint64(msg.sender);
    }


    /** Token viewer methods **/


    /**
     * @dev Gets game information associated with a specific butterfly.
     * Requires ID to be a valid butterfly.
     *
     * @param butterflyId uint256 ID of butterfly being queried
     *
     * @return gene uint64
     * @return createdTimestamp uint64
     * @return lastTimestamp uint64
     * @return numOwners uint160
     */
    function getButterflyInfo(uint256 butterflyId) public view returns (
        uint64 gene,
        uint64 createdTimestamp,
        uint64 lastTimestamp,
        uint160 numOwners
    ) {
       (gene, createdTimestamp, lastTimestamp, numOwners) = GameDataLib.getButterflyInfo(data, butterflyId);
    }

    /**
     * @dev Returns the N-th owner associated with a butterfly.
     * Requires ID to be a valid butterfly, and owner index to be smaller than the number of owners.
     *
     * @param butterflyId uint256 ID of butterfly being queried
     * @param index uint160 Index of owner being queried
     *
     * @return address
     */
    function getButterflyOwnerByIndex(
        uint256 butterflyId,
        uint160 index
    ) external view returns (address) {
        return GameDataLib.getButterflyOwnerByIndex(data, butterflyId, index);
    }


    /**
     * @dev Gets game information associated with a specific heart.
     * Requires ID to be a valid heart.
     *
     * @param heartId uint256 ID of heart being queried
     *
     * @return butterflyId uint256
     * @return gene uint64
     * @return snapshotTimestamp uint64
     * @return numOwners uint160
     */
    function getHeartInfo(uint256 heartId) public view returns (
        uint256 butterflyId,
        uint64 gene,
        uint64 snapshotTimestamp,
        uint160 numOwners
    ) {
        (butterflyId, gene, snapshotTimestamp, numOwners) = GameDataLib.getHeartInfo(data, heartId);
    }

    /**
     * @dev Returns the N-th owner associated with a heart's snapshot.
     * Requires ID to be a valid butterfly, and owner index to be smaller than the number of owners.
     *
     * @param heartId uint256 ID of heart being queried
     * @param index uint160 Index of owner being queried
     *
     * @return address
     */
    function getHeartOwnerByIndex(
        uint256 heartId,
        uint160 index
    ) external view returns (address) {
        return GameDataLib.getHeartOwnerByIndex(data, heartId, index);
    }


    /**
     * @dev Gets game information associated with a specific flower.
     *
     * @param flowerAddress address Address of the flower being queried
     *
     * @return isClaimed bool
     * @return gene uint64
     * @return gardenTimezone uint64
     * @return createdTimestamp uint64
     * @return flowerIndex uint160
     */
    function getFlowerInfo(
        address flowerAddress
    ) external view returns (
        bool isClaimed,
        uint64 gene,
        uint64 gardenTimezone,
        uint64 createdTimestamp,
        uint160 flowerIndex
    ) {
        (isClaimed, gene, gardenTimezone, createdTimestamp, flowerIndex) = GameDataLib.getFlowerInfo(data, flowerAddress);
    }


    /**
     * @dev Determines whether the game logic allows a transfer of a butterfly to another address.
     * Conditions:
     * - The receiver address must have already claimed a butterfly
     * - The butterfly's last timestamp is within the last 24 hours
     * - The receiver address must have never claimed *this* butterfly
     *
     * @param butterflyId uint256 ID of butterfly being queried
     * @param receiver address Address of potential receiver
     */
    function canReceiveButterfly(
        uint256 butterflyId,
        address receiver
    ) external view returns (bool) {
        return GameDataLib.canReceiveButterfly(data, butterflyId, receiver, uint64(now));
    }


    /** Override token methods **/

    /**
     * @dev Override the default ERC721 transferFrom implementation in order to check game conditions and
     * generate side effects
     */
    function transferFrom(address _from, address _to, uint256 _tokenId) public {
        _setupTransferFrom(_from, _to, _tokenId, uint64(now));
        ERC721Manager.transferFrom(erc721Data, _from, _to, _tokenId);
    }

    /**
     * @dev Override the default ERC721 safeTransferFrom implementation in order to check game conditions and
     * generate side effects
     */
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public {
        _setupTransferFrom(_from, _to, _tokenId, uint64(now));
        ERC721Manager.safeTransferFrom(erc721Data, _from, _to, _tokenId);
    }

    /**
     * @dev Override the default ERC721 safeTransferFrom implementation in order to check game conditions and
     * generate side effects
     */
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes _data
    ) public {
        _setupTransferFrom(_from, _to, _tokenId, uint64(now));
        ERC721Manager.safeTransferFrom(erc721Data, _from, _to, _tokenId, _data);
    }


    /**
    * @dev Execute before transfer, preventing token transfer in some circumstances.
    * Requirements:
    *  - Caller is owner, approved, or operator for the token
    *  - To has claimed a token before
    *  - Token is a Heart, or Token's last activity was in the last 24 hours
    *
    * @param from current owner of the token
    * @param to address to receive the ownership of the given token ID
    * @param tokenId uint256 ID of the token to be transferred
    * @param currentTimestamp uint64
    */
    function _setupTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        uint64 currentTimestamp
    ) private {
        if (data.tokenToType[tokenId] == GameDataLib.TokenType.Butterfly) {
            // try to do transfer and mint a heart
            uint256 heartId = GameDataLib.transferButterfly(data, tokenId, from, to, currentTimestamp);
            ERC721Manager.mint(erc721Data, from, heartId);
        } else {
            GameDataLib.transferHeart(data, tokenId, from, to);
        }
    }

    /**
     * @dev Overrides the default tokenURI method to lookup from the stored table of URIs -- rather than
     * storing a copy of the URI for each instance
     *
     * @param _tokenId uint256
     * @return string
     */
    function tokenURI(uint256 _tokenId) public view returns (string) {
        if (data.tokenToType[_tokenId] == GameDataLib.TokenType.Heart) {
            return GameDataLib.getHeartURI(data, _tokenId);
        }
        return GameDataLib.getButterflyURI(data, erc721Data, _tokenId, uint64(now));
    }

    /**
     * @dev Returns the URI mapped to a particular account / flower
     *
     * @param accountAddress address
     * @return string
     */
    function accountURI(address accountAddress) public view returns (string) {
        return GameDataLib.getFlowerURI(data, accountAddress);
    }

    /**
     * @dev Returns the URI mapped to account 0
     *
     * @return string
     */
    function accountZeroURI() public view returns (string) {
        return GameDataLib.getWhiteFlowerURI(data);
    }

    /**
     * @dev Returns the URI for a particular butterfly gene -- useful for seeing the butterfly "as it was"
     * when it dropped a heart
     *
     * @param gene uint64
     * @param isAlive bool
     * @return string
     */
    function getButterflyURIFromGene(uint64 gene, bool isAlive) public view returns (string) {
        return GameDataLib.getButterflyURIFromGene(data, gene, isAlive);
    }


    /** Extra token methods **/

    /**
     * @dev Claims a flower and an initial butterfly for a given address.
     * Requires address to have not claimed previously
     *
     * @param gardenTimezone uint64
     */
    function claim(uint64 gardenTimezone) external {
        address claimer = msg.sender;

        // claim a butterfly
        uint256 butterflyId = GameDataLib.claim(data, claimer, gardenTimezone, uint64(now));

        // mint its token
        ERC721Manager.mint(erc721Data, claimer, butterflyId);
    }

    /**
     * @dev Burns a token.  Caller must be owner or approved.
     *
     * @param _tokenId uint256 ID of token to burn
     */
    function burn(uint256 _tokenId) public {
        require(ERC721Manager.isApprovedOrOwner(erc721Data, msg.sender, _tokenId));

        address _owner = ERC721Manager.ownerOf(erc721Data, _tokenId);

        _setupTransferFrom(_owner, address(0x0), _tokenId, uint64(now));
        ERC721Manager.burn(erc721Data, _owner, _tokenId);
    }



    /**
     * @dev Returns the total number of tokens for a given type, owned by a specific address
     *
     * @param tokenType uint8
     * @param _owner address
     *
     * @return uint256
     */
    function typedBalanceOf(uint8 tokenType, address _owner) public view returns (uint256) {
        return GameDataLib.typedBalanceOf(data, tokenType, _owner);
    }

    /**
     * @dev Returns the total number of tokens for a given type
     *
     * @param tokenType uint8
     *
     * @return uint256
     */
    function typedTotalSupply(uint8 tokenType) public view returns (uint256) {
        return GameDataLib.typedTotalSupply(data, tokenType);
    }


    /**
     * @dev Returns the I-th token of a specific type owned by an index
     *
     * @param tokenType uint8
     * @param _owner address
     * @param _index uint256
     *
     * @return uint256
     */
    function typedTokenOfOwnerByIndex(
        uint8 tokenType,
        address _owner,
        uint256 _index
    ) external view returns (uint256) {
        return GameDataLib.typedTokenOfOwnerByIndex(data, tokenType, _owner, _index);
    }

    /**
     * @dev Returns the I-th token of a specific type
     *
     * @param tokenType uint8
     * @param _index uint256
     *
     * @return uint256
     */
    function typedTokenByIndex(
        uint8 tokenType,
        uint256 _index
    ) external view returns (uint256) {
        return GameDataLib.typedTokenByIndex(data, tokenType, _index);
    }

    /**
     * @dev Gets the total number of claimed flowers
     *
     * @return uint160
     */
    function totalFlowers() external view returns (uint160) {
        return GameDataLib.totalFlowers(data);
    }

    /**
     * @dev Gets the address of the N-th flower
     *
     * @return address
     */
    function getFlowerByIndex(uint160 index) external view returns (address) {
        return GameDataLib.getFlowerByIndex(data, index);
    }


    /** Admin setup methods */

    /*
    * Methods intended for initial contract setup, to be called at deployment.
    * Call renounceOwnership() to make the contract have no owner after setup is complete.
    */

    /**
     * @dev Registers a new flower URI with the corresponding weight
     *
     * @param weight uint16 Relative weight for the occurrence of this URI
     * @param uri string
     */
    function addFlowerURI(uint16 weight, string uri) external onlyOwner {
        GameDataLib.addFlowerURI(data, weight, uri);
    }

    /**
     * @dev Registers the flower URI for address 0
     *
     * @param uri string
     */
    function setWhiteFlowerURI(string uri) external onlyOwner {
        GameDataLib.setWhiteFlowerURI(data, uri);
    }

    /**
     * @dev Registers a new butterfly URI with the corresponding weight
     *
     * @param weight uint16 Relative weight for the occurrence of this URI
     * @param liveUri string
     * @param deadUri string
     * @param heartUri string
     */
    function addButterflyURI(uint16 weight, string liveUri, string deadUri, string heartUri) external onlyOwner {
        GameDataLib.addButterflyURI(data, weight, liveUri, deadUri, heartUri);
    }

}