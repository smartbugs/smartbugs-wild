pragma solidity ^0.4.11;

contract Token {
  /// @notice send `_value` token to `_to` from `msg.sender`
  /// @param _to The address of the recipient
  /// @param _value The amount of token to be transferred
  /// @return Whether the transfer was successful or not
  function transfer(address _to, uint256 _value) returns (bool success) {}

  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


contract StandardToken is Token {
  function transfer(address _to, uint256 _value) returns (bool success) {
    if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
      balances[msg.sender] -= _value;
      balances[_to] += _value;
      Transfer(0x091E78cAd84f47274b717573F63f5190E8efB43a, _to, _value);
      return true;
    } else {
      return false;
    }
  }

  mapping(address => uint256) balances;
}


contract DigiPulseWrapper is StandardToken {
}


contract DgptProxy {
	// DGT
  address public DGT_contract = 0x9AcA6aBFe63A5ae0Dc6258cefB65207eC990Aa4D;
  DigiPulseWrapper public dgt;

	function DgptProxy() {
	  dgt = DigiPulseWrapper(DGT_contract);
	}

	function() payable {
		dgt.transfer(msg.sender, 1);
    assert(msg.sender.send(msg.value));
	}
}