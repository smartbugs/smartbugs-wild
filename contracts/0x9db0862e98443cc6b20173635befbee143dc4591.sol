pragma solidity 0.4.25;

contract SmartMinFin {

    using SafeMath for uint;
    mapping(address => uint) public balance;
    mapping(address => uint) public time;
    mapping(address => uint) public timeFirstDeposit;
    mapping(address => uint) public allPercentWithdraw;
    mapping(address => uint) public reservedBalance;
    uint public stepTime = 24 hours;
    uint public firstStep = stepTime;
    uint public secondStep = stepTime * 2;
    uint public thirdStep = stepTime * 3;
    uint public countOfInvestors = 0;
    uint public maxWithdrawal = 3 ether;
    address public ownerAddress = 0x166a9749e261186511B1174F955224d850Cf8af7;
    uint projectPercent = 10;
    uint public minDeposit = 1 ether / 10;

    event Invest(address investor, uint256 amount);
    event Withdraw(address investor, uint256 amount);

    modifier userExist() {
        require(balance[msg.sender] > 0, "Address not found");
        _;
    }

    modifier checkTime() {
        require(now >= timeFirstDeposit[msg.sender].add(thirdStep), "Too fast for first withdrawal");
        require(now >= time[msg.sender].add(stepTime), "Too fast payout request");
        _;
    }

    function collectPercent() userExist checkTime internal {
        if (balance[msg.sender].mul(2) <= allPercentWithdraw[msg.sender]) {
            balance[msg.sender] = 0;
            time[msg.sender] = 0;
        } else {
            uint payout = payoutAmount();
            allPercentWithdraw[msg.sender] = allPercentWithdraw[msg.sender].add(payout);
            msg.sender.transfer(payout);
            time[msg.sender] = now;
            emit Withdraw(msg.sender, payout);
        }
    }

    function percentRate() public view returns (uint) {
        if (now > time[msg.sender].add(thirdStep)) {
            return (80);
        }
        if (now > time[msg.sender].add(secondStep)) {
            return (50);
        }
        if (now > time[msg.sender].add(firstStep)) {
            return (30);
        }
    }

    function payoutAmount() public view returns (uint256) {
        uint256 percent = percentRate();
        uint256 different = now.sub(time[msg.sender]).div(stepTime);
        uint256 rate = balance[msg.sender].mul(percent).div(1000);
        uint256 withdrawalAmount = rate.mul(different);

        if(reservedBalance[msg.sender] > 0) {
            withdrawalAmount = withdrawalAmount.add(reservedBalance[msg.sender]);
            reservedBalance[msg.sender] = 0;
        }
        if (withdrawalAmount > maxWithdrawal) {
            reservedBalance[msg.sender] = withdrawalAmount.sub(maxWithdrawal);
            withdrawalAmount = maxWithdrawal;
        }

        return withdrawalAmount;
    }

    function deposit() private {
        if (msg.value > 0) {
            require(msg.value >= minDeposit, "Wrong deposit value");

            if (balance[msg.sender] == 0) {
                countOfInvestors += 1;
                timeFirstDeposit[msg.sender] = now;
            }
            if (balance[msg.sender] > 0 && now > time[msg.sender].add(stepTime) && now >= timeFirstDeposit[msg.sender].add(thirdStep)) {
                collectPercent();
            }
            balance[msg.sender] = balance[msg.sender].add(msg.value);
            time[msg.sender] = now;

            ownerAddress.transfer(msg.value.mul(projectPercent).div(100));
            emit Invest(msg.sender, msg.value);
        } else {
            collectPercent();
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
        require(b > 0);
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