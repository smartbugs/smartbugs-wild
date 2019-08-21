pragma solidity ^0.4.20; // solhint-disable-line

/// @title A standard interface for non-fungible tokens.
/// @author Dieter Shirley <dete@axiomzen.co>
contract ERC721 {
  // Required methods
  function approve(address _to, uint256 _tokenId) public;
  function balanceOf(address _owner) public view returns (uint256 balance);
  function implementsERC721() public pure returns (bool);
  function ownerOf(uint256 _tokenId) public view returns (address addr);
  function takeOwnership(uint256 _tokenId) public;
  function totalSupply() public view returns (uint256 total);
  function transferFrom(address _from, address _to, uint256 _tokenId) public;
  function transfer(address _to, uint256 _tokenId) public;

  event Transfer(address indexed from, address indexed to, uint256 tokenId);
  event Approval(address indexed owner, address indexed approved, uint256 tokenId);
}

/// @title ViralLo.vin, Creator token smart contract
/// @author Sam Morris <hi@sam.viralo.vin>
contract ViralLovinCreatorToken is ERC721 {

  /*** EVENTS ***/

  /// @dev The Birth event is fired whenever a new Creator is created
  event Birth(
      uint256 tokenId, 
      string name, 
      address owner, 
      uint256 collectiblesOrdered
    );

  /// @dev The TokenSold event is fired whenever a token is sold.
  event TokenSold(
      uint256 tokenId, 
      uint256 oldPrice, 
      uint256 newPrice, 
      address prevOwner, 
      address winner, 
      string name, 
      uint256 collectiblesOrdered
    );

  /// @dev Transfer event as defined in current draft of ERC721. 
  ///  ownership is assigned, including births.
  event Transfer(address from, address to, uint256 tokenId);

  /*** CONSTANTS ***/

  /// @notice Name and symbol of the non fungible token, as defined in ERC721.
  string public constant NAME = "ViralLovin Creator Token"; // solhint-disable-line
  string public constant SYMBOL = "CREATOR"; // solhint-disable-line

  uint256 private startingPrice = 0.001 ether;

  /*** STORAGE ***/

  /// @dev A mapping from Creator IDs to the address that owns them. 
  /// All Creators have some valid owner address.
  mapping (uint256 => address) public creatorIndexToOwner;

  /// @dev A mapping from owner address to count of tokens that address owns.
  //  Used internally inside balanceOf() to resolve ownership count.
  mapping (address => uint256) private ownershipTokenCount;

  /// @dev A mapping from Creator IDs to an address that has been approved to call
  ///  transferFrom(). Each Creator can only have one approved address for transfer
  ///  at any time. A zero value means no approval is outstanding.
  mapping (uint256 => address) public creatorIndexToApproved;

  // @dev A mapping from creator IDs to the price of the token.
  mapping (uint256 => uint256) private creatorIndexToPrice;

  // The addresses that can execute actions within each roles.
  address public ceoAddress;
  address public cooAddress;

  uint256 public creatorsCreatedCount;

  /*** DATATYPES ***/
  struct Creator {
    string name;
    uint256 collectiblesOrdered;
  }

  Creator[] private creators;

  /*** ACCESS MODIFIERS ***/
  
  /// @dev Access modifier for CEO-only functionality
  modifier onlyCEO() {
    require(msg.sender == ceoAddress);
    _;
  }

  /// @dev Access modifier for COO-only functionality
  modifier onlyCOO() {
    require(msg.sender == cooAddress);
    _;
  }

  /// Access modifier for contract owner only functionality
  modifier onlyCLevel() {
    require(
      msg.sender == ceoAddress ||
      msg.sender == cooAddress
    );
    _;
  }

  /*** CONSTRUCTOR ***/
  
  function ViralLovinCreatorToken() public {
    ceoAddress = msg.sender;
    cooAddress = msg.sender;
  }

  /*** PUBLIC FUNCTIONS ***/
  
  /// @notice Grant another address the right to transfer token via takeOwnership() and transferFrom().
  /// @param _to The address to be granted transfer approval. Pass address(0) to clear all approvals.
  /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
  /// @dev Required for ERC-721 compliance.
  function approve(address _to, uint256 _tokenId) public {
    // Caller must own token.
    require(_owns(msg.sender, _tokenId));
    creatorIndexToApproved[_tokenId] = _to;
    Approval(msg.sender, _to, _tokenId);
  }

  /// For querying balance of a particular account
  /// @param _owner The address for balance query
  /// @dev Required for ERC-721 compliance.
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return ownershipTokenCount[_owner];
  }

  /// @dev Creates a new Creator with the given name, price, and the total number of collectibles ordered then assigns to an address.
  function createCreator(
      address _owner, 
      string _name, 
      uint256 _price, 
      uint256 _collectiblesOrdered
    ) public onlyCOO {
    address creatorOwner = _owner;
    if (creatorOwner == address(0)) {
      creatorOwner = cooAddress;
    }

    if (_price <= 0) {
      _price = startingPrice;
    }

    creatorsCreatedCount++;
    _createCreator(_name, creatorOwner, _price, _collectiblesOrdered);
    }

  /// @notice Returns all the information about Creator token.
  /// @param _tokenId The tokenId of the Creator token.
  function getCreator(
      uint256 _tokenId
    ) public view returns (
        string creatorName, 
        uint256 sellingPrice, 
        address owner, 
        uint256 collectiblesOrdered
    ) {
    Creator storage creator = creators[_tokenId];
    creatorName = creator.name;
    collectiblesOrdered = creator.collectiblesOrdered;
    sellingPrice = creatorIndexToPrice[_tokenId];
    owner = creatorIndexToOwner[_tokenId];
  }

  function implementsERC721() public pure returns (bool) {
    return true;
  }

  /// @dev For ERC-721 compliance.
  function name() public pure returns (string) {
    return NAME;
  }

  /// For querying owner of a token
  /// @param _tokenId The tokenID
  /// @dev Required for ERC-721 compliance.
  function ownerOf(uint256 _tokenId) public view returns (address owner)
  {
    owner = creatorIndexToOwner[_tokenId];
    require(owner != address(0));
  }

  /// For contract payout
  function payout(address _to) public onlyCLevel {
    require(_addressNotNull(_to));
    _payout(_to);
  }

  /// Allows someone to obtain the token
  function purchase(uint256 _tokenId) public payable {
    address oldOwner = creatorIndexToOwner[_tokenId];
    address newOwner = msg.sender;
    uint256 sellingPrice = creatorIndexToPrice[_tokenId];

    // Safety check to prevent against an unexpected 0x0 default.
    require(_addressNotNull(newOwner));

    // Making sure sent amount is greater than or equal to the sellingPrice
    require(msg.value >= sellingPrice);

    // Transfer contract to new owner
    _transfer(oldOwner, newOwner, _tokenId);

    // Transfer payment to VL
    ceoAddress.transfer(sellingPrice);

    // Emits TokenSold event
    TokenSold(
        _tokenId, 
        sellingPrice, 
        creatorIndexToPrice[_tokenId], 
        oldOwner, 
        newOwner, 
        creators[_tokenId].name, 
        creators[_tokenId].collectiblesOrdered
    );
  }

  function priceOf(uint256 _tokenId) public view returns (uint256 price) {
    return creatorIndexToPrice[_tokenId];
  }

  /// @dev Assigns a new address to act as the CEO. Only available to the current CEO.
  /// @param _newCEO The address of the new CEO
  function setCEO(address _newCEO) public onlyCEO {
    require(_newCEO != address(0));
    ceoAddress = _newCEO;
  }

  /// @dev Assigns a new address to act as the COO. Only available to the current CEO.
  /// @param _newCOO The address of the new COO
  function setCOO(address _newCOO) public onlyCEO {
    require(_newCOO != address(0));
    cooAddress = _newCOO;
  }

  /// @dev For ERC-721 compliance.
  function symbol() public pure returns (string) {
    return SYMBOL;
  }

  /// @notice Allow pre-approved user to take ownership of a token
  /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
  /// @dev Required for ERC-721 compliance.
  function takeOwnership(uint256 _tokenId) public {
    address newOwner = msg.sender;
    address oldOwner = creatorIndexToOwner[_tokenId];

    // Safety check to prevent against an unexpected 0x0 default.
    require(_addressNotNull(newOwner));

    // Making sure transfer is approved
    require(_approved(newOwner, _tokenId));

    _transfer(oldOwner, newOwner, _tokenId);
  }

  /// @param _owner Creator tokens belonging to the owner.
  /// @dev Expensive; not to be called by smart contract. Walks the collectibes array looking for Creator tokens belonging to owner.
  function tokensOfOwner(
      address _owner
      ) public view returns(uint256[] ownerTokens) {
    uint256 tokenCount = balanceOf(_owner);
    if (tokenCount == 0) {
        // Return an empty array
      return new uint256[](0);
    } else {
      uint256[] memory result = new uint256[](tokenCount);
      uint256 totalCreators = totalSupply();
      uint256 resultIndex = 0;
      uint256 creatorId;
      for (creatorId = 0; creatorId <= totalCreators; creatorId++) {
        if (creatorIndexToOwner[creatorId] == _owner) {
          result[resultIndex] = creatorId;
          resultIndex++;
        }
      }
      return result;
    }
  }

  /// For querying totalSupply of token
  /// @dev Required for ERC-721 compliance.
  function totalSupply() public view returns (uint256 total) {
    return creators.length;
  }

  /// Owner initates the transfer of the token to another account
  /// @param _to The address for the token to be transferred to.
  /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
  /// @dev Required for ERC-721 compliance.
  function transfer(address _to, uint256 _tokenId) public {
    require(_owns(msg.sender, _tokenId));
    require(_addressNotNull(_to));
    _transfer(msg.sender, _to, _tokenId);
  }

  /// Initiates transfer of token from address _from to address _to
  /// @param _from The address for the token to be transferred from.
  /// @param _to The address for the token to be transferred to.
  /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
  /// @dev Required for ERC-721 compliance.
  function transferFrom(address _from, address _to, uint256 _tokenId) public {
    require(_owns(_from, _tokenId));
    require(_approved(_to, _tokenId));
    require(_addressNotNull(_to));

    _transfer(_from, _to, _tokenId);
  }

  /*** PRIVATE FUNCTIONS ***/
  
  /// Safety check on _to address to prevent against an unexpected 0x0 default.
  function _addressNotNull(address _to) private pure returns (bool) {
    return _to != address(0);
  }

  /// For checking approval of transfer for address _to
  function _approved(
      address _to, 
      uint256 _tokenId
      ) private view returns (bool) {
    return creatorIndexToApproved[_tokenId] == _to;
  }

  /// For creating a Creator
  function _createCreator(
      string _name, 
      address _owner, 
      uint256 _price, 
      uint256 _collectiblesOrdered
      ) private {
    Creator memory _creator = Creator({
      name: _name,
      collectiblesOrdered: _collectiblesOrdered
    });
    uint256 newCreatorId = creators.push(_creator) - 1;

    require(newCreatorId == uint256(uint32(newCreatorId)));

    Birth(newCreatorId, _name, _owner, _collectiblesOrdered);

    creatorIndexToPrice[newCreatorId] = _price;

    // This will assign ownership, and also emit the Transfer event as per ERC721 draft
    _transfer(address(0), _owner, newCreatorId);
  }

  /// Check for token ownership
  function _owns(
      address claimant, 
      uint256 _tokenId
      ) private view returns (bool) {
    return claimant == creatorIndexToOwner[_tokenId];
  }

  /// For paying out the full balance of contract
  function _payout(address _to) private {
    if (_to == address(0)) {
      ceoAddress.transfer(this.balance);
    } else {
      _to.transfer(this.balance);
    }
  }

  /// @dev Assigns ownership of Creator token to an address.
  function _transfer(address _from, address _to, uint256 _tokenId) private {
    // increment owner token count
    ownershipTokenCount[_to]++;
    // transfer ownership
    creatorIndexToOwner[_tokenId] = _to;

    // When creating new creators _from is 0x0, we can't account that address.
    if (_from != address(0)) {
      ownershipTokenCount[_from]--;
      // clear any previously approved ownership
      delete creatorIndexToApproved[_tokenId];
    }

    // Emit the transfer event.
    Transfer(_from, _to, _tokenId);
  }
  
}