pragma solidity ^0.4.18;

contract KimAccessControl {
  // The addresses of the accounts (or contracts) that can execute actions within each roles.
  address public ceoAddress;
  address public cfoAddress;
  address public cooAddress;


  /// @dev Access modifier for CEO-only functionality
  modifier onlyCEO() {
      require(msg.sender == ceoAddress);
      _;
  }

  /// @dev Access modifier for CFO-only functionality
  modifier onlyCFO() {
      require(msg.sender == cfoAddress);
      _;
  }

  /// @dev Access modifier for COO-only functionality
  modifier onlyCOO() {
      require(msg.sender == cooAddress);
      _;
  }

  /// @dev Assigns a new address to act as the CEO. Only available to the current CEO.
  /// @param _newCEO The address of the new CEO
  function setCEO(address _newCEO) external onlyCEO {
      require(_newCEO != address(0));

      ceoAddress = _newCEO;
  }

  /// @dev Assigns a new address to act as the CFO. Only available to the current CEO.
  /// @param _newCFO The address of the new CFO
  function setCFO(address _newCFO) external onlyCEO {
      require(_newCFO != address(0));

      cfoAddress = _newCFO;
  }

  /// @dev Assigns a new address to act as the COO. Only available to the current CEO.
  /// @param _newCOO The address of the new COO
  function setCOO(address _newCOO) external onlyCEO {
      require(_newCOO != address(0));

      cooAddress = _newCOO;
  }


}



contract KimContract is KimAccessControl{

  // DECLARING BASIC VARIABLES, TOKEN SYMBOLS, AND CONSTANTS
  // Public variables of the token
  string public name;
  string public symbol;
  // total supply of kims ever to be in circulation
  uint256 public totalSupply;
  // Total Kims "released" into the market
  uint256 public kimsCreated;
  // Total Kims on sale at any given time
  uint256 public kimsOnAuction;
  // This is the cut each seller will take on the sale of a KIM
  uint256 public sellerCut;
  // A variable to house mathematic function used in _computeCut function
  uint constant feeDivisor = 100;

  // Map an owners address to the total amount of KIMS that they own
  mapping (address => uint256) public balanceOf;
  // Map the KIM to the owner, "Who owns this Kim?"
  mapping (uint => address) public tokenToOwner;
  // This creates a mapping of the tokenId to an Auction
  mapping (uint256 => TokenAuction) public tokenAuction;
  // How much ether does this wallet have to withdraw?
  mapping (address => uint) public pendingWithdrawals;

  // This generates a public event on the blockchain that will notify clients
  event Transfer(address indexed from, address indexed to, uint256 value);
  event TokenAuctionCreated(uint256 tokenIndex, address seller, uint256 sellPrice);
  event TokenAuctionCompleted(uint256 tokenIndex, address seller, address buyer, uint256 sellPrice);
  event Withdrawal(address to, uint256 amount);

  /* Initializes contract with initial supply tokens to the creator of the contract */
  function KimContract() public {
    // the creator of the contract is the initial CEO
    ceoAddress = msg.sender;
    // the creator of the contract is also the initial COO
    cooAddress = msg.sender;
    // Initiate the contract with inital supply of Kims
    totalSupply = 5000;
    // Give all initial kims to the contract itself
    balanceOf[this] = totalSupply;              // Give the creator all initial tokens
    // This is what we will call KIMs
    name = "KimJongCrypto";
    symbol = "KJC";
    // Declaring seller cut on initalization of the contract
    sellerCut = 95;
  }

  // contstruct the array struct
  struct TokenAuction {
    bool isForSale;
    uint256 tokenIndex;
    address seller;
    uint256 sellPrice;
    uint256 startedAt;
  }


  // Only the COO can release new KIMS into the market
  // We do not have power over the MAXIMUM amount of KIMS that will exist in the future
  // That was declared when we created the contract
  // KIMJONGCRYPTO.COM will release KIMS periodically to maintain a healthy market flow
  function releaseSomeKims(uint256 howMany) external onlyCOO {
    // We promise not to manipulate the markets, so we take an
    // average of all the KIMS on sale at any given time
    uint256 marketAverage = averageKimSalePrice();
    for(uint256 counter = 0; counter < howMany; counter++) {
      // map the token to the tokenOwner
      tokenToOwner[counter] = this;
      // Put the KIM out on the market for sale
      _tokenAuction(kimsCreated, this, marketAverage);
      // Record the amount of KIMS released
      kimsCreated++;
    }
  }


  // Don't want to keep this KIM?
  // Sell KIM then...
  function sellToken(uint256 tokenIndex, uint256 sellPrice) public {
    // Which KIM are you selling?
    TokenAuction storage tokenOnAuction = tokenAuction[tokenIndex];
    // Who's selling the KIM, stored into seller variable
    address seller = msg.sender;
    // Do you own this kim?
    require(_owns(seller, tokenIndex));
    // Is the KIM already on sale? Can't sell twice!
    require(tokenOnAuction.isForSale == false);
    // CLEAR! Send that KIM to Auction!
    _tokenAuction(tokenIndex, seller, sellPrice);
  }


  // INTERNAL FUNCTION, USED ONLY FROM WITHIN THE CONTRACT
  function _tokenAuction(uint256 tokenIndex, address seller, uint256 sellPrice) internal {
    // Set the Auction Struct to ON SALE
    tokenAuction[tokenIndex] = TokenAuction(true, tokenIndex, seller, sellPrice, now);
    // Fire the Auction Created Event, tell the whole wide world!
    TokenAuctionCreated(tokenIndex, seller, sellPrice);
    // Increase the amount of KIMS being sold!
    kimsOnAuction++;
  }

  // Like a KIM?
  // BUY IT!
  function buyKim(uint256 tokenIndex) public payable {
    // Store the KIM in question into tokenOnAuction variable
    TokenAuction storage tokenOnAuction = tokenAuction[tokenIndex];
    // How much is this KIM on sale for?
    uint256 sellPrice = tokenOnAuction.sellPrice;
    // Is the KIM even on sale? No monkey business!
    require(tokenOnAuction.isForSale == true);
    // You are going to have to pay for this KIM! make sure you send enough ether!
    require(msg.value >= sellPrice);
    // Who's selling their KIM?
    address seller = tokenOnAuction.seller;
    // Who's trying to buy this KIM?
    address buyer = msg.sender;
    // CLEAR!
    // Complete the auction! And transfer the KIM!
    _completeAuction(tokenIndex, seller, buyer, sellPrice);
  }



  // INTERNAL FUNCTION, USED ONLY FROM WITHIN THE CONTRACT
  function _completeAuction(uint256 tokenIndex, address seller, address buyer, uint256 sellPrice) internal {
    // Store the contract address
    address thisContract = this;
    // How much commision will the Auction House take?
    uint256 auctioneerCut = _computeCut(sellPrice);
    // How much will the seller take home?
    uint256 sellerProceeds = sellPrice - auctioneerCut;
    // If the KIM is being sold by the Auction House, then do this...
    if (seller == thisContract) {
      // Give the funds to the House
      pendingWithdrawals[seller] += sellerProceeds + auctioneerCut;
      // Close the Auction
      tokenAuction[tokenIndex] = TokenAuction(false, tokenIndex, 0, 0, 0);
      // Anounce it to the world!
      TokenAuctionCompleted(tokenIndex, seller, buyer, sellPrice);
    } else { // If the KIM is being sold by an Individual, then do this...
      // Give the funds to the seller
      pendingWithdrawals[seller] += sellerProceeds;
      // Give the funds to the House
      pendingWithdrawals[this] += auctioneerCut;
      // Close the Auction
      tokenAuction[tokenIndex] = TokenAuction(false, tokenIndex, 0, 0, 0);
      // Anounce it to the world!
      TokenAuctionCompleted(tokenIndex, seller, buyer, sellPrice);
    }
    _transfer(seller, buyer, tokenIndex);
    kimsOnAuction--;
  }


  // Don't want to sell KIM anymore?
  // Cancel Auction
  function cancelKimAuction(uint kimIndex) public {
    require(_owns(msg.sender, kimIndex));
    // Store the KIM in question into tokenOnAuction variable
    TokenAuction storage tokenOnAuction = tokenAuction[kimIndex];
    // Is the KIM even on sale? No monkey business!
    require(tokenOnAuction.isForSale == true);
    // Close the Auction
    tokenAuction[kimIndex] = TokenAuction(false, kimIndex, 0, 0, 0);
  }








  // INTERNAL FUNCTION, USED ONLY FROM WITHIN THE CONTRACT
  // Use this function to find out how much the AuctionHouse will take from this Transaction
  // All funds go to KIMJONGCRYPTO BCD(BLOCKCHAIN DEVS)!
  function _computeCut(uint256 sellPrice) internal view returns (uint) {
    return sellPrice * sellerCut / 1000;
  }





// INTERNAL FUNCTION, USED ONLY FROM WITHIN THE CONTRACT
  function _transfer(address _from, address _to, uint _value) internal {
      // Prevent transfer to 0x0 address. Use burn() instead
      require(_to != 0x0);
      // Subtract from the sender
      balanceOf[_from]--;
      // Add to the reciever
      balanceOf[_to]++;
      // map the token to the tokenOwner
      tokenToOwner[_value] = _to;
      Transfer(_from, _to, 1);
  }



  /**
   * Transfer tokens
   *
   * Send `_value` tokens to `_to` from your account
   *
   * @param _to The address of the recipient
   * @param _value the amount to send
   */
   // Go ahead and give away a KIM as a gift!
  function transfer(address _to, uint256 _value) public {
      require(_owns(msg.sender, _value));
      _transfer(msg.sender, _to, _value);
  }


  // this function returns bool of owenrship over the token.
  function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
    return tokenToOwner[_tokenId] == _claimant;
  }


  // How much are KIMS really going for now a days?
  // Run this function and find out!
  function averageKimSalePrice() public view returns (uint256) {
    uint256 sumOfAllKimAuctions = 0;
    if (kimsOnAuction == 0){
      return 0;
      } else {
        for (uint256 i = 0; i <= kimsOnAuction; i++) {
          sumOfAllKimAuctions += tokenAuction[i].sellPrice;
        }
        return sumOfAllKimAuctions / kimsOnAuction;
      }
  }



  // this function serves for users to withdraw their ethereum
  function withdraw() {
      uint amount = pendingWithdrawals[msg.sender];
      require(amount > 0);
      // Remember to zero the pending refund before
      // sending to prevent re-entrancy attacks
      pendingWithdrawals[msg.sender] = 0;
      msg.sender.transfer(amount);
      Withdrawal(msg.sender, amount);
  }



  // @dev Allows the CFO to capture the balance available to the contract.
  function withdrawBalance() external onlyCFO {
      uint balance = pendingWithdrawals[this];
      pendingWithdrawals[this] = 0;
      cfoAddress.transfer(balance);
      Withdrawal(cfoAddress, balance);
  }






}