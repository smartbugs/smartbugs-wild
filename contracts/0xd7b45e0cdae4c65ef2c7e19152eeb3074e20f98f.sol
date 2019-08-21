pragma solidity ^0.4.18;

interface TokenRecipient {
	function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public;
}

contract Erc20 { // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
	function totalSupply() public constant returns (uint256 amount);
	function balanceOf(address owner) public constant returns (uint256 balance);
	function transfer(address to, uint256 value) public returns (bool success);
	function transferFrom(address from, address to, uint256 value) public returns (bool success);
	function approve(address spender, uint256 value) public returns (bool success);
	function allowance(address owner, address spender) public constant returns (uint256 remaining);

	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Erc20Plus is Erc20 {
	function approveAndCall(address spender, uint256 value, bytes extraData) public returns (bool success);
	function burn(uint256 value) public returns (bool success);
	function burnFrom(address from, uint256 value) public returns (bool success);
}

contract Owned {
	address internal _owner;

	function Owned() public {
		_owner = msg.sender;
	}

	function kill() public onlyOwner {
		selfdestruct(_owner);
	}

	modifier onlyOwner {
		require(msg.sender == _owner);
		_;
	}

	function harvest() onlyOwner public {
		_owner.transfer(this.balance);
	}

	function () public payable {
		require(false); // throw
	}
}

contract CreditcoinBase is Owned {
//----------- ERC20 members
	uint8 public constant decimals = 18;
//=========== ERC20 members

	uint256 internal constant FRAC_IN1UNIT = 10 ** uint256(decimals);
	uint256 public constant creditcoinLimitInFrac = 2000000000 * FRAC_IN1UNIT;
	uint256 public constant initialSupplyInFrac = creditcoinLimitInFrac * 30 / 100; // 10% for sale + 15% for Gluwa + 5% for Creditcoin Foundation
}

/// @title Creditcoin ERC20 token
contract Creditcoin is CreditcoinBase, Erc20Plus {
//----------- ERC20 members
	string public constant name = "Creditcoin";
	string public constant symbol = "CRE";
//=========== ERC20 members

	mapping (address => uint256) internal _balanceOf;
	uint256 internal _totalSupply;
	mapping (address => mapping (address => uint256)) internal _allowance;

	event Burnt(address indexed from, uint256 value);
	event Minted(uint256 value);

	address public pool;
	address internal minter;

	function Creditcoin(address icoSalesAccount) public {
		_totalSupply = initialSupplyInFrac;
		pool = icoSalesAccount;
		_balanceOf[pool] = _totalSupply;
	}

	function _transfer(address from, address to, uint256 value) internal {
		require(to != 0x0);
		require(_balanceOf[from] >= value);
		require(_balanceOf[to] + value > _balanceOf[to]);

		uint256 previousBalances = _balanceOf[from] + _balanceOf[to];

		_balanceOf[from] -= value;
		_balanceOf[to] += value;

		Transfer(from, to, value);
		assert(_balanceOf[from] + _balanceOf[to] == previousBalances);
	}

//----------- ERC20 members
	function totalSupply() public constant returns (uint256 amount) {
		amount = _totalSupply;
	}
	
	function balanceOf(address owner) public constant returns (uint256 balance) {
		balance = _balanceOf[owner];
	}
	
	function allowance(address owner, address spender) public constant returns (uint256 remaining) {
		remaining = _allowance[owner][spender];
	}
	
	function transfer(address to, uint256 value) public returns (bool success) {
		_transfer(msg.sender, to, value);
		success = true;
	}

	function transferFrom(address from, address to, uint256 value) public returns (bool success) {
		require(value <= _allowance[from][msg.sender]);
		_allowance[from][msg.sender] -= value;
		_transfer(from, to, value);
		success = true;
	}

	function approve(address spender, uint256 value) public returns (bool success) {
		_allowance[msg.sender][spender] = value;
		success = true;
	}
//=========== ERC20 members

	function approveAndCall(address spender, uint256 value, bytes extraData) public returns (bool success) {
		TokenRecipient recepient = TokenRecipient(spender);
		if (approve(spender, value)) {
			recepient.receiveApproval(msg.sender, value, this, extraData);
			success = true;
		}
	}

	function burn(uint256 value) public returns (bool success) {
		require(_balanceOf[msg.sender] >= value);
		_balanceOf[msg.sender] -= value;
		_totalSupply -= value;

		Burnt(msg.sender, value);
		success = true;
	}

	function burnFrom(address from, uint256 value) public returns (bool success) {
		require(_balanceOf[from] >= value);
		require(value <= _allowance[from][msg.sender]);
		_balanceOf[from] -= value;
		_allowance[from][msg.sender] -= value;
		_totalSupply -= value;

		Burnt(from, value);
		success = true;
	}

	/// this function allows to mint coins up to totalSupply, so if coins were burnt it adds room for minting
	/// since natural loss of coins is expected the overall amount in use will be less than totalSupply
	function mint(uint256 amount) public returns (bool success) {
		require(msg.sender == minter);
		require(creditcoinLimitInFrac > amount && creditcoinLimitInFrac - amount >= _totalSupply);
		require(_balanceOf[msg.sender] + amount > _balanceOf[msg.sender]);
		_balanceOf[msg.sender] += amount;
		_totalSupply += amount;

		Minted(amount);
		success = true;
	}

	function setMinter(address newMinter) onlyOwner public returns (bool success) {
		minter = newMinter;
		success = true;
	}
}