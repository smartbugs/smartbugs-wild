pragma solidity ^ 0.4.24;

contract VTM {
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract BaseContract is VTM {
	using SafeMath
	for * ;

	string public name;
	string public symbol;
	uint8 public decimals;
	uint256 public totalSupply;
	mapping(address => uint256) public balanceOf;
	mapping(address => mapping(address => uint256)) public allowance;

	mapping(address => address[]) public affs;
	mapping(address => address) public aff;

	function BaseContract(
		uint256 _totalSupply,
		string _name,
		uint8 _decimal,
		string _symbol
	) {
		totalSupply = _totalSupply;
		name = _name;
		symbol = _symbol;
		decimals = _decimal;
		balanceOf[msg.sender] = _totalSupply;
		aff[msg.sender] = msg.sender;
	}

	function transfer(address _to, uint256 _value) public returns(bool success) {
		require(_to != 0x0, "invalid addr");
		balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
		balanceOf[_to] = balanceOf[_to].add(_value);
		emit Transfer(msg.sender, _to, _value);
		if(_value > 0 && aff[_to] == address(0) && msg.sender != _to) {
			aff[_to] = msg.sender;
			affs[msg.sender].push(_to);
		}
		return true;
	}

	function approve(address _spender, uint256 _value) public returns(bool success) {
		require(_spender != 0x0, "invalid addr");
		require(_value > 0, "invalid value");
		allowance[msg.sender][_spender] = _value;
		return true;
	}

	function transferFrom(address _from, address _to, uint256 _value) public returns(bool success) {
		require(_from != 0x0, "invalid addr");
		require(_to != 0x0, "invalid addr");
		balanceOf[_from] = balanceOf[_from].sub(_value);
		balanceOf[_to] = balanceOf[_to].add(_value);
		allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
		emit Transfer(_from, _to, _value);
		return true;
	}

	function getAff(address _addr)
	public
	view
	returns(address) {
		return aff[_addr];
	}
	
	function getAffLength(address _addr)
	public
	view
	returns(uint256) {
		return affs[_addr].length;
	}

}

library SafeMath {

	function sub(uint256 a, uint256 b)
	internal
	pure
	returns(uint256 c) {
		require(b <= a, "sub failed");
		c = a - b;
		require(c <= a, "sub failed");
		return c;
	}

	function add(uint256 a, uint256 b)
	internal
	pure
	returns(uint256 c) {
		c = a + b;
		require(c >= a, "add failed");
		return c;
	}

}