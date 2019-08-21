pragma solidity ^0.4.24; 

interface ERC165 {
  /**
   * @notice Query if a contract implements an interface
   * @param _interfaceId The interface identifier, as specified in ERC-165
   * @dev Interface identification is specified in ERC-165. This function
   * uses less than 30,000 gas.
   */
  function supportsInterface(bytes4 _interfaceId) external view returns (bool);
}

interface ERC721 /* is ERC165 */ {
    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) external view returns (uint256);

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view returns (address);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns (address);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

///  Note: the ERC-165 identifier for this interface is 0x780e9d63.
interface ERC721Enumerable /* is ERC721 */ {
    /// @notice Count NFTs tracked by this contract
    /// @return A count of valid NFTs tracked by this contract, where each one of
    ///  them has an assigned and queryable owner not equal to the zero address
    function totalSupply() external view returns (uint256);

    /// @notice Enumerate valid NFTs
    /// @dev Throws if `_index` >= `totalSupply()`.
    /// @param _index A counter less than `totalSupply()`
    /// @return The token identifier for the `_index`th NFT,
    ///  (sort order not specified)
    function tokenByIndex(uint256 _index) external view returns (uint256);

    /// @notice Enumerate NFTs assigned to an owner
    /// @dev Throws if `_index` >= `balanceOf(_owner)` or if
    ///  `_owner` is the zero address, representing invalid NFTs.
    /// @param _owner An address where we are interested in NFTs owned by them
    /// @param _index A counter less than `balanceOf(_owner)`
    /// @return The token identifier for the `_index`th NFT assigned to `_owner`,
    ///   (sort order not specified)
    function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256);
}

///  Note: the ERC-165 identifier for this interface is 0x5b5e139f.
interface ERC721Metadata /* is ERC721 */ {
  /// @notice A descriptive name for a collection of NFTs in this contract
  function name() external view returns (string _name);

  /// @notice An abbreviated name for NFTs in this contract
  function symbol() external view returns (string _symbol);

  /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
  /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
  ///  3986. The URI may point to a JSON file that conforms to the "ERC721
  ///  Metadata JSON Schema".
  function tokenURI(uint256 _tokenId) external view returns (string);
}

/// @dev Note: the ERC-165 identifier for this interface is 0x150b7a02.
interface ERC721TokenReceiver {
    /// @notice Handle the receipt of an NFT
    /// @dev The ERC721 smart contract calls this function on the recipient
    ///  after a `transfer`. This function MAY throw to revert and reject the
    ///  transfer. Return of other than the magic value MUST result in the
    ///  transaction being reverted.
    ///  Note: the contract address is always the message sender.
    /// @param _operator The address which called `safeTransferFrom` function
    /// @param _from The address which previously owned the token
    /// @param _tokenId The NFT identifier which is being transferred
    /// @param _data Additional data with no specified format
    /// @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    ///  unless throwing
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4);
}

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

/**
 * Utility library of inline functions on addresses
 */
library AddressUtils {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   * as the code is not actually created until after the constructor finishes.
   * @param addr address to check
   * @return whether the target address is a contract
   */
  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    // solium-disable-next-line security/no-inline-assembly
    assembly { size := extcodesize(addr) }
    return size > 0;
  }

}
 
library UrlStr {
  
  // generate url by tokenId
  // baseUrl must end with 00000000
  function generateUrl(string url,uint256 _tokenId) internal pure returns (string _url){
    _url = url;
    bytes memory _tokenURIBytes = bytes(_url);
    uint256 base_len = _tokenURIBytes.length - 1;
    _tokenURIBytes[base_len - 7] = byte(48 + _tokenId / 10000000 % 10);
    _tokenURIBytes[base_len - 6] = byte(48 + _tokenId / 1000000 % 10);
    _tokenURIBytes[base_len - 5] = byte(48 + _tokenId / 100000 % 10);
    _tokenURIBytes[base_len - 4] = byte(48 + _tokenId / 10000 % 10);
    _tokenURIBytes[base_len - 3] = byte(48 + _tokenId / 1000 % 10);
    _tokenURIBytes[base_len - 2] = byte(48 + _tokenId / 100 % 10);
    _tokenURIBytes[base_len - 1] = byte(48 + _tokenId / 10 % 10);
    _tokenURIBytes[base_len - 0] = byte(48 + _tokenId / 1 % 10);
  }
}

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
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
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

/**
 * @title Operator
 * @dev Allow two roles: 'owner' or 'operator'
 *      - owner: admin/superuser (e.g. with financial rights)
 *      - operator: can update configurations
 */
contract Operator is Ownable {

    address[] public operators;

    uint public MAX_OPS = 20; // Default maximum number of operators allowed

    mapping(address => bool) public isOperator;

    event OperatorAdded(address operator);
    event OperatorRemoved(address operator);

    // @dev Throws if called by any non-operator account. Owner has all ops rights.
    modifier onlyOperator() {
        require(
            isOperator[msg.sender] || msg.sender == owner,
            "Permission denied. Must be an operator or the owner."
        );
        _;
    }

    /**
     * @dev Allows the current owner or operators to add operators
     * @param _newOperator New operator address
     */
    function addOperator(address _newOperator) public onlyOwner {
        require(
            _newOperator != address(0),
            "Invalid new operator address."
        );

        // Make sure no dups
        require(
            !isOperator[_newOperator],
            "New operator exists."
        );

        // Only allow so many ops
        require(
            operators.length < MAX_OPS,
            "Overflow."
        );

        operators.push(_newOperator);
        isOperator[_newOperator] = true;

        emit OperatorAdded(_newOperator);
    }

    /**
     * @dev Allows the current owner or operators to remove operator
     * @param _operator Address of the operator to be removed
     */
    function removeOperator(address _operator) public onlyOwner {
        // Make sure operators array is not empty
        require(
            operators.length > 0,
            "No operator."
        );

        // Make sure the operator exists
        require(
            isOperator[_operator],
            "Not an operator."
        );

        // Manual array manipulation:
        // - replace the _operator with last operator in array
        // - remove the last item from array
        address lastOperator = operators[operators.length - 1];
        for (uint i = 0; i < operators.length; i++) {
            if (operators[i] == _operator) {
                operators[i] = lastOperator;
            }
        }
        operators.length -= 1; // remove the last element

        isOperator[_operator] = false;
        emit OperatorRemoved(_operator);
    }

    // @dev Remove ALL operators
    function removeAllOps() public onlyOwner {
        for (uint i = 0; i < operators.length; i++) {
            isOperator[operators[i]] = false;
        }
        operators.length = 0;
    }
}
 
contract Pausable is Operator {

  event FrozenFunds(address target, bool frozen);

  bool public isPaused = false;
  
  mapping(address => bool)  frozenAccount;

  modifier whenNotPaused {
    require(!isPaused);
    _;
  }

  modifier whenPaused {
    require(isPaused);
    _;  
  }

  modifier whenNotFreeze(address _target) {
    require(_target != address(0));
    require(!frozenAccount[_target]);
    _;
  }

  function isFrozen(address _target) external view returns (bool) {
    require(_target != address(0));
    return frozenAccount[_target];
  }

  function doPause() external  whenNotPaused onlyOwner {
    isPaused = true;
  }

  function doUnpause() external  whenPaused onlyOwner {
    isPaused = false;
  }

  function freezeAccount(address _target, bool _freeze) public onlyOwner {
    require(_target != address(0));
    frozenAccount[_target] = _freeze;
    emit FrozenFunds(_target, _freeze);
  }

}

contract ERC721BasicToken is SupportsInterfaceWithLookup, ERC721, Pausable{

  bytes4 public constant InterfaceId_ERC721 = 0x80ac58cd;
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

  bytes4 public constant InterfaceId_ERC721Exists = 0x4f558e79;
  /*
   * 0x4f558e79 ===
   *   bytes4(keccak256('exists(uint256)'))
   */

  using SafeMath for uint256;
  using AddressUtils for address;

  // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
  // which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
  bytes4 public constant ERC721_RECEIVED = 0x150b7a02;

  // Mapping from token ID to owner
  mapping (uint256 => address) internal tokenOwner;

  // Mapping from token ID to approved address
  mapping (uint256 => address) internal tokenApprovals;

  // Mapping from owner to number of owned token
  mapping (address => uint256) internal ownedTokensCount;

  // Mapping from owner to operator approvals
  mapping (address => mapping (address => bool)) internal operatorApprovals;

  /**
   * @dev Guarantees msg.sender is owner of the given token
   * @param _tokenId uint256 ID of the token to validate its ownership belongs to msg.sender
   */
  modifier onlyOwnerOf(uint256 _tokenId) {
    require(_ownerOf(_tokenId) == msg.sender,"This token not owned by this address");
    _;
  }
  
  function _ownerOf(uint256 _tokenId) internal view returns(address) {
    address _owner = tokenOwner[_tokenId];
    require(_owner != address(0),"Token not exist");
    return _owner;
  }

  /**
   * @dev Checks msg.sender can transfer a token, by being owner, approved, or operator
   * @param _tokenId uint256 ID of the token to validate
   */
  modifier canTransfer(uint256 _tokenId) {
    require(isApprovedOrOwner(msg.sender, _tokenId), "This address have no permisstion");
    _;
  }

  constructor()
    public
  {
    // register the supported interfaces to conform to ERC721 via ERC165
    _registerInterface(InterfaceId_ERC721);
    _registerInterface(InterfaceId_ERC721Exists);
    _registerInterface(ERC721_RECEIVED);
  }

  /**
   * @dev Gets the balance of the specified address
   * @param _owner address to query the balance of
   * @return uint256 representing the amount owned by the passed address
   */
  function balanceOf(address _owner) external view returns (uint256) {
    require(_owner != address(0));
    return ownedTokensCount[_owner];
  }

  /**
   * @dev Gets the owner of the specified token ID
   * @param _tokenId uint256 ID of the token to query the owner of
   * @return owner address currently marked as the owner of the given token ID
   */
  function ownerOf(uint256 _tokenId) external view returns (address) {
    return _ownerOf(_tokenId);
  }

  /**
   * @dev Returns whether the specified token exists
   * @param _tokenId uint256 ID of the token to query the existence of
   * @return whether the token exists
   */
  function exists(uint256 _tokenId) internal view returns (bool) {
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
  function approve(address _to, uint256 _tokenId) external whenNotPaused {
    address _owner = _ownerOf(_tokenId);
    require(_to != _owner);
    require(msg.sender == _owner || operatorApprovals[_owner][msg.sender]);

    tokenApprovals[_tokenId] = _to;
    emit Approval(_owner, _to, _tokenId);
  }

  /**
   * @dev Gets the approved address for a token ID, or zero if no address set
   * @param _tokenId uint256 ID of the token to query the approval of
   * @return address currently approved for the given token ID
   */
  function getApproved(uint256 _tokenId) external view returns (address) {
    return tokenApprovals[_tokenId];
  }

  /**
   * @dev Sets or unsets the approval of a given operator
   * An operator is allowed to transfer all tokens of the sender on their behalf
   * @param _to operator address to set the approval
   * @param _approved representing the status of the approval to be set
   */
  function setApprovalForAll(address _to, bool _approved) external whenNotPaused {
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
    external
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
    external
    canTransfer(_tokenId)
  {
    _transfer(_from,_to,_tokenId);
  }


  function _transfer(
    address _from,
    address _to,
    uint256 _tokenId) internal {
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
    external
    canTransfer(_tokenId)
  {
    // solium-disable-next-line arg-overflow
    _safeTransferFrom(_from, _to, _tokenId, "");
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
  function _safeTransferFrom( 
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data) internal {
    _transfer(_from, _to, _tokenId);
      // solium-disable-next-line arg-overflow
    require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
  }

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes _data
  )
    external
    canTransfer(_tokenId)
  {
    _safeTransferFrom(_from, _to, _tokenId, _data);
   
  }

  /**
   * @dev Returns whether the given spender can transfer a given token ID
   * @param _spender address of the spender to query
   * @param _tokenId uint256 ID of the token to be transferred
   * @return bool whether the msg.sender is approved for the given token ID,
   *  is an operator of the owner, or is the owner of the token
   */
  function isApprovedOrOwner (
    address _spender,
    uint256 _tokenId
  )
    internal
    view
    returns (bool)
  {
    address _owner = _ownerOf(_tokenId);
    // Disable solium check because of
    // https://github.com/duaraghav8/Solium/issues/175
    // solium-disable-next-line operator-whitespace
    return (
      _spender == _owner ||
      tokenApprovals[_tokenId] == _spender ||
      operatorApprovals[_owner][_spender]
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
  function clearApproval(address _owner, uint256 _tokenId) internal whenNotPaused {
    require(_ownerOf(_tokenId) == _owner);
    if (tokenApprovals[_tokenId] != address(0)) {
      tokenApprovals[_tokenId] = address(0);
    }
  }

  /**
   * @dev Internal function to add a token ID to the list of a given address
   * @param _to address representing the new owner of the given token ID
   * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
   */
  function addTokenTo(address _to, uint256 _tokenId) internal whenNotPaused {
    require(tokenOwner[_tokenId] == address(0));
    require(!frozenAccount[_to]);  
    tokenOwner[_tokenId] = _to;
    ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
  }

  /**
   * @dev Internal function to remove a token ID from the list of a given address
   * @param _from address representing the previous owner of the given token ID
   * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
   */
  function removeTokenFrom(address _from, uint256 _tokenId) internal whenNotPaused {
    require(_ownerOf(_tokenId) == _from);
    require(!frozenAccount[_from]);  
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
    bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(
      msg.sender, _from, _tokenId, _data);
    return (retval == ERC721_RECEIVED);
  }
}
 
contract ERC721ExtendToken is ERC721BasicToken, ERC721Enumerable, ERC721Metadata {

  using UrlStr for string;

  bytes4 public constant InterfaceId_ERC721Enumerable = 0x780e9d63;
  /**
   * 0x780e9d63 ===
   *   bytes4(keccak256('totalSupply()')) ^
   *   bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^
   *   bytes4(keccak256('tokenByIndex(uint256)'))
   */

  bytes4 public constant InterfaceId_ERC721Metadata = 0x5b5e139f;
  /**
   * 0x5b5e139f ===
   *   bytes4(keccak256('name()')) ^
   *   bytes4(keccak256('symbol()')) ^
   *   bytes4(keccak256('tokenURI(uint256)'))
   */
  string internal BASE_URL = "https://www.bitguild.com/bitizens/api/item/getItemInfo/00000000";

  // Mapping from owner to list of owned token IDs
  mapping(address => uint256[]) internal ownedTokens;

  // Mapping from token ID to index of the owner tokens list
  mapping(uint256 => uint256) internal ownedTokensIndex;

  // Array with all token ids, used for enumeration
  uint256[] internal allTokens;

  // Mapping from token id to position in the allTokens array
  mapping(uint256 => uint256) internal allTokensIndex;

  function updateBaseURI(string _url) external onlyOwner {
    BASE_URL = _url;
  }
  
  /**
   * @dev Constructor function
   */
  constructor() public {
    // register the supported interfaces to conform to ERC721 via ERC165
    _registerInterface(InterfaceId_ERC721Enumerable);
    _registerInterface(InterfaceId_ERC721Metadata);
  }

  /**
   * @dev Gets the token name
   * @return string representing the token name
   */
  function name() external view returns (string) {
    return "Bitizen item";
  }

  /**
   * @dev Gets the token symbol
   * @return string representing the token symbol
   */
  function symbol() external view returns (string) {
    return "ITMT";
  }

  /**
   * @dev Returns an URI for a given token ID
   * Throws if the token ID does not exist. May return an empty string.
   * @param _tokenId uint256 ID of the token to query
   */
  function tokenURI(uint256 _tokenId) external view returns (string) {
    require(exists(_tokenId));
    return BASE_URL.generateUrl(_tokenId);
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
    require(address(0)!=_owner);
    require(_index < ownedTokensCount[_owner]);
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
   * @dev Internal function to add a token ID to the list of a given address
   * @param _to address representing the new owner of the given token ID
   * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
   */
  function addTokenTo(address _to, uint256 _tokenId) internal whenNotPaused {
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
  function removeTokenFrom(address _from, uint256 _tokenId) internal whenNotPaused {
    super.removeTokenFrom(_from, _tokenId);

    uint256 tokenIndex = ownedTokensIndex[_tokenId];
    uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
    uint256 lastToken = ownedTokens[_from][lastTokenIndex];

    ownedTokens[_from][tokenIndex] = lastToken;
    ownedTokens[_from][lastTokenIndex] = 0;
    // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to
    // be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we are first swapping
    // the lastToken to the first position, and then dropping the element placed in the last position of the list

    ownedTokens[_from].length--;
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

/**
  if a ERC721 item want to mount to avatar, it must to inherit this.
 */
interface AvatarChildService {
  /**
      @dev if you want your contract become a avatar child, please let your contract inherit this interface
      @param _tokenId1  first child token id
      @param _tokenId2  second child token id
      @return  true will unmount first token before mount ,false will directly mount child
   */
   function compareItemSlots(uint256 _tokenId1, uint256 _tokenId2) external view returns (bool _res);

  /**
   @dev if you want your contract become a avatar child, please let your contract inherit this interface
   @return return true will be to avatar child
   */
   function isAvatarChild(uint256 _tokenId) external view returns(bool);
}

interface AvatarItemService {

  function getTransferTimes(uint256 _tokenId) external view returns(uint256);
  function getOwnedItems(address _owner) external view returns(uint256[] _tokenIds);
  
  function getItemInfo(uint256 _tokenId)
    external 
    view 
    returns(string, string, bool, uint256[4] _attr1, uint8[5] _attr2, uint16[2] _attr3);

  function isBurned(uint256 _tokenId) external view returns (bool); 
  function isSameItem(uint256 _tokenId1, uint256 _tokenId2) external view returns (bool _isSame);
  function getBurnedItemCount() external view returns (uint256);
  function getBurnedItemByIndex(uint256 _index) external view returns (uint256);
  function getSameItemCount(uint256 _tokenId) external view returns(uint256);
  function getSameItemIdByIndex(uint256 _tokenId, uint256 _index) external view returns(uint256);
  function getItemHash(uint256 _tokenId) external view returns (bytes8); 

  function burnItem(address _owner, uint256 _tokenId) external;
  /**
    @param _owner         owner of the token
    @param _founder       founder type of the token 
    @param _creator       creator type of the token
    @param _isBitizenItem true is for bitizen or false
    @param _attr1         _atrr1[0] => node   _atrr1[1] => listNumber _atrr1[2] => setNumber  _atrr1[3] => quality
    @param _attr2         _atrr2[0] => rarity _atrr2[1] => socket     _atrr2[2] => gender     _atrr2[3] => energy  _atrr2[4] => ext 
    @param _attr3         _atrr3[0] => miningTime  _atrr3[1] => magicFind     
    @return               token id
   */
  function createItem( 
    address _owner,
    string _founder,
    string _creator, 
    bool _isBitizenItem, 
    uint256[4] _attr1,
    uint8[5] _attr2,
    uint16[2] _attr3)
    external  
    returns(uint256 _tokenId);

  function updateItem(
    uint256 _tokenId,
    bool  _isBitizenItem,
    uint16 _miningTime,
    uint16 _magicFind,
    uint256 _node,
    uint256 _listNumber,
    uint256 _setNumber,
    uint256 _quality,
    uint8 _rarity,
    uint8 _socket,
    uint8 _gender,
    uint8 _energy,
    uint8 _ext
  ) 
  external;
}

contract AvatarItemToken is ERC721ExtendToken, AvatarItemService, AvatarChildService {

  enum ItemHandleType{NULL, CREATE_ITEM, UPDATE_ITEM, BURN_ITEM}
  
  event ItemHandleEvent(address indexed _owner, uint256 indexed _itemId,ItemHandleType _type);

  struct AvatarItem {
    string foundedBy;     // item founder
    string createdBy;     // item creator
    bool isBitizenItem;   // true for bitizen false for other
    uint16 miningTime;    // decrease the mine time, range to 0 ~ 10000/0.00% ~ 100.00%
    uint16 magicFind;     // increase get rare item, range to 0 ~ 10000/0.00% ~ 100.00%
    uint256 node;         // node token id 
    uint256 listNumber;   // list number
    uint256 setNumber;    // set number
    uint256 quality;      // quality of item 
    uint8 rarity;         // 01 => Common 02 => Uncommon  03 => Rare  04 => Epic 05 => Legendary 06 => Godlike 10 => Limited
    uint8 socket;         // 01 => Head   02 => Top  03 => Bottom  04 => Feet  05 => Trinket  06 => Acc  07 => Props 
    uint8 gender;         // 00 => Male   01 => Female 10 => Male-only 11 => Female-only  Unisex => 99
    uint8 energy;         // increases extra mining times
    uint8 ext;            // extra attribute for future
  }
  
  // item id index
  uint256 internal itemIndex = 0;
  // tokenId => item
  mapping(uint256 => AvatarItem) internal avatarItems;
  // all the burned token ids
  uint256[] internal burnedItemIds;
  // check token id => isBurned
  mapping(uint256 => bool) internal isBurnedItem;
  // hash(item) => tokenIds
  mapping(bytes8 => uint256[]) internal sameItemIds;
  // token id => index in the same item token ids array
  mapping(uint256 => uint256) internal sameItemIdIndex;
  // token id => hash(item)
  mapping(uint256 => bytes8) internal itemIdToHash;
  // item token id => transfer count
  mapping(uint256 => uint256) internal itemTransferCount;

  // avatar address, add default permission to handle item
  address internal avatarAccount = this;

  // contain burned token and exist token 
  modifier validItem(uint256 _itemId) {
    require(_itemId > 0 && _itemId <= itemIndex, "token not vaild");
    _;
  }

  modifier itemExists(uint256 _itemId){
    require(exists(_itemId), "token error");
    _;
  }

  function setDefaultApprovalAccount(address _account) public onlyOwner {
    avatarAccount = _account;
  }

  function compareItemSlots(uint256 _itemId1, uint256 _itemId2)
    external
    view
    itemExists(_itemId1)
    itemExists(_itemId2)
    returns (bool) {
    require(_itemId1 != _itemId2, "compared token shouldn't be the same");
    return avatarItems[_itemId1].socket == avatarItems[_itemId2].socket;
  }

  function isAvatarChild(uint256 _itemId) external view returns(bool){
    return true;
  }

  function getTransferTimes(uint256 _itemId) external view validItem(_itemId) returns(uint256) {
    return itemTransferCount[_itemId];
  }

  function getOwnedItems(address _owner) external view onlyOperator returns(uint256[] _items) {
    require(_owner != address(0), "address invalid");
    return ownedTokens[_owner];
  }

  function getItemInfo(uint256 _itemId)
    external 
    view 
    validItem(_itemId)
    returns(string, string, bool, uint256[4] _attr1, uint8[5] _attr2, uint16[2] _attr3) {
    AvatarItem storage item = avatarItems[_itemId];
    _attr1[0] = item.node;
    _attr1[1] = item.listNumber;
    _attr1[2] = item.setNumber;
    _attr1[3] = item.quality;  
    _attr2[0] = item.rarity;
    _attr2[1] = item.socket;
    _attr2[2] = item.gender;
    _attr2[3] = item.energy;
    _attr2[4] = item.ext;
    _attr3[0] = item.miningTime;
    _attr3[1] = item.magicFind;
    return (item.foundedBy, item.createdBy, item.isBitizenItem, _attr1, _attr2, _attr3);
  }

  function isBurned(uint256 _itemId) external view validItem(_itemId) returns (bool) {
    return isBurnedItem[_itemId];
  }

  function getBurnedItemCount() external view returns (uint256) {
    return burnedItemIds.length;
  }

  function getBurnedItemByIndex(uint256 _index) external view returns (uint256) {
    require(_index < burnedItemIds.length, "out of boundary");
    return burnedItemIds[_index];
  }

  function getSameItemCount(uint256 _itemId) external view validItem(_itemId) returns(uint256) {
    return sameItemIds[itemIdToHash[_itemId]].length;
  }
  
  function getSameItemIdByIndex(uint256 _itemId, uint256 _index) external view validItem(_itemId) returns(uint256) {
    bytes8 itemHash = itemIdToHash[_itemId];
    uint256[] storage items = sameItemIds[itemHash];
    require(_index < items.length, "out of boundray");
    return items[_index];
  }

  function getItemHash(uint256 _itemId) external view validItem(_itemId) returns (bytes8) {
    return itemIdToHash[_itemId];
  }

  function isSameItem(uint256 _itemId1, uint256 _itemId2)
    external
    view
    validItem(_itemId1)
    validItem(_itemId2)
    returns (bool _isSame) {
    if(_itemId1 == _itemId2) {
      _isSame = true;
    } else {
      _isSame = _calcuItemHash(_itemId1) == _calcuItemHash(_itemId2);
    }
  }

  function burnItem(address _owner, uint256 _itemId) external onlyOperator itemExists(_itemId) {
    _burnItem(_owner, _itemId);
  }

  function createItem( 
    address _owner,
    string _founder,
    string _creator, 
    bool _isBitizenItem, 
    uint256[4] _attr1,
    uint8[5] _attr2,
    uint16[2] _attr3)
    external  
    onlyOperator
    returns(uint256 _itemId) {
    require(_owner != address(0), "address invalid");
    AvatarItem memory item = _mintItem(_founder, _creator, _isBitizenItem, _attr1, _attr2, _attr3);
    _itemId = ++itemIndex;
    avatarItems[_itemId] = item;
    _mint(_owner, _itemId);
    _saveItemHash(_itemId);
    emit ItemHandleEvent(_owner, _itemId, ItemHandleType.CREATE_ITEM);
  }

  function updateItem(
    uint256 _itemId,
    bool  _isBitizenItem,
    uint16 _miningTime,
    uint16 _magicFind,
    uint256 _node,
    uint256 _listNumber,
    uint256 _setNumber,
    uint256 _quality,
    uint8 _rarity,
    uint8 _socket,
    uint8 _gender,
    uint8 _energy,
    uint8 _ext
  ) 
  external 
  onlyOperator
  itemExists(_itemId){
    _deleteOldValue(_itemId); 
    _updateItem(_itemId,_isBitizenItem,_miningTime,_magicFind,_node,_listNumber,_setNumber,_quality,_rarity,_socket,_gender,_energy,_ext);
    _saveItemHash(_itemId);
  }

  function _deleteOldValue(uint256 _itemId) private {
    uint256[] storage tokenIds = sameItemIds[itemIdToHash[_itemId]];
    require(tokenIds.length > 0);
    uint256 lastTokenId = tokenIds[tokenIds.length - 1];
    tokenIds[sameItemIdIndex[_itemId]] = lastTokenId;
    sameItemIdIndex[lastTokenId] = sameItemIdIndex[_itemId];
    tokenIds.length--;
  }

  function _saveItemHash(uint256 _itemId) private {
    bytes8 itemHash = _calcuItemHash(_itemId);
    uint256 index = sameItemIds[itemHash].push(_itemId);
    sameItemIdIndex[_itemId] = index - 1;
    itemIdToHash[_itemId] = itemHash;
  }
    
  function _calcuItemHash(uint256 _itemId) private view returns (bytes8) {
    AvatarItem storage item = avatarItems[_itemId];
    bytes memory itemBytes = abi.encodePacked(
      item.isBitizenItem,
      item.miningTime,
      item.magicFind,
      item.node,
      item.listNumber,
      item.setNumber,
      item.quality,
      item.rarity,
      item.socket,
      item.gender,
      item.energy,
      item.ext
      );
    return bytes8(keccak256(itemBytes));
  }

  function _mintItem(  
    string _foundedBy,
    string _createdBy, 
    bool _isBitizenItem, 
    uint256[4] _attr1, 
    uint8[5] _attr2,
    uint16[2] _attr3) 
    private
    pure
    returns(AvatarItem _item) {
    _item = AvatarItem(
      _foundedBy,
      _createdBy,
      _isBitizenItem, 
      _attr3[0], 
      _attr3[1], 
      _attr1[0],
      _attr1[1], 
      _attr1[2], 
      _attr1[3],
      _attr2[0], 
      _attr2[1], 
      _attr2[2], 
      _attr2[3],
      _attr2[4]
    );
  }

  function _updateItem(
    uint256 _itemId,
    bool  _isBitizenItem,
    uint16 _miningTime,
    uint16 _magicFind,
    uint256 _node,
    uint256 _listNumber,
    uint256 _setNumber,
    uint256 _quality,
    uint8 _rarity,
    uint8 _socket,
    uint8 _gender,
    uint8 _energy,
    uint8 _ext
  ) private {
    AvatarItem storage item = avatarItems[_itemId];
    item.isBitizenItem = _isBitizenItem;
    item.miningTime = _miningTime;
    item.magicFind = _magicFind;
    item.node = _node;
    item.listNumber = _listNumber;
    item.setNumber = _setNumber;
    item.quality = _quality;
    item.rarity = _rarity;
    item.socket = _socket;
    item.gender = _gender;  
    item.energy = _energy; 
    item.ext = _ext; 
    emit ItemHandleEvent(_ownerOf(_itemId), _itemId, ItemHandleType.UPDATE_ITEM);
  }

  function _burnItem(address _owner, uint256 _itemId) private {
    burnedItemIds.push(_itemId);
    isBurnedItem[_itemId] = true;
    _burn(_owner, _itemId);
    emit ItemHandleEvent(_owner, _itemId, ItemHandleType.BURN_ITEM);
  }

  // override 
  //Add default permission to avatar, user can change this permission by call setApprovalForAll
  function _mint(address _to, uint256 _itemId) internal {
    super._mint(_to, _itemId);
    operatorApprovals[_to][avatarAccount] = true;
  }

  // override
  // record every token transfer count
  function _transfer(address _from, address _to, uint256 _itemId) internal {
    super._transfer(_from, _to, _itemId);
    itemTransferCount[_itemId]++;
  }

  function () public payable {
    revert();
  }
}