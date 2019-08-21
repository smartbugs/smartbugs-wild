pragma solidity 0.4.25;

contract X2Contract {
    using SafeMath for uint256;

    address public constant promotionAddress = 0x22e483dBeb45EDBC74d4fE25d79B5C28eA6Aa8Dd;
    address public constant adminAddress = 0x3C1FD40A99066266A60F60d17d5a7c51434d74bB;

    mapping (address => uint256) public deposit;
    mapping (address => uint256) public withdrawals;
    mapping (address => uint256) public time;

    uint256 public minimum = 0.01 ether;
    uint public promotionPercent = 10;
    uint public adminPercent = 2;
    uint256 public countOfInvestors;

    /**
    * @dev Get percent depends on balance of contract
    * @return Percent
    */
    function getPhasePercent() view public returns (uint){
        uint contractBalance = address(this).balance;
        if (contractBalance < 300 ether) {
            return 2;
        }
        if (contractBalance >= 300 ether && contractBalance < 1200 ether) {
            return 3;
        }
        if (contractBalance >= 1200 ether) {
            return 4;
        }
    }

    /**
    * @dev Evaluate current balance
    * @param _address Address of investor
    * @return Payout amount
    */
    function getUserBalance(address _address) view public returns (uint256) {
        uint percent = getPhasePercent();
        uint256 differentTime = now.sub(time[_address]).div(1 hours);
        uint256 differentPercent = deposit[_address].mul(percent).div(100);
        uint256 payout = differentPercent.mul(differentTime).div(24);

        return payout;
    }

    /**
    * @dev Withdraw profit from contract. Investor will be deleted if he will try withdraw after received x2
    * @param _address Address of investor
    */
    function withdraw(address _address) private {
        //Get user balance
        uint256 balance = getUserBalance(_address);
        //Conditions for withdraw, deposit should be more than 0, balance of contract should be more than balance of
        //investor and balance of investor should be more than 0
        if (deposit[_address] > 0 && address(this).balance >= balance && balance > 0) {
            //Add withdrawal to storage
            withdrawals[_address] = withdrawals[_address].add(balance);
            //Reset time
            time[_address] = now;
            //If withdrawals more greater or equal deposit * 2 - delete investor
            if (withdrawals[_address] >= deposit[_address].mul(2)){
                deposit[_address] = 0;
                time[_address] = 0;
                withdrawals[_address] = 0;
                countOfInvestors--;
            }
            //Transfer percents to investor
            _address.transfer(balance);
        }

    }

    /**
    * @dev  Payable function
    */
    function () external payable {
        if (msg.value >= minimum){
            //Payout for promotion
            promotionAddress.transfer(msg.value.mul(promotionPercent).div(100));
            //Payout for admin
            adminAddress.transfer(msg.value.mul(adminPercent).div(100));

            //Withdraw a profit
            withdraw(msg.sender);

            //Increase counter of investors
            if (deposit[msg.sender] == 0){
                countOfInvestors++;
            }

            //Add deposit to storage
            deposit[msg.sender] = deposit[msg.sender].add(msg.value);
            //Reset last time of deposit
            time[msg.sender] = now;
        } else {
            //Withdraw a profit
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
        // Gas optimization: this is cheaper then requiring 'a' not being zero, but the
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