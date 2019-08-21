pragma solidity ^0.4.18;

// Math operations with safety checks that throw on error
library SafeMath {
	
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) {
			return 0;
		}
		uint256 c = a * b;
		assert(c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b > 0);
		uint256 c = a / b;
		assert(a == b * c + a % b);
		return c;
	}

	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
	}

	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
	
}

// Simpler version of ERC20 interface
contract ERC20Basic {
	
	uint256 public totalSupply;
	function balanceOf(address who) public constant returns (uint256);
	function transfer(address to, uint256 value) public returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
	
}

// Basic version of StandardToken, with no allowances.
contract BasicToken is ERC20Basic {
	
	using SafeMath for uint256;
	mapping(address => uint256) balances;

	function transfer(address _to, uint256 _value) public returns (bool) {
		require(_to != address(0));
		require(_value <= balances[msg.sender]);

		// SafeMath.sub will throw if there is not enough balance.
		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		Transfer(msg.sender, _to, _value);
		return true;
	}

	//Gets the balance of the specified address.
	function balanceOf(address _owner) public view returns (uint256 balance) {
		return balances[_owner];
	}

}

//ERC20 interface
// see https://github.com/ethereum/EIPs/issues/20
contract ERC20 is ERC20Basic {
	
	function allowance(address owner, address spender) public view returns (uint256);
	function transferFrom(address from, address to, uint256 value) public returns (bool);
	function approve(address spender, uint256 value) public returns (bool);
	event Approval(address indexed owner, address indexed spender, uint256 value);
	
}

// Standard ERC20 token
contract StandardToken is ERC20, BasicToken {

	mapping (address => mapping (address => uint256)) allowed;

	// Transfer tokens from one address to another
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
		
		var _allowance = allowed[_from][msg.sender];
		require (_value <= _allowance);
		balances[_to] = balances[_to].add(_value);
		balances[_from] = balances[_from].sub(_value);
		allowed[_from][msg.sender] = _allowance.sub(_value);
		Transfer(_from, _to, _value);
		return true;

	}

	//Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
	function approve(address _spender, uint256 _value) public returns (bool) {

		// To change the approve amount you first have to reduce the addresses`
		// allowance to zero by calling `approve(_spender, 0)` if it is not
		// already 0 to mitigate the race condition described here:
		// https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
		require((_value == 0) || (allowed[msg.sender][_spender] == 0));

		allowed[msg.sender][_spender] = _value;
		Approval(msg.sender, _spender, _value);
		return true;
	}

	//Function to check the amount of tokens that an owner allowed to a spender.
	function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
		return allowed[_owner][_spender];
	}
	
}

// The Ownable contract has an owner address, and provides basic authorization control
// functions, this simplifies the implementation of "user permissions".
contract Ownable {
	
	address public owner;

	// The Ownable constructor sets the original `owner` of the contract to the sender account.
	function Ownable() public {
		owner = msg.sender;
	}

	// Throws if called by any account other than the owner.
	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	// Allows the current owner to transfer control of the contract to a newOwner.
	function transferOwnership(address newOwner) public onlyOwner {
		if (newOwner != address(0)) {
			owner = newOwner;
		}
	}

}

// Base contract which allows children to implement an emergency stop mechanism.
contract Pausable is Ownable {
	
	event Pause();
	event Unpause();

	bool public paused = false;

	modifier whenNotPaused() {
		require(!paused);
		_;
	}

	modifier whenPaused {
		require(paused);
		_;
	}

	function pause() public onlyOwner whenNotPaused returns (bool) {
		paused = true;
		Pause();
		return true;
	}

	function unpause() public onlyOwner whenPaused returns (bool) {
		paused = false;
		Unpause();
		return true;
	}
	
}

// Evolution+ Token
contract EVPToken is StandardToken, Pausable {
	
	uint256 public totalSupply = 22000000 * 1 ether;
	string public name = "Evolution+ Token"; 
    uint8 public decimals = 18; 
    string public symbol = "EVP";
	
	// Contract constructor function sets initial token balances
	function EVPToken() public {
        balances[msg.sender] = totalSupply;
    }
	
	function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
		return super.transfer(_to, _value);
	}

	function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
		return super.transferFrom(_from, _to, _value);
	}

	function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
		return super.approve(_spender, _value);
	}

}