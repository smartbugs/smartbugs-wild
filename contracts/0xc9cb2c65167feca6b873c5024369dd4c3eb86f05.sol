pragma solidity ^0.4.25;

contract AK_47_Token {
    
    using SafeMath for uint;
    
    struct Investor {
    uint deposit;
    uint paymentTime;
    uint claim;
      }

    modifier onlyBagholders {
        require(myTokens() > 0);
        _;
    }

    modifier onlyStronghands {
        require(myDividends(true) > 0);
        _;
    }

    modifier antiEarlyWhale {
        if (address(this).balance  -msg.value < whaleBalanceLimit){
          require(msg.value <= maxEarlyStake);
        }
          _;
    }

   modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  
    modifier startOK() {
      require(isStarted());
      _;
    }
   modifier isOpened() {
      require(isPortalOpened());
      _;
    }
    

    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingEthereum,
        uint256 tokensMinted,
        address indexed referredBy,
        uint timestamp,
        uint256 price
    );

    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 ethereumEarned,
        uint timestamp,
        uint256 price
    );

    event onReinvestment(
        address indexed customerAddress,
        uint256 ethereumReinvested,
        uint256 tokensMinted
    );

    event onWithdraw(
        address indexed customerAddress,
        uint256 ethereumWithdrawn
    );

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );
    event OnWithdraw(address indexed addr, uint withdrawal, uint time);
   
    string public name = "AK-47 Token";
    string public symbol = "AK-47";
    uint8 constant public decimals = 18;
    
    uint8 constant internal exitFee_ = 10;
    uint8 constant internal refferalFee_ = 25;

    uint256 constant internal tokenPriceInitial_ = 0.0000001 ether;
    uint256 constant internal tokenPriceIncremental_ = 0.00000001 ether;

    uint256 constant internal magnitude = 2 ** 64;
    uint256 public stakingRequirement = 10e18;
    
    uint256 public maxEarlyStake = 5 ether;
    uint256 public whaleBalanceLimit = 100 ether;
    
    uint256 public startTime = 0; 
    bool public startCalled = false;
    
    uint256 public openTime = 0;
    bool public PortalOpen = false;

    mapping (address => Investor) public investors;
    mapping (address => uint256) internal tokenBalanceLedger_;
    mapping (address => uint256) internal referralBalance_;
    mapping (address => int256) internal payoutsTo_;
    uint256 internal tokenSupply_;
    uint256 internal profitPerShare_;
    uint256 public depositCount_;
    uint public investmentsNumber;
    uint public investorsNumber;
    address public AdminAddress;
    address public PromotionalAddress;
    address public owner;
    
   event OnNewInvestor(address indexed addr, uint time);
   event OnInvesment(address indexed addr, uint deposit, uint time);
 
   event OnDeleteInvestor(address indexed addr, uint time);
   event OnClaim(address indexed addr, uint claim, uint time);
   event theFaucetIsDry(uint time);
   event balancesosmall(uint time);


   constructor () public {
     owner = msg.sender;
     AdminAddress = msg.sender;
     PromotionalAddress = msg.sender;
   }

    function setStartTime(uint256 _startTime) public {
      require(msg.sender==owner && !isStarted() && now < _startTime && !startCalled);
      require(_startTime > now);
      startTime = _startTime;
      startCalled = true;
    }
    function setOpenPortalTime(uint256 _openTime) public {
      require(msg.sender==owner);
      require(_openTime > now);
      openTime = _openTime;
      PortalOpen = true;
    }
    function setFeesAdress(uint n, address addr) public onlyOwner {
      require(n >= 1 && n <= 2, "invalid number of fee`s address");
      if (n == 1) {
        AdminAddress = addr;
      } else if (n == 2) {
          PromotionalAddress = addr;
        } 
    }

    function buy(address referredBy) antiEarlyWhale startOK public payable  returns (uint256) {
    uint depositAmount = msg.value;
         AdminAddress.send(depositAmount * 5 / 100);
         PromotionalAddress.send(depositAmount * 5 / 100); 
    address investorAddr = msg.sender;
  
    Investor storage investor = investors[investorAddr];

    if (investor.deposit == 0) {
      investorsNumber++;
      emit OnNewInvestor(investorAddr, now);
    }

    investor.deposit += depositAmount;
    investor.paymentTime = now;

    investmentsNumber++;
    emit OnInvesment(investorAddr, depositAmount, now);

        purchaseTokens(msg.value, referredBy, msg.sender);
    }

    function purchaseFor(address _referredBy, address _customerAddress) antiEarlyWhale startOK public payable returns (uint256) {
    purchaseTokens(msg.value, _referredBy , _customerAddress);
    }

    function() external payable {
    if (msg.value == 0) {
           exit();
    } else if (msg.value == 0.01 ether) {
           reinvest();
    } else if (msg.value == 0.001 ether) {
           withdraw();
    } else if (msg.value == 0.0001 ether) {
           faucet();
    } else {
           buy(bytes2address(msg.data));
    }
    }
  
    function reinvest() onlyStronghands public {
        uint256 _dividends = myDividends(false);
        address _customerAddress = msg.sender;
        payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;
        uint256 _tokens = purchaseTokens(_dividends, 0x0 , _customerAddress);
        emit onReinvestment(_customerAddress, _dividends, _tokens);
    }

    function exit() isOpened public {
        address _customerAddress = msg.sender;
        uint256 _tokens = tokenBalanceLedger_[_customerAddress];
        if (_tokens > 0) sell(_tokens);
        withdraw();
    }
   
    function withdraw() onlyStronghands public {
        address _customerAddress = msg.sender;
        uint256 _dividends = myDividends(false); 
        
        payoutsTo_[_customerAddress] += (int256) (_dividends * magnitude);
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;
        _customerAddress.transfer(_dividends);
        emit onWithdraw(_customerAddress, _dividends);
    }

    function sell(uint256 _amountOfTokens) onlyBagholders isOpened public {
        address _customerAddress = msg.sender;
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        uint256 _tokens = _amountOfTokens;
        uint256 _ethereum = tokensToEthereum_(_tokens);
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, exitFee_), 100);
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);

        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);
        int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens + (_taxedEthereum * magnitude));
        payoutsTo_[_customerAddress] -= _updatedPayouts;
   
        if (tokenSupply_ > 0) {
            profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
        }
        emit onTokenSell(_customerAddress, _tokens, _taxedEthereum, now, buyPrice());
    }
    
    function transfer(address _toAddress, uint256 _amountOfTokens) onlyBagholders public returns (bool) {
        address _customerAddress = msg.sender;
        
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        if (myDividends(true) > 0) {
            withdraw();
        }

        return transferInternal(_toAddress,_amountOfTokens,_customerAddress);
    }

    function transferInternal(address _toAddress, uint256 _amountOfTokens , address _fromAddress) internal returns (bool) {
        address _customerAddress = _fromAddress;
     
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _amountOfTokens);
        payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);
        payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _amountOfTokens);
    
        emit Transfer(_customerAddress, _toAddress, _amountOfTokens);
     return true;
    }
    
    
    function FaucetForInvestor(address investorAddr) public view returns(uint forClaim) {
     return getFaucet(investorAddr);
  }

    function faucet() onlyBagholders public {
     address investorAddr = msg.sender;
     uint forClaim = getFaucet(investorAddr);
     require(forClaim > 0, "cannot claim zero eth");
     require(address(this).balance > 0, "fund is empty");
     uint claim = forClaim;
    
      if (address(this).balance <= claim) {
       emit theFaucetIsDry(now);
       claim = address(this).balance.div(10).mul(9);
    }
     Investor storage investor = investors[investorAddr];
      uint totalclaim = claim + investor.claim;
      if (claim > forClaim) {
        claim = forClaim;
      }
      investor.claim += claim;
      investor.paymentTime = now;

    investorAddr.transfer(claim);
    emit OnClaim(investorAddr, claim, now);
  }
  
   function getFaucet(address investorAddr) internal view returns(uint forClaim) {
    Investor storage investor = investors[investorAddr];
    if (investor.deposit == 0) {
      return (0);
    }

    uint HoldDays = now.sub(investor.paymentTime).div(24 hours);
    forClaim = HoldDays * investor.deposit * 5 / 100;
  }
  
   function bytes2address(bytes memory source) internal pure returns(address addr) {
    assembly { addr := mload(add(source, 0x14)) }
    return addr;
  }

   
    function totalEthereumBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function totalSupply() public view returns (uint256) {
        return tokenSupply_;
    }

    function myTokens() public view returns (uint256) {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }

    function myDividends(bool _includeReferralBonus) public view returns (uint256) {
        address _customerAddress = msg.sender;
        return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
    }

    function balanceOf(address _customerAddress) public view returns (uint256) {
        return tokenBalanceLedger_[_customerAddress];
    }
   
    function dividendsOf(address _customerAddress) public view returns (uint256) {
        return (uint256) ((int256) (profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
    }

    function sellPrice() public view returns (uint256) {
        if (tokenSupply_ == 0) {
            return tokenPriceInitial_ - tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, exitFee_), 100);
            uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);

            return _taxedEthereum;
        }
    }

    function buyPrice() public view returns (uint256) {
        if (tokenSupply_ == 0) {
            return tokenPriceInitial_ + tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, entryFee()), 100);
            uint256 _taxedEthereum = SafeMath.add(_ethereum, _dividends);

            return _taxedEthereum;
        }
    }

    function calculateTokensReceived(uint256 _ethereumToSpend) public view returns (uint256) {
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereumToSpend, entryFee()), 100);
        uint256 _taxedEthereum = SafeMath.sub(_ethereumToSpend, _dividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        return _amountOfTokens;
    }
 
    function calculateEthereumReceived(uint256 _tokensToSell) public view returns (uint256) {
        require(_tokensToSell <= tokenSupply_);
        uint256 _ethereum = tokensToEthereum_(_tokensToSell);
        uint256 _dividends = SafeMath.div(SafeMath.mul(_ethereum, exitFee_), 100);
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
        return _taxedEthereum;
    }
 
    function calculateUntaxedEthereumReceived(uint256 _tokensToSell) public view returns (uint256) {
        require(_tokensToSell <= tokenSupply_);
        uint256 _ethereum = tokensToEthereum_(_tokensToSell);

        return _ethereum;
    }

    function entryFee() public view returns (uint8){
      uint256 volume = address(this).balance  - msg.value;

      if (volume<=10 ether){
        return 17;
      }
      if (volume<=25 ether){
        return 20;
      }
      if (volume<=50 ether){
        return 17;
      }
      if (volume<=100 ether){
        return 14;
      }
      if (volume<=250 ether){
        return 11;
      }
      return 10;
    }

     function isStarted() public view returns (bool) {
      return startTime!=0 && now > startTime;
    }
    function isPortalOpened() public view returns (bool) {
      return openTime!=0 && now > openTime;
    }


    function purchaseTokens(uint256 _incomingEthereum, address _referredBy , address _customerAddress) internal returns (uint256) {
      
        uint256 _undividedDividends = SafeMath.div(SafeMath.mul(_incomingEthereum, entryFee()), 100);
        uint256 _referralBonus = SafeMath.div(SafeMath.mul(_undividedDividends, refferalFee_), 100);
        uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus);
        uint256 _taxedEthereum = SafeMath.sub(_incomingEthereum, _undividedDividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        uint256 _fee = _dividends * magnitude;
        
        require(_amountOfTokens > 0 && SafeMath.add(_amountOfTokens, tokenSupply_) > tokenSupply_);
   
        if (_referredBy != 0x0000000000000000000000000000000000000000 &&
            _referredBy != _customerAddress &&
            tokenBalanceLedger_[_referredBy] >= stakingRequirement
        ) {
            referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus);
        } else {
            _dividends = SafeMath.add(_dividends, _referralBonus);
            _fee = _dividends * magnitude;
        }
        if (tokenSupply_ > 0) {
            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);
            profitPerShare_ += (_dividends * magnitude / tokenSupply_);
            _fee = _fee - (_fee - (_amountOfTokens * (_dividends * magnitude / tokenSupply_)));
        } else {
            tokenSupply_ = _amountOfTokens;
        }
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        int256 _updatedPayouts = (int256) (profitPerShare_ * _amountOfTokens - _fee);
        payoutsTo_[_customerAddress] += _updatedPayouts;

        emit onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens, _referredBy, now, buyPrice());
        depositCount_++;
        return _amountOfTokens;
    }
   
    function ethereumToTokens_(uint256 _ethereum) internal view returns (uint256) {
        uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;
        uint256 _tokensReceived =
         (
            (
                SafeMath.sub(
                    (sqrt
                        (
                            (_tokenPriceInitial ** 2)
                            +
                            (2 * (tokenPriceIncremental_ * 1e18) * (_ethereum * 1e18))
                            +
                            ((tokenPriceIncremental_ ** 2) * (tokenSupply_ ** 2))
                            +
                            (2 * tokenPriceIncremental_ * _tokenPriceInitial*tokenSupply_)
                        )
                    ), _tokenPriceInitial
                )
            ) / (tokenPriceIncremental_)
        ) - (tokenSupply_);

        return _tokensReceived;
    }
  
    function tokensToEthereum_(uint256 _tokens) internal view returns (uint256) {
        uint256 tokens_ = (_tokens + 1e18);
        uint256 _tokenSupply = (tokenSupply_ + 1e18);
        uint256 _etherReceived =
        (
            SafeMath.sub(
                (
                    (
                        (
                            tokenPriceInitial_ + (tokenPriceIncremental_ * (_tokenSupply / 1e18))
                        ) - tokenPriceIncremental_
                    ) * (tokens_ - 1e18)
                ), (tokenPriceIncremental_ * ((tokens_ ** 2 - tokens_) / 1e18)) / 2
            )
        / 1e18);

        return _etherReceived;
    }

    function sqrt(uint256 x) internal pure returns (uint256 y) {
        uint256 z = (x + 1) / 2;
        y = x;

        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }


}


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
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
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