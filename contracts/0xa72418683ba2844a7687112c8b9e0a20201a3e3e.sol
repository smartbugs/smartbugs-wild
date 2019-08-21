pragma solidity ^0.4.25;

library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }
}

contract Plus50 {
    
    using SafeMath for uint;
    
    mapping (address=>uint) public holding;
    mapping (address=>uint) public percentage;
    mapping (address=>uint) public time_stamp;
    
    address public marketing_wallet = 0x82770c9dE54e316a9eba378516A3314Bc17FAcbe;
    uint public marketing_percent = 8;
    
    uint public max_contribution = 50 ether;
    uint public max_percentage = 150; //150%
    uint public referral_percent = 2; //2%
    uint public hourly_percentage = 3125; //0.3125 % per hours
    uint public payment_delay = 1 hours;
    uint public count_investors = 0;
    
    function bytesToAddress(bytes _data) internal pure returns(address referrer) {
        assembly {
            referrer := mload(add(_data,0x14))
        }
        
        return referrer;
    }
    
    function elapsedTime()public view returns(uint) {
        return now.sub(time_stamp[msg.sender]).div(payment_delay);
    }
    
    function getBonus(uint _value)public pure  returns(uint) {
        uint bonus = 0;
        if(_value >= 10 ether && _value < 25 ether){
            bonus = _value.mul(5).div(1000);
        }else if(_value >= 25 ether && _value < 50 ether){
            bonus = _value.mul(75).div(10000);
        }else if(_value == 50 ether){
            bonus = _value.mul(1).div(100);
        }
        
        return bonus;
    }
    
    function deposit() internal {
        uint sum_hold = holding[msg.sender].add(msg.value);
        
        require(sum_hold <= max_contribution, 'Maximum Deposit 50 ether');
        
        if(holding[msg.sender] > 0 && elapsedTime() > 0){
            pickUpCharges();
        }
        if (msg.data.length == 20) {
            address referral = bytesToAddress(bytes(msg.data));
            if(referral != msg.sender){
                referral.transfer(msg.value.mul(referral_percent).div(100));
            }
            
        }
        if(holding[msg.sender] == 0){
            count_investors+=1;
        }
        marketing_wallet.transfer(msg.value.mul(marketing_percent).div(100));
        holding[msg.sender]+= msg.value.add(getBonus(msg.value));
        time_stamp[msg.sender] = now;
    }
    
    function pickUpCharges() internal {
        uint hours_passed = elapsedTime();
        
        require(hours_passed > 0, 'You can receive payment 1 time per hour');
        
        uint value = (holding[msg.sender].mul(hourly_percentage).div(1000000)).mul(hours_passed);
        uint total_percent = percentage[msg.sender].add(value);
        uint max_percent = holding[msg.sender].mul(max_percentage).div(100);
        if(total_percent > max_percent){
            uint rest = total_percent - max_percent;
            holding[msg.sender] = 0;
            time_stamp[msg.sender] = 0;
            percentage[msg.sender] = 0;
            msg.sender.transfer(value.sub(rest));
        }else{
            percentage[msg.sender] += value;
            time_stamp[msg.sender] = now;
            msg.sender.transfer(value);
        }
    }
    
    function reinvest()internal {
        uint hours_passed = elapsedTime();
        require(holding[msg.sender] > 0  && hours_passed > 0);
        uint value = (holding[msg.sender].mul(hourly_percentage).div(1000000)).mul(hours_passed);
        marketing_wallet.transfer(value.mul(marketing_percent).div(100));
        holding[msg.sender] += value;
        time_stamp[msg.sender] = now;
    }

    function() external payable {
        if(msg.value > 0){
            if(msg.value == 0.0000000001 ether){
                reinvest();
            }else{
                deposit();
            }
        }else if(msg.value == 0){
            require(holding[msg.sender] > 0);
            pickUpCharges();
        }
    }
}