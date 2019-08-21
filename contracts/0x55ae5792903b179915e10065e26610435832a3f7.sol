pragma solidity ^0.4.11;

contract owned {

	address public owner;

	function owned() {
		owner = msg.sender;
	}

	modifier onlyOwner {
		if (msg.sender != owner) throw;
		_;
	}

	function transferOwnership(address newOwner) onlyOwner {
		owner = newOwner;
	}
}

contract tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData); }

contract ICofounditToken {
	function mintTokens(address _to, uint256 _amount, string _reason);
	function totalSupply() constant returns (uint256 totalSupply);
}

contract CofounditICO is owned{

	uint256 public startBlock;
	uint256 public endBlock;
	uint256 public minEthToRaise;
	uint256 public maxEthToRaise;
	uint256 public totalEthRaised;
	address public multisigAddress;

	uint256 public icoSupply;
	uint256 public strategicReserveSupply;
	uint256 public cashilaTokenSupply;
	uint256 public iconomiTokenSupply;
	uint256 public coreTeamTokenSupply;

	ICofounditToken cofounditTokenContract;	
	mapping (address => bool) presaleContributorAllowance;
	uint256 nextFreeParticipantIndex;
	mapping (uint => address) participantIndex;
	mapping (address => uint256) participantContribution;

	uint256 usedIcoSupply;
	uint256 usedStrategicReserveSupply;
	uint256 usedCashilaTokenSupply;
	uint256 usedIconomiTokenSupply;
	uint256 usedCoreTeamTokenSupply;

	bool icoHasStarted;
	bool minTresholdReached;
	bool icoHasSucessfulyEnded;

	uint256 lastEthReturnIndex;
	mapping (address => bool) hasClaimedEthWhenFail;
	uint256 lastCfiIssuanceIndex;

	string icoStartedMessage = "Cofoundit is launching!";
	string icoMinTresholdReachedMessage = "Firing Stage 2!";
	string icoEndedSuccessfulyMessage = "Orbit achieved!";
	string icoEndedSuccessfulyWithCapMessage = "Leaving Earth orbit!";
	string icoFailedMessage = "Rocket crashed.";

	event ICOStarted(uint256 _blockNumber, string _message);
	event ICOMinTresholdReached(uint256 _blockNumber, string _message);
	event ICOEndedSuccessfuly(uint256 _blockNumber, uint256 _amountRaised, string _message);
	event ICOFailed(uint256 _blockNumber, uint256 _ammountRaised, string _message);
	event ErrorSendingETH(address _from, uint256 _amount);

	function CofounditICO(uint256 _startBlock, uint256 _endBlock, address _multisigAddress) {
		startBlock = _startBlock;
		endBlock = _endBlock;
		minEthToRaise = 4525 * 10**18;
		maxEthToRaise = 56565 * 10**18;
		multisigAddress = _multisigAddress;

		icoSupply =	 				125000000 * 10**18;
		strategicReserveSupply = 	125000000 * 10**18;
		cashilaTokenSupply = 		100000000 * 10**18;
		iconomiTokenSupply = 		50000000 * 10**18;
		coreTeamTokenSupply =		100000000 * 10**18;
	}

	// 	
	/* User accessible methods */ 	
	// 	

	/* Users send ETH and enter the crowdsale*/ 	
	function () payable { 		
		if (msg.value == 0) throw;  												// Check if balance is not 0 		
		if (icoHasSucessfulyEnded || block.number > endBlock) throw;				// Throw if ico has already ended 		
		if (!icoHasStarted){														// Check if this is the first transaction of ico 			
			if (block.number < startBlock){											// Check if ico should start 				
				if (!presaleContributorAllowance[msg.sender]) throw;				// Check if this address is part of presale contributors 			
			} 			
			else{																	// If ICO should start 				
				icoHasStarted = true;												// Set that ico has started 				
				ICOStarted(block.number, icoStartedMessage);						// Raise event 			
			} 		
		} 		
		if (participantContribution[msg.sender] == 0){ 								// Check if sender is a new user 			
			participantIndex[nextFreeParticipantIndex] = msg.sender;				// Add new user to participant data structure 			
			nextFreeParticipantIndex += 1; 		
		} 		
		if (maxEthToRaise > (totalEthRaised + msg.value)){							// Check if user sent to much eth 			
			participantContribution[msg.sender] += msg.value;						// Add accounts contribution 			
			totalEthRaised += msg.value;											// Add to total eth Raised 			
			if (!minTresholdReached && totalEthRaised >= minEthToRaise){			// Check if min treshold has been reached(Do that one time) 				
				ICOMinTresholdReached(block.number, icoMinTresholdReachedMessage);	// Raise event 				
				minTresholdReached = true;											// Set that treshold has been reached 			
			} 		
		}else{																		// If user sent to much eth 			
			uint maxContribution = maxEthToRaise - totalEthRaised; 					// Calculate max contribution 			
			participantContribution[msg.sender] += maxContribution;					// Add max contribution to account 			
			totalEthRaised += maxContribution;													
			uint toReturn = msg.value - maxContribution;							// Calculate how much user should get back 			
			icoHasSucessfulyEnded = true;											// Set that ico has successfullyEnded 			
			ICOEndedSuccessfuly(block.number, totalEthRaised, icoEndedSuccessfulyWithCapMessage); 			
			if(!msg.sender.send(toReturn)){											// Refound balance that is over the cap 				
				ErrorSendingETH(msg.sender, toReturn);								// Raise event for manual return if transaction throws 			
			} 		
		}																			// Feel good about achiving the cap 	
	} 	

	/* Users can claim eth by themself if they want to in instance of eth faliure*/ 	
	function claimEthIfFailed(){ 		
		if (block.number <= endBlock || totalEthRaised >= minEthToRaise) throw;	// Check that ico has failed :( 		
		if (participantContribution[msg.sender] == 0) throw;					// Check if user has even been at crowdsale 		
		if (hasClaimedEthWhenFail[msg.sender]) throw;							// Check if this account has already claimed its eth 		
		uint256 ethContributed = participantContribution[msg.sender];			// Get participant eth Contribution 		
		hasClaimedEthWhenFail[msg.sender] = true; 		
		if (!msg.sender.send(ethContributed)){ 			
			ErrorSendingETH(msg.sender, ethContributed);						// Raise event if send failed and resolve manually 		
		} 	
	} 	

	// 	
	/* Only owner methods */ 	
	// 	

	/* Adds addresses that are allowed to take part in presale */ 	
	function addPresaleContributors(address[] _presaleContributors) onlyOwner { 		
		for (uint cnt = 0; cnt < _presaleContributors.length; cnt++){ 			
			presaleContributorAllowance[_presaleContributors[cnt]] = true; 		
		} 	
	} 	

	/* Owner can issue new tokens in token contract */ 	
	function batchIssueTokens(uint256 _numberOfIssuances) onlyOwner{ 		
		if (!icoHasSucessfulyEnded) throw;																				// Check if ico has ended 		
		address currentParticipantAddress; 		
		uint256 tokensToBeIssued; 		
		for (uint cnt = 0; cnt < _numberOfIssuances; cnt++){ 			
			currentParticipantAddress = participantIndex[lastCfiIssuanceIndex];	// Get next participant address
			if (currentParticipantAddress == 0x0) continue; 			
			tokensToBeIssued = icoSupply * participantContribution[currentParticipantAddress] / totalEthRaised;		// Calculate how much tokens will address get 			
			cofounditTokenContract.mintTokens(currentParticipantAddress, tokensToBeIssued, "Ico participation mint");	// Mint tokens @ CofounditToken 			
			lastCfiIssuanceIndex += 1;	
		} 

		if (participantIndex[lastCfiIssuanceIndex] == 0x0 && cofounditTokenContract.totalSupply() < icoSupply){
			uint divisionDifference = icoSupply - cofounditTokenContract.totalSupply();
			cofounditTokenContract.mintTokens(multisigAddress, divisionDifference, "Mint division error");	// Mint divison difference @ CofounditToken so that total supply is whole number			
		}
	} 	

	/* Owner can return eth for multiple users in one call*/ 	
	function batchReturnEthIfFailed(uint256 _numberOfReturns) onlyOwner{ 		
		if (block.number < endBlock || totalEthRaised >= minEthToRaise) throw;		// Check that ico has failed :( 		
		address currentParticipantAddress; 		
		uint256 contribution;
		for (uint cnt = 0; cnt < _numberOfReturns; cnt++){ 			
			currentParticipantAddress = participantIndex[lastEthReturnIndex];		// Get next account 			
			if (currentParticipantAddress == 0x0) return;							// If all the participants were reinbursed return 			
			if (!hasClaimedEthWhenFail[currentParticipantAddress]) {				// Check if user has manually recovered eth 				
				contribution = participantContribution[currentParticipantAddress];	// Get accounts contribution 				
				hasClaimedEthWhenFail[msg.sender] = true;							// Set that user got his eth back 				
				if (!currentParticipantAddress.send(contribution)){					// Send fund back to account 					
					ErrorSendingETH(currentParticipantAddress, contribution);		// Raise event if send failed and resolve manually 				
				} 			
			} 			
			lastEthReturnIndex += 1; 		
		} 	
	} 	

	/* Owner sets new address of CofounditToken */
	function changeMultisigAddress(address _newAddress) onlyOwner { 		
		multisigAddress = _newAddress;
	} 	

	/* Owner can claim reserved tokens on the end of crowsale */ 	
	function claimReservedTokens(string _which, address _to, uint256 _amount, string _reason) onlyOwner{ 		
		if (!icoHasSucessfulyEnded) throw;                 
		bytes32 hashedStr = sha3(_which);				
		if (hashedStr == sha3("Reserve")){ 			
			if (_amount > strategicReserveSupply - usedStrategicReserveSupply) throw; 			
			cofounditTokenContract.mintTokens(_to, _amount, _reason); 			
			usedStrategicReserveSupply += _amount; 		
		} 		
		else if (hashedStr == sha3("Cashila")){ 			
			if (_amount > cashilaTokenSupply - usedCashilaTokenSupply) throw; 			
			cofounditTokenContract.mintTokens(_to, _amount, "Reserved tokens for cashila"); 			
			usedCashilaTokenSupply += _amount; 		} 		
		else if (hashedStr == sha3("Iconomi")){ 			
			if (_amount > iconomiTokenSupply - usedIconomiTokenSupply) throw; 			
			cofounditTokenContract.mintTokens(_to, _amount, "Reserved tokens for iconomi"); 			
			usedIconomiTokenSupply += _amount; 		
		}
		else if (hashedStr == sha3("Core")){ 			
			if (_amount > coreTeamTokenSupply - usedCoreTeamTokenSupply) throw; 			
			cofounditTokenContract.mintTokens(_to, _amount, "Reserved tokens for cofoundit team"); 			
			usedCoreTeamTokenSupply += _amount; 		
		} 		
		else throw; 	
	} 	

	/* Owner can remove allowance of designated presale contributor */ 	
	function removePresaleContributor(address _presaleContributor) onlyOwner { 		
		presaleContributorAllowance[_presaleContributor] = false; 	
	} 	

	/* Set token contract where mints will be done (tokens will be issued)*/ 	
	function setTokenContract(address _cofounditContractAddress) onlyOwner { 		
		cofounditTokenContract = ICofounditToken(_cofounditContractAddress); 	
	} 	

	/* Withdraw funds from contract */ 	
	function withdrawEth() onlyOwner{ 		
		if (this.balance == 0) throw;				// Check if there is something on the contract 		
		if (totalEthRaised < minEthToRaise) throw;	// Check if minEth treshold is surpassed 		
		if (block.number > endBlock){				// Check if ico has ended withouth reaching the maxCap 			
			icoHasSucessfulyEnded = true; 			
			ICOEndedSuccessfuly(block.number, totalEthRaised, icoEndedSuccessfulyMessage); 		
		} 		
		if(multisigAddress.send(this.balance)){}		// Send contracts whole balance to multisig address 	
	} 	

	/* Withdraw remaining balance to manually return where contracts send has failed */ 	
	function withdrawRemainingBalanceForManualRecovery() onlyOwner{ 		
		if (this.balance == 0) throw;											// Check if there is something on the contract 		
		if (block.number < endBlock || totalEthRaised >= minEthToRaise) throw;	// Check if ico has failed :( 		
		if (participantIndex[lastEthReturnIndex] != 0x0) throw;					// Check if all the participants has been reinbursed 		
		if(multisigAddress.send(this.balance)){}								// Send remainder so it can be manually processed 	
	} 	

	// 	
	/* Getters */ 	
	// 	

	function getCfiEstimation(address _querryAddress) constant returns (uint256 answer){ 		
		return icoSupply * participantContribution[_querryAddress] / totalEthRaised; 	
	} 	

	function getCofounditTokenAddress() constant returns(address _tokenAddress){ 		
		return address(cofounditTokenContract); 	
	} 	

	function icoInProgress() constant returns (bool answer){ 		
		return icoHasStarted && !icoHasSucessfulyEnded; 	
	} 	

	function isAddressAllowedInPresale(address _querryAddress) constant returns (bool answer){ 		
		return presaleContributorAllowance[_querryAddress]; 	
	} 	

	function participantContributionInEth(address _querryAddress) constant returns (uint256 answer){ 		
		return participantContribution[_querryAddress]; 	
	}

	//
	/* This part is here only for testing and will not be included into final version */
	//
	//function killContract() onlyOwner{
	//	selfdestruct(msg.sender);
	//}
}