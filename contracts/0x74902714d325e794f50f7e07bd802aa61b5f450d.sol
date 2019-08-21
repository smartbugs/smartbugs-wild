pragma solidity ^0.4.24;


contract Migrations {
	address public owner;
	address public newOwner;

	address public manager;
	address public newManager;

	event TransferOwnership(address oldaddr, address newaddr);
	event TransferManager(address oldaddr, address newaddr);

	modifier onlyOwner() { require(msg.sender == owner); _; }
	modifier onlyManager() { require(msg.sender == manager); _; }
	modifier onlyAdmin() { require(msg.sender == owner || msg.sender == manager); _; }


	constructor() public {
		owner = msg.sender;
		manager = msg.sender;
	}

	function transferOwnership(address _newOwner) onlyOwner public {
		newOwner = _newOwner;
	}

	function transferManager(address _newManager) onlyAdmin public {
		newManager = _newManager;
	}

	function acceptOwnership() public {
		require(msg.sender == newOwner);
		address oldaddr = owner;
		owner = newOwner;
		newOwner = address(0);
		emit TransferOwnership(oldaddr, owner);
	}

	function acceptManager() public {
		require(msg.sender == newManager);
		address oldaddr = manager;
		manager = newManager;
		newManager = address(0);
		emit TransferManager(oldaddr, manager);
	}
}



library SafeMath {

	function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
		if (_a == 0) {
			return 0;
		}
		uint256 c = _a * _b;
		require(c / _a == _b);

		return c;
	}

	function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
		require(_b > 0);
		uint256 c = _a / _b;

		return c;
	}

	function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
		require(_b <= _a);
		uint256 c =  _a - _b;

		return c;
	}

	function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
		uint256 c = _a + _b;
		require(c >= _a);

		return c;
	}

	function mod(uint256 _a, uint256 _b) internal pure returns (uint256) {
		require(_b != 0);
		return _a % _b;
	}
}


// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
	function totalSupply() public view returns (uint256);
	function balanceOf(address _owner) public view returns (uint256 balance);
	function allowance(address _owner, address _spender) public view returns (uint256 remaining);
	function transfer(address _to, uint256 _value) public returns (bool success);
	function transferFrom(address _from, address _to, uint _value) public returns (bool success);
	function approve(address _spender, uint256 _value) public returns (bool success);

	event Transfer(address indexed from, address indexed to, uint tokens);
	event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


contract ReentrancyGuard {
	uint256 private guardCounter = 1;

	modifier noReentrant() {
		guardCounter = guardCounter+1;
		uint256 localCounter = guardCounter;
		_;
		require(localCounter == guardCounter);
	}
}


interface tokenRecipient {
	function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external;
}


contract ERC20Base is ERC20Interface , ReentrancyGuard{
	using SafeMath for uint256;

	string public name;
	string public symbol;
	uint8 public decimals = 18;
	uint256 public totalSupply;

	mapping(address => uint256) public balanceOf;
	mapping(address => mapping (address => uint256)) public allowance;

	constructor() public {
		//totalSupply = initialSupply * 10 ** uint256(decimals);
		uint256 initialSupply = 10000000000;
		totalSupply = initialSupply.mul(1 ether);
		balanceOf[msg.sender] = totalSupply;
		name = "BB Token";
		symbol = "BBT";
		emit Transfer(address(0), msg.sender, totalSupply);
	}

	function () payable public {
		revert();
	}

	function totalSupply() public view returns(uint256) {
		return totalSupply;
	}

	function balanceOf(address _owner) public view returns (uint256 balance) {
		return balanceOf[_owner];
	}

	function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
		return allowance[_owner][_spender];
	}

	function _transfer(address _from, address _to, uint256 _value) internal returns (bool success) {
		require(_to != 0x0);
		require(balanceOf[_from] >= _value);
		if (balanceOf[_to].add(_value) <= balanceOf[_to]) {
			revert();
		}

		uint256 previousBalances = balanceOf[_from].add(balanceOf[_to]);
		balanceOf[_from] = balanceOf[_from].sub(_value);
		balanceOf[_to] = balanceOf[_to].add(_value);
		emit Transfer(_from, _to, _value);
		assert(balanceOf[_from].add(balanceOf[_to]) == previousBalances);

		return true;
	}

	function transfer(address _to, uint256 _value) public returns (bool success) {
		return _transfer(msg.sender, _to, _value);
	}

	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
		require(_value <= allowance[_from][msg.sender]);
		allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
		return _transfer(_from, _to, _value);
	}

	function approve(address _spender, uint256 _value) public returns (bool success) {
		allowance[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

	function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
		allowance[msg.sender][_spender] = (
		allowance[msg.sender][_spender].add(_addedValue));
		emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
		return true;
	}

	function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
		uint256 oldValue = allowance[msg.sender][_spender];
		if (_subtractedValue >= oldValue) {
			allowance[msg.sender][_spender] = 0;
		} else {
			allowance[msg.sender][_spender] = oldValue.sub(_subtractedValue);
		}
		emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
		return true;
	}

	function approveAndCall(address _spender, uint256 _value, bytes _extraData) noReentrant public returns (bool success) {
		tokenRecipient spender = tokenRecipient(_spender);
		if (approve(_spender, _value)) {
			spender.receiveApproval(msg.sender, _value, this, _extraData);
			return true;
		}
	}
}


contract BBToken is Migrations, ERC20Base {
	bool public isTokenLocked;
	bool public isUseFreeze;
	struct Frozen {
		bool from;
		uint256 fromUntil;
		bool to;
		uint256 toUntil;
		uint256 amount;
		uint256 amountUntil;
	}
	mapping (address => Frozen) public frozenAccount;

	event FrozenFunds(address target, bool freezeFrom, uint256 fromUntil, bool freezeTo, uint256 toUntil, uint256 freezeAmount, uint256 amountUntil);
	event Burn(address indexed from, uint256 value);

	constructor()
		ERC20Base()
		onlyOwner()
		public
	{
		uint256 initialSupply = 10000000000;
		isUseFreeze = true;
		totalSupply = initialSupply.mul(1 ether);
		isTokenLocked = false;
		symbol = "BBT";
		name = "BB Token";
		balanceOf[msg.sender] = totalSupply;
		emit Transfer(address(0), msg.sender, totalSupply);
	}

	modifier tokenLock() {
		require(isTokenLocked == false);
		_;
	}

	function setLockToken(bool _lock) onlyOwner public {
		isTokenLocked = _lock;
	}

	function setUseFreeze(bool _useOrNot) onlyAdmin public {
		isUseFreeze = _useOrNot;
	}

	function freezeFrom(address target, bool fromFreeze, uint256 fromUntil) onlyAdmin public {
		frozenAccount[target].from = fromFreeze;
		frozenAccount[target].fromUntil = fromUntil;
		emit FrozenFunds(target, fromFreeze, fromUntil, false, 0, 0, 0);
	}

	function freezeTo(address target, bool toFreeze, uint256 toUntil) onlyAdmin public {
		frozenAccount[target].to = toFreeze;
		frozenAccount[target].toUntil = toUntil;
		emit FrozenFunds(target, false, 0, toFreeze, toUntil, 0, 0);
	}

	function freezeAmount(address target, uint256 amountFreeze, uint256 amountUntil) onlyAdmin public {
		frozenAccount[target].amount = amountFreeze;
		frozenAccount[target].amountUntil = amountUntil;
		emit FrozenFunds(target, false, 0, false, 0, amountFreeze, amountUntil);
	}

	function freezeAccount(
		address target,
		bool fromFreeze,
		uint256 fromUntil,
		bool toFreeze,
		uint256 toUntil,
		uint256 amountFreeze,
		uint256 amountUntil
	) onlyAdmin public {
		require(isUseFreeze);
		frozenAccount[target].from = fromFreeze;
		frozenAccount[target].fromUntil = fromUntil;
		frozenAccount[target].to = toFreeze;
		frozenAccount[target].toUntil = toUntil;
		frozenAccount[target].amount = amountFreeze;
		frozenAccount[target].amountUntil = amountUntil;
		emit FrozenFunds(target, fromFreeze, fromUntil, toFreeze, toUntil, amountFreeze, amountUntil);
	}

	function isFrozen(address target) public view returns(bool, uint256, bool, uint256, uint256, uint256) {
		return (frozenAccount[target].from, frozenAccount[target].fromUntil, frozenAccount[target].to, frozenAccount[target].toUntil, frozenAccount[target].amount, frozenAccount[target].amountUntil);
	}

	function _transfer(address _from, address _to, uint256 _value) tokenLock internal returns(bool success) {
		require(_to != 0x0);
		require(balanceOf[_from] >= _value);

		if (balanceOf[_to].add(_value) <= balanceOf[_to]) {
			revert();
		}

		if (isUseFreeze == true) {
			if (frozenAccount[_from].from) {
				require(!(frozenAccount[_from].fromUntil > now));
			}
			if (frozenAccount[_to].to) {
				require(!(frozenAccount[_to].toUntil > now));
			}

			if (frozenAccount[_from].amountUntil > now) {
				if(balanceOf[_from].sub(_value) < frozenAccount[_from].amount) {
					revert();
				}
			}
		}

		balanceOf[_from] = balanceOf[_from].sub(_value);
		balanceOf[_to] = balanceOf[_to].add(_value);
		emit Transfer(_from, _to, _value);

		return true;
	}
}