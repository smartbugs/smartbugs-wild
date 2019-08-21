pragma solidity ^0.4.24;

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

contract AvatarItemOperator is Operator {

  enum ItemRarity{
    RARITY_LIMITED,
    RARITY_OTEHR
  }

  event ItemCreated(address indexed _owner, uint256 _itemId, ItemRarity _type);
 
  event UpdateLimitedItemCount(bytes8 _hash, uint256 _maxCount);

  // item hash => max value 
  mapping(bytes8 => uint256) internal itemLimitedCount;
  // token id => position
  mapping(uint256 => uint256) internal itemPosition;
  // item hash => index
  mapping(bytes8 => uint256) internal itemIndex;

  AvatarItemService internal itemService;
  ERC721 internal ERC721Service;

  constructor() public {
    _setDefaultLimitedItem();
  }

  function injectItemService(AvatarItemService _itemService) external onlyOwner {
    itemService = AvatarItemService(_itemService);
    ERC721Service = ERC721(_itemService);
  }

  function getOwnedItems() external view returns(uint256[] _itemIds) {
    return itemService.getOwnedItems(msg.sender);
  }

  function getItemInfo(uint256 _itemId)
    external 
    view 
    returns(string, string, bool, uint256[4] _attr1, uint8[5] _attr2, uint16[2] _attr3) {
    return itemService.getItemInfo(_itemId);
  }

  function getSameItemCount(uint256 _itemId) external view returns(uint256){
    return itemService.getSameItemCount(_itemId);
  }

  function getSameItemIdByIndex(uint256 _itemId, uint256 _index) external view returns(uint256){
    return itemService.getSameItemIdByIndex(_itemId, _index);
  }

  function getItemHash(uint256 _itemId) external view  returns (bytes8) {
    return itemService.getItemHash(_itemId);
  }

  function isSameItem(uint256 _itemId1, uint256 _itemId2) external view returns (bool) {
    return itemService.isSameItem(_itemId1,_itemId2);
  }

  function getLimitedValue(uint256 _itemId) external view returns(uint256) {
    return itemLimitedCount[itemService.getItemHash(_itemId)];
  }
  // return the item position when get it in all same items
  function getItemPosition(uint256 _itemId) external view returns (uint256 _pos) {
    require(ERC721Service.ownerOf(_itemId) != address(0), "token not exist");
    _pos = itemPosition[_itemId];
  }

  function updateLimitedItemCount(bytes8 _itemBytes8, uint256 _count) public onlyOperator {
    itemLimitedCount[_itemBytes8] = _count;
    emit UpdateLimitedItemCount(_itemBytes8, _count);
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
    require(_attr3[0] >= 0 && _attr3[0] <= 10000, "param must be range to 0 ~ 10000 ");
    require(_attr3[1] >= 0 && _attr3[1] <= 10000, "param must be range to 0 ~ 10000 ");
    _itemId = _mintItem(_owner, _founder, _creator, _isBitizenItem, _attr1, _attr2, _attr3);
  }

  // add limited item check 
  function _mintItem( 
    address _owner,
    string _founder,
    string _creator,
    bool _isBitizenItem,
    uint256[4] _attr1,
    uint8[5] _attr2,
    uint16[2] _attr3) 
    internal 
    returns(uint256) {
    uint256 tokenId = itemService.createItem(_owner, _founder, _creator, _isBitizenItem, _attr1, _attr2, _attr3);
    bytes8 itemHash = itemService.getItemHash(tokenId);
    _saveItemIndex(itemHash, tokenId);
    if(itemLimitedCount[itemHash] > 0){
      require(itemService.getSameItemCount(tokenId) <= itemLimitedCount[itemHash], "overflow");  // limited item
      emit ItemCreated(_owner, tokenId, ItemRarity.RARITY_LIMITED);
    } else {
      emit ItemCreated(_owner, tokenId,  ItemRarity.RARITY_OTEHR);
    }
    return tokenId;
  }

  function _saveItemIndex(bytes8 _itemHash, uint256 _itemId) private {
    itemIndex[_itemHash]++;
    itemPosition[_itemId] = itemIndex[_itemHash];
  }

  function _setDefaultLimitedItem() private {
    itemLimitedCount[0xc809275c18c405b7] = 3;     //  Pioneer‘s Compass
    itemLimitedCount[0x7cb371a84bb16b98] = 100;   //  Pioneer of the Wild Hat
    itemLimitedCount[0x26a27c8bf9dd554b] = 100;   //  Pioneer of the Wild Top 
    itemLimitedCount[0xa8c29099f2421c0b] = 100;   //  Pioneer of the Wild Pant
    itemLimitedCount[0x8060b7c58dce9548] = 100;   //  Pioneer of the Wild Shoes
    itemLimitedCount[0x4f7d254af1d033cf] = 25;    //  Pioneer of the Skies Hat
    itemLimitedCount[0x19b6d994c1491e27] = 25;    //  Pioneer of the Skies Top
    itemLimitedCount[0x71e84d6ef1cf6c85] = 25;    //  Pioneer of the Skies Shoes
    itemLimitedCount[0xff5f095a3a3b990f] = 25;    //  Pioneer of the Skies Pant
    itemLimitedCount[0xa066c007ef8c352c] = 1;     //  Pioneer of the Cyberspace Hat
    itemLimitedCount[0x1029368269e054d5] = 1;     //  Pioneer of the Cyberspace Top
    itemLimitedCount[0xfd0e74b52734b343] = 1;     //  Pioneer of the Cyberspace Pant
    itemLimitedCount[0xf5974771adaa3a6b] = 1;     //  Pioneer of the Cyberspace Shoes
    itemLimitedCount[0x405b16d28c964f69] = 10;    //  Pioneer of the Seas Hat
    itemLimitedCount[0x8335384d55547989] = 10;    //  Pioneer of the Seas Top
    itemLimitedCount[0x679a5e1e0312d35a] = 10;    //  Pioneer of the Seas Pant
    itemLimitedCount[0xe3d973cce112f782] = 10;    //  Pioneer of the Seas Shoes
    itemLimitedCount[0xcde6284740e5fde9] = 50;    //  DAPP T-Shirt
  }

  function () public {
    revert();
  }
}