pragma solidity ^0.4.15;

library SafeMath {
    
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
 
  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a / b;
    return c;
  }
 
  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }
 
  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract Ownable {
    
  address public owner;
 
  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    require(newOwner != address(0));      
    owner = newOwner;
  }
 
}

contract SingleTokenCoin {
  function totalSupply() constant returns(uint256);
  function finishMinting();
  function moveUnsold(address _addr);
  function setFreeze(address _addr);
  function removeFreeze(address _addr);
  function transfer(address _to, uint256 _value);
  function newTransferManualTokensnewTransfer(address _from, address _to, uint256 _value) returns (bool);
  function transferTokens(address _to, uint256 _amount, uint256 freezeTime, uint256 _type);
  function transferTokens(address _from, address _to, uint256 _amount, uint256 freezeTime, uint256 _type);
  function withdrowTokens(address _address, uint256 _tokens);
  function setTotalSupply(address _addr);
  function tokenTransferOwnership(address _address);
  function getOwnerToken() constant returns(address);
}

contract WrapperOraclize {
  function update(string datasource, string arg) payable;
  function getWrapperData() constant returns(bytes32);
  function() external payable;
}

contract Crowdsale is Ownable {

  //string public ETHUSD;

  using SafeMath for uint256;

  //SingleTokenCoin public token = SingleTokenCoin(0xf579F37FE3129c4C897d2a9561f9D8DbEa3A0943);
    SingleTokenCoin public token;

  //Address from testnet
  //WrapperOraclize private wrapper = WrapperOraclize(0x676b33cdcc3fa7b994ca6d16cd3c9dfe3c64ec52);

  //Address from mainnet
  WrapperOraclize private wrapper = WrapperOraclize(0xfC484c66daE464CC6055d7a4782Ec8761dc9842F);

  uint256 private angel_sale_start;
  uint256 private angel_sale_finish;

  uint256 private pre_sale_start;
  uint256 private pre_sale_finish;

  uint256 private public_sale_start;
  uint256 private public_sale_finish;

  bool private isAngel;
  bool private isPreSale;
  bool private isPublic;

  uint256 private angel_rate;
  uint256 private public_rate;

  uint256 private decimals;

  uint256 private totalETH;

  address public coreTeamAddr;
  address public itDevAddr;
  address public futDevAddr;
  address public commFoundAddr;
  address public socWarefareAddr;
  address public marketingAddr;

  address public unsoldAddr;
  address public collectAddr;  
  
  bool public mintingFinished = false;

  //Storage for Founding Buyers Token
  mapping(address => uint256) private founding_buyers_token;  // 0

  //Storage for Angel Buyers ETH
  mapping(address => uint256) private angel_buyers_eth;       // 2

  //Storage for Angel Buyers Token
  mapping(address => uint256) private angel_buyers_token;     // 2

  //Storage for Angel Buyers ETH
  mapping(address => uint256) private pre_sale_buyers_eth;    // 1

  //Storage for Angel Buyers Token
  mapping(address => uint256) private pre_sale_buyers_token;  // 1

  //Storage for Angel Buyers Token
  mapping(address => uint256) private pe_buyers_token;        // 3

  //Storage for Angel Buyers ETH
  mapping(address => uint256) private public_buyers_eth;      // 4

  //Storage for Angel Buyers Token
  mapping(address => uint256) private public_buyers_token;    // 4

  address[] private founding_investors; // 0
  address[] private pre_sale_investors; // 1
  address[] private angel_investors;    // 2
  address[] private pe_investors;       // 3
  address[] private public_investors;   // 4

  uint256 private soldTokens;
  
  uint256 private maxcup;

  uint256 private totalAmount; 
  uint256 private foundingAmount; 
  uint256 private angelAmount;  
  uint256 private preSaleAmount;
  uint256 private PEInvestorAmount;
  uint256 private publicSaleAmount;

  uint256 private coreTeamAmount;
  uint256 private coreTeamAuto;
  uint256 private coreTeamManual;
  uint256 private itDevAmount;  
  uint256 private futDevAmount; 
  uint256 private commFoundAmount;
  uint256 private socWarefareAmount;
  uint256 private marketingAmount;

  uint256 private angel_sale_sold;
  uint256 private pre_sale_sold;
  uint256 private public_sale_sold;
  uint256 private founding_sold;
  uint256 private peInvestors_sold;

  uint256 private angel_sale_totalETH;
  uint256 private pre_sale_totalETH;
  uint256 private public_sale_totalETH;

  uint256 private firstPhaseAmount;
  uint256 private secondPhaseAmount; 
  uint256 private thirdPhaseAmount;  
  uint256 private fourPhaseAmount;

  uint256 private firstPhaseDiscount;
  uint256 private secondPhaseDiscount;
  uint256 private thirdPhaseDiscount;
  uint256 private fourPhaseDiscount;

  uint256 private currentPhase;

  bool private moveTokens;

  bool withdrowTokensComplete = false;  

  function Crowdsale(address token_addr) {

    token = SingleTokenCoin(token_addr);

    //set calculate rate from USD
    public_rate = 3546099290780141; // ~ 1 USD

    angel_rate = 20;

    decimals = 35460992907801; // 18 decimals

    //now
    angel_sale_start = now - 3 days;
    //06.12.2017 08:30 AM
    angel_sale_finish = 1510488000;

    //07.12.2017 08:30 AM
    pre_sale_start = 1510491600;
    //06 .01.2018 08:30 AM
    pre_sale_finish = 1512561600;

    //07.01.2018 08:30 AM
    //public_sale_start = 1512565200;
    public_sale_start = 1512565200;
    //10.01.2018 08:30 AM
    public_sale_finish = public_sale_start + 14 days;

    moveTokens = false;
    
    isAngel = true;
    isPreSale = false;
    isPublic = false;

    currentPhase = 1;

    founding_sold = 0;
    peInvestors_sold = 0;
    angel_sale_sold = 0;
    pre_sale_sold = 0;
    public_sale_sold = 0;

    angel_sale_totalETH = 0;
    pre_sale_totalETH = 0;
    public_sale_totalETH = 0;

    firstPhaseAmount = 18750000E18;     // 18 750 000;  // with 18 decimals
    secondPhaseAmount = 37500000E18;    // 37 500 000;  // with 18 decimals
    thirdPhaseAmount = 56250000E18;     // 56 250 000;  // with 18 decimals-
    fourPhaseAmount = 75000000E18;      // 75 000 000;  // with 18 decimals

    firstPhaseDiscount = 30;
    secondPhaseDiscount = 40;
    thirdPhaseDiscount = 50;
    fourPhaseDiscount = 60;

    totalAmount = 500000000E18;         // 500 000 000;  // with 18 decimals
    foundingAmount = 10000000E18;       //  10 000 000;  // with 18 decimals
    angelAmount = 25000000E18;          //  25 000 000;  // with 18 decimals
    preSaleAmount = 75000000E18;        //  75 000 000;  // with 18 decimals
    PEInvestorAmount = 50000000E18;     //  50 000 000;  // with 18 decimals
    publicSaleAmount = 100000000E18;    // 100 000 000;  // with 18 decimals

    coreTeamAmount = 100000000E18;      // 100 000 000;  // with 18 decimals
    coreTeamAuto = 60000000E18;         //  60 000 000;  // with 18 decimals
    coreTeamManual = 40000000E18;       //  40 000 000;  // with 18 decimals
    itDevAmount = 50000000E18;          //  50 000 000;  // with 18 decimals
    futDevAmount = 50000000E18;         //  50 000 000;  // with 18 decimals
    commFoundAmount = 15000000E18;      //  15 000 000;  // with 18 decimals
    socWarefareAmount = 10000000E18;    //  10 000 000;  // with 18 decimals
    marketingAmount = 15000000E18;      //  15 000 000;  // with 18 decimals

    mintingFinished = false;

    coreTeamAddr = 0xB0A3A845cfA5e2baCD3925Af85c59dE4D32D874f;
    itDevAddr = 0x61528ffdCd4BC26c81c88423018780b399Fbb8e7;
    futDevAddr = 0xA1f9C3F137496e6b8bA4445d15b0986CaA22FDe3;
    commFoundAddr = 0xC30a0E7FFad754A9AD2A1C1cFeB10e05f7C7aB6A;
    socWarefareAddr = 0xd5d692C89C83313579d02C94F4faE600fe30D1d9;
    marketingAddr = 0x5490510072b929273F65dba4B72c96cd45A99b5A;

    unsoldAddr = 0x18051b5b0F1FDb4D44eACF2FA49f19bB80105Fc1;
    collectAddr = 0xB338121B8e5dA0900a6E8580321293f3CF52E58D;

  }

  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  function setFreeze(address _addr) public onlyOwner {
    token.setFreeze(_addr);
  }

  function removeFreeze(address _addr) public onlyOwner {
    token.removeFreeze(_addr);
  }

  function moveUnsold() public onlyOwner {
    angelAmount = 0;
    preSaleAmount = 0;
    publicSaleAmount = 0;

    angel_sale_sold = 0;
    pre_sale_sold = 0;
    public_sale_sold = 0;
    token.moveUnsold(unsoldAddr);
  }

  function newTransferManualTokensnewTransfer(address _from, address _to, uint256 _value) onlyOwner returns (bool) {
    return token.newTransferManualTokensnewTransfer(_from, _to, _value);
  }

  function() external payable {
    mint();    
  }

  function bytesToUInt(bytes32 v) private constant returns (uint ret) {
    if (v == 0x0) {
        revert();
    }

    uint digit;

    for (uint i = 0; i < 32; i++) {
      digit = uint((uint(v) / (2 ** (8 * (31 - i)))) & 0xff);
      if (digit == 0 || digit == 46) {
          break;
      }
      else if (digit < 48 || digit > 57) {
          revert();
      }
      ret *= 10;
      ret += (digit - 48);
    }
    return ret;
  }

  function calculateRate() public constant returns(uint256) {
    bytes32 result = getWrapperData();
    uint256 usd = bytesToUInt(result);

    uint256 price = 1 ether / usd; //price for 1 BMC //4545454545454546;

    return price;
  }

  function calculatePrice(uint256 _usd, uint256 _pre_sale_sold) private constant returns(uint256) {
    
    if (currentPhase == 1 && pre_sale_sold + _pre_sale_sold <= firstPhaseAmount) {
      return _usd.mul(firstPhaseDiscount).div(100);
    }

    if (currentPhase == 2 && pre_sale_sold + _pre_sale_sold > firstPhaseAmount && pre_sale_sold + _pre_sale_sold <= secondPhaseAmount) {
      return _usd.mul(secondPhaseDiscount).div(100);
    }

    if (currentPhase == 3 && pre_sale_sold + _pre_sale_sold > secondPhaseAmount && pre_sale_sold + _pre_sale_sold <= thirdPhaseAmount) {
      return _usd.mul(thirdPhaseDiscount).div(100);
    }

    if (currentPhase == 4 && pre_sale_sold + _pre_sale_sold > thirdPhaseAmount && pre_sale_sold + _pre_sale_sold <= fourPhaseAmount) {
      return _usd.mul(fourPhaseDiscount).div(100);
    }

    return _usd;
  }

  function sendToAddress(address _address, uint256 _tokens, uint256 _type) canMint onlyOwner public {

   if (_type != 1 && _type != 2 && _type != 3) {
     revert();
   }

    //Founding
    if (_type == 1) {
      if (founding_sold + _tokens > foundingAmount) {
        revert();
      }

      if (founding_buyers_token[_address] == 0) {
        founding_investors.push(_address);
      }

      require(foundingAmount >= _tokens);

      founding_buyers_token[_address] = founding_buyers_token[_address].add(_tokens);
    
      founding_sold = founding_sold + _tokens;

      token.transferTokens(_address, _tokens, public_sale_start, 1);

      foundingAmount = foundingAmount - _tokens;
    }
    // PE Investors
    if (_type == 2) {
      if (peInvestors_sold + _tokens > PEInvestorAmount) {
        revert();
      }

      if (pe_buyers_token[_address] == 0) {
        pe_investors.push(_address);
      }

      require(PEInvestorAmount >= _tokens);

      pe_buyers_token[_address] = pe_buyers_token[_address].add(_tokens);
    
      peInvestors_sold = peInvestors_sold + _tokens;
      
      token.transferTokens(_address, _tokens, public_sale_start, 2);

      PEInvestorAmount = PEInvestorAmount - _tokens;
    }
    //Core Team
    if (_type == 3) {
      require(coreTeamAmount >= _tokens);
      token.transferTokens(coreTeamAddr, _address, _tokens, public_sale_start, 3);
      coreTeamAmount = coreTeamAmount - _tokens;
    } else {
      soldTokens = soldTokens + _tokens;
    }
  }

  modifier isICOFinished() {
    if (now > public_sale_finish) {
      finishMinting();
    }
    _;
  }

  modifier isAnyStage() {
    if (now > angel_sale_finish && now > pre_sale_finish && now > public_sale_finish) {
      revert();
    }

    if (now < angel_sale_start && now < pre_sale_start && now < public_sale_start) {
      revert();
    }

    _;
  }

  function setTransferOwnership(address _address) public onlyOwner {

    transferOwnership(_address);
  }

  //only for demonstrate Test Version
  function setAngelDate(uint256 _time) public onlyOwner {
    angel_sale_start = _time;
  }

  //only for demonstrate Test Version
  function setPreSaleDate(uint256 _time) public onlyOwner {
    pre_sale_start = _time;
  }

  //only for demonstrate Test Version
  function setPublicSaleDate(uint256 _time) public onlyOwner {
    public_sale_start = _time;
  }

  function getStartDates() public constant returns(uint256 _angel_sale_start, uint256 _pre_sale_start, uint256 _public_sale_start) {
    return (angel_sale_start, pre_sale_start, public_sale_start);
  }

  //only for demonstrate Test Version
  function setAngelFinishDate(uint256 _time) public onlyOwner {
    angel_sale_finish = _time;
  }

  //only for demonstrate Test Version
  function setPreSaleFinishDate(uint256 _time) public onlyOwner {
    pre_sale_finish = _time;
  }

  //only for demonstrate Test Version
  function setPublicSaleFinishDate(uint256 _time) public onlyOwner {
    public_sale_finish = _time;
  }

  function getFinishDates() public constant returns(uint256 _angel_sale_finish, uint256 _pre_sale_finish, uint256 _public_sale_finish) {
    return (angel_sale_finish, pre_sale_finish, public_sale_finish);
  }

  function mint() public canMint isICOFinished isAnyStage payable {

    if (now > angel_sale_finish && now < pre_sale_finish) {
      isPreSale = true;
      isAngel = false;
    }

    if (now > pre_sale_finish && now < public_sale_finish) {
      isPreSale = false;
      isAngel = false;
      isPublic = true;
    }

    if (now > angel_sale_finish && now < pre_sale_start) {
      revert();
    }

    if (now > pre_sale_finish && now < public_sale_start) {
      revert();
    }

    if (isAngel && angelAmount == angel_sale_sold) {
      revert();
    }

    if (isPreSale && preSaleAmount == pre_sale_sold) {
      revert();
    }

    if (isPublic && publicSaleAmount == public_sale_sold) {
      revert();
    }

    public_rate = calculateRate();

    uint256 eth = msg.value * 1E18;

    uint256 discountPrice = 0;

    if (isPreSale) {
      discountPrice = calculatePrice(public_rate, 0);
      pre_sale_totalETH = pre_sale_totalETH + eth;
    }

    if (isAngel) {
      discountPrice = public_rate.mul(angel_rate).div(100);
      angel_sale_totalETH = angel_sale_totalETH + eth;
    }

    uint currentRate = 0;

    if (isPublic) {
      currentRate = public_rate;
      public_sale_totalETH = public_sale_totalETH + eth;
    } else {
      currentRate = discountPrice;
    }

    if (eth < currentRate) {
      revert();
    }

    uint256 tokens = eth.div(currentRate);

    if (isPublic && !moveTokens) {
      if (angelAmount > angel_sale_sold) {
        uint256 angelRemainder = angelAmount - angel_sale_sold;
        publicSaleAmount = publicSaleAmount + angelRemainder;
      }
      if (preSaleAmount > pre_sale_sold) {
        uint256 preSaleRemainder = preSaleAmount - pre_sale_sold;
        publicSaleAmount = publicSaleAmount + preSaleRemainder;
      }
      moveTokens = true;
    }

    if (isPreSale) {
      uint256 availableTokensPhase = 0;
      uint256 ethToRefundPhase = 0;

      uint256 remETH = 0;

      uint256 totalTokensPhase = 0;

      if (currentPhase == 1 && pre_sale_sold + tokens > firstPhaseAmount) {
        (availableTokensPhase, ethToRefundPhase) = calculateMinorRefund(firstPhaseAmount, pre_sale_sold, currentRate, tokens);
        totalTokensPhase = availableTokensPhase;

        remETH = ethToRefundPhase;

        currentPhase = 2;

        currentRate = calculatePrice(pre_sale_sold, totalTokensPhase);
        tokens = remETH.div(currentRate);
      }

      if (currentPhase == 2 && pre_sale_sold + tokens + totalTokensPhase > secondPhaseAmount) {
        (availableTokensPhase, ethToRefundPhase) = calculateMinorRefund(secondPhaseAmount, pre_sale_sold, currentRate, tokens);
        totalTokensPhase = totalTokensPhase + availableTokensPhase;
        
        remETH = ethToRefundPhase;

        currentPhase = 3;

        currentRate = calculatePrice(pre_sale_sold, totalTokensPhase);
        tokens = remETH.div(currentRate);
      }

      if (currentPhase == 3 && pre_sale_sold + tokens + totalTokensPhase > thirdPhaseAmount) {
        (availableTokensPhase, ethToRefundPhase) = calculateMinorRefund(thirdPhaseAmount, pre_sale_sold, currentRate, tokens);
        totalTokensPhase = totalTokensPhase + availableTokensPhase;
        
        remETH = ethToRefundPhase;

        currentPhase = 4;

        currentRate = calculatePrice(pre_sale_sold, totalTokensPhase);
        tokens = remETH.div(currentRate);
      }

      if (currentPhase == 4 && pre_sale_sold + tokens + totalTokensPhase > fourPhaseAmount) {
        (availableTokensPhase, ethToRefundPhase) = calculateMinorRefund(fourPhaseAmount, pre_sale_sold, currentRate, tokens);
        totalTokensPhase = totalTokensPhase + availableTokensPhase;
        
        remETH = ethToRefundPhase;

        currentPhase = 0;

        currentRate = calculatePrice(pre_sale_sold, totalTokensPhase);
        tokens = remETH.div(currentRate);
      }

      tokens = tokens + totalTokensPhase;
    }

    if (isPreSale) {
      if (pre_sale_sold + tokens > preSaleAmount) {
        (availableTokensPhase, ethToRefundPhase) = calculateMinorRefund(preSaleAmount, pre_sale_sold, currentRate, tokens);
        tokens = availableTokensPhase;
        eth = eth - ethToRefundPhase;
        refund(ethToRefundPhase);
      }
    }

    if (isAngel) {
      if (angel_sale_sold + tokens > angelAmount) {
        (availableTokensPhase, ethToRefundPhase) = calculateMinorRefund(angelAmount, angel_sale_sold, currentRate, tokens);
        tokens = availableTokensPhase;
        eth = eth - ethToRefundPhase;
        refund(ethToRefundPhase);
        
      }    
    }

    if (isPublic) {
      if (public_sale_sold + tokens > publicSaleAmount) {
        (availableTokensPhase, ethToRefundPhase) = calculateMinorRefund(publicSaleAmount, public_sale_sold, currentRate, tokens);
        tokens = availableTokensPhase;
        eth = eth - ethToRefundPhase;
        refund(ethToRefundPhase);
        
      }
    }

    saveInfoAboutInvestors(msg.sender, eth, tokens);

    if (isAngel) {
      token.transferTokens(msg.sender, tokens, public_sale_start, 0);
    } else {
      // 0 - not freeze time; 4 - not freeze type currently;
      token.transferTokens(msg.sender, tokens, 0, 4);
    }

    soldTokens = soldTokens + tokens;
    
    totalETH = totalETH + eth;
  }

  function calculateMinorRefund(uint256 _maxcup, uint256 _sold, uint256 _rate, uint256 _tokens) private returns(uint256 _availableTokens, uint256 _ethToRefund) {
    uint256 availableTokens = _maxcup - _sold;
    uint256 tokensForRefund = _tokens - availableTokens;
    uint256 refundETH = tokensForRefund * _rate;

    return (availableTokens, refundETH);
  }

  function withdrowETH() public onlyOwner {
    require(now > public_sale_finish);

    collectAddr.transfer(this.balance);
  }

  function withdrowTokens() public onlyOwner {    
    if (!withdrowTokensComplete) {
      
      token.withdrowTokens(coreTeamAddr, coreTeamAmount);
      token.withdrowTokens(itDevAddr, itDevAmount);
      token.withdrowTokens(futDevAddr, futDevAmount);
      token.withdrowTokens(commFoundAddr, commFoundAmount);
      token.withdrowTokens(socWarefareAddr, socWarefareAmount);
      token.withdrowTokens(marketingAddr, marketingAmount);

      withdrowTokensComplete = true;
    }
  }

  function saveInfoAboutInvestors(address _address, uint256 _amount, uint256 _tokens) private {
    if (isAngel) {
      if (angel_buyers_token[_address] == 0) {
        angel_investors.push(_address);
      }

      angel_buyers_eth[_address] = angel_buyers_eth[_address].add(_amount);

      angel_buyers_token[_address] = angel_buyers_token[_address].add(_tokens);

      angel_sale_sold = angel_sale_sold + _tokens;
    }

    if (isPreSale) {
      if (pre_sale_buyers_token[_address] == 0) {
        pre_sale_investors.push(_address);
      }

      pre_sale_buyers_eth[_address] = pre_sale_buyers_eth[_address].add(_amount);

      pre_sale_buyers_token[_address] = pre_sale_buyers_token[_address].add(_tokens);
    
      pre_sale_sold = pre_sale_sold + _tokens;
    }

    if (isPublic) {
      if (public_buyers_token[_address] == 0) {
        public_investors.push(_address);
      }

      public_buyers_eth[_address] = public_buyers_eth[_address].add(_amount);

      public_buyers_token[_address] = public_buyers_token[_address].add(_tokens);
    
      public_sale_sold = public_sale_sold + _tokens;
    }
  }

  // Change for private when deploy to main net
  function finishMinting() public onlyOwner {

    if (mintingFinished) {
      revert();
    }

    token.finishMinting();

    mintingFinished = true;
  }

  function getFinishStatus() public constant returns(bool) {
    return mintingFinished;
  }

  function refund(uint256 _amount) private {
    msg.sender.transfer(_amount);
  }

  function getBalanceContract() public constant returns(uint256) {
    return this.balance;
  }

  function getSoldToken() public constant returns(uint256 _soldTokens, uint256 _angel_sale_sold, uint256 _pre_sale_sold, uint256 _public_sale_sold, uint256 _founding_sold, uint256 _peInvestors_sold) {
    return (soldTokens, angel_sale_sold, pre_sale_sold, public_sale_sold, founding_sold, peInvestors_sold);
  }

  function getInvestorsTokens(address _address, uint256 _type) public constant returns(uint256) {
    if (_type == 0) {
      return founding_buyers_token[_address];
    }
    if (_type == 1) {
      return pre_sale_buyers_token[_address];
    }
    if (_type == 2) {
      return angel_buyers_token[_address];
    }
    if (_type == 3) {
      return pe_buyers_token[_address];
    }
    if (_type == 4) {
      return public_buyers_token[_address];
    }
  }

  function getInvestorsCount(uint256 _type) public constant returns(uint256) {
    if (_type == 0) {
      return founding_investors.length;
    }
    if (_type == 1) {
      return pre_sale_investors.length;
    }
    if (_type == 2) {
      return angel_investors.length;
    }
    if (_type == 3) {
      return pe_investors.length;
    }
    if (_type == 4) {
      return public_investors.length;
    }
  }

  function getInvestorByIndex(uint256 _index, uint256 _type) public constant returns(address) {
    if (_type == 0) {
      return founding_investors[_index];
    }
    if (_type == 1) {
      return pre_sale_investors[_index];
    }
    if (_type == 2) {
      return angel_investors[_index];
    }
    if (_type == 3) {
      return pe_investors[_index];
    }
    if (_type == 4) {
      return public_investors[_index];
    }
  }

  function getLeftToken() public constant returns(uint256 _all_left, uint256 _founding_left, uint256 _angel_left, uint256 _preSaleAmount_left, uint256 _PEInvestorAmount_left, uint256 _publicSaleAmount_left) {
    uint256 all_left = token.totalSupply() != 0 ? token.totalSupply() - soldTokens : token.totalSupply();
    uint256 founding_left = foundingAmount != 0 ? foundingAmount - founding_sold : foundingAmount;
    uint256 angel_left = angelAmount != 0 ? angelAmount - angel_sale_sold : angelAmount;
    uint256 preSaleAmount_left = preSaleAmount != 0 ? preSaleAmount - pre_sale_sold : preSaleAmount;
    uint256 PEInvestorAmount_left = PEInvestorAmount != 0 ? PEInvestorAmount - peInvestors_sold : PEInvestorAmount;
    uint256 publicSaleAmount_left = publicSaleAmount != 0 ? publicSaleAmount - public_sale_sold : publicSaleAmount;

    return (all_left, founding_left, angel_left, preSaleAmount_left, PEInvestorAmount_left, publicSaleAmount_left);
  }

  function getTotalToken() public constant returns(uint256 _totalToken, uint256 _foundingAmount, uint256 _angelAmount, uint256 _preSaleAmount, uint256 _PEInvestorAmount, uint256 _publicSaleAmount) {
    return (token.totalSupply(), foundingAmount, angelAmount, preSaleAmount, PEInvestorAmount, publicSaleAmount);
  }

  function getTotalETH() public constant returns(uint256 _totalETH, uint256 _angel_sale_totalETH, uint256 _pre_sale_totalETH, uint256 _public_sale_totalETH) {
    return (totalETH, angel_sale_totalETH, pre_sale_totalETH, public_sale_totalETH);
  }

  function getCurrentPrice() public constant returns(uint256) {  
    uint256 price = calculateRate();
    return calculatePrice(price, 0);
  }

  function getContractAddress() public constant returns(address) {
    return this;
  }

  function getOwner() public constant returns(address) {
    return owner;
  }

  function sendOracleData() public payable {
    if (msg.value != 0) {
        wrapper.transfer(msg.value);
    }
    
    wrapper.update("URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHUSD).result.XETHZUSD.c.0");
  }

  function getWrapperData() public constant returns(bytes32) {
    return wrapper.getWrapperData();
  }
}