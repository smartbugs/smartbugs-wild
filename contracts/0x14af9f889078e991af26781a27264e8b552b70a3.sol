pragma solidity ^0.4.18;

// Project: Crypt2Pos
// v5, 2018-02-15
// Copying in whole or in part is prohibited.

// (A1)
// The main contract for the sale and management of rounds.
contract CrowdsaleL{

	// For Round0, firstMint is:
	// 0000000000000000000000000000000000000000000000000000000000000000
    
    using SafeMath for uint256;

    enum TokenSaleType {round1, round2}
    enum Roles {beneficiary, accountant, manager, observer, bounty, team, company}
    
    // Extra fee
    address constant TaxCollector = 0x0;
	// fee for round 1 & 2
    uint256[2] TaxValues = [0 finney, 0 finney];
    uint8 vaultNum;

    TokenL public token;

    bool public isFinalized;
    bool public isInitialized;
    bool public isPausedCrowdsale;


    // Initially, all next 7 roles/wallets are given to the Manager. The Manager is an employee of the company
    // with knowledge of IT, who publishes the contract and sets it up. However, money and tokens require
    // a Beneficiary and other roles (Accountant, Team, etc.). The Manager will not have the right
    // to receive them. To enable this, the Manager must either enter specific wallets here, or perform
    // this via method changeWallet. In the finalization methods it is written which wallet and
    // what percentage of tokens are received.
    address[7] public wallets = [
        
        // beneficiary
        // Receives all the money (when finalizing Round1 & Round2)
        0x9a1Fc7173086412A10dE27A9d1d543af3AB68262,
        
        // accountant
        // Receives all the tokens for non-ETH investors (when finalizing Round1 & Round2)
        0x9a1Fc7173086412A10dE27A9d1d543af3AB68262,
        
        // manager
        // All rights except the rights to receive tokens or money. Has the right to change any other
        // wallets (Beneficiary, Accountant, ...), but only if the round has not started. Once the
        // round is initialized, the Manager has lost all rights to change the wallets.
        // If the TokenSale is conducted by one person, then nothing needs to be changed. Permit all 7 roles
        // point to a single wallet.
        msg.sender,
        
        // observer
        // Has only the right to call paymentsInOtherCurrency (please read the document)
        0x8a91aC199440Da0B45B2E278f3fE616b1bCcC494,

        // bounty
        0x9a1Fc7173086412A10dE27A9d1d543af3AB68262,

        // team
        // When the round is finalized, all team tokens are transferred to a special freezing
        // contract. As soon as defrosting is over, only the Team wallet will be able to
        // collect all the tokens. It does not store the address of the freezing contract,
        // but the final wallet of the project team.
        0x9a1Fc7173086412A10dE27A9d1d543af3AB68262,
        
        // company
        0x9a1Fc7173086412A10dE27A9d1d543af3AB68262
        ];

    struct Profit{
	    uint256 min;    // percent from 0 to 50
	    uint256 max;    // percent from 0 to 50
	    uint256 step;   // percent step, from 1 to 50 (please, read doc!)
	    uint256 maxAllProfit; 
    }
    struct Bonus {
	    uint256 value;
	    uint256 procent;
	    uint256 freezeTime;
    }

    Bonus[] public bonuses;

    Profit public profit = Profit(0, 20, 4, 50);
    
    uint256 public startTime= 1518912000; // 18 Feb
    uint256 public endDiscountTime = 1521936000; // 25 Mar
    uint256 public endTime = 1522800000; // 4 Apr

    // How many tokens (excluding the bonus) are transferred to the investor in exchange for 1 ETH
    // **THOUSANDS** 10^3 for human, *10**3 for Solidity, 1e3 for MyEtherWallet (MEW).
    // Example: if 1ETH = 40.5 Token ==> use 40500
    uint256 public rate = 18000000;

    // If the round does not attain this value before the closing date, the round is recognized as a
    // failure and investors take the money back (the founders will not interfere in any way).
    // **QUINTILLIONS** 10^18 / *10**18 / 1e18. Example: softcap=15ETH ==> use 15*10**18 (Solidity) or 15e18 (MEW)
    uint256 public softCap = 0 ether;

    // The maximum possible amount of income
    // **QUINTILLIONS** 10^18 / *10**18 / 1e18. Example: hardcap=123.45ETH ==> use 123450*10**15 (Solidity) or 12345e15 (MEW)
    uint256 public hardCap = 19444 ether;

    // If the last payment is slightly higher than the hardcap, then the usual contracts do
    // not accept it, because it goes beyond the hardcap. However it is more reasonable to accept the
    // last payment, very slightly raising the hardcap. The value indicates by how many ETH the
    // last payment can exceed the hardcap to allow it to be paid. Immediately after this payment, the
    // round closes. The funders should write here a small number, not more than 1% of the CAP.
    // Can be equal to zero, to cancel.
    // **QUINTILLIONS** 10^18 / *10**18 / 1e18
    uint256 public overLimit = 20 ether;

    // The minimum possible payment from an investor in ETH. Payments below this value will be rejected.
    // **QUINTILLIONS** 10^18 / *10**18 / 1e18. Example: minPay=0.1ETH ==> use 100*10**15 (Solidity) or 100e15 (MEW)
    uint256 public minPay = 10 finney;

    uint256 public ethWeiRaised;
    uint256 public nonEthWeiRaised;
    uint256 public weiRound1;
    uint256 public tokenReserved;

    RefundVault public vault;
    //SVTAllocation public lockedAllocation;

    TokenSaleType TokenSale = TokenSaleType.round2;

    uint256 public allToken;

    bool public bounty;
    bool public team;
    bool public company;
    //bool public partners;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    event Finalized();
    event Initialized();

    function CrowdsaleL(TokenL _token, uint256 firstMint) public
    {

        token = _token;
        token.setOwner();

        token.pause(); // block exchange tokens

        token.addUnpausedWallet(wallets[uint8(Roles.accountant)]);
        token.addUnpausedWallet(msg.sender);
        //token.addUnpausedWallet(wallets[uint8(Roles.bounty)]);
        //token.addUnpausedWallet(wallets[uint8(Roles.company)]);
        
        token.setFreezingManager(wallets[uint8(Roles.accountant)]);
        
        bonuses.push(Bonus(11111 finney,30,60 days));
        bonuses.push(Bonus(55556 finney,40,90 days));
        bonuses.push(Bonus(111111 finney,50,180 days));

        if (firstMint > 0) {
            token.mint(msg.sender, firstMint);
        }

    }

    // Returns the name of the current round in plain text. Constant.
    function getTokenSaleType()  public constant returns(string){
        return (TokenSale == TokenSaleType.round1)?'round1':'round2';
    }

    // Transfers the funds of the investor to the contract of return of funds. Internal.
    function forwardFunds() internal {
        vault.deposit.value(msg.value)(msg.sender);
    }

    // Check for the possibility of buying tokens. Inside. Constant.
    function validPurchase() internal constant returns (bool) {

        // The round started and did not end
        bool withinPeriod = (now > startTime && now < endTime);

        // Rate is greater than or equal to the minimum
        bool nonZeroPurchase = msg.value >= minPay;

        // hardCap is not reached, and in the event of a transaction, it will not be exceeded by more than OverLimit
        bool withinCap = msg.value <= hardCap.sub(weiRaised()).add(overLimit);

        // round is initialized and no "Pause of trading" is set
        return withinPeriod && nonZeroPurchase && withinCap && isInitialized && !isPausedCrowdsale;
    }

    // Check for the ability to finalize the round. Constant.
    function hasEnded() public constant returns (bool) {

        bool timeReached = now > endTime;

        bool capReached = weiRaised() >= hardCap;

        return (timeReached || capReached) && isInitialized;
    }
    
    function finalizeAll() external {
        finalize();
        finalize1();
        finalize2();
        finalize3();
    }

    // Finalize. Only available to the Manager and the Beneficiary. If the round failed, then
    // anyone can call the finalization to unlock the return of funds to investors
    // You must call a function to finalize each round (after the Round1 & after the Round2)
    function finalize() public {

        require(wallets[uint8(Roles.manager)] == msg.sender || wallets[uint8(Roles.beneficiary)] == msg.sender || !goalReached());
        require(!isFinalized);
        require(hasEnded());

        isFinalized = true;
        finalization();
        Finalized();
    }

    // The logic of finalization. Internal
    function finalization() internal {

        // If the goal of the achievement
        if (goalReached()) {

            // Send ether to Beneficiary
            vault.close(wallets[uint8(Roles.beneficiary)]);

            // if there is anything to give
            if (tokenReserved > 0) {

                // Issue tokens of non-eth investors to Accountant account
                token.mint(wallets[uint8(Roles.accountant)],tokenReserved);

                // Reset the counter
                tokenReserved = 0;
            }

            // If the finalization is Round 1
            if (TokenSale == TokenSaleType.round1) {

                // Reset settings
                isInitialized = false;
                isFinalized = false;

                // Switch to the second round (to Round2)
                TokenSale = TokenSaleType.round2;

                // Reset the collection counter
                weiRound1 = weiRaised();
                ethWeiRaised = 0;
                nonEthWeiRaised = 0;


            }
            else // If the second round is finalized
            {

                // Record how many tokens we have issued
                allToken = token.totalSupply();

                // Permission to collect tokens to those who can pick them up
                bounty = true;
                team = true;
                company = true;
                //partners = true;

            }

        }
        else // If they failed round
        {
            // Allow investors to withdraw their funds
            vault.enableRefunds();
        }
    }

    // The Manager (no-freezes) the tokens for the Team.
    // You must call a function to finalize Round 2 (only after the Round2)
    function finalize1() public {
        require(wallets[uint8(Roles.manager)] == msg.sender || wallets[uint8(Roles.beneficiary)] == msg.sender);
        require(team);
        team = false;
        // 14% - tokens to Team wallet after freeze (80% for investors)
        // *** CHECK THESE NUMBERS ***
//        lockedAllocation = new SVTAllocation(token, wallets[uint8(Roles.team)]);
//        token.addUnpausedWallet(lockedAllocation);
//        token.mint(lockedAllocation,allToken.mul(14).div(80));

		// no freeze
        token.mint(wallets[uint8(Roles.team)],allToken.mul(14).div(80));
    }

    // For bounty
    // You must call a function to finalize Round 2 (only after the Round2)
    function finalize2() public {
        require(wallets[uint8(Roles.manager)] == msg.sender || wallets[uint8(Roles.beneficiary)] == msg.sender);
        require(bounty);
        bounty = false;
        // 3% - tokens to bounty wallet after freeze (80% for investors)
        // *** CHECK THESE NUMBERS ***
        token.mint(wallets[uint8(Roles.bounty)],allToken.mul(3).div(80));
    }

    // For marketing, referral, reserve 
    // You must call a function to finalize Round 2 (only after the Round2)
    function finalize3() public {
        require(wallets[uint8(Roles.manager)] == msg.sender || wallets[uint8(Roles.beneficiary)] == msg.sender);
        require(company);
        company = false;
        // 3% - tokens to company wallet after freeze (80% for investors)
        // *** CHECK THESE NUMBERS ***
        token.mint(wallets[uint8(Roles.company)],allToken.mul(3).div(80));
    }


    // Initializing the round. Available to the manager. After calling the function,
    // the Manager loses all rights: Manager can not change the settings (setup), change
    // wallets, prevent the beginning of the round, etc. You must call a function after setup
    // for the initial round (before the Round1 and before the Round2)
    function initialize() public {

        // Only the Manager
        require(wallets[uint8(Roles.manager)] == msg.sender);

        // If not yet initialized
        require(!isInitialized);

        // And the specified start time has not yet come
        // If initialization return an error, check the start date!
        require(now <= startTime);

        initialization();

        Initialized();

        isInitialized = true;
    }

    function initialization() internal {
        uint256 taxValue = TaxValues[vaultNum];
        vaultNum++;
        uint256 arrear;
        if (address(vault) != 0x0){
            arrear = DistributorRefundVault(vault).taxValue();
            vault.del(wallets[uint8(Roles.beneficiary)]);
        }
        vault = new DistributorRefundVault(TaxCollector, taxValue.add(arrear));
    }

    // At the request of the investor, we raise the funds (if the round has failed because of the hardcap)
    function claimRefund() public{
        vault.refund(msg.sender);
    }

    // We check whether we collected the necessary minimum funds. Constant.
    function goalReached() public constant returns (bool) {
        return weiRaised() >= softCap;
    }

    // Customize. The arguments are described in the constructor above.
    function setup(uint256 _startTime, uint256 _endDiscountTime, uint256 _endTime, uint256 _softCap, uint256 _hardCap, uint256 _rate, uint256 _overLimit, uint256 _minPay, uint256 _minProfit, uint256 _maxProfit, uint256 _stepProfit, uint256 _maxAllProfit, uint256[] _value, uint256[] _procent, uint256[] _freezeTime) public{
        changePeriod(_startTime, _endDiscountTime, _endTime);
        changeTargets(_softCap, _hardCap);
        changeRate(_rate, _overLimit, _minPay);
        changeDiscount(_minProfit, _maxProfit, _stepProfit, _maxAllProfit);
        setBonuses(_value, _procent, _freezeTime);
    }

    // Change the date and time: the beginning of the round, the end of the bonus, the end of the round. Available to Manager
    // Description in the Crowdsale constructor
    function changePeriod(uint256 _startTime, uint256 _endDiscountTime, uint256 _endTime) public{

        require(wallets[uint8(Roles.manager)] == msg.sender);

        require(!isInitialized);

        // Date and time are correct
        require(now <= _startTime);
        require(_endDiscountTime > _startTime && _endDiscountTime <= _endTime);

        startTime = _startTime;
        endTime = _endTime;
        endDiscountTime = _endDiscountTime;

    }

    // We change the purpose of raising funds. Available to the manager.
    // Description in the Crowdsale constructor.
    function changeTargets(uint256 _softCap, uint256 _hardCap) public {

        require(wallets[uint8(Roles.manager)] == msg.sender);

        require(!isInitialized);

        // The parameters are correct
        require(_softCap <= _hardCap);

        softCap = _softCap;
        hardCap = _hardCap;
    }

    // Change the price (the number of tokens per 1 eth), the maximum hardCap for the last bet,
    // the minimum bet. Available to the Manager.
    // Description in the Crowdsale constructor
    function changeRate(uint256 _rate, uint256 _overLimit, uint256 _minPay) public {

        require(wallets[uint8(Roles.manager)] == msg.sender);

        require(!isInitialized);

        require(_rate > 0);

        rate = _rate;
        overLimit = _overLimit;
        minPay = _minPay;
    }

    // We change the parameters of the discount:% min bonus,% max bonus, number of steps.
    // Available to the manager. Description in the Crowdsale constructor
    function changeDiscount(uint256 _minProfit, uint256 _maxProfit, uint256 _stepProfit, uint256 _maxAllProfit) public {

        require(wallets[uint8(Roles.manager)] == msg.sender);

        require(!isInitialized);
        
        require(_maxProfit <= _maxAllProfit);

        // The parameters are correct
        require(_stepProfit <= _maxProfit.sub(_minProfit));

        // If not zero steps
        if(_stepProfit > 0){
            // We will specify the maximum percentage at which it is possible to provide
            // the specified number of steps without fractional parts
            profit.max = _maxProfit.sub(_minProfit).div(_stepProfit).mul(_stepProfit).add(_minProfit);
        }else{
            // to avoid a divide to zero error, set the bonus as static
            profit.max = _minProfit;
        }

        profit.min = _minProfit;
        profit.step = _stepProfit;
        profit.maxAllProfit = _maxAllProfit;
    }

    function setBonuses(uint256[] _value, uint256[] _procent, uint256[] _dateUnfreeze) public {

        require(wallets[uint8(Roles.manager)] == msg.sender);
        require(!isInitialized);

        require(_value.length == _procent.length && _value.length == _dateUnfreeze.length);
        bonuses.length = _value.length;
        for(uint256 i = 0; i < _value.length; i++){
            bonuses[i] = Bonus(_value[i],_procent[i],_dateUnfreeze[i]);
        }
    }

    // Collected funds for the current round. Constant.
    function weiRaised() public constant returns(uint256){
        return ethWeiRaised.add(nonEthWeiRaised);
    }

    // Returns the amount of fees for both phases. Constant.
    function weiTotalRaised() public constant returns(uint256){
        return weiRound1.add(weiRaised());
    }

    // Returns the percentage of the bonus on the current date. Constant.
    function getProfitPercent() public constant returns (uint256){
        return getProfitPercentForData(now);
    }

    // Returns the percentage of the bonus on the given date. Constant.
    function getProfitPercentForData(uint256 timeNow) public constant returns (uint256){
        // if the discount is 0 or zero steps, or the round does not start, we return the minimum discount
        if (profit.max == 0 || profit.step == 0 || timeNow > endDiscountTime){
            return profit.min;
        }

        // if the round is over - the maximum
        if (timeNow<=startTime){
            return profit.max;
        }

        // bonus period
        uint256 range = endDiscountTime.sub(startTime);

        // delta bonus percentage
        uint256 profitRange = profit.max.sub(profit.min);

        // Time left
        uint256 timeRest = endDiscountTime.sub(timeNow);

        // Divide the delta of time into
        uint256 profitProcent = profitRange.div(profit.step).mul(timeRest.mul(profit.step.add(1)).div(range));
        return profitProcent.add(profit.min);
    }

    function getBonuses(uint256 _value) public constant returns(uint256 procent, uint256 _dateUnfreeze){
        if(bonuses.length == 0 || bonuses[0].value > _value){
            return (0,0);
        }
        uint16 i = 1;
        for(i; i < bonuses.length; i++){
            if(bonuses[i].value > _value){
                break;
            }
        }
        return (bonuses[i-1].procent,bonuses[i-1].freezeTime);
    }

    // The ability to quickly check Round1 (only for Round1, only 1 time). Completes the Round1 by
    // transferring the specified number of tokens to the Accountant's wallet. Available to the Manager.
    // Use only if this is provided by the script and white paper. In the normal scenario, it
    // does not call and the funds are raised normally. We recommend that you delete this
    // function entirely, so as not to confuse the auditors. Initialize & Finalize not needed.
    // ** QUINTILIONS **  10^18 / 1**18 / 1e18
    function fastTokenSale(uint256 _totalSupply) public {
        require(wallets[uint8(Roles.manager)] == msg.sender);
        require(TokenSale == TokenSaleType.round1 && !isInitialized);
        token.mint(wallets[uint8(Roles.accountant)], _totalSupply);
        TokenSale = TokenSaleType.round2;
    }

    // Remove the "Pause of exchange". Available to the manager at any time. If the
    // manager refuses to remove the pause, then 30-120 days after the successful
    // completion of the TokenSale, anyone can remove a pause and allow the exchange to continue.
    // The manager does not interfere and will not be able to delay the term.
    // He can only cancel the pause before the appointed time.
    function tokenUnpause() public {
        require(wallets[uint8(Roles.manager)] == msg.sender
            || (now > endTime + 30 days && TokenSale == TokenSaleType.round2 && isFinalized && goalReached()));
        token.unpause();
    }

    // Enable the "Pause of exchange". Available to the manager until the TokenSale is completed.
    // The manager cannot turn on the pause, for example, 3 years after the end of the TokenSale.
    function tokenPause() public {
        require(wallets[uint8(Roles.manager)] == msg.sender && !isFinalized);
        token.pause();
    }

    // Pause of sale. Available to the manager.
    function crowdsalePause() public {
        require(wallets[uint8(Roles.manager)] == msg.sender);
        require(isPausedCrowdsale == false);
        isPausedCrowdsale = true;
    }

    // Withdrawal from the pause of sale. Available to the manager.
    function crowdsaleUnpause() public {
        require(wallets[uint8(Roles.manager)] == msg.sender);
        require(isPausedCrowdsale == true);
        isPausedCrowdsale = false;
    }

    // Checking whether the rights to address ignore the "Pause of exchange". If the
    // wallet is included in this list, it can translate tokens, ignoring the pause. By default,
    // only the following wallets are included:
    //    - Accountant wallet (he should immediately transfer tokens, but not to non-ETH investors)
    //    - Contract for freezing the tokens for the Team (but Team wallet not included)
    // Inside. Constant.
    function unpausedWallet(address _wallet) internal constant returns(bool) {
        bool _accountant = wallets[uint8(Roles.accountant)] == _wallet;
        bool _manager = wallets[uint8(Roles.manager)] == _wallet;
        bool _bounty = wallets[uint8(Roles.bounty)] == _wallet;
        bool _company = wallets[uint8(Roles.company)] == _wallet;
        return _accountant || _manager || _bounty || _company;
    }

    // For example - After 5 years of the project's existence, all of us suddenly decided collectively
    // (company + investors) that it would be more profitable for everyone to switch to another smart
    // contract responsible for tokens. The company then prepares a new token, investors
    // disassemble, study, discuss, etc. After a general agreement, the manager allows any investor:
    //      - to burn the tokens of the previous contract
    //      - generate new tokens for a new contract
    // It is understood that after a general solution through this function all investors
    // will collectively (and voluntarily) move to a new token.
    function moveTokens(address _migrationAgent) public {
        require(wallets[uint8(Roles.manager)] == msg.sender);
        token.setMigrationAgent(_migrationAgent);
    }

    function migrateAll(address[] _holders) public {
        require(wallets[uint8(Roles.manager)] == msg.sender);
        token.migrateAll(_holders);
    }

    // Change the address for the specified role.
    // Available to any wallet owner except the observer.
    // Available to the manager until the round is initialized.
    // The Observer's wallet or his own manager can change at any time.
    function changeWallet(Roles _role, address _wallet) public
    {
        require(
        (msg.sender == wallets[uint8(_role)] && _role != Roles.observer)
        ||
        (msg.sender == wallets[uint8(Roles.manager)] && (!isInitialized || _role == Roles.observer))
        );
        address oldWallet = wallets[uint8(_role)];
        wallets[uint8(_role)] = _wallet;
        if(token.unpausedWallet(oldWallet))
            token.delUnpausedWallet(oldWallet);
        if(unpausedWallet(_wallet))
            token.addUnpausedWallet(_wallet);
        
        if(_role == Roles.accountant)
            token.setFreezingManager(wallets[uint8(Roles.accountant)]);
    }
    
    
    // The beneficiary at any time can take rights in all roles and prescribe his wallet in all the 
    // rollers. Thus, he will become the recipient of tokens for the role of Accountant, 
    // Team, etc. Works at any time.
    function resetAllWallets() public{
        address _beneficiary = wallets[uint8(Roles.beneficiary)];
        require(msg.sender == _beneficiary);
        for(uint8 i = 0; i < wallets.length; i++){
            if(token.unpausedWallet(wallets[i]))
                token.delUnpausedWallet(wallets[i]);
            wallets[i] = _beneficiary;
        }
        token.addUnpausedWallet(_beneficiary);
    }
    

    // If a little more than a year has elapsed (Round2 start date + 400 days), a smart contract
    // will allow you to send all the money to the Beneficiary, if any money is present. This is
    // possible if you mistakenly launch the Round2 for 30 years (not 30 days), investors will transfer
    // money there and you will not be able to pick them up within a reasonable time. It is also
    // possible that in our checked script someone will make unforeseen mistakes, spoiling the
    // finalization. Without finalization, money cannot be returned. This is a rescue option to
    // get around this problem, but available only after a year (400 days).

    // Another reason - the TokenSale was a failure, but not all ETH investors took their money during the year after.
    // Some investors may have lost a wallet key, for example.

    // The method works equally with the Round1 and Round2. When the Round1 starts, the time for unlocking
    // the distructVault begins. If the TokenSale is then started, then the term starts anew from the first day of the TokenSale.

    // Next, act independently, in accordance with obligations to investors.

    // Within 400 days of the start of the Round, if it fails only investors can take money. After
    // the deadline this can also include the company as well as investors, depending on who is the first to use the method.
    function distructVault() public {
 		if (wallets[uint8(Roles.beneficiary)] == msg.sender && (now > startTime + 400 days)) {
 			vault.del(wallets[uint8(Roles.beneficiary)]);
 		}
 		if (wallets[uint8(Roles.manager)] == msg.sender && (now > startTime + 600 days)) {
 			vault.del(wallets[uint8(Roles.manager)]);
 		}    
    }


    // We accept payments other than Ethereum (ETH) and other currencies, for example, Bitcoin (BTC).
    // Perhaps other types of cryptocurrency - see the original terms in the white paper and on the TokenSale website.

    // We release tokens on Ethereum. During the Round1 and Round2 with a smart contract, you directly transfer
    // the tokens there and immediately, with the same transaction, receive tokens in your wallet.

    // When paying in any other currency, for example in BTC, we accept your money via one common wallet.
    // Our manager fixes the amount received for the bitcoin wallet and calls the method of the smart
    // contract paymentsInOtherCurrency to inform him how much foreign currency has been received - on a daily basis.
    // The smart contract pins the number of accepted ETH directly and the number of BTC. Smart contract
    // monitors softcap and hardcap, so as not to go beyond this framework.

    // In theory, it is possible that when approaching hardcap, we will receive a transfer (one or several
    // transfers) to the wallet of BTC, that together with previously received money will exceed the hardcap in total.
    // In this case, we will refund all the amounts above, in order not to exceed the hardcap.

    // Collection of money in BTC will be carried out via one common wallet. The wallet's address will be published
    // everywhere (in a white paper, on the TokenSale website, on Telegram, on Bitcointalk, in this code, etc.)
    // Anyone interested can check that the administrator of the smart contract writes down exactly the amount
    // in ETH (in equivalent for BTC) there. In theory, the ability to bypass a smart contract to accept money in
    // BTC and not register them in ETH creates a possibility for manipulation by the company. Thanks to
    // paymentsInOtherCurrency however, this threat is leveled.

    // Any user can check the amounts in BTC and the variable of the smart contract that accounts for this
    // (paymentsInOtherCurrency method). Any user can easily check the incoming transactions in a smart contract
    // on a daily basis. Any hypothetical tricks on the part of the company can be exposed and panic during the TokenSale,
    // simply pointing out the incompatibility of paymentsInOtherCurrency (ie, the amount of ETH + BTC collection)
    // and the actual transactions in BTC. The company strictly adheres to the described principles of openness.

    // The company administrator is required to synchronize paymentsInOtherCurrency every working day (but you
    // cannot synchronize if there are no new BTC payments). In the case of unforeseen problems, such as
    // brakes on the Ethereum network, this operation may be difficult. You should only worry if the
    // administrator does not synchronize the amount for more than 96 hours in a row, and the BTC wallet
    // receives significant amounts.

    // This scenario ensures that for the sum of all fees in all currencies this value does not exceed hardcap.

    // BTC - 1Mzf6X9daai49B5UHvCWxUvSMpUPibATKm
    // LTC - LKsbawSDfYuV9sfv7vFVDKMnQSP5CmNgdY

    // ** QUINTILLIONS ** 10^18 / 1**18 / 1e18
    function paymentsInOtherCurrency(uint256 _token, uint256 _value) public {
        require(wallets[uint8(Roles.observer)] == msg.sender || wallets[uint8(Roles.manager)] == msg.sender);
        bool withinPeriod = (now >= startTime && now <= endTime);

        bool withinCap = _value.add(ethWeiRaised) <= hardCap.add(overLimit);
        require(withinPeriod && withinCap && isInitialized);

        nonEthWeiRaised = _value;
        tokenReserved = _token;

    }
    
    function changeLock(address _owner, uint256 _value, uint256 _date) external {
        require(wallets[uint8(Roles.manager)] == msg.sender);
        token.changeLock(_owner, _value, _date);
    }

    function lokedMint(address _beneficiary, uint256 _value, uint256 _freezeTime) internal {
        if(_freezeTime > 0){
            
            uint256 totalBloked = token.valueBlocked(_beneficiary).add(_value);
            uint256 pastDateUnfreeze = token.blikedUntil(_beneficiary);
            uint256 newDateUnfreeze = _freezeTime + now; 
            newDateUnfreeze = (pastDateUnfreeze > newDateUnfreeze ) ? pastDateUnfreeze : newDateUnfreeze;

            token.changeLock(_beneficiary,totalBloked,newDateUnfreeze);
        }
        token.mint(_beneficiary,_value);
    }


    // The function for obtaining smart contract funds in ETH. If all the checks are true, the token is
    // transferred to the buyer, taking into account the current bonus.
    function buyTokens(address beneficiary) public payable {
        require(beneficiary != 0x0);
        require(validPurchase());

        uint256 weiAmount = msg.value;

        uint256 ProfitProcent = getProfitPercent();

        var (bonus, dateUnfreeze) = getBonuses(weiAmount);
        
        // Scenario 1 - select max from all bonuses + check profit.maxAllProfit
        uint256 totalProfit = ProfitProcent;
        totalProfit = (totalProfit < bonus) ? bonus : totalProfit;
        totalProfit = (totalProfit > profit.maxAllProfit) ? profit.maxAllProfit : totalProfit;
        
        // Scenario 2 - sum both bonuses + check profit.maxAllProfit
        //uint256 totalProfit = bonus.add(ProfitProcent);
        //totalProfit = (totalProfit > profit.maxAllProfit)? profit.maxAllProfit: totalProfit;
        
        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate).mul(totalProfit + 100).div(100000);

        // update state
        ethWeiRaised = ethWeiRaised.add(weiAmount);

        lokedMint(beneficiary, tokens, dateUnfreeze);

        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardFunds();
    }

    // buyTokens alias
    function () public payable {
        buyTokens(msg.sender);
    }

}


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
        // assert(a == b * c + a % b); // There is no case in which this does not hold
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

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
        owner = msg.sender;
    }


    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) onlyOwner public{
        require(newOwner != address(0));
        owner = newOwner;
    }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool _paused = false;

    function paused() public constant returns(bool)
    {
        return _paused;
    }


    /**
     * @dev modifier to allow actions only when the contract IS paused
     */
    modifier whenNotPaused() {
        require(!paused());
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() onlyOwner public {
        require(!_paused);
        _paused = true;
        Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() onlyOwner public {
        require(_paused);
        _paused = false;
        Unpause();
    }
}


// Contract interface for transferring current tokens to another
contract MigrationAgent
{
    function migrateFrom(address _from, uint256 _value) public;
}

contract BlockedToken is Ownable {
    using SafeMath for uint256;

    struct locked {uint256 value; uint256 date;}

    mapping (address => locked) locks;

    function blikedUntil(address _owner) external constant returns (uint256) {
        if(now < locks[_owner].date)
        {
            return locks[_owner].date;
        }else{
            return 0;
        }
    }

    function valueBlocked(address _owner) public constant returns (uint256) {
        if(now < locks[_owner].date)
        {
            return locks[_owner].value;
        }else{
            return 0;
        }
    }

    function changeLock(address _owner, uint256 _value, uint256 _date) external onlyOwner {
        locks[_owner] = locked(_value,_date);
    }
}


// (A2)
// Contract token
contract TokenL is Pausable, BlockedToken {
    using SafeMath for uint256;

    string public constant name = "Crypt2Pos";
    string public constant symbol = "CRPOS";
    uint8 public constant decimals = 18;

    uint256 public totalSupply;

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    mapping (address => bool) public unpausedWallet;

    bool public mintingFinished = false;

    uint256 public totalMigrated;
    address public migrationAgent;
    
    address public freezingManager;
    mapping (address => bool) public freezingAgent;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    event Migrate(address indexed _from, address indexed _to, uint256 _value);

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    function TokenL() public{
        owner = 0x0;
    }

    function setOwner() public{
        require(owner == 0x0);
        owner = msg.sender;
    }
    
    function setFreezingManager(address _newAddress) external {
        require(msg.sender == owner || msg.sender == freezingManager);
        freezingAgent[freezingManager] = false;
        freezingManager = _newAddress;
        freezingAgent[freezingManager] = true;
    }
    
    function changeFreezingAgent(address _agent, bool _right) external {
        require(msg.sender == freezingManager);
        freezingAgent[_agent] = _right;
    }
    
    function transferAndFreeze(address _to, uint256 _value, uint256 _when) external {
        require(freezingAgent[msg.sender]);
        if(_when > 0){
            locked storage _locked = locks[_to];
            _locked.value = valueBlocked(_to).add(_value);
            _locked.date = (_locked.date > _when)? _locked.date: _when;
        }
        transfer(_to,_value);
    }

    // Balance of the specified address
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }


    // Transfer of tokens from one account to another
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(!paused()||unpausedWallet[msg.sender]||unpausedWallet[_to]);
        uint256 available = balances[msg.sender].sub(valueBlocked(msg.sender));
        require(_value <= available);
        require (_value > 0);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    // Returns the number of tokens that _owner trusted to spend from his account _spender
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    // Trust _sender and spend _value tokens from your account
    function approve(address _spender, uint256 _value) public returns (bool) {

        // To change the approve amount you first have to reduce the addresses
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    // Transfer of tokens from the trusted address _from to the address _to in the number _value
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(!paused()||unpausedWallet[msg.sender]||unpausedWallet[_to]);
        uint256 available = balances[_from].sub(valueBlocked(_from));
        require(_value <= available);

        var _allowance = allowed[_from][msg.sender];

        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
        // require (_value <= _allowance);

        require (_value > 0);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = _allowance.sub(_value);
        Transfer(_from, _to, _value);
        return true;
    }

    // Issue new tokens to the address _to in the amount _amount. Available to the owner of the contract (contract Crowdsale)
    function mint(address _to, uint256 _amount) public onlyOwner canMint returns (bool) {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Mint(_to, _amount);
        Transfer(0x0, _to, _amount);
        return true;
    }

    // Stop the release of tokens. This is not possible to cancel. Available to the owner of the contract.
    function finishMinting() public onlyOwner returns (bool) {
    	mintingFinished = true;
        MintFinished();
        return true;
    }

    // Redefinition of the method of the returning status of the "Exchange pause".
    // Never for the owner of an unpaused wallet.
    function paused() public constant returns(bool) {
        return super.paused();
    }

    // Add a wallet ignoring the "Exchange pause". Available to the owner of the contract.
    function addUnpausedWallet(address _wallet) public onlyOwner {
        unpausedWallet[_wallet] = true;
    }

    // Remove the wallet ignoring the "Exchange pause". Available to the owner of the contract.
    function delUnpausedWallet(address _wallet) public onlyOwner {
        unpausedWallet[_wallet] = false;
    }

    // Enable the transfer of current tokens to others. Only 1 time. Disabling this is not possible.
    // Available to the owner of the contract.
    function setMigrationAgent(address _migrationAgent) public onlyOwner {
        require(migrationAgent == 0x0);
        migrationAgent = _migrationAgent;
    }

    function migrateAll(address[] _holders) public onlyOwner {
        require(migrationAgent != 0x0);
        uint256 total = 0;
        uint256 value;
        for(uint i = 0; i < _holders.length; i++){
            value = balances[_holders[i]];
            if(value > 0){
                balances[_holders[i]] = 0;
                total = total.add(value);
                MigrationAgent(migrationAgent).migrateFrom(_holders[i], value);
                Migrate(_holders[i],migrationAgent,value);
            }
            totalSupply = totalSupply.sub(total);
            totalMigrated = totalMigrated.add(total);
        }
    }

    function migration(address _holder) internal {
        require(migrationAgent != 0x0);
        uint256 value = balances[_holder];
        require(value > 0);
        balances[_holder] = 0;
        totalSupply = totalSupply.sub(value);
        totalMigrated = totalMigrated.add(value);
        MigrationAgent(migrationAgent).migrateFrom(_holder, value);
        Migrate(_holder,migrationAgent,value);

    }

    // Reissue your tokens.
    function migrate() public
    {
        migration(msg.sender);
    }
}


// (A3)
// Contract for freezing of investors' funds. Hence, investors will be able to withdraw money if the
// round does not attain the softcap. From here the wallet of the beneficiary will receive all the
// money (namely, the beneficiary, not the manager's wallet).
contract RefundVault is Ownable {
    using SafeMath for uint256;

    enum State { Active, Refunding, Closed }

    mapping (address => uint256) public deposited;
    State public state;

    event Closed();
    event RefundsEnabled();
    event Refunded(address indexed beneficiary, uint256 weiAmount);
    event Deposited(address indexed beneficiary, uint256 weiAmount);

    function RefundVault() public {
        state = State.Active;
    }

    // Depositing funds on behalf of an TokenSale investor. Available to the owner of the contract (Crowdsale Contract).
    function deposit(address investor) onlyOwner public payable {
        require(state == State.Active);
        deposited[investor] = deposited[investor].add(msg.value);
        Deposited(investor,msg.value);
    }

    // Move the collected funds to a specified address. Available to the owner of the contract.
    function close(address _wallet) onlyOwner public {
        require(state == State.Active);
        require(_wallet != 0x0);
        state = State.Closed;
        Closed();
        _wallet.transfer(this.balance);
    }

    // Allow refund to investors. Available to the owner of the contract.
    function enableRefunds() onlyOwner public {
        require(state == State.Active);
        state = State.Refunding;
        RefundsEnabled();
    }

    // Return the funds to a specified investor. In case of failure of the round, the investor
    // should call this method of this contract (RefundVault) or call the method claimRefund of Crowdsale
    // contract. This function should be called either by the investor himself, or the company
    // (or anyone) can call this function in the loop to return funds to all investors en masse.
    function refund(address investor) public {
        require(state == State.Refunding);
        require(deposited[investor] > 0);
        uint256 depositedValue = deposited[investor];
        deposited[investor] = 0;
        investor.transfer(depositedValue);
        Refunded(investor, depositedValue);
    }

    // Destruction of the contract with return of funds to the specified address. Available to
    // the owner of the contract.
    function del(address _wallet) external onlyOwner {
        selfdestruct(_wallet);
    }
}

contract DistributorRefundVault is RefundVault{
 
    address public taxCollector;
    uint256 public taxValue;
    
    function DistributorRefundVault(address _taxCollector, uint256 _taxValue) RefundVault() public{
        taxCollector = _taxCollector;
        taxValue = _taxValue;
    }
   
    function close(address _wallet) onlyOwner public {
    
        require(state == State.Active);
        require(_wallet != 0x0);
        
        state = State.Closed;
        Closed();
        uint256 allPay = this.balance;
        uint256 forTarget1;
        uint256 forTarget2;
        if(taxValue <= allPay){
           forTarget1 = taxValue;
           forTarget2 = allPay.sub(taxValue);
           taxValue = 0;
        }else {
            taxValue = taxValue.sub(allPay);
            forTarget1 = allPay;
            forTarget2 = 0;
        }
        if(forTarget1 != 0){
            taxCollector.transfer(forTarget1);
        }
       
        if(forTarget2 != 0){
            _wallet.transfer(forTarget2);
        }

    }

}


// (B)
// The contract for freezing tokens for the team..
//contract SVTAllocation {
//    using SafeMath for uint256;
//
//    TokenL public token;
//
//    address public owner;
//
//    uint256 public unlockedAt;
//
//    // The contract takes the ERC20 coin address from which this contract will work and from the
//    // owner (Team wallet) who owns the funds.
//    function SVTAllocation(TokenL _token, address _owner) public{
//
//        // How many days to freeze from the moment of finalizing Round2
//        unlockedAt = now + 1 years;
//
//        token = _token;
//        owner = _owner;
//    }
//
//    function changeToken(TokenL _token) external{
//        require(msg.sender == owner);
//        token = _token;
//    }
//
//
//    // If the time of freezing expired will return the funds to the owner.
//    function unlock() external{
//        require(now >= unlockedAt);
//        require(token.transfer(owner,token.balanceOf(this)));
//    }
//}