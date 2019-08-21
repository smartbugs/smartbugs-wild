pragma solidity ^0.4.11;

// Created for conduction of Zaber ICO - http://www.zabercoin.io/
// Copying in whole or in part is prohibited.
// This code is the property of ICORating and ICOmachine - http://ICORating.com
// Authors: Ivan Fedorov and Dmitry Borodin

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    	uint256 c = a * b;
    	assert(a == 0 || c / a == b);
    	return c;
	}

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this does not hold
        return c;
    }
    
    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    
    function add(uint256 a, uint256 b) internal constant returns (uint256) {
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
    
    string public constant name = "ZABERcoin";
    string public constant symbol = "ZAB";
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
    
    function Token(){
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
  
	uint8 public round = 0;

	enum State { Active, Refunding, Closed }
  
    mapping (uint8 => mapping (address => uint256)) public deposited;

    State public state;
  
    event Closed();
    event RefundsEnabled();
    event Refunded(address indexed beneficiary, uint256 weiAmount);
  
    function RefundVault() public {
        state = State.Active;
    }
  
    // Depositing funds on behalf of an ICO investor. Available to the owner of the contract (Crowdsale Contract).
    function deposit(address investor) onlyOwner public payable {
        require(state == State.Active);
		deposited[round][investor] = deposited[round][investor].add(msg.value);
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
		uint256 depositedValue = deposited[round][investor];
		deposited[round][investor] = 0;
        investor.transfer(depositedValue);
        Refunded(investor, depositedValue);
    }

	function restart() onlyOwner public{
	    require(state == State.Closed);
	    round += 1;
	    state = State.Active;
	}
  
    // Destruction of the contract with return of funds to the specified address. Available to
    // the owner of the contract.
    function del(address _wallet) public onlyOwner {
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


// (A1)
// The main contract for the sale and management of rounds.
contract Crowdsale{
    using SafeMath for uint256;

    enum ICOType {preSale, sale}
    enum Roles {beneficiary,accountant,manager,observer,team}

    Token public token;

    bool public isFinalized = false;
    bool public isInitialized = false;
    bool public isPausedCrowdsale = false;

    mapping (uint8 => address) public wallets;

    uint256 public maxProfit;   // percent from 0 to 90
    uint256 public minProfit;   // percent from 0 to 90
    uint256 public stepProfit;  // percent step, from 1 to 50 (please, read doc!)

    uint256 public startTime;        // unixtime
    uint256 public endDiscountTime;  // unixtime
    uint256 public endTime;          // unixtime

    // How many tokens (excluding the bonus) are transferred to the investor in exchange for 1 ETH
    // **THOUSANDS** 10^3 for human, 1**3 for Solidity, 1e3 for MyEtherWallet (MEW). 
    // Example: if 1ETH = 40.5 Token ==> use 40500
    uint256 public rate;        
      
    // If the round does not attain this value before the closing date, the round is recognized as a 
    // failure and investors take the money back (the founders will not interfere in any way).
    // **QUINTILLIONS** 10^18 / 1**18 / 1e18. Example: softcap=15ETH ==> use 15**18 (Solidity) or 15e18 (MEW)
    uint256 public softCap;

    // The maximum possible amount of income
    // **QUINTILLIONS** 10^18 / 1**18 / 1e18. Example: hardcap=123.45ETH ==> use 123450**15 (Solidity) or 12345e15 (MEW)
    uint256 public hardCap;

    // If the last payment is slightly higher than the hardcap, then the usual contracts do 
    // not accept it, because it goes beyond the hardcap. However it is more reasonable to accept the
    // last payment, very slightly raising the hardcap. The value indicates by how many ETH the 
    // last payment can exceed the hardcap to allow it to be paid. Immediately after this payment, the 
    // round closes. The funders should write here a small number, not more than 1% of the CAP.
    // Can be equal to zero, to cancel.
    // **QUINTILLIONS** 10^18 / 1**18 / 1e18
    uint256 public overLimit;

    // The minimum possible payment from an investor in ETH. Payments below this value will be rejected.
    // **QUINTILLIONS** 10^18 / 1**18 / 1e18. Example: minPay=0.1ETH ==> use 100**15 (Solidity) or 100e15 (MEW)
    uint256 public minPay;

    uint256 ethWeiRaised;
    uint256 nonEthWeiRaised;
    uint256 weiPreSale;
    uint256 public tokenReserved;

    DistributorRefundVault public vault;

    SVTAllocation public lockedAllocation;

    ICOType ICO = ICOType.preSale;

    uint256 allToken;

    bool public team = false;

    event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    event Finalized();
    event Initialized();

    function Crowdsale(Token _token) public
    {

        // Initially, all next 5-7 roles/wallets are given to the Manager. The Manager is an employee of the company 
        // with knowledge of IT, who publishes the contract and sets it up. However, money and tokens require 
        // a Beneficiary and other roles (Accountant, Team, etc.). The Manager will not have the right 
        // to receive them. To enable this, the Manager must either enter specific wallets here, or perform 
        // this via method changeWallet. In the finalization methods it is written which wallet and 
        // what percentage of tokens are received.

        // Receives all the money (when finalizing pre-ICO & ICO)
        wallets[uint8(Roles.beneficiary)] = 0x8d6b447f443ce7cAA12399B60BC9E601D03111f9; 

        // Receives all the tokens for non-ETH investors (when finalizing pre-ICO & ICO)
        wallets[uint8(Roles.accountant)] = 0x99a280Dc34A996474e5140f34434CE59b5e65879;

        // All rights except the rights to receive tokens or money. Has the right to change any other 
        // wallets (Beneficiary, Accountant, ...), but only if the round has not started. Once the 
        // round is initialized, the Manager has lost all rights to change the wallets.
        // If the ICO is conducted by one person, then nothing needs to be changed. Permit all 7 roles 
        // point to a single wallet.
        wallets[uint8(Roles.manager)] = msg.sender; 

        // Has only the right to call paymentsInOtherCurrency (please read the document)
        wallets[uint8(Roles.observer)] = 0x8baf8F18256952362E485fEF1D0909F21f9a886C;

        // When the round is finalized, all team tokens are transferred to a special freezing 
        // contract. As soon as defrosting is over, only the Team wallet will be able to 
        // collect all the tokens. It does not store the address of the freezing contract, 
        // but the final wallet of the project team.
        wallets[uint8(Roles.team)] = 0x25365d4B293Ec34c39C00bBac3e5C5Ff2dC81F4F;

        // startTime, endDiscountTime, endTime (then you can change it in the setup)
        changePeriod(1510311600, 1511607600, 1511607600);

        // softCap & hardCap (then you can change it in the setup)
        changeTargets(0 ether, 51195 ether); // $15 000 000 / $293

        // rate (10^3), overLimit (10^18), minPay (10^18) (then you can change it in the setup)
        changeRate(61250, 500 ether, 10 ether);

        // minProfit, maxProfit, stepProfit
        changeDiscount(0,0,0);
 
        token = _token;
        token.setOwner();

        token.pause(); // block exchange tokens

        token.addUnpausedWallet(msg.sender);

        // The return of funds to investors & pay fee for partner 
        vault = new DistributorRefundVault(0x793ADF4FB1E8a74Dfd548B5E2B5c55b6eeC9a3f8, 10 ether);
    }

    // Returns the name of the current round in plain text. Constant.
    function ICOSaleType()  public constant returns(string){
        return (ICO == ICOType.preSale)?'pre ICO':'ICO';
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

    // Finalize. Only available to the Manager and the Beneficiary. If the round failed, then 
    // anyone can call the finalization to unlock the return of funds to investors
    // You must call a function to finalize each round (after the pre-ICO & after the ICO)
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

            // If the finalization is Round 1 pre-ICO
            if (ICO == ICOType.preSale) {

                // Reset settings
                isInitialized = false;
                isFinalized = false;

                // Switch to the second round (to ICO)
                ICO = ICOType.sale;

                // Reset the collection counter
                weiPreSale = weiRaised();
                ethWeiRaised = 0;
                nonEthWeiRaised = 0;

                // Re-start a refund contract
                vault.restart();


            } 
            else // If the second round is finalized 
            { 

                // Record how many tokens we have issued
                allToken = token.totalSupply();

                // Permission to collect tokens to those who can pick them up
                team = true;
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
    function finalize1()  public {
        require(wallets[uint8(Roles.manager)] == msg.sender);
        require(team);
        team = false;
        lockedAllocation = new SVTAllocation(token, wallets[uint8(Roles.team)]);
        token.addUnpausedWallet(lockedAllocation);
        // 20% - tokens to Team wallet after freeze (80% for investors)
        // *** CHECK THESE NUMBERS ***
        token.mint(lockedAllocation,allToken.mul(20).div(80));
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
	    // no code
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
    function setup(uint256 _startTime, uint256 _endDiscountTime, uint256 _endTime, uint256 _softCap, uint256 _hardCap, uint256 _rate, uint256 _overLimit, uint256 _minPay, uint256 _minProfit, uint256 _maxProfit, uint256 _stepProfit) public{
            changePeriod(_startTime, _endDiscountTime, _endTime);
            changeTargets(_softCap, _hardCap);
            changeRate(_rate, _overLimit, _minPay);
            changeDiscount(_minProfit, _maxProfit, _stepProfit);
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
    function changeDiscount(uint256 _minProfit, uint256 _maxProfit, uint256 _stepProfit) public {

        require(wallets[uint8(Roles.manager)] == msg.sender);

        require(!isInitialized);

        // The parameters are correct
        require(_stepProfit <= _maxProfit.sub(_minProfit));

        // If not zero steps
        if(_stepProfit > 0){
            // We will specify the maximum percentage at which it is possible to provide 
            // the specified number of steps without fractional parts
            maxProfit = _maxProfit.sub(_minProfit).div(_stepProfit).mul(_stepProfit).add(_minProfit);
        }else{
            // to avoid a divide to zero error, set the bonus as static
            maxProfit = _minProfit;
        }

        minProfit = _minProfit;
        stepProfit = _stepProfit;
    }

    // Collected funds for the current round. Constant.
    function weiRaised() public constant returns(uint256){
        return ethWeiRaised.add(nonEthWeiRaised);
    }

    // Returns the amount of fees for both phases. Constant.
    function weiTotalRaised() public constant returns(uint256){
        return weiPreSale.add(weiRaised());
    }

    // Returns the percentage of the bonus on the current date. Constant.
    function getProfitPercent() public constant returns (uint256){
        return getProfitPercentForData(now);
    }

    // Returns the percentage of the bonus on the given date. Constant.
    function getProfitPercentForData(uint256 timeNow) public constant returns (uint256)
    {
        // if the discount is 0 or zero steps, or the round does not start, we return the minimum discount
        if(maxProfit == 0 || stepProfit == 0 || timeNow > endDiscountTime) {
            return minProfit.add(100);
        }

        // if the round is over - the maximum
        if(timeNow<=startTime) {
            return maxProfit.add(100);
        }

        // bonus period
        uint256 range = endDiscountTime.sub(startTime);

        // delta bonus percentage
        uint256 profitRange = maxProfit.sub(minProfit);

        // Time left
        uint256 timeRest = endDiscountTime.sub(timeNow);

        // Divide the delta of time into
        uint256 profitProcent = profitRange.div(stepProfit).mul(timeRest.mul(stepProfit.add(1)).div(range));
        return profitProcent.add(minProfit).add(100);
    }

    // The ability to quickly check pre-ICO (only for Round 1, only 1 time). Completes the pre-ICO by 
    // transferring the specified number of tokens to the Accountant's wallet. Available to the Manager. 
    // Use only if this is provided by the script and white paper. In the normal scenario, it 
    // does not call and the funds are raised normally. We recommend that you delete this 
    // function entirely, so as not to confuse the auditors. Initialize & Finalize not needed. 
    // ** QUINTILIONS **  10^18 / 1**18 / 1e18
    function fastICO(uint256 _totalSupply) public {
      require(wallets[uint8(Roles.manager)] == msg.sender);
      require(ICO == ICOType.preSale && !isInitialized);
      token.mint(wallets[uint8(Roles.accountant)], _totalSupply);
      ICO = ICOType.sale;
    }
    
    // Remove the "Pause of exchange". Available to the manager at any time. If the 
    // manager refuses to remove the pause, then 120 days after the successful 
    // completion of the ICO, anyone can remove a pause and allow the exchange to continue. 
    // The manager does not interfere and will not be able to delay the term. 
    // He can only cancel the pause before the appointed time.
    function tokenUnpause() public {
        require(wallets[uint8(Roles.manager)] == msg.sender 
        	|| (now > endTime + 120 days && ICO == ICOType.sale && isFinalized && goalReached()));
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
        return _accountant;
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

    // If a little more than a year has elapsed (ICO start date + 460 days), a smart contract 
    // will allow you to send all the money to the Beneficiary, if any money is present. This is 
    // possible if you mistakenly launch the ICO for 30 years (not 30 days), investors will transfer 
    // money there and you will not be able to pick them up within a reasonable time. It is also 
    // possible that in our checked script someone will make unforeseen mistakes, spoiling the 
    // finalization. Without finalization, money cannot be returned. This is a rescue option to 
    // get around this problem, but available only after a year (460 days).

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

    // Our BTC wallet for audit in this function: 1CAyLcES1tNuatRhnL1ooPViZ32vF5KQ4A

    // ** QUINTILLIONS ** 10^18 / 1**18 / 1e18
    function paymentsInOtherCurrency(uint256 _token, uint256 _value) public {
        require(wallets[uint8(Roles.observer)] == msg.sender);
        bool withinPeriod = (now >= startTime && now <= endTime);
        
        bool withinCap = _value.add(ethWeiRaised) <= hardCap.add(overLimit);
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

        uint256 ProfitProcent = getProfitPercent();
        // calculate token amount to be created
        uint256 tokens = weiAmount.mul(rate).mul(ProfitProcent).div(100000);

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
        unlockedAt = now + 365 days; // freeze TEAM tokens for 1 year
        token = _token;
        owner = _owner;
    }

    // If the time of freezing expired will return the funds to the owner.
    function unlock() public{
        require(now >= unlockedAt);
        require(token.transfer(owner,token.balanceOf(this)));
    }
}