//! FrozenToken ECR20-compliant token contract
//! By Parity Technologies, 2017.
//! Released under the Apache Licence 2.

pragma solidity ^0.4.17;

// Owned contract.
contract Owned {
	modifier only_owner { require (msg.sender == owner); _; }

	event NewOwner(address indexed old, address indexed current);

	function setOwner(address _new) public only_owner { NewOwner(owner, _new); owner = _new; }

	address public owner;
}

// FrozenToken, a bit like an ECR20 token (though not - as it doesn't
// implement most of the API).
// All token balances are generally non-transferable.
// All "tokens" belong to the owner (who is uniquely liquid) at construction.
// Liquid accounts can make other accounts liquid and send their tokens
// to other axccounts.
contract FrozenToken is Owned {
	event Transfer(address indexed from, address indexed to, uint256 value);

	// this is as basic as can be, only the associated balance & allowances
	struct Account {
		uint balance;
		bool liquid;
	}

	// constructor sets the parameters of execution, _totalSupply is all units
	function FrozenToken(uint _totalSupply, address _owner)
        public
		when_non_zero(_totalSupply)
	{
		totalSupply = _totalSupply;
		owner = _owner;
		accounts[_owner].balance = totalSupply;
		accounts[_owner].liquid = true;
	}

	// balance of a specific address
	function balanceOf(address _who) public constant returns (uint256) {
		return accounts[_who].balance;
	}

	// make an account liquid: only liquid accounts can do this.
	function makeLiquid(address _to)
		public
		when_liquid(msg.sender)
		returns(bool)
	{
		accounts[_to].liquid = true;
		return true;
	}

	// transfer
	function transfer(address _to, uint256 _value)
		public
		when_owns(msg.sender, _value)
		when_liquid(msg.sender)
		returns(bool)
	{
		Transfer(msg.sender, _to, _value);
		accounts[msg.sender].balance -= _value;
		accounts[_to].balance += _value;

		return true;
	}

	// no default function, simple contract only, entry-level users
	function() public {
		assert(false);
	}

	// the balance should be available
	modifier when_owns(address _owner, uint _amount) {
		require (accounts[_owner].balance >= _amount);
		_;
	}

	modifier when_liquid(address who) {
		require (accounts[who].liquid);
		_;
	}

	// a value should be > 0
	modifier when_non_zero(uint _value) {
		require (_value > 0);
		_;
	}

	// Available token supply
	uint public totalSupply;

	// Storage and mapping of all balances & allowances
	mapping (address => Account) accounts;

	// Conventional metadata.
	string public constant name = "DOT Allocation Indicator";
	string public constant symbol = "DOT";
	uint8 public constant decimals = 3;
}