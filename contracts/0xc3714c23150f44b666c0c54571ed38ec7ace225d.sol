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
  function burn(uint256 _value) external returns (bool);
  function allowance(address _owner, address _spender) external returns (uint256);
  function transferFrom(address from, address to, uint256 value) external returns (bool);
  function balanceOf(address who) external  returns (uint256);
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

contract Buyback is Ownable{
    
  using SafeMath for uint;    
  
  // ERC20 standard interface
  ERC20 public token;
  
  address public tokenPreSale;
  address public tokenMainSale;

  address public backEndOperator = msg.sender;
  
  // Price 
  uint256 public buyPrice; // 1 USD
  
  uint256 public dollarPrice;
    
  // Amount of ether on the contract
  uint256 public totalFundsAvailable;
  
  uint256 public startBuyBackOne = 1639526400; // Wednesday, 15 December 2021 г., 0:00:00 Start Buyback for InvestTypeOne
  
  uint256 public startBuyBackTwo = 1734220800; // Sunday, 15 December 2024 г., 0:00:00 Start Buyback for InvestTypeTwo
  
  uint256 public percentBuyBackTypeTwo = 67;
 
  // This creates an array of invest type one addresses
  mapping (address => bool) public investTypeOne;
  
  // This creates an array of invest type two addresses
  mapping (address => bool) public investTypeTwo;
  
  // This creates an array of balance payble token in ICO period
  mapping (address => uint256) public balancesICOToken;
  
  
  modifier backEnd() {
    require(msg.sender == backEndOperator || msg.sender == owner);
    _;
  }
  
  modifier onlyICO() {
    require(msg.sender == tokenPreSale || msg.sender == tokenMainSale);
	_;
  }
	
  constructor(ERC20 _token,  address _tokenPreSale, address _tokenMainSale, uint256 usdETH) public {
    token = _token;
    tokenPreSale = _tokenPreSale;
    tokenMainSale = _tokenMainSale;
    dollarPrice = usdETH;
    buyPrice = (1e18/dollarPrice); // 1 usd
  }
  
  
  
  /*******************************************************************************
   * Setter's section */
  
  function setBuyPrice(uint256 _dollar) public onlyOwner {
    dollarPrice = _dollar;
    buyPrice = (1e18/dollarPrice); // 1 usd
  }
  
  function setBackEndAddress(address newBackEndOperator) public onlyOwner {
    backEndOperator = newBackEndOperator;
  }
  function setPercentTypeTwo(uint256 newPercent) public onlyOwner {
    percentBuyBackTypeTwo = newPercent;
  }
  
  function setstartBuyBackOne(uint256 newstartBuyBackOne) public onlyOwner {
    startBuyBackOne = newstartBuyBackOne;
  }
  
  function setstartBuyBackTwo(uint256 newstartBuyBackTwo) public onlyOwner {
    startBuyBackTwo = newstartBuyBackTwo;
  }
 
  //once the set typeInvest
  function setInvestTypeOne(address _investor) public backEnd{
      require(_investor != address(0x0));
      require(!isInvestTypeOne(_investor));
      require(!isInvestTypeTwo(_investor));
      investTypeOne[_investor] = true;
  }
  
  //once the set typeInvest
  function setInvestTypeTwo(address _investor) public backEnd{
      require(_investor != address(0x0));
      require(!isInvestTypeOne(_investor));
      require(!isInvestTypeTwo(_investor));
      investTypeTwo[_investor] = true;
  }
  
   function setPreSaleAddres(address _tokenPreSale) public onlyOwner{
      tokenPreSale = _tokenPreSale;
   }
      
  /*******************************************************************************
   * For Require's section */
   
   function isInvestTypeOne(address _investor) internal view returns(bool) {
    return investTypeOne[_investor];
  }
 
  function isInvestTypeTwo(address _investor) internal view returns(bool) {
    return investTypeTwo[_investor];
  }
     
   function isBuyBackOne() public constant returns(bool) {
    return now >= startBuyBackOne;
  }
  
   function isBuyBackTwo() public constant returns(bool) {
    return now >= startBuyBackTwo;
  }
  
  /*******************************************************************************/
  
   function buyTokenICO(address _investor, uint256 _value) onlyICO public returns (bool) {
      balancesICOToken[_investor] = balancesICOToken[_investor].add(_value);
      return true;
    }
     
    
  /*
   *  Fallback function.
   *  Stores sent ether.
   */
  function () public payable {
    totalFundsAvailable = totalFundsAvailable.add(msg.value);
  }


  /*
   *  Exchange tokens for ether. Invest type one
   */
  function buybackTypeOne() public {
        uint256 allowanceToken = token.allowance(msg.sender,this);
        require(allowanceToken != uint256(0));
        require(isInvestTypeOne(msg.sender));
        require(isBuyBackOne());
        require(balancesICOToken[msg.sender] >= allowanceToken);
        
        uint256 forTransfer = allowanceToken.mul(buyPrice).div(1e18).mul(3); //calculation Eth 100% in 3 year 
        require(totalFundsAvailable >= forTransfer);
        msg.sender.transfer(forTransfer);
        totalFundsAvailable = totalFundsAvailable.sub(forTransfer);
        
        balancesICOToken[msg.sender] = balancesICOToken[msg.sender].sub(allowanceToken);
        token.transferFrom(msg.sender, this, allowanceToken);
   }
   
   /*
   *  Exchange tokens for ether. Invest type two
   */
  function buybackTypeTwo() public {
        uint256 allowanceToken = token.allowance(msg.sender,this);
        require(allowanceToken != uint256(0));
        require(isInvestTypeTwo(msg.sender));
        require(isBuyBackTwo());
        require(balancesICOToken[msg.sender] >= allowanceToken);
        
        uint256 accumulated = percentBuyBackTypeTwo.mul(allowanceToken).div(100).mul(5).add(allowanceToken); // ~ 67%  of tokens purchased in 5 year
        uint256 forTransfer = accumulated.mul(buyPrice).div(1e18); //calculation Eth 
        require(totalFundsAvailable >= forTransfer);
        msg.sender.transfer(forTransfer);
        totalFundsAvailable = totalFundsAvailable.sub(forTransfer);
        
        balancesICOToken[msg.sender] = balancesICOToken[msg.sender].sub(allowanceToken);
        token.transferFrom(msg.sender, this, allowanceToken);
   }
   
}