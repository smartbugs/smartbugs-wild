pragma solidity ^0.4.24;


/* Smart Contract Security Audit by Callisto Network */
 
/* Mizhen Boss represents the right of being a member of Mizhen community 
 * Holders can use different tools and share profits in all the games developed by Mizhen team
 * Total number of MZBoss is 21,000,000
 * The price of MZBoss is constant at 0.005 ether
 * Purchase fee is 15%, pay customers buy MZBoss, of which 10% is distributed to tokenholders, 5% is sent to community for further development.
 * There is not selling fee
 * The purchase fee is evenly distributed to the existing MZBoss holders
 * All MZBoss holders will receive profit from different game pots
 * Mizhen Team
 */
 
contract MZBoss {
    /*=================================
    =            MODIFIERS            =
    =================================*/
    // only people with tokens
    modifier transferCheck(uint256 _amountOfTokens) {
        address _customerAddress = msg.sender;
        require((_amountOfTokens > 0) && (_amountOfTokens <= tokenBalanceLedger_[_customerAddress]));
        _;
    }
    
    // only people with profits
    modifier onlyStronghands() {
        address _customerAddress = msg.sender;
        require(dividendsOf(_customerAddress) > 0);
        _;
    }
    
    // Check if the play has enough ETH to buy tokens
    modifier enoughToreinvest() {
        address _customerAddress = msg.sender;
        uint256 priceForOne = (tokenPriceInitial_*100)/85;
        require((dividendsOf(_customerAddress) >= priceForOne) && (_tokenLeft >= calculateTokensReceived(dividendsOf(_customerAddress))));
        _; 
    } 
    
    // administrators can:
    // -> change the name of the contract
    // -> change the name of the token
    // they CANNOT:
    // -> take funds
    // -> disable withdrawals
    // -> kill the contract
    // -> change the price of tokens
    modifier onlyAdministrator(){
        address _customerAddress = msg.sender;
        require(administrators[_customerAddress] == true);
        _;
    }
    
    // Check if the play has enough ETH to buy tokens
    modifier enoughToBuytoken (){
        uint256 _amountOfEthereum = msg.value;
        uint256 priceForOne = (tokenPriceInitial_*100)/85;
        require((_amountOfEthereum >= priceForOne) && (_tokenLeft >= calculateTokensReceived(_amountOfEthereum)));
        _; 
    } 
    
    /*==============================
    =            EVENTS            =
    ==============================*/
    
    event OnTokenPurchase(
        address indexed customerAddress,
        uint256 incomingEthereum,
        uint256 tokensBought,
        uint256 tokenSupplyUpdate,
        uint256 tokenLeftUpdate
    );
    
    event OnTokenSell(
        address indexed customerAddress,
        uint256 tokensSold,
        uint256 ethereumEarned,
        uint256 tokenSupplyUpdate,
        uint256 tokenLeftUpdate
    );
    
    event OnReinvestment(
        address indexed customerAddress,
        uint256 ethereumReinvested,
        uint256 tokensBought,
        uint256 tokenSupplyUpdate,
        uint256 tokenLeftUpdate
    );
    
    event OnWithdraw(
        address indexed customerAddress,
        uint256 ethereumWithdrawn
    );
    
    
    // distribution of profit from pot
    event OnTotalProfitPot(
        uint256 _totalProfitPot
    );
    
    // ERC20
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );
    
    
    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/
    string public name = "Mizhen";
    string public symbol = "MZBoss";
    uint256 constant public totalToken = 21000000e18; //total 21000000 MZBoss tokens 
    uint8 constant public decimals = 18;
    uint8 constant internal dividendFee_ = 10; // percentage of fee sent to token holders 
    uint8 constant internal toCommunity_ = 5; // percentage of fee sent to community. 
    uint256 constant internal tokenPriceInitial_ = 5e15; // the price is constant and does not change as the purchase increases.
    uint256 constant internal magnitude = 1e18; // related to payoutsTo_, profitPershare_, profitPerSharePot_, profitPerShareNew_

    
    // ambassador program
    mapping(address => bool) internal ambassadors_;
    uint256 constant internal ambassadorMaxPurchase_ = 1e19;
    uint256 constant internal ambassadorQuota_ = 1e19;
    
    // exchange address, in the future customers can exchange MZBoss without the price limitation
    mapping(address => bool) public exchangeAddress_;
    
   /*================================
    =            DATASETS            =
    ================================*/
    // amount of shares for each address (scaled number)
    mapping(address => uint256) public tokenBalanceLedger_;
    mapping(address => int256) internal payoutsTo_;
    mapping(address => uint256) internal ambassadorAccumulatedQuota_;

    uint256 public tokenSupply_ = 0; // total sold tokens 
    uint256 public _tokenLeft = 21000000e18;
    uint256 public totalEthereumBalance1 = 0;
    uint256 public profitPerShare_ = 0 ;

    uint256 public _totalProfitPot = 0;
    address constant internal _communityAddress = 0x43e8587aCcE957629C9FD2185dD700dcDdE1dD1E;
    
    // administrator list (see above on what they can do)
    mapping(address => bool) public administrators;
    
    // when this is set to true, only ambassadors can purchase tokens 
    bool public onlyAmbassadors = true;


    /*=======================================
    =            PUBLIC FUNCTIONS            =
    =======================================*/
    /*
    * -- APPLICATION ENTRY POINTS --  
    */
    constructor ()
        public
    
    {
        // add administrators here
        administrators[0x6dAd1d9D24674bC9199237F93beb6E25b55Ec763] = true;

        // add the ambassadors here.
        ambassadors_[0x64BFD8F0F51569AEbeBE6AD2a1418462bCBeD842] = true;
    }
    
    function purchaseTokens()  
        enoughToBuytoken ()
        public
        payable
    {
           address _customerAddress = msg.sender;
           uint256 _amountOfEthereum = msg.value;
        
        // are we still in the ambassador phase? 
        if( onlyAmbassadors && (SafeMath.sub(totalEthereumBalance(), _amountOfEthereum) < ambassadorQuota_ )){ 
            require(
                // is the customer in the ambassador list? 
                (ambassadors_[_customerAddress] == true) &&
                
                // does the customer purchase exceed the max ambassador quota? 
                (SafeMath.add(ambassadorAccumulatedQuota_[_customerAddress], _amountOfEthereum) <= ambassadorMaxPurchase_)
            );
            
            // updated the accumulated quota    
            ambassadorAccumulatedQuota_[_customerAddress] = SafeMath.add(ambassadorAccumulatedQuota_[_customerAddress], _amountOfEthereum);
            
            totalEthereumBalance1 = SafeMath.add(totalEthereumBalance1, _amountOfEthereum);
            uint256 _amountOfTokens = ethereumToTokens_(_amountOfEthereum); 
            
            tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
            
            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens); 
            
            _tokenLeft = SafeMath.sub(totalToken, tokenSupply_); 
            
            emit OnTokenPurchase(_customerAddress, _amountOfEthereum, _amountOfTokens, tokenSupply_, _tokenLeft);
         
        } 
        
        else {
            // in case the ether count drops low, the ambassador phase won't reinitiate
            onlyAmbassadors = false;
            
            purchaseTokensAfter(_amountOfEthereum); 
                
        }
        
    }
    
    /**
     * profit distribution from game pot
     */
    function potDistribution()
        public
        payable
    {
        //
        require(msg.value > 0);
        uint256 _incomingEthereum = msg.value;
        if(tokenSupply_ > 0){
            
            // profit per share 
            uint256 profitPerSharePot_ = SafeMath.mul(_incomingEthereum, magnitude) / (tokenSupply_);
            
            // update profitPerShare_, adding profit from game pot
            profitPerShare_ = SafeMath.add(profitPerShare_, profitPerSharePot_);
            
        } else {
            // send to community
            payoutsTo_[_communityAddress] -=  (int256) (_incomingEthereum);
            
        }
        
        //update _totalProfitPot
        _totalProfitPot = SafeMath.add(_incomingEthereum, _totalProfitPot); 
    }
    
    /**
     * Converts all of caller's dividends to tokens.
     */
    function reinvest()
        enoughToreinvest()
        public
    {
        
        // pay out the dividends virtually
        address _customerAddress = msg.sender;
        
        // fetch dividends
        uint256 _dividends = dividendsOf(_customerAddress); 
        
        uint256 priceForOne = (tokenPriceInitial_*100)/85;
        
        // minimum purchase 1 ether token
        if (_dividends >= priceForOne) { 
        
        // dispatch a buy order with the virtualized "withdrawn dividends"
        purchaseTokensAfter(_dividends);
            
        payoutsTo_[_customerAddress] +=  (int256) (_dividends);
        
        }
        
    }
    
    /**
     * Withdraws all of the callers earnings.
     */
    function withdraw()
        onlyStronghands()
        public
    {
        // setup data
        address _customerAddress = msg.sender;
        uint256 _dividends = dividendsOf(_customerAddress); 
        
        // update dividend tracker, in order to calculate with payoutsTo which is int256, _dividends need to be casted to int256 first
        payoutsTo_[_customerAddress] +=  (int256) (_dividends);

        
        // send eth
        _customerAddress.transfer(_dividends);
        
        // fire event
        emit OnWithdraw(_customerAddress, _dividends);
    }
    
    /**
     * Liquifies tokens to ethereum.
     */
    function sell(uint256 _amountOfTokens)
        public
    {
        // setup data
        address _customerAddress = msg.sender;
        uint256 _tokens = _amountOfTokens;
        uint256 _ethereum = tokensToEthereum_(_tokens);
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, 0); // no fee when sell, but there is transaction fee included here
        
        require((tokenBalanceLedger_[_customerAddress] >= _amountOfTokens) && ( totalEthereumBalance1 >= _taxedEthereum ) && (_amountOfTokens > 0));
        
        // update the amount of the sold tokens
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);
        totalEthereumBalance1 = SafeMath.sub(totalEthereumBalance1, _taxedEthereum);
        
        // update dividends tracker
        int256 _updatedPayouts = (int256) (SafeMath.add(SafeMath.mul(profitPerShare_, _tokens)/magnitude, _taxedEthereum));
        payoutsTo_[_customerAddress] -= _updatedPayouts;       
        
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
        _tokenLeft = SafeMath.sub(totalToken, tokenSupply_);
        
        // fire event
        emit OnTokenSell(_customerAddress, _tokens, _taxedEthereum, tokenSupply_, _tokenLeft);
    }
    
    /**
     * Transfer tokens from the caller to a new holder.
     */
    function transfer(uint256 _amountOfTokens, address _toAddress)
        transferCheck(_amountOfTokens)
        public
        returns(bool)
    {
        // setup
        address _customerAddress = msg.sender;

        // withdraw all outstanding dividends first
        if(dividendsOf(_customerAddress) > 0) withdraw();

        // exchange tokens
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _amountOfTokens);
        
        // update dividend trackers
        payoutsTo_[_customerAddress] -= (int256) (SafeMath.mul(profitPerShare_ , _amountOfTokens)/magnitude);
        payoutsTo_[_toAddress] += (int256) (SafeMath.mul(profitPerShare_ , _amountOfTokens)/magnitude);
        
        // fire event
        emit Transfer(_customerAddress, _toAddress, _amountOfTokens);
        
        // ERC20
        return true;
       
    }

    
    /*----------  ADMINISTRATOR ONLY FUNCTIONS  ----------*/
    /**
     * In case we need to replace ourselves.
     */
    function setAdministrator(address _identifier, bool _status)
        onlyAdministrator()
        public
    {
        administrators[_identifier] = _status;
    }
    
    /**
     * If we want to rebrand, we can.
     */
    function setName(string _name)
        onlyAdministrator()
        public
    {
        name = _name;
    }
    
    /**
     * If we want to rebrand, we can.
     */
    function setSymbol(string _symbol)
        onlyAdministrator()
        public
    {
        symbol = _symbol;
    }

    
    /*----------  HELPERS AND CALCULATORS  ----------*/
    /**
     * Method to view the current Ethereum stored in the contract
     * 
     */
    function totalEthereumBalance()
        public
        view
        returns(uint)
    {
        return address(this).balance;
    }
    
    /**
     * Method to view the current sold tokens
     * 
     */
    function tokenSupply()
        public
        view
        returns(uint256)
    {
        return tokenSupply_;
    }
    
    /**
     * Retrieve the token balance of any single address.
     */
    function balanceOf(address _customerAddress)
        public
        view
        returns(uint256)
    {
        return tokenBalanceLedger_[_customerAddress];
    }
    
    /**
     * Retrieve the payoutsTo_ of any single address.
     */
    function payoutsTo(address _customerAddress)
        public
        view
        returns(int256)
    {
        return payoutsTo_[_customerAddress];
    }
    
    /**
     * Retrieve the tokens owned by the caller.
     */
    function myTokens()
        public
        view
        returns(uint256)
    {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }
    
    /**
     * Retrieve the dividend balance of any single address.
     */
    function dividendsOf(address _customerAddress)
        public 
        view
        returns(uint256)
    {
        
        uint256 _TokensEther = tokenBalanceLedger_[_customerAddress];
        
        if ((int256(SafeMath.mul(profitPerShare_, _TokensEther)/magnitude) - payoutsTo_[_customerAddress]) > 0 )
           return uint256(int256(SafeMath.mul(profitPerShare_, _TokensEther)/magnitude) - payoutsTo_[_customerAddress]);  
        else 
           return 0;
    }

    
    /**
     * Function for the frontend to dynamically retrieve the price scaling of buy orders.
     */
    function calculateTokensReceived(uint256 _ethereumToSpend) 
        public 
        pure 
        returns(uint256)
    {
        uint256 _dividends = SafeMath.mul(_ethereumToSpend, dividendFee_) / 100;
        uint256 _communityDistribution = SafeMath.mul(_ethereumToSpend, toCommunity_) / 100;
        uint256 _taxedEthereum = SafeMath.sub(_ethereumToSpend, SafeMath.add(_communityDistribution,_dividends));
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        
        return _amountOfTokens;
    }
    
    /**
     * Function for the frontend to dynamically retrieve the price scaling of sell orders.
     */
    function calculateEthereumReceived(uint256 _tokensToSell) 
        public 
        pure 
        returns(uint256)
    {
        uint256 _ethereum = tokensToEthereum_(_tokensToSell);
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, 0); // transaction fee
        return _taxedEthereum;
    }
    

    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/
    function purchaseTokensAfter(uint256 _incomingEthereum) 
        private
    {
        // data setup
        address _customerAddress = msg.sender;
        
        // distribution as dividend to token holders
        uint256 _dividends = SafeMath.mul(_incomingEthereum, dividendFee_) / 100; 
        
        // sent to community address
        uint256 _communityDistribution = SafeMath.mul(_incomingEthereum, toCommunity_) / 100;
        
        uint256 _taxedEthereum = SafeMath.sub(_incomingEthereum, SafeMath.add(_communityDistribution, _dividends));
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum); 

        // prevents overflow in the case that the pyramid somehow magically starts being used by everyone in the world
        // minimum purchase 1 token
        require((_amountOfTokens >= 1e18) && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_)); 

        
        // profitPerShare calculation assuming the _dividends are only distributed to the holders before the new customer
        // the tokenSupply_ here is the supply without considering the new customer's buying amount
        
        if (tokenSupply_ == 0){
            
            uint256 profitPerShareNew_ = 0;
        }else{
            
            profitPerShareNew_ = SafeMath.mul(_dividends, magnitude) / (tokenSupply_); 
        } 
        
        // take the amount of dividends gained through this transaction, and allocates them evenly to each shareholder
        profitPerShare_ = SafeMath.add(profitPerShare_, profitPerShareNew_); 
        
        // assumed total dividends considering the new customer's buying amount 
        uint256 _dividendsAssumed = SafeMath.div(SafeMath.mul(profitPerShare_, _amountOfTokens), magnitude);
            
        // extra dividends in the assumed dividens, which does not exist 
        // this part is considered as the existing payoutsTo_ to the new customer
        uint256 _dividendsExtra = _dividendsAssumed;
        
        
        // update the new customer's payoutsTo_; cast _dividendsExtra to int256 first because payoutsTo is int256
        payoutsTo_[_customerAddress] += (int256) (_dividendsExtra);
            
        // add tokens to the pool, update the tokenSupply_
        tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens); 
            
        _tokenLeft = SafeMath.sub(totalToken, tokenSupply_);
        totalEthereumBalance1 = SafeMath.add(totalEthereumBalance1, _taxedEthereum);
        
        // send to community
        _communityAddress.transfer(_communityDistribution);
        
        // update circulating supply & the ledger address for the customer
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        
        // fire event
        emit OnTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens, tokenSupply_, _tokenLeft);
    }

    /**
     * Calculate Token price based on an amount of incoming ethereum
     */
    function ethereumToTokens_(uint256 _ethereum)
        internal
        pure
        returns(uint256)
    {
        require (_ethereum > 0);
        uint256 _tokenPriceInitial = tokenPriceInitial_;
        
        uint256 _tokensReceived = SafeMath.mul(_ethereum, magnitude) / _tokenPriceInitial;
                    
        return _tokensReceived;
    }
    
    /**
     * Calculate token sell value.
     */
     function tokensToEthereum_(uint256 _tokens)
        internal
        pure
        returns(uint256)
    {   
        uint256 tokens_ = _tokens;
        
        uint256 _etherReceived = SafeMath.mul (tokenPriceInitial_, tokens_) / magnitude;
            
        return _etherReceived;
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