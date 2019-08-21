pragma solidity ^0.4.8;


contract SafeMath {

  function assert(bool assertion) internal {
    if (!assertion) throw;
  }

  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

}


contract StandardTokenProtocol {

    function totalSupply() constant returns (uint256 totalSupply) {}
    function balanceOf(address _owner) constant returns (uint256 balance) {}
    function transfer(address _recipient, uint256 _value) returns (bool success) {}
    function transferFrom(address _from, address _recipient, uint256 _value) returns (bool success) {}
    function approve(address _spender, uint256 _value) returns (bool success) {}
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _recipient, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}


contract StandardToken is StandardTokenProtocol {

    modifier when_can_transfer(address _from, uint256 _value) {
        if (balances[_from] >= _value) _;
    }

    modifier when_can_receive(address _recipient, uint256 _value) {
        if (balances[_recipient] + _value > balances[_recipient]) _;
    }

    modifier when_is_allowed(address _from, address _delegate, uint256 _value) {
        if (allowed[_from][_delegate] >= _value) _;
    }

    function transfer(address _recipient, uint256 _value)
        when_can_transfer(msg.sender, _value)
        when_can_receive(_recipient, _value)
        returns (bool o_success)
    {
        balances[msg.sender] -= _value;
        balances[_recipient] += _value;
        Transfer(msg.sender, _recipient, _value);
        return true;
    }

    function transferFrom(address _from, address _recipient, uint256 _value)
        when_can_transfer(_from, _value)
        when_can_receive(_recipient, _value)
        when_is_allowed(_from, msg.sender, _value)
        returns (bool o_success)
    {
        allowed[_from][msg.sender] -= _value;
        balances[_from] -= _value;
        balances[_recipient] += _value;
        Transfer(_from, _recipient, _value);
        return true;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool o_success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 o_remaining) {
        return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;

}

contract GUPToken is StandardToken {

	//FIELDS
	string public name = "Guppy";
    string public symbol = "GUP";
    uint public decimals = 3;

	//CONSTANTS
	uint public constant LOCKOUT_PERIOD = 1 years; //time after end date that illiquid GUP can be transferred

	//ASSIGNED IN INITIALIZATION
	uint public endMintingTime; //Timestamp after which no more tokens can be created
	address public minter; //address of the account which may mint new tokens

	mapping (address => uint) public illiquidBalance; //Balance of 'Frozen funds'

	//MODIFIERS
	//Can only be called by contribution contract.
	modifier only_minter {
		if (msg.sender != minter) throw;
		_;
	}

	// Can only be called if illiquid tokens may be transformed into liquid.
	// This happens when `LOCKOUT_PERIOD` of time passes after `endMintingTime`.
	modifier when_thawable {
		if (now < endMintingTime + LOCKOUT_PERIOD) throw;
		_;
	}

	// Can only be called if (liquid) tokens may be transferred. Happens
	// immediately after `endMintingTime`.
	modifier when_transferable {
		if (now < endMintingTime) throw;
		_;
	}

	// Can only be called if the `crowdfunder` is allowed to mint tokens. Any
	// time before `endMintingTime`.
	modifier when_mintable {
		if (now >= endMintingTime) throw;
		_;
	}

	// Initialization contract assigns address of crowdfund contract and end time.
	function GUPToken(address _minter, uint _endMintingTime) {
		endMintingTime = _endMintingTime;
		minter = _minter;
	}

	// Create new tokens when called by the crowdfund contract.
	// Only callable before the end time.
	function createToken(address _recipient, uint _value)
		when_mintable
		only_minter
		returns (bool o_success)
	{
		balances[_recipient] += _value;
		totalSupply += _value;
		return true;
	}

	// Create an illiquidBalance which cannot be traded until end of lockout period.
	// Can only be called by crowdfund contract before the end time.
	function createIlliquidToken(address _recipient, uint _value)
		when_mintable
		only_minter
		returns (bool o_success)
	{
		illiquidBalance[_recipient] += _value;
		totalSupply += _value;
		return true;
	}

	// Make sender's illiquid balance liquid when called after lockout period.
	function makeLiquid()
		when_thawable
	{
		balances[msg.sender] += illiquidBalance[msg.sender];
		illiquidBalance[msg.sender] = 0;
	}

	// Transfer amount of tokens from sender account to recipient.
	// Only callable after the crowd fund end date.
	function transfer(address _recipient, uint _amount)
		when_transferable
		returns (bool o_success)
	{
		return super.transfer(_recipient, _amount);
	}

	// Transfer amount of tokens from a specified address to a recipient.
	// Only callable after the crowd fund end date.
	function transferFrom(address _from, address _recipient, uint _amount)
		when_transferable
		returns (bool o_success)
	{
		return super.transferFrom(_from, _recipient, _amount);
	}
}