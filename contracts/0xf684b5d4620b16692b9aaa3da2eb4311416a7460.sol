pragma solidity ^0.4.24;


library SafeMath {

	function mul (uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) {
			return 0;
		}
		uint256 c = a * b;
		assert(c / a == b);
		return c;
	}


	function div (uint256 a, uint256 b) internal pure returns (uint256) {

		return a / b;
	}


	function sub (uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
	}


	function add (uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
}


contract ERCBasic {
	event Transfer(address indexed from, address indexed to, uint256 value);

	function totalSupply () public view returns (uint256);
	function balanceOf (address who) public view returns (uint256);
	function transfer (address to, uint256 value) public returns (bool);
}


contract ERC is ERCBasic {
	event Approval(address indexed owner, address indexed spender, uint256 value);

	function transferFrom (address from, address to, uint256 value) public returns (bool);
	function allowance (address owner, address spender) public view returns (uint256);
	function approve (address spender, uint256 value) public returns (bool);
}


contract Ownable {
	event OwnershipTransferred(address indexed oldone, address indexed newone);

	address public owner;

	constructor () public {
		owner = msg.sender;
	}


	modifier onlyOwner () {
		require(msg.sender == owner);
		_;
	}


	function transferOwnership (address newOwner) public onlyOwner {
		require(newOwner != address(0));
		require(newOwner != owner);
		address oldOwner = owner;
		owner = newOwner;
		emit OwnershipTransferred(oldOwner, newOwner);
	}
}


contract Pausable is Ownable {
	event ContractPause();
	event ContractResume();

	bool public paused = false;

	modifier whenRunning () {
		require(!paused);
		_;
	}

	modifier whenPaused () {
		require(paused);
		_;
	}


	function pause () public onlyOwner whenRunning {
		paused = true;
		emit ContractPause();
	}


	function resume () public onlyOwner whenPaused {
		paused = false;
		emit ContractResume();
	}
}


contract TokenForge is Ownable {
	event ForgeStart();
	event ForgeStop();

	bool public forge_running = true;

	modifier canForge () {
		require(forge_running);
		_;
	}

	modifier cannotForge () {
		require(!forge_running);
		_;
	}


	function startForge () public onlyOwner cannotForge returns (bool) {
		forge_running = true;
		emit ForgeStart();
		return true;
	}


	function stopForge () public onlyOwner canForge returns (bool) {
		forge_running = false;
		emit ForgeStop();
		return true;
	}
}


contract CappedToken is Ownable {
	using SafeMath for uint256;

	uint256 public token_cap;
	uint256 public token_created;

	constructor (uint256 _cap) public {
		token_cap = _cap;
	}

	function changeCap (uint256 _cap) public onlyOwner returns (bool) {
		if (_cap < token_created && _cap > 0) return false;
		token_cap = _cap;
		return true;
	}

	function canMint (uint256 amount) public view returns (bool) {
		return (token_cap == 0) || (token_created.add(amount) <= token_cap);
	}
}


contract BasicToken is ERCBasic, Pausable {
	using SafeMath for uint256;

	mapping(address => uint256) public wallets;

	modifier canTransfer (address _from, address _to, uint256 amount) {
		require((_from != address(0)) && (_to != address(0)));
		require(_from != _to);
		require(amount > 0);
		_;
	}


	function balanceOf (address user) public view returns (uint256) {
		return wallets[user];
	}
}


contract DelegatableToken is ERC, BasicToken {
	using SafeMath for uint256;

	mapping(address => mapping(address => uint256)) public warrants;


	function allowance (address owner, address delegator) public view returns (uint256) {
		return warrants[owner][delegator];
	}


	function approve (address delegator, uint256 value) public whenRunning returns (bool) {
		if (delegator == msg.sender) return true;
		warrants[msg.sender][delegator] = value;
		emit Approval(msg.sender, delegator, value);
		return true;
	}


	function increaseApproval (address delegator, uint256 delta) public whenRunning returns (bool) {
		if (delegator == msg.sender) return true;
		uint256 value = warrants[msg.sender][delegator].add(delta);
		warrants[msg.sender][delegator] = value;
		emit Approval(msg.sender, delegator, value);
		return true;
	}


	function decreaseApproval (address delegator, uint256 delta) public whenRunning returns (bool) {
		if (delegator == msg.sender) return true;
		uint256 value = warrants[msg.sender][delegator];
		if (value < delta) {
			value = 0;
		}
		else {
			value = value.sub(delta);
		}
		warrants[msg.sender][delegator] = value;
		emit Approval(msg.sender, delegator, value);
		return true;
	}
}


contract LockableProtocol is BasicToken {
	function invest (address investor, uint256 amount) public returns (bool);
	function getInvestedToken (address investor) public view returns (uint256);
	function getReleasedToken (address investor) public view returns (uint256);
	function getLockedToken (address investor) public view returns (uint256);


	function availableWallet (address user) public view returns (uint256) {
		return wallets[user].sub(getLockedToken(user));
	}
}


contract MintAndBurnToken is BasicToken, TokenForge, CappedToken, LockableProtocol {
	using SafeMath for uint256;

	event Mint(address indexed user, uint256 amount);
	event Burn(address indexed user, uint256 amount);

	constructor (uint256 _initial, uint256 _cap) public CappedToken(_cap) {
		token_created = _initial;
		wallets[msg.sender] = _initial;

		emit Mint(msg.sender, _initial);
		emit Transfer(address(0), msg.sender, _initial);
	}


	function totalSupply () public view returns (uint256) {
		return token_created;
	}


	function mint (address target, uint256 amount) public onlyOwner whenRunning canForge returns (bool) {
		if (!canMint(amount)) return false;

		token_created = token_created.add(amount);
		wallets[target] = wallets[target].add(amount);

		emit Mint(target, amount);
		emit Transfer(address(0), target, amount);
		return true;
	}


	function burn (uint256 amount) public whenRunning canForge returns (bool) {
		uint256 balance = availableWallet(msg.sender);
		require(amount <= balance);

		token_created = token_created.sub(amount);
		wallets[msg.sender] -= amount;

		emit Burn(msg.sender, amount);
		emit Transfer(msg.sender, address(0), amount);

		return true;
	}


	function burnByOwner (address target, uint256 amount) public onlyOwner whenRunning canForge returns (bool) {
		uint256 balance = availableWallet(target);
		require(amount <= balance);

		token_created = token_created.sub(amount);
		wallets[target] -= amount;

		emit Burn(target, amount);
		emit Transfer(target, address(0), amount);

		return true;
	}
}


contract LockableToken is MintAndBurnToken, DelegatableToken {
	using SafeMath for uint256;

	struct LockBin {
		uint256 start;
		uint256 finish;
		uint256 duration;
		uint256 amount;
	}

	event InvestStart();
	event InvestStop();
	event NewInvest(uint256 invest_start, uint256 invest_finish, uint256 release_start, uint256 release_duration);

	uint256 public investStart;
	uint256 public investFinish;
	uint256 public releaseStart;
	uint256 public releaseDuration;
	bool public forceStopInvest;
	mapping(address => mapping(uint => LockBin)) public lockbins;

	modifier canInvest () {
		require(!forceStopInvest);
		require(now >= investStart && now <= investFinish);
		_;
	}

	constructor (uint256 _initial, uint256 _cap) public MintAndBurnToken(_initial, _cap) {
		forceStopInvest = true;
		investStart = now;
		investFinish = now;
	}


	function pauseInvest () public onlyOwner whenRunning returns (bool) {
		if (now < investStart || now > investFinish) return false;
		if (forceStopInvest) return false;
		forceStopInvest = true;
		emit InvestStop();
		return true;
	}


	function resumeInvest () public onlyOwner whenRunning returns (bool) {
		if (now < investStart || now > investFinish) return false;
		if (!forceStopInvest) return false;
		forceStopInvest = false;
		emit InvestStart();
		return true;
	}


	function setInvest (uint256 invest_start, uint256 invest_finish, uint256 release_start, uint256 release_duration) public onlyOwner whenRunning returns (bool) {
		require(now > investFinish);
		require(invest_start > now);

		investStart = invest_start;
		investFinish = invest_finish;
		releaseStart = release_start;
		releaseDuration = release_duration;
		forceStopInvest = false;

		emit NewInvest(invest_start, invest_finish, release_start, release_duration);
		return true;
	}


	function invest (address investor, uint256 amount) public onlyOwner whenRunning canInvest returns (bool) {
		require(investor != address(0));
		require(amount > 0);
		require(canMint(amount));

		token_created = token_created.add(amount);
		wallets[investor] = wallets[investor].add(amount);
		emit Mint(investor, amount);
		emit Transfer(address(0), investor, amount);

		mapping(uint => LockBin) locks = lockbins[investor];
		LockBin storage info = locks[0];
		uint index = info.amount + 1;
		locks[index] = LockBin({
			start: releaseStart,
			finish: releaseStart + releaseDuration,
			duration: releaseDuration / (1 days),
			amount: amount
		});
		info.amount = index;

		return true;
	}


	function batchInvest (address[] investors, uint256 amount) public onlyOwner whenRunning canInvest returns (bool) {
		require(amount > 0);

		uint investorsLength = investors.length;
		uint investorsCount = 0;
		uint i;
		address r;
		for (i = 0; i < investorsLength; i ++) {
			r = investors[i];
			if (r != address(0)) investorsCount ++;
		}
		require(investorsCount > 0);

		uint256 totalAmount = amount.mul(uint256(investorsCount));
		require(canMint(totalAmount));

		token_created = token_created.add(totalAmount);

		for (i = 0; i < investorsLength; i ++) {
			r = investors[i];
			if (r == address(0)) continue;
			wallets[r] = wallets[r].add(amount);
			emit Mint(r, amount);
			emit Transfer(address(0), r, amount);

			mapping(uint => LockBin) locks = lockbins[r];
			LockBin storage info = locks[0];
			uint index = info.amount + 1;
			locks[index] = LockBin({
				start: releaseStart,
				finish: releaseStart + releaseDuration,
				duration: releaseDuration / (1 days),
				amount: amount
			});
			info.amount = index;
		}

		return true;
	}


	function batchInvests (address[] investors, uint256[] amounts) public onlyOwner whenRunning canInvest returns (bool) {
		uint investorsLength = investors.length;
		require(investorsLength == amounts.length);

		uint investorsCount = 0;
		uint256 totalAmount = 0;
		uint i;
		address r;
		for (i = 0; i < investorsLength; i ++) {
			r = investors[i];
			if (r == address(0)) continue;
			investorsCount ++;
			totalAmount += amounts[i];
		}
		require(totalAmount > 0);
		require(canMint(totalAmount));

		uint256 amount;
		token_created = token_created.add(totalAmount);
		for (i = 0; i < investorsLength; i ++) {
			r = investors[i];
			if (r == address(0)) continue;
			amount = amounts[i];
			wallets[r] = wallets[r].add(amount);
			emit Mint(r, amount);
			emit Transfer(address(0), r, amount);

			mapping(uint => LockBin) locks = lockbins[r];
			LockBin storage info = locks[0];
			uint index = info.amount + 1;
			locks[index] = LockBin({
				start: releaseStart,
				finish: releaseStart + releaseDuration,
				duration: releaseDuration / (1 days),
				amount: amount
			});
			info.amount = index;
		}

		return true;
	}


	function getInvestedToken (address investor) public view returns (uint256) {
		mapping(uint => LockBin) locks = lockbins[investor];
		uint256 balance = 0;
		uint l = locks[0].amount;

		for (uint i = 1; i <= l; i ++) {
			LockBin memory bin = locks[i];
			balance = balance.add(bin.amount);
		}
		return balance;
	}


	function getLockedToken (address investor) public view returns (uint256) {
		mapping(uint => LockBin) locks = lockbins[investor];
		uint256 balance = 0;
		uint256 d = 1;
		uint l = locks[0].amount;

		for (uint i = 1; i <= l; i ++) {
			LockBin memory bin = locks[i];
			if (now <= bin.start) {
				balance = balance.add(bin.amount);
			}
			else if (now < bin.finish) {
				d = (now - bin.start) / (1 days);
				balance = balance.add(bin.amount - bin.amount * d / bin.duration);
			}
		}
		return balance;
	}


	function getReleasedToken (address investor) public view returns (uint256) {
		mapping(uint => LockBin) locks = lockbins[investor];
		uint256 balance = 0;
		uint256 d = 1;
		uint l = locks[0].amount;

		for (uint i = 1; i <= l; i ++) {
			LockBin memory bin = locks[i];
			if (now >= bin.finish) {
				balance = balance.add(bin.amount);
			}
			else if (now > bin.start) {
				d = (now - bin.start) / (1 days);
				balance = balance.add(bin.amount * d / bin.duration);
			}
		}
		return balance;
	}


	function canPay (address user, uint256 amount) internal view returns (bool) {
		uint256 balance = availableWallet(user);
		return amount <= balance;
	}


	function transfer (address target, uint256 value) public whenRunning canTransfer(msg.sender, target, value) returns (bool) {
		require(canPay(msg.sender, value));

		wallets[msg.sender] = wallets[msg.sender].sub(value);
		wallets[target] = wallets[target].add(value);
		emit Transfer(msg.sender, target, value);
		return true;
	}


	function batchTransfer (address[] receivers, uint256 amount) public whenRunning returns (bool) {
		require(amount > 0);

		uint receiveLength = receivers.length;
		uint receiverCount = 0;
		uint i;
		address r;
		for (i = 0; i < receiveLength; i ++) {
			r = receivers[i];
			if (r != address(0) && r != msg.sender) receiverCount ++;
		}
		require(receiverCount > 0);

		uint256 totalAmount = amount.mul(uint256(receiverCount));
		require(canPay(msg.sender, totalAmount));

		for (i = 0; i < receiveLength; i++) {
			r = receivers[i];
			if (r == address(0) || r == msg.sender) continue;
			wallets[r] = wallets[r].add(amount);
			emit Transfer(msg.sender, r, amount);
		}
		wallets[msg.sender] -= totalAmount;
		return true;
	}


	function batchTransfers (address[] receivers, uint256[] amounts) public whenRunning returns (bool) {
		uint receiveLength = receivers.length;
		require(receiveLength == amounts.length);

		uint receiverCount = 0;
		uint256 totalAmount = 0;
		uint i;
		address r;
		for (i = 0; i < receiveLength; i ++) {
			r = receivers[i];
			if (r == address(0) || r == msg.sender) continue;
			receiverCount ++;
			totalAmount += amounts[i];
		}
		require(totalAmount > 0);
		require(canPay(msg.sender, totalAmount));

		uint256 amount;
		for (i = 0; i < receiveLength; i++) {
			r = receivers[i];
			if (r == address(0) || r == msg.sender) continue;
			amount = amounts[i];
			wallets[r] = wallets[r].add(amount);
			emit Transfer(msg.sender, r, amount);
		}
		wallets[msg.sender] -= totalAmount;
		return true;
	}


	function transferFrom (address from, address to, uint256 value) public whenRunning canTransfer(from, to, value) returns (bool) {
		uint256 warrant;
		if (msg.sender != from) {
			warrant = warrants[from][msg.sender];
			require(value <= warrant);
		}

		require(canPay(from, value));

		if (msg.sender != from) warrants[from][msg.sender] = warrant.sub(value);
		wallets[from] = wallets[from].sub(value);
		wallets[to] = wallets[to].add(value);
		emit Transfer(from, to, value);
		return true;
	}


	function batchTransferFrom (address from, address[] receivers, uint256 amount) public whenRunning returns (bool) {
		require(amount > 0);

		uint receiveLength = receivers.length;
		uint receiverCount = 0;
		uint i;
		address r;
		for (i = 0; i < receiveLength; i ++) {
			r = receivers[i];
			if (r != address(0) && r != from) receiverCount ++;
		}
		require(receiverCount > 0);

		uint256 totalAmount = amount.mul(uint256(receiverCount));
		require(canPay(from, totalAmount));

		uint256 warrant;
		if (msg.sender != from) {
			warrant = warrants[from][msg.sender];
			require(totalAmount <= warrant);
		}

		for (i = 0; i < receiveLength; i++) {
			r = receivers[i];
			if (r == address(0) || r == from) continue;
			wallets[r] = wallets[r].add(amount);
			emit Transfer(from, r, amount);
		}
		wallets[from] -= totalAmount;
		if (msg.sender != from) warrants[from][msg.sender] = warrant.sub(totalAmount);
		return true;
	}


	function batchTransferFroms (address from, address[] receivers, uint256[] amounts) public whenRunning returns (bool) {
		uint receiveLength = receivers.length;
		require(receiveLength == amounts.length);

		uint receiverCount = 0;
		uint256 totalAmount = 0;
		uint i;
		address r;
		for (i = 0; i < receiveLength; i ++) {
			r = receivers[i];
			if (r == address(0) || r == from) continue;
			receiverCount ++;
			totalAmount += amounts[i];
		}
		require(totalAmount > 0);
		require(canPay(from, totalAmount));

		uint256 warrant;
		if (msg.sender != from) {
			warrant = warrants[from][msg.sender];
			require(totalAmount <= warrant);
		}

		uint256 amount;
		for (i = 0; i < receiveLength; i++) {
			r = receivers[i];
			if (r == address(0) || r == from) continue;
			amount = amounts[i];
			wallets[r] = wallets[r].add(amount);
			emit Transfer(from, r, amount);
		}
		wallets[from] -= totalAmount;
		if (msg.sender != from) warrants[from][msg.sender] = warrant.sub(totalAmount);
		return true;
	}
}


contract FountainToken is LockableToken {
	string  public constant name     = "Fountain";
	string  public constant symbol   = "FTN";
	uint8   public constant decimals = 18;

	uint256 private constant TOKEN_CAP     = 10000000000 * 10 ** uint256(decimals);
	uint256 private constant TOKEN_INITIAL = 300000000  * 10 ** uint256(decimals);

	constructor () public LockableToken(TOKEN_INITIAL, TOKEN_CAP) {
		
	}
}