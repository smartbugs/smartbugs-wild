/**
 * Website: www.SafeInvest.co
 *
 * RECOMMENDED GAS LIMIT: 200000
 * RECOMMENDED GAS PRICE: https://ethgasstation.info/
 */

pragma solidity 0.4.25;


library SafeMath {


    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0);
        uint256 c = _a / _b;

        return c;
    }

    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

contract SafeInvest {
    
	using SafeMath for uint;

    address public owner;
    address marketing = 0x906Bd47Fcf07F82B98F28d1e572cA8D2273AA7CD;
    address admin = 0xe0C507cd978F380eac44eDf22Ea734B6c16B5fCF;

    mapping (address => uint) deposit;
    mapping (address => uint) checkpoint;
    mapping (address => bool) commission; 

    mapping (address => address) referrers;

    event LogInvestment(address indexed _addr, uint _value);
    event LogPayment(address indexed _addr, uint _value);
	event LogReferralPayment(address indexed _referral, address indexed _referrer, uint _value);

    constructor() public {
        owner = msg.sender;
    }

    function renounceOwnership() external {
        require(msg.sender == owner);
        owner = 0x0;
    }

    function bytesToAddress(bytes _source) internal pure returns(address parsedreferrer) {
        assembly {
            parsedreferrer := mload(add(_source,0x14))
        }
        return parsedreferrer;
    }

    function() external payable {
        if (msg.value >= 0 && msg.value < 0.0000002 ether) {
            withdraw(0);
        } 
		else if (msg.value == 0.0000002 ether){
            moneyBack();
        } 
		else {
            invest();
        }		
    }
	
    function invest() public payable {
        require(msg.value >= 0.01 ether);
		
        if (deposit[msg.sender] > 0) {
            withdraw(msg.value);
        }
		
        if (msg.data.length == 20) {
            address _referrer = bytesToAddress(bytes(msg.data));
			if (_referrer != msg.sender) {
				referrers[msg.sender] = _referrer;
			}
        }		
		
		checkpoint[msg.sender] = block.timestamp;
		deposit[msg.sender] = deposit[msg.sender].add(msg.value);
		
		emit LogInvestment(msg.sender, msg.value);
	}		

    function withdraw(uint _msgValue) internal {
		if (!commission[msg.sender]) {
			firstWithdraw(deposit[msg.sender]+_msgValue);
		} else if (_msgValue > 0) {
			payCommissions(_msgValue);
		}
		
        uint _payout = getPayout(msg.sender);

        if (_payout > 0) {
            msg.sender.transfer(_payout);
            emit LogPayment(msg.sender, _payout);
        }
		
		checkpoint[msg.sender] = block.timestamp;
    }
	
	function firstWithdraw(uint _deposit) internal {	
		commission[msg.sender] = true;
		payCommissions(_deposit);
	}
	
	function moneyBack() internal {
		require(!commission[msg.sender]);
		require(deposit[msg.sender] > 0);
		require((block.timestamp.sub(checkpoint[msg.sender])).div(1 days) < 7);
		
		msg.sender.transfer(deposit[msg.sender]);
		
		deposit[msg.sender] = 0;
		commission[msg.sender] = false;
	}

	function payCommissions(uint _deposit) internal {	
		uint _admFee = _deposit.mul(3).div(100); 
		uint _marketingFee = _deposit.div(10); 
        if (referrers[msg.sender] > 0) {
			uint _refFee = _deposit.mul(5).div(100);
			referrers[msg.sender].transfer(_refFee);
			emit LogReferralPayment(msg.sender, referrers[msg.sender], _refFee);
		}
		
		admin.transfer(_admFee);
		marketing.transfer(_marketingFee);
	}
		
    function getPayout(address _address) public view returns(uint) {
		uint rate = getInterest(_address);
		return (deposit[_address].mul(rate).div(100)).mul(block.timestamp.sub(checkpoint[_address])).div(1 days);
    }
	
    function getInterest(address _address) internal view returns(uint) {
        if (deposit[_address]<= 3 ether) {
            return 4; 
        } else if (deposit[_address] <= 6 ether) {
            return 5; 
        } else {
            return 6; 
        }
    }	


}