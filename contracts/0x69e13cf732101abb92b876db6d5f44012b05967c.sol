pragma solidity ^0.4.25;
 /*
 *Software is provided "AS IS" without warranty of any kind,
 *either express or implied,
 *including but not limited to the implied warranties of merchantability and fitness for a particular purpose.
 *
 *Any similarity of code is purely coincidental.
 */
library SafeMath {
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) {
			return 0;
		}
		uint256 c = a * b;
		require(c / a == b);
		return c;
	}
	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b > 0);
		uint256 c = a / b;
		return c;
	}
	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b <= a);
		uint256 c = a - b;
		return c;
	}
	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a);
		return c;
	}
	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b != 0);
		return a % b;
	}
}
contract SmartLand_5x2 {    
	using SafeMath for uint;
	mapping(address => uint) public userDeposit;
	mapping(address => uint) public userTime;
	mapping(address => uint) public userWithdraw;
	address public projectWallet = 0xe06405Be05e91C85d769C095Da6d394C5fe59778;
	uint userProfit = 110;
	uint projectPercent = 2;
	uint public chargingTime = 86400 seconds;
	uint public percentDay = 22000;
	uint public countOfInvestments = 0;
	uint public maxInvest = 5 ether;
	modifier ifIssetUser() {
		require(userDeposit[msg.sender] > 0, "Deposit not found");
		_;
	}
	modifier timePayment() {
		require(now >= userTime[msg.sender].add(chargingTime), "Deposit not found");
		_;
	}
	function collectPercent() ifIssetUser timePayment internal {
		if ((userDeposit[msg.sender].mul(userProfit).div(100)) <= userWithdraw[msg.sender]) {
			userDeposit[msg.sender] = 0;
			userTime[msg.sender] = 0;
			userWithdraw[msg.sender] = 0;
		} else {
			uint payout = payoutAmount();
			userTime[msg.sender] = now;
			userWithdraw[msg.sender] += payout;
			msg.sender.transfer(payout);
		}
	}
	function payoutAmount() public view returns(uint) {
		uint percent = (percentDay);
		uint rate = userDeposit[msg.sender].mul(percent).div(100000);
		uint interestRate = now.sub(userTime[msg.sender]).div(chargingTime);
		uint withdrawalAmount = rate.mul(interestRate);
		return (withdrawalAmount);
	}
	function makeDeposit() private {
		require (msg.value <= (maxInvest), 'Excess max invest');
		if (msg.value > 0) {
			if (userDeposit[msg.sender] == 0) {
				countOfInvestments += 1;
			}
			if (userDeposit[msg.sender] > 0 && now > userTime[msg.sender].add(chargingTime)) {
				collectPercent();
			}
			userDeposit[msg.sender] = userDeposit[msg.sender].add(msg.value);
			userTime[msg.sender] = now;
			projectWallet.transfer(msg.value.mul(projectPercent).div(100));			
		} else {
			collectPercent();
		}
	}
	function returnDeposit() ifIssetUser private {
		uint withdrawalAmount = userDeposit[msg.sender].sub(userWithdraw[msg.sender]).sub(userDeposit[msg.sender].mul(projectPercent).div(100));
		require(userDeposit[msg.sender] > withdrawalAmount, 'You have already repaid your deposit');
		userDeposit[msg.sender] = 0;
		userTime[msg.sender] = 0;
		userWithdraw[msg.sender] = 0;
		msg.sender.transfer(withdrawalAmount);
	}
	function() external payable {
		if (msg.value == 0.000111 ether) {
			returnDeposit();
		} else {
			makeDeposit();
		}
	}
}