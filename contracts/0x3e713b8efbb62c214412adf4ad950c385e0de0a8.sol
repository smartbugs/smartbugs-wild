pragma solidity 0.4.18;

contract Ownable {
	address public owner;
	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	function Ownable() {
		owner = msg.sender;
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	function transferOwnership(address newOwner) onlyOwner public {
		require(newOwner != address(0));
		OwnershipTransferred(owner, newOwner);
		owner = newOwner;
	}
}

library SafeMath {
	function mul(uint256 a, uint256 b) internal constant returns (uint256) {
		uint256 c = a * b;
		assert(a == 0 || c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal constant returns (uint256) {
		uint256 c = a / b;
		return c;
	}

	function sub(uint256 a, uint256 b) internal constant returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	function add(uint256 a, uint256 b) internal constant returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
}

contract ERC20 {
	uint256 public totalSupply;
	function balanceOf(address who) public constant returns (uint256);
	function transfer(address to, uint256 value) public returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);

	function allowance(address owner, address spender) public constant returns (uint256);
	function transferFrom(address from, address to, uint256 value) public returns (bool);
	function approve(address spender, uint256 value) public returns (bool);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract StandardToken is ERC20 {
	using SafeMath for uint256;

	mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

	function transfer(address _to, uint256 _value) public returns (bool) {
		require(_to != address(0));

		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		Transfer(msg.sender, _to, _value);
		return true;
	}

	function balanceOf(address _owner) public constant returns (uint256 balance) {
		return balances[_owner];
	}

	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
		require(_to != address(0));

		uint256 _allowance = allowed[_from][msg.sender];

		balances[_from] = balances[_from].sub(_value);
		balances[_to] = balances[_to].add(_value);
		allowed[_from][msg.sender] = _allowance.sub(_value);
		Transfer(_from, _to, _value);
		return true;
	}

	function approve(address _spender, uint256 _value) public returns (bool) {
		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
		return true;
	}

	function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
		return allowed[_owner][_spender];
	}
}

contract T8EXToken is StandardToken {
	string public constant name = "T8EX Token";
    string public constant symbol = "T8EX";
    uint8  public constant decimals = 18;

	address public minter; 
	uint    public tokenSaleEndTime; 

	// token lockup for cornerstone investors
	mapping(address=>uint) public lockedBalanceCor; 
	mapping(uint=>address) lockedBalanceCor_index;
	uint lockedBalanceCor_count;

	// token lockup for private investors
	mapping(address=>uint) public lockedBalancePri; 
	mapping(uint=>address) lockedBalancePri_index;
	uint lockedBalancePri_count;

	modifier onlyMinter {
		require (msg.sender == minter);
		_;
	}

	modifier whenMintable {
		require (now <= tokenSaleEndTime);
		_;
	}

    modifier validDestination(address to) {
        require(to != address(this));
        _;
    }

	function T8EXToken(address _minter, uint _tokenSaleEndTime) public {
		minter = _minter;
		tokenSaleEndTime = _tokenSaleEndTime;
    }

	function transfer(address _to, uint _value)
        public
        validDestination(_to)
        returns (bool) 
    {
        return super.transfer(_to, _value);
    }

	function transferFrom(address _from, address _to, uint _value)
        public
        validDestination(_to)
        returns (bool) 
    {
        return super.transferFrom(_from, _to, _value);
    }

	function createToken(address _recipient, uint _value)
		whenMintable
		onlyMinter
		returns (bool)
	{
		balances[_recipient] += _value;
		totalSupply += _value;
		return true;
	}

	// Create an lockedBalance which cannot be traded until admin make it liquid.
	// Can only be called by crowdfund contract before the end time.
	function createLockedTokenCor(address _recipient, uint _value)
		whenMintable
		onlyMinter
		returns (bool) 
	{
		lockedBalanceCor_index[lockedBalanceCor_count] = _recipient;
		lockedBalanceCor[_recipient] += _value;
		lockedBalanceCor_count++;

		totalSupply += _value;
		return true;
	}

	// Make sender's locked balance liquid when called after lockout period.
	function makeLiquidCor()
		onlyMinter
	{
		for (uint i=0; i<lockedBalanceCor_count; i++) {
			address investor = lockedBalanceCor_index[i];
			balances[investor] += lockedBalanceCor[investor];
			lockedBalanceCor[investor] = 0;
		}
	}

	// Create an lockedBalance which cannot be traded until admin make it liquid.
	// Can only be called by crowdfund contract before the end time.
	function createLockedTokenPri(address _recipient, uint _value)
		whenMintable
		onlyMinter
		returns (bool) 
	{
		lockedBalancePri_index[lockedBalancePri_count] = _recipient;
		lockedBalancePri[_recipient] += _value;
		lockedBalancePri_count++;

		totalSupply += _value;
		return true;
	}

	// Make sender's locked balance liquid when called after lockout period.
	function makeLiquidPri()
		onlyMinter
	{
		for (uint i=0; i<lockedBalancePri_count; i++) {
			address investor = lockedBalancePri_index[i];
			balances[investor] += lockedBalancePri[investor];
			lockedBalancePri[investor] = 0;
		}
	}
}