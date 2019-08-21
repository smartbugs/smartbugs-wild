pragma solidity ^0.4.24;

/*** @title SafeMath
 * @dev https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol */
library SafeMath {
  
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }
  
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    return a / b;
  }
  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

interface ERC20 {
  function transfer (address _beneficiary, uint256 _tokenAmount) external returns (bool);
  function mintFromICO(address _to, uint256 _amount) external  returns(bool);
  function buyTokenICO(address _investor, uint256 _value) external  returns(bool);
}

/**
 * @title Ownable
 * @dev https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/ownership/Ownable.sol */
contract Ownable {
  address public owner;
  
  constructor() public {
    owner = msg.sender;
  }
  
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}

/**
 * @title MainCrowdSale
 * @dev https://github.com/elephant-marketing/*/

contract MainSale is Ownable {
  
  ERC20 public token;
  
  ERC20 public BuyBackContract;
  
  using SafeMath for uint;
  
  address public backEndOperator = msg.sender;
  
  address team = 0x550cBC2C3Ac03f8f1d950FEf755Cd664fc498036; // 10 % - founders
  
  address bounty = 0x8118317911B0De31502aC978e1dD38e9EeE92538; // 2 % - bounty
  
  
  mapping(address=>bool) public whitelist;
  
  mapping(address => uint256) public investedEther;
  
  mapping(address => uint8) public typeOfInvestors;
  
  
  uint256 public startMainSale = 1539561600; // Monday, 15-Oct-18 00:00:00 UTC
  
  uint256 public endMainSale = 1544831999; // Friday, 14-Dec-18 23:59:59 UTC
  
  
  uint256 public stage1Sale = startMainSale + 14 days; // 0- 7  days
  
  uint256 public stage2Sale = startMainSale + 28 days; // 8 - 14 days
  
  uint256 public stage3Sale = startMainSale + 42 days; // 15 - 21  days
  
  
  uint256 public investors;
  
  uint256 public weisRaised;
  
  uint256 public buyPrice; // 1 USD
  
  uint256 public dollarPrice;
  
  uint256 public soldTokensMainSale;
  
  uint256 public softcapMainSale = 18500000*1e18; // 18,500,000 ANG - !!! в зачет пойдут бонусные
  
  uint256 public hardCapMainSale = 103500000*1e18; // 103,500,000 ANG - !!! в зачет пойдут бонусные
  
  
  event Authorized(address wlCandidate, uint timestamp, uint8 investorType);
  
  event Revoked(address wlCandidate, uint timestamp);
  
  event UpdateDollar(uint256 time, uint256 _rate);
  
  event Refund(uint256 sum, address investor);
  
  
  
  modifier backEnd() {
    require(msg.sender == backEndOperator || msg.sender == owner);
    _;
  }
  
  
  constructor(ERC20 _token, uint256 usdETH) public {
    token = _token;
    dollarPrice = usdETH;
    buyPrice = (1e18/dollarPrice); // 1 usd
  }
  
  
  function setStartMainSale(uint256 newStartMainSale) public onlyOwner {
    startMainSale = newStartMainSale;
  }
  
  function setEndMainSale(uint256 newEndMainSale) public onlyOwner {
    endMainSale = newEndMainSale;
  }
  
  function setBackEndAddress(address newBackEndOperator) public onlyOwner {
    backEndOperator = newBackEndOperator;
  }
  
  function setBuyBackAddress(ERC20 newBuyBackAddress) public onlyOwner {
    BuyBackContract = newBuyBackAddress;
  }
  
  function setBuyPrice(uint256 _dollar) public onlyOwner {
    dollarPrice = _dollar;
    buyPrice = (1e18/dollarPrice); // 1 usd
    emit UpdateDollar(now, dollarPrice);
  }
  
  /*******************************************************************************
   * Whitelist's section */
  
  function authorize(address wlCandidate, uint8 investorType) public backEnd  {
    require(wlCandidate != address(0x0));
    require(!isWhitelisted(wlCandidate));
    require(investors == 1 || investorType == 2);
    
    whitelist[wlCandidate] = true;
    investors++;
    
    if (investorType == 1) {
      typeOfInvestors[wlCandidate] = 1;
    } else {
      typeOfInvestors[wlCandidate] = 2;
    }
    emit Authorized(wlCandidate, now, investorType);
  }
  
  
  function revoke(address wlCandidate) public  onlyOwner {
    whitelist[wlCandidate] = false;
    investors--;
    emit Revoked(wlCandidate, now);
  }
  
  
  function isWhitelisted(address wlCandidate) internal view returns(bool) {
    return whitelist[wlCandidate];
  }
  
  
  /*******************************************************************************
   * Payable's section */
  
  function isMainSale() public constant returns(bool) {
    return now >= startMainSale && now <= endMainSale;
  }
  
  
  function () public payable {
    require(isWhitelisted(msg.sender));
    require(isMainSale());
    mainSale(msg.sender, msg.value);
    require(soldTokensMainSale<=hardCapMainSale);
    investedEther[msg.sender] = investedEther[msg.sender].add(msg.value);
  }
  
  
  function mainSale(address _investor, uint256 _value) internal {
    uint256 tokens = _value.mul(1e18).div(buyPrice);
    uint256 tokensByDate = tokens.mul(bonusDate()).div(100);
    tokens = tokens.add(tokensByDate);
    token.mintFromICO(_investor, tokens);
    BuyBackContract.buyTokenICO(_investor, tokens);//Set count token for periods ICO
    soldTokensMainSale = soldTokensMainSale.add(tokens); // only sold
	 
    uint256 tokensTeam = tokens.mul(5).div(44); // 10 %
    token.mintFromICO(team, tokensTeam);
    
    uint256 tokensBoynty = tokens.div(44); // 2 %
    token.mintFromICO(bounty, tokensBoynty);
    
    weisRaised = weisRaised.add(_value);
  }
  
  
  function bonusDate() private view returns (uint256){
    if (now > startMainSale && now < stage1Sale) {  // 0 - 14 days preSale
      return 30;
    }
    else if (now > stage1Sale && now < stage2Sale) { // 15 - 28 days preSale
      return 20;
    }
    else if (now > stage2Sale && now < stage3Sale) { // 29 - 42 days preSale
      return 10;
    }
    else if (now > stage3Sale && now < endMainSale) { // 43 - endSale
      return 6;
    }
    
    else {
      return 0;
    }
  }
  
  
  function mintManual(address receiver, uint256 _tokens) public backEnd {
    token.mintFromICO(receiver, _tokens);
    soldTokensMainSale = soldTokensMainSale.add(_tokens);
    BuyBackContract.buyTokenICO(receiver, _tokens);//Set count token for periods ICO
	 
    uint256 tokensTeam = _tokens.mul(5).div(44); // 10 %
    token.mintFromICO(team, tokensTeam);
    
    uint256 tokensBoynty = _tokens.div(44); // 2 %
    token.mintFromICO(bounty, tokensBoynty);
  }
  
  
  function transferEthFromContract(address _to, uint256 amount) public onlyOwner {
    _to.transfer(amount);
  }
  
  
  function refundPreSale() public {
    require(soldTokensMainSale < soldTokensMainSale && now > endMainSale);
    uint256 rate = investedEther[msg.sender];
    require(investedEther[msg.sender] >= 0);
    investedEther[msg.sender] = 0;
    msg.sender.transfer(rate);
    weisRaised = weisRaised.sub(rate);
    emit Refund(rate, msg.sender);
  }
}