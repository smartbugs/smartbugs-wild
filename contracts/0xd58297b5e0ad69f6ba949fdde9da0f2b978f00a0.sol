pragma solidity ^0.4.18;

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


contract Dogs {
  using SafeMath for uint256;
  /*** EVENTS ***/
  /// @dev The Birth event is fired whenever a new collectible comes into existence.
  event Birth(uint256 tokenId, uint256 startPrice);
  /// @dev The TokenSold event is fired whenever a token is sold.
  event TokenSold(uint256 indexed tokenId, uint256 price, address prevOwner, address winner);
  // ERC721 Transfer
  event Transfer(address indexed from, address indexed to, uint256 tokenId);
  // ERC721 Approval
  event Approval(address indexed owner, address indexed approved, uint256 tokenId);

  /*** CONSTANTS ***/

  string public constant NAME = "dogs-youCollect";
  string public constant SYMBOL = "DYC";
  uint256[] private tokens;

  /*** STORAGE ***/

  /// @dev A mapping from collectible IDs to the address that owns them. All collectibles have
  ///  some valid owner address.
  mapping (uint256 => address) public collectibleIndexToOwner;

  /// @dev A mapping from CollectibleIDs to an address that has been approved to call
  ///  transferFrom(). Each Collectible can only have one approved address for transfer
  ///  at any time. A zero value means no approval is outstanding.
  mapping (uint256 => address) public collectibleIndexToApproved;

  // @dev A mapping from CollectibleIDs to the price of the token.
  mapping (uint256 => uint256) public collectibleIndexToPrice;

  // The addresses of the accounts (or contracts) that can execute actions within each roles.
  address public ceoAddress;
  address public cooAddress;

  mapping (uint => address) private subTokenCreator;
  mapping (uint => address) private lastSubTokenBuyer;

  uint8 constant BASE_TOKEN_ID = 0;
  uint16 constant MAX_SETS_INDEX = 10000;
  uint64 constant FIFTY_TOKENS_INDEX = 1000000000000000;
  uint128 constant TRIBLE_TOKENS_INDEX = 100000000000000000000000;
  uint128 constant DOUBLE_TOKENS_INDEX = 100000000000000000000000000000000;
  uint256 private constant PROMO_CREATION_LIMIT = 50000;
  uint256 public promoCreatedCount;
  uint256 constant START_PRICE_DOG = 1 finney;
  uint256 constant START_PRICE_SETS = 100 finney;
  uint256 constant START_PRICE_BASE_DOG = 10 ether;


  /*** CONSTRUCTOR ***/
  function Dogs() public {
    ceoAddress = msg.sender;
    cooAddress = msg.sender;
  }
  function getTotalSupply() public view returns (uint) {
    return tokens.length;
  }
  function getInitialPriceOfToken(uint _tokenId) public pure returns (uint) {
    if (_tokenId > MAX_SETS_INDEX)
      return START_PRICE_DOG;
    if (_tokenId > 0)
      return START_PRICE_SETS;
    return START_PRICE_BASE_DOG;
  }

  function getNextPrice(uint price, uint _tokenId) public pure returns (uint) {
    if (_tokenId>DOUBLE_TOKENS_INDEX)
      return price.mul(2);
    if (_tokenId>TRIBLE_TOKENS_INDEX)
      return price.mul(3);
    if (_tokenId>FIFTY_TOKENS_INDEX)
      return price.mul(3).div(2);
    if (price < 1.2 ether)
      return price.mul(200).div(92);
    if (price < 5 ether)
      return price.mul(150).div(92);
    return price.mul(120).div(92);
  }

  function buyToken(uint _tokenId) public payable {
    address oldOwner = collectibleIndexToOwner[_tokenId];
    require(oldOwner!=msg.sender);
    uint256 sellingPrice = collectibleIndexToPrice[_tokenId];
    if (sellingPrice==0) {
      sellingPrice = getInitialPriceOfToken(_tokenId);
      if (_tokenId>MAX_SETS_INDEX)
        subTokenCreator[_tokenId] = msg.sender;
    }

    require(msg.value >= sellingPrice);
    uint256 purchaseExcess = msg.value.sub(sellingPrice);

    uint256 payment = sellingPrice.mul(92).div(100);
    uint256 feeOnce = sellingPrice.sub(payment).div(8);

    // transfer taxes
    if (_tokenId > 0) {
      if (collectibleIndexToOwner[BASE_TOKEN_ID]!=address(0))
        collectibleIndexToOwner[BASE_TOKEN_ID].transfer(feeOnce);
      if (_tokenId > MAX_SETS_INDEX) {
        if (collectibleIndexToOwner[_tokenId % MAX_SETS_INDEX]!=address(0))
          collectibleIndexToOwner[_tokenId % MAX_SETS_INDEX].transfer(feeOnce);
        if (subTokenCreator[_tokenId]!=address(0))
          subTokenCreator[_tokenId].transfer(feeOnce);

        lastSubTokenBuyer[BASE_TOKEN_ID] = msg.sender;
        lastSubTokenBuyer[_tokenId % MAX_SETS_INDEX] = msg.sender;
      } else {
        lastSubTokenBuyer[_tokenId].transfer(feeOnce*2);
      }
    } else {
      lastSubTokenBuyer[_tokenId].transfer(feeOnce*2);
    }
    // Transfers the Token
    collectibleIndexToOwner[_tokenId] = msg.sender;
    if (oldOwner != address(0)) {
      // Payment for old owner
      oldOwner.transfer(payment);
      // clear any previously approved ownership exchange
      delete collectibleIndexToApproved[_tokenId];
    } else {
      Birth(_tokenId, sellingPrice);
      tokens.push(_tokenId);
    }
    // Update prices
    collectibleIndexToPrice[_tokenId] = getNextPrice(sellingPrice, _tokenId);

    TokenSold(_tokenId, sellingPrice, oldOwner, msg.sender);
    Transfer(oldOwner, msg.sender, _tokenId);
    // refund when paid too much
    if (purchaseExcess>0)
      msg.sender.transfer(purchaseExcess);
  }



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

  /*** PUBLIC FUNCTIONS ***/
  /// @notice Grant another address the right to transfer token via takeOwnership() and transferFrom().
  /// @param _to The address to be granted transfer approval. Pass address(0) to
  ///  clear all approvals.
  /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
  /// @dev Required for ERC-721 compliance.
  function approve(
    address _to,
    uint256 _tokenId
  ) public {
    // Caller must own token.
    require(_owns(msg.sender, _tokenId));

    collectibleIndexToApproved[_tokenId] = _to;

    Approval(msg.sender, _to, _tokenId);
  }

  /// @dev Creates a new promo collectible with the given name, with given _price and assignes it to an address.
  function createPromoCollectible(uint256 tokenId, address _owner, uint256 _price) public onlyCOO {
    require(collectibleIndexToOwner[tokenId]==address(0));
    require(promoCreatedCount < PROMO_CREATION_LIMIT);

    address collectibleOwner = _owner;
    if (collectibleOwner == address(0)) {
      collectibleOwner = cooAddress;
    }

    if (_price <= 0) {
      _price = getInitialPriceOfToken(tokenId);
    }

    promoCreatedCount++;
    _createCollectible(tokenId, _price);
    subTokenCreator[tokenId] = collectibleOwner;
    // This will assign ownership, and also emit the Transfer event as
    // per ERC721 draft
    _transfer(address(0), collectibleOwner, tokenId);

  }

  bool isChangePriceLocked = true;
  // allows owners of tokens to decrease the price of them or if there is no owner the coo can do it
  function changePrice(uint256 newPrice, uint256 _tokenId) public {
    require((_owns(msg.sender, _tokenId) && !isChangePriceLocked) || (_owns(address(0), _tokenId) && msg.sender == cooAddress));
    require(newPrice<collectibleIndexToPrice[_tokenId]);
    collectibleIndexToPrice[_tokenId] = newPrice;
  }
  function unlockPriceChange() public onlyCOO {
    isChangePriceLocked = false;
  }

  /// @notice Returns all the relevant information about a specific collectible.
  /// @param _tokenId The tokenId of the collectible of interest.
  function getToken(uint256 _tokenId) public view returns (uint256 tokenId, uint256 sellingPrice, address owner, uint256 nextSellingPrice) {
    tokenId = _tokenId;
    sellingPrice = collectibleIndexToPrice[_tokenId];
    if (sellingPrice == 0)
      sellingPrice = getInitialPriceOfToken(_tokenId);
    owner = collectibleIndexToOwner[_tokenId];
    nextSellingPrice = getNextPrice(sellingPrice, _tokenId);
  }

  function implementsERC721() public pure returns (bool) {
    return true;
  }

  /// @dev Required for ERC-721 compliance.
  function name() public pure returns (string) {
    return NAME;
  }

  /// For querying owner of token
  /// @param _tokenId The tokenID for owner inquiry
  /// @dev Required for ERC-721 compliance.
  function ownerOf(uint256 _tokenId)
    public
    view
    returns (address owner)
  {
    owner = collectibleIndexToOwner[_tokenId];
    require(owner != address(0));
  }

  function payout(address _to) public onlyCLevel {
    _payout(_to);
  }


  function priceOf(uint256 _tokenId) public view returns (uint256 price) {
    price = collectibleIndexToPrice[_tokenId];
    if (price == 0)
      price = getInitialPriceOfToken(_tokenId);
  }

  /// @dev Assigns a new address to act as the CEO. Only available to the current CEO.
  /// @param _newCEO The address of the new CEO
  function setCEO(address _newCEO) public onlyCEO {
    require(_newCEO != address(0));

    ceoAddress = _newCEO;
  }

  /// @dev Assigns a new address to act as the COO. Only available to the current COO.
  /// @param _newCOO The address of the new COO
  function setCOO(address _newCOO) public onlyCEO {
    require(_newCOO != address(0));

    cooAddress = _newCOO;
  }

  /// @dev Required for ERC-721 compliance.
  function symbol() public pure returns (string) {
    return SYMBOL;
  }

  /// @notice Allow pre-approved user to take ownership of a token
  /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
  /// @dev Required for ERC-721 compliance.
  function takeOwnership(uint256 _tokenId) public {
    address newOwner = msg.sender;
    address oldOwner = collectibleIndexToOwner[_tokenId];

    // Safety check to prevent against an unexpected 0x0 default.
    require(_addressNotNull(newOwner));

    // Making sure transfer is approved
    require(_approved(newOwner, _tokenId));

    _transfer(oldOwner, newOwner, _tokenId);
  }

  /// Owner initates the transfer of the token to another account
  /// @param _to The address for the token to be transferred to.
  /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
  /// @dev Required for ERC-721 compliance.
  function transfer(
    address _to,
    uint256 _tokenId
  ) public {
    require(_owns(msg.sender, _tokenId));
    require(_addressNotNull(_to));

    _transfer(msg.sender, _to, _tokenId);
  }

  /// Third-party initiates transfer of token from address _from to address _to
  /// @param _from The address for the token to be transferred from.
  /// @param _to The address for the token to be transferred to.
  /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
  /// @dev Required for ERC-721 compliance.
  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  ) public {
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
  function _approved(address _to, uint256 _tokenId) private view returns (bool) {
    return collectibleIndexToApproved[_tokenId] == _to;
  }

  /// For creating Collectible
  function _createCollectible(uint256 tokenId, uint256 _price) private {
    collectibleIndexToPrice[tokenId] = _price;
    Birth(tokenId, _price);
    tokens.push(tokenId);
  }

  /// Check for token ownership
  function _owns(address claimant, uint256 _tokenId) private view returns (bool) {
    return claimant == collectibleIndexToOwner[_tokenId];
  }

  /// For paying out balance on contract
  function _payout(address _to) private {
    if (_to == address(0)) {
      ceoAddress.transfer(this.balance);
    } else {
      _to.transfer(this.balance);
    }
  }

  /// For querying balance of a particular account
  /// @param _owner The address for balance query
  /// @dev Required for ERC-721 compliance.
  function balanceOf(address _owner) public view returns (uint256 result) {
      uint256 totalTokens = tokens.length;
      uint256 tokenIndex;
      uint256 tokenId;
      result = 0;
      for (tokenIndex = 0; tokenIndex < totalTokens; tokenIndex++) {
        tokenId = tokens[tokenIndex];
        if (collectibleIndexToOwner[tokenId] == _owner) {
          result = result.add(1);
        }
      }
      return result;
  }

  /// @dev Assigns ownership of a specific Collectible to an address.
  function _transfer(address _from, address _to, uint256 _tokenId) private {
    //transfer ownership
    collectibleIndexToOwner[_tokenId] = _to;

    // When creating new collectibles _from is 0x0, but we can't account that address.
    if (_from != address(0)) {
      // clear any previously approved ownership exchange
      delete collectibleIndexToApproved[_tokenId];
    }

    // Emit the transfer event.
    Transfer(_from, _to, _tokenId);
  }


   /// @param _owner The owner whose celebrity tokens we are interested in.
  /// @dev This method MUST NEVER be called by smart contract code. First, it's fairly
  ///  expensive (it walks the entire tokens array looking for tokens belonging to owner),
  ///  but it also returns a dynamic array, which is only supported for web3 calls, and
  ///  not contract-to-contract calls.
  function tokensOfOwner(address _owner) public view returns(uint256[] ownerTokens) {
    uint256 tokenCount = balanceOf(_owner);
    if (tokenCount == 0) {
        // Return an empty array
      return new uint256[](0);
    } else {
      uint256[] memory result = new uint256[](tokenCount);
      uint256 totalTokens = getTotalSupply();
      uint256 resultIndex = 0;

      uint256 tokenIndex;
      uint256 tokenId;
      for (tokenIndex = 0; tokenIndex < totalTokens; tokenIndex++) {
        tokenId = tokens[tokenIndex];
        if (collectibleIndexToOwner[tokenId] == _owner) {
          result[resultIndex] = tokenId;
          resultIndex = resultIndex.add(1);
        }
      }
      return result;
    }
  }
}