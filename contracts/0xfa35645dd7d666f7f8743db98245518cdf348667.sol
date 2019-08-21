pragma solidity ^0.4.24;
/***
 * https://templeofeth.io
 *
 * Tribal Warfare.
 *
 * A timer countdown - starts 12 mins.
 * 6 Tribal masks flipping
 * Price increase by 35% per flip
 * TMPL tokens 10%
 * Dev fee: 5 %
 * 110% previous owner.
 * 5% goes into current pot.
 * 5% goes into next pot.
 * Each mask has a “time power” that adds 2,4,6,8,10,12 minutes to the timer when the card flips.
 * When the timer runs out the round ends and the last mask to flip wins the current pot.
 * Next round starts on next flip - prices are reset.
 *
 * Temple Warning: Do not play with more than you can afford to lose.
 */

contract TempleInterface {
  function purchaseFor(address _referredBy, address _customerAddress) public payable returns (uint256);
}

contract TribalWarfare {

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
    require(paused == false);
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

    event onRoundEnded(
         uint256 indexed roundNumber,
         uint256 indexed tokenId,
         address owner,
         uint256 winnings
      );

  /*==============================
  =            CONSTANTS         =
  ==============================*/

  uint256 private increaseRatePercent =  135;
  uint256 private devFeePercent =  5;
  uint256 private currentPotPercent =  5;
  uint256 private nextPotPercent =  5;
  uint256 private exchangeTokenPercent =  10;
  uint256 private previousOwnerPercent =  110;
  uint256 private initialRoundDuration =  12 minutes;

  /*==============================
  =            STORAGE           =
  ==============================*/

  /// @dev A mapping from token IDs to the address that owns them.
  mapping (uint256 => address) public tokenIndexToOwner;

  // @dev A mapping from owner address to count of tokens that address owns.
  mapping (address => uint256) private ownershipTokenCount;

  // @dev The address of the owner
  address public contractOwner;

  // @dev Current dev fee
  uint256 public currentDevFee = 0;

  // @dev The address of the temple contract
  address public templeOfEthaddress = 0x0e21902d93573c18fd0acbadac4a5464e9732f54; // MAINNET

  /// @dev Interface to exchange
  TempleInterface public templeContract;

  // @dev paused
  bool public paused = false;

  uint256 public currentPot =  0;
  uint256 public nextPot =  0;
  uint256 public roundNumber =  0;
  uint256 public roundEndingTime =  0;
  uint256 public lastFlip =  0; // the last token to flip

  /*==============================
  =            DATATYPES         =
  ==============================*/

  struct TribalMask {
    string name;
    uint256 basePrice;
    uint256 currentPrice;
    uint256 timePowerMinutes;
  }

  TribalMask [6] public tribalMasks;

  constructor () public {

    contractOwner = msg.sender;
    templeContract = TempleInterface(templeOfEthaddress);
    paused=true;

    TribalMask memory _Yucatec = TribalMask({
            name: "Yucatec",
            basePrice: 0.018 ether,
            currentPrice: 0.018 ether,
            timePowerMinutes: 12 minutes
            });

    tribalMasks[0] =  _Yucatec;

    TribalMask memory _Chiapas = TribalMask({
            name: "Chiapas",
            basePrice: 0.020 ether,
            currentPrice: 0.020 ether,
            timePowerMinutes: 10 minutes
            });

    tribalMasks[1] =  _Chiapas;

    TribalMask memory _Kekchi = TribalMask({
            name: "Kekchi",
            basePrice: 0.022 ether,
            currentPrice: 0.022 ether,
            timePowerMinutes: 8 minutes
            });

    tribalMasks[2] =  _Kekchi;

    TribalMask memory _Chontal = TribalMask({
            name: "Chontal",
            basePrice: 0.024 ether,
            currentPrice: 0.024 ether,
            timePowerMinutes: 6 minutes
            });

    tribalMasks[3] =  _Chontal;

    TribalMask memory _Akatek = TribalMask({
            name: "Akatek",
            basePrice: 0.028 ether,
            currentPrice: 0.028 ether,
            timePowerMinutes: 4 minutes
            });

    tribalMasks[4] =  _Akatek;

    TribalMask memory _Itza = TribalMask({
            name: "Itza",
            basePrice: 0.030 ether,
            currentPrice: 0.030 ether,
            timePowerMinutes: 2 minutes
            });

    tribalMasks[5] =  _Itza;

    _transfer(0x0, contractOwner, 0);
    _transfer(0x0, contractOwner, 1);
    _transfer(0x0, contractOwner, 2);
    _transfer(0x0, contractOwner, 3);
    _transfer(0x0, contractOwner, 4);
    _transfer(0x0, contractOwner, 5);

  }

  /// @notice Returns all the relevant information about a specific token.
  /// @param _tokenId The tokenId of the token of interest.
  function getTribalMask(uint256 _tokenId) public view returns (
    string maskName,
    uint256 basePrice,
    uint256 currentPrice,
    address currentOwner
  ) {
    TribalMask storage mask = tribalMasks[_tokenId];
    maskName = mask.name;
    basePrice = mask.basePrice;
    currentPrice = priceOf(_tokenId);
    currentOwner = tokenIndexToOwner[_tokenId];
  }

  /// For querying owner of token
  /// @param _tokenId The tokenID for owner inquiry
  function ownerOf(uint256 _tokenId)
    public
    view
    returns (address owner)
  {
    owner = tokenIndexToOwner[_tokenId];
    require(owner != address(0));
  }

  function () public payable {
      // allow donations to the pots for seeding etc.
      currentPot = currentPot + SafeMath.div(msg.value,2);
      nextPot = nextPot + SafeMath.div(msg.value,2);
  }

 function start() public payable onlyOwner {
   roundNumber = 1;
   roundEndingTime = now + initialRoundDuration;
   currentPot = currentPot + SafeMath.div(msg.value,2);
   nextPot = nextPot + SafeMath.div(msg.value,2);
   paused = false;
 }

 function isRoundEnd() public view returns (bool){
     return (now>roundEndingTime);
 }

 function newRound() internal {
   // round is over
   // distribute the winnings
    tokenIndexToOwner[lastFlip].transfer(currentPot);
   // some event
   emit onRoundEnded(roundNumber, lastFlip, tokenIndexToOwner[lastFlip], currentPot);

   // reset prices
   tribalMasks[0].currentPrice=tribalMasks[0].basePrice;
   tribalMasks[1].currentPrice=tribalMasks[1].basePrice;
   tribalMasks[2].currentPrice=tribalMasks[2].basePrice;
   tribalMasks[3].currentPrice=tribalMasks[3].basePrice;
   tribalMasks[4].currentPrice=tribalMasks[4].basePrice;
   tribalMasks[5].currentPrice=tribalMasks[5].basePrice;
   roundNumber++;
   roundEndingTime = now + initialRoundDuration;
   currentPot = nextPot;
   nextPot = 0;
 }

  // Allows someone to send ether and obtain the token
  function purchase(uint256 _tokenId , address _referredBy) public payable notContract notPaused easyOnGas  {

    // check if round ends
    if (now >= roundEndingTime){
        newRound();
    }

    uint256 currentPrice = tribalMasks[_tokenId].currentPrice;
    // Making sure sent amount is greater than or equal to the sellingPrice
    require(msg.value >= currentPrice);

    address oldOwner = tokenIndexToOwner[_tokenId];
    address newOwner = msg.sender;

     // Making sure token owner is not sending to self
    require(oldOwner != newOwner);

    // Safety check to prevent against an unexpected 0x0 default.
    require(_addressNotNull(newOwner));

    uint256 previousOwnerGets = SafeMath.mul(SafeMath.div(currentPrice,increaseRatePercent),previousOwnerPercent);
    uint256 exchangeTokensAmount = SafeMath.mul(SafeMath.div(currentPrice,increaseRatePercent),exchangeTokenPercent);
    uint256 devFeeAmount = SafeMath.mul(SafeMath.div(currentPrice,increaseRatePercent),devFeePercent);
    currentPot = currentPot + SafeMath.mul(SafeMath.div(currentPrice,increaseRatePercent),currentPotPercent);
    nextPot = nextPot + SafeMath.mul(SafeMath.div(currentPrice,increaseRatePercent),nextPotPercent);

    // ovebid should be discouraged but not punished at round end.
    if (msg.value > currentPrice){
      if (now < roundEndingTime){
        nextPot = nextPot + (msg.value - currentPrice);
      }else{
        // hardly fair to punish round ender
        msg.sender.transfer(msg.value - currentPrice);
      }
    }

    currentDevFee = currentDevFee + devFeeAmount;

    templeContract.purchaseFor.value(exchangeTokensAmount)(_referredBy, msg.sender);

    // do the sale
    _transfer(oldOwner, newOwner, _tokenId);

    // set new price
    tribalMasks[_tokenId].currentPrice = SafeMath.mul(SafeMath.div(currentPrice,100),increaseRatePercent);
    // extend the time
    roundEndingTime = roundEndingTime + tribalMasks[_tokenId].timePowerMinutes;

    lastFlip = _tokenId;
    // Pay previous tokenOwner if owner is not contract
    if (oldOwner != address(this)) {
      if (oldOwner.send(previousOwnerGets)){}
    }

    emit onTokenSold(_tokenId, currentPrice, oldOwner, newOwner, tribalMasks[_tokenId].name);

  }

  function priceOf(uint256 _tokenId) public view returns (uint256 price) {
      if(isRoundEnd()){
        return  tribalMasks[_tokenId].basePrice;
      }
    return tribalMasks[_tokenId].currentPrice;
  }

  /*** PRIVATE FUNCTIONS ***/
  /// Safety check on _to address to prevent against an unexpected 0x0 default.
  function _addressNotNull(address _to) private pure returns (bool) {
    return _to != address(0);
  }

  /// Check for token ownership
  function _owns(address claimant, uint256 _tokenId) private view returns (bool) {
    return claimant == tokenIndexToOwner[_tokenId];
  }

  /// @dev Assigns ownership of a specific token to an address.
  function _transfer(address _from, address _to, uint256 _tokenId) private {

    // no transfer to contract
    uint length;
    assembly { length := extcodesize(_to) }
    require (length == 0);

    ownershipTokenCount[_to]++;
    //transfer ownership
    tokenIndexToOwner[_tokenId] = _to;

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