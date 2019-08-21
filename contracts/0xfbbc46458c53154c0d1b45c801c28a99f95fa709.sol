pragma solidity ^0.4.18;

// Project: High Reward Coin
// v4, 2017-12-31
// This code is the property of CryptoB2B.io
// Copying in whole or in part is prohibited.
// Authors: Ivan Fedorov and Dmitry Borodin
// Do you want the same ICO platform? www.cryptob2b.io


// (A1)
// The main contract for the sale and management of rounds.
contract CrowdsaleBL{
    using SafeMath for uint256;

    enum ICOType {round1, round2}
    enum Roles {beneficiary, accountant, manager, observer, bounty, team, company}

    Token public token;

    bool public isFinalized;
    bool public isInitialized;
    bool public isPausedCrowdsale;

    mapping (uint8 => address) public wallets;
   

    uint256 public startTime = 1516435200;    // 20.01.2018 08:00:00
    uint256 public endTime = 1519171199;      // 20.02.2018 23:59:59

    // How many tokens (excluding the bonus) are transferred to the investor in exchange for 1 ETH
    // **THOUSANDS** 10^3 for human, 1*10**3 for Solidity, 1e3 for MyEtherWallet (MEW).
    // Example: if 1ETH = 40.5 Token ==> use 40500
    uint256 public rate = 400000; // Tokens

    // If the round does not attain this value before the closing date, the round is recognized as a
    // failure and investors take the money back (the founders will not interfere in any way).
    // **QUINTILLIONS** 10^18 / 1*10**18 / 1e18. Example: softcap=15ETH ==> use 15*10**18 (Solidity) or 15e18 (MEW)
    uint256 public softCap = 1240000*10**18; // 1,24M Tokens (~ $1 000 000)

    // The maximum possible amount of income
    // **QUINTILLIONS** 10^18 / 1*10**18 / 1e18. Example: hardcap=123.45ETH ==> use 123450*10**15 (Solidity) or 12345e15 (MEW)
    uint256 public hardCap = 9240000*10**18; // 9,24M Tokens (~ $12 700 00)

    // If the last payment is slightly higher than the hardcap, then the usual contracts do
    // not accept it, because it goes beyond the hardcap. However it is more reasonable to accept the
    // last payment, very slightly raising the hardcap. The value indicates by how many Token emitted the
    // last payment can exceed the hardcap to allow it to be paid. Immediately after this buy, the
    // round closes. The funders should write here a small number, not more than 1% of the CAP.
    // Can be equal to zero, to cancel.
    // **QUINTILLIONS** 10^18 / 1*10**18 / 1e18
    uint256 public overLimit = 20000*10**18; // Tokens (~$20000)

    // The minimum possible payment from an investor in ETH. Payments below this value will be rejected.
    // **QUINTILLIONS** 10^18 / 1*10**18 / 1e18. Example: minPay=0.1ETH ==> use 100*10**15 (Solidity) or 100e15 (MEW)
    uint256 public minPay = 36*10**15; // 0,036 ETH (~$25)

    uint256 public ethWeiRaised;
    uint256 public nonEthWeiRaised;
    uint256 weiRound1;
    uint256 public tokenReserved;

    RefundVault public vault;
    SVTAllocation public lockedAllocation;
    
    
    struct BonusBlock {uint256 amount; uint256 procent;}
    BonusBlock[] public bonusPattern;

    ICOType ICO = ICOType.round2; // only ICO round #2 (no pre-ICO)

    uint256 allToken;

    bool public bounty;
    bool public team;
    bool public company;
    bool public partners;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    event Finalized();
    event Initialized();

    function CrowdsaleBL(Token _token, uint256 firstMint) public
    {
        // Initially, all next 7 roles/wallets are given to the Manager. The Manager is an employee of the company
        // with knowledge of IT, who publishes the contract and sets it up. However, money and tokens require
        // a Beneficiary and other roles (Accountant, Team, etc.). The Manager will not have the right
        // to receive them. To enable this, the Manager must either enter specific wallets here, or perform
        // this via method changeWallet. In the finalization methods it is written which wallet and
        // what percentage of tokens are received.

        // Receives all the money (when finalizing pre-ICO & ICO)
        wallets[uint8(Roles.beneficiary)] = 0xe06bD713B2e33C218FDD56295Af74d45cE8c9D98; //msg.sender;

        // Receives all the tokens for non-ETH investors (when finalizing pre-ICO & ICO)
        wallets[uint8(Roles.accountant)] = 0xddC98d7d9CdD82172daD7467c8E341cfBEb077DD; //msg.sender;

        // All rights except the rights to receive tokens or money. Has the right to change any other
        // wallets (Beneficiary, Accountant, ...), but only if the round has not started. Once the
        // round is initialized, the Manager has lost all rights to change the wallets.
        // If the ICO is conducted by one person, then nothing needs to be changed. Permit all 7 roles
        // point to a single wallet.
        wallets[uint8(Roles.manager)] = msg.sender;

        // Has only the right to call paymentsInOtherCurrency (please read the document)
        wallets[uint8(Roles.observer)] = 0x76d737F21296cd1ED6938DbCA217615681b06336; //msg.sender;


        wallets[uint8(Roles.bounty)] = 0x4918fc7974d7Ee6F266f9256DfcA610FD735Bf27; //msg.sender;

        // When the round is finalized, all team tokens are transferred to a special freezing
        // contract. As soon as defrosting is over, only the Team wallet will be able to
        // collect all the tokens. It does not store the address of the freezing contract,
        // but the final wallet of the project team.
        wallets[uint8(Roles.team)] = 0xc59403026685F553f8a6937C53452b9d1DE4c707; // msg.sender;

        // startTime, endDiscountTime, endTime (then you can change it in the setup)
        //changePeriod(now + 5 minutes, now + 5 + 10 minutes, now + 5 + 12 minutes);

        wallets[uint8(Roles.company)] = 0xc59403026685F553f8a6937C53452b9d1DE4c707; //msg.sender;
        
        token = _token;
        token.setOwner();

        token.pause(); // block exchange tokens

        token.addUnpausedWallet(msg.sender);
        token.addUnpausedWallet(wallets[uint8(Roles.company)]);
        token.addUnpausedWallet(wallets[uint8(Roles.bounty)]);
        token.addUnpausedWallet(wallets[uint8(Roles.accountant)]);

        if (firstMint > 0){
            token.mint(msg.sender,firstMint);
        }

    }

    // Returns the name of the current round in plain text. Constant.
    function ICOSaleType()  public constant returns(string){
        return (ICO == ICOType.round1)?'round1':'round2';
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

        // round is initialized and no "Pause of trading" is set
        return withinPeriod && nonZeroPurchase && isInitialized && !isPausedCrowdsale;
    }

    // Check for the ability to finalize the round. Constant.
    function hasEnded() public constant returns (bool) {

        bool timeReached = now > endTime;

        bool capReached = token.totalSupply().add(tokenReserved) >= hardCap;

        return (timeReached || capReached) && isInitialized;
    }
    
    function finalizeAll() external {
        finalize();
        finalize1();
        finalize2();
        finalize3();
        finalize4();
    }

    // Finalize. Only available to the Manager and the Beneficiary. If the round failed, then
    // anyone can call the finalization to unlock the return of funds to investors
    // You must call a function to finalize each round (after the pre-ICO & after the ICO)
    function finalize() public {

        require(wallets[uint8(Roles.manager)] == msg.sender || wallets[uint8(Roles.beneficiary)] == msg.sender|| !goalReached());
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

            // If the finalization is Round 1 pre-ICO
            if (ICO == ICOType.round1) {

                // Reset settings
                isInitialized = false;
                isFinalized = false;

                // Switch to the second round (to ICO)
                ICO = ICOType.round2;

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
                partners = true;

            }

        }
        else // If they failed round
        {
            // Allow investors to withdraw their funds
            vault.enableRefunds();
        }
    }

    // The Manager freezes the tokens for the Team.
    // You must call a function to finalize Round 2 (only after the ICO)
    function finalize1() public {
        require(wallets[uint8(Roles.manager)] == msg.sender || wallets[uint8(Roles.beneficiary)] == msg.sender);
        require(team);
        team = false;
        lockedAllocation = new SVTAllocation(token, wallets[uint8(Roles.team)]);
        token.addUnpausedWallet(lockedAllocation);
        // 6% - tokens to Team wallet after freeze (77% for investors)
        // *** CHECK THESE NUMBERS ***
        token.mint(lockedAllocation, allToken.mul(6).div(77));
    }

    function finalize2() public {
        require(wallets[uint8(Roles.manager)] == msg.sender || wallets[uint8(Roles.beneficiary)] == msg.sender);
        require(bounty);
        bounty = false;
        // 2% - tokens to bounty wallet (77% for investors)
        // *** CHECK THESE NUMBERS ***
        token.mint(wallets[uint8(Roles.bounty)], allToken.mul(2).div(77));
    }

    function finalize3() public {
        require(wallets[uint8(Roles.manager)] == msg.sender || wallets[uint8(Roles.beneficiary)] == msg.sender);
        require(company);
        company = false;
        // 2% - tokens to company wallet (77% for investors)
        // *** CHECK THESE NUMBERS ***
        token.mint(wallets[uint8(Roles.company)],allToken.mul(2).div(77));
    }

    function finalize4()  public {
        require(wallets[uint8(Roles.manager)] == msg.sender || wallets[uint8(Roles.beneficiary)] == msg.sender);
        require(partners);
        partners = false;
        // 13% - tokens to partners+referral wallet (77% for investors)
        // *** CHECK THESE NUMBERS ***
        token.mint(wallets[uint8(Roles.accountant)],allToken.mul(13).div(77));
    }


    // Initializing the round. Available to the manager. After calling the function,
    // the Manager loses all rights: Manager can not change the settings (setup), change
    // wallets, prevent the beginning of the round, etc. You must call a function after setup
    // for the initial round (before the Pre-ICO and before the ICO)
    function initialize() public{

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
	    vault = new RefundVault();
    }

    // At the request of the investor, we raise the funds (if the round has failed because of the hardcap)
    function claimRefund() public{
        vault.refund(msg.sender);
    }

    // We check whether we collected the necessary minimum funds. Constant.
    function goalReached() public constant returns (bool) {
        return token.totalSupply().add(tokenReserved) >= softCap;
    }

    // Customize. The arguments are described in the constructor above.
    function setup(uint256 _startTime, uint256 _endTime, uint256 _softCap, uint256 _hardCap, uint256 _rate, uint256 _overLimit, uint256 _minPay, uint256[] _amount, uint256[] _procent) public{
            changePeriod(_startTime, _endTime);
            changeRate(_rate, _minPay);
            changeCap(_softCap, _hardCap, _overLimit);
            if(_amount.length > 0)
                setBonusPattern(_amount,_procent);
    }

	// Change the date and time: the beginning of the round, the end of the bonus, the end of the round. Available to Manager
    // Description in the Crowdsale constructor
    function changePeriod(uint256 _startTime, uint256 _endTime) public{

        require(wallets[uint8(Roles.manager)] == msg.sender);

        require(!isInitialized);

        // Date and time are correct
        require(now <= _startTime);
        require(_startTime < _endTime);

        startTime = _startTime;
        endTime = _endTime;
    }
    

    // Change the price (the number of tokens per 1 eth), the maximum hardCap for the last bet,
    // the minimum bet. Available to the Manager.
    // Description in the Crowdsale constructor
    function changeRate(uint256 _rate, uint256 _minPay) public {

         require(wallets[uint8(Roles.manager)] == msg.sender || wallets[uint8(Roles.observer)] == msg.sender);

         require(_rate > 0);

         rate = _rate;
         minPay = _minPay;
    }
    
    function changeCap(uint256 _softCap, uint256 _hardCap, uint256 _overLimit) public {
        require(wallets[uint8(Roles.manager)] == msg.sender);
        require(!isInitialized);
        require(_hardCap > _softCap);
        softCap = _softCap;
        hardCap = _hardCap;
        overLimit = _overLimit;
    }
    
    function setBonusPattern(uint256[] _amount, uint256[] _procent) public {
        require(wallets[uint8(Roles.manager)] == msg.sender);
        require(!isInitialized);
        require(_amount.length == _procent.length);
        bonusPattern.length = _amount.length;
        for(uint256 i = 0; i < _amount.length; i++){
            bonusPattern[i] = BonusBlock(_amount[i],_procent[i]);
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


    // The ability to quickly check pre-ICO (only for Round 1, only 1 time). Completes the pre-ICO by
    // transferring the specified number of tokens to the Accountant's wallet. Available to the Manager.
    // Use only if this is provided by the script and white paper. In the normal scenario, it
    // does not call and the funds are raised normally. We recommend that you delete this
    // function entirely, so as not to confuse the auditors. Initialize & Finalize not needed.
    // ** QUINTILIONS **  10^18 / 1*10**18 / 1e18
//    function fastICO(uint256 _totalSupply) public {
//      require(wallets[uint8(Roles.manager)] == msg.sender);
//      require(ICO == ICOType.round1 && !isInitialized);
//      token.mint(wallets[uint8(Roles.accountant)], _totalSupply);
//      ICO = ICOType.round2;
//    }

    // Remove the "Pause of exchange". Available to the manager at any time. If the
    // manager refuses to remove the pause, then 30 days after the successful
    // completion of the ICO, anyone can remove a pause and allow the exchange to continue.
    // The manager does not interfere and will not be able to delay the term.
    // He can only cancel the pause before the appointed time.
    function tokenUnpause() public {
        require(wallets[uint8(Roles.manager)] == msg.sender
        	|| (now > endTime + 30 days && ICO == ICOType.round2 && isFinalized && goalReached()));
        token.unpause();
    }

    // Enable the "Pause of exchange". Available to the manager until the ICO is completed.
    // The manager cannot turn on the pause, for example, 3 years after the end of the ICO.
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
        if(!unpausedWallet(oldWallet))
            token.delUnpausedWallet(oldWallet);
        if(unpausedWallet(_wallet))
            token.addUnpausedWallet(_wallet);
    }

    // If a little more than a year has elapsed (ICO start date + 400 days), a smart contract
    // will allow you to send all the money to the Beneficiary, if any money is present. This is
    // possible if you mistakenly launch the ICO for 30 years (not 30 days), investors will transfer
    // money there and you will not be able to pick them up within a reasonable time. It is also
    // possible that in our checked script someone will make unforeseen mistakes, spoiling the
    // finalization. Without finalization, money cannot be returned. This is a rescue option to
    // get around this problem, but available only after a year (400 days).

	// Another reason - the ICO was a failure, but not all ETH investors took their money during the year after.
	// Some investors may have lost a wallet key, for example.

	// The method works equally with the pre-ICO and ICO. When the pre-ICO starts, the time for unlocking
	// the distructVault begins. If the ICO is then started, then the term starts anew from the first day of the ICO.

	// Next, act independently, in accordance with obligations to investors.

	// Within 400 days of the start of the Round, if it fails only investors can take money. After
	// the deadline this can also include the company as well as investors, depending on who is the first to use the method.
    function distructVault() public {
        require(wallets[uint8(Roles.beneficiary)] == msg.sender);
        require(now > startTime + 400 days);
        vault.del(wallets[uint8(Roles.beneficiary)]);
    }
    
    
    
    function getBonus(uint256 _tokenValue) public constant returns (uint256 value) {
        uint256 totalToken = tokenReserved.add(token.totalSupply());
        uint256 tokenValue = _tokenValue;
        uint256 currentBonus;
        uint256 calculateBonus = 0;
        uint16 i;
        for (i = 0; i < bonusPattern.length; i++){
            if(totalToken >= bonusPattern[i].amount)
                continue;
            currentBonus = tokenValue.mul(bonusPattern[i].procent.add(100000)).div(100000);
            if(totalToken.add(calculateBonus).add(currentBonus) < bonusPattern[i].amount) {
                calculateBonus = calculateBonus.add(currentBonus);
                tokenValue = 0;
                break;
            }
            currentBonus = bonusPattern[i].amount.sub(totalToken.add(calculateBonus));
            tokenValue = tokenValue.sub(currentBonus.mul(100000).div(bonusPattern[i].procent.add(100000)));
            calculateBonus = calculateBonus + currentBonus;
        }
        return calculateBonus.add(tokenValue);
    }


	// We accept payments other than Ethereum (ETH) and other currencies, for example, Bitcoin (BTC).
	// Perhaps other types of cryptocurrency - see the original terms in the white paper and on the ICO website.

	// We release tokens on Ethereum. During the pre-ICO and ICO with a smart contract, you directly transfer
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
	// everywhere (in a white paper, on the ICO website, on Telegram, on Bitcointalk, in this code, etc.)
	// Anyone interested can check that the administrator of the smart contract writes down exactly the amount
	// in ETH (in equivalent for BTC) there. In theory, the ability to bypass a smart contract to accept money in
	// BTC and not register them in ETH creates a possibility for manipulation by the company. Thanks to
	// paymentsInOtherCurrency however, this threat is leveled.

	// Any user can check the amounts in BTC and the variable of the smart contract that accounts for this
	// (paymentsInOtherCurrency method). Any user can easily check the incoming transactions in a smart contract
	// on a daily basis. Any hypothetical tricks on the part of the company can be exposed and panic during the ICO,
	// simply pointing out the incompatibility of paymentsInOtherCurrency (ie, the amount of ETH + BTC collection)
	// and the actual transactions in BTC. The company strictly adheres to the described principles of openness.

	// The company administrator is required to synchronize paymentsInOtherCurrency every working day (but you
	// cannot synchronize if there are no new BTC payments). In the case of unforeseen problems, such as
	// brakes on the Ethereum network, this operation may be difficult. You should only worry if the
	// administrator does not synchronize the amount for more than 96 hours in a row, and the BTC wallet
	// receives significant amounts.

	// This scenario ensures that for the sum of all fees in all currencies this value does not exceed hardcap.

    // Common BTC wallet: 12sEoiXPs8a6sJbC2qkbZDjmHsSBv7cGwC

    // ** QUINTILLIONS ** 10^18 / 1**18 / 1e18
    function paymentsInOtherCurrency(uint256 _token, uint256 _value) public {
        require(wallets[uint8(Roles.observer)] == msg.sender);
        bool withinPeriod = (now >= startTime && now <= endTime);

        bool withinCap = token.totalSupply().add(_token) <= hardCap.add(overLimit);
        require(withinPeriod && withinCap && isInitialized);

        nonEthWeiRaised = _value;
        tokenReserved = _token;

    }


    // The function for obtaining smart contract funds in ETH. If all the checks are true, the token is
    // transferred to the buyer, taking into account the current bonus.
    function buyTokens(address beneficiary) public payable {
        require(beneficiary != 0x0);
        require(validPurchase());

        uint256 weiAmount = msg.value;

        // calculate token amount to be created
        uint256 tokens = getBonus(weiAmount*rate/1000);
        
        // hardCap is not reached, and in the event of a transaction, it will not be exceeded by more than OverLimit
        bool withinCap = tokens <= hardCap.sub(token.totalSupply().add(tokenReserved)).add(overLimit);
        
        require(withinCap);

        // update state
        ethWeiRaised = ethWeiRaised.add(weiAmount);

        token.mint(beneficiary, tokens);
        TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

        forwardFunds();
    }

    // buyTokens alias
    function () public payable {
        buyTokens(msg.sender);
    }

}

// (B)
// The contract for freezing tokens for the team..
contract SVTAllocation {
    using SafeMath for uint256;

    Token public token;

	address public owner;

    uint256 public unlockedAt;

    uint256 tokensCreated = 0;

    // The contract takes the ERC20 coin address from which this contract will work and from the
    // owner (Team wallet) who owns the funds.
    function SVTAllocation(Token _token, address _owner) public{

    	// How many days to freeze from the moment of finalizing ICO
        unlockedAt = now + 1 years;
        token = _token;
        owner = _owner;
    }

    // If the time of freezing expired will return the funds to the owner.
    function unlock() public{
        require(now >= unlockedAt);
        require(token.transfer(owner,token.balanceOf(this)));
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



// (A2)
// Contract token
contract Token is Pausable{
    using SafeMath for uint256;

    string public constant name = "High Reward Coin";
    string public constant symbol = "HRC";
    uint8 public constant decimals = 18;

    uint256 public totalSupply;

    mapping(address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    mapping (address => bool) public unpausedWallet;

    bool public mintingFinished = false;

    uint256 public totalMigrated;
    address public migrationAgent;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    event Migrate(address indexed _from, address indexed _to, uint256 _value);

    modifier canMint() {
        require(!mintingFinished);
        _;
    }

     function Token() public {
         owner = 0x0;
     }

     function setOwner() public{
         require(owner == 0x0);
         owner = msg.sender;
     }

    // Balance of the specified address
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    // Transfer of tokens from one account to another
    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
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
    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
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
//    function finishMinting() public onlyOwner returns (bool) {
//        mintingFinished = true;
//        MintFinished();
//        return true;
//    }

    // Redefinition of the method of the returning status of the "Exchange pause".
    // Never for the owner of an unpaused wallet.
    function paused() public constant returns(bool) {
        return super.paused() && !unpausedWallet[msg.sender];
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

    // Reissue your tokens.
    function migrate() public
    {
        uint256 value = balances[msg.sender];
        require(value > 0);

        totalSupply = totalSupply.sub(value);
        totalMigrated = totalMigrated.add(value);
        MigrationAgent(migrationAgent).migrateFrom(msg.sender, value);
        Migrate(msg.sender,migrationAgent,value);
        balances[msg.sender] = 0;
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

    // Depositing funds on behalf of an ICO investor. Available to the owner of the contract (Crowdsale Contract).
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