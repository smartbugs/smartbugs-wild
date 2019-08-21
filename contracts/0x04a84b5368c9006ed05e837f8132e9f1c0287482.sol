pragma solidity 0.4.25;

contract Everest {
    using SafeMath for uint;
    mapping(address => uint) public balance;
    mapping(address => uint) public time;
    mapping(address => uint) public allPercentWithdraw;
    uint public stepTime = 24 hours;
    uint public countOfInvestors = 0;
    address public ownerAddress = 0x524011386BCDFB614f7373Ee8aeb494199D812BE;
    address public adminAddress = 0xc210F228dFdb2c7C3B9BC347032a507ee62dC95c;
    uint ownerPercent = 5;
    uint projectPercent = 15; //1.5%
    uint public minDeposit = 1 ether / 100;

    event Invest(address investor, uint256 amount);
    event Withdraw(address investor, uint256 amount, string eventType);

    modifier userExist() {
        require(balance[msg.sender] > 0, "Address not found");
        _;
    }

    modifier checkTime() {
        require(now >= time[msg.sender].add(stepTime), "Too fast payout request");
        _;
    }

    function collectPercent() userExist checkTime internal {
        if (balance[msg.sender].mul(2) <= allPercentWithdraw[msg.sender]) {
            balance[msg.sender] = 0;
            time[msg.sender] = 0;
            allPercentWithdraw[msg.sender] = 0;
        } else {
            uint payout = payoutAmount();
            allPercentWithdraw[msg.sender] = allPercentWithdraw[msg.sender].add(payout);
            msg.sender.transfer(payout);
            time[msg.sender] = now;
            emit Withdraw(msg.sender, payout, 'collectPercent');
        }
    }

    function payoutAmount() public view returns (uint256) {
        uint256 different = now.sub(time[msg.sender]).div(stepTime);
        uint256 rate = balance[msg.sender].mul(projectPercent).div(1000);
        uint256 withdrawalAmount = rate.mul(different);

        return withdrawalAmount;
    }

    function deposit() private {
        if (msg.value > 0) {
            require(msg.value >= minDeposit, "Wrong deposit value");

            if (balance[msg.sender] == 0) {
                countOfInvestors += 1;

                address referrer = bytesToAddress(msg.data);
                if (balance[referrer] > 0 && referrer != msg.sender) {
                    uint256 sum = msg.value.mul(projectPercent).div(1000);
                    referrer.transfer(sum);
                    emit Withdraw(referrer, sum, 'referral');

                    msg.sender.transfer(sum);
                    emit Withdraw(msg.sender, sum, 'referral');
                }
            }

            if (balance[msg.sender] > 0 && now > time[msg.sender].add(stepTime)) {
                collectPercent();
            }

            balance[msg.sender] = balance[msg.sender].add(msg.value);
            time[msg.sender] = now;

            ownerAddress.transfer(msg.value.mul(ownerPercent).div(100));
            adminAddress.transfer(msg.value.mul(ownerPercent).div(100));
            emit Invest(msg.sender, msg.value);
        } else {
            collectPercent();
        }
    }

    function() external payable {
        deposit();
    }

    function bytesToAddress(bytes bys) private pure returns (address addr) {
        assembly {
            addr := mload(add(bys, 20))
        }
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