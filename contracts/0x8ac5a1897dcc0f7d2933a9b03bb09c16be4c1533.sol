pragma solidity 0.4.25;

contract E2D {
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
        require(myDividends() > 0);
        _;
    }

    // owner can:
    // -> change the name of the contract
    // -> change the name of the token
    // they CANNOT:
    // -> take funds
    // -> disable withdrawals
    // -> kill the contract
    // -> change the price of tokens
    modifier onlyOwner(){
        require(ownerAddr == msg.sender || OWNER_ADDRESS_2 == msg.sender, "only owner can perform this!");
        _;
    }

    modifier onlyInitialInvestors(){
        if(initialState) {
            require(initialInvestors[msg.sender] == true, "only allowed investor can invest!");
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

    event onPayDividends(
        uint256 dividends,
        uint256 profitPerShare
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
    string public name = "E2D";
    string public symbol = "E2D";
    uint8 constant public decimals = 18;
    uint8 constant internal dividendFee_ = 10;
    uint256 constant internal tokenPriceInitial_ = 0.0000001 ether;
    uint256 constant internal tokenPriceIncremental_ = 0.00000001 ether;
    uint256 constant internal magnitude = 2**64;
    address constant internal OWNER_ADDRESS = address(0x508b828440D72B0De506c86DB79D9E2c19810442);
    address constant internal OWNER_ADDRESS_2 = address(0x508b828440D72B0De506c86DB79D9E2c19810442);
    uint256 constant public INVESTOR_QUOTA = 0.01 ether;

   /*================================
    =            DATASETS            =
    ================================*/
    // amount of shares for each address (scaled number)
    mapping(address => uint256) internal tokenBalanceLedger_;
    mapping(address => int256) internal payoutsTo_;
    uint256 internal tokenSupply_ = 0;
    uint256 internal profitPerShare_;
    uint256 internal totalInvestment_ = 0;
    uint256 internal totalGameDividends_ = 0;

    // smart contract owner address (see above on what they can do)
    address public ownerAddr;

    // initial investor list who can purchase tokens (this prevents a whale premine, it ensures a fairly distributed upper pyramid)
    mapping(address => bool) public initialInvestors;

    // when this is set to true, only allowed initialInvestors can purchase tokens.
    bool public initialState = true;

    /*=======================================
    =            PUBLIC FUNCTIONS            =
    =======================================*/
    /*
    * -- APPLICATION ENTRY POINTS --  
    */

    constructor() public {
        // add initialInvestors here
        ownerAddr = OWNER_ADDRESS;
        initialInvestors[OWNER_ADDRESS] = true;
        initialInvestors[OWNER_ADDRESS_2] = true;
    }

    /**
     * Converts all incoming ethereum to tokens for the caller
     */
    function buy() public payable returns(uint256) {
        purchaseTokens(msg.value);
    }

    /**
     * Fallback function to handle ethereum that was send straight to the contract
     */
    function() public payable {
        purchaseTokens(msg.value);
    }

    /**
     * Converts all of caller's dividends to tokens.
     */
    function reinvest() public onlyStronghands() {
        // fetch dividends
        uint256 _dividends = myDividends();

        // pay out the dividends virtually
        address _customerAddress = msg.sender;
        payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);

        // dispatch a buy order with the virtualized "withdrawn dividends"
        uint256 _tokens = purchaseTokens(_dividends);

        // fire event
        emit onReinvestment(_customerAddress, _dividends, _tokens);
    }

    /**
     * Alias of sell() and withdraw().
     */
    function exit() public {
        // get token count for caller & sell them all
        address _customerAddress = msg.sender;
        uint256 _tokens = tokenBalanceLedger_[_customerAddress];
        if(_tokens > 0) sell(_tokens);

        // lambo delivery service
        withdraw();
    }

    /**
     * Withdraws all of the callers earnings.
     */
    function withdraw() public onlyStronghands() {
        // setup data
        address _customerAddress = msg.sender;
        uint256 _dividends = myDividends();

        // update dividend tracker
        payoutsTo_[_customerAddress] +=  (int256) (_dividends * magnitude);

        // lambo delivery service
        _customerAddress.transfer(_dividends);

        // fire event
        emit onWithdraw(_customerAddress, _dividends);
    }

    /**
     * Liquifies tokens to ethereum.
     */
    function sell(uint256 _amountOfTokens) public onlyBagholders() {
        // setup data
        address _customerAddress = msg.sender;
        // russian hackers BTFO
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress], "token to sell should be less then balance!");
        uint256 _tokens = _amountOfTokens;
        uint256 _ethereum = tokensToEthereum_(_tokens);
        uint256 _dividends = SafeMath.div(_ethereum, dividendFee_);
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);

        // burn the sold tokens
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokens);
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _tokens);

        // update dividends tracker
        int256 _updatedPayouts = (int256) (profitPerShare_ * _tokens + (_taxedEthereum * magnitude));
        payoutsTo_[_customerAddress] -= _updatedPayouts;      

        // dividing by zero is a bad idea
        if (tokenSupply_ > 0) {
            // update the amount of dividends per token
            profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
        }

        // fire event
        emit onTokenSell(_customerAddress, _tokens, _taxedEthereum);
    }

    /**
     * Transfer tokens from the caller to a new holder.
     * Remember, there's a 10% fee here as well.
     */
    function transfer(address _toAddress, uint256 _amountOfTokens) public onlyBagholders() returns(bool) {
        // setup
        address _customerAddress = msg.sender;

        // make sure we have the requested tokens
        // also disables transfers until adminstrator phase is over
        require(!initialState && (_amountOfTokens <= tokenBalanceLedger_[_customerAddress]), "initial state or token > balance!");

        // withdraw all outstanding dividends first
        if(myDividends() > 0) withdraw();

        // liquify 10% of the tokens that are transfered
        // these are dispersed to shareholders
        uint256 _tokenFee = SafeMath.div(_amountOfTokens, dividendFee_);
        uint256 _taxedTokens = SafeMath.sub(_amountOfTokens, _tokenFee);
        uint256 _dividends = tokensToEthereum_(_tokenFee);
  
        // burn the fee tokens
        tokenSupply_ = SafeMath.sub(tokenSupply_, _tokenFee);

        // exchange tokens
        tokenBalanceLedger_[_customerAddress] = SafeMath.sub(tokenBalanceLedger_[_customerAddress], _amountOfTokens);
        tokenBalanceLedger_[_toAddress] = SafeMath.add(tokenBalanceLedger_[_toAddress], _taxedTokens);

        // update dividend trackers
        payoutsTo_[_customerAddress] -= (int256) (profitPerShare_ * _amountOfTokens);
        payoutsTo_[_toAddress] += (int256) (profitPerShare_ * _taxedTokens);

        // disperse dividends among holders
        profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);

        // fire event
        emit Transfer(_customerAddress, _toAddress, _taxedTokens);

        // ERC20
        return true;
    }

    function payDividends() external payable {
        uint256 _dividends = msg.value;
        require(_dividends > 0, "dividends should be greater then 0!");
        // dividing by zero is a bad idea
        if (tokenSupply_ > 0) {
            // update the amount of dividends per token
            profitPerShare_ = SafeMath.add(profitPerShare_, (_dividends * magnitude) / tokenSupply_);
            totalGameDividends_ = SafeMath.add(totalGameDividends_, _dividends);
            // fire event
            emit onPayDividends(_dividends, profitPerShare_);
        }
    }

    /*----------  ADMINISTRATOR ONLY FUNCTIONS  ----------*/
    /**
     * In case the amassador quota is not met, the administrator can manually disable the ambassador phase.
     */
    function disableInitialStage() public onlyOwner() {
        require(initialState == true, "initial stage is already false!");
        initialState = false;
    }

    /**
     * In case one of us dies, we need to replace ourselves.
     */
    function setInitialInvestors(address _addr, bool _status) public onlyOwner() {
        initialInvestors[_addr] = _status;
    }

    /**
     * If we want to rebrand, we can.
     */
    function setName(string _name) public onlyOwner() {
        name = _name;
    }

    /**
     * If we want to rebrand, we can.
     */
    function setSymbol(string _symbol) public onlyOwner() {
        symbol = _symbol;
    }

    /*----------  HELPERS AND CALCULATORS  ----------*/
    /**
     * Method to view the current Ethereum stored in the contract
     * Example: totalEthereumBalance()
     */
    function totalEthereumBalance() public view returns(uint) {
        return address(this).balance;
    }

    /**
     * Retrieve the total token supply.
     */
    function totalSupply() public view returns(uint256) {
        return tokenSupply_;
    }

    /**
     * Retrieve the total Investment.
     */
    function totalInvestment() public view returns(uint256) {
        return totalInvestment_;
    }

    /**
     * Retrieve the total Game Dividends Paid.
     */
    function totalGameDividends() public view returns(uint256) {
        return totalGameDividends_;
    }

    /**
     * Retrieve the tokens owned by the caller.
     */
    function myTokens() public view returns(uint256) {
        address _customerAddress = msg.sender;
        return balanceOf(_customerAddress);
    }

    /**
     * Retrieve the dividends owned by the caller.
     */ 
    function myDividends() public view returns(uint256) {
        address _customerAddress = msg.sender;
        return dividendsOf(_customerAddress) ;
    }

    /**
     * Retrieve the token balance of any single address.
     */
    function balanceOf(address _customerAddress) public view returns(uint256) {
        return tokenBalanceLedger_[_customerAddress];
    }

    /**
     * Retrieve the dividend balance of any single address.
     */
    function dividendsOf(address _customerAddress) public view returns(uint256) {
        return (uint256) ((int256)(profitPerShare_ * tokenBalanceLedger_[_customerAddress]) - payoutsTo_[_customerAddress]) / magnitude;
    }

    /**
     * Return the sell price of 1 individual token.
     */
    function sellPrice() public view returns(uint256) {
        // our calculation relies on the token supply, so we need supply.
        if(tokenSupply_ == 0){
            return 0;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _dividends = SafeMath.div(_ethereum, dividendFee_);
            uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
            return _taxedEthereum;
        }
    }

    /**
     * Return the buy price of 1 individual token.
     */
    function buyPrice() public view returns(uint256) {
        // our calculation relies on the token supply, so we need supply.
        if(tokenSupply_ == 0){
            return tokenPriceInitial_ + tokenPriceIncremental_;
        } else {
            uint256 _ethereum = tokensToEthereum_(1e18);
            uint256 _dividends = SafeMath.div(_ethereum, dividendFee_);
            uint256 _taxedEthereum = SafeMath.add(_ethereum, _dividends);
            return _taxedEthereum;
        }
    }

    /**
     * Function for the frontend to dynamically retrieve the price scaling of buy orders.
     */
    function calculateTokensReceived(uint256 _ethereumToSpend) public view returns(uint256) {
        uint256 _dividends = SafeMath.div(_ethereumToSpend, dividendFee_);
        uint256 _taxedEthereum = SafeMath.sub(_ethereumToSpend, _dividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        return _amountOfTokens;
    }

    /**
     * Function for the frontend to dynamically retrieve the price scaling of sell orders.
     */
    function calculateEthereumReceived(uint256 _tokensToSell) public view returns(uint256) {
        require(_tokensToSell <= tokenSupply_, "token to sell should be less then total supply!");
        uint256 _ethereum = tokensToEthereum_(_tokensToSell);
        uint256 _dividends = SafeMath.div(_ethereum, dividendFee_);
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);
        return _taxedEthereum;
    }

    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/
    function purchaseTokens(uint256 _incomingEthereum) internal onlyInitialInvestors() returns(uint256) {
        // data setup
        address _customerAddress = msg.sender;
        uint256 _dividends = SafeMath.div(_incomingEthereum, dividendFee_);
        uint256 _taxedEthereum = SafeMath.sub(_incomingEthereum, _dividends);
        uint256 _amountOfTokens = ethereumToTokens_(_taxedEthereum);
        uint256 _fee = _dividends * magnitude;

        require((_amountOfTokens > 0 && (SafeMath.add(_amountOfTokens, tokenSupply_) > tokenSupply_)), "token should be > 0!");

        // we can't give people infinite ethereum
        if(tokenSupply_ > 0) {

            // add tokens to the pool
            tokenSupply_ = SafeMath.add(tokenSupply_, _amountOfTokens);
 
            // take the amount of dividends gained through this transaction, and allocates them evenly to each shareholder
            profitPerShare_ += (_dividends * magnitude / (tokenSupply_));

            // calculate the amount of tokens the customer receives over his purchase 
            _fee = _fee - (_fee-(_amountOfTokens * (_dividends * magnitude / (tokenSupply_))));
        } else {
            // add tokens to the pool
            tokenSupply_ = _amountOfTokens;
        }

        totalInvestment_ = SafeMath.add(totalInvestment_, _incomingEthereum);

        // update circulating supply & the ledger address for the customer
        tokenBalanceLedger_[_customerAddress] = SafeMath.add(tokenBalanceLedger_[_customerAddress], _amountOfTokens);

        // Tells the contract that the buyer doesn't deserve dividends for the tokens before they owned them;
        //really i know you think you do but you don't
        int256 _updatedPayouts = (int256) ((profitPerShare_ * _amountOfTokens) - _fee);
        payoutsTo_[_customerAddress] += _updatedPayouts;

        // disable initial stage if investor quota of 0.01 eth is reached
        if(address(this).balance >= INVESTOR_QUOTA) {
            initialState = false;
        }

        // fire event
        emit onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens);

        return _amountOfTokens;
    }

    /**
     * Calculate Token price based on an amount of incoming ethereum
     * It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;
     * Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.
     */
    function ethereumToTokens_(uint256 _ethereum) internal view returns(uint256) {
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
        )-(tokenSupply_);
        return _tokensReceived;
    }

    /**
     * Calculate token sell value.
     * It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;
     * Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.
     */
    function tokensToEthereum_(uint256 _tokens) internal view returns(uint256) {
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

    //This is where all your gas goes, sorry
    //Not sorry, you probably only paid 1 gwei
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
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }
        uint256 c = _a * _b;
        require(c / _a == _b);
        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        return c;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;
        return c;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract Constants {
    address internal constant OWNER_WALLET_ADDR = address(0x508b828440D72B0De506c86DB79D9E2c19810442);
    address internal constant COMPANY_WALLET_ADDR = address(0xEE50069c177721fdB06755427Fd19853681E86a2);
    address internal constant LAST10_WALLET_ADDR = address(0xe7d8Bf9B85EAE450f2153C66cdFDfD31D56750d0);
    address internal constant FEE_WALLET_ADDR = address(0x6Ba3B9E117F58490eC0e68cf3e48d606C2f2475b);
    uint internal constant LAST_10_MIN_INVESTMENT = 2 ether;
}

contract InvestorsStorage {
    using SafeMath for uint;
    using Percent for Percent.percent;
    struct investor {
        uint keyIndex;
        uint value;
        uint paymentTime;
        uint refs;
        uint refBonus;
        uint pendingPayout;
        uint pendingPayoutTime;
    }
    struct recordStats {
        uint investors;
        uint invested;
    }
    struct itmap {
        mapping(uint => recordStats) stats;
        mapping(address => investor) data;
        address[] keys;
    }
    itmap private s;

    address private owner;
    
    Percent.percent private _percent = Percent.percent(1,100);

    event LogOwnerForInvestorContract(address addr);

    modifier onlyOwner() {
        require(msg.sender == owner, "access denied");
        _;
    }

    constructor() public {
        owner = msg.sender;
        emit LogOwnerForInvestorContract(msg.sender);
        s.keys.length++;
    }
    
    function getDividendsPercent(address addr) public view returns(uint num, uint den) {
        uint amount = s.data[addr].value.add(s.data[addr].refBonus);
        if(amount <= 10*10**18) { //10 ETH
            return (15, 1000);
        } else if(amount <= 50*10**18) { //50 ETH
            return (16, 1000);
        } else if(amount <= 100*10**18) { //100 ETH
            return (17, 1000);
        } else if(amount <= 300*10**18) { //300 ETH
            return (185, 10000); //Extra zero for two digits after decimal
        } else {
            return (2, 100);
        }
    }

    function insert(address addr, uint value) public onlyOwner returns (bool) {
        uint keyIndex = s.data[addr].keyIndex;
        if (keyIndex != 0) return false;
        s.data[addr].value = value;
        keyIndex = s.keys.length++;
        s.data[addr].keyIndex = keyIndex;
        s.keys[keyIndex] = addr;
        return true;
    }

    function investorFullInfo(address addr) public view returns(uint, uint, uint, uint, uint, uint, uint) {
        return (
        s.data[addr].keyIndex,
        s.data[addr].value,
        s.data[addr].paymentTime,
        s.data[addr].refs,
        s.data[addr].refBonus,
        s.data[addr].pendingPayout,
        s.data[addr].pendingPayoutTime
        );
    }

    function investorBaseInfo(address addr) public view returns(uint, uint, uint, uint, uint, uint) {
        return (
        s.data[addr].value,
        s.data[addr].paymentTime,
        s.data[addr].refs,
        s.data[addr].refBonus,
        s.data[addr].pendingPayout,
        s.data[addr].pendingPayoutTime
        );
    }

    function investorShortInfo(address addr) public view returns(uint, uint) {
        return (
        s.data[addr].value,
        s.data[addr].refBonus
        );
    }

    function addRefBonus(address addr, uint refBonus, uint dividendsPeriod) public onlyOwner returns (bool) {
        if (s.data[addr].keyIndex == 0) {
            assert(insert(addr, 0));
        }

        uint time;
        if (s.data[addr].pendingPayoutTime == 0) {
            time = s.data[addr].paymentTime;
        } else {
            time = s.data[addr].pendingPayoutTime;
        }

        if(time != 0) {
            uint value = 0;
            uint256 daysAfter = now.sub(time).div(dividendsPeriod);
            if(daysAfter > 0) {
                value = _getValueForAddr(addr, daysAfter);
            }
            s.data[addr].refBonus += refBonus;
            uint256 hoursAfter = now.sub(time).mod(dividendsPeriod);
            if(hoursAfter > 0) {
                uint dailyDividends = _getValueForAddr(addr, 1);
                uint hourlyDividends = dailyDividends.div(dividendsPeriod).mul(hoursAfter);
                value = value.add(hourlyDividends);
            }
            if (s.data[addr].pendingPayoutTime == 0) {
                s.data[addr].pendingPayout = value;
            } else {
                s.data[addr].pendingPayout = s.data[addr].pendingPayout.add(value);
            }
        } else {
            s.data[addr].refBonus += refBonus;
            s.data[addr].refs++;
        }
        assert(setPendingPayoutTime(addr, now));
        return true;
    }

    function _getValueForAddr(address addr, uint daysAfter) internal returns (uint value) {
        (uint num, uint den) = getDividendsPercent(addr);
        _percent = Percent.percent(num, den);
        value = _percent.mul(s.data[addr].value.add(s.data[addr].refBonus)) * daysAfter;
    }

    function addRefBonusWithRefs(address addr, uint refBonus, uint dividendsPeriod) public onlyOwner returns (bool) {
        if (s.data[addr].keyIndex == 0) {
            assert(insert(addr, 0));
        }

        uint time;
        if (s.data[addr].pendingPayoutTime == 0) {
            time = s.data[addr].paymentTime;
        } else {
            time = s.data[addr].pendingPayoutTime;
        }

        if(time != 0) {
            uint value = 0;
            uint256 daysAfter = now.sub(time).div(dividendsPeriod);
            if(daysAfter > 0) {
                value = _getValueForAddr(addr, daysAfter);
            }
            s.data[addr].refBonus += refBonus;
            s.data[addr].refs++;
            uint256 hoursAfter = now.sub(time).mod(dividendsPeriod);
            if(hoursAfter > 0) {
                uint dailyDividends = _getValueForAddr(addr, 1);
                uint hourlyDividends = dailyDividends.div(dividendsPeriod).mul(hoursAfter);
                value = value.add(hourlyDividends);
            }
            if (s.data[addr].pendingPayoutTime == 0) {
                s.data[addr].pendingPayout = value;
            } else {
                s.data[addr].pendingPayout = s.data[addr].pendingPayout.add(value);
            }
        } else {
            s.data[addr].refBonus += refBonus;
            s.data[addr].refs++;
        }
        assert(setPendingPayoutTime(addr, now));
        return true;
    }

    function addValue(address addr, uint value) public onlyOwner returns (bool) {
        if (s.data[addr].keyIndex == 0) return false;
        s.data[addr].value += value;       
        return true;
    }

    function updateStats(uint dt, uint invested, uint investors) public {
        s.stats[dt].invested += invested;
        s.stats[dt].investors += investors;
    }
    
    function stats(uint dt) public view returns (uint invested, uint investors) {
        return ( 
        s.stats[dt].invested,
        s.stats[dt].investors
        );
    }

    function setPaymentTime(address addr, uint paymentTime) public onlyOwner returns (bool) {
        if (s.data[addr].keyIndex == 0) return false;
        s.data[addr].paymentTime = paymentTime;
        return true;
    }

    function setPendingPayoutTime(address addr, uint payoutTime) public onlyOwner returns (bool) {
        if (s.data[addr].keyIndex == 0) return false;
        s.data[addr].pendingPayoutTime = payoutTime;
        return true;
    }

    function setPendingPayout(address addr, uint payout) public onlyOwner returns (bool) {
        if (s.data[addr].keyIndex == 0) return false;
        s.data[addr].pendingPayout = payout;
        return true;
    }
    
    function contains(address addr) public view returns (bool) {
        return s.data[addr].keyIndex > 0;
    }

    function size() public view returns (uint) {
        return s.keys.length;
    }

    function iterStart() public pure returns (uint) {
        return 1;
    }
}

contract DT {
    struct DateTime {
        uint16 year;
        uint8 month;
        uint8 day;
        uint8 hour;
        uint8 minute;
        uint8 second;
        uint8 weekday;
    }

    uint private constant DAY_IN_SECONDS = 86400;
    uint private constant YEAR_IN_SECONDS = 31536000;
    uint private constant LEAP_YEAR_IN_SECONDS = 31622400;

    uint16 private constant ORIGIN_YEAR = 1970;

    function isLeapYear(uint16 year) internal pure returns (bool) {
        if (year % 4 != 0) {
            return false;
        }
        if (year % 100 != 0) {
            return true;
        }
        if (year % 400 != 0) {
            return false;
        }
        return true;
    }

    function leapYearsBefore(uint year) internal pure returns (uint) {
        year -= 1;
        return year / 4 - year / 100 + year / 400;
    }

    function getDaysInMonth(uint8 month, uint16 year) internal pure returns (uint8) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            return 31;
        } else if (month == 4 || month == 6 || month == 9 || month == 11) {
            return 30;
        } else if (isLeapYear(year)) {
            return 29;
        } else {
            return 28;
        }
    }

    function parseTimestamp(uint timestamp) internal pure returns (DateTime dt) {
        uint secondsAccountedFor = 0;
        uint buf;
        uint8 i;

        // Year
        dt.year = getYear(timestamp);
        buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
        secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);

        // Month
        uint secondsInMonth;
        for (i = 1; i <= 12; i++) {
            secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);
            if (secondsInMonth + secondsAccountedFor > timestamp) {
                dt.month = i;
                break;
            }
            secondsAccountedFor += secondsInMonth;
        }

        // Day
        for (i = 1; i <= getDaysInMonth(dt.month, dt.year); i++) {
            if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                dt.day = i;
                break;
            }
            secondsAccountedFor += DAY_IN_SECONDS;
        }
    }

        
    function getYear(uint timestamp) internal pure returns (uint16) {
        uint secondsAccountedFor = 0;
        uint16 year;
        uint numLeapYears;

        // Year
        year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
        numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

        secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
        secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

        while (secondsAccountedFor > timestamp) {
            if (isLeapYear(uint16(year - 1))) {
                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
            }
            else {
                secondsAccountedFor -= YEAR_IN_SECONDS;
            }
            year -= 1;
        }
        return year;
    }

    function getMonth(uint timestamp) internal pure returns (uint8) {
        return parseTimestamp(timestamp).month;
    }

    function getDay(uint timestamp) internal pure returns (uint8) {
        return parseTimestamp(timestamp).day;
    }
}

contract _200eth is DT, Constants {
    using Percent for Percent.percent;
    using SafeMath for uint;
    using Zero for *;
    using ToAddress for *;
    using Convert for *;

    // investors storage - iterable map;
    InvestorsStorage private m_investors = new InvestorsStorage();
    mapping(address => address) public m_referrals;
    mapping(address => bool) public m_isInvestor;
    bool public m_nextWave = false;

    // last 10 storage who's investment >= 2 ether
    struct Last10Struct {
        uint value;
        uint index;
    }
    address[] private m_last10InvestorAddr;
    mapping(address => Last10Struct) private m_last10Investor;

    // automatically generates getters
    address public ownerAddr;
    uint public totalInvestments = 0;
    uint public totalInvested = 0;
    uint public constant minInvesment = 10 finney; // 0.01 eth
    uint public constant dividendsPeriod = 5 minutes; //5 minutes
    uint private gasFee = 0;
    uint private last10 = 0;

    //Pyramid Coin instance required to send dividends to coin holders.
    E2D public e2d;

    // percents 
    Percent.percent private m_companyPercent = Percent.percent(10, 100); // 10/100*100% = 10%
    Percent.percent private m_refPercent1 = Percent.percent(3, 100); // 3/100*100% = 3%
    Percent.percent private m_refPercent2 = Percent.percent(2, 100); // 2/100*100% = 2%
    Percent.percent private m_fee = Percent.percent(1, 100); // 1/100*100% = 1%
    Percent.percent private m_coinHolders = Percent.percent(5, 100); // 5/100*100% = 5%
    Percent.percent private m_last10 = Percent.percent(4, 100); // 4/100*100% = 4%
    Percent.percent private _percent = Percent.percent(1,100);

    // more events for easy read from blockchain
    event LogNewInvestor(address indexed addr, uint when, uint value);
    event LogNewInvesment(address indexed addr, uint when, uint value);
    event LogNewReferral(address indexed addr, uint when, uint value);
    event LogPayDividends(address indexed addr, uint when, uint value);
    event LogBalanceChanged(uint when, uint balance);
    event LogNextWave(uint when);
    event LogPayLast10(address addr, uint percent, uint amount);

    modifier balanceChanged {
        _;
        emit LogBalanceChanged(now, address(this).balance.sub(last10).sub(gasFee));
    }

    constructor(address _tokenAddress) public {
        ownerAddr = OWNER_WALLET_ADDR;
        e2d = E2D(_tokenAddress);
        setup();
    }

    function isContract(address _addr) private view returns (bool isWalletAddress){
        uint32 size;
        assembly{
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function setup() internal {
        m_investors = new InvestorsStorage();
        totalInvestments = 0;
        totalInvested = 0;
        gasFee = 0;
        last10 = 0;
        for (uint i = 0; i < m_last10InvestorAddr.length; i++) {
            delete m_last10Investor[m_last10InvestorAddr[i]];
        }
        m_last10InvestorAddr.length = 1;
    }

    // start the next round of game only after previous is completed.
    function startNewWave() public {
        require(m_nextWave == true, "Game is not stopped yet.");
        require(msg.sender == ownerAddr, "Only Owner can call this function");
        m_nextWave = false;
    }

    function() public payable {
        // investor get him dividends
        if (msg.value == 0) {
            getMyDividends();
            return;
        }
        // sender do invest
        address refAddr = msg.data.toAddr();
        doInvest(refAddr);
    }

    function investorsNumber() public view returns(uint) {
        return m_investors.size() - 1;
        // -1 because see InvestorsStorage constructor where keys.length++ 
    }

    function balanceETH() public view returns(uint) {
        return address(this).balance.sub(last10).sub(gasFee);
    }

    function dividendsPercent() public view returns(uint numerator, uint denominator) {
        (uint num, uint den) = m_investors.getDividendsPercent(msg.sender);
        (numerator, denominator) = (num,den);
    }

    function companyPercent() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_companyPercent.num, m_companyPercent.den);
    }

    function coinHolderPercent() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_coinHolders.num, m_coinHolders.den);
    }

    function last10Percent() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_last10.num, m_last10.den);
    }

    function feePercent() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_fee.num, m_fee.den);
    }

    function referrer1Percent() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_refPercent1.num, m_refPercent1.den);
    }

    function referrer2Percent() public view returns(uint numerator, uint denominator) {
        (numerator, denominator) = (m_refPercent2.num, m_refPercent2.den);
    }

    function stats(uint date) public view returns(uint invested, uint investors) {
        (invested, investors) = m_investors.stats(date);
    }

    function last10Addr() public view returns(address[]) {
        return m_last10InvestorAddr;
    }

    function last10Info(address addr) public view returns(uint value, uint index) {
        return (
            m_last10Investor[addr].value,
            m_last10Investor[addr].index
        );
    }

    function investorInfo(address addr) public view returns(uint value, uint paymentTime, uint refsCount, uint refBonus,
     uint pendingPayout, uint pendingPayoutTime, bool isReferral, uint dividends) {
        (value, paymentTime, refsCount, refBonus, pendingPayout, pendingPayoutTime) = m_investors.investorBaseInfo(addr);
        isReferral = m_referrals[addr].notZero();
        dividends = checkDividends(addr);
    }

    function checkDividends(address addr) internal view returns (uint) {
        InvestorsStorage.investor memory investor = getMemInvestor(addr);
        if(investor.keyIndex <= 0){
            return 0;
        }
        uint256 time;
        uint256 value = 0;
        if(investor.pendingPayoutTime == 0) {
            time = investor.paymentTime;
        } else {
            time = investor.pendingPayoutTime;
            value = investor.pendingPayout;
        }
        // calculate days after payout time
        uint256 daysAfter = now.sub(time).div(dividendsPeriod);
        if(daysAfter > 0){
            uint256 totalAmount = investor.value.add(investor.refBonus);
            (uint num, uint den) = m_investors.getDividendsPercent(addr);
            value = value.add((totalAmount*num/den) * daysAfter);
        }
        return value;
    }

    function _getMyDividents(bool withoutThrow) private {
        address addr = msg.sender;
        require(!isContract(addr),"msg.sender must wallet");
        // check investor info
        InvestorsStorage.investor memory investor = getMemInvestor(addr);
        if(investor.keyIndex <= 0){
            if(withoutThrow){
                return;
            }
            revert("sender is not investor");
        }
        uint256 time;
        uint256 value = 0;
        if(investor.pendingPayoutTime == 0) {
            time = investor.paymentTime;
        } else {
            time = investor.pendingPayoutTime;
            value = investor.pendingPayout;
        }

        // calculate days after payout time
        uint256 daysAfter = now.sub(time).div(dividendsPeriod);
        if(daysAfter > 0){
            uint256 totalAmount = investor.value.add(investor.refBonus);
            (uint num, uint den) = m_investors.getDividendsPercent(addr);
            value = value.add((totalAmount*num/den) * daysAfter);
        }
        if(value == 0) {
            if(withoutThrow){
                return;
            }
            revert("the latest payment was earlier than dividents period");
        } else {
            if (checkBalanceState(addr, value)) {
                return;
            }
        }

        assert(m_investors.setPaymentTime(msg.sender, now));

        assert(m_investors.setPendingPayoutTime(msg.sender, 0));

        assert(m_investors.setPendingPayout(msg.sender, 0));

        sendDividends(msg.sender, value);
    }

    function checkBalanceState(address addr, uint value) private returns(bool) {
        uint checkBal = address(this).balance.sub(last10).sub(gasFee);
        if(checkBal < value) {
            sendDividends(addr, checkBal);
            return true;
        }
        return false;
    }

    function getMyDividends() public balanceChanged {
        _getMyDividents(false);
    }

    function doInvest(address _ref) public payable balanceChanged {
        require(!isContract(msg.sender),"msg.sender must wallet address");
        require(msg.value >= minInvesment, "msg.value must be >= minInvesment");
        require(!m_nextWave, "no further investment in this pool");
        uint value = msg.value;
        //ref system works only once for sender-referral
        if ((!m_isInvestor[msg.sender] && !m_referrals[msg.sender].notZero()) || 
        (m_isInvestor[msg.sender] && m_referrals[msg.sender].notZero())) {
            address ref = m_referrals[msg.sender].notZero() ? m_referrals[msg.sender] : _ref;
            // level 1
            if(notZeroNotSender(ref) && m_isInvestor[ref]) {
                // referrer 1 bonus
                uint reward = m_refPercent1.mul(value);
                if(m_referrals[msg.sender].notZero()) {
                    assert(m_investors.addRefBonus(ref, reward, dividendsPeriod));
                } else {
                    assert(m_investors.addRefBonusWithRefs(ref, reward, dividendsPeriod));
                    m_referrals[msg.sender] = ref;
                }
                emit LogNewReferral(msg.sender, now, value); 
                // level 2
                if (notZeroNotSender(m_referrals[ref]) && m_isInvestor[m_referrals[ref]] && ref != m_referrals[ref]) { 
                    reward = m_refPercent2.mul(value);
                    assert(m_investors.addRefBonus(m_referrals[ref], reward, dividendsPeriod)); // referrer 2 bonus
                }
            }
        }

        checkLast10(value);

        // company commission
        COMPANY_WALLET_ADDR.transfer(m_companyPercent.mul(value));
         // coin holder commission
        e2d.payDividends.value(m_coinHolders.mul(value))();
         // reserved for last 10 distribution
        last10 = last10.add(m_last10.mul(value));
        //reserved for gas fee
        gasFee = gasFee.add(m_fee.mul(value));

        _getMyDividents(true);

        DT.DateTime memory dt = parseTimestamp(now);
        uint today = dt.year.uintToString().strConcat((dt.month<10 ? "0":""), dt.month.uintToString(), (dt.day<10 ? "0":""), dt.day.uintToString()).stringToUint();

        //write to investors storage
        if (m_investors.contains(msg.sender)) {
            assert(m_investors.addValue(msg.sender, value));
            m_investors.updateStats(today, value, 0);
        } else {
            assert(m_investors.insert(msg.sender, value));
            m_isInvestor[msg.sender] = true;
            m_investors.updateStats(today, value, 1);
            emit LogNewInvestor(msg.sender, now, value); 
        }

        assert(m_investors.setPaymentTime(msg.sender, now));

        emit LogNewInvesment(msg.sender, now, value);   
        totalInvestments++;
        totalInvested += msg.value;
    }

    function checkLast10(uint value) internal {
        //check if value is >= 2 then add to last 10 
        if(value >= LAST_10_MIN_INVESTMENT) {
            if(m_last10Investor[msg.sender].index != 0) {
                uint index = m_last10Investor[msg.sender].index;
                removeFromLast10AtIndex(index);
            } else if(m_last10InvestorAddr.length == 11) {
                delete m_last10Investor[m_last10InvestorAddr[1]];
                removeFromLast10AtIndex(1);
            }
            m_last10InvestorAddr.push(msg.sender);
            m_last10Investor[msg.sender].index = m_last10InvestorAddr.length - 1;
            m_last10Investor[msg.sender].value = value;
        }
    }

    function removeFromLast10AtIndex(uint index) internal {
        for (uint i = index; i < m_last10InvestorAddr.length-1; i++){
            m_last10InvestorAddr[i] = m_last10InvestorAddr[i+1];
            m_last10Investor[m_last10InvestorAddr[i]].index = i;
        }
        delete m_last10InvestorAddr[m_last10InvestorAddr.length-1];
        m_last10InvestorAddr.length--;
    }

    function getMemInvestor(address addr) internal view returns(InvestorsStorage.investor) {
        (uint a, uint b, uint c, uint d, uint e, uint f, uint g) = m_investors.investorFullInfo(addr);
        return InvestorsStorage.investor(a, b, c, d, e, f, g);
    }

    function notZeroNotSender(address addr) internal view returns(bool) {
        return addr.notZero() && addr != msg.sender;
    }

    function sendDividends(address addr, uint value) private {
        if (addr.send(value)) {
            emit LogPayDividends(addr, now, value);
            if(address(this).balance.sub(gasFee).sub(last10) <= 0.005 ether) {
                nextWave();
                return;
            }
        }
    }

    function sendToLast10() private {
        uint lastPos = m_last10InvestorAddr.length - 1;
        uint index = 0;
        uint distributed = 0;
        for (uint pos = lastPos; pos > 0 ; pos--) {
            _percent = getPercentByPosition(index);
            uint amount = _percent.mul(last10);
            if( (!isContract(m_last10InvestorAddr[pos]))){
                m_last10InvestorAddr[pos].transfer(amount);
                emit LogPayLast10(m_last10InvestorAddr[pos], _percent.num, amount);
                distributed = distributed.add(amount);
            }
            index++;
        }

        last10 = last10.sub(distributed);
        //check if amount is left in last10 and transfer 
        if(last10 > 0) {
            LAST10_WALLET_ADDR.transfer(last10);
            last10 = 0;
        }
    }

    function getPercentByPosition(uint position) internal pure returns(Percent.percent) {
        if(position == 0) {
            return Percent.percent(40, 100); // 40%
        } else if(position == 1) {
            return Percent.percent(25, 100); // 25%
        } else if(position == 2) {
            return Percent.percent(15, 100); // 15%
        } else if(position == 3) {
            return Percent.percent(8, 100); // 8%
        } else if(position == 4) {
            return Percent.percent(5, 100); // 5%
        } else if(position == 5) {
            return Percent.percent(2, 100); // 2%
        } else if(position == 6) {
            return Percent.percent(2, 100); // 2%
        } else if(position == 7) {
            return Percent.percent(15, 1000); // 1.5%
        } else if(position == 8) {
            return Percent.percent(1, 100); // 1%
        } else if(position == 9) {
            return Percent.percent(5, 1000); // 0.5%
        }
    }

    function nextWave() private {
        if(m_nextWave) {
            return; 
        }
        m_nextWave = true;
        sendToLast10();
        //send gas fee to wallet
        FEE_WALLET_ADDR.transfer(gasFee);
        //send remaining contract balance to company wallet
        COMPANY_WALLET_ADDR.transfer(address(this).balance);
        setup();
        emit LogNextWave(now);
    }
}

library Percent {
  // Solidity automatically throws when dividing by 0
    struct percent {
        uint num;
        uint den;
    }
    function mul(percent storage p, uint a) internal view returns (uint) {
        if (a == 0) {
            return 0;
        }
        return a*p.num/p.den;
    }
    
    function div(percent storage p, uint a) internal view returns (uint) {
        return a/p.num*p.den;
    }

    function sub(percent storage p, uint a) internal view returns (uint) {
        uint b = mul(p, a);
        if (b >= a) return 0;
        return a - b;
    }

    function add(percent storage p, uint a) internal view returns (uint) {
        return a + mul(p, a);
    }
}

library Zero {
    function requireNotZero(uint a) internal pure {
        require(a != 0, "require not zero");
    }

    function requireNotZero(address addr) internal pure {
        require(addr != address(0), "require not zero address");
    }

    function notZero(address addr) internal pure returns(bool) {
        return !(addr == address(0));
    }

    function isZero(address addr) internal pure returns(bool) {
        return addr == address(0);
    }
}

library ToAddress {
    function toAddr(uint source) internal pure returns(address) {
        return address(source);
    }

    function toAddr(bytes source) internal pure returns(address addr) {
        assembly { addr := mload(add(source,0x14)) }
        return addr;
    }
}

library Convert {
    function stringToUint(string s) internal pure returns (uint) {
        bytes memory b = bytes(s);
        uint result = 0;
        for (uint i = 0; i < b.length; i++) { // c = b[i] was not needed
            if (b[i] >= 48 && b[i] <= 57) {
                result = result * 10 + (uint(b[i]) - 48); // bytes and int are not compatible with the operator -.
            }
        }
        return result; // this was missing
    }

    function uintToString(uint v) internal pure returns (string) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory s = new bytes(i); // i + 1 is inefficient
        for (uint j = 0; j < i; j++) {
            s[j] = reversed[i - j - 1]; // to avoid the off-by-one error
        }
        string memory str = string(s);  // memory isn't implicitly convertible to storage
        return str; // this was missing
    }

    function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }
    
    function strConcat(string _a, string _b, string _c, string _d) internal pure returns (string) {
        return strConcat(_a, _b, _c, _d, "");
    }
    
    function strConcat(string _a, string _b, string _c) internal pure returns (string) {
        return strConcat(_a, _b, _c, "", "");
    }
    
    function strConcat(string _a, string _b) internal pure returns (string) {
        return strConcat(_a, _b, "", "", "");
    }
}