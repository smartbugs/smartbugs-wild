pragma solidity ^0.4.18;

/// @title Ownable contract
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

/// @title Ownable contract
contract Ownable {
  
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /// @dev Change ownership
  /// @param newOwner Address of the new owner
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/// @title RateSetter contract
contract RateSetter {
  
  address public rateSetter;
  event RateSetterChanged(address indexed previousRateSetter, address indexed newRateSetter);

  function RateSetter() public {
    rateSetter = msg.sender;
  }

  modifier onlyRateSetter() {
    require(msg.sender == rateSetter);
    _;
  }

  function changeRateSetter(address newRateSetter) onlyRateSetter public {
    require(newRateSetter != address(0));
    RateSetterChanged(rateSetter, newRateSetter);
    rateSetter = newRateSetter;
  }

}

/// @title ERC20 contract
/// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) public constant returns (uint);
  function transfer(address to, uint value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint value);
  
  function allowance(address owner, address spender) public constant returns (uint);
  function transferFrom(address from, address to, uint value) public returns (bool);
  function approve(address spender, uint value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint value);
}

/// @title CCWhitelist contract
contract CCWhitelist {
  function isWhitelisted(address addr) public constant returns (bool);
}

/// @title Crowdsale contract
contract Crowdsale is Ownable, RateSetter {
  using SafeMath for uint256;

  /// Token reference
  ERC20 public token;
  /// Whitelist reference
  CCWhitelist public whitelist;
  /// Presale start time (inclusive)
  uint256 public startTimePre;
  /// Presale end time (inclusive)
  uint256 public endTimePre;
  /// ICO start time (inclusive)
  uint256 public startTimeIco;
  /// ICO end time (inclusive)
  uint256 public endTimeIco;
  /// Address where the funds will be collected
  address public wallet;
  /// EUR per 1 ETH rate
  uint32 public ethEurRate;
  /// ETH per 1 BTC rate (multiplied by 100)
  uint32 public btcEthRate;
  /// Amount of tokens sold in presale
  uint256 public tokensSoldPre;
  /// Amount of tokens sold in ICO
  uint256 public tokensSoldIco;
  /// Amount of raised ethers expressed in weis
  uint256 public weiRaised;
  /// Amount of raised EUR
  uint256 public eurRaised;
  /// Number of contributions
  uint256 public contributions;
  /// Presale cap
  uint256 public preCap;
  /// Presale discount percentage
  uint8 public preDiscountPercentage;

  /// Amount of tokens in each phase
  uint256 public icoPhaseAmount1;
  uint256 public icoPhaseAmount2;
  uint256 public icoPhaseAmount3;
  uint256 public icoPhaseAmount4;

  /// Discount percentages in each phase
  uint8 public icoPhaseDiscountPercentage1;
  uint8 public icoPhaseDiscountPercentage2;
  uint8 public icoPhaseDiscountPercentage3;
  uint8 public icoPhaseDiscountPercentage4;

  /// Hard cap in EUR
  uint32 public HARD_CAP_EUR = 19170000; // 19 170 000 EUR
  /// Soft cap in EUR
  uint32 public SOFT_CAP_EUR = 2000000; // 2 000 000 EUR
  /// Hard cap in tokens
  uint256 public HARD_CAP_IN_TOKENS = 810 * 10**24; //810m CC tokens

  /// Mapping for contributors - to limit max contribution and possibly to extract info for refund if soft cap is not reached
  mapping (address => uint) public contributors;

  function Crowdsale(uint256 _startTimePre, uint256 _endTimePre, uint256 _startTimeIco, uint256 _endTimeIco, uint32 _ethEurRate, uint32 _btcEthRate, address _wallet, address _tokenAddress, address _whitelistAddress) {
    require(_startTimePre >= now);
    require(_endTimePre >= _startTimePre);
    require(_startTimeIco >= _endTimePre);
    require(_endTimeIco >= _startTimeIco);
    require(_ethEurRate > 0 && _btcEthRate > 0);
    require(_wallet != address(0));
    require(_tokenAddress != address(0));
    require(_whitelistAddress != address(0));

    startTimePre = _startTimePre;
    endTimePre = _endTimePre;
    startTimeIco = _startTimeIco;
    endTimeIco = _endTimeIco;
    ethEurRate = _ethEurRate;
    btcEthRate = _btcEthRate;
    wallet = _wallet;
    token = ERC20(_tokenAddress);
    whitelist = CCWhitelist(_whitelistAddress);
    preCap = 90 * 10**24;             // 90m tokens
    preDiscountPercentage = 50;       // 50% discount
    icoPhaseAmount1 = 135 * 10**24;   // 135m tokens 
    icoPhaseAmount2 = 450 * 10**24;   // 450m tokens
    icoPhaseAmount3 = 135 * 10**24;   // 135m tokens
    icoPhaseAmount4 = 90 * 10**24;    // 90m tokens
    icoPhaseDiscountPercentage1 = 40; // 40% discount
    icoPhaseDiscountPercentage2 = 30; // 30% discount
    icoPhaseDiscountPercentage3 = 20; // 20% discount
    icoPhaseDiscountPercentage4 = 0;  // 0% discount
  }


  function setRates(uint32 _ethEurRate, uint32 _btcEthRate) public onlyRateSetter {
    require(_ethEurRate > 0 && _btcEthRate > 0);
    ethEurRate = _ethEurRate;
    btcEthRate = _btcEthRate;
    RatesChanged(rateSetter, ethEurRate, btcEthRate);
  }

  /// @dev Fallback function for crowdsale contribution
  function () payable {
    buyTokens(msg.sender);
  }

  /// @dev Buy tokens function
  /// @param beneficiary Address which will receive the tokens
  function buyTokens(address beneficiary) public payable {
    require(beneficiary != address(0));
    require(whitelist.isWhitelisted(beneficiary));
    uint256 weiAmount = msg.value;
    require(weiAmount > 0);
    require(contributors[beneficiary].add(weiAmount) <= 200 ether);
    uint256 tokenAmount = 0;
    if (isPresale()) {
      /// Minimum contribution of 1 ether during presale
      require(weiAmount >= 1 ether); 
      tokenAmount = getTokenAmount(weiAmount, preDiscountPercentage);
      uint256 newTokensSoldPre = tokensSoldPre.add(tokenAmount);
      require(newTokensSoldPre <= preCap);
      tokensSoldPre = newTokensSoldPre;
    } else if (isIco()) {
      uint8 discountPercentage = getIcoDiscountPercentage();
      tokenAmount = getTokenAmount(weiAmount, discountPercentage);
      /// Minimum contribution 1 token during ICO
      require(tokenAmount >= 10**18); 
      uint256 newTokensSoldIco = tokensSoldIco.add(tokenAmount); 
      require(newTokensSoldIco <= HARD_CAP_IN_TOKENS);
      tokensSoldIco = newTokensSoldIco;
    } else {
      /// Stop execution and return remaining gas
      require(false);
    }
    executeTransaction(beneficiary, weiAmount, tokenAmount);
  }

  /// @dev Internal function used for calculating ICO discount percentage depending on levels
  function getIcoDiscountPercentage() internal constant returns (uint8) {
    if (tokensSoldIco <= icoPhaseAmount1) {
      return icoPhaseDiscountPercentage1;
    } else if (tokensSoldIco <= icoPhaseAmount1.add(icoPhaseAmount2)) {
      return icoPhaseDiscountPercentage2;
    } else if (tokensSoldIco <= icoPhaseAmount1.add(icoPhaseAmount2).add(icoPhaseAmount3)) { 
      return icoPhaseDiscountPercentage3;
    } else {
      return icoPhaseDiscountPercentage4;
    }
  }

  /// @dev Internal function used to calculate amount of tokens based on discount percentage
  function getTokenAmount(uint256 weiAmount, uint8 discountPercentage) internal constant returns (uint256) {
    /// Less than 100 to avoid division with zero
    require(discountPercentage >= 0 && discountPercentage < 100); 
    uint256 baseTokenAmount = weiAmount.mul(ethEurRate);
    uint256 denominator = 3 * (100 - discountPercentage);
    uint256 tokenAmount = baseTokenAmount.mul(10000).div(denominator);
    return tokenAmount;
  }

   
  /// point out that it works for the last block
  /// @dev This method is used to get the current amount user can receive for 1ETH -- Used by frontend for easier calculation
  /// @return Amount of CC tokens
  function getCurrentTokenAmountForOneEth() public constant returns (uint256) {
    if (isPresale()) {
      return getTokenAmount(1 ether, preDiscountPercentage);
    } else if (isIco()) {
      uint8 discountPercentage = getIcoDiscountPercentage();
      return getTokenAmount(1 ether, discountPercentage);
    } 
    return 0;
  }
  
  /// @dev This method is used to get the current amount user can receive for 1BTC -- Used by frontend for easier calculation
  /// @return Amount of CC tokens
  function getCurrentTokenAmountForOneBtc() public constant returns (uint256) {
    uint256 amountForOneEth = getCurrentTokenAmountForOneEth();
    return amountForOneEth.mul(btcEthRate).div(100);
  }

  /// @dev Internal function for execution of crowdsale transaction and proper logging used by payable functions
  function executeTransaction(address beneficiary, uint256 weiAmount, uint256 tokenAmount) internal {
    weiRaised = weiRaised.add(weiAmount);
    uint256 eurAmount = weiAmount.mul(ethEurRate).div(10**18);
    eurRaised = eurRaised.add(eurAmount);
    token.transfer(beneficiary, tokenAmount);
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokenAmount);
	  contributions = contributions.add(1);
    contributors[beneficiary] = contributors[beneficiary].add(weiAmount);
    wallet.transfer(weiAmount);
  }

  function changeIcoPhaseAmounts(uint256[] icoPhaseAmounts) public onlyOwner {
    require(icoPhaseAmounts.length == 4);
    uint256 sum = 0;
    for (uint i = 0; i < icoPhaseAmounts.length; i++) {
      sum = sum.add(icoPhaseAmounts[i]);
    }
    require(sum == HARD_CAP_IN_TOKENS);
    icoPhaseAmount1 = icoPhaseAmounts[0];
    icoPhaseAmount2 = icoPhaseAmounts[1];
    icoPhaseAmount3 = icoPhaseAmounts[2];
    icoPhaseAmount4 = icoPhaseAmounts[3];
    IcoPhaseAmountsChanged(icoPhaseAmount1, icoPhaseAmount2, icoPhaseAmount3, icoPhaseAmount4);
  }

  /// @dev Check if presale is active
  function isPresale() public constant returns (bool) {
    return now >= startTimePre && now <= endTimePre;
  }

  /// @dev Check if ICO is active
  function isIco() public constant returns (bool) {
    return now >= startTimeIco && now <= endTimeIco;
  }

  /// @dev Check if presale has ended
  function hasPresaleEnded() public constant returns (bool) {
    return now > endTimePre;
  }

  /// @dev Check if ICO has ended
  function hasIcoEnded() public constant returns (bool) {
    return now > endTimeIco;
  }

  /// @dev Amount of tokens that have been sold during both presale and ICO phase
  function cummulativeTokensSold() public constant returns (uint256) {
    return tokensSoldPre + tokensSoldIco;
  }

  /// @dev Function to extract mistakenly sent ERC20 tokens sent to Crowdsale contract and to extract unsold CC tokens
  /// @param _token Address of token we want to extract
  function claimTokens(address _token) public onlyOwner {
    if (_token == address(0)) { 
         owner.transfer(this.balance);
         return;
    }

    ERC20 erc20Token = ERC20(_token);
    uint balance = erc20Token.balanceOf(this);
    erc20Token.transfer(owner, balance);
    ClaimedTokens(_token, owner, balance);
  }

  /// Events
  event TokenPurchase(address indexed _purchaser, address indexed _beneficiary, uint256 _value, uint256 _amount);
  event ClaimedTokens(address indexed _token, address indexed _owner, uint _amount);
  event IcoPhaseAmountsChanged(uint256 _icoPhaseAmount1, uint256 _icoPhaseAmount2, uint256 _icoPhaseAmount3, uint256 _icoPhaseAmount4);
  event RatesChanged(address indexed _rateSetter, uint32 _ethEurRate, uint32 _btcEthRate);

}

/// @title CulturalCoinCrowdsale contract
contract CulturalCoinCrowdsale is Crowdsale {

  function CulturalCoinCrowdsale(uint256 _startTimePre, uint256 _endTimePre, uint256 _startTimeIco, uint256 _endTimeIco, uint32 _ethEurRate, uint32 _btcEthRate, address _wallet, address _tokenAddress, address _whitelistAddress) 
  Crowdsale(_startTimePre, _endTimePre, _startTimeIco, _endTimeIco, _ethEurRate, _btcEthRate, _wallet, _tokenAddress, _whitelistAddress) public {

  }

}