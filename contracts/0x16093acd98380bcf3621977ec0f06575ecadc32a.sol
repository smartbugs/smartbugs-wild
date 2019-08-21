pragma solidity ^0.4.24;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * See https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address _who) public view returns (uint256);
  function transfer(address _to, uint256 _value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}



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


contract Activatable {
    bool public activated;

    modifier whenActivated {
        require(activated);
        _;
    }

    modifier whenNotActivated {
        require(!activated);
        _;
    }

    function activate() public returns (bool) {
        activated = true;
        return true;
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


contract Contract is Ownable, SupportsInterfaceWithLookup {
    /**
     * @notice this.owner.selector ^ this.renounceOwnership.selector ^ this.transferOwnership.selector
        ^ this.template.selector
     */
    bytes4 public constant InterfaceId_Contract = 0x6125ede5;

    Template public template;

    constructor(address _owner) public {
        require(_owner != address(0));

        template = Template(msg.sender);
        owner = _owner;

        _registerInterface(InterfaceId_Contract);
    }
}







contract Strategy is Contract, Activatable {
    /**
     * @notice this.owner.selector ^ this.renounceOwnership.selector ^ this.transferOwnership.selector
        ^ this.template.selector ^ this.activate.selector
     */
    bytes4 public constant InterfaceId_Strategy = 0x6e301925;

    constructor(address _owner) public Contract(_owner) {
        _registerInterface(InterfaceId_Strategy);
    }

    function activate() onlyOwner public returns (bool) {
        return super.activate();
    }
}



contract SaleStrategy is Strategy {
    /**
     * @notice this.owner.selector ^ this.renounceOwnership.selector ^ this.transferOwnership.selector
        ^ this.template.selector ^ this.activate.selector ^ this.deactivate.selector
        ^ this.started.selector ^ this.successful.selector ^ this.finished.selector
     */
    bytes4 public constant InterfaceId_SaleStrategy = 0x04c8123d;

    Sale public sale;

    constructor(address _owner, Sale _sale) public Strategy(_owner) {
        sale = _sale;

        _registerInterface(InterfaceId_SaleStrategy);
    }

    modifier whenSaleActivated {
        require(sale.activated());
        _;
    }

    modifier whenSaleNotActivated {
        require(!sale.activated());
        _;
    }

    function activate() whenSaleNotActivated public returns (bool) {
        return super.activate();
    }

    function deactivate() onlyOwner whenSaleNotActivated public returns (bool) {
        activated = false;
        return true;
    }

    function started() public view returns (bool);

    function successful() public view returns (bool);

    function finished() public view returns (bool);
}



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






/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function approve(address _spender, uint256 _value) public returns (bool);
  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}















/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) internal balances;

  uint256 internal totalSupply_;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev Transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_value <= balances[msg.sender]);
    require(_to != address(0));

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256) {
    return balances[_owner];
  }

}




/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/issues/20
 * Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);
    require(_to != address(0));

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {
    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {
    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue >= oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}




/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */
contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(
    address _to,
    uint256 _amount
  )
    public
    hasMintPermission
    canMint
    returns (bool)
  {
    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() public onlyOwner canMint returns (bool) {
    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}






/**
 * @title DetailedERC20 token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract DetailedERC20 is ERC20 {
  string public name;
  string public symbol;
  uint8 public decimals;

  constructor(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }
}


contract Boost is MintableToken, DetailedERC20("Boost", "BST", 18) {
}














/**
 * @title Template
 * @notice Template instantiates `Contract`s of the same form.
 */
contract Template is Ownable, SupportsInterfaceWithLookup {
    /**
     * @notice this.owner.selector ^ this.renounceOwnership.selector ^ this.transferOwnership.selector
        ^ this.bytecodeHash.selector ^ this.price.selector ^ this.beneficiary.selector
        ^ this.name.selector ^ this.description.selector ^ this.setNameAndDescription.selector
        ^ this.instantiate.selector
     */
    bytes4 public constant InterfaceId_Template = 0xd48445ff;

    mapping(string => string) nameOfLocale;
    mapping(string => string) descriptionOfLocale;
    /**
     * @notice Hash of EVM bytecode to be instantiated.
     */
    bytes32 public bytecodeHash;
    /**
     * @notice Price to pay when instantiating
     */
    uint public price;
    /**
     * @notice Address to receive payment
     */
    address public beneficiary;

    /**
     * @notice Logged when a new `Contract` instantiated.
     */
    event Instantiated(address indexed creator, address indexed contractAddress);

    /**
     * @param _bytecodeHash Hash of EVM bytecode
     * @param _price Price of instantiating in wei
     * @param _beneficiary Address to transfer _price when instantiating
     */
    constructor(
        bytes32 _bytecodeHash,
        uint _price,
        address _beneficiary
    ) public {
        bytecodeHash = _bytecodeHash;
        price = _price;
        beneficiary = _beneficiary;
        if (price > 0) {
            require(beneficiary != address(0));
        }

        _registerInterface(InterfaceId_Template);
    }

    /**
     * @param _locale IETF language tag(https://en.wikipedia.org/wiki/IETF_language_tag)
     * @return Name in `_locale`.
     */
    function name(string _locale) public view returns (string) {
        return nameOfLocale[_locale];
    }

    /**
     * @param _locale IETF language tag(https://en.wikipedia.org/wiki/IETF_language_tag)
     * @return Description in `_locale`.
     */
    function description(string _locale) public view returns (string) {
        return descriptionOfLocale[_locale];
    }

    /**
     * @param _locale IETF language tag(https://en.wikipedia.org/wiki/IETF_language_tag)
     * @param _name Name to set
     * @param _description Description to set
     */
    function setNameAndDescription(string _locale, string _name, string _description) public onlyOwner {
        nameOfLocale[_locale] = _name;
        descriptionOfLocale[_locale] = _description;
    }

    /**
     * @notice `msg.sender` is passed as first argument for the newly created `Contract`.
     * @param _bytecode Bytecode corresponding to `bytecodeHash`
     * @param _args If arguments where passed to this function, those will be appended to the arguments for `Contract`.
     * @return Newly created contract account's address
     */
    function instantiate(bytes _bytecode, bytes _args) public payable returns (address contractAddress) {
        require(bytecodeHash == keccak256(_bytecode));
        bytes memory calldata = abi.encodePacked(_bytecode, _args);
        assembly {
            contractAddress := create(0, add(calldata, 0x20), mload(calldata))
        }
        if (contractAddress == address(0)) {
            revert("Cannot instantiate contract");
        } else {
            Contract c = Contract(contractAddress);
            // InterfaceId_ERC165
            require(c.supportsInterface(0x01ffc9a7));
            // InterfaceId_Contract
            require(c.supportsInterface(0x6125ede5));

            if (price > 0) {
                require(msg.value == price);
                beneficiary.transfer(msg.value);
            }
            emit Instantiated(msg.sender, contractAddress);
        }
    }
}









contract StrategyTemplate is Template {
    constructor(
        bytes32 _bytecodeHash,
        uint _price,
        address _beneficiary
    ) public
    Template(
        _bytecodeHash,
        _price,
        _beneficiary
    ) {
    }

    function instantiate(bytes _bytecode, bytes _args) public payable returns (address contractAddress) {
        Strategy strategy = Strategy(super.instantiate(_bytecode, _args));
        // InterfaceId_Strategy
        require(strategy.supportsInterface(0x6e301925));
        return strategy;
    }
}



contract SaleStrategyTemplate is StrategyTemplate {
    constructor(
        bytes32 _bytecodeHash,
        uint _price,
        address _beneficiary
    ) public
    StrategyTemplate(
        _bytecodeHash,
        _price,
        _beneficiary
    ) {
    }

    function instantiate(bytes _bytecode, bytes _args) public payable returns (address contractAddress) {
        SaleStrategy strategy = SaleStrategy(super.instantiate(_bytecode, _args));
        // InterfaceId_SaleStrategy
        require(strategy.supportsInterface(0x04c8123d));
        return strategy;
    }
}



contract Sale is Contract, Activatable {
    using SafeMath for uint;

    /**
     * @notice this.owner.selector ^ this.renounceOwnership.selector ^ this.transferOwnership.selector
        ^ this.template.selector ^ this.activate.selector
        ^ this.projectName.selector ^ this.projectSummary.selector ^ this.projectDescription.selector
        ^ this.logoUrl.selector ^ this.coverImageUrl.selector ^ this.websiteUrl.selector ^ this.whitepaperUrl.selector
        ^ this.name.selector ^ this.weiRaised.selector ^ this.withdrawn.selector ^ this.ready.selector
        ^ this.started.selector ^ this.successful.selector ^ this.finished.selector ^ this.paymentOf.selector
        ^ this.update.selector ^ this.addStrategy.selector ^ this.numberOfStrategies.selector ^ this.strategyAt.selector
        ^ this.numberOfActivatedStrategies.selector ^ this.activatedStrategyAt.selector
        ^ this.withdraw.selector ^ this.claimRefund.selector
     */
    bytes4 public constant InterfaceId_Sale = 0x8139792d;

    string public projectName;
    string public projectSummary;
    string public projectDescription;
    string public logoUrl;
    string public coverImageUrl;
    string public websiteUrl;
    string public whitepaperUrl;
    string public name;

    uint256 public weiRaised;
    bool public withdrawn;

    SaleStrategy[] strategies;
    SaleStrategy[] activatedStrategies;
    mapping(address => uint256) paymentOfPurchaser;

    constructor(
        address _owner,
        string _projectName,
        string _name
    ) public Contract(_owner) {
        projectName = _projectName;
        name = _name;

        _registerInterface(InterfaceId_Sale);
    }

    function update(
        string _projectName,
        string _projectSummary,
        string _projectDescription,
        string _logoUrl,
        string _coverImageUrl,
        string _websiteUrl,
        string _whitepaperUrl,
        string _name
    ) public onlyOwner whenNotActivated {
        projectName = _projectName;
        projectSummary = _projectSummary;
        projectDescription = _projectDescription;
        logoUrl = _logoUrl;
        coverImageUrl = _coverImageUrl;
        websiteUrl = _websiteUrl;
        whitepaperUrl = _whitepaperUrl;
        name = _name;
    }

    function addStrategy(SaleStrategyTemplate _template, bytes _bytecode) onlyOwner whenNotActivated public payable {
        // InterfaceId_ERC165
        require(_template.supportsInterface(0x01ffc9a7));
        // InterfaceId_Template
        require(_template.supportsInterface(0xd48445ff));

        require(_isUniqueStrategy(_template));

        bytes memory args = abi.encode(msg.sender, address(this));
        SaleStrategy strategy = SaleStrategy(_template.instantiate.value(msg.value)(_bytecode, args));
        strategies.push(strategy);
    }

    function _isUniqueStrategy(SaleStrategyTemplate _template) private view returns (bool) {
        for (uint i = 0; i < strategies.length; i++) {
            SaleStrategy strategy = strategies[i];
            if (address(strategy.template()) == address(_template)) {
                return false;
            }
        }
        return true;
    }

    function numberOfStrategies() public view returns (uint256) {
        return strategies.length;
    }

    function strategyAt(uint256 index) public view returns (address) {
        return strategies[index];
    }

    function numberOfActivatedStrategies() public view returns (uint256) {
        return activatedStrategies.length;
    }

    function activatedStrategyAt(uint256 index) public view returns (address) {
        return activatedStrategies[index];
    }

    function activate() onlyOwner public returns (bool) {
        for (uint i = 0; i < strategies.length; i++) {
            SaleStrategy strategy = strategies[i];
            if (strategy.activated()) {
                activatedStrategies.push(strategy);
            }
        }
        return super.activate();
    }

    function started() public view returns (bool) {
        if (!activated) return false;

        bool s = false;
        for (uint i = 0; i < activatedStrategies.length; i++) {
            s = s || activatedStrategies[i].started();
        }
        return s;
    }

    function successful() public view returns (bool){
        if (!started()) return false;

        bool s = false;
        for (uint i = 0; i < activatedStrategies.length; i++) {
            s = s || activatedStrategies[i].successful();
        }
        return s;
    }

    function finished() public view returns (bool){
        if (!started()) return false;

        bool f = false;
        for (uint i = 0; i < activatedStrategies.length; i++) {
            f = f || activatedStrategies[i].finished();
        }
        return f;
    }

    function() external payable;

    function increasePaymentOf(address _purchaser, uint256 _weiAmount) internal {
        require(!finished());
        require(started());

        paymentOfPurchaser[_purchaser] = paymentOfPurchaser[_purchaser].add(_weiAmount);
        weiRaised = weiRaised.add(_weiAmount);
    }

    function paymentOf(address _purchaser) public view returns (uint256 weiAmount) {
        return paymentOfPurchaser[_purchaser];
    }

    function withdraw() onlyOwner whenActivated public returns (bool) {
        require(!withdrawn);
        require(finished());
        require(successful());

        withdrawn = true;
        msg.sender.transfer(weiRaised);

        return true;
    }

    function claimRefund() whenActivated public returns (bool) {
        require(finished());
        require(!successful());

        uint256 amount = paymentOfPurchaser[msg.sender];
        require(amount > 0);

        paymentOfPurchaser[msg.sender] = 0;
        msg.sender.transfer(amount);

        return true;
    }
}





contract SaleTemplate is Template {
    constructor(
        bytes32 _bytecodeHash,
        uint _price,
        address _beneficiary
    ) public
    Template(
        _bytecodeHash,
        _price,
        _beneficiary
    ) {
    }

    function instantiate(bytes _bytecode, bytes _args) public payable returns (address contractAddress) {
        Sale sale = Sale(super.instantiate(_bytecode, _args));
        // InterfaceId_Sale
        require(sale.supportsInterface(0x8139792d));
        return sale;
    }
}


contract Raiser is ERC721Token("Raiser", "RAI"), Ownable {
    using SafeMath for uint256;

    event Mint(address indexed to, uint256 tokenId);

    uint256 public constant HALVING_WEI = 21000000 * (10 ** 18);
    uint256 public constant MAX_HALVING_ERA = 20;

    Boost public boost;
    uint256 public rewardEra = 0;

    uint256 weiUntilNextHalving = HALVING_WEI;
    mapping(uint256 => Sale) saleOfTokenId;
    mapping(uint256 => string) slugOfTokenId;
    mapping(uint256 => mapping(address => uint256)) rewardedBoostsOfSomeoneOfTokenId;

    constructor(Boost _boost) public {
        boost = _boost;
    }

    function mint(string _slug, SaleTemplate _template, bytes _bytecode, bytes _args) public payable {
        // InterfaceId_ERC165
        require(_template.supportsInterface(0x01ffc9a7));
        // InterfaceId_Template
        require(_template.supportsInterface(0xd48445ff));

        uint256 tokenId = toTokenId(_slug);
        require(address(saleOfTokenId[tokenId]) == address(0));

        Sale sale = Sale(_template.instantiate.value(msg.value)(_bytecode, _args));
        saleOfTokenId[tokenId] = sale;
        slugOfTokenId[tokenId] = _slug;

        _mint(msg.sender, tokenId);
        emit Mint(msg.sender, tokenId);
    }

    function toTokenId(string _slug) public pure returns (uint256 tokenId) {
        bytes memory chars = bytes(_slug);
        require(chars.length > 0, "String is empty.");
        for (uint i = 0; i < _min(chars.length, 32); i++) {
            uint c = uint(chars[i]);
            require(0x61 <= c && c <= 0x7a || c == 0x2d, "String must contain only lowercase alphabets or hyphens.");
        }
        assembly {
            tokenId := mload(add(chars, 32))
        }
    }

    function slugOf(uint256 _tokenId) public view returns (string slug) {
        return slugOfTokenId[_tokenId];
    }

    function saleOf(uint256 _tokenId) public view returns (Sale sale) {
        return saleOfTokenId[_tokenId];
    }

    function claimableBoostsOf(uint256 _tokenId) public view returns (uint256 boosts, uint256 newRewardEra, uint256 newWeiUntilNextHalving) {
        if (rewardedBoostsOfSomeoneOfTokenId[_tokenId][msg.sender] > 0) {
            return (0, rewardEra, weiUntilNextHalving);
        }

        Sale sale = saleOfTokenId[_tokenId];
        require(address(sale) != address(0));
        require(sale.finished());

        uint256 weiAmount = sale.paymentOf(msg.sender);
        if (sale.owner() == msg.sender) {
            weiAmount = weiAmount.add(sale.weiRaised());
        }
        return _weiToBoosts(weiAmount);
    }

    function claimBoostsOf(uint256 _tokenId) public returns (bool) {
        (uint256 boosts, uint256 newRewardEra, uint256 newWeiUntilNextHalving) = claimableBoostsOf(_tokenId);
        rewardEra = newRewardEra;
        weiUntilNextHalving = newWeiUntilNextHalving;
        if (boosts > 0) {
            boost.mint(msg.sender, boosts);
        }
        rewardedBoostsOfSomeoneOfTokenId[_tokenId][msg.sender] = boosts;
        return true;
    }

    function rewardedBoostsOf(uint256 _tokenId) public view returns (uint256 boosts) {
        return rewardedBoostsOfSomeoneOfTokenId[_tokenId][msg.sender];
    }

    function claimableBoosts() public view returns (uint256 boosts, uint256 newRewardEra, uint256 newWeiUntilNextHalving) {
        for (uint i = 0; i < totalSupply(); i++) {
            uint256 tokenId = tokenByIndex(i);
            (uint256 b, uint256 r, uint256 w) = claimableBoostsOf(tokenId);
            boosts = boosts.add(b);
            newRewardEra = r;
            newWeiUntilNextHalving = w;
        }
    }

    function claimBoosts() public returns (bool) {
        for (uint i = 0; i < totalSupply(); i++) {
            uint256 tokenId = tokenByIndex(i);
            claimBoostsOf(tokenId);
        }
        return true;
    }

    function rewardedBoosts() public view returns (uint256 boosts) {
        for (uint i = 0; i < totalSupply(); i++) {
            uint256 tokenId = tokenByIndex(i);
            boosts = boosts.add(rewardedBoostsOf(tokenId));
        }
    }

    function boostsUntilNextHalving() public view returns (uint256) {
        (uint256 boosts,,) = _weiToBoosts(weiUntilNextHalving);
        return boosts;
    }

    function _weiToBoosts(uint256 _weiAmount) private view returns (uint256 boosts, uint256 newRewardEra, uint256 newWeiUntilNextHalving) {
        if (rewardEra > MAX_HALVING_ERA) {
            return (0, rewardEra, weiUntilNextHalving);
        }
        uint256 amount = _weiAmount;
        boosts = 0;
        newRewardEra = rewardEra;
        newWeiUntilNextHalving = weiUntilNextHalving;
        while (amount > 0) {
            uint256 a = _min(amount, weiUntilNextHalving);
            boosts = boosts.add(a.mul(2 ** (MAX_HALVING_ERA.sub(newRewardEra)).div(1000)));
            amount = amount.sub(a);
            newWeiUntilNextHalving = newWeiUntilNextHalving.sub(a);
            if (newWeiUntilNextHalving == 0) {
                newWeiUntilNextHalving = HALVING_WEI;
                newRewardEra += 1;
            }
        }
    }

    function _min(uint256 _a, uint256 _b) private pure returns (uint256) {
        return _a < _b ? _a : _b;
    }
}