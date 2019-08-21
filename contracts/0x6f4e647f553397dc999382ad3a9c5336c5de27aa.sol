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

contract Owned {
  // The addresses of the accounts (or contracts) that can execute actions within each roles.
  address public ceoAddress;
  address public cooAddress;
  address private newCeoAddress;
  address private newCooAddress;

  function Owned() public {
      ceoAddress = msg.sender;
      cooAddress = msg.sender;
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

  /// @dev Assigns a new address to act as the CEO. Only available to the current CEO.
  /// @param _newCEO The address of the new CEO
  function setCEO(address _newCEO) public onlyCEO {
    require(_newCEO != address(0));
    newCeoAddress = _newCEO;
  }

  /// @dev Assigns a new address to act as the COO. Only available to the current COO.
  /// @param _newCOO The address of the new COO
  function setCOO(address _newCOO) public onlyCEO {
    require(_newCOO != address(0));
    newCooAddress = _newCOO;
  }

  function acceptCeoOwnership() public {
      require(msg.sender == newCeoAddress);
      require(address(0) != newCeoAddress);
      ceoAddress = newCeoAddress;
      newCeoAddress = address(0);
  }

  function acceptCooOwnership() public {
      require(msg.sender == newCooAddress);
      require(address(0) != newCooAddress);
      cooAddress = newCooAddress;
      newCooAddress = address(0);
  }

}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ConsenSys/Tokens/blob/master/contracts/eip20/EIP20.sol
// ----------------------------------------------------------------------------
contract YouCollectBase is Owned {
  using SafeMath for uint256;

  /*** CONSTANTS ***/
  string public constant NAME = "Crypto - YouCollect";
  string public constant SYMBOL = "CYC";
  uint8 public constant DECIMALS = 18;  

  uint256 public totalSupply;
  uint256 constant private MAX_UINT256 = 2**256 - 1;
  mapping (address => uint256) public balances;
  mapping (address => mapping (address => uint256)) public allowed;

  event Transfer(address indexed _from, address indexed _to, uint256 _value); 
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  /// @dev Required for ERC-20 compliance.
  function name() public pure returns (string) {
    return NAME;
  }

  /// @dev Required for ERC-20 compliance.
  function symbol() public pure returns (string) {
    return SYMBOL;
  }
  /// @dev Required for ERC-20 compliance.
  function decimals() public pure returns (uint8) {
    return DECIMALS;
  }

  function transfer(address _to, uint256 _value) public returns (bool success) {
      require(balances[msg.sender] >= _value);
      balances[msg.sender] -= _value;
      balances[_to] += _value;
      Transfer(msg.sender, _to, _value);
      return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
      uint256 allowance = allowed[_from][msg.sender];
      require(balances[_from] >= _value && allowance >= _value);
      balances[_to] += _value;
      balances[_from] -= _value;
      if (allowance < MAX_UINT256) {
          allowed[_from][msg.sender] -= _value;
      }
      Transfer(_from, _to, _value);
      return true;
  }

  function balanceOf(address _owner) public view returns (uint256 balance) {
      return balances[_owner];
  }

  function approve(address _spender, uint256 _value) public returns (bool success) {
      allowed[msg.sender][_spender] = _value;
      Approval(msg.sender, _spender, _value);
      return true;
  }

  function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
      allowed[msg.sender][_spender] = _value;
      Approval(msg.sender, _spender, _value);

      require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
      return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
      return allowed[_owner][_spender];
  }   


  // Payout
  function payout(address _to) public onlyCLevel {
    _payout(_to, this.balance);
  }
  function payout(address _to, uint amount) public onlyCLevel {
    if (amount>this.balance)
      amount = this.balance;
    _payout(_to, amount);
  }
  function _payout(address _to, uint amount) private {
    if (_to == address(0)) {
      ceoAddress.transfer(amount);
    } else {
      _to.transfer(amount);
    }
  }
}

contract ERC721YC is YouCollectBase {
  /*** STORAGE ***/
  uint256[] public tokens;
  mapping (uint => bool) public unlocked;

  /// @dev A mapping from collectible IDs to the address that owns them. All collectibles have
  ///  some valid owner address.
  mapping (uint256 => address) public tokenIndexToOwner;

  /// @dev A mapping from CollectibleIDs to an address that has been approved to call
  ///  transferFrom(). Each Collectible can only have one approved address for transfer
  ///  at any time. A zero value means no approval is outstanding.
  mapping (uint256 => address) public tokenIndexToApproved;

  // @dev A mapping from CollectibleIDs to the price of the token.
  mapping (uint256 => uint256) public tokenIndexToPrice;

  /*** EVENTS ***/
  /// @dev The Birth event is fired whenever a new collectible comes into existence.
  event Birth(uint256 tokenId, uint256 startPrice);
  /// @dev The TokenSold event is fired whenever a token is sold.
  event TokenSold(uint256 indexed tokenId, uint256 price, address prevOwner, address winner);
  // ERC721 Transfer
  event TransferToken(address indexed from, address indexed to, uint256 tokenId);
  // ERC721 Approval
  event ApprovalToken(address indexed owner, address indexed approved, uint256 tokenId);

  /*** PUBLIC FUNCTIONS ***/
  /// @notice Grant another address the right to transfer token via takeOwnership() and transferFrom().
  /// @param _to The address to be granted transfer approval. Pass address(0) to
  ///  clear all approvals.
  /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
  /// @dev Required for ERC-721 compliance.
  function approveToken(
    address _to,
    uint256 _tokenId
  ) public {
    // Caller must own token.
    require(_ownsToken(msg.sender, _tokenId));

    tokenIndexToApproved[_tokenId] = _to;

    ApprovalToken(msg.sender, _to, _tokenId);
  }


  function getTotalTokenSupply() public view returns (uint) {
    return tokens.length;
  }

  function implementsERC721YC() public pure returns (bool) {
    return true;
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
  }


  function priceOf(uint256 _tokenId) public view returns (uint256 price) {
    price = tokenIndexToPrice[_tokenId];
    if (price == 0)
      price = getInitialPriceOfToken(_tokenId);
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

    _transferToken(oldOwner, newOwner, _tokenId);
  }

  /// Owner initates the transfer of the token to another account
  /// @param _to The address for the token to be transferred to.
  /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
  /// @dev Required for ERC-721 compliance.
  function transferToken(
    address _to,
    uint256 _tokenId
  ) public {
    require(_ownsToken(msg.sender, _tokenId));
    require(_addressNotNull(_to));

    _transferToken(msg.sender, _to, _tokenId);
  }

  /// Third-party initiates transfer of token from address _from to address _to
  /// @param _from The address for the token to be transferred from.
  /// @param _to The address for the token to be transferred to.
  /// @param _tokenId The ID of the Token that can be transferred if this call succeeds.
  /// @dev Required for ERC-721 compliance.
  function transferTokenFrom(
    address _from,
    address _to,
    uint256 _tokenId
  ) public {
    require(_ownsToken(_from, _tokenId));
    require(_approved(_to, _tokenId));
    require(_addressNotNull(_to));

    _transferToken(_from, _to, _tokenId);
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

  /// For creating Collectible
  function _createCollectible(uint256 tokenId, uint256 _price) internal {
    tokenIndexToPrice[tokenId] = _price;
    Birth(tokenId, _price);
    tokens.push(tokenId);
    unlocked[tokenId] = true;
  }

  /// Check for token ownership
  function _ownsToken(address claimant, uint256 _tokenId) public view returns (bool) {
    return claimant == tokenIndexToOwner[_tokenId];
  }


  // allows owners of tokens to decrease the price of them or if there is no owner the coo can do it
  bool isTokenChangePriceLocked = true;
  function changeTokenPrice(uint256 newPrice, uint256 _tokenId) public {
    require((_ownsToken(msg.sender, _tokenId) && !isTokenChangePriceLocked) || (_ownsToken(address(0), _tokenId) && msg.sender == cooAddress));
    require(newPrice<tokenIndexToPrice[_tokenId]);
    tokenIndexToPrice[_tokenId] = newPrice;
  }
  function unlockToken(uint tokenId) public onlyCOO {
    unlocked[tokenId] = true;
  }
  function unlockTokenPriceChange() public onlyCOO {
    isTokenChangePriceLocked = false;
  }
  function isChangePriceLocked() public view returns (bool) {
    return isTokenChangePriceLocked;
  }


  /// create Tokens for Token Owners in alpha Game
  function createPromoCollectible(uint256 tokenId, address _owner, uint256 _price) public onlyCOO {
    require(tokenIndexToOwner[tokenId]==address(0));

    address collectibleOwner = _owner;
    if (collectibleOwner == address(0)) {
      collectibleOwner = cooAddress;
    }

    if (_price <= 0) {
      _price = getInitialPriceOfToken(tokenId);
    }

    _createCollectible(tokenId, _price);
    // This will assign ownership, and also emit the Transfer event as
    // per ERC721 draft
    _transferToken(address(0), collectibleOwner, tokenId);

  }


  /// For querying balance of a particular account
  /// @param _owner The address for balance query
  /// @dev Required for ERC-721 compliance.
  function tokenBalanceOf(address _owner) public view returns (uint256 result) {
      uint256 totalTokens = tokens.length;
      uint256 tokenIndex;
      uint256 tokenId;
      result = 0;
      for (tokenIndex = 0; tokenIndex < totalTokens; tokenIndex++) {
        tokenId = tokens[tokenIndex];
        if (tokenIndexToOwner[tokenId] == _owner) {
          result = result.add(1);
        }
      }
      return result;
  }

  /// @dev Assigns ownership of a specific Collectible to an address.
  function _transferToken(address _from, address _to, uint256 _tokenId) internal {
    //transfer ownership
    tokenIndexToOwner[_tokenId] = _to;

    // When creating new collectibles _from is 0x0, but we can't account that address.
    if (_from != address(0)) {
      // clear any previously approved ownership exchange
      delete tokenIndexToApproved[_tokenId];
    }

    // Emit the transfer event.
    TransferToken(_from, _to, _tokenId);
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
      uint256 totalTokens = getTotalTokenSupply();
      uint256 resultIndex = 0;

      uint256 tokenIndex;
      uint256 tokenId;
      for (tokenIndex = 0; tokenIndex < totalTokens; tokenIndex++) {
        tokenId = tokens[tokenIndex];
        if (tokenIndexToOwner[tokenId] == _owner) {
          result[resultIndex] = tokenId;
          resultIndex = resultIndex.add(1);
        }
      }
      return result;
    }
  }

  /// @dev returns an array with all token ids
  function getTokenIds() public view returns(uint256[]) {
    return tokens;
  }

  function getInitialPriceOfToken(uint tokenId) public pure returns (uint);
}

contract CollectibleToken is ERC721YC {

  uint256 private constant STARTING_PRICE = 0.001 ether;

  uint256 private constant FIRST_STEP_LIMIT =  0.053613 ether;
  uint256 private constant SECOND_STEP_LIMIT = 0.564957 ether;

  uint private constant MASTER_TOKEN_ID = 0;

  function CollectibleToken() public {
    balances[msg.sender] = 10000000000000000000;
    totalSupply = 10000000000000000000;

  }

  function getInitialPriceOfToken(uint _tokenId) public pure returns (uint) {
    if (_tokenId > 0)
      return STARTING_PRICE;
    return 10 ether;
  }


  function getNextPrice(uint sellingPrice) public pure returns (uint) {
    if (sellingPrice < FIRST_STEP_LIMIT) {
      return sellingPrice.mul(200).div(93);
    } else if (sellingPrice < SECOND_STEP_LIMIT) {
      return sellingPrice.mul(120).div(93);
    } else {
      return sellingPrice.mul(115).div(93);
    }
  }

  /// @notice Returns all the relevant information about a specific collectible.
  /// @param _tokenId The tokenId of the collectible of interest.
  function getCollectible(uint256 _tokenId) public view returns (uint256 tokenId,
    uint256 sellingPrice,
    address owner,
    uint256 nextSellingPrice
  ) {
    tokenId = _tokenId;
    sellingPrice = tokenIndexToPrice[_tokenId];
    owner = tokenIndexToOwner[_tokenId];

    if (sellingPrice == 0)
      sellingPrice = getInitialPriceOfToken(_tokenId);

    nextSellingPrice = getNextPrice(sellingPrice);
  }

  // Allows someone to send ether and obtain the token
  function purchase(uint256 _tokenId) public payable {
    address oldOwner = tokenIndexToOwner[_tokenId];
    uint256 sellingPrice = tokenIndexToPrice[_tokenId];
    require(oldOwner!=msg.sender || sellingPrice > 1 ether);

    if (sellingPrice == 0) {
      sellingPrice = getInitialPriceOfToken(_tokenId);
    }

    // Safety check to prevent against an unexpected 0x0 default.
    require(msg.sender != address(0));

    require(msg.value >= sellingPrice);
    uint256 purchaseExcess = msg.value.sub(sellingPrice);

    uint256 payment = sellingPrice.mul(93).div(100);
    uint256 feeOnce = sellingPrice.sub(payment).div(7);

    tokenIndexToPrice[_tokenId] = getNextPrice(sellingPrice);

    // Transfers the Token
    tokenIndexToOwner[_tokenId] = msg.sender;
    TokenSold(_tokenId, sellingPrice, oldOwner, msg.sender);
    TransferToken(oldOwner, msg.sender, _tokenId);

    if (oldOwner != address(0)) {
      // clear any previously approved ownership exchange
      delete tokenIndexToApproved[_tokenId];
      // Payment for old owner and new owner
      _payoutMining(_tokenId, oldOwner, msg.sender);
      if (sellingPrice > 3 ether)
        levelUpMining(_tokenId);
      oldOwner.transfer(payment);
    } else {
      require(unlocked[_tokenId]);
      Birth(_tokenId, sellingPrice);
      tokens.push(_tokenId);
      createMineForToken(_tokenId);
    }

    if (_tokenId > 0 && tokenIndexToOwner[MASTER_TOKEN_ID]!=address(0)) {
      // Taxes for YouCollect-Token owner
      tokenIndexToOwner[MASTER_TOKEN_ID].transfer(feeOnce);
    }
    // refund when paid too much
    if (purchaseExcess>0)
      msg.sender.transfer(purchaseExcess);
  }
  
  
  //
  //  Mining
  //
    event MiningUpgrade(address indexed sender, uint indexed token, uint amount);
    event MiningLevelup(address indexed sender, uint indexed token, uint power);
    event MiningPayout(address indexed sender, uint indexed token, uint amount);
    event MiningStolenPayout(address indexed sender, address indexed oldOwner, uint indexed token, uint amount);

    mapping (uint => uint) miningPower;
    mapping (uint => uint) miningPushed;
    mapping (uint => uint) miningNextLevelBreak;
    mapping (uint => uint) miningLastPayoutBlock;

    uint earningsEachBlock = 173611111111111;
    uint FIRST_MINING_LEVEL_COST = 1333333333333333333;

    function changeEarnings(uint amount) public onlyCOO {
      earningsEachBlock = amount;
      require(earningsEachBlock>0);
    }

    function createMineForToken(uint tokenId) private {
      miningPower[tokenId] = 1;
      miningNextLevelBreak[tokenId] = FIRST_MINING_LEVEL_COST;
      miningLastPayoutBlock[tokenId] = block.number;
    }
    function createMineForToken(uint tokenId, uint power, uint xp, uint nextLevelBreak) public onlyCOO {
      miningPower[tokenId] = power;
      miningPushed[tokenId] = xp;
      miningNextLevelBreak[tokenId] = nextLevelBreak;
      miningLastPayoutBlock[tokenId] = block.number;
    }

    function upgradeMining(uint tokenId, uint coins) public {
      require(balanceOf(msg.sender)>=coins);
      uint nextLevelBreak = miningNextLevelBreak[tokenId];
      balances[msg.sender] -= coins;
      uint xp = miningPushed[tokenId]+coins;
      if (xp>nextLevelBreak) {
        uint power = miningPower[tokenId];
        if (miningLastPayoutBlock[tokenId] < block.number) {
          _payoutMining(tokenId, ownerOf(tokenId));
        }
        while (xp>nextLevelBreak) {
          nextLevelBreak = nextLevelBreak.mul(13).div(4);
          power = power.mul(2);
          MiningLevelup(msg.sender, tokenId, power);
        }
        miningNextLevelBreak[tokenId] = nextLevelBreak;
        miningPower[tokenId] = power;
      }
      miningPushed[tokenId] = xp;
      Transfer(msg.sender, this, coins);
      MiningUpgrade(msg.sender, tokenId, coins);
    }

    function levelUpMining(uint tokenId) private {
      uint diffToNextLevel = getCostToNextLevel(tokenId);
      miningNextLevelBreak[tokenId] = miningNextLevelBreak[tokenId].mul(13).div(4);
      miningPushed[tokenId] = miningNextLevelBreak[tokenId].sub(diffToNextLevel);
      miningPower[tokenId] = miningPower[tokenId].mul(2);
      MiningLevelup(msg.sender, tokenId, miningPower[tokenId]);
    }

    function payoutMining(uint tokenId) public {
      require(_ownsToken(msg.sender, tokenId));
      require(miningLastPayoutBlock[tokenId] < block.number);
      _payoutMining(tokenId, msg.sender);
    }

    function _payoutMining(uint tokenId, address owner) private {
      uint coinsMined = block.number.sub(miningLastPayoutBlock[tokenId]).mul(earningsEachBlock).mul(miningPower[tokenId]);
      miningLastPayoutBlock[tokenId] = block.number;
      balances[owner] = balances[owner].add(coinsMined);
      totalSupply = totalSupply.add(coinsMined);
      MiningPayout(owner, tokenId, coinsMined);
    }
    function _payoutMining(uint tokenId, address owner, address newOwner) private {
      uint coinsMinedHalf = block.number.sub(miningLastPayoutBlock[tokenId]).mul(earningsEachBlock).mul(miningPower[tokenId]).div(2);
      miningLastPayoutBlock[tokenId] = block.number;
      balances[owner] = balances[owner].add(coinsMinedHalf);
      balances[newOwner] = balances[newOwner].add(coinsMinedHalf);
      totalSupply = totalSupply.add(coinsMinedHalf.mul(2));
      MiningStolenPayout(newOwner, owner, tokenId, coinsMinedHalf);
    }

    function getCostToNextLevel(uint tokenId) public view returns (uint) {
      return miningNextLevelBreak[tokenId]-miningPushed[tokenId];
    }

    function getMiningMeta(uint tokenId) public view returns (uint earnEachBlock, uint mined, uint xp, uint nextLevelUp, uint lastPayoutBlock, uint power) {
      earnEachBlock = miningPower[tokenId].mul(earningsEachBlock);
      mined = block.number.sub(miningLastPayoutBlock[tokenId]).mul(earningsEachBlock).mul(miningPower[tokenId]);
      xp = miningPushed[tokenId];
      nextLevelUp = miningNextLevelBreak[tokenId];
      lastPayoutBlock = miningLastPayoutBlock[tokenId];
      power = miningPower[tokenId];
    }

    function getCollectibleWithMeta(uint256 tokenId) public view returns (uint256 _tokenId, uint256 sellingPrice, address owner, uint256 nextSellingPrice, uint earnEachBlock, uint mined, uint xp, uint nextLevelUp, uint lastPayoutBlock, uint power) {
      _tokenId = tokenId;
      sellingPrice = tokenIndexToPrice[tokenId];
      owner = tokenIndexToOwner[tokenId];
      if (sellingPrice == 0)
        sellingPrice = getInitialPriceOfToken(tokenId);

      nextSellingPrice = getNextPrice(sellingPrice);
      earnEachBlock = miningPower[tokenId].mul(earningsEachBlock);
      uint lastMinedBlock = miningLastPayoutBlock[tokenId];
      mined = block.number.sub(lastMinedBlock).mul(earningsEachBlock).mul(miningPower[tokenId]);
      xp = miningPushed[tokenId];
      nextLevelUp = miningNextLevelBreak[tokenId];
      lastPayoutBlock = miningLastPayoutBlock[tokenId];
      power = miningPower[tokenId];
    }
    function getEarnEachBlock() public view returns (uint) {
      return earningsEachBlock;
    }

    /// create Tokens for Token Owners in alpha Game
    function createPromoCollectibleWithMining(uint256 tokenId, address _owner, uint256 _price, uint256 power, uint256 xp, uint256 nextLevelBreak) public onlyCOO {
      require(tokenIndexToOwner[tokenId]==address(0));

      address collectibleOwner = _owner;
      if (collectibleOwner == address(0)) {
        collectibleOwner = cooAddress;
      }

      if (_price <= 0) {
        _price = getInitialPriceOfToken(tokenId);
      }

      _createCollectible(tokenId, _price);
      createMineForToken(tokenId, power, xp, nextLevelBreak);
      // This will assign ownership, and also emit the Transfer event as
      // per ERC721 draft
      _transferToken(address(0), collectibleOwner, tokenId);

    }

    /// create Tokens for Token Owners in alpha Game
    function createPromoCollectiblesWithMining(uint256[] tokenId, address[] _owner, uint256[] _price, uint256[] power, uint256[] xp, uint256[] nextLevelBreak) public onlyCOO {
      address collectibleOwner;
      for (uint i = 0; i < tokenId.length; i++) {
        require(tokenIndexToOwner[tokenId[i]]==address(0));

        collectibleOwner = _owner[i];
        if (collectibleOwner == address(0)) {
          collectibleOwner = cooAddress;
        }

        if (_price[i] <= 0) {
          _createCollectible(tokenId[i], getInitialPriceOfToken(tokenId[i]));
        } else {
          _createCollectible(tokenId[i], _price[i]);
        }

        createMineForToken(tokenId[i], power[i], xp[i], nextLevelBreak[i]);
        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _transferToken(address(0), collectibleOwner, tokenId[i]);
      }

    }
  //
  //  Mining end
  //
}