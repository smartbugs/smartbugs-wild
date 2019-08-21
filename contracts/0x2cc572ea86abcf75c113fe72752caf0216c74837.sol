pragma solidity ^0.4.16; //YourMomTokenCrowdsale

interface token {
	function transferFrom(address _holder, address _receiver, uint amount) public returns (bool success);
	function allowance(address _owner, address _spender) public returns (uint256 remaining);
	function balanceOf(address _owner) public returns (uint256 balance);
}


contract owned {	// Defines contract Owner
	address public owner;

	// Events
	event TransferOwnership (address indexed _owner, address indexed _newOwner);	// Notifies about the ownership transfer

	// Constrctor function
	function owned() public {
		owner = msg.sender;
	}

	function transferOwnership(address newOwner) onlyOwner public {
		TransferOwnership (owner, newOwner);
		owner = newOwner;
	}
	
	// Modifiers
	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}
}


contract YourMomTokenCrowdsale is owned {
	token public tokenReward;
	string public name;
	address public beneficiary;
	address public tokenHolder;
	uint256 public crowdsaleStartTime;
	uint256 public deadline;
	uint256 public tokensIssued;
	uint256 public amountRaised;
	mapping(address => uint256) private balanceOf;
	mapping(address => uint256) private etherBalanceOf;
	uint256 private reclaimForgottenEtherDeadline;
	uint256 private currentContractAllowance;
	uint256 private initialContractAllowance;
	uint256 private originalTokenReward;
	uint256 private _etherAmount;
	uint256 private price;
	uint8 private errorCount = 0;
	bool public purchasingAllowed = false;
	bool public failSafeMode = false;
	bool private afterFirstWithdrawal = false;
	bool private allowanceSetted = false;

	// Events
	event TokenPurchase(address indexed taker, uint amount, uint tokensBought);
	event FundWithdrawal(address indexed to, uint amount, bool isBeneficiary);
	event PurchasingAllowed(bool enabled);
	event ExecutionError(string reason);
	event FailSafeActivated(bool enabled);

	//Constrctor function
	function YourMomTokenCrowdsale(string contractName, address ifSuccessfulSendTo, uint durationInDays, uint howManyTokensAnEtherCanBuy, address addressOfTokenUsedAsReward, address adressOfTokenHolder, uint crowdsaleStartTimeTimestamp, uint ifInFailSafeTimeInDaysAfterDeadlineToReclaimForgottenEther) public {
		name = contractName;									// Set the name for display purposes
		crowdsaleStartTime = crowdsaleStartTimeTimestamp;
		deadline = crowdsaleStartTime + durationInDays * 1 days;
		originalTokenReward = howManyTokensAnEtherCanBuy;		//Assuming Token has 18 decimal units
		tokenReward = token(addressOfTokenUsedAsReward);
		tokenHolder = adressOfTokenHolder;
		beneficiary = ifSuccessfulSendTo;
		reclaimForgottenEtherDeadline = deadline + ifInFailSafeTimeInDaysAfterDeadlineToReclaimForgottenEther * 1 days;
	}

	//Fallback function
	function () payable public {
		require(!failSafeMode);
		require(purchasingAllowed);
		require(now >= crowdsaleStartTime);
		require(msg.value != 0);
		require(amountRaised + msg.value > amountRaised);	//Check for overflow
		price = _currentTokenRewardCalculator();
		require(tokenReward.transferFrom(tokenHolder, msg.sender, msg.value * price));	//Transfer tokens from tokenHolder to msg.sender
		amountRaised += msg.value;					//Updates amount raised
		tokensIssued += msg.value * price;			//Updates token selled (required for audit)
		etherBalanceOf[msg.sender] += msg.value; 	//Updates msg.sender ether contribution amount
		balanceOf[msg.sender] += msg.value * price;	//Updates the amount of tokens msg.sender has received
		currentContractAllowance = tokenReward.allowance(beneficiary, this);		//Updates contract allowance
		if (!afterFirstWithdrawal && ((tokensIssued != initialContractAllowance - currentContractAllowance) ||  (amountRaised != this.balance))) { _activateFailSafe(); }	//Check tokens issued and ether received, activates fail-safe in mismatch
		TokenPurchase(msg.sender, msg.value, msg.value * price);	//Event to inform about the purchase
		if (afterFirstWithdrawal) {	//If after first withdrawal, the ether will be sent immediately to the beneficiary
			if(beneficiary.send(msg.value)) { FundWithdrawal(beneficiary, msg.value, true); } //If fails, return false and the ether will remain in the contract
		}
	}

	function enablePurchase() onlyOwner() public {
		require(!failSafeMode);		//Can't enable purchase after Fail-Safe activates
		require(!purchasingAllowed);//Require purchasingAllowed = false
		purchasingAllowed = true;	//Contract must be deployed with purchasingAllowed = false
		PurchasingAllowed(true);
		if (!allowanceSetted) {		//Set the initial and current contract allowance
			require(tokenReward.allowance(beneficiary, this) > 0);	//Changing allowance before the first withdrawal activates Fail-Safe
			initialContractAllowance = tokenReward.allowance(beneficiary, this);
			currentContractAllowance = initialContractAllowance;
			allowanceSetted = true;
		}
	}

	function disablePurchase() onlyOwner() public {
		require(purchasingAllowed);	//Require purchasingAllowed = true
		purchasingAllowed = false;
		PurchasingAllowed(false);
	}

	function Withdrawal() public returns (bool sucess) {
		if (!failSafeMode) {	//If NOT in Fail-Safe
			require((now >= deadline) || (100*currentContractAllowance/initialContractAllowance <= 5));	//Require after deadline or 95% of the tokens sold
			require(msg.sender == beneficiary);	//Only the beneficiary can withdrawal if NOT in Fail-Safe
			if (!afterFirstWithdrawal) {
				if (beneficiary.send(amountRaised)) {
					afterFirstWithdrawal = true;
					FundWithdrawal(beneficiary, amountRaised, true);
					return true;
				} else {	//Executed if amountRaised's withdrawal fails
					errorCount += 1;
					if (errorCount >= 3) {	//If amountRaised's withdrawal fail 3 times, activates Fail-Safe
						_activateFailSafe();
						return false;	//'return false' cause it's an error function
					} else { return false; }	//If errorCount < 3
				}
			} else {	//If 'afterFirstWithdrawal == true' transfer current contract balance to beneficiary
				_etherAmount = this.balance;
				beneficiary.transfer(_etherAmount);
				FundWithdrawal(beneficiary, _etherAmount, true);
				return true;
			}
		} else {	//If in Fail-Safe mode
			if((now > reclaimForgottenEtherDeadline) && (msg.sender == beneficiary)) {	//Reclaim forgotten ethers sub-function
				_etherAmount = this.balance;
				beneficiary.transfer(_etherAmount);	//Send ALL contract's ether to beneficiary, throws on failure
				FundWithdrawal(beneficiary, _etherAmount, true);
				return true;
			} else {	//If the conditions to the 'reclaim forgotten ether' sub-function is not met
				require(balanceOf[msg.sender] > 0);
				require(etherBalanceOf[msg.sender] > 0);
				require(this.balance > 0 );	//Can't return ether if there is no ether on the contract
				require(tokenReward.balanceOf(msg.sender) >= balanceOf[msg.sender]);	//Check if msg.sender has the tokens he bought
				require(tokenReward.allowance(msg.sender, this) >= balanceOf[msg.sender]);	//Check if the contract is authorized to return the tokens
				require(tokenReward.transferFrom(msg.sender, tokenHolder, balanceOf[msg.sender])); 	//Tranfer the tokens back to the beneficiary
				if(this.balance >= etherBalanceOf[msg.sender]) {	//If the contract has not enough either, it will send all it can
					_etherAmount = etherBalanceOf[msg.sender];
				} else { _etherAmount = this.balance; }				//Which is all the contract's balance
				balanceOf[msg.sender] = 0;			// Mitigates Re-Entrancy call
				etherBalanceOf[msg.sender] = 0;		// Mitigates Re-Entrancy call
				msg.sender.transfer(_etherAmount);	//.transfer throws on failure, witch will revert even the variable changes
				FundWithdrawal(msg.sender, _etherAmount, false);	//Call the event to inform the withdrawal
				return true;
			}
		}
	}

	function _currentTokenRewardCalculator() internal view returns (uint256) {	//Increases the reward according to the discount
		if (now <= crowdsaleStartTime + 6 hours) { return originalTokenReward + (originalTokenReward * 70 / 100); }
		if (now <= crowdsaleStartTime + 12 hours) { return originalTokenReward + (originalTokenReward * 60 / 100); }
		if (now <= crowdsaleStartTime + 48 hours) { return originalTokenReward + (originalTokenReward * 50 / 100); }
		if (now <= crowdsaleStartTime + 7 days) { return originalTokenReward + (originalTokenReward * 30 / 100); }
		if (now <= crowdsaleStartTime + 14 days) { return originalTokenReward + (originalTokenReward * 10 / 100); }
		if (now > crowdsaleStartTime + 14 days) { return originalTokenReward; }
	}

	function _activateFailSafe() internal returns (bool) {
		if(afterFirstWithdrawal) { return false; }	//Fail-Safe can NOT be activated after First Withdrawal
		if(failSafeMode) { return false; }			//Fail-Safe can NOT be activated twice (right?)
		currentContractAllowance = 0;
		purchasingAllowed = false;
		failSafeMode = true;
		ExecutionError("Critical error");
		FailSafeActivated(true);
		return true;
	}

	// Call Functions
	function name() public constant returns (string) { return name; }
	function tokenBalanceOf(address _owner) public constant returns (uint256 tokensBoughtAtCrowdsale) { return balanceOf[_owner]; }
	function etherContributionOf(address _owner) public constant returns (uint256 amountContributedAtTheCrowdsaleInWei) { return etherBalanceOf[_owner]; }
	function currentPrice() public constant returns (uint256 currentTokenRewardPer1EtherContributed) { return (_currentTokenRewardCalculator()); }
	function discount() public constant returns (uint256 currentDiscount) { return ((100*_currentTokenRewardCalculator()/originalTokenReward) - 100); }
	function remainingTokens() public constant returns (uint256 tokensStillOnSale) { return currentContractAllowance; }
	function crowdsaleStarted() public constant returns (bool isCrowdsaleStarted) { if (now >= crowdsaleStartTime) { return true; } else { return false; } }
	function reclaimEtherDeadline() public constant returns (uint256 deadlineToReclaimEtherIfFailSafeWasActivated) { return reclaimForgottenEtherDeadline; }
}