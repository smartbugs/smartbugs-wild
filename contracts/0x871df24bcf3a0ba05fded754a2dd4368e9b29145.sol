pragma solidity ^0.4.24;



contract SHT_Token 
{

    /*=================================
    =            MODIFIERS            =
    =================================*/
    // only people with tokens
    modifier onlyTokenHolders() 
    {
        require(myTokens() > 0);
        _;
    }
    
    // only people with profits
    modifier onlyDividendPositive() 
    {
        require(myDividends() > 0);
        _;
    }

    // only owner
    modifier onlyOwner() 
    { 
        require (address(msg.sender) == owner); 
        _; 
    }
    
    // only founders if contract not live
    modifier onlyFoundersIfNotPublic() 
    {
        if(!openToThePublic)
        {
            require (founders[address(msg.sender)] == true);   
        }
        _;
    }    

    /*==============================
    =            EVENTS            =
    ==============================*/
    event onTokenPurchase(
        address indexed customerAddress,
        uint256 incomingEthereum,
        uint256 tokensMinted
    );
    
    event onTokenSell(
        address indexed customerAddress,
        uint256 tokensBurned,
        uint256 ethereumEarned
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
    
    event lotteryPayout(
        address customerAddress, 
        uint256 lotterySupply
    );
    
    event whaleDump(
        uint256 amount
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
    string public name = "SHT Token";
    string public symbol = "SHT";
    bool public openToThePublic = false;
    address public owner;
    address public dev;
    uint8 constant public decimals = 18;
    uint8 constant internal dividendFee = 10;  //11% (total.. breakdown is 5% tokenholders, 2.5% OB2, 1.5% whale, 1% lottery, 1% dev)
    uint8 constant internal lotteryFee = 5; 
    uint8 constant internal devFee = 5; 
    uint8 constant internal ob2Fee = 2;  
    uint256 constant internal tokenPrice = 400000000000000;  //0.0004 ether
    uint256 constant internal magnitude = 2**64;
    Onigiri2 private ob2; 
   

    
   /*================================
    =            DATASETS            =
    ================================*/
    mapping(address => uint256) internal publicTokenLedger;
    mapping(address => uint256) public   whaleLedger;
    mapping(address => int256) internal payoutsTo_;
    mapping(address => bool) internal founders;
    address[] lotteryPlayers;
    uint256 internal lotterySupply = 0;
    uint256 internal tokenSupply = 0;
    uint256 internal profitPerShare_;
    
    /*=======================================
    =            PUBLIC FUNCTIONS            =
    =======================================*/
    /*
    * -- APPLICATION ENTRY POINTS --  
    */
    constructor()
        public
    {
        // no admin, but the owner of the contract is the address used for whale
        owner = address(msg.sender);

        dev = address(0x7e474fe5Cfb720804860215f407111183cbc2f85); //some SHT Dev

        // add founders here... Founders don't get any special priveledges except being first in line at launch day
        founders[0x013f3B8C9F1c4f2f28Fd9cc1E1CF3675Ae920c76] = true; //Nomo
        founders[0xF57924672D6dBF0336c618fDa50E284E02715000] = true; //Bungalogic
        founders[0xE4Cf94e5D30FB4406A2B139CD0e872a1C8012dEf] = true; //Ivan

        // link this contract to OB2 contract to send rewards
        ob2 = Onigiri2(0xb8a68f9B8363AF79dEf5c5e11B12e8A258cE5be8); //MainNet
    }
    
     
    /**
     * Converts all incoming ethereum to tokens for the caller, and passes down the referral address
     */
    function buy()
        onlyFoundersIfNotPublic()
        public
        payable
        returns(uint256)
    {
        require (msg.sender == tx.origin);
         uint256 tokenAmount;

        tokenAmount = purchaseTokens(msg.value); //redirects to purchaseTokens so same functionality

        return tokenAmount;
    }
    
    /**
     * Fallback function to handle ethereum that was send straight to the contract
     */
    function()
        payable
        public
    {
       buy();
    }
    
    /**
     * Converts all of caller's dividends to tokens.
     */
    function reinvest()
        onlyDividendPositive()
        public
    {   
        require (msg.sender == tx.origin);
        
        // fetch dividends
        uint256 dividends = myDividends(); 
        
        // pay out the dividends virtually
        address customerAddress = msg.sender;
        payoutsTo_[customerAddress] +=  int256(dividends * magnitude);
        
        // dispatch a buy order with the virtualized "withdrawn dividends"
        uint256 _tokens = purchaseTokens(dividends);
        
        // fire event for logging 
        emit onReinvestment(customerAddress, dividends, _tokens);
    }
    
    /**
     * Alias of sell() and withdraw().
     */
    function exit()
        onlyTokenHolders()
        public
    {
        require (msg.sender == tx.origin);
        
        // get token count for caller & sell them all
        address customerAddress = address(msg.sender);
        uint256 _tokens = publicTokenLedger[customerAddress];
        
        if(_tokens > 0) 
        {
            sell(_tokens);
        }

        withdraw();
    }

    /**
     * Withdraws all of the callers earnings.
     */
    function withdraw()
        onlyDividendPositive()
        public
    {
        require (msg.sender == tx.origin);
        
        // setup data
        address customerAddress = msg.sender;
        uint256 dividends = myDividends(); 
        
        // update dividend tracker
        payoutsTo_[customerAddress] +=  int256(dividends * magnitude);
        
        customerAddress.transfer(dividends);
        
        // fire event for logging 
        emit onWithdraw(customerAddress, dividends);
    }
    
    /**
     * Liquifies tokens to ethereum.
     */
    function sell(uint256 _amountOfTokens)
        onlyTokenHolders()
        public
    {
        require (msg.sender == tx.origin);
        require((_amountOfTokens <= publicTokenLedger[msg.sender]) && (_amountOfTokens > 0));

        uint256 _tokens = _amountOfTokens;
        uint256 ethereum = tokensToEthereum_(_tokens);

        uint256 undividedDivs = SafeMath.div(ethereum, dividendFee);
        
        // from that 10%, divide for Community, Whale, Lottery, and OB2
        uint256 communityDivs = SafeMath.div(undividedDivs, 2); //5%
        uint256 ob2Divs = SafeMath.div(undividedDivs, 4); //2.5% 
        uint256 lotteryDivs = SafeMath.div(undividedDivs, 10); // 1%
        uint256 tip4Dev = lotteryDivs;
        uint256 whaleDivs = SafeMath.sub(communityDivs, (ob2Divs + lotteryDivs));  // 1.5%


        // let's deduct Whale, Lottery, and OB2 divs just to make sure our math is safe
        uint256 dividends = SafeMath.sub(undividedDivs, (ob2Divs + lotteryDivs + whaleDivs));

        uint256 taxedEthereum = SafeMath.sub(ethereum, (undividedDivs + tip4Dev));

        //add divs to whale
        whaleLedger[owner] += whaleDivs;
        
        //add tokens to the lotterySupply
        lotterySupply += ethereumToTokens_(lotteryDivs);

        //send divs to OB2
        ob2.fromGame.value(ob2Divs)();

        //send tip to Dev
        dev.transfer(tip4Dev);
        
        // burn the sold tokens
        tokenSupply -=  _tokens;
        publicTokenLedger[msg.sender] -= _tokens;
        
        
        // update dividends tracker
        int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens + (taxedEthereum * magnitude));
        payoutsTo_[msg.sender] -= _updatedPayouts;  
        
        // dividing by zero is a bad idea
        if (tokenSupply > 0) 
        {
            // update the amount of dividends per token
            profitPerShare_ += ((dividends * magnitude) / tokenSupply);
        }
        
        // fire event for logging 
        emit onTokenSell(msg.sender, _tokens, taxedEthereum);
    }
    
    
    /**
     * Transfer tokens from the caller to a new holder.
     */
    function transfer(address _toAddress, uint256 _amountOfTokens)
        onlyTokenHolders()
        public
        returns(bool)
    {
        assert(_toAddress != owner);
        
        // make sure we have the requested tokens
        require((_amountOfTokens <= publicTokenLedger[msg.sender]) && (_amountOfTokens > 0 ));
            // exchange tokens
        publicTokenLedger[msg.sender] -= _amountOfTokens;
        publicTokenLedger[_toAddress] += _amountOfTokens; 
        
        // update dividend trackers
        payoutsTo_[msg.sender] -= int256(profitPerShare_ * _amountOfTokens);
        payoutsTo_[_toAddress] += int256(profitPerShare_ * _amountOfTokens); 
            
        // fire event for logging 
        emit Transfer(msg.sender, _toAddress, _amountOfTokens); 

        return true;     
    }
    
    /*----------  OWNER ONLY FUNCTIONS  ----------*/

    /**
     * Want to prevent snipers from buying prior to launch
     */
    function goPublic() 
        onlyOwner()
        public 
        returns(bool)

    {
        openToThePublic = true;
        return openToThePublic;
    }
    
    
    /*----------  HELPERS AND CALCULATORS  ----------*/
    /**
     * Method to view the current Ethereum stored in the contract
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
        return (tokenSupply + lotterySupply); //adds the tokens from ambassadors to the supply (but not to the dividends calculation which is based on the supply)
    }
    
    /**
     * Retrieve the tokens owned by the caller.
     */
    function myTokens()
        public
        view
        returns(uint256)
    {
        return balanceOf(msg.sender);
    }

    /**
     * Retrieve the balance of the whale.
     */
    function whaleBalance()
        public
        view
        returns(uint256)
    {
        return  whaleLedger[owner]; 
    }


    /**
     * Retrieve the balance of the whale.
     */
    function lotteryBalance()
        public
        view
        returns(uint256)
    {
        return  lotterySupply; 
    }
    
    
    /**
     * Retrieve the dividends owned by the caller.
     */ 
    function myDividends() 
        public 
        view 
        returns(uint256)
    {
        return dividendsOf(msg.sender);
    }
    
    /**
     * Retrieve the token balance of any single address.
     */
    function balanceOf(address customerAddress)
        view
        public
        returns(uint256)
    {
        return publicTokenLedger[customerAddress];
    }
    
    /**
     * Retrieve the dividend balance of any single address.
     */
    function dividendsOf(address customerAddress)
        view
        public
        returns(uint256)
    {
      return (uint256) ((int256)(profitPerShare_ * publicTokenLedger[customerAddress]) - payoutsTo_[customerAddress]) / magnitude;
    }
    
    /**
     * Return the buy and sell price of 1 individual token.
     */
    function buyAndSellPrice()
    public
    pure 
    returns(uint256)
    {
        uint256 ethereum = tokenPrice;
        uint256 dividends = SafeMath.div((ethereum * dividendFee ), 100);
        uint256 taxedEthereum = SafeMath.sub(ethereum, dividends);
        return taxedEthereum;
    }
    
    /**
     * Function for the frontend to dynamically retrieve the price of buy orders.
     */
    function calculateTokensReceived(uint256 ethereumToSpend) 
        public 
        pure 
        returns(uint256)
    {
        require(ethereumToSpend >= tokenPrice);
        uint256 dividends = SafeMath.div((ethereumToSpend * dividendFee), 100);
        uint256 taxedEthereum = SafeMath.sub(ethereumToSpend, dividends);
        uint256 amountOfTokens = ethereumToTokens_(taxedEthereum);
        
        return amountOfTokens;
    }
    
    /**
     * Function for the frontend to dynamically retrieve the price of sell orders.
     */
    function calculateEthereumReceived(uint256 tokensToSell) 
        public 
        view 
        returns(uint256)
    {
        require(tokensToSell <= tokenSupply);
        uint256 ethereum = tokensToEthereum_(tokensToSell);
        uint256 dividends = SafeMath.div((ethereum * dividendFee ), 100);
        uint256 taxedEthereum = SafeMath.sub(ethereum, dividends);
        return taxedEthereum;
    }
    
    
    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/
    
    function purchaseTokens(uint256 incomingEthereum)
        internal
        returns(uint256)
    {
        // take out 10% of incoming eth for divs
        uint256 undividedDivs = SafeMath.div(incomingEthereum, dividendFee);
        
        // from that 10%, divide for Community, Whale, Lottery, and OB2
        uint256 communityDivs = SafeMath.div(undividedDivs, 2); //5%
        uint256 ob2Divs = SafeMath.div(undividedDivs, 4); //2.5% 
        uint256 lotteryDivs = SafeMath.div(undividedDivs, 10); // 1%
        uint256 tip4Dev = lotteryDivs;
        uint256 whaleDivs = SafeMath.sub(communityDivs, (ob2Divs + lotteryDivs));  // 1.5%

        // let's deduct Whale, Lottery, devfee, and OB2 divs just to make sure our math is safe
        uint256 dividends = SafeMath.sub(undividedDivs, (ob2Divs + lotteryDivs + whaleDivs));

        uint256 taxedEthereum = SafeMath.sub(incomingEthereum, (undividedDivs + tip4Dev));
        uint256 amountOfTokens = ethereumToTokens_(taxedEthereum);

        //add divs to whale
        whaleLedger[owner] += whaleDivs;
        
        //add tokens to the lotterySupply
        lotterySupply += ethereumToTokens_(lotteryDivs);
        
        //add entry to lottery
        lotteryPlayers.push(msg.sender);

        //send divs to OB2
        ob2.fromGame.value(ob2Divs)();

        //tip the dev
        dev.transfer(tip4Dev);
       
        uint256 fee = dividends * magnitude;
 
        require(amountOfTokens > 0 && (amountOfTokens + tokenSupply) > tokenSupply);

        uint256 payoutDividends = isWhalePaying();
        
        // we can't give people infinite ethereum
        if(tokenSupply > 0)
        {
            // add tokens to the pool
            tokenSupply += amountOfTokens;
            
             // take the amount of dividends gained through this transaction, and allocates them evenly to each shareholder
            profitPerShare_ += ((payoutDividends + dividends) * magnitude / (tokenSupply));
            
            // calculate the amount of tokens the customer receives over his purchase 
            fee -= fee-(amountOfTokens * (dividends * magnitude / (tokenSupply)));
        } else 
        {
            // add tokens to the pool
            tokenSupply = amountOfTokens;
            
            //if there are zero tokens prior to this buy, and the whale is triggered, send dividends back to whale
            if(whaleLedger[owner] == 0)
            {
                whaleLedger[owner] = payoutDividends;
            }
        }

        // update circulating supply & the ledger address for the customer
        publicTokenLedger[msg.sender] += amountOfTokens;
        
        // Tells the contract that the buyer doesn't deserve dividends for the tokens before they owned them;
        int256 _updatedPayouts = int256((profitPerShare_ * amountOfTokens) - fee);
        payoutsTo_[msg.sender] += _updatedPayouts;
        
     
        // fire event for logging 
        emit onTokenPurchase(msg.sender, incomingEthereum, amountOfTokens);
        
        return amountOfTokens;
    }
    
    
     /**
     * Calculate token sell value.
     * It's a simple algorithm. Hopefully, you don't need a whitepaper with it in scientific notation.
     */
    function isWhalePaying()
    private
    returns(uint256)
    {
        uint256 payoutDividends = 0;
         // this is where we check for lottery winner
        if(whaleLedger[owner] >= 1 ether)
        {
            if(lotteryPlayers.length > 0)
            {
                uint256 winner = uint256(blockhash(block.number-1))%lotteryPlayers.length;
                
                publicTokenLedger[lotteryPlayers[winner]] += lotterySupply;
                emit lotteryPayout(lotteryPlayers[winner], lotterySupply);
                tokenSupply += lotterySupply;
                lotterySupply = 0;
                delete lotteryPlayers;
               
            }
            //whale pays out everyone its divs
            payoutDividends = whaleLedger[owner];
            whaleLedger[owner] = 0;
            emit whaleDump(payoutDividends);
        }
        return payoutDividends;
    }

    /**
     * Calculate Token price based on an amount of incoming ethereum
     *It's a simple algorithm. Hopefully, you don't need a whitepaper with it in scientific notation.
     */
    function ethereumToTokens_(uint256 ethereum)
        internal
        pure
        returns(uint256)
    {
        uint256 tokensReceived = ((ethereum / tokenPrice) * 1e18);
               
        return tokensReceived;
    }
    
    /**
     * Calculate token sell value.
     * It's a simple algorithm. Hopefully, you don't need a whitepaper with it in scientific notation.
     */
     function tokensToEthereum_(uint256 coin)
        internal
        pure
        returns(uint256)
    {
        uint256 ethReceived = tokenPrice * (SafeMath.div(coin, 1e18));
        
        return ethReceived;
    }
}

contract Onigiri2 
{
    function fromGame() external payable;
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    
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
}