pragma solidity ^0.4.25;


contract Olympus {
    
    using SafeMath for uint;
    
    mapping (address=>uint) public invest;
    mapping (address=>uint) public percentage;
    mapping (address=>uint) public time_stamp;
    
    address techSupport = 0x0bD47808d4A09aD155b00C39dBb101Fb71e1C0f0;
    uint techSupportPercent = 2;
    
    uint refPercent = 3;
    uint refBack = 3;
    
    uint public payment_delay = 1 hours;
    uint public count_investors = 0;
    
    function bytesToAddress(bytes _data) internal pure returns(address referrer) {
        assembly {
            referrer := mload(add(_data, 20))
        }
        return referrer;
    }
    
    function elapsedTime()public view returns(uint) {
        return now.sub(time_stamp[msg.sender]).div(payment_delay);
    }
    
    function calculateProfitPercent(uint bal) private pure returns (uint) {
        if (bal >= 4e21) { // balance >= 4000 ETH
            return 2500;   // 6% per day
        }
        if (bal >= 2e21) { // balance >= 2000 ETH
            return 2083;   // 5% per day
        }
        if (bal >= 1e21) { // balance >= 1000 ETH
            return 1875;   // 4.5% per day
        }
        if (bal >= 5e20) { // balance >= 500 ETH
            return 1666;   // 4% per day
        }
        if (bal >= 4e20) { // balance >= 400 ETH
            return 1583;   // 3.8% per day
        }
        if (bal >= 3e20) { // balance >= 300 ETH
            return 1500;   // 3.6% per day
        }
        if (bal >= 2e20) { // balance >= 200 ETH
            return 1416;   // 3.4% per day
        }
        if (bal >= 1e20) { // balance >= 100 ETH
            return 1333;   // 3.2% per day
        } else {
            return 1250;   // 3% per day
        }
    }
    
    function deposit() internal {
        if(invest[msg.sender] > 0 && elapsedTime() > 0) {
            pickUpCharges();
        }
        if (msg.data.length > 0 ) {
            address referrer = bytesToAddress(bytes(msg.data));
            address sender = msg.sender;
            if(referrer != sender) {
                sender.transfer(msg.value * refBack / 100);
                referrer.transfer(msg.value * refPercent / 100);
            } else {
                techSupport.transfer(msg.value * refPercent / 100);
            }
        } else {
            techSupport.transfer(msg.value * refPercent / 100);
        }
        if(invest[msg.sender] == 0) {
            count_investors+=1;
        }
        techSupport.transfer(msg.value.mul(techSupportPercent).div(100));
        invest[msg.sender]+= msg.value;
        time_stamp[msg.sender] = now;
    }
    
    function pickUpCharges() internal {
        uint hours_passed = elapsedTime();
        require(hours_passed > 0, 'You can receive payment 1 time per hour');
        uint thisBalance = address(this).balance;
        uint value = (invest[msg.sender].mul(calculateProfitPercent(thisBalance)).div(1000000)).mul(hours_passed);
        percentage[msg.sender] += value;
        time_stamp[msg.sender] = now;
        msg.sender.transfer(value);
    }
    
    function() external payable {
        if(msg.value > 0) {
                deposit();
        } else if(msg.value == 0) {
            pickUpCharges();
        }
    }
}

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    require(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;
    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}