pragma solidity ^0.4.18; // solhint-disable-line

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

contract CryptoColors {
  using SafeMath for uint256;

  /*** EVENTS ***/

  /// @dev The Birth event is fired whenever a new token comes into existence.
  event Birth(uint256 tokenId, string name, address owner);

  /// @dev The TokenSold event is fired whenever a token is sold.
  event TokenSold(uint256 tokenId, uint256 oldPrice, uint256 newPrice, address prevOwner, address winner, string name);

  /// @dev Referrer payout completed
  event Payout(address referrer, uint256 balance);

  /// @dev Referrer registered
  event ReferrerRegistered(address referrer, address referral);

  /// @dev Transfer event as defined in current draft of ERC721.
  ///  ownership is assigned, including births.
  event Transfer(address from, address to, uint256 tokenId);

  event Approval(address indexed owner, address indexed approved, uint256 tokenId);

  /*** CONSTANTS ***/

  /// @notice Name and symbol of the non fungible token, as defined in ERC721.
  string public constant NAME = "CryptoColors"; // solhint-disable-line
  string public constant SYMBOL = "CLRS"; // solhint-disable-line

  uint256 private startingPrice = 0.001 ether;
  uint256 private firstStepLimit =  0.02 ether;
  uint256 private secondStepLimit = 0.5 ether;
  uint256 private thirdStepLimit = 2 ether;
  uint256 private forthStepLimit = 5 ether;

  /*** STORAGE ***/

  /// @dev A mapping from token IDs to the address that owns them. All tokens have
  ///  some valid owner address.
  mapping (uint256 => address) public tokenIndexToOwner;

  /// @dev A mapping from owner address to count of tokens that address owns.
  /// Used internally inside balanceOf() to resolve ownership count.
  mapping (address => uint256) private ownershipTokenCount;

  /// @dev A mapping from TokenIDs to an address that has been approved to call
  /// transferFrom(). Each Token can only have one approved address for transfer
  ///  at any time. A zero value means no approval is outstanding.
  mapping (uint256 => address) public tokenIndexToApproved;

  /// @dev A mapping from TokenIDs to the price of the token.
  mapping (uint256 => uint256) private tokenIndexToPrice;

  /// @dev Current referrer balance
  mapping (address => uint256) private referrerBalance;

  /// @dev A mapping from a token buyer to their referrer
  mapping (address => address) private referralToRefferer;

  /// The addresses of the accounts (or contracts) that can execute actions within each roles.
  address public ceoAddress;
  address public cooAddress;

  /*** DATATYPES ***/
  struct Token {
    string name;
  }

  Token[] private tokens;

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
  function CryptoColors() public {
    ceoAddress = msg.sender;
    cooAddress = msg.sender;
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
  )
  public
  {
    // Caller must own token.
    require(_owns(msg.sender, _tokenId));

    tokenIndexToApproved[_tokenId] = _to;

    Approval(msg.sender, _to, _tokenId);
  }

  /// For querying balance of a particular account
  /// @param _owner The address for balance query
  /// @dev Required for ERC-721 compliance.
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return ownershipTokenCount[_owner];
  }

  /// @dev Returns next token price
  function _calculateNextPrice(uint256 _sellingPrice) private view returns (uint256 price) {
    if (_sellingPrice < firstStepLimit) {
      // first stage
      return _sellingPrice.mul(200).div(100);
    } else if (_sellingPrice < secondStepLimit) {
      // second stage
     return _sellingPrice.mul(135).div(100);
    } else if (_sellingPrice < thirdStepLimit) {
      // third stage
      return _sellingPrice.mul(125).div(100);
    } else if (_sellingPrice < forthStepLimit) {
      // forth stage
      return _sellingPrice.mul(120).div(100);
    } else {
      // fifth stage
      return _sellingPrice.mul(115).div(100);
    }
  }

  /// @dev Creates a new Token with the given name.
  function createContractToken(string _name) public onlyCLevel {
    _createToken(_name, address(this), startingPrice);
  }

  /// @notice Returns all the relevant information about a specific token.
  /// @param _tokenId The tokenId of the token of interest.
  function getToken(uint256 _tokenId) public view returns (
    string tokenName,
    uint256 sellingPrice,
    address owner
  ) {
    Token storage token = tokens[_tokenId];
    tokenName = token.name;
    sellingPrice = tokenIndexToPrice[_tokenId];
    owner = tokenIndexToOwner[_tokenId];
  }

  /// @dev Get buyer referrer.
  function getReferrer(address _address) public view returns (address referrerAddress) {
    return referralToRefferer[_address];
  }

  /// @dev Get referrer balance.
  function getReferrerBalance(address _address) public view returns (uint256 totalAmount) {
    return referrerBalance[_address];
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
    owner = tokenIndexToOwner[_tokenId];
    require(owner != address(0));
  }

  function payout(address _to) public onlyCLevel {
    _payout(_to);
  }

  function payoutToReferrer() public payable {
    address referrer = msg.sender;
    uint256 totalAmount = referrerBalance[referrer];
    if (totalAmount > 0) {
      msg.sender.transfer(totalAmount);
      referrerBalance[referrer] = 0;
      Payout(referrer, totalAmount);
    }
  }

  function priceOf(uint256 _tokenId) public view returns (uint256 price) {
    return tokenIndexToPrice[_tokenId];
  }

    // Purchase token and increse referrer payout
  function purchase(uint256 _tokenId, address _referrer) public payable {
    address newOwner = msg.sender;
    address oldOwner = tokenIndexToOwner[_tokenId];
    uint256 sellingPrice = tokenIndexToPrice[_tokenId];

    // Making sure token owner is not sending to self
    require(oldOwner != newOwner);
    // Safety check to prevent against an unexpected 0x0 default.
    require(_addressNotNull(newOwner));
    // Making sure sent amount is greater than or equal to the sellingPrice
    require(msg.value >= sellingPrice);

    uint256 payment = sellingPrice.mul(95).div(100);
    uint256 purchaseExcess = msg.value.sub(sellingPrice);
    // Calculate 15% ref bonus
    uint256 referrerPayout = sellingPrice.sub(payment).mul(15).div(100);   
    address storedReferrer = getReferrer(newOwner);

    // If a referrer is registered
    if (_addressNotNull(storedReferrer)) {
      // Increase referrer balance
      referrerBalance[storedReferrer] += referrerPayout;
    } else if (_addressNotNull(_referrer)) {
      // Associate a referral with the referrer
      referralToRefferer[newOwner] = _referrer;
      // Notify subscribers about new referrer
      ReferrerRegistered(_referrer, newOwner);
      referrerBalance[_referrer] += referrerPayout;      
    } 

    // Update prices
    tokenIndexToPrice[_tokenId] = _calculateNextPrice(sellingPrice);

    _transfer(oldOwner, newOwner, _tokenId);

    // Pay previous tokenOwner if owner is not contract
    if (oldOwner != address(this)) {
      oldOwner.transfer(payment);
    }

    TokenSold(_tokenId, sellingPrice, tokenIndexToPrice[_tokenId], oldOwner, newOwner, tokens[_tokenId].name);

    // Transfer excess back to owner
    if (purchaseExcess > 0) {
      msg.sender.transfer(purchaseExcess);
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
    address oldOwner = tokenIndexToOwner[_tokenId];

    // Safety check to prevent against an unexpected 0x0 default.
    require(_addressNotNull(newOwner));

    // Making sure transfer is approved
    require(_approved(newOwner, _tokenId));

    _transfer(oldOwner, newOwner, _tokenId);
  }

  /// @param _owner The owner whose tokens we are interested in.
  /// @dev This method MUST NEVER be called by smart contract code. First, it's fairly
  ///  expensive (it walks the entire Tokens array looking for tokens belonging to owner),
  ///  but it also returns a dynamic array, which is only supported for web3 calls, and
  ///  not contract-to-contract calls.
  function tokensOfOwner(address _owner) public view returns(uint256[] ownerTokens) {
    uint256 tokenCount = balanceOf(_owner);
    if (tokenCount == 0) {
        // Return an empty array
      return new uint256[](0);
    } else {
      uint256[] memory result = new uint256[](tokenCount);
      uint256 totalTokens = totalSupply();
      uint256 resultIndex = 0;

      uint256 tokenId;
      for (tokenId = 0; tokenId <= totalTokens; tokenId++) {
        if (tokenIndexToOwner[tokenId] == _owner) {
          result[resultIndex] = tokenId;
          resultIndex++;
        }
      }
      return result;
    }
  }

  /// For querying totalSupply of token
  /// @dev Required for ERC-721 compliance.
  function totalSupply() public view returns (uint256 total) {
    return tokens.length;
  }

  /// Owner initates the transfer of the token to another account
  /// @param _to The address for the token to be transferred to.
  /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
  /// @dev Required for ERC-721 compliance.
  function transfer(
    address _to,
    uint256 _tokenId
  )
  public
  {
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
  )
  public
  {
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
    return tokenIndexToApproved[_tokenId] == _to;
  }

  /// For creating Token
  function _createToken(string _name, address _owner, uint256 _price) private {
    Token memory _token = Token({
      name: _name
    });
    uint256 newTokenId = tokens.push(_token) - 1;

    // It's probably never going to happen, 4 billion tokens are A LOT, but
    // let's just be 100% sure we never let this happen.
    require(newTokenId == uint256(uint32(newTokenId)));

    Birth(newTokenId, _name, _owner);

    tokenIndexToPrice[newTokenId] = _price;

    // This will assign ownership, and also emit the Transfer event as
    // per ERC721 draft
    _transfer(address(0), _owner, newTokenId);
  }

  /// Check for token ownership
  function _owns(address claimant, uint256 _tokenId) private view returns (bool) {
    return claimant == tokenIndexToOwner[_tokenId];
  }

  /// For paying out balance on contract
  function _payout(address _to) private {
    if (_to == address(0)) {
      ceoAddress.transfer(this.balance);
    } else {
      _to.transfer(this.balance);
    }
  }

  /// @dev Assigns ownership of a specific Token to an address.
  function _transfer(address _from, address _to, uint256 _tokenId) private {
    // Since the number of tokens is capped to 2^32 we can't overflow this
    ownershipTokenCount[_to]++;
    //transfer ownership
    tokenIndexToOwner[_tokenId] = _to;

    // When creating new tokens _from is 0x0, but we can't account that address.
    if (_from != address(0)) {
      ownershipTokenCount[_from]--;
      // clear any previously approved ownership exchange
      delete tokenIndexToApproved[_tokenId];
    }

    // Emit the transfer event.
    Transfer(_from, _to, _tokenId);
  }
}