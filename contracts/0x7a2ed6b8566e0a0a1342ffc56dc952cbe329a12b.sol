pragma solidity ^0.4.24;
/***
 * https://templeofeth.io
 *
 * Tiki Madness.
 *
 * 6 Tiki Masks are flipping
 * Price increases by 32% every flip.
 *
 * 10% of rise buyer gets TMPL tokens in the TempleOfETH.
 * 5% of rise goes to tiki holder fund.
 * 5% of rise goes to temple management.
 * 2% of rise goes to the God Tiki owner (The Tiki with the lowest value.)
 * The rest (110%) goes to previous owner.
 * Over 1 hour price will fall to 12.5% of the Tiki Holder fund..
 * Holders after 1 hours with no flip can collect the holder fund.
 *
 * Temple Warning: Do not play with more than you can afford to lose.
 */

contract TempleInterface {
  function purchaseFor(address _referredBy, address _customerAddress) public payable returns (uint256);
}

contract TikiMadness {

  /*=================================
  =            MODIFIERS            =
  =================================*/

  /// @dev Access modifier for owner functions
  modifier onlyOwner() {
    require(msg.sender == contractOwner);
    _;
  }

  /// @dev Prevent contract calls.
  modifier notContract() {
    require(tx.origin == msg.sender);
    _;
  }

  /// @dev notPaused
  modifier notPaused() {
    require(now > startTime);
    _;
  }

  /// @dev easyOnGas
  modifier easyOnGas() {
    require(tx.gasprice < 99999999999);
    _;
  }

  /*==============================
  =            EVENTS            =
  ==============================*/

  event onTokenSold(
       uint256 indexed tokenId,
       uint256 price,
       address prevOwner,
       address newOwner,
       string name
    );


  /*==============================
  =            CONSTANTS         =
  ==============================*/

  uint256 private increaseRatePercent =  132;
  uint256 private godTikiPercent =  2; // 2% of all sales
  uint256 private devFeePercent =  5;
  uint256 private bagHolderFundPercent =  5;
  uint256 private exchangeTokenPercent =  10;
  uint256 private previousOwnerPercent =  110;
  uint256 private priceFallDuration =  1 hours;

  /*==============================
  =            STORAGE           =
  ==============================*/

  /// @dev A mapping from tiki IDs to the address that owns them.
  mapping (uint256 => address) public tikiIndexToOwner;

  // @dev A mapping from owner address to count of tokens that address owns.
  mapping (address => uint256) private ownershipTokenCount;

  // @dev The address of the owner
  address public contractOwner;
  
  /// @dev Start Time
  uint256 public startTime = 1543692600; // GMT: Saturday, December 1, 2018 19:30:00 PM

  // @dev Current dev fee
  uint256 public currentDevFee = 0;

  // @dev The address of the temple contract
  address public templeOfEthaddress = 0x0e21902d93573c18fd0acbadac4a5464e9732f54; // MAINNET

  /// @dev Interface to temple
  TempleInterface public templeContract;

  /*==============================
  =            DATATYPES         =
  ==============================*/

  struct TikiMask {
    string name;
    uint256 basePrice; // current base price = 12.5% of holder fund.
    uint256 highPrice;
    uint256 fallDuration;
    uint256 saleTime; // when was sold last
    uint256 bagHolderFund;
  }

  TikiMask [6] public tikiMasks;

  constructor () public {

    contractOwner = msg.sender;
    templeContract = TempleInterface(templeOfEthaddress);

    TikiMask memory _Huracan = TikiMask({
            name: "Huracan",
            basePrice: 0.015 ether,
            highPrice: 0.015 ether,
            fallDuration: priceFallDuration,
            saleTime: now,
            bagHolderFund: 0
            });

    tikiMasks[0] =  _Huracan;

    TikiMask memory _Itzamna = TikiMask({
            name: "Itzamna",
            basePrice: 0.018 ether,
            highPrice: 0.018 ether,
            fallDuration: priceFallDuration,
            saleTime: now,
            bagHolderFund: 0
            });

    tikiMasks[1] =  _Itzamna;

    TikiMask memory _Mitnal = TikiMask({
            name: "Mitnal",
            basePrice: 0.020 ether,
            highPrice: 0.020 ether,
            fallDuration: priceFallDuration,
            saleTime: now,
            bagHolderFund: 0
            });

    tikiMasks[2] =  _Mitnal;

    TikiMask memory _Tepeu = TikiMask({
            name: "Tepeu",
            basePrice: 0.025 ether,
            highPrice: 0.025 ether,
            fallDuration: priceFallDuration,
            saleTime: now,
            bagHolderFund: 0
            });

    tikiMasks[3] =  _Tepeu;

    TikiMask memory _Usukan = TikiMask({
            name: "Usukan",
            basePrice: 0.030 ether,
            highPrice: 0.030 ether,
            fallDuration: priceFallDuration,
            saleTime: now,
            bagHolderFund: 0
            });

    tikiMasks[4] =  _Usukan;

    TikiMask memory _Voltan = TikiMask({
            name: "Voltan",
            basePrice: 0.035 ether,
            highPrice: 0.035 ether,
            fallDuration: priceFallDuration,
            saleTime: now,
            bagHolderFund: 0
            });

    tikiMasks[5] =  _Voltan;

    _transfer(0x0, contractOwner, 0);
    _transfer(0x0, contractOwner, 1);
    _transfer(0x0, contractOwner, 2);
    _transfer(0x0, contractOwner, 3);
    _transfer(0x0, contractOwner, 4);
    _transfer(0x0, contractOwner, 5);


  }


  /// For querying balance of a particular account
  /// @param _owner The address for balance query
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return ownershipTokenCount[_owner];
  }

  /// @notice Returns all the relevant information about a specific tiki.
  /// @param _tokenId The tokenId of the tiki of interest.
  function getTiki(uint256 _tokenId) public view returns (
    string tikiName,
    uint256 currentPrice,
    uint256 basePrice,
    address currentOwner,
    uint256 bagHolderFund,
    bool isBagFundAvailable
  ) {
    TikiMask storage tiki = tikiMasks[_tokenId];
    tikiName = tiki.name;
    currentPrice = priceOf(_tokenId);
    basePrice = tiki.basePrice;
    currentOwner = tikiIndexToOwner[_tokenId];
    bagHolderFund = tiki.bagHolderFund;
    isBagFundAvailable = now > (tiki.saleTime + priceFallDuration);
  }


  /// For querying owner of token
  /// @param _tokenId The tokenID for owner inquiry
  function ownerOf(uint256 _tokenId)
    public
    view
    returns (address owner)
  {
    owner = tikiIndexToOwner[_tokenId];
    require(owner != address(0));
  }

  // Allows someone to send ether and obtain the token
  function purchase(uint256 _tokenId , address _referredBy) public payable notContract notPaused easyOnGas  {

    address oldOwner = tikiIndexToOwner[_tokenId];
    address newOwner = msg.sender;

    uint256 currentPrice = priceOf(_tokenId);

    // Making sure token owner is not sending to self
    require(oldOwner != newOwner);

    // Safety check to prevent against an unexpected 0x0 default.
    require(_addressNotNull(newOwner));

    // Making sure sent amount is greater than or equal to the sellingPrice
    require(msg.value >= currentPrice);

    uint256 previousOwnerGets = SafeMath.mul(SafeMath.div(currentPrice,increaseRatePercent),previousOwnerPercent);
    uint256 exchangeTokensAmount = SafeMath.mul(SafeMath.div(currentPrice,increaseRatePercent),exchangeTokenPercent);
    uint256 devFeeAmount = SafeMath.mul(SafeMath.div(currentPrice,increaseRatePercent),devFeePercent);
    uint256 bagHolderFundAmount = SafeMath.mul(SafeMath.div(currentPrice,increaseRatePercent),bagHolderFundPercent);
    uint256 godTikiGets = SafeMath.mul(SafeMath.div(currentPrice,increaseRatePercent),godTikiPercent);

    if (msg.value>currentPrice){
      bagHolderFundAmount = bagHolderFundAmount + (msg.value-currentPrice); // overbidding should be discouraged
    }
    currentDevFee = currentDevFee + devFeeAmount;

    // buy the tokens for this player and include the referrer too (templenodes work)
    templeContract.purchaseFor.value(exchangeTokensAmount)(_referredBy, msg.sender);
 
    // the god tiki receives their amount.
    ownerOf(godTiki()).transfer(godTikiGets);

    // do the sale
    _transfer(oldOwner, newOwner, _tokenId);

    // set new price and saleTime
    tikiMasks[_tokenId].highPrice = SafeMath.mul(SafeMath.div(currentPrice,100),increaseRatePercent);
    tikiMasks[_tokenId].saleTime = now;
    tikiMasks[_tokenId].bagHolderFund = bagHolderFundAmount + bagHolderFundAmount;
    tikiMasks[_tokenId].basePrice = max(tikiMasks[_tokenId].basePrice,SafeMath.div(tikiMasks[_tokenId].bagHolderFund,8));  // 12.5% of the holder fund

    // Pay previous tokenOwner if owner is not contract
    if (oldOwner != address(this)) {
      if (oldOwner.send(previousOwnerGets)){}
    }

    emit onTokenSold(_tokenId, currentPrice, oldOwner, newOwner, tikiMasks[_tokenId].name);

  }

  /// @dev this is the tiki with the current lowest value - it receives 2% of ALL sales.
  function godTiki() public view returns (uint256 tokenId) {
    uint256 lowestPrice = priceOf(0);
    uint256 lowestId = 0;
    for(uint x=1;x<6;x++){
      if(priceOf(x)<lowestPrice){
        lowestId=x;
      }
    }
    return lowestId;
  }

  /// @dev calculate the current price of this token
  function priceOf(uint256 _tokenId) public view returns (uint256 price) {

    TikiMask storage tiki = tikiMasks[_tokenId];
    uint256 secondsPassed  = now - tiki.saleTime;

    if (secondsPassed >= tiki.fallDuration || tiki.highPrice==tiki.basePrice) {
            return tiki.basePrice;
    }

    uint256 totalPriceChange = tiki.highPrice - tiki.basePrice;
    uint256 currentPriceChange = totalPriceChange * secondsPassed /tiki.fallDuration;
    uint256 currentPrice = tiki.highPrice - currentPriceChange;

    return currentPrice;
  }

  /// @dev allow holder to collect fund if time is expired
  function collectBagHolderFund(uint256 _tokenId) public notPaused {
      require(msg.sender == tikiIndexToOwner[_tokenId]);
      uint256 bagHolderFund;
      bool isBagFundAvailable = false;
       (
        ,
        ,
        ,
        ,
        bagHolderFund,
        isBagFundAvailable
        ) = getTiki(_tokenId);
        require(isBagFundAvailable && bagHolderFund > 0);
        uint256 amount = bagHolderFund;
        tikiMasks[_tokenId].bagHolderFund = 0; 
        msg.sender.transfer(amount);
  }

  function paused() public view returns (bool){
    return (now < startTime);
  }

  /*** PRIVATE FUNCTIONS ***/
  /// Safety check on _to address to prevent against an unexpected 0x0 default.
  function _addressNotNull(address _to) private pure returns (bool) {
    return _to != address(0);
  }

  /// Check for token ownership
  function _owns(address claimant, uint256 _tokenId) private view returns (bool) {
    return claimant == tikiIndexToOwner[_tokenId];
  }

  /// @dev Assigns ownership of a specific token to an address.
  function _transfer(address _from, address _to, uint256 _tokenId) private {

    // no transfer to contract
    uint length;
    assembly { length := extcodesize(_to) }
    require (length == 0);

    ownershipTokenCount[_to]++;
    //transfer ownership
    tikiIndexToOwner[_tokenId] = _to;

    if (_from != address(0)) {
      ownershipTokenCount[_from]--;
    }
  }

  /// @dev Not a charity
  function collectDevFees() public onlyOwner {
      if (currentDevFee < address(this).balance){
         uint256 amount = currentDevFee;
         currentDevFee = 0;
         contractOwner.transfer(amount);
      }
  }


    /// @dev stop and start
    function max(uint a, uint b) private pure returns (uint) {
           return a > b ? a : b;
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