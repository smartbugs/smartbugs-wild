pragma solidity ^0.4.25;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract CoooinsCoinAd {

	using SafeMath for uint256;

	string public adMessage;
	string public adUrl;
	uint256 public purchaseTimestamp;
	uint256 public purchaseSeconds;
	uint256 public adPriceWeek;
	uint256 public adPriceMonth;
	address public contractOwner;

	event newAd(address indexed buyer, uint256 amount, string adMessage, string adUrl, uint256 purchaseSeconds, uint256 purchaseTimestamp);

	modifier onlyContractOwner {
		require(msg.sender == contractOwner);
		_;
	}

	constructor() public {
		adPriceWeek = 50000000000000000;
		adPriceMonth = 150000000000000000;
		contractOwner = 0x2E26a4ac59094DA46a0D8d65D90A7F7B51E5E69A;
	}

	function withdraw() public onlyContractOwner {
		contractOwner.transfer(address(this).balance);
	}

	function setAdPriceWeek(uint256 amount) public onlyContractOwner {
		adPriceWeek = amount;
	}

	function setAdPriceMonth(uint256 amount) public onlyContractOwner {
		adPriceMonth = amount;
	}

	function updateAd(string message, string url) public payable {
		// set minimum amount and make sure ad hasnt expired
		require(msg.value >= adPriceWeek);
		require(block.timestamp > purchaseTimestamp.add(purchaseSeconds));

		// set ad time limit in seconds
		if (msg.value >= adPriceMonth) {
			purchaseSeconds = 2592000; // 1 month
		} else {
			purchaseSeconds = 604800; // 1 week
		}

		adMessage = message;
		adUrl = url;

		purchaseTimestamp = block.timestamp;

		emit newAd(msg.sender, msg.value, adMessage, adUrl, purchaseSeconds, purchaseTimestamp);
	}

	function getPurchaseTimestampEnds() public view returns (uint _getPurchaseTimestampAdEnds) {
		return purchaseTimestamp.add(purchaseSeconds);
	}

	function getBalance() public view returns(uint256){
		return address(this).balance;
	}

}