pragma solidity 0.4.25;

/**
 * 
 *                                  ╔╗╔╗╔╗╔══╗╔╗──╔╗──╔══╗╔═══╗──╔╗──╔╗╔═══╗
 *                                  ║║║║║║║╔╗║║║──║║──╚╗╔╝║╔══╝──║║──║║║╔══╝
 *                                  ║║║║║║║╚╝║║║──║║───║║─║╚══╗──║╚╗╔╝║║╚══╗
 *                                  ║║║║║║║╔╗║║║──║║───║║─║╔══╝──║╔╗╔╗║║╔══╝
 *                                  ║╚╝╚╝║║║║║║╚═╗║╚═╗╔╝╚╗║╚══╗╔╗║║╚╝║║║╚══╗
 *                                  ╚═╝╚═╝╚╝╚╝╚══╝╚══╝╚══╝╚═══╝╚╝╚╝──╚╝╚═══╝
 *                                  ┌──────────────────────────────────────┐  
 *                                  │      Website:  http://wallie.me      │
 *                                  │                                      │  
 *                                  │  CN Telegram: https://t.me/WallieCH  │
 *                                  │  RU Telegram: https://t.me/wallieRU  |
 *                                  │  *  Telegram: https://t.me/WallieNews|
 *                                  |Twitter: https://twitter.com/Wallie_me|
 *                                  └──────────────────────────────────────┘ 
 *                    | Youtube – https://www.youtube.com/channel/UC1q3sPOlXsaJGrT8k-BZuyw |
 *
 *                                     * WALLIE - distribution contract *
 * 
 *  - Growth before 2000 ETH 1.1% and after 2000 ETH 1.2% in 24 hours
 * 
 * Distribution: *
 * - 10% Advertising, promotion
 * - 5% for developers and technical support
 * 
 * - Referral program:
 *   5% Level 1
 *   3% Level 2
 *   1% Level 3
 * 
 * - 3% Cashback
 * 
 *
 *
 * Usage rules *
 *  Holding:
 *   1. Send any amount of ether but not less than 0.01 ETH to make a contribution.
 *   2. Send 0 ETH at any time to get profit from the Deposit.
 *  
 *  - You can make a profit at any time. Consider your transaction costs (GAS).
 *  
 * Affiliate program *
 * - You have access to a multy-level referral system for additional profit (5%, 3%, 1% of the referral's contribution).
 * - Affiliate fees will come from each referral's Deposit as long as it doesn't change your wallet address Ethereum on the other.
 * 
 *  
 * 
 *
 * RECOMMENDED GAS LIMIT: 300000
 * RECOMMENDED GAS PRICE: https://ethgasstation.info/
 *
 * The contract has been tested for vulnerabilities!
 *
 */

contract Wallie
{
    //Investor
	mapping (address => Investor) public investors;

	//Event the new investor
	event NewInvestor(address _addr, uint256 _amount);

	//Event of the accrual of cashback bonus
	event CashbackBonus(address _addr, uint256 _amount, uint256 _revenue);

	//Referral bonus accrual event
	event RefererBonus(address _from, address _to, uint256 _amount, uint256 _revenue, uint256 _level);

	//New contribution event
	event NewInvestment(address _addr, uint256 _amount);

	//The event of the new withdrawal
	event NewWithdraw(address _addr, uint256 _amount);

	//The event of changes in the balance of the smart contract
	event ChangeBalance(uint256 _balance);

	struct Investor {
		//Member address
		address addr;
		//The address of the inviter
		address referer;
		//Deposit amount
		uint256 investment;
		//The time of the last contribution
		uint256 investment_time;
		//The time of the first contribution to the daily limit
		uint256 investment_first_time_in_day;
		//Deposit amount per day
		uint256 investments_daily;
		//Deposit income
		uint256 investment_profit;
		//Referral income
		uint256 referals_profit;
		//Cashback income
		uint256 cashback_profit;
		//Available balance income contributions
		uint256 investment_profit_balance;
		//Available referral income balance
		uint256 referals_profit_balance;
		//Available cashback income balance
		uint256 cashback_profit_balance;
	}

	//Percentage of daily charges before reaching the balance of 2000 ETH
	uint256 private constant dividends_perc_before_2000eth = 11;        // 1.1%
	//Percentage of daily charges after reaching the balance of 2000 ETH
	uint256 private constant dividends_perc_after_2000eth = 12;         // 1.2%
	//The percentage of the referral bonus of the first line
	uint256 public constant ref_bonus_level_1 = 5;                      // 5%
	//Second line referral bonus percentage
	uint256 public constant ref_bonus_level_2 = 3;                      // 3%
	//The percentage of referral bonus is the third line
	uint256 public constant ref_bonus_level_3 = 1;                      // 1%
	//Cashback bonus percentage
	uint256 public constant cashback_bonus = 3;                         // 3%
	//Minimum payment
	uint256 public constant min_invesment = 10 finney;                  // 0.01 eth
	//Deduction for advertising
	uint256 public constant advertising_fees = 15;                      // 15%
	//Limit to receive funds on the same day
	uint256 public constant contract_daily_limit = 100 ether;
	//Lock entry tools
	bool public block_investments = true;
	//The mode of payment
	bool public compensation = true;

	//Address smart contract first draft Wallie
	address first_project_addr = 0xC0B52b76055C392D67392622AE7737cdb6D42133;

	//Start time
	uint256 public start_time;
	//Current day
	uint256 current_day;
	//Launch day
	uint256 start_day;
	//Deposit amount per day
	uint256 daily_invest_to_contract;
	//The address of the owner
	address private adm_addr;
	//Starting block
	uint256 public start_block;
	//Project started
	bool public is_started = false;
	
	//Statistics
	//All investors
	uint256 private all_invest_users_count = 0;
	//Just introduced to the fund
	uint256 private all_invest = 0;
	//Total withdrawn from the fund
	uint256 private all_payments = 0;
	//The last address of the depositor
	address private last_invest_addr = 0;
	//The amount of the last contribution
	uint256 private last_invest_amount = 0;

	using SafeMath for uint;
    using ToAddress for *;
    using Zero for *;

constructor() public {
		adm_addr = msg.sender;
		current_day = 0;
		daily_invest_to_contract = 0;
	}

	//Current time
	function getTime() public view returns (uint256) {
		return (now);
	}

	//The creation of the account of the investor
	function createInvestor(address addr,address referer) private {
		investors[addr].addr = addr;
		if (investors[addr].referer.isZero()) {
			investors[addr].referer = referer;
		}
		all_invest_users_count++;
		emit NewInvestor(addr, msg.value);
	}

	//Check if there is an investor account
	function checkInvestor(address addr) public view returns (bool) {
		if (investors[addr].addr.isZero()) {
			return false;
		}
		else {
			return true;
		}
	}

	//Accrual of referral bonuses to the participant
	function setRefererBonus(address addr, uint256 amount, uint256 level_percent, uint256 level_num) private {
		if (addr.notZero()) {
			uint256 revenue = amount.mul(level_percent).div(100);

			if (!checkInvestor(addr)) {
				createInvestor(addr, address(0));
			}

			investors[addr].referals_profit = investors[addr].referals_profit.add(revenue);
			investors[addr].referals_profit_balance = investors[addr].referals_profit_balance.add(revenue);
			emit RefererBonus(msg.sender, addr, amount, revenue, level_num);
		}
	}

	//Accrual of referral bonuses to participants
	function setAllRefererBonus(address addr, uint256 amount) private {

		address ref_addr_level_1 = investors[addr].referer;
		address ref_addr_level_2 = investors[ref_addr_level_1].referer;
		address ref_addr_level_3 = investors[ref_addr_level_2].referer;

		setRefererBonus (ref_addr_level_1, amount, ref_bonus_level_1, 1);
		setRefererBonus (ref_addr_level_2, amount, ref_bonus_level_2, 2);
		setRefererBonus (ref_addr_level_3, amount, ref_bonus_level_3, 3);
	}

	//Get the number of dividends
	function calcDivedents (address addr) public view returns (uint256) {
		uint256 current_perc = 0;
		if (address(this).balance < 2000 ether) {
			current_perc = dividends_perc_before_2000eth;
		}
		else {
			current_perc = dividends_perc_after_2000eth;
		}

		return investors[addr].investment.mul(current_perc).div(1000).mul(now.sub(investors[addr].investment_time)).div(1 days);
	}

	//We transfer dividends to the participant's account
	function setDivedents(address addr) private returns (uint256) {
		investors[addr].investment_profit_balance = investors[addr].investment_profit_balance.add(calcDivedents(addr));
	}

	//We enroll the deposit
	function setAmount(address addr, uint256 amount) private {
		investors[addr].investment = investors[addr].investment.add(amount);
		investors[addr].investment_time = now;
		all_invest = all_invest.add(amount);
		last_invest_addr = addr;
		last_invest_amount = amount;
		emit NewInvestment(addr,amount);
	}

	//Cashback enrollment
	function setCashBackBonus(address addr, uint256 amount) private {
		if (investors[addr].referer.notZero() && investors[addr].investment == 0) {
			investors[addr].cashback_profit_balance = amount.mul(cashback_bonus).div(100);
			investors[addr].cashback_profit = investors[addr].cashback_profit.add(investors[addr].cashback_profit_balance);
			emit CashbackBonus(addr, amount, investors[addr].cashback_profit_balance);
		}
	}

	//Income payment
	function withdraw_revenue(address addr) private {
		uint256 withdraw_amount = calcDivedents(addr);
		
		if (check_x2_profit(addr,withdraw_amount) == true) {
		   withdraw_amount = 0; 
		}
		
		if (withdraw_amount > 0) {
		   investors[addr].investment_profit = investors[addr].investment_profit.add(withdraw_amount); 
		}
		
		withdraw_amount = withdraw_amount.add(investors[addr].investment_profit_balance).add(investors[addr].referals_profit_balance).add(investors[addr].cashback_profit_balance);
		

		if (withdraw_amount > 0) {
			clear_balance(addr);
			all_payments = all_payments.add(withdraw_amount);
			emit NewWithdraw(addr, withdraw_amount);
			emit ChangeBalance(address(this).balance.sub(withdraw_amount));
			addr.transfer(withdraw_amount);
		}
	}

	//Reset user balances
	function clear_balance(address addr) private {
		investors[addr].investment_profit_balance = 0;
		investors[addr].referals_profit_balance = 0;
		investors[addr].cashback_profit_balance = 0;
		investors[addr].investment_time = now;
	}

	//Checking the x2 profit
	function check_x2_profit(address addr, uint256 dividends) private returns(bool) {
		if (investors[addr].investment_profit.add(dividends) > investors[addr].investment.mul(2)) {
		    investors[addr].investment_profit_balance = investors[addr].investment.mul(2).sub(investors[addr].investment_profit);
			investors[addr].investment = 0;
			investors[addr].investment_profit = 0;
			investors[addr].investment_first_time_in_day = 0;
			investors[addr].investment_time = 0;
			return true;
		}
		else {
		    return false;
		}
	}

	function() public payable
	isStarted
	rerfererVerification
	isBlockInvestments
	minInvest
	allowInvestFirstThreeDays
	setDailyInvestContract
	setDailyInvest
	maxInvestPerUser
	maxDailyInvestPerContract
	setAdvertisingComiss {

		if (msg.value == 0) {
			//Request available payment
			withdraw_revenue(msg.sender);
		}
		else
		{
			//Contribution
			address ref_addr = msg.data.toAddr();

			//Check if there is an account
			if (!checkInvestor(msg.sender)) {
				//Создаем аккаунт пользователя
				createInvestor(msg.sender,ref_addr);
			}

			//Transfer of dividends on Deposit
			setDivedents(msg.sender);

			//Accrual of cashback
			setCashBackBonus(msg.sender, msg.value);

			//Deposit enrollment
			setAmount(msg.sender, msg.value);

			//Crediting bonuses to referrers
			setAllRefererBonus(msg.sender, msg.value);
		}
	}

	//Current day
	function today() public view returns (uint256) {
		return now.div(1 days);
	}

	//Prevent accepting deposits
	function BlockInvestments() public onlyOwner {
		block_investments = true;
	}

	//To accept deposits
	function AllowInvestments() public onlyOwner {
		block_investments = false;
	}
	
	//Disable compensation mode
	function DisableCompensation() public onlyOwner {
		compensation = false;
	}

	//Run the project
	function StartProject() public onlyOwner {
		require(is_started == false, "Project is started");
		block_investments = false;
		start_block = block.number;
		start_time = now;
		start_day = today();
		is_started = true;
	}
	
	//Investor account statistics
	function getInvestorInfo(address addr) public view returns (address, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
		Investor memory investor_info = investors[addr];
		return (investor_info.referer,
		investor_info.investment,
		investor_info.investment_time,
		investor_info.investment_first_time_in_day,
		investor_info.investments_daily,
		investor_info.investment_profit,
		investor_info.referals_profit,
		investor_info.cashback_profit,
		investor_info.investment_profit_balance,
		investor_info.referals_profit_balance,
		investor_info.cashback_profit_balance);
	}
	
	//The stats for the site
    function getWebStats() public view returns (uint256,uint256,uint256,uint256,address,uint256){
    return (all_invest_users_count,address(this).balance,all_invest,all_payments,last_invest_addr,last_invest_amount); 
    }

	//Check the start of the project
	modifier isStarted() {
		require(is_started == true, "Project not started");
		_;
	}

	//Checking deposit block
	modifier isBlockInvestments()
	{
		if (msg.value > 0) {
			require(block_investments == false, "investments is blocked");
		}
		_;
	}

	//Counting the number of user deposits per day
	modifier setDailyInvest() {
		if (now.sub(investors[msg.sender].investment_first_time_in_day) < 1 days) {
			investors[msg.sender].investments_daily = investors[msg.sender].investments_daily.add(msg.value);
		}
		else {
			investors[msg.sender].investments_daily = msg.value;
			investors[msg.sender].investment_first_time_in_day = now;
		}
		_;
	}

	//The maximum amount of contributions a user per day
	modifier maxInvestPerUser() {
		if (now.sub(start_time) <= 30 days) {
			require(investors[msg.sender].investments_daily <= 20 ether, "max payment must be <= 20 ETH");
		}
		else{
			require(investors[msg.sender].investments_daily <= 50 ether, "max payment must be <= 50 ETH");
		}
		_;
	}

	//Maximum amount of all deposits per day
	modifier maxDailyInvestPerContract() {
		if (now.sub(start_time) <= 30 days) {
			require(daily_invest_to_contract <= contract_daily_limit, "all daily invest to contract must be <= 100 ETH");
		}
		_;
	}

	//Minimum deposit amount
	modifier minInvest() {
		require(msg.value == 0 || msg.value >= min_invesment, "amount must be = 0 ETH or > 0.01 ETH");
		_;
	}

	//Calculation of the total number of deposits per day
	modifier setDailyInvestContract() {
		uint256 day = today();
		if (current_day == day) {
			daily_invest_to_contract = daily_invest_to_contract.add(msg.value);
		}
		else {
			daily_invest_to_contract = msg.value;
			current_day = day;
		}
		_;
	}

	//Permission for users of the previous project whose payments were <= 30% to make a contribution in the first 3 days
	modifier allowInvestFirstThreeDays() {
		if (now.sub(start_time) <= 3 days && compensation == true) {
			uint256 invested = WallieFirstProject(first_project_addr).invested(msg.sender);

			require(invested > 0, "invested first contract must be > 0");

			uint256 payments = WallieFirstProject(first_project_addr).payments(msg.sender);

			uint256 payments_perc = payments.mul(100).div(invested);

			require(payments_perc <= 30, "payments first contract must be <= 30%");
		}
		_;
	}

	//Verify the date field
	modifier rerfererVerification() {
		address ref_addr = msg.data.toAddr();
		if (ref_addr.notZero()) {
			require(msg.sender != ref_addr, "referer must be != msg.sender");
			require(investors[ref_addr].referer != msg.sender, "referer must be != msg.sender");
		}
		_;
	}

	//Only the owner
	modifier onlyOwner() {
		require(msg.sender == adm_addr,"onlyOwner!");
		_;
	}

	//Payment of remuneration for advertising
	modifier setAdvertisingComiss() {
		if (msg.sender != adm_addr && msg.value > 0) {
			investors[adm_addr].referals_profit_balance = investors[adm_addr].referals_profit_balance.add(msg.value.mul(advertising_fees).div(100));
		}
		_;
	}

}

//The interface of the first draft (the amount of deposits and amount of payments)
contract WallieFirstProject {

	mapping (address => uint256) public invested;

	mapping (address => uint256) public payments;
}

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

	/**
	* @dev Divides two numbers and returns the remainder (unsigned integer modulo),
	* reverts when dividing by zero.
	*/
	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		require(b != 0);
		return a % b;
	}
}

library ToAddress
{
	function toAddr(uint source) internal pure returns(address) {
		return address(source);
	}

	function toAddr(bytes source) internal pure returns(address addr) {
		assembly { addr := mload(add(source,0x14)) }
		return addr;
	}
}

library Zero
{
	function requireNotZero(uint a) internal pure {
		require(a != 0, "require not zero");
	}

	function requireNotZero(address addr) internal pure {
		require(addr != address(0), "require not zero address");
	}

	function notZero(address addr) internal pure returns(bool) {
		return !(addr == address(0));
	}

	function isZero(address addr) internal pure returns(bool) {
		return addr == address(0);
	}
}