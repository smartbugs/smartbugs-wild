pragma solidity 0.4.25;

interface tokenRecipient { function receiveApproval(address _from, uint _value, address _token, bytes _extraData) external; }

library SafeMath {

  function add(uint a, uint b) internal pure returns (uint) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function mul(uint a, uint b) internal pure returns (uint) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
    uint256 c = a / b;
    return c;
  }

}

contract owned {

	address public owner;

	constructor() public {
		owner = msg.sender;
	}

    modifier onlyOwner {
		require (msg.sender == owner);
		_;
    }

	function transferOwnership(address newOwner) public onlyOwner {
		require(newOwner != 0x0);
		owner = newOwner;
	}
}


contract Token is owned {

	using SafeMath for uint256;

	string public name;
    string public symbol;
    uint8 public decimals;
    uint public totalSupply;

    mapping (address => uint) public balances;
    mapping (address => mapping (address => uint)) public allowance;
	mapping (address => bool) public frozenAccount;

    event Transfer(address indexed from, address indexed to, uint value);
    event Burn(address indexed from, uint value);
	event FrozenFunds(address indexed target, bool frozen);

    constructor(uint256 initialSupply, string tokenName, string tokenSymbol, uint8 tokenDecimal) public {
        totalSupply = initialSupply * 10 ** uint(tokenDecimal);
        balances[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
		decimals = tokenDecimal;
    }

    function _transfer(address _from, address _to, uint _value) internal {
		require(_from != 0x0);
		require(_to != 0x0);
		require(balances[_from] >= _value && balances[_to] + _value > balances[_to]);
		require(!frozenAccount[_from]);
        require(!frozenAccount[_to]);
		uint previousBalances = balances[_from].add(balances[_to]);
		balances[_from] = balances[_from].sub(_value);
		balances[_to] = balances[_to].add(_value);
		emit Transfer(_from, _to, _value);
		assert(balances[_from] + balances[_to] == previousBalances);
    }
	
	function balanceOf(address _from) public view returns (uint) {
		return balances[_from];
	}

    function transfer(address _to, uint _value) public returns (bool) {
		_transfer(msg.sender, _to, _value);
		return true;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
		require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint _value) public returns (bool) {
		allowance[msg.sender][_spender] = _value;
        return true;
    }

    function approveAndCall(address _spender, uint _value, bytes _extraData) public returns (bool) {
		tokenRecipient spender = tokenRecipient(_spender);
		if (approve(_spender, _value)) {
			spender.receiveApproval(msg.sender, _value, this, _extraData);
			return true;
        }
		return false;
    }

    function burn(uint _value) public returns (bool) {
		require(balances[msg.sender] >= _value);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint _value) public onlyOwner returns (bool) {
        require(balances[_from] >= _value);
        require(_value <= allowance[_from][msg.sender]);
        balances[_from] = balances[_from].sub(_value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(_from, _value);
        return true;
    }
	
	function mintToken(address target, uint mintedAmount) public onlyOwner returns (bool) {
		balances[target] = balances[target].add(mintedAmount);
        totalSupply = totalSupply.add(mintedAmount);
		emit Transfer(0, this, mintedAmount);
		emit Transfer(this, target, mintedAmount);
		return true;
    }
	
	function freezeAccount(address target, bool freeze) public onlyOwner returns (bool) {
		frozenAccount[target] = freeze;
		emit FrozenFunds(target, freeze);
		return true;
    }

}