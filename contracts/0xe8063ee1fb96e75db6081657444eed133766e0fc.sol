pragma solidity ^0.4.25;

contract RunAway {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    /*=================================
    =            MODIFIERS            =
    =================================*/
    // only people with tokens
    modifier onlyBagholders() {
        require(myTokens() > 0);
        _;
    }

    /**
     * @dev prevents contracts from interacting with me
     */
    modifier onlyHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;

        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }

    // administrators can:
    // -> change the name of the contract
    // -> change the name of the token
    // -> start the game(activate)
    // they CANNOT:
    // -> take funds
    // -> disable withdrawals
    // -> kill the contract
    // -> change the price of tokens
    modifier onlyAdministrator(){
        address _customerAddress = msg.sender;
        require(administrators[keccak256(abi.encodePacked(_customerAddress))]);
        _;
    }

    modifier onlyComm1(){
        address _customerAddress = msg.sender;
        require(keccak256(abi.encodePacked(_customerAddress)) == comm1_);
        _;
    }

    modifier onlyComm2{
        address _customerAddress = msg.sender;
        require(keccak256(abi.encodePacked(_customerAddress)) == comm2_);
        _;
    }

    modifier checkRoundStatus()
    {
      if(now >= rounds_[currentRoundID_].endTime)
      {
        endCurrentRound();
        startNextRound();
      }
      _;
    }

    function startNextRound()
      private
      {
        currentRoundID_ ++;
        rounds_[currentRoundID_].roundID = currentRoundID_;
        rounds_[currentRoundID_].startTime = now;
        rounds_[currentRoundID_].endTime = now + roundDuration_;
        rounds_[currentRoundID_].ended = false;
      }

      function endCurrentRound()
        private
      {
        Round storage round = rounds_[currentRoundID_];
        round.ended = true;
        if(round.netBuySum>0 && round.dividends>0)
        {
          round.profitPerShare = round.dividends.mul(magnitude).div(round.netBuySum);
        }
      }

        modifier isActivated() {
            require(activated_ == true, "its not ready yet.  check ?eta in discord");
            _;
        }

    // ensures that the first tokens in the contract will be equally distributed
    // meaning, no divine dump will be ever possible
    // result: healthy longevity.
    modifier antiEarlyWhale(uint256 _amountOfEthereum){
        address _customerAddress = msg.sender;

        // are we still in the vulnerable phase?
        // if so, enact anti early whale protocol
        if( onlyAmbassadors && ((totalEthereumBalance() - _amountOfEthereum) <= ambassadorQuota_ )){
            require(
                // is the customer in the ambassador list?
                ambassadors_[_customerAddress] == true &&

                // does the customer purchase exceed the max ambassador quota?
                (ambassadorAccumulatedQuota_[_customerAddress] + _amountOfEthereum) <= ambassadorMaxPurchase_

            );

            // updated the accumulated quota
            ambassadorAccumulatedQuota_[_customerAddress] = SafeMath.add(ambassadorAccumulatedQuota_[_customerAddress], _amountOfEthereum);

            // execute
            _;
        } else {
            // in case the ether count drops low, the ambassador phase won't reinitiate
            onlyAmbassadors = false;
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
    event onAcquireDividends(
        address indexed customerAddress,
        uint256 dividendsAcquired
    );

    // ERC20
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 tokens
    );

    event onWithDrawComm(
      uint8 indexed comm,
      uint256 ethereumWithdrawn
    );

    event onTransferExpiredDividends(
      address indexed customerAddress,
      uint256 roundID,
      uint256 amount
    );
    /*=====================================
    =            Structs                  =
    =====================================*/
    struct Round {
        uint256 roundID;   // Starting from 1, increasing by 1
        uint256 netBuySum;   // Sum of all userNetBuy which are > 0
        uint256 endTime;
        bool ended;
        uint256 startTime;
        uint256 profitPerShare;
        uint256 dividends;
        mapping(address=>int256) userNetBuy;
        mapping(address => uint256) payoutsTo;
        uint256 totalPayouts;
    }

    // Rounds recorder
    mapping(uint256=>Round) public rounds_;

    // Fees storage accounts
    uint256 public comm1Balance_;
    uint256 public comm2Balance_;
    bytes32 comm1_=0xc0495b4fc42a03a01bdcd5e2f7b89dfd2e077e19f273ff82d33e9ec642fc7a08;
    bytes32 comm2_=0xa1bb9d7f7e4c2b049c73772f2cab50235f20a685f798970054b74fbc6d411c1e;

    // Current round ID
    uint256 public currentRoundID_;
    uint256 public roundDuration_ = 1 days;
    // Is game started?
    bool public activated_=false;

    /*=====================================
    =            CONFIGURABLES            =
    =====================================*/
    string public name = "Run Away";
    string public symbol = "RUN";
    uint8 constant public decimals = 18;
    uint8 constant internal dividendFee_ = 10;
    uint8 constant internal communityFee_ = 50;
    uint256 constant internal tokenPriceInitial_ = 0.0000001 ether;
    uint256 constant internal tokenPriceIncremental_ = 0.00000001 ether;
    uint256 constant internal magnitude = 2**64;

    // ambassador program
    mapping(address => bool) internal ambassadors_;
    uint256 constant internal ambassadorMaxPurchase_ = 20 ether;
    uint256 constant internal ambassadorQuota_ = 120 ether;

   /*================================
    =            DATASETS            =
    ================================*/
    // amount of shares for each address (scaled number)
    mapping(address => uint256) internal tokenBalanceLedger_;
    // Income, including dividends in each round and sale income.
    mapping(address => uint256) public income_;
    mapping(address => uint256) internal ambassadorAccumulatedQuota_;
    uint256 internal tokenSupply_ = 0;

    // administrator list (see above on what they can do)
    mapping(bytes32 => bool) public administrators;

    // when this is set to true, only ambassadors can purchase tokens (this prevents a whale premine, it ensures a fairly distributed upper pyramid)
    bool public onlyAmbassadors = true;



    /*=======================================
    =            PUBLIC FUNCTIONS            =
    =======================================*/
    /*
    * -- APPLICATION ENTRY POINTS --
    */
    constructor()
        public
    {
        // add administrators here
        administrators[0x2a94d36a11c723ddffd4bf9352609aed9b400b2be1e9b272421fa7b4e7a40560] = true;

        // add the ambassadors here.
        ambassadors_[0x16F2971f677DDCe04FC44bb1A5289f0B96053b2C] = true;
        ambassadors_[0x579F9608b1fa6aA387BD2a3844469CA8fb10628c] = true;
        ambassadors_[0x62E691c598D968633EEAB5588b1AF95725E33316] = true;
        ambassadors_[0x9e3F432dc2CD4EfFB0F0EB060b07DC2dFc574d0D] = true;
        ambassadors_[0x63735870e79A653aA445d7b7B59DC9c1a7149F39] = true;
        ambassadors_[0x562DEd82A67f4d2ED3782181f938f2E4232aE02C] = true;
        ambassadors_[0x22ec2994d77E3Ca929eAc83dEF3958CC547ff028] = true;
        ambassadors_[0xF2e602645AC91727D75E66231d06F572E133E59F] = true;
        ambassadors_[0x1AA16F9A2428ceBa2eDeb5D544b3a3D767c1566e] = true;
        ambassadors_[0x273b270F0eA966a462feAC89C9d4f4D6Dcd1CbdF] = true;
        ambassadors_[0x7ABe6948E5288a30026EdE239446a0B84d502184] = true;
        ambassadors_[0xB6Aa76e55564D9dB18cAF61369ff4618F5287f43] = true;
        ambassadors_[0x3c6c909dB011Af05Dadd706D88a6Cd03D87a4f86] = true;
        ambassadors_[0x914132fe8075aF2d932cadAa7d603DDfDf70D353] = true;
        ambassadors_[0x8Be6Aa12746e84e448a18B20013F3AdB9e24e1c6] = true;
        ambassadors_[0x3595bA9Ab527101B5cc78195Ca043653d96fEEB6] = true;
        ambassadors_[0x17dBe44d9c91d2c71E33E3fd239BD1574A7f46DF] = true;
        ambassadors_[0x47Ce514A4392304D9Ccaa7A807776AcB391198D0] = true;
        ambassadors_[0x96b41F6DE1d579ea5CB87bA04834368727B993e4] = true;
        ambassadors_[0x0953800A059a9d30BD6E47Ae2D34f3665F8E2b53] = true;
        ambassadors_[0x497C85EeF12A17D3fEd3aef894ec3273046FdC1D] = true;
        ambassadors_[0x116febf80104677019ac4C9E693c63c19B26Cf86] = true;
        ambassadors_[0xFb214AA761CcC1Ccc9D2134a33f4aC77c514d59c] = true;
        ambassadors_[0x567e3616dE1b217d6004cbE9a84095Ce90E94Bfd] = true;
        ambassadors_[0x3f054BF8C392F4F28a9B29f911503c6BC58ED4Da] = true;
        ambassadors_[0x71F658079CaEEDf2270F37c6235D0Ac6B25c9849] = true;
        ambassadors_[0x0581d2d23A300327678E4497d84d58FF64B9CfDe] = true;
        ambassadors_[0xFFAE7193dFA6eBff817C47cd2e5Ce4497c082613] = true;

        ambassadors_[0x18B0f4F11Cb1F2170a6AC594b2Cb0107e2B44821] = true;//zl
        ambassadors_[0x081c65ff7328ac4cC173D3dA7fD02371760B0cF4] = true;//yp
        ambassadors_[0xfa698b3242A3a48AadbC64F50dc96e1DE630F39A] = true;//lxy
        ambassadors_[0xAA5BA7930A1B2c14CDad11bECA86bf43779C05c5] = true;//m
        ambassadors_[0xa7bF8FF736532f6725c5433190E0852DD1592213] = true;//zsj


    }

    /**
     * Converts all incoming ethereum to tokens for the caller, and passes down the referral addy (if any)
     */
    function buy()
        public
        payable
        returns(uint256)
    {
        purchaseTokens(msg.value);
    }

    /**
     * Fallback function to handle ethereum that was send straight to the contract
     * Unfortunately we cannot use a referral address this way.
     */
    function()
        payable
        public
    {
        purchaseTokens(msg.value);
    }

    /**
     * Converts all of caller's dividends to tokens.
     */
    function reinvest()
        isActivated()
        onlyHuman()
        checkRoundStatus()
        public
    {
        address _customerAddress = msg.sender;
        uint256 incomeTmp = income_[_customerAddress];
        //clear income of this user
        income_[_customerAddress] = 0;
        uint256 _tokens = purchaseTokens(incomeTmp);
        // fire event
        emit onReinvestment(_customerAddress, incomeTmp, _tokens);
    }

    /**
     * Alias of sell(), acquireDividends() and withdraw().
     */
    function exit()
        isActivated()
        onlyHuman()
        checkRoundStatus()
        public
    {
        // get token count for caller & sell them all
        address _customerAddress = msg.sender;
        uint256 _tokens = tokenBalanceLedger_[_customerAddress];
        if(_tokens > 0) sell(_tokens);
        acquireDividends();
        // lambo delivery service
        withdraw();
    }

    /**
     * Withdraws all of the caller's dividends in previous round.
     */
    function acquireDividends()
        isActivated()
        onlyHuman()
        checkRoundStatus()
        public
    {
        // setup data
        address _customerAddress = msg.sender;
        Round storage round = rounds_[currentRoundID_.sub(1)];
        uint256 _dividends = myDividends(round.roundID); // get ref. bonus later in the code

        // update dividend tracker
        round.payoutsTo[_customerAddress] = round.payoutsTo[_customerAddress].add(_dividends);
        round.totalPayouts = round.totalPayouts.add(_dividends);

        // Add dividends to income.
        income_[_customerAddress] = income_[_customerAddress].add(_dividends);

        // fire event
        emit onAcquireDividends(_customerAddress, _dividends);
    }

    /**
     * Withdraws all of the caller's income.
     */
    function withdraw()
        isActivated()
        onlyHuman()
        checkRoundStatus()
        public
    {
        address _customerAddress = msg.sender;
        uint256 myIncome = income_[_customerAddress];
        //clear value
        income_[_customerAddress]=0;
        _customerAddress.transfer(myIncome);
        // fire event
        emit onWithdraw(_customerAddress, myIncome);
    }

    /**
     * Tax dividends to community.
    */
    function taxDividends(uint256 _dividends)
      internal
      returns (uint256)
    {
      // Taxed dividends
      uint256 _comm = _dividends.div(communityFee_);
      uint256 _taxedDividends = _dividends.sub(_comm);
      // Community fees
      uint256 _comm_1 = _comm.mul(3).div(10);
      comm1Balance_ = comm1Balance_.add(_comm_1);
      comm2Balance_ = comm2Balance_.add(_comm.sub(_comm_1));
      return _taxedDividends;
    }

    /**
     * Liquifies tokens to ethereum.
     */
    function sell(uint256 _amountOfTokens)
        isActivated()
        onlyHuman()
        onlyBagholders()
        checkRoundStatus()
        public
    {
        require(_amountOfTokens > 0, "Selling 0 token!");

        Round storage round = rounds_[currentRoundID_];
        // setup data
        address _customerAddress = msg.sender;
        // russian hackers BTFO
        require(_amountOfTokens <= tokenBalanceLedger_[_customerAddress]);
        uint256 _tokens = _amountOfTokens;
        uint256 _ethereum = tokensToEthereum_(_tokens);
        uint256 _dividends = SafeMath.div(_ethereum, dividendFee_);
        uint256 _taxedEthereum = SafeMath.sub(_ethereum, _dividends);

        // Record income
        income_[_customerAddress] = income_[_customerAddress].add(_taxedEthereum);

        // Taxed dividends
        uint256 _taxedDividends = taxDividends(_dividends);
        round.dividends = round.dividends.add(_taxedDividends);

        // burn the sold tokens
        tokenSupply_ = tokenSupply_.sub(_tokens);
        tokenBalanceLedger_[_customerAddress] = tokenBalanceLedger_[_customerAddress].sub(_tokens);

        // Calculate net buy of current round
        int256 _userNetBuyBeforeSale = round.userNetBuy[_customerAddress];
        round.userNetBuy[_customerAddress] = _userNetBuyBeforeSale.sub(_tokens.toInt256Safe());
        if( _userNetBuyBeforeSale > 0)
        {
          if(_userNetBuyBeforeSale.toUint256Safe() > _tokens)
          {
            round.netBuySum = round.netBuySum.sub(_tokens);
          }
          else
          {
            round.netBuySum = round.netBuySum.sub(_userNetBuyBeforeSale.toUint256Safe());
          }
        }

        // fire event
        emit onTokenSell(_customerAddress, _tokens, _taxedEthereum);
    }


    /**
     * Transfer tokens from the caller to a new holder.
     * Remember, there's a 10% fee here as well.
     */
    function transfer(address _toAddress, uint256 _amountOfTokens)
        isActivated()
        onlyHuman()
        checkRoundStatus()
        onlyBagholders()
        public
        returns(bool)
    {
        // setup
        address _customerAddress = msg.sender;

        // make sure we have the requested tokens
        // also disables transfers until ambassador phase is over
        // ( we dont want whale premines )
        require(!onlyAmbassadors && _amountOfTokens <= tokenBalanceLedger_[_customerAddress]);

        // liquify 10% of the tokens that are transfered
        // these are dispersed to shareholders
        uint256 _tokenFee = _amountOfTokens.div(dividendFee_);
        uint256 _taxedTokens = _amountOfTokens.sub(_tokenFee);
        uint256 _dividends = tokensToEthereum_(_tokenFee);


        // Taxed dividends
        uint256 _taxedDividends = taxDividends(_dividends);
        rounds_[currentRoundID_].dividends = rounds_[currentRoundID_].dividends.add(_taxedDividends);

        // burn the fee tokens
        tokenSupply_ = tokenSupply_.sub(_tokenFee);

        // exchange tokens
        tokenBalanceLedger_[_customerAddress] = tokenBalanceLedger_[_customerAddress].sub(_amountOfTokens);
        tokenBalanceLedger_[_toAddress] = tokenBalanceLedger_[_toAddress].add(_taxedTokens);

        // fire event
        emit Transfer(_customerAddress, _toAddress, _taxedTokens);

        // ERC20
        return true;

    }

    /*----------  ADMINISTRATOR ONLY FUNCTIONS  ----------*/
    /**
     * In case the amassador quota is not met, the administrator can manually disable the ambassador phase.
     */
    function disableInitialStage()
        onlyAdministrator()
        public
    {
        onlyAmbassadors = false;
    }

    /**
     * In case one of us dies, we need to replace ourselves.
     */
    function setAdministrator(bytes32 _identifier, bool _status)
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

    /**
      Start this game.
    */
    function activate()
      onlyAdministrator()
      public
    {
      // can only be ran once
      require(activated_ == false, "Already activated");

      currentRoundID_ = 1;
      rounds_[currentRoundID_].roundID = currentRoundID_;
      rounds_[currentRoundID_].startTime = now;
      rounds_[currentRoundID_].endTime = now + roundDuration_;

      activated_ = true;
    }

    /**
      Set round ruration, taking effect in the next round.
    */
    // function setRoundDuration(uint _duration)
    //   onlyAdministrator()
    //   public
    // {
    //   roundDuration_ = _duration;
    // }


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
    function myDividends(uint256 _roundID)
        public
        view
        returns(uint256)
    {
        return dividendsOf(msg.sender, _roundID);
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
     * Retrieve the dividend balance of any single address.
     */
    function dividendsOf(address _customerAddress, uint256 _roundID)
        view
        public
        returns(uint256)
    {
      if(_roundID<1) return 0;
      if (_roundID > currentRoundID_) return 0;
      Round storage round = rounds_[_roundID];
      // Sold >= bought
      if(round.userNetBuy[_customerAddress] <= 0)
      {
        return 0;
      }

      // Nobody sold.
      if(round.dividends <= 0)
      {
        return 0;
      }
      return round.profitPerShare.mul(round.userNetBuy[_customerAddress].toUint256Safe()).div(magnitude).sub(round.payoutsTo[_customerAddress]);
    }

    /**
     * Estimate user dividends in current round.
    */
    function estimateDividends(address _customerAddress)
        view
        public
        returns(uint256)
    {
      Round storage round = rounds_[currentRoundID_];
      // Sold >= bought
      if(round.userNetBuy[_customerAddress] <= 0)
      {
        return 0;
      }

      // Nobody sold.
      if(round.dividends <= 0)
      {
        return 0;
      }

      return round.dividends.mul(magnitude).div(round.netBuySum).mul(round.userNetBuy[_customerAddress].toUint256Safe()).div(magnitude);
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
            uint256 _ethereum = tokensToEthereum_(1e18);
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
            uint256 _ethereum = tokensToEthereum_(1e18);
            return _ethereum;
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
        uint256 _amountOfTokens = ethereumToTokens_(_ethereumToSpend);
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

    function roundNetBuySum(uint256 _roundID)
      public view returns(uint256)
    {
        if(_roundID <1 || _roundID > currentRoundID_) return 0;
        return rounds_[_roundID].netBuySum;
    }

    function roundEndTime(uint256 _roundID)
      public view returns(uint256)
    {
      if(_roundID <1 || _roundID > currentRoundID_) return 0;
      return rounds_[_roundID].endTime;
    }
    function roundEnded(uint256 _roundID)
      public view returns(bool)
    {
      if(_roundID <1 || _roundID > currentRoundID_) return true;
      return rounds_[_roundID].ended;
    }

    function roundStartTime(uint256 _roundID)
      public view returns(uint256)
    {
      if(_roundID <1 || _roundID > currentRoundID_) return 0;
      return rounds_[_roundID].startTime;
    }

    function roundProfitPerShare(uint256 _roundID)
      public view returns(uint256)
    {
      if(_roundID <1 || _roundID > currentRoundID_) return 0;
      return rounds_[_roundID].profitPerShare;
    }
    function roundDividends(uint256 _roundID)
      public view returns(uint256)
    {
      if(_roundID <1 || _roundID > currentRoundID_) return 0;
      return rounds_[_roundID].dividends;
    }

    function roundUserNetBuy(uint256 _roundID, address addr)
      public view returns(int256)
    {
      if(_roundID <1 || _roundID > currentRoundID_) return 0;
      return rounds_[_roundID].userNetBuy[addr];
    }

    function roundPayoutsTo(uint256 _roundID, address addr)
      public view returns(uint256)
    {
      if(_roundID <1 || _roundID > currentRoundID_) return 0;
      return rounds_[_roundID].payoutsTo[addr];
    }
    function roundTotalPayouts(uint256 _roundID)
      public view returns(uint256)
    {
      if(_roundID <1 || _roundID > currentRoundID_) return 0;
      return rounds_[_roundID].totalPayouts;
    }

    /*==========================================
    =            INTERNAL FUNCTIONS            =
    ==========================================*/
    function purchaseTokens(uint256 _incomingEthereum)
        isActivated()
        antiEarlyWhale(_incomingEthereum)
        onlyHuman()
        checkRoundStatus()
        internal
        returns(uint256)
    {
        require(_incomingEthereum > 0, "0 eth buying.");
        Round storage round = rounds_[currentRoundID_];
        // data setup
        address _customerAddress = msg.sender;
        uint256 _amountOfTokens = ethereumToTokens_(_incomingEthereum);

        // no point in continuing execution if OP is a poorfag russian hacker
        // prevents overflow in the case that the pyramid somehow magically starts being used by everyone in the world
        // (or hackers)
        // and yes we know that the safemath function automatically rules out the "greater then" equasion.
        require(_amountOfTokens > 0 && (tokenSupply_.add(_amountOfTokens) > tokenSupply_));

        // we can't give people infinite ethereum
        if(tokenSupply_ > 0){
            // add tokens to the pool
            tokenSupply_ = tokenSupply_.add(_amountOfTokens);
        } else {
            // add tokens to the pool
            tokenSupply_ = _amountOfTokens;
        }

        int256 _userNetBuy = round.userNetBuy[_customerAddress];
        int256 _userNetBuyAfterPurchase = _userNetBuy.add(_amountOfTokens.toInt256Safe());
        round.userNetBuy[_customerAddress] = _userNetBuyAfterPurchase;
        if(_userNetBuy >= 0)
        {
          round.netBuySum = round.netBuySum.add(_amountOfTokens);
        }
        else
        {
          if( _userNetBuyAfterPurchase > 0)
          {
            round.netBuySum = round.netBuySum.add(_userNetBuyAfterPurchase.toUint256Safe());
          }
        }

        // update circulating supply & the ledger address for the customer
        tokenBalanceLedger_[_customerAddress] = tokenBalanceLedger_[_customerAddress].add(_amountOfTokens);

        // fire event
        emit onTokenPurchase(_customerAddress, _incomingEthereum, _amountOfTokens);

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
     * It's an algorithm, hopefully we gave you the whitepaper with it in scientific notation;
     * Some conversions occurred to prevent decimal errors or underflows / overflows in solidity code.
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

    /*==========================================
    =           COMMUNITY FUNCTIONS            =
    ==========================================*/
    function withdrawComm1()
      isActivated()
      onlyComm1()
      onlyHuman()
      checkRoundStatus()
      public
    {
      uint256 bal = comm1Balance_;
      comm1Balance_ = 0;
      msg.sender.transfer(bal);
      emit onWithDrawComm(1, bal);
    }

    function withdrawComm2()
      isActivated()
      onlyComm2()
      onlyHuman()
      checkRoundStatus()
      public
    {
      uint256 bal = comm2Balance_;
      comm2Balance_ = 0;
      msg.sender.transfer(bal);
      emit onWithDrawComm(2, bal);
    }

    function transferExpiredDividends(uint256 _roundID)
      isActivated()
      onlyHuman()
      checkRoundStatus()
      public
    {
      require(_roundID > 0 && _roundID < currentRoundID_.sub(1), "Invalid round number");
      Round storage round = rounds_[_roundID];
      uint256 _unpaid = round.dividends.sub(round.totalPayouts);
      require(_unpaid>0, "No expired dividends.");
      uint256 comm1 = _unpaid.mul(3).div(10);
      comm1Balance_ = comm1Balance_.add(comm1);
      comm2Balance_ = comm2Balance_.add(_unpaid.sub(comm1));
      round.totalPayouts = round.totalPayouts.add(_unpaid);
      emit onTransferExpiredDividends(msg.sender, _roundID, _unpaid);
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

// From https://github.com/RequestNetwork/requestNetwork/blob/master/packages/requestNetworkSmartContracts/contracts/base/math/SafeMath.sol
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;

    assert(a == 0 || c / a == b);
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

  function toInt256Safe(uint256 a) internal pure returns (int256) {
    int256 b = int256(a);
    assert(b >= 0);
    return b;
  }
}

// From: https://github.com/RequestNetwork/requestNetwork/blob/master/packages/requestNetworkSmartContracts/contracts/base/math/SafeMathInt.sol
/**
 * @title SafeMathInt
 * @dev Math operations with safety checks that throw on error
 * @dev SafeMath adapted for int256
 */
library SafeMathInt {
  function mul(int256 a, int256 b) internal pure returns (int256) {
    // Prevent overflow when multiplying INT256_MIN with -1
    // https://github.com/RequestNetwork/requestNetwork/issues/43
    assert(!(a == - 2**255 && b == -1) && !(b == - 2**255 && a == -1));

    int256 c = a * b;
    assert((b == 0) || (c / b == a));
    return c;
  }

  function div(int256 a, int256 b) internal pure returns (int256) {
    // Prevent overflow when dividing INT256_MIN by -1
    // https://github.com/RequestNetwork/requestNetwork/issues/43
    assert(!(a == - 2**255 && b == -1));

    // assert(b > 0); // Solidity automatically throws when dividing by 0
    int256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(int256 a, int256 b) internal pure returns (int256) {
    assert((b >= 0 && a - b <= a) || (b < 0 && a - b > a));

    return a - b;
  }

  function add(int256 a, int256 b) internal pure returns (int256) {
    int256 c = a + b;
    assert((b >= 0 && c >= a) || (b < 0 && c < a));
    return c;
  }

  function toUint256Safe(int256 a) internal pure returns (uint256) {
    assert(a>=0);
    return uint256(a);
  }
}