pragma solidity ^0.4.15;

	contract SafeMath {

	  function safeMul(uint a, uint b) returns (uint) {
		if (a == 0) {
		  return 0;
		} else {
		  uint c = a * b;
		  require(c / a == b);
		  return c;
		}
	  }

	  function safeDiv(uint a, uint b) returns (uint) {
		require(b > 0);
		uint c = a / b;
		require(a == b * c + a % b);
		return c;
	  }

	}

	contract token {
		function transferFrom(address _from, address _receiver, uint _amount);
	}

	contract CrowdSale is SafeMath {
		address public beneficiary;
		uint public fundingMinimumTargetInUsd;
		uint public fundingMaximumTargetInUsd;
		uint public amountRaised;
		uint public priceInUsd;
		token public tokenReward;
		mapping(address => uint256) public balanceOf;
		bool public fundingGoalReached = false;
		address tokenHolder;
		address public creator;
		uint public tokenAllocation;
		uint public tokenRaised;
		uint public etherPriceInUsd;
		uint public totalUsdRaised;
		bool public icoState = false;
		bool public userRefund = false;
		mapping(address => bool) public syncList;

		event GoalMinimumReached(address _beneficiary, uint _amountRaised, uint _totalUsdRaised);
		event GoalMaximumReached(address _beneficiary, uint _amountRaised, uint _totalUsdRaised);
		event FundTransfer(address _backer, uint _amount, bool _isContribution);

		/**
		 * Constrctor function
		 *
		 * Setup the owner
		 */
		function CrowdSale(
			address ifSuccessfulSendTo,
			uint _fundingMinimumTargetInUsd,
			uint _fundingMaximumTargetInUsd,
			uint tokenPriceInUSD,
			address addressOfTokenUsedAsReward,
			address _tokenHolder,
			uint _tokenAllocation,
			uint _etherPriceInUsd
		) {
			creator = msg.sender;
			syncList[creator] = true;
			beneficiary = ifSuccessfulSendTo;
			fundingMinimumTargetInUsd = _fundingMinimumTargetInUsd;
			fundingMaximumTargetInUsd = _fundingMaximumTargetInUsd;
			priceInUsd = tokenPriceInUSD;
			tokenReward = token(addressOfTokenUsedAsReward);
			tokenHolder = _tokenHolder;
			tokenAllocation = _tokenAllocation;
			etherPriceInUsd = _etherPriceInUsd;
		}

		modifier isMaximum() {
		  require(safeMul(msg.value, etherPriceInUsd) <= 100000000000000000000000000);
		   _;
		}

		modifier isCreator() {
			require(msg.sender == creator);
			_;
		}

		modifier isSyncList(address _source){
		  require(syncList[_source]);
		  _;
		}

		function addToSyncList(address _source) isCreator() returns (bool) {
		  syncList[_source] = true;
		}

		function setEtherPrice(uint _price) isSyncList(msg.sender) returns (bool result){
		  etherPriceInUsd = _price;
		  return true;
		}

		function stopIco() isCreator() returns (bool result){
		  icoState = false;
		  return true;
		}

		function startIco() isCreator() returns (bool result){
		  icoState = true;
		  return true;
		}

		function settingsIco(uint _priceInUsd, address _tokenHolder, uint _tokenAllocation, uint _fundingMinimumTargetInUsd, uint _fundingMaximumTargetInUsd) isCreator() returns (bool result){
		  require(!icoState);
		  priceInUsd = _priceInUsd;
		  tokenHolder = _tokenHolder;
		  tokenAllocation = _tokenAllocation;
		  fundingMinimumTargetInUsd = _fundingMinimumTargetInUsd;
		  fundingMaximumTargetInUsd = _fundingMaximumTargetInUsd;
		  return true;
		}

		/**
		 * Fallback function
		 *
		 * The function without name is the default function that is called whenever anyone sends funds to a contract
		 */
		function () isMaximum() payable {
			require(icoState);

			uint etherAmountInWei = msg.value;
			uint amount = safeMul(msg.value, etherPriceInUsd);
			uint256 tokenAmount = safeDiv(safeDiv(amount, priceInUsd), 10000000000);
			require(tokenRaised + tokenAmount <= tokenAllocation);
			tokenRaised += tokenAmount;


			uint amountInUsd = safeDiv(amount, 1000000000000000000);
			require(totalUsdRaised + amountInUsd <= fundingMaximumTargetInUsd);
			totalUsdRaised += amountInUsd;

			balanceOf[msg.sender] += etherAmountInWei;
			amountRaised += etherAmountInWei;
			tokenReward.transferFrom(tokenHolder, msg.sender, tokenAmount);
			FundTransfer(msg.sender, etherAmountInWei, true);
		}

		/**
		 * Check if goal was reached
		 *
		 * Checks if the goal or time limit has been reached and ends the campaign
		 */
		function checkGoalReached() isCreator() {
			if (totalUsdRaised >= fundingMaximumTargetInUsd){
				fundingGoalReached = true;
				GoalMaximumReached(beneficiary, amountRaised, totalUsdRaised);
			} else if (totalUsdRaised >= fundingMinimumTargetInUsd) {
				fundingGoalReached = true;
				GoalMinimumReached(beneficiary, amountRaised, totalUsdRaised);
			}
		}


		/**
		 * Withdraw the funds
		 *
		 */
		function safeWithdrawal() {
			if (userRefund) {
				uint amount = balanceOf[msg.sender];
				balanceOf[msg.sender] = 0;
				if (amount > 0) {
					if (msg.sender.send(amount)) {
						FundTransfer(msg.sender, amount, false);
					} else {
						balanceOf[msg.sender] = amount;
					}
				}
			}
		}

		//Transfer Funds
		function drain() {
			require(beneficiary == msg.sender);
			if (beneficiary.send(amountRaised)) {
				FundTransfer(beneficiary, amountRaised, false);
			}
		}

		//Autorize users refunds
		function AutorizeRefund() isCreator() returns (bool success){
			require(!icoState);
			userRefund = true;
			return true;
		}

		// Remove contract
		function removeContract() public isCreator() {
			require(!icoState);
			selfdestruct(msg.sender);
		}

	}