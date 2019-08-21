pragma solidity ^0.4.18;

/**
 *
 * @author  <pratyush.bhatt@protonmail.com>
 *
 * RDFDM - Riverdimes Fiat Donation Manager
 * Version E
 *
 * Overview:
 * four basic round-up operations are supported:
 *
 * A) fiatCollected: Record Fiat Donation (collection)
 *    inputs:        charity (C), fiat amount ($XX.XX),
 *    summary:       creates a log of a fiat donation to a specified charity, C.
 *    message:       $XX.XX collected FBO Charity C, internal document #ABC
 *    - add $XX.XX to chariy's fiatBalanceIn, fiatCollected
 *
 * B) fiatToEth:     Fiat Converted to ETH
 *    inputs:        charity (C), fiat amount ($XX.XX), ETH amount (Z), document reference (ABC)
 *    summary:       deduct $XX.XX from charity C's fiatBalanceIn; credit charity C's ethBalanceIn. this operation is invoked
 *                   when fiat donations are converted to ETH. it includes a deposit of Z ETH.
 *    message(s):    On behalf of Charity C, $XX.XX used to purchase Z ETH
 *    - $XX.XX deducted from charity C's fiatBalanceIn
 *    - skims 4% of Z for RD Token holders, and 16% for operational overhead
 *    - credits charity C with 80% of Z ETH (ethBalance)
 *
 * C) ethToFiat:     ETH Converted to Fiat
 *    inputs:        charity (C), ETH amount (Z), fiat amount ($XX.XX), document reference (ABC)
 *    summary:       withdraw ETH from and convert to fiat
 *    message(s):    Z ETH converted to $XX.XX FBO Charity C
 *    - deducts Z ETH from charity C's ethBalance
 *    - adds $XX.XX to charity C's fiatBalanceOut
 *
 * D) fiatDelivered: Record Fiat Delivery to Specified Charity
 *    inputs:        charity (C), fiat amount ($XX.XX), document reference (ABC)
 *    summary:       creates a log of a fiat delivery to a specified charity, C:
 *    message:       $XX.XX delivered to Charity C, internal document #ABC
 *    - deducts the dollar amount, $XX.XX from charity's fiatBalanceOut
 *    - add $XX.XX to charity's totalDelivered
 *
 * one basic operation, unrelated to round-up
 *
 * A) ethDonation:        Direct ETH Donation to Charity
 *    inputs:             charity (C), ETH amount (Z), document reference (ABC)
 *    summary:            ETH donation to a specified charity, crediting charity's ethBalance. ETH in transaction.
 *    messages:           Z ETH donated to Charity C, internal document #ABC
 *    - add Z ETH to chariy's ethDonated
 *    - skims 0.5% of Z for RD Token holders, and 1.5% for operational overhead
 *    - credits charity C with 98% of Z ETH (ethBalance)
 *
 * in addition there are shortcut operations (related to round-up):
 *
 * A) fiatCollectedToEth: Record Fiat Donation (collection) and convert to ETH
 *    inputs:             charity (C), fiat amount ($XX.XX), ETH amount (Z), document reference (ABC)
 *    summary:            creates a log of a fiat donation to a specified charity, C; fiat donation is immediately converted to
 *                        ETH, crediting charity C's ethBalance. the transaction includes a deposit of Z ETH.
 *    messages:           $XX.XX collected FBO Charity C, internal document #ABC
 *                        On behalf of Charity C, $XX.XX used to purchase Z ETH
 *    - add $XX.XX to chariy's fiatCollected
 *    - skims 4% of Z for RD Token holders, and 16% for operational overhead
 *    - credits charity C with 80% of Z ETH (ethBalance)
 *
 * B) ethToFiatDelivered: Record ETH Conversion to Fiat; and Fiat Delivery to Specified Charity
 *    inputs:             charity (C), ETH amount (Z), fiat amount ($XX.XX), document reference (ABC)
 *    summary:            withdraw ETH from charity C's ethBalance and convert to fiat; log fiat delivery of $XX.XX.
 *    messages:           Z ETH converted to $XX.XX FBO Charity C
 *                        $XX.XX delivered to Charity C, internal document #ABC
 *    - deducts Z ETH from charity C's ethBalance
 *    - add $XX.XX to charity's totalDelivered
 *
 */

contract RDFDM {

  //events relating to donation operations
  //
  event FiatCollectedEvent(uint indexed charity, uint usd, string ref);
  event FiatToEthEvent(uint indexed charity, uint usd, uint eth);
  event EthToFiatEvent(uint indexed charity, uint eth, uint usd);
  event FiatDeliveredEvent(uint indexed charity, uint usd, string ref);
  event EthDonationEvent(uint indexed charity, uint eth);

  //events relating to adding and deleting charities
  //
  event CharityAddedEvent(uint indexed charity, string name, uint8 currency);
  event CharityModifiedEvent(uint indexed charity, string name, uint8 currency);

  //currencies
  //
  uint constant  CURRENCY_USD  = 0x01;
  uint constant  CURRENCY_EURO = 0x02;
  uint constant  CURRENCY_NIS  = 0x03;
  uint constant  CURRENCY_YUAN = 0x04;


  struct Charity {
    uint fiatBalanceIn;           // funds in external acct, collected fbo charity
    uint fiatBalanceOut;          // funds in external acct, pending delivery to charity
    uint fiatCollected;           // total collected since dawn of creation
    uint fiatDelivered;           // total delivered since dawn of creation
    uint ethDonated;              // total eth donated since dawn of creation
    uint ethCredited;             // total eth credited to this charity since dawn of creation
    uint ethBalance;              // current eth balance of this charity
    uint fiatToEthPriceAccEth;    // keep track of fiat to eth conversion price: total eth
    uint fiatToEthPriceAccFiat;   // keep track of fiat to eth conversion price: total fiat
    uint ethToFiatPriceAccEth;    // kkep track of eth to fiat conversion price: total eth
    uint ethToFiatPriceAccFiat;   // kkep track of eth to fiat conversion price: total fiat
    uint8 currency;               // fiat amounts are in smallest denomination of currency
    string name;                  // eg. "Salvation Army"
  }

  uint public charityCount;
  address public owner;
  address public manager;
  address public token;           //token-holder fees sent to this address
  address public operatorFeeAcct; //operations fees sent to this address
  mapping (uint => Charity) public charities;
  bool public isLocked;

  modifier ownerOnly {
    require(msg.sender == owner);
    _;
  }

  modifier managerOnly {
    require(msg.sender == owner || msg.sender == manager);
    _;
  }

  modifier unlockedOnly {
    require(!isLocked);
    _;
  }


  //
  //constructor
  //
  function RDFDM() public {
    owner = msg.sender;
    manager = msg.sender;
    token = msg.sender;
    operatorFeeAcct = msg.sender;
  }
  function lock() public ownerOnly { isLocked = true; }
  function setToken(address _token) public ownerOnly unlockedOnly { token = _token; }
  function setOperatorFeeAcct(address _operatorFeeAcct) public ownerOnly { operatorFeeAcct = _operatorFeeAcct; }
  function setManager(address _manager) public managerOnly { manager = _manager; }
  function deleteManager() public managerOnly { manager = owner; }


  function addCharity(string _name, uint8 _currency) public managerOnly {
    charities[charityCount].name = _name;
    charities[charityCount].currency = _currency;
    CharityAddedEvent(charityCount, _name, _currency);
    ++charityCount;
  }

  function modifyCharity(uint _charity, string _name, uint8 _currency) public managerOnly {
    require(_charity < charityCount);
    charities[_charity].name = _name;
    charities[_charity].currency = _currency;
    CharityModifiedEvent(_charity, _name, _currency);
  }



  //======== basic operations

  function fiatCollected(uint _charity, uint _fiat, string _ref) public managerOnly {
    require(_charity < charityCount);
    charities[_charity].fiatBalanceIn += _fiat;
    charities[_charity].fiatCollected += _fiat;
    FiatCollectedEvent(_charity, _fiat, _ref);
  }

  function fiatToEth(uint _charity, uint _fiat) public managerOnly payable {
    require(token != 0);
    require(_charity < charityCount);
    //keep track of fiat to eth conversion price
    charities[_charity].fiatToEthPriceAccFiat += _fiat;
    charities[_charity].fiatToEthPriceAccEth += msg.value;
    charities[_charity].fiatBalanceIn -= _fiat;
    uint _tokenCut = (msg.value * 4) / 100;
    uint _operatorCut = (msg.value * 16) / 100;
    uint _charityCredit = (msg.value - _operatorCut) - _tokenCut;
    operatorFeeAcct.transfer(_operatorCut);
    token.transfer(_tokenCut);
    charities[_charity].ethBalance += _charityCredit;
    charities[_charity].ethCredited += _charityCredit;
    FiatToEthEvent(_charity, _fiat, msg.value);
  }

  function ethToFiat(uint _charity, uint _eth, uint _fiat) public managerOnly {
    require(_charity < charityCount);
    require(charities[_charity].ethBalance >= _eth);
    //keep track of fiat to eth conversion price
    charities[_charity].ethToFiatPriceAccFiat += _fiat;
    charities[_charity].ethToFiatPriceAccEth += _eth;
    charities[_charity].ethBalance -= _eth;
    charities[_charity].fiatBalanceOut += _fiat;
    //withdraw funds to the caller
    msg.sender.transfer(_eth);
    EthToFiatEvent(_charity, _eth, _fiat);
  }

  function fiatDelivered(uint _charity, uint _fiat, string _ref) public managerOnly {
    require(_charity < charityCount);
    require(charities[_charity].fiatBalanceOut >= _fiat);
    charities[_charity].fiatBalanceOut -= _fiat;
    charities[_charity].fiatDelivered += _fiat;
    FiatDeliveredEvent(_charity, _fiat, _ref);
  }

  //======== unrelated to round-up
  function ethDonation(uint _charity) public payable {
    require(token != 0);
    require(_charity < charityCount);
    uint _tokenCut = (msg.value * 1) / 200;
    uint _operatorCut = (msg.value * 3) / 200;
    uint _charityCredit = (msg.value - _operatorCut) - _tokenCut;
    operatorFeeAcct.transfer(_operatorCut);
    token.transfer(_tokenCut);
    charities[_charity].ethDonated += _charityCredit;
    charities[_charity].ethBalance += _charityCredit;
    charities[_charity].ethCredited += _charityCredit;
    EthDonationEvent(_charity, msg.value);
  }


  //======== combo operations
  function fiatCollectedToEth(uint _charity, uint _fiat, string _ref) public managerOnly payable {
    require(token != 0);
    require(_charity < charityCount);
    charities[_charity].fiatCollected += _fiat;
    //charities[_charity].fiatBalanceIn does not change, since we immediately convert to eth
    //keep track of fiat to eth conversion price
    charities[_charity].fiatToEthPriceAccFiat += _fiat;
    charities[_charity].fiatToEthPriceAccEth += msg.value;
    uint _tokenCut = (msg.value * 4) / 100;
    uint _operatorCut = (msg.value * 16) / 100;
    uint _charityCredit = (msg.value - _operatorCut) - _tokenCut;
    operatorFeeAcct.transfer(_operatorCut);
    token.transfer(_tokenCut);
    charities[_charity].ethBalance += _charityCredit;
    charities[_charity].ethCredited += _charityCredit;
    FiatCollectedEvent(_charity, _fiat, _ref);
    FiatToEthEvent(_charity, _fiat, msg.value);
  }

  function ethToFiatDelivered(uint _charity, uint _eth, uint _fiat, string _ref) public managerOnly {
    require(_charity < charityCount);
    require(charities[_charity].ethBalance >= _eth);
    //keep track of fiat to eth conversion price
    charities[_charity].ethToFiatPriceAccFiat += _fiat;
    charities[_charity].ethToFiatPriceAccEth += _eth;
    charities[_charity].ethBalance -= _eth;
    //charities[_charity].fiatBalanceOut does not change, since we immediately deliver
    //withdraw funds to the caller
    msg.sender.transfer(_eth);
    EthToFiatEvent(_charity, _eth, _fiat);
    charities[_charity].fiatDelivered += _fiat;
    FiatDeliveredEvent(_charity, _fiat, _ref);
  }


  //note: constant fcn does not need safe math
  function divRound(uint256 _x, uint256 _y) pure internal returns (uint256) {
    uint256 z = (_x + (_y / 2)) / _y;
    return z;
  }

  function quickAuditEthCredited(uint _charityIdx) public constant returns (uint _fiatCollected,
                                                                            uint _fiatToEthNotProcessed,
                                                                            uint _fiatToEthProcessed,
                                                                            uint _fiatToEthPricePerEth,
                                                                            uint _fiatToEthCreditedSzabo,
                                                                            uint _fiatToEthAfterFeesSzabo,
                                                                            uint _ethDonatedSzabo,
                                                                            uint _ethDonatedAfterFeesSzabo,
                                                                            uint _totalEthCreditedSzabo,
                                                                            int _quickDiscrepancy) {
    require(_charityIdx < charityCount);
    Charity storage _charity = charities[_charityIdx];
    _fiatCollected = _charity.fiatCollected;                                                   //eg. $450 = 45000
    _fiatToEthNotProcessed = _charity.fiatBalanceIn;                                           //eg.            0
    _fiatToEthProcessed = _fiatCollected - _fiatToEthNotProcessed;                             //eg.        45000
    if (_charity.fiatToEthPriceAccEth == 0) {
      _fiatToEthPricePerEth = 0;
      _fiatToEthCreditedSzabo = 0;
    } else {
      _fiatToEthPricePerEth = divRound(_charity.fiatToEthPriceAccFiat * (1 ether),             //eg. 45000 * 10^18 = 45 * 10^21
                                       _charity.fiatToEthPriceAccEth);                         //eg 1.5 ETH        = 15 * 10^17
                                                                                               //               --------------------
                                                                                               //                     3 * 10^4 (30000 cents per ether)
      uint _szaboPerEth = 1 ether / 1 szabo;
      _fiatToEthCreditedSzabo = divRound(_fiatToEthProcessed * _szaboPerEth,                  //eg. 45000 * 1,000,000 / 30000 = 1,500,000 (szabo)
                                          _fiatToEthPricePerEth);
      _fiatToEthAfterFeesSzabo = divRound(_fiatToEthCreditedSzabo * 8, 10);                   //eg. 1,500,000 * 8 / 10 = 1,200,000 (szabo)
    }
    _ethDonatedSzabo = divRound(_charity.ethDonated, 1 szabo);                                //eg. 1 ETH = 1 * 10^18 / 10^12 = 1,000,000 (szabo)
    _ethDonatedAfterFeesSzabo = divRound(_ethDonatedSzabo * 98, 100);                         //eg. 1,000,000 * 98/100 = 980,000 (szabo)
    _totalEthCreditedSzabo = _fiatToEthAfterFeesSzabo + _ethDonatedAfterFeesSzabo;            //eg  1,200,000 + 980,000 = 2,180,000 (szabo)
    uint256 tecf = divRound(_charity.ethCredited, 1 szabo);                                   //eg. 2180000000000000000 * (10^-12) = 2,180,000
    _quickDiscrepancy = int256(_totalEthCreditedSzabo) - int256(tecf);                        //eg. 0
  }




  //note: contant fcn does not need safe math
  function quickAuditFiatDelivered(uint _charityIdx) public constant returns (uint _totalEthCreditedSzabo,
                                                                              uint _ethNotProcessedSzabo,
                                                                              uint _processedEthCreditedSzabo,
                                                                              uint _ethToFiatPricePerEth,
                                                                              uint _ethToFiatCreditedFiat,
                                                                              uint _ethToFiatNotProcessed,
                                                                              uint _ethToFiatProcessed,
                                                                              uint _fiatDelivered,
                                                                              int _quickDiscrepancy) {
    require(_charityIdx < charityCount);
    Charity storage _charity = charities[_charityIdx];
    _totalEthCreditedSzabo = divRound(_charity.ethCredited, 1 szabo);                          //eg. 2180000000000000000 * (10^-12) = 2,180,000
    _ethNotProcessedSzabo = divRound(_charity.ethBalance, 1 szabo);                            //eg. 1 ETH = 1 * 10^18 / 10^12 = 1,000,000 (szabo)
    _processedEthCreditedSzabo = _totalEthCreditedSzabo - _ethNotProcessedSzabo;               //eg  1,180,000 szabo
    if (_charity.ethToFiatPriceAccEth == 0) {
      _ethToFiatPricePerEth = 0;
      _ethToFiatCreditedFiat = 0;
    } else {
      _ethToFiatPricePerEth = divRound(_charity.ethToFiatPriceAccFiat * (1 ether),             //eg. 35400 * 10^18 = 3540000 * 10^16
                                       _charity.ethToFiatPriceAccEth);                         //eg  1.180 ETH     =     118 * 10^16
                                                                                               //               --------------------
                                                                                               //                      30000 (30000 cents per ether)
      uint _szaboPerEth = 1 ether / 1 szabo;
      _ethToFiatCreditedFiat = divRound(_processedEthCreditedSzabo * _ethToFiatPricePerEth,    //eg. 1,180,000 * 30000 / 1,000,000 = 35400
                                        _szaboPerEth);
    }
    _ethToFiatNotProcessed = _charity.fiatBalanceOut;
    _ethToFiatProcessed = _ethToFiatCreditedFiat - _ethToFiatNotProcessed;
    _fiatDelivered = _charity.fiatDelivered;
    _quickDiscrepancy = int256(_ethToFiatProcessed) - int256(_fiatDelivered);
  }


  //
  // default payable function.
  //
  function () public payable {
    revert();
  }

  //for debug
  //only available before the contract is locked
  function haraKiri() public ownerOnly unlockedOnly {
    selfdestruct(owner);
  }

}