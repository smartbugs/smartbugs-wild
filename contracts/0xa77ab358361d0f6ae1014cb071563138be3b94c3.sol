pragma solidity ^0.4.24;

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

// File: openzeppelin-solidity/contracts/ownership/HasNoEther.sol

/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <remco@2π.com>
 * @dev This tries to block incoming ether to prevent accidental loss of Ether. Should Ether end up
 * in the contract, it will allow the owner to reclaim this Ether.
 * @notice Ether can still be sent to this contract by:
 * calling functions labeled `payable`
 * `selfdestruct(contract_address)`
 * mining directly to the contract address
 */
contract HasNoEther is Ownable {

  /**
  * @dev Constructor that rejects incoming Ether
  * The `payable` flag is added so we can access `msg.value` without compiler warning. If we
  * leave out payable, then Solidity will allow inheriting contracts to implement a payable
  * constructor. By doing it this way we prevent a payable constructor from working. Alternatively
  * we could use assembly to access msg.value.
  */
  constructor() public payable {
    require(msg.value == 0);
  }

  /**
   * @dev Disallows direct send by setting a default function without the `payable` flag.
   */
  function() external {
  }

  /**
   * @dev Transfer all Ether held by the contract to the owner.
   */
  function reclaimEther() external onlyOwner {
    owner.transfer(address(this).balance);
  }
}

// File: openzeppelin-solidity/contracts/lifecycle/Destructible.sol

/**
 * @title Destructible
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.
 */
contract Destructible is Ownable {
  /**
   * @dev Transfers the current balance to the owner and terminates the contract.
   */
  function destroy() public onlyOwner {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) public onlyOwner {
    selfdestruct(_recipient);
  }
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

// File: contracts/MEHAccessControl.sol

contract MarketInerface {
    function buyBlocks(address, uint16[]) external returns (uint) {}
    function sellBlocks(address, uint, uint16[]) external returns (uint) {}
    function isMarket() public view returns (bool) {}
    function isOnSale(uint16) public view returns (bool) {}
    function areaPrice(uint16[]) public view returns (uint) {}
    function importOldMEBlock(uint8, uint8) external returns (uint, address) {}
}

contract RentalsInterface {
    function rentOutBlocks(address, uint, uint16[]) external returns (uint) {}
    function rentBlocks(address, uint, uint16[]) external returns (uint) {}
    function blocksRentPrice(uint, uint16[]) external view returns (uint) {}
    function isRentals() public view returns (bool) {}
    function isRented(uint16) public view returns (bool) {}
    function renterOf(uint16) public view returns (address) {}
}

contract AdsInterface {
    function advertiseOnBlocks(address, uint16[], string, string, string) external returns (uint) {}
    function canAdvertiseOnBlocks(address, uint16[]) public view returns (bool) {}
    function isAds() public view returns (bool) {}
}

/// @title MEHAccessControl: Part of MEH contract responsible for communication with external modules:
///  Market, Rentals, Ads contracts. Provides authorization and upgradability methods.
contract MEHAccessControl is Pausable {

    // Allows a module being plugged in to verify it is MEH contract. 
    bool public isMEH = true;

    // Modules
    MarketInerface public market;
    RentalsInterface public rentals;
    AdsInterface public ads;

    // Emitted when a module is plugged.
    event LogModuleUpgrade(address newAddress, string moduleName);
    
// GUARDS
    
    /// @dev Functions allowed to market module only. 
    modifier onlyMarket() {
        require(msg.sender == address(market));
        _;
    }

    /// @dev Functions allowed to balance operators only (market and rentals contracts are the 
    ///  only balance operators)
    modifier onlyBalanceOperators() {
        require(msg.sender == address(market) || msg.sender == address(rentals));
        _;
    }

// ** Admin set Access ** //
    /// @dev Allows admin to plug a new Market contract in.
    // credits to cryptokittes! - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
    // NOTE: verify that a contract is what we expect
    function adminSetMarket(address _address) external onlyOwner {
        MarketInerface candidateContract = MarketInerface(_address);
        require(candidateContract.isMarket());
        market = candidateContract;
        emit LogModuleUpgrade(_address, "Market");
    }

    /// @dev Allows admin to plug a new Rentals contract in.
    function adminSetRentals(address _address) external onlyOwner {
        RentalsInterface candidateContract = RentalsInterface(_address);
        require(candidateContract.isRentals());
        rentals = candidateContract;
        emit LogModuleUpgrade(_address, "Rentals");
    }

    /// @dev Allows admin to plug a new Ads contract in.
    function adminSetAds(address _address) external onlyOwner {
        AdsInterface candidateContract = AdsInterface(_address);
        require(candidateContract.isAds());
        ads = candidateContract;
        emit LogModuleUpgrade(_address, "Ads");
    }
}

// File: contracts/MehERC721.sol

// ERC721 



/// @title MehERC721: Part of MEH contract responsible for ERC721 token management. Openzeppelin's
///  ERC721 implementation modified for the Million Ether Homepage. 
contract MehERC721 is ERC721Token("MillionEtherHomePage","MEH"), MEHAccessControl {

    /// @dev Checks rights to transfer block ownership. Locks tokens on sale.
    ///  Overrides OpenZEppelin's isApprovedOrOwner function - so that tokens marked for sale can 
    ///  be transferred by Market contract only.
    function isApprovedOrOwner(
        address _spender,
        uint256 _tokenId
    )
        internal
        view
        returns (bool)
    {   
        bool onSale = market.isOnSale(uint16(_tokenId));

        address owner = ownerOf(_tokenId);
        bool spenderIsApprovedOrOwner =
            _spender == owner ||
            getApproved(_tokenId) == _spender ||
            isApprovedForAll(owner, _spender);

        return (
            (onSale && _spender == address(market)) ||
            (!(onSale) && spenderIsApprovedOrOwner)
        );
    }

    /// @dev mints a new block.
    ///  overrides _mint function to add pause/unpause functionality, onlyMarket access,
    ///  restricts totalSupply of blocks to 10000 (as there is only a 100x100 blocks field).
    function _mintCrowdsaleBlock(address _to, uint16 _blockId) external onlyMarket whenNotPaused {
        if (totalSupply() <= 9999) {
        _mint(_to, uint256(_blockId));
        }
    }

    /// @dev overrides approve function to add pause/unpause functionality
    function approve(address _to, uint256 _tokenId) public whenNotPaused {
        super.approve(_to, _tokenId);
    }
 
    /// @dev overrides setApprovalForAll function to add pause/unpause functionality
    function setApprovalForAll(address _to, bool _approved) public whenNotPaused {
        super.setApprovalForAll(_to, _approved);
    }    

    /// @dev overrides transferFrom function to add pause/unpause functionality
    ///  affects safeTransferFrom functions as well
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        public
        whenNotPaused
    {
        super.transferFrom(_from, _to, _tokenId);
    }
}

// File: contracts/Accounting.sol

// import "../installed_contracts/math.sol";



// @title Accounting: Part of MEH contract responsible for eth accounting.
contract Accounting is MEHAccessControl {
    using SafeMath for uint256;

    // Balances of users, admin, charity
    mapping(address => uint256) public balances;

    // Emitted when a user deposits or withdraws funds from the contract
    event LogContractBalance(address payerOrPayee, int balanceChange);

// ** PAYMENT PROCESSING ** //
    
    /// @dev Withdraws users available balance.
    function withdraw() external whenNotPaused {
        address payee = msg.sender;
        uint256 payment = balances[payee];

        require(payment != 0);
        assert(address(this).balance >= payment);

        balances[payee] = 0;

        // reentrancy safe
        payee.transfer(payment);
        emit LogContractBalance(payee, int256(-payment));
    }

    /// @dev Lets external authorized contract (operators) to transfer balances within MEH contract.
    ///  MEH contract doesn't transfer funds on its own. Instead Market and Rentals contracts
    ///  are granted operator access.
    function operatorTransferFunds(
        address _payer, 
        address _recipient, 
        uint _amount) 
    external 
    onlyBalanceOperators
    whenNotPaused
    {
        require(balances[_payer] >= _amount);
        _deductFrom(_payer, _amount);
        _depositTo(_recipient, _amount);
    }

    /// @dev Deposits eth to msg.sender balance.
    function depositFunds() internal whenNotPaused {
        _depositTo(msg.sender, msg.value);
        emit LogContractBalance(msg.sender, int256(msg.value));
    }

    /// @dev Increases recipients internal balance.
    function _depositTo(address _recipient, uint _amount) internal {
        balances[_recipient] = balances[_recipient].add(_amount);
    }

    /// @dev Increases payers internal balance.
    function _deductFrom(address _payer, uint _amount) internal {
        balances[_payer] = balances[_payer].sub(_amount);
    }

// ** ADMIN ** //

    /// @notice Allows admin to withdraw contract balance in emergency. And distribute manualy
    ///  aftrewards.
    /// @dev As the contract is not designed to keep users funds (users can withdraw
    ///  at anytime) it should be relatively easy to manualy transfer unclaimed funds to 
    ///  their owners. This is an alternatinve to selfdestruct allowing blocks ledger (ERC721 tokens)
    ///  to be immutable.
    function adminRescueFunds() external onlyOwner whenPaused {
        address payee = owner;
        uint256 payment = address(this).balance;
        payee.transfer(payment);
    }

    /// @dev Checks if a msg.sender has enough balance to pay the price _needed.
    function canPay(uint _needed) internal view returns (bool) {
        return (msg.value.add(balances[msg.sender]) >= _needed);
    }
}

// File: contracts/MEH.sol

/*
MillionEther smart contract - decentralized advertising platform.

This program is free software: you can redistribute it and/or modifromY
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
* A 1000x1000 pixel field is displayed at TheMillionEtherHomepage.com. 
* This smart contract lets anyone buy 10x10 pixel blocks and place ads there.
* It also allows to sell blocks and rent them out to other advertisers. 
*
* 10x10 pixels blocks are addressed by xy coordinates. So 1000x1000 pixel field is 100 by 100 blocks.
* Making up 10 000 blocks in total. Each block is an ERC721 (non fungible token) token. 
*
* At the initial sale the price for each block is $1 (price is feeded by an oracle). After
* every 1000 blocks sold (every 10%) the price doubles. Owners can sell and rent out blocks at any
* price they want. Owners and renters can place and replace ads to their blocks as many times they 
* want.
*
* All heavy logic is delegated to external upgradable contracts. There are 4 main modules (contracts):
*     - MEH: Million Ether Homepage (MEH) contract. Provides user interface and accounting 
*         functionality. It is immutable and it keeps Non fungible ERC721 tokens (10x10 pixel blocks) 
*         ledger and eth balances. 
*     - Market: Plugable. Provides methods for buy-sell functionality, keeps buy-sell ledger, 
*         querries oracle for a ETH-USD price, 
*     - Rentals: Plugable. Provides methods for rentout-rent functionality, keeps rentout-rent ledger.
*     - Ads: Plugable. Provides methods for image placement functionality.
* 
*/

/// @title MEH: Million Ether Homepage. Buy, sell, rent out pixels and place ads.
/// @author Peter Porobov (https://keybase.io/peterporobov)
/// @notice The main contract, accounting and user interface. Immutable.
contract MEH is MehERC721, Accounting {

    /// @notice emited when an area blocks is bought
    event LogBuys(
        uint ID,
        uint8 fromX,
        uint8 fromY,
        uint8 toX,
        uint8 toY,
        address newLandlord
    );

    /// @notice emited when an area blocks is marked for sale
    event LogSells(
        uint ID,
        uint8 fromX,
        uint8 fromY,
        uint8 toX,
        uint8 toY,
        uint sellPrice
    );

    /// @notice emited when an area blocks is marked for rent
    event LogRentsOut(
        uint ID,
        uint8 fromX,
        uint8 fromY,
        uint8 toX,
        uint8 toY,
        uint rentPricePerPeriodWei
    );

    /// @notice emited when an area blocks is rented
    event LogRents(
        uint ID,
        uint8 fromX,
        uint8 fromY,
        uint8 toX,
        uint8 toY,
        uint numberOfPeriods,
        uint rentedFrom
    );

    /// @notice emited when an ad is placed to an area
    event LogAds(
        uint ID, 
        uint8 fromX,
        uint8 fromY,
        uint8 toX,
        uint8 toY,
        string imageSourceUrl,
        string adUrl,
        string adText,
        address indexed advertiser);

// ** BUY AND SELL BLOCKS ** //
    
    /// @notice lets a message sender to buy blocks within area
    /// @dev if using a contract to buy an area make sure to implement ERC721 functionality 
    ///  as tokens are transfered using "transferFrom" function and not "safeTransferFrom"
    ///  in order to avoid external calls.
    function buyArea(uint8 fromX, uint8 fromY, uint8 toX, uint8 toY) 
        external
        whenNotPaused
        payable
    {   
        // check input parameters and eth deposited
        require(isLegalCoordinates(fromX, fromY, toX, toY));
        require(canPay(areaPrice(fromX, fromY, toX, toY)));
        depositFunds();

        // try to buy blocks through market contract
        // will get an id of buy-sell operation if succeeds (if all blocks available)
        uint id = market.buyBlocks(msg.sender, blocksList(fromX, fromY, toX, toY));
        emit LogBuys(id, fromX, fromY, toX, toY, msg.sender);
    }

    /// @notice lets a message sender to mark blocks for sale at price set for each block in wei
    /// @dev (priceForEachBlockCents = 0 - not for sale)
    function sellArea(uint8 fromX, uint8 fromY, uint8 toX, uint8 toY, uint priceForEachBlockWei)
        external 
        whenNotPaused
    {   
        // check input parameters
        require(isLegalCoordinates(fromX, fromY, toX, toY));

        // try to mark blocks for sale through market contract
        // will get an id of buy-sell operation if succeeds (if owns all blocks)
        uint id = market.sellBlocks(
            msg.sender, 
            priceForEachBlockWei, 
            blocksList(fromX, fromY, toX, toY)
        );
        emit LogSells(id, fromX, fromY, toX, toY, priceForEachBlockWei);
    }

    /// @notice get area price in wei
    function areaPrice(uint8 fromX, uint8 fromY, uint8 toX, uint8 toY) 
        public 
        view 
        returns (uint) 
    {   
        // check input
        require(isLegalCoordinates(fromX, fromY, toX, toY));

        // querry areaPrice in wei at market contract
        return market.areaPrice(blocksList(fromX, fromY, toX, toY));
    }

// ** RENT OUT AND RENT BLOCKS ** //
        
    /// @notice Rent out an area of blocks at coordinates [fromX, fromY, toX, toY] at a price for 
    ///  each block in wei
    /// @dev if rentPricePerPeriodWei = 0 then makes area not available for rent
    function rentOutArea(uint8 fromX, uint8 fromY, uint8 toX, uint8 toY, uint rentPricePerPeriodWei)
        external
        whenNotPaused
    {   
        // check input
        require(isLegalCoordinates(fromX, fromY, toX, toY));

        // try to mark blocks as rented out through rentals contract
        // will get an id of rent-rentout operation if succeeds (if message sender owns blocks)
        uint id = rentals.rentOutBlocks(
            msg.sender, 
            rentPricePerPeriodWei, 
            blocksList(fromX, fromY, toX, toY)
        );
        emit LogRentsOut(id, fromX, fromY, toX, toY, rentPricePerPeriodWei);
    }
    
    /// @notice Rent an area of blocks at coordinates [fromX, fromY, toX, toY] for a number of 
    ///  periods specified
    ///  (period length is specified in rentals contract)
    function rentArea(uint8 fromX, uint8 fromY, uint8 toX, uint8 toY, uint numberOfPeriods)
        external
        payable
        whenNotPaused
    {   
        // check input parameters and eth deposited
        // checks number of periods > 0 in rentals contract
        require(isLegalCoordinates(fromX, fromY, toX, toY));
        require(canPay(areaRentPrice(fromX, fromY, toX, toY, numberOfPeriods)));
        depositFunds();

        // try to rent blocks through rentals contract
        // will get an id of rent-rentout operation if succeeds (if all blocks available for rent)
        uint id = rentals.rentBlocks(
            msg.sender, 
            numberOfPeriods, 
            blocksList(fromX, fromY, toX, toY)
        );
        emit LogRents(id, fromX, fromY, toX, toY, numberOfPeriods, 0);
    }

    /// @notice get area rent price in wei for number of periods specified 
    ///  (period length is specified in rentals contract) 
    function areaRentPrice(uint8 fromX, uint8 fromY, uint8 toX, uint8 toY, uint numberOfPeriods)
        public 
        view 
        returns (uint) 
    {   
        // check input 
        require(isLegalCoordinates(fromX, fromY, toX, toY));

        // querry areaPrice in wei at rentals contract
        return rentals.blocksRentPrice (numberOfPeriods, blocksList(fromX, fromY, toX, toY));
    }

// ** PLACE ADS ** //
    
    /// @notice places ads (image, caption and link to a website) into desired coordinates
    /// @dev nothing is stored in any of the contracts except an image id. All other data is 
    ///  only emitted in event. Basicaly this function just verifies if an event is allowed 
    ///  to be emitted.
    function placeAds( 
        uint8 fromX, 
        uint8 fromY, 
        uint8 toX, 
        uint8 toY, 
        string imageSource, 
        string link, 
        string text
    ) 
        external
        whenNotPaused
    {   
        // check input
        require(isLegalCoordinates(fromX, fromY, toX, toY));

        // try to place ads through ads contract
        // will get an image id if succeeds (if advertiser owns or rents all blocks within area)
        uint AdsId = ads.advertiseOnBlocks(
            msg.sender, 
            blocksList(fromX, fromY, toX, toY), 
            imageSource, 
            link, 
            text
        );
        emit LogAds(AdsId, fromX, fromY, toX, toY, imageSource, link, text, msg.sender);
    }

    /// @notice check if an advertiser is allowed to put ads within area (i.e. owns or rents all 
    ///  blocks)
    function canAdvertise(
        address advertiser,
        uint8 fromX, 
        uint8 fromY, 
        uint8 toX, 
        uint8 toY
    ) 
        external
        view
        returns (bool)
    {   
        // check user input
        require(isLegalCoordinates(fromX, fromY, toX, toY));

        // querry permission at ads contract
        return ads.canAdvertiseOnBlocks(advertiser, blocksList(fromX, fromY, toX, toY));
    }

// ** IMPORT BLOCKS ** //

    /// @notice import blocks from previous version Million Ether Homepage
    function adminImportOldMEBlock(uint8 x, uint8 y) external onlyOwner {
        (uint id, address newLandlord) = market.importOldMEBlock(x, y);
        emit LogBuys(id, x, y, x, y, newLandlord);
    }

// ** INFO GETTERS ** //
    
    /// @notice get an owner(address) of block at a specified coordinates
    function getBlockOwner(uint8 x, uint8 y) external view returns (address) {
        return ownerOf(blockID(x, y));
    }

// ** UTILS ** //
    
    /// @notice get ERC721 token id corresponding to xy coordinates
    function blockID(uint8 x, uint8 y) public pure returns (uint16) {
        return (uint16(y) - 1) * 100 + uint16(x);
    }

    /// @notice get a number of blocks within area
    function countBlocks(
        uint8 fromX, 
        uint8 fromY, 
        uint8 toX, 
        uint8 toY
    ) 
        internal 
        pure 
        returns (uint16)
    {
        return (toX - fromX + 1) * (toY - fromY + 1);
    }

    /// @notice get an array of all block ids (i.e. ERC721 token ids) within area
    function blocksList(
        uint8 fromX, 
        uint8 fromY, 
        uint8 toX, 
        uint8 toY
    ) 
        internal 
        pure 
        returns (uint16[] memory r) 
    {
        uint i = 0;
        r = new uint16[](countBlocks(fromX, fromY, toX, toY));
        for (uint8 ix=fromX; ix<=toX; ix++) {
            for (uint8 iy=fromY; iy<=toY; iy++) {
                r[i] = blockID(ix, iy);
                i++;
            }
        }
    }
    
    /// @notice insures that area coordinates are within 100x100 field and 
    ///  from-coordinates >= to-coordinates
    /// @dev function is used instead of modifier as modifier 
    ///  required too much stack for placeImage and rentBlocks
    function isLegalCoordinates(
        uint8 _fromX, 
        uint8 _fromY, 
        uint8 _toX, 
        uint8 _toY
    )    
        private 
        pure 
        returns (bool) 
    {
        return ((_fromX >= 1) && (_fromY >=1)  && (_toX <= 100) && (_toY <= 100) 
            && (_fromX <= _toX) && (_fromY <= _toY));
    }
}

// File: contracts/MehModule.sol

/// @title MehModule: Base contract for MEH modules (Market, Rentals and Ads contracts). Provides
///  communication with MEH contract. 
contract MehModule is Ownable, Pausable, Destructible, HasNoEther {
    using SafeMath for uint256;

    // Main MEH contract
    MEH public meh;

    /// @dev Initializes a module, pairs with MEH contract.
    /// @param _mehAddress address of the main Million Ether Homepage contract
    constructor(address _mehAddress) public {
        adminSetMeh(_mehAddress);
    }
    
    /// @dev Throws if called by any address other than the MEH contract.
    modifier onlyMeh() {
        require(msg.sender == address(meh));
        _;
    }

    /// @dev Pairs a module with MEH main contract.
    function adminSetMeh(address _address) internal onlyOwner {
        MEH candidateContract = MEH(_address);
        require(candidateContract.isMEH());
        meh = candidateContract;
    }

    /// @dev Makes an internal transaction in the MEH contract.
    function transferFunds(address _payer, address _recipient, uint _amount) internal {
        return meh.operatorTransferFunds(_payer, _recipient, _amount);
    }

    /// @dev Check if a token exists.
    function exists(uint16 _blockId) internal view  returns (bool) {
        return meh.exists(_blockId);
    }

    /// @dev Querries an owner of a block id (ERC721 token).
    function ownerOf(uint16 _blockId) internal view returns (address) {
        return meh.ownerOf(_blockId);
    }
}

// File: contracts/mockups/OracleProxy.sol

contract OracleProxy is Destructible {
    
    bool public isOracleProxy = true;
    uint public oneCentInWei = 10 wei;

    // function OracleProxy() {
    //     oneCentInWei = 1 wei;  // TODO remove after debug
    // }
    
    // function getOneCentInWei() external view returns (uint) {
    //     return oneCentInWei;
    // }
}

// File: contracts/mockups/OldeMillionEtherInterface.sol

contract OldeMillionEtherInterface {
    function getBlockInfo(uint8, uint8) public returns (address, uint, uint) {}
}

// File: contracts/Market.sol

// @title Market: Pluggable module for MEH contract responsible for buy-sell operations including 
//  initial sale. 80% of initial sale income goes to charity. Initial sale price doubles every 1000 
//  blocks sold
// @dev this contract is unaware of xy block coordinates - ids only (ids are ERC721 tokens)
contract Market is MehModule {

    // Makes MEH contract sure it plugged in the right module 
    bool public isMarket = true;

    // The address of the previous version of The Million Ether Homepage (MEH). 
    // The previous version was published at Dec-13-2016 and was priced in ETH. As the ETH price 
    // strated to rise quickly in March 2017 the pixels became too expensive and nobody bought 
    // new pixels since then. This new version of MEH is priced in USD.
    // Old MEH is here - https://etherscan.io/address/0x15dbdB25f870f21eaf9105e68e249E0426DaE916. 
    OldeMillionEtherInterface public oldMillionEther;

    // Address of an oracle proxy, pluggable. For flexibility sake OracleProxy is a separate module. 
    // The only function of an OracleProxy is to provide usd price. Whenever a better usd Oracle 
    // comes up (with better performance, price, decentralization level, etc.) a new OracleProxy 
    // will be written and plugged.  
    OracleProxy public usd;

    // Internal charity funds vault. 80% of initial sale income goes to this vault. 
    // The address string is "all you need is love" in hex format - insures nobody has access to it.
    // See white paper for details on charity distribution.
    address public constant charityVault = 0x616c6C20796F75206e656564206973206C6f7665; 
    uint public charityPayed = 0;

    // Map from block ID to their corresponding price tag.
    // uint256 instead of uint16 for ERC721 compliance
    mapping (uint16 => uint256) public blockIdToPrice;
    
    // Keeps track of buy-sell events
    uint public numOwnershipStatuses = 0;

    // Reports
    event LogModuleUpgrade(address newAddress, string moduleName);
    event LogCharityTransfer(address charityAddress, uint amount);

// ** INITIALIZE ** //
    
    /// @dev Initialize Market contract.
    /// @param _mehAddress address of the main Million Ether Homepage contract
    /// @param _oldMehAddress address of the previous MEH version for import
    /// @param _oracleProxyAddress usd oracle address. Can be changed afterwards
    constructor(address _mehAddress, address _oldMehAddress, address _oracleProxyAddress)
        MehModule(_mehAddress)
        public
    {
        oldMillionEther = OldeMillionEtherInterface(_oldMehAddress);
        adminSetOracle(_oracleProxyAddress);
    }

// ** BUY BLOCKS ** //
    
    /// @dev Lets buy a list of blocks by block ids
    function buyBlocks(address _buyer, uint16[] _blockList) 
        external
        onlyMeh
        whenNotPaused
        returns (uint)
    {   
        for (uint i = 0; i < _blockList.length; i++) {
            buyBlock(_buyer, _blockList[i]);
        }
        numOwnershipStatuses++;
        return numOwnershipStatuses;
    }

    /// @dev buys 1 block
    function buyBlock(address _buyer, uint16 _blockId) private {
        // checks if a block id is already minted (if ERC721 token exists)
        if (exists(_blockId)) {
            // if minted it means that the block has an owner, try to by from owner
            buyOwnedBlock(_buyer, _blockId);
        } else {
            // if not minted yet, buy from crowdsale (also called initial sale here)
            buyCrowdsaleBlock(_buyer, _blockId);
        }
    }
    /// @dev buy a block (by id) from current owner (if an owner is selling)
    function buyOwnedBlock(address _buyer, uint16 _blockId) private {
        uint blockPrice = blockSellPrice(_blockId);
        address blockOwner = ownerOf(_blockId);
        require(blockPrice > 0);
        require(_buyer != blockOwner);

        // transfer funds internally (no external calls)
        transferFunds(_buyer, blockOwner, blockPrice);
        // transfer ERC721 token (block id) to a new owner
        transferNFT(blockOwner, _buyer, _blockId);
        // reset sell price
        setSellPrice(_blockId, 0);
    }

    /// @dev buy a block (by id) at crowdsale (initial sale). 
    function buyCrowdsaleBlock(address _buyer, uint16 _blockId) private {
        uint blockPrice = crowdsalePriceWei();
        transferFundsToAdminAndCharity(_buyer, blockPrice);
        // mint new ERC721 token
        mintCrowdsaleBlock(_buyer, _blockId);
    }

    /// @dev get a block sell price set by block owner
    function blockSellPrice(uint16 _blockId) private view returns (uint) {
        return blockIdToPrice[_blockId];
    }

    /// @dev calculates crowdsale (initial sale) price. Price doubles every 1000 block sold
    function crowdsalePriceWei() private view returns (uint) {
        uint256 blocksSold = meh.totalSupply();
        // get ETHUSD price from an usd price oralce
        uint256 oneCentInWei = usd.oneCentInWei();

        // sanity check (in case oracle proxy or oralce go completely mad)
        require(oneCentInWei > 0);

        // return price in wei
        return crowdsalePriceUSD(blocksSold).mul(oneCentInWei).mul(100);
    }

    /// @dev calculates price in USD. Doubles every 1000 blocks sold.
    function crowdsalePriceUSD(uint256 _blocksSold) internal pure returns (uint256) {
        // can't overflow as _blocksSold == meh.totalSupply() and meh.totalSupply() < 10000
        return 2 ** (_blocksSold / 1000);
    }

// ** SELL BLOCKS ** //
    
    /// @dev Lets seller sell a list of blocks by block ids. 
    function sellBlocks(address _seller, uint priceForEachBlockWei, uint16[] _blockList) 
        external
        onlyMeh
        whenNotPaused
        returns (uint)
    {   
        for (uint i = 0; i < _blockList.length; i++) {
            require(_seller == ownerOf(_blockList[i]));
            sellBlock(_blockList[i], priceForEachBlockWei);
        }
        numOwnershipStatuses++;
        return numOwnershipStatuses;
    }

    /// @dev Sets or updates price tag for a block id.
    ///  _sellPriceWei = 0 - cancel sale
    function sellBlock(uint16 _blockId, uint _sellPriceWei) private {
        setSellPrice(_blockId, _sellPriceWei);
    }

    function setSellPrice(uint16 _blockId, uint256 _sellPriceWei) private {
        blockIdToPrice[_blockId] = _sellPriceWei;
    }

// ** ADMIN ** //

    /// @dev transfer charity _amount to an address (internally).
    function adminTransferCharity(address _charityAddress, uint _amount) external onlyOwner {
        require(_charityAddress != owner);
        transferFunds(charityVault, _charityAddress, _amount);
        charityPayed += _amount;
        emit LogCharityTransfer(_charityAddress, _amount);
    }

    /// @dev set or reset an Oracle Proxy
    function adminSetOracle(address _address) public onlyOwner {
        OracleProxy candidateContract = OracleProxy(_address);
        require(candidateContract.isOracleProxy());
        usd = candidateContract;
        emit LogModuleUpgrade(_address, "OracleProxy");
    }

    /// @dev import old million ether contract blocks. See oldMillionEther variable 
    ///  description above for more.
    function importOldMEBlock(uint8 _x, uint8 _y) external onlyMeh returns (uint, address) {
        uint16 blockId = meh.blockID(_x, _y);
        require(!(exists(blockId)));
        // WARN! sell price is in wei
        (address oldLandlord, uint i, uint s) = oldMillionEther.getBlockInfo(_x, _y);  
        require(oldLandlord != address(0));
        mintCrowdsaleBlock(oldLandlord, blockId);
        numOwnershipStatuses++;
        return (numOwnershipStatuses, oldLandlord);
    }

// ** INFO ** //
    
    /// @dev get a sell price for a list of blocks 
    function areaPrice(uint16[] _blockList)
        external 
        view 
        returns (uint _totalPrice) 
    {
        _totalPrice = 0;
        for (uint i = 0; i < _blockList.length; i++) {
            // As sell price value is arbitrary add is overflow-safe here
            _totalPrice = _totalPrice.add(getBlockPrice(_blockList[i]));
        }
    }

    /// @dev checks if a block is on sale. Usage e.g. - permits ERC721 tokens transfer when on sale.
    function isOnSale(uint16 _blockId) public view returns (bool) {
        return (blockIdToPrice[_blockId] > 0);
    }

    function getBlockPrice(uint16 _blockId) private view returns (uint) {
        uint blockPrice = 0;
        if (exists(_blockId)) {
            blockPrice = blockSellPrice(_blockId);
            require(blockPrice > 0);
        } else {
            blockPrice = crowdsalePriceWei();
        }
        return blockPrice;
    }
    
// ** PAYMENT PROCESSING ** //

    /// @dev transfers 80% of payers funds to charity and 20% to contract owner (admin)
    function transferFundsToAdminAndCharity(address _payer, uint _amount) private {
        // 80% goes to charity  // check for oveflow too (in case of oracle mistake)
        uint goesToCharity = _amount * 80 / 100;  
        transferFunds(_payer, charityVault, goesToCharity);
        transferFunds(_payer, owner, _amount - goesToCharity);
    }

// ** ERC721 ** //
    
    /// @dev mint new ERC721 token
    function mintCrowdsaleBlock(address _to, uint16 _blockId) private {
        meh._mintCrowdsaleBlock(_to, _blockId);
    }

    /// @dev transfer ERC721 token
    function transferNFT(address _from, address _to, uint16 _blockId) private {
        meh.transferFrom(_from, _to, _blockId);  // safeTransfer has external call
    }
}