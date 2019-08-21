pragma solidity ^0.4.18;

library SafeMath {
	function mul(uint256 a, uint256 b) internal pure returns (uint256) {
		if (a == 0) return 0;
		uint256 c = a * b;
		assert(c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a / b;
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

contract Ownable {
	address public owner;

	event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

	function Ownable() public {
		owner = msg.sender;
	}

	modifier onlyOwner() {
		require(msg.sender == owner);
		_;
	}

	function transferOwnership(address newOwner) public onlyOwner {
		require(newOwner != address(0));
		OwnershipTransferred(owner, newOwner);
		owner = newOwner;
	}
}

contract Token {
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        (_from);
        (_to);
        (_value);
		return true;
	}
}

contract Crowdsale2 is Ownable {
	
	using SafeMath for uint256;

	Token public token;
	
	address public wallet;
	
	address public destination;

	uint256 public startTime;
	
	uint256 public endTime;

	uint256 public rate;

	uint256 public tokensSold;
	
	uint256 public weiRaised;

	event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);

	function Crowdsale2(address _token, address _wallet, address _destination, uint256 _startTime, uint256 _endTime, uint256 _rate) public {
		startTime = _startTime;
		endTime = _endTime;
		rate = _rate;
		token = Token(_token);
		wallet = _wallet;
		destination = _destination;
	}

	function () external payable {
		require(validPurchase());

		uint256 amount = msg.value;
		uint256 tokens = amount.mul(rate) / (1 ether);

		weiRaised = weiRaised.add(amount);
		tokensSold = tokensSold.add(tokens);

		token.transferFrom(wallet, msg.sender, tokens);
		TokenPurchase(msg.sender, amount, tokens);

		destination.transfer(amount);
	}

	function validPurchase() internal view returns (bool) {
		bool withinPeriod = now >= startTime && now <= endTime;
		bool nonZeroPurchase = msg.value != 0;
		return withinPeriod && nonZeroPurchase;
	}

	function setEndTime(uint256 _endTime) public onlyOwner returns (bool) {
		endTime = _endTime;
		return true;
	}

	function hasEnded() public view returns (bool) {
		return now > endTime;
	}
}