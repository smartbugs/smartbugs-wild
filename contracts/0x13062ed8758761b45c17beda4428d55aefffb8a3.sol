pragma solidity 0.4.25;

/**
* ETH CRYPTOCURRENCY DISTRIBUTION PROJECT v 3.0
* Web              - https://3333eth.ru
* 
* 
*  - GAIN 3,33% - 1% PER 24 HOURS (interest is charges in equal parts every 10 min)
*  - Life-long payments
*  - The revolutionary reliability
*  - Minimal contribution 0.01 eth
*  - Currency and payment - ETH
*  - Contribution allocation schemes:
*    -- 87% payments
*    --  8% marketing
*    --  5% technical support
*
* RECOMMENDED GAS LIMIT: 200000
* RECOMMENDED GAS PRICE: https://ethgasstation.info/
* You can check the payments on the etherscan.io site, in the "Internal Txns" tab of your wallet.
* 
* ---It is not allowed to transfer from exchanges, only from your personal ETH wallet, for which you 
* have private keys.
* 
* Contracts reviewed and approved by pros!
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

}

/**
The development of the contract is entirely owned by the 3333eth campaign, any copying of the source code is not legal.
*/
contract Eth333v3 {
    //use of library of safe mathematical operations    
    using SafeMath
    for uint;
    // array containing information about beneficiaries
    mapping(address => uint) public userDeposit;
    //array containing information about the time of payment
    mapping(address => uint) public userTime;
    //array containing information on interest paid
    mapping(address => uint) public persentWithdraw;
    //fund fo transfer percent
    address public projectFund = 0x18e9F86ed0430679f79EF2eA0cc5E1186b80c570;
    //wallet for a charitable foundation
    address public charityFund = 0xf36EEbB7438aDef0E7fE4650a6Cd6dB238B58c6a;
    //percentage deducted to the advertising fund
    uint projectPercent = 8;
    //percent for a charitable foundation
    uint public charityPercent = 5;
    //time through which you can take dividends
    uint public chargingTime = 1 hours;
    //start persent 0.13% per hour
    uint public startPercent = 250;
    uint public lowPersent = 300;
    uint public middlePersent = 350;
    uint public highPersent = 375;
    //interest rate increase steps
    uint public stepLow = 1000 ether;
    uint public stepMiddle = 2500 ether;
    uint public stepHigh = 5000 ether;
    uint public countOfInvestors = 0;
    uint public countOfCharity = 0;

    modifier isIssetUser() {
        require(userDeposit[msg.sender] > 0, "Deposit not found");
        _;
    }

    modifier timePayment() {
        require(now >= userTime[msg.sender].add(chargingTime), "Too fast payout request");
        _;
    }

    //return of interest on the deposit
    function collectPercent() isIssetUser timePayment internal {
        //if the user received 200% or more of his contribution, delete the user
        if ((userDeposit[msg.sender].mul(2)) <= persentWithdraw[msg.sender]) {
            userDeposit[msg.sender] = 0;
            userTime[msg.sender] = 0;
            persentWithdraw[msg.sender] = 0;
        } else {
            uint payout = payoutAmount();
            userTime[msg.sender] = now;
            persentWithdraw[msg.sender] += payout;
            msg.sender.transfer(payout);
        }
    }

    //calculation of the current interest rate on the deposit
    function persentRate() public view returns(uint) {
        //get contract balance
        uint balance = address(this).balance;
        //calculate persent rate
        if (balance < stepLow) {
            return (startPercent);
        }
        if (balance >= stepLow && balance < stepMiddle) {
            return (lowPersent);
        }
        if (balance >= stepMiddle && balance < stepHigh) {
            return (middlePersent);
        }
        if (balance >= stepHigh) {
            return (highPersent);
        }
    }

    //refund of the amount available for withdrawal on deposit
    function payoutAmount() public view returns(uint) {
        uint persent = persentRate();
        uint rate = userDeposit[msg.sender].mul(persent).div(100000);
        uint interestRate = now.sub(userTime[msg.sender]).div(chargingTime);
        uint withdrawalAmount = rate.mul(interestRate);
        return (withdrawalAmount);
    }

    //make a contribution to the system
    function makeDeposit() private {
        if (msg.value > 0) {
            if (userDeposit[msg.sender] == 0) {
                countOfInvestors += 1;
            }
            if (userDeposit[msg.sender] > 0 && now > userTime[msg.sender].add(chargingTime)) {
                collectPercent();
            }
            userDeposit[msg.sender] = userDeposit[msg.sender].add(msg.value);
            userTime[msg.sender] = now;
            //sending money for advertising
            projectFund.transfer(msg.value.mul(projectPercent).div(100));
            //sending money to charity
            uint charityMoney = msg.value.mul(charityPercent).div(100);
            countOfCharity+=charityMoney;
            charityFund.transfer(charityMoney);
        } else {
            collectPercent();
        }
    }
}