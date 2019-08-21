pragma solidity ^0.4.18;

contract HOLDx3 {
    using SafeMath for uint;
    
    mapping(address => uint[64]) public invest_amount;
    mapping(address => uint[64]) public invest_time;
    mapping(address => uint) public invest_count;

    mapping(address => uint[64]) public withdraw_amount;
    mapping(address => uint[64]) public withdraw_time;
    mapping(address => uint) public withdraw_count;

    mapping(address => uint) total_invest_amount;
    mapping(address => uint) total_paid_amount;
    mapping(address => uint) public last_withdraw_time;

    uint public investors = 0;

    uint stepTime = 1 hours;
    address dev_addr = 0x703826fc8D2a5506EAAe7808ab3B090521B04eDc;
    uint dev_fee= 10;

    modifier userExist() {
        require(total_invest_amount[msg.sender] > 0);
        _;
    }

    modifier checkTime() {
        require(now >= last_withdraw_time[msg.sender].add(stepTime));
        _;
    }

    function deposit() private {
        // invest
        if (msg.value > 0) {
            if (last_withdraw_time[msg.sender] == 0) last_withdraw_time[msg.sender] = now;
            if (total_invest_amount[msg.sender] == 0) {
                invest_count[msg.sender] = 0;
                withdraw_count[msg.sender] = 0;
                total_paid_amount[msg.sender] = 0;
                investors++;
            }
            invest_amount[msg.sender][invest_count[msg.sender]] = msg.value;
            invest_time[msg.sender][invest_count[msg.sender]] = now;
            invest_count[msg.sender] = invest_count[msg.sender]+1;
            total_invest_amount[msg.sender] = total_invest_amount[msg.sender].add(msg.value);
            dev_addr.transfer(msg.value.mul(dev_fee).div(100));
        }
        // claim percents
        else{
            CalculateAllPayoutAmount();
        }
    }

    function CalculateAllPayoutAmount() checkTime userExist internal {
        uint payout_amount = CalculatePayoutAmount();
        uint hold_payout_amount = CalculateHoldPayoutAmount();
        payout_amount = payout_amount.add(hold_payout_amount);
        SendPercent(payout_amount); 
    }

    function SendPercent(uint _payout_amount) internal {
        // checking that contract balance have an ether to pay dividents
        if (_payout_amount > address(this).balance) _payout_amount = address(this).balance;
        if (address(this).balance >= _payout_amount && _payout_amount > 0) {
            //checking that user claimed not more then x3 of his total investitions
            if ((_payout_amount.add(total_paid_amount[msg.sender])) > total_invest_amount[msg.sender].mul(3)) {
                _payout_amount = total_invest_amount[msg.sender].mul(3).sub(total_paid_amount[msg.sender]);
                for (uint16 i = 0; i < invest_count[msg.sender]; i++) {
                    invest_amount[msg.sender][i] = 0;
                }
                invest_count[msg.sender] = 0;
                total_invest_amount[msg.sender] = 0;
                total_paid_amount[msg.sender] = 0;
                last_withdraw_time[msg.sender] = 0;
            }
            else {
                total_paid_amount[msg.sender] = total_paid_amount[msg.sender].add(_payout_amount);
                last_withdraw_time[msg.sender] = now;
            }
            withdraw_amount[msg.sender][withdraw_count[msg.sender]] = _payout_amount;
            withdraw_time[msg.sender][withdraw_count[msg.sender]] = now;
            withdraw_count[msg.sender] = withdraw_count[msg.sender]+1;
            msg.sender.transfer(_payout_amount);
        }
    }
 
    function CalculatePayoutAmount() internal view returns (uint){
        uint percent = DayliPercentRate();
        uint _payout_amount = 0;
        uint time_spent = 0;
        // calculating all dividents for the current day percent rate
        for (uint16 i = 0; i < invest_count[msg.sender]; i++) {
            if (last_withdraw_time[msg.sender] > invest_time[msg.sender][i]) {
                time_spent = (now.sub(last_withdraw_time[msg.sender])).div(stepTime);
            }
            else {
                time_spent = (now.sub(invest_time[msg.sender][i])).div(stepTime);
            }
            uint current_payout_amount = (invest_amount[msg.sender][i].mul(time_spent).mul(percent).div(100)).div(24);
            _payout_amount = _payout_amount.add(current_payout_amount);
        }
        return _payout_amount;
    }

    function CalculateHoldPayoutAmount() internal view returns (uint){
        uint hold_payout_amount = 0;
        uint time_spent = 0;
        for (uint16 i = 0; i < invest_count[msg.sender]; i++) {
            if (last_withdraw_time[msg.sender] > invest_time[msg.sender][i]) 
                time_spent = (now.sub(last_withdraw_time[msg.sender])).div(stepTime.mul(24));
            else 
                time_spent = (now.sub(invest_time[msg.sender][i])).div(stepTime.mul(24));

            if (time_spent > 30) time_spent = 30;
            
            if (time_spent > 0) {
                uint hold_percent = 117**time_spent;
                uint devider = 100**time_spent;
                uint current_payout_amount = invest_amount[msg.sender][i].mul(hold_percent).div(devider).div(100);
                hold_payout_amount = hold_payout_amount.add(current_payout_amount);
            }
        }
        return hold_payout_amount;
    }

    function DayliPercentRate() internal view returns(uint) {
        uint contractBalance = address(this).balance;
        if (contractBalance >= 0 ether && contractBalance < 100 ether) {
            return (3);
        }
        if (contractBalance >= 100 ether && contractBalance < 200 ether) {
            return (4);
        }
        if (contractBalance >= 200 ether && contractBalance < 500 ether) {
            return (5);
        }
        if (contractBalance >= 500 ether && contractBalance < 1000 ether) {
            return (6);
        }
        if (contractBalance >= 1000 ether) {
            return (7); 
        }
    }

    function() external payable {
        deposit();
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
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