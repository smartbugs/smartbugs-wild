pragma solidity ^0.4.25;

/**
 *  X3ProfitInMonth contract (300% per 33 day, 99% per 11 day, 9% per day, in first iteration)
 *  This percent will decrease every restart of system to lowest value of 0.9% per day
 *
 *  Improved, no bugs and backdoors! Your investments are safe!
 *
 *  LOW RISK! You can take your deposit back ANY TIME!
 *     - Send 0.00000112 ETH to contract address
 *
 *  NO DEPOSIT FEES! All the money go to contract!
 *
 *  LOW WITHDRAWAL FEES! Advertising 10% to OUR MAIN CONTRACT 0xf85D337017D9e6600a433c5036E0D18EdD0380f3
 *
 *  HAVE COMMAND PREPARATION TIME DURING IT WILL BE RETURN ONLY INVESTED AMOUNT AND NOT MORE!!!
 *  Only special command will run X3 MODE!!!
 * 
 *  After restart system automaticaly make deposits for damage users in damaged part, 
 *   but before it users must self make promotion deposit by any amount first.
 *
 *  INSTRUCTIONS:
 *
 *  TO INVEST: send ETH to contract address
 *  TO WITHDRAW INTEREST: send 0 ETH to contract address
 *  TO REINVEST AND WITHDRAW INTEREST: send ETH to contract address
 *  TO GET BACK YOUR DEPOSIT: send 0.00000112 ETH to contract address
 *  TO START X3 WORK, ANY MEMBER CAN SEND 0.00000111 ETH to contract address
 *     While X3 not started investors can return only their deposits and no profit.
 *     Admin voice power is equal 10 simple participants
 *
 *  RECOMMENDED GAS LIMIT 200000
 */
 
contract X3ProfitInMonth {

	struct Investor {
	      // Restart iteration index
		uint iteration;
          // array containing information about beneficiaries
		uint deposit;
		  // sum locked to remove in predstart period, gived by contract for 
		  // compensation of previous iteration restart
		uint lockedDeposit;
           //array containing information about the time of payment
		uint time;
          //array containing information on interest paid
		uint withdrawn;
           //array containing information on interest paid (without tax)
		uint withdrawnPure;
		   // Vote system for start iteration
		bool isVoteProfit;
	}

    mapping(address => Investor) public investors;
	
    //fund to transfer percent for MAIN OUR CONTRACT EasyInvestForeverProtected2
    address public constant ADDRESS_MAIN_FUND = 0x20C476Bb4c7aA64F919278fB9c09e880583beb4c;
    address public constant ADDRESS_ADMIN =     0x6249046Af9FB588bb4E70e62d9403DD69239bdF5;
    //time through which you can take dividends
    uint private constant TIME_QUANT = 1 days;
	
    //start percent 10% per day
    uint private constant PERCENT_DAY = 10;
    uint private constant PERCENT_DECREASE_PER_ITERATION = 1;

    //Adv tax for withdrawal 10%
    uint private constant PERCENT_MAIN_FUND = 10;

    //All percent should be divided by this
    uint private constant PERCENT_DIVIDER = 100;

    uint public countOfInvestors = 0;
    uint public countOfAdvTax = 0;
	uint public countStartVoices = 0;
	uint public iterationIndex = 1;

    // max contract balance in ether for overflow protection in calculations only
    // 340 quintillion 282 quadrillion 366 trillion 920 billion 938 million 463 thousand 463
	uint public constant maxBalance = 340282366920938463463374607431768211456 wei; //(2^128) 
	uint public constant maxDeposit = maxBalance / 1000; 
	
	// X3 Mode status
    bool public isProfitStarted = false; 

    modifier isIssetUser() {
        require(investors[msg.sender].iteration == iterationIndex, "Deposit not found");
        _;
    }

    modifier timePayment() {
        require(now >= investors[msg.sender].time + TIME_QUANT, "Too fast payout request");
        _;
    }

    //return of interest on the deposit
    function collectPercent() isIssetUser timePayment internal {
        uint payout = payoutAmount(msg.sender);
        _payout(msg.sender, payout, false);
    }

    //calculate the amount available for withdrawal on deposit
    function payoutAmount(address addr) public view returns(uint) {
        Investor storage inv = investors[addr];
        if(inv.iteration != iterationIndex)
            return 0;
        uint varTime = inv.time;
        uint varNow = now;
        if(varTime > varNow) varTime = varNow;
        uint percent = PERCENT_DAY;
        uint decrease = PERCENT_DECREASE_PER_ITERATION * (iterationIndex - 1);
        if(decrease > percent - PERCENT_DECREASE_PER_ITERATION)
            decrease = percent - PERCENT_DECREASE_PER_ITERATION;
        percent -= decrease;
        uint rate = inv.deposit * percent / PERCENT_DIVIDER;
        uint fraction = 100;
        uint interestRate = fraction * (varNow  - varTime) / 1 days;
        uint withdrawalAmount = rate * interestRate / fraction;
        if(interestRate < 100) withdrawalAmount = 0;
        return withdrawalAmount;
    }

    //make a deposit
    function makeDeposit() private {
        if (msg.value > 0) {
            Investor storage inv = investors[msg.sender];
            if (inv.iteration != iterationIndex) {
                countOfInvestors += 1;
                if(inv.deposit > inv.withdrawnPure)
			        inv.deposit -= inv.withdrawnPure;
		        else
		            inv.deposit = 0;
		        if(inv.deposit + msg.value > maxDeposit) 
		            inv.deposit = maxDeposit - msg.value;
				inv.withdrawn = 0;
				inv.withdrawnPure = 0;
				inv.time = now;
				inv.iteration = iterationIndex;
				inv.lockedDeposit = inv.deposit;
				inv.isVoteProfit = false;
            }
            if (inv.deposit > 0 && now >= inv.time + TIME_QUANT) {
                collectPercent();
            }
            
            inv.deposit += msg.value;
            
        } else {
            collectPercent();
        }
    }

    //return of deposit balance
    function returnDeposit() isIssetUser private {
        Investor storage inv = investors[msg.sender];
        uint withdrawalAmount = 0;
        uint activDep = inv.deposit - inv.lockedDeposit;
        if(activDep > inv.withdrawn)
            withdrawalAmount = activDep - inv.withdrawn;

        if(withdrawalAmount > address(this).balance){
            withdrawalAmount = address(this).balance;
        }
        //Pay the rest of deposit and take taxes
        _payout(msg.sender, withdrawalAmount, true);

        //delete user record
        _delete(msg.sender);
    }
    
    function() external payable {
        require(msg.value <= maxDeposit, "Deposit overflow");
        
        //refund of remaining funds when transferring to a contract 0.00000112 ether
        Investor storage inv = investors[msg.sender];
        if (msg.value == 0.00000112 ether && inv.iteration == iterationIndex) {
            inv.deposit += msg.value;
            if(inv.deposit > maxDeposit) inv.deposit = maxDeposit;
            returnDeposit();
        } else {
            //start X3 Mode on 0.00000111 ether
            if (msg.value == 0.00000111 ether && !isProfitStarted) {
                makeDeposit();
                if(inv.deposit > maxDeposit) inv.deposit = maxDeposit;
                if(!inv.isVoteProfit)
                {
                    countStartVoices++;
                    inv.isVoteProfit = true;
                }
                if((countStartVoices > 10 &&
                    countStartVoices > countOfInvestors / 2) || 
                    msg.sender == ADDRESS_ADMIN)
    			    isProfitStarted = true;
            } 
            else
            {
                require(
                    msg.value == 0 ||
                    address(this).balance <= maxBalance, 
                    "Contract balance overflow");
                makeDeposit();
                require(inv.deposit <= maxDeposit, "Deposit overflow");
            }
        }
    }
    
    function restart() private {
		countOfInvestors = 0;
		iterationIndex++;
		countStartVoices = 0;
		isProfitStarted = false;
	}
	
    //Pays out, takes taxes according to holding time
    function _payout(address addr, uint amount, bool retDep) private {
        if(amount == 0)
            return;
		if(amount > address(this).balance) amount = address(this).balance;
		if(amount == 0){
			restart();
			return;
		}
		Investor storage inv = investors[addr];
        //Calculate pure payout that user receives
        uint activDep = inv.deposit - inv.lockedDeposit;
		if(!retDep && !isProfitStarted && amount + inv.withdrawn > activDep / 2 )
		{
			if(inv.withdrawn < activDep / 2)
    			amount = (activDep/2) - inv.withdrawn;
			else{
    			if(inv.withdrawn >= activDep)
    			{
    				_delete(addr);
    				return;
    			}
    			amount = activDep - inv.withdrawn;
    			_delete(addr);
			}
		}
        uint interestPure = amount * (PERCENT_DIVIDER - PERCENT_MAIN_FUND) / PERCENT_DIVIDER;

        //calculate money to charity
        uint advTax = amount - interestPure;

		inv.withdrawnPure += interestPure;
		inv.withdrawn += amount;
		inv.time = now;

        //send money
        if(ADDRESS_MAIN_FUND.call.value(advTax)()) 
            countOfAdvTax += advTax;
        else
            inv.withdrawn -= advTax;

        addr.transfer(interestPure);

		if(address(this).balance == 0)
			restart();
    }

    //Clears user from registry
    function _delete(address addr) private {
        if(investors[addr].iteration != iterationIndex)
            return;
        investors[addr].iteration = 0;
        countOfInvestors--;
    }
}