pragma solidity ^0.4.19;

contract Soccer {
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

  string public constant NAME = "SoccerAllStars";
  string public constant SYMBOL = "SAS";

  /*** STORAGE ***/
  struct Token {
    address owner;
    uint256 price;
  }
  mapping (uint256 => Token) collectibleIdx;
  mapping (uint256 => address[3]) mapToLastOwners;
  mapping (uint256 => address) collectibleIndexToApproved;
  uint256[] private tokens;

  // The addresses of the accounts (or contracts) that can execute actions within each roles.
  address public ceoAddress;
  address public cooAddress;

  uint16 constant NATION_INDEX = 1000;
  uint32 constant CLUB_INDEX = 1000000;

  uint256 private constant PROMO_CREATION_LIMIT = 50000;
  uint256 public promoCreatedCount;

  uint256 constant PLAYER_PRICE = 1 finney;
  uint256 constant CLUB_PRICE = 10 finney;
  uint256 constant NATION_PRICE = 100 finney;

  /*** CONSTRUCTOR ***/
  function Soccer() public {
    ceoAddress = msg.sender;
    cooAddress = msg.sender;
  }
  
  function getTotalSupply() public view returns (uint) {
    return tokens.length;
  }
  
  function getInitialPriceOfToken(uint _tokenId) public pure returns (uint) {
    if (_tokenId > CLUB_INDEX)
      return PLAYER_PRICE;
    if (_tokenId > NATION_INDEX)
      return CLUB_PRICE;
    return NATION_PRICE;
  }

  function getNextPrice(uint price, uint _tokenId) public pure returns (uint) {
    if (price < 0.05 ether)
      return price.mul(200).div(93); //x2
    if (price < 0.5 ether)
      return price.mul(150).div(93); //x1.5
    if (price < 2 ether)
      return price.mul(130).div(93); //x1.3
    return price.mul(120).div(93); //x1.2
  }

  function buyToken(uint _tokenId) public payable {
    require(!isContract(msg.sender));
    
    Token memory token = collectibleIdx[_tokenId];
    address oldOwner = address(0);
    uint256 sellingPrice;
    if (token.owner == address(0)) {
        sellingPrice = getInitialPriceOfToken(_tokenId);
        token = Token({
            owner: msg.sender,
            price: sellingPrice
        });
    } else {
        oldOwner = token.owner;
        sellingPrice = token.price;
        require(oldOwner != msg.sender);
    }
    require(msg.value >= sellingPrice);
    
    address[3] storage lastOwners = mapToLastOwners[_tokenId];
    uint256 payment = _handle(_tokenId, sellingPrice, lastOwners);

    // Transfers the Token
    token.owner = msg.sender;
    token.price = getNextPrice(sellingPrice, _tokenId);
    mapToLastOwners[_tokenId] = _addLastOwner(lastOwners, oldOwner);

    collectibleIdx[_tokenId] = token;
    if (oldOwner != address(0)) {
      // Payment for old owner
      oldOwner.transfer(payment);
      // clear any previously approved ownership exchange
      delete collectibleIndexToApproved[_tokenId];
    } else {
      Birth(_tokenId, sellingPrice);
      tokens.push(_tokenId);
    }

    TokenSold(_tokenId, sellingPrice, oldOwner, msg.sender);
    Transfer(oldOwner, msg.sender, _tokenId);

    // refund when paid too much
    uint256 purchaseExcess = msg.value.sub(sellingPrice);
    if (purchaseExcess > 0) {
        msg.sender.transfer(purchaseExcess);
    }
  }

function _handle(uint256 _tokenId, uint256 sellingPrice, address[3] lastOwners) private returns (uint256) {
    uint256 pPrice = sellingPrice.div(100);
    uint256 tax = pPrice.mul(7); // initial dev cut = 7%
    if (_tokenId > CLUB_INDEX) {
        uint256 clubId = _tokenId % CLUB_INDEX;
        Token storage clubToken = collectibleIdx[clubId];
        if (clubToken.owner != address(0)) {
            uint256 clubTax = pPrice.mul(2); // 2% club tax;
            tax += clubTax;
            clubToken.owner.transfer(clubTax);
        }

        uint256 nationId = clubId % NATION_INDEX;
        Token storage nationToken = collectibleIdx[nationId];
        if (nationToken.owner != address(0)) {
            tax += pPrice; // 1% nation tax;
            nationToken.owner.transfer(pPrice);
        }
    } else if (_tokenId > NATION_INDEX) {
        nationId = _tokenId % NATION_INDEX;
        nationToken = collectibleIdx[nationId];
        if (nationToken.owner != address(0)) {
            tax += pPrice; // 1% nation tax;
            nationToken.owner.transfer(pPrice);
        }
    }

    //Pay tax to the previous 3 owners
    uint256 lastOwnerTax;
    if (lastOwners[0] != address(0)) {
      tax += pPrice; // 1% 3rd payment
      lastOwners[0].transfer(pPrice);
    }
    if (lastOwners[1] != address(0)) {
      lastOwnerTax = pPrice.mul(2); // 2% 2nd payment
      tax += lastOwnerTax;
      lastOwners[1].transfer(lastOwnerTax);
    }
    if (lastOwners[2] != address(0)) {
      lastOwnerTax = pPrice.mul(3); // 3% 1st payment
      tax += lastOwnerTax;
      lastOwners[2].transfer(lastOwnerTax);
    }

    return sellingPrice.sub(tax);
}

function _addLastOwner(address[3] lastOwners, address oldOwner) pure private returns (address[3]) {
    lastOwners[0] = lastOwners[1];
    lastOwners[1] = lastOwners[2];
    lastOwners[2] = oldOwner;
    return lastOwners;
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
    require( msg.sender == ceoAddress || msg.sender == cooAddress );
    _;
  }

  /*** PUBLIC FUNCTIONS ***/
  /// @notice Grant another address the right to transfer token via takeOwnership() and transferFrom().
  /// @param _to The address to be granted transfer approval. Pass address(0) to
  ///  clear all approvals.
  /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
  /// @dev Required for ERC-721 compliance.
  function approve(address _to, uint256 _tokenId) public {
    // Caller must own token.
    require(_owns(msg.sender, _tokenId));

    collectibleIndexToApproved[_tokenId] = _to;

    Approval(msg.sender, _to, _tokenId);
  }

  /// @dev Creates a new promo collectible with the given name, with given _price and assignes it to an address.
  function createPromoCollectible(uint256 tokenId, address _owner, uint256 _price) public onlyCLevel {
    Token memory token = collectibleIdx[tokenId];
    require(token.owner == address(0));
    require(promoCreatedCount < PROMO_CREATION_LIMIT);

    address collectibleOwner = _owner;
    if (collectibleOwner == address(0)) {
      collectibleOwner = cooAddress;
    }

    if (_price <= 0) {
      _price = getInitialPriceOfToken(tokenId);
    }

    promoCreatedCount++;
    token = Token({
        owner: collectibleOwner,
        price: _price
    });
    collectibleIdx[tokenId] = token;
    Birth(tokenId, _price);
    tokens.push(tokenId);

    // This will assign ownership, and also emit the Transfer event as
    // per ERC721 draft
    _transfer(address(0), collectibleOwner, tokenId);

  }

  bool isChangePriceLocked = false;
  // allows owners of tokens to decrease the price of them or if there is no owner the coo can do it
  function changePrice(uint256 _tokenId, uint256 newPrice) public {
    require((_owns(msg.sender, _tokenId) && !isChangePriceLocked) || (_owns(address(0), _tokenId) && msg.sender == cooAddress));
    Token storage token = collectibleIdx[_tokenId];
    require(newPrice < token.price);
    token.price = newPrice;
    collectibleIdx[_tokenId] = token;
  }
  function unlockPriceChange() public onlyCLevel {
    isChangePriceLocked = false;
  }
  function lockPriceChange() public onlyCLevel {
    isChangePriceLocked = true;
  }

  /// @notice Returns all the relevant information about a specific collectible.
  /// @param _tokenId The tokenId of the collectible of interest.
  function getToken(uint256 _tokenId) public view returns (uint256 tokenId, uint256 sellingPrice, address owner, uint256 nextSellingPrice) {
    tokenId = _tokenId;
    Token storage token = collectibleIdx[_tokenId];
    sellingPrice = token.price;
    if (sellingPrice == 0)
      sellingPrice = getInitialPriceOfToken(_tokenId);
    owner = token.owner;
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
    Token storage token = collectibleIdx[_tokenId];
    require(token.owner != address(0));
    owner = token.owner;
  }

  function payout(address _to) public onlyCLevel {
    _payout(_to);
  }


  function priceOf(uint256 _tokenId) public view returns (uint256 price) {
    Token storage token = collectibleIdx[_tokenId];
    if (token.owner == address(0)) {
        price = getInitialPriceOfToken(_tokenId);
    } else {
        price = token.price;
    }
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
    Token storage token = collectibleIdx[_tokenId];
    require(token.owner != address(0));
    address oldOwner = token.owner;

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

  /// Check for token ownership
  function _owns(address claimant, uint256 _tokenId) private view returns (bool) {
    Token storage token = collectibleIdx[_tokenId];
    return claimant == token.owner;
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
        if (collectibleIdx[tokenId].owner == _owner) {
          result = result.add(1);
        }
      }
      return result;
  }

  /// @dev Assigns ownership of a specific Collectible to an address.
  function _transfer(address _from, address _to, uint256 _tokenId) private {
    //transfer ownership
    collectibleIdx[_tokenId].owner = _to;

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
        if (collectibleIdx[tokenId].owner == _owner) {
          result[resultIndex] = tokenId;
          resultIndex = resultIndex.add(1);
        }
      }
      return result;
    }
  }

    /* Util */
  function isContract(address addr) private view returns (bool) {
    uint size;
    assembly { size := extcodesize(addr) } // solium-disable-line
    return size > 0;
  }
}



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