pragma solidity ^ 0.4.24;

// File: openzeppelin-solidity/contracts/math/SafeMath.sol
/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

	/**
	 * @dev Multiplies two numbers, reverts on overflow.
	 */
	function mul(uint256 a, uint256 b) internal pure returns(uint256) {
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
	function div(uint256 a, uint256 b) internal pure returns(uint256) {
		require(b > 0); // Solidity only automatically asserts when dividing by 0
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold

		return c;
	}

	/**
	 * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
	 */
	function sub(uint256 a, uint256 b) internal pure returns(uint256) {
		require(b <= a);
		uint256 c = a - b;

		return c;
	}

	/**
	 * @dev Adds two numbers, reverts on overflow.
	 */
	function add(uint256 a, uint256 b) internal pure returns(uint256) {
		uint256 c = a + b;
		require(c >= a);

		return c;
	}

	/**
	 * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
	 * reverts when dividing by zero.
	 */
	function mod(uint256 a, uint256 b) internal pure returns(uint256) {
		require(b != 0);
		return a % b;
	}
}

/**
 * @title BaseAccessControl
 * @dev Basic control permissions are setting here
 */
contract BaseAccessControl {

	address public ceo;
	address public coo;
	address public cfo;

	constructor() public {
		ceo = msg.sender;
		coo = msg.sender;
		cfo = msg.sender;
	}

	/** roles modifer */
	modifier onlyCEO() {
		require(msg.sender == ceo, "CEO Only");
		_;
	}
	modifier onlyCOO() {
		require(msg.sender == coo, "COO Only");
		_;
	}
	modifier onlyCFO() {
		require(msg.sender == cfo, "CFO Only");
		_;
	}
	modifier onlyCLevel() {
		require(msg.sender == ceo || msg.sender == coo || msg.sender == cfo, "CLevel Only");
		_;
	}
	/** end modifier */

	/** util modifer */
	modifier required(address addr) {
		require(addr != address(0), "Address is required.");
		_;
	}
	modifier onlyHuman(address addr) {
		uint256 codeLength;
		assembly {
			codeLength: = extcodesize(addr)
		}
		require(codeLength == 0, "Humans only");
		_;
	}
	modifier onlyContract(address addr) {
		uint256 codeLength;
		assembly {
			codeLength: = extcodesize(addr)
		}
		require(codeLength > 0, "Contracts only");
		_;
	}
	/** end util modifier */

	/** setter */
	function setCEO(address addr) external onlyCEO() required(addr) onlyHuman(addr) {
		ceo = addr;
	}

	function setCOO(address addr) external onlyCEO() required(addr) onlyHuman(addr) {
		coo = addr;
	}

	function setCFO(address addr) external onlyCEO() required(addr) onlyHuman(addr) {
		cfo = addr;
	}
	/** end setter */
}

/**
 * @title MinerAccessControl
 * @dev Expanding the access control module for miner contract, especially for B1MP contract here
 */
contract MinerAccessControl is BaseAccessControl {

	address public companyWallet;

	bool public paused = false;

	/** modifer */
	modifier whenNotPaused() {
		require(!paused, "Paused");
		_;
	}
	modifier whenPaused() {
		require(paused, "Running");
		_;
	}
	/** end modifier */

	/** setter */
	function setCompanyWallet(address newCompanyWallet) external onlyCEO() required(newCompanyWallet) {
		companyWallet = newCompanyWallet;
	}

	function paused() public onlyCLevel() whenNotPaused() {
		paused = true;
	}

	function unpaused() external onlyCEO() whenPaused() {
		paused = false;
	}
	/** end setter */
}

/**
 * @title B1MPToken
 * @dev This contract is One-Minute Profit Option Contract.
 * And all users can get their one-minute profit option as a ERC721 token through this contract.
 * Even more, all users can exchange their one-minute profit option in the future.
 */
interface B1MPToken {
	function mintByTokenId(address to, uint256 tokenId) external returns(bool);
}

/**
 * @title B1MP
 * @dev This is the old B1MP contract.
 * Because of some problem, we have decided to migrate all data and use a new one contract.
 */
interface B1MP {
	function _global() external view returns(uint256 revenue, uint256 g_positionAmount, uint256 earlierPayoffPerPosition, uint256 totalRevenue);
	function _userAddrBook(uint256 index) external view returns(address addr);
	function _users(address addr) external view returns(uint256 id, uint256 positionAmount, uint256 earlierPayoffMask, uint256 lastRefId);
	function _invitations(address addr) external view returns(uint256 invitationAmount, uint256 invitationPayoff);
	function _positionBook(uint256 index1, uint256 index2) external view returns(uint256 minute);
	function _positionOnwers(uint256 minute) external view returns(address addr);
	function totalUsers() external view returns(uint256);
	function getUserPositionIds(address addr) external view returns(uint256[]);
}

/**
 * @title NewB1MP
 * @dev Because the old one has some problem, we re-devise the whole contract.
 * All actions, such as buying, withdrawing, and etc., are responding and recording by this contract.
 */
contract NewB1MP is MinerAccessControl {

	using SafeMath for * ;

	// the activity configurations
	struct Config {
		uint256 start; // the activity's start-time
		uint256 end; // the activity's end-time
		uint256 price; // the price of any one-minute profit option
		uint256 withdrawFee; // the basic fee for withdrawal request
		uint8 earlierPayoffRate; // the proportion of dividends to early buyers
		uint8 invitationPayoffRate; // the proportion of dividends to inviters
		uint256 finalPrizeThreshold; // the threshold for opening the final prize
		uint8[10] finalPrizeRates; // a group proportions for the final prize, the final selected proportion will be decided by some parameters
	}

	struct Global {
		uint256 revenue; // reserved revenue of the project holder
		uint256 positionAmount; // the total amount of minutes been sold
		uint256 earlierPayoffPerPosition; // the average dividends for every minute been sold before
		uint256 totalRevenue; // total amount of revenue
	}

	struct User {
		uint256 id; // user's id, equal to user's index + 1, increment
		uint256 positionAmount; // the total amount of minutes bought by this user
		uint256 earlierPayoffMask; // the pre-purchaser dividend that the user should not receive
		uint256 lastRefId; // the inviter's user-id
		uint256[] positionIds; // all position ids hold by this user
	}

	struct Invitation {
		uint256 amount; // how many people invited
		uint256 payoff; // how much payoff through invitation
	}

	B1MP public oldB1MPContract; // the old B1MP contract, just for data migration
	B1MPToken public tokenContract; // the one-minute profit option contract
	Config public _config; // configurations
	Global public _global; // globa info
	address[] public _userAddrBook; // users' addresses list, for registration
	mapping(address => User) public _users; // all users' detail info
	mapping(address => Invitation) public _invitations; // the invitations info

	uint256[2][] public _positionBook; // all positions list
	mapping(uint256 => address) public _positionOwners; // positionId (index + 1) => owner
	mapping(uint256 => address) public _positionMiners; // position minute => miner

	uint256 public _prizePool; // the pool of final prize
	uint256 public _prizePoolWithdrawn; // how much money been withdrawn through final prize pool
	bool public _isPrizeActivated; // whether the final prize is activated

	address[] public _winnerPurchaseListForAddr; // final prize winners list
	uint256[] public _winnerPurchaseListForPositionAmount; // the purchase history of final prize winners
	mapping(address => uint256) public _winnerPositionAmounts; // the total position amount of any final prize winner
	uint256 public _currentWinnerIndex; // the index of current winner, using for a looping array of all winners
	uint256 private _winnerCounter; // the total amount of final prize winners
	uint256 public _winnerTotalPositionAmount; // the total amount of positons bought by all final prize winners

	bool private _isReady; // whether the data migration has been completed
	uint256 private _userMigrationCounter; // how many users have been migrated

	/** modifer */
	modifier paymentLimit(uint256 ethVal) {
		require(ethVal > 0, "Too poor.");
		require(ethVal <= 100000 ether, "Too rich.");
		_;
	}
	modifier buyLimit(uint256 ethVal) {
		require(ethVal >= _config.price, 'Not enough.');
		_;
	}
	modifier withdrawLimit(uint256 ethVal) {
		require(ethVal == _config.withdrawFee, 'Not enough.');
		_;
	}
	modifier whenNotEnded() {
		require(_config.end == 0 || now < _config.end, 'Ended.');
		_;
	}
	modifier whenEnded() {
		require(_config.end != 0 && now >= _config.end, 'Not ended.');
		_;
	}
	modifier whenPrepare() {
		require(_config.end == 0, 'Started.');
		require(_isReady == false, 'Ready.');
		_;
	}
	modifier whenReady() {
		require(_isReady == true, 'Not ready.');
		_;
	}
	/** end modifier */

	// initialize
	constructor(address tokenAddr, address oldB1MPContractAddr) onlyContract(tokenAddr) onlyContract(oldB1MPContractAddr) public {
		// ready for migration
		oldB1MPContract = B1MP(oldB1MPContractAddr);
		_isReady = false;
		_userMigrationCounter = 0;
		// initialize base info
		tokenContract = B1MPToken(tokenAddr);
		_config = Config(1541993890, 0, 90 finney, 5 finney, 10, 20, 20000 ether, [
			5, 6, 7, 8, 10, 13, 15, 17, 20, 25
		]);
		_global = Global(0, 0, 0, 0);

		// ready for final prize
		_currentWinnerIndex = 0;
		_isPrizeActivated = false;
	}

	function migrateUserData(uint256 n) whenPrepare() onlyCEO() public {
		// intialize _userAddrBook & _users
		uint256 userAmount = oldB1MPContract.totalUsers();
		_userAddrBook.length = userAmount;
		// migrate n users per time
		uint256 lastMigrationNumber = _userMigrationCounter;
		for (_userMigrationCounter; _userMigrationCounter < userAmount && _userMigrationCounter < lastMigrationNumber + n; _userMigrationCounter++) {
			// A. get user address
			address userAddr = oldB1MPContract._userAddrBook(_userMigrationCounter);
			/// save to _userAddrBook
			_userAddrBook[_userMigrationCounter] = userAddr;
			// B. get user info
			(uint256 id, uint256 positionAmount, uint256 earlierPayoffMask, uint256 lastRefId) = oldB1MPContract._users(userAddr);
			uint256[] memory positionIds = oldB1MPContract.getUserPositionIds(userAddr);
			/// save to _users
			_users[userAddr] = User(id, positionAmount, earlierPayoffMask, lastRefId, positionIds);
			// C. get invitation info
			(uint256 invitationAmount, uint256 invitationPayoff) = oldB1MPContract._invitations(userAddr);
			/// save to _invitations
			_invitations[userAddr] = Invitation(invitationAmount, invitationPayoff);
			// D. get & save position info
			for (uint256 i = 0; i < positionIds.length; i++) {
				uint256 pid = positionIds[i];
				if (pid > 0) {
					if (pid > _positionBook.length) {
						_positionBook.length = pid;
					}
					uint256 pIndex = pid.sub(1);
					_positionBook[pIndex] = [oldB1MPContract._positionBook(pIndex, 0), oldB1MPContract._positionBook(pIndex, 1)];
					_positionOwners[pIndex] = userAddr;
				}
			}
		}
	}

	function migrateGlobalData() whenPrepare() onlyCEO() public {
		// intialize _global
		(uint256 revenue, uint256 g_positionAmount, uint256 earlierPayoffPerPosition, uint256 totalRevenue) = oldB1MPContract._global();
		_global = Global(revenue, g_positionAmount, earlierPayoffPerPosition, totalRevenue);
	}

	function depositeForMigration() whenPrepare() onlyCEO() public payable {
		require(_userMigrationCounter == oldB1MPContract.totalUsers(), 'Continue to migrate.');
		require(msg.value >= address(oldB1MPContract).balance, 'Not enough.');
		// update revenue, but don't update totalRevenue
		// because it's the dust of deposit, but not the revenue of sales
		// it will be not used for final prize
		_global.revenue = _global.revenue.add(msg.value.sub(address(oldB1MPContract).balance));
		_isReady = true;
	}

	function () whenReady() whenNotEnded() whenNotPaused() onlyHuman(msg.sender) paymentLimit(msg.value) buyLimit(msg.value) public payable {
		buyCore(msg.sender, msg.value, 0);
	}

	function buy(uint256 refId) whenReady() whenNotEnded() whenNotPaused() onlyHuman(msg.sender) paymentLimit(msg.value) buyLimit(msg.value) public payable {
		buyCore(msg.sender, msg.value, refId);
	}

	function buyCore(address addr_, uint256 revenue_, uint256 refId_) private {
		// 1. prepare some data
		uint256 _positionAmount_ = (revenue_).div(_config.price); // actual amount 
		uint256 _realCost_ = _positionAmount_.mul(_config.price);
		uint256 _invitationPayoffPart_ = _realCost_.mul(_config.invitationPayoffRate).div(100);
		uint256 _earlierPayoffPart_ = _realCost_.mul(_config.earlierPayoffRate).div(100);
		revenue_ = revenue_.sub(_invitationPayoffPart_).sub(_earlierPayoffPart_);
		uint256 _earlierPayoffMask_ = 0;

		// 2. register a new user
		if (_users[addr_].id == 0) {
			_userAddrBook.push(addr_); // add to user address list
			_users[addr_].id = _userAddrBook.length; // assign the user id, especially id = userAddrBook.index + 1
		}

		// 3. update global info
		if (_global.positionAmount > 0) {
			uint256 eppp = _earlierPayoffPart_.div(_global.positionAmount);
			_global.earlierPayoffPerPosition = eppp.add(_global.earlierPayoffPerPosition); // update global earlier payoff for per position
			revenue_ = revenue_.add(_earlierPayoffPart_.sub(eppp.mul(_global.positionAmount))); // the dust for this dividend
		} else {
			revenue_ = revenue_.add(_earlierPayoffPart_); // no need to dividend, especially for first one
		}
		// update the total position amount
		_global.positionAmount = _positionAmount_.add(_global.positionAmount);
		// calculate the current user's earlier payoff mask for this tx
		_earlierPayoffMask_ = _positionAmount_.mul(_global.earlierPayoffPerPosition);

		// 4. update referral data
		if (refId_ <= 0 || refId_ > _userAddrBook.length || refId_ == _users[addr_].id) { // the referrer doesn't exist, or is clien self
			refId_ = _users[addr_].lastRefId;
		} else if (refId_ != _users[addr_].lastRefId) {
			_users[addr_].lastRefId = refId_;
		}
		// update referrer's invitation info if he exists
		if (refId_ != 0) {
			address refAddr = _userAddrBook[refId_.sub(1)];
			// modify old one or create a new on if it doesn't exist
			_invitations[refAddr].amount = (1).add(_invitations[refAddr].amount); // update invitation amount
			_invitations[refAddr].payoff = _invitationPayoffPart_.add(_invitations[refAddr].payoff); // update invitation payoff
		} else {
			revenue_ = revenue_.add(_invitationPayoffPart_); // no referrer
		}

		// 5. update user info
		_users[addr_].positionAmount = _positionAmount_.add(_users[addr_].positionAmount);
		_users[addr_].earlierPayoffMask = _earlierPayoffMask_.add(_users[addr_].earlierPayoffMask);
		// update user's positions details, and record the position
		_positionBook.push([_global.positionAmount.sub(_positionAmount_).add(1), _global.positionAmount]);
		_positionOwners[_positionBook.length] = addr_;
		_users[addr_].positionIds.push(_positionBook.length);

		// 6. archive revenue
		_global.revenue = revenue_.add(_global.revenue);
		_global.totalRevenue = revenue_.add(_global.totalRevenue);

		// 7. select 1% user for final prize when the revenue is more than final prize threshold
		if (_global.totalRevenue > _config.finalPrizeThreshold) {
			uint256 maxWinnerAmount = countWinners(); // the max amount of winners, 1% of total users
			// activate final prize module at least there are more than 100 users
			if (maxWinnerAmount > 0) {
				if (maxWinnerAmount > _winnerPurchaseListForAddr.length) {
					_winnerPurchaseListForAddr.length = maxWinnerAmount;
					_winnerPurchaseListForPositionAmount.length = maxWinnerAmount;
				}
				// get the last winner's address
				address lwAddr = _winnerPurchaseListForAddr[_currentWinnerIndex];
				if (lwAddr != address(0)) { // deal the last winner's info
					// deduct this purchase record's positions amount from total amount
					_winnerTotalPositionAmount = _winnerTotalPositionAmount.sub(_winnerPurchaseListForPositionAmount[_currentWinnerIndex]);
					// deduct the winner's position amount from  this winner's amount
					_winnerPositionAmounts[lwAddr] = _winnerPositionAmounts[lwAddr].sub(_winnerPurchaseListForPositionAmount[_currentWinnerIndex]);
					// this is the winner's last record
					if (_winnerPositionAmounts[lwAddr] == 0) {
						// delete the winner's info
						_winnerCounter = _winnerCounter.sub(1);
						delete _winnerPositionAmounts[lwAddr];
					}
				}
				// set the new winner's info, or update old winner's info
				// register a new winner
				if (_winnerPositionAmounts[msg.sender] == 0) {
					// add a new winner
					_winnerCounter = _winnerCounter.add(1);
				}
				// update total amount of winner's positions bought finally
				_winnerTotalPositionAmount = _positionAmount_.add(_winnerTotalPositionAmount);
				// update winner's position amount
				_winnerPositionAmounts[msg.sender] = _positionAmount_.add(_winnerPositionAmounts[msg.sender]);
				// directly reset the winner list
				_winnerPurchaseListForAddr[_currentWinnerIndex] = msg.sender;
				_winnerPurchaseListForPositionAmount[_currentWinnerIndex] = _positionAmount_;
				// move the index to next
				_currentWinnerIndex = _currentWinnerIndex.add(1);
				if (_currentWinnerIndex >= maxWinnerAmount) { // the max index = total amount - 1
					_currentWinnerIndex = 0; // start a new loop when the number of winners exceed over the max amount allowed
				}
			}
		}

		// 8. update end time
		_config.end = (now).add(2 days); // expand the end time for every tx
	}

	function redeemOptionContract(uint256 positionId, uint256 minute) whenReady() whenNotPaused() onlyHuman(msg.sender) public {
		require(_users[msg.sender].id != 0, 'Unauthorized.');
		require(positionId <= _positionBook.length && positionId > 0, 'Position Id error.');
		require(_positionOwners[positionId] == msg.sender, 'No permission.');
		require(minute >= _positionBook[positionId - 1][0] && minute <= _positionBook[positionId - 1][1], 'Wrong interval.');
		require(_positionMiners[minute] == address(0), 'Minted.');

		// record the miner
		_positionMiners[minute] = msg.sender;

		// mint this minute's token
		require(tokenContract.mintByTokenId(msg.sender, minute), "Mining Error.");
	}

	function activateFinalPrize() whenReady() whenEnded() whenNotPaused() onlyCOO() public {
		require(_isPrizeActivated == false, 'Activated.');
		// total revenue should be more than final prize threshold
		if (_global.totalRevenue > _config.finalPrizeThreshold) {
			// calculate the prize pool
			uint256 selectedfinalPrizeRatesIndex = _winnerCounter.mul(_winnerTotalPositionAmount).mul(_currentWinnerIndex).mod(_config.finalPrizeRates.length);
			_prizePool = _global.totalRevenue.mul(_config.finalPrizeRates[selectedfinalPrizeRatesIndex]).div(100);
			// deduct the final prize pool from the reserved revenue
			_global.revenue = _global.revenue.sub(_prizePool);
		}
		// maybe not enough to final prize
		_isPrizeActivated = true;
	}

	function withdraw() whenReady() whenNotPaused() onlyHuman(msg.sender) withdrawLimit(msg.value) public payable {
		_global.revenue = _global.revenue.add(msg.value); // archive withdrawal fee to revenue, but not total revenue which is for final prize

		// 1. deduct invitation payoff
		uint256 amount = _invitations[msg.sender].payoff;
		_invitations[msg.sender].payoff = 0; // clear the user's invitation payoff

		// 2. deduct earlier payoff
		uint256 ep = (_global.earlierPayoffPerPosition).mul(_users[msg.sender].positionAmount);
		amount = amount.add(ep.sub(_users[msg.sender].earlierPayoffMask));
		_users[msg.sender].earlierPayoffMask = ep; // reset the user's earlier payoff mask which include this withdrawal part

		// 3. get the user's final prize, and deduct it
		if (_isPrizeActivated == true && _winnerPositionAmounts[msg.sender] > 0 &&
			_winnerTotalPositionAmount > 0 && _winnerCounter > 0 && _prizePool > _prizePoolWithdrawn) {
			// calculate the user's prize amount
			uint256 prizeAmount = prize(msg.sender);
			// set the user withdrawal amount
			amount = amount.add(prizeAmount);
			// refresh withdrawal amount of prize pool
			_prizePoolWithdrawn = _prizePoolWithdrawn.add(prizeAmount);
			// clear the user's finally bought position amount, so clear the user's final prize
			clearPrize(msg.sender);
			_winnerCounter = _winnerCounter.sub(1);
		}

		// 4. send eth
		(msg.sender).transfer(amount);
	}

	function withdrawByCFO(uint256 amount) whenReady() whenNotPaused() onlyCFO() required(companyWallet) public {
		require(amount > 0, 'Payoff too samll.');
		uint256 max = _global.revenue;
		if (_isPrizeActivated == false) { // when haven't sent final prize
			// deduct the max final prize pool
			max = max.sub(_global.totalRevenue.mul(_config.finalPrizeRates[_config.finalPrizeRates.length.sub(1)]).div(100));
		}
		require(amount <= max, 'Payoff too big.');

		// deduct the withdrawal amount
		_global.revenue = _global.revenue.sub(amount);

		// send eth
		companyWallet.transfer(amount);
	}

	function withdrawByCFO(address addr) whenReady() whenNotPaused() onlyCFO() onlyContract(addr) required(companyWallet) public {
		// send all erc20
		require(IERC20(addr).transfer(companyWallet, IERC20(addr).balanceOf(this)));
	}

	function collectPrizePoolDust() whenReady() whenNotPaused() onlyCOO() public {
		// when final prize has been sent, and all winners have received prizes
		require(_isPrizeActivated == true, 'Not activited.');
		// collect the prize pool dust
		if (_winnerCounter == 0 || now > _config.end.add(180 days)) {
			_global.revenue = _global.revenue.add(_prizePool.sub(_prizePoolWithdrawn));
			_prizePoolWithdrawn = _prizePool;
		}
	}

	function totalUsers() public view returns(uint256) {
		return _userAddrBook.length;
	}

	function getUserAddress(uint256 id) public view returns(address userAddrRet) {
		if (id <= _userAddrBook.length && id > 0) {
			userAddrRet = _userAddrBook[id.sub(1)];
		}
	}

	function getUserPositionIds(address addr) public view returns(uint256[]) {
		return _users[addr].positionIds;
	}

	function countPositions() public view returns(uint256) {
		return _positionBook.length;
	}

	function getPositions(uint256 id) public view returns(uint256[2] positionsRet) {
		if (id <= _positionBook.length && id > 0) {
			positionsRet = _positionBook[id.sub(1)];
		}
	}

	function prize(address addr) public view returns(uint256) {
		if (_winnerTotalPositionAmount == 0 || _prizePool == 0) {
			return 0;
		}
		return _winnerPositionAmounts[addr].mul(_prizePool).div(_winnerTotalPositionAmount);
	}

	function clearPrize(address addr) private {
		delete _winnerPositionAmounts[addr];
	}

	function countWinners() public view returns(uint256) {
		return _userAddrBook.length.div(100);
	}

	function allWinners() public view returns(address[]) {
		return _winnerPurchaseListForAddr;
	}
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
	function totalSupply() external view returns(uint256);

	function balanceOf(address who) external view returns(uint256);

	function allowance(address owner, address spender)
	external view returns(uint256);

	function transfer(address to, uint256 value) external returns(bool);

	function approve(address spender, uint256 value)
	external returns(bool);

	function transferFrom(address from, address to, uint256 value)
	external returns(bool);

	event Transfer(
		address indexed from,
		address indexed to,
		uint256 value
	);

	event Approval(
		address indexed owner,
		address indexed spender,
		uint256 value
	);
}