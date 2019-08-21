pragma solidity ^0.4.24;
/***
* Team JUST presents..
* ============================================================== *
RRRRRRRRRRRRRRRRR   BBBBBBBBBBBBBBBBB   XXXXXXX       XXXXXXX
R::::::::::::::::R  B::::::::::::::::B  X:::::X       X:::::X
R::::::RRRRRR:::::R B::::::BBBBBB:::::B X:::::X       X:::::X
RR:::::R     R:::::RBB:::::B     B:::::BX::::::X     X::::::X
  R::::R     R:::::R  B::::B     B:::::BXXX:::::X   X:::::XXX
  R::::R     R:::::R  B::::B     B:::::B   X:::::X X:::::X   
  R::::RRRRRR:::::R   B::::BBBBBB:::::B     X:::::X:::::X    
  R:::::::::::::RR    B:::::::::::::BB       X:::::::::X     
  R::::RRRRRR:::::R   B::::BBBBBB:::::B      X:::::::::X     
  R::::R     R:::::R  B::::B     B:::::B    X:::::X:::::X    
  R::::R     R:::::R  B::::B     B:::::B   X:::::X X:::::X   
  R::::R     R:::::R  B::::B     B:::::BXXX:::::X   X:::::XXX
RR:::::R     R:::::RBB:::::BBBBBB::::::BX::::::X     X::::::X
R::::::R     R:::::RB:::::::::::::::::B X:::::X       X:::::X
R::::::R     R:::::RB::::::::::::::::B  X:::::X       X:::::X
RRRRRRRR     RRRRRRRBBBBBBBBBBBBBBBBB   XXXXXXX       XXXXXXX
* ============================================================== *
*/
contract risebox {
    string public name = "RiseBox";
    string public symbol = "RBX";
    uint8 constant public decimals = 0;
    uint8 constant internal dividendFee_ = 10;

    uint256 constant ONEDAY = 86400;
    uint256 public lastBuyTime;
    address public lastBuyer;
    bool public isEnd = false;

    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal referralBalance_;
    mapping(address => int256) internal payoutsTo_;
    uint256 internal profitPerShare_ = 0;
    address internal foundation;
    
    uint256 internal tokenSupply_ = 0;
    uint256 constant internal tokenPriceInitial_ = 1e14;
    uint256 constant internal tokenPriceIncremental_ = 15e6;


    /*=================================
    =            MODIFIERS            =
    =================================*/
    // only people with tokens
    modifier onlyBagholders() {
        require(myTokens() > 0);
        _;
    }
    
    // only people with profits
    modifier onlyStronghands() {
        require(myDividends(true) > 0);
        _;
    }

    // healthy longevity
    modifier antiEarlyWhale(uint256 _amountOfEthereum){
        uint256 _balance = address(this).balance;

        if(_balance <= 1000 ether) {
            require(_amountOfEthereum <= 2 ether);
            _;
        } else {
            _;
        }
    }
    /*==============================
    =            EVENTS            =
    ==============================*/
    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingEthereum,
        uint256 tokensMinted,
        address indexed referredBy
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
    // ERC20
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );

    constructor () public {
        foundation =  msg.sender;
        lastBuyTime = now;
    }

    function buy(address _referredBy) 
        public 
        payable 
        returns(uint256)
    {
        assert(isEnd==false);

        if(breakDown()) {
            return liquidate();
        } else {
            return purchaseTokens(msg.value, _referredBy);
        }
    }

    function()
        payable
        public
    {
        assert(isEnd==false);

        if(breakDown()) {
            liquidate();
        } else {
            purchaseTokens(msg.value, 0x00);
        }
    }

    /**
     * Converts all of caller's dividends to tokens.
     */
    function reinvest()
        onlyStronghands() //针对有利润的客户
        public
    {
        // fetch dividends
        uint256 _dividends = myDividends(false); // retrieve ref. bonus later in the code
        
        // pay out the dividends virtually
        address _customerAddress = msg.sender;
        payoutsTo_[_customerAddress] +=  (int256) (_dividends);
        
        // retrieve ref. bonus
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;
        
        // dispatch a buy order with the virtualized "withdrawn dividends"
        uint256 _tokens = purchaseTokens(_dividends, 0x00);
        
        // fire event
        emit onReinvestment(_customerAddress, _dividends, _tokens);
    }


    /**
     * Alias of sell() and withdraw().
     */
    function exit(address _targetAddress)
        public
    {
        // get token count for caller & sell them all
        address _customerAddress = msg.sender;
        uint256 _tokens = tokenBalanceLedger_[_customerAddress];
        if(_tokens > 0) sell(_tokens);
        
        // lambo delivery service
        withdraw(_targetAddress);
    }


    function sell(uint256 _amountOfTokens)
        onlyBagholders()
        internal
    {
        // setup data
        address _customerAddress = msg.sender;
        // russian hackers BTFO
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        
        uint256 _tokens = _amountOfTokens;
        uint256 _ethereum = tokensToEthereum_(_tokens);
        uint256 _dividends = SafeMath.div(_ethereum, dividendFee_);
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);

        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);

        // update dividends tracker
        int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens + (_taxedEthereum));
        payoutsTo_[_customerAddress] -= _updatedPayouts;       
        
        payoutsTo_[foundation] -= (int256)(_dividends);
    }



    /**
     * 提取ETH
     */
    function withdraw(address _targetAddress)
        onlyStronghands()
        internal
    {
        // setup data
        address _customerAddress = msg.sender;
        uint256 _dividends = myDividends(false); // get ref. bonus later in the code
        
        // update dividend tracker
        payoutsTo_[_customerAddress] +=  (int256) (_dividends);
        
        // add ref. bonus
        _dividends += referralBalance_[_customerAddress];
        referralBalance_[_customerAddress] = 0;
        
        // anti whale
        if(_dividends > address(this).balance/2) {
            _dividends = address(this).balance / 2;
        }

        _targetAddress.transfer(_dividends);

        // fire event
        emit onWithdraw(_targetAddress, _dividends);       
    }

    /**
     * Transfer tokens from the caller to a new holder.
     * Remember, there's a 10% fee here as well.
     */
    function transfer(address _toAddress, uint256 _amountOfTokens)
        onlyBagholders()
        public
        returns(bool)
    {
        // setup
        address _customerAddress = msg.sender;
        
        // make sure we have the requested tokens
        // also disables transfers until ambassador phase is over
        // ( we dont want whale premines )
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        
        // withdraw all outstanding dividends first
        if(myDividends(true) > 0) withdraw(msg.sender);
        

        // exchange tokens
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _amountOfTokens);
        
        // update dividend trackers
        payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);
        payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _amountOfTokens);
        
        
        // fire event
        emit Transfer(_customerAddress, _toAddress, _amountOfTokens);
        
        // ERC20
        return true;
       
    }

    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/
    function purchaseTokens(uint256 _incomingEthereum, address _referredBy)
        antiEarlyWhale(_incomingEthereum)
        internal
        returns(uint256)
    {
        address _customerAddress = msg.sender; 
        uint256 _undividedDividends = SafeMath.div(_incomingEthereum, dividendFee_);
        uint256 _referralBonus = SafeMath.div(_undividedDividends, 2); 
        uint256 _dividends = SafeMath.sub(_undividedDividends, _referralBonus); 
        uint256 _taxedEthereum = SafeMath.sub(_incomingEthereum, _undividedDividends); 

        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        uint256 _fee = _dividends;

        require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_));

        if(
            // is this a referred purchase?
            _referredBy != 0x0000000000000000000000000000000000000000 &&

            // no cheating!
            _referredBy != _customerAddress
        ) {
            // wealth redistribution
            referralBalance_[_referredBy] = SafeMath.add(referralBalance_[_referredBy], _referralBonus);
        } else if (
            _referredBy != _customerAddress
        ){
            payoutsTo_[foundation] -= (int256)(_referralBonus);
        } else {
            referralBalance_[foundation] -= _referralBonus;
        }

        // we can't give people infinite ethereum
        if(tokenSupply_ > 0){
            
            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);

            _fee = _amountOfTokens * (_dividends / tokenSupply_);
         
        } else {
            // add tokens to the pool
            tokenSupply_ = _amountOfTokens;
        }

        profitPerShare_ += SafeMath.div(_dividends , tokenSupply_);

        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);

        int256 _updatedPayouts = (int256) ((profitPerShare_ * _amountOfTokens) - _fee);
        payoutsTo_[_customerAddress] += _updatedPayouts;

        lastBuyTime = now;
        lastBuyer = msg.sender;
        // fire event
        emit onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens, _referredBy);
        return _amountOfTokens;
    }


    // ETH for Token
    function ethereumToTokens_(uint256 _ethereum)
        internal
        view
        returns(uint256)
    {
        uint256 _tokensReceived = 0;
        
        if(_ethereum < (tokenPriceInitial_ + tokenPriceIncremental_*tokenSupply_)) {
            return _tokensReceived;
        }

        _tokensReceived = 
         (
            (
                // underflow attempts BTFO
                SafeMath.sub(
                    (SafeMath.sqrt
                        (
                            (tokenPriceInitial_**2)
                            +
                            (2 * tokenPriceIncremental_ * _ethereum)
                            +
                            (((tokenPriceIncremental_)**2)*(tokenSupply_**2))
                            +
                            (2*(tokenPriceIncremental_)*tokenPriceInitial_*tokenSupply_)
                        )
                    ), tokenPriceInitial_
                )
            )/(tokenPriceIncremental_)
        )-(tokenSupply_)
        ;
  
        return _tokensReceived;
    }

    // Token for eth
    function tokensToEthereum_(uint256 _tokens)
        internal
        view
        returns(uint256)
    {
        uint256 _etherReceived = 

        SafeMath.sub(
            _tokens * (tokenPriceIncremental_ * tokenSupply_ +     tokenPriceInitial_) , 
            (_tokens**2)*tokenPriceIncremental_/2
        );

        return _etherReceived;
    }


    /**
     * Retrieve the dividend balance of any single address.
     */
    function dividendsOf(address _customerAddress)
        internal
        view
        returns(uint256)
    {
        int256 _dividend = (int256)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress];

        if(_dividend < 0) {
            _dividend = 0;
        }
        return (uint256)(_dividend);
    }


    /**
     * Retrieve the token balance of any single address.
     */
    function balanceOf(address _customerAddress)
        internal
        view
        returns(uint256)
    {
        return tokenBalanceLedger_[_customerAddress];
    }

    /**
     * to check is game breakdown.
     */
    function breakDown() 
        internal
        returns(bool)
    {
        // is game ended
        if (lastBuyTime + ONEDAY < now) {
            isEnd = true;
            return true;
        } else {
            return false;
        }
    }

    function liquidate()
        internal
        returns(uint256)
    {
        // you are late,so sorry
        msg.sender.transfer(msg.value);

        // Ethereum in pool
        uint256 _balance = address(this).balance;
        // taxed
        uint256 _taxedEthereum = _balance * 88 / 100;
        // tax value
        uint256 _tax = SafeMath.sub(_balance , _taxedEthereum);

        foundation.transfer(_tax);
        lastBuyer.transfer(_taxedEthereum);

        return _taxedEthereum;
    }

    /*----------  HELPERS AND CALCULATORS  ----------*/
    /**
     * Method to view the current Ethereum stored in the contract
     * Example: totalEthereumBalance()
     */
    function totalEthereumBalance()
        public
        view
        returns(uint)
    {
        return address(this).balance;
    }
    
    /**
     * Retrieve the total token supply.
     */
    function totalSupply()
        public
        view
        returns(uint256)
    {
        return tokenSupply_;
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
     * Retrieve the dividends owned by the caller.
     * If `_includeReferralBonus` is to to 1/true, the referral bonus will be included in the calculations.
     * The reason for this, is that in the frontend, we will want to get the total divs (global + ref)
     * But in the internal calculations, we want them separate. 
     */ 
    function myDividends(bool _includeReferralBonus) 
        public 
        view 
        returns(uint256)
    {
        address _customerAddress = msg.sender;
        return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress) ;
    }
    
    /**
     * Return the buy price of 1 individual token.
     */
    function sellPrice() 
        public 
        view 
        returns(uint256)
    {
        // our calculation relies on the token supply, so we need supply. Doh.
        if(tokenSupply_ == 0){
            return tokenPriceInitial_ - tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1);
            uint256 _dividends = SafeMath.div(_ethereum, dividendFee_  );
            uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
            return _taxedEthereum;
        }
    }
    
    /**
     * Return the sell price of 1 individual token.
     */
    function buyPrice() 
        public 
        view 
        returns(uint256)
    {
        // our calculation relies on the token supply, so we need supply. Doh.
        if(tokenSupply_ == 0){
            return tokenPriceInitial_ + tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1);
            uint256 _dividends = SafeMath.div(_ethereum, (dividendFee_-1)  );
            uint256 _taxedEthereum = SafeMath.add(_ethereum, _dividends);
            return _taxedEthereum;
        }
    }
    
    /**
     * Function for the frontend to dynamically retrieve the price scaling of buy orders.
     */
    function calculateTokensReceived(uint256 _ethereumToSpend) 
        public 
        view 
        returns(uint256)
    {
        // overflow check
        require(_ethereumToSpend <= 1e32 , "number is too big");
        uint256 _dividends = SafeMath.div(_ethereumToSpend, dividendFee_);
        uint256 _taxedEthereum = SafeMath.sub(_ethereumToSpend, _dividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        return _amountOfTokens;
    }
    
    /**
     * Function for the frontend to dynamically retrieve the price scaling of sell orders.
     */
    function calculateEthereumReceived(uint256 _tokensToSell) 
        public 
        view 
        returns(uint256)
    {
        require(_tokensToSell <= tokenSupply_);
        uint256 _ethereum = tokensToEthereum_(_tokensToSell);
        uint256 _dividends = SafeMath.div(_ethereum, dividendFee_);
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
        return _taxedEthereum;
    }

}


/**
 * @title SafeMath v0.1.9
 * @dev Math operations with safety checks that throw on error
 * change notes:  original SafeMath library from OpenZeppelin modified by Inventor
 * - added sqrt
 * - added sq
 * - added pwr 
 * - changed asserts to requires with error log outputs
 * - removed div, its useless
 */
library SafeMath {
    
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) 
        internal 
        pure 
        returns (uint256 c) 
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
      require(b > 0); // Solidity only automatically asserts when dividing by 0
      uint256 c = a / b;
      // assert(a == b * c + a % b); // There is no case in which this doesn't hold

      return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256) 
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c) 
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }

    /**
     * @dev gives square root of given x.
     */
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y) 
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y) 
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }

        return y;
    }

}