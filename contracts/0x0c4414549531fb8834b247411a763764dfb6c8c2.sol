pragma solidity ^0.4.10;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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

contract Crowdsale {

	using SafeMath for uint256;

	address public owner;
	address public multisig;
	uint256 public totalRaised;
	uint256 public constant hardCap = 20000 ether;
	mapping(address => bool) public whitelist;

	modifier isWhitelisted() {
		require(whitelist[msg.sender]);
		_;
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	modifier belowCap() {
		require(totalRaised < hardCap);
		_;
	}

	function Crowdsale(address _multisig) {
		require (_multisig != 0);
		owner = msg.sender;
		multisig = _multisig;
	}

	function whitelistAddress(address _user) onlyOwner {
		whitelist[_user] = true;
	}

	function whitelistAddresses(address[] _users) onlyOwner {
		for (uint i = 0; i < _users.length; i++) {
			whitelist[_users[i]] = true;
		}
	}
	
	function() payable isWhitelisted belowCap {
		totalRaised = totalRaised.add(msg.value);
		uint contribution = msg.value;
		if (totalRaised > hardCap) {
			uint refundAmount = totalRaised.sub(hardCap);
			msg.sender.transfer(refundAmount);
			contribution = contribution.sub(refundAmount);
			refundAmount = 0;
			totalRaised = hardCap;
		}
		multisig.transfer(contribution);
	}

	function withdrawStuck() onlyOwner {
		multisig.transfer(this.balance);
	}

}