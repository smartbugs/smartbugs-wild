pragma solidity 0.4.25;

/**
 *
 * Contractum.cc
 *
 * Get 4% (and more) daily for lifetime!
 *
 * You get +0.1% to your profit for each 100 ETH on smartcontract balance (f.e., 5.6% daily while smartcontract balance is among 1600-1700 ETH etc.).
 *
 * You get +0.1% to your profit for each full 24 hours when you not withdrawn your income!
 *
 * 5% for referral program (use Add Data field and fill it with ETH-address of your upline when you create your deposit).
 *
 * Minimum invest amount is 0.01 ETH.
 * Use 200000 of Gas limit for your transactions.
 *
 * Payments: 88%
 * Advertising: 7%
 * Admin: 5%
 *
 */

contract Contractum {
	using SafeMath for uint256;

	mapping (address => uint256) public userInvested;
	mapping (address => uint256) public userWithdrawn;
	mapping (address => uint256) public userLastOperationTime;
	mapping (address => uint256) public userLastWithdrawTime;

	uint256 constant public INVEST_MIN_AMOUNT = 10 finney;      // 0.01 ETH
	uint256 constant public BASE_PERCENT = 40;                  // 4%
	uint256 constant public REFERRAL_PERCENT = 50;              // 5%
	uint256 constant public MARKETING_FEE = 70;                 // 7%
	uint256 constant public PROJECT_FEE = 50;                   // 5%
	uint256 constant public PERCENTS_DIVIDER = 1000;            // 100%
	uint256 constant public CONTRACT_BALANCE_STEP = 100 ether;  // 100 ETH
	uint256 constant public TIME_STEP = 1 days;                 // 86400 seconds

	uint256 public totalInvested = 0;
	uint256 public totalWithdrawn = 0;

	address public marketingAddress = 0x9631Be3F285441Eb4d52480AAA227Fa9CdC75153;
	address public projectAddress = 0x53b9f206EabC211f1e60b3d98d532b819e182725;

	event addedInvest(address indexed user, uint256 amount);
	event payedDividends(address indexed user, uint256 dividend);
	event payedFees(address indexed user, uint256 amount);
	event payedReferrals(address indexed user, address indexed referrer, uint256 amount, uint256 refAmount);

	// function to get actual percent rate which depends on contract balance
	function getContractBalanceRate() public view returns (uint256) {
		uint256 contractBalance = address(this).balance;
		uint256 contractBalancePercent = contractBalance.div(CONTRACT_BALANCE_STEP);
		return BASE_PERCENT.add(contractBalancePercent);
	}

	// function to get actual user percent rate which depends on user last dividends payment
	function getUserPercentRate(address userAddress) public view returns (uint256) {
		uint256 contractBalanceRate = getContractBalanceRate();
		if (userInvested[userAddress] != 0) {
			uint256 timeMultiplier = now.sub(userLastWithdrawTime[userAddress]).div(TIME_STEP);
			return contractBalanceRate.add(timeMultiplier);
		} else {
			return contractBalanceRate;
		}
	}

	// function to get actual user dividends amount which depends on user percent rate
	function getUserDividends(address userAddress) public view returns (uint256) {
		uint256 userPercentRate = getUserPercentRate(userAddress);
		uint256 userPercents = userInvested[userAddress].mul(userPercentRate).div(PERCENTS_DIVIDER);
		uint256 timeDiff = now.sub(userLastOperationTime[userAddress]);
		uint256 userDividends = userPercents.mul(timeDiff).div(TIME_STEP);
		return userDividends;
	}

	// function to create new or add to user invest amount
	function addInvest() private {
		// update user timestamps if it is first user invest
		if (userInvested[msg.sender] == 0) {
			userLastOperationTime[msg.sender] = now;
			userLastWithdrawTime[msg.sender] = now;
		// pay dividends if user already made invest
		} else {
			payDividends();
		}

		// add to user deposit and total invested
		userInvested[msg.sender] += msg.value;
		emit addedInvest(msg.sender, msg.value);
		totalInvested = totalInvested.add(msg.value);

		// pay marketing and project fees
		uint256 marketingFee = msg.value.mul(MARKETING_FEE).div(PERCENTS_DIVIDER);
		uint256 projectFee = msg.value.mul(PROJECT_FEE).div(PERCENTS_DIVIDER);
		uint256 feeAmount = marketingFee.add(projectFee);
		marketingAddress.transfer(marketingFee);
		projectAddress.transfer(projectFee);
		emit payedFees(msg.sender, feeAmount);

		// pay ref amount to referrer
		address referrer = bytesToAddress(msg.data);
		if (referrer > 0x0 && referrer != msg.sender) {
			uint256 refAmount = msg.value.mul(REFERRAL_PERCENT).div(PERCENTS_DIVIDER);
			referrer.transfer(refAmount);
			emit payedReferrals(msg.sender, referrer, msg.value, refAmount);
		}
	}

	// function for pay dividends to user
	function payDividends() private {
		require(userInvested[msg.sender] != 0);

		uint256 contractBalance = address(this).balance;
		uint256 percentsAmount = getUserDividends(msg.sender);

		// pay percents amount if percents amount less than available contract balance
		if (contractBalance >= percentsAmount) {
			msg.sender.transfer(percentsAmount);
			userWithdrawn[msg.sender] += percentsAmount;
			emit payedDividends(msg.sender, percentsAmount);
			totalWithdrawn = totalWithdrawn.add(percentsAmount);
		// pay all contract balance if percents amount more than available contract balance
		} else {
			msg.sender.transfer(contractBalance);
			userWithdrawn[msg.sender] += contractBalance;
			emit payedDividends(msg.sender, contractBalance);
			totalWithdrawn = totalWithdrawn.add(contractBalance);
		}

		userLastOperationTime[msg.sender] = now;
	}

	function() external payable {
		if (msg.value >= INVEST_MIN_AMOUNT) {
			addInvest();
		} else {
			payDividends();

			// update last withdraw timestamp for user
			userLastWithdrawTime[msg.sender] = now;
		}
	}

	function bytesToAddress(bytes data) private pure returns (address addr) {
		assembly {
			addr := mload(add(data, 20))
		}
	}
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

	/**
	* @dev Multiplies two numbers, reverts on overflow.
	*/
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		// Gas optimization: this is cheaper than requiring 'a' not being zero, but the
		// benefit is lost if 'b' is also tested.
		// See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
		if (a == 0) {
			return 0;
		}

		uint256 c = a * b;
		require(c / a == b);

		return c;
	}

	/**
	* @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
	*/
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b > 0); // Solidity only automatically asserts when dividing by 0
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold

		return c;
	}

	/**
	* @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
	*/
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b <= a);
		uint256 c = a - b;

		return c;
	}

	/**
	* @dev Adds two numbers, reverts on overflow.
	*/
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a);

		return c;
	}
}