pragma solidity 0.4.25;

/**
* Smart-contract 155percents
* You can invest ETH to the 155percents and take 4% per day, also you can send 0.001 ETH to contract and
* your percent will be increase on 0.04% per day while you hold your profit, after you withdraw percent will returns to 4%
*
* - To invest you can send at least 0.01 ETH to contract
* - To withdraw your profit you can send 0 ETH to contract
* - To turn on increasing percent you can send 0.001 ETH to contract
*/
contract OneHundredFiftyFive {

    using SafeMath for uint256;

    struct Investor {
        uint256 deposit;
        uint256 paymentTime;
        uint256 withdrawals;
        bool hold;
    }

    mapping (address => Investor) public investors;

    uint256 public countOfInvestors;
    uint256 public startTime;

    address public ownerAddress = 0xC24ddFFaaCEB94f48D2771FE47B85b49818204Be;

    /**
    * @dev Constructor function which set starting time
    */
    constructor() public {
        startTime = now;
    }

    /**
    * @dev  Evaluate user current percent.
    * @param _address Investor's address
    * @return Amount of profit depends on HOLD mode
    */
    function getUserProfit(address _address) view public returns (uint256) {
        Investor storage investor = investors[_address];

        uint256 passedMinutes = now.sub(investor.paymentTime).div(1 minutes);

        if (investor.hold) {
            uint firstDay = 0;

            if (passedMinutes >= 1440) {
                firstDay = 1440;
            }

            //Evaluate profit to according increasing profit percent on 0.04% daily
            //deposit * ( 400 +  4 * (passedMinutes-1440)/1440) * (passedMinutes)/14400
            return investor.deposit.mul(400 + 4 * (passedMinutes.sub(firstDay)).div(1440)).mul(passedMinutes).div(14400000);
        } else {
            //Evaluate profit on 4% per day
            //deposit*4/100*(passedMinutes)/1440
            uint256 differentPercent = investor.deposit.mul(4).div(100);
            return differentPercent.mul(passedMinutes).div(1440);
        }
    }

    /**
    * @dev Return current Ethereum time
    */
    function getCurrentTime() view public returns (uint256) {
        return now;
    }

    /**
    * @dev Withdraw profit from contract. Investor will be deleted if he will try withdraw after received 155%
    * @param _address Investor's address
    */
    function withdraw(address _address) private {
        Investor storage investor = investors[_address];
        uint256 balance = getUserProfit(_address);

        if (investor.deposit > 0 && balance > 0) {
            if (address(this).balance < balance) {
                balance = address(this).balance;
            }

            investor.withdrawals = investor.withdrawals.add(balance);
            investor.paymentTime = now;

            if (investor.withdrawals >= investor.deposit.mul(155).div(100)) {
                investor.deposit = 0;
                investor.paymentTime = 0;
                investor.withdrawals = 0;
                investor.hold = false;
                countOfInvestors--;
            }

            msg.sender.transfer(balance);
        }
    }

    /**
    * @dev  You able:
    * - To invest you can send at least 0.01 ETH to contract
    * - To withdraw your profit you can send 0 ETH to contract
    * - To turn on increasing percent you can send 0.001 ETH to contract
    */
    function () external payable {
        Investor storage investor = investors[msg.sender];

        if (msg.value >= 0.01 ether) {

            ownerAddress.transfer(msg.value.mul(10).div(100));

            if (investor.deposit == 0) {
                countOfInvestors++;
            }

            withdraw(msg.sender);

            investor.deposit = investor.deposit.add(msg.value);
            investor.paymentTime = now;
        } else if (msg.value == 0.001 ether) {
            withdraw(msg.sender);
            investor.hold = true;
        } else {
            withdraw(msg.sender);
        }
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
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

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}