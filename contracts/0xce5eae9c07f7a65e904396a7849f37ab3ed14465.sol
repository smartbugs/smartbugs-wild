pragma solidity ^0.4.24;

contract ConferencePay {
    uint public endTime;
    address public owner;
    mapping (bytes32 => uint) public talkMapping;
    using SafeMath for uint256;

    struct Talk {
        uint amount;
        address addr;
        bytes32 title;
    }

    Talk[] public talks;

    modifier onlyBefore(uint _time) { require(now < _time); _; }
    modifier onlyAfter(uint _time) { require(now > _time); _; }

	//event Transfer(address indexed _from, address indexed _to, uint256 _value);

	constructor(uint end) public {
        endTime = end;
        owner = msg.sender;
	}

    function getTalkCount() public constant returns(uint) {
        return talks.length;
    }

    function add(address addr, bytes32 title) public returns(uint) {
        uint index = talks.length;
        talkMapping[title] = index;
        talks.push(Talk({
            amount: 0,
            addr: addr,
            title: title
        }));
        return index;
    }

	function pay(uint talk) public payable returns(bool sufficient) {
		talks[talk].amount += msg.value;
		return true;
	}

    function end() public {
        require(now > endTime);
        uint max = 0;
        address winnerAddress;
        uint balance = address(this).balance;
        owner.transfer(balance.mul(20).div(100));
        for (uint i = 0; i < talks.length; i++) {
            if (talks[i].amount > max) {
                max = talks[i].amount;
                winnerAddress = talks[i].addr;
            }
            talks[i].addr.transfer(talks[i].amount.mul(70).div(100));
        }
        winnerAddress.transfer(address(this).balance);
    }
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
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