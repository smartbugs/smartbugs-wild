pragma solidity ^0.4.25;

library SafeMath {
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    if (_a == 0) {
      return 0;
    }
    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    return _a / _b;
  }

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

contract SmartRock {
    using SafeMath for uint256;
    uint constant public MINIMUM_INVEST = 1000000000000000 wei;
    uint constant public MAXIMUM_INVEST = 50000000000000000000 wei;
    uint constant public PERCENT_STEP1 = 250000000000000000000 wei;
    uint constant public PERCENT_STEP2 = 500000000000000000000 wei;
    uint constant public PERCENT_STEP3 = 750000000000000000000 wei;
    uint constant public PERCENT_STEP4 = 1000000000000000000000 wei;
    mapping (address => uint256) blocksData;
    mapping (address => uint256) deposits;
    mapping (address => uint256) referals;
    mapping (address => uint256) referalsData;
    address ad = 0x4F51785F0Fb33f869728dA547181a8F20F8c433E;
    address income = 0x15781b8d632A1B158B85d98418E2CA0219D6f675;
    
	function() payable public {
	    get();
	}
	
	function get() payable public {
	    require(msg.value >= MINIMUM_INVEST, "Too small amount, minimum 0.001 ether");
	    require(msg.value <= MAXIMUM_INVEST, "Too big amount, max 1 ether");
	    uint256 refPercent;
	    uint256 refpay;
	    uint256 percent;
	    percent = getPercent();
	    
	    if(deposits[msg.sender] != 0 && now > blocksData[msg.sender] + 1200) {
    	    uint256 paymount;
    	    paymount = deposits[msg.sender].mul(percent).div(10000).mul(getBlockTime(msg.sender)).div(86400);
	        msg.sender.transfer(paymount);
	        
	        if(referals[msg.sender] != 0) {
	            refpay = referals[msg.sender].mul(percent).div(10000).mul(2).div(100).mul(getRefTime(msg.sender)).div(86400);
            	referalsData[msg.sender] = now;
            	msg.sender.transfer(refpay);
	        }
	    } 
	    
	    deposits[msg.sender] += msg.value; 
	    blocksData[msg.sender] = now;
	    address ref = bytesToAddress(msg.data);
	    
	    ad.transfer(msg.value.div(100).mul(10));
	    income.transfer(msg.value.div(100).mul(5));
	    
	    if (ref > 0x0 && ref != msg.sender) {
            if(referals[ref] != 0) {
            	refpay = referals[ref].mul(percent).div(10000).mul(2).div(100).mul(getRefTime(ref)).div(86400);
            	ref.transfer(refpay);
            }
            
            referals[ref] += msg.value;
            referalsData[ref] = now;
            refPercent = msg.value.mul(3).div(100);  
            ref.transfer(refPercent);
            deposits[msg.sender] += msg.value.mul(1).div(100); 
	    }
	}
	
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    function getPercent() public view returns(uint256) {
        uint256 balance = getBalance();
        uint256 percent = 0;
        if(balance > PERCENT_STEP4)
            percent = 400; 
        if(balance < PERCENT_STEP3)
            percent = 350; 
        if(balance < PERCENT_STEP2)
            percent = 325; 
        if(balance < PERCENT_STEP1)
            percent = 300;
   
        return percent;
    }
    
    function getBlockTime(address addr) public view returns(uint256) {
        return now - blocksData[addr];
    }

    function getRefTime(address addr) public view returns(uint256) {
        return now - referalsData[addr];
    }

	function bytesToAddress(bytes bys) private pure returns (address addr) {
		assembly {
			addr := mload(add(bys, 20))
		}
	}
}