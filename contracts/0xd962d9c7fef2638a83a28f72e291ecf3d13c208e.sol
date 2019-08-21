pragma solidity 0.4.20;

 /**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function percent(uint value,uint numerator, uint denominator, uint precision) internal pure  returns(uint quotient) {
    uint _numerator  = numerator * 10 ** (precision+1);
    uint _quotient =  ((_numerator / denominator) + 5) / 10;
    return (value*_quotient/1000000000000000000);
  }
  
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract TREASURE {
    
    /*=====================================
    =       CONTRACT CONFIGURABLES        =
    =====================================*/
    
    // Token Details
    string public name                                      = "TREASURE";
    string public symbol                                    = "TRS";
    uint8 constant public decimals                          = 18;
    uint256 constant internal tokenPriceInitial             = 0.000000001 ether;
    
    // Token Price Increment & Decrement By 1Gwei
    uint256 constant internal tokenPriceIncDec              = 0.000000001 ether;
    
    // Proof of Stake (Default at 1 Token)
    uint256 public stakingReq                               = 1e18;
    uint256 constant internal magnitude                     = 2**64;
    
    // Dividend/Distribution Percentage
    uint8 constant internal referralFeePercent              = 5;
    uint8 constant internal dividendFeePercent              = 10;
    uint8 constant internal tradingFundWalletFeePercent     = 10;
    uint8 constant internal communityWalletFeePercent       = 10;
    
    /*================================
    =            DATASETS            =
    ================================*/
    
    // amount of shares for each address (scaled number)
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal referralBalance_;
    mapping(address => int256) internal payoutsTo_;
    mapping(address => uint256) internal sellingWithdrawBalance_;
    mapping(address => uint256) internal ambassadorAccumulatedQuota_;
    mapping(address => string) internal contractTokenHolderAddresses;

    uint256 internal tokenTotalSupply                       = 0;
    uint256 internal calReferralPercentage                  = 0;
    uint256 internal calDividendPercentage                  = 0;
    uint256 internal calculatedPercentage                   = 0;
    uint256 internal soldTokens                             = 0;
    uint256 internal tempIncomingEther                      = 0;
    uint256 internal tempProfitPerShare                     = 0;
    uint256 internal tempIf                                 = 0;
    uint256 internal tempCalculatedDividends                = 0;
    uint256 internal tempReferall                           = 0;
    uint256 internal tempSellingWithdraw                    = 0;
    uint256 internal profitPerShare_;
    
    // When this is set to true, only ambassadors can purchase tokens
    bool public onlyAmbassadors = false;
    
    // Community Wallet Address
    address internal constant CommunityWalletAddr           = address(0xa6ac94e896fBB8A2c27692e20B301D54D954071E);
    // Trading Fund Wallet Address
    address internal constant TradingWalletAddr             = address(0x40E68DF89cAa6155812225F12907960608A0B9dd);  

    // Administrator of this contract                        
    mapping(bytes32 => bool) public admin;
    
    /*=================================
    =            MODIFIERS            =
    =================================*/
    
    // Only people with tokens
    modifier onlybelievers() {
        require(myTokens() > 0);
        _;
    }
    
    // Only people with profits
    modifier onlyhodler() {
        require(myDividends(true) > 0);
        _;
    }
    
    // Only people with sold token
    modifier onlySelingholder() {
        require(sellingWithdrawBalance_[msg.sender] > 0);
        _;
    }
     
    // Admin can do following things:
    //  1. Change the name of contract.
    //  2. Change the name of token.
    //  3. Change the PoS difficulty .
    // Admin CANNOT do following things:
    //  1. Take funds out from contract.
    //  2. Disable withdrawals.
    //  3. Kill the smart contract.
    //  4. Change the price of tokens.
    modifier onlyAdmin() {
        address _adminAddress = msg.sender;
        require(admin[keccak256(_adminAddress)]);
        _;
    }
    
    /*===========================================
    =       ADMINISTRATOR ONLY FUNCTIONS        =
    ===========================================*/
    
    // Admin can manually disable the ambassador phase
    function disableInitialStage() onlyAdmin() public {
        onlyAmbassadors = false;
    }
    
    function setAdmin(bytes32 _identifier, bool _status) onlyAdmin() public {
        admin[_identifier]      = _status;
    }
    
    function setStakingReq(uint256 _tokensAmount) onlyAdmin() public {
        stakingReq              = _tokensAmount;
    }
    
    function setName(string _tokenName) onlyAdmin() public {
        name                    = _tokenName;
    }
    
    function setSymbol(string _tokenSymbol) onlyAdmin() public {
        symbol                  = _tokenSymbol;
    }
    
    /*==============================
    =            EVENTS            =
    ==============================*/
    
    event onTokenPurchase (
        address indexed customerAddress,
        uint256 incomingEthereum,
        uint256 tokensMinted,
        address indexed referredBy
    );
    
    event onTokenSell (
        address indexed customerAddress,
        uint256 tokensBurned
    );
    
    event onReinvestment (
        address indexed customerAddress,
        uint256 ethereumReinvested,
        uint256 tokensMinted
    );
    
    event onWithdraw (
        address indexed customerAddress,
        uint256 ethereumWithdrawn
    );
    
    event onSellingWithdraw (
        address indexed customerAddress,
        uint256 ethereumWithdrawn
    
    );
    
    event Transfer (
        address indexed from,
        address indexed to,
        uint256 tokens
    );
    
    /*=======================================
    =            PUBLIC FUNCTIONS            =
    =======================================*/
    
    function TREASURE() public {
        // Contract Admin
        admin[0x7cfa1051b7130edfac6eb71d17a849847cf6b7e7ad0b33fad4e124841e5acfbc] = true;
    }
    
    // Check contract Ethereum Balance
    function totalEthereumBalance() public view returns(uint) {
        return this.balance;
    }
    
    // Check tokens total supply
    function totalSupply() public view returns(uint256) {
        return tokenTotalSupply;
    }
    
    // Check token balance owned by the caller
    function myTokens() public view returns(uint256) {
        address ownerAddress = msg.sender;
        return tokenBalanceLedger_[ownerAddress];
    }
    
    // Check sold tokens
    function getSoldTokens() public view returns(uint256) {
        return soldTokens;
    }
    
    // Check dividends owned by the caller
    function myDividends(bool _includeReferralBonus) public view returns(uint256) {
        address _customerAddress = msg.sender;
        return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
    }
    
    // Check dividend balance of any single address
    function dividendsOf(address _customerAddress) view public returns(uint256) {
        return (uint256) ((int256)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
    }
    
    // Check token balance of any address
    function balanceOf(address ownerAddress) public view returns(uint256) {
        return tokenBalanceLedger_[ownerAddress]; ///need to change
    }
    
    // Check Selling Withdraw balance of address
    function sellingWithdrawBalance() view public returns(uint256) {
        address _customerAddress = msg.sender; 
        uint256 _sellingWithdraw = (uint256) (sellingWithdrawBalance_[_customerAddress]) ; // Get all balances
        return  _sellingWithdraw;
    }
    
    // Get Buy Price of 1 individual token
    function sellPrice() public view returns(uint256) {
        if(tokenTotalSupply == 0){
            return tokenPriceInitial - tokenPriceIncDec;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            return _ethereum - SafeMath.percent(_ethereum,15,100,18);
        }
    }
    
    // Get Sell Price of 1 individual token
    function buyPrice() public view returns(uint256) {
        if(tokenTotalSupply == 0){
            return tokenPriceInitial;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            return _ethereum;
        }
    }
    
    // Converts all of caller's dividends to tokens
    function reinvest() onlyhodler() public {
        address _customerAddress = msg.sender;
        // Get dividends
        uint256 _dividends                  = myDividends(true); // Retrieve Ref. Bonus later in the code
        // Calculate 10% for distribution 
        uint256  TenPercentForDistribution  = SafeMath.percent(_dividends,10,100,18);
        // Calculate 90% to reinvest into tokens
        uint256  NinetyPercentToReinvest    = SafeMath.percent(_dividends,90,100,18);
        // Dispatch a buy order with the calculatedPercentage 
        uint256 _tokens                     = purchaseTokens(NinetyPercentToReinvest, 0x0);
        // Empty their  all dividends beacuse we are reinvesting them
        payoutsTo_[_customerAddress]        +=  (int256) (SafeMath.sub(_dividends, referralBalance_[_customerAddress]) * magnitude);
        referralBalance_[_customerAddress]  = 0;
        
        // Distribute to all users as per holdings
        profitPerShare_ = SafeMath.add(profitPerShare_, (TenPercentForDistribution * magnitude) / tokenTotalSupply);
        
        // Fire Event
        onReinvestment(_customerAddress, _dividends, _tokens);
    }
    
    // Alias of sell() & withdraw() function
    function exit() public {
        // Get token count for caller & sell them all
        address _customerAddress            = msg.sender;
        uint256 _tokens                     = tokenBalanceLedger_[_customerAddress];
        if(_tokens > 0) sell(_tokens);
    
        withdraw();
    }
    
    // Withdraw all of the callers earnings
    function withdraw() onlyhodler() public {
        address _customerAddress            = msg.sender;
        // Calculate 20% of all Dividends and Transfer them to two communities
        uint256 _dividends                  = myDividends(true); // get all dividends
        // Calculate 10% for Trading Wallet
        uint256 TenPercentForTradingWallet  = SafeMath.percent(_dividends,10,100,18);
        // Calculate 10% for Community Wallet
        uint256 TenPercentForCommunityWallet= SafeMath.percent(_dividends,10,100,18);

        // Update Dividend Tracker
        payoutsTo_[_customerAddress]        +=  (int256) (SafeMath.sub(_dividends, referralBalance_[_customerAddress]) * magnitude);
        referralBalance_[_customerAddress]  = 0;
       
        // Delivery Service
        address(CommunityWalletAddr).transfer(TenPercentForCommunityWallet);
        
        // Delivery Service
        address(TradingWalletAddr).transfer(TenPercentForTradingWallet);
        
        // Calculate 80% for transfering it to Customer Address
        uint256 EightyPercentForCustomer    = SafeMath.percent(_dividends,80,100,18);

        // Delivery Service
        address(_customerAddress).transfer(EightyPercentForCustomer);
        
        // Fire Event
        onWithdraw(_customerAddress, _dividends);
    }
    
    // Withdraw all sellingWithdraw of the callers earnings
    function sellingWithdraw() onlySelingholder() public {
        address customerAddress             = msg.sender;
        uint256 _sellingWithdraw            = sellingWithdrawBalance_[customerAddress];
        
        // Empty all sellingWithdraw beacuse we are giving them ETHs
        sellingWithdrawBalance_[customerAddress] = 0;

        // Delivery Service
        address(customerAddress).transfer(_sellingWithdraw);
        
        // Fire Event
        onSellingWithdraw(customerAddress, _sellingWithdraw);
    }
    
    // Sell Tokens
    // Remember there's a 10% fee for sell
    function sell(uint256 _amountOfTokens) onlybelievers() public {
        address customerAddress                 = msg.sender;
        // Calculate 10% of tokens and distribute them 
        require(_amountOfTokens <= tokenBalanceLedger_[customerAddress] && _amountOfTokens > 1e18);
        
        uint256 _tokens                         = SafeMath.sub(_amountOfTokens, 1e18);
        uint256 _ethereum                       = tokensToEthereum_(_tokens);
        // Calculate 10% for distribution 
        uint256  TenPercentToDistribute         = SafeMath.percent(_ethereum,10,100,18);
        // Calculate 90% for customer withdraw wallet
        uint256  NinetyPercentToCustomer        = SafeMath.percent(_ethereum,90,100,18);
        
        // Burn Sold Tokens
        tokenTotalSupply                        = SafeMath.sub(tokenTotalSupply, _tokens);
        tokenBalanceLedger_[customerAddress]    = SafeMath.sub(tokenBalanceLedger_[customerAddress], _tokens);
        
        // Substract sold tokens from circulations of tokenTotalSupply
        soldTokens                              = SafeMath.sub(soldTokens,_tokens);
        
        // Update sellingWithdrawBalance of customer 
        sellingWithdrawBalance_[customerAddress] += NinetyPercentToCustomer;   
        
        // Update dividends tracker
        int256 _updatedPayouts                  = (int256) (profitPerShare_ * _tokens + (TenPercentToDistribute * magnitude));
        payoutsTo_[customerAddress]             -= _updatedPayouts; 
        
        // Distribute to all users as per holdings         
        if (tokenTotalSupply > 0) {
            // Update the amount of dividends per token
            profitPerShare_ = SafeMath.add(profitPerShare_, (TenPercentToDistribute * magnitude) / tokenTotalSupply);
        }
      
        // Fire Event
        onTokenSell(customerAddress, _tokens);
    }
    
    // Transfer tokens from the caller to a new holder
    // Remember there's a 5% fee here for transfer
    function transfer(address _toAddress, uint256 _amountOfTokens) onlybelievers() public returns(bool) {
        address customerAddress                 = msg.sender;
        // Make sure user have the requested tokens
        
        require(!onlyAmbassadors && _amountOfTokens <= tokenBalanceLedger_[customerAddress] && _amountOfTokens > 1e18);
        
        // Calculate 5% of total tokens
        uint256  FivePercentOfTokens            = SafeMath.percent(_amountOfTokens,5,100,18);
        // Calculate 95% of total tokens
        uint256  NinetyFivePercentOfTokens      = SafeMath.percent(_amountOfTokens,95,100,18);
        
        // Burn the fee tokens
        // Convert ETH to Tokens
        tokenTotalSupply                        = SafeMath.sub(tokenTotalSupply,FivePercentOfTokens);
        
        // Substract 5% from community of tokens
        soldTokens                              = SafeMath.sub(soldTokens, FivePercentOfTokens);

        // Exchange Tokens
        tokenBalanceLedger_[customerAddress]    = SafeMath.sub(tokenBalanceLedger_[customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress]         = SafeMath.add(tokenBalanceLedger_[_toAddress], NinetyFivePercentOfTokens) ;
        
        // Calculate value of all token to transfer to ETH
        uint256 FivePercentToDistribute         = tokensToEthereum_(FivePercentOfTokens);
        
        // Update dividend trackers
        payoutsTo_[customerAddress]             -= (int256) (profitPerShare_ * _amountOfTokens);
        payoutsTo_[_toAddress]                  += (int256) (profitPerShare_ * NinetyFivePercentOfTokens);
        
        // Distribute to all users as per holdings 
        profitPerShare_                         = SafeMath.add(profitPerShare_, (FivePercentToDistribute * magnitude) / tokenTotalSupply);

        // Fire Event
        Transfer(customerAddress, _toAddress, NinetyFivePercentOfTokens);
        
        return true;
    }
    
    // Function to calculate actual value after Taxes
    function calculateTokensReceived(uint256 _ethereumToSpend) public view returns(uint256) {
        // Calculate 15% for distribution 
        uint256  fifteen_percentToDistribute= SafeMath.percent(_ethereumToSpend,15,100,18);

        uint256 _dividends = SafeMath.sub(_ethereumToSpend, fifteen_percentToDistribute);
        uint256 _amountOfTokens = ethereumToTokens_(_dividends);
        
        return _amountOfTokens;
    }
    
    // Function to calculate received ETH
    function calculateEthereumReceived(uint256 _tokensToSell) public view returns(uint256) {
        require(_tokensToSell <= tokenTotalSupply);
        uint256 _ethereum = tokensToEthereum_(_tokensToSell);
        // Calculate 10% for distribution 
        uint256  ten_percentToDistribute= SafeMath.percent(_ethereum,10,100,18);
        
        uint256 _dividends = SafeMath.sub(_ethereum, ten_percentToDistribute);

        return _dividends;
    }
    
    // Convert all incoming ETH to Tokens for the caller and pass down the referral address (if any)
    function buy(address referredBy) public payable {
        purchaseTokens(msg.value, referredBy);
    }
    
    // Fallback function to handle ETH that was sent straight to the contract
    // Unfortunately we cannot use a referral address this way.
    function() payable public {
        purchaseTokens(msg.value, 0x0);
    }
    
    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/
    
    function purchaseTokens(uint256 incomingEthereum, address referredBy) internal returns(uint256) {
        // Datasets
        address customerAddress     = msg.sender;
        tempIncomingEther           = incomingEthereum;

        // Calculate Percentage for Referral (if any)
        calReferralPercentage       = SafeMath.percent(incomingEthereum,referralFeePercent,100,18);
        // Calculate Dividend
        calDividendPercentage       = SafeMath.percent(incomingEthereum,dividendFeePercent,100,18);
        // Calculate remaining amount
        calculatedPercentage        = SafeMath.percent(incomingEthereum,85,100,18);
        // Token will receive against the sent ETH
        uint256 _amountOfTokens     = ethereumToTokens_(SafeMath.percent(incomingEthereum,85,100,18));  
        uint256 _dividends          = 0;
        uint256 minOneToken         = 1 * (10 ** decimals);
        require(_amountOfTokens > minOneToken && (SafeMath.add(_amountOfTokens,tokenTotalSupply) > tokenTotalSupply));
        
        // If user referred by a Treasure Key
        if(
            // Is this a referred purchase?
            referredBy  != 0x0000000000000000000000000000000000000000 &&
            // No Cheating!!!!
            referredBy  != customerAddress &&
            // Does the referrer have at least X whole tokens?
            tokenBalanceLedger_[referredBy] >= stakingReq
        ) {
            // Give 5 % to Referral User
            referralBalance_[referredBy]    += SafeMath.percent(incomingEthereum,5,100,18);
            _dividends              = calDividendPercentage;
        } else {
            // Add the referral bonus back to the global dividend
            _dividends              = SafeMath.add(calDividendPercentage, calReferralPercentage);
        }
        
        // We can't give people infinite ETH
        if(tokenTotalSupply > 0) {
            // Add tokens to the pool
            tokenTotalSupply        = SafeMath.add(tokenTotalSupply, _amountOfTokens);
            profitPerShare_         += (_dividends * magnitude / (tokenTotalSupply));
        } else {
            // Add tokens to the pool
            tokenTotalSupply        = _amountOfTokens;
        }
        
        // Update circulating supply & the ledger address for the customer
        tokenBalanceLedger_[customerAddress] = SafeMath.add(tokenBalanceLedger_[customerAddress], _amountOfTokens);
        
        // Tells the contract that the buyer doesn't deserve dividends for the tokens before they owned them
        int256 _updatedPayouts      = (int256) (profitPerShare_ * _amountOfTokens);
        payoutsTo_[customerAddress] += _updatedPayouts;
        
        // Fire Event
        onTokenPurchase(customerAddress, incomingEthereum, _amountOfTokens, referredBy);
        
        // Calculate sold tokens here
        soldTokens += _amountOfTokens;
        
        return _amountOfTokens;

    }
    
    // Calculate token price based on an amount of incoming ETH
    // It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;
    // Some conversions occurred to prevent decimal errors or underflows/overflows in solidity code.
    function ethereumToTokens_(uint256 _ethereum) internal view returns(uint256) {
        uint256 _tokenPriceInitial  = tokenPriceInitial * 1e18;
        uint256 _tokensReceived     = 
         (
            (
                SafeMath.sub(
                    (SqRt
                        (
                            (_tokenPriceInitial**2)
                            +
                            (2*(tokenPriceIncDec * 1e18)*(_ethereum * 1e18))
                            +
                            (((tokenPriceIncDec)**2)*(tokenTotalSupply**2))
                            +
                            (2*(tokenPriceIncDec)*_tokenPriceInitial*tokenTotalSupply)
                        )
                    ), _tokenPriceInitial
                )
            )/(tokenPriceIncDec)
        )-(tokenTotalSupply);
        return _tokensReceived;
    }
    
    // Calculate token sell value
    // It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;
    // Some conversions occurred to prevent decimal errors or underflows/overflows in solidity code.
    function tokensToEthereum_(uint256 _tokens) public view returns(uint256) {
        uint256 tokens_         = (_tokens + 1e18);
        uint256 _tokenSupply    = (tokenTotalSupply + 1e18);
        uint256 _etherReceived  =
        (
            SafeMath.sub(
                (
                    (
                        (
                            tokenPriceInitial + (tokenPriceIncDec * (_tokenSupply/1e18))
                        )-tokenPriceIncDec
                    )*(tokens_ - 1e18)
                ),(tokenPriceIncDec*((tokens_**2-tokens_)/1e18))/2
            )/1e18);
        return _etherReceived;
    }
    
    // This is where all your gas goes
    function SqRt(uint x) internal pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
    
}